puts "executing $argv0"
puts "argv is: $argv"

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

set requiredKeys [list gendir xciname partname xcigenscript]
set allowedKeys [list target_language]
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
if {[llength {*}$unrecognizedKeys]} {
    puts "did not recognize keys $unrecognizedKeys"
	puts "allowed keys are: $allowedKeys"
	puts "execution suspended of $argv0"
	exit 5
}

if {[dict::getDef gendir {*}$argv] != ""} {
    cd [dict::getDef gendir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}

create_project -in_memory -part [dict::getDef partname {*}$argv]
set ip_gen_dir [pwd]
if {[dict::getDef xcigenscript {*}$argv] != ""} {
    source [dict::getDef xcigenscript {*}$argv]
}
if {[dict::checkForKeyPair target_language {*}$argv]} {
    set_property target_language \
	[dict::getDef target_language {*}$argv] [current_project]
} else {
    set_property target_language VHDL [current_project]
}
generate_target all [get_ips]
