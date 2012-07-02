" Comply with PEP 8 (as far as possible)
setlocal expandtab
setlocal textwidth=79
setlocal tabstop=8
setlocal softtabstop=4
setlocal shiftwidth=4
setlocal autoindent
" setlocal colorcolumn=80
setlocal number

" Set some useful keybindings
nmap <buffer> \s :w<CR>:SyntasticCheck<CR>
nmap <buffer> \p :w<CR>:!python %<CR>
