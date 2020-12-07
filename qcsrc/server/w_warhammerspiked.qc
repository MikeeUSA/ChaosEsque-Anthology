#ifdef REGISTER_WEAPON
REGISTER_WEAPON(WARHAMMERSPIKED, w_warhammerspiked, IT_NAILS, 2, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "warhammerspiked", "warhammerspiked", _("War Hammer"))
#else
#ifdef SVQC

.float warhammerspiked_release;
.float warhammerspiked_secondary;

.float swing_prev;
.entity swing_alreadyhit;

.float flaildeflected;

float melee_check_collision_keepweaponinhand(entity myplayer, entity otherplayer);
void melee_check_collision_maybedropweapon(entity myplayer, entity otherplayer);

void melee_set_tempdefensive(entity otherplayer, entity myplayer)
{
	if (otherplayer.weapon == WEP_QUARTERSTAFF
	|| otherplayer.weapon == WEP_INFANTRYSTAFF
	|| otherplayer.weapon == WEP_ELVENSTAFF) {
		//Quarterstaff etc gets buff for defense.
		if (myplayer.melee_temp_class <= 3) {
			//Normal
			otherplayer.melee_temp_class = 3;
		} else if (myplayer.melee_temp_class <= 5) {
			//Match for 4 or 5
			otherplayer.melee_temp_class = myplayer.melee_temp_class;
		} else {
			//Above 5 (6 or over), we don't match, too heavy for us, we'll resist tho with +1
			otherplayer.melee_temp_class = 4;
		}
		//Reset later.
	} else if (otherplayer.weapon == WEP_SAI) {
		//Sai etc gets buff for defense.
		if (myplayer.melee_temp_class <= 4) {
			//Match for up to 4
			otherplayer.melee_temp_class = myplayer.melee_temp_class;
		} else {
			//Above 4 (5 or over), we don't match, too heavy for us, we'll resist tho with +2
			otherplayer.melee_temp_class = 3;
		}
		//Reset later.
	} else if (otherplayer.weapon == WEP_DEFENDERSWORD) {
		//Defender sword gets slight defense buff
		if (myplayer.melee_temp_class <= 4) {
			//Normal
			otherplayer.melee_temp_class = 4;
		} else if (myplayer.melee_temp_class <= 5) {
			//Match for 5 (Defender sword catches those axes)
			otherplayer.melee_temp_class = myplayer.melee_temp_class;
		} else {
			//Above 5 (6 or over), we don't match, too heavy for us
			//(NOTE: we don't add additional resists either, unlike the other defensive weapons)
		}
		//Reset later.
	} else if (otherplayer.weapon == WEP_SHIRASAYA
	|| otherplayer.weapon == WEP_ZATOICHI) {
			//These lack a handguard and get nerfed for defense.
			otherplayer.melee_temp_class = 3;
	}
}

void melee_reset_tempdefensive(entity otherplayer)
{
	//Reset back to normal class
	if (otherplayer.weapon == WEP_QUARTERSTAFF) {
		otherplayer.melee_temp_class = 3;
	} else if (otherplayer.weapon == WEP_INFANTRYSTAFF) {
		otherplayer.melee_temp_class = 3;
	} else if (otherplayer.weapon == WEP_ELVENSTAFF) {
		otherplayer.melee_temp_class = 3;
	} else if (otherplayer.weapon == WEP_SAI) {
		otherplayer.melee_temp_class = 1;
	} else if (otherplayer.weapon == WEP_DEFENDERSWORD) {
		otherplayer.melee_temp_class = 4;
	}
}

