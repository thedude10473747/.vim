


"""""""""""""""""""""""""""""""""""
"            pathogen                   
"""""""""""""""""""""""""""""""""""

" 'pathogen' allows for efficient management of not only install/runtime files
" for plugins, but also support for one-page or two-page scripts; via the 'git'
" command line interface, we can extract all necessary files straight from
" 'github' by cloning each respective repo into a private sub-directory located
" inside the directory '~/.vim/bundle'.
"":execute pathogen#infect()

"""""""""""""""""""""""""""""""""""
"             vundle              "  
"""""""""""""""""""""""""""""""""""

" required:
":set nocompatible
":filetype off

" append vundle to 'runtimepath':
":set runtimepath+=~/.vim/bundle/Vundle.vim
" initialize vundle using the default path to install plugins:
":call vundle#begin()
" or initialize vundle using a custom path '~/path/to/dir' to install plugins:
":call vundle#being('~/path/to/dir')

" required - let vundle manage vundle:
":Plugin 'VundleVim/Vundle.vim'

" plugin commands must be within 'vundle#begin()' and 'vundle#end()'; below are
" some examples of different command formats that are supported.
" plugin from github repo:
":Plugin 'username/repo-one'
" plugin from 'https://vim-scripts.org/vim/scripts.html':
":Plugin 'repo-two'
" git plugin not hosted on github:
":Plugin 'git://git.username.com/plugin-one.git'
" local git repo (i.e., personal plugins):
":Plugin 'file:///home/username/path/to/plugin-two'
" if subdirectory named 'subdir' within repo named 'repo' holds the vim script 
" named 'vimscript', then pass the subdirectory path to set the 'runtimepath':
":Plugin 'username/repo', {'rtp': 'subdir/')
" install plugin 'repo-two' but avoid naming conflict if different version has
" already been installed somewhere else (as above for 'repo-two'):
":Plugin 'username/repo-two', {'name': 'new-repo-two'}

" required:
":call vundle#end()
":filetype plugin indent on
" if needed, plugin indent changes can be ignore:
":filetype plugin on

" a few common commands:
":PluginList        - list configured plugins
":PluginInstall     - install plugins; append '!' to update.
":PluginSearch foo  - search for foo; append '!' to refresh (local) cache.
":PluginClean       - confirm unused plugins are removed; append '!' for auto.

