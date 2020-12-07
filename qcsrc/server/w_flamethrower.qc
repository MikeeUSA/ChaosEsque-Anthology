#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FLAMETHROWER, w_flamethrower, IT_FUEL, 5, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "flamethrower", "flamethrower", _("FlameThrower"));
#else
#ifdef SVQC
void FlameThrowerInit();
vector flamethrower_shotorigin[4];

.float flamethrower_count;
.float flamethrower_secondarytime;

.float flamethrower_arrowlit;
.float flamethrower_arrownextburn;
.float flamethrowerfuelsoaked; //How soaked is the ent?
.entity flamethrowerlight;


void flamethrower_thinklight() {
	if (self.owner.flamethrower_arrowlit == 1 && self.flamethrower_arrowlit == 1 && self.owner.health > 0) {
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *48)+(v_up *2));
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up		
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		    vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *2));
		    if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *2));
		    	if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *2));
		    	}
		    }
		}
		setorigin(self, vlporigin);
		self.nextthink = time;
		self.flamethrower_arrowlit = 0;
	} else {
		remove(self);
	}
}

void flamethrower_spawnlight(entity myplayer) {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 128;
	newtorchlight.color = '1 0.5 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = myplayer;
	newtorchlight.think = flamethrower_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.flamethrower_arrowlit = 1;
	myplayer.flamethrowerlight = newtorchlight;
}


.vector hook_start, hook_end;
float flamethrowerbeam_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_FLAMETHROWERBEAM);
	sf = sf & 0x7F;
	if(sound_allowed(MSG_BROADCAST, self.realowner))
		sf |= 0x80;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
		if (self.owner.shootfromaltaim || self.owner.classname == "piercedjetemitter") {
			WriteByte(MSG_ENTITY, 1); //Don't interpolate from "owner player"
		} else {
			WriteByte(MSG_ENTITY, 0);
		}
		WriteCoord(MSG_ENTITY, autocvar_g_balance_flamethrower_primary_range);
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}
	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}
	return TRUE;
}

float frostbeam_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_FROSTBEAM);
	sf = sf & 0x7F;
	if(sound_allowed(MSG_BROADCAST, self.realowner))
		sf |= 0x80;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
		if (self.owner.shootfromaltaim || self.owner.classname == "piercedjetemitter") {
			WriteByte(MSG_ENTITY, 1); //Don't interpolate from "owner player"
		} else {
			WriteByte(MSG_ENTITY, 0);
		}
		WriteCoord(MSG_ENTITY, autocvar_g_balance_flamethrower_primary_range);
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}
	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}
	return TRUE;
}

float poisonbeam_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_POISONBEAM);
	sf = sf & 0x7F;
	if(sound_allowed(MSG_BROADCAST, self.realowner))
		sf |= 0x80;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
		if (self.owner.shootfromaltaim || self.owner.classname == "piercedjetemitter") {
			WriteByte(MSG_ENTITY, 1); //Don't interpolate from "owner player"
		} else {
			WriteByte(MSG_ENTITY, 0);
		}
		WriteCoord(MSG_ENTITY, autocvar_g_balance_flamethrower_primary_range);
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}
	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}
	return TRUE;
}


.entity flamethrowerbeam;
.float prevflamethrowerfire;
float flamethrowerbeam_checkammo()
{
	if(self.realowner.items & IT_UNLIMITED_WEAPON_AMMO)
		return TRUE;
	else if(autocvar_g_balance_flamethrower_reload_ammo)
		return self.realowner.clip_load > 0;
	else
		return self.realowner.ammo_fuel > 0;
}

