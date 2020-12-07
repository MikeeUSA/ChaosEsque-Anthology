#ifdef REGISTER_WEAPON
REGISTER_WEAPON(COLT44REVOLVER, w_colt44revolver, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "colt44revolver", "colt44revolver", _("Colt 44"))
#else
#ifdef SVQC

.float colt44revolver_release;
.float colt44revolver_casings;
.float colt44revolver_jammed;
.float colt44revolver_unjam;
.float colt44revolver_unjam_time;
.float colt44revolver_click;
.float colt44revolver_halftime;
.float colt44revolver_fulltime;
.float colt44revolver_state;

void W_Colt44Revolver_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_colt44revolver_primary_ammo;
	d = autocvar_g_balance_colt44revolver_primary_damage;
	f = autocvar_g_balance_colt44revolver_primary_force;
	spread = autocvar_g_balance_colt44revolver_primary_spread;
	bulletspeed = autocvar_g_balance_colt44revolver_primary_speed;
	bulletconstant = autocvar_g_balance_colt44revolver_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_colt44revolver_reload_ammo);
	self.colt44revolver_casings = self.colt44revolver_casings + 1;
	
	if (autocvar_g_balance_colt44revolver_jamrate &&
 	(autocvar_g_balance_colt44revolver_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your colt44revolver jammed\n");
		}
		self.colt44revolver_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_colt44revolver_primary_headshotaddeddamage, f, WEP_COLT44REVOLVER, PROJECTILE_MINIEBALL, 1, bulletconstant, autocvar_g_balance_colt44revolver_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_colt44revolver_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
	pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 2);
	}
	
	PlayerGunRise(self, autocvar_g_balance_colt44revolver_gunrise, random() * autocvar_g_balance_colt44revolver_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	
	} //End Not Jammed
}

void W_Colt44Revolver_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_colt44revolver_secondary_animtime, w_ready);
}

float W_Colt44Revolver_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_colt44revolver_reload_ammo && self.clip_load < autocvar_g_balance_colt44revolver_primary_ammo))
	{
		if (!self.colt44revolver_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.colt44revolver_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.colt44revolver_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_colt44revolver (void)
{
	weapon_defaultspawnfunc(WEP_COLT44REVOLVER);
}


.float colt44revolver_primarytime;

float w_colt44revolver(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Colt44Revolver_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.colt44revolver_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.colt44revolver_release) {
			self.BUTTON_ATCK2 = TRUE; //Pump
		} else {
			if((bot_aim(autocvar_g_balance_colt44revolver_primary_speed, 0, 5, FALSE)) && (self.colt44revolver_release != 1))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_Colt44Revolver_NeedManualReload())
	{
		if(autocvar_g_balance_colt44revolver_reload_ammo && self.clip_load < autocvar_g_balance_colt44revolver_primary_ammo) // forced reload
		{
			// don't force reload an empty colt44revolver if its melee attack is active
			if not(autocvar_g_balance_colt44revolver_secondary && self.ammo_nails < autocvar_g_balance_colt44revolver_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.colt44revolver_release = 0;
		}
		else
		{
		  if (self.colt44revolver_jammed && self.colt44revolver_unjam)
		  {
		  	if (time >= self.colt44revolver_unjam_time) {
				self.colt44revolver_jammed = 0;
				self.colt44revolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.colt44revolver_state == 2) {
		  		if (time > self.colt44revolver_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Colt44Revolver_Attack2);
					self.colt44revolver_state = 1;
					self.weaponname = "colt44revolver-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					PlayerGunRise(self, autocvar_g_balance_colt44revolver_cockingrise, random() * autocvar_g_balance_colt44revolver_cockingrun);
				}
			} else if (self.colt44revolver_state == 1) {
				if (time > self.colt44revolver_fulltime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Colt44Revolver_Attack2);
					self.colt44revolver_state = 0;
					self.colt44revolver_release = 0; //We finish pulling back the hammer
					self.weaponname = "colt44revolver-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			}
			else 
			{
				////NORMAL
				if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.colt44revolver_release != 1) &&
				(self.colt44revolver_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_colt44revolver_primary_refire))
				)
				{
						W_Colt44Revolver_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_colt44revolver_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_colt44revolver_primary_animtime, w_ready);
						self.colt44revolver_release = 1; //Slide needs to be wracked
						self.weaponname = "colt44revolver";
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.colt44revolver_release == 1) &&
				(self.colt44revolver_jammed != 1) &&
				(weapon_prepareattack(1, autocvar_g_balance_colt44revolver_secondary_refire))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Colt44Revolver_Attack2);
					self.colt44revolver_halftime = time + (autocvar_g_balance_colt44revolver_cocking_time * 0.5);
					self.colt44revolver_fulltime = time + autocvar_g_balance_colt44revolver_cocking_time;
					self.colt44revolver_state = 2;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_colt44revolver.md3");
		precache_model ("models/weapons/v_colt44revolver.md3");
		precache_model ("models/weapons/h_colt44revolver.iqm");
		precache_model ("models/weapons/v_colt44revolver-cocked.md3");
		precache_model ("models/weapons/h_colt44revolver-cocked.iqm");
		precache_model ("models/weapons/v_colt44revolver-half.md3");
		precache_model ("models/weapons/h_colt44revolver-half.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_THINK)
	{
		  if (self.colt44revolver_jammed && self.colt44revolver_unjam)
		  {
		  	if (time >= self.colt44revolver_unjam_time) {
				self.colt44revolver_jammed = 0;
				self.colt44revolver_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -2.25';
		//self.weaponaltaim = '40 -0.35 -1.75';
		weapon_setup(WEP_COLT44REVOLVER);
		self.current_ammo = ammo_nails;
		
		if (self.colt44revolver_release == 1) {
			self.weaponname = "colt44revolver";
		} else {
			self.weaponname = "colt44revolver-cocked";
		}
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_colt44revolver_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_COLT44REVOLVER]) >= autocvar_g_balance_colt44revolver_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.colt44revolver_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.colt44revolver_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_colt44revolver_clearjam_time, w_ready);
			if (self.colt44revolver_unjam != 1) {
				self.colt44revolver_unjam = 1;
				self.colt44revolver_unjam_time = time + autocvar_g_balance_colt44revolver_clearjam_time;
				self.colt44revolver_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the colt44revolver\n");
				}
			}
		} else {
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_colt44revolver_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_colt44revolver_primary_ammo, autocvar_g_balance_colt44revolver_reload_ammo, autocvar_g_balance_colt44revolver_reload_time - (autocvar_g_balance_colt44revolver_reload_time * (self.clip_load/autocvar_g_balance_colt44revolver_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_colt44revolver_primary_ammo, autocvar_g_balance_colt44revolver_reload_ammo, autocvar_g_balance_colt44revolver_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				for (sc = 0;sc < self.colt44revolver_casings;sc = sc + 1) {
					SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self, '0 0 -3');
				}
				self.colt44revolver_casings = 0;
			}
		}
		//self.colt44revolver_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_colt44revolver(float req)
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
			w_deathtypestring = _("%1$s failed to breathe when %2$s gave them peace");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s mind is now at peace thanks to %2$s peacemaker");
		else
			w_deathtypestring = _("%s was gifted some lead from %s's peacemaker");
	}
	return TRUE;
}
#endif
#endif
