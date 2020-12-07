//#define SHNZRG_SETUP 2
//#define SHNZRG_START 4
//#define SHNZRG_END 8

#ifdef SVQC
// Auto cvars
//float autocvar_g_vehicle_shenzong_mass;

float autocvar_g_vehicle_shenzong_speed_forward;
float autocvar_g_vehicle_shenzong_speed_strafe;
float autocvar_g_vehicle_shenzong_speed_up;
float autocvar_g_vehicle_shenzong_speed_down;
float autocvar_g_vehicle_shenzong_turnspeed;
float autocvar_g_vehicle_shenzong_pitchspeed;
float autocvar_g_vehicle_shenzong_pitchlimit;
float autocvar_g_vehicle_shenzong_friction;

float autocvar_g_vehicle_shenzong_bomb_refire;
float autocvar_g_vehicle_shenzong_bomb_aps;

float autocvar_g_vehicle_shenzong_energy;
float autocvar_g_vehicle_shenzong_energy_regen;
float autocvar_g_vehicle_shenzong_energy_regen_pause;

float autocvar_g_vehicle_shenzong_health;
float autocvar_g_vehicle_shenzong_health_regen;
float autocvar_g_vehicle_shenzong_health_regen_pause;

float autocvar_g_vehicle_shenzong_shield;
float autocvar_g_vehicle_shenzong_shield_regen;
float autocvar_g_vehicle_shenzong_shield_regen_pause;

// extraneous //float autocvar_g_vehicle_shenzong_cannon_cost;
float autocvar_g_vehicle_shenzong_cannon_damage;
float autocvar_g_vehicle_shenzong_cannon_radius;
// extraneous //float autocvar_g_vehicle_shenzong_cannon_refire;
float autocvar_g_vehicle_shenzong_cannon_speed;
float autocvar_g_vehicle_shenzong_cannon_spread;
float autocvar_g_vehicle_shenzong_cannon_force;
float autocvar_g_vehicle_shenzong_cannon_rayrefire;
float autocvar_g_vehicle_shenzong_cannon_raypulseduration;
float autocvar_g_vehicle_shenzong_cannon_raydamage;
float autocvar_g_vehicle_shenzong_cannon_raycost;

float autocvar_g_vehicle_shenzong_cannon_ammo;
float autocvar_g_vehicle_shenzong_cannon_ammo_regen;
float autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause;

var float autocvar_g_vehicle_shenzong_cannon_lock = 0;

float autocvar_g_vehicle_shenzong_cannon_turnspeed;
float autocvar_g_vehicle_shenzong_cannon_pitchlimit_down;
float autocvar_g_vehicle_shenzong_cannon_pitchlimit_up;
float autocvar_g_vehicle_shenzong_cannon_turnlimit_in;
float autocvar_g_vehicle_shenzong_cannon_turnlimit_out;
float autocvar_g_vehicle_shenzong_cannonback_turnlimit_in;
float autocvar_g_vehicle_shenzong_cannonback_turnlimit_out;
float autocvar_g_vehicle_shenzong_cannondown_pitchlimit_down;

float autocvar_g_vehicle_shenzong_raygun_turnspeed;
float autocvar_g_vehicle_shenzong_raygun_pitchlimit_down;
float autocvar_g_vehicle_shenzong_raygun_pitchlimit_up;
float autocvar_g_vehicle_shenzong_raygun_turnlimit_sides;

float autocvar_g_vehicle_shenzong_raygun_dps;
float autocvar_g_vehicle_shenzong_raygun_aps;
float autocvar_g_vehicle_shenzong_raygun_pulse;

//float autocvar_g_vehicle_shenzong_raygun;
float autocvar_g_vehicle_shenzong_raygun_locktime;

float autocvar_g_vehicle_shenzong_bomb_damage;
float autocvar_g_vehicle_shenzong_bomb_edgedamage;
float autocvar_g_vehicle_shenzong_bomb_radius;
float autocvar_g_vehicle_shenzong_bomb_force;

float autocvar_g_vehicle_shenzong_respawntime;

float autocvar_g_vehicle_shenzong_blowup_radius;
float autocvar_g_vehicle_shenzong_blowup_coredamage;
float autocvar_g_vehicle_shenzong_blowup_edgedamage;
float autocvar_g_vehicle_shenzong_blowup_forceintensity;
var vector autocvar_g_vehicle_shenzong_bouncepain;

var float autocvar_g_vehicle_shenzong = 0;


void flashnade_doflash(entity mynade, float flashbangradi);

#define SHENZONG_MIN '-200 -200 0'
#define SHENZONG_MAX '200 200 700'
//700 rather than 900 so our laser can't hit ourself if we pitch up

const vector SHENZONG_MIN_HFB = '-140 -140 300'; //Middle
const vector SHENZONG_MAX_HFB = '140 140 800';
//const vector SHENZONG_MIN_HFB = '-1 -1 -1'; //Middle
//const vector SHENZONG_MAX_HFB = '1 1 1';

const vector SHENZONG_MIN_HBB = '-220 -220 340'; //Middle
const vector SHENZONG_MAX_HBB = '220 220 890';

.entity mylazerenemy;


