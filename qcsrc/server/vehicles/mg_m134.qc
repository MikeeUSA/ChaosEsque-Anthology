const vector MG_M134_MIN = '-20 -20 1';
const vector MG_M134_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_m134;

float autocvar_g_vehicle_mg_m134_respawntime;

float autocvar_g_vehicle_mg_m134_speed_stop;
float autocvar_g_vehicle_mg_m134_speed_strafe;
float autocvar_g_vehicle_mg_m134_speed_walk;
float autocvar_g_vehicle_mg_m134_movement_inertia;

float autocvar_g_vehicle_mg_m134_springlength;
float autocvar_g_vehicle_mg_m134_springup;
float autocvar_g_vehicle_mg_m134_springblend;
float autocvar_g_vehicle_mg_m134_tiltlimit;

float autocvar_g_vehicle_mg_m134_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_m134_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_m134_gun_pitchspeed;
float autocvar_g_vehicle_mg_m134_gun_turnlimit;
float autocvar_g_vehicle_mg_m134_gun_turnspeed;

float autocvar_g_vehicle_mg_m134_health;
float autocvar_g_vehicle_mg_m134_health_regen;
float autocvar_g_vehicle_mg_m134_health_regen_pause;

float autocvar_g_vehicle_mg_m134_shield;
float autocvar_g_vehicle_mg_m134_shield_regen;
float autocvar_g_vehicle_mg_m134_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_m134_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_m134_machinegun_speed;
float autocvar_g_vehicle_mg_m134_machinegun_force;
float autocvar_g_vehicle_mg_m134_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_m134_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_m134_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_m134_machinegun_damage;
float autocvar_g_vehicle_mg_m134_machinegun_refire;
float autocvar_g_vehicle_mg_m134_machinegun_refire_min;
float autocvar_g_vehicle_mg_m134_machinegun_refire_max;
float autocvar_g_vehicle_mg_m134_machinegun_refire_changerate;
float autocvar_g_vehicle_mg_m134_machinegun_spread;
float autocvar_g_vehicle_mg_m134_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_m134_machinegun_ammo_max;
float autocvar_g_vehicle_mg_m134_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_m134_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_m134_machinegun_force;
float autocvar_g_vehicle_mg_m134_machinegun_speed;
float autocvar_g_vehicle_mg_m134_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_m134_bouncepain;


void mg_m134_exit(float eject);
void mg_m134_enter();
void mg_m134_spawn(float);

float mg_m134_aiframe()
{
    return FALSE;
}

void mg_m134_fire(entity mg_m134, entity player, entity gunmount, entity mggun1) 
{
        mg_m134.cnt = time;
        if(mg_m134.vehicle_ammo1 >= autocvar_g_vehicle_mg_m134_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_m134.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_m134_machinegun_spread, autocvar_g_vehicle_mg_m134_machinegun_speed, 5, autocvar_g_vehicle_mg_m134_machinegun_damage, autocvar_g_vehicle_mg_m134_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_m134_machinegun_force, DEATH_SPORTSTERGUNLT, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_mg_m134_machinegun_bulletconstant, autocvar_g_vehicle_mg_m134_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire.wav", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_m134_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			//Casing
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 105, gunmount, "tag_casings");
		
			//Casinglink
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 34, gunmount, "tag_casings");
		}
  	 }	

            self = mg_m134;

            mg_m134.vehicle_ammo1 -= autocvar_g_vehicle_mg_m134_machinegun_ammo_cost;
            
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire
	                
	    player.vehicle_ammo1 = (mg_m134.vehicle_ammo1 / autocvar_g_vehicle_mg_m134_machinegun_ammo_max) * 100;
	    
	    
            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
	//Smooth animations. Also gun can spin via elec power even if no ammo
	} else if(mg_m134.vehicle_ammo1 < autocvar_g_vehicle_mg_m134_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire

            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.attack_finished_single <= time)
	{
	    mggun1.attack_finished_single = time + (mggun1.count*0.3333333); // 1/3 time
	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.cnt <= time)
	{
	    mggun1.cnt = time + (mggun1.count*0.6666666); // 2/3 time

	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        }
}

