proc getKeys { args } {
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

proc getDef { key args} {
    if {![checkForKey $key [join $args]]} {
        return {}
    }
    set index 0
    while {$index != [llength [join $args]] && ![string match "-$key" [lindex [join $args] $index]]} {
	incr index
    }
    if {$index == [llength args]} {
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

proc hasDuplicates { args } {
    if {[llength [lsort -unique [join $args]]] != [llength [join $args]]} {
	return true
    }
    return false
}

proc checkForKey { key args } {
    set keys [getKeys [join $args]]
    if {[lsearch $keys $key] != -1} {
	return true
    } else {
	return false
    }
}

proc requireKey { key args} {
    set fail false
    if {![checkForKey $key [join $args]]} {
	set fail true
    } else {
	if {[getDef $key [join $args]] == ""} {
	    set fail true
	}
    }
    if {$fail} {	
	puts "no $key defined"
        set keys [getKeys [join $args]]
        puts "in keys: $keys"
	exit 4
    } 
}
