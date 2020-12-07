#ifdef REGISTER_WEAPON
REGISTER_WEAPON(STYERTMP, w_styertmp, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "styertmp", "styertmp", _("Styer TMP"))
#else
#ifdef SVQC

.float styertmp_release;
.float styertmp_jammed;
.float styertmp_unjam;
.float styertmp_unjam_time;
.float styertmp_click;
.float styertmp_animempty;
.float styertmp_animset;
.float styertmp_nextanim;
.float styertmp_nextbot;
.float styertmp_overheat_cnt;
.float styertmp_overheated_until;

void W_StyerTMP_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_styertmp_primary_ammo;
	d = autocvar_g_balance_styertmp_primary_damage;
	f = autocvar_g_balance_styertmp_primary_force;
	//spread = autocvar_g_balance_styertmp_primary_spread;
	spread = bound(autocvar_g_balance_styertmp_spread_min, autocvar_g_balance_styertmp_spread_min + (autocvar_g_balance_styertmp_spread_add * self.misc_bulletcounter), autocvar_g_balance_styertmp_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_styertmp_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_9mm_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_styertmp_reload_ammo);
	
	if (autocvar_g_balance_styertmp_jamrate &&
 	(autocvar_g_balance_styertmp_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your TMP jammed\n");
		}
		self.styertmp_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/tmp_fire.ogg", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_styertmp_primary_headshotaddeddamage, f, WEP_STYERTMP, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_styertmp_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_styertmp_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_styertmp_gunrise, random() * autocvar_g_balance_styertmp_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '2.50 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 150 + 50) * v_right) - (v_forward * (random () * 50 + 25)) - ((random () * -120 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self, '-3.5 0 0');


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.styertmp_overheat_cnt),"_Firing\n");
		
	    	self.styertmp_overheat_cnt = self.styertmp_overheat_cnt + autocvar_g_balance_styertmp_heatconstant;
         
	    	if (self.styertmp_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your styertmp overheated\n");
			}
				
			self.styertmp_overheated_until = time + (autocvar_g_balance_styertmp_cooldownwait * (self.styertmp_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	

	
	} //End Not Jammed
}


