
" PLUGINS
"
" Make sure you use single quotes
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
call plug#end()

" COLORS & font
"
" Note that our gruvbox is modified for a better "Folded" color scheme
let g:gruvbox_contrast_dark = 'medium'
let g:gruvbox_italic=1
autocmd vimenter * colorscheme gruvbox
set termguicolors
set background=dark
set guifont=Source\ Code\ Pro\ Regular\ 9

" airline symbols
let g:airline_symbols = {}
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ':'
let g:airline_symbols.maxlinenr = ''


" FOLDING
"
runtime kent-programming.vim
runtime kent-folding.vim
noremap <C-Right> :Foldenter<CR>
noremap <C-Left> :Foldexit<CR>
noremap <C-Down> :foldopen<CR>
noremap <C-Up> :foldclose<CR>
noremap <M-Right> :Foldcreateauto<CR>
noremap <M-Left> :Folddel<CR>
noremap <M-Down> :Foldcreate<CR>


" Smart word wrapping
set linebreak
set wrap
set nolist

" Prevent automatically inserting line breaks
set textwidth=0
set wrapmargin=0

" Extra
set guioptions-=T   " No toolbar
set guioptions-=r   " No scrollbar
set visualbell
set antialias