float melee_check_collision(entity myplayer, entity otherplayer)
{
	//print(ftos(myplayer.v_angle_x), " x ", ftos(otherplayer.v_angle_x), " diff ", ftos(myplayer.v_angle_x - otherplayer.v_angle_x),"\n");
	//print(ftos(myplayer.v_angle_y), " y ", ftos(otherplayer.v_angle_y), " diff ", ftos(myplayer.v_angle_y - otherplayer.v_angle_y),"\n");
	//print(ftos(myplayer.v_angle_z), " z ", ftos(otherplayer.v_angle_z),"\n");
	local float r;
	if((myplayer.v_angle_x - otherplayer.v_angle_x < 70) && (myplayer.v_angle_x - otherplayer.v_angle_x > -70))//Look up and down
	if((myplayer.v_angle_y - otherplayer.v_angle_y > 160) || (myplayer.v_angle_y - otherplayer.v_angle_y < -160)) //Side to side Facing eachother
	//////if(myplayer.v_angle_z + otherplayer.v_angle_z < 40)
	////if(otherplayer.melee_temp_starttime > time)
	if(otherplayer.melee_temp_endtime > time)
	{
		r = random() * 13;
		
		melee_set_tempdefensive(otherplayer, myplayer);
		
		if (myplayer.melee_temp_class >= 100 || otherplayer.melee_temp_class >= 100) {
			//Lightsabre type weapon
			r = random() * 3;
			if (r > 2) {
				spamsound (myplayer, CH_PAIN, "machines/electrifiedhit1.wav", VOL_BASE, ATTN_NORM);
			} else if (r > 1) {
				spamsound (myplayer, CH_PAIN, "machines/electrifiedhit2.wav", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (myplayer, CH_PAIN, "machines/electrifiedhit3.wav", VOL_BASE, ATTN_NORM);
			}
		} else if (
		(
		(myplayer.weapon == WEP_CUDGEL || myplayer.weapon == WEP_SPIKEDCUDGEL || myplayer.weapon == WEP_BAT || myplayer.weapon == WEP_QUARTERSTAFF || myplayer.weapon == WEP_ELVENSTAFF || myplayer.weapon == WEP_STAFFMAGI || myplayer.weapon == WEP_STAFFFLAME || myplayer.weapon == WEP_TORCH || myplayer.weapon == WEP_SPIKEDCLUB || myplayer.weapon == WEP_WARMALLET || myplayer.weapon == WEP_KIDUCHI)
		&& (otherplayer.weapon == WEP_CUDGEL || otherplayer.weapon == WEP_SPIKEDCUDGEL || otherplayer.weapon == WEP_BAT || otherplayer.weapon == WEP_QUARTERSTAFF || otherplayer.weapon == WEP_ELVENSTAFF || otherplayer.weapon == WEP_STAFFMAGI || otherplayer.weapon == WEP_STAFFFLAME || otherplayer.weapon == WEP_TORCH || otherplayer.weapon == WEP_SPIKEDCLUB || otherplayer.weapon == WEP_WARMALLET || otherplayer.weapon == WEP_KIDUCHI
		|| otherplayer.weapon == WEP_TETSUBO || otherplayer.weapon == WEP_GREYIRONMALLET || otherplayer.weapon == WEP_CROWBAR || otherplayer.weapon == WEP_IRONCROW || otherplayer.weapon == WEP_MORGENSTERN || otherplayer.weapon == WEP_SHOOTINGSTAR || otherplayer.weapon == WEP_MILFLAIL || otherplayer.weapon == WEP_SPIKEDFLAIL || otherplayer.weapon == WEP_SHININGSTAR || otherplayer.weapon == WEP_SPIKEDMACE
		|| otherplayer.weapon == WEP_SHACKLES || otherplayer.weapon == WEP_HANDCUFFS || otherplayer.weapon == WEP_FLASHLIGHT)
		)
		||
		(
		(myplayer.weapon == WEP_CUDGEL || myplayer.weapon == WEP_SPIKEDCUDGEL || myplayer.weapon == WEP_BAT || myplayer.weapon == WEP_QUARTERSTAFF || myplayer.weapon == WEP_ELVENSTAFF || myplayer.weapon == WEP_STAFFMAGI || myplayer.weapon == WEP_STAFFFLAME || myplayer.weapon == WEP_TORCH || myplayer.weapon == WEP_SPIKEDCLUB || myplayer.weapon == WEP_WARMALLET || myplayer.weapon == WEP_KIDUCHI
		|| myplayer.weapon == WEP_TETSUBO || myplayer.weapon == WEP_GREYIRONMALLET || myplayer.weapon == WEP_CROWBAR || myplayer.weapon == WEP_IRONCROW || myplayer.weapon == WEP_MORGENSTERN || myplayer.weapon == WEP_SHOOTINGSTAR || myplayer.weapon == WEP_MILFLAIL || myplayer.weapon == WEP_SPIKEDFLAIL || myplayer.weapon == WEP_SHININGSTAR || myplayer.weapon == WEP_SPIKEDMACE
		|| myplayer.weapon == WEP_SHACKLES || myplayer.weapon == WEP_HANDCUFFS || myplayer.weapon == WEP_FLASHLIGHT)
		&&
		(otherplayer.weapon == WEP_CUDGEL || otherplayer.weapon == WEP_SPIKEDCUDGEL || otherplayer.weapon == WEP_BAT || otherplayer.weapon == WEP_QUARTERSTAFF || otherplayer.weapon == WEP_ELVENSTAFF || otherplayer.weapon == WEP_STAFFMAGI || otherplayer.weapon == WEP_STAFFFLAME || otherplayer.weapon == WEP_TORCH || otherplayer.weapon == WEP_SPIKEDCLUB || otherplayer.weapon == WEP_WARMALLET || otherplayer.weapon == WEP_KIDUCHI)
		)
		)
		{
			//More blunt sound when blunt weapons used (if both cudgel, or neither equal but both beating weapons
			//Basically: Wood on one side (or both sides)
			//There is some redundancy in the code above.
			//print("here\n");
			if (r > 10) {
			spamsound (myplayer, CH_PAIN, "resource/lumbering/loudlumber_tree_01.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 6) {
			spamsound (myplayer, CH_PAIN, "resource/lumbering/loudlumber_tree_03.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 3) {
			spamsound (myplayer, CH_PAIN, "resource/lumbering/loudlumber_tree_05.ogg", VOL_BASE, ATTN_NORM);
			} else {
			spamsound (myplayer, CH_PAIN, "resource/lumbering/loudlumber_tree_06.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if((myplayer.weapon == WEP_STONEAXE)
		|| (otherplayer.weapon == WEP_STONEAXE))
		{
			if (r > 10) {
			spamsound (myplayer, CH_PAIN, "resource/mining/mine_stone_01.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 6) {
			spamsound (myplayer, CH_PAIN, "resource/mining/mine_stone_03.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 3) {
			spamsound (myplayer, CH_PAIN, "resource/mining/mine_stone_05.ogg", VOL_BASE, ATTN_NORM);
			} else {
			spamsound (myplayer, CH_PAIN, "resource/mining/mine_stone_06.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if (r > 14) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_215.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 13) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_214.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 12) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_213.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 11) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_212.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 10) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_211.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 9) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_210.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 8) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_29.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 7) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_28.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 6) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_27.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 5) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_26.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 4) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_25.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 3) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_24.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 2) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_23.ogg", VOL_BASE, ATTN_NORM);
		} else if (r > 1) {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_22.ogg", VOL_BASE, ATTN_NORM);
		} else {
			spamsound (myplayer, CH_PAIN, "resource/impact/shieldimpmetal_21.ogg", VOL_BASE, ATTN_NORM);
		}
		
		if (otherplayer.weapon == WEP_SPIKEDFLAIL
		 || otherplayer.weapon == WEP_MILFLAIL
		 || otherplayer.weapon == WEP_SHOOTINGSTAR) {
			if (myplayer.melee_temp_class >= 100) {
				//Can't touch lightsabre.
			} else {
					//1/3rd chance of catching/wrap around/etc, otherwise we deflect over
					if (random() > 0.66) {
						//print("!!Caught!!\n");
					} else {
						//print("!!DeflectedButGoingThrough!!!\n");
						
						if (myplayer.melee_temp) {
							myplayer.melee_temp.meleeotherpassesthrough = 1;
						}
						
						if (otherplayer.melee_temp) {
							//print("!!Here\n");
							otherplayer.melee_temp.flaildeflected = 1;
						}
					}
			}
		}

		
		if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 4) {
			melee_reset_tempdefensive(otherplayer);
			melee_check_collision_maybedropweapon(myplayer, otherplayer); //For large disparities in weight class we check every hit
			if (random() > 0.99) {
				return TRUE;
			} else {
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3.75) {
			melee_reset_tempdefensive(otherplayer);
			melee_check_collision_maybedropweapon(myplayer, otherplayer); //For large disparities in weight class we check every hit
			if (random() > 0.98) {
				return TRUE;
			} else {
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_3.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3.5) {
			melee_reset_tempdefensive(otherplayer);
			melee_check_collision_maybedropweapon(myplayer, otherplayer); //For large disparities in weight class we check every hit
			if (random() > 0.97) {
				return TRUE;
			} else {
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_3.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3.25) {
			melee_reset_tempdefensive(otherplayer);
			melee_check_collision_maybedropweapon(myplayer, otherplayer); //For large disparities in weight class we check every hit
			if (random() > 0.96) {
				return TRUE;
			} else {
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_3.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3) {
			melee_reset_tempdefensive(otherplayer);
			melee_check_collision_maybedropweapon(myplayer, otherplayer); //For large disparities in weight class we check every hit
			if (random() > 0.95) {
				return TRUE;
			} else {
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_3.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2.75) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.86) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_2.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2.5) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.77) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_2.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2.25) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.76) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_2.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.75) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_2.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 1.75) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.64) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_1.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 1.5) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.52) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_1.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 1.25) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.51) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_1.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 1) {
			melee_reset_tempdefensive(otherplayer);
			if (random() > 0.5) {
				return TRUE;
			} else {
				melee_check_collision_maybedropweapon(myplayer, otherplayer); //With smaller disparities in weight class we only check when went through
				spamsound (otherplayer, CH_PAIN, "object/impact_wood_1.ogg", VOL_BASE, ATTN_NORM);
				return FALSE;
			}
		} else {
			melee_reset_tempdefensive(otherplayer);
			return TRUE;
		}	
	}
	
	return FALSE;
} 

