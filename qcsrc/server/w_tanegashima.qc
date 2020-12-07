#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TANEGASHIMA, w_tanegashima, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "tanegashima", "tanegashima", _("Tanegashima"))
#else
#ifdef SVQC

.float tanegashima_release;
.float tanegashima_casings;
.float tanegashima_jammed;
.float tanegashima_unjam;
.float tanegashima_unjam_time;
.float tanegashima_click;
.float tanegashima_halftime;
.float tanegashima_fulltime;
.float tanegashima_state;
.float tanegashima_ontrigger;
.float tanegashima_firedelay;
.float tanegashima_firenow;
.float tanegashima_botreload;
.float tanegashima_notnew;

.float tanegashima_arrowlit;
.float tanegashima_arrownextburn;
.float tanegashima_arrownextraincheck;

.entity tanegashimalight;

void tanegashima_thinklight() {
	if (self.owner.tanegashima_arrowlit == 1 && self.tanegashima_arrowlit == 1 && self.owner.health > 0) {
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *24)+(v_up *2));
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *20)+(v_up *2));
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *2));
		  	if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *2));
		    	}
		  }
		}
		setorigin(self, vlporigin);
		self.nextthink = time;
		self.tanegashima_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void tanegashima_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 16;
	newtorchlight.color = '0.85 0.20 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = tanegashima_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.tanegashima_arrowlit = 1;
	self.tanegashimalight = newtorchlight;
}


void tanegashima_possiblylight(entity player)
{
			if ((player.watertype == CONTENT_WATER || player.watertype == CONTENT_SLIME) && player.waterlevel > 2) {
				//Do nothing
			} else {
				weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_torch_reload_time, w_ready);
				player.tanegashima_arrowlit = 1;
			
				if (player.weaponname == "tanegashima_unlit") {
					player.weaponname = "tanegashima";
				} else if (player.weaponname == "tanegashima-half_unlit") {
					player.weaponname = "tanegashima-half";
				} else if (player.weaponname == "tanegashima-cocked_unlit") {
					player.weaponname = "tanegashima-cocked";
				}	
				
				if ((clienttype(player) == CLIENTTYPE_REAL)) {
					sprint(player, "You lit the tanegashima's matchcord\n");
				}
				tanegashima_spawnlight();
			}
}

void tanegashima_changemodeltounlit(entity player)
{
	if (player.weaponname == "tanegashima") {
		player.weaponname = "tanegashima_unlit";
	} else if (player.weaponname == "tanegashima-half") {
		player.weaponname = "tanegashima-half_unlit";
	} else if (player.weaponname == "tanegashima-cocked") {
		player.weaponname = "tanegashima-cocked_unlit";
	}
}

