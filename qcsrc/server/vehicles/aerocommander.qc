#define AEROCOMMANDER_MIN '-120 -120 0'
#define AEROCOMMANDER_MAX '120 120 166'

const vector AEROCOMMANDERROTOR_MIN_HBF_T = '-15 -15 -60'; //Back and front trunk for this model
const vector AEROCOMMANDERROTOR_MAX_HBF_T = '15 15 60';

const vector AEROCOMMANDERROTOR_MIN_HBB_T = '-15 -15 -90'; //Middle
const vector AEROCOMMANDERROTOR_MAX_HBB_T = '15 15 90';

#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P

//Sparrow
float autocvar_g_vehicle_aerocommander_mass;

float autocvar_g_vehicle_aerocommander_respawntime;
float autocvar_g_vehicle_aerocommander_takeofftime;

float autocvar_g_vehicle_aerocommander_movestyle;
float autocvar_g_vehicle_aerocommander_turnspeed;
float autocvar_g_vehicle_aerocommander_pitchspeed;
float autocvar_g_vehicle_aerocommander_pitchlimit;

float autocvar_g_vehicle_aerocommander_friction;

float autocvar_g_vehicle_aerocommander_bombs_refire;

float autocvar_g_vehicle_aerocommander_flare_range;

float autocvar_g_vehicle_aerocommander_bouncefactor;
float autocvar_g_vehicle_aerocommander_bouncestop;
vector autocvar_g_vehicle_aerocommander_bouncepain;


// Auto cvars Fastcar
float autocvar_g_vehicle_aerocommander_mass;
float autocvar_g_vehicle_aerocommander_speed_forward;
float autocvar_g_vehicle_aerocommander_speed_strafe;
float autocvar_g_vehicle_aerocommander_speed_up;
float autocvar_g_vehicle_aerocommander_speed_down;
float autocvar_g_vehicle_aerocommander_pitchlimit;

float autocvar_g_vehicle_aerocommander_friction;

float autocvar_g_vehicle_aerocommander_turnspeed;
float autocvar_g_vehicle_aerocommander_pitchspeed;

float autocvar_g_vehicle_aerocommander_energy;
float autocvar_g_vehicle_aerocommander_energy_regen;
float autocvar_g_vehicle_aerocommander_energy_regen_pause;

float autocvar_g_vehicle_aerocommander_health;
float autocvar_g_vehicle_aerocommander_health_regen;
float autocvar_g_vehicle_aerocommander_health_regen_pause;

float autocvar_g_vehicle_aerocommander_shield;
float autocvar_g_vehicle_aerocommander_shield_regen;
float autocvar_g_vehicle_aerocommander_shield_regen_pause;

float autocvar_g_vehicle_aerocommander_cannon_speed;

float autocvar_g_vehicle_aerocommander_cannon_ammo;
float autocvar_g_vehicle_aerocommander_cannon_ammo_regen;
float autocvar_g_vehicle_aerocommander_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_aerocommander_cannon_lock = 0;

float autocvar_g_vehicle_aerocommander_cannon_turnspeed;
float autocvar_g_vehicle_aerocommander_cannon_pitchlimit_down;
float autocvar_g_vehicle_aerocommander_cannon_pitchlimit_up;
float autocvar_g_vehicle_aerocommander_cannon_turnlimit_in;
float autocvar_g_vehicle_aerocommander_cannon_turnlimit_out;

float autocvar_g_vehicle_aerocommander_respawntime;

float autocvar_g_vehicle_aerocommander_blowup_radius;
float autocvar_g_vehicle_aerocommander_blowup_coredamage;
float autocvar_g_vehicle_aerocommander_blowup_edgedamage;
float autocvar_g_vehicle_aerocommander_blowup_forceintensity;

float autocvar_g_vehicle_aerocommander_bouncefactor;
float autocvar_g_vehicle_aerocommander_bouncestop;
vector autocvar_g_vehicle_aerocommander_bouncepain;

var float autocvar_g_vehicle_aerocommander = 0;
var vector aerocommander_force_from_tag(string tag_name, float spring_length, float max_power);

float aerocommander_takeoff();
float aerocommander_pilot_frame();
void aerocommander_think();
void aerocommander_mg_m134(entity mg_m134, entity player, entity gunmount, entity mggun1);
void aerocommander_raagun(entity gun, entity pilot, entity gunmount, entity mggun1);
void aerocommander_minigun(entity gun, entity pilot, entity gunmount, entity mggun1);
void aerocommander_hvyminigun(entity gun, entity pilot, entity gunmount, entity mggun1);
void aerocommander_hmg(entity gun, entity pilot, entity gunmount);

float aerocommander_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

void aerocommander_pilot_enter()
{
    //print(sprintf("waterlevel: %f vehic to player %f\n", self.waterlevel, self.owner.waterlevel));

    self.vehicle_weapon2mode = RSM_BOMB;
    if(self.frame < 25)
    {
    	print("Takeoff Frame\n");
    	self.owner.PlayerPhysplug = aerocommander_takeoff;
    } else {
    	print("Pilot Frame\n");
    	self.owner.PlayerPhysplug = aerocommander_pilot_frame;
    }
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_aerocommander_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_aerocommander_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_aerocommander_bombs_refire;
    self.lip   = time;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}


