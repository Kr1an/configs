" PLUG SECTION
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'airblade/vim-gitgutter'
Plug 'preservim/nerdtree'
Plug 'adelarsq/vim-matchit'
call plug#end()
" END OF PLUG SECTION


" CUSTOM MAPPINGS SECTION
" fzf mappings
map <space>r :call StartFzf(1)<enter>
map <space>f :call StartFzf(0)<enter>
" inc/dec number under cursor
noremap <buffer> <nowait> <LEADER>+ <C-a>
noremap <buffer> <nowait> <LEADER>- <C-x>
" exist terminal mode with escape key
tnoremap <Esc> <C-\><C-n>
" file explorer mappings
" for nerdtree
map <F2>          :call StartExplorer(1, 1)<enter>
map <LEADER><F2>  :call StartExplorer(1, 0)<enter>
" for bash explorer
map <F3>          :call StartExplorer(0, 1)<enter>
map <LEADER><F3>  :call StartExplorer(0, 0)<enter>
" END OF CUSTOM MAPPINGS SECTION



" STATUSLINE FORMATTING 
set statusline=\ \ 
set statusline+=%#StatusLine#%{GetStatusLineCWDPart()}%*
set statusline+=%#StatusLineNC#%{GetStatusLineFilePart()}%*
set statusline+=%m
set statusline+=%=
set statusline+=\ %y
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ 
function GetStatusLineCWDPart()
  let rawCwd = getcwd()
  let cwd = rawCwd
  if cwd[-1:] !=# '/'
    let cwd = cwd . '/'
  endif
  let filepath = expand('%:p')
  if len(filepath) == 0
    return cwd
  endif
  if len(filepath) < len(cwd)
    return '[!cwd] '
  endif
  if filepath[0:len(cwd)-1] !=# cwd
    return '[!cwd] '
  endif
  return cwd
endfunction
function GetStatusLineFilePart()
  let cwdPart = GetStatusLineCWDPart()
  let path = expand('%')
  if len(path) == 0
    return '[!file]'
  endif
  if cwdPart[:1] ==# '/'
    let path = path[1:]
  endif
  return path
endfunction
" END OF STATUSLINE FORMATTING





" FILE EXPLORER SECTION
function StartExplorer(isTree, isInCurFileDir)
  if a:isTree
    " use NERDTREE as explorer
    if a:isInCurFileDir
      " open current FILE directory 
      e %:h
    else
      " open project ROOT directory 
      e .
    endif
  else
    " use BASH as file explorer
    if a:isInCurFileDir
      " open current FILE directory 
      let curFileDir = fnameescape(expand("%:p:h"))
      echo curFileDir
      terminal
      " cd to cur dir
      let cdCmd = "cd " . curFileDir . "\<CR>"
      call feedkeys(cdCmd)
    else
      " open project ROOT directory 
      terminal
    endif
    au CursorMoved <buffer> if &buftype == 'terminal' | call SyncTerminalPath()
    "nnoremap <buffer> gf :call RunGFInsideTerminal()<enter>
    call MakeCurrentBufferInvisibleForEver()
    call feedkeys("ls\<CR>")
  endif
endfunction
function SyncTerminalPath()
  let markerForCurrentPWD = "__bash_explorer__"
  let terminalBufferNumber = bufnr()
  let info = getbufinfo(terminalBufferNumber)
  let title = info[0].variables.term_title
  let pwd = substitute(title, "^.*: ", "", "")
  let pathComponents = split(&path, ",")
  let markerIndex = index(pathComponents, markerForCurrentPWD)
  if markerIndex == -1
    let pathComponents += [markerForCurrentPWD, ""]
  endif
  let markerIndex = index(pathComponents, markerForCurrentPWD)
  if markerIndex == -1
    echoerr 'file explorer code can not find marker in &path'
  endif
  let pathComponents[markerIndex + 1] = expand(pwd)
  let &path = join(pathComponents, ",") . ","
endfunction
function RunGFInsideTerminal()
  let nodeUnderCursor = expand("<cfile>")
  echo nodeUnderCursor
  if filereadable(nodeUnderCursor)
    execute ":fin <cfile>"
  elseif isdirectory(nodeUnderCursor)
    startinsert
    call feedkeys("cd " . nodeUnderCursor . "\<CR>")
  endif
endfunction
" END OF FILE EXPLORER SECTION



" FZF SECTION
let g:fzfTmpFile = '/tmp/fzf-vim-result'
let g:rgCmd = 'rg --no-ignore --line-number --max-filesize 2M  .'
let g:fzfBindings = '
      \ --bind=\''ctrl-h:backward-word\''
      \ --bind=\''ctrl-l:forward-word\''
      \ --bind=\''ctrl-e:preview-page-down\''
      \ --bind=\''ctrl-y:preview-page-up\''
      \ --bind=\''ctrl-space:toggle-all\''
      \'
