#ifdef REGISTER_WEAPON
REGISTER_WEAPON(R1856REVOLVER, w_r1856revolver, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "r1856revolver", "r1856revolver", _("Remington 1856"))
#else
#ifdef SVQC

.float r1856revolver_release;
.float r1856revolver_casings;
.float r1856revolver_jammed;
.float r1856revolver_unjam;
.float r1856revolver_unjam_time;
.float r1856revolver_click;
.float r1856revolver_halftime;
.float r1856revolver_fulltime;
.float r1856revolver_state;

void W_R1856Revolver_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_r1856revolver_primary_ammo;
	d = autocvar_g_balance_r1856revolver_primary_damage;
	f = autocvar_g_balance_r1856revolver_primary_force;
	spread = autocvar_g_balance_r1856revolver_primary_spread;
	bulletspeed = autocvar_g_balance_r1856revolver_primary_speed;
	bulletconstant = autocvar_g_balance_r1856revolver_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_r1856revolver_reload_ammo);
	self.r1856revolver_casings = self.r1856revolver_casings + 1;
	
	if (autocvar_g_balance_r1856revolver_jamrate &&
 	(autocvar_g_balance_r1856revolver_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your r1856revolver jammed\n");
		}
		self.r1856revolver_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_r1856revolver_primary_headshotaddeddamage, f, WEP_R1856REVOLVER, PROJECTILE_MINIEBALL, 1, bulletconstant, autocvar_g_balance_r1856revolver_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_r1856revolver_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 5);
	}
	
	PlayerGunRise(self, autocvar_g_balance_r1856revolver_gunrise, random() * autocvar_g_balance_r1856revolver_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '12 0 0');
	
	} //End Not Jammed
}

void W_R1856Revolver_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_r1856revolver_secondary_animtime, w_ready);
}

