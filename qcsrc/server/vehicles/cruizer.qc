#define CRUIZER_MIN '-120 -120 0'
#define CRUIZER_MAX '120 120 100'

#ifdef SVQC
void cruizer_exit(float eject);
void cruizer_enter();

// Auto cvars
float autocvar_g_vehicle_cruizer;
float autocvar_g_vehicle_cruizer_mass;
float autocvar_g_vehicle_cruizer_speed_afterburn;
float autocvar_g_vehicle_cruizer_afterburn_cost;

float autocvar_g_vehicle_cruizer_anglestabilizer;
float autocvar_g_vehicle_cruizer_downforce;

float autocvar_g_vehicle_cruizer_speed_forward;
float autocvar_g_vehicle_cruizer_speed_strafe;
float autocvar_g_vehicle_cruizer_springlength;
float autocvar_g_vehicle_cruizer_upforcedamper;
float autocvar_g_vehicle_cruizer_friction;

float autocvar_g_vehicle_cruizer_hovertype;
float autocvar_g_vehicle_cruizer_hoverpower;

float autocvar_g_vehicle_cruizer_turnroll;
float autocvar_g_vehicle_cruizer_turnspeed;
float autocvar_g_vehicle_cruizer_pitchspeed;

float autocvar_g_vehicle_cruizer_energy;
float autocvar_g_vehicle_cruizer_energy_regen;
float autocvar_g_vehicle_cruizer_energy_regen_pause;

float autocvar_g_vehicle_cruizer_health;
float autocvar_g_vehicle_cruizer_health_regen;
float autocvar_g_vehicle_cruizer_health_regen_pause;

float autocvar_g_vehicle_cruizer_shield;
float autocvar_g_vehicle_cruizer_shield_regen;
float autocvar_g_vehicle_cruizer_shield_regen_pause;

float autocvar_g_vehicle_cruizer_cannon_cost;
float autocvar_g_vehicle_cruizer_cannon_refire;

var float autocvar_g_vehicle_cruizer_mine_time = 0;

float autocvar_g_vehicle_cruizer_rocket_locktarget;
float autocvar_g_vehicle_cruizer_rocket_locking_time;
float autocvar_g_vehicle_cruizer_rocket_locking_releasetime;
float autocvar_g_vehicle_cruizer_rocket_locked_time;

float autocvar_g_vehicle_cruizer_respawntime;

float autocvar_g_vehicle_cruizer_blowup_radius;
float autocvar_g_vehicle_cruizer_blowup_coredamage;
float autocvar_g_vehicle_cruizer_blowup_edgedamage;
float autocvar_g_vehicle_cruizer_blowup_forceintensity;

float autocvar_g_vehicle_cruizer_bouncefactor;
float autocvar_g_vehicle_cruizer_bouncestop;
vector autocvar_g_vehicle_cruizer_bouncepain;

.entity gunner3;

var vector cruizer_force_from_tag(string tag_name, float spring_length, float max_power);
void cruizer_spawn_default();

void cruizer_align4point(float _delta)
{
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = cruizer_force_from_tag("tag_engine_fr", autocvar_g_vehicle_cruizer_springlength, autocvar_g_vehicle_cruizer_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_cruizer_collision_multiplier);

    push_vector += cruizer_force_from_tag("tag_engine_fl", autocvar_g_vehicle_cruizer_springlength, autocvar_g_vehicle_cruizer_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_cruizer_collision_multiplier);

    push_vector += cruizer_force_from_tag("tag_engine_br", autocvar_g_vehicle_cruizer_springlength, autocvar_g_vehicle_cruizer_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_cruizer_collision_multiplier);

    push_vector += cruizer_force_from_tag("tag_engine_bl", autocvar_g_vehicle_cruizer_springlength, autocvar_g_vehicle_cruizer_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_cruizer_collision_multiplier);

   self.velocity += push_vector * _delta;

    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_cruizer_upforcedamper * _delta;

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
    self.angles_x *= 1 - (autocvar_g_vehicle_cruizer_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_cruizer_anglestabilizer * _delta);
}

