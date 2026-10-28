// Light clip for the Thule Chariot Sport bike trailer.
// Rebuilt from Thule_HalterFischer.iges / .stl (original: clip + Fischer slide-in mount).
//
// Coordinates match the original STL: the part is an extrusion along X
// (0..clip_width), the cross-section lies in the Y/Z plane.
// Print it lying on the X=0 face (profile flat on the bed).

// which mount to build: "fischer" (original), "hiro50" or "none" (bare clip)
mount = "hiro50";
// show the original STL as transparent overlay for comparison
show_reference = false;

$fn = 64;

// ---------------------------------------------------------------- clip
clip_width = 25;
wall = 2;

// curved back of the clip (midline arc)
arc_center = [-44.01, 21.254];
arc_radius = 56;

// top lip with a downward hook at its free end
hook_tip = [-1.024, 38.7];
hook_top = [-1.024, 41.905];
top_lip_angle = -10.62;   // degrees, slope of the top lip
top_arc_angle = 19.64;    // where the top lip meets the arc

// bottom lip
bottom_lip_start = [-0.8, -1.147];
bottom_arc_angle = -21.97; // where the bottom lip meets the arc

function arc_point(a) = arc_center + arc_radius * [cos(a), sin(a)];

// path of the clip's wall midline
function clip_path() = concat(
    [hook_tip, hook_top],
    [for (a = [top_arc_angle : -2 : bottom_arc_angle]) arc_point(a)],
    [arc_point(bottom_arc_angle), bottom_lip_start]
);

// 2D stroke along a path with round joints
module stroke(path, width) {
    for (i = [0 : len(path) - 2])
        hull() {
            translate(path[i]) circle(d = width);
            translate(path[i + 1]) circle(d = width);
        }
}

// concave corners get a fillet
module fillet(r) {
    offset(r = -r) offset(delta = r) children();
}

module clip_profile() {
    stroke(clip_path(), wall);
}

// extrude a Y/Z profile along X
module extrude_x(length) {
    rotate([90, 0, 90]) linear_extrude(length) children();
}

// ---------------------------------------------------------------- Fischer mount
plate_y = [-24, -5.5];
plate_z = [6.125, 11.625];
pocket_z = [8.025, 10.125];   // slide-in pocket for the light's foot
pocket_y = [-22.5, -5.5];
pocket_depth = 20.76;
slot_width = 4;               // the two slots that free the spring tongue
slot_length = 11;
tongue_y = [-18.5, -9.5];
tongue_corner_r = 3;

// web connecting the bottom lip of the clip with the plate (y, z)
fischer_web_points = [
    [1.2, -1.0], [1.164, 0.194], [0.915, 0.184], [0.446, 0.348], [0.114, 0.716],
    [0.027, 0.951], [-0.235, 1.943], [-0.547, 2.921], [-0.909, 3.882], [-1.32, 4.823],
    [-4.23, 11.049], [-4.508, 11.403], [-4.912, 11.6], [-5.136, 11.625],
    [-5.5, 11.625], [-5.65, 6.125], [-3.65, 4.125], [-3.65, 2.531], [-3.61, 2.046],
    [-3.493, 1.573], [-3.3, 1.125], [-2.8, 0.125], [-2.8, -0.133],
    [-2.653, -0.886], [-2.234, -1.528], [-1.604, -1.965], [-0.855, -2.133], [-0.471, -2.106]
];

module fischer_plate_profile() {
    polygon(fischer_web_points);
    hull() {
        translate([plate_y[1] - 1, plate_z[0]]) square([1, plate_z[1] - plate_z[0]]);
        translate([plate_y[0] + 1, plate_z[1] - 1]) circle(r = 1);
        translate([plate_y[0] + 1, plate_z[0] + 0.76]) circle(r = 1);
    }
}

// cut-outs in the top layer: two slots around the spring tongue
module fischer_tongue_cut() {
    difference() {
        union() {
            translate([-1, pocket_y[0]]) square([slot_length + 1, pocket_y[1] - pocket_y[0]]);
            translate([slot_length, pocket_y[1] - slot_width / 2]) circle(d = slot_width);
            translate([slot_length, pocket_y[0] + slot_width / 2]) circle(d = slot_width);
        }
        hull() {
            translate([tongue_corner_r, tongue_y[1] - tongue_corner_r]) circle(r = tongue_corner_r);
            translate([tongue_corner_r, tongue_y[0] + tongue_corner_r]) circle(r = tongue_corner_r);
            translate([slot_length, tongue_y[0]]) square([5, tongue_y[1] - tongue_y[0]]);
        }
    }
}

