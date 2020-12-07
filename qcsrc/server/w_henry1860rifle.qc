#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HENRY1860RIFLE, w_henry1860rifle, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "henry1860rifle", "henry1860rifle", _("Henry Rifle"))
#else
#ifdef SVQC

.float henry1860rifle_jammed;
.float henry1860rifle_unjam;
.float henry1860rifle_unjam_time;
.float henry1860rifle_accumulator;
.float henry1860rifle_release;
.float henry1860rifle_release2;
.float henry1860rifle_click;
.float henry1860rifle_open;
.float henry1860rifle_animset;
.float henry1860rifle_ready;
.float henry1860rifle_leveroperated;
.float henry1860rifle_notnew;
.float henry1860rifle_casing;

void W_HENRY1860RIFLE_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	entity flash;
	
	if (self.henry1860rifle_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_henry1860rifle_reload_ammo);

	if(autocvar_g_balance_henry1860rifle_jamrate &&
 	(autocvar_g_balance_henry1860rifle_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.henry1860rifle_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, 2, pSound, CH_WEAPON_A, (pDamage + pHeadshotAddedDamage) * pShots);
	
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
	pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 15);
	}
	
	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}

	for(i = 0; i < pShots; ++i)
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, PROJECTILE_MINIEBALL, 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	PlayerGunRise(self, autocvar_g_balance_henry1860rifle_gunrise, random() * autocvar_g_balance_henry1860rifle_gunrun);
	
	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '18 0 0');
	
	}
}

void W_HENRY1860RIFLE_Attack()
{
	W_HENRY1860RIFLE_FireBullet(autocvar_g_balance_henry1860rifle_primary_spread, autocvar_g_balance_henry1860rifle_primary_damage, autocvar_g_balance_henry1860rifle_primary_headshotaddeddamage, autocvar_g_balance_henry1860rifle_primary_force, autocvar_g_balance_henry1860rifle_primary_speed, autocvar_g_balance_henry1860rifle_primary_lifetime, autocvar_g_balance_henry1860rifle_primary_ammo, WEP_HENRY1860RIFLE, autocvar_g_balance_henry1860rifle_primary_bulletconstant, autocvar_g_balance_henry1860rifle_primary_shots, "weapons/uzi_fire_somebass.wav", autocvar_g_balance_henry1860rifle_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_henry1860rifle (void)
{
	weapon_defaultspawnfunc(WEP_HENRY1860RIFLE);
}

.void(void) henry1860rifle_bullethail_attackfunc;
.float henry1860rifle_bullethail_frame;
.float henry1860rifle_bullethail_animtime;
.float henry1860rifle_bullethail_refire;
void W_HENRY1860RIFLE_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.henry1860rifle_bullethail_frame == WFRAME_FIRE2, self.henry1860rifle_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.henry1860rifle_bullethail_attackfunc();
		weapon_thinkf(self.henry1860rifle_bullethail_frame, self.henry1860rifle_bullethail_animtime, W_HENRY1860RIFLE_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_HENRY1860RIFLE_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.henry1860rifle_bullethail_attackfunc = AttackFunc;
		self.henry1860rifle_bullethail_frame = fr;
		self.henry1860rifle_bullethail_animtime = animtime;
		self.henry1860rifle_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_HENRY1860RIFLE_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_HENRY1860RIFLE_RackBolt (void)
{
	PlayerGunRise(self, autocvar_g_balance_henry1860rifle_cockingrise, random() * autocvar_g_balance_henry1860rifle_cockingrun);

	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_henry1860rifle_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		if (self.henry1860rifle_casing) {
			self.henry1860rifle_casing = 0;
			SpawnCasing (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self);
		}
	}
}

void W_HENRY1860RIFLE_RackBoltLoseAmmo (void)
{
	PlayerGunRise(self, autocvar_g_balance_henry1860rifle_cockingrise, random() * autocvar_g_balance_henry1860rifle_cockingrun);

	//Operate the bolt for no reason while ammo is there, extracts ammo
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_henry1860rifle_primary_ammo, autocvar_g_balance_henry1860rifle_reload_ammo);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_henry1860rifle_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		SpawnLiveCartridge_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self, '0 0 0', autocvar_g_balance_henry1860rifle_primary_ammo);
	}
}

void W_HENRY1860RIFLE_RackBoltForward (void)
{
	PlayerGunRise(self, autocvar_g_balance_henry1860rifle_cockingforwardrise, random() * autocvar_g_balance_henry1860rifle_cockingforwardrun);

	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_henry1860rifle_boltaction_animtime*0.5, w_ready);
}


