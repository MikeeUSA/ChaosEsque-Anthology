#define CHALLENGER_MIN '-120 -120 0'
#define CHALLENGER_MAX '120 120 100'

#ifdef SVQC
void challenger_exit(float eject);
void challenger_enter();

// Auto cvars
float autocvar_g_vehicle_challenger;
float autocvar_g_vehicle_challenger_mass;
float autocvar_g_vehicle_challenger_speed_afterburn;
float autocvar_g_vehicle_challenger_afterburn_cost;

float autocvar_g_vehicle_challenger_anglestabilizer;
float autocvar_g_vehicle_challenger_downforce;

float autocvar_g_vehicle_challenger_speed_forward;
float autocvar_g_vehicle_challenger_speed_strafe;
float autocvar_g_vehicle_challenger_springlength;
float autocvar_g_vehicle_challenger_upforcedamper;
float autocvar_g_vehicle_challenger_friction;

float autocvar_g_vehicle_challenger_hovertype;
float autocvar_g_vehicle_challenger_hoverpower;

float autocvar_g_vehicle_challenger_turnroll;
float autocvar_g_vehicle_challenger_turnspeed;
float autocvar_g_vehicle_challenger_pitchspeed;

float autocvar_g_vehicle_challenger_energy;
float autocvar_g_vehicle_challenger_energy_regen;
float autocvar_g_vehicle_challenger_energy_regen_pause;

float autocvar_g_vehicle_challenger_health;
float autocvar_g_vehicle_challenger_health_regen;
float autocvar_g_vehicle_challenger_health_regen_pause;

float autocvar_g_vehicle_challenger_shield;
float autocvar_g_vehicle_challenger_shield_regen;
float autocvar_g_vehicle_challenger_shield_regen_pause;

float autocvar_g_vehicle_challenger_cannon_cost;
float autocvar_g_vehicle_challenger_cannon_refire;

float autocvar_g_vehicle_challenger_cannon_spread;
float autocvar_g_vehicle_challenger_cannon_speed;
float autocvar_g_vehicle_challenger_cannon_damage; 
float autocvar_g_vehicle_challenger_cannon_headshotbonus; 
float autocvar_g_vehicle_challenger_cannon_force; 
float autocvar_g_vehicle_challenger_cannon_bulletconstant; 
float autocvar_g_vehicle_challenger_cannon_coreshotbonus;

float autocvar_g_vehicle_challenger_cannon_expelbulletcasings;

float autocvar_g_vehicle_challenger_rocket_accel;
float autocvar_g_vehicle_challenger_rocket_damage;
float autocvar_g_vehicle_challenger_rocket_radius;
float autocvar_g_vehicle_challenger_rocket_force;
float autocvar_g_vehicle_challenger_rocket_refire;
float autocvar_g_vehicle_challenger_rocket_speed;
float autocvar_g_vehicle_challenger_rocket_turnrate;

float autocvar_g_vehicle_challenger_rocket_locktarget;
float autocvar_g_vehicle_challenger_rocket_locking_time;
float autocvar_g_vehicle_challenger_rocket_locking_releasetime;
float autocvar_g_vehicle_challenger_rocket_locked_time;
float autocvar_g_vehicle_challenger_rocket_locked_maxangle;
float autocvar_g_vehicle_challenger_rocket_climbspeed;

float autocvar_g_vehicle_challenger_respawntime;

float autocvar_g_vehicle_challenger_blowup_radius;
float autocvar_g_vehicle_challenger_blowup_coredamage;
float autocvar_g_vehicle_challenger_blowup_edgedamage;
float autocvar_g_vehicle_challenger_blowup_forceintensity;

float autocvar_g_vehicle_challenger_bouncefactor;
float autocvar_g_vehicle_challenger_bouncestop;
vector autocvar_g_vehicle_challenger_bouncepain;

var vector challenger_force_from_tag(string tag_name, float spring_length, float max_power);
void challenger_spawn_default();

