const vector TANKLL37_MIN = '-100 -100 2';
const vector TANKLL37_MAX  = '100 100 136';

const vector TANKLL37_MIN_HBF = '-80 -80 2';
const vector TANKLL37_MAX_HBF = '80 80 90';

const vector TANKLL37_MIN_HBB = '-60 -60 2';
const vector TANKLL37_MAX_HBB = '60 60 64';

#ifdef SVQC
float autocvar_g_vehicle_tankll37;

float autocvar_g_vehicle_tankll37_respawntime;

float autocvar_g_vehicle_tankll37_speed_stop;
float autocvar_g_vehicle_tankll37_speed_strafe;
float autocvar_g_vehicle_tankll37_speed_walk;
float autocvar_g_vehicle_tankll37_movement_inertia;

float autocvar_g_vehicle_tankll37_springlength;
float autocvar_g_vehicle_tankll37_springup;
float autocvar_g_vehicle_tankll37_springblend;
float autocvar_g_vehicle_tankll37_tiltlimit;

float autocvar_g_vehicle_tankll37_gun_pitchlimit_down;
float autocvar_g_vehicle_tankll37_gun_pitchlimit_up;
float autocvar_g_vehicle_tankll37_gun_pitchspeed;
//float autocvar_g_vehicle_tankll37_gun_turnlimit;
//float autocvar_g_vehicle_tankll37_gun_turnspeed;

float autocvar_g_vehicle_tankll37_turret_turnlimit;
float autocvar_g_vehicle_tankll37_turret_turnspeed;

//float autocvar_g_vehicle_tankll37_energy;
//float autocvar_g_vehicle_tankll37_energy_regen;
//float autocvar_g_vehicle_tankll37_energy_regen_pause;

float autocvar_g_vehicle_tankll37_health;
float autocvar_g_vehicle_tankll37_health_regen;
float autocvar_g_vehicle_tankll37_health_regen_pause;

float autocvar_g_vehicle_tankll37_shield;
float autocvar_g_vehicle_tankll37_shield_regen;
float autocvar_g_vehicle_tankll37_shield_regen_pause;

float autocvar_g_vehicle_tankll37_machinegun_refire;
float autocvar_g_vehicle_tankll37_machinegun_ammo_cost;
float autocvar_g_vehicle_tankll37_machinegun_ammo_max;
float autocvar_g_vehicle_tankll37_machinegun_ammo_regen;
float autocvar_g_vehicle_tankll37_machinegun_ammo_regen_pause;

float autocvar_g_vehicle_tankll37_cannon_refire;
float autocvar_g_vehicle_tankll37_cannon_ammo_cost;
float autocvar_g_vehicle_tankll37_cannon_ammo_max;
float autocvar_g_vehicle_tankll37_cannon_ammo_regen;
float autocvar_g_vehicle_tankll37_cannon_ammo_regen_pause;
float autocvar_g_vehicle_tankll37_cannon_iter;
float autocvar_g_vehicle_tankll37_cannon_iterforward;
float autocvar_g_vehicle_tankll37_cannon_fragments;
float autocvar_g_vehicle_tankll37_cannon_pitchspeed;
float autocvar_g_vehicle_tankll37_cannon_pitchlimit_down;
float autocvar_g_vehicle_tankll37_cannon_pitchlimit_up;

vector autocvar_g_vehicle_tankll37_bouncepain;


void tankll37_exit(float eject);
void tankll37_enter();
void tankll37_spawn(float);

