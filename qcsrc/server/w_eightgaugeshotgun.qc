#ifdef REGISTER_WEAPON
REGISTER_WEAPON(EIGHTGAUGESHOTGUN, w_eightgaugeshotgun, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "eightgaugeshotgun", "eightgaugeshotgun", _("8ga Shotgun"))
#else
#ifdef SVQC

.float eightgaugeshotgun_release;
.float eightgaugeshotgun_casings;
.float eightgaugeshotgun_jammed;
.float eightgaugeshotgun_unjam;
.float eightgaugeshotgun_unjam_time;
.float eightgaugeshotgun_click;
.float eightgaugeshotgun_halftime;
.float eightgaugeshotgun_fulltime;
.float eightgaugeshotgun_state;
.float eightgaugeshotgun_ontrigger;
.float eightgaugeshotgun_firedelay;
.float eightgaugeshotgun_firenow;
.float eightgaugeshotgun_botreload;
.float eightgaugeshotgun_notnew;
.float eightgaugeshotgun_reloadanimtime;
.float eightgaugeshotgun_reloaddo;
.float eightgaugeshotgun_reloaddo_wait;

void W_EightGaugeShotgun_Attack (void)
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

	ammoamount = autocvar_g_balance_eightgaugeshotgun_primary_ammo;
	bullets = autocvar_g_balance_eightgaugeshotgun_primary_bullets;
	d = autocvar_g_balance_eightgaugeshotgun_primary_damage;
	f = autocvar_g_balance_eightgaugeshotgun_primary_force;
	spread = autocvar_g_balance_eightgaugeshotgun_primary_spread;
	bulletspeed = autocvar_g_balance_eightgaugeshotgun_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_eightgaugeshotgun_reload_ammo);
	self.eightgaugeshotgun_casings = self.eightgaugeshotgun_casings + 1;
	
	if (autocvar_g_balance_eightgaugeshotgun_jamrate &&
 	(autocvar_g_balance_eightgaugeshotgun_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your eightgaugeshotgun failed to fire\n");
		}
		self.eightgaugeshotgun_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d);

		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_EIGHTGAUGESHOTGUN, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_eightgaugeshotgun_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_eightgaugeshotgun_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 25);
	}
	
	PlayerGunRise(self, autocvar_g_balance_eightgaugeshotgun_gunrise, random() * autocvar_g_balance_eightgaugeshotgun_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '20 0 0');
	
	} //End Not Jammed
}

void W_EightGaugeShotgun_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_eightgaugeshotgun_secondary_animtime, w_ready);
}

