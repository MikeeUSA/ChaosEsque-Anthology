#ifdef REGISTER_WEAPON
REGISTER_WEAPON(EIGHTGAUGESAWEDOFF, w_eightgaugesawedoff, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "eightgaugesawedoff", "eightgaugesawedoff", _("8ga Sawed-Off"))
#else
#ifdef SVQC

.float eightgaugesawedoff_release;
.float eightgaugesawedoff_casings;
.float eightgaugesawedoff_jammed;
.float eightgaugesawedoff_unjam;
.float eightgaugesawedoff_unjam_time;
.float eightgaugesawedoff_click;
.float eightgaugesawedoff_halftime;
.float eightgaugesawedoff_fulltime;
.float eightgaugesawedoff_state;
.float eightgaugesawedoff_ontrigger;
.float eightgaugesawedoff_firedelay;
.float eightgaugesawedoff_firenow;
.float eightgaugesawedoff_botreload;
.float eightgaugesawedoff_notnew;
.float eightgaugesawedoff_reloadanimtime;
.float eightgaugesawedoff_reloaddo;
.float eightgaugesawedoff_reloaddo_wait;

void W_EightGaugeSawedOff_Attack (void)
{
	float sc;
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bullets;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_eightgaugesawedoff_primary_ammo;
	bullets = autocvar_g_balance_eightgaugesawedoff_primary_bullets;
	d = autocvar_g_balance_eightgaugesawedoff_primary_damage;
	f = autocvar_g_balance_eightgaugesawedoff_primary_force;
	spread = autocvar_g_balance_eightgaugesawedoff_primary_spread;
	bulletspeed = autocvar_g_balance_eightgaugesawedoff_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_eightgaugesawedoff_reload_ammo);
	self.eightgaugesawedoff_casings = self.eightgaugesawedoff_casings + 1;
	
	if (autocvar_g_balance_eightgaugesawedoff_jamrate &&
 	(autocvar_g_balance_eightgaugesawedoff_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your eightgaugesawedoff failed to fire\n");
		}
		self.eightgaugesawedoff_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d);

		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_EIGHTGAUGESAWEDOFF, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_eightgaugesawedoff_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg + (w_shotdir * 2), w_shotdir * 1000, autocvar_g_balance_eightgaugesawedoff_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 2));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 2), w_shotdir * 2, 25);
	}
	
	PlayerGunRise(self, autocvar_g_balance_eightgaugesawedoff_gunrise, random() * autocvar_g_balance_eightgaugesawedoff_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '-10 0 0');
	
	} //End Not Jammed
}

void W_EightGaugeSawedOff_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_eightgaugesawedoff_secondary_animtime, w_ready);
}

