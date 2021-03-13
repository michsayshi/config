" VIM Plug {{{
call plug#begin('~/.config/nvim/plugged')

" Languages
" Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
 Plug 'sheerun/vim-polyglot'
 Plug 'rust-lang/rust.vim'


" General
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
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
" }}}

" deoplete {{{
" let g:deoplete#enable_at_startup = 1 
" " Use smartcase.
" call deoplete#custom#option('smart_case', v:true)

" <CR>: close popup and save indent.
" inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
" function! s:my_cr_function()
"   return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
"   " For no inserting <CR> key.
"   "return pumvisible() ? "\<C-y>" : "\<CR>"
" endfunction
" <TAB>: completion.
" inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" " <C-h>, <BS>: close popup and delete backword char.
" inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
" inoremap <expr><BS> deoplete#smart_close_popup()."\<C-h>"
