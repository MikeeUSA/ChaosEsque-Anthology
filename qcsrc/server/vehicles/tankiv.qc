const vector TANKIV_MIN = '-100 -100 1';
const vector TANKIV_MAX  = '100 100 132';

const vector TANKIV_MIN_HBF = '-80 -80 1';
const vector TANKIV_MAX_HBF = '80 80 115';

const vector TANKIV_MIN_HBB = '-100 -100 1';
const vector TANKIV_MAX_HBB = '100 100 65';


#ifdef SVQC
float autocvar_g_vehicle_tankiv;

float autocvar_g_vehicle_tankiv_respawntime;

float autocvar_g_vehicle_tankiv_speed_stop;
float autocvar_g_vehicle_tankiv_speed_strafe;
float autocvar_g_vehicle_tankiv_speed_walk;
float autocvar_g_vehicle_tankiv_movement_inertia;

float autocvar_g_vehicle_tankiv_springlength;
float autocvar_g_vehicle_tankiv_springup;
float autocvar_g_vehicle_tankiv_springblend;
float autocvar_g_vehicle_tankiv_tiltlimit;

float autocvar_g_vehicle_tankiv_gun_pitchlimit_down;
float autocvar_g_vehicle_tankiv_gun_pitchlimit_up;
float autocvar_g_vehicle_tankiv_gun_pitchspeed;
float autocvar_g_vehicle_tankiv_gun_turnlimit;
float autocvar_g_vehicle_tankiv_gun_turnspeed;

//float autocvar_g_vehicle_tankiv_energy;
//float autocvar_g_vehicle_tankiv_energy_regen;
//float autocvar_g_vehicle_tankiv_energy_regen_pause;

float autocvar_g_vehicle_tankiv_health;
float autocvar_g_vehicle_tankiv_health_regen;
float autocvar_g_vehicle_tankiv_health_regen_pause;

float autocvar_g_vehicle_tankiv_shield;
float autocvar_g_vehicle_tankiv_shield_regen;
float autocvar_g_vehicle_tankiv_shield_regen_pause;

float autocvar_g_vehicle_tankiv_machinegun_ammo_max;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_tankiv_cannon_speed;
float autocvar_g_vehicle_tankiv_cannon_force;
float autocvar_g_vehicle_tankiv_cannon_bulletconstant;
float autocvar_g_vehicle_tankiv_cannon_headshotaddeddamage;
float autocvar_g_vehicle_tankiv_cannon_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_tankiv_cannon_damage;
float autocvar_g_vehicle_tankiv_cannon_refire;
float autocvar_g_vehicle_tankiv_cannon_spread;
float autocvar_g_vehicle_tankiv_cannon_ammo_cost;
float autocvar_g_vehicle_tankiv_cannon_ammo_max;
float autocvar_g_vehicle_tankiv_cannon_ammo_regen;
float autocvar_g_vehicle_tankiv_cannon_ammo_regen_pause;
float autocvar_g_vehicle_tankiv_cannon_force;
float autocvar_g_vehicle_tankiv_cannon_speed;
float autocvar_g_vehicle_tankiv_cannon_bulletconstant;
float autocvar_g_vehicle_tankiv_cannon_iter;
float autocvar_g_vehicle_tankiv_cannon_iterforward;
float autocvar_g_vehicle_tankiv_cannon_fragments;
float autocvar_g_vehicle_tankiv_cannon_fragments_frames;
float autocvar_g_vehicle_tankiv_cannon_pitchspeed;
float autocvar_g_vehicle_tankiv_cannon_pitchlimit_down;
float autocvar_g_vehicle_tankiv_cannon_pitchlimit_up;

vector autocvar_g_vehicle_tankiv_bouncepain;

float autocvar_g_vehicle_tankiv_gunback_turnlimit; //general
float autocvar_g_vehicle_tankiv_gunback_turnlimit_in;
float autocvar_g_vehicle_tankiv_gunback_turnlimit_out;
float autocvar_g_vehicle_tankiv_gunback_pitchlimit_down;
float autocvar_g_vehicle_tankiv_gunback_pitchlimit_up;

.entity gun0;

void tankiv_exit(float eject);
void tankiv_enter();
void tankiv_spawn(float);

void tankiv_FragsOverTime (void)
{
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		DEATH_FRAGMENT,
		PROJECTILE_BULLETSHRAPNEL,
		autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();		
	}
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_vehicle_tankiv_cannon_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}


void tankiv_FragsOverTimeSpawn (entity gren)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	e.think = tankiv_FragsOverTime;
	e.count = floor(autocvar_g_vehicle_tankiv_cannon_fragments / autocvar_g_vehicle_tankiv_cannon_fragments_frames)+1;
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void tankiv_Grenade_Explode2 (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
			sprint(self.realowner, "Your shell failed to detonate\n");
		}
	} else {
	
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;
		
	if (other.classname == "tree") {
		mine_damage_tree(other, self, autocvar_g_balance_rocketlauncher_damage * 4 * autocvar_g_balance_minelayer_damagerate_tree);
	}
	
	float iterfwd;
	iterfwd = tankt27_EvaluateMaterialHit(other, autocvar_g_vehicle_tankiv_cannon_iterforward);
	//print(sprintf("IterFWD %f \n", (iterfwd)));

	float	xc;
	for (xc = 0;xc < autocvar_g_vehicle_tankiv_cannon_iter;xc = xc + 1) {
	
		RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);

		OilFire_explosion_spawnoilburnermaybe(self);
		
		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
			if(autocvar_g_vehicle_tankiv_cannon_fragments_frames < 2)
			{
				//Start Grenade Fragmentation
				float	sc;
				for (sc = 0;sc < autocvar_g_vehicle_tankiv_cannon_fragments;sc = sc + 1) {
	
				fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
				 DEATH_FRAGMENT,
				 PROJECTILE_BULLETSHRAPNEL,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
				 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
				endFireBallisticBullet();
				}
				//Finish Grenade Fragmentation
			} else {
				tankiv_FragsOverTimeSpawn(self); //Spread out fragment spawning
			}
		}
		
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');

			setorigin(self, (self.origin + v_forward * iterfwd)); //Forward X qunits
		}

	}
	remove (self);
}

