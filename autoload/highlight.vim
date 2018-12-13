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


function! highlight#MatchQuery()
	if !LineHasChanged()
		return 0
	endif

	let l:previousCursorPosition = getpos(".")
	let l:queryBoundaries = GetQueryBoundaries()
	let l:lineRange = range(l:queryBoundaries[0], l:queryBoundaries[1])

	call ClearMatching()

	for i in l:lineRange
		call matchaddpos(g:PSQLVIM_HLGROUP, [i])
	endfor
endfunction

function! highlight#ResetBufAndLineNb()
	call ClearMatching()
	g:psqlBufferNumber = -1
	g:psqlParagraphNumber = -1
endfunction


function! highlight#SelectCurrentQuery()
	let l:matches = getmatches()
	let l:query = ""

	for i in range(len(l:matches))
		let l:lineContent = getline(l:matches[i].pos1[0])
		if l:matches[i].group ==# highlight#GetHlGroup() && !empty(l:lineContent)
			let l:query = l:query . " " . l:lineContent
		endif
	endfor

	return l:query
endfunction
