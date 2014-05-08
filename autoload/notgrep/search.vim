" Not grep, but something similar.
"
" Search and core plugin implementation.

function! notgrep#search#NotGrep(cmd, args)
    redraw
    echo "Searching ..."

    " If no pattern is provided, search for the word under the cursor
    if empty(a:args)
        let l:grepargs = expand("<cword>")
    else
        let l:grepargs = a:args
    end

    " Format, used to manage column jump
    if a:cmd =~# '-g$'
        let l:grepformat = "%f"
    else
        let l:grepformat = g:notgrep_efm
    end

    let grepprg_bak = &grepprg
    let grepformat_bak = &grepformat
    try
        let &grepprg = g:notgrep_prg
        let &grepformat = l:grepformat
        silent execute a:cmd . " " . l:grepargs
    finally
        let &grepprg = grepprg_bak
        let &grepformat = grepformat_bak
    endtry

    if a:cmd =~# '^l'
        botright lopen
    else
        botright copen
    endif

    if !exists("g:notgrep_no_mappings") || !g:notgrep_no_mappings
        exec "nnoremap <silent> <buffer> q :ccl<CR>"
        exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
        exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
        exec "nnoremap <silent> <buffer> o <CR>"
        exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
        exec "nnoremap <silent> <buffer> v <C-W><C-W><C-W>v<C-L><C-W><C-J><CR>"
        exec "nnoremap <silent> <buffer> gv <C-W><C-W><C-W>v<C-L><C-W><C-J><CR><C-W><C-J>"
    endif


    " If highlighting is on, highlight the search keyword.
    if exists("g:notgrep_highlight")
        let @/=notgrep#search#ConvertRegexPerlToVim(a:args)
        set hlsearch
    end

    redraw!
endfunction

function! notgrep#search#ConvertRegexVimToPerl(vim_regex)
    " Translate vim regular expression to perl regular expression (what grep
    " uses).
    let search = a:vim_regex
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    let search = substitute(search,'\\V','','g')
    "let search = substitute(search,'\\c','(?i)','g')
    "let search = substitute(search,'\\C','(?-i)','g')
    return search
endfunction

function! notgrep#search#ConvertRegexPerlToVim(perl_regex)
    " Translate perl regular expression to vim regular expression.
    let search = a:perl_regex
    let search = substitute(search,'\\b','','g')
    "let search = substitute(search,'(?i)','\\c','g')
    "let search = substitute(search,'(?-i)','\\C','g')
    return search
endfunction

function! notgrep#search#NotGrepFromSearch(cmd, args)
    let vim_search = getreg('/')
    let search = notgrep#search#ConvertRegexVimToPerl(vim_search)
    call notgrep#search#NotGrep(a:cmd, '"' . search .'" '. a:args)

    " The conversion is lossy, so keep our original query.
    let @/=vim_search
endfunction

" vi: et sw=4 ts=4
