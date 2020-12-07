#define SUBMERSIBLE_MIN '-60 -60 0'
#define SUBMERSIBLE_MAX '60 60 116'

#define SUBMERSIBLE_ROTORSPEED 7500


#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P

//Sparrow
float autocvar_g_vehicle_submersible_mass;

float autocvar_g_vehicle_submersible_respawntime;
float autocvar_g_vehicle_submersible_takeofftime;

float autocvar_g_vehicle_submersible_movestyle;
float autocvar_g_vehicle_submersible_turnspeed;
float autocvar_g_vehicle_submersible_pitchspeed;
float autocvar_g_vehicle_submersible_pitchlimit;

float autocvar_g_vehicle_submersible_friction;

float autocvar_g_vehicle_submersible_bombs_refire;

float autocvar_g_vehicle_submersible_flare_range;

float autocvar_g_vehicle_submersible_bouncefactor;
float autocvar_g_vehicle_submersible_bouncestop;
vector autocvar_g_vehicle_submersible_bouncepain;


// Auto cvars Fastcar
float autocvar_g_vehicle_submersible_mass;
float autocvar_g_vehicle_submersible_speed_forward;
float autocvar_g_vehicle_submersible_speed_strafe;
float autocvar_g_vehicle_submersible_speed_up;
float autocvar_g_vehicle_submersible_speed_down;
float autocvar_g_vehicle_submersible_pitchlimit;

float autocvar_g_vehicle_submersible_friction;

float autocvar_g_vehicle_submersible_turnspeed;
float autocvar_g_vehicle_submersible_pitchspeed;

float autocvar_g_vehicle_submersible_energy;
float autocvar_g_vehicle_submersible_energy_regen;
float autocvar_g_vehicle_submersible_energy_regen_pause;

float autocvar_g_vehicle_submersible_health;
float autocvar_g_vehicle_submersible_health_regen;
float autocvar_g_vehicle_submersible_health_regen_pause;

float autocvar_g_vehicle_submersible_shield;
float autocvar_g_vehicle_submersible_shield_regen;
float autocvar_g_vehicle_submersible_shield_regen_pause;

float autocvar_g_vehicle_submersible_cannon_speed;

float autocvar_g_vehicle_submersible_cannon_ammo;
float autocvar_g_vehicle_submersible_cannon_ammo_regen;
float autocvar_g_vehicle_submersible_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_submersible_cannon_lock = 0;

float autocvar_g_vehicle_submersible_cannon_turnspeed;
float autocvar_g_vehicle_submersible_cannon_pitchlimit_down;
float autocvar_g_vehicle_submersible_cannon_pitchlimit_up;
float autocvar_g_vehicle_submersible_cannon_turnlimit_in;
float autocvar_g_vehicle_submersible_cannon_turnlimit_out;

float autocvar_g_vehicle_submersible_respawntime;

float autocvar_g_vehicle_submersible_blowup_radius;
float autocvar_g_vehicle_submersible_blowup_coredamage;
float autocvar_g_vehicle_submersible_blowup_edgedamage;
float autocvar_g_vehicle_submersible_blowup_forceintensity;

float autocvar_g_vehicle_submersible_bouncefactor;
float autocvar_g_vehicle_submersible_bouncestop;
vector autocvar_g_vehicle_submersible_bouncepain;

var float autocvar_g_vehicle_submersible = 0;
var vector submersible_force_from_tag(string tag_name, float spring_length, float max_power);

float submersible_takeoff();
float submersible_pilot_frame();
void submersible_think();
void submersible_minigun(entity gun, entity pilot, entity gunmount, entity mggun1);
void submersible_hmg(entity gun, entity pilot, entity gunmount);

float submersible_watertest (entity vehic, vector voffset, string mywatertestspot)
{
	vector v;
	float rf;
	float oldsolid;
	
	oldsolid = vehic.solid;
	
	vehic.solid = SOLID_NOT;
	v = gettaginfo(vehic, gettagindex(vehic, mywatertestspot));
	v = v + voffset;
	rf = pointcontents(v);
	vehic.solid = oldsolid;


	if (rf == CONTENT_WATER) {
		return 1;
	} else if (rf == CONTENT_SLIME) {
		return 0.95;
	} else if (rf == CONTENT_LAVA) {
		return 0.5;
	}
	
	return 0;
}

void submersibleminder_think()
{
	if (self.subordinate.movetype == MOVETYPE_BOUNCEMISSILE)
	{
		if (submersible_watertest(self.subordinate, '0 0 -16', "watertestspot")) {
			self.subordinate.movetype = MOVETYPE_BOUNCEMISSILE;
		} else {
       			self.subordinate.movetype = MOVETYPE_TOSS;
		}
	}
	
	self.nextthink = time + 0.1;
}

