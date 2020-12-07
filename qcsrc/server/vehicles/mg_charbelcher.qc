const vector MG_CHARBELCHER_MIN = '-20 -20 1';
const vector MG_CHARBELCHER_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_charbelcher;

float autocvar_g_vehicle_mg_charbelcher_respawntime;

float autocvar_g_vehicle_mg_charbelcher_speed_stop;
float autocvar_g_vehicle_mg_charbelcher_speed_strafe;
float autocvar_g_vehicle_mg_charbelcher_speed_walk;
float autocvar_g_vehicle_mg_charbelcher_movement_inertia;

float autocvar_g_vehicle_mg_charbelcher_springlength;
float autocvar_g_vehicle_mg_charbelcher_springup;
float autocvar_g_vehicle_mg_charbelcher_springblend;
float autocvar_g_vehicle_mg_charbelcher_tiltlimit;

float autocvar_g_vehicle_mg_charbelcher_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_charbelcher_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_charbelcher_gun_pitchspeed;
float autocvar_g_vehicle_mg_charbelcher_gun_turnlimit;
float autocvar_g_vehicle_mg_charbelcher_gun_turnspeed;

float autocvar_g_vehicle_mg_charbelcher_health;
float autocvar_g_vehicle_mg_charbelcher_health_regen;
float autocvar_g_vehicle_mg_charbelcher_health_regen_pause;

float autocvar_g_vehicle_mg_charbelcher_shield;
float autocvar_g_vehicle_mg_charbelcher_shield_regen;
float autocvar_g_vehicle_mg_charbelcher_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_charbelcher_bolt_speed;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_charbelcher_bolt_refire;
float autocvar_g_vehicle_mg_charbelcher_bolt_spread;
float autocvar_g_vehicle_mg_charbelcher_bolt_ammo_cost;
float autocvar_g_vehicle_mg_charbelcher_bolt_ammo_max;
float autocvar_g_vehicle_mg_charbelcher_bolt_ammo_reserve;
float autocvar_g_vehicle_mg_charbelcher_bolt_ammo_regen;
float autocvar_g_vehicle_mg_charbelcher_bolt_ammo_regen_pause;
float autocvar_g_vehicle_mg_charbelcher_bolt_speed;

vector autocvar_g_vehicle_mg_charbelcher_bouncepain;


void mg_charbelcher_exit(float eject);
void mg_charbelcher_enter();
void mg_charbelcher_spawn(float);

void mg_charbelcher_Firemine_Think()
{
	if(time > self.pushltime)
	{
		remove(self);
		return;
	}

	// make it "hot" once it leaves its owner
	if(self.owner)
	{
		if(vlen(self.origin - self.owner.origin - self.owner.view_ofs) > (autocvar_g_balance_fireball_secondary_laserradius * 1.6))
		{
			self.cnt += 1;
			if(self.cnt == 3)
				self.owner = world;
		}
		else
			self.cnt = 0;
	}

	W_Fireball_LaserPlay(0.1, (autocvar_g_balance_fireball_secondary_laserradius * 1.6), autocvar_g_balance_fireball_secondary_laserdamage, autocvar_g_balance_fireball_secondary_laseredgedamage, autocvar_g_balance_fireball_secondary_laserburntime);

	self.nextthink = time + 0.1;
}

void mg_charbelcher_Fireball_Explode (void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	//d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	//if(self.realowner.health + self.realowner.armorvalue >= d)
	//if(!self.cnt)
	//{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_fireball_primary_bfgradius, 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, autocvar_g_balance_fireball_primary_bfgradius); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / autocvar_g_balance_fireball_primary_bfgradius));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, autocvar_g_balance_fireball_primary_bfgdamage * points);

			Damage(e, self, self.realowner, autocvar_g_balance_fireball_primary_bfgdamage * points, self.projectiledeathtype | HITTYPE_BOUNCE | HITTYPE_SPLASH, e.origin + e.view_ofs, autocvar_g_balance_fireball_primary_bfgforce * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);
		}
	//}

	// We do not remove self. We continue to act as a mine remove (self);
}

void mg_charbelcher_Fireball_Attack2(entity player)
{
	entity proj;
	vector f_diff;
	float c;

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, self);
	w_shotorg = trace_endpos;

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = player;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + autocvar_g_balance_fireball_secondary_lifetime;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void mg_charbelcher_Flameburst1(entity player, entity myowner)
{
	entity proj;
	vector direction;
	direction = randomvec();
	direction_z = 0;
	
	w_shotorg = player.origin;
	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = myowner;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Flameburst1_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	
	W_SetupProjectileVelocityEx(proj, direction, v_up, autocvar_g_balance_fireball_primary_speed, 0, 0, 0.025, FALSE);
	
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Flameburst1_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}


