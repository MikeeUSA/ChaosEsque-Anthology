const vector MG_RPK_MIN = '-20 -20 1';
const vector MG_RPK_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_rpd;

float autocvar_g_vehicle_mg_rpd_respawntime;

float autocvar_g_vehicle_mg_rpd_speed_stop;
float autocvar_g_vehicle_mg_rpd_speed_strafe;
float autocvar_g_vehicle_mg_rpd_speed_walk;
float autocvar_g_vehicle_mg_rpd_movement_inertia;

float autocvar_g_vehicle_mg_rpd_springlength;
float autocvar_g_vehicle_mg_rpd_springup;
float autocvar_g_vehicle_mg_rpd_springblend;
float autocvar_g_vehicle_mg_rpd_tiltlimit;

float autocvar_g_vehicle_mg_rpd_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_rpd_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_rpd_gun_pitchspeed;
float autocvar_g_vehicle_mg_rpd_gun_turnlimit;
float autocvar_g_vehicle_mg_rpd_gun_turnspeed;

float autocvar_g_vehicle_mg_rpd_health;
float autocvar_g_vehicle_mg_rpd_health_regen;
float autocvar_g_vehicle_mg_rpd_health_regen_pause;

float autocvar_g_vehicle_mg_rpd_shield;
float autocvar_g_vehicle_mg_rpd_shield_regen;
float autocvar_g_vehicle_mg_rpd_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_rpd_machinegun_cooldownrate;
float autocvar_g_vehicle_mg_rpd_machinegun_cooldownwait;
float autocvar_g_vehicle_mg_rpd_machinegun_heatconstant;
float autocvar_g_vehicle_mg_rpd_machinegun_heatmin;
float autocvar_g_vehicle_mg_rpd_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_rpd_machinegun_speed;
float autocvar_g_vehicle_mg_rpd_machinegun_force;
float autocvar_g_vehicle_mg_rpd_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_rpd_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_rpd_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_rpd_machinegun_damage;
float autocvar_g_vehicle_mg_rpd_machinegun_refire;
float autocvar_g_vehicle_mg_rpd_machinegun_spread;
float autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_rpd_machinegun_ammo_max;
float autocvar_g_vehicle_mg_rpd_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_rpd_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_rpd_machinegun_force;
float autocvar_g_vehicle_mg_rpd_machinegun_speed;
float autocvar_g_vehicle_mg_rpd_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_rpd_bouncepain;


void mg_rpd_exit(float eject);
void mg_rpd_enter();
void mg_rpd_spawn(float);

float mg_rpd_aiframe()
{
    return FALSE;
}

void mg_rpd_fire(entity mg_rpd, entity player, entity gunmount) 
{
	mg_rpd.cnt = time;
        if(mg_rpd.vehicle_ammo1 >= autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_rpd.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_rpd_machinegun_spread, autocvar_g_vehicle_mg_rpd_machinegun_speed, 5, autocvar_g_vehicle_mg_rpd_machinegun_damage, autocvar_g_vehicle_mg_rpd_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_rpd_machinegun_force, DEATH_SPORTSTERGUNLT, PROJECTILE_BULLETRIFLE25, 1, autocvar_g_vehicle_mg_rpd_machinegun_bulletconstant, autocvar_g_vehicle_mg_rpd_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/ffsl_ak47_fire_deeperer.wav", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_rpd_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 25 + 25) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 100 + 120) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 104, gunmount, "tag_casings");
		}
  	 }	

            self = mg_rpd;

            mg_rpd.vehicle_ammo1 -= autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_rpd_machinegun_refire;
            gunmount.ammount3 =  time + (autocvar_g_vehicle_mg_rpd_machinegun_refire * 0.5);
	    player.vehicle_ammo1 = (mg_rpd.vehicle_ammo1 / autocvar_g_vehicle_mg_rpd_machinegun_ammo_max) * 100;
	    
	    mg_rpd.gun1.cnt = mg_rpd.gun1.cnt + autocvar_g_vehicle_mg_rpd_machinegun_heatconstant;
         
	    if (mg_rpd.gun1.cnt > random() )
 	    {
		sprint(player, "Your gun overheated\n");
		
		pointparticles(particleeffectnum("shotgun_muzzleflash"), gettaginfo(gunmount, gettagindex(gunmount, "tag_casings")), v_forward * 2, 1);
		
		gunmount.attack_finished_single = gunmount.attack_finished_single + (autocvar_g_vehicle_mg_rpd_machinegun_cooldownwait * (mg_rpd.gun1.cnt + 1));
	    }
	    
	    gunmount.skin = 1;
	    mg_rpd.ammount2 = 1;
	    
	    //print("1\n");
	//Smooth anim
        } else if(mg_rpd.ammount2 == 1 && mg_rpd.vehicle_ammo1 >= autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost && gunmount.ammount3 <= time) {
		//print("2\n");
		//Belt moves
		gunmount.skin = 0;
	    	mg_rpd.ammount2 = 0;
	} else if(mg_rpd.ammount2 != 2 && mg_rpd.vehicle_ammo1 < autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
		//print("3\n");
		//Empty
		gunmount.skin = 2;
		mg_rpd.ammount2 = 2;
	}
}

