const vector MG_BATTERINGRAM_MIN = '-128 -128 0';
const vector MG_BATTERINGRAM_MAX  = '128 128 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_batteringram;

float autocvar_g_vehicle_mg_batteringram_respawntime;

float autocvar_g_vehicle_mg_batteringram_speed_stop;
float autocvar_g_vehicle_mg_batteringram_speed_strafe;
float autocvar_g_vehicle_mg_batteringram_speed_walk;
float autocvar_g_vehicle_mg_batteringram_movement_inertia;

float autocvar_g_vehicle_mg_batteringram_tiltlimit;

float autocvar_g_vehicle_mg_batteringram_gun_turnlimit;
float autocvar_g_vehicle_mg_batteringram_gun_turnspeed;

float autocvar_g_vehicle_mg_batteringram_health;
float autocvar_g_vehicle_mg_batteringram_health_regen;
float autocvar_g_vehicle_mg_batteringram_health_regen_pause;

float autocvar_g_vehicle_mg_batteringram_shield;
float autocvar_g_vehicle_mg_batteringram_shield_regen;
float autocvar_g_vehicle_mg_batteringram_shield_regen_pause;

float autocvar_g_vehicle_mg_batteringram_bolt_refire;
float autocvar_g_vehicle_mg_batteringram_bolt_damage;
float autocvar_g_vehicle_mg_batteringram_bolt_radius;

vector autocvar_g_vehicle_mg_batteringram_bouncepain;


void mg_batteringram_exit(float eject);
void mg_batteringram_enter();
void mg_batteringram_spawn(float);

float mg_batteringram_aiframe()
{
    return FALSE;
}

void mg_batteringram_fire(entity mg_batteringram, entity player, entity gunmount) 
{
        if(gunmount.attack_finished_single <= time)
        {
	    mg_batteringram.cnt = 0;
            vector v;
            mg_batteringram.misc_bulletcounter += 1;

            self = player;

            //Damage done at middle of swing
	 
	    //mg_batteringram.amnt = 0;
	    //mg_batteringram.bomb1.alpha = -1;
	
            self = mg_batteringram;

            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_batteringram_bolt_refire;
        }
}

void mg_batteringram_damage(entity mg_batteringram, entity player, entity gunmount) 
{
	vector v;
	local entity damager;

	self = player;

	v = gettaginfo(gunmount, gettagindex(gunmount, ""));
	v_forward = normalize(v_forward);
	v += v_forward * 352;
	//v += v_forward * 600;
	 
	//fireBatteringRamBolt(player, v, v_forward, autocvar_g_vehicle_mg_batteringram_bolt_spread, autocvar_g_vehicle_mg_batteringram_bolt_speed, 40, WEP_FIREBALL);
	//RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);
	
	damager = spawn();
	self = damager;
	self.origin = v;
	self.realowner = player;
	
	RadiusDamage (self, self.realowner, autocvar_g_vehicle_mg_batteringram_bolt_damage,
		autocvar_g_vehicle_mg_batteringram_bolt_damage,
		autocvar_g_vehicle_mg_batteringram_bolt_radius, world,
		0,
		DEATH_BATTERINGRAM, world);

	//pointparticles(particleeffectnum("fireball_muzzleflash"), v, v_forward, 1);

	//sound (gunmount, CH_WEAPON_A, "resource/impact/Arrowimpwood_19.ogg", VOL_BASE, ATTN_NORM);
	
	self = mg_batteringram;        	
}

