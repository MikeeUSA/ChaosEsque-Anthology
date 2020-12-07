const vector MG_T17MM_MIN = '-20 -20 1';
const vector MG_T17MM_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_t17mm;

float autocvar_g_vehicle_mg_t17mm_respawntime;

float autocvar_g_vehicle_mg_t17mm_speed_stop;
float autocvar_g_vehicle_mg_t17mm_speed_strafe;
float autocvar_g_vehicle_mg_t17mm_speed_walk;
float autocvar_g_vehicle_mg_t17mm_movement_inertia;

float autocvar_g_vehicle_mg_t17mm_springlength;
float autocvar_g_vehicle_mg_t17mm_springup;
float autocvar_g_vehicle_mg_t17mm_springblend;
float autocvar_g_vehicle_mg_t17mm_tiltlimit;

float autocvar_g_vehicle_mg_t17mm_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_t17mm_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_t17mm_gun_pitchspeed;
float autocvar_g_vehicle_mg_t17mm_gun_turnlimit;
float autocvar_g_vehicle_mg_t17mm_gun_turnspeed;

float autocvar_g_vehicle_mg_t17mm_health;
float autocvar_g_vehicle_mg_t17mm_health_regen;
float autocvar_g_vehicle_mg_t17mm_health_regen_pause;

float autocvar_g_vehicle_mg_t17mm_shield;
float autocvar_g_vehicle_mg_t17mm_shield_regen;
float autocvar_g_vehicle_mg_t17mm_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_t17mm_machinegun_cooldownrate;
float autocvar_g_vehicle_mg_t17mm_machinegun_cooldownwait;
float autocvar_g_vehicle_mg_t17mm_machinegun_heatconstant;
float autocvar_g_vehicle_mg_t17mm_machinegun_heatmin;
float autocvar_g_vehicle_mg_t17mm_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_t17mm_machinegun_speed;
float autocvar_g_vehicle_mg_t17mm_machinegun_force;
// extraneous //float autocvar_g_vehicle_mg_t17mm_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_t17mm_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_t17mm_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_t17mm_machinegun_damage;
float autocvar_g_vehicle_mg_t17mm_machinegun_refire;
float autocvar_g_vehicle_mg_t17mm_machinegun_spread;
float autocvar_g_vehicle_mg_t17mm_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max;
float autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_t17mm_machinegun_force;
float autocvar_g_vehicle_mg_t17mm_machinegun_speed;
// extraneous //float autocvar_g_vehicle_mg_t17mm_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_t17mm_bouncepain;


void mg_t17mm_exit(float eject);
void mg_t17mm_enter();
void mg_t17mm_spawn(float);

float mg_t17mm_aiframe()
{
    return FALSE;
}

void mg_t17mm_fire(entity mg_t17mm, entity player, entity gunmount) 
{
	mg_t17mm.cnt = time;
        if(mg_t17mm.vehicle_ammo1 >= autocvar_g_vehicle_mg_t17mm_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_t17mm.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_t17mm_machinegun_spread, autocvar_g_vehicle_mg_t17mm_machinegun_speed, 5, autocvar_g_vehicle_mg_t17mm_machinegun_damage, autocvar_g_vehicle_mg_t17mm_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_t17mm_machinegun_force, DEATH_SPORTSTERGUNHV, PROJECTILE_BULLETRIFLE17MM, 1, autocvar_g_balance_projectile_t17mmrifle_bulletconstant, autocvar_g_vehicle_mg_t17mm_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash1"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash1", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
	 
	    
   	if (autocvar_g_vehicle_mg_t17mm_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 12 + 20) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 29, gunmount, "tag_casings");
		//Not rifle style casings, those look too big for this gun
		}
  	 }	
	 
	 self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun2"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_t17mm_machinegun_spread, autocvar_g_vehicle_mg_t17mm_machinegun_speed, 5, autocvar_g_vehicle_mg_t17mm_machinegun_damage, autocvar_g_vehicle_mg_t17mm_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_t17mm_machinegun_force, DEATH_SPORTSTERGUNHV, PROJECTILE_BULLETRIFLE17MM, 1, autocvar_g_balance_projectile_t17mmrifle_bulletconstant, autocvar_g_vehicle_mg_t17mm_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash2"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 fokkerFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash2, '5 0 0', "tag_flash2", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
	 sound (gunmount, CH_WEAPON_A, "weapons/hook_impact.wav", VOL_BASE, ATTN_NORM);
	 
	    
   	if (autocvar_g_vehicle_mg_t17mm_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 12 + 20) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 29, gunmount, "tag_casings");
		}
  	 }	


            self = mg_t17mm;

            mg_t17mm.vehicle_ammo1 -= autocvar_g_vehicle_mg_t17mm_machinegun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_t17mm_machinegun_refire;
            player.vehicle_ammo1 = (mg_t17mm.vehicle_ammo1 / autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max) * 100;
	    
	    if (mg_t17mm.gun1.ammount) {
	    	//print("Divide by ammount\n");
	    	mg_t17mm.gun1.cnt = mg_t17mm.gun1.cnt + (autocvar_g_vehicle_mg_t17mm_machinegun_heatconstant / mg_t17mm.gun1.ammount);
	    } else {
	    	mg_t17mm.gun1.cnt = mg_t17mm.gun1.cnt + autocvar_g_vehicle_mg_t17mm_machinegun_heatconstant;
 	    }
	 
	    if (mg_t17mm.gun1.cnt > random() )
 	    {
		sprint(player, "Your gun overheated\n");
		
		pointparticles(particleeffectnum("shotgun_muzzleflash"), gettaginfo(gunmount, gettagindex(gunmount, "tag_casings")), v_forward * 2, 1);
		
		gunmount.attack_finished_single = gunmount.attack_finished_single + (autocvar_g_vehicle_mg_t17mm_machinegun_cooldownwait * (mg_t17mm.gun1.cnt + 1));
	    }
        }
}

