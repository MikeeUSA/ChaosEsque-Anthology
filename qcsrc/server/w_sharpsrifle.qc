#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SHARPSRIFLE, w_sharpsrifle, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "sharpsrifle", "sharpsrifle", _("Sharps Rifle"))
#else
#ifdef SVQC

.float sharpsrifle_release;
.float sharpsrifle_casings;
.float sharpsrifle_jammed;
.float sharpsrifle_unjam;
.float sharpsrifle_unjam_time;
.float sharpsrifle_click;
.float sharpsrifle_halftime;
.float sharpsrifle_fulltime;
.float sharpsrifle_state;
.float sharpsrifle_ontrigger;
.float sharpsrifle_firedelay;
.float sharpsrifle_firenow;
.float sharpsrifle_botreload;
.float sharpsrifle_notnew;
.float sharpsrifle_reloadanimtime;
.float sharpsrifle_reloaddo;
.float sharpsrifle_reloaddo_wait;

void W_SharpsRifle_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_sharpsrifle_primary_ammo;
	d = autocvar_g_balance_sharpsrifle_primary_damage;
	f = autocvar_g_balance_sharpsrifle_primary_force;
	spread = autocvar_g_balance_sharpsrifle_primary_spread;
	bulletspeed = autocvar_g_balance_sharpsrifle_primary_speed;
	bulletconstant = autocvar_g_balance_sharpsrifle_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_sharpsrifle_reload_ammo);
	self.sharpsrifle_casings = self.sharpsrifle_casings + 1;
	
	if (autocvar_g_balance_sharpsrifle_jamrate &&
 	(autocvar_g_balance_sharpsrifle_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your sharpsrifle failed to fire\n");
		}
		self.sharpsrifle_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_sharpsrifle_primary_headshotaddeddamage, f, WEP_SHARPSRIFLE, PROJECTILE_MINIEBALL50, 1, bulletconstant, autocvar_g_balance_sharpsrifle_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_sharpsrifle_primary_ammo);

	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 15);
	}
	
	PlayerGunRise(self, autocvar_g_balance_sharpsrifle_gunrise, random() * autocvar_g_balance_sharpsrifle_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '38 0 0');
	
	} //End Not Jammed
}

void W_SharpsRifle_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_sharpsrifle_secondary_animtime, w_ready);
}

