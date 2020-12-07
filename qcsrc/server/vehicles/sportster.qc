#define SPORTSTER_MIN '-120 -120 0'
#define SPORTSTER_MAX '120 120 80'

#ifdef SVQC
void sportster_exit(float eject);
void sportster_enter();

// Auto cvars
float autocvar_g_vehicle_sportster;
float autocvar_g_vehicle_sportster_mass;
float autocvar_g_vehicle_sportster_speed_afterburn;
float autocvar_g_vehicle_sportster_afterburn_cost;

float autocvar_g_vehicle_sportster_anglestabilizer;
float autocvar_g_vehicle_sportster_downforce;

float autocvar_g_vehicle_sportster_speed_forward;
float autocvar_g_vehicle_sportster_speed_strafe;
float autocvar_g_vehicle_sportster_springlength;
float autocvar_g_vehicle_sportster_upforcedamper;
float autocvar_g_vehicle_sportster_friction;

float autocvar_g_vehicle_sportster_hovertype;
float autocvar_g_vehicle_sportster_hoverpower;

float autocvar_g_vehicle_sportster_turnroll;
float autocvar_g_vehicle_sportster_turnspeed;
float autocvar_g_vehicle_sportster_pitchspeed;

float autocvar_g_vehicle_sportster_energy;
float autocvar_g_vehicle_sportster_energy_regen;
float autocvar_g_vehicle_sportster_energy_regen_pause;

float autocvar_g_vehicle_sportster_health;
float autocvar_g_vehicle_sportster_health_regen;
float autocvar_g_vehicle_sportster_health_regen_pause;

float autocvar_g_vehicle_sportster_shield;
float autocvar_g_vehicle_sportster_shield_regen;
float autocvar_g_vehicle_sportster_shield_regen_pause;

float autocvar_g_vehicle_sportster_cannon_cost;
float autocvar_g_vehicle_sportster_cannon_refire;

float autocvar_g_vehicle_sportster_cannon_spread;
float autocvar_g_vehicle_sportster_cannon_speed;
float autocvar_g_vehicle_sportster_cannon_damage; 
float autocvar_g_vehicle_sportster_cannon_headshotbonus; 
float autocvar_g_vehicle_sportster_cannon_force; 
float autocvar_g_vehicle_sportster_cannon_bulletconstant; 
float autocvar_g_vehicle_sportster_cannon_coreshotbonus;

float autocvar_g_vehicle_sportster_cannon_expelbulletcasings;

float autocvar_g_vehicle_sportster_rocket_accel;
float autocvar_g_vehicle_sportster_rocket_damage;
float autocvar_g_vehicle_sportster_rocket_radius;
float autocvar_g_vehicle_sportster_rocket_force;
float autocvar_g_vehicle_sportster_rocket_refire;
float autocvar_g_vehicle_sportster_rocket_speed;
float autocvar_g_vehicle_sportster_rocket_turnrate;

float autocvar_g_vehicle_sportster_rocket_locktarget;
float autocvar_g_vehicle_sportster_rocket_locking_time;
float autocvar_g_vehicle_sportster_rocket_locking_releasetime;
float autocvar_g_vehicle_sportster_rocket_locked_time;
float autocvar_g_vehicle_sportster_rocket_locked_maxangle;
float autocvar_g_vehicle_sportster_rocket_climbspeed;

float autocvar_g_vehicle_sportster_respawntime;

float autocvar_g_vehicle_sportster_blowup_radius;
float autocvar_g_vehicle_sportster_blowup_coredamage;
float autocvar_g_vehicle_sportster_blowup_edgedamage;
float autocvar_g_vehicle_sportster_blowup_forceintensity;

float autocvar_g_vehicle_sportster_bouncefactor;
float autocvar_g_vehicle_sportster_bouncestop;
vector autocvar_g_vehicle_sportster_bouncepain;

var vector sportster_force_from_tag(string tag_name, float spring_length, float max_power);
void sportster_spawn_default();

