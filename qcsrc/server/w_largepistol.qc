#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LARGEPISTOL, w_largepistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "largepistol", "largepistol", _(".50 Pistol"))
#else
#ifdef SVQC

float autocvar_g_balance_largepistol_skin;

.float largepistol_release;
.float largepistol_jammed;
.float largepistol_unjam;
.float largepistol_unjam_time;
.float largepistol_click;
.float largepistol_suppressed;
.float largepistol_animempty;
.float largepistol_animset;
.float largepistol_nextanim;
.float largepistol_nextbot;

float largepistolautoskincolorset;
.float largepistol_customskin;

void W_LargePistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_largepistol_primary_ammo;
	d = autocvar_g_balance_largepistol_primary_damage;
	f = autocvar_g_balance_largepistol_primary_force;
	spread = autocvar_g_balance_largepistol_primary_spread;
	bulletspeed = autocvar_g_balance_largepistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_50ae_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_largepistol_reload_ammo);
	
	if (autocvar_g_balance_largepistol_jamrate &&
 	(autocvar_g_balance_largepistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your .50 jammed\n");
		}
		self.largepistol_jammed = 1;
	} else { //Start Not Jammed

	if not(self.largepistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire3_bass.wav", CH_WEAPON_A, d);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_largepistol_primary_headshotaddeddamage, f, WEP_LARGEPISTOL, PROJECTILE_BULLET50AE, 1, bulletconstant, autocvar_g_balance_largepistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.largepistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_largepistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_largepistol_gunrise, random() * autocvar_g_balance_largepistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '4 0 0');
	} else {
		PlayerGunRise(self, autocvar_g_balance_largepistol_suppressed_gunrise, random() * autocvar_g_balance_largepistol_suppressed_gunrun);	
	}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 47, self);

	
	} //End Not Jammed
}


float W_LargePistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_largepistol_reload_ammo && self.clip_load < autocvar_g_balance_largepistol_primary_ammo))
	{
		if (!self.largepistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.largepistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.largepistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_largepistol (void)
{
	weapon_defaultspawnfunc(WEP_LARGEPISTOL);
}

float w_largepistol_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.largepistol_customskin > 0)) {
		return player.largepistol_customskin;
	} else if (autocvar_g_balance_largepistol_skin == -1) {
	
		////Use the p90 code for figuring out what type of map it is
		//if not(largepistolautoskincolorset) {
		//	largepistolautoskincolorset = w_p90_skin_autocolorset();
		//}
		
		////Our skins are different numbers however, for snow, so we set below
		//if (largepistolautoskincolorset == -10) {
		//	return 0;
		//} else if (largepistolautoskincolorset == 1) {
		//	//Dust
		//	return 1;
		//} else if (largepistolautoskincolorset == 4) {
		//	//Snow
		//	return 2;
		//} else {
			return 0;
		//}
	} else {
		return autocvar_g_balance_largepistol_skin;
	}
}




.float largepistol_primarytime;

