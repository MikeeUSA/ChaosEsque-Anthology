#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MOSIN, w_mosin, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "mosin", "mosin", _("Mosin-Nagant"))
#else
#ifdef SVQC

.float mosin_jammed;
.float mosin_unjam;
.float mosin_unjam_time;
.float mosin_accumulator;
.float mosin_release;
.float mosin_release2;
.float mosin_click;
.float mosin_empty;
.float mosin_animset;
.float mosin_notnew;
.float mosin_casing;

void W_MOSIN_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pTracer, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	
	if (self.mosin_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_mosin_reload_ammo);

	if(autocvar_g_balance_mosin_jamrate &&
 	(autocvar_g_balance_mosin_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.mosin_jammed = 1;
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
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, (pTracer ? PROJECTILE_BULLETRIFLE30_G_T : PROJECTILE_BULLETRIFLE30_G), 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	PlayerGunRise(self, autocvar_g_balance_mosin_gunrise, random() * autocvar_g_balance_mosin_gunrun);
	
	}
}

void W_MOSIN_Attack()
{
	W_MOSIN_FireBullet(autocvar_g_balance_mosin_primary_spread, autocvar_g_balance_mosin_primary_damage, autocvar_g_balance_mosin_primary_headshotaddeddamage, autocvar_g_balance_mosin_primary_force, autocvar_g_balance_mosin_primary_speed, autocvar_g_balance_mosin_primary_lifetime, autocvar_g_balance_mosin_primary_ammo, WEP_MOSIN, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_balance_mosin_primary_tracer, autocvar_g_balance_mosin_primary_shots, "weapons/campingrifle_fire.wav", autocvar_g_balance_mosin_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_mosin (void)
{
	weapon_defaultspawnfunc(WEP_MOSIN);
}

.void(void) mosin_bullethail_attackfunc;
.float mosin_bullethail_frame;
.float mosin_bullethail_animtime;
.float mosin_bullethail_refire;
void W_MOSIN_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.mosin_bullethail_frame == WFRAME_FIRE2, self.mosin_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.mosin_bullethail_attackfunc();
		weapon_thinkf(self.mosin_bullethail_frame, self.mosin_bullethail_animtime, W_MOSIN_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_MOSIN_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.mosin_bullethail_attackfunc = AttackFunc;
		self.mosin_bullethail_frame = fr;
		self.mosin_bullethail_animtime = animtime;
		self.mosin_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_MOSIN_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_MOSIN_RackBolt (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_mosin_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		if (self.mosin_casing) {
			self.mosin_casing = 0;
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 125, self);
		}
	}
}

void W_MOSIN_RackBoltLoseAmmo (void)
{
	//Operate the bolt for no reason while ammo is there, extracts ammo
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_mosin_primary_ammo, autocvar_g_balance_mosin_reload_ammo);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_mosin_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		SpawnLiveCartridge_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 125, self, '0 0 0', autocvar_g_balance_mosin_primary_ammo);
	}
}

void W_MOSIN_RackBoltForward (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_mosin_boltaction_animtime*0.5, w_ready);
}