void aerocommander_land()
{    
    float hgt;
        
    hgt = aerocommander_altitude(512);    
    //Glide to a stop
    self.velocity = (self.velocity * 1) + ('0 0 -200' * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.99;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    if (self.waterlevel > 0)
    {
	self.bomb1.gun1.avelocity_y = self.bomb1.gun1.avelocity_y * 0.95;
    	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    } else {
    	self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
    	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    }

    if(hgt < 16)
    {
    	//If we're tipped to much we'll crash and be destroyed
	//Greater wingspan than the fokker, wing can touch ground easier
    	if(
	(self.angles_z >= 40 && self.angles_z <= 180) ||
	(self.angles_z <= -40 && self.angles_z >= -180))
	{
                Damage(self, self, self.owner, 20000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} else {
	        self.think    = aerocommander_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
	self.bomb1.gun2.count = autocvar_g_vehicle_aerocommander_speed_forward * 0.1; //For non-flying movement
    }

    self.nextthink  = time;
}

float aerocommander_takeoff()
{
    entity player, aerocommander;
    
    player = self;
    aerocommander = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (aerocommander.bomb1.gun1.count == 0)) {
	    	aerocommander.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (aerocommander.bomb1.gun1.count == 1)) {
	  	aerocommander.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = aerocommander;
    if(self.sound_nexttime < time)
    {
        if (aerocommander.bomb1.gun1.count) {
	if not(player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
        	self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        	sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
	}
    }   

    // Takeoff sequense
    if(aerocommander.bomb1.gun1.count == 1) {
    if(aerocommander.frame < 25)
    {
    	makevectors(aerocommander.angles);
    	aerocommander.movetype       = MOVETYPE_WALK;
        aerocommander.frame += 25 / (autocvar_g_vehicle_aerocommander_takeofftime / sys_frametime);
        if(aerocommander.frame > 23)
		aerocommander.velocity_z = min(1 + (aerocommander.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = 90 + ((aerocommander.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_aerocommander_speed_forward * 0.32 * (aerocommander.frame/25),0.075);
    }
    else
    {
    	aerocommander.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = aerocommander_pilot_frame;
    }
    } else {
    	//Engine off?
    	aerocommander.movetype     = MOVETYPE_BOUNCE;
    	if (aerocommander.frame > 0) {
        	aerocommander.frame -= 25 / (autocvar_g_vehicle_aerocommander_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((aerocommander.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(aerocommander.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(aerocommander.angles_z >= 40 && aerocommander.angles_z <= 180) ||
	(aerocommander.angles_z <= -40 && aerocommander.angles_z >= -180))
	{
		Damage(aerocommander, aerocommander, player, 20000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 

    //Begin takeoff weapons stuff
    if (aerocommander.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	aerocommander_minigun(aerocommander, player, aerocommander.bomb3, aerocommander.bomb3.gun1);
	aerocommander_minigun(aerocommander, player, aerocommander.bomb4, aerocommander.bomb4.gun1);
	aerocommander_minigun(aerocommander, player, aerocommander.bomb8, aerocommander.bomb8.gun1);
	aerocommander_minigun(aerocommander, player, aerocommander.bomb7, aerocommander.bomb7.gun1);
	}
	
	if (aerocommander.spawnflags & 128) {
	aerocommander_hmg(aerocommander, player, aerocommander.bomb5);
	aerocommander_hmg(aerocommander, player, aerocommander.bomb6);
	}
	
	if (aerocommander.spawnflags & 256) {
	aerocommander_hvyminigun(aerocommander, player, aerocommander.bomb9, aerocommander.bomb9.gun1);
	aerocommander_hvyminigun(aerocommander, player, aerocommander.bomb10, aerocommander.bomb10.gun1);
	aerocommander_hvyminigun(aerocommander, player, aerocommander.bomb13, aerocommander.bomb13.gun1);
	aerocommander_hvyminigun(aerocommander, player, aerocommander.bomb14, aerocommander.bomb14.gun1);
	}
	
	if (aerocommander.spawnflags & 16384) {
	aerocommander_raagun(aerocommander, player, aerocommander.bomb15, aerocommander.bomb15.gun1);
	}
	
	if ((self.spawnflags & 64) || (self.spawnflags & 256)) {
		if(player.BUTTON_HOOK) {
			player.BUTTON_JUMP   = 0;
		}
	}
    }

    if (aerocommander.vehicle_ammo1_max) {
    	player.vehicle_ammo1_current = aerocommander.vehicle_ammo1_current;
    	player.vehicle_ammo1_max = aerocommander.vehicle_ammo1_max;
    }
    
    if (aerocommander.vehicle_ammo2_max) {
    	player.vehicle_ammo2_current = aerocommander.vehicle_ammo2_current;
    	player.vehicle_ammo2_max = aerocommander.vehicle_ammo2_max;
    }
    ///End takeoff weapons stuff

    
    if (
    ((!((aerocommander.spawnflags & 32)
	|| (aerocommander.spawnflags & 64)
	|| (aerocommander.spawnflags & 128)
	|| (aerocommander.spawnflags & 256)
	|| (aerocommander.spawnflags & 512)
	|| (aerocommander.spawnflags & 1024)
	|| (aerocommander.spawnflags & 2048)
	|| (aerocommander.spawnflags & 16384)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(aerocommander, aerocommander, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    setorigin(player, aerocommander.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(aerocommander.dmg_time, vehicle_shield, autocvar_g_vehicle_aerocommander_shield, autocvar_g_vehicle_aerocommander_shield_regen_pause, autocvar_g_vehicle_aerocommander_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(aerocommander.dmg_time, vehicle_health, autocvar_g_vehicle_aerocommander_health, autocvar_g_vehicle_aerocommander_health_regen_pause, autocvar_g_vehicle_aerocommander_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(aerocommander.cnt, vehicle_energy, autocvar_g_vehicle_aerocommander_energy, autocvar_g_vehicle_aerocommander_energy_regen_pause, autocvar_g_vehicle_aerocommander_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    aerocommander.bomb1.alpha = aerocommander.bomb2.alpha = (time - aerocommander.lip) / (aerocommander.delay - aerocommander.lip);
    player.vehicle_reload2 = bound(0, aerocommander.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, aerocommander);
    VEHICLE_UPDATE_PLAYER(player, energy, aerocommander);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, aerocommander);


    if (
    ((!((aerocommander.spawnflags & 32)
	|| (aerocommander.spawnflags & 64)
	|| (aerocommander.spawnflags & 128)
	|| (aerocommander.spawnflags & 256)
	|| (aerocommander.spawnflags & 512)
	|| (aerocommander.spawnflags & 1024)
	|| (aerocommander.spawnflags & 2048)
	|| (aerocommander.spawnflags & 16384)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(aerocommander, aerocommander, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

void aerocommander_mg_m134(entity mg_m134, entity player, entity gunmount, entity mggun1) 
{
        mg_m134.cnt = time;
        if(mg_m134.vehicle_ammo1 >= autocvar_g_vehicle_tankll24_raacannon_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_m134.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 //Barrel lenght to boresize ratio same as the tank's 30mm raa gun (we are 20mm so dmg same as spiderbot miniguns)
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_raacannon_spread, autocvar_g_vehicle_spiderbot_minigun_speed, 5, autocvar_g_vehicle_spiderbot_minigun_damage, autocvar_g_vehicle_spiderbot_minigun_headshotaddeddamage, autocvar_g_vehicle_spiderbot_minigun_force, DEATH_SBMINIGUN, PROJECTILE_BULLETRIFLE20MM, 1, autocvar_g_vehicle_spiderbot_minigun_bulletconstant, autocvar_g_vehicle_spiderbot_minigun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);

	    
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 30, gunmount, "tag_casings");
			//20mm
		}

            self = mg_m134;

            mg_m134.vehicle_ammo1 -= autocvar_g_vehicle_tankll24_raacannon_ammo_cost;
            
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire
	                
	    player.vehicle_ammo1 = (mg_m134.vehicle_ammo1 / autocvar_g_vehicle_tankll24_raacannon_ammo_max) * 100;
	    
	    
            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
	//Smooth animations. Also gun can spin via elec power even if no ammo
	} else if(mg_m134.vehicle_ammo1 < autocvar_g_vehicle_tankll24_raacannon_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire

            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.attack_finished_single <= time)
	{
	    mggun1.attack_finished_single = time + (mggun1.count*0.3333333); // 1/3 time
	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.cnt <= time)
	{
	    mggun1.cnt = time + (mggun1.count*0.6666666); // 2/3 time

	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        }
}

void aerocommander_raagun(entity gun, entity pilot, entity gunmount, entity mggun1)
{
   
   if(pilot.BUTTON_ATCK)
    {
    	aerocommander_mg_m134(gun, pilot, gunmount, mggun1);
	gun.count = 0; //Will have to press R to resume reload
    } else {
    	if (gun.count == 1) {
        vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_m134_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    	} else if (pilot.impulse == 20) {
		gun.count = 1;
		sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
    }
    
    if(pilot.BUTTON_HOOK) {
    	if(pilot.BUTTON_JUMP) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mggun1.count - (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Raised to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}
	    }
    
    	if(pilot.BUTTON_CROUCH ) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mggun1.count + (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Lowered to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}

    	}
    }
}

void aerocommander_minigun(entity gun, entity pilot, entity gunmount, entity mggun1)
{
   
   if(pilot.BUTTON_ATCK)
    {
    	mg_m134_fire(gun, pilot, gunmount, mggun1);
	gun.count = 0; //Will have to press R to resume reload
    } else {
        if (gun.count == 1) {
        vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_m134_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
        } else if (pilot.impulse == 20) {
		if(pilot.BUTTON_HOOK) {
			//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
		} else {
			gun.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
	}
    }
    
    if(pilot.BUTTON_HOOK) {
    	if(pilot.BUTTON_JUMP) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mggun1.count - (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Raised to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}
	    }
    
    	if(pilot.BUTTON_CROUCH ) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mggun1.count + (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Lowered to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}
    	}
    }
}

void aerocommander_hvyminigun(entity gun, entity pilot, entity gunmount, entity mggun1)
{
   
   if(pilot.BUTTON_ATCK)
    {
    	mg_gau19_fire(gun, pilot, gunmount, mggun1);
	gun.count = 0; //Will have to press R to resume reload
    } else {
    	if (gun.count == 1) {
        vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_gau19_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_gau19_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_gau19_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    	} else if (pilot.impulse == 20) {
		if(pilot.BUTTON_HOOK) {
			//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		} else {
			gun.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
	}
    }
    
    if(pilot.BUTTON_HOOK) {
    	if(pilot.BUTTON_JUMP) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_gau19_machinegun_refire_max, mggun1.count - (autocvar_g_vehicle_mg_gau19_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_gau19_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Raised to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}
	    }
    
    	if(pilot.BUTTON_CROUCH ) {
    		mggun1.count = bound(autocvar_g_vehicle_mg_gau19_machinegun_refire_max, mggun1.count + (autocvar_g_vehicle_mg_gau19_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_gau19_machinegun_refire_min);
		if(mggun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(pilot, sprintf("RoF Lowered to %f RPM\n", (60/mggun1.count)));
			mggun1.pushltime = time + 0.25;
		}
    	}
    }
}

void aerocommander_hmg(entity gun, entity pilot, entity gunmount)
{
   //This one is for forward mounted pilot controlled machineguns
   if(
   ((pilot.BUTTON_ATCK) && !(gun.spawnflags & 64))
   || ((pilot.BUTTON_ATCK2) && (gun.spawnflags & 64))
   )
    {
    	mg_browning50_fire(gun, pilot, gunmount);
	gun.count = 0; //Will have to press R to resume reload
    } else {
        if (gun.count == 1) {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_browning50_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_browning50_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_browning50_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if (pilot.impulse == 20) {
		if(pilot.BUTTON_HOOK) {
			//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		} else {
			gun.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
	}
	//Overheating stuff://
	if (gun.gun1.cnt < autocvar_g_vehicle_mg_browning50_machinegun_heatmin) {
		gun.gun1.cnt = autocvar_g_vehicle_mg_browning50_machinegun_heatmin;
	} else {
		gun.gun1.cnt = gun.gun1.cnt - (autocvar_g_vehicle_mg_browning50_machinegun_cooldownrate * sys_frametime);
	}
    }
}

void aerocommander_hmg2(entity gun, entity pilot, entity gunmount)
{
   //This one is for pintel mounted guns
   if(pilot.BUTTON_ATCK)
    {
    	mg_browning50_fire(gun, pilot, gunmount);
	gun.count = 0; //Will have to press R to resume reload
    } else {
    	if (gun.count == 1) {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_browning50_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_browning50_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_browning50_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if (pilot.impulse == 20) {
		if(pilot.BUTTON_HOOK) {
			//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		} else {
			gun.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
	}
	//Overheating stuff://
	if (gun.gun1.cnt < autocvar_g_vehicle_mg_browning50_machinegun_heatmin) {
		gun.gun1.cnt = autocvar_g_vehicle_mg_browning50_machinegun_heatmin;
	} else {
		gun.gun1.cnt = gun.gun1.cnt - (autocvar_g_vehicle_mg_browning50_machinegun_cooldownrate * sys_frametime);
	}
    }
}


float aerocommander_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;


	
	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin);
	gunner.velocity = vehic.velocity;
	
	float _in, _out;
	vector ad;
  if not (autocvar_g_vehicles_noauxaimforpassengervehic && (vehic.spawnflags < 64)) {
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	if((gun == vehic.gun1))
	{
		_in = autocvar_g_vehicle_aerocommander_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_aerocommander_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_aerocommander_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_aerocommander_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	if(gun == vehic.gun1 || gun == vehic.gun2)
	if (vehic.vehicle_ammo1_max) {
    	gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
    	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;

	if(autocvar_g_vehicle_aerocommander_cannon_lock)
	{
		if(gun.lock_time < time)
			gun.enemy = world;

		if(trace_ent)
			if(trace_ent.movetype)
				if(trace_ent.takedamage)
					if(!trace_ent.deadflag)
					{
						if(teamplay)
						{
							if(trace_ent.team != gunner.team)
							{
								gun.enemy = trace_ent;
								gun.lock_time = time + 5;
							}
						}
						else
						{
							gun.enemy = trace_ent;
							gun.lock_time = time + 5;
						}
					}
	}

	if(gun.enemy)
	{
		float i, distance, impact_time;

		vector vf = real_origin(gun.enemy);
		vector _vel = gun.enemy.velocity;
		if(gun.enemy.movetype == MOVETYPE_WALK)
			_vel_z *= 0.1;


		ad = vf;
		for(i = 0; i < 4; ++i)
		{
			distance = vlen(ad - gunner.origin);
			impact_time = distance / autocvar_g_vehicle_aerocommander_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_aerocommander_cannon_pitchlimit_down * -1, autocvar_g_vehicle_aerocommander_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_aerocommander_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_aerocommander_cannon_pitchlimit_down * -1, autocvar_g_vehicle_aerocommander_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_aerocommander_cannon_turnspeed);

	if ((gun == vehic.gun1) 
	|| (gun == vehic.gun2)) {
		if (vehic.spawnflags & 512) {
			aerocommander_hmg2(vehic, gunner, gun);	
		} else if (vehic.spawnflags & 1024) {
			aerocommander_hvyminigun(vehic, gunner, gun, gun.gun1);
		} else if (vehic.spawnflags & 2048) {
			aerocommander_minigun(vehic, gunner, gun, gun.gun1);
		} 
	}
	
  }


	VEHICLE_UPDATE_PLAYER(gunner, health, aerocommander);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, aerocommander);

  if not (autocvar_g_vehicles_noauxaimforpassengervehic && (vehic.spawnflags < 64)) {	
	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	if ((gun == vehic.gun1) 
	|| (gun == vehic.gun2)) {
		UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 0 0' *(1 - gunner.vehicle_reload1)), 0);

		if(vehic.owner)
			UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 0 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));
	
	}
	
  }

	//The back seats don't have a window to look/shoot out of


	vehic.solid = SOLID_BBOX;
	if(
	 (!((gun == vehic.gun1 || gun == vehic.gun2) && (vehic.spawnflags >= 64)))
	 && (gun != vehic.gun6 && gun != vehic.gun7 && gun != vehic.gun8 && gun != vehic.gun9)
	 && (vehicles_allowdriveby(0, gunner, autocvar_g_vehicles_allowdriveby_pssngr_hudnorm, 4))
	 ) {
		//The 4 is a Magic Number that means "we are an aeroplane"
		//Do nothing
		gunner.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, gun, gunner);
		gunner.BUTTON_CROUCH = 0;
	} else {
		gunner.vehicle_allowdriveby = 0;
		gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	}
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_aerocommander_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void aerocommander_gunner_exit(float _exitflag)
{


	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, self);

		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 0);
		WriteAngle(MSG_ONE, self.vehicle.angles_y);
		WriteAngle(MSG_ONE, 0);
	}
	
	CSQCVehicleSetup(self, HUD_NORMAL);
	setsize(self, PL_MIN, PL_MAX);

	self.vehicle_playerisgunner = 0;
	self.vehicle_playergunnervehicle  = world;
	self.vehicle_changeseat	= func_null;
	self.takedamage     = DAMAGE_AIM;
	self.solid          = SOLID_SLIDEBOX;
	self.movetype       = MOVETYPE_WALK;
	self.effects        &~= EF_NODRAW;
	self.alpha          = 1;
	self.PlayerPhysplug = func_null;
	self.view_ofs       = PL_VIEW_OFS;
	self.event_damage   = PlayerDamage;
	self.hud            = HUD_NORMAL;
	self.switchweapon   = self.vehicle.switchweapon;

    vh_player = self;
    vh_vehicle = self.vehicle;
    MUTATOR_CALLHOOK(VehicleExit);
    self = vh_player;
    self.vehicle = vh_vehicle;

	self.vehicle.vehicle_hudmodel.viewmodelforclient = self.vehicle;

	fixedmakevectors(self.vehicle.owner.angles);

	if(self == self.vehicle.owner.gunner1)
	{
		self.vehicle.owner.gunner1 = world;
	}
	else if(self == self.vehicle.owner.gunner2)
	{
		self.vehicle.owner.gunner2 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner3)
	{
		self.vehicle.owner.gunner3 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner4)
	{
		self.vehicle.owner.gunner4 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner5)
	{
		self.vehicle.owner.gunner5 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner6)
	{
		self.vehicle.owner.gunner6 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner7)
	{
		self.vehicle.owner.gunner7 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner8)
	{
		self.vehicle.owner.gunner8 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner9)
	{
		self.vehicle.owner.gunner9 = world;	
		v_right *= -1;		
	}
	else
		dprint("^1self != gunner1,2,3,4,5,6,...,10, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 132 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float aerocommander_gunner_enter(float selectgun)
{
	RemoveGrapplingHook(other);
	entity _gun, _gunner;
	if(!self.gunner1 && (!selectgun || selectgun == 1))
	{
		_gun = self.gun1;
		_gunner = self.gunner1;
		self.gunner1 = other;
	}
	else if(!self.gunner2 && (!selectgun || selectgun == 2))
	{
		_gun = self.gun2;
		_gunner = self.gunner2;
		self.gunner2 = other;
	}
	else if(!self.gunner3 && (!selectgun || selectgun == 3))
	{
		_gun = self.gun3;
		_gunner = self.gunner3;
		self.gunner3 = other;
	}
	else if(!self.gunner4 && (!selectgun || selectgun == 4))
	{
		_gun = self.gun4;
		_gunner = self.gunner4;
		self.gunner4 = other;
	}
	else if(!self.gunner5 && (!selectgun || selectgun == 5))
	{
		_gun = self.gun5;
		_gunner = self.gunner5;
		self.gunner5 = other;
	}
	else if(!self.gunner6 && (!selectgun || selectgun == 6))
	{
		_gun = self.gun6;
		_gunner = self.gunner6;
		self.gunner6 = other;
	}
	else if(!self.gunner7 && (!selectgun || selectgun == 7))
	{
		_gun = self.gun7;
		_gunner = self.gunner7;
		self.gunner7 = other;
	}
	else if(!self.gunner8 && (!selectgun || selectgun == 8))
	{
		_gun = self.gun8;
		_gunner = self.gunner8;
		self.gunner8 = other;
	}
	else if(!self.gunner9 && (!selectgun || selectgun == 9))
	{
		_gun = self.gun9;
		_gunner = self.gunner9;
		self.gunner9 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = aerocommander_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= aerocommander_gunner_enter;
	other.angles            = self.angles;
	other.takedamage        = DAMAGE_NO;
	other.solid             = SOLID_NOT;
	other.movetype          = MOVETYPE_NOCLIP;
	other.alpha             = -1;
	other.event_damage      = func_null;
	other.view_ofs          = '0 0 0';
	other.hud               = _gun.hud;
	other.PlayerPhysplug    = _gun.PlayerPhysplug;
	other.vehicle_ammo1     = self.vehicle_ammo1;
	other.vehicle_ammo2     = self.vehicle_ammo2;
	other.vehicle_reload1   = self.vehicle_reload1;
	other.vehicle_reload2   = self.vehicle_reload2;
	other.vehicle_energy    = self.vehicle_energy;
	other.PlayerPhysplug    = aerocommander_gunner_frame;
	other.flags             &~= FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
	WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
	WriteAngle(MSG_ONE, 0);                             // roll
	_gun.vehicle_hudmodel.viewmodelforclient = other;

	CSQCVehicleSetup(other, other.hud);
	
    vh_player = other;
    vh_vehicle = _gun;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    _gun = vh_vehicle;

	return TRUE;
}

float aerocommandervehicles_valid_pilot()
{
	if(other.classname != "player")
		return FALSE;

	if(other.deadflag != DEAD_NO)
		return FALSE;

	if(other.vehicle != world)
		return FALSE;

	if(clienttype(other) != CLIENTTYPE_REAL)
		if(!autocvar_g_vehicles_allow_bots)
			return FALSE;

	if(teamplay && other.team != self.team)
		return FALSE;

	return TRUE;
}

void aerocommander_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world && self.gunner5 != world && self.gunner6 != world && self.gunner7 != world && self.gunner8 != world && self.gunner9 != world
	))
	{
		vehicles_touch();
		return;
	}

	if(aerocommandervehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
	
		if(self.gun1.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun2.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun3.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun4.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun5.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun6.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun7.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun8.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
		
		if(self.gun9.phase <= time)
			if(aerocommander_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void aerocommander_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_aerocommander_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_aerocommander_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_aerocommander_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_aerocommander_shield, autocvar_g_vehicle_aerocommander_shield_regen_pause, autocvar_g_vehicle_aerocommander_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_aerocommander_health, autocvar_g_vehicle_aerocommander_health_regen_pause, autocvar_g_vehicle_aerocommander_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_aerocommander_energy, autocvar_g_vehicle_aerocommander_energy_regen_pause, autocvar_g_vehicle_aerocommander_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

float aerocommander_pilot_frame()
{
    entity pilot, vehic;
    float altcontrols = 0;
    vector df;
    float ftmp;
	
	if(intermission_running)
		return 1;

    pilot = self;
    vehic = self.vehicle;
    self   = vehic;

vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_aerocommander_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_aerocommander_speed_forward;
    */
        
    if(self.sound_nexttime < time)
    if not(pilot.waterlevel == WATERLEVEL_SUBMERGED)
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
    
    if(vehic.deadflag != DEAD_NO)
    {
        self = pilot;
        pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(pilot);

    vector vang;
    vang = vehic.angles;
    df = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
    vang_x *= -1;
    df_x *= -1;
    if(df_x > 180)  df_x -= 360;
    if(df_x < -180) df_x += 360;
    if(df_y > 180)  df_y -= 360;
    if(df_y < -180) df_y += 360;
    
    
    //print("wl: ", ftos(vehic.waterlevel), "\n");
    //print(sprintf("waterlevel: %f vehic to player %f\n", vehic.waterlevel, pilot.waterlevel));
	
    if not(pilot.waterlevel == WATERLEVEL_SUBMERGED)
    {
    //Got to do it this way as vehicles waterlevel is always 1
    //Thus we check players water level instead.
    /////////////////////////////////////////////////////////////////////////
    //BEGIN If not in water
    /////////////////////////////////////////////////////////////////////////

    if (vehic.movetype == MOVETYPE_BOUNCEMISSILE) {
    	//If we are flying
    	altcontrols = pilot.vehicle_alternateaircontrols;
    } else {
    	//If we are not flying and taxi on the ground
    	altcontrols = 0;
    }
    

    if (altcontrols) {
    	////Alternative Flight controls (no mouse use needed)
    	// A,D = Turn
	// W,S = Point up, point down
	// Shift A,D = Roll
	// Shift W,S = Speed/Slow
	// Jump (same) rise in altitude
	// Shift (same) lower altitude
	ftmp = 0;
    	if(pilot.movement_y != 0 && !pilot.BUTTON_CROUCH)
   	{
		ftmp = pilot.movement_y * -1 * autocvar_g_vehicle_aerocommander_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	vehic.avelocity_y = bound(-autocvar_g_vehicle_aerocommander_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_aerocommander_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(pilot.movement_x != 0 && !pilot.BUTTON_HOOK && !pilot.BUTTON_CROUCH)
   	{
		ftmp = pilot.movement_x * -1 * autocvar_g_vehicle_aerocommander_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	vehic.avelocity_x = bound(-autocvar_g_vehicle_aerocommander_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_aerocommander_pitchspeed);
    	
	
	
	if(vehic.angles_y > 180)  vehic.angles_y -= 360;
    	if(vehic.angles_y < -180) vehic.angles_y += 360;
	
		if(vehic.angles_y >= -1 && vehic.angles_y <= -1)
            	vehic.angles_y = 0;
		
	if(vehic.angles_x > 180)  vehic.angles_x -= 360;
    	if(vehic.angles_x < -180) vehic.angles_x += 360;
	
	
		if(vehic.angles_x >= -1 && vehic.angles_x <= -1)
            	vehic.angles_x = 0;
		
	if(vehic.angles_z > 180)  vehic.angles_z -= 360;
    	if(vehic.angles_z < -180) vehic.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    vehic.avelocity_y = bound(-autocvar_g_vehicle_aerocommander_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_aerocommander_turnspeed);

    // Pitch
    ftmp = 0;
    if not (pilot.BUTTON_HOOK) {
    	if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_aerocommander_pitchlimit) ftmp = 5;
    	else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_aerocommander_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_aerocommander_pitchlimit, df_x , autocvar_g_vehicle_aerocommander_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_aerocommander_pitchlimit, df_x + ftmp, autocvar_g_vehicle_aerocommander_pitchlimit);
    vehic.avelocity_x = bound(-autocvar_g_vehicle_aerocommander_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_aerocommander_pitchspeed);

    //END
    ///////////////
    }
    
    
    vehic.angles_x = anglemods(vehic.angles_x);
    vehic.angles_y = anglemods(vehic.angles_y);
    vehic.angles_z = anglemods(vehic.angles_z);

    if(autocvar_g_vehicle_aerocommander_movestyle == 1)
        makevectors('0 1 0' * vehic.angles_y);
    else
        makevectors(pilot.v_angle);

    df = vehic.velocity * -autocvar_g_vehicle_aerocommander_friction;

	//print(sprintf("m1 = %f\n", v_forward));
    ////
    ////
	
    if(pilot.BUTTON_HOOK) {
    		if(pilot.movement_x > 0) {
    	    		vehic.bomb1.gun2.count = bound(autocvar_g_vehicle_aerocommander_speed_forward * 0.03, vehic.bomb1.gun2.count + (128 * sys_frametime),autocvar_g_vehicle_aerocommander_speed_forward);
    			
			if((vehic.bomb1.gun2.pushltime < time) && !(vehic.bomb1.gun2.count >= autocvar_g_vehicle_aerocommander_speed_forward))  // Don't flood the connection with the messages
			{
				sprint(pilot, sprintf("Engine Speed Raised to %f %%\n", (vehic.bomb1.gun2.count/autocvar_g_vehicle_aerocommander_speed_forward)*100));
    				vehic.bomb1.gun2.pushltime = time + 0.25;
			}
		} else if(pilot.movement_x < 0) {
    	    		vehic.bomb1.gun2.count = bound(autocvar_g_vehicle_aerocommander_speed_forward * 0.03, vehic.bomb1.gun2.count - (128 * sys_frametime),autocvar_g_vehicle_aerocommander_speed_forward);
    			
			if((vehic.bomb1.gun2.pushltime < time) && !(vehic.bomb1.gun2.count <= autocvar_g_vehicle_aerocommander_speed_forward * 0.03))  // Don't flood the connection with the messages
			{
				sprint(pilot, sprintf("Engine Speed Lowered to %f %%\n", (vehic.bomb1.gun2.count/autocvar_g_vehicle_aerocommander_speed_forward)*100));
    				vehic.bomb1.gun2.pushltime = time + 0.25;
			}
        
   			if(aerocommander_altitude(512) < 16)
			if (vehic.bomb1.gun2.count < autocvar_g_vehicle_aerocommander_speed_forward * 0.05)
				pilot.PlayerPhysplug = aerocommander_takeoff;
		}	 
    } else {
    if((pilot.movement_x != 0 && !altcontrols)
    ||(pilot.movement_x != 0 && altcontrols && pilot.BUTTON_CROUCH))
    {
    	if (vehic.movetype == MOVETYPE_BOUNCEMISSILE) //Only for flying movement 
	{
        	if(pilot.movement_x > 0)
        	    df += v_forward  * autocvar_g_vehicle_aerocommander_speed_forward;
        	else if(pilot.movement_x < 0)
		  df += v_forward  * (autocvar_g_vehicle_aerocommander_speed_forward * 0.32);
	}
    }
    }
    
    if(vehic.movetype != MOVETYPE_BOUNCEMISSILE) {
    	makevectors('0 1 0' * vehic.angles_y); //If we are coasting on the ground we only use where the vehic is pointing
    }
    
    
    
    if(((pilot.movement_x == 0 && !altcontrols) || (pilot.movement_x == 0 && altcontrols && !pilot.BUTTON_CROUCH))
    || (pilot.BUTTON_HOOK)) {
    	df += v_forward  * vehic.bomb1.gun2.count;
    }


    //print(sprintf("ang = %f\n", vehic.angles_z));
    if((pilot.movement_y != 0 && !altcontrols)
    ||(pilot.movement_y != 0 && altcontrols && pilot.BUTTON_CROUCH))
    {
    	if (vehic.movetype == MOVETYPE_BOUNCEMISSILE) {
		//Only for flying movement 
       		if(pilot.movement_y < 0)
        	    df -= v_right * autocvar_g_vehicle_aerocommander_speed_strafe;
        	else if(pilot.movement_y > 0)
        	    df += v_right * autocvar_g_vehicle_aerocommander_speed_strafe;

        	//vehic.angles_z = bound(-30,vehic.angles_z + (pilot.movement_y / autocvar_g_vehicle_aerocommander_speed_strafe),30);
		vehic.angles_z = bound(-360,vehic.angles_z + ((pilot.movement_y * 0.65 * sys_frametime)/ autocvar_g_vehicle_aerocommander_speed_strafe),360);
		//Na, we aint limi-ted, 360 degree roll, Slower than nieuport though (*0.65)
	} else {
		//For non-flying movement
		if(vehic.angles_y > 180)  vehic.angles_y -= 360;
    		if(vehic.angles_y < -180) vehic.angles_y += 360;
		vehic.angles_y = bound(-184,vehic.angles_y + ((pilot.movement_y * sys_frametime) / -16.66666),184);	
		
		if(vehic.angles_y >= -1 && vehic.angles_y <= -1)
            		vehic.angles_y = 0;	
			
		pilot.v_angle_y = vehic.angles_y; //kiss

		if ((clienttype(pilot) == CLIENTTYPE_REAL)) {
			msg_entity = pilot;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, pilot.v_angle_x);
			WriteAngle( MSG_ONE, pilot.v_angle_y);
  			WriteAngle( MSG_ONE, pilot.v_angle_z);
		}
		
		vehic.angles_x = 0;
	}
    }
    else
    {
    	//Stable inverted flight
	if(
	(vehic.angles_z >= 179 && vehic.angles_z <= 180) ||
	(vehic.angles_z <= -179 && vehic.angles_z >= -180))
	{
		vehic.angles_z = 180;
	} else if(
	(vehic.angles_z >= 176 && vehic.angles_z <= 180) ||
	(vehic.angles_z <= -176 && vehic.angles_z >= -180))
	{
		vehic.angles_z *= 1.001;
	} else if(
	(vehic.angles_z >= 170 && vehic.angles_z <= 180) ||
	(vehic.angles_z <= -170 && vehic.angles_z >= -180))
	{
		vehic.angles_z *= 1.0025;
	} else if(
	(vehic.angles_z >= 150 && vehic.angles_z <= 180) ||
	(vehic.angles_z <= -150 && vehic.angles_z >= -180))
	{
		vehic.angles_z *= 1.005;
	} else if(
	(vehic.angles_z >= 100 && vehic.angles_z <= 180) ||
	(vehic.angles_z <= -100 && vehic.angles_z >= -180))
	{
		vehic.angles_z *= 1.01;	
	} else {
        	vehic.angles_z *= 0.965;
	}
        if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
            vehic.angles_z = 0;
    }
    ////
    ////
    
    //Cannon firing
    helicopter_delugegun(vehic, pilot, vehic.bomb11);
    helicopter_delugegun(vehic, pilot, vehic.bomb12);
     
    if (vehic.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	aerocommander_minigun(vehic, pilot, vehic.bomb3, vehic.bomb3.gun1);
	aerocommander_minigun(vehic, pilot, vehic.bomb4, vehic.bomb4.gun1);
	aerocommander_minigun(vehic, pilot, vehic.bomb8, vehic.bomb8.gun1);
	aerocommander_minigun(vehic, pilot, vehic.bomb7, vehic.bomb7.gun1);
	}
	
	if (vehic.spawnflags & 128) {
	aerocommander_hmg(vehic, pilot, vehic.bomb5);
	aerocommander_hmg(vehic, pilot, vehic.bomb6);
	}
	
	if (vehic.spawnflags & 256) {
	aerocommander_hvyminigun(vehic, pilot, vehic.bomb9, vehic.bomb9.gun1);
	aerocommander_hvyminigun(vehic, pilot, vehic.bomb10, vehic.bomb10.gun1);
	aerocommander_hvyminigun(vehic, pilot, vehic.bomb13, vehic.bomb13.gun1);
	aerocommander_hvyminigun(vehic, pilot, vehic.bomb14, vehic.bomb14.gun1);
	}
	
	if (vehic.spawnflags & 16384) {
	aerocommander_raagun(vehic, pilot, vehic.bomb15, vehic.bomb15.gun1);
	}
	
	if ((self.spawnflags & 64) || (self.spawnflags & 256)) {
		if(pilot.BUTTON_HOOK) {
			pilot.BUTTON_JUMP   = 0;
    			pilot.BUTTON_CROUCH    = 0;
    			//pilot.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
    }



    if(vehic.movetype == MOVETYPE_BOUNCEMISSILE) {
    	if((pilot.BUTTON_CROUCH && !altcontrols)
    	||(pilot.BUTTON_CROUCH && altcontrols && !pilot.movement_y && !pilot.movement_x)) {
    	    df -=   v_up * autocvar_g_vehicle_aerocommander_speed_down;
    	} else if ((pilot.BUTTON_JUMP && !altcontrols)
    	|| (pilot.BUTTON_JUMP && altcontrols && !pilot.movement_y && !pilot.movement_x))
    	{
    	    df +=  v_up * autocvar_g_vehicle_aerocommander_speed_up;
    	}
    }
	
    
    vehic.velocity  += df * frametime;
    //vehic.movetype       = MOVETYPE_BOUNCEMISSILE;
    
    if (vehic.bomb1.gun2.count < autocvar_g_vehicle_aerocommander_speed_forward * 0.32) {
    	//If less than *0.32, cannot stay airborne
    	vehic.movetype = MOVETYPE_WALK;
    } else {
    	vehic.movetype = MOVETYPE_BOUNCEMISSILE; //Flying!
    }
    
    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	vehic.velocity  = '0 0 0';
	vehic.velocity_x = 0;
	vehic.velocity_y = 0;
	vehic.velocity_z = 0;
	vehic.avelocity_x = 0;
	vehic.avelocity_y = 0;
	vehic.avelocity_z = 0;
	vehic.movetype  = MOVETYPE_TOSS;
	vehic.bomb1.gun2.count = vehic.bomb1.gun2.count * 0.95;
	vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun1.avelocity_y * 0.95;
    	vehic.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    }
    
    
    
    
    if (altcontrols) {
	pilot.v_angle_x = vehic.angles_x * -1;
	pilot.v_angle_y = vehic.angles_y;
	pilot.v_angle_z = vehic.angles_z; //kiss
	
	pilot.angles_x = vehic.angles_x;
	pilot.angles_y = vehic.angles_y;
	pilot.angles_z = vehic.angles_z; //for completion

	if ((clienttype(pilot) == CLIENTTYPE_REAL)) {
		msg_entity = pilot;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, pilot.v_angle_x);
		WriteAngle( MSG_ONE, pilot.v_angle_y);
  		WriteAngle( MSG_ONE, pilot.v_angle_z);
	}
    }
    
    
    
    pilot.velocity = pilot.movement  = vehic.velocity;
    setorigin(pilot, vehic.origin + '0 0 32');

    // Target lock & predict
    
    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_aerocommander_shield, autocvar_g_vehicle_aerocommander_shield_regen_pause, autocvar_g_vehicle_aerocommander_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_aerocommander_health, autocvar_g_vehicle_aerocommander_health_regen_pause, autocvar_g_vehicle_aerocommander_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_aerocommander_energy, autocvar_g_vehicle_aerocommander_energy_regen_pause, autocvar_g_vehicle_aerocommander_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    //Bomb dropping removed
    
    vehic.bomb1.alpha = vehic.bomb2.alpha = (time - vehic.lip) / (vehic.delay - vehic.lip);
    pilot.vehicle_reload2 = bound(0, vehic.bomb1.alpha * 100, 100);

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, vehic);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_aerocommander_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

//Weapons removed
   

    local entity aerocommander = vehic;

    VEHICLE_UPDATE_PLAYER(pilot, health, aerocommander);
    VEHICLE_UPDATE_PLAYER(pilot, energy, aerocommander);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, aerocommander);


    if (
    ((!((aerocommander.spawnflags & 32)
	|| (aerocommander.spawnflags & 64)
	|| (aerocommander.spawnflags & 128)
	|| (aerocommander.spawnflags & 256)
	|| (aerocommander.spawnflags & 512)
	|| (aerocommander.spawnflags & 1024)
	|| (aerocommander.spawnflags & 2048)
	|| (aerocommander.spawnflags & 16384)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, pilot, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4))
    ) {
		//Do nothing//
		pilot.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(aerocommander, aerocommander, pilot);
		pilot.BUTTON_CROUCH = 0;
    } else {
		pilot.vehicle_allowdriveby = 0;
    		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = pilot.BUTTON_CROUCH = 0;
    }
    
    setorigin(pilot,vehic.origin + '0 0 32');
    pilot.velocity = vehic.velocity;
	
    if (vehic.vehicle_ammo1_max) {
    	pilot.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	pilot.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
    }
    
    if (vehic.vehicle_ammo2_max) {
    	pilot.vehicle_ammo2_current = vehic.vehicle_ammo2_current;
    	pilot.vehicle_ammo2_max = vehic.vehicle_ammo2_max;
    }
    
	self = pilot;

	return 1;
}

void aerocommander_think()
{
	self.nextthink = time;

	if(!self.owner)
	{
		entity oldself = self;		
		if(self.gunner1)
		{
			self = self.gunner1;
			oldself.gun1.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner2)
		{
			self = self.gunner2;
			oldself.gun2.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner3)
		{
			self = self.gunner3;
			oldself.gun3.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner4)
		{
			self = self.gunner4;
			oldself.gun4.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner5)
		{
			self = self.gunner5;
			oldself.gun5.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner6)
		{
			self = self.gunner6;
			oldself.gun6.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner7)
		{
			self = self.gunner7;
			oldself.gun7.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner8)
		{
			self = self.gunner8;
			oldself.gun8.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner9)
		{
			self = self.gunner9;
			oldself.gun9.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
	}
	
}

void aerocommander_enter()
{
	self.touch = aerocommander_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCE;
	aerocommander_pilot_enter();
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void aerocommander_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = aerocommander_think;
	self.nextthink = time;
	
	if(!self.owner)
		return;
	
	//Add from sparrow	
	if(self.deadflag == DEAD_NO)
	{
	        self.bomb1.gun1.count = 0;
        	self.think      = aerocommander_land;
        	self.nextthink  = time;
	}
	//
	
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
			spot = self.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void aerocommander_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_aerocommander_blowup_coredamage,
				 autocvar_g_vehicle_aerocommander_blowup_edgedamage,
				 autocvar_g_vehicle_aerocommander_blowup_radius, self,
				 autocvar_g_vehicle_aerocommander_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void aerocommander_diethink()
{
	if(time >= self.wait)
		self.think = aerocommander_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void aerocommander_die()
{
	entity oldself = self;
	
	if(self.gunner1)
	{
		self = self.gunner1;
		oldself.gun1.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner2)
	{
		self = self.gunner2;
		oldself.gun2.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner3)
	{
		self = self.gunner3;
		oldself.gun3.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner4)
	{
		self = self.gunner4;
		oldself.gun4.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner5)
	{
		self = self.gunner5;
		oldself.gun5.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner6)
	{
		self = self.gunner6;
		oldself.gun6.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner7)
	{
		self = self.gunner7;
		oldself.gun7.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner8)
	{
		self = self.gunner8;
		oldself.gun8.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner9)
	{
		self = self.gunner9;
		oldself.gun9.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}

	self.vehicle_exit(VHEF_EJECT);
	
	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = aerocommander_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 1;
	_body.think = aerocommander_diethink;
	_body.nextthink = time;
	_body.wait = time + 2 + (random() * 8);
	_body.owner = self;
	_body.enemy = self.enemy;
	
	pointparticles(particleeffectnum("explosion_medium"), findbetterlocation(self.origin, 16), '0 0 0', 1);
	
	self.health			= 0;
	self.event_damage	= func_null;
	self.solid			= SOLID_CORPSE;
	self.takedamage		= DAMAGE_NO;
	self.deadflag		= DEAD_DYING;
	self.movetype		= MOVETYPE_NONE;
	self.effects		= EF_NODRAW;
	self.colormod		= '0 0 0';
	self.avelocity		= '0 0 0';
	self.velocity		= '0 0 0';
	self.touch 			= func_null;
	self.nextthink 		= 0;

	setorigin(self, self.pos1);
	
	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxftd1); 
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
	
	helicopter_rotor_die(self.rotorboxftr); 
    	helicopter_rotor_die(self.rotorboxmfr); //Middle front
	helicopter_rotor_die(self.rotorboxftd2); 
	helicopter_rotor_die(self.rotorboxmbr); //Mid back
    	helicopter_rotor_die(self.rotorboxbkr);
}

void aerocommander_impact()
{
    if(autocvar_g_vehicle_aerocommander_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_aerocommander_bouncepain_x, 
						autocvar_g_vehicle_aerocommander_bouncepain_y, 
						autocvar_g_vehicle_aerocommander_bouncepain_z);
}

// If we dont do this ever now and then, the aerocommanders rotors
// stop working, presumably due to angle overflow. cute.
void aerocommander_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

void aerocommander_spawn(float _f)
{
   self.vehicle_pilotchangeseat = aerocommander_gunner_enter; //Function to exec if pilot wants to change seat
    
	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
    if(!self.gun1)
    {
    	if (self.spawnflags >= 64) {
		self.lodmodel1 = "models/vehicles/aerocommanderedits_milspec_lod1.iqm";
	} else {
		self.lodmodel1 = "models/vehicles/aerocommanderedits_lod1.iqm";
	}
	self.loddistance1 = 32;
	
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
     
        entity spinner;
	
	// for some reason, autosizing of the shiled entity refuses to work for this one so set it up in advance.
		self.vehicle_shieldent = spawn();
		self.vehicle_shieldent.effects = EF_LOWPRECISION;
		setmodel(self.vehicle_shieldent, "models/vhshield.md3");
		setattachment(self.vehicle_shieldent, self, "");
		setorigin(self.vehicle_shieldent, real_origin(self) - self.origin);
		self.vehicle_shieldent.scale       = 512 / vlen(self.maxs - self.mins);
		self.vehicle_shieldent.think       = shieldhit_think;
		self.vehicle_shieldent.alpha = -1;
		self.vehicle_shieldent.effects = EF_LOWPRECISION | EF_NODRAW;

        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();
		self.gun3 = spawn();
		self.gun4 = spawn();
		self.gun5 = spawn();
		self.gun6 = spawn();
		self.gun7 = spawn();
		self.gun8 = spawn();
		self.gun9 = spawn();

        setmodel(self.bomb1,"null");
        setmodel(self.bomb2,"null");
        //setmodel(self.tur_head, "models/vehicles/aerocommanderedits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_left");
        setattachment(self.bomb2, self, "bombmount_right");
        //setattachment(self.tur_head, self,"root");

        // FIXMODEL Guns mounts to angled bones
        self.bomb1.angles = self.angles;
        self.angles = '0 0 0';

        self.angles = self.bomb1.angles;
        self.bomb1.angles = '0 0 0';

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/aerocommander_spinner.iqm");
        setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	//spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/aerocommander_spinner2.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = aerocommander_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_aerocommander_mass;
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxftd1 = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.rotorboxftr = spawn();
	self.rotorboxmfr = spawn();
	self.rotorboxftd2 = spawn();
	self.rotorboxmbr = spawn();
    	self.rotorboxbkr = spawn();
	
	self.bomb1.gun1.count = 0;
	self.bomb1.gun2.count = autocvar_g_vehicle_aerocommander_speed_forward * 0.1; //For non-flying movement
	
	self.vehicle_flags |= VHF_MULTISLOT;

	self.gun1.owner = self;
	self.gun2.owner = self;
	self.gun3.owner = self;
	self.gun4.owner = self;
	self.gun5.owner = self;
	self.gun6.owner = self;
	self.gun7.owner = self;
	self.gun8.owner = self;
	self.gun9.owner = self;
	
	if (self.spawnflags & 512) {
		setmodel(self.gun1, "models/mountedguns/browning50gun.iqm"); //Right
		setmodel(self.gun2, "models/mountedguns/browning50gun.iqm"); //Left
		setattachment(self.gun1, self, "pintelmount_right");
		setattachment(self.gun2, self, "pintelmount_left");
		vehicle_addplayerslot(self, self.gun1, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	
		setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_camera");
		setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_camera");
		
			//LOD stuff.
			self.gun2.owner = self.gun1.owner = self;
			self.gun2.lodowner = self.gun1.lodowner = 1; //Use owner origin for computing LOD
			self.gun2.lodmodel1 = self.gun1.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
			self.gun2.lodmodel2 = self.gun1.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end	
	} else if (self.spawnflags & 1024) {
		setmodel(self.gun1, "models/mountedguns/gau19gun.iqm"); //Right
		setmodel(self.gun2, "models/mountedguns/gau19gun.iqm"); //Left
		setattachment(self.gun1, self, "pintelmount_right");
		setattachment(self.gun2, self, "pintelmount_left");
		vehicle_addplayerslot(self, self.gun1, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	
		setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_camera");
		setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_camera");
		
		//.50 Minigun Barrels
		self.gun1.gun1 = spawn();
		setmodel(self.gun1.gun1,"models/mountedguns/gau19gun_barrels.iqm");
		setattachment(self.gun1.gun1, self.gun1, "tag_axis");
		self.gun1.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
		
		//.50 Minigun Barrels
		self.gun2.gun1 = spawn();
		setmodel(self.gun2.gun1,"models/mountedguns/gau19gun_barrels.iqm");
		setattachment(self.gun2.gun1, self.gun2, "tag_axis");
		self.gun2.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
		
			//LOD stuff.
			self.gun2.owner = self.gun1.owner = self;
			self.gun2.lodowner = self.gun1.lodowner = 1; //Use owner origin for computing LOD
			self.gun2.lodmodel1 = self.gun1.lodmodel1 = "models/mountedguns/gau19gun_lod1.iqm";
			self.gun2.lodmodel1 = self.gun1.lodmodel2 = "models/mountedguns/gau19gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end	
	} else if (self.spawnflags & 2048) {
		setmodel(self.gun1, "models/mountedguns/m134gun.iqm"); //Right
		setmodel(self.gun2, "models/mountedguns/m134gun.iqm"); //Left
		setattachment(self.gun1, self, "pintelmount_right");
		setattachment(self.gun2, self, "pintelmount_left");
		vehicle_addplayerslot(self, self.gun1, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	
		setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_camera");
		setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_camera");
		
		//Minigun Barrels
		self.gun1.gun1 = spawn();
		setmodel(self.gun1.gun1,"models/mountedguns/m134gun_barrels.iqm");
		setattachment(self.gun1.gun1, self.gun1, "tag_axis");
		self.gun1.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
		
		//Minigun Barrels
		self.gun2.gun1 = spawn();
		setmodel(self.gun2.gun1,"models/mountedguns/m134gun_barrels.iqm");
		setattachment(self.gun2.gun1, self.gun2, "tag_axis");
		self.gun2.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
		
			//LOD stuff.
			self.gun2.owner = self.gun1.owner = self;
			self.gun2.lodowner = self.gun1.lodowner = 1; //Use owner origin for computing LOD
			self.gun2.lodmodel1 = self.gun1.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
			self.gun2.lodmodel2 = self.gun1.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end	
	} else {
		setmodel(self.gun1, "null");
        	setmodel(self.gun2, "null");
		setattachment(self.gun1, self, "tag_pass1");
		setattachment(self.gun2, self, "tag_pass2");
		vehicle_addplayerslot(self, self.gun1, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	}
		
		setmodel(self.gun3, "null");
		setmodel(self.gun4, "null");
		setmodel(self.gun5, "null");
		setmodel(self.gun6, "null");
		setmodel(self.gun7, "null");
		setmodel(self.gun8, "null");
		setmodel(self.gun9, "null");
		
	
	setattachment(self.gun3, self, "tag_pass3");
	setattachment(self.gun4, self, "tag_pass4");
	setattachment(self.gun5, self, "tag_pass5");
	setattachment(self.gun6, self, "tag_pass6");
	setattachment(self.gun7, self, "tag_pass7");
	setattachment(self.gun8, self, "tag_pass8");
	setattachment(self.gun9, self, "tag_pass9");
	
	vehicle_addplayerslot(self, self.gun3, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun4, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun5, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun6, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun7, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun8, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	vehicle_addplayerslot(self, self.gun9, HUD_RAPTOR, "null", aerocommander_gunner_frame, aerocommander_gunner_exit);
	
	helicopter_delugegun_add(self, "forwardmount_left");
	helicopter_delugegun_add2(self, "forwardmount_right");
	
	if (self.spawnflags & 64) {
	//Minigun Left Stuff
	self.bomb3 = spawn();
	setmodel(self.bomb3,"models/vehicles/m134simple.iqm");
	setattachment(self.bomb3, self, "gunmount_left");
	
	//Minugun Left Barrels
	self.bomb3.gun1 = spawn();
	setmodel(self.bomb3.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb3.gun1, self.bomb3, "tag_axis");
	self.bomb3.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb3.angles_z = -110; //So ammo chain travels into fuselage
	
	//Minigun Right Stuff
	self.bomb4 = spawn();
	setmodel(self.bomb4,"models/vehicles/m134simple.iqm");
	setattachment(self.bomb4, self, "gunmount_right");
	
	//Minugun Right Barrels
	self.bomb4.gun1 = spawn();
	setmodel(self.bomb4.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb4.gun1, self.bomb4, "tag_axis");
	self.bomb4.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb4.angles_z = 120; //So ammo chain travels into fuselage
	
	////////
	
	
	//Minigun Left Stuff
	self.bomb8 = spawn();
	setmodel(self.bomb8,"models/vehicles/m134simple.iqm");
	setattachment(self.bomb8, self, "gunmount_left4");
	
	//Minugun Left Barrels
	self.bomb8.gun1 = spawn();
	setmodel(self.bomb8.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb8.gun1, self.bomb8, "tag_axis");
	self.bomb8.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb8.angles_z = -110; //So ammo chain travels into fuselage
	
	//Minigun Right Stuff
	self.bomb7 = spawn();
	setmodel(self.bomb7,"models/vehicles/m134simple.iqm");
	setattachment(self.bomb7, self, "gunmount_right4");
	
	//Minugun Right Barrels
	self.bomb7.gun1 = spawn();
	setmodel(self.bomb7.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb7.gun1, self.bomb7, "tag_axis");
	self.bomb7.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb7.angles_z = 120; //So ammo chain travels into fuselage
	
			//LOD stuff.
			self.bomb3.owner = self.bomb4.owner = self.bomb8.owner = self.bomb7.owner = self;
			self.bomb3.lodowner = self.bomb4.lodowner = self.bomb8.lodowner = self.bomb7.lodowner = 1; //Use owner origin for computing LOD
			self.bomb3.lodmodel1 = self.bomb4.lodmodel1 = self.bomb8.lodmodel1 = self.bomb7.lodmodel1 = "models/vehicles/m134simple_lod1.iqm";
			InitializeEntity(self.bomb3, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb4, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb8, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb7, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
	}
	
	if (self.spawnflags & 128) {
	//.50 Left Stuff
	self.bomb5 = spawn();
	setmodel(self.bomb5,"models/mountedguns/browning50gun.iqm");
	setattachment(self.bomb5, self, "forwardmount_left");
		
	self.bomb5.angles_z = 90; //So ammo chain travels into fuselage
	
	//.50 Right Stuff
	self.bomb6 = spawn();
	setmodel(self.bomb6,"models/mountedguns/browning50gun.iqm");
	setattachment(self.bomb6, self, "forwardmount_right");
	
	self.bomb6.angles_z = 90; //So ammo chain travels into fuselage
	
			//LOD stuff.
			self.bomb5.owner = self.bomb6.owner = self;
			self.bomb5.lodowner = self.bomb6.lodowner = 1; //Use owner origin for computing LOD
			self.bomb5.lodmodel1 = self.bomb6.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
			self.bomb5.lodmodel2 = self.bomb6.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
			InitializeEntity(self.bomb5, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb6, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
	}
	
	
	if (self.spawnflags & 256) {
			//.50 Minigun Left Stuff
			self.bomb9 = spawn();
			setmodel(self.bomb9,"models/vehicles/m134simple.iqm");
			
			setattachment(self.bomb9, self, "gunmount_right5");
			
	
			//.50 Minugun Left Barrels
			self.bomb9.gun1 = spawn();
			setmodel(self.bomb9.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb9.gun1, self.bomb9, "tag_axis");
			self.bomb9.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
			self.bomb9.angles_z = 110; //So ammo chain travels into fuselage

			
			//.50 Minigun Left Stuff
			self.bomb10 = spawn();
			setmodel(self.bomb10,"models/vehicles/m134simple.iqm");
			
			setattachment(self.bomb10, self, "gunmount_left5");
			
	
			//.50 Minugun Left Barrels
			self.bomb10.gun1 = spawn();
			setmodel(self.bomb10.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb10.gun1, self.bomb10, "tag_axis");
			self.bomb10.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
			self.bomb10.angles_z = -110; //So ammo chain travels into fuselage
			
			
			//////
			//.50 Minigun Left Stuff
			self.bomb13 = spawn();
			setmodel(self.bomb13,"models/vehicles/m134simple.iqm");
			
			setattachment(self.bomb13, self, "gunmount_right6");
			
	
			//.50 Minugun Left Barrels
			self.bomb13.gun1 = spawn();
			setmodel(self.bomb13.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb13.gun1, self.bomb13, "tag_axis");
			self.bomb13.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
			self.bomb13.angles_z = 110; //So ammo chain travels into fuselage

			
			//.50 Minigun Left Stuff
			self.bomb14 = spawn();
			setmodel(self.bomb14,"models/vehicles/m134simple.iqm");
			
			setattachment(self.bomb14, self, "gunmount_left6");
			
	
			//.50 Minugun Left Barrels
			self.bomb14.gun1 = spawn();
			setmodel(self.bomb14.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb14.gun1, self.bomb14, "tag_axis");
			self.bomb14.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
			self.bomb14.angles_z = -100; //So ammo chain travels into fuselage
			
			//LOD stuff.
			self.bomb9.owner = self.bomb10.owner = self.bomb13.owner = self.bomb14.owner = self;
			self.bomb9.lodowner = self.bomb10.lodowner = self.bomb13.lodowner = self.bomb14.lodowner = 1; //Use owner origin for computing LOD
			self.bomb9.lodmodel1 = self.bomb10.lodmodel1 = self.bomb13.lodmodel1 = self.bomb14.lodmodel1 = "models/vehicles/m134simple_lod1.iqm";
			InitializeEntity(self.bomb9, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb10, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb13, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.bomb14, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end

	}
	
	if (self.spawnflags & 16384) {
		//20mm Minigun Stuff
		self.bomb15 = spawn();
		self.bomb15.scale = 2;
		setmodel(self.bomb15,"models/vehicles/m134simple_lod1.iqm");
		setattachment(self.bomb15, self, "coaxilmount1_back");
		
			//LOD stuff.
			self.bomb15.owner = self;
			self.bomb15.lodowner = 1; //Use owner origin for computing LOD
			self.bomb15.lodmodel1 = "models/vehicles/m134simple_lod1.iqm";
			InitializeEntity(self.bomb15, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
	
		//20mm Minugun Barrels
		self.bomb15.gun1 = spawn();
		setmodel(self.bomb15.gun1,"models/mountedguns/m134gun_barrels.iqm");
		setattachment(self.bomb15.gun1, self.bomb15, "tag_axis");
		self.bomb15.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	}
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_aerocommander_health;
    self.vehicle_shield = autocvar_g_vehicle_aerocommander_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, AEROCOMMANDER_MIN, AEROCOMMANDER_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_aerocommander_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_aerocommander_bouncestop;    
    self.vehicle_impact = aerocommander_impact;    
    self.damageforcescale = 0.25;
    
    	//if (self.spawnflags & 64) {	
	//	self.bomb1.gun1.colormap = 1228;
	//	self.bomb1.gun2.colormap = 1228;
	//}
	
	//if (self.spawnflags & 128) {
    	//	self.bomb1.gun1.colormap = 1041;
	//	self.bomb1.gun2.colormap = 1041;
	//}
    	
	//if (self.spawnflags & 64)
	//if (self.spawnflags & 128)
	//{
	//	self.bomb1.gun1.colormap = 1092;
	//	self.bomb1.gun2.colormap = 1092;
	//}
	
	self.bomb1.gun1.colormap = 1023;
	self.bomb1.gun2.colormap = 1023;
	
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly
	
    //vorg = gettaginfo(self, gettagindex(self, "engine_right"));
    //vorg -= self.origin;
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxft, AEROCOMMANDERROTOR_MIN_HBF_T, AEROCOMMANDERROTOR_MAX_HBF_T, 0, 70, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmf, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, 35, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxftd1, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxmb, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, -35, 0);	
    aeroplane_prop_spawn_hitbox(0, self, self.rotorboxbk, AEROCOMMANDERROTOR_MIN_HBF_T, AEROCOMMANDERROTOR_MAX_HBF_T, 0, -70, 0);

    //vorg = gettaginfo(self, gettagindex(self, "engine_left"));
    //vorg -= self.origin;
    aeroplane_prop_spawn_hitbox(1, self, self.rotorboxftr, AEROCOMMANDERROTOR_MIN_HBF_T, AEROCOMMANDERROTOR_MAX_HBF_T, 0, 70, 0);
    aeroplane_prop_spawn_hitbox(1, self, self.rotorboxmfr, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, 35, 0);	
    aeroplane_prop_spawn_hitbox(1, self, self.rotorboxftd2, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, 0, 0);
    aeroplane_prop_spawn_hitbox(1, self, self.rotorboxmbr, AEROCOMMANDERROTOR_MIN_HBB_T, AEROCOMMANDERROTOR_MAX_HBB_T, 0, -35, 0);	
    aeroplane_prop_spawn_hitbox(1, self, self.rotorboxbkr, AEROCOMMANDERROTOR_MIN_HBF_T, AEROCOMMANDERROTOR_MAX_HBF_T, 0, -70, 0);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_aerocommander()
{
	if(!autocvar_g_vehicle_aerocommander)
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

    	precache_model ("models/vhshield.md3");
	
	float caammomax;
	string bodymodel;
	
	if (self.spawnflags & 32) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		precache_sound ( "machines/steam_fade.ogg" );
	}
	
	if (self.spawnflags >= 64) {
		if ((self.spawnflags & 64) || (self.spawnflags & 2048)) {
			if (self.spawnflags & 64)
				precache_model ( "models/vehicles/m134simple.iqm");
				precache_model ( "models/vehicles/m134simple_lod1.iqm");
			if (self.spawnflags & 2048) {
				precache_model ( "models/mountedguns/m134gun.iqm");
				precache_model ( "models/mountedguns/m134gun_lod1.iqm");
				precache_model ( "models/mountedguns/m134gun_lod2.iqm");
			}
			
			precache_model ( "models/mountedguns/m134gun_barrels.iqm");
			precache_sound ( "weapons/uzi_fire.wav" );
		}
		
		if ((self.spawnflags & 128) || (self.spawnflags & 512)) {
			precache_model ( "models/mountedguns/browning50gun.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod1.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod2.iqm");
			precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		}
		
		if ((self.spawnflags & 256) || (self.spawnflags & 1024)) {
			if (self.spawnflags & 256)
				precache_model ( "models/vehicles/m134simple.iqm"); //Might need to make one for the gau? Lod it too?

			if (self.spawnflags & 1024) {
				precache_model ( "models/mountedguns/gau19gun.iqm");
				precache_model ( "models/mountedguns/gau19gun_lod1.iqm");
				precache_model ( "models/mountedguns/gau19gun_lod2.iqm");
			}
			
			precache_model ( "models/mountedguns/gau19gun_barrels.iqm");
			precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		}
		
		if (self.spawnflags & 16384) {
			//Big Coaxil gun
			precache_model ( "models/vehicles/m134simple.iqm");
			precache_model ( "models/mountedguns/m134gun_barrels.iqm");
			precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
		}
		
		precache_model ( "models/uziflash.md3");
		
		precache_model("models/vehicles/aerocommanderedits_milspec.iqm");
		precache_model ("models/vehicles/aerocommanderedits_milspec_lod1.iqm");
		
		bodymodel = "models/vehicles/aerocommanderedits_milspec.iqm";
		
		caammomax = autocvar_g_vehicle_mg_m134_machinegun_ammo_max * 6;
	} else {
		precache_model("models/vehicles/aerocommanderedits.iqm");
		precache_model ("models/vehicles/aerocommanderedits_lod1.iqm");
		bodymodel = "models/vehicles/aerocommanderedits.iqm";
		caammomax = 0;
	}
	
	precache_model ("models/vehicles/aerocommander_spinner.iqm");
	precache_model ("models/vehicles/aerocommander_spinner2.iqm");
	
	
	
	precache_sound ("vehicles/raptor_fly.wav");
	precache_sound ("vehicles/raptor_speed.wav");
	precache_sound ("vehicles/missile_alarm.wav");
	precache_sound ( "weapons/rocket_impact.wav");

	if(autocvar_g_vehicle_aerocommander_energy)
		if(autocvar_g_vehicle_aerocommander_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_aerocommander_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_aerocommander_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_aerocommander_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1109; //Light Blue
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "AeroCommander",
			   bodymodel,
			   "null", // we need this so tur_head is networked and usable for sounds
			   "null", 
			   "", "", "tag_viewport",
			   HUD_RAPTOR, 
           		   AEROCOMMANDER_MIN, AEROCOMMANDER_MAX,
			   FALSE,
			   aerocommander_spawn, autocvar_g_vehicle_aerocommander_respawntime,
			   aerocommander_pilot_frame, aerocommander_enter, aerocommander_exit,
			   aerocommander_die, aerocommander_think, FALSE, autocvar_g_vehicle_aerocommander_health, autocvar_g_vehicle_aerocommander_shield, autocolor, caammomax, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}

void spawnfunc_vehicle_aerocommander_milspec()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 1024 + 16384; //So we spawn weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_aerocommander();
}
#endif // SVQC

#ifdef CSQC
void aerocommander_draw()
{

}

void aerocommander_draw2d()
{

}

void aerocommander_read_extra()
{

}

void vehicle_aerocommander_assemble()
{

}
#endif //CSQC
