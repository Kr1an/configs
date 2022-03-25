""" PLUG SECTION
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'
Plug 'pangloss/vim-javascript'
Plug 'tomlion/vim-solidity'
call plug#end()
""" END OF PLUG SECTION



""" BASH AS FILE EXPLORER
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
  set nobuflisted noswapfile
  autocmd BufEnter,BufLeave <buffer> set nobuflisted noswapfile
  call feedkeys("ls\<CR>")
endfunction
function SyncTerminalPath()
  let markerForCurrentPWD = "__bash_explorer__"
  let terminalBufferNumber = bufnr()
  let info = getbufinfo(terminalBufferNumber)
  let title = info[0].variables.term_title
  let pwd = substitute(title, "^.*:", "", "")
  let pwd = substitute(pwd, "^\\s", "", "")
  let pathComponents = split(&path, ",")
  let markerIndex = index(pathComponents, markerForCurrentPWD)
  if markerIndex == -1
    let pathComponents += [markerForCurrentPWD, ""]
  endif
  let markerIndex = index(pathComponents, markerForCurrentPWD)
  let pathComponents[markerIndex + 1] = expand(pwd)
  let &path = join(pathComponents, ",") . ","
endfunction
""" END OF BASH AS FILE EXPLORER




""" FZF SECTION
" - system package requirenments: [ripgrep, fzf, bat]
" This section provides keybindings to work with bash tools: fzf/rg.
" The idea is to open these tools inside the terminal in the buffer
" and add some logic to iterract with these commands. 
" 
" - Preview window is opened based on current terminal size. If the
"   terminal size is small, than the preview window will try to fit
"   of will be hidden completly.
" - Multiselection is enabled in fzf with <Shift><Tab> keybindings.
" - The terminal is invisible in ls.
" - When fzf program returned some result, based on that result various
"   resolutions exists:
"   - If single file was selected, than this file will be opened.
"   - If multiple files are selected, than qf list will be filled.
"   - If no file selected, simple wipe The terminal and go back to previously
"   opened buffer.
map <space>r :call StartFzf(1)<enter>
map <space>f :call StartFzf(0)<enter>
let g:fzfTmpFile = '/tmp/fzf-vim-result'
let g:rgCmd = 'rg --line-number --max-filesize 2M .'
let g:fzfBindings = ' --bind=\''ctrl-r:backward-word\'' --bind=\''ctrl-t:forward-word\'' --bind=\''ctrl-e:preview-page-down\'' --bind=\''ctrl-y:preview-page-up\'' --bind=\''ctrl-space:toggle-all\'' '
function GenerateFzfCommand()
  let l:smallH = winwidth(0) < 120
  let l:smallV = winheight(0) < 20
  let g:fzfPreviewConf = ' --preview-window="' . (l:smallH ? 'top' : 'right') . ':wrap:+{2}/3' . (l:smallV && l:smallH ? ':hidden' : '') . '" '
  let g:fzfPreview = ' --preview \'' bat --style=numbers --color=always --highlight-line=$(l={2};l=${l:-1};echo $l) {1} \'' '
  let g:fzfCmd = 'fzf ' . g:fzfPreviewConf . g:fzfBindings . '--algo=v1 --multi --history=/tmp/fzf-history.txt  --delimiter=\'':\'' --nth=1,3,.. ' . g:fzfPreview
  return g:fzfCmd
endfunction
function StartFzf(withRg)
  if (a:withRg && !executable("rg")) || !executable("fzf") || !executable("bat") | echoerr 'no deps required deps installed' | throw l:output | return | endif
  call system('!rm -f ' . g:fzfTmpFile)
  let g:fzfCmd = GenerateFzfCommand()
  let g:cmd = g:fzfCmd
  if a:withRg | let g:cmd = g:rgCmd . ' | ' . g:fzfCmd | endif
  execute ' terminal bash -c $''' . g:cmd . '  '' > ' . g:fzfTmpFile
  autocmd TermClose <buffer> ++nested execute ':call WhenTermProcessFinished()'
  set nobuflisted noswapfile
  autocmd BufEnter,BufLeave <buffer> set nobuflisted noswapfile
endfunction
function WhenTermProcessFinished()
  let tmpFileLineList = readfile(g:fzfTmpFile)
  call system('!rm -f' . g:fzfTmpFile)
  let newQFValue = []
  for line in tmpFileLineList
    if line == "" | break | endif
    let lineComps = split(line, ":")
    let compAmount = len(lineComps)
    let qfEntry = {'lnum':1,'text':lineComps[0],'filename':lineComps[0]}
    if !filereadable(qfEntry.filename) | return | endif
    if compAmount > 1 | let qfEntry.lnum = lineComps[1] | endif
    if compAmount > 2 | let qfEntry.text = lineComps[2] | endif
    call extend(newQFValue, [qfEntry])
  endfor
  set modifiable 
  let l:curBufNum = bufnr('%')
  exe ':silent! bprevious'
  exe ':silent! bwipeout! ' . l:curBufNum
  if len(newQFValue) == 0 | return
  elseif len(newQFValue) == 1 | exe ':e ' . newQFValue[0].filename . (newQFValue[0].lnum  ? '| :' . newQFValue[0].lnum : '')
  else | call setqflist(newQFValue) | exe ':cfirst'
  endif
endfunction
""" END OF FZF SECTION



