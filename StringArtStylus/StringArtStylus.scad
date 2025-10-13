// Measurements
$orig_length = 108;
$orig_tip_od = 4.05;
$orig_tip_id = 3.18;
$orig_tail_id= 6.70;
$orig_tail_od=10.37;
$orig_grip_len=32.38;
$orig_grip_from_tip=50-$orig_grip_len;

// Variables
$length = 108;
$tip_od = 4.05;
$tip_id = 3.18;
$tail_id= 6.70;
$tail_od= 7.32;
$grip_len=32.38;
$grip_from_tip=18;

$epsilon=0.01;

// Calculations
$body_length = $length - $grip_from_tip;


module outer_shell() {
    union() {
        // Tail
        cylinder(h=$body_length, r=$tail_od/2, center=false);
        
        // Tip
        translate([0,0,$body_length])
        cylinder(h=$grip_from_tip, r1=$tail_od/2, r2=$tip_od/2, center=false);
    }
}

module inner_core() {
    translate([0,0,-$epsilon/2])
    cylinder(h=$length+$epsilon, r1=$tail_id/2, r2=$tip_id/2, center=false);
}

difference() {
    outer_shell();
    inner_core();
}