#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FLASHLIGHT, w_flashlight, IT_NAILS, 3, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "flashlight", "flashlight", _("Flashlight"))
#else
#ifdef SVQC
.float flashlight_lit;
.float flashlight_changecolor;
.float flashlight_changefocus;
.float flashlight_release;
.float flashlight_secondary;
.entity flashlightlight;
.entity flashlightlightforwarpzone;

.float swing_prev;
.entity swing_alreadyhit;

void TurnOffFlashlightlightForWarpzone(entity myplyr)
{
	if (myplyr.flashlightlightforwarpzone) {
	  if (myplyr.flashlightlightforwarpzone != world) { //Yes, redundant
	    if (myplyr.flashlightlightforwarpzone.owner == myplyr) {
	      //print("Removing flashlightlightforwarpzone for warpzone\n");
	      myplyr.flashlightlightforwarpzone.light_lev = 0;
	      remove(myplyr.flashlightlightforwarpzone);
	    }
	  }
	}
}

void flashlight_thinklight() {
	if (self.owner.flashlight_lit == 1 && self.flashlight_lit == 1 && self.owner.health > 0) {
		//setorigin(self, self.owner.origin);
		self.nextthink = time;
		
		makevectors(self.owner.v_angle);
		local vector vlporigin;
		
		vlporigin = (self.owner.origin + '0 0 16' + v_forward * 64);
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		//Don't want to do traceline every frame
		//Sometimes this will shine beyond doors tho...
		//Guess I've made my decision for now
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = (self.owner.origin + '0 0 16' + v_forward * 56);
		  //print("1\n");
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	//print("2\n");
			vlporigin = (self.owner.origin + '0 0 16' + v_forward * 48);
		  	if (pointcontents (vlporigin) == CONTENT_SOLID) {
				//print("3\n");
				vlporigin = (self.owner.origin + '0 0 16' + v_forward * 40);
				if (pointcontents (vlporigin) == CONTENT_SOLID) {
					//print("4\n");
					vlporigin = (self.owner.origin + '0 0 16' + v_forward * 32);
					if (pointcontents (vlporigin) == CONTENT_SOLID) {
						//print("5\n");
						vlporigin = (self.owner.origin + '0 0 16' + v_forward * 24);
						if (pointcontents (vlporigin) == CONTENT_SOLID) {
							//print("6\n");
							vlporigin = (self.owner.origin + '0 0 16' + v_forward * 18); //Don't want to align with player extens
							if (pointcontents (vlporigin) == CONTENT_SOLID) {
								//print("7\n");
								vlporigin = (self.owner.origin + '0 0 16');
							}
						}
					}
				}
		  	}
		  }
		}
		
		setorigin(self, vlporigin);
		//setorigin(self, self.owner.origin + '0 0 16' + v_forward * 10); //Old
		self.angles = self.owner.v_angle;
		self.angles_x = self.angles_x * -1;
		
		if (self.owner.flashlight_changecolor != self.flashlight_changecolor) {
			if (self.owner.flashlight_changecolor == 2) {
				self.color = '1 0 0';
			} else if (self.owner.flashlight_changecolor == 1) {
				self.color = '0 1 0';
			} else {
				self.color = '0.75 0.8 1';
			}
			self.flashlight_changecolor = self.owner.flashlight_changecolor;
		}
		
		if (self.owner.flashlight_changefocus != self.flashlight_changefocus) {
			if (self.owner.flashlight_changefocus == 1) {
				self.skin = 2;
				self.light_lev = autocvar_g_balance_flashlight_lightlev * 0.5;
			} else {
				self.skin = 1;
				self.light_lev = autocvar_g_balance_flashlight_lightlev;
			}
			self.flashlight_changefocus = self.owner.flashlight_changefocus;
		}
		
		//self.flashlight_lit = 0;
	} else {
		remove(self);
	}
}

