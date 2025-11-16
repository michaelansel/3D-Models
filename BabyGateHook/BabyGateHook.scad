$height = 50.83;
$original_insertion_gap = 16.36;
$hook_diameter = 9.88;
$hook_depth = 14.46; // diameter + extra_hook
$hook_height = 30.23; // vertical height
$end_to_end = 35.79; // from the wall to the top of the hook
$screw_spacing = 31.84; // closest edge-to-edge, not center-to-center
$screw_diameter = 4.5;

$thickness = 3.13;

// extra long upper hook
$long_end_to_end = 40.75+3.13+3.13; // wall to top of hook for the upper hook that needs to be longer
$insertion_gap = $original_insertion_gap + ($long_end_to_end - $end_to_end);

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
    hook_size,
    brace_size
) {
    difference() {
        union() {
            linear_extrude(height)
            square([hook_size, thickness]);
            
            // inner triangle brace
            $inner_brace_height =
                hole_separation-2*hole_radius /* edge-to-edge of the screw holes */
                -2*hole_radius /* extra space for the screws */;
            $inner_brace_offset = (height-$inner_brace_height)/2;
            translate([thickness,thickness,$inner_brace_offset])
//            linear_extrude($inner_brace_height)
//            polygon([
//                [0,$insertion_gap/2],
//                [0,0],
//                [hook_size-thickness,0]
//            ]);
            polyhedron(
                points=[
                    // top
                    [0, 0, $inner_brace_height],
                    [hook_size-thickness, 0, $inner_brace_height-$insertion_gap/4],
                    [0, $insertion_gap/2, $inner_brace_height-$insertion_gap/4],
                    // bottom
                    [0, 0, 0],
                    [hook_size-thickness, 0, $insertion_gap/4],
                    [0, $insertion_gap/2, $insertion_gap/4]
                ],
                faces=[
                    [0,1,2], // top
                    [1,4,5,2], // slant
                    [3,5,4], // bottom
                    [1,0,3,4], // hidden against screwplate
                    [0,2,5,3], // hidden against support
                ]
            );
            
            // brace
            translate([-brace_size,0,0])
            linear_extrude(height)
            square([brace_size, thickness]);
            
            // outer triangle brace
            translate([0,thickness,0])
            polyhedron(
                points=[
                    // top
                    [0, 0, height],
                    [-brace_size, 0, height],
                    // crazy math copied from the top/bottom support
                    [0, ($hook_depth - $hook_diameter + $insertion_gap), $height-($height/2-$hook_height/2)],
                    // bottom
                    [0, 0, 0],
                    [-brace_size, 0, 0],
                    // crazy math copied from the top/bottom support
                    [0, ($hook_depth - $hook_diameter + $insertion_gap), ($height/2-$hook_height/2)]
                ],
                faces=[
                    [0,1,2], // top
                    [1,4,5,2], // slant
                    [3,5,4], // bottom
                    [1,0,3,4], // hidden against screwplate
                    [0,2,5,3], // hidden against support
                ]
            );
        };
        
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
        hook_size=$hook_diameter + 2*$thickness,
        brace_size=$hook_diameter
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