syntax on
filetype indent plugin on
set modeline
set number
set colorcolumn=80
set background=light
set laststatus=2
hi ColorColumn ctermbg=LightGray
"set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set tabstop=4
set shiftwidth=4
set expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=<:>
nnoremap <F5> :buffers<CR>:buffer<Space>
