#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SVSKORPION, w_svskorpion, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "svskorpion", "svskorpion", _("SV Skorpion"))
#else
#ifdef SVQC

.float svskorpion_release;
.float svskorpion_jammed;
.float svskorpion_unjam;
.float svskorpion_unjam_time;
.float svskorpion_click;
.float svskorpion_animempty;
.float svskorpion_animset;
.float svskorpion_nextanim;
.float svskorpion_nextbot;
.float svskorpion_overheat_cnt;
.float svskorpion_overheated_until;

void W_SvSkorpion_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_svskorpion_primary_ammo;
	d = autocvar_g_balance_svskorpion_primary_damage;
	f = autocvar_g_balance_svskorpion_primary_force;
	//spread = autocvar_g_balance_svskorpion_primary_spread;
	spread = bound(autocvar_g_balance_svskorpion_spread_min, autocvar_g_balance_svskorpion_spread_min + (autocvar_g_balance_svskorpion_spread_add * self.misc_bulletcounter), autocvar_g_balance_svskorpion_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_svskorpion_primary_speed;
	bulletconstant = autocvar_g_balance_svskorpion_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_svskorpion_reload_ammo);
	
	if (autocvar_g_balance_svskorpion_jamrate &&
 	(autocvar_g_balance_svskorpion_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your svskorpion jammed\n");
		}
		self.svskorpion_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_svskorpion_primary_headshotaddeddamage, f, WEP_SVSKORPION, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_svskorpion_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_svskorpion_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_svskorpion_gunrise, random() * autocvar_g_balance_svskorpion_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '8.5 0 0');
	
	
	if (autocvar_g_casings >= 2) {
		if (autocvar_g_balance_svskorpion_altcasings) {
			//For the cinematic magic
			SpawnCasing_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '0 2 0');
		} else {
			//Normal
			SpawnCasing_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 125 + 125)) - ((random () * -200 - 220) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 4, self, '0 2 0');
		}
	}

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.svskorpion_overheat_cnt),"_Firing\n");
		
	    	self.svskorpion_overheat_cnt = self.svskorpion_overheat_cnt + autocvar_g_balance_svskorpion_heatconstant;
         
	    	if (self.svskorpion_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your svskorpion overheated\n");
			}
				
			self.svskorpion_overheated_until = time + (autocvar_g_balance_svskorpion_cooldownwait * (self.svskorpion_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	

	
	} //End Not Jammed
}


