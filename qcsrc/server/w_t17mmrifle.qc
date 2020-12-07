#ifdef REGISTER_WEAPON
REGISTER_WEAPON(T17MMRIFLE, w_t17mmrifle, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "t17mmrifle", "t17mmrifle", _("T17mm Rifle"))
#else
#ifdef SVQC

.float t17mmrifle_jammed;
.float t17mmrifle_unjam;
.float t17mmrifle_unjam_time;
.float t17mmrifle_accumulator;
.float t17mmrifle_release;
.float t17mmrifle_release2;
.float t17mmrifle_click;
.float t17mmrifle_empty;
.float t17mmrifle_animset;
.float t17mmrifle_notnew;
.float t17mmrifle_casing;

void W_T17MMRIFLE_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pTracer, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	entity flash;
	
	if (self.t17mmrifle_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_t17mmrifle_reload_ammo);

	if(autocvar_g_balance_t17mmrifle_jamrate &&
 	(autocvar_g_balance_t17mmrifle_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.t17mmrifle_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, 2, pSound, CH_WEAPON_A, (pDamage + pHeadshotAddedDamage) * pShots);
	
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);
	

	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}

	for(i = 0; i < pShots; ++i)
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, PROJECTILE_BULLETRIFLE17MM, 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		//shake things around
		self.punchangle_x = (random () - 0.5)*4;
		self.punchangle_y = (random () - 0.5)*4;
		self.punchangle_z = (random () - 0.5)*14;
	}

	PlayerGunRise(self, autocvar_g_balance_t17mmrifle_gunrise, random() * autocvar_g_balance_t17mmrifle_gunrun);
	
		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '18 0 0');
	
	}
}

void W_T17MMRIFLE_Attack()
{
	W_T17MMRIFLE_FireBullet(autocvar_g_balance_t17mmrifle_primary_spread, autocvar_g_balance_t17mmrifle_primary_damage, autocvar_g_balance_t17mmrifle_primary_headshotaddeddamage, autocvar_g_balance_t17mmrifle_primary_force, autocvar_g_balance_t17mmrifle_primary_speed, autocvar_g_balance_t17mmrifle_primary_lifetime, autocvar_g_balance_t17mmrifle_primary_ammo, WEP_T17MMRIFLE, autocvar_g_balance_projectile_t17mmrifle_bulletconstant, autocvar_g_balance_t17mmrifle_primary_tracer, autocvar_g_balance_t17mmrifle_primary_shots, "weapons/uzi_fire_slow_bass.wav", autocvar_g_balance_t17mmrifle_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_t17mmrifle (void)
{
	weapon_defaultspawnfunc(WEP_T17MMRIFLE);
}

.void(void) t17mmrifle_bullethail_attackfunc;
.float t17mmrifle_bullethail_frame;
.float t17mmrifle_bullethail_animtime;
.float t17mmrifle_bullethail_refire;
void W_T17MMRIFLE_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.t17mmrifle_bullethail_frame == WFRAME_FIRE2, self.t17mmrifle_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.t17mmrifle_bullethail_attackfunc();
		weapon_thinkf(self.t17mmrifle_bullethail_frame, self.t17mmrifle_bullethail_animtime, W_T17MMRIFLE_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_T17MMRIFLE_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.t17mmrifle_bullethail_attackfunc = AttackFunc;
		self.t17mmrifle_bullethail_frame = fr;
		self.t17mmrifle_bullethail_animtime = animtime;
		self.t17mmrifle_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_T17MMRIFLE_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_T17MMRIFLE_RackBolt (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_t17mmrifle_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		if (self.t17mmrifle_casing) {
			self.t17mmrifle_casing = 0;
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 + 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 29, self);
		}
	}
}

void W_T17MMRIFLE_RackBoltLoseAmmo (void)
{
	//Operate the bolt for no reason while ammo is there, extracts ammo
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_t17mmrifle_primary_ammo, autocvar_g_balance_t17mmrifle_reload_ammo);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_t17mmrifle_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		SpawnLiveCartridge_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 29, self, '0 0 0', autocvar_g_balance_t17mmrifle_primary_ammo);
	}
}

void W_T17MMRIFLE_RackBoltForward (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_t17mmrifle_boltaction_animtime*0.5, w_ready);
}