float mg_batteringram_frame()
{
    vector ad;
    entity player, mg_batteringram;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_batteringram = self.vehicle;
    self   = mg_batteringram;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_batteringram.tur_head, gettagindex(mg_batteringram.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_batteringram);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_batteringram.angles), AnglesTransform_FromAngles(ad))) - mg_batteringram.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    if (self.spawnflags >= 16) {
    	ftmp = autocvar_g_vehicle_mg_batteringram_gun_turnspeed * sys_frametime;    
    	ad_y = bound(-ftmp, ad_y, ftmp);
    	mg_batteringram.tur_head.angles_y = bound(autocvar_g_vehicle_mg_batteringram_gun_turnlimit * -1, mg_batteringram.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_batteringram_gun_turnlimit);
    }

    //fixedmakevectors(mg_batteringram.angles);
    makevectors(mg_batteringram.angles + '-2 0 0' * mg_batteringram.angles_x);
    
    //if (!mg_batteringram.vehicle_shieldtype) {
    //	movelib_groundalign4point(autocvar_g_vehicle_mg_batteringram_springlength, autocvar_g_vehicle_mg_batteringram_springup, autocvar_g_vehicle_mg_batteringram_springblend, autocvar_g_vehicle_mg_batteringram_tiltlimit);
    //}

    if(mg_batteringram.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_batteringram_speed_stop);
		setanim(player, player.anim_idle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_batteringram.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_batteringram, player, -600); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_batteringram.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_batteringram, player, autocvar_g_vehicle_mg_batteringram_speed_walk, autocvar_g_vehicle_mg_batteringram_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_batteringram_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_batteringram_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_batteringram_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_batteringram_tiltlimit);
        
    if(player.BUTTON_ATCK)
    {
	mg_batteringram_fire(mg_batteringram, player, mg_batteringram.tur_head);
    }
    
    if (mg_batteringram.tur_head.attack_finished_single > time) {
    	float amountchange;
	amountchange = (100 / ((autocvar_g_vehicle_mg_batteringram_bolt_refire / frametime) * 0.5));
	
	if (self.tur_head.origin_x >= 100 || mg_batteringram.cnt > 0) {
		if (mg_batteringram.cnt == 0)
		{
			mg_batteringram.cnt = 1;
			mg_batteringram_damage(mg_batteringram, player, mg_batteringram.tur_head);
		}
		self.tur_head.origin_x = self.tur_head.origin_x - amountchange;
	} else {
		self.tur_head.origin_x = self.tur_head.origin_x + amountchange;
	}
    } else {
    	self.tur_head.origin_x = 0;
    }

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_batteringram.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_batteringram_shield, autocvar_g_vehicle_mg_batteringram_shield_regen_pause, autocvar_g_vehicle_mg_batteringram_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_batteringram.dmg_time, vehicle_health, autocvar_g_vehicle_mg_batteringram_health, autocvar_g_vehicle_mg_batteringram_health_regen_pause, autocvar_g_vehicle_mg_batteringram_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_batteringram.origin + '0 0 1' * MG_BATTERINGRAM_MAX_z);
    player.velocity = mg_batteringram.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_batteringram);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_batteringram);

    player.vehicle_ammo1_current = mg_batteringram.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_batteringram.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_batteringram_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_batteringram_speed_stop);

    self.nextthink = time;
}

void mg_batteringram_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_batteringram_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_batteringram_shield) * 100;

    mg_enter(self.owner);
    
    //We don't crouch for this weapon
    self.owner.crouch = FALSE;
    setsize(self.owner, PL_MIN,PL_MAX);
    setanim(self.owner, self.owner.anim_idle, TRUE, FALSE, FALSE);
}

void mg_batteringram_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_batteringram_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_batteringram_speed_strafe)
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

void mg_batteringram_impact()
{
    if(autocvar_g_vehicle_mg_batteringram_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_batteringram_bouncepain_x, autocvar_g_vehicle_mg_batteringram_bouncepain_y, autocvar_g_vehicle_mg_batteringram_bouncepain_z);    
}