void flamethrower_alighttarget(entity mytarget, entity myrealowner, float myfuelsoak, float myburndamage)
{
	//Somewhat similar code in w_crossbowdtwr
	if (mytarget != world) {
			if (mytarget.classname == "tree" || mytarget.classname == "bush"
			|| isPlayerOrMonsterByClassname(mytarget)) {
				//This is the crossbowbolt type we are
				//print("burn!2222\n");
				Fire_AddDamage(mytarget, myrealowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
			} else if (mytarget.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) {
				//Continuous stream, so give some time before ignition
				mytarget.flamethrowerfuelsoaked = mytarget.flamethrowerfuelsoaked + myfuelsoak;
				if (mytarget.flamethrowerfuelsoaked > 1000) {
					Fire_AddDamage(mytarget, myrealowner, myburndamage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
				}
			} else {
				//Continuous stream, so give some time before ignition
				if (mytarget.classname == "building" && mytarget.multitool_hitbox != world) {
					mytarget.flamethrowerfuelsoaked = mytarget.flamethrowerfuelsoaked + myfuelsoak;
					if ((mytarget.flamethrowerfuelsoaked > 500) && multitool_iswooden(mytarget.multitool_hitbox.count)) {
						Fire_AddDamage(mytarget.multitool_hitbox, myrealowner, myburndamage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				else if (mytarget.accptcrssbwstklkbld) {
				if (mytarget.multitool_doorframeent && mytarget.multitool_doorframeent.multitool_hitbox != world) {
					mytarget.flamethrowerfuelsoaked = mytarget.flamethrowerfuelsoaked + myfuelsoak;
					if ((mytarget.flamethrowerfuelsoaked > 500) && multitool_iswooden(mytarget.multitool_doorframeent.multitool_hitbox.count)) {
						Fire_AddDamage(mytarget.multitool_doorframeent.multitool_hitbox, myrealowner, myburndamage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				}
			}
	}

}

void flamethrower_radiusburn(vector mytargetorigin, entity myrealowner, float myradius, float mysoak, float myburndamage)
{
	local entity eburn;
	eburn = findradius(mytargetorigin, myradius);
	while(eburn)
	{
		
			flamethrower_alighttarget(eburn, myrealowner, mysoak, myburndamage);
			//END//

	eburn = eburn.chain;
	}
	return;	
}



void flamethrower_freezetarget(entity mytarget, entity myrealowner, float myburndamage)
{
	if (mytarget != world) {
			if((mytarget.flags & FL_MONSTER) || (mytarget.flags & FL_CLIENT)) {
				Freeze(mytarget, 0.05/(myburndamage*0.05), 0);
			}
	}

}

void flamethrower_radiusfreeze(vector mytargetorigin, entity myrealowner, float myradius, float myburndamage)
{
	local entity eburn;
	eburn = findradius(mytargetorigin, myradius);
	while(eburn)
	{
		
			flamethrower_freezetarget(eburn, myrealowner, myburndamage);
			//END//

	eburn = eburn.chain;
	}
	return;	
}



void flamethrower_poisontarget(entity mytarget, entity myrealowner, float myburndamage)
{
	if (mytarget != world) {
			if((mytarget.flags & FL_MONSTER) || (mytarget.flags & FL_CLIENT)) {
				Damage (mytarget, myrealowner, myrealowner, myburndamage * frametime, DEATH_SLIME, mytarget.origin, '0 0 0');
				Freeze(mytarget, 0.8/(myburndamage*0.1), 1);
			}
	}

}

void flamethrower_radiuspoison(vector mytargetorigin, entity myrealowner, float myradius, float myburndamage)
{
	local entity eburn;
	eburn = findradius(mytargetorigin, myradius);
	while(eburn)
	{
		
			flamethrower_poisontarget(eburn, myrealowner, myburndamage);
			//END//

	eburn = eburn.chain;
	}
	return;	
}



entity flamethrowerbeam_owner_ent;

void flamethrowerbeam_think_do(entity owner_player, entity damage_owner_player, float dt, float flamethrowerdamage, float flamethrowerforce, float flamethrowerforceup, float myburndamage, float myelementaltype)
{
	if(!flamethrowerbeam_owner_ent)
	{
		flamethrowerbeam_owner_ent = spawn();
		flamethrowerbeam_owner_ent.classname = "flamethrowerbeam_owner_ent";
	}
	
	float rmulti, f;

	WarpZone_traceline_antilag(flamethrowerbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, flamethrowerbeam_owner_ent, ANTILAG_LATENCY(owner_player));


	//if (trace_dphitcontents & DPCONTENTS_WATER || trace_dphitcontents & DPCONTENTS_SLIME) {
	//	//print("   Hit Water Person \n\n\n!!!!!!!\n");
	//}
	
	if (trace_ent &&
	(!myelementaltype &&  !(trace_dphitcontents & DPCONTENTS_WATER || trace_dphitcontents & DPCONTENTS_SLIME)) 
	|| ((myelementaltype == 1) &&  !(trace_dphitcontents & DPCONTENTS_LAVA || trace_dphitcontents & DPCONTENTS_SLIME)) 
	|| ((myelementaltype == 2) &&  !(trace_dphitcontents & DPCONTENTS_LAVA || trace_dphitcontents & DPCONTENTS_WATER)) 
	){
		//Do nothing
	} else {
		//Pull back 1 qu if we hit world, since the pointcontentstest will probably come back solid
		//We want to see if there is water infront of that possibly submerged wall...
		W_SetupShot_Range(owner_player, TRUE, 0, "", 0, flamethrowerdamage * dt, (vlen(w_shotorg - trace_endpos) - 1));
		WarpZone_traceline_antilag(flamethrowerbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, flamethrowerbeam_owner_ent, ANTILAG_LATENCY(owner_player));
	}


        ///////////////////////////////////////////////////////
	///////////////////////////////////////////////////////
	//BEGIN Binary Tree Search To Deal With Water        //
	///////////////////////////////////////////////////////
	local float mydamageisnullified;
	local float mytestpointcontents;
	local float myvlen; //Original length
	local float myvlentest; //Lenght of last test
	local float myvlenlatch; //Furthest still good (Hit nothing, don't go below this from now on)
	local float myvlenlimit; //Last too far (Hit water)
	local float mycounter;
	local float myiter;
	myvlenlatch = 0;
	
	mycounter = 0;
	mydamageisnullified = 0;
	mytestpointcontents = pointcontents(trace_endpos);
	if (autocvar_g_balance_flamethrower_waterdetectbinarytreeiter < 0) {
		//Test disabled.
	} else if (
		(!myelementaltype && (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME
		|| trace_dphitcontents & DPCONTENTS_WATER || trace_dphitcontents & DPCONTENTS_SLIME))
	||
		(myelementaltype == 1 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME
		|| trace_dphitcontents & DPCONTENTS_LAVA || trace_dphitcontents & DPCONTENTS_SLIME))
	||
		(myelementaltype == 2 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER
		|| trace_dphitcontents & DPCONTENTS_LAVA || trace_dphitcontents & DPCONTENTS_WATER))
	){
		myiter = autocvar_g_balance_flamethrower_waterdetectbinarytreeiter;
		if (myiter > 20) {
			myiter = 20; //Avoid complete insanity
		}
	
		//Do binary tree search
		myvlen = vlen(w_shotorg - trace_endpos);
		myvlenlimit = myvlen;
		myvlentest = myvlen * 0.5;
		W_SetupShot_Range(owner_player, TRUE, 0, "", 0, flamethrowerdamage * dt, myvlentest);
		WarpZone_traceline_antilag(flamethrowerbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, flamethrowerbeam_owner_ent, ANTILAG_LATENCY(owner_player));
		
		//print("Starting\n");
		//print(vtos(w_shotorg)," w_shotorg\n");
		//print(vtos(w_shotend)," w_shotend\n");
		//print (ftos(myvlen), " _ _ ", ftos(mycounter), "\n");
		//print (ftos(myvlentest), " o o ", ftos(mycounter), "\n");

		//set to 8 to 10?
		//10 gets down to 1 qu
		while (mycounter < myiter) {
		  mytestpointcontents = pointcontents(trace_endpos);
		  if (
		  	(!myelementaltype && (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME
		  	|| mytestpointcontents == CONTENT_SOLID))
		  ||
		  	(myelementaltype == 1 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME
		  	|| mytestpointcontents == CONTENT_SOLID))
		  ||
		  	(myelementaltype == 2 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER
		  	|| mytestpointcontents == CONTENT_SOLID))
		  ){
		  	//print("Hit Water, trying Shorter\n");
			myvlenlimit = myvlentest; //Last test was too long, hit water
			//print("   ^x00A", ftos(myvlenlimit)," Limit^7\n");

			if (myvlenlatch) {
				//When we extended our reach 1.5x, we found outselves in water
				//Let us test between the previous no-water spot (latch), and the current water spot(test)
				///This seems correct
				myvlentest = myvlentest - myvlenlatch;
				myvlentest = myvlenlatch + (myvlentest * 0.5);
				//myvlenlatch = 0;
			} else {
				myvlentest = myvlentest * 0.5;
			}
			W_SetupShot_Range(owner_player, TRUE, 0, "", 0, flamethrowerdamage * dt, myvlentest);
			WarpZone_traceline_antilag(flamethrowerbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, flamethrowerbeam_owner_ent, ANTILAG_LATENCY(owner_player));

		  } else {
		  	//No water/slime hit. Dry spot. Extend out to see how far we may go.
		  	//print("Good Spot, Trying Longer\n");
			
				myvlenlatch = myvlentest; //We have found no water at last test spot, so we remeber that
				//print("   ^x444", ftos(myvlenlatch)," Latch^7\n");
			
			myvlentest = myvlentest + ((myvlenlimit - myvlentest) * 0.5);

			W_SetupShot_Range(owner_player, TRUE, 0, "", 0, flamethrowerdamage * dt, myvlentest);
			WarpZone_traceline_antilag(flamethrowerbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, flamethrowerbeam_owner_ent, ANTILAG_LATENCY(owner_player));

		  }
		  
		  //print (ftos(myvlentest), " * * ", ftos(mycounter), "\n");
		  mycounter = mycounter + 1;
		}
		
		//print("End\n");
		//print(vtos(w_shotorg)," w_shotorg\n");
		//print(vtos(w_shotend)," w_shotend\n");
		
		mytestpointcontents = pointcontents(trace_endpos);
		if (!myelementaltype && (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME)) {
			mydamageisnullified = 1;
		}
		else if (myelementaltype == 1 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME)) {
			mydamageisnullified = 1;
		}
		else if (myelementaltype == 2 && (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER)) {
			mydamageisnullified = 1;
		}
	} 
	///////////////////////////////////////////////////////
	//END Binary Tree Search To Deal With Water          //
	///////////////////////////////////////////////////////
	///////////////////////////////////////////////////////


	
	//f needs to be calculated anyway for arcing, even if no direct damage by beam
	f = ExponentialFalloff(autocvar_g_balance_flamethrower_primary_falloff_mindist, autocvar_g_balance_flamethrower_primary_falloff_maxdist, autocvar_g_balance_flamethrower_primary_falloff_halflifedist, vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos) - w_shotorg));
	
	rmulti = 0;
	// apply the direct beam damage
	if (mydamageisnullified) {
		//Do nothing
	} else {
	/////////
	//START//
	/////////
	
		local vector mytargetentpos;
		mytargetentpos = trace_endpos;
		
		if(trace_ent)
		{
			local entity mytargetent;
			mytargetent = trace_ent;
			
			rmulti = 1;
			vector force;
			force = w_shotdir * flamethrowerforce + '0 0 1' * flamethrowerforceup;

			if (myelementaltype == 1) {
				//if(accuracy_isgooddamage(owner_player, mytargetent))
				//	accuracy_add(owner_player, WEP_FLAMETHROWER, 0, flamethrowerdamage * dt * f);
				Damage (mytargetent, damage_owner_player, damage_owner_player, flamethrowerdamage * dt * f, DEATH_ICE, mytargetentpos, force * dt);
				
				if (mytargetent) {
					flamethrower_freezetarget(mytargetent, damage_owner_player, myburndamage);
				}
			} else if (myelementaltype == 2) {
				//if(accuracy_isgooddamage(owner_player, mytargetent))
				//	accuracy_add(owner_player, WEP_FLAMETHROWER, 0, flamethrowerdamage * dt * f);
				Damage (mytargetent, damage_owner_player, damage_owner_player, flamethrowerdamage * dt * f, DEATH_SLIME, mytargetentpos, force * dt);
				
				if (mytargetent) {
					flamethrower_poisontarget(mytargetent, damage_owner_player, myburndamage);
				}
			} else {
				if(accuracy_isgooddamage(owner_player, mytargetent))
					accuracy_add(owner_player, WEP_FLAMETHROWER, 0, flamethrowerdamage * dt * f);
				Damage (mytargetent, damage_owner_player, damage_owner_player, flamethrowerdamage * dt * f, WEP_FLAMETHROWER, mytargetentpos, force * dt);
				
				if (mytargetent) {
					flamethrower_alighttarget(mytargetent, damage_owner_player, flamethrowerdamage * dt * f, myburndamage);
				}
			}
		}
	
	
		if (myelementaltype == 1) {
			//pointparticles(particleeffectnum("iceorglass"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("pipe_smoke"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("steam"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("smoke_ring"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("damage_nex"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("iceball"), mytargetentpos, '0 0 0', 1);
			local vector mytep2;
			mytep2 = mytargetentpos;
			mytep2_z = mytep2_z - 1;
			trailparticles(owner_player, particleeffectnum("iceball"), mytep2, mytargetentpos);
			//trailparticles(owner_player, particleeffectnum("iceball"), mytargetentpos, mytargetentpos);
			flamethrower_radiusfreeze(mytargetentpos, owner_player, autocvar_g_balance_flamethrower_primary_radius, myburndamage); //Alight things in a radius;
		} else if (myelementaltype == 2) {
			//pointparticles(particleeffectnum("iceorglass"), mytargetentpos, '0 0 0', 1);
			pointparticles(particleeffectnum("pipe_smoke"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("steam"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("smoke_ring"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("damage_nex"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("iceball"), mytargetentpos, '0 0 0', 1);
			flamethrower_radiuspoison(mytargetentpos, owner_player, autocvar_g_balance_flamethrower_primary_radius, myburndamage); //Alight things in a radius;
		} else {
			flamethrower_radiusburn(mytargetentpos, owner_player, autocvar_g_balance_flamethrower_primary_radius, flamethrowerdamage * dt * f, myburndamage); //Alight things in a radius;
	
			//pointparticles(particleeffectnum("EF_BIGFLAME"), mytargetentpos, '0 0 0', 1);
			pointparticles(particleeffectnum("torchflame"), mytargetentpos, '0 0 0', 1);
			//pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), mytargetentpos, '0 0 0', 1); //For light
		
			local entity flfspot;
			flfspot = spawn();
			flfspot.origin = mytargetentpos;
			OilFire_explosion_spawnoilburnermaybe(flfspot);
			if (random() > 0.8) {
				//print(vtos(w_shotorg), "\n");
				flfspot.origin = w_shotorg;
				OilFire_explosion_spawnoilburnermaybe(flfspot);
			}
			remove(flfspot);
		}
	
	
	///////
	//END//
	///////
	}
	
	// draw effect
	if(w_shotorg != self.hook_start)
	{
		self.SendFlags |= 2;
		self.hook_start = w_shotorg;
	}
	if(w_shotend != self.hook_end)
	{
		self.SendFlags |= 4;
		self.hook_end = w_shotend;
	}
}

void flamethrowerbeam_think()
{
	entity owner_player;
	owner_player = self.realowner;

	owner_player.prevflamethrowerfire = time;
	if (self != owner_player.flamethrowerbeam)
	{
		remove(self);
		return;
	}

	if (owner_player.weaponentity.state != WS_INUSE || !flamethrowerbeam_checkammo() || owner_player.deadflag != DEAD_NO || !owner_player.BUTTON_ATCK || owner_player.freezetag_frozen || owner_player.frozen || owner_player.stoned)
	{
		if(self == owner_player.flamethrowerbeam)
			owner_player.flamethrowerbeam = world;
		remove(self);
		return;
	}
	
	if ((owner_player.watertype == CONTENT_WATER || owner_player.watertype == CONTENT_SLIME) && owner_player.waterlevel > 2) {
		if(self == owner_player.flamethrowerbeam)
			owner_player.flamethrowerbeam = world;
		remove(self);
		return;
	}
	
	if (!owner_player.flamethrower_arrowlit) {
		owner_player.flamethrower_arrowlit = 1;
		flamethrower_spawnlight(owner_player);
	}

	//Obstructs view //pointparticles(particleeffectnum("torchflame"), w_shotorg, '0 0 0', 1);
	//Much Too much//pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, '0 0 0', 1); //For light

	self.nextthink = time;

	makevectors(owner_player.v_angle);
	
	Methane_ExplodeBullet_maybe_at (w_shotorg, owner_player); //If we are in methane, maybe cause an explosion

	float dt;
	dt = frametime;

	// if this weapon is reloadable, decrease its load. Else decrease the player's ammo
	if not(owner_player.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		if(autocvar_g_balance_flamethrower_primary_ammo)
		{
			if(autocvar_g_balance_flamethrower_reload_ammo)
			{
				dt = min(dt, owner_player.clip_load / autocvar_g_balance_flamethrower_primary_ammo);
				owner_player.clip_load = max(0, owner_player.clip_load - autocvar_g_balance_flamethrower_primary_ammo * frametime);
				owner_player.(weapon_load[WEP_FLAMETHROWER]) = owner_player.clip_load;
			}
			else
			{
				dt = min(dt, owner_player.ammo_fuel / autocvar_g_balance_flamethrower_primary_ammo);
				owner_player.ammo_fuel = max(0, owner_player.ammo_fuel - autocvar_g_balance_flamethrower_primary_ammo * frametime);
			}
		}
	}

	W_SetupShot_Range(owner_player, TRUE, 0, "", 0, autocvar_g_balance_flamethrower_primary_damage * dt, autocvar_g_balance_flamethrower_primary_range);
	
	///
	flamethrowerbeam_think_do(owner_player, owner_player, dt,
	autocvar_g_balance_flamethrower_primary_damage,
	autocvar_g_balance_flamethrower_primary_force,
	autocvar_g_balance_flamethrower_primary_force_up,
	autocvar_g_balance_torch_fire_damage, 0);
	
	//Arcing stuff;

	
}

// experimental lightning gun
void W_FlameThrower_Attack3 (void)
{
	Methane_ExplodeBullet_maybe_at (self.origin, self); //If we are in methane, maybe cause an explosion

	//pointparticles(particleeffectnum("torchflame"), w_shotorg, w_shotdir * 1000, 1); //flys like a shot
	//pointparticles(particleeffectnum("torchflame"), w_shotorg, '0 0 0', 1);

	//// only play fire sound if 0.5 sec has passed since player let go the fire button
	//if(time - self.prevflamethrowerfire > 0.5)
	//	sound (self, CH_WEAPON_A, "weapons/flamethrowerbeam_fire.wav", VOL_BASE, ATTN_NORM);

	entity beam, oldself;

	self.flamethrowerbeam = beam = spawn();
	beam.classname = "flamethrowerbeam";
	beam.solid = SOLID_NOT;
	beam.think = flamethrowerbeam_think;
	beam.owner = beam.realowner = self;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_flamethrower_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, flamethrowerbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
	
	pointparticles(particleeffectnum("torchflame"), w_shotorg, '0 0 0', 1);
}

void FlameThrowerInit()
{
	weapon_action(WEP_FLAMETHROWER, WR_PRECACHE);
	flamethrower_shotorigin[0] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_FLAMETHROWER), FALSE, FALSE, 1);
	flamethrower_shotorigin[1] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_FLAMETHROWER), FALSE, FALSE, 2);
	flamethrower_shotorigin[2] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_FLAMETHROWER), FALSE, FALSE, 3);
	flamethrower_shotorigin[3] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_FLAMETHROWER), FALSE, FALSE, 4);
}

