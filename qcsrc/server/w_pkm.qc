#ifdef REGISTER_WEAPON
REGISTER_WEAPON(PKM, w_pkm, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "pkm", "pkm", _("PKM"))
#else
#ifdef SVQC

.float pkm_release;
.float pkm_jammed;
.float pkm_unjam;
.float pkm_unjam_time;
.float pkm_click;
.float pkm_animempty;
.float pkm_animset;
.float pkm_nextanim;
.float pkm_nextbot;
.float pkm_overheat_cnt;
.float pkm_overheated_until;
.float pkm_triggerlag;
.float pkm_triggerlag_time;
.float pkm_triggerlag_button;


void W_PKM_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_pkm_primary_ammo;
	d = autocvar_g_balance_pkm_primary_damage;
	f = autocvar_g_balance_pkm_primary_force;

	spread = bound(autocvar_g_balance_pkm_spread_min, autocvar_g_balance_pkm_spread_min + (autocvar_g_balance_pkm_spread_add * self.misc_bulletcounter), autocvar_g_balance_pkm_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_pkm_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_30calrifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_pkm_reload_ammo);
	
	if (autocvar_g_balance_pkm_jamrate &&
 	(autocvar_g_balance_pkm_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun jammed\n");
		}
		self.pkm_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ak47_fire_deepererer.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_pkm_primary_headshotaddeddamage, f, WEP_PKM, PROJECTILE_BULLETRIFLE30, 1, bulletconstant, autocvar_g_balance_pkm_primary_coreshotaddeddamage);
	endFireBallisticBullet();
	
	//Note projectile changed to bulletrifle9mm from bulletrifle25

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_pkm_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_pkm_gunrise, random() * autocvar_g_balance_pkm_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '28 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 100 + 100) * -1 * v_right) - (v_forward * (random () * 45 + 45)) - ((random () * 100 + 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 125, self, '4.2 4.5 -3');  //back, side, updown


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.pkm_overheat_cnt),"_Firing\n");
		
	    	self.pkm_overheat_cnt = self.pkm_overheat_cnt + autocvar_g_balance_pkm_heatconstant;
         
	    	if (self.pkm_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your pkm overheated\n");
			}
				
			self.pkm_overheated_until = time + (autocvar_g_balance_pkm_cooldownwait * (self.pkm_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}

	
	} //End Not Jammed
}


