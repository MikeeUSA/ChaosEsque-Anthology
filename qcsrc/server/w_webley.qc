#ifdef REGISTER_WEAPON
REGISTER_WEAPON(WEBLEY, w_webley, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "webley", "webley", _("Webley"))
#else
#ifdef SVQC

.float webley_release;
.float webley_casings;
.float webley_jammed;
.float webley_unjam;
.float webley_unjam_time;
.float webley_click;
.float webley_halftime;
.float webley_fulltime;
.float webley_state;
.float webley_doubleaction;
.float webley_ontrigger;

void W_Webley_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_webley_primary_ammo;
	d = autocvar_g_balance_webley_primary_damage;
	f = autocvar_g_balance_webley_primary_force;
	spread = autocvar_g_balance_webley_primary_spread;
	bulletspeed = autocvar_g_balance_webley_primary_speed;
	bulletconstant = autocvar_g_balance_webley_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_webley_reload_ammo);
	self.webley_casings = self.webley_casings + 1;
	
	if (autocvar_g_balance_webley_jamrate &&
 	(autocvar_g_balance_webley_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your webley jammed\n");
		}
		self.webley_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_webley_primary_headshotaddeddamage, f, WEP_WEBLEY, PROJECTILE_BULLETWEBLEY, 1, bulletconstant, autocvar_g_balance_webley_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_webley_primary_ammo);
	
	PlayerGunRise(self, autocvar_g_balance_webley_gunrise, random() * autocvar_g_balance_webley_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '2 0 0');
	
	} //End Not Jammed
}

void W_Webley_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_webley_secondary_animtime, w_ready);
}