void challenger_align4point(float _delta)
{
    vector push_vector;
    float fl_push, fr_push, bl_push, br_push;

    push_vector  = challenger_force_from_tag("tag_engine_fr", autocvar_g_vehicle_challenger_springlength, autocvar_g_vehicle_challenger_hoverpower);
    fr_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_challenger_collision_multiplier);

    push_vector += challenger_force_from_tag("tag_engine_fl", autocvar_g_vehicle_challenger_springlength, autocvar_g_vehicle_challenger_hoverpower);
    fl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_challenger_collision_multiplier);

    push_vector += challenger_force_from_tag("tag_engine_br", autocvar_g_vehicle_challenger_springlength, autocvar_g_vehicle_challenger_hoverpower);
    br_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_challenger_collision_multiplier);

    push_vector += challenger_force_from_tag("tag_engine_bl", autocvar_g_vehicle_challenger_springlength, autocvar_g_vehicle_challenger_hoverpower);
    bl_push      = force_fromtag_normpower;
    //vehicles_sweap_collision(force_fromtag_origin, self.velocity, _delta, v_add, autocvar_g_vehicle_challenger_collision_multiplier);

   self.velocity += push_vector * _delta;

    // Anti ocilation
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_challenger_upforcedamper * _delta;

    push_vector_x =  (fl_push - bl_push);
    push_vector_x += (fr_push - br_push);
    push_vector_x *= 360;

    push_vector_z = (fr_push - fl_push);
    push_vector_z += (br_push - bl_push);
    push_vector_z *= 360;

    // Apply angle diffrance
    self.angles_z += push_vector_z * _delta;
    self.angles_x += push_vector_x * _delta;

    // Apply stabilizer
    self.angles_x *= 1 - (autocvar_g_vehicle_challenger_anglestabilizer * _delta);
    self.angles_z *= 1 - (autocvar_g_vehicle_challenger_anglestabilizer * _delta);
}

void challenger_AttachToShotorg(entity flash, vector offset, string tagname)
{
	entity xflash;
	flash.owner = self;
	flash.angles_z = random() * 360;


	setattachment(flash, self, tagname);
	setorigin(flash, offset);

	xflash = spawn();
	copyentity(flash, xflash);

	flash.viewmodelforclient = self;

	setattachment(xflash, self, tagname);
	setorigin(xflash, offset);
}

void challenger_hagar_explode (void)
{
	if(autocvar_g_balance_hagar_primary_failurerate &&
 	(autocvar_g_balance_hagar_primary_failurerate > random() ))
 	{
		//if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
		//	sprint(self.realowner, "A grenade of yours was a dud\n");
		//}
		//Spams client too much (many duds with this gun by default)
	} else {
	
	self.event_damage = func_null;
	RadiusDamage (self, self.realowner, autocvar_g_balance_hagar_primary_damage, autocvar_g_balance_hagar_primary_edgedamage, autocvar_g_balance_hagar_primary_radius, world, autocvar_g_balance_hagar_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	} //End To Dud or not to dud.
	
	remove (self);
}

void challenger_hagar_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	float is_linkexplode = ( ((inflictor.owner != world) ? (inflictor.owner == self.owner) : TRUE)
		&& (inflictor.projectiledeathtype & HITTYPE_SECONDARY) 
		&& (self.projectiledeathtype & HITTYPE_SECONDARY));
	
	if(is_linkexplode)
		is_linkexplode = (is_linkexplode && autocvar_g_balance_hagar_secondary_load_linkexplode);
	else
		is_linkexplode = -1; // not secondary load, so continue as normal without exception.

	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, is_linkexplode))
		return; // g_projectiles_damage says to halt

	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.think);
}