float W_MOSIN_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_mosin_reload_ammo && self.clip_load < min(autocvar_g_balance_mosin_primary_ammo, autocvar_g_balance_mosin_secondary_ammo)))
	{
		if (!self.mosin_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.mosin_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.mosin_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_mosin(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_MOSIN_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.mosin_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.mosin_empty) {
			if (!self.mosin_release2) {
				self.BUTTON_ATCK2 = TRUE;
			}
		} else if (!self.mosin_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_mosin_primary_speed, 0, autocvar_g_balance_mosin_primary_lifetime, FALSE))
			&& (self.mosin_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_MOSIN_NeedManualReload())
	{
		self.mosin_notnew = 1;
		
		if(autocvar_g_balance_mosin_reload_ammo && self.clip_load < min(autocvar_g_balance_mosin_primary_ammo, autocvar_g_balance_mosin_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.mosin_jammed && self.mosin_unjam)
		  {
		  	if (time >= self.mosin_unjam_time) {
				self.mosin_jammed = 0;
				self.mosin_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.mosin_accumulator = bound(time - autocvar_g_balance_mosin_bursttime, self.mosin_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.mosin_jammed != 1)
			if (!self.BUTTON_ATCK2)
			if (self.mosin_release)
			if (!self.mosin_empty)
			if (weapon_prepareattack_check(0, autocvar_g_balance_mosin_primary_refire))
			if (time >= self.mosin_accumulator + autocvar_g_balance_mosin_primary_burstcost)
			{
				self.mosin_casing = 1;
				weapon_prepareattack_do(0, autocvar_g_balance_mosin_primary_refire);
				W_MOSIN_BulletHail(autocvar_g_balance_mosin_primary_bullethail, W_MOSIN_Attack, WFRAME_FIRE1, autocvar_g_balance_mosin_primary_animtime, autocvar_g_balance_mosin_primary_refire);
				self.mosin_accumulator += autocvar_g_balance_mosin_primary_burstcost;
				
				self.mosin_release = 0;
			}
			if (self.BUTTON_ATCK2)
			if (self.mosin_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.mosin_release
				&& !self.mosin_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_mosin_boltaction_refire*0.5))) {
					self.mosin_release2 = 1; //Any time 2nd button is touched
					if (self.mosin_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltForward);
						self.mosin_empty = 0;
						self.mosin_release = 1; //We operated the bolt
						self.mosin_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBolt);
						self.mosin_empty = 1;
						self.mosin_animset = 1;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.mosin_release
				&& !self.mosin_release2
				&& !autocvar_g_balance_mosin_noneedlessboltuse) 
				&& (weapon_prepareattack(1, autocvar_g_balance_mosin_boltaction_refire*0.5))) {
					self.mosin_release2 = 1; //Any time 2nd button is touched
					if (self.mosin_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltForward);
						self.mosin_empty = 0;
						self.mosin_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltLoseAmmo);
						self.mosin_empty = 1;
						self.mosin_animset = 1;
					}
					
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.mosin_release2 = 0;
			}
			
			if (self.mosin_animset) {
				if (self.mosin_empty)
					self.weaponname = "mosin_empty";
				else
					self.weaponname = "mosin";
			}
			
			self.mosin_animset = 0;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK && !autocvar_g_balance_mosin_noneedlessboltuse)
	{
		self.mosin_notnew = 1;
		//Needs reload, can op bolt tho
		
			if (self.BUTTON_ATCK2)
			if (self.mosin_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.mosin_release
				&& !self.mosin_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_mosin_boltaction_refire*0.5))) {
					self.mosin_release2 = 1; //Any time 2nd button is touched
					if (self.mosin_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltForward);
						self.mosin_empty = 0;
						self.mosin_release = 1; //We operated the bolt
						self.mosin_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBolt);
						self.mosin_empty = 1;
						self.mosin_animset = 1;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.mosin_release
				&& !self.mosin_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_mosin_boltaction_refire*0.5))) {
					self.mosin_release2 = 1; //Any time 2nd button is touched
					if (self.mosin_empty == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltForward);
						self.mosin_empty = 0;
						self.mosin_animset = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_MOSIN_RackBoltForward);
						self.mosin_empty = 1;
						self.mosin_animset = 1;
					}
					
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.mosin_release2 = 0;
			}
			
			if (self.mosin_animset) {
				if (self.mosin_empty)
					self.weaponname = "mosin_empty";
				else
					self.weaponname = "mosin";
			}
			
			self.mosin_animset = 0;
			////END NORMAL////
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_mosin.md3");
		precache_model ("models/weapons/v_mosin.md3");
		precache_model ("models/weapons/h_mosin.iqm");
		precache_model ("models/weapons/v_mosin_empty.md3");
		precache_model ("models/weapons/h_mosin_empty.iqm");
		precache_model ("models/items/casingriflebullet.iqm"); //Can expel these if cycle bolt when not fired
		precache_sound ("weapons/campingrifle_fire.wav");
		precache_sound ("weapons/campingrifle_fire2.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_MOSIN);
		self.current_ammo = ammo_nails;
		
		if(self.mosin_notnew)
		{
			//Do nothing
		} else {
			self.mosin_release = 1;
			self.weaponname = "mosin";
		}
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '54 -0.35 -2.95';
		self.weaponaltaim = '54 -0.20 -2.95';
				
				if (self.mosin_empty)
					self.weaponname = "mosin_empty";
				else
					self.weaponname = "mosin";
	
	
		  
		  if (self.mosin_jammed && self.mosin_unjam)
		  {
		  	if (time >= self.mosin_unjam_time) {
				self.mosin_jammed = 0;
				self.mosin_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_mosin_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_MOSIN]) >= autocvar_g_balance_mosin_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_mosin_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_MOSIN]) >= autocvar_g_balance_mosin_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.mosin_accumulator = time - autocvar_g_balance_mosin_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.mosin_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_mosin_clearjam_time, w_ready);
			if (self.mosin_unjam != 1) {
				self.mosin_unjam = 1;
				self.mosin_unjam_time = time + autocvar_g_balance_mosin_clearjam_time;
				self.mosin_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.mosin_click = 0;
			W_Reload(min(autocvar_g_balance_mosin_primary_ammo, autocvar_g_balance_mosin_secondary_ammo), autocvar_g_balance_mosin_reload_ammo, autocvar_g_balance_mosin_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_mosin(float req)
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
				w_deathtypestring = _("%s died in %s's mosin reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's mosin");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s was was killed by a sniper bullet from %s's Mosin");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s was put down by a bullet from %s's Mosin-Nagant");
				else
					w_deathtypestring = _("%s was killed by a bullet from %s's Mosin rifle");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_mosin (void)
//{
//	weapon_defaultspawnfunc(WEP_MOSIN);
//}
