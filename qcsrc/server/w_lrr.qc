#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LRR, w_lrr, IT_NAILS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_MID, "campingrifle", "lrr", _("Long Range Rifle"))
#else
#ifdef SVQC

.float lrr_jammed;
.float lrr_unjam;
.float lrr_unjam_time;
.float lrr_accumulator;
.float lrr_release;
.float lrr_click;

void W_LRR_FireBullet(float pSpread, float pDamage, float pHeadshotAddedDamage, float pForce, float pSpeed, float pLifetime, float pAmmo, float deathtype, float pBulletConstant, float pTracer, float pShots, string pSound, float pCoreshotAddedDamage)
{
	float i;
	
	if (self.lrr_jammed)
	{
		w_ready();
		return;
	}

	W_DecreaseAmmo(ammo_nails, pAmmo, autocvar_g_balance_lrr_reload_ammo);

	if(autocvar_g_balance_lrr_jamrate &&
 	(autocvar_g_balance_lrr_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your rifle has jammed\n");
		}
		self.lrr_jammed = 1;
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
		fireBallisticBullet(w_shotorg, w_shotdir, pSpread, pSpeed, pLifetime, pDamage, pHeadshotAddedDamage / pDamage, pForce, deathtype, (pTracer ? PROJECTILE_BULLETRIFLE9MM_G_T : PROJECTILE_BULLETRIFLE9MM_G), 1, pBulletConstant, pCoreshotAddedDamage);
	endFireBallisticBullet();

	PlayerGunRise(self, autocvar_g_balance_lrr_gunrise, random() * autocvar_g_balance_lrr_gunrun);
	
	}
	
	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 99, self);
	}
}

void W_LRR_Attack()
{
	W_LRR_FireBullet(autocvar_g_balance_lrr_primary_spread, autocvar_g_balance_lrr_primary_damage, autocvar_g_balance_lrr_primary_headshotaddeddamage, autocvar_g_balance_lrr_primary_force, autocvar_g_balance_lrr_primary_speed, autocvar_g_balance_lrr_primary_lifetime, autocvar_g_balance_lrr_primary_ammo, WEP_LRR, autocvar_g_balance_lrr_primary_bulletconstant, autocvar_g_balance_lrr_primary_tracer, autocvar_g_balance_lrr_primary_shots, "weapons/campingrifle_fire.wav", autocvar_g_balance_lrr_primary_coreshotaddeddamage);
}

void spawnfunc_weapon_lrr (void)
{
	weapon_defaultspawnfunc(WEP_LRR);
}

.void(void) lrr_bullethail_attackfunc;
.float lrr_bullethail_frame;
.float lrr_bullethail_animtime;
.float lrr_bullethail_refire;
void W_LRR_BulletHail_Continue()
{
	float r, sw, af;

	sw = self.switchweapon; // make it not detect weapon changes as reason to abort firing
	af = ATTACK_FINISHED(self);
	self.switchweapon = self.weapon;
	ATTACK_FINISHED(self) = time;
	print(ftos(self.ammo_nails), "\n");
	r = weapon_prepareattack(self.lrr_bullethail_frame == WFRAME_FIRE2, self.lrr_bullethail_refire);
	if(self.switchweapon == self.weapon)
		self.switchweapon = sw;
	if(r)
	{
		self.lrr_bullethail_attackfunc();
		weapon_thinkf(self.lrr_bullethail_frame, self.lrr_bullethail_animtime, W_LRR_BulletHail_Continue);
		print("thinkf set\n");
	}
	else
	{
		ATTACK_FINISHED(self) = af; // reset attack_finished if we didn't fire, so the last shot enforces the refire time
		print("out of ammo... ", ftos(self.weaponentity.state), "\n");
	}
}

void W_LRR_BulletHail(float mode, void(void) AttackFunc, float fr, float animtime, float refire)
{
	// if we get here, we have at least one bullet to fire
	AttackFunc();
	if(mode)
	{
		// continue hail
		self.lrr_bullethail_attackfunc = AttackFunc;
		self.lrr_bullethail_frame = fr;
		self.lrr_bullethail_animtime = animtime;
		self.lrr_bullethail_refire = refire;
		weapon_thinkf(fr, animtime, W_LRR_BulletHail_Continue);
	}
	else
	{
		// just one shot
		weapon_thinkf(fr, animtime, w_ready);
	}
}

