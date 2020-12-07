#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HMG, w_hmg, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "hmg", "hmg", _("Heavy Machine Gun"))
#else
#ifdef SVQC
.float hmg_jammed;
.float hmg_unjam;
.float hmg_unjam_time;
.float hmg_click;
// weapon frames

float W_Hmg_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_hmg_reload_ammo && self.clip_load < autocvar_g_balance_hmg_sustained_ammo))
	{
		if (!self.hmg_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
			self.hmg_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.hmg_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void hmg_fire_auto()
{
	float hmg_spread;
	
	if (self.hmg_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_Hmg_NeedManualReload()) {
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_hmg_sustained_ammo, autocvar_g_balance_hmg_reload_ammo);

	
	if(autocvar_g_balance_hmg_jamrate &&
 	(autocvar_g_balance_hmg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun has jammed\n");
		}
		self.hmg_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_hmg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2.wav", CH_WEAPON_A, autocvar_g_balance_hmg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	hmg_spread = bound(autocvar_g_balance_hmg_spread_min, autocvar_g_balance_hmg_spread_min + (autocvar_g_balance_hmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_hmg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, hmg_spread, autocvar_g_balance_hmg_speed, 5, autocvar_g_balance_hmg_sustained_damage, autocvar_g_balance_hmg_sustained_headshotaddeddamage, autocvar_g_balance_hmg_sustained_force, WEP_HMG, PROJECTILE_BULLETRIFLE9MM, 1, autocvar_g_balance_hmg_bulletconstant, autocvar_g_balance_hmg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	
	PlayerGunRise(self, autocvar_g_balance_hmg_gunrise, random() * autocvar_g_balance_hmg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 99, self);

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_hmg_sustained_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hmg_sustained_refire, hmg_fire_auto);
}

void spawnfunc_weapon_hmg()
{    
	weapon_defaultspawnfunc(WEP_HMG);
}

float w_hmg(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Hmg_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.hmg_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Hmg_NeedManualReload())
	{
		if(autocvar_g_balance_hmg_reload_ammo && self.clip_load < autocvar_g_balance_hmg_sustained_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
		  if (self.hmg_jammed && self.hmg_unjam)
		  {
		  	if (time >= self.hmg_unjam_time) {
				self.hmg_jammed = 0;
				self.hmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			if (self.BUTTON_ATCK)
			if (self.hmg_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				hmg_fire_auto();
			}

			/*
			if(self.BUTTON_ATCK2)
			if (self.hmg_jammed != 1)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_hmg_burst_ammo, autocvar_g_balance_hmg_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_hmg_burst * -1;
				uzi_mode1_fire_burst();
			}
			*/
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_hmg.md3");
		precache_model ("models/weapons/v_hmg.md3");
		precache_model ("models/weapons/h_hmg.iqm");
		precache_sound ("weapons/campingrifle_fire2.wav");		
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '44 0.1 -5';
		weapon_setup(WEP_HMG);
		self.current_ammo = ammo_nails;
		
		
		
		  if (self.hmg_jammed && self.hmg_unjam)
		  {
		  	if (time >= self.hmg_unjam_time) {
				self.hmg_jammed = 0;
				self.hmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hmg_sustained_ammo;

		if(autocvar_g_balance_hmg_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_HMG]) >= autocvar_g_balance_hmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hmg_sustained_ammo;

		if(autocvar_g_balance_hmg_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_HMG]) >= autocvar_g_balance_hmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.hmg_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_hmg_clearjam_time, w_ready);
			if (self.hmg_unjam != 1) {
				self.hmg_unjam = 1;
				self.hmg_unjam_time = time + autocvar_g_balance_hmg_clearjam_time;
				self.hmg_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_hmg_sustained_ammo, autocvar_g_balance_hmg_reload_ammo, autocvar_g_balance_hmg_reload_time, "weapons/reload.wav");
			self.hmg_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hmg(float req)
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
			w_deathtypestring = _("%s was sniped by %s's heavy machine gun");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s was ripped through the heart and lungs by %s's heavy machine gun");
		else
			w_deathtypestring = _("%s torn to bits by %s's heavy machine gun");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_hmg()
//{    
//	weapon_defaultspawnfunc(WEP_HMG);
//}
