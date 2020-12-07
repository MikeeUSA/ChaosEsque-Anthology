#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LIGHTCROSSBOW, w_lightcrossbow, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "lightcrossbow", "lightcrossbow", _("Light Crossbow"))
#else
#ifdef SVQC

.float lightcrossbow_release;
.float lightcrossbow_reloaded_time;
.float lightcrossbow_arrowlit;
.float lightcrossbow_arrownextburn;

float autocvar_g_balance_lightcrossbow_forceburningbolt; //If admin wishes to force (no choice for player) the arrows fired to be burning ones, say in night games

.entity lightcrossbowlight;

void lightcrossbow_thinklight() {
	if (self.owner.lightcrossbow_arrowlit == 1 && self.lightcrossbow_arrowlit == 1 && self.owner.health > 0) {
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
		self.lightcrossbow_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void lightcrossbow_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 64;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = lightcrossbow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.lightcrossbow_arrowlit = 1;
	self.lightcrossbowlight = newtorchlight;
}

void W_LightCrossbowBolt_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_LIGHTCROSSBOW;
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
	
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your lightcrossbow suffered a partial dryfire\n");
		}
	} else {
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_lightcrossbow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}
	

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_CROSSBOWBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_LightCrossbowBolt_Burning_Attack (void)
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
	crossbolt.projectiledeathtype = WEP_LIGHTCROSSBOW;
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
	
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, FALSE);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your lightcrossbow suffered a partial dryfire\n");
		}
	} else {
		//W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
		W_SetupProjectileVelocityEx(crossbolt, w_shotdir, v_up, autocvar_g_balance_lightcrossbow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, autocvar_g_balance_crossbowdtwr_primary_spread, FALSE);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.amnt = 3; //Burning bolt, same model as regular crossbow, will check to see if shall burn in vicinity tho

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BURNINGBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_LightCrossbow_Attack2 (void)
{
	weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_lightcrossbow_secondary_animtime, w_ready);
}

float W_LightCrossbow_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_lightcrossbow_reload_ammo && self.clip_load < autocvar_g_balance_lightcrossbow_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_lightcrossbow (void)
{
	weapon_defaultspawnfunc(WEP_LIGHTCROSSBOW);
}


.float lightcrossbow_primarytime;

float w_lightcrossbow(float req)
{
	float ammo_amount;
	
	if (req == WR_AIM)
	{
		if (W_LightCrossbow_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
			if((bot_aim(autocvar_g_balance_lightcrossbow_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE)) && (self.lightcrossbow_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
	}
	else if (req == WR_THINK)
	{
		if (!W_LightCrossbow_NeedManualReload()) {
			if(autocvar_g_balance_lightcrossbow_reload_ammo && self.clip_load < autocvar_g_balance_lightcrossbow_primary_ammo) // forced reload
				weapon_action(self.weapon, WR_RELOAD);
			else if (self.BUTTON_ATCK && self.lightcrossbow_release)
			{
				if (weapon_prepareattack(0, autocvar_g_balance_lightcrossbow_primary_refire))
				{
					if (self.lightcrossbow_arrowlit == 1 || autocvar_g_balance_lightcrossbow_forceburningbolt == 1)
					{
						//If admin wants to force on all (no choice for player)
						//Or if lit by player F+R near fire
						W_LightCrossbowBolt_Burning_Attack();
					} else {
						//Normal
						W_LightCrossbowBolt_Attack();
					}
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightcrossbow_primary_animtime, w_ready);
					self.lightcrossbow_release = 0;
					
					self.lightcrossbow_arrowlit = 0;
					
					self.weaponname = "lightcrossbow-uncocked";
				}
			}
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.lightcrossbow_release = 1;
			}
		} else {
			self.weaponname = "lightcrossbow-uncocked";	
		}
		
		//"Animation"
		if ((self.lightcrossbow_reloaded_time) && 
		(self.lightcrossbow_reloaded_time < time))
		{
			self.weaponname = "lightcrossbow";

			self.lightcrossbow_reloaded_time = 0;
		}
		
		if (self.lightcrossbow_arrowlit == 1) {
			if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
				pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
				spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
				self.lightcrossbow_arrowlit = 0;
				
			} else if (time > self.lightcrossbow_arrownextburn) {
				W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
				self.lightcrossbow_arrownextburn = time + 0.2;
				self.lightcrossbowlight.lightcrossbow_arrowlit = 1;
			} else {
				self.lightcrossbowlight.lightcrossbow_arrowlit = 1;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_lightcrossbow.md3");
		precache_model ("models/weapons/v_lightcrossbow.md3");
		precache_model ("models/weapons/h_lightcrossbow.iqm");
		precache_model ("models/weapons/g_lightcrossbow-uncocked.md3");
		precache_model ("models/weapons/v_lightcrossbow-uncocked.md3");
		precache_model ("models/weapons/h_lightcrossbow-uncocked.iqm");
		precache_model ("models/crossbowbolt.md3");
		precache_sound("weapons/campingrifle_boltclick.wav");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		W_crossbowdtwr_precache_arrowsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LIGHTCROSSBOW);
		self.current_ammo = ammo_nails;
		if not(autocvar_g_balance_bowsstaylit) {
			self.lightcrossbow_arrowlit = 0;
		}
		
		if (self.lightcrossbow_arrowlit) {
			lightcrossbow_spawnlight();
		}
		
		//if (!self.lightcrossbow_reloaded_time && self.clip_load && self.weaponname == "lightcrossbow_empty") {
		//	self.weaponname = "lightcrossbow";
		//}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.lightcrossbow_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_lightcrossbow_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_LIGHTCROSSBOW]) >= autocvar_g_balance_lightcrossbow_primary_ammo;
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
		self.lightcrossbow_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We lost dropped the weapon
		//print("Drop\n");
		self.lightcrossbow_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_lightcrossbow_primary_ammo, autocvar_g_balance_lightcrossbow_reload_ammo, autocvar_g_balance_lightcrossbow_reload_time, "weapons/campingrifle_boltclick.wav");
		self.lightcrossbow_reloaded_time = time + autocvar_g_balance_lightcrossbow_reload_time;
		
		if (self.BUTTON_USE && !self.lightcrossbow_arrowlit) {
			if (W_CrossbowCanLightBoltEx(self, 78)) {
				self.lightcrossbow_arrowlit = 1;
				lightcrossbow_spawnlight();
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_lightcrossbow(float req)
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
				w_deathtypestring = _("%s was unaware of %s's crossbow bolt");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s almost avoided %s's crossbow bolt");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s consumed %s's crossbow bolt");
	}
	return TRUE;
}
#endif
#endif
