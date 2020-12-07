#ifdef REGISTER_WEAPON
REGISTER_WEAPON(DEVASTATOR, w_devastator, IT_ROCKETS, 9, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_HIGH, "devastator", "devastator", _("Devastator"))
#else
#ifdef SVQC
.float devastator_release;
.float devastator_detonate_later;
.float devastator_faillaunch;
float autocvar_g_balance_devastator_enableshockwave;

void W_Devastator_Unregister()
{
	if(self.realowner && self.realowner.lastrocket == self)
	{
		self.realowner.lastrocket = world;
		// self.realowner.devastator_release = 1;
	}
}

void W_Devastator_Explode ()
{
	W_Devastator_Unregister();

	if(autocvar_g_balance_devastator_primary_failurerate &&
 	(autocvar_g_balance_devastator_primary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your rocket was a dud\n");
		}
	} else {
	
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_devastator_damage, autocvar_g_balance_devastator_edgedamage, autocvar_g_balance_devastator_radius, world, autocvar_g_balance_devastator_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	

	//Start Explosion Shockwave and fireball
	if (autocvar_g_balance_devastator_enableshockwave == 1) {
		modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_devastator_radius, 0.95, 0.05, 0.25);
	}
	//End Explosion Shockwave and Fireball
	
	} //End To Dud or not to dud.
	
	
	if (self.realowner.weapon == WEP_DEVASTATOR)
	{
		//print(ftos(self.realowner.clip_load),"\n");
		if (self.realowner.clip_load <= 0) {
			if(self.realowner.ammo_rockets < autocvar_g_balance_devastator_ammo)
			{
				self.realowner.cnt = WEP_DEVASTATOR;
				ATTACK_FINISHED(self.realowner) = time;
				self.realowner.switchweapon = w_getbestweapon(self.realowner);
			}
		}
	}
	
	remove (self);
}

