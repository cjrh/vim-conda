scriptencoding utf-8

" ------------------------------------------------------------------------
" functions that call python code
" " ------------------------------------------------------------------------
" function! jedi#goto_assignments()
"     Python jedi_vim.goto()
" endfunction
"
" function! jedi#goto_definitions()
"     Python jedi_vim.goto(is_definition=True)
" endfunction
"
" ------------------------------------------------------------------------
" defaults for jedi-vim
" ------------------------------------------------------------------------
" let s:settings = {
"     \ 'use_tabs_not_buffers': 1,
"     \ 'use_splits_not_buffers': 1,
"     \ 'auto_initialization': 1,
"     \ 'auto_vim_configuration': 1,
"     \ 'goto_assignments_command': "'<leader>g'",
"     \ 'completions_command': "'<C-Space>'",
"     \ 'goto_definitions_command': "'<leader>d'",
"     \ 'call_signatures_command': "'<leader>n'",
"     \ 'usages_command': "'<leader>n'",
"     \ 'rename_command': "'<leader>r'",
"     \ 'popup_on_dot': 1,
"     \ 'documentation_command': "'K'",
"     \ 'show_call_signatures': 1,
"     \ 'call_signature_escape': "'=`='",
"     \ 'auto_close_doc': 1,
"     \ 'popup_select_first': 1,
"     \ 'quickfix_window_height': 10,
"     \ 'completions_enabled': 1,
"     \ 'force_py_version': 2
" \ }
"
"
" function! s:init()
"   for [key, val] in items(s:deprecations)
"       if exists('g:jedi#'.key)
"           echom "'g:jedi#".key."' is deprecated. Please use 'g:jedi#".val."' instead. Sorry for the inconvenience."
"           exe 'let g:jedi#'.val.' = g:jedi#'.key
"       end
"   endfor
"
"   for [key, val] in items(s:settings)
"       if !exists('g:jedi#'.key)
"           exe 'let g:jedi#'.key.' = '.val
"       endif
"   endfor
" endfunction
"
"
" call s:init()

" ------------------------------------------------------------------------
" Python initialization
" ------------------------------------------------------------------------

let s:script_path = fnameescape(expand('<sfile>:p:h:h'))

if has('python')
    command! -nargs=1 Python python <args>
    execute 'pyfile '.s:script_path.'/initialize.py'
elseif has('python3')
    command! -nargs=1 Python python3 <args>
    execute 'py3file '.s:script_path.'/initialize.py'
else
    echomsg "Error: vim-conda requires vim compiled with +python"
    finish
end

" vim: set et ts=4:
