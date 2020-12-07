#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LIGHTSABREIV, w_lightsabreiv, IT_NAILS, 8, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "lightsabreiv_off", "lightsabreiv", _("LightsabreIV"))
#else
#ifdef SVQC
.float lightsabreiv_lit;
.float lightsabreiv_release;
.float lightsabreiv_secondary;
.entity lightsabreivlight;
.float lightsabreiv_didsteamsnd;
.float lightsabreiv_nextsteam;

.float swing_prev;
.entity swing_alreadyhit;
void Foliage_Fall();

void lightsabreiv_thinklight() {
	if (self.owner.lightsabreiv_lit == 1 && self.lightsabreiv_lit == 1 && self.owner.health > 0) {
		
		makevectors(self.owner.v_angle);
		setorigin(self, ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *16)));
		self.nextthink = time;
		self.lightsabreiv_lit = 0;
		if (random() < 0.5) {
			Chemical_flash_maybe_at(self.origin, self.owner);
		}
	} else {
		remove(self);
	}
}

void lightsabreiv_spawnlight() {
	local entity newlightsabreivlight;
	newlightsabreivlight = spawn();
	newlightsabreivlight.pflags = PFLAGS_FULLDYNAMIC;
	//newlightsabreivlight.light_lev = 256;
	newlightsabreivlight.light_lev = 64;
	newlightsabreivlight.color = '0 1 0';
	newlightsabreivlight.style = 0;
	newlightsabreivlight.owner = self;
	newlightsabreivlight.think = lightsabreiv_thinklight;
	newlightsabreivlight.nextthink = time;
	newlightsabreivlight.lightsabreiv_lit = 1;
	self.lightsabreivlight = newlightsabreivlight;
}

void lightsabreiv_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
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
	f = ((1 - swing) * autocvar_g_balance_lightsabreiv_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_lightsabreiv_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_lightsabreiv_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_lightsabreiv_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_lightsabreiv_primary_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));
		
		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5); 
		//te_customflash(targpos, 40,  2, '1 1 1');
		
		is_player = isPlayerOrMonsterByClassname(trace_ent);
		
		float svgorelvl;
		svgorelvl = autocvar_g_balance_melee_gorelvl;
		
		if (is_player)
		{
			if (melee_check_collision(self.realowner, trace_ent))
			{
				if(trace_ent.melee_temp && !self.meleeotherpassesthrough) remove(trace_ent.melee_temp);
				remove(self);
				return;	
			}
		}
		
		entity oldself;
		if (is_player && !(autocvar_g_balance_lightsabreiv_noblood) && (trace_ent.armorvalue < 50)) {
			//print(etos(trace_ent),  etos(self.realowner)," fs\n");
			//print(ftos(trace_ent.armorvalue)," armor\n");
			Damage_DamageInfo(targpos, 150, 150, 0, v_forward * 100, WEP_LIGHTSABREIV, trace_ent.species, self.realowner);
			
			//print("AAblood\n");
		}
		
		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM || trace_ent.classname == "tree" || trace_ent.classname == "bush")  
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || wmelee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (wprimary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (wmelee_nonplayerdamage * min(1, swing_factor + 1));
			
			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));
			if (target_victim.classname == "tree") 
			{
				swing_damage = swing_damage * autocvar_g_balance_lightsabreiv_damagerate_tree;
			
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					pointparticles(particleeffectnum("smoke_big"), target_victim.origin + '0 0 1', '0 0 0', 1);

					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + target_victim.multitool_ammocurrent;
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
				} else {
					pointparticles(particleeffectnum("smoke_small"), target_victim.origin + '0 0 1', '0 0 0', 1);
				}
				
				Fire_AddDamage(target_victim, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, WEP_LIGHTSABREIV);
				
				if (random() > 0.5) {
					spamsound (target_victim, CH_PAIN, "machines/electrifiedhit2.wav", VOL_BASE * 0.50, ATTN_NORM);
				} else {
					spamsound (target_victim, CH_PAIN, "machines/electrifiedhit3.wav", VOL_BASE * 0.50, ATTN_NORM);
				}
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));

			}
			else if (target_victim.classname == "bush")
			{
				//Sharp and thin, so can cut bushes easily
				swing_damage = swing_damage * autocvar_g_balance_lightsabreiv_damagerate_bush;
				
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					pointparticles(particleeffectnum("smoke_big"), target_victim.origin + '0 0 1', '0 0 0', 1);

					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + 1; //Bushes pay very little
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
				}
				
				//Fire_AddDamage(target_victim, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, WEP_LIGHTSABREIV);
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
			}
			else
			{
			
				float d;
				float t;
				if (is_player) swing_damage = W_CritHitCalc_LightSabre(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_LIGHTSABREIV);
				
				d = target_victim.armorvalue;
				t = target_victim.armortype;
				target_victim.armorvalue = d * 1.2; //LightSabreIV isn't fazed much by armor
			
				//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
				if (d > 25) {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.025, swing_damage - (d * 0.75), swing_damage), WEP_LIGHTSABREIV | HITTYPE_SECONDARY, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_lightsabreiv_primary_force);
				} else {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.05, swing_damage - (d * 0.50), swing_damage), WEP_LIGHTSABREIV, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_lightsabreiv_primary_force);
				}
			
				if ((is_player) && !(autocvar_g_balance_lightsabreiv_noblood) && (d < 25)) {
					//print("blood\n");
					Damage_DamageInfo(targpos, swing_damage, swing_damage, 0, v_forward * 100, WEP_LIGHTSABREIV, trace_ent.species, self.realowner);

				}
			
				target_victim.armorvalue = d; //Damage done, reset armor
				target_victim.armortype = t;  //Just incase it was removed
			
				if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_LIGHTSABREIV, 0, swing_damage); }
			}
			
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_lightsabreiv_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void lightsabreiv_primarythink (void)
{
	lightsabreiv_meleethink(
		autocvar_g_balance_lightsabreiv_primary_melee_time,
		autocvar_g_balance_lightsabreiv_primary_melee_range,
		autocvar_g_balance_lightsabreiv_primary_damage,
		autocvar_g_balance_lightsabreiv_primary_melee_nonplayerdamage
		);
}

