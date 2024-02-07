function TriggerHoverInPopUp()
  if &filetype =~ 'tf\|terraform'
    return
  endif
  lua vim.lsp.buf.hover()
endfunction

au CompleteChanged * call TriggerHoverInPopUp()

inoremap <c-space> <c-x><c-o>
