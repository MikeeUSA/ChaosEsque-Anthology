#ifdef REGISTER_WEAPON
REGISTER_WEAPON(STYERAUG, w_styeraug, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "styeraug", "styeraug", _("Styer Aug"))
#else
#ifdef SVQC

.float styeraug_release;
.float styeraug_jammed;
.float styeraug_unjam;
.float styeraug_unjam_time;
.float styeraug_click;
.float styeraug_animempty;
.float styeraug_animset;
.float styeraug_nextanim;
.float styeraug_nextbot;
.float styeraug_overheat_cnt;
.float styeraug_overheated_until;
.float styeraug_magazine; //0normal, 1 45rnd
.float styeraug_magazine_changetime;
.float styeraug_gsetmagazine; //For ground model setting propagation
.float styeraug_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup

float styeraugautoskincolorset;
.float styeraug_customskin;

float w_p90_skin_autocolorset(void);

void W_StyerAug_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_styeraug_primary_ammo;
	d = autocvar_g_balance_styeraug_primary_damage;
	f = autocvar_g_balance_styeraug_primary_force;
	//spread = autocvar_g_balance_styeraug_primary_spread;
	spread = bound(autocvar_g_balance_styeraug_spread_min, autocvar_g_balance_styeraug_spread_min + (autocvar_g_balance_styeraug_spread_add * self.misc_bulletcounter), autocvar_g_balance_styeraug_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_styeraug_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_styeraug_reload_ammo);
	
	if (autocvar_g_balance_styeraug_jamrate &&
 	(autocvar_g_balance_styeraug_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your Aug jammed\n");
		}
		self.styeraug_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire_aug.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_styeraug_primary_headshotaddeddamage, f, WEP_STYERAUG, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_styeraug_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.35;
		self.punchangle_y = random () - 0.35;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_styeraug_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_styeraug_gunrise, random() * autocvar_g_balance_styeraug_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '1 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * -120 - 140) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '-8 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.styeraug_overheat_cnt),"_Firing\n");
		
	    	self.styeraug_overheat_cnt = self.styeraug_overheat_cnt + autocvar_g_balance_styeraug_heatconstant;
         
	    	if (self.styeraug_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your styeraug overheated\n");
			}
				
			self.styeraug_overheated_until = time + (autocvar_g_balance_styeraug_cooldownwait * (self.styeraug_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_StyerAug_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_styeraug_reload_ammo && self.clip_load < autocvar_g_balance_styeraug_primary_ammo))
	{
		if (!self.styeraug_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.styeraug_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.styeraug_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}



float W_StyerAug_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.styeraug_magazine == 2) {
				//	if (!autocvar_g_balance_styeraug_exmag100notincluded
			  	//	|| player.inv_misc_exmag_styeraug_100)
			  	//	{
				//		return 1;
				//	} else {
				//		player.styeraug_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.styeraug_magazine == 1.5) {
				//	if (!autocvar_g_balance_styeraug_drum75notincluded
			  	//	|| player.inv_misc_drum_styeraug_75)
			  	//	{
				//		return 1;
				//	} else {
				//		player.styeraug_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else
				if (player.styeraug_magazine == 1) {
					if (!autocvar_g_balance_styeraug_exmag42notincluded
			  		|| player.inv_misc_exmag_styeraug_42)
			  		{
						return 1;
					} else {
						player.styeraug_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.styeraug_magazine == -1) {
					return 1;
				}
				
				if (player.styeraug_magazine == 0) {
					if (!autocvar_g_balance_styeraug_mag30notincluded
			  		|| player.inv_misc_mag_styeraug_30)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.styeraug_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_StyerAug_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_styeraug_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_styeraug_reload_ammo;
		player.clip_load = autocvar_g_balance_styeraug_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_StyerAug_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_StyerAug_setmodelforanim(entity player) {
	//if (player.styeraug_magazine == 2) {
	//		player.weaponname = "styeraug_exm100";
	//} else if (player.styeraug_magazine == 1.5) {
	//		player.weaponname = "styeraug_drum75";
	//} else
	if (player.styeraug_magazine == 1) {
			player.weaponname = "styeraug_exm42";
	} else if (player.styeraug_magazine == -1) {
			player.weaponname = "styeraug_none";
	} else {
			player.weaponname = "styeraug";
	}
}

void W_StyerAug_setclipsize(entity player) {
	//if (player.styeraug_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_styeraug_reload_ammoexm2;
	//} else if (player.styeraug_magazine == 1.5) {
	//	player.clip_size = autocvar_g_balance_styeraug_reload_ammodrum;
	//} else
	if (player.styeraug_magazine == 1) {
		player.clip_size = autocvar_g_balance_styeraug_reload_ammoexm;
	} else if (player.styeraug_magazine == -1) {
		player.clip_size = autocvar_g_balance_styeraug_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_styeraug_reload_ammo;
	}
}

void W_StyerAug_setrefunddown(entity player) {
	//if (player.styeraug_magazine == 2) {
	//	W_StyerAug_refunddowntocustommag(player, autocvar_g_balance_styeraug_reload_ammoexm2);
	//} else if (player.styeraug_magazine == 1.5) {
	//	W_StyerAug_refunddowntocustommag(player, autocvar_g_balance_styeraug_reload_ammodrum);
	//} else
	if (player.styeraug_magazine == 1) {
		W_StyerAug_refunddowntocustommag(player, autocvar_g_balance_styeraug_reload_ammoexm);
	} else if (player.styeraug_magazine == -1) {
		W_StyerAug_refunddowntocustommag(player, autocvar_g_balance_styeraug_reload_ammonone);
	} else {
		W_StyerAug_refunddowntocustommag(player, autocvar_g_balance_styeraug_reload_ammo);
	}
}

float W_StyerAug_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_styeraug_mag30notincluded
	|| player.inv_misc_mag_styeraug_30)
	{
		return 0;
	} else if (!autocvar_g_balance_styeraug_exmag42notincluded
	|| player.inv_misc_exmag_styeraug_42)
	{
		return 1;
	}
	//else if (!autocvar_g_balance_styeraug_drum75notincluded
	//|| player.inv_misc_drum_styeraug_75)
	//{
	//	return 1.5;
	//} else if (!autocvar_g_balance_styeraug_exmag100notincluded
	//|| player.inv_misc_exmag_styeraug_100)
	//{
	//	return 2;					
	//}
	
	return currentmagwant;
}




void spawnfunc_weapon_styeraug (void)
{
	weapon_defaultspawnfunc(WEP_STYERAUG);
}

void w_styeraug_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.styeraug_magazine == 2) {
	//	myself.model = "models/weapons/g_styeraug_exm100.md3";
	//	
	//	if (autocvar_g_balance_styeraug_exmag100notincluded
	//	&& player.inv_misc_exmag_styeraug_100 >= 1) {
	//		player.inv_misc_exmag_styeraug_100 = player.inv_misc_exmag_styeraug_100 - 1;
	//		myself.inv_misc_exmag_styeraug_100 = myself.inv_misc_exmag_styeraug_100 + 1;
	//	}
	//	
	//	myself.styeraug_gsetmagazine = player.styeraug_magazine;
	//} else if (player.styeraug_magazine == 1.5) {
	//	myself.model = "models/weapons/g_styeraug_drum75.md3";
	//	
	//	if (autocvar_g_balance_styeraug_drum75notincluded
	//	&& player.inv_misc_drum_styeraug_75 >= 1) {
	//		player.inv_misc_drum_styeraug_75 = player.inv_misc_drum_styeraug_75 - 1;
	//		myself.inv_misc_drum_styeraug_75 = myself.inv_misc_drum_styeraug_75 + 1;
	//	}
	//	
	//	myself.styeraug_gsetmagazine = player.styeraug_magazine;
	//} else
	if (player.styeraug_magazine == 1) {
		myself.model = "models/weapons/g_styeraug_exm42.md3";
		
		if (autocvar_g_balance_styeraug_exmag42notincluded
		&& player.inv_misc_exmag_styeraug_42 >= 1) {
			player.inv_misc_exmag_styeraug_42 = player.inv_misc_exmag_styeraug_42 - 1;
			myself.inv_misc_exmag_styeraug_42 = myself.inv_misc_exmag_styeraug_42 + 1;
		}
		myself.styeraug_gsetmagazine = player.styeraug_magazine;
	} else if (player.styeraug_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_styeraug.md3";
		
		if (autocvar_g_balance_styeraug_mag30notincluded
		&& player.inv_misc_mag_styeraug_30 >= 1) {
			player.inv_misc_mag_styeraug_30 = player.inv_misc_mag_styeraug_30 - 1;
			myself.inv_misc_mag_styeraug_30 = myself.inv_misc_mag_styeraug_30 + 1;
		}
		myself.styeraug_gsetmagazine = player.styeraug_magazine;
	} else if (player.styeraug_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_styeraug_none.md3";
		
		myself.styeraug_gsetmagazine = player.styeraug_magazine;
	} else {
		//Do nothing
		myself.styeraug_gsetmagazine = 0;
	}
}

