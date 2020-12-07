const vector MG_AUTONEX_MIN = '-20 -20 1';
const vector MG_AUTONEX_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_autonex;

float autocvar_g_vehicle_mg_autonex_respawntime;

float autocvar_g_vehicle_mg_autonex_speed_stop;
float autocvar_g_vehicle_mg_autonex_speed_strafe;
float autocvar_g_vehicle_mg_autonex_speed_walk;
float autocvar_g_vehicle_mg_autonex_movement_inertia;

float autocvar_g_vehicle_mg_autonex_springlength;
float autocvar_g_vehicle_mg_autonex_springup;
float autocvar_g_vehicle_mg_autonex_springblend;
float autocvar_g_vehicle_mg_autonex_tiltlimit;

float autocvar_g_vehicle_mg_autonex_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_autonex_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_autonex_gun_pitchspeed;
float autocvar_g_vehicle_mg_autonex_gun_turnlimit;
float autocvar_g_vehicle_mg_autonex_gun_turnspeed;

float autocvar_g_vehicle_mg_autonex_health;
float autocvar_g_vehicle_mg_autonex_health_regen;
float autocvar_g_vehicle_mg_autonex_health_regen_pause;

float autocvar_g_vehicle_mg_autonex_shield;
float autocvar_g_vehicle_mg_autonex_shield_regen;
float autocvar_g_vehicle_mg_autonex_shield_regen_pause;

float autocvar_g_vehicle_mg_autonex_railgun_refire;
float autocvar_g_vehicle_mg_autonex_railgun_ammo_cost;
float autocvar_g_vehicle_mg_autonex_railgun_ammo_max;
float autocvar_g_vehicle_mg_autonex_railgun_ammo_regen;
float autocvar_g_vehicle_mg_autonex_railgun_ammo_regen_pause;

vector autocvar_g_vehicle_mg_autonex_bouncepain;


void mg_autonex_exit(float eject);
void mg_autonex_enter();
void mg_autonex_spawn(float);

void mg_autonex_attack(string tagname, entity fireentity, entity player)
{
	entity oldself2;
	vector v;
	v = gettaginfo(fireentity, gettagindex(fireentity, tagname));
	v_forward = normalize(v_forward);
	
	float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife;
		 mydmg = autocvar_g_balance_nex_primary_damage;
		 myforce = autocvar_g_balance_nex_primary_force;
		 mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		 mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		 myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		 myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		
		W_SetupShot (self, TRUE, 5, "weapons/nexfire.wav", CH_WEAPON_A, mydmg);
		
		oldself2 = self;
		self = player;
		FireRailgunBullet (v, v + w_shotdir * MAX_SHOT_DISTANCE,
		 mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);
		self = oldself2;
		
		vector u;
		u = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
		WriteCoord(MSG_BROADCAST, v_x);
		WriteCoord(MSG_BROADCAST, v_y);
		WriteCoord(MSG_BROADCAST, v_z);
		WriteCoord(MSG_BROADCAST, u_x);
		WriteCoord(MSG_BROADCAST, u_y);
		WriteCoord(MSG_BROADCAST, u_z);
		WriteByte(MSG_BROADCAST, bound(0, 255, 255));

		pointparticles(particleeffectnum("electro_muzzleflash"), v, v_forward, 1);

}

float mg_autonex_aiframe()
{
    return FALSE;
}

void mg_autonex_fire(entity mg_autonex, entity player, entity gunmount) 
{
	mg_autonex.cnt = time;
        if(mg_autonex.vehicle_ammo1 >= autocvar_g_vehicle_mg_autonex_railgun_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_autonex.misc_bulletcounter += 1;

	    self = mg_autonex;
	    
	    makevectors(self.angles);
	    v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
	
		mg_autonex_attack("tag_mgun", gunmount, player);

            self = mg_autonex;

            mg_autonex.vehicle_ammo1 -= autocvar_g_vehicle_mg_autonex_railgun_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_autonex_railgun_refire;
            player.vehicle_ammo1 = (mg_autonex.vehicle_ammo1 / autocvar_g_vehicle_mg_autonex_railgun_ammo_max) * 100;
         
        }
}