void tankiv_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void tankiv_fire_cannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun00, gettagindex(self.gun00, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankiv_Grenade_Explode2;
	gren.touch = tankiv_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankiv_cannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	//if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	//else
	//	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float tankiv_aiframe()
{
    return FALSE;
}

void tankiv_maxim_fire(entity gun, entity pilot, entity gunmount)
{
    if(pilot.BUTTON_ATCK)
    {
	mg_maxim_fire(gun, pilot, gunmount);
	gunmount.count = 0; //Will have to press R to resume reload
    } else {
    	if (gunmount.count == 1) {
        vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_maxim_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((pilot.impulse == 20) && !(pilot.BUTTON_HOOK)) {
			gunmount.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (pilot.impulse == 20)
	if (pilot.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 pilot ammo = 1 vehic ammo,
		vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);	
	}
    }
}


void tankiv_mg_hotchkissm1914_fire(entity mg_hotchkissm1914, entity player, entity gunmount) 
{
	mg_hotchkissm1914.cnt = time;
        if((gunmount.ammount3 > 0) && (time >= gunmount.ammount2) && mg_hotchkissm1914.vehicle_ammo1 >= autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_hotchkissm1914.misc_bulletcounter += 1;
	    gunmount.ammount3 = gunmount.ammount3 - 1; //30 round clip
	    gunmount.ammount2 = time;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_spread, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_speed, 5, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_damage, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_headshotaddeddamage, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_force, DEATH_SPORTSTERGUNLT, PROJECTILE_BULLETRIFLE9MM, 1, autocvar_g_balance_projectile_30calrifle_bulletconstant, autocvar_g_vehicle_mg_hotchkissm1914_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_bass.ogg", VOL_BASE, ATTN_NORM);

	    
   	if (autocvar_g_vehicle_mg_hotchkissm1914_machinegun_expelbulletcasings == 1) {
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 150 + 150) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 2 - 7) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 63, gunmount, "tag_casings");
		}
  	 }	

            self = mg_hotchkissm1914;

            mg_hotchkissm1914.vehicle_ammo1 -= autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_hotchkissm1914_machinegun_refire;
            player.vehicle_ammo1 = (mg_hotchkissm1914.vehicle_ammo1 / autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_max) * 100;
	    
	    gunmount.ammount5 = gunmount.ammount5 + autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatconstant;
         
	    if (gunmount.ammount5 > random() )
 	    {
		sprint(player, "Your gun overheated\n");
		
		pointparticles(particleeffectnum("shotgun_muzzleflash"), gettaginfo(gunmount, gettagindex(gunmount, "tag_casings")), v_forward * 2, 1);
		
		gunmount.attack_finished_single = gunmount.attack_finished_single + (autocvar_g_vehicle_mg_hotchkissm1914_machinegun_cooldownwait * (gunmount.ammount5 + 1));
	    }
        }
}


