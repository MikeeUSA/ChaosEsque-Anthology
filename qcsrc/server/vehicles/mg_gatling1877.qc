const vector MG_GATLING1877_MIN = '-20 -20 1';
const vector MG_GATLING1877_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_gatling1877;

float autocvar_g_vehicle_mg_gatling1877_respawntime;

float autocvar_g_vehicle_mg_gatling1877_speed_stop;
float autocvar_g_vehicle_mg_gatling1877_speed_strafe;
float autocvar_g_vehicle_mg_gatling1877_speed_walk;
float autocvar_g_vehicle_mg_gatling1877_movement_inertia;

float autocvar_g_vehicle_mg_gatling1877_springlength;
float autocvar_g_vehicle_mg_gatling1877_springup;
float autocvar_g_vehicle_mg_gatling1877_springblend;
float autocvar_g_vehicle_mg_gatling1877_tiltlimit;

float autocvar_g_vehicle_mg_gatling1877_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_gatling1877_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_gatling1877_gun_pitchspeed;
float autocvar_g_vehicle_mg_gatling1877_gun_turnlimit;
float autocvar_g_vehicle_mg_gatling1877_gun_turnspeed;

float autocvar_g_vehicle_mg_gatling1877_health;
float autocvar_g_vehicle_mg_gatling1877_health_regen;
float autocvar_g_vehicle_mg_gatling1877_health_regen_pause;

float autocvar_g_vehicle_mg_gatling1877_shield;
float autocvar_g_vehicle_mg_gatling1877_shield_regen;
float autocvar_g_vehicle_mg_gatling1877_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_gatling1877_machinegun_expelbulletcasings;
float autocvar_g_vehicle_mg_gatling1877_machinegun_speed;
float autocvar_g_vehicle_mg_gatling1877_machinegun_force;
float autocvar_g_vehicle_mg_gatling1877_machinegun_bulletconstant;
float autocvar_g_vehicle_mg_gatling1877_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_mg_gatling1877_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_gatling1877_machinegun_damage;
float autocvar_g_vehicle_mg_gatling1877_machinegun_refire;
float autocvar_g_vehicle_mg_gatling1877_machinegun_refire_min;
float autocvar_g_vehicle_mg_gatling1877_machinegun_refire_max;
float autocvar_g_vehicle_mg_gatling1877_machinegun_refire_amnt_fixed;
float autocvar_g_vehicle_mg_gatling1877_machinegun_refire_amnt_transition;
float autocvar_g_vehicle_mg_gatling1877_machinegun_spread;
float autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_max;
float autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_mg_gatling1877_machinegun_force;
float autocvar_g_vehicle_mg_gatling1877_machinegun_speed;
float autocvar_g_vehicle_mg_gatling1877_machinegun_bulletconstant;

vector autocvar_g_vehicle_mg_gatling1877_bouncepain;

.float gatling1877lastbuttonchangeold;
.float gatling1877lastbuttonchangemid;
.float gatling1877lastbuttonchangenew;
.float gatling1877lastbuttonforce;
.float gatling1877lastbuttonamt;
.float gatling1877lastbuttonwastype;
.float gatling1877lastbuttonoldtype;


void mg_gatling1877_exit(float eject);
void mg_gatling1877_enter();
void mg_gatling1877_spawn(float);

float mg_gatling1877_aiframe()
{
    return FALSE;
}

