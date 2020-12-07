#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SVD, w_svd, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "svd", "svd", _("SVD"))
#else
#ifdef SVQC

.float svd_release;
.float svd_jammed;
.float svd_unjam;
.float svd_unjam_time;
.float svd_click;
.float svd_animempty;
.float svd_animset;
.float svd_nextanim;
.float svd_nextbot;
.float svd_overheat_cnt;
.float svd_overheated_until;


void W_SvD_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_svd_primary_ammo;
	d = autocvar_g_balance_svd_primary_damage;
	f = autocvar_g_balance_svd_primary_force;
	//spread = autocvar_g_balance_svd_primary_spread;
	spread = bound(autocvar_g_balance_svd_spread_min, autocvar_g_balance_svd_spread_min + (autocvar_g_balance_svd_spread_add * self.misc_bulletcounter), autocvar_g_balance_svd_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_svd_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_30calrifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_svd_reload_ammo);
	
	if (autocvar_g_balance_svd_jamrate &&
 	(autocvar_g_balance_svd_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle jammed\n");
		}
		self.svd_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_sks_fire.wav", CH_WEAPON_A, d);
	
	
	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_svd_primary_headshotaddeddamage, f, WEP_SVD, PROJECTILE_BULLETRIFLE30, 1, bulletconstant, autocvar_g_balance_svd_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_svd_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_svd_gunrise, random() * autocvar_g_balance_svd_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '30 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 125, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.svd_overheat_cnt),"_Firing\n");
		
	    	self.svd_overheat_cnt = self.svd_overheat_cnt + autocvar_g_balance_svd_heatconstant;
         
	    	if (self.svd_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your svd overheated\n");
			}
				
			self.svd_overheated_until = time + (autocvar_g_balance_svd_cooldownwait * (self.svd_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	
	} //End Not Jammed
}


float W_SvD_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_svd_reload_ammo && self.clip_load < autocvar_g_balance_svd_primary_ammo))
	{
		if (!self.svd_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.svd_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.svd_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_svd (void)
{
	weapon_defaultspawnfunc(WEP_SVD);
}


.float svd_primarytime;

float w_svd(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
				//print(ftos(self.svd_overheat_cnt),"_Cooldown\n");
			
			if (self.svd_overheat_cnt < autocvar_g_balance_svd_heatmin) {
				self.svd_overheat_cnt = autocvar_g_balance_svd_heatmin;
			} else {
				self.svd_overheat_cnt = self.svd_overheat_cnt - (autocvar_g_balance_svd_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_SvD_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.svd_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.svd_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_svd_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_SvD_NeedManualReload())
	{
		if(autocvar_g_balance_svd_reload_ammo && self.clip_load < autocvar_g_balance_svd_primary_ammo) // forced reload
		{
			// don't force reload an empty svd if its melee attack is active
			if not(autocvar_g_balance_svd_secondary && self.ammo_nails < autocvar_g_balance_svd_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.svd_release = 0;
		}
		else
		{
		  if (self.svd_jammed && self.svd_unjam)
		  {
		  	if (time >= self.svd_unjam_time) {
				self.svd_jammed = 0;
				self.svd_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.svd_release)
			if (self.svd_jammed != 1)
			if ((time > self.svd_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.svd_nextbot)," \n");
				} else {
					self.svd_nextbot = 0;
				}
				
				if (time >= self.svd_nextbot) {
					W_SvD_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_svd_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_svd_primary_animtime, w_ready);
					self.svd_release = 0;
					self.svd_animempty = 1;
					self.svd_animset = 1;
					self.svd_nextanim = time + autocvar_g_balance_svd_primary_rfanim;
					bp_skipme = 1;
					//self.svd_nextbot = time + (autocvar_g_balance_svd_primary_refire * 50 * random());
					self.svd_nextbot = time + 0.1 + (0.4 * random());
					
					bp_skipme = 1;
					//self.svd_nextbot = time + (autocvar_g_balance_svd_primary_refire * 50 * random());
					self.svd_nextbot = time + 0.1 + (0.4 * random());
				}
			}
			
			if not(bp_skipme) {
				if (self.svd_jammed != 1)
				if (time >= self.svd_nextanim)
				if (self.svd_animempty)
				{
					self.svd_animempty = 0;
					self.svd_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.svd_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			if (self.svd_animset)
			if (self.svd_jammed != 1) {
				
					if (self.svd_animempty)
						self.weaponname = "svd_empty";
					else
						self.weaponname = "svd";
			}
			
			self.svd_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  if (self.svd_jammed && self.svd_unjam)
		  {
		  	if (time >= self.svd_unjam_time) {
				self.svd_jammed = 0;
				self.svd_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  } 
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_svd.md3");
		precache_model ("models/weapons/v_svd.md3");
		precache_model ("models/weapons/h_svd.iqm");
		
		precache_model ("models/weapons/v_svd_empty.md3");
		precache_model ("models/weapons/h_svd_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_sks_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.svd_overheat_cnt = autocvar_g_balance_svd_heatmin;
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '43 0.02 -2.8';
		self.weaponaltaim = '55 0.02 -5.8';
		weapon_setup(WEP_SVD);
		self.current_ammo = ammo_nails;
		
		
			if (self.svd_animempty)
				self.weaponname = "svd_empty";
			else
				self.weaponname = "svd";
				
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_svd_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SVD]) >= autocvar_g_balance_svd_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.svd_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_svd_clearjam_time, w_ready);
			if (self.svd_unjam != 1) {
				self.svd_unjam = 1;
				self.svd_unjam_time = time + autocvar_g_balance_svd_clearjam_time;
				self.svd_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_svd_primary_ammo, autocvar_g_balance_svd_reload_ammo, autocvar_g_balance_svd_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_svd(float req)
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
			w_deathtypestring = _("%1$s chest was made holes of by %2$s SVD");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died, %2$s shot them in head");
		else
			w_deathtypestring = _("%s killed was by %s's SVD");
	}
	return TRUE;
}
#endif
#endif