void tankiv_hotchkissm1914_fire(entity gun, entity pilot, entity gunmount)
{
    if(pilot.BUTTON_ATCK)
    {
	tankiv_mg_hotchkissm1914_fire(gun, pilot, gunmount);
	gunmount.count = 0; //Will have to press R to resume reload
	
	//print (ftos(gunmount.ammount5), " USING\n");
    } else {
    	if (gunmount.count == 1) {
		if (gunmount.ammount3 < autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_max) {
			if (time >= gunmount.ammount2) {
				gunmount.ammount3 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_max;
				gunmount.ammount2 = time + autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_regen_pause + (autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_max/autocvar_g_vehicle_mg_hotchkissm1914_machinegun_ammo_regen);
			}
		}
		
        	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_maxim_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_maxim_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((pilot.impulse == 20) && !(pilot.BUTTON_HOOK)) {
			gunmount.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (pilot.impulse == 20)
	if (pilot.BUTTON_HOOK) {
		//Reload from own stores //50 ammo, 3 pilot ammo = 1 vehic ammo,
		//Note, on the hotchkiss gun itself it is 2 pilot ammo = 1 vehic ammo
		//however currently the maxim gun draws from this ammo too
		//which is 3 for 1, so we default to the more expensive one
		vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 3);	
	}
	
	//Overheating and cooldown stuff://
	if (gunmount.ammount5 < autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin) {
		gunmount.ammount5 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin;
	
		//print (ftos(gunmount.cnt), " REPLENISH2\n");
	} else {
		gunmount.ammount5 = gunmount.ammount5 - (autocvar_g_vehicle_mg_hotchkissm1914_machinegun_cooldownrate * sys_frametime);
		
		//print (ftos(gunmount.ammount5), " REPLENISH1\n");
	}
    }
}



//Add For multi
float tankiv_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;

	//print(etos(vehic),"--Tanka7v\n");
	//print(etos(gun),"--Gun7v\n");
	//print(etos(gunner),"--Gunner7v\n");
	//print(vtos(gunner.origin), "--vs--", vtos(vehic.origin),"\n");
	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin + '0 0 32'); //+32 so not in ground
	//setorigin(gunner, vehic.origin + '0 0 64'); //+64 test to see if reduces shake
	gunner.velocity = vehic.velocity;
	
	//float _in, _out;
	//vehic.angles_x *= -1;
	//makevectors(vehic.angles);
	//vehic.angles_x *= -1;
	//if((gun == vehic.gun0))
	//{
	//	_in = autocvar_g_vehicle_tankiv_cannon_turnlimit_in;
	//	_out = autocvar_g_vehicle_tankiv_cannon_turnlimit_out;
	//	//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * 128);
	//}
	//else
	//{
	//	_in = autocvar_g_vehicle_tankiv_cannon_turnlimit_out;
	//	_out = autocvar_g_vehicle_tankiv_cannon_turnlimit_in;
	//	//setorigin(gunner, vehic.origin + v_up * -16 + v_forward * -16 + v_right * -128);		
	//}
	
	//_in = autocvar_g_vehicle_tankiv_gun_turnlimit;
	//_out = autocvar_g_vehicle_tankiv_gun_turnlimit;
	
	//if(gun == vehic.gun1)
	//if (vehic.vehicle_ammo1_max) {
    	//gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	//gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
    	//}
	
	//crosshair_trace2(gunner);
	//vector _ct = trace_endpos;
	//vector ad;
	//
	//	vehicle_aimturret(vehic, _ct, gun, "fire",
	//					  autocvar_g_vehicle_tankiv_gun_pitchlimit_down * -1, autocvar_g_vehicle_tankiv_gun_pitchlimit_up,
	//					  _out * -1,  _in,  autocvar_g_vehicle_tankiv_gun_turnspeed);
	//



    //For gun1 (back gun)
    
    //makevectors(gun.angles_x * '-1 0 0' + gun.angles_y * '0 1 0' + gun.angles_z * '0 0 1');
    makevectors(gun.angles); //test to see if removes shaking ... didn't
    //makevectors(gunner.v_angle); //test again... didn't
    
    float ftmp;
    vector ad;
    vector myvehicangles;
    myvehicangles = vehic.angles;
    //myvehicangles_y = myvehicangles_y * -1;
    //myvehicangles_x = myvehicangles_x * -1;
    
    ad = gettaginfo(gun, gettagindex(gun, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, vehic);
    
    //float effectnum;
    //effectnum = particleeffectnum("TE_TEI_G3");
    //trailparticles(gunner, effectnum, ad, trace_endpos);
				
    
    //UpdateAuxiliaryXhair(gunner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' * (1 - gunner.vehicle_reload1)), 0);
    
    crosshair_trace2(gunner);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(myvehicangles), AnglesTransform_FromAngles(ad))) - gun.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);



    // Yaw //KISS
    float gunnerangley;
    
    if ((gun == vehic.gun3) || (gun == vehic.gun4)) {
   	 //For reverse:
    	gunnerangley = gunner.v_angle_y - 180;
    	gunnerangley = gunner.v_angle_y - 180 - vehic.angles_y;
    } else {
   	//Forward facing
    	gunnerangley = gunner.v_angle_y;
    	gunnerangley = gunner.v_angle_y - vehic.angles_y;
    }
    
    ftmp = autocvar_g_vehicle_tankiv_gun_turnspeed * sys_frametime;
    	//print (ftos(gunner.v_angle_y), "   ", ftos(gunnerangley),"   ", ftos(vehic.angles_y),"\n");
    ftmp = bound(-ftmp, shortangle_f(gunnerangley - gun.angles_y, gun.angles_y), ftmp);
    gun.angles_y = anglemods(gun.angles_y + ftmp);
    if (gun == vehic.gun1) {
    	gun.angles_y = bound(autocvar_g_vehicle_tankiv_gunback_turnlimit_in * -1, gun.angles_y, autocvar_g_vehicle_tankiv_gunback_turnlimit_out); 
    } else if (gun == vehic.gun2) {
       	gun.angles_y = bound(autocvar_g_vehicle_tankiv_gunback_turnlimit_out * -1, gun.angles_y, autocvar_g_vehicle_tankiv_gunback_turnlimit_in); 
    
    } else if (gun == vehic.gun3) {
    	gun.angles_y = bound(autocvar_g_vehicle_tankiv_gunback_turnlimit_out * -1, gun.angles_y, autocvar_g_vehicle_tankiv_gunback_turnlimit_in); 
    } else if (gun == vehic.gun4) {
       	gun.angles_y = bound(autocvar_g_vehicle_tankiv_gunback_turnlimit_in * -1, gun.angles_y, autocvar_g_vehicle_tankiv_gunback_turnlimit_out); 
    
    } else {
    	gun.angles_y = bound(autocvar_g_vehicle_tankiv_gunback_turnlimit * -1, gun.angles_y, autocvar_g_vehicle_tankiv_gunback_turnlimit); 
    }
    
    // Pitch head
    ftmp = autocvar_g_vehicle_tankiv_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    gun.angles_x = bound(autocvar_g_vehicle_tankiv_gunback_pitchlimit_down, gun.angles_x + ad_x, autocvar_g_vehicle_tankiv_gunback_pitchlimit_up);



	if ((gun == vehic.gun1) || (gun == vehic.gun2) || (gun == vehic.gun3) || (gun == vehic.gun4)) {
		tankiv_hotchkissm1914_fire(vehic, gunner, gun);
	}
	
	//Allow gunner to reload cannon too, so pilot doesn't have to get out
	if (gunner.impulse == 20) {
	if (gunner.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 gunner ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(gunner, vehic, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
	}
	}

	VEHICLE_UPDATE_PLAYER(gunner, health, tankiv);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, tankiv);

	//ad = gettaginfo(gun, gettagindex(gun, "fire")); //Commenting out Didn't change shaking
	//traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, gun); //Commenting out Didn't change shaking

	if ((gun == vehic.gun1) || (gun == vehic.gun2) || (gun == vehic.gun3) || (gun == vehic.gun4)) {
		//UpdateAuxiliaryXhair(gunner, trace_endpos, '0 0 0', 0);
		UpdateAuxiliaryXhair(gunner, trace_endpos, '0 1 0', 0);
		UpdateAuxiliaryXhair(gunner, trace_endpos, '1 0.5 0', 1);
		
		//if(vehic.owner)
		//	UpdateAuxiliaryXhair(vehic.owner, trace_endpos, ('1 0 0' * gunner.vehicle_reload1) + ('0 1 0' *(1 - gunner.vehicle_reload1)), ((gunner == vehic.gunner1) ? 1 : 2));
	}

	vehic.solid = SOLID_SLIDEBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;
	//gunner.vehicle_energy = (gun.vehicle_energy / autocvar_g_vehicle_tankiv_machinegun_ammo_max) * 100;
	gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
	gunner.vehicle_ammo2_current = vehic.vehicle_ammo2_current;
    	gunner.vehicle_ammo2_max = vehic.vehicle_ammo2_max;

	self = gunner;
	return 1;
}