//These are done at the end of the weapon's think below
void tanegashima_litoperations(entity player)
{
		if (player.tanegashima_arrowlit == 1) {
			local float myrainamount;
			myrainamount = 0;
			
			if (time > player.tanegashima_arrownextraincheck) {
				myrainamount = CheckIfEntityIsInRain(player);
				
				//print(ftos(myrainamount),"_RainAmnt\n");
				
				player.tanegashima_arrownextraincheck = time + 5;
			}
				
		
			if ((player.watertype == CONTENT_WATER || player.watertype == CONTENT_SLIME) && player.waterlevel > 2) {
				pointparticles(particleeffectnum("smoke_big"), ((player.origin + player.view_ofs)+(v_forward *16)+(v_up *2)), '0 0 30', 10);
				spamsound (player, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
				player.tanegashima_arrowlit = 0;
				tanegashima_changemodeltounlit(player);
			} else if (myrainamount >= 10) {
				player.tanegashima_arrowlit = 0;
				tanegashima_changemodeltounlit(player);
			} else if (time > player.tanegashima_arrownextburn) {
				//W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
				player.tanegashima_arrownextburn = time + 0.2;
				player.tanegashimalight.tanegashima_arrowlit = 1;
			} else {
				player.tanegashimalight.tanegashima_arrowlit = 1;
			}
		} else {
			//Light if in lava...
			if ((player.watertype == CONTENT_LAVA) && player.waterlevel > 2) {
				tanegashima_possiblylight(player);
			}
		}
}

void W_Tanegashima_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_tanegashima_primary_ammo;
	d = autocvar_g_balance_tanegashima_primary_damage;
	f = autocvar_g_balance_tanegashima_primary_force;
	spread = autocvar_g_balance_tanegashima_primary_spread;
	bulletspeed = autocvar_g_balance_tanegashima_primary_speed;
	bulletconstant = autocvar_g_balance_tanegashima_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_tanegashima_reload_ammo);
	self.tanegashima_casings = self.tanegashima_casings + 1;
	
	if (autocvar_g_balance_tanegashima_jamrate &&
 	(autocvar_g_balance_tanegashima_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your tanegashima failed to fire\n");
		}
		self.tanegashima_jammed = 1;
	} else { //Start Not Jammed

	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire_somebass.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_tanegashima_primary_headshotaddeddamage, f, WEP_TANEGASHIMA, PROJECTILE_MUSKETBALL69, 1, bulletconstant, autocvar_g_balance_tanegashima_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg + (w_shotdir * 14), w_shotdir * 1000, autocvar_g_balance_tanegashima_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 16));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 16), w_shotdir * 2, 30);
	}
	
	PlayerGunRise(self, autocvar_g_balance_tanegashima_gunrise, random() * autocvar_g_balance_tanegashima_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '12 0 0');
	
	} //End Not Jammed
}

void W_Tanegashima_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_tanegashima_secondary_animtime, w_ready);
}

