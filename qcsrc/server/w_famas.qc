#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FAMAS, w_famas, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "famas", "famas", _("FAMAS"))
#else
#ifdef SVQC

.float famas_release;
.float famas_jammed;
.float famas_unjam;
.float famas_unjam_time;
.float famas_click;
.float famas_animempty;
.float famas_animset;
.float famas_nextanim;
.float famas_nextbot;
.float famas_setting; //0 full auto //1 semi
.float famas_overheat_cnt;
.float famas_overheated_until;
float famasautoskincolorset;
.float famas_customskin;

void W_FAMAS_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_famas_primary_ammo;
	d = autocvar_g_balance_famas_primary_damage;
	f = autocvar_g_balance_famas_primary_force;
	//spread = autocvar_g_balance_famas_primary_spread;
	spread = bound(autocvar_g_balance_famas_spread_min, autocvar_g_balance_famas_spread_min + (autocvar_g_balance_famas_spread_add * self.misc_bulletcounter), autocvar_g_balance_famas_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_famas_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_famas_reload_ammo);
	
	if (autocvar_g_balance_famas_jamrate &&
 	(autocvar_g_balance_famas_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault FAMAS jammed\n");
		}
		self.famas_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire_deeper.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_famas_primary_headshotaddeddamage, f, WEP_FAMAS, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_famas_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_famas_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_famas_gunrise, random() * autocvar_g_balance_famas_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '-4 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 100 + 100) * v_right) - (v_forward * (random () * 100 + 100)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self, '-13 0 0');

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.famas_overheat_cnt),"_Firing\n");
		
	    	self.famas_overheat_cnt = self.famas_overheat_cnt + autocvar_g_balance_famas_heatconstant;
         
	    	if (self.famas_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your FAMAS overheated\n");
			}
				
			self.famas_overheated_until = time + (autocvar_g_balance_famas_cooldownwait * (self.famas_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
}


float W_FAMAS_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_famas_reload_ammo && self.clip_load < autocvar_g_balance_famas_primary_ammo))
	{
		if (!self.famas_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.famas_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.famas_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_famas (void)
{
	weapon_defaultspawnfunc(WEP_FAMAS);
}


float w_famas_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.famas_customskin > 0)) {
		return player.famas_customskin;
	} else if (autocvar_g_balance_famas_skin == -1) {
	
		if not(famasautoskincolorset) {
			famasautoskincolorset = w_p90_skin_autocolorset();
		}
		
		
		if (famasautoskincolorset == -10) {
			return 0;
		} else {
			return famasautoskincolorset;
		}
	} else {
		return autocvar_g_balance_famas_skin;
	}
}


.float famas_primarytime;

