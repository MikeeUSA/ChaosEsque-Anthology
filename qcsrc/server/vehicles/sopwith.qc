#define SOPWITH_MIN '-70 -70 0'
#define SOPWITH_MAX '70 70 120'

const vector SOPWITHROTOR_MIN_HBF_T = '-10 -10 -40'; //Back and front trunk for this model
const vector SOPWITHROTOR_MAX_HBF_T = '10 10 40';

const vector SOPWITHROTOR_MIN_HBB_T = '-10 -10 -60'; //Middle
const vector SOPWITHROTOR_MAX_HBB_T = '10 10 60';

#ifdef SVQC
float autocvar_g_vehicle_sopwith;

float autocvar_g_vehicle_sopwith_mass;

float autocvar_g_vehicle_sopwith_respawntime;
float autocvar_g_vehicle_sopwith_takeofftime;

float autocvar_g_vehicle_sopwith_movestyle;
float autocvar_g_vehicle_sopwith_turnspeed;
float autocvar_g_vehicle_sopwith_pitchspeed;
float autocvar_g_vehicle_sopwith_pitchlimit;

float autocvar_g_vehicle_sopwith_speed_forward;
float autocvar_g_vehicle_sopwith_speed_strafe;
float autocvar_g_vehicle_sopwith_speed_up;
float autocvar_g_vehicle_sopwith_speed_down;
float autocvar_g_vehicle_sopwith_friction;

float autocvar_g_vehicle_sopwith_cannon_refire;

float autocvar_g_vehicle_sopwith_cannon_expelbulletcasings;

float autocvar_g_vehicle_sopwith_cannon_spread;
float autocvar_g_vehicle_sopwith_cannon_speed;
float autocvar_g_vehicle_sopwith_cannon_damage; 
float autocvar_g_vehicle_sopwith_cannon_headshotbonus; 
float autocvar_g_vehicle_sopwith_cannon_force; 
float autocvar_g_vehicle_sopwith_cannon_bulletconstant; 
float autocvar_g_vehicle_sopwith_cannon_coreshotbonus;

float autocvar_g_vehicle_sopwith_bombs_refire;
float autocvar_g_vehicle_sopwith_bomb1_fragments;
float autocvar_g_vehicle_sopwith_bomb2_fragments;

float autocvar_g_vehicle_sopwith_bombs_ammo_cost;
float autocvar_g_vehicle_sopwith_bombs_ammo_max;
float autocvar_g_vehicle_sopwith_bombs_ammo_regen;
float autocvar_g_vehicle_sopwith_bombs_ammo_regen_pause;

float autocvar_g_vehicle_sopwith_flare_range;

float autocvar_g_vehicle_sopwith_energy;
float autocvar_g_vehicle_sopwith_energy_regen;
float autocvar_g_vehicle_sopwith_energy_regen_pause;

float autocvar_g_vehicle_sopwith_health;
float autocvar_g_vehicle_sopwith_health_regen;
float autocvar_g_vehicle_sopwith_health_regen_pause;

float autocvar_g_vehicle_sopwith_shield;
float autocvar_g_vehicle_sopwith_shield_regen;
float autocvar_g_vehicle_sopwith_shield_regen_pause;

float autocvar_g_vehicle_sopwith_bouncefactor;
float autocvar_g_vehicle_sopwith_bouncestop;
vector autocvar_g_vehicle_sopwith_bouncepain;

void sopwith_spawn(float);
float sopwith_frame();
float sopwith_takeoff();

.entity bomb1;
.entity bomb2;
.entity bomb3;
.entity bomb4;
.entity bomb5;
.entity bomb6;

.entity bomb7;
.entity bomb8;
.entity bomb9;
.entity bomb10;
.entity bomb11;
.entity bomb12;

.entity bomb13;
.entity bomb14;
.entity bomb15;
.entity bomb16;
.entity bomb17;
.entity bomb18;

void mg_maxim_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, string tagname);

