/*

Customisable cup holder adapter for a phone

Originally designed for Toyota Yaris cup holder to fit a Samsung Galaxy S8

(c) Matthias Liffers 2018

Released under CC-BY 4.0 license

All dimensions in millimetres

Changelog:

v0.1
 * First release

v0.2
 * Added side walls to dock rest to stop phone falling over when not plugged in
 * Added plug offset for phones where the plug is not dead centre along the y axis
 * Removed roundess from top

v1.0
 * modularised code
 * a bit more friendly for Thingiverse Customizer

v2.0
 * Converted from rounded shape to tapered shape
 * Added shelf to hold charging plug so that it doesn't get pushed down when the phone is inserted

*/ 

/* [ Basics ] */

// Diameter of cup holder
holder_top_diameter = 85;
// Diamater of cup holder bottom
holder_bottom_diameter = 85;
// Height of cup holder
holder_height = 50;

// Phone width
phone_x = 79;
// Phone Depth
phone_y = 9;

// Angle at which the phone should lean back
dock_angle = 20;
// Depth at which phone should be inset into the holder
dock_z = 12;

/* [ Back rest ] */

// Add back rest
dock_rest = true;
// Phone back rest height
dock_rest_z = 25;
// Phone back rest width
dock_rest_x = phone_x;
// Phone back rest depth
dock_rest_y = 5;

/* [ Charge plug hole ] */

plug = true; // Add charge plug hole
// Width of charging plug
plug_x = 13;
// Depth of charging plug
plug_y = 7;
// Length of charging plug, minus the contacts
plug_z = 20.5;
// Distance of charging plug from front of phone
plug_offset = 1.5;

/* [ Cable routing channel ] */

// Add cable routing channel
cable = false;
// Width of cable routing channel
cable_x = 3;
// Depth of cable routing channel
cable_y = 3;


// Add a front slope (for non-embedded cup holder) 
front_slope = true;
slope_rise = 43;
slope_run = 30;

// Add side curves to the dock for phones with curved display 
side_curves = true;
curve_factor = 0.5;
// QUICK & DIRTY!!!!: overwritte phone_x  and reduce it = phone_x - (phone_y * curve_facotor * 2)
phone_x = 75;

 // Add the G logo to the front top surface 
G_logo = true;
G_radius = 5;
G_thickness =3;
G_depth = 2;

// Add bottom gouges for cable
bottom_gouges = false;

// Smoothness of all rounded edges. Use a low number for faster rendering, increase when performing final render
round_smoothness= 200;

cos_d_a = cos(dock_angle);
sin_d_a = sin(dock_angle);
tan_d_a = tan(dock_angle);

holder_top_radius = holder_top_diameter/2;
holder_bottom_radius = holder_bottom_diameter/2;
dock_drop = (sin_d_a * phone_y / 2) - (cos_d_a * dock_z / 2);
dock_height_add = tan_d_a * (phone_y / 2 + dock_rest_y);
gouge_height = holder_height - ((cos_d_a * plug_z) + (cos_d_a * dock_z) - (sin_d_a * (phone_y - plug_offset))) - 5;
rest_setback = (sin_d_a * dock_z / 2) + (cos_d_a * phone_y / 2);

difference() {
    difference() {
        union() {
            // Main body
            cylinder( h = holder_height, r1 = holder_bottom_radius, r2 = holder_top_radius, $fn=round_smoothness);
                // Dock rest
                if (dock_rest)
                    create_dock_rest();
        }
        
        translate([(0 - phone_x) / 2, 0, holder_height + dock_drop])
            rotate(a = (0 - dock_angle), v = [1, 0, 0])
                translate ([0, 0 - (phone_y / 2), 0 - (dock_z / 2)])
                    union() {
                        cube([phone_x, phone_y, dock_z + 1]);
                        if (plug) 
                            create_plug_hole();
                    }
        // Cable channel
        if (cable)
            create_cable_channel();
        
        // Bottom gouges
        if (bottom_gouges){
            create_bottom_gouges();
        }
        
        // create a front slope
        if(front_slope){
            create_front_slope();
        }
        
        // create dock side curves
        if(side_curves){
            create_dock_side_curve();
        }
        
        // Add the G logo
        if(G_logo)
            create_G_logo();
    }
    // Trim entire cup holder down to just the radius and slice the top off the dock
    difference() {
        cylinder(h = holder_height + dock_rest_z * 2, r = holder_top_radius * 2, $fn = round_smoothness);
         cylinder(h = holder_height * 2, r1 = holder_bottom_radius, r2 = holder_top_radius + (holder_top_radius - holder_bottom_radius), $fn = round_smoothness);
    }
}