float W_EightGaugeSawedOff_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_eightgaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugesawedoff_primary_ammo))
	{
		if (!self.eightgaugesawedoff_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.eightgaugesawedoff_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.eightgaugesawedoff_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_eightgaugesawedoff (void)
{
	weapon_defaultspawnfunc(WEP_EIGHTGAUGESAWEDOFF);
}


.float eightgaugesawedoff_primarytime;

float w_eightgaugesawedoff(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_EightGaugeSawedOff_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.eightgaugesawedoff_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_eightgaugesawedoff_primary_speed, 0, 5, FALSE)) && (!self.eightgaugesawedoff_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && self.eightgaugesawedoff_reloaddo)
	{
		//print("here\n");
		if (time > self.eightgaugesawedoff_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_EightGaugeSawedOff_NeedManualReload())
	{
		self.eightgaugesawedoff_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.eightgaugesawedoff_reloadanimtime && self.eightgaugesawedoff_reloadanimtime > time) {
		  	if (!self.eightgaugesawedoff_reloaddo_wait) {
				self.eightgaugesawedoff_reloadanimtime = 0;
				
				if (self.eightgaugesawedoff_release == 1) {
					self.weaponname = "eightgaugesawedoff";
				} else {
					self.weaponname = "eightgaugesawedoff-cocked";
				}
			}
		}
		
		
		if(autocvar_g_balance_eightgaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugesawedoff_primary_ammo) // forced reload
		{
			// don't force reload an empty eightgaugesawedoff if its melee attack is active
			if not(autocvar_g_balance_eightgaugesawedoff_secondary && self.ammo_shells < autocvar_g_balance_eightgaugesawedoff_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.eightgaugesawedoff_release = 0;
		}
		else
		{
		  if (self.eightgaugesawedoff_jammed && self.eightgaugesawedoff_unjam)
		  {
		  	if (time >= self.eightgaugesawedoff_unjam_time) {
				self.eightgaugesawedoff_jammed = 0;
				self.eightgaugesawedoff_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.eightgaugesawedoff_state == 3) {
		  		if (time > self.eightgaugesawedoff_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeSawedOff_Attack2);
					self.eightgaugesawedoff_state = 2;
					self.weaponname = "eightgaugesawedoff-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_eightgaugesawedoff_cockingrise, random() * autocvar_g_balance_eightgaugesawedoff_cockingrun);
				}
			} else if (self.eightgaugesawedoff_state == 2) {
				if (time > self.eightgaugesawedoff_fulltime) {
					self.eightgaugesawedoff_state = 400;
					self.eightgaugesawedoff_release = 0; //We finish pulling back the hammer
					self.weaponname = "eightgaugesawedoff-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.eightgaugesawedoff_state == 1) {
				if (time > self.eightgaugesawedoff_firedelay) {
					self.eightgaugesawedoff_state = 0;

					self.eightgaugesawedoff_firedelay = 0;
					self.weaponname = "eightgaugesawedoff";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.eightgaugesawedoff_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.eightgaugesawedoff_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugesawedoff_primary_refire))
				)
				{
						self.eightgaugesawedoff_ontrigger = 1;
						
						
						W_EightGaugeSawedOff_Attack();
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_eightgaugesawedoff_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_eightgaugesawedoff_primary_animtime, w_ready);
						self.eightgaugesawedoff_release = 1; //Slide needs to be wracked
						self.weaponname = "eightgaugesawedoff";
						self.eightgaugesawedoff_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.eightgaugesawedoff_ontrigger != 1) &&
				(self.eightgaugesawedoff_release != 1) &&
				(self.eightgaugesawedoff_jammed != 1) &&
				(self.eightgaugesawedoff_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugesawedoff_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.weaponname = "eightgaugesawedoff";

						self.eightgaugesawedoff_firedelay = time + autocvar_g_balance_eightgaugesawedoff_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeSawedOff_Attack2);
						self.eightgaugesawedoff_state = 1;
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.eightgaugesawedoff_ontrigger != 1) &&
				(self.eightgaugesawedoff_release == 1) &&
				(self.eightgaugesawedoff_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugesawedoff_secondary_refire))
				)
				{
					self.eightgaugesawedoff_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeSawedOff_Attack2);
					self.eightgaugesawedoff_halftime = time + (autocvar_g_balance_eightgaugesawedoff_cocking_time * 0.5);
					self.eightgaugesawedoff_fulltime = time + autocvar_g_balance_eightgaugesawedoff_cocking_time;
					self.eightgaugesawedoff_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.eightgaugesawedoff_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.eightgaugesawedoff_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.eightgaugesawedoff_jammed && self.eightgaugesawedoff_unjam)
		  {
		  	if (time >= self.eightgaugesawedoff_unjam_time) {
				self.eightgaugesawedoff_jammed = 0;
				self.eightgaugesawedoff_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_eightgaugesawedoff.md3");
		precache_model ("models/weapons/v_eightgaugesawedoff.md3");
		precache_model ("models/weapons/h_eightgaugesawedoff.iqm");
		precache_model ("models/weapons/v_eightgaugesawedoff-cocked.md3");
		precache_model ("models/weapons/h_eightgaugesawedoff-cocked.iqm");
		precache_model ("models/weapons/v_eightgaugesawedoff-half.md3");
		precache_model ("models/weapons/h_eightgaugesawedoff-half.iqm");
		precache_model ("models/weapons/v_eightgaugesawedoff-reload.md3");
		precache_model ("models/weapons/h_eightgaugesawedoff-reload.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
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
		//self.weaponaltaim = '55 0.05 -2.5';
		//self.weaponaltaim = '55 0.05 -3.5';
		//self.weaponaltaim = '55 -0.15 -5.5';
		//self.weaponaltaim = '55 -0.15 -3.5';
		//self.weaponaltaim = '55 -0.15 -2.5';
		//self.weaponaltaim = '55 -0.15 -2.2';
		self.weaponaltaim = '58 -0.15 -2.7';
		weapon_setup(WEP_EIGHTGAUGESAWEDOFF);
		self.current_ammo = ammo_shells;
		
		self.eightgaugesawedoff_reloaddo = 0;
		self.eightgaugesawedoff_reloaddo_wait = 0;
		
		if not(self.eightgaugesawedoff_notnew) {
			self.eightgaugesawedoff_release = 1;
		
			self.weaponname = "eightgaugesawedoff";
		} else {
			if (self.eightgaugesawedoff_release == 1) {
				self.weaponname = "eightgaugesawedoff";
			} else {
				self.weaponname = "eightgaugesawedoff-cocked";
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_eightgaugesawedoff_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_EIGHTGAUGESAWEDOFF]) >= autocvar_g_balance_eightgaugesawedoff_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.eightgaugesawedoff_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.eightgaugesawedoff_jammed) {
			self.eightgaugesawedoff_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_eightgaugesawedoff_clearjam_time, w_ready);
			if (self.eightgaugesawedoff_unjam != 1) {
				self.eightgaugesawedoff_unjam = 1;
				self.eightgaugesawedoff_unjam_time = time + autocvar_g_balance_eightgaugesawedoff_clearjam_time;
				self.eightgaugesawedoff_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the eightgaugesawedoff\n");
				}
			}
		} else if not (self.eightgaugesawedoff_reloadanimtime) {
			self.eightgaugesawedoff_reloaddo = 1;
			self.eightgaugesawedoff_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_eightgaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugesawedoff_primary_ammo) {
					self.weaponname = "eightgaugesawedoff-reload";
				}
			self.eightgaugesawedoff_reloadanimtime = time + frametime + autocvar_g_balance_eightgaugesawedoff_reload_time;
		} else {
			self.eightgaugesawedoff_reloaddo = 0;
			self.eightgaugesawedoff_reloaddo_wait = 0;
			self.eightgaugesawedoff_botreload = 1;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_eightgaugesawedoff_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.eightgaugesawedoff_reloadanimtime = time + frametime + (autocvar_g_balance_eightgaugesawedoff_reload_time - (autocvar_g_balance_eightgaugesawedoff_reload_time * (self.clip_load/autocvar_g_balance_eightgaugesawedoff_reload_ammo)));
				W_Reload(autocvar_g_balance_eightgaugesawedoff_primary_ammo, autocvar_g_balance_eightgaugesawedoff_reload_ammo, autocvar_g_balance_eightgaugesawedoff_reload_time - (autocvar_g_balance_eightgaugesawedoff_reload_time * (self.clip_load/autocvar_g_balance_eightgaugesawedoff_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.eightgaugesawedoff_reloadanimtime = time + frametime + autocvar_g_balance_eightgaugesawedoff_reload_time;
				W_Reload(autocvar_g_balance_eightgaugesawedoff_primary_ammo, autocvar_g_balance_eightgaugesawedoff_reload_ammo, autocvar_g_balance_eightgaugesawedoff_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_eightgaugesawedoff_casings) {
					for (sc = 0;sc < self.eightgaugesawedoff_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 59, self, '0 0 -3');
					}
				}
				self.eightgaugesawedoff_casings = 0;
			}
		}
		//self.eightgaugesawedoff_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_eightgaugesawedoff(float req)
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
			w_deathtypestring = _("%1$s found it difficult to process substance due to the size of the holes %2$s put in their chest");
		else
			w_deathtypestring = _("%s was gunned down with a 8ga sawed-off shotgun by %s");
	}
	return TRUE;
}
#endif
#endif
