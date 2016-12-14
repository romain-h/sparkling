" Vim sparkling
" Author:   Romain Hardy <romain.hardy17 AT gmail DOT com>

" Do not load Vim < v8 or no `job_start`
if (v:version == 800 && !exists('*job_start')) || (v:version < 800)
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
  autocmd! BufWritePost *.js call sparkling#CheckSyntaxOnSave()
  autocmd! CursorMoved * call sparkling#RefreshCursor()
augroup END
