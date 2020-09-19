#see copywrite notice(s) at bottom of file

puts "executing $argv0"
puts "argv is: $argv"

source [file join [file dirname [info script]] "helper_procs/cmdline_dict.tcl"]


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

set requiredKeys [list xcipath gendir partname]
set allowedKeys [list target_language]
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

if {[diction::getDef gendir {*}$argv] != ""} {
    cd [diction::getDef gendir {*}$argv]
} else {
    puts "builddir failed"
    exit 7
}

create_project -in_memory -part [diction::getDef partname {*}$argv]

set ip_gen_dir [pwd]
set xcipath [diction::getDef xcipath {*}$argv]
file mkdir [file rootname [file tail $xcipath]]
file copy $xcipath [file rootname [file tail $xcipath]]/
if {[diction::checkForKeyPair target_language {*}$argv]} {
    set_property target_language \
	[diction::getDef target_language {*}$argv] [current_project]
} else {
    set_property target_language VHDL [current_project]
}

read_ip [file rootname [file tail $xcipath]]/[file tail $xcipath]
generate_target all [get_ips]

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
