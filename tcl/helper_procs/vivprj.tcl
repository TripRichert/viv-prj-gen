## \file vivprj.tcl
# \brief adds files to vivado project

namespace eval vivprj {}

## add_files_to_set
# \brief adds passed filenames to project fileset
# \param filesettype the fileset to add to (e.g. sources_1)
# \param filetype the type of file (e.g. VHDL)
# \param args list of files
proc vivprj::add_files_to_set { filesettype filetype args} {
    set obj [get_filesets $filesettype]
    set files []
    set missingFiles []
    foreach filename $args {
        if {[file exists [join $filename]]} {
	    regsub -all { } "[file normalize $filename]" {\ } newfilename
            lappend files $newfilename
        } else {
            lappend missingFiles $filename
        }
    }
    if {[llength $missingFiles]} {
        puts "these files don't exist yet : $missingFiles"
        puts "exiting due to missing files"
        exit 6
    }
    add_files -norecurse -fileset $obj [join $files]
    foreach filename $files {
	set file_obj [get_files -of_objects [get_filesets $filesettype] $filename]
	set_property file_type $filetype $file_obj
    }
    return
}

## add_const_files_to_set
# \brief adds xdc filenames to project fileset
# \param isScoped true if constraint is scoped to ref of its own filename
# \param order when the constraint is applied (early, normal, or late)
# \param args list of files
proc vivprj::add_const_files_to_set { isScoped order args } {
    vivprj::add_files_to_set constrs_1 "XDC" {*}$args
    set files []
    foreach filename $args {
        lappend files [file normalize $filename]
    }
    foreach filename [join $files] {
	if { $isScoped } {
	    set_property SCOPED_TO_REF [file rootname [file tail $filename]] [get_files $filename]
	}
    }
    set_property PROCESSING_ORDER $order [get_files $files]
    return
}