void w_styeraug_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_STYERAUG) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.styeraug_magazine = myself.styeraug_gsetmagazine;
			player.styeraug_pickedupgsetmagazine = myself.styeraug_gsetmagazine;
		}
	}
}




float w_styeraug_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.styeraug_customskin > 0)) {
		return player.styeraug_customskin;
	} else if (autocvar_g_balance_styeraug_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(styeraugautoskincolorset) {
			styeraugautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (styeraugautoskincolorset == -10) {
			return 0;
		} else if (styeraugautoskincolorset == 4) {
			//Snow
			return 1;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_styeraug_skin;
	}
}




.float styeraug_primarytime;

float w_styeraug(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For Aug, only the primary trigger is relevant for overheating
				//print(ftos(self.styeraug_overheat_cnt),"_Cooldown\n");
			
			if (self.styeraug_overheat_cnt < autocvar_g_balance_styeraug_heatmin) {
				self.styeraug_overheat_cnt = autocvar_g_balance_styeraug_heatmin;
			} else {
				self.styeraug_overheat_cnt = self.styeraug_overheat_cnt - (autocvar_g_balance_styeraug_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_StyerAug_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.styeraug_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		
		
			if (self.styeraug_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_styeraug_primary_speed, 0, 0.001, FALSE);
			}
			
			if (self.bot_aggresskill > 0.75) {
				//Full auto!
				self.BUTTON_ATCK2 = self.BUTTON_ATCK;
			} else if (self.bot_aggresskill > 0.50) {
				//Full auto maybe
				if (random() > 0.70) {
					self.BUTTON_ATCK2 = self.BUTTON_ATCK;
				}
			} else if (random() > 0.9) {
				//Full auto?
				self.BUTTON_ATCK2 = self.BUTTON_ATCK;
			}
		
	}
	else if (req == WR_THINK && !W_StyerAug_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_StyerAug_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_StyerAug_setclipsize(self);
			W_StyerAug_setrefunddown(self);
			W_StyerAug_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_styeraug_reload_ammo && self.clip_load < autocvar_g_balance_styeraug_primary_ammo) // forced reload
		{
			// don't force reload an empty styeraug if its melee attack is active
			if not(autocvar_g_balance_styeraug_secondary && self.ammo_nails < autocvar_g_balance_styeraug_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.styeraug_release = 0;
		}
		else
		{
		  if (self.styeraug_jammed && self.styeraug_unjam)
		  {
		  	if (time >= self.styeraug_unjam_time) {
				self.styeraug_jammed = 0;
				self.styeraug_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.styeraug_release || self.BUTTON_ATCK2)
			if (self.styeraug_jammed != 1)
			if ((time > self.styeraug_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.BUTTON_ATCK2) {
			  	//Fullauto (aug has a 2 stage trigger, simulating that)
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.styeraug_nextbot)," \n");
				} else {
					self.styeraug_nextbot = 0;
				}
				
				if (time >= self.styeraug_nextbot) {
					W_StyerAug_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_styeraug_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_styeraug_primary_animtime, w_ready);
					self.styeraug_release = 0;
					self.styeraug_animempty = 1;
					self.styeraug_animset = 1;
					self.styeraug_nextanim = time + autocvar_g_balance_styeraug_primary_rfanim;
					bp_skipme = 1;
					//self.styeraug_nextbot = time + (autocvar_g_balance_styeraug_primary_refire * 50 * random());
					self.styeraug_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.styeraug_release = 1;
					self.styeraug_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.styeraug_nextbot)," \n");
				} else {
					self.styeraug_nextbot = 0;
				}
				
				if (time >= self.styeraug_nextbot) {
					W_StyerAug_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_styeraug_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_styeraug_secondary_animtime, w_ready);
					self.styeraug_release = 0;
					self.styeraug_animempty = 1;
					self.styeraug_animset = 1;
					self.styeraug_nextanim = time + autocvar_g_balance_styeraug_secondary_rfanim;
					bp_skipme = 1;
					//self.styeraug_nextbot = time + (autocvar_g_balance_styeraug_secondary_refire * 50 * random());
					self.styeraug_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			
			if not(bp_skipme) {
				if (self.styeraug_jammed != 1)
				if (time >= self.styeraug_nextanim)
				if (self.styeraug_animempty)
				{
					self.styeraug_animempty = 0;
					self.styeraug_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.styeraug_release = 1;
			}
			
			if not(self.BUTTON_ATCK && self.BUTTON_ATCK2) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.styeraug_animset)
			//if (self.styeraug_jammed != 1) {
			//	
			//		if (self.styeraug_animempty)
			//			self.weaponname = "styeraug_empty";
			//		else
			//			self.weaponname = "styeraug";
			//}
			
			self.styeraug_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_StyerAug_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_StyerAug_setclipsize(self);
			W_StyerAug_setrefunddown(self);
			W_StyerAug_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_styeraug.md3");
		precache_model ("models/weapons/v_styeraug.md3");
		precache_model ("models/weapons/h_styeraug.iqm");
		
		//precache_model ("models/weapons/v_styeraug_empty.md3");
		//precache_model ("models/weapons/h_styeraug_empty.iqm");
		
		precache_model ("models/weapons/g_styeraug_exm42.md3");
		precache_model ("models/weapons/v_styeraug_exm42.md3");
		precache_model ("models/weapons/h_styeraug_exm42.iqm");
		//precache_model ("models/weapons/v_styeraug_exm42_empty.md3");
		//precache_model ("models/weapons/h_styeraug_exm42_empty.iqm");
		
		precache_model ("models/weapons/g_styeraug_none.md3");
		precache_model ("models/weapons/v_styeraug_none.md3");
		precache_model ("models/weapons/h_styeraug_none.iqm");
		//precache_model ("models/weapons/v_styeraug_none_empty.md3");
		//precache_model ("models/weapons/h_styeraug_none_empty.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire_aug.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.styeraug_overheat_cnt = autocvar_g_balance_styeraug_heatmin;
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -3.3'; //To look down scope (but it isn't magnified... model...)
		//self.weaponaltaim = '45 0.02 -4.2'; //Ironsights
		//self.weaponaltaim = '50 0.02 -4.4'; //Ironsights
		self.weaponaltaim = '48 0.02 -4.3'; //Ironsights
		weapon_setup(WEP_STYERAUG);
		self.current_ammo = ammo_nails;
		
		
			//if (self.styeraug_animempty)
			//	self.weaponname = "styeraug_empty";
			//else
			//	self.weaponname = "styeraug";
		
		
			
			
			//Make sure we're allowed to have.
			W_StyerAug_allowedextendedmags(self);
			
			if (self.styeraug_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.styeraug_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 30 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.styeraug_magazine = W_StyerAug_tryforvalidmag(self, self.styeraug_magazine);
					W_StyerAug_allowedextendedmags(self);
				}
			}
			
			self.styeraug_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_StyerAug_setmodelforanim(self);
				
		
		
				
	
		
		  if (self.styeraug_jammed && self.styeraug_unjam)
		  {
		  	if (time >= self.styeraug_unjam_time) {
				self.styeraug_jammed = 0;
				self.styeraug_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_StyerAug_setclipsize(self);
		W_StyerAug_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_styeraug_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_STYERAUG]) >= autocvar_g_balance_styeraug_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.styeraug_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_styeraug_clearjam_time, w_ready);
			if (self.styeraug_unjam != 1) {
				self.styeraug_unjam = 1;
				self.styeraug_unjam_time = time + autocvar_g_balance_styeraug_clearjam_time;
				self.styeraug_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float styeraugdonothing;
			styeraugdonothing = 0;
			if (self.BUTTON_USE) {
			  if (self.styeraug_magazine_changetime >= time) {
			  	//Do nothing
				styeraugdonothing = 1;
			  } else {
				local float styeraugmagwant;
				if (self.styeraug_magazine == 1) {
					styeraugmagwant = 0;
					//////styeraugmagwant = 1.5;
				//} else if (self.styeraug_magazine == 1.5) {
				//	styeraugmagwant = 2;	
				//} else if (self.styeraug_magazine == 2) {
				//	styeraugmagwant = 0;	
				} else {
					//self.styeraug_magazine == 0
					styeraugmagwant = 1;
				}				
				
				if (styeraugmagwant == 1) {
					if (!autocvar_g_balance_styeraug_exmag42notincluded
			  		|| self.inv_misc_exmag_styeraug_42)
			  		{
						//Yes
					} else {
						//No
						//	styeraugmagwant = 1.5; //fallback
						styeraugmagwant = 0; //fallback
					}
				}				
				
				//if (styeraugmagwant == 1.5) {
				//	if (!autocvar_g_balance_styeraug_drum75notincluded
			  	//	|| self.inv_misc_drum_styeraug_75)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			styeraugmagwant = 2; //fallback
				//	}
				//}
				
				//if (styeraugmagwant == 2) {
				//	if (!autocvar_g_balance_styeraug_exmag100notincluded
			  	//	|| self.inv_misc_exmag_styeraug_100)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			styeraugmagwant = 0; //fallback
				//	}
				//}
				
				//If no magazines available...
				if (styeraugmagwant == 0) {
					if (!autocvar_g_balance_styeraug_mag30notincluded
			  		|| self.inv_misc_mag_styeraug_30)
			  		{
						//Yes
					} else {
						//No
							styeraugmagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (styeraugmagwant == -1) {
					styeraugmagwant = W_StyerAug_tryforvalidmag(self, styeraugmagwant);
				}
				//Final decisions
				
				if (styeraugmagwant == self.styeraug_magazine) {
					styeraugdonothing = 1;
				//} else if (styeraugmagwant == 2) {
				//	self.styeraug_magazine = 2;
				//} else if (styeraugmagwant == 1.5) {
				//	self.styeraug_magazine = 1.5;
				} else if (styeraugmagwant == 1) {
					self.styeraug_magazine = 1;
				} else if (styeraugmagwant == 0) {
					self.styeraug_magazine = 0;
				} else if (styeraugmagwant == -1) {
					self.styeraug_magazine = -1;
				}
				
				W_StyerAug_setmodelforanim(self);
			  }
			}
		
			if (styeraugdonothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.styeraug_magazine == 2) {
			//	W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammoexm2, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
			//	
			//	W_StyerAug_refunddowntocustommag(self, autocvar_g_balance_styeraug_reload_ammoexm2);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammoexm2, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
			//	W_StyerAug_setclipsize(self);
			//	self.styeraug_magazine_changetime = time + self.reload_time;
			//} else if (self.styeraug_magazine == 1.5) {
			//	W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammodrum, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
			//	
			//	W_StyerAug_refunddowntocustommag(self, autocvar_g_balance_styeraug_reload_ammodrum);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammodrum, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
			//	W_StyerAug_setclipsize(self);
			//	self.styeraug_magazine_changetime = time + self.reload_time;
			} else if (self.styeraug_magazine == 1) {
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammoexm, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				
				W_StyerAug_refunddowntocustommag(self, autocvar_g_balance_styeraug_reload_ammoexm);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammoexm, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				W_StyerAug_setclipsize(self);
				self.styeraug_magazine_changetime = time + self.reload_time;
			} else if (self.styeraug_magazine == -1) {
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammonone, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_StyerAug_refunddowntocustommag(self, autocvar_g_balance_styeraug_reload_ammonone);
				
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammonone, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				W_StyerAug_setclipsize(self);
				self.styeraug_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammo, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_StyerAug_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammo, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
				W_StyerAug_setclipsize(self);
				self.styeraug_magazine_changetime = time + self.reload_time;
			}
			
			
			//W_Reload(autocvar_g_balance_styeraug_primary_ammo, autocvar_g_balance_styeraug_reload_ammo, autocvar_g_balance_styeraug_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_styeraug(float req)
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
			w_deathtypestring = _("%s developed small accurately placed holes in the chest thanks to %s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s enjoyed greeting from Austria from %s's Aug");
		else
			w_deathtypestring = _("%s shot dead by %s with a Styer Aug");
	}
	return TRUE;
}
#endif
#endif