float mg_t17mm_frame()
{
    vector ad;
    entity player, mg_t17mm;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_t17mm = self.vehicle;
    self   = mg_t17mm;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_t17mm.tur_head, gettagindex(mg_t17mm.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_t17mm);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_t17mm.angles), AnglesTransform_FromAngles(ad))) - mg_t17mm.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_t17mm_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_t17mm.tur_head.angles_y = bound(autocvar_g_vehicle_mg_t17mm_gun_turnlimit * -1, mg_t17mm.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_t17mm_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_t17mm_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_t17mm.tur_head.angles_x = bound(autocvar_g_vehicle_mg_t17mm_gun_pitchlimit_down, mg_t17mm.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_t17mm_gun_pitchlimit_up);


    //fixedmakevectors(mg_t17mm.angles);
    makevectors(mg_t17mm.angles + '-2 0 0' * mg_t17mm.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_t17mm_springlength, autocvar_g_vehicle_mg_t17mm_springup, autocvar_g_vehicle_mg_t17mm_springblend, autocvar_g_vehicle_mg_t17mm_tiltlimit);

    if(mg_t17mm.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_t17mm_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_t17mm.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_t17mm, player, -200); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_t17mm.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_t17mm, player, autocvar_g_vehicle_mg_t17mm_speed_walk, autocvar_g_vehicle_mg_t17mm_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_t17mm_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_t17mm_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_t17mm_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_t17mm_tiltlimit);
    
    mg_resetpunchangle(player);
    
    if(player.BUTTON_ATCK)
    {
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_t17mm.vehicle_ammo1 >= autocvar_g_vehicle_mg_t17mm_machinegun_ammo_cost && mg_t17mm.tur_head.attack_finished_single <= time)
        	{
			dopunchangle = 1;
		}
	}
	
	mg_t17mm_fire(mg_t17mm, player, mg_t17mm.tur_head);
	mg_t17mm.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.375;
		player.punchangle_y = random () - 0.375;
	}
    } else {
    	if (mg_t17mm.count == 1) {
        vehicles_regen(mg_t17mm.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_t17mm.count = 1;
		sound (mg_t17mm, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_t17mm, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	}
	//Overheating and cooldown stuff://
	if (mg_t17mm.gun1.cnt < autocvar_g_vehicle_mg_t17mm_machinegun_heatmin) {
		mg_t17mm.gun1.cnt = autocvar_g_vehicle_mg_t17mm_machinegun_heatmin;
	} else {
		mg_t17mm.gun1.cnt = mg_t17mm.gun1.cnt - (autocvar_g_vehicle_mg_t17mm_machinegun_cooldownrate * sys_frametime);
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_t17mm.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_t17mm_shield, autocvar_g_vehicle_mg_t17mm_shield_regen_pause, autocvar_g_vehicle_mg_t17mm_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_t17mm.dmg_time, vehicle_health, autocvar_g_vehicle_mg_t17mm_health, autocvar_g_vehicle_mg_t17mm_health_regen_pause, autocvar_g_vehicle_mg_t17mm_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_t17mm.origin + '0 0 1' * MG_T17MM_MAX_z);
    player.velocity = mg_t17mm.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_t17mm);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_t17mm);

    player.vehicle_ammo1_current = mg_t17mm.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_t17mm.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_t17mm_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_t17mm_speed_stop);

    self.nextthink = time;
}

void mg_t17mm_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_t17mm_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_t17mm_shield) * 100;

    mg_enter(self.owner);
}

void mg_t17mm_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_t17mm_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_t17mm_speed_strafe)
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

void mg_t17mm_impact()
{
    if(autocvar_g_vehicle_mg_t17mm_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_t17mm_bouncepain_x, autocvar_g_vehicle_mg_t17mm_bouncepain_y, autocvar_g_vehicle_mg_t17mm_bouncepain_z);    
}

void mg_t17mm_headfade()
{
	self.think = mg_t17mm_headfade;
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

void mg_t17mm_blowup()
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
    h.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
    h.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
    setmodel(h,  "models/mountedguns/t17mmgun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_t17mm_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_t17mm_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_t17mm_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_t17mm_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_t17mm_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_t17mm_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_t17mm_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();  
	self.gun1.cnt = autocvar_g_vehicle_mg_t17mm_machinegun_heatmin;

        self.gravity            = 2;
        self.mass               = 5000;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
    self.tur_head.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_t17mm_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_t17mm_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_t17mm_shield;
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
    self.vehicle_impact = mg_t17mm_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_t17mm()
{
    if(!autocvar_g_vehicle_mg_t17mm)
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
    precache_model ( "models/mountedguns/t17mmgun.iqm");
    precache_model ( "models/mountedguns/t17mmgun_lod1.iqm");
    precache_model ( "models/mountedguns/t17mmgun_lod2.iqm");
    precache_model ( "models/mountedguns/t17mmgun_lod3.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_t17mm_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_t17mm_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_t17mm_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "T17mmGun",
             bodymodel,
             "models/mountedguns/t17mmgun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_T17MM_MIN, MG_T17MM_MAX,
             FALSE,
             mg_t17mm_spawn, autocvar_g_vehicle_mg_t17mm_respawntime,
             mg_t17mm_frame,
             mg_t17mm_enter, mg_t17mm_exit,
             mg_t17mm_die,   mg_t17mm_think,
             FALSE, 
             autocvar_g_vehicle_mg_t17mm_health,
             autocvar_g_vehicle_mg_t17mm_shield, 1, autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max * 6, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

