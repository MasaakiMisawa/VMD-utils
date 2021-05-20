###########################################################################
## C. pickconfig: Export Selected Frame as a Scaled Coordination File    ##
##                                                                       ##
## (How to use)                                                          ##
##  pickconfig $frame $filename -sel "selection"                         ##
##    $frame: input frame (default frame is "now")                       ##
##    $filename: output file name (default filename is "Config.dat")     ##
##    -sel "selection": output only selected atoms (default: all)        ##
##                                                                       ##
## Memo: Keywords are determined by name on VMD, not element or type     ##
##       (you can check by "[atomselect top all] get name" in Tk console)## 
##       Information of the lattice constants are required               ##
##       ("pbc set {$a $b $c $alpha $beta $gamma} -all" on Tk Console)   ##
##                                                                       ##
##       2016.8.10 apply for trigonal cell                               ##
##                                                                       ##
###########################################################################

proc pickconfig {args} {

  set nframe "" 
  set filen ""
  set sel ""
  for {set i 0} {$i < [llength $args]} {incr i} {
    if {[lindex $args $i] == "-sel"} then {
      set sel [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[catch {expr [lindex $args $i]}] == 0} then {
      set nframe [lindex $args $i]
    } else {
      set filen [lindex $args $i]
    }
  }
 
  if {$nframe == ""} then {
    set nframe now
  } 
  if {$filen == ""} then {
    set filen Config.dat
  }
  if {$sel == ""} then {
    set sel all
  } 

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
  #set n [molinfo top get numatoms]
  set wfile [open $filen w]
  set nkey 1
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
  set n [[atomselect top $sel] num]
  for {set i 0} {$i < $n} {incr i} {
    set dat {} 
    set ii [lindex [[atomselect top $sel] get index] $i] 
    set x [[atomselect top "index $ii" frame $nframe] get x]
    set y [[atomselect top "index $ii" frame $nframe] get y]
    set z [[atomselect top "index $ii" frame $nframe] get z]
    set x2 [expr $x*$axi + $y*$bxi + $z*$cxi]
    set y2 [expr $x*$ayi + $y*$byi + $z*$cyi]
    set z2 [expr $x*$azi + $y*$bzi + $z*$czi]
    set na [[atomselect top "index $ii" frame $nframe] get name]
#    if {$i == 0} then {
#      set nao $na
#      puts $wfile $n
#    } elseif {$na != $nao} then { 
#      incr num 
#      set nao $na
#    }
    set cna($i) $na
    set num 0
    if {$i == 0} then {
      set num $nkey
      set nnum($na) $nkey
      puts $wfile $n
    } else {
      for {set j 0} {$j < $i} {incr j} {
        if {$cna($j) == $na} then {
          set num $nnum($na)
        }
      }   
    }
    if {$num == 0} then {
      incr nkey
      set num $nkey
      set nnum($na) $nkey
    }
    lappend dat $num
    lappend dat [format "%.6f" [expr $x2/$lx]]
    lappend dat [format "%.6f" [expr $y2/$ly]]
    lappend dat [format "%.6f" [expr $z2/$lz]]
    puts $wfile $dat
  }  
  close $wfile
  puts "Supercell length & angles"
  puts "$lx $ly $lz"
  puts "$alpha $beta $gamma"
  return
}
