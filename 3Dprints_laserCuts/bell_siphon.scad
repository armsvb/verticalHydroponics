
faces = 360;


inner_tube_diameter = 10;
inner_tube_height = 70;
inner_tube_cap_height = 10;

bell_tube_diameter = 30;
bell_tube_gap_over_inner_tube = 7;
bell_tube_water_inlet_height = 10;

outer_tube_diameter = 37;
outer_tube_number_of_inlets = 30;
outer_tube_inlet_length = 7;
outer_tube_inlet_width = 2;


threaded_pipe_diameter=12;
threaded_pipe_height=9;
threaded_pipe_nut_height = 5;
threaded_pipe_nut_width = 30;


module innerTube(){
	
	//pipe
	difference(){
		cylinder(h=inner_tube_height, r=inner_tube_diameter, center=false, $fn=faces);
		translate([0,0,-.1]) cylinder(h=inner_tube_height+0.2, r=inner_tube_diameter-2.5, center=false, $fn=faces);
	}

	//pipe cap
	translate([0,0,inner_tube_height]) difference(){
		cylinder(inner_tube_cap_height, r1=inner_tube_diameter, r2=inner_tube_diameter*2, $fn=faces);
		translate([0,0,-0.1]) cylinder(inner_tube_cap_height+0.2, r1=inner_tube_diameter-2.5, r2=(inner_tube_diameter*2)-2.5, $fn=faces);
	}
}



module bellTube(){

	//pipe
	difference(){
		cylinder(h=inner_tube_height+inner_tube_cap_height+bell_tube_gap_over_inner_tube, r=bell_tube_diameter, center=false, $fn=faces);
		translate([0,0,-.1]) cylinder(h=inner_tube_height+inner_tube_cap_height+bell_tube_gap_over_inner_tube+0.2, r=bell_tube_diameter-2.5, center=false, $fn=faces);
		
		//pipe bottom inlets
		for (r = [-60, 0, 60]) rotate([0,0,r]) cube([bell_tube_diameter/1.75, bell_tube_diameter*2.5, bell_tube_water_inlet_height*2], true);
	}

	//pipe cap
	translate([0,0,inner_tube_height+inner_tube_cap_height+bell_tube_gap_over_inner_tube-2.5]) cylinder(h=2.5, r=bell_tube_diameter, center=false, $fn=faces);

}


module outerTube(){
	
	numberOfInletLevels = max(1, floor(inner_tube_height / ((outer_tube_inlet_length*2) + 10)));
	numberOfInletRotations = (outer_tube_number_of_inlets/2);
  	inletAngle = 360/numberOfInletRotations;

	//pipe
	difference(){
		cylinder(h=inner_tube_height+inner_tube_cap_height+bell_tube_gap_over_inner_tube, r=outer_tube_diameter, center=false, $fn=faces);
		translate([0,0,-.1]) cylinder(h=inner_tube_height+inner_tube_cap_height+bell_tube_gap_over_inner_tube+0.2, r=outer_tube_diameter-2.5, center=false, $fn=faces);

		//pipe bottom inlets
		for (r = [-60, 0, 60]) rotate([0,0,r]) cube([outer_tube_diameter/1.75, outer_tube_diameter*2.5, bell_tube_water_inlet_height*2], true);

		//pipe side inlets
		for (l = [1:numberOfInletLevels]) {
  			for (i = [1:numberOfInletRotations]) {
    				rotate([90, 0, i*inletAngle]) 
				translate([0,(l*((outer_tube_inlet_length*2)+10)),0])
				scale([1, outer_tube_inlet_length/outer_tube_inlet_width, 1]) 
				cylinder(outer_tube_diameter*2+0.1, r=outer_tube_inlet_width, center=true, $fn=faces);
			}
  		}

	}
}	







module assemblyBase(){

	//platform
	difference(){
		cylinder(h=5, r=outer_tube_diameter, center=false, $fn=faces);
		translate([0,0,-.1]) cylinder(h=5.2, r=inner_tube_diameter+0.15, center=false, $fn=faces);

		//outer tube attachment points
		for (r = [90, 30, -30]) rotate([0,0,r]) difference(){
			cube([outer_tube_diameter/2.25, (outer_tube_diameter*2), bell_tube_water_inlet_height*2], true);
			cube([outer_tube_diameter/2.25, (outer_tube_diameter*2)-7, bell_tube_water_inlet_height*2], true);
		}
	}

