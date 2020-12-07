//This is misc_fire_crossbowbolt
//It allow you to have your map fire projectiles at things and people in the map
//Many ways to fire.
//Hope not too hacky

void misc_fire_crossbowbolt_attack (void)
{
	entity crossbolt;

	//No use of ammo for this

	makevectors(self.angles);
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_CROSSBOWDTWR;
	setorigin(crossbolt, self.origin);
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
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);	
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_CROSSBOWBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_fireball_attack2()
{
	entity proj;
	vector f_diff;
	float c;

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	makevectors(self.angles);
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, self);
	w_shotorg = trace_endpos;

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = self;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + autocvar_g_balance_fireball_secondary_lifetime;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}


void misc_fire_fireball_attack1()
{
	entity proj;
	
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Fireball_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}


void misc_fire_crylink_attack (void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	//No need for ammo here
	makevectors(self.angles);
	
	maxdmg = autocvar_g_balance_crylink_primary_damage*autocvar_g_balance_crylink_primary_shots;
	maxdmg *= 1 + autocvar_g_balance_crylink_primary_bouncedamagefactor * autocvar_g_balance_crylink_primary_bounces;
	if(autocvar_g_balance_crylink_primary_joinexplode)
		maxdmg += autocvar_g_balance_crylink_primary_joinexplode_damage;

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_balance_crylink_primary_shots;
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crylink_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_crylink_primary_damage;
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * autocvar_g_balance_crylink_primary_spread * g_weaponspreadfactor;
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, autocvar_g_balance_crylink_primary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Crylink_Touch;

		proj.think = W_Crylink_Fadethink;
		if(counter == 0)
		{
			proj.fade_time = time + autocvar_g_balance_crylink_primary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_primary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_primary_middle_lifetime + autocvar_g_balance_crylink_primary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_crylink_primary_other_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_primary_other_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_primary_other_lifetime + autocvar_g_balance_crylink_primary_other_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_crylink_primary_joindelay;
		proj.cnt = autocvar_g_balance_crylink_primary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(autocvar_g_balance_crylink_primary_joinspread != 0 || autocvar_g_balance_crylink_primary_jointime != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		self.crylink_waitrelease = 1;
	}
}

void misc_fire_crylink_attack2 (void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	float maxdmg;

	//No use of ammo for this

	maxdmg = autocvar_g_balance_crylink_secondary_damage*autocvar_g_balance_crylink_secondary_shots;
	maxdmg *= 1 + autocvar_g_balance_crylink_secondary_bouncedamagefactor * autocvar_g_balance_crylink_secondary_bounces;
	if(autocvar_g_balance_crylink_secondary_joinexplode)
		maxdmg += autocvar_g_balance_crylink_secondary_joinexplode_damage;

	makevectors(self.angles);
	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire2.wav", CH_WEAPON_A, maxdmg);

	shots = autocvar_g_balance_crylink_secondary_shots;
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crylink_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_crylink_secondary_damage;
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYLINK | HITTYPE_SECONDARY;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');

		W_SetupProjectileVelocityEx(proj, (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * autocvar_g_balance_crylink_secondary_spread * g_weaponspreadfactor), v_up, autocvar_g_balance_crylink_secondary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Crylink_Touch2;
		proj.think = W_Crylink_Fadethink;
		if(counter == (shots - 1) / 2)
		{
			proj.fade_time = time + autocvar_g_balance_crylink_secondary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_secondary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_secondary_middle_lifetime + autocvar_g_balance_crylink_secondary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_crylink_secondary_line_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crylink_secondary_line_fadetime;
			proj.nextthink = time + autocvar_g_balance_crylink_secondary_line_lifetime + autocvar_g_balance_crylink_secondary_line_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_crylink_secondary_joindelay;
		proj.cnt = autocvar_g_balance_crylink_secondary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;
        
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(autocvar_g_balance_crylink_secondary_joinspread != 0 || autocvar_g_balance_crylink_secondary_jointime != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crylink_CheckLinks(proj);
		self.crylink_waitrelease = 2;
	}
}

void misc_fire_electro_attack2()
{
	entity proj;

	//No use of ammo for this
	
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '0 0 -4', '0 0 -4', FALSE, 2, "weapons/electro_fire2.wav", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);

	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma";
	proj.owner = proj.realowner = self;
	proj.use = W_Plasma_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_electro_secondary_damage;
	proj.nextthink = time + autocvar_g_balance_electro_secondary_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO | HITTYPE_SECONDARY;
	setorigin(proj, w_shotorg);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_electro_secondary);
	proj.touch = W_Plasma_Touch;
	setsize(proj, '0 0 -4', '0 0 -4');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_electro_secondary_damageforcescale;
	proj.health = autocvar_g_balance_electro_secondary_health;
	proj.event_damage = W_Plasma_Damage;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = (autocvar_g_balance_electro_secondary_damagedbycontents);

	proj.bouncefactor = autocvar_g_balance_electro_secondary_bouncefactor;
	proj.bouncestop = autocvar_g_balance_electro_secondary_bouncestop;
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

#if 0
	entity p2;
	p2 = spawn();
	copyentity(proj, p2);
	setmodel(p2, "models/ebomb.mdl");
	setsize(p2, proj.mins, proj.maxs);
#endif

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO, FALSE); // no culling, it has sound

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_uzibullet()
{
	
	makevectors(self.angles);
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_uzi_speed >= autocvar_g_antilag_bullets, 0, "weapons/uzi_fire.wav", CH_WEAPON_A, autocvar_g_balance_uzi_sustained_damage);
	
	fireBallisticBullet(w_shotorg, w_shotdir, autocvar_g_balance_uzi_sustained_spread, autocvar_g_balance_uzi_speed, 5, autocvar_g_balance_uzi_sustained_damage, autocvar_g_balance_uzi_sustained_headshotaddeddamage, autocvar_g_balance_uzi_sustained_force, WEP_UZI, 0, 1, autocvar_g_balance_uzi_bulletconstant, autocvar_g_balance_uzi_sustained_coreshotaddeddamage);
	endFireBallisticBullet();
	
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
}

