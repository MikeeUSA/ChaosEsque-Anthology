#ifdef REGISTER_WEAPON
REGISTER_WEAPON(L85A2, w_l85a2, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "l85a2", "l85a2", _("L85A2"))
#else
#ifdef SVQC

.float l85a2_release;
.float l85a2_jammed;
.float l85a2_unjam;
.float l85a2_unjam_time;
.float l85a2_click;
.float l85a2_animempty;
.float l85a2_animset;
.float l85a2_nextanim;
.float l85a2_nextbot;
.float l85a2_setting; //0 full auto //1 semi
.float l85a2_overheat_cnt;
.float l85a2_overheated_until;

void W_L85A2_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_l85a2_primary_ammo;
	d = autocvar_g_balance_l85a2_primary_damage;
	f = autocvar_g_balance_l85a2_primary_force;
	//spread = autocvar_g_balance_l85a2_primary_spread;
	spread = bound(autocvar_g_balance_l85a2_spread_min, autocvar_g_balance_l85a2_spread_min + (autocvar_g_balance_l85a2_spread_add * self.misc_bulletcounter), autocvar_g_balance_l85a2_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_l85a2_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_l85a2_reload_ammo);
	
	if (autocvar_g_balance_l85a2_jamrate &&
 	(autocvar_g_balance_l85a2_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault L85A2 jammed\n");
		}
		self.l85a2_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire_deeper.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_l85a2_primary_headshotaddeddamage, f, WEP_L85A2, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_l85a2_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_l85a2_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_l85a2_gunrise, random() * autocvar_g_balance_l85a2_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '-1 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * -120 - 140) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '-8 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.l85a2_overheat_cnt),"_Firing\n");
		
	    	self.l85a2_overheat_cnt = self.l85a2_overheat_cnt + autocvar_g_balance_l85a2_heatconstant;
         
	    	if (self.l85a2_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your L85A2 overheated\n");
			}
				
			self.l85a2_overheated_until = time + (autocvar_g_balance_l85a2_cooldownwait * (self.l85a2_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
}


float W_L85A2_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_l85a2_reload_ammo && self.clip_load < autocvar_g_balance_l85a2_primary_ammo))
	{
		if (!self.l85a2_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.l85a2_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.l85a2_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_l85a2 (void)
{
	weapon_defaultspawnfunc(WEP_L85A2);
}


.float l85a2_primarytime;

float w_l85a2(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//Normally, secondary would be irrelevant here
				//However the L85 is finicky
				//print(ftos(self.l85a2_overheat_cnt),"_Cooldown\n");
			
			if (self.l85a2_overheat_cnt < autocvar_g_balance_l85a2_heatmin) {
				self.l85a2_overheat_cnt = autocvar_g_balance_l85a2_heatmin;
			} else {
				self.l85a2_overheat_cnt = self.l85a2_overheat_cnt - (autocvar_g_balance_l85a2_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_L85A2_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.l85a2_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.l85a2_setting != 1) {
			self.BUTTON_ATCK2 = 1;
			//Flip to full auto if bot
		} else {
		
			if (self.l85a2_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_l85a2_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_L85A2_NeedManualReload())
	{
		if(autocvar_g_balance_l85a2_reload_ammo && self.clip_load < autocvar_g_balance_l85a2_primary_ammo) // forced reload
		{
			// don't force reload an empty l85a2 if its melee attack is active
			if not(autocvar_g_balance_l85a2_secondary && self.ammo_nails < autocvar_g_balance_l85a2_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.l85a2_release = 0;
		}
		else
		{
		  if (self.l85a2_jammed && self.l85a2_unjam)
		  {
		  	if (time >= self.l85a2_unjam_time) {
				self.l85a2_jammed = 0;
				self.l85a2_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.l85a2_release)
			if (self.l85a2_jammed != 1)
			if ((time > self.l85a2_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.l85a2_setting == 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.l85a2_nextbot)," \n");
				} else {
					self.l85a2_nextbot = 0;
				}
				
				if (time >= self.l85a2_nextbot) {
					W_L85A2_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_l85a2_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_l85a2_primary_animtime, w_ready);
					self.l85a2_release = 0;
					self.l85a2_animempty = 1;
					self.l85a2_animset = 1;
					self.l85a2_nextanim = time + autocvar_g_balance_l85a2_primary_rfanim;
					bp_skipme = 1;
					//self.l85a2_nextbot = time + (autocvar_g_balance_l85a2_primary_refire * 50 * random());
					self.l85a2_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.l85a2_release = 1;
					self.l85a2_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.l85a2_nextbot)," \n");
				} else {
					self.l85a2_nextbot = 0;
				}
				
				if (time >= self.l85a2_nextbot) {
					W_L85A2_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_l85a2_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_l85a2_secondary_animtime, w_ready);
					self.l85a2_release = 0;
					self.l85a2_animempty = 1;
					self.l85a2_animset = 1;
					self.l85a2_nextanim = time + autocvar_g_balance_l85a2_secondary_rfanim;
					bp_skipme = 1;
					//self.l85a2_nextbot = time + (autocvar_g_balance_l85a2_secondary_refire * 50 * random());
					self.l85a2_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.l85a2_release)
			if (self.l85a2_jammed != 1)
			if ((time > self.l85a2_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.l85a2_setting) {
					self.l85a2_setting = 0;
				} else {
					self.l85a2_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.l85a2_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.l85a2_jammed != 1)
				if (time >= self.l85a2_nextanim)
				if (self.l85a2_animempty)
				{
					self.l85a2_animempty = 0;
					self.l85a2_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.l85a2_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.l85a2_animset)
			//if (self.l85a2_jammed != 1) {
			//	
			//		if (self.l85a2_animempty)
			//			self.weaponname = "l85a2_empty";
			//		else
			//			self.weaponname = "l85a2";
			//}
			
			self.l85a2_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_l85a2.md3");
		precache_model ("models/weapons/v_l85a2.md3");
		precache_model ("models/weapons/h_l85a2.iqm");
		
		//precache_model ("models/weapons/v_l85a2_empty.md3");
		//precache_model ("models/weapons/h_l85a2_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire_deeper.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.l85a2_overheat_cnt = autocvar_g_balance_l85a2_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		//self.weaponaltaim = '43 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -1.8';
		//self.weaponaltaim = '40 0.02 -0.8';
		//self.weaponaltaim = '54 0.02 -1.8';
		self.weaponaltaim = '50 0.02 -2.0';
		weapon_setup(WEP_L85A2);
		self.current_ammo = ammo_nails;
		
		
			//if (self.l85a2_animempty)
			//	self.weaponname = "l85a2_empty";
			//else
			//	self.weaponname = "l85a2";
				
	
	
		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  //With the L85A2 we have set it so that if a malfunction (rather than a jam) occurs it is hard to clear
		  //A good deal of fiddling
		  if (self.l85a2_jammed && self.l85a2_unjam)
		  {
		  	if (time >= self.l85a2_unjam_time) {
			if (random() > 0.9) {
				self.l85a2_jammed = 0;
				self.l85a2_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_l85a2_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_L85A2]) >= autocvar_g_balance_l85a2_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.l85a2_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_l85a2_clearjam_time, w_ready);
			if (self.l85a2_unjam != 1) {
				self.l85a2_unjam = 1;
				self.l85a2_unjam_time = time + autocvar_g_balance_l85a2_clearjam_time;
				self.l85a2_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_l85a2_primary_ammo, autocvar_g_balance_l85a2_reload_ammo, autocvar_g_balance_l85a2_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_l85a2(float req)
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
			w_deathtypestring = _("%s had some standard drilled in the chest thanks to %s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was regimented by %s's L85A2");
		else
			w_deathtypestring = _("%s copped a packet, thank %s's L85A2");
	}
	return TRUE;
}
#endif
#endif
