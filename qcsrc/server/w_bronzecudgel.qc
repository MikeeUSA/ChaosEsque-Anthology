#ifdef REGISTER_WEAPON
REGISTER_WEAPON(BRONZECUDGEL, w_bronzecudgel, IT_NAILS, 2, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "bronzecudgel", "bronzecudgel", _("Bronze Cudgel"))
#else
#ifdef SVQC

.float bronzecudgel_release;
.float bronzecudgel_secondary;

.float swing_prev;
.entity swing_alreadyhit;

void bronzecudgel_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
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
	f = ((1 - swing) * autocvar_g_balance_bronzecudgel_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_bronzecudgel_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_bronzecudgel_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_bronzecudgel_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_bronzecudgel_primary_melee_swing_side));

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
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (wprimary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (wmelee_nonplayerdamage * min(1, swing_factor + 1));
			
			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));
			float d;
			float t;
				if (is_player) swing_damage = W_CritHitCalc_Mace(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_BRONZECUDGEL);
			d = target_victim.armorvalue;
			t = target_victim.armortype;
			target_victim.armorvalue = 0; //BronzeCudgel pierces and crushes armor
			
			if (d > 50) {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_BRONZECUDGEL | HITTYPE_SECONDARY, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_bronzecudgel_primary_force);
			} else {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_BRONZECUDGEL, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_bronzecudgel_primary_force);
			}
			
			target_victim.armorvalue = d; //Damage done, give back armor
			target_victim.armortype = t;  //Just incase it was removed due to value being 0
			
			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_BRONZECUDGEL, 0, swing_damage); }
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_bronzecudgel_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void bronzecudgel_primarythink (void)
{
	bronzecudgel_meleethink(
		autocvar_g_balance_bronzecudgel_primary_melee_time,
		autocvar_g_balance_bronzecudgel_primary_melee_range,
		autocvar_g_balance_bronzecudgel_primary_damage,
		autocvar_g_balance_bronzecudgel_primary_melee_nonplayerdamage
		);
}

void bronzecudgel_secondarythink (void)
{
	bronzecudgel_meleethink(
		autocvar_g_balance_bronzecudgel_secondary_melee_time,
		autocvar_g_balance_bronzecudgel_secondary_melee_range,
		autocvar_g_balance_bronzecudgel_secondary_damage,
		autocvar_g_balance_bronzecudgel_secondary_melee_nonplayerdamage
		);
}

void W_BronzeCudgelspiked_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/warhammerspiked_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.bronzecudgel_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_bronzecudgel_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_bronzecudgel_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 6.5; //_Very_ Heavy
	
	if(self.bronzecudgel_secondary == 1) {
		self.melee_temp_starttime = time + autocvar_g_balance_bronzecudgel_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_bronzecudgel_secondary_melee_time;
	   meleetemp.think = bronzecudgel_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_bronzecudgel_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_bronzecudgel_secondary_damage, autocvar_g_balance_bronzecudgel_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_bronzecudgel_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_bronzecudgel_primary_melee_time;
	   meleetemp.think = bronzecudgel_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_bronzecudgel_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_bronzecudgel_primary_damage, autocvar_g_balance_bronzecudgel_primary_melee_range);
	}
}

void spawnfunc_weapon_bronzecudgel (void)
{
	weapon_defaultspawnfunc(WEP_BRONZECUDGEL);
}

.float bronzecudgel_primarytime;

float w_bronzecudgel(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_bronzecudgel_primary_melee_range)
		&& (self.bronzecudgel_release)) {
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
		if (self.bronzecudgel_release)
		if (weapon_prepareattack(1, autocvar_g_balance_bronzecudgel_primary_refire))
		{
			self.bronzecudgel_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_BronzeCudgelspiked_Attack);
			self.bronzecudgel_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.bronzecudgel_release)
		if (weapon_prepareattack(1, autocvar_g_balance_bronzecudgel_secondary_refire))
		{
			self.bronzecudgel_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_BronzeCudgelspiked_Attack);
			self.bronzecudgel_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.bronzecudgel_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_bronzecudgel.md3");
		precache_model ("models/weapons/v_bronzecudgel.md3");
		precache_model ("models/weapons/h_bronzecudgel.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/bronzecudgel_fire.wav");
		precache_sound ("weapons/warhammerspiked_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_BRONZECUDGEL);
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
float w_bronzecudgel(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was smashed in his armor with %s's bronzecudgel");
		} else {
			w_deathtypestring = _("%s was crushed to dust with %s's bronzecudgel");
		}
	}
	return TRUE;
}
#endif
#endif
