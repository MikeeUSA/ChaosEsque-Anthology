#define LIGHTAPC_MIN '-120 -120 0'
#define LIGHTAPC_MAX '120 120 250'

const vector LIGHTAPC_MIN_HBB = '-120 -120 0'; //Middle
const vector LIGHTAPC_MAX_HBB = '120 120 250';

#define LIGHTAPC_SETUP 2
#define LIGHTAPC_START 4
#define LIGHTAPC_END 8

#ifdef SVQC
//Many thanks to taniwha of #qc on anynet for help debugging
//Even more thanks to tZork for making the code in the first place :P
.entity gun6;
.entity gun7;
.entity gun8;
.entity gun9;
.entity gunner6;
.entity gunner7;
.entity gunner8;
.entity gunner9;

// Auto cvars
float autocvar_g_vehicle_lightapc_mass;
float autocvar_g_vehicle_lightapc_speed_forward;

float autocvar_g_vehicle_lightapc_speed_forward;

float autocvar_g_vehicle_lightapc_hovertype;

float autocvar_g_vehicle_lightapc_energy;
float autocvar_g_vehicle_lightapc_energy_regen;
float autocvar_g_vehicle_lightapc_energy_regen_pause;

float autocvar_g_vehicle_lightapc_health;
float autocvar_g_vehicle_lightapc_health_regen;
float autocvar_g_vehicle_lightapc_health_regen_pause;

float autocvar_g_vehicle_lightapc_shield;
float autocvar_g_vehicle_lightapc_shield_regen;
float autocvar_g_vehicle_lightapc_shield_regen_pause;

float autocvar_g_vehicle_lightapc_cannon_ammo;
float autocvar_g_vehicle_lightapc_cannon_ammo_regen;
float autocvar_g_vehicle_lightapc_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_lightapc_cannon_lock = 0;

float autocvar_g_vehicle_lightapc_cannon_turnspeed;
float autocvar_g_vehicle_lightapc_cannon_pitchlimit_down;
float autocvar_g_vehicle_lightapc_cannon_pitchlimit_up;
float autocvar_g_vehicle_lightapc_cannon_turnlimit_in;
float autocvar_g_vehicle_lightapc_cannon_turnlimit_out;

float autocvar_g_vehicle_lightapc_respawntime;

float autocvar_g_vehicle_lightapc_blowup_radius;
float autocvar_g_vehicle_lightapc_blowup_coredamage;
float autocvar_g_vehicle_lightapc_blowup_edgedamage;
float autocvar_g_vehicle_lightapc_blowup_forceintensity;

float autocvar_g_vehicle_lightapc_bouncefactor;
float autocvar_g_vehicle_lightapc_bouncestop;
vector autocvar_g_vehicle_lightapc_bouncepain;

var float autocvar_g_vehicle_lightapc = 0;
var vector lightapc_force_from_tag(string tag_name, float spring_length, float max_power);

