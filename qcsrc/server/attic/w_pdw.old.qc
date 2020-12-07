#ifdef REGISTER_WEAPON
REGISTER_WEAPON(PDW, w_pdw, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "pdw", "pdw", _("PDW Sub-Machine Gun"))
#else
#ifdef SVQC
.float pdw_release;
.float pdw_jammed;
.float pdw_unjam;
.float pdw_unjam_time;
.float pdw_click;
.float pdw_overheat_cnt;
.float pdw_overheated_until;

float W_PDW_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_pdw_reload_ammo && self.clip_load < min(max(autocvar_g_balance_pdw_sustained_ammo, autocvar_g_balance_pdw_first_ammo), autocvar_g_balance_pdw_burst_ammo)))
	{	
		if (!self.pdw_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.pdw_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.pdw_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void W_PDW_Attack (float deathtype)
{
	if (autocvar_g_balance_pdw_jamrate &&
 	(autocvar_g_balance_pdw_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.pdw_jammed = 1;
	} else { //Start Not Jammed
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_pdw_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_pdw_first_damage : autocvar_g_balance_pdw_sustained_damage));

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_pdw_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_pdw_first_spread, autocvar_g_balance_pdw_speed, 5, autocvar_g_balance_pdw_first_damage, autocvar_g_balance_pdw_first_headshotaddeddamage, autocvar_g_balance_pdw_first_force, deathtype, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_projectile_9mm_bulletconstant, autocvar_g_balance_pdw_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_pdw_sustained_spread, autocvar_g_balance_pdw_speed, 5, autocvar_g_balance_pdw_sustained_damage, autocvar_g_balance_pdw_sustained_headshotaddeddamage, autocvar_g_balance_pdw_sustained_force, deathtype, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_projectile_9mm_bulletconstant, autocvar_g_balance_pdw_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '-3 0 0');
		PlayerGunRise(self, autocvar_g_balance_pdw_gunrise, random() * autocvar_g_balance_pdw_gunrun);
	
	
	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);


	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.pdw_overheat_cnt),"_Firing\n");
		
	    	self.pdw_overheat_cnt = self.pdw_overheat_cnt + autocvar_g_balance_pdw_heatconstant;
         
	    	if (self.pdw_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.pdw_overheated_until = time + (autocvar_g_balance_pdw_cooldownwait * (self.pdw_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	



	} //End Not Jammed
	
	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_pdw_first_ammo, autocvar_g_balance_pdw_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_pdw_sustained_ammo, autocvar_g_balance_pdw_reload_ammo);
}

// weapon frames
void pdw_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.pdw_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.pdw_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_PDW_Attack(WEP_PDW);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pdw_sustained_refire, pdw_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pdw_sustained_refire, w_ready);
}


