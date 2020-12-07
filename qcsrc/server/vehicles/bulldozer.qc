const vector BULLDOZER_MIN = '-100 -100 1';
const vector BULLDOZER_MAX  = '100 100 132';

const vector BULLDOZER_MIN_HBF = '-80 -80 1';
const vector BULLDOZER_MAX_HBF = '80 80 155';

const vector BULLDOZER_MIN_HBB = '-100 -100 1';
const vector BULLDOZER_MAX_HBB = '100 100 130';

const vector BULLDOZER_MIN_PHB = '-16 -16 0';
const vector BULLDOZER_MAX_PHB = '16 16 130';

const vector BULLDOZER_MIN_PHBD = '-32 -32 0';
const vector BULLDOZER_MAX_PHBD = '32 32 8';

#ifdef SVQC
float autocvar_g_vehicle_bulldozer;

float autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage;

float autocvar_g_vehicle_bulldozer_respawntime;
float autocvar_g_vehicle_bulldozer_crushwoodbldng_dmg;

float autocvar_g_vehicle_bulldozer_speed_stop;
float autocvar_g_vehicle_bulldozer_speed_strafe;
float autocvar_g_vehicle_bulldozer_speed_walk;
float autocvar_g_vehicle_bulldozer_movement_inertia;

float autocvar_g_vehicle_bulldozer_springlength;
float autocvar_g_vehicle_bulldozer_springup;
float autocvar_g_vehicle_bulldozer_springblend;
float autocvar_g_vehicle_bulldozer_tiltlimit;

float autocvar_g_vehicle_bulldozer_gun_pitchlimit_down;
float autocvar_g_vehicle_bulldozer_gun_pitchlimit_up;
float autocvar_g_vehicle_bulldozer_gun_pitchspeed;
float autocvar_g_vehicle_bulldozer_gun_turnlimit;
float autocvar_g_vehicle_bulldozer_gun_turnspeed;

//float autocvar_g_vehicle_bulldozer_energy;
//float autocvar_g_vehicle_bulldozer_energy_regen;
//float autocvar_g_vehicle_bulldozer_energy_regen_pause;

float autocvar_g_vehicle_bulldozer_health;
float autocvar_g_vehicle_bulldozer_health_regen;
float autocvar_g_vehicle_bulldozer_health_regen_pause;

float autocvar_g_vehicle_bulldozer_shield;
float autocvar_g_vehicle_bulldozer_shield_regen;
float autocvar_g_vehicle_bulldozer_shield_regen_pause;

vector autocvar_g_vehicle_bulldozer_bouncepain;

void bulldozer_exit(float eject);
void bulldozer_enter();
void bulldozer_spawn(float);

void bulldozer_vehicles_touch()
{
	if (other.isabdbld && other != world) {
		if (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 1)
		{
			if (other.abdbld_damagescale_bulldozer > 0) {
				Damage(other, world, world, 
				(autocvar_g_vehicle_bulldozer_crushwoodbldng_dmg * frametime), DEATH_BATTERINGRAM, 
				'0 0 0', 
				'0 0 0');
	  		}
		}
	
	} else if (other.classname == "building" && other.rubble_is) {
		//Rubble
			Damage(other, world, world, 
			(autocvar_g_vehicle_bulldozer_crushwoodbldng_dmg * frametime), DEATH_BATTERINGRAM, 
			'0 0 0', 
			'0 0 0');
			//print("Clearing rubble\n");
	} else if (other.classname == "building" && other.multitool_hitbox != world) {
		//We do barbed wire, wooden stakes, wire fence in tankt27_vehicles_touch;
		//Yes wooden stakes get hit 2x per time: here and there
		if (multitool_iswooden(other.multitool_hitbox.count))
		{
			Damage(other.multitool_hitbox, world, world, 
			(autocvar_g_vehicle_bulldozer_crushwoodbldng_dmg * frametime), DEATH_BATTERINGRAM, 
			'0 0 0', 
			'0 0 0');
			//print("Damaging wooden building\n");
		}
	}
	tankt27_vehicles_touch();
}

