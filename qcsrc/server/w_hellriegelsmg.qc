#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HELLRIEGELSMG, w_hellriegelsmg, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "hellriegelsmg", "hellriegelsmg", _("Hellriegel SMG"))
#else
#ifdef SVQC
.float hellriegelsmg_jammed;
.float hellriegelsmg_unjam;
.float hellriegelsmg_unjam_time;
.float hellriegelsmg_click;
.float hellriegelsmg_triggerlag;
.float hellriegelsmg_triggerlag_time;
.float hellriegelsmg_triggerlag_button;

// weapon frames

float W_HellriegelSMG_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_hellriegelsmg_reload_ammo && self.clip_load < autocvar_g_balance_hellriegelsmg_sustained_ammo))
	{
		if (!self.hellriegelsmg_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
			self.hellriegelsmg_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.hellriegelsmg_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

void hellriegelsmg_fire_auto()
{
	float hellriegelsmg_spread;
	
	if (self.hellriegelsmg_jammed)
	{
		w_ready();
		return;
	}
	
	if(W_HellriegelSMG_NeedManualReload()) {
		w_ready();
		return;	
	}

	if (!self.BUTTON_ATCK && !self.hellriegelsmg_triggerlag_button)
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

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_hellriegelsmg_sustained_ammo, autocvar_g_balance_hellriegelsmg_reload_ammo);

	
	if(autocvar_g_balance_hellriegelsmg_jamrate &&
 	(autocvar_g_balance_hellriegelsmg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun has jammed\n");
		}
		self.hellriegelsmg_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_hellriegelsmg_speed >= autocvar_g_antilag_bullets, 0, "weapons/ffsl_wppq_fire.wav", CH_WEAPON_A, autocvar_g_balance_hellriegelsmg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	hellriegelsmg_spread = bound(autocvar_g_balance_hellriegelsmg_spread_min, autocvar_g_balance_hellriegelsmg_spread_min + (autocvar_g_balance_hellriegelsmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_hellriegelsmg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, hellriegelsmg_spread, autocvar_g_balance_hellriegelsmg_speed, 5, autocvar_g_balance_hellriegelsmg_sustained_damage, autocvar_g_balance_hellriegelsmg_sustained_headshotaddeddamage, autocvar_g_balance_hellriegelsmg_sustained_force, WEP_HELLRIEGELSMG, PROJECTILE_BULLET9MM, 1, autocvar_g_balance_hellriegelsmg_bulletconstant, autocvar_g_balance_hellriegelsmg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '-1 0 1.5');
	
	PlayerGunRise(self, autocvar_g_balance_hellriegelsmg_gunrise, random() * autocvar_g_balance_hellriegelsmg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing_Offset (((random () * -50 - 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 190) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 45, self, '0 3.5 3'); //back, side, updown

	} //End Not Jammed
	
	ATTACK_FINISHED(self) = time + autocvar_g_balance_hellriegelsmg_sustained_refire * W_WeaponRateFactor();
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_hellriegelsmg_sustained_refire, hellriegelsmg_fire_auto);
}

void spawnfunc_weapon_hellriegelsmg()
{    
	weapon_defaultspawnfunc(WEP_HELLRIEGELSMG);
}

float w_hellriegelsmg(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_HellriegelSMG_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.hellriegelsmg_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		if(vlen(self.origin-self.enemy.origin) < 3000 - bound(0, skill, 10) * 200)
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		else
		{
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_HellriegelSMG_NeedManualReload())
	{
		if(autocvar_g_balance_hellriegelsmg_reload_ammo && self.clip_load < autocvar_g_balance_hellriegelsmg_sustained_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);		
		else
		{
		  if (self.hellriegelsmg_jammed && self.hellriegelsmg_unjam)
		  {
		  	if (time >= self.hellriegelsmg_unjam_time) {
				self.hellriegelsmg_jammed = 0;
				self.hellriegelsmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {			
			if (self.BUTTON_ATCK || self.hellriegelsmg_triggerlag_button == 1)
			if (self.hellriegelsmg_jammed != 1)
			if (((time > self.hellriegelsmg_triggerlag_time) && self.hellriegelsmg_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack(0, 0))
			{
				self.hellriegelsmg_triggerlag = 1; //For openbolt trigger lag
				self.misc_bulletcounter = 0;
				hellriegelsmg_fire_auto();
			}
			
			
			//Openbolt trigger lag
			if (time > self.hellriegelsmg_triggerlag_time) {
				self.hellriegelsmg_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.hellriegelsmg_triggerlag)
			&& self.BUTTON_ATCK) {
				self.hellriegelsmg_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.hellriegelsmg_triggerlag = 1;
				self.hellriegelsmg_triggerlag_time = time + autocvar_g_balance_hellriegelsmg_sustained_refire * 0.5 * W_WeaponRateFactor(); //1/2 a cycle
			}
			//Openbolt trigger lag


			if not(self.BUTTON_ATCK) {
				if not(self.hellriegelsmg_triggerlag_button) {
					self.hellriegelsmg_triggerlag = 0; //For openbolt trigger lag
				}
			}
			
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_hellriegelsmg.md3");
		precache_model ("models/weapons/v_hellriegelsmg.md3");
		precache_model ("models/weapons/h_hellriegelsmg.iqm");
		precache_sound ("weapons/ffsl_wppq_fire.wav");		
	}
	else if (req == WR_SETUP)
	{
		self.hellriegelsmg_triggerlag_button = 0; //for openbolt trigger lag
		self.hellriegelsmg_triggerlag = 0; //for openbolt trigger lag
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '44 0.1 -5';
		//self.weaponaltaim = '54 -0.35 -2.95';
		//self.weaponaltaim = '47 -0.35 -5';
		//self.weaponaltaim = '50 -0.35 -4';
		//self.weaponaltaim = '52 -0.35 -4'; //too far to right
		//self.weaponaltaim = '52 0 -4'; //too far to left
		self.weaponaltaim = '52 -0.20 -4';
		weapon_setup(WEP_HELLRIEGELSMG);
		self.current_ammo = ammo_nails;
	
	
		  if (self.hellriegelsmg_jammed && self.hellriegelsmg_unjam)
		  {
		  	if (time >= self.hellriegelsmg_unjam_time) {
				self.hellriegelsmg_jammed = 0;
				self.hellriegelsmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hellriegelsmg_sustained_ammo;

		if(autocvar_g_balance_hellriegelsmg_reload_ammo)		
            ammo_amount += self.(weapon_load[WEP_HELLRIEGELSMG]) >= autocvar_g_balance_hellriegelsmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
        ammo_amount = self.ammo_nails >= autocvar_g_balance_hellriegelsmg_sustained_ammo;

		if(autocvar_g_balance_hellriegelsmg_reload_ammo)
            ammo_amount += self.(weapon_load[WEP_HELLRIEGELSMG]) >= autocvar_g_balance_hellriegelsmg_sustained_ammo;
		
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		self.hellriegelsmg_triggerlag_button = 0; //for openbolt triggerlag
		self.hellriegelsmg_triggerlag = 0; //for openbolt triggerlag
		
		if (self.hellriegelsmg_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_hellriegelsmg_clearjam_time, w_ready);
			if (self.hellriegelsmg_unjam != 1) {
				self.hellriegelsmg_unjam = 1;
				self.hellriegelsmg_unjam_time = time + autocvar_g_balance_hellriegelsmg_clearjam_time;
				self.hellriegelsmg_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_hellriegelsmg_sustained_ammo, autocvar_g_balance_hellriegelsmg_reload_ammo, autocvar_g_balance_hellriegelsmg_reload_time, "weapons/reload.wav");
			self.hellriegelsmg_click = 0;
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_hellriegelsmg(float req)
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
			w_deathtypestring = _("%s was sniped by %s's heavy submachine gun");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s was ripped through the heart and lungs by %s's heavy submachine gun");
		else
			w_deathtypestring = _("%s torn to bits by %s's heavy submachine gun");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_hellriegelsmg()
//{    
//	weapon_defaultspawnfunc(WEP_HELLRIEGELSMG);
//}