//SOPWITH GRENADE STUFF
void sopwith_Grenade_FragsOverTime (void)
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
	if (self.cnt >= autocvar_g_vehicle_sopwith_bomb1_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void sopwith_Grenade_FragsOverTime2 (void)
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
	if (self.cnt >= autocvar_g_vehicle_sopwith_bomb2_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void sopwith_Grenade_FragsOverTimeSpawn (entity gren, float type)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	if (type == 0)
	{
		e.think = sopwith_Grenade_FragsOverTime;
		e.count = floor(autocvar_g_vehicle_sopwith_bomb1_fragments / autocvar_g_balance_grenadelauncher_primary_fragments_frames)+1;
	} else {
		e.think = sopwith_Grenade_FragsOverTime2;
		e.count = floor(autocvar_g_vehicle_sopwith_bomb2_fragments / autocvar_g_balance_grenadelauncher_secondary_fragments_frames)+1;
	}
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void sopwith_Grenade_Explode (void)
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_primary_damage, autocvar_g_balance_grenadelauncher_primary_edgedamage, autocvar_g_balance_grenadelauncher_primary_radius, world, autocvar_g_balance_grenadelauncher_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	
	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_primary_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_sopwith_bomb1_fragments;sc = sc + 1) {
	
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
		sopwith_Grenade_FragsOverTimeSpawn(self, 0); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

void sopwith_Grenade_Explode2 (void)
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);

	
	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_secondary_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_sopwith_bomb2_fragments;sc = sc + 1) {
	
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
		sopwith_Grenade_FragsOverTimeSpawn(self, 1); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

void sopwith_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void sopwith_Grenade_Think1 (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		sopwith_Grenade_Explode ();
		return;
	}
	if(self.gl_detonate_later && self.gl_bouncecnt >= autocvar_g_balance_grenadelauncher_primary_remote_minbouncecnt)
		sopwith_Grenade_Explode();
}

