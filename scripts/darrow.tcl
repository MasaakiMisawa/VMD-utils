###########################################################################
## L. darrow: Draw Arrows on Selected Atoms                              ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  darrow $filename                                                     ##
##                                                                       ##
## (data file format)                                                    ##
##                                                                       ##
## 3                 #number of arrows in frame 0                        ##
## 1  1.0  0.0  0.0  #atom index, vector vx, vy, vz                      ##
## 5  1.0  1.0  1.0  #atom index, vector vx, vy, vz                      ##
## 10 1.0  1.0  0.0  #atom index, vector vx, vy, vz                      ##
## 4                 #number of arrows in frame 1                        ##
## .                                                                     ##
## .                                                                     ##
##                                                                       ##
## Vector components will not be normalized automatically.               ##
## Default color is green.                                               ##
##                                                                       ##
###########################################################################

proc darrow {filename} {
  set datfile [open $filename r]
  set nfram [molinfo top get numframes]
  global pos1
  global pos2
  global natm
  for {set ii 0} {$ii < $nfram} {incr ii} {
    set natm($ii) [gets $datfile]
    set sel [atomselect top all frame $ii]
    for {set i 0} {$i < $natm($ii)} {incr i} {
      set dat [gets $datfile]
      set pos1($ii,$i) {}
      set pos2($ii,$i) {}
      lappend pos1($ii,$i) [lindex [$sel get x] [expr [lindex $dat 0] - 1]]
      lappend pos1($ii,$i) [lindex [$sel get y] [expr [lindex $dat 0] - 1]]
      lappend pos1($ii,$i) [lindex [$sel get z] [expr [lindex $dat 0] - 1]]
      lappend pos2($ii,$i) [lindex $dat 1]
      lappend pos2($ii,$i) [lindex $dat 2]
      lappend pos2($ii,$i) [lindex $dat 3]
    }
  }
  global vmd_frame;
  set f $vmd_frame([molinfo top])
  trace variable vmd_frame([molinfo top]) w drawar
}

proc stopar {} {
  global vmd_frame
  trace vdelete vmd_frame([molinfo top]) w drawar
}

proc drawar { name element op } {
  global vmd_frame
  global pos1
  global pos2
  global natm
  set f $vmd_frame([molinfo top])
  draw delete all
  draw color green
  for {set i 0} {$i < $natm($f)} {incr i} {
    draw cylinder $pos1($f,$i) [vecadd $pos1($f,$i) [vecscale $pos2($f,$i) 1]] radius 0.1
    draw cone [vecadd $pos1($f,$i) [vecscale $pos2($f,$i) 1]] [vecadd $pos1($f,$i) [vecscale $pos2($f,$i) 1.4]] radius 0.2
  }
}
