puts "executing $argv0"
puts "argv is:$argv"

source [file join [file dirname [info script]] "cmdline_dict_utils.tcl"]

if {[info exists ::env(MESON_BUILD_ROOT)]} {
    cd $::env(MESON_BUILD_ROOT)
} else {
    puts "no build directory, building at ."
}

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit
}
if {[hasDuplicates [getKeys $argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit
}
proc requireKey { key args} {
    if {![checkForKey $key [join $args]]} {
	puts "no $key defined"
        set keys [getKeys [join $args]]
        puts "in keys: $keys"
	exit
    }
}
requireKey prjname $argv
requireKey partname $argv

proc add_files_to_set { filesettype filetype args} {
    set obj [get_filesets $filesettype]
    set files []
    set missingFiles []
    foreach filename [join $args] {
        if {[file exists $filename]} {
            lappend files [file normalize $filename]
        } else {
            lappend missingFiles $filename
        }
    }
    if {[llength $missingFiles]} {
        puts "these files don't exist yet :'( $missingFiles"
        puts "exiting due to missing files"
        exit
    }
    puts "files: $files"
    add_files -norecurse -fileset $obj $files
    foreach filename $files {
	set file_obj [get_files -of_objects [get_filesets $filesettype] $filename]
	set_property file_type $filetype $file_obj
    }
}

proc add_const_files_to_set { isScoped order args } {
    add_files_to_set constrs_1 "XDC" $args
    set files $args
    foreach filename [join $files] {
	if { $isScoped } {
	    set_property SCOPED_TO_REF [file rootname [file tail $file]] [get_files $filename]
	}
    }
    set_property PROCESSING_ORDER $order [get_files [join $files]]	
}

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
    add_files_to_set sources_1 "VHDL 2008" [getDef vhdl08synthfiles $argv]
    add_files_to_set sim_1 "VHDL 2008" [getDef vhdl08synthfiles $argv]
}

if {[checkForKey vhdl08simfiles $argv]} {
    add_files_to_set sim_1 "VHDL 2008" [getDef vhdl08simfiles $argv]
}

if {[checkForKey scopedearlyconstraints $argv]} {
    add_const_files_to_set true early [getDef scopedearlyconstraints $argv]
}
if {[checkForKey scopednormalconstraints $argv]} {
    add_const_files_to_set true normal [getDef scopedearlyconstraints $argv]
}
if {[checkForKey scopedlateconstraints $argv]} {
    add_const_files_to_set true late [getDef scopedearlyconstraints $argv]
}
if {[checkForKey unscopedearlyconstraints $argv]} {
    add_const_files_to_set false early [getDef scopedearlyconstraints $argv]
}
if {[checkForKey unscopednormalconstraints $argv]} {
    add_const_files_to_set false normal [getDef scopedearlyconstraints $argv]
}
if {[checkForKey unscopedlateconstraints $argv]} {
    add_const_files_to_set false late [getDef scopedearlyconstraints $argv]
}

puts "Completed Execution of $argv0"
