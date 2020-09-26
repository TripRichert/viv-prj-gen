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

