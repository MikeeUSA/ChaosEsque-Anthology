#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TENGAUGESAWEDOFF, w_tengaugesawedoff, IT_SHELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "tengaugesawedoff", "tengaugesawedoff", _("10ga Sawed-Off"))
#else
#ifdef SVQC

.float tengaugesawedoff_release;
.float tengaugesawedoff_casings;
.float tengaugesawedoff_jammed;
.float tengaugesawedoff_unjam;
.float tengaugesawedoff_unjam_time;
.float tengaugesawedoff_click;
.float tengaugesawedoff_halftime;
.float tengaugesawedoff_fulltime;
.float tengaugesawedoff_state;
.float tengaugesawedoff_ontrigger;
.float tengaugesawedoff_firedelay;
.float tengaugesawedoff_firenow;
.float tengaugesawedoff_botreload;
.float tengaugesawedoff_notnew;
.float tengaugesawedoff_reloadanimtime;
.float tengaugesawedoff_reloaddo;
.float tengaugesawedoff_reloaddo_wait;
.float tengaugesawedoff_whichshot;
.float tengaugesawedoff_beforfiringstate; //State right before firing

//Right side first
//Left side second _xhalf, _xcocked

void W_TenGaugeSawedOff_Attack (void)
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

	ammoamount = autocvar_g_balance_tengaugesawedoff_primary_ammo;
	bullets = autocvar_g_balance_tengaugesawedoff_primary_bullets;
	d = autocvar_g_balance_tengaugesawedoff_primary_damage;
	f = autocvar_g_balance_tengaugesawedoff_primary_force;
	spread = autocvar_g_balance_tengaugesawedoff_primary_spread;
	bulletspeed = autocvar_g_balance_tengaugesawedoff_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_shotgunshot_bulletconstant;
	
	
	if (self.tengaugesawedoff_firenow == 10) {
		mywepdeathtype = WEP_TENGAUGESAWEDOFF | HITTYPE_SECONDARY;
	} else {
		mywepdeathtype = WEP_TENGAUGESAWEDOFF;
	}


	W_DecreaseAmmo(ammo_shells, ammoamount, autocvar_g_balance_tengaugesawedoff_reload_ammo);
	self.tengaugesawedoff_casings = self.tengaugesawedoff_casings + 1;
	
	if (autocvar_g_balance_tengaugesawedoff_jamrate &&
 	(autocvar_g_balance_tengaugesawedoff_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your tengaugesawedoff failed to fire\n");
		}
		self.tengaugesawedoff_jammed = 1;
	} else { //Start Not Jammed
		float f_diff;
		
		//if (self.tengaugesawedoff_firenow == 2) {
		if (self.tengaugesawedoff_whichshot) {
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
			fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, mywepdeathtype, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_tengaugesawedoff_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg + (w_shotdir * 3), w_shotdir * 1000, autocvar_g_balance_tengaugesawedoff_primary_ammo);
	
	local float mytestpointcontents;
	mytestpointcontents = pointcontents(w_shotorg + (w_shotdir * 3));
	if (mytestpointcontents == CONTENT_WATER
	|| mytestpointcontents == CONTENT_SLIME
	|| mytestpointcontents == CONTENT_LAVA)
	{
		//Do nothing
	} else {
		pointparticles(particleeffectnum("pipe_smoke"), w_shotorg + (w_shotdir * 3), w_shotdir * 2, 25);
	}
	
	PlayerGunRise(self, autocvar_g_balance_tengaugesawedoff_gunrise, random() * autocvar_g_balance_tengaugesawedoff_gunrun);

	// muzzle flash for 1st person view
	flash = spawn();
	setmodel(flash, "models/uziflash.md3"); // precision set below
	flash.think = SUB_Remove;
	flash.nextthink = time + 0.06;
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '-9 0 0');
	
	} //End Not Jammed
	
	self.tengaugesawedoff_whichshot = self.tengaugesawedoff_whichshot + 1;
}

void W_TenGaugeSawedOff_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_tengaugesawedoff_secondary_animtime, w_ready);
}

