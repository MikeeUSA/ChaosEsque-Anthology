#ifdef REGISTER_WEAPON
REGISTER_WEAPON(YUMIBOW, w_yumibow, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "yumibow", "yumibow", _("Yumi"))
#else
#ifdef SVQC

.float yumibow_release;
.float yumibow_casings;
.float yumibow_onetime;
.float yumibow_twotime;
.float yumibow_threetime; //Half
.float yumibow_fourtime;
.float yumibow_fulltime;
.float yumibow_state;
.float yumibow_pullbackstarted;
.float yumibow_reloaded_time;
.float yumibow_arrowlit;
.float yumibow_arrownextburn;

float autocvar_g_balance_yumibow_forceburningarrow; //If admin wishes to force (no choice for player) the arrows fired to be burning ones, say in night games

.entity yumibowlight;

void yumibow_thinklight() {
	if (self.owner.yumibow_arrowlit == 1 && self.yumibow_arrowlit == 1 && self.owner.health > 0) {
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
		self.yumibow_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void yumibow_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 64;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = yumibow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.yumibow_arrowlit = 1;
	self.yumibowlight = newtorchlight;
}

void W_YumiBowBolt_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_YUMIBOW;
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
	float speedmulti = crossbolt.owner.yumibow_state / 5;
	if (crossbolt.owner.yumibow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your yumibow suffered a partial dryfire\n");
		}
	} else {
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_yumibow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}
	

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 4; //Arrow Model

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_ARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_YumiBowBolt_Burning_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_YUMIBOW;
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
	float speedmulti = crossbolt.owner.yumibow_state / 5;
	if (crossbolt.owner.yumibow_state < 1) speedmulti = 0.01;
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your yumibow suffered a partial dryfire\n");
		}
	} else {
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_yumibow_primary_speed * speedmulti, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage * speedmulti;
	crossbolt.amnt = 5; //Burning bolt, same model as regular crossbow, will check to see if shall burn in vicinity tho

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BURNINGARROW, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_YumiBow_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_yumibow_secondary_animtime, w_ready);
}

float W_YumiBow_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_yumibow_reload_ammo && self.clip_load < autocvar_g_balance_yumibow_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_yumibow (void)
{
	weapon_defaultspawnfunc(WEP_YUMIBOW);
}


.float yumibow_primarytime;

