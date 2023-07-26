include <Leonardo_UsbHostShield_Measurements.scad>
include <YAPPgenerator_v20.scad>



// Note: length/lengte refers to X axis, 
//       width to Y, 
//       height to Z

/*
      padding-back|<------pcb length --->|<padding-front
                            RIGHT
        0    X-as ---> 
        +----------------------------------------+   ---
        |                                        |    ^
        |                                        |   padding-right 
        |                                        |    v
        |    -5,y +----------------------+       |   ---              
 B    Y |         | 0,y              x,y |       |     ^              F
 A    - |         |                      |       |     |              R
 C    a |         |                      |       |     | pcb width    O
 K    s |         |                      |       |     |              N
        |         | 0,0              x,0 |       |     v              T
      ^ |    -5,0 +----------------------+       |   ---
      | |                                        |    padding-left
      0 +----------------------------------------+   ---
        0    X-as --->
                          LEFT
*/

printLidShell       = true;
printBaseShell      = true;

// Edit these parameters for your own board dimensions
wallThickness       = 1.5;
basePlaneThickness  = 1.0;
lidPlaneThickness   = 1.0;

baseWallHeight      = 20;
lidWallHeight       = 15;

assert(baseWallHeight + lidWallHeight + standoffHeight > totalThickness);

//-- D E B U G -------------------
showSideBySide      = false;
onLidGap            = 0;
shiftLid            = 0;
hideLidWalls        = false;
colorLid            = "yellow";
hideBaseWalls       = false;
colorBase           = "white";
showPCB             = false;
showMarkers         = false;
inspectX            = 0;  //-> 0=none (>0 from front, <0 from back)
inspectY            = 0;  //-> 0=none (>0 from left, <0 from right)
//-- D E B U G -------------------

// Total height of box = basePlaneThickness + lidPlaneThickness 
//                     + baseWallHeight + lidWallHeight
pcbLength           = leonardoPcbLength;
pcbWidth            = leonardoPcbWidth;
pcbThickness        = totalPcbThickness;

assert(leonardoPcbLength > 0);
echo(leonardoPcbLength);
                            
// padding between pcb and inside wall
paddingFront        = 1;
paddingBack         = 1;
paddingRight        = 1.5;
paddingLeft         = 1.5;

// ridge where base and lid off box can overlap
// Make sure this isn't less than lidWallHeight
ridgeHeight         = 3.5;
ridgeSlack          = 0.1;
roundRadius         = 3.0;

// How much the PCB needs to be raised from the base
// to leave room for solderings and whatnot
standoffHeight      = 8-leonardoPcbThickness+0.5; // M3x8mm screws
assert(standoffHeight > solderJoints);
pinDiameter         = 3;
pinHoleSlack        = 0.1;
standoffDiameter    = 5;


//-- pcb_standoffs  -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = standoffHeight
// (3) = flangeHeight
// (4) = flangeDiam
// (5) = { yappBoth | yappLidOnly | yappBaseOnly }
// (6) = { yappHole, YappPin }
// (7) = { yappAllCorners | yappFrontLeft | yappFrondRight | yappBackLeft | yappBackRight }
pcbStands =     [
for (hole = leonardoDrillHoles) [ hole[0], hole[1], standoffHeight, standoffHeight/2, standoffDiameter*1.5, yappBaseOnly, yappHole ],
//  [ 12.49 + 3.43/2, 0.61 + 3.43/2,
//    standoffHeight - (totalPcbThickness + leonardoPcbThickness),
//    standoffHeight/2, 3.43*1.5,
//    yappBaseOnly, yappPin ],
//  [ 13.65 + 3.43/2, 48.63 + 3.43/2,
//    standoffHeight - (totalPcbThickness + leonardoPcbThickness),
//    standoffHeight/2, 3.43*1.5,
//    yappBaseOnly, yappPin ],
//  [ usbShieldPcbXOffset + 0.84 + 3.7/2, 2.58 + 3.7/2,
//    standoffHeight,
//    standoffHeight/2, 3.7*1.5,
//    yappLidOnly, yappHole ],
//                  [3.6,  3, 2, yappBoth, yappPin]                     // back-left
//                , [3.6,  pcbWidth-3, 2, yappBoth, yappHole]           // back-right
//                , [pcbLength-3,  7.5, 2, yappBoth, yappHole]          // front-left
//                , [pcbLength-3, pcbWidth-3, 2, yappBoth, yappPin]     // front-right
                ];

