package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] \
	    "../tcl/helper_procs/vivprj.tcl"]


set vhdl_file [file normalize [file join [file dirname [info script]]\
				  "hdl files" DFlipFlop.vhdl]]

set vhdlSpace_file [file normalize [file join [file dirname [info script]]\
				  "hdl files" "test space.vhdl"]]

set constrSpace_file [file normalize [file join [file dirname [info script]]\
					  "constraints" "test space.xdc"]]

file delete -force test_addfiles

proc tcltest::cleanupTestsHook {} {
    variable numTests
    set ::exitCode [expr {$numTests(Failed) > 0}]
}

proc setup_prj {} {
    file mkdir test_addfiles
    cd test_addfiles
    create_project tmp
    if {[string equal [get_filesets -quiet sources_1] ""]} {
	create_fileset -srcset sources_1
    }
    cd ..
}

proc cleanup_prj {} {
    file delete -force test_addfiles
}


test addFiles_spacepath {
} -body {
    set filelist ""
    catch {
	setup_prj
	vivprj::add_files_to_set sources_1 VHDL "$vhdl_file"

	set tmplist [get_files -of_objects [get_filesets sources_1]]
	set filelist ""
	foreach pathname $tmplist {
	    lappend filelist [file tail $pathname]
	}
    } 
    cleanup_prj
    set filelist $filelist
} -result "DFlipFlop.vhdl"

test addConst_spacepath {
} -body {
    set filelist ""
    catch {
	setup_prj
	vivprj::add_const_files_to_set false normal "$constrSpace_file"
	set tmplist [get_files -of_objects [get_filesets constrs_1]]
	set filelist ""
	foreach pathname $tmplist {
	    lappend filelist [file tail $pathname]
	}
    } 
    cleanup_prj
    set filelist $filelist
} -result "{test space.xdc}"

test addConst_scoped {
} -body {
    set result_str ""
    catch {
	setup_prj
	vivprj::add_files_to_set sources_1 VHDL "$vhdlSpace_file"
	vivprj::add_const_files_to_set true normal "$constrSpace_file"
	regsub -all { } "$constrSpace_file" {\ } clean_filename
	set result_str [get_property SCOPED_TO_REF [get_files $clean_filename]]
    } 
    cleanup_prj
    set result_str $result_str
} -result "test_space"

tcltest::runAllTests
file delete vivado.jou
file delete vivado.log
exit $exitCode


###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert

#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
