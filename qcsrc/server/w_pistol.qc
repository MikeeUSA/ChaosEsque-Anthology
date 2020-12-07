#ifdef REGISTER_WEAPON
REGISTER_WEAPON(PISTOL, w_pistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "pistol", "pistol", _("Pistol"))
#else
#ifdef SVQC

.float pistol_release;
.float pistol_accumulator;
.float pistol_jammed;
.float pistol_unjam;
.float pistol_unjam_time;
.float pistol_click;
.float pistol_laserness;

void W_Pistol_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_pistol_reload_ammo);

	if (autocvar_g_balance_pistol_jamrate &&
 	(autocvar_g_balance_pistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your pistol jammed\n");
		}
		self.pistol_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, autocvar_g_balance_pistol_recoil, pSound, CH_WEAPON_A, (pDamage + pHeadshotAddedDamage) * pShots);

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	for(i = 0; i < pShots; ++i)
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, PROJECTILE_BULLETRIFLE22, 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	PlayerGunRise(self, autocvar_g_balance_pistol_gunrise, random() * autocvar_g_balance_pistol_gunrun);

	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self);

	} //End Not Jammed
}

void W_Pistol_Attack()
{
	W_Pistol_FireBullet(autocvar_g_balance_pistol_primary_spread, autocvar_g_balance_pistol_primary_damage, autocvar_g_balance_pistol_primary_headshotaddeddamage, autocvar_g_balance_pistol_primary_force, autocvar_g_balance_pistol_primary_speed, autocvar_g_balance_pistol_primary_lifetime, autocvar_g_balance_pistol_primary_ammo, WEP_PISTOL, autocvar_g_balance_pistol_primary_bulletconstant, autocvar_g_balance_pistol_primary_shots, "weapons/campingrifle_fire2.wav", autocvar_g_balance_pistol_primary_coreshotaddeddamage);
}

void W_Pistol_Attack2()
{
	W_Pistol_FireBullet(autocvar_g_balance_pistol_secondary_spread, autocvar_g_balance_pistol_secondary_damage, autocvar_g_balance_pistol_secondary_headshotaddeddamage, autocvar_g_balance_pistol_secondary_force, autocvar_g_balance_pistol_secondary_speed, autocvar_g_balance_pistol_secondary_lifetime, autocvar_g_balance_pistol_secondary_ammo, WEP_PISTOL | HITTYPE_SECONDARY, autocvar_g_balance_pistol_secondary_bulletconstant, autocvar_g_balance_pistol_secondary_shots, "weapons/campingrifle_fire2.wav", autocvar_g_balance_pistol_secondary_coreshotaddeddamage);
}

void spawnfunc_weapon_pistol (void)
{
	weapon_defaultspawnfunc(WEP_PISTOL);
}

// compatibility alias
void spawnfunc_weapon_campingpistol (void)
{
	spawnfunc_weapon_pistol();
}
void spawnfunc_weapon_sniperpistol (void)
{
	spawnfunc_weapon_pistol();
}

