# vim-conda

This is a [Vim](http://www.vim.org/) plugin to support [Python](https://www.python.org/) development using the [Conda](http://conda.pydata.org/docs/) environment manager.

**This plugin is currently in alpha. Unless you like the bleeding edge you should hold off using this until beta.**

This plugin provides the following functions:
```
CondaChangeEnv()
```
This function will trigger wildmode allowing you to tab through the existing Conda environments on your system. When an environment is selected, the following happens: 
- A new environment variable called `$CONDA_DEFAULT_ENV` is created *inside the running Vim process*
- The `$PATH` variable is set to be the selected conda env, plus the associated `/Scripts` folder, as per the usual way the `activate` script supplied by Conda would modify the path. Note that the `$PATH` environment variable *inside the running Vim process* is modified.
- The `sys.path` list of the **embedded Python instance** inside the running Vim process is modified to include the entries for the selected Conda env.  This is done so that the Jedi-vim package will automatically be able to perform code completion within the selected env.

Demo
----

![gif screencast of plugin demo](https://github.com/cjrh/vim-conda/blob/master/demo.gif)
