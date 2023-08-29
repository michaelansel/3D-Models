FrameHoleDiameter = 18.8;
DoorHoleDiameter = 9.3;

SensorHeight = 17.1;
SensorDiameter = 9.3;
SensorFlangeDiameter = 10.74;
SensorFlangeHeight = 0.5;

MagnetHeight = 14.35;
MagnetDiameter = 9.36;

LipHeight = 0.5;


// Frame mount
translate([FrameHoleDiameter,FrameHoleDiameter,0])
difference() {
// Main body
union() {
translate([0,0,LipHeight/2])
cylinder(LipHeight, 1.5*FrameHoleDiameter/2, 1.5*FrameHoleDiameter/2, center = true);
translate([0,0,LipHeight+SensorHeight/2])
cylinder(SensorHeight, FrameHoleDiameter/2, FrameHoleDiameter/2, center = true);
}
// Cutouts
translate([0,0,(SensorHeight+1)/2])
cylinder(SensorHeight + 1, SensorDiameter/2, SensorDiameter/2, center = true);

translate([0,0,SensorFlangeHeight/2])
cylinder(SensorFlangeHeight, SensorFlangeDiameter/2, SensorDiameter/2, center = true);
}

/* Not necessary; already the right size
// Door mount
translate([2*FrameHoleDiameter + 2*DoorHoleDiameter,2*DoorHoleDiameter,0])
difference() {
// Main body
union() {
translate([0,0,0.5])
cylinder(1, 1.5*DoorHoleDiameter, 1.5*DoorHoleDiameter, center = true);
translate([0,0,0.5+MagnetHeight/2])
cylinder(SensorHeight, DoorHoleDiameter, DoorHoleDiameter, center = true);
}
// Cutouts
translate([0,0,(MagnetHeight+1)/2])
cylinder(MagnetHeight + 1, MagnetDiameter, MagnetDiameter, center = true);

translate([0,0,0.25])
cylinder(0.5, SensorFlangeDiameter, MagnetDiameter, center = true);
}
*/