const vector MG_SIEGEMORTAR_MIN = '-20 -20 1';
const vector MG_SIEGEMORTAR_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_siegemortar;

float autocvar_g_vehicle_mg_siegemortar_respawntime;

float autocvar_g_vehicle_mg_siegemortar_speed_stop;
float autocvar_g_vehicle_mg_siegemortar_speed_strafe;
float autocvar_g_vehicle_mg_siegemortar_speed_walk;
float autocvar_g_vehicle_mg_siegemortar_movement_inertia;

float autocvar_g_vehicle_mg_siegemortar_springlength;
float autocvar_g_vehicle_mg_siegemortar_springup;
float autocvar_g_vehicle_mg_siegemortar_springblend;
float autocvar_g_vehicle_mg_siegemortar_tiltlimit;

float autocvar_g_vehicle_mg_siegemortar_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_siegemortar_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_siegemortar_gun_pitchspeed;
float autocvar_g_vehicle_mg_siegemortar_gun_turnlimit;
float autocvar_g_vehicle_mg_siegemortar_gun_turnspeed;

float autocvar_g_vehicle_mg_siegemortar_health;
float autocvar_g_vehicle_mg_siegemortar_health_regen;
float autocvar_g_vehicle_mg_siegemortar_health_regen_pause;

float autocvar_g_vehicle_mg_siegemortar_shield;
float autocvar_g_vehicle_mg_siegemortar_shield_regen;
float autocvar_g_vehicle_mg_siegemortar_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_siegemortar_bolt_speed;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_siegemortar_bolt_refire;
float autocvar_g_vehicle_mg_siegemortar_bolt_spread;
float autocvar_g_vehicle_mg_siegemortar_bolt_ammo_cost;
float autocvar_g_vehicle_mg_siegemortar_bolt_ammo_max;
float autocvar_g_vehicle_mg_siegemortar_bolt_ammo_reserve;
float autocvar_g_vehicle_mg_siegemortar_bolt_ammo_regen;
float autocvar_g_vehicle_mg_siegemortar_bolt_ammo_regen_pause;
float autocvar_g_vehicle_mg_siegemortar_bolt_speed;

vector autocvar_g_vehicle_mg_siegemortar_bouncepain;


void mg_siegemortar_exit(float eject);
void mg_siegemortar_enter();
void mg_siegemortar_spawn(float);


void fireSiegemortarBolt(entity player, vector start, vector dir, float spread, float pSpeed, float lifetime, float dtype)
{
	entity proj;
	
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));
	
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/campingrifle_fire_morebass.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);

	proj = spawn ();
	proj.owner = proj.realowner = player;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = dtype;
	proj.use = tankll40_Grenade_Explode2;
	proj.touch = tankll40_Grenade_Touch2;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-16 -16 -16', '16 16 16');
	setorigin(proj, start);
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = time + autocvar_g_vehicle_tankll40_rocket_lifetime;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + lifetime;
	//W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);
	W_SetupProjectileVelocityEx(proj, dir, v_up, pSpeed, 0, 0, spread, antilagging);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_SIEGECANNON, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_siegemortar_aiframe()
{
    return FALSE;
}

void mg_siegemortar_checkmodel(entity mg_siegemortar, entity gunmount) 
{
    if(mg_siegemortar.vehicle_ammo1 >= autocvar_g_vehicle_mg_siegemortar_bolt_ammo_cost && gunmount.attack_finished_single <= time)
    {
    	if (mg_siegemortar.amnt != 1) {
		mg_siegemortar.amnt = 1;
    		//setmodel(gunmount,  "models/mountedguns/siegemortar_loaded.iqm");
		mg_siegemortar.bomb1.alpha = 1;
	}
    }
}