void W_Devastator_DoRemoteExplode ()
{
	W_Devastator_Unregister();
	
	if(autocvar_g_balance_devastator_commlink_failurerate &&
 	(autocvar_g_balance_devastator_commlink_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your rocket experienced a commlink error\n");
		}
	} else {
	
	
	if(autocvar_g_balance_devastator_secondary_failurerate &&
 	(autocvar_g_balance_devastator_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your rocket flew but never died\n");
		}
	} else {

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	////local float handled_as_rocketjump = FALSE;
	local entity myhead = world;
	if(autocvar_g_balance_devastator_remote_jump_radius)
	{
		myhead = WarpZone_FindRadius(
			self.origin,
			autocvar_g_balance_devastator_remote_jump_radius,
			FALSE
		);

		while(myhead)
		{
			if(myhead.takedamage && (myhead == self.realowner))
			{
				if(vlen(self.origin - myhead.WarpZone_findradius_nearest) <= autocvar_g_balance_devastator_remote_jump_radius)
				{
					////// we handled self as a rocketjump :)
					////handled_as_rocketjump = TRUE;

					// modify velocity
					if(autocvar_g_balance_devastator_remote_jump_velocity_z_add)
					{
						myhead.velocity_x *= 0.9;
						myhead.velocity_y *= 0.9;
						myhead.velocity_z = bound(
							autocvar_g_balance_devastator_remote_jump_velocity_z_min,
							myhead.velocity_z + autocvar_g_balance_devastator_remote_jump_velocity_z_add,
							autocvar_g_balance_devastator_remote_jump_velocity_z_max
						);
					}

					// now do the damage
					RadiusDamage(
						self,
						myhead,
						autocvar_g_balance_devastator_remote_jump_damage,
						autocvar_g_balance_devastator_remote_jump_damage,
						autocvar_g_balance_devastator_remote_jump_radius,
						world,
						((autocvar_g_balance_devastator_remote_jump_force) ? (autocvar_g_balance_devastator_remote_jump_force) : 0),
						self.projectiledeathtype | HITTYPE_BOUNCE,
						world
					);
					break;
				}
			}
			myhead = myhead.chain;
		}
	}

	RadiusDamage (self, self.realowner, autocvar_g_balance_devastator_remote_damage, autocvar_g_balance_devastator_remote_edgedamage, autocvar_g_balance_devastator_remote_radius, world, autocvar_g_balance_devastator_remote_force, self.projectiledeathtype | HITTYPE_BOUNCE, world);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	//Start Explosion Shockwave and fireball
	if (autocvar_g_balance_devastator_enableshockwave == 1) {
		modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_devastator_remote_radius, 0.95, 0.05, 0.25);
	}
	//End Explosion Shockwave and Fireball
	
	} //End To Dud or not to dud.

	if (self.realowner.weapon == WEP_DEVASTATOR)
	{
		if(self.realowner.ammo_rockets < autocvar_g_balance_devastator_ammo)
		{
			self.realowner.cnt = WEP_DEVASTATOR;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	remove (self);
	
	} //End Commlink Error
}

void W_Devastator_RemoteExplode()
{
	if(self.realowner.deadflag == DEAD_NO)
	if(self.realowner.lastrocket)
	{
		if((self.spawnshieldtime >= 0)
			? (time >= self.spawnshieldtime) // timer
			: (vlen(NearestPointOnBox(self.realowner, self.origin) - self.origin) > autocvar_g_balance_devastator_remote_radius) // safety device
		)
		{
			W_Devastator_DoRemoteExplode();
		}
	}
}

//rocket_steerto is in rocketlauncher code

void W_Devastator_Think (void)
{
	vector desireddir, olddir, newdir, desiredorigin, goal;
#if 0
	float cosminang, cosmaxang, cosang;
#endif
	float velspeed, f;
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Devastator_Explode ();
		return;
	}

	// accelerate
	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	if (self.devastator_faillaunch) {
		// lauchfailure rocket
		W_Devastator_Unregister();
		
		velspeed = autocvar_g_balance_devastator_launchfailure_speed * g_weaponspeedfactor - (self.velocity * v_forward);
		if (velspeed > 0)
			self.velocity = self.velocity + v_forward * min(autocvar_g_balance_devastator_launchfailure_speedaccel * g_weaponspeedfactor * frametime, velspeed);
	} else {
	// normal rocket
	velspeed = autocvar_g_balance_devastator_speed * g_weaponspeedfactor - (self.velocity * v_forward);
	if (velspeed > 0)
		self.velocity = self.velocity + v_forward * min(autocvar_g_balance_devastator_speedaccel * g_weaponspeedfactor * frametime, velspeed);
	}
	// laser guided, or remote detonation
	if (self.realowner.weapon == WEP_DEVASTATOR)
	{
		if(self == self.realowner.lastrocket)
		if not(self.realowner.devastator_release)
		if not(self.BUTTON_ATCK2)
		if(autocvar_g_balance_devastator_guiderate)
		if(time > self.pushltime)
		if(self.realowner.deadflag == DEAD_NO)
		{
			f = autocvar_g_balance_devastator_guideratedelay;
			if(f)
				f = bound(0, (time - self.pushltime) / f, 1);
			else
				f = 1;

			velspeed = vlen(self.velocity);

			makevectors(self.realowner.v_angle);
			desireddir = WarpZone_RefSys_TransformVelocity(self.realowner, self, v_forward);
			desiredorigin = WarpZone_RefSys_TransformOrigin(self.realowner, self, self.realowner.origin + self.realowner.view_ofs);
			olddir = normalize(self.velocity);

			// now it gets tricky... we want to move like some curve to approximate the target direction
			// but we are limiting the rate at which we can turn!
			goal = desiredorigin + ((self.origin - desiredorigin) * desireddir + autocvar_g_balance_devastator_guidegoal) * desireddir;
			newdir = rocket_steerto(olddir, normalize(goal - self.origin), cos(autocvar_g_balance_devastator_guiderate * f * frametime * DEG2RAD));

			self.velocity = newdir * velspeed;
			self.angles = vectoangles(self.velocity);

			if(!self.count)
			{
				pointparticles(particleeffectnum("rocket_guide"), self.origin, self.velocity, 1);
				// TODO add a better sound here
				sound (self.realowner, CH_WEAPON_B, "weapons/rocket_mode.wav", VOL_BASE, ATTN_NORM);
				self.count = 1;
			}
		}

		if(self.devastator_detonate_later)
			W_Devastator_RemoteExplode();
	}

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void W_Devastator_Touch (void)
{
	if(WarpZone_Projectile_Touch())
	{
		if(wasfreed(self))
			W_Devastator_Unregister();
		return;
	}
	W_Devastator_Unregister();
	W_Devastator_Explode ();
}

void W_Devastator_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
	
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_Devastator_Explode);
}

