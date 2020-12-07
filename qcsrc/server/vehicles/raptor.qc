#define RSM_FIRST 0
#define RSM_BOMB 0
#define RSM_FLARE 1
#define RSM_LAST 1

#define RAPTOR_MIN '-80 -80 0'
#define RAPTOR_MAX '80 80 70'

const vector RAPTORHELIROTOR_MIN_HBF = '-25 -25 -2'; //Back and front trunk for this model
const vector RAPTORHELIROTOR_MAX_HBF = '25 25 2';

const vector RAPTORHELIROTOR_MIN_HBF2 = '-50 -50 -8'; //Back and front trunk for this model
const vector RAPTORHELIROTOR_MAX_HBF2 = '50 50 2';

const vector RAPTORHELIROTOR_MIN_HBF_T = '-5 -5 -30'; //Back and front trunk for this model
const vector RAPTORHELIROTOR_MAX_HBF_T = '5 5 30';

const vector RAPTORHELIROTOR_MIN_HBB_T = '-5 -5 -60'; //Middle
const vector RAPTORHELIROTOR_MAX_HBB_T = '5 5 60';


#ifdef SVQC
float autocvar_g_vehicle_raptor;

float autocvar_g_vehicle_raptor_mass;

float autocvar_g_vehicle_raptor_respawntime;
float autocvar_g_vehicle_raptor_takeofftime;

float autocvar_g_vehicle_raptor_movestyle;
float autocvar_g_vehicle_raptor_turnspeed;
float autocvar_g_vehicle_raptor_pitchspeed;
float autocvar_g_vehicle_raptor_pitchlimit;

float autocvar_g_vehicle_raptor_speed_forward;
float autocvar_g_vehicle_raptor_speed_strafe;
float autocvar_g_vehicle_raptor_speed_up;
float autocvar_g_vehicle_raptor_speed_down;
float autocvar_g_vehicle_raptor_friction;

float autocvar_g_vehicle_raptor_bomblets;
float autocvar_g_vehicle_raptor_bomblet_alt;
float autocvar_g_vehicle_raptor_bomblet_time;
float autocvar_g_vehicle_raptor_bomblet_damage;
float autocvar_g_vehicle_raptor_bomblet_spread;
float autocvar_g_vehicle_raptor_bomblet_edgedamage;
float autocvar_g_vehicle_raptor_bomblet_radius;
float autocvar_g_vehicle_raptor_bomblet_force;
float autocvar_g_vehicle_raptor_bomblet_explode_delay;
float autocvar_g_vehicle_raptor_bomblet_explode_enableshockwave;
float autocvar_g_vehicle_raptor_bomblet_fragments;
float autocvar_g_vehicle_raptor_bomblet_fragment_speed;
float autocvar_g_vehicle_raptor_bomblet_fragment_damage;
float autocvar_g_vehicle_raptor_bomblet_fragment_headshotbonus;
float autocvar_g_vehicle_raptor_bomblet_fragment_force;
// extraneous //float autocvar_g_vehicle_raptor_bomblet_fragment_tracer;
float autocvar_g_vehicle_raptor_bomblet_fragment_gravity;
float autocvar_g_vehicle_raptor_bomblet_fragment_bulletconstant;
float autocvar_g_vehicle_raptor_bomblet_fragment_coreshotbonus;
float autocvar_g_vehicle_raptor_bombs_refire;

float autocvar_g_vehicle_raptor_flare_refire;
float autocvar_g_vehicle_raptor_flare_lifetime;
float autocvar_g_vehicle_raptor_flare_chase;
float autocvar_g_vehicle_raptor_flare_range;

float autocvar_g_vehicle_raptor_cannon_turnspeed;
float autocvar_g_vehicle_raptor_cannon_turnlimit;
float autocvar_g_vehicle_raptor_cannon_pitchlimit_up;
float autocvar_g_vehicle_raptor_cannon_pitchlimit_down;

float autocvar_g_vehicle_raptor_cannon_locktarget;
float autocvar_g_vehicle_raptor_cannon_locking_time;
float autocvar_g_vehicle_raptor_cannon_locking_releasetime;
float autocvar_g_vehicle_raptor_cannon_locked_time;
float autocvar_g_vehicle_raptor_cannon_predicttarget;

float autocvar_g_vehicle_raptor_cannon_cost;
float autocvar_g_vehicle_raptor_cannon_damage;
float autocvar_g_vehicle_raptor_cannon_radius;
float autocvar_g_vehicle_raptor_cannon_refire;
float autocvar_g_vehicle_raptor_cannon_speed;
float autocvar_g_vehicle_raptor_cannon_spread;
float autocvar_g_vehicle_raptor_cannon_force;

float autocvar_g_vehicle_raptor_energy;
float autocvar_g_vehicle_raptor_energy_regen;
float autocvar_g_vehicle_raptor_energy_regen_pause;

float autocvar_g_vehicle_raptor_health;
float autocvar_g_vehicle_raptor_health_regen;
float autocvar_g_vehicle_raptor_health_regen_pause;

float autocvar_g_vehicle_raptor_shield;
float autocvar_g_vehicle_raptor_shield_regen;
float autocvar_g_vehicle_raptor_shield_regen_pause;

float autocvar_g_vehicle_raptor_bouncefactor;
float autocvar_g_vehicle_raptor_bouncestop;
vector autocvar_g_vehicle_raptor_bouncepain;

void raptor_spawn(float);
float raptor_frame();
float raptor_takeoff();

.entity bomb1;
.entity bomb2;
.entity bomb3;

.entity rotorboxft;
.entity rotorboxmf;
.entity rotorboxmb;
.entity rotorboxbk;

.entity rotorboxftr;
.entity rotorboxmfr;
.entity rotorboxmbr;
.entity rotorboxbkr;

//tail rotor
.entity rotorboxft_t;
.entity rotorboxmf_t;
.entity rotorboxmid_t;
.entity rotorboxmb_t;
.entity rotorboxbk_t;

void helicopter_rotor_die(entity hitbox);
void helicopter_rotor_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s);

float raptor_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

void raptor_FragsOverTime (void)
{
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
			fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
			 autocvar_g_vehicle_raptor_bomblet_fragment_speed, 5,
			 autocvar_g_vehicle_raptor_bomblet_fragment_damage,
			 autocvar_g_vehicle_raptor_bomblet_fragment_headshotbonus,
			 autocvar_g_vehicle_raptor_bomblet_fragment_force,
			 DEATH_FRAGMENT,
			 PROJECTILE_BULLETSHRAPNEL,
			 autocvar_g_vehicle_raptor_bomblet_fragment_gravity,
			 autocvar_g_vehicle_raptor_bomblet_fragment_bulletconstant,
			 autocvar_g_vehicle_raptor_bomblet_fragment_coreshotbonus);
		 
			endFireBallisticBullet();				
	}
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_vehicle_raptor_bomblet_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}


