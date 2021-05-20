###########################################################################
## H. readeigv: Read Eienvalue as Volmetric Data Set                     ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  readeigv (filename)                                                  ##
##   --- filename: qm_eigv.d.***** (raw data from pwp)                   ##
##                                                                       ##
##  read eigv (filename) (filename2)                                     ##
##   --- read 2 files                                                    ##
##                                                                       ##
##  read eigv (filename) as (dataname)                                   ##
##   --- input data as name of (dataname)                                ##
##                                                                       ##
## (example)                                                             ##
##  read eigv qm_eigv.d.5.00000 as HOMO qm_eigv.d.7.00000 as "LUMO 2"    ##
##                                                                       ##
##  Memo:                                                                ##
##   Lattice parameters are required                                     ##
##   Only for orthorhombic cell (?)                                      ##
##   New format: readeigv2 (2016.1.8)                                    ##
##   Eigenvalue file in QXMD code is only available                      ##
##                                                                       ##
###########################################################################

proc readeigv {args} {
  set molid top
  set nargs [llength $args]

  for {set ii 0} {$ii < $nargs} {incr ii} {
    set filename($ii) [lindex $args $ii]
    set rfile [open $filename($ii) r]
    set vorigin [gets $rfile]
    if {[lindex $vorigin 0] == -1} then {
    vmdcon -warn "readeigv: file format error"
    return
    }
    set vgrid [gets $rfile]
    set ngrid [expr [lindex $vgrid 0]*[lindex $vgrid 1]*[lindex $vgrid 2]]
#    set evfact [gets $rfile]
    set evfact [format "%.7f" [gets $rfile]]
    puts $evfact
    set valList ""
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
        lappend valList $eval
#        lappend valList [format "%.6f" [expr $eval*$evfact]]
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
    #mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] $valList
    mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] [vecscale $evfact $valList]
    puts "accepted as $vdnam"
  }
}

proc readeigv2 {args} {
  set molid top
  set nargs [llength $args]

  for {set ii 0} {$ii < $nargs} {incr ii} {
    set filename($ii) [lindex $args $ii]
    set rfile [open $filename($ii) r]
    set dummy [gets $rfile]

    if {[lindex $dummy 0] == 0} then {
    vmdcon -warn "readeigv2: file format error"
    return
    }

    set ovorigin [gets $rfile]
    set ovgrid [gets $rfile]
    set shorigin [gets $rfile]
#    set evfact [gets $rfile]
    set evfact [format "%.7f" [gets $rfile]]
    puts $evfact
    set valList ""
    
    set lgx [lindex $shorigin 3]
    set lgy [lindex $shorigin 4]
    set lgz [lindex $shorigin 5]

#    puts "$lgx $lgy $lgz"

    set vorigin [expr [lindex $shorigin 0]*[molinfo top get a]/[lindex $ovgrid 0]]
    lappend vorigin [expr [lindex $shorigin 1]*[molinfo top get b]/[lindex $ovgrid 1]]
    lappend vorigin [expr [lindex $shorigin 2]*[molinfo top get c]/[lindex $ovgrid 2]]

    set xVec [expr $lgx*[molinfo top get a]/[lindex $ovgrid 0]]
    lappend xVec 0
    lappend xVec 0
    set yVec 0
    lappend yVec [expr $lgy*[molinfo top get b]/[lindex $ovgrid 1]]
    lappend yVec 0
    set zVec 0
    lappend zVec 0
    lappend zVec [expr $lgz*[molinfo top get c]/[lindex $ovgrid 2]]

    set vgrid $lgx
    lappend vgrid $lgy
    lappend vgrid $lgz
    set ngrid [expr $lgx*$lgy*$lgz]
#    set nn 0

    puts "start reading $filename($ii)"
    for {set j 0} {$j < $ngrid} {incr j} {
      set n [gets $rfile]
      set eval [gets $rfile]
      for {set i 0} {$i < $n} {incr i} {
        lappend valList $eval
#        lappend valList [format "%.6f" [expr $eval*$evfact]]
      }
      incr j [expr $n - 1]
#      set nn [expr $nn + $n]
    }

    puts "end reading $filename($ii)"
#    puts "ngrid = $ngrid value = $nn"
    close $rfile
    if {[lindex $args [expr $ii + 1]] == "as"} then {
      set vdnam [lindex $args [expr $ii + 2]]
      incr ii 2
    } else {
      set vdnam $filename($ii)
    }
    #mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] $valList
     mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] [vecscale $evfact $valList]
    puts "accepted as $vdnam"
  }
}
