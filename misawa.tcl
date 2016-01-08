set pset on
###########################################################################
## VMD Tools (2016.1.8)                                                  ##
##                                                                       ##
## -Functions-                                                           ##
##  A. chview: Change Viewpoint by Moving Atomic Configurations          ##
##  B. topdb: Export Selected Frames and Atoms as PDB a Trajectory File  ##
##  C. pickconfig: Export Selected Frames as a Scaled Coordination File  ##
##  D. ssr: Render Snapshots of Selected Frames                          ##
##  E. makebonds: Make Bondlists for All Frames                          ##
##  F. readbonds: Read Bondlist and Update Every Frames                  ##
##  G. readdata: Read Trajectory Value as "User" Variable                ##
##  H. readeigv: Read Eienvalue as Volmetric Data Set                    ##
##                                                                       ##
###########################################################################
## Setup                                                                 ##
##                                                                       ##
## 1. Select "VMD Main -> Extansions -> TkConsole"                       ##
##                                                                       ##
## 2. Execute "source (path)/misawa.tcl"                                 ##
##                                                                       ##
## 3. Execute functions                                                  ##
##                                                                       ##  
###########################################################################
## A. chview: Change Viewpoint by Moving Atomic Configurations           ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
## chview -shift { $x $y $z }:                                           ##
##   --- shift atomic positions in {$x $y $z} (ang.) in boundary box.    ##
##       |$x|, |$y| and |$z| must be smaller than Lx, Ly and Lz          ##
##                                                                       ##
## chview -com "$selection":                                             ##
##   --- fit center of mass of $selection to center of view              ##
##                                                                       ##
## chview -gc "$selection":                                              ##
##   --- fit geometrical center of $selection to center of view          ##
##                                                                       ##
## chview -reset                                                         ##
##   --- reset view                                                      ##
##                                                                       ##
## Example: chview -com "name O H"                                       ##
##   --- fit center of mass of oxygen and hydrogen to center of view     ##
##                                                                       ##
## Memo: Input lattice constant is required                              ##
##       ("pbc set {$a $b $c $alpha $beta $gamma} -all" on Tk Console)   ##
##       Only for orthorhombic cell                                      ##
##                                                                       ##
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
## C. pickconfig: Export Selected Frame as a Scaled Coordination File    ##
##                                                                       ##
## (How to use)                                                          ##
##  pickconfig $frame $filename                                          ##
##    $frame: default frame is "now"                                     ##
##    $filename: default filename is "Config.dat"                        ##
##                                                                       ##
## Memo: Input lattice constant is required                              ##
##       ("pbc set {$a $b $c $alpha $beta $gamma} -all" on Tk Console)   ##
##       Only for orthorhombic cell                                      ##
##                                                                       ##
###########################################################################
## D. ssr: Render Snapshots of Selected Frames                           ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  ssr -frames $i $j                                                    ##
##    $i: initial frame number                                           ##
##    $j: final frame number                                             ##
##                                                                       ##
##  ssr -frame $i                                                        ##
##    $i: render frame                                                   ##
##                                                                       ##
##  (other options)                                                      ##
##  ssr -frame $i -form $text -skip $s -rend $r                          ##
##    $text: format type (default: tga)                                  ##
##    $s: skip every $s frame (default: 1)                               ##
##    $rend: render type (default: 0)                                    ##
##           $r = 0: Snapshots                                           ##
##           $r = 1: Internal Tachyon                                    ##
##                                                                       ##
## Example: ssr -frames 0 100 -rend TachyonInternal                      ##
##   --- Frame000.tga ~ Frame100.tga will be created by Tachyon          ##
##                                                                       ##
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
##  F. readbonds: Read Bondlist and Update Every Frames                  ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  readbonds $filename                                                  ##
##    default filename is "./bondlist.dat"                               ##
##                                                                       ##
##  readbonds -pbc $filename                                             ##
##    --- remove PBC bond with keeping "numbonds"                        ##
##        if bond distance > 3 ang., it will be considered as PBC bond   ##
##                                                                       ##
##  Bondlist is available only for "Bonds" or "CPK" in Representation.   ##
##                                                                       ##
##  The bondlist is available only for current box.                      ##
##  (if "pbc wrap -shiftcenter" or "chview" is done after readbonds,     ##
##   "Bonds" or "CPK" will not represent exactlly.)                      ##           
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
##                                                                       ##
###########################################################################
##  G. readdata: Read Trajectory Value as "User" Variable                ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  readdata $filename -str $i $j -var $var                              ##
##    $filename: path of datafile                                        ##
##    $i, $j: data strength (default: $i = 4, $j = 6)                    ##
##    $var: variable name (default: user) e.g. user, user2, user3, ...   ##
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
##   Only for orthorhombic cell                                          ##
##                                                                       ##
###########################################################################

