desk_thickness = 24.25; // actual measured thickness
clamp_tightening = 1; // decrease width by this amount at the tip to make it tighter; discover by printing at zero and then measuring the resulting gapping

clamp_depth = 33; // how much it goes back onto the desk
clamp_thickness = 5; // how thick is the entire shape (i.e. height above/below desk when installed)
clamp_width = 10; // top-down width when installed
cable_tray_height = 35; // vertical height of the opening

bottom_thickness = 3; // extra thick on the bottom to hold up cables

cable_tray_opening = 8; // largest cable diameter plus any extra space
// tab heights based on size of largest cable; 60/40 ratio
opening_bottom_tab_height = (cable_tray_height-cable_tray_opening)*0.6;
opening_top_tab_height = (cable_tray_height-cable_tray_opening)*0.4;

/* top-down; x->, y^
B    A
0   1
xxxx
3   2
 8  9a
    9b9c
 
   6b6a
 7 6c
4    5
*/

linear_extrude(clamp_width) {
    
polygon([
/* 0 */  [0, 0-clamp_tightening],
/* 1 */  [clamp_depth, 0],
/* 2 */  [clamp_depth, 0-desk_thickness],
/* 3 */  [0, 0-desk_thickness],
/* 4 */  [0, 0-desk_thickness-clamp_thickness-cable_tray_height-bottom_thickness],
/* 5 */  [clamp_depth+clamp_thickness, 0-desk_thickness-clamp_thickness-cable_tray_height-bottom_thickness],
/* 6a */ [clamp_depth+clamp_thickness, 0-desk_thickness-clamp_thickness-cable_tray_height+opening_bottom_tab_height],
/* 6b */ [clamp_depth+clamp_thickness-bottom_thickness, 0-desk_thickness-clamp_thickness-cable_tray_height+opening_bottom_tab_height],
/* 6c */ [clamp_depth+clamp_thickness-bottom_thickness, 0-desk_thickness-clamp_thickness-cable_tray_height],
/* 7 */  [bottom_thickness, 0-desk_thickness-clamp_thickness-cable_tray_height],
/* 8 */  [bottom_thickness, 0-desk_thickness-clamp_thickness],
/* 9a */ [clamp_depth+clamp_thickness-bottom_thickness, 0-desk_thickness-clamp_thickness],
/* 9b */ [clamp_depth+clamp_thickness-bottom_thickness, 0-desk_thickness-clamp_thickness-opening_top_tab_height],
/* 9c */ [clamp_depth+clamp_thickness, 0-desk_thickness-clamp_thickness-opening_top_tab_height],
/* A */  [clamp_depth+clamp_thickness, 0+clamp_thickness],
/* B */  [0, 0+clamp_thickness-clamp_tightening],
]);
};