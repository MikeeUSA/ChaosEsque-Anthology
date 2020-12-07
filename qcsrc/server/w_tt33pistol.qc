#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TT33PISTOL, w_tt33pistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "tt33pistol", "tt33pistol", _("TT33 Pistol"))
#else
#ifdef SVQC

float autocvar_g_balance_tt33pistol_skin;

.float tt33pistol_release;
.float tt33pistol_jammed;
.float tt33pistol_unjam;
.float tt33pistol_unjam_time;
.float tt33pistol_click;
.float tt33pistol_animempty;
.float tt33pistol_animset;
.float tt33pistol_nextanim;
.float tt33pistol_nextbot;

float tt33pistolautoskincolorset;
.float tt33pistol_customskin;

void W_Tt33Pistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_tt33pistol_primary_ammo;
	d = autocvar_g_balance_tt33pistol_primary_damage;
	f = autocvar_g_balance_tt33pistol_primary_force;
	spread = autocvar_g_balance_tt33pistol_primary_spread;
	bulletspeed = autocvar_g_balance_tt33pistol_primary_speed;
	bulletconstant = autocvar_g_balance_tt33pistol_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_tt33pistol_reload_ammo);
	
	if (autocvar_g_balance_tt33pistol_jamrate &&
 	(autocvar_g_balance_tt33pistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your pistol jammed\n");
		}
		self.tt33pistol_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_tt33pistol_primary_headshotaddeddamage, f, WEP_TT33PISTOL, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_tt33pistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_tt33pistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_tt33pistol_gunrise, random() * autocvar_g_balance_tt33pistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '0.25 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 62, self);

	
	} //End Not Jammed
}


float W_Tt33Pistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_tt33pistol_reload_ammo && self.clip_load < autocvar_g_balance_tt33pistol_primary_ammo))
	{
		if (!self.tt33pistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.tt33pistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.tt33pistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_tt33pistol (void)
{
	weapon_defaultspawnfunc(WEP_TT33PISTOL);
}



float w_tt33pistol_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.tt33pistol_customskin > 0)) {
		return player.tt33pistol_customskin;
	} else if (autocvar_g_balance_tt33pistol_skin == -1) {
	
		////Use the p90 code for figuring out what type of map it is
		//if not(tt33pistolautoskincolorset) {
		//	tt33pistolautoskincolorset = w_p90_skin_autocolorset();
		//}
		
		////Our skins are different numbers however, for snow, so we set below
		//if (tt33pistolautoskincolorset == -10) {
		//	return 0;
		//} else if (tt33pistolautoskincolorset == 1) {
		//	//Dust
		//	return 1;
		//} else if (tt33pistolautoskincolorset == 4) {
		//	//Snow
		//	return 2;
		//} else {
			return 0;
		//}
	} else {
		return autocvar_g_balance_tt33pistol_skin;
	}
}




.float tt33pistol_primarytime;

float w_tt33pistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Tt33Pistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.tt33pistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.tt33pistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_tt33pistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Tt33Pistol_NeedManualReload())
	{
		if(autocvar_g_balance_tt33pistol_reload_ammo && self.clip_load < autocvar_g_balance_tt33pistol_primary_ammo) // forced reload
		{
			// don't force reload an empty tt33pistol if its melee attack is active
			if not(autocvar_g_balance_tt33pistol_secondary && self.ammo_nails < autocvar_g_balance_tt33pistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.tt33pistol_release = 0;
		}
		else
		{
		  if (self.tt33pistol_jammed && self.tt33pistol_unjam)
		  {
		  	if (time >= self.tt33pistol_unjam_time) {
				self.tt33pistol_jammed = 0;
				self.tt33pistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.tt33pistol_release)
			if (self.tt33pistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.tt33pistol_nextbot)," \n");
				} else {
					self.tt33pistol_nextbot = 0;
				}
				
				if (time >= self.tt33pistol_nextbot) {
					W_Tt33Pistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_tt33pistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tt33pistol_primary_animtime, w_ready);
					self.tt33pistol_release = 0;
					self.tt33pistol_animempty = 1;
					self.tt33pistol_animset = 1;
					self.tt33pistol_nextanim = time + autocvar_g_balance_tt33pistol_primary_rfanim;
					bp_skipme = 1;
					//self.tt33pistol_nextbot = time + (autocvar_g_balance_tt33pistol_primary_refire * 50 * random());
					self.tt33pistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_tt33pistol_fullauto == 1) {
						self.tt33pistol_release = 1;
						self.tt33pistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.tt33pistol_jammed != 1)
				if (time >= self.tt33pistol_nextanim)
				if (self.tt33pistol_animempty)
				{
					self.tt33pistol_animempty = 0;
					self.tt33pistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.tt33pistol_release = 1;
			}
				
			if (self.tt33pistol_animset)
			if (self.tt33pistol_jammed != 1) {
					if (self.tt33pistol_animempty)
						self.weaponname = "tt33pistol_empty";
					else
						self.weaponname = "tt33pistol";
			}
			
			self.tt33pistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_tt33pistol.md3");
		precache_model ("models/weapons/v_tt33pistol.md3");
		precache_model ("models/weapons/h_tt33pistol.iqm");
		
		precache_model ("models/weapons/v_tt33pistol_empty.md3");
		precache_model ("models/weapons/h_tt33pistol_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -0.9';
		weapon_setup(WEP_TT33PISTOL);
		self.current_ammo = ammo_nails;
		
			if (self.tt33pistol_animempty)
				self.weaponname = "tt33pistol_empty";
			else
				self.weaponname = "tt33pistol";
	
	
	
		  if (self.tt33pistol_jammed && self.tt33pistol_unjam)
		  {
		  	if (time >= self.tt33pistol_unjam_time) {
			if (random() > 0.75) {
				self.tt33pistol_jammed = 0;
				self.tt33pistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_tt33pistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TT33PISTOL]) >= autocvar_g_balance_tt33pistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.tt33pistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_tt33pistol_clearjam_time, w_ready);
			if (self.tt33pistol_unjam != 1) {
				self.tt33pistol_unjam = 1;
				self.tt33pistol_unjam_time = time + autocvar_g_balance_tt33pistol_clearjam_time;
				self.tt33pistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_tt33pistol_primary_ammo, autocvar_g_balance_tt33pistol_reload_ammo, autocvar_g_balance_tt33pistol_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_tt33pistol(float req)
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
			w_deathtypestring = _("%s chest was shot by %s gun");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was execute by %s with pistol");
		else
			w_deathtypestring = _("%s was given death by %s's Tokarev");
	}
	return TRUE;
}
#endif
#endif
