$height = 50.83;
$insertion_gap = 16.36;
$hook_diameter = 9.88;
$hook_depth = 14.46; // diameter + extra_hook
$hook_height = 30.23;
$end_to_end = 35.79; // from the wall to the top of the hook
$screw_spacing = 31.84; // closest edge-to-edge, not center-to-center
$screw_diameter = 4.5;

$thickness = 3.13;

// Render quality
$fn = $preview ? 32 : 64;

$epsilon = 0.01;


// anchored at 0,0,0; hook in the positive XY direction; linear_extrude in the Z direction
module hook_and_stem(
    height = 100,
    radius = 10,
    thickness = 1,
    extra_hook = 15,
    extra_stem = 30
) {
    translate([radius+thickness, extra_stem+extra_hook, 0])
    linear_extrude(height)
    union() {
        // hook
        difference() {
            circle(r=radius + thickness);
            circle(r=radius);
            translate([0, -(radius+thickness), 0])
            square(2*(radius+thickness), center=true);
        };
        
        // extra_hook without rounding
        translate([
            (radius+thickness/2),
            -((extra_hook-thickness/2)/2),
            0
        ])
        square([thickness, extra_hook-thickness/2], center=true);
        
        // extra_hook rounding
        translate([
            (radius+thickness/2),
            -((extra_hook-thickness/2)),
            0
        ])
        circle(d=thickness);
        
        // extra_hook on stem
        translate([
            -(radius+thickness/2),
            -(extra_hook/2),
            0
        ])
        square([thickness, extra_hook], center=true);
        
        // stem
        translate([
            -(radius+thickness/2),
            -(extra_stem/2+extra_hook),
            0
        ])
        square([thickness, extra_stem], center=true);
    }
}

module screwplate (
    thickness,
    height,
    hole_radius,
    hole_separation,
    hook_size
) {
    difference() {
        linear_extrude(height)
        square([hook_size, thickness]);
        
        // screw holes
        translate([hook_size/2, -$epsilon, height/2 + hole_separation/2])
        rotate([-90,0,0])
        linear_extrude(thickness+2*$epsilon)
        circle(hole_radius);
        
        translate([hook_size/2, -$epsilon, height/2 - hole_separation/2])
        rotate([-90,0,0])
        linear_extrude(thickness+2*$epsilon)
        circle(hole_radius);
    }
}


union() {
    screwplate(
        thickness=$thickness,
        height=$height,
        hole_radius=$screw_diameter/2,
        hole_separation=$screw_spacing+$screw_diameter,
        hook_size=$hook_diameter + 2*$thickness
    );
    
    translate([
        0,
        $thickness,
        $height/2-$hook_height/2
    ])
    hook_and_stem(
        height=$hook_height,
        radius=$hook_diameter/2,
        thickness=$thickness,
        extra_hook=$hook_depth - $hook_diameter,
        extra_stem=$insertion_gap
    );
    
    // top support
    translate([0,$thickness,0])
    rotate([-90,180,-90])
    linear_extrude($thickness)
    polygon(points=[
        [0,0],
        [0,($height/2-$hook_height/2)],
        [($hook_depth - $hook_diameter + $insertion_gap),($height/2-$hook_height/2)]
    ]);
    
    // bottom support
    translate([
        $thickness,
        $thickness,
        $height
    ])
    rotate([90,180,-90])
    linear_extrude($thickness)
    polygon(points=[
        [0,0],
        [0,($height/2-$hook_height/2)],
        [($hook_depth - $hook_diameter + $insertion_gap),($height/2-$hook_height/2)]
    ]);
};