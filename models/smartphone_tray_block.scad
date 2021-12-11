block_z=20;
block_x=80;
block_y=130;

slope_y=20;
$fs = 0.15;
corner_radius=1;

 // Add the G logo to the front top surface 
G_logo = true;
G_radius = 10;
G_thickness =7;
G_depth = 2;

difference() {
    
    //cube([block_x,block_y,block_z]);
    
    roundedcube([block_x,block_y,block_z], center = false, radius = corner_radius, apply_to = "all");
    
    // add fron slope
    translate([block_x+0.1,0,0]) 
    rotate([0,-90,0])

    linear_extrude(height = block_x+1, center =false, convexity = 10, twist = 0, $fn = round_smoothness)
    polygon(points=[[-0.1,-0.1],[slope_y,-0.1],[-0.1,block_z+0.1]], paths=[[0,1,2]]);;
    
    create_G_logo();
}




//roundedcube([block_x,block_y,block_z], center=false, corner_radius, "all");

module create_G_logo() {
    extra_deg = atan((G_thickness/2)/(G_radius+G_thickness));

    translate([block_x/2, block_y/1.9, block_z-G_depth])
    rotate([0,0,45])
    rotate_extrude(angle=315 +extra_deg, convexity=10, $fn = round_smoothness) 
       translate([G_radius, 0,0]) square(G_thickness,G_depth+0.1);
    
    translate([block_x/2+G_radius, block_y/1.9+G_thickness/2, block_z-G_depth])
    rotate([90,0,-90])
    linear_extrude(height = G_radius, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
    translate([0, 0,0])
    square(G_thickness,G_depth+0.1);
        
    translate([block_x/2+G_radius, block_y/1.9+G_thickness/2, block_z-G_depth])
    rotate([0,0,-90])
    linear_extrude(height = G_depth+0.1, center = false, convexity = 10, twist = 0, $fn = round_smoothness)
    translate([0, 0,0])
    polygon(points=[[0,0],[G_thickness/2,0],[0,G_thickness-0.1]], paths=[[0,1,2]]);
    
}

module roundedcube(size = [1, 1, 1], center = false, radius = 0.5, apply_to = "all") {
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";

						translate(v = [translate_x, translate_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							sphere(r = radius);
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							rotate(a = rotate)
							cylinder(h = diameter, r = radius, center = true);
						}
					}
				}
			}
		}
	}
}