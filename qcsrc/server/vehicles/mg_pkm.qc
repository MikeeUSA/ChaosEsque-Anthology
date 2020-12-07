const vector MG_PKM_MIN = '-20 -20 1';
const vector MG_PKM_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_pkm;

float autocvar_g_vehicle_mg_pkm_respawntime;

float autocvar_g_vehicle_mg_pkm_speed_stop;
float autocvar_g_vehicle_mg_pkm_speed_strafe;
float autocvar_g_vehicle_mg_pkm_speed_walk;
float autocvar_g_vehicle_mg_pkm_movement_inertia;

float autocvar_g_vehicle_mg_pkm_springlength;
float autocvar_g_vehicle_mg_pkm_springup;
float autocvar_g_vehicle_mg_pkm_springblend;
float autocvar_g_vehicle_mg_pkm_tiltlimit;

float autocvar_g_vehicle_mg_pkm_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_pkm_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_pkm_gun_pitchspeed;
float autocvar_g_vehicle_mg_pkm_gun_turnlimit;
float autocvar_g_vehicle_mg_pkm_gun_turnspeed;

float autocvar_g_vehicle_mg_pkm_health;
float autocvar_g_vehicle_mg_pkm_health_regen;
float autocvar_g_vehicle_mg_pkm_health_regen_pause;

float autocvar_g_vehicle_mg_pkm_shield;
float autocvar_g_vehicle_mg_pkm_shield_regen;
float autocvar_g_vehicle_mg_pkm_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_pkm_machinegun_cooldownrate;
float autocvar_g_vehicle_mg_pkm_machinegun_cooldownwait;
float autocvar_g_vehicle_mg_pkm_machinegun_heatconstant;
float autocvar_g_vehicle_mg_pkm_machinegun_heatmin;
float autocvar_g_vehicle_mg_pkm_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_pkm_machinegun_speed;
float autocvar_g_vehicle_mg_pkm_machinegun_force;
// extraneous //float autocvar_g_vehicle_mg_pkm_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_pkm_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_pkm_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_pkm_machinegun_damage;
float autocvar_g_vehicle_mg_pkm_machinegun_refire;
float autocvar_g_vehicle_mg_pkm_machinegun_spread;
float autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_pkm_machinegun_ammo_max;
float autocvar_g_vehicle_mg_pkm_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_pkm_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_pkm_machinegun_force;
float autocvar_g_vehicle_mg_pkm_machinegun_speed;
// extraneous //float autocvar_g_vehicle_mg_pkm_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_pkm_bouncepain;


void mg_pkm_exit(float eject);
void mg_pkm_enter();
void mg_pkm_spawn(float);

float mg_pkm_aiframe()
{
    return FALSE;
}

