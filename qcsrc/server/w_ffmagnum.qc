#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FFMAGNUM, w_ffmagnum, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "44magnum", "ffmagnum", _("44 Magnum"))
#else
#ifdef SVQC

.float ffmagnum_release;
.float ffmagnum_casings;
.float ffmagnum_jammed;
.float ffmagnum_unjam;
.float ffmagnum_unjam_time;
.float ffmagnum_click;
.float ffmagnum_halftime;
.float ffmagnum_fulltime;
.float ffmagnum_state;
.float ffmagnum_doubleaction;
.float ffmagnum_ontrigger;

void W_FFMagnum_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_ffmagnum_primary_ammo;
	d = autocvar_g_balance_ffmagnum_primary_damage;
	f = autocvar_g_balance_ffmagnum_primary_force;
	spread = autocvar_g_balance_ffmagnum_primary_spread;
	bulletspeed = autocvar_g_balance_ffmagnum_primary_speed;
	bulletconstant = autocvar_g_balance_ffmagnum_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_ffmagnum_reload_ammo);
	self.ffmagnum_casings = self.ffmagnum_casings + 1;
	
	if (autocvar_g_balance_ffmagnum_jamrate &&
 	(autocvar_g_balance_ffmagnum_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your .44 magnum jammed\n");
		}
		self.ffmagnum_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire3_bass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_ffmagnum_primary_headshotaddeddamage, f, WEP_FFMAGNUM, PROJECTILE_BULLET44MAG, 1, bulletconstant, autocvar_g_balance_ffmagnum_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_ffmagnum_primary_ammo);
	
	PlayerGunRise(self, autocvar_g_balance_ffmagnum_gunrise, random() * autocvar_g_balance_ffmagnum_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '6 0 0');
	
	} //End Not Jammed
}

void W_FFMagnum_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_ffmagnum_secondary_animtime, w_ready);
}

