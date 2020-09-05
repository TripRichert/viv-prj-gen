puts "executing $argv0"
puts "argv is:$argv"

#get dictionary procs to process commandline arguments
source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]

#get procs to add files to vivado
source [file join [file dirname [info script]] "helper_procs/vivprj.tcl"]

if { $argc == 0 } {
    puts "No arguments!"
    puts "execution suspended of $argv0"
    exit 2
}
if {[diction::hasDuplicates {*}[diction::getKeys {*}$argv]]} {
    puts "error! Duplicate keys!"
    puts "execution suspended of $argv0"
    exit 3
}

set requiredKeys [list ipdir ipname partname  topname]
set allowedKeys [list target_language \
		     vhdlsynthfiles verilogsynthfiles svsynthfiles \
		     preipxscripts postipxscripts miscparams]

#all required keys are allowed
foreach key $requiredKeys {
    lappend allowedKeys $key
}

foreach requiredKey $requiredKeys {
    diction::requireKey $requiredKey {*}$argv
}
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

if {[diction::getDef ipdir {*}$argv] != ""} {
    cd [diction::getDef ipdir {*}$argv]
} else {
    puts "ipdir failed"
    exit 7
}

#clean out old files
file delete components.xml
file delete -force xgui
file delete -force delete_me

#need temporary project to manage files wrapped into generated xactip
file mkdir delete_me
cd delete_me
create_project "delete_me"

set obj [current_project]
set partname [diction::getDef partname {*}$argv]
set_property "part" "$partname" [current_project]
if {[diction::checkForKeyPair target_language {*}$argv]} {
    set_property target_language \
	[diction::getDef target_language {*}$argv] [current_project]
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


if {[diction::checkForKeyPair vhdlsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"VHDL" {*}[diction::getDef vhdlsynthfiles {*}$argv]
}

if {[diction::checkForKeyPair verilogsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"Verilog" {*}[diction::getDef verilogsynthfiles {*}$argv]
}

if {[diction::checkForKeyPair svsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"SystemVerilog" {*}[diction::getDef svsynthfiles {*}$argv]
}

set_property top [diction::getDef topname {*}$argv] [current_fileset]
update_compile_order -fileset sources_1

set root_dir [diction::getDef ipdir {*}$argv]
set miscparams [diction::getDef miscparams {*}$argv]

#optional list of scripts to run before xactip is wrapped
if {[diction::checkForKeyPair preipxscripts {*}$argv]} {
    foreach script [diction::getDef preipxscripts {*}$argv] {
	source ${script}
    }
}

ipx::package_project -root_dir $root_dir  -vendor NTA -library user -taxonomy /UserIP

set_property core_revision 1 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]

#optional list of scripts to run after xactip is created (use ipx cmds)
if {[diction::checkForKeyPair postipxscripts {*}$argv]} {
    foreach script [diction::getDef postipxscripts {*}$argv] {
	source ${script}
    }
}

ipx::save_core [ipx::current_core]
set_property  ip_repo_paths  $root_dir [current_project]
update_ip_catalog

close_project

if {![diction::checkForKey "-nodelete" {*}$argv]} {
    file delete -force "$root_dir/delete_me"
}

puts "Completed Execution of $argv0"
