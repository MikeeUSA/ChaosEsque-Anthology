const vector MECHMAX_MIN = '-16 -16 -24' * 1.75;
const vector MECHMAX_MAX  = '16 16 40' * 1.75;
const vector MECHMAX_CROUCH_MIN = '-16 -16 -24' * 1.75;
const vector MECHMAX_CROUCH_MAX  = '16 16 25' * 1.75;

#ifdef SVQC
float autocvar_g_vehicle_mechmax;
float autocvar_g_vehicle_mechmax_autoshotgun_refire;
float autocvar_g_vehicle_mechmax_shotgun_refire;

float autocvar_g_vehicle_spiderbot_respawntime;

float autocvar_g_vehicle_spiderbot_speed_stop;
float autocvar_g_vehicle_mechmax_speed_strafe;
float autocvar_g_vehicle_mechmax_speed_walk;
float autocvar_g_vehicle_spiderbot_turnspeed;
float autocvar_g_vehicle_spiderbot_turnspeed_strafe;
float autocvar_g_vehicle_spiderbot_movement_inertia;

float autocvar_g_vehicle_spiderbot_springlength;
float autocvar_g_vehicle_spiderbot_springup;
float autocvar_g_vehicle_spiderbot_springblend;
float autocvar_g_vehicle_spiderbot_tiltlimit;

float autocvar_g_vehicle_mechmax_head_pitchlimit_down;
float autocvar_g_vehicle_mechmax_head_pitchlimit_up;
float autocvar_g_vehicle_spiderbot_head_turnlimit;
float autocvar_g_vehicle_spiderbot_head_turnspeed;

//float autocvar_g_vehicle_spiderbot_energy;
//float autocvar_g_vehicle_spiderbot_energy_regen;
//float autocvar_g_vehicle_spiderbot_energy_regen_pause;

float autocvar_g_vehicle_mechmax_health;
float autocvar_g_vehicle_mechmax_health_regen;
float autocvar_g_vehicle_mechmax_health_regen_pause;

float autocvar_g_vehicle_mechmax_shield;
float autocvar_g_vehicle_mechmax_shield_regen;
float autocvar_g_vehicle_mechmax_shield_regen_pause;

float autocvar_g_vehicle_spiderbot_minigun_damage;
float autocvar_g_vehicle_spiderbot_minigun_refire;
float autocvar_g_vehicle_spiderbot_minigun_spread;
float autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
float autocvar_g_vehicle_spiderbot_minigun_ammo_max;
float autocvar_g_vehicle_spiderbot_minigun_ammo_regen;
float autocvar_g_vehicle_spiderbot_minigun_ammo_regen_pause;
float autocvar_g_vehicle_spiderbot_minigun_force;
float autocvar_g_vehicle_spiderbot_minigun_speed;
float autocvar_g_vehicle_spiderbot_minigun_bulletconstant;

float autocvar_g_vehicle_spiderbot_rocket_damage;
float autocvar_g_vehicle_spiderbot_rocket_force;
float autocvar_g_vehicle_spiderbot_rocket_radius;
float autocvar_g_vehicle_mechmax_rocket_speed;
float autocvar_g_vehicle_spiderbot_rocket_spread;
float autocvar_g_vehicle_spiderbot_rocket_refire;
float autocvar_g_vehicle_spiderbot_rocket_refire2;
float autocvar_g_vehicle_spiderbot_rocket_reload;
float autocvar_g_vehicle_spiderbot_rocket_health;
float autocvar_g_vehicle_spiderbot_rocket_noise;
float autocvar_g_vehicle_spiderbot_rocket_turnrate;
float autocvar_g_vehicle_spiderbot_rocket_lifetime;

vector autocvar_g_vehicle_spiderbot_bouncepain;


void mechmax_exit(float eject);
void mechmax_enter();
void mechmax_spawn(float);

void mechmax_guide_release()
{
    entity rkt;
    rkt = findchainentity(realowner, self.owner);
    if not (rkt)
        return;

    crosshair_trace(self.owner);
    while(rkt)
    {
        if(rkt.think == spiderbot_rocket_guided)
        {
            rkt.pos1 = trace_endpos;
            rkt.think = spiderbot_rocket_unguided;
        }
        rkt = rkt.chain;
    }
}

