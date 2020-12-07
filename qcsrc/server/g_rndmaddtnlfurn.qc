////////////////////////////////////////////////////////////////////////////////////////////////
//rndmaddtnlfurn, similar to above.
float rndmaddtnlfurnsuccess;
float rndmaddtnlfurnfail;
float autocvar_rndmaddtnlfurn_barrel_wood2_amnt;
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt;
float autocvar_rndmaddtnlfurn_chest_wood_amnt;
float autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt;
float autocvar_rndmaddtnlfurn_chestlarge_wood_amnt;
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_amnt;

float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_trychestsiffail;
float autocvar_mapforcerndmaddtnlfurn_chest_wood_trybarreliffail;
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_trybarreliffail;

float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_groups;

float autocvar_mapforcerndmaddtnlfurn_za_minz_override;
float autocvar_mapforcerndmaddtnlfurn_searchfor_override; //special

float autocvar_mapforcerndmaddtnlfurn_minx_disable;
float autocvar_mapforcerndmaddtnlfurn_miny_disable;
float autocvar_mapforcerndmaddtnlfurn_maxx_disable;
float autocvar_mapforcerndmaddtnlfurn_maxy_disable;

float autocvar_mapforcerndmaddtnlfurn_minx;
float autocvar_mapforcerndmaddtnlfurn_miny;
float autocvar_mapforcerndmaddtnlfurn_maxx;
float autocvar_mapforcerndmaddtnlfurn_maxy;

//float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_za_minz_override;
//float autocvar_mapforcerndmaddtnlfurn_chest_wood_za_minz_override;
//float autocvar_mapforcerndmaddtnlfurn_chestlarge_za_minz_override;

float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st0; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture0; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st1; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture1; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st2; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture2; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st3; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture3; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st4; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture4; //texture name
float autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st5; //search texture
string autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture5; //texture name

float autocvar_mapforcerndmaddtnlfurn_chest_wood_st; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st0; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture0; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st1; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture1; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st2; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture2; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st3; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture3; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st4; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture4; //texture name
float autocvar_mapforcerndmaddtnlfurn_chest_wood_st5; //search texture
string autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture5; //texture name

float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st0; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture0; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st1; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture1; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st2; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture2; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st3; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture3; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st4; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture4; //texture name
float autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st5; //search texture
string autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture5; //texture name

float rndmaddtnlfurn_evalspot(float myitem, string mytexturename)
{
	float myreturnvalue;
	myreturnvalue = 0;
	if (myitem == 1 || myitem == 3 || myitem == 5) {
		myreturnvalue = 1;
	} else if (myitem == 2) {
		if (!autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st
		&& !autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st0
		&& !autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st1) {
			print("here\n");
			myreturnvalue = 1;
		} else {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st0) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture0, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st1) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture1, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st2) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture2, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st3) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture3, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st4) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture4, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_st5) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_barrel_wood2_stexture5, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
		}
	} else if (myitem == 4) {
		if (!autocvar_mapforcerndmaddtnlfurn_chest_wood_st
		&& !autocvar_mapforcerndmaddtnlfurn_chest_wood_st0
		&& !autocvar_mapforcerndmaddtnlfurn_chest_wood_st1) {
			myreturnvalue = 1;
		} else {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st0) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture0, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st1) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture1, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st2) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture2, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st3) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture3, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st4) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture4, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chest_wood_st5) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chest_wood_stexture5, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
		}
	} else if (myitem == 6) {
		if (!autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st
		&& !autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st0
		&& !autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st1) {
			myreturnvalue = 1;
		} else {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st0) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture0, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st1) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture1, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st2) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture2, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st3) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture3, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st4) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture4, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
			if (!myreturnvalue) {
			if (autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_st5) {
				if ( strstrofs(mytexturename, autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_stexture5, 0) != -1 )
				{
					myreturnvalue = 1;
				}
			}
			}
			
		}
	}
	
	return myreturnvalue;
}

