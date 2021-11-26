" PLUG EXTENSIONS
call plug#begin('~/.vim/plugged')
"Plug 'rafi/awesome-vim-colorschemes'
"Plug 'scrooloose/nerdtree'
"Plug 'w0rp/ale'
"
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"Plug 'dracula/vim'
"Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
"Plug 'junegunn/fzf.vim'
"Plug 'evanleck/vim-svelte', {'branch': 'main'}
Plug 'leafOfTree/vim-svelte-plugin'
Plug 'airblade/vim-gitgutter'

"Plug 'evanleck/vim-svelte'
"Plug 'pangloss/vim-javascript'
"Plug 'coc-extensions/coc-svelte'
" Plug 'Valloric/YouCompleteMe'
" Plug 'cakebaker/scss-syntax.vim'
" Plug 'Quramy/tsuquyomi'
" Plug 'leafgarland/typescript-vim'
" Plug 'Quramy/vim-js-pretty-template'
" Plug 'scrooloose/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'nathanaelkane/vim-indent-guides'
" Plug 'alvan/vim-closetag'
" Plug 'digitaltoad/vim-pug'
" Plug 'groenewege/vim-less'
" Plug 'StanAngeloff/php.vim'
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'
" Plug 'evanleck/vim-svelte'
" Plug 'pangloss/vim-javascript'
" Plug 'dense-analysis/ale'
call plug#end()
" END OF PLUG EXTENSIONS


"" Only run linters named in ale_linters settings.
"let g:ale_linters_explicit = 1
"let g:ale_completion_enabled = 1
"set omnifunc=ale#completion#OmniFunc
"let g:ale_completion_autoimport = 1
"let g:ale_linters = {
"\ 'javascript': ['tsserver']
"\}


" BASIC SETTINGS
filetype plugin indent on
syntax on
colorscheme default
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

"set expandtab
set noexpandtab

set shiftwidth=2
set directory=.

"set list
set nolist

set listchars=tab:>-,eol:\
set wrap
" include @ character to file path characters for gf/gF
set isfname+=@-@
let g:vim_svelte_plugin_use_typescript = 1
let g:vim_svelte_plugin_use_sass = 1
let g:vim_svelte_plugin_has_init_indent = 1
" netrw
"let g:netrw_liststyle = 3
"let g:netrw_winsize = 18 
let g:netrw_banner = 0
"let g:netrw_hide = 1
"let g:netrw_preview = 1
" inc/dec number under cursor
" because <C-a> is used by tmux
noremap <buffer> <nowait> <LEADER>+ <C-a>
noremap <buffer> <nowait> <LEADER>- <C-x>
" exist terminal mode with escape key
tnoremap <Esc> <C-\><C-n>
"set timeoutlen=100 ttimeoutlen=100
" END OF BASIC SETTINGS




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



" CUSTOM BINDINGS
let g:openRgAndFzfInSplit = 0
function OpenRgPlusFzf()
  if has('nvim') && g:openRgAndFzfInSplit
    execute 'split | terminal bash -c "rg --no-ignore -n --max-filesize 2M  . | fzf --multi"'
  else
    execute 'terminal bash -c "rg --no-ignore -n --max-filesize 2M  . | fzf --multi"'
  endif
endfunction
function OpenFzf()
  if has('nvim') && g:openRgAndFzfInSplit
    execute 'split | terminal fzf --multi'
  else
    execute 'terminal fzf --multi'
  endif
endfunction
map <space>r :call OpenRgPlusFzf()<enter>
map <space>f :call OpenFzf()<enter>
if exists(":NERDTreeToggle")
  map <C-n> :NERDTreeToggle<CR>
endif
if 1 || exists(":Explore")
  map <C-n> :Explore<CR>
endif
if exists(":CocRestart")
  autocmd BufEnter *.svelte execute ":silent! CocRestart"
endif
if has('nvim')
  autocmd TermOpen term://* startinsert
endif
" END OF CUSTOM BINDINGS




" COC CONFIGURATION
let g:coc_global_extensions = ['coc-json']
" Set internal encoding of vim, not needed on neovim, since coc.nvim using some
" unicode characters in the file autoload/float.vim
set encoding=utf-8
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
" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)
" Remap <C-f> and <C-b> for scroll float windows/popups.
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif
" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')
" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" END OF COC CONFIGURATION
