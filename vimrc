execute pathogen#infect()

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
"let g:airline_theme='hybrid'

function! SearchUp(path, needles)
    let l:i = 0
    while l:i < len(a:needles)
        if isdirectory(a:path . '/' . a:needles[l:i])
            return l:i
        endif
        let l:i = l:i + 1
    endwhile

    if a:path == '/'
        return -1
    else
        return SearchUp(fnamemodify(a:path, ':h'), a:needles)
    endif
endfunction

function! SearchUpFromFile(needles)
    return SearchUp(fnamemodify(expand('%:p'), ':h'), a:needles)
endfunction

function! DetectVCS()
    return SearchUpFromFile(['.git', '.svn'])
endfunction

function! VCSDiff()
    let l:vcs = DetectVCS()
    if l:vcs == 0
        Gdiff
    elseif l:vcs == 1
        SVNDiff
    endif
endfunction

function! VCSCommit()
    let l:vcs = DetectVCS()
    if l:vcs == 0
        Gcommit
    elseif l:vcs == 1
        SVNCommit
    endif
endfunction

function! VCSStatus()
    let l:vcs = DetectVCS()
    if l:vcs == 0
        Gstatus
    elseif l:vcs == 1
        SVNStatus
    endif
endfunction

function! GetLines()
  let buf = getline(1, '$')
  if &encoding != 'utf-8'
    let buf = map(buf, 'iconv(v:val, &encoding, "utf-8")')
  endif
  if &l:fileformat == 'dos'
    " XXX: line2byte() depend on 'fileformat' option.
    " so if fileformat is 'dos', 'buf' must include '\r'.
    let buf = map(buf, 'v:val."\r"')
  endif
  return buf
endfunction

function! System(str, ...) abort
    return call('system', [a:str] + a:000)
endfunction

function! PHPsave()
    let l:tmpname = tempname()
    call writefile(GetLines(), l:tmpname)
    let l:cmd = join(['php-cs-fixer', '--no-ansi', '--no-interaction', '--quiet', 'fix', l:tmpname, '--rules=@PSR2'], ' ')
    call system(l:cmd)
    call rename(l:tmpname, expand("%"))
    silent! edit!
    syntax on
endfunction

let mapleader = ","
autocmd FileType java map <F8> :!ant<CR>
autocmd FileType java map <F9> :!ant run<CR>
autocmd FileType cpp set tags+=~/.vim/systags
autocmd FileType cpp set omnifunc=ccomplete#Complete
autocmd FileType c set tags+=~/.vim/systags
autocmd FileType c set tags+=~/.vim/linuxtags
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType php set tags+=~/.vim/phptags
autocmd FileType xml set omnifunc=xmlcomplete#CompleteXML
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType go map <F9> :GoRun<CR>
autocmd FileType go nmap <Leader>i <Plug>(go-info)
autocmd FileType go nmap <Leader>d <Plug>(go-doc)
autocmd FileType go nmap <Leader>c <Plug>(go-coverage-toggle)
autocmd FileType go nmap <Leader>t <Plug>(go-test)
autocmd FileType go nmap <Leader>r <Plug>(go-run)
autocmd FileType go nmap <Leader>b <Plug>(go-build)
autocmd FileType php nmap <Leader>f :!php-cs-fixer --no-ansi --quiet --no-interaction fix "%"<CR><CR>L
autocmd BufWritePre *.php call PHPsave()
set tags+=./tags
map <F5> :call VCSDiff()<CR>
map <F6> :call VCSCommit()<CR>
map <F7> :call VCSStatus()<CR>
map <F8> :make<CR>
map <F9> :make<CR>
nmap <F8> :TagbarToggle<CR>

"YCM
let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
let g:ycm_filetype_whitelist = {'js':1,'py':1,'c':1}

"UltiSnips
let UltiSnipsEditSplit="vertical"
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

set secure
"if has("gui_running")
    highlight SpellBad ctermbg=DarkBlue gui=undercurl guisp=Orange
"endif