float W_StyerTMP_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_styertmp_reload_ammo && self.clip_load < autocvar_g_balance_styertmp_primary_ammo))
	{
		if (!self.styertmp_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.styertmp_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.styertmp_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_styertmp (void)
{
	weapon_defaultspawnfunc(WEP_STYERTMP);
}


.float styertmp_primarytime;

float w_styertmp(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//For TMP, only the primary trigger is relevant for overheating
				//print(ftos(self.styertmp_overheat_cnt),"_Cooldown\n");
			
			if (self.styertmp_overheat_cnt < autocvar_g_balance_styertmp_heatmin) {
				self.styertmp_overheat_cnt = autocvar_g_balance_styertmp_heatmin;
			} else {
				self.styertmp_overheat_cnt = self.styertmp_overheat_cnt - (autocvar_g_balance_styertmp_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_StyerTMP_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.styertmp_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		
		
			if (self.styertmp_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_styertmp_primary_speed, 0, 0.001, FALSE);
			}
			
			if (self.bot_aggresskill > 0.75) {
				//Full auto!
				self.BUTTON_ATCK2 = self.BUTTON_ATCK;
			} else if (self.bot_aggresskill > 0.50) {
				//Full auto maybe
				if (random() > 0.70) {
					self.BUTTON_ATCK2 = self.BUTTON_ATCK;
				}
			} else if (random() > 0.9) {
				//Full auto?
				self.BUTTON_ATCK2 = self.BUTTON_ATCK;
			}
		
	}
	else if (req == WR_THINK && !W_StyerTMP_NeedManualReload())
	{
		if(autocvar_g_balance_styertmp_reload_ammo && self.clip_load < autocvar_g_balance_styertmp_primary_ammo) // forced reload
		{
			// don't force reload an empty styertmp if its melee attack is active
			if not(autocvar_g_balance_styertmp_secondary && self.ammo_nails < autocvar_g_balance_styertmp_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.styertmp_release = 0;
		}
		else
		{
		  if (self.styertmp_jammed && self.styertmp_unjam)
		  {
		  	if (time >= self.styertmp_unjam_time) {
				self.styertmp_jammed = 0;
				self.styertmp_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.styertmp_release || self.BUTTON_ATCK2)
			if (self.styertmp_jammed != 1)
			if ((time > self.styertmp_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.BUTTON_ATCK2) {
			  	//Fullauto (aug has a 2 stage trigger, simulating that)
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.styertmp_nextbot)," \n");
				} else {
					self.styertmp_nextbot = 0;
				}
				
				if (time >= self.styertmp_nextbot) {
					W_StyerTMP_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_styertmp_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_styertmp_primary_animtime, w_ready);
					self.styertmp_release = 0;
					self.styertmp_animempty = 1;
					self.styertmp_animset = 1;
					self.styertmp_nextanim = time + autocvar_g_balance_styertmp_primary_rfanim;
					bp_skipme = 1;
					//self.styertmp_nextbot = time + (autocvar_g_balance_styertmp_primary_refire * 50 * random());
					self.styertmp_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.styertmp_release = 1;
					self.styertmp_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.styertmp_nextbot)," \n");
				} else {
					self.styertmp_nextbot = 0;
				}
				
				if (time >= self.styertmp_nextbot) {
					W_StyerTMP_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_styertmp_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_styertmp_secondary_animtime, w_ready);
					self.styertmp_release = 0;
					self.styertmp_animempty = 1;
					self.styertmp_animset = 1;
					self.styertmp_nextanim = time + autocvar_g_balance_styertmp_secondary_rfanim;
					bp_skipme = 1;
					//self.styertmp_nextbot = time + (autocvar_g_balance_styertmp_secondary_refire * 50 * random());
					self.styertmp_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			
			if not(bp_skipme) {
				if (self.styertmp_jammed != 1)
				if (time >= self.styertmp_nextanim)
				if (self.styertmp_animempty)
				{
					self.styertmp_animempty = 0;
					self.styertmp_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.styertmp_release = 1;
			}
			
			if not(self.BUTTON_ATCK && self.BUTTON_ATCK2) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.styertmp_animset)
			//if (self.styertmp_jammed != 1) {
			//	
			//		if (self.styertmp_animempty)
			//			self.weaponname = "styertmp_empty";
			//		else
			//			self.weaponname = "styertmp";
			//}
			
			self.styertmp_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_styertmp.md3");
		precache_model ("models/weapons/v_styertmp.md3");
		precache_model ("models/weapons/h_styertmp.iqm");
		
		//precache_model ("models/weapons/v_styertmp_empty.md3");
		//precache_model ("models/weapons/h_styertmp_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/tmp_fire.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.styertmp_overheat_cnt = autocvar_g_balance_styertmp_heatmin;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -3.0';
		weapon_setup(WEP_STYERTMP);
		self.current_ammo = ammo_nails;
		
		
			//if (self.styertmp_animempty)
			//	self.weaponname = "styertmp_empty";
			//else
			//	self.weaponname = "styertmp";
				
	
		  
		  if (self.styertmp_jammed && self.styertmp_unjam)
		  {
		  	if (time >= self.styertmp_unjam_time) {
				self.styertmp_jammed = 0;
				self.styertmp_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_styertmp_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_STYERTMP]) >= autocvar_g_balance_styertmp_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.styertmp_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_styertmp_clearjam_time, w_ready);
			if (self.styertmp_unjam != 1) {
				self.styertmp_unjam = 1;
				self.styertmp_unjam_time = time + autocvar_g_balance_styertmp_clearjam_time;
				self.styertmp_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_styertmp_primary_ammo, autocvar_g_balance_styertmp_reload_ammo, autocvar_g_balance_styertmp_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_styertmp(float req)
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
			w_deathtypestring = _("%s developed small accurately placed holes in the chest thanks to %s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s enjoyed greeting from Austria from %s's TMP");
		else
			w_deathtypestring = _("%s shot dead by %s with a Styer TMP");
	}
	return TRUE;
}
#endif
#endif
