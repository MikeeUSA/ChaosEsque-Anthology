const vector MG_DELUGE_MIN = '-20 -20 1';
const vector MG_DELUGE_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_deluge;

float autocvar_g_vehicle_mg_deluge_respawntime;

float autocvar_g_vehicle_mg_deluge_speed_stop;
float autocvar_g_vehicle_mg_deluge_speed_strafe;
float autocvar_g_vehicle_mg_deluge_speed_walk;
float autocvar_g_vehicle_mg_deluge_movement_inertia;

float autocvar_g_vehicle_mg_deluge_springlength;
float autocvar_g_vehicle_mg_deluge_springup;
float autocvar_g_vehicle_mg_deluge_springblend;
float autocvar_g_vehicle_mg_deluge_tiltlimit;

float autocvar_g_vehicle_mg_deluge_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_deluge_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_deluge_gun_pitchspeed;
float autocvar_g_vehicle_mg_deluge_gun_turnlimit;
float autocvar_g_vehicle_mg_deluge_gun_turnspeed;

float autocvar_g_vehicle_mg_deluge_health;
float autocvar_g_vehicle_mg_deluge_health_regen;
float autocvar_g_vehicle_mg_deluge_health_regen_pause;

float autocvar_g_vehicle_mg_deluge_shield;
float autocvar_g_vehicle_mg_deluge_shield_regen;
float autocvar_g_vehicle_mg_deluge_shield_regen_pause;

float autocvar_g_vehicle_mg_deluge_cannon_radius;
float autocvar_g_vehicle_mg_deluge_cannon_force;
float autocvar_g_vehicle_mg_deluge_machinegun_damage;
float autocvar_g_vehicle_mg_deluge_machinegun_edgedamage;
float autocvar_g_vehicle_mg_deluge_machinegun_refire;
float autocvar_g_vehicle_mg_deluge_machinegun_ammo_cost;
float autocvar_g_vehicle_mg_deluge_machinegun_ammo_max;
float autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen;
float autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen_pause;

vector autocvar_g_vehicle_mg_deluge_bouncepain;


void mg_deluge_exit(float eject);
void mg_deluge_enter();
void mg_deluge_spawn(float);
.entity deluge_filth_ent;

float mg_deluge_aiframe()
{
    return FALSE;
}

