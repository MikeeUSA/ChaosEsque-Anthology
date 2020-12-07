#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SHOSHO, w_shosho, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "shosho", "shosho", _("Sho-sho"))
#else
#ifdef SVQC

.float shosho_release;
.float shosho_jammed;
.float shosho_unjam;
.float shosho_unjam_time;
.float shosho_click;
.float shosho_animempty;
.float shosho_animset;
.float shosho_nextanim;
.float shosho_nextbot;
.float shosho_setting; //0 full auto //1 semi
.float shosho_overheat_cnt;
.float shosho_overheated_until;
.float shosho_overheat2_cnt;
.float shosho_overheat2ed_until;


void W_ShoSho_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_shosho_primary_ammo;
	d = autocvar_g_balance_shosho_primary_damage;
	f = autocvar_g_balance_shosho_primary_force;
	//spread = autocvar_g_balance_shosho_primary_spread;
	spread = bound(autocvar_g_balance_shosho_spread_min, autocvar_g_balance_shosho_spread_min + (autocvar_g_balance_shosho_spread_add * self.misc_bulletcounter), autocvar_g_balance_shosho_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_shosho_primary_speed;
	bulletconstant = autocvar_g_balance_shosho_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_shosho_reload_ammo);
	
	if (autocvar_g_balance_shosho_jamrate &&
 	(autocvar_g_balance_shosho_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machine rifle jammed\n");
		}
		self.shosho_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_bass.ogg", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_shosho_primary_headshotaddeddamage, f, WEP_SHOSHO, PROJECTILE_BULLETRIFLE9MM, 1, bulletconstant, autocvar_g_balance_shosho_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_shosho_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_shosho_gunrise, random() * autocvar_g_balance_shosho_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '32 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 105, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.shosho_overheat_cnt),"_Firing\n");
		
	    	self.shosho_overheat_cnt = self.shosho_overheat_cnt + autocvar_g_balance_shosho_heatconstant;
         
	    	if (self.shosho_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your shosho overheated\n");
			}
				
			self.shosho_overheated_until = time + (autocvar_g_balance_shosho_cooldownwait * (self.shosho_overheat_cnt + 1));
	    	}
		
		//2
		
		self.shosho_overheat2_cnt = self.shosho_overheat2_cnt + autocvar_g_balance_shosho_heatconstant;
         
	    	if (self.shosho_overheat2_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your shosho overheated the internal aluminium cooling jacket and jammed hard\n");
			}
				
			self.shosho_overheat2ed_until = time + (autocvar_g_balance_shosho_cooldownwait2 * (self.shosho_overheat2_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_ShoSho_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_shosho_reload_ammo && self.clip_load < autocvar_g_balance_shosho_primary_ammo))
	{
		if (!self.shosho_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.shosho_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.shosho_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_shosho (void)
{
	weapon_defaultspawnfunc(WEP_SHOSHO);
}


.float shosho_primarytime;

float w_shosho(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//print(ftos(self.shosho_overheat_cnt),"_Cooldown\n");
			
			if (self.shosho_overheat_cnt < autocvar_g_balance_shosho_heatmin) {
				self.shosho_overheat_cnt = autocvar_g_balance_shosho_heatmin;
			} else {
				self.shosho_overheat_cnt = self.shosho_overheat_cnt - (autocvar_g_balance_shosho_cooldownrate * sys_frametime);
			}
			
			//2
			if (self.shosho_overheat2_cnt < autocvar_g_balance_shosho_heatmin2) {
				self.shosho_overheat2_cnt = autocvar_g_balance_shosho_heatmin2;
			} else {
				self.shosho_overheat2_cnt = self.shosho_overheat2_cnt - (autocvar_g_balance_shosho_cooldownrate2 * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_ShoSho_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.shosho_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.shosho_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_shosho_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_ShoSho_NeedManualReload())
	{
		if(autocvar_g_balance_shosho_reload_ammo && self.clip_load < autocvar_g_balance_shosho_primary_ammo) // forced reload
		{
			// don't force reload an empty shosho if its melee attack is active
			if not(autocvar_g_balance_shosho_secondary && self.ammo_nails < autocvar_g_balance_shosho_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.shosho_release = 0;
		}
		else
		{
		  if (self.shosho_jammed && self.shosho_unjam)
		  {
		  	if (time >= self.shosho_unjam_time) {
				self.shosho_jammed = 0;
				self.shosho_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.shosho_release)
			if (self.shosho_jammed != 1)
			if ((time > self.shosho_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if ((time > self.shosho_overheat2ed_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.shosho_setting != 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.shosho_nextbot)," \n");
				} else {
					self.shosho_nextbot = 0;
				}
				
				if (time >= self.shosho_nextbot) {
					W_ShoSho_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_shosho_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shosho_primary_animtime, w_ready);
					self.shosho_release = 0;
					self.shosho_animempty = 1;
					self.shosho_animset = 1;
					self.shosho_nextanim = time + autocvar_g_balance_shosho_primary_rfanim;
					bp_skipme = 1;
					//self.shosho_nextbot = time + (autocvar_g_balance_shosho_primary_refire * 50 * random());
					self.shosho_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.shosho_release = 1;
					self.shosho_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.shosho_nextbot)," \n");
				} else {
					self.shosho_nextbot = 0;
				}
				
				if (time >= self.shosho_nextbot) {
					W_ShoSho_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_shosho_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shosho_secondary_animtime, w_ready);
					self.shosho_release = 0;
					self.shosho_animempty = 1;
					self.shosho_animset = 1;
					self.shosho_nextanim = time + autocvar_g_balance_shosho_secondary_rfanim;
					bp_skipme = 1;
					//self.shosho_nextbot = time + (autocvar_g_balance_shosho_secondary_refire * 50 * random());
					self.shosho_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.shosho_release)
			if (self.shosho_jammed != 1)
			if ((time > self.shosho_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if ((time > self.shosho_overheat2ed_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.shosho_setting) {
					self.shosho_setting = 0;
				} else {
					self.shosho_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.shosho_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.shosho_jammed != 1)
				if (time >= self.shosho_nextanim)
				if (self.shosho_animempty)
				{
					self.shosho_animempty = 0;
					self.shosho_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.shosho_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.shosho_animset)
			if (self.shosho_jammed != 1) {
				
					//Reverse: open bolt
					if (self.shosho_animempty)
						self.weaponname = "shosho";
					else
						self.weaponname = "shosho_empty";
			}
			
			self.shosho_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_shosho.md3");
		precache_model ("models/weapons/v_shosho.md3");
		precache_model ("models/weapons/h_shosho.iqm");
		
		precache_model ("models/weapons/v_shosho_empty.md3");
		precache_model ("models/weapons/h_shosho_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_bass.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.shosho_overheat_cnt = autocvar_g_balance_shosho_heatmin;
		self.shosho_overheat2_cnt = autocvar_g_balance_shosho_heatmin2;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		self.weaponaltaim = '50 -1.25 -3.70';
		weapon_setup(WEP_SHOSHO);
		self.current_ammo = ammo_nails;
		
			//Reverse: open bolt
			if (self.shosho_animempty)
				self.weaponname = "shosho";
			else
				self.weaponname = "shosho_empty";
				
	
		
		  if (self.shosho_jammed && self.shosho_unjam)
		  {
		  	if (time >= self.shosho_unjam_time) {
				self.shosho_jammed = 0;
				self.shosho_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_shosho_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SHOSHO]) >= autocvar_g_balance_shosho_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.shosho_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_shosho_clearjam_time, w_ready);
			if (self.shosho_unjam != 1) {
				self.shosho_unjam = 1;
				self.shosho_unjam_time = time + autocvar_g_balance_shosho_clearjam_time;
				self.shosho_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_shosho_primary_ammo, autocvar_g_balance_shosho_reload_ammo, autocvar_g_balance_shosho_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_shosho(float req)
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
			w_deathtypestring = _("%1$s chest has .30-06 cal holes put in by %2$s sho-sho");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died, %2$s shot them in the head with some .30-06");
		else
			w_deathtypestring = _("%s was killed by %s's .30-06 sho-sho");
	}
	return TRUE;
}
#endif
#endif
