#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MUSKET, w_musket, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "musket", "musket", _("Musket"))
#else
#ifdef SVQC

.float musket_release;
.float musket_casings;
.float musket_jammed;
.float musket_unjam;
.float musket_unjam_time;
.float musket_click;
.float musket_halftime;
.float musket_fulltime;
.float musket_state;
.float musket_ontrigger;
.float musket_firedelay;
.float musket_firenow;
.float musket_botreload;
.float musket_notnew;

float autocvar_g_balance_musket_buckandball;
float autocvar_g_balance_musket_buckandball_spread;

void W_Musket_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_musket_primary_ammo;
	d = autocvar_g_balance_musket_primary_damage;
	f = autocvar_g_balance_musket_primary_force;
	spread = autocvar_g_balance_musket_primary_spread;
	bulletspeed = autocvar_g_balance_musket_primary_speed;
	bulletconstant = autocvar_g_balance_musket_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_musket_reload_ammo);
	self.musket_casings = self.musket_casings + 1;
	
	if (autocvar_g_balance_musket_jamrate &&
 	(autocvar_g_balance_musket_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your musket failed to fire\n");
		}
		self.musket_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_musket_primary_headshotaddeddamage, f, WEP_MUSKET, PROJECTILE_MUSKETBALL69, 1, bulletconstant, autocvar_g_balance_musket_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_musket_primary_ammo);
	
	if (autocvar_g_balance_musket_buckandball > 0) {
		local float sc, buckbullets, bulletconstantbuckandball, coreshotdmgbuckandball, dmgtypebuckandball, bulletspeedbuckandball, spreadbuckandball, damagebuckandball;
		buckbullets = autocvar_g_balance_musket_buckandball;
		sc = autocvar_g_balance_musket_buckandball;
		bulletconstantbuckandball = autocvar_g_balance_tengaugedouble_primary_bulletconstant;
		coreshotdmgbuckandball = autocvar_g_balance_tengaugedouble_primary_coreshotaddeddamage;
		dmgtypebuckandball = WEP_MUSKET | HITTYPE_SECONDARY;
		bulletspeedbuckandball = bulletspeed * 0.95; //presumably the smaller lighter buckshot pellets do not quite absorb as much energy, also we wish for them to be behind the large ball
		spreadbuckandball = autocvar_g_balance_musket_buckandball_spread;
		damagebuckandball = autocvar_g_balance_tengaugedouble_primary_damage;
		
		for (sc = 0;sc < autocvar_g_balance_musket_buckandball;sc = sc + 1)
				fireBallisticBullet(w_shotorg, w_shotdir, spreadbuckandball, bulletspeedbuckandball, 5, damagebuckandball, 0, f, dmgtypebuckandball, PROJECTILE_BULLETSHOTGUN, 1, bulletconstantbuckandball, coreshotdmgbuckandball);
		endFireBallisticBullet();
	}
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 20);
	}
	
	PlayerGunRise(self, autocvar_g_balance_musket_gunrise, random() * autocvar_g_balance_musket_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '38 0 0');
	
	} //End Not Jammed
}

void W_Musket_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_musket_secondary_animtime, w_ready);
}

