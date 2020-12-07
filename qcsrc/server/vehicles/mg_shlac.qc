const vector MG_SHLAC_MIN = '-20 -20 1';
const vector MG_SHLAC_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_shlac;

float autocvar_g_vehicle_mg_shlac_respawntime;

float autocvar_g_vehicle_mg_shlac_speed_stop;
float autocvar_g_vehicle_mg_shlac_speed_strafe;
float autocvar_g_vehicle_mg_shlac_speed_walk;
float autocvar_g_vehicle_mg_shlac_movement_inertia;

float autocvar_g_vehicle_mg_shlac_springlength;
float autocvar_g_vehicle_mg_shlac_springup;
float autocvar_g_vehicle_mg_shlac_springblend;
float autocvar_g_vehicle_mg_shlac_tiltlimit;

float autocvar_g_vehicle_mg_shlac_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_shlac_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_shlac_gun_pitchspeed;
float autocvar_g_vehicle_mg_shlac_gun_turnlimit;
float autocvar_g_vehicle_mg_shlac_gun_turnspeed;

float autocvar_g_vehicle_mg_shlac_health;
float autocvar_g_vehicle_mg_shlac_health_regen;
float autocvar_g_vehicle_mg_shlac_health_regen_pause;

float autocvar_g_vehicle_mg_shlac_shield;
float autocvar_g_vehicle_mg_shlac_shield_regen;
float autocvar_g_vehicle_mg_shlac_shield_regen_pause;

float autocvar_g_vehicle_mg_shlac_railgun_refire;
float autocvar_g_vehicle_mg_shlac_railgun_ammo_cost;
float autocvar_g_vehicle_mg_shlac_railgun_ammo_max;
float autocvar_g_vehicle_mg_shlac_railgun_ammo_regen;
float autocvar_g_vehicle_mg_shlac_railgun_ammo_regen_pause;

vector autocvar_g_vehicle_mg_shlac_bouncepain;


void mg_shlac_exit(float eject);
void mg_shlac_enter();
void mg_shlac_spawn(float);

void mg_shlac_attack(string tagname, entity fireentity)
{
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	
	entity missile;
    float spread;

    spread = autocvar_g_balance_hlac_primary_spread_min * 0.1;

	W_SetupShot (self, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_A, autocvar_g_balance_hlac_primary_damage);
	pointparticles(particleeffectnum("laser_muzzleflash"), v, v_forward * 1000, 1);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	missile = spawn ();
	//missile.owner = missile.realowner = self;
	missile.owner = self;
	missile.realowner = self.owner;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = autocvar_g_balance_hlac_primary_damage;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, v);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocity(missile, autocvar_g_balance_hlac_primary_speed, spread);
	//missile.angles = vectoangles (missile.velocity); // csqc

	missile.touch = W_HLAC_Touch;
	missile.think = SUB_Remove;

    missile.nextthink = time + autocvar_g_balance_hlac_primary_lifetime;

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = WEP_HLAC;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_shlac_aiframe()
{
    return FALSE;
}

void mg_shlac_fire(entity mg_shlac, entity player, entity gunmount) 
{
	mg_shlac.cnt = time;
        if(mg_shlac.vehicle_ammo1 >= autocvar_g_vehicle_mg_shlac_railgun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_shlac.misc_bulletcounter += 1;

	    self = mg_shlac;
	    
	    makevectors(self.angles);
	    v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun1"));
            v_forward = normalize(v_forward);
	
		mg_shlac_attack("tag_mgun1", gunmount);
		mg_shlac_attack("tag_mgun2", gunmount);
		mg_shlac_attack("tag_mgun3", gunmount);
		mg_shlac_attack("tag_mgun4", gunmount);
		mg_shlac_attack("tag_mgun5", gunmount);

            self = mg_shlac;

            mg_shlac.vehicle_ammo1 -= autocvar_g_vehicle_mg_shlac_railgun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_shlac_railgun_refire;
            player.vehicle_ammo1 = (mg_shlac.vehicle_ammo1 / autocvar_g_vehicle_mg_shlac_railgun_ammo_max) * 100;
         
        }
}

