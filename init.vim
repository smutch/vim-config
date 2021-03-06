" vim:fdm=marker

" Initialisation {{{

" If we have true color support available
if exists('&termguicolors')
    set termguicolors
endif

" We don't want to mimic vi
set nocompatible

" Set the encoding
set encoding=utf-8

" Deal with gnu screen
if (match($TERM, "screen")!=-1) && !exists('&termguicolors')
    set term=screen-256color
endif

" }}}
" System specific {{{

" Do system specific settings
let os = substitute(system('uname'), "\n", "", "")
let hostname = substitute(system('hostname'), '\n', '', '')

try
    runtime system.vim
catch
endtry
" }}}

" vim-plug {{{
runtime plugins.vim
" }}}

" Basic settings {{{
let mapleader="\<Space>"
let localleader='\'

set history=1000                     " Store a ton of history (default is 20)
set wildmenu                         " show list instead of just completing
set autoread                         " Automatically re-read changed files
set hidden                           " Don't unload a buffer when abandoning it
set mouse=a                          " enable mouse for all modes settings
set clipboard+=unnamedplus           " To work in tmux
set spelllang=en_gb                  " British spelling
set noshowmode                         " Don't show the current mode
" set list                             " Show trailing & tab markers
" set showcmd                          " Show partial command in bottom right

set secure                           " Secure mode for reading vimrc, exrc files etc. in current dir
set exrc                             " Allow the use of folder dependent settings

let g:netrw_altfile = 1              " Prev buffer command excludes netrw buffers

" Use an interactive shell to allow command line aliases to work
" set shellcmdflag=-ic

" I tend to write c rather than c++
let g:c_syntax_for_h = 1

" What to write in sessions
set sessionoptions=blank,buffers,curdir,folds,help,tabpages,winsize,globals

" Indent and wrapping {{{

set backspace=indent,eol,start       " Sane backspace
set autoindent                       " Autoindent
set nosmartindent                    " Turning this off as messes with python comment indents.
set wrap                             " Wrap lines
set linebreak                        " Wrap at breaks
set textwidth=0 wrapmargin=0
set display=lastline
set formatoptions+=l                 " Dont mess with the wrapping of existing lines
set expandtab tabstop=4 shiftwidth=4 " 4 spaces for tabs

" }}}
" Searching {{{
set incsearch                        " Highlight matches as you type
set hlsearch                         " Highlight matches
set showmatch                        " Show matching paren
set ignorecase                       " case insensitive search
set smartcase                        " case sensitive when uc present
set gdefault                         " g flag on sed subs automatically
" set tags+=./tags;$HOME                " recursively search up dir stack for tags file

" Live substitution
if exists('&inccommand')
  set inccommand=nosplit
endif

" Use ripgrep if possible, if not then ack, and fall back to grep if all else fails
if executable('rg')
    set grepprg=set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case\ --trim\ -g\ '!*.ipynb'
elseif executable('ack')
    set grepprg=ack\ -s\ -H\ --nocolor\ --nogroup\ --column
    set grepformat=%f:%l:%c:%m,%f:%l:%m
else
    " Grep will sometimes skip displaying the file name if you
    " search in a singe file. Set grep
    " program to always generate a file-name.
    set grepprg=grep\ -nHRI\ --exclude='*.ipynb'\ $*\ .
endif
nnoremap <leader>* :silent grep! "<C-r><C-w>"<CR>:copen<CR>:redraw!<CR>
command! -nargs=+ -complete=file -bar Grep silent grep! <args>|copen|redraw!
nnoremap <leader>/ :Grep 

" Load up last search in buffer into the location list and open it
nnoremap <leader>l :<C-u>lvim // % \| lopen<CR>

set wildignore+=*.o,*.obj,*.pyc,
            \*.aux,*.blg,*.fls,*.blg,*.fdb_latexmk,*.latexmain,.DS_Store,
            \Session.vim,Project.vim,tags,.tags,.sconsign.dblite,.ccls-cache

" Set suffixes that are ignored with multiple match
set suffixes=.bak,~,.o,.info,.swp,.obj