void rndmaddtnlfurn_alignitem()
{
		local float mywinnera, mdna;
		local float mywinnerb, mdnb;
		local float mywinner;
		local vector tpn0, tpn1, tpn2, tpn3;
		local vector vrg0, vrg1, vrg2, vrg3;
		local float  mdn0, mdn1, mdn2, mdn3;
		mdn0 = mdn1 = mdn2 = mdn3 = 99999;
		mdna = mdnb = 99999;
		
		mywinnerb = -1;
		mywinnera = -1;
		mywinner = -1;
		
		
		traceline(self.origin + '0 0 70', self.origin + '128 0 32', MOVE_WORLDONLY, self);
		vrg0 = trace_endpos;
		tpn0 = trace_plane_normal;
		//print("  tracefraction0:", ftos(trace_fraction),"\n");
		
		if (trace_dphitcontents & DPCONTENTS_SOLID && trace_fraction && trace_fraction < 1)
			mdn0 = vlen(self.origin - vrg0);
		
		traceline(self.origin + '0 0 70', self.origin + '-128 0 32', MOVE_WORLDONLY, self);
		vrg1 = trace_endpos;
		tpn1 = trace_plane_normal;
		//print("  tracefraction1:", ftos(trace_fraction),"\n");
		
		if (trace_dphitcontents & DPCONTENTS_SOLID && trace_fraction && trace_fraction < 1)
			mdn1 = vlen(self.origin - vrg1);
		
		traceline(self.origin + '0 0 70', self.origin + '0 128 32', MOVE_WORLDONLY, self);
		vrg2 = trace_endpos;
		tpn2 = trace_plane_normal;
		//print("  tracefraction2:", ftos(trace_fraction),"\n");
		
		if (trace_dphitcontents & DPCONTENTS_SOLID && trace_fraction && trace_fraction < 1)
			mdn2 = vlen(self.origin - vrg2);
		
		traceline(self.origin + '0 0 70', self.origin + '0 -128 32', MOVE_WORLDONLY, self);
		vrg3 = trace_endpos;
		tpn3 = trace_plane_normal;
		//print("  tracefraction3:", ftos(trace_fraction),"\n");
			
		if (trace_dphitcontents & DPCONTENTS_SOLID && trace_fraction && trace_fraction < 1)
			mdn3 = vlen(self.origin - vrg3);
			
		if (!mdn0 && !mdn1 && !mdn2 && !mdn3) {
			//Do no more
		} else {
			//We want the shortest distance
			if (mdn0 < mdn1) {
				mywinnera = 0;
				mdna = mdn0;
			} else if (mdn0 > mdn1) {
				mywinnera = 1;
				mdna = mdn1;
			}
			
			if (mdn2 < mdn3) {
				mywinnerb = 2;
				mdnb = mdn2;
			} else if (mdn2 > mdn3) {
				mywinnerb = 3;
				mdnb = mdn3;
			}
			
			if (mywinnera != -1 && mywinnerb != -1) {
				if (mdna < mdnb) {
					mywinner = mywinnera;
				} else {
					mywinner = mywinnerb;
				}
			} else if (mywinnera != -1) {
				mywinner = mywinnera;
			} else if (mywinnerb != -1) {
				mywinner = mywinnerb;
			}
			
			if (mywinner == -1) {
				//Do nothing
			} else {
				if (mywinner == 0) {
					self.angles = vectoangles(-tpn0);
				} else if (mywinner == 1) {
					self.angles = vectoangles(-tpn1);
				} else if (mywinner == 2) {
					self.angles = vectoangles(-tpn2);
				} else if (mywinner == 3) {
					self.angles = vectoangles(-tpn3);
				}
				
				//print("\n\n\n****ANGLES****\n\n\n");
				//print(vtos(self.angles),"\n");
				//print("\n\n\n****SELGNA****\n\n\n");
			}
		}
}

