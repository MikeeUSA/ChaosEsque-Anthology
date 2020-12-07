#ifdef REGISTER_WEAPON
REGISTER_WEAPON(RPG7_LAUNCHER, w_rpg7launcher, IT_ROCKETS, 9, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_HIGH, "rpg7", "rpg7launcher", _("RPG7"))
#else
#ifdef SVQC
.float rpg7_release;
.float rpg7_faillaunch;
.float rpg7_reloaded_time;
.float rpg7_timeminus;

//Todo: add eject casing thing, add _empty

void W_RPG7Rocket_Unregister()
{
	if(self.realowner && self.realowner.lastrocket == self)
	{
		self.realowner.lastrocket = world;
		// self.realowner.rpg7_release = 1;
	}
}

void W_RPG7Rocket_Explode ()
{
	W_RPG7Rocket_Unregister();
	
	local float notdud;
	notdud = 0;

	if(autocvar_g_balance_rpg7launcher_primary_failurerate &&
 	(autocvar_g_balance_rpg7launcher_primary_failurerate > random() ))
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
	
	notdud = 1; //So we will only burn things if not a dud.

	RadiusDamage (self, self.realowner, autocvar_g_balance_rpg7launcher_damage, autocvar_g_balance_rpg7launcher_edgedamage, autocvar_g_balance_rpg7launcher_radius, world, autocvar_g_balance_rpg7launcher_force, self.projectiledeathtype, other);

	//Concussion
	RadiusDamage (self, self.realowner, 20, 5, autocvar_g_balance_rpg7launcher_radius*2, world, autocvar_g_balance_rpg7launcher_force*0.25, DEATH_FALL, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	//Start Explosion Shockwave and fireball
	modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rpg7launcher_radius, 0.95, 0.05, 0.25);
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rpg7launcher_radius, 0.35, 0.13, 0.6);
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rpg7launcher_radius, 0.4, 1, 4.0);

	//End Explosion Shockwave and Fireball
	
	} //End To Dud or not to dud.
	
	
	if (self.realowner.weapon == WEP_RPG7_LAUNCHER)
	{
		if(self.realowner.ammo_rockets < autocvar_g_balance_rpg7launcher_ammo)
		{
			self.realowner.cnt = WEP_RPG7_LAUNCHER;
			ATTACK_FINISHED(self.realowner) = time;
			self.realowner.switchweapon = w_getbestweapon(self.realowner);
		}
	}
	
	if (notdud) {
	/////Fire Stuff Begin////////
	  //Sometimes things burn
	  local float burnrandom, indivburn;
	  burnrandom = random();
	  indivburn = random(); //How often to burn everything or not.
	
	  if (burnrandom > 0.92) {		
		entity eburn;
	
		eburn = findradius(self.origin, autocvar_g_balance_rpg7launcher_radius);
		while(eburn)
		{
		if (((eburn.classname == "player" && eburn.health > 0) || eburn.classname == "tree" || eburn.classname == "bush"
		|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) ) && (random() > indivburn))
			Fire_AddDamage(eburn, self.realowner, autocvar_g_balance_nukelayer_fire5_damage *
			10, 10, 
			WEP_FIREBALL);
		
			if (eburn.classname == "tree"
			|| eburn.classname == "bush") {
				eburn.fire_intensity = 5;
			}
		
			eburn = eburn.chain;
		}
	  } else if (burnrandom > 0.8) {		
		entity eburn;
	
		eburn = findradius(self.origin, autocvar_g_balance_rpg7launcher_radius);
		while(eburn)
		{
		if ((eburn.classname == "tree" || eburn.classname == "bush") && (random() > indivburn))
			Fire_AddDamage(eburn, self.realowner, autocvar_g_balance_nukelayer_fire5_damage *
			10, 10, 
			WEP_FIREBALL);
		
			if (eburn.classname == "tree"
			|| eburn.classname == "bush") {
				eburn.fire_intensity = 5;
			}
		
			eburn = eburn.chain;
		}
	  }
	/////Fire Stuff End////////
	}
	
	remove (self);
}

void W_RPG7Rocket_Think (void)
{

#if 0
	float cosminang, cosmaxang, cosang;
#endif
	float velspeed;
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_RPG7Rocket_Explode ();
		return;
	}

	// accelerate
	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	if (self.rpg7_faillaunch) {
		// lauchfailure rocket
		W_RPG7Rocket_Unregister();
		
		velspeed = autocvar_g_balance_rpg7launcher_launchfailure_speed * g_weaponspeedfactor - (self.velocity * v_forward);
		if (velspeed > 0)
			self.velocity = self.velocity + v_forward * min(autocvar_g_balance_rpg7launcher_launchfailure_speedaccel * g_weaponspeedfactor * frametime, velspeed);
	} else {
	// normal rocket
	velspeed = autocvar_g_balance_rpg7launcher_speed * g_weaponspeedfactor - (self.velocity * v_forward);
	if (velspeed > 0)
		self.velocity = self.velocity + v_forward * min(autocvar_g_balance_rpg7launcher_speedaccel * g_weaponspeedfactor * frametime, velspeed);
	}
	// laser guided, or remote detonation removed

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void W_RPG7Rocket_Touch (void)
{
	if(WarpZone_Projectile_Touch())
	{
		if(wasfreed(self))
			W_RPG7Rocket_Unregister();
		return;
	}
	W_RPG7Rocket_Unregister();
	W_RPG7Rocket_Explode ();
}