void W_Devastator_Attack (void)
{
	entity missile;
	entity flash;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_devastator_ammo, autocvar_g_balance_devastator_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_devastator_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
	if(autocvar_g_balance_devastator_detonatedelay >= 0)
		missile.spawnshieldtime = time + autocvar_g_balance_devastator_detonatedelay;
	else
		missile.spawnshieldtime = -1;
	missile.pushltime = time + autocvar_g_balance_devastator_guidedelay;
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_devastator_damage * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = autocvar_g_balance_devastator_damageforcescale;
	missile.health = autocvar_g_balance_devastator_health;
	missile.event_damage = W_Devastator_Damage;
	missile.damagedbycontents = TRUE;


	if(autocvar_g_balance_devastator_launch_failurerate &&
 	(autocvar_g_balance_devastator_launch_failurerate > random() ))
 	{
		//Start Abnormal
		missile.devastator_faillaunch = 1;
		
		missile.movetype = MOVETYPE_BOUNCE;
		PROJECTILE_MAKETRIGGER(missile);
		missile.projectiledeathtype = WEP_DEVASTATOR;
		setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

		setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
		W_SetupProjectileVelocity(missile, autocvar_g_balance_devastator_launchfailure_speedstart, 0);
		
		//End Abnormal
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "A launch failure occured\n");
		}
	} else {
	//Start Normal Missile
	missile.devastator_faillaunch = 0;
	
	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_DEVASTATOR;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_balance_devastator_speedstart, 0);
	
	//End Normal Missile
	}
	
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Devastator_Touch;
	missile.think = W_Devastator_Think;
	missile.nextthink = time;
	missile.cnt = time + autocvar_g_balance_devastator_lifetime;
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, autocvar_g_balance_devastator_guiderate == 0 && autocvar_g_balance_devastator_speedaccel == 0, PROJECTILE_ROCKET, FALSE); // because of fly sound
	
	if not(self.flags & FL_MONSTER)
	{
		// muzzle flash for 1st person view
		flash = spawn ();
		setmodel (flash, "models/flash.md3"); // precision set below
		SUB_SetFade (flash, time, 0.1);
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '5 0 0');
	}

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
	PlayerGunRise(self, autocvar_g_balance_devastator_gunrise, random() * autocvar_g_balance_devastator_gunrun);
}

float W_DevastatorLauncher_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_devastator_reload_ammo && self.clip_load < autocvar_g_balance_devastator_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_devastator (void)
{
	weapon_defaultspawnfunc(WEP_DEVASTATOR);
}