void bulldozer_vehicles_touch_pushing_hitbox()
{
    //This is for the verticle parts of the bulldozer front end loader
    //Ever active
      if(other != world) {
        if(vehicles_crushable(other) || vehicles_lightvehicle(other) || vehicles_mediumvehicle(other))
        {
	    	//Push player, vehics, etc
		sound (other, CH_TRIGGER, "misc/mouseclick.wav", VOL_BASE, ATTN_NORM);
		
		other.velocity = other.velocity * -1;
		
		makevectors(self.owner.angles_x * '-1 0 0' + self.owner.angles_y * '0 1 0' + self.owner.angles_z * '0 0 1'); //Inverted pitch on models
		entity oldself; oldself = self; self = other;
		
		//print(ftos(oldself.owner.subordinatespeed)," . ", ftos(oldself.owner.subordinateinertia),"\n");
		
		movelib_move_simple(normalize(v_forward * 1),oldself.owner.subordinatespeed,oldself.owner.subordinateinertia);
		movelib_move_simple(v_forward , 50, oldself.owner.subordinateinertia);
	    	
		self = oldself;
	} else {
		entity myoldself;
   		myoldself = self;
    		self = self.owner;
		tankt27_vehicles_touch2(); //This way self.subordinate is tested for max_z rather than self
		self = myoldself;
	}
     }
}

void bulldozer_vehicles_touch_pushing_nobounce_hitbox()
{
    //This is for the ones you stand on in the front end loader.    
		
    //Ever active
      if(other != world) {
        if(vehicles_crushable(other) || vehicles_lightvehicle(other) || vehicles_mediumvehicle(other))
        {
	    	//Do nothing
	} else {
		//Forward
		entity myoldself;
   		myoldself = self;
    		self = self.owner;
		tankt27_vehicles_touch2(); //This way self.subordinate is tested for max_z rather than self
		self = myoldself;
	}
     }
}

void bulldozer_vehicles_blocked_pushing_hitbox()
{
	if (other == world
	|| other == self.owner)
	{
		print("blocked worldorself\n");
		//Nothing
	} else if (other == self.owner.hitboxft
	|| other == self.owner.hitboxbk
	|| other == self.owner.rotorboxft
	|| other == self.owner.rotorboxmf
	|| other == self.owner.rotorboxmb
	|| other == self.owner.rotorboxbk
	|| other == self.owner.rotorboxftr
	|| other == self.owner.rotorboxmfr
	|| other == self.owner.rotorboxmbr
	|| other == self.owner.rotorboxbkr
	|| other == self.owner.rotorboxftd1
	|| other == self.owner.rotorboxmfd1
	|| other == self.owner.rotorboxmbd1
	|| other == self.owner.rotorboxbkd1
	|| other == self.owner.rotorboxftd2
	|| other == self.owner.rotorboxmfd2
	|| other == self.owner.rotorboxmbd2
	|| other == self.owner.rotorboxbkd2
	|| other == self.owner.rotorboxft_t
	|| other == self.owner.rotorboxmf_t
	|| other == self.owner.rotorboxmid_t
	|| other == self.owner.rotorboxmb_t
	|| other == self.owner.rotorboxbk_t) {
		print("blocked otherpusher\n");
		//Do nothing
	} else {
		print("blocked something else\n");
		tankt27_vehicles_touch2(); //This way self.subordinate is tested for max_z rather than self
	}
}

void bulldozer_rotor_die(entity hitbox)
{
    hitbox.event_damage       = func_null;
    hitbox.takedamage         = DAMAGE_NO;
    hitbox.touch              = func_null;
    hitbox.think              = helicopter_rotor_donothing;
    hitbox.deadflag           = DEAD_DEAD;
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid      = SOLID_NOT;
    if(self.subordinate5 && self.subordinate5 != world) {
    	self.think              = helicopter_rotor_donothing;
	remove(self.subordinate5);
    }
}