void mg_deluge_Water_Explode (void)
{
	local float cleanmultip;
	
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;
	
	if (other != world) {
	  if (self.amnt == 1) {
	  	//OIL
		other.fire_oilfire_entwasinoil = 1;
	  } else if (self.amnt == 2) {
	  	//Methane
	  } else if (self.amnt == 5) { 
	  	//Lava
		//Fire_AddDamage(other, self.realowner, autocvar_g_balance_contents_playerdamage_lava_ignite*autocvar_g_balance_contents_playerdamage_lava_ignite_time, autocvar_g_balance_contents_playerdamage_lava_ignite_time, DEATH_FIRE);
		if (other.takedamage == DAMAGE_AIM
		&& !other.accptcrssbwstklkbld)
		{
				Fire_AddDamage(other, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, self.projectiledeathtype);
		} else if (other.classname == "tree" || other.classname == "bush"
		|| isPlayerOrMonsterByClassname(other)) {
			//Fallback
			Fire_AddDamage(other, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, self.projectiledeathtype);
		} else if (other.classname == "building" && other.multitool_hitbox != world) {
				if ((random() > 0.5) && multitool_iswooden(other.multitool_hitbox.count)) {
					Fire_AddDamage(other.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
				}
		} else if (other.accptcrssbwstklkbld) {
			if (other.multitool_doorframeent && other.multitool_doorframeent.multitool_hitbox != world) {
				if ((random() > 0.5) && multitool_iswooden(other.multitool_doorframeent.multitool_hitbox.count)) {
					Fire_AddDamage(other.multitool_doorframeent.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
				}
			}
		}
		//print("Fire\n");
		
		Damage (other, self.realowner, self.realowner, autocvar_g_balance_contents_playerdamage_lava * autocvar_g_balance_contents_damagerate, DEATH_LAVA, self.origin, '0 0 0');
	  } else {
	  	//Water (0), Chemical and Slime
		
		if (self.amnt == 3 || self.amnt == 4) { cleanmultip = 100; } //Really cleans you up well
		else { cleanmultip = 1; }
	  
		if (other.fire_endtime > time) {
			other.fire_endtime = other.fire_endtime * 0.9;
			//print("fire\n");
		}
	
		if (other.multitool_hitbox) { //Quick check first
			if (other.classname == "building") { //Then make sure
				//The building model doesn't burn, the hitbox does (wooden ones atleast)
				if (other.multitool_hitbox.fire_endtime > time) {
					other.multitool_hitbox.fire_endtime = other.multitool_hitbox.fire_endtime * 0.9;
				}
			}
		}
	
		if (PlayerIsInOil(other)) {
			//Do nothing
		} else if (self.amnt == 6) {
			//No cleaning
			//Filth
			if(self.deluge_filth_ent && self.deluge_filth_ent != world) {
				local float myoldwaterlevel, myoldwatertype;
				myoldwaterlevel = other.waterlevel;
				myoldwatertype = other.watertype;
					other.watertype = CONTENT_WATER;
					other.waterlevel = WATERLEVEL_SUBMERGED; //Soaked
					TransferSmells (other, self.deluge_filth_ent);
				other.waterlevel = myoldwaterlevel; //Reset
				other.watertype = myoldwatertype; //Reset
			}
		} else {
			//Clean player
			if (other.fire_oilfire_entwasinoil) other.fire_oilfire_entwasinoil = bound(0, other.fire_oilfire_entwasinoil - (0.34 * cleanmultip), 10000);
			if (other.fire_oilfire_entreignite) other.fire_oilfire_entreignite = bound(0, other.fire_oilfire_entreignite - (0.34 * cleanmultip), 10000);
		}
		
		if (self.amnt == 4) {
			//Extra DMG for Slime
			Damage (other, self.realowner, self.realowner, autocvar_g_balance_contents_playerdamage_slime * autocvar_g_balance_contents_damagerate, DEATH_SLIME, self.origin, '0 0 0');
		}
	 }
	}
	
	RadiusDamage (self, self.realowner, autocvar_g_vehicle_mg_deluge_machinegun_damage, autocvar_g_vehicle_mg_deluge_machinegun_edgedamage, autocvar_g_vehicle_mg_deluge_cannon_radius, world, autocvar_g_vehicle_mg_deluge_cannon_force, self.projectiledeathtype, other);

	remove (self);
}

void mg_deluge_Water_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	mg_deluge_Water_Explode ();
}

void mg_deluge_Water_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
}