// cut-out in the bottom layer (entry with flared corners + wider recess)
module fischer_bottom_cut() {
    // entry
    translate([-1, -19.95]) square([7.11, 11.9]);
    // flared corners at x = 0
    // (squares overlap the entry by 0.1 so no zero-width sliver remains)
    difference() {
        translate([-1, -8.15]) square([4, 3.1]);
        translate([3, -5.05]) circle(r = 3);
    }
    difference() {
        translate([-1, -22.95]) square([4, 3.1]);
        translate([3, -22.95]) circle(r = 3);
    }
    // recess
    hull() {
        translate([6.11, -20.35]) square([1, 12.7]);
        translate([17.61, -8.65]) circle(r = 1);
        translate([17.61, -19.35]) circle(r = 1);
    }
}

// small catch under the tip of the tongue
module fischer_latch() {
    hull() {
        translate([1.6, -16.1, pocket_z[1] + 1.13]) rotate([-90, 0, 0]) cylinder(r = 1.5, h = 4.2);
        translate([1.6, -17.4, pocket_z[1] + 0.5]) rotate([-90, 0, 0]) cylinder(r = 0.5, h = 6.8);
    }
}

module fischer_mount() {
    difference() {
        extrude_x(clip_width) fischer_plate_profile();
        // pocket
        translate([0, 0, pocket_z[0]]) linear_extrude(pocket_z[1] - pocket_z[0])
            hull() {
                translate([-1, pocket_y[0]]) square([1, pocket_y[1] - pocket_y[0]]);
                translate([pocket_depth - 1, pocket_y[1] - 1]) circle(r = 1);
                translate([pocket_depth - 1, pocket_y[0] + 1]) circle(r = 1);
            }
        translate([0, 0, pocket_z[1] - 0.01]) linear_extrude(plate_z[1] - pocket_z[1] + 1)
            fischer_tongue_cut();
        translate([0, 0, plate_z[0] - 1]) linear_extrude(pocket_z[0] - plate_z[0] + 1.01)
            fischer_bottom_cut();
    }
    intersection() {
        fischer_latch();
        translate([0, -30, pocket_z[0]]) cube([clip_width, 30, pocket_z[1] - pocket_z[0]]);
    }
}

// ---------------------------------------------------------------- Sigma Hiro 50 mount
// The Sigma bracket stays on the light (rubber strap removed). Its two ear
// flanges slide into C-rails, a spring tongue with a catch snaps behind the
// top end of the bracket. The light hangs below, LED facing -Z, its back
// parallel to the trailer rail (X); it slides in from X = 0, bottom end first.
// Lift the tongue tip at X = 0 to release the light.

// bracket, measured with calipers
hiro_bracket_length = 26.2;   // along the light's back
hiro_wedge_top = 4.7;         // light back -> pad surface, thin (top) end
hiro_wedge_bottom = 14.1;     // light back -> pad surface, thick (bottom) end
hiro_ear_inner = 24.7;        // between the two ear flanges
hiro_ear_outer = 27.4;        // across the two ear flanges
hiro_flange_length = 17.7;
hiro_flange_depth = 6.3;
hiro_flange_gap = 3.4;        // flange edge -> light back, at the bottom end
hiro_pad_width = 17.5;
// light body, estimated from photos (only used for the preview)
hiro_light_size = [63, 19.9, 20]; // length, width (measured), depth
hiro_light_top_overhang = 8;      // light beyond the top end of the bracket

// receiver
hiro_clearance = 0.3;
hiro_seat_gap = 0.2;          // between pad and seat (rubber pad)
hiro_lip = [1.0, 2];          // overlap under the flange, thickness
                              // (inner edges 22.7 apart, the light body must fit between)
hiro_side_wall = 2;
hiro_stop = 2.5;              // end stop thickness
hiro_body_min = 3;            // material above the seat at the deep end
hiro_tongue = [13, 10, 1.8];  // length, width, thickness
hiro_tongue_slot = 1.5;
hiro_nub = [2.5, 1];          // length, height of the catch
hiro_tab = 3;                 // finger tab in front of the catch
hiro_center_y = -5.5 - (hiro_ear_outer / 2 + hiro_clearance + hiro_side_wall);
hiro_top_z = plate_z[1];

// derived
hiro_angle = atan((hiro_wedge_bottom - hiro_wedge_top) / hiro_bracket_length);
hiro_half = hiro_ear_outer / 2 + hiro_clearance + hiro_side_wall;
hiro_pad_length = hiro_bracket_length / cos(hiro_angle);

// Receiver frame: origin on the pad surface at the bracket's bottom end,
// u (x) along the pad towards the deep end, v (y) across, w (z) away from the light.
// The bracket occupies u = -hiro_pad_length .. 0, w <= 0.
hiro_flange_edge_w = -(hiro_wedge_bottom - hiro_flange_gap) * cos(hiro_angle);
hiro_flange_top_w = hiro_flange_edge_w + hiro_flange_depth;
hiro_u_stop = hiro_clearance;
hiro_u_end = hiro_u_stop + hiro_stop;
hiro_u_nub = -hiro_pad_length - hiro_clearance;
hiro_u_entry = hiro_u_nub - hiro_nub[0] - hiro_tab;
hiro_u_rail = -hiro_flange_length - 1.5;
hiro_lip_w = hiro_flange_edge_w - hiro_clearance - hiro_lip[1];

