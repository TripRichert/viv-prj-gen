proc comp_file {file1 file2} {
    set equal 0
    if {[file size $file1] == [file size $file2]} {
        set fh1 [open $file1 r]
        set fh2 [open $file2 r]
        set equal [string equal [read $fh1] [read $fh2]]
        close $fh1
        close $fh2
    }
    return $equal
}
set retval [expr 1 - [comp_file [lindex $argv 0] [lindex $argv 1]]]
puts $retval
exit $retval
