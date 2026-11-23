// =====================================================================
// Breakaway Key Ring Clasp v2
// A proper cantilever snap-fit: a flexing beam with a ramped barb on
// the male half hooks into a stepped pocket in the female half.
// =====================================================================

// ---------- TUNABLE PARAMETERS ----------
wall          = 2.4;   // housing side/roof wall thickness
plug_w        = 10;    // width (Y) of the plug / cavity
w_clear       = 0.6;   // total width clearance (cavity_w = plug_w + w_clear)

base_h        = 1.6;   // base rail thickness (always contacts socket floor)
arm_t         = 1.8;   // beam thickness -- PRIMARY stiffness lever
L_free        = 14;    // free (flexing) length of the beam, tip to root
root_len      = 4;     // length of the solid flange that stops against the mouth
tip_lead      = 2.5;   // blunt lead-in before the ramp starts

barb_h        = 1.8;   // bump height -- THE interlock depth lever. Push this as
                        // deep as you want; flex_gap below is derived from it
                        // automatically so the air gap is always just barely
                        // enough to swallow it, never more.
insertion_clearance = 0.25;
                        // minimum extra room, beyond barb_h itself, that the
                        // beam needs to fully compress and let the barb pass.
                        // This is a print-tolerance/friction margin, not a
                        // style choice - too small and the tab jams or shears
                        // on insertion/removal instead of flexing. 0.15-0.3mm
                        // is reasonable for FDM; tighten toward 0.15 only if
                        // your printer holds tolerance well.
flex_gap = barb_h + insertion_clearance;
                        // DERIVED, not hand-set: this is exactly what makes
                        // barb_h "as deep as possible while leaving just
                        // enough air gap" - raising barb_h automatically
                        // raises flex_gap by the same amount, so there's
                        // never slack wasted and never a gap that's too
                        // tight to release.

ramp_in_len   = 3.0;   // front (insertion) ramp
barb_flat     = 1.5;   // flat top of the bump, sits in the pocket when locked
release_ramp_len = 3.5; // back ramp -- PRIMARY pull-apart force lever

// ---------- DESIGN-RULE ASSERTIONS ----------
// These guard the one invariant that actually makes this a functional
// part rather than a fused blob or a loose rattle: the beam must have
// *just enough* clearance to fully retract the barb, and no more.
assert(insertion_clearance > 0,
    "insertion_clearance must be > 0mm - with zero (or negative) clearance the beam has nowhere to compress into, so the barb cannot retract and the part can never be inserted or removed.");
assert(flex_gap >= barb_h + insertion_clearance - 1e-9,
    str("flex_gap (", flex_gap, "mm) is not large enough for barb_h (", barb_h,
        "mm) plus insertion_clearance (", insertion_clearance,
        "mm) - the barb would physically collide with the throat ceiling on insertion. If you hand-set flex_gap instead of using the derived value, increase it."));
assert(barb_h > 0, "barb_h must be positive - it's the whole interlock; at 0 there is nothing to hold the two halves together.");
assert(arm_t >= 1.0,
    str("arm_t (", arm_t, "mm) is too thin to print reliably as a repeatedly-flexed beam - use at least 1.0mm."));

c1            = 0.3;   // fit clearance added to throat/pocket ceiling heights
tip_gap       = 1.0;   // clearance between tip and the socket's back wall
back_wall     = 1.6;   // thickness of the socket's closed back wall
step_margin   = 0.5;   // margin so the bump fully clears the step when seated

loop_id       = 7.5;
loop_wall     = 3;

$fn = 48;

// ---------- DERIVED ----------
barb_start   = tip_lead;
ramp_in_end  = barb_start + ramp_in_len;
flat_end     = ramp_in_end + barb_flat;
barb_end     = flat_end + release_ramp_len;
L_total      = L_free + root_len;

H_low  = base_h + flex_gap + arm_t + c1;
H_high = H_low + barb_h;

w_bump_shallow_seated = L_free - barb_end;
step_pos = max(0.1, w_bump_shallow_seated - step_margin);

socket_len = L_free + tip_gap;
outer_len  = socket_len + back_wall;

cavity_w = plug_w + w_clear;
outer_w  = cavity_w + 2*wall;
outer_h  = H_high + wall;

