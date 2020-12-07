#define NIEUPORT_MIN '-70 -70 0'
#define NIEUPORT_MAX '70 70 120'

const vector NIEUPORTROTOR_MIN_HBF_T = '-10 -10 -40'; //Back and front trunk for this model
const vector NIEUPORTROTOR_MAX_HBF_T = '10 10 40';

const vector NIEUPORTROTOR_MIN_HBB_T = '-10 -10 -60'; //Middle
const vector NIEUPORTROTOR_MAX_HBB_T = '10 10 60';

#ifdef SVQC
float autocvar_g_vehicle_nieuport;

float autocvar_g_vehicle_nieuport_mass;

float autocvar_g_vehicle_nieuport_respawntime;
float autocvar_g_vehicle_nieuport_takeofftime;

float autocvar_g_vehicle_nieuport_movestyle;
float autocvar_g_vehicle_nieuport_turnspeed;
float autocvar_g_vehicle_nieuport_pitchspeed;
float autocvar_g_vehicle_nieuport_pitchlimit;

float autocvar_g_vehicle_nieuport_speed_forward;
float autocvar_g_vehicle_nieuport_speed_strafe;
float autocvar_g_vehicle_nieuport_speed_up;
float autocvar_g_vehicle_nieuport_speed_down;
float autocvar_g_vehicle_nieuport_friction;

float autocvar_g_vehicle_nieuport_cannon_refire;
float autocvar_g_vehicle_nieuport_cannon_speed;
float autocvar_g_vehicle_nieuport_bombs_refire;
float autocvar_g_vehicle_nieuport_bombs_ammo_max;
float autocvar_g_vehicle_nieuport_bombs_ammo_cost;
float autocvar_g_vehicle_nieuport_bombs_ammo_regen;
float autocvar_g_vehicle_nieuport_bombs_ammo_regen_pause;
float autocvar_g_vehicle_nieuport_bomb_radius;
float autocvar_g_vehicle_nieuport_bomb_damage;
float autocvar_g_vehicle_nieuport_bomb_fragments;
float autocvar_g_vehicle_nieuport_bomb_fragments_frames;

float autocvar_g_vehicle_nieuport_flare_range;

float autocvar_g_vehicle_nieuport_energy;
float autocvar_g_vehicle_nieuport_energy_regen;
float autocvar_g_vehicle_nieuport_energy_regen_pause;

float autocvar_g_vehicle_nieuport_health;
float autocvar_g_vehicle_nieuport_health_regen;
float autocvar_g_vehicle_nieuport_health_regen_pause;

float autocvar_g_vehicle_nieuport_shield;
float autocvar_g_vehicle_nieuport_shield_regen;
float autocvar_g_vehicle_nieuport_shield_regen_pause;

float autocvar_g_vehicle_nieuport_bouncefactor;
float autocvar_g_vehicle_nieuport_bouncestop;
vector autocvar_g_vehicle_nieuport_bouncepain;

void nieuport_spawn(float);
float nieuport_frame();
float nieuport_takeoff();

void aeroplane_prop_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s);
void helicopter_rotor_die(entity hitbox);
void helicopter_rotor_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s);
void atmine_destroy_gamemodel_tree(entity eburn);
.entity rotorboxft;
.entity rotorboxmf;
.entity rotorboxmb;
.entity rotorboxbk;
.entity rotorboxftd1;

.entity bomb1;
.entity bomb2;

//We'll add these instead of using the mg_ ones, so as not to cause confusion
//if one wanted to add mounted guns to vehics (which is done in several vehicles)
.float vehic_triggerlag;
.float vehic_triggerlag_time;
.float vehic_triggerlag_maxtime;

void nieuport_FragsOverTime (void)
{
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
		fireBallisticBullet(self.origin, randomvec(), 1,
		 autocvar_g_balance_explosivevest_primary_fragment_speed, 5,
		 autocvar_g_balance_explosivevest_primary_fragment_damage,
		 autocvar_g_balance_explosivevest_primary_fragment_headshotbonus,
		 autocvar_g_balance_explosivevest_primary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNELHOT,
		 autocvar_g_balance_explosivevest_primary_fragment_gravity,
		 autocvar_g_balance_explosivevest_primary_fragment_bulletconstant,
		 autocvar_g_balance_explosivevest_primary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();			
	}
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_vehicle_nieuport_bomb_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}


