if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'zchee/deoplete-jedi'
Plug 'zchee/deoplete-clang'
Plug 'scrooloose/nerdtree'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tpope/vim-fugitive'
Plug 'bling/vim-airline'
Plug 'kien/ctrlp.vim'
Plug 'fatih/vim-go'
Plug 'PProvost/vim-ps1'
Plug 'tpope/vim-eunuch'
Plug 'w0rp/ale'
call plug#end()

syntax on
colo elflord
set hlsearch
set incsearch
set expandtab
set tabstop=4
set shiftwidth=4
set ignorecase
set smartcase
set number
set si
set exrc
filetype plugin indent on
let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-5.0/lib/libclang.so.1'

map <F5> :Gdiff<CR>
map <F6> :Gcommit<CR>
map <F7> :Gstatus<CR>
