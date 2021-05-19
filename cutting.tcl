     set theta1 [expr acos( $dltc/sqrt($dlta**2 + $dltc**2))]
     set theta2 [expr acos( $dlta/sqrt($dlta**2 + $dltc**2))]
     set theta1d [expr $theta1*180/$pi]
     set theta2d [expr $theta2*180/$pi]

     rmat -$theta1d 0 1 0
     $sela move $mat

     set na [expr $dlta*cos($theta2)/2 + $dltc*cos($theta1)/2]
     set nc [expr $dlta*sin($theta2)/2 + $dltc*sin($theta1)/2]
     set nthetad [expr 180 - $theta1d*2]
     set ntheta2d [expr 180 - $nthetad]
     set ntheta2 [expr $ntheta2d*$pi/180]

     pbc set "$na $dltb $nc 90 $nthetad 90"

     $sela moveby "[expr $na*sin($ntheta2)/2] 0 0"
     $sela moveby "0 0 [expr -$dltc*sin($theta2)/2]"
