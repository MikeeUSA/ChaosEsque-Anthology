#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TARGETPISTOL, w_targetpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "targetpistol", "targetpistol", _("Target Pistol"))
#else
#ifdef SVQC

.float targetpistol_release;
.float targetpistol_casings;
.float targetpistol_jammed;
.float targetpistol_unjam;
.float targetpistol_unjam_time;
.float targetpistol_click;
.float targetpistol_halftime;
.float targetpistol_fulltime;
.float targetpistol_state;
.float targetpistol_ontrigger;
.float targetpistol_firedelay;
.float targetpistol_firenow;
.float targetpistol_botreload;
.float targetpistol_notnew;
.float targetpistol_reloadanimtime;
.float targetpistol_reloaddo;
.float targetpistol_reloaddo_wait;

float targetpistolautoskincolorset;
.float targetpistol_customskin;

void W_TargetPistol_Attack (void)
{
	float sc;
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bullets;
	float	bulletspeed;
	float	bulletconstant;
	float	pHeadshotAddedDamage;
	float   pLifetime;
	entity flash;

	ammoamount = autocvar_g_balance_targetpistol_primary_ammo;
	bullets = autocvar_g_balance_targetpistol_primary_bullets;
	d = autocvar_g_balance_targetpistol_primary_damage;
	f = autocvar_g_balance_targetpistol_primary_force;
	pHeadshotAddedDamage = autocvar_g_balance_targetpistol_primary_headshotaddeddamage;
	pLifetime = autocvar_g_balance_m1903_primary_lifetime;
	spread = autocvar_g_balance_targetpistol_primary_spread;
	bulletspeed = autocvar_g_balance_targetpistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_30calrifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_targetpistol_reload_ammo);
	self.targetpistol_casings = self.targetpistol_casings + 1;
	
	if (autocvar_g_balance_targetpistol_jamrate &&
 	(autocvar_g_balance_targetpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your target pistol failed to fire\n");
		}
		self.targetpistol_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 2, "weapons/campingrifle_fire2.wav", CH_WEAPON_A, d);


		if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
		{
			w_shotdir = v_forward;
			w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
		} else {
			W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
		}
		
		
		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, pLifetime, d, pHeadshotAddedDamage / d, f, WEP_TARGETPISTOL, PROJECTILE_BULLETRIFLE9MM_G, 1, bulletconstant, autocvar_g_balance_targetpistol_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 2), w_shotdir * 1000, autocvar_g_balance_targetpistol_primary_ammo);
	
	//local float mytestpointcontents;
	//mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 2));
	//if (mytestpointcontents == CONTENT_WATER
	//|| mytestpointcontents == CONTENT_SLIME
	//|| mytestpointcontents == CONTENT_LAVA)
	//{
	//	//Do nothing
	//} else {
	//	pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 2), w_shotdir * 2, 25);
	//}
	
	PlayerGunRise(self, autocvar_g_balance_targetpistol_gunrise, random() * autocvar_g_balance_targetpistol_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '16 0 0');
	
	} //End Not Jammed
}

void W_TargetPistol_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_targetpistol_secondary_animtime, w_ready);
}

