###########################################################################
## K. rmat: Calculate Rotation Matrix                                    ##
##                                                                       ##
## (How to use)                                                          ##
##                                                                       ##
##  rmat $angle $vx $vy $vz                                              ##
##      $angle: rotation angle                                           ##
##      $vx, $vy, $vz: rotation axis                                     ##
##                                                                       ##                         
##  Calculated matrix will be defined as $mat.                           ##
##  "$sela move $mat" to execute rotation.                               ##
##  Preset matrix:                                                       ##
##  imat: inversion matrix                                               ##
##  xym, yzm, zxm: mirror matrix                                         ##
##                                                                       ##
###########################################################################

proc rmat {theta nv1 nv2 nv3} {
  set sinR [expr sin($theta*acos(-1.0)/180.0)]
  set cosR [expr cos($theta*acos(-1.0)/180.0)]
# vector normalization
  set n1 [expr $nv1/sqrt($nv1*$nv1 + $nv2*$nv2 + $nv3*$nv3)]
  set n2 [expr $nv2/sqrt($nv1*$nv1 + $nv2*$nv2 + $nv3*$nv3)]
  set n3 [expr $nv3/sqrt($nv1*$nv1 + $nv2*$nv2 + $nv3*$nv3)]
# components of translation matrix
  set x1 [format "%.8f" [expr $n1*$n1*(1.0 - $cosR) + $cosR]]
  set x2 [format "%.8f" [expr $n1*$n2*(1.0 - $cosR) - $n3*$sinR]]
  set x3 [format "%.8f" [expr $n1*$n3*(1.0 - $cosR) + $n2*$sinR]]
  set x4 [format "%.8f" 0.0]
  set y1 [format "%.8f" [expr $n1*$n2*(1.0 - $cosR) + $n3*$sinR]]
  set y2 [format "%.8f" [expr $n2*$n2*(1.0 - $cosR) + $cosR]]
  set y3 [format "%.8f" [expr $n2*$n3*(1.0 - $cosR) - $n1*$sinR]]
  set y4 [format "%.8f" 0.0]
  set z1 [format "%.8f" [expr $n1*$n3*(1.0 - $cosR) - $n2*$sinR]]
  set z2 [format "%.8f" [expr $n2*$n3*(1.0 - $cosR) + $n1*$sinR]]
  set z3 [format "%.8f" [expr $n3*$n3*(1.0 - $cosR) + $cosR]]
  set z4 [format "%.8f" 0.0]
  set f1 [format "%.8f" 0.0]
  set f2 [format "%.8f" 0.0]
  set f3 [format "%.8f" 0.0]
  set f4 [format "%.8f" 1.0]
  global mat
  set mat {}
  lappend mat  "$x1 $x2 $x3 $x4"
  lappend mat  "$y1 $y2 $y3 $y4"
  lappend mat  "$z1 $z2 $z3 $z4"
  lappend mat  "$f1 $f2 $f3 $f4"
  puts $mat
}

# matrix multiplication (http://www.pitecan.com/presentations/Script/html/page32.html)
proc mmult {m1 m2} {
    set m2rows [llength $m2];
    set m2cols [llength [lindex $m2 0]];
    set m1rows [llength $m1];
    set m1cols [llength [lindex $m1 0]];
    if { $m1cols != $m2rows || $m1rows != $m2cols } {
        error "Matrix dimensions do not match!";
    }
    foreach row1 $m1 {
        set row {};
        for { set i 0 } { $i < $m2cols } { incr i } {
            set j 0;
            set element 0;
            foreach row2 $m2 {
                incr element [expr [lindex $row1 $j] * [lindex $row2 $i]];
                incr j;
            }
            lappend row $element;
        }
        lappend result $row;
    }
    return $result;
}

set imat {}
lappend imat "-1 0 0 0"
lappend imat "0 -1 0 0"
lappend imat "0 0 -1 0"
lappend imat "0 0 0 1"
set xym {}
lappend xym "1 0 0 0"
lappend xym "0 1 0 0"
lappend xym "0 0 -1 0"
lappend xym "0 0 0 1"
set yzm {}
lappend yzm "-1 0 0 0"
lappend yzm "0 1 0 0"
lappend yzm "0 0 1 0"
lappend yzm "0 0 0 1"
set zxm {}
lappend zxm "1 0 0 0"
lappend zxm "0 -1 0 0"
lappend zxm "0 0 1 0"
lappend zxm "0 0 0 1"
set dlta [molinfo top get a]
set dltb [molinfo top get b]
set dltc [molinfo top get c]
set sela [atomselect top all]
set pi [expr acos(-1.0)]