float W_HENRY1860RIFLE_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_henry1860rifle_reload_ammo && self.clip_load < min(autocvar_g_balance_henry1860rifle_primary_ammo, autocvar_g_balance_henry1860rifle_secondary_ammo)))
	{
		if (!self.henry1860rifle_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.henry1860rifle_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.henry1860rifle_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_henry1860rifle(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_HENRY1860RIFLE_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.henry1860rifle_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.henry1860rifle_open) {
			if (!self.henry1860rifle_release2) {
				self.BUTTON_ATCK2 = TRUE;
			}
		} else if (!self.henry1860rifle_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_henry1860rifle_primary_speed, 0, autocvar_g_balance_henry1860rifle_primary_lifetime, FALSE))
			&& (self.henry1860rifle_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_HENRY1860RIFLE_NeedManualReload())
	{
		self.henry1860rifle_notnew = 1;
		
		if(autocvar_g_balance_henry1860rifle_reload_ammo && self.clip_load < min(autocvar_g_balance_henry1860rifle_primary_ammo, autocvar_g_balance_henry1860rifle_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.henry1860rifle_jammed && self.henry1860rifle_unjam)
		  {
		  	if (time >= self.henry1860rifle_unjam_time) {
				self.henry1860rifle_jammed = 0;
				self.henry1860rifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.henry1860rifle_accumulator = bound(time - autocvar_g_balance_henry1860rifle_bursttime, self.henry1860rifle_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.henry1860rifle_jammed != 1)
			if (!self.BUTTON_ATCK2)
			if (self.henry1860rifle_release)
			if (!self.henry1860rifle_open)
			if (weapon_prepareattack_check(0, autocvar_g_balance_henry1860rifle_primary_refire))
			if (time >= self.henry1860rifle_accumulator + autocvar_g_balance_henry1860rifle_primary_burstcost)
			{
				self.weaponname = "henry1860rifle";
				self.henry1860rifle_casing = 1;
				weapon_prepareattack_do(0, autocvar_g_balance_henry1860rifle_primary_refire);
				W_HENRY1860RIFLE_BulletHail(autocvar_g_balance_henry1860rifle_primary_bullethail, W_HENRY1860RIFLE_Attack, WFRAME_FIRE1, autocvar_g_balance_henry1860rifle_primary_animtime, autocvar_g_balance_henry1860rifle_primary_refire);
				self.henry1860rifle_accumulator += autocvar_g_balance_henry1860rifle_primary_burstcost;
				
				self.henry1860rifle_release = 0;
				self.henry1860rifle_ready = 0;
				self.henry1860rifle_leveroperated = 0;
			}
			if (self.BUTTON_ATCK2 || self.henry1860rifle_leveroperated)
			if (self.henry1860rifle_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.henry1860rifle_release
				&& !self.henry1860rifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_henry1860rifle_boltaction_refire*0.5))) {
					self.henry1860rifle_release2 = 1; //Any time 2nd button is touched
					if (self.henry1860rifle_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltForward);
						self.henry1860rifle_open = 0;
						self.henry1860rifle_release = 1; //We operated the bolt
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_ready = 1;
						self.henry1860rifle_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBolt);
						self.henry1860rifle_open = 1;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.henry1860rifle_release
				&& !self.henry1860rifle_release2
				&& !autocvar_g_balance_henry1860rifle_noneedlessboltuse) 
				&& (weapon_prepareattack(1, autocvar_g_balance_henry1860rifle_boltaction_refire*0.5))) {
					self.henry1860rifle_release2 = 1; //Any time 2nd button is touched
					if (self.henry1860rifle_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltForward);
						self.henry1860rifle_open = 0;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_ready = 1;
						self.henry1860rifle_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltLoseAmmo);
						self.henry1860rifle_open = 1;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					}
					
				} else if (!self.BUTTON_ATCK
				&& !self.henry1860rifle_release
				&& !self.henry1860rifle_release2) {
					//print("here\n");
					self.henry1860rifle_leveroperated = 1; //smoooth
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.henry1860rifle_release2 = 0;
			}
			
			if (self.henry1860rifle_animset) {
				if (self.henry1860rifle_open)
					self.weaponname = "henry1860rifle_open";
				else if (self.henry1860rifle_ready)
					self.weaponname = "henry1860rifle_ready";
				else
					self.weaponname = "henry1860rifle";
			}
			
			self.henry1860rifle_animset = 0;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK && !autocvar_g_balance_henry1860rifle_noneedlessboltuse)
	{
		self.henry1860rifle_notnew = 1;
		
		//Needs reload, can op bolt tho
		
			if (self.BUTTON_ATCK2 || self.henry1860rifle_leveroperated)
			if (self.henry1860rifle_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.henry1860rifle_release
				&& !self.henry1860rifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_henry1860rifle_boltaction_refire*0.5))) {
					self.henry1860rifle_release2 = 1; //Any time 2nd button is touched
					if (self.henry1860rifle_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltForward);
						self.henry1860rifle_open = 0;
						self.henry1860rifle_release = 1; //We operated the bolt
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBolt);
						self.henry1860rifle_open = 1;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.henry1860rifle_release
				&& !self.henry1860rifle_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_henry1860rifle_boltaction_refire*0.5))) {
					self.henry1860rifle_release2 = 1; //Any time 2nd button is touched
					if (self.henry1860rifle_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltForward);
						self.henry1860rifle_open = 0;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_HENRY1860RIFLE_RackBoltForward);
						self.henry1860rifle_open = 1;
						self.henry1860rifle_animset = 1;
						self.henry1860rifle_leveroperated = 0;
					}
					
				} else if (!self.BUTTON_ATCK
				&& !self.henry1860rifle_release
				&& !self.henry1860rifle_release2) {
					self.henry1860rifle_leveroperated = 1;
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.henry1860rifle_release2 = 0;
			}
			
			if (self.henry1860rifle_animset) {
				if (self.henry1860rifle_open)
					self.weaponname = "henry1860rifle_open";
				else if (self.henry1860rifle_ready)
					self.weaponname = "henry1860rifle_ready";
				else
					self.weaponname = "henry1860rifle";
			}
			
			self.henry1860rifle_animset = 0;
			////END NORMAL////
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_henry1860rifle.md3");
		precache_model ("models/weapons/v_henry1860rifle.md3");
		precache_model ("models/weapons/h_henry1860rifle.iqm");
		precache_model ("models/weapons/v_henry1860rifle_open.md3");
		precache_model ("models/weapons/h_henry1860rifle_open.iqm");
		precache_model ("models/weapons/v_henry1860rifle_ready.md3");
		precache_model ("models/weapons/h_henry1860rifle_ready.iqm");
		precache_model ("models/casing_steel.mdl"); //Can expel these if cycle bolt when not fired
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HENRY1860RIFLE);
		self.current_ammo = ammo_nails;

		if(self.henry1860rifle_notnew)
		{
			//Do nothing
		} else {
			self.weaponname = "henry1860rifle_ready";
			self.henry1860rifle_release = 1;
		}
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '54 -0.35 -2.95';
		self.weaponaltaim = '54 -0.20 -2.95';	
			
				if (self.henry1860rifle_open)
					self.weaponname = "henry1860rifle_open";
				else if (self.henry1860rifle_ready)
					self.weaponname = "henry1860rifle_ready";
				else
					self.weaponname = "henry1860rifle";
	
	
		
		  if (self.henry1860rifle_jammed && self.henry1860rifle_unjam)
		  {
		  	if (time >= self.henry1860rifle_unjam_time) {
				self.henry1860rifle_jammed = 0;
				self.henry1860rifle_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_henry1860rifle_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_HENRY1860RIFLE]) >= autocvar_g_balance_henry1860rifle_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_henry1860rifle_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_HENRY1860RIFLE]) >= autocvar_g_balance_henry1860rifle_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.henry1860rifle_accumulator = time - autocvar_g_balance_henry1860rifle_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.henry1860rifle_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_henry1860rifle_clearjam_time, w_ready);
			if (self.henry1860rifle_unjam != 1) {
				self.henry1860rifle_unjam = 1;
				self.henry1860rifle_unjam_time = time + autocvar_g_balance_henry1860rifle_clearjam_time;
				self.henry1860rifle_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.henry1860rifle_click = 0;
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_henry1860rifle_reload_ammo)) {
				//Tube Magazine not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_henry1860rifle_primary_ammo, autocvar_g_balance_henry1860rifle_reload_ammo, autocvar_g_balance_henry1860rifle_reload_time - (autocvar_g_balance_henry1860rifle_reload_time * (self.clip_load/autocvar_g_balance_henry1860rifle_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_henry1860rifle_primary_ammo, autocvar_g_balance_henry1860rifle_reload_ammo, autocvar_g_balance_henry1860rifle_reload_time, "weapons/reload.wav");
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_henry1860rifle(float req)
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
				w_deathtypestring = _("%s died in %s's henry1860rifle reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's henry1860rifle");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s head got destroyed thanks to %s's skill with the shooting iron");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s got shot dead center in the chest by %s's henry repeating rifle");
				else
					w_deathtypestring = _("%s was killed by way of %s's shooting iron");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_henry1860rifle (void)
//{
//	weapon_defaultspawnfunc(WEP_HENRY1860RIFLE);
//}
