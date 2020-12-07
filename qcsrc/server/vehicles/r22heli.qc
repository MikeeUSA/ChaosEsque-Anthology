#define R22HELI_MIN '-60 -60 0'
#define R22HELI_MAX '60 60 86'

const float R22HELIROTOR_HEIGHT = 148;

const vector R22HELIROTOR_MIN_HBF = '-50 -50 -1'; //Back and front trunk for this model
const vector R22HELIROTOR_MAX_HBF = '50 50 1';

const vector R22HELIROTOR_MIN_HBB = '-50 -50 -1'; //Middle
const vector R22HELIROTOR_MAX_HBB = '50 50 1';


const vector R22HELIROTOR_MIN_HBF_T = '-5 -5 -15'; //Back and front trunk for this model
const vector R22HELIROTOR_MAX_HBF_T = '5 5 15';

const vector R22HELIROTOR_MIN_HBB_T = '-5 -5 -30'; //Middle
const vector R22HELIROTOR_MAX_HBB_T = '5 5 30';

#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P

//Sparrow
float autocvar_g_vehicle_r22heli_mass;

float autocvar_g_vehicle_r22heli_respawntime;
float autocvar_g_vehicle_r22heli_takeofftime;

float autocvar_g_vehicle_r22heli_movestyle;
float autocvar_g_vehicle_r22heli_turnspeed;
float autocvar_g_vehicle_r22heli_pitchspeed;
float autocvar_g_vehicle_r22heli_pitchlimit;

float autocvar_g_vehicle_r22heli_friction;

float autocvar_g_vehicle_r22heli_bombs_refire;

float autocvar_g_vehicle_r22heli_flare_range;

float autocvar_g_vehicle_r22heli_bouncefactor;
float autocvar_g_vehicle_r22heli_bouncestop;
vector autocvar_g_vehicle_r22heli_bouncepain;


// Auto cvars Fastcar
float autocvar_g_vehicle_r22heli_mass;
float autocvar_g_vehicle_r22heli_speed_forward;
float autocvar_g_vehicle_r22heli_speed_strafe;
float autocvar_g_vehicle_r22heli_speed_up;
float autocvar_g_vehicle_r22heli_speed_down;
float autocvar_g_vehicle_r22heli_pitchlimit;

float autocvar_g_vehicle_r22heli_friction;

float autocvar_g_vehicle_r22heli_turnspeed;
float autocvar_g_vehicle_r22heli_pitchspeed;

float autocvar_g_vehicle_r22heli_energy;
float autocvar_g_vehicle_r22heli_energy_regen;
float autocvar_g_vehicle_r22heli_energy_regen_pause;

float autocvar_g_vehicle_r22heli_health;
float autocvar_g_vehicle_r22heli_health_regen;
float autocvar_g_vehicle_r22heli_health_regen_pause;

float autocvar_g_vehicle_r22heli_shield;
float autocvar_g_vehicle_r22heli_shield_regen;
float autocvar_g_vehicle_r22heli_shield_regen_pause;

float autocvar_g_vehicle_r22heli_cannon_speed;

float autocvar_g_vehicle_r22heli_cannon_ammo;
float autocvar_g_vehicle_r22heli_cannon_ammo_regen;
float autocvar_g_vehicle_r22heli_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_r22heli_cannon_lock = 0;

float autocvar_g_vehicle_r22heli_cannon_turnspeed;
float autocvar_g_vehicle_r22heli_cannon_pitchlimit_down;
float autocvar_g_vehicle_r22heli_cannon_pitchlimit_up;
float autocvar_g_vehicle_r22heli_cannon_turnlimit_in;
float autocvar_g_vehicle_r22heli_cannon_turnlimit_out;

float autocvar_g_vehicle_r22heli_respawntime;

float autocvar_g_vehicle_r22heli_blowup_radius;
float autocvar_g_vehicle_r22heli_blowup_coredamage;
float autocvar_g_vehicle_r22heli_blowup_edgedamage;
float autocvar_g_vehicle_r22heli_blowup_forceintensity;

