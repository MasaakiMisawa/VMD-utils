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
##  ssr -frame $i -form $text -skip $s -rend $rend -ope $opefile         ##
##    $text: format type (default: tga)                                  ##
##    $s: skip every $s frame (default: 1)                               ##
##    $rend: render type (default: 0)                                    ##
##           $r = 0: Snapshots                                           ##
##           $r = 1: Internal Tachyon                                    ##
##           $r = 2: POV-Ray                                             ##
##    -cons: output file name will be consecutive (default: 0)           ##
##    -ope: rendering with camera operation                              ##
##                                                                       ##
##    opefile format:                                                    ##
##    -----------------------------------                                ##
##    10                                   #repeat number of ope. 1      ##
##    {rotate y by 0.1}                    #operation 1                  ##
##    10                                   #repeat number of ope. 2      ##
##                                         #operation 2 (no operation)   ##
##    10                                   #repeat number of ope. 3      ##
##    {rotate z by 0.1} {translate x 1}    #operation 3                  ##
##    -----------------------------------                                ##
##                                                                       ##
##  operation should consists less than 12 word                          ##
##                                                                       ##
## Example: ssr -frames 0 100 -rend TachyonInternal                      ##
##   --- Frame000.tga ~ Frame100.tga will be created by Tachyon          ##
##                                                                       ##
###########################################################################

proc ssr {args} {
  set nargs [llength $args]
  set format tga
  set nrend 0
  set skip 1
  set dot .
  set fname Frame
  set start 0
  set end 0
  set lope 0
  set lcons 0
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
###
    } elseif {[lindex $args $i] == "-ope" } then {
      set opefile [lindex $args [expr $i + 1]]
      set lope 1
      incr i
###
    } elseif {[lindex $args $i] == "-cons" } then {
      set lcons 1
      set fname Image
      
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
  } elseif {$nrend == 2} then {
    set nrend POV3
    set format pov
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
###
  if {$lope == 1} then {
    set rfile [open $opefile r]
    set opetot 0
    set nope 0
  }
###
###
  for {set i $start} {$i < [expr $end +1]} {incr i $skip} {
    if {$lcons == 0} then {
      set j $i
    } else {
      set j [expr ($i - $start)/$skip]
    }

    if { $j >= 10} then {
      set kk 2
    }
    if { $j >= 100} then {
      set kk 3
    }
    if { $j >= 1000} then {
      set kk 4
    }
    if { $j >= 10000} then {
      set kk 5
    }
    if {[expr $k - $kk] != 0} then {
      for {set ii 0} {$ii < [expr $k - $kk]} {incr ii} {
        set j 0$j
      }
    }


###
    if {$lope == 1} then {
      if {$nope == $opetot} then {
        set opetot [gets $rfile]
        set ope [gets $rfile]
        set nope 0
      } 
    
      for {set ii 0} {$ii < [llength $ope]} {incr ii} {
        if {[llength [lindex $ope $ii]] == 1} then {
        } elseif {[llength [lindex $ope $ii]] == 1} then {
          [lindex $ope $ii 0]  
        } elseif {[llength [lindex $ope $ii]] == 2} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] 
        } elseif {[llength [lindex $ope $ii]] == 3} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] 
        } elseif {[llength [lindex $ope $ii]] == 4} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3]  
        } elseif {[llength [lindex $ope $ii]] == 5} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] 
        } elseif {[llength [lindex $ope $ii]] == 6} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] 
        } elseif {[llength [lindex $ope $ii]] == 7} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6]
        } elseif {[llength [lindex $ope $ii]] == 8} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6] [lindex $ope $ii 7] 
        } elseif {[llength [lindex $ope $ii]] == 9} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6] [lindex $ope $ii 7] [lindex $ope $ii 8] 
        } elseif {[llength [lindex $ope $ii]] == 10} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6] [lindex $ope $ii 7] [lindex $ope $ii 8] [lindex $ope $ii 9] 
        } elseif {[llength [lindex $ope $ii]] == 11} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6] [lindex $ope $ii 7] [lindex $ope $ii 8] [lindex $ope $ii 9] [lindex $ope $ii 10] 
        } elseif {[llength [lindex $ope $ii]] == 12} then {
          [lindex $ope $ii 0] [lindex $ope $ii 1] [lindex $ope $ii 2] [lindex $ope $ii 3] [lindex $ope $ii 4] [lindex $ope $ii 5] [lindex $ope $ii 6] [lindex $ope $ii 7] [lindex $ope $ii 8] [lindex $ope $ii 9] [lindex $ope $ii 10] [lindex $ope $ii 11] 
        }
      }
      incr nope
    } 
###
    animate goto $i

    #render TachyonInternal $fname$j$dot$format
    if {$nrend == "POV3"} then {
       render $nrend $fname$j$dot$format povray +W%w +H%h +D +X +A +FT
    } else  {
       render $nrend $fname$j$dot$format
    }
    vmdcon -info "frame $i complete"
  }
return
}