void mg_siegemortar_fire(entity mg_siegemortar, entity player, entity gunmount) 
{
	mg_siegemortar.cnt = time;
        if(mg_siegemortar.vehicle_ammo1 >= autocvar_g_vehicle_mg_siegemortar_bolt_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_siegemortar.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
            v += v_forward * 48;
	 
	 fireSiegemortarBolt(player, v, v_forward, autocvar_g_vehicle_mg_siegemortar_bolt_spread, autocvar_g_vehicle_mg_siegemortar_bolt_speed, 40, WEP_FIREBALL);

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("fireball_muzzleflash"), v, v_forward, 1);

	 //sound (gunmount, CH_WEAPON_A, "resource/impact/Arrowimpwood_19.ogg", VOL_BASE, ATTN_NORM);
	
	setmodel(gunmount,  "models/mountedguns/siegemortar.iqm");
	mg_siegemortar.amnt = 0;
	mg_siegemortar.bomb1.alpha = -1;
	
	 //Removed expell bullet casings stuff	

            self = mg_siegemortar;

            mg_siegemortar.vehicle_ammo1 -= autocvar_g_vehicle_mg_siegemortar_bolt_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_siegemortar_bolt_refire;
            player.vehicle_ammo1 = (mg_siegemortar.vehicle_ammo1 / autocvar_g_vehicle_mg_siegemortar_bolt_ammo_max) * 100;
        }
}

float mg_siegemortar_frame()
{
    vector ad;
    entity player, mg_siegemortar;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_siegemortar = self.vehicle;
    self   = mg_siegemortar;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_siegemortar.tur_head, gettagindex(mg_siegemortar.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_siegemortar);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_siegemortar.angles), AnglesTransform_FromAngles(ad))) - mg_siegemortar.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    if (self.spawnflags >= 16) {
    	ftmp = autocvar_g_vehicle_mg_siegemortar_gun_turnspeed * sys_frametime;    
    	ad_y = bound(-ftmp, ad_y, ftmp);
    	mg_siegemortar.tur_head.angles_y = bound(autocvar_g_vehicle_mg_siegemortar_gun_turnlimit * -1, mg_siegemortar.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_siegemortar_gun_turnlimit);
    
        // Pitch head
    ftmp = autocvar_g_vehicle_mg_siegemortar_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_siegemortar.tur_head.angles_x = bound(autocvar_g_vehicle_mg_siegemortar_gun_pitchlimit_down, mg_siegemortar.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_siegemortar_gun_pitchlimit_up);

    } else {

    	// Pitch head
    	ftmp = autocvar_g_vehicle_mg_siegemortar_gun_pitchspeed * sys_frametime;    
    	ad_x = bound(ftmp * -1, ad_x, ftmp);
    	mg_siegemortar.tur_head.angles_x = bound(-10, mg_siegemortar.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_siegemortar_gun_pitchlimit_up);
    }

    //fixedmakevectors(mg_siegemortar.angles);
    makevectors(mg_siegemortar.angles + '-2 0 0' * mg_siegemortar.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_siegemortar_springlength, autocvar_g_vehicle_mg_siegemortar_springup, autocvar_g_vehicle_mg_siegemortar_springblend, autocvar_g_vehicle_mg_siegemortar_tiltlimit);

    if(mg_siegemortar.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_siegemortar_speed_stop);
		setanim(player, player.anim_idle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_siegemortar.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_siegemortar, player, -600); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_siegemortar.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_siegemortar, player, autocvar_g_vehicle_mg_siegemortar_speed_walk, autocvar_g_vehicle_mg_siegemortar_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_siegemortar_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_siegemortar_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_siegemortar_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_siegemortar_tiltlimit);
    
    mg_siegemortar_checkmodel(mg_siegemortar, mg_siegemortar.tur_head);
    
    if(player.BUTTON_ATCK)
    {
	mg_siegemortar_fire(mg_siegemortar, player, mg_siegemortar.tur_head);
	mg_siegemortar.count = 0; //Will have to press R to resume reload
    } else {
    	if (mg_siegemortar.count == 1) {
        vehicles_regen(mg_siegemortar.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_siegemortar_bolt_ammo_max,
                                           autocvar_g_vehicle_mg_siegemortar_bolt_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_siegemortar_bolt_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_siegemortar.count = 1;
		sound (mg_siegemortar, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		////Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		////vehicles_replenishAmmo(player, mg_siegemortar, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		//Reload from own stores //3 ammo, 3 player ammo = 3 vehic ammo,
		vehicles_replenishAmmo(player, mg_siegemortar, ammo_rockets, vehicle_ammo1_current, vehicle_ammo1_max, 3, 3);
	
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_siegemortar.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_siegemortar_shield, autocvar_g_vehicle_mg_siegemortar_shield_regen_pause, autocvar_g_vehicle_mg_siegemortar_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_siegemortar.dmg_time, vehicle_health, autocvar_g_vehicle_mg_siegemortar_health, autocvar_g_vehicle_mg_siegemortar_health_regen_pause, autocvar_g_vehicle_mg_siegemortar_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_siegemortar.origin + '0 0 1' * MG_SIEGEMORTAR_MAX_z);
    player.velocity = mg_siegemortar.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_siegemortar);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_siegemortar);

    player.vehicle_ammo1_current = mg_siegemortar.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_siegemortar.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_siegemortar_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_siegemortar_speed_stop);

    self.nextthink = time;
}

