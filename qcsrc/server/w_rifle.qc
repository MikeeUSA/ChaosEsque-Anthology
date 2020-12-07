#ifdef REGISTER_WEAPON
REGISTER_WEAPON(RIFLE, w_rifle, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "sniperrifle", "rifle", _("Rifle"))
#else
#ifdef SVQC

.float rifle_accumulator;
.float rifle_release;
.float rifle_click;
.float rifle_suppressed;
.float rifle_gsetsuppressed; //For ground model setting propagation

void W_Rifle_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pTracer, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_rifle_reload_ammo);


	if not(self.rifle_suppressed) {
			W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, 2, pSound, CH_WEAPON_A, (pDamage + pHeadshotAddedDamage) * pShots);
	
		//If suppressed, don't show flash or dynlight
		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 2000, 1);
	} else {
			W_SetupShot (self, autocvar_g_antilag_bullets && pSpeed >= autocvar_g_antilag_bullets, 2, "weapons/uzi_fire_suppressed.wav", CH_WEAPON_A, (pDamage + pHeadshotAddedDamage) * pShots);

			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.33, ATTN_NORM);
	}

	if(self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) // if zoomed, shoot from the eye
	{
		w_shotdir = v_forward;
		w_shotorg = self.origin + self.view_ofs + ((w_shotorg - self.origin - self.view_ofs) * v_forward) * v_forward;
	} else {
		W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	}

	for(i = 0; i < pShots; ++i)
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, (pTracer ? PROJECTILE_BULLETRIFLE45_G_T : PROJECTILE_BULLETRIFLE45_G), 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	if not(self.rifle_suppressed) {
		PlayerGunRise(self, autocvar_g_balance_rifle_gunrise, random() * autocvar_g_balance_rifle_gunrun);
	} else {
		PlayerGunRise(self, autocvar_g_balance_rifle_suppressed_gunrise, random() * autocvar_g_balance_rifle_suppressed_gunrun);
	}
	
	if ((autocvar_g_casings >= 2) && !autocvar_g_balance_rifle_boltaction) {
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 106, self);
	}
}

void W_Rifle_Attack()
{
	W_Rifle_FireBullet(autocvar_g_balance_rifle_primary_spread, autocvar_g_balance_rifle_primary_damage, autocvar_g_balance_rifle_primary_headshotaddeddamage, autocvar_g_balance_rifle_primary_force, autocvar_g_balance_rifle_primary_speed, autocvar_g_balance_rifle_primary_lifetime, autocvar_g_balance_rifle_primary_ammo, WEP_RIFLE, autocvar_g_balance_rifle_primary_bulletconstant, autocvar_g_balance_rifle_primary_tracer, autocvar_g_balance_rifle_primary_shots, "weapons/campingrifle_fire.wav", autocvar_g_balance_rifle_primary_coreshotaddeddamage);
}

void W_Rifle_Attack2()
{
	W_Rifle_FireBullet(autocvar_g_balance_rifle_secondary_spread, autocvar_g_balance_rifle_secondary_damage, autocvar_g_balance_rifle_secondary_headshotaddeddamage, autocvar_g_balance_rifle_secondary_force, autocvar_g_balance_rifle_secondary_speed, autocvar_g_balance_rifle_secondary_lifetime, autocvar_g_balance_rifle_secondary_ammo, WEP_RIFLE | HITTYPE_SECONDARY, autocvar_g_balance_rifle_secondary_bulletconstant, autocvar_g_balance_rifle_secondary_tracer, autocvar_g_balance_rifle_secondary_shots, "weapons/campingrifle_fire2.wav", autocvar_g_balance_rifle_secondary_coreshotaddeddamage);
}

void spawnfunc_weapon_rifle (void)
{
	weapon_defaultspawnfunc(WEP_RIFLE);
}

void w_rifle_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.rifle_suppressed) {
		myself.model = "models/weapons/g_sniperrifle_suppressed.md3";
		
		if (autocvar_g_balance_rifle_suppressornotincluded
		&& player.inv_misc_suppressorrifle >= 1) {
			player.inv_misc_suppressorrifle = player.inv_misc_suppressorrifle - 1;
			myself.inv_misc_suppressorrifle = myself.inv_misc_suppressorrifle + 1;
		}
		
		myself.rifle_gsetsuppressed = player.rifle_suppressed;
	} else {
		//Do nothing
		myself.rifle_gsetsuppressed = 0;
	}
}

void w_rifle_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_RIFLE) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.rifle_suppressed = myself.rifle_gsetsuppressed;
		}
	}
}

// compatibility alias
void spawnfunc_weapon_campingrifle (void)
{
	spawnfunc_weapon_rifle();
}
void spawnfunc_weapon_sniperrifle (void)
{
	spawnfunc_weapon_rifle();
}

