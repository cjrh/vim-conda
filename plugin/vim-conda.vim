" vim-conda
" Version: 0.0.2
" Caleb Hattingh
" Revised by John D. Fisher
" MIT Licence

" This is currently hard-coded and is therefore bad. I
" need some help figure out how to make it user-defined.
set wildcharm=<Tab>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use python3 or python depending on which is in $PATH for when vim is
" compiled with dynamic python.
" from http://stackoverflow.com/questions/8805247/compatible-way-to-use-either-py-or-py3-in-vim
" Doesn't work very well for dynamic python since both will show true but only
" one will work for a given session.
" Vim's python's will not switch dll's to match the conda env selected.
" If started from other than root env, Vim will not find the python dll unless
" Vim is started from the directory in which the dll resides.  This is
" probably a python dynamic issue but haven't tested with a static version.
" TODO: Don't know good way to test for python version without activating it,
" which means the other one won't run. Doesn't prevent switching back and
" forth between python2 and python3 since default python remains at end of
" $PATH, and :!python works as expected. Using Python avoids the error E887
" but jedi might get confused linting python2 when jedi is running in python3.
if !has('python3') && !has('python')
    finish
endif
if has("python3")
    command! -nargs=* Python python3 <args>
    command! -nargs=* Pyfile py3file <args>
else
    command! -nargs=* Python python <args>
    command! -nargs=* Pyfile pyfile <args>
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Global code for Python
"Python import vimconda
" Add the plugin directory to sys.path for import vimconda
Python import vim
Python if vim.eval('expand("<sfile>:p:h")') not in sys.path: sys.path.append(vim.eval('expand("<sfile>:p:h")'))
Python import vimconda
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:SetCondaPlainPath()
    Python vimconda.setcondaplainpath()
    return l:temppath
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


function! s:CondaActivate(envname, envpath, envsroot)
    " Set environment variables $PATH and $CONDA_DEFAULT_ENV
    let $CONDA_DEFAULT_ENV = a:envname
    if has("win32") || has("win64")
        " TODO: Doesn't include Lirary/mingw-w64/bin, but this may only be
        " issue for activate.bat, which uses it to run bash scripts. win32
        " and win64 would have to split if added.
        let $PATH = a:envpath . ';' . a:envpath . '\Scripts' .';' . a:envpath . '\Library\bin' .';' . g:conda_plain_path
    elseif has("unix")
        let $PATH = a:envpath . '/bin' .  ':' . g:conda_plain_path
    endif
    Python vimconda.condaactivate()
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:CondaDeactivate()
    " Reset $PATH back to what it was at startup, and unset $CONDA_DEFAULT_ENV
    " TODO: Maybe deactivate should really give us `g:conda_plain_path`?
    "       `g:conda_startup_path` would contain env stuff IF vim was started
    "       from inside a conda env..
    let $CONDA_DEFAULT_ENV = g:conda_startup_env
    let $PATH = g:conda_startup_path
    Python vimconda.condadeactivate()
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


function! Conda_env_input_callback(A,L,P)
    " This is the callback for the `input()` function.
    " g:condaenvs will be assigned values inside `s:CondaChangeEnv()`
    return g:condaenvs
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" STARTUP
"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This only runs when the script loads
if !exists("g:conda_startup_path")
    let g:conda_startup_path = $PATH
    " If vim is started from inside a conda path, this variable will
    " contain the path WITHOUT the extra conda env bits. Storing this
    " allows us to change conda envs internally inside vim without
    " carrying around any startup baggage in $PATH, if vim was started
    " from a terminal that already had a conda env activated.
    let g:conda_plain_path = s:SetCondaPlainPath()
    " Load all the required Python stuff at startup. These functions
    " get called from other places.
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Python <<EOF relocated to top of vimconda.py, which is imported above.
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setting global paths - We use these to switch between conda envs.
" Python <<EOF relocated to top of vimconda.py
if exists("$CONDA_DEFAULT_ENV")
    " This is happening at script startup. It looks like a conda env
    " was already activated before launching vim, so we need to make
    " the required changes internally.
    let g:conda_startup_env = $CONDA_DEFAULT_ENV
    " This may get overridden later if the default env was in fact
    " a prefix env.
    let g:conda_startup_was_prefix = 0
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    Python vimconda.conda_startup_env()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
else
    let g:conda_startup_env = ""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    Python vimconda.insert_system_py_sitepath()
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! s:CondaChangeEnv()
   " Python <<EOF
   Python vimconda.conda_change_env()
endfunction
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! CondaChangeEnv call s:CondaChangeEnv()

" ISSUES
" http://stackoverflow.com/questions/13402899/why-does-my-vim-command-line-path-differ-from-my-shell-path
" THERE ARE OTHER ISSUES..SHELLS MUST MATCH
" https://github.com/gmarik/Vundle.vim/issues/510
" https://github.com/davidhalter/jedi-vim/issues/280
" https://github.com/davidhalter/jedi/issues/385
" https://github.com/davidhalter/jedi-vim/issues/196