float mg_m134_frame()
{
    vector ad;
    entity player, mg_m134;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_m134 = self.vehicle;
    self   = mg_m134;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_m134.tur_head, gettagindex(mg_m134.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_m134);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_m134.angles), AnglesTransform_FromAngles(ad))) - mg_m134.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_m134_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_m134.tur_head.angles_y = bound(autocvar_g_vehicle_mg_m134_gun_turnlimit * -1, mg_m134.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_m134_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_m134_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_m134.tur_head.angles_x = bound(autocvar_g_vehicle_mg_m134_gun_pitchlimit_down, mg_m134.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_m134_gun_pitchlimit_up);


    //fixedmakevectors(mg_m134.angles);
    makevectors(mg_m134.angles + '-2 0 0' * mg_m134.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_m134_springlength, autocvar_g_vehicle_mg_m134_springup, autocvar_g_vehicle_mg_m134_springblend, autocvar_g_vehicle_mg_m134_tiltlimit);

    if(mg_m134.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_m134_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_m134.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_m134, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_m134.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_m134, player, autocvar_g_vehicle_mg_m134_speed_walk, autocvar_g_vehicle_mg_m134_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_m134_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_m134_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_m134_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_m134_tiltlimit);
    
    mg_resetpunchangle(player);
    
    if(player.BUTTON_ATCK)
    {
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_m134.vehicle_ammo1 >= autocvar_g_vehicle_mg_m134_machinegun_ammo_cost && mg_m134.tur_head.attack_finished_single <= time)
        	{
			dopunchangle = 1;
		}
	}
	
	mg_m134_fire(mg_m134, player, mg_m134.tur_head, mg_m134.gun1);
	mg_m134.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.15;
		player.punchangle_y = random () - 0.15;
	}
    } else {
    	if (mg_m134.count == 1) {
        vehicles_regen(mg_m134.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_m134_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_m134_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_m134.count = 1;
		sound (mg_m134, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_m134, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
	}
    }
       
       
       
    if(player.BUTTON_JUMP) {
    	mg_m134.gun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mg_m134.gun1.count - (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
	if(mg_m134.gun1.pushltime < time)  // Don't flood the connection with the messages
	{
		sprint(player, sprintf("RoF Raised to %f RPM\n", (60/mg_m134.gun1.count)));
		mg_m134.gun1.pushltime = time + 0.25;
	}
    }
    
    if(player.BUTTON_CROUCH ) {
    	mg_m134.gun1.count = bound(autocvar_g_vehicle_mg_m134_machinegun_refire_max, mg_m134.gun1.count + (autocvar_g_vehicle_mg_m134_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_m134_machinegun_refire_min);
	if(mg_m134.gun1.pushltime < time)  // Don't flood the connection with the messages
	{
		sprint(player, sprintf("RoF Lowered to %f RPM\n", (60/mg_m134.gun1.count)));
		mg_m134.gun1.pushltime = time + 0.25;
	}
    }
    player.BUTTON_JUMP   = 0;
    player.BUTTON_CROUCH    = 0;
    
    

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_m134.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_m134_shield, autocvar_g_vehicle_mg_m134_shield_regen_pause, autocvar_g_vehicle_mg_m134_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_m134.dmg_time, vehicle_health, autocvar_g_vehicle_mg_m134_health, autocvar_g_vehicle_mg_m134_health_regen_pause, autocvar_g_vehicle_mg_m134_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_m134.origin + '0 0 1' * MG_M134_MAX_z);
    player.velocity = mg_m134.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_m134);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_m134);

    player.vehicle_ammo1_current = mg_m134.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_m134.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_m134_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_m134_speed_stop);

    self.nextthink = time;
}

void mg_m134_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_m134_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_m134_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_m134_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_m134_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_m134_speed_strafe)
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

void mg_m134_impact()
{
    if(autocvar_g_vehicle_mg_m134_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_m134_bouncepain_x, autocvar_g_vehicle_mg_m134_bouncepain_y, autocvar_g_vehicle_mg_m134_bouncepain_z);    
}

void mg_m134_headfade()
{
	self.think = mg_m134_headfade;
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

void mg_m134_blowup()
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
    h.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
    setmodel(h,  "models/mountedguns/m134gun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_m134_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_m134_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_m134_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_m134_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_m134_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_m134_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_m134_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();
	setmodel(self.gun1,"models/mountedguns/m134gun_barrels.iqm");
	setattachment(self.gun1, self.tur_head, "tag_axis");
	self.gun1.count = autocvar_g_vehicle_mg_m134_machinegun_refire;
        
        self.gravity            = 1;
        self.mass               = 300;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/m134gun_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/m134gun_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_m134_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_m134_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_m134_shield;
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
    self.vehicle_impact = mg_m134_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_m134()
{
    if(!autocvar_g_vehicle_mg_m134)
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
    precache_model ( "models/mountedguns/m134gun.iqm");
    precache_model ( "models/mountedguns/m134gun_lod1.iqm");
    precache_model ( "models/mountedguns/m134gun_lod2.iqm");
    precache_model ( "models/mountedguns/m134gun_barrels.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/uzi_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_m134_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_m134_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_m134_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "M134Gun",
             bodymodel,
             "models/mountedguns/m134gun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_M134_MIN, MG_M134_MAX,
             FALSE,
             mg_m134_spawn, autocvar_g_vehicle_mg_m134_respawntime,
             mg_m134_frame,
             mg_m134_enter, mg_m134_exit,
             mg_m134_die,   mg_m134_think,
             FALSE, 
             autocvar_g_vehicle_mg_m134_health,
             autocvar_g_vehicle_mg_m134_shield, 1, autocvar_g_vehicle_mg_m134_machinegun_ammo_max * 6, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

