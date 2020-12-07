#ifdef REGISTER_WEAPON
REGISTER_WEAPON(RPD, w_rpd, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "rpd", "rpd", _("RPD"))
#else
#ifdef SVQC

.float rpd_release;
.float rpd_jammed;
.float rpd_unjam;
.float rpd_unjam_time;
.float rpd_click;
.float rpd_animempty;
.float rpd_animset;
.float rpd_nextanim;
.float rpd_nextbot;
.float rpd_overheat_cnt;
.float rpd_overheated_until;
.float rpd_triggerlag;
.float rpd_triggerlag_time;
.float rpd_triggerlag_button;


void W_RPD_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_rpd_primary_ammo;
	d = autocvar_g_balance_rpd_primary_damage;
	f = autocvar_g_balance_rpd_primary_force;

	spread = bound(autocvar_g_balance_rpd_spread_min, autocvar_g_balance_rpd_spread_min + (autocvar_g_balance_rpd_spread_add * self.misc_bulletcounter), autocvar_g_balance_rpd_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_rpd_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_ak47_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_rpd_reload_ammo);
	
	if (autocvar_g_balance_rpd_jamrate &&
 	(autocvar_g_balance_rpd_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your machinegun jammed\n");
		}
		self.rpd_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ak47_fire_deeperer.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_rpd_primary_headshotaddeddamage, f, WEP_RPD, PROJECTILE_BULLETRIFLE30, 1, bulletconstant, autocvar_g_balance_rpd_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_rpd_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_rpd_gunrise, random() * autocvar_g_balance_rpd_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '15 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 45 + 45)) - ((random () * 100 + 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 124, self, '0 0 -5');


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.rpd_overheat_cnt),"_Firing\n");
		
	    	self.rpd_overheat_cnt = self.rpd_overheat_cnt + autocvar_g_balance_rpd_heatconstant;
         
	    	if (self.rpd_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your rpd overheated\n");
			}
				
			self.rpd_overheated_until = time + (autocvar_g_balance_rpd_cooldownwait * (self.rpd_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}

	
	} //End Not Jammed
}


