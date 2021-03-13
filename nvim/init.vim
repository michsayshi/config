" VIM Plug {{{
call plug#begin('~/.config/nvim/plugged')

" Languages
Plug 'sheerun/vim-polyglot'
Plug 'rust-lang/rust.vim'
Plug 'lervag/vimtex'

" General
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdtree'
Plug 'justinmk/vim-sneak'
Plug 'easymotion/vim-easymotion'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'neomake/neomake'
Plug 'fatih/molokai'
    augroup localneomake " run on buffer save
        autocmd! BufWritePost * Neomake
    augroup END

" Plugins to consider in the future
" vim-sneak -> find two characters
" vim-scripts/mru -> most recently opened files
call plug#end()
" }}}

" General options {{{
set nocompatible
set ts=2
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set encoding=utf-8
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set textwidth=120
set autoindent
set smartindent
filetype plugin indent on
set backspace=indent,eol,start " make backspace behave logically
set smartcase
set showmatch
set formatoptions=lcqj
set lbr
set ofu=syntaxcomplete#Complete
set virtualedit=block,onemore
set splitbelow
set splitright
au VimResized * :wincmd = " Resize splits when the window is resized
autocmd BufEnter,FocusGained * checktime " Refresh current buffer if file changed
let g:vim_json_syntax_conceal = 0 "Disabling concealing json syntax by default
" }}}

" Visual options {{{
set termguicolors
set t_Co=256
syntax on
color molokai
set showmode
set showcmd
""set hidden " allow buffers to be hidden with unsaved changes
set cursorline
set number
" set relativenumber
set lsp=1
set laststatus=2 " always show status line
" }}}

set noerrorbells visualbell t_vb= " disable annoying bell
" Search options {{{
set incsearch " search while typing
set smartcase
set ignorecase
" }}}

" Trailing whitespace  {{{
" Only shown when not in insert mode so I don't go insane.
augroup trailing
    au!
    au InsertEnter * :set listchars-=trail:⌴
    au InsertLeave * :set listchars+=trail:⌴
augroup END
" }}}

" Plugin config {{{

"" Coc
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

"" Go
" general
let g:go_fmt_command = "goimports"
let g:go_autodetect_gopath = 1
let g:go_list_type = "quickfix"
" syntax highlighting
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1

"" Rust
let g:rustfmt_autosave = 1
let g:rustfmt_emit_files = 1
let g:rustfmt_fail_silently = 0
" Follow Rust code style rules
au Filetype rust set colorcolumn=100
au Filetype rust set shiftwidth=4
au Filetype rust set softtabstop=4
au Filetype rust set tabstop=4
" }}}

" Key Mapping {{{
" leader
let mapleader = "\<Space>"
" Suspend with ctrl+f
inoremap <C-f> :sus<cr>
vnoremap <C-f> :sus<cr>
nnoremap <C-f> :sus<cr>
" disable help button
map <F1> <Esc>
imap <F1> <Esc>
" Switch between splits
nmap <Tab> :wincmd w<return>
nmap <S-Tab> :wincmd W<return>
nmap <F2> :NERDTreeToggle<return>

" Plugin key mapping

" 'Smart' complete nevigation
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
" }}}
