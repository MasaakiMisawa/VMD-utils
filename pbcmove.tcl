###########################################################################
## N. pbcmove: Move Atoms on Outside PBC Box to Inside                   ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  pbcmove                       #all atoms                             ##
##  pbcmove   -sel "selection"    #selected atoms                        ##
##                                                                       ##
###########################################################################

proc pbcmove {args} {
  set sel all
  set lovl 0
  lappend args
  set laug [llength $args]
  for {set i 0} {$i < $laug} {incr i} {
    if {[lindex $args $i] == "-sel"} then {
      set sel [lindex $args [expr $i + 1]]
      if {$sel == ""} then {
        set sel all
      }
      incr i 
    }
  }
  set nframe now
  set lx [molinfo top get a frame $nframe]
  set ly [molinfo top get b frame $nframe]
  set lz [molinfo top get c frame $nframe]
  set alpha [molinfo top get alpha frame $nframe]
  set beta [molinfo top get beta frame $nframe]
  set gamma [molinfo top get gamma frame $nframe]
  set pi 3.1415926535897946
  set cosBC [expr cos($alpha*$pi/180)]
  if {$alpha == 90.0} then {
    set cosBC 0
  }
  set sinBC [expr sin($alpha*$pi/180)]
  set sinAC [expr sin($beta*$pi/180)]
  set cosAC [expr cos($beta*$pi/180)]
  if {$beta == 90.0} then {
    set cosAC 0
  }
  set cosAB [expr cos($gamma*$pi/180)]
  if {$gamma == 90.0} then {
    set cosAB 0
  }
  set sinAB [expr sin($gamma*$pi/180)]
  set n [[atomselect top $sel frame now] num]
  set num 1
  set ax 1.0
  set ay 0.0
  set az 0.0
  set bx $cosAB
  set by $sinAB
  set bz 0.0
  set cx $cosAC
  set cy [expr ($cosBC - $cosAC * $cosAB)/$sinAB]
  set cz [expr sqrt(1.0-$cx*$cx-$cy*$cy)]
  set det [expr $ax*$by*$cz + $ay*$bz*$cx + $az*$bx*$cy - $az*$by*$cx - $ay*$bx*$cz - $ax*$bz*$cy]
  set axi [expr (1/$det)*($by*$cz - $cy*$bz)]
  set ayi [expr (1/$det)*($cy*$az - $ay*$cz)]
  set azi [expr (1/$det)*($ay*$bz - $by*$az)]
  set bxi [expr (1/$det)*($cx*$bz - $bx*$cz)]
  set byi [expr (1/$det)*($ax*$cz - $cx*$az)]
  set bzi [expr (1/$det)*($bx*$az - $ax*$bz)]
  set cxi [expr (1/$det)*($bx*$cy - $cx*$by)]
  set cyi [expr (1/$det)*($cx*$ay - $ax*$cy)]
  set czi [expr (1/$det)*($ax*$by - $bx*$ay)]
  set ii 0
  for {set i 0} {$i < $n} {incr i} {
    set inum [lindex [[atomselect top $sel frame now] get serial] $i]
    set x [[atomselect top "serial $inum" frame $nframe] get x]
    set y [[atomselect top "serial $inum" frame $nframe] get y]
    set z [[atomselect top "serial $inum" frame $nframe] get z]
    set x2 [expr $x*$axi + $y*$bxi + $z*$cxi]
    set y2 [expr $x*$ayi + $y*$byi + $z*$cyi]
    set z2 [expr $x*$azi + $y*$bzi + $z*$czi]
    set x2 [format "%.6f" [expr $x2/$lx]]
    set y2 [format "%.6f" [expr $y2/$ly]]
    set z2 [format "%.6f" [expr $z2/$lz]]
    
    for {set j 0} {$j < 1} {incr j} {
      set lout 1
      if {$x2 < 0.0} then {
        set x2 [expr $x2 + 1.0]
        set lout 0
      }
      if {$x2 >= 1.0} then {
        set x2 [expr $x2 - 1.0]
        set lout 0
      }
      if {$y2 < 0.0} then {
        set y2 [expr $y2 + 1.0]
        set lout 0
      }
      if {$y2 >= 1.0} then {
        set y2 [expr $y2 - 1.0]
        set lout 0
      }
      if {$z2 < 0.0} then {
        set z2 [expr $z2 + 1.0]
        set lout 0
      }
      if {$z2 >= 1.0} then {
        set z2 [expr $z2 - 1.0]
        set lout 0
      }
      if {$lout == 0} then {
        set j [expr $j - 1]
      }
    }

    set x2 [format "%.6f" [expr $x2*$lx]]
    set y2 [format "%.6f" [expr $y2*$ly]]
    set z2 [format "%.6f" [expr $z2*$lz]]
    set x [expr $x2*$ax + $y2*$bx + $z2*$cx]
    set y [expr $x2*$ay + $y2*$by + $z2*$cy]
    set z [expr $x2*$az + $y2*$bz + $z2*$cz]
    [atomselect top "serial $inum" frame $nframe] moveto "$x $y $z"
  }
}
