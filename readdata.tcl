###########################################################################
##  G. readdata: Read Trajectory Value as "User" Variable                ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  readdata $filename -clm $i -var $var                                 ##
##    $filename: path of datafile                                        ##
##    $i: data column (default: 1)                                       ##
#e    $var: variable name (default: user) e.g. user, user2, user3, ...   ##
##                                                                       ##
##  example:                                                             ##
##    readdata ./coordination.dat -clm 2 -var user2                      ##
##                                                                       ##
##  datafile format:                                                     ##
##  ---------------------                                                ##
##  DAT 1.0   #value for atom 1, step 0                                  ##
##  DAT 2.0   #value for atom 2, step 0                                  ##
##  DAT 1.5   #value for atom 3, step 0                                  ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ## 
##  DAT 1.2   #value for atom n, step 0                                  ##
##  END       #end frame                                                 ##
##  DAT 1.0   #value for atom 1, step 1                                  ##
##  DAT 2.0   #value for atom 2, step 1                                  ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ##
##                                                                       ##
###########################################################################

proc readdata {args} {
  set var user
  set clm 1
  for {set i 0} {$i < [llength $args]} {incr i} {
    if {[lindex $args $i] == "-clm"} then {
      set clm [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-var"} then {
      set var [lindex $args [expr $i + 1]]
      incr i
    } else {
      set filename [lindex $args $i]
    }
  }

  set all [atomselect top all]
  set frame 0
  set in [open $filename r]
  set alpha {}

  while { [gets $in line] != -1 } {
    switch -- [string range $line 0 2] {
      DAT {
        #lappend alpha [expr [string range $line $ini $fin] ]
        #set ldat [gets $in]
        lappend alpha [lindex $line $clm]
      }
          END {
        $all frame $frame
        $all set $var $alpha
        set alpha {}
        incr frame
          }
    }
  }
}
