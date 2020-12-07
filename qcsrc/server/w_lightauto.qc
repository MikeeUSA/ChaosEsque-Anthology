#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LIGHTAUTO, w_lightauto, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "lightauto", "lightauto", _("9mm AutoPistol"))
#else
#ifdef SVQC

.float lightauto_release;
.float lightauto_jammed;
.float lightauto_unjam;
.float lightauto_unjam_time;
.float lightauto_click;
.float lightauto_suppressed;
.float lightauto_animempty;
.float lightauto_animset;
.float lightauto_nextanim;
.float lightauto_nextbot;
.float lightauto_overheat_cnt;
.float lightauto_overheated_until;
.float lightauto_magazine; //0normal(32), 1 50rnd, 2 106rnd
.float lightauto_magazine_changetime;
.float lightauto_gsetmagazine; //For ground model setting propagation
.float lightauto_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup
.float lightauto_gsetsuppressed; //For ground model setting propagation

float lightautoautoskincolorset;

.float lightauto_customskin;
float w_p90_skin_autocolorset(void);

void W_LightAuto_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_lightauto_primary_ammo;
	d = autocvar_g_balance_lightauto_primary_damage;
	f = autocvar_g_balance_lightauto_primary_force;
	//spread = autocvar_g_balance_lightauto_primary_spread;
	spread = bound(autocvar_g_balance_lightauto_spread_min, autocvar_g_balance_lightauto_spread_min + (autocvar_g_balance_lightauto_spread_add * self.misc_bulletcounter), autocvar_g_balance_lightauto_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_lightauto_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_9mm_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_lightauto_reload_ammo);
	
	if (autocvar_g_balance_lightauto_jamrate &&
 	(autocvar_g_balance_lightauto_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your 9mm jammed\n");
		}
		self.lightauto_jammed = 1;
	} else { //Start Not Jammed

	if not(self.lightauto_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_wppq_fire.wav", CH_WEAPON_A, d);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_lightauto_primary_headshotaddeddamage, f, WEP_LIGHTAUTO, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_lightauto_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	if not(self.lightauto_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_lightauto_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_lightauto_gunrise, random() * autocvar_g_balance_lightauto_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '0.25 0 0');
	} else {
		PlayerGunRise(self, autocvar_g_balance_lightauto_suppressed_gunrise, random() * autocvar_g_balance_lightauto_suppressed_gunrun);	
	}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.lightauto_overheat_cnt),"_Firing\n");
		
	    	self.lightauto_overheat_cnt = self.lightauto_overheat_cnt + autocvar_g_balance_lightauto_heatconstant;
         
	    	if (self.lightauto_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your automatic pistol overheated\n");
			}
				
			self.lightauto_overheated_until = time + (autocvar_g_balance_lightauto_cooldownwait * (self.lightauto_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_LightAuto_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_lightauto_reload_ammo && self.clip_load < autocvar_g_balance_lightauto_primary_ammo))
	{
		if (!self.lightauto_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.lightauto_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.lightauto_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}




float W_LightAuto_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				if (player.lightauto_magazine == 2) {
					if (!autocvar_g_balance_lightauto_betacmagnotincluded
			  		|| player.inv_misc_betacmag_lightpistol)
			  		{
						return 1;
					} else {
						player.lightauto_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.lightauto_magazine == 1) {
					if (!autocvar_g_balance_lightauto_drumnotincluded
			  		|| player.inv_misc_drum_lightpistol)
			  		{
						return 1;
					} else {
						player.lightauto_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.lightauto_magazine == -0.50) {
					if (!autocvar_g_balance_lightauto_magnotincluded
			  		|| player.inv_misc_mag_lightpistol)
			  		{
						return 1;
					} else {
						player.lightauto_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.lightauto_magazine == -1) {
					return 1;
				}
				
				if (player.lightauto_magazine == 0) {
					if (!autocvar_g_balance_lightauto_exmagnotincluded
			  		|| player.inv_misc_exmag_lightpistol)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.lightauto_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_LightAuto_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_lightauto_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_lightauto_reload_ammo;
		player.clip_load = autocvar_g_balance_lightauto_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_LightAuto_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_LightAuto_setmodelforanim(entity player) {
	if (player.lightauto_suppressed) {
		if (player.lightauto_magazine == 2) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_betacmag_suppressed_empty";
			else
				player.weaponname = "lightauto_betacmag_suppressed";
		} else if (player.lightauto_magazine == 1) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_drum_suppressed_empty";
			else
				player.weaponname = "lightauto_drum_suppressed";
		} else if (player.lightauto_magazine == -0.50) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_mag_suppressed_empty";
			else
				player.weaponname = "lightauto_mag_suppressed";
		} else if (player.lightauto_magazine == -1) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_none_suppressed_empty";
			else
				player.weaponname = "lightauto_none_suppressed";
		} else {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_suppressed_empty";
			else
				player.weaponname = "lightauto_suppressed";
		}
	} else {
		if (player.lightauto_magazine == 2) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_betacmag_empty";
			else
				player.weaponname = "lightauto_betacmag";
		} else if (player.lightauto_magazine == 1) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_drum_empty";
			else
				player.weaponname = "lightauto_drum";
		} else if (player.lightauto_magazine == -0.50) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_mag_empty";
			else
				player.weaponname = "lightauto_mag";
		} else if (player.lightauto_magazine == -1) {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_none_empty";
			else
				player.weaponname = "lightauto_none";
		} else {
			if (player.lightauto_animempty)
				player.weaponname = "lightauto_empty";
			else
				player.weaponname = "lightauto";
		}
	}
}

