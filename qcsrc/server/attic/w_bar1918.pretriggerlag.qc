#ifdef REGISTER_WEAPON
REGISTER_WEAPON(BAR1918, w_bar1918, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "bar1918", "bar1918", _("BAR-1918"))
#else
#ifdef SVQC

.float bar1918_release;
.float bar1918_jammed;
.float bar1918_unjam;
.float bar1918_unjam_time;
.float bar1918_click;
.float bar1918_animempty;
.float bar1918_animset;
.float bar1918_nextanim;
.float bar1918_nextbot;
.float bar1918_setting; //0 full auto //1 semi
.float bar1918_overheat_cnt;
.float bar1918_overheated_until;
.float bar1918_magazine; //0normal, 1 40rnd
.float bar1918_magazine_changetime;
.float bar1918_gsetmagazine; //For ground model setting propagation
.float bar1918_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup



void W_Bar1918_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_bar1918_primary_ammo;
	d = autocvar_g_balance_bar1918_primary_damage;
	f = autocvar_g_balance_bar1918_primary_force;
	//spread = autocvar_g_balance_bar1918_primary_spread;
	spread = bound(autocvar_g_balance_bar1918_spread_min, autocvar_g_balance_bar1918_spread_min + (autocvar_g_balance_bar1918_spread_add * self.misc_bulletcounter), autocvar_g_balance_bar1918_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_bar1918_primary_speed;
	bulletconstant = autocvar_g_balance_bar1918_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_bar1918_reload_ammo);
	
	if (autocvar_g_balance_bar1918_jamrate &&
 	(autocvar_g_balance_bar1918_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your automatic rifle jammed\n");
		}
		self.bar1918_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_bass.ogg", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_bar1918_primary_headshotaddeddamage, f, WEP_BAR1918, PROJECTILE_BULLETRIFLE9MM, 1, bulletconstant, autocvar_g_balance_bar1918_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_bar1918_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_bar1918_gunrise, random() * autocvar_g_balance_bar1918_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '32 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 50 + 150) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 220) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 105, self, '8 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.bar1918_overheat_cnt),"_Firing\n");
		
	    	self.bar1918_overheat_cnt = self.bar1918_overheat_cnt + autocvar_g_balance_bar1918_heatconstant;
         
	    	if (self.bar1918_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your bar1918 overheated\n");
			}
				
			self.bar1918_overheated_until = time + (autocvar_g_balance_bar1918_cooldownwait * (self.bar1918_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_Bar1918_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_bar1918_reload_ammo && self.clip_load < autocvar_g_balance_bar1918_primary_ammo))
	{
		if (!self.bar1918_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.bar1918_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.bar1918_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}



float W_Bar1918_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.bar1918_magazine == 2) {
				//	if (!autocvar_g_balance_bar1918_exmag100notincluded
			  	//	|| player.inv_misc_exmag_bar_100)
			  	//	{
				//		return 1;
				//	} else {
				//		player.bar1918_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.bar1918_magazine == 1.5) {
				//	if (!autocvar_g_balance_bar1918_drum75notincluded
			  	//	|| player.inv_misc_drum_bar1918_75)
			  	//	{
				//		return 1;
				//	} else {
				//		player.bar1918_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else
				if (player.bar1918_magazine == 1) {
					if (!autocvar_g_balance_bar1918_exmag40notincluded
			  		|| player.inv_misc_exmag_bar_40)
			  		{
						return 1;
					} else {
						player.bar1918_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.bar1918_magazine == -1) {
					return 1;
				}
				
				if (player.bar1918_magazine == 0) {
					if (!autocvar_g_balance_bar1918_mag20notincluded
			  		|| player.inv_misc_mag_bar_20)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.bar1918_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_Bar1918_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_bar1918_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_bar1918_reload_ammo;
		player.clip_load = autocvar_g_balance_bar1918_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_Bar1918_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_Bar1918_setmodelforanim(entity player) {
	////Open bolt: reversed
	//if (player.bar1918_magazine == 2) {
	//	if (player.bar1918_animempty)
	//		player.weaponname = "bar1918_exm100";
	//	else
	//		player.weaponname = "bar1918_exm100_empty";
	//} else if (player.bar1918_magazine == 1.5) {
	//	if (player.bar1918_animempty)
	//		player.weaponname = "bar1918_drum75";
	//	else
	//		player.weaponname = "bar1918_drum75_empty";
	//} else
	if (player.bar1918_magazine == 1) {
		if (player.bar1918_animempty)
			player.weaponname = "bar1918_exm40";
		else
			player.weaponname = "bar1918_exm40_empty";
	} else if (player.bar1918_magazine == -1) {
		if (player.bar1918_animempty)
			player.weaponname = "bar1918_none";
		else
			player.weaponname = "bar1918_none_empty";
	} else {
		if (player.bar1918_animempty)
			player.weaponname = "bar1918";
		else
			player.weaponname = "bar1918_empty";
	}
}

void W_Bar1918_setclipsize(entity player) {
	//if (player.bar1918_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_bar1918_reload_ammoexm2;
	//} else if (player.bar1918_magazine == 1.5) {
	//	player.clip_size = autocvar_g_balance_bar1918_reload_ammodrum;
	//} else
	if (player.bar1918_magazine == 1) {
		player.clip_size = autocvar_g_balance_bar1918_reload_ammoexm;
	} else if (player.bar1918_magazine == -1) {
		player.clip_size = autocvar_g_balance_bar1918_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_bar1918_reload_ammo;
	}
}

void W_Bar1918_setrefunddown(entity player) {
	//if (player.bar1918_magazine == 2) {
	//	W_Bar1918_refunddowntocustommag(player, autocvar_g_balance_bar1918_reload_ammoexm2);
	//} else if (player.bar1918_magazine == 1.5) {
	//	W_Bar1918_refunddowntocustommag(player, autocvar_g_balance_bar1918_reload_ammodrum);
	//} else
	if (player.bar1918_magazine == 1) {
		W_Bar1918_refunddowntocustommag(player, autocvar_g_balance_bar1918_reload_ammoexm);
	} else if (player.bar1918_magazine == -1) {
		W_Bar1918_refunddowntocustommag(player, autocvar_g_balance_bar1918_reload_ammonone);
	} else {
		W_Bar1918_refunddowntocustommag(player, autocvar_g_balance_bar1918_reload_ammo);
	}
}

float W_Bar1918_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_bar1918_mag20notincluded
	|| player.inv_misc_mag_bar_20)
	{
		return 0;
	} else if (!autocvar_g_balance_bar1918_exmag40notincluded
	|| player.inv_misc_exmag_bar_40)
	{
		return 1;
	}
	//else if (!autocvar_g_balance_bar1918_drum75notincluded
	//|| player.inv_misc_drum_bar1918_75)
	//{
	//	return 1.5;
	//} else if (!autocvar_g_balance_bar1918_exmag100notincluded
	//|| player.inv_misc_exmag_bar_100)
	//{
	//	return 2;					
	//}
	
	return currentmagwant;
}




void spawnfunc_weapon_bar1918 (void)
{
	weapon_defaultspawnfunc(WEP_BAR1918);
}

void w_bar1918_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.bar1918_magazine == 2) {
	//	myself.model = "models/weapons/g_bar1918_exm100.md3";
	//	
	//	if (autocvar_g_balance_bar1918_exmag100notincluded
	//	&& player.inv_misc_exmag_bar_100 >= 1) {
	//		player.inv_misc_exmag_bar_100 = player.inv_misc_exmag_bar_100 - 1;
	//		myself.inv_misc_exmag_bar_100 = myself.inv_misc_exmag_bar_100 + 1;
	//	}
	//	
	//	myself.bar1918_gsetmagazine = player.bar1918_magazine;
	//} else if (player.bar1918_magazine == 1.5) {
	//	myself.model = "models/weapons/g_bar1918_drum75.md3";
	//	
	//	if (autocvar_g_balance_bar1918_drum75notincluded
	//	&& player.inv_misc_drum_bar1918_75 >= 1) {
	//		player.inv_misc_drum_bar1918_75 = player.inv_misc_drum_bar1918_75 - 1;
	//		myself.inv_misc_drum_bar1918_75 = myself.inv_misc_drum_bar1918_75 + 1;
	//	}
	//	
	//	myself.bar1918_gsetmagazine = player.bar1918_magazine;
	//} else
	if (player.bar1918_magazine == 1) {
		myself.model = "models/weapons/g_bar1918_exm40.md3";
		
		if (autocvar_g_balance_bar1918_exmag40notincluded
		&& player.inv_misc_exmag_bar_40 >= 1) {
			player.inv_misc_exmag_bar_40 = player.inv_misc_exmag_bar_40 - 1;
			myself.inv_misc_exmag_bar_40 = myself.inv_misc_exmag_bar_40 + 1;
		}
		myself.bar1918_gsetmagazine = player.bar1918_magazine;
	} else if (player.bar1918_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_bar1918.md3";
		
		if (autocvar_g_balance_bar1918_mag20notincluded
		&& player.inv_misc_mag_bar_20 >= 1) {
			player.inv_misc_mag_bar_20 = player.inv_misc_mag_bar_20 - 1;
			myself.inv_misc_mag_bar_20 = myself.inv_misc_mag_bar_20 + 1;
		}
		myself.bar1918_gsetmagazine = player.bar1918_magazine;
	} else if (player.bar1918_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_bar1918_none.md3";
		
		myself.bar1918_gsetmagazine = player.bar1918_magazine;
	} else {
		//Do nothing
		myself.bar1918_gsetmagazine = 0;
	}
}

void w_bar1918_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_BAR1918) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.bar1918_magazine = myself.bar1918_gsetmagazine;
			player.bar1918_pickedupgsetmagazine = myself.bar1918_gsetmagazine;
		}
	}
}