float W_SvSkorpion_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_svskorpion_reload_ammo && self.clip_load < autocvar_g_balance_svskorpion_primary_ammo))
	{
		if (!self.svskorpion_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.svskorpion_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.svskorpion_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_svskorpion (void)
{
	weapon_defaultspawnfunc(WEP_SVSKORPION);
}


.float svskorpion_primarytime;

float w_svskorpion(float req)
{
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.svskorpion_overheat_cnt),"_Cooldown\n");
			
			if (self.svskorpion_overheat_cnt < autocvar_g_balance_svskorpion_heatmin) {
				self.svskorpion_overheat_cnt = autocvar_g_balance_svskorpion_heatmin;
			} else {
				self.svskorpion_overheat_cnt = self.svskorpion_overheat_cnt - (autocvar_g_balance_svskorpion_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_SvSkorpion_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.svskorpion_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.svskorpion_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_svskorpion_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_SvSkorpion_NeedManualReload())
	{
		
	
	
	
		if(autocvar_g_balance_svskorpion_reload_ammo && self.clip_load < autocvar_g_balance_svskorpion_primary_ammo) // forced reload
		{
			// don't force reload an empty svskorpion if its melee attack is active
			if not(autocvar_g_balance_svskorpion_secondary && self.ammo_nails < autocvar_g_balance_svskorpion_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.svskorpion_release = 0;
		}
		else
		{
		  if (self.svskorpion_jammed && self.svskorpion_unjam)
		  {
		  	if (time >= self.svskorpion_unjam_time) {
				self.svskorpion_jammed = 0;
				self.svskorpion_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.svskorpion_release)
			if (self.svskorpion_jammed != 1)
			if ((time > self.svskorpion_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.svskorpion_nextbot)," \n");
				} else {
					self.svskorpion_nextbot = 0;
				}
				
				if (time >= self.svskorpion_nextbot) {
					W_SvSkorpion_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_svskorpion_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_svskorpion_primary_animtime, w_ready);
					self.svskorpion_release = 0;
					self.svskorpion_animempty = 1;
					self.svskorpion_animset = 1;
					self.svskorpion_nextanim = time + autocvar_g_balance_svskorpion_primary_rfanim;
					bp_skipme = 1;
					//self.svskorpion_nextbot = time + (autocvar_g_balance_svskorpion_primary_refire * 50 * random());
					self.svskorpion_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.svskorpion_release = 1;
					self.svskorpion_nextbot = time;
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.svskorpion_release)
			if (self.svskorpion_jammed != 1)
			if ((time > self.svskorpion_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.svskorpion_nextbot)," \n");
				} else {
					self.svskorpion_nextbot = 0;
				}
				
				if (time >= self.svskorpion_nextbot) {
					W_SvSkorpion_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_svskorpion_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_svskorpion_secondary_animtime, w_ready);
					self.svskorpion_release = 0;
					self.svskorpion_animempty = 1;
					self.svskorpion_animset = 1;
					self.svskorpion_nextanim = time + autocvar_g_balance_svskorpion_secondary_rfanim;
					bp_skipme = 1;
					//self.svskorpion_nextbot = time + (autocvar_g_balance_svskorpion_secondary_refire * 50 * random());
					self.svskorpion_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_svskorpion_fullauto == 1) {
						self.svskorpion_release = 1;
						self.svskorpion_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.svskorpion_jammed != 1)
				if (time >= self.svskorpion_nextanim)
				if (self.svskorpion_animempty)
				{
					self.svskorpion_animempty = 0;
					self.svskorpion_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.svskorpion_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.svskorpion_animset)
			if (self.svskorpion_jammed != 1) {
					if (self.svskorpion_animempty)
						self.weaponname = "svskorpion_empty";
					else
						self.weaponname = "svskorpion";
			}
			
			self.svskorpion_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_svskorpion.md3");
		precache_model ("models/weapons/v_svskorpion.md3");
		precache_model ("models/weapons/h_svskorpion.iqm");
		
		precache_model ("models/weapons/v_svskorpion_empty.md3");
		precache_model ("models/weapons/h_svskorpion_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.svskorpion_overheat_cnt = autocvar_g_balance_svskorpion_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.25 -1.0';
		//self.weaponaltaim = '40 -0.25 -1.35';
		//self.weaponaltaim = '40 1 -1.5';
		//self.weaponaltaim = '40 -0.5 -1.7';
		//self.weaponaltaim = '40 -0.6 -1.8';
		//self.weaponaltaim = '40 -0.5 -1.8';
		//self.weaponaltaim = '40 -0.485 -1.8';
		self.weaponaltaim = '40 -0.5 -1.8';

		weapon_setup(WEP_SVSKORPION);
		self.current_ammo = ammo_nails;
		
		
			
			if (self.svskorpion_animempty)
				self.weaponname = "svskorpion_empty";
			else
				self.weaponname = "svskorpion";

	
	
		  if (self.svskorpion_jammed && self.svskorpion_unjam)
		  {
		  	if (time >= self.svskorpion_unjam_time) {
				self.svskorpion_jammed = 0;
				self.svskorpion_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_svskorpion_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SVSKORPION]) >= autocvar_g_balance_svskorpion_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.svskorpion_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_svskorpion_clearjam_time, w_ready);
			if (self.svskorpion_unjam != 1) {
				self.svskorpion_unjam = 1;
				self.svskorpion_unjam_time = time + autocvar_g_balance_svskorpion_clearjam_time;
				self.svskorpion_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_svskorpion_primary_ammo, autocvar_g_balance_svskorpion_reload_ammo, autocvar_g_balance_svskorpion_reload_time, "weapons/reload.wav");
			
			
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_svskorpion(float req)
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
			w_deathtypestring = _("%1$s chest was ventelated by %2$s SV skorpion");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s shot them in the head with a SV skorpion");
		else
			w_deathtypestring = _("%s was kiled by %s's SV skorpion");
	}
	return TRUE;
}
#endif
#endif