float w_largepistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_LargePistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.largepistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.largepistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_largepistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_LargePistol_NeedManualReload())
	{
		if(autocvar_g_balance_largepistol_reload_ammo && self.clip_load < autocvar_g_balance_largepistol_primary_ammo) // forced reload
		{
			// don't force reload an empty largepistol if its melee attack is active
			if not(autocvar_g_balance_largepistol_secondary && self.ammo_nails < autocvar_g_balance_largepistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.largepistol_release = 0;
		}
		else
		{
		  if (self.largepistol_jammed && self.largepistol_unjam)
		  {
		  	if (time >= self.largepistol_unjam_time) {
				self.largepistol_jammed = 0;
				self.largepistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.largepistol_release)
			if (self.largepistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.largepistol_nextbot)," \n");
				} else {
					self.largepistol_nextbot = 0;
				}
				
				if (time >= self.largepistol_nextbot) {
					W_LargePistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_largepistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_largepistol_primary_animtime, w_ready);
					self.largepistol_release = 0;
					self.largepistol_animempty = 1;
					self.largepistol_animset = 1;
					self.largepistol_nextanim = time + autocvar_g_balance_largepistol_primary_rfanim;
					bp_skipme = 1;
					//self.largepistol_nextbot = time + (autocvar_g_balance_largepistol_primary_refire * 50 * random());
					self.largepistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_largepistol_fullauto == 1) {
						self.largepistol_release = 1;
						self.largepistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.largepistol_jammed != 1)
				if (time >= self.largepistol_nextanim)
				if (self.largepistol_animempty)
				{
					self.largepistol_animempty = 0;
					self.largepistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.largepistol_release = 1;
			}
				
			if (self.largepistol_animset)
			if (self.largepistol_jammed != 1) {
				if (self.largepistol_suppressed) {
					if (self.largepistol_animempty)
						self.weaponname = "largepistol_suppressed_empty";
					else
						self.weaponname = "largepistol_suppressed";
				} else if (!self.largepistol_suppressed) {
					if (self.largepistol_animempty)
						self.weaponname = "largepistol_empty";
					else
						self.weaponname = "largepistol";
				}
			}
			
			self.largepistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_largepistol.md3");
		precache_model ("models/weapons/v_largepistol.md3");
		//precache_model ("models/weapons/g_largepistol_suppressed.md3");
		//precache_model ("models/weapons/v_largepistol_suppressed.md3");
		precache_model ("models/weapons/h_largepistol.iqm");
		//precache_model ("models/weapons/h_largepistol_suppressed.iqm");
		
		precache_model ("models/weapons/v_largepistol_empty.md3");
		//precache_model ("models/weapons/v_largepistol_suppressed_empty.md3");
		precache_model ("models/weapons/h_largepistol_empty.iqm");
		//precache_model ("models/weapons/h_largepistol_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire3_bass.wav");
		//precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LARGEPISTOL);
		self.current_ammo = ammo_nails;
		
		if (self.largepistol_suppressed) {
			if (self.largepistol_animempty)
				self.weaponname = "largepistol_suppressed_empty";
			else
				self.weaponname = "largepistol_suppressed";
		} else if (!self.largepistol_suppressed) {
			self.weaponaltaim_use = 1;
			self.weaponaltaim = '40 -0.35 -1.2';
		
			if (self.largepistol_animempty)
				self.weaponname = "largepistol_empty";
			else
				self.weaponname = "largepistol";
		}
		
		
		  if (self.largepistol_jammed && self.largepistol_unjam)
		  {
		  	if (time >= self.largepistol_unjam_time) {
				self.largepistol_jammed = 0;
				self.largepistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_largepistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LARGEPISTOL]) >= autocvar_g_balance_largepistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.largepistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_largepistol_clearjam_time, w_ready);
			if (self.largepistol_unjam != 1) {
				self.largepistol_unjam = 1;
				self.largepistol_unjam_time = time + autocvar_g_balance_largepistol_clearjam_time;
				self.largepistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_largepistol_primary_ammo, autocvar_g_balance_largepistol_reload_ammo, autocvar_g_balance_largepistol_reload_time, "weapons/reload.wav");
			
			//if (self.BUTTON_USE) {
			//	if (self.largepistol_suppressed) {
			//		self.largepistol_suppressed = 0;
			//		if (self.largepistol_animempty)
			//			self.weaponname = "largepistol_empty";
			//		else
			//			self.weaponname = "largepistol";
			//	} else if (!self.largepistol_suppressed) {
			//		self.largepistol_suppressed = 1;
			//		if (self.largepistol_animempty)
			//			self.weaponname = "largepistol_suppressed_empty";
			//		else
			//			self.weaponname = "largepistol_suppressed";
			//	}
			//}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_largepistol(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("medbullet_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s did not live long once %2$s placed a .50 slug in their chest");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s hammered them in the head with a bullet");
		else
			w_deathtypestring = _("%s was shot down by %s's .50 pistol");
	}
	return TRUE;
}
#endif
#endif
