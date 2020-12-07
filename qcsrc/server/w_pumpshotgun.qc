#ifdef REGISTER_WEAPON
REGISTER_WEAPON(PUMPSHOTGUN, w_pumpshotgun, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "pumpshotgun", "pumpshotgun", _("Pump Shotgun"))
#else
#ifdef SVQC

.float pumpshotgun_release;
.float pumpshotgun_jammed;
.float pumpshotgun_unjam;
.float pumpshotgun_unjam_time;
.float pumpshotgun_click;
.float pumpshotgun_altchoke;

void W_PumpShotgun_Attack (void)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_pumpshotgun_primary_ammo;
	bullets = autocvar_g_balance_pumpshotgun_primary_bullets;
	d = autocvar_g_balance_pumpshotgun_primary_damage;
	f = autocvar_g_balance_pumpshotgun_primary_force;
	
	if (self.pumpshotgun_altchoke == 1) {
		spread = autocvar_g_balance_pumpshotgun_primary_spreadalt;
	} else if (self.pumpshotgun_altchoke == 2) {
		spread = autocvar_g_balance_pumpshotgun_primary_spreadduckbill;
	} else {
		spread = autocvar_g_balance_pumpshotgun_primary_spread;
	}
	bulletspeed = autocvar_g_balance_pumpshotgun_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_pumpshotgun_reload_ammo);

	if (autocvar_g_balance_pumpshotgun_jamrate &&
 	(autocvar_g_balance_pumpshotgun_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your shotgun jammed\n");
		}
		self.pumpshotgun_jammed = 1;
	} else { //Start Not Jammed

	if (self.pumpshotgun_altchoke == 2) {
		local vector sdr;
				
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets);
		
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

		for (sc = 0;sc < bullets;sc = sc + 1) {
			if (self.shootfromside == 1) {
				sdr = (w_shotdir + (((sc + 0.5) / bullets) * 2 - 1) * v_up * autocvar_g_balance_pumpshotgun_primary_spreadduckbillside * g_weaponspreadfactor);
			} else {
				//Normal
				sdr = (w_shotdir + (((sc + 0.5) / bullets) * 2 - 1) * v_right * autocvar_g_balance_pumpshotgun_primary_spreadduckbillside * g_weaponspreadfactor);
			}
			
			fireBallisticBullet(w_shotorg, sdr, spread, bulletspeed, 5, d, 0, f, WEP_PUMPSHOTGUN, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_pumpshotgun_primary_coreshotaddeddamage);
		}
		endFireBallisticBullet();
	} else {
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets);
		
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_PUMPSHOTGUN, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_pumpshotgun_primary_coreshotaddeddamage);
		endFireBallisticBullet();
	}
	
	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_pumpshotgun_primary_ammo);
	
	PlayerGunRise(self, autocvar_g_balance_pumpshotgun_gunrise, random() * autocvar_g_balance_pumpshotgun_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	
	} //End Not Jammed
}

void W_PumpShotgun_Attack2 (void)
{
	sound (self, CH_WEAPON_A, "weapons/pumpshotgun_rack.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_pumpshotgun_secondary_animtime, w_ready);
		
	if (autocvar_g_casings >= 1) {
		//for (sc = 0;sc < ammoamount;sc = sc + 1)
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);
	}

}