void bulldozer_rotor_think_noz()
{
	//if(self.pushltime < time) {
	//	self.pushltime = time+1;
	//	
	//}
	
	//For this version, No spin for z:

	makevectors(self.subordinate4.owner.angles_x * '-1 0 0' + self.subordinate4.owner.angles_y * '0 1 0' + self.subordinate4.owner.angles_z * '0 0 0');
	setorigin(self.subordinate4, (self.subordinate4.owner.origin + (v_forward * self.subordinate4.rotoroffset_x) + (v_right * self.subordinate4.rotoroffset_y) + (v_up * self.subordinate4.rotoroffset_z))); //Forward X qunits, up_s
	self.nextthink = time;
	
	//print(vtos(self.subordinate4.owner.origin), "-ownrorigin   ", vtos(self.subordinate4.origin), "-pusherorigin \n");
}

void bulldozer_vehicles_damage_hitboxbk(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	damage = damage * 0.04; // (1/25), as so many other hbxs here (21 total), explosions will hit them all, so that plus a little dmg reduction for the front end loader/pusher 
	tankt27_vehicles_damage_hitboxbk(inflictor, attacker, damage, deathtype, hitloc, force);
}

void bulldozer_spawn_pushing_hitbox(float position, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float right_s, float up_s, float vehic_health)
{
    hitbox.owner              = vehic;
    if (position == 1 || position == 10 || position == 100) {
    	//Back armor
	if (position == 100) {
		hitbox.touch              = bulldozer_vehicles_touch_pushing_nobounce_hitbox;
	} else {
    		hitbox.touch              = bulldozer_vehicles_touch_pushing_hitbox;
	}
    	hitbox.event_damage       = bulldozer_vehicles_damage_hitboxbk;
    } else {
    	//Front armor
    	if (position == 200) {
		hitbox.touch              = bulldozer_vehicles_touch_pushing_nobounce_hitbox;
	} else {
    		hitbox.touch              = bulldozer_vehicles_touch_pushing_hitbox;
	}
    	hitbox.event_damage       = tankt27_vehicles_damage_hitboxft;
	hitbox.vehicle_tankresists = 1; //Front armor gets extra protections
    }
    hitbox.blocked = tankt27_vehicles_touch2;
    hitbox.buff_wont_ignite = vehic.buff_wont_ignite;
    hitbox.bot_attack         = TRUE;
    hitbox.iscreature         = TRUE;
    hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    hitbox.damagedbycontents	= TRUE;
    hitbox.movetype           = MOVETYPE_PUSH; //MOVETYPE_WALK;
    if (position == 10 || position == 20 || position == 200) {
    	hitbox.solid              = SOLID_TRIGGER;
    } else {
   	 hitbox.solid              = SOLID_SLIDEBOX;
    }
    hitbox.takedamage         = DAMAGE_AIM;
    hitbox.deadflag           = DEAD_NO;
    hitbox.bot_attack         = TRUE;
    hitbox.flags              = FL_NOTARGET;
    hitbox.think              = func_null;
    
    local entity watcherent;
    watcherent = spawn();
    watcherent.subordinate4 = hitbox;
    watcherent.think              = bulldozer_rotor_think_noz;
    watcherent.nextthink = time;
    hitbox.subordinate5 = watcherent;

    hitbox.vehicle_health = vehic_health;
    setsize(hitbox, min_s, max_s);
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    setorigin(hitbox, (vehic.origin + (v_forward * fwd_s) + (v_right * right_s) + (v_up * up_s))); //Forward X qunits, up_s
    hitbox.rotoroffset_x = fwd_s;
    hitbox.rotoroffset_y = right_s;
    hitbox.rotoroffset_z = up_s;
    //follow_sameorigin(hitbox, vehic); //Follow vehic
    
    hitbox.damageforcescale = 0.03;
    hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}