float W_Tanegashima_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_tanegashima_reload_ammo && self.clip_load < autocvar_g_balance_tanegashima_primary_ammo))
	{
		if (!self.tanegashima_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.tanegashima_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.tanegashima_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_tanegashima (void)
{
	weapon_defaultspawnfunc(WEP_TANEGASHIMA);
}


.float tanegashima_primarytime;

float w_tanegashima(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Tanegashima_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.tanegashima_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		if ((!self.tanegashima_arrowlit)
		&& (!((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2))
		) {
			//We're a bot with an unlit matchcord and not underwater, better light it up if we're even abit aggressive
			weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_tanegashima_primary_speed, 0, 5, FALSE)) && (!self.tanegashima_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
			}
		
		}
	}
	else if (req == WR_THINK && !W_Tanegashima_NeedManualReload())
	{
		self.tanegashima_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		if (flintlock_powder_gets_hot(mysmokeorg)
		|| flintlock_powder_spontaneously_ignites(self)) {
			W_Tanegashima_Attack();
		} else if(autocvar_g_balance_tanegashima_reload_ammo && self.clip_load < autocvar_g_balance_tanegashima_primary_ammo) // forced reload
		{
			// don't force reload an empty tanegashima if its melee attack is active
			if not(autocvar_g_balance_tanegashima_secondary && self.ammo_nails < autocvar_g_balance_tanegashima_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.tanegashima_release = 0;
		}
		else
		{
		  if (self.tanegashima_jammed && self.tanegashima_unjam)
		  {
		  	if (time >= self.tanegashima_unjam_time) {
				self.tanegashima_jammed = 0;
				self.tanegashima_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.tanegashima_state == 3) {
		  		if (time > self.tanegashima_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_Tanegashima_Attack2);
					self.tanegashima_state = 2;
					
					if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima-half"; }
					else { self.weaponname = "tanegashima-half_unlit"; }
					
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_tanegashima_cockingrise, random() * autocvar_g_balance_tanegashima_cockingrun);
				}
			} else if (self.tanegashima_state == 2) {
				if (time > self.tanegashima_fulltime) {
					self.tanegashima_state = 400;
					self.tanegashima_release = 0; //We finish pulling back the hammer
					
					if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima-cocked"; }
					else { self.weaponname = "tanegashima-cocked_unlit"; }
					
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				}
			} else if (self.tanegashima_state == 1) {
				if (time > self.tanegashima_firedelay) {
					self.tanegashima_state = 0;

					self.tanegashima_firedelay = 0;
					
					if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima"; }
					else { self.weaponname = "tanegashima_unlit"; }
					
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tanegashima_firenow = 1;
					
				}
			}
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.tanegashima_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_tanegashima_primary_refire))
				)
				{
						self.tanegashima_ontrigger = 1;
						
						if (flintlock_powder_gets_wet(mysmokeorg)) {

							W_DecreaseAmmo(ammo_nails, autocvar_g_balance_tanegashima_primary_ammo, autocvar_g_balance_tanegashima_reload_ammo);
							self.tanegashima_casings = self.tanegashima_casings + 1;
	
							//if ((clienttype(self) == CLIENTTYPE_REAL)) {
							//	sprint(self, "Your powder failed to ignite when wet\n");
							//}
							////Doesn't jam, just decreases ammo, reload
		
						} else {
							if (self.tanegashima_arrowlit == 1) {
								if (CheckIfEntityIsInRain(self) >= 10) {
									self.tanegashima_arrowlit = 0;
									tanegashima_changemodeltounlit(self);
								} else {
									W_Tanegashima_Attack();
								}
							}
						}
						
						ATTACK_FINISHED(self) = time + autocvar_g_balance_tanegashima_primary_refire * W_WeaponRateFactor();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tanegashima_primary_animtime, w_ready);
						self.tanegashima_release = 1; //Slide needs to be wracked
						
						if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima"; }
						else { self.weaponname = "tanegashima_unlit"; }
					
						self.tanegashima_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2) &&
				(self.tanegashima_ontrigger != 1) &&
				(self.tanegashima_release != 1) &&
				(self.tanegashima_jammed != 1) &&
				(self.tanegashima_state == 400) &&
				(weapon_prepareattack(0, autocvar_g_balance_tanegashima_primary_firedelay))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima"; }
						else { self.weaponname = "tanegashima_unlit"; }

						self.tanegashima_firedelay = time + autocvar_g_balance_tanegashima_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_Tanegashima_Attack2);
						self.tanegashima_state = 1;
												
						if not (flintlock_powder_gets_wet(mysmokeorg)) {
							if (self.tanegashima_arrowlit == 1) {
								pointparticles(particleeffectnum("uzi_muzzleflash"), mysmokeorg, '0 0 0', 1);
								pointparticles(particleeffectnum("pipe_smoke"), mysmokeorg, '0 0 0', 10);
							}
						}
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.tanegashima_ontrigger != 1) &&
				(self.tanegashima_release == 1) &&
				(self.tanegashima_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_tanegashima_secondary_refire))
				)
				{
					self.tanegashima_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_Tanegashima_Attack2);
					self.tanegashima_halftime = time + (autocvar_g_balance_tanegashima_cocking_time * 0.5);
					self.tanegashima_fulltime = time + autocvar_g_balance_tanegashima_cocking_time;
					self.tanegashima_state = 3;
					//print("here3\n");
				}
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.tanegashima_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
		tanegashima_litoperations(self);
	}
	else if (req == WR_THINK)
	{
		  self.tanegashima_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.tanegashima_jammed && self.tanegashima_unjam)
		  {
		  	if (time >= self.tanegashima_unjam_time) {
				self.tanegashima_jammed = 0;
				self.tanegashima_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
		  
		  tanegashima_litoperations(self);
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_tanegashima.md3");
		precache_model ("models/weapons/v_tanegashima.md3");
		precache_model ("models/weapons/h_tanegashima.iqm");
		precache_model ("models/weapons/v_tanegashima-cocked.md3");
		precache_model ("models/weapons/h_tanegashima-cocked.iqm");
		precache_model ("models/weapons/v_tanegashima-half.md3");
		precache_model ("models/weapons/h_tanegashima-half.iqm");
		
		
		precache_model ("models/weapons/v_tanegashima_unlit.md3");
		precache_model ("models/weapons/h_tanegashima_unlit.iqm");
		precache_model ("models/weapons/v_tanegashima-cocked_unlit.md3");
		precache_model ("models/weapons/h_tanegashima-cocked_unlit.iqm");
		precache_model ("models/weapons/v_tanegashima-half_unlit.md3");
		precache_model ("models/weapons/h_tanegashima-half_unlit.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire_somebass.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -1.52';
		//self.weaponaltaim = '40 -0.55 -1.52';
		//self.weaponaltaim = '40 -0.45 -1.52';
		//self.weaponaltaim = '40 -0.15 -1.52';
		//self.weaponaltaim = '55 -0.15 -2.5';
		//self.weaponaltaim = '55 -0.05 -2.5';
		//self.weaponaltaim = '55 0.05 -2.5';
		//self.weaponaltaim = '55 0.05 -3.5';
		//self.weaponaltaim = '65 0.05 -3.5';
		self.weaponaltaim = '60 0.05 -3.5';
		weapon_setup(WEP_TANEGASHIMA);
		self.current_ammo = ammo_nails;
		
		if not(self.tanegashima_notnew) {
			self.tanegashima_release = 1;
		
			if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima"; }
			else { self.weaponname = "tanegashima_unlit"; }

		} else {
			self.tanegashima_arrowlit = 0;
			
			if (self.tanegashima_release == 1) {
				if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima"; }
				else { self.weaponname = "tanegashima_unlit"; }

			} else {
				if (self.tanegashima_arrowlit == 1) { self.weaponname = "tanegashima-cocked"; }
				else { self.weaponname = "tanegashima-cocked_unlit"; }

			}
		}
		
		
		if (self.tanegashima_arrowlit) {
			tanegashima_spawnlight();
		}
		
	}
	else if (req == WR_RESETPLAYER)
	{
		self.tanegashima_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_tanegashima_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TANEGASHIMA]) >= autocvar_g_balance_tanegashima_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.tanegashima_casings = 0;
	}
	else if (req == WR_GONETHINK)
	{
		//We lost the weapon
		self.tanegashima_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We lost dropped the weapon
		self.tanegashima_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		
		self.tanegashima_botreload = 1;
		if (self.tanegashima_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_tanegashima_clearjam_time, w_ready);
			if (self.tanegashima_unjam != 1) {
				self.tanegashima_unjam = 1;
				self.tanegashima_unjam_time = time + autocvar_g_balance_tanegashima_clearjam_time;
				self.tanegashima_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the tanegashima\n");
				}
			}
		} else if not(self.tanegashima_arrowlit) {
			tanegashima_possiblylight(self);
		} else {
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_tanegashima_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				W_Reload(autocvar_g_balance_tanegashima_primary_ammo, autocvar_g_balance_tanegashima_reload_ammo, autocvar_g_balance_tanegashima_reload_time - (autocvar_g_balance_tanegashima_reload_time * (self.clip_load/autocvar_g_balance_tanegashima_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				W_Reload(autocvar_g_balance_tanegashima_primary_ammo, autocvar_g_balance_tanegashima_reload_ammo, autocvar_g_balance_tanegashima_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_tanegashima_casings) {
					for (sc = 0;sc < self.tanegashima_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 56, self, '0 0 -3');
					}
				}
				self.tanegashima_casings = 0;
			}
		}
		//self.tanegashima_release = 0; //Do it yourself		
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_tanegashima(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("largebullet_impact"), org2, w_backoff * 1000, 1);
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
			w_deathtypestring = _("%s was shot in the chest by %s's tanegashima");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was shot in the skull by %s's tanegashima");
		else
			w_deathtypestring = _("%s was shot to death by %s's tanegashima");
	}
	return TRUE;
}
#endif
#endif
