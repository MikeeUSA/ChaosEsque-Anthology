.float spawnradial_degrees; //How many degrees, default 360
.float spawnradial_rads; //Radius' (()) (how many "layers")
.float spawnradial_scts; //Sectors within each radius
.float spawnradial_lvls; //Z levels
.float spawnradial_lvl_addangle;
.vector spawnradial_lvl_addangles;
.float spawnradial_scts_scale; //Scale scts per radius...
.float spawnradial_originoffset; //offsetfromorigin;
.float spawnradial_originone; //only one origin spawn, then move on;
.float spawnradial_nosymmetric;
.float spawnradial_turndegrees;  //add this many degrees.
.float spawnradial_spawnaddangle;
.vector spawnradial_forceangles;
.string spawnradial_spawn;
.float spawnradial_rad_offset;
.float spawnradial_lvl_offset;
.float spawnradial_add2offset;
.float spawnradial_add2offset_noup;
.float spawnradial_add2offset_norad;
.float spawnradial_strict;
.float spawnradial_evaleachoffset;
.float spawnradial_droptofloor;
.float spawnradial_extend; //Extend past the ends, useful if _degrees is set, can make curved right angles etc
.float spawnradial_extend_offset; //Offset of each item in the extends
.float spawnradial_rad0_spawnflags;
.float spawnradial_rad0_spawnflags_d;
.float spawnradial_rad0_spawnflags_f;

.float spawnradial_rad1_spawnflags;
.float spawnradial_rad1_spawnflags_d; //Disable
.float spawnradial_rad1_spawnflags_f; //Force (even if 0

.float spawnradial_radn_spawnflags;
.float spawnradial_radn_spawnflags_d;
.float spawnradial_radn_spawnflags_f;

.float spawnradial_radev_spawnflags;
.float spawnradial_radev_spawnflags_d;
.float spawnradial_radev_spawnflags_f;

.float spawnradial_radod_spawnflags;
.float spawnradial_radod_spawnflags_d;
.float spawnradial_radod_spawnflags_f;

.float spawnradial_sctilesspecial;

//Iterations
.float spawnradial_iter;
.float spawnradial_iter_and;
.float spawnradial_iter_skipuntil; //Add one only ever X
.float spawnradial_iter_andobeyskip; //obeys the skips
.float spawnradial_iter_andxorskip; //Shows when there is not a skip
.float spawnradial_iter_revitmita; //Reverses the affinity, ita goes first then

.float spawnradial_ita_originoffset; //Adds or subtracts
.float spawnradial_ita_degrees; //Adds or subtracts
.float spawnradial_ita_rads; //Adds or subtracts
.float spawnradial_ita_scts; //Adds or subtracts
.float spawnradial_ita_lvls; //Adds or subtracts
.float spawnradial_ita_lvl_addangle; //Adds or subtracts
.float spawnradial_ita_turndegrees; //Adds or subtracts
.vector spawnradial_ita_lvl_addangles; //Adds or subtracts
.float spawnradial_ita_spawnaddangle; //Adds or subtracts
.float spawnradial_ita_rad_offset; //Adds or subtracts
.float spawnradial_ita_lvl_offset; //Adds or subtracts
.float spawnradial_ita_add2offset; //Adds or subtracts
.float spawnradial_ita_scts_scale; //Adds or subtracts
.float spawnradial_ita_iter_skipuntil; //Adds or subtracts
.float spawnradial_ita_iter_and; //Adds or subtracts
.float spawnradial_ita_iter_andobeysk; //Adds or subtracts
.float spawnradial_ita_iter_revitmita;

.float spawnradial_itm_originoffset; //Multiplies
.float spawnradial_itm_degrees; //Multiplies
.float spawnradial_itm_rads; //Multiplies
.float spawnradial_itm_scts; //Multiplies
.float spawnradial_itm_lvls; //Multiplies
.float spawnradial_itm_lvl_addangle; //Multiplies
.float spawnradial_itm_turndegrees; //Multiplies
.vector spawnradial_itm_lvl_addangles; //Multiplies
.float spawnradial_itm_spawnaddangle; //Multiplies
.float spawnradial_itm_rad_offset; //Multiplies
.float spawnradial_itm_lvl_offset; //Multiplies
.float spawnradial_itm_add2offset; //Multiplies
.float spawnradial_itm_scts_scale; //Multiplies
.float spawnradial_itm_iter_skipuntil; //Multiplies
.float spawnradial_itm_iter_and; //Adds or subtracts
.float spawnradial_itm_iter_andobeysk; //Adds or subtracts
.float spawnradial_itm_iter_revitmita;

//loat spawnradial_radod_spawnflags_f;

.float spawnradial_spawn_delay; //Delayspawn
.float spawnradial_spawn_delayjitter; //Jitter to add
.float spawnradial_spawn_delaymethod; //Decide what method, changes how many entities used etc
.float spawnradial_spawn_delaymthdft;

float autocvar_g_spawnradial_spawn_delaymthdft_default; //Default findtype for method 3






.float spawnradial_spawn_no_solid;
.float spawnradial_spawn_no_water;
.float spawnradial_spawn_no_lava;
.float spawnradial_spawn_no_slime;
.float spawnradial_spawn_no_sky;
.float spawnradial_spawn_no_area; //X by X area to check
.float spawnradial_spawn_no_arear;//Set if you want the right side to be different
.float spawnradial_spawn_no_up;   //go up and do the same
.float spawnradial_spawn_no_down; //go down and do the same
.float spawnradial_spawn_no_brthld; //blockratethreshold
.float spawnradial_spawn_no_zofset; //offset (set to negative to search down (ex for water)
.float spawnradial_spawn_no_trdown; //tracedown
.float spawnradial_spawn_no_nomain; //no maincheck, only roads etc