float autocvar_g_vehicle_r22heli_bouncefactor;
float autocvar_g_vehicle_r22heli_bouncestop;
vector autocvar_g_vehicle_r22heli_bouncepain;

var float autocvar_g_vehicle_r22heli = 0;
var vector r22heli_force_from_tag(string tag_name, float spring_length, float max_power);

float r22heli_takeoff();
float r22heli_pilot_frame();
void r22heli_think();
void r22heli_minigun(entity gun, entity pilot, entity gunmount, entity mggun1);
void r22heli_hmg(entity gun, entity pilot, entity gunmount);

float r22heli_altitude(float amax)
{
	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
    return vlen(self.origin - trace_endpos);
}

void r22heli_pilot_enter()
{
    //print(sprintf("waterlevel: %f vehic to player %f\n", self.waterlevel, self.owner.waterlevel));

    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = r22heli_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_r22heli_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_r22heli_shield) * 100;
    self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_r22heli_bombs_refire;
    self.lip   = time;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}


void r22heli_land()
{    
    float hgt;
        
    hgt = r22heli_altitude(512);    
    self.velocity = (self.velocity * 0.9) + ('0 0 -1800' * (hgt / 256) * sys_frametime);
    self.angles_x *= 0.95;
    self.angles_z *= 0.95;

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
        self.movetype = MOVETYPE_TOSS;
        self.think    = r22heli_think;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

float r22heli_takeoff()
{
    entity player, r22heli;
    
    player = self;
    r22heli = self.vehicle;
    self   = r22heli;
    
    if(player.BUTTON_HOOK) {
	if((player.movement_x > 0) && (r22heli.bomb1.gun1.count == 0)) {
	    	r22heli.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        }
    }
    
    if(player.BUTTON_JUMP) {
    	if(r22heli.bomb1.gun1.count == 0) {
	    	r22heli.bomb1.gun1.count = 1;
		sprint(player, "Engine set to Maximum\n");
        }
    }
    
    if(self.sound_nexttime < time)
    {
        if (r22heli.bomb1.gun1.count) {
	if not(player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
        	self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
        	sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
	}
    }   

    // Takeoff sequense
    if(r22heli.bomb1.gun1.count == 1) {
    	    r22heli.movetype     = MOVETYPE_BOUNCEMISSILE;
    	if(r22heli.frame < 25)
    	{
		r22heli.frame += 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);    
		if not(player.waterlevel == WATERLEVEL_SUBMERGED)
   		{
			r22heli.velocity_z = min(r22heli.velocity_z * 1.5, 256);
        		self.bomb1.gun1.avelocity_y = 90 + ((r22heli.frame / 25) * 25000);
        		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
		}	
    	}
    	else
    	{
        	player.PlayerPhysplug = r22heli_pilot_frame;
    	}
    } else {
    	//Engine off?
    	r22heli.movetype     = MOVETYPE_BOUNCE;
    	if (r22heli.frame > 0) {
        	r22heli.frame -= 25 / (autocvar_g_vehicle_r22heli_takeofftime / sys_frametime);
		if not(player.waterlevel == WATERLEVEL_SUBMERGED)
   		{
			self.bomb1.gun1.avelocity_y = 90 + ((r22heli.frame / 25) * 25000);
        		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
		}
	}
	if(r22heli.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Cannon firing
    helicopter_delugegun(r22heli, player, r22heli.bomb11);
     
    if (r22heli.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	r22heli_minigun(r22heli, player, r22heli.bomb3, r22heli.bomb3.gun1);
	r22heli_minigun(r22heli, player, r22heli.bomb4, r22heli.bomb4.gun1);
		if(player.BUTTON_HOOK) {
			player.BUTTON_JUMP   = 0;
    			player.BUTTON_CROUCH    = 0;
    			//player.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
	
	if (r22heli.spawnflags & 128) {
	r22heli_hmg(r22heli, player, r22heli.bomb5);
	r22heli_hmg(r22heli, player, r22heli.bomb6);
	}
    }
    
    if (r22heli.vehicle_ammo1_max) {
    	player.vehicle_ammo1_current = r22heli.vehicle_ammo1_current;
    	player.vehicle_ammo1_max = r22heli.vehicle_ammo1_max;
    }
    
    if (r22heli.vehicle_ammo2_max) {
    	player.vehicle_ammo2_current = r22heli.vehicle_ammo2_current;
    	player.vehicle_ammo2_max = r22heli.vehicle_ammo2_max;
    }
    ///End takeoff weapons stuff
    
    
    if (
    ((!((r22heli.spawnflags & 32)
	|| (r22heli.spawnflags & 64)
	|| (r22heli.spawnflags & 128)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(r22heli, r22heli, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    setorigin(player, r22heli.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(r22heli.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(r22heli.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(r22heli.cnt, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    r22heli.bomb1.alpha = r22heli.bomb2.alpha = (time - r22heli.lip) / (r22heli.delay - r22heli.lip);
    player.vehicle_reload2 = bound(0, r22heli.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, r22heli);
    VEHICLE_UPDATE_PLAYER(player, energy, r22heli);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, r22heli);


    if (
    ((!((r22heli.spawnflags & 32)
	|| (r22heli.spawnflags & 64)
	|| (r22heli.spawnflags & 128)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(r22heli, r22heli, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    if (r22heli.vehicle_ammo1_max) {
    	player.vehicle_ammo1_current = r22heli.vehicle_ammo1_current;
    	player.vehicle_ammo1_max = r22heli.vehicle_ammo1_max;
    }
    
    if (r22heli.vehicle_ammo2_max) {
    	player.vehicle_ammo2_current = r22heli.vehicle_ammo2_current;
    	player.vehicle_ammo2_max = r22heli.vehicle_ammo2_max;
    }
    
    self = player;
    return 1;
}

float r22heli_gunner_frame()
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
  if not (autocvar_g_vehicles_noauxaimforpassengervehic) {	
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	if((gun == vehic.gun1))
	{
		_in = autocvar_g_vehicle_r22heli_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_r22heli_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_r22heli_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_r22heli_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;

	if(autocvar_g_vehicle_r22heli_cannon_lock)
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
			impact_time = distance / autocvar_g_vehicle_r22heli_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_r22heli_cannon_pitchlimit_down * -1, autocvar_g_vehicle_r22heli_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_r22heli_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_r22heli_cannon_pitchlimit_down * -1, autocvar_g_vehicle_r22heli_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_r22heli_cannon_turnspeed);

	
	
  }


	VEHICLE_UPDATE_PLAYER(gunner, health, r22heli);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, r22heli);


  if not (autocvar_g_vehicles_noauxaimforpassengervehic) {
	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));
	
  }


	vehic.solid = SOLID_BBOX;
	if (vehicles_allowdriveby(0, gunner, autocvar_g_vehicles_allowdriveby_pssngr_hudnorm, 3)) {
		//That 3 is a magic number that means "we are a heli"
		//Do nothing
		gunner.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, gun, gunner);
		gunner.BUTTON_CROUCH = 0;
	} else {
		gunner.vehicle_allowdriveby = 0;
		gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	}
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_r22heli_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void r22heli_gunner_exit(float _exitflag)
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
	else
		dprint("^1self != gunner1, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 132 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float r22heli_gunner_enter(float selectgun)
{
	RemoveGrapplingHook(other);
	entity _gun, _gunner;
	if(!self.gunner1 && (!selectgun || selectgun == 1))
	{
		_gun = self.gun1;
		_gunner = self.gunner1;
		self.gunner1 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = r22heli_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= r22heli_gunner_enter;
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
	other.PlayerPhysplug    = r22heli_gunner_frame;
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

float r22helivehicles_valid_pilot()
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

void r22heli_touch()
{

	if((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world))
	{
		vehicles_touch();
		return;
	}

	if(r22helivehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(r22heli_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void r22heli_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_r22heli_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_r22heli_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_r22heli_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

void r22heli_minigun(entity gun, entity pilot, entity gunmount, entity mggun1)
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

void r22heli_hmg(entity gun, entity pilot, entity gunmount)
{
   
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

float r22heli_pilot_frame()
{
    entity pilot, vehic;
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
    if(ftmp > autocvar_g_vehicle_r22heli_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_r22heli_speed_forward;
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

    ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    vehic.avelocity_y = bound(-autocvar_g_vehicle_r22heli_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_r22heli_turnspeed);

    // Pitch
    ftmp = 0;
    if not((pilot.BUTTON_HOOK) && (pilot.movement_x < 0)) {
    if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_r22heli_pitchlimit) ftmp = 5;
    else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_r22heli_pitchlimit) ftmp = -20;
    }

    df_x = bound(-autocvar_g_vehicle_r22heli_pitchlimit, df_x , autocvar_g_vehicle_r22heli_pitchlimit);
    ftmp = vang_x - bound(-autocvar_g_vehicle_r22heli_pitchlimit, df_x + ftmp, autocvar_g_vehicle_r22heli_pitchlimit);
    vehic.avelocity_x = bound(-autocvar_g_vehicle_r22heli_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_r22heli_pitchspeed);

    vehic.angles_x = anglemods(vehic.angles_x);
    vehic.angles_y = anglemods(vehic.angles_y);
    vehic.angles_z = anglemods(vehic.angles_z);

    if(autocvar_g_vehicle_r22heli_movestyle == 1)
        makevectors('0 1 0' * vehic.angles_y);
    else
        makevectors(pilot.v_angle);

    df = vehic.velocity * -autocvar_g_vehicle_r22heli_friction;
    
    if(pilot.BUTTON_HOOK) {
    		if(pilot.movement_x < 0) {
   			if(r22heli_altitude(512) < 16) 
			{
				pilot.PlayerPhysplug = r22heli_takeoff;
				vehic.bomb1.gun1.count = 0;
			}
		}	 
    } else {

    if(pilot.movement_x != 0)
    {
        if(pilot.movement_x > 0)
            df += v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
        else if(pilot.movement_x < 0)
            df -= v_forward  * autocvar_g_vehicle_r22heli_speed_forward;
    }
    }

    if(pilot.movement_y != 0)
    {
        if(pilot.movement_y < 0)
            df -= v_right * autocvar_g_vehicle_r22heli_speed_strafe;
        else if(pilot.movement_y > 0)
            df += v_right * autocvar_g_vehicle_r22heli_speed_strafe;

        vehic.angles_z = bound(-30,vehic.angles_z + (pilot.movement_y / autocvar_g_vehicle_r22heli_speed_strafe),30);
    }
    else
    {
        vehic.angles_z *= 0.95;
        if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
            vehic.angles_z = 0;
    }
    
    //Cannon firing
    helicopter_delugegun(vehic, pilot, vehic.bomb11);
     
    if (vehic.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	r22heli_minigun(vehic, pilot, vehic.bomb3, vehic.bomb3.gun1);
	r22heli_minigun(vehic, pilot, vehic.bomb4, vehic.bomb4.gun1);
		if(pilot.BUTTON_HOOK) {
			pilot.BUTTON_JUMP   = 0;
    			pilot.BUTTON_CROUCH    = 0;
    			//pilot.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
	
	if (vehic.spawnflags & 128) {
	r22heli_hmg(vehic, pilot, vehic.bomb5);
	r22heli_hmg(vehic, pilot, vehic.bomb6);
	}
    }

    if(pilot.BUTTON_CROUCH)
        df -=   v_up * autocvar_g_vehicle_r22heli_speed_down;
    else if (pilot.BUTTON_JUMP)
        df +=  v_up * autocvar_g_vehicle_r22heli_speed_up;
	
    
    vehic.velocity  += df * frametime;
    vehic.movetype       = MOVETYPE_BOUNCEMISSILE;
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
	vehic.bomb1.gun1.avelocity_y = vehic.bomb1.gun1.avelocity_y * 0.95;
    	vehic.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
    }
    
    pilot.velocity = pilot.movement  = vehic.velocity;
    setorigin(pilot, vehic.origin + '0 0 32');

    // Target lock & predict
    
    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_r22heli_shield, autocvar_g_vehicle_r22heli_shield_regen_pause, autocvar_g_vehicle_r22heli_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_health_regen_pause, autocvar_g_vehicle_r22heli_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_r22heli_energy, autocvar_g_vehicle_r22heli_energy_regen_pause, autocvar_g_vehicle_r22heli_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

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
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_r22heli_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

//Weapons removed
   

    local entity r22heli = vehic;

    VEHICLE_UPDATE_PLAYER(pilot, health, r22heli);
    VEHICLE_UPDATE_PLAYER(pilot, energy, r22heli);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, r22heli);


    if (
    ((!((r22heli.spawnflags & 32)
	|| (r22heli.spawnflags & 64)
	|| (r22heli.spawnflags & 128)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, pilot, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 3))
    ) {
		//Do nothing//
		pilot.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(r22heli, r22heli, pilot);
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

void r22heli_think()
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
		
	}
	
}

void r22heli_enter()
{
	self.touch = r22heli_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCE;
	r22heli_pilot_enter();
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void r22heli_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = r22heli_think;
	self.nextthink = time;
	
	if(!self.owner)
		return;
	
	//Add from sparrow	
	if(self.deadflag == DEAD_NO)
	{
        	self.think      = r22heli_land;
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

void r22heli_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_r22heli_blowup_coredamage,
				 autocvar_g_vehicle_r22heli_blowup_edgedamage,
				 autocvar_g_vehicle_r22heli_blowup_radius, self,
				 autocvar_g_vehicle_r22heli_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void r22heli_diethink()
{
	if(time >= self.wait)
		self.think = r22heli_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void r22heli_die()
{
	entity oldself = self;
	
	if(self.gunner1)
	{
		self = self.gunner1;
		oldself.gun1.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}

	self.vehicle_exit(VHEF_EJECT);
	
	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = r22heli_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 1;
	_body.think = r22heli_diethink;
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

void r22heli_impact()
{
    if(autocvar_g_vehicle_r22heli_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_r22heli_bouncepain_x, 
						autocvar_g_vehicle_r22heli_bouncepain_y, 
						autocvar_g_vehicle_r22heli_bouncepain_z);
}

// If we dont do this ever now and then, the r22helis rotors
// stop working, presumably due to angle overflow. cute.
void r22heli_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y);
    self.gun2.angles_y = anglemods(self.gun2.angles_y);
    self.nextthink = time + 15;
}

void r22heli_spawn(float _f)
{
   self.vehicle_pilotchangeseat = r22heli_gunner_enter; //Function to exec if pilot wants to change seat

	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
	    if(!self.gun1)
    {
    	self.loddistance1 = 512; //Lod0 Model quite complex, so only use when very close
    
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

        if (self.spawnflags >= 64) {
		self.lodmodel1 = "models/vehicles/r22edits_milspec_lod1.iqm";
		self.lodmodel2 = "models/vehicles/r22edits_milspec_lod2.iqm";
	} else {
		self.lodmodel1 = "models/vehicles/r22edits_lod1.iqm";
		self.lodmodel2 = "models/vehicles/r22edits_lod2.iqm";
	}
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
     
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();

        setmodel(self.bomb1,"null");
        setmodel(self.bomb2,"null");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
        //setmodel(self.tur_head, "models/vehicles/r22heliedits_body.iqm");

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
        setmodel(spinner,"models/vehicles/r22edits_spinner.iqm");
        setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	//spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/r22edits_smallspinner.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
        self.bomb1.gun2 = spinner;

        // Sigh.
        self.bomb1.think = r22heli_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_r22heli_mass;
	
	self.vehicle_flags |= VHF_MULTISLOT;

	self.gun1.owner = self;
		
	setattachment(self.gun1, self, "tag_pass1");
	
	vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "null", r22heli_gunner_frame, r22heli_gunner_exit);
	
	helicopter_delugegun_add(self, "forwardmount_left");
	
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
	
	if (self.spawnflags & 64) {
	//Minigun Left Stuff
	self.bomb3 = spawn();
	setmodel(self.bomb3,"models/mountedguns/m134gun.iqm");
	setattachment(self.bomb3, self, "gunmount_left");
		//LOD stuff.
		self.bomb3.owner = self;
		self.bomb3.lodowner = 1; //Use owner origin for computing LOD
		self.bomb3.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
		self.bomb3.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
		InitializeEntity(self.bomb3, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
	//Minugun Left Barrels
	self.bomb3.gun1 = spawn();
	setmodel(self.bomb3.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb3.gun1, self.bomb3, "tag_axis");
	self.bomb3.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb3.angles_z = -110; //So ammo chain travels into fuselage
	
	//Minigun Right Stuff
	self.bomb4 = spawn();
	setmodel(self.bomb4,"models/mountedguns/m134gun.iqm");
	setattachment(self.bomb4, self, "gunmount_right");
		//LOD stuff.
		self.bomb4.owner = self;
		self.bomb4.lodowner = 1; //Use owner origin for computing LOD
		self.bomb4.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
		self.bomb4.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
		InitializeEntity(self.bomb4, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
	
	//Minugun Right Barrels
	self.bomb4.gun1 = spawn();
	setmodel(self.bomb4.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.bomb4.gun1, self.bomb4, "tag_axis");
	self.bomb4.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
	
	self.bomb4.angles_z = 120; //So ammo chain travels into fuselage
	}
	
	if (self.spawnflags & 128) {
	//.50 Left Stuff
	self.bomb5 = spawn();
	setmodel(self.bomb5,"models/mountedguns/browning50gun.iqm");
	setattachment(self.bomb5, self, "forwardmount_left");
		//LOD stuff.
		self.bomb5.owner = self;
		self.bomb5.lodowner = 1; //Use owner origin for computing LOD
		self.bomb5.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
		self.bomb5.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
		InitializeEntity(self.bomb5, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		
	self.bomb5.angles_z = -90; //So ammo chain travels into fuselage
	
	//.50 Right Stuff
	self.bomb6 = spawn();
	setmodel(self.bomb6,"models/mountedguns/browning50gun.iqm");
	setattachment(self.bomb6, self, "forwardmount_right");
		//LOD stuff.
		self.bomb6.owner = self;
		self.bomb6.lodowner = 1; //Use owner origin for computing LOD
		self.bomb6.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
		self.bomb6.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
		InitializeEntity(self.bomb6, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
	
	self.bomb6.angles_z = 90; //So ammo chain travels into fuselage
	}
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame          = 0;
    self.vehicle_health = autocvar_g_vehicle_r22heli_health;
    self.vehicle_shield = autocvar_g_vehicle_r22heli_shield;
    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, R22HELI_MIN, R22HELI_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_r22heli_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_r22heli_bouncestop;    
    self.vehicle_impact = r22heli_impact;    
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
	
    float oldy;
    oldy = self.angles_y;
    self.angles_y = 0; //So we can do the init math correctly	

    //Spinning rotor death areas
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 150, 0, R22HELIROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 100, 0, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -100, 0, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -150, 0, R22HELIROTOR_HEIGHT);
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftr, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 0, 150, R22HELIROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfr, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 0, 100, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbr, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 0, -100, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkr, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 0, -150, R22HELIROTOR_HEIGHT);	
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd1, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 90, 90, R22HELIROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd1, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 50, 50, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd1, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -50, -50, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd1, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -90, -90, R22HELIROTOR_HEIGHT);
    
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxftd2, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, -90, 90, R22HELIROTOR_HEIGHT);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmfd2, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, -50, 50, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmbd2, R22HELIROTOR_MIN_HBB, R22HELIROTOR_MAX_HBB, 50, -50, R22HELIROTOR_HEIGHT);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbkd2, R22HELIROTOR_MIN_HBF, R22HELIROTOR_MAX_HBF, 90, -90, R22HELIROTOR_HEIGHT);

    local vector vorg;
    vorg = gettaginfo(self, gettagindex(self, "engine_right"));
    vorg -= self.origin;
    vorg_y = vorg_y -15; //Move it to one side. Where the rotor is.
    //Tail rotor
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxft_t, R22HELIROTOR_MIN_HBF_T, R22HELIROTOR_MAX_HBF_T, vorg_x+20, vorg_y, vorg_z);
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmf_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x+8, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmid_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxmb_t, R22HELIROTOR_MIN_HBB_T, R22HELIROTOR_MAX_HBB_T, vorg_x-8, vorg_y, vorg_z);	
    helicopter_rotor_spawn_hitbox(0, self, self.rotorboxbk_t, R22HELIROTOR_MIN_HBF_T, R22HELIROTOR_MAX_HBF_T, vorg_x-20, vorg_y, vorg_z);

    self.angles_y = oldy; //Done doing the init math, reset.
}

void spawnfunc_vehicle_r22heli()
{
	if(!autocvar_g_vehicle_r22heli)
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
	
	precache_model ("models/vehicles/r22edits_smallspinner.iqm");
	precache_model ("models/vehicles/r22edits_spinner.iqm");
	
	float caammomax;
	string bodymodel;
	
	if (self.spawnflags & 32) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		precache_sound ( "machines/steam_fade.ogg" );
	}
	
	if (self.spawnflags >= 64) {
		precache_model("models/vehicles/r22edits_milspec.iqm");
		precache_model("models/vehicles/r22edits_milspec_lod1.iqm");
		precache_model("models/vehicles/r22edits_milspec_lod2.iqm");
		bodymodel = "models/vehicles/r22edits_milspec.iqm";
		
		if (self.spawnflags & 64) {
			precache_model ( "models/mountedguns/m134gun.iqm");
			precache_model ( "models/mountedguns/m134gun_lod1.iqm");
			precache_model ( "models/mountedguns/m134gun_lod2.iqm");
			precache_model ( "models/mountedguns/m134gun_barrels.iqm");
			precache_sound ( "weapons/uzi_fire.wav" );
		}
		
		if (self.spawnflags & 128) {
			precache_model ( "models/mountedguns/browning50gun.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod1.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod2.iqm");
			precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		}
		
		precache_model ( "models/uziflash.md3");
		
		caammomax = autocvar_g_vehicle_mg_m134_machinegun_ammo_max * 2;
	} else {
		precache_model("models/vehicles/r22edits.iqm");
		precache_model("models/vehicles/r22edits_lod1.iqm");
		precache_model("models/vehicles/r22edits_lod2.iqm");
		bodymodel = "models/vehicles/r22edits.iqm";
		caammomax = 0;
	}
	
	precache_sound ("vehicles/raptor_fly.wav");
	precache_sound ("vehicles/raptor_speed.wav");
	precache_sound ("vehicles/missile_alarm.wav");
	precache_sound ( "weapons/rocket_impact.wav");

	if(autocvar_g_vehicle_r22heli_energy)
		if(autocvar_g_vehicle_r22heli_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_r22heli_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_r22heli_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_r22heli_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	
	if (self.team) {
		autocolor = 0;
	} else {
		autocolor = 1211;
	}
	
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "R22Heli",
			   bodymodel,
			   "null", // we need this so tur_head is networked and usable for sounds
			   "null", 
			   "", "", "tag_viewport",
			   HUD_RAPTOR, 
           		   R22HELI_MIN, R22HELI_MAX,
			   FALSE,
			   r22heli_spawn, autocvar_g_vehicle_r22heli_respawntime,
			   r22heli_pilot_frame, r22heli_enter, r22heli_exit,
			   r22heli_die, r22heli_think, FALSE, autocvar_g_vehicle_r22heli_health, autocvar_g_vehicle_r22heli_shield, autocolor, caammomax, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}

void spawnfunc_vehicle_r22heli_milspec()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 64; //So we spawn weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_r22heli();
}
#endif // SVQC

#ifdef CSQC
void r22heli_draw()
{

}

void r22heli_draw2d()
{

}

void r22heli_read_extra()
{

}

void vehicle_r22heli_assemble()
{

}
#endif //CSQC
