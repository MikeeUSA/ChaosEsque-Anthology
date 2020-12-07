#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FIVESEVENPISTOL, w_fivesevenpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "fivesevenpistol", "fivesevenpistol", _("5.7mm Pistol"))
#else
#ifdef SVQC

.float fivesevenpistol_release;
.float fivesevenpistol_jammed;
.float fivesevenpistol_unjam;
.float fivesevenpistol_unjam_time;
.float fivesevenpistol_click;
.float fivesevenpistol_suppressed;
.float fivesevenpistol_animempty;
.float fivesevenpistol_animset;
.float fivesevenpistol_nextanim;
.float fivesevenpistol_nextbot;

void W_FivesevenPistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_fivesevenpistol_primary_ammo;
	d = autocvar_g_balance_fivesevenpistol_primary_damage;
	f = autocvar_g_balance_fivesevenpistol_primary_force;
	spread = autocvar_g_balance_fivesevenpistol_primary_spread;
	bulletspeed = autocvar_g_balance_fivesevenpistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_5n7_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_fivesevenpistol_reload_ammo);
	
	if (autocvar_g_balance_fivesevenpistol_jamrate &&
 	(autocvar_g_balance_fivesevenpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your pistol jammed\n");
		}
		self.fivesevenpistol_jammed = 1;
	} else { //Start Not Jammed

	if not(self.fivesevenpistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_fivesevenpistol_primary_headshotaddeddamage, f, WEP_FIVESEVENPISTOL, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_fivesevenpistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.fivesevenpistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_fivesevenpistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_fivesevenpistol_gunrise, random() * autocvar_g_balance_fivesevenpistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '-0.75 0 0');
	} else {
		PlayerGunRise(self, autocvar_g_balance_fivesevenpistol_suppressed_gunrise, random() * autocvar_g_balance_fivesevenpistol_suppressed_gunrun);	
	}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 61, self);

	
	} //End Not Jammed
}


