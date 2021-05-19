###########################################################################
## J. cntr: Draw Clock Counter                                           ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  cntr (options)                                                       ##
##      -dt $cntdt: value per frame (default: 1)                         ##
##      -t0 $cntt0: time at the initial frame (default: 0)               ##
##      -uni $cntuni: unit of value (default: step)                      ##
##      -put $cntx, $cnty, $cntz: position of counter (default: 0,15,0)  ##
##      -size $cntsize: size of text                                     ##
##      -thick $cntthick: thickness of text                              ##
##      -color $cntcolor: color of text                                  ##
##                                                                       ##
##  parameters can be set by "set (variable name) (new value)"           ##
##      example: set cntdt 0.01                                          ##
##                                                                       ##
###########################################################################
proc cntr {args} {
  global cntx
  global cnty
  global cntz
  global cntdt
  global cntt0
  global cntuni
  global cntsize
  global cntthick
  global cntcolor
  set cntx 0
  set cnty 15
  set cntz 0
  set cntdt 1
  set cntt0 0
  set cntuni "step"
  set cntsize 2
  set cntthick 2
  set cntcolor 16
  for {set i 0} {$i < [llength $args]} {incr i} {
    if {[lindex $args $i] == "-dt"} then {
      set cntdt [lindex $args [expr $i + 1]]
      incr i
    } elseif {[lindex $args $i] == "-put"} then {
      set cntx [lindex $args [expr $i + 1]]
      set cnty [lindex $args [expr $i + 2]]
      set cntz [lindex $args [expr $i + 3]]
      incr i 3
    } elseif {[lindex $args $i] == "-t0"} then {
      set cntt0 [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-uni"} then {
      set cntuni [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-size"} then {
      set cntsize [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-thick"} then {
      set cntthick [lindex $args [expr $i + 1]]
      incr i 
    } elseif {[lindex $args $i] == "-color"} then {
      set cntcolor [lindex $args [expr $i + 1]]
      incr i 
    }
  }
  global vmd_frame;
  trace variable vmd_frame([molinfo top]) w drawcounter
  animate goto [molinfo top get frame]
}

proc disabletrace {} {
  global vmd_frame;
  trace vdelete vmd_frame([molinfo top]) w drawcounter
}

proc drawcounter { name element op } {
  global vmd_frame;
  global cntx
  global cnty
  global cntz
  global cntdt
  global cntt0
  global cntuni
  global cntsize
  global cntthick
  global cntcolor
  #draw delete all
  set drlist [graphics top list]
  for {set i 0} {$i < [llength $drlist]} {incr i} {
     set drlog [graphics top info [lindex $drlist $i]]
	  if {[lindex $drlog 0] == "text"} then {
	    draw delete [lindex $drlist $i]
	  }
	  if {[lindex $drlog 0] == "color"} then {
	    draw delete [lindex $drlist $i]
	  }
  }
  # puts "callback!"
  set cntcrd $cntx
  lappend cntcrd $cnty
  lappend cntcrd $cntz
  set time [format "%8.2f $cntuni" [expr $cntt0 + $vmd_frame([molinfo top]) * $cntdt]]
  draw color $cntcolor
  draw text $cntcrd  "$time" size $cntsize thickness $cntthick
}