void sportster_align4point(float _delta)
{
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = sportster_force_from_tag("tag_engine_fr", autocvar_g_vehicle_sportster_springlength, autocvar_g_vehicle_sportster_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_sportster_collision_multiplier);

    push_vector += sportster_force_from_tag("tag_engine_fl", autocvar_g_vehicle_sportster_springlength, autocvar_g_vehicle_sportster_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_sportster_collision_multiplier);

    push_vector += sportster_force_from_tag("tag_engine_br", autocvar_g_vehicle_sportster_springlength, autocvar_g_vehicle_sportster_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_sportster_collision_multiplier);

    push_vector += sportster_force_from_tag("tag_engine_bl", autocvar_g_vehicle_sportster_springlength, autocvar_g_vehicle_sportster_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_sportster_collision_multiplier);

   self.velocity += push_vector * _delta;

    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_sportster_upforcedamper * _delta;

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
    self.angles_x *= 1 - (autocvar_g_vehicle_sportster_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_sportster_anglestabilizer * _delta);
}

void sportster_AttachToShotorg(entity flash, vector offset, string tagname)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;


	setattachment(flash, self, tagname);
	setorigin(flash, offset);

	xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = self;

	setattachment(xflash, self, tagname);
	setorigin(xflash, offset);
}

void sportster_fire_cannon(string tagname)
{
    vector v;
    vector oldv;
    entity _oldself = self;

    v = gettaginfo(self, gettagindex(self, tagname));
    oldv = v;
    v_forward = normalize(v_forward);
    v += v_forward * 50; //So as to clear the hitbox;
    
    //print(etos(self)," self and owner ",  etos(self.owner), "\n");
    self = self.owner;
  
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_sportster_cannon_spread, autocvar_g_vehicle_sportster_cannon_speed, 5, autocvar_g_vehicle_sportster_cannon_damage, autocvar_g_vehicle_sportster_cannon_headshotbonus, autocvar_g_vehicle_sportster_cannon_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_vehicle_sportster_cannon_bulletconstant, autocvar_g_vehicle_sportster_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    v = oldv;
    self = _oldself;
    
    sound (self, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
	    
    UziFlash();
    sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', tagname);
    
    if (autocvar_g_vehicle_sportster_cannon_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 104, self);
	}
    }
    
}

void sportster_rocket_groundhugger()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if(self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;

    tracebox(self.origin, self.mins, self.maxs, self.origin + olddir * 64, MOVE_WORLDONLY,self);
    if(trace_fraction <= 0.5)
    {
        // Hitting somethign soon, just speed ahead
        self.velocity = olddir * newvel;
        UpdateCSQCProjectile(self);
        return;
    }

    traceline(trace_endpos, trace_endpos - '0 0 64', MOVE_NORMAL, self);
    if(trace_fraction != 1.0)
    {
        newdir = normalize(trace_endpos + '0 0 64' - self.origin) * autocvar_g_vehicle_sportster_rocket_turnrate;
        self.velocity = normalize(olddir + newdir) * newvel;
    }
    else
    {
        self.velocity = olddir * newvel;
        self.velocity_z -= 1600 * sys_frametime; // 2x grav looks better for this one
    }

    UpdateCSQCProjectile(self);
    return;
}

void sportster_rocket_tracker()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;
    makevectors(vectoangles(olddir));

	float time_to_impact = min(vlen(self.enemy.origin - self.origin) / vlen(self.velocity), 1);
	vector predicted_origin = self.enemy.origin + self.enemy.velocity * time_to_impact;

    traceline(self.origin, self.origin + v_forward * 64 - '0 0 32', MOVE_NORMAL, self);
    newdir = normalize(predicted_origin - self.origin);

    //vector
	float height_diff = predicted_origin_z - self.origin_z;

    if(vlen(newdir - v_forward) > autocvar_g_vehicle_sportster_rocket_locked_maxangle)
    {
        //bprint("Target lost!\n");
        //dprint("OF:", ftos(vlen(newdir - v_forward)), "\n");
        self.think = sportster_rocket_groundhugger;
        return;
    }

    if(trace_fraction != 1.0 && trace_ent != self.enemy)
        newdir_z += 16 * sys_frametime;

    self.velocity = normalize(olddir + newdir * autocvar_g_vehicle_sportster_rocket_turnrate) * newvel;
    self.velocity_z -= 800 * sys_frametime;
    self.velocity_z += max(height_diff, autocvar_g_vehicle_sportster_rocket_climbspeed) * sys_frametime ;

    UpdateCSQCProjectile(self);
    return;
}

