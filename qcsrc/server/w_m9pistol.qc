#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M9PISTOL, w_m9pistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m9pistol", "m9pistol", _("M9 Pistol"))
#else
#ifdef SVQC

.float m9pistol_release;
.float m9pistol_jammed;
.float m9pistol_unjam;
.float m9pistol_unjam_time;
.float m9pistol_click;
//.float m9pistol_suppressed;
.float m9pistol_animempty;
.float m9pistol_animset;
.float m9pistol_nextanim;
.float m9pistol_nextbot;

void W_M9Pistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m9pistol_primary_ammo;
	d = autocvar_g_balance_m9pistol_primary_damage;
	f = autocvar_g_balance_m9pistol_primary_force;
	spread = autocvar_g_balance_m9pistol_primary_spread;
	bulletspeed = autocvar_g_balance_m9pistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_9mm_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m9pistol_reload_ammo);
	
	if (autocvar_g_balance_m9pistol_jamrate &&
 	(autocvar_g_balance_m9pistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your 9mm pistol jammed\n");
		}
		self.m9pistol_jammed = 1;
	} else { //Start Not Jammed

	//if not(self.m9pistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/futuristic_smg_single_shot.wav", CH_WEAPON_A, d);
	//} else {
	//	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
	//	spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	//}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m9pistol_primary_headshotaddeddamage, f, WEP_M9PISTOL, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_m9pistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	//if not(self.m9pistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m9pistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m9pistol_gunrise, random() * autocvar_g_balance_m9pistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '1.00 0 0');
	//} else {
	//	PlayerGunRise(self, autocvar_g_balance_m9pistol_suppressed_gunrise, random() * autocvar_g_balance_m9pistol_suppressed_gunrun);	
	//}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	} //End Not Jammed
}


