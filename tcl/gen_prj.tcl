#see copywrite notice(s) at bottom of file

puts "executing $argv0"
puts "argv is:$argv"

#get procs to parse cmdline arguments
source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]
#procs to add files to vivado projects
source [file join [file dirname [info script]] "helper_procs/vivprj.tcl"]

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


if {[diction::getDef builddir {*}$argv] != ""} {
    cd [diction::getDef builddir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}
file mkdir [diction::getDef prjname {*}$argv]
cd [diction::getDef prjname {*}$argv]

create_project [diction::getDef prjname {*}$argv]

set obj [current_project]
set partname [diction::getDef partname {*}$argv]
set_property "part" "$partname" [current_project]
if {[diction::checkForKey target_language {*}$argv]} {
    set_property target_language [diction::getDef target_language {*}$argv] [current_project]
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

if {[diction::checkForKey vhdl08synthfiles {*}$argv]} {
    if {[diction::getDef vhdl08synthfiles {*}$argv] != ""} {
	vivprj::add_files_to_set sources_1 "VHDL 2008" {*}[diction::getDef vhdl08synthfiles {*}$argv]
	vivprj::add_files_to_set sim_1 "VHDL 2008" {*}[diction::getDef vhdl08synthfiles {*}$argv]
    }
}

if {[diction::checkForKeyPair vhdl08simfiles {*}$argv]} {
    vivprj::add_files_to_set sim_1 \
	"VHDL 2008" {*}[diction::getDef vhdl08simfiles {*}$argv]
}

if {[diction::checkForKeyPair vhdlsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"VHDL" {*}[diction::getDef vhdlsynthfiles {*}$argv]
    vivprj::add_files_to_set sim_1 \
	"VHDL" {*}[diction::getDef vhdlsynthfiles {*}$argv]
}

if {[diction::checkForKeyPair vhdlsimfiles {*}$argv]} {
    vivprj::add_files_to_set sim_1 "VHDL" {*}[diction::getDef vhdlsimfiles {*}$argv]
}

if {[diction::checkForKeyPair verilogsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"Verilog" {*}[diction::getDef verilogsynthfiles {*}$argv]
    vivprj::add_files_to_set sim_1 \
	"Verilog" {*}[diction::getDef verilogsynthfiles {*}$argv]
}

if {[diction::checkForKeyPair verilogsimfiles {*}$argv]} {
    vivprj::add_files_to_set sim_1 \
	"Verilog" {*}[diction::getDef verilogsimfiles {*}$argv]
}

if {[diction::checkForKeyPair systemverilogsynthfiles {*}$argv]} {
    vivprj::add_files_to_set sources_1 \
	"SystemVerilog" {*}[diction::getDef systemverilogsynthfiles {*}$argv]
    vivprj::add_files_to_set sim_1 \
	"SystemVerilog" {*}[diction::getDef systemverilogsynthfiles {*}$argv]
}

if {[diction::checkForKeyPair systemverilogsimfiles {*}$argv]} {
    vivprj::add_files_to_set sim_1 \
	"SystemVerilog" {*}[diction::getDef systemverilogsimfiles {*}$argv]
}


if {[diction::checkForKeyPair scopedearlyconstraints {*}$argv]} {
    vivprj::add_const_files_to_set true \
	early {*}[diction::getDef scopedearlyconstraints {*}$argv]
}
if {[diction::checkForKeyPair scopednormalconstraints {*}$argv]} {
    vivprj::add_const_files_to_set true \
	normal {*}[diction::getDef scopednormalconstraints {*}$argv]
}
if {[diction::checkForKeyPair scopedlateconstraints {*}$argv]} {
    vivprj::add_const_files_to_set true \
	late {*}[diction::getDef scopedlateconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopedearlyconstraints {*}$argv]} {
    vivprj::add_const_files_to_set false \
	early {*}[diction::getDef unscopedearlyconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopednormalconstraints {*}$argv]} {
    vivprj::add_const_files_to_set false \
	normal {*}[diction::getDef unscopednormalconstraints {*}$argv]
}
if {[diction::checkForKeyPair unscopedlateconstraints {*}$argv]} {
    vivprj::add_const_files_to_set false \
	late {*}[diction::getDef unscopedlateconstraints {*}$argv]
}

if {[diction::checkForKeyPair datafiles {*}$argv]} {
    vivprj::add_files_to_set sim_1 \
	"Data Files" {*}[diction::getDef datafiles {*}$argv]
}

puts "Completed Execution of $argv0"

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
