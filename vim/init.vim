""" PLUG SECTION
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-surround'
" <M-p> to toggle
Plug 'jiangmiao/auto-pairs'
Plug 'nathanaelkane/vim-indent-guides'

Plug 'airblade/vim-gitgutter'

Plug 'gcmt/taboo.vim'

"" lsp 
Plug 'neovim/nvim-lspconfig'
  
Plug 'SirVer/ultisnips'

call plug#end()

command! VO :edit ~/.config/nvim/init.vim
command! LO :edit ~/.config/nvim/lua/init.lua
command! VS :source ~/.config/nvim/init.vim
command! BO :edit ~/.bashrc

""" END OF PLUG SECTION

"" dark
set background=dark
let minorInfoFgColor = 237
let minorInfoBgColor = 234
hi Pmenu ctermfg=254 ctermbg=245
hi PmenuSel ctermfg=254 ctermbg=242

"hi FloatBorder ctermfg=254 ctermbg=242
hi LspInfoBorder ctermfg=254 ctermbg=242

hi LspReferenceText ctermbg=244
hi LspReferenceRead ctermbg=240
hi LspReferenceWrite ctermbg=240
hi NormalFloat ctermbg=0

""" light
"set background=light
"let minorInfoFgColor = 210
"let minorInfoBgColor = 210
"hi Pmenu ctermfg=0 ctermbg=252
"hi PmenuSel ctermfg=0 ctermbg=249
"hi FloatBorder ctermfg=210 ctermbg=249
"hi link LspInfoBorder FloatBorder
"hi LspReferenceText ctermbg=214
"hi LspReferenceRead ctermbg=210
"hi LspReferenceWrite ctermbg=210

exe 'hi MinorInfoFg ctermfg=' . minorInfoFgColor . ' ctermbg=NONE'
exe 'hi MinorInfoBg ctermfg=NONE ctermbg=' . minorInfoBgColor
hi! link LineNr MinorInfoFg
hi! link SignColumn MinorInfoFg
hi! link LineNr MinorInfoFg
hi! link NonText MinorInfoFg
hi! link GitGutterAdd Normal
hi! link GitGutterChange Normal 
hi! link GitGutterDelete Normal 
hi! link ColorColumn MinorInfoBg
hi! link FoldColumn SignColumn
hi! link Folded LineNr
exe 'hi IndentGuidesOdd ctermfg=NONE ctermbg=' . minorInfoBgColor
exe 'hi IndentGuidesEven ctermfg=NONE ctermbg=' . (minorInfoBgColor + 1)
hi! link LspSignatureActiveParameter Search
"hi! link FloatBorder SpecialKey
hi! link LspInfoBorder SpecialKey

function TriggerHoverInPopUp()
  if &filetype =~ 'tf\|terraform'
    return
  endif
  lua vim.lsp.buf.hover()
endfunction
au CompleteChanged * call TriggerHoverInPopUp()
inoremap <c-space> <c-x><c-o>
nmap <C-p> :pop<CR>

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


"""""""""""""""""" OPTIONS SECTION""""""""""""""""""""""

"" This section sets various global options. 
filetype on
filetype plugin off
filetype indent off 
syntax on
" help scroll-horizontal: zl(->), zh(<-), zL(->halfscreen), ze, zs
set nowrap
set isfname+=@-@ nofixendofline foldcolumn=0
set hlsearch incsearch hidden relativenumber numberwidth=1 
set autoindent tabstop=4 expandtab shiftwidth=4
set wildmenu wildmode=list:full directory=.
set listchars=tab:\\x20\\x20,eol:\
set nolist
set updatetime=300
set notimeout
let g:editorconfig = v:false

set foldmethod=indent
set foldlevelstart=99
set foldminlines=2

"set completeopt=menu,menuone,longest,preview,noselect,noinsert
set completeopt=menu,menuone,longest
set omnifunc=v:lua.vim.lsp.omnifunc