float W_Webley_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_webley_reload_ammo && self.clip_load < autocvar_g_balance_webley_primary_ammo))
	{
		if (!self.webley_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.webley_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.webley_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_webley (void)
{
	weapon_defaultspawnfunc(WEP_WEBLEY);
}


.float webley_primarytime;

float w_webley(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Webley_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.webley_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.webley_doubleaction) {
			self.BUTTON_ATCK = TRUE; //In the middle of double action attack, keep the trigger pressed
		} else {
			if((bot_aim(autocvar_g_balance_webley_primary_speed, 0, 5, FALSE)) && (!self.webley_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
				
			if ((!self.BUTTON_ATCK)
			&& (!self.webley_state)
			&& (!self.webley_ontrigger)
			&& (self.webley_release == 1)
			&& (random() > 0.95)) {
				self.BUTTON_ATCK2 = TRUE; //Pump/Pull hammer back
			}
		}
	}
	else if (req == WR_THINK && !W_Webley_NeedManualReload())
	{
		if(autocvar_g_balance_webley_reload_ammo && self.clip_load < autocvar_g_balance_webley_primary_ammo) // forced reload
		{
			// don't force reload an empty webley if its melee attack is active
			if not(autocvar_g_balance_webley_secondary && self.ammo_nails < autocvar_g_balance_webley_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.webley_release = 0;
		}
		else
		{
		  if (self.webley_jammed && self.webley_unjam)
		  {
		  	if (time >= self.webley_unjam_time) {
				self.webley_jammed = 0;
				self.webley_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.webley_state == 2) {
		  		if (time > self.webley_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Webley_Attack2);
					self.webley_state = 1;
					self.weaponname = "webley-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					if (self.webley_doubleaction == 1) {
						//print("DoubleAction\n");
						PlayerGunRise(self, autocvar_g_balance_webley_darise, random() * autocvar_g_balance_webley_darun);
					} else {
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_webley_cockingrise, random() * autocvar_g_balance_webley_cockingrun);
					}
				}
			} else if (self.webley_state == 1) {
				if (time > self.webley_fulltime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Webley_Attack2);
					self.webley_state = 0;
					self.webley_release = 0; //We finish pulling back the hammer
					self.weaponname = "webley-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			}
			else 
			{
				////NORMAL
				if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.webley_ontrigger != 1) &&
				(self.webley_release != 1) &&
				(self.webley_jammed != 1) &&
				(self.webley_doubleaction != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_webley_primary_refire))
				)
				{
						self.webley_ontrigger = 1;
						W_Webley_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_webley_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_webley_primary_animtime, w_ready);
						self.webley_release = 1; //Slide needs to be wracked
						self.weaponname = "webley";
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.webley_ontrigger != 1) &&
				(self.webley_release == 1) &&
				(self.webley_jammed != 1) &&
				(self.webley_doubleaction != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_webley_primary_refire))
				)
				{
					self.webley_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Webley_Attack2);
					self.webley_halftime = time + (autocvar_g_balance_webley_cocking_time * 0.5);
					self.webley_fulltime = time + autocvar_g_balance_webley_cocking_time;
					self.webley_state = 2;
					self.webley_doubleaction = 1;
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.webley_ontrigger == 1) &&
				(self.webley_release != 1) &&
				(self.webley_jammed != 1) &&
				(self.webley_doubleaction == 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_webley_primary_refire))
				)
				{
					//Double Action fire
						self.webley_ontrigger = 1;
						W_Webley_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_webley_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_webley_primary_animtime, w_ready);
						self.webley_release = 1; //Slide needs to be wracked
						self.weaponname = "webley";
						self.webley_doubleaction = 0;
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.webley_ontrigger != 1) &&
				(self.webley_release == 1) &&
				(self.webley_jammed != 1) &&
				(self.webley_doubleaction != 1) &&
				(weapon_prepareattack(1, autocvar_g_balance_webley_secondary_refire))
				)
				{
					self.webley_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Webley_Attack2);
					self.webley_halftime = time + (autocvar_g_balance_webley_cocking_time * 0.5);
					self.webley_fulltime = time + autocvar_g_balance_webley_cocking_time;
					self.webley_state = 2;
				}
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.webley_ontrigger = 0;
					self.webley_doubleaction = 0; //Not squeezing trigger
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.webley_jammed && self.webley_unjam)
		  {
		  	if (time >= self.webley_unjam_time) {
				self.webley_jammed = 0;
				self.webley_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_webley.md3");
		precache_model ("models/weapons/v_webley.md3");
		precache_model ("models/weapons/h_webley.iqm");
		precache_model ("models/weapons/v_webley-cocked.md3");
		precache_model ("models/weapons/h_webley-cocked.iqm");
		precache_model ("models/weapons/v_webley-half.md3");
		precache_model ("models/weapons/h_webley-half.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -1';
		weapon_setup(WEP_WEBLEY);
		self.current_ammo = ammo_nails;
		
		if (self.webley_release == 1) {
			self.weaponname = "webley";
		} else {
			self.weaponname = "webley-cocked";
		}
		self.webley_doubleaction = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_webley_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_WEBLEY]) >= autocvar_g_balance_webley_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.webley_casings = 0;
		self.webley_doubleaction = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.webley_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_webley_clearjam_time, w_ready);
			if (self.webley_unjam != 1) {
				self.webley_unjam = 1;
				self.webley_unjam_time = time + autocvar_g_balance_webley_clearjam_time;
				self.webley_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the webley\n");
				}
			}
		} else {
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_webley_reload_ammo)) {
				local float myminreloadtime;
				if (autocvar_g_balance_webley_reload_time_min < autocvar_g_balance_webley_reload_time) {
					myminreloadtime = autocvar_g_balance_webley_reload_time_min;
				} else {
					myminreloadtime = 0;
				}
				//Breaktop cylinder not empty Less than full reload time needed
				//But there is a min reload time
				W_Reload(autocvar_g_balance_webley_primary_ammo, autocvar_g_balance_webley_reload_ammo, autocvar_g_balance_webley_reload_time - ((autocvar_g_balance_webley_reload_time - myminreloadtime) * (self.clip_load/autocvar_g_balance_webley_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_webley_primary_ammo, autocvar_g_balance_webley_reload_ammo, autocvar_g_balance_webley_reload_time, "weapons/reload.wav");
			}
						
			if (autocvar_g_casings >= 2) {
				float sc;
				for (sc = 0;sc < self.webley_casings;sc = sc + 1) {
					SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);
				}
				self.webley_casings = 0;
			}
		}
		//self.webley_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_webley(float req)
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
			w_deathtypestring = _("%1$s found a lead shot in their chest, courtesy of %2$s webley revolver");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was executed in the British tradition by %s");
		else
			w_deathtypestring = _("The sun set on %s. To %s go the victories.");
	}
	return TRUE;
}
#endif
#endif
