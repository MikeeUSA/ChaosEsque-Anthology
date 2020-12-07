#ifdef REGISTER_WEAPON
REGISTER_WEAPON(P90, w_p90, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "p90", "p90", _("P90"))
#else
#ifdef SVQC

.float p90_release;
.float p90_jammed;
.float p90_unjam;
.float p90_unjam_time;
.float p90_click;
.float p90_animempty;
.float p90_animset;
.float p90_nextanim;
.float p90_nextbot;
.float p90_overheat_cnt;
.float p90_overheated_until;
.float p90_laser_on;
float p90autoskincolorset;
.float p90_customskin;

void W_P90_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_p90_primary_ammo;
	d = autocvar_g_balance_p90_primary_damage;
	f = autocvar_g_balance_p90_primary_force;
	//spread = autocvar_g_balance_p90_primary_spread;
	spread = bound(autocvar_g_balance_p90_spread_min, autocvar_g_balance_p90_spread_min + (autocvar_g_balance_p90_spread_add * self.misc_bulletcounter), autocvar_g_balance_p90_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_p90_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_5n7_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_p90_reload_ammo);
	
	if (autocvar_g_balance_p90_jamrate &&
 	(autocvar_g_balance_p90_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your P90 jammed\n");
		}
		self.p90_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_p90_primary_headshotaddeddamage, f, WEP_P90, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_p90_primary_coreshotaddeddamage);
	endFireBallisticBullet();
	
	//Note: P90s "pistol" bullet is a rifle shaped bullet

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.35;
		self.punchangle_y = random () - 0.35;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_p90_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_p90_gunrise, random() * autocvar_g_balance_p90_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '2.50 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * -50 - 25) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 61, self, '-5.5 2.5 0');


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.p90_overheat_cnt),"_Firing\n");
		
	    	self.p90_overheat_cnt = self.p90_overheat_cnt + autocvar_g_balance_p90_heatconstant;
         
	    	if (self.p90_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your P90 overheated\n");
			}
				
			self.p90_overheated_until = time + (autocvar_g_balance_p90_cooldownwait * (self.p90_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	

	
	} //End Not Jammed
}


