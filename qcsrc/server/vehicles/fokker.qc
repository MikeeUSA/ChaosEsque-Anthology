#define FOKKER_MIN '-70 -70 0'
#define FOKKER_MAX '70 70 120'

const vector FOKKERROTOR_MIN_HBF_T = '-10 -10 -40'; //Back and front trunk for this model
const vector FOKKERROTOR_MAX_HBF_T = '10 10 40';

const vector FOKKERROTOR_MIN_HBB_T = '-10 -10 -60'; //Middle
const vector FOKKERROTOR_MAX_HBB_T = '10 10 60';

#ifdef SVQC
float autocvar_g_vehicle_fokker;

float autocvar_g_vehicle_fokker_mass;

float autocvar_g_vehicle_fokker_respawntime;
float autocvar_g_vehicle_fokker_takeofftime;

float autocvar_g_vehicle_fokker_movestyle;
float autocvar_g_vehicle_fokker_turnspeed;
float autocvar_g_vehicle_fokker_pitchspeed;
float autocvar_g_vehicle_fokker_pitchlimit;

float autocvar_g_vehicle_fokker_speed_forward;
float autocvar_g_vehicle_fokker_speed_strafe;
float autocvar_g_vehicle_fokker_speed_up;
float autocvar_g_vehicle_fokker_speed_down;
float autocvar_g_vehicle_fokker_friction;

float autocvar_g_vehicle_fokker_cannon_refire;

float autocvar_g_vehicle_fokker_cannon_expelbulletcasings;

float autocvar_g_vehicle_fokker_cannon_spread;
float autocvar_g_vehicle_fokker_cannon_speed;
float autocvar_g_vehicle_fokker_cannon_damage; 
float autocvar_g_vehicle_fokker_cannon_headshotbonus; 
float autocvar_g_vehicle_fokker_cannon_force; 
float autocvar_g_vehicle_fokker_cannon_bulletconstant; 
float autocvar_g_vehicle_fokker_cannon_coreshotbonus;

float autocvar_g_vehicle_fokker_bombs_refire;

float autocvar_g_vehicle_fokker_bombs_ammo_cost;
float autocvar_g_vehicle_fokker_bombs_ammo_max;
float autocvar_g_vehicle_fokker_bombs_ammo_regen;
float autocvar_g_vehicle_fokker_bombs_ammo_regen_pause;

float autocvar_g_vehicle_fokker_flare_range;

float autocvar_g_vehicle_fokker_energy;
float autocvar_g_vehicle_fokker_energy_regen;
float autocvar_g_vehicle_fokker_energy_regen_pause;

float autocvar_g_vehicle_fokker_health;
float autocvar_g_vehicle_fokker_health_regen;
float autocvar_g_vehicle_fokker_health_regen_pause;

float autocvar_g_vehicle_fokker_shield;
float autocvar_g_vehicle_fokker_shield_regen;
float autocvar_g_vehicle_fokker_shield_regen_pause;

float autocvar_g_vehicle_fokker_bouncefactor;
float autocvar_g_vehicle_fokker_bouncestop;
vector autocvar_g_vehicle_fokker_bouncepain;

void fokker_spawn(float);
float fokker_frame();
float fokker_takeoff();

.entity bomb1;
.entity bomb2;
.entity muzzle_flash2;

// leilei's fancy muzzleflash stuff
void fokker_Flash_Go()
{
	self.frame = self.frame + 2;
	self.scale = self.scale * 0.5;
	self.alpha = self.alpha - 0.25;
	self.nextthink = time + 0.05;

	if (self.alpha <= 0)
	{
		self.think = SUB_Remove;
		self.nextthink = time;
		self.realowner.muzzle_flash2 = world;
		return;
	}

}

