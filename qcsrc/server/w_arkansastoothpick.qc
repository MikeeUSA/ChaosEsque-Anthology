#ifdef REGISTER_WEAPON
REGISTER_WEAPON(ARKANSASTOOTHPICK, w_arkansastoothpick, IT_NAILS, 7, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "arkansastoothpick", "arkansastoothpick", _("Arkansas Toothpick"))
#else
#ifdef SVQC

.float arkansastoothpick_release;
.float arkansastoothpick_secondary;

.float swing_prev;
.entity swing_alreadyhit;
void Foliage_Fall();

void arkansastoothpick_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage, float wmelee_issecondary)
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
	f = ((1 - swing) * autocvar_g_balance_arkansastoothpick_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_arkansastoothpick_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_arkansastoothpick_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_arkansastoothpick_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_arkansastoothpick_primary_melee_swing_side));

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
		if (wmelee_issecondary)
		if (is_player && !(autocvar_g_balance_arkansastoothpick_noblood) && (trace_ent.armorvalue < 50)) {
			//print(etos(trace_ent),  etos(self.realowner)," fs\n");
			//print(ftos(trace_ent.armorvalue)," armor\n");
			Damage_DamageInfo(targpos, 150, 150, 0, v_forward * 100, WEP_ARKANSASTOOTHPICK, trace_ent.species, self.realowner);
			
			oldself = self;
			self = trace_ent;
			
			if (trace_ent.armorvalue < 15) {
			if (svgorelvl) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 100, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 1) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 50, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 10, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			}
			
			if (trace_ent.armorvalue < 35) {
			if (svgorelvl > 1) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 100, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 50, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 10, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), targpos, 2, 100, trace_ent, oldself.realowner);
			}
			
			self = oldself;
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
				swing_damage = swing_damage * autocvar_g_balance_arkansastoothpick_damagerate_tree;
			
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + target_victim.multitool_ammocurrent;
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
				} else {
					if (random() > 0.5) {
						spamsound (target_victim, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE * 0.15, ATTN_NORM);
					} else {
						spamsound (target_victim, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE * 0.15, ATTN_NORM);
					}
				}
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));

			}
			else if (target_victim.classname == "bush")
			{
				//Sharp and thin, so can cut bushes easily
				swing_damage = swing_damage * autocvar_g_balance_arkansastoothpick_damagerate_bush;
				
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + 1; //Bushes pay very little
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
				}
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
			}
			else
			{
			
				float d;
				float t;
				if (is_player){
					if (wmelee_issecondary)
						swing_damage = W_CritHitCalc_Knife(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_ARKANSASTOOTHPICK);
					else
						swing_damage = W_CritHitCalc_Spear(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_ARKANSASTOOTHPICK);
				}
				d = target_victim.armorvalue;
				t = target_victim.armortype;
				
				if (wmelee_issecondary) {
					target_victim.armorvalue = d * 22; //ArkansasToothpick secondary (swing) doesn't do well against armor at all
			
					//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
					if (d > 25) {
						Damage(target_victim, self.realowner, self.realowner, 
						bound(swing_damage * 0.025, swing_damage - (d * 0.75), swing_damage), WEP_ARKANSASTOOTHPICK | HITTYPE_SECONDARY, 
						self.realowner.origin + self.realowner.view_ofs, 
						v_forward * autocvar_g_balance_arkansastoothpick_primary_force);
					} else {
						Damage(target_victim, self.realowner, self.realowner, 
						bound(swing_damage * 0.05, swing_damage - (d * 0.50), swing_damage), WEP_ARKANSASTOOTHPICK | HITTYPE_SECONDARY, 
						self.realowner.origin + self.realowner.view_ofs, 
						v_forward * autocvar_g_balance_arkansastoothpick_primary_force);
					}
				} else {
					target_victim.armorvalue = d * 2; //ArkansasToothpick primary (thrust) can pierce some armor
			
					//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
					if (d > 25) {
						Damage(target_victim, self.realowner, self.realowner, 
						bound(swing_damage * 0.05, swing_damage - (d * 0.95), swing_damage), WEP_ARKANSASTOOTHPICK, 
						self.realowner.origin + self.realowner.view_ofs, 
						v_forward * autocvar_g_balance_arkansastoothpick_primary_force);
					} else {
						Damage(target_victim, self.realowner, self.realowner, 
						bound(swing_damage * 0.1, swing_damage - (d * 0.75), swing_damage), WEP_ARKANSASTOOTHPICK, 
						self.realowner.origin + self.realowner.view_ofs, 
						v_forward * autocvar_g_balance_arkansastoothpick_primary_force);
					}	
				}
			
				if ((is_player) && !(autocvar_g_balance_arkansastoothpick_noblood) && (d < 25)) {
					//print("blood\n");
					Damage_DamageInfo(targpos, swing_damage, swing_damage, 0, v_forward * 100, WEP_ARKANSASTOOTHPICK, trace_ent.species, self.realowner);
					
					if (wmelee_issecondary)
					{
						oldself = self;
						self = target_victim;
						if (target_victim.armorvalue < 15)
							if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
				
						if (target_victim.armorvalue < 35)
							if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
						
						self = oldself;
					}
				}
			
				target_victim.armorvalue = d; //Damage done, reset armor
				target_victim.armortype = t;  //Just incase it was removed
			
				if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_ARKANSASTOOTHPICK, 0, swing_damage); }
			}
			
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_arkansastoothpick_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void arkansastoothpick_primarythink (void)
{
	arkansastoothpick_meleethink(
		autocvar_g_balance_arkansastoothpick_primary_melee_time,
		autocvar_g_balance_arkansastoothpick_primary_melee_range,
		autocvar_g_balance_arkansastoothpick_primary_damage,
		autocvar_g_balance_arkansastoothpick_primary_melee_nonplayerdamage,
		0);
}

