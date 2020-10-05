#see copywrite notice(s) at bottom of file

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
    if {$filetype != "IP"} {
	foreach filename $files {
	    set file_obj [get_files -of_objects [get_filesets $filesettype] $filename]
	    set_property file_type $filetype $file_obj
	}
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
	regsub -all { } "[file normalize $filename]" {\ } newfilename
	lappend files $newfilename
    }
    puts $files
    foreach filename $files {
	if { $isScoped } {
	    set modulename "[file rootname [file tail $filename]]"
	    regsub -all {\\\s} $modulename {_} modulename
	    set_property SCOPED_TO_REF $modulename "[get_files $filename]"
	}
    }
    set_property PROCESSING_ORDER $order [get_files [join $files]]
    return
}

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
