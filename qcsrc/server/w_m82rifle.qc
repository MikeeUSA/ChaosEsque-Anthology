#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M82RIFLE, w_m82rifle, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m82rifle", "m82rifle", _("M82 Rifle"))
#else
#ifdef SVQC

float autocvar_g_balance_m82rifle_skin;

.float m82rifle_release;
.float m82rifle_jammed;
.float m82rifle_unjam;
.float m82rifle_unjam_time;
.float m82rifle_click;
.float m82rifle_animempty;
.float m82rifle_animset;
.float m82rifle_nextanim;
.float m82rifle_nextbot;

float m82rifleautoskincolorset;
.float m82rifle_customskin;

void W_M82Rifle_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m82rifle_primary_ammo;
	d = autocvar_g_balance_m82rifle_primary_damage;
	f = autocvar_g_balance_m82rifle_primary_force;
	//spread = autocvar_g_balance_m82rifle_primary_spread;
	spread = bound(autocvar_g_balance_m82rifle_spread_min, autocvar_g_balance_m82rifle_spread_min + (autocvar_g_balance_m82rifle_spread_add * self.misc_bulletcounter), autocvar_g_balance_m82rifle_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_m82rifle_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_50bmgrifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m82rifle_reload_ammo);
	
	if (autocvar_g_balance_m82rifle_jamrate &&
 	(autocvar_g_balance_m82rifle_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle jammed\n");
		}
		self.m82rifle_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire_morebass.wav", CH_WEAPON_A, d);
	
	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m82rifle_primary_headshotaddeddamage, f, WEP_M82RIFLE, PROJECTILE_BULLETRIFLE50S, 1, bulletconstant, autocvar_g_balance_m82rifle_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		//if (self.misc_bulletcounter) {
		////If we've been shooting full auto, shake things around
		self.punchangle_x = (random () - 0.5)*2;
		self.punchangle_y = (random () - 0.5)*2;
		self.punchangle_z = (random () - 0.5)*2;
		//}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m82rifle_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m82rifle_gunrise, random() * autocvar_g_balance_m82rifle_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '27 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 107, self);

	
	} //End Not Jammed
}


float W_M82Rifle_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m82rifle_reload_ammo && self.clip_load < autocvar_g_balance_m82rifle_primary_ammo))
	{
		if (!self.m82rifle_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m82rifle_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m82rifle_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_m82rifle (void)
{
	weapon_defaultspawnfunc(WEP_M82RIFLE);
}

float w_m82rifle_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.m82rifle_customskin > 0)) {
		return player.m82rifle_customskin;
	} else if (autocvar_g_balance_m82rifle_skin == -1) {
	
		//Use the p90 code for figuring out what type of map it is
		if not(m82rifleautoskincolorset) {
			m82rifleautoskincolorset = w_p90_skin_autocolorset();
		}
		
		//Our skins are different numbers however, for snow, so we set below
		if (m82rifleautoskincolorset == -10) {
			return 0;
		} else if (m82rifleautoskincolorset == 1) {
			//Dust
			return 1;
		} else if (m82rifleautoskincolorset == 4) {
			//Snow
			return 2;
		} else {
			return 0;
		}
	} else {
		return autocvar_g_balance_m82rifle_skin;
	}
}


.float m82rifle_primarytime;