void nieuport_FragsOverTimeSpawn (entity gren)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	e.think = nieuport_FragsOverTime;
	e.count = floor(autocvar_g_vehicle_nieuport_bomb_fragments / autocvar_g_vehicle_nieuport_bomb_fragments_frames)+1;
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void nieuport_Mine_Damage_Tree (entity mymine)
{
	entity eburn;
	eburn = findradius(mymine.origin, autocvar_g_vehicle_nieuport_bomb_radius * 0.5);
	while(eburn)
	{
		if (eburn.classname == "tree") {
			mine_damage_tree(eburn, mymine, autocvar_g_vehicle_nieuport_bomb_damage * autocvar_g_balance_minelayer_damagerate_tree);
		}
		
		eburn = eburn.chain;
	}
	
	eburn = findradius(mymine.origin, autocvar_g_vehicle_nieuport_bomb_radius*0.35);
	while(eburn)
	{
		if (eburn.classname == "misc_gamemodel") {
 			atmine_destroy_gamemodel_tree(eburn);	
		}
		
		eburn = eburn.chain;
	}
}

void nieuport_bomb_boom()
{
	   
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
	
		//print(ftos(self.projectiledeathtype), "-nieuport-bomb-projdeathtype\n");

	//Start explosivevest Fragmentation
	if(autocvar_g_vehicle_nieuport_bomb_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_nieuport_bomb_fragments;sc = sc + 1) {
			//print(sprintf("Spawning bullets: %f\n", sc));
		
			fireBallisticBullet(self.origin, randomvec(), 1,
			 autocvar_g_balance_explosivevest_primary_fragment_speed, 5,
			 autocvar_g_balance_explosivevest_primary_fragment_damage,
			 autocvar_g_balance_explosivevest_primary_fragment_headshotbonus,
			 autocvar_g_balance_explosivevest_primary_fragment_force,
			 DEATH_FRAGMENT,
			 PROJECTILE_BULLETSHRAPNELHOT,
			 autocvar_g_balance_explosivevest_primary_fragment_gravity,
			 autocvar_g_balance_explosivevest_primary_fragment_bulletconstant,
			 autocvar_g_balance_explosivevest_primary_fragment_coreshotbonus);
		 
			endFireBallisticBullet();
		}
	} else {
		nieuport_FragsOverTimeSpawn(self); //Spread out fragment spawning
	}
	//Finish explosivevest Fragmentation
	
	remove(self);
}

void nieuport_bombdrop()
{
    entity bomb_1;

    bomb_1 = spawn();

    setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bombmount_center")));

    bomb_1.movetype        = MOVETYPE_BOUNCE;
    bomb_1.velocity        = self.velocity;
    bomb_1.touch           = nieuport_bomb_boom;
    //bomb_1.think           = nieuport_bomb_burst;
    //bomb_1.cnt             = time + 10;

    //if(autocvar_g_vehicle_nieuport_bomblet_alt)
    //    bomb_1.nextthink   = time;
    //else
    //    bomb_1.nextthink   = time + autocvar_g_vehicle_nieuport_bomblet_time;

    bomb_1.owner           = self;
    bomb_1.realowner       = self.owner;
    bomb_1.solid           = SOLID_BBOX;
    bomb_1.gravity         = 1;
    bomb_1.projectiledeathtype = DEATH_SBROCKET;

    PROJECTILE_MAKETRIGGER(bomb_1);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
}

void nieuport_nukedrop()
{
    entity bomb_1;

    bomb_1 = spawn();
    W_Nuke_Set_Standard(bomb_1); //Set the yeild etc
    
    setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bombmount_center")));

    bomb_1.movetype        = MOVETYPE_BOUNCE;
    bomb_1.velocity        = self.velocity;
    bomb_1.touch           = W_Nuke_Explode;

    bomb_1.owner           = self;
    bomb_1.realowner       = self.owner;
    //print(etos(self.owner)," \n");
    bomb_1.solid           = SOLID_BBOX;
    bomb_1.gravity         = 0.65; //Streamer
    bomb_1.projectiledeathtype = WEP_NUKE_LAYER;

    PROJECTILE_MAKETRIGGER(bomb_1);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_NUKEBOMB, TRUE);
}