//float submersible_altitude(float amax)
//{
//	tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * amax), MOVE_WORLDONLY, self);
//    return vlen(self.origin - trace_endpos);
//}

void submersible_pilot_enter()
{
    //print(sprintf("waterlevel: %f vehic to player %f\n", self.waterlevel, self.owner.waterlevel));

    self.vehicle_weapon2mode = RSM_BOMB;
    self.owner.PlayerPhysplug = submersible_takeoff;
    self.movetype       = MOVETYPE_BOUNCEMISSILE;
    self.solid          = SOLID_SLIDEBOX;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_submersible_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_submersible_shield) * 100;
    self.velocity_z = 1; // Nudge upwards to takeoff sequense can work.
    self.tur_head.exteriormodeltoclient = self.owner;

    self.delay = time + autocvar_g_vehicle_submersible_bombs_refire;
    self.lip   = time;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-20 0 96');
    
    CSQCVehicleSetup(self.owner, 0);
}


void submersible_land()
{    

    self.velocity = (self.velocity * 0.9);
    self.angles_x *= 0.95;
    self.angles_z *= 0.95;

    self.frame = self.frame - (1*frametime);

    self.bomb1.gun1.avelocity_y = self.bomb1.gun1.avelocity_y * 0.95;
    self.bomb2.gun1.avelocity_y = self.bomb1.gun1.avelocity_y;
    self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;


    if(self.frame < 0.1)
    {
    	if (submersible_watertest(self, '0 0 -16', "watertestspot")) {
		self.movetype = MOVETYPE_BOUNCEMISSILE;
	} else {
       		self.movetype = MOVETYPE_TOSS;
	}
        self.think    = submersible_think;
        self.frame    = 0;
    }

    self.nextthink  = time;
}