""""""""""" Tab, windows shortcuts""""""""""""""""""""

tnoremap <Esc> <C-\><C-n>
nnoremap <C-s> <ESC>:w<CR>
inoremap <C-s> <ESC>:w<CR>
nnoremap <C-q> <ESC>:bd!<CR>
inoremap <C-q> <ESC>:bd!<CR>
nnoremap <C-t> <ESC>:$tabnew<CR>
nnoremap <M-=> :tabnext<CR>
inoremap <M-=> <C-o>:tabnext<CR>
nnoremap <M--> :tabprev<CR>
inoremap <M--> <C-o>:tabprev<CR>
nnoremap <M-1> 1gt
inoremap <M-1> <C-o>1gt
nnoremap <M-2> 2gt
inoremap <M-2> <C-o>2gt
nnoremap <M-3> 3gt
inoremap <M-3> <C-o>3gt
nnoremap <M-4> 4gt
inoremap <M-4> <C-o>4gt
nnoremap <M-5> 5gt
inoremap <M-5> <C-o>5gt
nnoremap <M-6> 6gt
inoremap <M-6> <C-o>6gt
nnoremap <M-7> 7gt
inoremap <M-7> <C-o>7gt
nnoremap <M-8> 8gt
inoremap <M-8> <C-o>8gt
nnoremap <M-9> 9gt
inoremap <M-9> <C-o>9gt
nnoremap <M-0> :tablast<CR>
inoremap <M-0> <C-o>:tablast<CR>
nnoremap <M-l> :call ToggleList()<CR>
inoremap <M-l> <C-o>:call ToggleList()<CR>
inoremap <M-w> <C-o>:set wrap!<CR>
nnoremap <M-w> :set wrap!<CR>

map <F5> <c-w>_<c-w><bar> 
map <c-w>t :tabnew %<CR>
nnoremap z. :let &foldlevel = max([indent('.') / &shiftwidth - 1, 0])<cr>
nnoremap z> zMzvzczO


""""""""""""""" Show/Hide all invisible characters

function ToggleList()
  let isVisible = &list
  if isVisible == 0
    echo "Show hidden chars"
    set list
    IndentGuidesEnable
    set cc=81
  else
    echo "Hide hidden chars"
    set nolist
    IndentGuidesDisable
    set cc=
  endif
endfunction


