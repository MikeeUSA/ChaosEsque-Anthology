#define EINDECKER_MIN '-70 -70 0'
#define EINDECKER_MAX '70 70 120'

const vector EINDECKERROTOR_MIN_HBF_T = '-10 -10 -40'; //Back and front trunk for this model
const vector EINDECKERROTOR_MAX_HBF_T = '10 10 40';

const vector EINDECKERROTOR_MIN_HBB_T = '-10 -10 -60'; //Middle
const vector EINDECKERROTOR_MAX_HBB_T = '10 10 60';

#ifdef SVQC
float autocvar_g_vehicle_eindecker;

float autocvar_g_vehicle_eindecker_mass;

float autocvar_g_vehicle_eindecker_respawntime;
float autocvar_g_vehicle_eindecker_takeofftime;

float autocvar_g_vehicle_eindecker_movestyle;
float autocvar_g_vehicle_eindecker_turnspeed;
float autocvar_g_vehicle_eindecker_pitchspeed;
float autocvar_g_vehicle_eindecker_pitchlimit;

float autocvar_g_vehicle_eindecker_speed_forward;
float autocvar_g_vehicle_eindecker_speed_strafe;
float autocvar_g_vehicle_eindecker_speed_up;
float autocvar_g_vehicle_eindecker_speed_down;
float autocvar_g_vehicle_eindecker_friction;

float autocvar_g_vehicle_eindecker_cannon_refire;

float autocvar_g_vehicle_eindecker_cannon_expelbulletcasings;

float autocvar_g_vehicle_eindecker_cannon_spread;
float autocvar_g_vehicle_eindecker_cannon_speed;
float autocvar_g_vehicle_eindecker_cannon_damage; 
float autocvar_g_vehicle_eindecker_cannon_headshotbonus; 
float autocvar_g_vehicle_eindecker_cannon_force; 
float autocvar_g_vehicle_eindecker_cannon_bulletconstant; 
float autocvar_g_vehicle_eindecker_cannon_coreshotbonus;


float autocvar_g_vehicle_eindecker_bombs_ammo_cost;
float autocvar_g_vehicle_eindecker_bombs_ammo_max;
float autocvar_g_vehicle_eindecker_bombs_ammo_regen;
float autocvar_g_vehicle_eindecker_bombs_ammo_regen_pause;

float autocvar_g_vehicle_eindecker_bombs_refire;
float autocvar_g_vehicle_eindecker_bomb1_fragments;
float autocvar_g_vehicle_eindecker_bomb2_fragments;

float autocvar_g_vehicle_eindecker_flare_range;

float autocvar_g_vehicle_eindecker_energy;
float autocvar_g_vehicle_eindecker_energy_regen;
float autocvar_g_vehicle_eindecker_energy_regen_pause;

float autocvar_g_vehicle_eindecker_health;
float autocvar_g_vehicle_eindecker_health_regen;
float autocvar_g_vehicle_eindecker_health_regen_pause;

float autocvar_g_vehicle_eindecker_shield;
float autocvar_g_vehicle_eindecker_shield_regen;
float autocvar_g_vehicle_eindecker_shield_regen_pause;

float autocvar_g_vehicle_eindecker_bouncefactor;
float autocvar_g_vehicle_eindecker_bouncestop;
vector autocvar_g_vehicle_eindecker_bouncepain;

void eindecker_spawn(float);
float eindecker_frame();
float eindecker_takeoff();


void mg_maxim_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, string tagname);