float anglemods(float v);
float rndmaddtnlfurn_spawnitem(float myitem)
{
	float myreturn;
	self.angles_x = 0;
	self.angles_y = bound(-180, floor((random()*360)-180) ,180);
	self.angles_z = 0;
		
	self.angles_y = anglemods(self.angles_y);
		
	self.absolute = 1; //Used to not do itemreplace on items (weaps) only
			
	if(myitem == 1 || myitem == 2) {
		spawnfunc_furniture_classic_BARREL_WOOD2();
		return myitem;
	} else if(myitem == 3 || myitem == 4) {
		rndmaddtnlfurn_alignitem();
		spawnfunc_furniture_classic_CHEST_WOOD();
		return myitem;
	} else if(myitem == 5 || myitem == 6) {
		rndmaddtnlfurn_alignitem();
		
		spawnfunc_furniture_classic_CHESTLARGE_WOOD();
		return myitem;
	} else {
		return 0;
	}
	
	return 0;
}

			
float rndmaddtnlfurn_chooseitem()
{
	float wrandvar;
	float randvar;
	
				
			randvar = random() *
			(autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_rndmaddtnlfurn_chest_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
			+ autocvar_rndmaddtnlfurn_chestlarge_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_amnt
			);
			
			if (randvar < autocvar_rndmaddtnlfurn_barrel_wood2_amnt) {
				return 1;
			} else if (randvar < (autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			)) {
				return 2;
			} else if (randvar < (autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_rndmaddtnlfurn_chest_wood_amnt
			)) {
				return 3;
			} else if (randvar < (autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_rndmaddtnlfurn_chest_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
			)) {
				return 4;
			} else if (randvar < (autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_rndmaddtnlfurn_chest_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
			+ autocvar_rndmaddtnlfurn_chestlarge_wood_amnt
			)) {
				return 5;
			} else if (randvar < (autocvar_rndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt
			+ autocvar_rndmaddtnlfurn_chest_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
			+ autocvar_rndmaddtnlfurn_chestlarge_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_amnt
			)) {
				return 6;
			} else {
				//Shouldn't get here usually
				return 0;
			}
}


float rndmaddtnlfurn_evalspotandspawn(float myitem, string mytexturename) {
	float mysuccessitem;
	mysuccessitem = 0;
		
	if (rndmaddtnlfurn_evalspot(myitem, mytexturename)) {
		mysuccessitem = rndmaddtnlfurn_spawnitem(myitem);
	} else if ((myitem == 1 || myitem == 2) && autocvar_mapforcerndmaddtnlfurn_barrel_wood2_trychestsiffail > random()) {
		local float randvar;
		randvar = random() *
		(autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
		+ autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_amnt);
		
		if (randvar < autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt) {
			if (rndmaddtnlfurn_evalspot(4, mytexturename)) {
				print("Spawning Chest Instead\n");
				mysuccessitem = rndmaddtnlfurn_spawnitem(4);
			}
		} else if (randvar < (autocvar_mapforcerndmaddtnlfurn_chest_wood_amnt
			+ autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_amnt)) {
			
			if (rndmaddtnlfurn_evalspot(6, mytexturename)) {
				print("Spawning LargeChest Instead\n");
				mysuccessitem = rndmaddtnlfurn_spawnitem(6);
			}
		}
	} else if ((myitem == 3 || myitem == 4) && autocvar_mapforcerndmaddtnlfurn_chest_wood_trybarreliffail > random()) {
		if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt) {
			if (rndmaddtnlfurn_evalspot(2, mytexturename)) {
				print("Spawning Barrel Instead of Chest\n");
				mysuccessitem = rndmaddtnlfurn_spawnitem(2);
			}
		}
	} else if ((myitem == 5 || myitem == 6) && autocvar_mapforcerndmaddtnlfurn_chestlarge_wood_trybarreliffail > random()) {
		if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_amnt) {
			if (rndmaddtnlfurn_evalspot(2, mytexturename)) {
				print("Spawning Barrel Instead of Large Chest\n");
				mysuccessitem = rndmaddtnlfurn_spawnitem(2);
			}
		}
	}
	return mysuccessitem;
}

void rndmaddtnlfurn_groups (vector myorigin, float myitem)
{
	local entity myoldererself;
	local entity ene;
	
	if (pointcontents(myorigin + '0 0 1') == CONTENT_SOLID)
		return;

	
	myoldererself = self;
	
	ene = spawn();
	ene.origin = myorigin;
	
	self = ene;
			
		traceline(ene.origin + '0 0 1', ene.origin - '0 0 64', MOVE_WORLDONLY, ene);
		ene.origin = trace_endpos;
		ene.multitool_forcesolidtype = SOLID_SLIDEBOX;
		if (trace_dphitcontents & DPCONTENTS_SOLID) {
			if (rndmaddtnlfurn_evalspot(myitem, trace_dphittexturename)) {
				if (rndmaddtnlfurn_spawnitem(myitem)) {
					print("Spawning Group Item\n");
				} else {
					print("Failed spawning Group Item\n");
					remove(ene);
				}
			} else {
				remove(ene);
			}
		} else {
			print("Not spawning Group Item: non solid ground\n");
			remove(ene);
		}
			
	self = myoldererself;
}

