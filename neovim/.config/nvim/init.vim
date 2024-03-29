" Plugins will be downloaded under the specified directory.
call plug#begin('~/.local/lib/nvim/')

" Declare the list of plugins.
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'machakann/vim-sandwich', {'branch': 'master'}
Plug 'donRaphaco/neotex', { 'for': 'tex' }
Plug '/usr/bin/fzf'
Plug 'junegunn/fzf.vim'
Plug 'honza/vim-snippets', {'branch': 'master'}
Plug 'lervag/vimtex'
Plug 'Konfekt/FastFold'
Plug 'matze/vim-tex-fold'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'psliwka/vim-smoothie'
Plug 'Shougo/ddc.vim'
Plug 'vim-denops/denops.vim'

" ddc.vim requirements
" Install your UIs
Plug 'Shougo/ddc-ui-native'
" Install your sources
Plug 'Shougo/ddc-source-around'
" Install your filters
Plug 'Shougo/ddc-matcher_head'
Plug 'Shougo/ddc-sorter_rank'


" List ends here. Plugins become visible to Vim after this call.
call plug#end()






let g:neotex_enabled = 2
