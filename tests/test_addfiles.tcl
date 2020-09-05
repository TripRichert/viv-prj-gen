package require tcltest
namespace import ::tcltest::*

source [file join [file dirname [info script]] \
	    "../tcl/helper_procs/vivprj.tcl"]
set filename [file normalize [file join [file dirname [info script]]\
				  hdl DFlipFlop.vhdl]]

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


test getKeys_vivprj {
} -body {
    set fileset ""
    catch {
	setup_prj
	vivprj::add_files_to_set sources_1 VHDL $filename

	set tmplist [get_files -of_objects [get_filesets sources_1]]
	set filelist ""
	foreach pathname $tmplist {
	    lappend filelist [file tail $pathname]
	}
    } 
    cleanup_prj
    set filelist $filelist
} -result "DFlipFlop.vhdl"

tcltest::runAllTests
file delete vivado.jou
file delete vivado.log
exit $exitCode
