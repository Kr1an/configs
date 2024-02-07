function QuickPreview(toShow)
    let linesToShow = split(a:toShow, "\n")
    " close preview wiindow
    pclose
    " open and position new preview window
    topleft pedit Preview_2211
    let pbufnr = bufnr("Preview_2211")
    let pwinid = bufwinnr(pbufnr)
    let linewidth = winwidth(pwinid)
    let displayedLines = 0
    let maxLinesToShow = 8
    for line in linesToShow
        let displayedLines += max([1, float2nr(ceil((1.0 * len(line)) / linewidth))])
        if displayedLines >= maxLinesToShow
            break
        endif
    endfor
    let previewHeight = min([maxLinesToShow, float2nr(displayedLines)])
    execute(pwinid .. "resize " .. previewHeight)
    call setwinvar(pwinid, '&buflisted', 0)
    call setwinvar(pwinid, '&buftype', 'nofile')
    call setwinvar(pwinid, '&statusline', 'QuickPreview')
    call setwinvar(pwinid, '&swapfile', 0)
    call setwinvar(pwinid, '&number', 0)
    call setwinvar(pwinid, '&relativenumber', 0)
    call setwinvar(pwinid, '&wrap', 1)
    silent call deletebufline(pbufnr, 1, "$")
    call setbufline(pbufnr, 1, linesToShow)
    call setwinvar(pwinid, '&syntax', 'javascript')
    return
endfunction


function RemoveQuickPreview()
    autocmd! QuickPreviewCloseAugroup
    pclose
endfunction

function QuickPreviewOnBufEnter()
    if !&previewwindow
        call RemoveQuickPreview()
    endif
endfunction

function CreatePreviewCloseAugroup()
    augroup QuickPreviewCloseAugroup
        au!
        autocmd CompleteDone * call RemoveQuickPreview()
        autocmd CursorMoved <buffer> call RemoveQuickPreview()
        autocmd BufEnter * call QuickPreviewOnBufEnter()
    augroup END
endfunction