float w_devastator(float req)
{
	entity rock;
	float rockfound;
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_DevastatorLauncher_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		// aim and decide to fire if appropriate
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_devastator_speed, 0, autocvar_g_balance_devastator_lifetime, FALSE);
		if(skill >= 2) // skill 0 and 1 bots won't detonate rockets!
		{
			// decide whether to detonate rockets
			entity missile, targetlist, targ;
			float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
			float selfdamage, teamdamage, enemydamage;
			edgedamage = autocvar_g_balance_devastator_edgedamage;
			coredamage = autocvar_g_balance_devastator_damage;
			edgeradius = autocvar_g_balance_devastator_radius;
			recipricoledgeradius = 1 / edgeradius;
			selfdamage = 0;
			teamdamage = 0;
			enemydamage = 0;
			targetlist = findchainfloat(bot_attack, TRUE);
			missile = find(world, classname, "rocket");
			while (missile)
			{
				if (missile.realowner != self)
				{
					missile = find(missile, classname, "rocket");
					continue;
				}
				targ = targetlist;
				while (targ)
				{
					d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - missile.origin);
					d = bound(0, edgedamage + (coredamage - edgedamage) * sqrt(1 - d * recipricoledgeradius), 10000);
					// count potential damage according to type of target
					if (targ == self)
						selfdamage = selfdamage + d;
					else if (targ.team == self.team && teamplay)
						teamdamage = teamdamage + d;
					else if (bot_shouldattack(targ))
						enemydamage = enemydamage + d;
					targ = targ.chain;
				}
				missile = find(missile, classname, "rocket");
			}
			float desirabledamage;
			desirabledamage = enemydamage;
			if (time > self.invincible_finished && time > self.spawnshieldtime)
				desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
			if (teamplay && self.team)
				desirabledamage = desirabledamage - teamdamage;

			missile = find(world, classname, "rocket");
			while (missile)
			{
				if (missile.realowner != self)
				{
					missile = find(missile, classname, "rocket");
					continue;
				}
				makevectors(missile.v_angle);
				targ = targetlist;
				if (skill > 9) // normal players only do this for the target they are tracking
				{
					targ = targetlist;
					while (targ)
					{
						if (
							(v_forward * normalize(missile.origin - targ.origin)< 0.1)
							&& desirabledamage > 0.1*coredamage
						)self.BUTTON_ATCK2 = TRUE;
						targ = targ.chain;
					}
				}else{
					float distance; distance= bound(300,vlen(self.origin-self.enemy.origin),30000);
					//As the distance gets larger, a correct detonation gets near imposible
					//Bots are assumed to use the rocket spawnfunc_light to see if the rocket gets near a player
					if(v_forward * normalize(missile.origin - self.enemy.origin)< 0.1)
						if(self.enemy.classname == "player")
							if(desirabledamage >= 0.1*coredamage)
								if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
									self.BUTTON_ATCK2 = TRUE;
				//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
				}

				missile = find(missile, classname, "rocket");
			}
			// if we would be doing at X percent of the core damage, detonate it
			// but don't fire a new shot at the same time!
			if (desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
				self.BUTTON_ATCK2 = TRUE;
			if ((skill > 6.5) && (selfdamage > self.health))
				self.BUTTON_ATCK2 = FALSE;
			//if(self.BUTTON_ATCK2 == TRUE)
			//	dprint(ftos(desirabledamage),"\n");
			if (self.BUTTON_ATCK2 == TRUE) self.BUTTON_ATCK = FALSE;
		}
	}
	else if (req == WR_THINK && !W_DevastatorLauncher_NeedManualReload())
	{
		if(autocvar_g_balance_devastator_reload_ammo && self.clip_load < autocvar_g_balance_devastator_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else
		{
			if (self.BUTTON_ATCK)
			{
				if(self.devastator_release || autocvar_g_balance_devastator_guidestop)
				if(weapon_prepareattack(0, autocvar_g_balance_devastator_refire))
				{
					W_Devastator_Attack();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_devastator_animtime, w_ready);
					self.devastator_release = 0;
				}
			}
			else
				self.devastator_release = 1;

			if (self.BUTTON_ATCK2)
			{
				rockfound = 0;
				for(rock = world; (rock = find(rock, classname, "rocket")); ) if(rock.realowner == self)
				{
					if(!rock.devastator_detonate_later)
					{
						rock.devastator_detonate_later = TRUE;
						rockfound = 1;
					}
				}
				if(rockfound)
					sound (self, CH_WEAPON_B, "weapons/rocket_det.wav", VOL_BASE, ATTN_NORM);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/sphere/sphexp.md3");
		precache_model ("models/flash.md3");
		precache_model ("models/weapons/g_devastator.md3");
		precache_model ("models/weapons/v_devastator.md3");
		precache_model ("models/weapons/h_devastator.iqm");
		precache_sound ("weapons/rocket_det.wav");
		precache_sound ("weapons/rocket_fire.wav");
		precache_sound ("weapons/rocket_mode.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '35 -0.01 -5';
		self.weaponaltaim = '35 -0.01 -10';
		
		self.weaponinitaimmotif_use = 2; //relative
		//self.weaponinitaimmotif = '0 0 -5';
		//self.weaponinitaimmotif = '0 -4 -6';
		self.weaponinitaimmotif = '0 -5 0';
		
		weapon_setup(WEP_DEVASTATOR);
		self.current_ammo = ammo_rockets;
		self.devastator_release = 1;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while guiding a missile
		if (ATTACK_FINISHED(self) <= time || self.weapon != WEP_DEVASTATOR)
		{
			ammo_amount = FALSE;
			if(autocvar_g_balance_devastator_reload_ammo)
			{
				if(self.ammo_rockets < autocvar_g_balance_devastator_ammo && self.(weapon_load[WEP_DEVASTATOR]) < autocvar_g_balance_devastator_ammo)
					ammo_amount = TRUE;
			}
			else if(self.ammo_rockets < autocvar_g_balance_devastator_ammo)
				ammo_amount = TRUE;
			return !ammo_amount;
		}
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_RESETPLAYER)
	{
		self.lastrocket = world; // stop rocket guiding, no revenge from the grave!
		self.devastator_release = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_devastator_ammo, autocvar_g_balance_devastator_reload_ammo, autocvar_g_balance_devastator_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_devastator(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/rocket_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s blew themself up with their Devastator");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE) // (remote detonation)
			w_deathtypestring = _("%s got too close to %s's Devastator rocket");
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s almost dodged %s's Devastator rocket");
		else
			w_deathtypestring = _("%s ate %s's Devastator rocket");
	}
	return TRUE;
}
#endif
#endif