void misc_fire_hmgbullet()
{
	float hmg_spread;
	
	makevectors(self.angles);
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_hmg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2.wav", CH_WEAPON_A, autocvar_g_balance_hmg_sustained_damage);
	
	hmg_spread = bound(autocvar_g_balance_hmg_spread_min, autocvar_g_balance_hmg_spread_min + (autocvar_g_balance_hmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_hmg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, hmg_spread, autocvar_g_balance_hmg_speed, 5, autocvar_g_balance_hmg_sustained_damage, autocvar_g_balance_hmg_sustained_headshotaddeddamage, autocvar_g_balance_hmg_sustained_force, WEP_HMG, 0, 1, autocvar_g_balance_hmg_bulletconstant, autocvar_g_balance_hmg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();
	
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
}

void misc_fire_shotgunblast()
{
	float	sc;
	float	ammoamount;
	float	bullets;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;

	ammoamount = autocvar_g_balance_shotgun_primary_ammo;
	bullets = autocvar_g_balance_shotgun_primary_bullets;
	d = autocvar_g_balance_shotgun_primary_damage;
	f = autocvar_g_balance_shotgun_primary_force;
	spread = autocvar_g_balance_shotgun_primary_spread;
	bulletspeed = autocvar_g_balance_shotgun_primary_speed;
	bulletconstant = autocvar_g_balance_shotgun_primary_bulletconstant;
	
	makevectors(self.angles);
	W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d * bullets);
	
	for (sc = 0;sc < bullets;sc = sc + 1)
		fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN, 0, 1, bulletconstant, autocvar_g_balance_shotgun_primary_coreshotaddeddamage);
	endFireBallisticBullet();
	
	pointparticles(particleeffectnum("shotgun_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_shotgun_primary_ammo);
}

void misc_fire_rocket_attack (void)
{
	entity missile;
	entity flash;

	//No need to decrease ammo here
	
	makevectors(self.angles);
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rocketlauncher_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = missile.realowner = self;
	self.lastrocket = missile;
	if(autocvar_g_balance_rocketlauncher_detonatedelay >= 0)
		missile.spawnshieldtime = time + autocvar_g_balance_rocketlauncher_detonatedelay;
	else
		missile.spawnshieldtime = -1;
	missile.pushltime = time + autocvar_g_balance_rocketlauncher_guidedelay;
	missile.classname = "rocket";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_rocketlauncher_damage * 2; // * 2 because it can be detonated inflight which makes it even more dangerous

	missile.takedamage = DAMAGE_YES;
	missile.damageforcescale = autocvar_g_balance_rocketlauncher_damageforcescale;
	missile.health = autocvar_g_balance_rocketlauncher_health;
	missile.event_damage = W_Rocket_Damage;
	missile.damagedbycontents = TRUE;

	//Start Normal Missile
	missile.rl_faillaunch = 0;
	
	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_ROCKET_LAUNCHER;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, w_shotorg - v_forward * 3); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(missile, autocvar_g_balance_rocketlauncher_speedstart, 0);
	
	//End Normal Missile
	
	missile.angles = vectoangles (missile.velocity);

	missile.touch = W_Rocket_Touch;
	missile.think = W_Rocket_Think;
	missile.nextthink = time;
	missile.cnt = time + autocvar_g_balance_rocketlauncher_lifetime;
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, autocvar_g_balance_rocketlauncher_guiderate == 0 && autocvar_g_balance_rocketlauncher_speedaccel == 0, PROJECTILE_ROCKET, FALSE); // because of fly sound
	
	// muzzle flash for 1st person view
	flash = spawn ();
	setmodel (flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_electro_attack()
{
	entity proj;

	//No need to decrease ammo here
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '0 0 -3', '0 0 -3', FALSE, 2, "weapons/electro_fire.wav", CH_WEAPON_A, autocvar_g_balance_electro_primary_damage);

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_electro_primary_damage;
	proj.use = W_Plasma_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = time + autocvar_g_balance_electro_primary_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_ELECTRO;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_electro_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Plasma_TouchExplode;
	setsize(proj, '0 0 -3', '0 0 -3');
	proj.flags = FL_PROJECTILE;
	proj.missile_flags = MIF_SPLASH;

	CSQCProjectile(proj, TRUE, PROJECTILE_ELECTRO_BEAM, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_grenade_attack2 (void)
{
	entity gren;

	//No need for ammo here
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_grenade_attack (void)
{
	entity gren;

	//No need for ammo here
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_primary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_primary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_grenadelauncher_primary_lifetime;
	gren.nextthink = time;
	gren.think = W_Grenade_Think1;
	gren.use = W_Grenade_Explode;
	gren.touch = W_Grenade_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_primary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_primary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_primary);


	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_primary_type == 0 || autocvar_g_balance_grenadelauncher_primary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_expvest_attack (void)
{
	entity exvest;
	
	//No need for ammo here
	makevectors(self.angles);
	
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/rocket_det.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_primary_damage);
	w_shotdir = v_forward; // no TrueAim for exvestades please

	exvest = spawn ();
	exvest.owner = exvest.realowner = self;
	exvest.classname = "grenade";
	exvest.bot_dodge = TRUE;
	exvest.bot_dodgerating = autocvar_g_balance_explosivevest_primary_damage;
	exvest.movetype = MOVETYPE_BOUNCE;
	exvest.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	exvest.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(exvest);
	exvest.projectiledeathtype = WEP_EXPLOSIVE_VEST;
	setorigin(exvest, w_shotorg);
	setsize(exvest, '-3 -3 -3', '3 3 3');

	exvest.cnt = time + autocvar_g_balance_explosivevest_primary_delay;
	exvest.nextthink = time;
	exvest.think = W_Expvest_Think;
	exvest.use = W_Expvest_Explode;
	exvest.touch = W_Expvest_Touch;

	exvest.takedamage = DAMAGE_YES;
	exvest.health = autocvar_g_balance_grenadelauncher_primary_health;
	exvest.damageforcescale = autocvar_g_balance_explosivevest_primary_damageforcescale;
	exvest.event_damage = W_Expvest_Damage;
	exvest.damagedbycontents = TRUE;
 	
	W_SETUPPROJECTILEVELOCITY_UP(exvest, g_balance_explosivevest_primary);

	exvest.angles = vectoangles (exvest.velocity);
	exvest.flags = FL_PROJECTILE;
	
	CSQCProjectile(exvest, TRUE, PROJECTILE_GRENADE, TRUE);
	
	other = exvest; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_hagar_attack (void)
{
	entity missile;

	//No need for ammo here
	makevectors(self.angles);
	
	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_hagar_primary_damage);

	pointparticles(particleeffectnum("hagar_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_hagar_primary_damage;
	
	missile.takedamage = DAMAGE_YES;
	missile.health = autocvar_g_balance_hagar_primary_health;
	missile.damageforcescale = autocvar_g_balance_hagar_primary_damageforcescale;
	missile.event_damage = W_Hagar_Damage;
	missile.damagedbycontents = TRUE;
	
	missile.touch = W_Hagar_Touch;
	missile.use = W_Hagar_Explode;
	missile.think = adaptor_think2use_hittype_splash;
	missile.nextthink = time + autocvar_g_balance_hagar_primary_lifetime;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR;
	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');
	
	missile.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_primary);

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}


void misc_fire_laser_attack ()
{
	entity missile;
	vector s_forward;
	float a;
	float nodamage;

	makevectors(self.angles);
	
	nodamage = FALSE;

	a = autocvar_g_balance_laser_primary_shotangle;
	s_forward = v_forward * cos(a * DEG2RAD) + v_up * sin(a * DEG2RAD);

	if(nodamage)
		W_SetupShot_Dir (self, s_forward, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, 0);
	else
		W_SetupShot_Dir (self, s_forward, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_B, autocvar_g_balance_laser_primary_damage);
	pointparticles(particleeffectnum("laser_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "laserbolt";
	missile.dmg = 0;
	if(!nodamage)
	{
		missile.bot_dodge = TRUE;
		missile.bot_dodgerating = autocvar_g_balance_laser_primary_damage;
	}

	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_LASER;

	setorigin (missile, w_shotorg);
	setsize(missile, '0 0 0', '0 0 0');

	W_SETUPPROJECTILEVELOCITY(missile, g_balance_laser_primary);
	missile.angles = vectoangles (missile.velocity);
	//missile.glow_color = 250; // 244, 250
	//missile.glow_size = 120;
	missile.touch = W_Laser_Touch;

	missile.flags = FL_PROJECTILE;
	missile.missile_flags = MIF_SPLASH; 

	missile.think = W_Laser_Think;
	missile.nextthink = time + autocvar_g_balance_laser_primary_delay;

	other = missile; MUTATOR_CALLHOOK(EditProjectile);

	if(time >= missile.nextthink)
	{
		entity oldself;
		oldself = self;
		self = missile;
		self.think();
		self = oldself;
	}
}

void misc_fire_hook_attack2()
{
	entity gren;

	makevectors(self.angles);
	W_SetupShot (self, FALSE, 4, "weapons/hookbomb_fire.wav", CH_WEAPON_A, autocvar_g_balance_hook_secondary_damage);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "hookbomb";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_hook_secondary_damage;
	gren.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_HOOK | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '0 0 0', '0 0 0');

	gren.nextthink = time + autocvar_g_balance_hook_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Hook_Explode2;
	gren.touch = W_Hook_Touch2;
	
	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_hook_secondary_health;
	gren.damageforcescale = autocvar_g_balance_hook_secondary_damageforcescale;
	gren.event_damage = W_Hook_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	gren.velocity = '0 0 1' * autocvar_g_balance_hook_secondary_speed;
	if(autocvar_g_projectiles_newton_style)
		gren.velocity = gren.velocity + self.velocity;

	gren.gravity = autocvar_g_balance_hook_secondary_gravity;
	//W_SetupProjectileVelocity(gren); // just falling down!

	gren.angles = '0 0 0';
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_HOOKBOMB, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void misc_fire_hlac_attack2 (void)
{
    float i;

	//No need for ammo here
	makevectors(self.angles);

    for(i=autocvar_g_balance_hlac_secondary_shots;i>0;--i)
        W_HLAC_Attack2f();

}

void misc_fire_nex_attack ()
{
	float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, myammo, charge;
	makevectors(self.angles);
	
		mydmg = autocvar_g_balance_nex_primary_damage;
		myforce = autocvar_g_balance_nex_primary_force;
		mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		myammo = autocvar_g_balance_nex_primary_ammo;

	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	charge = 1;
	mydmg *= charge;
	myforce *= charge;

	W_SetupShot (self, TRUE, 5, "weapons/nexfire.wav", CH_WEAPON_A, mydmg);
	if(charge > autocvar_g_balance_nex_charge_animlimit && autocvar_g_balance_nex_charge_animlimit) // if the Nex is overcharged, we play an extra sound
	{
		sound (self, CH_WEAPON_B, "weapons/nexcharge.wav", VOL_BASE * (charge - 0.5 * autocvar_g_balance_nex_charge_animlimit) / (1 - 0.5 * autocvar_g_balance_nex_charge_animlimit), ATTN_NORM);
	}

	FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);


	//beam and muzzle flash done on client
	SendCSQCNexBeamParticle(charge);
}

void misc_fire_fireBallistaBolt (void)
{
	makevectors(self.angles);
	fireBallistaBolt(self.origin, v_forward, autocvar_g_vehicle_mg_scorpion_bolt_spread, autocvar_g_vehicle_mg_scorpion_bolt_speed, autocvar_g_balance_crossbowdtwr_primary_lifetime, autocvar_g_vehicle_mg_scorpion_bolt_damage, autocvar_g_vehicle_mg_scorpion_bolt_force, WEP_CROSSBOWDTWR);
}


void misc_fire_fireFlameThrower(void)
{

	local entity mybullet;
	mybullet = self;
	makevectors(self.angles);

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				//flashent.projectiledeathtype = WEP_FLAMETHROWER;
				//setmodel(flashent, "models/uziflash.md3");
				flashent.think = PiercingCausesFire_FireJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				//flashent.angles = vectoangles(mynormal);
				flashent.angles = mybullet.angles;
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!mybullet.count) {
					flashent.amnt = time + 4;
				} else {
					flashent.amnt = time + mybullet.count;
				}
				
				
				if (!mybullet.ammount)
					flashent.ammount = 1536;
				
				if (!mybullet.ammount2)
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				
				if (!mybullet.ammount3)
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				
				if (!mybullet.ammount4)
					flashent.ammount4 = 256;
				
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}


void misc_fire_fireFrostThrower(void)
{

	local entity mybullet;
	mybullet = self;
	makevectors(self.angles);

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				
				flashent.think = PiercingCausesIce_IceJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				//flashent.angles = vectoangles(mynormal);
				flashent.angles = mybullet.angles;
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!mybullet.count) {
					flashent.amnt = time + 4;
				} else {
					flashent.amnt = time + mybullet.count;
				}
				
				
				if (!mybullet.ammount)
					flashent.ammount = 1536;
				
				if (!mybullet.ammount2)
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				
				if (!mybullet.ammount3)
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				
				if (!mybullet.ammount4)
					flashent.ammount4 = 256;
				
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}


void misc_fire_firePoisonThrower(void)
{

	local entity mybullet;
	mybullet = self;
	makevectors(self.angles);

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				
				flashent.think = PiercingCausesPoison_PoisonJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				//flashent.angles = vectoangles(mynormal);
				flashent.angles = mybullet.angles;
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!mybullet.count) {
					flashent.amnt = time + 4;
				} else {
					flashent.amnt = time + mybullet.count;
				}
				
				
				if (!mybullet.ammount)
					flashent.ammount = 1536;
				
				if (!mybullet.ammount2)
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				
				if (!mybullet.ammount3)
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				
				if (!mybullet.ammount4)
					flashent.ammount4 = 256;
				
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}


void misc_fire_crossbowbolt_init()
{
	if(self.target != "")
		self.enemy = find(world, targetname, self.target);
}

/*QUAKED spawnfunc_misc_fire_crossbowbolt (.5 .5 .5) ? START_ON DEST_IS_FIXED
Fires a crossbow bolt
Can also fire other things.
Keys:
"target"
Where to fire the shot at (a target_position or so)
"targetname"
What triggers this to fire
"cnt"
sets which projectile to fire:
0  crossbow bolt
1  small fireball
2  crylink line
3  electroball
4  laserbolt
5  rocket
6  timed grenade
7  explosives
8  hagar grenade
9  EMP hook grenade
10 Uzi bullet
11 HMG bullet
12 shotgun blast
13 crylink ring
14 electro bolt
15 HLAC bolts
16 grenade
17 nex beam
18 big fireball
19 ballista bolt
20 flamethrower
21 frostthrower
22 poisonthrower
The reason for the mix-and-match listing is so if a mapper
is trying out each one, he will not see too many of the same
effect over and over and then think something is broken or
he has come to the end of the list before he has.
 spawnfunc_target_position where the misc_fire_crossbowbolt ends
*/

void spawnfunc_misc_fire_crossbowbolt()
{
	InitializeEntity(self, misc_fire_crossbowbolt_init, INITPRIO_FINDTARGET);

	self.nohitplotanalysis = 1; //We aren't a player nor are we a bot
	self.noaccuracyfrags = 1;
	
	self.mangle = self.angles;

	misc_laser_aim(); //Good enough for laser, good enough for us.

	switch(self.cnt)
	{
		case 0:
			precache_model ("models/crossbowbolt.md3");
			W_crossbowdtwr_precache_arrowsounds();
			self.use = misc_fire_crossbowbolt_attack;
			break;
		case 1:
			self.use = misc_fire_fireball_attack2;
			break;
		case 2:
			self.use = misc_fire_crylink_attack2;
			break;
		case 3:
			self.use = misc_fire_electro_attack2;
			break;
		case 4:
			self.use = misc_fire_laser_attack;
			break;
		case 5:
			self.use = misc_fire_rocket_attack;
			break;
		case 6:
			self.use = misc_fire_grenade_attack2;
			break;
		case 7:
			self.use = misc_fire_expvest_attack;
			break;
		case 8:
			self.use = misc_fire_hagar_attack;
			break;
		case 9:
			self.use = misc_fire_hook_attack2;
			break;
		case 10:
			self.use = misc_fire_uzibullet;
			break;
		case 11:
			self.use = misc_fire_hmgbullet;
			break;
		case 12:
			self.use = misc_fire_shotgunblast;
			break;
		case 13:
			self.use = misc_fire_crylink_attack;
			break;
		case 14:
			self.use = misc_fire_electro_attack;
			break;
		case 15:
			self.use = misc_fire_hlac_attack2;
			break;	
		case 16:
			self.use = misc_fire_grenade_attack;
			break;
		case 17:
			self.use = misc_fire_nex_attack;
			break;
		case 18:
			self.use = misc_fire_fireball_attack1;
			break;
		case 19:
			self.use = misc_fire_fireBallistaBolt;
			break;
		case 20:
			self.use = misc_fire_fireFlameThrower;
			break;
		case 21:
			self.use = misc_fire_fireFrostThrower;
			break;
		case 22:
			self.use = misc_fire_firePoisonThrower;
			break;
		default:
			precache_model ("models/crossbowbolt.md3");
			W_crossbowdtwr_precache_arrowsounds();
			self.use = misc_fire_crossbowbolt_attack;
			break;
	}
	
}