void arkansastoothpick_secondarythink (void)
{
	arkansastoothpick_meleethink(
		autocvar_g_balance_arkansastoothpick_secondary_melee_time,
		autocvar_g_balance_arkansastoothpick_secondary_melee_range,
		autocvar_g_balance_arkansastoothpick_secondary_damage,
		autocvar_g_balance_arkansastoothpick_secondary_melee_nonplayerdamage,
		1);
}

void W_ArkansasToothpickspiked_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/arkansastoothpick_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.arkansastoothpick_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_arkansastoothpick_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_arkansastoothpick_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 1;
	
	if(self.arkansastoothpick_secondary == 1) {
	 	self.melee_temp_starttime = time + autocvar_g_balance_arkansastoothpick_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_arkansastoothpick_secondary_melee_time;
	   
	   meleetemp.think = arkansastoothpick_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_arkansastoothpick_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_arkansastoothpick_secondary_damage, autocvar_g_balance_arkansastoothpick_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_arkansastoothpick_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_arkansastoothpick_primary_melee_time;
	   meleetemp.think = arkansastoothpick_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_arkansastoothpick_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_arkansastoothpick_primary_damage, autocvar_g_balance_arkansastoothpick_primary_melee_range);
	}
}


void spawnfunc_weapon_arkansastoothpick (void)
{
	weapon_defaultspawnfunc(WEP_ARKANSASTOOTHPICK);
}

.float arkansastoothpick_primarytime;

float w_arkansastoothpick(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_arkansastoothpick_primary_melee_range)
		&& (self.arkansastoothpick_release)) {
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
		if (self.arkansastoothpick_release)
		if (weapon_prepareattack(1, autocvar_g_balance_arkansastoothpick_primary_refire))
		{
			self.arkansastoothpick_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_ArkansasToothpickspiked_Attack);
			self.arkansastoothpick_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.arkansastoothpick_release)
		if (weapon_prepareattack(1, autocvar_g_balance_arkansastoothpick_secondary_refire))
		{
			self.arkansastoothpick_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_ArkansasToothpickspiked_Attack);
			self.arkansastoothpick_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.arkansastoothpick_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_arkansastoothpick.md3");
		precache_model ("models/weapons/v_arkansastoothpick.md3");
		precache_model ("models/weapons/h_arkansastoothpick.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/arkansastoothpick_fire.wav");
		precache_sound ("weapons/arkansastoothpick_melee.wav");
		precache_sound ("object/impact_wood_4.ogg");
		precache_sound ("object/impact_wood_5.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_ARKANSASTOOTHPICK);
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
float w_arkansastoothpick(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s hide got tanned by %s's arkansas toothpick");
		} else {
			w_deathtypestring = _("%s got dun gud by %s's arkansas toothpick");
		}
	}
	return TRUE;
}
#endif
#endif
