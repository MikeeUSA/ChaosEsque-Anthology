#ifdef REGISTER_WEAPON
REGISTER_WEAPON(AK47, w_ak47, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "ak47", "ak47", _("AK-47"))
#else
#ifdef SVQC

float autocvar_g_balance_ak47_skin;

.float ak47_release;
.float ak47_jammed;
.float ak47_unjam;
.float ak47_unjam_time;
.float ak47_click;
.float ak47_animempty;
.float ak47_animset;
.float ak47_nextanim;
.float ak47_nextbot;
.float ak47_setting; //0 full auto //1 semi
.float ak47_overheat_cnt;
.float ak47_overheated_until;
.float ak47_magazine; //0normal, 1 50rnd, 2 100rnd
.float ak47_magazine_changetime;
.float ak47_gsetmagazine; //For ground model setting propagation
.float ak47_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup

float ak47autoskincolorset;
.float ak47_customskin;

void W_Ak47_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_ak47_primary_ammo;
	d = autocvar_g_balance_ak47_primary_damage;
	f = autocvar_g_balance_ak47_primary_force;

	spread = bound(autocvar_g_balance_ak47_spread_min, autocvar_g_balance_ak47_spread_min + (autocvar_g_balance_ak47_spread_add * self.misc_bulletcounter), autocvar_g_balance_ak47_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_ak47_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_ak47_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_ak47_reload_ammo);
	
	if (autocvar_g_balance_ak47_jamrate &&
 	(autocvar_g_balance_ak47_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault rifle jammed\n");
		}
		self.ak47_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ak47_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_ak47_primary_headshotaddeddamage, f, WEP_AK47, PROJECTILE_BULLETRIFLE30, 1, bulletconstant, autocvar_g_balance_ak47_primary_coreshotaddeddamage);
	endFireBallisticBullet();
	
	//Note projectile changed to bulletrifle9mm from bulletrifle25

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_ak47_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_ak47_gunrise, random() * autocvar_g_balance_ak47_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '8 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 124, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.ak47_overheat_cnt),"_Firing\n");
		
	    	self.ak47_overheat_cnt = self.ak47_overheat_cnt + autocvar_g_balance_ak47_heatconstant;
         
	    	if (self.ak47_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your ak47 overheated\n");
			}
				
			self.ak47_overheated_until = time + (autocvar_g_balance_ak47_cooldownwait * (self.ak47_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_Ak47_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_ak47_reload_ammo && self.clip_load < autocvar_g_balance_ak47_primary_ammo))
	{
		if (!self.ak47_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.ak47_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.ak47_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

float W_Ak47_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				if (player.ak47_magazine == 2) {
					if (!autocvar_g_balance_ak47_exmag100notincluded
			  		|| player.inv_misc_exmag_ak47_100)
			  		{
						return 1;
					} else {
						player.ak47_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.ak47_magazine == 1.5) {
					if (!autocvar_g_balance_ak47_drum75notincluded
			  		|| player.inv_misc_drum_ak47_75)
			  		{
						return 1;
					} else {
						player.ak47_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.ak47_magazine == 1) {
					if (!autocvar_g_balance_ak47_exmag50notincluded
			  		|| player.inv_misc_exmag_ak47_50)
			  		{
						return 1;
					} else {
						player.ak47_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.ak47_magazine == -1) {
					return 1;
				}
				
				if (player.ak47_magazine == 0) {
					if (!autocvar_g_balance_ak47_mag30notincluded
			  		|| player.inv_misc_mag_ak47_30)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.ak47_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_Ak47_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_ak47_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_ak47_reload_ammo;
		player.clip_load = autocvar_g_balance_ak47_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_Ak47_refunddowntocustommag(entity player, float myreloadammo) {
	if(player.clip_load > myreloadammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - myreloadammo;
		player.clip_load = myreloadammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

void W_Ak47_setmodelforanim(entity player) {
	if (player.ak47_magazine == 2) {
		if (player.ak47_animempty)
			player.weaponname = "ak47_exm100_empty";
		else
			player.weaponname = "ak47_exm100";
	} else if (player.ak47_magazine == 1.5) {
		if (player.ak47_animempty)
			player.weaponname = "ak47_drum75_empty";
		else
			player.weaponname = "ak47_drum75";
	} else if (player.ak47_magazine == 1) {
		if (player.ak47_animempty)
			player.weaponname = "ak47_exm50_empty";
		else
			player.weaponname = "ak47_exm50";
	} else if (player.ak47_magazine == -1) {
		if (player.ak47_animempty)
			player.weaponname = "ak47_none_empty";
		else
			player.weaponname = "ak47_none";
	} else {
		if (player.ak47_animempty)
			player.weaponname = "ak47_empty";
		else
			player.weaponname = "ak47";
	}
}

void W_Ak47_setclipsize(entity player) {
	if (player.ak47_magazine == 2) {
		player.clip_size = autocvar_g_balance_ak47_reload_ammoexm2;
	} else if (player.ak47_magazine == 1.5) {
		player.clip_size = autocvar_g_balance_ak47_reload_ammodrum;
	} else if (player.ak47_magazine == 1) {
		player.clip_size = autocvar_g_balance_ak47_reload_ammoexm;
	} else if (player.ak47_magazine == -1) {
		player.clip_size = autocvar_g_balance_ak47_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_ak47_reload_ammo;
	}
}

void W_Ak47_setrefunddown(entity player) {
	if (player.ak47_magazine == 2) {
		W_Ak47_refunddowntocustommag(player, autocvar_g_balance_ak47_reload_ammoexm2);
	} else if (player.ak47_magazine == 1.5) {
		W_Ak47_refunddowntocustommag(player, autocvar_g_balance_ak47_reload_ammodrum);
	} else if (player.ak47_magazine == 1) {
		W_Ak47_refunddowntocustommag(player, autocvar_g_balance_ak47_reload_ammoexm);
	} else if (player.ak47_magazine == -1) {
		W_Ak47_refunddowntocustommag(player, autocvar_g_balance_ak47_reload_ammonone);
	} else {
		W_Ak47_refunddowntocustommag(player, autocvar_g_balance_ak47_reload_ammo);
	}
}

float W_Ak47_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_ak47_mag30notincluded
	|| player.inv_misc_mag_ak47_30)
	{
		return 0;
	} else if (!autocvar_g_balance_ak47_exmag50notincluded
	|| player.inv_misc_exmag_ak47_50)
	{
		return 1;
	} else if (!autocvar_g_balance_ak47_drum75notincluded
	|| player.inv_misc_drum_ak47_75)
	{
		return 1.5;
	} else if (!autocvar_g_balance_ak47_exmag100notincluded
	|| player.inv_misc_exmag_ak47_100)
	{
		return 2;					
	}
	
	return currentmagwant;
}

void spawnfunc_weapon_ak47 (void)
{
	weapon_defaultspawnfunc(WEP_AK47);
}

float w_ak47_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.ak47_customskin > 0)) {
		return player.ak47_customskin;
	} else if (autocvar_g_balance_ak47_skin == -1) {
	
		////Use the p90 code for figuring out what type of map it is
		//if not(ak47autoskincolorset) {
		//	ak47autoskincolorset = w_p90_skin_autocolorset();
		//}
		
		////Our skins are different numbers however, for snow, so we set below
		//if (ak47autoskincolorset == -10) {
		//	return 0;
		//} else if (ak47autoskincolorset == 1) {
		//	//Dust
		//	return 1;
		//} else if (ak47autoskincolorset == 4) {
		//	//Snow
		//	return 2;
		//} else {
			return 0;
		//}
	} else {
		return autocvar_g_balance_ak47_skin;
	}
}


void w_ak47_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.ak47_magazine == 2) {
		myself.model = "models/weapons/g_ak47_exm100.md3";
		
		if (autocvar_g_balance_ak47_exmag100notincluded
		&& player.inv_misc_exmag_ak47_100 >= 1) {
			player.inv_misc_exmag_ak47_100 = player.inv_misc_exmag_ak47_100 - 1;
			myself.inv_misc_exmag_ak47_100 = myself.inv_misc_exmag_ak47_100 + 1;
		}
		
		myself.ak47_gsetmagazine = player.ak47_magazine;
	} else if (player.ak47_magazine == 1.5) {
		myself.model = "models/weapons/g_ak47_drum75.md3";
		
		if (autocvar_g_balance_ak47_drum75notincluded
		&& player.inv_misc_drum_ak47_75 >= 1) {
			player.inv_misc_drum_ak47_75 = player.inv_misc_drum_ak47_75 - 1;
			myself.inv_misc_drum_ak47_75 = myself.inv_misc_drum_ak47_75 + 1;
		}
		
		myself.ak47_gsetmagazine = player.ak47_magazine;
	} else if (player.ak47_magazine == 1) {
		myself.model = "models/weapons/g_ak47_exm50.md3";
		
		if (autocvar_g_balance_ak47_exmag50notincluded
		&& player.inv_misc_exmag_ak47_50 >= 1) {
			player.inv_misc_exmag_ak47_50 = player.inv_misc_exmag_ak47_50 - 1;
			myself.inv_misc_exmag_ak47_50 = myself.inv_misc_exmag_ak47_50 + 1;
		}
		myself.ak47_gsetmagazine = player.ak47_magazine;
	} else if (player.ak47_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_ak47.md3";
		
		if (autocvar_g_balance_ak47_mag30notincluded
		&& player.inv_misc_mag_ak47_30 >= 1) {
			player.inv_misc_mag_ak47_30 = player.inv_misc_mag_ak47_30 - 1;
			myself.inv_misc_mag_ak47_30 = myself.inv_misc_mag_ak47_30 + 1;
		}
		myself.ak47_gsetmagazine = player.ak47_magazine;
	} else if (player.ak47_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_ak47_none.md3";
		
		myself.ak47_gsetmagazine = player.ak47_magazine;
	} else {
		//Do nothing
		myself.ak47_gsetmagazine = 0;
	}
}

void w_ak47_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_AK47) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.ak47_magazine = myself.ak47_gsetmagazine;
			player.ak47_pickedupgsetmagazine = myself.ak47_gsetmagazine;
		}
	}
}