float w_m82rifle(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M82Rifle_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m82rifle_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.m82rifle_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m82rifle_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_M82Rifle_NeedManualReload())
	{
		if(autocvar_g_balance_m82rifle_reload_ammo && self.clip_load < autocvar_g_balance_m82rifle_primary_ammo) // forced reload
		{
			// don't force reload an empty m82rifle if its melee attack is active
			if not(autocvar_g_balance_m82rifle_secondary && self.ammo_nails < autocvar_g_balance_m82rifle_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m82rifle_release = 0;
		}
		else
		{
		  if (self.m82rifle_jammed && self.m82rifle_unjam)
		  {
		  	if (time >= self.m82rifle_unjam_time) {
				self.m82rifle_jammed = 0;
				self.m82rifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			//float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.m82rifle_release)
			if (self.m82rifle_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
			
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m82rifle_nextbot)," \n");
				} else {
					self.m82rifle_nextbot = 0;
				}
				
				if (time >= self.m82rifle_nextbot) {
					W_M82Rifle_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m82rifle_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m82rifle_primary_animtime, w_ready);
					self.m82rifle_release = 0;
					self.m82rifle_animempty = 1;
					self.m82rifle_animset = 1;
					self.m82rifle_nextanim = time + autocvar_g_balance_m82rifle_primary_rfanim;
					//bp_skipme = 1;
					//self.m82rifle_nextbot = time + (autocvar_g_balance_m82rifle_primary_refire * 50 * random());
					self.m82rifle_nextbot = time + 0.1 + (0.4 * random());
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.m82rifle_release)
			if (self.m82rifle_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.m82rifle_release = 0;
			}
			
			//if not(bp_skipme) {
			//	if (self.m82rifle_jammed != 1)
			//	if (time >= self.m82rifle_nextanim)
			//	if (self.m82rifle_animempty)
			//	{
			//		self.m82rifle_animempty = 0;
			//		self.m82rifle_animset = 1;
			//	}
			//}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m82rifle_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.m82rifle_animset)
			//if (self.m82rifle_jammed != 1) {
			//	
			//		if (self.m82rifle_animempty)
			//			self.weaponname = "m82rifle_empty";
			//		else
			//			self.weaponname = "m82rifle";
			//}
			
			//self.m82rifle_animset = 0;
			//bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m82rifle.md3");
		precache_model ("models/weapons/v_m82rifle.md3");
		precache_model ("models/weapons/h_m82rifle.iqm");
		
		//precache_model ("models/weapons/v_m82rifle_empty.md3");
		//precache_model ("models/weapons/h_m82rifle_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire_morebass.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//////self.weaponaltaim = '43 0.02 -10.0';
		//////self.weaponaltaim = '50 0.02 -7.0';
		//self.weaponaltaim = '50 0.02 -7.0';
		//////self.weaponaltaim = '50 0.02 -6.0';
		//////self.weaponaltaim = '43 0.02 -5.0';
		
		//self.weaponaltaim = '54 0.02 -5.0';
		//self.weaponaltaim = '54 0.02 -5.25';
		//self.weaponaltaim = '54 0.02 -5.35';
		//self.weaponaltaim = '54 0.02 -5.45';
		self.weaponaltaim = '54 0.02 -6.35';
		weapon_setup(WEP_M82RIFLE);
		self.current_ammo = ammo_nails;
		
		
			//if (self.m82rifle_animempty)
			//	self.weaponname = "m82rifle_empty";
			//else
			//	self.weaponname = "m82rifle";
				
	
	
		  if (self.m82rifle_jammed && self.m82rifle_unjam)
		  {
		  	if (time >= self.m82rifle_unjam_time) {
				self.m82rifle_jammed = 0;
				self.m82rifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m82rifle_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M82RIFLE]) >= autocvar_g_balance_m82rifle_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m82rifle_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m82rifle_clearjam_time, w_ready);
			if (self.m82rifle_unjam != 1) {
				self.m82rifle_unjam = 1;
				self.m82rifle_unjam_time = time + autocvar_g_balance_m82rifle_clearjam_time;
				self.m82rifle_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_m82rifle_primary_ammo, autocvar_g_balance_m82rifle_reload_ammo, autocvar_g_balance_m82rifle_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m82rifle(float req)
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
			w_deathtypestring = _("%1$s chest was materially altered by %2$s M82");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was taken out by %2$s well placed .50 bmg round");
		else
			w_deathtypestring = _("%s tried to argue with %s's light-fifty");
	}
	return TRUE;
}
#endif
#endif
