#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CRUDEBOW, w_crudebow, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "crudebow", "crudebow", _("Crude Bow"))
#else
#ifdef SVQC

.float crudebow_release;
.float crudebow_casings;
.float crudebow_onetime;
.float crudebow_twotime;
.float crudebow_threetime; //Half
.float crudebow_fourtime;
.float crudebow_fulltime;
.float crudebow_state;
.float crudebow_pullbackstarted;
.float crudebow_reloaded_time;
.float crudebow_arrowlit;
.float crudebow_arrownextburn;

float autocvar_g_balance_crudebow_forceburningarrow; //If admin wishes to force (no choice for player) the arrows fired to be burning ones, say in night games

.entity crudebowlight;

void crudebow_thinklight() {
	if (self.owner.crudebow_arrowlit == 1 && self.crudebow_arrowlit == 1 && self.owner.health > 0) {
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
		self.crudebow_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void crudebow_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 64;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = crudebow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.crudebow_arrowlit = 1;
	self.crudebowlight = newtorchlight;
}

void W_CrudeBowBolt_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_CRUDEBOW;
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
	float speedmulti = crossbolt.owner.crudebow_state / 5;
	if (crossbolt.owner.crudebow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your crudebow suffered a partial dryfire\n");
		}
	} else {
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crudebow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}
	

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 4; //Arrow Model

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_ARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_CrudeBowBolt_Burning_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_CRUDEBOW;
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
	float speedmulti = crossbolt.owner.crudebow_state / 5;
	if (crossbolt.owner.crudebow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your crudebow suffered a partial dryfire\n");
		}
	} else {
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crudebow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 5; //Burning bolt, same model as regular crossbow, will check to see if shall burn in vicinity tho

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BURNINGARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_CrudeBow_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_crudebow_secondary_animtime, w_ready);
}

float W_CrudeBow_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_crudebow_reload_ammo && self.clip_load < autocvar_g_balance_crudebow_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_crudebow (void)
{
	weapon_defaultspawnfunc(WEP_CRUDEBOW);
}


.float crudebow_primarytime;