void flashlight_spawnlight() {
	local entity newflashlightlight;
	newflashlightlight = spawn();
	newflashlightlight.pflags = PFLAGS_FULLDYNAMIC;
	newflashlightlight.light_lev = autocvar_g_balance_flashlight_lightlev;
	newflashlightlight.color = '0.75 0.8 1';
	newflashlightlight.skin = 1; //Projective texture cubemap#.tga
	newflashlightlight.style = 255;
	newflashlightlight.owner = self;
	newflashlightlight.think = flashlight_thinklight;
	newflashlightlight.nextthink = time;
	newflashlightlight.flashlight_lit = 1;
	self.flashlightlight = newflashlightlight;
	
	if(!warpzone_warpzones_exist) {
		//Do nothing
	} else {
		if (autocvar_g_balance_torch_maxlighttraces_enable) {
			//The utilize warpzone code attempt didn't quite work
			//The goal was to use the same exact light setting as the "real" light
			//It sorta worked at first, but problems arose...
			//The light would only shine in the other area
			//if you were quite near the warp zone
			//Sometimes it would flicker
			//Sometimes it would show up from a farther distance, but only after a second or two.
			//////For using:Warpzone code attempt 
			//////self.flashlightlight.ammount7 = 4096; //how far //192 is fairly good //128 not enough
			//////self.flashlightlight.ammount2 = 22; //Deviation from center; //(not used, traces)
			//////self.flashlightlightforwarpzone = torch_spawnlightforwarpzone(newflashlightlight, newflashlightlight.style, newflashlightlight.skin, newflashlightlight.light_lev, 1);
			
			//Ohwell, KISS:
						
			self.flashlightlight.ammount2 = 22; //Deviation from center. Used to make the thing possibly shine on both sides
			
			if (self.flashlight_changefocus == 1) {
				//Big
				self.flashlightlight.ammount7 = 512;
				self.flashlightlightforwarpzone = torch_spawnlightforwarpzone(newflashlightlight, newflashlightlight.style, 0, 128, 1);
			} else {
				//Small
				self.flashlightlight.ammount7 = 768;
				self.flashlightlightforwarpzone = torch_spawnlightforwarpzone(newflashlightlight, newflashlightlight.style, 0, 64, 1);
			}
			self.flashlightlightforwarpzone.subordinate10 = newflashlightlight; //The "real" flashlight
			self.flashlightlightforwarpzone.weapon = WEP_FLASHLIGHT;
		}
	}
}


void flashlight_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time; 
		W_PlayStrengthSound(self.realowner);
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors
	
	// calculate swing percentage based on time
	meleetime = wmelee_time * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_balance_flashlight_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_flashlight_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_flashlight_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_flashlight_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_flashlight_primary_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));
		
		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5); 
		//te_customflash(targpos, 40,  2, '1 1 1');
		
		is_player = isPlayerOrMonsterByClassname(trace_ent);

		if (is_player)
		{
			if (melee_check_collision(self.realowner, trace_ent))
			{
				if(trace_ent.melee_temp && !self.meleeotherpassesthrough) remove(trace_ent.melee_temp);
				remove(self);
				return;	
			}
		}

		if (trace_fraction < 1) { // if trace is good, apply the damage and remove self
		  if((trace_ent.takedamage == DAMAGE_AIM) //Player or some entity that can be damaged
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || wmelee_nonplayerdamage))
		  {
			target_victim = trace_ent; // so it persists through other calls
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (wprimary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (wmelee_nonplayerdamage * min(1, swing_factor + 1));
			
			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));
			
			
			if (is_player) {
				swing_damage = W_CritHitCalc_Blunt(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_FLASHLIGHT);
			}
				
			Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_FLASHLIGHT, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_flashlight_primary_force);
				
			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_FLASHLIGHT, 0, swing_damage); }
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_flashlight_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		  }
		}
	}
	
	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		remove(self);
		return;
	}
	else
	{
		// set up next frame 
		self.swing_prev = i;
		self.nextthink = time;
	}
}

void flashlight_primarythink (void)
{
	flashlight_meleethink(
		autocvar_g_balance_flashlight_primary_melee_time,
		autocvar_g_balance_flashlight_primary_melee_range,
		autocvar_g_balance_flashlight_primary_damage,
		autocvar_g_balance_flashlight_primary_melee_nonplayerdamage
		);
}

