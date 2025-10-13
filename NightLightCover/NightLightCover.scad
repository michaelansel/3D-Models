// LED Night Light https://www.amazon.com/dp/B0BLCD42J7

//// Input image dimensions (pixels)

$image_width = 250;
$image_height = 137;

//// Measured values

// How wide is the lighted area
$portal_width = 43;
$portal_height = 38;
// How big is the faceplate on the light (to get all the way around it)
$faceplate_width = 52;
$faceplate_height = 47;
// How deep is the faceplate (to get behind it with clips)
$faceplate_depth = 5;

//// Configuration values

// How much of a nubbin should exist on the clip
$clip_depth = 1;
// How thick to make the strucural parts of the cover
$skin_thickness = 1;
// Minimum thickness for the cover (for all white pixels in the image)
$cover_backing_thickness = 1;
// Extra clearance at render time
$epsilon = 0.01;
// Thickness of the lithophane
$image_thickness = 1;

// Render quality
$fn = $preview ? 32 : 64;

//// Calculations

// Final object dimensions
$exterior_width = $faceplate_width + 2*$skin_thickness;
$exterior_height = $faceplate_height + 2*$skin_thickness;
$exterior_depth = $faceplate_depth + 2*$clip_depth + $cover_backing_thickness;

$image_scale_factor = $image_width > $image_height ?
    $portal_width/$image_width :
    $portal_height/$image_height;

// rounded-cube function

module roundedcube(
    size = [1, 1, 1], radius = 1.0,
    x = false, y = false, z = false,
    xmin = false, ymin = false, zmin = false,
    xmax = false, ymax = false, zmax = false
) {
	// if single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;
    all = !x && !xmin && !xmax && !y && !ymin && !ymax && !z && !zmin && !zmax;
    hull() {
        for (translate_x = [radius, size[0] - radius]) {
            x_at = (translate_x == radius) ? "min" : "max";
            for (translate_y = [radius, size[1] - radius]) {
                y_at = (translate_y == radius) ? "min" : "max";
                for (translate_z = [radius, size[2] - radius]) {
                    z_at = (translate_z == radius) ? "min" : "max";
                    translate(v = [translate_x, translate_y, translate_z])
                    if (all ||
                        x || (xmin && x_at == "min") || (xmax && x_at == "max") ||
                        y || (ymin && y_at == "min") || (ymax && y_at == "max") ||
                        (zmin && z_at == "min") || (zmax && z_at == "max")
                    ) {
                        sphere(r = radius);
                    } else {
                        rotate =
                            (x || xmin || xmax) ? [0, 90, 0] : (
                            (y || ymin || ymax) ? [90, 90, 0] :
                            [0, 0, 0]
                        );
                        rotate(a = rotate)
                        cylinder(h = 2 * radius, r = radius, center = true);
                    }
                }
            }
        }
    }
}

module cover() {
    difference() {
        // Outer box
        roundedcube([$exterior_width, $exterior_depth, $exterior_height]);
        // Cutout for night light
        translate([$skin_thickness, $cover_backing_thickness, $skin_thickness])
        cube([$faceplate_width, 2*$skin_thickness+$faceplate_depth+$epsilon, $faceplate_height]);
    }
    
    // Left Lower
    translate([
        $skin_thickness,
        $cover_backing_thickness + $faceplate_depth + $clip_depth,
        $exterior_height/3
    ])
    rotate([0, 90, 0])
    nubbin();
    
    // Left Upper
    translate([
        $skin_thickness,
        $cover_backing_thickness + $faceplate_depth + $clip_depth,
        2*$exterior_height/3
    ])
    rotate([0, 90, 0])
    nubbin();
    
    // Right Lower
    translate([
        $skin_thickness+$faceplate_width, // $exterior_width-$skin_thickness
        $cover_backing_thickness + $faceplate_depth + $clip_depth,
        $exterior_height/3
    ])
    rotate([0, -90, 0])
    nubbin();
    
    // Right Upper
    translate([
        $skin_thickness+$faceplate_width, // $exterior_width-$skin_thickness
        $cover_backing_thickness + $faceplate_depth + $clip_depth,
        2*$exterior_height/3
    ])
    rotate([0, -90, 0])
    nubbin();
    
    // Image
    // https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Importing_Geometry#surface
    translate([
        $exterior_width/2,
        -$image_thickness,
        $exterior_height/2
    ])
    rotate([90, 0, 0])
    scale([$image_scale_factor, $image_scale_factor, $image_thickness/100])
    surface(file = "picture.png", center = true, invert = true, convexity=3);
}

module nubbin() {
    difference() {
        sphere($clip_depth);
        translate([0,0,-$clip_depth])
        cube([2*$clip_depth, 2*$clip_depth, 2*$clip_depth], center=true);
    }
}

cover();