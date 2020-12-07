#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LEWISMG, w_lewismg, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "lewismg", "lewismg", _("Lewis Gun"))
#else
#ifdef SVQC
.float lewismg_jammed;
.float lewismg_unjam;
.float lewismg_unjam_time;
.float lewismg_click;
.float lewismg_overheat_cnt;
.float lewismg_overheated_until;
.float lewismg_magazine; //0normal, 1 97rnd
.float lewismg_magazine_changetime;
.float lewismg_gsetmagazine; //For ground model setting propagation
.float lewismg_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup
.float lewismg_triggerlag;
.float lewismg_triggerlag_time;
.float lewismg_triggerlag_button;

// weapon frames

float lewismgautoskincolorset;
.float lewismg_customskin;

float W_LewisMG_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_lewismg_reload_ammo && self.clip_load < autocvar_g_balance_lewismg_sustained_ammo))
	{
		if (!self.lewismg_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
			self.lewismg_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.lewismg_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void lewismg_fire_auto()
{
	float lewismg_spread;
	
	if (self.lewismg_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.lewismg_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(W_LewisMG_NeedManualReload()) {
		w_ready();
		return;	
	}

	if (!self.BUTTON_ATCK && !self.lewismg_triggerlag_button)
	{
		w_ready();
		return;
	}

	if (!weapon_action(self.weapon, WR_CHECKAMMO1))
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_lewismg_sustained_ammo, autocvar_g_balance_lewismg_reload_ammo);

	
	if(autocvar_g_balance_lewismg_jamrate &&
 	(autocvar_g_balance_lewismg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun has jammed\n");
		}
		self.lewismg_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_lewismg_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire_bass.ogg", CH_WEAPON_A, autocvar_g_balance_lewismg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	lewismg_spread = bound(autocvar_g_balance_lewismg_spread_min, autocvar_g_balance_lewismg_spread_min + (autocvar_g_balance_lewismg_spread_add * self.misc_bulletcounter), autocvar_g_balance_lewismg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, lewismg_spread, autocvar_g_balance_lewismg_speed, 5, autocvar_g_balance_lewismg_sustained_damage, autocvar_g_balance_lewismg_sustained_headshotaddeddamage, autocvar_g_balance_lewismg_sustained_force, WEP_LEWISMG, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_balance_lewismg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '19 0 1.5');
	
	PlayerGunRise(self, autocvar_g_balance_lewismg_gunrise, random() * autocvar_g_balance_lewismg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * 120 + 40) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 105, self, '1 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.lewismg_overheat_cnt),"_Firing\n");
		
	    	self.lewismg_overheat_cnt = self.lewismg_overheat_cnt + autocvar_g_balance_lewismg_heatconstant;
         
	    	if (self.lewismg_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your lewismg overheated\n");
			}
				
			self.lewismg_overheated_until = time + (autocvar_g_balance_lewismg_cooldownwait * (self.lewismg_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_lewismg_sustained_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lewismg_sustained_refire, lewismg_fire_auto);
}

float W_LewisMG_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.lewismg_magazine == 2) {
				//	if (!autocvar_g_balance_lewismg_exmag100notincluded
			  	//	|| player.inv_misc_exmag_lewisgun_100)
			  	//	{
				//		return 1;
				//	} else {
				//		player.lewismg_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.lewismg_magazine == 1.5) {
				//	if (!autocvar_g_balance_lewismg_drum75notincluded
			  	//	|| player.inv_misc_drum_lewismg_75)
			  	//	{
				//		return 1;
				//	} else {
				//		player.lewismg_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else
				if (player.lewismg_magazine == 1) {
					if (!autocvar_g_balance_lewismg_panmag97notincluded
			  		|| player.inv_misc_panmag_lewisgun_97)
			  		{
						return 1;
					} else {
						player.lewismg_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.lewismg_magazine == -1) {
					return 1;
				}
				
				if (player.lewismg_magazine == 0) {
					if (!autocvar_g_balance_lewismg_panmag47notincluded
			  		|| player.inv_misc_panmag_lewisgun_47)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.lewismg_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_LewisMG_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_lewismg_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_lewismg_reload_ammo;
		player.clip_load = autocvar_g_balance_lewismg_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_LewisMG_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_LewisMG_setmodelforanim(entity player) {
	//if (player.lewismg_magazine == 2) {
	//		player.weaponname = "lewismg_exm100";
	//} else if (player.lewismg_magazine == 1.5) {
	//		player.weaponname = "lewismg_drum75";
	//} else
	if (player.lewismg_magazine == 1) {
			player.weaponname = "lewismg_exm97";
	} else if (player.lewismg_magazine == -1) {
			player.weaponname = "lewismg_none";
	} else {
			player.weaponname = "lewismg";
	}
}

void W_LewisMG_setclipsize(entity player) {
	//if (player.lewismg_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_lewismg_reload_ammoexm2;
	//} else if (player.lewismg_magazine == 1.5) {
	//	player.clip_size = autocvar_g_balance_lewismg_reload_ammodrum;
	//} else
	if (player.lewismg_magazine == 1) {
		player.clip_size = autocvar_g_balance_lewismg_reload_ammoexm;
	} else if (player.lewismg_magazine == -1) {
		player.clip_size = autocvar_g_balance_lewismg_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_lewismg_reload_ammo;
	}
}

void W_LewisMG_setrefunddown(entity player) {
	//if (player.lewismg_magazine == 2) {
	//	W_LewisMG_refunddowntocustommag(player, autocvar_g_balance_lewismg_reload_ammoexm2);
	//} else if (player.lewismg_magazine == 1.5) {
	//	W_LewisMG_refunddowntocustommag(player, autocvar_g_balance_lewismg_reload_ammodrum);
	//} else
	if (player.lewismg_magazine == 1) {
		W_LewisMG_refunddowntocustommag(player, autocvar_g_balance_lewismg_reload_ammoexm);
	} else if (player.lewismg_magazine == -1) {
		W_LewisMG_refunddowntocustommag(player, autocvar_g_balance_lewismg_reload_ammonone);
	} else {
		W_LewisMG_refunddowntocustommag(player, autocvar_g_balance_lewismg_reload_ammo);
	}
}

float W_LewisMG_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_lewismg_panmag47notincluded
	|| player.inv_misc_panmag_lewisgun_47)
	{
		return 0;
	} else if (!autocvar_g_balance_lewismg_panmag97notincluded
	|| player.inv_misc_panmag_lewisgun_97)
	{
		return 1;
	}
	//else if (!autocvar_g_balance_lewismg_drum75notincluded
	//|| player.inv_misc_drum_lewismg_75)
	//{
	//	return 1.5;
	//} else if (!autocvar_g_balance_lewismg_exmag100notincluded
	//|| player.inv_misc_exmag_lewisgun_100)
	//{
	//	return 2;					
	//}
	
	return currentmagwant;
}


void w_lewismg_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.lewismg_magazine == 2) {
	//	myself.model = "models/weapons/g_lewismg_exm100.md3";
	//	
	//	if (autocvar_g_balance_lewismg_exmag100notincluded
	//	&& player.inv_misc_exmag_lewisgun_100 >= 1) {
	//		player.inv_misc_exmag_lewisgun_100 = player.inv_misc_exmag_lewisgun_100 - 1;
	//		myself.inv_misc_exmag_lewisgun_100 = myself.inv_misc_exmag_lewisgun_100 + 1;
	//	}
	//	
	//	myself.lewismg_gsetmagazine = player.lewismg_magazine;
	//} else if (player.lewismg_magazine == 1.5) {
	//	myself.model = "models/weapons/g_lewismg_drum75.md3";
	//	
	//	if (autocvar_g_balance_lewismg_drum75notincluded
	//	&& player.inv_misc_drum_lewismg_75 >= 1) {
	//		player.inv_misc_drum_lewismg_75 = player.inv_misc_drum_lewismg_75 - 1;
	//		myself.inv_misc_drum_lewismg_75 = myself.inv_misc_drum_lewismg_75 + 1;
	//	}
	//	
	//	myself.lewismg_gsetmagazine = player.lewismg_magazine;
	//} else
	if (player.lewismg_magazine == 1) {
		myself.model = "models/weapons/g_lewismg_exm97.md3";
		
		if (autocvar_g_balance_lewismg_panmag97notincluded
		&& player.inv_misc_panmag_lewisgun_97 >= 1) {
			player.inv_misc_panmag_lewisgun_97 = player.inv_misc_panmag_lewisgun_97 - 1;
			myself.inv_misc_panmag_lewisgun_97 = myself.inv_misc_panmag_lewisgun_97 + 1;
		}
		myself.lewismg_gsetmagazine = player.lewismg_magazine;
	} else if (player.lewismg_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_lewismg.md3";
		
		if (autocvar_g_balance_lewismg_panmag47notincluded
		&& player.inv_misc_panmag_lewisgun_47 >= 1) {
			player.inv_misc_panmag_lewisgun_47 = player.inv_misc_panmag_lewisgun_47 - 1;
			myself.inv_misc_panmag_lewisgun_47 = myself.inv_misc_panmag_lewisgun_47 + 1;
		}
		myself.lewismg_gsetmagazine = player.lewismg_magazine;
	} else if (player.lewismg_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_lewismg_none.md3";
		
		myself.lewismg_gsetmagazine = player.lewismg_magazine;
	} else {
		//Do nothing
		myself.lewismg_gsetmagazine = 0;
	}
}

void w_lewismg_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_LEWISMG) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.lewismg_magazine = myself.lewismg_gsetmagazine;
			player.lewismg_pickedupgsetmagazine = myself.lewismg_gsetmagazine;
		}
	}
}



