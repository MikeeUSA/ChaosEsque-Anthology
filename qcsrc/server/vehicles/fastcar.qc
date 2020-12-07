#define FASTCAR_MIN '-126 -126 0'
#define FASTCAR_MAX '126 126 90'

#define FASTCAR_SETUP 2
#define FASTCAR_START 4
#define FASTCAR_END 8

#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P

// Auto cvars
float autocvar_g_vehicle_fastcar_mass;
float autocvar_g_vehicle_fastcar_speed_forward;
float autocvar_g_vehicle_fastcar_speed_strafe;

float autocvar_g_vehicle_fastcar_speed_afterburn;
float autocvar_g_vehicle_fastcar_afterburn_cost;

float autocvar_g_vehicle_fastcar_anglestabilizer;
float autocvar_g_vehicle_fastcar_downforce;

float autocvar_g_vehicle_fastcar_speed_forward;
float autocvar_g_vehicle_fastcar_speed_strafe;
float autocvar_g_vehicle_fastcar_springlength;
float autocvar_g_vehicle_fastcar_upforcedamper;
float autocvar_g_vehicle_fastcar_friction;

float autocvar_g_vehicle_fastcar_hovertype;
float autocvar_g_vehicle_fastcar_hoverpower;

float autocvar_g_vehicle_fastcar_turnroll;
float autocvar_g_vehicle_fastcar_turnspeed;
float autocvar_g_vehicle_fastcar_pitchspeed;

float autocvar_g_vehicle_fastcar_energy;
float autocvar_g_vehicle_fastcar_energy_regen;
float autocvar_g_vehicle_fastcar_energy_regen_pause;

float autocvar_g_vehicle_fastcar_health;
float autocvar_g_vehicle_fastcar_health_regen;
float autocvar_g_vehicle_fastcar_health_regen_pause;

float autocvar_g_vehicle_fastcar_shield;
float autocvar_g_vehicle_fastcar_shield_regen;
float autocvar_g_vehicle_fastcar_shield_regen_pause;

float autocvar_g_vehicle_fastcar_cannon_speed;

float autocvar_g_vehicle_fastcar_cannon_ammo;
float autocvar_g_vehicle_fastcar_cannon_ammo_regen;
float autocvar_g_vehicle_fastcar_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_fastcar_cannon_lock = 0;

float autocvar_g_vehicle_fastcar_cannon_turnspeed;
float autocvar_g_vehicle_fastcar_cannon_pitchlimit_down;
float autocvar_g_vehicle_fastcar_cannon_pitchlimit_up;
float autocvar_g_vehicle_fastcar_cannon_turnlimit_in;
float autocvar_g_vehicle_fastcar_cannon_turnlimit_out;

float autocvar_g_vehicle_fastcar_respawntime;

float autocvar_g_vehicle_fastcar_blowup_radius;
float autocvar_g_vehicle_fastcar_blowup_coredamage;
float autocvar_g_vehicle_fastcar_blowup_edgedamage;
float autocvar_g_vehicle_fastcar_blowup_forceintensity;

float autocvar_g_vehicle_fastcar_bouncefactor;
float autocvar_g_vehicle_fastcar_bouncestop;
vector autocvar_g_vehicle_fastcar_bouncepain;

var float autocvar_g_vehicle_fastcar = 0;
var vector fastcar_force_from_tag(string tag_name, float spring_length, float max_power);


void fastcar_align4point(float _delta)
{	
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = fastcar_force_from_tag("tag_engine_fr", autocvar_g_vehicle_fastcar_springlength, autocvar_g_vehicle_fastcar_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_fastcar_collision_multiplier);

    push_vector += fastcar_force_from_tag("tag_engine_fl", autocvar_g_vehicle_fastcar_springlength, autocvar_g_vehicle_fastcar_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_fastcar_collision_multiplier);

    push_vector += fastcar_force_from_tag("tag_engine_br", autocvar_g_vehicle_fastcar_springlength, autocvar_g_vehicle_fastcar_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_fastcar_collision_multiplier);

    push_vector += fastcar_force_from_tag("tag_engine_bl", autocvar_g_vehicle_fastcar_springlength, autocvar_g_vehicle_fastcar_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_fastcar_collision_multiplier);
   self.velocity += push_vector * _delta;
    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_fastcar_upforcedamper * _delta;

    push_vector_x =  (fl_push - bl_push);
    push_vector_x += (fr_push - br_push);
    push_vector_x *= 360;

    push_vector_z = (fr_push - fl_push);
    push_vector_z += (br_push - bl_push);
    push_vector_z *= 360;

    // Apply angle diffrance
    self.angles_z += push_vector_z * _delta;
    self.angles_x += push_vector_x * _delta;

    // Apply stabilizer
    self.angles_x *= 1 - (autocvar_g_vehicle_fastcar_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_fastcar_anglestabilizer * _delta);
}