## personal settings ##
if {$pset == "on"} then {
  puts "read personal settings"
  display projection Orthographic
  display depthcue off
#  axes location Off
  color Display Background 8
  animate goto 0
#  pbc box -color 22 -style tubes -width 0.75 -material Transparent
  mol modstyle 0 0 CPK 0.700000 0.300000 12.000000 12.000000
  mol modcolor 0 0 Element
  color Element H 8
  color Element Li 7
  color Element O 1
  color Element F 14
  color Element Al 9
  color Element Si 4
  color Element P 9
  color Element Fe 6
  color Element Co 10
  color Labels Bonds black
}

puts ""
puts "---FUNCTION LIST---"
###########################################################################

puts "chview"
proc chview {args} {
  global defcx
  global defcy
  global defcz
  set swgc 0
  set swcom 0
  set swval 0
  set swres 0
  set arg [ lindex $args 0 ]
  set val [ lindex $args 1 ]
  switch -- $arg {
    "-gc" { set swgc 1 ; set seltext $val }
    "-com" { set swcom 1; set seltext $val }
    "-shift" { set swval 1; set selval $val }
    "-reset" { set swres 1 }
    default { error "error: chview: unknown option: $arg" }
  }
#  for {set i 0} {$i < [llength $args]} {incr i} {
#    if {[lindex $args $i] == "-gc"} then {
#      set swgc 1
#      set seltext [lindex $args [expr $i + 1]]
#      incr i
#    } elseif {[lindex $args $i] == "-com"} then {
#      set swcom 1
#      set seltext [lindex $args [expr $i + 1]]
#      incr i
#    } elseif {[lindex $args $i] == "-reset"} then {
#      set swres 1
#    } else {
#      set swval 1
#      set selval [lindex $args $i]
#    }
#  }

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

    if { [llength $defcx] != $n } then {
      if { $i == 0 } then {
        set defcx [ expr [ molinfo top get a frame $i ] / 2.0 ]
        set defcy [ expr [ molinfo top get b frame $i ] / 2.0 ]
        set defcz [ expr [ molinfo top get c frame $i ] / 2.0 ]
      } else {
        lappend defcx [ expr [ molinfo top get a frame $i ] / 2.0 ]
        lappend defcy [ expr [ molinfo top get b frame $i ] / 2.0 ]
        lappend defcz [ expr [ molinfo top get c frame $i ] / 2.0 ]
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
    }

    if { $swval == 1 } then {   
      ##error trap
      if { abs([lindex $selval 0]) > $lx } then {
        vmdcon -warn "shift value is too big ( < $lx )"
        return
      } elseif { abs([lindex $selval 1]) > $ly } then {
        vmdcon -warn "shift value is too big ( < $ly )"
        return
      } elseif { abs([lindex $selval 2]) > $lz } then {
        vmdcon -warn "shift value is too big ( < $lz )"
        return
      }
      ##calculate translate vector
      set tx [lindex $selval 0]
      set ty [lindex $selval 1]
      set tz [lindex $selval 2]
    }

    ##memory translating history
    if { $swres == 0 } then {
      lset defcx $i [ expr [ lindex $defcx $i ] + $tx] 
      if {[lindex $defcx $i] >= $lx} then {
        lset defcx $i [expr [lindex $defcx $i] - $lx]
      } elseif { [lindex $defcx $i] < 0.0 } then {
        lset defcx $i [expr [lindex $defcx $i] + $lx]
      }
      lset defcy $i [ expr [ lindex $defcy $i ] + $ty]
      if {[lindex $defcy $i] >= $ly} then {
        lset defcy $i [expr [lindex $defcy $i] - $ly]
      } elseif { [lindex $defcy $i] < 0.0 } then {
        lset defcy $i [expr [lindex $defcy $i] + $ly]
      }  
      lset defcz $i [ expr [ lindex $defcz $i ] + $tz]
      if {[lindex $defcz $i] >= $lz} then {
        lset defcz $i [expr [lindex $defcz $i] - $lz]
      } elseif { [lindex $defcz $i] < 0.0 } then {
        lset defcz $i [expr [lindex $defcz $i] + $lz]
      }  
    } else {
      set tx [expr $lx/2.0 - [ lindex $defcx $i] ]
      set ty [expr $ly/2.0 - [ lindex $defcy $i] ]
      set tz [expr $lz/2.0 - [ lindex $defcz $i] ]
      lset defcx $i [ expr [ molinfo top get a frame $i ] / 2.0 ]
      lset defcy $i [ expr [ molinfo top get b frame $i ] / 2.0 ]
      lset defcz $i [ expr [ molinfo top get c frame $i ] / 2.0 ]
    } 

    ##shift all atomic positions
    set allx [$all get x]
    set ally [$all get y]
    set allz [$all get z] 
    for {set j 0} {$j < $m} {incr j} {
      lset allx $j [expr [lindex $allx $j] + $tx]
      if {[lindex $allx $j] >= $lx} then {
        lset allx $j [expr [lindex $allx $j] - $lx]
      } 
      if {[lindex $allx $j] < 0} then {
        lset allx $j [expr [lindex $allx $j] + $lx]
      }
      lset ally $j [expr [lindex $ally $j] + $ty] 
      if {[lindex $ally $j] >= $ly} then {
        lset ally $j [expr [lindex $ally $j] - $ly]
      } 
      if {[lindex $ally $j] < 0} then {
        lset ally $j [expr [lindex $ally $j] + $ly]
      }
      lset allz $j [expr [lindex $allz $j] + $tz] 
      if {[lindex $allz $j] >= $lz} then {
        lset allz $j [expr [lindex $allz $j] - $lz]
      } 
      if {[lindex $allz $j] < 0} then {
        lset allz $j [expr [lindex $allz $j] + $lz]
      }
        }
    $all set x $allx
    $all set y $ally
    $all set z $allz

    ##progress report
    if { $i == $k } then {
      vmdcon -info "shift positions: frame $i completed"
      set k [expr $k + 100]
    }

  }
  return
}
set defcx 0
set defcy 0
set defcz 0
####################################################################