void pdw_mode1_fire_auto()
{
	float pdw_spread;

	if (self.pdw_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(W_PDW_NeedManualReload()) {
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_pdw_sustained_ammo, autocvar_g_balance_pdw_reload_ammo);

	if(autocvar_g_balance_pdw_jamrate &&
 	(autocvar_g_balance_pdw_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.pdw_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_pdw_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_pdw_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	pdw_spread = bound(autocvar_g_balance_pdw_spread_min, autocvar_g_balance_pdw_spread_min + (autocvar_g_balance_pdw_spread_add * self.misc_bulletcounter), autocvar_g_balance_pdw_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, pdw_spread, autocvar_g_balance_pdw_speed, 5, autocvar_g_balance_pdw_sustained_damage, autocvar_g_balance_pdw_sustained_headshotaddeddamage, autocvar_g_balance_pdw_sustained_force, WEP_PDW, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_projectile_9mm_bulletconstant, autocvar_g_balance_pdw_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '-3 0 0');
		PlayerGunRise(self, autocvar_g_balance_pdw_gunrise, random() * autocvar_g_balance_pdw_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.pdw_overheat_cnt),"_Firing\n");
		
	    	self.pdw_overheat_cnt = self.pdw_overheat_cnt + autocvar_g_balance_pdw_heatconstant;
         
	    	if (self.pdw_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.pdw_overheated_until = time + (autocvar_g_balance_pdw_cooldownwait * (self.pdw_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_pdw_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pdw_sustained_refire, pdw_mode1_fire_auto);
}

void pdw_mode1_fire_burst()
{
	if (self.pdw_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(autocvar_g_balance_pdw_jamrate &&
 	(autocvar_g_balance_pdw_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.pdw_jammed = 1;
	} else { //Start Not Jammed
	
	
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_pdw_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_pdw_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_pdw_burst_spread, autocvar_g_balance_pdw_speed, 5, autocvar_g_balance_pdw_sustained_damage, autocvar_g_balance_pdw_sustained_headshotaddeddamage, autocvar_g_balance_pdw_sustained_force, WEP_PDW, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_projectile_9mm_bulletconstant, autocvar_g_balance_pdw_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

		//If suppressed, don't show flash, if not, then do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '-3 0 0');
		PlayerGunRise(self, autocvar_g_balance_pdw_gunrise, random() * autocvar_g_balance_pdw_gunrun);
	
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -120 - 200) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	
	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.pdw_overheat_cnt),"_Firing\n");
		
	    	self.pdw_overheat_cnt = self.pdw_overheat_cnt + autocvar_g_balance_pdw_heatconstant;
         
	    	if (self.pdw_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.pdw_overheated_until = time + (autocvar_g_balance_pdw_cooldownwait * (self.pdw_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_pdw_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_pdw_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_pdw_burst_refire, pdw_mode1_fire_burst);
	}

}

void spawnfunc_weapon_pdw()
{    
	weapon_defaultspawnfunc(WEP_PDW);
}

float w_pdw(float req)
{
	
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.pdw_overheat_cnt),"_Cooldown\n");
			
			if (self.pdw_overheat_cnt < autocvar_g_balance_pdw_heatmin) {
				self.pdw_overheat_cnt = autocvar_g_balance_pdw_heatmin;
			} else {
				self.pdw_overheat_cnt = self.pdw_overheat_cnt - (autocvar_g_balance_pdw_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_PDW_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.pdw_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.pdw_release) {
			if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
			{
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
			}
		}
	}
	else if (req == WR_THINK && !W_PDW_NeedManualReload())
	{
		if(autocvar_g_balance_pdw_reload_ammo && self.clip_load < min(max(autocvar_g_balance_pdw_sustained_ammo, autocvar_g_balance_pdw_first_ammo), autocvar_g_balance_pdw_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_pdw_mode == 1)
		{
		  if (self.pdw_jammed && self.pdw_unjam)
		  {
		  	if (time >= self.pdw_unjam_time) {
				self.pdw_jammed = 0;
				self.pdw_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.pdw_release)
			if (self.pdw_jammed != 1)
			if ((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				pdw_mode1_fire_auto();
			}

			if(self.BUTTON_ATCK2)
			if (self.pdw_release)
			if (self.pdw_jammed != 1)
			if ((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_pdw_burst_ammo, autocvar_g_balance_pdw_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_pdw_burst * -1;
				pdw_mode1_fire_burst();
				self.pdw_release = 0;
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.pdw_release = 1;
			}
			////END NORMAL////
		  }
		}
		else
		{
		  if (self.pdw_jammed && self.pdw_unjam)
		  {
		  	if (time >= self.pdw_unjam_time) {
				self.pdw_jammed = 0;
				self.pdw_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.pdw_jammed != 1)
			if ((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 1;
				W_PDW_Attack(WEP_PDW); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pdw_sustained_refire, pdw_fire1_02);
			}

			if (self.BUTTON_ATCK2 && autocvar_g_balance_pdw_first)
			if (self.pdw_jammed != 1)
			if ((time > self.pdw_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 1;
				W_PDW_Attack(WEP_PDW | HITTYPE_SECONDARY); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_pdw_first_refire, w_ready);
			}
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_pdw.md3");
		//precache_model ("models/weapons/v_pdw.md3");
		//precache_model ("models/weapons/h_pdw.iqm");
		precache_model ("models/weapons/g_pdw.md3");
		precache_model ("models/weapons/v_pdw.md3");
		precache_model ("models/weapons/h_pdw.iqm");
		precache_sound ("weapons/uzi_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.pdw_overheat_cnt = autocvar_g_balance_pdw_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.4 -4.5';
		weapon_setup(WEP_PDW);
		self.current_ammo = ammo_nails;
	
	
	
		  if (self.pdw_jammed && self.pdw_unjam)
		  {
		  	if (time >= self.pdw_unjam_time) {
				self.pdw_jammed = 0;
				self.pdw_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_pdw_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_pdw_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_pdw_first_ammo;

		if(autocvar_g_balance_pdw_reload_ammo)
		{
			if(autocvar_g_balance_pdw_mode == 1)
				ammo_amount += self.(weapon_load[WEP_PDW]) >= autocvar_g_balance_pdw_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_PDW]) >= autocvar_g_balance_pdw_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_pdw_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_pdw_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_pdw_first_ammo;

		if(autocvar_g_balance_pdw_reload_ammo)
		{
			if(autocvar_g_balance_pdw_mode == 1)
				ammo_amount += self.(weapon_load[WEP_PDW]) >= autocvar_g_balance_pdw_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_PDW]) >= autocvar_g_balance_pdw_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.pdw_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_pdw_clearjam_time, w_ready);
			if (self.pdw_unjam != 1) {
				self.pdw_unjam = 1;
				self.pdw_unjam_time = time + autocvar_g_balance_pdw_clearjam_time;
				self.pdw_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_pdw_sustained_ammo, autocvar_g_balance_pdw_first_ammo), autocvar_g_balance_pdw_burst_ammo), autocvar_g_balance_pdw_reload_ammo, autocvar_g_balance_pdw_reload_time, "weapons/reload.wav");
			self.pdw_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_pdw(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%s was sniped by %s's pdw");
		else
			w_deathtypestring = _("%s was riddled full of holes by %s's pdw");
	}
	return TRUE;
}
#endif
#endif
