// create the bottom plate 
bottom_height = 2;
bottom_radius = 15.7;

cylinder(h = bottom_height, r1 = bottom_radius, r2 = bottom_radius, center = true, $fn = 100);
    
    
// create the padding for the bush button 
difference()
{
    button_padding_h=3;
    button_padding_r=10.5;
    button_padding_thickness=1.5;
    
   translate([0,0,bottom_height/2]) 
   cylinder(h = button_padding_h, r1 = button_padding_r+button_padding_thickness, r2 = button_padding_r + button_padding_thickness, center = false, $fn = 100);
    
    translate([0,0,bottom_height/2]) 
   cylinder(h = button_padding_h + 0.01, r1 = button_padding_r , r2 = button_padding_r , center = false, $fn = 100);
}

// create the three hold arms
arm_height=11.5;
arm_thickness=2;
arm_gap = 15;

module create_arm_ring(){
    
    difference()
    {
       translate([0,0,bottom_height/2]) 
        
       cylinder(h = arm_height, r1 = bottom_radius, r2 = bottom_radius, center = false, $fn = 100);
        
        translate([0,0,bottom_height/2]) 
            
       cylinder(h = arm_height + 0.01, r1 = bottom_radius - arm_thickness, r2 = bottom_radius - arm_thickness , center = false, $fn = 100);
    }
    
    // add arm "fingers" 
    rotate_extrude(convexity = 10, $fn = 100)
    translate([bottom_radius-arm_thickness, arm_height+0.25, 0])
    rotate([0,0,0])
    circle(r = 0.75, $fn = 100); // use a half circle instead
    
    // add rounding to arm bottom for more stability 
        difference()
    {
        rounding_r=2;
        rotate_extrude(convexity = 10, $fn = 100)
        translate([bottom_radius-arm_thickness, bottom_height/2, 0])
        circle(r = rounding_r, $fn = 100); // use a half circle instead
            
        rotate_extrude(convexity = 10, $fn = 100)
        translate([bottom_radius-arm_thickness-rounding_r, bottom_height/2 +rounding_r , 0])
        circle(r = rounding_r, $fn = 100); // use a half circle instead
    }
    
}

module create_arm_gap(x_offset_deg = 0){
    translate([0,0,bottom_height/2]) 
    rotate([x_offset_deg,-90,0])

    translate([0, -arm_gap/2,0]) 
    
   linear_extrude(height = bottom_radius+1, center = false, convexity = 10, twist = 0)
    square(arm_gap);
}

difference()
{
    create_arm_ring();
    
    create_arm_gap(0);
    create_arm_gap(120);
    create_arm_gap(240);  
}

    