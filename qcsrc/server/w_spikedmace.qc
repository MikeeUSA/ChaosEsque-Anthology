#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SPIKEDMACE, w_spikedmace, IT_NAILS, 4, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "spikedmace", "spikedmace", _("Spiked Mace"))
#else
#ifdef SVQC

.float spikedmace_release;
.float spikedmace_secondary;

void spikedmace_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage, float wspike_damage)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;
	
	float svgorelvl;
	svgorelvl = autocvar_g_balance_melee_gorelvl;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time; 
		W_PlayStrengthSound(self.realowner);
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors
	
	// calculate swing percentage based on time
	meleetime = wmelee_time * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_balance_spikedmace_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_spikedmace_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_spikedmace_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_spikedmace_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_spikedmace_primary_melee_swing_side));

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
		
		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM)  
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || wmelee_nonplayerdamage))
		{
			target_victim = trace_ent; // so it persists through other calls
			
			entity oldself;
			
			float d;
			float t;
				if (is_player) swing_damage = W_CritHitCalc_Mace(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_SPIKEDMACE);
			////////////////////
			if((is_player) && (target_victim.armorvalue < 100))
			{
				swing_damage = (wspike_damage * min(1, swing_factor + 1));
			
				d = target_victim.armorvalue;
				t = target_victim.armortype;
				target_victim.armorvalue = d * 16; //spikes are good vs flesh
			
				//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
				if (d > 50) {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.05, swing_damage - (d * 0.75), swing_damage), WEP_SPIKEDMACE | HITTYPE_SECONDARY, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_spikedmace_primary_force);
				} else {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.1, swing_damage - (d * 0.50), swing_damage), WEP_SPIKEDMACE | HITTYPE_SECONDARY, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_spikedmace_primary_force);
				}
			
				if ((is_player) && !(autocvar_g_balance_spikedmace_noblood) && (d < 50)) {
					//print("blood\n");
					Damage_DamageInfo(targpos, swing_damage, swing_damage, 0, v_forward * 100, WEP_SHORTSWORD, trace_ent.species, self.realowner);

					oldself = self;
					self = target_victim;
					if (target_victim.armorvalue < 15)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -102', 2, swing_damage, target_victim, self.realowner);
				
					if (target_victim.armorvalue < 25)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -103', 2, swing_damage, target_victim, self.realowner);
				
					if (target_victim.armorvalue < 35)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -104', 2, swing_damage, target_victim, self.realowner);
				
					if (target_victim.armorvalue < 45)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -105', 2, swing_damage, target_victim, self.realowner);
					self = oldself;
				}
			
				target_victim.armorvalue = d; //Damage done, reset armor
				target_victim.armortype = t;  //Just incase it was removed
			}
			////////////////////
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (wprimary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (wmelee_nonplayerdamage * min(1, swing_factor + 1));
			
			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));
			d = target_victim.armorvalue;
			t = target_victim.armortype;
			target_victim.armorvalue = 0; //Warhammer pierces and crushes armor
			
			if (d > 50) {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_SPIKEDMACE, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_spikedmace_primary_force);
			} else {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_SPIKEDMACE, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_spikedmace_primary_force);
			}
			
			target_victim.armorvalue = d; //Damage done, give back armor
			target_victim.armortype = t;  //Just incase it was removed due to value being 0
			
			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_SPIKEDMACE, 0, swing_damage); }
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_spikedmace_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void spikedmace_primarythink (void)
{
	spikedmace_meleethink(
		autocvar_g_balance_spikedmace_primary_melee_time,
		autocvar_g_balance_spikedmace_primary_melee_range,
		autocvar_g_balance_spikedmace_primary_damage,
		autocvar_g_balance_spikedmace_primary_melee_nonplayerdamage,
		autocvar_g_balance_spikedmace_primary_spikedamage
		);
}

void spikedmace_secondarythink (void)
{
	spikedmace_meleethink(
		autocvar_g_balance_spikedmace_secondary_melee_time,
		autocvar_g_balance_spikedmace_secondary_melee_range,
		autocvar_g_balance_spikedmace_secondary_damage,
		autocvar_g_balance_spikedmace_secondary_melee_nonplayerdamage,
		autocvar_g_balance_spikedmace_secondary_spikedamage
		);
}

void W_SpikedMace_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/spikedmace_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.spikedmace_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_spikedmace_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_spikedmace_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 3;
	
	if(self.spikedmace_secondary == 1) {
		self.melee_temp_starttime = time + autocvar_g_balance_spikedmace_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_spikedmace_secondary_melee_time;
	   meleetemp.think = spikedmace_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_spikedmace_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_spikedmace_secondary_damage, autocvar_g_balance_spikedmace_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_spikedmace_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_spikedmace_primary_melee_time;
	   meleetemp.think = spikedmace_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_spikedmace_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_spikedmace_primary_damage, autocvar_g_balance_spikedmace_primary_melee_range);
	}
}

void spawnfunc_weapon_spikedmace (void)
{
	weapon_defaultspawnfunc(WEP_SPIKEDMACE);
}

.float spikedmace_primarytime;

float w_spikedmace(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_spikedmace_primary_melee_range)
		&& (self.spikedmace_release)) {
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
		if (self.spikedmace_release)
		if (weapon_prepareattack(1, autocvar_g_balance_spikedmace_primary_refire))
		{
			self.spikedmace_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_SpikedMace_Attack);
			self.spikedmace_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.spikedmace_release)
		if (weapon_prepareattack(1, autocvar_g_balance_spikedmace_secondary_refire))
		{
			self.spikedmace_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_SpikedMace_Attack);
			self.spikedmace_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.spikedmace_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_spikedmace.md3");
		precache_model ("models/weapons/v_spikedmace.md3");
		precache_model ("models/weapons/h_spikedmace.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/spikedmace_fire.wav");
		precache_sound ("weapons/spikedmace_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_SPIKEDMACE);
		self.current_ammo = ammo_none;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// melee attack is always available
		return TRUE;
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_spikedmace(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was gored by %s's spiked mace");
		} else {
			w_deathtypestring = _("%s was beaten to death by %s's spiked mace");
		}
	}
	return TRUE;
}
#endif
#endif