.float bar1918_primarytime;

float w_bar1918(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//Secondary is selector switch, so irrelevant
				//print(ftos(self.bar1918_overheat_cnt),"_Cooldown\n");
			
			if (self.bar1918_overheat_cnt < autocvar_g_balance_bar1918_heatmin) {
				self.bar1918_overheat_cnt = autocvar_g_balance_bar1918_heatmin;
			} else {
				self.bar1918_overheat_cnt = self.bar1918_overheat_cnt - (autocvar_g_balance_bar1918_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Bar1918_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.bar1918_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.bar1918_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_bar1918_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Bar1918_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_Bar1918_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_Bar1918_setclipsize(self);
			W_Bar1918_setrefunddown(self);
			W_Bar1918_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_bar1918_reload_ammo && self.clip_load < autocvar_g_balance_bar1918_primary_ammo) // forced reload
		{
			// don't force reload an empty bar1918 if its melee attack is active
			if not(autocvar_g_balance_bar1918_secondary && self.ammo_nails < autocvar_g_balance_bar1918_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.bar1918_release = 0;
		}
		else
		{
		  if (self.bar1918_jammed && self.bar1918_unjam)
		  {
		  	if (time >= self.bar1918_unjam_time) {
				self.bar1918_jammed = 0;
				self.bar1918_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.bar1918_release)
			if (self.bar1918_jammed != 1)
			if ((time > self.bar1918_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.bar1918_setting != 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.bar1918_nextbot)," \n");
				} else {
					self.bar1918_nextbot = 0;
				}
				
				if (time >= self.bar1918_nextbot) {
					W_Bar1918_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_bar1918_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_bar1918_primary_animtime, w_ready);
					self.bar1918_release = 0;
					self.bar1918_animempty = 1;
					self.bar1918_animset = 1;
					self.bar1918_nextanim = time + autocvar_g_balance_bar1918_primary_rfanim;
					bp_skipme = 1;
					//self.bar1918_nextbot = time + (autocvar_g_balance_bar1918_primary_refire * 50 * random());
					self.bar1918_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.bar1918_release = 1;
					self.bar1918_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.bar1918_nextbot)," \n");
				} else {
					self.bar1918_nextbot = 0;
				}
				
				if (time >= self.bar1918_nextbot) {
					W_Bar1918_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_bar1918_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_bar1918_secondary_animtime, w_ready);
					self.bar1918_release = 0;
					self.bar1918_animempty = 1;
					self.bar1918_animset = 1;
					self.bar1918_nextanim = time + autocvar_g_balance_bar1918_secondary_rfanim;
					bp_skipme = 1;
					//self.bar1918_nextbot = time + (autocvar_g_balance_bar1918_secondary_refire * 50 * random());
					self.bar1918_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.bar1918_release)
			if (self.bar1918_jammed != 1)
			if ((time > self.bar1918_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.bar1918_setting) {
					self.bar1918_setting = 0;
				} else {
					self.bar1918_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.bar1918_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.bar1918_jammed != 1)
				if (time >= self.bar1918_nextanim)
				if (self.bar1918_animempty)
				{
					self.bar1918_animempty = 0;
					self.bar1918_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.bar1918_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.bar1918_animset)
			if (self.bar1918_jammed != 1) {
					W_Bar1918_setmodelforanim(self);
					////Open bolt: reversed
					//if (self.bar1918_animempty)
					//	self.weaponname = "bar1918";
					//else
					//	self.weaponname = "bar1918_empty";
			}
			
			self.bar1918_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_Bar1918_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_Bar1918_setclipsize(self);
			W_Bar1918_setrefunddown(self);
			W_Bar1918_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_bar1918.md3");
		precache_model ("models/weapons/v_bar1918.md3");
		precache_model ("models/weapons/h_bar1918.iqm");
		
		precache_model ("models/weapons/v_bar1918_empty.md3");
		precache_model ("models/weapons/h_bar1918_empty.iqm");
		
		
		precache_model ("models/weapons/g_bar1918_exm40.md3");
		precache_model ("models/weapons/v_bar1918_exm40.md3");
		precache_model ("models/weapons/h_bar1918_exm40.iqm");
		precache_model ("models/weapons/v_bar1918_exm40_empty.md3");
		precache_model ("models/weapons/h_bar1918_exm40_empty.iqm");
		
		precache_model ("models/weapons/g_bar1918_none.md3");
		precache_model ("models/weapons/v_bar1918_none.md3");
		precache_model ("models/weapons/h_bar1918_none.iqm");
		precache_model ("models/weapons/v_bar1918_none_empty.md3");
		precache_model ("models/weapons/h_bar1918_none_empty.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_bass.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.bar1918_overheat_cnt = autocvar_g_balance_bar1918_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		self.weaponaltaim = '43 -0.23 -3.35';
		weapon_setup(WEP_BAR1918);
		self.current_ammo = ammo_nails;
		
			////Open bolt: reversed
			//if (self.bar1918_animempty)
			//	self.weaponname = "bar1918";
			//else
			//	self.weaponname = "bar1918_empty";
		
		//Make sure we're allowed to have.
			W_Bar1918_allowedextendedmags(self);
			
			if (self.bar1918_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.bar1918_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 30 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.bar1918_magazine = W_Bar1918_tryforvalidmag(self, self.bar1918_magazine);
					W_Bar1918_allowedextendedmags(self);
				}
			}
			
			self.bar1918_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_Bar1918_setmodelforanim(self);
			
			
					
	
	
		
		  if (self.bar1918_jammed && self.bar1918_unjam)
		  {
		  	if (time >= self.bar1918_unjam_time) {
				self.bar1918_jammed = 0;
				self.bar1918_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_Bar1918_setclipsize(self);
		W_Bar1918_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_bar1918_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_BAR1918]) >= autocvar_g_balance_bar1918_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.bar1918_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_bar1918_clearjam_time, w_ready);
			if (self.bar1918_unjam != 1) {
				self.bar1918_unjam = 1;
				self.bar1918_unjam_time = time + autocvar_g_balance_bar1918_clearjam_time;
				self.bar1918_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float bar1918donothing;
			bar1918donothing = 0;
			if (self.BUTTON_USE) {
			  if (self.bar1918_magazine_changetime >= time) {
			  	//Do nothing
				bar1918donothing = 1;
			  } else {
				local float bar1918magwant;
				if (self.bar1918_magazine == 1) {
					bar1918magwant = 0;
					//////bar1918magwant = 1.5;
				//} else if (self.bar1918_magazine == 1.5) {
				//	bar1918magwant = 2;	
				//} else if (self.bar1918_magazine == 2) {
				//	bar1918magwant = 0;	
				} else {
					//self.bar1918_magazine == 0
					bar1918magwant = 1;
				}				
				
				if (bar1918magwant == 1) {
					if (!autocvar_g_balance_bar1918_exmag40notincluded
			  		|| self.inv_misc_exmag_bar_40)
			  		{
						//Yes
					} else {
						//No
						//	bar1918magwant = 1.5; //fallback
						bar1918magwant = 0; //fallback
					}
				}				
				
				//if (bar1918magwant == 1.5) {
				//	if (!autocvar_g_balance_bar1918_drum75notincluded
			  	//	|| self.inv_misc_drum_bar1918_75)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			bar1918magwant = 2; //fallback
				//	}
				//}
				
				//if (bar1918magwant == 2) {
				//	if (!autocvar_g_balance_bar1918_exmag100notincluded
			  	//	|| self.inv_misc_exmag_bar_100)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			bar1918magwant = 0; //fallback
				//	}
				//}
				
				//If no magazines available...
				if (bar1918magwant == 0) {
					if (!autocvar_g_balance_bar1918_mag20notincluded
			  		|| self.inv_misc_mag_bar_20)
			  		{
						//Yes
					} else {
						//No
							bar1918magwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (bar1918magwant == -1) {
					bar1918magwant = W_Bar1918_tryforvalidmag(self, bar1918magwant);
				}
				//Final decisions
				
				if (bar1918magwant == self.bar1918_magazine) {
					bar1918donothing = 1;
				//} else if (bar1918magwant == 2) {
				//	self.bar1918_magazine = 2;
				//} else if (bar1918magwant == 1.5) {
				//	self.bar1918_magazine = 1.5;
				} else if (bar1918magwant == 1) {
					self.bar1918_magazine = 1;
				} else if (bar1918magwant == 0) {
					self.bar1918_magazine = 0;
				} else if (bar1918magwant == -1) {
					self.bar1918_magazine = -1;
				}
				
				W_Bar1918_setmodelforanim(self);
			  }
			}
		
			if (bar1918donothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.bar1918_magazine == 2) {
			//	W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammoexm2, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
			//	
			//	W_Bar1918_refunddowntocustommag(self, autocvar_g_balance_bar1918_reload_ammoexm2);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammoexm2, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
			//	W_Bar1918_setclipsize(self);
			//	self.bar1918_magazine_changetime = time + self.reload_time;
			//} else if (self.bar1918_magazine == 1.5) {
			//	W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammodrum, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
			//	
			//	W_Bar1918_refunddowntocustommag(self, autocvar_g_balance_bar1918_reload_ammodrum);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammodrum, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
			//	W_Bar1918_setclipsize(self);
			//	self.bar1918_magazine_changetime = time + self.reload_time;
			} else if (self.bar1918_magazine == 1) {
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammoexm, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				
				W_Bar1918_refunddowntocustommag(self, autocvar_g_balance_bar1918_reload_ammoexm);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammoexm, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				W_Bar1918_setclipsize(self);
				self.bar1918_magazine_changetime = time + self.reload_time;
			} else if (self.bar1918_magazine == -1) {
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammonone, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_Bar1918_refunddowntocustommag(self, autocvar_g_balance_bar1918_reload_ammonone);
				
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammonone, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				W_Bar1918_setclipsize(self);
				self.bar1918_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammo, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_Bar1918_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammo, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
				W_Bar1918_setclipsize(self);
				self.bar1918_magazine_changetime = time + self.reload_time;
			}
			
			//W_Reload(autocvar_g_balance_bar1918_primary_ammo, autocvar_g_balance_bar1918_reload_ammo, autocvar_g_balance_bar1918_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_bar1918(float req)
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
			w_deathtypestring = _("%1$s tried to breathe but %2$s's Automatic Rifle gave silence");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died, %2$s smashed them in the head with a bullet from a BAR");
		else
			w_deathtypestring = _("%s was killed by %s's Browning Automatic Rifle");
	}
	return TRUE;
}
#endif
#endif
