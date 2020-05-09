colorscheme ron
set encoding=utf-8
set background=dark
set rnu

autocmd BufEnter * set mouse=
" this caused lines to disappear on startup
" set ttymouse=

"Remove all trailing whitespace by pressing F5
nnoremap <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar><CR>

" Enter the command :set grepprg? to determine what program is used on your
" system to execute the :grep command. If it is the grep utility, the
" following mappings allow searching files in a directory for the word under
" the cursor.
let grepprg="grep -n $* /dev/null"
let g:netrw_bufsettings = 'noma nomod rnu nowrap ro nobl'

" The first mapping searches for the text in the word under the cursor (like
" g*) in any of the files in the current directory.
nnoremap gr :grep -R <cword> *<CR>

" The second mapping searches for the text in the word under the cursor (like
" g*) in any of the files in the same directory as the current file.
nnoremap Gr :grep <cword> %:p:h/*<CR>

" The third mapping searches for the whole word under the cursor (like *) in
" any of the files in the current directory.
nnoremap gR :grep -R '\b<cword>\b' *<CR>

" The fourth mapping searches for the whole word under the cursor (like *) in
" any of the files in the same directory as the current file.
nnoremap GR :grep '\b<cword>\b' %:p:h/*<CR>

let mapleader=","
nnoremap <Leader>o o<Esc>
nnoremap <Leader>O O<Esc>


set incsearch
no <down> j
no <up> k
no <left> h
no <right> l


ino <down> <Nop>
ino <up> <Nop>

xno <expr> <up> mode() ==# "V" ? "dkP`[V`]":"<up>"
xno <expr> <down> mode() ==# "V" ? "dp`[V`]":"<down>"
xno <expr> <left> mode() ==# "V" ? "<`[V`]":"<left>"
xno <expr> <right> mode() ==# "V" ? ">`[V`]":"<right>"


nnoremap <silent> <q :cnext <CR>
nnoremap <silent> >q :cprevious <CR>

" URL: http://vim.wikia.com/wiki/Example_vimrc
" Authors: http://vim.wikia.com/wiki/Vim_on_Freenode

" Description: A minimal, but feature rich, example .vimrc. If you are a
"              newbie, basing your first .vimrc on this file is a good choice.
"              If you're a more advanced user, building your own .vimrc based
"              on this file is still a good idea.

"------------------------------------------------------------
" Features {{{1
"
" These options and commands enable some very useful features in Vim, that
" no user should have to live without.

" Set 'nocompatible' to ward off unexpected things that your distro might
" have made, as well as sanely reset options when re-sourcing .vimrc
set nocompatible

" Attempt to determine the type of a file based on its name and possibly its
" contents. Use this to allow intelligent auto-indenting for each filetype,
" and for plugins that are filetype specific.
filetype indent plugin on

" Enable syntax highlighting
syntax on


"------------------------------------------------------------
" Must have options {{{1
"
" These are highly recommended options.

" Vim with default settings does not allow easy switching between multiple files
" in the same editor window. Users can use multiple split windows or multiple
" tab pages to edit multiple files, but it is still best to enable an option to
" allow easier switching between files.
"
" One such option is the 'hidden' option, which allows you to re-use the same
" window and switch from an unsaved buffer without saving it first. Also allows
" you to keep an undo history for multiple files when re-using the same window
" in this way. Note that using persistent undo also lets you undo in multiple
" files even in the same window, but is less efficient and is actually designed
" for keeping undo history after closing Vim entirely. Vim will complain if you
" try to quit without saving, and swap files will keep you safe if your computer
" crashes.
set hidden

" Note that not everyone likes working this way (with the hidden option).
" Alternatives include using tabs or split windows instead of re-using the same
" window as mentioned above, and/or either of the following options:
" set confirm
" set autowriteall

" Better command-line completion
set wildmode=longest,list,full
set wildmenu

" Show partial commands in the last line of the screen
set showcmd

" Highlight searches (use <C-L> to temporarily turn off highlighting; see the
" mapping of <C-L> below)
set hlsearch

" Modelines have historically been a source of security vulnerabilities. As
" such, it may be a good idea to disable them and use the securemodelines
" script, <http://www.vim.org/scripts/script.php?script_id=1876>.
" set nomodeline


"------------------------------------------------------------
" Usability options {{{1
"
" These are options that users frequently set in their .vimrc. Some of them
" change Vim's behaviour in ways which deviate from the true Vi way, but
" which are considered to add usability. Which, if any, of these options to
" use is very much a personal preference, but they are harmless.

" Use case insensitive search, except when using capital letters
set ignorecase
set smartcase

" Allow backspacing over autoindent, line breaks and start of insert action
set backspace=indent,eol,start

" When opening a new line and no filetype-specific indenting is enabled, keep
" the same indent as the line you're currently on. Useful for READMEs, etc.
set autoindent

" Stop certain movements from always going to the first character of a line.
" While this behaviour deviates from that of Vi, it does what most users
" coming from other editors would expect.
set nostartofline

" Display the cursor position on the last line of the screen or in the status
" line of a window
set ruler

" Always display the status line, even if only one window is displayed
set laststatus=2

" Instead of failing a command because of unsaved changes, instead raise a
" dialogue asking if you wish to save changed files.
set confirm

" Use visual bell instead of beeping when doing something wrong
set visualbell

" And reset the terminal code for the visual bell. If visualbell is set, and
" this line is also included, vim will neither flash nor beep. If visualbell
" is unset, this does nothing.
set t_vb=

" Enable use of the mouse for all modes
set mouse=a

" Set the command window height to 2 lines, to avoid many cases of having to
" "press <Enter> to continue"
set cmdheight=2

" Display line numbers on the left
set number

" Quickly time out on keycodes, but never time out on mappings
set notimeout ttimeout ttimeoutlen=200

" Use <F11> to toggle between 'paste' and 'nopaste'
set pastetoggle=<F2>


"------------------------------------------------------------
" Indentation options {{{1
"
" Indentation settings according to personal preference.

" Indentation settings for using 4 spaces instead of tabs.
" Do not change 'tabstop' from its default value of 8 with this setup.
set tabstop=8
set shiftwidth=4
set softtabstop=4
set expandtab