void mechmax_rocket_do(entity player)
{

    vector v;
    entity rocket = world;

    if (self.wait != -10)
    {        
        if (self.owner.BUTTON_ATCK2 && self.vehicle_weapon2mode == SBRM_GUIDE)
        {
            if (self.wait == 1)
            if (self.tur_head.frame == 9 || self.tur_head.frame == 1)
            {
                if(self.gun2.cnt < time && self.tur_head.frame == 9)
                    self.tur_head.frame = 1;

                return;
            }
            self.wait = 1;
        }
        else
        {
            if(self.wait)
                mechmax_guide_release();

            self.wait = 0;
        }
    }
    
    if(self.gun2.cnt > time)
        return;
	
    if (player.vehicle_reload2 < 100)
        return;

    if (self.tur_head.frame >= 9)
    {
        self.tur_head.frame = 1;
        self.wait = 0;
    }
        
    if (self.wait != -10)
        if not (self.owner.BUTTON_ATCK2)
            return;


    v = gettaginfo(self,gettagindex(self,"head"));
    v_x -= 32;
    

            rocket = vehicles_projectile("spiderbot_rocket_launch", "weapons/rocket_fire.wav",
                                   v, normalize(v_forward) * autocvar_g_vehicle_mechmax_rocket_speed,
                                   autocvar_g_vehicle_spiderbot_rocket_damage, autocvar_g_vehicle_spiderbot_rocket_radius, autocvar_g_vehicle_spiderbot_rocket_force, 1,
                                   DEATH_SBROCKET, PROJECTILE_SPIDERROCKET, autocvar_g_vehicle_spiderbot_rocket_health, FALSE, TRUE, self.owner);
            
            crosshair_trace(self.owner);
            
            rocket.pos1       = trace_endpos + randomvec() * (0.75 * autocvar_g_vehicle_spiderbot_rocket_radius);
            rocket.pos1_z       = trace_endpos_z;
            
            traceline(v, v + '0 0 1' * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, self);             
            float h1 = 0.75 * vlen(v - trace_endpos);
            
            //v = trace_endpos;
            traceline(v , rocket.pos1 + '0 0 1' * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, self); 
            float h2 = 0.75 * vlen(rocket.pos1 - v);
            
            rocket.velocity  = spiberbot_calcartillery(v, rocket.pos1, ((h1 < h2) ? h1 : h2));
            rocket.movetype  = MOVETYPE_TOSS;            
            rocket.gravity   = 1;
            //rocket.think     = spiderbot_rocket_artillery;   

    rocket.classname  = "spiderbot_rocket";
    
    rocket.cnt = time + autocvar_g_vehicle_spiderbot_rocket_lifetime;
    
    self.tur_head.frame += 1;
    if (self.tur_head.frame == 9)
        self.attack_finished_single = autocvar_g_vehicle_spiderbot_rocket_reload;
    else
        self.attack_finished_single = ((self.vehicle_weapon2mode ==  SBRM_VOLLY) ? autocvar_g_vehicle_spiderbot_rocket_refire2 : autocvar_g_vehicle_spiderbot_rocket_refire);

    self.gun2.cnt = time + self.attack_finished_single;
}

float mechmax_aiframe()
{
    return FALSE;
}

