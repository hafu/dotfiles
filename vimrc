syntax on
filetype indent plugin on
set modeline
set number
set colorcolumn=80
set background=light
set laststatus=2
set spell
hi ColorColumn ctermbg=LightGray
"set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab
set tabstop=4
set shiftwidth=4
set expandtab
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab indentkeys-=<:>
nnoremap <F5> :buffers<CR>:buffer<Space>

" http://vim.wikia.com/wiki/Pretty-formatting_XML
function! DoPrettyXML()
  " save the filetype so we can restore it later
  let l:origft = &ft
  set ft=
  " delete the xml header if it exists. This will
  " permit us to surround the document with fake tags
  " without creating invalid xml.
  1s/<?xml .*?>//e
  " insert fake tags around the entire document.
  " This will permit us to pretty-format excerpts of
  " XML that may contain multiple top-level elements.
  0put ='<PrettyXML>'
  $put ='</PrettyXML>'
  silent %!xmllint --format -
  " xmllint will insert an <?xml?> header. it's easy enough to delete
  " if you don't want it.
  " delete the fake tags
  2d
  $d
  " restore the 'normal' indentation, which is one extra level
  " too deep due to the extra tags we wrapped around the document.
  silent %<
  " back to home
  1
  " restore the filetype
  exe "set ft=" . l:origft
endfunction
command! PrettyXML call DoPrettyXML()