void challenger_hagar_touch (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void challenger_fire_hagar(string tagname)
{
	vector v;

  	v = gettaginfo(self, gettagindex(self, tagname));

	entity missile;

	W_SetupShot (self, FALSE, 2, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_hagar_primary_damage);

	pointparticles(particleeffectnum("hagar_muzzleflash"), v, v_forward * 1000, 1);

	missile = spawn ();

	//Got to be for newtonian physics to work
	missile.owner = self;
	missile.realowner = self.owner;

	missile.classname = "missile";
	missile.bot_dodge = TRUE;
	missile.bot_dodgerating = autocvar_g_balance_hagar_primary_damage;
	
	missile.takedamage = DAMAGE_YES;
	missile.health = autocvar_g_balance_hagar_primary_health;
	missile.damageforcescale = autocvar_g_balance_hagar_primary_damageforcescale;
	missile.event_damage = challenger_hagar_damage;
	missile.damagedbycontents = TRUE;
	
	missile.touch = challenger_hagar_touch;
	missile.use = challenger_hagar_explode;
	missile.think = adaptor_think2use_hittype_splash;
	missile.nextthink = time + autocvar_g_balance_hagar_primary_lifetime;
	PROJECTILE_MAKETRIGGER(missile);
	missile.projectiledeathtype = WEP_HAGAR;
	setorigin (missile, v);
	setsize(missile, '0 0 0', '0 0 0');
	
	//if(autocvar_g_balance_hagar_primary_launch_failurerate &&
 	//(autocvar_g_balance_hagar_primary_launch_failurerate > random() ))
 	//{
	//	missile.movetype = MOVETYPE_BOUNCE;
	//	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_primary_launchfailure);
	//	sprint(self, "Your hagar grenade was propelled by an insufficent impulse\n");
	//} else {
	missile.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(missile, g_balance_hagar_primary);
	//}

	missile.angles = vectoangles (missile.velocity);
	missile.flags = FL_PROJECTILE;

	CSQCProjectile(missile, TRUE, PROJECTILE_HAGAR, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}


void challenger_fire_cannon(string tagname)
{
    vector v;

    v = gettaginfo(self, gettagindex(self, tagname));
    
    fireBallisticBullet(v, v_forward, autocvar_g_vehicle_challenger_cannon_spread, autocvar_g_vehicle_challenger_cannon_speed, 5, autocvar_g_vehicle_challenger_cannon_damage, autocvar_g_vehicle_challenger_cannon_headshotbonus, autocvar_g_vehicle_challenger_cannon_force, DEATH_SPORTSTERGUN, 1, 1, autocvar_g_vehicle_challenger_cannon_bulletconstant, autocvar_g_vehicle_challenger_cannon_coreshotbonus);
    endFireBallisticBullet();
    
    sound (self, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);
    
    pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward * 2500, 1);
	    
    UziFlash();
    challenger_AttachToShotorg(self.muzzle_flash, '5 0 0', tagname);
    
    if (autocvar_g_vehicle_challenger_cannon_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 3, self);
	}
    }
    
}

void challenger_rocket_groundhugger()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if(self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;

    tracebox(self.origin, self.mins, self.maxs, self.origin + olddir * 64, MOVE_WORLDONLY,self);
    if(trace_fraction <= 0.5)
    {
        // Hitting somethign soon, just speed ahead
        self.velocity = olddir * newvel;
        UpdateCSQCProjectile(self);
        return;
    }

    traceline(trace_endpos, trace_endpos - '0 0 64', MOVE_NORMAL, self);
    if(trace_fraction != 1.0)
    {
        newdir = normalize(trace_endpos + '0 0 64' - self.origin) * autocvar_g_vehicle_challenger_rocket_turnrate;
        self.velocity = normalize(olddir + newdir) * newvel;
    }
    else
    {
        self.velocity = olddir * newvel;
        self.velocity_z -= 1600 * sys_frametime; // 2x grav looks better for this one
    }

    UpdateCSQCProjectile(self);
    return;
}

