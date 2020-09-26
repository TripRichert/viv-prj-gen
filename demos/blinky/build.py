#license at bottom of file

from edalize import *
import os
import sys, re

def generateDiction(args):
    mydictionary = {}
    definitionList = []
    currentKey = ""
    for arg in args:
        if (re.match("-.+", arg)):
            if (len(currentKey) > 0):
                mydictionary[currentKey] = definitionList
            currentKey = arg[1:]
            definitionList = []
        else:
            definitionList.append(arg)
    if (len(currentKey) > 0):
        mydictionary[currentKey] = definitionList
    return mydictionary
    

def main(argv):
    cmdDictionary = generateDiction(argv)

    assert 'outdir' in cmdDictionary
    assert 'partname' in cmdDictionary
    assert 'name' in cmdDictionary
    assert 'topname' in cmdDictionary
    
    files = []
    if 'vhdlsynthfiles' in cmdDictionary:
        for filename in cmdDictionary['vhdlsynthfiles']:
            files.append({'name': filename, 'file_type': 'vhdlSource'})

    if 'verilogsynthfiles' in cmdDictionary:
        for filename in cmdDictionary['verilogsynthfiles']:
            files.append({'name': filename, 'file_type': 'verilogSource'})

    if 'xdcfiles' in cmdDictionary:
        for filename in cmdDictionary['xdcfiles']:
            files.append({'name': filename, 'file_type': 'xdc'})

    tool = 'vivado'
    name = cmdDictionary['name'][0]
    topname = cmdDictionary['topname'][0]
    partname = cmdDictionary['partname'][0]
    work_dir = cmdDictionary['outdir'][0]

    edam = {
        'files'        : files,
        'name'         : name,
        'toplevel'     : topname,
        'tool_options' : {'vivado': {'part': partname}}
        }
    backend = get_edatool(tool)(edam=edam,
                                work_root=work_dir)

    
    os.makedirs(work_dir)
    backend.configure()

    backend.build()


if __name__ == "__main__":
   main(sys.argv[1:])


###############################################################################
# MIT LICENSE
###############################################################################

#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