void tankiv_gunner_exit(float _exitflag)
{


	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEWPORT);
		WriteEntity(MSG_ONE, self);

		WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
		WriteAngle(MSG_ONE, 0);
		WriteAngle(MSG_ONE, self.vehicle.angles_y);
		WriteAngle(MSG_ONE, 0);
	}
	
	CSQCVehicleSetup(self, HUD_NORMAL);
	setsize(self, PL_MIN, PL_MAX);

	self.vehicle_playerisgunner = 0;
	self.vehicle_playergunnervehicle  = world;
	self.vehicle_changeseat	= func_null;
	self.takedamage     = DAMAGE_AIM;
	self.solid          = SOLID_SLIDEBOX;
	self.movetype       = MOVETYPE_WALK;
	self.effects        &~= EF_NODRAW;
	self.alpha          = 1;
	self.PlayerPhysplug = func_null;
	self.view_ofs       = PL_VIEW_OFS;
	self.event_damage   = PlayerDamage;
	self.hud            = HUD_NORMAL;
	self.switchweapon   = self.vehicle.switchweapon;

    vh_player = self;
    vh_vehicle = self.vehicle;
    MUTATOR_CALLHOOK(VehicleExit);
    self = vh_player;
    self.vehicle = vh_vehicle;

	self.vehicle.vehicle_hudmodel.viewmodelforclient = self.vehicle;

	fixedmakevectors(self.vehicle.owner.angles);

	if(self == self.vehicle.owner.gunner1)
	{
		self.vehicle.owner.gunner1 = world;
	}
	else if(self == self.vehicle.owner.gunner2)
	{
		self.vehicle.owner.gunner2 = world;
	}
	else if(self == self.vehicle.owner.gunner3)
	{
		self.vehicle.owner.gunner3 = world;
	}
	else if(self == self.vehicle.owner.gunner4)
	{
		self.vehicle.owner.gunner4 = world;
	}
	else
		dprint("^1self != gunner1,2,3,4,5,6,...,14, this is a BIG PROBLEM, tell tZork this happend.\n");
		
	vector spot = self.vehicle.owner.origin + v_up * 132 + v_right * 306;
	spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
	//setorigin(self , spot);

	self.velocity = 0.75 * self.vehicle.owner.velocity + normalize(spot - self.vehicle.owner.origin) * 200;
	self.velocity_z += 10;

	self.vehicle.phase = time + 5;
	self.vehicle        = world;
}

float tankiv_gunner_enter(float selectgun)
{
	RemoveGrapplingHook(other);
	entity _gun, _gunner;
	if(!self.gunner1 && (!selectgun || selectgun == 1))
	{
		_gun = self.gun1;
		_gunner = self.gunner1;
		self.gunner1 = other;
	}
	else if(!self.gunner2 && (!selectgun || selectgun == 2))
	{
		_gun = self.gun2;
		_gunner = self.gunner2;
		self.gunner2 = other;
	}
	else if(!self.gunner3 && (!selectgun || selectgun == 3))
	{
		_gun = self.gun3;
		_gunner = self.gunner3;
		self.gunner3 = other;
	}
	else if(!self.gunner4 && (!selectgun || selectgun == 4))
	{
		_gun = self.gun4;
		_gunner = self.gunner4;
		self.gunner4 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = tankiv_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= tankiv_gunner_enter;
	other.angles            = self.angles;
	other.takedamage        = DAMAGE_NO;
	other.solid             = SOLID_NOT;
	other.movetype          = MOVETYPE_NOCLIP;
	other.alpha             = -1;
	other.event_damage      = func_null;
	other.view_ofs          = '0 0 0';
	other.hud               = _gun.hud;
	other.PlayerPhysplug    = _gun.PlayerPhysplug;
	other.vehicle_ammo1     = self.vehicle_ammo1;
	other.vehicle_ammo2     = self.vehicle_ammo2;
	other.vehicle_reload1   = self.vehicle_reload1;
	other.vehicle_reload2   = self.vehicle_reload2;
	other.vehicle_energy    = self.vehicle_energy;
	other.PlayerPhysplug    = tankiv_gunner_frame;
	other.flags             &~= FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	if (_gun == self.gun1 || _gun == self.gun2) {
		//Spontoon gun - Front facing
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll
	} else if (_gun == self.gun3 || _gun == self.gun4) {
		//Spontoon gun - Back facing
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y - 180);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll
	} else {
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll
	}
	_gun.vehicle_hudmodel.viewmodelforclient = other;

	CSQCVehicleSetup(other, other.hud);
	
    vh_player = other;
    vh_vehicle = _gun;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    _gun = vh_vehicle;

	return TRUE;
}

