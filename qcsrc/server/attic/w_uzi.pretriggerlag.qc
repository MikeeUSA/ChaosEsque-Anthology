#ifdef REGISTER_WEAPON
REGISTER_WEAPON(UZI, w_uzi, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "mac10_unsuppressed", "uzi", _("Machine Gun"))
#else
#ifdef SVQC
.float uzi_jammed;
.float uzi_unjam;
.float uzi_unjam_time;
.float uzi_click;
.float uzi_suppressed;
.float uzi_gsetsuppressed; //For ground model setting propagation

float W_Uzi_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_uzi_reload_ammo && self.clip_load < min(max(autocvar_g_balance_uzi_sustained_ammo, autocvar_g_balance_uzi_first_ammo), autocvar_g_balance_uzi_burst_ammo)))
	{	
		if (!self.uzi_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.uzi_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.uzi_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


// leilei's fancy muzzleflash stuff
void UZI_Flash_Go()
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

void UziFlash()
{
	if (self.muzzle_flash == world)
		self.muzzle_flash = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash, "models/uziflash.md3"); // precision set below

	self.muzzle_flash.scale = 0.75;
	self.muzzle_flash.think = UZI_Flash_Go;
	self.muzzle_flash.nextthink = time + 0.02;
	self.muzzle_flash.frame = 2;
	self.muzzle_flash.alpha = 0.75;
	self.muzzle_flash.angles_z = random() * 180;
	self.muzzle_flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash.owner = self.muzzle_flash.realowner = self;
}

void W_UZI_Attack (float deathtype)
{
	if (autocvar_g_balance_uzi_jamrate &&
 	(autocvar_g_balance_uzi_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.uzi_jammed = 1;
	} else { //Start Not Jammed
	
	if not(self.uzi_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_uzi_first_damage : autocvar_g_balance_uzi_sustained_damage));
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, ((self.misc_bulletcounter == 1) ? autocvar_g_balance_uzi_first_damage : autocvar_g_balance_uzi_sustained_damage));
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	// this attack_finished just enforces a cooldown at the end of a burst
	ATTACK_FINISHED(self) = time + autocvar_g_balance_uzi_first_refire * W_WeaponRateFactor();

	if (self.misc_bulletcounter == 1)
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_uzi_first_spread, autocvar_g_balance_uzi_speed, 5, autocvar_g_balance_uzi_first_damage, autocvar_g_balance_uzi_first_headshotaddeddamage, autocvar_g_balance_uzi_first_force, deathtype, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_uzi_bulletconstant, autocvar_g_balance_uzi_first_coreshotaddeddamage);
	else
		fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_uzi_sustained_spread, autocvar_g_balance_uzi_speed, 5, autocvar_g_balance_uzi_sustained_damage, autocvar_g_balance_uzi_sustained_headshotaddeddamage, autocvar_g_balance_uzi_sustained_force, deathtype, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_uzi_bulletconstant, autocvar_g_balance_uzi_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.uzi_suppressed) { 
		//If suppressed, don't show flash. Otherwise do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '5 0 0');
		PlayerGunRise(self, autocvar_g_balance_uzi_gunrise, random() * autocvar_g_balance_uzi_gunrun);
	} else {
		PlayerGunRise(self, autocvar_g_balance_uzi_suppressed_gunrise, random() * autocvar_g_balance_uzi_suppressed_gunrun);
	}
	
	// casing code
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	} //End Not Jammed
	
	if (self.misc_bulletcounter == 1)
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_uzi_first_ammo, autocvar_g_balance_uzi_reload_ammo);
	else
		W_DecreaseAmmo(ammo_nails, autocvar_g_balance_uzi_sustained_ammo, autocvar_g_balance_uzi_reload_ammo);
}