void flashlight_secondarythink (void)
{
	flashlight_meleethink(
		autocvar_g_balance_flashlight_secondary_melee_time,
		autocvar_g_balance_flashlight_secondary_melee_range,
		autocvar_g_balance_flashlight_secondary_damage,
		autocvar_g_balance_flashlight_secondary_melee_nonplayerdamage
		);
}

void W_Flashlight_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/flashlight_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.flashlight_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_flashlight_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_flashlight_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 1;
	
	if(self.flashlight_secondary == 1) {
	 	self.melee_temp_starttime = time + autocvar_g_balance_flashlight_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_flashlight_secondary_melee_time;
	   meleetemp.think = flashlight_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_flashlight_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_flashlight_secondary_damage, autocvar_g_balance_flashlight_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_flashlight_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_flashlight_primary_melee_time;
	   meleetemp.think = flashlight_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_flashlight_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_flashlight_primary_damage, autocvar_g_balance_flashlight_primary_melee_range);
	}
}


void spawnfunc_weapon_flashlight (void)
{
	weapon_defaultspawnfunc(WEP_FLASHLIGHT);
}

.float flashlight_primarytime;

float w_flashlight(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_flashlight_primary_melee_range)
		&& (self.flashlight_release)) {
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		}
		else
		{
			self.BUTTON_ATCK=FALSE;
		}
	}
	else if (req == WR_THINK)
	{
		//if (!self.crouch) // we are not currently crouching; this fixes an exploit where your melee anim is not visible, and besides wouldn't make much sense
		if (self.BUTTON_ATCK)
		if (self.flashlight_release)
		if (weapon_prepareattack(1, autocvar_g_balance_flashlight_primary_refire))
		{
			self.flashlight_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Flashlight_Attack);
			self.flashlight_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.flashlight_release)
		if (weapon_prepareattack(1, autocvar_g_balance_flashlight_secondary_refire))
		{
			self.flashlight_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Flashlight_Attack);
			self.flashlight_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.flashlight_release = 1;
		}
		
		if (self.flashlight_lit) {
		if ((self.watertype == CONTENT_LAVA) && self.waterlevel > 2) {
			self.flashlight_lit = 0;
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your flashlight was damaged\n");
			}
		} else {
			self.flashlightlight.flashlight_lit = 1;
		}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_flashlight.md3");
		precache_model ("models/weapons/v_flashlight.md3");
		precache_model ("models/weapons/h_flashlight.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/flashlight_fire.wav");
		precache_sound ("weapons/flashlight_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_FLASHLIGHT);
		self.current_ammo = ammo_none;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.flashlight_lit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.flashlight_lit = 0;	
	}
	else if (req == WR_GONETHINK)
	{
		//We lost the weapon
		self.flashlight_lit = 0;
			
	}
	else if (req == WR_DROP)
	{
		//We dropped the weapon
		//print("drop\n");
		self.flashlight_lit = 0;
	}
	else if (req == WR_RELOAD)
	{
		if not(self.flashlight_lit) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_flashlight_reload_time, w_ready);
			self.flashlight_lit = 1;
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You turn on the flashlight\n");
			}
			flashlight_spawnlight();
			
		} else {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_flashlight_reload_time, w_ready);
			self.flashlight_lit = 0;
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You turn off the flashlight\n");
			}
			
			if (self.BUTTON_USE) {
				if ((self.BUTTON_CROUCH) || (self.BUTTON_JUMP)) {
					if (self.flashlight_changefocus == 1) {
						self.flashlight_changefocus = 0;
					} else {
						self.flashlight_changefocus = 1;
					}
					
					if ((clienttype(self) == CLIENTTYPE_REAL)) {
						sprint(self, "You change the focus of the flashlight\n");
					}
				} else {
					if (self.flashlight_changecolor == 2) {
						self.flashlight_changecolor = 0;
					} else if (self.flashlight_changecolor == 1) {
						self.flashlight_changecolor = 2;
					} else {
						self.flashlight_changecolor = 1;
					}
				}
			}
		}

	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_flashlight(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if not(w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was beaten to death with %s's flashlight");
		} else {
			w_deathtypestring = _("%s was burned to death with %s's flashlight");
		}
	}
	return TRUE;
}
#endif
#endif
