#!/usr/bin/python
import os
path = os.getenv('PATH')
for p in path.split(os.pathsep):
    print p