//EINDECKER GRENADE STUFF
void eindecker_Grenade_FragsOverTime (void)
{
	//print("Here\n");
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_primary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_primary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_primary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_primary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_primary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_primary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_primary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();
	}
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_vehicle_eindecker_bomb1_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void eindecker_Grenade_FragsOverTime2 (void)
{
	//print("Here2\n");
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();
	}
	//Finish Grenade Fragmentation
	
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_vehicle_eindecker_bomb2_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void eindecker_Grenade_FragsOverTimeSpawn (entity gren, float type)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	if (type == 0)
	{
		e.think = eindecker_Grenade_FragsOverTime;
		e.count = floor(autocvar_g_vehicle_eindecker_bomb1_fragments / autocvar_g_balance_grenadelauncher_primary_fragments_frames)+1;
	} else {
		e.think = eindecker_Grenade_FragsOverTime2;
		e.count = floor(autocvar_g_vehicle_eindecker_bomb2_fragments / autocvar_g_balance_grenadelauncher_secondary_fragments_frames)+1;
	}
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void eindecker_Grenade_Explode (void)
{
	if(autocvar_g_balance_grenadelauncher_primary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_primary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade was a dud\n");
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

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rocketlauncher_damage, autocvar_g_balance_rocketlauncher_edgedamage, autocvar_g_balance_rocketlauncher_radius, world, autocvar_g_balance_grenadelauncher_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	
	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_primary_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_eindecker_bomb1_fragments;sc = sc + 1) {
	
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_primary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_primary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_primary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_primary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_primary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_primary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_primary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();
		}
	} else {
		eindecker_Grenade_FragsOverTimeSpawn(self, 0); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

void eindecker_Grenade_Explode2 (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade failed to detonate\n");
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

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rocketlauncher_damage, autocvar_g_balance_rocketlauncher_edgedamage, autocvar_g_balance_rocketlauncher_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);

	
	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_secondary_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_eindecker_bomb2_fragments;sc = sc + 1) {
	
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();
		}
	} else {
		eindecker_Grenade_FragsOverTimeSpawn(self, 1); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

void eindecker_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void eindecker_Grenade_Think1 (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		eindecker_Grenade_Explode ();
		return;
	}
	if(self.gl_detonate_later && self.gl_bouncecnt >= autocvar_g_balance_grenadelauncher_primary_remote_minbouncecnt)
		eindecker_Grenade_Explode();
}

void eindecker_Grenade_Touch1 (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void eindecker_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM || autocvar_g_balance_grenadelauncher_secondary_type == 0) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else // bounce
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.gl_bouncecnt += 1;
		
		if (autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce && self.gl_bouncecnt == 1)
			self.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce;
			
	}
}

//ENDEINDECKERGRENADE STUFF