" handy mapping to fold around previous search results
" taken from http://vim.wikia.com/wiki/Folding_with_Regular_Expression
" \z to show previous search results
" zr to display more context
" zm to display less
function! s:SearchFold()
    if (!exists('b:searchfold_on') || b:searchfold_on==0)
        let b:old_foldexpr = &l:foldexpr
        let b:old_fdm = &l:fdm
        let b:old_foldlevel = &l:foldlevel
        let b:old_foldcolumn = &l:foldcolumn
        setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2
        let b:searchfold_on = 1
    else
        let &l:foldexpr = b:old_foldexpr
        let &l:foldmethod = b:old_fdm
        let &l:foldlevel = b:old_foldlevel
        let &l:foldcolumn = b:old_foldcolumn
        let b:searchfold_on = 0
    endif
endfunction
command! SearchFold call s:SearchFold()
nnoremap <localleader>z :SearchFold<CR>



" }}}
" Backup and swap files {{{
set backupdir=~/.vim_backup
set directory=~/.vim_backup
set undodir=~/.vim/.vim_backup/undo  " where to save undo histories
set undofile                         " Save undo's after file closes
" }}}

" }}}
" Visual settings {{{

" Neovide {{{

set guifont=JetBrainsMono\ Nerd\ Font:h12
let g:neovide_cursor_animation_length=0.07
let g:neovide_cursor_vfx_mode = "railgun"

" }}}
set vb t_vb=                            " Turn off visual beep
set laststatus=2                        " Always display a status line
set cmdheight=1                         " Command line height
set listchars=tab:▸\ ,eol:↵,trail:·     " Set hidden characters
set nonumber                              " Show line numbers
" set cursorline                          " highlight current line

if has("nvim") && exists("+pumblend")
    set pumblend=20                     " opacity for popupmenu
endif

" Colorscheme {{{

function! ReturnHighlightTerm(group, term)
    " taken from https://vi.stackexchange.com/a/12294
    " Store output of group to variable
    let output = execute('hi ' . a:group)

    " Find the term we're looking for
    return matchstr(output, a:term.'=\zs\S*')
endfunction

augroup CustomColors
    au!
    au ColorScheme * hi! link Search DiffAdd
                \| hi! link Conceal NonText
                \| if !match($TERM, "screen") 
                \| hi! Comment cterm=italic gui=italic
                \| endif
    au ColorScheme onedark if &background == 'dark'
                \| hi! Normal guifg=#d9dbda guibg=#263238
                \| hi! TermNormal guibg=#263238
                \| hi! link EndOfBuffer Comment
                \| for group in ['DiffAdd', 'DiffChange', 'DiffDelete', 'DiffText']
                \|   exec 'hi! '.group.' guibg=#2c323c'
                \| endfor
                \| hi! Search guifg=white guibg=#3e4452
                \| hi! IndentBlanklineChar guifg=#2e3c44
                " \| hi! CursorLine guibg=#263238
                " \| nnoremap <leader>cd :hi Normal guibg=<C-R>=(ReturnHighlightTerm('Normal', 'guibg') =~# "#263238") ? '#1a1d23' : '#263238'<CR><CR>
                \| endif
    au ColorScheme tokyonight if &background == 'dark'
                \| hi! Normal guifg=#d9dbda guibg=#263238
                \| hi! NormalNC guifg=#d9dbda guibg=#2e3c44
                \| hi! TermNormal guibg=#263238
                \| hi! Search guifg=white guibg=#3e4452
                \| endif
augroup END

" Properly switch colors {{{
" Taken from: https://github.com/altercation/solarized/issues/102#issuecomment-275269574

if !exists('s:known_links')
  let s:known_links = {}
endif

function! s:Find_links()
  " Find and remember links between highlighting groups.
  redir => listing
  try
    silent highlight
  finally
    redir END
  endtry
  for line in split(listing, "\n")
    let tokens = split(line)
    " We're looking for lines like "String xxx links to Constant" in the
    " output of the :highlight command.
    if len(tokens) == 5 && tokens[1] == 'xxx' && tokens[2] == 'links' && tokens[3] == 'to'
      let fromgroup = tokens[0]
      let togroup = tokens[4]
      let s:known_links[fromgroup] = togroup
    endif
  endfor
endfunction

function! s:Restore_links()
  " Restore broken links between highlighting groups.
  redir => listing
  try
    silent highlight
  finally
    redir END
  endtry
  let num_restored = 0
  for line in split(listing, "\n")
    let tokens = split(line)
    " We're looking for lines like "String xxx cleared" in the
    " output of the :highlight command.
    if len(tokens) == 3 && tokens[1] == 'xxx' && tokens[2] == 'cleared'
      let fromgroup = tokens[0]
      let togroup = get(s:known_links, fromgroup, '')
      if !empty(togroup)
        execute 'hi link' fromgroup togroup
        let num_restored += 1
      endif
    endif
  endfor