void lightsabreiv_secondarythink (void)
{
	lightsabreiv_meleethink(
		autocvar_g_balance_lightsabreiv_secondary_melee_time,
		autocvar_g_balance_lightsabreiv_secondary_melee_range,
		autocvar_g_balance_lightsabreiv_secondary_damage,
		autocvar_g_balance_lightsabreiv_secondary_melee_nonplayerdamage
		);
}

void W_LightSabreIVspiked_Attack (void)
{
	if (random() > 0.4) {
		sound (self, CH_WEAPON_A, "machines/Jacobs_Ladder-FastReverse.wav", VOL_BASE, ATTN_NORM);
	} else {
		sound (self, CH_WEAPON_A, "machines/Jacobs_Ladder-Fast.wav", VOL_BASE, ATTN_NORM);
	}
	
	if(self.lightsabreiv_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightsabreiv_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_lightsabreiv_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 104; //Cuts through most things //LightX is on a diff level than material weaps
	
	if(self.lightsabreiv_secondary == 1) {
		self.melee_temp_starttime = time + autocvar_g_balance_lightsabreiv_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_lightsabreiv_secondary_melee_time;
	   meleetemp.think = lightsabreiv_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_lightsabreiv_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_lightsabreiv_secondary_damage, autocvar_g_balance_lightsabreiv_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_lightsabreiv_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_lightsabreiv_primary_melee_time;
	   meleetemp.think = lightsabreiv_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_lightsabreiv_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_lightsabreiv_primary_damage, autocvar_g_balance_lightsabreiv_primary_melee_range);
	}
}


void spawnfunc_weapon_lightsabreiv (void)
{
	weapon_defaultspawnfunc(WEP_LIGHTSABREIV);
}

.float lightsabreiv_primarytime;

