#ifdef REGISTER_WEAPON
REGISTER_WEAPON(POUNDERSMG, w_poundersmg, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "poundersmg", "poundersmg", _("Pounder-SMG"))
#else
#ifdef SVQC

.float poundersmg_release;
.float poundersmg_jammed;
.float poundersmg_unjam;
.float poundersmg_unjam_time;
.float poundersmg_click;
.float poundersmg_animempty;
.float poundersmg_animset;
.float poundersmg_nextanim;
.float poundersmg_nextbot;
.float poundersmg_triggerlag;
.float poundersmg_triggerlag_time;
.float poundersmg_triggerlag_button;

void W_PounderSMG_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_poundersmg_primary_ammo;
	d = autocvar_g_balance_poundersmg_primary_damage;
	f = autocvar_g_balance_poundersmg_primary_force;
	//spread = autocvar_g_balance_poundersmg_primary_spread;
	spread = bound(autocvar_g_balance_poundersmg_spread_min, autocvar_g_balance_poundersmg_spread_min + (autocvar_g_balance_poundersmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_poundersmg_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_poundersmg_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_50ae_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_poundersmg_reload_ammo);
	
	if (autocvar_g_balance_poundersmg_jamrate &&
 	(autocvar_g_balance_poundersmg_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your Pounder-SMG jammed\n");
		}
		self.poundersmg_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/campingrifle_fire3_bass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_poundersmg_primary_headshotaddeddamage, f, WEP_POUNDERSMG, PROJECTILE_BULLET50AE, 1, bulletconstant, autocvar_g_balance_poundersmg_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_poundersmg_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_poundersmg_gunrise, random() * autocvar_g_balance_poundersmg_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '9.25 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -340 - 150) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 47, self);

	
	} //End Not Jammed
}


float W_PounderSMG_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_poundersmg_reload_ammo && self.clip_load < autocvar_g_balance_poundersmg_primary_ammo))
	{
		if (!self.poundersmg_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.poundersmg_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.poundersmg_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_poundersmg (void)
{
	weapon_defaultspawnfunc(WEP_POUNDERSMG);
}


.float poundersmg_primarytime;

float w_poundersmg(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_PounderSMG_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.poundersmg_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.poundersmg_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_poundersmg_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_PounderSMG_NeedManualReload())
	{
		if(autocvar_g_balance_poundersmg_reload_ammo && self.clip_load < autocvar_g_balance_poundersmg_primary_ammo) // forced reload
		{
			// don't force reload an empty poundersmg if its melee attack is active
			if not(autocvar_g_balance_poundersmg_secondary && self.ammo_nails < autocvar_g_balance_poundersmg_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.poundersmg_release = 0;
		}
		else
		{
		  if (self.poundersmg_jammed && self.poundersmg_unjam)
		  {
		  	if (time >= self.poundersmg_unjam_time) {
				self.poundersmg_jammed = 0;
				self.poundersmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK || self.poundersmg_triggerlag_button == 1)
			if (self.poundersmg_release)
			if (self.poundersmg_jammed != 1)
			if (((time > self.poundersmg_triggerlag_time) && self.poundersmg_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack_check(0, 0))
			{
				self.poundersmg_triggerlag = 1; //For openbolt trigger lag
				
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.poundersmg_nextbot)," \n");
				} else {
					self.poundersmg_nextbot = 0;
				}
				
				if (time >= self.poundersmg_nextbot) {
					W_PounderSMG_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_poundersmg_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_poundersmg_primary_animtime, w_ready);
					self.poundersmg_release = 0;
					self.poundersmg_animempty = 1;
					self.poundersmg_animset = 1;
					self.poundersmg_nextanim = time + autocvar_g_balance_poundersmg_primary_rfanim;
					bp_skipme = 1;
					//self.poundersmg_nextbot = time + (autocvar_g_balance_poundersmg_primary_refire * 50 * random());
					self.poundersmg_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.poundersmg_release = 1;
					self.poundersmg_nextbot = time;
				}
			}
			
			
			//Openbolt trigger lag
			if (time > self.poundersmg_triggerlag_time) {
				self.poundersmg_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.poundersmg_triggerlag)
			&& self.BUTTON_ATCK) {
				self.poundersmg_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.poundersmg_triggerlag = 1;
				self.poundersmg_triggerlag_time = time + (autocvar_g_balance_poundersmg_primary_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			
			if not(bp_skipme) {
				if (self.poundersmg_jammed != 1)
				if (time >= self.poundersmg_nextanim)
				if (self.poundersmg_animempty)
				{
					self.poundersmg_animempty = 0;
					self.poundersmg_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.poundersmg_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
				
				if not(self.poundersmg_triggerlag_button) {
					self.poundersmg_triggerlag = 0; //For openbolt trigger lag
				}
			}
				
			//Reversed: open bolt
			if (self.poundersmg_animset)
			if (self.poundersmg_jammed != 1) {
					if (self.poundersmg_animempty)
						self.weaponname = "poundersmg";
					else
						self.weaponname = "poundersmg_empty";
			}
			
			self.poundersmg_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_poundersmg.md3");
		precache_model ("models/weapons/v_poundersmg.md3");
		precache_model ("models/weapons/h_poundersmg.iqm");
		
		precache_model ("models/weapons/v_poundersmg_empty.md3");
		precache_model ("models/weapons/h_poundersmg_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/campingrifle_fire3_bass.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.poundersmg_triggerlag_button = 0; //for openbolt trigger lag
		self.poundersmg_triggerlag = 0; //for openbolt trigger lag
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -2.1';
			
		weapon_setup(WEP_POUNDERSMG);
		self.current_ammo = ammo_nails;
			//Reversed, open bolt
			if (self.poundersmg_animempty)
				self.weaponname = "poundersmg";
			else
				self.weaponname = "poundersmg_empty";
	
	
		
		  if (self.poundersmg_jammed && self.poundersmg_unjam)
		  {
		  	if (time >= self.poundersmg_unjam_time) {
				self.poundersmg_jammed = 0;
				self.poundersmg_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_poundersmg_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_POUNDERSMG]) >= autocvar_g_balance_poundersmg_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		self.poundersmg_triggerlag_button = 0; //for openbolt triggerlag
		self.poundersmg_triggerlag = 0; //for openbolt triggerlag
		
		if (self.poundersmg_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_poundersmg_clearjam_time, w_ready);
			if (self.poundersmg_unjam != 1) {
				self.poundersmg_unjam = 1;
				self.poundersmg_unjam_time = time + autocvar_g_balance_poundersmg_clearjam_time;
				self.poundersmg_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_poundersmg_primary_ammo, autocvar_g_balance_poundersmg_reload_ammo, autocvar_g_balance_poundersmg_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_poundersmg(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("medbullet_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s chest was smashed by %2$s Pounder-SMG");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s domed was pulverized by a Pounder-SMG");
		else
			w_deathtypestring = _("%s was destroyed by %s's Pounder-SMG");
	}
	return TRUE;
}
#endif
#endif