void W_LightAuto_setclipsize(entity player) {
	if (player.lightauto_magazine == 2) {
		player.clip_size = autocvar_g_balance_lightauto_reload_ammobetacmag;
	} else if (player.lightauto_magazine == 1) {
		player.clip_size = autocvar_g_balance_lightauto_reload_ammodrum;
	} else if (player.lightauto_magazine == -0.5) {
		player.clip_size = autocvar_g_balance_lightauto_reload_ammomag;
	} else if (player.lightauto_magazine == -1) {
		player.clip_size = autocvar_g_balance_lightauto_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_lightauto_reload_ammo;
	}
}

void W_LightAuto_setrefunddown(entity player) {
	if (player.lightauto_magazine == 2) {
		W_LightAuto_refunddowntocustommag(player, autocvar_g_balance_lightauto_reload_ammobetacmag);
	} else if (player.lightauto_magazine == 1) {
		W_LightAuto_refunddowntocustommag(player, autocvar_g_balance_lightauto_reload_ammodrum);
	} else if (player.lightauto_magazine == -0.5) {
		W_LightAuto_refunddowntocustommag(player, autocvar_g_balance_lightauto_reload_ammomag);	
	} else if (player.lightauto_magazine == -1) {
		W_LightAuto_refunddowntocustommag(player, autocvar_g_balance_lightauto_reload_ammonone);
	} else {
		W_LightAuto_refunddowntocustommag(player, autocvar_g_balance_lightauto_reload_ammo);
	}
}

float W_LightAuto_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_lightauto_exmagnotincluded
	|| player.inv_misc_exmag_lightpistol)
	{
		return 0;
	} else if (!autocvar_g_balance_lightauto_drumnotincluded
	|| player.inv_misc_drum_lightpistol)
	{
		return 1;
	} else if (!autocvar_g_balance_lightauto_betacmagnotincluded
	|| player.inv_misc_betacmag_lightpistol)
	{
		return 2;				
	} else if (!autocvar_g_balance_lightauto_magnotincluded
	|| player.inv_misc_mag_lightpistol)
	{
		return (-0.50);					
	}
	
	return currentmagwant;
}



void spawnfunc_weapon_lightauto (void)
{
	weapon_defaultspawnfunc(WEP_LIGHTAUTO);
}