// weapon frames
void uzi_fire1_02()
{
	if(self.weapon != self.switchweapon) // abort immediately if switching
	{
		w_ready();
		return;
	}
	
	if (self.uzi_jammed)
	{
		w_ready();
		return;
	}
	
	if (self.BUTTON_ATCK)
	if (self.uzi_jammed != 1)
	{
		if (!weapon_action(self.weapon, WR_CHECKAMMO2))
		if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		{
			W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w_ready();
			return;
		}
		self.misc_bulletcounter = self.misc_bulletcounter + 1;
		W_UZI_Attack(WEP_UZI);
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_uzi_sustained_refire, uzi_fire1_02);
	}
	else
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_uzi_sustained_refire, w_ready);
}


void uzi_mode1_fire_auto()
{
	float uzi_spread;

	if (self.uzi_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_Uzi_NeedManualReload()) {
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_uzi_sustained_ammo, autocvar_g_balance_uzi_reload_ammo);

	if(autocvar_g_balance_uzi_jamrate &&
 	(autocvar_g_balance_uzi_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.uzi_jammed = 1;
	} else { //Start Not Jammed

	if not(self.uzi_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_uzi_sustained_damage);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, autocvar_g_balance_uzi_sustained_damage);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	uzi_spread = bound(autocvar_g_balance_uzi_spread_min, autocvar_g_balance_uzi_spread_min + (autocvar_g_balance_uzi_spread_add * self.misc_bulletcounter), autocvar_g_balance_uzi_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, uzi_spread, autocvar_g_balance_uzi_speed, 5, autocvar_g_balance_uzi_sustained_damage, autocvar_g_balance_uzi_sustained_headshotaddeddamage, autocvar_g_balance_uzi_sustained_force, WEP_UZI, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_uzi_bulletconstant, autocvar_g_balance_uzi_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	if not(self.uzi_suppressed) { 
		//If suppressed, don't show flash. If not, then do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '5 0 0');
		PlayerGunRise(self, autocvar_g_balance_uzi_gunrise, random() * autocvar_g_balance_uzi_gunrun);
	} else {
		PlayerGunRise(self, autocvar_g_balance_uzi_suppressed_gunrise, random() * autocvar_g_balance_uzi_suppressed_gunrun);
	}
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_uzi_first_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_uzi_sustained_refire, uzi_mode1_fire_auto);
}

void uzi_mode1_fire_burst()
{
	if (self.uzi_jammed)
	{
		w_ready();
		return;
	}
	
	if(autocvar_g_balance_uzi_jamrate &&
 	(autocvar_g_balance_uzi_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your gun jammed\n");
		}
		self.uzi_jammed = 1;
	} else { //Start Not Jammed
	
	
	if not(self.uzi_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_uzi_sustained_damage);
	} else {
			W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, autocvar_g_balance_uzi_sustained_damage);
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}
	
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_uzi_burst_spread, autocvar_g_balance_uzi_speed, 5, autocvar_g_balance_uzi_sustained_damage, autocvar_g_balance_uzi_sustained_headshotaddeddamage, autocvar_g_balance_uzi_sustained_force, WEP_UZI, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_uzi_bulletconstant, autocvar_g_balance_uzi_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.uzi_suppressed) {  
		//If suppressed, don't show flash, if not, then do
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

		UziFlash();
		W_AttachToShotorg(self.muzzle_flash, '5 0 0');
		PlayerGunRise(self, autocvar_g_balance_uzi_gunrise, random() * autocvar_g_balance_uzi_gunrun);
	} else {
		PlayerGunRise(self, autocvar_g_balance_uzi_suppressed_gunrise, random() * autocvar_g_balance_uzi_suppressed_gunrun);
	}
	
	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self);

	self.misc_bulletcounter = self.misc_bulletcounter + 1;
	
	} //End Not Jammed
	
	if (self.misc_bulletcounter == 0)
	{
		ATTACK_FINISHED(self) = time + autocvar_g_balance_uzi_burst_refire2 * W_WeaponRateFactor();
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_uzi_burst_animtime, w_ready);
	}
	else
	{
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_uzi_burst_refire, uzi_mode1_fire_burst);
	}

}