endfunction

function! s:AccurateColorscheme(colo_name)
  call <SID>Find_links()
  exec "colorscheme " a:colo_name
  call <SID>Restore_links()
endfunction

command! -nargs=1 -complete=color Cs call <SID>AccurateColorscheme(<q-args>)
" }}}

syntax on " Use syntax highlighting
function! SetTheme()
    " Setting this will turn off the guibg color
	" let g:hybrid_custom_term_colors = 1
    
    let g:hybrid_reduced_contrast = 1
    if (&t_Co >= 256)
        if (exists('g:light') && g:light==1) || (exists('$LIGHT') && $LIGHT==1)
            set background=light
            Cs onedark
            let g:light=1
        else
            set background=dark
            Cs onedark
            " let g:term_bg="#3e4452"

            let g:light=0
        endif
    end
endfunction

command! ToggleTheme let g:light=!g:light | call SetTheme()
nnoremap cot :<C-u>ToggleTheme<CR> 

" use the presence of a file to determine if we want to start in light or dark mode
if !empty(glob(expand("~") . "/.vimlight"))
    let g:light=1
else
    let g:light=0
endif
call SetTheme()

" Neovim terminal colors
if has("nvim")
    let g:terminal_color_0 = "#252525"
    let g:terminal_color_1 = "#d06c76"
    let g:terminal_color_2 = "#99c27c"
    let g:terminal_color_3 = "#FFD740"
    let g:terminal_color_4 = "#40C4FF"
    let g:terminal_color_5 = "#FF4081"
    let g:terminal_color_6 = "#59b3be"
    let g:terminal_color_7 = "#F5F5F5"
    let g:terminal_color_8 = "#708284"
    let g:terminal_color_9 = "#d06c76"
    let g:terminal_color_10 = "#99c27c"
    let g:terminal_color_11 = "#FFD740"
    let g:terminal_color_12 = "#40C4FF"
    let g:terminal_color_13 = "#FF4081"
    let g:terminal_color_14 = "#59b3be"
    let g:terminal_color_15 = "#F5F5F5"
endif

" }}}

" Cursor configuration {{{
" ====================================================================
if !has("nvim")
    let &t_SI = "\<Esc>[5 q"
    if exists("&t_SR")
        let &t_SR = "\<Esc>[3 q"
    endif
    let &t_EI = "\<Esc>[2 q"
endif
" }}}

" }}}
" Highlighting {{{

highlight link CheckWords DiffText

function! MatchCheckWords()
  match CheckWords /\c\<\(your\|Your\|it's\|they're\|halos\|Halos\|reionisation\|Reionisation\)\>/
endfunction

" autocmd FileType markdown,tex,rst call MatchCheckWords()
" autocmd BufWinEnter *.md,*.tex,*.rst call MatchCheckWords()
" autocmd BufWinLeave *.md,*.tex,*.rst call clearmatches()

" }}}
" Custom commands and functions {{{

" Edit remote files locally
command! -nargs=1 F1 execute ':e scp://f1/<args>'

" Remove trailing whitespace
command! TrimWhitespace execute ':%s/\s\+$// | :noh'

" Allow us to move to windows by number using the leader key
let i = 1
while i <= 9
    execute 'nnoremap <Leader>' . i . ' :' . i . 'wincmd w<CR>'
    let i = i + 1
endwhile
function! WindowNumber()
    let str=tabpagewinnr(tabpagenr())
    return str
endfunction

" Allow `e` to be prefixed by a window number to use for the jump
function! QFOpenInWindow()
    if v:count is 0
        .cc
    else
        let s:linenumber = line('.')
        exec v:count . 'wincmd w'
        exec ':' . s:linenumber . 'cc'
    endif
endfunction
autocmd FileType quickfix,qf nnoremap <buffer> e :<C-u>call QFOpenInWindow()<CR>

" CMake
function! s:CMake()
    let src_dir = fnamemodify(findfile('CMakeLists.txt', '.;'), ':p:h')
    let build_dir = finddir('build', '.;')

    if build_dir =~ ""
        let build_dir = src_dir . '/build'
        echo build_dir
        call system('mkdir -p ' . build_dir)
    endif
    let &makeprg = 'make -j2 -C ' . build_dir

    exec 'Dispatch -dir=' . build_dir . ' cmake .. ' . g:cmake_opts