float W_RPD_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_rpd_reload_ammo && self.clip_load < autocvar_g_balance_rpd_primary_ammo))
	{
		if (!self.rpd_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.rpd_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.rpd_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_rpd (void)
{
	weapon_defaultspawnfunc(WEP_RPD);
}


.float rpd_primarytime;

float w_rpd(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For AK, only the primary trigger is relevant for overheating
				//print(ftos(self.rpd_overheat_cnt),"_Cooldown\n");
			
			if (self.rpd_overheat_cnt < autocvar_g_balance_rpd_heatmin) {
				self.rpd_overheat_cnt = autocvar_g_balance_rpd_heatmin;
			} else {
				self.rpd_overheat_cnt = self.rpd_overheat_cnt - (autocvar_g_balance_rpd_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}


	float ammo_amount;
	if (req == WR_AIM) {
		if (W_RPD_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.rpd_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.rpd_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_rpd_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_RPD_NeedManualReload())
	{
		if(autocvar_g_balance_rpd_reload_ammo && self.clip_load < autocvar_g_balance_rpd_primary_ammo) // forced reload
		{
			// don't force reload an empty rpd if its melee attack is active
			if not(autocvar_g_balance_rpd_secondary && self.ammo_nails < autocvar_g_balance_rpd_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.rpd_release = 0;
		}
		else
		{
		  if (self.rpd_jammed && self.rpd_unjam)
		  {
		  	if (time >= self.rpd_unjam_time) {
				self.rpd_jammed = 0;
				self.rpd_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK || self.rpd_triggerlag_button == 1)
			if (self.rpd_release)
			if (self.rpd_jammed != 1)
			if ((time > self.rpd_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (((time > self.rpd_triggerlag_time) && self.rpd_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack_check(0, 0))
			{
				self.rpd_triggerlag = 1; //For openbolt trigger lag
				
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.rpd_nextbot)," \n");
				} else {
					self.rpd_nextbot = 0;
				}
				
				if (time >= self.rpd_nextbot) {
					W_RPD_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_rpd_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_rpd_primary_animtime, w_ready);
					self.rpd_release = 0;
					self.rpd_animempty = 1;
					self.rpd_animset = 1;
					self.rpd_nextanim = time + autocvar_g_balance_rpd_primary_rfanim;
					bp_skipme = 1;
					//self.rpd_nextbot = time + (autocvar_g_balance_rpd_primary_refire * 50 * random());
					self.rpd_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.rpd_release = 1;
					self.rpd_nextbot = time;
				}
			}
			
			
			//Openbolt trigger lag
			if (time > self.rpd_triggerlag_time) {
				self.rpd_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.rpd_triggerlag)
			&& self.BUTTON_ATCK) {
				self.rpd_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.rpd_triggerlag = 1;
				self.rpd_triggerlag_time = time + (autocvar_g_balance_rpd_primary_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			if not(bp_skipme) {
				if (self.rpd_jammed != 1)
				if (time >= self.rpd_nextanim)
				if (self.rpd_animempty)
				{
					self.rpd_animempty = 0;
					self.rpd_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) { // || self.BUTTON_ATCK2) {
				self.rpd_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
				
				if not(self.rpd_triggerlag_button) {
					self.rpd_triggerlag = 0; //For openbolt trigger lag
				}
			}
				
			if (self.rpd_animset)
			if (self.rpd_jammed != 1) {
				
					if (autocvar_g_balance_rpd_reload_ammo
					&& (self.clip_load < (autocvar_g_balance_rpd_primary_ammo*2)))
						self.weaponname = "rpd_none"; //1 or no ammo, show empty belt
					else if (self.rpd_animempty)
						self.weaponname = "rpd_empty";
					else
						self.weaponname = "rpd";
			}
			
			self.rpd_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.rpd_jammed && self.rpd_unjam)
		  {
		  	if (time >= self.rpd_unjam_time) {
				self.rpd_jammed = 0;
				self.rpd_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_rpd.md3");
		precache_model ("models/weapons/v_rpd.md3");
		precache_model ("models/weapons/h_rpd.iqm");
		
		precache_model ("models/weapons/v_rpd_empty.md3");
		precache_model ("models/weapons/h_rpd_empty.iqm");
		
		precache_model ("models/weapons/v_rpd_none.md3");
		precache_model ("models/weapons/h_rpd_none.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ak47_fire_deeperer.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.rpd_triggerlag_button = 0; //for openbolt trigger lag
		self.rpd_triggerlag = 0; //for openbolt trigger lag
		
		self.rpd_overheat_cnt = autocvar_g_balance_rpd_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 0.02 -2.8';
		weapon_setup(WEP_RPD);
		self.current_ammo = ammo_nails;
		
		
			//if (autocvar_g_balance_rpd_reload_ammo && (self.clip_load < (autocvar_g_balance_rpd_primary_ammo*2)))
			//	self.weaponname = "rpd_none"; //1 or no ammo, show empty belt
			//else 
			if (self.rpd_animempty)
				self.weaponname = "rpd_empty";
			else
				self.weaponname = "rpd";
				
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_rpd_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_RPD]) >= autocvar_g_balance_rpd_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		self.rpd_triggerlag_button = 0; //for openbolt triggerlag
		self.rpd_triggerlag = 0; //for openbolt triggerlag
		
		if (self.rpd_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_rpd_clearjam_time, w_ready);
			if (self.rpd_unjam != 1) {
				self.rpd_unjam = 1;
				self.rpd_unjam_time = time + autocvar_g_balance_rpd_clearjam_time;
				self.rpd_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_rpd_primary_ammo, autocvar_g_balance_rpd_reload_ammo, autocvar_g_balance_rpd_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_rpd(float req)
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
			w_deathtypestring = _("%1$s chest made divots by %2$s RPD");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died by wound to head, %2$s RPD");
		else
			w_deathtypestring = _("%s shot, %s's RPD");
	}
	return TRUE;
}
#endif
#endif