float mechmax_frame()
{
    vector ad, vf;
    entity player, spider;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    spider = self.vehicle;
    self   = spider;

    vehicles_painframe();
    
    if (player.stat_sv_hudshownameenemies != 5)
    {
    	player.stat_sv_hudshownameenemies = 5;
	//sprint(player, sprintf("Infographical HUD Overlay Enabled\n"));
    }
    
    player.BUTTON_ZOOM      = 0;
    player.switchweapon     = 0;
     
    if (player.BUTTON_CROUCH)	{
	if (!spider.crouch)
	{
		spider.crouch = TRUE;
		setsize (spider, MECHMAX_CROUCH_MIN, MECHMAX_CROUCH_MAX);
		setorigin(spider.vehicle_hudmodel, '0 0 10');
	}
    }
    else
    {
	if (spider.crouch)
	{
		tracebox(spider.origin, MECHMAX_MIN, MECHMAX_MAX, spider.origin, FALSE, spider);
		if (!trace_startsolid)
		{
			spider.crouch = FALSE;
			setsize (spider, MECHMAX_MIN, MECHMAX_MAX);
			setorigin(spider.vehicle_hudmodel, '0 0 26');
		}
	}
    }
    //player.BUTTON_CROUCH    = 0;


    ad = gettaginfo(spider.gun1, gettagindex(spider.gun1, "barrels"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, spider);
    if (spider.spawnflags & 64) {
        UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 0);
    } else {
    	UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 0 0' * (1 - player.vehicle_reload1)), 0);
    }
    vf = ad;
    ad = gettaginfo(spider.gun2, gettagindex(spider.gun2, "barrels"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, spider);
    if (spider.spawnflags & 64) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0.5 0.5 0.5', 1);
    } else {
    	UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 0 0' * (1 - player.vehicle_reload1)), 1);
    }
    ad = 0.5 * (ad + vf);


    crosshair_trace(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(spider.angles), AnglesTransform_FromAngles(ad))) - spider.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_spiderbot_head_turnspeed * sys_frametime;    
    //ad_y = bound(-ftmp, ad_y, ftmp);
    //spider.angles_y = spider.angles_y + ad_y;
    spider.angles_y = player.v_angle_y;

    // Pitch head
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    spider.angles_x = bound(autocvar_g_vehicle_mechmax_head_pitchlimit_down, spider.angles_x + ad_x, autocvar_g_vehicle_mechmax_head_pitchlimit_up);


    //fixedmakevectors(spider.angles);
    makevectors(spider.angles + '-2 0 0' * spider.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_spiderbot_springlength, autocvar_g_vehicle_spiderbot_springup, autocvar_g_vehicle_spiderbot_springblend, autocvar_g_vehicle_spiderbot_tiltlimit);

    if(spider.flags & FL_ONGROUND)
    {
        if((spider.frame == 8 || spider.frame == 5) && self.tur_head.wait != 0)
        {
            sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_land.wav", VOL_VEHICLEENGINE, ATTN_NORM);
            if(spider.crouch) spider.frame = 6; else spider.frame = 7;            
        }
        
        if(player.BUTTON_JUMP && self.tur_head.wait < time)
        {        
            sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_jump.wav", VOL_VEHICLEENGINE, ATTN_NORM);
            //dprint("mechmax_jump:", ftos(soundlength("vehicles/spiderbot_jump.wav")), "\n");
            self.delay = 0;

            self.tur_head.wait = time + 2;
            player.BUTTON_JUMP = 0;
            spider.velocity   = v_forward * 700 + v_up * 600;
            if(spider.crouch) spider.frame = 5; else spider.frame = 8;
        }
        else
        {
            if(vlen(player.movement) == 0)
            {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_idle.wav");
                    //dprint("mechmax_idle:", ftos(soundlength("vehicles/spiderbot_idle.wav")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_idle.wav", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_spiderbot_speed_stop);
                if(spider.crouch) spider.frame = 6; else spider.frame = 7;
            }
            else
            {
                // Turn Body
                if(player.movement_x == 0 && player.movement_y != 0)
                    ftmp = autocvar_g_vehicle_spiderbot_turnspeed_strafe * sys_frametime;
                else
                    ftmp = autocvar_g_vehicle_spiderbot_turnspeed * sys_frametime;
                
                ftmp = bound(-ftmp, spider.angles_y, ftmp);                
                spider.angles_y = anglemods(spider.angles_y + ftmp);
                spider.angles_y -= ftmp;

                if(player.movement_x != 0)
                {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        if(spider.crouch) spider.frame = 4; else spider.frame = 13;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        if(spider.crouch) spider.frame = 24; else spider.frame = 14;
                    }
                    player.movement_y = 0;
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_mech_waterspeed_simple(player, autocvar_g_vehicle_mechmax_speed_walk),autocvar_g_vehicle_spiderbot_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_walk.wav");
                        sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_walk.wav", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("mechmax_walk:", ftos(soundlength("vehicles/spiderbot_walk.wav")), "\n");
                    }
                }
                else if(player.movement_y != 0)
                {
                    if(player.movement_y < 0)
                    {
                        player.movement_y = -1;
                        if(spider.crouch) spider.frame = 25; else spider.frame = 15;
                    }
                    else if(player.movement_y > 0)
                    {
                        player.movement_y = 1;
                        if(spider.crouch) spider.frame = 26; else spider.frame = 16;
                    }
                    movelib_move_simple(normalize(v_right * player.movement_y),autocvar_g_vehicle_mechmax_speed_strafe,autocvar_g_vehicle_spiderbot_movement_inertia);
                    if(self.sound_nexttime < time || self.delay != 2)
                    {                        
                        self.delay = 2;
                        self.sound_nexttime = time + 6.486500; //soundlength("vehicles/spiderbot_strafe.wav");
                        sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_strafe.wav", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("mechmax_strafe:", ftos(soundlength("vehicles/spiderbot_strafe.wav")), "\n");
                    }
                }
            }
        }
    }

    self.angles_x = bound(-autocvar_g_vehicle_spiderbot_tiltlimit, self.angles_x, autocvar_g_vehicle_spiderbot_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_spiderbot_tiltlimit, self.angles_z, autocvar_g_vehicle_spiderbot_tiltlimit);
    
    if (spider.spawnflags & 64) {
       if(player.BUTTON_ATCK)
       {
        spider.cnt = time;
        if(spider.vehicle_ammo1 >= autocvar_g_vehicle_spiderbot_minigun_ammo_cost && spider.tur_head.attack_finished_single <= time)
        {
	    	spider.count = 0; //Will have to press R to resume reload
            	entity gun;
            	vector v;

            	self = player;

            	gun = spider.gun1;
            	v = gettaginfo(gun, gettagindex(gun, "mgun"));
            	v_forward = normalize(v_forward);
            	v += v_forward * 50;

  	 	// Start Ballistic bullet
	 	//Shotgun
	 	float	sc;
		float	ammoamount;
		float	bullets;
		float	d;
		float	f;
		float	spread;
		float	bulletspeed;
		float	bulletconstant;
		entity flash;

		ammoamount = autocvar_g_balance_shotgun_primary_ammo;
		bullets = autocvar_g_balance_shotgun_primary_bullets;
		d = autocvar_g_balance_shotgun_primary_damage;
		f = autocvar_g_balance_shotgun_primary_force;
		spread = autocvar_g_balance_shotgun_primary_spread;
		bulletspeed = autocvar_g_balance_shotgun_primary_speed;
		bulletconstant = autocvar_g_balance_shotgun_primary_bulletconstant;

		for (sc = 0;sc < bullets;sc = sc + 1)
			fireBallisticBullet(v, v_forward, spread, bulletspeed, 5, d, 0, f, WEP_SHOTGUN, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant, autocvar_g_balance_shotgun_primary_coreshotaddeddamage);
		endFireBallisticBullet();

	 
		 sound (gun, CH_WEAPON_A, "weapons/shotgun_fire.wav", VOL_BASE, ATTN_NORM);

		//Shotgun
		// End Ballistic bullet 


	            pointparticles(particleeffectnum("shotgun_muzzleflash"), v, v_forward * 2600, 1);
	    
      		if (autocvar_g_vehicle_spiderbot_minigun_expelbulletcasings == 1) {
  			if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 1, self);
			}
      		}

            	self = spider;

            	spider.vehicle_ammo1 -= autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
            	spider.tur_head.attack_finished_single = time + autocvar_g_vehicle_mechmax_autoshotgun_refire;
            	player.vehicle_ammo1 = (spider.vehicle_ammo1 / autocvar_g_vehicle_spiderbot_minigun_ammo_max) * 100;
        	}
       }
       
       if(player.BUTTON_ATCK2)
       {
        spider.cnt = time;
	if(spider.gun2.count != 1)
        if(spider.vehicle_ammo1 >= (autocvar_g_vehicle_spiderbot_minigun_ammo_cost * 3) && spider.gun2.attack_finished_single <= time)
        {
	    	spider.count = 0; //Will have to press R to resume reload
            	entity gun;
            	vector v;

            	self = player;

            	gun = spider.gun2;
            	v = gettaginfo(gun, gettagindex(gun, "mgun"));
            	v_forward = normalize(v_forward);
            	v += v_forward * 50;

  	 	// Start Ballistic bullet
	 	//Shotgun
		float	sc2;
		float	ammoamount2;
		float	bullets2;
		float	d2;
		float	f2;
		float	spread2;
		float	bulletspeed2;
		float	bulletconstant2;
		local entity flash;

		ammoamount2 = autocvar_g_balance_shotgunautomat_secondary_ammo;
		bullets2 = autocvar_g_balance_shotgunautomat_secondary_bullets;
		d2 = autocvar_g_balance_shotgunautomat_secondary_damage;
		f2 = autocvar_g_balance_shotgunautomat_secondary_force;
		spread2 = autocvar_g_balance_shotgunautomat_secondary_spread;
		bulletspeed2 = autocvar_g_balance_shotgunautomat_secondary_speed;
		bulletconstant2 = autocvar_g_balance_shotgunautomat_secondary_bulletconstant;

		W_DecreaseAmmo(ammo_shells, ammoamount2, autocvar_g_balance_shotgunautomat_reload_ammo);

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed2 >= autocvar_g_antilag_bullets, 5, "weapons/shotgun_fire.wav", CH_WEAPON_A, d2 * bullets2);
		for (sc2 = 0;sc2 < bullets2;sc2 = sc2 + 1)
		fireBallisticBullet(v, v_forward, spread2, bulletspeed2, 5, d2, 0, f2, WEP_SHOTGUNAUTOMAT, PROJECTILE_BULLETSHOTGUN, 1, bulletconstant2, autocvar_g_balance_shotgunautomat_secondary_coreshotaddeddamage);
		endFireBallisticBullet();

	 
		 sound (gun, CH_WEAPON_A, "weapons/shotgun_fire.wav", VOL_BASE, ATTN_NORM);

		//Shotgun
		// End Ballistic bullet 


	            pointparticles(particleeffectnum("shotgun_muzzleflash"), v, v_forward * 2600, 1);
	    
      		if (autocvar_g_vehicle_spiderbot_minigun_expelbulletcasings == 1) {
  			if (autocvar_g_casings >= 2) {
				for (sc2 = 0;sc2 < ammoamount2;sc2 = sc2 + 1) {
					SpawnCasing (((random () * 50 + 50) * v_right) - 
					(v_forward * (random () * 25 + 25)) - 
					((random () * 5 - 70) * v_up), 2, 
					vectoangles(v_forward),'0 250 0', 100, 1, self);
				}
			}
      		}
		
		spider.gun2.count = 1;
            	self = spider;

            	spider.vehicle_ammo1 -= autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
            	spider.gun2.attack_finished_single = time + autocvar_g_vehicle_mechmax_shotgun_refire;
            	player.vehicle_ammo1 = (spider.vehicle_ammo1 / autocvar_g_vehicle_spiderbot_minigun_ammo_max) * 100;
        	}
       }
       
       if not(player.BUTTON_ATCK)
       if not(player.BUTTON_ATCK2)
       {
       		spider.gun2.count = 0;
		
    		if (spider.count == 1) {
        	vehicles_regen(spider.cnt, vehicle_ammo1, autocvar_g_vehicle_spiderbot_minigun_ammo_max,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen_pause,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
        
		} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
			spider.count = 1;
			sound (spider, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
		
		if (player.impulse == 20)
    		if (player.BUTTON_HOOK) {
			//Reload from own stores //25 ammo, 1 player ammo = 1 vehic ammo,
			vehicles_replenishAmmo(player, spider, ammo_shells, vehicle_ammo1_current, vehicle_ammo1_max, 25, 1);
			
		}
       }
    } else {
    ///////////////////////////
    //Begin Normal Firing Block
    if(player.BUTTON_ATCK)
    {
        spider.cnt = time;
        if(spider.vehicle_ammo1 >= autocvar_g_vehicle_spiderbot_minigun_ammo_cost && spider.tur_head.attack_finished_single <= time)
        {
	    spider.count = 0; //Will have to press R to resume reload
            entity gun;
            vector v;
            spider.misc_bulletcounter += 1;

            self = player;

            mod(spider.misc_bulletcounter, 2) ? gun = spider.gun1 : gun = spider.gun2;
            v = gettaginfo(gun, gettagindex(gun, "barrels"));
            v_forward = normalize(v_forward);
            v += v_forward * 50;

  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_spiderbot_minigun_spread,autocvar_g_balance_hmg_speed, 5,
	    	autocvar_g_balance_hmg_sustained_damage, autocvar_g_balance_hmg_sustained_headshotaddeddamage,
		autocvar_g_balance_hmg_sustained_force, WEP_HMG, PROJECTILE_BULLETRIFLE9MM, 1, autocvar_g_balance_hmg_bulletconstant, autocvar_g_balance_hmg_sustained_coreshotaddeddamage);
	  endFireBallisticBullet();
	 
	 
	 sound (gun, CH_WEAPON_A, "weapons/campingrifle_fire2.wav", VOL_BASE, ATTN_NORM);

	// End Ballistic bullet 


            pointparticles(particleeffectnum("mechmax_minigun_muzzleflash"), v, v_forward * 2500, 1);
	    
   if (autocvar_g_vehicle_spiderbot_minigun_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 3, self);
	}
   }

            self = spider;

            spider.vehicle_ammo1 -= autocvar_g_vehicle_spiderbot_minigun_ammo_cost;
            spider.tur_head.attack_finished_single = time + autocvar_g_vehicle_spiderbot_minigun_refire;
            player.vehicle_ammo1 = (spider.vehicle_ammo1 / autocvar_g_vehicle_spiderbot_minigun_ammo_max) * 100;
            spider.gun1.angles_z += 45;
            spider.gun2.angles_z -= 45;
            if(spider.gun1.angles_z >= 360)
            {
                spider.gun1.angles_z = 0;
                spider.gun2.angles_z = 0;
            }
        }
    }
    else
    {
    	if (spider.count == 1) {
        vehicles_regen(spider.cnt, vehicle_ammo1, autocvar_g_vehicle_spiderbot_minigun_ammo_max,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen_pause,
                                           autocvar_g_vehicle_spiderbot_minigun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
        
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		spider.count = 1;
		sound (spider, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
    	if (player.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, spider, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
	}
    }
    
    mechmax_rocket_do(player);
    //End Normal Firing Block
    /////////////////////////
    }

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(spider.dmg_time, vehicle_shield, autocvar_g_vehicle_mechmax_shield, autocvar_g_vehicle_mechmax_shield_regen_pause, autocvar_g_vehicle_mechmax_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(spider.dmg_time, vehicle_health, autocvar_g_vehicle_mechmax_health, autocvar_g_vehicle_mechmax_health_regen_pause, autocvar_g_vehicle_mechmax_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    player.vehicle_ammo2 = spider.tur_head.frame;

    if (spider.vehicle_ammo2_current > 0) {
    	if(spider.gun2.cnt <= time)
        	player.vehicle_reload2 = 100;
   	else
        	player.vehicle_reload2 = 100 - ((spider.gun2.cnt - time) / spider.attack_finished_single) * 100;
        
	if (player.vehicle_reload2 < 100) {
		spider.vehicle_ammo2_current = spider.vehicle_ammo2_current - (1 * sys_frametime);
	}
    }

    setorigin(player, spider.origin + '0 0 1' * MECHMAX_MAX_z);
    player.velocity = spider.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mechmax);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mechmax);

    player.vehicle_ammo1_current = spider.vehicle_ammo1_current;
    player.vehicle_ammo1_max = spider.vehicle_ammo1_max;
    player.vehicle_ammo2_current = spider.vehicle_ammo2_current;
    player.vehicle_ammo2_max = spider.vehicle_ammo2_max;

    self = player;
    return 1;    
}
void mechmax_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_spiderbot_speed_stop);

    self.nextthink = time;
}