void W_RPG7Rocket_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
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
		W_PrepareExplosionByDamage(attacker, W_RPG7Rocket_Explode);
}

void W_RPG7Rocket_Attack (void)
{
	entity missile;
	entity flash;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_rpg7launcher_ammo, autocvar_g_balance_rpg7launcher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3.25 -3.25 -3.25', '3.25 3.25 3.25', FALSE, 2, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rpg7launcher_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
	if(autocvar_g_balance_rpg7launcher_detonatedelay >= 0)
		missile.spawnshieldtime = time + autocvar_g_balance_rpg7launcher_detonatedelay;
	else
		missile.spawnshieldtime = -1;
	////missile.pushltime = time;// + autocvar_g_balance_rpg7launcher_guidedelay;
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_rpg7launcher_damage * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = autocvar_g_balance_rpg7launcher_damageforcescale;
	missile.health = autocvar_g_balance_rpg7launcher_health;
	missile.event_damage = W_RPG7Rocket_Damage;
	missile.damagedbycontents = TRUE;


	if(autocvar_g_balance_rpg7launcher_launch_failurerate &&
 	(autocvar_g_balance_rpg7launcher_launch_failurerate > random() ))
 	{
		//Start Abnormal
		missile.rpg7_faillaunch = 1;
		
		missile.movetype = MOVETYPE_BOUNCE;
		PROJECTILE_MAKETRIGGER(missile);
		missile.projectiledeathtype = WEP_RPG7_LAUNCHER;
		setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

		setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
		W_SetupProjectileVelocity(missile, autocvar_g_balance_rpg7launcher_launchfailure_speedstart, 0);
		
		//End Abnormal
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "A launch failure occured\n");
		}
	} else {
	//Start Normal Missile
	missile.rpg7_faillaunch = 0;
	
	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_RPG7_LAUNCHER;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_balance_rpg7launcher_speedstart, 0);
	
	//End Normal Missile
	
		if (autocvar_g_casings >= 2)
			SpawnCasing (((random () * 1 + 1) * v_right) - (v_forward * (random () * 2500 + 25)) - ((random () * -1 - 2) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 33, self);

	}
	
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_RPG7Rocket_Touch;
	missile.think = W_RPG7Rocket_Think;
	missile.nextthink = time;
	if (self.rpg7_timeminus >= autocvar_g_balance_rpg7launcher_lifetime) {
		missile.cnt = time + 0.1 + autocvar_g_balance_rpg7launcher_lifetime - self.rpg7_timeminus;
	} else if (self.rpg7_timeminus < 0) {
		missile.cnt = time + autocvar_g_balance_rpg7launcher_lifetime;
	} else {
		missile.cnt = time + autocvar_g_balance_rpg7launcher_lifetime - self.rpg7_timeminus;
	}
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, autocvar_g_balance_rpg7launcher_guiderate == 0 && autocvar_g_balance_rpg7launcher_speedaccel == 0, PROJECTILE_RPG, FALSE); // because of fly sound
	
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
	PlayerGunRise(self, autocvar_g_balance_rpg7launcher_gunrise, random() * autocvar_g_balance_rpg7launcher_gunrun);
}

float W_RPG7RocketLauncher_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_rpg7launcher_reload_ammo && self.clip_load < autocvar_g_balance_rpg7launcher_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_rpg7launcher ()
{    
	weapon_defaultspawnfunc(WEP_RPG7_LAUNCHER);
}

