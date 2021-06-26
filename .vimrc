


"""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""

" note: some plugins will overwrite options further down in the vimrc, but 
"       these settings are still included, just in case there is ever a desire 
"       (later on, at some point in the future) to build a more customized or 
"       more personalized option in place of the plugin(s); see 'statusline' 
"       setting under the 'customizations' heading for an example.

"""""""""""""""""""""""""""""""""""
"             plugins             "  
"""""""""""""""""""""""""""""""""""

" required:
:set nocompatible
:filetype off

" append vundle to 'runtimepath':
:set runtimepath+=~/.vim/bundle/Vundle.vim
" initialize vundle using the default path to install plugins:
:call vundle#begin()

" required - let vundle manage vundle:
:Plugin 'VundleVim/Vundle.vim'

" vim-colors-solarized:
:Plugin 'altercation/vim-colors-solarized'

" vim-airline:
:Plugin 'vim-airline/vim-airline'
:Plugin 'vim-airline/vim-airline-themes'

" vim-gitgutter:
:Plugin 'airblade/vim-gitgutter'
   
" required:
:call vundle#end()

"""""""""""""""""""""""""""""""""""
"           colorscheme           "   
"""""""""""""""""""""""""""""""""""

" specify colorscheme from plugin- 'solarized'
:colorscheme solarized

" set airline theme; 'command' mode syntax - ':AirlineTheme <theme>'; 
" vimrc syntax: "let g:airline_theme='<theme>'"
:let g:airline_theme='google_dark'

"""""""""""""""""""""""""""""""""""
"        helper functions         "
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

" create a function to call when the '<del>' key ('delete' key) is pressed
" while in 'normal' mode.
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
       
" create a function to call when the '<bs>' key ('backspace' key) is pressed 
" while in 'normal' mode.
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
     
" create a function to call when the '<tab>' key ('tab' key) is pressed while 
" in 'normal' mode.
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
   
" create a function to call when the '<cr>' key ('carriage return' key or the
" 'enter' key) is pressed while in 'normal' mode.
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
"         order-dependent         " 
"""""""""""""""""""""""""""""""""""

" prevent 'defaults.vim' from being sourced; although this file should not be
" run upon startup anyway because there is a user vimrc present (this file), it 
" is explicitly skipped here just for saftey.
:let g:skip_defaults_vim=1

"""""""""""""""""""""""""""""""""""
"         customizations          "    
"""""""""""""""""""""""""""""""""""

" use 'W' to write file changes even after opening without 'sudo'.
:command W silent execute 'write !sudo /usr/bin/tee ' 
            \   . shellescape(@%, 1) . ' > /dev/null' <bar> edit!

" jump to last position of cursor, unless it is invalid, inside event handler
" (when dropping files in gvim), or editing commit file (probably different).
autocmd BufReadPost * 
  \   if line("'\"") > 0 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   :execute "normal! g`\"" 
  \ | endif

" format the statusbar; again, this is pointless when using 'vim-airline' (or 
" another status bar plugin), but leaving it here in case there is a desire in 
" the future to build a customized, personal status bar. 
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

" format the titlestring; this does not seem to work when running 
:set titlestring=%<%{strpart(expand(\"%:p:h\"),stridx(expand(\"%:p:h\"),
                  \\"/\",strlen(expand(\":p:h\"))-12))}%=[%n]
                  \%{expand(\"%:t:r\")}\%m\%y\ %l\\%L

"""""""""""""""""""""""""""""""""""
"          key mappings           " 
"""""""""""""""""""""""""""""""""""

" in 'normal' mode, have 'delete' key call function 'Delete_key()'.
nnoremap <silent> <del> :call Delete_key()<cr>

" in 'normal' mode, have 'backspace' key call function 'Backspace_key()'.
nnoremap <silent> <bs> :call Backspace_key()<cr>

" in 'normal' mode, have 'tab' key call function 'Tab_key()'.
nnoremap <silent> <tab> :call Tab_key()<cr>

" in 'normal' mode, have 'carriage return' key ('enter' key) call function 
" 'Return_key()'.
nnoremap <silent> <cr> :call Return_key()<cr>

" in 'normal' mode, have 'space' key ('spacebar' key) activate 'insert' mode, 
" enter one 'space', then enter 'escape' to change back into 'normal' mode.
nnoremap <silent> <space> i<space><esc>l

" in 'insert' mode, have 'control' plus 'v' enter 'escape' to change into
" 'normal' mode, then enter '"+p' to paste from system clipboard, then enter
" 'a' to change back into 'insert' mode using append.
:inoremap <C-v> <esc>"+pa

" in 'visual' mode, have 'control' plus 'c' enter '"+y' to copy selection to
" system clipboard.
:vnoremap <C-c> "+y

" in 'visual' mode, have 'control' plus 'd' enter '"+d' to cut selection to
" system clipboard.
:vnoremap <C-d> "+d

"""""""""""""""""""""""""""""""""""
"       backup, swap, undo        "
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

