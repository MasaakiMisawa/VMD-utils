######################################################################
# Personal settings of color scheme, VMD display, and representation #
######################################################################

set pset on
if {$pset == "on"} then {

### Color Settings ###
  color Element H 8
  color Element Li 7
  color Element O 1
  color Element C 2
  color Element F 14
  color Element Al 9
  color Element Si 4
  color Element P 9
  color Element Fe 6
  color Element Co 10
  color Element Cu 0
  color Element As 7
  color Element Mo 7
  color Element Mg 0
  color Element Ag 6
  color Element Ni 0
  color Labels Atoms red
  color Labels Bonds black
  color Labels Angles blue
  color Axes Labels 16

### Display Settings ###
  display projection Orthographic
  display depthcue off
  color Display Background 8
  display cuemode Linear
  user add key 3 {display projection Orthographic}
  user add key 4 {display projection Perspective}
  user add key 5 {display depthcue off}
  user add key 6 {display depthcue on}
  user add key 7 {axes location Off}
  user add key 8 {axes location LowerLeft}
  user add key 9 {display resetview}
  #axes location Off
  #pbc box

### Representations ###
  #mol modstyle 0 top VDW 0.20 12.00 
  #mol modcolor 0 top Element
  #mol addrep top
  #mol modstyle 2 top DynamicBonds 2.30 0.10 12.00
  #mol addrep top
  #mol modstyle 3 top DynamicBonds 1.20 0.10 12.00
  #mol modselect 3 top "name O H"

### U --> H conversion settings ###
### if U atoms exist, it will considered as H ###
#  set indH [[atomselect top "element Z or type Z or name Z"] get index]
#  if {$indH != ""} then {
#    set selH [atomselect top "index $indH"]
#    $selH set name H
#    $selH set type H
#    $selH set element H
#    $selH set radius 1
#  }

### Other Settings ###
  animate goto 0

}
