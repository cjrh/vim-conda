# coding: utf-8
from __future__ import division, print_function
'''
------------------------------------------------------------------------
Python initialization
------------------------------------------------------------------------
This file was copied and adapted from jedi-vim.
'''

import vim

# update the system path, to include the jedi path
import sys
import os

# vim.command('echom expand("<sfile>:p:h:h")') # broken, <sfile> inside function
# sys.path.insert(0, os.path.join(vim.eval('expand("<sfile>:p:h:h")'), 'jedi'))
_script_path = vim.eval('expand(s:script_path)')

# This would be used if there was some other local
# library that you wanted to import.

# to display errors correctly
import traceback

# update the sys path to include the jedi_vim script
sys.path.insert(0, _script_path)
try:
    import vim_conda
except ImportError:
    vim.command('echoerr "Please install Jedi if you want to use jedi_vim."')
sys.path.pop(1)