float fastcar_gunner_frame()
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
		_in = autocvar_g_vehicle_fastcar_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_fastcar_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_fastcar_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_fastcar_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;

	if(autocvar_g_vehicle_fastcar_cannon_lock)
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
			impact_time = distance / autocvar_g_vehicle_fastcar_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_fastcar_cannon_pitchlimit_down * -1, autocvar_g_vehicle_fastcar_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_fastcar_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_fastcar_cannon_pitchlimit_down * -1, autocvar_g_vehicle_fastcar_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_fastcar_cannon_turnspeed);

	
  }

	VEHICLE_UPDATE_PLAYER(gunner, health, fastcar);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, fastcar);

  if not (autocvar_g_vehicles_noauxaimforpassengervehic) {
	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));

  }

	vehic.solid = SOLID_BBOX;
	if (vehicles_allowdriveby(0, gunner, autocvar_g_vehicles_allowdriveby_pssngr_hudnorm, 1)) {
		//Do nothing
		gunner.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, gun, gunner);
		gunner.BUTTON_CROUCH = 0;
	} else {
		gunner.vehicle_allowdriveby = 0;
		gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	}
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_fastcar_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void fastcar_gunner_exit(float _exitflag)
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

float fastcar_gunner_enter(float selectgun)
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
	_gun.vehicle_exit  = fastcar_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= fastcar_gunner_enter;
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
	other.PlayerPhysplug    = fastcar_gunner_frame;
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

float fastcarvehicles_valid_pilot()
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

