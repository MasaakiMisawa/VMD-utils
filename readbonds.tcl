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
##                                                                       ##
###########################################################################

proc readbonds {args} {
  set molnum [molinfo top]
  global blist
  set swcheck 0
  stopbonds$molnum
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
    set blist($molnum,$f) {}
    #set lx [molinfo top get a frame $f]
    #set ly [molinfo top get b frame $f]
    #set lz [molinfo top get c frame $f]
    for {set i 0} {$i < $n} {incr i} {
      lappend blist($molnum,$f) [gets $rfile]
      if {$swcheck == 1} then {
        for {set ii 0} {$ii < [llength [lindex $blist($molnum,$f) $i]]} {incr ii} {
          set j [lindex $blist($molnum,$f) $i $ii]
          # set jad 0
          # set dx [expr abs([[atomselect top "index $i"] get x] - [[atomselect top "index $j"] get x])]
          # set dy [expr abs([[atomselect top "index $i"] get y] - [[atomselect top "index $j"] get y])]
          # set dz [expr abs([[atomselect top "index $i"] get z] - [[atomselect top "index $j"] get z])]
          # if {$dx > [expr $lx/2.0]} then {
          #   set jad 1
          # } elseif {$dy > [expr $ly/2.0]} then {
          #   set jad 1
          # } elseif {$dz > [expr $lz/2.0]} then {
          #   set jad 1
          # }
          # if {$jad == 1} then {}
          if {[measure bond "$i $j" frame $f] > 3.0} then {
            lset blist($molnum,$f) $i $ii $i
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
  $sel setbonds $blist($molnum,$f)
  if {$molnum == 0} then {
    trace variable vmd_frame(0) w bupdate0
  } elseif {$molnum == 1} then {
    trace variable vmd_frame(1) w bupdate1
  } elseif {$molnum == 2} then {
    trace variable vmd_frame(2) w bupdate2
  }
}

proc stopbonds0 {} {
  global vmd_frame
  global blist
  trace vdelete vmd_frame(0) w bupdate
}
proc stopbonds1 {} {
  global vmd_frame
  global blist
  trace vdelete vmd_frame(1) w bupdate
}
proc stopbonds2 {} {
  global vmd_frame
  global blist
  trace vdelete vmd_frame(2) w bupdate
}

proc bupdate0 { name element op } {
  global vmd_frame
  global blist
  set f $vmd_frame(0)
  set sel [atomselect 0 all frame $vmd_frame(0)]
  $sel setbonds $blist(0,$f)
}
proc bupdate1 { name element op } {
  global vmd_frame
  global blist
  set f $vmd_frame(1)
  set sel [atomselect 1 all frame $vmd_frame(1)]
  $sel setbonds $blist(1,$f)
}
proc bupdate2 { name element op } {
  global vmd_frame
  global blist
  set f $vmd_frame(2)
  set sel [atomselect 2 all frame $vmd_frame(2)]
  $sel setbonds $blist(2,$f)
}
