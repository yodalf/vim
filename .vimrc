" Make sure you use single quotes
call plug#begin('~/.vim/plugged')
Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

"{{{  Test
" airline
let g:airline_symbols = {}
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ':'
let g:airline_symbols.maxlinenr = ''
"}}}

" COLORS & font
"
" Note that our gruvbox is modified for a better "Folded" color scheme
set termguicolors
set background=dark
set guifont=Source\ Code\ Pro
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_italic=1
let g:gruvbox_invert_selection=0
autocmd vimenter * colorscheme gruvbox
autocmd vimenter * AirlineTheme gruvbox

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

" Extra for gvim
set guioptions-=T   " No toolbar
set guioptions-=r   " No scrollbar
set visualbell

" Tabstops replaced with spaces
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab

" Ensure right-click always brings the pop-up menu
set mousemodel=popup

" Initial window size
"set lines=50 columns=120

" Set scripts to be executable from the shell
autocmd BufWriteCmd * if ( getline(1) =~ '^#!' || getline(1) =~ '/bin/' || &filetype == 'sh') | silent execute '!chmod a+x <afile>' | endif

