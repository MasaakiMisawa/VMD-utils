###########################################################################
## A. chview: Change Viewpoint by Moving Atomic Configurations           ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
## chview -shift { $x $y $z }:                                           ##
##   --- shift atomic positions in {$x $y $z} (ang.) in boundary box.    ##
##                                                                       ##
## chview -lshift { $x $y $z }:                                          ##
##   --- shift atomic positions in {$x $y $z} (ang.) in boundary box     ##
##       along the lattice axes                                          ##
##                                                                       ##
## chview -com "$selection":                                             ##
##   --- fit center of mass of $selection to center of view              ##
##                                                                       ##
## chview -gc "$selection":                                              ##
##   --- fit geometrical center of $selection to center of view          ##
##                                                                       ##
## chview -reset                                                         ##
##   --- reset atomic positions                                          ##
##                                                                       ##
## Example: chview -com "name O H"                                       ##
##   --- fit center of mass of oxygen and hydrogen to center of view     ##
##                                                                       ##
## Memo: Input lattice constant is required                              ##
##       ("pbc set {$a $b $c $alpha $beta $gamma} -all" on Tk Console)   ##
##                                                                       ##
##       2016.6.8 apply for trigonal cell                                ##
###########################################################################

proc chview {args} {
  global defcx
  global defcy
  global defcz
  global resx
  global resy
  global resz
  set swgc 0
  set swcom 0
  set swval 0
  set swres 0
  set lshift 0
  set arg [ lindex $args 0 ]
  set val [ lindex $args 1 ]
  switch -- $arg {
    "-gc" { set swgc 1 ; set seltext $val }
    "-com" { set swcom 1; set seltext $val }
    "-shift" { set swval 1; set selval $val }
    "-lshift" { set swval 1; set selval $val; set lshift 1}
    "-reset" { set swres 1 }
    default { error "error: chview: unknown option: $arg" }
  }

  #set parameters
  if { $swval == 0 } then {
    if { $swres == 0 } then {
      set sel [atomselect top $seltext]
    }
  }
  set all [atomselect top all]
  set n [molinfo top get numframes]
  set m [molinfo top get numatoms]
  set k 0

  ##error trap
  if { $swres == 0 } then {
    if { $swval == 0 } then {
      for { set i 0 } { $i < $n } { incr i } {
        if { [[atomselect top $seltext frame $i] num] == 0 } then {
          vmdcon -warn "chview: selection is empty! (frame: $i)"
          return
         }
      }
    }
  }
  if { $swval == 1 } then {
    if { [llength $selval] != 3 } then {
      vmdcon -warn "chview -shift: selection should have 3 values!"
      return
    }
  }

  for { set i 0 } { $i < $n } { incr i } {
    #update frame
    if { $swres == 0 } then {
      if { $swval == 0 } then {
        $sel frame $i
        set nsel [[atomselect top $seltext frame $i] num]
      }
    }
    $all frame $i
    set lx [molinfo top get a frame $i]
    set ly [molinfo top get b frame $i]
    set lz [molinfo top get c frame $i]
    set alpha [molinfo top get alpha frame $i]
    set beta [molinfo top get beta frame $i]
    set gamma [molinfo top get gamma frame $i]
    set pi 3.1415926535897946
    set cosBC [expr cos($alpha*$pi/180)]
    set sinBC [expr sin($alpha*$pi/180)]
    set sinAC [expr sin($beta*$pi/180)]
    set cosAC [expr cos($beta*$pi/180)]
    set cosAB [expr cos($gamma*$pi/180)]
    set sinAB [expr sin($gamma*$pi/180)]
    if {$alpha == 90.0} then {
      set cosBC 0
    }
    if {$beta == 90.0} then {
      set cosAC 0
    }
    if {$gamma == 90.0} then {
      set cosAB 0
    }
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
    set iax [expr (1/$det)*($by*$cz - $cy*$bz)]
    set iay [expr (1/$det)*($cy*$az - $ay*$cz)]
    set iaz [expr (1/$det)*($ay*$bz - $by*$az)]
    set ibx [expr (1/$det)*($cx*$bz - $bx*$cz)]
    set iby [expr (1/$det)*($ax*$cz - $cx*$az)]
    set ibz [expr (1/$det)*($bx*$az - $ax*$bz)]
    set icx [expr (1/$det)*($bx*$cy - $cx*$by)]
    set icy [expr (1/$det)*($cx*$ay - $ax*$cy)]
	 set icz [expr (1/$det)*($ax*$by - $bx*$ay)]

    if { $defcx == "ini" } then {
	   set defcx 0
	   set defcy 0
	   set defcz 0
		for {set ii 0} {$ii < [expr $n - 1]} {incr ii} {
		  lappend defcx 0
		  lappend defcy 0
		  lappend defcz 0
		}
	 }
    
    if { $swcom == 1 } then {
      ##calculate center of mass
      set com [measure center $sel weight mass]
      set comx [lindex $com 0]
      set comy [lindex $com 1]
      set comz [lindex $com 2]
      ##calculate translate vector
      set tx [expr $lx/2.0 - $comx]
      set ty [expr $ly/2.0 - $comy]
      set tz [expr $lz/2.0 - $comz]
      set txo $tx
      set tyo $ty
      set tzo $tz
		set resx 0
		set resy 0
		set resz 0
    }

    if { $swgc == 1 } then {   
      ##calculate geometrical center
      set gc [measure center $sel]
      set gcx [lindex $gc 0]
      set gcy [lindex $gc 1]
      set gcz [lindex $gc 2]
      ##calculate translate vector
      set tx [expr $lx/2.0 - $gcx]
      set ty [expr $ly/2.0 - $gcy]
      set tz [expr $lz/2.0 - $gcz]
      set txo $tx
      set tyo $ty
      set tzo $tz
		set resx 0
		set resy 0
		set resz 0
    }

    if { $swval == 1 && $lshift == 0} then {   
      set txo [lindex $selval 0]
      set tyo [lindex $selval 1]
      set tzo [lindex $selval 2]
		set resx 0
	   lset selval 0 [expr fmod([lindex $selval 0], $lx*$ax)]
	   set resy [expr ([lindex $selval 1] - (fmod([lindex $selval 1], $ly*$by)))/$ly*$by]
	   lset selval 1 [expr fmod([lindex $selval 1], $ly*$by)]
	   set resz [expr ([lindex $selval 2] - (fmod([lindex $selval 2], $lz*$cz)))/$lz*$cz]
	   lset selval 2 [expr fmod([lindex $selval 2], $lz*$cz)]
		if {$gamma == 90} then {
		  set resy 0
		}
		if {$beta == 90} then {
		  set resz 0
		}
      set tx [lindex $selval 0]
      set ty [lindex $selval 1]
      set tz [lindex $selval 2]
    }

    if { $swval == 1 && $lshift == 1} then {   
		set resx 0
		set resy 0
		set resz 0
		lset selval 0 [expr fmod([lindex $selval 0], $lx)]
		lset selval 1 [expr fmod([lindex $selval 1], $ly)]
		lset selval 2 [expr fmod([lindex $selval 2], $lz)]
      ##calculate translate vector
      set tx [expr $ax*[lindex $selval 0] + $bx*[lindex $selval 1] + $cx*[lindex $selval 2]]
      set ty [expr $ay*[lindex $selval 0] + $by*[lindex $selval 1] + $cy*[lindex $selval 2]]
      set tz [expr $az*[lindex $selval 0] + $bz*[lindex $selval 1] + $cz*[lindex $selval 2]]
      set txo $tx
      set tyo $ty
      set tzo $tz
    }

    ##memory translating history
    if { $swres == 0 } then {
      lset defcx $i [ expr [ lindex $defcx $i ] + $txo] 
      lset defcy $i [ expr [ lindex $defcy $i ] + $tyo] 
      lset defcz $i [ expr [ lindex $defcz $i ] + $tzo] 
    } else {
		set resx 0
      lset defcx $i [expr fmod([lindex $defcx $i], $lx*$ax)]
		set resy [expr ([lindex $defcy $i] - (fmod([lindex $defcy $i], $ly*$by)))/$ly*$by]
      lset defcy $i [expr fmod([lindex $defcy $i], $ly*$by)]
		set resz [expr ([lindex $defcz $i] - (fmod([lindex $defcz $i], $lz*$cz)))/$lz*$cz]
      lset defcz $i [expr fmod([lindex $defcz $i], $lz*$cz)]
		if {$gamma == 90} then {
		  set resy 0
		}
		if {$beta == 90} then {
		  set resz 0
		}
      set tx [expr -1.0*[ lindex $defcx $i] ]
      set ty [expr -1.0*[ lindex $defcy $i] ]
      set tz [expr -1.0*[ lindex $defcz $i] ]
      lset defcx $i 0 
      lset defcy $i 0 
      lset defcz $i 0
    } 

    ##shift all atomic positions
    set allx [$all get x]
    set ally [$all get y]
    set allz [$all get z] 
    for {set jj 0} {$jj < $resy} {incr jj} {
      for {set j 0} {$j < $m} {incr j} {
	      if { $swres == 0 } then {
	        lset ally $j [expr [lindex $ally $j] + $ly*$by]
	        $all set y $ally
			} else {
	        lset ally $j [expr [lindex $ally $j] - $ly*$by]
	        $all set y $ally
			}
		}

		#pbcmove
      for {set j 0} {$j < $m} {incr j} {
        set inum [lindex [[atomselect top all frame $i] get serial] $j]
        set x1 [[atomselect top "serial $inum" frame $i] get x]
        set y1 [[atomselect top "serial $inum" frame $i] get y]
        set z1 [[atomselect top "serial $inum" frame $i] get z]
        set x2 [expr $x1*$iax + $y1*$ibx + $z1*$icx]
        set y2 [expr $x1*$iay + $y1*$iby + $z1*$icy]
        set z2 [expr $x1*$iaz + $y1*$ibz + $z1*$icz]
        set x2 [format "%.6f" [expr $x2/$lx]]
        set y2 [format "%.6f" [expr $y2/$ly]]
        set z2 [format "%.6f" [expr $z2/$lz]]
        for {set jj 0} {$jj < 1} {incr jj} {
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
            set jj [expr $jj - 1]
          }
        }
        set x2 [format "%.6f" [expr $x2*$lx]]
        set y2 [format "%.6f" [expr $y2*$ly]]
        set z2 [format "%.6f" [expr $z2*$lz]]
        set x1 [expr $x2*$ax + $y2*$bx + $z2*$cx]
        set y1 [expr $x2*$ay + $y2*$by + $z2*$cy]
        set z1 [expr $x2*$az + $y2*$bz + $z2*$cz]
        [atomselect top "serial $inum" frame $i] moveto "$x1 $y1 $z1"
      }

	 }
    for {set jj 0} {$jj < $resz} {incr jj} {
      for {set j 0} {$j < $m} {incr j} {
	      if { $swres == 0 } then {
	        lset allz $j [expr [lindex $allz $j] + $lz*$cz]
	        $all set z $allz
			} else {
	        lset allz $j [expr [lindex $allz $j] - $lz*$cz]
	        $all set z $allz
			}
		}
		#pbcmove
      for {set j 0} {$j < $m} {incr j} {
        set inum [lindex [[atomselect top all frame $i] get serial] $j]
        set x1 [[atomselect top "serial $inum" frame $i] get x]
        set y1 [[atomselect top "serial $inum" frame $i] get y]
        set z1 [[atomselect top "serial $inum" frame $i] get z]
        set x2 [expr $x1*$iax + $y1*$ibx + $z1*$icx]
        set y2 [expr $x1*$iay + $y1*$iby + $z1*$icy]
        set z2 [expr $x1*$iaz + $y1*$ibz + $z1*$icz]
        set x2 [format "%.6f" [expr $x2/$lx]]
        set y2 [format "%.6f" [expr $y2/$ly]]
        set z2 [format "%.6f" [expr $z2/$lz]]
        for {set jj 0} {$jj < 1} {incr jj} {
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
            set jj [expr $jj - 1]
          }
        }
        set x2 [format "%.6f" [expr $x2*$lx]]
        set y2 [format "%.6f" [expr $y2*$ly]]
        set z2 [format "%.6f" [expr $z2*$lz]]
        set x1 [expr $x2*$ax + $y2*$bx + $z2*$cx]
        set y1 [expr $x2*$ay + $y2*$by + $z2*$cy]
        set z1 [expr $x2*$az + $y2*$bz + $z2*$cz]
        [atomselect top "serial $inum" frame $i] moveto "$x1 $y1 $z1"
      }
	 }

    for {set j 0} {$j < $m} {incr j} {
      lset allx $j [expr [lindex $allx $j] + $tx]
      lset ally $j [expr [lindex $ally $j] + $ty] 
      lset allz $j [expr [lindex $allz $j] + $tz] 
      $all set x $allx
      $all set y $ally
      $all set z $allz
    ##progress report
  }
  #pbcmove
  for {set j 0} {$j < $m} {incr j} {
    set inum [lindex [[atomselect top all frame $i] get serial] $j]
    set x1 [[atomselect top "serial $inum" frame $i] get x]
    set y1 [[atomselect top "serial $inum" frame $i] get y]
    set z1 [[atomselect top "serial $inum" frame $i] get z]
    set x2 [expr $x1*$iax + $y1*$ibx + $z1*$icx]
    set y2 [expr $x1*$iay + $y1*$iby + $z1*$icy]
    set z2 [expr $x1*$iaz + $y1*$ibz + $z1*$icz]
    set x2 [format "%.6f" [expr $x2/$lx]]
    set y2 [format "%.6f" [expr $y2/$ly]]
    set z2 [format "%.6f" [expr $z2/$lz]]
    for {set jj 0} {$jj < 1} {incr jj} {
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
        set jj [expr $jj - 1]
      }
    }
    set x2 [format "%.6f" [expr $x2*$lx]]
    set y2 [format "%.6f" [expr $y2*$ly]]
    set z2 [format "%.6f" [expr $z2*$lz]]
    set x1 [expr $x2*$ax + $y2*$bx + $z2*$cx]
    set y1 [expr $x2*$ay + $y2*$by + $z2*$cy]
    set z1 [expr $x2*$az + $y2*$bz + $z2*$cz]
    [atomselect top "serial $inum" frame $i] moveto "$x1 $y1 $z1"
  }
  if { $i == $k } then {
    vmdcon -info "shift positions: frame $i completed"
    #set k [expr $k + 100]
    set k [expr $k + $n/10]
  }
#}
}
set defcx ini
set defcy ini
set defcz ini
set resx ini
set resy ini
set resz ini