void sportster_fire_rocket(string tagname, entity trg)
{
    vector v = gettaginfo(self, gettagindex(self, tagname));
    entity rocket = rocket = vehicles_projectile("wakizashi_rocket_launch", "weapons/rocket_fire.wav",
                           v, v_forward * autocvar_g_vehicle_sportster_rocket_speed,
                           autocvar_g_vehicle_sportster_rocket_damage, autocvar_g_vehicle_sportster_rocket_radius, autocvar_g_vehicle_sportster_rocket_force, 3,
                           DEATH_WAKIROCKET, PROJECTILE_SEEKER, 20, FALSE, FALSE, self.owner);

    rocket.lip              = autocvar_g_vehicle_sportster_rocket_accel * sys_frametime;
    rocket.wait             = autocvar_g_vehicle_sportster_rocket_turnrate;
    rocket.nextthink        = time;
    rocket.enemy            = trg;
    rocket.cnt              = time + 15;

    if(trg)
        rocket.think            = sportster_rocket_tracker;
    else
        rocket.think            = sportster_rocket_groundhugger;
}

//Add For multi
float sportster_gunner_frame()
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
  //if not (autocvar_g_vehicles_noauxaimforpassengervehic) {	
  //	
  //}

	VEHICLE_UPDATE_PLAYER(gunner, health, sportster);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, sportster);

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
	gunner.vehicle_energy = vehic.vehicle_energy;

	self = gunner;
	return 1;
}

void sportster_gunner_exit(float _exitflag)
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
		
	vector spot = self.vehicle.owner.origin + v_up * 128 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float sportster_gunner_enter(float selectgun)
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
	_gun.vehicle_exit  = sportster_gunner_exit;
	
	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= sportster_gunner_enter;
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
	other.PlayerPhysplug    = sportster_gunner_frame;
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

float sportstervehicles_valid_pilot()
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

void sportster_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world))
	{
		vehicles_touch();
		return;
	}

	if(sportstervehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(sportster_gunner_enter(0))
				return;

	}

	vehicles_touch();
}
//Done For multi