float W_FFMagnum_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_ffmagnum_reload_ammo && self.clip_load < autocvar_g_balance_ffmagnum_primary_ammo))
	{
		if (!self.ffmagnum_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.ffmagnum_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.ffmagnum_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_ffmagnum (void)
{
	weapon_defaultspawnfunc(WEP_FFMAGNUM);
}


.float ffmagnum_primarytime;

float w_ffmagnum(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_FFMagnum_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.ffmagnum_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.ffmagnum_doubleaction) {
			self.BUTTON_ATCK = TRUE; //In the middle of double action attack, keep the trigger pressed
		} else {
			if((bot_aim(autocvar_g_balance_ffmagnum_primary_speed, 0, 5, FALSE)) && (!self.ffmagnum_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
				
			if ((!self.BUTTON_ATCK)
			&& (!self.ffmagnum_state)
			&& (!self.ffmagnum_ontrigger)
			&& (self.ffmagnum_release == 1)
			&& (random() > 0.95)) {
				self.BUTTON_ATCK2 = TRUE; //Pump/Pull hammer back
			}
		}
	}
	else if (req == WR_THINK && !W_FFMagnum_NeedManualReload())
	{
		if(autocvar_g_balance_ffmagnum_reload_ammo && self.clip_load < autocvar_g_balance_ffmagnum_primary_ammo) // forced reload
		{
			// don't force reload an empty ffmagnum if its melee attack is active
			if not(autocvar_g_balance_ffmagnum_secondary && self.ammo_nails < autocvar_g_balance_ffmagnum_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.ffmagnum_release = 0;
		}
		else
		{
		  if (self.ffmagnum_jammed && self.ffmagnum_unjam)
		  {
		  	if (time >= self.ffmagnum_unjam_time) {
				self.ffmagnum_jammed = 0;
				self.ffmagnum_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.ffmagnum_state == 2) {
		  		if (time > self.ffmagnum_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_FFMagnum_Attack2);
					self.ffmagnum_state = 1;
					self.weaponname = "44magnum-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					if (self.ffmagnum_doubleaction == 1) {
						//print("DoubleAction\n");
						PlayerGunRise(self, autocvar_g_balance_ffmagnum_darise, random() * autocvar_g_balance_ffmagnum_darun);
					} else {
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_ffmagnum_cockingrise, random() * autocvar_g_balance_ffmagnum_cockingrun);
					}
				}
			} else if (self.ffmagnum_state == 1) {
				if (time > self.ffmagnum_fulltime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_FFMagnum_Attack2);
					self.ffmagnum_state = 0;
					self.ffmagnum_release = 0; //We finish pulling back the hammer
					self.weaponname = "44magnum-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			}
			else 
			{
				////NORMAL
				if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.ffmagnum_ontrigger != 1) &&
				(self.ffmagnum_release != 1) &&
				(self.ffmagnum_jammed != 1) &&
				(self.ffmagnum_doubleaction != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_ffmagnum_primary_refire))
				)
				{
						self.ffmagnum_ontrigger = 1;
						W_FFMagnum_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_ffmagnum_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_ffmagnum_primary_animtime, w_ready);
						self.ffmagnum_release = 1; //Slide needs to be wracked
						self.weaponname = "44magnum";
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.ffmagnum_ontrigger != 1) &&
				(self.ffmagnum_release == 1) &&
				(self.ffmagnum_jammed != 1) &&
				(self.ffmagnum_doubleaction != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_ffmagnum_primary_refire))
				)
				{
					self.ffmagnum_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_FFMagnum_Attack2);
					self.ffmagnum_halftime = time + (autocvar_g_balance_ffmagnum_cocking_time * 0.5);
					self.ffmagnum_fulltime = time + autocvar_g_balance_ffmagnum_cocking_time;
					self.ffmagnum_state = 2;
					self.ffmagnum_doubleaction = 1;
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.ffmagnum_ontrigger == 1) &&
				(self.ffmagnum_release != 1) &&
				(self.ffmagnum_jammed != 1) &&
				(self.ffmagnum_doubleaction == 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_ffmagnum_primary_refire))
				)
				{
					//Double Action fire
						self.ffmagnum_ontrigger = 1;
						W_FFMagnum_Attack();
						ATTACK_FINISHED(self) = time + autocvar_g_balance_ffmagnum_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_ffmagnum_primary_animtime, w_ready);
						self.ffmagnum_release = 1; //Slide needs to be wracked
						self.weaponname = "44magnum";
						self.ffmagnum_doubleaction = 0;
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.ffmagnum_ontrigger != 1) &&
				(self.ffmagnum_release == 1) &&
				(self.ffmagnum_jammed != 1) &&
				(self.ffmagnum_doubleaction != 1) &&
				(weapon_prepareattack(1, autocvar_g_balance_ffmagnum_secondary_refire))
				)
				{
					self.ffmagnum_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_FFMagnum_Attack2);
					self.ffmagnum_halftime = time + (autocvar_g_balance_ffmagnum_cocking_time * 0.5);
					self.ffmagnum_fulltime = time + autocvar_g_balance_ffmagnum_cocking_time;
					self.ffmagnum_state = 2;
				}
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.ffmagnum_ontrigger = 0;
					self.ffmagnum_doubleaction = 0; //Not squeezing trigger
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.ffmagnum_jammed && self.ffmagnum_unjam)
		  {
		  	if (time >= self.ffmagnum_unjam_time) {
				self.ffmagnum_jammed = 0;
				self.ffmagnum_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_44magnum.md3");
		precache_model ("models/weapons/v_44magnum.md3");
		precache_model ("models/weapons/h_44magnum.iqm");
		precache_model ("models/weapons/v_44magnum-cocked.md3");
		precache_model ("models/weapons/h_44magnum-cocked.iqm");
		precache_model ("models/weapons/v_44magnum-half.md3");
		precache_model ("models/weapons/h_44magnum-half.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire3_bass.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -1.2';
		weapon_setup(WEP_FFMAGNUM);
		self.current_ammo = ammo_nails;
		
		if (self.ffmagnum_release == 1) {
			self.weaponname = "44magnum";
		} else {
			self.weaponname = "44magnum-cocked";
		}
		self.ffmagnum_doubleaction = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_ffmagnum_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_FFMAGNUM]) >= autocvar_g_balance_ffmagnum_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.ffmagnum_casings = 0;
		self.ffmagnum_doubleaction = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.ffmagnum_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_ffmagnum_clearjam_time, w_ready);
			if (self.ffmagnum_unjam != 1) {
				self.ffmagnum_unjam = 1;
				self.ffmagnum_unjam_time = time + autocvar_g_balance_ffmagnum_clearjam_time;
				self.ffmagnum_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the ffmagnum\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_ffmagnum_primary_ammo, autocvar_g_balance_ffmagnum_reload_ammo, autocvar_g_balance_ffmagnum_reload_time, "weapons/reload.wav");
			
			if (autocvar_g_casings >= 2) {
				float sc;
				for (sc = 0;sc < self.ffmagnum_casings;sc = sc + 1) {
					SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 26, self);
				}
				self.ffmagnum_casings = 0;
			}
		}
		//self.ffmagnum_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_ffmagnum(float req)
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
			w_deathtypestring = _("%s spuriously tried to breathe after %s's 44 magnum said no");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot through the skull by %s");
		else
			w_deathtypestring = _("%s life ended. 44 magnum powered by %s's action.");
	}
	return TRUE;
}
#endif
#endif