float W_M9Pistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m9pistol_reload_ammo && self.clip_load < autocvar_g_balance_m9pistol_primary_ammo))
	{
		if (!self.m9pistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m9pistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m9pistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_m9pistol (void)
{
	weapon_defaultspawnfunc(WEP_M9PISTOL);
}


.float m9pistol_primarytime;

float w_m9pistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M9Pistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m9pistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.m9pistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m9pistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_M9Pistol_NeedManualReload())
	{
		//if (self.m9pistol_suppressed) {
		//	if (!autocvar_g_balance_m9pistol_suppressornotincluded
		//	|| self.inv_misc_suppressor9mm)
		//	{
		//		//Nothing
		//	} else {
		//		self.m9pistol_suppressed = 0;
		//		self.m9pistol_animset = 1;
		//	}
		//}
	
	
	
		if(autocvar_g_balance_m9pistol_reload_ammo && self.clip_load < autocvar_g_balance_m9pistol_primary_ammo) // forced reload
		{
			// don't force reload an empty m9pistol if its melee attack is active
			if not(autocvar_g_balance_m9pistol_secondary && self.ammo_nails < autocvar_g_balance_m9pistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m9pistol_release = 0;
		}
		else
		{
		  if (self.m9pistol_jammed && self.m9pistol_unjam)
		  {
		  	if (time >= self.m9pistol_unjam_time) {
				self.m9pistol_jammed = 0;
				self.m9pistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.m9pistol_release)
			if (self.m9pistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m9pistol_nextbot)," \n");
				} else {
					self.m9pistol_nextbot = 0;
				}
				
				if (time >= self.m9pistol_nextbot) {
					W_M9Pistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m9pistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m9pistol_primary_animtime, w_ready);
					self.m9pistol_release = 0;
					self.m9pistol_animempty = 1;
					self.m9pistol_animset = 1;
					self.m9pistol_nextanim = time + autocvar_g_balance_m9pistol_primary_rfanim;
					bp_skipme = 1;
					//self.m9pistol_nextbot = time + (autocvar_g_balance_m9pistol_primary_refire * 50 * random());
					self.m9pistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_m9pistol_fullauto == 1) {
						self.m9pistol_release = 1;
						self.m9pistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.m9pistol_jammed != 1)
				if (time >= self.m9pistol_nextanim)
				if (self.m9pistol_animempty)
				{
					self.m9pistol_animempty = 0;
					self.m9pistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.m9pistol_release = 1;
			}
				
			if (self.m9pistol_animset)
			if (self.m9pistol_jammed != 1) {
				//if (self.m9pistol_suppressed) {
				//	if (self.m9pistol_animempty)
				//		self.weaponname = "m9pistol_suppressed_empty";
				//	else
				//		self.weaponname = "m9pistol_suppressed";
				//} else if (!self.m9pistol_suppressed) {
					if (self.m9pistol_animempty)
						self.weaponname = "m9pistol_empty";
					else
						self.weaponname = "m9pistol";
				//}
			}
			
			self.m9pistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m9pistol.md3");
		precache_model ("models/weapons/v_m9pistol.md3");
		//precache_model ("models/weapons/g_m9pistol_suppressed.md3");
		//precache_model ("models/weapons/v_m9pistol_suppressed.md3");
		precache_model ("models/weapons/h_m9pistol.iqm");
		//precache_model ("models/weapons/h_m9pistol_suppressed.iqm");
		
		precache_model ("models/weapons/v_m9pistol_empty.md3");
		//precache_model ("models/weapons/v_m9pistol_suppressed_empty.md3");
		precache_model ("models/weapons/h_m9pistol_empty.iqm");
		//precache_model ("models/weapons/h_m9pistol_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/futuristic_smg_single_shot.wav");
		//precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -0.9';
			
		weapon_setup(WEP_M9PISTOL);
		self.current_ammo = ammo_nails;
		
		//if (!autocvar_g_balance_m9pistol_suppressornotincluded
		//|| self.inv_misc_suppressor9mm)
		//{
		//	if (self.m9pistol_suppressed) {
		//		if (self.m9pistol_animempty)
		//			self.weaponname = "m9pistol_suppressed_empty";
		//		else
		//			self.weaponname = "m9pistol_suppressed";
		//	} else if (!self.m9pistol_suppressed) {
		//		if (self.m9pistol_animempty)
		//			self.weaponname = "m9pistol_empty";
		//		else
		//			self.weaponname = "m9pistol";
		//	}
		//} else {
		//	self.m9pistol_suppressed = 0;
			
			if (self.m9pistol_animempty)
				self.weaponname = "m9pistol_empty";
			else
				self.weaponname = "m9pistol";
		//}
		
		
		
		
		  if (self.m9pistol_jammed && self.m9pistol_unjam)
		  {
		  	if (time >= self.m9pistol_unjam_time) {
			if (random() > 0.75) {
				self.m9pistol_jammed = 0;
				self.m9pistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m9pistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M9PISTOL]) >= autocvar_g_balance_m9pistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m9pistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m9pistol_clearjam_time, w_ready);
			if (self.m9pistol_unjam != 1) {
				self.m9pistol_unjam = 1;
				self.m9pistol_unjam_time = time + autocvar_g_balance_m9pistol_clearjam_time;
				self.m9pistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_m9pistol_primary_ammo, autocvar_g_balance_m9pistol_reload_ammo, autocvar_g_balance_m9pistol_reload_time, "weapons/reload.wav");
			
			//if (self.BUTTON_USE) {
			//  if (!autocvar_g_balance_m9pistol_suppressornotincluded
			//  || self.inv_misc_suppressor9mm)
			//  {
			//	if (self.m9pistol_suppressed) {
			//		self.m9pistol_suppressed = 0;
			//		if (self.m9pistol_animempty)
			//			self.weaponname = "m9pistol_empty";
			//		else
			//			self.weaponname = "m9pistol";
			//	} else if (!self.m9pistol_suppressed) {
			//		self.m9pistol_suppressed = 1;
			//		if (self.m9pistol_animempty)
			//			self.weaponname = "m9pistol_suppressed_empty";
			//		else
			//			self.weaponname = "m9pistol_suppressed";
			//	}
			// }
			//}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m9pistol(float req)
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
			w_deathtypestring = _("%1$s chest was pierced by bullets from %2$s pistol");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s pistol placed a bullet in their head");
		else
			w_deathtypestring = _("%s was killed by %s's M9 pistol");
	}
	return TRUE;
}
#endif
#endif
