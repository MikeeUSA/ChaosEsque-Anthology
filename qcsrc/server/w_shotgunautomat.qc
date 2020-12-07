#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SHOTGUNAUTOMAT, w_shotgunautomat, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "shotgunautomat", "shotgunautomat", _("ShotgunAutomat"))
#else
#ifdef SVQC
.float shotgunautomat_jammed;
.float shotgunautomat_unjam;
.float shotgunautomat_unjam_time;
.float shotgunautomat_click;

void W_ShotgunAutomat_Attack (void)
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	local entity flash;

	ammoamount = autocvar_g_balance_shotgunautomat_primary_ammo;
	bullets = autocvar_g_balance_shotgunautomat_primary_bullets;
	d = autocvar_g_balance_shotgunautomat_primary_damage;
	f = autocvar_g_balance_shotgunautomat_primary_force;
	spread = autocvar_g_balance_shotgunautomat_primary_spread;
	bulletspeed = autocvar_g_balance_shotgunautomat_primary_speed;
	bulletconstant = autocvar_g_balance_shotgunautomat_primary_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_shotgunautomat_reload_ammo);

	if (autocvar_g_balance_shotgunautomat_jamrate &&
 	(autocvar_g_balance_shotgunautomat_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your automatic shotgun jammed\n");
		}
		self.shotgunautomat_jammed = 1;
	} else { //Start Not Jammed
	
	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUNAUTOMAT, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_shotgunautomat_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_shotgunautomat_primary_ammo);

	PlayerGunRise(self, autocvar_g_balance_shotgunautomat_gunrise, random() * autocvar_g_balance_shotgunautomat_gunrun);

	// casing code
	if (autocvar_g_casings >= 1)
		for (sc = 0;sc < ammoamount;sc = sc + 1)
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	
	} //End Not Jammed
}

entity lgbeam_owner_ent;
void shotgunautomat_meleethink (void)
{
	// store time when we started swinging down inside self.cnt
	if(!self.cnt)
		self.cnt = time;

	makevectors(self.realowner.v_angle);
	vector angle;
	angle = v_forward;

	float meleetime;
	meleetime = autocvar_g_balance_shotgunautomat_secondary_melee_time * W_WeaponRateFactor();

	// perform trace
	float f;
	f = (self.cnt + meleetime - time) / meleetime * 2 - 1;
	vector targpos;
	targpos = self.realowner.origin + self.realowner.view_ofs + angle * autocvar_g_balance_shotgunautomat_secondary_melee_range + v_right * f * autocvar_g_balance_shotgunautomat_secondary_melee_swing + v_up * f * autocvar_g_balance_shotgunautomat_secondary_melee_swing;

	if(!lgbeam_owner_ent)
	{
		lgbeam_owner_ent = spawn();
		lgbeam_owner_ent.classname = "lgbeam_owner_ent";
	}
	WarpZone_traceline_antilag(lgbeam_owner_ent, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, lgbeam_owner_ent, ANTILAG_LATENCY(self.realowner));

	// apply the damage, also remove self
	if(trace_fraction < 1 && trace_ent.takedamage == DAMAGE_AIM && (trace_ent.classname == "player" || trace_ent.classname == "body"))
	{
		vector force;
		force = angle * autocvar_g_balance_shotgunautomat_secondary_force;
		if(accuracy_isgooddamage(self.realowner, trace_ent))
			accuracy_add(self.realowner, WEP_SHOTGUNAUTOMAT, 0, autocvar_g_balance_shotgunautomat_secondary_damage * min(1, f + 1));
		Damage (trace_ent, self.realowner, self.realowner, autocvar_g_balance_shotgunautomat_secondary_damage * min(1, f + 1), WEP_SHOTGUNAUTOMAT | HITTYPE_SECONDARY , self.realowner.origin + self.realowner.view_ofs, force);
		remove(self);
	}
	else if(time >= self.cnt + meleetime || (self.realowner.deadflag != DEAD_NO && autocvar_g_balance_shotgunautomat_secondary_melee_no_doubleslap)) // missed or owner died, remove ent
		remove(self);
	else // continue swinging the weapon in hope of hitting someone :)
		self.nextthink = time;
}

void W_ShotgunAutomat_Attack2 (void)
{
	float	sc2;
	float	ammoamount2;
	float	bullets2;
	float	d2;
	float	f2;
	float	spread2;
	float	bulletspeed2;
	float	bulletconstant2;
	local entity flash;

	ammoamount2 = autocvar_g_balance_shotgunautomat_secondary_ammo;
	bullets2 = autocvar_g_balance_shotgunautomat_secondary_bullets;
	d2 = autocvar_g_balance_shotgunautomat_secondary_damage;
	f2 = autocvar_g_balance_shotgunautomat_secondary_force;
	spread2 = autocvar_g_balance_shotgunautomat_secondary_spread;
	bulletspeed2 = autocvar_g_balance_shotgunautomat_secondary_speed;
	bulletconstant2 = autocvar_g_balance_shotgunautomat_secondary_bulletconstant;

	W_DecreaseAmmo(ammo_shells, ammoamount2, autocvar_g_balance_shotgunautomat_reload_ammo);

	if (autocvar_g_balance_shotgunautomat_jamrate &&
 	(autocvar_g_balance_shotgunautomat_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your automatic shotgun jammed\n");
		}
		self.shotgunautomat_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed2 >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d2 * bullets2);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	for (sc2 = 0;sc2 < bullets2;sc2 = sc2 + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread2, bulletspeed2, 5, d2, 0, f2, WEP_SHOTGUNAUTOMAT, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant2, autocvar_g_balance_shotgunautomat_secondary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_shotgunautomat_secondary_ammo);
	
	PlayerGunRise(self, autocvar_g_balance_shotgunautomat_gunrise * ammoamount2, random() * autocvar_g_balance_shotgunautomat_gunrun * ammoamount2);

	// casing code
	if (autocvar_g_casings >= 1) {
		for (sc2 = 0;sc2 < ammoamount2;sc2 = sc2 + 1) {
				SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);		
		}
	}

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');
	
	} //End Not Jammed
}