void tankll37_Grenade_Explode2 (void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	
	float	xc;
	for (xc = 0;xc < autocvar_g_vehicle_tankll37_cannon_iter;xc = xc + 1) {
	
		RadiusDamage (self, self.realowner, autocvar_g_balance_electro_combo_damage,
		autocvar_g_balance_electro_combo_edgedamage,
		autocvar_g_balance_electro_combo_radius, world,
		autocvar_g_balance_electro_combo_force,
		self.projectiledeathtype, other);
		
		//OilFire_explosion_spawnoilburnermaybe(self);
		////This is an energy weap, not explosive or fire, chem flash more appropriate:
		Chemical_flash_maybe(self);
		
		pointparticles(particleeffectnum("newelectro_combo"), self.origin + '0 0 32', '0 0 0', 1);
		//pointparticles(particleeffectnum("PROJECTILE_BUMBLE_GUN"), self.origin + '0 0 32', '0 0 0', 1);
		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
		//Start Grenade Fragmentation
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_tankll37_cannon_fragments;sc = sc + 1) {
	

		 float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife;
		 mydmg = autocvar_g_balance_nex_primary_damage;
		 myforce = autocvar_g_balance_nex_primary_force;
		 mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		 mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		 myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		 myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		
		 FireRailgunBullet (self.origin, self.origin + randomvec() * MAX_SHOT_DISTANCE,
		 mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);

		//vector u;
		//u = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
		//WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		//WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
		//WriteCoord(MSG_BROADCAST, self.origin_x);
		//WriteCoord(MSG_BROADCAST, self.origin_y);
		//WriteCoord(MSG_BROADCAST, self.origin_z);
		//WriteCoord(MSG_BROADCAST, u_x);
		//WriteCoord(MSG_BROADCAST, u_y);
		//WriteCoord(MSG_BROADCAST, u_z);
		//WriteByte(MSG_BROADCAST, bound(0, 255, 255));
			
		}
		//Finish Grenade Fragmentation
		}
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');

			setorigin(self, (self.origin + v_forward * autocvar_g_vehicle_tankll37_cannon_iterforward)); //Forward X qunits
	}

	remove (self);
}

void tankll37_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	spamsound (self, CH_SHOTS, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);
	self.use ();
}

void tankll37_autonex(entity gun, entity pilot, entity gunmount)
{
   
    if(pilot.BUTTON_ATCK)
    {
    	mg_autonex_fire(gun, pilot, gunmount);
    } else {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_tankll37_machinegun_ammo_max,
                                           autocvar_g_vehicle_tankll37_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_tankll37_machinegun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
}

void tankll37_fire_cannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun2, gettagindex(self.gun2, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/electro_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


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
	gren.projectiledeathtype = WEP_ELECTRO;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll37_Grenade_Explode2;
	gren.touch = tankll37_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankll37_cannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_BUMBLE_GUN, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float tankll37_aiframe()
{
    return FALSE;
}




//Add For multi
float tankll37_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;

	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin + '0 0 32'); //+32 so not in ground

	gunner.velocity = vehic.velocity;
	
    ////////
    ////////
    if ((gun == vehic.gun0)) {
    
    //For gun0 (top gun)
    
    makevectors(gun.angles);
    
    float ftmp;
    vector ad;
    vector myvehicangles;
    myvehicangles = vehic.angles;
    
    
    ad = gettaginfo(gun, gettagindex(gun, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, vehic);
    
   
    crosshair_trace2(gunner);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(myvehicangles), AnglesTransform_FromAngles(ad))) - gun.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);



    // Yaw //KISS
    float gunnerangley;
    
   
    //Forward facing
    gunnerangley = gunner.v_angle_y - vehic.angles_y - vehic.tur_head.angles_y;
    
    
    //ftmp = autocvar_g_vehicle_tankll37_gun_turnspeed * sys_frametime;
    ftmp = autocvar_g_vehicle_tankll37_turret_turnspeed * 2 * sys_frametime;

    ftmp = bound(-ftmp, shortangle_f(gunnerangley - gun.angles_y, gun.angles_y), ftmp);
    gun.angles_y = anglemods(gun.angles_y + ftmp);

    // Pitch head
    ftmp = autocvar_g_vehicle_tankll37_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    gun.angles_x = bound(autocvar_g_vehicle_tankll37_gun_pitchlimit_down, gun.angles_x + ad_x, autocvar_g_vehicle_tankll37_gun_pitchlimit_up);



	
		tankll37_autonex(vehic, gunner, gun); //
    
    }
    ////////
    ////////
	

	VEHICLE_UPDATE_PLAYER(gunner, health, tankll37);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, tankll37);

	
	if (gun == vehic.gun0) {
		UpdateAuxiliaryXhair(gunner, trace_endpos, '0 1 1', 0);
	}

	vehic.solid = SOLID_SLIDEBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;

	gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
	gunner.vehicle_ammo2_current = vehic.vehicle_ammo2_current;
    	gunner.vehicle_ammo2_max = vehic.vehicle_ammo2_max;

	self = gunner;
	return 1;
}