void mg_deluge_attack(string tagname, entity spigot, float myspeed, float mydelugetype)
{
	vector v;
	if (myspeed) {
		v = spigot.origin;
	} else {
	v = gettaginfo(spigot, gettagindex(spigot, tagname));
	v_forward = normalize(v_forward);
	}
	
	entity proj;

	

	if (mydelugetype == 1) {
		//print("Oil\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("tar_TR_BLOOD"), v, w_shotdir * 1000, 1);
	} else if (mydelugetype == 2) {
		//print("Methane\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "machines/steam_fade.ogg", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("deluge_muzzleflash"), v, w_shotdir * 1000, 1);
	} else if (mydelugetype == 3) {
		//print("Chem\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "machines/steam_fade.ogg", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("robot_TR_BLOOD"), v, w_shotdir * 1000, 1);
	} else if (mydelugetype == 4) {
		//print("Slime\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "machines/steam_fade.ogg", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("alien_TR_BLOOD"), v, w_shotdir * 1000, 1);
	} else if (mydelugetype == 5) {
		//print("Lava\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("fireball_muzzleflash"), v, w_shotdir * 1000, 1);
	} else if (mydelugetype == 6) {
		//print("Filth\n");
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("insect_TR_SLIGHTBLOOD"), v, w_shotdir * 1000, 1);
	} else {
		W_SetupShot_ProjectileSize (self, '0 0 -1', '0 0 -1', FALSE, 2, "machines/steam_fade.ogg", CH_WEAPON_A, autocvar_g_balance_electro_secondary_damage);
		w_shotdir = v_forward; // no TrueAim for grenades please
		pointparticles(particleeffectnum("deluge_muzzleflash"), v, w_shotdir * 1000, 1);
	}
	
	proj = spawn ();
	proj.amnt = mydelugetype;
	proj.classname = "water";
	//proj.owner = proj.realowner = self;
	proj.owner = self;
	proj.realowner = self.owner;
	proj.use = mg_deluge_Water_Explode;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_vehicle_mg_deluge_machinegun_damage;
	proj.nextthink = time + autocvar_g_balance_electro_secondary_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_DROWN;
	setorigin(proj, v);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	if (myspeed) {
		W_SetupProjectileVelocityEx(proj, w_shotdir, v_up, myspeed, 0, 0, 0.03, FALSE);
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(proj, g_vehicle_mg_deluge_water);
	}
	proj.touch = mg_deluge_Water_TouchExplode;
	setsize(proj, '0 0 -1', '0 0 -1');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_electro_secondary_damageforcescale;
	proj.health = autocvar_g_balance_electro_secondary_health;
	proj.event_damage = mg_deluge_Water_Damage;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = (autocvar_g_balance_electro_secondary_damagedbycontents);

	proj.bouncefactor = autocvar_g_balance_electro_secondary_bouncefactor;
	proj.bouncestop = autocvar_g_balance_electro_secondary_bouncestop;
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

#if 0
	entity p2;
	p2 = spawn();
	copyentity(proj, p2);
	setmodel(p2, "models/ebomb.mdl");
	setsize(p2, proj.mins, proj.maxs);
#endif
	
	if (mydelugetype == 1) {
		//print("Oil\n");
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGEOIL, FALSE); // no culling, it has sound
	} else if (mydelugetype == 2) {
		//print("Methane\n");
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGEMETHANE, FALSE); // no culling, it has sound
	} else if (mydelugetype == 3) {
		//print("Chem\n");
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGECHEM, FALSE); // no culling, it has sound
	} else if (mydelugetype == 4) {
		//print("Slime\n");
		proj.projectiledeathtype = DEATH_SLIME;
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGESLIME, FALSE); // no culling, it has sound
	} else if (mydelugetype == 5) {
		//print("Lava\n");
		proj.projectiledeathtype = DEATH_LAVA;
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGELAVA, FALSE); // no culling, it has sound
	} else if (mydelugetype == 6) {
		//print("Filth\n");
		proj.deluge_filth_ent = self.deluge_filth_ent;
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGEFILTH, FALSE); // no culling, it has sound
	} else {
		CSQCProjectile(proj, TRUE, PROJECTILE_DELUGE, FALSE); // no culling, it has sound
	}

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_deluge_delugetype_isinlava(entity player)
{

		local vector mypcvec;
	
		mypcvec = player.origin;
	 	if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z - 10;
	 	if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z - 20;
	 	if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z + player.mins_z;
	 	if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.maxs_x + 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.mins_x - 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.maxs_x + 1;
		mypcvec_y = mypcvec_y + player.maxs_y + 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.mins_x - 1;
		mypcvec_y = mypcvec_y + player.mins_y - 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_LAVA) {
			return TRUE;
		}
		
		return FALSE;
}

float mg_deluge_delugetype_isinslime(entity player)
{

		local vector mypcvec;
		
		mypcvec = player.origin;
	 	if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z - 10;
	 	if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z - 20;
	 	if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z + player.mins_z;
	 	if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.maxs_x + 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
				
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.mins_x - 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.maxs_x + 1;
		mypcvec_y = mypcvec_y + player.maxs_y + 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		mypcvec = player.origin;
		mypcvec_x = mypcvec_x + player.mins_x - 1;
		mypcvec_y = mypcvec_y + player.mins_y - 1;
		mypcvec_z = mypcvec_z + player.mins_z + 1;
		
		if (pointcontents (mypcvec) == CONTENT_SLIME) {
			return TRUE;
		}
		
		return FALSE;
}

float mg_deluge_delugetype_ext(entity player, float mydelugetype) {
	//Extended options, called by mg_deluge_delugetype to support map-set areas of this type
	//Thus you can create water areas in a map, texture it with the appropriate texture, and
	//place trigger_chemreactarea around it and have the correct delugegun effect occur
	if (PlayerIsInOilReactArea(player)) {
		mydelugetype = 1; //Oil
	} else if (PlayerIsInMethaneReactArea(player)) {
		mydelugetype = 2; //Methane
	} else if (PlayerIsInChemReactArea(player)) {
		mydelugetype = 3; //Chem
	}
	
	return mydelugetype;
}

float mg_deluge_delugetype(entity player) {
	local float mydelugetype;
	mydelugetype = 0;
	player.deluge_filth_ent = world;
	
	if (PlayerIsInOil(player)) {
		mydelugetype = 1; //Oil
	} else if (PlayerIsInMethane(player)) {
		mydelugetype = 2; //Methane
	} else if (PlayerIsInChem(player)) {
		mydelugetype = 3; //Chem
	} else if (player.watertype == CONTENT_SLIME) {
		mydelugetype = 4; //Slime
		mydelugetype = mg_deluge_delugetype_ext(player, mydelugetype); //Extended options
	} else if (player.watertype == CONTENT_LAVA) {
		mydelugetype = 5; //Lava
		mydelugetype = mg_deluge_delugetype_ext(player, mydelugetype); //Extended options
	} else if (mg_deluge_delugetype_isinslime(player)) {
		mydelugetype = 4; //Slime
	} else if (mg_deluge_delugetype_isinlava(player)) {
		mydelugetype = 5; //Lava
	} else {
		local entity testentf;
		testentf = PlayerIsInFilth(player);
		if (testentf.smell_faeces) {
			mydelugetype = 6; //Filth
			player.deluge_filth_ent = testentf;
		} else {
			mydelugetype = mg_deluge_delugetype_ext(player, mydelugetype); //Extended options
		}
	}
		
	
	return mydelugetype;
}

void mg_deluge_fire(entity mg_deluge, entity player, entity gunmount) 
{
	mg_deluge.cnt = time;
        if(
	((mg_deluge.vehicle_ammo1 >= autocvar_g_vehicle_mg_deluge_machinegun_ammo_cost)
	|| (player.waterlevel < 0))	
	&& gunmount.attack_finished_single <= time)
        {
            mg_deluge.misc_bulletcounter += 1;

            self = player;
	    
	    mg_deluge_attack("tag_mgun", gunmount, 0, mg_deluge_delugetype(player));
	    self.deluge_filth_ent = world; //Reset
	    
            self = mg_deluge;

	    if not(player.waterlevel > 0) {
            	mg_deluge.vehicle_ammo1 -= autocvar_g_vehicle_mg_deluge_machinegun_ammo_cost;
	    }
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_deluge_machinegun_refire;
            player.vehicle_ammo1 = (mg_deluge.vehicle_ammo1 / autocvar_g_vehicle_mg_deluge_machinegun_ammo_max) * 100;
         
        }
}

float mg_deluge_frame()
{
    vector ad;
    entity player, mg_deluge;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_deluge = self.vehicle;
    self   = mg_deluge;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_deluge.tur_head, gettagindex(mg_deluge.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_deluge);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_deluge.angles), AnglesTransform_FromAngles(ad))) - mg_deluge.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_deluge_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_deluge.tur_head.angles_y = bound(autocvar_g_vehicle_mg_deluge_gun_turnlimit * -1, mg_deluge.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_deluge_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_deluge_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_deluge.tur_head.angles_x = bound(autocvar_g_vehicle_mg_deluge_gun_pitchlimit_down, mg_deluge.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_deluge_gun_pitchlimit_up);


    //fixedmakevectors(mg_deluge.angles);
    makevectors(mg_deluge.angles + '-2 0 0' * mg_deluge.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_deluge_springlength, autocvar_g_vehicle_mg_deluge_springup, autocvar_g_vehicle_mg_deluge_springblend, autocvar_g_vehicle_mg_deluge_tiltlimit);

    if(mg_deluge.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_deluge_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_deluge.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_deluge, player, -200); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_deluge.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_deluge, player, autocvar_g_vehicle_mg_deluge_speed_walk, autocvar_g_vehicle_mg_deluge_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_deluge_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_deluge_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_deluge_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_deluge_tiltlimit);
    
    
    if(player.BUTTON_ATCK)
    {
        mg_deluge_fire(mg_deluge, player, mg_deluge.tur_head);
    } else {
        vehicles_regen(mg_deluge.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_deluge_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_deluge_machinegun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_deluge.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_deluge_shield, autocvar_g_vehicle_mg_deluge_shield_regen_pause, autocvar_g_vehicle_mg_deluge_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_deluge.dmg_time, vehicle_health, autocvar_g_vehicle_mg_deluge_health, autocvar_g_vehicle_mg_deluge_health_regen_pause, autocvar_g_vehicle_mg_deluge_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_deluge.origin + '0 0 1' * MG_DELUGE_MAX_z);
    player.velocity = mg_deluge.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_deluge);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_deluge);

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_deluge_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_deluge_speed_stop);

    self.nextthink = time;
}

void mg_deluge_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_deluge_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_deluge_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_deluge_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_deluge_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_deluge_speed_strafe)
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

void mg_deluge_impact()
{
    if(autocvar_g_vehicle_mg_deluge_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_deluge_bouncepain_x, autocvar_g_vehicle_mg_deluge_bouncepain_y, autocvar_g_vehicle_mg_deluge_bouncepain_z);    
}

void mg_deluge_headfade()
{
	self.think = mg_deluge_headfade;
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

void mg_deluge_blowup()
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
    h.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
    setmodel(h,  "models/mountedguns/delugegun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_deluge_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_deluge_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_deluge_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_deluge_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_deluge_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_deluge_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_deluge_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        
        self.gravity            = 1;
        self.mass               = 150;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
	
	self.tur_head.colormap = 1228; //Yellow
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/delugegun_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/delugegun_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_deluge_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_deluge_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_deluge_shield;
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
    self.vehicle_impact = mg_deluge_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_deluge()
{
    if(!autocvar_g_vehicle_mg_deluge)
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
    precache_model ( "models/mountedguns/delugegun.iqm");
    precache_model ( "models/mountedguns/delugegun_lod1.iqm");
    precache_model ( "models/mountedguns/delugegun_lod2.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "machines/steam_fade.ogg" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_deluge_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_deluge_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_deluge_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "DelugeGun",
             bodymodel,
             "models/mountedguns/delugegun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_DELUGE_MIN, MG_DELUGE_MAX,
             FALSE,
             mg_deluge_spawn, autocvar_g_vehicle_mg_deluge_respawntime,
             mg_deluge_frame,
             mg_deluge_enter, mg_deluge_exit,
             mg_deluge_die,   mg_deluge_think,
             FALSE, 
             autocvar_g_vehicle_mg_deluge_health,
             autocvar_g_vehicle_mg_deluge_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