float w_lightsabreiv(float req)
{
	if (req == WR_AIM) {
		if (!self.lightsabreiv_lit) { weapon_action(self.weapon, WR_RELOAD); } // bot lightsabreiv not lit
	
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_lightsabreiv_primary_melee_range)
		&& (self.lightsabreiv_release)) {
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
		if (self.lightsabreiv_release)
		if (weapon_prepareattack(1, autocvar_g_balance_lightsabreiv_primary_refire))
		{
			self.lightsabreiv_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			if (self.lightsabreiv_lit) {
				weapon_thinkf(WFRAME_FIRE1, 0, W_LightSabreIVspiked_Attack);
			} else {
				weapon_thinkf(WFRAME_FIRE1, 0, W_Flashlight_Attack);
			}
			self.lightsabreiv_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.lightsabreiv_release)
		if (weapon_prepareattack(1, autocvar_g_balance_lightsabreiv_secondary_refire))
		{
			self.lightsabreiv_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			if (self.lightsabreiv_lit) {
				weapon_thinkf(WFRAME_FIRE1, 0, W_LightSabreIVspiked_Attack);
			} else {
				weapon_thinkf(WFRAME_FIRE1, 0, W_Flashlight_Attack);
			}
			self.lightsabreiv_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.lightsabreiv_release = 1;
		}
		
		if (self.lightsabreiv_lit) {
			self.lightsabreivlight.lightsabreiv_lit = 1;
			if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
				if (time > self.lightsabreiv_nextsteam) {
					
					local vector my_origintouse = self.lightsabreivlight.origin;
					local float r;
					
					pointparticles(particleeffectnum("impact_metal"), my_origintouse, '0 0 0', 1);
					pointparticles(particleeffectnum("gauntlet_lightning"), my_origintouse+(randomvec()*10), '0 0 0', 1);
					pointparticles(particleeffectnum("impact_metal"), my_origintouse+(randomvec()*10), '0 0 10', 10);
					pointparticles(particleeffectnum("gauntlet_lightning"), my_origintouse+(randomvec()*10), '0 0 0', 1);
					pointparticles(particleeffectnum("impact_metal"), my_origintouse+(randomvec()*10), '0 0 1', 10);

					r = random() * 3;
					if (r > 2) {
						spamsound (self, CH_PAIN, "machines/electrifiedhit1.wav", VOL_BASE, ATTN_NORM);
					} else if (r > 1) {
						spamsound (self, CH_PAIN, "machines/electrifiedhit2.wav", VOL_BASE, ATTN_NORM);
					} else {	
						spamsound (self, CH_PAIN, "machines/electrifiedhit3.wav", VOL_BASE, ATTN_NORM);
					}
					
					self.lightsabreiv_nextsteam = time + 0.05 + (random()*0.3);
					if (!self.lightsabreiv_didsteamsnd) {
						pointparticles(particleeffectnum("smoke_big"), my_origintouse + '0 0 2', '0 0 30', 10);
						spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
						self.lightsabreiv_didsteamsnd = 1;
					}
				}
			} else if (self.lightsabreiv_didsteamsnd) {
				self.lightsabreiv_didsteamsnd = 0;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_lightsabreiv.md3");
		precache_model ("models/weapons/v_lightsabreiv.md3");
		precache_model ("models/weapons/h_lightsabreiv.iqm");
		precache_model ("models/weapons/g_lightsabreiv_off.md3");
		precache_model ("models/weapons/v_lightsabreiv_off.md3");
		precache_model ("models/weapons/h_lightsabreiv_off.iqm");
		//precache_sound ("misc/itempickup.wav");
		precache_sound ("machines/Jacobs_Ladder-FastReverse.wav");
		precache_sound ("machines/Jacobs_Ladder-Fast.wav");
		//precache_sound ("weapons/lightsabreiv_melee.wav");
		precache_sound ("machines/electrifiedhit1.wav");
		precache_sound ("machines/electrifiedhit2.wav");
		precache_sound ("machines/electrifiedhit3.wav");
		precache_sound ("machines/electrifiedon.wav");
		precache_sound ("machines/electrifiedoff.wav");
		precache_sound ("machines/steam_fade.ogg");
		precache_sound ("object/impact_wood_4.ogg");
		precache_sound ("object/impact_wood_5.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LIGHTSABREIV);
		self.current_ammo = ammo_none;
		self.lightsabreiv_lit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if not(self.lightsabreiv_lit) {
			weapon_thinkf(WFRAME_RELOAD, 0.4, w_ready);
			self.lightsabreiv_lit = 1;
			self.weaponname = "lightsabreiv";
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				spamsound (self, CH_WEAPON_A, "machines/electrifiedon.wav", VOL_BASE, ATTN_NORM);
				sprint(self, "You lit the lightsabre\n");
			}
			lightsabreiv_spawnlight();
			
		} else {
			weapon_thinkf(WFRAME_RELOAD, 0.4, w_ready);
			self.lightsabreiv_lit = 0;
			self.weaponname = "lightsabreiv_off";
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				spamsound (self, CH_WEAPON_A, "machines/electrifiedoff.wav", VOL_BASE, ATTN_NORM);
				sprint(self, "You extinguish the lightsabre\n");
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_lightsabreiv(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was cut down despite his armor by %s's sabre of light");
		} else {
			w_deathtypestring = _("%s was cut down by %s's sabre of light");
		}
	}
	return TRUE;
}
#endif
#endif
