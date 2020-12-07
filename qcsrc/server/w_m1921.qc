#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M1921, w_m1921, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "m1921", "m1921", _(".45 SMG 1921"))
#else
#ifdef SVQC
.float m1921_release;
.float m1921_jammed;
.float m1921_unjam;
.float m1921_unjam_time;
.float m1921_click;

.float m1921_triggerlag;
.float m1921_triggerlag_time;
.float m1921_triggerlag_button;

float W_M1921_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m1921_reload_ammo && self.clip_load < min(max(autocvar_g_balance_m1921_sustained_ammo, autocvar_g_balance_m1921_first_ammo), autocvar_g_balance_m1921_burst_ammo)))
	{	
		if (!self.m1921_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m1921_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.m1921_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void W_M1921_Attack (float deathtype)
{
	if (autocvar_g_balance_m1921_jamrate &&
 	(autocvar_g_balance_m1921_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1921_jammed = 1;
	} else { //Start Not Jammed
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1921_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_m1921_first_damage : autocvar_g_balance_m1921_sustained_damage));
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_m1921_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1921_first_spread, autocvar_g_balance_m1921_speed, 5, autocvar_g_balance_m1921_first_damage, autocvar_g_balance_m1921_first_headshotaddeddamage, autocvar_g_balance_m1921_first_force, deathtype, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_projectile_45acp_bulletconstant, autocvar_g_balance_m1921_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1921_sustained_spread, autocvar_g_balance_m1921_speed, 5, autocvar_g_balance_m1921_sustained_damage, autocvar_g_balance_m1921_sustained_headshotaddeddamage, autocvar_g_balance_m1921_sustained_force, deathtype, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_projectile_45acp_bulletconstant, autocvar_g_balance_m1921_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '6 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1921_gunrise, random() * autocvar_g_balance_m1921_gunrun);
	
	
	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	} //End Not Jammed
	
	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1921_first_ammo, autocvar_g_balance_m1921_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1921_sustained_ammo, autocvar_g_balance_m1921_reload_ammo);
}

// weapon frames
void m1921_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.m1921_jammed)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.m1921_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_M1921_Attack(WEP_M1921);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1921_sustained_refire, m1921_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1921_sustained_refire, w_ready);
}


