let s:PSQLVIM_FILETYPE = "psql"
let s:PSQLVIM_FILEEXT = ".vimpsql.sql"
let s:PSQLVIM_HLGROUP = "PsqlVim"
let s:PSQLVIM_SCRIPT_PATH = expand("<sfile>:p:h")

let g:psqlBufferNumber = -1
let g:psqlParagraphNumber = -1

execute("highlight " . s:PSQLVIM_HLGROUP . " gui=bold cterm=bold")

function! ClearMatching()
	"Fast and ugly way to delete PsqlVim matches
	call clearmatches()
endfunction

function! GetQueryStart()
	return line("'{")
endfunction

function! GetQueryEnd(queryStartLineNb)
	:set eventignore=all
	let l:savedPosition = getpos(".")

	normal {

	let l:queryEndLineNb = line("'}")

	call setpos(".", l:savedPosition)

	:set eventignore=""

	return l:queryEndLineNb
endfunction


function! GetQueryBoundaries()
	let l:queryStart = GetQueryStart()
	let l:queryEnd = GetQueryEnd(l:queryStart)

	return [l:queryStart, l:queryEnd]
endfunction

function! LineHasChanged()
	let l:currentBufferNumber=bufnr("%")
	let l:currentParagraphNumber=line("'{")

	if l:currentBufferNumber == g:psqlBufferNumber && l:currentParagraphNumber == g:psqlParagraphNumber
		return 0
	endif

	let g:psqlBufferNumber = l:currentBufferNumber
	let g:psqlParagraphNumber = l:currentParagraphNumber
	return 1
endfunction

function! MatchQuery()
	if !LineHasChanged()
		return 0
	endif

	let l:previousCursorPosition = getpos(".")
	let l:queryBoundaries = GetQueryBoundaries()
	let l:lineRange = range(l:queryBoundaries[0], l:queryBoundaries[1])

	call ClearMatching()

	for i in l:lineRange
		call matchaddpos(s:PSQLVIM_HLGROUP, [i])
	endfor
endfunction

function! ResetBufAndLineNb()
	call ClearMatching()
	g:psqlBufferNumber = -1
	g:psqlParagraphNumber = -1
endfunction

function! OpenPSQL(...)
	let l:fileName=get(a:, 1, "/tmp/toto") . s:PSQLVIM_FILEEXT
	let l:openMode=get(a:, 2, ":tabnew")

	execute(l:openMode . " " . l:fileName)
endfunction

augroup PsqlAu
	au!
	execute("autocmd CursorMoved *" . s:PSQLVIM_FILEEXT . " :call MatchQuery()")
	execute("autocmd InsertEnter *" . s:PSQLVIM_FILEEXT . " :call ResetBufAndLineNb()")
	execute("autocmd InsertLeave *" . s:PSQLVIM_FILEEXT . " :call MatchQuery()")
augroup end

function! Highlight()
	:py3file "../lib/highlight.py"
endfunction

function! SelectCurrentQuery()
	let l:matches = getmatches()
	let l:query = ""

	for i in range(len(l:matches))
		let l:lineContent = getline(l:matches[i].pos1[0])
		if l:matches[i].group ==# s:PSQLVIM_HLGROUP && !empty(l:lineContent)
			let l:query = l:query . " " . l:lineContent
		endif
	endfor

	if l:query[len(l:query) - 1] != ';'
		let l:query = l:query . ';'
	endif

	return l:query
endfunction

function! RunCurrentQuery()
	let l:query = SelectCurrentQuery()

	execute("python3 sys.argv = ['" . l:query . "']")
	execute("py3file " . s:PSQLVIM_SCRIPT_PATH . "/../lib/vim_psql.py")

	return l:query
endfunction
