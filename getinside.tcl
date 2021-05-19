###########################################################################
## M. getinside: Get Serial Number of Atoms in PBC Box                   ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  getinside                     #all atoms                             ##
##  getinside -sel "selection"    #selected atoms                        ##
##  getinside -ovl                #check overlapping atoms               ##
##                                                                       ##
###########################################################################

proc getinside {args} {
  set sel all
  set lovl 0
  lappend args
  set laug [llength $args]
  for {set i 0} {$i < $laug} {incr i} {
    if {[lindex $args $i] == "-sel"} then {
      set sel [lindex $args [expr $i + 1]]
      if {$sel == ""} then {
        set sel all
      } elseif {$sel == "-ovl"} then {
        set sel all
        set lovl 1
      }
      incr i 
    } elseif {[lindex $args $i] == "-ovl"} then {
      set lovl 1
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
  set list {}
  set ii 0
  set ovlc 0
  for {set i 0} {$i < $n} {incr i} {
    set dat {}
    set inum [lindex [[atomselect top $sel frame now] get serial] $i]
    set x [[atomselect top "serial $inum" frame $nframe] get x]
    set y [[atomselect top "serial $inum" frame $nframe] get y]
    set z [[atomselect top "serial $inum" frame $nframe] get z]
    set x2 [expr $x*$axi + $y*$bxi + $z*$cxi]
    set y2 [expr $x*$ayi + $y*$byi + $z*$cyi]
    set z2 [expr $x*$azi + $y*$bzi + $z*$czi]
    set x [format "%.6f" [expr $x2/$lx]]
    set y [format "%.6f" [expr $y2/$ly]]
    set z [format "%.6f" [expr $z2/$lz]]
    if {$lovl == 1} then {
      set x3($i) $x
      set y3($i) $y
      set z3($i) $z
      if {$i != 0} then {
        for {set j 0} {$j < $i} {incr j} {
          set dx [expr abs($x - $x3($j))]
          set dy [expr abs($y - $y3($j))]
          set dz [expr abs($z - $z3($j))]
          if {$dx > 0.5} then {
            set dx [expr 1.0 - $dx] 
          }
          if {$dy > 0.5} then {
            set dy [expr 1.0 - $dy] 
          }
          if {$dz > 0.5} then {
            set dz [expr 1.0 - $dz] 
          }
          set rdx [expr $dx*$lx*$ax + $dy*$ly*$bx + $dz*$lz*$cx]
          set rdy [expr $dx*$lx*$ay + $dy*$ly*$by + $dz*$lz*$cy]
          set rdz [expr $dx*$lx*$az + $dy*$ly*$bz + $dz*$lz*$cz]
          set dis [expr sqrt($rdx*$rdx + $rdy*$rdy + $rdz*$rdz)]
          if {$dis < 0.5} then {
            set jnum [lindex [[atomselect top $sel frame now] get serial] $j]
            puts "overlap serial $jnum and $inum"
            incr ovlc
          }
        }
      }
    }
    if {$x >= 0.0 && $x <= 1.0} then {
      if {$y >= 0.0 && $y <= 1.0} then {
        if {$z >= 0.0 && $z <= 1.0} then {
          lappend list $inum
          incr ii
        }
      }
    }
  }
  puts "number of atoms = $ii"
  puts "serial number:"
  puts $list
  if {$lovl == 1 && $ovlc == 0} then {
     puts "no overlapping atoms"
  } 
}
