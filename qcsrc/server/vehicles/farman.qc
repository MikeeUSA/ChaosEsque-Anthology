#define FARMAN_MIN '-70 -70 0'
#define FARMAN_MAX '70 70 120'

#ifdef SVQC
float autocvar_g_vehicle_farman;

float autocvar_g_vehicle_farman_mass;

float autocvar_g_vehicle_farman_respawntime;
float autocvar_g_vehicle_farman_takeofftime;

float autocvar_g_vehicle_farman_movestyle;
float autocvar_g_vehicle_farman_turnspeed;
float autocvar_g_vehicle_farman_pitchspeed;
float autocvar_g_vehicle_farman_pitchlimit;

float autocvar_g_vehicle_farman_speed_forward;
float autocvar_g_vehicle_farman_speed_strafe;
float autocvar_g_vehicle_farman_speed_up;
float autocvar_g_vehicle_farman_speed_down;
float autocvar_g_vehicle_farman_friction;

float autocvar_g_vehicle_farman_bombs_refire;

float autocvar_g_vehicle_farman_energy;
float autocvar_g_vehicle_farman_energy_regen;
float autocvar_g_vehicle_farman_energy_regen_pause;

float autocvar_g_vehicle_farman_health;
float autocvar_g_vehicle_farman_health_regen;
float autocvar_g_vehicle_farman_health_regen_pause;

float autocvar_g_vehicle_farman_shield;
float autocvar_g_vehicle_farman_shield_regen;
float autocvar_g_vehicle_farman_shield_regen_pause;

float autocvar_g_vehicle_farman_bouncefactor;
float autocvar_g_vehicle_farman_bouncestop;
vector autocvar_g_vehicle_farman_bouncepain;

void farman_spawn(float);
float farman_frame();
float farman_takeoff();

.entity bomb1;
.entity bomb2;

float farman_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

void farman_think()
{
}


void farman_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);
    RadiusDamage (self, self.enemy, 75, 15, 100, world, 75, DEATH_WAKIBLOWUP, world);

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

void farman_diethink()
{
	if(time >= self.wait)
		self.think = farman_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void farman_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = farman_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = farman_blowup;
}