void shenzong_bomb_boom()
{   
	if (other == self.subordinate.hitboxmf
	|| other == self.subordinate.hitboxmb
	|| other == self.subordinate) {
		//print("Don't explode on own vehic\n");
		return;
	}
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.95, 0.05, 0.25);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.75, 0.07, 0.4);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.4, 0.1, 0.5);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.35, 0.13, 0.6);

	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.25, 0.16, 0.7);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.4, 1, 1.0);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.3, 2, 2.0);
	
	modeleffect_spawn("models/sphere/sphelc.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_shenzong_bomb_radius, 0.2, 3, 3.0);
	
	pointparticles(particleeffectnum("hookbomb_explode"), self.origin, '0 0 0', 1);
	
	flashnade_doflash(self, autocvar_g_vehicle_shenzong_bomb_radius*0.5);
	W_Plasma_TriggerCombo(self.origin, autocvar_g_vehicle_shenzong_bomb_radius, self.realowner);
	RadiusDamage (self, self.realowner, autocvar_g_vehicle_shenzong_bomb_damage, autocvar_g_vehicle_shenzong_bomb_edgedamage, autocvar_g_vehicle_shenzong_bomb_radius, world, autocvar_g_vehicle_shenzong_bomb_force, self.projectiledeathtype, world);
	Chemical_flash_maybe(self);
	
		//print(ftos(self.projectiledeathtype), "-shenzong-bomb-projdeathtype\n");

	
	remove(self);
}

void shenzong_bombdrop(entity pilot, entity vehic)
{
    entity bomb_1;

    bomb_1 = spawn();

    setorigin(bomb_1, gettaginfo(self, gettagindex(self, "bomb2")));

    bomb_1.movetype        = MOVETYPE_BOUNCE;
    bomb_1.velocity        = self.velocity;
    bomb_1.touch           = shenzong_bomb_boom;

    bomb_1.owner           = self;
    bomb_1.realowner       = pilot;
    bomb_1.solid           = SOLID_BBOX;
    bomb_1.subordinate = vehic;
    bomb_1.gravity         = 1;
    bomb_1.projectiledeathtype = WEP_ELECTRO;

    PROJECTILE_MAKETRIGGER(bomb_1);

    CSQCProjectile(bomb_1, TRUE, PROJECTILE_RAPTORBOMB, TRUE);
}


void shenzong_pulse_laser_think(void) {
	if (time > self.ammount) {
		entity myselflaser;
		myselflaser = self;
		self = world; //So whoever is pointing at us is pointing at world now (hopefully)
		remove(myselflaser);
	} else {
		misc_laser_think();
	}
}

void shenzong_fire_cannon(entity _gun, string _tagname, entity _owner)
{
	vector v = gettaginfo(_gun, gettagindex(_gun, _tagname));
	vehicles_projectile("bigplasma_muzzleflash", "weapons/flacexp3.wav",
						v, normalize(v_forward + randomvec() * autocvar_g_vehicle_shenzong_cannon_spread) * autocvar_g_vehicle_shenzong_cannon_speed,
						autocvar_g_vehicle_shenzong_cannon_damage, autocvar_g_vehicle_shenzong_cannon_radius, autocvar_g_vehicle_shenzong_cannon_force,  0,
						DEATH_BUMB_GUN, PROJECTILE_BUMBLE_GUN, 0, TRUE, TRUE, _owner);
}

float shenzong_maybe_fire_laser(entity _gun, string _tagname, entity pilot,
				entity _vehic, vector _mycolormod, float _myalpha,
				float _myscale, float _mydynlight, float _mydamage,
				float _myduration, float firerequirementsment)
{
	
	if(firerequirementsment)
	{
		if (_gun.mylazerenemy == world || !_gun.mylazerenemy) {
			//vector v;
			entity mylaser;
			entity myoldself;
			myoldself = self;
			mylaser = spawn();
			self = mylaser;
			self.realowner = pilot;
			self.colormod = _mycolormod;
			self.alpha = _myalpha;
			self.scale = _myscale;
			self.modelscale = _mydynlight; //Dynlight
			self.origin = gettaginfo(_gun, gettagindex(_gun, _tagname));
			
			//Works OK:
			//makevectors(_vehic.angles + _gun.angles);
			//self.angles = vectoangles(v_forward);
			
			//Doesn't work with turrets: (fires at 90 degree somewhere)
			//makevectors(_vehic.angles);
			//v = gettaginfo(_gun, gettagindex(_gun, _tagname));
        		//v_forward = normalize(v_forward);
			//v += v_forward;
			//self.angles = v;
			
			//Pretty good
			makevectors(_vehic.angles + _gun.angles);
			v_forward = normalize(v_forward);
			self.angles = vectoangles(v_forward);
			
			self.dmg = _mydamage;
			spawnfunc_misc_laser();
			if (_myduration) {
				self.ammount = time + _myduration;
				self.think = shenzong_pulse_laser_think;
			}
			self = myoldself;
			
			_gun.mylazerenemy = mylaser;
		} else {
			_gun.mylazerenemy.origin = gettaginfo(_gun, gettagindex(_gun, _tagname));
			
			makevectors(_vehic.angles + _gun.angles);
			_gun.mylazerenemy.angles = vectoangles(v_forward);
		}
		return 1;
	}
	else {
		entity myremovelaser;
		if(_gun.mylazerenemy) {
			myremovelaser = _gun.mylazerenemy;
			_gun.mylazerenemy = world;
			remove(myremovelaser);
		}
		return 0;
	}
}