void mg_gatling1877_fire(entity mg_gatling1877, entity player, entity gunmount, entity mggun1) 
{
        mg_gatling1877.cnt = time;
        if(mg_gatling1877.vehicle_ammo1 >= autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_gatling1877.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_gatling1877_machinegun_spread, autocvar_g_vehicle_mg_gatling1877_machinegun_speed, 5, autocvar_g_vehicle_mg_gatling1877_machinegun_damage, autocvar_g_vehicle_mg_gatling1877_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_gatling1877_machinegun_force, DEATH_SPORTSTERGUN, PROJECTILE_MINIEBALL, 1, autocvar_g_vehicle_mg_gatling1877_machinegun_bulletconstant, autocvar_g_vehicle_mg_gatling1877_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
	 local float mytestpointcontents;
	 mytestpointcontents = pointcontents(v + (v_forward * 2));
	 if (mytestpointcontents == CONTENT_WATER
	 || mytestpointcontents == CONTENT_SLIME
	 || mytestpointcontents == CONTENT_LAVA)
	 {
		//Do nothing
	 } else {
	 	pointparticles(particleeffectnum("pipe_smoke"), v, v_forward * 2, 2);
	 }
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_somebass.wav", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_gatling1877_machinegun_expelbulletcasings == 1) {
  		//Casing
		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 5 - 25)) - 
			((random () * 5 + 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 32, gunmount, "tag_casings");
		}
		
		////CasingLink
		//if (autocvar_g_casings >= 2) {
		//	mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
		//	(v_forward * (random () * 5 - 25)) - 
		//	((random () * 5 + 70) * v_up), 2, 
		//	vectoangles(v_forward),'0 250 0', 100, 37, gunmount, "tag_casings");
		//}
  	 }	

            self = mg_gatling1877;

            mg_gatling1877.vehicle_ammo1 -= autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_cost;
            
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire
	                
	    player.vehicle_ammo1 = (mg_gatling1877.vehicle_ammo1 / autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_max) * 100;
	    
	    
            mggun1.angles_y += 12;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
	//Smooth animations. Also gun can spin via elec power even if no ammo
	} else if(mg_gatling1877.vehicle_ammo1 < autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire

            mggun1.angles_y += 12;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.attack_finished_single <= time)
	{
	    mggun1.attack_finished_single = time + (mggun1.count*0.3333333); // 1/3 time
	    mggun1.angles_y += 12;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.cnt <= time)
	{
	    mggun1.cnt = time + (mggun1.count*0.6666666); // 2/3 time

	    mggun1.angles_y += 12;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        }
}

