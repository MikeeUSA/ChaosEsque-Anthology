//Thanks to KrimZon_2, Spoike, and OneManClan for help with the math!

.float spawnsnake_degrees; //How many degrees, default 360
.float spawnsnake_scts; //Sectors within each radius
.float spawnsnake_lvls; //Z levels
.string spawnsnake_spawn;
.float spawnsnake_sct_offset;
.float spawnsnake_originoffset; //offsetfromorigin;
.float spawnsnake_sct_sinx;

.float spawnsnake_turndegrees;
.float spawnsnake_nosymmetric;

.float spawnsnake_lvl_offset;
.float spawnsnake_lvl_addangle;
.vector spawnsnake_lvl_addangles;
.float spawnsnake_lvl_addangles_al;


.float spawnsnake_spawnaddangle;
.vector spawnsnake_forceangles;

.float spawnsnake_evaleachoffset;
.float spawnsnake_droptofloor;
.float spawnsnake_strict;

.float spawnsnake_sctilesspecial;

float spawnsnake_populate (float addspawnprefix) {
	local float scts, lvls, myforceangles, symsubdg, dgrs, trnadddg, hasspawnedone;
	local float cur_sct, cur_lvl;
	local float algocalc;
	local float loffset, loffsetee;
	local vector save_v_forward;
	local vector save_v_right;
	local vector save_v_up;
	loffsetee = 0;
	hasspawnedone = 0;
	vector myorigin;
	string myspwnfnctn;
	
	if (self.spawnsnake_spawnaddangle) {
		myforceangles = 1;
	}
	
	if (self.spawnsnake_forceangles_x || self.spawnsnake_forceangles_y || self.spawnsnake_forceangles_z) {
		myforceangles = 2;
	}
	
	cur_sct = 0;
	cur_lvl = 0;

	if (self.spawnsnake_spawn == "spawnsnake") {
		remove(self);
		return 0; //no ginception... atleast not yet.
	} else if (self.spawnsnake_spawn == "") {
		remove(self);
		return 0; //
	}
	
	if (addspawnprefix) {
		myspwnfnctn = strcat("spawnfunc_", self.spawnsnake_spawn);
	} else {
		myspwnfnctn = self.spawnsnake_spawn;
	}
	
	myorigin = self.origin;
	
	
	
	lvls = self.spawnsnake_lvls;
	scts = self.spawnsnake_scts;
	
	loffset = self.spawnsnake_lvl_offset;

	if (self.spawnsnake_turndegrees) {
		trnadddg = self.spawnsnake_turndegrees;
	} else {
		trnadddg = 0;
	}
	
	
	if (!self.spawnsnake_strict)
	{
		if (!lvls) lvls = 1;
		if (!scts) scts = 1;
		
		if (self.spawnsnake_evaleachoffset) {
			if (!loffset) loffsetee = 1;
		}
	}
	

	if (self.spawnsnake_degrees) {
		dgrs = self.spawnsnake_degrees;
	} else {
		dgrs = 360;
	}
	
	
	
	if (self.spawnsnake_nosymmetric) {
		symsubdg = 0;
	} else if (self.spawnradial_strict || dgrs)
	{
		symsubdg = (dgrs*0.5);
	}
	
	print("**spawnsnake**\n");
	entity myoldspawnself;

	local entity myfirstentity;
	myoldspawnself = self;
	
	
	
	//Start loop
	while (cur_lvl < lvls) {
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
			if (myoldspawnself.spawnsnake_sct_sinx) {
				algocalc = myoldspawnself.spawnsnake_sct_offset * ( 1 +
				sin((cur_sct/scts)*myoldspawnself.spawnsnake_sct_sinx * 2*M_PI));
			} else {
				algocalc = myoldspawnself.spawnsnake_sct_offset;
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
			distance = (algocalc + myoldspawnself.spawnsnake_originoffset);
			
			myorigin = myorigin + v_forward*cos(degreeangle * (M_PI/180))*distance
			+ v_right*sin(degreeangle * (M_PI/180))*distance;
			
			self.classname = strzone(myoldspawnself.spawnsnake_spawn);
			self.origin = myorigin;
			
			
			//Force angles on spawned entities
			if (myforceangles) {
				if (myforceangles == 2) {
				self.angles = self.spawnsnake_forceangles;
				}
				self.angles_y = self.angles_y + myoldspawnself.spawnsnake_spawnaddangle;
			}
			//Force angles on spawned entities
			
			
					//////////////////////////////////////////////////////////
					//////Some Special handling if you want it
					//////Made for the SC_Tiles buildings
					if (myoldspawnself.spawnsnake_sctilesspecial) {
						
						
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
			if(myoldspawnself.spawnsnake_droptofloor) {
				droptofloor();
			}
			//Drop spawned entity to floor
			
			
			//Execute the spawn function		
			if(isfunction(myspwnfnctn)) {
				callfunction(myspwnfnctn);
			}
			//Execute the spawn function	
			
					
			if (!hasspawnedone || myoldspawnself.spawnsnake_evaleachoffset) {
				if (!myoldspawnself.spawnsnake_strict)
				{
					if (!loffset || loffsetee) loffset = (self.absmax_z - self.absmin_z);
				}
				hasspawnedone = 1;
			}
			
		//End Inner loop
		cur_sct++;
		}
		cur_sct = 0; //Reset
		
	cur_lvl++;
	
		//Keep within bounds
		myoldspawnself.angles_x = myoldspawnself.angles_x - 360 * rint(myoldspawnself.angles_x / 360);
		myoldspawnself.angles_y = myoldspawnself.angles_y - 360 * rint(myoldspawnself.angles_y / 360);
		myoldspawnself.angles_z = myoldspawnself.angles_z - 360 * rint(myoldspawnself.angles_z / 360);
		//Keep within bounds
	
	
		//Simple turning of y angle
		if (myoldspawnself.spawnsnake_lvl_addangle) {
			myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnsnake_lvl_addangle;
			//makevectors(self.angles);
		}
		//Simple turning of y angle
		
		
		//The more important part for making snakes
		if (myoldspawnself.spawnsnake_lvl_addangles_x
		|| myoldspawnself.spawnsnake_lvl_addangles_y
		|| myoldspawnself.spawnsnake_lvl_addangles_z) {
			myoldspawnself.angles_x = myoldspawnself.angles_x + myoldspawnself.spawnsnake_lvl_addangles_x;
			myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnsnake_lvl_addangles_y;
			myoldspawnself.angles_z = myoldspawnself.angles_z + myoldspawnself.spawnsnake_lvl_addangles_z;
			
			if (myoldspawnself.spawnsnake_lvl_addangles_al) {
				makevectors(myoldspawnself.spawnsnake_lvl_addangles_x*cur_lvl * '1 0 0'
				+ myoldspawnself.spawnsnake_lvl_addangles_y*cur_lvl * '0 1 0'
				+ myoldspawnself.spawnsnake_lvl_addangles_z*cur_lvl * '0 0 1');
			}
		}
		//The more important part for making snakes
		
		
		if (myoldspawnself.spawnsnake_lvl_addangles_al) {
			//Algorithim lock, for use with addangles
			//Lets you specify while orientating differently
		} else {
			makevectors(self.angles);
		}
		
		myoldspawnself.origin = myoldspawnself.origin + (v_up * loffset);
		setorigin(myoldspawnself, myoldspawnself.origin);
	}
	//End loop
	
	self = myoldspawnself;
	remove(self);
		

	return 1;
}



void spawnfunc_spawnsnake(void) {
	spawnsnake_populate(1);
}