float shenzong_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;


	
	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin);
	gunner.velocity = vehic.velocity;
	
	float _in, _out, _pitchlimitdown;
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
  if(gun == vehic.gun1 || gun == vehic.gun2  || gun == vehic.gun3 || gun == vehic.gun4
  || gun == vehic.gun5 || gun == vehic.gun6 || gun == vehic.gun7 || gun == vehic.gun8)
  {
  //Gunners
  
	if((gun == vehic.gun1 || gun == vehic.gun3 || gun == vehic.gun5 || gun == vehic.gun7))
	{
		if (gun == vehic.gun7) {
			_in = autocvar_g_vehicle_shenzong_cannonback_turnlimit_in;
			_out = autocvar_g_vehicle_shenzong_cannonback_turnlimit_out;
		} else {
			_in = autocvar_g_vehicle_shenzong_cannon_turnlimit_in;
			_out = autocvar_g_vehicle_shenzong_cannon_turnlimit_out;
		}
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	}
	else
	{
		if (gun == vehic.gun8) {
			_in = autocvar_g_vehicle_shenzong_cannonback_turnlimit_out;
			_out = autocvar_g_vehicle_shenzong_cannonback_turnlimit_in;
		} else {
			_in = autocvar_g_vehicle_shenzong_cannon_turnlimit_out;
			_out = autocvar_g_vehicle_shenzong_cannon_turnlimit_in;
		}
		//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	}
	
	if (gun == vehic.gun5 || gun == vehic.gun6) {
		_pitchlimitdown = autocvar_g_vehicle_shenzong_cannondown_pitchlimit_down;
	} else {
		_pitchlimitdown = autocvar_g_vehicle_shenzong_cannon_pitchlimit_down;
	}
	

	//if(gun.enemy){
	//	crosshair_trace2(gunner);
	//} else if (!gun.ammount3) {
	//	gun.ammount3 = 1;
	//	crosshair_trace(gunner);
	//} else {
	//	gun.ammount3 = 0;
	//	crosshair_trace2(gunner);
	//}
	
	float gunnofire;
	gunnofire = 0;
	
	crosshair_trace(gunner);
	
	if (trace_ent == vehic.hitboxmf
	|| trace_ent == vehic.hitboxmb
	|| trace_ent == vehic) {
		//Let's not collide with something from our vehic
		crosshair_trace2(gunner);
		gunnofire = 1; //Don't shoot at self
	}
	
	vector _ct = trace_endpos;
	vector ad;

	if(autocvar_g_vehicle_shenzong_cannon_lock)
	{
		if(gun.lock_time < time)
			gun.enemy = world;

		if(trace_ent)
			if (trace_ent != vehic.hitboxmf)
			if (trace_ent != vehic.hitboxmb)
			if (trace_ent != vehic)
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
			impact_time = distance / autocvar_g_vehicle_shenzong_cannon_speed;
			ad = vf + _vel * impact_time;
		}
		trace_endpos = ad;


		UpdateAuxiliaryXhair(gunner, ad, '1 0 1', 1);
		vehicle_aimturret(vehic, trace_endpos, gun, "fire",
						  _pitchlimitdown * -1, autocvar_g_vehicle_shenzong_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_shenzong_cannon_turnspeed);

	}
	else
		vehicle_aimturret(vehic, _ct, gun, "fire",
						  _pitchlimitdown * -1, autocvar_g_vehicle_shenzong_cannon_pitchlimit_up,
						  _out * -1,  _in,  autocvar_g_vehicle_shenzong_cannon_turnspeed);

	
	//if(gunner.BUTTON_ATCK)
	//	if(time > gun.attack_finished_single)
	//		if(gun.vehicle_energy >= autocvar_g_vehicle_shenzong_cannon_cost)
	//		{
	//			gun.vehicle_energy -= autocvar_g_vehicle_shenzong_cannon_cost;
	//			shenzong_fire_cannon(gun, "fire", gunner);
	//			gun.delay = time;
	//			gun.attack_finished_single = time + autocvar_g_vehicle_shenzong_cannon_refire;
	//		}
	
	
	float myrequirementstofire;
	myrequirementstofire = 0;
			
	if(gunner.BUTTON_ATCK)
		if(time > gun.attack_finished_single || time < gun.amnt)
			if(gun.vehicle_energy >= autocvar_g_vehicle_shenzong_cannon_raycost)
			{
				if (!gunnofire) {
					myrequirementstofire = 1;
				}
			}	
			
			
	if (shenzong_maybe_fire_laser(gun, "fire", gunner,
				vehic, '1 0 1', 0.9,
				8, 2, autocvar_g_vehicle_shenzong_cannon_raydamage,
				autocvar_g_vehicle_shenzong_cannon_raypulseduration, myrequirementstofire))
	{
		if (time > gun.attack_finished_single) {
			gun.vehicle_energy -= autocvar_g_vehicle_shenzong_cannon_raycost;
			gun.delay = time;
			gun.attack_finished_single = time + autocvar_g_vehicle_shenzong_cannon_rayrefire;
			gun.amnt = time + autocvar_g_vehicle_shenzong_cannon_raypulseduration; //Pulse duration;
		}
				
		//Restore previous
		vehic.angles_x *= -1;
		makevectors(vehic.angles);
		vehic.angles_x *= -1;
	}
			
	

	VEHICLE_UPDATE_PLAYER(gunner, health, shenzong);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, shenzong);

	ad = gettaginfo(gun, gettagindex(gun, "fire"));
	traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun);

	UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 0 1' *(1 - gunner.vehicle_reload1)), 0);

	if(vehic.owner)
		UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('1 0 1' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));
  } else {
  	//Passenger
  	VEHICLE_UPDATE_PLAYER(gunner, health, shenzong);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, shenzong);
  }
  
	vehic.solid = SOLID_BBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;

	self = gunner;
	return 1;
}

