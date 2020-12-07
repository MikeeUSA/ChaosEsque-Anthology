#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M249PARA, w_m249para, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m249para", "m249para", _("M249-Para"))
#else
#ifdef SVQC

.float m249para_release;
.float m249para_jammed;
.float m249para_unjam;
.float m249para_unjam_time;
.float m249para_click;
.float m249para_animempty;
.float m249para_animset;
.float m249para_nextanim;
.float m249para_nextbot;
.float m249para_overheat_cnt;
.float m249para_overheated_until;
.float m249para_triggerlag;
.float m249para_triggerlag_time;
.float m249para_triggerlag_button;


void W_M249PARA_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m249para_primary_ammo;
	d = autocvar_g_balance_m249para_primary_damage;
	f = autocvar_g_balance_m249para_primary_force;

	spread = bound(autocvar_g_balance_m249para_spread_min, autocvar_g_balance_m249para_spread_min + (autocvar_g_balance_m249para_spread_add * self.misc_bulletcounter), autocvar_g_balance_m249para_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_m249para_primary_speed;
	bulletconstant = autocvar_g_balance_m249para_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m249para_reload_ammo);
	
	if (autocvar_g_balance_m249para_jamrate &&
 	(autocvar_g_balance_m249para_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun jammed\n");
		}
		self.m249para_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire_deeperer.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m249para_primary_headshotaddeddamage, f, WEP_M249PARA, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_m249para_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m249para_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m249para_gunrise, random() * autocvar_g_balance_m249para_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '0 0 0');
	
	
	if (autocvar_g_casings >= 2) {
		SpawnCasing_Offset (((random () * 100 + 120) * v_right) - (v_forward * (random () * 45 + 45)) - ((random () * 100 + 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '0 0 -5');
		//Link
		SpawnCasing_Offset (((random () * 25 + 25) * v_right) - (v_forward * (random () * 45 + 45)) - ((random () * 100 + 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 34, self, '0 0 1');
	}

	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.m249para_overheat_cnt),"_Firing\n");
		
	    	self.m249para_overheat_cnt = self.m249para_overheat_cnt + autocvar_g_balance_m249para_heatconstant;
         
	    	if (self.m249para_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your m249para overheated\n");
			}
				
			self.m249para_overheated_until = time + (autocvar_g_balance_m249para_cooldownwait * (self.m249para_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}

	
	} //End Not Jammed
}


float W_M249PARA_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m249para_reload_ammo && self.clip_load < autocvar_g_balance_m249para_primary_ammo))
	{
		if (!self.m249para_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m249para_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m249para_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_m249para (void)
{
	weapon_defaultspawnfunc(WEP_M249PARA);
}


.float m249para_primarytime;

float w_m249para(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For AK, only the primary trigger is relevant for overheating
				//print(ftos(self.m249para_overheat_cnt),"_Cooldown\n");
			
			if (self.m249para_overheat_cnt < autocvar_g_balance_m249para_heatmin) {
				self.m249para_overheat_cnt = autocvar_g_balance_m249para_heatmin;
			} else {
				self.m249para_overheat_cnt = self.m249para_overheat_cnt - (autocvar_g_balance_m249para_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}


	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M249PARA_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m249para_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.m249para_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m249para_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_M249PARA_NeedManualReload())
	{
		if(autocvar_g_balance_m249para_reload_ammo && self.clip_load < autocvar_g_balance_m249para_primary_ammo) // forced reload
		{
			// don't force reload an empty m249para if its melee attack is active
			if not(autocvar_g_balance_m249para_secondary && self.ammo_nails < autocvar_g_balance_m249para_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m249para_release = 0;
		}
		else
		{
		  if (self.m249para_jammed && self.m249para_unjam)
		  {
		  	if (time >= self.m249para_unjam_time) {
				self.m249para_jammed = 0;
				self.m249para_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK || self.m249para_triggerlag_button == 1)
			if (self.m249para_release)
			if (self.m249para_jammed != 1)
			if ((time > self.m249para_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (((time > self.m249para_triggerlag_time) && self.m249para_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack_check(0, 0))
			{
				self.m249para_triggerlag = 1; //For openbolt trigger lag
				
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m249para_nextbot)," \n");
				} else {
					self.m249para_nextbot = 0;
				}
				
				if (time >= self.m249para_nextbot) {
					W_M249PARA_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m249para_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m249para_primary_animtime, w_ready);
					self.m249para_release = 0;
					self.m249para_animempty = 1;
					self.m249para_animset = 1;
					self.m249para_nextanim = time + autocvar_g_balance_m249para_primary_rfanim;
					bp_skipme = 1;
					//self.m249para_nextbot = time + (autocvar_g_balance_m249para_primary_refire * 50 * random());
					self.m249para_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.m249para_release = 1;
					self.m249para_nextbot = time;
				}
			}
			
			
			//Openbolt trigger lag
			if (time > self.m249para_triggerlag_time) {
				self.m249para_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.m249para_triggerlag)
			&& self.BUTTON_ATCK) {
				self.m249para_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.m249para_triggerlag = 1;
				self.m249para_triggerlag_time = time + (autocvar_g_balance_m249para_primary_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			if not(bp_skipme) {
				if (self.m249para_jammed != 1)
				if (time >= self.m249para_nextanim)
				if (self.m249para_animempty)
				{
					self.m249para_animempty = 0;
					self.m249para_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) { // || self.BUTTON_ATCK2) {
				self.m249para_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
				
				if not(self.m249para_triggerlag_button) {
					self.m249para_triggerlag = 0; //For openbolt trigger lag
				}
			}
				
			if (self.m249para_animset)
			if (self.m249para_jammed != 1) {
				
					if (autocvar_g_balance_m249para_reload_ammo
					&& (self.clip_load < (autocvar_g_balance_m249para_primary_ammo*2))) {
						self.weaponname = "m249para_emptybelt"; //1 or no ammo, show empty belt
					} else if (self.m249para_animempty) {
						self.weaponname = "m249para_empty";
					} else {
						self.weaponname = "m249para";
					}
			}
			
			self.m249para_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.m249para_jammed && self.m249para_unjam)
		  {
		  	if (time >= self.m249para_unjam_time) {
				self.m249para_jammed = 0;
				self.m249para_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m249para.md3");
		precache_model ("models/weapons/v_m249para.md3");
		precache_model ("models/weapons/h_m249para.iqm");
		
		precache_model ("models/weapons/v_m249para_empty.md3");
		precache_model ("models/weapons/h_m249para_empty.iqm");
		
		precache_model ("models/weapons/v_m249para_emptybelt.md3");
		precache_model ("models/weapons/h_m249para_emptybelt.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire_deeperer.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.m249para_triggerlag_button = 0; //for openbolt trigger lag
		self.m249para_triggerlag = 0; //for openbolt trigger lag
		
		self.m249para_overheat_cnt = autocvar_g_balance_m249para_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		//self.weaponaltaim = '53 0.02 -2.8'; //x //FPS drop alot for some reason
		//self.weaponaltaim = '63 0.02 -2.8'; //x //*
		//self.weaponaltaim = '47 0.02 -2.8'; //x //*
		//self.weaponaltaim = '53 -2 -2.8'; //x //*
		//self.weaponaltaim = '35 0.02 -5.8';
		//self.weaponaltaim = '53 0.02 -5.8';
		//self.weaponaltaim = '47 0.02 -5.8';
		self.weaponaltaim = '47 0.02 -3.8';
		weapon_setup(WEP_M249PARA);
		self.current_ammo = ammo_nails;
		
		
			////if (autocvar_g_balance_m249para_reload_ammo && (self.clip_load < (autocvar_g_balance_m249para_primary_ammo*2)))
			////	self.weaponname = "m249para_emptybelt"; //1 or no ammo, show empty belt
			////else 
			if (self.m249para_animempty) {
				self.weaponname = "m249para_empty";
			} else {
				self.weaponname = "m249para";
			}
							
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m249para_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M249PARA]) >= autocvar_g_balance_m249para_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		self.m249para_triggerlag_button = 0; //for openbolt triggerlag
		self.m249para_triggerlag = 0; //for openbolt triggerlag
		
		if (self.m249para_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m249para_clearjam_time, w_ready);
			if (self.m249para_unjam != 1) {
				self.m249para_unjam = 1;
				self.m249para_unjam_time = time + autocvar_g_balance_m249para_clearjam_time;
				self.m249para_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_m249para_primary_ammo, autocvar_g_balance_m249para_reload_ammo, autocvar_g_balance_m249para_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m249para(float req)
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
			w_deathtypestring = _("%1$s was raked in the chest by %2$s M249-Para");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was headshotted, courtesy of %2$s M249-Para");
		else
			w_deathtypestring = _("%s was shot by %s's M249-Para");
	}
	return TRUE;
}
#endif
#endif
