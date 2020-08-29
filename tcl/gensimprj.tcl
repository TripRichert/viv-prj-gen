puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "cmdline_dict_procs.tcl"]
source [file join [file dirname [info script]] "viv_prj_procs.tcl"]

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

set requiredKeys [list builddir prjname partname]
set allowedKeys [list target_language vhdl08synthfiles \
		     vhdl08simfiles vhdlsynthfiles vhdlsimfiles\
		     verilogsynthfiles verilogsimfiles \
		     systemverilogsynthfiles systemverilogsimfiles \
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

create_project [getDef prjname $argv]
#set_proj_dir [get_property directory [current_project]]
set obj [current_project]
set partname [getDef partname $argv]
set_property "part" "$partname" [current_project]
if {[checkForKey target_language $argv]} {
    set_property target_language [getDef target_language $argv] [current_project]
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

if {[checkForKey vhdl08synthfiles $argv]} {
    if {[getDef vhdl08synthfiles $argv] != ""} {
	add_files_to_set sources_1 "VHDL 2008" [getDef vhdl08synthfiles $argv]
	add_files_to_set sim_1 "VHDL 2008" [getDef vhdl08synthfiles $argv]
    }
}

if {[checkForKey vhdl08simfiles $argv]} {
    if {[getDef vhdl08simfiles $argv] != ""} {
	add_files_to_set sim_1 "VHDL 2008" [getDef vhdl08simfiles $argv]
    }
}

if {[checkForKey vhdlsynthfiles $argv]} {
    if {[getDef vhdlsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "VHDL" [getDef vhdlsynthfiles $argv]
	add_files_to_set sim_1 "VHDL" [getDef vhdlsynthfiles $argv]
    }
}

if {[checkForKey vhdlsimfiles $argv]} {
    if {[getDef vhdlsimfiles $argv] != ""} {
	add_files_to_set sim_1 "VHDL" [getDef vhdlsimfiles $argv]
    }
}

if {[checkForKey verilogsynthfiles $argv]} {
    if {[getDef verilogsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "Verilog" [getDef verilogsynthfiles $argv]
	add_files_to_set sim_1 "Verilog" [getDef verilogsynthfiles $argv]
    }
}

if {[checkForKey verilogsimfiles $argv]} {
    if {[getDef verilogsimfiles $argv] != ""} {
	add_files_to_set sim_1 "Verilog" [getDef verilogsimfiles $argv]
    }
}

if {[checkForKey systemverilogsynthfiles $argv]} {
    if {[getDef systemverilogsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "SystemVerilog" [getDef systemverilogsynthfiles $argv]
	add_files_to_set sim_1 "SystemVerilog" [getDef systemverilogsynthfiles $argv]
    }
}

if {[checkForKey systemverilogsimfiles $argv]} {
    if {[getDef systemverilogsimfiles $argv] != ""} {
	add_files_to_set sim_1 "SystemVerilog" [getDef systemverilogsimfiles $argv]
    }
}


if {[checkForKey scopedearlyconstraints $argv]} {
    if {[getDef scopedearlyconstraints $argv] != ""} {
	add_const_files_to_set true early [getDef scopedearlyconstraints $argv]
    }
}
if {[checkForKey scopednormalconstraints $argv]} {
    if {[getDef scopednormalconstraints $argv] != ""} {
	add_const_files_to_set true normal [getDef scopednormalconstraints $argv]
    }
}
if {[checkForKey scopedlateconstraints $argv]} {
    if {[getDef scopedlateconstraints $argv] != ""} {
	add_const_files_to_set true late [getDef scopedlateconstraints $argv]
    }
}
if {[checkForKey unscopedearlyconstraints $argv]} {
    if {[getDef unscopedearlyconstraints $argv] != ""} {
	add_const_files_to_set false early [getDef unscopedearlyconstraints $argv]
    }
}
if {[checkForKey unscopednormalconstraints $argv]} {
    if {[getDef unscopednormalconstraints $argv] != ""} {
	add_const_files_to_set false normal [getDef unscopednormalconstraints $argv]
    }
}
if {[checkForKey unscopedlateconstraints $argv]} {
    if {[getDef unscopedlateconstraints $argv] != ""} {
	add_const_files_to_set false late [getDef unscopedlateconstraints $argv]
    }
}

puts "Completed Execution of $argv0"