float W_Pumpshotgun_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_pumpshotgun_reload_ammo && self.clip_load < autocvar_g_balance_pumpshotgun_primary_ammo))
	{
		if (!self.pumpshotgun_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.pumpshotgun_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.pumpshotgun_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_pumpshotgun (void)
{
	weapon_defaultspawnfunc(WEP_PUMPSHOTGUN);
}


.float pumpshotgun_primarytime;

float w_pumpshotgun(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Pumpshotgun_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.pumpshotgun_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.pumpshotgun_release) {
			self.BUTTON_ATCK2 = TRUE; //Pump
		} else {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_pumpshotgun_primary_speed, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Pumpshotgun_NeedManualReload())
	{
		if(autocvar_g_balance_pumpshotgun_reload_ammo && self.clip_load < autocvar_g_balance_pumpshotgun_primary_ammo) // forced reload
		{
			// don't force reload an empty pumpshotgun if its melee attack is active
			if not(autocvar_g_balance_pumpshotgun_secondary && self.ammo_shells < autocvar_g_balance_pumpshotgun_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.pumpshotgun_release = 0;
		}
		else
		{
		  if (self.pumpshotgun_jammed && self.pumpshotgun_unjam)
		  {
		  	if (time >= self.pumpshotgun_unjam_time) {
				self.pumpshotgun_jammed = 0;
				self.pumpshotgun_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			if (
			(self.BUTTON_ATCK) &&
			(!self.BUTTON_ATCK2) &&
			(self.pumpshotgun_release != 1) &&
			(self.pumpshotgun_jammed != 1) &&
			(time >= self.pumpshotgun_primarytime) // handle refire separately so the secondary can be fired straight after a primary
			)
			{
					if(weapon_prepareattack(0, autocvar_g_balance_pumpshotgun_primary_animtime))
					{
						W_PumpShotgun_Attack();
						self.pumpshotgun_primarytime = time + autocvar_g_balance_pumpshotgun_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_pumpshotgun_primary_animtime, w_ready);
						self.pumpshotgun_release = 1; //Slide needs to be wracked
					}
			}
			else if (
			(self.BUTTON_ATCK2) &&
			(!self.BUTTON_ATCK) &&
			(self.pumpshotgun_release == 1) &&
			(self.pumpshotgun_jammed != 1) &&
			(weapon_prepareattack(1, autocvar_g_balance_pumpshotgun_secondary_refire))
			)
			{
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				weapon_thinkf(WFRAME_FIRE1, 0, W_PumpShotgun_Attack2);
				self.pumpshotgun_release = 0; //We wracked the slide
			}
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_pumpshotgun.md3");
		precache_model ("models/weapons/v_pumpshotgun.md3");
		precache_model ("models/weapons/h_pumpshotgun.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
		precache_sound ("weapons/pumpshotgun_rack.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '55 0.5 -5';
		weapon_setup(WEP_PUMPSHOTGUN);
		self.current_ammo = ammo_shells;
	
	
		  
		  if (self.pumpshotgun_jammed && self.pumpshotgun_unjam)
		  {
		  	if (time >= self.pumpshotgun_unjam_time) {
				self.pumpshotgun_jammed = 0;
				self.pumpshotgun_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_pumpshotgun_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_PUMPSHOTGUN]) >= autocvar_g_balance_pumpshotgun_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.pumpshotgun_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_pumpshotgun_clearjam_time, w_ready);
			if (self.pumpshotgun_unjam != 1) {
				self.pumpshotgun_unjam = 1;
				self.pumpshotgun_unjam_time = time + autocvar_g_balance_pumpshotgun_clearjam_time;
				self.pumpshotgun_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the shotgun\n");
				}
			}
		} else {
			//print(ftos(self.(weapon_load[self.weapon])   ), " swl\n");
			//print(ftos(self.clip_load) , " cl\n");
			
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_pumpshotgun_reload_ammo)) {
				//Tube Magazine not empty Less than full reload time needed
				local float pumpshotgunreloadammotime;
				
				////Pumpshotgun pump time + how long it might take to load the reduced number of shells
				//pumpshotgunreloadammotime =
				//autocvar_g_balance_pumpshotgun_secondary_refire + 
				//autocvar_g_balance_pumpshotgun_secondary_animtime +
				//(autocvar_g_balance_pumpshotgun_reload_time - (autocvar_g_balance_pumpshotgun_reload_time * (self.clip_load/autocvar_g_balance_pumpshotgun_reload_ammo)));
				////Decided not to do it this way as the loading anim then takes too long, doesn't corrispond
				////Decided to just not set pumped if you didn't load all in
				////(Corrisponds to animation somewhat)
				
				pumpshotgunreloadammotime = (autocvar_g_balance_pumpshotgun_reload_time - (autocvar_g_balance_pumpshotgun_reload_time * (self.clip_load/autocvar_g_balance_pumpshotgun_reload_ammo)));

				//print (ftos(pumpshotgunreloadammotime)," set\n");
				//if (pumpshotgunreloadammotime > autocvar_g_balance_pumpshotgun_reload_time) {
				//	pumpshotgunreloadammotime = autocvar_g_balance_pumpshotgun_reload_time;
				//	print (ftos(pumpshotgunreloadammotime)," forget\n");
				//}
				
				W_Reload(autocvar_g_balance_pumpshotgun_primary_ammo, autocvar_g_balance_pumpshotgun_reload_ammo, pumpshotgunreloadammotime, "weapons/reload.wav");
				//For not full reload, we do not pump slide automatically.
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_pumpshotgun_primary_ammo, autocvar_g_balance_pumpshotgun_reload_ammo, autocvar_g_balance_pumpshotgun_reload_time, "weapons/reload.wav");
				self.pumpshotgun_release = 0;
			}
		
			if (self.BUTTON_USE) {
				
				if (self.pumpshotgun_altchoke == 2) {
					if(self.BUTTON_CROUCH) {
						self.pumpshotgun_altchoke = 1;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to an open choke on your pumpshotgun\n");
						}
					} else {
						self.pumpshotgun_altchoke = 0;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a tight choke on your pumpshotgun\n");
						}
					}
				} else if (self.pumpshotgun_altchoke == 1) {
					if(self.BUTTON_CROUCH) {
						self.pumpshotgun_altchoke = 0;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a tight choke on your pumpshotgun\n");
						}
					} else {
						self.pumpshotgun_altchoke = 2;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a duckbill choke on your pumpshotgun\n");
						}
					}
				} else if (!self.pumpshotgun_altchoke) {
					if(self.BUTTON_CROUCH) {
						self.pumpshotgun_altchoke = 2;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to a duckbill choke on your pumpshotgun\n");
						}
					} else {
						self.pumpshotgun_altchoke = 1;
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, "You change to an open choke on your pumpshotgun\n");
						}
					}
				}
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_pumpshotgun(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s found it difficult to digest with the size of the hole %2$s put in their chest");
		else
			w_deathtypestring = _("%s was gunned down with a pumpshotgun by %s");
	}
	return TRUE;
}
#endif
#endif