void melee_check_collision_maybedropweapon(entity myplayer, entity otherplayer)
{
	local entity myoldwepself;
	
	if (melee_check_collision_keepweaponinhand(myplayer, otherplayer)) {
		//Nothing
	} else {
		myoldwepself = self;
		self = otherplayer;
		
		if (self.weapon) {
			sprint(self, "Your weapon has been knocked from your grip\n");
			self.weaponentity.state = WS_READY; //Have to do this to ensure it will be dropped	
			W_ThrowWeaponNoSwitch(W_CalculateProjectileVelocity(self.velocity, v_forward * 1, FALSE), '0 0 0', TRUE);
	  		
			if (autocvar_g_nodropweapons) {
				//If this is set, the above will fail to drop a weapon
				//So instead we just switch weapon to none
				//print ("failed to throw weapon due to nodropweapons, switching to none instead\n");
				W_SwitchWeapon_Force(self, 0);
			}
		}
		
		self = myoldwepself;
	}
}

float melee_check_collision_keepweaponinhand(entity myplayer, entity otherplayer)
{
		if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 6) {
			if (random() > 0.99) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 5.5) {
			if (random() > 0.97) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 5) {
			if (random() > 0.95) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 4.5) {
			if (random() > 0.77) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 4) {
			if (random() > 0.75) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3.5) {
			if (random() > 0.52) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 3) {
			if (random() > 0.5) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2.5) {
			if (random() > 0.25) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else if (myplayer.melee_temp_class - otherplayer.melee_temp_class >= 2) {
			if (random() > 0.1) {
				return TRUE;
			} else {
				//Dropweapon
				return FALSE;
			}
		} else {
			return TRUE;
		}
}