float sportster_frame()
{
    entity player, sportster;
    vector df;
    float ftmp;

	if(intermission_running)
		return 1;

    player  = self;
    sportster   = self.vehicle;
    self    = sportster;

    player.BUTTON_ZOOM = player.BUTTON_CROUCH = 0;

    vehicles_painframe();

    if(sportster.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }

    sportster_align4point(frametime);

    crosshair_trace(player);

    sportster.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_sportster_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_y - sportster.angles_y, sportster.angles_y), ftmp);
    sportster.angles_y = anglemods(sportster.angles_y + ftmp);

    // Roll
    sportster.angles_z += -ftmp * autocvar_g_vehicle_sportster_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_sportster_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_x - sportster.angles_x, sportster.angles_x), ftmp);
    sportster.angles_x = bound(-30, anglemods(sportster.angles_x + ftmp), 30);

    makevectors(sportster.angles);
    sportster.angles_x *= -1;

    //ftmp = sportster.velocity_z;
    df = sportster.velocity * -autocvar_g_vehicle_sportster_friction;
    //sportster.velocity_z = ftmp;

    if(vlen(player.movement) != 0)
    {
        if(player.movement_x)
            df += v_forward * ((player.movement_x > 0) ? autocvar_g_vehicle_sportster_speed_forward : -autocvar_g_vehicle_sportster_speed_forward);

        if(player.movement_y)
            df += v_right * ((player.movement_y > 0) ? autocvar_g_vehicle_sportster_speed_strafe : -autocvar_g_vehicle_sportster_speed_strafe);

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
    if (player.BUTTON_JUMP && sportster.vehicle_energy >= (autocvar_g_vehicle_sportster_afterburn_cost * frametime))
    {
        if(time - sportster.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        sportster.wait = time;
        sportster.vehicle_energy -= autocvar_g_vehicle_sportster_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_sportster_speed_afterburn);

        if(sportster.invincible_finished < time)
        {
            traceline(sportster.origin, sportster.origin - '0 0 256', MOVE_NORMAL, self);
            if(trace_fraction != 1.0)
                pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

            sportster.invincible_finished = time + 0.1 + (random() * 0.1);
        }

        if(sportster.strength_finished < time)
        {
            sportster.strength_finished = time + 10.922667; //soundlength("vehicles/racer_boost.wav");
            sound (sportster.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        sportster.strength_finished = 0;
        sound (sportster.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);
    }

	df -= v_up * (vlen(sportster.velocity) * autocvar_g_vehicle_sportster_downforce);
	df = vehicles_waterspeed(player, df);
	sportster.velocity = vehicles_waterfriction(player, sportster, sportster.velocity);
    player.movement = sportster.velocity += df * frametime;

    if(player.BUTTON_ATCK)
    if(time > sportster.attack_finished_single)
    if(sportster.vehicle_ammo1 >= autocvar_g_vehicle_sportster_cannon_cost)
    {
        sportster.vehicle_ammo1 -= autocvar_g_vehicle_sportster_cannon_cost;
        sportster.wait = time;

        crosshair_trace(player);
        if(sportster.cnt)
        {
            sportster_fire_cannon("tag_fire1");
            sportster.cnt = 0;
        }
        else
        {
            sportster_fire_cannon("tag_fire2");
            sportster.cnt = 1;
        }
        sportster.attack_finished_single = time + autocvar_g_vehicle_sportster_cannon_refire;
	sportster.count = 0; //Will have to press R to resume reload 
    }
    
    if not(player.BUTTON_ATCK) {
    	if (sportster.count == 1) {
        	vehicles_regen(sportster.wait, vehicle_ammo1, autocvar_g_vehicle_sportster_energy, autocvar_g_vehicle_sportster_energy_regen_pause, autocvar_g_vehicle_sportster_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		sportster.count = 1;
		sound (sportster, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, sportster, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	}
    }

    if(autocvar_g_vehicle_sportster_rocket_locktarget)
    {
        vehicles_locktarget((1 / autocvar_g_vehicle_sportster_rocket_locking_time) * frametime,
                         (1 / autocvar_g_vehicle_sportster_rocket_locking_releasetime) * frametime,
                         autocvar_g_vehicle_sportster_rocket_locked_time);

        if(self.lock_target)
        {
            if(sportster.lock_strength == 1)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 0 0', 0);
            else if(self.lock_strength > 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 0.5 0', 0);
            else if(self.lock_strength < 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0.5 0.5 0', 0);
        }
    }

    if(time > sportster.delay)
    if(player.BUTTON_ATCK2)
    if(player.vehicle_reload1 == 100)
    {
        sportster.misc_bulletcounter += 1;
        sportster.delay = time + 0.3;

        if(sportster.misc_bulletcounter == 1)
            sportster_fire_rocket("tag_rocket_r", (sportster.lock_strength == 1 && sportster.lock_target) ? sportster.lock_target : world);
        else if(sportster.misc_bulletcounter == 2)
        {
            sportster_fire_rocket("tag_rocket_l", (sportster.lock_strength == 1 && sportster.lock_target) ? sportster.lock_target : world);
            sportster.lock_strength  = 0;
            sportster.lock_target    = world;
            sportster.misc_bulletcounter = 0;

            sportster.delay = time + autocvar_g_vehicle_sportster_rocket_refire;
            sportster.lip = time;
        }
    }
    
    if (sportster.vehicle_ammo2_current > 0) {
   	player.vehicle_reload1 = bound(0, 100 * ((time - sportster.lip) / (sportster.delay - sportster.lip)), 100);
	if (player.vehicle_reload1 < 100) {
		sportster.vehicle_ammo2_current = sportster.vehicle_ammo2_current - (1 * sys_frametime);
	}
    }
    
    if(sportster.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(sportster.dmg_time, vehicle_shield, autocvar_g_vehicle_sportster_shield, autocvar_g_vehicle_sportster_shield_regen_pause, autocvar_g_vehicle_sportster_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(sportster.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(sportster.dmg_time, vehicle_health, autocvar_g_vehicle_sportster_health, autocvar_g_vehicle_sportster_health_regen_pause, autocvar_g_vehicle_sportster_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(sportster.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(sportster.wait, vehicle_energy, autocvar_g_vehicle_sportster_energy, autocvar_g_vehicle_sportster_energy_regen_pause, autocvar_g_vehicle_sportster_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(player, health, sportster);
    VEHICLE_UPDATE_PLAYER(player, energy, sportster);

    if(sportster.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, sportster);
    
    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 1))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(sportster, sportster, player);
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    }
    
    setorigin(player,sportster.origin + '0 0 32');
    player.velocity = sportster.velocity;

    player.vehicle_ammo1_current = sportster.vehicle_ammo1_current;
    player.vehicle_ammo1_max = sportster.vehicle_ammo1_max;
    player.vehicle_ammo2_current = sportster.vehicle_ammo2_current;
    player.vehicle_ammo2_max = sportster.vehicle_ammo2_max;
    player.vehicle_ammo1 = (sportster.vehicle_ammo1 / autocvar_g_vehicle_sportster_energy) * 100;

    self = player;
    return 1;
}

void sportster_think()
{
    self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_sportster_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_sportster_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_sportster_hoverpower + sin(time * 2) * (autocvar_g_vehicle_sportster_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_sportster_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_sportster_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_sportster_anglestabilizer * pushdeltatime);

    //Added for multi
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
    //done for multi
}

void sportster_enter()
{
    self.touch = sportster_touch; //Added for multi
    self.nextthink = 0;  //Added for multi
    
    self.movetype = MOVETYPE_BOUNCE;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_sportster_health)  * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_sportster_shield)  * 100;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-190 0 96');

	//targetdrone_spawn(self.origin + '0 0 512' + randomvec() * 256, 1);
}

void sportster_exit(float eject)
{
    vector spot;

    self.touch = vehicles_touch; //Added for multi

    self.think      = sportster_think;
    self.nextthink  = time;
    self.movetype   = MOVETYPE_BOUNCE;
    sound (self.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);

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

void sportster_impact()
{
    if(autocvar_g_vehicle_sportster_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_sportster_bouncepain_x, autocvar_g_vehicle_sportster_bouncepain_y, autocvar_g_vehicle_sportster_bouncepain_z);
}

void sportster_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);

    RadiusDamage (self, self.enemy, autocvar_g_vehicle_sportster_blowup_coredamage,
					autocvar_g_vehicle_sportster_blowup_edgedamage,
					autocvar_g_vehicle_sportster_blowup_radius, world,
					autocvar_g_vehicle_sportster_blowup_forceintensity,
					DEATH_WAKIBLOWUP, world);

    self.nextthink  = time + autocvar_g_vehicle_sportster_respawntime;
    self.think      = sportster_spawn_default;
    self.movetype   = MOVETYPE_NONE;
    self.effects    = EF_NODRAW;

    self.colormod  = '0 0 0';
    self.avelocity = '0 0 0';
    self.velocity  = '0 0 0';

    setorigin(self, self.pos1);
}

void sportster_deadtouch()
{
    self.avelocity_x *= 0.7;
    self.cnt -= 1;
    if(self.cnt <= 0)
        sportster_blowup();
}

void sportster_die()
{
   //Added for multi
    entity oldself = self;
    
	if(self.gunner1)
	{
		self = self.gunner1;
		oldself.gun1.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}

	
    self.vehicle_exit(VHEF_EJECT);
    //done for multi
    
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.wait         = time;
    self.cnt          = 1 + random() * 2;
    self.touch        = sportster_deadtouch;

    pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

    if(random() < 0.5)
        self.avelocity_z  = 32;
    else
        self.avelocity_z  = -32;

    self.avelocity_x = -vlen(self.velocity) * 0.2;
    self.velocity   += '0 0 700';
    self.colormod    = '-0.5 -0.5 -0.5';

	self.think     = sportster_blowup;
	self.nextthink = 2 + time + random() * 3;
}
void sportster_spawn(float _spawnflag)
{
    self.vehicle_pilotchangeseat = sportster_gunner_enter; //Function to exec if pilot wants to change seat, added for multi

    if(self.scale != 0.5)
    {
        if(autocvar_g_vehicle_sportster_hovertype != 0)
            sportster_force_from_tag = vehicles_force_fromtag_maglev;
        else
            sportster_force_from_tag = vehicles_force_fromtag_hover;

        // FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        self.scale = 0.5;
        setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self, "tag_viewport");

        self.mass               = autocvar_g_vehicle_sportster_mass;
	
	//Added for multi
		self.gun1 = spawn();

		self.vehicle_flags |= VHF_MULTISLOT;

		self.gun1.owner = self;

		setmodel(self.gun1, "null");

		setattachment(self.gun1, self, "null");
		
		vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "models/vehicles/sportster_interior.iqm", sportster_gunner_frame, sportster_gunner_exit);
    		
		self.gun1.vehicle_viewport.origin = '-16 -32 80';
		//Done for multi
    }
    self.lodmodel1 = "models/vehicles/sportster_lod1.iqm";
    self.lodmodel2 = "models/vehicles/sportster_lod2.iqm";
    InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.think          = sportster_think;
    self.nextthink      = time;
    self.vehicle_health = autocvar_g_vehicle_sportster_health;
    self.vehicle_shield = autocvar_g_vehicle_sportster_shield;

    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.delay          = time;
    self.scale          = 0.5;

    setsize(self, SPORTSTER_MIN * 0.5, SPORTSTER_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_sportster_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_sportster_bouncestop;
    self.vehicle_impact = sportster_impact;
    self.damageforcescale = 0.5;
    self.vehicle_hudmodel.colormap = self.vehicle.colormap;

    //self.destvec = autocvar_g_vehicle_sportster_bouncepain;
}
void sportster_spawn_default()
{
	sportster_spawn(0);
}


void spawnfunc_vehicle_sportster()
{
    if(!autocvar_g_vehicle_sportster)
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

    precache_sound ("weapons/campingrifle_fire.wav");
    precache_sound ("weapons/rocket_fire.wav");

    precache_sound ("vehicles/racer_idle.wav");
    precache_sound ("vehicles/racer_move.wav");
    precache_sound ("vehicles/racer_boost.wav");

    precache_model ("models/vhshield.md3");
    precache_model ("models/vehicles/sportster_exterior.iqm");
    precache_model ("models/vehicles/sportster_interior.iqm");
    precache_model ("models/vehicles/sportster_lod1.iqm");
    precache_model ("models/vehicles/sportster_lod2.iqm");

    if(autocvar_g_vehicle_sportster_energy)
        if(autocvar_g_vehicle_sportster_energy_regen)
            self.vehicle_flags |= VHF_ENERGYREGEN;

    if(autocvar_g_vehicle_sportster_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_sportster_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_sportster_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

    if not (vehicle_initialize(
             "Sportster",
             "models/vehicles/sportster_exterior.iqm",
             "null", // we need this so tur_head is networked and usable for sounds
             "models/vehicles/sportster_interior.iqm",
             "", "", "tag_viewport",
             HUD_WAKIZASHI,
             0.5 * SPORTSTER_MIN, 0.5 * SPORTSTER_MAX,
             FALSE,
             sportster_spawn, autocvar_g_vehicle_sportster_respawntime,
             sportster_frame,
             sportster_enter, sportster_exit,
             sportster_die,   sportster_think,
             TRUE, 
             autocvar_g_vehicle_sportster_health,
             autocvar_g_vehicle_sportster_shield, autocolor, autocvar_g_vehicle_sportster_energy * 4, autocvar_g_vehicle_sportster_rocket_refire * 2))
    {
        remove(self);
        return;
    }
}
#endif // SVQC