void challenger_rocket_tracker()
{
    vector olddir, newdir;
    float oldvel, newvel;

    self.nextthink  = time;

    if (self.owner.deadflag != DEAD_NO || self.cnt < time)
    {
        self.use();
        return;
    }

    if not (self.realowner.vehicle)
    {
        UpdateCSQCProjectile(self);
        return;
    }

    olddir = normalize(self.velocity);
    oldvel = vlen(self.velocity);
    newvel = oldvel + self.lip;
    makevectors(vectoangles(olddir));

	float time_to_impact = min(vlen(self.enemy.origin - self.origin) / vlen(self.velocity), 1);
	vector predicted_origin = self.enemy.origin + self.enemy.velocity * time_to_impact;

    traceline(self.origin, self.origin + v_forward * 64 - '0 0 32', MOVE_NORMAL, self);
    newdir = normalize(predicted_origin - self.origin);

    //vector
	float height_diff = predicted_origin_z - self.origin_z;

    if(vlen(newdir - v_forward) > autocvar_g_vehicle_challenger_rocket_locked_maxangle)
    {
        //bprint("Target lost!\n");
        //dprint("OF:", ftos(vlen(newdir - v_forward)), "\n");
        self.think = challenger_rocket_groundhugger;
        return;
    }

    if(trace_fraction != 1.0 && trace_ent != self.enemy)
        newdir_z += 16 * sys_frametime;

    self.velocity = normalize(olddir + newdir * autocvar_g_vehicle_challenger_rocket_turnrate) * newvel;
    self.velocity_z -= 800 * sys_frametime;
    self.velocity_z += max(height_diff, autocvar_g_vehicle_challenger_rocket_climbspeed) * sys_frametime ;

    UpdateCSQCProjectile(self);
    return;
}

void challenger_fire_rocket(string tagname, entity trg)
{
    vector v = gettaginfo(self, gettagindex(self, tagname));
    entity rocket = rocket = vehicles_projectile("wakizashi_rocket_launch", "weapons/rocket_fire.wav",
                           v, v_forward * autocvar_g_vehicle_challenger_rocket_speed,
                           autocvar_g_vehicle_challenger_rocket_damage, autocvar_g_vehicle_challenger_rocket_radius, autocvar_g_vehicle_challenger_rocket_force, 3,
                           WEP_ROCKET_LAUNCHER, PROJECTILE_ROCKET, 20, FALSE, FALSE, self.owner);

    rocket.lip              = autocvar_g_vehicle_challenger_rocket_accel * sys_frametime;
    rocket.wait             = autocvar_g_vehicle_challenger_rocket_turnrate;
    rocket.nextthink        = time;
    rocket.enemy            = trg;
    rocket.cnt              = time + 15;

    if(trg)
        rocket.think            = challenger_rocket_tracker;
    else
        rocket.think            = challenger_rocket_groundhugger;
}

