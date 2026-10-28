// Portafilter holder for the DF54 grinder.
// Ring with bayonet groove that takes the portafilter, mounted on a block
// whose back follows the (tilted) round grinder body. Origin = ring center.

$fn = 128;

// ---------- ring ----------
bore_d = 64.46;             // inner diameter of the ring
bore_r = bore_d / 2;
outer_d = 73.42;            // outer diameter of the ring = width of the block
outer_r = outer_d / 2;
floor_hole_d = 54.46;       // opening in the floor
floor_h = 5;
floor_lip_r = bore_r + 1;   // floor outer radius below the front opening
ring_h = 29.4;

// crush ribs on the inside of the ring
rib_d = 1;
rib_h = ring_h - 1;
rib_angles = [0, 45, 90, 135, 180];

// ---------- front opening ----------
open_left_y = -20.4;        // left wall end (plane parallel to x)
open_left_round_r = 5;      // rounding of the top corner of the left wall end
open_right_low_x = 9.31;    // right wall end below open_step_z
open_right_high_x = -6.62;  // right wall end above open_step_z
open_step_z = 20;
open_corner_r = 10;

// ---------- bayonet ----------
bayonet_d = 72.98;
bayonet_r = bayonet_d / 2;
funnel_h = 3.5;
groove_z = 33 - funnel_h;
groove_h = 6.25 + funnel_h;
groove_end_angle = 106.3;   // groove runs from the front (-90 deg) to here
channel_end_angle = 80.5;   // vertical entry channel runs from the front to here

// ---------- block / hood ----------
hood_h = 61;
// side profile (y/z) is the max of three arcs
hood_a_start_y = -7.87;     // concave arc, tangent to the ring top
hood_a_r = 56.53;
hood_b_center = [75.2, 11.84]; // convex arc
hood_b_r = 61.18;
hood_top_y = 42.84;         // start of the flat top
hood_top_r = 13;            // rounding into the flat top

// ---------- grinder body (back side) ----------
grinder_d = 112;
grinder_r = grinder_d / 2;
grinder_tilt = 26;          // tilt of the body from vertical
grinder_dist = 73.1;        // ring center -> grinder body at z = 0

// ---------- screws ----------
// holes are tilted with the grinder body (y-z) and parallel to y in the top view
screw_x = 12.5;               // +/- from center, where the hole exits the back
screw_z = 53;               // height where the hole exits the back
screw_d = 5;
screw_head_d = 8;
screw_wall = 3;             // material left under the screw head
screw_len = 40;             // hole length from the back into the bore

big = 300;
meld_offset = 0.01;


module footprint() {
    hull() {
        circle(r = outer_r);
        translate([-outer_r, 0]) square([outer_d, big]);
    }
}

// 2D in (y, z)
module side_profile() {
    a_center = [hood_a_start_y, ring_h + hood_a_r];
    top_center = [hood_top_y, hood_h - hood_top_r];

    intersection() {
        translate([-big, 0]) square([2 * big, hood_h]);

        union() {
            translate([-big, 0]) square([2 * big, ring_h]);

            difference() {
                translate([a_center[0], 0]) square([hood_a_r, a_center[1]]);
                translate(a_center) circle(r = hood_a_r);
            }

            translate(hood_b_center) circle(r = hood_b_r, $fn = 512);
            translate([hood_b_center[0] - hood_b_r, 0]) square([2 * hood_b_r, hood_b_center[1]]);

            translate(top_center) circle(r = hood_top_r);
            translate([top_center[0] - hood_top_r, 0]) square([2 * hood_top_r, top_center[1]]);
            translate([top_center[0], 0]) square([big, hood_h]);
        }
    }
}

// y of the grinder axis at z = 0
grinder_axis_y = grinder_dist + grinder_r / cos(grinder_tilt);

// children are placed in the grinder frame: axis = z
module in_grinder_frame() {
    translate([0, grinder_axis_y, 0])
    rotate([grinder_tilt, 0, 0])
    children();
}

module grinder_body() {
    hull() {
        for (dy = [0, big])
            translate([0, dy, 0])
            in_grinder_frame()
            cylinder(r = grinder_r, h = 4 * hood_h, center = true, $fn = 360);
    }
}

// 2D in (x, z)
module opening_front_shape() {
    translate([-big, floor_h]) square([big + open_right_high_x, big]);

    difference() {
        translate([-big, floor_h]) square([big + open_right_low_x, open_step_z - floor_h]);

        translate([open_right_low_x - open_corner_r, open_step_z - open_corner_r])
        difference() {
            square(open_corner_r + meld_offset);
            circle(r = open_corner_r);
        }
    }
}

// 2D in (y, z)
module opening_side_shape() {
    translate([-big, floor_h]) square([big + open_left_y, big]);

    translate([open_left_y - meld_offset, ring_h - open_left_round_r])
    difference() {
        square([open_left_round_r + meld_offset, open_left_round_r + meld_offset]);
        translate([open_left_round_r + meld_offset, 0]) circle(r = open_left_round_r);
    }
}

module front_opening() {
    intersection() {
        rotate([90, 0, 0]) linear_extrude(height = big, center = true) opening_front_shape();
        rotate([90, 0, 90]) linear_extrude(height = big, center = true) opening_side_shape();
    }

    // floor below the opening only reaches out to floor_lip_r
    translate([0, 0, -meld_offset])
    linear_extrude(height = floor_h + 2 * meld_offset)
    difference() {
        translate([-big, -big]) square([big + open_right_low_x, big + open_left_y]);
        circle(r = floor_lip_r);
    }
}

module bayonet() {
    // groove
    translate([0, 0, groove_z])
    rotate([0, 0, -90])
    rotate_extrude(angle = groove_end_angle + 90)
    square([bayonet_r, groove_h]);

    // vertical entry channel
    translate([0, 0, groove_z])
    rotate([0, 0, -90])
    rotate_extrude(angle = channel_end_angle + 90)
    square([bayonet_r, hood_h]);
}

module screw_holes() {
    // angle around the grinder axis and height along it of the exit point
    phi = asin(screw_x / grinder_r);
    h = (screw_z + grinder_r * cos(phi) * sin(grinder_tilt)) / cos(grinder_tilt);

    // distance from the grinder axis to the back surface at screw_x
    back_dist = grinder_r * cos(phi);

    // holes are parallel to y in the top view, tilted by grinder_tilt only
    for (side = [-1, 1])
        in_grinder_frame()
        translate([side * screw_x, 0, h])
        rotate([90, 0, 0]) {
            translate([0, 0, back_dist - 1])
            cylinder(d = screw_d, h = screw_len + 1, $fn = 48);
            translate([0, 0, back_dist + screw_wall])
            cylinder(d = screw_head_d, h = screw_len - screw_wall, $fn = 48);
        }
}

module holder() {
    difference() {
        intersection() {
            linear_extrude(height = hood_h) footprint();
            rotate([90, 0, 90]) linear_extrude(height = outer_d + 2, center = true) side_profile();
        }

        grinder_body();

        translate([0, 0, floor_h]) cylinder(r = bore_r, h = big);
        translate([0, 0, -meld_offset]) cylinder(d = floor_hole_d, h = floor_h + 2 * meld_offset);

        front_opening();
        bayonet();
        screw_holes();
    }

    for (a = rib_angles)
        rotate([0, 0, a])
        translate([bore_r, 0, floor_h - meld_offset])
        cylinder(d = rib_d, h = rib_h - floor_h + meld_offset, $fn = 24);
}

holder();