float mg_gatling1877_crank(entity player, entity mg_gatling1877, float myrefiremax, float myrefire, float myrefiremin, entity mygunmount, entity mygun1, float myamnttransition, float myamntfixed)
{
    local float dofiring, mycorrectbutton, dogatlingspeedchange;
    mycorrectbutton = 0;
    dofiring = 0;
    dogatlingspeedchange = 0;
     
    
    	if(player.BUTTON_ATCK && !player.BUTTON_ATCK2) {
		if (mg_gatling1877.gatling1877lastbuttonoldtype) {
			dogatlingspeedchange = 1;
		}
	
		mg_gatling1877.gatling1877lastbuttonoldtype = 0;
	} else if (player.BUTTON_ATCK2 && !player.BUTTON_ATCK) {
		if (!mg_gatling1877.gatling1877lastbuttonoldtype) {
			dogatlingspeedchange = 1;
		}
		
		mg_gatling1877.gatling1877lastbuttonoldtype = 1;
	}
 
 
 	if (dogatlingspeedchange)
 	{
		mg_gatling1877.gatling1877lastbuttonchangeold = mg_gatling1877.gatling1877lastbuttonchangemid;
		mg_gatling1877.gatling1877lastbuttonchangemid = mg_gatling1877.gatling1877lastbuttonchangenew;
		mg_gatling1877.gatling1877lastbuttonchangenew = time;
		
		local float mycalc, mycalc2, mycalc3;
		mycalc = mycalc2 = mycalc3 = 0;
		
		if (mg_gatling1877.gatling1877lastbuttonchangemid) {
			mycalc = mg_gatling1877.gatling1877lastbuttonchangenew - mg_gatling1877.gatling1877lastbuttonchangemid;
		}
		
		if (mg_gatling1877.gatling1877lastbuttonchangeold) {
			mycalc2 = mg_gatling1877.gatling1877lastbuttonchangemid - mg_gatling1877.gatling1877lastbuttonchangeold;
		
			mycalc3 = (mycalc + mycalc2) * 0.5;
		} else {
			mycalc3 = mycalc;
		}
		
		
		
		//print("here ", ftos(mycalc3), " ... time:[ ",ftos(time)," ]\n");
		
		
		mygun1.count = bound(myrefiremax, myrefire * (mycalc3/0.3) , myrefiremin);
		if(mygun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(player, sprintf("RoF Set to %f RPM\n", (60/mygun1.count)));
    			mygun1.pushltime = time + 0.5;
		}
	}
    
    
    
    
    
    
    if not (mg_gatling1877.gatling1877lastbuttonforce) {
    	mg_gatling1877.gatling1877lastbuttonforce = 1;
    }
    
    if(mygunmount.attack_finished_single <= time)
    {
    ////////////////////////
    
    if
    (player.BUTTON_ATCK && mg_gatling1877.gatling1877lastbuttonforce == 1
    && !player.BUTTON_ATCK2)
    {
    	mycorrectbutton = 1;
    	mg_gatling1877.gatling1877lastbuttonwastype = 1;
    }
    else if(player.BUTTON_ATCK2 && mg_gatling1877.gatling1877lastbuttonforce == 2
    && !player.BUTTON_ATCK)
    {
    	mycorrectbutton = 1;
    	mg_gatling1877.gatling1877lastbuttonwastype = 2;
    }
    else if((player.BUTTON_ATCK || player.BUTTON_ATCK2)
    && (mg_gatling1877.gatling1877lastbuttonforce == -1|| mg_gatling1877.gatling1877lastbuttonforce == -2))
    {
    	mycorrectbutton = 1;
	
	if (player.BUTTON_ATCK && !player.BUTTON_ATCK2) {
		if (mg_gatling1877.gatling1877lastbuttonwastype == 2) {
    			mg_gatling1877.gatling1877lastbuttonwastype = 1;
			mg_gatling1877.gatling1877lastbuttonforce = 1;
			mg_gatling1877.gatling1877lastbuttonamt = 0;
		}
	} else if (player.BUTTON_ATCK2 && !player.BUTTON_ATCK) {
		if (mg_gatling1877.gatling1877lastbuttonwastype == 1) {
			mg_gatling1877.gatling1877lastbuttonwastype = 2;
			mg_gatling1877.gatling1877lastbuttonforce = 2;
			mg_gatling1877.gatling1877lastbuttonamt = 0;
		}
	}
    }
    
    if (mycorrectbutton)
    {
    	dofiring = 1;
	mg_gatling1877.gatling1877lastbuttonamt = mg_gatling1877.gatling1877lastbuttonamt + 1;
	
	if ((mg_gatling1877.gatling1877lastbuttonforce < 0 &&
	mg_gatling1877.gatling1877lastbuttonamt >= myamnttransition)
	|| (mg_gatling1877.gatling1877lastbuttonamt >= myamntfixed)) {
		mg_gatling1877.gatling1877lastbuttonamt = 0;
		
		if (mg_gatling1877.gatling1877lastbuttonforce == 1) {
			mg_gatling1877.gatling1877lastbuttonforce = -2;
		} else if (mg_gatling1877.gatling1877lastbuttonforce == 2) {
			mg_gatling1877.gatling1877lastbuttonforce = -1;
		} else if (mg_gatling1877.gatling1877lastbuttonforce == -1) {
			mg_gatling1877.gatling1877lastbuttonforce = 1;
		} else if (mg_gatling1877.gatling1877lastbuttonforce == -2) {
			mg_gatling1877.gatling1877lastbuttonforce = 2;
		} else {
			mg_gatling1877.gatling1877lastbuttonforce = 0;
		}
		
		//mg_gatling1877.gatling1877lastbuttonchangeold = mg_gatling1877.gatling1877lastbuttonchangemid;
	}
    }
    
    ////////////////////////
    }
    
    return dofiring;
}

