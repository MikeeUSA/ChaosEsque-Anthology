#ifdef REGISTER_WEAPON
REGISTER_WEAPON(BIGPISTOL, w_bigpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "45pistol", "bigpistol", _(".45 Pistol"))
#else
#ifdef SVQC

float autocvar_g_balance_bigpistol_skin;

.float bigpistol_release;
.float bigpistol_jammed;
.float bigpistol_unjam;
.float bigpistol_unjam_time;
.float bigpistol_click;
.float bigpistol_suppressed;
.float bigpistol_animempty;
.float bigpistol_animset;
.float bigpistol_nextanim;
.float bigpistol_nextbot;
.float bigpistol_gsetsuppressed; //For ground model setting propagation


float bigpistolautoskincolorset;
.float bigpistol_customskin;

void W_BigPistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_bigpistol_primary_ammo;
	d = autocvar_g_balance_bigpistol_primary_damage;
	f = autocvar_g_balance_bigpistol_primary_force;
	spread = autocvar_g_balance_bigpistol_primary_spread;
	bulletspeed = autocvar_g_balance_bigpistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_45acp_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_bigpistol_reload_ammo);
	
	if (autocvar_g_balance_bigpistol_jamrate &&
 	(autocvar_g_balance_bigpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your .45 jammed\n");
		}
		self.bigpistol_jammed = 1;
	} else { //Start Not Jammed

	if not(self.bigpistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire2_bass.wav", CH_WEAPON_A, d);
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
		spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	}
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_bigpistol_primary_headshotaddeddamage, f, WEP_BIGPISTOL, PROJECTILE_BULLET45ACP, 1, bulletconstant, autocvar_g_balance_bigpistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if not(self.bigpistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_bigpistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_bigpistol_gunrise, random() * autocvar_g_balance_bigpistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '1 0 0');
	} else {
		PlayerGunRise(self, autocvar_g_balance_bigpistol_suppressed_gunrise, random() * autocvar_g_balance_bigpistol_suppressed_gunrun);	
	}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 6, self);

	
	} //End Not Jammed
}


float W_BigPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_bigpistol_reload_ammo && self.clip_load < autocvar_g_balance_bigpistol_primary_ammo))
	{
		if (!self.bigpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.bigpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.bigpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_bigpistol (void)
{
	weapon_defaultspawnfunc(WEP_BIGPISTOL);
}


float w_bigpistol_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.bigpistol_customskin > 0)) {
		return player.bigpistol_customskin;
	} else if (autocvar_g_balance_bigpistol_skin == -1) {
	
		////Use the p90 code for figuring out what type of map it is
		//if not(bigpistolautoskincolorset) {
		//	bigpistolautoskincolorset = w_p90_skin_autocolorset();
		//}
		
		////Our skins are different numbers however, for snow, so we set below
		//if (bigpistolautoskincolorset == -10) {
		//	return 0;
		//} else if (bigpistolautoskincolorset == 1) {
		//	//Dust
		//	return 1;
		//} else if (bigpistolautoskincolorset == 4) {
		//	//Snow
		//	return 2;
		//} else {
			return 0;
		//}
	} else {
		return autocvar_g_balance_bigpistol_skin;
	}
}

void w_bigpistol_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.bigpistol_suppressed) {
		myself.model = "models/weapons/g_45pistol_suppressed.md3";
		
		if (autocvar_g_balance_bigpistol_suppressornotincluded
		&& player.inv_misc_suppressor45 >= 1) {
			player.inv_misc_suppressor45 = player.inv_misc_suppressor45 - 1;
			myself.inv_misc_suppressor45 = myself.inv_misc_suppressor45 + 1;
		}
		
		myself.bigpistol_gsetsuppressed = player.bigpistol_suppressed;
	} else {
		//Do nothing
		myself.bigpistol_gsetsuppressed = 0;
	}
}

void w_bigpistol_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_BIGPISTOL) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.bigpistol_suppressed = myself.bigpistol_gsetsuppressed;
		}
	}
}


.float bigpistol_primarytime;