void mg_batteringram_headfade()
{
	self.think = mg_batteringram_headfade;
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

void mg_batteringram_blowup()
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
    b.scale = self.scale;
    h.scale = self.scale;

    setmodel(b,  "models/mountedguns/batteringram_frame.bsp");
    //h.lodmodel1 = "models/mountedguns/batteringram_lod1.iqm";
    //h.lodmodel2 = "models/mountedguns/batteringram_lod2.iqm";
    setmodel(h,  "models/mountedguns/batteringram.bsp");
    //InitializeEntity(h, LODmodel_attach, INITPRIO_FINDTARGET);

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_batteringram_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_batteringram_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_batteringram_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_batteringram_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.bomb1.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_batteringram_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_batteringram_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_batteringram_spawn(float _f)
{
    //self.scale = 1.90;
    //self.scale = 1.70;
    self.scale = 1;
    
    self.resist_acid = 1.0;   //Slime
    self.resist_blunt = 1.0;  //Warhammer, beatdown, melee
    self.resist_bullet = 1.0;
    self.resist_crush = 0.10;  //Vehicle crush
    self.resist_edged = 1.0;  //Axe, Sword, Claw
    self.resist_electricity = 1.0; //Lightning gun, Tesla arc, 
    self.resist_energy = 1.0; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
    self.resist_explode = 0;//Rockets etc
    self.resist_fall = 1.0;   //Shooting star, fall etc
    self.resist_fire = 0;   //Fire, Lava
    self.resist_laser = 1.0;  //Laser
    self.resist_nuke = 0;  //Nuclear explosion
    self.resist_pierce = 1.0; //Crossbow, Bite
    self.resist_sound = 1.0; //Tuba
    self.resist_ice = 1.0; //Freeze damage resistance
    self.resist_rotor = 1.0; //Helicopter/Aero-plane Rotor blades damage resistance, Special, evaluated before crush

    if(!self.gun1)
    {	
        self.gun1            = spawn();
	
	self.bomb1              = spawn(); 
	self.bomb1.scale = 1/self.scale; //Attached things are scaled to parent, so scale back down.
	self.bomb1.scale = self.bomb1.scale * 2;
	setattachment(self.bomb1, self.tur_head, "tag_mgun");
	self.bomb1.alpha = -1;
	self.bomb1.origin = '2 0 0';
	setorigin(self.bomb1, self.bomb1.origin);
	setmodel(self.bomb1,  "models/map_xoylent/asteroid.obj");
	
        self.gravity            = 2;
        self.mass               = 5000;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "");
	self.vehicle_viewport.origin = '0 0 32';
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    //self.tur_head.lodmodel1 = "models/mountedguns/batteringram_lod1.iqm";
    //self.tur_head.lodmodel2 = "models/mountedguns/batteringram_lod2.iqm";
    //InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_batteringram_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_batteringram_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_batteringram_shield;
    self.movetype           = MOVETYPE_WALK;
    
    //if (self.vehicle_shieldtype) self.solid              = SOLID_SLIDEBOX;
    //else self.solid              = SOLID_BSP; //SLIDEBOX;
    self.solid              = SOLID_BSP;
    
    self.alpha              = self.tur_head.alpha = self.colormap;
    self.tur_head.angles    = '0 0 0';
    self.tur_head.origin_z  = 32;

    if (self.spawnflags >= 16) {
	setorigin(self, self.pos1);
	self.movetype           = MOVETYPE_NONE;
    } else {
	setorigin(self, self.pos1 + '0 0 32');	
    }
    self.angles = self.pos2;
    self.vehicle_impact = mg_batteringram_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_batteringram()
{
    if(!autocvar_g_vehicle_mg_batteringram)
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
    	precache_model ( "models/mountedguns/batteringram_frame.bsp");
    	bodymodel = "models/mountedguns/batteringram_frame.bsp";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }

    mg_shield_precache();
    //precache_model ( "models/mountedguns/batteringram_loaded.iqm");
    precache_model ( "models/mountedguns/batteringram.bsp");
    //precache_model ( "models/mountedguns/batteringram_lod1.iqm");
    //precache_model ( "models/mountedguns/batteringram_lod2.iqm");
    precache_model ( "models/sphere/sphere.md3");
    precache_model ("models/map_xoylent/asteroid.obj");
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "weapons/fireball_fire.wav");
    precache_sound ( "weapons/fireball_fire2.wav");
    
    if(autocvar_g_vehicle_mg_batteringram_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_batteringram_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_batteringram_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "BatteringRam",
             bodymodel,
             "models/mountedguns/batteringram.bsp",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_BATTERINGRAM_MIN, MG_BATTERINGRAM_MAX,
             FALSE,
             mg_batteringram_spawn, autocvar_g_vehicle_mg_batteringram_respawntime,
             mg_batteringram_frame,
             mg_batteringram_enter, mg_batteringram_exit,
             mg_batteringram_die,   mg_batteringram_think,
             FALSE, 
             autocvar_g_vehicle_mg_batteringram_health,
             autocvar_g_vehicle_mg_batteringram_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

