#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M1928, w_m1928, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "m1928", "m1928", _(".45 SMG 1928"))
#else
#ifdef SVQC
.float m1928_release;
.float m1928_jammed;
.float m1928_unjam;
.float m1928_unjam_time;
.float m1928_click;

float W_M1928_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m1928_reload_ammo && self.clip_load < min(max(autocvar_g_balance_m1928_sustained_ammo, autocvar_g_balance_m1928_first_ammo), autocvar_g_balance_m1928_burst_ammo)))
	{	
		if (!self.m1928_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m1928_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.m1928_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void W_M1928_Attack (float deathtype)
{
	if (autocvar_g_balance_m1928_jamrate &&
 	(autocvar_g_balance_m1928_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1928_jammed = 1;
	} else { //Start Not Jammed
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1928_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_m1928_first_damage : autocvar_g_balance_m1928_sustained_damage));

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_m1928_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1928_first_spread, autocvar_g_balance_m1928_speed, 5, autocvar_g_balance_m1928_first_damage, autocvar_g_balance_m1928_first_headshotaddeddamage, autocvar_g_balance_m1928_first_force, deathtype, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_m1928_bulletconstant, autocvar_g_balance_m1928_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1928_sustained_spread, autocvar_g_balance_m1928_speed, 5, autocvar_g_balance_m1928_sustained_damage, autocvar_g_balance_m1928_sustained_headshotaddeddamage, autocvar_g_balance_m1928_sustained_force, deathtype, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_m1928_bulletconstant, autocvar_g_balance_m1928_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '12 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1928_gunrise, random() * autocvar_g_balance_m1928_gunrun);
	
	
	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	} //End Not Jammed
	
	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1928_first_ammo, autocvar_g_balance_m1928_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1928_sustained_ammo, autocvar_g_balance_m1928_reload_ammo);
}

// weapon frames
void m1928_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.m1928_jammed)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.m1928_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_M1928_Attack(WEP_M1928);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1928_sustained_refire, m1928_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1928_sustained_refire, w_ready);
}