void warhammerspiked_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
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
	f = ((1 - swing) * autocvar_g_balance_warhammerspiked_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_warhammerspiked_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_warhammerspiked_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_warhammerspiked_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_warhammerspiked_primary_melee_swing_side));

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
			d = target_victim.armorvalue;
			t = target_victim.armortype;
			target_victim.armorvalue = 0; //Warhammer pierces and crushes armor
			
			if (is_player) swing_damage = W_CritHitCalc_WarHammer(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_WARHAMMERSPIKED);
			
			if (d > 50) {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_WARHAMMERSPIKED | HITTYPE_SECONDARY, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_warhammerspiked_primary_force);
			} else {
				Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_WARHAMMERSPIKED, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_warhammerspiked_primary_force);
			}
			
			target_victim.armorvalue = d; //Damage done, give back armor
			target_victim.armortype = t;  //Just incase it was removed due to value being 0
			
			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_WARHAMMERSPIKED, 0, swing_damage); }
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_warhammerspiked_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
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

void warhammerspiked_primarythink (void)
{
	warhammerspiked_meleethink(
		autocvar_g_balance_warhammerspiked_primary_melee_time,
		autocvar_g_balance_warhammerspiked_primary_melee_range,
		autocvar_g_balance_warhammerspiked_primary_damage,
		autocvar_g_balance_warhammerspiked_primary_melee_nonplayerdamage
		);
}