.float spawnradial_spawn_n2_solid;
.float spawnradial_spawn_n2_water;
.float spawnradial_spawn_n2_lava;
.float spawnradial_spawn_n2_slime;
.float spawnradial_spawn_n2_sky;
.float spawnradial_spawn_n2_area; //X by X area to check
.float spawnradial_spawn_n2_arear;//Set if you want the right side to be different
.float spawnradial_spawn_n2_up;   //go up and do the same
.float spawnradial_spawn_n2_down; //go down and do the same
.float spawnradial_spawn_n2_brthld; //blockratethreshold
.float spawnradial_spawn_n2_zofset; //offset (set to negative to search down (ex for water)
.float spawnradial_spawn_n2_trdown; //tracedown
.float spawnradial_spawn_n2_nomain; //no maincheck, only roads etc

.float spawnradial_spawn_n3_solid;
.float spawnradial_spawn_n3_water;
.float spawnradial_spawn_n3_lava;
.float spawnradial_spawn_n3_slime;
.float spawnradial_spawn_n3_sky;
.float spawnradial_spawn_n3_area; //X by X area to check
.float spawnradial_spawn_n3_arear;//Set if you want the right side to be different
.float spawnradial_spawn_n3_up;   //go up and do the same
.float spawnradial_spawn_n3_down; //go down and do the same
.float spawnradial_spawn_n3_brthld; //blockratethreshold
.float spawnradial_spawn_n3_zofset; //offset (set to negative to search down (ex for water)
.float spawnradial_spawn_n3_trdown; //tracedown
.float spawnradial_spawn_n3_nomain; //no maincheck, only roads etc




.float spawnradial_moveorigin_forward; //Move origin by v_forward etc
.float spawnradial_moveorigin_right;
.float spawnradial_moveorigin_up;
.vector spawnradial_moveorigin; //Move origin by xyz


//I did use a goto here, to deal with complex control flow needed inside the loops
//so that we could have extentions on the end of the sections
void spawnfunc_spawnradial(void);

void spawnradial_ita_apply(void) {
	
	if (self.spawnradial_ita_originoffset) {
		self.spawnradial_originoffset = 
		self.spawnradial_originoffset +
		self.spawnradial_ita_originoffset;
	}

	if (self.spawnradial_ita_degrees) {
		self.spawnradial_degrees =
		self.spawnradial_degrees +
		self.spawnradial_ita_degrees;
	}

	if (self.spawnradial_ita_rads) {
		self.spawnradial_rads =
		self.spawnradial_rads +
		self.spawnradial_ita_rads;
	}

	if (self.spawnradial_ita_scts) {
		self.spawnradial_scts =
		self.spawnradial_scts +
		self.spawnradial_ita_scts;
	}

	if (self.spawnradial_ita_lvls) {
		self.spawnradial_lvls =
		self.spawnradial_lvls +
		self.spawnradial_ita_lvls;
	}

	if (self.spawnradial_ita_lvl_addangle) {
		self.spawnradial_lvl_addangle =
		self.spawnradial_lvl_addangle +
		self.spawnradial_ita_lvl_addangle;
	}

	if (self.spawnradial_ita_turndegrees) {
		self.spawnradial_turndegrees =
		self.spawnradial_turndegrees +
		self.spawnradial_ita_turndegrees;	
	}

	if (self.spawnradial_ita_lvl_addangles_x) {
		self.spawnradial_lvl_addangles_x =
		self.spawnradial_lvl_addangles_x +
		self.spawnradial_ita_lvl_addangles_x;
	}

	if (self.spawnradial_ita_lvl_addangles_y) {
		self.spawnradial_lvl_addangles_y =
		self.spawnradial_lvl_addangles_y +
		self.spawnradial_ita_lvl_addangles_y;
	}

	if (self.spawnradial_ita_lvl_addangles_z) {
		self.spawnradial_lvl_addangles_z =
		self.spawnradial_lvl_addangles_z +
		self.spawnradial_ita_lvl_addangles_z;
	}

	if (self.spawnradial_ita_spawnaddangle) {
		self.spawnradial_spawnaddangle =
		self.spawnradial_spawnaddangle +
		self.spawnradial_ita_spawnaddangle;
	}

	if (self.spawnradial_ita_rad_offset) {
		self.spawnradial_rad_offset =
		self.spawnradial_rad_offset +
		self.spawnradial_ita_rad_offset;
	}

	if (self.spawnradial_ita_lvl_offset) {
		self.spawnradial_lvl_offset =
		self.spawnradial_lvl_offset +
		self.spawnradial_ita_lvl_offset;
	}

	if (self.spawnradial_ita_add2offset) {
		self.spawnradial_add2offset =
		self.spawnradial_add2offset +
		self.spawnradial_ita_add2offset;
	}

	if (self.spawnradial_ita_scts_scale) {
		self.spawnradial_scts_scale =
		self.spawnradial_scts_scale +
		self.spawnradial_ita_scts_scale;
	}

	if (self.spawnradial_ita_iter_skipuntil) {
		self.spawnradial_iter_skipuntil =
		self.spawnradial_iter_skipuntil +
		self.spawnradial_ita_iter_skipuntil;
	}

	if (self.spawnradial_ita_iter_and) {
		self.spawnradial_iter_and =
		self.spawnradial_iter_and +
		self.spawnradial_ita_iter_and;
	}

	if (self.spawnradial_ita_iter_andobeysk) {
		self.spawnradial_iter_andobeyskip =
		self.spawnradial_iter_andobeyskip +
		self.spawnradial_ita_iter_andobeysk;
	}

	if (self.spawnradial_ita_iter_revitmita) {
		//Not really practical unless you want to slowly move up to 1 and then from then on...
		self.spawnradial_iter_revitmita =
		self.spawnradial_iter_revitmita +
		self.spawnradial_ita_iter_revitmita;
	}
}


