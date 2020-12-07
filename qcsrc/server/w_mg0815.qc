#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MG0815, w_mg0815, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "mg0815", "mg0815", _("MG 08/15"))
#else
#ifdef SVQC
.float mg0815_jammed;
.float mg0815_unjam;
.float mg0815_unjam_time;
.float mg0815_click;
// weapon frames

float W_Mg0815_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_mg0815_reload_ammo && self.clip_load < autocvar_g_balance_mg0815_sustained_ammo))
	{
		if (!self.mg0815_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
			self.mg0815_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.mg0815_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void mg0815_fire_auto()
{
	float mg0815_spread;
	
	if (self.mg0815_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_Mg0815_NeedManualReload()) {
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg0815_sustained_ammo, autocvar_g_balance_mg0815_reload_ammo);

	
	if(autocvar_g_balance_mg0815_jamrate &&
 	(autocvar_g_balance_mg0815_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun has jammed\n");
		}
		self.mg0815_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_mg0815_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire.wav", CH_WEAPON_A, autocvar_g_balance_mg0815_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	mg0815_spread = bound(autocvar_g_balance_mg0815_spread_min, autocvar_g_balance_mg0815_spread_min + (autocvar_g_balance_mg0815_spread_add * self.misc_bulletcounter), autocvar_g_balance_mg0815_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, mg0815_spread, autocvar_g_balance_mg0815_speed, 5, autocvar_g_balance_mg0815_sustained_damage, autocvar_g_balance_mg0815_sustained_headshotaddeddamage, autocvar_g_balance_mg0815_sustained_force, WEP_MG0815, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_balance_mg0815_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '-1 0 1.5');
	
	PlayerGunRise(self, autocvar_g_balance_mg0815_gunrise, random() * autocvar_g_balance_mg0815_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing_Offset (((random () * -5 - 1) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -5 + 190) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 105, self, '0 1.5 3'); //back, side, updown

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_mg0815_sustained_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mg0815_sustained_refire, mg0815_fire_auto);
}

void spawnfunc_weapon_mg0815()
{    
	weapon_defaultspawnfunc(WEP_MG0815);
}

float w_mg0815(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Mg0815_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.mg0815_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Mg0815_NeedManualReload())
	{
		if(autocvar_g_balance_mg0815_reload_ammo && self.clip_load < autocvar_g_balance_mg0815_sustained_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
		  if (self.mg0815_jammed && self.mg0815_unjam)
		  {
		  	if (time >= self.mg0815_unjam_time) {
				self.mg0815_jammed = 0;
				self.mg0815_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			if (self.BUTTON_ATCK)
			if (self.mg0815_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				mg0815_fire_auto();
			}

			/*
			if(self.BUTTON_ATCK2)
			if (self.mg0815_jammed != 1)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mg0815_burst_ammo, autocvar_g_balance_mg0815_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_mg0815_burst * -1;
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
		precache_model ("models/weapons/g_mg0815.md3");
		precache_model ("models/weapons/v_mg0815.md3");
		precache_model ("models/weapons/h_mg0815.iqm");
		precache_sound ("weapons/campingrifle_fire.wav");		
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '44 0.1 -5';
		//self.weaponaltaim = '54 -0.35 -2.95';
		//self.weaponaltaim = '47 -0.35 -5';
		//self.weaponaltaim = '50 -0.35 -4';
		//self.weaponaltaim = '52 -0.35 -4'; //too far to right
		//self.weaponaltaim = '52 0 -4'; //too far to left
		self.weaponaltaim = '58 -0.20 -5.25';
		weapon_setup(WEP_MG0815);
		self.current_ammo = ammo_nails;
	
	
		
		  if (self.mg0815_jammed && self.mg0815_unjam)
		  {
		  	if (time >= self.mg0815_unjam_time) {
				self.mg0815_jammed = 0;
				self.mg0815_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_mg0815_sustained_ammo;

		if(autocvar_g_balance_mg0815_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_MG0815]) >= autocvar_g_balance_mg0815_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_mg0815_sustained_ammo;

		if(autocvar_g_balance_mg0815_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_MG0815]) >= autocvar_g_balance_mg0815_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.mg0815_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_mg0815_clearjam_time, w_ready);
			if (self.mg0815_unjam != 1) {
				self.mg0815_unjam = 1;
				self.mg0815_unjam_time = time + autocvar_g_balance_mg0815_clearjam_time;
				self.mg0815_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_mg0815_sustained_ammo, autocvar_g_balance_mg0815_reload_ammo, autocvar_g_balance_mg0815_reload_time, "weapons/reload.wav");
			self.mg0815_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_mg0815(float req)
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
			w_deathtypestring = _("%s was sniped by %s's MG 08/15");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s was ripped through the heart and lungs by %s's MG 08/15");
		else
			w_deathtypestring = _("%s torn to bits by %s's MG 08/15");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_mg0815()
//{    
//	weapon_defaultspawnfunc(WEP_MG0815);
//}
