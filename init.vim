if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
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
Plug 'OmniSharp/omnisharp-vim'
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
set number relativenumber
set si
set exrc
set foldnestmax=1
set foldmethod=indent
filetype plugin indent on
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#sources#syntax#min_keyword_length = 2
let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-5.0/lib/libclang.so.1'
au BufRead,BufNewFile *.nasm set filetype=nasm

map <F5> :Gdiff<CR>
map <F6> :Gcommit<CR>
map <F7> :Gstatus<CR>

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

if has("cscope")
        set nocsverb	" Make cs not verbose
        " Look for a 'cscope.out' file starting from the current directory,
        " going up to the root directory.
        let s:dirs = split(getcwd(), "/")
        while s:dirs != []
                let s:path = "/" . join(s:dirs, "/")
                if (filereadable(s:path . "/cscope.out"))
                        execute "cs add " . s:path . "/cscope.out " . s:path . " -v"
                        break
                endif
                let s:dirs = s:dirs[:-2]
        endwhile

        set csto=0	" Use cscope first, then ctags
        set cst		" Only search cscope
        set csverb	" Make cs verbose

        nmap <C-s>s :cs find s <C-R>=expand("<cword>")<CR><CR>
        nmap <C-s>g :cs find g <C-R>=expand("<cword>")<CR><CR>
        nmap <C-s>c :cs find c <C-R>=expand("<cword>")<CR><CR>
        nmap <C-s>t :cs find t <C-R>=expand("<cword>")<CR><CR>
        nmap <C-s>e :cs find e <C-R>=expand("<cword>")<CR><CR>
        nmap <C-s>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
        nmap <C-s>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
        nmap <C-s>d :cs find d <C-R>=expand("<cword>")<CR><CR>
        " Open a quickfix window for the following queries.
        set cscopequickfix=s-,c-,d-,i-,t-,e-,g-
endif