float W_EightGaugeShotgun_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_eightgaugeshotgun_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugeshotgun_primary_ammo))
	{
		if (!self.eightgaugeshotgun_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.eightgaugeshotgun_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.eightgaugeshotgun_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_eightgaugeshotgun (void)
{
	weapon_defaultspawnfunc(WEP_EIGHTGAUGESHOTGUN);
}


.float eightgaugeshotgun_primarytime;

float w_eightgaugeshotgun(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_EightGaugeShotgun_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.eightgaugeshotgun_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_eightgaugeshotgun_primary_speed, 0, 5, FALSE)) && (!self.eightgaugeshotgun_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && self.eightgaugeshotgun_reloaddo)
	{
		//print("here\n");
		if (time > self.eightgaugeshotgun_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_EightGaugeShotgun_NeedManualReload())
	{
		self.eightgaugeshotgun_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.eightgaugeshotgun_reloadanimtime && self.eightgaugeshotgun_reloadanimtime > time) {
		  	if (!self.eightgaugeshotgun_reloaddo_wait) {
				self.eightgaugeshotgun_reloadanimtime = 0;
				
				if (self.eightgaugeshotgun_release == 1) {
					self.weaponname = "eightgaugeshotgun";
				} else {
					self.weaponname = "eightgaugeshotgun-cocked";
				}
			}
		}
		
		
		if(autocvar_g_balance_eightgaugeshotgun_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugeshotgun_primary_ammo) // forced reload
		{
			// don't force reload an empty eightgaugeshotgun if its melee attack is active
			if not(autocvar_g_balance_eightgaugeshotgun_secondary && self.ammo_shells < autocvar_g_balance_eightgaugeshotgun_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.eightgaugeshotgun_release = 0;
		}
		else
		{
		  if (self.eightgaugeshotgun_jammed && self.eightgaugeshotgun_unjam)
		  {
		  	if (time >= self.eightgaugeshotgun_unjam_time) {
				self.eightgaugeshotgun_jammed = 0;
				self.eightgaugeshotgun_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.eightgaugeshotgun_state == 3) {
		  		if (time > self.eightgaugeshotgun_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeShotgun_Attack2);
					self.eightgaugeshotgun_state = 2;
					self.weaponname = "eightgaugeshotgun-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_eightgaugeshotgun_cockingrise, random() * autocvar_g_balance_eightgaugeshotgun_cockingrun);
				}
			} else if (self.eightgaugeshotgun_state == 2) {
				if (time > self.eightgaugeshotgun_fulltime) {
					self.eightgaugeshotgun_state = 400;
					self.eightgaugeshotgun_release = 0; //We finish pulling back the hammer
					self.weaponname = "eightgaugeshotgun-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.eightgaugeshotgun_state == 1) {
				if (time > self.eightgaugeshotgun_firedelay) {
					self.eightgaugeshotgun_state = 0;

					self.eightgaugeshotgun_firedelay = 0;
					self.weaponname = "eightgaugeshotgun";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.eightgaugeshotgun_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.eightgaugeshotgun_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugeshotgun_primary_refire))
				)
				{
						self.eightgaugeshotgun_ontrigger = 1;
						
						
						W_EightGaugeShotgun_Attack();
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_eightgaugeshotgun_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_eightgaugeshotgun_primary_animtime, w_ready);
						self.eightgaugeshotgun_release = 1; //Slide needs to be wracked
						self.weaponname = "eightgaugeshotgun";
						self.eightgaugeshotgun_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.eightgaugeshotgun_ontrigger != 1) &&
				(self.eightgaugeshotgun_release != 1) &&
				(self.eightgaugeshotgun_jammed != 1) &&
				(self.eightgaugeshotgun_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugeshotgun_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.weaponname = "eightgaugeshotgun";

						self.eightgaugeshotgun_firedelay = time + autocvar_g_balance_eightgaugeshotgun_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeShotgun_Attack2);
						self.eightgaugeshotgun_state = 1;
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.eightgaugeshotgun_ontrigger != 1) &&
				(self.eightgaugeshotgun_release == 1) &&
				(self.eightgaugeshotgun_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_eightgaugeshotgun_secondary_refire))
				)
				{
					self.eightgaugeshotgun_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_EightGaugeShotgun_Attack2);
					self.eightgaugeshotgun_halftime = time + (autocvar_g_balance_eightgaugeshotgun_cocking_time * 0.5);
					self.eightgaugeshotgun_fulltime = time + autocvar_g_balance_eightgaugeshotgun_cocking_time;
					self.eightgaugeshotgun_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.eightgaugeshotgun_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.eightgaugeshotgun_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.eightgaugeshotgun_jammed && self.eightgaugeshotgun_unjam)
		  {
		  	if (time >= self.eightgaugeshotgun_unjam_time) {
				self.eightgaugeshotgun_jammed = 0;
				self.eightgaugeshotgun_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_eightgaugeshotgun.md3");
		precache_model ("models/weapons/v_eightgaugeshotgun.md3");
		precache_model ("models/weapons/h_eightgaugeshotgun.iqm");
		precache_model ("models/weapons/v_eightgaugeshotgun-cocked.md3");
		precache_model ("models/weapons/h_eightgaugeshotgun-cocked.iqm");
		precache_model ("models/weapons/v_eightgaugeshotgun-half.md3");
		precache_model ("models/weapons/h_eightgaugeshotgun-half.iqm");
		precache_model ("models/weapons/v_eightgaugeshotgun-reload.md3");
		precache_model ("models/weapons/h_eightgaugeshotgun-reload.iqm");
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
		self.weaponaltaim = '55 -0.15 -2.4';
		weapon_setup(WEP_EIGHTGAUGESHOTGUN);
		self.current_ammo = ammo_shells;
		
		self.eightgaugeshotgun_reloaddo = 0;
		self.eightgaugeshotgun_reloaddo_wait = 0;
		
		if not(self.eightgaugeshotgun_notnew) {
			self.eightgaugeshotgun_release = 1;
		
			self.weaponname = "eightgaugeshotgun";
		} else {
			if (self.eightgaugeshotgun_release == 1) {
				self.weaponname = "eightgaugeshotgun";
			} else {
				self.weaponname = "eightgaugeshotgun-cocked";
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_eightgaugeshotgun_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_EIGHTGAUGESHOTGUN]) >= autocvar_g_balance_eightgaugeshotgun_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.eightgaugeshotgun_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.eightgaugeshotgun_jammed) {
			self.eightgaugeshotgun_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_eightgaugeshotgun_clearjam_time, w_ready);
			if (self.eightgaugeshotgun_unjam != 1) {
				self.eightgaugeshotgun_unjam = 1;
				self.eightgaugeshotgun_unjam_time = time + autocvar_g_balance_eightgaugeshotgun_clearjam_time;
				self.eightgaugeshotgun_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the eightgaugeshotgun\n");
				}
			}
		} else if not (self.eightgaugeshotgun_reloadanimtime) {
			self.eightgaugeshotgun_reloaddo = 1;
			self.eightgaugeshotgun_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_eightgaugeshotgun_reload_ammo && self.clip_load < autocvar_g_balance_eightgaugeshotgun_primary_ammo) {
					self.weaponname = "eightgaugeshotgun-reload";
				}
			self.eightgaugeshotgun_reloadanimtime = time + frametime + autocvar_g_balance_eightgaugeshotgun_reload_time;
		} else {
			self.eightgaugeshotgun_reloaddo = 0;
			self.eightgaugeshotgun_reloaddo_wait = 0;
			self.eightgaugeshotgun_botreload = 1;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_eightgaugeshotgun_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.eightgaugeshotgun_reloadanimtime = time + frametime + (autocvar_g_balance_eightgaugeshotgun_reload_time - (autocvar_g_balance_eightgaugeshotgun_reload_time * (self.clip_load/autocvar_g_balance_eightgaugeshotgun_reload_ammo)));
				W_Reload(autocvar_g_balance_eightgaugeshotgun_primary_ammo, autocvar_g_balance_eightgaugeshotgun_reload_ammo, autocvar_g_balance_eightgaugeshotgun_reload_time - (autocvar_g_balance_eightgaugeshotgun_reload_time * (self.clip_load/autocvar_g_balance_eightgaugeshotgun_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.eightgaugeshotgun_reloadanimtime = time + frametime + autocvar_g_balance_eightgaugeshotgun_reload_time;
				W_Reload(autocvar_g_balance_eightgaugeshotgun_primary_ammo, autocvar_g_balance_eightgaugeshotgun_reload_ammo, autocvar_g_balance_eightgaugeshotgun_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_eightgaugeshotgun_casings) {
					for (sc = 0;sc < self.eightgaugeshotgun_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 59, self, '0 0 -3');
					}
				}
				self.eightgaugeshotgun_casings = 0;
			}
		}
		//self.eightgaugeshotgun_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_eightgaugeshotgun(float req)
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
			w_deathtypestring = _("%1$s found it difficult to process substance the size of the hole %2$s put in their chest");
		else
			w_deathtypestring = _("%s was gunned down with a 8ga shotgun by %s");
	}
	return TRUE;
}
#endif
#endif