void mg_charbelcher_Firemine_Touch (void)
{
	PROJECTILE_TOUCH;
	
	self.ammount = self.ammount + 1;
	
	if (other.classname == "tree" || other.classname == "bush") {
		Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
	}
	
	if (other.takedamage == DAMAGE_AIM)
	if(Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype | HITTYPE_HEADSHOT) >= 0)
	{
		mg_charbelcher_Fireball_Explode ();
	
		W_SetupShot(self, FALSE, FALSE, "weapons/fireball_fire.wav", CH_WEAPON_A, 0);
		makevectors(self.v_angle);
		mg_charbelcher_Flameburst1(self, self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Flameburst1(self, self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Flameburst1(self, self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Flameburst1(self, self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Flameburst1(self, self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Fireball_Attack2(self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Fireball_Attack2(self.realowner);
		makevectors(self.v_angle);
		mg_charbelcher_Fireball_Attack2(self.realowner);
		
		remove(self);
		return;
	}
	
	mg_charbelcher_Fireball_Explode ();
	
	if (self.ammount > 15) {
		//print("Removing self after many bounces\n");
		remove(self);
		return;
	} else if (self.ammount > 10) {
		//print("Reducing effects after some bounces\n");
		return;
	}
	
	W_SetupShot(self, FALSE, FALSE, "weapons/fireball_fire.wav", CH_WEAPON_A, 0);
	makevectors(self.v_angle);
	mg_charbelcher_Flameburst1(self, self.realowner);
	makevectors(self.v_angle);
	mg_charbelcher_Flameburst1(self, self.realowner);
	makevectors(self.v_angle);
	mg_charbelcher_Flameburst1(self, self.realowner);
	makevectors(self.v_angle);
	mg_charbelcher_Fireball_Attack2(self.realowner);
}


void fireCharbelcherBolt(entity player, vector start, vector dir, float spread, float pSpeed, float lifetime, float dtype)
{
	entity proj;
	
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));
	
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);

	proj = spawn ();
	proj.owner = proj.realowner = player;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = dtype;
	proj.touch = mg_charbelcher_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-16 -16 -16', '16 16 16');
	setorigin(proj, start);
	proj.think = mg_charbelcher_Firemine_Think;
	proj.nextthink = time + 0.1;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + lifetime;
	//W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);
	W_SetupProjectileVelocityEx(proj, dir, v_up, pSpeed, 0, 0, spread, antilagging);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_CHARBELCHER, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_charbelcher_aiframe()
{
    return FALSE;
}

void mg_charbelcher_checkmodel(entity mg_charbelcher, entity gunmount) 
{
    if(mg_charbelcher.vehicle_ammo1 >= autocvar_g_vehicle_mg_charbelcher_bolt_ammo_cost && gunmount.attack_finished_single <= time)
    {
    	if (mg_charbelcher.amnt != 1) {
		mg_charbelcher.amnt = 1;
    		//setmodel(gunmount,  "models/mountedguns/charbelcher_loaded.iqm");
		mg_charbelcher.bomb1.alpha = 1;
	}
    }
}

void mg_charbelcher_fire(entity mg_charbelcher, entity player, entity gunmount) 
{
	mg_charbelcher.cnt = time;
        if(mg_charbelcher.vehicle_ammo1 >= autocvar_g_vehicle_mg_charbelcher_bolt_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_charbelcher.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
            v += v_forward * 48;
	 
		if not (flintlock_powder_gets_wet(mg_charbelcher.origin)) {
		 fireCharbelcherBolt(player, v, v_forward, autocvar_g_vehicle_mg_charbelcher_bolt_spread, autocvar_g_vehicle_mg_charbelcher_bolt_speed, 40, WEP_FIREBALL);
	
	 
		 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
	         v_forward = normalize(v_forward);
		 v += v_forward * 5;
	 
		 pointparticles(particleeffectnum("fireball_muzzleflash"), v, v_forward, 1);

		 //sound (gunmount, CH_WEAPON_A, "resource/impact/Arrowimpwood_19.ogg", VOL_BASE, ATTN_NORM);
		}
	
	setmodel(gunmount,  "models/mountedguns/charbelcher.iqm");
	mg_charbelcher.amnt = 0;
	mg_charbelcher.bomb1.alpha = -1;
	
	 //Removed expell bullet casings stuff	

            self = mg_charbelcher;

            mg_charbelcher.vehicle_ammo1 -= autocvar_g_vehicle_mg_charbelcher_bolt_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_charbelcher_bolt_refire;
            player.vehicle_ammo1 = (mg_charbelcher.vehicle_ammo1 / autocvar_g_vehicle_mg_charbelcher_bolt_ammo_max) * 100;
        }
}

float mg_charbelcher_frame()
{
    vector ad;
    entity player, mg_charbelcher;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_charbelcher = self.vehicle;
    self   = mg_charbelcher;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_charbelcher.tur_head, gettagindex(mg_charbelcher.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_charbelcher);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_charbelcher.angles), AnglesTransform_FromAngles(ad))) - mg_charbelcher.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    if (self.spawnflags >= 16) {
    	ftmp = autocvar_g_vehicle_mg_charbelcher_gun_turnspeed * sys_frametime;    
    	ad_y = bound(-ftmp, ad_y, ftmp);
    	mg_charbelcher.tur_head.angles_y = bound(autocvar_g_vehicle_mg_charbelcher_gun_turnlimit * -1, mg_charbelcher.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_charbelcher_gun_turnlimit);
    
        // Pitch head
    ftmp = autocvar_g_vehicle_mg_charbelcher_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_charbelcher.tur_head.angles_x = bound(autocvar_g_vehicle_mg_charbelcher_gun_pitchlimit_down, mg_charbelcher.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_charbelcher_gun_pitchlimit_up);

    } else {

    	// Pitch head
    	ftmp = autocvar_g_vehicle_mg_charbelcher_gun_pitchspeed * sys_frametime;    
    	ad_x = bound(ftmp * -1, ad_x, ftmp);
    	mg_charbelcher.tur_head.angles_x = bound(-10, mg_charbelcher.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_charbelcher_gun_pitchlimit_up);
    }

    //fixedmakevectors(mg_charbelcher.angles);
    makevectors(mg_charbelcher.angles + '-2 0 0' * mg_charbelcher.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_charbelcher_springlength, autocvar_g_vehicle_mg_charbelcher_springup, autocvar_g_vehicle_mg_charbelcher_springblend, autocvar_g_vehicle_mg_charbelcher_tiltlimit);

    if(mg_charbelcher.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_charbelcher_speed_stop);
		setanim(player, player.anim_idle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_charbelcher.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_charbelcher, player, -600); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_charbelcher.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_charbelcher, player, autocvar_g_vehicle_mg_charbelcher_speed_walk, autocvar_g_vehicle_mg_charbelcher_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_charbelcher_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_charbelcher_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_charbelcher_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_charbelcher_tiltlimit);
    
    mg_charbelcher_checkmodel(mg_charbelcher, mg_charbelcher.tur_head);
    
    if(player.BUTTON_ATCK)
    {
    	if (time > mg_charbelcher.tanegashima_arrownextraincheck) {
    		if (CheckIfEntityIsInRainAdv(mg_charbelcher, MOVE_WORLDONLY) >= 10) {
			//Do nothing
		} else {
			mg_charbelcher_fire(mg_charbelcher, player, mg_charbelcher.tur_head);
		}
		
		mg_charbelcher.tanegashima_arrownextraincheck = time + 1; //So we don't flood 

		mg_charbelcher.count = 0; //Will have to press R to resume reload
	}
    } else {
    	if (mg_charbelcher.count == 1) {
        vehicles_regen(mg_charbelcher.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_charbelcher_bolt_ammo_max,
                                           autocvar_g_vehicle_mg_charbelcher_bolt_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_charbelcher_bolt_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		mg_charbelcher.count = 1;
		sound (mg_charbelcher, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		////Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		////vehicles_replenishAmmo(player, mg_charbelcher, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		//Reload from own stores //3 ammo, 3 player ammo = 3 vehic ammo,
		vehicles_replenishAmmo(player, mg_charbelcher, ammo_rockets, vehicle_ammo1_current, vehicle_ammo1_max, 3, 3);
	
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_charbelcher.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_charbelcher_shield, autocvar_g_vehicle_mg_charbelcher_shield_regen_pause, autocvar_g_vehicle_mg_charbelcher_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_charbelcher.dmg_time, vehicle_health, autocvar_g_vehicle_mg_charbelcher_health, autocvar_g_vehicle_mg_charbelcher_health_regen_pause, autocvar_g_vehicle_mg_charbelcher_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_charbelcher.origin + '0 0 1' * MG_CHARBELCHER_MAX_z);
    player.velocity = mg_charbelcher.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_charbelcher);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_charbelcher);

    player.vehicle_ammo1_current = mg_charbelcher.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_charbelcher.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_charbelcher_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_charbelcher_speed_stop);

    self.nextthink = time;
}