float W_TenGaugeSawedOff_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_tengaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_tengaugesawedoff_primary_ammo))
	{
		if (!self.tengaugesawedoff_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.tengaugesawedoff_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.tengaugesawedoff_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_tengaugesawedoff (void)
{
	weapon_defaultspawnfunc(WEP_TENGAUGESAWEDOFF);
}

void w_tengaugesawedoffselfmodels (void) {
	if (self.tengaugesawedoff_state == 400) {
		self.weaponname = "tengaugesawedoff-cocked";
	////
	} else if (self.tengaugesawedoff_state == 4000) {
		self.weaponname = "tengaugesawedoff-cocked-cocked";
	}
}

.float tengaugesawedoff_primarytime;

float w_tengaugesawedoff(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_TenGaugeSawedOff_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.tengaugesawedoff_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (random() > 0.80) {
			//Do nothing
		} else if (random() > 0.60) {
			self.BUTTON_ATCK2 = TRUE;
		} else {
		
			if((bot_aim(autocvar_g_balance_tengaugesawedoff_primary_speed, 0, 5, FALSE)) && (!self.tengaugesawedoff_ontrigger))
			{
				self.BUTTON_ATCK = TRUE;
				
				if (skill >= 2)
				if (self.tengaugesawedoff_state == 4000)
				if (self.clip_load >= autocvar_g_balance_tengaugesawedoff_primary_ammo) {
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
	else if (req == WR_THINK && self.tengaugesawedoff_reloaddo)
	{
		//print("here\n");
		if (time > self.tengaugesawedoff_reloaddo_wait) {
			weapon_action(self.weapon, WR_RELOAD);
		}
	}
	else if (req == WR_THINK && !W_TenGaugeSawedOff_NeedManualReload())
	{
		self.tengaugesawedoff_notnew = 1;
		
		vector mysmokeorg;
		mysmokeorg = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
		
		
		if (self.tengaugesawedoff_reloadanimtime && self.tengaugesawedoff_reloadanimtime > time) {
		  	if (!self.tengaugesawedoff_reloaddo_wait) {
				self.tengaugesawedoff_reloadanimtime = 0;
				
				if (self.tengaugesawedoff_release == 1) {
					self.weaponname = "tengaugesawedoff";
					
					//print(self.weaponname, " --\n");
				} else {
					//self.weaponname = "tengaugesawedoff-cocked";
					w_tengaugesawedoffselfmodels();
					
					
					//print(self.weaponname, " --\n");
				}
			}
		}
		
		
		if(autocvar_g_balance_tengaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_tengaugesawedoff_primary_ammo) // forced reload
		{
			// don't force reload an empty tengaugesawedoff if its melee attack is active
			if not(autocvar_g_balance_tengaugesawedoff_secondary && self.ammo_shells < autocvar_g_balance_tengaugesawedoff_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.tengaugesawedoff_release = 0;
		}
		else
		{
		  if (self.tengaugesawedoff_jammed && self.tengaugesawedoff_unjam)
		  {
		  	if (time >= self.tengaugesawedoff_unjam_time) {
				self.tengaugesawedoff_jammed = 0;
				self.tengaugesawedoff_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
		  	if (self.tengaugesawedoff_state == 3) {
		  		if (time > self.tengaugesawedoff_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeSawedOff_Attack2);
					self.tengaugesawedoff_state = 2;
					
					if (self.tengaugesawedoff_whichshot)
						self.weaponname = "tengaugesawedoff-xhalf";
					else
						self.weaponname = "tengaugesawedoff-half";
						
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_tengaugesawedoff_cockingrise, random() * autocvar_g_balance_tengaugesawedoff_cockingrun);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugesawedoff_state == 2) {
				if (time > self.tengaugesawedoff_fulltime) {
					self.tengaugesawedoff_state = 400;
					self.tengaugesawedoff_release = 0; //We finish pulling back the hammer
					
					if (self.tengaugesawedoff_whichshot)
						self.weaponname = "tengaugesawedoff-xcocked";
					else
						self.weaponname = "tengaugesawedoff-cocked";
						
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugesawedoff_state == 1) {
				if (time > self.tengaugesawedoff_firedelay) {
					self.tengaugesawedoff_state = 0;

					self.tengaugesawedoff_firedelay = 0;
					//self.weaponname = "tengaugesawedoff";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugesawedoff_firenow = 1;
					
					//print(self.weaponname, "\n");
				}
			}
			///////
			else if (self.tengaugesawedoff_state == 30) {
		  		if (time > self.tengaugesawedoff_halftime) {
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					//weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeSawedOff_Attack2);
					self.tengaugesawedoff_state = 20;
					self.weaponname = "tengaugesawedoff-cocked-half";
					spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					
						//print("SingleAction\n");
						PlayerGunRise(self, autocvar_g_balance_tengaugesawedoff_cockingrise, random() * autocvar_g_balance_tengaugesawedoff_cockingrun);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugesawedoff_state == 20) {
				if (time > self.tengaugesawedoff_fulltime) {
					self.tengaugesawedoff_state = 4000;
					self.tengaugesawedoff_release = 0; //We finish pulling back the hammer
					self.weaponname = "tengaugesawedoff-cocked-cocked";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
				
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugesawedoff_state == 10) {
				if (time > self.tengaugesawedoff_firedelay) {
					//self.tengaugesawedoff_state = 00;
					self.tengaugesawedoff_state = 400;
			
					self.tengaugesawedoff_firedelay = 0;
					//self.weaponname = "tengaugesawedoff";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugesawedoff_firenow = 2;
					
					//print(self.weaponname, "\n");
				}
			} else if (self.tengaugesawedoff_state == 100) {
				//Both Barrels
				if (time > self.tengaugesawedoff_firedelay) {
					//self.tengaugesawedoff_state = 00;
					self.tengaugesawedoff_state = 0;
			
					self.tengaugesawedoff_firedelay = 0;
					//self.weaponname = "tengaugesawedoff";
					spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.95, ATTN_NORM);
					self.tengaugesawedoff_firenow = 10;
					
					//print(self.weaponname, "\n");
				}
			}
			///////
			else 
			{
				//print("here0\n");
				////NORMAL
				if (
				(self.tengaugesawedoff_firenow) &&
				(weapon_prepareattack(0, autocvar_g_balance_tengaugesawedoff_primary_refire))
				)
				{
						self.tengaugesawedoff_ontrigger = 1;
						
						
						W_TenGaugeSawedOff_Attack();
						if (self.tengaugesawedoff_firenow == 10) {
							//self.tengaugesawedoff_firenow = 2;
							W_TenGaugeSawedOff_Attack();
						}
						
						//print (ftos(self.tengaugesawedoff_state), "_state\n");
						//print (ftos(self.tengaugesawedoff_beforfiringstate), "_bfstate\n");
						if (self.tengaugesawedoff_beforfiringstate == 4000) {
							//print("Shot one of the 2 ready double barrels, follow up can be immediate\n");
							ATTACK_FINISHED(self) = time + 0.000001 * W_WeaponRateFactor();
						} else {
							ATTACK_FINISHED(self) = time + autocvar_g_balance_tengaugesawedoff_primary_refire * W_WeaponRateFactor();
						}
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tengaugesawedoff_primary_animtime, w_ready);
						//if (self.tengaugesawedoff_firenow == 2) {
						if (self.tengaugesawedoff_whichshot >= 2 || self.tengaugesawedoff_beforfiringstate != 4000) {
							self.tengaugesawedoff_release = 1; //Slide needs to be wracked
							//self.weaponname = "tengaugesawedoff";
						}
						self.tengaugesawedoff_firenow = 0;
						//print("here1\n");
						
				}
				else if (
				(self.BUTTON_ATCK) &&
				(!self.BUTTON_ATCK2 || self.tengaugesawedoff_state == 4000) &&
				(self.tengaugesawedoff_ontrigger != 1) &&
				(self.tengaugesawedoff_release != 1) &&
				(self.tengaugesawedoff_jammed != 1) &&
				(self.tengaugesawedoff_state == 400 || self.tengaugesawedoff_state == 4000) &&
					(weapon_prepareattack(0, 
					((self.tengaugesawedoff_state == 4000) ? 0.000001 : autocvar_g_balance_tengaugesawedoff_primary_firedelay)
					))
				)
				{
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
						self.tengaugesawedoff_beforfiringstate = self.tengaugesawedoff_state;
						
						if (self.tengaugesawedoff_state == 400) {
							self.weaponname = "tengaugesawedoff";
						} else if (self.tengaugesawedoff_state == 4000) {
							if (self.BUTTON_ATCK2) {
								self.weaponname = "tengaugesawedoff";
							} else {
								////
								self.weaponname = "tengaugesawedoff-done-cocked";
							}
						}

						self.tengaugesawedoff_firedelay = time + autocvar_g_balance_tengaugesawedoff_primary_firedelay;
						weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeSawedOff_Attack2);
						
						if (self.tengaugesawedoff_state == 400) {
							self.tengaugesawedoff_state = 1;
						} else if (self.tengaugesawedoff_state == 4000) {
							if (self.BUTTON_ATCK2) {
								self.tengaugesawedoff_state = 100; //Both Barrels
							} else {
								self.tengaugesawedoff_state = 10;
							}
						}
												
					//print("here2\n");
				}
				else if (
				(self.BUTTON_ATCK2) &&
				(!self.BUTTON_ATCK) &&
				(self.tengaugesawedoff_ontrigger != 1) &&
				(self.tengaugesawedoff_release == 1 || self.tengaugesawedoff_state == 400) &&
				//edited added the 444 to see if can work?
				(self.tengaugesawedoff_jammed != 1) &&
				(weapon_prepareattack(0, autocvar_g_balance_tengaugesawedoff_secondary_refire))
				)
				{
					self.tengaugesawedoff_ontrigger = 1;
					// attempt forcing playback of the anim by switching to another anim (that we never play) here...
					weapon_thinkf(WFRAME_FIRE1, 0, W_TenGaugeSawedOff_Attack2);
					self.tengaugesawedoff_halftime = time + (autocvar_g_balance_tengaugesawedoff_cocking_time * 0.5);
					self.tengaugesawedoff_fulltime = time + autocvar_g_balance_tengaugesawedoff_cocking_time;
					if (self.tengaugesawedoff_state == 400 && !self.tengaugesawedoff_whichshot) {
						//print("Setting state to 30\n");
						self.tengaugesawedoff_state = 30;
					} else {
						//print("Setting state to 3\n");
						self.tengaugesawedoff_state = 3;
					}
					//print("here3\n");
				}
				
				//////Test
				//else if ((self.BUTTON_ATCK2) && (!self.BUTTON_ATCK))
				//{
				//
				//	print(ftos(self.tengaugesawedoff_ontrigger), "_ontrigger\n");
				//	print(ftos(self.tengaugesawedoff_release), "_release\n");
				//	print(ftos(self.tengaugesawedoff_jammed), "_jammed\n");
				//	print(ftos(self.tengaugesawedoff_state), "_state\n");
				//	print(ftos(self.tengaugesawedoff_beforfiringstate), "_beforfiringstate\n");
				//}
				//////Test
				
				
				
				if not(self.BUTTON_ATCK || self.BUTTON_ATCK2)
				{
					self.tengaugesawedoff_ontrigger = 0;
				}
				////END NORMAL////
			}
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		  self.tengaugesawedoff_notnew = 1;
		  
		  //If we have to unjam when we are out of ammo, we never get to with the other code...
		  if (self.tengaugesawedoff_jammed && self.tengaugesawedoff_unjam)
		  {
		  	if (time >= self.tengaugesawedoff_unjam_time) {
				self.tengaugesawedoff_jammed = 0;
				self.tengaugesawedoff_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_tengaugesawedoff.md3");
		precache_model ("models/weapons/v_tengaugesawedoff.md3");
		precache_model ("models/weapons/h_tengaugesawedoff.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-cocked.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-cocked.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-half.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-half.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-reload.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-reload.iqm");
		
		
		precache_model ("models/weapons/g_tengaugesawedoff-cocked-cocked.md3");
		precache_model ("models/weapons/v_tengaugesawedoff-cocked-cocked.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-cocked-cocked.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-done-cocked.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-done-cocked.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-cocked-half.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-cocked-half.iqm");
		
		//Other side after first has fired:
		precache_model ("models/weapons/v_tengaugesawedoff-xcocked.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-xcocked.iqm");
		precache_model ("models/weapons/v_tengaugesawedoff-xhalf.md3");
		precache_model ("models/weapons/h_tengaugesawedoff-xhalf.iqm");
		
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
		//self.weaponaltaim = '55 -0.15 -2.7';
		self.weaponaltaim = '58 -0.15 -2.8';
		weapon_setup(WEP_TENGAUGESAWEDOFF);
		self.current_ammo = ammo_shells;
		
		self.tengaugesawedoff_reloaddo = 0;
		self.tengaugesawedoff_reloaddo_wait = 0;
		
		if not(self.tengaugesawedoff_notnew) {
			self.tengaugesawedoff_release = 1;
		
			self.weaponname = "tengaugesawedoff";
		} else {
			if (self.tengaugesawedoff_release == 1) {
				self.weaponname = "tengaugesawedoff";
			} else {
				//self.weaponname = "tengaugesawedoff-cocked";
				w_tengaugesawedoffselfmodels();
			}
		}
		
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_shells >= autocvar_g_balance_tengaugesawedoff_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TENGAUGESAWEDOFF]) >= autocvar_g_balance_tengaugesawedoff_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.tengaugesawedoff_casings = 0;
	}
	else if (req == WR_RELOAD)
	{
		if (self.tengaugesawedoff_jammed) {
			self.tengaugesawedoff_botreload = 1;
		
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_tengaugesawedoff_clearjam_time, w_ready);
			if (self.tengaugesawedoff_unjam != 1) {
				self.tengaugesawedoff_unjam = 1;
				self.tengaugesawedoff_unjam_time = time + autocvar_g_balance_tengaugesawedoff_clearjam_time;
				self.tengaugesawedoff_click = 0;
				if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
					sprint(self.owner, "You work on the tengaugesawedoff\n");
				}
			}
		} else if not (self.tengaugesawedoff_reloadanimtime) {
			self.tengaugesawedoff_reloaddo = 1;
			self.tengaugesawedoff_reloaddo_wait = time+frametime;
				if (autocvar_g_balance_tengaugesawedoff_reload_ammo && self.clip_load < autocvar_g_balance_tengaugesawedoff_primary_ammo) {
					self.weaponname = "tengaugesawedoff-reload";
				}
			self.tengaugesawedoff_reloadanimtime = time + frametime + autocvar_g_balance_tengaugesawedoff_reload_time;
		} else {
			self.tengaugesawedoff_reloaddo = 0;
			self.tengaugesawedoff_reloaddo_wait = 0;
			self.tengaugesawedoff_botreload = 1;
			self.tengaugesawedoff_whichshot = 0;
		
			if ((self.clip_load > 0) && (self.clip_load < autocvar_g_balance_tengaugesawedoff_reload_ammo)) {
				//Gate loaded cylinder not empty Less than full reload time needed
				self.tengaugesawedoff_reloadanimtime = time + frametime + (autocvar_g_balance_tengaugesawedoff_reload_time - (autocvar_g_balance_tengaugesawedoff_reload_time * (self.clip_load/autocvar_g_balance_tengaugesawedoff_reload_ammo)));
				W_Reload(autocvar_g_balance_tengaugesawedoff_primary_ammo, autocvar_g_balance_tengaugesawedoff_reload_ammo, autocvar_g_balance_tengaugesawedoff_reload_time - (autocvar_g_balance_tengaugesawedoff_reload_time * (self.clip_load/autocvar_g_balance_tengaugesawedoff_reload_ammo)), "weapons/reload.wav");
			} else {
				//Empty or abnormal, do simple full reload time
				self.tengaugesawedoff_reloadanimtime = time + frametime + autocvar_g_balance_tengaugesawedoff_reload_time;
				W_Reload(autocvar_g_balance_tengaugesawedoff_primary_ammo, autocvar_g_balance_tengaugesawedoff_reload_ammo, autocvar_g_balance_tengaugesawedoff_reload_time, "weapons/reload.wav");
			}
			
			if (autocvar_g_casings >= 2) {
				float sc;
				if (autocvar_g_balance_tengaugesawedoff_casings) {
					for (sc = 0;sc < self.tengaugesawedoff_casings;sc = sc + 1) {
						SpawnCasing_Offset (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 60, self, '0 0 -3');
					}
				}
				self.tengaugesawedoff_casings = 0;
			}
		}
		//self.tengaugesawedoff_release = 0; //Do it yourself
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_tengaugesawedoff(float req)
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
				w_deathtypestring = _("%2$s gave %1$s's chest both 10 gauge barrels");
			else 
				w_deathtypestring = _("%2$s gave %1$s both 10 gauge barrels");
		} else if(w_deathtype & HITTYPE_CORESHOT) {
			w_deathtypestring = _("%1$s was blown away by the hole %2$s put in their chest");
		} else {
			w_deathtypestring = _("%s was ended by a 10 gauge sawed-off shotgun by %s");
		}
	}
	return TRUE;
}
#endif
#endif