void raptor_FragsOverTimeSpawn (entity gren)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	e.think = raptor_FragsOverTime;
	e.count = floor(autocvar_g_vehicle_raptor_bomblet_fragments / autocvar_g_balance_grenadelauncher_secondary_fragments_frames)+1;
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void raptor_bomblet_boom()
{

    if (autocvar_g_vehicle_raptor_bomblet_explode_enableshockwave == 1) {
    modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_raptor_bomblet_radius, 0.2, 0.05, 0.25);
    
    modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_raptor_bomblet_radius, 0.30, 0.05, 1.1);
    }

    RadiusDamage (self, self.realowner, autocvar_g_vehicle_raptor_bomblet_damage,
                                    autocvar_g_vehicle_raptor_bomblet_edgedamage,
                                    autocvar_g_vehicle_raptor_bomblet_radius, world,
                                    autocvar_g_vehicle_raptor_bomblet_force, DEATH_RAPTOR_BOMB, world);

	OilFire_explosion_spawnoilburnermaybe(self);
	
	//Start Bomblet Fragmentation
	if (autocvar_g_vehicle_raptor_bomblet_fragments > 0) {
		if(autocvar_g_balance_grenadelauncher_secondary_fragments_frames < 2)
		{
			float	sc;
			for (sc = 0;sc < autocvar_g_vehicle_raptor_bomblet_fragments;sc = sc + 1) {
	
			fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
			 autocvar_g_vehicle_raptor_bomblet_fragment_speed, 5,
			 autocvar_g_vehicle_raptor_bomblet_fragment_damage,
			 autocvar_g_vehicle_raptor_bomblet_fragment_headshotbonus,
			 autocvar_g_vehicle_raptor_bomblet_fragment_force,
			 DEATH_FRAGMENT,
			 PROJECTILE_BULLETSHRAPNEL,
			 autocvar_g_vehicle_raptor_bomblet_fragment_gravity,
			 autocvar_g_vehicle_raptor_bomblet_fragment_bulletconstant,
			 autocvar_g_vehicle_raptor_bomblet_fragment_coreshotbonus);
		 
			endFireBallisticBullet();
			}
		} else {
		raptor_FragsOverTimeSpawn(self); //Spread out fragment spawning
		}
	}
	//Finish Bomblet Fragmentation
	    
    remove(self);
}

void raptor_bomblet_touch()
{
    if(other == self.owner)
        return;

    PROJECTILE_TOUCH;
    self.think = raptor_bomblet_boom;
    self.nextthink = time + random() * autocvar_g_vehicle_raptor_bomblet_explode_delay;
}

void raptor_bomb_burst()
{
    if(self.cnt > time)
    if(autocvar_g_vehicle_raptor_bomblet_alt)
    {
        self.nextthink = time;
        traceline(self.origin, self.origin + (normalize(self.velocity) * autocvar_g_vehicle_raptor_bomblet_alt), MOVE_NORMAL, self);
        if((trace_fraction == 1.0) || (vlen(self.origin - self.owner.origin) < autocvar_g_vehicle_raptor_bomblet_radius))
        {
            UpdateCSQCProjectile(self);
            return;
        }
    }

    entity bomblet;
    float i;

    Damage_DamageInfo(self.origin, 0, 0, 0, '0 0 0', DEATH_RAPTOR_BOMB_SPLIT, 0, self);

    for(i = 0; i < autocvar_g_vehicle_raptor_bomblets; ++i)
    {
        bomblet = spawn();
        setorigin(bomblet, self.origin);

        bomblet.movetype    = MOVETYPE_TOSS;
        bomblet.touch       = raptor_bomblet_touch;
        bomblet.think       = raptor_bomblet_boom;
        bomblet.nextthink   = time + 5;
        bomblet.owner       = self.owner;
        bomblet.realowner   = self.realowner;
        bomblet.velocity    = normalize(normalize(self.velocity) + (randomvec() * autocvar_g_vehicle_raptor_bomblet_spread)) * vlen(self.velocity);

        PROJECTILE_MAKETRIGGER(bomblet);
        CSQCProjectile(bomblet, TRUE, PROJECTILE_RAPTORBOMBLET, TRUE);
    }

    remove(self);
}

float autocvar_g_vehicle_nieuport_bomb_radius;
float autocvar_g_vehicle_nieuport_bomb_damage;
void nieuport_Mine_Damage_Tree (entity mymine);
void raptor_bombfly_boom()
{
	PROJECTILE_TOUCH;
	  
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.95, 0.05, 0.25);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.75, 0.07, 0.4);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.4, 0.1, 0.5);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.35, 0.13, 0.6);

	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.25, 0.16, 0.7);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.4, 1, 1.0);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.3, 2, 2.0);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_nieuport_bomb_radius, 0.2, 3, 3.0);
	
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

	nieuport_Mine_Damage_Tree(self);
	RadiusDamage (self, self.realowner, autocvar_g_vehicle_nieuport_bomb_damage, autocvar_g_balance_explosivevest_primary_edgedamage, autocvar_g_vehicle_nieuport_bomb_radius, world, autocvar_g_balance_explosivevest_primary_force, self.projectiledeathtype, world);
	OilFire_explosion_spawnoilburnermaybe(self);

	
	//Finish explosivevest Fragmentation
	
	remove(self);
}

