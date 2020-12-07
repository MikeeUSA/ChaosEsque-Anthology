#define SPARROW_MIN '-60 -60 0'
#define SPARROW_MAX '60 60 86'

const float SPARROWROTOR_HEIGHT = 100;

const vector SPARROWROTOR_MIN_HBF = '-50 -50 -10'; //Back and front trunk for this model
const vector SPARROWROTOR_MAX_HBF = '50 50 5';

const vector SPARROWROTOR_MIN_HBB = '-50 -50 -10'; //Middle
const vector SPARROWROTOR_MAX_HBB = '50 50 5';


const vector SPARROWROTOR_MIN_HBF_T = '-10 -10 -30'; //Back and front trunk for this model
const vector SPARROWROTOR_MAX_HBF_T = '10 10 30';

const vector SPARROWROTOR_MIN_HBB_T = '-10 -10 -50'; //Middle
const vector SPARROWROTOR_MAX_HBB_T = '10 10 50';

#ifdef SVQC
float autocvar_g_vehicle_sparrow;

float autocvar_g_vehicle_sparrow_mass;

float autocvar_g_vehicle_sparrow_respawntime;
float autocvar_g_vehicle_sparrow_takeofftime;

float autocvar_g_vehicle_sparrow_movestyle;
float autocvar_g_vehicle_sparrow_turnspeed;
float autocvar_g_vehicle_sparrow_pitchspeed;
float autocvar_g_vehicle_sparrow_pitchlimit;

float autocvar_g_vehicle_sparrow_speed_forward;
float autocvar_g_vehicle_sparrow_speed_strafe;
float autocvar_g_vehicle_sparrow_speed_up;
float autocvar_g_vehicle_sparrow_speed_down;
float autocvar_g_vehicle_sparrow_friction;

float autocvar_g_vehicle_sparrow_bombs_refire;

float autocvar_g_vehicle_sparrow_flare_range;

float autocvar_g_vehicle_sparrow_energy;
float autocvar_g_vehicle_sparrow_energy_regen;
float autocvar_g_vehicle_sparrow_energy_regen_pause;

float autocvar_g_vehicle_sparrow_health;
float autocvar_g_vehicle_sparrow_health_regen;
float autocvar_g_vehicle_sparrow_health_regen_pause;

float autocvar_g_vehicle_sparrow_shield;
float autocvar_g_vehicle_sparrow_shield_regen;
float autocvar_g_vehicle_sparrow_shield_regen_pause;

float autocvar_g_vehicle_sparrow_bouncefactor;
float autocvar_g_vehicle_sparrow_bouncestop;
vector autocvar_g_vehicle_sparrow_bouncepain;

void sparrow_spawn(float);
float sparrow_frame();
float sparrow_takeoff();

.entity bomb1;
.entity bomb2;

float sparrow_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}


//Bomblet Boom removed

//Bomblet Touch removed

//Bomb Burst removed

//Bomb Drop removed

//Fire Cannon removed


////////////////////////////////////////////////////////
////////For touching rotors (don't do it!)
void helicopter_rotor_donothing()
{
	//print("doing nothing\n");
}

void helicopter_rotor_die(entity hitbox)
{
    hitbox.event_damage       = func_null;
    hitbox.takedamage         = DAMAGE_NO;
    hitbox.touch              = func_null;
    hitbox.think              = helicopter_rotor_donothing;
    hitbox.deadflag           = DEAD_DEAD;
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid      = SOLID_NOT;
}

