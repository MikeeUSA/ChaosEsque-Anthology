#ifdef REGISTER_WEAPON
REGISTER_WEAPON(STREETSWEEPER, w_streetsweeper, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "streetsweeper", "streetsweeper", _("Street Sweeper"))
#else
#ifdef SVQC

.float streetsweeper_release;
.float streetsweeper_jammed;
.float streetsweeper_unjam;
.float streetsweeper_unjam_time;
.float streetsweeper_click;
.float streetsweeper_altchoke;
.float streetsweeper_nextbot;

.float streetsweeper_casings;

float streetsweeperautoskincolorset;
.float streetsweeper_customskin;


void W_StreetSweeper_Attack (void)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_streetsweeper_primary_ammo;
	bullets = autocvar_g_balance_streetsweeper_primary_bullets;
	d = autocvar_g_balance_streetsweeper_primary_damage;
	f = autocvar_g_balance_streetsweeper_primary_force;
	
	if (self.streetsweeper_altchoke == 1) {
		spread = autocvar_g_balance_streetsweeper_primary_spreadalt;
	} else if (self.streetsweeper_altchoke == 2) {
		spread = autocvar_g_balance_streetsweeper_primary_spreadalt2;
	} else {
		spread = autocvar_g_balance_streetsweeper_primary_spread;
	}
	bulletspeed = autocvar_g_balance_streetsweeper_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_streetsweeper_reload_ammo);
	self.streetsweeper_casings = self.streetsweeper_casings + 1;
	
	if (autocvar_g_balance_streetsweeper_jamrate &&
 	(autocvar_g_balance_streetsweeper_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your shotgun jammed\n");
		}
		self.streetsweeper_jammed = 1;
	} else { //Start Not Jammed

	
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets);
		
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_STREETSWEEPER, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_streetsweeper_primary_coreshotaddeddamage);
		endFireBallisticBullet();
	
	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg + (v_forward * 50), w_shotdir * 1000, autocvar_g_balance_streetsweeper_primary_ammo);
	
	PlayerGunRise(self, autocvar_g_balance_streetsweeper_gunrise, random() * autocvar_g_balance_streetsweeper_gunrun);
	
	//casing code moved
	
	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '15 0 0');
	
	} //End Not Jammed
}


