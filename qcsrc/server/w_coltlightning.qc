#ifdef REGISTER_WEAPON
REGISTER_WEAPON(COLTLIGHTNING, w_coltlightning, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "coltlightning", "coltlightning", _("Colt Lightning"))
#else
#ifdef SVQC

.float coltlightning_jammed;
.float coltlightning_unjam;
.float coltlightning_unjam_time;
.float coltlightning_accumulator;
.float coltlightning_release;
.float coltlightning_release2;
.float coltlightning_click;
.float coltlightning_open;
.float coltlightning_animset;
.float coltlightning_ready;
.float coltlightning_leveroperated;
.float coltlightning_notnew;
.float coltlightning_casing;

//NOTE: When pressing secondary 3 times-in-a-row quickly, often
//the mechanism gets jammed. To fix it press the secondary and
//then hold it and press the primary.
//The original Colt Lightning's mechanism jammed sometimes
//This replecates the imprefect loading mechanism
//NOTE for future coding based off of this CODE:
//For other weapons based off of this code, fix said jamming issue
//as said mechanism was later improved

void W_COLTLIGHTNING_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	entity flash;
	
	if (self.coltlightning_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_coltlightning_reload_ammo);

	if(autocvar_g_balance_coltlightning_jamrate &&
 	(autocvar_g_balance_coltlightning_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.coltlightning_jammed = 1;
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

	PlayerGunRise(self, autocvar_g_balance_coltlightning_gunrise, random() * autocvar_g_balance_coltlightning_gunrun);
	
	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '14 0 0');
	
	}
}

void W_COLTLIGHTNING_Attack()
{
	W_COLTLIGHTNING_FireBullet(autocvar_g_balance_coltlightning_primary_spread, autocvar_g_balance_coltlightning_primary_damage, autocvar_g_balance_coltlightning_primary_headshotaddeddamage, autocvar_g_balance_coltlightning_primary_force, autocvar_g_balance_coltlightning_primary_speed, autocvar_g_balance_coltlightning_primary_lifetime, autocvar_g_balance_coltlightning_primary_ammo, WEP_COLTLIGHTNING, autocvar_g_balance_coltlightning_primary_bulletconstant, autocvar_g_balance_coltlightning_primary_shots, "weapons/uzi_fire_somebass.wav", autocvar_g_balance_coltlightning_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_coltlightning (void)
{
	weapon_defaultspawnfunc(WEP_COLTLIGHTNING);
}

.void(void) coltlightning_bullethail_attackfunc;
.float coltlightning_bullethail_frame;
.float coltlightning_bullethail_animtime;
.float coltlightning_bullethail_refire;
void W_COLTLIGHTNING_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.coltlightning_bullethail_frame == WFRAME_FIRE2, self.coltlightning_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.coltlightning_bullethail_attackfunc();
		weapon_thinkf(self.coltlightning_bullethail_frame, self.coltlightning_bullethail_animtime, W_COLTLIGHTNING_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_COLTLIGHTNING_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.coltlightning_bullethail_attackfunc = AttackFunc;
		self.coltlightning_bullethail_frame = fr;
		self.coltlightning_bullethail_animtime = animtime;
		self.coltlightning_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_COLTLIGHTNING_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_COLTLIGHTNING_RackBolt (void)
{
	PlayerGunRise(self, autocvar_g_balance_coltlightning_cockingrise, random() * autocvar_g_balance_coltlightning_cockingrun);

	sound (self, CH_WEAPON_A, "weapons/pumpshotgun_rack.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_coltlightning_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		if (self.coltlightning_casing) {
			self.coltlightning_casing = 0;
			SpawnCasing (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self);
		}
	}
}

void W_COLTLIGHTNING_RackBoltLoseAmmo (void)
{
	PlayerGunRise(self, autocvar_g_balance_coltlightning_cockingrise, random() * autocvar_g_balance_coltlightning_cockingrun);

	//Operate the bolt for no reason while ammo is there, extracts ammo
	sound (self, CH_WEAPON_A, "weapons/pumpshotgun_rack.wav", VOL_BASE, ATTN_NORM);
	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_coltlightning_primary_ammo, autocvar_g_balance_coltlightning_reload_ammo);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_coltlightning_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		SpawnLiveCartridge_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 32, self, '0 0 0', autocvar_g_balance_coltlightning_primary_ammo);
	}
}

