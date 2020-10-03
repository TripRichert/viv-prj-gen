#see copywrite notice(s) at bottom of file

puts "executing $argv0"
puts "argv is:$argv"

#get procs to parse cmdline arguments
source [file join [file dirname [info script]] "tcl_utils/cmdline_dict.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[diction::hasDuplicates [diction::getKeys {*}$argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit 3
}

#topname name of top level module of project to be build
#buildscripts list of tcl scripts to be called after files are loaded
set requiredKeys [list builddir prjname partname topname buildscripts]

#miscparams is used to pass data from commandline to the build scripts.
set allowedKeys [list target_language vhdlsynthfiles \
		     verilogsynthfiles svsynthfiles xcifiles \
		     scopedearlyconstraints scopednormalconstraints \
		     scopedlateconstraints unscopedearlyconstraints \
		     unscopednormalconstraints unscopedlateconstraints \
		     miscparams  -vhdl2008
		]

#all required keys are allowed
foreach key $requiredKeys {
    lappend allowedKeys $key
}

#exit program if required key is missing
foreach requiredKey $requiredKeys {
    diction::requireKey $requiredKey {*}$argv
}
#exit program if any keys aren't allowed
set unrecognizedKeys []
foreach key [diction::getKeys {*}$argv] {
    if {[lsearch $allowedKeys $key] == -1} {
        lappend unrecognizedKeys $key
    }
}
if {[llength $unrecognizedKeys]} {
    puts "did not recognize keys $unrecognizedKeys"
	puts "allowed keys are: $allowedKeys"
	puts "execution suspended of $argv0"
	exit 5
}

#navigate to build directory, create prj directory, and navigate to it
if {[diction::getDef builddir {*}$argv] != ""} {
    cd [diction::getDef builddir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}
set prjname [diction::getDef prjname {*}$argv]
file mkdir "vivnonprj_$prjname"
cd "vivnonprj_$prjname"

create_project -in_memory -part [diction::getDef partname {*}$argv]

#add the source files
if {[diction::checkForKey vhdlsynthfiles {*}$argv]} {
    foreach filename [diction::getDef vhdlsynthfiles {*}$argv] {
	if {[diction::checkForKey -vhdl2008 {*}$argv]} {
	    read_vhdl -vhdl2008 $filename
	} else {
	    read_vhdl $filename
	}
    }
}

if {[diction::checkForKey verilogsynthfiles {*}$argv]} {
    foreach filename [diction::getDef verilogsynthfiles {*}$argv] {
	read_verilog $filename
    }
}

if {[diction::checkForKey svsynthfiles {*}$argv]} {
    foreach filename [diction::getDef svsynthfiles {*}$argv] {
	read_vhdl -sv $filename
    }
}

if {[diction::checkForKey xcifiles {*}$argv]} {
    foreach filename [diction::getDef xcifiles {*}$argv] {
	puts "importing ip $filename"
	read_ip $filename
    }
}


if {[diction::checkForKey unscopedearlyconstraints {*}$argv]} {
    foreach filename [diction::getDef unscopedearlyconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[diction::checkForKey scopedearlyconstraints {*}$argv]} {
    foreach filename [diction::getDef scopedearlyconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[diction::checkForKey unscopednormalconstraints {*}$argv]} {
    foreach filename [diction::getDef unscopednormalconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[diction::checkForKey scopednormalconstraints {*}$argv]} {
    foreach filename [diction::getDef scopednormalconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[diction::checkForKey unscopedlateconstraints {*}$argv]} {
    foreach filename [diction::getDef unscopedlateconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[diction::checkForKey scopedlateconstraints {*}$argv]} {
    foreach filename [diction::getDef scopedlateconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}

#set up variables the called scripts might need
set topname [diction::getDef topname {*}$argv]
set partname [diction::getDef partname {*}$argv]
set prjname [diction::getDef prjname {*}$argv]
set miscparams [join [diction::getDef miscparams {*}$argv]]
set tcltopdirname [file dirname [info script]]

#call each of the passed list of scripts in order
foreach scriptname [diction::getDef buildscripts {*}$argv] {
    source $scriptname
}

puts "Completed Execution of $argv0"

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