float challenger_frame()
{
    entity player, challenger;
    vector df;
    float ftmp;

	if(intermission_running)
		return 1;

    player  = self;
    challenger   = self.vehicle;
    self    = challenger;

    player.BUTTON_ZOOM = player.BUTTON_CROUCH = 0;

    vehicles_painframe();

    if(challenger.deadflag != DEAD_NO)
    {
        self = player;
        player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
        return 1;
    }

    challenger_align4point(frametime);

    crosshair_trace(player);

    challenger.angles_x *= -1;

    // Yaw
    ftmp = autocvar_g_vehicle_challenger_turnspeed * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_y - challenger.angles_y, challenger.angles_y), ftmp);
    challenger.angles_y = anglemods(challenger.angles_y + ftmp);

    // Roll
    challenger.angles_z += -ftmp * autocvar_g_vehicle_challenger_turnroll * frametime;

    // Pitch
    ftmp = autocvar_g_vehicle_challenger_pitchspeed  * frametime;
    ftmp = bound(-ftmp, shortangle_f(player.v_angle_x - challenger.angles_x, challenger.angles_x), ftmp);
    challenger.angles_x = bound(-30, anglemods(challenger.angles_x + ftmp), 30);

    makevectors(challenger.angles);
    challenger.angles_x *= -1;

    //ftmp = challenger.velocity_z;
    df = challenger.velocity * -autocvar_g_vehicle_challenger_friction;
    //challenger.velocity_z = ftmp;

    if(vlen(player.movement) != 0)
    {
        if(player.movement_x)
            df += v_forward * ((player.movement_x > 0) ? autocvar_g_vehicle_challenger_speed_forward : -autocvar_g_vehicle_challenger_speed_forward);

        if(player.movement_y)
            df += v_right * ((player.movement_y > 0) ? autocvar_g_vehicle_challenger_speed_strafe : -autocvar_g_vehicle_challenger_speed_strafe);

        if(self.sound_nexttime < time || self.sounds != 1)
        {
            self.sounds = 1;
            self.sound_nexttime = time + 10.922667; //soundlength("vehicles/racer_move.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_move.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        if(self.sound_nexttime < time || self.sounds != 0)
        {
            self.sounds = 0;
            self.sound_nexttime = time + 11.888604; //soundlength("vehicles/racer_idle.wav");
            sound (self, CH_TRIGGER_SINGLE, "vehicles/racer_idle.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }

    // Afterburn
    if (player.BUTTON_JUMP && challenger.vehicle_energy >= (autocvar_g_vehicle_challenger_afterburn_cost * frametime))
    {
        if(time - challenger.wait > 0.2)
            pointparticles(particleeffectnum("wakizashi_booster_smoke"), self.origin - v_forward * 32, v_forward  * vlen(self.velocity), 1);

        challenger.wait = time;
        challenger.vehicle_energy -= autocvar_g_vehicle_challenger_afterburn_cost * frametime;
        df += (v_forward * autocvar_g_vehicle_challenger_speed_afterburn);

        if(challenger.invincible_finished < time)
        {
            traceline(challenger.origin, challenger.origin - '0 0 256', MOVE_NORMAL, self);
            if(trace_fraction != 1.0)
                pointparticles(particleeffectnum("smoke_small"), trace_endpos, '0 0 0', 1);

            challenger.invincible_finished = time + 0.1 + (random() * 0.1);
        }

        if(challenger.strength_finished < time)
        {
            challenger.strength_finished = time + 10.922667; //soundlength("vehicles/racer_boost.wav");
            sound (challenger.tur_head, CH_TRIGGER_SINGLE, "vehicles/racer_boost.wav", VOL_VEHICLEENGINE, ATTN_NORM);
        }
    }
    else
    {
        challenger.strength_finished = 0;
        sound (challenger.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);
    }

	df -= v_up * (vlen(challenger.velocity) * autocvar_g_vehicle_challenger_downforce);
	df = vehicles_waterspeed(player, df);
	challenger.velocity = vehicles_waterfriction(player, challenger, challenger.velocity);
    player.movement = challenger.velocity += df * frametime;

    if(player.BUTTON_ATCK)
    if(time > challenger.attack_finished_single)
    if(challenger.vehicle_ammo1 >= autocvar_g_vehicle_challenger_cannon_cost)
    {
        challenger.vehicle_ammo1 -= autocvar_g_vehicle_challenger_cannon_cost;
        challenger.wait = time;

        crosshair_trace(player);
        
            challenger_fire_hagar("tag_fire1");
	    challenger_fire_hagar("tag_fire2");
	    challenger_fire_hagar("tag_fire3");
	    challenger_fire_hagar("tag_fire4");
        
        challenger.attack_finished_single = time + autocvar_g_vehicle_challenger_cannon_refire;
        //self.owner.vehicle_ammo1 = challenger.vehicle_ammo1 / autocvar_g_vehicle_challenger_ammo1;
	challenger.count = 0; //Will have to press R to resume reload
    }
    
    if not(player.BUTTON_ATCK) {
    	if (challenger.count == 1) {
        	vehicles_regen(challenger.wait, vehicle_ammo1, autocvar_g_vehicle_challenger_energy, autocvar_g_vehicle_challenger_energy_regen_pause, autocvar_g_vehicle_challenger_energy_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		challenger.count = 1;
		sound (challenger, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //24 ammo, 1 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, challenger, ammo_rockets, vehicle_ammo1_current, vehicle_ammo1_max, 24, 1);
	}
    }

    if(autocvar_g_vehicle_challenger_rocket_locktarget)
    {
        vehicles_locktarget((1 / autocvar_g_vehicle_challenger_rocket_locking_time) * frametime,
                         (1 / autocvar_g_vehicle_challenger_rocket_locking_releasetime) * frametime,
                         autocvar_g_vehicle_challenger_rocket_locked_time);

        if(self.lock_target)
        {
            if(challenger.lock_strength == 1)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 0 0', 0);
            else if(self.lock_strength > 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 0.5 0', 0);
            else if(self.lock_strength < 0.5)
                UpdateAuxiliaryXhair(player, real_origin(self.lock_target), '1 1 0', 0);
        }
    }

    if(time > challenger.delay)
    if(player.BUTTON_ATCK2)
    if(player.vehicle_reload1 == 100)
    {
        challenger.misc_bulletcounter += 1;
        challenger.delay = time + 0.3;

        if(challenger.misc_bulletcounter == 1)
            challenger_fire_rocket("tag_rocket_r", (challenger.lock_strength == 1 && challenger.lock_target) ? challenger.lock_target : world);
        else if(challenger.misc_bulletcounter == 2)
        {
            challenger_fire_rocket("tag_rocket_l", (challenger.lock_strength == 1 && challenger.lock_target) ? challenger.lock_target : world);
            challenger.lock_strength  = 0;
            challenger.lock_target    = world;
            challenger.misc_bulletcounter = 0;

            challenger.delay = time + autocvar_g_vehicle_challenger_rocket_refire;
            challenger.lip = time;
        }
    }
    
    if (challenger.vehicle_ammo2_current > 0) {
	player.vehicle_reload1 = bound(0, 100 * ((time - challenger.lip) / (challenger.delay - challenger.lip)), 100);
	if (player.vehicle_reload1 < 100) {
		challenger.vehicle_ammo2_current = challenger.vehicle_ammo2_current - (1 * sys_frametime);
	}
    }

    if(challenger.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(challenger.dmg_time, vehicle_shield, autocvar_g_vehicle_challenger_shield, autocvar_g_vehicle_challenger_shield_regen_pause, autocvar_g_vehicle_challenger_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(challenger.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(challenger.dmg_time, vehicle_health, autocvar_g_vehicle_challenger_health, autocvar_g_vehicle_challenger_health_regen_pause, autocvar_g_vehicle_challenger_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    if(challenger.vehicle_flags  & VHF_ENERGYREGEN)
        vehicles_regen(challenger.wait, vehicle_energy, autocvar_g_vehicle_challenger_energy, autocvar_g_vehicle_challenger_energy_regen_pause, autocvar_g_vehicle_challenger_energy_regen, frametime, FALSE, vehicle_zero, vehicle_zero);


    VEHICLE_UPDATE_PLAYER(player, health, challenger);
    VEHICLE_UPDATE_PLAYER(player, energy, challenger);

    if(challenger.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, challenger);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    setorigin(player,challenger.origin + '0 0 32');
    player.velocity = challenger.velocity;

    player.vehicle_ammo1_current = challenger.vehicle_ammo1_current;
    player.vehicle_ammo1_max = challenger.vehicle_ammo1_max;
    player.vehicle_ammo2_current = challenger.vehicle_ammo2_current;
    player.vehicle_ammo2_max = challenger.vehicle_ammo2_max;
    player.vehicle_ammo1 = (challenger.vehicle_ammo1 / autocvar_g_vehicle_challenger_energy) * 100;

    self = player;
    return 1;
}

void challenger_think()
{
    self.nextthink = time;

    float pushdeltatime = time - self.lastpushtime;
    if (pushdeltatime > 0.15) pushdeltatime = 0;
    self.lastpushtime = time;
    if(!pushdeltatime) return;

    tracebox(self.origin, self.mins, self.maxs, self.origin - ('0 0 1' * autocvar_g_vehicle_challenger_springlength), MOVE_NORMAL, self);

    vector df = self.velocity * -autocvar_g_vehicle_challenger_friction;
	df_z += (1 - trace_fraction) * autocvar_g_vehicle_challenger_hoverpower + sin(time * 2) * (autocvar_g_vehicle_challenger_springlength * 2);

	self.velocity += df * pushdeltatime;
    if(self.velocity_z > 0)
        self.velocity_z *= 1 - autocvar_g_vehicle_challenger_upforcedamper * pushdeltatime;

    self.angles_x *= 1 - (autocvar_g_vehicle_challenger_anglestabilizer * pushdeltatime);
    self.angles_z *= 1 - (autocvar_g_vehicle_challenger_anglestabilizer * pushdeltatime);
}

void challenger_enter()
{
    self.movetype = MOVETYPE_BOUNCE;
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_challenger_health)  * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_challenger_shield)  * 100;

    if(self.owner.flagcarried)
       setorigin(self.owner.flagcarried, '-190 0 96');

	//targetdrone_spawn(self.origin + '0 0 512' + randomvec() * 256, 1);
}

void challenger_exit(float eject)
{
    vector spot;

    self.think      = challenger_think;
    self.nextthink  = time;
    self.movetype   = MOVETYPE_BOUNCE;
    sound (self.tur_head, CH_TRIGGER_SINGLE, "misc/null.wav", VOL_VEHICLEENGINE, ATTN_NORM);

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
		if(vlen(self.velocity) > 2 * autocvar_sv_maxairspeed)
		{
			self.owner.velocity = normalize(self.velocity) * autocvar_sv_maxairspeed * 2;
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 32 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin - v_forward * 200 + '0 0 32';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	antilag_clear(self.owner);
    self.owner = world;
}

void challenger_impact()
{
    if(autocvar_g_vehicle_challenger_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_challenger_bouncepain_x, autocvar_g_vehicle_challenger_bouncepain_y, autocvar_g_vehicle_challenger_bouncepain_z);
}

void challenger_blowup()
{
    self.deadflag    = DEAD_DEAD;
    self.vehicle_exit(VHEF_NORMAL);

    RadiusDamage (self, self.enemy, autocvar_g_vehicle_challenger_blowup_coredamage,
					autocvar_g_vehicle_challenger_blowup_edgedamage,
					autocvar_g_vehicle_challenger_blowup_radius, world,
					autocvar_g_vehicle_challenger_blowup_forceintensity,
					DEATH_WAKIBLOWUP, world);

    self.nextthink  = time + autocvar_g_vehicle_challenger_respawntime;
    self.think      = challenger_spawn_default;
    self.movetype   = MOVETYPE_NONE;
    self.effects    = EF_NODRAW;

    self.colormod  = '0 0 0';
    self.avelocity = '0 0 0';
    self.velocity  = '0 0 0';

    setorigin(self, self.pos1);
}

void challenger_deadtouch()
{
    self.avelocity_x *= 0.7;
    self.cnt -= 1;
    if(self.cnt <= 0)
        challenger_blowup();
}

void challenger_die()
{
    self.health       = 0;
    self.event_damage = func_null;
    self.solid        = SOLID_CORPSE;
    self.takedamage   = DAMAGE_NO;
    self.deadflag     = DEAD_DYING;
    self.movetype     = MOVETYPE_BOUNCE;
    self.wait         = time;
    self.cnt          = 1 + random() * 2;
    self.touch        = challenger_deadtouch;

    pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

    if(random() < 0.5)
        self.avelocity_z  = 32;
    else
        self.avelocity_z  = -32;

    self.avelocity_x = -vlen(self.velocity) * 0.2;
    self.velocity   += '0 0 700';
    self.colormod    = '-0.5 -0.5 -0.5';

	self.think     = challenger_blowup;
	self.nextthink = 2 + time + random() * 3;
}
void challenger_spawn(float _spawnflag)
{
    if(self.scale != 0.5)
    {
        if(autocvar_g_vehicle_challenger_hovertype != 0)
            challenger_force_from_tag = vehicles_force_fromtag_maglev;
        else
            challenger_force_from_tag = vehicles_force_fromtag_hover;

        // FIXME: this be hakkz, fix the models insted (scale body, add tag_viewport to the hudmodel).
        self.scale = 0.5;
        setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self, "tag_viewport");

        self.mass               = autocvar_g_vehicle_challenger_mass;
    }
    self.lodmodel1 = "models/vehicles/challenger_lod1.iqm";
    InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.think          = challenger_think;
    self.nextthink      = time;
    self.vehicle_health = autocvar_g_vehicle_challenger_health;
    self.vehicle_shield = autocvar_g_vehicle_challenger_shield;

    self.movetype       = MOVETYPE_TOSS;
    self.solid          = SOLID_SLIDEBOX;
    self.delay          = time;
    self.scale          = 0.5;

    setsize(self, CHALLENGER_MIN * 0.5, CHALLENGER_MAX * 0.5);
    self.bouncefactor = autocvar_g_vehicle_challenger_bouncefactor;
    self.bouncestop = autocvar_g_vehicle_challenger_bouncestop;
    self.vehicle_impact = challenger_impact;
    self.damageforcescale = 0.5;
    self.vehicle_hudmodel.colormap = self.vehicle.colormap;
    
    //self.destvec = autocvar_g_vehicle_challenger_bouncepain;
}
void challenger_spawn_default()
{
	challenger_spawn(0);
}



void spawnfunc_vehicle_challenger()
{
    if(!autocvar_g_vehicle_challenger)
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
    self.vehicle_flags |= VHF_DMGROLL;

    precache_sound ("weapons/rocket_fire.wav");
    precache_sound ("weapons/hagar_fire.wav");
    
    precache_sound ("vehicles/racer_idle.wav");
    precache_sound ("vehicles/racer_move.wav");
    precache_sound ("vehicles/racer_boost.wav");

    precache_model ("models/vhshield.md3");
    precache_model ("models/vehicles/challenger_exterior.iqm");
    precache_model ("models/vehicles/challenger_interior.iqm");
    precache_model ("models/vehicles/challenger_lod1.iqm");

    if(autocvar_g_vehicle_challenger_energy)
        if(autocvar_g_vehicle_challenger_energy_regen)
            self.vehicle_flags |= VHF_ENERGYREGEN;

    if(autocvar_g_vehicle_challenger_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_challenger_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_challenger_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;

	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;

    if not (vehicle_initialize(
             "Challenger",
             "models/vehicles/challenger_exterior.iqm",
             "null", // we need this so tur_head is networked and usable for sounds
             "models/vehicles/challenger_interior.iqm",
             "", "", "tag_viewport",
             HUD_WAKIZASHI,
             0.5 * CHALLENGER_MIN, 0.5 * CHALLENGER_MAX,
             FALSE,
             challenger_spawn, autocvar_g_vehicle_challenger_respawntime,
             challenger_frame,
             challenger_enter, challenger_exit,
             challenger_die,   challenger_think,
             TRUE, 
             autocvar_g_vehicle_challenger_health,
             autocvar_g_vehicle_challenger_shield, autocolor, autocvar_g_vehicle_challenger_energy * 4, autocvar_g_vehicle_challenger_rocket_refire * 2))
    {
        remove(self);
        return;
    }
}
#endif // SVQC