void m1921_mode1_fire_auto()
{
	float m1921_spread;

	if (self.m1921_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_M1921_NeedManualReload()) {
		w_ready();
		return;	
	}
	
	if (!self.BUTTON_ATCK && !self.m1921_triggerlag_button)
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1921_sustained_ammo, autocvar_g_balance_m1921_reload_ammo);

	if(autocvar_g_balance_m1921_jamrate &&
 	(autocvar_g_balance_m1921_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1921_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1921_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, autocvar_g_balance_m1921_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	m1921_spread = bound(autocvar_g_balance_m1921_spread_min, autocvar_g_balance_m1921_spread_min + (autocvar_g_balance_m1921_spread_add * self.misc_bulletcounter), autocvar_g_balance_m1921_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, m1921_spread, autocvar_g_balance_m1921_speed, 5, autocvar_g_balance_m1921_sustained_damage, autocvar_g_balance_m1921_sustained_headshotaddeddamage, autocvar_g_balance_m1921_sustained_force, WEP_M1921, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_projectile_45acp_bulletconstant, autocvar_g_balance_m1921_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '6 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1921_gunrise, random() * autocvar_g_balance_m1921_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_m1921_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1921_sustained_refire, m1921_mode1_fire_auto);
}

void m1921_mode1_fire_burst()
{
	if (self.m1921_jammed)
	{
		w_ready();
		return;
	}
	
	if(autocvar_g_balance_m1921_jamrate &&
 	(autocvar_g_balance_m1921_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.m1921_jammed = 1;
	} else { //Start Not Jammed
	
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_m1921_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, autocvar_g_balance_m1921_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_m1921_burst_spread, autocvar_g_balance_m1921_speed, 5, autocvar_g_balance_m1921_sustained_damage, autocvar_g_balance_m1921_sustained_headshotaddeddamage, autocvar_g_balance_m1921_sustained_force, WEP_M1921, PROJECTILE_BULLET45ACP, 1, autocvar_g_balance_projectile_45acp_bulletconstant, autocvar_g_balance_m1921_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		//If suppressed, don't show flash, if not, then do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '6 0 0');
		PlayerGunRise(self, autocvar_g_balance_m1921_gunrise, random() * autocvar_g_balance_m1921_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_m1921_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1921_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1921_burst_refire, m1921_mode1_fire_burst);
	}

}

void spawnfunc_weapon_m1921()
{    
	weapon_defaultspawnfunc(WEP_M1921);
}

float w_m1921(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_M1921_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m1921_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.m1921_release) {
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
			{
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			}
		}
	}
	else if (req == WR_THINK && !W_M1921_NeedManualReload())
	{
		if(autocvar_g_balance_m1921_reload_ammo && self.clip_load < min(max(autocvar_g_balance_m1921_sustained_ammo, autocvar_g_balance_m1921_first_ammo), autocvar_g_balance_m1921_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_m1921_mode == 1)
		{
		  if (self.m1921_jammed && self.m1921_unjam)
		  {
		  	if (time >= self.m1921_unjam_time) {
				self.m1921_jammed = 0;
				self.m1921_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK || self.m1921_triggerlag_button == 1)
			if (self.m1921_release)
			if (self.m1921_jammed != 1)
			if (((time > self.m1921_triggerlag_time) && self.m1921_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack(0, 0))
			{
				self.m1921_triggerlag = 1; //For openbolt trigger lag
				
				self.misc_bulletcounter = 0;
				m1921_mode1_fire_auto();
			}

			if(self.BUTTON_ATCK2 || self.m1921_triggerlag_button == 2)
			if (self.m1921_release)
			if (self.m1921_jammed != 1)
			if (((time > self.m1921_triggerlag_time) && self.m1921_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if(weapon_prepareattack(1, 0))
			{
				self.m1921_triggerlag = 1; //For openbolt trigger lag
				
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_m1921_burst_ammo, autocvar_g_balance_m1921_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_m1921_burst * -1;
				m1921_mode1_fire_burst();
				self.m1921_release = 0;
			}
			
			
			//Openbolt trigger lag
			if (time > self.m1921_triggerlag_time) {
				self.m1921_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.m1921_triggerlag)
			&& (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
				if (self.BUTTON_ATCK) {
					self.m1921_triggerlag_button = 1;
				} else if (self.BUTTON_ATCK2) {
					self.m1921_triggerlag_button = 2;
				}
				
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.m1921_triggerlag = 1;
				self.m1921_triggerlag_time = time + (autocvar_g_balance_m1921_sustained_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m1921_release = 1;
				
				if not(self.m1921_triggerlag_button) {
					self.m1921_triggerlag = 0; //For openbolt trigger lag
				}
			}
			////END NORMAL////
		  }
		}
		else
		{
		  if (self.m1921_jammed && self.m1921_unjam)
		  {
		  	if (time >= self.m1921_unjam_time) {
				self.m1921_jammed = 0;
				self.m1921_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.m1921_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 1;
				W_M1921_Attack(WEP_M1921); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m1921_sustained_refire, m1921_fire1_02);
			}

			if (self.BUTTON_ATCK2 && autocvar_g_balance_m1921_first)
			if (self.m1921_jammed != 1)
			if (weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 1;
				W_M1921_Attack(WEP_M1921 | HITTYPE_SECONDARY); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_m1921_first_refire, w_ready);
			}
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_m1921.md3");
		//precache_model ("models/weapons/v_m1921.md3");
		//precache_model ("models/weapons/h_m1921.iqm");
		precache_model ("models/weapons/g_m1921.md3");
		precache_model ("models/weapons/v_m1921.md3");
		precache_model ("models/weapons/h_m1921.iqm");
		precache_sound ("weapons/campingrifle_fire2_bass.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.m1921_triggerlag_button = 0; //for openbolt trigger lag
		self.m1921_triggerlag = 0; //for openbolt trigger lag
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 -0.6 -2.2';
		weapon_setup(WEP_M1921);
		self.current_ammo = ammo_nails;
		
		
		  if (self.m1921_jammed && self.m1921_unjam)
		  {
		  	if (time >= self.m1921_unjam_time) {
				self.m1921_jammed = 0;
				self.m1921_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_m1921_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1921_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1921_first_ammo;

		if(autocvar_g_balance_m1921_reload_ammo)
		{
			if(autocvar_g_balance_m1921_mode == 1)
				ammo_amount += self.(weapon_load[WEP_M1921]) >= autocvar_g_balance_m1921_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_M1921]) >= autocvar_g_balance_m1921_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_m1921_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1921_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_m1921_first_ammo;

		if(autocvar_g_balance_m1921_reload_ammo)
		{
			if(autocvar_g_balance_m1921_mode == 1)
				ammo_amount += self.(weapon_load[WEP_M1921]) >= autocvar_g_balance_m1921_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_M1921]) >= autocvar_g_balance_m1921_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		self.m1921_triggerlag_button = 0; //for openbolt triggerlag
		self.m1921_triggerlag = 0; //for openbolt triggerlag
		
		if (self.m1921_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m1921_clearjam_time, w_ready);
			if (self.m1921_unjam != 1) {
				self.m1921_unjam = 1;
				self.m1921_unjam_time = time + autocvar_g_balance_m1921_clearjam_time;
				self.m1921_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_m1921_sustained_ammo, autocvar_g_balance_m1921_first_ammo), autocvar_g_balance_m1921_burst_ammo), autocvar_g_balance_m1921_reload_ammo, autocvar_g_balance_m1921_reload_time, "weapons/reload.wav");
			self.m1921_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_m1921(float req)
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
			w_deathtypestring = _("%s was sniped by %s's submachine gun");
		else
			w_deathtypestring = _("%s was riddled full of holes by %s's submachine gun");
	}
	return TRUE;
}
#endif
#endif
