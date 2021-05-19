###########################################################################
##  E. makebonds: Make Bondlists for All Frames                          ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  makebonds $filename                                                  ##
##    (default filename is "./bondlist.dat")                             ##
##    then enter the cutoff distances in ang.                            ##
##                                                                       ##
##  makebonds -pbc $filename                                             ##
##    --- make bondlist with considering PBC                             ##
##        (please execute "readbonds" with "-pbc" option                 ##
##         when you apply a bondlist created with this option)           ##
##                                                                       ##
##  note: cutoff distance should be less than 3.0 ang.                   ##
##                                                                       ##
##  bondlist format:                                                     ##
##  ---------------------                                                ##
##  3 5 10     #neighbors of atom 1, step 0                              ##
##             #neighbors of atom 2, step 0 (if no neighbors: empty)     ##
##  1 12 100   #neighbors of atom 3, step 0                              ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ##
##  30 40 50   #neighbors of atom n, step 0                              ##
##  3 5 10 12  #neighbors of atom 1, step 1                              ##
##  3          #neighbors of atom 1, step 1                              ##
##   .                                                                   ##
##   .                                                                   ##
##   .                                                                   ##
##                                                                       ##
## Memo: Input lattice constant is required                              ##
##       ("pbc set {$a $b $c $alpha $beta $gamma} -all" on Tk Console)   ##
##       Only for orthorhombic cell                                      ##
##       VMD will be stop if there are too many atoms or frames          ##
##       Create bondlists on other workspace (not on VMD) is recommended ##
##                                                                       ##
###########################################################################

