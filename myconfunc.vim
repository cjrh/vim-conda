function! Cmtest(A,L,P)
    " return system('conda info -e')
    return g:condaenvs
endfunction


set wildcharm=<Tab>

function! Showcm()
    unlet g:condaenvs
    let g:condaenvs = system('conda info -e')
    echo g:condaenvs
    let tags = input("Change env to: ", "	", "custom,Cmtest")
    echo tags
endfunction


function! SetCondaPlainPath()
python << EOF
import os
import subprocess
import json
path = os.getenv('PATH')
conda_default_env = os.getenv('CONDA_DEFAULT_ENV')
if not conda_default_env:
    pass
else:
    output = subprocess.check_output('conda info --json', shell=True)
    d = json.loads(output)
    # TODO Check whether the generator comprehension also works.
    path = os.pathsep.join([x for x in path.split(os.pathsep) if d['default_prefix'] not in x])
vim.command("let l:temppath = '" + path + "'")
EOF
return l:temppath
endfunction


" Setting global paths - We use these to switch between conda envs.
if exists("$CONDA_DEFAULT_ENV")
    let g:conda_startup_env = $CONDA_DEFAULT_ENV
else
    let g:conda_startup_env = ""
end


if !exists("g:conda_plain_path")
    " If vim is started from inside a conda path, this variable will
    " contain the path WITHOUT the extra conda env bits.
    let g:conda_plain_path = SetCondaPlainPath()
endif


if !exists("g:conda_startup_path")
    let g:conda_startup_path = $PATH
endif


function! CondaActivate(envname, envpath)
    let $CONDA_DEFAULT_ENV = a:envname
    if has("win32") || has("win64")
        let $PATH = a:envpath . ';' . a:envpath . '\Scripts' .';' . g:conda_plain_path
    elseif has("unix")
        let $PATH = a:envpath . '/bin' .  ':' . g:conda_plain_path
    endif
endfunction


function! CondaDeactivate()
    let $CONDA_DEFAULT_ENV = g:conda_startup_env
    let $PATH = g:conda_startup_path
endfunction


function! CondaChangeEnv()
python << EOF
import vim
import sys
import os
import subprocess
import json
import copy

_current_sys_path = copy.copy(sys.path)

def python_input(message = 'input'):
    vim.command('call inputsave()')
    vim.command("let user_input = input('" + message + ": ', '	', 'custom,Cmtest')")
    vim.command('call inputrestore()')
    return vim.eval('user_input')

output = subprocess.check_output('conda info --json', shell=True)
d = json.loads(output)
print d['envs']

keys = [os.path.basename(e).decode().encode('ascii') for e in d['envs']]
envnames = dict(zip(keys, d['envs']))
envnames['root'] = d['root_prefix']
# Decorate the currently enabled env
default_prefix = d['default_prefix']
for key, value in envnames.items():
    if value == default_prefix:
        current_env = key
        # Don't provide current_env as an option for user
        del envnames[key]

print keys
print envnames
vim.command('let g:condaenvs = "' + '\n'.join(envnames.keys()) + '"')
choice = python_input("Change conda env [current: {}]: ".format(current_env))
print '\n'
print 'choice: ' + choice
if choice == 'root':
    # Run `deactivate` in shell
    print 'Running deactivate...'
    vim.command('call CondaDeactivate()')
elif choice in envnames:
    # Run `activate <choice>` in shell
    print 'Running "activate {}"'.format(choice)
    vim.command("call CondaActivate('{}', '{}')".format(choice, envnames[choice]))
    # Insert selected env's sys.path into the vim python sys.path
    pass
elif len(choice) > 0:
    vim.command('echo "Selected choice: `{}` not found."'.format(choice))
    pass
else:
    # Do nothing, i.e. no change or message
    pass
# vim.command('redraw')
# print 'choice: ' + choice
EOF
endfunction


