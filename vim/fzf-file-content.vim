let s:searchOutputFilepath = '/tmp/file-content-search-output.txt'
let s:searchOutputOkFilepath = '/tmp/file-content-search-output-ok.txt'

let s:termBufferId = v:null
let s:termChandId = v:null

function s:InitializeSearchTerminal()
    if s:termBufferId != v:null && bufexists(s:termBufferId)
        return
    endif
    let fzfDefaultCommand =
        \ "fd" .
        \ " --type f" .
        \ '| xargs -d "\n"' .
        \ ' rg ""' .
        \ ' --field-match-separator=":\x7F"' .
        \ " --no-heading" .
        \ " --line-number"
    let fzfCommand =
        \ "FZF_DEFAULT_COMMAND='" . fzfDefaultCommand . "'" .
        \ GetSearchFzfCommonArgs(s:searchOutputFilepath, s:searchOutputOkFilepath) .
        \ ' --delimiter=":\x7F"' .
        \ ' --nth=3' .
        \ ""

    execute 'terminal ' . fzfCommand
    let s:termBufferId = bufnr('$')
    let s:termChandId = b:terminal_job_id
    file File Content Search
    setl nobuflisted noswapfile
    setl nonumber
    setl norelativenumber
    tnoremap <buffer> <enter> <cmd>call PopulateQuickFixWithFileContentSearch()<CR>
    noremap <buffer> <enter> <cmd>call PopulateQuickFixWithFileContentSearch()<CR>
endfunction


function PopulateQuickFixWithFileContentSearch()
    call FzfDumpSelectionToFile(s:termChandId)
    call FzfWaitForOkFile(s:searchOutputOkFilepath)

    stopinsert

    let files = systemlist('cat ' . s:searchOutputFilepath)
    let l:locationlist = []
    
    for l:line in files
        let components = split(l:line, ":\x7F")
        if len(components) != 3
            continue
        endif

        let [filePath, lineNum, text] = components
        let lnum = str2nr(lineNum)
        if lnum == 0
            continue
        endif
        
        call add(l:locationlist, #{
        \   filename: filePath,
        \   lnum: lnum,
        \   text: text,
        \   valid: 1
        \})
    endfor

    if len(l:locationlist) == 0
        return
    endif


    call setloclist(0, l:locationlist)
    echo 'Copied ' . len(l:locationlist) . ' items to the Location List'
    if len(l:locationlist) == 1
        lfirst
    endif
endfunction


function OpenFileContentSearch(shouldReset)
    call s:InitializeSearchTerminal()

    if a:shouldReset
        call FzfReloadSearchSource(s:termChandId)
    endif
    
    execute 'b ' . s:termBufferId
    startinsert
endfunction

noremap <space>r :call OpenFileContentSearch(0)<CR>
noremap <space>R :call OpenFileContentSearch(1)<CR>
