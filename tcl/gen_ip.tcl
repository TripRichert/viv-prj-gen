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

set requiredKeys [list ipdir ipname partname vhdlsynthfiles verilogsynthfiles svsynthfiles topname]
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

if {[getDef ipdir $argv] != ""} {
    cd [getDef ipdir $argv]
} else {
    puts "ipdir failed"
    exit 7
}

#clean out old files
file delete components.xml
file delete -force xgui
file delete -force delete_me

file mkdir delete_me
cd delete_me
create_project "delete_me"

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


if {[checkForKey vhdlsynthfiles $argv]} {
    if {[getDef vhdlsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "VHDL" [getDef vhdlsynthfiles $argv]
    }
}

if {[checkForKey verilogsynthfiles $argv]} {
    if {[getDef verilogsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "Verilog" [getDef verilogsynthfiles $argv]
    }
}

if {[checkForKey svsynthfiles $argv]} {
    if {[getDef svsynthfiles $argv] != ""} {
	add_files_to_set sources_1 "SystemVerilog" [getDef svsynthfiles $argv]
    }
}

set_property top [getDef topname $argv] [current_fileset]
update_compile_order -fileset sources_1

set root_dir [getDef ipdir $argv]

ipx::package_project -root_dir $root_dir  -vendor NTA -library user -taxonomy /UserIP

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $root_dir [current_project]
update_ip_catalog

close_project

if {![checkForKey "-nodelete" $argv]} {
    file delete -force "$root_dir/delete_me"
}

puts "Completed Execution of $argv0"