void raptor_bombdrop()
{
    entity bomb_1, bomb_2;

    bomb_1 = spawn();
    bomb_2 = spawn();

    setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bombmount_left")));
    setorigin(bomb_2, gettaginfo(self, gettagindex(self, "bombmount_right")));

    bomb_1.movetype     = bomb_2.movetype   = MOVETYPE_BOUNCE;
    bomb_1.velocity     = bomb_2.velocity   = self.velocity;
    bomb_1.touch        = bomb_2.touch      = raptor_bomb_burst;
    bomb_1.think        = bomb_2.think      = raptor_bomb_burst;
    bomb_1.cnt          = bomb_2.cnt        = time + 10;

    if(autocvar_g_vehicle_raptor_bomblet_alt)
        bomb_1.nextthink = bomb_2.nextthink  = time;
    else
        bomb_1.nextthink = bomb_2.nextthink  = time + autocvar_g_vehicle_raptor_bomblet_time;

    bomb_1.owner     = bomb_2.owner      = self;
    bomb_1.realowner = bomb_2.realowner  = self.owner;
    bomb_1.solid     = bomb_2.solid      = SOLID_BBOX;
    bomb_1.gravity   = bomb_2.gravity    = 1;

    PROJECTILE_MAKETRIGGER(bomb_1);
    PROJECTILE_MAKETRIGGER(bomb_2);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
    CSQCProjectile(bomb_2, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
}


void raptor_rightbombdrop()
{
    entity bomb_2;

    bomb_2 = spawn();

    setorigin(bomb_2, gettaginfo(self, gettagindex(self, "bombmount_right")));

    bomb_2.movetype   = MOVETYPE_BOUNCE;
    bomb_2.velocity   = self.velocity;
    bomb_2.touch      = raptor_bomb_burst;
    bomb_2.think      = raptor_bomb_burst;
    bomb_2.cnt        = time + 10;

    if(autocvar_g_vehicle_raptor_bomblet_alt)
        bomb_2.nextthink  = time;
    else
        bomb_2.nextthink  = time + autocvar_g_vehicle_raptor_bomblet_time;

    bomb_2.owner      = self;
    bomb_2.realowner  = self.owner;
    bomb_2.solid      = SOLID_BBOX;
    bomb_2.gravity    = 1;

    PROJECTILE_MAKETRIGGER(bomb_2);

    CSQCProjectile(bomb_2, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
}

void raptor_nukedrop()
{
    entity bomb_1;

    bomb_1 = spawn();
    W_Nuke_Set_Standard(bomb_1); //Set the yeild etc
    
    setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bombmount_left")));

    bomb_1.movetype        = MOVETYPE_BOUNCE;
    bomb_1.velocity        = self.velocity;
    bomb_1.touch           = W_Nuke_Explode;

    bomb_1.owner           = self;
    bomb_1.realowner       = self.owner;
    bomb_1.solid           = SOLID_BBOX;
    bomb_1.gravity         = 0.65; //Streamer
    bomb_1.projectiledeathtype = WEP_NUKE_LAYER;

    PROJECTILE_MAKETRIGGER(bomb_1);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_NUKEBOMB, TRUE);
}
//////////////////////////////////////////////////////////////////////////////////
/////////Missiles/////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////


void raptor_bombfly_think (void)
{

	float velspeed;
	self.nextthink = time;


	// accelerate
	makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0');
	
	// normal rocket
	velspeed = autocvar_g_balance_rpg7launcher_speed * g_weaponspeedfactor - (self.velocity * v_forward);
	if (velspeed > 0)
		self.velocity = self.velocity + v_forward * min(autocvar_g_balance_rpg7launcher_speedaccel * g_weaponspeedfactor * frametime, velspeed);

	if ((time < self.ammount) && (time > self.cnt)) {
		//print ("Guiding\n");
		if(time > self.pushltime)
		if(self.realowner.deadflag == DEAD_NO)
		{
			local float myrocketguiderate;
			local vector desireddir, olddir, newdir, desiredorigin, goal;
			local float f;
			myrocketguiderate = 90;
			
			f = autocvar_g_balance_rocketlauncher_guideratedelay;
			if(f)
				f = bound(0, (time - self.pushltime) / f, 1);
			else
				f = 1;

			velspeed = vlen(self.velocity);

			makevectors(self.realowner.v_angle);
			desireddir = WarpZone_RefSys_TransformVelocity(self.realowner, self, v_forward);
			//desiredorigin = WarpZone_RefSys_TransformOrigin(self.realowner, self, self.realowner.origin + self.realowner.view_ofs);
			if (self.count) {
				desiredorigin = WarpZone_RefSys_TransformOrigin(self.realowner, self, self.realowner.origin + v_right * -300);
			} else {
				desiredorigin = WarpZone_RefSys_TransformOrigin(self.realowner, self, self.realowner.origin + v_right * 300);
			}
			olddir = normalize(self.velocity);

			// now it gets tricky... we want to move like some curve to approximate the target direction
			// but we are limiting the rate at which we can turn!
			goal = desiredorigin + ((self.origin - desiredorigin) * desireddir + autocvar_g_balance_rocketlauncher_guidegoal) * desireddir;
			newdir = rocket_steerto(olddir, normalize(goal - self.origin), cos(myrocketguiderate * f * frametime * DEG2RAD));

			self.velocity = newdir * velspeed;
			self.angles = vectoangles(self.velocity);
			
			UpdateCSQCProjectile(self);
		}
	}

	if(self.csqcprojectile_clientanimate == 0)
		UpdateCSQCProjectile(self);
}

void raptor_nukefly_Rocket_Explode ()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_rocketlauncher_damage, autocvar_g_balance_rocketlauncher_edgedamage, autocvar_g_balance_rocketlauncher_radius, world, autocvar_g_balance_rocketlauncher_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	

	//Start Explosion Shockwave and fireball
	if (autocvar_g_balance_rocketlauncher_enableshockwave == 1) {
		modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rocketlauncher_radius, 0.95, 0.05, 0.25);
	}
	
	remove (self);
}

void raptor_bombfly_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
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
		W_PrepareExplosionByDamage(attacker, raptor_bombfly_boom);
}

void raptor_nukefly_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
	
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	//Doesn't explode nuclear if not detonated properly
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, raptor_nukefly_Rocket_Explode);
}


/////////////////////////////////////////////////////////////////////////////
//For alt weapons
#define RAPTORCMISSILEG1 0.1
#define RAPTORCMISSILEG2 0.95
void raptor_bombfly()
{
    entity bomb_1, bomb_2;

    bomb_1 = spawn();
    bomb_2 = spawn();
    bomb_1.health = autocvar_g_balance_rocketlauncher_health;
    bomb_2.health = autocvar_g_balance_rocketlauncher_health;

    bomb_1.origin = gettaginfo(self, gettagindex(self, "bombmount_left"));
    bomb_1.origin_z = bomb_1.origin_z + 24;
    setorigin(bomb_1, bomb_1.origin);
    
    bomb_2.origin = gettaginfo(self, gettagindex(self, "bombmount_right"));
    bomb_2.origin_z = bomb_2.origin_z + 24;
    setorigin(bomb_2, bomb_2.origin);

    bomb_1.movetype     = bomb_2.movetype   = MOVETYPE_FLY;
    bomb_1.velocity     = bomb_2.velocity   = normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_balance_rpg7launcher_speedstart;
    bomb_1.touch        = bomb_2.touch      = raptor_bombfly_boom;
    bomb_1.think        = bomb_2.think      = raptor_bombfly_think;
    bomb_1.nextthink = bomb_2.nextthink  = time;
    bomb_1.event_damage = bomb_2.event_damage = raptor_bombfly_Damage;
    
    bomb_1.owner     = bomb_2.owner      = self;
    bomb_1.realowner = bomb_2.realowner  = self.owner;
    bomb_1.solid     = bomb_2.solid      = SOLID_BBOX;
    bomb_1.cnt       = bomb_2.cnt = time + RAPTORCMISSILEG1;
    bomb_1.ammount   = bomb_2.ammount = time + RAPTORCMISSILEG2;
    bomb_1.count = 0;
    bomb_2.count = 1;
    
    pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), bomb_1.origin,  v_forward * 1000, 1);
    pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), bomb_2.origin,  v_forward * 1000, 1);

    PROJECTILE_MAKETRIGGER(bomb_1);
    PROJECTILE_MAKETRIGGER(bomb_2);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_RAPTORCMISSILE, TRUE);
    CSQCProjectile(bomb_2, TRUE, PROJECTILE_RAPTORCMISSILE, TRUE);
}


void raptor_rightbombfly()
{
    entity bomb_2;

    bomb_2 = spawn();
    
    bomb_2.health = autocvar_g_balance_rocketlauncher_health;

    bomb_2.origin = gettaginfo(self, gettagindex(self, "bombmount_right"));
    bomb_2.origin_z = bomb_2.origin_z + 24;
    setorigin(bomb_2, bomb_2.origin);

    bomb_2.movetype   = MOVETYPE_FLY;
    bomb_2.velocity   = normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_balance_rpg7launcher_speedstart;
    bomb_2.touch      = raptor_bombfly_boom;
    bomb_2.think      = raptor_bombfly_think;

    pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), bomb_2.origin,  v_forward * 1000, 1);

    bomb_2.nextthink  = time;
    
    bomb_2.event_damage = raptor_bombfly_Damage;

    bomb_2.owner      = self;
    bomb_2.realowner  = self.owner;
    bomb_2.solid      = SOLID_BBOX;
    bomb_2.cnt        = time + RAPTORCMISSILEG1;
    bomb_2.ammount        = time + RAPTORCMISSILEG2;
    bomb_2.count = 1;

    PROJECTILE_MAKETRIGGER(bomb_2);

    CSQCProjectile(bomb_2, TRUE, PROJECTILE_RAPTORCMISSILE, TRUE);
}

