//A simple spawn circle
.float spawncircle_degrees; //How many degrees, default 360
.float spawncircle_scts; //Sectors within each radius
.string spawncircle_spawn;
.float spawncircle_sct_offset;
.float spawncircle_originoffset; //offsetfromorigin;
.float spawncircle_sct_sinx;

.float spawncircle_turndegrees;
.float spawncircle_nosymmetric;

.float spawncircle_spawnaddangle;
.vector spawncircle_forceangles;

.float spawncircle_droptofloor;
.float spawncircle_strict;

.float spawncircle_sctilesspecial;



float spawncircle_populate (float addspawnprefix) {
	local float scts, myforceangles, symsubdg, dgrs, trnadddg, hasspawnedone;
	local float cur_sct;
	local float algocalc;
	local vector save_v_forward;
	local vector save_v_right;
	local vector save_v_up;
	hasspawnedone = 0;
	vector myorigin;
	string myspwnfnctn;
	
	if (self.spawncircle_spawnaddangle) {
		myforceangles = 1;
	}
	
	if (self.spawncircle_forceangles_x || self.spawncircle_forceangles_y || self.spawncircle_forceangles_z) {
		myforceangles = 2;
	}
	
	cur_sct = 0;

	if (self.spawncircle_spawn == "spawncircle") {
		remove(self);
		return 0; //no ginception... atleast not yet.
	} else if (self.spawncircle_spawn == "") {
		remove(self);
		return 0; //
	}
	
	if (addspawnprefix) {
		myspwnfnctn = strcat("spawnfunc_", self.spawncircle_spawn);
	} else {
		myspwnfnctn = self.spawncircle_spawn;
	}
	
	myorigin = self.origin;
	
	
	
	scts = self.spawncircle_scts;
	
	if (self.spawncircle_turndegrees) {
		trnadddg = self.spawncircle_turndegrees;
	} else {
		trnadddg = 0;
	}
	
	
	if (!self.spawncircle_strict)
	{
		if (!scts) scts = 1;
	}
	

	if (self.spawncircle_degrees) {
		dgrs = self.spawncircle_degrees;
	} else {
		dgrs = 360;
	}
	
	
	
	if (self.spawncircle_nosymmetric) {
		symsubdg = 0;
	} else if (self.spawnradial_strict || dgrs)
	{
		symsubdg = (dgrs*0.5);
	}
	
	print("**spawncircle**\n");
	entity myoldspawnself;

	local entity myfirstentity;
	myoldspawnself = self;
	
	
	
	//Start loop
	while (cur_sct < scts) {
		//Inner loop
			myfirstentity = spawn();

			copyentity(myoldspawnself, myfirstentity);
	
			self = myfirstentity;
			
			
			
			makevectors(myoldspawnself.angles);
			////Examples
			//origin offset: v_forward*cos(angle) + v_right*sin(angle)
			//Use radians: sin(degreeangle * (M_PI/180))
			
			
			myorigin = myoldspawnself.origin;
			
			
			//For distance from center
			if (myoldspawnself.spawncircle_sct_sinx) {
				algocalc = myoldspawnself.spawncircle_sct_offset * ( 1 +
				sin((cur_sct/scts)*myoldspawnself.spawncircle_sct_sinx * 2*M_PI));
			} else {
				algocalc = myoldspawnself.spawncircle_sct_offset;
			}
			//For distance from center
			
			
			local float degreeangle, distance;
			if (dgrs == 360) {
				degreeangle = trnadddg + ((cur_sct/scts)*dgrs) - symsubdg;
			} else {
				//Sections
				degreeangle = trnadddg; //If you want a turn offset;
				//Normal section
				degreeangle = degreeangle - symsubdg; //-90
				degreeangle = degreeangle + (symsubdg/scts) + ((dgrs/scts)*cur_sct);
			}
			distance = (algocalc + myoldspawnself.spawncircle_originoffset);
			
			myorigin = myorigin + v_forward*cos(degreeangle * (M_PI/180))*distance
			+ v_right*sin(degreeangle * (M_PI/180))*distance;
			
			self.classname = strzone(myoldspawnself.spawncircle_spawn);
			self.origin = myorigin;
			
			
			//Force angles on spawned entities
			if (myforceangles) {
				if (myforceangles == 2) {
				self.angles = self.spawncircle_forceangles;
				}
				self.angles_y = self.angles_y + myoldspawnself.spawncircle_spawnaddangle;
			}
			//Force angles on spawned entities
			
			
					//////////////////////////////////////////////////////////
					//////Some Special handling if you want it
					//////Made for the SC_Tiles buildings
					if (myoldspawnself.spawncircle_sctilesspecial) {
						
						
						if (self.abdbld_baseheight_sc
						|| self.abdbld_baseheightrand_sc
						|| self.abdbld_baseheightrandmax_sc) {
							//Do nothing
						} else {
							//Move by random amount of 1.5qu: less zfight
							self.abdbld_baseheightrand_sc = 1;
							self.abdbld_baseheightrandmax_sc = 1.5;
						}
						
						//Some jitter to avoid some zfighting
						//(note this could cause some bboxes to be slightly where not wanted though)
						self.origin_x = self.origin_x + ((random() * 1.5) - 0.75);
						self.origin_y = self.origin_y + ((random() * 1.5) - 0.75);
					}
					//////Some Special handling if you want it
					//////////////////////////////////////////////////////////
					
			
			
			//Drop spawned entity to floor
			if(myoldspawnself.spawncircle_droptofloor) {
				droptofloor();
			}
			//Drop spawned entity to floor
			
			
			//Execute the spawn function		
			if(isfunction(myspwnfnctn)) {
				callfunction(myspwnfnctn);
			}
			//Execute the spawn function	
			
					

			
		//End Inner loop
		cur_sct++;
	}
	//End loop
	
	self = myoldspawnself;
	remove(self);
		

	return 1;
}



void spawnfunc_spawncircle(void) {
	spawncircle_populate(1);
}

