const vector MG_LASERCANNON_MIN = '-20 -20 1';
const vector MG_LASERCANNON_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_lasercannon;
float autocvar_g_vehicle_mg_lasercannon_turnoffonexit;

float autocvar_g_vehicle_mg_lasercannon_respawntime;

float autocvar_g_vehicle_mg_lasercannon_speed_stop;
float autocvar_g_vehicle_mg_lasercannon_speed_strafe;
float autocvar_g_vehicle_mg_lasercannon_speed_walk;
float autocvar_g_vehicle_mg_lasercannon_movement_inertia;

float autocvar_g_vehicle_mg_lasercannon_springlength;
float autocvar_g_vehicle_mg_lasercannon_springup;
float autocvar_g_vehicle_mg_lasercannon_springblend;
float autocvar_g_vehicle_mg_lasercannon_tiltlimit;
float autocvar_g_vehicle_mg_lasercannon_red_damage;
float autocvar_g_vehicle_mg_lasercannon_green_damage;
float autocvar_g_vehicle_mg_lasercannon_cyan_damage;
float autocvar_g_vehicle_mg_lasercannon_magenta_pulsed_damage;
float autocvar_g_vehicle_mg_lasercannon_magenta_damage;

float autocvar_g_vehicle_mg_lasercannon_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_lasercannon_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_lasercannon_gun_pitchspeed;
float autocvar_g_vehicle_mg_lasercannon_gun_turnlimit;
float autocvar_g_vehicle_mg_lasercannon_gun_turnspeed;

float autocvar_g_vehicle_mg_lasercannon_health;
float autocvar_g_vehicle_mg_lasercannon_health_regen;
float autocvar_g_vehicle_mg_lasercannon_health_regen_pause;

float autocvar_g_vehicle_mg_lasercannon_shield;
float autocvar_g_vehicle_mg_lasercannon_shield_regen;
float autocvar_g_vehicle_mg_lasercannon_shield_regen_pause;

float autocvar_g_vehicle_mg_lasercannon_railgun_refire;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulsecost;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulseduration;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_max;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_regen;
float autocvar_g_vehicle_mg_lasercannon_railgun_ammo_regen_pause;

vector autocvar_g_vehicle_mg_lasercannon_bouncepain;

void bumb_fire_cannon(entity _gun, string _tagname, entity _owner);

void mg_lasercannon_exit(float eject);
void mg_lasercannon_enter();
void mg_lasercannon_spawn(float);

float mg_lasercannon_aiframe()
{
    return FALSE;
}

void mg_lasercannon_fire(entity mg_lasercannon, entity player, entity _gun, float attackbutton, float mydamage, vector mycolor, float mypulseduration, float mycost) 
{
	local vector oldvforward;
	local vector oldvup;
	local vector oldvright;
	
	oldvforward = v_forward;
	oldvforward = v_up;
	oldvforward = v_right;
	
	float myrequirementstofire;
    	myrequirementstofire = 0;
	
	if(attackbutton) {
		mg_lasercannon.cnt = time;
		if(time > _gun.attack_finished_single || time < _gun.amnt) {
			if(mg_lasercannon.vehicle_ammo1 >= mycost)
			{
					myrequirementstofire = 1;
			}
		}
	}
	
	self = mg_lasercannon;
	makevectors(self.angles);
	//v = gettaginfo(_gun, gettagindex(_gun, "tag_mgun1"));
        v_forward = normalize(v_forward);
	
	self = mg_lasercannon;
	
	if (shenzong_maybe_fire_laser(_gun, "fire", player,
				mg_lasercannon, mycolor, 0.9,
				8, 2, mydamage,
				mypulseduration, myrequirementstofire))
	{
		if (time > _gun.attack_finished_single) {
			mg_lasercannon.vehicle_ammo1 -= mycost;
			_gun.delay = time;
			_gun.attack_finished_single = time + autocvar_g_vehicle_mg_lasercannon_railgun_refire;
			_gun.amnt = time + mypulseduration; //Pulse duration;
			player.vehicle_ammo1 = (mg_lasercannon.vehicle_ammo1 / autocvar_g_vehicle_mg_lasercannon_railgun_ammo_max) * 100;
		}
	}
	
	//Restore previous
	v_forward = oldvforward;
	v_up = oldvup;
	v_right = oldvright;
}

