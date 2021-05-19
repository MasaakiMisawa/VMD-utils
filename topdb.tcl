###########################################################################
## B. topdb: Export Selected Frames and Atoms as a PDB Trajectory File   ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  topdb $i $j $filename                                                ##
##    $i: start frame                                                    ##
##    $j: end frame                                                      ##
##                                                                       ##
##  topdb -skip $sk -sel $selection $i $j $filename                      ##
##    $selsction: selection of atoms (like as "name Fe O")               ##
##    $sk: skip frames                                                   ##
##                                                                       ##
## Example: topdb -skip 5 0 100 trajectory.pdb                           ##
##                                                                       ##
###########################################################################

proc topdb {args} {
  set start 0
  set end 0
  set sel [atomselect top all]
  set sk 1
  for {set i 0} {$i < [llength $args]} {incr i} {
    if {[lindex $args $i] == "-sel"} then {
      set sel [atomselect top [lindex $args [expr $i + 1]]]
      incr i 
    } elseif {[lindex $args $i] == "-skip"} then {
      set sk [lindex $args [expr $i + 1]]
      incr i
    } else {
      set start [lindex $args $i]
      set end  [lindex $args [expr $i + 1]]
      set filename [lindex $args [expr $i + 2]]
      incr i 2
    }
  }

  if {$filename == ""} then {
    set filename config.pdb  
   }
  if {$start == ""} then {
    set start 0  
   }
  if {$end == ""} then {
    set end 0  
   }

  for {set i $start} {$i < [expr $end + 1]} {incr i $sk} {
    $sel frame $i
    if {$i == $start} then {
      $sel writepdb $filename
    } else {
      $sel writepdb ./pdbframe.pdb
      exec cat pdbframe.pdb >> $filename
    }
  }
  if {$start != $end} then { 
    exec rm pdbframe.pdb
  }
  return
}
