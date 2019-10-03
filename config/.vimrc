" Silently execute python3 to avoid deprecation warnings
if has('python3')
  silent! python3 1
endif
" Use Python with the libraries in the current virtualenv
py << EOF
import os
if 'VIRTUAL_ENV' in os.environ:
  project_base_dir = os.environ['VIRTUAL_ENV']
  activate_this = os.path.join(project_base_dir, 'bin/activate_this.py')
  with open(activate_this, 'r') as activate_this_file:
    exec(activate_this_file.read(), dict(__file__=activate_this))
EOF

" Set very magic mode on by default
nnoremap / /\v
vnoremap / /\v
cnoremap %s/ %smagic/
cnoremap \>s/ \>smagic/
nnoremap :g/ :g/\v
nnoremap :g// :g//

set nocompatible               " don't go into Vi mode, use VIM's features
let mapleader=","              " map leader changed to comma
set noruler                    " hide the position of cursor in the buffer
set laststatus=0               " hide the statusline
set encoding=utf-8             " allow UTF8 characters to be viewed
set nowrap                     " don't wrap lines
set nrformats=alpha            " allow incrementing alphabets
set fileformat=unix            " set unix file format
set splitbelow                 " split new windows below current
set splitright                 " split new windows to the right of current
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set number relativenumber      " always show line numbers
set visualbell                 " don't beep
set noerrorbells               " don't beep
set showmatch                  " set show matching parenthesis
set updatetime=1000            " set update time for the swap file
set history=1000               " remember more commands and search history
set mouse=a                    " enable mouse support
set undolevels=1000            " use many muchos levels of undo
set undofile                   " maintain undo history between sessions
set undodir=~/.vim/undodir     " undo save directory
set formatoptions+=ro          " allow auto-adding of comments
" highlight extra whitespace
highlight BadWhitespace ctermbg=red guibg=red
match BadWhitespace /\s\+$/

" Indentation
set expandtab    " convert tab to spaces
set tabstop=4    " a tab is four spaces
set shiftwidth=4 " number of spaces to use for autoindenting
set shiftround   " use multiple of shiftwidth when indenting with '<' and '>'
set autoindent   " always set autoindenting on
set copyindent   " copy the previous indentation on autoindenting

" Searching
set ignorecase " ignore case when searching
set smartcase  " ignore case if search pattern is all lowercase, case-sensitive otherwise
set hlsearch   " highlight search terms
set incsearch  " show search matches as you type

" Folding
set foldmethod=indent " allow folding of code by indentation
" shortcut for fixing indent-issues
nnoremap <leader>s :set foldmethod=indent<CR>
" shortcut for toggling a fold
nnoremap <space> za
" remember folds after closing and when opening files
augroup AutoSaveFolds
  autocmd!
  autocmd BufWinLeave ?* mkview
  autocmd BufWinEnter ?* silent loadview
  autocmd BufWinEnter ?* set foldmethod=indent
augroup END

" Buffers
set hidden                  " allow changing buffers without saving
command BufDelete bp | bd # " command to delete buffer compatible with NERDTree
" shortcuts for moving b/w buffers
nnoremap <C-N> :bnext<CR>
nnoremap <C-P> :bprev<CR>

" Syntax Highlighting
if &t_Co >= 256 || has("gui_running")
  colorscheme gogh
endif
if &t_Co > 2 || has("gui_running")
  syntax on " switch syntax highlighting on, when the terminal has colors
endif

" File extension specific settings
autocmd FileType python setlocal completeopt-=preview
filetype plugin indent on           " enable plugins, indentation and features based on the filetype
" Indentation for webdev languages, markdown and vimrc
au BufNewFile,BufRead *.php,*.js,*.ts,*.html,*.css,*.scss,*.md,*.json,*.vimrc
  \ setlocal tabstop=2 |
  \ setlocal shiftwidth=2
au BufNewFile,BufRead *.py
  \ set foldignore-=#               " allow folding of comments
au BufNewFile,BufRead *.ts
  \ setlocal filetype=javascript    " enable javascript-like syntax highlighting for typescript
au BufNewFile,BufRead *.tex
  \ setlocal filetype=tex           " by default it is simpletex
au FileType tex
  \ setlocal spell spelllang=en_gb  " UK English spell check for tex files