void helicopter_rotor_touch()
{
    //This is for helicopter rotor kill boxes. //This is mostly the same as above but whatever is set as self.subordinate
    if(self.owner)
    {
        if(other != world)
        if(vehicles_crushable(other))
        {
		if(other.resist_rotor != 1) {
            	if((self.bomb1.gun1.avelocity_y > 200) || (self.bomb1.gun1.avelocity_y < -200)) {
	    		float dmgalgo;
			if (self.bomb1.gun1.avelocity_y > 1)
				dmgalgo = 202 + bound(0, (autocvar_g_vehicles_crush_dmg * (self.bomb1.gun1.avelocity_y / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
			else if (self.bomb1.gun1.avelocity_y < -1)
				dmgalgo = 202 + bound(0, (autocvar_g_vehicles_crush_dmg * ((self.bomb1.gun1.avelocity_y * -1) / 2090)), autocvar_g_vehicles_crush_dmg*1.5);
				
			if (other.resist_rotor) {
				dmgalgo = dmgalgo - (dmgalgo * other.resist_rotor);
			}
			
                	Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_CRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
		}
		}

            return; // Dont do selfdamage when hitting "soft targets".
	}
	
        if(self.play_time < time)
        if(self.vehicle_impact)
            self.vehicle_impact();

        return;
    }

    if(other.classname != "player")
        return;

    if(other.deadflag != DEAD_NO)
        return;

    if(other.vehicle != world)
        return;

    return;
}


void helicopter_rotor_touch_hitbox()
{
	//print("rotor touched something\n");
	if (!other.rotor_is)
	if (other != self.owner) {
		//print("rotor touched not its owner and not another rotor, something else\n");
		self = self.owner;
		helicopter_rotor_touch(); //This way self.subordinate is tested for max_z rather than self
	}
}

void helicopter_rotor_impact_hitbox()
{
	//print("here2\n");
	self = self.owner;
	self.vehicle_impact();
}

void helicopter_rotor_think()
{
	//print (self.owner.model, " my mster\n");
	
	//Information on why it's not simply makevectors(self.angles);
	//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
	//	have inverted pitch
	//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
	//	if the entity is bsp or sprite, but not if it is a model
	//18:36 <@LordHavoc> inverting the pitch is necessary on models
	//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
	//	where they are correct pitch for models but not for bsp or 
	//	sprite :P
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 1');
	setorigin(self, (self.owner.origin + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void helicopter_rotor_think_noz()
{
	//For this version, No spin for z:
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (self.owner.origin + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void helicopter_rotor_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s)
{
    hitbox.owner              = vehic;
    
    hitbox.touch              = helicopter_rotor_touch_hitbox;
    hitbox.rotor_is = 1; //We are a rotor. Other rotors will ignore touching us. Brothers in arms.

    hitbox.bot_attack         = FALSE;
    hitbox.iscreature         = TRUE;
    hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid              = SOLID_TRIGGER;
    hitbox.deadflag           = DEAD_NO;
    hitbox.flags              = FL_NOTARGET;
    
    if (rotortype == 1)
    	hitbox.think              = helicopter_rotor_think_noz; //For plane props
    else
    	hitbox.think              = helicopter_rotor_think;
	
    hitbox.nextthink = time;
    hitbox.netname = hitbox.owner.netname;
    setsize(hitbox, min_s, max_s);
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    setorigin(hitbox, (vehic.origin + (v_forward * fwd_s) + (v_right * right_s) + (v_up * up_s))); //Forward X qunits, up_s
    hitbox.rotoroffset_x = fwd_s;
    hitbox.rotoroffset_y = right_s;
    hitbox.rotoroffset_z = up_s;
    
    hitbox.damageforcescale = 0.03;
    hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}

void aeroplane_prop_think_right()
{
	//For this version, No spin for z:
	local vector vorg;
    	vorg = gettaginfo(self.owner, gettagindex(self.owner, "engine_right"));
	
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (vorg + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}

void aeroplane_prop_think_left()
{
	//For this version, No spin for z:
	local vector vorg;
    	vorg = gettaginfo(self.owner, gettagindex(self.owner, "engine_left"));
	
	makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 0');
	setorigin(self, (vorg + (v_forward * self.rotoroffset_x) + (v_right * self.rotoroffset_y) + (v_up * self.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
}



void aeroplane_prop_spawn_hitbox(float rotortype, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s)
{
    hitbox.owner              = vehic;
    
    hitbox.touch              = helicopter_rotor_touch_hitbox;
    hitbox.rotor_is = 1; //We are a rotor. Other rotors will ignore touching us. Brothers in arms.

    hitbox.bot_attack         = FALSE;
    hitbox.iscreature         = TRUE;
    hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid              = SOLID_TRIGGER;
    hitbox.deadflag           = DEAD_NO;
    hitbox.flags              = FL_NOTARGET;
    
    local vector vorg;

    if (rotortype == 1) {
    	hitbox.think              = aeroplane_prop_think_left;
	vorg = gettaginfo(vehic, gettagindex(vehic, "engine_left"));
    } else {
    	hitbox.think              = aeroplane_prop_think_right;
	vorg = gettaginfo(vehic, gettagindex(vehic, "engine_right"));
    }
	
    hitbox.nextthink = time;
    hitbox.netname = hitbox.owner.netname;
    setsize(hitbox, min_s, max_s);
        
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    
    setorigin(hitbox, (vorg + (v_forward * fwd_s) + (v_right * right_s) + (v_up * up_s))); //Forward X qunits, up_s
    hitbox.rotoroffset_x = fwd_s;
    hitbox.rotoroffset_y = right_s;
    hitbox.rotoroffset_z = up_s;
    
    hitbox.damageforcescale = 0.03;
    hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}

////////End for touching rotors (bad idea for player)
////////////////////////////////////////////////////////

void helicopter_delugegun_add (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb11 = spawn();
		vehic.bomb11.colormap = vehic.colormap;
		setmodel(vehic.bomb11,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb11, vehic, mountspot);
		
		//LOD stuff.
		vehic.bomb11.owner = vehic;
		vehic.bomb11.lodowner = 1; //Use owner origin for computing LOD
		vehic.bomb11.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
		vehic.bomb11.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
		InitializeEntity(vehic.bomb11, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
		vehic.bomb11.angles_z = -90; //So ammo hose travels into fuselage
	}
}

void helicopter_delugegun_add2 (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb12 = spawn();
		vehic.bomb12.colormap = vehic.colormap;
		setmodel(vehic.bomb12,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb12, vehic, mountspot);
		
		//LOD stuff.
		vehic.bomb12.owner = vehic;
		vehic.bomb12.lodowner = 1; //Use owner origin for computing LOD
		vehic.bomb12.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
		vehic.bomb12.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
		InitializeEntity(vehic.bomb12, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
		vehic.bomb12.angles_z = 90; //So ammo hose travels into fuselage
	}
}

void helicopter_delugegun_add3 (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb13 = spawn();
		vehic.bomb13.colormap = vehic.colormap;
		setmodel(vehic.bomb13,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb13, vehic, mountspot);
		
		//LOD stuff.
		vehic.bomb13.owner = vehic;
		vehic.bomb13.lodowner = 1; //Use owner origin for computing LOD
		vehic.bomb13.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
		vehic.bomb13.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
		InitializeEntity(vehic.bomb13, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
		vehic.bomb13.angles_z = 90; //So ammo hose travels into fuselage
	}
}

void helicopter_delugegun_add4 (entity vehic, string mountspot) {
	if (vehic.spawnflags & 32) {
		//delugegun
		vehic.bomb14 = spawn();
		vehic.bomb14.colormap = vehic.colormap;
		setmodel(vehic.bomb14,"models/mountedguns/delugegun.iqm");
		setattachment(vehic.bomb14, vehic, mountspot);
		
		//LOD stuff.
		vehic.bomb14.owner = vehic;
		vehic.bomb14.lodowner = 1; //Use owner origin for computing LOD
		vehic.bomb14.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
		vehic.bomb14.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
		InitializeEntity(vehic.bomb14, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
		vehic.bomb14.angles_z = -90; //So ammo hose travels into fuselage
	}
}


void helicopter_delugegun(entity gun, entity pilot, entity gunmount)
{
   if (gun.spawnflags & 32) {
   	if(pilot.BUTTON_ATCK)
    	{
    		mg_deluge_fire(gun, pilot, gunmount);
    	} else {
    	    vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_deluge_machinegun_ammo_max,
    	                                       autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen_pause,
    	                                       autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    	}
   }
}


void sparrow_think()
{
}

void sparrow_enter()
{
    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = sparrow_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_sparrow_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_sparrow_shield) * 100;
    self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_sparrow_bombs_refire;
    self.lip   = time;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}

void sparrow_land()
{    
    float hgt;
        
    hgt = sparrow_altitude(512);    
    self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.95;

    if(hgt < 128)
    if(hgt > 0)
        self.frame = (hgt / 128) * 25;

    self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
    self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;

    if(hgt < 16)
    {
        self.movetype = MOVETYPE_TOSS;
        self.think    = sparrow_think;
        self.frame    = 0;
    }
    
    if (self.waterlevel != 0)
    if (self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) {
	self.movetype = MOVETYPE_NONE;
	self.think    = sparrow_think;
	self.frame    = 0;
	self.bomb1.gun1.avelocity_y = 90 + ((self.frame / 25) * 2000);
	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    }

    self.nextthink  = time;
}

void sparrow_exit(float eject)
{
    vector spot;
    self.tur_head.exteriormodeltoclient = world;

    if(self.deadflag == DEAD_NO)
    {
        self.think      = sparrow_land;
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

float sparrow_takeoff()
{
    entity player, sparrow;
    
    player = self;
    sparrow = self.vehicle;
    self   = sparrow;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (sparrow.bomb1.gun1.count == 0)) {
	    	sparrow.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        }
    }
    
    if(player.BUTTON_JUMP) {
    	if(sparrow.bomb1.gun1.count == 0) {
	    	sparrow.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        }
    }
    
    if(self.sound_nexttime < time)
    {        
        if (sparrow.bomb1.gun1.count) {
        self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
    }   

    // Takeoff sequense
    if(sparrow.bomb1.gun1.count == 1) {
    	    sparrow.movetype     = MOVETYPE_BOUNCEMISSILE;
    	if(sparrow.frame < 25)
    	{
    	makevectors(sparrow.angles);
	sparrow.frame += 25 / (autocvar_g_vehicle_sparrow_takeofftime / sys_frametime);
	//Sparrow has pontuns, won't be submerged for long. Thus no code for that
        sparrow.velocity_z = min(sparrow.velocity_z * 1.5, 256);
        self.bomb1.gun1.avelocity_y = 90 + ((sparrow.frame / 25) * 25000);
        self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;	
    	}
    	else
    	{
        player.PlayerPhysplug = sparrow_frame;
    	}
    } else {
    	//Engine off?
    	sparrow.movetype     = MOVETYPE_BOUNCE;
    	if (sparrow.frame > 0) {
        	sparrow.frame -= 25 / (autocvar_g_vehicle_sparrow_takeofftime / sys_frametime);
		self.bomb1.gun1.avelocity_y = 90 + ((sparrow.frame / 25) * 25000);
        	self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
	}
	if(sparrow.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Takeoff delugegun
    helicopter_delugegun(sparrow, player, sparrow.bomb11);
  
    
    if (
        ((!(sparrow.spawnflags & 32))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 5))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sparrow, sparrow, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    setorigin(player, sparrow.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(sparrow.dmg_time, vehicle_shield, autocvar_g_vehicle_sparrow_shield, autocvar_g_vehicle_sparrow_shield_regen_pause, autocvar_g_vehicle_sparrow_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(sparrow.dmg_time, vehicle_health, autocvar_g_vehicle_sparrow_health, autocvar_g_vehicle_sparrow_health_regen_pause, autocvar_g_vehicle_sparrow_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(sparrow.cnt, vehicle_energy, autocvar_g_vehicle_sparrow_energy, autocvar_g_vehicle_sparrow_energy_regen_pause, autocvar_g_vehicle_sparrow_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    sparrow.bomb1.alpha = sparrow.bomb2.alpha = (time - sparrow.lip) / (sparrow.delay - sparrow.lip);
    player.vehicle_reload2 = bound(0, sparrow.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, sparrow);
    VEHICLE_UPDATE_PLAYER(player, energy, sparrow);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, sparrow);

    if (
        ((!(sparrow.spawnflags & 32))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 5))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sparrow, sparrow, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

//Flare Stuff removed

float sparrow_frame()
{
    entity player, sparrow;
    float ftmp = 0;
    vector df;
    
	if(intermission_running)
		return 1;

    player = self;
    sparrow = self.vehicle;
    self   = sparrow;
    vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_sparrow_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_sparrow_speed_forward;
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
    
    if(sparrow.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }
    crosshair_trace2(player);

    vector vang;
    vang = sparrow.angles;
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

    ftmp = shortangle_f(player.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    sparrow.avelocity_y = bound(-autocvar_g_vehicle_sparrow_turnspeed, ftmp + sparrow.avelocity_y * 0.9, autocvar_g_vehicle_sparrow_turnspeed);

    // Pitch
    ftmp = 0;
    if not((player.BUTTON_HOOK) && (player.movement_x < 0)) {
    if(player.movement_x > 0 && vang_x < autocvar_g_vehicle_sparrow_pitchlimit) ftmp = 5;
    else if(player.movement_x < 0 && vang_x > -autocvar_g_vehicle_sparrow_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_sparrow_pitchlimit, df_x , autocvar_g_vehicle_sparrow_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_sparrow_pitchlimit, df_x + ftmp, autocvar_g_vehicle_sparrow_pitchlimit);
    sparrow.avelocity_x = bound(-autocvar_g_vehicle_sparrow_pitchspeed, ftmp + sparrow.avelocity_x * 0.9, autocvar_g_vehicle_sparrow_pitchspeed);

    sparrow.angles_x = anglemods(sparrow.angles_x);
    sparrow.angles_y = anglemods(sparrow.angles_y);
    sparrow.angles_z = anglemods(sparrow.angles_z);

    if(autocvar_g_vehicle_sparrow_movestyle == 1)
        makevectors('0 1 0' * sparrow.angles_y);
    else
        makevectors(player.v_angle);

    df = sparrow.velocity * -autocvar_g_vehicle_sparrow_friction;
    
    if(player.BUTTON_HOOK) {
    		if(player.movement_x < 0) {
			if(sparrow_altitude(512) < 16) {
				player.PlayerPhysplug = sparrow_takeoff;
				sparrow.bomb1.gun1.count = 0;
			}
		}	 
    } else {
    	if(player.movement_x != 0)
    	{
        	if(player.movement_x > 0)
        	    df += v_forward  * autocvar_g_vehicle_sparrow_speed_forward;
        	else if(player.movement_x < 0)
        	    df -= v_forward  * autocvar_g_vehicle_sparrow_speed_forward;
    	}
    }

    if(player.movement_y != 0)
    {
        if(player.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_sparrow_speed_strafe;
        else if(player.movement_y > 0)
            df += v_right * autocvar_g_vehicle_sparrow_speed_strafe;

        sparrow.angles_z = bound(-30,sparrow.angles_z + (player.movement_y / autocvar_g_vehicle_sparrow_speed_strafe),30);
    }
    else
    {
        sparrow.angles_z *= 0.95;
        if(sparrow.angles_z >= -1 && sparrow.angles_z <= -1)
            sparrow.angles_z = 0;
    }

    if(player.BUTTON_CROUCH)
        df -=   v_up * autocvar_g_vehicle_sparrow_speed_down;
    else if (player.BUTTON_JUMP)
        df +=  v_up * autocvar_g_vehicle_sparrow_speed_up;
    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If not in water
    /////////////////////////////////////////////////////////////////////////
	sparrow.avelocity_x = 0;
	sparrow.avelocity_y = 0;
	sparrow.avelocity_z = 0;
    }

    sparrow.velocity = vehicles_waterfriction(player, sparrow, sparrow.velocity);

    if (sparrow.waterlevel != 0)
    if (sparrow.watertype == CONTENT_WATER || sparrow.watertype == CONTENT_SLIME) {
    	df +=  v_up * autocvar_g_vehicle_sparrow_speed_up;
    }

    sparrow.velocity  += df * frametime;
    player.velocity = player.movement  = sparrow.velocity;
    setorigin(player, sparrow.origin + '0 0 32');
    
    //Cannon firing removed
    helicopter_delugegun(sparrow, player, sparrow.bomb11);

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(sparrow.dmg_time, vehicle_shield, autocvar_g_vehicle_sparrow_shield, autocvar_g_vehicle_sparrow_shield_regen_pause, autocvar_g_vehicle_sparrow_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(sparrow.dmg_time, vehicle_health, autocvar_g_vehicle_sparrow_health, autocvar_g_vehicle_sparrow_health_regen_pause, autocvar_g_vehicle_sparrow_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(sparrow.cnt, vehicle_energy, autocvar_g_vehicle_sparrow_energy, autocvar_g_vehicle_sparrow_energy_regen_pause, autocvar_g_vehicle_sparrow_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    //Bomb dropping removed
    
    sparrow.bomb1.alpha = sparrow.bomb2.alpha = (time - sparrow.lip) / (sparrow.delay - sparrow.lip);
    player.vehicle_reload2 = bound(0, sparrow.bomb1.alpha * 100, 100);

    if(self.bomb1.cnt < time)
    {
        entity _missile = findchainentity(enemy, sparrow);
        float _incomming = 0;
        while(_missile)
        {
            if(_missile.flags & FL_PROJECTILE)
            if(MISSILE_IS_TRACKING(_missile))
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_sparrow_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

    VEHICLE_UPDATE_PLAYER(player, health, sparrow);
    VEHICLE_UPDATE_PLAYER(player, energy, sparrow);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, sparrow);

    
    if (
        ((!(sparrow.spawnflags & 32))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 5))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sparrow, sparrow, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    self = player;
    return 1;
}

void sparrow_blowup()
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

void sparrow_diethink()
{
	if(time >= self.wait)
		self.think = sparrow_blowup;
    
    if(random() < 0.1)
    {
        sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
        pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
    }
    self.nextthink = time + 0.1;
}

void sparrow_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.think        = sparrow_diethink;
    self.nextthink    = time;
    self.wait 		  = time + 5 + (random() * 5);
    
    pointparticles(particleeffectnum("explosion_medium"), findbetterlocation (self.origin, 16), '0 0 0', 1);

    self.velocity_z += 600;

    self.avelocity = '0 0.5 1' * (random() * 400);
    self.avelocity -= '0 0.5 1' * (random() * 400);

    self.colormod = '-0.5 -0.5 -0.5';
	self.touch     = sparrow_blowup;
	
   	helicopter_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf); //Middle front
	helicopter_rotor_die(self.rotorboxmb); //Mid back
    	helicopter_rotor_die(self.rotorboxbk);
	
	helicopter_rotor_die(self.rotorboxftr); 
    	helicopter_rotor_die(self.rotorboxmfr); //Middle front
	helicopter_rotor_die(self.rotorboxmbr); //Mid back
    	helicopter_rotor_die(self.rotorboxbkr);
	
	helicopter_rotor_die(self.rotorboxftd1); 
    	helicopter_rotor_die(self.rotorboxmfd1); //Middle front
	helicopter_rotor_die(self.rotorboxmbd1); //Mid back
    	helicopter_rotor_die(self.rotorboxbkd1);
	
	helicopter_rotor_die(self.rotorboxftd2); 
    	helicopter_rotor_die(self.rotorboxmfd2); //Middle front
	helicopter_rotor_die(self.rotorboxmbd2); //Mid back
    	helicopter_rotor_die(self.rotorboxbkd2);
	
	helicopter_rotor_die(self.rotorboxft_t); //Using this, sets .think to something other than null, but not much :)
    	helicopter_rotor_die(self.rotorboxmf_t); //Middle front
	helicopter_rotor_die(self.rotorboxmid_t);
	helicopter_rotor_die(self.rotorboxmb_t); //Mid back
    	helicopter_rotor_die(self.rotorboxbk_t);
}

void sparrow_impact()
{
    if(autocvar_g_vehicle_sparrow_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_sparrow_bouncepain_x, autocvar_g_vehicle_sparrow_bouncepain_y, autocvar_g_vehicle_sparrow_bouncepain_z);
}

// If we dont do this ever now and then, the sparrows rotors
// stop working, presumably due to angle overflow. cute.
void sparrow_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

// Removed impulse stuff

void sparrow_spawn(float _f)
{
    if(!self.gun1)
    {
    	self.lodmodel1 = "models/vehicles/sparrowedits_lod1.iqm";
	self.loddistance1 = 512; //Lod0 Model Somewhat complex
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
        entity spinner;
        vector ofs;

        //FIXME: Camera is in a bad place in HUD model.
        //setorigin(self.vehicle_viewport, '0 0 25');
        
        //self.vehicles_impusle   = sparrow_impulse;
        
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"null");
        setmodel(self.bomb2,"null");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/sparrowedits_body.iqm");

        setattachment(self.bomb1, self, "bombmount_left");
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
        setmodel(spinner,"models/vehicles/sparrow_spinner.iqm");
        setattachment(spinner, self, "engine_left");
		//LOD stuff.
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/sparrow_spinner_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	//spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/sparrow_smallspinner.iqm");
        setattachment(spinner, self, "engine_right");
		//LOD stuff.
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/sparrow_smallspinner_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = sparrow_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_sparrow_mass;
	
	helicopter_delugegun_add(self, "bombmount_left");
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.rotorboxftr = spawn();
	self.rotorboxmfr = spawn();
	self.rotorboxmbr = spawn();
    	self.rotorboxbkr = spawn();
	
	self.rotorboxftd1 = spawn();
	self.rotorboxmfd1 = spawn();
	self.rotorboxmbd1 = spawn();
    	self.rotorboxbkd1 = spawn();
	
	self.rotorboxftd2 = spawn();
	self.rotorboxmfd2 = spawn();
	self.rotorboxmbd2 = spawn();
    	self.rotorboxbkd2 = spawn();
	
	self.rotorboxft_t = spawn();
	self.rotorboxmf_t = spawn();
	self.rotorboxmid_t = spawn();
	self.rotorboxmb_t = spawn();
    	self.rotorboxbk_t = spawn();
    }


    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_sparrow_health;
    self.vehicle_shield = autocvar_g_vehicle_sparrow_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, SPARROW_MIN, SPARROW_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_sparrow_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_sparrow_bouncestop;    
    self.vehicle_impact = sparrow_impact;    
    self.damageforcescale = 0.25;
    
    self.bomb1.gun1.colormap = 1023;
    self.bomb1.gun2.colormap = 1023;
    
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly
    
    //Spinning rotor death areas
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, 170, 0, SPARROWROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, 100, 0, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, -100, 0, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, -170, 0, SPARROWROTOR_HEIGHT);
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftr, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, 0, 170, SPARROWROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfr, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, 0, 100, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbr, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, 0, -100, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkr, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, 0, -170, SPARROWROTOR_HEIGHT);	
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd1, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, 110, 110, SPARROWROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd1, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, 70, 70, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd1, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, -70, -70, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd1, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, -110, -110, SPARROWROTOR_HEIGHT);
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd2, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, -110, 110, SPARROWROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd2, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, -70, 70, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd2, SPARROWROTOR_MIN_HBB, SPARROWROTOR_MAX_HBB, 70, -70, SPARROWROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd2, SPARROWROTOR_MIN_HBF, SPARROWROTOR_MAX_HBF, 110, -110, SPARROWROTOR_HEIGHT);

    local vector vorg;
    vorg = gettaginfo(self, gettagindex(self, "engine_right"));
    vorg -= self.origin;
    vorg_y = vorg_y -15; //Move it to one side. Where the rotor is.
    //Tail rotor
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft_t, SPARROWROTOR_MIN_HBF_T, SPARROWROTOR_MAX_HBF_T, vorg_x+45, vorg_y, vorg_z);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf_t, SPARROWROTOR_MIN_HBB_T, SPARROWROTOR_MAX_HBB_T, vorg_x+23, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmid_t, SPARROWROTOR_MIN_HBB_T, SPARROWROTOR_MAX_HBB_T, vorg_x, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb_t, SPARROWROTOR_MIN_HBB_T, SPARROWROTOR_MAX_HBB_T, vorg_x-23, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk_t, SPARROWROTOR_MIN_HBF_T, SPARROWROTOR_MAX_HBF_T, vorg_x-45, vorg_y, vorg_z);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_sparrow()
{
    if(!autocvar_g_vehicle_sparrow)
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
   
    if(autocvar_g_vehicle_sparrow_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_sparrow_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_sparrow_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

    if(autocvar_g_vehicle_sparrow_energy_regen)
        self.vehicle_flags |= VHF_ENERGYREGEN;

    if (self.spawnflags & 32) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		precache_sound ( "machines/steam_fade.ogg" );
    }
	
    precache_model ("models/vehicles/sparrowedits.iqm");
    precache_model ("models/vehicles/sparrowedits_lod1.iqm");

    precache_model ("models/vehicles/sparrow_smallspinner.iqm");
    precache_model ("models/vehicles/sparrow_smallspinner_lod1.iqm");

    precache_model ("models/vehicles/sparrow_spinner.iqm");
    precache_model ("models/vehicles/sparrow_spinner_lod1.iqm");
    
    precache_model ("models/vhshield.md3");
    
    precache_sound ("vehicles/raptor_fly.wav");
    precache_sound ("vehicles/raptor_speed.wav");
    precache_sound ("vehicles/missile_alarm.wav");
    
    	float autocolor;
	autocolor = 1126; //1126, a cyan
	if (self.colormap >= 1023)
		autocolor = self.colormap;
    
    if not (vehicle_initialize(
             "Sparrow",
             "models/vehicles/sparrowedits.iqm",
             "null",
             "null",
             "", "", "tag_camera",
             HUD_RAPTOR,
             SPARROW_MIN, SPARROW_MAX,
             FALSE,
             sparrow_spawn, autocvar_g_vehicle_sparrow_respawntime,
             sparrow_frame,
             sparrow_enter, sparrow_exit,
             sparrow_die,   sparrow_think,
             FALSE, 
             autocvar_g_vehicle_sparrow_health,
             autocvar_g_vehicle_sparrow_shield, autocolor, 0, 0))
    {
        remove(self);
        return;
    }
    
    
}
#endif // SVQC
