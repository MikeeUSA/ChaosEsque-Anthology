#ifdef REGISTER_WEAPON
REGISTER_WEAPON(G36C, w_g36c, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "g36c", "g36c", _("G36C"))
#else
#ifdef SVQC

.float g36c_release;
.float g36c_jammed;
.float g36c_unjam;
.float g36c_unjam_time;
.float g36c_click;
.float g36c_animempty;
.float g36c_animset;
.float g36c_nextanim;
.float g36c_nextbot;
.float g36c_setting; //0 full auto //1 semi
.float g36c_overheat_cnt;
.float g36c_overheated_until;

void W_G36C_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_g36c_primary_ammo;
	d = autocvar_g_balance_g36c_primary_damage;
	f = autocvar_g_balance_g36c_primary_force;
	//spread = autocvar_g_balance_g36c_primary_spread;
	spread = bound(autocvar_g_balance_g36c_spread_min, autocvar_g_balance_g36c_spread_min + (autocvar_g_balance_g36c_spread_add * self.misc_bulletcounter), autocvar_g_balance_g36c_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_g36c_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_g36c_reload_ammo);
	
	if (autocvar_g_balance_g36c_jamrate &&
 	(autocvar_g_balance_g36c_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault G36C jammed\n");
		}
		self.g36c_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire_deeper.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_g36c_primary_headshotaddeddamage, f, WEP_G36C, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_g36c_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.35;
		self.punchangle_y = random () - 0.35;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_g36c_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_g36c_gunrise, random() * autocvar_g_balance_g36c_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '-2 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 80 + 80) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * -74 - 74) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '-1 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.g36c_overheat_cnt),"_Firing\n");
		
	    	self.g36c_overheat_cnt = self.g36c_overheat_cnt + autocvar_g_balance_g36c_heatconstant;
         
	    	if (self.g36c_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your G36C overheated\n");
			}
				
			self.g36c_overheated_until = time + (autocvar_g_balance_g36c_cooldownwait * (self.g36c_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
}


float W_G36C_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_g36c_reload_ammo && self.clip_load < autocvar_g_balance_g36c_primary_ammo))
	{
		if (!self.g36c_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.g36c_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.g36c_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_g36c (void)
{
	weapon_defaultspawnfunc(WEP_G36C);
}


.float g36c_primarytime;

float w_g36c(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//Secondary is selector switch, irrelevant here
				//print(ftos(self.g36c_overheat_cnt),"_Cooldown\n");
			
			if (self.g36c_overheat_cnt < autocvar_g_balance_g36c_heatmin) {
				self.g36c_overheat_cnt = autocvar_g_balance_g36c_heatmin;
			} else {
				self.g36c_overheat_cnt = self.g36c_overheat_cnt - (autocvar_g_balance_g36c_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_G36C_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.g36c_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.g36c_setting != 1) {
			self.BUTTON_ATCK2 = 1;
			//Flip to full auto if bot
		} else {
		
			if (self.g36c_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_g36c_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_G36C_NeedManualReload())
	{
		if(autocvar_g_balance_g36c_reload_ammo && self.clip_load < autocvar_g_balance_g36c_primary_ammo) // forced reload
		{
			// don't force reload an empty g36c if its melee attack is active
			if not(autocvar_g_balance_g36c_secondary && self.ammo_nails < autocvar_g_balance_g36c_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.g36c_release = 0;
		}
		else
		{
		  if (self.g36c_jammed && self.g36c_unjam)
		  {
		  	if (time >= self.g36c_unjam_time) {
				self.g36c_jammed = 0;
				self.g36c_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.g36c_release)
			if (self.g36c_jammed != 1)
			if ((time > self.g36c_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.g36c_setting == 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.g36c_nextbot)," \n");
				} else {
					self.g36c_nextbot = 0;
				}
				
				if (time >= self.g36c_nextbot) {
					W_G36C_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_g36c_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_g36c_primary_animtime, w_ready);
					self.g36c_release = 0;
					self.g36c_animempty = 1;
					self.g36c_animset = 1;
					self.g36c_nextanim = time + autocvar_g_balance_g36c_primary_rfanim;
					bp_skipme = 1;
					//self.g36c_nextbot = time + (autocvar_g_balance_g36c_primary_refire * 50 * random());
					self.g36c_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.g36c_release = 1;
					self.g36c_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.g36c_nextbot)," \n");
				} else {
					self.g36c_nextbot = 0;
				}
				
				if (time >= self.g36c_nextbot) {
					W_G36C_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_g36c_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_g36c_secondary_animtime, w_ready);
					self.g36c_release = 0;
					self.g36c_animempty = 1;
					self.g36c_animset = 1;
					self.g36c_nextanim = time + autocvar_g_balance_g36c_secondary_rfanim;
					bp_skipme = 1;
					//self.g36c_nextbot = time + (autocvar_g_balance_g36c_secondary_refire * 50 * random());
					self.g36c_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.g36c_release)
			if (self.g36c_jammed != 1)
			if ((time > self.g36c_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.g36c_setting) {
					self.g36c_setting = 0;
				} else {
					self.g36c_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.g36c_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.g36c_jammed != 1)
				if (time >= self.g36c_nextanim)
				if (self.g36c_animempty)
				{
					self.g36c_animempty = 0;
					self.g36c_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.g36c_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.g36c_animset)
			//if (self.g36c_jammed != 1) {
			//	
			//		if (self.g36c_animempty)
			//			self.weaponname = "g36c_empty";
			//		else
			//			self.weaponname = "g36c";
			//}
			
			self.g36c_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_g36c.md3");
		precache_model ("models/weapons/v_g36c.md3");
		precache_model ("models/weapons/h_g36c.iqm");
		
		//precache_model ("models/weapons/v_g36c_empty.md3");
		//precache_model ("models/weapons/h_g36c_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire_deeper.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.g36c_overheat_cnt = autocvar_g_balance_g36c_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		//self.weaponaltaim = '43 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -1.8';
		//self.weaponaltaim = '40 0.02 -0.8';
		//self.weaponaltaim = '54 0.02 -1.8';
		//self.weaponaltaim = '50 0.02 -2.0';
		self.weaponaltaim = '50 0.02 -3.25';
		weapon_setup(WEP_G36C);
		self.current_ammo = ammo_nails;
		
		
			//if (self.g36c_animempty)
			//	self.weaponname = "g36c_empty";
			//else
			//	self.weaponname = "g36c";
			
			
			
		  if (self.g36c_jammed && self.g36c_unjam)
		  {
		  	if (time >= self.g36c_unjam_time) {
				self.g36c_jammed = 0;
				self.g36c_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
				
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_g36c_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_G36C]) >= autocvar_g_balance_g36c_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.g36c_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_g36c_clearjam_time, w_ready);
			if (self.g36c_unjam != 1) {
				self.g36c_unjam = 1;
				self.g36c_unjam_time = time + autocvar_g_balance_g36c_clearjam_time;
				self.g36c_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_g36c_primary_ammo, autocvar_g_balance_g36c_reload_ammo, autocvar_g_balance_g36c_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_g36c(float req)
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
			w_deathtypestring = _("%s had some NATO drilled in the chest thanks to %s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot in the head by %s's G36C");
		else
			w_deathtypestring = _("%s was killed via %s's G36C");
	}
	return TRUE;
}
#endif
#endif