void sopwith_Grenade_Touch1 (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void sopwith_Grenade_Touch2 (void)
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

//ENDSOPWITHGRENADE STUFF

void sopwith_drop_nade1(string tagname, entity who)
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
	gren.think = sopwith_Grenade_Think1;
	gren.use = sopwith_Grenade_Explode;
	gren.touch = sopwith_Grenade_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_primary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_primary_damageforcescale;
	gren.event_damage = sopwith_Grenade_Damage;
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

void sopwith_drop_nade2(string tagname, entity who)
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
	gren.use = sopwith_Grenade_Explode2;
	gren.touch = sopwith_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = sopwith_Grenade_Damage;
	gren.damagedbycontents = TRUE;

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void sopwith_fire_cannon(string tagname)
{
    vector v;
    entity _oldself = self;

    v = gettaginfo(self, gettagindex(self, tagname));
    
    //print(etos(self)," self and owner ",  etos(self.owner), "\n");
    self = self.owner;
  
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_sopwith_cannon_spread, autocvar_g_vehicle_sopwith_cannon_speed, 5, autocvar_g_vehicle_sopwith_cannon_damage, autocvar_g_vehicle_sopwith_cannon_headshotbonus, autocvar_g_vehicle_sopwith_cannon_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_sopwith_cannon_bulletconstant, autocvar_g_vehicle_sopwith_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    self = _oldself;
    
    sound (self, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
}

float sopwith_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

//Fire Cannon removed

void sopwith_think()
{
}


void sopwith_blowup()
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

void sopwith_diethink()
{
	if(time >= self.wait)
		self.think = sopwith_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void sopwith_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = sopwith_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = sopwith_blowup;
	
	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxftd1); 
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
}

void sopwith_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = sopwith_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_sopwith_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_sopwith_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_sopwith_bombs_refire;
    self.lip   = time;
    

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void sopwith_land()
{    
    float hgt;
        
    hgt = sopwith_altitude(512);    
    //self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    //self.velocity = (self.velocity * 1) + ('0 0 -200' * (hgt / 256) * sys_frametime);
    self.velocity = (self.velocity * 1) + ('0 0 -200' * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.99;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun2.avelocity_y = 90 + ((self.frame / 25) * 2000);
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
	        self.think    = sopwith_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void sopwith_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.bomb1.gun1.count = 0;
        self.think      = sopwith_land;
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

float sopwith_takeoff()
{
    entity player, sopwith;
    
    player = self;
    sopwith = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (sopwith.bomb1.gun1.count == 0)) {
	    	sopwith.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (sopwith.bomb1.gun1.count == 1)) {
	  	sopwith.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = sopwith;
    if(self.sound_nexttime < time)
    {        
        if (sopwith.bomb1.gun1.count) {
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
    }   

    // Takeoff sequense
    if(sopwith.bomb1.gun1.count == 1) {
    if(sopwith.frame < 25)
    {
    	makevectors(sopwith.angles);
    	sopwith.movetype       = MOVETYPE_WALK;
        sopwith.frame += 25 / (autocvar_g_vehicle_sopwith_takeofftime / sys_frametime);
        if(sopwith.frame > 23)
		sopwith.velocity_z = min(1 + (sopwith.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = 90 + ((sopwith.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_sopwith_speed_forward * 0.35 * (sopwith.frame/25),0.075);
    }
    else
    {
    	sopwith.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = sopwith_frame;
    }
    } else {
    	//Engine off?
    	sopwith.movetype     = MOVETYPE_BOUNCE;
    	if (sopwith.frame > 0) {
        	sopwith.frame -= 25 / (autocvar_g_vehicle_sopwith_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((sopwith.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(sopwith.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(sopwith.angles_z >= 55 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -55 && sopwith.angles_z >= -180))
	{
		Damage(sopwith, sopwith, player, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 
    
    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sopwith, sopwith, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    setorigin(player, sopwith.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(sopwith.dmg_time, vehicle_shield, autocvar_g_vehicle_sopwith_shield, autocvar_g_vehicle_sopwith_shield_regen_pause, autocvar_g_vehicle_sopwith_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(sopwith.dmg_time, vehicle_health, autocvar_g_vehicle_sopwith_health, autocvar_g_vehicle_sopwith_health_regen_pause, autocvar_g_vehicle_sopwith_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (sopwith.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(sopwith.cnt, vehicle_energy, autocvar_g_vehicle_sopwith_energy, autocvar_g_vehicle_sopwith_energy_regen_pause, autocvar_g_vehicle_sopwith_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
    	vehicles_regen(sopwith.ammount3, vehicle_ammo2, autocvar_g_vehicle_sopwith_bombs_ammo_max,
                                           autocvar_g_vehicle_sopwith_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_sopwith_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    
    
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		sopwith.count = 1;
		sound (sopwith, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, sopwith, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
    
    	//Add
	vehicles_replenishAmmo(player, sopwith, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
	
    }

    sopwith.bomb1.alpha = sopwith.bomb2.alpha = sopwith.bomb3.alpha = sopwith.bomb4.alpha = sopwith.bomb5.alpha = sopwith.bomb6.alpha = sopwith.bomb7.alpha = sopwith.bomb8.alpha = sopwith.bomb9.alpha = sopwith.bomb10.alpha = sopwith.bomb11.alpha = sopwith.bomb12.alpha = sopwith.bomb13.alpha = sopwith.bomb14.alpha = sopwith.bomb15.alpha = sopwith.bomb16.alpha = sopwith.bomb17.alpha = sopwith.bomb18.alpha = (time - sopwith.lip) / (sopwith.delay - sopwith.lip);
    //player.vehicle_reload2 = bound(0, sopwith.bomb1.alpha * 100, 100);
    
    VEHICLE_UPDATE_PLAYER(player, health, sopwith);
    VEHICLE_UPDATE_PLAYER(player, energy, sopwith);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, sopwith);

    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sopwith, sopwith, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

//Flare Stuff removed

float sopwith_frame()
{
    entity player, sopwith;
    float altcontrols = 0;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    altcontrols = player.vehicle_alternateaircontrols;
    sopwith = self.vehicle;
    self   = sopwith;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_sopwith_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_sopwith_speed_forward;
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
    
    if(sopwith.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = sopwith.angles;
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
		ftmp = player.movement_y * -1 * autocvar_g_vehicle_sopwith_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	sopwith.avelocity_y = bound(-autocvar_g_vehicle_sopwith_turnspeed, ftmp + sopwith.avelocity_y * 0.9, autocvar_g_vehicle_sopwith_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(player.movement_x != 0 && !player.BUTTON_HOOK && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_x * -1 * autocvar_g_vehicle_sopwith_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	sopwith.avelocity_x = bound(-autocvar_g_vehicle_sopwith_pitchspeed, ftmp + sopwith.avelocity_x * 0.9, autocvar_g_vehicle_sopwith_pitchspeed);
    	
	
	
	if(sopwith.angles_y > 180)  sopwith.angles_y -= 360;
    	if(sopwith.angles_y < -180) sopwith.angles_y += 360;
	
		if(sopwith.angles_y >= -1 && sopwith.angles_y <= -1)
            	sopwith.angles_y = 0;
		
	if(sopwith.angles_x > 180)  sopwith.angles_x -= 360;
    	if(sopwith.angles_x < -180) sopwith.angles_x += 360;
	
	
		if(sopwith.angles_x >= -1 && sopwith.angles_x <= -1)
            	sopwith.angles_x = 0;
		
	if(sopwith.angles_z > 180)  sopwith.angles_z -= 360;
    	if(sopwith.angles_z < -180) sopwith.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    sopwith.avelocity_y = bound(-autocvar_g_vehicle_sopwith_turnspeed, ftmp + sopwith.avelocity_y * 0.9, autocvar_g_vehicle_sopwith_turnspeed);

    // Pitch
    ftmp = 0;
    if not(player.BUTTON_HOOK) {
    	if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_sopwith_pitchlimit) ftmp = 5;
    	else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_sopwith_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_sopwith_pitchlimit, df_x , autocvar_g_vehicle_sopwith_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_sopwith_pitchlimit, df_x + ftmp, autocvar_g_vehicle_sopwith_pitchlimit);
    sopwith.avelocity_x = bound(-autocvar_g_vehicle_sopwith_pitchspeed, ftmp + sopwith.avelocity_x * 0.9, autocvar_g_vehicle_sopwith_pitchspeed);

    
    //END
    ///////////////
    }
    
    
    sopwith.angles_x = anglemods(sopwith.angles_x);
    sopwith.angles_y = anglemods(sopwith.angles_y);
    sopwith.angles_z = anglemods(sopwith.angles_z);

    if(autocvar_g_vehicle_sopwith_movestyle == 1)
        makevectors('0 1 0' * sopwith.angles_y);
    else
        makevectors(player.v_angle);

    df = sopwith.velocity * -autocvar_g_vehicle_sopwith_friction;

	//print(sprintf("m1 = %f\n", v_forward));
    if(player.BUTTON_HOOK) {
    		if(player.movement_x > 0) {
    	    		sopwith.bomb1.gun2.count = bound(autocvar_g_vehicle_sopwith_speed_forward * 0.35, sopwith.bomb1.gun2.count + (128 * sys_frametime),autocvar_g_vehicle_sopwith_speed_forward);
    			if((sopwith.bomb1.gun2.pushltime < time) && !(sopwith.bomb1.gun2.count >= autocvar_g_vehicle_sopwith_speed_forward))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Raised to %f\n", (sopwith.bomb1.gun2.count/autocvar_g_vehicle_sopwith_speed_forward)));
    				sopwith.bomb1.gun2.pushltime = time + 0.25;
			}
		} else if(player.movement_x < 0) {
    	    		sopwith.bomb1.gun2.count = bound(autocvar_g_vehicle_sopwith_speed_forward * 0.35, sopwith.bomb1.gun2.count - (128 * sys_frametime),autocvar_g_vehicle_sopwith_speed_forward);
    			if((sopwith.bomb1.gun2.pushltime < time) && !(sopwith.bomb1.gun2.count <= autocvar_g_vehicle_sopwith_speed_forward * 0.35))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Lowered to %f\n", (sopwith.bomb1.gun2.count/autocvar_g_vehicle_sopwith_speed_forward)));
    				sopwith.bomb1.gun2.pushltime = time + 0.25;
			}
        
   			if(sopwith_altitude(512) < 16)
				player.PlayerPhysplug = sopwith_takeoff;
		}	 
    } else {
    if((player.movement_x != 0 && !altcontrols)
    ||(player.movement_x != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_sopwith_speed_forward;
        else if(player.movement_x < 0)
          //df -= v_forward  * autocvar_g_vehicle_sopwith_speed_forward;
	  df += v_forward  * (autocvar_g_vehicle_sopwith_speed_forward * 0.35);
    }
    }
    
    
    
    if(((player.movement_x == 0 && !altcontrols) || (player.movement_x == 0 && altcontrols && !player.BUTTON_CROUCH))
    || (player.BUTTON_HOOK)) {
    	df += v_forward  * sopwith.bomb1.gun2.count;
    }



    if((player.movement_y != 0 && !altcontrols)
    ||(player.movement_y != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_sopwith_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_sopwith_speed_strafe;

	sopwith.angles_z = bound(-360,sopwith.angles_z + ((player.movement_y * 1.6 * sys_frametime) / autocvar_g_vehicle_sopwith_speed_strafe),360);
    }
    else
    {
    	//Stable inverted flight
	if(
	(sopwith.angles_z >= 179 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -179 && sopwith.angles_z >= -180))
	{
		sopwith.angles_z = 180;
	} else if(
	(sopwith.angles_z >= 176 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -176 && sopwith.angles_z >= -180))
	{
		sopwith.angles_z *= 1.001;
	} else if(
	(sopwith.angles_z >= 170 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -170 && sopwith.angles_z >= -180))
	{
		sopwith.angles_z *= 1.005;
	} else if(
	(sopwith.angles_z >= 150 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -150 && sopwith.angles_z >= -180))
	{
		sopwith.angles_z *= 1.01;
	} else if(
	(sopwith.angles_z >= 100 && sopwith.angles_z <= 180) ||
	(sopwith.angles_z <= -100 && sopwith.angles_z >= -180))
	{
		sopwith.angles_z *= 1.025;	
	} else {
       		sopwith.angles_z *= 0.95;
	}
        if(sopwith.angles_z >= -1 && sopwith.angles_z <= -1)
            sopwith.angles_z = 0;
    }



    if((player.BUTTON_CROUCH && !altcontrols)
    ||(player.BUTTON_CROUCH && altcontrols && !player.movement_y && !player.movement_x)) {
        df -=   v_up * autocvar_g_vehicle_sopwith_speed_down;
    } else if ((player.BUTTON_JUMP && !altcontrols)
    || (player.BUTTON_JUMP && altcontrols && !player.movement_y && !player.movement_x))
    {
        df +=  v_up * autocvar_g_vehicle_sopwith_speed_up;
    }
    
    

    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	sopwith.avelocity_x = 0;
	sopwith.avelocity_y = 0;
	sopwith.avelocity_z = 0;
    }
    
    
    
    
    
    if (altcontrols) {
	player.v_angle_x = sopwith.angles_x * -1;
	player.v_angle_y = sopwith.angles_y;
	player.v_angle_z = sopwith.angles_z; //kiss
	
	player.angles_x = sopwith.angles_x;
	player.angles_y = sopwith.angles_y;
	player.angles_z = sopwith.angles_z; //for completion

	if ((clienttype(player) == CLIENTTYPE_REAL)) {
		msg_entity = player;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, player.v_angle_x);
		WriteAngle( MSG_ONE, player.v_angle_y);
  		WriteAngle( MSG_ONE, player.v_angle_z);
	}
    }
    
    
    df = vehicles_waterspeed(player, df);
    sopwith.velocity = vehicles_waterfriction(player, sopwith, sopwith.velocity);
    sopwith.velocity  += df * frametime;
    player.velocity = player.movement  = sopwith.velocity;
    setorigin(player, sopwith.origin + '0 0 32');
    
    //Cannon firing 
    if(player.BUTTON_ATCK)
    if(time > sopwith.attack_finished_single)
    if(sopwith.vehicle_energy >= autocvar_g_vehicle_sportster_cannon_cost)
    {
        sopwith.vehicle_energy -= autocvar_g_vehicle_sportster_cannon_cost;
        sopwith.wait = time;

        crosshair_trace(player);
	
        sopwith_fire_cannon("tag_mgun");
	UziFlash();
	sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_mgun");
	if (autocvar_g_casings >= 2) {
		if (autocvar_g_vehicle_sopwith_cannon_expelbulletcasings) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right *-1) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 105, sopwith, "tag_casings");
		}
	}
        
        sopwith.attack_finished_single = time + autocvar_g_vehicle_sopwith_cannon_refire;
	sopwith.count = 0; //Will have to press R to resume reload
    }


    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(sopwith.dmg_time, vehicle_shield, autocvar_g_vehicle_sopwith_shield, autocvar_g_vehicle_sopwith_shield_regen_pause, autocvar_g_vehicle_sopwith_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(sopwith.dmg_time, vehicle_health, autocvar_g_vehicle_sopwith_health, autocvar_g_vehicle_sopwith_health_regen_pause, autocvar_g_vehicle_sopwith_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (sopwith.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(sopwith.cnt, vehicle_energy, autocvar_g_vehicle_sopwith_energy, autocvar_g_vehicle_sopwith_energy_regen_pause, autocvar_g_vehicle_sopwith_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
    	vehicles_regen(sopwith.ammount3, vehicle_ammo2, autocvar_g_vehicle_sopwith_bombs_ammo_max,
                                           autocvar_g_vehicle_sopwith_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_sopwith_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    
    
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		sopwith.count = 1;
		sound (sopwith, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, sopwith, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
    
    	//Add
	vehicles_replenishAmmo(player, sopwith, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
    }
    
    
    //Add
    if(player.BUTTON_ATCK2)
    {
    	//print(ftos(sopwith.vehicle_ammo2), "_a2_", ftos(autocvar_g_vehicle_sopwith_bombs_ammo_cost), "_ac_", ftos(sopwith.vehicle_ammo2_current), "_cur_", ftos(sopwith.vehicle_ammo2_max), "_max\n");
	sopwith.ammount3 = time; //.cnt
        if(sopwith.vehicle_ammo2 >= autocvar_g_vehicle_sopwith_bombs_ammo_cost && sopwith.bomb1.attack_finished_single <= time)
        {
	    sopwith_drop_nade1("bombmount_center1", sopwith);
	    sopwith_drop_nade2("bombmount_center2", sopwith);
	    sopwith_drop_nade2("bombmount_center3", sopwith);
	    sopwith_drop_nade1("bombmount_center4", sopwith);
	    sopwith_drop_nade1("bombmount_center5", sopwith);
	    sopwith_drop_nade2("bombmount_center6", sopwith);
	    
	    sopwith_drop_nade1("bombmount_center7", sopwith);
	    sopwith_drop_nade2("bombmount_center8", sopwith);
	    sopwith_drop_nade2("bombmount_center9", sopwith);
	    sopwith_drop_nade1("bombmount_center10", sopwith);
	    sopwith_drop_nade1("bombmount_center11", sopwith);
	    sopwith_drop_nade2("bombmount_center12", sopwith);
	    
	    sopwith_drop_nade1("bombmount_center13", sopwith);
	    sopwith_drop_nade2("bombmount_center14", sopwith);
	    sopwith_drop_nade2("bombmount_center15", sopwith);
	    sopwith_drop_nade1("bombmount_center16", sopwith);
	    sopwith_drop_nade1("bombmount_center17", sopwith);
	    sopwith_drop_nade2("bombmount_center18", sopwith);
	    
            sopwith.vehicle_ammo2 -= autocvar_g_vehicle_sopwith_bombs_ammo_cost;
            sopwith.bomb1.attack_finished_single = time + autocvar_g_vehicle_sopwith_bombs_refire; //Changed from tur_head

	    sopwith.count = 0; //Will have to press R to resume reload
			    
	    sopwith.bomb1.alpha = sopwith.bomb2.alpha = sopwith.bomb3.alpha = sopwith.bomb4.alpha = sopwith.bomb5.alpha = sopwith.bomb6.alpha = sopwith.bomb7.alpha = sopwith.bomb8.alpha = sopwith.bomb9.alpha = sopwith.bomb10.alpha = sopwith.bomb11.alpha = sopwith.bomb12.alpha = sopwith.bomb13.alpha = sopwith.bomb14.alpha = sopwith.bomb15.alpha = sopwith.bomb16.alpha = sopwith.bomb17.alpha = sopwith.bomb18.alpha = 0.000001;            
	}
    }
    
    if (sopwith.bomb1.alpha < 1) {
    	//1-((futuretime-currenttime)/addedtime)
	sopwith.bomb1.alpha = sopwith.bomb2.alpha = sopwith.bomb3.alpha = sopwith.bomb4.alpha = sopwith.bomb5.alpha = sopwith.bomb6.alpha = sopwith.bomb7.alpha = sopwith.bomb8.alpha = sopwith.bomb9.alpha = sopwith.bomb10.alpha = sopwith.bomb11.alpha = sopwith.bomb12.alpha = sopwith.bomb13.alpha = sopwith.bomb14.alpha = sopwith.bomb15.alpha = sopwith.bomb16.alpha = sopwith.bomb17.alpha = sopwith.bomb18.alpha = ( 1 - ((sopwith.bomb1.attack_finished_single - time) / autocvar_g_vehicle_sopwith_bombs_refire) );
    }
    //Added       
    
    
    
    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, sopwith);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_sopwith_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

    VEHICLE_UPDATE_PLAYER(player, health, sopwith);
    VEHICLE_UPDATE_PLAYER(player, energy, sopwith);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, sopwith);

    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sopwith, sopwith, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    player.vehicle_ammo1_current = sopwith.vehicle_ammo1_current;
    player.vehicle_ammo1_max = sopwith.vehicle_ammo1_max;
    player.vehicle_ammo2_current = sopwith.vehicle_ammo2_current;
    player.vehicle_ammo2_max = sopwith.vehicle_ammo2_max;
    
    //For the bomb reload bar;
    if(sopwith.vehicle_ammo2 > 0)
    {
    	//pressed reload
    	if (time > sopwith.bomb1.attack_finished_single) {
    		player.vehicle_reload2 = 100;
    	} else {
    		player.vehicle_reload2 = bound(0, 
     		( 1 - ((sopwith.bomb1.attack_finished_single - time) / autocvar_g_vehicle_sopwith_bombs_refire) ) * 100,
     		100);
    	}
    } else {
    	player.vehicle_reload2 = 0;
    }
    //Done bomb reloading bar
    
    self = player;
    return 1;
}

void sopwith_impact()
{
    if(autocvar_g_vehicle_sopwith_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_sopwith_bouncepain_x, autocvar_g_vehicle_sopwith_bouncepain_y, autocvar_g_vehicle_sopwith_bouncepain_z);
}

// If we dont do this ever now and then, the sopwiths rotors
// stop working, presumably due to angle overflow. cute.
void sopwith_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void sopwith_spawn(float _f)
{
    if(!self.gun1)
    {
    	self.loddistance1 = 256; //Lod0 Model somewhat complex, so only use when very close
	self.loddistance2 = 512;
	
    	self.lodmodel1 = "models/vehicles/sopwithedits_lod1.iqm";
	self.lodmodel2 = "models/vehicles/sopwithedits_lod2.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = sopwith_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
	self.bomb3 = spawn();
        self.bomb4 = spawn();
	self.bomb5 = spawn();
        self.bomb6 = spawn();
	self.bomb7 = spawn();
        self.bomb8 = spawn();
	self.bomb9 = spawn();
        self.bomb10 = spawn();
	self.bomb11 = spawn();
        self.bomb12 = spawn();
	self.bomb13 = spawn();
        self.bomb14 = spawn();
	self.bomb15 = spawn();
        self.bomb16 = spawn();
	self.bomb17 = spawn();
        self.bomb18 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"models/grenademodel.md3");
        setmodel(self.bomb2,"models/grenademodel.md3");
	setmodel(self.bomb3,"models/grenademodel.md3");
        setmodel(self.bomb4,"models/grenademodel.md3");
	setmodel(self.bomb5,"models/grenademodel.md3");
        setmodel(self.bomb6,"models/grenademodel.md3");
	
	setmodel(self.bomb7,"models/grenademodel.md3");
        setmodel(self.bomb8,"models/grenademodel.md3");
	setmodel(self.bomb9,"models/grenademodel.md3");
        setmodel(self.bomb10,"models/grenademodel.md3");
	setmodel(self.bomb11,"models/grenademodel.md3");
        setmodel(self.bomb12,"models/grenademodel.md3");
	
	setmodel(self.bomb13,"models/grenademodel.md3");
        setmodel(self.bomb14,"models/grenademodel.md3");
	setmodel(self.bomb15,"models/grenademodel.md3");
        setmodel(self.bomb16,"models/grenademodel.md3");
	setmodel(self.bomb17,"models/grenademodel.md3");
        setmodel(self.bomb18,"models/grenademodel.md3");
	
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/sopwithedits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_center1");
        setattachment(self.bomb2, self, "bombmount_center2");
	setattachment(self.bomb3, self, "bombmount_center3");
        setattachment(self.bomb4, self, "bombmount_center4");
	setattachment(self.bomb5, self, "bombmount_center5");
        setattachment(self.bomb6, self, "bombmount_center6");
	
	setattachment(self.bomb7, self, "bombmount_center7");
        setattachment(self.bomb8, self, "bombmount_center8");
	setattachment(self.bomb9, self, "bombmount_center9");
        setattachment(self.bomb10, self, "bombmount_center10");
	setattachment(self.bomb11, self, "bombmount_center11");
        setattachment(self.bomb12, self, "bombmount_center12");
	
	setattachment(self.bomb13, self, "bombmount_center13");
        setattachment(self.bomb14, self, "bombmount_center14");
	setattachment(self.bomb15, self, "bombmount_center15");
        setattachment(self.bomb16, self, "bombmount_center16");
	setattachment(self.bomb17, self, "bombmount_center17");
        setattachment(self.bomb18, self, "bombmount_center18");
        //setattachment(self.tur_head, self,"root");

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
        setmodel(spinner,"models/vehicles/sopwith_spinner.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	////spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        //setmodel(spinner,"models/vehicles/sopwith_spinner.iqm");
        //setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = sopwith_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_sopwith_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxftd1 = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.bomb1.gun1.count = 0;
	self.bomb1.gun2.count = autocvar_g_vehicle_sopwith_speed_forward * 0.6;
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_sopwith_health;
    self.vehicle_shield = autocvar_g_vehicle_sopwith_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = 90;

    setsize(self, SOPWITH_MIN, SOPWITH_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_sopwith_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_sopwith_bouncestop;    
    self.vehicle_impact = sopwith_impact;    
    self.damageforcescale = 0.25;
    
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly
	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxft, SOPWITHROTOR_MIN_HBF_T, SOPWITHROTOR_MAX_HBF_T, 0, 50, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmf, SOPWITHROTOR_MIN_HBB_T, SOPWITHROTOR_MAX_HBB_T, 0, 20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxftd1, SOPWITHROTOR_MIN_HBB_T, SOPWITHROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmb, SOPWITHROTOR_MIN_HBB_T, SOPWITHROTOR_MAX_HBB_T, 0, -20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxbk, SOPWITHROTOR_MIN_HBF_T, SOPWITHROTOR_MAX_HBF_T, 0, -50, 0);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_sopwith()
{
    if(!autocvar_g_vehicle_sopwith)
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
   
    if(autocvar_g_vehicle_sopwith_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_sopwith_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_sopwith_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_sopwith_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/sopwithedits.iqm");
    precache_model ("models/vehicles/sopwithedits_lod1.iqm");
    precache_model ("models/vehicles/sopwithedits_lod2.iqm");
    precache_model ("models/vehicles/sopwith_spinner.iqm");
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
             "Sopwith",
             "models/vehicles/sopwithedits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_AEROPLANE,
             SOPWITH_MIN, SOPWITH_MAX,
             FALSE,
             sopwith_spawn, autocvar_g_vehicle_sopwith_respawntime,
             sopwith_frame,
             sopwith_enter, sopwith_exit,
             sopwith_die,   sopwith_think,
             FALSE, 
             autocvar_g_vehicle_sopwith_health,
             autocvar_g_vehicle_sopwith_shield, autocolor, autocvar_g_vehicle_nieuport_energy * 5, floor(autocvar_g_vehicle_sopwith_bombs_ammo_max * 2.12)))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