void mg_pkm_fire(entity mg_pkm, entity player, entity gunmount) 
{
	mg_pkm.cnt = time;
        ////////////// Open Bolt Trigger lag code
	if (!autocvar_g_balance_noopenbolttriggerlag) {
		if (mg_pkm.mg_triggerlag == 1) {
			if (time >= mg_pkm.mg_triggerlag_maxtime) {
				mg_pkm.mg_triggerlag = 0;
			} else if (time >= mg_pkm.mg_triggerlag_time)	{
				mg_pkm.mg_triggerlag = 3; //Force fire
			}
		}
	}
	
	if(
	(!autocvar_g_balance_noopenbolttriggerlag && !mg_pkm.mg_triggerlag)
	&& mg_pkm.vehicle_ammo1 >= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
		//Button is pressed, but we cannot fire yet since we are openbolt
		//Thus we set triggerlag to 1
		//When trigger lag is 2 or 3 it fires
		//When trigger lag is 3 it is forced to fire
		//When 2, if the button is not down it does not fire.
		//print("1\n");
		mg_pkm.mg_triggerlag_time = time + (autocvar_g_vehicle_mg_pkm_machinegun_refire * 0.5);
		
		if (frametime > autocvar_g_vehicle_mg_pkm_machinegun_refire) {
			//Frametime not enough to keep up, don't want to jam up gun
			//print("Insufficent frametime lags PKM gun\n");
			mg_pkm.mg_triggerlag_maxtime = time + (frametime * 1.5);
		} else {
			//Normal
			mg_pkm.mg_triggerlag_maxtime = time + (autocvar_g_vehicle_mg_pkm_machinegun_refire * 0.99);
		}	
        	mg_pkm.mg_triggerlag = 1;
		////////////// Open Bolt Trigger lag code
	} else if(
	(autocvar_g_balance_noopenbolttriggerlag || mg_pkm.mg_triggerlag >= 2)
	&& mg_pkm.vehicle_ammo1 >= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    mg_pkm.mg_triggerlag = 2; //For open bolt trigger lag
	    
            vector v;
            mg_pkm.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_pkm_machinegun_spread, autocvar_g_vehicle_mg_pkm_machinegun_speed, 5, autocvar_g_vehicle_mg_pkm_machinegun_damage, autocvar_g_vehicle_mg_pkm_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_pkm_machinegun_force, DEATH_SPORTSTERGUNLT, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_vehicle_mg_pkm_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet
	 
	 //Note projectile changed to bulletrifle9mm from bulletrifle25

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/ffsl_ak47_fire_deepererer.wav", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_pkm_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 100 + 100) * -1 * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 100 + 120) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 125, gunmount, "tag_casings");
		}
  	 }	

            self = mg_pkm;

            mg_pkm.vehicle_ammo1 -= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_pkm_machinegun_refire;
            gunmount.ammount3 =  time + (autocvar_g_vehicle_mg_pkm_machinegun_refire * 0.5);
	    player.vehicle_ammo1 = (mg_pkm.vehicle_ammo1 / autocvar_g_vehicle_mg_pkm_machinegun_ammo_max) * 100;
	    
	    mg_pkm.gun1.cnt = mg_pkm.gun1.cnt + autocvar_g_vehicle_mg_pkm_machinegun_heatconstant;
         
	    if (mg_pkm.gun1.cnt > random() )
 	    {
		sprint(player, "Your gun overheated\n");
		
		pointparticles(particleeffectnum("shotgun_muzzleflash"), gettaginfo(gunmount, gettagindex(gunmount, "tag_casings")), v_forward * 2, 1);
		
		gunmount.attack_finished_single = gunmount.attack_finished_single + (autocvar_g_vehicle_mg_pkm_machinegun_cooldownwait * (mg_pkm.gun1.cnt + 1));
	    }
	    
	    gunmount.skin = 1;
	    mg_pkm.ammount2 = 1;
	    
	    //print("1\n");
	//Smooth anim
        } else if(mg_pkm.ammount2 == 1 && mg_pkm.vehicle_ammo1 >= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost && gunmount.ammount3 <= time) {
		//print("2\n");
		//Belt moves
		gunmount.skin = 0;
	    	mg_pkm.ammount2 = 0;
	} else if(mg_pkm.ammount2 != 2 && mg_pkm.vehicle_ammo1 < autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
		//print("3\n");
		//Empty
		gunmount.skin = 2;
		mg_pkm.ammount2 = 2;
	}
}

float mg_pkm_frame()
{
    vector ad;
    entity player, mg_pkm;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_pkm = self.vehicle;
    self   = mg_pkm;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_pkm.tur_head, gettagindex(mg_pkm.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_pkm);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_pkm.angles), AnglesTransform_FromAngles(ad))) - mg_pkm.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_pkm_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_pkm.tur_head.angles_y = bound(autocvar_g_vehicle_mg_pkm_gun_turnlimit * -1, mg_pkm.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_pkm_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_pkm_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_pkm.tur_head.angles_x = bound(autocvar_g_vehicle_mg_pkm_gun_pitchlimit_down, mg_pkm.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_pkm_gun_pitchlimit_up);


    //fixedmakevectors(mg_pkm.angles);
    makevectors(mg_pkm.angles + '-2 0 0' * mg_pkm.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_pkm_springlength, autocvar_g_vehicle_mg_pkm_springup, autocvar_g_vehicle_mg_pkm_springblend, autocvar_g_vehicle_mg_pkm_tiltlimit);

    if(mg_pkm.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_pkm_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_pkm.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_pkm, player, -100); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_pkm.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
	 	mg_stdmove(mg_pkm, player, autocvar_g_vehicle_mg_pkm_speed_walk, autocvar_g_vehicle_mg_pkm_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_pkm_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_pkm_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_pkm_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_pkm_tiltlimit);
    
    mg_resetpunchangle(player);
    
    ////////////// Open Bolt Trigger lag code
    if (!autocvar_g_balance_noopenbolttriggerlag) {
    	if (mg_pkm.mg_triggerlag == 2) {
    		if (player.BUTTON_ATCK) {
			//Do nothing
		} else {
			mg_pkm.mg_triggerlag = 0;
		}
  	  }
    }
    ////////////// Open Bolt Trigger lag code
    
    if(player.BUTTON_ATCK
    || (!autocvar_g_balance_noopenbolttriggerlag && mg_pkm.mg_triggerlag))
    {
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_pkm.vehicle_ammo1 >= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost && mg_pkm.tur_head.attack_finished_single <= time)
        	{
			if (autocvar_g_balance_noopenbolttriggerlag || mg_pkm.mg_triggerlag >= 2
			|| (mg_pkm.mg_triggerlag == 1 && time >= mg_pkm.mg_triggerlag_time && !(time >= mg_pkm.mg_triggerlag_maxtime))
			) {
				//Here we only do the punchangle if we will fire.
				dopunchangle = 1;
			}
		}
	}
	
        mg_pkm_fire(mg_pkm, player, mg_pkm.tur_head);
	mg_pkm.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.125;
		player.punchangle_y = random () - 0.125;
	}
    } else {
    	if (mg_pkm.count == 1) {
        vehicles_regen(mg_pkm.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_pkm_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_pkm_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_pkm_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_pkm.mg_triggerlag = 0; //For open bolt trigger lag
		mg_pkm.count = 1;
		sound (mg_pkm, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_pkm, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
	}
	//Overheating and cooldown stuff://
	if (mg_pkm.gun1.cnt < autocvar_g_vehicle_mg_pkm_machinegun_heatmin) {
		mg_pkm.gun1.cnt = autocvar_g_vehicle_mg_pkm_machinegun_heatmin;
	} else {
		mg_pkm.gun1.cnt = mg_pkm.gun1.cnt - (autocvar_g_vehicle_mg_pkm_machinegun_cooldownrate * sys_frametime);
	}
	
	
	if (mg_pkm.ammount2 == 2) {
		//Empty?
		if (mg_pkm.vehicle_ammo1 >= autocvar_g_vehicle_mg_pkm_machinegun_ammo_cost) {
			//Reset skin, not empty
			mg_pkm.tur_head.skin = 0;
			mg_pkm.ammount2 = 0;
		}
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_pkm.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_pkm_shield, autocvar_g_vehicle_mg_pkm_shield_regen_pause, autocvar_g_vehicle_mg_pkm_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_pkm.dmg_time, vehicle_health, autocvar_g_vehicle_mg_pkm_health, autocvar_g_vehicle_mg_pkm_health_regen_pause, autocvar_g_vehicle_mg_pkm_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_pkm.origin + '0 0 1' * MG_PKM_MAX_z);
    player.velocity = mg_pkm.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_pkm);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_pkm);

    player.vehicle_ammo1_current = mg_pkm.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_pkm.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_pkm_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_pkm_speed_stop);

    self.nextthink = time;
}

