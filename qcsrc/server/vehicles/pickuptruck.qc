#define PICKUPTRUCK_MIN '-120 -120 0'
#define PICKUPTRUCK_MAX '120 120 100'

#define PICKUPTRUCK_SETUP 2
#define PICKUPTRUCK_START 4
#define PICKUPTRUCK_END 8

#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P
//.entity gunner3;

// Auto cvars
float autocvar_g_vehicle_pickuptruck_mass;
float autocvar_g_vehicle_pickuptruck_speed_forward;
float autocvar_g_vehicle_pickuptruck_speed_strafe;

float autocvar_g_vehicle_pickuptruck_speed_afterburn;
float autocvar_g_vehicle_pickuptruck_afterburn_cost;

float autocvar_g_vehicle_pickuptruck_anglestabilizer;
float autocvar_g_vehicle_pickuptruck_downforce;

float autocvar_g_vehicle_pickuptruck_speed_forward;
float autocvar_g_vehicle_pickuptruck_speed_strafe;
float autocvar_g_vehicle_pickuptruck_springlength;
float autocvar_g_vehicle_pickuptruck_upforcedamper;
float autocvar_g_vehicle_pickuptruck_friction;

float autocvar_g_vehicle_pickuptruck_hovertype;
float autocvar_g_vehicle_pickuptruck_hoverpower;

float autocvar_g_vehicle_pickuptruck_turnroll;
float autocvar_g_vehicle_pickuptruck_turnspeed;
float autocvar_g_vehicle_pickuptruck_pitchspeed;

float autocvar_g_vehicle_pickuptruck_energy;
float autocvar_g_vehicle_pickuptruck_energy_regen;
float autocvar_g_vehicle_pickuptruck_energy_regen_pause;

float autocvar_g_vehicle_pickuptruck_health;
float autocvar_g_vehicle_pickuptruck_health_regen;
float autocvar_g_vehicle_pickuptruck_health_regen_pause;

float autocvar_g_vehicle_pickuptruck_shield;
float autocvar_g_vehicle_pickuptruck_shield_regen;
float autocvar_g_vehicle_pickuptruck_shield_regen_pause;

float autocvar_g_vehicle_pickuptruck_cannon_speed;

float autocvar_g_vehicle_pickuptruck_cannon_ammo;
float autocvar_g_vehicle_pickuptruck_cannon_ammo_regen;
float autocvar_g_vehicle_pickuptruck_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_pickuptruck_cannon_lock = 0;

float autocvar_g_vehicle_pickuptruck_cannon_turnspeed;
float autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_down;
float autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_up;
float autocvar_g_vehicle_pickuptruck_cannon_turnlimit_in;
float autocvar_g_vehicle_pickuptruck_cannon_turnlimit_out;

float autocvar_g_vehicle_pickuptruck_respawntime;

float autocvar_g_vehicle_pickuptruck_blowup_radius;
float autocvar_g_vehicle_pickuptruck_blowup_coredamage;
float autocvar_g_vehicle_pickuptruck_blowup_edgedamage;
float autocvar_g_vehicle_pickuptruck_blowup_forceintensity;

float autocvar_g_vehicle_pickuptruck_bouncefactor;
float autocvar_g_vehicle_pickuptruck_bouncestop;
vector autocvar_g_vehicle_pickuptruck_bouncepain;

var float autocvar_g_vehicle_pickuptruck = 0;
var vector pickuptruck_force_from_tag(string tag_name, float spring_length, float max_power);



void pickuptruck_align4point(float _delta)
{	
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = pickuptruck_force_from_tag("tag_engine_fr", autocvar_g_vehicle_pickuptruck_springlength, autocvar_g_vehicle_pickuptruck_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_pickuptruck_collision_multiplier);

    push_vector += pickuptruck_force_from_tag("tag_engine_fl", autocvar_g_vehicle_pickuptruck_springlength, autocvar_g_vehicle_pickuptruck_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_pickuptruck_collision_multiplier);

    push_vector += pickuptruck_force_from_tag("tag_engine_br", autocvar_g_vehicle_pickuptruck_springlength, autocvar_g_vehicle_pickuptruck_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_pickuptruck_collision_multiplier);

    push_vector += pickuptruck_force_from_tag("tag_engine_bl", autocvar_g_vehicle_pickuptruck_springlength, autocvar_g_vehicle_pickuptruck_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_pickuptruck_collision_multiplier);
   self.velocity += push_vector * _delta;
    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_pickuptruck_upforcedamper * _delta;

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
    self.angles_x *= 1 - (autocvar_g_vehicle_pickuptruck_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_pickuptruck_anglestabilizer * _delta);
}


