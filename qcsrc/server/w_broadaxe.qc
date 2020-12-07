#ifdef REGISTER_WEAPON
REGISTER_WEAPON(BROADAXE, w_broadaxe, IT_NAILS, 9, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "broadaxe", "broadaxe", _("Broad Axe"))
#else
#ifdef SVQC

.float broadaxe_release;
.float broadaxe_secondary;

.float swing_prev;
.entity swing_alreadyhit;
void Foliage_Fall();

void broadaxe_precachechoppingwoodsounds()
{
	precache_sound ("resource/lumbering/loudlumber_tree_01.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_02.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_03.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_04.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_05.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_06.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_07.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_08.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_09.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_10.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_11.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_12.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_13.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_14.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_15.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_16.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_17.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_18.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_19.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_20.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_21.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_22.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_23.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_24.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_25.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_26.ogg");
	//Skippin _01
	precache_sound ("resource/lumbering/lumber_treeexpire_02.ogg");
	precache_sound ("resource/lumbering/lumber_treeexpire_03.ogg");
	precache_sound ("resource/lumbering/lumber_treeexpire_04.ogg");
}
void broadaxe_spamtreefallsound (entity myplayer)
{
	//Oh my, a switch statement, so elite. Thank goodness we didn't use an if then
	//Now for us to wait until the user does this a handful of times
	//Future criticisms: didn't use some string magling to come up with the numbers
	//and avoid a switch and use costly string routines instead!
	local float snrandvar;
	snrandvar = floor(random()*3);
	switch(snrandvar)
	{
		default:
		case 0:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/lumber_treeexpire_02.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 1:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/lumber_treeexpire_03.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 2:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/lumber_treeexpire_04.ogg", VOL_BASE, ATTN_NORM);
			break;
	}
}
void broadaxe_spamchoppingwoodsound (entity myplayer)
{
	//Oh my, a switch statement, so elite. Thank goodness we didn't use an if then
	//Now for us to wait until the user does this a handful of times
	//Future criticisms: didn't use some string magling to come up with the numbers
	//and avoid a switch and use costly string routines instead!
	//
	//These sfx are amplified, they're 8-19db amplified above the originals,
	// they sound about 2x as loud as the originals and are encoded at ogg lvl 3 to reduce size
	//Any higher amplification and there would be clipping.
	//Had to do it this way as you can't set volume above 1.
	local float snrandvar;
	snrandvar = floor(random()*26);
	switch(snrandvar)
	{
		default:
		case 0:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_01.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 1:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_02.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 2:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_03.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 3:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_04.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 4:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_05.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 5:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_06.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 6:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_07.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 7:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_08.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 8:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_09.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 9:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_10.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 10:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_11.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 11:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_12.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 12:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_13.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 13:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_14.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 14:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_15.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 15:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_16.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 16:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_17.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 17:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_18.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 18:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_19.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 19:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_20.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 20:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_21.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 21:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_22.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 22:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_23.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 23:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_24.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 24:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_25.ogg", VOL_BASE, ATTN_NORM);
			break;
		case 25:
			spamsound (myplayer, CH_SHOTS, "resource/lumbering/loudlumber_tree_26.ogg", VOL_BASE, ATTN_NORM);
			break;	
	}
}


void broadaxe_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
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
	f = ((1 - swing) * autocvar_g_balance_broadaxe_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_broadaxe_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_broadaxe_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_broadaxe_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_broadaxe_primary_melee_swing_side));

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
		
		if (is_player && !(autocvar_g_balance_broadaxe_noblood) && (trace_ent.armorvalue < 50)) {
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
				swing_damage = swing_damage * autocvar_g_balance_broadaxe_damagerate_tree;
			
				target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
				if (target_victim.vehicle_health < 0) {
					self.realowner.multitool_ammocurrent = self.realowner.multitool_ammocurrent + target_victim.multitool_ammocurrent;
					target_victim.multitool_ammocurrent = 0;
					
					target_victim.health = target_victim.maxs_z + 16;
			
					target_victim.think = Foliage_Fall;
					target_victim.nextthink = time;
					broadaxe_spamtreefallsound(target_victim); //We'll do it here rather than in Foliage_Fall, these sounds just for axe fellings (not explosion destruction of trees etc)
				} else {
					broadaxe_spamchoppingwoodsound(self.realowner); //Needs to be player for these particular sounds so we can really hear it
				}
				
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));

			} else if ((target_victim.classname == "building" || target_victim.accptlikebuilding) && !target_victim.multitool_isscaffold) 
			{
				////swing_damage = swing_damage * autocvar_g_balance_broadaxe_damagerate_tree;
			
				if (target_victim.multitool_hitbox != world) {
				 if (multitool_axecandamage(target_victim.multitool_hitbox.count)) {				
					Damage(target_victim.multitool_hitbox, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage, swing_damage), WEP_BROADAXE, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_broadaxe_primary_force);
					
					if (random() > 0.5) {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE * 0.15, ATTN_NORM);
					} else {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE * 0.15, ATTN_NORM);
					}
				 }
				} else if (target_victim.multitool_doorframeent && target_victim.multitool_doorframeent.multitool_hitbox != world) {
				 //Built Door slabs
				 if (multitool_axecandamage(target_victim.multitool_doorframeent.multitool_hitbox.count)) {				
					Damage(target_victim.multitool_doorframeent.multitool_hitbox, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage, swing_damage), WEP_BROADAXE, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_broadaxe_primary_force);
					
					if (random() > 0.5) {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE * 0.15, ATTN_NORM);
					} else {
						spamsound (self.realowner, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE * 0.15, ATTN_NORM);
					}
				 }
				} 
				//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
			}
			else
			{
				float d;
				float t;
				if (is_player) swing_damage = W_CritHitCalc_Axe(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_BROADAXE);
				d = target_victim.armorvalue;
				t = target_victim.armortype;
				target_victim.armorvalue = d * 4; //BroadAxe doesn't do as well against armor
			
				//print(ftos(swing_damage), " ", ftos(swing_damage - (d * 0.75)), "\n");
			
				if (d > 50) {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.1, swing_damage - (d * 0.50), swing_damage), WEP_BROADAXE | HITTYPE_SECONDARY, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_broadaxe_primary_force);
				} else {
					Damage(target_victim, self.realowner, self.realowner, 
					bound(swing_damage * 0.2, swing_damage - (d * 0.25), swing_damage), WEP_BROADAXE, 
					self.realowner.origin + self.realowner.view_ofs, 
					v_forward * autocvar_g_balance_broadaxe_primary_force);
				}
			
				if ((is_player) && !(autocvar_g_balance_broadaxe_noblood) && (d < 50)) {
					//print("blood\n");
					Damage_DamageInfo(targpos, swing_damage, swing_damage, 0, v_forward * 100, WEP_BROADAXE, trace_ent.species, self.realowner);
	
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
			
				if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_BROADAXE, 0, swing_damage); }
			}
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_broadaxe_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void broadaxe_primarythink (void)
{
	broadaxe_meleethink(
		autocvar_g_balance_broadaxe_primary_melee_time,
		autocvar_g_balance_broadaxe_primary_melee_range,
		autocvar_g_balance_broadaxe_primary_damage,
		autocvar_g_balance_broadaxe_primary_melee_nonplayerdamage
		);
}

