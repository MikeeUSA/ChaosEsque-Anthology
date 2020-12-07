#ifdef REGISTER_WEAPON
REGISTER_WEAPON(PEPPERBOXREVOLVER, w_pepperboxrevolver, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "pepperboxrevolver", "pepperboxrevolver", _("Pepperbox"))
#else
#ifdef SVQC

.float pepperboxrevolver_release;
.float pepperboxrevolver_casings;
.float pepperboxrevolver_jammed;
.float pepperboxrevolver_unjam;
.float pepperboxrevolver_unjam_time;
.float pepperboxrevolver_click;
.float pepperboxrevolver_halftime;
.float pepperboxrevolver_fulltime;
.float pepperboxrevolver_state;
.float pepperboxrevolver_doubleaction;
.float pepperboxrevolver_ontrigger;
.float pepperboxrevolver_firedelay;
.float pepperboxrevolver_firenow;
float flintlock_powder_gets_wet (vector mytestorigin);
float flintlock_powder_gets_hot (vector mytestorigin);
float flintlock_powder_spontaneously_ignites (entity e);

void W_PepperboxRevolver_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_pepperboxrevolver_primary_ammo;
	d = autocvar_g_balance_pepperboxrevolver_primary_damage;
	f = autocvar_g_balance_pepperboxrevolver_primary_force;
	spread = autocvar_g_balance_pepperboxrevolver_primary_spread;
	bulletspeed = autocvar_g_balance_pepperboxrevolver_primary_speed;
	bulletconstant = autocvar_g_balance_pepperboxrevolver_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_pepperboxrevolver_reload_ammo);
	self.pepperboxrevolver_casings = self.pepperboxrevolver_casings + 1;
	
	if (autocvar_g_balance_pepperboxrevolver_jamrate &&
 	(autocvar_g_balance_pepperboxrevolver_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your pepperbox revolver jammed\n");
		}
		self.pepperboxrevolver_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_pepperboxrevolver_primary_headshotaddeddamage, f, WEP_PEPPERBOXREVOLVER, PROJECTILE_MUSKETBALL36, 1, bulletconstant, autocvar_g_balance_pepperboxrevolver_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_pepperboxrevolver_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 10);
	}
	
	PlayerGunRise(self, autocvar_g_balance_pepperboxrevolver_gunrise, random() * autocvar_g_balance_pepperboxrevolver_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '9.5 0 0');
	
	} //End Not Jammed
}

void W_PepperboxRevolver_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_pepperboxrevolver_secondary_animtime, w_ready);
}

