const vector TURRETLL20_MIN = '-32 -32 0';
const vector TURRETLL20_MAX  = '32 32 70';
const float LL20MOREPITCHDOWN = 10; //Is subtracted, so keep as positive interger
#ifdef SVQC
float autocvar_g_vehicle_turretll20;

float autocvar_g_vehicle_turretll20_respawntime;

float autocvar_g_vehicle_turretll20_speed_stop;
float autocvar_g_vehicle_turretll20_speed_strafe;
float autocvar_g_vehicle_turretll20_speed_walk;
float autocvar_g_vehicle_turretll20_movement_inertia;

float autocvar_g_vehicle_turretll20_tiltlimit;

float autocvar_g_vehicle_turretll20_turret_turnlimit;
float autocvar_g_vehicle_turretll20_turret_turnspeed;

float autocvar_g_vehicle_turretll20_health;
float autocvar_g_vehicle_turretll20_health_regen;
float autocvar_g_vehicle_turretll20_health_regen_pause;

float autocvar_g_vehicle_turretll20_shield;
float autocvar_g_vehicle_turretll20_shield_regen;
float autocvar_g_vehicle_turretll20_shield_regen_pause;

vector autocvar_g_vehicle_turretll20_bouncepain;

void turretll20_exit(float eject);
void turretll20_enter();
void turretll20_spawn(float);

float turretll20_aiframe()
{
    return FALSE;
}

