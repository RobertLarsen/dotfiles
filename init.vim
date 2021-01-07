if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.local/share/nvim/plugged')
    " Snippets
    Plug 'Shougo/neosnippet.vim'
    Plug 'Shougo/neosnippet-snippets'
    " Helps with pairing brackets
    Plug 'jiangmiao/auto-pairs'
    " Provides a nice tagbar. Press F8 to show/hide.
    Plug 'preservim/tagbar'
    " Autocomplete, error check, jump to definition...programmers swiss army
    " tool
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
    " Directory tree browser
    Plug 'scrooloose/nerdtree'
    " Communicates with tmux
    Plug 'christoomey/vim-tmux-navigator'
    " Git integration
    Plug 'tpope/vim-fugitive'
    " Status bar
    Plug 'bling/vim-airline'
    " File search with <ctrl>+p
    " however, it seems coc has taken over <ctrl>+p
    Plug 'kien/ctrlp.vim'
    " File related commands, such as :Chmod, :Rename, :Move, etc
    Plug 'tpope/vim-eunuch'
    " Highlight all occurences of word under cursor
    Plug 'RRethy/vim-illuminate'
    " Awesome color scheme
    Plug 'ParamagicDev/vim-medic_chalk'
call plug#end()

let g:coc_global_extensions = [
    \'coc-clangd',
    \'coc-cmake',
    \'coc-html',
    \'coc-java',
    \'coc-json',
    \'coc-lists',
    \'coc-neosnippet',
    \'coc-pyright',
    \'coc-rls',
    \'coc-sh',
    \'coc-snippets',
    \'coc-vimlsp'
    \]

syntax on
colo medic_chalk
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
set cursorline
set mouse=a
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:airline#extensions#coc#enabled = 1
filetype plugin indent on
au BufRead,BufNewFile *.nasm set filetype=nasm
let g:neosnippet#snippets_directory = '~/.local/share/nvim/plugged/neosnippet-snippets/neosnippets'

" Reload Vim configuration file after saving it
if !exists('*ReloadVimrc')
   fun! ReloadVimrc()
       let save_cursor = getcurpos()
       source $MYVIMRC
       call setpos('.', save_cursor)
   endfun
endif
autocmd! BufWritePost $MYVIMRC call ReloadVimrc()

map <F5> :Gdiff<CR>
map <F6> :Gcommit<CR>
map <F7> :Gstatus<CR>
nmap <F8> :TagbarToggle<CR>

imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

nnoremap <M-j> :resize -1<CR>
nnoremap <M-k> :resize +1<CR>
nnoremap <M-h> :vertical resize -1<CR>
nnoremap <M-l> :vertical resize +1<CR>

vnoremap < <gv
vnoremap > >gv

" Is this necessary now that coc-clangd is in place?
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

        "   's'   symbol: find all references to the token under cursor
        "   'g'   global: find global definition(s) of the token under cursor
        "   'c'   calls:  find all calls to the function name under cursor
        "   't'   text:   find all instances of the text under cursor
        "   'e'   egrep:  egrep search for the word under cursor
        "   'f'   file:   open the filename under cursor
        "   'i'   includes: find files that include the filename under cursor
        "   'd'   called: find functions that function under cursor calls
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