float W_R1856Revolver_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_r1856revolver_reload_ammo && self.clip_load < autocvar_g_balance_r1856revolver_primary_ammo))
	{
		if (!self.r1856revolver_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.r1856revolver_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.r1856revolver_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_r1856revolver (void)
{
	weapon_defaultspawnfunc(WEP_R1856REVOLVER);
}


.float r1856revolver_primarytime;

float w_r1856revolver(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_R1856Revolver_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.r1856revolver_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.r1856revolver_release) {
			self.BUTTON_ATCK2 = TRUE; //Pump
		} else {
			if((bot_aim(autocvar_g_balance_r1856revolver_primary_speed, 0, 5, FALSE)) && (self.r1856revolver_release != 1))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_R1856Revolver_NeedManualReload())
	{
		if(autocvar_g_balance_r1856revolver_reload_ammo && self.clip_load < autocvar_g_balance_r1856revolver_primary_ammo) // forced reload
		{
			// don't force reload an empty r1856revolver if its melee attack is active
			if not(autocvar_g_balance_r1856revolver_secondary && self.ammo_nails < autocvar_g_balance_r1856revolver_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.r1856revolver_release = 0;
		}
		else
		{
		  if (self.r1856revolver_jammed && self.r1856revolver_unjam)
		  {
		  	if (time >= self.r1856revolver_unjam_time) {
				self.r1856revolver_jammed = 0;
				self.r1856revolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.r1856revolver_state == 2) {
		  		if (time > self.r1856revolver_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_R1856Revolver_Attack2);
					self.r1856revolver_state = 1;
					self.weaponname = "r1856revolver-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					PlayerGunRise(self, autocvar_g_balance_r1856revolver_cockingrise, random() * autocvar_g_balance_r1856revolver_cockingrun);
				}
			} else if (self.r1856revolver_state == 1) {
				if (time > self.r1856revolver_fulltime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_R1856Revolver_Attack2);
					self.r1856revolver_state = 0;
					self.r1856revolver_release = 0; //We finish pulling back the hammer
					self.weaponname = "r1856revolver-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			}
			else 
			{
				////NORMAL
				if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.r1856revolver_release != 1) &&
				(self.r1856revolver_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_r1856revolver_primary_refire))
				)
				{
						W_R1856Revolver_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_r1856revolver_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_r1856revolver_primary_animtime, w_ready);
						self.r1856revolver_release = 1; //Slide needs to be wracked
						self.weaponname = "r1856revolver";
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.r1856revolver_release == 1) &&
				(self.r1856revolver_jammed != 1) &&
				(weapon_prepareattack(1, autocvar_g_balance_r1856revolver_secondary_refire))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_R1856Revolver_Attack2);
					self.r1856revolver_halftime = time + (autocvar_g_balance_r1856revolver_cocking_time * 0.5);
					self.r1856revolver_fulltime = time + autocvar_g_balance_r1856revolver_cocking_time;
					self.r1856revolver_state = 2;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.r1856revolver_jammed && self.r1856revolver_unjam)
		  {
		  	if (time >= self.r1856revolver_unjam_time) {
				self.r1856revolver_jammed = 0;
				self.r1856revolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_r1856revolver.md3");
		precache_model ("models/weapons/v_r1856revolver.md3");
		precache_model ("models/weapons/h_r1856revolver.iqm");
		precache_model ("models/weapons/v_r1856revolver-cocked.md3");
		precache_model ("models/weapons/h_r1856revolver-cocked.iqm");
		precache_model ("models/weapons/v_r1856revolver-half.md3");
		precache_model ("models/weapons/h_r1856revolver-half.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -2.25';
		//self.weaponaltaim = '40 -0.35 -1.75';
		self.weaponaltaim = '40 -0.35 -2.50';
		weapon_setup(WEP_R1856REVOLVER);
		self.current_ammo = ammo_nails;
		
		if (self.r1856revolver_release == 1) {
			self.weaponname = "r1856revolver";
		} else {
			self.weaponname = "r1856revolver-cocked";
		}
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_r1856revolver_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_R1856REVOLVER]) >= autocvar_g_balance_r1856revolver_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.r1856revolver_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.r1856revolver_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_r1856revolver_clearjam_time, w_ready);
			if (self.r1856revolver_unjam != 1) {
				self.r1856revolver_unjam = 1;
				self.r1856revolver_unjam_time = time + autocvar_g_balance_r1856revolver_clearjam_time;
				self.r1856revolver_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the r1856revolver\n");
				}
			}
		} else {
			float myr1856reloadtime;
			
			if (!autocvar_g_balance_r1856revolver_extracylindernotincluded
			|| self.inv_misc_cylinder_r1856)
			{
				myr1856reloadtime = autocvar_g_balance_r1856revolver_quickreload_time;
			
				if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_r1856revolver_reload_ammo)) {
					if (myr1856reloadtime > (autocvar_g_balance_r1856revolver_reload_time - (autocvar_g_balance_r1856revolver_reload_time * (self.clip_load/autocvar_g_balance_r1856revolver_reload_ammo)))) {
						myr1856reloadtime = autocvar_g_balance_r1856revolver_reload_time; //Faster in this case
					}
				}
			} else {
				myr1856reloadtime = autocvar_g_balance_r1856revolver_reload_time;
			}
			
			  
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_r1856revolver_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_r1856revolver_primary_ammo, autocvar_g_balance_r1856revolver_reload_ammo, myr1856reloadtime - (myr1856reloadtime * (self.clip_load/autocvar_g_balance_r1856revolver_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_r1856revolver_primary_ammo, autocvar_g_balance_r1856revolver_reload_ammo, myr1856reloadtime, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				for (sc = 0;sc < self.r1856revolver_casings;sc = sc + 1) {
					SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self, '0 0 -3');
				}
				self.r1856revolver_casings = 0;
			}
		}
		//self.r1856revolver_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_r1856revolver(float req)
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
			w_deathtypestring = _("%1$s failed to breathe when %2$s put a quick lead ball into their chest");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s stopped thinking when %2$s placed a lead ball in their skull");
		else
			w_deathtypestring = _("%s was gifted some lead balls from %s's old 1856 remington revolver");
	}
	return TRUE;
}
#endif
#endif