void broadaxe_secondarythink (void)
{
	broadaxe_meleethink(
		autocvar_g_balance_broadaxe_secondary_melee_time,
		autocvar_g_balance_broadaxe_secondary_melee_range,
		autocvar_g_balance_broadaxe_secondary_damage,
		autocvar_g_balance_broadaxe_secondary_melee_nonplayerdamage
		);
}

float broadaxe_probablywillhittree(entity myplayer, float wmelee_range)
{
	//See if we'll hit a tree, if so, don't annoy player with swing sound
	vector targpos;
	local entity trcr;
	trcr = spawn();
	trcr.origin = myplayer.origin; //Cargo culting.

	makevectors(myplayer.v_angle); // update values for v_* vectors
			
	targpos = (myplayer.origin + myplayer.view_ofs + (v_forward * wmelee_range));

	//WarpZone_traceline_antilag(trcr, myplayer.origin + myplayer.view_ofs, targpos, FALSE, trcr, ANTILAG_LATENCY(myplayer));
	traceline(myplayer.origin + myplayer.view_ofs, targpos, MOVE_NORMAL, trcr); //Should be right next to it
	remove(trcr);
		
	if (trace_ent.classname == "tree") 
	{
		return TRUE; //Ok, so we shouldn't do the swing sound, lets tell the other part of the code
	}

	return FALSE;
}	

void W_BroadAxe_Attack (void)
{
	if not (broadaxe_probablywillhittree(self, autocvar_g_balance_broadaxe_primary_melee_range)) {
		sound (self, CH_WEAPON_A, "weapons/warhammerspiked_melee.wav", VOL_BASE, ATTN_NORM);
	}
	
	if(self.broadaxe_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_broadaxe_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_broadaxe_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 5;
	
	if(self.broadaxe_secondary == 1) {
 		self.melee_temp_starttime = time + autocvar_g_balance_broadaxe_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_broadaxe_secondary_melee_time;
	   meleetemp.think = broadaxe_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_broadaxe_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_broadaxe_secondary_damage, autocvar_g_balance_broadaxe_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_broadaxe_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_broadaxe_primary_melee_time;
	   meleetemp.think = broadaxe_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_broadaxe_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_broadaxe_primary_damage, autocvar_g_balance_broadaxe_primary_melee_range);
	}
}


void spawnfunc_weapon_broadaxe (void)
{
	weapon_defaultspawnfunc(WEP_BROADAXE);
}

.float broadaxe_primarytime;

float w_broadaxe(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_broadaxe_primary_melee_range)
		&& (self.broadaxe_release)) {
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
		if (self.broadaxe_release)
		if (weapon_prepareattack(1, autocvar_g_balance_broadaxe_primary_refire))
		{
			self.broadaxe_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_BroadAxe_Attack);
			self.broadaxe_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.broadaxe_release)
		if (weapon_prepareattack(1, autocvar_g_balance_broadaxe_secondary_refire))
		{
			self.broadaxe_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_BroadAxe_Attack);
			self.broadaxe_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.broadaxe_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_broadaxe.md3");
		precache_model ("models/weapons/v_broadaxe.md3");
		precache_model ("models/weapons/h_broadaxe.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/broadaxe_fire.wav");
		precache_sound ("weapons/warhammerspiked_melee.wav");
		precache_sound ("object/impact_wood_4.ogg");
		precache_sound ("object/impact_wood_5.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
		broadaxe_precachechoppingwoodsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_BROADAXE);
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
float w_broadaxe(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was crushed by %s's broad axe");
		} else {
			w_deathtypestring = _("%s was cleaved by %s's broad axe");
		}
	}
	return TRUE;
}
#endif
#endif
