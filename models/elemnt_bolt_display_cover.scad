
baseplate_length=78;
baseplate_width=47;
baseplate_height=1.5;

module create_base_plate(){   
    cube([baseplate_width,baseplate_length,baseplate_height], true);
}

module create_side_boarder(){
    boarder_radius=1;
    x_offset=baseplate_width/2-boarder_radius;
    z_offset=baseplate_height/2;
    
    translate([x_offset,0,z_offset])
    rotate([90,0,0])
    linear_extrude(baseplate_length,center=true,convexity = 10)
    circle(r = boarder_radius, $fn = 100); 
    
    translate([-x_offset,0,z_offset])
    rotate([90,0,0])
    linear_extrude(baseplate_length,center=true,convexity = 10)
    circle(r = boarder_radius, $fn = 100); 
}

module create_arm(arm_height, arm_width, arm_thinkness, finger_radius){

    // create arm 
    cube([arm_width,arm_thinkness,arm_height]);
    
    // add fingers to top of arm 
    translate([0,0,arm_height-finger_radius])
    rotate([0,90,0])
    linear_extrude(arm_width,center=false,convexity = 10)
    circle(r = finger_radius, $fn = 100); 
    
    // add rounding to arm bottom for more stability
    rounding_radius=arm_thinkness;
    translate([0, -arm_thinkness, rounding_radius])
    rotate([0,90,0])
    linear_extrude(arm_width,center=false,convexity = 10)
    difference()
    {
        square(rounding_radius);
        circle(r = rounding_radius, $fn = 100); 
    }
}

module create_front_arm(){
    arm_thinkness=1.5;
    arm_height=10;
    arm_width=20;
    finger_radius=1;
    
    x_offset=-arm_width/2;
    y_offset=baseplate_length/2-arm_thinkness;
    z_offset=baseplate_height/2;
    
    translate([x_offset, y_offset, z_offset])
    create_arm(arm_height, arm_width, arm_thinkness, finger_radius);
}

module create_back_arm(){
    arm_thinkness=1.5;
    arm_height=5;
    arm_width=8;
    finger_radius=1;
    
    y_offset=baseplate_length/2-arm_thinkness;
    x_offset=baseplate_width*0.4;
    z_offset=baseplate_height/2;
    
    rotate([0,0,180])
    translate([x_offset-arm_width, y_offset, z_offset])
    create_arm(arm_height, arm_width, arm_thinkness, finger_radius);
    
    rotate([0,0,180])
    translate([-x_offset, y_offset, z_offset])
    create_arm(arm_height, arm_width, arm_thinkness, finger_radius);
}

module main()
{
    create_base_plate();
    create_side_boarder();
    create_front_arm();
    
    create_back_arm();
}
main();