.void(void) rifle_bullethail_attackfunc;
.float rifle_bullethail_frame;
.float rifle_bullethail_animtime;
.float rifle_bullethail_refire;
void W_Rifle_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.rifle_bullethail_frame == WFRAME_FIRE2, self.rifle_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.rifle_bullethail_attackfunc();
		weapon_thinkf(self.rifle_bullethail_frame, self.rifle_bullethail_animtime, W_Rifle_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_Rifle_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.rifle_bullethail_attackfunc = AttackFunc;
		self.rifle_bullethail_frame = fr;
		self.rifle_bullethail_animtime = animtime;
		self.rifle_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_Rifle_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

void W_Rifle_RackBolt (void)
{
	sound (self, CH_WEAPON_A, "weapons/campingrifle_boltaction.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_rifle_boltaction_animtime, w_ready);
	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 106, self);
	}
}


float W_Rifle_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_rifle_reload_ammo && self.clip_load < min(autocvar_g_balance_rifle_primary_ammo, autocvar_g_balance_rifle_secondary_ammo)))
	{
		if (!self.rifle_click && (self.BUTTON_ATCK || (autocvar_g_balance_rifle_secondary && self.BUTTON_ATCK2))) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.rifle_click = 1;
		}
		else if not(self.BUTTON_ATCK || (autocvar_g_balance_rifle_secondary && self.BUTTON_ATCK2))
		{
			self.rifle_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


.float bot_secondary_riflemooth;
float w_rifle(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_Rifle_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (autocvar_g_balance_rifle_boltaction && !self.rifle_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if(vlen(self.origin-self.enemy.origin) > 1000)
				self.bot_secondary_riflemooth = 0;
			if(self.bot_secondary_riflemooth == 0)
			{
				if((bot_aim(autocvar_g_balance_rifle_primary_speed, 0, autocvar_g_balance_rifle_primary_lifetime, FALSE))
				&& (self.rifle_release))
				{
					self.BUTTON_ATCK = TRUE;
					if(random() < 0.01) self.bot_secondary_riflemooth = 1;
				}
			}
			else
			{
				if((bot_aim(autocvar_g_balance_rifle_secondary_speed, 0, autocvar_g_balance_rifle_secondary_lifetime, FALSE))
				&& (self.rifle_release))
				{
					self.BUTTON_ATCK2 = TRUE;
					if(random() < 0.03) self.bot_secondary_riflemooth = 0;
				}
			}
		}
	}
	else if (req == WR_THINK && !W_Rifle_NeedManualReload())
	{
		if (self.rifle_suppressed) {
			if (!autocvar_g_balance_rifle_suppressornotincluded
			|| self.inv_misc_suppressorrifle)
			{
				//Nothing
			} else {
				self.rifle_suppressed = 0;
				self.weaponname = "sniperrifle";
			}
		}
	
	
		if(autocvar_g_balance_rifle_reload_ammo && self.clip_load < min(autocvar_g_balance_rifle_primary_ammo, autocvar_g_balance_rifle_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
			self.rifle_accumulator = bound(time - autocvar_g_balance_rifle_bursttime, self.rifle_accumulator, time);
			if (self.BUTTON_ATCK)
			if ((!self.BUTTON_ATCK2
			     && autocvar_g_balance_rifle_boltaction)
			     || (!autocvar_g_balance_rifle_boltaction))
			if (self.rifle_release)
			if (weapon_prepareattack_check(0, autocvar_g_balance_rifle_primary_refire))
			if (time >= self.rifle_accumulator + autocvar_g_balance_rifle_primary_burstcost)
			{
				weapon_prepareattack_do(0, autocvar_g_balance_rifle_primary_refire);
				W_Rifle_BulletHail(autocvar_g_balance_rifle_primary_bullethail, W_Rifle_Attack, WFRAME_FIRE1, autocvar_g_balance_rifle_primary_animtime, autocvar_g_balance_rifle_primary_refire);
				self.rifle_accumulator += autocvar_g_balance_rifle_primary_burstcost;
				if (autocvar_g_balance_rifle_semiauto
				|| autocvar_g_balance_rifle_boltaction) {
					self.rifle_release = 0;
				}
			}
			if (self.BUTTON_ATCK2)
			{
				if (autocvar_g_balance_rifle_secondary)
				{
					if(autocvar_g_balance_rifle_boltaction) {	
						if ((!self.BUTTON_ATCK 
						&& !self.rifle_release) 
						&& (weapon_prepareattack(1, autocvar_g_balance_rifle_boltaction_refire))) {
							weapon_thinkf(WFRAME_FIRE1, 0, W_Rifle_RackBolt);
							self.rifle_release = 1; //We operated the bolt
						}
					} 
					else if(autocvar_g_balance_rifle_secondary_reload) 
					{
                     	   			weapon_action(self.weapon, WR_RELOAD);
                  	  		}
					else if (self.rifle_release)
                   	 		{
                   	     			if (weapon_prepareattack_check(1, autocvar_g_balance_rifle_secondary_refire))
                      	  			if (time >= self.rifle_accumulator + autocvar_g_balance_rifle_secondary_burstcost)
                      	 	 		{
                       	   		  		weapon_prepareattack_do(1, autocvar_g_balance_rifle_secondary_refire);
                       	    		 		W_Rifle_BulletHail(autocvar_g_balance_rifle_secondary_bullethail, W_Rifle_Attack2, WFRAME_FIRE2, autocvar_g_balance_rifle_secondary_animtime, autocvar_g_balance_rifle_primary_refire);
                       	    		 		self.rifle_accumulator += autocvar_g_balance_rifle_secondary_burstcost;
                       	 				if (autocvar_g_balance_rifle_semiauto) {
								self.rifle_release = 0;
							}
						}
                   	 		}
				}
			}
			if not(autocvar_g_balance_rifle_boltaction) {
				if (!autocvar_g_balance_rifle_semiauto) {
					self.rifle_release = 1;
				}
				if(autocvar_g_balance_rifle_secondary) {
					if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
						self.rifle_release = 1;
					}
				} else {
					if not(self.BUTTON_ATCK) {
						self.rifle_release = 1;
					}
				}
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_sniperrifle.md3");
		precache_model ("models/weapons/v_sniperrifle.md3");
		precache_model ("models/weapons/h_sniperrifle.iqm");
		precache_model ("models/weapons/g_sniperrifle_suppressed.md3");
		precache_model ("models/weapons/v_sniperrifle_suppressed.md3");
		precache_model ("models/weapons/h_sniperrifle_suppressed.iqm");
		precache_sound ("weapons/campingrifle_fire.wav");
		precache_sound ("weapons/campingrifle_fire2.wav");
		precache_sound ("weapons/campingrifle_boltaction.wav");
		precache_sound ("weapons/uzi_fire_suppressed.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '48 -0.2 -6.25';
		//self.weaponaltaim = '54 -0.2 -6.25';
		//self.weaponaltaim = '54 -0.1 -6.25';
		//self.weaponaltaim = '54 0.1 -6.25';
		//self.weaponaltaim = '54 -0.15 -6.25';
		//self.weaponaltaim = '54 -0.25 -6.25';
		//self.weaponaltaim = '54 0 -6.45';
		self.weaponaltaim = '54 0 -6.30';
		weapon_setup(WEP_RIFLE);
		self.current_ammo = ammo_nails;
		self.rifle_release = 1;
		
		if (!autocvar_g_balance_rifle_suppressornotincluded
		|| self.inv_misc_suppressorrifle)
		{
			if (self.rifle_suppressed) {
				self.weaponname = "sniperrifle_suppressed";
			} else if (!self.rifle_suppressed) {
				self.weaponname = "sniperrifle";
			}
		} else {
			self.rifle_suppressed = 0;
			self.weaponname = "sniperrifle";
		}
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_rifle_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_RIFLE]) >= autocvar_g_balance_rifle_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_rifle_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_RIFLE]) >= autocvar_g_balance_rifle_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.rifle_accumulator = time - autocvar_g_balance_rifle_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		self.rifle_click = 0;
		W_Reload(min(autocvar_g_balance_rifle_primary_ammo, autocvar_g_balance_rifle_secondary_ammo), autocvar_g_balance_rifle_reload_ammo, autocvar_g_balance_rifle_reload_time, "weapons/reload.wav");
			if (self.BUTTON_USE) {
			  if (!autocvar_g_balance_rifle_suppressornotincluded
			  || self.inv_misc_suppressorrifle)
			  {
				if (self.rifle_suppressed) {
					self.rifle_suppressed = 0;
					self.weaponname = "sniperrifle";
				} else if (!self.rifle_suppressed) {
					self.rifle_suppressed = 1;
					self.weaponname = "sniperrifle_suppressed";
				}
			  }
			}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_rifle(float req)
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
				w_deathtypestring = _("%s failed to hide from %s's rifle bullet hail");
			else
				w_deathtypestring = _("%s died in %s's rifle bullet hail");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's rifle");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s got shot in the head with a rifle by %s");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s got a rifle bullet through the chest thanks to %s");
				else
					w_deathtypestring = _("%s was sniped with a rifle by %s");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_rifle (void)
//{
//	weapon_defaultspawnfunc(WEP_RIFLE);
//}
