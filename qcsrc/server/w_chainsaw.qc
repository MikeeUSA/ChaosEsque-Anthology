#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CHAINSAW, w_chainsaw, IT_FUEL, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE , BOT_PICKUP_RATING_LOW, "chainsaw", "chainsaw", _("Chainsaw"))
#else
#ifdef SVQC

.float chainsaw_release;
.float chainsaw_jammed;
.float chainsaw_unjam;
.float chainsaw_unjam_time;
.float chainsaw_bladestime;
.float chainsaw_secondary;
.float chainsaw_primaryon;

.float swing_prev;
.entity swing_alreadyhit;
void Foliage_Fall();

void chainsaw_precachechoppingwoodsounds()
{
	precache_sound ("machines/generator_loop_speedup_chorus.ogg");
	//Skippin _01
	precache_sound ("resource/lumbering/lumber_treeexpire_02.ogg");
	precache_sound ("resource/lumbering/lumber_treeexpire_03.ogg");
	precache_sound ("resource/lumbering/lumber_treeexpire_04.ogg");
}

void chainsaw_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage, float wmelee_issawing, float wmelee_issecondary)
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
	f = ((1 - swing) * autocvar_g_balance_chainsaw_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_chainsaw_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_chainsaw_primary_melee_traces)) * 2 - 1);
		
		if (wmelee_issecondary) {
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_chainsaw_secondary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_chainsaw_secondary_melee_swing_side));
		
		} else {
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_chainsaw_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_chainsaw_primary_melee_swing_side));
		}

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));
		
		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5); 
		//te_customflash(targpos, 40,  2, '1 1 1');
		
		is_player = isPlayerOrMonsterByClassname(trace_ent);
		
		entity oldself;
		
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
		
		//print(ftos(wmelee_issawing),"\n");
		
		if (wmelee_issawing) {
		  //We have fuel and our saw is turned on (first mouse button)
		  if (is_player && !(autocvar_g_balance_chainsaw_noblood) && (trace_ent.armorvalue < 50)) {
		  	//Yes using broadaxe as the "damage type" for this blood visual is intentional
			//This doesn't do damage here, it's just a visual, our saw is on so we want lot of blood
			//But when it's off we don't. Thus we use broadaxe visual only when it's on
			//And only our own dmgtype in other cases.
			//print(etos(trace_ent),  etos(self.realowner)," fs\n");
			//print(ftos(trace_ent.armorvalue)," armor\n");

			Damage_DamageInfo(targpos, 150, 150, 0, v_forward * 100, WEP_BROADAXE, trace_ent.species, self.realowner);
			
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
			
			if (trace_ent.armorvalue < 25) {
			if (svgorelvl > 1) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 100, 2, 100, trace_ent, oldself.realowner);
			if (svgorelvl > 2) Violence_GibSplash_At(targpos + ('2 2 2' * (random() - 0.5)), v_forward * 50, 2, 100, trace_ent, oldself.realowner);
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
			
			if (trace_ent.armorvalue < 45) {
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
		}
		
		if((trace_fraction < 1) // if trace is good, apply the damage and remove self
			&& (trace_ent.takedamage == DAMAGE_AIM || trace_ent.classname == "tree" || trace_ent.classname == "building" || trace_ent.accptlikebuilding)  
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
			   if (wmelee_issawing) {
				swing_damage = swing_damage * autocvar_g_balance_chainsaw_damagerate_tree;
			
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + target_victim.multitool_ammocurrent;
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
					broadaxe_spamtreefallsound(target_victim); //We'll do it here rather than in Foliage_Fall, these sounds just for axe fellings (not explosion destruction of trees etc)
				} else {
					if (random() > 0.5) {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE * 0.85, ATTN_NORM);
					} else {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE * 0.85, ATTN_NORM);
					}
				}
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
			  }
			} else if ((target_victim.classname == "building" || target_victim.accptlikebuilding) && !target_victim.multitool_isscaffold) 
			{
			   if (wmelee_issawing) {
				////swing_damage = swing_damage * autocvar_g_balance_chainsaw_damagerate_tree;
			
				if (target_victim.multitool_hitbox != world) {
				 if (multitool_chainsawcandamage(target_victim.multitool_hitbox.count)) {				
					Damage(target_victim.multitool_hitbox, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage, swing_damage), WEP_CHAINSAW, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_chainsaw_primary_force);
					
					if (random() > 0.5) {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE, ATTN_NORM);
					} else {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE, ATTN_NORM);
					}
				 }
				} else if (target_victim.multitool_doorframeent && target_victim.multitool_doorframeent.multitool_hitbox != world) {
				 //Built Door slabs
				 if (multitool_chainsawcandamage(target_victim.multitool_doorframeent.multitool_hitbox.count)) {				
					Damage(target_victim.multitool_doorframeent.multitool_hitbox, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage, swing_damage), WEP_CHAINSAW, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_chainsaw_primary_force);
					
					if (random() > 0.5) {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE, ATTN_NORM);
					} else {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE, ATTN_NORM);
					}
				 }
				} 
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
			  }
			}
			else
			{
				float d;
				float t;
				if (is_player) {
					swing_damage = W_CritHitCalc_Sword(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_CHAINSAW);
				}
				d = target_victim.armorvalue;
				t = target_victim.armortype;
				target_victim.armorvalue = d * 4; //ChainSaw doesn't do as well against armor
			
				//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
				if (d > 50) {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.1, swing_damage - (d * 0.50), swing_damage), WEP_CHAINSAW | HITTYPE_SECONDARY, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_chainsaw_primary_force);
				} else {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage - (d * 0.25), swing_damage), WEP_CHAINSAW, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_chainsaw_primary_force);
				}
			
				if ((is_player) && !(autocvar_g_balance_chainsaw_noblood) && (d < 50)) {
					//print("blood\n");
					Damage_DamageInfo(targpos, swing_damage, swing_damage, 0, v_forward * 100, WEP_CHAINSAW, trace_ent.species, self.realowner);
	
					oldself = self;
					self = target_victim;
					if (target_victim.armorvalue < 15) {
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
					}
					
					if (target_victim.armorvalue < 25) {
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
					}
					
					if (target_victim.armorvalue < 35)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
				
					if (target_victim.armorvalue < 45)
						if (svgorelvl > 2) Violence_GibSplash_At(targpos, v_forward + '0 0 -100', 2, swing_damage, target_victim, self.realowner);
					self = oldself;
				}
			
				target_victim.armorvalue = d; //Damage done, reset armor
				target_victim.armortype = t;  //Just incase it was removed
			
				if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_CHAINSAW, 0, swing_damage); }
			}
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_chainsaw_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void chainsaw_primarythink (void)
{
	chainsaw_meleethink(
		autocvar_g_balance_chainsaw_primary_melee_time,
		autocvar_g_balance_chainsaw_primary_melee_range,
		autocvar_g_balance_chainsaw_primary_damage,
		autocvar_g_balance_chainsaw_primary_melee_nonplayerdamage, self.chainsaw_primaryon,
		FALSE);
}