endfunction
command! CMake call <SID>CMake()

" Ctags command
function! GenCtags()
    let s:cmd = ' -R --fields=+iaS --extra=+q'
    if exists("g:Tlist_Ctags_Cmd")
        execute ':!'.g:Tlist_Ctags_Cmd.s:cmd
    else
        execute ':! ctags'.s:cmd
    endif
endfun

" Softwrap
command! SoftWrap execute ':g/./,-/\n$/j'

" Edit rc files
command! Erc execute ':e ~/.config/nvim/init.vim'
command! Ezrc execute ':e ~/.zshrc'
command! Eplug execute ':e ~/.config/nvim/plugins.vim'
command! Elua execute ':e ~/.config/nvim/lua'

" Capture output from a vim command (like :version or :messages) into a split scratch buffer. {{{

" (credit: ctechols, https://gist.github.com/ctechols/c6f7c900b09be5a31dc8)
" Examples:
":Page version
":Page messages
":Page ls
"It also works with the :!cmd command and Ex special characters like % (cmdline-special)
":Page !wc %
"Capture and return the long output of a verbose command.
function! s:Redir(cmd)
   let output = ""
   redir =>> output
   silent exe a:cmd
   redir END
   return output
endfunction

"A command to open a scratch buffer.
function! s:Scratch()
   split Scratch
   setlocal buftype=nofile
   setlocal bufhidden=wipe
   setlocal noswapfile
   setlocal nobuflisted
   return bufnr("%")
endfunction

"Put the output of a command into a scratch buffer.
function! s:Page(command)
   let output = s:Redir(a:command)
   call s:Scratch()
   normal gg
   call append(1, split(output, "\n"))
endfunction

command! -nargs=+ -complete=command Page :call <SID>Page(<q-args>)


" }}}

" make something like <c-l> that does more than just redraw the screen
nnoremap <leader>L :nohlsearch<cr>:diffupdate<cr>:syntax sync fromstart<cr><c-l>

" scrach buffers (taken from
" <http://dhruvasagar.com/2014/03/11/creating-custom-scratch-buffers-in-vim>)
function! ScratchEdit(cmd, options)
    exe a:cmd tempname()
    setl buftype=nofile bufhidden=wipe nobuflisted
    if !empty(a:options) | exe 'setl' a:options | endif
endfunction
command! -bar -nargs=* Sedit call ScratchEdit('edit', <q-args>)
command! -bar -nargs=* Ssplit call ScratchEdit('split', <q-args>)
command! -bar -nargs=* Svsplit call ScratchEdit('vsplit', <q-args>)
command! -bar -nargs=* Stabedit call ScratchEdit('tabe', <q-args>)

" store the current directory into register d
command! GrabPWD let @d = system("pwd")

" }}}
" Keybindings {{{

imap <C-@> <C-Space>

" Quick escape from insert mode
inoremap kj <ESC>

" Quick switch to directory of current file
nnoremap gcd :lcd %:p:h<CR>:pwd<CR>

" Quickly create a file in the directory of the current buffer
nmap <leader>e :<C-u>e <C-R>=expand("%:p:h") . "/" <CR>