hiro_origin = [
    -hiro_u_entry * cos(hiro_angle) + hiro_seat_gap * sin(hiro_angle),
    hiro_center_y,
    hiro_top_z - hiro_body_min - hiro_u_end * sin(hiro_angle) - hiro_seat_gap * cos(hiro_angle)
];

module hiro_frame() {
    translate(hiro_origin) rotate([0, -hiro_angle, 0]) children();
}

// wedge-shaped body above the seat, flat on top
module hiro_body() {
    intersection() {
        translate([0, hiro_center_y - hiro_half, -50]) cube([100, 2 * hiro_half, hiro_top_z + 50]);
        hiro_frame() translate([hiro_u_entry, -hiro_half, hiro_seat_gap])
            cube([hiro_u_end - hiro_u_entry, 2 * hiro_half, 100]);
    }
}

// C-rail around one ear flange (+v side)
module hiro_rail() {
    len = hiro_u_end - hiro_u_rail;
    flange_out = hiro_ear_outer / 2 + hiro_clearance;
    // side wall
    translate([hiro_u_rail, flange_out, hiro_lip_w])
        cube([len, hiro_side_wall, hiro_seat_gap - hiro_lip_w + 0.5]);
    // lip under the flange
    translate([hiro_u_rail, hiro_ear_inner / 2 - hiro_lip[0], hiro_lip_w])
        cube([len, flange_out - hiro_ear_inner / 2 + hiro_lip[0] + 0.01, hiro_lip[1]]);
}

module hiro_receiver() {
    difference() {
        union() {
            hiro_body();
            hiro_frame() {
                hiro_rail();
                mirror([0, 1, 0]) hiro_rail();
                // end stop
                translate([hiro_u_stop, -hiro_half, hiro_flange_edge_w])
                    cube([hiro_stop, 2 * hiro_half, hiro_seat_gap - hiro_flange_edge_w + 0.5]);
            }
        }
        // free the spring tongue
        hiro_frame() translate([hiro_u_entry - 1, -(hiro_tongue[1] / 2 + hiro_tongue_slot), hiro_seat_gap - 1])
            cube([hiro_tongue[0] + 1, hiro_tongue[1] + 2 * hiro_tongue_slot, 100]);
    }
    hiro_frame() {
        translate([hiro_u_entry, -hiro_tongue[1] / 2, hiro_seat_gap])
            cube([hiro_tongue[0] + 1, hiro_tongue[1], hiro_tongue[2]]);
        // catch, ramp towards the entry
        rotate([90, 0, 0]) linear_extrude(hiro_tongue[1] - 2, center = true)
            polygon([
                [hiro_u_nub, hiro_seat_gap + 0.01],
                [hiro_u_nub, hiro_seat_gap - hiro_nub[1]],
                [hiro_u_nub - 0.5, hiro_seat_gap - hiro_nub[1]],
                [hiro_u_nub - hiro_nub[0], hiro_seat_gap + 0.01]
            ]);
    }
}

module hiro50_mount() {
    // web from the clip to the receiver
    extrude_x(clip_width) {
        polygon(fischer_web_points);
        translate([-7, plate_z[0]]) square([1.6, plate_z[1] - plate_z[0]]);
    }
    intersection() {
        hiro_receiver();
        translate([0, -100, -100]) cube(200);
    }
}

// light with bracket, for the preview only
module hiro_light() {
    a = hiro_angle;
    translate(hiro_origin - [0, 0, hiro_wedge_bottom]) {
        translate([hiro_light_top_overhang * -1 - hiro_bracket_length, -hiro_light_size[1] / 2, -hiro_light_size[2]])
            cube(hiro_light_size);
        rotate([90, 0, 0]) linear_extrude(hiro_pad_width, center = true)
            polygon([[0, 0], [0, hiro_wedge_bottom], [-hiro_bracket_length, hiro_wedge_top], [-hiro_bracket_length, 0]]);
    }
    hiro_frame() for (m = [0, 1]) mirror([0, m, 0])
        translate([-hiro_flange_length, hiro_ear_inner / 2, hiro_flange_edge_w])
            cube([hiro_flange_length, (hiro_ear_outer - hiro_ear_inner) / 2, hiro_flange_depth]);
}

// ---------------------------------------------------------------- assembly
// side: "left" or "right" (mirrored), for the two sides of the trailer
side = "right";
show_light = false;

mirror([side == "right" ? 1 : 0, 0, 0]) {
    extrude_x(clip_width) clip_profile();

    if (mount == "fischer") fischer_mount();
    if (mount == "hiro50") hiro50_mount();

    if (show_reference) %import("Thule_HalterFischer.stl");
    if (show_light && mount == "hiro50") %hiro_light();
}
 