void spawnradial_itm_apply(void) {
	
	if (self.spawnradial_itm_originoffset) {
		self.spawnradial_originoffset = 
		self.spawnradial_originoffset *
		self.spawnradial_itm_originoffset;
	}

	if (self.spawnradial_itm_degrees) {
		self.spawnradial_degrees =
		self.spawnradial_degrees *
		self.spawnradial_itm_degrees;
	}

	if (self.spawnradial_itm_rads) {
		self.spawnradial_rads =
		self.spawnradial_rads *
		self.spawnradial_itm_rads;
	}

	if (self.spawnradial_itm_scts) {
		self.spawnradial_scts =
		self.spawnradial_scts *
		self.spawnradial_itm_scts;
	}

	if (self.spawnradial_itm_lvls) {
		self.spawnradial_lvls =
		self.spawnradial_lvls *
		self.spawnradial_itm_lvls;
	}

	if (self.spawnradial_itm_lvl_addangle) {
		self.spawnradial_lvl_addangle =
		self.spawnradial_lvl_addangle *
		self.spawnradial_itm_lvl_addangle;
	}

	if (self.spawnradial_itm_turndegrees) {
		self.spawnradial_turndegrees =
		self.spawnradial_turndegrees *
		self.spawnradial_itm_turndegrees;	
	}

	if (self.spawnradial_itm_lvl_addangles_x) {
		self.spawnradial_lvl_addangles_x =
		self.spawnradial_lvl_addangles_x *
		self.spawnradial_itm_lvl_addangles_x;
	}

	if (self.spawnradial_itm_lvl_addangles_y) {
		self.spawnradial_lvl_addangles_y =
		self.spawnradial_lvl_addangles_y *
		self.spawnradial_itm_lvl_addangles_y;
	}

	if (self.spawnradial_itm_lvl_addangles_z) {
		self.spawnradial_lvl_addangles_z =
		self.spawnradial_lvl_addangles_z *
		self.spawnradial_itm_lvl_addangles_z;
	}

	if (self.spawnradial_itm_spawnaddangle) {
		self.spawnradial_spawnaddangle =
		self.spawnradial_spawnaddangle *
		self.spawnradial_itm_spawnaddangle;
	}

	if (self.spawnradial_itm_rad_offset) {
		self.spawnradial_rad_offset =
		self.spawnradial_rad_offset *
		self.spawnradial_itm_rad_offset;
	}

	if (self.spawnradial_itm_lvl_offset) {
		self.spawnradial_lvl_offset =
		self.spawnradial_lvl_offset *
		self.spawnradial_itm_lvl_offset;
	}

	if (self.spawnradial_itm_add2offset) {
		self.spawnradial_add2offset =
		self.spawnradial_add2offset *
		self.spawnradial_itm_add2offset;
	}

	if (self.spawnradial_itm_scts_scale) {
		self.spawnradial_scts_scale =
		self.spawnradial_scts_scale *
		self.spawnradial_itm_scts_scale;
	}

	if (self.spawnradial_itm_iter_skipuntil) {
		self.spawnradial_iter_skipuntil =
		self.spawnradial_iter_skipuntil *
		self.spawnradial_itm_iter_skipuntil;
	}

	if (self.spawnradial_itm_iter_and) {
		self.spawnradial_iter_and =
		self.spawnradial_iter_and *
		self.spawnradial_itm_iter_and;
	}

	if (self.spawnradial_itm_iter_andobeysk) {
		self.spawnradial_iter_andobeyskip =
		self.spawnradial_iter_andobeyskip *
		self.spawnradial_itm_iter_andobeysk;
	}

	if (self.spawnradial_itm_iter_revitmita) {
		//Set to -1 to reverse each time
		self.spawnradial_iter_revitmita =
		self.spawnradial_iter_revitmita *
		self.spawnradial_itm_iter_revitmita;
	}
}