float mg_lasercannon_frame()
{
    vector ad;
    entity player, mg_lasercannon;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_lasercannon = self.vehicle;
    self   = mg_lasercannon;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_lasercannon.tur_head, gettagindex(mg_lasercannon.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_lasercannon);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_lasercannon.angles), AnglesTransform_FromAngles(ad))) - mg_lasercannon.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_lasercannon_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_lasercannon.tur_head.angles_y = bound(autocvar_g_vehicle_mg_lasercannon_gun_turnlimit * -1, mg_lasercannon.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_lasercannon_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_lasercannon_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_lasercannon.tur_head.angles_x = bound(autocvar_g_vehicle_mg_lasercannon_gun_pitchlimit_down, mg_lasercannon.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_lasercannon_gun_pitchlimit_up);


    //fixedmakevectors(mg_lasercannon.angles);
    makevectors(mg_lasercannon.angles + '-2 0 0' * mg_lasercannon.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_lasercannon_springlength, autocvar_g_vehicle_mg_lasercannon_springup, autocvar_g_vehicle_mg_lasercannon_springblend, autocvar_g_vehicle_mg_lasercannon_tiltlimit);

    if(mg_lasercannon.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_lasercannon_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_lasercannon.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_lasercannon, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_lasercannon.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_lasercannon, player, autocvar_g_vehicle_mg_lasercannon_speed_walk, autocvar_g_vehicle_mg_lasercannon_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_lasercannon_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_lasercannon_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_lasercannon_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_lasercannon_tiltlimit);
    
    if (self.ammount2 == 10) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_red_damage, '1 0 0', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost);
    } else if (self.ammount2 == 11) {
        mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_red_damage, '1 0 0', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulseduration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulsecost);
    } else if (self.ammount2 == 20) {
	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_green_damage, '0 1 0', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost);
    } else if (self.ammount2 == 21) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_green_damage, '0 1 0', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulseduration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulsecost);
    } else if (self.ammount2 == 30) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_cyan_damage, '0 1 1', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost);
    } else if (self.ammount2 == 31) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_cyan_damage, '0 1 1', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulseduration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulsecost);
    } else if (self.ammount2 == 40) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_magenta_damage, '1 0 1', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost);
    } else if (self.ammount2 == 41) {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_magenta_pulsed_damage, '1 0 1', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulseduration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_pulsecost);
    } else {
    	mg_lasercannon_fire(mg_lasercannon, player, mg_lasercannon.tur_head, player.BUTTON_ATCK, autocvar_g_vehicle_mg_lasercannon_red_damage, '1 0 0', autocvar_g_vehicle_mg_lasercannon_railgun_ammo_duration, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_cost);
    }
    
    if(player.BUTTON_ATCK)
    {
    	//Do nothing	
    } else {
        vehicles_regen(mg_lasercannon.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_lasercannon_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_lasercannon_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_lasercannon_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_lasercannon.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_lasercannon_shield, autocvar_g_vehicle_mg_lasercannon_shield_regen_pause, autocvar_g_vehicle_mg_lasercannon_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_lasercannon.dmg_time, vehicle_health, autocvar_g_vehicle_mg_lasercannon_health, autocvar_g_vehicle_mg_lasercannon_health_regen_pause, autocvar_g_vehicle_mg_lasercannon_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_lasercannon.origin + '0 0 1' * MG_LASERCANNON_MAX_z);
    player.velocity = mg_lasercannon.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_lasercannon);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_lasercannon);

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_lasercannon_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_lasercannon_speed_stop);

    self.nextthink = time;
}

