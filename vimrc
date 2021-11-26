" PLUG SECTION
call plug#begin('~/.vim/plugged')
Plug 'flazz/vim-colorschemes'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'airblade/vim-gitgutter'
call plug#end()
" END OF PLUG SECTION






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



" FZF SECTION
let g:rgCmd = 'rg --no-ignore --line-number --max-filesize 2M  .'
let g:fzfBindings = ' --bind=\''ctrl-n:preview-page-down\'' --bind=\''ctrl-u:preview-page-up\'' '
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
	let g:fzfCmd = 'fzf ' . g:fzfPreviewConf . g:fzfBindings . '  --delimiter=\'':\'' ' . g:fzfPreview
	return g:fzfCmd
endfunction
function StartFzf(withRg)
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
	execute ' terminal bash -c $''' . g:cmd . '  '' '
endfunction
map <space>r :call StartFzf(1)<enter>
map <space>f :call StartFzf(0)<enter>
" END OF FZF SECTION




" COC CONFIGURATION
let g:coc_global_extensions = ['coc-json']
" TextEdit might fail if hidden is not set.
set hidden
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup
" Give more space for displaying messages.
set cmdheight=2
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
colorscheme 1989
set encoding=utf-8
set background=light
set timeoutlen=1000
set ttimeoutlen=0
set hlsearch
set incsearch
set relativenumber
set number
set hidden
set smartindent
set autoindent
set laststatus=2
set wildmenu
set wildmode=list:full
set tabstop=2
let g:netrw_keepj=""
set expandtab
set shiftwidth=2
set directory=.
set nolist
set listchars=tab:>-,eol:\
set wrap
map <C-n> :Explore<CR>
" include @ character to file path characters for gf/gF
set isfname+=@-@ 
let g:netrw_banner = 0
" inc/dec number under cursor
noremap <buffer> <nowait> <LEADER>+ <C-a>
noremap <buffer> <nowait> <LEADER>- <C-x>
" exist terminal mode with escape key
tnoremap <Esc> <C-\><C-n>
if exists(":CocRestart")
  autocmd BufEnter *.svelte execute ":silent! CocRestart"
endif
if has('nvim')
  autocmd TermOpen term://* startinsert
endif
" END OF OPTIONS SECTION