float w_yumibow(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_YumiBow_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.yumibow_pullbackstarted) {
			//In the middle of double action attack, keep the trigger pressed unless ready
			if (self.yumibow_state == 5) {
				if(bot_aim(autocvar_g_balance_yumibow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE)) {
					self.BUTTON_ATCK = FALSE; //Aim is good? Release arrow
				} else {
					self.BUTTON_ATCK = TRUE; //Hold it till aim is good
				}
			} else {
				self.BUTTON_ATCK = TRUE;
			}
		} else {
			if(bot_aim(autocvar_g_balance_yumibow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE))
			{
				self.BUTTON_ATCK = TRUE; //We see someone? Draw bowstring back
			}
		}
	}
	else if (req == WR_THINK && !W_YumiBow_NeedManualReload())
	{
		if(autocvar_g_balance_yumibow_reload_ammo && self.clip_load < autocvar_g_balance_yumibow_primary_ammo) // forced reload
		{
			// don't force reload an empty yumibow if its melee attack is active
			if not(autocvar_g_balance_yumibow_secondary && self.ammo_nails < autocvar_g_balance_yumibow_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				self.yumibow_release = 0;
		}
		else
		{
			if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2 && !self.yumibow_pullbackstarted)
			{
				//No touching and haven't started to pull back
				 self.yumibow_release = 1;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			!self.yumibow_pullbackstarted && self.yumibow_release) {
				//print("pullback\n");
				self.yumibow_pullbackstarted = 1;
				//Begin pull back
				// attempt forcing playback of the anim by switching to another anim (that we never play) here...
				//weapon_thinkf(WFRAME_FIRE1, 0, W_YumiBow_Attack2);
				self.yumibow_onetime = time + (autocvar_g_balance_yumibow_cocking_time * 0.1);
				self.yumibow_twotime = time + (autocvar_g_balance_yumibow_cocking_time * 0.25);
				self.yumibow_threetime = time + (autocvar_g_balance_yumibow_cocking_time * 0.5);
				self.yumibow_fourtime = time + (autocvar_g_balance_yumibow_cocking_time * 0.75);
				self.yumibow_fulltime = time + autocvar_g_balance_yumibow_cocking_time;
				self.yumibow_state = 0;
			} else if ((self.BUTTON_ATCK || self.BUTTON_ATCK2) &&
			self.yumibow_pullbackstarted) {
				//The action.
				if (self.yumibow_state < 1) {
					if (time > (self.yumibow_onetime)) {
						//print("1\n");
						self.yumibow_state = 1;
						//self.weaponname = "yumibow";
						PlayerGunRise(self, autocvar_g_balance_yumibow_cockingrise, random() * autocvar_g_balance_yumibow_cockingrun);
					}
				} else if (self.yumibow_state < 2) {
					if (time > (self.yumibow_twotime)) {
						//print("2\n");
						self.yumibow_state = 2;
						self.weaponname = "yumibow_2";
						PlayerGunRise(self, autocvar_g_balance_yumibow_cockingrise, random() * autocvar_g_balance_yumibow_cockingrun);
					}
				} else if (self.yumibow_state < 3) {
					if (time > (self.yumibow_threetime)) {
						//print("3\n");
						self.yumibow_state = 3;
						self.weaponname = "yumibow_3";
						PlayerGunRise(self, autocvar_g_balance_yumibow_cockingrise, random() * autocvar_g_balance_yumibow_cockingrun);
					}
				} else if (self.yumibow_state < 4) {
					if (time > (self.yumibow_fourtime)) {
						//print("4\n");
						self.yumibow_state = 4;
						self.weaponname = "yumibow_4";
						PlayerGunRise(self, autocvar_g_balance_yumibow_cockingrise, random() * autocvar_g_balance_yumibow_cockingrun);
					}
				} else if (self.yumibow_state < 5) {
					if (time > (self.yumibow_fulltime)) {
						//print("5\n");
						self.yumibow_state = 5;
						self.weaponname = "yumibow_5";
						PlayerGunRise(self, autocvar_g_balance_yumibow_cockingrise, random() * autocvar_g_balance_yumibow_cockingrun);
					}
				}
			} else if (
			(!self.BUTTON_ATCK && !self.BUTTON_ATCK2) &&
			self.yumibow_pullbackstarted) {
				//The release
				self.weaponname = "yumibow_empty";
				if (weapon_prepareattack(0, autocvar_g_balance_yumibow_primary_refire))
				{
					if (self.yumibow_arrowlit == 1 || autocvar_g_balance_yumibow_forceburningarrow == 1)
					{
						//Admin forced on all
						W_YumiBowBolt_Burning_Attack();
					} else {
						//Normal
						W_YumiBowBolt_Attack();
					}
					ATTACK_FINISHED(self) = time + autocvar_g_balance_yumibow_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_yumibow_primary_animtime, w_ready);
				}
				self.yumibow_state = 0;
				self.yumibow_release = 1; //Slide needs to be wracked
				self.yumibow_pullbackstarted = 0;
				self.yumibow_arrowlit = 0;
			}
			
			//"Animation"
			if ((self.yumibow_reloaded_time) && 
			(self.yumibow_reloaded_time < time))
			{
				if (self.yumibow_state == 5) {
					self.weaponname = "yumibow_5";
				} else if (self.yumibow_state == 4) {
					self.weaponname = "yumibow_4";
				} else if (self.yumibow_state == 3) {
					self.weaponname = "yumibow_3";
				} else if (self.yumibow_state == 2) {
					self.weaponname = "yumibow_2";
				} else {
					self.weaponname = "yumibow";
				}
				self.yumibow_reloaded_time = 0;
			}
			
			if (self.yumibow_arrowlit == 1) {
				if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
					pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
					spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
					self.yumibow_arrowlit = 0;
				
				} else if (time > self.yumibow_arrownextburn) {
					W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
					self.yumibow_arrownextburn = time + 0.2;
					self.yumibowlight.yumibow_arrowlit = 1;
				} else {
					self.yumibowlight.yumibow_arrowlit = 1;
				}
			}
			//print(ftos(self.clip_load), " clipload\n");
		}		
	}
	else if (req == WR_THINK)
	{
		//Just think, so means we're not loaded.
		if (!self.yumibow_reloaded_time && self.clip_load < 1) {
			if(self.weaponname == "yumibow") {
				self.weaponname = "yumibow_empty";
				//print("switched\n");
			}
		}
			
		//print(ftos(self.clip_load), "switched clipload\n");
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_yumibow.md3");
		precache_model ("models/weapons/v_yumibow.md3");
		precache_model ("models/weapons/h_yumibow.iqm");
		precache_model ("models/weapons/v_yumibow_empty.md3");
		precache_model ("models/weapons/h_yumibow_empty.iqm");
		precache_model ("models/weapons/v_yumibow_2.md3");
		precache_model ("models/weapons/h_yumibow_2.iqm");
		precache_model ("models/weapons/v_yumibow_3.md3");
		precache_model ("models/weapons/h_yumibow_3.iqm");
		precache_model ("models/weapons/v_yumibow_4.md3");
		precache_model ("models/weapons/h_yumibow_4.iqm");
		precache_model ("models/weapons/v_yumibow_5.md3");
		precache_model ("models/weapons/h_yumibow_5.iqm");
		precache_model ("models/arrowbodkin.iqm");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		W_crossbowdtwr_precache_arrowsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_YUMIBOW);
		self.current_ammo = ammo_nails;
		if not(autocvar_g_balance_bowsstaylit) {
			self.yumibow_arrowlit = 0;
		}
		
		if (self.yumibow_arrowlit) {
			yumibow_spawnlight();
		}
		
		//if (!self.yumibow_reloaded_time && self.clip_load && self.weaponname == "yumibow_empty") {
		//	self.weaponname = "yumibow";
		//}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.yumibow_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_yumibow_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_YUMIBOW]) >= autocvar_g_balance_yumibow_primary_ammo;
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
		self.yumibow_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We lost dropped the weapon
		self.yumibow_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_yumibow_primary_ammo, autocvar_g_balance_yumibow_reload_ammo, autocvar_g_balance_yumibow_reload_time, "");
		self.yumibow_reloaded_time = time + autocvar_g_balance_yumibow_reload_time;
		
		if (self.BUTTON_USE && !self.yumibow_arrowlit) {
			if (W_CrossbowCanLightBoltEx(self, 78)) {
				self.yumibow_arrowlit = 1;
				yumibow_spawnlight();
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_yumibow(float req)
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
			w_deathtypestring = _("%s killed themself with their own arrow");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s didn't see %s's arrow");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s nearly dodged %s's arrow");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s was struk by %s's arrow");
	}
	return TRUE;
}
#endif
#endif