void m1928_mode1_fire_auto()
{
	float m1928_spread;

	if (self.m1928_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_M1928_NeedManualReload()) {
		w_ready();
		return;	
	}
	
	if (!self.BUTTON_ATCK)
	{
		w_ready();
		return;
	}

	if (!weapon_action(self.weapon, WR_CHECKAMMO1))
	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		W_SwitchWeapon_Force(self, w_getbestweapon(self));
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1928_sustained_ammo, autocvar_g_balance_m1928_reload_ammo);

	if(autocvar_g_balance_m1928_jamrate &&
 	(autocvar_g_balance_m1928_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1928_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1928_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, autocvar_g_balance_m1928_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	m1928_spread = bound(autocvar_g_balance_m1928_spread_min, autocvar_g_balance_m1928_spread_min + (autocvar_g_balance_m1928_spread_add * self.misc_bulletcounter), autocvar_g_balance_m1928_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, m1928_spread, autocvar_g_balance_m1928_speed, 5, autocvar_g_balance_m1928_sustained_damage, autocvar_g_balance_m1928_sustained_headshotaddeddamage, autocvar_g_balance_m1928_sustained_force, WEP_M1928, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_m1928_bulletconstant, autocvar_g_balance_m1928_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '12 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1928_gunrise, random() * autocvar_g_balance_m1928_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_m1928_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1928_sustained_refire, m1928_mode1_fire_auto);
}

void m1928_mode1_fire_burst()
{
	if (self.m1928_jammed)
	{
		w_ready();
		return;
	}
	
	if(autocvar_g_balance_m1928_jamrate &&
 	(autocvar_g_balance_m1928_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1928_jammed = 1;
	} else { //Start Not Jammed
	
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1928_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, autocvar_g_balance_m1928_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1928_burst_spread, autocvar_g_balance_m1928_speed, 5, autocvar_g_balance_m1928_sustained_damage, autocvar_g_balance_m1928_sustained_headshotaddeddamage, autocvar_g_balance_m1928_sustained_force, WEP_M1928, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_m1928_bulletconstant, autocvar_g_balance_m1928_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		//If suppressed, don't show flash, if not, then do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '12 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1928_gunrise, random() * autocvar_g_balance_m1928_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_m1928_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1928_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1928_burst_refire, m1928_mode1_fire_burst);
	}

}

void spawnfunc_weapon_m1928()
{    
	weapon_defaultspawnfunc(WEP_M1928);
}

float w_m1928(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_M1928_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m1928_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.m1928_release) {
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
			{
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			}
		}
	}
	else if (req == WR_THINK && !W_M1928_NeedManualReload())
	{
		if(autocvar_g_balance_m1928_reload_ammo && self.clip_load < min(max(autocvar_g_balance_m1928_sustained_ammo, autocvar_g_balance_m1928_first_ammo), autocvar_g_balance_m1928_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_m1928_mode == 1)
		{
		  if (self.m1928_jammed && self.m1928_unjam)
		  {
		  	if (time >= self.m1928_unjam_time) {
				self.m1928_jammed = 0;
				self.m1928_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.m1928_release)
			if (self.m1928_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				m1928_mode1_fire_auto();
			}

			if(self.BUTTON_ATCK2)
			if (self.m1928_release)
			if (self.m1928_jammed != 1)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1928_burst_ammo, autocvar_g_balance_m1928_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_m1928_burst * -1;
				m1928_mode1_fire_burst();
				self.m1928_release = 0;
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m1928_release = 1;
			}
			////END NORMAL////
		  }
		}
		else
		{
		  if (self.m1928_jammed && self.m1928_unjam)
		  {
		  	if (time >= self.m1928_unjam_time) {
				self.m1928_jammed = 0;
				self.m1928_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.m1928_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 1;
				W_M1928_Attack(WEP_M1928); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1928_sustained_refire, m1928_fire1_02);
			}

			if (self.BUTTON_ATCK2 && autocvar_g_balance_m1928_first)
			if (self.m1928_jammed != 1)
			if (weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 1;
				W_M1928_Attack(WEP_M1928 | HITTYPE_SECONDARY); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1928_first_refire, w_ready);
			}
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_m1928.md3");
		//precache_model ("models/weapons/v_m1928.md3");
		//precache_model ("models/weapons/h_m1928.iqm");
		precache_model ("models/weapons/g_m1928.md3");
		precache_model ("models/weapons/v_m1928.md3");
		precache_model ("models/weapons/h_m1928.iqm");
		precache_sound ("weapons/campingrifle_fire2_bass.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 -0.6 -2.2';
		weapon_setup(WEP_M1928);
		self.current_ammo = ammo_nails;
		
		
		  if (self.m1928_jammed && self.m1928_unjam)
		  {
		  	if (time >= self.m1928_unjam_time) {
				self.m1928_jammed = 0;
				self.m1928_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_m1928_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1928_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1928_first_ammo;

		if(autocvar_g_balance_m1928_reload_ammo)
		{
			if(autocvar_g_balance_m1928_mode == 1)
				ammo_amount += self.(weapon_load[WEP_M1928]) >= autocvar_g_balance_m1928_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_M1928]) >= autocvar_g_balance_m1928_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_m1928_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1928_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1928_first_ammo;

		if(autocvar_g_balance_m1928_reload_ammo)
		{
			if(autocvar_g_balance_m1928_mode == 1)
				ammo_amount += self.(weapon_load[WEP_M1928]) >= autocvar_g_balance_m1928_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_M1928]) >= autocvar_g_balance_m1928_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m1928_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m1928_clearjam_time, w_ready);
			if (self.m1928_unjam != 1) {
				self.m1928_unjam = 1;
				self.m1928_unjam_time = time + autocvar_g_balance_m1928_clearjam_time;
				self.m1928_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_m1928_sustained_ammo, autocvar_g_balance_m1928_first_ammo), autocvar_g_balance_m1928_burst_ammo), autocvar_g_balance_m1928_reload_ammo, autocvar_g_balance_m1928_reload_time, "weapons/reload.wav");
			self.m1928_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_m1928(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("medbullet_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
			if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.1)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.2)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
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
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s was sniped by %s's long-barrel submachine gun");
		else
			w_deathtypestring = _("%s was riddled full of holes by %s's long-barrel submachine gun");
	}
	return TRUE;
}
#endif
#endif
