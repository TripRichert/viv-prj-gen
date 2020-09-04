## \file cmdline_dict.tcl
# \brief Defines dictionary for commandline arguments
# pass the dictionary string as a series of pairs of -key value 

namespace eval dict {}

## getKeys
# \brief returns keys of passed dictionary
# \param args string of -key value pairs
# \return string of keys
proc dict::getKeys { args } {
    set keylist {}
    foreach arg [join $args] {
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
proc dict::getDef { key args} {
    if {![dict::checkForKey $key [join $args]]} {
        return {}
    }
    set index 0
    while {$index != [llength [join $args]] && ![string match "-$key" [lindex [join $args] $index]]} {
	incr index
    }
    if {$index == [llength [join $args]]} {
	return {}
    }
    set deflist {}
    incr index
    while {$index != [llength [join $args]] && ![string match "-*" [lindex [join $args] $index]]} {
	lappend deflist [lindex [join $args] $index]
	incr index
    }
    return $deflist 
}

## hasDuplicates
# \brief checks for duplicate -key in passed string
# \param args string of -key value pairs
# \return true if duplicates are detected
proc dict::hasDuplicates { args } {
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
proc dict::checkForKey { key args } {
    set keys [dict::getKeys [join $args]]
    if {[lsearch $keys $key] != -1} {
	return true
    } else {
	return false
    }
}

## requireKey
# \brief exits program if passed key is not in dictionary
# \param key is the -key to search for
# \param args string of -key value pairs
proc dict::requireKey { key args} {
    set fail false
    if {![dict::checkForKey $key [join $args]]} {
	set fail true
    } else {
	if {[dict::getDef $key [join $args]] == ""} {
	    set fail true
	}
    }
    if {$fail} {	
	puts "no $key defined"
        set keys [dict::getKeys [join $args]]
        puts "in keys: $keys"
	exit 4
    }
    return
}