float W_SharpsRifle_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_sharpsrifle_reload_ammo && self.clip_load < autocvar_g_balance_sharpsrifle_primary_ammo))
	{
		if (!self.sharpsrifle_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.sharpsrifle_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.sharpsrifle_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_sharpsrifle (void)
{
	weapon_defaultspawnfunc(WEP_SHARPSRIFLE);
}


.float sharpsrifle_primarytime;

float w_sharpsrifle(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_SharpsRifle_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.sharpsrifle_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_sharpsrifle_primary_speed, 0, 5, FALSE)) && (!self.sharpsrifle_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && self.sharpsrifle_reloaddo)
	{
		//print("here\n");
		if (time > self.sharpsrifle_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_SharpsRifle_NeedManualReload())
	{
		self.sharpsrifle_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.sharpsrifle_reloadanimtime && self.sharpsrifle_reloadanimtime > time) {
		  	if (!self.sharpsrifle_reloaddo_wait) {
				self.sharpsrifle_reloadanimtime = 0;
				
				if (self.sharpsrifle_release == 1) {
					self.weaponname = "sharpsrifle";
				} else {
					self.weaponname = "sharpsrifle-cocked";
				}
			}
		}
		
		
		if(autocvar_g_balance_sharpsrifle_reload_ammo && self.clip_load < autocvar_g_balance_sharpsrifle_primary_ammo) // forced reload
		{
			// don't force reload an empty sharpsrifle if its melee attack is active
			if not(autocvar_g_balance_sharpsrifle_secondary && self.ammo_nails < autocvar_g_balance_sharpsrifle_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.sharpsrifle_release = 0;
		}
		else
		{
		  if (self.sharpsrifle_jammed && self.sharpsrifle_unjam)
		  {
		  	if (time >= self.sharpsrifle_unjam_time) {
				self.sharpsrifle_jammed = 0;
				self.sharpsrifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.sharpsrifle_state == 3) {
		  		if (time > self.sharpsrifle_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_SharpsRifle_Attack2);
					self.sharpsrifle_state = 2;
					self.weaponname = "sharpsrifle-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_sharpsrifle_cockingrise, random() * autocvar_g_balance_sharpsrifle_cockingrun);
				}
			} else if (self.sharpsrifle_state == 2) {
				if (time > self.sharpsrifle_fulltime) {
					self.sharpsrifle_state = 400;
					self.sharpsrifle_release = 0; //We finish pulling back the hammer
					self.weaponname = "sharpsrifle-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.sharpsrifle_state == 1) {
				if (time > self.sharpsrifle_firedelay) {
					self.sharpsrifle_state = 0;

					self.sharpsrifle_firedelay = 0;
					self.weaponname = "sharpsrifle";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.sharpsrifle_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.sharpsrifle_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_sharpsrifle_primary_refire))
				)
				{
						self.sharpsrifle_ontrigger = 1;
						
						
						W_SharpsRifle_Attack();
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_sharpsrifle_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_sharpsrifle_primary_animtime, w_ready);
						self.sharpsrifle_release = 1; //Slide needs to be wracked
						self.weaponname = "sharpsrifle";
						self.sharpsrifle_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.sharpsrifle_ontrigger != 1) &&
				(self.sharpsrifle_release != 1) &&
				(self.sharpsrifle_jammed != 1) &&
				(self.sharpsrifle_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_sharpsrifle_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.weaponname = "sharpsrifle";

						self.sharpsrifle_firedelay = time + autocvar_g_balance_sharpsrifle_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_SharpsRifle_Attack2);
						self.sharpsrifle_state = 1;
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.sharpsrifle_ontrigger != 1) &&
				(self.sharpsrifle_release == 1) &&
				(self.sharpsrifle_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_sharpsrifle_secondary_refire))
				)
				{
					self.sharpsrifle_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_SharpsRifle_Attack2);
					self.sharpsrifle_halftime = time + (autocvar_g_balance_sharpsrifle_cocking_time * 0.5);
					self.sharpsrifle_fulltime = time + autocvar_g_balance_sharpsrifle_cocking_time;
					self.sharpsrifle_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.sharpsrifle_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.sharpsrifle_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.sharpsrifle_jammed && self.sharpsrifle_unjam)
		  {
		  	if (time >= self.sharpsrifle_unjam_time) {
				self.sharpsrifle_jammed = 0;
				self.sharpsrifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_sharpsrifle.md3");
		precache_model ("models/weapons/v_sharpsrifle.md3");
		precache_model ("models/weapons/h_sharpsrifle.iqm");
		precache_model ("models/weapons/v_sharpsrifle-cocked.md3");
		precache_model ("models/weapons/h_sharpsrifle-cocked.iqm");
		precache_model ("models/weapons/v_sharpsrifle-half.md3");
		precache_model ("models/weapons/h_sharpsrifle-half.iqm");
		precache_model ("models/weapons/v_sharpsrifle-reload.md3");
		precache_model ("models/weapons/h_sharpsrifle-reload.iqm");
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
		//self.weaponaltaim = '55 0.05 -2.5';
		//self.weaponaltaim = '55 0.05 -3.5';
		self.weaponaltaim = '55 -0.15 -5.5';
		weapon_setup(WEP_SHARPSRIFLE);
		self.current_ammo = ammo_nails;
		
		self.sharpsrifle_reloaddo = 0;
		self.sharpsrifle_reloaddo_wait = 0;
		
		if not(self.sharpsrifle_notnew) {
			self.sharpsrifle_release = 1;
		
			self.weaponname = "sharpsrifle";
		} else {
			if (self.sharpsrifle_release == 1) {
				self.weaponname = "sharpsrifle";
			} else {
				self.weaponname = "sharpsrifle-cocked";
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_sharpsrifle_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SHARPSRIFLE]) >= autocvar_g_balance_sharpsrifle_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.sharpsrifle_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.sharpsrifle_jammed) {
			self.sharpsrifle_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_sharpsrifle_clearjam_time, w_ready);
			if (self.sharpsrifle_unjam != 1) {
				self.sharpsrifle_unjam = 1;
				self.sharpsrifle_unjam_time = time + autocvar_g_balance_sharpsrifle_clearjam_time;
				self.sharpsrifle_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the sharpsrifle\n");
				}
			}
		} else if not (self.sharpsrifle_reloadanimtime) {
			self.sharpsrifle_reloaddo = 1;
			self.sharpsrifle_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_sharpsrifle_reload_ammo && self.clip_load < autocvar_g_balance_sharpsrifle_primary_ammo) {
					self.weaponname = "sharpsrifle-reload";
				}
			self.sharpsrifle_reloadanimtime = time + frametime + autocvar_g_balance_sharpsrifle_reload_time;
		} else {
			self.sharpsrifle_reloaddo = 0;
			self.sharpsrifle_reloaddo_wait = 0;
			self.sharpsrifle_botreload = 1;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_sharpsrifle_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.sharpsrifle_reloadanimtime = time + frametime + (autocvar_g_balance_sharpsrifle_reload_time - (autocvar_g_balance_sharpsrifle_reload_time * (self.clip_load/autocvar_g_balance_sharpsrifle_reload_ammo)));
				W_Reload(autocvar_g_balance_sharpsrifle_primary_ammo, autocvar_g_balance_sharpsrifle_reload_ammo, autocvar_g_balance_sharpsrifle_reload_time - (autocvar_g_balance_sharpsrifle_reload_time * (self.clip_load/autocvar_g_balance_sharpsrifle_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.sharpsrifle_reloadanimtime = time + frametime + autocvar_g_balance_sharpsrifle_reload_time;
				W_Reload(autocvar_g_balance_sharpsrifle_primary_ammo, autocvar_g_balance_sharpsrifle_reload_ammo, autocvar_g_balance_sharpsrifle_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_sharpsrifle_casings) {
					for (sc = 0;sc < self.sharpsrifle_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 58, self, '0 0 -3');
					}
				}
				self.sharpsrifle_casings = 0;
			}
		}
		//self.sharpsrifle_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_sharpsrifle(float req)
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
			w_deathtypestring = _("%s was shot in the chest by %s's sharps rifle");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot in the skull by %s's sharps rifle");
		else
			w_deathtypestring = _("%s was shot to death by %s's sharps rifle");
	}
	return TRUE;
}
#endif
#endif