float w_rpg7launcher(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_RPG7RocketLauncher_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		// aim and decide to fire if appropriate
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_rpg7launcher_speed, 0, autocvar_g_balance_rpg7launcher_lifetime, FALSE);
		
	}
	else if (req == WR_THINK)
	{
		if (!W_RPG7RocketLauncher_NeedManualReload())
		{
			if(autocvar_g_balance_rpg7launcher_reload_ammo && self.clip_load < autocvar_g_balance_rpg7launcher_ammo) // forced reload
				weapon_action(self.weapon, WR_RELOAD);
			else
			{
				if (self.BUTTON_ATCK)
				{
					if(self.rpg7_release)
					if(weapon_prepareattack(0, autocvar_g_balance_rpg7launcher_refire))
					{
						W_RPG7Rocket_Attack();
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_rpg7launcher_animtime, w_ready);
						self.rpg7_release = 0;
						
						self.weaponname = "rpg7_empty";
					}
				}
	
				if (self.BUTTON_ATCK2)
				if (self.rpg7_release)
				{
					//change delay perhaps? (minus etc)
					if(self.BUTTON_CROUCH) {
						//Up (reduce timeminus)
						if (self.rpg7_timeminus > 0) {
							self.rpg7_timeminus = self.rpg7_timeminus - 0.25;
						} else {
							self.rpg7_timeminus = autocvar_g_balance_rpg7launcher_lifetime;
						}
						
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, sprintf("Fuse Timer Increased: %f\n", (autocvar_g_balance_rpg7launcher_lifetime - self.rpg7_timeminus)));
						}
						spamsound (self, CH_SHOTS, "misc/increasevalue.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
					} else {
						if (self.rpg7_timeminus < autocvar_g_balance_rpg7launcher_lifetime) {
							self.rpg7_timeminus = self.rpg7_timeminus + 0.25;
						} else {
							self.rpg7_timeminus = 0;
						}
						
						if ((clienttype(self) == CLIENTTYPE_REAL)) {
							sprint(self, sprintf("Fuse Timer Decreased: %f\n", (autocvar_g_balance_rpg7launcher_lifetime - self.rpg7_timeminus)));
						}
						spamsound (self, CH_SHOTS, "misc/decreasevalue.wav", VOL_BASE * 0.35, ATTN_NORM); //Not 0.25: Heavier Firing Pin
					}
					
					if (self.rpg7_timeminus > autocvar_g_balance_rpg7launcher_lifetime) {
						self.rpg7_timeminus = autocvar_g_balance_rpg7launcher_lifetime;
					} else if (self.rpg7_timeminus < 0) {
						self.rpg7_timeminus = 0;
					}
					
					self.rpg7_release = 0;
				}
				
				if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
					self.rpg7_release = 1;
				}
			}
		
		
		} else {
			self.weaponname = "rpg7_empty";
		}
		
		//"Animation"
		if ((self.rpg7_reloaded_time) && 
		(self.rpg7_reloaded_time < time))
		{
			self.weaponname = "rpg7";

			self.rpg7_reloaded_time = 0;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/sphere/sphexp.md3");
		precache_model ("models/flash.md3");
		precache_model ("models/weapons/g_rpg7.md3");
		precache_model ("models/weapons/v_rpg7.md3");
		precache_model ("models/weapons/h_rpg7.iqm");
		precache_model ("models/weapons/v_rpg7_empty.md3");
		precache_model ("models/weapons/h_rpg7_empty.iqm");
		precache_sound ("weapons/rocket_det.wav");
		precache_sound ("weapons/rocket_fire.wav");
		precache_sound ("weapons/rocket_mode.wav");
		precache_sound ("misc/decreasevalue.wav");
		precache_sound ("misc/increasevalue.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '30 -5.2 0';
		//self.weaponaltaim = '30 -4 0';
		//////self.weaponaltaim = '30 -2.2 -5';
		//self.weaponaltaim = '30 -1.5 -4';
		//self.weaponaltaim = '35 -1.5 -4.5';
		//self.weaponaltaim = '37 -1.2 -6.0';
		//self.weaponaltaim = '37 -1 -5.25';
		self.weaponaltaim = '38 -1 -5.50';
		
		self.weaponinitaimmotif_use = 1;
		self.weaponinitaimmotif = '30 -4 0';
		
		weapon_setup(WEP_RPG7_LAUNCHER);
		self.current_ammo = ammo_rockets;
		self.rpg7_release = 1;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while guiding a missile
		if (ATTACK_FINISHED(self) <= time || self.weapon != WEP_RPG7_LAUNCHER)
		{
			ammo_amount = FALSE;
			if(autocvar_g_balance_rpg7launcher_reload_ammo)
			{
				if(self.ammo_rockets < autocvar_g_balance_rpg7launcher_ammo && self.(weapon_load[WEP_RPG7_LAUNCHER]) < autocvar_g_balance_rpg7launcher_ammo)
					ammo_amount = TRUE;
			}
			else if(self.ammo_rockets < autocvar_g_balance_rpg7launcher_ammo)
				ammo_amount = TRUE;
			return !ammo_amount;
		}
	}
	else if (req == WR_CHECKAMMO2)
		return FALSE;
	else if (req == WR_RESETPLAYER)
	{
		self.rpg7_release = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_rpg7launcher_ammo, autocvar_g_balance_rpg7launcher_reload_ammo, autocvar_g_balance_rpg7launcher_reload_time, "weapons/reload.wav");
		self.rpg7_reloaded_time = time + autocvar_g_balance_rpg7launcher_reload_time;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_rpg7launcher(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("explosion_big"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/rocket_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s blew themself up with their rpg7launcher");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE) // (remote detonation)
			w_deathtypestring = _("%s got too close to %s's rocket propelled grenade");
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s almost dodged %s's RPG");
		else
			w_deathtypestring = _("%s was destroyed by %s's rocket propelled grenade");
	}
	return TRUE;
}
#endif
#endif