.float ak47_primarytime;

float w_ak47(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For AK, only the primary trigger is relevant for overheating
				//print(ftos(self.ak47_overheat_cnt),"_Cooldown\n");
			
			if (self.ak47_overheat_cnt < autocvar_g_balance_ak47_heatmin) {
				self.ak47_overheat_cnt = autocvar_g_balance_ak47_heatmin;
			} else {
				self.ak47_overheat_cnt = self.ak47_overheat_cnt - (autocvar_g_balance_ak47_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Ak47_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.ak47_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.ak47_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_ak47_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Ak47_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_Ak47_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_Ak47_refunddowntostdmag(self);
			//print(ftos(self.ak47_magazine), "Here222\n");
			//////self.ak47_magazine = W_Ak47_tryforvalidmag(self, self.ak47_magazine);
			W_Ak47_setclipsize(self);
			W_Ak47_setrefunddown(self);
			W_Ak47_setmodelforanim(self);
		}	
			
		if(autocvar_g_balance_ak47_reload_ammo && self.clip_load < autocvar_g_balance_ak47_primary_ammo) // forced reload
		{
			// don't force reload an empty ak47 if its melee attack is active
			if not(autocvar_g_balance_ak47_secondary && self.ammo_nails < autocvar_g_balance_ak47_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.ak47_release = 0;
		}
		else
		{
		  if (self.ak47_jammed && self.ak47_unjam)
		  {
		  	if (time >= self.ak47_unjam_time) {
				self.ak47_jammed = 0;
				self.ak47_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.ak47_release)
			if (self.ak47_jammed != 1)
			if ((time > self.ak47_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.ak47_setting != 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.ak47_nextbot)," \n");
				} else {
					self.ak47_nextbot = 0;
				}
				
				if (time >= self.ak47_nextbot) {
					W_Ak47_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_ak47_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_ak47_primary_animtime, w_ready);
					self.ak47_release = 0;
					self.ak47_animempty = 1;
					self.ak47_animset = 1;
					self.ak47_nextanim = time + autocvar_g_balance_ak47_primary_rfanim;
					bp_skipme = 1;
					//self.ak47_nextbot = time + (autocvar_g_balance_ak47_primary_refire * 50 * random());
					self.ak47_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.ak47_release = 1;
					self.ak47_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.ak47_nextbot)," \n");
				} else {
					self.ak47_nextbot = 0;
				}
				
				if (time >= self.ak47_nextbot) {
					W_Ak47_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_ak47_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_ak47_secondary_animtime, w_ready);
					self.ak47_release = 0;
					self.ak47_animempty = 1;
					self.ak47_animset = 1;
					self.ak47_nextanim = time + autocvar_g_balance_ak47_secondary_rfanim;
					bp_skipme = 1;
					//self.ak47_nextbot = time + (autocvar_g_balance_ak47_secondary_refire * 50 * random());
					self.ak47_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.ak47_release)
			if (self.ak47_jammed != 1)
			if ((time > self.ak47_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.ak47_setting) {
					self.ak47_setting = 0;
				} else {
					self.ak47_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.ak47_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.ak47_jammed != 1)
				if (time >= self.ak47_nextanim)
				if (self.ak47_animempty)
				{
					self.ak47_animempty = 0;
					self.ak47_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.ak47_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.ak47_animset)
			if (self.ak47_jammed != 1) {
					W_Ak47_setmodelforanim(self);
			}
			
			self.ak47_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_Ak47_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_Ak47_refunddowntostdmag(self);
			W_Ak47_setclipsize(self);
			W_Ak47_setrefunddown(self);
			W_Ak47_setmodelforanim(self);
		}
		
		
		  if (self.ak47_jammed && self.ak47_unjam)
		  {
		  	if (time >= self.ak47_unjam_time) {
				self.ak47_jammed = 0;
				self.ak47_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_ak47.md3");
		precache_model ("models/weapons/v_ak47.md3");
		precache_model ("models/weapons/h_ak47.iqm");
		
		precache_model ("models/weapons/v_ak47_empty.md3");
		precache_model ("models/weapons/h_ak47_empty.iqm");
		
		precache_model ("models/weapons/g_ak47_exm50.md3");
		precache_model ("models/weapons/v_ak47_exm50.md3");
		precache_model ("models/weapons/h_ak47_exm50.iqm");
		precache_model ("models/weapons/v_ak47_exm50_empty.md3");
		precache_model ("models/weapons/h_ak47_exm50_empty.iqm");
		
		precache_model ("models/weapons/g_ak47_drum75.md3");
		precache_model ("models/weapons/v_ak47_drum75.md3");
		precache_model ("models/weapons/h_ak47_drum75.iqm");
		precache_model ("models/weapons/v_ak47_drum75_empty.md3");
		precache_model ("models/weapons/h_ak47_drum75_empty.iqm");
		
		precache_model ("models/weapons/g_ak47_exm100.md3");
		precache_model ("models/weapons/v_ak47_exm100.md3");
		precache_model ("models/weapons/h_ak47_exm100.iqm");
		precache_model ("models/weapons/v_ak47_exm100_empty.md3");
		precache_model ("models/weapons/h_ak47_exm100_empty.iqm");
		
		precache_model ("models/weapons/g_ak47_none.md3");
		precache_model ("models/weapons/v_ak47_none.md3");
		precache_model ("models/weapons/h_ak47_none.iqm");
		precache_model ("models/weapons/v_ak47_none_empty.md3");
		precache_model ("models/weapons/h_ak47_none_empty.iqm");
		
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ak47_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.ak47_overheat_cnt = autocvar_g_balance_ak47_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 0.02 -2.8';
		weapon_setup(WEP_AK47);
		self.current_ammo = ammo_nails;
		
			//Make sure we're allowed to have.
			W_Ak47_allowedextendedmags(self);
			
			if (self.ak47_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.ak47_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 30 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.ak47_magazine = W_Ak47_tryforvalidmag(self, self.ak47_magazine);
					W_Ak47_allowedextendedmags(self);
				}
			}
			
			self.ak47_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_Ak47_setmodelforanim(self);
				
	}
	else if (req == WR_CLIPSETUP)
	{
		W_Ak47_setclipsize(self);
		W_Ak47_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_ak47_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_AK47]) >= autocvar_g_balance_ak47_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.ak47_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_ak47_clearjam_time, w_ready);
			if (self.ak47_unjam != 1) {
				self.ak47_unjam = 1;
				self.ak47_unjam_time = time + autocvar_g_balance_ak47_clearjam_time;
				self.ak47_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float ak47donothing;
			ak47donothing = 0;
			if (self.BUTTON_USE) {
			  if (self.ak47_magazine_changetime >= time) {
			  	//Do nothing
				ak47donothing = 1;
			  } else {
				local float ak47magwant;
				if (self.ak47_magazine == 1) {
					ak47magwant = 1.5;
				} else if (self.ak47_magazine == 1.5) {
					ak47magwant = 2;	
				} else if (self.ak47_magazine == 2) {
					ak47magwant = 0;	
				} else {
					//self.ak47_magazine == 0
					ak47magwant = 1;
				}				
				
				if (ak47magwant == 1) {
					if (!autocvar_g_balance_ak47_exmag50notincluded
			  		|| self.inv_misc_exmag_ak47_50)
			  		{
						//Yes
					} else {
						//No
							ak47magwant = 1.5; //fallback
					}
				}				
				
				if (ak47magwant == 1.5) {
					if (!autocvar_g_balance_ak47_drum75notincluded
			  		|| self.inv_misc_drum_ak47_75)
			  		{
						//Yes
					} else {
						//No
							ak47magwant = 2; //fallback
					}
				}
				
				if (ak47magwant == 2) {
					if (!autocvar_g_balance_ak47_exmag100notincluded
			  		|| self.inv_misc_exmag_ak47_100)
			  		{
						//Yes
					} else {
						//No
							ak47magwant = 0; //fallback
					}
				}
				
				//If no magazines available...
				if (ak47magwant == 0) {
					if (!autocvar_g_balance_ak47_mag30notincluded
			  		|| self.inv_misc_mag_ak47_30)
			  		{
						//Yes
					} else {
						//No
							ak47magwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (ak47magwant == -1) {
					ak47magwant = W_Ak47_tryforvalidmag(self, ak47magwant);
				}
				//Final decisions
				
				if (ak47magwant == self.ak47_magazine) {
					ak47donothing = 1;
				} else if (ak47magwant == 2) {
					self.ak47_magazine = 2;
				} else if (ak47magwant == 1.5) {
					self.ak47_magazine = 1.5;
				} else if (ak47magwant == 1) {
					self.ak47_magazine = 1;
				} else if (ak47magwant == 0) {
					self.ak47_magazine = 0;
				} else if (ak47magwant == -1) {
					self.ak47_magazine = -1;
				}
				
				W_Ak47_setmodelforanim(self);
			  }
			}
		
			if (ak47donothing) {
				//print(ftos(time),"Doing nothing\n");
			} else if (self.ak47_magazine == 2) {
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammoexm2, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				
				W_Ak47_refunddowntocustommag(self, autocvar_g_balance_ak47_reload_ammoexm2);
				//Normally no refund here since selection goes up
	
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammoexm2, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				W_Ak47_setclipsize(self);
				self.ak47_magazine_changetime = time + self.reload_time;
			} else if (self.ak47_magazine == 1.5) {
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammodrum, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				
				W_Ak47_refunddowntocustommag(self, autocvar_g_balance_ak47_reload_ammodrum);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammodrum, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				W_Ak47_setclipsize(self);
				self.ak47_magazine_changetime = time + self.reload_time;
			} else if (self.ak47_magazine == 1) {
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammoexm, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				
				W_Ak47_refunddowntocustommag(self, autocvar_g_balance_ak47_reload_ammoexm);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammoexm, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				W_Ak47_setclipsize(self);
				self.ak47_magazine_changetime = time + self.reload_time;
			} else if (self.ak47_magazine == -1) {
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammonone, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_Ak47_refunddowntocustommag(self, autocvar_g_balance_ak47_reload_ammonone);
				
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammonone, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				W_Ak47_setclipsize(self);
				self.ak47_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammo, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_Ak47_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_ak47_primary_ammo, autocvar_g_balance_ak47_reload_ammo, autocvar_g_balance_ak47_reload_time, "weapons/reload.wav");
				W_Ak47_setclipsize(self);
				self.ak47_magazine_changetime = time + self.reload_time;
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_ak47(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent && time - self.prevric > 0.25)
		{
			if(w_random < 0.0165)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.033)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
			self.prevric = time;
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/ric1.wav");
		precache_sound("weapons/ric2.wav");
		precache_sound("weapons/ric3.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%1$s chest was made holes of by %2$s Avtomat Kalashnikova");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died, %2$s shot them in the head");
		else
			w_deathtypestring = _("%s killed was by %s's Avtomat Kalashnikova");
	}
	return TRUE;
}
#endif
#endif