float w_bigpistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_BigPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.bigpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.bigpistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_bigpistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_BigPistol_NeedManualReload())
	{
		if (self.bigpistol_suppressed) {
			if (!autocvar_g_balance_bigpistol_suppressornotincluded
			|| self.inv_misc_suppressor45)
			{
				//Nothing
			} else {
				self.bigpistol_suppressed = 0;
				self.bigpistol_animset = 1;
			}
		}
		
	
		if(autocvar_g_balance_bigpistol_reload_ammo && self.clip_load < autocvar_g_balance_bigpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty bigpistol if its melee attack is active
			if not(autocvar_g_balance_bigpistol_secondary && self.ammo_nails < autocvar_g_balance_bigpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.bigpistol_release = 0;
		}
		else
		{
		  if (self.bigpistol_jammed && self.bigpistol_unjam)
		  {
		  	if (time >= self.bigpistol_unjam_time) {
				self.bigpistol_jammed = 0;
				self.bigpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.bigpistol_release)
			if (self.bigpistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.bigpistol_nextbot)," \n");
				} else {
					self.bigpistol_nextbot = 0;
				}
				
				if (time >= self.bigpistol_nextbot) {
					W_BigPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_bigpistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_bigpistol_primary_animtime, w_ready);
					self.bigpistol_release = 0;
					self.bigpistol_animempty = 1;
					self.bigpistol_animset = 1;
					self.bigpistol_nextanim = time + autocvar_g_balance_bigpistol_primary_rfanim;
					bp_skipme = 1;
					//self.bigpistol_nextbot = time + (autocvar_g_balance_bigpistol_primary_refire * 50 * random());
					self.bigpistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_bigpistol_fullauto == 1) {
						self.bigpistol_release = 1;
						self.bigpistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.bigpistol_jammed != 1)
				if (time >= self.bigpistol_nextanim)
				if (self.bigpistol_animempty)
				{
					self.bigpistol_animempty = 0;
					self.bigpistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.bigpistol_release = 1;
			}
				
			if (self.bigpistol_animset)
			if (self.bigpistol_jammed != 1) {
				if (self.bigpistol_suppressed) {
					if (self.bigpistol_animempty)
						self.weaponname = "45pistol_suppressed_empty";
					else
						self.weaponname = "45pistol_suppressed";
				} else if (!self.bigpistol_suppressed) {
					if (self.bigpistol_animempty)
						self.weaponname = "45pistol_empty";
					else
						self.weaponname = "45pistol";
				}
			}
			
			self.bigpistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_45pistol.md3");
		precache_model ("models/weapons/v_45pistol.md3");
		precache_model ("models/weapons/g_45pistol_suppressed.md3");
		precache_model ("models/weapons/v_45pistol_suppressed.md3");
		precache_model ("models/weapons/h_45pistol.iqm");
		precache_model ("models/weapons/h_45pistol_suppressed.iqm");
		
		precache_model ("models/weapons/v_45pistol_empty.md3");
		precache_model ("models/weapons/v_45pistol_suppressed_empty.md3");
		precache_model ("models/weapons/h_45pistol_empty.iqm");
		precache_model ("models/weapons/h_45pistol_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire2_bass.wav");
		precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -1';
			
		weapon_setup(WEP_BIGPISTOL);
		self.current_ammo = ammo_nails;
		
		if (!autocvar_g_balance_bigpistol_suppressornotincluded
		|| self.inv_misc_suppressor45)
		{
			if (self.bigpistol_suppressed) {
				if (self.bigpistol_animempty)
					self.weaponname = "45pistol_suppressed_empty";
				else
					self.weaponname = "45pistol_suppressed";
			} else if (!self.bigpistol_suppressed) {
				if (self.bigpistol_animempty)
					self.weaponname = "45pistol_empty";
				else
					self.weaponname = "45pistol";
			}
		} else {
			self.bigpistol_suppressed = 0;
			
			if (self.bigpistol_animempty)
				self.weaponname = "45pistol_empty";
			else
				self.weaponname = "45pistol";
		}
		
		
		  if (self.bigpistol_jammed && self.bigpistol_unjam)
		  {
		  	if (time >= self.bigpistol_unjam_time) {
				self.bigpistol_jammed = 0;
				self.bigpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_bigpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_BIGPISTOL]) >= autocvar_g_balance_bigpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.bigpistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_bigpistol_clearjam_time, w_ready);
			if (self.bigpistol_unjam != 1) {
				self.bigpistol_unjam = 1;
				self.bigpistol_unjam_time = time + autocvar_g_balance_bigpistol_clearjam_time;
				self.bigpistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_bigpistol_primary_ammo, autocvar_g_balance_bigpistol_reload_ammo, autocvar_g_balance_bigpistol_reload_time, "weapons/reload.wav");
			
			if (self.BUTTON_USE) {
			  if (!autocvar_g_balance_bigpistol_suppressornotincluded
			  || self.inv_misc_suppressor45)
			  {
				if (self.bigpistol_suppressed) {
					self.bigpistol_suppressed = 0;
					if (self.bigpistol_animempty)
						self.weaponname = "45pistol_empty";
					else
						self.weaponname = "45pistol";
				} else if (!self.bigpistol_suppressed) {
					self.bigpistol_suppressed = 1;
					if (self.bigpistol_animempty)
						self.weaponname = "45pistol_suppressed_empty";
					else
						self.weaponname = "45pistol_suppressed";
				}
			  }
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_bigpistol(float req)
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
			w_deathtypestring = _("%1$s did not live long once %2$s placed a .45 slug in their chest");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s punched them in the head with a bullet");
		else
			w_deathtypestring = _("%s was shot down by %s's 45");
	}
	return TRUE;
}
#endif
#endif