let g:fzfPreviewConfHidden = ' --preview-window="right:wrap:+{2}/3:hidden" '
let g:fzfPreviewConfRight = ' --preview-window="right:wrap:+{2}/3" '
let g:fzfPreviewConfTop = ' --preview-window="top:wrap:+{2}/3" '
let g:fzfPreviewWithBat = ' --preview \'' bat --style=numbers --color=always --highlight-line=$(l={2};l=${l:-1};echo $l) {1} \'' '
let g:fzfPreviewWithCat = ' --preview \'' cat --number {1} \'' '
function GenerateFzfCommand()
	let g:fzfPreviewConf = g:fzfPreviewConfRight
	if winwidth(0) < 120
		let g:fzfPreviewConf = g:fzfPreviewConfTop
		if winheight(0) < 20
			let g:fzfPreviewConf = g:fzfPreviewConfHidden
		endif
	endif
	let g:fzfPreview = g:fzfPreviewWithBat
	if !executable("bat")
		let g:fzfPreview = g:fzfPreviewWithCat
	endif
	let g:fzfCmd = 'fzf ' . g:fzfPreviewConf . g:fzfBindings . ' --multi --history=/tmp/fzf-history.txt  --delimiter=\'':\'' ' . g:fzfPreview
	return g:fzfCmd
endfunction
function StartFzf(withRg)
  call system('!rm -f ' . g:fzfTmpFile)
	if !executable("fzf")
		echoerr 'no fzf exec found'
		return
	endif
	let g:fzfCmd = GenerateFzfCommand()
	let g:cmd = g:fzfCmd
	if a:withRg
		if !executable("rg")
			echoerr 'no ripgrep exec found'
			throw l:output
			return
		endif
		let g:cmd = g:rgCmd . ' | ' . g:fzfCmd
	endif
	execute ' terminal bash -c $''' . g:cmd . '  '' > ' . g:fzfTmpFile
  call MakeCurrentBufferInvisibleForEver()
  autocmd TermClose <buffer> call WhenTermProcessFinished()
endfunction
function SetParamsForInvisBuffer()
  set nobuflisted noswapfile
endfunction
function MakeCurrentBufferInvisibleForEver()
  call SetParamsForInvisBuffer()
  autocmd BufEnter,BufLeave <buffer> call SetParamsForInvisBuffer()
endfunction
function WhenTermProcessFinished()
  let tmpFileLineList = readfile(g:fzfTmpFile)
  call system('!rm -f' . g:fzfTmpFile)
  let newQFValue = []
  for line in tmpFileLineList
    if line == ""
      break
    endif
    let lineComps = split(line, ":")
    let compAmount = len(lineComps)
    let qfEntry = {
        \ 'lnum': 1,
        \ 'text': lineComps[0],
        \ 'filename': lineComps[0],
        \ }
    if !filereadable(qfEntry.filename)
      return
    endif
    if compAmount >= 2
      let qfEntry.lnum = lineComps[1]
    endif
    if compAmount >= 3
      let qfEntry.text = lineComps[2]
    endif
    call extend(newQFValue, [qfEntry])
  endfor
  set modifiable
  execute ':e /tmp/' . fnameescape(strftime('%c')) 
  execute ':0r ' . g:fzfTmpFile
  execute ':w'
  call MakeCurrentBufferInvisibleForEver()
  if len(newQFValue)
    call setqflist(newQFValue)
  endif
endfunction
" END OF FZF SECTION




" COC CONFIGURATION
let g:coc_global_extensions = ['coc-json']
" TextEdit might fail if hidden is not set.
set hidden
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=1
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300
" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
" " Always show the signcolumn, otherwise it would shift the text each time
" " diagnostics appear/become resolved.
" if false && has("nvim-0.5.0") || has("patch-8.1.1564")
"   " Recently vim can merge signcolumn and number column into one
"   set signcolumn=number
" else
"   set signcolumn=yes
" endif
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" END OF COC CONFIGURATION





" OPTIONS SECTION
filetype plugin indent on
syntax on
colorscheme default
set fillchars=fold:\ ,vert:\│,eob:\ ,msgsep:‾
set encoding=utf-8
set background=dark
set timeoutlen=1000
set ttimeoutlen=0
set hlsearch
set incsearch
set norelativenumber
set nonumber
set hidden
set smartindent
set autoindent
set laststatus=2
set wildmenu
set wildmode=list:full
set tabstop=2
set expandtab
set shiftwidth=2
set directory=.
set nolist
set listchars=tab:>-,eol:\
set wrap
" include @ character to file path characters for gf/gF
set isfname+=@-@ 
" netrw section
let NERDTreeHijackNetrw=1
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1
if exists(":CocRestart")
  autocmd BufEnter *.svelte execute ":silent! CocRestart"
endif
if has('nvim')
  autocmd TermOpen term://* startinsert
endif
" END OF OPTIONS SECTION
