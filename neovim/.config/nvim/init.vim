" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/lib/nvim/')

" Declare the list of plugins.
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'machakann/vim-sandwich', {'branch': 'master'}
Plug 'donRaphaco/neotex', { 'for': 'tex' }
Plug '/usr/bin/fzf'
Plug 'junegunn/fzf.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'honza/vim-snippets', {'branch': 'master'}
Plug 'lervag/vimtex'
Plug 'Konfekt/FastFold'
Plug 'matze/vim-tex-fold'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'


" List ends here. Plugins become visible to Vim after this call.
call plug#end()


let g:deoplete#enable_at_startup = 1
let g:airline_powerline_fonts = 1
let g:neotex_enabled = 2