void mg_pkm_enter()
{
    self.mg_triggerlag = 0; //For open bolt trigger lag
    
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_pkm_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_pkm_shield) * 100;

    mg_enter(self.owner);
}

void mg_pkm_exit(float eject)
{
    vector spot;
    
    self.mg_triggerlag = 0; //For open bolt trigger lag

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_pkm_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_pkm_speed_strafe)
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

void mg_pkm_impact()
{
    if(autocvar_g_vehicle_mg_pkm_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_pkm_bouncepain_x, autocvar_g_vehicle_mg_pkm_bouncepain_y, autocvar_g_vehicle_mg_pkm_bouncepain_z);    
}

void mg_pkm_headfade()
{
	self.think = mg_pkm_headfade;
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

void mg_pkm_blowup()
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
    h.lodmodel1 = "models/weapons/v_pkm_belt250_lod1.md3";
    //h.lodmodel2 = "models/weapons/v_pkm_belt250_lod2.md3";
    setmodel(h,  "models/weapons/v_pkm_belt250.md3");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_pkm_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_pkm_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_pkm_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_pkm_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_pkm_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_pkm_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_pkm_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();  
	self.gun1.cnt = autocvar_g_vehicle_mg_pkm_machinegun_heatmin;
        
        self.gravity            = 1;
        self.mass               = 300;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
		
	if (self.vehicle_shieldtype) {
		self.hitboxft = spawn();
		self.tur_head.origin_x = self.tur_head.origin_x - 1.5; //'-2.5 0 0'; //Move gun back abit, so we can see ammo box
	}
    }
    
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/weapons/v_pkm_belt250_lod1.md3";
    //self.tur_head.lodmodel2 = "models/weapons/v_pkm_belt250_lod2.md3";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_pkm_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_pkm_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_pkm_shield;
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
    self.vehicle_impact = mg_pkm_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_pkm()
{
    if(!autocvar_g_vehicle_mg_pkm)
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
    precache_model ( "models/weapons/v_pkm_belt250.md3");
    precache_model ( "models/weapons/v_pkm_belt250_lod1.md3");
    //precache_model ( "models/weapons/v_pkm_belt250_lod2.md3");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/ffsl_ak47_fire_deepererer.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_pkm_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_pkm_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_pkm_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "PkmGun",
             bodymodel,
             "models/weapons/v_pkm_belt250.md3",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_PKM_MIN, MG_PKM_MAX,
             FALSE,
             mg_pkm_spawn, autocvar_g_vehicle_mg_pkm_respawntime,
             mg_pkm_frame,
             mg_pkm_enter, mg_pkm_exit,
             mg_pkm_die,   mg_pkm_think,
             FALSE, 
             autocvar_g_vehicle_mg_pkm_health,
             autocvar_g_vehicle_mg_pkm_shield, 1, autocvar_g_vehicle_mg_pkm_machinegun_ammo_max * 12, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