"""""""""""""""""""""""""""""""""""
"            vim-plug             "
"""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""
"        helper functions         
"""""""""""""""""""""""""""""""""""

" return message if 'paste' mode currently enabled - display on statusbar.
function! HasPaste()
    if &paste
        return 'PASTE MODE '
    else
        return ''
    endif
endfunction

" set a property equal to itself to reload tabline - autoupdate statusbar.
function! UpdateStatusbar(timer)    
    :execute 'let &ro=&ro'
endfunction

" create function to call when '<del>' key is pressed in 'normal' mode.
function! Delete_key(...)
  let line=getline('.')
  if line=~'^\s*$'
    execute "normal dd"
    return
  endif
  let column=col('.')
  let line_len=strlen(line)
  let first_or_end=0
  if column==1
    let first_or_end=1
  else
    if column==line_len
      first_or_end=1
    endif
  endif
  execute "normal i\<del>\<esc>"
  if first_or_end==0
    execute "normal l"
  endif
endfunction
       
" create function to call when '<bs>' key is pressed in 'normal' mode.
function! Backspace_key(...)
  let column=col('.')
  execute "normal i\<bs>\<esc>"
    if column==1
      let column2=col('.')
      if column2>1
        execute "normal l"
      endif
    else
      if column>2
        execute "normal l"
      endif
    endif
endfunction
     
" create function to call when '<tab>' key is pressed in 'normal' mode.
function! Tab_key(...)
  let start_pos=col('.')
  execute "normal i\<tab>"
  let end_pos=col('.')
  let diff=end_pos-start_pos
  let counter=0
  while 1==1
    execute "normal l"
    "let counter=counter+1
    let counter+=1
    if counter>=diff
      break
    endif
  endwhile
  execute "normal \<esc>"
endfunction
   
" create function to call when '<cr>' key is pressed in 'normal' mode
function! Return_key(...)
  let buftype=getbufvar(bufnr(''),'&buftype')
  if buftype!=''
    unmap <cr>
    execute "normal \<cr>"
    nnoremap <silent> <cr> :call Return_key()<cr>
  else
    execute "normal i\<cr>\<esc>"
  endif
endfunction

"""""""""""""""""""""""""""""""""""
"         order-dependent          
"""""""""""""""""""""""""""""""""""

" prevent 'defaults.vim' from being sourced; although this file should not be
" sourced anyway because there is a user vimrc present (this file), it is 
" explicitly skipped here just for saftey.
:let g:skip_defaults_vim=1

" Use 'set nocompatible', only if not already done so (prevents any unintended
" "side effects", which can crop up if 'nocp' has already been set). 
if &compatible
    :set nocompatible
endif

"""""""""""""""""""""""""""""""""""
"     complex/situational           
"""""""""""""""""""""""""""""""""""

" write the file changes after editing without sudo
:command W silent execute 'write !sudo /usr/bin/tee ' 
            \   . shellescape(@%, 1) . ' > /dev/null' <bar> edit!

" jump to last position of cursor, unless it is invalid, inside event handler
" (when dropping files in gvim), or editing commit file (probably different).
autocmd BufReadPost * 
  \   if line("'\"") > 0 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   :execute "normal! g`\"" 
  \ | endif

" format the statusbar.
:set statusline=bf:[%n]\ 
                    \%{HasPaste()}\'%F'\%m%r%h%w,\ 
                    \ft:%y,\ 
                    \cwd:\'%{getcwd()}',\ 
                    \mod:\ %{strftime(\"%c\",getftime(expand(\"%:p\")))}
                    \%=\ 
                    \line:%l/%L,\ 
                    \col:%c\ 

" update statusbar every number of seconds specified - '4000': 4 seconds.
:let timer=timer_start(4000,'UpdateStatusbar',{'repeat':-1})

" format the titlestring
:set titlestring=%<%{strpart(expand(\"%:p:h\"),stridx(expand(\"%:p:h\"),
                  \\"/\",strlen(expand(\":p:h\"))-12))}%=[%n]
                  \%{expand(\"%:t:r\")}\%m\%y\ %l\\%L

"""""""""""""""""""""""""""""""""""
"          key mappings           " 
"""""""""""""""""""""""""""""""""""

" map '<del>' key to call function 'Delete_key()'
nnoremap <silent> <del> :call Delete_key()<cr>

" map '<bs>' key to call function 'Backspace_key()'
nnoremap <silent> <bs> :call Backspace_key()<cr>

" map '<tab>' key to call function 'Tab_key()'
nnoremap <silent> <tab> :call Tab_key()<cr>

" map '<cr>' to call function 'Return_key()'
nnoremap <silent> <cr> :call Return_key()<cr>

" map '<space>' key to to 'i\<space>\<esc>l' which will change to 'insert'
" mode, enter '<space>' key, enter '<esc>' key to change to 'normal' mode
nnoremap <silent> <space> i<space><esc>l

"""""""""""""""""""""""""""""""""""
"             common                             
"""""""""""""""""""""""""""""""""""

" show the titlebar to enable titlestring customization
:set title

" set length of titlestring
:set titlelen=30

" load indentation rules and plugins according to the detected filetype.
:filetype plugin indent on

" allow '<BS>' over indent/autoindent, line breaks, and 'insert' mode start.
:set backspace=indent,eol,start

" turn on syntax highlighting
:syntax on

" set compatibility for dark background and syntax highlighting.
:set background=dark

" use indent of previous line for newly created line. 
:set autoindent

" specify when to display statusline - '2': always.
:set laststatus=2

" display current cursor position (lower-right). 
:set ruler

" enable mouse usage for specified mode(s) - 'a': all modes.
:set mouse=a

" use '<space>' characters in place of '<tab>' character.
:set expandtab

" specify number of '<space>' characters each '<tab>' will represent - '2'.
:set tabstop=2

" specify number of '<space>' characters each '<tab>' and '<bs>' will represent 
" when performing editing operations (with 'insert' mode) - '2'.
:set softtabstop=2

" specify number of '<space>' characters each '>>' and '<<' will represent, as 
" well as number of '<space>' characters each level of automatic indentation
" will represent; - '2'.
:set shiftwidth=2

" at line start, value of 'shiftwidth' will represent '<tab>'; elsewhere, value
" of 'tabstop' or 'softtabstop' will represent '<tab>'.
:set smarttab

" display line numbers in the left margin.
:set number

" specify width of additional margin to add left of line numbers - '2'.
:set foldcolumn=2

" wrap lines at the width of the window.
:set wrap

" do not split words when wrapping text (wraps full word).
:set linebreak

" wrap text using specified formatting option - 't': textwidth. 
:set formatoptions=t

" break/wrap each line at number of characters specified - '79'.
:set textwidth=79

" set a visual aid for ideal textwidth
:set colorcolumn=+1

" set a visual aid for current line and update as cursor moves.
:set cursorline

" set the height of the command window to number of lines specified - '2'.
:set cmdheight=2

" display (partial) commands in statusline (lower-right, left of ruler).
:set showcmd

" show matching brackets, parentheses, etc. 
:set showmatch

" display partial matches for search patterns.
:set incsearch

" highlight matches with the last used search pattern. 
:set hlsearch

" search using case insensitive matching. 
:set ignorecase

" search using 'smart' case matching.
:set smartcase

" record specified number of commands and search patterns - '200'.
:set history=200

" automatically save before commands like ':next' and ':make'.
:set autowrite

" use '<Left>' or '<Right>' to navigate through completion lists. 
:set wildmenu

" specify minimum screen lines to keep above/below cursor - '10'.
:set scrolloff=10

" stop certain movements from always going to the first character of a line.
:set nostartofline

" toggle between 'paste' and 'nopaste' using the key specified - '<F11>'
:set pastetoggle=<F11>

"""""""""""""""""""""""""""""""""""
"       backup, swap, undo        
"""""""""""""""""""""""""""""""""""

" set backup directory
:set backupdir=~/.vim/.backup//

" set undo directory
:set undodir=~/.vim/.undo//

" set swap directory
:set directory=~/.vim/.swp//

" keep a backup file
:set backup

" keep an undo file
:set undofile

" keep a swap file
:set swapfile

"""""""""""""""""""""""""""""""""""
"  colorscheme and highlighting                
"""""""""""""""""""""""""""""""""""

" specify general colorscheme - 'desert'
:colorscheme desert

" remove the current individual syntax highlighting for a group.
":highlight Normal ctermfg=None
":highlight Comment ctermfg=None

" configure individual instructions for syntax hightlighting.
":highlight Normal ctermfg=Blue
":highlight Comment ctermfg=Green