void mg_lasercannon_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_lasercannon_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_lasercannon_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_lasercannon_exit(float eject)
{
    vector spot;
    
    if (autocvar_g_vehicle_mg_lasercannon_turnoffonexit) {
    	entity myremovelaser;
	if(self.tur_head.mylazerenemy) {
		myremovelaser = self.tur_head.mylazerenemy;
		self.tur_head.mylazerenemy = world;
		remove(myremovelaser);
	}
    }
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_lasercannon_think;
    self.nextthink  = time;
    self.frame      = 5;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = mg_exit_stationary(spot);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_lasercannon_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = mg_exit_stationary(spot);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = mg_exit_stationary(spot);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void mg_lasercannon_impact()
{
    if(autocvar_g_vehicle_mg_lasercannon_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_lasercannon_bouncepain_x, autocvar_g_vehicle_mg_lasercannon_bouncepain_y, autocvar_g_vehicle_mg_lasercannon_bouncepain_z);    
}

void mg_lasercannon_headfade()
{
	self.think = mg_lasercannon_headfade;
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

void mg_lasercannon_blowup()
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
    
    entity h, b;
    b = spawn();
    h = spawn();


    setmodel(b,  "models/mountedguns/maximgun_mount.iqm");
    setmodel(h,  "models/vehicles/bumblebee_plasma_left.dpm");

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_lasercannon_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_lasercannon_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_lasercannon_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_lasercannon_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_lasercannon_die()
{
	
	entity myremovelaser;
	if(self.tur_head.mylazerenemy) {
		myremovelaser = self.tur_head.mylazerenemy;
		self.tur_head.mylazerenemy = world;
		remove(myremovelaser);
	}
	
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_lasercannon_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_lasercannon_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.

    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        
        self.gravity            = 1;
        self.mass               = 250;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	setorigin(self.vehicle_viewport, '0 0 16'); //Up abit
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
	
	self.tur_head.colormap = 1092; //Red
    }

    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_lasercannon_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_lasercannon_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_lasercannon_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.colormap;
    self.tur_head.angles    = '0 0 0';

    if (self.spawnflags >= 16) {
	setorigin(self, self.pos1);
	self.movetype           = MOVETYPE_NONE;
    } else {
	setorigin(self, self.pos1 + '0 0 32');	
    }
    self.angles = self.pos2;
    self.vehicle_impact = mg_lasercannon_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_lasercannon()
{
    if(!autocvar_g_vehicle_mg_lasercannon)
    {
        remove(self);
        return;
    }        
    
    if (autocvar_g_delete_mountedguns >= 1) {
	if (time < game_starttime + autocvar_g_delete_mountedguns_time)
	{
		remove(self);
		return;
	}
    }
    
    string bodymodel;
    if (self.spawnflags == 16) {
    	precache_model ( "models/mountedguns/maximgun_circmount.iqm");
	bodymodel = "models/mountedguns/maximgun_circmount.iqm";
    } else if (self.spawnflags == 32) {
    	precache_model ( "models/mountedguns/maximgun_pointmount.iqm");
	bodymodel = "models/mountedguns/maximgun_pointmount.iqm";
    } else {
    	precache_model ( "models/mountedguns/maximgun_mount.iqm");
    	bodymodel = "models/mountedguns/maximgun_mount.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }
    
    mg_shield_precache();
    precache_model ( "models/vehicles/bumblebee_plasma_left.dpm");
    //precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/flacexp3.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_lasercannon_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_lasercannon_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_lasercannon_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "LaserCannon",
             bodymodel,
             "models/vehicles/bumblebee_plasma_left.dpm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_LASERCANNON_MIN, MG_LASERCANNON_MAX,
             FALSE,
             mg_lasercannon_spawn, autocvar_g_vehicle_mg_lasercannon_respawntime,
             mg_lasercannon_frame,
             mg_lasercannon_enter, mg_lasercannon_exit,
             mg_lasercannon_die,   mg_lasercannon_think,
             FALSE, 
             autocvar_g_vehicle_mg_lasercannon_health,
             autocvar_g_vehicle_mg_lasercannon_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

void spawnfunc_mountedgun_lasercannon_red()
{
	self.ammount2 = 10;
		
	spawnfunc_mountedgun_lasercannon();
}

void spawnfunc_mountedgun_lasercannon_red_pulsed()
{
	self.ammount2 = 11;
		
	spawnfunc_mountedgun_lasercannon();
}

void spawnfunc_mountedgun_lasercannon_green()
{
	self.ammount2 = 20;
		
	spawnfunc_mountedgun_lasercannon();
}

void spawnfunc_mountedgun_lasercannon_green_pulsed()
{
	self.ammount2 = 21;
		
	spawnfunc_mountedgun_lasercannon();
}

void spawnfunc_mountedgun_lasercannon_cyan()
{
	self.ammount2 = 30;
		
	spawnfunc_mountedgun_lasercannon();
}


void spawnfunc_mountedgun_lasercannon_cyan_pulsed()
{
	self.ammount2 = 31;
		
	spawnfunc_mountedgun_lasercannon();
}


void spawnfunc_mountedgun_lasercannon_magenta()
{
	self.ammount2 = 40;
		
	spawnfunc_mountedgun_lasercannon();
}

void spawnfunc_mountedgun_lasercannon_magenta_pulsed()
{
	self.ammount2 = 41;
		
	spawnfunc_mountedgun_lasercannon();
}

