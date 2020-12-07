const vector MG_MAXIM_MIN = '-20 -20 1';
const vector MG_MAXIM_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mgnoforcedlight; //Don't force dynamic light on the bsp additions
float autocvar_g_vehicle_mg_maxim;

float autocvar_g_vehicle_mg_maxim_respawntime;

float autocvar_g_vehicle_mg_maxim_speed_stop;
float autocvar_g_vehicle_mg_maxim_speed_strafe;
float autocvar_g_vehicle_mg_maxim_speed_walk;
float autocvar_g_vehicle_mg_maxim_movement_inertia;

float autocvar_g_vehicle_mg_maxim_springlength;
float autocvar_g_vehicle_mg_maxim_springup;
float autocvar_g_vehicle_mg_maxim_springblend;
float autocvar_g_vehicle_mg_maxim_tiltlimit;

float autocvar_g_vehicle_mg_maxim_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_maxim_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_maxim_gun_pitchspeed;
float autocvar_g_vehicle_mg_maxim_gun_turnlimit;
float autocvar_g_vehicle_mg_maxim_gun_turnspeed;

float autocvar_g_vehicle_mg_maxim_health;
float autocvar_g_vehicle_mg_maxim_health_regen;
float autocvar_g_vehicle_mg_maxim_health_regen_pause;

float autocvar_g_vehicle_mg_maxim_shield;
float autocvar_g_vehicle_mg_maxim_shield_regen;
float autocvar_g_vehicle_mg_maxim_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_maxim_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_maxim_machinegun_speed;
float autocvar_g_vehicle_mg_maxim_machinegun_force;
// extraneous //float autocvar_g_vehicle_mg_maxim_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_maxim_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_maxim_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_maxim_machinegun_damage;
float autocvar_g_vehicle_mg_maxim_machinegun_refire;
float autocvar_g_vehicle_mg_maxim_machinegun_spread;
float autocvar_g_vehicle_mg_maxim_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_maxim_machinegun_ammo_max;
float autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_maxim_machinegun_force;
float autocvar_g_vehicle_mg_maxim_machinegun_speed;
// extraneous //float autocvar_g_vehicle_mg_maxim_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_maxim_bouncepain;

void mg_maxim_exit(float eject);
void mg_maxim_enter();
void mg_maxim_spawn(float);

vector mg_exit_stationary(vector spot)
{
	spot = self.origin + '0 0 40';
	return spot;
}

void mg_std_resists()
{
    self.resist_acid = 0;   //Slime
    self.resist_blunt = 1.0;  //Warhammer, beatdown, melee
    self.resist_bullet = 1.0;
    self.resist_crush = 0.10;  //Vehicle crush
    self.resist_edged = 1.0;  //Axe, Sword, Claw
    self.resist_electricity = 1.0; //Lightning gun, Tesla arc, 
    self.resist_energy = 1.0; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
    self.resist_explode = 0;//Rockets etc
    self.resist_fall = 1.0;   //Shooting star, fall etc
    self.resist_fire = 1.0;   //Fire, Lava
    self.resist_laser = 1.0;  //Laser
    self.resist_nuke = 0;  //Nuclear explosion
    self.resist_pierce = 1.0; //Crossbow, Bite
    self.resist_sound = 1.0; //Tuba
    self.resist_ice = 1.0; //Freeze damage resistance
    self.resist_rotor = 1.0; //Helicopter/Aero-plane Rotor blades damage resistance, Special, evaluated before crush
    self.buff_wont_ignite = 1; //Made of metal //Entity won't ignite if hit by Fire_AddDamage
}

void mg_shield_precache()
{
	if (self.vehicle_shieldtype == 1)
		precache_model ( "models/misc/mg_shield_metal.bsp");
	else if (self.vehicle_shieldtype == 2)
		precache_model ( "models/misc/mg_shield_energy.bsp");
	else if (self.vehicle_shieldtype == 3)
		precache_model ( "models/misc/mg_shield_iron.bsp");
	else if (self.vehicle_shieldtype == 4)
		precache_model ( "models/misc/mg_shield_thinmetal.bsp");
	else if (self.vehicle_shieldtype == 5)
		precache_model ( "models/misc/mg_shield_glass.bsp");
	else if (self.vehicle_shieldtype == 6)
		precache_model ( "models/misc/mg_shield_roundel.bsp");
	else if (self.vehicle_shieldtype == 7)
		precache_model ( "models/misc/mg_shield_grail.bsp");
	else if (self.vehicle_shieldtype == 8)
		precache_model ( "models/misc/mg_shield_rpk.bsp");
	else if (self.vehicle_shieldtype == 9)
		precache_model ( "models/misc/mg_shield_wood.bsp");
	else if (self.vehicle_shieldtype == 10)
		precache_model ( "models/misc/mg_shield_batteringram_wood.bsp");
	else if (self.vehicle_shieldtype == 11)
		precache_model ( "models/misc/mg_shield_energy2.bsp");
	else if (self.vehicle_shieldtype == 12
		|| self.vehicle_shieldtype == 13
		|| self.vehicle_shieldtype == 14
		|| self.vehicle_shieldtype == 15
		|| self.vehicle_shieldtype == 16)
		precache_model ( "models/misc/mg_shield_laser.bsp");
	else if (self.vehicle_shieldtype == 17)
		precache_model ( "models/misc/mg_shield_roundel2.bsp");
}

