#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TENGAUGEDOUBLE, w_tengaugedouble, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "tengaugedouble", "tengaugedouble", _("10ga Double"))
#else
#ifdef SVQC

.float tengaugedouble_release;
.float tengaugedouble_casings;
.float tengaugedouble_jammed;
.float tengaugedouble_unjam;
.float tengaugedouble_unjam_time;
.float tengaugedouble_click;
.float tengaugedouble_halftime;
.float tengaugedouble_fulltime;
.float tengaugedouble_state;
.float tengaugedouble_ontrigger;
.float tengaugedouble_firedelay;
.float tengaugedouble_firenow;
.float tengaugedouble_botreload;
.float tengaugedouble_notnew;
.float tengaugedouble_reloadanimtime;
.float tengaugedouble_reloaddo;
.float tengaugedouble_reloaddo_wait;
.float tengaugedouble_whichshot;
.float tengaugedouble_beforfiringstate; //State right before firing

//Right side first
//Left side second _xhalf, _xcocked

void W_TenGaugeDouble_Attack (void)
{
	float sc;
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bullets;
	float	bulletspeed;
	float	bulletconstant;
	float   mywepdeathtype;
	entity flash;

	ammoamount = autocvar_g_balance_tengaugedouble_primary_ammo;
	bullets = autocvar_g_balance_tengaugedouble_primary_bullets;
	d = autocvar_g_balance_tengaugedouble_primary_damage;
	f = autocvar_g_balance_tengaugedouble_primary_force;
	spread = autocvar_g_balance_tengaugedouble_primary_spread;
	bulletspeed = autocvar_g_balance_tengaugedouble_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;
	
	
	if (self.tengaugedouble_firenow == 10) {
		mywepdeathtype = WEP_TENGAUGEDOUBLE | HITTYPE_SECONDARY;
	} else {
		mywepdeathtype = WEP_TENGAUGEDOUBLE;
	}


	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_tengaugedouble_reload_ammo);
	self.tengaugedouble_casings = self.tengaugedouble_casings + 1;
	
	if (autocvar_g_balance_tengaugedouble_jamrate &&
 	(autocvar_g_balance_tengaugedouble_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your tengaugedouble failed to fire\n");
		}
		self.tengaugedouble_jammed = 1;
	} else { //Start Not Jammed
		float f_diff;
		
		//if (self.tengaugedouble_firenow == 2) {
		if (self.tengaugedouble_whichshot) {
			//print("hereA\n");
			
			//f_diff = -32.75;
			f_diff = -3.75;
		} else {
			//print("here0\n");
			
			//f_diff = 32.75;
			f_diff = 3.75;
		}
		
	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	if (self.shootfromside == 1) {
		w_shotorg = w_shotorg + (v_up * f_diff);
	} else {
		w_shotorg = w_shotorg + (v_right * f_diff);
	}
	
	
		
		
	
		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, mywepdeathtype, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_tengaugedouble_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg + (w_shotdir * 30), w_shotdir * 1000, autocvar_g_balance_tengaugedouble_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 30));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 30), w_shotdir * 2, 25);
	}
	
	PlayerGunRise(self, autocvar_g_balance_tengaugedouble_gunrise, random() * autocvar_g_balance_tengaugedouble_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '20 0 0');
	
	} //End Not Jammed
	
	self.tengaugedouble_whichshot = self.tengaugedouble_whichshot + 1;
}

void W_TenGaugeDouble_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_tengaugedouble_secondary_animtime, w_ready);
}

