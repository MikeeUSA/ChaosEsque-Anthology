#ifdef REGISTER_WEAPON
REGISTER_WEAPON(AMR18, w_amr18, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "amr18", "amr18", _("AMR-18"))
#else
#ifdef SVQC

.float amr18_release;
.float amr18_jammed;
.float amr18_unjam;
.float amr18_unjam_time;
.float amr18_click;
.float amr18_animempty;
.float amr18_animset;
.float amr18_nextanim;
.float amr18_nextbot;
.float amr18_setting; //0 full auto //1 semi
.float amr18_overheat_cnt;
.float amr18_overheated_until;


void W_Amr18_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_amr18_primary_ammo;
	d = autocvar_g_balance_amr18_primary_damage;
	f = autocvar_g_balance_amr18_primary_force;
	spread = bound(autocvar_g_balance_amr18_spread_min, autocvar_g_balance_amr18_spread_min + (autocvar_g_balance_amr18_spread_add * self.misc_bulletcounter), autocvar_g_balance_amr18_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_amr18_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_30calrifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_amr18_reload_ammo);
	
	if (autocvar_g_balance_amr18_jamrate &&
 	(autocvar_g_balance_amr18_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault rifle jammed\n");
		}
		self.amr18_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire.wav", CH_WEAPON_A, d);
	
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_amr18_primary_headshotaddeddamage, f, WEP_AMR18, PROJECTILE_BULLETRIFLE25, 1, bulletconstant, autocvar_g_balance_amr18_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_amr18_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_amr18_gunrise, random() * autocvar_g_balance_amr18_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '14 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 104, self);


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.amr18_overheat_cnt),"_Firing\n");
		
	    	self.amr18_overheat_cnt = self.amr18_overheat_cnt + autocvar_g_balance_amr18_heatconstant;
         
	    	if (self.amr18_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your amr18 overheated\n");
			}
				
			self.amr18_overheated_until = time + (autocvar_g_balance_amr18_cooldownwait * (self.amr18_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}

	
	} //End Not Jammed
}


float W_Amr18_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_amr18_reload_ammo && self.clip_load < autocvar_g_balance_amr18_primary_ammo))
	{
		if (!self.amr18_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.amr18_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.amr18_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_amr18 (void)
{
	weapon_defaultspawnfunc(WEP_AMR18);
}


.float amr18_primarytime;

float w_amr18(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.amr18_overheat_cnt),"_Cooldown\n");
			
			if (self.amr18_overheat_cnt < autocvar_g_balance_amr18_heatmin) {
				self.amr18_overheat_cnt = autocvar_g_balance_amr18_heatmin;
			} else {
				self.amr18_overheat_cnt = self.amr18_overheat_cnt - (autocvar_g_balance_amr18_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Amr18_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.amr18_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.amr18_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_amr18_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Amr18_NeedManualReload())
	{
		if(autocvar_g_balance_amr18_reload_ammo && self.clip_load < autocvar_g_balance_amr18_primary_ammo) // forced reload
		{
			// don't force reload an empty amr18 if its melee attack is active
			if not(autocvar_g_balance_amr18_secondary && self.ammo_nails < autocvar_g_balance_amr18_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.amr18_release = 0;
		}
		else
		{
		  if (self.amr18_jammed && self.amr18_unjam)
		  {
		  	if (time >= self.amr18_unjam_time) {
				self.amr18_jammed = 0;
				self.amr18_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.amr18_release)
			if (self.amr18_jammed != 1)
			if ((time > self.amr18_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.amr18_setting != 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.amr18_nextbot)," \n");
				} else {
					self.amr18_nextbot = 0;
				}
				
				if (time >= self.amr18_nextbot) {
					W_Amr18_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_amr18_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_amr18_primary_animtime, w_ready);
					self.amr18_release = 0;
					self.amr18_animempty = 1;
					self.amr18_animset = 1;
					self.amr18_nextanim = time + autocvar_g_balance_amr18_primary_rfanim;
					bp_skipme = 1;
					//self.amr18_nextbot = time + (autocvar_g_balance_amr18_primary_refire * 50 * random());
					self.amr18_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.amr18_release = 1;
					self.amr18_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.amr18_nextbot)," \n");
				} else {
					self.amr18_nextbot = 0;
				}
				
				if (time >= self.amr18_nextbot) {
					W_Amr18_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_amr18_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_amr18_secondary_animtime, w_ready);
					self.amr18_release = 0;
					self.amr18_animempty = 1;
					self.amr18_animset = 1;
					self.amr18_nextanim = time + autocvar_g_balance_amr18_secondary_rfanim;
					bp_skipme = 1;
					//self.amr18_nextbot = time + (autocvar_g_balance_amr18_secondary_refire * 50 * random());
					self.amr18_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.amr18_release)
			if (self.amr18_jammed != 1)
			if ((time > self.amr18_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.amr18_setting) {
					self.amr18_setting = 0;
				} else {
					self.amr18_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.amr18_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.amr18_jammed != 1)
				if (time >= self.amr18_nextanim)
				if (self.amr18_animempty)
				{
					self.amr18_animempty = 0;
					self.amr18_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.amr18_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.amr18_animset)
			if (self.amr18_jammed != 1) {
				
					if (self.amr18_animempty)
						self.weaponname = "amr18_empty";
					else
						self.weaponname = "amr18";
			}
			
			self.amr18_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_amr18.md3");
		precache_model ("models/weapons/v_amr18.md3");
		precache_model ("models/weapons/h_amr18.iqm");
		
		precache_model ("models/weapons/v_amr18_empty.md3");
		precache_model ("models/weapons/h_amr18_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.amr18_overheat_cnt = autocvar_g_balance_amr18_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '52 0.02 -2.8';
		self.weaponaltaim = '52 0.02 -1.8';
		weapon_setup(WEP_AMR18);
		self.current_ammo = ammo_nails;
		
		
			if (self.amr18_animempty)
				self.weaponname = "amr18_empty";
			else
				self.weaponname = "amr18";
				
	
	
		  if (self.amr18_jammed && self.amr18_unjam)
		  {
		  	if (time >= self.amr18_unjam_time) {
				self.amr18_jammed = 0;
				self.amr18_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_amr18_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_AMR18]) >= autocvar_g_balance_amr18_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.amr18_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_amr18_clearjam_time, w_ready);
			if (self.amr18_unjam != 1) {
				self.amr18_unjam = 1;
				self.amr18_unjam_time = time + autocvar_g_balance_amr18_clearjam_time;
				self.amr18_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_amr18_primary_ammo, autocvar_g_balance_amr18_reload_ammo, autocvar_g_balance_amr18_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_amr18(float req)
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
			w_deathtypestring = _("%1$s was terminated by %2$s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was no match for %2$s mechanical accuracy");
		else
			w_deathtypestring = _("%s was sent on vacation via round from %s's AMR-18");
	}
	return TRUE;
}
#endif
#endif
