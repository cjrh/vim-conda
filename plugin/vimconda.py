""" Global code for Python """
import os
from os.path import join, dirname #, normpath
from subprocess import check_output, PIPE
import json
import vim

def vim_conda_runshell(cmd):
    """ Run external shell command """
    return check_output(cmd, shell=True, executable=os.getenv('SHELL'),
                        # Needed to avoid "WindowsError: [Error 6] The handle
                        # is invalid" When launching gvim.exe from a CMD shell.
                        # (gvim from icon seems fine!?) See also:
                        # http://bugs.python.org/issue3905
                        # stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                        # stderr=subprocess.PIPE)
                        stdin=PIPE, stderr=PIPE)


def vim_conda_runpyshell(cmd):
    """ Run python external python command """
    return check_output('python -c "{}"'.format(cmd), shell=True,
                        executable=os.getenv('SHELL'),
                        stdin=PIPE, stderr=PIPE)


def get_conda_info_dict():
    """ Example output:
    {
      "channels": [
        "http://repo.continuum.io/pkgs/free/osx-64/",
        "http://repo.continuum.io/pkgs/free/noarch/",
        "http://repo.continuum.io/pkgs/pro/osx-64/",
        "http://repo.continuum.io/pkgs/pro/noarch/"
      ],
      "conda_build_version": "1.1.0",
      "conda_version": "3.9.0",
      "default_prefix": "/Users/calebhattingh/anaconda",
      "envs": [
        "/Users/calebhattingh/anaconda/envs/django3",
        "/Users/calebhattingh/anaconda/envs/falcontest",
        "/Users/calebhattingh/anaconda/envs/misutesting",
        "/Users/calebhattingh/anaconda/envs/partito",
        "/Users/calebhattingh/anaconda/envs/py26",
        "/Users/calebhattingh/anaconda/envs/py27",
        "/Users/calebhattingh/anaconda/envs/py3",
        "/Users/calebhattingh/anaconda/envs/py34"
      ],
      "envs_dirs": [
        "/Users/calebhattingh/anaconda/envs"
      ],
      "is_foreign": false,
      "pkgs_dirs": [
        "/Users/calebhattingh/anaconda/pkgs"
      ],
      "platform": "osx-64",
      "python_version": "2.7.9.final.0",
      "rc_path": null,
      "requests_version": "2.5.1",
      "root_prefix": "/Users/calebhattingh/anaconda",
      "root_writable": true,
      "sys_rc_path": "/Users/calebhattingh/anaconda/.condarc",
      "user_rc_path": "/Users/calebhattingh/.condarc"
    }
    """
    output = vim_conda_runshell('conda info --json')
    return json.loads(output)


def insert_system_py_sitepath():
    """ Add the system $PATH Python's site-packages folders to the
    embedded Python's sys.path. This is for Jedi-vim code completion. """
    import os
    cmd = "import site, sys, os; sys.stdout.write(os.path.pathsep.join(site.getsitepackages()))"
    #sitedirs = str(vim_conda_runpyshell(cmd)).split(os.path.pathsep)
    sitedirs = vim_conda_runpyshell(cmd).decode()
    sitedirs = sitedirs.split(os.path.pathsep)
    # The following causes errors. Jedi vim imports e.g. hashlib
    # from the stdlib, but it we've added a different stdlib to the
    # embedded sys.path, jedi loads the wrong one, causing errs.
    # Looks like we should only load site-packages.
    for sitedir in sitedirs:
        if sitedir not in sys.path:
            sys.path.insert(0, sitedir)

def setcondaplainpath():
    """ function! s:SetCondaPlainPath()

    return:
        l:temppath
    """
    import subprocess
    # This is quite deceiving. `os.environ` loads only a single time,
    # when the os module is first loaded. With this embedded-vim
    # Python, that means only one time. If we want to have an
    # up-to-date version of the environment, we'll have to use
    # Vim's $VAR variables and rather act on that.
    # TODO: Fix use of py getenv
    path = os.getenv('PATH')
    conda_default_env = os.getenv('CONDA_DEFAULT_ENV')
    if not conda_default_env:
        pass
    else:
        # We appear to be inside a conda env already. We want the path
        # that we would have WITHOUT being in a conda env, e.g. what
        # we'd get if `deactivate` was run.
        output = subprocess.check_output('conda info --json',
            shell=True, executable=os.getenv('SHELL'),
            # Needed to avoid "WindowsError: [Error 6] The handle is invalid"
            # When launching gvim.exe from a CMD shell. (gvim from icon seems
            # fine!?)
            # See also: http://bugs.python.org/issue3905
            # stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdin=subprocess.PIPE, stderr=subprocess.PIPE)
        d = json.loads(output)
        # We store the path variable we get if we filter out all the paths
        # that match the current conda "default_prefix".
        # TODO Check whether the generator comprehension also works.
        path = os.pathsep.join([x for x in path.split(os.pathsep)
                                    if d['default_prefix'] not in x])
    vim.command("let l:temppath = '" + path + "'")
