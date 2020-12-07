#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MACHINEPISTOL, w_machinepistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "machinepistol", "machinepistol", _("MachinePistol"))
#else
#ifdef SVQC

.float machinepistol_release;
.float machinepistol_jammed;
.float machinepistol_unjam;
.float machinepistol_unjam_time;
.float machinepistol_click;
.float machinepistol_animempty;
.float machinepistol_animset;
.float machinepistol_nextanim;
.float machinepistol_nextbot;
.float machinepistol_overheat_cnt;
.float machinepistol_overheated_until;

void W_MachinePistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_machinepistol_primary_ammo;
	d = autocvar_g_balance_machinepistol_primary_damage;
	f = autocvar_g_balance_machinepistol_primary_force;
	//spread = autocvar_g_balance_machinepistol_primary_spread;
	spread = bound(autocvar_g_balance_machinepistol_spread_min, autocvar_g_balance_machinepistol_spread_min + (autocvar_g_balance_machinepistol_spread_add * self.misc_bulletcounter), autocvar_g_balance_machinepistol_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_machinepistol_primary_speed;
	bulletconstant = autocvar_g_balance_machinepistol_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_machinepistol_reload_ammo);
	
	if (autocvar_g_balance_machinepistol_jamrate &&
 	(autocvar_g_balance_machinepistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinepistol jammed\n");
		}
		self.machinepistol_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_wppq_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_machinepistol_primary_headshotaddeddamage, f, WEP_MACHINEPISTOL, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_machinepistol_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_machinepistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_machinepistol_gunrise, random() * autocvar_g_balance_machinepistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '7.5 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 62, self, '0 2 0');


	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.machinepistol_overheat_cnt),"_Firing\n");
		
	    	self.machinepistol_overheat_cnt = self.machinepistol_overheat_cnt + autocvar_g_balance_machinepistol_heatconstant;
         
	    	if (self.machinepistol_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your machinepistol overheated\n");
			}
				
			self.machinepistol_overheated_until = time + (autocvar_g_balance_machinepistol_cooldownwait * (self.machinepistol_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	

	
	} //End Not Jammed
}


float W_MachinePistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_machinepistol_reload_ammo && self.clip_load < autocvar_g_balance_machinepistol_primary_ammo))
	{
		if (!self.machinepistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.machinepistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.machinepistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_machinepistol (void)
{
	weapon_defaultspawnfunc(WEP_MACHINEPISTOL);
}


.float machinepistol_primarytime;

float w_machinepistol(float req)
{
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.machinepistol_overheat_cnt),"_Cooldown\n");
			
			if (self.machinepistol_overheat_cnt < autocvar_g_balance_machinepistol_heatmin) {
				self.machinepistol_overheat_cnt = autocvar_g_balance_machinepistol_heatmin;
			} else {
				self.machinepistol_overheat_cnt = self.machinepistol_overheat_cnt - (autocvar_g_balance_machinepistol_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_MachinePistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.machinepistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.machinepistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_machinepistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_MachinePistol_NeedManualReload())
	{
		
	
	
	
		if(autocvar_g_balance_machinepistol_reload_ammo && self.clip_load < autocvar_g_balance_machinepistol_primary_ammo) // forced reload
		{
			// don't force reload an empty machinepistol if its melee attack is active
			if not(autocvar_g_balance_machinepistol_secondary && self.ammo_nails < autocvar_g_balance_machinepistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.machinepistol_release = 0;
		}
		else
		{
		  if (self.machinepistol_jammed && self.machinepistol_unjam)
		  {
		  	if (time >= self.machinepistol_unjam_time) {
				self.machinepistol_jammed = 0;
				self.machinepistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.machinepistol_release)
			if (self.machinepistol_jammed != 1)
			if ((time > self.machinepistol_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.machinepistol_nextbot)," \n");
				} else {
					self.machinepistol_nextbot = 0;
				}
				
				if (time >= self.machinepistol_nextbot) {
					W_MachinePistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_machinepistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_machinepistol_primary_animtime, w_ready);
					self.machinepistol_release = 0;
					self.machinepistol_animempty = 1;
					self.machinepistol_animset = 1;
					self.machinepistol_nextanim = time + autocvar_g_balance_machinepistol_primary_rfanim;
					bp_skipme = 1;
					//self.machinepistol_nextbot = time + (autocvar_g_balance_machinepistol_primary_refire * 50 * random());
					self.machinepistol_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.machinepistol_release = 1;
					self.machinepistol_nextbot = time;
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.machinepistol_release)
			if (self.machinepistol_jammed != 1)
			if ((time > self.machinepistol_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.machinepistol_nextbot)," \n");
				} else {
					self.machinepistol_nextbot = 0;
				}
				
				if (time >= self.machinepistol_nextbot) {
					W_MachinePistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_machinepistol_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_machinepistol_secondary_animtime, w_ready);
					self.machinepistol_release = 0;
					self.machinepistol_animempty = 1;
					self.machinepistol_animset = 1;
					self.machinepistol_nextanim = time + autocvar_g_balance_machinepistol_secondary_rfanim;
					bp_skipme = 1;
					//self.machinepistol_nextbot = time + (autocvar_g_balance_machinepistol_secondary_refire * 50 * random());
					self.machinepistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_machinepistol_fullauto == 1) {
						self.machinepistol_release = 1;
						self.machinepistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.machinepistol_jammed != 1)
				if (time >= self.machinepistol_nextanim)
				if (self.machinepistol_animempty)
				{
					self.machinepistol_animempty = 0;
					self.machinepistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.machinepistol_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.machinepistol_animset)
			if (self.machinepistol_jammed != 1) {
					if (self.machinepistol_animempty)
						self.weaponname = "machinepistol_empty";
					else
						self.weaponname = "machinepistol";
			}
			
			self.machinepistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_machinepistol.md3");
		precache_model ("models/weapons/v_machinepistol.md3");
		precache_model ("models/weapons/h_machinepistol.iqm");
		
		precache_model ("models/weapons/v_machinepistol_empty.md3");
		precache_model ("models/weapons/h_machinepistol_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_wppq_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.machinepistol_overheat_cnt = autocvar_g_balance_machinepistol_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.25 -1.0';
			
		weapon_setup(WEP_MACHINEPISTOL);
		self.current_ammo = ammo_nails;
		
		
			
			if (self.machinepistol_animempty)
				self.weaponname = "machinepistol_empty";
			else
				self.weaponname = "machinepistol";

	
	
		  if (self.machinepistol_jammed && self.machinepistol_unjam)
		  {
		  	if (time >= self.machinepistol_unjam_time) {
				self.machinepistol_jammed = 0;
				self.machinepistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_machinepistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_MACHINEPISTOL]) >= autocvar_g_balance_machinepistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.machinepistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_machinepistol_clearjam_time, w_ready);
			if (self.machinepistol_unjam != 1) {
			if (random() > 0.8) {
				self.machinepistol_unjam = 1;
				self.machinepistol_unjam_time = time + autocvar_g_balance_machinepistol_clearjam_time;
				self.machinepistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
			}
		} else {
			W_Reload(autocvar_g_balance_machinepistol_primary_ammo, autocvar_g_balance_machinepistol_reload_ammo, autocvar_g_balance_machinepistol_reload_time, "weapons/reload.wav");
			
			
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_machinepistol(float req)
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
			w_deathtypestring = _("%1$s chest was ventelated by %2$s  machine pistol");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s shot them in the head with a machine pistol");
		else
			w_deathtypestring = _("%s was kiled by %s's machine pistol");
	}
	return TRUE;
}
#endif
#endif