void rndmaddtnlfurn_maybegroups(entity e, float myitem)
{
	if (myitem == 1 || myitem == 2) {
	if (autocvar_mapforcerndmaddtnlfurn_barrel_wood2_groups) {
	if (random() < autocvar_mapforcerndmaddtnlfurn_barrel_wood2_groups) {
			if (random() > 0.50) rndmaddtnlfurn_groups(e.origin+'64 0 0', myitem);
			if (random() > 0.50) rndmaddtnlfurn_groups(e.origin+'-64 0 0', myitem);
			if (random() > 0.50) rndmaddtnlfurn_groups(e.origin+'0 64 0', myitem);
			if (random() > 0.50) rndmaddtnlfurn_groups(e.origin+'0 -64 0', myitem);
			
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'64 64 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'-64 64 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'64 -64 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'-64 -64 0', myitem);
			
			if (random() > 0.30) {
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'-128 0 0', myitem);
				if (random() > 0.75) rndmaddtnlfurn_groups(e.origin+'128 0 0', myitem);
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'0 -128 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'0 128 0', myitem);
			}
			
			if (random() > 0.75) {
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'128 64 0', myitem);
				if (random() > 0.75) rndmaddtnlfurn_groups(e.origin+'128 -64 0', myitem);
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'-128 64 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'-128 64 0', myitem);
				
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'64 128 0', myitem);
				if (random() > 0.75) rndmaddtnlfurn_groups(e.origin+'64 -128 0', myitem);
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'-64 128 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'-64 -128 0', myitem);
				
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'128 128 0', myitem);
				if (random() > 0.75) rndmaddtnlfurn_groups(e.origin+'128 -128 0', myitem);
				if (random() > 0.90) rndmaddtnlfurn_groups(e.origin+'-128 128 0', myitem);
				if (random() > 0.80) rndmaddtnlfurn_groups(e.origin+'-128 -128 0', myitem);
			}
	}
	}
	}
}


void rndmaddtnlfurn_loop(vector mymins, vector mymaxs, float mysearchfor)
{
	local float mywpn;
	local float myitem;
	local float mysuccessitem;
	local float mygroundnotsolid;
	local string mytexturename;
	mygroundnotsolid = 0;
	myitem = 0;
	mysuccessitem = 0;
	entity e;
	entity myolderself;
	e = spawn();
	e.mins = '-32 -32 0';
	e.maxs = '32 32 64';
	//mysearchfor = 3;
	//mysearchfor = 4;
	//e.mins = PL_MIN;
	//e.maxs = PL_MAX;
	//2qu off ground max:
	//if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 2, 1))
	if (mysearchfor != -1) {
		//Used with ZA limits (map specified etc)
		if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NODRAW, 100, 512, 1, mymins, mymaxs, mysearchfor))
		{
			myolderself = self;
			self = e;
			
				traceline(e.origin + '0 0 1', e.origin - '0 0 10000', MOVE_WORLDONLY, e);
			
			if (trace_dphitcontents & DPCONTENTS_SOLID) {
				mytexturename = trace_dphittexturename;
				print(trace_dphittexturename,":TNAME\n");
				e.origin = trace_endpos;
				e.multitool_forcesolidtype = SOLID_SLIDEBOX;
				
				myitem = rndmaddtnlfurn_chooseitem();
				
				mysuccessitem = rndmaddtnlfurn_evalspotandspawn(myitem, mytexturename);
				
				rndmaddtnlfurn_maybegroups(e, mysuccessitem);
			} else {
				mygroundnotsolid = 1;
			}
				
			
			self = myolderself;
			if (mygroundnotsolid) {
				print("^7FAIL: Nonsolid ground. Using Za limits\n");
				remove(e);
				rndmaddtnlfurnfail++;
			} else if (!myitem) {
				print("^5FAIL: No Item: Failed to spawn random additional furn. Using Za limits\n");
				remove(e);
				rndmaddtnlfurnfail++;
			} else if (!mysuccessitem) {
				print("^4FAIL: No Success Item: Failed to spawn random additional furn. Using Za limits\n");
				remove(e);
				rndmaddtnlfurnfail++;
			} else {
				if (autocvar_g_rndmaddtnlfurn) {
					print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional furn. Using Za limits\n");
				} else {
					print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional furn. Using Za limits\n");
				}
				rndmaddtnlfurnsuccess++;
			}
		} else {
			print("^6FAIL: no location for random additional furn found. Using Za limits\n");
			remove(e);
			rndmaddtnlfurnfail++;
		}
	} else {
		//Normal
		if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY | Q3SURFACEFLAG_NODRAW, 10, 64, 1, mymins, mymaxs))
		{
			myolderself = self;
			self = e;
			
				traceline(e.origin + '0 0 1', e.origin - '0 0 10000', MOVE_WORLDONLY, e);
				mytexturename = trace_dphittexturename;
				print(trace_dphittexturename,":TNAME\n");
				e.origin = trace_endpos;
				myitem = rndmaddtnlfurn_chooseitem();
				
				mysuccessitem = rndmaddtnlfurn_evalspotandspawn(myitem, mytexturename);
			
			self = myolderself;
			if (!myitem || !mysuccessitem) {
				print("^4FAIL: Failed to spawn random additional furn.\n");
				remove(e);
				rndmaddtnlfurnfail++;
			} else {
				if (autocvar_g_rndmaddtnlfurn) {
					print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional furn\n");
				} else {
					print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional furn\n");
				}
				rndmaddtnlfurnsuccess++;
			}
		} else {
			print("^6FAIL: no location for random additional furn found\n");
			remove(e);
			rndmaddtnlfurnfail++;
		}
	}
}