void spawnfunc_weapon_machinegun(); // defined in t_items.qc

void w_uzi_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.uzi_suppressed) {
		myself.model = "models/weapons/g_mac10_suppressed.md3";
		
		if (autocvar_g_balance_uzi_suppressornotincluded
		&& player.inv_misc_suppressormac10 >= 1) {
			player.inv_misc_suppressormac10 = player.inv_misc_suppressormac10 - 1;
			myself.inv_misc_suppressormac10 = myself.inv_misc_suppressormac10 + 1;
		}
		
		myself.uzi_gsetsuppressed = player.uzi_suppressed;
	} else {
		//Do nothing
		myself.uzi_gsetsuppressed = 0;
	}
}

void w_uzi_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_UZI) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.uzi_suppressed = myself.uzi_gsetsuppressed;
		}
	}
}

float w_uzi(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Uzi_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.uzi_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Uzi_NeedManualReload())
	{
		if (self.uzi_suppressed) {
			if (!autocvar_g_balance_uzi_suppressornotincluded
			|| self.inv_misc_suppressormac10)
			{
				//Nothing
			} else {
				self.uzi_suppressed = 0;
				self.weaponname = "mac10_unsuppressed";
				self.weaponaltaim_use = 1;
				self.weaponaltaim = '35 -0.5 -2.8';
			}
		}
		
	
		if(autocvar_g_balance_uzi_reload_ammo && self.clip_load < min(max(autocvar_g_balance_uzi_sustained_ammo, autocvar_g_balance_uzi_first_ammo), autocvar_g_balance_uzi_burst_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if(autocvar_g_balance_uzi_mode == 1)
		{
		  if (self.uzi_jammed && self.uzi_unjam)
		  {
		  	if (time >= self.uzi_unjam_time) {
				self.uzi_jammed = 0;
				self.uzi_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.uzi_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 0;
				uzi_mode1_fire_auto();
			}

			if(self.BUTTON_ATCK2)
			if (self.uzi_jammed != 1)
			if(weapon_prepareattack(1, 0))
			{
				if (!weapon_action(self.weapon, WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
					w_ready();
					return FALSE;
				}

				W_DecreaseAmmo(ammo_nails, autocvar_g_balance_uzi_burst_ammo, autocvar_g_balance_uzi_reload_ammo);

				self.misc_bulletcounter = autocvar_g_balance_uzi_burst * -1;
				uzi_mode1_fire_burst();
			}
			////END NORMAL////
		  }
		}
		else
		{
		  if (self.uzi_jammed && self.uzi_unjam)
		  {
		  	if (time >= self.uzi_unjam_time) {
				self.uzi_jammed = 0;
				self.uzi_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			if (self.BUTTON_ATCK)
			if (self.uzi_jammed != 1)
			if (weapon_prepareattack(0, 0))
			{
				self.misc_bulletcounter = 1;
				W_UZI_Attack(WEP_UZI); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_uzi_sustained_refire, uzi_fire1_02);
			}

			if (self.BUTTON_ATCK2 && autocvar_g_balance_uzi_first)
			if (self.uzi_jammed != 1)
			if (weapon_prepareattack(1, 0))
			{
				self.misc_bulletcounter = 1;
				W_UZI_Attack(WEP_UZI | HITTYPE_SECONDARY); // sets attack_finished
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_uzi_first_refire, w_ready);
			}
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		//precache_model ("models/weapons/g_uzi.md3");
		//precache_model ("models/weapons/v_uzi.md3");
		//precache_model ("models/weapons/h_uzi.iqm");
		precache_model ("models/weapons/g_mac10_unsuppressed.md3");
		precache_model ("models/weapons/v_mac10_unsuppressed.md3");
		precache_model ("models/weapons/h_mac10_unsuppressed.iqm");
		precache_model ("models/weapons/g_mac10_suppressed.md3");
		precache_model ("models/weapons/v_mac10_suppressed.md3");
		precache_model ("models/weapons/h_mac10_suppressed.iqm");
		precache_sound ("weapons/uzi_fire.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_UZI);
		self.current_ammo = ammo_nails;
		
		if (!autocvar_g_balance_uzi_suppressornotincluded
		|| self.inv_misc_suppressormac10)
		{
			if (self.uzi_suppressed) {
				self.weaponname = "mac10_suppressed";
				self.weaponaltaim_use = 1;
				self.weaponaltaim = '50 -0.5 -2.7';
			} else if (!self.uzi_suppressed) {
				self.weaponname = "mac10_unsuppressed";
				self.weaponaltaim_use = 1;
				self.weaponaltaim = '35 -0.5 -2.8';
			}
		} else {
			self.uzi_suppressed = 0;
			self.weaponname = "mac10_unsuppressed";
			self.weaponaltaim_use = 1;
			self.weaponaltaim = '35 -0.5 -2.8';
		}
	
	
	
	
		  if (self.uzi_jammed && self.uzi_unjam)
		  {
		  	if (time >= self.uzi_unjam_time) {
				self.uzi_jammed = 0;
				self.uzi_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(autocvar_g_balance_uzi_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_uzi_sustained_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_uzi_first_ammo;

		if(autocvar_g_balance_uzi_reload_ammo)
		{
			if(autocvar_g_balance_uzi_mode == 1)
				ammo_amount += self.(weapon_load[WEP_UZI]) >= autocvar_g_balance_uzi_sustained_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_UZI]) >= autocvar_g_balance_uzi_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_uzi_mode == 1)
			ammo_amount = self.ammo_nails >= autocvar_g_balance_uzi_burst_ammo;
		else
			ammo_amount = self.ammo_nails >= autocvar_g_balance_uzi_first_ammo;

		if(autocvar_g_balance_uzi_reload_ammo)
		{
			if(autocvar_g_balance_uzi_mode == 1)
				ammo_amount += self.(weapon_load[WEP_UZI]) >= autocvar_g_balance_uzi_burst_ammo;
			else
				ammo_amount += self.(weapon_load[WEP_UZI]) >= autocvar_g_balance_uzi_first_ammo;
		}
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		if (self.uzi_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_uzi_clearjam_time, w_ready);
			if (self.uzi_unjam != 1) {
				self.uzi_unjam = 1;
				self.uzi_unjam_time = time + autocvar_g_balance_uzi_clearjam_time;
				self.uzi_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the gun\n");
				}
			}
		} else {
			W_Reload(min(max(autocvar_g_balance_uzi_sustained_ammo, autocvar_g_balance_uzi_first_ammo), autocvar_g_balance_uzi_burst_ammo), autocvar_g_balance_uzi_reload_ammo, autocvar_g_balance_uzi_reload_time, "weapons/reload.wav");
			self.uzi_click = 0;
			if (self.BUTTON_USE) {
			  if (!autocvar_g_balance_uzi_suppressornotincluded
			  || self.inv_misc_suppressormac10)
			  {
				if (self.uzi_suppressed) {
					self.uzi_suppressed = 0;
					self.weaponname = "mac10_unsuppressed";
					self.weaponaltaim_use = 1;
					self.weaponaltaim = '35 -0.5 -2.8';
				} else if (!self.uzi_suppressed) {
					self.uzi_suppressed = 1;
					self.weaponname = "mac10_suppressed";
					self.weaponaltaim_use = 1;
					self.weaponaltaim = '50 -0.5 -2.7';
				}
			  }
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_uzi(float req)
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
			w_deathtypestring = _("%s was sniped by %s's machine gun");
		else
			w_deathtypestring = _("%s was riddled full of holes by %s's machine gun");
	}
	return TRUE;
}
#endif
#endif