float tankivvehicles_valid_pilot()
{
	if(other.classname != "player")
		return FALSE;

	if(other.deadflag != DEAD_NO)
		return FALSE;

	if(other.vehicle != world)
		return FALSE;

	if(clienttype(other) != CLIENTTYPE_REAL)
		if(!autocvar_g_vehicles_allow_bots)
			return FALSE;

	if(teamplay && other.team != self.team)
		return FALSE;

	return TRUE;
}

void tankiv_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world && self.gunner5 != world && self.gunner6 != world && self.gunner7 != world && self.gunner8 != world && self.gunner9 != world && self.gunner10 != world && self.gunner11 != world && self.gunner12 != world && self.gunner13 != world))
	{
		tankt27_vehicles_touch();
		return;
	}

	if(tankivvehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(tankiv_gunner_enter(0))
				return;
				
		if(self.gun2.phase <= time)
			if(tankiv_gunner_enter(0))
				return;
				
		if(self.gun3.phase <= time)
			if(tankiv_gunner_enter(0))
				return;
				
		if(self.gun4.phase <= time)
			if(tankiv_gunner_enter(0))
				return;
	}

	tankt27_vehicles_touch();
}



//Done For multi


float tankiv_frame()
{
    vector ad, vf;
    entity player, tankiv;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    tankiv = self.vehicle;
    self   = tankiv;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    


    ad = gettaginfo(tankiv.gun0, gettagindex(tankiv.gun0, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankiv);
    UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    vf = ad;
    ad = gettaginfo(tankiv.gun00, gettagindex(tankiv.gun00, "tag_cannon"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankiv);
    UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 1);
    //ad = 0.5 * (ad + vf);
    ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankiv.angles), AnglesTransform_FromAngles(ad))) - tankiv.gun0.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_tankiv_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    tankiv.gun0.angles_y = bound(autocvar_g_vehicle_tankiv_gun_turnlimit * -1, tankiv.gun0.angles_y + ad_y, autocvar_g_vehicle_tankiv_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_tankiv_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    tankiv.gun0.angles_x = bound(autocvar_g_vehicle_tankiv_gun_pitchlimit_down, tankiv.gun0.angles_x + ad_x, autocvar_g_vehicle_tankiv_gun_pitchlimit_up);


    //fixedmakevectors(tankiv.angles);
    makevectors(tankiv.angles + '-2 0 0' * tankiv.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_tankiv_springlength, autocvar_g_vehicle_tankiv_springup, autocvar_g_vehicle_tankiv_springblend, autocvar_g_vehicle_tankiv_tiltlimit);

    if(tankiv.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("tankiv_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_tankiv_speed_stop);
                //tankiv.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0)
   	 {
	 	if(tankiv.angles_y > 180)  tankiv.angles_y -= 360;
    		if(tankiv.angles_y < -180) tankiv.angles_y += 360;
		tankiv.angles_y = bound(-184,tankiv.angles_y + ((player.movement_y * sys_frametime) / -6.66666),184);	
		
		if(tankiv.angles_y >= -1 && tankiv.angles_y <= -1)
            		tankiv.angles_y = 0;	

		////float degree_y;
		////player.angles_y = player.angles_y + ((player.movement_y * sys_frametime) / -6.66666);
		////degree_y = ((player.movement_y * sys_frametime) / -6.66666);
		////player.v_angle_y += degree_y;
		
		player.v_angle_y = tankiv.angles_y; //kiss

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
  		//////WriteAngle( MSG_ONE, tankiv.angles_x); 
  		//////WriteAngle( MSG_ONE, tankiv.angles_y);
  		//////WriteAngle( MSG_ONE, tankiv.angles_z);
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
                        tankiv.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        tankiv.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(tankiv.angles);
    			makevectors(tankiv.angles + '-2 0 0' * tankiv.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_oldtank_waterspeed_simple(player, autocvar_g_vehicle_tankiv_speed_walk),autocvar_g_vehicle_tankiv_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 4; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("tankiv_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_tankiv_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_tankiv_tiltlimit, self.angles_x, autocvar_g_vehicle_tankiv_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_tankiv_tiltlimit, self.angles_z, autocvar_g_vehicle_tankiv_tiltlimit);

    if(player.BUTTON_JUMP) {
    	tankiv.gun00.angles_x = bound(autocvar_g_vehicle_tankiv_cannon_pitchlimit_down, tankiv.gun00.angles_x + (autocvar_g_vehicle_tankiv_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankiv_cannon_pitchlimit_up);
    }
    
    if(player.BUTTON_CROUCH ) {
    	tankiv.gun00.angles_x = bound(autocvar_g_vehicle_tankiv_cannon_pitchlimit_down, tankiv.gun00.angles_x - (autocvar_g_vehicle_tankiv_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankiv_cannon_pitchlimit_up);
    }
    
    player.BUTTON_CROUCH    = 0;

    tankiv_maxim_fire(tankiv, player, tankiv.gun0);
  
    if(player.BUTTON_ATCK2)
    {
        tankiv.cnt = time;
	if not(tankiv.gun00.count)
        if(tankiv.vehicle_ammo2 >= autocvar_g_vehicle_tankiv_cannon_ammo_cost && tankiv.tur_head.attack_finished_single <= time)
        {
            vector v;
            tankiv.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(tankiv.gun00, gettagindex(tankiv.gun00, "tag_cannon"));
            v_forward = normalize(v_forward);
            v += v_forward * 12;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankiv_cannon_spread, autocvar_g_vehicle_tankiv_cannon_speed, 5, autocvar_g_vehicle_tankiv_cannon_damage, autocvar_g_vehicle_tankiv_cannon_headshotaddeddamage, autocvar_g_vehicle_tankiv_cannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankiv_cannon_bulletconstant, autocvar_g_vehicle_tankiv_cannon_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 
	 
	 sound (tankiv.gun00, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);

	// End Ballistic bullet

            pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);


            self = tankiv;
	    
	    makevectors(self.angles);
	    v = gettaginfo(tankiv.gun00, gettagindex(tankiv.gun00, "tag_cannon"));
            v_forward = normalize(v_forward);
	    
	    tankiv_fire_cannon("tag_cannon");


            tankiv.vehicle_ammo2 -= autocvar_g_vehicle_tankiv_cannon_ammo_cost;
            tankiv.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankiv_cannon_refire;
            player.vehicle_ammo2 = (tankiv.vehicle_ammo2 / autocvar_g_vehicle_tankiv_cannon_ammo_max) * 100;
            
	    tankiv.count = 0; //Will have to press R to resume reload 
	    tankiv.gun00.count = 1; //Will have to press R to reload gun, not semiauto, old tank
        }
    }
    else
    {
    	if (tankiv.count == 1) {
        vehicles_regen(tankiv.cnt, vehicle_ammo2, autocvar_g_vehicle_tankiv_cannon_ammo_max,
                                           autocvar_g_vehicle_tankiv_cannon_ammo_regen_pause,
                                           autocvar_g_vehicle_tankiv_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		if (autocvar_g_casings >= 2)
		{
			if not(tankiv.count == 0 && tankiv.gun00.count == 0) {
				entity oldself2;
				
				oldself2 = self;
				self = player;
				//makevectors(self.angles);
				
				SpawnCasing (((random () * 5 + 5) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 + 70) * v_up), 2, 
				vectoangles(v_forward),'0 16 0', 100, 12, self);
				
				self = oldself2;
	    		}
		}
		tankiv.count = 1;
		sound (tankiv, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		tankiv.gun00.count = 0;
    	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 player ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(player, tankiv, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
	}
    }
    
    //tankiv_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(tankiv.dmg_time, vehicle_shield, autocvar_g_vehicle_tankiv_shield, autocvar_g_vehicle_tankiv_shield_regen_pause, autocvar_g_vehicle_tankiv_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(tankiv.dmg_time, vehicle_health, autocvar_g_vehicle_tankiv_health, autocvar_g_vehicle_tankiv_health_regen_pause, autocvar_g_vehicle_tankiv_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = tankiv.tur_head.frame;

    if(tankiv.gun00.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((tankiv.gun00.cnt - time) / tankiv.attack_finished_single) * 100;

    setorigin(player, tankiv.origin + '0 0 1' * TANKIV_MAX_z);
    tankiv.velocity = vehicles_tank_waterfriction(player, tankiv.velocity);
    player.velocity = tankiv.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, tankiv);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, tankiv);

    //VEHICLE_UPDATE_PLAYER2(player, ammo1_current, tankiv);
    //VEHICLE_UPDATE_PLAYER2(player, ammo1_max, tankiv);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_current, tankiv);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_max, tankiv);
    player.vehicle_ammo1_current = tankiv.vehicle_ammo1_current;
    player.vehicle_ammo1_max = tankiv.vehicle_ammo1_max;
    player.vehicle_ammo2_current = tankiv.vehicle_ammo2_current;
    player.vehicle_ammo2_max = tankiv.vehicle_ammo2_max;
    
    self = player;
    return 1;    
}
void tankiv_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_tankiv_speed_stop);

    self.nextthink = time;
    
    	//Added for multi
    	if(!self.owner)
	{
		entity oldself = self;		
		if(self.gunner1)
		{
			self = self.gunner1;
			oldself.gun1.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner2)
		{
			self = self.gunner2;
			oldself.gun2.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner3)
		{
			self = self.gunner3;
			oldself.gun3.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		if(self.gunner4)
		{
			self = self.gunner4;
			oldself.gun4.vehicle_exit(VHEF_EJECT);
			entity oldother = other;
			other = self;
			self = oldself;
			self.phase = 0;
			self.touch();
			other = oldother;
			return;
		}
		
		
	}
	//done for multi
}

void tankiv_enter()
{
    self.touch = tankiv_touch; //Add
    self.nextthink = 0;  //Add
    
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankiv_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankiv_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void tankiv_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = tankiv_think;
    self.touch = tankt27_vehicles_touch; //Added for multi
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 142 + '0 0 64';
	    spot = vehicles_findgoodexit2(spot, self.owner.origin, 200, MOVE_NORMAL);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_tankiv_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 168 + '0 0 64';
			spot = vehicles_findgoodexit2(spot, self.owner.origin, 200, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit2(spot, self.owner.origin, 200, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void tankiv_impact()
{
    if(autocvar_g_vehicle_tankiv_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_tankiv_bouncepain_x, autocvar_g_vehicle_tankiv_bouncepain_y, autocvar_g_vehicle_tankiv_bouncepain_z);    
}

void tankiv_headfade()
{
	self.think = tankiv_headfade;
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

void tankiv_blowup()
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
    b.lodmodel1 = "models/vehicles/tankiv_lod1.iqm";
    //b.lodmodel2 = "models/vehicles/tankiv_lod2.iqm";
    //b.lodmodel3 = "models/vehicles/tankiv_lod3.iqm";
    setmodel(b,  "models/vehicles/tankiv.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    setmodel(h,  "models/vehicles/tankt27_cannon.iqm");
    g1.lodmodel1 = "models/mountedguns/maximgun_lod1.iqm";
    g1.lodmodel2 = "models/mountedguns/maximgun_lod2.iqm";
    setmodel(g1, "models/mountedguns/maximgun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_tankiv_respawntime, 10);
    h.fade_time     = time;
    h.think         = tankiv_headfade;
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

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankiv_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankiv_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankiv_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankiv_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun0.alpha = self.gun1.alpha = self.gun2.alpha = self.gun3.alpha = self.gun4.alpha = self.gun00.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void tankiv_die()
{
	//Added for multi
	entity oldself = self;
		
	if(self.gunner1)
	{
		self = self.gunner1;
		oldself.gun1.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner2)
	{
		self = self.gunner2;
		oldself.gun2.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner3)
	{
		self = self.gunner3;
		oldself.gun3.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	if(self.gunner4)
	{
		self = self.gunner4;
		oldself.gun4.vehicle_exit(VHEF_EJECT);
		self = oldself;
	}
	
	self.vehicle_exit(VHEF_EJECT);
	
	//fixedmakevectors(self.angles);
	//vehicle_tossgib(self.gun1, self.velocity + v_right * 300 + v_up * 100 + randomvec() * 200, "cannon_right", rint(random()), rint(random()), 6, randomvec() * 200);

	//done for multi

    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = tankiv_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
    
    tankt27_hitbox_die(self.hitboxft);
    tankt27_hitbox_die(self.hitboxbk);
}

void tankiv_spawn(float _f)
{
    self.buff_wont_ignite = 1;
    self.vehicle_tankresists = 1;
    self.vehicle_pilotchangeseat = tankiv_gunner_enter; //Function to exec if pilot wants to change seat
    
    if(!self.gun0)
    {
    	self.loddistance1 = 512; //Lod0 Model somewhat complex, so only use when very close

    	self.lodmodel1 = "models/vehicles/tankiv_lod1.iqm";
	//self.lodmodel2 = "models/vehicles/tankiv_lod2.iqm";
	//self.lodmodel3 = "models/vehicles/tankiv_lod3.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
        self.gun0               = spawn();
        self.gun00               = spawn();
	self.gun1               = spawn();
	self.gun2               = spawn();
	self.gun3               = spawn();
	self.gun4               = spawn();
	
	self.gun0.owner = self;
	self.gun0.lodowner = 1; //Use owner origin for computing LOD
	self.gun0.lodmodel1 = "models/mountedguns/maximgun_lod1.iqm";
	self.gun0.lodmodel2 = "models/mountedguns/maximgun_lod2.iqm";
        setmodel(self.gun0, "models/mountedguns/maximgun.iqm");
	InitializeEntity(self.gun0, LODmodel_attach, INITPRIO_FINDTARGET);
        setmodel(self.gun00, "models/vehicles/tankt27_cannon.iqm");
        setattachment(self.gun0, self, "tag_gunpivot");
        setattachment(self.gun00, self, "tag_cannon_pivot");
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
	self.bomb1.gun2.scale = 2;
	
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
	self.bomb2.gun2.scale = 2;
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	
	//Added for multi
	//Add
	self.vehicle_flags |= VHF_MULTISLOT;
	setmodel(self.gun1, "null");
	self.gun1.ammount5 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin;
	self.gun1.owner = self;
	self.gun1.lodowner = 1; //Use owner origin for computing LOD
	self.gun1.lodmodel1 = "models/mountedguns/hotchkissm1914_lod1.iqm";
	self.gun1.lodmodel2 = "models/mountedguns/hotchkissm1914_lod2.iqm";
	self.gun1.lodmodel3 = "models/mountedguns/hotchkissm1914_lod3.iqm";
	self.gun1.lodmodel4 = "models/mountedguns/hotchkissm1914_lod4.iqm";
        setmodel(self.gun1, "models/mountedguns/hotchkissm1914.iqm");
	InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(self.gun1, self, "tag_gunpivot2");
	self.gun1.owner = self;
	//Done
	
	//Add More
	setmodel(self.gun2, "null");
	self.gun2.ammount5 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin;
	self.gun2.owner = self;
	self.gun2.lodowner = 1; //Use owner origin for computing LOD
	self.gun2.lodmodel1 = "models/mountedguns/hotchkissm1914_lod1.iqm";
	self.gun2.lodmodel2 = "models/mountedguns/hotchkissm1914_lod2.iqm";
	self.gun2.lodmodel3 = "models/mountedguns/hotchkissm1914_lod3.iqm";
	self.gun2.lodmodel4 = "models/mountedguns/hotchkissm1914_lod4.iqm";
        setmodel(self.gun2, "models/mountedguns/hotchkissm1914.iqm");
	InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(self.gun2, self, "tag_gunpivot3");
	self.gun2.owner = self;
	//Done
	//done for multi
	
	//Add More
	setmodel(self.gun3, "null");
	self.gun3.ammount5 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin;
	self.gun3.owner = self;
	self.gun3.lodowner = 1; //Use owner origin for computing LOD
	self.gun3.lodmodel1 = "models/mountedguns/hotchkissm1914_lod1.iqm";
	self.gun3.lodmodel2 = "models/mountedguns/hotchkissm1914_lod2.iqm";
	self.gun3.lodmodel3 = "models/mountedguns/hotchkissm1914_lod3.iqm";
	self.gun3.lodmodel4 = "models/mountedguns/hotchkissm1914_lod4.iqm";
        setmodel(self.gun3, "models/mountedguns/hotchkissm1914.iqm");
	InitializeEntity(self.gun3, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(self.gun3, self, "tag_gunpivot4");
	self.gun3.owner = self;
	//Done
	//done for multi
	
	//Add More
	setmodel(self.gun4, "null");
	self.gun4.ammount5 = autocvar_g_vehicle_mg_hotchkissm1914_machinegun_heatmin;
	self.gun4.owner = self;
	self.gun4.lodowner = 1; //Use owner origin for computing LOD
	self.gun4.lodmodel1 = "models/mountedguns/hotchkissm1914_lod1.iqm";
	self.gun4.lodmodel2 = "models/mountedguns/hotchkissm1914_lod2.iqm";
	self.gun4.lodmodel3 = "models/mountedguns/hotchkissm1914_lod3.iqm";
	self.gun4.lodmodel4 = "models/mountedguns/hotchkissm1914_lod4.iqm";
        setmodel(self.gun4, "models/mountedguns/hotchkissm1914.iqm");
	InitializeEntity(self.gun4, LODmodel_attach, INITPRIO_FINDTARGET);
        setattachment(self.gun4, self, "tag_gunpivot5");
	self.gun4.owner = self;
	//Done
	//done for multi
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun0, "tag_gcamera");
	setattachment(self.vehicle_viewport, self, "tag_camera");
	
	//Added for multi
	vehicle_addplayerslot(self, self.gun1, HUD_TANK, "null", tankiv_gunner_frame, tankiv_gunner_exit);
	vehicle_addplayerslot(self, self.gun2, HUD_TANK, "null", tankiv_gunner_frame, tankiv_gunner_exit);
	vehicle_addplayerslot(self, self.gun3, HUD_TANK, "null", tankiv_gunner_frame, tankiv_gunner_exit);
	vehicle_addplayerslot(self, self.gun4, HUD_TANK, "null", tankiv_gunner_frame, tankiv_gunner_exit);

	setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_camera");
	setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_camera");
	setattachment(self.gun3.vehicle_viewport, self.gun3, "tag_camera");
	setattachment(self.gun4.vehicle_viewport, self.gun4, "tag_camera");
	//done for multi
	
	self.hitboxbk = spawn();
	self.hitboxft = spawn();
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = tankiv_think;
    self.touch              = tankt27_vehicles_touch;
    self.subordinate        = self.hitboxbk; //For testing max_z in determining if should crush a player or monster
    self.subordinatespeed   = autocvar_g_vehicle_tankiv_speed_walk;
    self.subordinateinertia = autocvar_g_vehicle_tankiv_movement_inertia;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_tankiv_health;
    self.vehicle_shield     = autocvar_g_vehicle_tankiv_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun0.alpha = self.gun1.alpha = self.gun2.alpha = self.gun3.alpha = self.gun4.alpha = self.gun00.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun00.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = tankiv_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
    
    tankt27_spawn_hitbox(1, self, self.hitboxft, TANKIV_MIN_HBF, TANKIV_MAX_HBF, 100, autocvar_g_vehicle_tankiv_health);
    tankt27_spawn_hitbox(1, self, self.hitboxbk, TANKIV_MIN_HBB, TANKIV_MAX_HBB, -145, autocvar_g_vehicle_tankiv_health);
}

void spawnfunc_vehicle_tankiv()
{
    if(!autocvar_g_vehicle_tankiv)
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
    precache_model ( "models/vehicles/tankiv.iqm");
    precache_model ( "models/vehicles/tankiv_lod1.iqm");
    //precache_model ( "models/vehicles/tankt27_lod2.iqm");
    //precache_model ( "models/vehicles/tankt27_lod3.iqm");
    precache_model ( "models/mountedguns/maximgun.iqm");
    precache_model ( "models/mountedguns/maximgun_lod1.iqm");
    precache_model ( "models/mountedguns/maximgun_lod2.iqm");
    precache_model ( "models/mountedguns/hotchkissm1914.iqm");
    precache_model ( "models/mountedguns/hotchkissm1914_lod1.iqm");
    precache_model ( "models/mountedguns/hotchkissm1914_lod2.iqm");
    precache_model ( "models/mountedguns/hotchkissm1914_lod3.iqm");
    precache_model ( "models/mountedguns/hotchkissm1914_lod4.iqm");
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    precache_model ( "models/vehicles/tankt27_cannon.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/campingrifle_fire.wav" );
    precache_sound ( "weapons/grenade_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    
    precache_sound ( "vehicles/tankiv_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/tankiv_jump.wav");
    precache_sound ( "vehicles/tankiv_strafe.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "vehicles/tankiv_land.wav");

    if(autocvar_g_vehicle_tankiv_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_tankiv_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_tankiv_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "TankIV",
             "models/vehicles/tankiv.iqm",
             "null",
             "null",
             "", "tag_camera", "",
             HUD_TANK,
             TANKIV_MIN, TANKIV_MAX,
             FALSE,
             tankiv_spawn, autocvar_g_vehicle_tankiv_respawntime,
             tankiv_frame,
             tankiv_enter, tankiv_exit,
             tankiv_die,   tankiv_think,
             FALSE, 
             autocvar_g_vehicle_tankiv_health,
             autocvar_g_vehicle_tankiv_shield, autocolor, autocvar_g_vehicle_tankiv_machinegun_ammo_max * 10, autocvar_g_vehicle_tankiv_cannon_ammo_max * 3))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}
#endif // SVQC