float W_TenGaugeDouble_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_tengaugedouble_reload_ammo && self.clip_load < autocvar_g_balance_tengaugedouble_primary_ammo))
	{
		if (!self.tengaugedouble_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.tengaugedouble_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.tengaugedouble_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_tengaugedouble (void)
{
	weapon_defaultspawnfunc(WEP_TENGAUGEDOUBLE);
}

void w_tengaugedoubleselfmodels (void) {
	if (self.tengaugedouble_state == 400) {
		self.weaponname = "tengaugedouble-cocked";
	//////////////////////////////////////////////////////////////////////////
	////} el//se if (self.teng//augedoub//le_sta//te == 444) {
	////	self.we//aponname = "ten//gaugedouble-don//e-cock//ed";	
	//////////////////////////////////////////////////////////////////////////
	} else if (self.tengaugedouble_state == 4000) {
		self.weaponname = "tengaugedouble-cocked-cocked";
	}
}

.float tengaugedouble_primarytime;

float w_tengaugedouble(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_TenGaugeDouble_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.tengaugedouble_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_tengaugedouble_primary_speed, 0, 5, FALSE)) && (!self.tengaugedouble_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
				
				if (skill >= 2)
				if (self.tengaugedouble_state == 4000)
				if (self.clip_load >= autocvar_g_balance_tengaugedouble_primary_ammo) {
					if (skill >= 9) {
						if (random() > 0.5)
							self.BUTTON_ATCK2 = TRUE;
					} else if (skill >= 7) {
						if (random() > 0.6)
							self.BUTTON_ATCK2 = TRUE;
					} else if (skill >= 4) {
						if (random() > 0.7)
							self.BUTTON_ATCK2 = TRUE;
					} else {
						if (random() > 0.8)
							self.BUTTON_ATCK2 = TRUE;
					}	
				}
			}
		
		}
	}
	else if (req == WR_THINK && self.tengaugedouble_reloaddo)
	{
		//print("here\n");
		if (time > self.tengaugedouble_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_TenGaugeDouble_NeedManualReload())
	{
		self.tengaugedouble_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.tengaugedouble_reloadanimtime && self.tengaugedouble_reloadanimtime > time) {
		  	if (!self.tengaugedouble_reloaddo_wait) {
				self.tengaugedouble_reloadanimtime = 0;
				
				if (self.tengaugedouble_release == 1) {
					self.weaponname = "tengaugedouble";
					
					//print(self.weaponname, " --\n");
				} else {
					//self.weaponname = "tengaugedouble-cocked";
					w_tengaugedoubleselfmodels();
					
					
					//print(self.weaponname, " --\n");
				}
			}
		}
		
		
		if(autocvar_g_balance_tengaugedouble_reload_ammo && self.clip_load < autocvar_g_balance_tengaugedouble_primary_ammo) // forced reload
		{
			// don't force reload an empty tengaugedouble if its melee attack is active
			if not(autocvar_g_balance_tengaugedouble_secondary && self.ammo_shells < autocvar_g_balance_tengaugedouble_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.tengaugedouble_release = 0;
		}
		else
		{
		  if (self.tengaugedouble_jammed && self.tengaugedouble_unjam)
		  {
		  	if (time >= self.tengaugedouble_unjam_time) {
				self.tengaugedouble_jammed = 0;
				self.tengaugedouble_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.tengaugedouble_state == 3) {
		  		if (time > self.tengaugedouble_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeDouble_Attack2);
					self.tengaugedouble_state = 2;
					
					if (self.tengaugedouble_whichshot)
						self.weaponname = "tengaugedouble-xhalf";
					else
						self.weaponname = "tengaugedouble-half";
						
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_tengaugedouble_cockingrise, random() * autocvar_g_balance_tengaugedouble_cockingrun);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugedouble_state == 2) {
				if (time > self.tengaugedouble_fulltime) {
					self.tengaugedouble_state = 400;
					self.tengaugedouble_release = 0; //We finish pulling back the hammer
					
					if (self.tengaugedouble_whichshot)
						self.weaponname = "tengaugedouble-xcocked";
					else
						self.weaponname = "tengaugedouble-cocked";
						
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugedouble_state == 1) {
				if (time > self.tengaugedouble_firedelay) {
					self.tengaugedouble_state = 0;

					self.tengaugedouble_firedelay = 0;
					//self.weaponname = "tengaugedouble";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugedouble_firenow = 1;
					
					//print(self.weaponname, "\n");
				}
			}
			///////
			else if (self.tengaugedouble_state == 30) {
		  		if (time > self.tengaugedouble_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeDouble_Attack2);
					self.tengaugedouble_state = 20;
					self.weaponname = "tengaugedouble-cocked-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_tengaugedouble_cockingrise, random() * autocvar_g_balance_tengaugedouble_cockingrun);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugedouble_state == 20) {
				if (time > self.tengaugedouble_fulltime) {
					self.tengaugedouble_state = 4000;
					self.tengaugedouble_release = 0; //We finish pulling back the hammer
					self.weaponname = "tengaugedouble-cocked-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugedouble_state == 10) {
				if (time > self.tengaugedouble_firedelay) {
					//self.tengaugedouble_state = 00;
					self.tengaugedouble_state = 400;
			
					self.tengaugedouble_firedelay = 0;
					//self.weaponname = "tengaugedouble";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugedouble_firenow = 2;
					
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugedouble_state == 100) {
				//Both Barrels
				if (time > self.tengaugedouble_firedelay) {
					//self.tengaugedouble_state = 00;
					self.tengaugedouble_state = 0;
			
					self.tengaugedouble_firedelay = 0;
					//self.weaponname = "tengaugedouble";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugedouble_firenow = 10;
					
					//print(self.weaponname, "\n");
				}
			}
			///////
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.tengaugedouble_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_tengaugedouble_primary_refire))
				)
				{
						self.tengaugedouble_ontrigger = 1;
						
						
						W_TenGaugeDouble_Attack();
						if (self.tengaugedouble_firenow == 10) {
							//self.tengaugedouble_firenow = 2;
							W_TenGaugeDouble_Attack();
						}
						
						//print (ftos(self.tengaugedouble_state), "_state\n");
						//print (ftos(self.tengaugedouble_beforfiringstate), "_bfstate\n");
						if (self.tengaugedouble_beforfiringstate == 4000) {
							//print("Shot one of the 2 ready double barrels, follow up can be immediate\n");
							ATTACK_FINISHED(self) = time + 0.000001 * W_WeaponRateFactor();
						} else {
							ATTACK_FINISHED(self) = time + autocvar_g_balance_tengaugedouble_primary_refire * W_WeaponRateFactor();
						}
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tengaugedouble_primary_animtime, w_ready);
						//if (self.tengaugedouble_firenow == 2) {
						if (self.tengaugedouble_whichshot >= 2 || self.tengaugedouble_beforfiringstate != 4000) {
							self.tengaugedouble_release = 1; //Slide needs to be wracked
							//self.weaponname = "tengaugedouble";
						}
						self.tengaugedouble_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2 || self.tengaugedouble_state == 4000) &&
				(self.tengaugedouble_ontrigger != 1) &&
				(self.tengaugedouble_release != 1) &&
				(self.tengaugedouble_jammed != 1) &&
				(self.tengaugedouble_state == 400 || self.tengaugedouble_state == 4000) &&
					(weapon_prepareattack(0, 
					((self.tengaugedouble_state == 4000) ? 0.000001 : autocvar_g_balance_tengaugedouble_primary_firedelay)
					))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.tengaugedouble_beforfiringstate = self.tengaugedouble_state;
						
						if (self.tengaugedouble_state == 400) {
							self.weaponname = "tengaugedouble";
						} else if (self.tengaugedouble_state == 4000) {
							if (self.BUTTON_ATCK2) {
								self.weaponname = "tengaugedouble";
							} else {
								//////////////////////////////////////////////////////////////////////
								////sel//f.ten//gau//gedoubl//e_stat//e = 444//; //No, breaks stuff //
								//////////////////////////////////////////////////////////////////////
								self.weaponname = "tengaugedouble-done-cocked";
							}
						}

						self.tengaugedouble_firedelay = time + autocvar_g_balance_tengaugedouble_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeDouble_Attack2);
						
						if (self.tengaugedouble_state == 400) {
							self.tengaugedouble_state = 1;
						} else if (self.tengaugedouble_state == 4000) {
							if (self.BUTTON_ATCK2) {
								self.tengaugedouble_state = 100; //Both Barrels
							} else {
								self.tengaugedouble_state = 10;
							}
						}
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.tengaugedouble_ontrigger != 1) &&
				(self.tengaugedouble_release == 1 || self.tengaugedouble_state == 400) &&
				//edited added the 444 to see if can work?
				(self.tengaugedouble_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_tengaugedouble_secondary_refire))
				)
				{
					self.tengaugedouble_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeDouble_Attack2);
					self.tengaugedouble_halftime = time + (autocvar_g_balance_tengaugedouble_cocking_time * 0.5);
					self.tengaugedouble_fulltime = time + autocvar_g_balance_tengaugedouble_cocking_time;
					if (self.tengaugedouble_state == 400 && !self.tengaugedouble_whichshot) {
						//print("Setting state to 30\n");
						self.tengaugedouble_state = 30;
					} else {
						//print("Setting state to 3\n");
						self.tengaugedouble_state = 3;
					}
					//print("here3\n");
				}
				
				//////Test
				//else if ((self.BUTTON_ATCK2) && (!self.BUTTON_ATCK))
				//{
				//
				//	print(ftos(self.tengaugedouble_ontrigger), "_ontrigger\n");
				//	print(ftos(self.tengaugedouble_release), "_release\n");
				//	print(ftos(self.tengaugedouble_jammed), "_jammed\n");
				//	print(ftos(self.tengaugedouble_state), "_state\n");
				//	print(ftos(self.tengaugedouble_beforfiringstate), "_beforfiringstate\n");
				//}
				//////Test
				
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.tengaugedouble_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.tengaugedouble_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.tengaugedouble_jammed && self.tengaugedouble_unjam)
		  {
		  	if (time >= self.tengaugedouble_unjam_time) {
				self.tengaugedouble_jammed = 0;
				self.tengaugedouble_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_tengaugedouble.md3");
		precache_model ("models/weapons/v_tengaugedouble.md3");
		precache_model ("models/weapons/h_tengaugedouble.iqm");
		precache_model ("models/weapons/v_tengaugedouble-cocked.md3");
		precache_model ("models/weapons/h_tengaugedouble-cocked.iqm");
		precache_model ("models/weapons/v_tengaugedouble-half.md3");
		precache_model ("models/weapons/h_tengaugedouble-half.iqm");
		precache_model ("models/weapons/v_tengaugedouble-reload.md3");
		precache_model ("models/weapons/h_tengaugedouble-reload.iqm");
		
		
		precache_model ("models/weapons/g_tengaugedouble-cocked-cocked.md3");
		precache_model ("models/weapons/v_tengaugedouble-cocked-cocked.md3");
		precache_model ("models/weapons/h_tengaugedouble-cocked-cocked.iqm");
		precache_model ("models/weapons/v_tengaugedouble-done-cocked.md3");
		precache_model ("models/weapons/h_tengaugedouble-done-cocked.iqm");
		precache_model ("models/weapons/v_tengaugedouble-cocked-half.md3");
		precache_model ("models/weapons/h_tengaugedouble-cocked-half.iqm");
		
		//Other side after first has fired:
		precache_model ("models/weapons/v_tengaugedouble-xcocked.md3");
		precache_model ("models/weapons/h_tengaugedouble-xcocked.iqm");
		precache_model ("models/weapons/v_tengaugedouble-xhalf.md3");
		precache_model ("models/weapons/h_tengaugedouble-xhalf.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/shotgun_fire.wav");
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
		//self.weaponaltaim = '55 -0.15 -5.5';
		//self.weaponaltaim = '55 -0.15 -3.5';
		//self.weaponaltaim = '55 -0.15 -2.5';
		//self.weaponaltaim = '55 -0.15 -2.2';
		self.weaponaltaim = '55 -0.15 -2.7';
		weapon_setup(WEP_TENGAUGEDOUBLE);
		self.current_ammo = ammo_shells;
		
		self.tengaugedouble_reloaddo = 0;
		self.tengaugedouble_reloaddo_wait = 0;
		
		if not(self.tengaugedouble_notnew) {
			self.tengaugedouble_release = 1;
		
			self.weaponname = "tengaugedouble";
		} else {
			if (self.tengaugedouble_release == 1) {
				self.weaponname = "tengaugedouble";
			} else {
				//self.weaponname = "tengaugedouble-cocked";
				w_tengaugedoubleselfmodels();
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_tengaugedouble_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TENGAUGEDOUBLE]) >= autocvar_g_balance_tengaugedouble_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.tengaugedouble_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.tengaugedouble_jammed) {
			self.tengaugedouble_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_tengaugedouble_clearjam_time, w_ready);
			if (self.tengaugedouble_unjam != 1) {
				self.tengaugedouble_unjam = 1;
				self.tengaugedouble_unjam_time = time + autocvar_g_balance_tengaugedouble_clearjam_time;
				self.tengaugedouble_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the tengaugedouble\n");
				}
			}
		} else if not (self.tengaugedouble_reloadanimtime) {
			self.tengaugedouble_reloaddo = 1;
			self.tengaugedouble_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_tengaugedouble_reload_ammo && self.clip_load < autocvar_g_balance_tengaugedouble_primary_ammo) {
					self.weaponname = "tengaugedouble-reload";
				}
			self.tengaugedouble_reloadanimtime = time + frametime + autocvar_g_balance_tengaugedouble_reload_time;
		} else {
			self.tengaugedouble_reloaddo = 0;
			self.tengaugedouble_reloaddo_wait = 0;
			self.tengaugedouble_botreload = 1;
			self.tengaugedouble_whichshot = 0;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_tengaugedouble_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.tengaugedouble_reloadanimtime = time + frametime + (autocvar_g_balance_tengaugedouble_reload_time - (autocvar_g_balance_tengaugedouble_reload_time * (self.clip_load/autocvar_g_balance_tengaugedouble_reload_ammo)));
				W_Reload(autocvar_g_balance_tengaugedouble_primary_ammo, autocvar_g_balance_tengaugedouble_reload_ammo, autocvar_g_balance_tengaugedouble_reload_time - (autocvar_g_balance_tengaugedouble_reload_time * (self.clip_load/autocvar_g_balance_tengaugedouble_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.tengaugedouble_reloadanimtime = time + frametime + autocvar_g_balance_tengaugedouble_reload_time;
				W_Reload(autocvar_g_balance_tengaugedouble_primary_ammo, autocvar_g_balance_tengaugedouble_reload_ammo, autocvar_g_balance_tengaugedouble_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_tengaugedouble_casings) {
					for (sc = 0;sc < self.tengaugedouble_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 60, self, '0 0 -3');
					}
				}
				self.tengaugedouble_casings = 0;
			}
		}
		//self.tengaugedouble_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_tengaugedouble(float req)
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
		if(w_deathtype & HITTYPE_SECONDARY) {
			if(w_deathtype & HITTYPE_CORESHOT)
				w_deathtypestring = _("%2$s gave %1$s both barrels to the chest");
			else 
				w_deathtypestring = _("%2$s gave %1$s both barrels");
		} else if(w_deathtype & HITTYPE_CORESHOT) {
			w_deathtypestring = _("%1$s found it difficult to live due to the hole %2$s put in their chest");
		} else {
			w_deathtypestring = _("%s was gunned down with a 10ga double-barrel shotgun by %s");
		}
	}
	return TRUE;
}
#endif
#endif