float bulldozer_aiframe()
{
    return FALSE;
}

float bulldozer_frame()
{
    vector ad, vf;
    entity player, bulldozer;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    bulldozer = self.vehicle;
    self   = bulldozer;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    


    //ad = gettaginfo(bulldozer.gun1, gettagindex(bulldozer.gun1, "tag_mgun"));
    //traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, bulldozer);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    //vf = ad;
    //ad = gettaginfo(bulldozer.gun2, gettagindex(bulldozer.gun2, "tag_cannon"));
    //traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, bulldozer);
    //UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 1);
    ////ad = 0.5 * (ad + vf);
    //ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(bulldozer.angles), AnglesTransform_FromAngles(ad))) - bulldozer.gun1.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_bulldozer_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    bulldozer.gun1.angles_y = bound(autocvar_g_vehicle_bulldozer_gun_turnlimit * -1, bulldozer.gun1.angles_y + ad_y, autocvar_g_vehicle_bulldozer_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_bulldozer_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    bulldozer.gun1.angles_x = bound(autocvar_g_vehicle_bulldozer_gun_pitchlimit_down, bulldozer.gun1.angles_x + ad_x, autocvar_g_vehicle_bulldozer_gun_pitchlimit_up);


    //fixedmakevectors(bulldozer.angles);
    makevectors(bulldozer.angles + '-2 0 0' * bulldozer.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_bulldozer_springlength, autocvar_g_vehicle_bulldozer_springup, autocvar_g_vehicle_bulldozer_springblend, autocvar_g_vehicle_bulldozer_tiltlimit);

    if(bulldozer.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6.486500; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("bulldozer_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_bulldozer_speed_stop);
                //bulldozer.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0)
   	 {
	 	if(bulldozer.angles_y > 180)  bulldozer.angles_y -= 360;
    		if(bulldozer.angles_y < -180) bulldozer.angles_y += 360;
		bulldozer.angles_y = bound(-184,bulldozer.angles_y + ((player.movement_y * sys_frametime) / -6.66666),184);	
		
		if(bulldozer.angles_y >= -1 && bulldozer.angles_y <= -1)
            		bulldozer.angles_y = 0;	

		////float degree_y;
		////player.angles_y = player.angles_y + ((player.movement_y * sys_frametime) / -6.66666);
		////degree_y = ((player.movement_y * sys_frametime) / -6.66666);
		////player.v_angle_y += degree_y;
		
		player.v_angle_y = bulldozer.angles_y; //kiss

		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}
		
		////////player.angles_y = player.angles_y + (player.movement_y / -200);
		////////player.fixangle = TRUE;
		
		//////msg_entity = player;
  		//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		//////WriteAngle( MSG_ONE, bulldozer.angles_x); 
  		//////WriteAngle( MSG_ONE, bulldozer.angles_y);
  		//////WriteAngle( MSG_ONE, bulldozer.angles_z);
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
	 
	 if(player.movement_x != 0)
         {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        bulldozer.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        bulldozer.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(bulldozer.angles);
    			makevectors(bulldozer.angles + '-2 0 0' * bulldozer.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_tank_waterspeed_simple(player, autocvar_g_vehicle_bulldozer_speed_walk),autocvar_g_vehicle_bulldozer_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 6.486500; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("bulldozer_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_bulldozer_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_bulldozer_tiltlimit, self.angles_x, autocvar_g_vehicle_bulldozer_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_bulldozer_tiltlimit, self.angles_z, autocvar_g_vehicle_bulldozer_tiltlimit);

    player.BUTTON_CROUCH    = 0;

    //bulldozer_maxim_fire(bulldozer, player, bulldozer.gun1);

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(bulldozer.dmg_time, vehicle_shield, autocvar_g_vehicle_bulldozer_shield, autocvar_g_vehicle_bulldozer_shield_regen_pause, autocvar_g_vehicle_bulldozer_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(bulldozer.dmg_time, vehicle_health, autocvar_g_vehicle_bulldozer_health, autocvar_g_vehicle_bulldozer_health_regen_pause, autocvar_g_vehicle_bulldozer_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = bulldozer.tur_head.frame;

    if(bulldozer.gun2.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((bulldozer.gun2.cnt - time) / bulldozer.attack_finished_single) * 100;

    setorigin(player, bulldozer.origin + '0 0 1' * BULLDOZER_MAX_z);
    player.velocity = bulldozer.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, bulldozer);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, bulldozer);

    //VEHICLE_UPDATE_PLAYER2(player, ammo1_current, bulldozer);
    //VEHICLE_UPDATE_PLAYER2(player, ammo1_max, bulldozer);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_current, bulldozer);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_max, bulldozer);
    player.vehicle_ammo1_current = bulldozer.vehicle_ammo1_current;
    player.vehicle_ammo1_max = bulldozer.vehicle_ammo1_max;
    player.vehicle_ammo2_current = bulldozer.vehicle_ammo2_current;
    player.vehicle_ammo2_max = bulldozer.vehicle_ammo2_max;
    
    self = player;
    return 1;    
}
void bulldozer_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_bulldozer_speed_stop);

    self.nextthink = time;
}

void bulldozer_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_bulldozer_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_bulldozer_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void bulldozer_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = bulldozer_think;
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + (v_forward * -142) + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_bulldozer_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + (v_forward * -168) + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + (v_forward * -256) + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void bulldozer_impact()
{
    if(autocvar_g_vehicle_bulldozer_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_bulldozer_bouncepain_x, autocvar_g_vehicle_bulldozer_bouncepain_y, autocvar_g_vehicle_bulldozer_bouncepain_z);    
}

void bulldozer_headfade()
{
	self.think = bulldozer_headfade;
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

void bulldozer_blowup()
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

    b.loddistance1 = 512;
    b.lodmodel1 = "models/vehicles/bulldozer_lod1.iqm";
    b.lodmodel2 = "models/vehicles/bulldozer_lod2.iqm";
    //b.lodmodel3 = "models/vehicles/bulldozer_lod3.iqm";
    setmodel(b,  "models/vehicles/bulldozer.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    setmodel(h,  "models/vehicles/tankt27_wheel.iqm");
    setmodel(g1, "models/vehicles/tankt27_gear.iqm");
    InitializeEntity(g1, LODmodel_attach, INITPRIO_FINDTARGET);
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_bulldozer_respawntime, 10);
    h.fade_time     = time;
    h.think         = bulldozer_headfade;
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

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_bulldozer_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_bulldozer_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_bulldozer_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_bulldozer_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void bulldozer_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = bulldozer_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
    
    tankt27_hitbox_die(self.hitboxft);
    tankt27_hitbox_die(self.hitboxbk);
    
    	bulldozer_rotor_die(self.rotorboxft); //Using this, sets .think to something other than null, but not much :)
    	bulldozer_rotor_die(self.rotorboxmf); //Middle front
	bulldozer_rotor_die(self.rotorboxmb); //Mid back
    	bulldozer_rotor_die(self.rotorboxbk);
	
	bulldozer_rotor_die(self.rotorboxftr); 
    	bulldozer_rotor_die(self.rotorboxmfr); //Middle front
	bulldozer_rotor_die(self.rotorboxmbr); //Mid back
    	bulldozer_rotor_die(self.rotorboxbkr);
	
	bulldozer_rotor_die(self.rotorboxftd1); 
    	bulldozer_rotor_die(self.rotorboxmfd1); //Middle front
	bulldozer_rotor_die(self.rotorboxmbd1); //Mid back
    	bulldozer_rotor_die(self.rotorboxbkd1);
	
	bulldozer_rotor_die(self.rotorboxftd2); 
    	bulldozer_rotor_die(self.rotorboxmfd2); //Middle front
	bulldozer_rotor_die(self.rotorboxmbd2); //Mid back
    	bulldozer_rotor_die(self.rotorboxbkd2);
	
	bulldozer_rotor_die(self.rotorboxft_t);
	bulldozer_rotor_die(self.rotorboxmf_t);
	bulldozer_rotor_die(self.rotorboxmid_t);
	bulldozer_rotor_die(self.rotorboxmb_t);
	bulldozer_rotor_die(self.rotorboxbk_t);
}

void bulldozer_spawn(float _f)
{
    self.buff_wont_ignite = 1;
    self.vehicle_tankresists = 1;
    self.vehicle_pounddownclass = 5; //Huge
    
    if(!self.gun1)
    {
    	self.loddistance1 = 512; //Lod0 Model somewhat complex, so only use when very close

    	self.lodmodel1 = "models/vehicles/bulldozer_lod1.iqm";
	self.lodmodel2 = "models/vehicles/bulldozer_lod2.iqm";
	//self.lodmodel3 = "models/vehicles/bulldozer_lod3.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
        self.gun1               = spawn();
        self.gun2               = spawn();
	self.gun1.owner = self;
	//self.gun1.lodowner = 1; //Use owner origin for computing LOD
	//self.gun1.lodmodel1 = "models/mountedguns/maximgun_lod1.iqm";
	//self.gun1.lodmodel2 = "models/mountedguns/maximgun_lod2.iqm";
        //setmodel(self.gun1, "models/mountedguns/maximgun.iqm");
	//InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
        //setmodel(self.gun2, "models/vehicles/tankt27_cannon.iqm");
        setattachment(self.gun1, self, "tag_gunpivot");
        setattachment(self.gun2, self, "tag_cannon_pivot");
        self.gravity            = 2;
        self.mass               = 5000;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	//self.bomb1.gun2.scale = 2;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun2 = spinner;
	//self.bomb2.gun2.scale = 2;
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun1, "tag_gcamera");
	setattachment(self.vehicle_viewport, self, "tag_camera");
	
	self.hitboxbk = spawn();
	self.hitboxft = spawn();
	
	self.rotorboxft = spawn();
	self.rotorboxmf = spawn();
	self.rotorboxmb = spawn();
    	self.rotorboxbk = spawn();
	
	self.rotorboxftr = spawn();
	self.rotorboxmfr = spawn();
	self.rotorboxmbr = spawn();
    	self.rotorboxbkr = spawn();
	
	self.rotorboxftd1 = spawn();
	self.rotorboxmfd1 = spawn();
	self.rotorboxmbd1 = spawn();
    	self.rotorboxbkd1 = spawn();
	
	self.rotorboxftd2 = spawn();
	self.rotorboxmfd2 = spawn();
	self.rotorboxmbd2 = spawn();
    	self.rotorboxbkd2 = spawn();
	
	self.rotorboxft_t = spawn();
	self.rotorboxmf_t = spawn();
	self.rotorboxmid_t = spawn();
	self.rotorboxmb_t = spawn();
    	self.rotorboxbk_t = spawn();
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = bulldozer_think;
    self.touch              = bulldozer_vehicles_touch;
    self.subordinate        = self.hitboxbk; //For testing max_z in determining if should crush a player or monster
    self.subordinatespeed   = autocvar_g_vehicle_bulldozer_speed_walk;
    self.subordinateinertia = autocvar_g_vehicle_bulldozer_movement_inertia;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_bulldozer_health;
    self.vehicle_shield     = autocvar_g_vehicle_bulldozer_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun2.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = bulldozer_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
    
    tankt27_spawn_hitbox(1, self, self.hitboxft, BULLDOZER_MIN_HBF, BULLDOZER_MAX_HBF, 60, autocvar_g_vehicle_bulldozer_health);
    tankt27_spawn_hitbox(1, self, self.hitboxbk, BULLDOZER_MIN_HBB, BULLDOZER_MAX_HBB, -80, autocvar_g_vehicle_bulldozer_health);

    //We construct the colision for the front-end-loader part of the bulldozer
    //We mix slidebox and solid_trigger (the 1 and 10s) as they both work slightly differently
    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxft, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 10, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmf, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -10, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmb, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 40, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxbk, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -40, 8, autocvar_g_vehicle_bulldozer_health);

    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxftr, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 70, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmfr, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -70, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmbr, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 100, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxbkr, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -100, 8, autocvar_g_vehicle_bulldozer_health);

    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxftd1, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 130, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmfd1, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -130, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmbd1, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, 160, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxbkd1, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 200, -160, 8, autocvar_g_vehicle_bulldozer_health);

    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxftd2, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 230, 190, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmfd2, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 230, -190, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(10, self, self.rotorboxmbd2, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 260, 220, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(1, self, self.rotorboxbkd2, BULLDOZER_MIN_PHB, BULLDOZER_MAX_PHB, 260, -220, 8, autocvar_g_vehicle_bulldozer_health);

    //Here some slideboxes that don't bounce the player back (100)
    bulldozer_spawn_pushing_hitbox(100, self, self.rotorboxft_t, BULLDOZER_MIN_PHBD, BULLDOZER_MAX_PHBD, 230, 128, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(100, self, self.rotorboxmf_t, BULLDOZER_MIN_PHBD, BULLDOZER_MAX_PHBD, 230, 64, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(100, self, self.rotorboxmid_t, BULLDOZER_MIN_PHBD, BULLDOZER_MAX_PHBD, 230, 0, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(100, self, self.rotorboxmb_t, BULLDOZER_MIN_PHBD, BULLDOZER_MAX_PHBD, 230, -64, 8, autocvar_g_vehicle_bulldozer_health);
    bulldozer_spawn_pushing_hitbox(100, self, self.rotorboxbk_t, BULLDOZER_MIN_PHBD, BULLDOZER_MAX_PHBD, 230, -128, 8, autocvar_g_vehicle_bulldozer_health);
}

void spawnfunc_vehicle_bulldozer()
{
    if(!autocvar_g_vehicle_bulldozer)
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
    precache_model ( "models/vehicles/bulldozer.iqm");
    precache_model ( "models/vehicles/bulldozer_lod1.iqm");
    //precache_model ( "models/vehicles/tankt27_lod2.iqm");
    //precache_model ( "models/vehicles/tankt27_lod3.iqm");
    //precache_model ( "models/mountedguns/maximgun.iqm");
    //precache_model ( "models/mountedguns/maximgun_lod1.iqm");
    //precache_model ( "models/mountedguns/maximgun_lod2.iqm");
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    precache_model ( "models/vehicles/tankt27_cannon.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/campingrifle_fire.wav" );
    precache_sound ( "weapons/grenade_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "misc/mouseclick.wav");
    
    precache_sound ( "vehicles/bulldozer_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/bulldozer_jump.wav");
    precache_sound ( "vehicles/bulldozer_strafe.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "vehicles/bulldozer_land.wav");

    if(autocvar_g_vehicle_bulldozer_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_bulldozer_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_bulldozer_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "Bulldozer",
             "models/vehicles/bulldozer.iqm",
             "null",
             "null",
             "", "tag_camera", "",
             HUD_TANK,
             BULLDOZER_MIN, BULLDOZER_MAX,
             FALSE,
             bulldozer_spawn, autocvar_g_vehicle_bulldozer_respawntime,
             bulldozer_frame,
             bulldozer_enter, bulldozer_exit,
             bulldozer_die,   bulldozer_think,
             FALSE, 
             autocvar_g_vehicle_bulldozer_health,
             autocvar_g_vehicle_bulldozer_shield, autocolor, 0, 0))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}
#endif // SVQC