float mg_gatling1877_frame()
{
    vector ad;
    entity player, mg_gatling1877;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_gatling1877 = self.vehicle;
    self   = mg_gatling1877;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_gatling1877.tur_head, gettagindex(mg_gatling1877.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_gatling1877);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_gatling1877.angles), AnglesTransform_FromAngles(ad))) - mg_gatling1877.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_gatling1877_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_gatling1877.tur_head.angles_y = bound(autocvar_g_vehicle_mg_gatling1877_gun_turnlimit * -1, mg_gatling1877.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_gatling1877_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_gatling1877_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_gatling1877.tur_head.angles_x = bound(autocvar_g_vehicle_mg_gatling1877_gun_pitchlimit_down, mg_gatling1877.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_gatling1877_gun_pitchlimit_up);


    //fixedmakevectors(mg_gatling1877.angles);
    makevectors(mg_gatling1877.angles + '-2 0 0' * mg_gatling1877.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_gatling1877_springlength, autocvar_g_vehicle_mg_gatling1877_springup, autocvar_g_vehicle_mg_gatling1877_springblend, autocvar_g_vehicle_mg_gatling1877_tiltlimit);

    if(mg_gatling1877.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_gatling1877_speed_stop);
		if (mg_gatling1877.spawnflags < 16) {
			setanim(player, player.anim_idle, TRUE, FALSE, FALSE);
		} else {
			setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
		}
        }
	
	if not(mg_gatling1877.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_gatling1877, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_gatling1877.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_gatling1877, player, autocvar_g_vehicle_mg_gatling1877_speed_walk, autocvar_g_vehicle_mg_gatling1877_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_gatling1877_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_gatling1877_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_gatling1877_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_gatling1877_tiltlimit);
    
    mg_resetpunchangle(player);
    
    local float dofiring;
    dofiring = 0;
    
    dofiring =  mg_gatling1877_crank(player, mg_gatling1877,
 		autocvar_g_vehicle_mg_gatling1877_machinegun_refire_max,
 		autocvar_g_vehicle_mg_gatling1877_machinegun_refire,
 		autocvar_g_vehicle_mg_gatling1877_machinegun_refire_min, 
 		mg_gatling1877.tur_head, 
 		mg_gatling1877.gun1,
		autocvar_g_vehicle_mg_gatling1877_machinegun_refire_amnt_transition,
		autocvar_g_vehicle_mg_gatling1877_machinegun_refire_amnt_fixed);
    
    if(dofiring)
    {
	
	
    	local float dopunchangle;
	dopunchangle = 0;
	
	if (!g_norecoil) {
    	if(mg_gatling1877.vehicle_ammo1 >= autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_cost && mg_gatling1877.tur_head.attack_finished_single <= time)
        	{
			dopunchangle = 1;
		}
	}
	
	mg_gatling1877_fire(mg_gatling1877, player, mg_gatling1877.tur_head, mg_gatling1877.gun1);
	mg_gatling1877.count = 0; //Will have to press R to resume reload
	
	if (dopunchangle) {
		player.punchangle_x = random () - 0.3;
		player.punchangle_y = random () - 0.3;
	}
    } else {
    	if (mg_gatling1877.count == 1) {
        vehicles_regen(mg_gatling1877.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_gatling1877.count = 1;
		sound (mg_gatling1877, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //50 ammo, 1 player ammo = 1 vehic ammo, (currently using colt 44 peacemaker / henry repearing rifle 44 ammo)
		vehicles_replenishAmmo(player, mg_gatling1877, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 1);
	}
    }
       
       
       
    //if(player.BUTTON_JUMP) {
    	//mg_gatling1877.gun1.count = bound(autocvar_g_vehicle_mg_gatling1877_machinegun_refire_max, mg_gatling1877.gun1.count - (autocvar_g_vehicle_mg_gatling1877_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_gatling1877_machinegun_refire_min);
	//if(mg_gatling1877.gun1.pushltime < time)  // Don't flood the connection with the messages
	//{
	//	sprint(player, sprintf("RoF Raised to %f RPM\n", (60/mg_gatling1877.gun1.count)));
    	//	mg_gatling1877.gun1.pushltime = time + 0.25;
	//}
    //}
    
    //if(player.BUTTON_CROUCH ) {
    	//mg_gatling1877.gun1.count = bound(autocvar_g_vehicle_mg_gatling1877_machinegun_refire_max, mg_gatling1877.gun1.count + (autocvar_g_vehicle_mg_gatling1877_machinegun_refire_changerate * sys_frametime),autocvar_g_vehicle_mg_gatling1877_machinegun_refire_min);
	//if(mg_gatling1877.gun1.pushltime < time)  // Don't flood the connection with the messages
	//{
	//	sprint(player, sprintf("RoF Lowered to %f RPM\n", (60/mg_gatling1877.gun1.count)));
	//	mg_gatling1877.gun1.pushltime = time + 0.25;
	//}
    //}
    player.BUTTON_JUMP   = 0;
    player.BUTTON_CROUCH    = 0;
    
    

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_gatling1877.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_gatling1877_shield, autocvar_g_vehicle_mg_gatling1877_shield_regen_pause, autocvar_g_vehicle_mg_gatling1877_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_gatling1877.dmg_time, vehicle_health, autocvar_g_vehicle_mg_gatling1877_health, autocvar_g_vehicle_mg_gatling1877_health_regen_pause, autocvar_g_vehicle_mg_gatling1877_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_gatling1877.origin + '0 0 1' * MG_GATLING1877_MAX_z);
    player.velocity = mg_gatling1877.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_gatling1877);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_gatling1877);

    player.vehicle_ammo1_current = mg_gatling1877.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_gatling1877.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_gatling1877_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_gatling1877_speed_stop);

    self.nextthink = time;
}