float w_lightauto_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.lightauto_customskin > 0)) {
		return player.lightauto_customskin;
	} else if (autocvar_g_balance_lightauto_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(lightautoautoskincolorset) {
			lightautoautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (lightautoautoskincolorset == -10) {
			return 0;
		} else if (lightautoautoskincolorset == 1) {
			//Dust
			return 1;
		} else if (lightautoautoskincolorset == 4) {
			//Snow
			return 2;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_lightauto_skin;
	}
}



void w_lightauto_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.lightauto_suppressed) {
		myself.model = "models/weapons/g_lightauto_suppressed.md3";
		
		if (autocvar_g_balance_lightauto_suppressornotincluded
		&& player.inv_misc_suppressor9mm >= 1) {
			player.inv_misc_suppressor9mm = player.inv_misc_suppressor9mm - 1;
			myself.inv_misc_suppressor9mm = myself.inv_misc_suppressor9mm + 1;
		}
		
		myself.lightauto_gsetsuppressed = player.lightauto_suppressed;
	} else {
		//Do nothing
		myself.lightauto_gsetsuppressed = 0;
	}

	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.lightauto_magazine == 2) {
		if (player.lightauto_suppressed) {
			myself.model = "models/weapons/g_lightauto_betacmag_suppressed.md3";
		} else {
			myself.model = "models/weapons/g_lightauto_betacmag.md3";
		}
		
		if (autocvar_g_balance_lightauto_betacmagnotincluded
		&& player.inv_misc_betacmag_lightpistol >= 1) {
			player.inv_misc_betacmag_lightpistol = player.inv_misc_betacmag_lightpistol - 1;
			myself.inv_misc_betacmag_lightpistol = myself.inv_misc_betacmag_lightpistol + 1;
		}
		
		myself.lightauto_gsetmagazine = player.lightauto_magazine;
	} else if (player.lightauto_magazine == 1) {
		if (player.lightauto_suppressed) {
			myself.model = "models/weapons/g_lightauto_drum_suppressed.md3";
		} else {
			myself.model = "models/weapons/g_lightauto_drum.md3";
		}
		
		if (autocvar_g_balance_lightauto_drumnotincluded
		&& player.inv_misc_drum_lightpistol >= 1) {
			player.inv_misc_drum_lightpistol = player.inv_misc_drum_lightpistol - 1;
			myself.inv_misc_drum_lightpistol = myself.inv_misc_drum_lightpistol + 1;
		}
		myself.lightauto_gsetmagazine = player.lightauto_magazine;
	} else if (player.lightauto_magazine == 0) {
		//Standard
		if (player.lightauto_suppressed) {
			myself.model = "models/weapons/g_lightauto_suppressed.md3";
		} else {
			//////Allready set //myself.model = "models/weapons/g_lightauto.md3";
		}
		
		if (autocvar_g_balance_lightauto_exmagnotincluded
		&& player.inv_misc_exmag_lightpistol >= 1) {
			player.inv_misc_exmag_lightpistol = player.inv_misc_exmag_lightpistol - 1;
			myself.inv_misc_exmag_lightpistol = myself.inv_misc_exmag_lightpistol + 1;
		}
		myself.lightauto_gsetmagazine = player.lightauto_magazine;
	} else if (player.lightauto_magazine == -0.5) {
		if (player.lightauto_suppressed) {
			myself.model = "models/weapons/g_lightauto_mag_suppressed.md3";
		} else {
			myself.model = "models/weapons/g_lightauto_mag.md3";
		}
		
		if (autocvar_g_balance_lightauto_magnotincluded
		&& player.inv_misc_mag_lightpistol >= 1) {
			player.inv_misc_mag_lightpistol = player.inv_misc_mag_lightpistol - 1;
			myself.inv_misc_mag_lightpistol = myself.inv_misc_mag_lightpistol + 1;
		}
		myself.lightauto_gsetmagazine = player.lightauto_magazine;
	} else if (player.lightauto_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_lightauto_none.md3";
		
		myself.lightauto_gsetmagazine = player.lightauto_magazine;
	} else {
		//Do nothing
		myself.lightauto_gsetmagazine = 0;
	}
}

void w_lightauto_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_LIGHTAUTO) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.lightauto_magazine = myself.lightauto_gsetmagazine;
			player.lightauto_pickedupgsetmagazine = myself.lightauto_gsetmagazine;
			player.lightauto_suppressed = myself.lightauto_gsetsuppressed;
		}
	}
}


float lightauto_suppressorattachdetach(void)
{
 			  if (!autocvar_g_balance_lightauto_suppressornotincluded
			  || self.inv_misc_suppressor9mm)
			  {
				if (self.lightauto_suppressed) {
					self.lightauto_suppressed = 0;
					//if (self.lightauto_animempty)
					//	self.weaponname = "lightauto_empty";
					//else
					//	self.weaponname = "lightauto";
				} else if (!self.lightauto_suppressed) {
					self.lightauto_suppressed = 1;
					//if (self.lightauto_animempty)
					//	self.weaponname = "lightauto_suppressed_empty";
					//else
					//	self.weaponname = "lightauto_suppressed";
				}
				W_LightAuto_setmodelforanim(self);
				return TRUE;
			  }
			  return FALSE;
}

