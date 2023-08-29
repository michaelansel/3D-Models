// Render parts side by side (far apart); false for showing final alignment
side_by_side = true;
$fa=1;$fs=1;


print_bed = 170; // Prusa MINI+
epsilon=0.01; // for stitching pieces together in the final model
tolerance=0.2; // for interlocking parts

inches = 25.4;
drawer_width = 13 * inches;
//drawer_width = 2 * inches; //testing
//drawer_width = 28 * inches; //testing
drawer_height = 3.25 * inches;
drawer_depth = 19 * inches;

// https://www.reddit.com/r/nespresso/comments/r499a1/vertuo_pod_dimensions/
pod_ring_diameter = 2.25 * inches + 1 /* extra wiggle room */;
//pod_ring_diameter = 1 * inches; // testing connectors
pod_ring_thickness = 3/32 * inches;
pod_ring_crimp_width = 3/16 * inches; // part of the diameter
pod_depths = [
  1.5 * inches,
  1 * inches,
  3/4 * inches,
  1.75 * inches,
];

base_thickness = 2; // this is the thickness of the base below the pod
pod_spacer_thickness = pod_ring_thickness; // walls between pods; seems like a nice aesthetic to have them match; this is also the endcap thickness
plug_length = 4*(pod_ring_thickness + pod_spacer_thickness); // plug for interlocking multiple pieces together
//plug_length = 2*(pod_ring_thickness + pod_spacer_thickness); // testing connectors

// organizer is installed sideways in the drawer
// maximized the number of slots for the drawer

number_of_slots = floor((drawer_width - pod_spacer_thickness /* endcap */ ) / (pod_spacer_thickness + pod_ring_thickness));
organizer_width = number_of_slots * (pod_spacer_thickness + pod_ring_thickness) + pod_spacer_thickness /* endcap */;

assert(organizer_width < drawer_width);
organizer_depth = pod_ring_diameter + base_thickness; // means that the sidewalls are actually base_thickness/2 thick
organizer_height = pod_ring_diameter/2 + base_thickness;

// how high is the center of the pod from the x axis
// used for aligning cutout cylinders
pod_center_offset = pod_ring_diameter/2 - organizer_height/2+base_thickness;

// make sure it fits
assert(organizer_height + pod_ring_diameter/2 < drawer_height);
assert(organizer_height < print_bed);
assert(organizer_depth < print_bed);

echo(str("You can fit ", floor(drawer_depth/organizer_depth), " organizers in your drawer with ", (drawer_depth-floor(drawer_depth/organizer_depth)*(organizer_depth))/inches, "in left over. Each organizer will have ", number_of_slots, " slots (not the number of pods!)." ));

// Make a pair of divider and cutout; the finished product is just a bunch of these next to each other
module pod_slot() {
    total_slot_thickness = pod_ring_thickness + pod_spacer_thickness;
    
    // cube - pod_ring
    difference() {
        cube([total_slot_thickness, organizer_depth, organizer_height], center=true);

        // cutout for pod rings
        translate([0, 0, pod_center_offset])
        rotate([0, 90, 0])
        translate([0,-epsilon,0])
        cylinder(h=total_slot_thickness+2*epsilon, d=pod_ring_diameter, center=true);
    }

    // divider - pod_core
    difference() {
        translate([0-pod_spacer_thickness/2, 0, 0])
        cube([pod_spacer_thickness, organizer_depth, organizer_height], center=true);

        // cutout for pod cores
        translate([0, 0, pod_center_offset])
        rotate([0, 90, 0])
        translate([0,-epsilon,0])
        cylinder(h=total_slot_thickness+2*epsilon, d=pod_ring_diameter - pod_ring_crimp_width, center=true);
    }
}

module plug(length, radius, flange=false) {
    union() {
        rotate([0, 90, 0])
        cylinder(h=length, r=radius-tolerance, center=true);
        
        if (flange) {
            flange_length=length-radius; // flange down to where the sphere starts
            translate([-length/2 + flange_length/2,0,0])
            rotate([0,90,0])
            cylinder(h=flange_length, r1=radius+tolerance, r2=radius-tolerance, center=true);
        }
        
        translate([plug_length/2, 0, 0])
        sphere(r=radius);
    }
}

// Make a full part with endcaps and a bunch of pod_slots
module pod_organizer_part(number_of_slots, include_left_endcap=true, include_right_endcap=true) {
    
    part_width = number_of_slots*(pod_spacer_thickness+pod_ring_thickness) + (include_right_endcap ? pod_spacer_thickness : 0);
    