void mg_shield_idle()
{
	//Doin nothin
}

void mg_shield_die(entity e, entity hitbox)
{
	if (e.vehicle_shieldtype)
	{
	   tankt27_hitbox_die(hitbox); //Fine, doesnt do anything tank specific
	   hitbox.think = mg_shield_idle;
	}
}

void mg_shield_think()
{
	entity vehic, turhead;
	vector v;
	
	vehic = self.realowner;
	turhead = self.realowner.tur_head;
	//makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
	
	v = gettaginfo(vehic, gettagindex(vehic, "tag_gunpivot"));
	self.origin = v;
	self.angles = turhead.angles + vehic.angles;
	self.angles_x = self.angles_x * -1;
	
	setorigin(self, self.origin);
	self.nextthink = time;
	
	if (vehic.spawnflags >= 16) {
		//Fixed Mount, Makesure we don't move around due to pushing of the shield.
		//print("We are on a fixed mount: circ or pintel\n");
		if (vehic.origin_x != vehic.pos1_x || vehic.origin_y != vehic.pos1_y)
		{
			vehic.origin_x = vehic.pos1_x;
			vehic.origin_y = vehic.pos1_y;
			setorigin(vehic, vehic.origin);
			//print("We were moving, fixed in the x and y, back to spawn origin x y!\n");
		}
    	}
}

void mg_shield_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (self.realowner.vehicle_shieldtype == 1)
			spamsound (self, CH_PAIN, "object/impact_metal_2.ogg", VOL_BASE * 0.5, ATTN_NORM);
		else if (self.realowner.vehicle_shieldtype == 2)
			spamsound (self, CH_PAIN, "onslaught/ons_hit2.wav", VOL_BASE * 0.5, ATTN_NORM);
		else if (self.realowner.vehicle_shieldtype == 3)
			spamsound (self, CH_PAIN, "object/impact_metal_1.ogg", VOL_BASE * 0.5, ATTN_NORM);
		else if (self.realowner.vehicle_shieldtype == 4)
			spamsound (self, CH_PAIN, "object/impact_metal_3.ogg", VOL_BASE * 0.5, ATTN_NORM);
		//else if (self.realowner.vehicle_shieldtype == 5)
		//	//Glass
		else if (self.realowner.vehicle_shieldtype == 6)
			spamsound (self, CH_PAIN, "object/impact_metal_4.ogg", VOL_BASE * 0.5, ATTN_NORM);

	}
}