void mg_siegemortar_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_siegemortar_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_siegemortar_shield) * 100;

    mg_enter(self.owner);
    
    //We don't crouch for this weapon
    self.owner.crouch = FALSE;
    setsize(self.owner, PL_MIN,PL_MAX);
    setanim(self.owner, self.owner.anim_idle, TRUE, FALSE, FALSE);
}

void mg_siegemortar_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_siegemortar_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_siegemortar_speed_strafe)
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

void mg_siegemortar_impact()
{
    if(autocvar_g_vehicle_mg_siegemortar_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_siegemortar_bouncepain_x, autocvar_g_vehicle_mg_siegemortar_bouncepain_y, autocvar_g_vehicle_mg_siegemortar_bouncepain_z);    
}

void mg_siegemortar_headfade()
{
	self.think = mg_siegemortar_headfade;
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

void mg_siegemortar_blowup()
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

    setmodel(b,  "models/mountedguns/siegemortar_mount.iqm");
    h.lodmodel1 = "models/mountedguns/siegemortar_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/siegemortar_lod2.iqm";
    setmodel(h,  "models/mountedguns/siegemortar.iqm");
    InitializeEntity(h, LODmodel_attach, INITPRIO_FINDTARGET);

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_siegemortar_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_siegemortar_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_siegemortar_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_siegemortar_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.bomb1.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_siegemortar_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_siegemortar_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_siegemortar_spawn(float _f)
{
    //self.scale = 1.90;
    self.scale = 1.70;
    //self.scale = 1;
    mg_std_resists(); //Standard resistances for mounted guns.
    
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
	setmodel(self.bomb1,  "models/sphere/cannonball.iqm");
	
        self.gravity            = 2;
        self.mass               = 5000;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/siegemortar_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/siegemortar_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_siegemortar_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_siegemortar_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_siegemortar_shield;
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
    self.vehicle_impact = mg_siegemortar_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_siegemortar()
{
    if(!autocvar_g_vehicle_mg_siegemortar)
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
    	precache_model ( "models/mountedguns/siegemortar_mount.iqm");
    	bodymodel = "models/mountedguns/siegemortar_mount.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }

    mg_shield_precache();
    //precache_model ( "models/mountedguns/siegemortar_loaded.iqm");
    precache_model ( "models/mountedguns/siegemortar.iqm");
    precache_model ( "models/mountedguns/siegemortar_lod1.iqm");
    precache_model ( "models/mountedguns/siegemortar_lod2.iqm");
    precache_model ( "models/sphere/sphere.md3");
    precache_model ("models/sphere/cannonball.iqm");
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "weapons/campingrifle_fire_morebass.wav");
    
    if(autocvar_g_vehicle_mg_siegemortar_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_siegemortar_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_siegemortar_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "SiegeMortar",
             bodymodel,
             "models/mountedguns/siegemortar.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_SIEGEMORTAR_MIN, MG_SIEGEMORTAR_MAX,
             FALSE,
             mg_siegemortar_spawn, autocvar_g_vehicle_mg_siegemortar_respawntime,
             mg_siegemortar_frame,
             mg_siegemortar_enter, mg_siegemortar_exit,
             mg_siegemortar_die,   mg_siegemortar_think,
             FALSE, 
             autocvar_g_vehicle_mg_siegemortar_health,
             autocvar_g_vehicle_mg_siegemortar_shield, 1, autocvar_g_vehicle_mg_siegemortar_bolt_ammo_max * autocvar_g_vehicle_mg_siegemortar_bolt_ammo_reserve, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