void mechmax_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mechmax_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mechmax_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void mechmax_exit(float eject)
{
    entity e;
    vector spot;
    
    e = findchain(classname,"spiderbot_rocket");
    while(e)
    {
        if(e.owner == self.owner)
        {
            e.realowner = self.owner;
            e.owner = world;
        }
        e = e.chain;
    }

    //self.velocity   = '0 0 0';
    self.think      = mechmax_think;
    self.nextthink  = time;
    self.frame      = 7;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_mechmax_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void mechmax_headfade()
{
	self.think = mechmax_headfade;
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

void mechmax_blowup()
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
    
    b.lodmodel1 = "models/player/megaerebus_lod1.iqm";
    b.lodmodel2 = "models/player/megaerebus_lod2.iqm";
    setmodel(b,  "models/player/megaerebus.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    setmodel(h,  "models/misc/playerspikes_head.iqm");
    //setmodel(h,  "null");
    if (self.spawnflags & 64) {
    	setmodel(g1, "models/vehicles/maxshotgun1.iqm");
    	setmodel(g2, "models/vehicles/maxshotgun2.iqm");
    } else {
    	setmodel(g1, "models/vehicles/spiderbot_barrels.dpm");
    	setmodel(g2, "models/vehicles/spiderbot_barrels.dpm");
    }

    setorigin(b, self.origin);
    b.scale         = self.scale;
    b.skin          = self.skin;
    b.frame         = 18;
    b.angles        = self.angles;
    setsize(b, self.mins, self.maxs);

    setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
    h.scale         = self.scale;
    h.movetype      = MOVETYPE_BOUNCE;
    h.solid         = SOLID_BBOX;
    h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
    h.modelflags    = MF_ROCKET;
    h.effects       = EF_FLAME | EF_LOWPRECISION;
    h.avelocity     = randomvec() * 360;

    h.alpha         = 1;
    h.cnt           = time + (3.5 * random());
    h.fade_rate     = 1 / min(autocvar_g_vehicle_spiderbot_respawntime, 10);
    h.fade_time     = time;
    h.think         = mechmax_headfade;
    h.nextthink     = time;

    setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
    g1.scale         = self.scale;
    g1.movetype     = MOVETYPE_TOSS;
    g1.solid        = SOLID_CORPSE;
    g1.velocity     = v_forward * 700 + (randomvec() * 32);
    g1.avelocity    = randomvec() * 180;

    setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
    g2.scale         = self.scale;
    g2.movetype     = MOVETYPE_TOSS;
    g2.solid        = SOLID_CORPSE;
    g2.velocity     = v_forward * 700 + (randomvec() * 32);
    g2.avelocity    = randomvec() * 180;

    h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_spiderbot_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_spiderbot_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha =
    self.bomb1.alpha = self.bomb2.alpha = self.bomb3.alpha =
    self.bomb4.alpha = self.bomb5.alpha = self.bomb6.alpha =
    self.bomb7.alpha = self.bomb8.alpha = self.bomb9.alpha =
    self.bomb10.alpha = self.bomb13.alpha = self.bomb14.alpha =
    self.bomb15.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mechmax_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mechmax_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 7;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 1;
	self.movetype           = MOVETYPE_TOSS;
}

float mechmax_impulse(float _imp)
{
    switch(_imp)
    {
        case 10:
        case 15:        
        case 18:
            self.vehicle.vehicle_weapon2mode += 1;
            if(self.vehicle.vehicle_weapon2mode > SBRM_LAST)
                self.vehicle.vehicle_weapon2mode = SBRM_FIRST;
            
            //centerprint(self, strcat("Rocket mode is ", ftos(self.vehicle.vehicle_weapon2mode)));
            CSQCVehicleSetup(self, 0);
            return TRUE;
        case 12:
        case 16:
        case 19:
            self.vehicle.vehicle_weapon2mode -= 1;
            if(self.vehicle.vehicle_weapon2mode < SBRM_FIRST)
                self.vehicle.vehicle_weapon2mode = SBRM_LAST;
            
            //centerprint(self, strcat("Rocket mode is ", ftos(self.vehicle.vehicle_weapon2mode)));
            CSQCVehicleSetup(self, 0);
            return TRUE;

        /*			
        case 17: // toss gun, could be used to exit?
            break;
        case 20: // Manual minigun reload?
            break;
        */
    }    
    return FALSE;
}

void mechmax_spawn(float _f)
{
    if(!self.gun1)
    {
    	////Spike Ornaments
    	self.bomb1               = spawn();
    	setmodel(self.bomb1,  "models/misc/playerspikes_head.iqm");
	self.bomb1.angles    = '0 0 0';
	setattachment(self.bomb1, self, "head");
	setorigin(self.bomb1, '0 8 0');    // Move attch spot up 8// back 0// yes fscked up bone   

	
	self.bomb2               = spawn();
    	setmodel(self.bomb2,  "models/misc/playerspikes.iqm");
	self.bomb2.angles    = '0 0 0';
	setattachment(self.bomb2, self, "upperleg_L");
	
	self.bomb3               = spawn();
    	setmodel(self.bomb3,  "models/misc/playerspikes.iqm");
	self.bomb3.angles    = '0 0 0';
	setattachment(self.bomb3, self, "upperleg_R");
	
	setorigin(self.bomb2, '0 15 4');    // Move attch spot down 15// forward 4// yes fscked up bone
	setorigin(self.bomb3, '0 15 4');    // Move attch spot down 15// forward 4// yes fscked up bone
	
	self.bomb8             = spawn();
    	setmodel(self.bomb8,  "models/misc/playerspikes.iqm");
	self.bomb8.angles    = '0 0 0';
	setattachment(self.bomb8, self, "upperleg_L");
	
	self.bomb9            = spawn();
    	setmodel(self.bomb9,  "models/misc/playerspikes.iqm");
	self.bomb9.angles    = '0 0 0';
	setattachment(self.bomb9, self, "upperleg_R");
	
	setorigin(self.bomb8, '0 10 4');    // Move attch spot down 15// forward 4// yes fscked up bone
	setorigin(self.bomb9, '0 10 4');    // Move attch spot down 15// forward 4// yes fscked up bone
	
	self.bomb10             = spawn();
    	setmodel(self.bomb10,  "models/misc/playerspikes.iqm");
	self.bomb10.angles    = '0 0 0';
	setattachment(self.bomb10, self, "upperleg_L");
	
	self.bomb13            = spawn();
    	setmodel(self.bomb13,  "models/misc/playerspikes.iqm");
	self.bomb13.angles    = '0 0 0';
	setattachment(self.bomb13, self, "upperleg_R");
	
	setorigin(self.bomb10, '0 6 4');    // Move attch spot down 15// forward 4// yes fscked up bone
	setorigin(self.bomb13, '0 6 4');    // Move attch spot down 15// forward 4// yes fscked up bone

	self.bomb4               = spawn();
    	setmodel(self.bomb4,  "models/misc/playerspikes.iqm");
	self.bomb4.angles    = '0 0 0';
	setattachment(self.bomb4, self, "upperarm_L");
	
	self.bomb5               = spawn();
    	setmodel(self.bomb5,  "models/misc/playerspikes.iqm");
	self.bomb5.angles    = '0 0 0';
	setattachment(self.bomb5, self, "upperarm_R");
	
	setorigin(self.bomb4, '0 10 0');
	setorigin(self.bomb5, '0 10 0');
	
	self.bomb6               = spawn();
    	setmodel(self.bomb6,  "models/misc/playerspikes.iqm");
	self.bomb6.angles    = '0 0 0';
	setattachment(self.bomb6, self, "upperarm_L");
	
	self.bomb7               = spawn();
    	setmodel(self.bomb7,  "models/misc/playerspikes.iqm");
	self.bomb7.angles    = '0 0 0';
	setattachment(self.bomb7, self, "upperarm_R");
	
	setorigin(self.bomb6, '0 0 4');
	setorigin(self.bomb7, '0 0 4');
	
	
	self.bomb14               = spawn();
    	setmodel(self.bomb14,  "models/misc/playerspikes.iqm");
	self.bomb14.angles    = '0 0 0';
	setattachment(self.bomb14, self, "hand_L");
	
	self.bomb15           = spawn();
    	setmodel(self.bomb15,  "models/misc/playerspikes.iqm");
	self.bomb15.angles    = '0 0 0';
	setattachment(self.bomb15, self, "hand_R");
	//End Spike Ornaments
	
	
        //self.vehicles_impusle   = mechmax_impulse;
        self.gun1               = spawn();
        self.gun2               = spawn();
	if (self.spawnflags & 64) {
		self.gun1.scale = self.gun2.scale = 0.6;
        	setmodel(self.gun1, "models/vehicles/maxshotgun1.iqm");
        	setmodel(self.gun2, "models/vehicles/maxshotgun2.iqm");
		self.gun1.angles    = '-90 0 -90';
		self.gun2.angles    = '-90 0 -90';
		setattachment(self.gun1, self, "head");
		setorigin(self.gun1, '-8 1 -3');    // Move attach spot up 1// yes fscked up bone

        	setattachment(self.gun2, self, "head");
		setorigin(self.gun2, '8 -1 4');    // Move attch spot up 0// back 4// Down 1// yes fscked up bone

	} else {
		self.gun1.scale = self.gun2.scale = 0.4;
        	setmodel(self.gun1, "models/vehicles/spiderbot_barrels.dpm");
        	setmodel(self.gun2, "models/vehicles/spiderbot_barrels.dpm");
		self.gun1.angles    = '-90 0 0';
		self.gun2.angles    = '-90 0 0';
		setattachment(self.gun1, self, "head");
		setorigin(self.gun1, '8 0 5');    // Move attch spot up 0// back 5// yes fscked up bone

        	setattachment(self.gun2, self, "head");
		setorigin(self.gun2, '-8 2 0');    // Move attach spot up 2// yes fscked up bone
	}

        self.gravity            = 2;
        self.mass               = 1000;
	setattachment(self.vehicle_viewport, self, "head");
	setorigin(self.vehicle_viewport, '0 8 1');    // Move camera up// yes fscked up bone
    }
    self.lodmodel1 = "models/player/megaerebus_lod1.iqm";
    self.lodmodel2 = "models/player/megaerebus_lod2.iqm";
    InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
    self.skin = 1;
    self.scale = self.vehicle_hudmodel.scale = 1.75;
    self.vehicle_hudmodel.angles = '0 90 0';
    setorigin(self.vehicle_hudmodel, '0 0 26');
    self.frame              = 7;
    self.think              = mechmax_think;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mechmax_health;
    self.vehicle_shield     = autocvar_g_vehicle_mechmax_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha =
    self.bomb1.alpha = self.bomb2.alpha = self.bomb3.alpha =
    self.bomb4.alpha = self.bomb5.alpha = self.bomb6.alpha =
    self.bomb7.alpha = self.bomb8.alpha = self.bomb9.alpha =
    self.bomb10.alpha = self.bomb13.alpha = self.bomb14.alpha =
    self.bomb15.alpha  = 1;
    self.bomb1.colormap = self.bomb2.colormap = self.bomb3.colormap =
    self.bomb4.colormap = self.bomb5.colormap = self.bomb6.colormap =
    self.bomb7.colormap = self.bomb8.colormap = self.bomb9.colormap =
    self.bomb10.colormap = self.bomb13.colormap = self.bomb14.colormap =
    self.bomb15.colormap  = 1023; //Black aslong as 255th client doesn't join
    self.tur_head.angles    = '0 0 0';
    self.tur_head.alpha    = -1;
    self.angles    = '0 0 0';

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = spider_impact;
    self.damageforcescale = 0.03;
}

void spawnfunc_vehicle_mechmax()
{
    if(!autocvar_g_vehicle_mechmax)
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
    precache_model ( "models/player/megaerebus.iqm");
    precache_model ( "models/player/megaerebus_lod1.iqm");
    precache_model ( "models/player/megaerebus_lod2.iqm");
    precache_model ( "models/vehicles/spiderbot_top.dpm");
    float cammo2max;
    if (self.spawnflags & 64) {
    	precache_model ( "models/vehicles/maxshotgun1.iqm");
    	precache_model ( "models/vehicles/maxshotgun2.iqm");
	precache_sound ( "weapons/shotgun_fire.wav");
	cammo2max = 0;
    } else {
    	precache_model ( "models/vehicles/spiderbot_barrels.dpm");
	precache_sound ( "weapons/campingrifle_fire2.wav" );
	cammo2max = autocvar_g_vehicle_spiderbot_rocket_refire * 256;
    }
    precache_model ( "models/vehicles/spiderbot_cockpit.dpm");
    precache_model ( "models/uziflash.md3");
    precache_model ( "models/misc/playerspikes_head.iqm");
    precache_model ( "models/misc/playerspikes.iqm");
    precache_model ( "models/vehicles/megaerebus_headinterior.iqm");
    
    precache_sound ( "weapons/rocket_impact.wav");
    
    precache_sound ( "vehicles/spiderbot_die.wav");
    precache_sound ( "vehicles/spiderbot_idle.wav");
    precache_sound ( "vehicles/spiderbot_jump.wav");
    precache_sound ( "vehicles/spiderbot_strafe.wav");
    precache_sound ( "vehicles/spiderbot_walk.wav");
    precache_sound ( "vehicles/spiderbot_land.wav");

    if(autocvar_g_vehicle_mechmax_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mechmax_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mechmax_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "MechMAX",
             "models/player/megaerebus.iqm",
             "null",
             "models/vehicles/megaerebus_headinterior.iqm",
             "", "", "head",
             HUD_SPIDERBOT,
             MECHMAX_MIN, MECHMAX_MAX,
             FALSE,
             mechmax_spawn, autocvar_g_vehicle_spiderbot_respawntime,
             mechmax_frame,
             mechmax_enter, mechmax_exit,
             mechmax_die,   mechmax_think,
             FALSE, 
             autocvar_g_vehicle_mechmax_health,
             autocvar_g_vehicle_mechmax_shield, autocolor, autocvar_g_vehicle_spiderbot_minigun_ammo_max * 6, cammo2max))
    {
        remove(self);
        return;
    }
}

void spawnfunc_vehicle_mechbst()
{
	if (self.spawnflags < 64) {
		self.spawnflags = self.spawnflags + 64; //So we shotgun weapons
	}
		
	spawnfunc_vehicle_mechmax();
}
#endif // SVQC
