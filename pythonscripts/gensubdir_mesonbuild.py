#!/usr/bin/env python3

import re
import sys, getopt
import os
from os import listdir
from os.path import isfile, join, basename

def main(argv):
    try:
        opts, args = getopt.getopt(argv,'a:e:d:',['alias', 'extension',
                                                  'directory'])
    except getopt.GetoptError:
        print('gensubdir_mesonbuild' + '-a <name of file set in meson> -e <file extension> -d <directory to search>')
        sys.exit(2)
    aliasname = ""
    extension = ""
    directory = ""
    for opt, arg in opts:
        if opt == '-h':
            print(basename('gensubdir_mesonbuild') + '-ext <file extension>' +
                  '-dir <directory to search>')
            sys.exit()
        elif opt in ("-a", "--alias"):
            aliasname = arg
        elif opt in ("-e", "--extension"):
            extension = arg
        elif opt in ("-d", "--directory"):
            directory = arg
    if not extension:
        print("specify extension")
        sys.exit(2)
    if not directory:
        print("specify directory")
        sys.exit(2)
    if not aliasname:
        print("specify meson variable name -a")
        sys.exit(2)
    filenames = [ f for f in listdir(directory) if isfile(join(directory, f))]
    checkmatch = ".*\." + extension
    filematches = [f for f in filenames if re.match(checkmatch, f)]
    outfilestring = aliasname + " = files(["
    for f in filematches:
        outfilestring = outfilestring + "'" + f + "'" +  ", "
    outfilestring = outfilestring + "])"
    if isfile(join(directory, 'meson.build')):
        with open(join(directory,'meson.build'), 'r') as f:
            if f.read() == outfilestring:
                sys.exit()#nothing to be done
    with open(join(directory,'meson.build'), 'w') as f:
        f.write(outfilestring)

if __name__ == "__main__":
   main(sys.argv[1:])