//-- Lid plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLid =    [
//                  [6, -1, 5, (pcbLength-12), 0, yappRectangle]        // left-header
//                , [6, pcbWidth-4, 5, pcbLength-12, 0, yappRectangle]  // right-header
//                , [18.7, 8.8, 2, 0, 0, yappCircle]                    // blue led
                ];

//-- base plane    -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = width
// (3) = length
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBase =   [
//                  [6, -1, 5, (pcbLength-12), 0, yappRectangle]         // left-header
//                , [6, pcbWidth-4, 5, pcbLength-12, 0, yappRectangle]   // right-header
                ];

//-- front plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsFront =  [
//                  [14.0, 1.0, 12.0, 7, 0, yappRectangle, yappCenter]  // microUSB
                ];

//-- left plane   -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsLeft =   [
//                  [31.0, 0.5, 4.5, 3, 0, yappRectangle, yappCenter]    // reset button
                ];

//-- back plane  -- origin is pcb[0,0,0]
// (0) = posy
// (1) = posz
// (2) = width
// (3) = height
// (4) = angle
// (5) = { yappRectangle | yappCircle }
// (6) = { yappCenter }
cutoutsBack =   [
  [ // microUsb
    leonardoUsbCenter - microUsbPlugWidth/2 - connectorTolerance,
    0 - totalPcbThickness + leonardoPcbThickness + microUsbPlugYOffset - connectorTolerance,
    microUsbPlugWidth + 2*connectorTolerance,
    microUsbPlugHeight + 2*connectorTolerance,
    0, yappRectangle
  ],
  [ // barrel, manually adjusted for easier printing
    leonardoBarrelCenter - leonardoBarrelWidth/2 - connectorTolerance,
    0 - totalPcbThickness + leonardoPcbThickness - connectorTolerance,
    leonardoBarrelWidth + 2*connectorTolerance + 2,
    leonardoBarrelHeight - leonardoPcbThickness + 2*connectorTolerance,
    0, yappRectangle
  ],
  [ // USB-A, manually adjusted for easier printing
    usbShieldUsbCenter - usbShieldUsbWidth/2 - connectorTolerance,
    0 - totalPcbThickness + leonardoPcbThickness + totalPcbThickness - leonardoPcbThickness - connectorTolerance - 2.75,
    usbPlugWidth + 2*connectorTolerance,
    usbPlugThickness + 2*connectorTolerance + 2.75,
    0, yappRectangle
  ],
];

//-- pushButtons  -- origin is pcb[0,0,0]
// (0) = posx
// (1) = posy
// (2) = capLength
// (3) = capWidth
// (4) = capAboveLid
// (5) = switchHeight
// (6) = switchTrafel
// (7) = poleDiameter
// (8) = buttonType  {yappCircle|yappRectangle}
pushButtons = [
            //-- 0,  1,  2, 3, 4, 5, 6, 7,   8
                [usbShieldResetYCenter + usbShieldPcbXOffset, usbShieldResetXCenter, 8, 8, 0, usbShieldResetButtonHeight, 1, 3.5, yappCircle],
              ];

//-- snap Joins -- origen = box[x0,y0]
// (0) = posx | posy
// (1) = width
// (2..5) = yappLeft / yappRight / yappFront / yappBack (one or more)
// (n) = { yappSymmetric }
snapJoins   =   [
                    [(shellLength/2)-5/2, 5, yappLeft]
                  , [(shellLength/2)-5/2, 5, yappRight]
                  , [shellWidth-15-5/2, 5, yappBack]
                  , [(shellWidth/2)-5/2, 5, yappFront]
                ];

//-- origin of labels is box [0,0,0]
// (0) = posx
// (1) = posy/z
// (2) = orientation
// (3) = plane {lid | base | left | right | front | back }
// (4) = font
// (5) = size
// (6) = "label text"
labelsPlane =   [
                ];


module baseHookInside()
{
//  translate([30, wallThickness, (basePlaneThickness/2)])
//  {
//    color("blue")
//    {
//      cube([2,(shellWidth-(wallThickness*2)),((basePlaneThickness/2)+baseWallHeight)]);
//    }
//  }
} //  baseHookInside()

module lidHookInside()
{
  
//  translate([45, wallThickness, -(lidPlaneThickness/2)-((basePlaneThickness/2)+baseWallHeight)])
//  {
//    color("blue")
//    {
//      cube([2,(shellWidth-(wallThickness*2)),((basePlaneThickness/2)+baseWallHeight)]);
//    }
//  }
} //  lidHookInside()

//--- this is where the magic happens ---
YAPPgenerate();
