" setlocal tw=80 fo=cqt wm=0 colorcolumn=80
" let b:wrapToggleFlag=1

" let g:solarized_contrast="normal"
" let g:solarized_visibility="low"

" set lbr
setlocal spell 
" if has("gui_macvim")
    " setlocal background=light
    " let g:Powerline_colorscheme = "solarizedLight"
    " call Pl#ReloadColorscheme()
    " colorscheme colorful
" end

" Allow the wrapping to mess with existing lines
setlocal formatoptions-=l

nnoremap <buffer> <leader>m :silent !open -a Marked\ 2.app '%:p'<cr>
nnoremap <buffer> <leader>M :silent !paver -f $HOME/bin/pavement.py pandoc_github '%:p'<cr>

setlocal conceallevel=0 "Prevents annoyances when using $$ style (pandoc) math

syn match markdownIgnore "\$\+.\{-}\n*.\{-}\$\+" "Don't use italics with underscore in math

" If writing a list, pressing enter will start new bullet
setlocal comments-=fb:-
setlocal comments+=nb:-\ [\ ]
setlocal comments+=nb:-
setlocal fo+=ro

" set tabs to 2 spaces
set expandtab tabstop=2 shiftwidth=2