float w_famas(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//secondary is irrelevant here
				//as it is a selector
				//print(ftos(self.famas_overheat_cnt),"_Cooldown\n");
			
			if (self.famas_overheat_cnt < autocvar_g_balance_famas_heatmin) {
				self.famas_overheat_cnt = autocvar_g_balance_famas_heatmin;
			} else {
				self.famas_overheat_cnt = self.famas_overheat_cnt - (autocvar_g_balance_famas_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_FAMAS_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.famas_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.famas_setting != 1) {
			self.BUTTON_ATCK2 = 1;
			//Flip to full auto if bot
		} else {
		
			if (self.famas_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_famas_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_FAMAS_NeedManualReload())
	{
		if(autocvar_g_balance_famas_reload_ammo && self.clip_load < autocvar_g_balance_famas_primary_ammo) // forced reload
		{
			// don't force reload an empty famas if its melee attack is active
			if not(autocvar_g_balance_famas_secondary && self.ammo_nails < autocvar_g_balance_famas_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.famas_release = 0;
		}
		else
		{
		  if (self.famas_jammed && self.famas_unjam)
		  {
		  	if (time >= self.famas_unjam_time) {
				self.famas_jammed = 0;
				self.famas_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.famas_release)
			if (self.famas_jammed != 1)
			if ((time > self.famas_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.famas_setting == 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.famas_nextbot)," \n");
				} else {
					self.famas_nextbot = 0;
				}
				
				if (time >= self.famas_nextbot) {
					W_FAMAS_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_famas_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_famas_primary_animtime, w_ready);
					self.famas_release = 0;
					self.famas_animempty = 1;
					self.famas_animset = 1;
					self.famas_nextanim = time + autocvar_g_balance_famas_primary_rfanim;
					bp_skipme = 1;
					//self.famas_nextbot = time + (autocvar_g_balance_famas_primary_refire * 50 * random());
					self.famas_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.famas_release = 1;
					self.famas_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.famas_nextbot)," \n");
				} else {
					self.famas_nextbot = 0;
				}
				
				if (time >= self.famas_nextbot) {
					W_FAMAS_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_famas_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_famas_secondary_animtime, w_ready);
					self.famas_release = 0;
					self.famas_animempty = 1;
					self.famas_animset = 1;
					self.famas_nextanim = time + autocvar_g_balance_famas_secondary_rfanim;
					bp_skipme = 1;
					//self.famas_nextbot = time + (autocvar_g_balance_famas_secondary_refire * 50 * random());
					self.famas_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.famas_release)
			if (self.famas_jammed != 1)
			if ((time > self.famas_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.famas_setting) {
					self.famas_setting = 0;
				} else {
					self.famas_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.famas_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.famas_jammed != 1)
				if (time >= self.famas_nextanim)
				if (self.famas_animempty)
				{
					self.famas_animempty = 0;
					self.famas_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.famas_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.famas_animset)
			//if (self.famas_jammed != 1) {
			//	
			//		if (self.famas_animempty)
			//			self.weaponname = "famas_empty";
			//		else
			//			self.weaponname = "famas";
			//}
			
			self.famas_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_famas.md3");
		precache_model ("models/weapons/v_famas.md3");
		precache_model ("models/weapons/h_famas.iqm");
		
		//precache_model ("models/weapons/v_famas_empty.md3");
		//precache_model ("models/weapons/h_famas_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire_deeper.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.famas_overheat_cnt = autocvar_g_balance_famas_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		//self.weaponaltaim = '43 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -0.8';
		//self.weaponaltaim = '50 0.02 -1.8';
		//self.weaponaltaim = '40 0.02 -0.8';
		//self.weaponaltaim = '54 0.02 -1.8';
		//self.weaponaltaim = '50 0.02 -2.0';
		//self.weaponaltaim = '50 0.02 -5.0';
		self.weaponaltaim = '50 0.06 -5.0';
		
		weapon_setup(WEP_FAMAS);
		self.current_ammo = ammo_nails;
		
		
			//if (self.famas_animempty)
			//	self.weaponname = "famas_empty";
			//else
			//	self.weaponname = "famas";
				
	
	
		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  //With the FAMAS we have set it so that if a malfunction (rather than a jam) occurs it is hard to clear
		  //A good deal of fiddling
		  if (self.famas_jammed && self.famas_unjam)
		  {
		  	if (time >= self.famas_unjam_time) {
			if (random() > 0.9) {
				self.famas_jammed = 0;
				self.famas_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_famas_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_FAMAS]) >= autocvar_g_balance_famas_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.famas_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_famas_clearjam_time, w_ready);
			if (self.famas_unjam != 1) {
				self.famas_unjam = 1;
				self.famas_unjam_time = time + autocvar_g_balance_famas_clearjam_time;
				self.famas_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_famas_primary_ammo, autocvar_g_balance_famas_reload_ammo, autocvar_g_balance_famas_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_famas(float req)
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
			w_deathtypestring = _("%s Mike voulait respirer, mais %s lui avait tiré dans la poitrine avec son FAMAS, et dans le cours naturel normal des choses: la mort s'ensuivit");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s a été abattu dans la tête par FAMAS de %s");
		else
			w_deathtypestring = _("%s est mort en raison de l'action prise par %s");
	}
	return TRUE;
}
#endif
#endif
