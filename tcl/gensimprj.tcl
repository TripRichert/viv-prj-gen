puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]
source [file join [file dirname [info script]] "helper_procs/vivprj.tcl"]

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

set requiredKeys [list builddir prjname partname]
set allowedKeys [list target_language vhdl08synthfiles \
		     vhdl08simfiles vhdlsynthfiles vhdlsimfiles\
		     verilogsynthfiles verilogsimfiles \
		     systemverilogsynthfiles systemverilogsimfiles \
		     scopedearlyconstraints scopednormalconstraints \
		     scopedlateconstraints unscopedearlyconstraints \
		     unscopednormalconstraints unscopedlateconstraints \
		     datafiles
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

create_project [dict::getDef prjname {*}$argv]
#set_proj_dir [get_property directory [current_project]]
set obj [current_project]
set partname [dict::getDef partname {*}$argv]
set_property "part" "$partname" [current_project]
if {[dict::checkForKey target_language {*}$argv]} {
    set_property target_language [dict::getDef target_language {*}$argv] [current_project]
} else {
    set_property target_language VHDL [current_project]
}
set_property default_lib xil_defaultlib [current_project]
set_property generate_ip_upgrade_log "0" [current_project]
set_property "sim.ip.auto_export_scripts" "1" [current_project]
set_property simulator_language "Mixed" [current_project]
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

if {[dict::checkForKey vhdl08synthfiles {*}$argv]} {
    if {[dict::getDef vhdl08synthfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sources_1 "VHDL 2008" [dict::getDef vhdl08synthfiles {*}$argv]
	vivprj::add_files_to_set sim_1 "VHDL 2008" [dict::getDef vhdl08synthfiles {*}$argv]
    }
}

if {[dict::checkForKey vhdl08simfiles {*}$argv]} {
    if {[dict::getDef vhdl08simfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sim_1 "VHDL 2008" [dict::getDef vhdl08simfiles {*}$argv]
    }
}

if {[dict::checkForKey vhdlsynthfiles {*}$argv]} {
    if {[dict::getDef vhdlsynthfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sources_1 "VHDL" [dict::getDef vhdlsynthfiles {*}$argv]
	vivprj::add_files_to_set sim_1 "VHDL" [dict::getDef vhdlsynthfiles {*}$argv]
    }
}

if {[dict::checkForKey vhdlsimfiles {*}$argv]} {
    if {[dict::getDef vhdlsimfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sim_1 "VHDL" [dict::getDef vhdlsimfiles {*}$argv]
    }
}

if {[dict::checkForKey verilogsynthfiles {*}$argv]} {
    if {[dict::getDef verilogsynthfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sources_1 "Verilog" [dict::getDef verilogsynthfiles {*}$argv]
	vivprj::add_files_to_set sim_1 "Verilog" [dict::getDef verilogsynthfiles {*}$argv]
    }
}

if {[dict::checkForKey verilogsimfiles {*}$argv]} {
    if {[dict::getDef verilogsimfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sim_1 "Verilog" [dict::getDef verilogsimfiles {*}$argv]
    }
}

if {[dict::checkForKey systemverilogsynthfiles {*}$argv]} {
    if {[dict::getDef systemverilogsynthfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sources_1 "SystemVerilog" [dict::getDef systemverilogsynthfiles {*}$argv]
	vivprj::add_files_to_set sim_1 "SystemVerilog" [dict::getDef systemverilogsynthfiles {*}$argv]
    }
}

if {[dict::checkForKey systemverilogsimfiles {*}$argv]} {
    if {[dict::getDef systemverilogsimfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sim_1 "SystemVerilog" [dict::getDef systemverilogsimfiles {*}$argv]
    }
}


if {[dict::checkForKey scopedearlyconstraints {*}$argv]} {
    if {[dict::getDef scopedearlyconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set true early [dict::getDef scopedearlyconstraints {*}$argv]
    }
}
if {[dict::checkForKey scopednormalconstraints {*}$argv]} {
    if {[dict::getDef scopednormalconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set true normal [dict::getDef scopednormalconstraints {*}$argv]
    }
}
if {[dict::checkForKey scopedlateconstraints {*}$argv]} {
    if {[dict::getDef scopedlateconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set true late [dict::getDef scopedlateconstraints {*}$argv]
    }
}
if {[dict::checkForKey unscopedearlyconstraints {*}$argv]} {
    if {[dict::getDef unscopedearlyconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set false early [dict::getDef unscopedearlyconstraints {*}$argv]
    }
}
if {[dict::checkForKey unscopednormalconstraints {*}$argv]} {
    if {[dict::getDef unscopednormalconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set false normal [dict::getDef unscopednormalconstraints {*}$argv]
    }
}
if {[dict::checkForKey unscopedlateconstraints {*}$argv]} {
    if {[dict::getDef unscopedlateconstraints {*}$argv] != ""} {
	vivprj::add_const_files_to_set false late [dict::getDef unscopedlateconstraints {*}$argv]
    }
}

if {[dict::checkForKey datafiles {*}$argv]} {
    if {[dict::getDef datafiles {*}$argv] != ""} {
	vivprj::add_files_to_set sim_1 "Data Files" [dict::getDef datafiles {*}$argv]
    }
}

puts "Completed Execution of $argv0"