float W_LRR_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_lrr_reload_ammo && self.clip_load < min(autocvar_g_balance_lrr_primary_ammo, autocvar_g_balance_lrr_secondary_ammo)))
	{
		if (!self.lrr_click && (self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin, same as HMG, both are .50 cal

			self.lrr_click = 1;
		}
		else if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
		{
			self.lrr_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float w_lrr(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_LRR_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
		
		if (self.lrr_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (!self.lrr_release) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_lrr_primary_speed, 0, autocvar_g_balance_lrr_primary_lifetime, FALSE))
			&& (self.lrr_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
		}
	}
	else if (req == WR_THINK && !W_LRR_NeedManualReload())
	{
		if(autocvar_g_balance_lrr_reload_ammo && self.clip_load < min(autocvar_g_balance_lrr_primary_ammo, autocvar_g_balance_lrr_secondary_ammo)) // forced reload
            weapon_action(self.weapon, WR_RELOAD);
		else
		{
		  if (self.lrr_jammed && self.lrr_unjam)
		  {
		  	if (time >= self.lrr_unjam_time) {
				self.lrr_jammed = 0;
				self.lrr_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			////NORMAL
			self.lrr_accumulator = bound(time - autocvar_g_balance_lrr_bursttime, self.lrr_accumulator, time);
			if (self.BUTTON_ATCK)
			if (self.lrr_jammed != 1)
			if (!self.BUTTON_ATCK2)
			if (self.lrr_release)
			if (weapon_prepareattack_check(0, autocvar_g_balance_lrr_primary_refire))
			if (time >= self.lrr_accumulator + autocvar_g_balance_lrr_primary_burstcost)
			{
				weapon_prepareattack_do(0, autocvar_g_balance_lrr_primary_refire);
				W_LRR_BulletHail(autocvar_g_balance_lrr_primary_bullethail, W_LRR_Attack, WFRAME_FIRE1, autocvar_g_balance_lrr_primary_animtime, autocvar_g_balance_lrr_primary_refire);
				self.lrr_accumulator += autocvar_g_balance_lrr_primary_burstcost;
				
				self.lrr_release = 0;
			}
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				self.lrr_release = 1; //SemiAuto
			////END NORMAL////
		  }
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_campingrifle.md3");
		precache_model ("models/weapons/v_campingrifle.md3");
		precache_model ("models/weapons/h_campingrifle.iqm");
		precache_sound ("weapons/campingrifle_fire.wav");
		precache_sound ("weapons/campingrifle_fire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '45 -0.2 -5';
		//self.weaponaltaim = '48 -0.1 -5';
		//self.weaponaltaim = '48 -0.4 -5';
		//self.weaponaltaim = '48 0.1 -5';
		self.weaponaltaim = '48 0 -5.25';
		weapon_setup(WEP_LRR);
		self.current_ammo = ammo_nails;
		self.lrr_release = 1;
		self.weaponname = "campingrifle";
	
		
		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  if (self.lrr_jammed && self.lrr_unjam)
		  {
		  	if (time >= self.lrr_unjam_time) {
				self.lrr_jammed = 0;
				self.lrr_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_lrr_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LRR]) >= autocvar_g_balance_lrr_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_lrr_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_LRR]) >= autocvar_g_balance_lrr_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.lrr_accumulator = time - autocvar_g_balance_lrr_bursttime;
	}
	else if (req == WR_RELOAD)
	{
		if (self.lrr_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_lrr_clearjam_time, w_ready);
			if (self.lrr_unjam != 1) {
				self.lrr_unjam = 1;
				self.lrr_unjam_time = time + autocvar_g_balance_lrr_clearjam_time;
				self.lrr_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the rifle\n");
				}
			}
		} else {
			self.lrr_click = 0;
			W_Reload(min(autocvar_g_balance_lrr_primary_ammo, autocvar_g_balance_lrr_secondary_ammo), autocvar_g_balance_lrr_reload_ammo, autocvar_g_balance_lrr_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_lrr(float req)
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
				w_deathtypestring = _("%s died in %s's lrr reloading operation");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// TODO special headshot message here too?
				w_deathtypestring = _("%s failed to hide from %s's lrr");
			}
			else
			{
				if(w_deathtype & HITTYPE_HEADSHOT)
					w_deathtypestring = _("%s head got popped thanks to %s's skill with a lrr");
				else if(w_deathtype & HITTYPE_CORESHOT)
					w_deathtypestring = _("%s got shot in the chest by way of %s's lrr");
				else
					w_deathtypestring = _("%s was shot dead by %s's lrr");
			}
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_lrr (void)
//{
//	weapon_defaultspawnfunc(WEP_LRR);
//}
