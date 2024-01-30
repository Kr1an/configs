let s:searchOutputFilepath = '/tmp/filepath-search-output.txt'
let s:searchOutputOkFilepath = '/tmp/filepath-search-output-ok.txt'

let s:termBufferId = v:null
let s:termChandId = v:null

function s:InitializeSearchTerminal()
    if s:termBufferId != v:null && bufexists(s:termBufferId)
        return
    endif
    let fzfCommand =
        \ 'FZF_DEFAULT_COMMAND="fd --type f"' .
        \ GetSearchFzfCommonArgs(s:searchOutputFilepath, s:searchOutputOkFilepath)

    execute 'terminal ' . fzfCommand
    let s:termBufferId = bufnr('$')
    let s:termChandId = b:terminal_job_id
    file Filepath Search
    setl nobuflisted noswapfile
    setl nonumber
    setl norelativenumber
    tnoremap <buffer> <enter> <cmd>call PopulateQuickFixWithFilepathSearch()<CR>
    noremap <buffer> <enter> <cmd>call PopulateQuickFixWithFilepathSearch()<CR>
endfunction

function GetSearchFzfCommonArgs(outputFile, okFile)
    return
        \ " fzf" .
        \ " --multi" .
        \ " --reverse" .
        \
        \ " --bind 'tab:toggle'" .
        \ " --bind 'ctrl-a:toggle-all'" .
        \
        \ " --bind 'ctrl-d:half-page-down'" .
        \ " --bind 'ctrl-f:page-down'" .
        \ " --bind 'ctrl-u:half-page-up'" .
        \ " --bind 'ctrl-b:page-up'" .
        \
        \ " --bind 'ctrl-r:reload(eval \"$FZF_DEFAULT_COMMAND\")+change-query()'" .
        \ " --bind 'ctrl-p:execute(" .
        \       "rm -f " . a:outputFile . ";" .
        \       "rm -f " . a:okFile. ";" .
        \       'for l in {+}; do echo "$l"  >> ' . a:outputFile . "; done;" .
        \       "touch " . a:okFile . ";" .
        \   ")'" .
        \
        \ " --bind 'ctrl-c:execute()'" .
        \ " --bind 'shift-tab:execute()'" .
        \ " --bind 'enter:execute()'" .
        \ ""
endfunction

function FzfReloadSearchSource(chandId)
    call chansend(a:chandId, "\<c-r>")
endfunction

function FzfDumpSelectionToFile(chandId)
    call chansend(a:chandId, "\<c-p>")
endfunction

function PopulateQuickFixWithFilepathSearch()
    call FzfDumpSelectionToFile(s:termChandId)
    call FzfWaitForOkFile(s:searchOutputOkFilepath)

    stopinsert

    let l:files = systemlist('cat ' . s:searchOutputFilepath)
    let l:locationlist = []
    
    for l:line in l:files
        call add(l:locationlist, #{
        \   filename: l:line,
        \   valid: 1
        \})
    endfor

    call setloclist(0, l:locationlist)
    echo 'Copied ' . len(l:locationlist) . ' items to the Location List'

    if len(l:locationlist) == 1
        lfirst
    endif
endfunction


function OpenFilepathSearch(shouldReset)
    call s:InitializeSearchTerminal()

    if a:shouldReset
        call FzfReloadSearchSource(s:termChandId)
    endif
    
    execute 'b ' . s:termBufferId
    startinsert
endfunction

function FzfWaitForOkFile(okFile)
    let maxWait = 0.3
    let step = 0.05
    let start = reltimefloat(reltime())

    while v:true
        let isOkFileExist = system(
        \    "test -f " . a:okFile . " && echo 1 || echo 0"
        \)
        if isOkFileExist
            return v:true
        endif
        let now = reltimefloat(reltime()) 
        let elapsed = now - start
        if elapsed > maxWait
            return v:false
        endif
        execute 'sleep ' . float2nr(step * 1000) . 'm'
    endwhile
    return v:true
endfunction

noremap <space>f :call OpenFilepathSearch(0)<CR>
noremap <space>F :call OpenFilepathSearch(1)<CR>