.float lightauto_primarytime;

float w_lightauto(float req)
{
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.lightauto_overheat_cnt),"_Cooldown\n");
			
			if (self.lightauto_overheat_cnt < autocvar_g_balance_lightauto_heatmin) {
				self.lightauto_overheat_cnt = autocvar_g_balance_lightauto_heatmin;
			} else {
				self.lightauto_overheat_cnt = self.lightauto_overheat_cnt - (autocvar_g_balance_lightauto_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_LightAuto_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.lightauto_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.lightauto_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_lightauto_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_LightAuto_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_LightAuto_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_LightAuto_refunddowntostdmag(self);
			//print(ftos(self.lightauto_magazine), "Here222\n");
			//////self.lightauto_magazine = W_LightAuto_tryforvalidmag(self, self.lightauto_magazine);
			W_LightAuto_setclipsize(self);
			W_LightAuto_setrefunddown(self);
			W_LightAuto_setmodelforanim(self);
		}
		
		if (self.lightauto_suppressed) {
			if (!autocvar_g_balance_lightauto_suppressornotincluded
			|| self.inv_misc_suppressor9mm)
			{
				//Nothing
			} else {
				self.lightauto_suppressed = 0;
				self.lightauto_animset = 1;
			}
		}
	
	
	
		if(autocvar_g_balance_lightauto_reload_ammo && self.clip_load < autocvar_g_balance_lightauto_primary_ammo) // forced reload
		{
			// don't force reload an empty lightauto if its melee attack is active
			if not(autocvar_g_balance_lightauto_secondary && self.ammo_nails < autocvar_g_balance_lightauto_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.lightauto_release = 0;
		}
		else
		{
		  if (self.lightauto_jammed && self.lightauto_unjam)
		  {
		  	if (time >= self.lightauto_unjam_time) {
				self.lightauto_jammed = 0;
				self.lightauto_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.lightauto_release)
			if (self.lightauto_jammed != 1)
			if ((time > self.lightauto_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.lightauto_nextbot)," \n");
				} else {
					self.lightauto_nextbot = 0;
				}
				
				if (time >= self.lightauto_nextbot) {
					W_LightAuto_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_lightauto_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightauto_primary_animtime, w_ready);
					self.lightauto_release = 0;
					self.lightauto_animempty = 1;
					self.lightauto_animset = 1;
					self.lightauto_nextanim = time + autocvar_g_balance_lightauto_primary_rfanim;
					bp_skipme = 1;
					//self.lightauto_nextbot = time + (autocvar_g_balance_lightauto_primary_refire * 50 * random());
					self.lightauto_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.lightauto_release = 1;
					self.lightauto_nextbot = time;
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.lightauto_release)
			if (self.lightauto_jammed != 1)
			if ((time > self.lightauto_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.lightauto_nextbot)," \n");
				} else {
					self.lightauto_nextbot = 0;
				}
				
				if (time >= self.lightauto_nextbot) {
					W_LightAuto_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_lightauto_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightauto_secondary_animtime, w_ready);
					self.lightauto_release = 0;
					self.lightauto_animempty = 1;
					self.lightauto_animset = 1;
					self.lightauto_nextanim = time + autocvar_g_balance_lightauto_secondary_rfanim;
					bp_skipme = 1;
					//self.lightauto_nextbot = time + (autocvar_g_balance_lightauto_secondary_refire * 50 * random());
					self.lightauto_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_lightauto_fullauto == 1) {
						self.lightauto_release = 1;
						self.lightauto_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.lightauto_jammed != 1)
				if (time >= self.lightauto_nextanim)
				if (self.lightauto_animempty)
				{
					self.lightauto_animempty = 0;
					self.lightauto_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.lightauto_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.lightauto_animset)
			if (self.lightauto_jammed != 1) {
				W_LightAuto_setmodelforanim(self);
				//if (self.lightauto_suppressed) {
				//	if (self.lightauto_animempty)
				//		self.weaponname = "lightauto_suppressed_empty";
				//	else
				//		self.weaponname = "lightauto_suppressed";
				//} else if (!self.lightauto_suppressed) {
				//	if (self.lightauto_animempty)
				//		self.weaponname = "lightauto_empty";
				//	else
				//		self.weaponname = "lightauto";
				//}
			}
			
			self.lightauto_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_LightAuto_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_LightAuto_refunddowntostdmag(self);
			W_LightAuto_setclipsize(self);
			W_LightAuto_setrefunddown(self);
			W_LightAuto_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_lightauto.md3");
		precache_model ("models/weapons/v_lightauto.md3");
		precache_model ("models/weapons/v_lightauto_suppressed.md3");
		precache_model ("models/weapons/h_lightauto.iqm");
		precache_model ("models/weapons/h_lightauto_suppressed.iqm");
		
		precache_model ("models/weapons/v_lightauto_empty.md3");
		precache_model ("models/weapons/v_lightauto_suppressed_empty.md3");
		precache_model ("models/weapons/h_lightauto_empty.iqm");
		precache_model ("models/weapons/h_lightauto_suppressed_empty.iqm");
		
		precache_model ("models/weapons/g_lightauto_mag.md3");
		precache_model ("models/weapons/v_lightauto_mag.md3");
		precache_model ("models/weapons/v_lightauto_mag_suppressed.md3");
		precache_model ("models/weapons/h_lightauto_mag.iqm");
		precache_model ("models/weapons/h_lightauto_mag_suppressed.iqm");
		
		precache_model ("models/weapons/v_lightauto_mag_empty.md3");
		precache_model ("models/weapons/v_lightauto_mag_suppressed_empty.md3");
		precache_model ("models/weapons/h_lightauto_mag_empty.iqm");
		precache_model ("models/weapons/h_lightauto_mag_suppressed_empty.iqm");
		
		precache_model ("models/weapons/g_lightauto_drum.md3");
		precache_model ("models/weapons/v_lightauto_drum.md3");
		precache_model ("models/weapons/v_lightauto_drum_suppressed.md3");
		precache_model ("models/weapons/h_lightauto_drum.iqm");
		precache_model ("models/weapons/h_lightauto_drum_suppressed.iqm");
		
		precache_model ("models/weapons/v_lightauto_drum_empty.md3");
		precache_model ("models/weapons/v_lightauto_drum_suppressed_empty.md3");
		precache_model ("models/weapons/h_lightauto_drum_empty.iqm");
		precache_model ("models/weapons/h_lightauto_drum_suppressed_empty.iqm");
		
		precache_model ("models/weapons/g_lightauto_betacmag.md3");
		precache_model ("models/weapons/v_lightauto_betacmag.md3");
		precache_model ("models/weapons/v_lightauto_betacmag_suppressed.md3");
		precache_model ("models/weapons/h_lightauto_betacmag.iqm");
		precache_model ("models/weapons/h_lightauto_betacmag_suppressed.iqm");
		
		precache_model ("models/weapons/v_lightauto_betacmag_empty.md3");
		precache_model ("models/weapons/v_lightauto_betacmag_suppressed_empty.md3");
		precache_model ("models/weapons/h_lightauto_betacmag_empty.iqm");
		precache_model ("models/weapons/h_lightauto_betacmag_suppressed_empty.iqm");
		
		precache_model ("models/weapons/g_lightauto_none.md3");
		precache_model ("models/weapons/v_lightauto_none.md3");
		precache_model ("models/weapons/v_lightauto_none_suppressed.md3");
		precache_model ("models/weapons/h_lightauto_none.iqm");
		precache_model ("models/weapons/h_lightauto_none_suppressed.iqm");
		
		precache_model ("models/weapons/v_lightauto_none_empty.md3");
		precache_model ("models/weapons/v_lightauto_none_suppressed_empty.md3");
		precache_model ("models/weapons/h_lightauto_none_empty.iqm");
		precache_model ("models/weapons/h_lightauto_none_suppressed_empty.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_wppq_fire.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.lightauto_overheat_cnt = autocvar_g_balance_lightauto_heatmin;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -0.9';
			
		weapon_setup(WEP_LIGHTAUTO);
		self.current_ammo = ammo_nails;
		
		//if (!autocvar_g_balance_lightauto_suppressornotincluded
		//|| self.inv_misc_suppressor9mm)
		//{
		//	if (self.lightauto_suppressed) {
		//		if (self.lightauto_animempty)
		//			self.weaponname = "lightauto_suppressed_empty";
		//		else
		//			self.weaponname = "lightauto_suppressed";
		//	} else if (!self.lightauto_suppressed) {
		//		if (self.lightauto_animempty)
		//			self.weaponname = "lightauto_empty";
		//		else
		//			self.weaponname = "lightauto";
		//	}
		//} else {
		//	self.lightauto_suppressed = 0;
		//	
		//	if (self.lightauto_animempty)
		//		self.weaponname = "lightauto_empty";
		//	else
		//		self.weaponname = "lightauto";
		//}
		
		
			//Make sure we're allowed to have.
			W_LightAuto_allowedextendedmags(self);
			
			if (self.lightauto_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.lightauto_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 32 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.lightauto_magazine = W_LightAuto_tryforvalidmag(self, self.lightauto_magazine);
					W_LightAuto_allowedextendedmags(self);
				}
			}
			
			self.lightauto_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_LightAuto_setmodelforanim(self);
		
		
		  if (self.lightauto_jammed && self.lightauto_unjam)
		  {
		  	if (time >= self.lightauto_unjam_time) {
				self.lightauto_jammed = 0;
				self.lightauto_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_LightAuto_setclipsize(self);
		W_LightAuto_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_lightauto_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LIGHTAUTO]) >= autocvar_g_balance_lightauto_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.lightauto_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_lightauto_clearjam_time, w_ready);
			if (self.lightauto_unjam != 1) {
				self.lightauto_unjam = 1;
				self.lightauto_unjam_time = time + autocvar_g_balance_lightauto_clearjam_time;
				self.lightauto_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			//W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammo, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
			local float lightautodonothing;
			lightautodonothing = 0;
			
			local float lightautosuppressorallowed;
			local float lightautosuppressortried;
			
			lightautosuppressorallowed = 0;
			lightautosuppressortried = 0;
			
			if (self.BUTTON_USE && self.crouch) {
				lightautosuppressorallowed = lightauto_suppressorattachdetach();
				lightautosuppressortried = 1;
			} else if (self.BUTTON_USE
			&&
			(!(!autocvar_g_balance_lightauto_magnotincluded
			|| self.inv_misc_mag_lightpistol))
			
			&& (!(!autocvar_g_balance_lightauto_drumnotincluded
			|| self.inv_misc_drum_lightpistol))
			
			&& (!(!autocvar_g_balance_lightauto_betacmagnotincluded
			|| self.inv_misc_betacmag_lightpistol))
			
			&& (!autocvar_g_balance_lightauto_exmagnotincluded
			|| self.inv_misc_exmag_lightpistol)
			
			) {
				//If standard configuration and no different magazine pickups.
				//then switch suppressor if possible
				lightautosuppressorallowed = lightauto_suppressorattachdetach();
				lightautosuppressortried = 1;
			}
			
			//This is so if you do not have a suppressor, you can press button_use
			//plus R and anything else to change magazine,
			//But if you do have a suppressor, you add shift to the combo and add/remove suppressor
			//But if you have no magazines, other than the standard one, you can add/remove
			//suppressor just with R and button_use but not need shift
			if ((!lightautosuppressortried && self.BUTTON_USE)
			|| (lightautosuppressortried && !lightautosuppressorallowed)) {
			  if (self.lightauto_magazine_changetime >= time) {
			  	//Do nothing
				lightautodonothing = 1;
			  } else {
				local float lightautomagwant;
				if (self.lightauto_magazine == -0.5) {
					lightautomagwant = 0;
				} else if (self.lightauto_magazine == 1) {
					lightautomagwant = 2;	
				} else if (self.lightauto_magazine == 2) {
					lightautomagwant = -0.5;	
				} else {
					//self.lightauto_magazine == 0
					lightautomagwant = 1;
				}
				
				if (lightautomagwant == -0.5) {
					if (!autocvar_g_balance_lightauto_magnotincluded
			  		|| self.inv_misc_mag_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = 0; //fallback
					}
				}
				
				//Where standard comes in
				//Keeping with the pattern
				if (lightautomagwant == 0) {
					if (!autocvar_g_balance_lightauto_exmagnotincluded
			  		|| self.inv_misc_exmag_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = 1; //fallback
					}
				}
								
				if (lightautomagwant == 1) {
					if (!autocvar_g_balance_lightauto_drumnotincluded
			  		|| self.inv_misc_drum_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = 2; //fallback
					}
				}
				
				if (lightautomagwant == 2) {
					if (!autocvar_g_balance_lightauto_betacmagnotincluded
			  		|| self.inv_misc_betacmag_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = -0.5; //fallback
					}
				}
				
				if (lightautomagwant == -0.5) {
					if (!autocvar_g_balance_lightauto_magnotincluded
			  		|| self.inv_misc_mag_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = 0; //fallback
					}
				}
				
				//If no magazines available...
				if (lightautomagwant == 0) {
					if (!autocvar_g_balance_lightauto_exmagnotincluded
			  		|| self.inv_misc_exmag_lightpistol)
			  		{
						//Yes
					} else {
						//No
							lightautomagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (lightautomagwant == -1) {
					lightautomagwant = W_LightAuto_tryforvalidmag(self, lightautomagwant);
				}
				//Final decisions
				
				if (lightautomagwant == self.lightauto_magazine) {
					lightautodonothing = 1;
				} else if (lightautomagwant == 2) {
					self.lightauto_magazine = 2;
				} else if (lightautomagwant == 1.5) {
					self.lightauto_magazine = 1.5;
				} else if (lightautomagwant == 1) {
					self.lightauto_magazine = 1;
				} else if (lightautomagwant == 0.5) {
					self.lightauto_magazine = 0.5;
				} else if (lightautomagwant == 0) {
					self.lightauto_magazine = 0;
				} else if (lightautomagwant == -0.25) {
					self.lightauto_magazine = -0.25;
				} else if (lightautomagwant == -0.5) {
					self.lightauto_magazine = -0.5;
				} else if (lightautomagwant == -1) {
					self.lightauto_magazine = -1;
				}
				
				W_LightAuto_setmodelforanim(self);
			  }
			}
		
			if (lightautodonothing) {
				//print(ftos(time),"Doing nothing\n");
			} else if (self.lightauto_magazine == 2) {
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammobetacmag, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				
				W_LightAuto_refunddowntocustommag(self, autocvar_g_balance_lightauto_reload_ammobetacmag);
				//Normally no refund here since selection goes up
	
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammobetacmag, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				W_LightAuto_setclipsize(self);
				self.lightauto_magazine_changetime = time + self.reload_time;
			} else if (self.lightauto_magazine == 1) {
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammodrum, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				
				W_LightAuto_refunddowntocustommag(self, autocvar_g_balance_lightauto_reload_ammodrum);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammodrum, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				W_LightAuto_setclipsize(self);
				self.lightauto_magazine_changetime = time + self.reload_time;
			} else if (self.lightauto_magazine == -0.5) {
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammomag, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				
				W_LightAuto_refunddowntocustommag(self, autocvar_g_balance_lightauto_reload_ammomag);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammomag, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				W_LightAuto_setclipsize(self);
				self.lightauto_magazine_changetime = time + self.reload_time;
			} else if (self.lightauto_magazine == -1) {
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammonone, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_LightAuto_refunddowntocustommag(self, autocvar_g_balance_lightauto_reload_ammonone);
				
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammonone, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				W_LightAuto_setclipsize(self);
				self.lightauto_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammo, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_LightAuto_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_lightauto_primary_ammo, autocvar_g_balance_lightauto_reload_ammo, autocvar_g_balance_lightauto_reload_time, "weapons/reload.wav");
				W_LightAuto_setclipsize(self);
				self.lightauto_magazine_changetime = time + self.reload_time;
			}
			//
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_lightauto(float req)
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
			w_deathtypestring = _("%1$s chest was ventelated by %2$s 9mm machine pistol");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s shot them in the head with a select-fire 9mm");
		else
			w_deathtypestring = _("%s was kiled by %s's 9mm full-auto");
	}
	return TRUE;
}
#endif
#endif