float W_TargetPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_targetpistol_reload_ammo && self.clip_load < autocvar_g_balance_targetpistol_primary_ammo))
	{
		if (!self.targetpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.targetpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.targetpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_targetpistol (void)
{
	weapon_defaultspawnfunc(WEP_TARGETPISTOL);
}


float w_targetpistol_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.targetpistol_customskin > 0)) {
		return player.targetpistol_customskin;
	} else if (autocvar_g_balance_targetpistol_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(targetpistolautoskincolorset) {
			targetpistolautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (targetpistolautoskincolorset == -10) {
			return 0;
		//} else if (targetpistolautoskincolorset == 1) {
		//	//Dust
		//	return 2;
		} else if (targetpistolautoskincolorset == 4) {
			//Snow gets black for now
			return 1;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_targetpistol_skin;
	}
}




.float targetpistol_primarytime;

float w_targetpistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_TargetPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.targetpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_targetpistol_primary_speed, 0, 5, FALSE)) && (!self.targetpistol_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && self.targetpistol_reloaddo)
	{
		//print("here\n");
		if (time > self.targetpistol_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_TargetPistol_NeedManualReload())
	{
		self.targetpistol_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.targetpistol_reloadanimtime && self.targetpistol_reloadanimtime > time) {
		  	if (!self.targetpistol_reloaddo_wait) {
				self.targetpistol_reloadanimtime = 0;
				
				if (self.targetpistol_release == 1) {
					self.weaponname = "targetpistol";
				} else {
					self.weaponname = "targetpistol-cocked";
				}
			}
		}
		
		
		if(autocvar_g_balance_targetpistol_reload_ammo && self.clip_load < autocvar_g_balance_targetpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty targetpistol if its melee attack is active
			if not(autocvar_g_balance_targetpistol_secondary && self.ammo_nails < autocvar_g_balance_targetpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.targetpistol_release = 0;
		}
		else
		{
		  if (self.targetpistol_jammed && self.targetpistol_unjam)
		  {
		  	if (time >= self.targetpistol_unjam_time) {
				self.targetpistol_jammed = 0;
				self.targetpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.targetpistol_state == 3) {
		  		if (time > self.targetpistol_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_TargetPistol_Attack2);
					self.targetpistol_state = 2;
					self.weaponname = "targetpistol-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_targetpistol_cockingrise, random() * autocvar_g_balance_targetpistol_cockingrun);
				}
			} else if (self.targetpistol_state == 2) {
				if (time > self.targetpistol_fulltime) {
					self.targetpistol_state = 400;
					self.targetpistol_release = 0; //We finish pulling back the hammer
					self.weaponname = "targetpistol-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.targetpistol_state == 1) {
				if (time > self.targetpistol_firedelay) {
					self.targetpistol_state = 0;

					self.targetpistol_firedelay = 0;
					self.weaponname = "targetpistol";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.targetpistol_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.targetpistol_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_targetpistol_primary_refire))
				)
				{
						self.targetpistol_ontrigger = 1;
						
						
						W_TargetPistol_Attack();
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_targetpistol_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_targetpistol_primary_animtime, w_ready);
						self.targetpistol_release = 1; //Slide needs to be wracked
						self.weaponname = "targetpistol";
						self.targetpistol_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.targetpistol_ontrigger != 1) &&
				(self.targetpistol_release != 1) &&
				(self.targetpistol_jammed != 1) &&
				(self.targetpistol_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_targetpistol_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.weaponname = "targetpistol";

						self.targetpistol_firedelay = time + autocvar_g_balance_targetpistol_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_TargetPistol_Attack2);
						self.targetpistol_state = 1;
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.targetpistol_ontrigger != 1) &&
				(self.targetpistol_release == 1) &&
				(self.targetpistol_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_targetpistol_secondary_refire))
				)
				{
					self.targetpistol_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_TargetPistol_Attack2);
					self.targetpistol_halftime = time + (autocvar_g_balance_targetpistol_cocking_time * 0.5);
					self.targetpistol_fulltime = time + autocvar_g_balance_targetpistol_cocking_time;
					self.targetpistol_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.targetpistol_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.targetpistol_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.targetpistol_jammed && self.targetpistol_unjam)
		  {
		  	if (time >= self.targetpistol_unjam_time) {
				self.targetpistol_jammed = 0;
				self.targetpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_targetpistol.md3");
		precache_model ("models/weapons/v_targetpistol.md3");
		precache_model ("models/weapons/h_targetpistol.iqm");
		precache_model ("models/weapons/v_targetpistol-cocked.md3");
		precache_model ("models/weapons/h_targetpistol-cocked.iqm");
		precache_model ("models/weapons/v_targetpistol-half.md3");
		precache_model ("models/weapons/h_targetpistol-half.iqm");
		precache_model ("models/weapons/v_targetpistol-reload.md3");
		precache_model ("models/weapons/h_targetpistol-reload.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire2.wav");
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
		//self.weaponaltaim = '58 -0.15 -2.7';
		//self.weaponaltaim = '40 -0.35 -0.9';
		//self.weaponaltaim = '34 -0.35 -0.9';
		self.weaponaltaim = '36 -0.35 -0.9';
		weapon_setup(WEP_TARGETPISTOL);
		self.current_ammo = ammo_nails;
		
		self.targetpistol_reloaddo = 0;
		self.targetpistol_reloaddo_wait = 0;
		
		if not(self.targetpistol_notnew) {
			self.targetpistol_release = 1;
		
			self.weaponname = "targetpistol";
		} else {
			if (self.targetpistol_release == 1) {
				self.weaponname = "targetpistol";
			} else {
				self.weaponname = "targetpistol-cocked";
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_targetpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TARGETPISTOL]) >= autocvar_g_balance_targetpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.targetpistol_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.targetpistol_jammed) {
			self.targetpistol_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_targetpistol_clearjam_time, w_ready);
			if (self.targetpistol_unjam != 1) {
				self.targetpistol_unjam = 1;
				self.targetpistol_unjam_time = time + autocvar_g_balance_targetpistol_clearjam_time;
				self.targetpistol_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the targetpistol\n");
				}
			}
		} else if not (self.targetpistol_reloadanimtime) {
			self.targetpistol_reloaddo = 1;
			self.targetpistol_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_targetpistol_reload_ammo && self.clip_load < autocvar_g_balance_targetpistol_primary_ammo) {
					self.weaponname = "targetpistol-reload";
				}
			self.targetpistol_reloadanimtime = time + frametime + autocvar_g_balance_targetpistol_reload_time;
		} else {
			self.targetpistol_reloaddo = 0;
			self.targetpistol_reloaddo_wait = 0;
			self.targetpistol_botreload = 1;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_targetpistol_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.targetpistol_reloadanimtime = time + frametime + (autocvar_g_balance_targetpistol_reload_time - (autocvar_g_balance_targetpistol_reload_time * (self.clip_load/autocvar_g_balance_targetpistol_reload_ammo)));
				W_Reload(autocvar_g_balance_targetpistol_primary_ammo, autocvar_g_balance_targetpistol_reload_ammo, autocvar_g_balance_targetpistol_reload_time - (autocvar_g_balance_targetpistol_reload_time * (self.clip_load/autocvar_g_balance_targetpistol_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.targetpistol_reloadanimtime = time + frametime + autocvar_g_balance_targetpistol_reload_time;
				W_Reload(autocvar_g_balance_targetpistol_primary_ammo, autocvar_g_balance_targetpistol_reload_ammo, autocvar_g_balance_targetpistol_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_targetpistol_casings) {
					for (sc = 0;sc < self.targetpistol_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 99, self, '0 0 -3');
					}
				}
				self.targetpistol_casings = 0;
			}
		}
		//self.targetpistol_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_targetpistol(float req)
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
		if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s got shot in the head with a target pistol by %s");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%1$s found it difficult to breate due to rifle round %2$s put through their chest");
		else
			w_deathtypestring = _("%s was gunned down with a target pistol by %s");
	}
	return TRUE;
}
#endif
#endif
