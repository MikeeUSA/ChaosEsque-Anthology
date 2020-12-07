const vector QNONLOCALITY_MIN = '-20 -20 1';
const vector QNONLOCALITY_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_qnonlocality;

float autocvar_g_vehicle_qnonlocality_respawntime;

float autocvar_g_vehicle_qnonlocality_speed_stop;
float autocvar_g_vehicle_qnonlocality_speed_strafe;

float autocvar_g_vehicle_qnonlocality_springlength;
float autocvar_g_vehicle_qnonlocality_springup;
float autocvar_g_vehicle_qnonlocality_springblend;
float autocvar_g_vehicle_qnonlocality_tiltlimit;

float autocvar_g_vehicle_qnonlocality_health;
float autocvar_g_vehicle_qnonlocality_health_regen;
float autocvar_g_vehicle_qnonlocality_health_regen_pause;

float autocvar_g_vehicle_qnonlocality_shield;
float autocvar_g_vehicle_qnonlocality_shield_regen;
float autocvar_g_vehicle_qnonlocality_shield_regen_pause;

vector autocvar_g_vehicle_qnonlocality_bouncepain;


void qnonlocality_exit(float eject);
void qnonlocality_enter();
void qnonlocality_spawn(float);

void qnonlocality_vehicles_touch()
{
    // Vehicle currently in use
    if(self.owner)
    {
        return;
    }

    if(other.classname != "player")
        return;

    if(other.deadflag != DEAD_NO)
        return;

    if(other.vehicle != world)
        return;

    vehicles_enter();
}

float qnonlocality_aiframe()
{
    return FALSE;
}

float qnonlocality_frame()
{
    vector ad;
    entity player, qnonlocality;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    qnonlocality = self.vehicle;
    self   = qnonlocality;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    makevectors(qnonlocality.angles + '-2 0 0' * qnonlocality.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_qnonlocality_springlength, autocvar_g_vehicle_qnonlocality_springup, autocvar_g_vehicle_qnonlocality_springblend, autocvar_g_vehicle_qnonlocality_tiltlimit);
    
    if(player.BUTTON_ATCK) {
    	setorigin(qnonlocality, randomvec() * random() * qnonlocality.gun1.count);
    }
    
    if(player.BUTTON_ATCK2) {
    	setorigin(qnonlocality, randomvec() * random() * qnonlocality.gun1.count);
    }
    
    if(player.BUTTON_JUMP) {
	qnonlocality.gun1.count += 128;
	sprint(player, sprintf("Probability Sector Raised to %f\n", (qnonlocality.gun1.count)));
    }
    
    if(player.BUTTON_CROUCH ) {
    	qnonlocality.gun1.count -= 128;
	sprint(player, sprintf("Probability Sector Lowered to %f\n", (qnonlocality.gun1.count)));
    }
    
    player.BUTTON_CROUCH    = 0;

    
    self.angles_x = bound(-autocvar_g_vehicle_qnonlocality_tiltlimit, self.angles_x, autocvar_g_vehicle_qnonlocality_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_qnonlocality_tiltlimit, self.angles_z, autocvar_g_vehicle_qnonlocality_tiltlimit);
    
    
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(qnonlocality.dmg_time, vehicle_shield, autocvar_g_vehicle_qnonlocality_shield, autocvar_g_vehicle_qnonlocality_shield_regen_pause, autocvar_g_vehicle_qnonlocality_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(qnonlocality.dmg_time, vehicle_health, autocvar_g_vehicle_qnonlocality_health, autocvar_g_vehicle_qnonlocality_health_regen_pause, autocvar_g_vehicle_qnonlocality_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, qnonlocality.origin + '0 0 1' * QNONLOCALITY_MAX_z);
    player.velocity = qnonlocality.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, qnonlocality);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, qnonlocality);

    self = player;
    return 1;    
}
void qnonlocality_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_qnonlocality_speed_stop);

    self.nextthink = time;
}

void qnonlocality_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_qnonlocality_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_qnonlocality_shield) * 100;
    
    setsize(self.owner, PL_MIN,PL_MAX);
	self.owner.crouch = TRUE;
        self.owner.takedamage     = DAMAGE_AIM;
        self.owner.solid          = SOLID_SLIDEBOX;
        self.owner.effects        &~= EF_NODRAW;
        self.owner.alpha          = 1;
        self.owner.event_damage   = PlayerDamage;
        //self.owner.hud            = HUD_NORMAL;
	
	antilag_clear(self.owner); 
}

void qnonlocality_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = qnonlocality_think;
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
	    spot = self.origin + v_forward * 30 + '0 0 40';
	    spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_qnonlocality_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 30 + '0 0 40';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 60 + '0 0 40';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void qnonlocality_impact()
{
    if(autocvar_g_vehicle_qnonlocality_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_qnonlocality_bouncepain_x, autocvar_g_vehicle_qnonlocality_bouncepain_y, autocvar_g_vehicle_qnonlocality_bouncepain_z);    
}

void qnonlocality_headfade()
{
	self.think = qnonlocality_headfade;
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

void qnonlocality_blowup()
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
    setmodel(h,  "models/ebomb.mdl");

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_qnonlocality_respawntime, 10);
    h.fade_time     = time;
    h.think         = qnonlocality_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_qnonlocality_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_qnonlocality_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void qnonlocality_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = qnonlocality_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
}

void qnonlocality_spawn(float _f)
{
    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        
        self.gravity            = 1;
        self.mass               = 1;
	
	self.gun1.count = 1024;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "");
	
	//self.tur_head.colormap = 1092; //Red
	self.tur_head.scale = 20;
	self.tur_head.alpha = 0.05;
	setmodel(self.tur_head,  "models/ebomb.mdl");
    }

    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = qnonlocality_think;
    self.touch              = qnonlocality_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_qnonlocality_health;
    self.vehicle_shield     = autocvar_g_vehicle_qnonlocality_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = -1;
    self.tur_head.angles    = '0 0 0';

    if (self.spawnflags >= 16) {
	setorigin(self, self.pos1);
	self.movetype           = MOVETYPE_NONE;
    } else {
	setorigin(self, self.pos1 + '0 0 32');	
    }
    self.angles = self.pos2;
    self.vehicle_impact = qnonlocality_impact;
    self.damageforcescale = 0.03;
}

void spawnfunc_vehicle_qnonlocality()
{
    if(!autocvar_g_vehicle_qnonlocality)
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
    
    precache_model ( "models/ebomb.mdl");
    //precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_qnonlocality_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_qnonlocality_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_qnonlocality_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "QNonLocality",
             bodymodel,
             "models/ebomb.mdl",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             QNONLOCALITY_MIN, QNONLOCALITY_MAX,
             FALSE,
             qnonlocality_spawn, autocvar_g_vehicle_qnonlocality_respawntime,
             qnonlocality_frame,
             qnonlocality_enter, qnonlocality_exit,
             qnonlocality_die,   qnonlocality_think,
             FALSE, 
             autocvar_g_vehicle_qnonlocality_health,
             autocvar_g_vehicle_qnonlocality_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