void fastcar_touch()
{

	if((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world))
	{
		vehicles_touch();
		return;
	}

	if(fastcarvehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(fastcar_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void fastcar_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_fastcar_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_fastcar_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_fastcar_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_fastcar_shield, autocvar_g_vehicle_fastcar_shield_regen_pause, autocvar_g_vehicle_fastcar_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_fastcar_health, autocvar_g_vehicle_fastcar_health_regen_pause, autocvar_g_vehicle_fastcar_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_fastcar_energy, autocvar_g_vehicle_fastcar_energy_regen_pause, autocvar_g_vehicle_fastcar_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

float fastcar_pilot_frame()
{
    entity pilot, vehic;
    vector df;
    float ftmp;
	
	if(intermission_running)
		return 1;

    pilot = self;
    vehic = self.vehicle;
    self   = vehic;

    pilot.BUTTON_ZOOM = pilot.BUTTON_CROUCH = 0;

    vehicles_painframe();

    if(vehic.deadflag != DEAD_NO)
    {
        self = pilot;
        pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
        return 1;
    }
    
    //fastcar_regen();

    fastcar_align4point(frametime);

    crosshair_trace(pilot);

    vehic.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_fastcar_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(pilot.v_angle_y - vehic.angles_y, vehic.angles_y), ftmp);
    vehic.angles_y = anglemods(vehic.angles_y + ftmp);

    // Roll
    vehic.angles_z += -ftmp * autocvar_g_vehicle_fastcar_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_fastcar_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(pilot.v_angle_x - vehic.angles_x, vehic.angles_x), ftmp);
    vehic.angles_x = bound(-30, anglemods(vehic.angles_x + ftmp), 30);

    makevectors(vehic.angles);
    vehic.angles_x *= -1;

    //ftmp = vehic.velocity_z;
    df = vehic.velocity * -autocvar_g_vehicle_fastcar_friction;
    //vehic.velocity_z = ftmp;

    if(vlen(pilot.movement) != 0)
    {
        if(pilot.movement_x)
            df += v_forward * ((pilot.movement_x > 0) ? autocvar_g_vehicle_fastcar_speed_forward : -autocvar_g_vehicle_fastcar_speed_forward);

        if(pilot.movement_y)
            df += v_right * ((pilot.movement_y > 0) ? autocvar_g_vehicle_fastcar_speed_strafe : -autocvar_g_vehicle_fastcar_speed_strafe);

        if(self.sound_nexttime < time || self.sounds != 1)
        {
            self.sounds = 1;
            self.sound_nexttime = time + 10.922667; //soundlength("vehicles/racer_move.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_move.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        if(self.sound_nexttime < time || self.sounds != 0)
        {
            self.sounds = 0;
            self.sound_nexttime = time + 11.888604; //soundlength("vehicles/racer_idle.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }

    // Afterburn
    if (pilot.BUTTON_JUMP && vehic.vehicle_energy >= (autocvar_g_vehicle_fastcar_afterburn_cost * frametime))
    {
        if(time - vehic.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        vehic.wait = time;
        vehic.vehicle_energy -= autocvar_g_vehicle_fastcar_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_fastcar_speed_afterburn);

        if(vehic.invincible_finished < time)
        {
            traceline(vehic.origin, vehic.origin - '0 0 256', MOVE_NORMAL, self);
            if(trace_fraction != 1.0)
                pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

            vehic.invincible_finished = time + 0.1 + (random() * 0.1);
        }

        if(vehic.strength_finished < time)
        {
            vehic.strength_finished = time + 10.922667; //soundlength("vehicles/racer_boost.wav");
            sound (vehic.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        vehic.strength_finished = 0;
        sound (vehic.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);
    }

	df -= v_up * (vlen(vehic.velocity) * autocvar_g_vehicle_fastcar_downforce);
    	df = vehicles_waterspeed(pilot, df);
	vehic.velocity = vehicles_waterfriction(pilot, vehic, vehic.velocity);
    pilot.movement = vehic.velocity += df * frametime;

//Weapons removed
   

    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_fastcar_shield, autocvar_g_vehicle_fastcar_shield_regen_pause, autocvar_g_vehicle_fastcar_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_fastcar_health, autocvar_g_vehicle_fastcar_health_regen_pause, autocvar_g_vehicle_fastcar_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_fastcar_energy, autocvar_g_vehicle_fastcar_energy_regen_pause, autocvar_g_vehicle_fastcar_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(pilot, health, fastcar);
    VEHICLE_UPDATE_PLAYER(pilot, energy, fastcar);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, fastcar);

    if (vehicles_allowdriveby(1, pilot, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 1)) {
		//Do nothing
		pilot.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, vehic, pilot);
    } else {
		pilot.vehicle_allowdriveby = 0;
    		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
    }
    
    setorigin(pilot,vehic.origin + '0 0 32');
    pilot.velocity = vehic.velocity;
	
	self = pilot;

	return 1;
}

void fastcar_think()
{
	self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_fastcar_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_fastcar_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_fastcar_hoverpower + sin(time * 2) * (autocvar_g_vehicle_fastcar_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_fastcar_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_fastcar_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_fastcar_anglestabilizer * pushdeltatime);
	
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

void fastcar_enter()
{
	self.touch = fastcar_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCE;
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void fastcar_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = fastcar_think;
	self.nextthink = time;
	
	if(!self.owner)
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

void fastcar_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_fastcar_blowup_coredamage,
				 autocvar_g_vehicle_fastcar_blowup_edgedamage,
				 autocvar_g_vehicle_fastcar_blowup_radius, self,
				 autocvar_g_vehicle_fastcar_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void fastcar_diethink()
{
	if(time >= self.wait)
		self.think = fastcar_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void fastcar_die()
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
		_body.touch = fastcar_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 0.5;
	_body.think = fastcar_diethink;
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

void fastcar_impact()
{
    if(autocvar_g_vehicle_fastcar_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_fastcar_bouncepain_x, 
						autocvar_g_vehicle_fastcar_bouncepain_y, 
						autocvar_g_vehicle_fastcar_bouncepain_z);
}

void fastcar_spawn(float _f)
{
   self.vehicle_pilotchangeseat = fastcar_gunner_enter; //Function to exec if pilot wants to change seat

	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
	if(!self.gun1)
	{
		//self.loddistance1 = 32; //Lod0 Model quite complex, so only use when very close
		self.loddistance1 = 256; 
		self.lodmodel1 = "models/vehicles/fastcar_lod1.iqm";
		
		self.loddistance2 = 512; 
		self.lodmodel2 = "models/vehicles/fastcar_lod2.iqm";
		
		self.loddistance3 = 2048; 
		self.lodmodel3 = "models/vehicles/fastcar_lod3.iqm";
		
    		InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
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

		self.gun1 = spawn();

		self.vehicle_flags |= VHF_MULTISLOT;

		self.gun1.owner = self;

		setmodel(self.gun1, "null");
		
		//Old:
		//setattachment(self.gun1, self, "tag_pass1");
		//vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "null", fastcar_gunner_frame, fastcar_gunner_exit);
	
		//Instead so we can use the cockpit without having an offset
		setattachment(self.gun1, self, "null");
		vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "models/vehicles/fastcar_interior.iqm", fastcar_gunner_frame, fastcar_gunner_exit);
		self.gun1.vehicle_viewport.origin = '0 -32 80';
	}
	
	if(self.scale != 0.5)
	{
	        if(autocvar_g_vehicle_fastcar_hovertype != 0)
	            fastcar_force_from_tag = vehicles_force_fromtag_maglev;
	        else
	            fastcar_force_from_tag = vehicles_force_fromtag_hover;
	
        	// FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        	self.scale = 0.5;
        	setattachment(self.vehicle_hudmodel, self, "");
	        setattachment(self.vehicle_viewport, self, "tag_viewport");

        	self.mass               = autocvar_g_vehicle_fastcar_mass;
	}
	
	self.think          = fastcar_think;
        self.nextthink      = time;

	self.vehicle_health = autocvar_g_vehicle_fastcar_health;
	self.vehicle_shield = autocvar_g_vehicle_fastcar_shield;
	self.movetype       = MOVETYPE_TOSS;
    	self.solid          = SOLID_SLIDEBOX;
	self.delay          = time;
	self.vehicle_impact = fastcar_impact;
	
	self.scale          = 0.5;

    setsize(self, FASTCAR_MIN * 0.5, FASTCAR_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_fastcar_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_fastcar_bouncestop;
    self.damageforcescale = 0.5;
    //self.destvec = autocvar_g_vehicle_fastcar_bouncepain;
	
}

void spawnfunc_vehicle_fastcar()
{
	if(!autocvar_g_vehicle_fastcar)
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
	
	precache_sound ("vehicles/racer_idle.wav");
   	precache_sound ("vehicles/racer_move.wav");
    	precache_sound ("vehicles/racer_boost.wav");
	precache_sound ( "weapons/rocket_impact.wav");

    	precache_model ("models/vhshield.md3");
		
	precache_model("models/vehicles/fastcar.iqm");
	precache_model("models/vehicles/fastcar_lod1.iqm");
	precache_model("models/vehicles/fastcar_lod2.iqm");
	precache_model("models/vehicles/fastcar_lod3.iqm");

	precache_model("models/vehicles/fastcar_interior.iqm");

	if(autocvar_g_vehicle_fastcar_energy)
		if(autocvar_g_vehicle_fastcar_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_fastcar_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_fastcar_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_fastcar_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1211;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "FastCar",
			   "models/vehicles/fastcar.iqm",
			   "null", // we need this so tur_head is networked and usable for sounds
			   "models/vehicles/fastcar_interior.iqm", 
			   "", "", "tag_viewport",
			   HUD_WAKIZASHI, 
           		   0.5 * FASTCAR_MIN, 0.5 * FASTCAR_MAX,
			   FALSE,
			   fastcar_spawn, autocvar_g_vehicle_fastcar_respawntime,
			   fastcar_pilot_frame, fastcar_enter, fastcar_exit,
			   fastcar_die, fastcar_think, FALSE, autocvar_g_vehicle_fastcar_health, autocvar_g_vehicle_fastcar_shield, autocolor, 0, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}
#endif // SVQC

#ifdef CSQC
void fastcar_draw()
{

}

void fastcar_draw2d()
{

}

void fastcar_read_extra()
{

}

void vehicle_fastcar_assemble()
{

}
#endif //CSQC