float W_PepperboxRevolver_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_pepperboxrevolver_reload_ammo && self.clip_load < autocvar_g_balance_pepperboxrevolver_primary_ammo))
	{
		if (!self.pepperboxrevolver_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.pepperboxrevolver_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.pepperboxrevolver_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_pepperboxrevolver (void)
{
	weapon_defaultspawnfunc(WEP_PEPPERBOXREVOLVER);
}


.float pepperboxrevolver_primarytime;

float w_pepperboxrevolver(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_PepperboxRevolver_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.pepperboxrevolver_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.pepperboxrevolver_state) {
			self.BUTTON_ATCK = TRUE; //In the middle of double action attack, keep the trigger pressed
		} else {
			self.pepperboxrevolver_ontrigger = 0;
			self.pepperboxrevolver_doubleaction = 0; //Not squeezing trigger
			
			if((bot_aim(autocvar_g_balance_pepperboxrevolver_primary_speed, 0, 5, FALSE)) && (!self.pepperboxrevolver_ontrigger))
			{
					self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_PepperboxRevolver_NeedManualReload())
	{
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		if (flintlock_powder_gets_hot(mysmokeorg)
		|| flintlock_powder_spontaneously_ignites(self)) {
			W_PepperboxRevolver_Attack();
		} else if(autocvar_g_balance_pepperboxrevolver_reload_ammo && self.clip_load < autocvar_g_balance_pepperboxrevolver_primary_ammo) // forced reload
		{
			// don't force reload an empty pepperboxrevolver if its melee attack is active
			if not(autocvar_g_balance_pepperboxrevolver_secondary && self.ammo_nails < autocvar_g_balance_pepperboxrevolver_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.pepperboxrevolver_release = 0;
		}
		else
		{
		  if (self.pepperboxrevolver_jammed && self.pepperboxrevolver_unjam)
		  {
		  	if (time >= self.pepperboxrevolver_unjam_time) {
				self.pepperboxrevolver_jammed = 0;
				self.pepperboxrevolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.pepperboxrevolver_state == 3) {
		  		if (time > self.pepperboxrevolver_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_PepperboxRevolver_Attack2);
					self.pepperboxrevolver_state = 2;
					self.weaponname = "pepperboxrevolver-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					if (self.pepperboxrevolver_doubleaction == 1) {
						//print("DoubleAction\n");
						PlayerGunRise(self, autocvar_g_balance_pepperboxrevolver_darise, random() * autocvar_g_balance_pepperboxrevolver_darun);
					} else {
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_pepperboxrevolver_cockingrise, random() * autocvar_g_balance_pepperboxrevolver_cockingrun);
					}
				}
			} else if (self.pepperboxrevolver_state == 2) {
				if (time > self.pepperboxrevolver_fulltime) {
					self.pepperboxrevolver_state = 1;
						//self.pepperboxrevolver_release = 0; //We finish pulling back the hammer
					self.weaponname = "pepperboxrevolver-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.pepperboxrevolver_firedelay = time + autocvar_g_balance_pepperboxrevolver_primary_firedelay;
				}
			} else if (self.pepperboxrevolver_state == 1) {
				if (time > self.pepperboxrevolver_firedelay) {
					self.pepperboxrevolver_state = 0;
					self.pepperboxrevolver_release = 0; //We finish pulling back the hammer
					self.pepperboxrevolver_firedelay = 0;
					self.weaponname = "pepperboxrevolver";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.pepperboxrevolver_firenow = 1;
				}
			}
			else 
			{
				////NORMAL
				if (
				(self.pepperboxrevolver_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_pepperboxrevolver_primary_refire))
				)
				{
						self.pepperboxrevolver_ontrigger = 1;
						
						if (self.BUTTON_ATCK) {
							//print("here1a\n");
							if (flintlock_powder_gets_wet(mysmokeorg)) {

								W_DecreaseAmmo(ammo_nails, autocvar_g_balance_pepperboxrevolver_primary_ammo, autocvar_g_balance_pepperboxrevolver_reload_ammo);
								self.pepperboxrevolver_casings = self.pepperboxrevolver_casings + 1;
	
								//if ((clienttype(self) == CLIENTTYPE_REAL)) {
								//	sprint(self, "Your powder failed to ignite when wet\n");
								//}
								////Doesn't jam, just decreases ammo
		
							} else {								
								local float myraincheck;
								myraincheck = CheckIfEntityIsInRain(self);
								//print(ftos(myraincheck),"_ppprbx\n");
							
								if (myraincheck >= 100) {
									//Do nothing
								} else {
									if (myraincheck >= 70) {
										if (random() > 0.90) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 60) {
										if (random() > 0.80) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 50) {
										if (random() > 0.70) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 40) {
										if (random() > 0.60) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 30) {
										if (random() > 0.50) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 25) {
										if (random() > 0.40) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 20) {
										if (random() > 0.20) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 15) {
										if (random() > 0.15) {
											W_PepperboxRevolver_Attack();
										}
									} else if (myraincheck >= 10) {
										if (random() > 0.10) {
											W_PepperboxRevolver_Attack();
										}
									} else {
										W_PepperboxRevolver_Attack();
									}
								}
							}
						}
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_pepperboxrevolver_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pepperboxrevolver_primary_animtime, w_ready);
						self.pepperboxrevolver_release = 1; //Slide needs to be wracked
						self.weaponname = "pepperboxrevolver";
						self.pepperboxrevolver_firenow = 0;
						//print("here1\n");
						
						if (autocvar_g_balance_pepperboxrevolver_fullauto) {
							self.pepperboxrevolver_ontrigger = 0;
							self.pepperboxrevolver_doubleaction = 0; //Not squeezing trigger	
						}
				}
				else if (
				(self.BUTTON_ATCK) &&
				(self.pepperboxrevolver_ontrigger != 1) &&
				(self.pepperboxrevolver_release == 1) &&
				(self.pepperboxrevolver_jammed != 1) &&
				(self.pepperboxrevolver_doubleaction != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_pepperboxrevolver_primary_refire))
				)
				{
					self.pepperboxrevolver_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_PepperboxRevolver_Attack2);
					self.pepperboxrevolver_halftime = time + (autocvar_g_balance_pepperboxrevolver_cocking_time * 0.5);
					self.pepperboxrevolver_fulltime = time + autocvar_g_balance_pepperboxrevolver_cocking_time;
					self.pepperboxrevolver_state = 3;
					self.pepperboxrevolver_doubleaction = 1;
					//print("here2\n");
				}
				
				
				if not(self.BUTTON_ATCK)
				{
					self.pepperboxrevolver_ontrigger = 0;
					self.pepperboxrevolver_doubleaction = 0; //Not squeezing trigger
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.pepperboxrevolver_jammed && self.pepperboxrevolver_unjam)
		  {
		  	if (time >= self.pepperboxrevolver_unjam_time) {
				self.pepperboxrevolver_jammed = 0;
				self.pepperboxrevolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_pepperboxrevolver.md3");
		precache_model ("models/weapons/v_pepperboxrevolver.md3");
		precache_model ("models/weapons/h_pepperboxrevolver.iqm");
		precache_model ("models/weapons/v_pepperboxrevolver-cocked.md3");
		precache_model ("models/weapons/h_pepperboxrevolver-cocked.iqm");
		precache_model ("models/weapons/v_pepperboxrevolver-half.md3");
		precache_model ("models/weapons/h_pepperboxrevolver-half.iqm");
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
		self.weaponaltaim = '40 -0.15 -1.52';
		weapon_setup(WEP_PEPPERBOXREVOLVER);
		self.current_ammo = ammo_nails;
		
		self.pepperboxrevolver_release = 1;
		
		self.weaponname = "pepperboxrevolver";
		
		self.pepperboxrevolver_doubleaction = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_pepperboxrevolver_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_PEPPERBOXREVOLVER]) >= autocvar_g_balance_pepperboxrevolver_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.pepperboxrevolver_casings = 0;
		self.pepperboxrevolver_doubleaction = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.pepperboxrevolver_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_pepperboxrevolver_clearjam_time, w_ready);
			if (self.pepperboxrevolver_unjam != 1) {
				self.pepperboxrevolver_unjam = 1;
				self.pepperboxrevolver_unjam_time = time + autocvar_g_balance_pepperboxrevolver_clearjam_time;
				self.pepperboxrevolver_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the pepperboxrevolver\n");
				}
			}
		} else {
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_pepperboxrevolver_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_pepperboxrevolver_primary_ammo, autocvar_g_balance_pepperboxrevolver_reload_ammo, autocvar_g_balance_pepperboxrevolver_reload_time - (autocvar_g_balance_pepperboxrevolver_reload_time * (self.clip_load/autocvar_g_balance_pepperboxrevolver_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_pepperboxrevolver_primary_ammo, autocvar_g_balance_pepperboxrevolver_reload_ammo, autocvar_g_balance_pepperboxrevolver_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_pepperboxrevolver_casings) {
					for (sc = 0;sc < self.pepperboxrevolver_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 56, self, '0 0 -3');
					}
				}
				self.pepperboxrevolver_casings = 0;
			}
		}
		//self.pepperboxrevolver_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_pepperboxrevolver(float req)
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
			w_deathtypestring = _("%s was shot in the chest by %s's pepperbox revolver");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot in the skull by %s's pepperbox revolver");
		else
			w_deathtypestring = _("%s was shot to death by %s's pepperbox revolver");
	}
	return TRUE;
}
#endif
#endif
