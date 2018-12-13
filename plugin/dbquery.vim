let g:loaded_psqlvim=1
let g:psqlBufferNumber = -1
let g:psqlParagraphNumber = -1
let g:PSQLVIM_HLGROUP = "PsqlVim"

let s:PSQLVIM_FILEEXT = ".vimpsql.sql"

execute("highlight " . g:PSQLVIM_HLGROUP . " gui=bold cterm=bold")

augroup PsqlAu
	au!
	execute("autocmd CursorMoved *" . s:PSQLVIM_FILEEXT . " :call highlight#MatchQuery()")
	execute("autocmd InsertEnter *" . s:PSQLVIM_FILEEXT . " :call highlight#ResetBufAndLineNb()")
	execute("autocmd InsertLeave *" . s:PSQLVIM_FILEEXT . " :call highlight#MatchQuery()")
augroup end

function! OpenPSQL(...)
	let l:fileName=get(a:, 1, "/tmp/toto") . s:PSQLVIM_FILEEXT
	let l:openMode=get(a:, 2, ":tabnew")

	execute(l:openMode . " " . l:fileName)
endfunction