float W_FivesevenPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_fivesevenpistol_reload_ammo && self.clip_load < autocvar_g_balance_fivesevenpistol_primary_ammo))
	{
		if (!self.fivesevenpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.fivesevenpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.fivesevenpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_fivesevenpistol (void)
{
	weapon_defaultspawnfunc(WEP_FIVESEVENPISTOL);
}


.float fivesevenpistol_primarytime;

float w_fivesevenpistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_FivesevenPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.fivesevenpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.fivesevenpistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_fivesevenpistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_FivesevenPistol_NeedManualReload())
	{
		if (self.fivesevenpistol_suppressed) {
			if (!autocvar_g_balance_fivesevenpistol_suppressornotincluded
			|| self.inv_misc_suppressor5n7mm)
			{
				//Nothing
			} else {
				self.fivesevenpistol_suppressed = 0;
				self.fivesevenpistol_animset = 1;
			}
		}
	
	
	
		if(autocvar_g_balance_fivesevenpistol_reload_ammo && self.clip_load < autocvar_g_balance_fivesevenpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty fivesevenpistol if its melee attack is active
			if not(autocvar_g_balance_fivesevenpistol_secondary && self.ammo_nails < autocvar_g_balance_fivesevenpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.fivesevenpistol_release = 0;
		}
		else
		{
		  if (self.fivesevenpistol_jammed && self.fivesevenpistol_unjam)
		  {
		  	if (time >= self.fivesevenpistol_unjam_time) {
				self.fivesevenpistol_jammed = 0;
				self.fivesevenpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.fivesevenpistol_release)
			if (self.fivesevenpistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.fivesevenpistol_nextbot)," \n");
				} else {
					self.fivesevenpistol_nextbot = 0;
				}
				
				if (time >= self.fivesevenpistol_nextbot) {
					W_FivesevenPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_fivesevenpistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fivesevenpistol_primary_animtime, w_ready);
					self.fivesevenpistol_release = 0;
					self.fivesevenpistol_animempty = 1;
					self.fivesevenpistol_animset = 1;
					self.fivesevenpistol_nextanim = time + autocvar_g_balance_fivesevenpistol_primary_rfanim;
					bp_skipme = 1;
					//self.fivesevenpistol_nextbot = time + (autocvar_g_balance_fivesevenpistol_primary_refire * 50 * random());
					self.fivesevenpistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_fivesevenpistol_fullauto == 1) {
						self.fivesevenpistol_release = 1;
						self.fivesevenpistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.fivesevenpistol_jammed != 1)
				if (time >= self.fivesevenpistol_nextanim)
				if (self.fivesevenpistol_animempty)
				{
					self.fivesevenpistol_animempty = 0;
					self.fivesevenpistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.fivesevenpistol_release = 1;
			}
				
			if (self.fivesevenpistol_animset)
			if (self.fivesevenpistol_jammed != 1) {
				if (self.fivesevenpistol_suppressed) {
					if (self.fivesevenpistol_animempty)
						self.weaponname = "fivesevenpistol_suppressed_empty";
					else
						self.weaponname = "fivesevenpistol_suppressed";
				} else if (!self.fivesevenpistol_suppressed) {
					if (self.fivesevenpistol_animempty)
						self.weaponname = "fivesevenpistol_empty";
					else
						self.weaponname = "fivesevenpistol";
				}
			}
			
			self.fivesevenpistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_fivesevenpistol.md3");
		precache_model ("models/weapons/v_fivesevenpistol.md3");
		//////precache_model ("models/weapons/g_fivesevenpistol_suppressed.md3");
		precache_model ("models/weapons/v_fivesevenpistol_suppressed.md3");
		precache_model ("models/weapons/h_fivesevenpistol.iqm");
		precache_model ("models/weapons/h_fivesevenpistol_suppressed.iqm");
		
		precache_model ("models/weapons/v_fivesevenpistol_empty.md3");
		precache_model ("models/weapons/v_fivesevenpistol_suppressed_empty.md3");
		precache_model ("models/weapons/h_fivesevenpistol_empty.iqm");
		precache_model ("models/weapons/h_fivesevenpistol_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -1.3';
			
		weapon_setup(WEP_FIVESEVENPISTOL);
		self.current_ammo = ammo_nails;
		
		if (!autocvar_g_balance_fivesevenpistol_suppressornotincluded
		|| self.inv_misc_suppressor5n7mm)
		{
			if (self.fivesevenpistol_suppressed) {
				if (self.fivesevenpistol_animempty)
					self.weaponname = "fivesevenpistol_suppressed_empty";
				else
					self.weaponname = "fivesevenpistol_suppressed";
			} else if (!self.fivesevenpistol_suppressed) {
				if (self.fivesevenpistol_animempty)
					self.weaponname = "fivesevenpistol_empty";
				else
					self.weaponname = "fivesevenpistol";
			}
		} else {
			self.fivesevenpistol_suppressed = 0;
			
			if (self.fivesevenpistol_animempty)
				self.weaponname = "fivesevenpistol_empty";
			else
				self.weaponname = "fivesevenpistol";
		}
		
		
		  if (self.fivesevenpistol_jammed && self.fivesevenpistol_unjam)
		  {
		  	if (time >= self.fivesevenpistol_unjam_time) {
				self.fivesevenpistol_jammed = 0;
				self.fivesevenpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_fivesevenpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_FIVESEVENPISTOL]) >= autocvar_g_balance_fivesevenpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.fivesevenpistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_fivesevenpistol_clearjam_time, w_ready);
			if (self.fivesevenpistol_unjam != 1) {
				self.fivesevenpistol_unjam = 1;
				self.fivesevenpistol_unjam_time = time + autocvar_g_balance_fivesevenpistol_clearjam_time;
				self.fivesevenpistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_fivesevenpistol_primary_ammo, autocvar_g_balance_fivesevenpistol_reload_ammo, autocvar_g_balance_fivesevenpistol_reload_time, "weapons/reload.wav");
			
			if (self.BUTTON_USE) {
			  if (!autocvar_g_balance_fivesevenpistol_suppressornotincluded
			  || self.inv_misc_suppressor5n7mm)
			  {
				if (self.fivesevenpistol_suppressed) {
					self.fivesevenpistol_suppressed = 0;
					if (self.fivesevenpistol_animempty)
						self.weaponname = "fivesevenpistol_empty";
					else
						self.weaponname = "fivesevenpistol";
				} else if (!self.fivesevenpistol_suppressed) {
					self.fivesevenpistol_suppressed = 1;
					if (self.fivesevenpistol_animempty)
						self.weaponname = "fivesevenpistol_suppressed_empty";
					else
						self.weaponname = "fivesevenpistol_suppressed";
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
float w_fivesevenpistol(float req)
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
			w_deathtypestring = _("%1$s was shot in the chest with a 5.7mm round by %2$s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was executed with a 5.7mm pistol by %2$s");
		else
			w_deathtypestring = _("%s killed by %s's 5.7mm pistol");
	}
	return TRUE;
}
#endif
#endif
