
fan_d = 123;
fan_r = fan_d / 2;

big_channel_d = 90;
big_channel_r = big_channel_d / 2;
big_center_gnd_offset = 115;

small_channel_d = 72;
small_channel_r = small_channel_d / 2;
small_center_gnd_offset = 55;
small_channel_side_offset = 35/2;

height_channel = 50;
height_cylinder = 45;

// move the object a tiny bit further, that the start and end of object are melded
meld_offset = 0.1;
wall_thickness = 2;


//center_ratio = (big_center_gnd_offset - big_channel_r) - (small_center_gnd_offset - small_channel_r);

// correct radius of big fan
scale_factor = big_channel_d/small_channel_d;


module create_channel(small_r, height, left = true){   
    
    // left is -1 and right is 1
    side_factor = (left) ? -1 : 1;
    x_channel_offset = (side_factor * (small_channel_side_offset + small_channel_r));
        
    linear_extrude(
        height = height, 
        center = true, 
        convexity = 10, 
        scale=scale_factor, 
        $fn=100, 
        twist=side_factor* 90
    )
        
    translate([x_channel_offset, 0, 0])
    
    circle(r = small_r);
}

module create_cylinder(r1, r2, inner=false) {
    
    // if we create the inner cylinder, 
    // the height should be slightly more for a clear object difference
    inner_offset = (inner) ? meld_offset : 0;
    
    scale = r2 / r1;
    
    // first we move object to negative y and during extrution same offset to positive y 
    // --> one side will be parallel to z-axis and other with slope 
    slope_offset = r1;
    
    y_cylinder_offset = - (small_channel_side_offset + small_channel_r) * scale_factor - slope_offset;
    z_cylinder_offset = height_channel / 2 - meld_offset - (inner_offset / 2) ;
    
    translate([0, y_cylinder_offset, z_cylinder_offset])
    
    linear_extrude(
        height = height_cylinder + inner_offset, 
        center = false, 
        convexity = 10, 
        scale=scale, 
        $fn=100
    )
    
    translate([0,  slope_offset, 0,])
    
    circle(r = r1);
    
    //cylinder(h=height_cylinder + inner_offset, r1=r1, r2=r2, center=false,  $fn=100);
}

module create_wall_mount_disk(mount_h, mount_r){   
    cylinder(
        h = mount_h, 
        r1= mount_r, 
        r2= mount_r, 
        center=false,  
        $fn=100
    );   
}

module create_wall_mount_screw_holes(mount_h, mount_r){
 
    mount_middle_r = mount_r - ((mount_r - small_channel_r + wall_thickness) / 2);
    screw_hole_r = 3;
    
    // pythagoras hypotenuse hole every 120°
    // this was not working, as the screw holes were covered by channel
    //xy_hypotenuse = mount_middle_r * sqrt(0.5);

    v_hole_0 = [0, mount_middle_r, -meld_offset/2];
    v_hole_90 = [mount_middle_r, 0, -meld_offset/2];
    v_hole_270 = [-mount_middle_r, 0, -meld_offset/2];
    
    for(vec=[v_hole_0, v_hole_90, v_hole_270])
        translate(vec)
        cylinder(
            h = mount_h + meld_offset, 
            r1= screw_hole_r, 
            r2= screw_hole_r, 
            center=false,  
            $fn=100
        );
    
     // create screw sink
    screw_hole_sink_h = 1.5;
    for(vec=[v_hole_0, v_hole_90, v_hole_270])
        translate(vec + [0,0,mount_h - screw_hole_sink_h])
        cylinder(
            h = screw_hole_sink_h + meld_offset, 
            r1= screw_hole_r, 
            r2= screw_hole_r + screw_hole_sink_h, 
            center=false,  
            $fn=100
        );
}

module create_small_channel_wall_mount(){
    
    x_offset = small_channel_side_offset + small_channel_r;
    z_offset = - (height_channel / 2);
    
    mount_r = small_channel_r + wall_thickness + 10;
    mount_h = 2 * wall_thickness;
    
    // right side 
    translate([x_offset, 0, z_offset])
    difference()
    {
        create_wall_mount_disk(mount_h, mount_r);
        create_wall_mount_screw_holes(mount_h, mount_r);   
    }

    // left side
    translate([-x_offset, 0, z_offset])
    difference()
    {
        create_wall_mount_disk(mount_h, mount_r);
        create_wall_mount_screw_holes(mount_h, mount_r);   
    }
}


module create_outer_channels() {
    small_channel_outter_r = small_channel_r + wall_thickness;
    big_channel_outter_r = big_channel_r + (wall_thickness * scale_factor);
    
    create_channel(small_channel_outter_r, height_channel, false);
    create_channel(small_channel_outter_r, height_channel, true);
    create_cylinder(big_channel_outter_r, fan_r);
    create_small_channel_wall_mount();
}

module create_inner_channels() {
    create_channel(small_channel_r, height_channel + meld_offset, false);
    create_channel(small_channel_r, height_channel + meld_offset, true);
    create_cylinder(big_channel_r, fan_r - wall_thickness, true);
}



difference()
{
    create_outer_channels();
    create_inner_channels();
}
