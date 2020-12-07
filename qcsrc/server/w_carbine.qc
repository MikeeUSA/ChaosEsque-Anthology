#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CARBINE, w_carbine, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "uzi", "carbine", _("Carbine"))
#else
#ifdef SVQC
.float carbine_jammed;
.float carbine_click;
.float carbine_overheat_cnt;
.float carbine_overheated_until;

float W_Carbine_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_carbine_reload_ammo && self.clip_load < min(max(autocvar_g_balance_carbine_sustained_ammo, autocvar_g_balance_carbine_first_ammo), autocvar_g_balance_carbine_burst_ammo)))
	{	
		if (!self.carbine_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.carbine_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.carbine_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void W_CARBINE_Attack (float deathtype)
{
	if (autocvar_g_balance_carbine_jamrate &&
 	(autocvar_g_balance_carbine_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.carbine_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_carbine_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_carbine_first_damage : autocvar_g_balance_carbine_sustained_damage));
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_carbine_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_carbine_first_spread, autocvar_g_balance_carbine_speed, 5, autocvar_g_balance_carbine_first_damage, autocvar_g_balance_carbine_first_headshotaddeddamage, autocvar_g_balance_carbine_first_force, deathtype, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_carbine_bulletconstant, autocvar_g_balance_carbine_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_carbine_sustained_spread, autocvar_g_balance_carbine_speed, 5, autocvar_g_balance_carbine_sustained_damage, autocvar_g_balance_carbine_sustained_headshotaddeddamage, autocvar_g_balance_carbine_sustained_force, deathtype, 0, 1, autocvar_g_balance_carbine_bulletconstant, autocvar_g_balance_carbine_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	PlayerGunRise(self, autocvar_g_balance_carbine_gunrise, random() * autocvar_g_balance_carbine_gunrun);
	
	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.carbine_overheat_cnt),"_Firing\n");
		
	    	self.carbine_overheat_cnt = self.carbine_overheat_cnt + autocvar_g_balance_carbine_heatconstant;
         
	    	if (self.carbine_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.carbine_overheated_until = time + (autocvar_g_balance_carbine_cooldownwait * (self.carbine_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_carbine_first_ammo, autocvar_g_balance_carbine_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_carbine_sustained_ammo, autocvar_g_balance_carbine_reload_ammo);
}

// weapon frames
void carbine_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.carbine_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.carbine_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_CARBINE_Attack(WEP_CARBINE);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_carbine_sustained_refire, carbine_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_carbine_sustained_refire, w_ready);
}


