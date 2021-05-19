###########################################################################
##  G. readdata: Read Trajectory Value as "User" Variable                ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  readdata $filename -str $i $j -var $var                              ##
##    $filename: path of datafile                                        ##
##    $i, $j: data strength (default: $i = 4, $j = 6)                    ##
#e    $var: variable name (default: user) e.g. user, user2, user3, ...   ##
##                                                                       ##
##  example:                                                             ##
##    readdata ./coordination.dat -var use2                              ##
##                                                                       ##
##  datafile format:                                                     ##
##  ---------------------                                                ##
##  DATA 1.0   #value for atom 1, step 0                                 ##
##  DATA 2.0   #value for atom 2, step 0                                 ##
##  DATA 1.5   #value for atom 3, step 0                                 ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ## 
##  DATA 1.2   #value for atom n, step 0                                 ##
##  END                                                                  ##
##  DATA 1.0   #value for atom 1, step 1                                 ##
##  DATA 2.0   #value for atom 2, step 1                                 ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ##
##                                                                       ##
###########################################################################

proc readdata {args} {
  set var user
  set ini 4 
  set fin 11
  for {set i 0} {$i < [llength $args]} {incr i} {
    if {[lindex $args $i] == "-str"} then {
      set ini [lindex $args [expr $i + 1]]
      set fin [lindex $args [expr $i + 2]]
      incr i 2
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
        lappend alpha [expr [string range $line $ini $fin] ]
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