void farman_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = farman_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_farman_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_farman_shield) * 100;
    //self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_farman_bombs_refire;
    self.lip   = time;
    

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void farman_land()
{    
    float hgt;
        
    hgt = farman_altitude(512);    
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
	(self.angles_z >= 40 && self.angles_z <= 180) ||
	(self.angles_z <= -40 && self.angles_z >= -180))
	{
                Damage(self, self, self.owner, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} else {
	        self.think    = farman_think;
	}
        self.movetype = MOVETYPE_TOSS;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

void farman_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.bomb1.gun1.count = 0;
        self.think      = farman_land;
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

float farman_takeoff()
{
    entity player, farman;
    
    player = self;
    farman = self.vehicle;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (farman.bomb1.gun1.count == 0)) {
	    	farman.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        } else if((player.movement_x < 0) && (farman.bomb1.gun1.count == 1)) {
	  	farman.bomb1.gun1.count = 0;
		sprint(player, "engine set to minimum\n");
	}
    }
    
    self   = farman;
    if(self.sound_nexttime < time)
    {        
        if (farman.bomb1.gun1.count) {
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
    }   

    // Takeoff sequense
    if(farman.bomb1.gun1.count == 1) {
    if(farman.frame < 25)
    {
    	makevectors(farman.angles);
    	farman.movetype       = MOVETYPE_WALK;
        farman.frame += 25 / (autocvar_g_vehicle_farman_takeofftime / sys_frametime);
        if(farman.frame > 23)
		farman.velocity_z = min(1 + (farman.velocity_z * 1.5), 32);
        self.bomb1.gun1.avelocity_y = 90 + ((farman.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	movelib_move_simple(normalize(v_forward),autocvar_g_vehicle_farman_speed_forward * 0.7 * (farman.frame/25),0.075);
    }
    else
    {
    	farman.movetype     = MOVETYPE_BOUNCEMISSILE;
        player.PlayerPhysplug = farman_frame;
    }
    } else {
    	//Engine off?
    	farman.movetype     = MOVETYPE_BOUNCE;
    	if (farman.frame > 0) {
        	farman.frame -= 25 / (autocvar_g_vehicle_farman_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((farman.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(farman.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Crash?
    if(
	(farman.angles_z >= 40 && farman.angles_z <= 180) ||
	(farman.angles_z <= -40 && farman.angles_z >= -180))
	{
		Damage(farman, farman, player, 2000, DEATH_VHCRUSH, '0 0 0', '0 0 0');
	} 
    
    
    if (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4)) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(farman, farman, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    
    setorigin(player, farman.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(farman.dmg_time, vehicle_shield, autocvar_g_vehicle_farman_shield, autocvar_g_vehicle_farman_shield_regen_pause, autocvar_g_vehicle_farman_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(farman.dmg_time, vehicle_health, autocvar_g_vehicle_farman_health, autocvar_g_vehicle_farman_health_regen_pause, autocvar_g_vehicle_farman_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(farman.cnt, vehicle_energy, autocvar_g_vehicle_farman_energy, autocvar_g_vehicle_farman_energy_regen_pause, autocvar_g_vehicle_farman_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    farman.bomb1.alpha = farman.bomb2.alpha = (time - farman.lip) / (farman.delay - farman.lip);
    player.vehicle_reload2 = bound(0, farman.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, farman);
    VEHICLE_UPDATE_PLAYER(player, energy, farman);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, farman);
    
    
    if (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4)) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(farman, farman, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

//Flare Stuff removed

float farman_frame()
{
    entity player, farman;
    float altcontrols = 0;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    altcontrols = player.vehicle_alternateaircontrols;
    farman = self.vehicle;
    self   = farman;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_farman_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_farman_speed_forward;
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
    
    if(farman.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace(player);

    vector vang;
    vang = farman.angles;
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
		ftmp = player.movement_y * -1 * autocvar_g_vehicle_farman_turnspeed/60 * sys_frametime;
	}
	
	if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    	farman.avelocity_y = bound(-autocvar_g_vehicle_farman_turnspeed, ftmp + farman.avelocity_y * 0.9, autocvar_g_vehicle_farman_turnspeed);



	//// Pitch
    	ftmp = 0;
	
	if(player.movement_x != 0 && !player.BUTTON_HOOK && !player.BUTTON_CROUCH)
   	{
		ftmp = player.movement_x * -1 * autocvar_g_vehicle_farman_pitchspeed/60 * sys_frametime;
		//-1 for "inverted" controls (feels more natural)		
	}
	
    	farman.avelocity_x = bound(-autocvar_g_vehicle_farman_pitchspeed, ftmp + farman.avelocity_x * 0.9, autocvar_g_vehicle_farman_pitchspeed);
    	
	
	
	if(farman.angles_y > 180)  farman.angles_y -= 360;
    	if(farman.angles_y < -180) farman.angles_y += 360;
	
		if(farman.angles_y >= -1 && farman.angles_y <= -1)
            	farman.angles_y = 0;
		
	if(farman.angles_x > 180)  farman.angles_x -= 360;
    	if(farman.angles_x < -180) farman.angles_x += 360;
	
	
		if(farman.angles_x >= -1 && farman.angles_x <= -1)
            	farman.angles_x = 0;
		
	if(farman.angles_z > 180)  farman.angles_z -= 360;
    	if(farman.angles_z < -180) farman.angles_z += 360;
	

    } else {
    ///////////////
    //START Normal
    
    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    farman.avelocity_y = bound(-autocvar_g_vehicle_farman_turnspeed, ftmp + farman.avelocity_y * 0.9, autocvar_g_vehicle_farman_turnspeed);

    // Pitch
    ftmp = 0;
    if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_farman_pitchlimit) ftmp = 5;
    else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_farman_pitchlimit) ftmp = -20;

    df_x = bound(-autocvar_g_vehicle_farman_pitchlimit, df_x , autocvar_g_vehicle_farman_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_farman_pitchlimit, df_x + ftmp, autocvar_g_vehicle_farman_pitchlimit);
    farman.avelocity_x = bound(-autocvar_g_vehicle_farman_pitchspeed, ftmp + farman.avelocity_x * 0.9, autocvar_g_vehicle_farman_pitchspeed);
    
    
    //END
    ///////////////
    }
    
    
    farman.angles_x = anglemods(farman.angles_x);
    farman.angles_y = anglemods(farman.angles_y);
    farman.angles_z = anglemods(farman.angles_z);

    if(autocvar_g_vehicle_farman_movestyle == 1)
        makevectors('0 1 0' * farman.angles_y);
    else
        makevectors(player.v_angle);

    df = farman.velocity * -autocvar_g_vehicle_farman_friction;

	//print(sprintf("m1 = %f\n", v_forward));	
    if(player.BUTTON_HOOK)
    if(player.movement_x < 0)
    {
        if(farman_altitude(512) < 16)
		player.PlayerPhysplug = farman_takeoff;
    }
   
   
    
    if((player.movement_x != 0 && !altcontrols)
    ||(player.movement_x != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_farman_speed_forward;
        else if(player.movement_x < 0)
          //df -= v_forward  * autocvar_g_vehicle_farman_speed_forward;
	  df += v_forward  * (autocvar_g_vehicle_farman_speed_forward * 0.7);
    } else {
    	df += v_forward  * (autocvar_g_vehicle_farman_speed_forward * 0.9); //1 speed engine
    }



    //print(sprintf("ang = %f\n", farman.angles_z));
    if((player.movement_y != 0 && !altcontrols)
    ||(player.movement_y != 0 && altcontrols && player.BUTTON_CROUCH))
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_farman_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_farman_speed_strafe;

        //farman.angles_z = bound(-30,farman.angles_z + (player.movement_y / autocvar_g_vehicle_farman_speed_strafe),30);
	farman.angles_z = bound(-360,farman.angles_z + ((player.movement_y * 0.65 * sys_frametime)/ autocvar_g_vehicle_farman_speed_strafe),360);
	//Na, we aint limi-ted, 360 degree roll, Slower than nieuport though (*0.65)
    }
    else
    {
    	//Stable inverted flight
	if(
	(farman.angles_z >= 179 && farman.angles_z <= 180) ||
	(farman.angles_z <= -179 && farman.angles_z >= -180))
	{
		farman.angles_z = 180;
	} else if(
	(farman.angles_z >= 176 && farman.angles_z <= 180) ||
	(farman.angles_z <= -176 && farman.angles_z >= -180))
	{
		farman.angles_z *= 1.001;
	} else if(
	(farman.angles_z >= 170 && farman.angles_z <= 180) ||
	(farman.angles_z <= -170 && farman.angles_z >= -180))
	{
		farman.angles_z *= 1.0025;
	} else if(
	(farman.angles_z >= 150 && farman.angles_z <= 180) ||
	(farman.angles_z <= -150 && farman.angles_z >= -180))
	{
		farman.angles_z *= 1.005;
	} else if(
	(farman.angles_z >= 100 && farman.angles_z <= 180) ||
	(farman.angles_z <= -100 && farman.angles_z >= -180))
	{
		farman.angles_z *= 1.01;	
	} else {
        	farman.angles_z *= 0.965;
	}
        if(farman.angles_z >= -1 && farman.angles_z <= -1)
            farman.angles_z = 0;
    }



    if((player.BUTTON_CROUCH && !altcontrols)
    ||(player.BUTTON_CROUCH && altcontrols && !player.movement_y && !player.movement_x)) {
        df -=   v_up * autocvar_g_vehicle_farman_speed_down;
    } else if ((player.BUTTON_JUMP && !altcontrols)
    || (player.BUTTON_JUMP && altcontrols && !player.movement_y && !player.movement_x))
    {
        df +=  v_up * autocvar_g_vehicle_farman_speed_up;
    }
    


    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	farman.avelocity_x = 0;
	farman.avelocity_y = 0;
	farman.avelocity_z = 0;
    }





    if (altcontrols) {
	player.v_angle_x = farman.angles_x * -1;
	player.v_angle_y = farman.angles_y;
	player.v_angle_z = farman.angles_z; //kiss
	
	player.angles_x = farman.angles_x;
	player.angles_y = farman.angles_y;
	player.angles_z = farman.angles_z; //for completion

	if ((clienttype(player) == CLIENTTYPE_REAL)) {
		msg_entity = player;
  		WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		WriteAngle( MSG_ONE, player.v_angle_x);
		WriteAngle( MSG_ONE, player.v_angle_y);
  		WriteAngle( MSG_ONE, player.v_angle_z);
	}
    }
    
    
    
    df = vehicles_waterspeed(player, df);
    farman.velocity = vehicles_waterfriction(player, farman, farman.velocity);
    farman.velocity  += df * frametime;
    player.velocity = player.movement  = farman.velocity;
    setorigin(player, farman.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(farman.dmg_time, vehicle_shield, autocvar_g_vehicle_farman_shield, autocvar_g_vehicle_farman_shield_regen_pause, autocvar_g_vehicle_farman_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(farman.dmg_time, vehicle_health, autocvar_g_vehicle_farman_health, autocvar_g_vehicle_farman_health_regen_pause, autocvar_g_vehicle_farman_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(farman.cnt, vehicle_energy, autocvar_g_vehicle_farman_energy, autocvar_g_vehicle_farman_energy_regen_pause, autocvar_g_vehicle_farman_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    

    VEHICLE_UPDATE_PLAYER(player, health, farman);
    VEHICLE_UPDATE_PLAYER(player, energy, farman);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, farman);


    if (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 4)) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(farman, farman, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

void farman_impact()
{
    if(autocvar_g_vehicle_farman_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_farman_bouncepain_x, autocvar_g_vehicle_farman_bouncepain_y, autocvar_g_vehicle_farman_bouncepain_z);
}

// If we dont do this ever now and then, the farmans rotors
// stop working, presumably due to angle overflow. cute.
void farman_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void farman_spawn(float _f)
{
    if(!self.gun1)
    {
        self.loddistance1 = 512;
	
    	self.lodmodel1 = "models/vehicles/farmanedits_lod1.iqm";
	self.lodmodel2 = "models/vehicles/farmanedits_lod2.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = farman_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"null");
        setmodel(self.bomb2,"null");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/farmanedits_body.iqm");

        //setattachment(self.bomb1, self, "bombmount_center");
        //setattachment(self.bomb2, self, "bombmount_right");
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
        spinner.avelocity = '0 -90 0';
	spinner.scale = 0.81;
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
        self.bomb1.think = farman_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_farman_mass;
	
	self.bomb1.gun1.count = 0;
    }


    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_farman_health;
    self.vehicle_shield = autocvar_g_vehicle_farman_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, FARMAN_MIN, FARMAN_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_farman_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_farman_bouncestop;    
    self.vehicle_impact = farman_impact;    
    self.damageforcescale = 0.25;
}

void spawnfunc_vehicle_farman()
{
    if(!autocvar_g_vehicle_farman)
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
   
    if(autocvar_g_vehicle_farman_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_farman_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_farman_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_farman_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    precache_model ("models/vehicles/farmanedits.iqm");
    precache_model ("models/vehicles/farmanedits_lod1.iqm");
    precache_model ("models/vehicles/farmanedits_lod2.iqm");
    precache_model ("models/vehicles/sopwith_spinner.iqm");
    precache_model ("models/sphere/sphexp2.iqm");
    precache_model ("models/sphere/sphexp3.iqm");
    precache_model ("models/vehicles/clusterbomb_folded.md3");
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
             "Farman",
             "models/vehicles/farmanedits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_RAPTOR,
             FARMAN_MIN, FARMAN_MAX,
             FALSE,
             farman_spawn, autocvar_g_vehicle_farman_respawntime,
             farman_frame,
             farman_enter, farman_exit,
             farman_die,   farman_think,
             FALSE, 
             autocvar_g_vehicle_farman_health,
             autocvar_g_vehicle_farman_shield, autocolor, 0, 0))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