void raptor_nukefly_boom()
{
	PROJECTILE_TOUCH;
	W_Nuke_Explode();
}

void raptor_nukefly()
{
    entity bomb_1;

    bomb_1 = spawn();
    W_Nuke_Set_Standard(bomb_1); //Set the yeild etc
    
    bomb_1.health = autocvar_g_balance_rocketlauncher_health;

    bomb_1.origin = gettaginfo(self, gettagindex(self, "bombmount_left"));
    bomb_1.origin_z = bomb_1.origin_z + 24;
    setorigin(bomb_1, bomb_1.origin);

    bomb_1.movetype        = MOVETYPE_FLY;
    bomb_1.velocity        = normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_balance_rpg7launcher_speedstart;
    bomb_1.touch           = raptor_nukefly_boom;
    
    pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), bomb_1.origin, v_forward * 1000, 1);

    
    bomb_1.event_damage = raptor_nukefly_Damage;

    bomb_1.owner           = self;
    bomb_1.realowner       = self.owner;
    bomb_1.solid           = SOLID_BBOX;
    bomb_1.projectiledeathtype = WEP_NUKE_LAYER;
    
    bomb_1.think      = raptor_bombfly_think;

    bomb_1.nextthink  = time;
    
    bomb_1.cnt        = time + RAPTORCMISSILEG1;
    bomb_1.ammount        = time + RAPTORCMISSILEG2;
    bomb_1.count = 0;

    PROJECTILE_MAKETRIGGER(bomb_1);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_NUKECMISSILE, TRUE);
}


void raptor_fire_cannon(entity gun, string tagname)
{
    vehicles_projectile("raptor_cannon_muzzleflash", "weapons/lasergun_fire.wav",
                           gettaginfo(gun, gettagindex(gun, tagname)), normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_vehicle_raptor_cannon_speed,
                           autocvar_g_vehicle_raptor_cannon_damage, autocvar_g_vehicle_raptor_cannon_radius, autocvar_g_vehicle_raptor_cannon_force,  0,
                           DEATH_RAPTOR_CANNON, PROJECTILE_RAPTORCANNON, 0, TRUE, TRUE, self.owner);
}