void tankll37_gunner_exit(float _exitflag)
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
	}
	else if(self == self.vehicle.owner.gunner3)
	{
		self.vehicle.owner.gunner3 = world;
	}
	else
		dprint("^1self != gunner1,2,3,4,5,6,...,14, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 132 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float tankll37_gunner_enter(float selectgun)
{
	RemoveGrapplingHook(other);
	entity _gun, _gunner;
	if(!self.gunner1 && (!selectgun || selectgun == 1))
	{
		_gun = self.gun0;
		_gunner = self.gunner1;
		self.gunner1 = other;
	}
	else if(!self.gunner2 && (!selectgun || selectgun == 2))
	{
		_gun = self.gun00;
		_gunner = self.gunner2;
		self.gunner2 = other;
	}
	else if(!self.gunner3 && (!selectgun || selectgun == 3))
	{
		_gun = self.gun000;
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
	_gun.vehicle_exit  = tankll37_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= tankll37_gunner_enter;
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
	other.PlayerPhysplug    = tankll37_gunner_frame;
	other.flags             &~= FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	if (_gun == self.gun0) {
		//Spontoon gun - Front facing
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x + _gun.owner.tur_head.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y + _gun.owner.tur_head.angles_y);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll
	} else {
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll
	}
	_gun.vehicle_hudmodel.viewmodelforclient = other;

	CSQCVehicleSetup(other, other.hud);
	
    vh_player = other;
    vh_vehicle = _gun;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    _gun = vh_vehicle;

	return TRUE;
}

float tankll37vehicles_valid_pilot()
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

void tankll37_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world && self.gunner5 != world && self.gunner6 != world && self.gunner7 != world && self.gunner8 != world && self.gunner9 != world && self.gunner10 != world && self.gunner11 != world && self.gunner12 != world && self.gunner13 != world))
	{
		tankt27_vehicles_touch();
		return;
	}

	if(tankll37vehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun0.phase <= time)
			if(tankll37_gunner_enter(0))
				return;
		
		if(self.gun00.phase <= time)
			if(tankll37_gunner_enter(0))
				return;
		
		if(self.gun000.phase <= time)
			if(tankll37_gunner_enter(0))
				return;
	}

	tankt27_vehicles_touch();
}



//Done For multi




