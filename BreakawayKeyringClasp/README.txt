BREAKAWAY KEY RING CLASP - v2 (validated)
============================================

WHAT CHANGED FROM v1
v1 was a rough blob with an ad-hoc barb bolted onto the side - it hadn't
been checked for actual mechanical fit, and when I cross-sectioned it,
it turned out the retaining tab wasn't correctly engaging anything.

v2 is a proper cantilever snap-fit, the same mechanism used in real
snap-fit fasteners:
 - a flexible beam, anchored at one end, floats above a rigid base rail
   with an air gap that lets it flex downward
 - a ramped barb on top of the beam cams down going in, then springs up
   into a stepped pocket once fully inserted
 - pulling back, the barb's angled back face cams against the pocket's
   edge and releases - this angle is your main "how much force" knob

I validated this by rendering an actual Y=0 cross-section through the
locked assembly (cross_section_validation.png) with full CGAL geometry
evaluation (not just the fast preview, which silently produces wrong
pictures for nested boolean operations - that's what hid a real bug
during this process: the barb was initially mis-extruded off to the
side of the beam entirely, invisible in the fast preview, and only
showed up once I forced a real render and looked at the slice).
The cross-section confirms: the barb sits inside the pocket with
~0.3mm clearance to the ceiling (no interference), the flex gap is
open beneath the beam (room to compress), and the stop flange seats
flush against the socket mouth.

FILES
- breakaway_keyring_clasp.scad  -> parametric source
- clasp_male.stl / clasp_female.stl -> print these
- assembly_preview.png          -> both halves, locked together
- cross_section_validation.png  -> the internal-fit proof (see above)
- male_half_preview.png / female_half_preview.png -> each part alone

INTERLOCK DEPTH IS NOW SELF-SIZING
barb_h (how deep the barb/pocket interlock is) and flex_gap (the air
space the beam compresses into) used to be two independent numbers
you had to keep in sync by hand - easy to get wrong in either
direction (too little gap = jams, can't insert or release; too much
gap = wasted depth, weaker hold than the geometry could give).

flex_gap is now DERIVED: flex_gap = barb_h + insertion_clearance.
Turn up barb_h for a deeper interlock and the gap grows with it
automatically, always exactly "just enough." insertion_clearance
(default 0.25mm) is the only slack left in that relationship - it's
a print-tolerance/friction margin, not a style choice. Tighten it
toward ~0.15mm only if your printer holds dimensions well; loosen it
if prints come out too tight to release.

The .scad file also asserts this relationship on every render:
if insertion_clearance is ever <=0, or flex_gap is hand-overridden
to less than barb_h+insertion_clearance, or arm_t is too thin to
print reliably, the build stops with an error instead of silently
producing a part that can't be inserted or won't release. Verified
this actually fires on a broken config before shipping this version.

TUNING RELEASE FORCE (edit the .scad, re-render, re-export)
  barb_h            - THE interlock-depth lever, and now the one to
                      push first: deeper interlock, flex_gap follows
                      automatically. Current default: 1.8mm (up from
                      1.1mm in the previous version).
  release_ramp_len  - steepness of the barb's back face. Shorter =
                      steeper = more pull-apart force. Longer =
                      easier release. Start: 3.5mm.
  arm_t             - beam thickness. Thicker = stiffer beam = more
                      force everywhere (insertion AND release).

PRINT NOTES
- PLA or ABS. No supports needed - both halves print flat as designed.
- The beam and barb are the working parts; print with at least 3-4
  perimeters through that region so it doesn't delaminate under flex.
- This is still a first physical prototype: the numbers above are
  reasoned from geometry, not yet pull-tested. Print a pair, test it,
  and adjust release_ramp_len first if it's too strong or too weak.

KEY RING HOLE FIX
The loop's hole used to come out as a crescent instead of a full
circle - the fillet connecting the loop to the body was a small
cylinder centered on the hole itself, sized smaller than the hole's
radius, so it plugged most of the opening. Fixed by cutting the hole
once, as a final step over the whole assembled loop+connector region,
so no connector geometry can intrude into it again regardless of how
the blend is shaped. Verified with a render of each half - both now
show a full, clean, unobstructed circular hole sized to loop_id.
