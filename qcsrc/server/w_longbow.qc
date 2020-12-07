#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LONGBOW, w_longbow, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "longbow", "longbow", _("Longbow"))
#else
#ifdef SVQC

.float longbow_release;
.float longbow_casings;
.float longbow_onetime;
.float longbow_twotime;
.float longbow_threetime; //Half
.float longbow_fourtime;
.float longbow_fulltime;
.float longbow_state;
.float longbow_pullbackstarted;
.float longbow_reloaded_time;
.float longbow_arrowlit;
.float longbow_arrownextburn;

float autocvar_g_balance_longbow_forceburningarrow; //If admin wishes to force (no choice for player) the arrows fired to be burning ones, say in night games

.entity longbowlight;

void longbow_thinklight() {
	if (self.owner.longbow_arrowlit == 1 && self.longbow_arrowlit == 1 && self.owner.health > 0) {
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *48)+(v_up *2));
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up		
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		    vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *2));
		    if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *2));
		    	if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *2));
		    	}
		    }
		}
		setorigin(self, vlporigin);
		self.nextthink = time;
		self.longbow_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void longbow_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 64;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = longbow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.longbow_arrowlit = 1;
	self.longbowlight = newtorchlight;
}

void W_LongBowBolt_Attack (void)
{
	entity crossbolt;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_LONGBOW;
	setorigin(crossbolt, w_shotorg);
	setsize(crossbolt, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');

	crossbolt.cnt = time + autocvar_g_balance_crossbowdtwr_primary_lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	
	//To see how far along the draw we are
	float speedmulti = crossbolt.owner.longbow_state / 5;
	if (crossbolt.owner.longbow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your longbow suffered a partial dryfire\n");
		}
	} else {
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_longbow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}
	

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 4; //Arrow Model

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_ARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_LongBowBolt_Burning_Attack (void)
{
	entity crossbolt;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_LONGBOW;
	setorigin(crossbolt, w_shotorg);
	setsize(crossbolt, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');

	crossbolt.cnt = time + autocvar_g_balance_crossbowdtwr_primary_lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	
	//To see how far along the draw we are
	float speedmulti = crossbolt.owner.longbow_state / 5;
	if (crossbolt.owner.longbow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your longbow suffered a partial dryfire\n");
		}
	} else {
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_longbow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 5; //Burning bolt, same model as regular crossbow, will check to see if shall burn in vicinity tho

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BURNINGARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_LongBow_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_longbow_secondary_animtime, w_ready);
}

float W_LongBow_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_longbow_reload_ammo && self.clip_load < autocvar_g_balance_longbow_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_longbow (void)
{
	weapon_defaultspawnfunc(WEP_LONGBOW);
}


.float longbow_primarytime;

float w_longbow(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_LongBow_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.longbow_pullbackstarted) {
			//In the middle of double action attack, keep the trigger pressed unless ready
			if (self.longbow_state == 5) {
				if(bot_aim(autocvar_g_balance_longbow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE)) {
					self.BUTTON_ATCK = FALSE; //Aim is good? Release arrow
				} else {
					self.BUTTON_ATCK = TRUE; //Hold it till aim is good
				}
			} else {
				self.BUTTON_ATCK = TRUE;
			}
		} else {
			if(bot_aim(autocvar_g_balance_longbow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE))
			{
				self.BUTTON_ATCK = TRUE; //We see someone? Draw bowstring back
			}
		}
	}
	else if (req == WR_THINK && !W_LongBow_NeedManualReload())
	{
		if(autocvar_g_balance_longbow_reload_ammo && self.clip_load < autocvar_g_balance_longbow_primary_ammo) // forced reload
		{
			// don't force reload an empty longbow if its melee attack is active
			if not(autocvar_g_balance_longbow_secondary && self.ammo_nails < autocvar_g_balance_longbow_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.longbow_release = 0;
		}
		else
		{
			if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2 && !self.longbow_pullbackstarted)
			{
				//No touching and haven't started to pull back
				 self.longbow_release = 1;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			!self.longbow_pullbackstarted && self.longbow_release) {
				//print("pullback\n");
				self.longbow_pullbackstarted = 1;
				//Begin pull back
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				//weapon_thinkf(WFRAME_FIRE1, 0, W_LongBow_Attack2);
				self.longbow_onetime = time + (autocvar_g_balance_longbow_cocking_time * 0.1);
				self.longbow_twotime = time + (autocvar_g_balance_longbow_cocking_time * 0.25);
				self.longbow_threetime = time + (autocvar_g_balance_longbow_cocking_time * 0.5);
				self.longbow_fourtime = time + (autocvar_g_balance_longbow_cocking_time * 0.75);
				self.longbow_fulltime = time + autocvar_g_balance_longbow_cocking_time;
				self.longbow_state = 0;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			self.longbow_pullbackstarted) {
				//The action.
				if (self.longbow_state < 1) {
					if (time > (self.longbow_onetime)) {
						//print("1\n");
						self.longbow_state = 1;
						//self.weaponname = "longbow";
						PlayerGunRise(self, autocvar_g_balance_longbow_cockingrise, random() * autocvar_g_balance_longbow_cockingrun);
					}
				} else if (self.longbow_state < 2) {
					if (time > (self.longbow_twotime)) {
						//print("2\n");
						self.longbow_state = 2;
						self.weaponname = "longbow_2";
						PlayerGunRise(self, autocvar_g_balance_longbow_cockingrise, random() * autocvar_g_balance_longbow_cockingrun);
					}
				} else if (self.longbow_state < 3) {
					if (time > (self.longbow_threetime)) {
						//print("3\n");
						self.longbow_state = 3;
						self.weaponname = "longbow_3";
						PlayerGunRise(self, autocvar_g_balance_longbow_cockingrise, random() * autocvar_g_balance_longbow_cockingrun);
					}
				} else if (self.longbow_state < 4) {
					if (time > (self.longbow_fourtime)) {
						//print("4\n");
						self.longbow_state = 4;
						self.weaponname = "longbow_4";
						PlayerGunRise(self, autocvar_g_balance_longbow_cockingrise, random() * autocvar_g_balance_longbow_cockingrun);
					}
				} else if (self.longbow_state < 5) {
					if (time > (self.longbow_fulltime)) {
						//print("5\n");
						self.longbow_state = 5;
						self.weaponname = "longbow_5";
						PlayerGunRise(self, autocvar_g_balance_longbow_cockingrise, random() * autocvar_g_balance_longbow_cockingrun);
					}
				}
			} else if (
			(!self.BUTTON_ATCK && !self.BUTTON_ATCK2) &&
			self.longbow_pullbackstarted) {
				//The release
				self.weaponname = "longbow_empty";
				if (weapon_prepareattack(0, autocvar_g_balance_longbow_primary_refire))
				{
					if (self.longbow_arrowlit == 1 || autocvar_g_balance_longbow_forceburningarrow == 1)
					{
						//Admin forced on all
						W_LongBowBolt_Burning_Attack();
					} else {
						//Normal
						W_LongBowBolt_Attack();
					}
					ATTACK_FINISHED(self) = time + autocvar_g_balance_longbow_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_longbow_primary_animtime, w_ready);
				}
				self.longbow_state = 0;
				self.longbow_release = 1; //Slide needs to be wracked
				self.longbow_pullbackstarted = 0;
				self.longbow_arrowlit = 0;
			}
			
			//"Animation"
			if ((self.longbow_reloaded_time) && 
			(self.longbow_reloaded_time < time))
			{
				if (self.longbow_state == 5) {
					self.weaponname = "longbow_5";
				} else if (self.longbow_state == 4) {
					self.weaponname = "longbow_4";
				} else if (self.longbow_state == 3) {
					self.weaponname = "longbow_3";
				} else if (self.longbow_state == 2) {
					self.weaponname = "longbow_2";
				} else {
					self.weaponname = "longbow";
				}
				self.longbow_reloaded_time = 0;
			}
			
			if (self.longbow_arrowlit == 1) {
				if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
					pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
					spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
					self.longbow_arrowlit = 0;
				
				} else if (time > self.longbow_arrownextburn) {
					W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
					self.longbow_arrownextburn = time + 0.2;
					self.longbowlight.longbow_arrowlit = 1;
				} else {
					self.longbowlight.longbow_arrowlit = 1;
				}
			}
			//print(ftos(self.clip_load), " clipload\n");
		}		
	}
	else if (req == WR_THINK)
	{
		//Just think, so means we're not loaded.
		if (!self.longbow_reloaded_time && self.clip_load < 1) {
			if(self.weaponname == "longbow") {
				self.weaponname = "longbow_empty";
				//print("switched\n");
			}
		}
			
		//print(ftos(self.clip_load), "switched clipload\n");
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_longbow.md3");
		precache_model ("models/weapons/v_longbow.md3");
		precache_model ("models/weapons/h_longbow.iqm");
		precache_model ("models/weapons/v_longbow_empty.md3");
		precache_model ("models/weapons/h_longbow_empty.iqm");
		precache_model ("models/weapons/v_longbow_2.md3");
		precache_model ("models/weapons/h_longbow_2.iqm");
		precache_model ("models/weapons/v_longbow_3.md3");
		precache_model ("models/weapons/h_longbow_3.iqm");
		precache_model ("models/weapons/v_longbow_4.md3");
		precache_model ("models/weapons/h_longbow_4.iqm");
		precache_model ("models/weapons/v_longbow_5.md3");
		precache_model ("models/weapons/h_longbow_5.iqm");
		precache_model ("models/arrowbodkin.iqm");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		W_crossbowdtwr_precache_arrowsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LONGBOW);
		self.current_ammo = ammo_nails;
		if not(autocvar_g_balance_bowsstaylit) {
			self.longbow_arrowlit = 0;
		}
		
		if (self.longbow_arrowlit) {
			longbow_spawnlight();
		}
		
		//if (!self.longbow_reloaded_time && self.clip_load && self.weaponname == "longbow_empty") {
		//	self.weaponname = "longbow";
		//}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.longbow_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_longbow_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LONGBOW]) >= autocvar_g_balance_longbow_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_GONETHINK)
	{
		//We lost the weapon
		self.longbow_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We lost dropped the weapon
		self.longbow_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_longbow_primary_ammo, autocvar_g_balance_longbow_reload_ammo, autocvar_g_balance_longbow_reload_time, "");
		self.longbow_reloaded_time = time + autocvar_g_balance_longbow_reload_time;
		
		if (self.BUTTON_USE && !self.longbow_arrowlit) {
			if (W_CrossbowCanLightBoltEx(self, 78)) {
				self.longbow_arrowlit = 1;
				longbow_spawnlight();
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_longbow(float req)
{
	//if(req == WR_IMPACTEFFECT)
	//{
	//	vector org2;
	//	org2 = w_org + w_backoff * 2;
	//	pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
	//	if(!w_issilent && time - self.prevric > 0.25)
	//	{
	//		if(w_random < 0.0165)
	//			sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
	//		else if(w_random < 0.033)
	//			sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
	//		else if(w_random < 0.05)
	//			sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
	//		self.prevric = time;
	//	}
	//}
	//else if(req == WR_PRECACHE)
	//{
	//	precache_sound("weapons/ric1.wav");
	//	precache_sound("weapons/ric2.wav");
	//	precache_sound("weapons/ric3.wav");
	//}
	if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see their own arrow");
		else
			w_deathtypestring = _("%s killed themself good with their arrow");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s didn't see %s's arrow");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s almost dodged %s's arrow");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s ate %s's arrow");
	}
	return TRUE;
}
#endif
#endif