float W_T17MMRIFLE_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_t17mmrifle_reload_ammo && self.clip_load < min(autocvar_g_balance_t17mmrifle_primary_ammo, autocvar_g_balance_t17mmrifle_secondary_ammo)))
	{
		if (!self.t17mmrifle_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.t17mmrifle_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.t17mmrifle_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_t17mmrifle(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_T17MMRIFLE_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.t17mmrifle_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.t17mmrifle_empty) {
			if (!self.t17mmrifle_release2) {
				self.BUTTON_ATCK2 = TRUE;
			}
		} else if (!self.t17mmrifle_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_t17mmrifle_primary_speed, 0, autocvar_g_balance_t17mmrifle_primary_lifetime, FALSE))
			&& (self.t17mmrifle_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_T17MMRIFLE_NeedManualReload())
	{
		self.t17mmrifle_notnew = 1;
		
		if(autocvar_g_balance_t17mmrifle_reload_ammo && self.clip_load < min(autocvar_g_balance_t17mmrifle_primary_ammo, autocvar_g_balance_t17mmrifle_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.t17mmrifle_jammed && self.t17mmrifle_unjam)
		  {
		  	if (time >= self.t17mmrifle_unjam_time) {
				self.t17mmrifle_jammed = 0;
				self.t17mmrifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.t17mmrifle_accumulator = bound(time - autocvar_g_balance_t17mmrifle_bursttime, self.t17mmrifle_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.t17mmrifle_jammed != 1)
			if (!self.BUTTON_ATCK2)
			if (self.t17mmrifle_release)
			if (!self.t17mmrifle_empty)
			if (weapon_prepareattack_check(0, autocvar_g_balance_t17mmrifle_primary_refire))
			if (time >= self.t17mmrifle_accumulator + autocvar_g_balance_t17mmrifle_primary_burstcost)
			{
				self.t17mmrifle_casing = 1;
				weapon_prepareattack_do(0, autocvar_g_balance_t17mmrifle_primary_refire);
				W_T17MMRIFLE_BulletHail(autocvar_g_balance_t17mmrifle_primary_bullethail, W_T17MMRIFLE_Attack, WFRAME_FIRE1, autocvar_g_balance_t17mmrifle_primary_animtime, autocvar_g_balance_t17mmrifle_primary_refire);
				self.t17mmrifle_accumulator += autocvar_g_balance_t17mmrifle_primary_burstcost;
				
				self.t17mmrifle_release = 0;
			}
			if (self.BUTTON_ATCK2)
			if (self.t17mmrifle_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.t17mmrifle_release
				&& !self.t17mmrifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_t17mmrifle_boltaction_refire*0.5))) {
					self.t17mmrifle_release2 = 1; //Any time 2nd button is touched
					if (self.t17mmrifle_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltForward);
						self.t17mmrifle_empty = 0;
						self.t17mmrifle_release = 1; //We operated the bolt
						self.t17mmrifle_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBolt);
						self.t17mmrifle_empty = 1;
						self.t17mmrifle_animset = 1;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.t17mmrifle_release
				&& !self.t17mmrifle_release2
				&& !autocvar_g_balance_t17mmrifle_noneedlessboltuse) 
				&& (weapon_prepareattack(1, autocvar_g_balance_t17mmrifle_boltaction_refire*0.5))) {
					self.t17mmrifle_release2 = 1; //Any time 2nd button is touched
					if (self.t17mmrifle_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltForward);
						self.t17mmrifle_empty = 0;
						self.t17mmrifle_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltLoseAmmo);
						self.t17mmrifle_empty = 1;
						self.t17mmrifle_animset = 1;
					}
					
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.t17mmrifle_release2 = 0;
			}
			
			if (self.t17mmrifle_animset) {
				if (self.t17mmrifle_empty)
					self.weaponname = "t17mmrifle_empty";
				else
					self.weaponname = "t17mmrifle";
			}
			
			self.t17mmrifle_animset = 0;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK && !autocvar_g_balance_t17mmrifle_noneedlessboltuse)
	{
		self.t17mmrifle_notnew = 1;
		//Needs reload, can op bolt tho
		
			if (self.BUTTON_ATCK2)
			if (self.t17mmrifle_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.t17mmrifle_release
				&& !self.t17mmrifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_t17mmrifle_boltaction_refire*0.5))) {
					self.t17mmrifle_release2 = 1; //Any time 2nd button is touched
					if (self.t17mmrifle_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltForward);
						self.t17mmrifle_empty = 0;
						self.t17mmrifle_release = 1; //We operated the bolt
						self.t17mmrifle_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBolt);
						self.t17mmrifle_empty = 1;
						self.t17mmrifle_animset = 1;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.t17mmrifle_release
				&& !self.t17mmrifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_t17mmrifle_boltaction_refire*0.5))) {
					self.t17mmrifle_release2 = 1; //Any time 2nd button is touched
					if (self.t17mmrifle_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltForward);
						self.t17mmrifle_empty = 0;
						self.t17mmrifle_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_T17MMRIFLE_RackBoltForward);
						self.t17mmrifle_empty = 1;
						self.t17mmrifle_animset = 1;
					}
					
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.t17mmrifle_release2 = 0;
			}
			
			if (self.t17mmrifle_animset) {
				if (self.t17mmrifle_empty)
					self.weaponname = "t17mmrifle_empty";
				else
					self.weaponname = "t17mmrifle";
			}
			
			self.t17mmrifle_animset = 0;
			////END NORMAL////
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_t17mmrifle.md3");
		precache_model ("models/weapons/v_t17mmrifle.md3");
		precache_model ("models/weapons/h_t17mmrifle.iqm");
		precache_model ("models/weapons/v_t17mmrifle_empty.md3");
		precache_model ("models/weapons/h_t17mmrifle_empty.iqm");
		precache_model ("models/casing_long.iqm"); //Can expel these if cycle bolt when not fired
		precache_sound ("weapons/uzi_fire_slow_bass.wav");
		//precache_sound ("weapons/campingrifle_fire2.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_T17MMRIFLE);
		self.current_ammo = ammo_nails;
		
		if(self.t17mmrifle_notnew)
		{
			//Do nothing
		} else {
			self.t17mmrifle_release = 1;
			self.weaponname = "t17mmrifle";
		}
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '54 -0.35 -2.95';
		//self.weaponaltaim = '54 -0.20 -2.95';
		self.weaponaltaim = '54 0 -2.95';
				
				if (self.t17mmrifle_empty)
					self.weaponname = "t17mmrifle_empty";
				else
					self.weaponname = "t17mmrifle";
	
	
		  
		  if (self.t17mmrifle_jammed && self.t17mmrifle_unjam)
		  {
		  	if (time >= self.t17mmrifle_unjam_time) {
				self.t17mmrifle_jammed = 0;
				self.t17mmrifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_t17mmrifle_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_T17MMRIFLE]) >= autocvar_g_balance_t17mmrifle_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_t17mmrifle_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_T17MMRIFLE]) >= autocvar_g_balance_t17mmrifle_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.t17mmrifle_accumulator = time - autocvar_g_balance_t17mmrifle_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.t17mmrifle_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_t17mmrifle_clearjam_time, w_ready);
			if (self.t17mmrifle_unjam != 1) {
				self.t17mmrifle_unjam = 1;
				self.t17mmrifle_unjam_time = time + autocvar_g_balance_t17mmrifle_clearjam_time;
				self.t17mmrifle_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.t17mmrifle_click = 0;
			W_Reload(min(autocvar_g_balance_t17mmrifle_primary_ammo, autocvar_g_balance_t17mmrifle_secondary_ammo), autocvar_g_balance_t17mmrifle_reload_ammo, autocvar_g_balance_t17mmrifle_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_t17mmrifle(float req)
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
		w_deathtypestring = _("%s is now thinking with portals");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_BOUNCE)
				w_deathtypestring = _("%s failed to hide from %s's reloading skills");
			else
				w_deathtypestring = _("%s died in %s's T17mm rifle reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's T17mm rifle");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s was was killed by an anti-material round from %s's T17mm Rifle");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s was put down by an anti-material round from %s's T17mm Rifle");
				else
					w_deathtypestring = _("%s was killed by an anti-material round from %s's T17mm Rifle rifle");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_t17mmrifle (void)
//{
//	weapon_defaultspawnfunc(WEP_T17MMRIFLE);
//}