float spawnradial_populate (float addspawnprefix) {
	float hasspawnedone, dgrs, oroffset, symsubdg, trnadddg, myforceangles;
	float doprints;
	hasspawnedone = 0;
	vector myadd2offset;
	myadd2offset_x = 0;
	myadd2offset_y = 0;
	myadd2offset_z = 0;
	local float rads, scts, lvls, sctsscale, maxscts;
	local float roffset, loffset, eoffset;
	local float myroffset;
	local float roffsetee, loffsetee, eoffsetee;
	local float cur_rad, cur_sct, cur_lvl;
	local float cur_extend;
	local float iterskipcounter;
	iterskipcounter = 0;
	cur_rad = 0;
	cur_sct = 0;
	cur_lvl = 0;
	cur_extend = 0;
	roffsetee = loffsetee = eoffsetee = 0;
	vector myorigin;
	//vector myoriginwrk;
	string myspwnfnctn;
	
	if (self.spawnradial_spawnaddangle) {
		myforceangles = 1;
	}
	
	if (self.spawnradial_forceangles_x || self.spawnradial_forceangles_y || self.spawnradial_forceangles_z) {
		myforceangles = 2;
	}

	if (self.spawnradial_spawn == "spawnradial") {
		remove(self);
		return 0; //no ginception... atleast not yet.
	} else if (self.spawnradial_spawn == "") {
		remove(self);
		return 0; //
	}
	
	
	
	
	//If we aren't adding spawnprefix, then we are probably calling this from
	//in the game code (ex for a spell), not on map load, so we want less console spam
	if (addspawnprefix) { doprints = 1; } else { doprints = 0; }
	//Now with that settled, on we go
	
	
	
	float snallremself; //Used at the very end of the loops to flag if we will remove the spawned ent
			    //EX: if it is unused or in a forbidden solid etc, and these settings have
			    //been set to disallow such or to trim unused ents along the way
			    //Where it is used, it is set to 0, then the code deciding if the ent
			    //is to be removed is run, then it is set to 1 if so, the ent is removed
			    //and it is set to 0 again
			    
	//Here is for checking if we are in forbidden solid etc, atleast the setup for it
	//The idea is not to spawn buildings inside mountains etc
	//This doesn't affect the skips nor the iters
	//Just the main things you are spawning 
	//(EX: the roads will still be spawned)
	////////////////////
	////////////////////
	float snocheckremoveent;
	entity snocheckremoveenttoremove;
	float snocheck;
	float sno_solid;
	float sno_water;
	float sno_lava;
	float sno_slime;
	float sno_sky;
	float sno_area; //X by X area to check
	float sno_arear;//Set if you want the right side to be different
	float sno_up;   //go up and do the same
	float sno_down; //go down and do the same
	float sno_brthld; //block rate threshold (don't need to set)
	float sno_zofset; //z offset
	float sno_trdown; //tracedown
	
	snocheckremoveent = 0;
	sno_solid = 0;
	sno_water = 0;
	sno_lava = 0;
	sno_slime = 0;
	sno_sky = 0;
	sno_area = 0;
	sno_up = 0;
	sno_down = 0;
	sno_brthld = 0;
	sno_zofset = 0;
	sno_trdown = 0;
	
	if (self.spawnradial_spawn_no_solid)
		sno_solid = self.spawnradial_spawn_no_solid;
	
	if (self.spawnradial_spawn_no_water)
		sno_water = self.spawnradial_spawn_no_water;
	
	if (self.spawnradial_spawn_no_lava)
		sno_lava = self.spawnradial_spawn_no_lava;
	
	if (self.spawnradial_spawn_no_slime)
		sno_slime = self.spawnradial_spawn_no_slime;
	
	if (self.spawnradial_spawn_no_sky)
		sno_sky = self.spawnradial_spawn_no_sky;
	
	if (self.spawnradial_spawn_no_brthld)
		sno_brthld = self.spawnradial_spawn_no_brthld;
	
	if (self.spawnradial_spawn_no_zofset)
		sno_zofset = self.spawnradial_spawn_no_zofset;
	
	if (self.spawnradial_spawn_no_trdown)
		sno_trdown = self.spawnradial_spawn_no_trdown;
	
	
	if (sno_solid || sno_water || sno_lava || sno_slime || sno_sky) {
		snocheck = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnradial_spawn_no_area)
			sno_area = self.spawnradial_spawn_no_area;
		
		if (self.spawnradial_spawn_no_arear)
			sno_arear = self.spawnradial_spawn_no_arear;
		
		if (self.spawnradial_spawn_no_up)
			sno_up = self.spawnradial_spawn_no_up;
		
		if (self.spawnradial_spawn_no_down)
			sno_down = self.spawnradial_spawn_no_down;
	} else {
		snocheck = 0;
	}
	////////////////////
	//float sn2checkremoveent;
	//entity sn2checkremoveenttoremove;
	float sn2check;
	float sn2_solid;
	float sn2_water;
	float sn2_lava;
	float sn2_slime;
	float sn2_sky;
	float sn2_area; //X by X area to check
	float sn2_arear;//Set if you want the right side to be different
	float sn2_up;   //go up and do the same
	float sn2_down; //go down and do the same
	float sn2_brthld; //block rate threshold (don't need to set)
	float sn2_zofset; //z offset
	float sn2_trdown; //tracedown
	
	//sn2checkremoveent = 0;
	sn2_solid = 0;
	sn2_water = 0;
	sn2_lava = 0;
	sn2_slime = 0;
	sn2_sky = 0;
	sn2_area = 0;
	sn2_up = 0;
	sn2_down = 0;
	sn2_brthld = 0;
	sn2_zofset = 0;
	sn2_trdown = 0;
	
	if (self.spawnradial_spawn_n2_solid)
		sn2_solid = self.spawnradial_spawn_n2_solid;
	
	if (self.spawnradial_spawn_n2_water)
		sn2_water = self.spawnradial_spawn_n2_water;
	
	if (self.spawnradial_spawn_n2_lava)
		sn2_lava = self.spawnradial_spawn_n2_lava;
	
	if (self.spawnradial_spawn_n2_slime)
		sn2_slime = self.spawnradial_spawn_n2_slime;
	
	if (self.spawnradial_spawn_n2_sky)
		sn2_sky = self.spawnradial_spawn_n2_sky;
	
	if (self.spawnradial_spawn_n2_brthld)
		sn2_brthld = self.spawnradial_spawn_n2_brthld;
	
	if (self.spawnradial_spawn_n2_zofset)
		sn2_zofset = self.spawnradial_spawn_n2_zofset;
	
	if (self.spawnradial_spawn_n2_trdown)
		sn2_trdown = self.spawnradial_spawn_n2_trdown;
	
	if (sn2_solid || sn2_water || sn2_lava || sn2_slime || sn2_sky) {
		sn2check = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnradial_spawn_n2_area)
			sn2_area = self.spawnradial_spawn_n2_area;
		
		if (self.spawnradial_spawn_n2_arear)
			sn2_arear = self.spawnradial_spawn_n2_arear;
		
		if (self.spawnradial_spawn_n2_up)
			sn2_up = self.spawnradial_spawn_n2_up;
		
		if (self.spawnradial_spawn_n2_down)
			sn2_down = self.spawnradial_spawn_n2_down;
	} else {
		sn2check = 0;
	}
	////////////////////
	//float sn3checkremoveent;
	//entity sn3checkremoveenttoremove;
	float sn3check;
	float sn3_solid;
	float sn3_water;
	float sn3_lava;
	float sn3_slime;
	float sn3_sky;
	float sn3_area; //X by X area to check
	float sn3_arear;//Set if you want the right side to be different
	float sn3_up;   //go up and do the same
	float sn3_down; //go down and do the same
	float sn3_brthld; //block rate threshold (don't need to set)
	float sn3_zofset; //z offset
	float sn3_trdown; //tracedown
	
	//sn3checkremoveent = 0;
	sn3_solid = 0;
	sn3_water = 0;
	sn3_lava = 0;
	sn3_slime = 0;
	sn3_sky = 0;
	sn3_area = 0;
	sn3_up = 0;
	sn3_down = 0;
	sn3_brthld = 0;
	sn3_zofset = 0;
	sn3_trdown = 0;
	
	if (self.spawnradial_spawn_n3_solid)
		sn3_solid = self.spawnradial_spawn_n3_solid;
	
	if (self.spawnradial_spawn_n3_water)
		sn3_water = self.spawnradial_spawn_n3_water;
	
	if (self.spawnradial_spawn_n3_lava)
		sn3_lava = self.spawnradial_spawn_n3_lava;
	
	if (self.spawnradial_spawn_n3_slime)
		sn3_slime = self.spawnradial_spawn_n3_slime;
	
	if (self.spawnradial_spawn_n3_sky)
		sn3_sky = self.spawnradial_spawn_n3_sky;
	
	if (self.spawnradial_spawn_n3_brthld)
		sn3_brthld = self.spawnradial_spawn_n3_brthld;
	
	if (self.spawnradial_spawn_n3_zofset)
		sn3_zofset = self.spawnradial_spawn_n3_zofset;
	
	if (self.spawnradial_spawn_n3_trdown)
		sn3_trdown = self.spawnradial_spawn_n3_trdown;
	
	if (sn3_solid || sn3_water || sn3_lava || sn3_slime || sn3_sky) {
		sn3check = 1;
		
		//I could just assign these, but I just.. don't trust.
		if (self.spawnradial_spawn_n3_area)
			sn3_area = self.spawnradial_spawn_n3_area;
		
		if (self.spawnradial_spawn_n3_arear)
			sn3_arear = self.spawnradial_spawn_n3_arear;
		
		if (self.spawnradial_spawn_n3_up)
			sn3_up = self.spawnradial_spawn_n3_up;
		
		if (self.spawnradial_spawn_n3_down)
			sn3_down = self.spawnradial_spawn_n3_down;
	} else {
		sn3check = 0;
	}
	////////////////////
	////////////////////		    
	
	
	
	//For setting some minor variables regarding delay search methods
	float mydelayfindtype = 0;
	if (self.spawnradial_spawn_delaymthdft) {
		mydelayfindtype = self.spawnradial_spawn_delaymthdft;
	} else if (autocvar_g_spawnradial_spawn_delaymthdft_default) {
		mydelayfindtype = autocvar_g_spawnradial_spawn_delaymthdft_default;
	}
	
	
	//Move spawnpoint in absolute terms
	if (self.spawnradial_moveorigin_x
	|| self.spawnradial_moveorigin_y
	|| self.spawnradial_moveorigin_z
	) {
		if (self.spawnradial_moveorigin_x) {
			self.origin_x = self.origin_x + self.spawnradial_moveorigin_x;
		}
		
		if (self.spawnradial_moveorigin_y) {
			self.origin_y = self.origin_y + self.spawnradial_moveorigin_y;
		}
		
		if (self.spawnradial_moveorigin_z) {
			self.origin_z = self.origin_z + self.spawnradial_moveorigin_z;
		}
		
		setorigin (self, self.origin);
	}
	
	//To uncenter a radial by relative terms, say if spawned by another spawn_
	if (self.spawnradial_moveorigin_forward
	|| self.spawnradial_moveorigin_right
	|| self.spawnradial_moveorigin_up) {
		local vector myold_v_forward;
		local vector myold_v_right;
		local vector myold_v_up;
		myold_v_forward = v_forward;
		myold_v_right = v_right;
		myold_v_up = v_up;
		
		makevectors(self.angles);
		if (self.spawnradial_moveorigin_forward) {
			self.origin = self.origin + (v_forward * self.spawnradial_moveorigin_forward);
		}
		
		if (self.spawnradial_moveorigin_right) {
			self.origin = self.origin + (v_right * self.spawnradial_moveorigin_right);
		}
		
		if (self.spawnradial_moveorigin_up) {
			self.origin = self.origin + (v_up * self.spawnradial_moveorigin_up);
		}

		setorigin (self, self.origin);
		
		//Reset so we don't conflict with anything else
		v_forward = myold_v_forward;
		v_right = myold_v_right;
		v_up = myold_v_up;
	}
	
	spawnarray_delay_simulated_mintime = 0; //Reset
	spawnarray_delay_simulated_maxtime = 0; //Reset
	
	if (addspawnprefix) {
		myspwnfnctn = strcat("spawnfunc_", self.spawnradial_spawn);
	} else {
		myspwnfnctn = self.spawnradial_spawn;
	}
	myorigin = self.origin;
	
	lvls = self.spawnradial_lvls;
	rads = self.spawnradial_rads;
	scts = self.spawnradial_scts;

	loffset = self.spawnradial_lvl_offset;	
	roffset = self.spawnradial_rad_offset;
	
	eoffset = self.spawnradial_extend_offset;

	oroffset = self.spawnradial_originoffset;


	if (self.spawnradial_degrees) {
		dgrs = self.spawnradial_degrees;
	} else {
		dgrs = 360;
	}
	
	
	if (self.spawnradial_nosymmetric) {
		//
		symsubdg = 0;
	} else if (self.spawnradial_strict || dgrs)
	{
		symsubdg = (dgrs*0.5);
	}
	
	
	if (self.spawnradial_turndegrees) {
		trnadddg = self.spawnradial_turndegrees;
	} else {
		trnadddg = 0;
	}


	if (!self.spawnradial_strict)
	{
		if (!lvls) lvls = 1;
		if (!rads) rads = 1;
		if (!scts) scts = 1;
		
		if (self.spawnradial_evaleachoffset) {
			if (!roffset) roffsetee = 1;
			if (!loffset) loffsetee = 1;
			if (!eoffset) eoffsetee = 1;
		}
		
		if (self.spawnradial_add2offset) {
			if (!self.spawnradial_add2offset_noup)
				myadd2offset_z = self.spawnradial_add2offset;
				
			if (!self.spawnradial_add2offset_norad)
				myadd2offset_y = self.spawnradial_add2offset;
		}

	}
	
	if (doprints) print("**spawnradial**\n");
	entity myoldspawnself;

	local entity myfirstentity;
	myoldspawnself = self;
	

	
	while (cur_lvl < lvls) {
		if (doprints) print(ftos(cur_lvl),"lvl\n");
		
		while (cur_rad < rads) {
		
			if (doprints) print(ftos(cur_rad),"rad\n");
			
			
			if (myoldspawnself.spawnradial_scts_scale && cur_rad) {
				maxscts = scts * cur_rad * myoldspawnself.spawnradial_scts_scale;
			} else {
				maxscts = scts;
			}
			
			while (cur_sct < maxscts) {
				local float myend;
				myend = 0;
:SPWNRDIALSENT			
				if (doprints) print(ftos(cur_sct),"sct\n");
					myfirstentity = spawn();

					copyentity(myoldspawnself, myfirstentity);
	
					self = myfirstentity;
					
					if (myend) {
						//This is for the extentions you can put on the end of a section
						//So you may have, say, an arch type layout, or a gradual curve
						if (myend == 1) {
							//1
							self.angles_y = self.angles_y + trnadddg - symsubdg;
						} else {
							//2
							self.angles_y = self.angles_y + trnadddg + dgrs - symsubdg;
						}
					} else if (dgrs == 360) {
						//Full circle.
						self.angles_y = self.angles_y + trnadddg + ((cur_sct/maxscts)*dgrs) - symsubdg;
					} else {
						//Sections
						self.angles_y = self.angles_y + trnadddg; //If you want a turn offset;
						//Normal section
						self.angles_y = self.angles_y - symsubdg; //-90
						self.angles_y = self.angles_y + (symsubdg/maxscts) + ((dgrs/maxscts)*cur_sct);
					}
					
					makevectors(self.angles);
										
					//
					//Code for all
					if (!cur_rad && !myend) {
						myroffset = 0;
					} else {
						myroffset = roffset;
					}
					myorigin = myoldspawnself.origin
					+ (v_up * ((loffset + myadd2offset_z) * cur_lvl))
					+ (v_forward * (((myroffset + myadd2offset_y) * cur_rad) + oroffset));
					//Above code for all
					//
					
					///////////////////////////////////////
					///////////////////////////////////////
					//This code is for the extend ends only
					if (myend) {
						local float myemultip;
						if (myend == 1) {
							//1
							myemultip = 1;
						} else {
							//2
							myemultip = -1;
						}
						
						print(ftos(cur_rad),"ERad\n");
						print(ftos(cur_sct),"ESct\n");
						
						print (ftos(cur_extend),"MCE\n");
						
						myorigin = myorigin
						+ (v_right * myemultip * (eoffset * (cur_extend + 0.5)));
					
					}
					//Above code is for the extend ends only
					///////////////////////////////////////
					///////////////////////////////////////
					
					
					
					self.classname = strzone(myoldspawnself.spawnradial_spawn);
					self.origin = myorigin;
					
					if (myforceangles) {
						if (myforceangles == 2) {
						self.angles = self.spawnradial_forceangles;
						}
						self.angles_y = self.angles_y + myoldspawnself.spawnradial_spawnaddangle;
					}
					
					
					
					//////////////////////////////////////////////////////////
					//Here we allow custom spawnflags to be set on radians
					//The first (0), second(1), last
					if (cur_rad == 0) {
						if not(myoldspawnself.spawnradial_rad0_spawnflags_d) {
							if (myoldspawnself.spawnradial_rad0_spawnflags
							|| myoldspawnself.spawnradial_rad0_spawnflags_f)
							{
								self.spawnflags = myoldspawnself.spawnradial_rad0_spawnflags;
							}
						}
					} else if (cur_rad == 1) {
						if not(myoldspawnself.spawnradial_rad1_spawnflags_d) {
							if (myoldspawnself.spawnradial_rad1_spawnflags
							|| myoldspawnself.spawnradial_rad1_spawnflags_f)
							{
								self.spawnflags = myoldspawnself.spawnradial_rad1_spawnflags;
							}
						}
					} else if (cur_rad == (rads-1)) {
						if not(myoldspawnself.spawnradial_radn_spawnflags_d) {
							if (myoldspawnself.spawnradial_radn_spawnflags
							|| myoldspawnself.spawnradial_radn_spawnflags_f)
							{
								self.spawnflags = myoldspawnself.spawnradial_radn_spawnflags;
							}
						}
					} else {
						if (mod(cur_rad, 2)) {
							//print ("ODD\n");
							if not(myoldspawnself.spawnradial_radod_spawnflags_d) {
								if (myoldspawnself.spawnradial_radod_spawnflags
								|| myoldspawnself.spawnradial_radod_spawnflags_f)
								{
									self.spawnflags = myoldspawnself.spawnradial_radod_spawnflags;
								}
							}
						} else {
							//print ("EVEN\n");
							if not(myoldspawnself.spawnradial_radev_spawnflags_d) {
								if (myoldspawnself.spawnradial_radev_spawnflags
								|| myoldspawnself.spawnradial_radev_spawnflags_f)
								{
									self.spawnflags = myoldspawnself.spawnradial_radev_spawnflags;
								}
							}
						}
					}
					//Here we allow custom spawnflags to be set on radians
					//////////////////////////////////////////////////////////
					
					
					//////////////////////////////////////////////////////////
					//////Some Special handling if you want it
					//////Made for the SC_Tiles buildings
					if (myoldspawnself.spawnradial_sctilesspecial) {
						//For some reason this first square of the extends on the
						//right side of the inner arch/horseshoe always loses in boxesoverlapcheck
						if (myend) {
							//if (cur_rad <= 5) {
							if (!cur_sct) {
							if (!cur_extend) {
							if (self.spawnflags & 4) {
								self.spawnflags &~= 4; //No buildingboxesoverlapcheck
							}
							}
							}
							//}
						}
						
						if (self.abdbld_baseheight_sc
						|| self.abdbld_baseheightrand_sc
						|| self.abdbld_baseheightrandmax_sc) {
							//Do nothing
						} else {
							//Move by random amount of 1.5qu: less zfight
							self.abdbld_baseheightrand_sc = 1;
							self.abdbld_baseheightrandmax_sc = 1.5;
							
							//Some jitter to avoid some zfighting
							//(note this could cause some bboxes to be slightly where not wanted though)
							self.origin_x = self.origin_x + ((random() * 1.5) - 0.75);
							self.origin_y = self.origin_y + ((random() * 1.5) - 0.75);
						}
					}
					//////Some Special handling if you want it
					//////////////////////////////////////////////////////////
					
					if(myoldspawnself.spawnradial_droptofloor) {
						droptofloor();
					}
					
					if(self.spawnradial_iter >= 1) {
					  iterskipcounter++;
					  if ((self.spawnradial_iter_skipuntil > 0) && iterskipcounter < self.spawnradial_iter_skipuntil) {
					  	//Do nothing
						if(self.spawnradial_iter_and) {
							if (self.spawnradial_iter_andobeyskip) {
								//Do nothing
							} else if(isfunction(myspwnfnctn)) {
								if (myoldspawnself.spawnradial_spawn_delay || myoldspawnself.spawnradial_spawn_delayjitter) {
									spawnarraydelay(myoldspawnself.spawnradial_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnradial_spawn_delay, myoldspawnself.spawnradial_spawn_delayjitter);
								} else {
									callfunction(myspwnfnctn);
								}
							}
						}
					  } else {
					  	if(self.spawnradial_iter_skipuntil) {
							iterskipcounter = 0;
						}
						
						local entity myiteroldself;
						local entity myiterandentity;
						print(ftos(self.spawnradial_iter)," doing iter\n");
						self.spawnradial_iter = self.spawnradial_iter - 1;
						
						if((self.spawnradial_iter_and) &&
						(!(self.spawnradial_iter_skipuntil && self.spawnradial_iter_andxorskip))
						) {
							myiteroldself = self;
							myiterandentity = spawn();
							copyentity(self, myiterandentity);
							myiterandentity.spawnradial_iter = 0;
						}
	
						//ita apply
						if (self.spawnradial_iter_revitmita >= 1) {
							spawnradial_ita_apply(); //Reversed affinity
							spawnradial_itm_apply();
						} else {
						spawnradial_itm_apply(); //Multipliers are first
						spawnradial_ita_apply(); //Then additions
						}
						
						spawnfunc_spawnradial();
						
						if((self.spawnradial_iter_and && myiterandentity && myiteroldself) &&
						(!(self.spawnradial_iter_skipuntil && self.spawnradial_iter_andxorskip))
						) {
							self = myiterandentity;
							
							if(isfunction(myspwnfnctn)) {
								if (myoldspawnself.spawnradial_spawn_delay || myoldspawnself.spawnradial_spawn_delayjitter) {
									spawnarraydelay(myoldspawnself.spawnradial_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnradial_spawn_delay, myoldspawnself.spawnradial_spawn_delayjitter);
								} else {
									callfunction(myspwnfnctn);
								}
							}
							
							self = myiteroldself;
						}
					  }
					} else {
						local float snocheck1allows;
						local float snocheck2allows;
						local float snocheck3allows;
						if (!snocheck || 
							spawnarrayspawnno_allowspawn(
							self,
							sno_brthld,
							sno_zofset,
							sno_trdown,
							sno_area,
							sno_arear, 
							sno_up,
							sno_down,
							sno_solid, 
							sno_water, 
							sno_lava,
							sno_slime,
							sno_sky, doprints))
						{
							snocheck1allows = 1;
						} else {
							snocheck1allows = 0;
						}
						
						
						if (!sn2check || 
							spawnarrayspawnno_allowspawn(
							self,
							sn2_brthld,
							sn2_zofset,
							sn2_trdown,
							sn2_area,
							sn2_arear, 
							sn2_up,
							sn2_down,
							sn2_solid, 
							sn2_water, 
							sn2_lava,
							sn2_slime,
							sn2_sky, doprints))
							{
							snocheck2allows = 1;
						} else {
							snocheck2allows = 0;
						}
						
						
						if (!sn3check || 
							spawnarrayspawnno_allowspawn(
							self,
							sn3_brthld,
							sn3_zofset,
							sn3_trdown,
							sn3_area,
							sn3_arear, 
							sn3_up,
							sn3_down,
							sn3_solid, 
							sn3_water, 
							sn3_lava,
							sn3_slime,
							sn3_sky, doprints))
							{
							snocheck3allows = 1;
						} else {
							snocheck3allows = 0;
						}
						
					
						if(isfunction(myspwnfnctn)) {
							if ((snocheck1allows || myoldspawnself.spawnradial_spawn_no_nomain)
							&& (snocheck3allows || myoldspawnself.spawnradial_spawn_n3_nomain)
							&& (snocheck2allows || myoldspawnself.spawnradial_spawn_n2_nomain)) {
								if (myoldspawnself.spawnradial_spawn_delay || myoldspawnself.spawnradial_spawn_delayjitter) {
									spawnarraydelay(myoldspawnself.spawnradial_spawn_delaymethod, self, myspwnfnctn, myoldspawnself.spawnradial_spawn_delay, myoldspawnself.spawnradial_spawn_delayjitter);
								} else {
									callfunction(myspwnfnctn);
								}
							} else {
								snocheckremoveent = 1;
								snocheckremoveenttoremove = self;
							}
						}
					}
					
					if (myoldspawnself.spawnradial_originone && !hasspawnedone) {
						cur_sct = maxscts + 1;
					}
					
					if (!hasspawnedone || myoldspawnself.spawnradial_evaleachoffset) {
						if (!myoldspawnself.spawnradial_strict)
						{
					
						if (doprints) print(vtos(self.absmin),"\n");
						if (doprints) print(vtos(self.absmax),"\n");
						if (!roffset || roffsetee) roffset = (self.absmax_y - self.absmin_y);
						if (!loffset || loffsetee) loffset = (self.absmax_z - self.absmin_z);
						if (!eoffset || eoffsetee) eoffset = roffset;
						}
						hasspawnedone = 1;
					}

				if (doprints) print(self.classname, " My classname\n");
				
				/////////////////////////////////////
				/////////////////////////////////////
				/////////Remove unused ent///////////
				snallremself = 0; //Do we remove?
				
				if (snocheckremoveent) {
					if (snocheckremoveenttoremove == self) {
						if (self != world) {
							if (doprints) print("setting to removing snochecked ent", etos(self), "\n");
							
							snallremself = 1;
							snocheckremoveenttoremove = world;
						}
					}
					snocheckremoveent = 0;
				}
				
				if (snallremself) {
					if (doprints) print("removing ent", etos(self), "\n");
					remove(self);
				}
				
				snallremself = 0;
				/////////Remove unused ent///////////
				/////////////////////////////////////
				/////////////////////////////////////
				
				
				//Stay in below while loop if need be
				if (myend) {
					goto EXTRDIALSENT;
				}
				
				//If were are at the section ends
				//And extend is set
				//We extend the array outward as instructed
				//Right now myend is not set
				//Once we start the loop we set it
				if (myoldspawnself.spawnradial_extend >= 1) {
				  if (!cur_sct || cur_sct == (maxscts - 1)) {
					//////
					if (!cur_sct) { myend = 1; }
					
					if (cur_sct == (maxscts - 1)) { myend = 2; }
					
					while (cur_extend < myoldspawnself.spawnradial_extend) {
						goto SPWNRDIALSENT;
:EXTRDIALSENT
						print("**", ftos(cur_extend),"_DO\n\n");
						cur_extend++;
					}
					cur_extend = 0; //Reset
					//////
				  }
				}
				
			cur_sct++;
			}
			cur_sct = 0; //Reset
			iterskipcounter = 0; //Iters only operate on the sct scale
		
		cur_rad++;
		}
		cur_rad = 0; //Reset
		
		
		
		if (myoldspawnself.spawnradial_lvl_addangle) {
			myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnradial_lvl_addangle;
		}
	
		if (myoldspawnself.spawnradial_lvl_addangles_x
		|| myoldspawnself.spawnradial_lvl_addangles_y
		|| myoldspawnself.spawnradial_lvl_addangles_z) {
			myoldspawnself.angles_x = myoldspawnself.angles_x + myoldspawnself.spawnradial_lvl_addangles_x;
			myoldspawnself.angles_y = myoldspawnself.angles_y + myoldspawnself.spawnradial_lvl_addangles_y;
			myoldspawnself.angles_z = myoldspawnself.angles_z + myoldspawnself.spawnradial_lvl_addangles_z;
		}
		
		
	cur_lvl++;
	}

	self = myoldspawnself;
	remove(self);
	
	//Here, once we are done, we simulate the spawndelays 
	//To create a varied spawn field, if called for
	if (spawnarray_delay_simulated_maxtime) {
		spawnarraydelaymethod3_do(0.1, mydelayfindtype); //The delayfindtype is only evaluated for method3
	}
	
	return 1;
}


void spawnfunc_spawnradial (void) {
	spawnradial_populate(1);
}
