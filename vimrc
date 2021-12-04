" PLUG SECTION
call plug#begin('~/.vim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'airblade/vim-gitgutter'
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




" BASH AS FILE EXPLORER
map <F3> :call StartBashAsFSExplorer()<enter>
function StartBashAsFSExplorer()
  let curFileDir = fnameescape(expand("%:p:h"))
  echo curFileDir
  terminal
  let cdCmd = "cd " . curFileDir . "\<CR>"
  call feedkeys(cdCmd)
  au CursorMoved <buffer> if &buftype == 'terminal' | call SyncTerminalPath()
  call MakeCurrentBufferInvisibleForEver()
  call feedkeys("ls\<CR>")
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
  let pathComponents[markerIndex + 1] = expand(pwd)
  let &path = join(pathComponents, ",") . ","
endfunction
" END OF BASH AS FILE EXPLORER



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
set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=300
set shortmess+=c
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
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
autocmd CursorHold * silent call CocActionAsync('highlight')
nmap <leader>rn <Plug>(coc-rename)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction)
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