void mg_gatling1877_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_gatling1877_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_gatling1877_shield) * 100;
    
    mg_enter(self.owner);
    
    if (self.spawnflags < 16) {
    	//We don't crouch for this weapon
    	self.owner.crouch = FALSE;
    	setsize(self.owner, PL_MIN,PL_MAX);
    	setanim(self.owner, self.owner.anim_idle, TRUE, FALSE, FALSE);
    }
}

void mg_gatling1877_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_gatling1877_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_gatling1877_speed_strafe)
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

void mg_gatling1877_impact()
{
    if(autocvar_g_vehicle_mg_gatling1877_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_gatling1877_bouncepain_x, autocvar_g_vehicle_mg_gatling1877_bouncepain_y, autocvar_g_vehicle_mg_gatling1877_bouncepain_z);    
}

void mg_gatling1877_headfade()
{
	self.think = mg_gatling1877_headfade;
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

void mg_gatling1877_blowup()
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


    setmodel(b,  "models/mountedguns/gatlingstand.iqm");
    h.lodmodel1 = "models/mountedguns/gatling1877gun_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/gatling1877gun_lod2.iqm";
    setmodel(h,  "models/mountedguns/gatling1877gun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_gatling1877_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_gatling1877_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_gatling1877_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_gatling1877_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_gatling1877_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_gatling1877_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_gatling1877_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();
	setmodel(self.gun1,"models/mountedguns/gatling1877gun_barrels.iqm");
	setattachment(self.gun1, self.tur_head, "tag_axis");
	self.gun1.count = autocvar_g_vehicle_mg_gatling1877_machinegun_refire;
        
        self.gravity            = 1;
        self.mass               = 300;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/gatling1877gun_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/gatling1877gun_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_gatling1877_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_gatling1877_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_gatling1877_shield;
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
    self.vehicle_impact = mg_gatling1877_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_gatling1877()
{
    if(!autocvar_g_vehicle_mg_gatling1877)
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
    	precache_model ( "models/mountedguns/gatlingstand.iqm");
    	bodymodel = "models/mountedguns/gatlingstand.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }
    
    mg_shield_precache();
    precache_model ( "models/mountedguns/gatling1877gun.iqm");
    precache_model ( "models/mountedguns/gatling1877gun_lod1.iqm");
    precache_model ( "models/mountedguns/gatling1877gun_lod2.iqm");
    precache_model ( "models/mountedguns/gatling1877gun_barrels.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/uzi_fire_somebass.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_gatling1877_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_gatling1877_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_gatling1877_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "Gatling1877Gun",
             bodymodel,
             "models/mountedguns/gatling1877gun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_GATLING1877_MIN, MG_GATLING1877_MAX,
             FALSE,
             mg_gatling1877_spawn, autocvar_g_vehicle_mg_gatling1877_respawntime,
             mg_gatling1877_frame,
             mg_gatling1877_enter, mg_gatling1877_exit,
             mg_gatling1877_die,   mg_gatling1877_think,
             FALSE, 
             autocvar_g_vehicle_mg_gatling1877_health,
             autocvar_g_vehicle_mg_gatling1877_shield, 1, autocvar_g_vehicle_mg_gatling1877_machinegun_ammo_max * 10, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

