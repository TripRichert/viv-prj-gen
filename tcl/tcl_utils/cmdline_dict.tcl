#see copywrite notice(s) at bottom of file

## \file cmdline_dict.tcl
# \brief Defines dictionary for commandline arguments
# pass the dictionary string as a series of pairs of -key value


namespace eval diction {}

## getKeys
# \brief returns keys of passed dictionary
# \param args string of -key value pairs
# \return string of keys
proc diction::getKeys { args } {
    set keylist {}
    foreach arg $args {
	if {[string match -* $arg]} {
	    if {[string match --* $arg]} {
	    } else {
		lappend keylist [string trim $arg "-"]
	    }
	}
    }
    return $keylist
}

## getDef
# \brief returns keys of passed dictionary
# \param key to search for to get corresponding definition
# \param args string of -key value pairs
# \return value associated with passed key or "" if not found
proc diction::getDef { key args} {
    if {![diction::checkForKey $key {*}$args]} {
        return {}
    }
    set index 0
    while {$index != [llength $args] && ![string match "-$key" [lindex  $args $index]]} {
	incr index
    }
    if {$index == [llength $args]} {
	return {}
    }
    set deflist {}
    incr index
    while {$index != [llength $args] && ![string match "-*" [lindex $args $index]]} {
	lappend deflist [lindex $args $index]
	incr index
    }
    return $deflist 
}

## hasDuplicates
# \brief checks for duplicate -key in passed string
# \param args string of -key value pairs
# \return true if duplicates are detected
proc diction::hasDuplicates { args } {
    if {[llength [lsort -unique [join $args]]] != [llength [join $args]]} {
	return true
    }
    return false
}

## checkForKey
# \brief checks dictionary string to see if -key is a key
# \param key is the -key to search for
# \param args string of -key value pairs
# \return true if match is detected
proc diction::checkForKey { key args } {
    set keys [diction::getKeys {*}$args]
    if {[lsearch $keys $key] != -1} {
	return true
    } else {
	return false
    }
}

## checkForKeyPair
# \brief checks dictionary string to see if -key is a key and has a value
# \param key is the -key to search for
# \param args string of -key value pairs
# \return true if match is detected
proc diction::checkForKeyPair { key args } {
    if {[diction::checkForKey $key {*}$args]} {
	if {[diction::getDef $key {*}$args] != ""} {
	    return true
	}
    }
    return false
}


## requireKey
# \brief exits program if passed key is not in dictionary
# \param key is the -key to search for
# \param args string of -key value pairs
proc diction::requireKey { key args} {
    if {![diction::checkForKeyPair $key {*}$args]} {
	puts "no $key defined"
        set keys [diction::getKeys {*}$args]
        puts "in keys: $keys"
	exit 4
    }
}

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