void raptor_W_RPG7Rocket_Attack (vector _org, vector _vel, entity _owner)
{
	entity missile;
	entity flash;

	//W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_rpg7launcher_ammo, autocvar_g_balance_rpg7launcher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3.25 -3.25 -3.25', '3.25 3.25 3.25', FALSE, 2, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rpg7launcher_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), _org, v_forward * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	missile.owner = self;
	missile.realowner = _owner;
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


	//Start Normal Missile
	missile.rpg7_faillaunch = 0;
	
	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_RPG7_LAUNCHER;
	setsize (missile, '-3 -3 -3', '3 3 3'); // give it some size so it can be shot

	setorigin (missile, _org - v_forward * 3); // move it back so it hits the wall at the right point
	//W_SetupProjectileVelocity(missile, autocvar_g_balance_rpg7launcher_speedstart, 0);
	missile.velocity         = _vel;
	
	//End Normal Missile
	
		if (autocvar_g_casings >= 2)
			SpawnCasing (((random () * 1 + 1) * v_right) - (v_forward * (random () * 2500 + 25)) - ((random () * -1 - 2) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 33, self);

	
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
	
	//if not(self.flags & FL_MONSTER)
	//{
	//	// muzzle flash for 1st person view
	//	flash = spawn ();
	//	setmodel (flash, "models/flash.md3"); // precision set below
	//	SUB_SetFade (flash, time, 0.1);
	//	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	//	W_AttachToShotorg(flash, '5 0 0');
	//}

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
	PlayerGunRise(self, autocvar_g_balance_rpg7launcher_gunrise, random() * autocvar_g_balance_rpg7launcher_gunrun);
}

void raptor_fire_rpg(entity gun, string tagname)
{
    raptor_W_RPG7Rocket_Attack(gettaginfo(gun, gettagindex(gun, tagname)), normalize(v_forward + randomvec() * autocvar_g_vehicle_raptor_cannon_spread) * autocvar_g_balance_rpg7launcher_speedstart, self.owner);
}


void raptor_think()
{
}

void raptor_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = raptor_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_raptor_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_raptor_shield) * 100;
    self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    if not(self.bomb1.alpha)
    {
    	self.delay = time + autocvar_g_vehicle_raptor_bombs_refire;
    	self.lip   = time;
    }

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void raptor_land()
{    
    float hgt;
        
    hgt = raptor_altitude(512);    
    self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.95;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
    self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    if (self.spawnflags & 1) {
    	self.bomb2.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
    	self.bomb2.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	self.bomb3.avelocity_x = 90 + ((self.frame / 25) * 2000);
    }

    if(hgt < 16)
    {
        self.movetype = MOVETYPE_TOSS;
        self.think    = raptor_think;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void raptor_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.think      = raptor_land;
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

float raptor_takeoff()
{
    entity player, raptor;
    
    player = self;
    raptor = self.vehicle;
    self   = raptor;
    if(self.sound_nexttime < time)
    {        
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
    }   

    // Takeoff sequense
    if(raptor.frame < 25)
    {
        raptor.frame += 25 / (autocvar_g_vehicle_raptor_takeofftime / sys_frametime);
        raptor.velocity_z = min(raptor.velocity_z * 1.5, 256);
        self.bomb1.gun1.avelocity_y = 90 + ((raptor.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	if (self.spawnflags & 1) {
		self.bomb2.gun1.avelocity_y = 90 + ((raptor.frame / 25) * 25000);
        	self.bomb2.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	
	
	if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    	(vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(raptor, raptor, player);
		player.BUTTON_CROUCH = 0;
    	} else {
		player.vehicle_allowdriveby = 0;
        	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	}
	
        setorigin(player, raptor.origin + '0 0 32');
    }
    else
        player.PlayerPhysplug = raptor_frame;

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(raptor.dmg_time, vehicle_shield, autocvar_g_vehicle_raptor_shield, autocvar_g_vehicle_raptor_shield_regen_pause, autocvar_g_vehicle_raptor_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(raptor.dmg_time, vehicle_health, autocvar_g_vehicle_raptor_health, autocvar_g_vehicle_raptor_health_regen_pause, autocvar_g_vehicle_raptor_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(raptor.cnt, vehicle_energy, autocvar_g_vehicle_raptor_energy, autocvar_g_vehicle_raptor_energy_regen_pause, autocvar_g_vehicle_raptor_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    if not(raptor.bomb1.alpha)
    {
    	raptor.bomb1.alpha = raptor.bomb2.alpha = (time - raptor.lip) / (raptor.delay - raptor.lip);
    	player.vehicle_reload2 = bound(0, raptor.bomb1.alpha * 100, 100);
    }
    
    VEHICLE_UPDATE_PLAYER(player, health, raptor);
    VEHICLE_UPDATE_PLAYER(player, energy, raptor);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, raptor);

    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    	(vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(raptor, raptor, player);
		player.BUTTON_CROUCH = 0;
    	} else {
		player.vehicle_allowdriveby = 0;
        	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	}
	
    self = player;
    return 1;
}

void raptor_flare_touch()
{
    remove(self);
}

void raptor_flare_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
    self.health -= damage;
    if(self.health <= 0)
        remove(self);
}

void raptor_flare_think()
{
    self.nextthink = time + 0.1;
    entity _missile = findchainentity(enemy, self.owner);
    while(_missile)
    {
        if(_missile.flags & FL_PROJECTILE)
        if(vlen(self.origin - _missile.origin) < autocvar_g_vehicle_raptor_flare_range)
        if(random() > autocvar_g_vehicle_raptor_flare_chase)
            _missile.enemy = self;
        _missile = _missile.chain;
    }
    
    if(self.tur_impacttime < time)
        remove(self);
}

float raptor_frame()
{
    entity player, raptor;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    raptor = self.vehicle;
    self   = raptor;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_raptor_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_raptor_speed_forward;
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
    
    if(raptor.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = raptor.angles;
    df = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
        UpdateAuxiliaryXhair(player, trace_endpos, '1 0 1', 1);
    vang_x *= -1;
    df_x *= -1;
    if(df_x > 180)  df_x -= 360;
    if(df_x < -180) df_x += 360;
    if(df_y > 180)  df_y -= 360;
    if(df_y < -180) df_y += 360;

    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    raptor.avelocity_y = bound(-autocvar_g_vehicle_raptor_turnspeed, ftmp + raptor.avelocity_y * 0.9, autocvar_g_vehicle_raptor_turnspeed);

    // Pitch
    ftmp = 0;
    if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_raptor_pitchlimit) ftmp = 5;
    else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_raptor_pitchlimit) ftmp = -20;

    df_x = bound(-autocvar_g_vehicle_raptor_pitchlimit, df_x , autocvar_g_vehicle_raptor_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_raptor_pitchlimit, df_x + ftmp, autocvar_g_vehicle_raptor_pitchlimit);
    raptor.avelocity_x = bound(-autocvar_g_vehicle_raptor_pitchspeed, ftmp + raptor.avelocity_x * 0.9, autocvar_g_vehicle_raptor_pitchspeed);

    raptor.angles_x = anglemods(raptor.angles_x);
    raptor.angles_y = anglemods(raptor.angles_y);
    raptor.angles_z = anglemods(raptor.angles_z);

    if(autocvar_g_vehicle_raptor_movestyle == 1)
        makevectors('0 1 0' * raptor.angles_y);
    else
        makevectors(player.v_angle);

    df = raptor.velocity * -autocvar_g_vehicle_raptor_friction;

    if(player.movement_x != 0)
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_raptor_speed_forward;
        else if(player.movement_x < 0)
            df -= v_forward  * autocvar_g_vehicle_raptor_speed_forward;
    }

    if(player.movement_y != 0)
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_raptor_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_raptor_speed_strafe;

        raptor.angles_z = bound(-30,raptor.angles_z + (player.movement_y / autocvar_g_vehicle_raptor_speed_strafe),30);
	
	if (raptor.spawnflags & 1) {
		if(player.movement_y < 0) {
			if (self.bomb3.avelocity_y > 25000)
				self.bomb3.avelocity_x = 25000;
			else
				self.bomb3.avelocity_x += (frametime * 25000);
		} else if(player.movement_y > 0) {
			if (self.bomb3.avelocity_y < 25000)
				self.bomb3.avelocity_x = -25000;
			else
				self.bomb3.avelocity_x -= (frametime * 25000);
		} else {
			//Bring it back to 90 revolutions per..
			if (self.bomb3.avelocity_y > 90) {
				self.bomb3.avelocity_x -= (frametime * 25000);
			} else if (self.bomb3.avelocity_y < 90) {
				self.bomb3.avelocity_x += (frametime * 25000);
			}
			
		}
	}
    }
    else
    {
        raptor.angles_z *= 0.95;
        if(raptor.angles_z >= -1 && raptor.angles_z <= -1)
            raptor.angles_z = 0;
    }

    if(player.BUTTON_CROUCH)
        df -=   v_up * autocvar_g_vehicle_raptor_speed_down;
    else if (player.BUTTON_JUMP)
        df +=  v_up * autocvar_g_vehicle_raptor_speed_up;

	
    df = vehicles_waterspeed2(player, df);
    raptor.velocity = vehicles_waterfriction2(player, raptor, raptor.velocity);
    
    raptor.velocity  += df * frametime;
    player.velocity = player.movement  = raptor.velocity;
    setorigin(player, raptor.origin + '0 0 32');

    vector vf, ad;
    // Target lock & predict
    if(autocvar_g_vehicle_raptor_cannon_locktarget == 2)
    {
        if(raptor.gun1.lock_time < time || raptor.gun1.enemy.deadflag)
            raptor.gun1.enemy = world;
    
        if(trace_ent)
        if(trace_ent.movetype)
        if(trace_ent.takedamage)
        if(!trace_ent.deadflag)
        {
            if(teamplay)
            {
                if(trace_ent.team != player.team)
                {
                    raptor.gun1.enemy = trace_ent;
                    raptor.gun1.lock_time = time + 5;
                }
            }
            else
            {            
                raptor.gun1.enemy = trace_ent;
                raptor.gun1.lock_time = time + 0.5;
            }
        }
            
        if(raptor.gun1.enemy)
        {
            float i, distance, impact_time;

            vf = real_origin(raptor.gun1.enemy);
            UpdateAuxiliaryXhair(player, vf, '1 0 0.75', 1);
            vector _vel = raptor.gun1.enemy.velocity;
            if(raptor.gun1.enemy.movetype == MOVETYPE_WALK)
                _vel_z *= 0.1;
            
            if(autocvar_g_vehicle_raptor_cannon_predicttarget)
            {
                ad = vf;
                for(i = 0; i < 4; ++i)
                {
                    distance = vlen(ad - player.origin);
                    impact_time = distance / autocvar_g_vehicle_raptor_cannon_speed;
                    ad = vf + _vel * impact_time;
                }
                trace_endpos = ad;                        
            }
            else
                trace_endpos = vf;                        
        }
    }
    else if(autocvar_g_vehicle_raptor_cannon_locktarget == 1)
    {

        vehicles_locktarget((1 / autocvar_g_vehicle_raptor_cannon_locking_time) * frametime,
                             (1 / autocvar_g_vehicle_raptor_cannon_locking_releasetime) * frametime,
                             autocvar_g_vehicle_raptor_cannon_locked_time);

        if(self.lock_target != world)
        if(autocvar_g_vehicle_raptor_cannon_predicttarget)
        if(self.lock_strength == 1)
        {
            float i, distance, impact_time;

            vf = real_origin(raptor.lock_target);
            ad = vf;
            for(i = 0; i < 4; ++i)
            {
                distance = vlen(ad - raptor.origin);
                impact_time = distance / autocvar_g_vehicle_raptor_cannon_speed;
                ad = vf + raptor.lock_target.velocity * impact_time;
            }
            trace_endpos = ad;
        }

        if(self.lock_target)
        {
            if(raptor.lock_strength == 1)
                UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '1 0 0.75', 1);
            else if(self.lock_strength > 0.5)
                UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '0 1 1', 1);
            else if(self.lock_strength < 0.5)
                UpdateAuxiliaryXhair(player, real_origin(raptor.lock_target), '0.75 0 1', 1);
        }
    }


    vehicle_aimturret(raptor, trace_endpos, raptor.gun1, "fire1", 
                          autocvar_g_vehicle_raptor_cannon_pitchlimit_down * -1,  autocvar_g_vehicle_raptor_cannon_pitchlimit_up, 
                          autocvar_g_vehicle_raptor_cannon_turnlimit * -1,  autocvar_g_vehicle_raptor_cannon_turnlimit,  autocvar_g_vehicle_raptor_cannon_turnspeed);

    vehicle_aimturret(raptor, trace_endpos, raptor.gun2, "fire1", 
                          autocvar_g_vehicle_raptor_cannon_pitchlimit_down * -1,  autocvar_g_vehicle_raptor_cannon_pitchlimit_up, 
                          autocvar_g_vehicle_raptor_cannon_turnlimit * -1,  autocvar_g_vehicle_raptor_cannon_turnlimit,  autocvar_g_vehicle_raptor_cannon_turnspeed);

    /*
    ad = ad * 0.5;
    v_forward = vf * 0.5;
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, raptor);
    UpdateAuxiliaryXhair(player, trace_endpos, '0 1 0', 0);
    */
    
    if(raptor.spawnflags & 1) {
     //RPGs
     if(player.BUTTON_ATCK) {
      	//raptor.count = 0; //Will have to press R to resume reload
      	if(raptor.attack_finished_single <= time)
      	if(raptor.vehicle_ammo1 > 1)
      	{
       		 raptor.misc_bulletcounter += 1;
       		 raptor.attack_finished_single = time + 0.1;
        	 if(raptor.misc_bulletcounter <= 2)
       		     raptor_fire_rpg(self.gun1, "fire1");
        	else if(raptor.misc_bulletcounter == 3)
        	    raptor_fire_rpg(self.gun2, "fire1");
        	else
        	{
        	    raptor.attack_finished_single = time + 0.1 * 2;
        	    raptor_fire_rpg(self.gun2, "fire1");
        	    raptor.misc_bulletcounter = 0;
        	}
        	raptor.vehicle_ammo1 -= 1;
        	self.cnt = time;
      	}
     } else {
     		//if (raptor.count == 1) {
			//Using .ammount as timer rather than .cnt
			vehicles_regen(raptor.ammount, vehicle_ammo1, 1 * 16,
                                           autocvar_g_vehicle_raptor_energy_regen_pause, autocvar_g_vehicle_raptor_energy_regen,
					   frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    		//} else
		if (player.impulse == 20) {
			if(player.BUTTON_HOOK) {
				//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
				//vehicles_replenishAmmo(player, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
				//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
				vehicles_replenishAmmo(player, raptor, ammo_rockets, vehicle_ammo1_current, vehicle_ammo1_max, 16, 5);
			} else {
				//raptor.count = 1;
				sound (raptor, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
			}
		}
     }
     
     
    } else {
     //Normal
     if(player.BUTTON_ATCK)
     if(raptor.attack_finished_single <= time)
     if(raptor.vehicle_energy > autocvar_g_vehicle_raptor_cannon_cost)
     {
        raptor.misc_bulletcounter += 1;
        raptor.attack_finished_single = time + autocvar_g_vehicle_raptor_cannon_refire;
        if(raptor.misc_bulletcounter <= 2)
            raptor_fire_cannon(self.gun1, "fire1");
        else if(raptor.misc_bulletcounter == 3)
            raptor_fire_cannon(self.gun2, "fire1");
        else
        {
            raptor.attack_finished_single = time + autocvar_g_vehicle_raptor_cannon_refire * 2;
            raptor_fire_cannon(self.gun2, "fire1");
            raptor.misc_bulletcounter = 0;
        }
        raptor.vehicle_energy -= autocvar_g_vehicle_raptor_cannon_cost;
        self.cnt = time;
     }
    }

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(raptor.dmg_time, vehicle_shield, autocvar_g_vehicle_raptor_shield, autocvar_g_vehicle_raptor_shield_regen_pause, autocvar_g_vehicle_raptor_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(raptor.dmg_time, vehicle_health, autocvar_g_vehicle_raptor_health, autocvar_g_vehicle_raptor_health_regen_pause, autocvar_g_vehicle_raptor_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(raptor.cnt, vehicle_energy, autocvar_g_vehicle_raptor_energy, autocvar_g_vehicle_raptor_energy_regen_pause, autocvar_g_vehicle_raptor_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    
    if(raptor.vehicle_weapon2mode == RSM_BOMB)
    {
        if(time > raptor.lip + autocvar_g_vehicle_raptor_bombs_refire)
        if(player.BUTTON_ATCK2)
	if (player.vehicle_reload2 == 100)
        {
	    if(raptor.spawnflags & 1) {
	    	    if (raptor.gun1.count == 1) {
	    		//if raptor.gun1.count is 1 we are loaded with a nuke
	    		raptor_rightbombfly();
			raptor_nukefly();
			raptor.gun1.count = 0;
			setmodel(raptor.bomb1,"models/vehicles/clusterbomb_folded.md3");
			sound (raptor, CH_WEAPON_A, "weapons/rocket_fire.wav", VOL_BASE, ATTN_NORM);
		    } else {
        	    	raptor_bombfly();
			sound (raptor, CH_WEAPON_A, "weapons/rocket_fire.wav", VOL_BASE, ATTN_NORM);
		    }
	    } else {
	    	    if (raptor.gun1.count == 1) {
	    		//if raptor.gun1.count is 1 we are loaded with a nuke
	    		raptor_rightbombdrop();
			raptor_nukedrop();
			raptor.gun1.count = 0;
			setmodel(raptor.bomb1,"models/vehicles/clusterbomb_folded.md3");
		    } else {
        	    	raptor_bombdrop();
		    }
	    }
	    //raptor.vehicle_ammo2_current -= autocvar_g_vehicle_raptor_bombs_refire;
	    //raptor.bomb1.alpha = raptor.bomb2.alpha = 0.001;
	    
            raptor.delay = time + autocvar_g_vehicle_raptor_bombs_refire;
            raptor.lip   = time;
        }        
    }
    else
    {
        if(time > raptor.lip + autocvar_g_vehicle_raptor_flare_refire)
        if(player.BUTTON_ATCK2)
        {
            float i;
            entity _flare;
            
            for(i = 0; i < 3; ++i)
            {
            _flare = spawn();
            setmodel(_flare, "models/runematch/rune.mdl"); 
            _flare.effects = EF_LOWPRECISION | EF_FLAME;
            _flare.scale = 0.5;
            setorigin(_flare, self.origin - '0 0 16');
            _flare.movetype = MOVETYPE_TOSS;
            _flare.gravity = 0.15;
            _flare.velocity = 0.25 * raptor.velocity + (v_forward + randomvec() * 0.25)* -500;
            _flare.think = raptor_flare_think;
            _flare.nextthink = time;
            _flare.owner = raptor;
            _flare.solid = SOLID_CORPSE;
            _flare.takedamage = DAMAGE_YES;
            _flare.event_damage = raptor_flare_damage;
            _flare.health = 20;
            _flare.tur_impacttime = time + autocvar_g_vehicle_raptor_flare_lifetime;
            _flare.touch = raptor_flare_touch;
            }
            raptor.delay = time + autocvar_g_vehicle_raptor_flare_refire;
            raptor.lip   = time;
        }
    }
    
    if (raptor.vehicle_ammo2_current > 0) {
    	raptor.bomb1.alpha = raptor.bomb2.alpha = (time - raptor.lip) / (raptor.delay - raptor.lip);
    	player.vehicle_reload2 = bound(0, raptor.bomb1.alpha * 100, 100);
    	if (player.vehicle_reload2 < 100) {
		raptor.vehicle_ammo2_current = raptor.vehicle_ammo2_current - (1 * sys_frametime);
	}
    }

	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 player ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		//vehicles_replenishAmmo(player, raptor, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
		if(raptor.pushltime < time) {
			sound (raptor, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
		vehicles_replenishAmmo(player, raptor, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 1);
		
		if (raptor.gun1.count != 1)
		if (player.weapon == WEP_NUKE_LAYER)
		{
			entity oldself;
			oldself = self;
			self = player;
			//We lose the weapon
			if (self.weapon == 0)
			{
				// just in case
			}
			else if(!WEPSET_CONTAINS_EW(self, self.weapon)) 
			{
				//Do nothing
			}
			else
			{
				WEPSET_ANDNOT_EW(self, self.weapon);
				W_SwitchWeapon_Force(self, w_getbestweapon(self));
			}
			//
			self = oldself;
			raptor.gun1.count = 1;
			setmodel(raptor.bomb1,"models/vehicles/nukebomb.md3");
			sprint(player, sprintf("Nuclear Weapon Loaded. Estimated Damage Radius: %f %% miles\n", (autocvar_g_balance_nukelayer_radius/63360)));
		}
	}

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, raptor);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_raptor_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

    VEHICLE_UPDATE_PLAYER(player, health, raptor);
    VEHICLE_UPDATE_PLAYER(player, energy, raptor);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, raptor);

    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    	(vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(raptor, raptor, player);
		player.BUTTON_CROUCH = 0;
    	} else {
		player.vehicle_allowdriveby = 0;
        	player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
	}
    
    player.vehicle_ammo1_current = raptor.vehicle_ammo1_current;
    player.vehicle_ammo1_max = raptor.vehicle_ammo1_max;
    player.vehicle_ammo2_current = raptor.vehicle_ammo2_current;
    player.vehicle_ammo2_max = raptor.vehicle_ammo2_max;
    
    self = player;
    return 1;
}

void raptor_blowup()
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

void raptor_diethink()
{
	if(time >= self.wait)
		self.think = raptor_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void raptor_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = raptor_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = raptor_blowup;
	
	helicopter_rotor_die(self.rotorboxft); 
    	helicopter_rotor_die(self.rotorboxmf); 
	helicopter_rotor_die(self.rotorboxmb); 
    	helicopter_rotor_die(self.rotorboxbk);
	
	helicopter_rotor_die(self.rotorboxftr); 
    	helicopter_rotor_die(self.rotorboxmfr); 
	helicopter_rotor_die(self.rotorboxmbr); 
    	helicopter_rotor_die(self.rotorboxbkr);
	
	if (self.spawnflags & 1)
	{
		helicopter_rotor_die(self.rotorboxft_t); //Using this, sets .think to something other than null, but not much :)
    		helicopter_rotor_die(self.rotorboxmf_t); //Middle front
		helicopter_rotor_die(self.rotorboxmid_t);
		helicopter_rotor_die(self.rotorboxmb_t); //Mid back
    		helicopter_rotor_die(self.rotorboxbk_t);
	}
}

void raptor_impact()
{
    if(autocvar_g_vehicle_raptor_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_raptor_bouncepain_x, autocvar_g_vehicle_raptor_bouncepain_y, autocvar_g_vehicle_raptor_bouncepain_z);
}

// If we dont do this ever now and then, the raptors rotors
// stop working, presumably due to angle overflow. cute.
void raptor_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

float raptor_impulse(float _imp)
{
    switch(_imp)
    {
        case 10:
        case 15:        
        case 18:
            self.vehicle.vehicle_weapon2mode += 1;
            if(self.vehicle.vehicle_weapon2mode > RSM_LAST)
                self.vehicle.vehicle_weapon2mode = RSM_FIRST;
            
            CSQCVehicleSetup(self, 0);
            return TRUE;
        case 12:
        case 16:
        case 19:
            self.vehicle.vehicle_weapon2mode -= 1;
            if(self.vehicle.vehicle_weapon2mode < RSM_FIRST)
                self.vehicle.vehicle_weapon2mode = RSM_LAST;
            
            CSQCVehicleSetup(self, 0);
            return TRUE;

        /*			
        case 17: // toss gun, could be used to exit?
            break;
        case 20: // Manual minigun reload?
            break;
        */
    }    
    return FALSE;
}

void raptor_spawn(float _f)
{
    self.buff_wont_ignite = 1;
    
    if(!self.gun1)
    {
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '25 0 5');
        
        self.vehicles_impusle   = raptor_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"models/vehicles/clusterbomb_folded.md3");
        setmodel(self.bomb2,"models/vehicles/clusterbomb_folded.md3");
	if (self.spawnflags & 1) {
		setmodel(self.gun1, "models/turrets/mlrs.md3");
		setmodel(self.gun2, "models/turrets/mlrs.md3");
	} else {
        	setmodel(self.gun1, "models/vehicles/raptor_gun.dpm");
        	setmodel(self.gun2, "models/vehicles/raptor_gun.dpm");
	}
        setmodel(self.tur_head, "models/vehicles/raptor_body.dpm");

        setattachment(self.bomb1, self, "bombmount_left");
        setattachment(self.bomb2, self, "bombmount_right");
        setattachment(self.tur_head, self,"root");

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
        setmodel(spinner,"models/vehicles/spinner.dpm");
        setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/spinner.dpm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
        self.bomb1.gun2 = spinner;
	
	if (self.spawnflags & 1) {
	        spinner = spawn();
       		spinner.owner = self;
        	setmodel(spinner,"models/vehicles/spinner.dpm");
        	setattachment(spinner, self, "engine_left");
		spinner.scale = 2;
		setorigin(spinner, '0 0 16');
        	spinner.movetype = MOVETYPE_NOCLIP;
        	spinner.avelocity = '0 90 0';
        	self.bomb2.gun1 = spinner;

        	spinner = spawn();
        	spinner.owner = self;
        	setmodel(spinner,"models/vehicles/spinner.dpm");
        	setattachment(spinner, self, "engine_right");
		spinner.scale = 2;
		setorigin(spinner, '0 0 16');
        	spinner.movetype = MOVETYPE_NOCLIP;
        	spinner.avelocity = '0 -90 0';
        	self.bomb2.gun2 = spinner;
		
		setorigin(self.bomb1, '0 0 24');
		setorigin(self.bomb2, '0 0 24');
		
		
		spinner = spawn();
        	spinner.owner = self;
        	setmodel(spinner,"models/vehicles/spinner.dpm");
		spinner.angles = '0 0 90';
        	setattachment(spinner, self, "");
		setorigin(spinner, '-172 0 32');
        	spinner.movetype = MOVETYPE_NOCLIP;
        	//spinner.avelocity = '0 -90 0';
		//spinner.avelocity = '-90 0 0';
		//spinner.avelocity = '0 0 -90';
		spinner.avelocity = '-90 0 0';
        	self.bomb3 = spinner;
	}

        // Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;

        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_raptor_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.rotorboxftr = spawn();
	self.rotorboxmfr = spawn();
	self.rotorboxmbr = spawn();
    	self.rotorboxbkr = spawn();
    }
    
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_raptor_health;
    self.vehicle_shield = autocvar_g_vehicle_raptor_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;
    if (self.spawnflags & 1) {
    	self.bomb2.gun1.avelocity_y = 90;
    	self.bomb2.gun2.avelocity_y = -90;
    }

    setsize(self, RAPTOR_MIN, RAPTOR_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_raptor_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_raptor_bouncestop;    
    self.vehicle_impact = raptor_impact;    
    self.damageforcescale = 0.25;
    
    local float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly	

    if (self.spawnflags & 1) {
    	local vector vorg;
    	vorg = gettaginfo(self, gettagindex(self, "engine_left"));
    	vorg -= self.origin;
    	vorg_y = vorg_y + 32; //Move it over more
    	//Spinning rotor death areas
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x+64, vorg_y, vorg_z-64-16);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x, vorg_y+64, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x, vorg_y-64, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x-64, vorg_y, vorg_z-64+16);
    
    	vorg = gettaginfo(self, gettagindex(self, "engine_right"));
    	vorg -= self.origin;
    	vorg_y = vorg_y - 32;
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftr, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x+64, vorg_y, vorg_z-64-16);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfr, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x, vorg_y+64, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbr, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x, vorg_y-64, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkr, RAPTORHELIROTOR_MIN_HBF2, RAPTORHELIROTOR_MAX_HBF2, vorg_x-64, vorg_y, vorg_z-64+16);
    
   
    	self.rotorboxft_t = spawn();
	self.rotorboxmf_t = spawn();
	self.rotorboxmid_t = spawn();
	self.rotorboxmb_t = spawn();
    	self.rotorboxbk_t = spawn();
    	vorg = self.bomb3.origin;
    	//Tail rotor
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft_t, RAPTORHELIROTOR_MIN_HBF_T, RAPTORHELIROTOR_MAX_HBF_T, vorg_x+40, vorg_y, vorg_z);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf_t, RAPTORHELIROTOR_MIN_HBB_T, RAPTORHELIROTOR_MAX_HBB_T, vorg_x+16, vorg_y, vorg_z);	
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmid_t, RAPTORHELIROTOR_MIN_HBB_T, RAPTORHELIROTOR_MAX_HBB_T, vorg_x, vorg_y, vorg_z);	
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb_t, RAPTORHELIROTOR_MIN_HBB_T, RAPTORHELIROTOR_MAX_HBB_T, vorg_x-16, vorg_y, vorg_z);	
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk_t, RAPTORHELIROTOR_MIN_HBF_T, RAPTORHELIROTOR_MAX_HBF_T, vorg_x-40, vorg_y, vorg_z);
    } else {
    	local vector vorg;
    	vorg = gettaginfo(self, gettagindex(self, "engine_left"));
    	vorg -= self.origin;
    	vorg_y = vorg_y + 32; //Move it over more
    	//Spinning rotor death areas
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x+32, vorg_y, vorg_z-64-16);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x, vorg_y+32, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x, vorg_y-32, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x-32, vorg_y, vorg_z-64+16);
    
    	vorg = gettaginfo(self, gettagindex(self, "engine_right"));
    	vorg -= self.origin;
    	vorg_y = vorg_y - 32;
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftr, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x+32, vorg_y, vorg_z-64-16);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfr, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x, vorg_y+32, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbr, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x, vorg_y-32, vorg_z-64);
    	helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkr, RAPTORHELIROTOR_MIN_HBF, RAPTORHELIROTOR_MAX_HBF, vorg_x-32, vorg_y, vorg_z-64+16);
    }   
      
    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_raptor()
{
    if(!autocvar_g_vehicle_raptor)
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
      
    float caammomax;
    
    self.vehicle_flags |= VHF_DMGSHAKE;
    self.vehicle_flags |= VHF_DMGROLL;
   
    if(autocvar_g_vehicle_raptor_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_raptor_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_raptor_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_raptor_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/raptor.dpm");
    precache_model ("models/vehicles/raptor_gun.dpm");
    precache_model ("models/vehicles/spinner.dpm");
    precache_model ("models/vehicles/raptor_cockpit.dpm");
    //precache_model ("models/vehicles/clusterbomb.md3");
    precache_model ("models/vehicles/clusterbomb_folded.md3");
    precache_model ("models/vehicles/raptor_body.dpm");
    precache_model ("models/sphere/sphere.md3");
    precache_model ("models/sphere/sphexp.md3");
    precache_model ("models/vhshield.md3");
    
    precache_sound ("vehicles/raptor_fly.wav");
    precache_sound ("vehicles/raptor_speed.wav");
    precache_sound ("vehicles/missile_alarm.wav");
    precache_sound ( "weapons/rocket_impact.wav");
    caammomax = 0;
    if (self.spawnflags & 1) {
    	precache_model ("models/turrets/mlrs.md3");
    	precache_sound ( "weapons/rocket_fire.wav");
	caammomax = 64;
    }
    
    	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
    
    if not (vehicle_initialize(
             "Raptor",
             "models/vehicles/raptor.dpm",
             "",
             "models/vehicles/raptor_cockpit.dpm",
             "", "tag_hud", "tag_camera",
             HUD_RAPTOR,
             RAPTOR_MIN, RAPTOR_MAX,
             FALSE,
             raptor_spawn, autocvar_g_vehicle_raptor_respawntime,
             raptor_frame,
             raptor_enter, raptor_exit,
             raptor_die,   raptor_think,
             FALSE, 
             autocvar_g_vehicle_raptor_health,
             autocvar_g_vehicle_raptor_shield, autocolor, caammomax, autocvar_g_vehicle_raptor_bombs_refire * 2))
    {
        remove(self);
        return;
    }
    
    
}

void spawnfunc_vehicle_mraptor()
{
	self.spawnflags = 1;
	spawnfunc_vehicle_raptor();
}
#endif // SVQC
