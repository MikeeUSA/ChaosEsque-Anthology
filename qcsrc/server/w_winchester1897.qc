#ifdef REGISTER_WEAPON
REGISTER_WEAPON(WINCHESTER1897, w_winchester1897, IT_SHELLS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "winchester1897", "winchester1897", _("Winchester 1897"))
#else
#ifdef SVQC

.float winchester1897_jammed;
.float winchester1897_unjam;
.float winchester1897_unjam_time;
.float winchester1897_accumulator;
.float winchester1897_release;
.float winchester1897_release2;
.float winchester1897_click;
.float winchester1897_open;
.float winchester1897_animset;
.float winchester1897_ready;
.float winchester1897_leveroperated;
.float winchester1897_notnew;
.float winchester1897_casing;
.float winchester1897_slidemaxtime;
.float winchester1897_canejectliveshell;

//PAST:
//NOTE: When pressing secondary 3 times-in-a-row quickly, the previous code would have it that often
//the mechanism gets jammed. To fix it one would press the secondary and
//then hold it and press the primary. This replicated the finicky nature of the earliest pump guns
//NOTE for future coding based off of this CODE:
//For other weapons based off of this code, there has been applied a fix for said jamming issue
//as said mechanism was later improved
//PRESENT: Mechanism has been fixed

void W_WINCHESTER1897_FireBullet(float pSpread, float pDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	entity flash;
	
	if (self.winchester1897_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_shells, pAmmo, autocvar_g_balance_winchester1897_reload_ammo);

	if(autocvar_g_balance_winchester1897_jamrate &&
 	(autocvar_g_balance_winchester1897_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.winchester1897_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, 2, pSound, CH_WEAPON_A, pDamage * pShots);
	
	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
	pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 20);
	}
	
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming

	for(i = 0; i < pShots; ++i)
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, 0, pForce, deathtype, PROJECTILE_BULLETSHOTGUN, 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	PlayerGunRise(self, autocvar_g_balance_winchester1897_gunrise, random() * autocvar_g_balance_winchester1897_gunrun);
	
	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '16 0 0');
	
	}
}

void W_WINCHESTER1897_Attack()
{
	W_WINCHESTER1897_FireBullet(autocvar_g_balance_winchester1897_primary_spread, autocvar_g_balance_winchester1897_primary_damage, autocvar_g_balance_winchester1897_primary_force, autocvar_g_balance_winchester1897_primary_speed, autocvar_g_balance_winchester1897_primary_lifetime, autocvar_g_balance_winchester1897_primary_ammo, WEP_WINCHESTER1897, autocvar_g_balance_projectile_shotgunshot_bulletconstant, autocvar_g_balance_winchester1897_primary_shots, "weapons/shotgun_fire.wav", autocvar_g_balance_winchester1897_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_winchester1897 (void)
{
	weapon_defaultspawnfunc(WEP_WINCHESTER1897);
}

.void(void) winchester1897_bullethail_attackfunc;
.float winchester1897_bullethail_frame;
.float winchester1897_bullethail_animtime;
.float winchester1897_bullethail_refire;
void W_WINCHESTER1897_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_shells), "\n");
	r = weapon_prepareattack(self.winchester1897_bullethail_frame == WFRAME_FIRE2, self.winchester1897_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.winchester1897_bullethail_attackfunc();
		weapon_thinkf(self.winchester1897_bullethail_frame, self.winchester1897_bullethail_animtime, W_WINCHESTER1897_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_WINCHESTER1897_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.winchester1897_bullethail_attackfunc = AttackFunc;
		self.winchester1897_bullethail_frame = fr;
		self.winchester1897_bullethail_animtime = animtime;
		self.winchester1897_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_WINCHESTER1897_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_WINCHESTER1897_RackBolt (void)
{
	PlayerGunRise(self, autocvar_g_balance_winchester1897_cockingrise, random() * autocvar_g_balance_winchester1897_cockingrun);

	sound (self, CH_WEAPON_A, "weapons/pumpshotgun_rack.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_winchester1897_boltaction_animtime*0.5, w_ready);
	if (autocvar_g_casings >= 2) {
		if (self.winchester1897_casing) {
			self.winchester1897_casing = 0;
			SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self);
		}
	}
}

void W_WINCHESTER1897_RackBoltLoseAmmo (void)
{
	PlayerGunRise(self, autocvar_g_balance_winchester1897_cockingrise, random() * autocvar_g_balance_winchester1897_cockingrun);

	//Operate the bolt for no reason while ammo is there, extracts ammo at //Rack for no reason: 
	//and plays the sound
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_winchester1897_boltaction_animtime*0.5, w_ready);
}

void W_WINCHESTER1897_RackBoltForward (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_winchester1897_boltaction_animtime*0.5, w_ready);
}


