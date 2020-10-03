package require tcltest
namespace import ::tcltest::*
source [file join [file dirname [info script]] \
	    "..//cmdline_dict.tcl"]

proc tcltest::cleanupTestsHook {} {
    variable numTests
    set ::exitCode [expr {$numTests(Failed) > 0}]
}

test getKeys_oneKey {
} -body {
    diction::getKeys diction::getKeys garbagestart -blue food
} -result "blue"

test getKeys_threeKeys {
} -body {
    diction::getKeys diction::getKeys -red rose -blue food -green grass
} -result "red blue green"

test getKeys_longerKey {
} -body {
    diction::getKeys "-red key" rose -blue food -green grass
} -result "{red key} blue green"

test getKeys_longerDef {
} -body {
    diction::getKeys -red apple rose blood -blue food sky -green grass coder
} -result "red blue green"

test getKeys_emptyKey {
} -body {
    diction::getKeys -red -blue -green
} -result "red blue green"

test getKeys_emptyKey {
} -body {
    diction::getKeys -red -blue -green
} -result "red blue green"

test getKeys_defWithHyphen {
} -body {
    diction::getKeys -applepie viv-prj-gen
} -result "applepie"

test getKeys_nested {
} -body {
    diction::getKeys -findyourinnerdictionary "gap -red rose -blue food" -key a
} -result "findyourinnerdictionary key"
    
test getKeys_nestedNoGap {
} -body {
    diction::getKeys -key0 "-key1 a -key2 b"
} -result "key0 {key1 a -key2 b}"

test getDef_oneKey {
} -body {
    diction::getDef blue trash -blue food
} -result "food"

test getDef_threeKeys {
} -body {
    diction::getDef spicy -pot plant -spicy pepper -chair cushion
} -result "pepper"

test getDef_empty {
} -body {
    diction::getDef mickey -mickey -mouse trap
} -result ""

test getDef_noKey {
} -body {
    diction::getDef mykey so I walked home from the bar- and I saw this light
} -result ""

test getDef_longDef {
} -body {
    diction::getDef ok -awsome shrike -majestic "bald eagle" -ok "blue jay" -e
} -result "{blue jay}"

test getDef_nested {
} -body {
    diction::getDef miscparams -myfile ../applepie.txt \
	-miscparams "args -red rose apple -blue food -green grass noob" \
	-key pair
} -result "{args -red rose apple -blue food -green grass noob}"

test hasDuplicates_yes {
} -body {
    diction::hasDuplicates -red apple -blue food -red blood
} -result "true"

test hasDuplicates_no {
} -body {
    diction::hasDuplicates -red apple -blue food
} -result "false"

test hasDuplicates_inrow {
} -body {
    diction::hasDuplicates -red -red apple -blue food
} -result "true"

test hasDuplicates_nodef {
} -body {
    diction::hasDuplicates -red -red
} -result "true"

test hasDuplicates_endnodef {
} -body {
    diction::hasDuplicates -key pair -red -red
} -result "true"

test checkForKeyPair_oneKeyNoDef {
} -body {
    diction::checkForKeyPair mykey -mykey
} -result "false"

test checkForKeyPair_oneKeyPair {
} -body {
    diction::checkForKeyPair mykey -mykey val
} -result "true"

test checkForKeyPair_threeKeyNoMatch {
} -body {
    diction::checkForKeyPair scotch -red rose -blue food -green grass
} -result "false"

test checkForKeyPair_noMatchHasSpace {
} -body {
    diction::checkForKeyPair red -green grass "-red key" rose
} -result "false"

test checkForKeyPair_hasSpace {
} -body {
    diction::checkForKeyPair "red key" -green grass "-red key" rose
} -result "true"

test getDef_nested {
} -body {
    diction::checkForKeyPair miscparams -myfile ../applepie.txt \
	-miscparams "args -red rose apple -blue food -green grass noob" \
	-key pair
} -result "true"

test getDef_nestedKey {
} -body {
    diction::checkForKeyPair red -myfile ../applepie.txt \
	-miscparams "args -red rose apple -blue food -green grass noob" \
	-key pair
} -result "false"

test checkForKey_oneKeyNoDef {
} -body {
    diction::checkForKey mykey -mykey
} -result "true"


tcltest::runAllTests
exit $exitCode

###############################################################################
# MIT LICENSE
###############################################################################
#Copyright 2020 Trip Richert
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