echo("barb_h=", barb_h, "flex_gap=", flex_gap, "(slack over minimum =",
     flex_gap - barb_h - insertion_clearance, "mm)");
echo("H_low=", H_low, "H_high=", H_high, "step_pos=", step_pos,
     "socket_len=", socket_len, "bump seated span=",
     w_bump_shallow_seated, "-", L_free-barb_start);

module keyring_loop_solid(h) {
    // solid boss only -- no hole. The hole is cut once, at the very end,
    // over the whole assembled region (see male_root_and_loop /
    // female_half below) so no connector geometry can ever intrude into
    // it again, regardless of how the blend/fillet is shaped.
    cylinder(h = h, r = loop_id/2 + loop_wall);
}

module male_base_rail() {
    translate([0,-plug_w/2,0])
        cube([L_total, plug_w, base_h]);
}

module male_beam() {
    // free cantilever beam, flat top (no barb), full length 0..L_free
    translate([0, -plug_w/2, base_h+flex_gap])
        cube([L_free, plug_w, arm_t]);
}

module male_barb() {
    // ramp / flat / ramp bump sitting on top of the beam, extruded across plug_w (Y)
    // polygon+extrude builds in local Z=0..plug_w; rotate(90,x) maps that to Y=-plug_w..0;
    // translate by +plug_w/2 recenters it to Y=-plug_w/2..+plug_w/2, matching the beam.
    translate([0, plug_w/2, 0])
    rotate([90,0,0])
    linear_extrude(height = plug_w)
    polygon(points = [
        [barb_start,  base_h+flex_gap+arm_t],
        [ramp_in_end, base_h+flex_gap+arm_t+barb_h],
        [flat_end,    base_h+flex_gap+arm_t+barb_h],
        [barb_end,    base_h+flex_gap+arm_t],
    ]);
}

module male_root_and_loop() {
    full_h = base_h+flex_gap+arm_t+barb_h;
    loop_cx = L_total + loop_id/2 + loop_wall - 1;
    difference() {
        union() {
            // root block: anchors the beam, acts as the insertion-depth stop
            translate([L_free, -plug_w/2 - 0.5, 0])
                cube([root_len, plug_w+1, full_h]);
            // key ring loop boss + a generous blended connector -- both
            // are allowed to overlap the hole area here, because the
            // hole itself is cut afterward, once, below.
            translate([loop_cx, 0, 0])
                keyring_loop_solid(full_h);
            hull() {
                translate([L_total-1, -plug_w/2-0.5, 0])
                    cube([1, plug_w+1, full_h]);
                translate([loop_cx, 0, 0])
                    cylinder(h = full_h, r = loop_wall);
            }
        }
        // the key ring hole: cut once, full diameter, guaranteed clear
        translate([loop_cx, 0, -1])
            cylinder(h = full_h+2, r = loop_id/2);
    }
}

module male_half() {
    union() {
        male_base_rail();
        male_beam();
        male_barb();
        male_root_and_loop();
    }
}

module female_half() {
    loop_cx = outer_len + loop_id/2 + loop_wall - 1;
    difference() {
        union() {
            translate([0, -outer_w/2, -wall])
                cube([outer_len, outer_w, outer_h+wall]);
            translate([loop_cx, 0, 0])
                keyring_loop_solid(outer_h);
            hull() {
                translate([outer_len-1, -outer_w/2, -wall])
                    cube([1, outer_w, outer_h+wall]);
                translate([loop_cx, 0, 0])
                    cylinder(h = outer_h, r = loop_wall);
            }
        }
        translate([-1, -cavity_w/2, 0])
            cube([step_pos+1, cavity_w, H_low]);
        translate([step_pos, -cavity_w/2, 0])
            cube([socket_len-step_pos, cavity_w, H_high]);
        // the key ring hole: cut once, full diameter, guaranteed clear
        translate([loop_cx, 0, -1])
            cylinder(h = outer_h+2, r = loop_id/2);
    }
}

// fully seated / locked assembly: male local x=t -> world x = L_free - t
module assembly_seated() {
    color("SteelBlue") female_half();
    color([1,0.5,0.4])
    translate([L_free, 0, 0]) rotate([0,0,180]) male_half();
}

assembly_seated();