float submersible_takeoff()
{
    entity player, submersible;
    
    player = self;
    submersible = self.vehicle;
    self   = submersible;
    
    player.air_finished = time + 12;
    
    if(player.BUTTON_JUMP || player.BUTTON_CROUCH || (player.BUTTON_HOOK && (player.movement_x > 0))) {
    	if(submersible.bomb1.gun1.count == 0) {
	    	submersible.bomb1.gun1.count = 1;
		if((clienttype(player) == CLIENTTYPE_REAL)) {
			sprint(player, "Engine Engaged\n");
		}
        }
    }
    
    if(self.sound_nexttime < time)
    {
    	if (submersible.bomb1.gun1.count) {
	if (player.waterlevel)
   	{
        	//self.sound_nexttime = time + 7.955812; //soundlength("vehicles/raptor_fly.wav");
		self.sound_nexttime = time + 11.888604; //soundlength("vehicles/racer_idle.wav");  
        	sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", VOL_VEHICLEENGINE, ATTN_NORM);
	}
	}
    }   

 
    if (submersible_watertest(self, '0 0 -16', "watertestspot")) {
		self.movetype = MOVETYPE_BOUNCEMISSILE;
    } else {
       		self.movetype = MOVETYPE_TOSS;
    }


    // Takeoff sequense
    if(submersible.bomb1.gun1.count == 1) {
    	    submersible.movetype     = MOVETYPE_BOUNCEMISSILE;
    	if(submersible.frame < 25)
    	{
		submersible.frame += 25 / (autocvar_g_vehicle_submersible_takeofftime / sys_frametime);    
		if (player.waterlevel)
   		{
			//submersible.velocity_z = min(submersible.velocity_z * 1.5, 256);
        		self.bomb1.gun1.avelocity_y = 90 + ((submersible.frame / 25) * SUBMERSIBLE_ROTORSPEED);
			self.bomb2.gun1.avelocity_y = self.bomb1.gun1.avelocity_y;
        		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
		}	
    	}
    	else
    	{
        	player.PlayerPhysplug = submersible_pilot_frame;
    	}
    } else {
    	//Engine off?
    	if (submersible.frame > 0) {
        	submersible.frame -= 25 / (autocvar_g_vehicle_submersible_takeofftime / sys_frametime);
		//if (player.waterlevel)
   		//{
			self.bomb1.gun1.avelocity_y = 90 + ((submersible.frame / 25) * SUBMERSIBLE_ROTORSPEED);
			self.bomb2.gun1.avelocity_y = self.bomb1.gun1.avelocity_y;
        		self.bomb1.gun2.avelocity_y = -self.bomb1.gun1.avelocity_y;
		//}
	}
	if(submersible.flags & FL_ONGROUND)
        		movelib_beak_simple(1);
    }
    
    //Cannon firing
    helicopter_delugegun(submersible, player, submersible.bomb11);
    helicopter_delugegun(submersible, player, submersible.bomb12);
    helicopter_delugegun(submersible, player, submersible.bomb13);
    helicopter_delugegun(submersible, player, submersible.bomb14);
     
    if (submersible.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	submersible_minigun(submersible, player, submersible.bomb3, submersible.bomb3.gun1);
	submersible_minigun(submersible, player, submersible.bomb4, submersible.bomb4.gun1);
		if(player.BUTTON_HOOK) {
			player.BUTTON_JUMP   = 0;
    			player.BUTTON_CROUCH    = 0;
    			//player.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
	
	if (submersible.spawnflags & 128) {
	submersible_hmg(submersible, player, submersible.bomb5);
	submersible_hmg(submersible, player, submersible.bomb6);
	}
    }
    
    if (submersible.vehicle_ammo1_max) {
    	player.vehicle_ammo1_current = submersible.vehicle_ammo1_current;
    	player.vehicle_ammo1_max = submersible.vehicle_ammo1_max;
    }
    
    if (submersible.vehicle_ammo2_max) {
    	player.vehicle_ammo2_current = submersible.vehicle_ammo2_current;
    	player.vehicle_ammo2_max = submersible.vehicle_ammo2_max;
    }
    ///End takeoff weapons stuff
    
    
    if (
    ((!((submersible.spawnflags & 32)
	|| (submersible.spawnflags & 64)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 6))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(submersible, submersible, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    setorigin(player, submersible.origin + '0 0 32');

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(submersible.dmg_time, vehicle_shield, autocvar_g_vehicle_submersible_shield, autocvar_g_vehicle_submersible_shield_regen_pause, autocvar_g_vehicle_submersible_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(submersible.dmg_time, vehicle_health, autocvar_g_vehicle_submersible_health, autocvar_g_vehicle_submersible_health_regen_pause, autocvar_g_vehicle_submersible_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(submersible.cnt, vehicle_energy, autocvar_g_vehicle_submersible_energy, autocvar_g_vehicle_submersible_energy_regen_pause, autocvar_g_vehicle_submersible_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    submersible.bomb1.alpha = submersible.bomb2.alpha = (time - submersible.lip) / (submersible.delay - submersible.lip);
    player.vehicle_reload2 = bound(0, submersible.bomb1.alpha * 100, 100);

    VEHICLE_UPDATE_PLAYER(player, health, submersible);
    VEHICLE_UPDATE_PLAYER(player, energy, submersible);
    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, submersible);


    if (
    ((!((submersible.spawnflags & 32)
	|| (submersible.spawnflags & 64)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 6))
    ) {
		//Do nothing//
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(submersible, submersible, player);
		player.BUTTON_CROUCH = 0;
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = player.BUTTON_CROUCH = 0;
    }
    
    if (submersible.vehicle_ammo1_max) {
    	player.vehicle_ammo1_current = submersible.vehicle_ammo1_current;
    	player.vehicle_ammo1_max = submersible.vehicle_ammo1_max;
    }
    
    if (submersible.vehicle_ammo2_max) {
    	player.vehicle_ammo2_current = submersible.vehicle_ammo2_current;
    	player.vehicle_ammo2_max = submersible.vehicle_ammo2_max;
    }
    
    self = player;
    return 1;
}

float submersible_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;


	gunner.air_finished = time + 12;
	
	
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
		_in = autocvar_g_vehicle_submersible_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_submersible_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_submersible_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_submersible_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;

	if(autocvar_g_vehicle_submersible_cannon_lock)
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
			impact_time = distance / autocvar_g_vehicle_submersible_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_submersible_cannon_pitchlimit_down * -1, autocvar_g_vehicle_submersible_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_submersible_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_submersible_cannon_pitchlimit_down * -1, autocvar_g_vehicle_submersible_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_submersible_cannon_turnspeed);

	
  }

	VEHICLE_UPDATE_PLAYER(gunner, health, submersible);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, submersible);

  if not (autocvar_g_vehicles_noauxaimforpassengervehic) {
	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));

  }

	vehic.solid = SOLID_BBOX;
	if (vehicles_allowdriveby(0, gunner, autocvar_g_vehicles_allowdriveby_pssngr_hudnorm, 6)) {
		//See that 6. That's a Magic Number that says "we are a submersible"
		//Do nothing
		gunner.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, gun, gunner);
		gunner.BUTTON_CROUCH = 0;
	} else {
		gunner.vehicle_allowdriveby = 0;
		gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	}
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_submersible_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void submersible_gunner_exit(float _exitflag)
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
	else
		dprint("^1self != gunner1,2,3, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 132 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float submersible_gunner_enter(float selectgun)
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
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = submersible_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= submersible_gunner_enter;
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
	other.PlayerPhysplug    = submersible_gunner_frame;
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

float submersiblevehicles_valid_pilot()
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

void submersible_touch()
{

	if((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world))
	{
		vehicles_touch();
		return;
	}

	if(submersiblevehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(submersible_gunner_enter(0))
				return;
				
		if(self.gun2.phase <= time)
			if(submersible_gunner_enter(0))
				return;
		
		if(self.gun3.phase <= time)
			if(submersible_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void submersible_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_submersible_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_submersible_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_submersible_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_submersible_shield, autocvar_g_vehicle_submersible_shield_regen_pause, autocvar_g_vehicle_submersible_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_submersible_health, autocvar_g_vehicle_submersible_health_regen_pause, autocvar_g_vehicle_submersible_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_submersible_energy, autocvar_g_vehicle_submersible_energy_regen_pause, autocvar_g_vehicle_submersible_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

void submersible_minigun(entity gun, entity pilot, entity gunmount, entity mggun1)
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

void submersible_hmg(entity gun, entity pilot, entity gunmount)
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


float submersible_boatwatertest (entity vehic)
{
	float watertest;
	watertest = 0;
	
	if (submersible_watertest(vehic, '0 0 0', "watertestspot")) {
		watertest = 1;
	}
	
	if (!watertest) {
		if (submersible_watertest(vehic, '0 0 0', "watertestspotdown")) {
			if (random() > 0.75) {
				//Skipping on water
				watertest = 1;
			}
		}
	}
	
	if (submersible_watertest(vehic, '0 0 0', "watertestspotup"))
	{
		watertest = 0;
	}
	
	return watertest;
}

float submersible_boatunderwatertest (entity vehic)
{
	if (submersible_watertest(vehic, '0 0 0', "watertestspotup")) {
	if (submersible_watertest(vehic, '0 0 0', "watertestspot")) {
	if (submersible_watertest(vehic, '0 0 0', "watertestspotdown")) {
		return TRUE;
	}
	}
	}
	
	return FALSE;
}

float submersible_boatsomewhatunderwatertest (entity vehic)
{
	if (submersible_watertest(vehic, '0 0 0', "watertestspot")) {
	if (submersible_watertest(vehic, '0 0 0', "watertestspotdown")) {
		return TRUE;
	}
	}
	
	return FALSE;
}

void submersible_movement (float boatmovement, float() whichtakeofffunc, entity pilot, entity vehic, float vehicturnspeed, float vehicpitchlimit, float vehicpitchspeed, float vehicmovestyle, float vehicfriction, float vehicspeedforward, float vehicspeedstrafe, float vehicspeeddown, float vehicspeedup, float ftmp, entity myengine1, entity myengine2, entity myenginestrafe, float myrotorspeed, float myrotordir1, float myrotordir2, float mystraferotordir)
{
    vector df;
    vector vang;
    float watertest;
    
    vang = vehic.angles;
    df = vectoangles(normalize(trace_endpos - vehic.origin + '0 0 32'));
    vang_x *= -1;
    df_x *= -1;
    if(df_x > 180)  df_x -= 360;
    if(df_x < -180) df_x += 360;
    if(df_y > 180)  df_y -= 360;
    if(df_y < -180) df_y += 360;
    
    //print("wl: ", ftos(vehic.waterlevel), "\n");
    //print(sprintf("waterlevel: %f vehic to player %f\n", vehic.waterlevel, pilot.waterlevel));
	
    if (boatmovement) {
    	watertest = submersible_boatwatertest(vehic);
    } else {
    	watertest = submersible_watertest(vehic, '0 0 0', "watertestspot");
    }
    
    if (pilot.waterlevel && watertest)
    {
    //Got to do it this way as vehicles waterlevel is always 1
    //Thus we check players water level instead.
    /////////////////////////////////////////////////////////////////////////
    //BEGIN If in water
    /////////////////////////////////////////////////////////////////////////

    ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
    if(ftmp > 180)  ftmp -= 360; if(ftmp < -180) ftmp += 360;
    vehic.avelocity_y = bound(-vehicturnspeed, ftmp + vehic.avelocity_y * 0.9, vehicturnspeed);

    // Pitch
    ftmp = 0;
    if not((pilot.BUTTON_HOOK) && (pilot.movement_x < 0)) {
    if(pilot.movement_x > 0 && vang_x < vehicpitchlimit) ftmp = 5;
    else if(pilot.movement_x < 0 && vang_x > -vehicpitchlimit) ftmp = -20;
    }

    df_x = bound(-vehicpitchlimit, df_x , vehicpitchlimit);
    ftmp = vang_x - bound(-vehicpitchlimit, df_x + ftmp, vehicpitchlimit);
    vehic.avelocity_x = bound(-vehicpitchspeed, ftmp + vehic.avelocity_x * 0.9, vehicpitchspeed);

    vehic.angles_x = anglemods(vehic.angles_x);
    vehic.angles_y = anglemods(vehic.angles_y);
    vehic.angles_z = anglemods(vehic.angles_z);

    if(vehicmovestyle == 1)
        makevectors('0 1 0' * vehic.angles_y);
    else
        makevectors(pilot.v_angle);

    df = vehic.velocity * -vehicfriction;
    
    if(pilot.BUTTON_HOOK) {
    		if(pilot.movement_x < 0) {
   			//if(submersible_altitude(512) < 16) 
			//{
				
				pilot.PlayerPhysplug = whichtakeofffunc;
				
				if (myengine1) myengine1.count = 0;
				if((clienttype(pilot) == CLIENTTYPE_REAL)) {
					sprint(pilot, "Engine disengaged\n");
				}
			//}
		}	 
    } else {

    if(pilot.movement_x != 0)
    {		
        if(pilot.movement_x > 0) {
	    if (myengine1) myengine1.avelocity_y = (90 + ((vehic.frame / 25) * myrotorspeed)) * -1 * myrotordir1;
            df += v_forward  * vehicspeedforward * watertest;
        } else if(pilot.movement_x < 0) {
	    if (myengine1) myengine1.avelocity_y = (90 + ((vehic.frame / 25) * myrotorspeed)) * myrotordir1;
            df -= v_forward  * vehicspeedforward * watertest;
	}
	
	if (vehic.frame < 25) {
		vehic.frame = vehic.frame - (25*frametime);
	} else {
		vehic.frame = 25;
	}
    } else {
    	if (myengine1) myengine1.avelocity_y = myengine1.avelocity_y * 0.95;
	if (vehic.frame > 0) {
		vehic.frame = vehic.frame - (25*frametime);
	} else {
		vehic.frame = 0;
	}
    }
    }

    if (myengine2 && myengine1) myengine2.avelocity_y = myengine1.avelocity_y * myrotordir2;

    if(pilot.movement_y != 0)
    {
        if(pilot.movement_y < 0) {
            df -= v_right * vehicspeedstrafe * watertest;
	    if (myenginestrafe) myenginestrafe.avelocity_y = (90 + (myrotorspeed)) * mystraferotordir;
        } else if(pilot.movement_y > 0) {
            df += v_right * vehicspeedstrafe * watertest;
	    if (myenginestrafe) myenginestrafe.avelocity_y = (90 + (myrotorspeed)) * -1 * mystraferotordir;
	}

        vehic.angles_z = bound(-5,vehic.angles_z + (pilot.movement_y / vehicspeedstrafe),5);
    }
    else
    {
    	if (myenginestrafe) myenginestrafe.avelocity_y = myenginestrafe.avelocity_y * 0.95;
	
        vehic.angles_z *= 0.95;
        if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
            vehic.angles_z = 0;
    }
    
 
    if (boatmovement) {
    	if(pilot.movement_x) {
    		if (random() > 0.45)
    			df +=  v_up * vehicspeedup * 0.15;
		else
			df -=   v_up * vehicspeeddown * 0.15;
	} else {
		if (random() > 0.45)
    			df +=  v_up * vehicspeedup * 0.05;
		else
			df -=   v_up * vehicspeeddown * 0.05;
	}
    } else {
    	if(pilot.BUTTON_CROUCH)
    	    df -=   v_up * vehicspeeddown;
    	else if (pilot.BUTTON_JUMP)
    	    df +=  v_up * vehicspeedup;
    }
	
    
    vehic.velocity  += df * frametime;
    vehic.movetype       = MOVETYPE_BOUNCEMISSILE;
    } else {
    /////////////////////////////////////////////////////////////////////////
    //END If in water
    /////////////////////////////////////////////////////////////////////////
	//vehic.velocity  = '0 0 0';
	df = vehic.velocity * -vehicfriction;

	//vehic.velocity_x = 0;
	//vehic.velocity_y = 0;	
	vehic.velocity_z = 0;
	vehic.avelocity_x = 0;
	vehic.avelocity_y = 0;
	vehic.avelocity_z = 0;
	vehic.movetype  = MOVETYPE_TOSS;
	if (myengine1) myengine1.avelocity_y = myengine1.avelocity_y * 0.95;
	if (myengine2 && myengine1) myengine2.avelocity_y = myengine1.avelocity_y;
    	if (myenginestrafe && myengine1) myenginestrafe.avelocity_y = -myengine1.avelocity_y;
	
	if (boatmovement) {
		if (submersible_boatunderwatertest(vehic)) {
			//print ("Go up\n");
			vehic.movetype       = MOVETYPE_BOUNCEMISSILE;
			df +=  (v_up * vehicspeedup);
		} else {
			//print ("Go down\n");
			df +=  (v_up * vehicspeedup) * -1;
		}
	} else {
		df +=  (v_up * vehicspeedup) * -1;
	}
	vehic.velocity  += df * frametime;
    }
}


float submersible_pilot_frame()
{
    entity pilot, vehic;
    float ftmp;
	
	if(intermission_running)
		return 1;

    pilot = self;
    vehic = self.vehicle;
    self   = vehic;
    
    pilot.air_finished = time + 12;

vehicles_painframe();
    /*
    ftmp = vlen(self.velocity);
    if(ftmp > autocvar_g_vehicle_submersible_speed_forward) 
        ftmp = 1;
    else  
        ftmp = ftmp / autocvar_g_vehicle_submersible_speed_forward;
    */
        
    if(self.sound_nexttime < time)
    if (pilot.waterlevel)
    {        
        //self.sound_nexttime = time + 7.955812; 
        ////sound (self.tur_head, CH_TRIGGER_SINGLE, "vehicles/raptor_fly.wav", 1 - ftmp,   ATTN_NORM );
        //sound (self, CH_TRIGGER_SINGLE, "vehicles/raptor_speed.wav", 1, ATTN_NORM);   
	self.sound_nexttime = time + 11.888604; //soundlength("vehicles/racer_idle.wav");  
	sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", 1, ATTN_NORM); 
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


    
    submersible_movement (0, submersible_takeoff, pilot, vehic,
	autocvar_g_vehicle_submersible_turnspeed,
	autocvar_g_vehicle_submersible_pitchlimit,
	autocvar_g_vehicle_submersible_pitchspeed,
	autocvar_g_vehicle_submersible_movestyle,
	autocvar_g_vehicle_submersible_friction,
	autocvar_g_vehicle_submersible_speed_forward,
	autocvar_g_vehicle_submersible_speed_strafe,
	autocvar_g_vehicle_submersible_speed_down,
	autocvar_g_vehicle_submersible_speed_up, ftmp,
	vehic.bomb1.gun1,
	vehic.bomb2.gun1,
	vehic.bomb1.gun2,
	SUBMERSIBLE_ROTORSPEED,
	1,
	1,
	1
	);
    
    
    
    pilot.velocity = pilot.movement  = vehic.velocity;
    setorigin(pilot, vehic.origin + '0 0 32');
    
    //Cannon firing
    helicopter_delugegun(vehic, pilot, vehic.bomb11);
    helicopter_delugegun(vehic, pilot, vehic.bomb12);
    helicopter_delugegun(vehic, pilot, vehic.bomb13);
    helicopter_delugegun(vehic, pilot, vehic.bomb14);
     
    if (vehic.spawnflags >= 64) {
    	if (self.spawnflags & 64) {
    	submersible_minigun(vehic, pilot, vehic.bomb3, vehic.bomb3.gun1);
	submersible_minigun(vehic, pilot, vehic.bomb4, vehic.bomb4.gun1);
		if(pilot.BUTTON_HOOK) {
			pilot.BUTTON_JUMP   = 0;
    			pilot.BUTTON_CROUCH    = 0;
    			//pilot.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
	
	if (vehic.spawnflags & 128) {
	submersible_hmg(vehic, pilot, vehic.bomb5);
	submersible_hmg(vehic, pilot, vehic.bomb6);
	}
    }

    // Target lock & predict
    
    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_submersible_shield, autocvar_g_vehicle_submersible_shield_regen_pause, autocvar_g_vehicle_submersible_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_submersible_health, autocvar_g_vehicle_submersible_health_regen_pause, autocvar_g_vehicle_submersible_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_submersible_energy, autocvar_g_vehicle_submersible_energy_regen_pause, autocvar_g_vehicle_submersible_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

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
            if(vlen(self.origin - _missile.origin) < 2 * autocvar_g_vehicle_submersible_flare_range)
                ++_incomming;

            _missile = _missile.chain;
        }
        
        if(_incomming)
            sound(self, CH_PAIN_SINGLE, "vehicles/missile_alarm.wav", VOL_BASE, ATTN_NONE);
        
        self.bomb1.cnt = time + 1;
    }
    

//Weapons removed
   

    local entity submersible = vehic;

    VEHICLE_UPDATE_PLAYER(pilot, health, submersible);
    VEHICLE_UPDATE_PLAYER(pilot, energy, submersible);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, submersible);


    if (
    ((!((submersible.spawnflags & 32)
	|| (submersible.spawnflags & 64)))
	|| (autocvar_g_vehicles_allowdriveby_drvr > 1))
    && (vehicles_allowdriveby(1, pilot, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 6))
    ) {
		//Do nothing//
		pilot.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(submersible, submersible, pilot);
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

void submersible_think()
{
	self.nextthink = time;
	
	if (submersible_watertest(self, '0 0 -16', "watertestspot")) {
		self.movetype = MOVETYPE_BOUNCEMISSILE;
	} else {
       		self.movetype = MOVETYPE_TOSS;
	}

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
		
	}
	
}

void submersible_enter()
{
	self.touch = submersible_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCE;
	submersible_pilot_enter();
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void submersible_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = submersible_think;
	self.nextthink = time;
	
	if(!self.owner)
		return;
	
	//Add from sparrow	
	if(self.deadflag == DEAD_NO)
	{
		self.frame = 1;
        	self.think      = submersible_land;
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

void submersible_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_submersible_blowup_coredamage,
				 autocvar_g_vehicle_submersible_blowup_edgedamage,
				 autocvar_g_vehicle_submersible_blowup_radius, self,
				 autocvar_g_vehicle_submersible_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	//submersibleminder
	if (self.subordinate4) {
		remove (self.subordinate4);
	}
	
	remove(self);
}

void submersible_diethink()
{
	if(time >= self.wait)
		self.think = submersible_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void submersible_die()
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

	self.vehicle_exit(VHEF_EJECT);
	
	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = submersible_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 1;
	_body.think = submersible_diethink;
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

}

void submersible_impact()
{
    if(autocvar_g_vehicle_submersible_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_submersible_bouncepain_x, 
						autocvar_g_vehicle_submersible_bouncepain_y, 
						autocvar_g_vehicle_submersible_bouncepain_z);
}

// If we dont do this ever now and then, the submersibles rotors
// stop working, presumably due to angle overflow. cute.
void submersible_rotor_anglefix()
{
    self.gun1.angles_y = anglemods(self.gun1.angles_y); //Engine 1
    self.gun2.angles_y = anglemods(self.gun2.angles_y); //Side to side prop
    self.gun1.owner.bomb2.gun1.angles_y = anglemods(self.gun1.owner.bomb2.gun1.angles_y); //Engine 2
    self.nextthink = time + 15;
}

void submersible_spawn(float _f)
{
   self.vehicle_pilotchangeseat = submersible_gunner_enter; //Function to exec if pilot wants to change seat

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

  
		self.lodmodel1 = "models/vehicles/submersible_lod1.iqm";
		self.lodmodel2 = "models/vehicles/submersible_lod2.iqm";
		self.lodmodel3 = "models/vehicles/submersible_lod3.iqm";

	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
     
        self.frame = 0;

        self.bomb1 = spawn();
        self.bomb2 = spawn();
        self.gun1  = spawn();
        self.gun2  = spawn();
	self.gun3  = spawn();

        setmodel(self.bomb1,"null");
        setmodel(self.bomb2,"null");
        setmodel(self.gun1, "null");
        setmodel(self.gun2, "null");
	setmodel(self.gun3, "null");
        //setmodel(self.tur_head, "models/vehicles/submersibleedits_body.iqm");

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
        setmodel(spinner,"models/vehicles/submersible_spinnerengine.iqm");
        setattachment(spinner, self, "engine_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	//spinner.scale = 3.0;
        self.bomb1.gun1 = spinner;

        spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/submersible_spinner.iqm");
        setattachment(spinner, self, "engine_turn");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 -90 0';
        self.bomb1.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/submersible_spinnerengine.iqm");
        setattachment(spinner, self, "engine_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
	//spinner.scale = 3.0;
        self.bomb2.gun1 = spinner;

        // Sigh.
        self.bomb1.think = submersible_rotor_anglefix;
        self.bomb1.nextthink = time;

	setattachment(self.vehicle_viewport, self, "tag_camera");
        //self.mass               = 1 ;
	self.mass               = autocvar_g_vehicle_submersible_mass;
	
	self.vehicle_flags |= VHF_MULTISLOT;

	self.gun1.owner = self;
	self.gun2.owner = self;
	self.gun3.owner = self;
		
	setattachment(self.gun1, self, "tag_pass1");
	setattachment(self.gun2, self, "tag_pass3");
	setattachment(self.gun3, self, "tag_pass4");
	
	vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "null", submersible_gunner_frame, submersible_gunner_exit);
	vehicle_addplayerslot(self, self.gun2, HUD_WAKIZASHI, "null", submersible_gunner_frame, submersible_gunner_exit);
	vehicle_addplayerslot(self, self.gun3, HUD_WAKIZASHI, "null", submersible_gunner_frame, submersible_gunner_exit);
	
	helicopter_delugegun_add(self, "forwardmount_left");
	helicopter_delugegun_add2(self, "forwardmount_right");
	helicopter_delugegun_add3(self, "gunmount_left");
	helicopter_delugegun_add4(self, "gunmount_right");
	
	
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
	
	self.bomb3.angles_z = -95; //So ammo chain travels into fuselage
	
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
	
	self.bomb4.angles_z = 95; //So ammo chain travels into fuselage
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
    self.vehicle_health = autocvar_g_vehicle_submersible_health;
    self.vehicle_shield = autocvar_g_vehicle_submersible_shield;
    if (submersible_watertest(self, '0 0 -16', "watertestspot")) {
    		//print("******in water*******\n");
		self.movetype = MOVETYPE_BOUNCEMISSILE;
		//self.movetype = MOVETYPE_NONE;
    } else {
    		//print("******NOT in water*******\n");
   		self.movetype       = MOVETYPE_TOSS;
    }
    self.solid          = SOLID_SLIDEBOX;
    self.vehicle_energy = 1;

    self.bomb1.gun1.avelocity_y = 90;
    self.bomb2.gun1.avelocity_y = 90;
    self.bomb1.gun2.avelocity_y = -90;

    setsize(self, SUBMERSIBLE_MIN, SUBMERSIBLE_MAX );
    self.delay = time;
        
    self.bouncefactor = autocvar_g_vehicle_submersible_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_submersible_bouncestop;    
    self.vehicle_impact = submersible_impact;    
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
	
	//Submersible minder
	self.subordinate4 = spawn();
	self.subordinate4.subordinate = self;
	self.subordinate4.think = submersibleminder_think;
	self.subordinate4.nextthink = time;
}

void spawnfunc_vehicle_submersible()
{
	if(!autocvar_g_vehicle_submersible)
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

	float autocolor, mynodrop;
	autocolor = 0;
	
    	precache_model ("models/vhshield.md3");
	
	precache_model ("models/vehicles/submersible_spinner.iqm");
	precache_model ("models/vehicles/submersible_spinnerengine.iqm");
	
	float caammomax;
	string bodymodel;
	
	if (self.spawnflags & 32) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		precache_sound ( "machines/steam_fade.ogg" );
		
		autocolor = (1024 + 4 + 4 * 16); //Red
	}
	
	if (self.spawnflags >= 64) {
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
		
		autocolor = 1023;
	} else {
		caammomax = 0;
		
		if not (autocolor) {
			if (random() > 0.5) {
				autocolor = (1024 + 1 + 1 * 16); //Orange
			} else {
				autocolor = (1024 + 14 + 14 * 16); //Another Orange
			}
		}
	}
	
		precache_model("models/vehicles/submersible.iqm");
		precache_model("models/vehicles/submersible_lod1.iqm");
		precache_model("models/vehicles/submersible_lod2.iqm");
		precache_model("models/vehicles/submersible_lod3.iqm");
		bodymodel = "models/vehicles/submersible.iqm";
	
	precache_sound ("vehicles/racer_idle.wav");
	precache_sound ("vehicles/missile_alarm.wav");
	precache_sound ( "weapons/rocket_impact.wav");

	if(autocvar_g_vehicle_submersible_energy)
		if(autocvar_g_vehicle_submersible_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_submersible_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_submersible_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_submersible_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	
	if (self.colormap >= 1023)
		autocolor = self.colormap;
		
	
	local float wt;
	wt = pointcontents(self.origin);
	
	if (wt == CONTENT_WATER) {
		mynodrop = TRUE;
	} else if (wt == CONTENT_SLIME) {
		mynodrop = TRUE;
	} else if (wt == CONTENT_LAVA) {
		mynodrop = TRUE;
	} else {
		mynodrop = FALSE;
	}

	//print(vtos(self.origin),"  ---SelfOrigin\n");
	//print(ftos(mynodrop),"  ---NODROP\n");
	
	if not(vehicle_initialize(
			   "Submersible",
			   bodymodel,
			   "null", // we need this so tur_head is networked and usable for sounds
			   "null", 
			   "", "", "tag_viewport",
			   HUD_WAKIZASHI, 
           		   SUBMERSIBLE_MIN, SUBMERSIBLE_MAX,
			   mynodrop,
			   submersible_spawn, autocvar_g_vehicle_submersible_respawntime,
			   submersible_pilot_frame, submersible_enter, submersible_exit,
			   submersible_die, submersible_think, mynodrop, autocvar_g_vehicle_submersible_health, autocvar_g_vehicle_submersible_shield, autocolor, caammomax, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}

void spawnfunc_vehicle_submersible_milspec()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 128; //So we spawn .50 weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_submersible();
}

void spawnfunc_vehicle_submersible_milspec2()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 64; //So we spawn minigun weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_submersible();
}

void spawnfunc_vehicle_submersible_milspec3()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 64 + 128; //So we spawn .50 and minigun weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_submersible();
}
#endif // SVQC

#ifdef CSQC
void submersible_draw()
{

}

void submersible_draw2d()
{

}

void submersible_read_extra()
{

}

void vehicle_submersible_assemble()
{

}
#endif //CSQC
