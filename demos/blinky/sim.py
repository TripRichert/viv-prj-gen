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
    assert 'name'    in cmdDictionary
    assert 'topname' in cmdDictionary

    files = []
    if 'vhdlfiles' in cmdDictionary:
        for filename in cmdDictionary['vhdlfiles']:
            files.append({'name': filename, 'file_type': 'vhdlSource'})

    if 'verilogfiles' in cmdDictionary:
        for filename in cmdDictionary['verilogfiles']:
            files.append({'name': filename, 'file_type': 'verilogSource'})


    parameters = {'vcd' : {'datatype' : 'bool', 'paramtype' : 'plusarg'}}
    if 'parameters' in cmdDictionary:
        paramDictionary = generateDiction(cmdDictionary['parameters'][1:]) 
        for param in paramDictionary:
            parameters[param] = {'datatype' : paramDictionary[param][0], 'default': paramDictionary[param][1], 'paramtype' : 'vlogparam'}

    tool = 'icarus'

    name = cmdDictionary['name'][0]
    topname = cmdDictionary['topname'][0]
    work_dir = cmdDictionary['outdir'][0]

    edam = {
        'files'        : files,
        'name'         : name,
        'parameters'   : parameters,
        'toplevel'     : topname
    }

    backend = get_edatool(tool)(edam=edam,
                                work_root=work_dir)

    os.makedirs(work_dir)
    backend.configure()

    backend.build()

    args = {'vcd' : True}
    backend.run(args)

if __name__ == "__main__":
   main(sys.argv[1:])