    /*
        find the largest circle (r1) that can fit into the space between the pod_ring (r1) and the corner of the organizer (y1,z1); t=base_thickness
        uses a right triangle with hypotenuse between the centers of the two circles as the means of relating them geometrically (triangle sides f5,f6)
    
        z1 == t + r1
        y1 == r1
        f6 + r2 == z1
        f5 + r2 == y1
        f5^2 + f6^2 == (r1 + r2)^2
    */
    max_plug_radius=min(
        3*pod_ring_diameter/2 + base_thickness - 2*sqrt(2*(pod_ring_diameter/2)^2 + pod_ring_diameter/2*base_thickness),
        3*pod_ring_diameter + base_thickness + 2*sqrt(2*(pod_ring_diameter/2)^2 + pod_ring_diameter/2*base_thickness)
    );
    echo(str("Max Plug Radius: ", max_plug_radius));
    plug_cutout_radius=max_plug_radius - base_thickness;
    plug_radius=plug_cutout_radius - tolerance;

    difference() {
        union() {
            // main body
            for (a =[0:number_of_slots-1])
            {
                translate([0-part_width/2+(pod_spacer_thickness+pod_ring_thickness)/2+a*(pod_spacer_thickness+pod_ring_thickness), 0, 0])
                pod_slot();
            }
            
            // left endcap
            if (include_left_endcap)
            translate([0-part_width/2+pod_spacer_thickness/2, 0, 0])
            cube([pod_spacer_thickness, organizer_depth, organizer_height], center=true);
            
            // right endcap
            if (include_right_endcap)
            translate([part_width/2-pod_spacer_thickness/2, 0, 0])
            cube([pod_spacer_thickness, organizer_depth, organizer_height], center=true);
            
            // add a solid base piece to make the slicer happy
            // TODO use epsilon extensions instead
            translate([0, 0, -organizer_height/2])
            cube([part_width, organizer_depth, epsilon], center=true);

            // right end has plug
            if (!include_right_endcap) {
                translate([part_width/2, -organizer_depth/2 + max_plug_radius, -organizer_height/2 + plug_radius + max_plug_radius/2])
                plug(plug_length, plug_radius);
                
                translate([part_width/2, -1*(-organizer_depth/2 + max_plug_radius), -organizer_height/2 + plug_radius + max_plug_radius/2])
                plug(plug_length, plug_radius);
            }
        }
    
        // left end has a cutout for the plug
        if (!include_left_endcap) {
            translate([-part_width/2+plug_length/2-epsilon, -organizer_depth/2 + max_plug_radius, -organizer_height/2 + plug_radius + max_plug_radius/2])
            plug(plug_length + epsilon, plug_cutout_radius, flange=true);
            
            translate([-part_width/2+plug_length/2-epsilon, -1*(-organizer_depth/2 + max_plug_radius), -organizer_height/2 + plug_radius + max_plug_radius/2])
            plug(plug_length + epsilon, plug_cutout_radius, flange=true);
        }
    }
}

// Generate the right number of pieces to fit on the printer
if (organizer_width > print_bed /*|| true /*testing*/) {
    number_of_parts = ceil(organizer_width / print_bed);
    //number_of_parts = 2; // testing
    
    if (number_of_parts == 2) {
        // Just split the part in half
        first_part_slot_count = floor(number_of_slots/2);
        
        translate(side_by_side ? [0, 2*organizer_depth, 0] : [-organizer_width/2, 0, 0])
        pod_organizer_part(first_part_slot_count, include_left_endcap=true, include_right_endcap=false);
    
        pod_organizer_part(number_of_slots - first_part_slot_count, include_left_endcap=false, include_right_endcap=true);

    } else {
        // need to print multiple middle sections with separate endcaps
        echo(str("You need to print the open-ended piece ", number_of_parts-2, " times and glue them all together."));
        
        minimum_number_of_slots_per_piece = 5;
        
        left_slot_count = floor(number_of_slots / number_of_parts);
        middle_slot_count = floor(number_of_slots / number_of_parts);
        right_slot_count = number_of_slots - left_slot_count - middle_slot_count*(number_of_parts-2);
        
        // If these assertions fail, then we need to fudge the numbers to have a better split across the parts. Future work.
        assert(left_slot_count > minimum_number_of_slots_per_piece);
        assert(middle_slot_count > minimum_number_of_slots_per_piece);
        assert(middle_slot_count > minimum_number_of_slots_per_piece);
        assert(left_slot_count * (pod_spacer_thickness + pod_ring_thickness) < print_bed);
        assert(middle_slot_count * (pod_spacer_thickness + pod_ring_thickness) < print_bed);
        assert(right_slot_count * (pod_spacer_thickness + pod_ring_thickness) + pod_spacer_thickness /* right endcap */ < print_bed);
        
    
        translate([0, 2*organizer_depth, 0])
        pod_organizer_part(left_slot_count, include_left_endcap=true, include_right_endcap=false);
    
        pod_organizer_part(middle_slot_count, include_left_endcap=false, include_right_endcap=false);
    
        translate([0, -2*organizer_depth, 0])
        pod_organizer_part(right_slot_count, include_left_endcap=false, include_right_endcap=true);
    }

} else {
    // print as single piece
    pod_organizer_part(number_of_slots, true, true);
}

//!pod_slot();
//!pod_organizer_part(1, false, false);