void eindecker_drop_nade1(string tagname, entity who)
{
    vector v;

    v = gettaginfo(who, gettagindex(who, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;

	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_primary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_grenadelauncher_primary_lifetime;
	gren.nextthink = time;
	gren.think = eindecker_Grenade_Think1;
	gren.use = eindecker_Grenade_Explode;
	gren.touch = eindecker_Grenade_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_primary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_primary_damageforcescale;
	gren.event_damage = eindecker_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;


	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;
	gren.gravity = 2;

	if(autocvar_g_balance_grenadelauncher_primary_type == 0 || autocvar_g_balance_grenadelauncher_primary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void eindecker_drop_nade2(string tagname, entity who)
{
    vector v;

    v = gettaginfo(who, gettagindex(who, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = eindecker_Grenade_Explode2;
	gren.touch = eindecker_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = eindecker_Grenade_Damage;
	gren.damagedbycontents = TRUE;

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void eindecker_fire_cannon(string tagname)
{
    vector v;
    entity _oldself = self;

    v = gettaginfo(self, gettagindex(self, tagname));
    
    //print(etos(self)," self and owner ",  etos(self.owner), "\n");
    self = self.owner;
  
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_eindecker_cannon_spread, autocvar_g_vehicle_eindecker_cannon_speed, 5, autocvar_g_vehicle_eindecker_cannon_damage, autocvar_g_vehicle_eindecker_cannon_headshotbonus, autocvar_g_vehicle_eindecker_cannon_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_eindecker_cannon_bulletconstant, autocvar_g_vehicle_eindecker_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    self = _oldself;
    
    sound (self, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
}

float eindecker_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

//Fire Cannon removed

void eindecker_think()
{
}


void eindecker_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_WAKIBLOWUP, world);

    self.alpha          = -1;
    self.movetype       = MOVETYPE_NONE;
    self.effects        = EF_NODRAW;
    self.colormod       = '0 0 0';
    self.avelocity      = '0 0 0';
    self.velocity       = '0 0 0';

    setorigin(self, self.pos1);
    self.touch = func_null;
    self.nextthink = 0;
}

void eindecker_diethink()
{
	if(time >= self.wait)
		self.think = eindecker_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void eindecker_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = eindecker_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = eindecker_blowup;
	
	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxftd1); 
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
}

void eindecker_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = eindecker_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_eindecker_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_eindecker_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_eindecker_bombs_refire;
    self.lip   = time;
    

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void eindecker_land()
{    
    float hgt;
        
    hgt = eindecker_altitude(512);    
    //self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    //self.velocity = (self.velocity * 1) + ('0 0 -200' * (hgt / 256) * sys_frametime);
    self.velocity = (self.velocity * 1) + ('0 0 -200' * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.99;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun2.avelocity_y = -90 - ((self.frame / 25) * 2000);
    self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y;

    if(hgt < 16)
    {
    	//If we're tipped to much we'll crash and be destroyed
    	if(
	(self.angles_z >= 55 && self.angles_z <= 180) ||
	(self.angles_z <= -55 && self.angles_z >= -180))
	{
		Damage(self, self, self.owner, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} else {
	        self.think    = eindecker_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void eindecker_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.bomb1.gun1.count = 0;
        self.think      = eindecker_land;
        self.nextthink  = time;
    }

    if not (self.owner)
        return;
	
	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > 2 * autocvar_sv_maxairspeed)
		{
			self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed * 2;
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 32 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);	
    self.owner = world;
}

float eindecker_takeoff()
{
    entity player, eindecker;
    
    player = self;
    eindecker = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (eindecker.bomb1.gun1.count == 0)) {
	    	eindecker.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (eindecker.bomb1.gun1.count == 1)) {
	  	eindecker.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = eindecker;
    if(self.sound_nexttime < time)
    {       
        if (eindecker.bomb1.gun1.count) { 
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }   

    // Takeoff sequense
    if(eindecker.bomb1.gun1.count == 1) {
    if(eindecker.frame < 25)
    {
    	makevectors(eindecker.angles);
    	eindecker.movetype       = MOVETYPE_WALK;
        eindecker.frame += 25 / (autocvar_g_vehicle_eindecker_takeofftime / sys_frametime);
        if(eindecker.frame > 23)
		eindecker.velocity_z = min(1 + (eindecker.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = -90 - ((eindecker.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_eindecker_speed_forward * 0.32 * (eindecker.frame/25),0.075);
    }
    else
    {
    	eindecker.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = eindecker_frame;
    }
    } else {
    	//Engine off?
    	eindecker.movetype     = MOVETYPE_BOUNCE;
    	if (eindecker.frame > 0) {
        	eindecker.frame -= 25 / (autocvar_g_vehicle_eindecker_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = -90 - ((eindecker.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(eindecker.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(eindecker.angles_z >= 55 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -55 && eindecker.angles_z >= -180))
	{
		Damage(eindecker, eindecker, player, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 
    
    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(eindecker, eindecker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    
    setorigin(player, eindecker.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(eindecker.dmg_time, vehicle_shield, autocvar_g_vehicle_eindecker_shield, autocvar_g_vehicle_eindecker_shield_regen_pause, autocvar_g_vehicle_eindecker_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(eindecker.dmg_time, vehicle_health, autocvar_g_vehicle_eindecker_health, autocvar_g_vehicle_eindecker_health_regen_pause, autocvar_g_vehicle_eindecker_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (eindecker.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(eindecker.cnt, vehicle_energy, autocvar_g_vehicle_eindecker_energy, autocvar_g_vehicle_eindecker_energy_regen_pause, autocvar_g_vehicle_eindecker_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
    	//Add
    	vehicles_regen(eindecker.ammount3, vehicle_ammo2, autocvar_g_vehicle_eindecker_bombs_ammo_max,
                                           autocvar_g_vehicle_eindecker_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_eindecker_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		eindecker.count = 1;
		sound (eindecker, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, eindecker, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
    			
			
			vehicles_replenishAmmo(player, eindecker, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
    }

    ////eindecker.bomb1.alpha = eindecker.bomb2.alpha = eindecker.bomb3.alpha = eindecker.bomb4.alpha = eindecker.bomb5.alpha = eindecker.bomb6.alpha = eindecker.bomb7.alpha = eindecker.bomb8.alpha = eindecker.bomb9.alpha = eindecker.bomb10.alpha = eindecker.bomb11.alpha = eindecker.bomb12.alpha = eindecker.bomb13.alpha = eindecker.bomb14.alpha = eindecker.bomb15.alpha = eindecker.bomb16.alpha = eindecker.bomb17.alpha = eindecker.bomb18.alpha = (time - eindecker.lip) / (eindecker.delay - eindecker.lip);
    eindecker.bomb1.alpha = (time - eindecker.lip) / (eindecker.delay - eindecker.lip);
    ////player.vehicle_reload2 = bound(0, eindecker.bomb1.alpha * 100, 100);
    
    VEHICLE_UPDATE_PLAYER(player, health, eindecker);
    VEHICLE_UPDATE_PLAYER(player, energy, eindecker);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, eindecker);

    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(eindecker, eindecker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

//Flare Stuff removed

float eindecker_frame()
{
    entity player, eindecker;
    float altcontrols = 0;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    altcontrols = player.vehicle_alternateaircontrols;
    eindecker = self.vehicle;
    self   = eindecker;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_eindecker_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_eindecker_speed_forward;
    */
        
    if(self.sound_nexttime < time)
    {        
        self.sound_nexttime = time + 7.955812; 
        //sound (self.tur_head, CH_TRIGGER_SINGLE, "vehicles/raptor_fly.wav", 1 - ftmp,   ATTN_NORM );
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", 1, ATTN_NORM);        
        self.wait = ftmp;
    }        
    /*
    else if(fabs(ftmp - self.wait) > 0.2)
    {
        sound (self.tur_head, CH_TRIGGER_SINGLE, "", 1 - ftmp,   ATTN_NORM );
        sound (self, CH_TRIGGER_SINGLE, "", ftmp, ATTN_NORM);        
        self.wait = ftmp;
    }
    */
    
    if(eindecker.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = eindecker.angles;
    df = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
    vang_x *= -1;
    df_x *= -1;
    if(df_x > 180)  df_x -= 360;
    if(df_x < -180) df_x += 360;
    if(df_y > 180)  df_y -= 360;
    if(df_y < -180) df_y += 360;

    if not(player.waterlevel == WATERLEVEL_SUBMERGED)
    {
    //Got to do it this way as vehicles waterlevel is always 1
    //Thus we check players water level instead.
    /////////////////////////////////////////////////////////////////////////
    //BEGIN If not in water
    /////////////////////////////////////////////////////////////////////////
    
    if (altcontrols) {
    	////Alternative Flight controls (no mouse use needed)
    	// A,D = Turn
	// W,S = Point up, point down
	// Shift A,D = Roll
	// Shift W,S = Speed/Slow
	// Jump (same) rise in altitude
	// Shift (same) lower altitude
	ftmp = 0;
    	if(player.movement_y != 0 && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_y * -1 * autocvar_g_vehicle_eindecker_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	eindecker.avelocity_y = bound(-autocvar_g_vehicle_eindecker_turnspeed, ftmp + eindecker.avelocity_y * 0.9, autocvar_g_vehicle_eindecker_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(player.movement_x != 0 && !player.BUTTON_HOOK && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_x * -1 * autocvar_g_vehicle_eindecker_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	eindecker.avelocity_x = bound(-autocvar_g_vehicle_eindecker_pitchspeed, ftmp + eindecker.avelocity_x * 0.9, autocvar_g_vehicle_eindecker_pitchspeed);
    	
	
	
	if(eindecker.angles_y > 180)  eindecker.angles_y -= 360;
    	if(eindecker.angles_y < -180) eindecker.angles_y += 360;
	
		if(eindecker.angles_y >= -1 && eindecker.angles_y <= -1)
            	eindecker.angles_y = 0;
		
	if(eindecker.angles_x > 180)  eindecker.angles_x -= 360;
    	if(eindecker.angles_x < -180) eindecker.angles_x += 360;
	
	
		if(eindecker.angles_x >= -1 && eindecker.angles_x <= -1)
            	eindecker.angles_x = 0;
		
	if(eindecker.angles_z > 180)  eindecker.angles_z -= 360;
    	if(eindecker.angles_z < -180) eindecker.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    eindecker.avelocity_y = bound(-autocvar_g_vehicle_eindecker_turnspeed, ftmp + eindecker.avelocity_y * 0.9, autocvar_g_vehicle_eindecker_turnspeed);

    // Pitch
    ftmp = 0;
    if not(player.BUTTON_HOOK) {
    	if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_eindecker_pitchlimit) ftmp = 5;
    	else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_eindecker_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_eindecker_pitchlimit, df_x , autocvar_g_vehicle_eindecker_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_eindecker_pitchlimit, df_x + ftmp, autocvar_g_vehicle_eindecker_pitchlimit);
    eindecker.avelocity_x = bound(-autocvar_g_vehicle_eindecker_pitchspeed, ftmp + eindecker.avelocity_x * 0.9, autocvar_g_vehicle_eindecker_pitchspeed);

    
    //END
    ///////////////
    }
    
    
    eindecker.angles_x = anglemods(eindecker.angles_x);
    eindecker.angles_y = anglemods(eindecker.angles_y);
    eindecker.angles_z = anglemods(eindecker.angles_z);

    if(autocvar_g_vehicle_eindecker_movestyle == 1)
        makevectors('0 1 0' * eindecker.angles_y);
    else
        makevectors(player.v_angle);

    df = eindecker.velocity * -autocvar_g_vehicle_eindecker_friction;

	//print(sprintf("m1 = %f\n", v_forward));
    if(player.BUTTON_HOOK) {
    		if(player.movement_x > 0) {
    	    		eindecker.bomb1.gun2.count = bound(autocvar_g_vehicle_eindecker_speed_forward * 0.32, eindecker.bomb1.gun2.count + (128 * sys_frametime),autocvar_g_vehicle_eindecker_speed_forward);
    			if((eindecker.bomb1.gun2.pushltime < time) && !(eindecker.bomb1.gun2.count >= autocvar_g_vehicle_eindecker_speed_forward))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Raised to %f\n", (eindecker.bomb1.gun2.count/autocvar_g_vehicle_eindecker_speed_forward)));
    				eindecker.bomb1.gun2.pushltime = time + 0.25;
			}
		} else if(player.movement_x < 0) {
    	    		eindecker.bomb1.gun2.count = bound(autocvar_g_vehicle_eindecker_speed_forward * 0.32, eindecker.bomb1.gun2.count - (128 * sys_frametime),autocvar_g_vehicle_eindecker_speed_forward);
    			if((eindecker.bomb1.gun2.pushltime < time) && !(eindecker.bomb1.gun2.count <= autocvar_g_vehicle_eindecker_speed_forward * 0.32))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Lowered to %f\n", (eindecker.bomb1.gun2.count/autocvar_g_vehicle_eindecker_speed_forward)));
    				eindecker.bomb1.gun2.pushltime = time + 0.25;
			}
        
   			if(eindecker_altitude(512) < 16)
				player.PlayerPhysplug = eindecker_takeoff;
		}	 
    } else {
    if((player.movement_x != 0 && !altcontrols)
    ||(player.movement_x != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_eindecker_speed_forward;
        else if(player.movement_x < 0)
          //df -= v_forward  * autocvar_g_vehicle_eindecker_speed_forward;
	  df += v_forward  * (autocvar_g_vehicle_eindecker_speed_forward * 0.32);
    }
    }
    
    
    
    if(((player.movement_x == 0 && !altcontrols) || (player.movement_x == 0 && altcontrols && !player.BUTTON_CROUCH))
    || (player.BUTTON_HOOK)) {
    	df += v_forward  * eindecker.bomb1.gun2.count;
    }



    if((player.movement_y != 0 && !altcontrols)
    ||(player.movement_y != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_eindecker_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_eindecker_speed_strafe;

	eindecker.angles_z = bound(-360,eindecker.angles_z + ((player.movement_y * 0.85 * sys_frametime) / autocvar_g_vehicle_eindecker_speed_strafe),360);
    	//Abit slower then nieuport for roll: * 0.85
    }
    else
    {
    	//Stable inverted flight
	if(
	(eindecker.angles_z >= 179 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -179 && eindecker.angles_z >= -180))
	{
		eindecker.angles_z = 180;
	} else if(
	(eindecker.angles_z >= 176 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -176 && eindecker.angles_z >= -180))
	{
		eindecker.angles_z *= 1.001;
	} else if(
	(eindecker.angles_z >= 170 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -170 && eindecker.angles_z >= -180))
	{
		eindecker.angles_z *= 1.005;
	} else if(
	(eindecker.angles_z >= 150 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -150 && eindecker.angles_z >= -180))
	{
		eindecker.angles_z *= 1.01;
	} else if(
	(eindecker.angles_z >= 100 && eindecker.angles_z <= 180) ||
	(eindecker.angles_z <= -100 && eindecker.angles_z >= -180))
	{
		eindecker.angles_z *= 1.025;	
	} else {
       		eindecker.angles_z *= 0.95;
	}
        if(eindecker.angles_z >= -1 && eindecker.angles_z <= -1)
            eindecker.angles_z = 0;
    }



    if((player.BUTTON_CROUCH && !altcontrols)
    ||(player.BUTTON_CROUCH && altcontrols && !player.movement_y && !player.movement_x)) {
        df -=   v_up * autocvar_g_vehicle_eindecker_speed_down;
    } else if ((player.BUTTON_JUMP && !altcontrols)
    || (player.BUTTON_JUMP && altcontrols && !player.movement_y && !player.movement_x))
    {
        df +=  v_up * autocvar_g_vehicle_eindecker_speed_up;
    }
    
    

    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	eindecker.avelocity_x = 0;
	eindecker.avelocity_y = 0;
	eindecker.avelocity_z = 0;
    }
    
    
    
    if (altcontrols) {
	player.v_angle_x = eindecker.angles_x * -1;
	player.v_angle_y = eindecker.angles_y;
	player.v_angle_z = eindecker.angles_z; //kiss
	
	player.angles_x = eindecker.angles_x;
	player.angles_y = eindecker.angles_y;
	player.angles_z = eindecker.angles_z; //for completion

	if ((clienttype(player) == CLIENTTYPE_REAL)) {
		msg_entity = player;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, player.v_angle_x);
		WriteAngle( MSG_ONE, player.v_angle_y);
  		WriteAngle( MSG_ONE, player.v_angle_z);
	}
    }
        
    
    df = vehicles_waterspeed(player, df);
    eindecker.velocity = vehicles_waterfriction(player, eindecker, eindecker.velocity);
    eindecker.velocity  += df * frametime;
    player.velocity = player.movement  = eindecker.velocity;
    setorigin(player, eindecker.origin + '0 0 32');
    
    //Cannon firing 
    if(player.BUTTON_ATCK)
    if(time > eindecker.attack_finished_single)
    if(eindecker.vehicle_energy >= autocvar_g_vehicle_sportster_cannon_cost)
    {
        eindecker.vehicle_energy -= autocvar_g_vehicle_sportster_cannon_cost;
        eindecker.wait = time;

        crosshair_trace(player);
	
        eindecker_fire_cannon("tag_mgun");
	UziFlash();
	sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_mgun");
	if (autocvar_g_casings >= 2) {
		if (autocvar_g_vehicle_eindecker_cannon_expelbulletcasings) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right *-1) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 105, eindecker, "tag_casings");
		}
	}
        
        eindecker.attack_finished_single = time + autocvar_g_vehicle_eindecker_cannon_refire;
	eindecker.count = 0; //Will have to press R to resume reload
    }


    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(eindecker.dmg_time, vehicle_shield, autocvar_g_vehicle_eindecker_shield, autocvar_g_vehicle_eindecker_shield_regen_pause, autocvar_g_vehicle_eindecker_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(eindecker.dmg_time, vehicle_health, autocvar_g_vehicle_eindecker_health, autocvar_g_vehicle_eindecker_health_regen_pause, autocvar_g_vehicle_eindecker_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (eindecker.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(eindecker.cnt, vehicle_energy, autocvar_g_vehicle_eindecker_energy, autocvar_g_vehicle_eindecker_energy_regen_pause, autocvar_g_vehicle_eindecker_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
    	//Add
    	vehicles_regen(eindecker.ammount3, vehicle_ammo2, autocvar_g_vehicle_eindecker_bombs_ammo_max,
                                           autocvar_g_vehicle_eindecker_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_eindecker_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		eindecker.count = 1;
		sound (eindecker, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, eindecker, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
			
			//Add
			vehicles_replenishAmmo(player, eindecker, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
		
    }
    
    //Add
    if(player.BUTTON_ATCK2)
    {
    	//print(ftos(eindecker.vehicle_ammo2), "_a2_", ftos(autocvar_g_vehicle_eindecker_bombs_ammo_cost), "_ac_", ftos(eindecker.vehicle_ammo2_current), "_cur_", ftos(eindecker.vehicle_ammo2_max), "_max\n");
	eindecker.ammount3 = time; //.cnt
        if(eindecker.vehicle_ammo2 >= autocvar_g_vehicle_eindecker_bombs_ammo_cost && eindecker.bomb1.attack_finished_single <= time)
        {
	    if (random() > 0.5) {
	    	eindecker_drop_nade1("bombmount_center1", eindecker);
	    } else {
	   	eindecker_drop_nade2("bombmount_center1", eindecker);
	    }
	    
	    eindecker.vehicle_ammo2 -= autocvar_g_vehicle_eindecker_bombs_ammo_cost;
            eindecker.bomb1.attack_finished_single = time + autocvar_g_vehicle_eindecker_bombs_refire; //Changed from tur_head
	    
	    eindecker.count = 0; //Will have to press R to resume reload
			    
	    eindecker.bomb1.alpha = 0.000001; 
	}
    }
    
    if (eindecker.bomb1.alpha < 1) {
    	//1-((futuretime-currenttime)/addedtime)
 	eindecker.bomb1.alpha = ( 1 - ((eindecker.bomb1.attack_finished_single - time) / autocvar_g_vehicle_eindecker_bombs_refire) );
    }
    //Added 
    

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, eindecker);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_eindecker_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

    VEHICLE_UPDATE_PLAYER(player, health, eindecker);
    VEHICLE_UPDATE_PLAYER(player, energy, eindecker);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, eindecker);


    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(eindecker, eindecker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    player.vehicle_ammo1_current = eindecker.vehicle_ammo1_current;
    player.vehicle_ammo1_max = eindecker.vehicle_ammo1_max;
    player.vehicle_ammo2_current = eindecker.vehicle_ammo2_current;
    player.vehicle_ammo2_max = eindecker.vehicle_ammo2_max;
    
    //For the bomb reload bar;
    if(eindecker.vehicle_ammo2 > 0)
    {
    	//pressed reload
    	if (time > eindecker.bomb1.attack_finished_single) {
    		player.vehicle_reload2 = 100;
    	} else {
    		player.vehicle_reload2 = bound(0, 
     		( 1 - ((eindecker.bomb1.attack_finished_single - time) / autocvar_g_vehicle_eindecker_bombs_refire) ) * 100,
     		100);
    	}
    } else {
    	player.vehicle_reload2 = 0;
    }
    //Done bomb reloading bar
    
    self = player;
    return 1;
}

void eindecker_impact()
{
    if(autocvar_g_vehicle_eindecker_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_eindecker_bouncepain_x, autocvar_g_vehicle_eindecker_bouncepain_y, autocvar_g_vehicle_eindecker_bouncepain_z);
}

// If we dont do this ever now and then, the eindeckers rotors
// stop working, presumably due to angle overflow. cute.
void eindecker_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void eindecker_spawn(float _f)
{
    if(!self.gun1)
    {
    	self.loddistance1 = 256; //Lod0 Model somewhat complex, so only use when very close
	self.loddistance2 = 512;
	self.loddistance3 = 1024;
	
    	self.lodmodel1 = "models/vehicles/eindeckeredits_lod1.iqm";
	self.lodmodel2 = "models/vehicles/eindeckeredits_lod2.iqm";
	self.lodmodel3 = "models/vehicles/eindeckeredits_lod3.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = eindecker_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        //self.bomb2 = spawn();
	//self.bomb3 = spawn();
        //self.bomb4 = spawn();
	//self.bomb5 = spawn();
        //self.bomb6 = spawn();
	//self.bomb7 = spawn();
        //self.bomb8 = spawn();
	//self.bomb9 = spawn();
        //self.bomb10 = spawn();
	//self.bomb11 = spawn();
        //self.bomb12 = spawn();
	//self.bomb13 = spawn();
        //self.bomb14 = spawn();
	//self.bomb15 = spawn();
        //self.bomb16 = spawn();
	//self.bomb17 = spawn();
        //self.bomb18 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"models/grenademodel.md3");
        //setmodel(self.bomb2,"models/grenademodel.md3");
	//setmodel(self.bomb3,"models/grenademodel.md3");
        //setmodel(self.bomb4,"models/grenademodel.md3");
	//setmodel(self.bomb5,"models/grenademodel.md3");
        //setmodel(self.bomb6,"models/grenademodel.md3");
	
	//setmodel(self.bomb7,"models/grenademodel.md3");
        //setmodel(self.bomb8,"models/grenademodel.md3");
	//setmodel(self.bomb9,"models/grenademodel.md3");
        //setmodel(self.bomb10,"models/grenademodel.md3");
	//setmodel(self.bomb11,"models/grenademodel.md3");
        //setmodel(self.bomb12,"models/grenademodel.md3");
	
	//setmodel(self.bomb13,"models/grenademodel.md3");
        //setmodel(self.bomb14,"models/grenademodel.md3");
	//setmodel(self.bomb15,"models/grenademodel.md3");
        //setmodel(self.bomb16,"models/grenademodel.md3");
	//setmodel(self.bomb17,"models/grenademodel.md3");
        //setmodel(self.bomb18,"models/grenademodel.md3");
	
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/eindeckeredits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_center1");
        //setattachment(self.bomb2, self, "bombmount_center2");
	//setattachment(self.bomb3, self, "bombmount_center3");
        //setattachment(self.bomb4, self, "bombmount_center4");
	//setattachment(self.bomb5, self, "bombmount_center5");
        //setattachment(self.bomb6, self, "bombmount_center6");
	
	//setattachment(self.bomb7, self, "bombmount_center7");
        //setattachment(self.bomb8, self, "bombmount_center8");
	//setattachment(self.bomb9, self, "bombmount_center9");
        //setattachment(self.bomb10, self, "bombmount_center10");
	//setattachment(self.bomb11, self, "bombmount_center11");
        //setattachment(self.bomb12, self, "bombmount_center12");
	
	//setattachment(self.bomb13, self, "bombmount_center13");
        //setattachment(self.bomb14, self, "bombmount_center14");
	//setattachment(self.bomb15, self, "bombmount_center15");
        //setattachment(self.bomb16, self, "bombmount_center16");
	//setattachment(self.bomb17, self, "bombmount_center17");
        //setattachment(self.bomb18, self, "bombmount_center18");
        ////setattachment(self.tur_head, self,"root");

        // FIXMODEL Guns mounts to angled bones
        self.bomb1.angles = self.angles;
        self.angles = '0 0 0';
        // This messes up gun-aim, so work arround it.
        //setattachment(self.gun1, self, "gunmount_left");
        ofs = gettaginfo(self, gettagindex(self, "gunmount_left"));
        ofs -= self.origin;
        setattachment(self.gun1, self, "");
        setorigin(self.gun1, ofs);

        //setattachment(self.gun2, self, "gunmount_right");
        ofs = gettaginfo(self, gettagindex(self, "gunmount_right"));
        ofs -= self.origin;
        setattachment(self.gun2, self, "");
        setorigin(self.gun2, ofs);

        self.angles = self.bomb1.angles;
        self.bomb1.angles = '0 0 0';

        spinner = spawn();
        spinner.owner = self;
	spinner.lodowner = 1; //Use owner origin for computing LOD
	spinner.lodmodel1 = "models/vehicles/eindecker_spinner_lod1.iqm";
	spinner.lodmodel2 = "models/vehicles/eindecker_spinner_lod2.iqm";
	spinner.lodmodel3 = "models/vehicles/eindecker_spinner_lod3.iqm";
        setmodel(spinner,"models/vehicles/eindecker_spinner.iqm");
	InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	////spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        //setmodel(spinner,"models/vehicles/eindecker_spinner.iqm");
        //setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = eindecker_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_eindecker_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxftd1 = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.bomb1.gun1.count = 0;
	self.bomb1.gun2.count = autocvar_g_vehicle_eindecker_speed_forward * 0.6;
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_eindecker_health;
    self.vehicle_shield = autocvar_g_vehicle_eindecker_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = -90; //Opposite
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, EINDECKER_MIN, EINDECKER_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_eindecker_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_eindecker_bouncestop;    
    self.vehicle_impact = eindecker_impact;    
    self.damageforcescale = 0.25;
    
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly
	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxft, EINDECKERROTOR_MIN_HBF_T, EINDECKERROTOR_MAX_HBF_T, 0, 50, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmf, EINDECKERROTOR_MIN_HBB_T, EINDECKERROTOR_MAX_HBB_T, 0, 20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxftd1, EINDECKERROTOR_MIN_HBB_T, EINDECKERROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmb, EINDECKERROTOR_MIN_HBB_T, EINDECKERROTOR_MAX_HBB_T, 0, -20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxbk, EINDECKERROTOR_MIN_HBF_T, EINDECKERROTOR_MAX_HBF_T, 0, -50, 0);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_eindecker()
{
    if(!autocvar_g_vehicle_eindecker)
    {
        remove(self);
        return;
    }  
    
    if (autocvar_g_delete_vehicles >= 1) {
		if (time < game_starttime + autocvar_g_delete_vehicles_time)
		{
			remove(self);
			return;
		}
    }      
    
    self.vehicle_flags |= VHF_DMGSHAKE;
    self.vehicle_flags |= VHF_DMGROLL;
   
    if(autocvar_g_vehicle_eindecker_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_eindecker_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_eindecker_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_eindecker_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/eindeckeredits.iqm");
    precache_model ("models/vehicles/eindeckeredits_lod1.iqm");
    precache_model ("models/vehicles/eindeckeredits_lod2.iqm");
    precache_model ("models/vehicles/eindeckeredits_lod3.iqm");
    precache_model ("models/vehicles/eindecker_spinner.iqm");
    precache_model ("models/vehicles/eindecker_spinner_lod1.iqm");
    precache_model ("models/vehicles/eindecker_spinner_lod2.iqm");
    precache_model ("models/vehicles/eindecker_spinner_lod3.iqm");
    
    precache_model ("models/grenademodel.md3");
    precache_model ("models/vhshield.md3");
    
    precache_sound ("vehicles/raptor_fly.wav");
    precache_sound ("vehicles/raptor_speed.wav");
    precache_sound ("vehicles/missile_alarm.wav");
    precache_sound ("weapons/campingrifle_fire.wav");
    precache_sound ( "weapons/rocket_impact.wav");


	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
		    
    if not (vehicle_initialize(
             "Eindecker",
             "models/vehicles/eindeckeredits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_AEROPLANE,
             EINDECKER_MIN, EINDECKER_MAX,
             FALSE,
             eindecker_spawn, autocvar_g_vehicle_eindecker_respawntime,
             eindecker_frame,
             eindecker_enter, eindecker_exit,
             eindecker_die,   eindecker_think,
             FALSE, 
             autocvar_g_vehicle_eindecker_health,
             autocvar_g_vehicle_eindecker_shield, autocolor, autocvar_g_vehicle_nieuport_energy * 5, floor(autocvar_g_vehicle_eindecker_bombs_ammo_max * 2.3)))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