void cruizer_fire_cannon(string tagname)
{
    vector v;

    v = gettaginfo(self, gettagindex(self, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	if(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary_launchfailure);
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "A grenade of yours held an insufficent firing charge\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);
	}

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void cruizer_mine_think (void)
{
	entity head;

	self.nextthink = time;

	if(self.movetype == MOVETYPE_FOLLOW)
	{
		if(LostMovetypeFollow(self))
		{
			UnsetMovetypeFollow(self);
			self.movetype = MOVETYPE_NONE;
		}
	}
	
	// our lifetime has expired, it's time to die - mine_time just allows us to play a sound for this
	// TODO: replace this mine_trigger.wav sound with a real countdown
	if ((time > self.cnt) && (!self.mine_time))
	{
		if(autocvar_g_balance_minelayer_lifetime_countdown > 0)
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
		self.mine_time = time + autocvar_g_balance_minelayer_lifetime_countdown;
		self.mine_explodeanyway = 1; // make the mine super aggressive -- Samual: Rather, make it not care if a team mate is near.
	}

	// a player's mines shall explode if he disconnects or dies
	// TODO: Do this on team change too -- Samual: But isn't a player killed when they switch teams?
	if((self.realowner.classname != "player" || self.realowner.deadflag != DEAD_NO)
		&& autocvar_g_balance_minelayer_persistent != 1)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Mine_Explode();
		return;
	}

	// set the mine for detonation when a foe gets close enough
	head = findradius(self.origin, autocvar_g_balance_minelayer_proximityradius);
	while(head)
	{
		if(head.classname == "player" && head.deadflag == DEAD_NO)
		if(head != self.realowner && IsDifferentTeam(head, self.realowner)) // don't trigger for team mates
		if(!self.mine_time)
		{
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
			self.mine_time = time + autocvar_g_vehicle_cruizer_mine_time;
		}
		head = head.chain;
	}

	// explode if it's time to
	if(self.mine_time && time >= self.mine_time)
	{
		W_Mine_ProximityExplode();
		return;
	}

	// remote detonation
	if (self.realowner.weapon == WEP_MINE_LAYER)
	if (self.realowner.deadflag == DEAD_NO)
	if (self.minelayer_detonate)
		W_Mine_RemoteExplode();
}

void cruizer_mine_stick (entity to)
{
	spamsound (self, CH_SHOTS, "weapons/mine_stick.wav", VOL_BASE, ATTN_NORM);

	// in order for mines to face properly when sticking to the ground, they must be a server side entity rather than a csqc projectile

	entity newmine;
	newmine = spawn();
	newmine.classname = self.classname;

	newmine.bot_dodge = self.bot_dodge;
	newmine.bot_dodgerating = self.bot_dodgerating;

	newmine.owner = self.owner;
	newmine.realowner = self.realowner;
	setsize(newmine, '-4 -4 -4', '4 4 4');
	setorigin(newmine, self.origin);
	setmodel(newmine, "models/mine.md3");
	newmine.angles = vectoangles(-trace_plane_normal); // face against the surface

	newmine.oldvelocity = self.velocity;

	newmine.takedamage = self.takedamage;
	newmine.damageforcescale = self.damageforcescale;
	newmine.health = self.health;
	newmine.event_damage = self.event_damage;
	newmine.spawnshieldtime = self.spawnshieldtime;
	newmine.damagedbycontents = TRUE;

	newmine.movetype = MOVETYPE_NONE; // lock the mine in place
	newmine.projectiledeathtype = self.projectiledeathtype;

	newmine.mine_time = self.mine_time;

	newmine.touch = func_null;
	newmine.think = cruizer_mine_think;
	newmine.nextthink = time;
	newmine.cnt = self.cnt;
	newmine.flags = self.flags;

	remove(self);
	self = newmine;

	if(to)
		SetMovetypeFollow(self, to);
}

void cruizer_mine_touch (void)
{
	if(self.movetype == MOVETYPE_NONE || self.movetype == MOVETYPE_FOLLOW)
		return; // we're already a stuck mine, why do we get called? TODO does this even happen?

	PROJECTILE_TOUCH;

	if(other && other.classname == "player" && other.deadflag == DEAD_NO)
	{
		// hit a player
		// don't stick
	}
	else
	{
		cruizer_mine_stick(other);
	}
}


void cruizer_drop_mine(string tagname)
{
    vector v;

    v = gettaginfo(self, gettagindex(self, tagname));

	entity mine;

	// scan how many mines we placed, and return if we reached our limit
	if(autocvar_g_balance_minelayer_limit)
	{
	
		if(W_Mine_Count(self) >= autocvar_g_balance_minelayer_limit)
		{
			// the refire delay keeps this message from being spammed
			sprint(self, strcat("minelayer: You cannot place more than ^2", ftos(autocvar_g_balance_minelayer_limit), " ^7mines at a time\n") );
			play2(self, "weapons/unavailable.wav");
			return;
		}
	}

	W_SetupShot_ProjectileSize (self, '-4 -4 -4', '4 4 4', FALSE, 5, "weapons/mine_fire.wav", CH_WEAPON_A, autocvar_g_balance_minelayer_damage);

	mine = WarpZone_RefSys_SpawnSameRefSys(self);
	
	//Got to be for newtonian physics to work
	mine.owner = self;
	mine.realowner = self.owner;
	
	if(autocvar_g_balance_minelayer_detonatedelay >= 0)
		mine.spawnshieldtime = time + autocvar_g_balance_minelayer_detonatedelay;
	else
		mine.spawnshieldtime = -1;
	mine.classname = "mine";
	mine.bot_dodge = TRUE;
	mine.bot_dodgerating = autocvar_g_balance_minelayer_damage * 2; // * 2 because it can detonate inflight which makes it even more dangerous

	mine.takedamage = DAMAGE_YES;
	mine.damageforcescale = autocvar_g_balance_minelayer_damageforcescale;
	mine.health = autocvar_g_balance_minelayer_health;
	mine.event_damage = W_Mine_Damage;
	mine.damagedbycontents = TRUE;

	mine.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(mine);
	mine.projectiledeathtype = WEP_MINE_LAYER;
	setsize (mine, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot

	setorigin (mine, v); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(mine, autocvar_g_balance_minelayer_speed, 0);
	mine.angles = vectoangles (mine.velocity);

	mine.touch = cruizer_mine_touch;
	mine.think = cruizer_mine_think;
	mine.nextthink = time;
	mine.cnt = time + (autocvar_g_balance_minelayer_lifetime - autocvar_g_balance_minelayer_lifetime_countdown);
	mine.flags = FL_PROJECTILE;

	CSQCProjectile(mine, TRUE, PROJECTILE_MINE, TRUE);

	// common properties

	other = mine; MUTATOR_CALLHOOK(EditProjectile);
	
	self.minelayer_mines = W_Mine_Count(self);
}


//Add For multi
float cruizer_gunner_frame()
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

	VEHICLE_UPDATE_PLAYER(gunner, health, cruizer);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, cruizer);

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

void cruizer_gunner_exit(float _exitflag)
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

float cruizer_gunner_enter(float selectgun)
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
	_gun.vehicle_exit  = cruizer_gunner_exit;
	
	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= cruizer_gunner_enter;
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
	other.PlayerPhysplug    = cruizer_gunner_frame;
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

float cruizervehicles_valid_pilot()
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

void cruizer_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world))
	{
		vehicles_touch();
		return;
	}

	if(cruizervehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(cruizer_gunner_enter(0))
				return;

		if(self.gun2.phase <= time)
			if(cruizer_gunner_enter(0))
				return;
				
		if(self.gun3.phase <= time)
			if(cruizer_gunner_enter(0))
				return;
	}

	vehicles_touch();
}
//Done For multi