void carbine_mode1_fire_auto()
{
	float carbine_spread;

	if (self.carbine_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(W_Carbine_NeedManualReload()) {
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_carbine_sustained_ammo, autocvar_g_balance_carbine_reload_ammo);

	if(autocvar_g_balance_carbine_jamrate &&
 	(autocvar_g_balance_carbine_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.carbine_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_carbine_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_carbine_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	carbine_spread = bound(autocvar_g_balance_carbine_spread_min, autocvar_g_balance_carbine_spread_min + (autocvar_g_balance_carbine_spread_add * self.misc_bulletcounter), autocvar_g_balance_carbine_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, carbine_spread, autocvar_g_balance_carbine_speed, 5, autocvar_g_balance_carbine_sustained_damage, autocvar_g_balance_carbine_sustained_headshotaddeddamage, autocvar_g_balance_carbine_sustained_force, WEP_CARBINE, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_carbine_bulletconstant, autocvar_g_balance_carbine_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	PlayerGunRise(self, autocvar_g_balance_carbine_gunrise, random() * autocvar_g_balance_carbine_gunrun);
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.carbine_overheat_cnt),"_Firing\n");
		
	    	self.carbine_overheat_cnt = self.carbine_overheat_cnt + autocvar_g_balance_carbine_heatconstant;
         
	    	if (self.carbine_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.carbine_overheated_until = time + (autocvar_g_balance_carbine_cooldownwait * (self.carbine_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	
	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_carbine_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_carbine_sustained_refire, carbine_mode1_fire_auto);
}

void carbine_mode1_fire_burst()
{
	if (self.carbine_jammed)
	{
		w_ready();
		return;
	}
	
	if not((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
	{
		w_ready();
		return;
	}
	
	if(autocvar_g_balance_carbine_jamrate &&
 	(autocvar_g_balance_carbine_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.carbine_jammed = 1;
	} else { //Start Not Jammed
	
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_carbine_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_carbine_sustained_damage);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_carbine_burst_spread, autocvar_g_balance_carbine_speed, 5, autocvar_g_balance_carbine_sustained_damage, autocvar_g_balance_carbine_sustained_headshotaddeddamage, autocvar_g_balance_carbine_sustained_force, WEP_CARBINE, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_carbine_bulletconstant, autocvar_g_balance_carbine_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	PlayerGunRise(self, autocvar_g_balance_carbine_gunrise, random() * autocvar_g_balance_carbine_gunrun);
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	
	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.carbine_overheat_cnt),"_Firing\n");
		
	    	self.carbine_overheat_cnt = self.carbine_overheat_cnt + autocvar_g_balance_carbine_heatconstant;
         
	    	if (self.carbine_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your gun overheated\n");
			}
				
			self.carbine_overheated_until = time + (autocvar_g_balance_carbine_cooldownwait * (self.carbine_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_carbine_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_carbine_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_carbine_burst_refire, carbine_mode1_fire_burst);
	}

}

void spawnfunc_weapon_carbine()
{    
	weapon_defaultspawnfunc(WEP_CARBINE);
}

float w_carbine(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.carbine_overheat_cnt),"_Cooldown\n");
			
			if (self.carbine_overheat_cnt < autocvar_g_balance_carbine_heatmin) {
				self.carbine_overheat_cnt = autocvar_g_balance_carbine_heatmin;
			} else {
				self.carbine_overheat_cnt = self.carbine_overheat_cnt - (autocvar_g_balance_carbine_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Carbine_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.carbine_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Carbine_NeedManualReload())
	{
		if(autocvar_g_balance_carbine_reload_ammo && self.clip_load < min(max(autocvar_g_balance_carbine_sustained_ammo, autocvar_g_balance_carbine_first_ammo), autocvar_g_balance_carbine_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_carbine_mode == 1)
		{
			if (self.BUTTON_ATCK)
			if (self.carbine_jammed != 1)
			if ((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				carbine_mode1_fire_auto();
			}

			if(self.BUTTON_ATCK2)
			if (self.carbine_jammed != 1)
			if ((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_carbine_burst_ammo, autocvar_g_balance_carbine_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_carbine_burst * -1;
				carbine_mode1_fire_burst();
			}
		}
		else
		{

			if (self.BUTTON_ATCK)
			if (self.carbine_jammed != 1)
			if ((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 1;
				W_CARBINE_Attack(WEP_CARBINE); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_carbine_sustained_refire, carbine_fire1_02);
			}

			if (self.BUTTON_ATCK2 && autocvar_g_balance_carbine_first)
			if (self.carbine_jammed != 1)
			if ((time > self.carbine_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 1;
				W_CARBINE_Attack(WEP_CARBINE | HITTYPE_SECONDARY); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_carbine_first_refire, w_ready);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_carbine.md3");
		//precache_model ("models/weapons/v_carbine.md3");
		//precache_model ("models/weapons/h_carbine.iqm");
		precache_model ("models/weapons/g_uzi.md3");
		precache_model ("models/weapons/v_uzi.md3");
		precache_model ("models/weapons/h_uzi.iqm");
		precache_sound ("weapons/uzi_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.carbine_overheat_cnt = autocvar_g_balance_carbine_heatmin;
		weapon_setup(WEP_CARBINE);
		self.current_ammo = ammo_nails;
		self.weaponname = "uzi";
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_carbine_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_carbine_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_carbine_first_ammo;

		if(autocvar_g_balance_carbine_reload_ammo)
		{
			if(autocvar_g_balance_carbine_mode == 1)
				ammo_amount += self.(weapon_load[WEP_CARBINE]) >= autocvar_g_balance_carbine_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_CARBINE]) >= autocvar_g_balance_carbine_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_carbine_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_carbine_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_carbine_first_ammo;

		if(autocvar_g_balance_carbine_reload_ammo)
		{
			if(autocvar_g_balance_carbine_mode == 1)
				ammo_amount += self.(weapon_load[WEP_CARBINE]) >= autocvar_g_balance_carbine_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_CARBINE]) >= autocvar_g_balance_carbine_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.carbine_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_carbine_clearjam_time, w_ready);
			self.carbine_jammed = 0;
			self.carbine_click = 0;
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You cleared the jam\n");
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_carbine_sustained_ammo, autocvar_g_balance_carbine_first_ammo), autocvar_g_balance_carbine_burst_ammo), autocvar_g_balance_carbine_reload_ammo, autocvar_g_balance_carbine_reload_time, "weapons/reload.wav");
			self.carbine_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_carbine(float req)
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
			w_deathtypestring = _("%s was sniped by %s's carbine");
		else
			w_deathtypestring = _("%s was riddled full of holes by %s's carbine");
	}
	return TRUE;
}
#endif
#endif