float mg_shlac_frame()
{
    vector ad;
    entity player, mg_shlac;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_shlac = self.vehicle;
    self   = mg_shlac;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_shlac.tur_head, gettagindex(mg_shlac.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_shlac);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_shlac.angles), AnglesTransform_FromAngles(ad))) - mg_shlac.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_shlac_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_shlac.tur_head.angles_y = bound(autocvar_g_vehicle_mg_shlac_gun_turnlimit * -1, mg_shlac.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_shlac_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_shlac_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_shlac.tur_head.angles_x = bound(autocvar_g_vehicle_mg_shlac_gun_pitchlimit_down, mg_shlac.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_shlac_gun_pitchlimit_up);


    //fixedmakevectors(mg_shlac.angles);
    makevectors(mg_shlac.angles + '-2 0 0' * mg_shlac.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_shlac_springlength, autocvar_g_vehicle_mg_shlac_springup, autocvar_g_vehicle_mg_shlac_springblend, autocvar_g_vehicle_mg_shlac_tiltlimit);

    if(mg_shlac.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_shlac_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_shlac.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_shlac, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_shlac.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_shlac, player, autocvar_g_vehicle_mg_shlac_speed_walk, autocvar_g_vehicle_mg_shlac_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_shlac_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_shlac_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_shlac_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_shlac_tiltlimit);
    
    
    if(player.BUTTON_ATCK)
    {
        mg_shlac_fire(mg_shlac, player, mg_shlac.tur_head);
    } else {
        vehicles_regen(mg_shlac.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_shlac_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_shlac_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_shlac_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_shlac.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_shlac_shield, autocvar_g_vehicle_mg_shlac_shield_regen_pause, autocvar_g_vehicle_mg_shlac_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_shlac.dmg_time, vehicle_health, autocvar_g_vehicle_mg_shlac_health, autocvar_g_vehicle_mg_shlac_health_regen_pause, autocvar_g_vehicle_mg_shlac_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_shlac.origin + '0 0 1' * MG_SHLAC_MAX_z);
    player.velocity = mg_shlac.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_shlac);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_shlac);

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_shlac_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_shlac_speed_stop);

    self.nextthink = time;
}

void mg_shlac_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_shlac_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_shlac_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_shlac_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_shlac_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_shlac_speed_strafe)
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

void mg_shlac_impact()
{
    if(autocvar_g_vehicle_mg_shlac_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_shlac_bouncepain_x, autocvar_g_vehicle_mg_shlac_bouncepain_y, autocvar_g_vehicle_mg_shlac_bouncepain_z);    
}

void mg_shlac_headfade()
{
	self.think = mg_shlac_headfade;
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

void mg_shlac_blowup()
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
    setmodel(h,  "models/mountedguns/shlacgun.iqm");

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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_shlac_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_shlac_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_shlac_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_shlac_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_shlac_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_shlac_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_shlac_spawn(float _f)
{
    mg_std_resists(); //Standard resistances for mounted guns.
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();    
        
        self.gravity            = 1;
        self.mass               = 250;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
	
	self.tur_head.colormap = 1092; //Red
    }

    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_shlac_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_shlac_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_shlac_shield;
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
    self.vehicle_impact = mg_shlac_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_shlac()
{
    if(!autocvar_g_vehicle_mg_shlac)
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
    precache_model ( "models/mountedguns/shlacgun.iqm");
    //precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/lasergun_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_shlac_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_shlac_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_shlac_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "SHlacGun",
             bodymodel,
             "models/mountedguns/shlacgun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_SHLAC_MIN, MG_SHLAC_MAX,
             FALSE,
             mg_shlac_spawn, autocvar_g_vehicle_mg_shlac_respawntime,
             mg_shlac_frame,
             mg_shlac_enter, mg_shlac_exit,
             mg_shlac_die,   mg_shlac_think,
             FALSE, 
             autocvar_g_vehicle_mg_shlac_health,
             autocvar_g_vehicle_mg_shlac_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