float turretll20_frame()
{
    vector ad, vf;
    entity player, tankll24;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    tankll24 = self.vehicle;
    
    self   = tankll24;

    vehicles_painframe();
    
    	//Fixed Mount, Makesure we don't move around due to pushing of the shield.
	//print("We are on a fixed mount: circ or pintel\n");
	if (tankll24.origin_x != tankll24.pos1_x || tankll24.origin_y != tankll24.pos1_y)
	{
		tankll24.origin_x = tankll24.pos1_x;
		tankll24.origin_y = tankll24.pos1_y;
		setorigin(tankll24, tankll24.origin);
		//print("We were moving, fixed in the x and y, back to spawn origin x y!\n");
	}
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;

    ad = gettaginfo(tankll24.gun3, gettagindex(tankll24.gun3, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    
    vf = ad;
    ad = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    if (tankll24.spawnflags & 16384) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0.1 0.1 0.1', 1);
    } else if (tankll24.spawnflags & 8192) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0 1', 1);
    } else if (tankll24.spawnflags & 2048) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0 0', 1);
    } else if (tankll24.spawnflags & 512) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 1 0', 1);
    } else if (tankll24.spawnflags & 256) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.65 0', 1);
    } else if (tankll24.spawnflags & 128) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.35 0', 1);
    } else if (tankll24.spawnflags & 64) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 1);
    } else {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0 0.5 1', 1);
    }
    //ad = 0.5 * (ad + vf);
    ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll24.angles), AnglesTransform_FromAngles(ad))) - tankll24.gun3.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
   
    //Rotate Turret and stabilizing "gun3" (rotates faster than turret)
    ftmp = autocvar_g_vehicle_turretll20_turret_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    if (tankll24.spawnflags & 2048) {
    	//Avoid gun3 line directly below for "stuck"setting
    } else {
    	tankll24.gun3.angles_y = bound(autocvar_g_vehicle_turretll20_turret_turnlimit * -1, tankll24.gun3.angles_y + ad_y, autocvar_g_vehicle_turretll20_turret_turnlimit);
        tankll24.tur_head.angles_y = tankll24.gun3.angles_y;
    }

    /////////////////////////
    //Stuff for actual mgun
    ad = gettaginfo(tankll24.gun1, gettagindex(tankll24.gun1, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    if (self.spawnflags & 16384) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0 0 0', 0);
    } else if (self.spawnflags & 8192) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0 1', 0);
    }
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll24.angles), AnglesTransform_FromAngles(ad))) - tankll24.gun1.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);

    vf = ad;
    // Pitch head
    if (tankll24.spawnflags & 2048) {
    	ftmp = autocvar_g_vehicle_tankll48_gun_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 512) {
    	ftmp = autocvar_g_vehicle_tankll24_raacannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 256) {
    	ftmp = autocvar_g_vehicle_tankll24_aicannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 128) {
    	ftmp = autocvar_g_vehicle_tankll24_heatcannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 64) {
    	ftmp = autocvar_g_vehicle_tankll24_aacannon_pitchspeed * sys_frametime;  
    } else {
    	ftmp = autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime; 
    }  
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    if (tankll24.spawnflags & 16384) {
	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_aacannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_aacannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 2048) {
	if(player.BUTTON_JUMP) {
	    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	}
    
	if(player.BUTTON_CROUCH ) {
		tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll48_cannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x - (autocvar_g_vehicle_tankll48_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll48_cannon_pitchlimit_up);
	}
    } else if (tankll24.spawnflags & 512) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_raacannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_raacannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 256) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_aicannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_aicannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 128) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 64) {
    	//AAgun, no additional pitchdown
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_aacannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_aacannon_pitchlimit_up);
    } else {
        tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down - LL20MOREPITCHDOWN, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    }
    ad = vf;
    
    //Mgun
    tankll24.gun1.angles_x = tankll24.gun2.angles_x;

    //fixedmakevectors(tankll24.angles);
    makevectors(tankll24.angles + '-2 0 0' * tankll24.angles_x);
    
    //movelib_groundalign4point(autocvar_g_vehicle_tankll24_springlength, autocvar_g_vehicle_tankll24_springup, autocvar_g_vehicle_tankll24_springblend, autocvar_g_vehicle_turretll20_tiltlimit);

    if(tankll24.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6.486500; //soundlength("machines/generator_loop_pitchdown.ogg");
		    if (tankll24.spawnflags & 2048) {
                    	sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                    } else {
		    	sound (self, CH_TRIGGER_SINGLE, "vehicles/spiderbot_idle.wav", VOL_VEHICLEENGINE, ATTN_NORM);
		    }
		}                
                movelib_beak_simple(autocvar_g_vehicle_turretll20_speed_stop);
                //tankll24.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0) //self.spawnflags & 2048
   	 {
	 	if(tankll24.tur_head.angles_y > 180)  tankll24.tur_head.angles_y -= 360;
    		if(tankll24.tur_head.angles_y < -180) tankll24.tur_head.angles_y += 360;
		tankll24.tur_head.angles_y = bound(-184,tankll24.tur_head.angles_y + ((player.movement_y * 0.5* sys_frametime) / -6.66666),184);	
		
		if(tankll24.tur_head.angles_y >= -1 && tankll24.tur_head.angles_y <= -1)
            		tankll24.tur_head.angles_y = 0;	
		
		//Unlike the T27 tank, we do it alittle more complex way so the turret can 
		//be independent somewhat
		float degree_y;
		player.angles_y = player.angles_y + ((player.movement_y * 0.5* sys_frametime) / -6.66666);
		degree_y = ((player.movement_y * 0.5* sys_frametime) / -6.66666);
		player.v_angle_y += degree_y;
		
		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}
		
		if (player.movement_y > 0) {
			self.bomb1.gun1.avelocity_y = 75; //gear
                	self.bomb1.gun2.avelocity_y = 90; //wheel
                	self.bomb2.gun1.avelocity_y = -75; //gear
                	self.bomb2.gun2.avelocity_y = -90; //wheel
		} else {
			self.bomb1.gun1.avelocity_y = -75; //gear
                	self.bomb1.gun2.avelocity_y = -90; //wheel
                	self.bomb2.gun1.avelocity_y = 75; //gear
                	self.bomb2.gun2.avelocity_y = 90; //wheel
		}
	 }
	 
	 //No move
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_turretll20_tiltlimit, self.angles_x, autocvar_g_vehicle_turretll20_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_turretll20_tiltlimit, self.angles_z, autocvar_g_vehicle_turretll20_tiltlimit);

    //if(player.BUTTON_JUMP) {
    //	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down, tankll24.gun2.angles_x + (autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    //}
    
    //if(player.BUTTON_CROUCH ) {
    //	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down, tankll24.gun2.angles_x - (autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    //}
    
    if (tankll24.spawnflags & 512) {
    if(player.BUTTON_HOOK) {
    	if(player.BUTTON_JUMP) {
    		tankll24.gun2.gun1.count = bound(autocvar_g_vehicle_tankll24_raacannon_refire_max, tankll24.gun2.gun1.count - (autocvar_g_vehicle_tankll24_raacannon_refire_changerate * sys_frametime),autocvar_g_vehicle_tankll24_raacannon_refire_min);
		if(tankll24.gun2.gun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(player, sprintf("RoF Raised to %f RPM\n", (60/tankll24.gun2.gun1.count)));
			tankll24.gun2.gun1.pushltime = time + 0.25;
		}
	    }
    
    	if(player.BUTTON_CROUCH ) {
    		tankll24.gun2.gun1.count = bound(autocvar_g_vehicle_tankll24_raacannon_refire_max, tankll24.gun2.gun1.count + (autocvar_g_vehicle_tankll24_raacannon_refire_changerate * sys_frametime),autocvar_g_vehicle_tankll24_raacannon_refire_min);
		if(tankll24.gun2.gun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(player, sprintf("RoF Lowered to %f RPM\n", (60/tankll24.gun2.gun1.count)));
			tankll24.gun2.gun1.pushltime = time + 0.25;
		}

    	}
    }
    //print(ftos(tankll24.gun2.gun1.count),"\n");
    }
    
    player.BUTTON_CROUCH    = 0;

    if (self.spawnflags & 16384) {
    	tankll24_t17mm_fire(tankll24, player, tankll24.gun1);
    } else if (self.spawnflags & 8192) {
    	tankll24_grail(tankll24, player, tankll24.gun1);
    }    

    if((player.BUTTON_ATCK) ||
    ((player.BUTTON_ATCK2) && !(self.spawnflags & 8192) && !(self.spawnflags & 16384)))
    {
        if (tankll24.spawnflags & 16384) {
		mg_t17mm_fire(tankll24, player, tankll24.gun2);
		tankll24.count = 0; //Will have to press R to resume reload
	} else if (tankll24.spawnflags & 8192) {
		mg_grail_fire(tankll24, player, tankll24.gun2);
    	} else if (tankll24.spawnflags & 2048) {
		//////////////Start-TankLL48Style////////////
		tankll24.cnt = time;
		if not(tankll24.gun2.count)
        	if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll48_cannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;
	
	            v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon"));
	            v_forward = normalize(v_forward);
	            v += v_forward * 12;
	  	 // Start Ballistic bullet
		 
	   	 fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll48_cannon_spread, autocvar_g_vehicle_tankll48_cannon_speed, 5, autocvar_g_vehicle_tankll48_cannon_damage, autocvar_g_vehicle_tankll48_cannon_headshotaddeddamage, autocvar_g_vehicle_tankll48_cannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll48_cannon_bulletconstant, autocvar_g_vehicle_tankll48_cannon_coreshotaddeddamage);
	    	 endFireBallisticBullet();
		 
		 
		 sound (tankll24.gun2, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
	
		// End Ballistic bullet
	
	            pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	
	
	            self = tankll24;
	    
		    makevectors(self.angles);
		    v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon"));
        	    v_forward = normalize(v_forward);
		    
		    tankll48_fire_cannon("tag_cannon");
	
	
	            tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll48_cannon_ammo_cost;
	            tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll48_cannon_refire;
	            player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll48_cannon_ammo_max) * 100;
	         
		    tankll24.count = 0; //Will have to press R to resume reload 
		    tankll24.gun2.count = 1; //Can't fire untill stop pressing key
		    
		    if (autocvar_g_casings >= 2) {
		    	entity oldself2;
					
			oldself2 = self;
			self = player;
			//makevectors(self.angles);
			
			SpawnCasing (((random () * 5 + 5) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 + 70) * v_up), 2, 
			vectoangles(v_forward),'0 64 0', 100, 14, self);
			
			self = oldself2;
		    }
	        }
		//////////////End-TankLL48Style////////////
    	} else if (tankll24.spawnflags & 512) {
		tankll24_mg_m134(tankll24, player, tankll24.gun2, tankll24.gun2.gun1);
        } else if (tankll24.spawnflags & 256) {
		//Anti Infantry Cannon
		tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_aicannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;

	            	self = tankll24;
	    
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aicannon("tag_cannon1");
	 	   
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 12, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_aicannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_aicannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         	tankll24.count = 0; //Will have to press R to resume reload
        	}
    	} else if (tankll24.spawnflags & 128) {
		//HEAT Cannon
		tankll24.cnt = time;
		if not(tankll24.bomb1.gun1.count)
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_heatcannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;

	            	self = tankll24;
	    
	 		sound (tankll24, CH_WEAPON_A, "weapons/campingrifle_fire_morebass.ogg", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_heatcannon("tag_cannon1");
	 	   
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 13, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_heatcannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_heatcannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         	tankll24.count = 0; //Will have to press R to resume reload
		tankll24.bomb1.gun1.count = 1; //Can't fire untill stop pressing key (semi auto)
        	}
    	} else if (tankll24.spawnflags & 64) {
		//AA Cannon
		tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_aacannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;
		    
		    if(tankll24.gun2.count == 1) {
		    	tankll24.gun2.count = 2;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon2");
	 	   } else if(tankll24.gun2.count == 2) {
	   		tankll24.gun2.count = 3;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon3"));
	           	 v_forward = normalize(v_forward);
	    		
			entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon4"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon4");
		   } else if(tankll24.gun2.count == 3) {
	   		tankll24.gun2.count = 0;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon1");
		   } else {
		   	tankll24.gun2.count = 1;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon4"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon3"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon3");
		   }
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 111, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_aacannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_aacannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
		tankll24.count = 0; //Will have to press R to resume reload 
        	}
	} else {
		//Regular
        	tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_cannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;
		    
		    if(tankll24.gun2.count == 1) {
	            	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
		    	tankll24.gun2.count = 0;
			v_forward = normalize(v_forward);
	            	v += v_forward * 12;

	            	pointparticles(particleeffectnum("bigplasma_muzzleflash"), v, v_forward, 1);


	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
	    
	 	   	tankll24_fire_cannon("tag_cannon1");
	 	   } else {
	   		v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	    		tankll24.gun2.count = 1;
			v_forward = normalize(v_forward);
            		v += v_forward * 12;

            		pointparticles(particleeffectnum("bigplasma_muzzleflash"), v, v_forward, 1);


            		self = tankll24;
	    
	    		makevectors(self.angles);
	    		v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
            		v_forward = normalize(v_forward);
	    
	    		tankll24_fire_cannon("tag_cannon2");
	   	  }

            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_cannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_cannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         
        	}
	}
    }
    else
    {
      if (tankll24.spawnflags & 2048) {
	//////////////Start-TankLL48Style////////////
        if (tankll24.count == 1) {
        vehicles_regen(tankll24.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll48_cannon_ammo_max,
                                           autocvar_g_vehicle_tankll48_cannon_ammo_regen_pause,
                                           autocvar_g_vehicle_tankll48_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		tankll24.count = 1;
		sound (tankll24, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
    	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 player ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(player, tankll24, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
	}
	
	tankll24.gun2.count = 0; //Can fire
	//////////////END-TankLL48Style////////////
      } else {
    	tankll24.bomb1.gun1.count = 0; //For semi-auto cannons, you stopped pressing attack2 button, so reset this
	
    	float regenll24;
	if (tankll24.spawnflags & 16384) {
		regenll24 = autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen_pause;
	} else if (tankll24.spawnflags & 8192) {
		regenll24 = autocvar_g_vehicle_mg_grail_railgun_ammo_regen_pause;
    	} else if (tankll24.spawnflags & 256) {
		regenll24 = autocvar_g_vehicle_tankll24_aicannon_ammo_regen_pause;
	} else if (tankll24.spawnflags & 128) {
		regenll24 = autocvar_g_vehicle_tankll24_heatcannon_ammo_regen_pause;
	} else if (tankll24.spawnflags & 64) {
		regenll24 = autocvar_g_vehicle_tankll24_aacannon_ammo_regen_pause;
	} else {
		regenll24 = autocvar_g_vehicle_tankll24_cannon_ammo_regen_pause;
	}
	
	if (tankll24.spawnflags & 16384 || tankll24.spawnflags & 512 || tankll24.spawnflags & 256 || tankll24.spawnflags & 128 || tankll24.spawnflags & 64) {
		if (tankll24.count == 1) {
        	vehicles_regen(tankll24.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll24_cannon_ammo_max,
                	                           regenll24,
                	                           autocvar_g_vehicle_tankll24_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    		} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
				tankll24.count = 1;
				sound (tankll24, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
		
		if (player.impulse == 20)
		if (player.BUTTON_HOOK) {
    			//Reload from own stores //4 ammo, 4 player ammo = 50 vehic ammo, 4/0.08 = 50 (the normal one shot ammo cost for this weapon)
			//For the RAA gun (512) it's 125 ammo at 5 player ammo per one vehic ammo = 25 vehic ammo
			//For t17mm x4 gun (16384) its, 75 ammo, 3 player ammo = 1 vehic ammo,
			if (tankll24.spawnflags & 16384)
				vehicles_replenishAmmo(player, tankll24, ammo_nails, vehicle_ammo2_current, vehicle_ammo2_max, 75, 3);
			else if (tankll24.spawnflags & 512)
				vehicles_replenishAmmo(player, tankll24, ammo_nails, vehicle_ammo2_current, vehicle_ammo2_max, 125, 5);
			else
				vehicles_replenishAmmo(player, tankll24, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 0.08);
    		}
		
		//if (tankll24.spawnflags & 16384) {
		//	//Overheating and cooldown stuff://
		//	if (tankll24.gun1.cnt < autocvar_g_vehicle_mg_t17mm_machinegun_heatmin) {
		//		tankll24.gun1.cnt = autocvar_g_vehicle_mg_t17mm_machinegun_heatmin;
		//	} else {
		//		tankll24.gun1.cnt = tankll24.gun1.cnt - (autocvar_g_vehicle_mg_t17mm_machinegun_cooldownrate * sys_frametime);
		//	}
		//}
	} else {
	vehicles_regen(tankll24.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll24_cannon_ammo_max,
                                           regenll24,
                                           autocvar_g_vehicle_tankll24_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);	
	}
      }
    }  
    
    //tankll24_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(tankll24.dmg_time, vehicle_shield, autocvar_g_vehicle_turretll20_shield, autocvar_g_vehicle_turretll20_shield_regen_pause, autocvar_g_vehicle_turretll20_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(tankll24.dmg_time, vehicle_health, autocvar_g_vehicle_turretll20_health, autocvar_g_vehicle_turretll20_health_regen_pause, autocvar_g_vehicle_turretll20_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = tankll24.tur_head.frame;

    if(tankll24.gun2.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((tankll24.gun2.cnt - time) / tankll24.attack_finished_single) * 100;

    setorigin(player, tankll24.origin + '0 0 1' * TURRETLL20_MAX_z);
    player.velocity = tankll24.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, tankll24);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, tankll24);


    //Gun3 is out invisible angle stabilizer/reducer
    //tur_head gets its value from it above, so we act on it here
    //print(sprintf("m1 = %f\n", tankll24.gun3.angles_y));
    if(tankll24.gun3.angles_y > 180) {
    	//print("here 1\n");
    	tankll24.gun3.angles_y = tankll24.gun3.angles_y - 360;
	//print(sprintf("m2 = %f\n", tankll24.gun3.angles_y));
    } else if(tankll24.gun3.angles_y < -180) {
    	//print("here 2\n");
    	tankll24.gun3.angles_y = tankll24.gun3.angles_y + 360;
	//print(sprintf("m2 = %f\n", tankll24.gun3.angles_y));
    }

    player.vehicle_ammo1_current = tankll24.vehicle_ammo1_current;
    player.vehicle_ammo1_max = tankll24.vehicle_ammo1_max;
    player.vehicle_ammo2_current = tankll24.vehicle_ammo2_current;
    player.vehicle_ammo2_max = tankll24.vehicle_ammo2_max;

    self = player;
    return 1;    
}
void turretll20_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_turretll20_speed_stop);

    self.nextthink = time;
}

void turretll20_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK; //So we can spin around using the strafe keys
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_turretll20_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_turretll20_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void turretll20_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = turretll20_think;
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_NONE;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_turretll20_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 64 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void turretll20_impact()
{
    if(autocvar_g_vehicle_turretll20_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_turretll20_bouncepain_x, autocvar_g_vehicle_turretll20_bouncepain_y, autocvar_g_vehicle_turretll20_bouncepain_z);    
}

void turretll20_headfade()
{
	self.think = turretll20_headfade;
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

void turretll20_blowup()
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

    setmodel(b,  "models/vehicles/turretll20.iqm");
    if (self.spawnflags & 16384) {
    	g1.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
    	g1.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
    	g1.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
    	setmodel(g1, "models/mountedguns/t17mmgun.iqm");
	InitializeEntity(g1, LODmodel_attach, INITPRIO_FINDTARGET);
    } else if (self.spawnflags & 8192) {
    	g1.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
    	setmodel(g1, "models/mountedguns/grailgun.iqm");
	InitializeEntity(g1, LODmodel_attach, INITPRIO_FINDTARGET);
    } else if (self.spawnflags & 2048) {
    	setmodel(g1, "models/vehicles/tankll48_cannon.iqm");
    } else if (self.spawnflags & 512) {
    	g1.scale = 4;
    	setmodel(g1, "models/mountedguns/m134gun_barrels.iqm");
	self.gun2.gun1.alpha = -1;
    } else if (self.spawnflags & 256) {
    	setmodel(g1, "models/vehicles/tankll24_aicannon.iqm");
    } else if (self.spawnflags & 128) {
    	setmodel(g1, "models/vehicles/tankll24_heatcannon.iqm");
    } else if (self.spawnflags & 64) {
    	setmodel(g1, "models/vehicles/tankll24_aacannon.iqm");
    } else {
    	setmodel(g1, "models/vehicles/tankll24_cannon.iqm");
    }
    setmodel(h,  "models/vehicles/turretll20_turret_medium.iqm");
    
    setmodel(g2, "models/vehicles/tankt27_gear.iqm");

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_turretll20_respawntime, 10);
    h.fade_time     = time;
    h.think         = turretll20_headfade;
    h.nextthink     = time;

    setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
    g1.movetype     = MOVETYPE_TOSS;
    g1.solid        = SOLID_CORPSE;
    g1.velocity     = v_forward * 700 + (randomvec() * 32);
    g1.avelocity    = randomvec() * 180;

    setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
    g2.movetype     = MOVETYPE_TOSS;
    g2.solid        = SOLID_CORPSE;
    g2.velocity     = v_forward * 700 + (randomvec() * 32);
    g2.avelocity    = randomvec() * 180;

    h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_turretll20_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_turretll20_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_turretll20_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_turretll20_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void turretll20_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = turretll20_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;

}

