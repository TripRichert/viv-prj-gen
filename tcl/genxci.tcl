puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]


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

set requiredKeys [list gendir xciname partname xcigenscript]
set allowedKeys [list target_language]
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

if {[getDef gendir $argv] != ""} {
    cd [getDef gendir $argv]
} else {
    puts "builddir failed"
    exit 7
}

create_project -in_memory -part [getDef partname $argv]
set ip_gen_dir [pwd]
if {[getDef xcigenscript $argv] != ""} {
    source [getDef xcigenscript $argv]
}
if {[checkForKey target_language $argv]} {
    set_property target_language [getDef target_language $argv] [current_project]
} else {
    set_property target_language VHDL [current_project]
}
generate_target all [get_ips]

