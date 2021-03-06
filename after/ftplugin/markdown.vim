setlocal foldlevel=99
setlocal concealcursor=nc

" text width
setlocal tw=80 wm=0

" when pressing enter within a task it creates another task
setlocal comments-=fb:-
setlocal comments+=nb:-\ [\ ],nb:-
setlocal comments-=fb:*
setlocal comments+=nb:*
setlocal fo+=ro

" don't auto wrap and use visual linewise motions
set fo-=t
set fo-=c
nnoremap <buffer> $ g$
nnoremap <buffer> 0 g0
nnoremap <buffer> j gj
nnoremap <buffer> k gk

" abbreviations
ab <buffer> -[] - [ ]

" -------------------------------------------------------

" Only do the following when not done yet for this buffer
if exists("b:did_md_extras")
    if b:did_md_extras == 1
        finish
    endif
endif

nnoremap <buffer> <localleader>m :silent !open -a Marked\ 2.app '%:p'<cr>

" focus on outline fold
nnoremap zp zMzvzczO

" convert address to link
nmap <buffer> <localleader>l yiWysiW]f]a(<ESC>pa)<ESC>

" Quick map for adding a new item to a list at the same level
imap <buffer> ;; <CR>-<Space><C-d>

let s:show_tags_flag = 0

nnoremap <buffer> <tab> :call CycleState()<cr>
nnoremap <buffer> + :call CycleType()<cr>
nnoremap <buffer> <LocalLeader>na :call ArchiveTasks()<cr>

function! CycleState()
    let line = getline('.')
    if line =~ "\\(@todo\\|^ *- \\[ \\]\\)"
        call s:cycle_todo(0)
    elseif line =~ "\\(^ *- \\[x\\]\\|@done\\)"
        call s:cycle_done()
    elseif line =~ "\\(@cancelled\\|^ *- X \\)"
        call s:cycle_cancelled()
    endif
endfunction

function! CycleType()
    let line = getline('.')
    if line =~ "^ *$"
        call s:cycle_empty()
    elseif line =~ "^ *[\*-] \\(\\[[ x]\\]\\|X\\)\\@\!"
        call s:cycle_bullet()
    elseif line =~ "^ *[\*-] \\(\\[[ x]\\]\\|X\\)"
        call s:cycle_todo(1)
    endif
endfunction

function! s:cycle_empty()
    normal! $xA* 
    normal! $
endfunction

function! s:cycle_bullet()
    .s/\(^ *[\*-]\)/- \[ \]/
endfunction

function! s:cycle_done()
    silent! .s/^\( *\)- \[x\]/\1- X/
    silent! .s/ *@done.*$//
    let text = " @cancelled (" . strftime("%Y-%m-%d %H:%M") .")"
    exec "normal! A" . text
    normal! _
endfunc

function! s:cycle_todo(flag)
    if a:flag == 0
        silent! .s/^\( *\)- \[ \]/\1- \[x\]/
        silent! .s/ *@todo *//
        let text = " @done (" . strftime("%Y-%m-%d %H:%M") .")"
        exec "normal! A" . text
        normal! _
    elseif a:flag == 1
        silent! .s/^\( *[-*]\) \(\[[ x]\]\|X\)/\1/
        silent! .s/ *@done.*$//
        silent! .s/ *@cancelled.*$//
    else
        return
    endif
endfunc

function! s:cycle_cancelled()
    .s/^\( *\)- X/\1- \[ \]/
    .s/ *@cancelled.*$//
endfunc

function! ArchiveTasks()
    let orig_line=line('.')
    let orig_col=col('.')
    let archive_start = search("^# Archive")
    if (archive_start == 0)
        call cursor(line('$'), 1)
        normal! 2o
        normal! o--------------------------
        normal! o
        normal! o# Archive
        normal! o
        normal! 0D
        let archive_start = line('$') - 1
    endif
    call cursor(1,1)

    let found=0
    let a_reg = @a
    let @a = ""
    if search("[-\\*] \\[x\\]", "", archive_start) != 0
        call cursor(1,1)
        while search("[-\\*] \\[x\\]", "", archive_start) > 0
            if (found == 0)
                normal! "add
            else
                normal! "Add
            endif
            let found = found + 1
            call cursor(1,1)
        endwhile

        call cursor(archive_start + 1,1)
        normal! "ap
    endif

    "clean up
    let @a = a_reg
    call cursor(orig_line, orig_col)
endfunc

function! Separator()
    let line = getline('.')
    if line =~ "^-*$"
      return "--------------------------"
    else
      return "---"
    end
endfunc

function! s:OpenSearchFolds(e)
    let s:show_tags_flag = 1
    let s:old_fold_expr = &foldexpr
    let s:old_foldminlines = &foldminlines
    let s:old_foldtext = &foldtext
    let s:old_foldlevel = &foldlevel
    let s:old_fillchars = &fillchars
    let regex = '\\('.a:e.'\\\\|^#\\)'
    " exec "setlocal foldexpr=(getline(v:lnum)=~'".regex."')?0:1"
    exec "setlocal foldexpr=(getline(v:lnum)=~'".regex."')?0:(getline(v:lnum-1)=~'".regex."')\\|\\|(getline(v:lnum+1)=~'".regex."')?1:2"
    setlocal foldlevel=0 fml=0 foldtext='\ ' fillchars="fold: "
endfunction

function! s:VimGrepKW(e)
    exec "normal! :lvimgrep /" . a:e . "/ %\<CR>:lopen\<CR>"
endfunction

function! ShowTags(grepflag)
    if (s:show_tags_flag == 1)
        let &l:foldexpr = s:old_fold_expr
        let s:show_tags_flag = 0
        let &l:foldminlines = s:old_foldminlines
        let &l:foldtext = s:old_foldtext
        let &l:foldlevel = s:old_foldlevel
        let &l:fillchars = s:old_fillchars
        return
    endif

    let word = expand("<cWORD>")
    let regexp = '@\w\+'

    let sink = '<SID>OpenSearchFolds'
    if a:grepflag == 1
        let sink = '<SID>VimGrepKW'
    endif

    if word =~ regexp
        exec 'call '.sink.'(word)'
    else
        call fzf#run({
                    \   'source':  'grep --line-buffered --color=never -roh "' . regexp . '" ' . fnameescape(@%) . ' | sort | uniq',
                    \   'sink': function(sink)
                    \ })
    endif
endfunction

nnoremap <buffer><silent> <Localleader>nt :call ShowTags(1)<CR>
nnoremap <buffer><silent> <Localleader><Localleader> :call ShowTags(0)<CR>

function! OutlineFolding(linenum)
    " deal first with headings...
    let line = getline(a:linenum)
    if line =~ '^\s*$'
        " ignore empty lines
        return '='
    elseif line =~ '^#'
        " use the number of # to set level
        return '>'.matchend(line, '^#\+')
    endif

    " " now deal with indents...
    let indent = indent(a:linenum) / &tabstop
    let indentBelow = indent(a:linenum + 1) / &tabstop
    if indentBelow > indent
        return "a1"
    elseif indentBelow < indent
        " return "<" . indent
        return "s1"
    else
        return "="
    endif
endfunction

" set foldexpr=OutlineFolding(v:lnum)
" set foldmethod=expr

let b:did_md_extras = 1