void turretll20_spawn(float _f)
{
    if(!self.gun1)
    {
    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
	//Turret Rotation stabilizer
	self.gun3 = spawn(); //Will be an angle stabilizer for the rotating turret
	self.gun3.alpha = -1;
	setmodel(self.gun3, "models/vehicles/anglestabilizer.iqm");
	setattachment(self.gun3, self.tur_head, "tag_cannon_pivot");
	
	
        self.gun1               = spawn();
        self.gun2               = spawn();
	if (self.spawnflags & 16384) {
		self.gun1.ammount = 2.4; //Reduce heatup speed for this gun. Specific to t17mm code
	 	setmodel(self.gun1, "models/mountedguns/t17mmgun.iqm");
		//LOD stuff.
		self.gun1.owner = self;
		self.gun1.lodowner = 1; //Use owner origin for computing LOD
		self.gun1.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
		self.gun1.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
		self.gun1.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
		InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		setattachment(self.gun1, self.tur_head, "tag_cannon_pivot_bottom");
	} else if (self.spawnflags & 8192) {
        	setmodel(self.gun1, "models/mountedguns/grailgun.iqm");
		//LOD stuff.
		self.gun1.owner = self;
		self.gun1.lodowner = 1; //Use owner origin for computing LOD
		self.gun1.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
		InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
	} else {
		setmodel(self.gun1, "null");
		//LOD stuff.
		self.gun1.owner = self;
		//LOD stuff end
		setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
	}
	
	if (self.spawnflags & 16384) {
		//LOD stuff.
		self.gun2.owner = self;
		self.gun2.lodowner = 1; //Use owner origin for computing LOD
		self.gun2.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
    		self.gun2.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
    		self.gun2.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
		setmodel(self.gun2, "models/mountedguns/t17mmgun.iqm");
		InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
	} else if (self.spawnflags & 8192) {
		self.gun2.owner = self;
		self.gun2.lodowner = 1; //Use owner origin for computing LOD
		self.gun2.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
		setmodel(self.gun2, "models/mountedguns/grailgun.iqm");
		InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
	} else if (self.spawnflags & 2048) {
		setmodel(self.gun2, "models/vehicles/tankll48_cannon.iqm");
	} else if (self.spawnflags & 512) {
		self.gun2.scale = 4;
		self.gun2.owner = self;
		self.gun2.lodmodel1 = "models/vehicles/m134simple_lod1.iqm";
        	setmodel(self.gun2, "models/vehicles/m134simple.iqm");
		InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
		
		self.gun2.gun1 = spawn();
		////Do not need to scale, takes on scale of parent //self.gun2.gun1.scale = 4;//
		setmodel(self.gun2.gun1,"models/mountedguns/m134gun_barrels.iqm");
		setattachment(self.gun2.gun1, self.gun2, "tag_axis");
		
		self.gun2.gun1.count = autocvar_g_vehicle_tankll24_raacannon_refire_max;
	} else if (self.spawnflags & 256) {
        	setmodel(self.gun2, "models/vehicles/tankll24_aicannon.iqm");
	} else if (self.spawnflags & 128) {
        	setmodel(self.gun2, "models/vehicles/tankll24_heatcannon.iqm");
	} else if (self.spawnflags & 64) {
        	setmodel(self.gun2, "models/vehicles/tankll24_aacannon.iqm");
	} else {
		setmodel(self.gun2, "models/vehicles/tankll24_cannon.iqm");
	}
	
	if (self.spawnflags & 8192) {
		setattachment(self.gun2, self.tur_head, "tag_gunpivot");
	} else {
		setattachment(self.gun2, self.tur_head, "tag_cannon_pivot");
	}
        self.gravity            = 2;
        self.mass               = 5000;
	
	spinner = spawn();
        spinner.owner = self;
	if (self.spawnflags & 2048) {
        	setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
	}
        setattachment(spinner, self, "tag_gear_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
	if (self.spawnflags & 2048) {
        	setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
	}
        setattachment(spinner, self, "tag_wheel_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
	if (self.spawnflags & 2048) {
        	setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
	}
        setattachment(spinner, self, "tag_gear_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
	if (self.spawnflags & 2048) {
        	setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
	}
        setattachment(spinner, self, "tag_wheel_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun2 = spinner;
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun1, "tag_gcamera");
	if (self.spawnflags & 128 || self.spawnflags & 256 || self.spawnflags & 512 || self.spawnflags & 2048) {
		setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
		//Set forward
		setorigin(self.vehicle_viewport, '6 0 0');
	} else if (self.spawnflags & 16384) {
		setattachment(self.vehicle_viewport, self.tur_head, "tag_cannon_pivot_mid_up");
	} else if (self.spawnflags & 8192) {
		setattachment(self.vehicle_viewport, self.tur_head, "tag_cannon_pivot");
	} else {
		setattachment(self.vehicle_viewport, self.gun2, "tag_camera");
	}
	
	self.gun1.colormap = self.colormap;
    }
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;    
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = turretll20_think;
    self.touch              = tankt27_vehicles_touch2;
    self.subordinate        = self; //For testing max_z in determining if should crush a player or monster
    self.subordinatespeed   = autocvar_g_vehicle_turretll20_speed_walk;
    self.subordinateinertia = autocvar_g_vehicle_turretll20_movement_inertia;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_turretll20_health;
    self.vehicle_shield     = autocvar_g_vehicle_turretll20_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    if (self.spawnflags & 512) {
	self.gun2.gun1.alpha = 1;
    }
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun2.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    //setorigin(self, self.pos1 + '0 0 128');
    setorigin(self, self.pos1);
    self.movetype           = MOVETYPE_NONE;
    self.angles = self.pos2;
    self.vehicle_impact = turretll20_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
}

void spawnfunc_vehicle_turretll20()
{
    if(!autocvar_g_vehicle_turretll20)
    {
        remove(self);
        return;
    }        

    self.vehicle_flags |= VHF_DMGSHAKE;
    //self.vehicle_flags |= VHF_DMGROLL;
    //self.vehicle_flags |= VHF_DMGHEADROLL;
    
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/vehicles/turretll20.iqm");
        
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    
    precache_model ( "models/vehicles/anglestabilizer.iqm");
    precache_model ( "models/uziflash.md3");
    
    //Anti-infantry gun (seconday weapon)
    float gnammomax;
    
    //Main Turret
    float caammomax;
    string turretmodel;
    if (self.spawnflags & 16384) {
    	precache_model ( "models/mountedguns/t17mmgun.iqm");
    	precache_model ( "models/mountedguns/t17mmgun_lod1.iqm");
	precache_model ( "models/mountedguns/t17mmgun_lod2.iqm");
	precache_model ( "models/mountedguns/t17mmgun_lod3.iqm");
	precache_model ( "models/uziflash.md3");
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	gnammomax = autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max * 7;
    	caammomax =  autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max * 7;
    } else if (self.spawnflags & 8192) {
    	precache_model ( "models/mountedguns/grailgun.iqm");
    	precache_model ( "models/mountedguns/grailgun_lod1.iqm");
	gnammomax = 0;
    	caammomax = 0;
    } else if (self.spawnflags & 2048) {
    	precache_model ( "models/vehicles/tankll48_cannon.iqm");
    	precache_model ( "models/uziflash.md3");
	precache_model ( "models/sphere/sphexp.md3");
    	precache_sound ( "weapons/campingrifle_fire.wav" );
    	precache_sound ( "weapons/grenade_fire.wav" );
	precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
	caammomax = autocvar_g_vehicle_tankll48_cannon_ammo_max * 3;
    } else if (self.spawnflags & 512) {
	precache_model ( "models/mountedguns/m134gun_barrels.iqm");
	precache_model ( "models/vehicles/m134simple.iqm");
	precache_model ( "models/vehicles/m134simple_lod1.iqm");
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_raacannon_ammo_max * 3;
    } else if (self.spawnflags & 256) {
	precache_model ( "models/vehicles/tankll24_aicannon.iqm");
	//precache_model ( "models/sphere/sphexp.md3");
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 12;
    } else if (self.spawnflags & 128) {
	precache_model ( "models/vehicles/tankll24_heatcannon.iqm");
	precache_model ( "models/sphere/sphexp.md3");
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/campingrifle_fire_morebass.ogg" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 3;
    } else if (self.spawnflags & 64) {
	precache_model ( "models/vehicles/tankll24_aacannon.iqm");
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 3;
    } else {
	precache_model ( "models/vehicles/tankll24_cannon.iqm");
	caammomax = 0;
    }
    precache_model ( "models/vehicles/turretll20_turret_medium.iqm");
    turretmodel = "models/vehicles/turretll20_turret_medium.iqm";
    
    precache_sound ( "weapons/electro_impact_combo.wav" );
    precache_sound ( "weapons/electro_fire.wav" );
    precache_sound ( "weapons/crylink_fire.wav" );
    precache_sound ( "weapons/nexfire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    precache_sound ( "vehicles/turretll20_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/tankll24_jump.wav");
    precache_sound ( "vehicles/tankll24_strafe.wav");
    precache_sound ( "vehicles/spiderbot_idle.wav");
    precache_sound ( "vehicles/tankll24_land.wav");
    precache_sound ( "object/impact_metal_3.ogg");
    precache_sound ( "object/impact_metal_4.ogg");

    if(autocvar_g_vehicle_turretll20_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_turretll20_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_turretll20_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "LL20",
             "models/vehicles/turretll20.iqm",
             turretmodel,
             "null",
             "tag_turret", "tag_camera", "",
             HUD_TANK,
             TURRETLL20_MIN, TURRETLL20_MAX,
             FALSE,
             turretll20_spawn, autocvar_g_vehicle_turretll20_respawntime,
             turretll20_frame,
             turretll20_enter, turretll20_exit,
             turretll20_die,   turretll20_think,
             FALSE, 
             autocvar_g_vehicle_turretll20_health,
             autocvar_g_vehicle_turretll20_shield, autocolor, gnammomax, caammomax))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}

void spawnfunc_vehicle_turretll20_aa()
{
	if not(self.spawnflags & 64) {
		self.spawnflags |= 64; //So we spawn AA
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_heat()
{
	if not(self.spawnflags & 128) {
		self.spawnflags |= 128; //So we spawn HEAT
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_ai()
{
	if not(self.spawnflags & 256) {
		self.spawnflags |= 256; //So we spawn AntiInfantry
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_raa()
{
	if not(self.spawnflags & 512) {
		self.spawnflags |= 512; //So we spawn RAA
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_cannon()
{
	if not(self.spawnflags & 2048) {
		self.spawnflags |= 2048; //So we spawn LL48 style cannon
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_grail()
{
	if not(self.spawnflags & 8192) {
		self.spawnflags |= 8192; //So we spawn LL48 style cannon
	}
		
	spawnfunc_vehicle_turretll20();
}

void spawnfunc_vehicle_turretll20_t17mm()
{
	if not(self.spawnflags & 16384) {
		self.spawnflags |= 16384; //So we spawn LL48 style cannon
	}
		
	spawnfunc_vehicle_turretll20();
}
#endif // SVQC
