#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LONGPISTOL, w_longpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "45longslide", "longpistol", _(".45 Longslide"))
#else
#ifdef SVQC

.float longpistol_release;
.float longpistol_jammed;
.float longpistol_unjam;
.float longpistol_unjam_time;
.float longpistol_click;
.float longpistol_suppressed;
.float longpistol_animempty;
.float longpistol_animset;
.float longpistol_nextanim;
.float longpistol_nextbot;
.float longpistol_laser_on;

void W_LongPistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_longpistol_primary_ammo;
	d = autocvar_g_balance_longpistol_primary_damage;
	f = autocvar_g_balance_longpistol_primary_force;
	spread = autocvar_g_balance_longpistol_primary_spread;
	bulletspeed = autocvar_g_balance_longpistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_45acp_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_longpistol_reload_ammo);
	
	if (autocvar_g_balance_longpistol_jamrate &&
 	(autocvar_g_balance_longpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your .45 jammed\n");
		}
		self.longpistol_jammed = 1;
	} else { //Start Not Jammed

	if not(self.longpistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, d);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_longpistol_primary_headshotaddeddamage, f, WEP_LONGPISTOL, PROJECTILE_BULLET45ACP, 1, bulletconstant, autocvar_g_balance_longpistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.longpistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_longpistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_longpistol_gunrise, random() * autocvar_g_balance_longpistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '6 0 0');
	} else {
		PlayerGunRise(self, autocvar_g_balance_longpistol_suppressed_gunrise, random() * autocvar_g_balance_longpistol_suppressed_gunrun);	
	}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	
	} //End Not Jammed
}