" Leave cursor at end of yank after yanking text with lowercase y in visual 
" mode
vnoremap y y`>

" Make Y behave like other capital
nnoremap Y y$

" Easy on the fingers save and window manipulation bindings
nnoremap <leader>s :w<CR>
nnoremap <leader>w <C-w>

" Fit window height to contents and fix
command! SqueezeWindow execute('resize ' . line('$') . ' | set wfh')

" Toggle to last active tab
let g:lasttab = 1
nnoremap <CR>t :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Switch back to alternate file
nnoremap <CR><CR> <C-S-^>

" Disable increment number up / down - *way* too dangerous...
nmap <C-a> <Nop>
nmap <C-x> <Nop>

" Turn off highlighting
noremap \| <Esc>:<C-u>noh<CR>

" Paste without auto indent
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

" Toggle auto paragraph formatting
nnoremap coa :set <C-R>=(&formatoptions =~# "aw") ? 'formatoptions-=aw' : 'formatoptions+=aw'<CR><CR>

" Reformat chunks (chunks are defined per filetype basis in after/ftplugin)
" nmap ,; gwic
" nmap ,: gwac

" {{{ terminal
" Neovim terminal mappings and settings
if has('nvim')
    let $LAUNCHED_FROM_NVIM = 1
    augroup MyTerm
        au!
        au BufWinEnter,WinEnter,TermOpen term://* startinsert 
        au TermOpen * setlocal winhighlight=Normal:TermNormal |
                    \ setlocal nocursorline nonumber norelativenumber
    augroup END

    tnoremap kj <C-\><C-n>
    tnoremap <C-h> <C-\><C-n><C-w>h
    tnoremap <C-j> <C-\><C-n><C-w>j
    tnoremap <C-k> <C-\><C-n><C-w>k
    tnoremap <C-l> <C-\><C-n><C-w>l
    tnoremap <C-w> <C-\><C-n><C-w>
    nnoremap <A-h> <C-w>h
    nnoremap <A-j> <C-w>j
    nnoremap <A-k> <C-w>k
    nnoremap <A-l> <C-w>l
endif
" }}}

" }}}
" Autocommands {{{

" Scons files
au BufNewFile,BufRead SConscript,SConstruct set filetype=scons
" set makeprg=scons

" cython files
au BufRead,BufNewFile *.pxd,*.pxi,*.pyx set filetype=cython

" slurm files
au BufRead,BufNewFile *.slurm set filetype=slurm

" Trim trailing whitespace when saving python file
autocmd BufWritePre *.py normal m`:%s/\s\+$//e``

" enable spell checking on certain files
autocmd BufNewFile,BufRead COMMIT_EDITMSG set spell |
            \ setlocal nofoldenable

" pandoc
augroup pandoc_syntax
    au! BufNewFile,BufFilePre,BufRead *.md set filetype=markdown.pandoc |
                \ setlocal cole=0
augroup END

" Automatically reload vimrc when it's saved
" augroup AutoReloadVimRC
"   au!
"   au BufWritePost $MYVIMRC so $MYVIMRC
" augroup END

" If we have a wide window then put the preview window on the right
au BufAdd * if &previewwindow && &columns >= 160 && winnr("$") == 2 | silent! wincmd L | endif

" web related languages
autocmd FileType javascript,coffee,html,css,scss,sass setlocal ts=2 sw=2

" make sure all tex files are set to correct filetype
autocmd BufNewFile,BufRead *.tex set ft=tex

" make sure pbs scripts are set to the right filetype
autocmd BufNewFile,BufRead *.{qsub,pbs} set ft=sh

" set marks to jump between header and source files
autocmd BufLeave *.{c,cpp,cc} mark C
autocmd BufLeave *.{h,hpp,hh} mark H

" }}}
" Treesitter {{{

lua require('treesitter')

" }}}
" Plugin settings {{{

lua require('misc')

" auto-pairs {{{

let g:AutoPairsFlyMode = 0
let g:AutoPairsShortcutToggle = ''
let g:AutoPairsShortcutBackInsert = '<A-b>'

" }}}
" bbye {{{

nnoremap Q :Bdelete<CR>

" }}}
" compe {{{

" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use ctrl-space for manual completion
inoremap <silent><expr> <C-Space> compe#complete()

" Set completeopt to have a better completion experience
set completeopt=menuone,noinsert,noselect

" Avoid showing message extra message when using completion
set shortmess+=c

" }}}
" dispatch {{{

let g:dispatch_compilers = {
      \ 'markdown': 'doit',
      \ 'python': 'python %'}

" remove iterm from the list of handlers (don't like it removing focus when run)
let g:dispatch_handlers = ['tmux', 'screen', 'windows', 'x11', 'headless']

" }}}
" easy-align {{{

vmap <Enter> <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" }}}
" echodoc {{{

" N.B. ensure noshowmode has been set above
let g:echodoc_enable_at_startup = 0
let g:echodoc#type = "floating"

" }}}
" float-preview {{{

let g:float_preview#docked = 0

" }}}
" fugitive {{{

" Useful shortcut for git commands
nnoremap git :Git
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>ga :Git commit -a<CR>
nnoremap <leader>gd :Git diff<CR>
nnoremap <leader>gm :Git merge<CR>
nnoremap <leader>gP :Git pull<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gf :Git fetch<CR>
nnoremap <leader>gg :Git grep<CR>
nnoremap <leader>gw :Git write<CR>
nnoremap <leader>gr :Git read<CR>
nnoremap <leader>gb :Git blame<CR>