void chainsaw_secondarythink (void)
{
	if (self.chainsaw_primaryon || self.chainsaw_bladestime > time) {
		chainsaw_meleethink(
		autocvar_g_balance_chainsaw_secondary_melee_time,
		autocvar_g_balance_chainsaw_secondary_melee_range,
		autocvar_g_balance_chainsaw_primary_damage,
		autocvar_g_balance_chainsaw_primary_melee_nonplayerdamage, TRUE,
		TRUE);
	} else {
		chainsaw_meleethink(
		autocvar_g_balance_chainsaw_secondary_melee_time,
		autocvar_g_balance_chainsaw_secondary_melee_range,
		autocvar_g_balance_chainsaw_secondary_damage,
		autocvar_g_balance_chainsaw_secondary_melee_nonplayerdamage, FALSE,
		TRUE);
	}
}	

void W_ChainSaw_Attack (void)
{
	if(self.chainsaw_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_chainsaw_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_chainsaw_primary_animtime, w_ready);
		//print(ftos(self.ammo_fuel),"clip",ftos(self.clip_load),"Decrease ammo\n");
		W_DecreaseAmmo(ammo_fuel, autocvar_g_balance_chainsaw_primary_ammo, autocvar_g_balance_chainsaw_reload_ammo);
		if (autocvar_g_balance_chainsaw_jamrate &&
 		(autocvar_g_balance_chainsaw_jamrate > random() ))
 		{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your chainsaw jammed\n");
			}
			self.chainsaw_jammed = 1;
		} else {
			self.chainsaw_bladestime = time + autocvar_g_balance_chainsaw_sawspincontinue;
		}
	}
	
	if (self.chainsaw_primaryon)
	{
		sound (self, CH_WEAPON_A, "machines/generator_loop_speedup_chorus.ogg", VOL_BASE, ATTN_NORM);	
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 3; //Don't want it to be that big, you don't really swing it
	self.melee_temp.chainsaw_primaryon = self.chainsaw_primaryon;
	self.melee_temp.chainsaw_bladestime = self.chainsaw_bladestime;
	
	if(self.chainsaw_secondary == 1) {
 		self.melee_temp_starttime = time + autocvar_g_balance_chainsaw_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_chainsaw_secondary_melee_time;
	   meleetemp.think = chainsaw_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_chainsaw_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_chainsaw_secondary_damage, autocvar_g_balance_chainsaw_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_chainsaw_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_chainsaw_primary_melee_time;
	   meleetemp.think = chainsaw_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_chainsaw_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_chainsaw_primary_damage, autocvar_g_balance_chainsaw_primary_melee_range);
	}
}