float W_P90_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_p90_reload_ammo && self.clip_load < autocvar_g_balance_p90_primary_ammo))
	{
		if (!self.p90_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.p90_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.p90_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_p90 (void)
{
	weapon_defaultspawnfunc(WEP_P90);
}

float SMI_AbdBld_ChooseBaseTerrainType();

float w_p90_skin_autocolorset(void) {

			local float myautocolor;
			local float myp90autoskincolorset;
			//Numbers as seen in mutator_spawnvehicles.qc
			//BUILDING_SC_TERRAIN_SNOW = 1;
			//BUILDING_SC_TERRAIN_DUST = 2;
			//BUILDING_SC_TERRAIN_GREYSTONE = 3;
			//BUILDING_SC_TERRAIN_BLACKSTONE = 4;
			
			myautocolor = SMI_AbdBld_ChooseBaseTerrainType();
		
			if (myautocolor == 1) {
				myp90autoskincolorset = 4; //Snow
			} else if (myautocolor == 2) {
				myp90autoskincolorset = 1; //Dust
			} else {
			
				if(
					(strstrofs(mapname, "desert", 0) != -1 )
					|| (strstrofs(mapname, "sand", 0) != -1 )
				) {
				
					myp90autoskincolorset = 1; //Dust
				} else if(
					(strstrofs(mapname, "snow", 0) != -1 )
					|| (strstrofs(mapname, "winter", 0) != -1 )
					|| (strstrofs(mapname, "ice", 0) != -1 )
				) {
					myp90autoskincolorset = 4; //Snow
				} else {
					myp90autoskincolorset = -10; //Black
				}
			}
		
		return myp90autoskincolorset;
}

float w_p90_skin(entity player)
{
	if (autocvar_g_allowcustomweaponskins && player && (player.p90_customskin > 0)) {
		return player.p90_customskin;
	} else if (autocvar_g_balance_p90_skin == -1) {
	
		if not(p90autoskincolorset) {
			p90autoskincolorset = w_p90_skin_autocolorset();
		}
		
		
		if (p90autoskincolorset == -10) {
			return 0;
		} else {
			return p90autoskincolorset;
		}
	} else {
		return autocvar_g_balance_p90_skin;
	}
}

.float p90_primarytime;

float w_p90(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK) {
			//For P90, only the primary trigger is relevant for overheating
				//print(ftos(self.p90_overheat_cnt),"_Cooldown\n");
			
			if (self.p90_overheat_cnt < autocvar_g_balance_p90_heatmin) {
				self.p90_overheat_cnt = autocvar_g_balance_p90_heatmin;
			} else {
				self.p90_overheat_cnt = self.p90_overheat_cnt - (autocvar_g_balance_p90_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_P90_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.p90_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		
		
			if (self.p90_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_p90_primary_speed, 0, 0.001, FALSE);
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
	else if (req == WR_THINK && !W_P90_NeedManualReload())
	{
		if(autocvar_g_balance_p90_reload_ammo && self.clip_load < autocvar_g_balance_p90_primary_ammo) // forced reload
		{
			// don't force reload an empty p90 if its melee attack is active
			if not(autocvar_g_balance_p90_secondary && self.ammo_nails < autocvar_g_balance_p90_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.p90_release = 0;
		}
		else
		{
		  if (self.p90_jammed && self.p90_unjam)
		  {
		  	if (time >= self.p90_unjam_time) {
				self.p90_jammed = 0;
				self.p90_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.p90_release || self.BUTTON_ATCK2)
			if (self.p90_jammed != 1)
			if ((time > self.p90_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.BUTTON_ATCK2) {
			  	//Fullauto (aug has a 2 stage trigger, simulating that)
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.p90_nextbot)," \n");
				} else {
					self.p90_nextbot = 0;
				}
				
				if (time >= self.p90_nextbot) {
					W_P90_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_p90_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_p90_primary_animtime, w_ready);
					self.p90_release = 0;
					self.p90_animempty = 1;
					self.p90_animset = 1;
					self.p90_nextanim = time + autocvar_g_balance_p90_primary_rfanim;
					bp_skipme = 1;
					//self.p90_nextbot = time + (autocvar_g_balance_p90_primary_refire * 50 * random());
					self.p90_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.p90_release = 1;
					self.p90_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.p90_nextbot)," \n");
				} else {
					self.p90_nextbot = 0;
				}
				
				if (time >= self.p90_nextbot) {
					W_P90_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_p90_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_p90_secondary_animtime, w_ready);
					self.p90_release = 0;
					self.p90_animempty = 1;
					self.p90_animset = 1;
					self.p90_nextanim = time + autocvar_g_balance_p90_secondary_rfanim;
					bp_skipme = 1;
					//self.p90_nextbot = time + (autocvar_g_balance_p90_secondary_refire * 50 * random());
					self.p90_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			
			if not(bp_skipme) {
				if (self.p90_jammed != 1)
				if (time >= self.p90_nextanim)
				if (self.p90_animempty)
				{
					self.p90_animempty = 0;
					self.p90_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.p90_release = 1;
			}
			
			if not(self.BUTTON_ATCK && self.BUTTON_ATCK2) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.p90_animset)
			//if (self.p90_jammed != 1) {
			//	
			//		if (self.p90_animempty)
			//			self.weaponname = "p90_empty";
			//		else
			//			self.weaponname = "p90";
			//}
			
			self.p90_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/laser_dot.iqm");
		precache_model ("models/weapons/g_p90.md3");
		precache_model ("models/weapons/v_p90.md3");
		precache_model ("models/weapons/h_p90.iqm");
		
		//precache_model ("models/weapons/v_p90_empty.md3");
		//precache_model ("models/weapons/h_p90_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.p90_overheat_cnt = autocvar_g_balance_p90_heatmin;
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -3.0';
		self.weaponaltaim = '40 -0.35 -4.7';
		weapon_setup(WEP_P90);
		self.current_ammo = ammo_nails;
		
		
			//if (self.p90_animempty)
			//	self.weaponname = "p90_empty";
			//else
			//	self.weaponname = "p90";
				
	
		  
		  if (self.p90_jammed && self.p90_unjam)
		  {
		  	if (time >= self.p90_unjam_time) {
				self.p90_jammed = 0;
				self.p90_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_p90_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_P90]) >= autocvar_g_balance_p90_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.p90_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_p90_clearjam_time, w_ready);
			if (self.p90_unjam != 1) {
				self.p90_unjam = 1;
				self.p90_unjam_time = time + autocvar_g_balance_p90_clearjam_time;
				self.p90_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			if (self.BUTTON_USE) {
				if (self.p90_laser_on) {
					self.p90_laser_on = FALSE;
				} else {
					self.p90_laser_on = TRUE;	
				}
			} else {
				W_Reload(autocvar_g_balance_p90_primary_ammo, autocvar_g_balance_p90_reload_ammo, autocvar_g_balance_p90_reload_time, "weapons/reload.wav");
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_p90(float req)
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
			w_deathtypestring = _("%s enjoyed greeting from %s's P90");
		else
			w_deathtypestring = _("%s shot dead by %s with a P90");
	}
	return TRUE;
}
#endif
#endif