float pickuptruck_gunner_frame()
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
		_in = autocvar_g_vehicle_pickuptruck_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_pickuptruck_cannon_turnlimit_out;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		_in = autocvar_g_vehicle_pickuptruck_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_pickuptruck_cannon_turnlimit_in;
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;

	if(autocvar_g_vehicle_pickuptruck_cannon_lock)
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
			impact_time = distance / autocvar_g_vehicle_pickuptruck_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_down * -1, autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_pickuptruck_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_down * -1, autocvar_g_vehicle_pickuptruck_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_pickuptruck_cannon_turnspeed);

	
  }

	VEHICLE_UPDATE_PLAYER(gunner, health, pickuptruck);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, pickuptruck);

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
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_pickuptruck_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void pickuptruck_gunner_exit(float _exitflag)
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
		dprint("^1self != gunner1 or gunner2,3,4,5, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 128 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float pickuptruck_gunner_enter(float selectgun)
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
	_gun.vehicle_exit  = pickuptruck_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= pickuptruck_gunner_enter;
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
	other.PlayerPhysplug    = pickuptruck_gunner_frame;
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

float pickuptruckvehicles_valid_pilot()
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

void pickuptruck_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world))
	{
		vehicles_touch();
		return;
	}

	if(pickuptruckvehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(pickuptruck_gunner_enter(0))
				return;

		if(self.gun2.phase <= time)
			if(pickuptruck_gunner_enter(0))
				return;
				
		if(self.gun3.phase <= time)
			if(pickuptruck_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void pickuptruck_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_pickuptruck_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_pickuptruck_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_pickuptruck_cannon_ammo_regen * frametime);

	if(self.gun2.delay + autocvar_g_vehicle_pickuptruck_cannon_ammo_regen_pause < time)
		self.gun2.vehicle_energy = min(autocvar_g_vehicle_pickuptruck_cannon_ammo,
									   self.gun2.vehicle_energy + autocvar_g_vehicle_pickuptruck_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_pickuptruck_shield, autocvar_g_vehicle_pickuptruck_shield_regen_pause, autocvar_g_vehicle_pickuptruck_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_pickuptruck_health, autocvar_g_vehicle_pickuptruck_health_regen_pause, autocvar_g_vehicle_pickuptruck_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_pickuptruck_energy, autocvar_g_vehicle_pickuptruck_energy_regen_pause, autocvar_g_vehicle_pickuptruck_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

void pickuptruck_minigun(entity gun, entity pilot, entity gunmount, entity mggun1)
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

void pickuptruck_hmg(entity gun, entity pilot, entity gunmount)
{
   
   if(
   ((pilot.BUTTON_ATCK) && !(gun.spawnflags & 128))
   || ((pilot.BUTTON_ATCK2) && (gun.spawnflags & 128))
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


float pickuptruck_pilot_frame()
{
    entity pilot, vehic;
    vector df;
    float ftmp;
	
	if(intermission_running)
		return 1;

    pilot = self;
    vehic = self.vehicle;
    self   = vehic;

    pilot.BUTTON_ZOOM = 0;

    vehicles_painframe();

    if(vehic.deadflag != DEAD_NO)
    {
        self = pilot;
        pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
        return 1;
    }
    
    //pickuptruck_regen();

    pickuptruck_align4point(frametime);

    crosshair_trace(pilot);

    vehic.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_pickuptruck_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(pilot.v_angle_y - vehic.angles_y, vehic.angles_y), ftmp);
    vehic.angles_y = anglemods(vehic.angles_y + ftmp);

    // Roll
    vehic.angles_z += -ftmp * autocvar_g_vehicle_pickuptruck_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_pickuptruck_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(pilot.v_angle_x - vehic.angles_x, vehic.angles_x), ftmp);
    vehic.angles_x = bound(-30, anglemods(vehic.angles_x + ftmp), 30);

    makevectors(vehic.angles);
    vehic.angles_x *= -1;

    //ftmp = vehic.velocity_z;
    df = vehic.velocity * -autocvar_g_vehicle_pickuptruck_friction;
    //vehic.velocity_z = ftmp;

    if(vlen(pilot.movement) != 0)
    {
        if(pilot.movement_x)
            df += v_forward * ((pilot.movement_x > 0) ? autocvar_g_vehicle_pickuptruck_speed_forward : -autocvar_g_vehicle_pickuptruck_speed_forward);

        if(pilot.movement_y)
            df += v_right * ((pilot.movement_y > 0) ? autocvar_g_vehicle_pickuptruck_speed_strafe : -autocvar_g_vehicle_pickuptruck_speed_strafe);

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
    if (pilot.BUTTON_JUMP && vehic.vehicle_energy >= (autocvar_g_vehicle_pickuptruck_afterburn_cost * frametime))
    {
        if(time - vehic.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        vehic.wait = time;
        vehic.vehicle_energy -= autocvar_g_vehicle_pickuptruck_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_pickuptruck_speed_afterburn);

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

	df -= v_up * (vlen(vehic.velocity) * autocvar_g_vehicle_pickuptruck_downforce);
	df = vehicles_waterspeed(pilot, df);
	vehic.velocity = vehicles_waterfriction(pilot, vehic, vehic.velocity);
    pilot.movement = vehic.velocity += df * frametime;

    //Weapons
    if (vehic.spawnflags >= 64) {
    	if (self.spawnflags & 128) {
    	pickuptruck_minigun(vehic, pilot, vehic.bomb3, vehic.bomb3.gun1);
	}
	
	if (vehic.spawnflags & 64) {
	pickuptruck_hmg(vehic, pilot, vehic.bomb5);
	}
	
	if (vehic.spawnflags & 256) {
	pickuptruck_hmg(vehic, pilot, vehic.bomb6);
	pickuptruck_hmg(vehic, pilot, vehic.bomb7);
	}
	
	if (self.spawnflags & 512) {
    	pickuptruck_minigun(vehic, pilot, vehic.bomb4, vehic.bomb4.gun1);
	pickuptruck_minigun(vehic, pilot, vehic.bomb8, vehic.bomb8.gun1);
	}
	
	if ((self.spawnflags & 128) || (self.spawnflags & 512)) {
		if(pilot.BUTTON_HOOK) {
			pilot.BUTTON_JUMP   = 0;
    			pilot.BUTTON_CROUCH    = 0;
    			//pilot.BUTTON_HOOK    = 0; //Na don't set this, we need it for paintjobs at colormod
		}
	}
    }
    
    pilot.BUTTON_CROUCH = 0;
   

    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_pickuptruck_shield, autocvar_g_vehicle_pickuptruck_shield_regen_pause, autocvar_g_vehicle_pickuptruck_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_pickuptruck_health, autocvar_g_vehicle_pickuptruck_health_regen_pause, autocvar_g_vehicle_pickuptruck_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_pickuptruck_energy, autocvar_g_vehicle_pickuptruck_energy_regen_pause, autocvar_g_vehicle_pickuptruck_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(pilot, health, pickuptruck);
    VEHICLE_UPDATE_PLAYER(pilot, energy, pickuptruck);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, pickuptruck);

    
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

void pickuptruck_think()
{
	self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_pickuptruck_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_pickuptruck_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_pickuptruck_hoverpower + sin(time * 2) * (autocvar_g_vehicle_pickuptruck_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_pickuptruck_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_pickuptruck_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_pickuptruck_anglestabilizer * pushdeltatime);
	
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

void pickuptruck_enter()
{
	self.touch = pickuptruck_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCE;
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void pickuptruck_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = pickuptruck_think;
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

void pickuptruck_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_pickuptruck_blowup_coredamage,
				 autocvar_g_vehicle_pickuptruck_blowup_edgedamage,
				 autocvar_g_vehicle_pickuptruck_blowup_radius, self,
				 autocvar_g_vehicle_pickuptruck_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void pickuptruck_diethink()
{
	if(time >= self.wait)
		self.think = pickuptruck_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void pickuptruck_die()
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
	vehicle_tossgib(self.gun2, self.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = pickuptruck_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 0.5;
	_body.think = pickuptruck_diethink;
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

void pickuptruck_impact()
{
    if(autocvar_g_vehicle_pickuptruck_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_pickuptruck_bouncepain_x, 
						autocvar_g_vehicle_pickuptruck_bouncepain_y, 
						autocvar_g_vehicle_pickuptruck_bouncepain_z);
}

void pickuptruck_spawn(float _f)
{
   self.vehicle_pilotchangeseat = pickuptruck_gunner_enter; //Function to exec if pilot wants to change seat

	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
	if(!self.gun1)
	{
		self.lodmodel1 = "models/vehicles/pickuptruck_lod1.iqm";
		self.lodmodel2 = "models/vehicles/pickuptruck_lod2.iqm";
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
		self.gun2 = spawn();
		self.gun3 = spawn();

		self.vehicle_flags |= VHF_MULTISLOT;

		self.gun1.owner = self;
		self.gun2.owner = self;
		self.gun3.owner = self;

		setmodel(self.gun1, "null");
		setmodel(self.gun2, "null");
		setmodel(self.gun3, "null");

		setattachment(self.gun1, self, "tag_pass1");
		setattachment(self.gun2, self, "tag_pass2");
		setattachment(self.gun3, self, "tag_pass3");
		
		vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "null", pickuptruck_gunner_frame, pickuptruck_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_WAKIZASHI, "null", pickuptruck_gunner_frame, pickuptruck_gunner_exit);
		vehicle_addplayerslot(self, self.gun3, HUD_WAKIZASHI, "null", pickuptruck_gunner_frame, pickuptruck_gunner_exit);
		
		if (self.spawnflags & 64) {
			//.50 Left Stuff
			self.bomb5 = spawn();
			setmodel(self.bomb5,"models/mountedguns/browning50gun.iqm");
			setattachment(self.bomb5, self, "tag_gunmount_top");
			
				//LOD stuff.
				self.bomb5.owner = self;
				self.bomb5.lodowner = 1; //Use owner origin for computing LOD
				self.bomb5.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
				self.bomb5.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
				InitializeEntity(self.bomb5, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end	
		}
		
		if (self.spawnflags & 128) {
			//.50 Minigun Left Stuff
			self.bomb3 = spawn();
			setmodel(self.bomb3,"models/mountedguns/gau19gun.iqm");
			
			if (self.spawnflags & 64) {
				setattachment(self.bomb3, self, "tag_gunmount_topup");
			} else {
				setattachment(self.bomb3, self, "tag_gunmount_top");
			}
			
				//LOD stuff.
				self.bomb3.owner = self;
				self.bomb3.lodowner = 1; //Use owner origin for computing LOD
				self.bomb3.lodmodel1 = "models/mountedguns/gau19gun_lod1.iqm";
				self.bomb3.lodmodel2 = "models/mountedguns/gau19gun_lod2.iqm";
				InitializeEntity(self.bomb3, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end	
	
			//.50 Minugun Left Barrels
			self.bomb3.gun1 = spawn();
			setmodel(self.bomb3.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb3.gun1, self.bomb3, "tag_axis");
			self.bomb3.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
		}
		
		
		if (self.spawnflags & 256) {
			//.50 Left Stuff
			self.bomb6 = spawn();
			setmodel(self.bomb6,"models/mountedguns/browning50gun.iqm");
			setattachment(self.bomb6, self, "tag_minigun3");
			
			self.bomb7 = spawn();
			setmodel(self.bomb7,"models/mountedguns/browning50gun.iqm");
			setattachment(self.bomb7, self, "tag_minigun4");
			
				//LOD stuff.
				self.bomb6.owner = self;
				self.bomb6.lodowner = 1; //Use owner origin for computing LOD
				self.bomb6.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
				self.bomb6.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
				InitializeEntity(self.bomb6, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end	
		}
		
		if (self.spawnflags & 512) {
			//.50 Minigun Left Stuff
			self.bomb4 = spawn();
			setmodel(self.bomb4,"models/mountedguns/gau19gun.iqm");
			
			setattachment(self.bomb4, self, "tag_minigun1");
			
	
			//.50 Minugun Left Barrels
			self.bomb4.gun1 = spawn();
			setmodel(self.bomb4.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb4.gun1, self.bomb4, "tag_axis");
			self.bomb4.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
			
			//.50 Minigun Left Stuff
			self.bomb8 = spawn();
			setmodel(self.bomb8,"models/mountedguns/gau19gun.iqm");
			
			setattachment(self.bomb8, self, "tag_minigun2");
			
	
			//.50 Minugun Left Barrels
			self.bomb8.gun1 = spawn();
			setmodel(self.bomb8.gun1,"models/mountedguns/gau19gun_barrels.iqm");
			setattachment(self.bomb8.gun1, self.bomb8, "tag_axis");
			self.bomb8.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
			
				//LOD stuff.
				self.bomb8.owner = self.bomb4.owner = self;
				self.bomb8.lodowner = self.bomb4.lodowner = 1; //Use owner origin for computing LOD
				self.bomb8.lodmodel1 = self.bomb4.lodmodel1 = "models/mountedguns/gau19gun_lod1.iqm";
				self.bomb8.lodmodel2 = self.bomb4.lodmodel2 = "models/mountedguns/gau19gun_lod2.iqm";
				InitializeEntity(self.bomb4, LODmodel_attach, INITPRIO_FINDTARGET);
				InitializeEntity(self.bomb8, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end	
		}
	}
	
	if(self.scale != 0.5)
	{
	        if(autocvar_g_vehicle_pickuptruck_hovertype != 0)
	            pickuptruck_force_from_tag = vehicles_force_fromtag_maglev;
	        else
	            pickuptruck_force_from_tag = vehicles_force_fromtag_hover;
	
        	// FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        	self.scale = 0.5;
        	setattachment(self.vehicle_hudmodel, self, "");
	        setattachment(self.vehicle_viewport, self, "tag_viewport");

        	self.mass               = autocvar_g_vehicle_pickuptruck_mass;
	}
	
	self.think          = pickuptruck_think;
        self.nextthink      = time;
	self.vehicle_ammo1_current = self.vehicle_ammo1_max;
	self.vehicle_ammo2_current = self.vehicle_ammo2_max;
	self.vehicle_health = autocvar_g_vehicle_pickuptruck_health;
	self.vehicle_shield = autocvar_g_vehicle_pickuptruck_shield;
	self.movetype       = MOVETYPE_TOSS;
    	self.solid          = SOLID_SLIDEBOX;
	self.delay          = time;
	self.vehicle_impact = pickuptruck_impact;
	
	self.scale          = 0.5;

    setsize(self, PICKUPTRUCK_MIN * 0.5, PICKUPTRUCK_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_pickuptruck_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_pickuptruck_bouncestop;
    self.damageforcescale = 0.5;
    //self.destvec = autocvar_g_vehicle_pickuptruck_bouncepain;
	
}

void spawnfunc_vehicle_pickuptruck()
{
	if(!autocvar_g_vehicle_pickuptruck)
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
	
	precache_model("models/vehicles/pickuptruck.iqm");
	precache_model("models/vehicles/pickuptruck_lod1.iqm");
	precache_model("models/vehicles/pickuptruck_lod2.iqm");
	
	float caammomax;
	
	if (self.spawnflags >= 64) {
		if ((self.spawnflags & 64) || (self.spawnflags & 256)) {
			precache_model ( "models/mountedguns/browning50gun.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod1.iqm");
			precache_model ( "models/mountedguns/browning50gun_lod2.iqm");
			precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		}
		
		if ((self.spawnflags & 128) || (self.spawnflags & 512)) {
			precache_model ( "models/mountedguns/gau19gun.iqm");
			precache_model ( "models/mountedguns/gau19gun_lod1.iqm");
			precache_model ( "models/mountedguns/gau19gun_lod2.iqm");
			precache_model ( "models/mountedguns/gau19gun_barrels.iqm");
			precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		}
		
		precache_model ( "models/uziflash.md3");
		caammomax = autocvar_g_vehicle_mg_m134_machinegun_ammo_max * 2;
	} else {
		caammomax = 0;
	}
	

	if(autocvar_g_vehicle_pickuptruck_energy)
		if(autocvar_g_vehicle_pickuptruck_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_pickuptruck_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_pickuptruck_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_pickuptruck_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1195;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "PickupTruck",
			   "models/vehicles/pickuptruck.iqm",
			   "null", // we need this so tur_head is networked and usable for sounds
			   "null", 
			   "", "", "tag_viewport",
			   HUD_WAKIZASHI, 
           		   0.5 * PICKUPTRUCK_MIN, 0.5 * PICKUPTRUCK_MAX,
			   FALSE,
			   pickuptruck_spawn, autocvar_g_vehicle_pickuptruck_respawntime,
			   pickuptruck_pilot_frame, pickuptruck_enter, pickuptruck_exit,
			   pickuptruck_die, pickuptruck_think, FALSE, autocvar_g_vehicle_pickuptruck_health, autocvar_g_vehicle_pickuptruck_shield, autocolor, caammomax, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}

void spawnfunc_vehicle_pickuptruck_milspec()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 64; //So we spawn weapons
	}
	
	if not(self.colormap >= 1023) {
		self.colormap = 1023; //Black
	}
		
	spawnfunc_vehicle_pickuptruck();
}
#endif // SVQC

#ifdef CSQC
void pickuptruck_draw()
{

}

void pickuptruck_draw2d()
{

}

void pickuptruck_read_extra()
{

}

void vehicle_pickuptruck_assemble()
{

}
#endif //CSQC