puts "topdb"
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
  exec rm pdbframe.pdb
  return
}
####################################################################

puts "pickconfig"
proc pickconfig {args} {
  set nframe [lindex $args 0] 
  set filen [lindex $args 1]
  
  if {$nframe == ""} then {
    set nframe now
  } 
  if {$filen == ""} then {
    set filen Config.dat
  } 

  set lx [molinfo top get a frame $nframe] 
  set ly [molinfo top get b frame $nframe] 
  set lz [molinfo top get c frame $nframe]
  set n [molinfo top get numatoms]
  set wfile [open $filen w]
  set num 1

  for {set i 0} {$i < $n} {incr i} {
    set dat {} 
    set x [[atomselect top "index $i" frame $nframe] get x]
    set y [[atomselect top "index $i" frame $nframe] get y]
    set z [[atomselect top "index $i" frame $nframe] get z]
    set na [[atomselect top "index $i" frame $nframe] get name]
    if {$i == 0} then {
      set nao $na
      puts $wfile $n
    } elseif {$na != $nao} then { 
      incr num 
      set nao $na
    } 
    lappend dat $num
    lappend dat [format "%.8f" [expr $x/$lx]]
    lappend dat [format "%.8f" [expr $y/$ly]]
    lappend dat [format "%.8f" [expr $z/$lz]]
    puts $wfile $dat
  }  
  close $wfile
  return
}
####################################################################