""" GIT BLAME PLUGIN SECTION
" Show last commit message of current line
let g:gitBlamePluginEnabled = 1
let g:gitBlameNSId = nvim_create_namespace('git blame plugin')
let g:gitBlameMarkId = 873
function DisableGitBlame()
    if exists('#GitBlame#CursorHold')
        autocmd! GitBlame CursorHold *
        autocmd! GitBlame CursorHoldI *
    endif
    call nvim_buf_del_extmark(bufnr('%'), g:gitBlameNSId, g:gitBlameMarkId)
endfunction
function EnableGitBlame()
    call DisableGitBlame()
    augroup GitBlame 
        autocmd CursorHold * call DisplayGitBlame()
        autocmd CursorHoldI * call DisplayGitBlame()
    augroup END
endfunction
function ToggleGitBlame()
    if exists('#GitBlame#CursorHold')
        call DisableGitBlame()
    else
        call EnableGitBlame()
    endif
endfunction
if g:gitBlamePluginEnabled
    call EnableGitBlame()
else
    call DisableGitBlame()
endif
function DisplayGitBlame()
    let curBufPath = expand('%:p')
    if
        \ &buftype ==# 'terminal' ||
        \ !filereadable(curBufPath) ||
        \ getbufinfo('%')[0].changed
        return RemoveGitBlameMark()
    endif
    let gitDirPath = trim(system('cd ' . expand('%:p:h') . ' && ' . 'git rev-parse --absolute-git-dir'))
    if v:shell_error != 0
        return RemoveGitBlameMark()
    endif
    let curLine = line('.')
    let gitBlameCmd = 'git --git-dir=' . gitDirPath . ' blame --porcelain -L ' . curLine . ',' . curLine . ' ' . curBufPath
    let result = systemlist(gitBlameCmd)
    if v:shell_error != 0
        return RemoveGitBlameMark()
    endif
    let commitHash = result[0][0:4]
    let author = substitute(result[1], 'author ', '', '')[0:10]
    let msg = substitute(result[9], 'summary ', '', '')[0:15]
    let time = substitute(result[3], 'author-time ', '', '')
    let dateTimeStr = trim(system('date -d @' . time . ' +%e.%m.%g'))
    let textToDisplay = dateTimeStr . '|' . author . '|' . msg . '(' . commitHash . ')'
    call RemoveGitBlameMark()
    let opts = { 'id': g:gitBlameMarkId, 'virt_text': [[textToDisplay, "LineNrBelow"]] }
    call nvim_buf_set_extmark(bufnr('%'), g:gitBlameNSId, curLine-1, -1, opts)
endfunction
function RemoveGitBlameMark()
    call nvim_buf_del_extmark(bufnr('%'), g:gitBlameNSId, g:gitBlameMarkId)
endfunction
""" End of git blame plugin



""" COC CONFIGURATION
" This section sets some of the mappings from coc.nvim extension
" https://github.com/neoclide/coc.nvim
let g:coc_global_extensions = ['coc-json', 'coc-tsserver', 'coc-omnisharp']
set updatetime=300
set shortmess+=c
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
inoremap <silent><expr> <c-space> coc#refresh()
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm(): "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>
autocmd CursorHold * silent call CocActionAsync('highlight')
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
""" END OF COC CONFIGURATION





""" OPTIONS SECTION
" This section sets various global options. 
filetype on
filetype plugin on
filetype indent off
syntax on
set wrap isfname+=@-@ nofixendofline foldcolumn=auto
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾ encoding=utf-8
set hlsearch incsearch relativenumber number hidden
set autoindent tabstop=4 expandtab shiftwidth=4 
set laststatus=2 wildmenu wildmode=list:full directory=. listchars=tab:>-,eol:\
set list
autocmd BufEnter *.svelte execute ":set syntax=html"
"if exists(":CocRestart")
"  autocmd BufEnter *.svelte execute ":silent! CocRestart"
"endif
autocmd TermOpen term://* startinsert
tnoremap <Esc> <C-\><C-n>
noremap <nowait> <LEADER>+ <C-a>
noremap <nowait> <LEADER>- <C-x>
augroup remember_folds
  autocmd!
  au BufWinLeave ?* silent! mkview 1
  au BufWinEnter ?* silent! loadview 1
augroup END
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
"nmap <C-p> :pop<CR>
""" END OF OPTIONS



""" COLORS
" This section configures color theme.
" Its base on dark background and set black background as well.
" - system requirenments: [xterm-256-colors] should be enabled.
colorscheme default
set background=dark
hi Normal ctermfg=15 ctermbg=16
hi Pmenu ctermfg=254 ctermbg=238
hi PmenuSel ctermfg=254 ctermbg=242
hi SignColumn ctermbg=232
hi CocErrorSign ctermfg=203
hi NonText ctermfg=236
let lineNrBackground = 232
let lineNrExtra = 240
exe 'hi LineNr ctermfg=244 ctermbg=' . lineNrBackground
exe 'hi LineNrAbove ctermfg=' . lineNrExtra . ' ctermbg=' . lineNrBackground
exe 'hi LineNrBelow ctermfg=' . lineNrExtra . ' ctermbg=' . lineNrBackground
hi Constant ctermfg=144
""" END OF COLORS