void mg_charbelcher_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_charbelcher_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_charbelcher_shield) * 100;

    mg_enter(self.owner);
    
    //We don't crouch for this weapon
    self.owner.crouch = FALSE;
    setsize(self.owner, PL_MIN,PL_MAX);
    setanim(self.owner, self.owner.anim_idle, TRUE, FALSE, FALSE);
}

void mg_charbelcher_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_charbelcher_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_charbelcher_speed_strafe)
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

void mg_charbelcher_impact()
{
    if(autocvar_g_vehicle_mg_charbelcher_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_charbelcher_bouncepain_x, autocvar_g_vehicle_mg_charbelcher_bouncepain_y, autocvar_g_vehicle_mg_charbelcher_bouncepain_z);    
}

void mg_charbelcher_headfade()
{
	self.think = mg_charbelcher_headfade;
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

void mg_charbelcher_blowup()
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
    b.scale = self.scale;
    h.scale = self.scale;

    setmodel(b,  "models/mountedguns/charbelcher_mount.iqm");
    h.lodmodel1 = "models/mountedguns/charbelcher_lod1.iqm";
    h.lodmodel2 = "models/mountedguns/charbelcher_lod2.iqm";
    setmodel(h,  "models/mountedguns/charbelcher.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_charbelcher_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_charbelcher_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_charbelcher_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_charbelcher_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.bomb1.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_charbelcher_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_charbelcher_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_charbelcher_spawn(float _f)
{
    //self.scale = 1.90;
    self.scale = 1.70;
    //self.scale = 1;
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();
	
	self.bomb1              = spawn(); 
	self.bomb1.scale = 1/self.scale; //Attached things are scaled to parent, so scale back down.
	self.bomb1.scale = self.bomb1.scale * 2;
	setattachment(self.bomb1, self.tur_head, "tag_mgun");
	self.bomb1.alpha = -1;
	self.bomb1.origin = '2 0 0';
	setorigin(self.bomb1, self.bomb1.origin);
	setmodel(self.bomb1,  "models/map_xoylent/asteroid.obj");
	
        self.gravity            = 2;
        self.mass               = 5000;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/charbelcher_lod1.iqm";
    self.tur_head.lodmodel2 = "models/mountedguns/charbelcher_lod2.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_charbelcher_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_charbelcher_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_charbelcher_shield;
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
    self.vehicle_impact = mg_charbelcher_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_charbelcher()
{
    if(!autocvar_g_vehicle_mg_charbelcher)
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
    	precache_model ( "models/mountedguns/charbelcher_mount.iqm");
    	bodymodel = "models/mountedguns/charbelcher_mount.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }

    mg_shield_precache();
    //precache_model ( "models/mountedguns/charbelcher_loaded.iqm");
    precache_model ( "models/mountedguns/charbelcher.iqm");
    precache_model ( "models/mountedguns/charbelcher_lod1.iqm");
    precache_model ( "models/mountedguns/charbelcher_lod2.iqm");
    precache_model ( "models/sphere/sphere.md3");
    precache_model ("models/map_xoylent/asteroid.obj");
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "weapons/fireball_fire.wav");
    precache_sound ( "weapons/fireball_fire2.wav");
    
    if(autocvar_g_vehicle_mg_charbelcher_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_charbelcher_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_charbelcher_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "CharMortar",
             bodymodel,
             "models/mountedguns/charbelcher.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_CHARBELCHER_MIN, MG_CHARBELCHER_MAX,
             FALSE,
             mg_charbelcher_spawn, autocvar_g_vehicle_mg_charbelcher_respawntime,
             mg_charbelcher_frame,
             mg_charbelcher_enter, mg_charbelcher_exit,
             mg_charbelcher_die,   mg_charbelcher_think,
             FALSE, 
             autocvar_g_vehicle_mg_charbelcher_health,
             autocvar_g_vehicle_mg_charbelcher_shield, 1, autocvar_g_vehicle_mg_charbelcher_bolt_ammo_max * autocvar_g_vehicle_mg_charbelcher_bolt_ammo_reserve, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