float mg_autonex_frame()
{
    vector ad;
    entity player, mg_autonex;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_autonex = self.vehicle;
    self   = mg_autonex;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_autonex.tur_head, gettagindex(mg_autonex.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_autonex);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_autonex.angles), AnglesTransform_FromAngles(ad))) - mg_autonex.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_autonex_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_autonex.tur_head.angles_y = bound(autocvar_g_vehicle_mg_autonex_gun_turnlimit * -1, mg_autonex.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_autonex_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_autonex_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_autonex.tur_head.angles_x = bound(autocvar_g_vehicle_mg_autonex_gun_pitchlimit_down, mg_autonex.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_autonex_gun_pitchlimit_up);


    //fixedmakevectors(mg_autonex.angles);
    makevectors(mg_autonex.angles + '-2 0 0' * mg_autonex.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_autonex_springlength, autocvar_g_vehicle_mg_autonex_springup, autocvar_g_vehicle_mg_autonex_springblend, autocvar_g_vehicle_mg_autonex_tiltlimit);

    if(mg_autonex.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_autonex_speed_stop);
		setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_autonex.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_autonex, player, -133); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_autonex.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_autonex, player, autocvar_g_vehicle_mg_autonex_speed_walk, autocvar_g_vehicle_mg_autonex_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_autonex_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_autonex_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_autonex_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_autonex_tiltlimit);
    
    
    if(player.BUTTON_ATCK)
    {
        mg_autonex_fire(mg_autonex, player, mg_autonex.tur_head);
    } else {
        vehicles_regen(mg_autonex.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_autonex_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_autonex_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_autonex_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_autonex.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_autonex_shield, autocvar_g_vehicle_mg_autonex_shield_regen_pause, autocvar_g_vehicle_mg_autonex_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_autonex.dmg_time, vehicle_health, autocvar_g_vehicle_mg_autonex_health, autocvar_g_vehicle_mg_autonex_health_regen_pause, autocvar_g_vehicle_mg_autonex_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_autonex.origin + '0 0 1' * MG_AUTONEX_MAX_z);
    player.velocity = mg_autonex.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_autonex);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_autonex);

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_autonex_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_autonex_speed_stop);

    self.nextthink = time;
}

void mg_autonex_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_autonex_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_autonex_shield) * 100;
    
    mg_enter(self.owner);
}

void mg_autonex_exit(float eject)
{
    vector spot;
    

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_autonex_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_autonex_speed_strafe)
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

void mg_autonex_impact()
{
    if(autocvar_g_vehicle_mg_autonex_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_autonex_bouncepain_x, autocvar_g_vehicle_mg_autonex_bouncepain_y, autocvar_g_vehicle_mg_autonex_bouncepain_z);    
}

void mg_autonex_headfade()
{
	self.think = mg_autonex_headfade;
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

void mg_autonex_blowup()
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
    h.lodmodel1 = "models/mountedguns/autonexgun_lod1.iqm";
    setmodel(h,  "models/mountedguns/autonexgun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_autonex_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_autonex_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_autonex_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_autonex_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_autonex_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_autonex_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_autonex_spawn(float _f)
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
    }
    self.tur_head.lodowner = 1;
    self.tur_head.lodmodel1 = "models/mountedguns/autonexgun_lod1.iqm";
    InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_autonex_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_autonex_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_autonex_shield;
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
    self.vehicle_impact = mg_autonex_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_autonex()
{
    if(!autocvar_g_vehicle_mg_autonex)
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
    precache_model ( "models/mountedguns/autonexgun.iqm");
    precache_model ( "models/mountedguns/autonexgun_lod1.iqm");
    //precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/lasergun_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    if(autocvar_g_vehicle_mg_autonex_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_autonex_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_autonex_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "AutoNexGun",
             bodymodel,
             "models/mountedguns/autonexgun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_AUTONEX_MIN, MG_AUTONEX_MAX,
             FALSE,
             mg_autonex_spawn, autocvar_g_vehicle_mg_autonex_respawntime,
             mg_autonex_frame,
             mg_autonex_enter, mg_autonex_exit,
             mg_autonex_die,   mg_autonex_think,
             FALSE, 
             autocvar_g_vehicle_mg_autonex_health,
             autocvar_g_vehicle_mg_autonex_shield, 1, 0, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