void fokkerFlash()
{
	if (self.muzzle_flash2 == world)
		self.muzzle_flash2 = spawn();

	// muzzle flash for 1st person view
	setmodel(self.muzzle_flash2, "models/uziflash.md3"); // precision set below

	self.muzzle_flash2.scale = 0.75;
	self.muzzle_flash2.think = fokker_Flash_Go;
	self.muzzle_flash2.nextthink = time + 0.02;
	self.muzzle_flash2.frame = 2;
	self.muzzle_flash2.alpha = 0.75;
	self.muzzle_flash2.angles_z = random() * 180;
	self.muzzle_flash2.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	self.muzzle_flash2.owner = self.muzzle_flash2.realowner = self;
}

void fokker_casings(string tagname)
{
    vector v;
    ////entity _oldself = self;    
    
    v = gettaginfo(self, gettagindex(self, tagname));
    if (autocvar_g_vehicle_fokker_cannon_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 105, self);
	}
    }
    
}

void fokker_fire_cannon(string tagname)
{
    vector v;
    entity _oldself = self;

    v = gettaginfo(self, gettagindex(self, tagname));
    
    //print(etos(self)," self and owner ",  etos(self.owner), "\n");
    self = self.owner;
  
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_fokker_cannon_spread, autocvar_g_vehicle_fokker_cannon_speed, 5, autocvar_g_vehicle_fokker_cannon_damage, autocvar_g_vehicle_fokker_cannon_headshotbonus, autocvar_g_vehicle_fokker_cannon_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_fokker_cannon_bulletconstant, autocvar_g_vehicle_fokker_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    self = _oldself;
    
    sound (self, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
}

void fokker_fire_rocket (string tagname)
{
	vector v;
	v = gettaginfo(self, gettagindex(self, tagname));
    
	entity missile;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 5, "weapons/rocket_fire.wav", CH_WEAPON_A, autocvar_g_balance_rocketlauncher_damage);
	//pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), v, v_forward * 1000, 1);

	missile = WarpZone_RefSys_SpawnSameRefSys(self);
	//missile.owner = missile.realowner = self; //Got to be for newtonian physics to work
	missile.owner = self;
	missile.realowner = self.owner;
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

	setorigin (missile, v); // move it back so it hits the wall at the right point
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

	// common properties
	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}


float fokker_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

//Fire Cannon removed

void fokker_think()
{
}


void fokker_blowup()
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

void fokker_diethink()
{
	if(time >= self.wait)
		self.think = fokker_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void fokker_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = fokker_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = fokker_blowup;

	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxftd1); 
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
}