float tankll37_frame()
{
    vector ad, vf;
    entity player, tankll37;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    tankll37 = self.vehicle;
    self   = tankll37;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;

    ad = gettaginfo(tankll37.gun3, gettagindex(tankll37.gun3, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll37);
    
    vf = ad;
    ad = gettaginfo(tankll37.gun2, gettagindex(tankll37.gun2, "tag_cannon"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll37);
    UpdateAuxiliaryXhair(player, trace_endpos, '0 1 1', 1);
    //ad = 0.5 * (ad + vf);
    ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll37.angles), AnglesTransform_FromAngles(ad))) - tankll37.gun3.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    
    //Make sure angles are fine
    //if(tankll37.tur_head.angles_y > 180)  tankll37.tur_head.angles_y -= 360; if(tankll37.tur_head.angles_y < -180) tankll37.tur_head.angles_y += 360;
    
 
    //Rotate Turret and stabilizing "gun3" (rotates faster than turret)
    ftmp = autocvar_g_vehicle_tankll37_turret_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    if (player.isvehiclepilotplaceholder) {
    	//Do Nothing, no turret rotation
    } else {
    	tankll37.gun3.angles_y = bound(autocvar_g_vehicle_tankll37_turret_turnlimit * -1, tankll37.gun3.angles_y + ad_y, autocvar_g_vehicle_tankll37_turret_turnlimit);
    	tankll37.tur_head.angles_y = tankll37.gun3.angles_y;
    }

    /////////////////////////
    //Stuff for actual mgun
    ad = gettaginfo(tankll37.gun1, gettagindex(tankll37.gun1, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll37);
    UpdateAuxiliaryXhair(player, trace_endpos, '0 1 1', 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll37.angles), AnglesTransform_FromAngles(ad))) - tankll37.gun1.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    
    //ftmp = autocvar_g_vehicle_tankll37_gun_turnspeed * sys_frametime;    
    //ad_y = bound(-ftmp, ad_y, ftmp);
    //tankll37.gun1.angles_y = bound(autocvar_g_vehicle_tankll37_gun_turnlimit * -1, tankll37.gun1.angles_y + ad_y, autocvar_g_vehicle_tankll37_gun_turnlimit);

    
    // Pitch head
    ftmp = autocvar_g_vehicle_tankll37_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    tankll37.gun1.angles_x = bound(autocvar_g_vehicle_tankll37_gun_pitchlimit_down, tankll37.gun1.angles_x + ad_x, autocvar_g_vehicle_tankll37_gun_pitchlimit_up);


    //fixedmakevectors(tankll37.angles);
    makevectors(tankll37.angles + '-2 0 0' * tankll37.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_tankll37_springlength, autocvar_g_vehicle_tankll37_springup, autocvar_g_vehicle_tankll37_springblend, autocvar_g_vehicle_tankll37_tiltlimit);

    if(tankll37.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("tankll37_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_tankll37_speed_stop);
                //tankll37.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0)
   	 {
	 	if(tankll37.angles_y > 180)  tankll37.angles_y -= 360;
    		if(tankll37.angles_y < -180) tankll37.angles_y += 360;
		tankll37.angles_y = bound(-184,tankll37.angles_y + ((player.movement_y * sys_frametime) / -6.66666),184);	
		
		if(tankll37.angles_y >= -1 && tankll37.angles_y <= -1)
            		tankll37.angles_y = 0;	
		
		//Unlike the T27 tank, we do it alittle more complex way so the turret can 
		//be independent somewhat
		float degree_y;
		player.angles_y = player.angles_y + ((player.movement_y * sys_frametime) / -6.66666);
		degree_y = ((player.movement_y * sys_frametime) / -6.66666);
		player.v_angle_y += degree_y;
		
		////player.v_angle_y = tankll37.angles_y; //kiss //T27

		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}
		
		////////player.angles_y = player.angles_y + (player.movement_y / -200);
		////////player.fixangle = TRUE;
		
		//////msg_entity = player;
  		//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		//////WriteAngle( MSG_ONE, tankll37.angles_x); 
  		//////WriteAngle( MSG_ONE, tankll37.angles_y);
  		//////WriteAngle( MSG_ONE, tankll37.angles_z);
		if (player.movement_y > 0) {
			self.bomb1.gun1.avelocity_y = 75; //gear
                	self.bomb1.gun2.avelocity_y = 90; //wheel
                	self.bomb2.gun1.avelocity_y = -75; //gear
                	self.bomb2.gun2.avelocity_y = -90; //wheel
		} else {
			self.bomb1.gun1.avelocity_y = -75; //gear
                	self.bomb1.gun2.avelocity_y = -90; //wheel
                	self.bomb2.gun1.avelocity_y = 75; //gear
                	self.bomb2.gun2.avelocity_y = 90; //wheel
		}
	 }
	 
	 if(player.movement_x != 0)
         {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        tankll37.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        tankll37.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(tankll37.angles);
    			makevectors(tankll37.angles + '-2 0 0' * tankll37.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_tank_waterspeed_simple(player, autocvar_g_vehicle_tankll37_speed_walk),autocvar_g_vehicle_tankll37_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 4; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("tankll37_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_tankll37_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_tankll37_tiltlimit, self.angles_x, autocvar_g_vehicle_tankll37_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_tankll37_tiltlimit, self.angles_z, autocvar_g_vehicle_tankll37_tiltlimit);

    if(player.BUTTON_JUMP) {
    	tankll37.gun2.angles_x = bound(autocvar_g_vehicle_tankll37_cannon_pitchlimit_down, tankll37.gun2.angles_x + (autocvar_g_vehicle_tankll37_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll37_cannon_pitchlimit_up);
    }
    
    if(player.BUTTON_CROUCH ) {
    	tankll37.gun2.angles_x = bound(autocvar_g_vehicle_tankll37_cannon_pitchlimit_down, tankll37.gun2.angles_x - (autocvar_g_vehicle_tankll37_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll37_cannon_pitchlimit_up);
    }
    
    player.BUTTON_CROUCH    = 0;

    if(player.BUTTON_ATCK)
    {
        tankll37.cnt = time;
        if(tankll37.vehicle_ammo1 >= autocvar_g_vehicle_tankll37_machinegun_ammo_cost && tankll37.gun1.attack_finished_single <= time)
        {
		vector v;
		tankll37.misc_bulletcounter += 1;

		self = player;

		v = gettaginfo(tankll37.gun1, gettagindex(tankll37.gun1, "tag_mgun"));
		makevectors(player.v_angle);
		v_forward = normalize(v_forward);
		//   v += v_forward * 50;

		float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife;
		 mydmg = autocvar_g_balance_nex_primary_damage;
		 myforce = autocvar_g_balance_nex_primary_force;
		 mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		 mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		 myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		 myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		
		FireRailgunBullet (v, v + v_forward * MAX_SHOT_DISTANCE,
		 mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);

		vector u;
		u = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
		WriteCoord(MSG_BROADCAST, v_x);
		WriteCoord(MSG_BROADCAST, v_y);
		WriteCoord(MSG_BROADCAST, v_z);
		WriteCoord(MSG_BROADCAST, u_x);
		WriteCoord(MSG_BROADCAST, u_y);
		WriteCoord(MSG_BROADCAST, u_z);
		WriteByte(MSG_BROADCAST, bound(0, 255, 255));

		pointparticles(particleeffectnum("electro_muzzleflash"), v, v_forward, 1);
	     
		sound (tankll37.gun1, CH_WEAPON_A, "weapons/nexfire.wav", VOL_BASE, ATTN_NORM);


            self = tankll37;

            tankll37.vehicle_ammo1 -= autocvar_g_vehicle_tankll37_machinegun_ammo_cost;
            tankll37.gun1.attack_finished_single = time + autocvar_g_vehicle_tankll37_machinegun_refire;
            player.vehicle_ammo1 = (tankll37.vehicle_ammo1 / autocvar_g_vehicle_tankll37_machinegun_ammo_max) * 100;
         
        }
    }
    else
        vehicles_regen(tankll37.cnt, vehicle_ammo1, autocvar_g_vehicle_tankll37_machinegun_ammo_max,
                                           autocvar_g_vehicle_tankll37_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_tankll37_machinegun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
        

    if(player.BUTTON_ATCK2)
    {
        tankll37.cnt = time;
        if(tankll37.vehicle_ammo2 >= autocvar_g_vehicle_tankll37_cannon_ammo_cost && tankll37.tur_head.attack_finished_single <= time)
        {
            vector v;
            tankll37.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(tankll37.gun2, gettagindex(tankll37.gun2, "tag_cannon"));
            v_forward = normalize(v_forward);
            v += v_forward * 12;
  	 // Start Ballistic bullet
	 
   	 // fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll37_cannon_spread, autocvar_g_vehicle_tankll37_cannon_speed, 5, autocvar_g_vehicle_tankll37_cannon_damage, autocvar_g_vehicle_tankll37_cannon_headshotaddeddamage, autocvar_g_vehicle_tankll37_cannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll37_cannon_bulletconstant, autocvar_g_vehicle_tankll37_cannon_coreshotaddeddamage);
    	 //endFireBallisticBullet();
	 
	 
	 //sound (tankll37.gun2, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);

	// End Ballistic bullet

            pointparticles(particleeffectnum("bigplasma_muzzleflash"), v, v_forward, 1);


            self = tankll37;
	    
	    makevectors(self.angles);
	    v = gettaginfo(tankll37.gun2, gettagindex(tankll37.gun2, "tag_cannon"));
            v_forward = normalize(v_forward);
	    
	    tankll37_fire_cannon("tag_cannon");


            tankll37.vehicle_ammo2 -= autocvar_g_vehicle_tankll37_cannon_ammo_cost;
            tankll37.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll37_cannon_refire;
            player.vehicle_ammo2 = (tankll37.vehicle_ammo2 / autocvar_g_vehicle_tankll37_cannon_ammo_max) * 100;
         
        }
    }
    else
        vehicles_regen(tankll37.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll37_cannon_ammo_max,
                                           autocvar_g_vehicle_tankll37_cannon_ammo_regen_pause,
                                           autocvar_g_vehicle_tankll37_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
      
    
    
    //tankll37_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(tankll37.dmg_time, vehicle_shield, autocvar_g_vehicle_tankll37_shield, autocvar_g_vehicle_tankll37_shield_regen_pause, autocvar_g_vehicle_tankll37_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(tankll37.dmg_time, vehicle_health, autocvar_g_vehicle_tankll37_health, autocvar_g_vehicle_tankll37_health_regen_pause, autocvar_g_vehicle_tankll37_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = tankll37.tur_head.frame;

    if(tankll37.gun2.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((tankll37.gun2.cnt - time) / tankll37.attack_finished_single) * 100;

    setorigin(player, tankll37.origin + '0 0 1' * TANKLL37_MAX_z);
    tankll37.velocity = vehicles_tank_waterfriction(player, tankll37.velocity);
    player.velocity = tankll37.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, tankll37);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, tankll37);


    //Gun3 is out invisible angle stabilizer/reducer
    //tur_head gets its value from it above, so we act on it here
    //print(sprintf("m1 = %f\n", tankll37.gun3.angles_y));
    if(tankll37.gun3.angles_y > 180) {
    	//print("here 1\n");
    	tankll37.gun3.angles_y = tankll37.gun3.angles_y - 360;
	//print(sprintf("m2 = %f\n", tankll37.gun3.angles_y));
    } else if(tankll37.gun3.angles_y < -180) {
    	//print("here 2\n");
    	tankll37.gun3.angles_y = tankll37.gun3.angles_y + 360;
	//print(sprintf("m2 = %f\n", tankll37.gun3.angles_y));
    }
    
    player.vehicle_ammo1_current = tankll37.vehicle_ammo1_current;
    player.vehicle_ammo1_max = tankll37.vehicle_ammo1_max;
    player.vehicle_ammo2_current = tankll37.vehicle_ammo2_current;
    player.vehicle_ammo2_max = tankll37.vehicle_ammo2_max;

    self = player;
    return 1;    
}
void tankll37_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_tankll37_speed_stop);

    self.nextthink = time;
    
    
    //Added for multi
    	if(!self.owner)
	{
		entity oldself = self;		
		if(self.gunner1)
		{
			self = self.gunner1;
			oldself.gun0.vehicle_exit(VHEF_EJECT);
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
			oldself.gun00.vehicle_exit(VHEF_EJECT);
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
			oldself.gun000.vehicle_exit(VHEF_EJECT);
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

void tankll37_enter()
{
    self.touch = tankll37_touch; //Added for multi
    self.nextthink = 0;  //Added for multi
    
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankll37_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankll37_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void tankll37_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = tankll37_think;
    self.touch = tankt27_vehicles_touch; //Added for multi
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_tankll37_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void tankll37_impact()
{
    if(autocvar_g_vehicle_tankll37_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_tankll37_bouncepain_x, autocvar_g_vehicle_tankll37_bouncepain_y, autocvar_g_vehicle_tankll37_bouncepain_z);    
}

void tankll37_headfade()
{
	self.think = tankll37_headfade;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;

    if(self.cnt < time || self.alpha < 0.1)
    {
        if(self.alpha > 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_big"), self.origin + '0 0 100', '0 0 0', 1);
        }
        remove(self);
    }
}

void tankll37_blowup()
{
    if(self.cnt > time)
    {
        if(random() < 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
        }
        self.nextthink = time + 0.1;
        return;
    }
    
    entity h, g1, g2, b;
    b = spawn();
    h = spawn();
    g1 = spawn();
    g2 = spawn();
    
    b.lodmodel1 = "models/vehicles/tankll37_lod1.iqm";
    b.lodmodel2 = "models/vehicles/tankll37_lod2.iqm";
    setmodel(b,  "models/vehicles/tankll37.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    setmodel(h,  "models/vehicles/tankll37_turret.iqm");
    setmodel(g1, "models/vehicles/tankll37_cannon.iqm");
    setmodel(g2, "models/vehicles/tankt27_gear.iqm");

    setorigin(b, self.origin);
    b.frame         = 11;
    b.angles        = self.angles;
    setsize(b, self.mins, self.maxs);

    setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
    h.movetype      = MOVETYPE_BOUNCE;
    h.solid         = SOLID_BBOX;
    h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
    h.modelflags    = MF_ROCKET;
    h.effects       = EF_FLAME | EF_LOWPRECISION;
    h.avelocity     = randomvec() * 360;

    h.alpha         = 1;
    h.cnt           = time + (3.5 * random());
    h.fade_rate     = 1 / min(autocvar_g_vehicle_tankll37_respawntime, 10);
    h.fade_time     = time;
    h.think         = tankll37_headfade;
    h.nextthink     = time;

    setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
    g1.movetype     = MOVETYPE_TOSS;
    g1.solid        = SOLID_CORPSE;
    g1.velocity     = v_forward * 700 + (randomvec() * 32);
    g1.avelocity    = randomvec() * 180;

    setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
    g2.movetype     = MOVETYPE_TOSS;
    g2.solid        = SOLID_CORPSE;
    g2.velocity     = v_forward * 700 + (randomvec() * 32);
    g2.avelocity    = randomvec() * 180;

    h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankll37_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankll37_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankll37_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankll37_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.gun0.alpha = self.gun00.alpha = self.gun000.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void tankll37_die()
{
	//Added for multi
	entity oldself = self;
		
	if(self.gunner1)
	{
		self = self.gunner1;
		oldself.gun0.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner2)
	{
		self = self.gunner2;
		oldself.gun00.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner3)
	{
		self = self.gunner3;
		oldself.gun000.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	self.vehicle_exit(VHEF_EJECT);
	
	//done for multi

    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = tankll37_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
    tankt27_hitbox_die(self.hitboxft);
    tankt27_hitbox_die(self.hitboxbk);
}

void tankll37_spawn(float _f)
{
    self.vehicle_pilotchangeseat = tankll37_gunner_enter; //Function to exec if pilot wants to change seat, added for multi

    self.buff_wont_ignite = 1;
    self.vehicle_tankresists = 1;
    self.vehicle_pounddownclass = 2; //Pretty big 
    
    if(!self.gun1)
    {
    	self.lodmodel1 = "models/vehicles/tankll37_lod1.iqm";
	self.lodmodel2 = "models/vehicles/tankll37_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
	//Turret Rotation stabilizer
	self.gun3 = spawn(); //Will be an angle stabilizer for the rotating turret
	self.gun3.alpha = -1;
	setmodel(self.gun3, "models/vehicles/anglestabilizer.iqm");
	setattachment(self.gun3, self.tur_head, "tag_cannon_pivot");
	
	self.gun0               = spawn(); //Added for multi
	self.gun00               = spawn(); //Added for multi
	self.gun000               = spawn(); //Added for multi
        self.gun1               = spawn();
        self.gun2               = spawn();    
        setmodel(self.gun1, "models/mountedguns/autonexgun.iqm");
		//LOD stuff.
		self.gun1.owner = self;
		self.gun1.lodowner = 1; //Use owner origin for computing LOD
		self.gun1.lodmodel1 = "models/mountedguns/autonexgun_lod1.iqm";
		InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
        setmodel(self.gun2, "models/vehicles/tankll37_cannon.iqm");
        setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
        setattachment(self.gun2, self.tur_head, "tag_cannon_pivot");
        self.gravity            = 2;
        self.mass               = 5000;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun2 = spinner;
	
	//Added for multi
	//Add
	self.vehicle_flags |= VHF_MULTISLOT;
	setmodel(self.gun0, "null");
	self.gun0.owner = self;
	self.gun0.lodowner = 1; //Use owner origin for computing LOD
	self.gun0.lodmodel1 = "models/mountedguns/autonexgun.iqm";
        setmodel(self.gun0, "models/mountedguns/autonexgun_lod1.iqm");
	InitializeEntity(self.gun0, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(self.gun0, self.tur_head, "tag_gunpivot");
	self.gun0.origin = '-80 0 14.75';
	self.gun0.owner = self;
	//Done for multi
	
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun1, "tag_gcamera");
	setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	//Added for multi
	vehicle_addplayerslot(self, self.gun0, HUD_WAKIZASHI, "null", tankiv_gunner_frame, tankiv_gunner_exit);
	setattachment(self.gun0.vehicle_viewport, self.gun0, "tag_camera");
	self.gun0.vehicle_viewport.origin = '0 0 3';
	//Done for multi
	
	self.gun1.colormap = self.colormap;
	self.gun0.colormap = self.colormap; //Added for multi
	
	
		self.gun00.owner = self;
		self.gun000.owner = self;

		setmodel(self.gun00, "null");
		setmodel(self.gun000, "null");

		setattachment(self.gun00, self, "null");
		setattachment(self.gun000, self, "null");
		
		vehicle_addplayerslot(self, self.gun00, HUD_WAKIZASHI, "models/vehicles/tankll37_interior.iqm", tankll37_gunner_frame, tankll37_gunner_exit);
		vehicle_addplayerslot(self, self.gun000, HUD_WAKIZASHI, "models/vehicles/tankll37_interior.iqm", tankll37_gunner_frame, tankll37_gunner_exit);
    		
		self.gun00.vehicle_viewport.origin = '64 32 80'; 
		self.gun000.vehicle_viewport.origin = '64 -32 80';
		
	self.hitboxft = spawn();
    	self.hitboxbk = spawn();
    }
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = tankll37_think;
    self.touch              = tankt27_vehicles_touch2;
    self.subordinate        = self.hitboxft; //For testing max_z in determining if should crush a player or monster
    self.subordinatespeed   = autocvar_g_vehicle_tankll37_speed_walk;
    self.subordinateinertia = autocvar_g_vehicle_tankll37_movement_inertia;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_tankll37_health;
    self.vehicle_shield     = autocvar_g_vehicle_tankll37_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.gun0.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun2.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = tankll37_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
    
    tankt27_spawn_hitbox(0, self, self.hitboxft, TANKLL37_MIN_HBF, TANKLL37_MAX_HBF, 124, autocvar_g_vehicle_tankll37_health);
    tankt27_spawn_hitbox(1, self, self.hitboxbk, TANKLL37_MIN_HBB, TANKLL37_MAX_HBB, -120, autocvar_g_vehicle_tankll37_health * 0.5);
}

void spawnfunc_vehicle_tankll37()
{
    if(!autocvar_g_vehicle_tankll37)
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
    //self.vehicle_flags |= VHF_DMGROLL;
    //self.vehicle_flags |= VHF_DMGHEADROLL;
    
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/vehicles/tankll37.iqm");
    precache_model ( "models/vehicles/tankll37_lod1.iqm");
    precache_model ( "models/vehicles/tankll37_lod2.iqm");
    
    precache_model ( "models/vehicles/tankll37_turret.iqm");
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    precache_model ( "models/vehicles/tankll37_cannon.iqm");
    precache_model ( "models/vehicles/tankll37_interior.iqm");
    precache_model ( "models/vehicles/anglestabilizer.iqm");
    precache_model ( "models/mountedguns/autonexgun.iqm");
    precache_model ( "models/mountedguns/autonexgun_lod1.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/campingrifle_fire.wav" );
    precache_sound ( "weapons/electro_impact_combo.wav" );
    precache_sound ( "weapons/electro_fire.wav" );
    precache_sound ( "weapons/nexfire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    
    precache_sound ( "vehicles/tankll37_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/tankll37_jump.wav");
    precache_sound ( "vehicles/tankll37_strafe.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "vehicles/tankll37_land.wav");
    precache_sound ( "object/impact_metal_3.ogg");
    precache_sound ( "object/impact_metal_4.ogg");

    if(autocvar_g_vehicle_tankll37_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_tankll37_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_tankll37_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "LL37",
             "models/vehicles/tankll37.iqm",
             "models/vehicles/tankll37_turret.iqm",
             "null",
             "tag_turret", "tag_camera", "",
             HUD_TANK,
             TANKLL37_MIN, TANKLL37_MAX,
             FALSE,
             tankll37_spawn, autocvar_g_vehicle_tankll37_respawntime,
             tankll37_frame,
             tankll37_enter, tankll37_exit,
             tankll37_die,   tankll37_think,
             FALSE, 
             autocvar_g_vehicle_tankll37_health,
             autocvar_g_vehicle_tankll37_shield, autocolor, 0, 0))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}
#endif // SVQC