float mg_rpd_frame()
{
    vector ad;
    entity player, mg_rpd;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_rpd = self.vehicle;
    self   = mg_rpd;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_rpd.tur_head, gettagindex(mg_rpd.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_rpd);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_rpd.angles), AnglesTransform_FromAngles(ad))) - mg_rpd.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_rpd_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_rpd.tur_head.angles_y = bound(autocvar_g_vehicle_mg_rpd_gun_turnlimit * -1, mg_rpd.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_rpd_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_rpd_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_rpd.tur_head.angles_x = bound(autocvar_g_vehicle_mg_rpd_gun_pitchlimit_down, mg_rpd.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_rpd_gun_pitchlimit_up);


    //fixedmakevectors(mg_rpd.angles);
    makevectors(mg_rpd.angles + '-2 0 0' * mg_rpd.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_rpd_springlength, autocvar_g_vehicle_mg_rpd_springup, autocvar_g_vehicle_mg_rpd_springblend, autocvar_g_vehicle_mg_rpd_tiltlimit);

    if(mg_rpd.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_rpd_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_rpd.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_rpd, player, -100); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_rpd.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
	 	mg_stdmove(mg_rpd, player, autocvar_g_vehicle_mg_rpd_speed_walk, autocvar_g_vehicle_mg_rpd_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_rpd_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_rpd_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_rpd_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_rpd_tiltlimit);
    
    mg_resetpunchangle(player);
    
    if(player.BUTTON_ATCK)
    {
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_rpd.vehicle_ammo1 >= autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost && mg_rpd.tur_head.attack_finished_single <= time)
        	{
			dopunchangle = 1;
		}
	}
	
        mg_rpd_fire(mg_rpd, player, mg_rpd.tur_head);
	mg_rpd.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.125;
		player.punchangle_y = random () - 0.125;
	}
    } else {
    	if (mg_rpd.count == 1) {
        vehicles_regen(mg_rpd.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_rpd_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_rpd_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_rpd_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_rpd.count = 1;
		sound (mg_rpd, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_rpd, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
	}
	//Overheating and cooldown stuff://
	if (mg_rpd.gun1.cnt < autocvar_g_vehicle_mg_rpd_machinegun_heatmin) {
		mg_rpd.gun1.cnt = autocvar_g_vehicle_mg_rpd_machinegun_heatmin;
	} else {
		mg_rpd.gun1.cnt = mg_rpd.gun1.cnt - (autocvar_g_vehicle_mg_rpd_machinegun_cooldownrate * sys_frametime);
	}
	
	
	if (mg_rpd.ammount2 == 2) {
		//Empty?
		if (mg_rpd.vehicle_ammo1 >= autocvar_g_vehicle_mg_rpd_machinegun_ammo_cost) {
			//Reset skin, not empty
			mg_rpd.tur_head.skin = 0;
			mg_rpd.ammount2 = 0;
		}
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_rpd.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_rpd_shield, autocvar_g_vehicle_mg_rpd_shield_regen_pause, autocvar_g_vehicle_mg_rpd_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_rpd.dmg_time, vehicle_health, autocvar_g_vehicle_mg_rpd_health, autocvar_g_vehicle_mg_rpd_health_regen_pause, autocvar_g_vehicle_mg_rpd_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_rpd.origin + '0 0 1' * MG_RPK_MAX_z);
    player.velocity = mg_rpd.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_rpd);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_rpd);

    player.vehicle_ammo1_current = mg_rpd.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_rpd.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_rpd_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_rpd_speed_stop);

    self.nextthink = time;
}

void mg_rpd_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_rpd_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_rpd_shield) * 100;

    mg_enter(self.owner);
}

void mg_rpd_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_rpd_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_rpd_speed_strafe)
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

void mg_rpd_impact()
{
    if(autocvar_g_vehicle_mg_rpd_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_rpd_bouncepain_x, autocvar_g_vehicle_mg_rpd_bouncepain_y, autocvar_g_vehicle_mg_rpd_bouncepain_z);    
}

void mg_rpd_headfade()
{
	self.think = mg_rpd_headfade;
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

void mg_rpd_blowup()
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
    h.lodmodel1 = "models/weapons/v_rpd_lod1.md3";
    h.lodmodel2 = "models/weapons/v_rpd_lod2.md3";
    setmodel(h,  "models/weapons/v_rpd.md3");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_rpd_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_rpd_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_rpd_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_rpd_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_rpd_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_rpd_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_rpd_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();  
	self.gun1.cnt = autocvar_g_vehicle_mg_rpd_machinegun_heatmin;
        
        self.gravity            = 1;
        self.mass               = 300;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
		
	if (self.vehicle_shieldtype) {
		self.hitboxft = spawn();
		self.tur_head.origin_x = self.tur_head.origin_x - 2.5; //'-2.5 0 0'; //Move gun back abit, so we can see ammo box
	}
    }
    
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/weapons/v_rpd_lod1.md3";
    self.tur_head.lodmodel2 = "models/weapons/v_rpd_lod2.md3";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_rpd_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_rpd_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_rpd_shield;
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
    self.vehicle_impact = mg_rpd_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_rpd()
{
    if(!autocvar_g_vehicle_mg_rpd)
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
    precache_model ( "models/weapons/v_rpd.md3");
    precache_model ( "models/weapons/v_rpd_lod1.md3");
    precache_model ( "models/weapons/v_rpd_lod2.md3");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/ffsl_ak47_fire_deeperer.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_rpd_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_rpd_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_rpd_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "RpdGun",
             bodymodel,
             "models/weapons/v_rpd.md3",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_RPK_MIN, MG_RPK_MAX,
             FALSE,
             mg_rpd_spawn, autocvar_g_vehicle_mg_rpd_respawntime,
             mg_rpd_frame,
             mg_rpd_enter, mg_rpd_exit,
             mg_rpd_die,   mg_rpd_think,
             FALSE, 
             autocvar_g_vehicle_mg_rpd_health,
             autocvar_g_vehicle_mg_rpd_shield, 1, autocvar_g_vehicle_mg_rpd_machinegun_ammo_max * 12, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