float W_Streetsweeper_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_streetsweeper_reload_ammo && self.clip_load < autocvar_g_balance_streetsweeper_primary_ammo))
	{
		if (!self.streetsweeper_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.streetsweeper_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.streetsweeper_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_streetsweeper (void)
{
	weapon_defaultspawnfunc(WEP_STREETSWEEPER);
}


float w_streetsweeper_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.streetsweeper_customskin > 0)) {
		return player.streetsweeper_customskin;
	} else if (autocvar_g_balance_streetsweeper_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(streetsweeperautoskincolorset) {
			streetsweeperautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (streetsweeperautoskincolorset == -10) {
			return 0;
		} else if (streetsweeperautoskincolorset == 1) {
			//Dust
			return 1;
		} else if (streetsweeperautoskincolorset == 4) {
			//Snow
			return 2;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_streetsweeper_skin;
	}
}



.float streetsweeper_primarytime;

float w_streetsweeper(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Streetsweeper_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.streetsweeper_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (time >= self.streetsweeper_nextbot) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_streetsweeper_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Streetsweeper_NeedManualReload())
	{
		if(autocvar_g_balance_streetsweeper_reload_ammo && self.clip_load < autocvar_g_balance_streetsweeper_primary_ammo) // forced reload
		{
			// don't force reload an empty streetsweeper if its melee attack is active
			if not(autocvar_g_balance_streetsweeper_secondary && self.ammo_shells < autocvar_g_balance_streetsweeper_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.streetsweeper_release = 0;
		}
		else
		{
		  if (self.streetsweeper_jammed && self.streetsweeper_unjam)
		  {
		  	if (time >= self.streetsweeper_unjam_time) {
				self.streetsweeper_jammed = 0;
				self.streetsweeper_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	
			if not(self.BUTTON_ATCK) {
				self.streetsweeper_release = 1;
				self.streetsweeper_click = 0;
			} else if (
			(self.BUTTON_ATCK) &&
			(self.streetsweeper_jammed != 1) &&
			(self.streetsweeper_release))
			{
				if (time >= self.streetsweeper_primarytime) // handle refire separately so the secondary can be fired straight after a primary
				{
						if(clienttype(self) == CLIENTTYPE_BOT) {
							//Nope
							//print("I bot", ftos(self.streetsweeper_nextbot)," \n");
						} else {
							self.streetsweeper_nextbot = 0;
						}
				
						if(weapon_prepareattack(0, autocvar_g_balance_streetsweeper_primary_animtime))
						{
						  if (time >= self.streetsweeper_nextbot) {
							W_StreetSweeper_Attack();
							self.streetsweeper_primarytime = time + autocvar_g_balance_streetsweeper_primary_refire * W_WeaponRateFactor();
							weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_streetsweeper_primary_animtime, w_ready);
							self.streetsweeper_release = 0;
							self.streetsweeper_nextbot = time + 0.1 + (0.4 * random());
						  }
						}
				}
			} else if (self.BUTTON_ATCK && !self.shotgun_click && self.shotgun_release && W_shotgun_NeedManualReload()) {
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
				self.streetsweeper_click = 1;
			}
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_streetsweeper.md3");
		precache_model ("models/weapons/v_streetsweeper.md3");
		precache_model ("models/weapons/h_streetsweeper.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 0.05 -1.25';	
		//self.weaponaltaim = '60 -0.20 -7.95';
		self.weaponaltaim = '40 -0.20 -4.05';	
		weapon_setup(WEP_STREETSWEEPER);
		self.current_ammo = ammo_shells;
	
	
		
		  if (self.streetsweeper_jammed && self.streetsweeper_unjam)
		  {
		  	if (time >= self.streetsweeper_unjam_time) {
				self.streetsweeper_jammed = 0;
				self.streetsweeper_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_streetsweeper_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_STREETSWEEPER]) >= autocvar_g_balance_streetsweeper_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.streetsweeper_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.streetsweeper_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_streetsweeper_clearjam_time, w_ready);
			if (self.streetsweeper_unjam != 1) {
				self.streetsweeper_unjam = 1;
				self.streetsweeper_unjam_time = time + autocvar_g_balance_streetsweeper_clearjam_time;
				self.streetsweeper_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the shotgun\n");
				}
			}
		} else {
			//print(ftos(self.(weapon_load[self.weapon])   ), " swl\n");
			//print(ftos(self.clip_load) , " cl\n");

			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_streetsweeper_reload_ammo)) {
				//Tube Magazine not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_streetsweeper_primary_ammo, autocvar_g_balance_streetsweeper_reload_ammo, autocvar_g_balance_streetsweeper_reload_time - (autocvar_g_balance_streetsweeper_reload_time * (self.clip_load/autocvar_g_balance_streetsweeper_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_streetsweeper_primary_ammo, autocvar_g_balance_streetsweeper_reload_ammo, autocvar_g_balance_streetsweeper_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				for (sc = 0;sc < self.streetsweeper_casings;sc = sc + 1) {
					SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self, '0 0 -3');
				}
				self.streetsweeper_casings = 0;
			}
			
			if (self.BUTTON_USE) {
				
				if (self.streetsweeper_altchoke == 2) {
					if(self.BUTTON_CROUCH) {
						self.streetsweeper_altchoke = 1;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to an open choke on your streetsweeper\n");
						}
					} else {
						self.streetsweeper_altchoke = 0;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a tight choke on your streetsweeper\n");
						}
					}
				} else if (self.streetsweeper_altchoke == 1) {
					if(self.BUTTON_CROUCH) {
						self.streetsweeper_altchoke = 0;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a tight choke on your streetsweeper\n");
						}
					} else {
						self.streetsweeper_altchoke = 2;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a restrictive choke on your streetsweeper\n");
						}
					}
				} else if (!self.streetsweeper_altchoke) {
					if(self.BUTTON_CROUCH) {
						self.streetsweeper_altchoke = 2;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a restrictive choke on your streetsweeper\n");
						}
					} else {
						self.streetsweeper_altchoke = 1;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to an open choke on your streetsweeper\n");
						}
					}
				}
			}
		}
		self.streetsweeper_release = 0;
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_streetsweeper(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s found it difficult to digest with the size of the hole %2$s put in their chest");
		else
			w_deathtypestring = _("%s was gunned down with a streetsweeper by %s");
	}
	return TRUE;
}
#endif
#endif