void spawnfunc_weapon_lewismg()
{    
	weapon_defaultspawnfunc(WEP_LEWISMG);
}

float w_lewismg_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.lewismg_customskin > 0)) {
		return player.lewismg_customskin;
	} else if (autocvar_g_balance_lewismg_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(lewismgautoskincolorset) {
			lewismgautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (lewismgautoskincolorset == -10) {
			return 0;
		} else if (lewismgautoskincolorset == 1) {
			//Dust
			return 2;
		} else if (lewismgautoskincolorset == 4) {
			//Snow
			return 1;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_lewismg_skin;
	}
}




float w_lewismg(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//Secondary does nothing, so is irrelevant here
				//print(ftos(self.lewismg_overheat_cnt),"_Cooldown\n");
			
			if (self.lewismg_overheat_cnt < autocvar_g_balance_lewismg_heatmin) {
				self.lewismg_overheat_cnt = autocvar_g_balance_lewismg_heatmin;
			} else {
				self.lewismg_overheat_cnt = self.lewismg_overheat_cnt - (autocvar_g_balance_lewismg_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_LewisMG_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.lewismg_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		//if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		//else
		//{
		//	self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		//}
	}
	else if (req == WR_THINK && !W_LewisMG_NeedManualReload())
	{	//Make sure we're allowed to have.
		if (W_LewisMG_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_LewisMG_setclipsize(self);
			W_LewisMG_setrefunddown(self);
			W_LewisMG_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_lewismg_reload_ammo && self.clip_load < autocvar_g_balance_lewismg_sustained_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
		  if (self.lewismg_jammed && self.lewismg_unjam)
		  {
		  	if (time >= self.lewismg_unjam_time) {
				self.lewismg_jammed = 0;
				self.lewismg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			if (self.BUTTON_ATCK || self.lewismg_triggerlag_button == 1)
			if (self.lewismg_jammed != 1)
			if ((time > self.lewismg_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (((time > self.lewismg_triggerlag_time) && self.lewismg_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack(0, 0))
			{
				self.lewismg_triggerlag = 1; //For openbolt trigger lag
				
				self.misc_bulletcounter = 0;
				lewismg_fire_auto();
			}
			
			
			
			
			//Openbolt trigger lag
			if (time > self.lewismg_triggerlag_time) {
				self.lewismg_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.lewismg_triggerlag)
			&& self.BUTTON_ATCK) {
				self.lewismg_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.lewismg_triggerlag = 1;
				self.lewismg_triggerlag_time = time + (autocvar_g_balance_lewismg_sustained_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			if not(self.BUTTON_ATCK) {
				if not(self.lewismg_triggerlag_button) {
					self.lewismg_triggerlag = 0; //For openbolt trigger lag
				}
			}
			
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_LewisMG_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			W_LewisMG_setclipsize(self);
			W_LewisMG_setrefunddown(self);
			W_LewisMG_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_lewismg.md3");
		precache_model ("models/weapons/v_lewismg.md3");
		precache_model ("models/weapons/h_lewismg.iqm");
		precache_model ("models/weapons/g_lewismg_exm97.md3");
		precache_model ("models/weapons/v_lewismg_exm97.md3");
		precache_model ("models/weapons/h_lewismg_exm97.iqm");
		precache_model ("models/weapons/g_lewismg_none.md3");
		precache_model ("models/weapons/v_lewismg_none.md3");
		precache_model ("models/weapons/h_lewismg_none.iqm");
		precache_sound ("weapons/uzi_fire_bass.ogg");		
	}
	else if (req == WR_SETUP)
	{
		self.lewismg_triggerlag_button = 0; //for openbolt trigger lag
		self.lewismg_triggerlag = 0; //for openbolt trigger lag
		
		self.lewismg_overheat_cnt = autocvar_g_balance_lewismg_heatmin;

		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '44 0.1 -5';
		//self.weaponaltaim = '54 -0.35 -2.95';
		//self.weaponaltaim = '47 -0.35 -5';
		//self.weaponaltaim = '50 -0.35 -4';
		//self.weaponaltaim = '52 -0.35 -4'; //too far to right
		//self.weaponaltaim = '52 0 -4'; //too far to left
		//self.weaponaltaim = '62 -0.20 -5.25';
		//self.weaponaltaim = '62 -0.20 -6';
		self.weaponaltaim = '62 -0.20 -5.6';
		weapon_setup(WEP_LEWISMG);
		self.current_ammo = ammo_nails;
		
		
		
			//Make sure we're allowed to have.
			W_LewisMG_allowedextendedmags(self);
			
			if (self.lewismg_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.lewismg_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 30 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.lewismg_magazine = W_LewisMG_tryforvalidmag(self, self.lewismg_magazine);
					W_LewisMG_allowedextendedmags(self);
				}
			}
			
			self.lewismg_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_LewisMG_setmodelforanim(self);
		
		
		
		
		
		  if (self.lewismg_jammed && self.lewismg_unjam)
		  {
		  	if (time >= self.lewismg_unjam_time) {
				self.lewismg_jammed = 0;
				self.lewismg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_LewisMG_setclipsize(self);
		W_LewisMG_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_lewismg_sustained_ammo;

		if(autocvar_g_balance_lewismg_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_LEWISMG]) >= autocvar_g_balance_lewismg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_lewismg_sustained_ammo;

		if(autocvar_g_balance_lewismg_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_LEWISMG]) >= autocvar_g_balance_lewismg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		self.lewismg_triggerlag_button = 0; //for openbolt triggerlag
		self.lewismg_triggerlag = 0; //for openbolt triggerlag
		
		if (self.lewismg_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_lewismg_clearjam_time, w_ready);
			if (self.lewismg_unjam != 1) {
				self.lewismg_unjam = 1;
				self.lewismg_unjam_time = time + autocvar_g_balance_lewismg_clearjam_time;
				self.lewismg_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float lewismgdonothing;
			lewismgdonothing = 0;
			if (self.BUTTON_USE) {
			  if (self.lewismg_magazine_changetime >= time) {
			  	//Do nothing
				lewismgdonothing = 1;
			  } else {
				local float lewismgmagwant;
				if (self.lewismg_magazine == 1) {
					lewismgmagwant = 0;
					//////lewismgmagwant = 1.5;
				//} else if (self.lewismg_magazine == 1.5) {
				//	lewismgmagwant = 2;	
				//} else if (self.lewismg_magazine == 2) {
				//	lewismgmagwant = 0;	
				} else {
					//self.lewismg_magazine == 0
					lewismgmagwant = 1;
				}				
				
				if (lewismgmagwant == 1) {
					if (!autocvar_g_balance_lewismg_panmag97notincluded
			  		|| self.inv_misc_panmag_lewisgun_97)
			  		{
						//Yes
					} else {
						//No
						//	lewismgmagwant = 1.5; //fallback
						lewismgmagwant = 0; //fallback
					}
				}				
				
				//if (lewismgmagwant == 1.5) {
				//	if (!autocvar_g_balance_lewismg_drum75notincluded
			  	//	|| self.inv_misc_drum_lewismg_75)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			lewismgmagwant = 2; //fallback
				//	}
				//}
				
				//if (lewismgmagwant == 2) {
				//	if (!autocvar_g_balance_lewismg_exmag100notincluded
			  	//	|| self.inv_misc_exmag_lewisgun_100)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			lewismgmagwant = 0; //fallback
				//	}
				//}
				
				//If no magazines available...
				if (lewismgmagwant == 0) {
					if (!autocvar_g_balance_lewismg_panmag47notincluded
			  		|| self.inv_misc_panmag_lewisgun_47)
			  		{
						//Yes
					} else {
						//No
							lewismgmagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (lewismgmagwant == -1) {
					lewismgmagwant = W_LewisMG_tryforvalidmag(self, lewismgmagwant);
				}
				//Final decisions
				
				if (lewismgmagwant == self.lewismg_magazine) {
					lewismgdonothing = 1;
				//} else if (lewismgmagwant == 2) {
				//	self.lewismg_magazine = 2;
				//} else if (lewismgmagwant == 1.5) {
				//	self.lewismg_magazine = 1.5;
				} else if (lewismgmagwant == 1) {
					self.lewismg_magazine = 1;
				} else if (lewismgmagwant == 0) {
					self.lewismg_magazine = 0;
				} else if (lewismgmagwant == -1) {
					self.lewismg_magazine = -1;
				}
				
				W_LewisMG_setmodelforanim(self);
			  }
			}
		
			if (lewismgdonothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.lewismg_magazine == 2) {
			//	W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammoexm2, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
			//	
			//	W_LewisMG_refunddowntocustommag(self, autocvar_g_balance_lewismg_reload_ammoexm2);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammoexm2, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
			//	W_LewisMG_setclipsize(self);
			//	self.lewismg_magazine_changetime = time + self.reload_time;
			//} else if (self.lewismg_magazine == 1.5) {
			//	W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammodrum, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
			//	
			//	W_LewisMG_refunddowntocustommag(self, autocvar_g_balance_lewismg_reload_ammodrum);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammodrum, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
			//	W_LewisMG_setclipsize(self);
			//	self.lewismg_magazine_changetime = time + self.reload_time;
			} else if (self.lewismg_magazine == 1) {
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammoexm, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				
				W_LewisMG_refunddowntocustommag(self, autocvar_g_balance_lewismg_reload_ammoexm);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammoexm, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				W_LewisMG_setclipsize(self);
				self.lewismg_magazine_changetime = time + self.reload_time;
			} else if (self.lewismg_magazine == -1) {
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammonone, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_LewisMG_refunddowntocustommag(self, autocvar_g_balance_lewismg_reload_ammonone);
				
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammonone, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				W_LewisMG_setclipsize(self);
				self.lewismg_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_LewisMG_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
				W_LewisMG_setclipsize(self);
				self.lewismg_magazine_changetime = time + self.reload_time;
			}
			
			//W_Reload(autocvar_g_balance_lewismg_sustained_ammo, autocvar_g_balance_lewismg_reload_ammo, autocvar_g_balance_lewismg_reload_time, "weapons/reload.wav");
			self.lewismg_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_lewismg(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
			if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.1)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.2)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
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
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s was sniped by %s's Lewis Gun");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s was ripped through the heart and lungs by %s's Lewis Gun");
		else
			w_deathtypestring = _("%s torn to bits by %s's Lewis Gun");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_lewismg()
//{    
//	weapon_defaultspawnfunc(WEP_LEWISMG);
//}