proc makebonds {args} {
  set swpbc 0
  if {[llength $args] == 1} then {
    set filename $args  
  } elseif {[lindex $args 0] == "-pbc"} then {
    set swpbc 1
    set filename [lindex $args 1]
  } elseif {$args == ""} then {
    set filename ./bondlist.dat
  }

  set wfile [open $filename w]
  set n [molinfo top get numatoms]
  set nf [molinfo top get numframes]

  ##Make Namelist
  set ic 0
  for {set i 0} {$i < $n} {incr i} {
    set sel [atomselect top "index $i"]
    set in($i) [$sel get name]
    set jadge 1
    if {$i == 0} then {
      set namelist [$sel get name]
      set it($i) $ic
    }
    for {set ii 0} {$ii < [llength $namelist]} {incr ii} {
      if {[$sel get name] == [lindex $namelist $ii]} then {
        set jadge 0
      }
    }
    if {$jadge == 1} then {
      lappend namelist [$sel get name]
      incr ic
      set it($i) $ic
    } else {
      set it($i) $ic
    }
  }
  puts "number of type = [expr $ic + 1]"
  puts "components: $namelist"
  
  ##Input Cutoff Distances
  for {set i 0} {$i < [llength $namelist]} {incr i} {
    for {set j $i} {$j < [llength $namelist]} {incr j} {
      puts "enter the cutoff distance for [lindex $namelist $i] - [lindex $namelist $j]"
      set cutd($i,$j) [gets stdin]
      if {$cutd($i,$j) == ""} then {
        set cutd($i,$j) 2.0
      }
      set cutd($j,$i) $cutd($i,$j)
    }
  }
  
  ##Make bondlist
  set fc 0
  for {set f 0} {$f < $nf} {incr f} {
    for {set i 0} {$i < $n} {incr i} {
      set iblist {}
      set xi [[atomselect top "index $i" frame $f] get x]
      set yi [[atomselect top "index $i" frame $f] get y]
      set zi [[atomselect top "index $i" frame $f] get z]
      for {set jj 0} {$jj < [llength $namelist]} {incr jj} {
        set sel2 [atomselect top "name [lindex $namelist $jj] and ((x-$xi)^2 + (y-$yi)^2 + (z-$zi)^2) <= ($cutd($it($i),$jj))^2" frame $f] 
        for {set j 0} {$j < [llength [$sel2 get index]]} {incr j} {
          if {$i != [lindex [$sel2 get index] $j]} then {
            lappend iblist [lindex [$sel2 get index] $j]
          }
        }
      }

      ##Considering PBC##
      if {$swpbc == 1} then {
        set jadx 0
        set jady 0
        set jadz 0
        set lx [molinfo top get a frame $f] 
        set ly [molinfo top get b frame $f] 
        set lz [molinfo top get c frame $f]
        if {$xi < 3.0} then {
          set jadx 1
        } elseif {[expr abs($xi - $lx)] < 3.0} then {
          set jadx -1
        } 
        if {$yi < 3.0} then {
          set jady 1
        } elseif {[expr abs($yi - $ly)] < 3.0} then {
          set jady -1
        } 
        if {$zi < 3.0} then {
          set jadz 1
        } elseif {[expr abs($zi - $lz)] < 3.0} then {
          set jadz -1
        }
        set jad [expr abs($jadx) + abs($jady) + abs($jadz) ]
        if {$jad == 0} then {
          set npbc 0
        } elseif {$jad == 1} then {
          set npbc 1
          set dx(0) [expr $xi + $lx*$jadx]
          set dy(0) [expr $yi + $ly*$jady]
          set dz(0) [expr $zi + $lz*$jadz]
        } elseif {$jad == 2} then {
          set npbc 3
          if {$jadx == 0} then {
            set dx(0) [expr $xi]
            set dy(0) [expr $yi]
            set dz(0) [expr $zi + $lz*$jadz]
            set dx(1) [expr $xi]
            set dy(1) [expr $yi + $ly*$jady]
            set dz(1) [expr $zi]
            set dx(2) [expr $xi]
            set dy(2) [expr $yi + $ly*$jady]
            set dz(2) [expr $zi + $lz*$jadz]
          } elseif {$jady == 0} then {
            set dx(0) [expr $xi]
            set dy(0) [expr $yi]
            set dz(0) [expr $zi + $lz*$jadz]
            set dx(1) [expr $xi + $lx*$jadx]
            set dy(1) [expr $yi]
            set dz(1) [expr $zi]
            set dx(2) [expr $xi + $lx*$jadx]
            set dy(2) [expr $yi]
            set dz(2) [expr $zi + $lz*$jadz]
          } elseif {$jadz == 0} then {
            set dx(0) [expr $xi + $lx*$jadx]
            set dy(0) [expr $yi]
            set dz(0) [expr $zi]
            set dx(1) [expr $xi]
            set dy(1) [expr $yi + $ly*$jady]
            set dz(1) [expr $zi]
            set dx(2) [expr $xi + $lx*$jadx]
            set dy(2) [expr $yi + $ly*$jady]
            set dz(2) [expr $zi]
          }
        } elseif {$jad == 3} then {
          set npbc 7
          set dx(0) [expr $xi + $lx*$jadx]
          set dy(0) [expr $yi]
          set dz(0) [expr $zi]
          set dx(1) [expr $xi]
          set dy(1) [expr $yi + $ly*$jady]
          set dz(1) [expr $zi]
          set dx(2) [expr $xi]
          set dy(2) [expr $yi]
          set dz(2) [expr $zi + $lz*$jadz]
          set dx(3) [expr $xi + $lx*$jadx]
          set dy(3) [expr $yi + $ly*$jady]
          set dz(3) [expr $zi]
          set dx(4) [expr $xi + $lx*$jadx]
          set dy(4) [expr $yi]
          set dz(4) [expr $zi + $lz*$jadz]
          set dx(5) [expr $xi]
          set dy(5) [expr $yi + $ly*$jady]
          set dz(5) [expr $zi + $lz*$jadz]
          set dx(6) [expr $xi + $lx*$jadx]
          set dy(6) [expr $yi + $ly*$jady]
          set dz(6) [expr $zi + $lz*$jadz]
        }
        for {set p 0} {$p < $npbc} {incr p} { 
          for {set jj 0} {$jj < [llength $namelist]} {incr jj} {
            set sel2 [atomselect top "name [lindex $namelist $jj] and ((x-$dx($p))^2 + (y-$dy($p))^2 + (z-$dz($p))^2) <= ($cutd($it($i),$jj))^2" frame $f]
            for {set j 0} {$j < [llength [$sel2 get index]]} {incr j} {
              if {$i != [lindex [$sel2 get index] $j]} then {
                  lappend iblist [lindex [$sel2 get index] $j]
              }
            }
          }
        }
      }
      puts $wfile $iblist
    }
    if {$f == $fc} then {
      puts "frame $f complete"
      incr fc 50
    }
  }
  close $wfile 
}