float nieuport_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

void nieuport_fire_cannon(string tagname)
{
    vector v;
    entity _oldself = self;

    v = gettaginfo(self, gettagindex(self, tagname));
    
    //print(etos(self)," self and owner ",  etos(self.owner), "\n");
    self = self.owner;
  
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_sportster_cannon_spread, autocvar_g_vehicle_nieuport_cannon_speed, 5, autocvar_g_vehicle_sportster_cannon_damage, autocvar_g_vehicle_sportster_cannon_headshotbonus, autocvar_g_vehicle_sportster_cannon_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_sportster_cannon_bulletconstant, autocvar_g_vehicle_sportster_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    self = _oldself;
    
    sound (self, CH_WEAPON_A, "weapons/uzi_fire_bass.ogg", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
	    
    UziFlash();
    sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', tagname);
    
    if (autocvar_g_vehicle_sportster_cannon_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 105, self);
	}
    }
    
}

void nieuport_think()
{
}


void nieuport_blowup()
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

void nieuport_diethink()
{
	if(time >= self.wait)
		self.think = nieuport_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void nieuport_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = nieuport_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = nieuport_blowup;

	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxftd1); 
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
}


void nieuport_enter()
{
    self.vehic_triggerlag = 0; //For open bolt trigger lag
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = nieuport_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_nieuport_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_nieuport_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    //self.delay = time + autocvar_g_vehicle_nieuport_bombs_refire;
    //self.lip   = time;
    

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void nieuport_land()
{    
    float hgt;
        
    hgt = nieuport_altitude(512);    
    //Glide to a stop
    self.velocity = (self.velocity * 1) + ('0 0 -200' * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.99;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
    self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;

    if(hgt < 16)
    {
    	//If we're tipped to much we'll crash and be destroyed
	//Greater wingspan than the fokker, wing can touch ground easier
    	if(
	(self.angles_z >= 50 && self.angles_z <= 180) ||
	(self.angles_z <= -50 && self.angles_z >= -180))
	{
		Damage(self, self, self.owner, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} else {
	        self.think    = nieuport_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void nieuport_exit(float eject)
{
    vector spot;
    self.vehic_triggerlag = 0; //For open bolt trigger lag
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.bomb1.gun1.count = 0;
        self.think      = nieuport_land;
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

float nieuport_takeoff()
{
    entity player, nieuport;
    
    player = self;
    nieuport = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (nieuport.bomb1.gun1.count == 0)) {
	    	nieuport.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (nieuport.bomb1.gun1.count == 1)) {
	  	nieuport.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = nieuport;
    if(self.sound_nexttime < time)
    {    
        if (nieuport.bomb1.gun1.count) {    
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }   

    // Takeoff sequense
    if(nieuport.bomb1.gun1.count == 1) {
    if(nieuport.frame < 25)
    {
        makevectors(nieuport.angles);
    	nieuport.movetype       = MOVETYPE_WALK;
        nieuport.frame += 25 / (autocvar_g_vehicle_nieuport_takeofftime / sys_frametime);
        if(nieuport.frame > 23)
		nieuport.velocity_z = min(1 + (nieuport.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = 90 + ((nieuport.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_nieuport_speed_forward * 0.3 * (nieuport.frame/25),0.075);
    }
    else
    {
    	nieuport.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = nieuport_frame;
    }
    } else {
    	//Engine off?
    	nieuport.movetype     = MOVETYPE_BOUNCE;
    	if (nieuport.frame > 0) {
        	nieuport.frame -= 25 / (autocvar_g_vehicle_nieuport_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((nieuport.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(nieuport.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(nieuport.angles_z >= 50 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -50 && nieuport.angles_z >= -180))
	{
		Damage(nieuport, nieuport, player, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 
    
    player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    setorigin(player, nieuport.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(nieuport.dmg_time, vehicle_shield, autocvar_g_vehicle_nieuport_shield, autocvar_g_vehicle_nieuport_shield_regen_pause, autocvar_g_vehicle_nieuport_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(nieuport.dmg_time, vehicle_health, autocvar_g_vehicle_nieuport_health, autocvar_g_vehicle_nieuport_health_regen_pause, autocvar_g_vehicle_nieuport_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (nieuport.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(nieuport.cnt, vehicle_energy, autocvar_g_vehicle_nieuport_energy, autocvar_g_vehicle_nieuport_energy_regen_pause, autocvar_g_vehicle_nieuport_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		nieuport.vehic_triggerlag = 0; //For open bolt trigger lag
    		nieuport.count = 1;
		sound (nieuport, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, nieuport, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
    }

    if not(nieuport.bomb1.alpha) nieuport.bomb1.alpha = nieuport.bomb2.alpha = 0.001;
    //player.vehicle_reload2 = bound(0, nieuport.bomb1.alpha * 100, 100);
    
    VEHICLE_UPDATE_PLAYER(player, health, nieuport);
    VEHICLE_UPDATE_PLAYER(player, energy, nieuport);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, nieuport);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    self = player;
    return 1;
}

//Flare Stuff removed

float nieuport_frame()
{
    entity player, nieuport;
    float altcontrols = 0;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    altcontrols = player.vehicle_alternateaircontrols;
    nieuport = self.vehicle;
    self   = nieuport;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_nieuport_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_nieuport_speed_forward;
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
    
    if(nieuport.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = nieuport.angles;
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
		ftmp = player.movement_y * -1 * autocvar_g_vehicle_nieuport_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	nieuport.avelocity_y = bound(-autocvar_g_vehicle_nieuport_turnspeed, ftmp + nieuport.avelocity_y * 0.9, autocvar_g_vehicle_nieuport_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(player.movement_x != 0 && !player.BUTTON_HOOK && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_x * -1 * autocvar_g_vehicle_nieuport_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	nieuport.avelocity_x = bound(-autocvar_g_vehicle_nieuport_pitchspeed, ftmp + nieuport.avelocity_x * 0.9, autocvar_g_vehicle_nieuport_pitchspeed);
    	
	
	
	if(nieuport.angles_y > 180)  nieuport.angles_y -= 360;
    	if(nieuport.angles_y < -180) nieuport.angles_y += 360;
	
		if(nieuport.angles_y >= -1 && nieuport.angles_y <= -1)
            	nieuport.angles_y = 0;
		
	if(nieuport.angles_x > 180)  nieuport.angles_x -= 360;
    	if(nieuport.angles_x < -180) nieuport.angles_x += 360;
	
	
		if(nieuport.angles_x >= -1 && nieuport.angles_x <= -1)
            	nieuport.angles_x = 0;
		
	if(nieuport.angles_z > 180)  nieuport.angles_z -= 360;
    	if(nieuport.angles_z < -180) nieuport.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    
    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    nieuport.avelocity_y = bound(-autocvar_g_vehicle_nieuport_turnspeed, ftmp + nieuport.avelocity_y * 0.9, autocvar_g_vehicle_nieuport_turnspeed);

    // Pitch
    ftmp = 0;
    if not(player.BUTTON_HOOK) {
    	if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_nieuport_pitchlimit) ftmp = 5;
    	else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_nieuport_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_nieuport_pitchlimit, df_x , autocvar_g_vehicle_nieuport_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_nieuport_pitchlimit, df_x + ftmp, autocvar_g_vehicle_nieuport_pitchlimit);
    nieuport.avelocity_x = bound(-autocvar_g_vehicle_nieuport_pitchspeed, ftmp + nieuport.avelocity_x * 0.9, autocvar_g_vehicle_nieuport_pitchspeed);

    
    //END
    ///////////////
    }
    
    
    nieuport.angles_x = anglemods(nieuport.angles_x);
    nieuport.angles_y = anglemods(nieuport.angles_y);
    nieuport.angles_z = anglemods(nieuport.angles_z);

    if(autocvar_g_vehicle_nieuport_movestyle == 1)
        makevectors('0 1 0' * nieuport.angles_y);
    else
        makevectors(player.v_angle);

    df = nieuport.velocity * -autocvar_g_vehicle_nieuport_friction;

	//print(sprintf("m1 = %f\n", v_forward));
    if(player.BUTTON_HOOK) {
    		if(player.movement_x > 0) {
    	    		nieuport.bomb1.gun2.count = bound(autocvar_g_vehicle_nieuport_speed_forward * 0.3, nieuport.bomb1.gun2.count + (128 * sys_frametime),autocvar_g_vehicle_nieuport_speed_forward);
    			if((nieuport.bomb1.gun2.pushltime < time) && !(nieuport.bomb1.gun2.count >= autocvar_g_vehicle_nieuport_speed_forward))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Raised to %f %%\n", (nieuport.bomb1.gun2.count/autocvar_g_vehicle_nieuport_speed_forward)*100));
    				nieuport.bomb1.gun2.pushltime = time + 0.25;
			}
		} else if(player.movement_x < 0) {
    	    		nieuport.bomb1.gun2.count = bound(autocvar_g_vehicle_nieuport_speed_forward * 0.3, nieuport.bomb1.gun2.count - (128 * sys_frametime),autocvar_g_vehicle_nieuport_speed_forward);
    			if((nieuport.bomb1.gun2.pushltime < time) && !(nieuport.bomb1.gun2.count <= autocvar_g_vehicle_nieuport_speed_forward * 0.3))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Lowered to %f %%\n", (nieuport.bomb1.gun2.count/autocvar_g_vehicle_nieuport_speed_forward)*100));
    				nieuport.bomb1.gun2.pushltime = time + 0.25;
			}
        
   			if(nieuport_altitude(512) < 16)
				player.PlayerPhysplug = nieuport_takeoff;
		}	 
    } else {
    if((player.movement_x != 0 && !altcontrols)
    ||(player.movement_x != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_nieuport_speed_forward;
        else if(player.movement_x < 0)
          //df -= v_forward  * autocvar_g_vehicle_nieuport_speed_forward;
	  df += v_forward  * (autocvar_g_vehicle_nieuport_speed_forward * 0.3);
    }
    }
    
    
    
    if(((player.movement_x == 0 && !altcontrols) || (player.movement_x == 0 && altcontrols && !player.BUTTON_CROUCH))
    || (player.BUTTON_HOOK)) {
    	df += v_forward  * nieuport.bomb1.gun2.count;
    }
    
    

    //print(sprintf("ang = %f\n", nieuport.angles_z));
    if((player.movement_y != 0 && !altcontrols)
    ||(player.movement_y != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_nieuport_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_nieuport_speed_strafe;

        //nieuport.angles_z = bound(-30,nieuport.angles_z + (player.movement_y / autocvar_g_vehicle_nieuport_speed_strafe),30);
	nieuport.angles_z = bound(-360,nieuport.angles_z + ((player.movement_y * sys_frametime)/ autocvar_g_vehicle_nieuport_speed_strafe),360);
	//Na, we aint limi-ted, 360 degree roll
    }
    else
    {
    	//Stable inverted flight
	if(
	(nieuport.angles_z >= 179 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -179 && nieuport.angles_z >= -180))
	{
		nieuport.angles_z = 180;
	} else if(
	(nieuport.angles_z >= 176 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -176 && nieuport.angles_z >= -180))
	{
		nieuport.angles_z *= 1.001;
	} else if(
	(nieuport.angles_z >= 170 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -170 && nieuport.angles_z >= -180))
	{
		nieuport.angles_z *= 1.0025;
	} else if(
	(nieuport.angles_z >= 150 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -150 && nieuport.angles_z >= -180))
	{
		nieuport.angles_z *= 1.005;
	} else if(
	(nieuport.angles_z >= 100 && nieuport.angles_z <= 180) ||
	(nieuport.angles_z <= -100 && nieuport.angles_z >= -180))
	{
		nieuport.angles_z *= 1.01;	
	} else {
        	nieuport.angles_z *= 0.965;
	}
        if(nieuport.angles_z >= -1 && nieuport.angles_z <= -1)
            nieuport.angles_z = 0;
    }



    if((player.BUTTON_CROUCH && !altcontrols)
    ||(player.BUTTON_CROUCH && altcontrols && !player.movement_y && !player.movement_x)) {
        df -=   v_up * autocvar_g_vehicle_nieuport_speed_down;
    } else if ((player.BUTTON_JUMP && !altcontrols)
    || (player.BUTTON_JUMP && altcontrols && !player.movement_y && !player.movement_x))
    {
        df +=  v_up * autocvar_g_vehicle_nieuport_speed_up;
    }
    


    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	nieuport.avelocity_x = 0;
	nieuport.avelocity_y = 0;
	nieuport.avelocity_z = 0;
    }





    if (altcontrols) {
	player.v_angle_x = nieuport.angles_x * -1;
	player.v_angle_y = nieuport.angles_y;
	player.v_angle_z = nieuport.angles_z; //kiss
	
	player.angles_x = nieuport.angles_x;
	player.angles_y = nieuport.angles_y;
	player.angles_z = nieuport.angles_z; //for completion

	if ((clienttype(player) == CLIENTTYPE_REAL)) {
		msg_entity = player;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, player.v_angle_x);
		WriteAngle( MSG_ONE, player.v_angle_y);
  		WriteAngle( MSG_ONE, player.v_angle_z);
	}
    }
    
    
    
    df = vehicles_waterspeed(player, df);
    nieuport.velocity = vehicles_waterfriction(player, nieuport, nieuport.velocity);
    nieuport.velocity  += df * frametime;
    player.velocity = player.movement  = nieuport.velocity;
    setorigin(player, nieuport.origin + '0 0 32');
    
    ////////////// Open Bolt Trigger lag code
    if (!autocvar_g_balance_noopenbolttriggerlag) {
    	if (nieuport.vehic_triggerlag == 2) {
    		if (player.BUTTON_ATCK) {
			//Do nothing
		} else {
			nieuport.vehic_triggerlag = 0;
		}
  	  }
    }
    ////////////// Open Bolt Trigger lag code
    
    
    //Cannon firing 
    if(player.BUTTON_ATCK || (!autocvar_g_balance_noopenbolttriggerlag && nieuport.vehic_triggerlag))
    if(time > nieuport.attack_finished_single)
    if(nieuport.vehicle_energy >= autocvar_g_vehicle_sportster_cannon_cost)
    {
    	//Note: The fact that the Lewisgun is open bolt is the very reason
	//that a reliable syncronization gear was not able to be created
	//and the Lewisgun always fires outside the arc of the propeller
        ////////////// Open Bolt Trigger lag code
	if (!autocvar_g_balance_noopenbolttriggerlag) {
		if (nieuport.vehic_triggerlag == 1) {
			if (time >= nieuport.vehic_triggerlag_maxtime) {
				nieuport.vehic_triggerlag = 0;
			} else if (time >= nieuport.vehic_triggerlag_time)	{
				nieuport.vehic_triggerlag = 3; //Force fire
			}
		}
	}
	
	if(!autocvar_g_balance_noopenbolttriggerlag && !nieuport.vehic_triggerlag)
        {
		//Button is pressed, but we cannot fire yet since we are openbolt
		//Thus we set triggerlag to 1
		//When trigger lag is 2 or 3 it fires
		//When trigger lag is 3 it is forced to fire
		//When 2, if the button is not down it does not fire.
		//print("1\n");
		nieuport.vehic_triggerlag_time = time + (autocvar_g_vehicle_nieuport_cannon_refire * 0.5);
		
		if (frametime > autocvar_g_vehicle_nieuport_cannon_refire) {
			//Frametime not enough to keep up, don't want to jam up gun
			//print("Insufficent frametime lags Nieuport gun\n");
			nieuport.vehic_triggerlag_maxtime = time + (frametime * 1.5);
		} else {
			//Normal
			nieuport.vehic_triggerlag_maxtime = time + (autocvar_g_vehicle_nieuport_cannon_refire * 0.99);	
        	}
		
		nieuport.vehic_triggerlag = 1;
		////////////// Open Bolt Trigger lag code
	} else if (autocvar_g_balance_noopenbolttriggerlag || nieuport.vehic_triggerlag >= 2)
	{
		//print("2\n");
    		nieuport.vehic_triggerlag = 2; //For open bolt trigger lag
    		//FIRE
        	nieuport.vehicle_energy -= autocvar_g_vehicle_sportster_cannon_cost;
        	nieuport.wait = time;

        	crosshair_trace(player);
     
        	nieuport_fire_cannon("tag_mgun");
        
        	nieuport.attack_finished_single = time + autocvar_g_vehicle_nieuport_cannon_refire;
	}
	
	nieuport.count = 0; //Will have to press R to resume reload
    }


    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(nieuport.dmg_time, vehicle_shield, autocvar_g_vehicle_nieuport_shield, autocvar_g_vehicle_nieuport_shield_regen_pause, autocvar_g_vehicle_nieuport_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(nieuport.dmg_time, vehicle_health, autocvar_g_vehicle_nieuport_health, autocvar_g_vehicle_nieuport_health_regen_pause, autocvar_g_vehicle_nieuport_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (nieuport.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(nieuport.cnt, vehicle_energy, autocvar_g_vehicle_nieuport_energy, autocvar_g_vehicle_nieuport_energy_regen_pause, autocvar_g_vehicle_nieuport_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
    		nieuport.count = 1;
		sound (nieuport, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
	//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, nieuport, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
    }


    //
    if(player.BUTTON_ATCK2)
    {
        nieuport.gun2.cnt = time;
	if not(nieuport.gun2.count)
        if(nieuport.vehicle_ammo2 >= autocvar_g_vehicle_nieuport_bombs_ammo_cost && nieuport.tur_head.attack_finished_single <= time)
        {
            //vector v;
            //nieuport.misc_bulletcounter += 1;
	    
	    if (nieuport.gun1.count == 1) {
	    	//if nieuport.gun1.count is 1 we are loaded with a nuke
	    	nieuport_nukedrop();
		nieuport.gun1.count = 0;
		setmodel(nieuport.bomb1,"models/vehicles/clusterbomb_folded.md3");
	    } else {
	    	nieuport_bombdrop();
	    }
            nieuport.bomb1.alpha = nieuport.bomb2.alpha = 0.001;

            nieuport.vehicle_ammo2 -= autocvar_g_vehicle_nieuport_bombs_ammo_cost;
            nieuport.tur_head.attack_finished_single = time + autocvar_g_vehicle_nieuport_bombs_refire;
            //player.vehicle_ammo2 = (nieuport.vehicle_ammo2 / autocvar_g_vehicle_nieuport_bombs_ammo_max) * 100;
         
	    nieuport.count = 0; //Will have to press R to resume reload 
	    nieuport.gun2.count = 1; //Can't fire untill stop pressing key
	    
        }
    }
    else
    {
    	if (nieuport.count == 1) {
        vehicles_regen(nieuport.gun2.cnt, vehicle_ammo2, autocvar_g_vehicle_nieuport_bombs_ammo_max,
                                           autocvar_g_vehicle_nieuport_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_nieuport_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    	    	
		if(nieuport.bomb1.alpha < 1)
		if(nieuport.vehicle_ammo2_current > 0)
		{
			nieuport.bomb1.alpha = nieuport.bomb1.alpha + (sys_frametime / autocvar_g_vehicle_nieuport_bombs_refire);
			nieuport.bomb2.alpha = nieuport.bomb1.alpha;
		}
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		nieuport.count = 1;
		sound (nieuport, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		//nieuport.delay = time + autocvar_g_vehicle_nieuport_bombs_refire;
            	//nieuport.lip   = time;
    	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 player ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(player, nieuport, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
		
		if (nieuport.gun1.count != 1)
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
			nieuport.gun1.count = 1;
			setmodel(nieuport.bomb1,"models/vehicles/nukebomb.md3");
			sprint(player, sprintf("Nuclear Weapon Loaded. Estimated Damage Radius: %f %% miles\n", (autocvar_g_balance_nukelayer_radius/63360)));
		}
	}
	
	nieuport.gun2.count = 0; //Can fire
    }
    //

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, nieuport);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_nieuport_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    
    
    
    VEHICLE_UPDATE_PLAYER(player, health, nieuport);
    VEHICLE_UPDATE_PLAYER(player, energy, nieuport);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, nieuport);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    
    player.vehicle_ammo1_current = nieuport.vehicle_ammo1_current;
    player.vehicle_ammo1_max = nieuport.vehicle_ammo1_max;
    player.vehicle_ammo2_current = nieuport.vehicle_ammo2_current;
    player.vehicle_ammo2_max = nieuport.vehicle_ammo2_max;
    
    self = player;
    return 1;
}

void nieuport_impact()
{
    if(autocvar_g_vehicle_nieuport_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_nieuport_bouncepain_x, autocvar_g_vehicle_nieuport_bouncepain_y, autocvar_g_vehicle_nieuport_bouncepain_z);
}

// If we dont do this ever now and then, the nieuports rotors
// stop working, presumably due to angle overflow. cute.
void nieuport_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void nieuport_spawn(float _f)
{
    if(!self.gun1)
    {
    	self.loddistance1 = 256; //Lod0 Model somewhat complex, so only use when very close
	self.loddistance2 = 512;
	
    	self.lodmodel1 = "models/vehicles/nieuportedits_lod1.iqm";
	self.lodmodel2 = "models/vehicles/nieuportedits_lod2.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = nieuport_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"models/vehicles/clusterbomb_folded.md3");
        setmodel(self.bomb2,"null");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/nieuportedits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_center");
        setattachment(self.bomb2, self, "bombmount_right");
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
        setmodel(spinner,"models/vehicles/nieuport_spinner.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
	////spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;
	self.bomb1.gun1.count = 0;

        spinner = spawn();
        spinner.owner = self;
        //setmodel(spinner,"models/vehicles/nieuport_spinner.iqm");
        //setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	self.bomb1.gun2.count = autocvar_g_vehicle_nieuport_speed_forward * 0.6;

        // Sigh.
        self.bomb1.think = nieuport_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_nieuport_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxftd1 = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_nieuport_health;
    self.vehicle_shield = autocvar_g_vehicle_nieuport_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, NIEUPORT_MIN, NIEUPORT_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_nieuport_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_nieuport_bouncestop;    
    self.vehicle_impact = nieuport_impact;    
    self.damageforcescale = 0.25;
    
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly

    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxft, NIEUPORTROTOR_MIN_HBF_T, NIEUPORTROTOR_MAX_HBF_T, 0, 50, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmf, NIEUPORTROTOR_MIN_HBB_T, NIEUPORTROTOR_MAX_HBB_T, 0, 20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxftd1, NIEUPORTROTOR_MIN_HBB_T, NIEUPORTROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmb, NIEUPORTROTOR_MIN_HBB_T, NIEUPORTROTOR_MAX_HBB_T, 0, -20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxbk, NIEUPORTROTOR_MIN_HBF_T, NIEUPORTROTOR_MAX_HBF_T, 0, -50, 0);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_nieuport()
{
    if(!autocvar_g_vehicle_nieuport)
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
   
    if(autocvar_g_vehicle_nieuport_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_nieuport_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_nieuport_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_nieuport_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/nieuportedits.iqm");
    precache_model ("models/vehicles/nieuportedits_lod1.iqm");
    precache_model ("models/vehicles/nieuportedits_lod2.iqm");
    precache_model ("models/vehicles/nieuport_spinner.iqm");
    precache_model ("models/sphere/sphexp2.iqm");
    precache_model ("models/sphere/sphexp3.iqm");
    precache_model ("models/vehicles/clusterbomb_folded.md3");
    precache_model ("models/vehicles/nukebomb.md3");
    precache_model ("models/vhshield.md3");
    
    precache_sound ("vehicles/raptor_fly.wav");
    precache_sound ("vehicles/raptor_speed.wav");
    precache_sound ("vehicles/missile_alarm.wav");
    precache_sound ("weapons/uzi_fire_bass.ogg");
    precache_sound ( "weapons/rocket_impact.wav");
    
    	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
    
    if not (vehicle_initialize(
             "Nieuport",
             "models/vehicles/nieuportedits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_RAPTOR,
             NIEUPORT_MIN, NIEUPORT_MAX,
             FALSE,
             nieuport_spawn, autocvar_g_vehicle_nieuport_respawntime,
             nieuport_frame,
             nieuport_enter, nieuport_exit,
             nieuport_die,   nieuport_think,
             FALSE, 
             autocvar_g_vehicle_nieuport_health,
             autocvar_g_vehicle_nieuport_shield, autocolor, autocvar_g_vehicle_nieuport_energy * 5, autocvar_g_vehicle_nieuport_bombs_ammo_max * 2.04))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
