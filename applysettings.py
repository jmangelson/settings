#!/usr/bin/env python

import os
import sys
import errno
import shutil

scriptDir           = sys.path[0]
homeDir             = os.getenv('HOME')
requiredDirs        = [os.path.join(homeDir, '.config'),
                       os.path.join(homeDir, 'texpath')]

#These home dir files will be links to version controlled files
bashrc              = os.path.join(homeDir, '.bashrc')
emacs               = os.path.join(homeDir, '.emacs')
emacsd              = os.path.join(homeDir, '.emacs.d')
openboxd            = os.path.join(homeDir, '.config', 'openbox')
fontsconf           = os.path.join(homeDir, '.fonts.conf')
dircolors           = os.path.join(homeDir, '.dircolors')
pythonrc            = os.path.join(homeDir, '.pythonrc')
texpathd            = os.path.join(homeDir, 'texpath')

#These will be the actual version controlled files (the sources)
bashrcSource        = os.path.join(scriptDir, 'linux-stuff', '.bashrc')
emacsSource         = os.path.join(scriptDir,  'emacs-stuff', '.emacs')
emacsdSource        = os.path.join(scriptDir,  'emacs-stuff', '.emacs.d')
openboxdSource      = os.path.join(scriptDir, 'openbox-stuff', 'openbox')
fontsconfSource     = os.path.join(scriptDir, 'linux-stuff', '.fonts.conf')
dircolorsSource     = os.path.join(scriptDir, 'linux-stuff', '.dircolors')
pythonrcSource      = os.path.join(scriptDir, 'linux-stuff', '.pythonrc')
texpathdSource      = os.path.join(scriptDir, 'texpath')

#make a list of tupple pairs
sourceToDestination = { bashrcSource : bashrc,
                        emacsSource : emacs,
                        emacsdSource : emacsd,
                        openboxdSource : openboxd,
                        fontsconfSource : fontsconf,
                        dircolorsSource : dircolors,
                        pythonrcSource : pythonrc,
                        texpathdSource : texpathd }

def createLink(src, dest):
    os.symlink(src, dest)

def removeFile(path):
    try:
        os.remove(path)
    except OSError, err:
        if (err.errno == errno.EISDIR or
            err.errno == errno.ENOTEMPTY):
            printInfo('\tRemoving dir ' + path)
            shutil.rmtree(path)
        else:
            pass

def makeDir(directory):
    try:
        os.mkdir(directory)
    except OSError, err:
        if err.errno == errno.EEXIST:
            pass

def printInfo(string):
    print 'INFO: ' + string

def main():

    for d in requiredDirs:
        makeDir(d)

    for src, dest in sourceToDestination.items():

        if not os.path.islink(dest):
            printInfo(dest + " link does NOT exist.  Creating link...")
            removeFile(dest)
            createLink(src, dest)
        else:
            print dest + " exists"
            
    return 0
    
if __name__ == '__main__':

    sys.exit(main())

