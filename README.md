
# vim-conda

This is a [Vim](http://www.vim.org/) plugin to support [Python](https://www.python.org/) development using the [Conda](http://conda.pydata.org/docs/) environment manager.

**NOTE for Neovim users**: If Neovim finds `python` on your `$PATH`, it assumes this is Python 2 (and likewise for `python3` being treated as Python 3). If you start Neovim from a shell with an activated Conda env that uses _Python 3_, you're going to have problems because the conda env exposes a binary called `python`, but which is really 3 and not 2. Because of this, you will have to use the Neovim option of setting `g:python_host_prog` to point to a valid Python 2, into which you must also have pip installed the required neovim client.


Install
-------

[Vundle](https://github.com/gmarik/Vundle.vim) is the recommended way. Add this to the section in your `vimrc` file where all your plugin statements appear:
```
Plugin 'cjrh/vim-conda'
```

_Edit: Vundle is no longer the recommended way!_

I much prefer [vim-plug](https://github.com/junegunn/vim-plug) which works in a similar way to Vundle, but seem just generally better all round. To add vim-conda,
you need this:
```
Plug 'cjrh/vim-conda'
```


Super-short summary
-------------------
When developing Python with Vim, there are *two* Pythons of interest:

1. The one that executes your code in a shell command, i.e. `:!python %`
1. The (embedded in Vim) one that `jedi-vim` uses to provide code completion.

Conda is concerned with the first one, i.e. the "shell Python".  The second one depends on how you have Vim set up with respect to its own Python scripting support.

This plugin provides a command, `CondaChangeEnv`, that will

1. Change the `$PATH` and `$CONDA_DEFAULT_ENV` environment variables *inside* the Vim process, so that new launched processes will have the same environment as if they were launched from a Conda env.
1. Change the *embedded Python sys.path* inside Vim so that tools like `jedi-vim` will provide code completion for the selected env.

Demo
----

![gif screencast of plugin demo](https://github.com/cjrh/vim-conda/blob/master/demo.gif)

Introduction
------------

The Vim editor can be used to develop Python code. One popular workflow is to edit the text of a code module (e.g. a `.py` file), and then execute the code with a shell command, such as
```
:!python %
```
(where `%` will be expanded to the name of the current file). Which `python` will run? Why, the one in the system path of course! But what happens if there is more than one Python executable in the system path? The *first one* to be found will be the one that runs.

This forms the basis of how *virtual environments* work.  The Conda tool is an environment manager for Python; it also supports package management as part of its feature set, but we are not concerned with that here.  Conda allows the user to create multiple, separate Python installations, and switch between them on the command line. It does this by modifying the `$PATH` (or `PATH` on Windows) environment variable.

`vim-conda` makes it easy to perform **switching** environments right from inside Vim.  Now you never have to leave, so the [>300 upvoted question on StackOverflow on "how to quit"](http://stackoverflow.com/questions/11828270/how-to-exit-the-vim-editor) need no longer concern you ;)

This plugin provides only one single command, `CondaChangeEnv`, which you can map to an unused key. You can call the command like so:
```
:CondaChangeEnv<ENTER>
```
You can map it to a key (e.g. in your `vimrc` file) like so:
```
map <F4> :CondaChangeEnv<CR>
```

When the command is executed, a `wildmenu` will appear showing the currently available Conda environments on your system. By selection one, the changes to `$PATH` and the embedded-python `sys.path` are made. (*Unfortunately, the key for triggering `wildmode` and moving through the wildmenu is hard-coded to `<Tab>`; I still haven't learned enough vimscript to figure out how to use a user setting.*)

In the list of environments, you will also see `root` as an option if you had previously changed to a non-root env. Selecting `root` is the same as doing a `deactivate` in the sense that all the changes made previously are rolled back.

Likewise, when you change from one environment to another, the change is clean in the sense that changes from the first env are reset, before changes for the new env are made.  Exactly as would happen on the command line.

Details
-------

The `CondaChangeEnv` command will trigger wildmode allowing you to tab through the existing Conda environments on your system. When an environment is selected, the following happens:

- A new environment variable called `$CONDA_DEFAULT_ENV` is created *inside the running Vim process*
- The `$PATH` variable is set to be the selected Conda env, plus the associated `/Scripts` folder, as per the usual way the `activate` script supplied by Conda would modify the path. Note that the `$PATH` environment variable *inside the running Vim process* is modified.
- The `sys.path` list of the **embedded Python instance** inside the running Vim process is modified to include the entries for the selected Conda env.  This is done so that the Jedi-Vim package will automatically be able to perform code completion within the selected env.

# Notes

While testing, I found that I needed the following settings in my `vimrc` in order to suppress some errors related to other packages:

```vim
let g:jedi#force_py_version = 2
let g:UltisnipsUsePythonVersion = 2
```
More testing is needed to make sure that all the configurations work.


In order to suppress the message of vim-conda environment information on vim startup - add the variable in the 'vimrc' file.

```vim
let g:conda_startup_msg_suppress = 1
```

In order to keep the message of vim-conda environment information on vim startup - you can either comment out the above variable or add the below variable in the 'vimrc' file.

```vim
let g:conda_startup_msg_suppress = 0
```

In order to avoid a warning when opening vim without an environment activated, add the variable in the 'vimrc' file.

```vim
let g:conda_startup_wrn_suppress = 1
```