void spawnfunc_weapon_flamethrower (void)
{
	weapon_defaultspawnfunc(WEP_FLAMETHROWER);
}

float W_FlameThrower_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_flamethrower_reload_ammo && self.clip_load < min(autocvar_g_balance_flamethrower_primary_ammo, autocvar_g_balance_flamethrower_secondary_ammo)) )
	{
		//Tried to figure out the logic of the custom flamethrower reload code, has to do with
		//not allowing you to waste all your ammo on secondary I think. I'll keep it
		//simple here though. Down on primary or secondary ammo, gotta reload
		return 1;
	} else {
		return 0;
	}
	
}


.float bot_secondary_flamethrowermooth;
.float BUTTON_ATCK_prev;
float w_flamethrower(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_FlameThrower_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_flamethrowermooth = 0;
		if(self.bot_secondary_flamethrowermooth == 0)
		{
			float shoot;
			shoot = bot_aim(1000000, 0, 0.001, FALSE);			
			
			if(shoot)
			{
				if(vlen(self.origin-self.enemy.origin) > (autocvar_g_balance_flamethrower_primary_range + autocvar_g_balance_flamethrower_primary_radius))
				{
					//Don't bother, totally out of range
				} else {
					self.BUTTON_ATCK = TRUE;
				}
				
				if(random() < 0.01) self.bot_secondary_flamethrowermooth = 1;
			}
		}
	}
	else if (req == WR_THINK && !W_FlameThrower_NeedManualReload())
	{
		if(autocvar_g_balance_flamethrower_reload_ammo) // forced reload
		{
			if(self.clip_load > 0)
				ammo_amount = 1;
			if(self.clip_load >= autocvar_g_balance_flamethrower_secondary_ammo)
				ammo_amount += 1;

			if(!ammo_amount)
			{
				weapon_action(self.weapon, WR_RELOAD);
				return FALSE;
			}
		}
		if (self.BUTTON_ATCK)
		{
			if(self.BUTTON_ATCK_prev)
			{
					// prolong the animtime while the gun is being fired
					if(self.animstate_startframe == self.anim_shoot_x && self.animstate_numframes == self.anim_shoot_y)
						weapon_thinkf(WFRAME_DONTCHANGE, autocvar_g_balance_flamethrower_primary_animtime, w_ready);
					else
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_flamethrower_primary_animtime, w_ready);
			}
			if (weapon_prepareattack(0, 0))
			{
				if ((!self.flamethrowerbeam) || wasfreed(self.flamethrowerbeam))
				{
					W_FlameThrower_Attack3();
				}
				if(!self.BUTTON_ATCK_prev)
				{
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_flamethrower_primary_animtime, w_ready);
						self.BUTTON_ATCK_prev = 1;
				}
			}
		} else {
			if (self.BUTTON_ATCK_prev != 0)
			{
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_flamethrower_primary_animtime, w_ready);
				ATTACK_FINISHED(self) = time + autocvar_g_balance_flamethrower_primary_refire * W_WeaponRateFactor();
			}
			self.BUTTON_ATCK_prev = 0;
			
			self.flamethrower_arrowlit = 0;
		}
		
		if (self.flamethrower_arrowlit == 1) {
			if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
				self.flamethrower_arrowlit = 0;
			} else if (time > self.flamethrower_arrownextburn) {
				self.flamethrower_arrownextburn = time + 0.2;
				self.flamethrowerlight.flamethrower_arrowlit = 1;
			} else {
				self.flamethrowerlight.flamethrower_arrowlit = 1;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_flamethrower.md3");
		precache_model ("models/weapons/v_flamethrower.md3");
		precache_model ("models/weapons/h_flamethrower.iqm");
		precache_sound ("misc/ignition_firewall.ogg");
		precache_sound ("weapons/electro_impact_combo.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		
			//precache_sound ("weapons/flamethrowerbeam_fire.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_FLAMETHROWER);
		self.current_ammo = ammo_fuel;
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(!autocvar_g_balance_flamethrower_primary_ammo)
			ammo_amount = 1;
		else
			ammo_amount = self.ammo_fuel > 0;
		ammo_amount += self.(weapon_load[WEP_FLAMETHROWER]) > 0;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_fuel >= autocvar_g_balance_flamethrower_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_FLAMETHROWER]) >= autocvar_g_balance_flamethrower_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.flamethrower_secondarytime = time;
		self.flamethrower_arrowlit = 0;
	}
	else if (req == WR_GONETHINK)
	{
		//We lost the weapon
		self.flamethrower_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We dropped the weapon
		self.flamethrower_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_flamethrower_primary_ammo, autocvar_g_balance_flamethrower_secondary_ammo), autocvar_g_balance_flamethrower_reload_ammo, autocvar_g_balance_flamethrower_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_flamethrower(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		
				//pointparticles(particleeffectnum("hagar_explode"), org2, '0 0 0', 1);
				//if(!w_issilent)
				//	sound(self, CH_SHOTS, "misc/ignition_firewall.ogg", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("misc/ignition_firewall.ogg");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
			w_deathtypestring = _("%s burned the air with flame");
	}
	else if (req == WR_KILLMESSAGE)
	{
		
			if(w_deathtype & HITTYPE_SPLASH)
				w_deathtypestring = _("%s got too close to %s's flame");
			else
				w_deathtypestring = _("%s was immolated by %s's flame");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_flamethrower (void)
//{
//	weapon_defaultspawnfunc(WEP_FLAMETHROWER);
//}
