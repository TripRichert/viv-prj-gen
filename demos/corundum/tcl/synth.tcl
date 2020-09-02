set requiredMiscKeys synthbasescript

foreach key $requiredMiscKeys {
    requireKey $key $miscparams
}

if {[checkForKey synthbasescript $miscparams]} {
    if {[getDef synthbasescript $miscparams] != ""} {
	source [getDef synthbasescript $miscparams]
    }
}

if {[checkForKey postsynthscripts $miscparams]} {
    foreach script [getDef postsynthscripts $miscparams] {
	source $script
    }
}