float w_crudebow(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_CrudeBow_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.crudebow_pullbackstarted) {
			//In the middle of double action attack, keep the trigger pressed unless ready
			if (self.crudebow_state == 5) {
				if(bot_aim(autocvar_g_balance_crudebow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE)) {
					self.BUTTON_ATCK = FALSE; //Aim is good? Release arrow
				} else {
					self.BUTTON_ATCK = TRUE; //Hold it till aim is good
				}
			} else {
				self.BUTTON_ATCK = TRUE;
			}
		} else {
			if(bot_aim(autocvar_g_balance_crudebow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE))
			{
				self.BUTTON_ATCK = TRUE; //We see someone? Draw bowstring back
			}
		}
	}
	else if (req == WR_THINK && !W_CrudeBow_NeedManualReload())
	{
		if(autocvar_g_balance_crudebow_reload_ammo && self.clip_load < autocvar_g_balance_crudebow_primary_ammo) // forced reload
		{
			// don't force reload an empty crudebow if its melee attack is active
			if not(autocvar_g_balance_crudebow_secondary && self.ammo_nails < autocvar_g_balance_crudebow_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.crudebow_release = 0;
		}
		else
		{
			if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2 && !self.crudebow_pullbackstarted)
			{
				//No touching and haven't started to pull back
				 self.crudebow_release = 1;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			!self.crudebow_pullbackstarted && self.crudebow_release) {
				//print("pullback\n");
				self.crudebow_pullbackstarted = 1;
				//Begin pull back
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				//weapon_thinkf(WFRAME_FIRE1, 0, W_CrudeBow_Attack2);
				self.crudebow_onetime = time + (autocvar_g_balance_crudebow_cocking_time * 0.1);
				self.crudebow_twotime = time + (autocvar_g_balance_crudebow_cocking_time * 0.25);
				self.crudebow_threetime = time + (autocvar_g_balance_crudebow_cocking_time * 0.5);
				self.crudebow_fourtime = time + (autocvar_g_balance_crudebow_cocking_time * 0.75);
				self.crudebow_fulltime = time + autocvar_g_balance_crudebow_cocking_time;
				self.crudebow_state = 0;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			self.crudebow_pullbackstarted) {
				//The action.
				if (self.crudebow_state < 1) {
					if (time > (self.crudebow_onetime)) {
						//print("1\n");
						self.crudebow_state = 1;
						//self.weaponname = "crudebow";
						PlayerGunRise(self, autocvar_g_balance_crudebow_cockingrise, random() * autocvar_g_balance_crudebow_cockingrun);
					}
				} else if (self.crudebow_state < 2) {
					if (time > (self.crudebow_twotime)) {
						//print("2\n");
						self.crudebow_state = 2;
						self.weaponname = "crudebow_2";
						PlayerGunRise(self, autocvar_g_balance_crudebow_cockingrise, random() * autocvar_g_balance_crudebow_cockingrun);
					}
				} else if (self.crudebow_state < 3) {
					if (time > (self.crudebow_threetime)) {
						//print("3\n");
						self.crudebow_state = 3;
						self.weaponname = "crudebow_3";
						PlayerGunRise(self, autocvar_g_balance_crudebow_cockingrise, random() * autocvar_g_balance_crudebow_cockingrun);
					}
				} else if (self.crudebow_state < 4) {
					if (time > (self.crudebow_fourtime)) {
						//print("4\n");
						self.crudebow_state = 4;
						self.weaponname = "crudebow_4";
						PlayerGunRise(self, autocvar_g_balance_crudebow_cockingrise, random() * autocvar_g_balance_crudebow_cockingrun);
					}
				} else if (self.crudebow_state < 5) {
					if (time > (self.crudebow_fulltime)) {
						//print("5\n");
						self.crudebow_state = 5;
						self.weaponname = "crudebow_5";
						PlayerGunRise(self, autocvar_g_balance_crudebow_cockingrise, random() * autocvar_g_balance_crudebow_cockingrun);
					}
				}
			} else if (
			(!self.BUTTON_ATCK && !self.BUTTON_ATCK2) &&
			self.crudebow_pullbackstarted) {
				//The release
				self.weaponname = "crudebow_empty";
				if (weapon_prepareattack(0, autocvar_g_balance_crudebow_primary_refire))
				{
					if (self.crudebow_arrowlit == 1 || autocvar_g_balance_crudebow_forceburningarrow == 1)
					{
						//Admin forced on all
						W_CrudeBowBolt_Burning_Attack();
					} else {
						//Normal
						W_CrudeBowBolt_Attack();
					}
					ATTACK_FINISHED(self) = time + autocvar_g_balance_crudebow_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_crudebow_primary_animtime, w_ready);
				}
				self.crudebow_state = 0;
				self.crudebow_release = 1; //Slide needs to be wracked
				self.crudebow_pullbackstarted = 0;
				self.crudebow_arrowlit = 0;
			}
			
			//"Animation"
			if ((self.crudebow_reloaded_time) && 
			(self.crudebow_reloaded_time < time))
			{
				if (self.crudebow_state == 5) {
					self.weaponname = "crudebow_5";
				} else if (self.crudebow_state == 4) {
					self.weaponname = "crudebow_4";
				} else if (self.crudebow_state == 3) {
					self.weaponname = "crudebow_3";
				} else if (self.crudebow_state == 2) {
					self.weaponname = "crudebow_2";
				} else {
					self.weaponname = "crudebow";
				}
				self.crudebow_reloaded_time = 0;
			}
			
			if (self.crudebow_arrowlit == 1) {
				if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
					pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
					spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
					self.crudebow_arrowlit = 0;
				
				} else if (time > self.crudebow_arrownextburn) {
					W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
					self.crudebow_arrownextburn = time + 0.2;
					self.crudebowlight.crudebow_arrowlit = 1;
				} else {
					self.crudebowlight.crudebow_arrowlit = 1;
				}
			}
			//print(ftos(self.clip_load), " clipload\n");
		}		
	}
	else if (req == WR_THINK)
	{
		//Just think, so means we're not loaded.
		if (!self.crudebow_reloaded_time && self.clip_load < 1) {
			if(self.weaponname == "crudebow") {
				self.weaponname = "crudebow_empty";
				//print("switched\n");
			}
		}
			
		//print(ftos(self.clip_load), "switched clipload\n");
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_crudebow.md3");
		precache_model ("models/weapons/v_crudebow.md3");
		precache_model ("models/weapons/h_crudebow.iqm");
		precache_model ("models/weapons/v_crudebow_empty.md3");
		precache_model ("models/weapons/h_crudebow_empty.iqm");
		precache_model ("models/weapons/v_crudebow_2.md3");
		precache_model ("models/weapons/h_crudebow_2.iqm");
		precache_model ("models/weapons/v_crudebow_3.md3");
		precache_model ("models/weapons/h_crudebow_3.iqm");
		precache_model ("models/weapons/v_crudebow_4.md3");
		precache_model ("models/weapons/h_crudebow_4.iqm");
		precache_model ("models/weapons/v_crudebow_5.md3");
		precache_model ("models/weapons/h_crudebow_5.iqm");
		precache_model ("models/arrowbodkin.iqm");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		W_crossbowdtwr_precache_arrowsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CRUDEBOW);
		self.current_ammo = ammo_nails;
		if not(autocvar_g_balance_bowsstaylit) {
			self.crudebow_arrowlit = 0;
		}
		
		if (self.crudebow_arrowlit) {
			crudebow_spawnlight();
		}
		
		//if (!self.crudebow_reloaded_time && self.clip_load && self.weaponname == "crudebow_empty") {
		//	self.weaponname = "crudebow";
		//}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.crudebow_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_crudebow_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_CRUDEBOW]) >= autocvar_g_balance_crudebow_primary_ammo;
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
		self.crudebow_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_crudebow_primary_ammo, autocvar_g_balance_crudebow_reload_ammo, autocvar_g_balance_crudebow_reload_time, "");
		self.crudebow_reloaded_time = time + autocvar_g_balance_crudebow_reload_time;
		
		if (self.BUTTON_USE && !self.crudebow_arrowlit) {
			if (W_CrossbowCanLightBoltEx(self, 78)) {
				self.crudebow_arrowlit = 1;
				crudebow_spawnlight();
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_crudebow(float req)
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
			w_deathtypestring = _("%s wasn't aware of their own arrow");
		else
			w_deathtypestring = _("%s killed themself with their own arrow");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s was unaware of %s's arrow");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s almost avoided %s's arrow");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s consumed %s's arrow");
	}
	return TRUE;
}
#endif
#endif