void spawnfunc_weapon_shotgunautomat (void)
{
	weapon_defaultspawnfunc(WEP_SHOTGUNAUTOMAT);
}

float W_shotgunautomat_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_shotgunautomat_reload_ammo && self.clip_load < min(autocvar_g_balance_shotgunautomat_primary_ammo, autocvar_g_balance_shotgunautomat_secondary_ammo)))
	{
		if (!self.shotgunautomat_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.shotgunautomat_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.shotgunautomat_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

.float shotgun_primarytime;
.float shotgun_secondarytime;

float w_shotgunautomat(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_shotgunautomat_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.shotgunautomat_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		if(vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_shotgunautomat_secondary_melee_range)
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		else
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
	}
	else if (req == WR_THINK && !W_shotgunautomat_NeedManualReload())
	{
		if(autocvar_g_balance_shotgunautomat_reload_ammo && self.clip_load < min(autocvar_g_balance_shotgunautomat_primary_ammo, autocvar_g_balance_shotgunautomat_secondary_ammo)) // forced reload
		{
			weapon_action(self.weapon, WR_RELOAD);
		}
		else
		{
		  if (self.shotgunautomat_jammed && self.shotgunautomat_unjam)
		  {
		  	if (time >= self.shotgunautomat_unjam_time) {
				self.shotgunautomat_jammed = 0;
				self.shotgunautomat_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			if ((self.BUTTON_ATCK) &&
			(self.shotgunautomat_jammed != 1))
			{
				if (time >= self.shotgun_primarytime) // handle refire separately so the secondary can be fired straight after a primary
				{
					if(weapon_prepareattack(0, autocvar_g_balance_shotgunautomat_primary_animtime))
					{
						W_ShotgunAutomat_Attack();
						self.shotgun_primarytime = time + autocvar_g_balance_shotgunautomat_primary_refire;
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgunautomat_primary_animtime, w_ready);
					}
				}
			}
			else if ((self.BUTTON_ATCK2) &&
			(self.shotgunautomat_jammed != 1))
			{
				if (time >= self.shotgun_secondarytime) // handle refire separately so the secondary can be fired straight after a secondary
				{
					if(weapon_prepareattack(0, autocvar_g_balance_shotgunautomat_secondary_animtime))
					{
					W_ShotgunAutomat_Attack2();
					self.shotgun_secondarytime = time + autocvar_g_balance_shotgunautomat_secondary_refire;
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_shotgunautomat_secondary_animtime, w_ready);
					}
				}
			}
			////END NORMAL////
		  }
		}
		//if (self.clip_load >= 0) // we are not currently reloading
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_shotgunautomat.md3");
		precache_model ("models/weapons/v_shotgunautomat.md3");
		precache_model ("models/weapons/h_shotgunautomat.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
		precache_sound ("weapons/shotgun_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '28 0.02 -2.6';
		weapon_setup(WEP_SHOTGUNAUTOMAT);
		self.current_ammo = ammo_shells;
	
	
	
		  if (self.shotgunautomat_jammed && self.shotgunautomat_unjam)
		  {
		  	if (time >= self.shotgunautomat_unjam_time) {
				self.shotgunautomat_jammed = 0;
				self.shotgunautomat_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_shotgunautomat_primary_ammo;
		ammo_amount += self.weapon_load[WEP_SHOTGUNAUTOMAT] >= autocvar_g_balance_shotgunautomat_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.shotgunautomat_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_shotgunautomat_clearjam_time, w_ready);
			if (self.shotgunautomat_unjam != 1) {
				self.shotgunautomat_unjam = 1;
				self.shotgunautomat_unjam_time = time + autocvar_g_balance_shotgunautomat_clearjam_time;
				self.shotgunautomat_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_shotgunautomat_primary_ammo, autocvar_g_balance_shotgunautomat_reload_ammo, autocvar_g_balance_shotgunautomat_reload_time, "weapons/reload.wav");
			self.shotgunautomat_click = 0;
		}
	}
	return TRUE;
};
#endif
#ifdef CSQC
.float prevric;
float w_shotgunautomat(float req)
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
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%2$s ^7gave %1$s ^7all three ^2barrels");
		else if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%s got a few pellets to the chest thanks to %s");
		else
			w_deathtypestring = _("%s was gunned by %s");
	}
	return TRUE;
}
#endif
#endif