void mg_spawn_shield(float shieldtype, entity vehic, entity turhead, entity hitbox, float vehic_health)
{
    entity oldself;
    vector v;
    
    vehic.movetype = MOVETYPE_TOSS; //So shield weilding mounted gun decends to the floor on spawn, otherwise it just floats up in the air about 64 qunit, can't have that.
    
    hitbox.realowner              = vehic;
    
    if (shieldtype == 1) {
    	hitbox.model = "models/misc/mg_shield_metal.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 2) {
    	hitbox.model = "models/misc/mg_shield_energy.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 3) {
    	hitbox.model = "models/misc/mg_shield_iron.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 4) {
    	hitbox.model = "models/misc/mg_shield_thinmetal.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 5) {
    	hitbox.model = "models/misc/mg_shield_glass.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 6) {
    	hitbox.model = "models/misc/mg_shield_roundel.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 7) {
    	hitbox.model = "models/misc/mg_shield_grail.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 8) {
    	hitbox.model = "models/misc/mg_shield_rpk.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 9) {
    	hitbox.model = "models/misc/mg_shield_wood.bsp";
    } else if (shieldtype == 10) {
    	hitbox.model = "models/misc/mg_shield_batteringram_wood.bsp";
    } else if (shieldtype == 11) {
	hitbox.model = "models/misc/mg_shield_energy2.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 12) {
	hitbox.model = "models/misc/mg_shield_laser.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 13) {
    	//Red
	hitbox.colormap = (1024 + 4 + 4 * 16);
	hitbox.model = "models/misc/mg_shield_laser.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 14) {
    	//Green
	hitbox.colormap = (1024 + 3 + 3 * 16);
	hitbox.model = "models/misc/mg_shield_laser.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 15) {
    	//Cyan
	hitbox.colormap = (1024 + 6 + 6 * 16);
	hitbox.model = "models/misc/mg_shield_laser.bsp";
	hitbox.buff_wont_ignite = 1;
    } else if (shieldtype == 16) {
    	//Magenta
	hitbox.colormap = (1024 + 9 + 9 * 16);
	hitbox.model = "models/misc/mg_shield_laser.bsp";
	hitbox.buff_wont_ignite = 1; 
    } else if (shieldtype == 17) {
    	hitbox.model = "models/misc/mg_shield_roundel2.bsp";
	hitbox.buff_wont_ignite = 1;
    } else {
    	hitbox.model = "models/misc/mg_shield_metal.bsp";
	hitbox.buff_wont_ignite = 1;
    }
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    
    v = gettaginfo(vehic, gettagindex(vehic, "tag_gunpivot"));
    self.origin = v;
    self.angles = turhead.angles + vehic.angles;
    self.angles_x = self.angles_x * -1;
    setorigin(self, self.origin);

    hitbox.health = vehic_health;

    oldself = self;
    self = hitbox;
    //spawnfunc_func_breakable();
    //self.event_damage = func_null;
    //self.reset = func_null;
   
    if (!autocvar_g_vehicle_mgnoforcedlight) {
       if (!(self.effects & EF_DYNAMICMODELLIGHT)) self.effects += EF_DYNAMICMODELLIGHT;
    }
    
    self.mdl = self.model;
    SetBrushEntityModel();
    setmodel(self, self.mdl);
    self.solid = SOLID_BSP;
    self.takedamage = DAMAGE_AIM;
    self.bot_attack = FALSE;
    self.event_damage = mg_shield_damage;
    self.state = 0;
    self.health = 10000;
    self.max_health = self.health;
    self = oldself;
    
    hitbox.think              = mg_shield_think;
    hitbox.nextthink		= time;
}


float mg_maxim_aiframe()
{
    return FALSE;
}

void mg_maxim_SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, string tagname)
{
	entity e;
	vector org;
		
	org = gettaginfo(casingowner, gettagindex(casingowner, tagname));

	if(!sound_allowed(MSG_BROADCAST, casingowner))
		casingtype |= 0x80;

	e = spawn();
	e.state = casingtype;
	setorigin(e, org);
	e.velocity = vel;
	e.angles = ang;
	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, TRUE, 0.2, Casing_SendEntity);
		// 0.2s should be enough time for all clients to receive this ent once, do the gibbage and be done with it
}


void mg_maxim_AttachToShotorg(entity flash, vector offset, string tagname, entity attach)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;


	setattachment(flash, self, tagname);
	setorigin(flash, offset);

	xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = self;

	setattachment(xflash, attach, tagname);
	setorigin(xflash, offset);
}

void mg_maxim_fire(entity mg_maxim, entity player, entity gunmount) 
{
	mg_maxim.cnt = time;
        if(mg_maxim.vehicle_ammo1 >= autocvar_g_vehicle_mg_maxim_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_maxim.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_maxim_machinegun_spread, autocvar_g_vehicle_mg_maxim_machinegun_speed, 5, autocvar_g_vehicle_mg_maxim_machinegun_damage, autocvar_g_vehicle_mg_maxim_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_maxim_machinegun_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_vehicle_mg_maxim_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_maxim_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 105, gunmount, "tag_casings");
		}
  	 }	

            self = mg_maxim;

            mg_maxim.vehicle_ammo1 -= autocvar_g_vehicle_mg_maxim_machinegun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_maxim_machinegun_refire;
            player.vehicle_ammo1 = (mg_maxim.vehicle_ammo1 / autocvar_g_vehicle_mg_maxim_machinegun_ammo_max) * 100;
         
        }
}

void mg_resetpunchangle (entity player)
{
    //Reset punchangle like in cl_physics (normal player frame)
    if (player.punchangle != '0 0 0')
    {
    		local float paf;
		paf = vlen(player.punchangle) - 20 * frametime;
		if (paf > 0)
			player.punchangle = normalize(player.punchangle) * paf;
		else
			player.punchangle = '0 0 0';
    }
}