au FileType text
  \ execute ':IndentLinesDisable' | " disable indentation lines
  \ setlocal noexpandtab            " do not convert tabs to spaces for standard text

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy/<C-R><C-R>=substitute(
  \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \ let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \ gvy?<C-R><C-R>=substitute(
  \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \ gV:call setreg('"', old_reg, old_regtype)<CR>

" Change case with ~ key
function! TwiddleCase(str)
  if a:str ==# toupper(a:str)
    let result = tolower(a:str)
  elseif a:str ==# tolower(a:str)
    let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  else
    let result = toupper(a:str)
  endif
  return result
endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" Shortcuts for clipboard functionality
" do not erase clipboard on exit
autocmd VimLeave * call system('echo ' . shellescape(getreg('+')) . ' | xclip -selection clipboard')
" normal mode
nmap <leader>y "+y
nmap <leader>Y "+yy
nmap <leader>p o<space><ESC>v"+p
nmap <leader><S-p> <S-o><space><ESC>v"+p
nmap <leader>d "+d
" visual mode
vmap <leader>y "+y
vmap <leader>Y "+yy
vmap <leader>p "+p
vmap <leader><S-p> <S-o><space><ESC>v"+p
vmap <leader>d "+d

" Options for the plugin ALE
" Enable some linters not done by default
let g:ale_linters={
  \ 'sh': ['bashls', 'shell'],
  \ 'python': ['pyls'],
  \ 'tex': ['texlabls', 'chktex']
  \ }
" Enable pydocstyle for docstring linting
let g:ale_python_pyls_config={'pyls': {'plugins': {
  \ 'pydocstyle': {'enabled': v:true}
  \ }}}
" Set fixers for linting issues
let g:ale_fixers={
  \ 'python': ['black', 'isort'],
  \ 'go': ['gofmt'],
  \ 'cpp': ['uncrustify'],
  \ }
let g:ale_fix_on_save=1                                      " fix files on save
let g:ale_completion_enabled=1                               " enable ALE's completion through LSP
set omnifunc=ale#completion#OmniFunc                         " make vim's omnicompletion use ALE, because supertab uses it for tab completion
set completeopt+=noinsert                                    " fix for ALE auto completion
let g:ale_set_balloons=1                                     " enable ballon text using mouse hover through LSP
nmap <leader>f :ALEFix<CR>
nmap <leader>gd :ALEGoToDefinition<CR>

" Options for the plugin indentLine
let g:indentLine_showFirstIndentLevel = 1                      " show first indent level
let g:indentLine_first_char = '▏'                              " character for indent lines
let g:indentLine_char = '▏'                                    " character for indent lines
let g:indentLine_color_term = 8                                " do not change gray color
let g:indentLine_color_gui = '#505666'                         " do not change gray color
let g:indentLine_bufTypeExclude = ['tex', 'json', 'markdown']  " exclude tex and json files
let g:indentLine_fileTypeExclude = ['tex', 'json', 'markdown'] " exclude tex and json files
" define command and function for changing indentation level for tabs
" this is because the indentLine plugin also needs to be refreshed
function SetIndent(indent)
  let &shiftwidth=a:indent
  execute ":IndentLinesReset"
endfunction
command -nargs=1 SetIndent call SetIndent(<f-args>)

" Options for the plugin vim-shebang
let g:shebang#shebangs = {
  \ 'python' : '#!/usr/bin/env python3',
  \ 'awk': '#!/usr/bin/awk -f',
  \ 'php': '',
  \ 'sh' : '#!/usr/bin/zsh',
  \ }

" Options for other plugins
let g:instant_markdown_autostart = 0                   " don't start instant markdown preview on start
let g:SuperTabDefaultCompletionType = "<c-n>"          " tab completion from top to bottom
let g:NERDSpaceDelims = 1                              " delimit comments by one space
let g:NERDCustomDelimiters = {'python': {'left': '#'}} " workaround for double-space in python
let g:NERDDefaultAlign = "left"                        " align comment symbols to the left
let g:strip_whitespace_on_save = 1                     " strip trailing whitespace on save
let g:livepreview_engine = 'xelatex -shell-escape'     " default pdf engine for latex-preview
let g:fastfold_fold_command_suffixes = []              " fastfold
" close NERDTree on closing all buffers
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

packloadall          " load all plugins
silent! helptags ALL " load all helptags

" Plugins options to be set after plugin load
call ale#Set('python_black_options', '--fast --line-length=79')                                   " use black with line length limit of 79
au FileType * call ale#Set('c_uncrustify_options', '-l ' . &ft . ' -c ' . $HOME . '/.uncrustify') " use uncrustify with custom config and auto-detect language
" Use the buffer's directory if a git repository is not available
function! LangServProjRoot(buffer)
  let l:git_path = ale#path#FindNearestDirectory(a:buffer, '.git')
  let l:curr_dir = fnamemodify(bufname(a:buffer), ':h')
  return !empty(l:git_path) ? fnamemodify(l:git_path, ':h:h') : l:curr_dir
endfunction
call ale#linter#Define('sh', {
\   'name': 'bashls',
\   'lsp': 'stdio',
\   'executable': function('ale_linters#sh#language_server#GetExecutable'),
\   'command': function('ale_linters#sh#language_server#GetCommand'),
\   'project_root': function('LangServProjRoot'),
\})
call ale#linter#Define('tex', {
\   'name': 'texlabls',
\   'lsp': 'stdio',
\   'executable': {b -> ale#Var(b, 'tex_texlab_executable')},
\   'command': function('ale_linters#tex#texlab#GetCommand'),
\   'project_root': function('LangServProjRoot'),
\})
