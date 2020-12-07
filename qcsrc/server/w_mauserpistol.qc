#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MAUSERPISTOL, w_mauserpistol, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "mauserpistol", "mauserpistol", _("Mauser Pistol"))
#else
#ifdef SVQC

.float mauserpistol_release;
.float mauserpistol_jammed;
.float mauserpistol_unjam;
.float mauserpistol_unjam_time;
.float mauserpistol_click;
.float mauserpistol_animempty;
.float mauserpistol_animset;
.float mauserpistol_nextanim;
.float mauserpistol_nextbot;

void W_MauserPistol_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_mauserpistol_primary_ammo;
	d = autocvar_g_balance_mauserpistol_primary_damage;
	f = autocvar_g_balance_mauserpistol_primary_force;
	spread = autocvar_g_balance_mauserpistol_primary_spread;
	bulletspeed = autocvar_g_balance_mauserpistol_primary_speed;
	bulletconstant = autocvar_g_balance_mauserpistol_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_mauserpistol_reload_ammo);
	
	if (autocvar_g_balance_mauserpistol_jamrate &&
 	(autocvar_g_balance_mauserpistol_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your pistol jammed\n");
		}
		self.mauserpistol_jammed = 1;
	} else { //Start Not Jammed

	
		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_wppq_fire.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_mauserpistol_primary_headshotaddeddamage, f, WEP_MAUSERPISTOL, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_mauserpistol_primary_coreshotaddeddamage);
	endFireBallisticBullet();

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_mauserpistol_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_mauserpistol_gunrise, random() * autocvar_g_balance_mauserpistol_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '7.5 0 0');

	if (autocvar_g_casings >= 2)
		SpawnCasing_Offset (((random () * 1 - 0.5) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -100 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 62, self, '0 2 0');

	
	} //End Not Jammed
}


float W_MauserPistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_mauserpistol_reload_ammo && self.clip_load < autocvar_g_balance_mauserpistol_primary_ammo))
	{
		if (!self.mauserpistol_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.mauserpistol_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.mauserpistol_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_mauserpistol (void)
{
	weapon_defaultspawnfunc(WEP_MAUSERPISTOL);
}


.float mauserpistol_primarytime;

float w_mauserpistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_MauserPistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.mauserpistol_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.mauserpistol_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_mauserpistol_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_MauserPistol_NeedManualReload())
	{

	
	
	
		if(autocvar_g_balance_mauserpistol_reload_ammo && self.clip_load < autocvar_g_balance_mauserpistol_primary_ammo) // forced reload
		{
			// don't force reload an empty mauserpistol if its melee attack is active
			if not(autocvar_g_balance_mauserpistol_secondary && self.ammo_nails < autocvar_g_balance_mauserpistol_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.mauserpistol_release = 0;
		}
		else
		{
		  if (self.mauserpistol_jammed && self.mauserpistol_unjam)
		  {
		  	if (time >= self.mauserpistol_unjam_time) {
				self.mauserpistol_jammed = 0;
				self.mauserpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.mauserpistol_release)
			if (self.mauserpistol_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.mauserpistol_nextbot)," \n");
				} else {
					self.mauserpistol_nextbot = 0;
				}
				
				if (time >= self.mauserpistol_nextbot) {
					W_MauserPistol_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_mauserpistol_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_mauserpistol_primary_animtime, w_ready);
					self.mauserpistol_release = 0;
					self.mauserpistol_animempty = 1;
					self.mauserpistol_animset = 1;
					self.mauserpistol_nextanim = time + autocvar_g_balance_mauserpistol_primary_rfanim;
					bp_skipme = 1;
					//self.mauserpistol_nextbot = time + (autocvar_g_balance_mauserpistol_primary_refire * 50 * random());
					self.mauserpistol_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_mauserpistol_fullauto == 1) {
						self.mauserpistol_release = 1;
						self.mauserpistol_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.mauserpistol_jammed != 1)
				if (time >= self.mauserpistol_nextanim)
				if (self.mauserpistol_animempty)
				{
					self.mauserpistol_animempty = 0;
					self.mauserpistol_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK) {
				self.mauserpistol_release = 1;
			}
				
			if (self.mauserpistol_animset)
			if (self.mauserpistol_jammed != 1) {
				
					if (self.mauserpistol_animempty)
						self.weaponname = "mauserpistol_empty";
					else
						self.weaponname = "mauserpistol";

			}
			
			self.mauserpistol_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_mauserpistol.md3");
		precache_model ("models/weapons/v_mauserpistol.md3");
		precache_model ("models/weapons/h_mauserpistol.iqm");
		
		precache_model ("models/weapons/v_mauserpistol_empty.md3");
		precache_model ("models/weapons/h_mauserpistol_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_wppq_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.25 -1.0';
			
		weapon_setup(WEP_MAUSERPISTOL);
		self.current_ammo = ammo_nails;
		
			if (self.mauserpistol_animempty)
				self.weaponname = "mauserpistol_empty";
			else
				self.weaponname = "mauserpistol";

	
	
	
		  if (self.mauserpistol_jammed && self.mauserpistol_unjam)
		  {
		  	if (time >= self.mauserpistol_unjam_time) {
			if (random() > 0.8) {
				self.mauserpistol_jammed = 0;
				self.mauserpistol_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_mauserpistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_MAUSERPISTOL]) >= autocvar_g_balance_mauserpistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.mauserpistol_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_mauserpistol_clearjam_time, w_ready);
			if (self.mauserpistol_unjam != 1) {
				self.mauserpistol_unjam = 1;
				self.mauserpistol_unjam_time = time + autocvar_g_balance_mauserpistol_clearjam_time;
				self.mauserpistol_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			W_Reload(autocvar_g_balance_mauserpistol_primary_ammo, autocvar_g_balance_mauserpistol_reload_ammo, autocvar_g_balance_mauserpistol_reload_time, "weapons/reload.wav");
			
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_mauserpistol(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%1$s was shot in the chest by %2$s mauser pistol");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s was shot in the head by %2$s broomhandle pistol");
		else
			w_deathtypestring = _("%s was killed by %s's mauser pistol");
	}
	return TRUE;
}
#endif
#endif
