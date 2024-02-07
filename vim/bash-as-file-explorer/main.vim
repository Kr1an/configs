"""""""""""""""" BASH AS FILE EXPLORER""""""""""""""""

" This section adds keybinding to open terminal enchanced with some triks:
" - When cd to some directory, use gf/gF/<c-w>f/... to open file
"   under cursor. No global PWD manipulations.
" - The terminal is hidden from the visible buffers list(:ls).
" - The terminal is opened in current file directory. Ex:
"   if you are editing ~/test/text.txt, it will be
"   opened in ~/test/.
" - When opened, 'ls' command is issued automatically.
map <F3> :call StartBashAsFSExplorer()<enter>
function StartBashAsFSExplorer()
  let curFileDir = fnameescape(expand("%:p:h"))
  echo curFileDir
  terminal
  let cdCmd = "cd " . curFileDir . "\<CR>"
  call feedkeys(cdCmd)
  au CursorMoved <buffer> if &buftype == 'terminal' | call SyncTerminalPath()
  setl nobuflisted noswapfile nonumber norelativenumber
  autocmd BufEnter,BufLeave <buffer> setl nobuflisted noswapfile
  call feedkeys("ls\<CR>")
endfunction
function SyncTerminalPath()
  let terminalBufferNumber = bufnr()
  let info = getbufinfo(terminalBufferNumber)
  let title = info[0].variables.term_title
  let pwd = substitute(title, "^.*:", "", "")
  let pwd = substitute(pwd, "^\\s", "", "")
  let pwd = substitute(pwd, "[[:cntrl:]].*$", "", "g")
  let pwd = substitute(pwd, "\n.*$", "", "")
  let pwd = expand(pwd)
  if exists("g:SyncTerminalPwd__LastPathValue")
    exec "set path-=" . g:SyncTerminalPwd__LastPathValue
  endif
  let pathComponents = split(&path, ",")
  let newPathComponents = [pwd] + pathComponents
  let &path = join(newPathComponents, ",")
  let g:SyncTerminalPwd__LastPathValue = pwd
endfunction

autocmd TermOpen term://* startinsert

