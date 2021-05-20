###########################################################################
## I. readeigvs: Linear Combination of Eienvalue data sets               ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  read eigv (filename1) (filename2) ... as (dataname)                  ##
##                                                                       ##
##  Memo:                                                                ##
##   Lattice parameters are required                                     ##
##   Only for orthorhombic cell (?)                                      ##
##   Eigenvalue file in QXMD code is only available                      ##
##                                                                       ##
###########################################################################

# puts "readeigvs"
proc readeigvs {args} {
  set molid top
  set nargs [llength $args]
  set nfil 0

  for {set ii 0} {$ii < $nargs} {incr ii} {
    set filename($ii) [lindex $args $ii]
    set rfile [open $filename($ii) r]
    set vorigin [gets $rfile]
    incr nfil
    if {[lindex $vorigin 0] == -1} then {
    vmdcon -warn "readeigv: file format error"
    return
    }

    set vgrid [gets $rfile]
    set ngrid [expr [lindex $vgrid 0]*[lindex $vgrid 1]*[lindex $vgrid 2]]
#    set evfact [gets $rfile]
    set evfact [format "%.7f" [gets $rfile]]
    puts $evfact
    set valList($ii) ""
    set xVec [molinfo top get a]
    lappend xVec 0
    lappend xVec 0
    set yVec 0
    lappend yVec [molinfo top get b]
    lappend yVec 0
    set zVec 0
    lappend zVec 0
    lappend zVec [molinfo top get c]

#    set nn 0
    puts "start readig $filename($ii)"
    for {set j 0} {$j < $ngrid} {incr j} {
      set n [gets $rfile]
      set eval [gets $rfile]
      for {set i 0} {$i < $n} {incr i} {
#        lappend valList($ii) $eval
        lappend valList($ii) [format "%.6f" [expr $eval*$evfact]]
      }
      incr j [expr $n - 1]
#      set nn [expr $nn + $n]
    }

#    puts "ngrid = $ngrid value = $nn"
    puts "end reading $filename($ii)"
    close $rfile

    if {[lindex $args [expr $ii + 1]] == "as"} then {
      set vdnam [lindex $args [expr $ii + 2]]
      incr ii 2
    } else {
      set vdnam $filename($ii)
    }
  }
  set valListsum $valList(0) 
  puts "start sum" 
  for {set jj 1} {$jj < $nfil} {incr jj} {
    set valListsum [vecadd $valListsum $valList($jj)]    
  }
  puts "end sum" 
 
  mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] $valListsum
#  mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] [vecscale $evfact $valListsum]
  puts "accepted as $vdnam"
}