void fokker_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = fokker_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_fokker_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_fokker_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_fokker_bombs_refire;
    self.lip   = time;
    

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void fokker_land()
{    
    float hgt;
        
    hgt = fokker_altitude(512);    
    //self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    //self.velocity = (self.velocity * 1) + ('0 0 -200' * (hgt / 256) * sys_frametime);
    self.velocity = (self.velocity * 1) + ('0 0 -200' * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.99;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun2.avelocity_y = 90 + ((self.frame / 25) * 2000);
    self.bomb1.gun1.avelocity_y = -self.bomb1.gun2.avelocity_y;

    if(hgt < 16)
    {
    	//If we're tipped to much we'll crash and be destroyed
    	if(
	(self.angles_z >= 60 && self.angles_z <= 180) ||
	(self.angles_z <= -60 && self.angles_z >= -180))
	{
		Damage(self, self, self.owner, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} else {
	        self.think    = fokker_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void fokker_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.bomb1.gun1.count = 0;
        self.think      = fokker_land;
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

float fokker_takeoff()
{
    entity player, fokker;
    
    player = self;
    fokker = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (fokker.bomb1.gun1.count == 0)) {
	    	fokker.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (fokker.bomb1.gun1.count == 1)) {
	  	fokker.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = fokker;
    if(self.sound_nexttime < time)
    {        
        if (fokker.bomb1.gun1.count) {
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
    }   

    // Takeoff sequense
    if(fokker.bomb1.gun1.count == 1) {
    if(fokker.frame < 25)
    {
    	makevectors(fokker.angles);
    	fokker.movetype       = MOVETYPE_WALK;
        fokker.frame += 25 / (autocvar_g_vehicle_fokker_takeofftime / sys_frametime);
        if(fokker.frame > 23)
		fokker.velocity_z = min(1 + (fokker.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = 90 + ((fokker.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_fokker_speed_forward * 0.4 * (fokker.frame/25),0.075);
    }
    else
    {
    	fokker.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = fokker_frame;
    }
    } else {
    	//Engine off?
    	fokker.movetype     = MOVETYPE_BOUNCE;
    	if (fokker.frame > 0) {
        	fokker.frame -= 25 / (autocvar_g_vehicle_fokker_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((fokker.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(fokker.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(fokker.angles_z >= 60 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -60 && fokker.angles_z >= -180))
	{
		Damage(fokker, fokker, player, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 
    
    
    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(fokker, fokker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    
    setorigin(player, fokker.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(fokker.dmg_time, vehicle_shield, autocvar_g_vehicle_fokker_shield, autocvar_g_vehicle_fokker_shield_regen_pause, autocvar_g_vehicle_fokker_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(fokker.dmg_time, vehicle_health, autocvar_g_vehicle_fokker_health, autocvar_g_vehicle_fokker_health_regen_pause, autocvar_g_vehicle_fokker_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (fokker.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(fokker.cnt, vehicle_energy, autocvar_g_vehicle_fokker_energy, autocvar_g_vehicle_fokker_energy_regen_pause, autocvar_g_vehicle_fokker_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
        //Add
	vehicles_regen(fokker.ammount3, vehicle_ammo2, autocvar_g_vehicle_fokker_bombs_ammo_max,
                                           autocvar_g_vehicle_fokker_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_fokker_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		fokker.count = 1;
		sound (fokker, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
    	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
    	vehicles_replenishAmmo(player, fokker, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	
	//Add
	vehicles_replenishAmmo(player, fokker, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
		
    }

    fokker.bomb1.alpha = fokker.bomb2.alpha = (time - fokker.lip) / (fokker.delay - fokker.lip);
    //player.vehicle_reload2 = bound(0, fokker.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, fokker);
    VEHICLE_UPDATE_PLAYER(player, energy, fokker);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, fokker);

    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(fokker, fokker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

//Flare Stuff removed

float fokker_frame()
{
    entity player, fokker;
    float altcontrols = 0;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    altcontrols = player.vehicle_alternateaircontrols;
    fokker = self.vehicle;
    self   = fokker;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_fokker_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_fokker_speed_forward;
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
    
    if(fokker.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = fokker.angles;
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
		ftmp = player.movement_y * -1 * autocvar_g_vehicle_fokker_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	fokker.avelocity_y = bound(-autocvar_g_vehicle_fokker_turnspeed, ftmp + fokker.avelocity_y * 0.9, autocvar_g_vehicle_fokker_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(player.movement_x != 0 && !player.BUTTON_HOOK && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_x * -1 * autocvar_g_vehicle_fokker_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	fokker.avelocity_x = bound(-autocvar_g_vehicle_fokker_pitchspeed, ftmp + fokker.avelocity_x * 0.9, autocvar_g_vehicle_fokker_pitchspeed);
    	
	
	
	if(fokker.angles_y > 180)  fokker.angles_y -= 360;
    	if(fokker.angles_y < -180) fokker.angles_y += 360;
	
		if(fokker.angles_y >= -1 && fokker.angles_y <= -1)
            	fokker.angles_y = 0;
		
	if(fokker.angles_x > 180)  fokker.angles_x -= 360;
    	if(fokker.angles_x < -180) fokker.angles_x += 360;
	
	
		if(fokker.angles_x >= -1 && fokker.angles_x <= -1)
            	fokker.angles_x = 0;
		
	if(fokker.angles_z > 180)  fokker.angles_z -= 360;
    	if(fokker.angles_z < -180) fokker.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    
    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    fokker.avelocity_y = bound(-autocvar_g_vehicle_fokker_turnspeed, ftmp + fokker.avelocity_y * 0.9, autocvar_g_vehicle_fokker_turnspeed);

    // Pitch
    ftmp = 0;
    if not(player.BUTTON_HOOK) {
    	if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_fokker_pitchlimit) ftmp = 5;
    	else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_fokker_pitchlimit) ftmp = -20;
    }
    
    
    df_x = bound(-autocvar_g_vehicle_fokker_pitchlimit, df_x , autocvar_g_vehicle_fokker_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_fokker_pitchlimit, df_x + ftmp, autocvar_g_vehicle_fokker_pitchlimit);
    fokker.avelocity_x = bound(-autocvar_g_vehicle_fokker_pitchspeed, ftmp + fokker.avelocity_x * 0.9, autocvar_g_vehicle_fokker_pitchspeed);
    
    
    //END
    ///////////////
    }
    
    
    fokker.angles_x = anglemods(fokker.angles_x);
    fokker.angles_y = anglemods(fokker.angles_y);
    fokker.angles_z = anglemods(fokker.angles_z);

    if(autocvar_g_vehicle_fokker_movestyle == 1)
        makevectors('0 1 0' * fokker.angles_y);
    else
        makevectors(player.v_angle);

    df = fokker.velocity * -autocvar_g_vehicle_fokker_friction;

	//print(sprintf("m1 = %f\n", v_forward));
    if(player.BUTTON_HOOK) {
    		if(player.movement_x > 0) {
    	    		fokker.bomb1.gun2.count = bound(autocvar_g_vehicle_fokker_speed_forward * 0.4, fokker.bomb1.gun2.count + (128 * sys_frametime),autocvar_g_vehicle_fokker_speed_forward);
    			if((fokker.bomb1.gun2.pushltime < time) && !(fokker.bomb1.gun2.count >= autocvar_g_vehicle_fokker_speed_forward))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Raised to %f\n", (fokker.bomb1.gun2.count/autocvar_g_vehicle_fokker_speed_forward)));
    				fokker.bomb1.gun2.pushltime = time + 0.25;
			}
		} else if(player.movement_x < 0) {
    	    		fokker.bomb1.gun2.count = bound(autocvar_g_vehicle_fokker_speed_forward * 0.4, fokker.bomb1.gun2.count - (128 * sys_frametime),autocvar_g_vehicle_fokker_speed_forward);
    			if((fokker.bomb1.gun2.pushltime < time) && !(fokker.bomb1.gun2.count <= autocvar_g_vehicle_fokker_speed_forward * 0.4))  // Don't flood the connection with the messages
			{
				sprint(player, sprintf("Engine Speed Lowered to %f\n", (fokker.bomb1.gun2.count/autocvar_g_vehicle_fokker_speed_forward)));
    				fokker.bomb1.gun2.pushltime = time + 0.25;
			}
        
   			if(fokker_altitude(512) < 16)
				player.PlayerPhysplug = fokker_takeoff;
		}	 
    } else {
    if((player.movement_x != 0 && !altcontrols)
    ||(player.movement_x != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_fokker_speed_forward;
        else if(player.movement_x < 0)
          //df -= v_forward  * autocvar_g_vehicle_fokker_speed_forward;
	  df += v_forward  * (autocvar_g_vehicle_fokker_speed_forward * 0.4);
    }
    }
    
    
    
    if(((player.movement_x == 0 && !altcontrols) || (player.movement_x == 0 && altcontrols && !player.BUTTON_CROUCH))
    || (player.BUTTON_HOOK)) {
    	df += v_forward  * fokker.bomb1.gun2.count;
    }



    if((player.movement_y != 0 && !altcontrols)
    ||(player.movement_y != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_fokker_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_fokker_speed_strafe;

        //fokker.angles_z = bound(-30,fokker.angles_z + (player.movement_y / autocvar_g_vehicle_fokker_speed_strafe),30);
	fokker.angles_z = bound(-360,fokker.angles_z + ((player.movement_y * 4 * sys_frametime) / autocvar_g_vehicle_fokker_speed_strafe),360);
	//Na, we aint limi-ted, 360 degree roll
    }
    else
    {
    	//Stable inverted flight
	if(
	(fokker.angles_z >= 179 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -179 && fokker.angles_z >= -180))
	{
		fokker.angles_z = 180;
	} else if(
	(fokker.angles_z >= 176 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -176 && fokker.angles_z >= -180))
	{
		fokker.angles_z *= 1.001;
	} else if(
	(fokker.angles_z >= 170 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -170 && fokker.angles_z >= -180))
	{
		fokker.angles_z *= 1.005;
	} else if(
	(fokker.angles_z >= 150 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -150 && fokker.angles_z >= -180))
	{
		fokker.angles_z *= 1.01;
	} else if(
	(fokker.angles_z >= 100 && fokker.angles_z <= 180) ||
	(fokker.angles_z <= -100 && fokker.angles_z >= -180))
	{
		fokker.angles_z *= 1.025;	
	} else {
       		fokker.angles_z *= 0.95;
	}
        if(fokker.angles_z >= -1 && fokker.angles_z <= -1)
            fokker.angles_z = 0;
    }



    if((player.BUTTON_CROUCH && !altcontrols)
    ||(player.BUTTON_CROUCH && altcontrols && !player.movement_y && !player.movement_x)) {
        df -=   v_up * autocvar_g_vehicle_fokker_speed_down;
    } else if ((player.BUTTON_JUMP && !altcontrols)
    || (player.BUTTON_JUMP && altcontrols && !player.movement_y && !player.movement_x))
    {
        df +=  v_up * autocvar_g_vehicle_fokker_speed_up;
    }
    

    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	fokker.avelocity_x = 0;
	fokker.avelocity_y = 0;
	fokker.avelocity_z = 0;
    }
    
    
    
    
    
    if (altcontrols) {
	player.v_angle_x = fokker.angles_x * -1;
	player.v_angle_y = fokker.angles_y;
	player.v_angle_z = fokker.angles_z; //kiss
	
	player.angles_x = fokker.angles_x;
	player.angles_y = fokker.angles_y;
	player.angles_z = fokker.angles_z; //for completion

	if ((clienttype(player) == CLIENTTYPE_REAL)) {
		msg_entity = player;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, player.v_angle_x);
		WriteAngle( MSG_ONE, player.v_angle_y);
  		WriteAngle( MSG_ONE, player.v_angle_z);
	}
    }


    df = vehicles_waterspeed(player, df);
    fokker.velocity = vehicles_waterfriction(player, fokker, fokker.velocity);
    fokker.velocity  += df * frametime;
    player.velocity = player.movement  = fokker.velocity;
    setorigin(player, fokker.origin + '0 0 32');
    
    //Cannon firing 
    if(player.BUTTON_ATCK)
    if(time > fokker.attack_finished_single)
    if(fokker.vehicle_energy >= autocvar_g_vehicle_sportster_cannon_cost)
    {
        fokker.vehicle_energy -= autocvar_g_vehicle_sportster_cannon_cost;
        fokker.wait = time;

        crosshair_trace(player);
	
        fokker_fire_cannon("tag_mgun1");
	UziFlash();
	sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_mgun1");
	fokker_casings("tag_casings1");
    
	fokker_fire_cannon("tag_mgun2");
	fokkerFlash();
	sportster_AttachToShotorg(self.muzzle_flash2, '5 0 0', "tag_mgun2");
	fokker_casings("tag_casings2");
        
        fokker.attack_finished_single = time + autocvar_g_vehicle_fokker_cannon_refire;
	fokker.count = 0; //Will have to press R to resume reload
    }


    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(fokker.dmg_time, vehicle_shield, autocvar_g_vehicle_fokker_shield, autocvar_g_vehicle_fokker_shield_regen_pause, autocvar_g_vehicle_fokker_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(fokker.dmg_time, vehicle_health, autocvar_g_vehicle_fokker_health, autocvar_g_vehicle_fokker_health_regen_pause, autocvar_g_vehicle_fokker_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if (fokker.count == 1) {
    	if(self.vehicle_flags  & VHF_ENERGYREGEN)
        	vehicles_regen(fokker.cnt, vehicle_energy, autocvar_g_vehicle_fokker_energy, autocvar_g_vehicle_fokker_energy_regen_pause, autocvar_g_vehicle_fokker_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    
    	vehicles_regen(fokker.ammount3, vehicle_ammo2, autocvar_g_vehicle_fokker_bombs_ammo_max,
                                           autocvar_g_vehicle_fokker_bombs_ammo_regen_pause,
                                           autocvar_g_vehicle_fokker_bombs_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    
    } else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		fokker.count = 1;
		sound (fokker, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    }
    
    if (player.impulse == 20)
    if (player.BUTTON_HOOK) {
    	//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
    	vehicles_replenishAmmo(player, fokker, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	
	//Add
	vehicles_replenishAmmo(player, fokker, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 4);
    }

    //Bomb dropping
    
    //Add
    if(player.BUTTON_ATCK2)
    {
    	//print(ftos(fokker.vehicle_ammo2), "_a2_", ftos(autocvar_g_vehicle_fokker_bombs_ammo_cost), "_ac_", ftos(fokker.vehicle_ammo2_current), "_cur_", ftos(fokker.vehicle_ammo2_max), "_max\n");
	fokker.ammount3 = time; //.cnt
        if(fokker.vehicle_ammo2 >= autocvar_g_vehicle_fokker_bombs_ammo_cost && fokker.bomb1.attack_finished_single <= time)
        {
	    fokker_fire_rocket("bombmount_right");
	    fokker_fire_rocket("bombmount_left");
	    
	    fokker.vehicle_ammo2 -= autocvar_g_vehicle_fokker_bombs_ammo_cost;
            fokker.bomb1.attack_finished_single = time + autocvar_g_vehicle_fokker_bombs_refire; //Changed from tur_head

	    fokker.count = 0; //Will have to press R to resume reload
			    
	    fokker.bomb1.alpha = fokker.bomb2.alpha = 0.000001;            
	}
    }
    
    if (fokker.bomb1.alpha < 1) {
    	//1-((futuretime-currenttime)/addedtime)
 	fokker.bomb1.alpha = fokker.bomb2.alpha = ( 1 - ((fokker.bomb1.attack_finished_single - time) / autocvar_g_vehicle_fokker_bombs_refire) );
    }
    //Added
    

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, fokker);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_fokker_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

    VEHICLE_UPDATE_PLAYER(player, health, fokker);
    VEHICLE_UPDATE_PLAYER(player, energy, fokker);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, fokker);

    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(fokker, fokker, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    
    player.vehicle_ammo1_current = fokker.vehicle_ammo1_current;
    player.vehicle_ammo1_max = fokker.vehicle_ammo1_max;
    player.vehicle_ammo2_current = fokker.vehicle_ammo2_current;
    player.vehicle_ammo2_max = fokker.vehicle_ammo2_max;
    
    //For the bomb reload bar;
    if(fokker.vehicle_ammo2 > 0)
    {
    	//pressed reload
    	if (time > fokker.bomb1.attack_finished_single) {
    		player.vehicle_reload2 = 100;
    	} else {
    		player.vehicle_reload2 = bound(0, 
     		( 1 - ((fokker.bomb1.attack_finished_single - time) / autocvar_g_vehicle_fokker_bombs_refire) ) * 100,
     		100);
    	}
    } else {
    	player.vehicle_reload2 = 0;
    }
    //Done bomb reloading bar
    
    self = player;
    return 1;
}

void fokker_impact()
{
    if(autocvar_g_vehicle_fokker_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_fokker_bouncepain_x, autocvar_g_vehicle_fokker_bouncepain_y, autocvar_g_vehicle_fokker_bouncepain_z);
}

// If we dont do this ever now and then, the fokkers rotors
// stop working, presumably due to angle overflow. cute.
void fokker_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void fokker_spawn(float _f)
{
    if(!self.gun1)
    {
    	self.loddistance1 = 192; //Lod0 Model quite complex, so only use when very close
	self.loddistance2 = 736;
	
    	self.lodmodel1 = "models/vehicles/fokkeredits_lod1.iqm";
	self.lodmodel2 = "models/vehicles/fokkeredits_lod2.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = fokker_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"models/rocket.md3");
        setmodel(self.bomb2,"models/rocket.md3");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/fokkeredits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_right");
        setattachment(self.bomb2, self, "bombmount_left");
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
        setmodel(spinner,"models/vehicles/fokker_spinner.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
	////spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        //setmodel(spinner,"models/vehicles/fokker_spinner.iqm");
        //setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = fokker_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_fokker_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxftd1 = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.bomb1.gun1.count = 0;
	self.bomb1.gun2.count = autocvar_g_vehicle_fokker_speed_forward * 0.6;
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_fokker_health;
    self.vehicle_shield = autocvar_g_vehicle_fokker_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = -90;
    self.bomb1.gun2.avelocity_y = 90;

    setsize(self, FOKKER_MIN, FOKKER_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_fokker_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_fokker_bouncestop;    
    self.vehicle_impact = fokker_impact;    
    self.damageforcescale = 0.25;

    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly

    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxft, FOKKERROTOR_MIN_HBF_T, FOKKERROTOR_MAX_HBF_T, 0, 50, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmf, FOKKERROTOR_MIN_HBB_T, FOKKERROTOR_MAX_HBB_T, 0, 20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxftd1, FOKKERROTOR_MIN_HBB_T, FOKKERROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmb, FOKKERROTOR_MIN_HBB_T, FOKKERROTOR_MAX_HBB_T, 0, -20, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxbk, FOKKERROTOR_MIN_HBF_T, FOKKERROTOR_MAX_HBF_T, 0, -50, 0);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_fokker()
{
    if(!autocvar_g_vehicle_fokker)
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
   
    if(autocvar_g_vehicle_fokker_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_fokker_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_fokker_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_fokker_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/fokkeredits.iqm");
    precache_model ("models/vehicles/fokkeredits_lod1.iqm");
    precache_model ("models/vehicles/fokkeredits_lod2.iqm");
    precache_model ("models/vehicles/fokker_spinner.iqm");
    precache_model ("models/rocket.md3");
    precache_model ("models/sphere/sphexp.md3");
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
    
    //Had to do it this way for some reason.
    float myammo1, myammo2;
    myammo1 = (autocvar_g_vehicle_fokker_energy * 5);
    myammo2 = (autocvar_g_vehicle_fokker_bombs_ammo_max * 2);
    //print(ftos(myammo1), " fokker ", ftos(myammo2), "\n");
    
    if not (vehicle_initialize(
             "Fokker",
             "models/vehicles/fokkeredits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_AEROPLANE,
             FOKKER_MIN, FOKKER_MAX,
             FALSE,
             fokker_spawn, autocvar_g_vehicle_fokker_respawntime,
             fokker_frame,
             fokker_enter, fokker_exit,
             fokker_die,   fokker_think,
             FALSE, 
             autocvar_g_vehicle_fokker_health,
             autocvar_g_vehicle_fokker_shield, autocolor, myammo1, myammo2 ))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
