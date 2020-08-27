puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "cmdline_dict_utils.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[hasDuplicates [getKeys $argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit 3
}
proc requireKey { key args} {
    if {![checkForKey $key [join $args]]} {
	puts "no $key defined"
        set keys [getKeys [join $args]]
        puts "in keys: $keys"
	exit 4
    }
}

set requiredKeys [list builddir prjname partname topname buildscripts]
set allowedKeys [list target_language vhdlsynthfiles \
                   scopedearlyconstraints scopednormalconstraints \
                   scopedlateconstraints unscopedearlyconstraints \
                   unscopednormalconstraints unscopedlateconstraints \
                   ]
foreach key $requiredKeys {
    lappend allowedKeys $key
}

foreach requiredKey $requiredKeys {
    requireKey $requiredKey $argv
}
set unrecognizedKeys []
foreach key [getKeys $argv] {
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

if {[getDef builddir $argv] != ""} {
    cd [getDef builddir $argv]
} else {
    puts "builddir failed"
    exit 7
}
file mkdir [getDef prjname $argv]
cd [getDef prjname $argv]

create_project -in_memory -part [getDef partname $argv]


if {[checkForKey vhdlsynthfiles $argv]} {
    foreach filename [getDef vhdlsynthfiles $argv] {
	read_vhdl $filename
    }
}

if {[checkForKey unscopedearlyconstraints $argv]} {
    foreach filename [getDef unscopedearlyconstraints $argv] {
	read_xdc $filename
    }
}
if {[checkForKey scopedearlyconstraints $argv]} {
    foreach filename [getDef scopedearlyconstraints $argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[checkForKey unscopednormalconstraints $argv]} {
    foreach filename [getDef unscopednormalconstraints $argv] {
	read_xdc $filename
    }
}
if {[checkForKey scopednormalconstraints $argv]} {
    foreach filename [getDef scopednormalconstraints $argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
if {[checkForKey unscopedlateconstraints $argv]} {
    foreach filename [getDef unscopedlateconstraints $argv] {
	read_xdc $filename
    }
}
if {[checkForKey scopedlateconstraints $argv]} {
    foreach filename [getDef scopedlateconstraints $argv] {
	read_xdc -ref [file rootname [file tail $filename]] $filename
    }
}
set topname [getDef topname $argv]
set partname [getDef partname $argv]
set prjname [getDef prjname $argv]

foreach scriptname [getDef buildscripts $argv] {
    source $scriptname
}

puts "Completed Execution of $argv0"
