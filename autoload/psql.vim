let s:PSQLVIM_FILETYPE = "psql"
let s:PSQLVIM_SCRIPT_PATH = expand("<sfile>:p:h")

function! RunCurrentQuery()
	let l:query = highlight#SelectCurrentQuery()
	let g:psqlvimQueryResult = []

	execute("python3 sys.argv = ['" . l:query . "']")
	execute("py3file " . s:PSQLVIM_SCRIPT_PATH . "/../lib/vim_psql.py")

	new
	for rowNb in range(len(g:psqlvimQueryResult))
		put =join(g:psqlvimQueryResult[l:rowNb])
	endfor
	:1
	:delete p
	:setlocal buftype=nofile bufhidden=wipe nomodifiable nobuflisted noswapfile nowrap

	return l:query
endfunction