float cruizer_frame()
{
    entity player, cruizer;
    vector df;
    float ftmp;

	if(intermission_running)
		return 1;

    player  = self;
    cruizer   = self.vehicle;
    self    = cruizer;

    player.BUTTON_ZOOM = player.BUTTON_CROUCH = 0;

    vehicles_painframe();

    if(cruizer.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }

    cruizer_align4point(frametime);

    crosshair_trace(player);

    cruizer.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_cruizer_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_y - cruizer.angles_y, cruizer.angles_y), ftmp);
    cruizer.angles_y = anglemods(cruizer.angles_y + ftmp);

    // Roll
    cruizer.angles_z += -ftmp * autocvar_g_vehicle_cruizer_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_cruizer_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_x - cruizer.angles_x, cruizer.angles_x), ftmp);
    cruizer.angles_x = bound(-30, anglemods(cruizer.angles_x + ftmp), 30);

    makevectors(cruizer.angles);
    cruizer.angles_x *= -1;

    //ftmp = cruizer.velocity_z;
    df = cruizer.velocity * -autocvar_g_vehicle_cruizer_friction;
    //cruizer.velocity_z = ftmp;

    if(vlen(player.movement) != 0)
    {
        if(player.movement_x)
            df += v_forward * ((player.movement_x > 0) ? autocvar_g_vehicle_cruizer_speed_forward : -autocvar_g_vehicle_cruizer_speed_forward);

        if(player.movement_y)
            df += v_right * ((player.movement_y > 0) ? autocvar_g_vehicle_cruizer_speed_strafe : -autocvar_g_vehicle_cruizer_speed_strafe);

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
    if (player.BUTTON_JUMP && cruizer.vehicle_energy >= (autocvar_g_vehicle_cruizer_afterburn_cost * frametime))
    {
        if(time - cruizer.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        cruizer.wait = time;
        cruizer.vehicle_energy -= autocvar_g_vehicle_cruizer_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_cruizer_speed_afterburn);

        if(cruizer.invincible_finished < time)
        {
            traceline(cruizer.origin, cruizer.origin - '0 0 256', MOVE_NORMAL, self);
            if(trace_fraction != 1.0)
                pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

            cruizer.invincible_finished = time + 0.1 + (random() * 0.1);
        }

        if(cruizer.strength_finished < time)
        {
            cruizer.strength_finished = time + 10.922667; //soundlength("vehicles/racer_boost.wav");
            sound (cruizer.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        cruizer.strength_finished = 0;
        sound (cruizer.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);
    }

	df -= v_up * (vlen(cruizer.velocity) * autocvar_g_vehicle_cruizer_downforce);
	df = vehicles_waterspeed(player, df);
	cruizer.velocity = vehicles_waterfriction(player, cruizer, cruizer.velocity);
    player.movement = cruizer.velocity += df * frametime;

    if(player.BUTTON_ATCK2)
    if(time > cruizer.attack_finished_single)
    if(cruizer.vehicle_ammo1 >= autocvar_g_vehicle_cruizer_cannon_cost)
    {
        cruizer.vehicle_ammo1 -= autocvar_g_vehicle_cruizer_cannon_cost;
        cruizer.wait = time;

        crosshair_trace(player);
        if(cruizer.cnt)
        {
            cruizer_fire_cannon("tag_fire1");
            cruizer.cnt = 0;
        }
        else
        {
            cruizer_fire_cannon("tag_fire2");
            cruizer.cnt = 1;
        }
        cruizer.attack_finished_single = time + autocvar_g_vehicle_cruizer_cannon_refire;
        //self.owner.vehicle_ammo1 = cruizer.vehicle_ammo1 / autocvar_g_vehicle_cruizer_ammo1;
    	cruizer.count = 0; //Will have to press R to resume reload
    }
    
    if not(player.BUTTON_ATCK) {
    	if (cruizer.count == 1) {
        	vehicles_regen(cruizer.wait, vehicle_ammo1, autocvar_g_vehicle_cruizer_energy, autocvar_g_vehicle_cruizer_energy_regen_pause, autocvar_g_vehicle_cruizer_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		cruizer.count = 1;
		sound (cruizer, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores // 1/0.04 = 25 (1 vehic ammo for this vehic)
		vehicles_replenishAmmo(player, cruizer, ammo_rockets, vehicle_ammo1_current, vehicle_ammo1_max, 1, 0.04);
	} 
    }

    if(autocvar_g_vehicle_cruizer_rocket_locktarget)
    {
        vehicles_locktarget((1 / autocvar_g_vehicle_cruizer_rocket_locking_time) * frametime,
                         (1 / autocvar_g_vehicle_cruizer_rocket_locking_releasetime) * frametime,
                         autocvar_g_vehicle_cruizer_rocket_locked_time);

        if(self.lock_target)
        {
            if(cruizer.lock_strength == 1)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0.4 0 0', 0);
            else if(self.lock_strength > 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0.2 0.05 0', 0);
            else if(self.lock_strength < 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '0.05 0.05 0.05', 0);
        }
    }

    if(time > cruizer.delay)
    if(player.BUTTON_ATCK)
    if(player.vehicle_reload1 == 100)
    {
            cruizer_drop_mine("tag_rocket_r");
	    cruizer_drop_mine("tag_rocket_l");
	    cruizer_drop_mine("tag_rocket_r2");
	    cruizer_drop_mine("tag_rocket_l2");
	    cruizer_drop_mine("tag_rocket_r3");
	    cruizer_drop_mine("tag_rocket_l3");
	    
	    cruizer.delay = time + autocvar_g_vehicle_racer_rocket_refire;
            cruizer.lip = time;
    }
    
    if (cruizer.vehicle_ammo2_current > 0) {
    	player.vehicle_reload1 = bound(0, 100 * ((time - cruizer.lip) / (cruizer.delay - cruizer.lip)), 100);
	if (player.vehicle_reload1 < 100) {
		cruizer.vehicle_ammo2_current = cruizer.vehicle_ammo2_current - (1 * sys_frametime);
	}
    }

    if(cruizer.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(cruizer.dmg_time, vehicle_shield, autocvar_g_vehicle_cruizer_shield, autocvar_g_vehicle_cruizer_shield_regen_pause, autocvar_g_vehicle_cruizer_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(cruizer.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(cruizer.dmg_time, vehicle_health, autocvar_g_vehicle_cruizer_health, autocvar_g_vehicle_cruizer_health_regen_pause, autocvar_g_vehicle_cruizer_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(cruizer.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(cruizer.wait, vehicle_energy, autocvar_g_vehicle_cruizer_energy, autocvar_g_vehicle_cruizer_energy_regen_pause, autocvar_g_vehicle_cruizer_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(player, health, cruizer);
    VEHICLE_UPDATE_PLAYER(player, energy, cruizer);

    if(cruizer.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, cruizer);

    if (autocvar_g_vehicles_allowdriveby_drvr > 1 &&
    (vehicles_allowdriveby(1, player, autocvar_g_vehicles_allowdriveby_drvr_hudnorm, 1))) {
		//Do nothing
		player.vehicle_allowdriveby = 1;
		W_VehicleDriveByShootingAim(cruizer, cruizer, player);
    } else {
		player.vehicle_allowdriveby = 0;
    		player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    }
    
    setorigin(player,cruizer.origin + '0 0 32');
    player.velocity = cruizer.velocity;

    player.vehicle_ammo1_current = cruizer.vehicle_ammo1_current;
    player.vehicle_ammo1_max = cruizer.vehicle_ammo1_max;
    player.vehicle_ammo2_current = cruizer.vehicle_ammo2_current;
    player.vehicle_ammo2_max = cruizer.vehicle_ammo2_max;
    player.vehicle_ammo1 = (cruizer.vehicle_ammo1 / autocvar_g_vehicle_cruizer_energy) * 100;

    self = player;
    return 1;
}

void cruizer_think()
{
    self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_cruizer_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_cruizer_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_cruizer_hoverpower + sin(time * 2) * (autocvar_g_vehicle_cruizer_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_cruizer_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_cruizer_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_cruizer_anglestabilizer * pushdeltatime);


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
    //done for multi
}

void cruizer_enter()
{
    self.touch = cruizer_touch; //Added for multi
    self.nextthink = 0;  //Added for multi
    
    self.movetype = MOVETYPE_BOUNCE;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_cruizer_health)  * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_cruizer_shield)  * 100;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-190 0 96');

	//targetdrone_spawn(self.origin + '0 0 512' + randomvec() * 256, 1);
}

void cruizer_exit(float eject)
{
    vector spot;
    
    self.touch = vehicles_touch; //Added for multi
    self.think      = cruizer_think;
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

void cruizer_impact()
{
    if(autocvar_g_vehicle_cruizer_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_cruizer_bouncepain_x, autocvar_g_vehicle_cruizer_bouncepain_y, autocvar_g_vehicle_cruizer_bouncepain_z);
}

void cruizer_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);

    RadiusDamage (self, self.enemy, autocvar_g_vehicle_cruizer_blowup_coredamage,
					autocvar_g_vehicle_cruizer_blowup_edgedamage,
					autocvar_g_vehicle_cruizer_blowup_radius, world,
					autocvar_g_vehicle_cruizer_blowup_forceintensity,
					DEATH_WAKIBLOWUP, world);

    self.nextthink  = time + autocvar_g_vehicle_cruizer_respawntime;
    self.think      = cruizer_spawn_default;
    self.movetype   = MOVETYPE_NONE;
    self.effects    = EF_NODRAW;

    self.colormod  = '0 0 0';
    self.avelocity = '0 0 0';
    self.velocity  = '0 0 0';

    setorigin(self, self.pos1);
}

void cruizer_deadtouch()
{
    self.avelocity_x *= 0.7;
    self.cnt -= 1;
    if(self.cnt <= 0)
        cruizer_blowup();
}

void cruizer_die()
{
//Added for multi
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
    //done for multi
    
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.wait         = time;
    self.cnt          = 1 + random() * 2;
    self.touch        = cruizer_deadtouch;

    pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

    if(random() < 0.5)
        self.avelocity_z  = 32;
    else
        self.avelocity_z  = -32;

    self.avelocity_x = -vlen(self.velocity) * 0.2;
    self.velocity   += '0 0 700';
    self.colormod    = '-0.5 -0.5 -0.5';

	self.think     = cruizer_blowup;
	self.nextthink = 2 + time + random() * 3;
}
void cruizer_spawn(float _spawnflag)
{
    self.vehicle_pilotchangeseat = cruizer_gunner_enter; //Function to exec if pilot wants to change seat, added for multi

    if(self.scale != 0.5)
    {
    	self.lodmodel1 = "models/vehicles/cruizer_lod1.iqm";
    	self.lodmodel2 = "models/vehicles/cruizer_lod2.iqm";
    	self.lodmodel3 = "models/vehicles/cruizer_lod3.iqm";
    	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
        if(autocvar_g_vehicle_cruizer_hovertype != 0)
            cruizer_force_from_tag = vehicles_force_fromtag_maglev;
        else
            cruizer_force_from_tag = vehicles_force_fromtag_hover;

        // FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        self.scale = 0.5;
        setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self, "tag_viewport");

        self.mass               = autocvar_g_vehicle_cruizer_mass;
	
		//Added for multi
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

		setattachment(self.gun1, self, "null");
		setattachment(self.gun2, self, "null");
		setattachment(self.gun3, self, "null");
		
		vehicle_addplayerslot(self, self.gun1, HUD_WAKIZASHI, "models/vehicles/cruizer_interior.iqm", cruizer_gunner_frame, cruizer_gunner_exit);
		vehicle_addplayerslot(self, self.gun2, HUD_WAKIZASHI, "models/vehicles/cruizer_interior.iqm", cruizer_gunner_frame, cruizer_gunner_exit);
		vehicle_addplayerslot(self, self.gun3, HUD_WAKIZASHI, "models/vehicles/cruizer_interior.iqm", cruizer_gunner_frame, cruizer_gunner_exit);
    		
		self.gun1.vehicle_viewport.origin = '0 -38 80';
		self.gun2.vehicle_viewport.origin = '-64 32 90'; //Sitting ontop of ammo box
		self.gun3.vehicle_viewport.origin = '-64 -32 90'; //Sitting ontop of ammo box
		//Done for multi
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.think          = cruizer_think;
    self.nextthink      = time;
    self.vehicle_health = autocvar_g_vehicle_cruizer_health;
    self.vehicle_shield = autocvar_g_vehicle_cruizer_shield;

    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.delay          = time;
    self.scale          = 0.5;

    setsize(self, CRUIZER_MIN * 0.5, CRUIZER_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_cruizer_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_cruizer_bouncestop;
    self.vehicle_impact = cruizer_impact;
    self.damageforcescale = 0.5;
    self.vehicle_hudmodel.colormap = self.vehicle.colormap;

    //self.destvec = autocvar_g_vehicle_cruizer_bouncepain;
}
void cruizer_spawn_default()
{
	cruizer_spawn(0);
}



void spawnfunc_vehicle_cruizer()
{
    if(!autocvar_g_vehicle_cruizer)
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

    precache_sound ("vehicles/racer_idle.wav");
    precache_sound ("vehicles/racer_move.wav");
    precache_sound ("vehicles/racer_boost.wav");

    precache_model ("models/vhshield.md3");
    precache_model ("models/vehicles/cruizer_exterior.iqm");
    precache_model ("models/vehicles/cruizer_interior.iqm");
    precache_model("models/vehicles/cruizer_lod1.iqm");
    precache_model("models/vehicles/cruizer_lod2.iqm");
    precache_model("models/vehicles/cruizer_lod3.iqm");
    precache_model ("models/mine.md3");

	precache_sound ("weapons/mine_det.wav");
	precache_sound ("weapons/mine_fire.wav");
	precache_sound ("weapons/mine_stick.wav");
	precache_sound ("weapons/mine_trigger.wav");
	
	precache_sound ("weapons/grenade_bounce1.wav");
	precache_sound ("weapons/grenade_bounce2.wav");
	precache_sound ("weapons/grenade_bounce3.wav");
	precache_sound ("weapons/grenade_bounce4.wav");
	precache_sound ("weapons/grenade_bounce5.wav");
	precache_sound ("weapons/grenade_bounce6.wav");
	precache_sound ("weapons/grenade_stick.wav");
	precache_sound ("weapons/grenade_fire.wav");

    if(autocvar_g_vehicle_cruizer_energy)
        if(autocvar_g_vehicle_cruizer_energy_regen)
            self.vehicle_flags |= VHF_ENERGYREGEN;

    if(autocvar_g_vehicle_cruizer_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_cruizer_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_cruizer_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

    if not (vehicle_initialize(
             "Cruizer",
             "models/vehicles/cruizer_exterior.iqm",
             "null", // we need this so tur_head is networked and usable for sounds
             "models/vehicles/cruizer_interior.iqm",
             "", "", "tag_viewport",
             HUD_WAKIZASHI,
             0.5 * CRUIZER_MIN, 0.5 * CRUIZER_MAX,
             FALSE,
             cruizer_spawn, autocvar_g_vehicle_cruizer_respawntime,
             cruizer_frame,
             cruizer_enter, cruizer_exit,
             cruizer_die,   cruizer_think,
             TRUE, 
             autocvar_g_vehicle_cruizer_health,
             autocvar_g_vehicle_cruizer_shield, autocolor, autocvar_g_vehicle_cruizer_energy * 4, autocvar_g_vehicle_racer_rocket_refire * 2))
	    	//1023 == Hack for black colormap
		//Not likely to be any 1023rd colormap
		//So it's black.
    {
        remove(self);
        return;
    }
}
#endif // SVQC