void warhammerspiked_secondarythink (void)
{
	warhammerspiked_meleethink(
		autocvar_g_balance_warhammerspiked_secondary_melee_time,
		autocvar_g_balance_warhammerspiked_secondary_melee_range,
		autocvar_g_balance_warhammerspiked_secondary_damage,
		autocvar_g_balance_warhammerspiked_secondary_melee_nonplayerdamage
		);
}

void W_Warhammerspiked_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/warhammerspiked_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.warhammerspiked_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_warhammerspiked_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_warhammerspiked_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 3;
	
	if(self.warhammerspiked_secondary == 1) {
		self.melee_temp_starttime = time + autocvar_g_balance_warhammerspiked_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_warhammerspiked_secondary_melee_time;
	   meleetemp.think = warhammerspiked_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_warhammerspiked_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_warhammerspiked_secondary_damage, autocvar_g_balance_warhammerspiked_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_warhammerspiked_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_warhammerspiked_primary_melee_time;
	   meleetemp.think = warhammerspiked_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_warhammerspiked_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_warhammerspiked_primary_damage, autocvar_g_balance_warhammerspiked_primary_melee_range);
	}
}

void melee_precachesound (void)
{
	precache_sound ("resource/lumbering/loudlumber_tree_01.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_03.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_05.ogg");
	precache_sound ("resource/lumbering/loudlumber_tree_06.ogg");
	precache_sound ("resource/mining/mine_stone_01.ogg");
	precache_sound ("resource/mining/mine_stone_03.ogg");
	precache_sound ("resource/mining/mine_stone_05.ogg");
	precache_sound ("resource/mining/mine_stone_06.ogg");
	precache_sound ("resource/impact/shieldimpmetal_215.ogg");
	precache_sound ("resource/impact/shieldimpmetal_214.ogg");
	precache_sound ("resource/impact/shieldimpmetal_213.ogg");
	precache_sound ("resource/impact/shieldimpmetal_212.ogg");
	precache_sound ("resource/impact/shieldimpmetal_211.ogg");
	precache_sound ("resource/impact/shieldimpmetal_210.ogg");
	precache_sound ("resource/impact/shieldimpmetal_29.ogg");
	precache_sound ("resource/impact/shieldimpmetal_28.ogg");
	precache_sound ("resource/impact/shieldimpmetal_27.ogg");
	precache_sound ("resource/impact/shieldimpmetal_26.ogg");
	precache_sound ("resource/impact/shieldimpmetal_25.ogg");
	precache_sound ("resource/impact/shieldimpmetal_24.ogg");
	precache_sound ("resource/impact/shieldimpmetal_23.ogg");
	precache_sound ("resource/impact/shieldimpmetal_22.ogg");
	precache_sound ("resource/impact/shieldimpmetal_21.ogg");
	precache_sound ("object/impact_wood_4.ogg");
	precache_sound ("object/impact_wood_3.ogg");
	precache_sound ("object/impact_wood_2.ogg");
	precache_sound ("object/impact_wood_1.ogg");
}

void spawnfunc_weapon_warhammerspiked (void)
{
	weapon_defaultspawnfunc(WEP_WARHAMMERSPIKED);
}

.float warhammerspiked_primarytime;

float w_warhammerspiked(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_warhammerspiked_primary_melee_range)
		&& (self.warhammerspiked_release)) {
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
		if (self.warhammerspiked_release)
		if (weapon_prepareattack(1, autocvar_g_balance_warhammerspiked_primary_refire))
		{
			self.warhammerspiked_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Warhammerspiked_Attack);
			self.warhammerspiked_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.warhammerspiked_release)
		if (weapon_prepareattack(1, autocvar_g_balance_warhammerspiked_secondary_refire))
		{
			self.warhammerspiked_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Warhammerspiked_Attack);
			self.warhammerspiked_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.warhammerspiked_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_warhammerspiked.md3");
		precache_model ("models/weapons/v_warhammerspiked.md3");
		precache_model ("models/weapons/h_warhammerspiked.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/warhammerspiked_fire.wav");
		precache_sound ("weapons/warhammerspiked_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_WARHAMMERSPIKED);
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
float w_warhammerspiked(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was crushed in his armor with %s's warhammer");
		} else {
			w_deathtypestring = _("%s was crushed with %s's warhammer");
		}
	}
	return TRUE;
}
#endif
#endif
