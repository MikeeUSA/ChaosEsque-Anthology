#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M93RPISTOL, w_m93rpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m93rpistol", "m93rpistol", _("93R Pistol"))
#else
#ifdef SVQC

.float m93rpistol_release;
.float m93rpistol_jammed;
.float m93rpistol_unjam;
.float m93rpistol_unjam_time;
.float m93rpistol_click;
//////.float m93rpistol_suppressed;
.float m93rpistol_animempty;
.float m93rpistol_animset;
.float m93rpistol_nextanim;
.float m93rpistol_nextbot;
.float m93rpistol_overheat_cnt;
.float m93rpistol_overheated_until;
.float m93rpistol_burstcount;
float autocvar_g_balance_m93rpistol_primary_burstamnt;

void W_M93RPistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m93rpistol_primary_ammo;
	d = autocvar_g_balance_m93rpistol_primary_damage;
	f = autocvar_g_balance_m93rpistol_primary_force;
	//spread = autocvar_g_balance_m93rpistol_primary_spread;
	spread = bound(autocvar_g_balance_m93rpistol_spread_min, autocvar_g_balance_m93rpistol_spread_min + (autocvar_g_balance_m93rpistol_spread_add * self.misc_bulletcounter), autocvar_g_balance_m93rpistol_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_m93rpistol_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_9mm_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m93rpistol_reload_ammo);
	
	if (autocvar_g_balance_m93rpistol_jamrate &&
 	(autocvar_g_balance_m93rpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your 9mm jammed\n");
		}
		self.m93rpistol_jammed = 1;
	} else { //Start Not Jammed

	//if not(self.m93rpistol_suppressed) {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/futuristic_smg_single_shot.wav", CH_WEAPON_A, d);
	//} else {
	//	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_doublesuppressed.wav", CH_WEAPON_A, d);
	//	spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.23, ATTN_NORM);
	//}

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m93rpistol_primary_headshotaddeddamage, f, WEP_M93RPISTOL, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_m93rpistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	//if not(self.m93rpistol_suppressed) {	
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m93rpistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m93rpistol_gunrise, random() * autocvar_g_balance_m93rpistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '1.00 0 0');
	//} else {
	//	PlayerGunRise(self, autocvar_g_balance_m93rpistol_suppressed_gunrise, random() * autocvar_g_balance_m93rpistol_suppressed_gunrun);	
	//}
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.m93rpistol_overheat_cnt),"_Firing\n");
		
	    	self.m93rpistol_overheat_cnt = self.m93rpistol_overheat_cnt + autocvar_g_balance_m93rpistol_heatconstant;
         
	    	if (self.m93rpistol_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your automatic pistol overheated\n");
			}
				
			self.m93rpistol_overheated_until = time + (autocvar_g_balance_m93rpistol_cooldownwait * (self.m93rpistol_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_M93RPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m93rpistol_reload_ammo && self.clip_load < autocvar_g_balance_m93rpistol_primary_ammo))
	{
		if (!self.m93rpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m93rpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m93rpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_m93rpistol (void)
{
	weapon_defaultspawnfunc(WEP_M93RPISTOL);
}


.float m93rpistol_primarytime;

float w_m93rpistol(float req)
{
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.m93rpistol_overheat_cnt),"_Cooldown\n");
			
			if (self.m93rpistol_overheat_cnt < autocvar_g_balance_m93rpistol_heatmin) {
				self.m93rpistol_overheat_cnt = autocvar_g_balance_m93rpistol_heatmin;
			} else {
				self.m93rpistol_overheat_cnt = self.m93rpistol_overheat_cnt - (autocvar_g_balance_m93rpistol_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M93RPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m93rpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (autocvar_g_balance_m93rpistol_primary_burstamnt &&
		(self.m93rpistol_burstcount >= autocvar_g_balance_m93rpistol_primary_burstamnt)) {
			self.m93rpistol_nextbot = time + 0.1 + (0.4 * random());
		} else {
		
			if (self.m93rpistol_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m93rpistol_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_M93RPistol_NeedManualReload())
	{
		//if (self.m93rpistol_suppressed) {
		//	if (!autocvar_g_balance_m93rpistol_suppressornotincluded
		//	|| self.inv_misc_suppressor9mm)
		//	{
		//		//Nothing
		//	} else {
		//		self.m93rpistol_suppressed = 0;
		//		self.m93rpistol_animset = 1;
		//	}
		//}
	
	
	
		if(autocvar_g_balance_m93rpistol_reload_ammo && self.clip_load < autocvar_g_balance_m93rpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty m93rpistol if its melee attack is active
			if not(autocvar_g_balance_m93rpistol_secondary && self.ammo_nails < autocvar_g_balance_m93rpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m93rpistol_release = 0;
		}
		else
		{
		  if (self.m93rpistol_jammed && self.m93rpistol_unjam)
		  {
		  	if (time >= self.m93rpistol_unjam_time) {
				self.m93rpistol_jammed = 0;
				self.m93rpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.m93rpistol_release)
			if (self.m93rpistol_jammed != 1)
			if ((time > self.m93rpistol_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m93rpistol_nextbot)," \n");
				} else {
					self.m93rpistol_nextbot = 0;
				}
				
				if (time >= self.m93rpistol_nextbot) {
				if (!autocvar_g_balance_m93rpistol_primary_burstamnt ||
				(self.m93rpistol_burstcount < autocvar_g_balance_m93rpistol_primary_burstamnt)) {
					W_M93RPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m93rpistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m93rpistol_primary_animtime, w_ready);
					self.m93rpistol_release = 0;
					self.m93rpistol_animempty = 1;
					self.m93rpistol_animset = 1;
					self.m93rpistol_nextanim = time + autocvar_g_balance_m93rpistol_primary_rfanim;
					bp_skipme = 1;
					//self.m93rpistol_nextbot = time + (autocvar_g_balance_m93rpistol_primary_refire * 50 * random());
					self.m93rpistol_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.m93rpistol_release = 1;
					self.m93rpistol_nextbot = time;
					self.m93rpistol_burstcount = self.m93rpistol_burstcount + 1;
				}
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.m93rpistol_release)
			if (self.m93rpistol_jammed != 1)
			if ((time > self.m93rpistol_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m93rpistol_nextbot)," \n");
				} else {
					self.m93rpistol_nextbot = 0;
				}
				
				if (time >= self.m93rpistol_nextbot) {
					W_M93RPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m93rpistol_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m93rpistol_secondary_animtime, w_ready);
					self.m93rpistol_release = 0;
					self.m93rpistol_animempty = 1;
					self.m93rpistol_animset = 1;
					self.m93rpistol_nextanim = time + autocvar_g_balance_m93rpistol_secondary_rfanim;
					bp_skipme = 1;
					//self.m93rpistol_nextbot = time + (autocvar_g_balance_m93rpistol_secondary_refire * 50 * random());
					self.m93rpistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_m93rpistol_fullauto == 1) {
						self.m93rpistol_release = 1;
						self.m93rpistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.m93rpistol_jammed != 1)
				if (time >= self.m93rpistol_nextanim)
				if (self.m93rpistol_animempty)
				{
					self.m93rpistol_animempty = 0;
					self.m93rpistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m93rpistol_release = 1;
				self.m93rpistol_burstcount = 0;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.m93rpistol_animset)
			if (self.m93rpistol_jammed != 1) {
				//if (self.m93rpistol_suppressed) {
				//	if (self.m93rpistol_animempty)
				//		self.weaponname = "m93rpistol_suppressed_empty";
				//	else
				//		self.weaponname = "m93rpistol_suppressed";
				//} else if (!self.m93rpistol_suppressed) {
					if (self.m93rpistol_animempty)
						self.weaponname = "m93rpistol_empty";
					else
						self.weaponname = "m93rpistol";
				//}
			}
			
			self.m93rpistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m93rpistol.md3");
		precache_model ("models/weapons/v_m93rpistol.md3");
		//precache_model ("models/weapons/v_m93rpistol_suppressed.md3");
		precache_model ("models/weapons/h_m93rpistol.iqm");
		//precache_model ("models/weapons/h_m93rpistol_suppressed.iqm");
		
		precache_model ("models/weapons/v_m93rpistol_empty.md3");
		//precache_model ("models/weapons/v_m93rpistol_suppressed_empty.md3");
		precache_model ("models/weapons/h_m93rpistol_empty.iqm");
		//precache_model ("models/weapons/h_m93rpistol_suppressed_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/futuristic_smg_single_shot.wav");
		//precache_sound ("weapons/uzi_fire_doublesuppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.m93rpistol_overheat_cnt = autocvar_g_balance_m93rpistol_heatmin;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -0.9';
			
		weapon_setup(WEP_M93RPISTOL);
		self.current_ammo = ammo_nails;
		
		//if (!autocvar_g_balance_m93rpistol_suppressornotincluded
		//|| self.inv_misc_suppressor9mm)
		//{
		//	if (self.m93rpistol_suppressed) {
		//		if (self.m93rpistol_animempty)
		//			self.weaponname = "m93rpistol_suppressed_empty";
		//		else
		//			self.weaponname = "m93rpistol_suppressed";
		//	} else if (!self.m93rpistol_suppressed) {
		//		if (self.m93rpistol_animempty)
		//			self.weaponname = "m93rpistol_empty";
		//		else
		//			self.weaponname = "m93rpistol";
		//	}
		//} else {
		//	self.m93rpistol_suppressed = 0;
			
			if (self.m93rpistol_animempty)
				self.weaponname = "m93rpistol_empty";
			else
				self.weaponname = "m93rpistol";
		//}
		
		
		  if (self.m93rpistol_jammed && self.m93rpistol_unjam)
		  {
		  	if (time >= self.m93rpistol_unjam_time) {
				self.m93rpistol_jammed = 0;
				self.m93rpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m93rpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M93RPISTOL]) >= autocvar_g_balance_m93rpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m93rpistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m93rpistol_clearjam_time, w_ready);
			if (self.m93rpistol_unjam != 1) {
				self.m93rpistol_unjam = 1;
				self.m93rpistol_unjam_time = time + autocvar_g_balance_m93rpistol_clearjam_time;
				self.m93rpistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_m93rpistol_primary_ammo, autocvar_g_balance_m93rpistol_reload_ammo, autocvar_g_balance_m93rpistol_reload_time, "weapons/reload.wav");
			
			//if (self.BUTTON_USE) {
			//  if (!autocvar_g_balance_m93rpistol_suppressornotincluded
			//  || self.inv_misc_suppressor9mm)
			//  {
			//	if (self.m93rpistol_suppressed) {
			//		self.m93rpistol_suppressed = 0;
			//		if (self.m93rpistol_animempty)
			//			self.weaponname = "m93rpistol_empty";
			//		else
			//			self.weaponname = "m93rpistol";
			//	} else if (!self.m93rpistol_suppressed) {
			//		self.m93rpistol_suppressed = 1;
			//		if (self.m93rpistol_animempty)
			//			self.weaponname = "m93rpistol_suppressed_empty";
			//		else
			//			self.weaponname = "m93rpistol_suppressed";
			//	}
			//  }
			//}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m93rpistol(float req)
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
			w_deathtypestring = _("%1$s died when %2$s 93R pistol placed a bullet in their head");
		else
			w_deathtypestring = _("%s was killed by %s's 93R pistol");
	}
	return TRUE;
}
#endif
#endif