module create_dock_rest() {
    translate([0 - (dock_rest_x / 2), rest_setback, holder_height])
        rotate(a = (0 - dock_angle), v = [1, 0, 0])
            translate([0, 0, 0 - dock_height_add])
                union() {
                    cube([dock_rest_x, dock_rest_y, dock_rest_z + dock_height_add]);
                    translate([-2 - dock_rest_y, 0 - phone_y, 0])
                        cube([dock_rest_y+2, phone_y + dock_rest_y, dock_rest_z + dock_height_add]);
                    translate([dock_rest_x, 0 - phone_y, 0])
                        cube([dock_rest_y+2, phone_y + dock_rest_y, dock_rest_z + dock_height_add]);
                }    
}

module create_bottom_gouges(){
                translate([0 - (plug_y + 5) / 2, 0 - holder_bottom_radius, -1])
                cube([plug_y + 5, holder_bottom_diameter, gouge_height + 1]);
            translate([0 - holder_bottom_radius, 0 - (plug_y + 5) / 2, -1])
                cube([holder_bottom_diameter, plug_y + 5, gouge_height +1 ]);
}

module create_cable_channel() {
    translate([0 - (cable_x / 2), holder_top_radius -  2 * cable_y, -1])
        rotate(a = 0-atan((holder_top_radius - holder_bottom_radius)/ holder_height), v = [1,0,0])
            cube([cable_x, cable_y, holder_height +2]);
}

module create_plug_hole() {
    echo(phone_x);
    translate([phone_x / 2 - plug_x / 2, plug_offset, -10 - plug_z])
        union() {
            cube([plug_x, plug_y, plug_z + 11]);
            translate([plug_x/2 - plug_y/2 - 0.5, 0 - plug_offset, - 13])
                cube([plug_y + 1, plug_x + 1, plug_z + plug_z + 30]);
        }
}


module create_front_slope() {
    rotate([0,-90,0])
      linear_extrude(height = holder_bottom_diameter+1, center = true, convexity = 10, twist = 0, $fn = round_smoothness)
        polygon(points=[[-0.1,-holder_bottom_radius-0.1],[slope_rise,-holder_bottom_radius-0.1],[-0.1,-holder_bottom_radius + slope_run]], paths=[[0,1,2]]);;
}

module create_dock_side_curve(){
    // left side
    translate([(0 - phone_x) / 2, 0, holder_height + dock_drop])
        rotate(a = (0 - dock_angle), v = [1, 0, 0])
            translate ([0, 0, 0 - dock_z/2])
                 linear_extrude(height = dock_rest_z + dock_z+0.1, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
                        intersection(){
                            scale([curve_factor,1])circle(d=phone_y);
                            translate ([-2.1, -phone_y/2, 0])
                            square(phone_y, phone_y);
                        }
    
        // right side
        translate([(0 + phone_x) / 2, 0, holder_height + dock_drop])
        rotate(a = (0 - dock_angle), v = [1, 0, 0])
            translate ([0, 0, 0 - dock_z/2])
                 linear_extrude(height = dock_rest_z + dock_z+0.1, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
                        intersection(){
                            scale([curve_factor,1])circle(d=phone_y);
                            translate ([2.1-phone_y, -phone_y/2, 0])
                            square(phone_y, phone_y);
                        }
                       
}

module create_G_logo() {
    extra_deg = atan((G_thickness/2)/(G_radius+G_thickness));

    translate([0, -holder_top_radius/1.9, holder_height-G_depth])
    rotate([0,0,45])
    rotate_extrude(angle=315 +extra_deg, convexity=10, $fn = round_smoothness) 
       translate([G_radius, 0,0]) square(G_thickness,G_depth+0.1);
    
    translate([G_radius, -holder_top_radius/1.9+G_thickness/2, holder_height-G_depth])
    rotate([90,0,-90])
    linear_extrude(height = G_radius, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
    translate([0, 0,0])
    square(G_thickness,G_depth+0.1);
        
    translate([G_radius, -holder_top_radius/1.9+G_thickness/2, holder_height-G_depth])
    rotate([0,0,-90])
    linear_extrude(height = G_depth+0.1, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
    translate([0, 0,0])
    polygon(points=[[0,0],[G_thickness/2,0],[0,G_thickness-0.1]], paths=[[0,1,2]]);
    
}