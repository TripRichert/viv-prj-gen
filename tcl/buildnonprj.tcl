puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[dict::hasDuplicates [dict::getKeys {*}$argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit 3
}

set requiredKeys [list builddir prjname partname topname buildscripts]
set allowedKeys [list target_language vhdlsynthfiles \
		     verilogsynthfiles svsynthfiles xcifiles \
		     scopedearlyconstraints scopednormalconstraints \
		     scopedlateconstraints unscopedearlyconstraints \
		     unscopednormalconstraints unscopedlateconstraints \
		     miscparams  -vhdl2008
		]

foreach key $requiredKeys {
    lappend allowedKeys $key
}

foreach requiredKey $requiredKeys {
    dict::requireKey $requiredKey {*}$argv
}
set unrecognizedKeys []
foreach key [dict::getKeys {*}$argv] {
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

if {[dict::getDef builddir {*}$argv] != ""} {
    cd [dict::getDef builddir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}
file mkdir [dict::getDef prjname {*}$argv]
cd [dict::getDef prjname {*}$argv]

create_project -in_memory -part [dict::getDef partname {*}$argv]

if {[dict::checkForKey vhdlsynthfiles {*}$argv]} {
    foreach filename [dict::getDef vhdlsynthfiles {*}$argv] {
	if {[dict::checkForKey -vhdl2008 {*}$argv]} {
	    read_vhdl -vhdl2008 $filename
	} else {
	    read_vhdl $filename
	}
    }
}

if {[dict::checkForKey verilogsynthfiles {*}$argv]} {
    foreach filename [dict::getDef verilogsynthfiles {*}$argv] {
	read_verilog $filename
    }
}

if {[dict::checkForKey svsynthfiles {*}$argv]} {
    foreach filename [dict::getDef svsynthfiles {*}$argv] {
	read_vhdl -sv $filename
    }
}

if {[dict::checkForKey xcifiles {*}$argv]} {
    foreach filename [dict::getDef xcifiles {*}$argv] {
	puts "importing ip $filename"
	read_ip $filename
    }
}


if {[dict::checkForKey unscopedearlyconstraints {*}$argv]} {
    foreach filename [dict::getDef unscopedearlyconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[dict::checkForKey scopedearlyconstraints {*}$argv]} {
    foreach filename [dict::getDef scopedearlyconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[dict::checkForKey unscopednormalconstraints {*}$argv]} {
    foreach filename [dict::getDef unscopednormalconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[dict::checkForKey scopednormalconstraints {*}$argv]} {
    foreach filename [dict::getDef scopednormalconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[dict::checkForKey unscopedlateconstraints {*}$argv]} {
    foreach filename [dict::getDef unscopedlateconstraints {*}$argv] {
	read_xdc $filename
    }
}
if {[dict::checkForKey scopedlateconstraints {*}$argv]} {
    foreach filename [dict::getDef scopedlateconstraints {*}$argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
set topname [dict::getDef topname {*}$argv]
set partname [dict::getDef partname {*}$argv]
set prjname [dict::getDef prjname {*}$argv]
set miscparams [join [dict::getDef miscparams {*}$argv]]
set tcltopdirname [file dirname [info script]]

foreach scriptname [dict::getDef buildscripts {*}$argv] {
    source $scriptname
}

puts "Completed Execution of $argv0"