void lightapc_autonex(entity gun, entity pilot, entity gunmount)
{
   
    if(pilot.BUTTON_ATCK)
    {
    	mg_autonex_fire(gun, pilot, gunmount);
    } else {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_grail_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
}

void lightapc_delugegun(entity gun, entity pilot, entity gunmount)
{
   	if(pilot.BUTTON_ATCK)
    	{
    		mg_deluge_fire(gun, pilot, gunmount);
    	} else {
    	    vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_deluge_machinegun_ammo_max,
    	                                       autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen_pause,
    	                                       autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    	}
}

float lightapc_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	entity turretmount;
	
	
	//Happended once that the world was giving solid_not
	//So we check now
	//Could not reproduce yet
	if (vehic == world) {
		print("!!!ERROR LIGHTAPC VEHIC IS WORLD!!!\n");
		return 1; //We'll return 1 for now...
	}
	
	if (gun == world) {
		print("!!!ERROR LIGHTAPC GUN IS WORLD!!!\n");
		return 1;
	}
	
	if (vehic == gunner) {
		print("!!!ERROR LIGHTAPC GUNNER IS WORLD!!!\n");
		return 1;
	}
	
	
	
	self = vehic;
	

	if((gun == vehic.gun1)) {
		turretmount = vehic.bomb5;
	} else {
		turretmount = vehic.bomb6;
	}
	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin);
	gunner.velocity = vehic.velocity;
	
	float _in, _out;
	vector ad;
  if not (autocvar_g_vehicles_noauxaimforpassengervehic && (!vehic.spawnflags)) {	
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	
	if (vehic.spawnflags == 1 || vehic.spawnflags == 2 || vehic.spawnflags == 4 || vehic.spawnflags == 5) {
		_in = autocvar_g_vehicle_lightapc_cannon_turnlimit_out;
		_out = autocvar_g_vehicle_lightapc_cannon_turnlimit_out;
	} else if (vehic.spawnflags == 6) {
		_in = 0;
		_out = 0; 
	} else {
		_in = autocvar_g_vehicle_lightapc_cannon_turnlimit_in;
		_out = autocvar_g_vehicle_lightapc_cannon_turnlimit_in;
	}
	
	crosshair_trace(gunner);
	vector _ct = trace_endpos;
	//vector ad;
	
	if ((gun == vehic.gun1) 
	|| (gun == vehic.gun2)) {
		if (vehic.vehicle_ammo1_max) {
    			gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    			gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
    		}
	
		if(gunner.movement_y != 0)
   	 	{
	 		if(turretmount.angles_y > 180)  turretmount.angles_y -= 360;
    			if(turretmount.angles_y < -180) turretmount.angles_y += 360;
			turretmount.angles_y = bound(-184,turretmount.angles_y + ((gunner.movement_y * sys_frametime) / -6.66666),184);	
		
			if(turretmount.angles_y >= -1 && turretmount.angles_y <= -1)
            			turretmount.angles_y = 0;	

			float degree_y;
			gunner.angles_y = gunner.angles_y + ((gunner.movement_y * sys_frametime) / -6.66666);
			degree_y = ((gunner.movement_y * sys_frametime) / -6.66666);
			gunner.v_angle_y += degree_y;
		
			//gunner.v_angle_y = turretmount.angles_y; //kiss
			
			if ((clienttype(gunner) == CLIENTTYPE_REAL)) {
				msg_entity = gunner;
  				WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  				WriteAngle( MSG_ONE, gunner.v_angle_x);
				WriteAngle( MSG_ONE, gunner.v_angle_y);
  				WriteAngle( MSG_ONE, gunner.v_angle_z);
			}
		}
	
	
	
	
		vehicle_aimturret2(vehic, turretmount, _ct, gun, "fire",
						  autocvar_g_vehicle_lightapc_cannon_pitchlimit_down * -1, autocvar_g_vehicle_lightapc_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_lightapc_cannon_turnspeed);

		local vector angvec;
		angvec = gettaginfo(gun, gettagindex(gun, "tag_camera"));
		traceline(angvec, angvec + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, gun);
		
		//Guns
		if (vehic.spawnflags == 1) {
			lightapc_delugegun(vehic, gunner, gun);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0.5 1 0.8', 0);	
		} else if (vehic.spawnflags == 2) {
			tankll48_shlac(vehic, gunner, gun);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '1 0 0', 0);	
		} else if (vehic.spawnflags == 3) {
			if(gunner.BUTTON_ATCK) gunner.BUTTON_ATCK2 = 1;
			tankll24_grail(vehic, gunner, gun);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '1 0 1', 0);	
		} else if (vehic.spawnflags == 4) {
			lightapc_autonex(vehic, gunner, gun);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 1 1', 0);	
		} else if (vehic.spawnflags == 5) {
			aerocommander_hmg2(vehic, gunner, gun);	
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);
		} else if (vehic.spawnflags == 6) {
			if(gunner.BUTTON_ATCK) gunner.BUTTON_ATCK2 = 1;
			tankll24_t17mm_fire(vehic, gunner, gun);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);	
		} else if (vehic.spawnflags == 7) {
			blackhawk_hvyminigun(vehic, gunner, gun, gun.gun1);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);
		} else if (vehic.spawnflags == 8) {
			blackhawk_minigun(vehic, gunner, gun, gun.gun1);
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);
		} else {
			UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);
		}
		

		if(vehic.owner)
			UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 0 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));
	
	}
	
	
  }

	
	VEHICLE_UPDATE_PLAYER(gunner, health, lightapc);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, lightapc);

  if not (autocvar_g_vehicles_noauxaimforpassengervehic && (!vehic.spawnflags)) {
	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);
  }

	//Removed xhair updating, only doing for 2 turrets.
	
	vehic.solid = SOLID_BBOX;
	if ((!vehic.spawnflags) && (gun == vehic.gun1)
	&& (vehicles_allowdriveby(0, gunner, autocvar_g_vehicles_allowdriveby_pssngr_hudnorm, 1))) {
		//Do nothing
		gunner.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, gun, gunner);
		gunner.BUTTON_CROUCH = 0;
	} else {
		gunner.vehicle_allowdriveby = 0;
		gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	}
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_lightapc_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void lightapc_gunner_exit(float _exitflag)
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
	else if(self == self.vehicle.owner.gunner10)
	{
		self.vehicle.owner.gunner10 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner11)
	{
		self.vehicle.owner.gunner11 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner12)
	{
		self.vehicle.owner.gunner12 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner13)
	{
		self.vehicle.owner.gunner13 = world;	
		v_right *= -1;
	}
	else
		dprint("^1self != gunner1 or gunner2,3,4,5,6,7,8,9,10,11,12,13 this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 128 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float lightapc_gunner_enter(float selectgun)
{
	local float myturnviewy;
	myturnviewy = 0; //Default don't turn view
	
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
		myturnviewy = -90;
	}
	else if(!self.gunner4 && (!selectgun || selectgun == 4))
	{
		_gun = self.gun4;
		_gunner = self.gunner4;
		self.gunner4 = other;
		myturnviewy = -90;
	}
	else if(!self.gunner5 && (!selectgun || selectgun == 5))
	{
		_gun = self.gun5;
		_gunner = self.gunner5;
		self.gunner5 = other;
		myturnviewy = 90;
	}
	else if(!self.gunner6 && (!selectgun || selectgun == 6))
	{
		_gun = self.gun6;
		_gunner = self.gunner6;
		self.gunner6 = other;
		myturnviewy = -90;
	}
	else if(!self.gunner7 && (!selectgun || selectgun == 7))
	{
		_gun = self.gun7;
		_gunner = self.gunner7;
		self.gunner7 = other;
		myturnviewy = -90;
	}
	else if(!self.gunner8 && (!selectgun || selectgun == 8))
	{
		_gun = self.gun8;
		_gunner = self.gunner8;
		self.gunner8 = other;
		myturnviewy = 90;
	}
	else if(!self.gunner9 && (!selectgun || selectgun == 9))
	{
		_gun = self.gun9;
		_gunner = self.gunner9;
		self.gunner9 = other;
		myturnviewy = -90;
	}
	else if(!self.gunner10 && (!selectgun || selectgun == 10))
	{
		_gun = self.gun10;
		_gunner = self.gunner10;
		self.gunner10 = other;
		myturnviewy = -90;
	}
	else if(!self.gunner11 && (!selectgun || selectgun == 11))
	{
		_gun = self.gun11;
		_gunner = self.gunner11;
		self.gunner11 = other;
		myturnviewy = 90;
	}
	else if(!self.gunner12 && (!selectgun || selectgun == 12))
	{
		_gun = self.gun12;
		_gunner = self.gunner12;
		self.gunner12 = other;
		myturnviewy = 90;
	}
	else if(!self.gunner13 && (!selectgun || selectgun == 13))
	{
		_gun = self.gun13;
		_gunner = self.gunner13;
		self.gunner13 = other;
		myturnviewy = 90;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = lightapc_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= lightapc_gunner_enter;
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
	other.PlayerPhysplug    = lightapc_gunner_frame;
	other.flags             &~= FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
	WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y + myturnviewy);    // yaw
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

float lightapcvehicles_valid_pilot()
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

void lightapc_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world && self.gunner5 != world && self.gunner6 != world && self.gunner7 != world && self.gunner8 != world && self.gunner9 != world && self.gunner10 != world && self.gunner11 != world && self.gunner12 != world && self.gunner13 != world))
	{
		vehicles_touch();
		return;
	}

	if(lightapcvehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(lightapc_gunner_enter(0))
				return;

		if(self.gun2.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun3.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
		
		if(self.gun4.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
		
		if(self.gun5.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
		
		if(self.gun6.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun7.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun8.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun9.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun10.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun11.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun12.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
				
		if(self.gun13.phase <= time)
			if(lightapc_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void lightapc_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_lightapc_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_lightapc_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_lightapc_cannon_ammo_regen * frametime);

	if(self.gun2.delay + autocvar_g_vehicle_lightapc_cannon_ammo_regen_pause < time)
		self.gun2.vehicle_energy = min(autocvar_g_vehicle_lightapc_cannon_ammo,
									   self.gun2.vehicle_energy + autocvar_g_vehicle_lightapc_cannon_ammo_regen * frametime);

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_lightapc_shield, autocvar_g_vehicle_lightapc_shield_regen_pause, autocvar_g_vehicle_lightapc_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_lightapc_health, autocvar_g_vehicle_lightapc_health_regen_pause, autocvar_g_vehicle_lightapc_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_lightapc_energy, autocvar_g_vehicle_lightapc_energy_regen_pause, autocvar_g_vehicle_lightapc_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

float lightapc_pilot_frame()
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
    
    //lightapc_regen();


  //////////////////////////////////////////////////
  /// Tanklike Movements ///////////////////////////
  //////////////////////////////////////////////////
	makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_tankiv_springlength, autocvar_g_vehicle_tankiv_springup, autocvar_g_vehicle_tankiv_springblend, autocvar_g_vehicle_tankiv_tiltlimit);

    if(vehic.flags & FL_ONGROUND)
    {
          makevectors(pilot.v_angle);

	if(vlen(pilot.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("tankiv_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_tankiv_speed_stop);
                //vehic.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
		self.bomb3.gun1.avelocity_y = self.bomb3.gun2.avelocity_y = self.bomb4.gun1.avelocity_y = self.bomb4.gun2.avelocity_y = 0;
        }
	
    	if(pilot.movement_y != 0)
   	 {
	 	if(vehic.angles_y > 180)  vehic.angles_y -= 360;
    		if(vehic.angles_y < -180) vehic.angles_y += 360;
		vehic.angles_y = bound(-184,vehic.angles_y + ((pilot.movement_y * sys_frametime) / -6.66666),184);	
		
		if(vehic.angles_y >= -1 && vehic.angles_y <= -1)
            		vehic.angles_y = 0;	

		////float degree_y;
		////pilot.angles_y = pilot.angles_y + ((pilot.movement_y * sys_frametime) / -6.66666);
		////degree_y = ((pilot.movement_y * sys_frametime) / -6.66666);
		////pilot.v_angle_y += degree_y;
		
		pilot.v_angle_y = vehic.angles_y; //kiss

		if ((clienttype(pilot) == CLIENTTYPE_REAL)) {
			msg_entity = pilot;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, pilot.v_angle_x);
			WriteAngle( MSG_ONE, pilot.v_angle_y);
  			WriteAngle( MSG_ONE, pilot.v_angle_z);
		}
		
		////////pilot.angles_y = pilot.angles_y + (pilot.movement_y / -200);
		////////pilot.fixangle = TRUE;
		
		//////msg_entity = pilot;
  		//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		//////WriteAngle( MSG_ONE, vehic.angles_x); 
  		//////WriteAngle( MSG_ONE, vehic.angles_y);
  		//////WriteAngle( MSG_ONE, vehic.angles_z);
		if (pilot.movement_y > 0) {
			self.bomb1.gun1.avelocity_y = 75; //gear
                	self.bomb1.gun2.avelocity_y = 90; //wheel
                	self.bomb2.gun1.avelocity_y = -75; //gear
                	self.bomb2.gun2.avelocity_y = -90; //wheel
			
			self.bomb3.gun1.avelocity_y = 75; //gear
                	self.bomb3.gun2.avelocity_y = 90; //wheel
                	self.bomb4.gun1.avelocity_y = -75; //gear
                	self.bomb4.gun2.avelocity_y = -90; //wheel
		} else {
			self.bomb1.gun1.avelocity_y = -75; //gear
                	self.bomb1.gun2.avelocity_y = -90; //wheel
                	self.bomb2.gun1.avelocity_y = 75; //gear
                	self.bomb2.gun2.avelocity_y = 90; //wheel
			
			self.bomb3.gun1.avelocity_y = -75; //gear
                	self.bomb3.gun2.avelocity_y = -90; //wheel
                	self.bomb4.gun1.avelocity_y = 75; //gear
                	self.bomb4.gun2.avelocity_y = 90; //wheel
		}
	 }
	 
	 if(pilot.movement_x != 0)
         {
                    if(pilot.movement_x > 0)
                    {
                        pilot.movement_x = 1;
                        vehic.frame = 0;
                    }
                    else if(pilot.movement_x < 0)
                    {
                        pilot.movement_x = -1;
                        vehic.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * pilot.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * pilot.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * pilot.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * pilot.movement_x; //wheel
		    
		    self.bomb3.gun1.avelocity_y = 75 * pilot.movement_x; //gear
                    self.bomb3.gun2.avelocity_y = 90 * pilot.movement_x; //wheel
                    self.bomb4.gun1.avelocity_y = 75 * pilot.movement_x; //gear
                    self.bomb4.gun2.avelocity_y = 90 * pilot.movement_x; //wheel
		    
                    pilot.movement_y = 0;
		    
		    //fixedmakevectors(vehic.angles);
    			makevectors(vehic.angles + '-2 0 0' * vehic.angles_x);
    
    		    local float myvehicspeed;
		    
		    	if (pilot.waterlevel == WATERLEVEL_SUBMERGED)
   			{
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.10;
			} else if (pilot.waterlevel == WATERLEVEL_SWIMMING)
   			{
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.45;
			}  else if (pilot.waterlevel == WATERLEVEL_WETFEET)
   			{
				myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward * 0.75;
			} else {
		   		myvehicspeed = autocvar_g_vehicle_lightapc_speed_forward;
		    	}
			
                    movelib_move_simple(normalize(v_forward * pilot.movement_x),myvehicspeed,autocvar_g_vehicle_tankiv_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 4; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("tankiv_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_tankiv_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_tankiv_tiltlimit, self.angles_x, autocvar_g_vehicle_tankiv_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_tankiv_tiltlimit, self.angles_z, autocvar_g_vehicle_tankiv_tiltlimit);
  //////////////////////////////////////////////////
  /// Tanklike Movements ///////////////////////////
  //////////////////////////////////////////////////

//Weapons removed
   

    if(vehic.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_shield, autocvar_g_vehicle_lightapc_shield, autocvar_g_vehicle_lightapc_shield_regen_pause, autocvar_g_vehicle_lightapc_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(vehic.dmg_time, vehicle_health, autocvar_g_vehicle_lightapc_health, autocvar_g_vehicle_lightapc_health_regen_pause, autocvar_g_vehicle_lightapc_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(vehic.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(vehic.wait, vehicle_energy, autocvar_g_vehicle_lightapc_energy, autocvar_g_vehicle_lightapc_energy_regen_pause, autocvar_g_vehicle_lightapc_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(pilot, health, lightapc);
    VEHICLE_UPDATE_PLAYER(pilot, energy, lightapc);

    if(vehic.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(pilot, shield, lightapc);

    
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

void lightapc_think()
{
	if(self.flags & FL_ONGROUND)
        	movelib_beak_simple(autocvar_g_vehicle_tankll48_speed_stop);
	
	self.nextthink = time;

//    float pushdeltatime = time - self.lastpushtime;
//    if (pushdeltatime > 0.15) pushdeltatime = 0;
//    self.lastpushtime = time;
//    if(!pushdeltatime) return;

//    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_lightapc_springlength), MOVE_NORMAL, self);

//    vector df = self.velocity * -autocvar_g_vehicle_lightapc_friction;
//	df_z += (1 - trace_fraction) * autocvar_g_vehicle_lightapc_hoverpower + sin(time * 2) * (autocvar_g_vehicle_lightapc_springlength * 2);

//	self.velocity += df * pushdeltatime;
//    if(self.velocity_z > 0)
//        self.velocity_z *= 1 - autocvar_g_vehicle_lightapc_upforcedamper * pushdeltatime;

//    self.angles_x *= 1 - (autocvar_g_vehicle_lightapc_anglestabilizer * pushdeltatime);
//    self.angles_z *= 1 - (autocvar_g_vehicle_lightapc_anglestabilizer * pushdeltatime);
	
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
		
		if(self.gunner10)
		{
			self = self.gunner10;
			oldself.gun10.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner11)
		{
			self = self.gunner11;
			oldself.gun11.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner12)
		{
			self = self.gunner12;
			oldself.gun12.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner13)
		{
			self = self.gunner13;
			oldself.gun13.vehicle_exit(VHEF_EJECT);
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

void lightapc_enter()
{
	self.touch = lightapc_touch;
	self.nextthink = 0;
	//self.movetype = MOVETYPE_BOUNCE;
	self.movetype = MOVETYPE_WALK;
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void lightapc_exit(float eject)
{
	vector spot;
	
	self.touch = vehicles_touch;
	self.think = lightapc_think;
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

void lightapc_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_lightapc_blowup_coredamage,
				 autocvar_g_vehicle_lightapc_blowup_edgedamage,
				 autocvar_g_vehicle_lightapc_blowup_radius, self,
				 autocvar_g_vehicle_lightapc_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void lightapc_diethink()
{
	if(time >= self.wait)
		self.think = lightapc_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void lightapc_die()
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
	
	if(self.gunner10)
	{
		self = self.gunner10;
		oldself.gun10.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner11)
	{
		self = self.gunner11;
		oldself.gun11.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner12)
	{
		self = self.gunner12;
		oldself.gun12.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner13)
	{
		self = self.gunner13;
		oldself.gun13.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}

	self.vehicle_exit(VHEF_EJECT);
	
	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);
	vehicle_tossgib(self.gun2, self.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left", rint(random()), rint(random()), 6, randomvec() * 200);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if(random() > 0.5)
		_body.touch = lightapc_blowup;
	else
		_body.touch = func_null;
		
	_body.scale          = 0.75;
	_body.think = lightapc_diethink;
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

	tankt27_hitbox_die(self.hitboxmf); //Middle front //Fine, doesnt do anything tank specific
	tankt27_hitbox_die(self.hitboxmb); //Mid back
}

void lightapc_impact()
{
    if(autocvar_g_vehicle_lightapc_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_lightapc_bouncepain_x, 
						autocvar_g_vehicle_lightapc_bouncepain_y, 
						autocvar_g_vehicle_lightapc_bouncepain_z);
}

void lightapc_spawn(float _f)
{
   self.vehicle_pilotchangeseat = lightapc_gunner_enter; //Function to exec if pilot wants to change seat

	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
	if(!self.gun1)
	{
		self.loddistance1 = 192; //Lod0 Model quite complex, so only use when very close
		self.loddistance2 = 6144; //rather basic
		
		self.lodmodel1 = "models/vehicles/lightapc_lod1.iqm";
		self.lodmodel2 = "models/vehicles/lightapc_lod2.iqm";
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
		self.gun4 = spawn();
		self.gun5 = spawn();
		self.gun6 = spawn();
		self.gun7 = spawn();
		self.gun8 = spawn();
		self.gun9 = spawn();
		self.gun10 = spawn();
		self.gun11 = spawn();
		self.gun12 = spawn();
		self.gun13 = spawn();
		
		entity spinner;
		self.bomb1 = spawn();
        	self.bomb2 = spawn();
		self.bomb3 = spawn();
		self.bomb4 = spawn();
	
		//Wheels
		spinner = spawn();
	
	local float mytireloddistance1;
	mytireloddistance1 = 3000;
	
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_gear_left");
        spinner.movetype = MOVETYPE_NOCLIP;
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_wheel_left");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_gear_right");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_wheel_right");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun2 = spinner;
	
	//
	spinner = spawn();
	spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_gear_left2");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb3.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_wheel_left2");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb3.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_gear_right2");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb4.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/lightapc_tire.iqm");
        setattachment(spinner, self, "tag_wheel_right2");
		//LOD stuff.
		spinner.loddistance1 = mytireloddistance1;
		spinner.lodowner = 1; //Use owner origin for computing LOD
		spinner.lodmodel1 = "models/vehicles/lightapc_tire_lod1.iqm";
		InitializeEntity(spinner, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb4.gun2 = spinner;
		//End Wheels

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
		self.gun10.owner = self;
		self.gun11.owner = self;
		self.gun12.owner = self;
		self.gun13.owner = self;

		setmodel(self.gun1, "null");
		setmodel(self.gun2, "null");
		setmodel(self.gun3, "null");
		setmodel(self.gun4, "null");
		setmodel(self.gun5, "null");
		setmodel(self.gun6, "null");
		setmodel(self.gun7, "null");
		setmodel(self.gun8, "null");
		setmodel(self.gun9, "null");
		setmodel(self.gun10, "null");
		setmodel(self.gun11, "null");
		setmodel(self.gun12, "null");
		setmodel(self.gun13, "null");
		
		self.bomb5 = spawn();
		self.bomb6 = spawn();

		if (self.spawnflags) {
			self.bomb5.owner = self; //So LOD stuff will...
			setmodel(self.bomb5,"models/vehicles/lightapc_mount.iqm");
			setattachment(self.bomb5, self, "tag_gunturret1");
			
				//LOD stuff.
				self.bomb5.loddistance1 = 6144;
				self.bomb5.lodowner = 1; //Use owner origin for computing LOD
				self.bomb5.lodmodel1 = "models/vehicles/lightapc_mount_lod1.iqm";
				InitializeEntity(self.bomb5, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end
		
			self.bomb6.owner = self; //For LOD stuff
			setmodel(self.bomb6,"models/vehicles/lightapc_mount.iqm");
			setattachment(self.bomb6, self, "tag_gunturret2");
			
				//LOD stuff.
				self.bomb6.loddistance1 = 6144;
				self.bomb6.lodowner = 1; //Use owner origin for computing LOD
				self.bomb6.lodmodel1 = "models/vehicles/lightapc_mount_lod1.iqm";
				InitializeEntity(self.bomb6, LODmodel_attach, INITPRIO_FINDTARGET);
				//LOD stuff end
		}
		
		if (self.spawnflags == 1) {
			setmodel(self.gun1, "models/mountedguns/delugegun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/delugegun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
			self.gun1.owner = self.gun2.owner = self;
			self.gun1.lodowner = self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = self.gun2.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
			self.gun1.lodmodel2 = self.gun2.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
		} else if (self.spawnflags == 2) {
			setmodel(self.gun1, "models/mountedguns/shlacgun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/shlacgun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
		} else if (self.spawnflags == 3) {
			setmodel(self.gun1, "models/mountedguns/grailgun.iqm");
			//LOD stuff.
			self.gun1.owner = self;
			self.gun1.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			
			setmodel(self.gun2, "models/mountedguns/grailgun.iqm");
			//LOD stuff.
			self.gun2.owner = self;
			self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun2.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
		} else if (self.spawnflags == 4) {
			setmodel(self.gun1, "models/mountedguns/autonexgun.iqm");
			//LOD stuff.
			self.gun1.owner = self;
			self.gun1.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = "models/mountedguns/autonexgun_lod1.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			
			setmodel(self.gun2, "models/mountedguns/autonexgun.iqm");
			//LOD stuff.
			self.gun2.owner = self;
			self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun2.lodmodel1 = "models/mountedguns/autonexgun_lod1.iqm";
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			//LOD stuff end
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
		} else if (self.spawnflags == 5) {
			setmodel(self.gun1, "models/mountedguns/browning50gun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/browning50gun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
			self.gun1.owner = self.gun2.owner = self;
			self.gun1.lodowner = self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = self.gun2.lodmodel1 = "models/mountedguns/browning50gun_lod1.iqm";
			self.gun1.lodmodel2 = self.gun2.lodmodel2 = "models/mountedguns/browning50gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			
		} else if (self.spawnflags == 6) {
			setmodel(self.gun1, "models/mountedguns/t17mmgun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/t17mmgun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
			self.gun1.owner = self.gun2.owner = self;
			self.gun1.lodowner = self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = self.gun2.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
			self.gun1.lodmodel2 = self.gun2.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
			self.gun1.lodmodel3 = self.gun2.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
		} else if (self.spawnflags == 7) {	
			setmodel(self.gun1, "models/mountedguns/gau19gun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/gau19gun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
			self.gun1.owner = self.gun2.owner = self;
			self.gun1.lodowner = self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = self.gun2.lodmodel1 = "models/mountedguns/gau19gun_lod1.iqm";
			self.gun1.lodmodel2 = self.gun2.lodmodel2 = "models/mountedguns/gau19gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			
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
		} else if (self.spawnflags == 8) {	
			setmodel(self.gun1, "models/mountedguns/m134gun.iqm");
			setattachment(self.gun1, self.bomb5, "tag_gunpivot");
			setmodel(self.gun2, "models/mountedguns/m134gun.iqm");
			setattachment(self.gun2, self.bomb6, "tag_gunpivot");
			
			self.gun1.owner = self.gun2.owner = self;
			self.gun1.lodowner = self.gun2.lodowner = 1; //Use owner origin for computing LOD
			self.gun1.lodmodel1 = self.gun2.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
			self.gun1.lodmodel2 = self.gun2.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
			InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
			InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
			
			//Minigun Barrels
			self.gun1.gun1 = spawn();
			setmodel(self.gun1.gun1,"models/mountedguns/m134gun_barrels.iqm");
			setattachment(self.gun1.gun1, self.gun1, "tag_axis");
			self.gun1.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
		
			//Minigun Barrels
			self.gun2.gun1 = spawn();
			setmodel(self.gun2.gun1,"models/mountedguns/m134gun_barrels.iqm");
			setattachment(self.gun2.gun1, self.gun2, "tag_axis");
			self.gun2.gun1.count = autocvar_g_vehicle_mg_gau19_machinegun_refire;
		} else {
			setattachment(self.gun1, self, "tag_pass1");
			setattachment(self.gun2, self, "tag_pass2");
		}
		setattachment(self.gun3, self, "tag_pass3");
		setattachment(self.gun4, self, "tag_pass4");
		setattachment(self.gun5, self, "tag_pass5");
		setattachment(self.gun6, self, "tag_pass6");
		setattachment(self.gun7, self, "tag_pass7");
		setattachment(self.gun8, self, "tag_pass8");
		setattachment(self.gun9, self, "tag_pass9");
		setattachment(self.gun10, self, "tag_pass10");
		setattachment(self.gun11, self, "tag_pass11");
		setattachment(self.gun12, self, "tag_pass12");
		setattachment(self.gun13, self, "tag_pass13");
		
		vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun3, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun4, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun5, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun6, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun7, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun8, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun9, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun10, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun11, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun12, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);
		vehicle_addplayerslot(self, self.gun13, HUD_WAKIZASHI, "null", lightapc_gunner_frame, lightapc_gunner_exit);


		if (self.spawnflags) {
			setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_camera");
                	setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_camera");
		}
		self.hitboxmf = spawn();
		self.hitboxmb = spawn();
	}
	
	if(self.scale != 0.75)
	{
	        if(autocvar_g_vehicle_lightapc_hovertype != 0)
	            lightapc_force_from_tag = vehicles_force_fromtag_maglev;
	        else
	            lightapc_force_from_tag = vehicles_force_fromtag_hover;
	
        	// FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        	self.scale = 0.75;
        	setattachment(self.vehicle_hudmodel, self, "");
	        setattachment(self.vehicle_viewport, self, "tag_viewport");

        	self.mass               = autocvar_g_vehicle_lightapc_mass;
	}
	
	self.think          = lightapc_think;
        self.nextthink      = time;
	
	self.subordinate        = self.hitboxmf; //For testing max_z in determining if should crush a player or monster
   	self.subordinatespeed   = autocvar_g_vehicle_lightapc_speed_forward;
    	self.subordinateinertia = autocvar_g_vehicle_tankiv_movement_inertia;

	self.vehicle_health = autocvar_g_vehicle_lightapc_health;
	self.vehicle_shield = autocvar_g_vehicle_lightapc_shield;
	self.movetype       = MOVETYPE_TOSS;
    	self.solid          = SOLID_SLIDEBOX;
	self.delay          = time;
	self.vehicle_impact = lightapc_impact;
	
	self.scale          = 0.75;

    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;
    self.bomb3.gun1.avelocity_y = 0;
    self.bomb3.gun2.avelocity_y = 0;
    self.bomb4.gun1.avelocity_y = 0;
    self.bomb4.gun2.avelocity_y = 0;
    
    setsize(self, LIGHTAPC_MIN * 0.5, LIGHTAPC_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_lightapc_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_lightapc_bouncestop;
    self.damageforcescale = 0.5;
    //self.destvec = autocvar_g_vehicle_lightapc_bouncepain;

    cruizerlimo_spawn_hitbox(0, self, self.hitboxmf, LIGHTAPC_MIN_HBB * 0.5, LIGHTAPC_MAX_HBB * 0.5, 90, autocvar_g_vehicle_lightapc_health);	
    cruizerlimo_spawn_hitbox(0, self, self.hitboxmb, LIGHTAPC_MIN_HBB * 0.5, LIGHTAPC_MAX_HBB * 0.5, -90, autocvar_g_vehicle_lightapc_health);	
}

void spawnfunc_vehicle_lightapc()
{
	if(!autocvar_g_vehicle_lightapc)
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
	
	//precache_sound ("vehicles/racer_idle.wav");
   	//precache_sound ("vehicles/racer_move.wav");
    	//precache_sound ("vehicles/racer_boost.wav");
	precache_sound ( "weapons/rocket_impact.wav");
	
    	precache_sound ( "machines/generator_loop_pitchdown.ogg");
   	precache_sound ( "vehicles/tankll24_jump.wav");
    	precache_sound ( "vehicles/tankll24_strafe.wav");
    	precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");

    	precache_model ("models/vhshield.md3");
	
	precache_model("models/vehicles/lightapc_mount.iqm");
	precache_model("models/vehicles/lightapc_mount_lod1.iqm");
	precache_model("models/vehicles/lightapc_tire.iqm");
	precache_model("models/vehicles/lightapc_tire_lod1.iqm");
	precache_model("models/vehicles/lightapc.iqm");
	precache_model("models/vehicles/lightapc_lod1.iqm");
	precache_model("models/vehicles/lightapc_lod2.iqm");
	
	float gnammomax;
	if (self.spawnflags == 1) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		precache_sound ( "machines/steam_fade.ogg" );
		gnammomax = 0;
	} else if (self.spawnflags == 2) {
		precache_model ( "models/mountedguns/shlacgun.iqm");
		gnammomax = 0;
	} else if (self.spawnflags == 3) {
		precache_model ( "models/mountedguns/grailgun.iqm");
    		precache_model ( "models/mountedguns/grailgun_lod1.iqm");
		gnammomax = 0;	
	} else if (self.spawnflags == 4) {
		precache_model ( "models/mountedguns/autonexgun.iqm");
		precache_model ( "models/mountedguns/autonexgun_lod1.iqm");
		gnammomax = 0;
	} else if (self.spawnflags == 5) {
		precache_model ( "models/mountedguns/browning50gun.iqm");
		precache_model ( "models/mountedguns/browning50gun_lod1.iqm");
		precache_model ( "models/mountedguns/browning50gun_lod2.iqm");
		precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		precache_model ( "models/uziflash.md3");
		gnammomax = autocvar_g_vehicle_mg_browning50_machinegun_ammo_max * 14;
	} else if (self.spawnflags == 6) {
		precache_model ( "models/mountedguns/t17mmgun.iqm");
    		precache_model ( "models/mountedguns/t17mmgun_lod1.iqm");
		precache_model ( "models/mountedguns/t17mmgun_lod2.iqm");
		precache_model ( "models/mountedguns/t17mmgun_lod3.iqm");
		precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
		precache_model ( "models/uziflash.md3");
		gnammomax = autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max * 14;
	} else if (self.spawnflags == 7) {
		precache_model ( "models/mountedguns/gau19gun.iqm");
		precache_model ( "models/mountedguns/gau19gun_lod1.iqm");
		precache_model ( "models/mountedguns/gau19gun_lod2.iqm");
		precache_model ( "models/mountedguns/gau19gun_barrels.iqm");
		precache_sound ( "weapons/campingrifle_fire_bass.wav" );
		gnammomax = autocvar_g_vehicle_mg_gau19_machinegun_ammo_max * 4;
	} else if (self.spawnflags == 8) {
		precache_model ( "models/mountedguns/m134gun.iqm");
		precache_model ( "models/mountedguns/m134gun_lod1.iqm");
		precache_model ( "models/mountedguns/m134gun_lod2.iqm");
		precache_model ( "models/mountedguns/m134gun_barrels.iqm");
		precache_sound ( "weapons/uzi_fire.wav" );
		gnammomax = autocvar_g_vehicle_mg_m134_machinegun_ammo_max * 4;
	}
	
	if(autocvar_g_vehicle_lightapc_energy)
		if(autocvar_g_vehicle_lightapc_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_lightapc_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_lightapc_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_lightapc_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "LightAPC",
			   "models/vehicles/lightapc.iqm",
			   "null", // we need this so tur_head is networked and usable for sounds
			   "null", 
			   "", "", "tag_viewport",
			   HUD_WAKIZASHI, 
           		   0.5 * LIGHTAPC_MIN, 0.5 * LIGHTAPC_MAX,
			   FALSE,
			   lightapc_spawn, autocvar_g_vehicle_lightapc_respawntime,
			   lightapc_pilot_frame, lightapc_enter, lightapc_exit,
			   lightapc_die, lightapc_think, FALSE, autocvar_g_vehicle_lightapc_health, autocvar_g_vehicle_lightapc_shield, autocolor, gnammomax, 0))
			   //1023 == Hack for no starting colormap (1024 = grey)
	{
		remove(self);
		return;
	}
}

void spawnfunc_vehicle_lightapc_deluge()
{
	self.spawnflags = 1;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_shlac()
{
	self.spawnflags = 2;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_grail()
{
	self.spawnflags = 3;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_autonex()
{
	self.spawnflags = 4;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_browning50()
{
	self.spawnflags = 5;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_t17mm()
{
	self.spawnflags = 6;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_gau19()
{
	self.spawnflags = 7;	
	spawnfunc_vehicle_lightapc();
}

void spawnfunc_vehicle_lightapc_m134()
{
	self.spawnflags = 8;	
	spawnfunc_vehicle_lightapc();
}

#endif // SVQC

#ifdef CSQC
void lightapc_draw()
{

}

void lightapc_draw2d()
{

}

void lightapc_read_extra()
{

}

void vehicle_lightapc_assemble()
{

}
#endif //CSQC
