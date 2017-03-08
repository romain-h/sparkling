let s:firstSignId = 100
let s:nextSignId = s:firstSignId
let s:mainDic = {}

func! sparkling#log(msg)
  if !g:sparkling_debug
    return
  end

  if exists('g:sparkling_debug_file')
    execute 'redir >> ' . g:sparkling_debug_file
    silent echomsg a:msg
    silent! redir END
  else
    echomsg 'Sparkling: ' . a:msg
  end
endfunc

func! sparkling#logError(msg)
  execute 'normal! \<Esc>'
  echohl ErrorMsg
  echomsg 'Sparkling: error: ' . a:msg
  echohl None
endfunc

" Highlight error/warning in current window
func! sparkling#HighLight(line, col, signName)
  call matchadd(a:signName, '\%' . a:line . 'l\%' . a:col . 'c')
endfunc

func! sparkling#RemoveHighLight()
  for match in getmatches()
    if stridx(match['group'], 'Sparkling') == 0
      call matchdelete(match['id'])
    endif
  endfor
endfunc

" Display sign on sidebar.
func! sparkling#DisplaySign(line, filePath, signName)
  execute 'sign place ' . s:nextSignId . ' line=' . a:line . ' name=' . a:signName . ' file=' . a:filePath
  let s:nextSignId += 1
endfunc

func! sparkling#RenderEslint(data)
  let filePath = get(a:data, 'filePath')

  " Remove all previous signs for this file
  execute 'sign unplace * file=' . filePath
  call sparkling#RemoveHighLight()

  let issues = get(a:data, 'messages')
  for i in issues
    let signName = i['severity'] ==? 2 ? 'SparklingError' : 'SparklingWarning'
    call sparkling#DisplaySign(i['line'], filePath, signName)
    call sparkling#HighLight(i['line'], i['column'], signName)
  endfor
endfunc

func! sparkling#CloseHandler(channel)
  while ch_status(a:channel, {'part': 'out'}) == 'buffered'
    let raw = ch_read(a:channel)
    let data = json_decode(raw)[0]
    let filePath = get(data, 'filePath')
    let issues = get(data, 'messages')
    let lines = {}

    for i in issues
      let line = i['line']
      if !has_key(lines, line)
        let lines[line] = []
      endif
      call add(lines[line], i)
    endfor
    let data.lines = lines

    let s:mainDic[filePath] = data
    call sparkling#RenderEslint(data)
  endwhile
endfunc

func! sparkling#GetErrorMsg(err)
  return a:err.message . ' (' . a:err.ruleId . ')'
endfunc

func! sparkling#RefreshCursor(filename)
  let currentFile = a:filename
  if has_key(s:mainDic, currentFile)
    let data = s:mainDic[currentFile]
    if has_key(data.lines, line('.'))
      let line_errors = get(data.lines, line('.'))
      let msg = sparkling#GetErrorMsg(line_errors[0])

      if len(line_errors) > 1
        let lastCol = col([line('.'), '$'])
        for err in line_errors[1:len(line_errors)]
          if col('.') >= err.column
            let msg = sparkling#GetErrorMsg(err)
            " Render end of line error at previous char
          elseif err.column == lastCol  && (col('.') + 1) == lastCol
            let msg = sparkling#GetErrorMsg(err)
          endif
        endfor
      endif
      echom 'sparkling: ' . msg
    else
      echom ''
    endif
  else
    echom ''
  endif
endfunc

func! sparkling#BuffSaveHook(filename)
  call sparkling#log('job start for ' . a:filename)
  let command = g:sparkling_eslint . ' ' . a:filename  . ' -f json'
  let job = job_start(command, {'close_cb': 'sparkling#CloseHandler'})
endfunc

func! sparkling#BufEnterHook(filename, type)
  call sparkling#log('reading '. a:type .' ' . a:filename)
  if has_key(s:mainDic, a:filename)
    let data = s:mainDic[a:filename]
    call sparkling#RenderEslint(data)
  else
    call sparkling#RemoveHighLight()
  endif
endfunc