puts "ssr"
proc ssr {args} {
  set nargs [llength $args]
  set format tga
  set nrend 0
  set skip 1
  set dot .
  set fname Frame
  set start 0
  set end 0
  set n [molinfo top get numframes]
  for {set i 0} {$i < $nargs} {incr i} {
    if {[lindex $args $i] == "-form" } then {
      set format [lindex $args [expr $i + 1]]
      incr i
    } elseif {[lindex $args $i] == "-frame" } then {
      set start [lindex $args [expr $i + 1]] 
      set end $start
      incr i 
    } elseif {[lindex $args $i] == "-frames" } then {
      set start [lindex $args [expr $i + 1]] 
      set end [lindex $args [expr $i + 2]]
      incr i 2
    } elseif {[lindex $args $i] == "-skip" } then {
      set skip [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-rend" } then {
      set nrend [lindex $args [expr $i + 1]]
      incr i
    } else {
      vmdcon -warn "unknown value: [lindex $args $i]"
      return
    }
  }
  if {$end > $n} then {
    vmdcon -warn "endframe > numframes"
    return
  }   
  if {$nrend == 0} then {
    set nrend snapshot
  } elseif {$nrend == 1} then {
    set nrend TachyonInternal
  } else {
    vmdcon -warn "error in render type $nrend"
  }


  if {$end < 10} then {
    set k 1
  } elseif {$end < 100 && $end >= 10} then {
    set k 2
  } elseif {$end < 1000 && $end >= 100} then {
    set k 3
  } elseif {$end < 10000 && $end >= 1000} then {
    set k 4
  } elseif {$end < 100000 && $end >= 10000} then {
    set k 5
  } else {
    vmdcon -warn "frame number is too big"
    return
  }
  
  set kk 1
  for {set i $start} {$i < [expr $end +1]} {incr i $skip} {
    set j $i

    if {$i >= 10} then {
      set kk 2
    }
    if {$i >= 100} then {
      set kk 3
    }
    if {$i >= 1000} then {
      set kk 4
    }
    if {$i >= 10000} then {
      set kk 5
    }

    if {[expr $k - $kk] != 0} then {
      for {set ii 0} {$ii < [expr $k - $kk]} {incr ii} {
        set j 0$j
      }
    }

    animate goto $i
    #render TachyonInternal $fname$j$dot$format
    render $nrend $fname$j$dot$format
    vmdcon -info "frame $i complete"
  }
return
}

###################################################################

puts "makebonds"
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
###################################################################

puts "readbonds"
proc readbonds {args} {
  global blist
  set swcheck 0
  stopbonds
  if {[llength $args] == 1} then {
    set filename $args
  } elseif {[lindex $args 0] == "-pbc"} then {
    if {[llength $args] == 2} then {
      set filename [lindex $args 1]
    } else {
      vmdcon -warn "argments is not correct"
      return
    }
    set swcheck 1
  } else {
    vmdcon -warn "argments is not correct"
    return
  }

  set rfile [open $filename r]  
  set n [molinfo top get numatoms]
  set nf [molinfo top get numframes]
  set fc 0

  for {set f 0} {$f < $nf} {incr f} {
    set blist($f) {}
    #set lx [molinfo top get a frame $f]
    #set ly [molinfo top get b frame $f]
    #set lz [molinfo top get c frame $f]
    for {set i 0} {$i < $n} {incr i} {
      lappend blist($f) [gets $rfile]
      if {$swcheck == 1} then {
        for {set ii 0} {$ii < [llength [lindex $blist($f) $i]]} {incr ii} {
          set j [lindex $blist($f) $i $ii]
          #set jad 0
          #set dx [expr abs([[atomselect top "index $i"] get x] - [[atomselect top "index $j"] get x])]
          #set dy [expr abs([[atomselect top "index $i"] get y] - [[atomselect top "index $j"] get y])]
          #set dz [expr abs([[atomselect top "index $i"] get z] - [[atomselect top "index $j"] get z])]
          #if {$dx > [expr $lx/2.0]} then {
          #  set jad 1
          #} elseif {$dy > [expr $ly/2.0]} then {
          #  set jad 1
          #} elseif {$dz > [expr $lz/2.0]} then {
          #  set jad 1
          #}
          #if {$jad == 1} then {}
          if {[measure bond "$i $j" frame $f] > 3.0} then {
            lset blist($f) $i $ii $i
          } 
        }
      }
    }
    if {$fc == $f} then {
      puts "frame $f complete"
      incr fc 50
    }
  }
  close $rfile
  global vmd_frame;
  set f $vmd_frame([molinfo top])
  set sel [atomselect top all frame $vmd_frame([molinfo top])]
  $sel setbonds $blist($f)
  trace variable vmd_frame([molinfo top]) w bupdate
}

proc stopbonds {} {
  global vmd_frame
  global blist
  trace vdelete vmd_frame([molinfo top]) w bupdate
}

proc bupdate { name element op } {
  global vmd_frame
  global blist
  set f $vmd_frame([molinfo top])
  set sel [atomselect top all frame $vmd_frame([molinfo top])]
  $sel setbonds $blist($f)
}

###################################################################

puts "readdata"
proc readdata {args} {
  set var user
  set ini 4 
  set fin 6
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
###################################################################

puts "readeigv"
proc readeigv {args} {
  set molid top
  set nargs [llength $args]

  for {set ii 0} {$ii < $nargs} {incr ii} {
    set filename($ii) [lindex $args $ii]
    set rfile [open $filename($ii) r]
    set vorigin [gets $rfile]
    set vgrid [gets $rfile]
    set ngrid [expr [lindex $vgrid 0]*[lindex $vgrid 1]*[lindex $vgrid 2]]
    set evfact [gets $rfile]
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
    
    puts "start readig $filename($ii)"  
    for {set j 0} {$j < $ngrid} {incr j} {
      set n [gets $rfile]
      set eval [gets $rfile]
      for {set i 0} {$i < $n} {incr i} {
        lappend valList [expr $eval*$evfact]
#        lappend valList $eval
      }
      incr j [expr $n - 1]
    }

    puts "end reading $filename($ii)"
    close $rfile
    if {[lindex $args [expr $ii + 1]] == "as"} then {
      set vdnam [lindex $args [expr $ii + 2]]
      incr ii 2
    } else {
      set vdnam $filename($ii)
    }
    mol volume $molid $vdnam $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] $valList
    # mol volume $molid $filename($ii) $vorigin $xVec $yVec $zVec [lindex $vgrid 0] [lindex $vgrid 1] [lindex $vgrid 2] [vecscale $evfact $valList]
    puts "accepted as $vdnam"
  }
}

###################################################################
###################################################################
puts "-------------------"