float W_WINCHESTER1897_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_winchester1897_reload_ammo && self.clip_load < min(autocvar_g_balance_winchester1897_primary_ammo, autocvar_g_balance_winchester1897_secondary_ammo)))
	{
		if (!self.winchester1897_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.winchester1897_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.winchester1897_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_winchester1897(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_WINCHESTER1897_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.winchester1897_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.winchester1897_open) {
			if (!self.winchester1897_release2) {
				self.BUTTON_ATCK2 = TRUE;
			}
		} else if (!self.winchester1897_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_winchester1897_primary_speed, 0, autocvar_g_balance_winchester1897_primary_lifetime, FALSE))
			&& (self.winchester1897_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_WINCHESTER1897_NeedManualReload())
	{
		local float myoperatedslidenow;
		myoperatedslidenow = 0;
		self.winchester1897_notnew = 1;
		
		if(autocvar_g_balance_winchester1897_reload_ammo && self.clip_load < min(autocvar_g_balance_winchester1897_primary_ammo, autocvar_g_balance_winchester1897_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.winchester1897_jammed && self.winchester1897_unjam)
		  {
		  	if (time >= self.winchester1897_unjam_time) {
				self.winchester1897_jammed = 0;
				self.winchester1897_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	//print (ftos(self.winchester1897_canejectliveshell), "_Can eject casing?\n");
			
			
			////NORMAL
			self.winchester1897_accumulator = bound(time - autocvar_g_balance_winchester1897_bursttime, self.winchester1897_accumulator, time);
			if (self.BUTTON_ATCK) {
			if (self.winchester1897_jammed != 1) {
			if (!self.BUTTON_ATCK2) {
			if (self.winchester1897_release) {
			if (!self.winchester1897_open) {
			if (weapon_prepareattack_check(0, autocvar_g_balance_winchester1897_primary_refire)) {
			if (time >= self.winchester1897_accumulator + autocvar_g_balance_winchester1897_primary_burstcost)
			{
				self.weaponname = "winchester1897";
				self.winchester1897_casing = 1;
				weapon_prepareattack_do(0, autocvar_g_balance_winchester1897_primary_refire);
				W_WINCHESTER1897_BulletHail(autocvar_g_balance_winchester1897_primary_bullethail, W_WINCHESTER1897_Attack, WFRAME_FIRE1, autocvar_g_balance_winchester1897_primary_animtime, autocvar_g_balance_winchester1897_primary_refire);
				self.winchester1897_accumulator += autocvar_g_balance_winchester1897_primary_burstcost;
				
				self.winchester1897_release = 0;
				self.winchester1897_ready = 0;
				self.winchester1897_leveroperated = 0;
				
				//print("C1\n");
			}
			}
			}
			}
			}
			}
			}
	
			
			if (self.BUTTON_ATCK2 || self.winchester1897_leveroperated) {
			if (self.winchester1897_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.winchester1897_release
				&& !self.winchester1897_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_winchester1897_boltaction_refire*0.5))) {
					self.winchester1897_release2 = 1; //Any time 2nd button is touched
					if (self.winchester1897_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltForward);
						self.winchester1897_open = 0;
						self.winchester1897_release = 1; //We operated the bolt
						self.winchester1897_animset = 1;
						self.winchester1897_ready = 1;
						self.winchester1897_leveroperated = 0;
						
						//print("D1\n");
						self.winchester1897_canejectliveshell = 0;
						
						myoperatedslidenow = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBolt);
						self.winchester1897_open = 1;
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						self.winchester1897_slidemaxtime = time+(autocvar_g_balance_winchester1897_boltaction_refire*0.5);
	
						//print("D2\n");
						self.winchester1897_canejectliveshell = 0;
						
						myoperatedslidenow = 1;
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.winchester1897_release
				&& !self.winchester1897_release2
				&& !autocvar_g_balance_winchester1897_noneedlessboltuse) 
				&& (weapon_prepareattack(1, autocvar_g_balance_winchester1897_boltaction_refire*0.5))) {
					self.winchester1897_release2 = 1; //Any time 2nd button is touched
					if (self.winchester1897_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltForward);
						self.winchester1897_open = 0;
						self.winchester1897_animset = 1;
						self.winchester1897_ready = 1;
						self.winchester1897_leveroperated = 0;
						
						//print("E1\n");
						self.winchester1897_canejectliveshell = 0;
						
						myoperatedslidenow = 1;
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltLoseAmmo);
						
						if (self.winchester1897_canejectliveshell) {
							//Operate the bolt for no reason while ammo is there, extracts ammo
							sound (self, CH_WEAPON_A, "weapons/pumpshotgun_rack.wav", VOL_BASE, ATTN_NORM);

							W_DecreaseAmmo(ammo_shells, autocvar_g_balance_winchester1897_primary_ammo, autocvar_g_balance_winchester1897_reload_ammo);
	
							if (autocvar_g_casings >= 2) {
								SpawnLiveCartridge_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 30) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 1, self, '0 0 0', autocvar_g_balance_winchester1897_primary_ammo);
							}
						}
						
						self.winchester1897_open = 1;
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						self.winchester1897_slidemaxtime = time+(autocvar_g_balance_winchester1897_boltaction_refire*0.5);
						//print("E2\n");
						self.winchester1897_canejectliveshell = 0;
						
						myoperatedslidenow = 1;
					}
					
				} else {
					//print("here\n");
					self.winchester1897_leveroperated = 1; //smoooth
					
					myoperatedslidenow = 1;
				}
			}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.winchester1897_release2 = 0;
				
				//The added fix for later weapon
				if (!self.BUTTON_ATCK) {
				if (self.winchester1897_open) {
				if (self.winchester1897_release) {
				if (time > self.winchester1897_slidemaxtime) {
				self.winchester1897_open = 0; 
				self.winchester1897_animset = 1;
				}
				}
				}
				}
				
				if (!myoperatedslidenow) {
					self.winchester1897_canejectliveshell = 1;
				}
			}
			
			if (self.winchester1897_animset) {
				if (self.winchester1897_open)
					self.weaponname = "winchester1897_open";
				else if (self.winchester1897_ready)
					self.weaponname = "winchester1897_ready";
				else
					self.weaponname = "winchester1897";
			}
			
			self.winchester1897_animset = 0;
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_THINK && !autocvar_g_balance_winchester1897_noneedlessboltuse)
	{
		self.winchester1897_notnew = 1;
		
		//Needs reload, can op bolt tho
		
			if (self.BUTTON_ATCK2 || self.winchester1897_leveroperated) {
			if (self.winchester1897_jammed != 1)
			{
				if ((!self.BUTTON_ATCK 
				&& !self.winchester1897_release
				&& !self.winchester1897_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_winchester1897_boltaction_refire*0.5))) {
					self.winchester1897_release2 = 1; //Any time 2nd button is touched
					if (self.winchester1897_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltForward);
						self.winchester1897_open = 0;
						self.winchester1897_release = 1; //We operated the bolt
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						//print("A1\n");
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBolt);
						self.winchester1897_open = 1;
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						self.winchester1897_slidemaxtime = time+(autocvar_g_balance_winchester1897_boltaction_refire*0.5);
						
						//print("A2\n");
					}
					
				}
				
				//Rack for no reason:
				else if ((!self.BUTTON_ATCK 
				&& self.winchester1897_release
				&& !self.winchester1897_release2) 
				&& (weapon_prepareattack(1, autocvar_g_balance_winchester1897_boltaction_refire*0.5))) {
					self.winchester1897_release2 = 1; //Any time 2nd button is touched
					if (self.winchester1897_open == 1) {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltForward);
						self.winchester1897_open = 0;
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						//print("B1\n");
					} else {
						weapon_thinkf(WFRAME_FIRE1, 0, W_WINCHESTER1897_RackBoltForward);
						self.winchester1897_open = 1;
						self.winchester1897_animset = 1;
						self.winchester1897_leveroperated = 0;
						
						self.winchester1897_slidemaxtime = time+(autocvar_g_balance_winchester1897_boltaction_refire*0.5);
						
						//print("B2\n");
					}
					
				} else {
					self.winchester1897_leveroperated = 1;
				}
			}
			}
			
			if (!self.BUTTON_ATCK2) {
				self.winchester1897_release2 = 0;
				
				//The added fix for later weapon
				if (self.winchester1897_open) {
				if (time > self.winchester1897_slidemaxtime) {
				self.winchester1897_open = 0; 
				self.winchester1897_animset = 1;
				}
				}
			}
			
			if (self.winchester1897_animset) {
				if (self.winchester1897_open)
					self.weaponname = "winchester1897_open";
				else if (self.winchester1897_ready)
					self.weaponname = "winchester1897_ready";
				else
					self.weaponname = "winchester1897";
			}
			
			self.winchester1897_animset = 0;
			////END NORMAL////
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_winchester1897.md3");
		precache_model ("models/weapons/v_winchester1897.md3");
		precache_model ("models/weapons/h_winchester1897.iqm");
		precache_model ("models/weapons/v_winchester1897_open.md3");
		precache_model ("models/weapons/h_winchester1897_open.iqm");
		precache_model ("models/weapons/v_winchester1897_ready.md3");
		precache_model ("models/weapons/h_winchester1897_ready.iqm");
		precache_model ("models/casing_shell.mdl"); //Can expel these if cycle bolt when not fired
		precache_sound ("weapons/shotgun_fire.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		precache_sound ("weapons/pumpshotgun_rack.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_WINCHESTER1897);
		self.current_ammo = ammo_shells;

		if(self.winchester1897_notnew)
		{
			//Do nothing
		} else {
			self.weaponname = "winchester1897_ready";
			self.winchester1897_release = 1;
		}
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '54 -0.35 -2.95';
		//self.weaponaltaim = '54 -0.20 -2.95';	
		self.weaponaltaim = '60 -0.20 -2.95';
			
				if (self.winchester1897_open)
					self.weaponname = "winchester1897_open";
				else if (self.winchester1897_ready)
					self.weaponname = "winchester1897_ready";
				else
					self.weaponname = "winchester1897";
	
	
		
		  if (self.winchester1897_jammed && self.winchester1897_unjam)
		  {
		  	if (time >= self.winchester1897_unjam_time) {
				self.winchester1897_jammed = 0;
				self.winchester1897_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_winchester1897_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_WINCHESTER1897]) >= autocvar_g_balance_winchester1897_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_winchester1897_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_WINCHESTER1897]) >= autocvar_g_balance_winchester1897_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.winchester1897_accumulator = time - autocvar_g_balance_winchester1897_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.winchester1897_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_winchester1897_clearjam_time, w_ready);
			if (self.winchester1897_unjam != 1) {
				self.winchester1897_unjam = 1;
				self.winchester1897_unjam_time = time + autocvar_g_balance_winchester1897_clearjam_time;
				self.winchester1897_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.winchester1897_click = 0;
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_winchester1897_reload_ammo)) {
				//Tube Magazine not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_winchester1897_primary_ammo, autocvar_g_balance_winchester1897_reload_ammo, autocvar_g_balance_winchester1897_reload_time - (autocvar_g_balance_winchester1897_reload_time * (self.clip_load/autocvar_g_balance_winchester1897_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_winchester1897_primary_ammo, autocvar_g_balance_winchester1897_reload_ammo, autocvar_g_balance_winchester1897_reload_time, "weapons/reload.wav");
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_winchester1897(float req)
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
				w_deathtypestring = _("%s died in %s's winchester1897 reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's winchester1897");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s head got destroyed thanks to %s's skill with the winchester 1897 shotgun");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s got shot in the chest by %s's winchester 1897 shotgun");
				else
					w_deathtypestring = _("%s was killed by way of %s's winchester 1897 shotgun");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_winchester1897 (void)
//{
//	weapon_defaultspawnfunc(WEP_WINCHESTER1897);
//}