void rndmaddtnlfurn_do (void)
{
	float i;
	local float myreturn;
	local float mysearchfor;
	local float myhavesetalimit;
	local vector mymins;
	local vector mymaxs;
	
	if (autocvar_g_rndmaddtnlfurn) {
		//Overrides
		i = autocvar_g_rndmaddtnlfurn;
	} else {
		i = autocvar_g_suggested_rndmaddtnlfurn;
	}
	
	if (autocvar_g_mapforce_rndmaddtnlfurn) {
		i = i + autocvar_g_mapforce_rndmaddtnlfurn;
	}
	
	if (i > 10000) {
		print("^4RandomAdditionalItems set too high, setting to 10000\n");
		i = 10000; //Don't want to use too many ents.
	}
	
	if (autocvar_g_rndmaddtnlfurn_ignore_za_limits) {
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
	} else if ((!autocvar_g_za_usezlimits) || (!autocvar_g_za_maxz &&
	!autocvar_g_za_minz &&
	!autocvar_g_suggested_za_maxz &&
	!autocvar_g_suggested_za_minz))
	{
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
	} else {
		myhavesetalimit = 0;
		mymins = world.mins;
		mymaxs = world.maxs;
			
		if (autocvar_g_za_maxz) {
			myhavesetalimit = autocvar_g_za_maxz;
			mymaxs_z = autocvar_g_za_maxz;
		} else if (autocvar_g_suggested_za_maxz) {
			myhavesetalimit = autocvar_g_suggested_za_maxz;
			mymaxs_z = autocvar_g_suggested_za_maxz;
		}
		
		if (autocvar_g_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_za_minz) {
				print("G_RNDMADDTNLFURN NOT DOING ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_za_minz;
			}
		} else if (autocvar_g_suggested_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_suggested_za_minz) {
				print("G_RNDMADDTNLFURN NOT DOING SUGGESTED ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_suggested_za_minz;
			}
		}
		
		
		
		if (autocvar_mapforcerndmaddtnlfurn_za_minz_override) {
			if (autocvar_mapforcerndmaddtnlfurn_za_minz_override >= mymaxs_z) {
				print("G_RNDMADDTNLFURN NOT DOING FORCE ZA MIN OVERRIDE LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				print("\n\n",ftos(mymins_z), " Pre: mapforcerndmaddtnlfurn_za_minz_override\n\n");
				mymins_z = autocvar_mapforcerndmaddtnlfurn_za_minz_override;
				print("\n\n",ftos(mymins_z), " Post: mapforcerndmaddtnlfurn_za_minz_override set\n\n");
			}
		}
		
		if (!autocvar_mapforcerndmaddtnlfurn_minx_disable) {
		if (autocvar_mapforcerndmaddtnlfurn_minx) {
			if (autocvar_mapforcerndmaddtnlfurn_minx >= mymaxs_x) {
				print("\nNot doing mapforcerndmaddtnlfurn minx\n");
			} else {
				mymins_x = autocvar_mapforcerndmaddtnlfurn_minx;
			}
		}
		}
		
		if (!autocvar_mapforcerndmaddtnlfurn_miny_disable) {
		if (autocvar_mapforcerndmaddtnlfurn_miny) {
			if (autocvar_mapforcerndmaddtnlfurn_miny >= mymaxs_y) {
				print("\nNot doing mapforcerndmaddtnlfurn miny\n");
			} else {
				mymins_y = autocvar_mapforcerndmaddtnlfurn_miny;
			}
		}
		}
		
		if (!autocvar_mapforcerndmaddtnlfurn_maxx_disable) {
		if (autocvar_mapforcerndmaddtnlfurn_maxx) {
			if (autocvar_mapforcerndmaddtnlfurn_maxx <= mymins_x) {
				print("\nNot doing mapforcerndmaddtnlfurn maxx\n");
			} else {
				mymaxs_x = autocvar_mapforcerndmaddtnlfurn_maxx;
			}
		}
		}
		
		if (!autocvar_mapforcerndmaddtnlfurn_maxy_disable) {
		if (autocvar_mapforcerndmaddtnlfurn_maxy) {
			if (autocvar_mapforcerndmaddtnlfurn_maxy <= mymins_y) {
				print("\nNot doing mapforcerndmaddtnlfurn maxy\n");
			} else {
				mymaxs_y = autocvar_mapforcerndmaddtnlfurn_maxy;
			}
		}
		}
		
		
		//0 == player start, 1 == nothing, 2 == info_notnull (darkhold etc)
		if (autocvar_g_suggested_za_zlimitsearchfor == 1) {
			mysearchfor = 1;
		} else if (autocvar_g_suggested_za_zlimitsearchfor == 2) {
			mysearchfor = 2;
		} else if (autocvar_g_suggested_za_zlimitsearchfor > 2) {
			mysearchfor = 0;
		} else if (autocvar_g_suggested_za_zlimitsearchfor < 0) {
			mysearchfor = 0;	
		} else {
			mysearchfor = 0;
		}
		
	}
	
	if (autocvar_mapforcerndmaddtnlfurn_searchfor_override) {
		mysearchfor = autocvar_mapforcerndmaddtnlfurn_searchfor_override;
	}
	
	rndmaddtnlfurnsuccess = 0;
	rndmaddtnlfurnfail = 0;
	
	while (i) {
		rndmaddtnlfurn_loop(mymins, mymaxs, mysearchfor);
		i = i - 1;
	}
	
	print("^8", ftos(rndmaddtnlfurnfail), " Fail Amnt\n");
	print("^3", ftos(rndmaddtnlfurnsuccess), " Success Amnt\n");
	
	remove(self);
}

void rndmaddtnlfurn_setup(void)
{
	entity rndmaddtnlitemthinker;
	entity oldself;
	
	oldself = self;
	
	rndmaddtnlitemthinker = spawn();
	
	self = rndmaddtnlitemthinker;
	self.think = rndmaddtnlfurn_do;
	
	if (autocvar_g_mapforce_rndmaddtnlfurn) {
		self.nextthink = time + autocvar_g_mapforce_rndmaddtnlfurn_wait;
	} else if (autocvar_g_rndmaddtnlfurn) {
		//Overrides
		self.nextthink = time + autocvar_g_rndmaddtnlfurn_wait;
	} else {
		self.nextthink = time + autocvar_g_suggested_rndmaddtnlfurn_wait;
	}
	
	//print(ftos(self.nextthink)," G_RNDMADDTNLFURN NEXTTHINK\n");
	self = oldself;
}

void g_rndmaddtnlfurn(void)
{
	if (autocvar_g_rndmaddtnlfurn || autocvar_g_suggested_rndmaddtnlfurn || autocvar_g_mapforce_rndmaddtnlfurn)
	{
		rndmaddtnlfurn_setup();
	}
}