float W_PKM_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_pkm_reload_ammo && self.clip_load < autocvar_g_balance_pkm_primary_ammo))
	{
		if (!self.pkm_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.pkm_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.pkm_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_pkm (void)
{
	weapon_defaultspawnfunc(WEP_PKM);
}


.float pkm_primarytime;

float w_pkm(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For AK, only the primary trigger is relevant for overheating
				//print(ftos(self.pkm_overheat_cnt),"_Cooldown\n");
			
			if (self.pkm_overheat_cnt < autocvar_g_balance_pkm_heatmin) {
				self.pkm_overheat_cnt = autocvar_g_balance_pkm_heatmin;
			} else {
				self.pkm_overheat_cnt = self.pkm_overheat_cnt - (autocvar_g_balance_pkm_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}


	float ammo_amount;
	if (req == WR_AIM) {
		if (W_PKM_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.pkm_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.pkm_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_pkm_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_PKM_NeedManualReload())
	{
		if(autocvar_g_balance_pkm_reload_ammo && self.clip_load < autocvar_g_balance_pkm_primary_ammo) // forced reload
		{
			// don't force reload an empty pkm if its melee attack is active
			if not(autocvar_g_balance_pkm_secondary && self.ammo_nails < autocvar_g_balance_pkm_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.pkm_release = 0;
		}
		else
		{
		  if (self.pkm_jammed && self.pkm_unjam)
		  {
		  	if (time >= self.pkm_unjam_time) {
				self.pkm_jammed = 0;
				self.pkm_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK || self.pkm_triggerlag_button == 1)
			if (self.pkm_release)
			if (self.pkm_jammed != 1)
			if ((time > self.pkm_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (((time > self.pkm_triggerlag_time) && self.pkm_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack_check(0, 0))
			{
				self.pkm_triggerlag = 1; //For openbolt trigger lag
				
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.pkm_nextbot)," \n");
				} else {
					self.pkm_nextbot = 0;
				}
				
				if (time >= self.pkm_nextbot) {
					W_PKM_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_pkm_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pkm_primary_animtime, w_ready);
					self.pkm_release = 0;
					self.pkm_animempty = 1;
					self.pkm_animset = 1;
					self.pkm_nextanim = time + autocvar_g_balance_pkm_primary_rfanim;
					bp_skipme = 1;
					//self.pkm_nextbot = time + (autocvar_g_balance_pkm_primary_refire * 50 * random());
					self.pkm_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.pkm_release = 1;
					self.pkm_nextbot = time;
				}
			}
			
			
			//Openbolt trigger lag
			if (time > self.pkm_triggerlag_time) {
				self.pkm_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.pkm_triggerlag)
			&& self.BUTTON_ATCK) {
				self.pkm_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.pkm_triggerlag = 1;
				self.pkm_triggerlag_time = time + (autocvar_g_balance_pkm_primary_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			if not(bp_skipme) {
				if (self.pkm_jammed != 1)
				if (time >= self.pkm_nextanim)
				if (self.pkm_animempty)
				{
					self.pkm_animempty = 0;
					self.pkm_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) { // || self.BUTTON_ATCK2) {
				self.pkm_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
				
				if not(self.pkm_triggerlag_button) {
					self.pkm_triggerlag = 0; //For openbolt trigger lag
				}
			}
				
			if (self.pkm_animset)
			if (self.pkm_jammed != 1) {
				
					if (autocvar_g_balance_pkm_reload_ammo
					&& (self.clip_load < (autocvar_g_balance_pkm_primary_ammo*2)))
						self.weaponname = "pkm_emptybelt"; //1 or no ammo, show empty belt
					else if (self.pkm_animempty)
						self.weaponname = "pkm_empty";
					else
						self.weaponname = "pkm";
			}
			
			self.pkm_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.pkm_jammed && self.pkm_unjam)
		  {
		  	if (time >= self.pkm_unjam_time) {
				self.pkm_jammed = 0;
				self.pkm_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_pkm.md3");
		precache_model ("models/weapons/v_pkm.md3");
		precache_model ("models/weapons/h_pkm.iqm");
		
		precache_model ("models/weapons/v_pkm_empty.md3");
		precache_model ("models/weapons/h_pkm_empty.iqm");
		
		precache_model ("models/weapons/v_pkm_emptybelt.md3");
		precache_model ("models/weapons/h_pkm_emptybelt.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ak47_fire_deepererer.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.pkm_triggerlag_button = 0; //for openbolt trigger lag
		self.pkm_triggerlag = 0; //for openbolt trigger lag
		
		self.pkm_overheat_cnt = autocvar_g_balance_pkm_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 0.02 -2.8';
		weapon_setup(WEP_PKM);
		self.current_ammo = ammo_nails;
		
		
			//if (autocvar_g_balance_pkm_reload_ammo && (self.clip_load < (autocvar_g_balance_pkm_primary_ammo*2)))
			//	self.weaponname = "pkm_emptybelt"; //1 or no ammo, show empty belt
			//else 
			if (self.pkm_animempty)
				self.weaponname = "pkm_empty";
			else
				self.weaponname = "pkm";
				
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_pkm_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_PKM]) >= autocvar_g_balance_pkm_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		self.pkm_triggerlag_button = 0; //for openbolt triggerlag
		self.pkm_triggerlag = 0; //for openbolt triggerlag
		
		if (self.pkm_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_pkm_clearjam_time, w_ready);
			if (self.pkm_unjam != 1) {
				self.pkm_unjam = 1;
				self.pkm_unjam_time = time + autocvar_g_balance_pkm_clearjam_time;
				self.pkm_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_pkm_primary_ammo, autocvar_g_balance_pkm_reload_ammo, autocvar_g_balance_pkm_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_pkm(float req)
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
			w_deathtypestring = _("%1$s chest made divots by %2$s PKM");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died by wound to head, %2$s PKM");
		else
			w_deathtypestring = _("%s shot, %s's PKM");
	}
	return TRUE;
}
#endif
#endif
