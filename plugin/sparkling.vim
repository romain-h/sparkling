" Vim sparkling
" Author:   Romain Hardy <romain.hardy17 AT gmail DOT com>

" Do not load Vim < v8 or no `job_start`
if (v:version == 800 && !exists('*job_start')) || (v:version < 800)
  call sparkling#logError('Vim >=800 with job_start is required')
  finish
endif

if !exists('g:sparkling_debug')
  let g:sparkling_debug = 0
end

" Detect local eslint from local npm package. Fallback on global package
let localEslintPath = StrTrim(system('npm bin')) . '/eslint'
if filereadable(localEslintPath)
  call sparkling#log('using local bin: '. localEslintPath)
  let g:sparkling_eslint = localEslintPath
elseif filereadable(StrTrim(system('which eslint')))
  call sparkling#log('using global eslint bin')
  let g:sparkling_eslint = localEslintPath
else
  call sparkling#logError('Eslint package not found')
  finish
endif

if exists('g:loaded_sparkling') || &cp
  finish
endif
let g:loaded_sparkling = 1

if !hlexists('SparklingError')
  highlight link SparklingError SpellBad
endif
if !hlexists('SparklingWarning')
  highlight link SparklingWarning SpellCap
endif
if !hlexists('SparklingErrorSign')
  highlight link SparklingErrorSign error
endif
if !hlexists('SparklingWarningSign')
  highlight link SparklingWarningSign todo
endif
if !hlexists('SparklingStyleErrorLine')
  highlight link SparklingStyleErrorLine SparklingErrorLine
endif
if !hlexists('SparklingStyleWarningLine')
  highlight link SparklingStyleWarningLine SparklingWarningLine
endif

execute 'sign define SparklingError text=> texthl=SparklingErrorSign linehl=SparklingErrorLine'
execute 'sign define SparklingWarning text=> texthl=SparklingWarningSign linehl=SparklingWarningLine'

" Auto commands
augroup sparkling
  autocmd!
  autocmd! BufWritePost *.js call sparkling#BuffSaveHook(expand('%:p'))
  autocmd! BufEnter * call sparkling#BufEnterHook(expand('%:p'), 'BufEnter')
  autocmd! CursorMoved *.js call sparkling#RefreshCursor(expand('%:p'))
augroup END

function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction
