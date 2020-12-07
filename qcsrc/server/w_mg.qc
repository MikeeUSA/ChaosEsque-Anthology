#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MG, w_mg, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "g3", "mg", _("Assault Rifle"))
#else
#ifdef SVQC
.float mg_release;
.float mg_jammed;
.float mg_unjam;
.float mg_unjam_time;
.float mg_click;
.float mg_overheat_cnt;
.float mg_overheated_until;

float W_Mg_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_mg_reload_ammo && self.clip_load < min(max(autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_first_ammo), autocvar_g_balance_mg_burst_ammo)))
	{
		if (!self.mg_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.mg_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.mg_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

// leilei's fancy muzzleflash stuff
void MG_Flash_Go()
{
	self.frame = self.frame + 2;
	self.scale = self.scale * 0.5;
	self.alpha = self.alpha - 0.25;
	self.nextthink = time + 0.05;

	if (self.alpha <= 0)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		self.realowner.muzzle_flash = world;
		return;
	}

}

void MgFlash()
{
	if (self.muzzle_flash == world)
		self.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash, "models/uziflash.md3"); // precision set below

	self.muzzle_flash.scale = 0.75;
	self.muzzle_flash.think = MG_Flash_Go;
	self.muzzle_flash.nextthink = time + 0.02;
	self.muzzle_flash.frame = 2;
	self.muzzle_flash.alpha = 0.75;
	self.muzzle_flash.angles_z = random() * 180;
	self.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash.owner = self.muzzle_flash.realowner = self;
}

void W_MG_Attack (float deathtype)
{
	if (autocvar_g_balance_mg_jamrate &&
 	(autocvar_g_balance_mg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle jammed\n");
		}
		self.mg_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_mg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_mg_first_damage : autocvar_g_balance_mg_sustained_damage));
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_mg_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_mg_first_spread, autocvar_g_balance_mg_speed, 5, autocvar_g_balance_mg_first_damage, autocvar_g_balance_mg_first_headshotaddeddamage, autocvar_g_balance_mg_first_force, deathtype, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_balance_mg_bulletconstant, autocvar_g_balance_mg_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_mg_sustained_spread, autocvar_g_balance_mg_speed, 5, autocvar_g_balance_mg_sustained_damage, autocvar_g_balance_mg_sustained_headshotaddeddamage, autocvar_g_balance_mg_sustained_force, deathtype, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_balance_mg_bulletconstant, autocvar_g_balance_mg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	MgFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	
	PlayerGunRise(self, autocvar_g_balance_mg_gunrise, random() * autocvar_g_balance_mg_gunrun);

	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 104, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.mg_overheat_cnt),"_Firing\n");
		
	    	self.mg_overheat_cnt = self.mg_overheat_cnt + autocvar_g_balance_mg_heatconstant;
         
	    	if (self.mg_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your rifle overheated\n");
			}
				
			self.mg_overheated_until = time + (autocvar_g_balance_mg_cooldownwait * (self.mg_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed

	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg_first_ammo, autocvar_g_balance_mg_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_reload_ammo);
}

// weapon frames
void mg_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.mg_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.mg_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.mg_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_MG_Attack(WEP_MG);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mg_sustained_refire, mg_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mg_sustained_refire, w_ready);
}


void mg_mode1_fire_auto()
{
	float mg_spread;

	if (self.mg_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.mg_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}

	if(W_Mg_NeedManualReload()) {
		w_ready();
		return;	
	}

	if (!self.BUTTON_ATCK2)
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_reload_ammo);

	if(autocvar_g_balance_mg_jamrate &&
 	(autocvar_g_balance_mg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle jammed\n");
		}
		self.mg_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_mg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire.wav", CH_WEAPON_A, autocvar_g_balance_mg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	mg_spread = bound(autocvar_g_balance_mg_spread_min, autocvar_g_balance_mg_spread_min + (autocvar_g_balance_mg_spread_add * self.misc_bulletcounter), autocvar_g_balance_mg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, mg_spread, autocvar_g_balance_mg_speed, 5, autocvar_g_balance_mg_sustained_damage, autocvar_g_balance_mg_sustained_headshotaddeddamage, autocvar_g_balance_mg_sustained_force, WEP_MG, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_balance_mg_bulletconstant, autocvar_g_balance_mg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	MgFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	
	PlayerGunRise(self, autocvar_g_balance_mg_gunrise, random() * autocvar_g_balance_mg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 104, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.mg_overheat_cnt),"_Firing\n");
		
	    	self.mg_overheat_cnt = self.mg_overheat_cnt + autocvar_g_balance_mg_heatconstant;
         
	    	if (self.mg_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your rifle overheated\n");
			}
				
			self.mg_overheated_until = time + (autocvar_g_balance_mg_cooldownwait * (self.mg_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed

	ATTACK_FINISHED(self) = time + autocvar_g_balance_mg_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_mg_sustained_refire, mg_mode1_fire_auto);
}

void mg_mode1_fire_burst()
{

	if (self.mg_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.mg_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(W_Mg_NeedManualReload()) {
		w_ready();
		return;	
	}
	
	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_reload_ammo);

	if(autocvar_g_balance_mg_jamrate &&
 	(autocvar_g_balance_mg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle jammed\n");
		}
		self.mg_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_mg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire.wav", CH_WEAPON_A, autocvar_g_balance_mg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_mg_burst_spread, autocvar_g_balance_mg_speed, 5, autocvar_g_balance_mg_sustained_damage, autocvar_g_balance_mg_sustained_headshotaddeddamage, autocvar_g_balance_mg_sustained_force, WEP_MG, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_balance_mg_bulletconstant, autocvar_g_balance_mg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();


	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	MgFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	
	PlayerGunRise(self, autocvar_g_balance_mg_gunrise, random() * autocvar_g_balance_mg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 104, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.mg_overheat_cnt),"_Firing\n");
		
	    	self.mg_overheat_cnt = self.mg_overheat_cnt + autocvar_g_balance_mg_heatconstant;
         
	    	if (self.mg_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your rifle overheated\n");
			}
				
			self.mg_overheated_until = time + (autocvar_g_balance_mg_cooldownwait * (self.mg_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_mg_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mg_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mg_burst_refire, mg_mode1_fire_burst);
	}

}

void spawnfunc_weapon_mg()
{    
	weapon_defaultspawnfunc(WEP_MG);
}

float w_mg(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.mg_overheat_cnt),"_Cooldown\n");
			
			if (self.mg_overheat_cnt < autocvar_g_balance_mg_heatmin) {
				self.mg_overheat_cnt = autocvar_g_balance_mg_heatmin;
			} else {
				self.mg_overheat_cnt = self.mg_overheat_cnt - (autocvar_g_balance_mg_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Mg_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.mg_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		if(vlen(self.origin-self.enemy.origin) < 2000 - bound(0, skill, 10) * 200)
			if (self.mg_release) {
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			} else {
				self.BUTTON_ATCK=FALSE;
				self.BUTTON_ATCK2=FALSE;
			}
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Mg_NeedManualReload())
	{
		if(autocvar_g_balance_mg_reload_ammo && self.clip_load < min(max(autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_first_ammo), autocvar_g_balance_mg_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.mg_jammed && self.mg_unjam)
		  {
		  	if (time >= self.mg_unjam_time) {
				self.mg_jammed = 0;
				self.mg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.mg_release)
			if (self.mg_jammed != 1)
			if ((time > self.mg_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(0, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				//W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg_burst_ammo, autocvar_g_balance_mg_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_mg_burst * -1;
				mg_mode1_fire_burst();
				self.mg_release = 0;
			}

			if(self.BUTTON_ATCK2)
			if (self.mg_release)
			if (self.mg_jammed != 1)
			if ((time > self.mg_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if(weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 0;
				mg_mode1_fire_auto();
				self.mg_release = 0;
			}
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				self.mg_release = 1;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_mg.md3");
		//precache_model ("models/weapons/v_mg.md3");
		//precache_model ("models/weapons/h_mg.iqm");
		precache_model ("models/weapons/g_g3.md3");
		precache_model ("models/weapons/v_g3.md3");
		precache_model ("models/weapons/h_g3.iqm");
		precache_sound ("weapons/campingrifle_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.mg_overheat_cnt = autocvar_g_balance_mg_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '44 0.01 -3.4';
		weapon_setup(WEP_MG);
		self.current_ammo = ammo_nails;
		
		
		
		  if (self.mg_jammed && self.mg_unjam)
		  {
		  	if (time >= self.mg_unjam_time) {
				self.mg_jammed = 0;
				self.mg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_mg_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_mg_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_mg_first_ammo;

		if(autocvar_g_balance_mg_reload_ammo)
		{
			if(autocvar_g_balance_mg_mode == 1)
				ammo_amount += self.(weapon_load[WEP_MG]) >= autocvar_g_balance_mg_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_MG]) >= autocvar_g_balance_mg_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_mg_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_mg_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_mg_first_ammo;

		if(autocvar_g_balance_mg_reload_ammo)
		{
			if(autocvar_g_balance_mg_mode == 1)
				ammo_amount += self.(weapon_load[WEP_MG]) >= autocvar_g_balance_mg_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_MG]) >= autocvar_g_balance_mg_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.mg_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_mg_clearjam_time, w_ready);
			if (self.mg_unjam != 1) {
				self.mg_unjam = 1;
				self.mg_unjam_time = time + autocvar_g_balance_mg_clearjam_time;
				self.mg_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the gun\n");
				}
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_mg_sustained_ammo, autocvar_g_balance_mg_first_ammo), autocvar_g_balance_mg_burst_ammo), autocvar_g_balance_mg_reload_ammo, autocvar_g_balance_mg_reload_time, "weapons/reload.wav");
			self.mg_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_mg(float req)
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
			w_deathtypestring = _("%s was raked by %s's assault rifle");
		else if(w_deathtype & HITTYPE_CORESHOT)
				w_deathtypestring = _("%s got their chest ventilated by %s's assault rifle");
		else
			w_deathtypestring = _("%s was put down via %s's assault rifle");
	}
	return TRUE;
}
#endif
#endif