float mg_maxim_frame()
{
    vector ad;
    entity player, mg_maxim;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_maxim = self.vehicle;
    self   = mg_maxim;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_maxim.tur_head, gettagindex(mg_maxim.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_maxim);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_maxim.angles), AnglesTransform_FromAngles(ad))) - mg_maxim.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_maxim_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_maxim.tur_head.angles_y = bound(autocvar_g_vehicle_mg_maxim_gun_turnlimit * -1, mg_maxim.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_maxim_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_maxim_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_maxim.tur_head.angles_x = bound(autocvar_g_vehicle_mg_maxim_gun_pitchlimit_down, mg_maxim.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_maxim_gun_pitchlimit_up);


    //fixedmakevectors(mg_maxim.angles);
    makevectors(mg_maxim.angles + '-2 0 0' * mg_maxim.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_maxim_springlength, autocvar_g_vehicle_mg_maxim_springup, autocvar_g_vehicle_mg_maxim_springblend, autocvar_g_vehicle_mg_maxim_tiltlimit);

    if(mg_maxim.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_maxim_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_maxim.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_maxim, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_maxim.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
	 	mg_stdmove(mg_maxim, player, autocvar_g_vehicle_mg_maxim_speed_walk, autocvar_g_vehicle_mg_maxim_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_maxim_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_maxim_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_maxim_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_maxim_tiltlimit);
    
    //Reset punchangle like in cl_physics (normal player frame)
    mg_resetpunchangle(player);
    
    if(player.BUTTON_ATCK)
    {
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_maxim.vehicle_ammo1 >= autocvar_g_vehicle_mg_maxim_machinegun_ammo_cost && mg_maxim.tur_head.attack_finished_single <= time)
        	{
			dopunchangle = 1;
		}
	}
	
    	mg_maxim_fire(mg_maxim, player, mg_maxim.tur_head);
	mg_maxim.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.25;
		player.punchangle_y = random () - 0.25;
	}
    } else {
    	if (mg_maxim.count == 1) {
        vehicles_regen(mg_maxim.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_maxim_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_maxim.count = 1;
		sound (mg_maxim, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_maxim, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_maxim.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_maxim_shield, autocvar_g_vehicle_mg_maxim_shield_regen_pause, autocvar_g_vehicle_mg_maxim_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_maxim.dmg_time, vehicle_health, autocvar_g_vehicle_mg_maxim_health, autocvar_g_vehicle_mg_maxim_health_regen_pause, autocvar_g_vehicle_mg_maxim_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_maxim.origin + '0 0 1' * MG_MAXIM_MAX_z);
    player.velocity = mg_maxim.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_maxim);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_maxim);

    player.vehicle_ammo1_current = mg_maxim.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_maxim.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_maxim_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_maxim_speed_stop);

    self.nextthink = time;
}

void mg_maxim_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_maxim_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_maxim_shield) * 100;
    
    mg_enter(self.owner); 
}

void mg_maxim_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_maxim_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_maxim_speed_strafe)
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

void mg_maxim_impact()
{
    if(autocvar_g_vehicle_mg_maxim_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_maxim_bouncepain_x, autocvar_g_vehicle_mg_maxim_bouncepain_y, autocvar_g_vehicle_mg_maxim_bouncepain_z);    
}

void mg_maxim_headfade()
{
	self.think = mg_maxim_headfade;
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

void mg_maxim_blowup()
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
    h.lodmodel1 = "models/mountedguns/maximgun_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/maximgun_lod2.iqm";
    setmodel(h,  "models/mountedguns/maximgun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_maxim_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_maxim_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_maxim_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_maxim_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_maxim_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_maxim_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;

    mg_shield_die(self, self.hitboxft);
}

void mg_maxim_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        //setmodel(self.tur_head, "models/mountedguns/maximgun.iqm");
        //setattachment(self.tur_head, self, "tag_gunpivot");
        self.gravity            = 1;
        self.mass               = 300;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/maximgun_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/maximgun_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_maxim_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_maxim_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_maxim_shield;
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
    self.vehicle_impact = mg_maxim_impact;
    self.damageforcescale = 0.03;
    
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_maxim()
{
    if(!autocvar_g_vehicle_mg_maxim)
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
    precache_model ( "models/mountedguns/maximgun.iqm");
    precache_model ( "models/mountedguns/maximgun_lod1.iqm");
    precache_model ( "models/mountedguns/maximgun_lod2.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/campingrifle_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_maxim_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_maxim_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_maxim_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "Maxim",
	     bodymodel,
             "models/mountedguns/maximgun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_MAXIM_MIN, MG_MAXIM_MAX,
             FALSE,
             mg_maxim_spawn, autocvar_g_vehicle_mg_maxim_respawntime,
             mg_maxim_frame,
             mg_maxim_enter, mg_maxim_exit,
             mg_maxim_die,   mg_maxim_think,
             FALSE, 
             autocvar_g_vehicle_mg_maxim_health,
             autocvar_g_vehicle_mg_maxim_shield, 1, autocvar_g_vehicle_mg_maxim_machinegun_ammo_max * 6, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