void shenzong_gunner_exit(float _exitflag)
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
	}
	else if(self == self.vehicle.owner.gunner4)
	{
		self.vehicle.owner.gunner4 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner5)
	{
		self.vehicle.owner.gunner5 = world;	
	}
	else if(self == self.vehicle.owner.gunner6)
	{
		self.vehicle.owner.gunner6 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner7)
	{
		self.vehicle.owner.gunner7 = world;	
	}
	else if(self == self.vehicle.owner.gunner8)
	{
		self.vehicle.owner.gunner8 = world;	
		v_right *= -1;
	}
	else if(self == self.vehicle.owner.gunner9)
	{
		self.vehicle.owner.gunner9 = world;	
	}
	else if(self == self.vehicle.owner.gunner10)
	{
		self.vehicle.owner.gunner10 = world;	
		v_right *= -1;		
	}
	else if(self == self.vehicle.owner.gunner11)
	{
		self.vehicle.owner.gunner11 = world;	
	}
	else if(self == self.vehicle.owner.gunner12)
	{
		self.vehicle.owner.gunner12 = world;	
		v_right *= -1;		
	}	
	else
		dprint("^1self != gunner1 or gunner2 or gunner3 or gunner4,...,12 this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + + v_up * 128 + v_right * 300;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float shenzong_gunner_enter(float selectgun)
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
	else if(!self.gunner10 && (!selectgun || selectgun == 10))
	{
		_gun = self.gun10;
		_gunner = self.gunner10;
		self.gunner10 = other;
	}
	else if(!self.gunner11 && (!selectgun || selectgun == 11))
	{
		_gun = self.gun11;
		_gunner = self.gunner11;
		self.gunner11 = other;
	}
	else if(!self.gunner12 && (!selectgun || selectgun == 12))
	{
		_gun = self.gun12;
		_gunner = self.gunner12;
		self.gunner12 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = shenzong_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= shenzong_gunner_enter;
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
	other.PlayerPhysplug    = shenzong_gunner_frame;
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

void shenzong_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world  && self.gunner5 != world && self.gunner6 != world && self.gunner7 != world && self.gunner8 != world && self.gunner9 != world
	 && self.gunner10 != world && self.gunner11 != world && self.gunner12 != world))
	{
		vehicles_touch();
		return;
	}

	if(vehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(shenzong_gunner_enter(0))
				return;

		if(self.gun2.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
				
		if(self.gun3.phase <= time)
			if(shenzong_gunner_enter(0))
				return;

		if(self.gun4.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun5.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun6.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun7.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun8.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun9.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun10.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun11.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
		
		if(self.gun12.phase <= time)
			if(shenzong_gunner_enter(0))
				return;
	}

	vehicles_touch();
}

void shenzong_regen()
{
	if(self.gun1.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun1.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun1.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);

	if(self.gun2.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun2.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun2.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);
	
	if(self.gun3.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun3.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun3.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);
	
	if(self.gun4.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun4.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun4.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);

	if(self.gun5.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun5.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun5.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);

	if(self.gun6.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun6.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun6.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);

	if(self.gun7.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun7.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun7.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);

	if(self.gun8.delay + autocvar_g_vehicle_shenzong_cannon_ammo_regen_pause < time)
		self.gun8.vehicle_energy = min(autocvar_g_vehicle_shenzong_cannon_ammo,
									   self.gun8.vehicle_energy + autocvar_g_vehicle_shenzong_cannon_ammo_regen * frametime);
	if(self.bomb1.alpha < 1) {
			self.bomb1.alpha = self.bomb1.alpha + (sys_frametime / autocvar_g_vehicle_shenzong_bomb_refire);
	}

	if(self.vehicle_flags  & VHF_SHIELDREGEN)
		vehicles_regen(self.dmg_time, vehicle_shield, autocvar_g_vehicle_shenzong_shield, autocvar_g_vehicle_shenzong_shield_regen_pause, autocvar_g_vehicle_shenzong_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_HEALTHREGEN)
		vehicles_regen(self.dmg_time, vehicle_health, autocvar_g_vehicle_shenzong_health, autocvar_g_vehicle_shenzong_health_regen_pause, autocvar_g_vehicle_shenzong_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

	if(self.vehicle_flags  & VHF_ENERGYREGEN)
		vehicles_regen(self.wait, vehicle_energy, autocvar_g_vehicle_shenzong_energy, autocvar_g_vehicle_shenzong_energy_regen_pause, autocvar_g_vehicle_shenzong_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

}

float shenzong_pilot_frame()
{
	entity pilot, vehic;
	vector newvel;

	pilot = self;
	vehic = self.vehicle;
	self   = vehic;


	if(vehic.deadflag != DEAD_NO)
	{
		self = pilot;
		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = 0;
		return 1;
	}

	shenzong_regen();

	if(vehic.tur_head.enemy){
		crosshair_trace2(pilot);
	} else if (!vehic.ammount3) {
		vehic.ammount3 = 1;
		crosshair_trace(pilot);
	} else {
		vehic.ammount3 = 0;
		crosshair_trace2(pilot);
	} 
	
	
	if (trace_ent == vehic.hitboxmf
	|| trace_ent == vehic.hitboxmb
	|| trace_ent == vehic) {
		//Let's not collide with something from our vehic
		crosshair_trace2(pilot);
	}
	

	vector vang;
	float ftmp;

	vang = vehic.angles;
	newvel = vectoangles(normalize(trace_endpos - self.origin + '0 0 32'));
	vang_x *= -1;
	newvel_x *= -1;
	if(newvel_x > 180)  newvel_x -= 360;
	if(newvel_x < -180) newvel_x += 360;
	if(newvel_y > 180)  newvel_y -= 360;
	if(newvel_y < -180) newvel_y += 360;

	ftmp = shortangle_f(pilot.v_angle_y - vang_y, vang_y);
	if(ftmp > 180)  ftmp -= 360;
	if(ftmp < -180) ftmp += 360;
	vehic.avelocity_y = bound(-autocvar_g_vehicle_shenzong_turnspeed, ftmp + vehic.avelocity_y * 0.9, autocvar_g_vehicle_shenzong_turnspeed);

	// Pitch
	ftmp = 0;
	if(pilot.movement_x > 0 && vang_x < autocvar_g_vehicle_shenzong_pitchlimit) 
		ftmp = 4;
	else if(pilot.movement_x < 0 && vang_x > -autocvar_g_vehicle_shenzong_pitchlimit) 
		ftmp = -8;

	newvel_x = bound(-autocvar_g_vehicle_shenzong_pitchlimit, newvel_x , autocvar_g_vehicle_shenzong_pitchlimit);
	ftmp = vang_x - bound(-autocvar_g_vehicle_shenzong_pitchlimit, newvel_x + ftmp, autocvar_g_vehicle_shenzong_pitchlimit);
	vehic.avelocity_x = bound(-autocvar_g_vehicle_shenzong_pitchspeed, ftmp + vehic.avelocity_x * 0.9, autocvar_g_vehicle_shenzong_pitchspeed);

	vehic.angles_x = anglemods(vehic.angles_x);
	vehic.angles_y = anglemods(vehic.angles_y);
	vehic.angles_z = anglemods(vehic.angles_z);

	makevectors('0 1 0' * vehic.angles_y);
	newvel = vehic.velocity * -autocvar_g_vehicle_shenzong_friction;

	if(pilot.movement_x != 0)
	{
		if(pilot.movement_x > 0)
			newvel += v_forward  * autocvar_g_vehicle_shenzong_speed_forward;
		else if(pilot.movement_x < 0)
			newvel -= v_forward  * autocvar_g_vehicle_shenzong_speed_forward;
	}

	if(pilot.movement_y != 0)
	{
		if(pilot.movement_y < 0)
			newvel -= v_right * autocvar_g_vehicle_shenzong_speed_strafe;
		else if(pilot.movement_y > 0)
			newvel += v_right * autocvar_g_vehicle_shenzong_speed_strafe;
		ftmp = newvel * v_right;
		ftmp *= frametime * 0.1;
		vehic.angles_z = bound(-20, vehic.angles_z + ftmp, 20);
	}
	else
	{
		vehic.angles_z *= 0.95;
		if(vehic.angles_z >= -1 && vehic.angles_z <= -1)
			vehic.angles_z = 0;
	}

	if(pilot.BUTTON_CROUCH)
		newvel -=   v_up * autocvar_g_vehicle_shenzong_speed_down;
	else if(pilot.BUTTON_JUMP)
		newvel +=  v_up * autocvar_g_vehicle_shenzong_speed_up;

	
	newvel = vehicles_waterspeed2(pilot, newvel);
    	vehic.velocity = vehicles_waterfriction2(pilot, vehic, vehic.velocity);
	
	
	vehic.velocity  += newvel * frametime;
	pilot.velocity = pilot.movement  = vehic.velocity;
	

	if(autocvar_g_vehicle_shenzong_raygun_locktime)
	{		
		if(vehic.tur_head.lock_time < time || vehic.tur_head.enemy.deadflag)
			vehic.tur_head.enemy = world;

		if(trace_ent)
		if(trace_ent.movetype)
		if(trace_ent.takedamage)
		if(trace_ent != vehic.hitboxmf)
		if(trace_ent != vehic.hitboxmb)
		if(trace_ent != vehic)
		if(!trace_ent.deadflag)
		{
			if(teamplay)
			{
				if(trace_ent.team == pilot.team)
				{
					vehic.tur_head.enemy = trace_ent;
					vehic.tur_head.lock_time = time + autocvar_g_vehicle_shenzong_raygun_locktime;
				}
			}
			else
			{            
				vehic.tur_head.enemy = trace_ent;
				vehic.tur_head.lock_time = time + autocvar_g_vehicle_shenzong_raygun_locktime;
			}
		}
			
		if(vehic.tur_head.enemy)
		{
			trace_endpos = real_origin(vehic.tur_head.enemy);			
			UpdateAuxiliaryXhair(pilot, trace_endpos, '0.75 0 0.75', 0);		
		}
	}
	
	vang = vehicle_aimturret(vehic, trace_endpos, self.gun14, "fire",
					  autocvar_g_vehicle_shenzong_raygun_pitchlimit_down * -1,  autocvar_g_vehicle_shenzong_raygun_pitchlimit_up,
					  autocvar_g_vehicle_shenzong_raygun_turnlimit_sides * -1,  autocvar_g_vehicle_shenzong_raygun_turnlimit_sides,  autocvar_g_vehicle_shenzong_raygun_turnspeed);

	if((pilot.BUTTON_ATCK2) && (vehic.vehicle_energy > autocvar_g_vehicle_shenzong_bomb_aps))
	{
		if(time > vehic.attack_finished_single) {
			//mg_grail_attack("gunmount_right2", vehic);
			//mg_grail_attack("gunmount_left2", vehic);
			
			if (vehic.bomb1.count == 1) {
	    			//if nieuport.gun1.count is 1 we are loaded with a nuke
			    	nieuport_nukedrop();
				vehic.bomb1.count = 0;
				setmodel(vehic.bomb1,"models/vehicles/clusterbomb_folded.md3");
	    		} else {
	    			shenzong_bombdrop(pilot, vehic);
	    		}
            		vehic.bomb1.alpha = 0.001;
			
			vehic.vehicle_energy -= autocvar_g_vehicle_shenzong_bomb_aps;
			vehic.attack_finished_single = time + autocvar_g_vehicle_shenzong_bomb_refire;
		}
	}

	
	local float myrequirementstofire;
	myrequirementstofire = 0;
	if((pilot.BUTTON_ATCK) && (vehic.vehicle_energy > autocvar_g_vehicle_shenzong_raygun_aps * sys_frametime)) {
		myrequirementstofire = 1;
	}

	if (shenzong_maybe_fire_laser(vehic.gun14, "fire", pilot,
				vehic, '1 0 1', 0.9,
				8, 2, autocvar_g_vehicle_shenzong_raygun_dps,
				autocvar_g_vehicle_shenzong_raygun_pulse, myrequirementstofire))
	{
		vehic.vehicle_energy -= autocvar_g_vehicle_shenzong_raygun_aps * sys_frametime;
		vehic.wait = time + 1;
		//Restore previous
		makevectors('0 1 0' * vehic.angles_y);
	}
	
	
	if (pilot.impulse == 20)
	if (pilot.BUTTON_HOOK) {
		if (vehic.bomb1.count != 1)
		if (pilot.weapon == WEP_NUKE_LAYER)
		{
			entity oldself;
			oldself = self;
			self = pilot;
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
			vehic.bomb1.count = 1;
			setmodel(vehic.bomb1,"models/vehicles/nukebomb.md3");
			sprint(pilot, sprintf("Nuclear Weapon Loaded. Estimated Damage Radius: %f %% miles\n", (autocvar_g_balance_nukelayer_radius/63360)));
		}
	}
	
	
	VEHICLE_UPDATE_PLAYER(pilot, health, shenzong);
	VEHICLE_UPDATE_PLAYER(pilot, energy, shenzong);

	if (vehic.gunner1) {
		pilot.vehicle_ammo1 = (vehic.gun1.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else if (vehic.gunner3) {
		pilot.vehicle_ammo1 = (vehic.gun3.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else if (vehic.gunner5) {
		pilot.vehicle_ammo1 = (vehic.gun5.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else {
		pilot.vehicle_ammo1 = (vehic.gun7.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	}

	if (vehic.gunner2) {
		pilot.vehicle_ammo2 = (vehic.gun2.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else if (vehic.gunner4) {
		pilot.vehicle_ammo2 = (vehic.gun4.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else if (vehic.gunner6) {
		pilot.vehicle_ammo2 = (vehic.gun6.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	} else {
		pilot.vehicle_ammo2 = (vehic.gun8.vehicle_energy / autocvar_g_vehicle_shenzong_cannon_ammo) * 100;
	}

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(pilot, shield, shenzong);
		
	vehic.angles_x *= -1;
	makevectors(vehic.angles);
	vehic.angles_x *= -1;
	setorigin(pilot, vehic.origin + v_up * 48 + v_forward * 160);

	if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    	(vehicles_allowdriveby(1, pilot, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 5))) {
		//Do nothing
		pilot.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(vehic, vehic, pilot);
		pilot.BUTTON_CROUCH = 0;
    	} else {
		pilot.vehicle_allowdriveby = 0;
		pilot.BUTTON_ATCK = pilot.BUTTON_ATCK2 = pilot.BUTTON_CROUCH = 0;
	}
	
	self = pilot;

	return 1;
}

void shenzong_think()
{
	self.movetype = MOVETYPE_TOSS;
		
		//self.velocity = self.velocity * 0.5;
	self.angles_z *= 0.8;
	self.angles_x *= 0.8;
	
	self.nextthink = time + 0.05;
	
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
	}
	
}

void shenzong_enter()
{
	self.touch = shenzong_touch;
	self.nextthink = 0;
	self.movetype = MOVETYPE_BOUNCEMISSILE;
	//setattachment(self.owner, self.vehicle_viewport, "");
}

void shenzong_exit(float eject)
{
	self.touch = vehicles_touch;
	self.think = shenzong_think;
	self.nextthink = time;
	
	if(!self.owner)
		return;
		
	entity myremovelaser;
	if(self.gun14.mylazerenemy) {
		myremovelaser = self.gun14.mylazerenemy;
		self.gun14.mylazerenemy = world;
		remove(myremovelaser);
	}
	
	fixedmakevectors(self.angles);
	vector spot;
	if(vlen(self.velocity) > autocvar_g_vehicle_shenzong_speed_forward * 0.5)		
		spot = self.origin + v_up * 128 + v_forward * 200;
	else
		spot = self.origin + v_up * 128 - v_forward * 200;
	
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	

	self.owner.velocity = 0.75 * self.vehicle.velocity + normalize(spot - self.vehicle.origin) * 200;
	self.owner.velocity_z += 10;
	setorigin(self.owner, spot);

	/*if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	    //setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 250;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_shenzong_speed_forward * 0.5)		
		{
			if(vlen(self.velocity) > autocvar_sv_maxairspeed)
				self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed;
			else
				self.owner.velocity = self.velocity + v_forward * 100;
			
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 300 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    //setorigin(self.owner , spot);
	}
	*/
	
	antilag_clear(self.owner);
    self.owner = world;
}

void shenzong_blowup()
{
	RadiusDamage(self, self.enemy, autocvar_g_vehicle_shenzong_blowup_coredamage,
				 autocvar_g_vehicle_shenzong_blowup_edgedamage,
				 autocvar_g_vehicle_shenzong_blowup_radius, self,
				 autocvar_g_vehicle_shenzong_blowup_forceintensity,
				 DEATH_WAKIBLOWUP, world);

	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("explosion_large"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	
	if(self.owner.deadflag == DEAD_DYING)
		self.owner.deadflag = DEAD_DEAD;
	
	remove(self);
}

void shenzong_diethink()
{
	if(time >= self.wait)
		self.think = shenzong_blowup;

	if(random() < 0.1)
	{
		sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
	}

	self.nextthink = time + 0.1;
}

void shenzong_die()
{
	entity oldself = self;
	
	// Hide beam
	//if(self.gun14.enemy || !wasfreed(self.gun14.enemy))
	//	self.gun14.enemy.effects |= EF_NODRAW;
	entity myremovelaser;
	if(self.gun14.mylazerenemy) {
		myremovelaser = self.gun14.mylazerenemy;
		self.gun14.mylazerenemy = world;
		remove(myremovelaser);
	}
	
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

	self.vehicle_exit(VHEF_EJECT);

	fixedmakevectors(self.angles);
	vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right2", rint(random()), rint(random()), 6, randomvec() * 200);
	vehicle_tossgib(self.gun2, self.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left2", rint(random()), rint(random()), 6, randomvec() * 200);
	vehicle_tossgib(self.gun3, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right3", rint(random()), rint(random()), 6, randomvec() * 200);
	vehicle_tossgib(self.gun4, self.velocity + v_right * -300 + v_up * 100 + randomvec() * 200, "cannon_left3", rint(random()), rint(random()), 6, randomvec() * 200);
	
	vehicle_tossgib(self.gun14, self.velocity + v_forward * 300 + v_up * -100 + randomvec() * 200, "raygun", rint(random()), rint(random()), 6, randomvec() * 300);

	entity _body = vehicle_tossgib(self, self.velocity + randomvec() * 200, "", rint(random()), rint(random()), 6, randomvec() * 100);
	
	if (_body) {
		//Trying to avoid cannot modify free entity complaints 
		_body.lodmodel1 = "models/vehicles/shenzong_lod1.iqm";
		_body.lodmodel2 = "models/vehicles/shenzong_lod2.iqm";
    		InitializeEntity(_body, LODmodel_attach, INITPRIO_FINDTARGET);
	
		setsize(_body, SHENZONG_MIN, SHENZONG_MAX);
		_body.angles = self.angles;
	}
	
	//traceline(_body.origin, _body.origin + '0 0 256' , MOVE_WORLDONLY, _body);
	//_body.origin = trace_endpos;
	//setorigin(_body, _body.origin);
	
	if(random() > 0.5)
		_body.touch = shenzong_blowup;
	else
		_body.touch = func_null;
		
	_body.scale = self.scale;
	_body.think = shenzong_diethink;
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

void shenzong_impact()
{
    if(autocvar_g_vehicle_shenzong_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_shenzong_bouncepain_x, 
						autocvar_g_vehicle_shenzong_bouncepain_y, 
						autocvar_g_vehicle_shenzong_bouncepain_z);
}

void shenzong_spawn(float _f)
{
   self.vehicle_pilotchangeseat = shenzong_gunner_enter; //Function to exec if pilot wants to change seat

	/*
	float i;
	for(i=1; gettaginfo(self.gun1, i), gettaginfo_name; ++i)
	{

	    dprint(" ------- ^1gettaginfo_name^2(",ftos(i),") ^3=", gettaginfo_name, "\n");
	}
	*/
	if(!self.gun1)
	{
		
		self.loddistance1 = 2000;
		self.loddistance2 = 4000;
		
		self.lodmodel1 = "models/vehicles/shenzong_lod1.iqm";
		self.lodmodel2 = "models/vehicles/shenzong_lod2.iqm";
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
		self.gun10  = spawn();
		self.gun11  = spawn();
		self.gun12  = spawn();
		//
		self.gun14 = spawn(); //Main gun for pilot
		self.bomb1 = spawn();

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
		//
		self.gun14.owner = self; //Main gun for pilot

		setmodel(self.gun1, "models/vehicles/bumblebee_plasma_right.dpm");
		setmodel(self.gun2, "models/vehicles/bumblebee_plasma_left.dpm");
		setmodel(self.gun3, "models/vehicles/bumblebee_plasma_right.dpm");
		setmodel(self.gun4, "models/vehicles/bumblebee_plasma_left.dpm");
		setmodel(self.gun5, "models/vehicles/bumblebee_plasma_right.dpm");
		setmodel(self.gun6, "models/vehicles/bumblebee_plasma_left.dpm");
		setmodel(self.gun7, "models/vehicles/bumblebee_plasma_right.dpm");
		setmodel(self.gun8, "models/vehicles/bumblebee_plasma_left.dpm");
		setmodel(self.gun9, "null");
		setmodel(self.gun10, "null");
		setmodel(self.gun11, "null");
		setmodel(self.gun12, "null");
		//
		setmodel(self.gun14, "models/vehicles/bumblebee_ray.dpm"); //Main gun for pilot
		setmodel(self.bomb1,"models/vehicles/clusterbomb_folded.md3");
		
		setattachment(self.gun1, self, "cannon_right2");
		setattachment(self.gun2, self, "cannon_left2");
		
		setattachment(self.gun3, self, "cannon_right3");
		setattachment(self.gun4, self, "cannon_left3");
		
		setattachment(self.gun5, self, "cannon_downright");
		setattachment(self.gun6, self, "cannon_downleft");
		
		setattachment(self.gun7, self, "cannon_rightback2");
		setattachment(self.gun8, self, "cannon_leftback2");
		
		setattachment(self.gun9, self, "seat7");
		setattachment(self.gun10, self, "seat8");
		setattachment(self.gun11, self, "seat13");
		setattachment(self.gun12, self, "seat14");
		
		setattachment(self.bomb1, self, "bomb2");

		// Angled bones are no fun, messes up gun-aim; so work arround it.
		self.gun14.pos1 = self.angles;
		self.angles = '0 0 0';
		vector ofs = gettaginfo(self, gettagindex(self, "raygun"));
		ofs -= self.origin;
		setattachment(self.gun14, self, "");
		setorigin(self.gun14, ofs);
		self.angles = self.gun14.pos1;

		vehicle_addplayerslot(self, self.gun1, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun3, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun4, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun5, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun6, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun7, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun8, HUD_BUMBLEBEE_GUN, "models/vehicles/wakizashi_cockpit.dpm", shenzong_gunner_frame, shenzong_gunner_exit);

		vehicle_addplayerslot(self, self.gun9, HUD_BUMBLEBEE_GUN, "null", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun10, HUD_BUMBLEBEE_GUN, "null", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun11, HUD_BUMBLEBEE_GUN, "null", shenzong_gunner_frame, shenzong_gunner_exit);
		vehicle_addplayerslot(self, self.gun12, HUD_BUMBLEBEE_GUN, "null", shenzong_gunner_frame, shenzong_gunner_exit);


		//setorigin(self.vehicle_hudmodel, '50 0 -5');    // Move cockpit forward - down.
		//setorigin(self.vehicle_viewport, '5 0 2');    // Move camera forward up

		//fixme-model-bones
		setorigin(self.gun1.vehicle_hudmodel, '90 -27 -23');
		setorigin(self.gun1.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun3.vehicle_hudmodel, '90 -27 -23');
		setorigin(self.gun3.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun5.vehicle_hudmodel, '90 -27 -23');
		setorigin(self.gun5.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun7.vehicle_hudmodel, '90 -27 -23');
		setorigin(self.gun7.vehicle_viewport, '-85 0 50');
		
		//fixme-model-bones
		setorigin(self.gun2.vehicle_hudmodel, '90 27 -23');
		setorigin(self.gun2.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun4.vehicle_hudmodel, '90 27 -23');
		setorigin(self.gun4.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun6.vehicle_hudmodel, '90 27 -23');
		setorigin(self.gun6.vehicle_viewport, '-85 0 50');
		
		setorigin(self.gun8.vehicle_hudmodel, '90 27 -23');
		setorigin(self.gun8.vehicle_viewport, '-85 0 50');

		self.scale = 1; //1.5;
		self.mass = 10000; //2200;
		
		setattachment(self.vehicle_hudmodel, self, "");
	        setattachment(self.vehicle_viewport, self, "tag_viewport");
		//setorigin(self.vehicle_viewport, '-100 0 0');
		setorigin(self.vehicle_viewport, '-50 0 -50');
		
		//// Raygun beam
		//if(self.gun14.enemy == world)
		//{			
		//	self.gun14.enemy = spawn();
		//}
		
		self.hitboxmf = spawn();
		self.hitboxmb = spawn();
	}

	self.subordinate        = self.hitboxmf; //For testing max_z in determining if should crush a player or monster
   	self.subordinatespeed   = autocvar_g_vehicle_shenzong_speed_forward;
    	self.subordinateinertia = autocvar_g_vehicle_tankiv_movement_inertia;
	
	self.vehicle_health = autocvar_g_vehicle_shenzong_health;
	self.vehicle_shield = autocvar_g_vehicle_shenzong_shield;
	self.solid          = SOLID_BBOX;
	//self.movetype 	= MOVETYPE_BOUNCEMISSILE;
	self.movetype 		= MOVETYPE_TOSS;
	self.vehicle_impact = shenzong_impact;
	self.damageforcescale = 0.025;
	
	setorigin(self, self.origin + '0 0 25');
	
	cruizerlimo_spawn_hitbox(0, self, self.hitboxmf, SHENZONG_MIN_HFB, SHENZONG_MAX_HFB, 360, autocvar_g_vehicle_shenzong_health);	
    	cruizerlimo_spawn_hitbox(0, self, self.hitboxmb, SHENZONG_MIN_HBB, SHENZONG_MAX_HBB, -400, autocvar_g_vehicle_shenzong_health);	
}

void spawnfunc_vehicle_shenzong()
{
	if(!autocvar_g_vehicle_shenzong)
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

	precache_model("models/vehicles/shenzong.iqm");
	precache_model("models/vehicles/shenzong_lod1.iqm");
	precache_model("models/vehicles/shenzong_lod2.iqm");
	precache_model("models/vehicles/bumblebee_plasma_left.dpm");
	precache_model("models/vehicles/bumblebee_plasma_right.dpm");
	precache_model("models/vehicles/bumblebee_ray.dpm");
	precache_model("models/vehicles/wakizashi_cockpit.dpm");
	precache_model("models/vehicles/spiderbot_cockpit.dpm");
	precache_model("models/vehicles/raptor_cockpit.dpm");
	precache_model ("models/vehicles/clusterbomb_folded.md3");
	precache_model ("models/vehicles/nukebomb.md3");
	precache_model ("models/vhshield.md3");
	precache_model ("models/sphere/sphelc.md3");
	precache_sound ( "weapons/rocket_impact.wav");

	if(autocvar_g_vehicle_shenzong_energy)
		if(autocvar_g_vehicle_shenzong_energy_regen)
			self.vehicle_flags |= VHF_ENERGYREGEN;

	if(autocvar_g_vehicle_shenzong_shield)
		self.vehicle_flags |= VHF_HASSHIELD;

	if(autocvar_g_vehicle_shenzong_shield_regen)
		self.vehicle_flags |= VHF_SHIELDREGEN;

	if(autocvar_g_vehicle_shenzong_health_regen)
		self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

	if not(vehicle_initialize(
			   "Shenzong", "models/vehicles/shenzong.iqm",
			   "null",
			   "null",
			   "", "", "tag_viewport",
			   HUD_BUMBLEBEE, SHENZONG_MIN, SHENZONG_MAX, FALSE,
			   shenzong_spawn, autocvar_g_vehicle_shenzong_respawntime,
			   shenzong_pilot_frame, shenzong_enter, shenzong_exit,
			   shenzong_die, shenzong_think, FALSE, autocvar_g_vehicle_shenzong_health, autocvar_g_vehicle_shenzong_shield, autocolor, 0, 0))
	{
		remove(self);
		return;
	}
}

#endif // SVQC

#ifdef CSQC
/*
.vector raygun_l1
.vector raygun_l2;
.vector raygun_l3;
*/

void shenzong_draw()
{

}

void shenzong_draw2d()
{

}

void shenzong_read_extra()
{

}

void vehicle_shenzong_assemble()
{

}
#endif //CSQC