""""""""""""""""""""""""""""""""""""
"          indentation             " 
""""""""""""""""""""""""""""""""""""

" load indentation rules and plugins according to the detected filetype.
:filetype plugin indent on

" use indent of previous line for newly created line. 
:set autoindent

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

" use multiple of shiftwidth when indenting with '>>' and '<<'.
:set shiftround

" at line start, value of 'shiftwidth' will represent '<tab>'; elsewhere, value
" of 'tabstop' or 'softtabstop' will represent '<tab>'.
:set smarttab

"""""""""""""""""""""""""""""""""""
"            searching            "          
"""""""""""""""""""""""""""""""""""

" display partial matches for search patterns.
:set incsearch

" highlight matches with the last used search pattern. 
:set hlsearch

" search using case insensitive matching. 
:set ignorecase

" search using 'smart' case matching.
:set smartcase

"""""""""""""""""""""""""""""""""""
"           performance           "           
"""""""""""""""""""""""""""""""""""

" do not update screen during macro and script execution.
:set lazyredraw

"""""""""""""""""""""""""""""""""""
"         text rendering          "
"""""""""""""""""""""""""""""""""""

" turn on syntax highlighting
:syntax enable

" always try to show a paragraph's last line.
:set display+=lastline

" use an encoding that supports unicode.
:set encoding=utf-8

" do not split words when wrapping text (wraps full word).
:set linebreak

" specify minimum screen lines to keep above/below cursor - '10'.
:set scrolloff=10

" wrap lines at the width of the window.
:set wrap

" specify format option to wrap text - 't'. 
:set formatoptions=t

" break/wrap each line at number of characters specified - '79'.
:set textwidth=79

" display current cursor position (lower-right). 
:set ruler

" set a visual aid for current line and update as cursor moves.
:set cursorline

" display line numbers in the left margin.
:set number

" disable beep on errors.
:set noerrorbells

" flash the screen instead of beeping on errors.
:set visualbell

" enable mouse usage for specified mode(s) - 'a': all modes.
:set mouse=a

" show the titlebar to enable titlestring customization
:set title

" set length of titlestring
:set titlelen=30

" set compatibility for dark background and syntax highlighting.
:set background=dark

"""""""""""""""""""""""""""""""""""
"         user interface          "
"""""""""""""""""""""""""""""""""""

" specify when to display statusline - '2': always.
:set laststatus=2

" use '<left>' or '<right>' to navigate through completion lists
:set wildmenu

" show longest common command and completion list on first '<tab>', then show 
" interactive list on second '<tab>' (navigate with '<tab>', '<shift>+<tab>', 
" '<left>', or '<right>').
:set wildmode=list:longest,full

" set a visual aid for ideal textwidth
:set colorcolumn=+1

" set the height of the command window to number of lines specified - '2'.
:set cmdheight=2

" display (partial) commands in statusline (lower-right, left of ruler).
:set showcmd

" show matching brackets, parentheses, etc. 
:set showmatch

"""""""""""""""""""""""""""""""""""
"             folding             "  
"""""""""""""""""""""""""""""""""""

" fold based on indentation levels.
:set foldmethod=indent

"  only fold up to three nested levels.
:set foldnestmax=7 

" specify width of additional margin to add left of line numbers - '2'.
:set foldcolumn=2

"""""""""""""""""""""""""""""""""""
"         miscellaneous           "          
"""""""""""""""""""""""""""""""""""

" allow '<BS>' over indent/autoindent, line breaks, and 'insert' mode start.
:set backspace=indent,eol,start

" automatically save before commands like ':next' and ':make'.
:set autowrite

" stop certain movements from always going to the first character of a line.
:set nostartofline

" toggle between 'paste' and 'nopaste' using the key specified - '<F11>'.
:set pastetoggle=<F11>

" let vim use the system clipboard.
:set clipboard=unnamed

" display a confirmation dialog when closing an unsaved file.
:set confirm

" specify format option to delete comment characters when joining lines - 'j'.
:set formatoptions+=j

" hide unsaved buffer in background when new buffer is opened in it's place.
:set hidden

" increase the undo limit.
:set history=1000

" interpret octal as decimal when incrementing numbers.
:set nrformats-=octal

" enable spell checking.
:set spell

"""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""