" }}}
" fzf {{{

" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-o': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
" - window (nvim only)
let g:fzf_layout = { 'up': '~40%' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" For Commits and BCommits to customize the options used by 'git log':
let g:fzf_commits_log_options = '--graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

" Mappings and commands
nmap <leader>fm <plug>(fzf-maps-n)
xmap <leader>fm <plug>(fzf-maps-x)
omap <leader>fm <plug>(fzf-maps-o)

" redefine some commands to use the preview feature
" command! -bang -nargs=* -complete=file Files call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
" command! -bang -nargs=* -complete=dir Ag call fzf#vim#ag(<q-args>, fzf#vim#with_preview(), <bang>0)
" command! -bang History call fzf#vim#history(fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>ff :Files %:p:h<CR>
nnoremap <leader>fhf :History<CR>
nnoremap <leader>fh: :History:<CR>
nnoremap <leader>fh/ :History/<CR>
nnoremap <leader>f: :Commands<CR>
nnoremap <leader>fw :Windows<CR>
nnoremap <leader>fs :Snippets<CR>
nnoremap <leader>f? :Helptags<CR>
nnoremap <leader>fg :GitFiles?<CR>
nnoremap <leader>fl :Lines<CR>
nnoremap <leader>fL :BLines<CR>
nnoremap <leader>ft :Tags<CR>
nnoremap <leader>fT :BTags<CR>
nnoremap <leader>f/ :Rg<CR>

imap <c-x><c-k> <plug>(fzf-complete-word)
imap <c-x><c-f> <plug>(fzf-complete-path)
imap <c-x><c-j> <plug>(fzf-complete-file-ag)
imap <c-x><c-l> <plug>(fzf-complete-line)

" project files
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
" command! -bang FZFProjectFiles call fzf#vim#files(s:find_git_root(), fzf#vim#with_preview(), <bang>0)
command! -bang FZFProjectFiles call fzf#vim#files(s:find_git_root(), <bang>0)
nnoremap <leader>fp :FZFProjectFiles<CR>

" floating fzf
" taken from https://github.com/junegunn/fzf.vim/issues/664#issuecomment-564267298
if has('nvim')
  let $FZF_DEFAULT_OPTS .= ' --layout=reverse'

  function! FloatingFZF()
    let height = &lines
    let width = float2nr(&columns - (&columns * 2 / 10))
    let col = float2nr((&columns - width) / 2)
    let col_offset = &columns / 10
    let opts = {
          \ 'relative': 'editor',
          \ 'row': 1,
          \ 'col': col + col_offset,
          \ 'width': width * 2 / 1,
          \ 'height': height / 2,
          \ 'style': 'minimal'
          \ }
    let buf = nvim_create_buf(v:false, v:true)
    let win = nvim_open_win(buf, v:true, opts)
    call setwinvar(win, '&winhl', 'NormalFloat:TabLine')
  endfunction

  let g:fzf_layout = { 'window': 'call FloatingFZF()' }
endif

" }}}
" galaxyline {{{

lua require('statusline')

" }}}
" gitgutter {{{

let g:gitgutter_map_keys = 0
autocmd BufNewFile,BufRead /Volumes/* let g:gitgutter_enabled = 0
nnoremap ]h :GitGutterNextHunk<CR>
nnoremap [h :GitGutterPrevHunk<CR>
nnoremap ghs :GitGutterStageHunk<CR>
nnoremap ghr :GitGutterRevertHunk<CR>
nnoremap ghp :GitGutterPreviewHunk<CR>
let g:gitgutter_realtime = 0
let g:gitgutter_sign_priority = 9

let g:gitgutter_sign_added = ''
let g:gitgutter_sign_modified = ''
let g:gitgutter_sign_removed = ''
let g:gitgutter_sign_modified_removed = '⊝'

" }}}
" goyo {{{

let g:goyo_width = 82

" }}}
" {{{ gutentags

let g:gutentags_resolve_symlinks = 0
let g:gutentags_project_root = [".tagme"]
let g:gutentags_ctags_tagfile = ".tags"
let g:gutentags_enabled = 1

let g:gutentags_ctags_extra_args = ['--c++-kinds=+p', '--c-kinds=-p', '--fields=+iaS', '--extra=+q']
let g:gutentags_ctags_exclude = ['build']

" }}}
" indent-blankline {{{

    let g:indent_blankline_char = '│'

" }}}
" jedi {{{

" ---
" UNCOMMENT TO DISABLE
" let g:jedi#auto_initialization = 0
" ---

" These two are required for neocomplete
" let g:jedi#completions_enabled = 0
" let g:jedi#auto_vim_configuration = 0

" Ensure conda paths are being used (see https://github.com/cjrh/vim-conda/issues/15)
" let s:custom_sys_paths = system('~/miniconda3/bin/python -c "import sys; print(sys.path)"') 
" py3 << EOF
" import vim, sys, ast
" sys.path.extend(ast.literal_eval(vim.eval("s:custom_sys_paths")))
" EOF

" let g:jedi#force_py_version = 3
" let g:jedi#popup_on_dot = 0
" let g:jedi#show_call_signatures = 2  "May be too slow...
" let g:jedi#auto_close_doc = 0
" autocmd FileType python let b:did_ftplugin = 1
" let g:jedi#goto_stubs_command = '<localleader>s'
" let g:jedi#goto_assignments_command = '<localleader>g'
" let g:jedi#goto_command = '<localleader>d'
" let g:jedi#rename_command = '<localleader>r'
" let g:jedi#usages_command = '<localleader>u'

" move documentation to the right if the window is big enough
" au BufAdd * if bufname(expand('<afile>')) ==# "'__doc__'" | silent! wincmd L | endif

" close the documentation window
" autocmd FileType python nnoremap <buffer> <localleader>D :exec bufwinnr('__doc__') . "wincmd c"<CR>

" }}}
" lightspeed {{{
" These dummy mappings prevent lightspeed from implementing multi-line f/F/t/F
" jumps and breaking ; and ,
nmap f f
nmap F F
nmap t t
nmap T T
" }}}
" matchit {{{

if !exists('g:loaded_matchit')
  runtime macros/matchit.vim
endif

" }}}
" miniyank {{{

map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)
map <leader>ys <Plug>(miniyank-startput)
map <leader>yS <Plug>(miniyank-startPut)
map <leader>yn <Plug>(miniyank-cycle)
map <leader>yN <Plug>(miniyank-cycleback)

function FZFYankList() abort
  function! KeyValue(key, val)
    let line = join(a:val[0], '\n')
    if (a:val[1] ==# 'V')
      let line = '\n'.line
    endif
    return a:key.' '.line
  endfunction
  return map(miniyank#read(), function('KeyValue'))
endfunction

function FZFYankHandler(opt, line) abort
  let key = substitute(a:line, ' .*', '', '')
  if !empty(a:line)
    let yanks = miniyank#read()[key]
    call miniyank#drop(yanks, a:opt)
  endif
endfunction

command! YanksAfter call fzf#run(fzf#wrap('YanksAfter', {
\ 'source':  FZFYankList(),
\ 'sink':    function('FZFYankHandler', ['p']),
\ 'options': '--no-sort --prompt="Yanks-p> "',
\ }))

command! YanksBefore call fzf#run(fzf#wrap('YanksBefore', {
\ 'source':  FZFYankList(),
\ 'sink':    function('FZFYankHandler', ['P']),
\ 'options': '--no-sort --prompt="Yanks-P> "',
\ }))

map <leader>yp :YanksAfter<CR>
map <leader>yP :YanksBefore<CR>

" }}}
" neoterm {{{

let g:neoterm_automap_keys = '<LocalLeader>t'
nnoremap <Leader>tv :vert Tnew<CR><Esc>
nnoremap <Leader>ts :below Tnew<CR><Esc>
nnoremap <Leader>tt :Tnew<CR><Esc>
nnoremap <Leader>tm :Tmap 
nnoremap <Leader>to :Topen<CR><Esc>

" }}}
" nerd_commenter {{{

" Custom NERDCommenter mappings
let g:NERDCustomDelimiters = {
            \ 'scons': { 'left': '#' },
            \ 'jinja': { 'left': '<!--', 'right': '-->' },
            \ }

let g:NERDSpaceDelims = 1
let g:NERDAltDelims_c = 1
map <leader><leader> <plug>NERDCommenterToggle
nnoremap <leader>cp yy:<C-u>call NERDComment('n', 'comment')<CR>p
nnoremap <leader>cP yy:<C-u>call NERDComment('n', 'comment')<CR>P
vnoremap <leader>cp ygv:<C-u>call NERDComment('x', 'comment')<CR>`>p
vnoremap <leader>cP ygv:<C-u>call NERDComment('x', 'comment')<CR>`<P

" }}}
" note-system {{{

let g:notes_dir = '~/Dropbox/Notes'
let g:notes_assets_dir = 'img'

" }}}
" nvim-lsp {{{

lua require('lsp')

" }}}
" polyglot {{{

 let g:polyglot_disabled = ['tex', 'latex', 'python']

" }}}
" surround {{{

" Extra surround mappings for particular filetypes

" Markdown
autocmd FileType markdown let b:surround_109 = "\\\\(\r\\\\)" "math
autocmd FileType markdown let b:surround_115 = "~~\r~~" "strikeout
autocmd FileType markdown let b:surround_98 = "**\r**" "bold
autocmd FileType markdown let b:surround_105 = "*\r*" "italics

" }}}
" taboo {{{

let g:taboo_tab_format=" %I %f%m "
let g:taboo_renamed_tab_format=" %I %l%m "

" }}}
" tagbar {{{

nnoremap <leader>T :TagbarToggle<CR>

" }}}
" ultisnips {{{

let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsExpandTrigger = '<C-k>'
let g:UltiSnipsJumpForwardTrigger = '<C-k>'
let g:UltiSnipsJumpBackwardTrigger = '<C-j>'
let g:ultisnips_python_style = 'numpy'

" }}}
" vimtex {{{

" Latex options
let g:vimtex_compiler_latexmk = {
            \ 'build_dir' : './build',
            \}
let g:vimtex_quickfix_mode = 0
let g:vimtex_view_method = 'skim'
let g:vimtex_fold_enabled = 1
let g:vimtex_compiler_progname='nvr'

" Quick map for adding a new item to an itemize environment list
au FileType tex call vimtex#imaps#add_map({
  \ 'lhs' : '<A-CR>',
  \ 'rhs' : '\item ',
  \ 'leader' : '',
  \ 'wrapper' : 'vimtex#imaps#wrap_environment',
  \ 'context' : ["itemize", "enumerate"],
  \})

" }}}
" vimux {{{

 " Run the current file with python
 augroup vimux
     au!
     au FileType python nnoremap <buffer> <LocalLeader>v :call VimuxRunCommand("clear; python " . bufname("%"))<CR>
 augroup END

 " Prompt for a command to run
 map <Leader>vc :VimuxPromptCommand<CR>

 " Run last command executed by VimuxRunCommand
 map <Leader>vl :VimuxRunLastCommand<CR>

 " Inspect runner pane
 map <Leader>vi :VimuxInspectRunner<CR>

 " Close vim tmux runner opened by VimuxRunCommand
 map <Leader>vq :VimuxCloseRunner<CR>

 " Interrupt any command running in the runner pane
 map <Leader>vx :VimuxInterruptRunner<CR>

 " Zoom the runner pane (use <bind-key> z to restore runner pane)
 map <Leader>vz :call VimuxZoomRunner()<CR>

 function! VimuxSlime()
  call VimuxSendText(@v)
  " call VimuxSendKeys("Enter")
 endfunction

 " If text is selected, save it in the v buffer and send that buffer it to tmux
 vnoremap <Leader>vs "vy :call VimuxSlime()<CR>

 " Select current paragraph and send it to tmux
 nnoremap <Leader>vs vip"vy :call VimuxSlime()<CR>

 " Select current line and send it to tmux
 nnoremap <Leader>vS ^v$"vy :call VimuxSlime()<CR>

 " Call OpenRunner to assign pane if not already
 nnoremap <Leader>vo :call VimuxOpenRunner()<CR>

 function! VimuxIPython()
     call VimuxSendText("%cpaste")
     call VimuxSendKeys("Enter")
     call VimuxSendText(@v."--")
     " call VimuxSendKeys("Enter")
 endfunction

 " If text is selected, save it in the v buffer and send that buffer it to ipython
 vnoremap <Leader>vi "vy :call VimuxIPython()<CR>

 " Select current paragraph and send it to ipython
 nnoremap <Leader>vi vip"vy :call VimuxIPython()<CR>

" }}}
" }}}
" post plugin setup {{{

lua require'colorizer'.setup()

" }}}