void spawnfunc_weapon_chainsaw (void)
{
	weapon_defaultspawnfunc(WEP_CHAINSAW);
}

float W_chainsaw_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_chainsaw_reload_ammo && self.clip_load < autocvar_g_balance_chainsaw_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

.float chainsaw_primarytime;

float w_chainsaw(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_chainsaw_primary_melee_range)
		&& (self.chainsaw_release)) {
			if (W_chainsaw_NeedManualReload()) {
				if (self.ammo_fuel < 1) {
					self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
				} else {
					weapon_action(self.weapon, WR_RELOAD);
				}
			} // bot reload if automatic reload off

			if not (self.BUTTON_ATCK2) {
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			}
		}
		else
		{
			self.BUTTON_ATCK=FALSE;
			self.BUTTON_ATCK2=FALSE;
		}
	}
	else if (req == WR_THINK)
	{
	   if (!autocvar_g_manualreload && 
	   (autocvar_g_balance_chainsaw_reload_ammo && self.clip_load < autocvar_g_balance_chainsaw_primary_ammo)) // forced reload
	   {
			// don't force reload an empty chainsaw if its melee attack is active
			if not(self.ammo_fuel < autocvar_g_balance_chainsaw_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
	   } else if (self.chainsaw_jammed && self.chainsaw_unjam) {
	   	 	if (time >= self.chainsaw_unjam_time) {
				self.chainsaw_jammed = 0;
				self.chainsaw_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
	   } else {
		//if (!self.crouch) // we are not currently crouching; this fixes an exploit where your melee anim is not visible, and besides wouldn't make much sense
		if (self.BUTTON_ATCK2)
		if (self.chainsaw_release)
		if (weapon_prepareattack(1, autocvar_g_balance_chainsaw_secondary_refire))
		{
			self.chainsaw_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_ChainSaw_Attack);
			self.chainsaw_release = 0;
		}
		if (self.BUTTON_ATCK)
		//if (self.chainsaw_release)
		if (self.chainsaw_jammed != 1)
		if(!W_chainsaw_NeedManualReload())
		if (weapon_prepareattack(1, autocvar_g_balance_chainsaw_primary_refire))
		{
			self.chainsaw_secondary = 0;
			self.chainsaw_primaryon = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_ChainSaw_Attack);
			//self.chainsaw_release = 0;
		}
		
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.chainsaw_release = 1;
			self.chainsaw_primaryon = 0;
		}
	   }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_chainsaw.md3");
		precache_model ("models/weapons/v_chainsaw.md3");
		precache_model ("models/weapons/h_chainsaw.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/chainsaw_fire.wav");
		precache_sound ("weapons/warhammerspiked_melee.wav");
		precache_sound ("object/impact_wood_4.ogg");
		precache_sound ("object/impact_wood_5.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
		chainsaw_precachechoppingwoodsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CHAINSAW);
		self.current_ammo = ammo_fuel;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_fuel >= autocvar_g_balance_chainsaw_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_CHAINSAW]) >= autocvar_g_balance_chainsaw_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.chainsaw_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_chainsaw_clearjam_time, w_ready);
			if (self.chainsaw_unjam != 1) {
				self.chainsaw_unjam = 1;
				self.chainsaw_unjam_time = time + autocvar_g_balance_chainsaw_clearjam_time;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the tool\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_chainsaw_primary_ammo, autocvar_g_balance_chainsaw_reload_ammo, autocvar_g_balance_chainsaw_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_chainsaw(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was hit by %s's chainsaw");
		} else {
			w_deathtypestring = _("%s was sawn by %s");
		}
	}
	return TRUE;
}
#endif
#endif