	//threaded fastener
	translate([0,0,(-1*threaded_pipe_height)]) difference(){
		thread(threaded_pipe_diameter, threaded_pipe_height+2, 1.5);
		translate([0,0,-.1]) cylinder(h=(threaded_pipe_height+2.2), r=inner_tube_diameter-2.5, center=false, $fn=faces);
	}

	//threaded nut
	boxWidth = threaded_pipe_nut_width/1.75;
	translate([75,0,(-1*(threaded_pipe_height/2))]) difference(){
  		for (r = [-60, 0, 60]) rotate([0,0,r]) cube([boxWidth, threaded_pipe_nut_width, threaded_pipe_nut_height], true);
		translate([0,0,(-1*(threaded_pipe_nut_height/2))-0.1]) thread(threaded_pipe_diameter, threaded_pipe_nut_height+0.2, 1.5);
	}

}











module thread(outer_diameter_of_thread, thread_length, lead_of_thread){
	// the thread is extruded with a twisted linear extrusion 
	orad = outer_diameter_of_thread;
	p = lead_of_thread;

	// radius' for the spiral
	r = [orad-0/18*p, orad-1/18*p, orad-2/18*p, orad-3/18*p, orad-4/18*p, orad-5/18*p,
     		orad-6/18*p, orad-7/18*p, orad-8/18*p, orad-9/18*p, orad-10/18*p, orad-11/18*p,
     		orad-12/18*p, orad-13/18*p, orad-14/18*p, orad-15/18*p, orad-16/18*p, orad-17/18*p,
     		orad-p];

	// extrude 2d shape with twist
	translate([0,0,thread_length/2])
	linear_extrude(height = thread_length, convexity = 10, twist = -360.0*thread_length/p, center = true)

	// mirrored spiral (2d poly) -> triangular thread when extruded
	polygon([[ r[ 0]*cos(  0), r[ 0]*sin(  0)], [r[ 1]*cos( 10), r[ 1]*sin( 10)],
		 [ r[ 2]*cos( 20), r[ 2]*sin( 20)], [r[ 3]*cos( 30), r[ 3]*sin( 30)],
		 [ r[ 4]*cos( 40), r[ 4]*sin( 40)], [r[ 5]*cos( 50), r[ 5]*sin( 50)],
	     	 [ r[ 6]*cos( 60), r[ 6]*sin( 60)], [r[ 7]*cos( 70), r[ 7]*sin( 70)],
		 [ r[ 8]*cos( 80), r[ 8]*sin( 80)], [r[ 9]*cos( 90), r[ 9]*sin( 90)],
		 [ r[10]*cos(100), r[10]*sin(100)], [r[11]*cos(110), r[11]*sin(110)],
		 [ r[12]*cos(120), r[12]*sin(120)], [r[13]*cos(130), r[13]*sin(130)],
		 [ r[14]*cos(140), r[14]*sin(140)], [r[15]*cos(150), r[15]*sin(150)],
		 [ r[16]*cos(160), r[16]*sin(160)], [r[17]*cos(170), r[17]*sin(170)],
		 [ r[18]*cos(180), r[18]*sin(180)], [r[17]*cos(190), r[17]*sin(190)],
		 [ r[16]*cos(200), r[16]*sin(200)], [r[15]*cos(210), r[15]*sin(210)],
		 [ r[14]*cos(220), r[14]*sin(220)], [r[13]*cos(230), r[13]*sin(230)],
		 [ r[12]*cos(240), r[12]*sin(240)], [r[11]*cos(250), r[11]*sin(250)],
		 [ r[10]*cos(260), r[10]*sin(260)], [r[ 9]*cos(270), r[ 9]*sin(270)],
		 [ r[ 8]*cos(280), r[ 8]*sin(280)], [r[ 7]*cos(290), r[ 7]*sin(290)],
		 [ r[ 6]*cos(300), r[ 6]*sin(300)], [r[ 5]*cos(310), r[ 5]*sin(310)],
		 [ r[ 4]*cos(320), r[ 4]*sin(320)], [r[ 3]*cos(330), r[ 3]*sin(330)],
		 [ r[ 2]*cos(340), r[ 2]*sin(340)], [r[ 1]*cos(350), r[ 1]*sin(350)]
                ]);
}











assemblyBase();
translate([0,0,3]) innerTube();
translate([0,0,6]) bellTube();
outerTube();