float W_LongPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_longpistol_reload_ammo && self.clip_load < autocvar_g_balance_longpistol_primary_ammo))
	{
		if (!self.longpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.longpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.longpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_longpistol (void)
{
	weapon_defaultspawnfunc(WEP_LONGPISTOL);
}


.float longpistol_primarytime;

float w_longpistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_LongPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.longpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.longpistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_longpistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_LongPistol_NeedManualReload())
	{
		if (self.longpistol_suppressed) {
			if (!autocvar_g_balance_longpistol_suppressornotincluded
			|| self.inv_misc_suppressor45)
			{
				//Nothing
			} else {
				self.longpistol_suppressed = 0;
				self.longpistol_animset = 1;
			}
		}
		
	
		if(autocvar_g_balance_longpistol_reload_ammo && self.clip_load < autocvar_g_balance_longpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty longpistol if its melee attack is active
			if not(autocvar_g_balance_longpistol_secondary && self.ammo_nails < autocvar_g_balance_longpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.longpistol_release = 0;
		}
		else
		{
		  if (self.longpistol_jammed && self.longpistol_unjam)
		  {
		  	if (time >= self.longpistol_unjam_time) {
				self.longpistol_jammed = 0;
				self.longpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.longpistol_release)
			if (self.longpistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.longpistol_nextbot)," \n");
				} else {
					self.longpistol_nextbot = 0;
				}
				
				if (time >= self.longpistol_nextbot) {
					W_LongPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_longpistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_longpistol_primary_animtime, w_ready);
					self.longpistol_release = 0;
					self.longpistol_animempty = 1;
					self.longpistol_animset = 1;
					self.longpistol_nextanim = time + autocvar_g_balance_longpistol_primary_rfanim;
					bp_skipme = 1;
					//self.longpistol_nextbot = time + (autocvar_g_balance_longpistol_primary_refire * 50 * random());
					self.longpistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_longpistol_fullauto == 1) {
						self.longpistol_release = 1;
						self.longpistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.longpistol_jammed != 1)
				if (time >= self.longpistol_nextanim)
				if (self.longpistol_animempty)
				{
					self.longpistol_animempty = 0;
					self.longpistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.longpistol_release = 1;
			}
			
			if (self.BUTTON_ATCK2) {
				self.longpistol_laser_on = 1;
			} else {
				self.longpistol_laser_on = 0;
			}
				
			if (self.longpistol_animset)
			if (self.longpistol_jammed != 1) {
				if (self.longpistol_suppressed) {
					if (self.longpistol_animempty)
						self.weaponname = "45longslide_suppressed_empty";
					else
						self.weaponname = "45longslide_suppressed";
				} else if (!self.longpistol_suppressed) {
					if (self.longpistol_animempty)
						self.weaponname = "45longslide_empty";
					else
						self.weaponname = "45longslide";
				}
			}
			
			self.longpistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/laser_dot.iqm");
		precache_model ("models/weapons/g_45longslide.md3");
		precache_model ("models/weapons/v_45longslide.md3");
		//precache_model ("models/weapons/g_45longslide_suppressed.md3");
		precache_model ("models/weapons/v_45longslide_suppressed.md3");
		precache_model ("models/weapons/h_45longslide.iqm");
		precache_model ("models/weapons/h_45longslide_suppressed.iqm");
		
		precache_model ("models/weapons/v_45longslide_empty.md3");
		precache_model ("models/weapons/v_45longslide_suppressed_empty.md3");
		precache_model ("models/weapons/h_45longslide_empty.iqm");
		precache_model ("models/weapons/h_45longslide_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire2_bass.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -1';
		self.weaponaltaim = '40 -0.35 -4';
			
		weapon_setup(WEP_LONGPISTOL);
		self.current_ammo = ammo_nails;
		
		if (!autocvar_g_balance_longpistol_suppressornotincluded
		|| self.inv_misc_suppressor45)
		{
			if (self.longpistol_suppressed) {
				if (self.longpistol_animempty)
					self.weaponname = "45longslide_suppressed_empty";
				else
					self.weaponname = "45longslide_suppressed";
			} else if (!self.longpistol_suppressed) {
				if (self.longpistol_animempty)
					self.weaponname = "45longslide_empty";
				else
					self.weaponname = "45longslide";
			}
		} else {
			self.longpistol_suppressed = 0;
			
			if (self.longpistol_animempty)
				self.weaponname = "45longslide_empty";
			else
				self.weaponname = "45longslide";
		}
	
	
	
		  if (self.longpistol_jammed && self.longpistol_unjam)
		  {
		  	if (time >= self.longpistol_unjam_time) {
				self.longpistol_jammed = 0;
				self.longpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_longpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LONGPISTOL]) >= autocvar_g_balance_longpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.longpistol_jammed) {
			self.longpistol_laser_on = 0;
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_longpistol_clearjam_time, w_ready);
			if (self.longpistol_unjam != 1) {
				self.longpistol_unjam = 1;
				self.longpistol_unjam_time = time + autocvar_g_balance_longpistol_clearjam_time;
				self.longpistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			self.longpistol_laser_on = 0;
			W_Reload(autocvar_g_balance_longpistol_primary_ammo, autocvar_g_balance_longpistol_reload_ammo, autocvar_g_balance_longpistol_reload_time, "weapons/reload.wav");
			
			if (self.BUTTON_USE) {
			  if (!autocvar_g_balance_longpistol_suppressornotincluded
			  || self.inv_misc_suppressor45)
			  {
				if (self.longpistol_suppressed) {
					self.longpistol_suppressed = 0;
					if (self.longpistol_animempty)
						self.weaponname = "45longslide_empty";
					else
						self.weaponname = "45longslide";
				} else if (!self.longpistol_suppressed) {
					self.longpistol_suppressed = 1;
					if (self.longpistol_animempty)
						self.weaponname = "45longslide_suppressed_empty";
					else
						self.weaponname = "45longslide_suppressed";
				}
			  }
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_longpistol(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("medbullet_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s was removed when %2$s placed a .45 slug in their chest");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was terminated with a bullet to the head by %2$s");
		else
			w_deathtypestring = _("%s processed by %s");
	}
	return TRUE;
}
#endif
#endif