void W_COLTLIGHTNING_RackBoltForward (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_coltlightning_boltaction_animtime*0.5, w_ready);
}


float W_COLTLIGHTNING_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_coltlightning_reload_ammo && self.clip_load < min(autocvar_g_balance_coltlightning_primary_ammo, autocvar_g_balance_coltlightning_secondary_ammo)))
	{
		if (!self.coltlightning_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.coltlightning_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.coltlightning_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_coltlightning(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_COLTLIGHTNING_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.coltlightning_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.coltlightning_open) {
			if (!self.coltlightning_release2) {
				self.BUTTON_ATCK2 = TRUE;
			}
		} else if (!self.coltlightning_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_coltlightning_primary_speed, 0, autocvar_g_balance_coltlightning_primary_lifetime, FALSE))
			&& (self.coltlightning_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_COLTLIGHTNING_NeedManualReload())
	{
		self.coltlightning_notnew = 1;
		
		if(autocvar_g_balance_coltlightning_reload_ammo && self.clip_load < min(autocvar_g_balance_coltlightning_primary_ammo, autocvar_g_balance_coltlightning_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.coltlightning_jammed && self.coltlightning_unjam)
		  {
		  	if (time >= self.coltlightning_unjam_time) {
				self.coltlightning_jammed = 0;
				self.coltlightning_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.coltlightning_accumulator = bound(time - autocvar_g_balance_coltlightning_bursttime, self.coltlightning_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.coltlightning_jammed != 1)
			if (!self.BUTTON_ATCK2)
			if (self.coltlightning_release)
			if (!self.coltlightning_open)
			if (weapon_prepareattack_check(0, autocvar_g_balance_coltlightning_primary_refire))
			if (time >= self.coltlightning_accumulator + autocvar_g_balance_coltlightning_primary_burstcost)
			{
				self.weaponname = "coltlightning";
				self.coltlightning_casing = 1;
				weapon_prepareattack_do(0, autocvar_g_balance_coltlightning_primary_refire);
				W_COLTLIGHTNING_BulletHail(autocvar_g_balance_coltlightning_primary_bullethail, W_COLTLIGHTNING_Attack, WFRAME_FIRE1, autocvar_g_balance_coltlightning_primary_animtime, autocvar_g_balance_coltlightning_primary_refire);
				self.coltlightning_accumulator += autocvar_g_balance_coltlightning_primary_burstcost;
				
				self.coltlightning_release = 0;
				self.coltlightning_ready = 0;
				self.coltlightning_leveroperated = 0;
			}
			if (self.BUTTON_ATCK2 || self.coltlightning_leveroperated)
			if (self.coltlightning_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.coltlightning_release
				&& !self.coltlightning_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_coltlightning_boltaction_refire*0.5))) {
					self.coltlightning_release2 = 1; //Any time 2nd button is touched
					if (self.coltlightning_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltForward);
						self.coltlightning_open = 0;
						self.coltlightning_release = 1; //We operated the bolt
						self.coltlightning_animset = 1;
						self.coltlightning_ready = 1;
						self.coltlightning_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBolt);
						self.coltlightning_open = 1;
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.coltlightning_release
				&& !self.coltlightning_release2
				&& !autocvar_g_balance_coltlightning_noneedlessboltuse) 
				&& (weapon_prepareattack(1, autocvar_g_balance_coltlightning_boltaction_refire*0.5))) {
					self.coltlightning_release2 = 1; //Any time 2nd button is touched
					if (self.coltlightning_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltForward);
						self.coltlightning_open = 0;
						self.coltlightning_animset = 1;
						self.coltlightning_ready = 1;
						self.coltlightning_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltLoseAmmo);
						self.coltlightning_open = 1;
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					}
					
				} else {
					//print("here\n");
					self.coltlightning_leveroperated = 1; //smoooth
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.coltlightning_release2 = 0;
			}
			
			if (self.coltlightning_animset) {
				if (self.coltlightning_open)
					self.weaponname = "coltlightning_open";
				else if (self.coltlightning_ready)
					self.weaponname = "coltlightning_ready";
				else
					self.weaponname = "coltlightning";
			}
			
			self.coltlightning_animset = 0;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK && !autocvar_g_balance_coltlightning_noneedlessboltuse)
	{
		self.coltlightning_notnew = 1;
		
		//Needs reload, can op bolt tho
		
			if (self.BUTTON_ATCK2 || self.coltlightning_leveroperated)
			if (self.coltlightning_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.coltlightning_release
				&& !self.coltlightning_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_coltlightning_boltaction_refire*0.5))) {
					self.coltlightning_release2 = 1; //Any time 2nd button is touched
					if (self.coltlightning_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltForward);
						self.coltlightning_open = 0;
						self.coltlightning_release = 1; //We operated the bolt
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBolt);
						self.coltlightning_open = 1;
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.coltlightning_release
				&& !self.coltlightning_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_coltlightning_boltaction_refire*0.5))) {
					self.coltlightning_release2 = 1; //Any time 2nd button is touched
					if (self.coltlightning_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltForward);
						self.coltlightning_open = 0;
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_COLTLIGHTNING_RackBoltForward);
						self.coltlightning_open = 1;
						self.coltlightning_animset = 1;
						self.coltlightning_leveroperated = 0;
					}
					
				} else {
					self.coltlightning_leveroperated = 1;
				}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.coltlightning_release2 = 0;
			}
			
			if (self.coltlightning_animset) {
				if (self.coltlightning_open)
					self.weaponname = "coltlightning_open";
				else if (self.coltlightning_ready)
					self.weaponname = "coltlightning_ready";
				else
					self.weaponname = "coltlightning";
			}
			
			self.coltlightning_animset = 0;
			////END NORMAL////
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_coltlightning.md3");
		precache_model ("models/weapons/v_coltlightning.md3");
		precache_model ("models/weapons/h_coltlightning.iqm");
		precache_model ("models/weapons/v_coltlightning_open.md3");
		precache_model ("models/weapons/h_coltlightning_open.iqm");
		precache_model ("models/weapons/v_coltlightning_ready.md3");
		precache_model ("models/weapons/h_coltlightning_ready.iqm");
		precache_model ("models/casing_steel.mdl"); //Can expel these if cycle bolt when not fired
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		precache_sound ("weapons/pumpshotgun_rack.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_COLTLIGHTNING);
		self.current_ammo = ammo_nails;

		if(self.coltlightning_notnew)
		{
			//Do nothing
		} else {
			self.weaponname = "coltlightning_ready";
			self.coltlightning_release = 1;
		}
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '54 -0.35 -2.95';
		self.weaponaltaim = '54 -0.20 -2.95';	
			
				if (self.coltlightning_open)
					self.weaponname = "coltlightning_open";
				else if (self.coltlightning_ready)
					self.weaponname = "coltlightning_ready";
				else
					self.weaponname = "coltlightning";
	
	
		
		  if (self.coltlightning_jammed && self.coltlightning_unjam)
		  {
		  	if (time >= self.coltlightning_unjam_time) {
				self.coltlightning_jammed = 0;
				self.coltlightning_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_coltlightning_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_COLTLIGHTNING]) >= autocvar_g_balance_coltlightning_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_coltlightning_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_COLTLIGHTNING]) >= autocvar_g_balance_coltlightning_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.coltlightning_accumulator = time - autocvar_g_balance_coltlightning_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.coltlightning_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_coltlightning_clearjam_time, w_ready);
			if (self.coltlightning_unjam != 1) {
				self.coltlightning_unjam = 1;
				self.coltlightning_unjam_time = time + autocvar_g_balance_coltlightning_clearjam_time;
				self.coltlightning_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.coltlightning_click = 0;
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_coltlightning_reload_ammo)) {
				//Tube Magazine not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_coltlightning_primary_ammo, autocvar_g_balance_coltlightning_reload_ammo, autocvar_g_balance_coltlightning_reload_time - (autocvar_g_balance_coltlightning_reload_time * (self.clip_load/autocvar_g_balance_coltlightning_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_coltlightning_primary_ammo, autocvar_g_balance_coltlightning_reload_ammo, autocvar_g_balance_coltlightning_reload_time, "weapons/reload.wav");
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_coltlightning(float req)
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
				w_deathtypestring = _("%s died in %s's coltlightning reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's coltlightning");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s head got destroyed thanks to %s's skill with the colt lightning carbine");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s got shot center in the chest by %s's colt lightning carbine");
				else
					w_deathtypestring = _("%s was killed by way of %s's colt lightning carbine");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_coltlightning (void)
//{
//	weapon_defaultspawnfunc(WEP_COLTLIGHTNING);
//}