""""""""""""""""" Missing syntaxes""""""""""""

autocmd BufEnter *.Build.props :setlocal filetype=xml
autocmd BufEnter *.Build.targets :setlocal filetype=xml
autocmd BufEnter nlog.config :setlocal filetype=xml
autocmd BufEnter *.svelte execute ":set syntax=html"
autocmd BufEnter *.json execute ":set syntax="


""""""""""""""""""" Visible Indent Plugin configs"""""""""""""
   
let g:indent_guides_auto_colors = 0
let g:indent_guides_guide_size = 1

"""""""""""""""""" UltiSnippets configs""""""""

let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<m-j>"
let g:UltiSnipsJumpBackwardTrigger="<m-k>"
let g:UltiSnipsEditSplit="vertical"
let g:UltiSnipsSnippetDirectories=["UltiSnippets"]

"""""""""""""""""" Sealed secrets""""""""""""""

autocmd BufEnter * :set conceallevel=1
autocmd BufEnter * :set concealcursor=nvic
autocmd BufEnter * :syntax match SealedSecreats /\v(sec\()@<=.*(\)ret)@=/ conceal cchar=*


""""""""""""""" Git shortcuts/GitGutter config"""""""""""""""
map <space>gs :call OpenGitGutterHunkDiff()<enter>
function OpenGitGutterHunkDiff()
    let g:gitgutter_floating_window_options['border'] = 'single'
    GitGutterPreviewHunk
endfunction
map <space>gU :GitGutterUndoHunk<enter>
map <space>gn :GitGutterNextHunk<enter>
map <space>gp :GitGutterPrevHunk<enter>
map <space>gL :GitGutterQuickFix<enter>
map <space>gl :GitGutterQuickFixCurrentFile<enter>
map <space>gA :GitGutterStageHunk<enter>
map <space>gg :GitGutterToggle<enter>
map <space>gb :exec "!git blame % --date=human -L " . line(".") . ",+1"<enter>
call gitgutter#disable()
let g:gitgutter_map_keys = 0
let g:gitgutter_use_location_list = 0

"""""""""""""""" Quick/Location shortcuts""""""
map <space>co :copen<enter>
map <space>cc :cclose<enter>
map <space>cf :cfirst<enter>
map <space>cn :cnext<enter>
map <space>cp :cprev<enter>
map <space>cN :cnfile<enter>
map <space>cP :cpfile<enter>

map <space>lo :lopen<enter>
map <space>lc :lclose<enter>
map <space>lf :lfirst<enter>
map <space>ln :lnext<enter>
map <space>lp :lprev<enter>
map <space>lN :lnfile<enter>
map <space>lP :lpfile<enter>

"""""""""""""""""Diagnostic Shortcuts""""""""""""""""

map <space>dl :lua vim.diagnostic.setloclist({ open = false })<CR>
map <space>dL :lua vim.diagnostic.setqflist({ open = false })<CR>
map <space>ds :lua vim.diagnostic.open_float()<CR>
let g:DIAGNOSTIC_HIDDEN = 0
let g:DIAGNOSTIC_ERROR_ONLY = 1
let g:DIAGNOSTIC_ALL = 2
let g:DiagnosticSeverity = g:DIAGNOSTIC_ALL
function SetDiagnosticSeverigy(severity)
    let g:DiagnosticSeverity = a:severity
    if g:DiagnosticSeverity == g:DIAGNOSTIC_HIDDEN
        echo "Diagnostic disabled"
        lua vim.diagnostic.disable()
    elseif g:DiagnosticSeverity == g:DIAGNOSTIC_ERROR_ONLY
        echo "Diagnostic Severity is Error only"
        lua vim.diagnostic.enable()
        lua vim.diagnostic.config({
        \   virtual_text = { severity = { min = 1 } },
        \   underline = { severity = { min = 1 } },
        \   signs = { severity = { min = 1 } },
        \   float = { severity = { min = 1 }, border = "single" },
        \})
    else
        echo "Diagnostic Severity is All Errors/Warnings"
        lua vim.diagnostic.enable()
        lua vim.diagnostic.config({
        \   virtual_text = { severity = { max = 1 } },
        \   underline = { severity = { max = 1 } },
        \   signs = { severity = { max = 1 } },
        \   float = { severity = { max = 1 }, border = "single" },
        \})
    endif
endfunction
silent call SetDiagnosticSeverigy(g:DIAGNOSTIC_ALL)
map <space>dn :lua vim.diagnostic.goto_next()<CR>
map <space>dp :lua vim.diagnostic.goto_prev()<CR>
map <space>d0 :call SetDiagnosticSeverigy(g:DIAGNOSTIC_HIDDEN)<CR>
map <space>d1 :call SetDiagnosticSeverigy(g:DIAGNOSTIC_ERROR_ONLY)<CR>
map <space>d2 :call SetDiagnosticSeverigy(g:DIAGNOSTIC_ALL)<CR>



"""""""""""""""" AutoPair Plugin config""""""""""""
let g:autopairs_enabled = 1
" configure autopairs on new buffer enter
autocmd BufEnter * let b:autopairs_enabled = g:autopairs_enabled
function ToggleAutoPairPlugin()
    " toggle autopairs on all buffers
    let bufNr = bufnr()
    let g:autopairs_enabled = !g:autopairs_enabled
    bufdo let b:autopairs_enabled = !g:autopairs_enabled
    execute 'b ' . bufNr
endfunction
let g:AutoPairsMapCR = 0
let g:AutoPairsCenterLine = 0
let g:AutoPairsMultilineClose = 0
let g:AutoPairsShortcutToggle = ''
nmap <m-p> :call ToggleAutoPairPlugin()<enter>
imap <m-p> <c-o>:call ToggleAutoPairPlugin()<enter>


""""""""" Statusline config"""""""
function RecalculateStatusLine()
    let &statusline = &statusline
endfunction
let &laststatus = 2
let &statusline = "%f %m%r%h%w%=%l,%c  %p%% " .
    \ "%{g:autopairs_enabled ? '() ' : '( '}" .
    \ "%{g:gitgutter_enabled ? 'git ' : ''}"

""""""""""" Taboo plugin config"""""""

let g:taboo_tab_format = " %f%I "

"""""""""""""""""""""""""""""""""

"" run ts-node with debugger
"" nodemon --exec "node --inspect --require ts-node/register download-all-annual-reports.ts"
"" node --inspect -r ts-node/register/transpile-only index.ts

" gpg commands:
" decrypt from vim:
" :r !gpg -d ~/path/to/encrypted/file
" encrypt from vim:
" :w !gpg -o ~/save/to/file -c


lua package.path = package.path .. ";" .. vim.fn.expand('<sfile>:p:h') .. "/?.lua"
lua require('junk')
lua require('lsp.quick-preview')
execute('source ' . expand('<sfile>:p:h') . '/fzf/fzf-file-path.vim')
execute('source ' . expand('<sfile>:p:h') . '/fzf/fzf-file-content.vim')
execute('source ' . expand('<sfile>:p:h') . '/lsp/quick-preview.vim')
