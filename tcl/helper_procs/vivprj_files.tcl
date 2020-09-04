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
        exit 6
    }
    add_files -norecurse -fileset $obj $files
    foreach filename $files {
	set file_obj [get_files -of_objects [get_filesets $filesettype] $filename]
	set_property file_type $filetype $file_obj
    }
}

proc add_const_files_to_set { isScoped order args } {
    add_files_to_set constrs_1 "XDC" [join $args]
    set files []
    foreach filename [join $args] {
        lappend files [file normalize $filename]
    }
    foreach filename [join $files] {
	if { $isScoped } {
	    set_property SCOPED_TO_REF [file rootname [file tail $filename]] [get_files $filename]
	}
    }
    set_property PROCESSING_ORDER $order [get_files [join $files]]	
}