float W_Musket_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_musket_reload_ammo && self.clip_load < autocvar_g_balance_musket_primary_ammo))
	{
		if (!self.musket_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.musket_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.musket_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_musket (void)
{
	weapon_defaultspawnfunc(WEP_MUSKET);
}


.float musket_primarytime;

float w_musket(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Musket_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.musket_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_musket_primary_speed, 0, 5, FALSE)) && (!self.musket_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && !W_Musket_NeedManualReload())
	{
		self.musket_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		if (flintlock_powder_gets_hot(mysmokeorg)
		|| flintlock_powder_spontaneously_ignites(self)) {
			W_Musket_Attack();
		} else if(autocvar_g_balance_musket_reload_ammo && self.clip_load < autocvar_g_balance_musket_primary_ammo) // forced reload
		{
			// don't force reload an empty musket if its melee attack is active
			if not(autocvar_g_balance_musket_secondary && self.ammo_nails < autocvar_g_balance_musket_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.musket_release = 0;
		}
		else
		{
		  if (self.musket_jammed && self.musket_unjam)
		  {
		  	if (time >= self.musket_unjam_time) {
				self.musket_jammed = 0;
				self.musket_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.musket_state == 3) {
		  		if (time > self.musket_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Musket_Attack2);
					self.musket_state = 2;
					self.weaponname = "musket-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_musket_cockingrise, random() * autocvar_g_balance_musket_cockingrun);
				}
			} else if (self.musket_state == 2) {
				if (time > self.musket_fulltime) {
					self.musket_state = 400;
					self.musket_release = 0; //We finish pulling back the hammer
					self.weaponname = "musket-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.musket_state == 1) {
				if (time > self.musket_firedelay) {
					self.musket_state = 0;

					self.musket_firedelay = 0;
					self.weaponname = "musket";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.musket_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.musket_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_musket_primary_refire))
				)
				{
						self.musket_ontrigger = 1;
						
						if (flintlock_powder_gets_wet(mysmokeorg)) {

							W_DecreaseAmmo(ammo_nails, autocvar_g_balance_musket_primary_ammo, autocvar_g_balance_musket_reload_ammo);
							self.musket_casings = self.musket_casings + 1;
	
							//if ((clienttype(self) == CLIENTTYPE_REAL)) {
							//	sprint(self, "Your powder failed to ignite when wet\n");
							//}
							////Doesn't jam, just decreases ammo, reload
		
						} else {
							local float myraincheck;
							myraincheck = CheckIfEntityIsInRain(self);
							
							if (myraincheck >= 70) {
								//Do nothing
							} else {
								if (myraincheck >= 60) {
									if (random() > 0.90) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 50) {
									if (random() > 0.80) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 40) {
									if (random() > 0.70) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 30) {
									if (random() > 0.60) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 25) {
									if (random() > 0.50) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 20) {
									if (random() > 0.30) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 15) {
									if (random() > 0.25) {
										W_Musket_Attack();
									}
								} else if (myraincheck >= 10) {
									if (random() > 0.20) {
										W_Musket_Attack();
									}
								} else {
									W_Musket_Attack();
								}
							}
						}
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_musket_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_musket_primary_animtime, w_ready);
						self.musket_release = 1; //Slide needs to be wracked
						self.weaponname = "musket";
						self.musket_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.musket_ontrigger != 1) &&
				(self.musket_release != 1) &&
				(self.musket_jammed != 1) &&
				(self.musket_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_musket_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.weaponname = "musket";

						self.musket_firedelay = time + autocvar_g_balance_musket_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_Musket_Attack2);
						self.musket_state = 1;
												
						if not (flintlock_powder_gets_wet(mysmokeorg)) {
							pointparticles(particleeffectnum("uzi_muzzleflash"), mysmokeorg, '0 0 0', 1);
							pointparticles(particleeffectnum("pipe_smoke"), mysmokeorg, '0 0 0', 10);
						}
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.musket_ontrigger != 1) &&
				(self.musket_release == 1) &&
				(self.musket_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_musket_secondary_refire))
				)
				{
					self.musket_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Musket_Attack2);
					self.musket_halftime = time + (autocvar_g_balance_musket_cocking_time * 0.5);
					self.musket_fulltime = time + autocvar_g_balance_musket_cocking_time;
					self.musket_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.musket_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.musket_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.musket_jammed && self.musket_unjam)
		  {
		  	if (time >= self.musket_unjam_time) {
				self.musket_jammed = 0;
				self.musket_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_musket.md3");
		precache_model ("models/weapons/v_musket.md3");
		precache_model ("models/weapons/h_musket.iqm");
		precache_model ("models/weapons/v_musket-cocked.md3");
		precache_model ("models/weapons/h_musket-cocked.iqm");
		precache_model ("models/weapons/v_musket-half.md3");
		precache_model ("models/weapons/h_musket-half.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -1.52';
		//self.weaponaltaim = '40 -0.55 -1.52';
		//self.weaponaltaim = '40 -0.45 -1.52';
		//self.weaponaltaim = '40 -0.15 -1.52';
		//self.weaponaltaim = '55 -0.15 -2.5';
		//self.weaponaltaim = '55 -0.05 -2.5';
		self.weaponaltaim = '55 0.05 -2.5';
		weapon_setup(WEP_MUSKET);
		self.current_ammo = ammo_nails;
		
		if not(self.musket_notnew) {
			self.musket_release = 1;
		
			self.weaponname = "musket";
		} else {
			if (self.musket_release == 1) {
				self.weaponname = "musket";
			} else {
				self.weaponname = "musket-cocked";
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_musket_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_MUSKET]) >= autocvar_g_balance_musket_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.musket_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		self.musket_botreload = 1;
		if (self.musket_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_musket_clearjam_time, w_ready);
			if (self.musket_unjam != 1) {
				self.musket_unjam = 1;
				self.musket_unjam_time = time + autocvar_g_balance_musket_clearjam_time;
				self.musket_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the musket\n");
				}
			}
		} else {
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_musket_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_musket_primary_ammo, autocvar_g_balance_musket_reload_ammo, autocvar_g_balance_musket_reload_time - (autocvar_g_balance_musket_reload_time * (self.clip_load/autocvar_g_balance_musket_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_musket_primary_ammo, autocvar_g_balance_musket_reload_ammo, autocvar_g_balance_musket_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_musket_casings) {
					for (sc = 0;sc < self.musket_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 56, self, '0 0 -3');
					}
				}
				self.musket_casings = 0;
			}
		}
		//self.musket_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_musket(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
		} else {
			pointparticles(particleeffectnum("largebullet_impact"), org2, w_backoff * 1000, 1);
		}
		
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
		if(w_deathtype & HITTYPE_SECONDARY) {
			if(w_deathtype & HITTYPE_CORESHOT)
				w_deathtypestring = _("%s was shot in the chest with buckshot from %s's musket");
			else 
				w_deathtypestring = _("%s was shot to death with buckshot from %s's musket");
		} else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s was shot in the chest by %s's musket");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot in the skull by %s's musket");
		else
			w_deathtypestring = _("%s was shot to death by %s's musket");
	}
	return TRUE;
}
#endif
#endif
