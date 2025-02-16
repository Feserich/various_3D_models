

D_out = 32;
D_in = 20;
D_drill=10;

// calc radius and a bit smaller for tollerance
tollerance = 0.2;
r_out = (D_out/2) - tollerance;
r_in = (D_in/2) - tollerance;
r_drill=(D_drill/2) - tollerance;

// calc the hight 
h_out = D_out /4;
h_in = D_in /4;
h_drill = h_out + h_in + 1;


module create_bearing_press() 
{
    cylinder(h=h_out, r=r_out, center=false, $fn = 100);

    translate([0,0,h_out])
    cylinder(h=h_in, r=r_in, center=false, $fn = 100);
}

// drill hole in the middle
difference()
 {
     create_bearing_press();
     
     translate([0,0,-0.5])
     cylinder(h=h_drill, r=r_drill, center=false, $fn = 100);
 }