.void(void) pistol_bullethail_attackfunc;
.float pistol_bullethail_frame;
.float pistol_bullethail_animtime;
.float pistol_bullethail_refire;
void W_Pistol_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.pistol_bullethail_frame == WFRAME_FIRE2, self.pistol_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.pistol_bullethail_attackfunc();
		weapon_thinkf(self.pistol_bullethail_frame, self.pistol_bullethail_animtime, W_Pistol_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_Pistol_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.pistol_bullethail_attackfunc = AttackFunc;
		self.pistol_bullethail_frame = fr;
		self.pistol_bullethail_animtime = animtime;
		self.pistol_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_Pistol_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

float W_Pistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_pistol_reload_ammo && self.clip_load < min(autocvar_g_balance_pistol_primary_ammo, autocvar_g_balance_pistol_secondary_ammo)))
	{
		if (!self.pistol_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.pistol_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.pistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

.float bot_secondary_pistolmooth;
float w_pistol(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_Pistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.pistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_pistolmooth = 0;
		if(self.bot_secondary_pistolmooth == 0)
		{
			if((bot_aim(autocvar_g_balance_pistol_primary_speed, 0, autocvar_g_balance_pistol_primary_lifetime, FALSE)) && (self.pistol_release))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_pistolmooth = 1;
			}
		}
		else
		{
			if((bot_aim(autocvar_g_balance_pistol_secondary_speed, 0, autocvar_g_balance_pistol_secondary_lifetime, FALSE)) && (self.pistol_release))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.03) self.bot_secondary_pistolmooth = 0;
			}
		}
	}
	else if (req == WR_THINK && !W_Pistol_NeedManualReload())
	{
		if(autocvar_g_balance_pistol_reload_ammo && self.clip_load < min(autocvar_g_balance_pistol_primary_ammo, autocvar_g_balance_pistol_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.pistol_jammed && self.pistol_unjam)
		  {
		  	if (time >= self.pistol_unjam_time) {
				self.pistol_jammed = 0;
				self.pistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.pistol_accumulator = bound(time - autocvar_g_balance_pistol_bursttime, self.pistol_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.pistol_release)
			if (self.pistol_jammed != 1)
			if (weapon_prepareattack_check(0, autocvar_g_balance_pistol_primary_refire))
			if (time >= self.pistol_accumulator + autocvar_g_balance_pistol_primary_burstcost)
			{
				weapon_prepareattack_do(0, autocvar_g_balance_pistol_primary_refire);
				W_Pistol_BulletHail(autocvar_g_balance_pistol_primary_bullethail, W_Pistol_Attack, WFRAME_FIRE1, autocvar_g_balance_pistol_primary_animtime, autocvar_g_balance_pistol_primary_refire);
				self.pistol_accumulator += autocvar_g_balance_pistol_primary_burstcost;
				self.pistol_release = 0;
			}
			if (self.BUTTON_ATCK2)
			if (self.pistol_jammed != 1)
			{
				if (autocvar_g_balance_pistol_secondary)
				{
                 			if(autocvar_g_balance_pistol_secondary_reload)
                  		      		weapon_action(self.weapon, WR_RELOAD);
                			else
                 			{
                  				if (weapon_prepareattack_check(1, autocvar_g_balance_pistol_secondary_refire))
						if (self.pistol_release)
                     				if (time >= self.pistol_accumulator + autocvar_g_balance_pistol_secondary_burstcost)
                      		  		{
                            				weapon_prepareattack_do(1, autocvar_g_balance_pistol_secondary_refire);
                            				W_Pistol_BulletHail(autocvar_g_balance_pistol_secondary_bullethail, W_Pistol_Attack2, WFRAME_FIRE2, autocvar_g_balance_pistol_secondary_animtime, autocvar_g_balance_pistol_primary_refire);
                            				self.pistol_accumulator += autocvar_g_balance_pistol_secondary_burstcost;
			    				self.pistol_release = 0;
                        			}
                    			}
				}
			}
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				self.pistol_release = 1;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_pistol.md3");
		precache_model ("models/weapons/v_pistol.md3");
		precache_model ("models/weapons/h_pistol.iqm");
		precache_model ("models/laser_dot.iqm");
		precache_sound ("weapons/campingrifle_fire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -1 -1';
		weapon_setup(WEP_PISTOL);
		self.current_ammo = ammo_nails;
		
		  if (self.pistol_jammed && self.pistol_unjam)
		  {
		  	if (time >= self.pistol_unjam_time) {
				if (random() > 0.8) {
					self.pistol_jammed = 0;
					self.pistol_unjam = 0;
					if ((clienttype(self) == CLIENTTYPE_REAL)) {
						sprint(self, "You cleared the malfunction\n");
					}
				}
			}
		  } 
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_pistol_primary_ammo;
		ammo_amount += self.weapon_load[WEP_PISTOL] >= autocvar_g_balance_pistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_pistol_secondary_ammo;
		ammo_amount += self.weapon_load[WEP_PISTOL] >= autocvar_g_balance_pistol_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.pistol_accumulator = time - autocvar_g_balance_pistol_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.pistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_pistol_clearjam_time, w_ready);
			if (self.pistol_unjam != 1) {
				self.pistol_unjam = 1;
				self.pistol_unjam_time = time + autocvar_g_balance_pistol_clearjam_time;
				self.pistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the gun\n");
				}
			}
		} else {
			if (self.BUTTON_USE) {
				if (self.laser_on)
					self.laser_on = FALSE;
				else {
					if (self.pistol_laserness == 1) {
						//print("more\n");
						self.laser_alpha = 0.45;
						self.laser_size = 1.00;
						self.pistol_laserness = 2;
					} else if (self.pistol_laserness == 2) {
						//print("moreer\n");
						self.laser_alpha = 0.65;
						self.laser_size = 0.75;
						self.pistol_laserness = 3;
					} else if (self.pistol_laserness == 3) {
						//print("intense\n");
						self.laser_alpha = 0.85;
						self.laser_size = 0.5;
						self.pistol_laserness = 0;
					} else {
						//print("Standard\n");
						self.laser_alpha = 0.25;
						self.laser_size = 1.25;
						self.pistol_laserness = 1;	
					}
					self.laser_on = TRUE;
				}
			} else {
				W_Reload(min(autocvar_g_balance_pistol_primary_ammo, autocvar_g_balance_pistol_secondary_ammo), autocvar_g_balance_pistol_reload_ammo, autocvar_g_balance_pistol_reload_time, "weapons/reload.wav");
				self.pistol_click = 0;
			}
		}
	}
	return TRUE;
};
#endif
#ifdef CSQC
float w_pistol(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent)
		{
			if(w_random < 0.2)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.4)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.5)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/ric1.wav");
		precache_sound("weapons/ric2.wav");
		precache_sound("weapons/ric3.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s quickly self-dispached");
		else
			w_deathtypestring = _("%s committed suicide via gunshot wound");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_BOUNCE)
				w_deathtypestring = _("%s failed to hide from %s's quick trigger finger");
			else
				w_deathtypestring = _("%s by %s The Pistoleer");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s tried to hide from %s's pistol");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s was executed by %s");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s was plugged in the chest by %s");
				else
					w_deathtypestring = _("%s was shot down by %s");
			}
		}
	}
	return TRUE;
}
#endif
#endif
