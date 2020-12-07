const vector MG_SCORPION_MIN = '-20 -20 1';
const vector MG_SCORPION_MAX  = '20 20 20';

#ifdef SVQC
float autocvar_g_vehicle_mg_scorpion;

float autocvar_g_vehicle_mg_scorpion_respawntime;

float autocvar_g_vehicle_mg_scorpion_speed_stop;
float autocvar_g_vehicle_mg_scorpion_speed_strafe;
float autocvar_g_vehicle_mg_scorpion_speed_walk;
float autocvar_g_vehicle_mg_scorpion_movement_inertia;

float autocvar_g_vehicle_mg_scorpion_springlength;
float autocvar_g_vehicle_mg_scorpion_springup;
float autocvar_g_vehicle_mg_scorpion_springblend;
float autocvar_g_vehicle_mg_scorpion_tiltlimit;

float autocvar_g_vehicle_mg_scorpion_gun_pitchlimit_down;
float autocvar_g_vehicle_mg_scorpion_gun_pitchlimit_up;
float autocvar_g_vehicle_mg_scorpion_gun_pitchspeed;
float autocvar_g_vehicle_mg_scorpion_gun_turnlimit;
float autocvar_g_vehicle_mg_scorpion_gun_turnspeed;

float autocvar_g_vehicle_mg_scorpion_health;
float autocvar_g_vehicle_mg_scorpion_health_regen;
float autocvar_g_vehicle_mg_scorpion_health_regen_pause;

float autocvar_g_vehicle_mg_scorpion_shield;
float autocvar_g_vehicle_mg_scorpion_shield_regen;
float autocvar_g_vehicle_mg_scorpion_shield_regen_pause;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_mg_scorpion_bolt_speed;
float autocvar_g_vehicle_mg_scorpion_bolt_force;
// End ballistic bullet cvars

float autocvar_g_vehicle_mg_scorpion_bolt_damage;
float autocvar_g_vehicle_mg_scorpion_bolt_refire;
float autocvar_g_vehicle_mg_scorpion_bolt_spread;
float autocvar_g_vehicle_mg_scorpion_bolt_ammo_cost;
float autocvar_g_vehicle_mg_scorpion_bolt_ammo_max;
float autocvar_g_vehicle_mg_scorpion_bolt_ammo_reserve;
float autocvar_g_vehicle_mg_scorpion_bolt_ammo_regen;
float autocvar_g_vehicle_mg_scorpion_bolt_ammo_regen_pause;
float autocvar_g_vehicle_mg_scorpion_bolt_force;
float autocvar_g_vehicle_mg_scorpion_bolt_speed;

vector autocvar_g_vehicle_mg_scorpion_bouncepain;


void mg_scorpion_exit(float eject);
void mg_scorpion_enter();
void mg_scorpion_spawn(float);

void fireBallistaBolt(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float force, float dtype)
{
	entity crossbolt;
	
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	//w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = dtype;
	setorigin(crossbolt, start);
	setsize(crossbolt, '-1.0 -1.0 -1.0', '1.0 1.0 1.0');

	crossbolt.cnt = time + lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	W_SetupProjectileVelocityEx(crossbolt, dir, v_up, pSpeed, 0, 0, spread, antilagging);

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = damage;
	crossbolt.amnt = 2;

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BALLISTABOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void fireBurningBallistaBolt(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float force, float dtype)
{
	entity crossbolt;
	
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	//w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = dtype;
	setorigin(crossbolt, start);
	setsize(crossbolt, '-1.0 -1.0 -1.0', '1.0 1.0 1.0');

	crossbolt.cnt = time + lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	W_SetupProjectileVelocityEx(crossbolt, dir, v_up, pSpeed, 0, 0, spread, antilagging);

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = damage;
	crossbolt.amnt = 6; //BurningBallista bolt

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BRBALLISTABOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

float mg_scorpion_aiframe()
{
    return FALSE;
}

void mg_scorpion_checkmodel(entity mg_scorpion, entity gunmount) 
{
    if(mg_scorpion.vehicle_ammo1 >= autocvar_g_vehicle_mg_scorpion_bolt_ammo_cost && gunmount.attack_finished_single <= time)
    {
    	if (mg_scorpion.amnt != 1) {
		mg_scorpion.amnt = 1;
    		setmodel(gunmount,  "models/mountedguns/scorpiongun_loaded.iqm");
		mg_scorpion.bomb1.alpha = 1;
	}
    }
}

void mg_scorpion_fire(entity mg_scorpion, entity player, entity gunmount) 
{
	mg_scorpion.cnt = time;
        if(mg_scorpion.vehicle_ammo1 >= autocvar_g_vehicle_mg_scorpion_bolt_ammo_cost && gunmount.attack_finished_single <= time)
        {
            vector v;
            mg_scorpion.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
	 
	 if (mg_scorpion.cb_arrowlit) {
		fireBurningBallistaBolt(v, v_forward, autocvar_g_vehicle_mg_scorpion_bolt_spread, autocvar_g_vehicle_mg_scorpion_bolt_speed, autocvar_g_balance_crossbowdtwr_primary_lifetime, autocvar_g_vehicle_mg_scorpion_bolt_damage, autocvar_g_vehicle_mg_scorpion_bolt_force, WEP_CROSSBOWDTWR);
	 	mg_scorpion.cb_arrowlit = 0;
	 } else {
	 	fireBallistaBolt(v, v_forward, autocvar_g_vehicle_mg_scorpion_bolt_spread, autocvar_g_vehicle_mg_scorpion_bolt_speed, autocvar_g_balance_crossbowdtwr_primary_lifetime, autocvar_g_vehicle_mg_scorpion_bolt_damage, autocvar_g_vehicle_mg_scorpion_bolt_force, WEP_CROSSBOWDTWR);
	 }
	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 //pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
	 sound (gunmount, CH_WEAPON_A, "resource/impact/Arrowimpwood_19.ogg", VOL_BASE, ATTN_NORM);
	
	setmodel(gunmount,  "models/mountedguns/scorpiongun.iqm");
	mg_scorpion.amnt = 0;
	mg_scorpion.bomb1.alpha = -1;
	
	 //Removed expell bullet casings stuff	

            self = mg_scorpion;

            mg_scorpion.vehicle_ammo1 -= autocvar_g_vehicle_mg_scorpion_bolt_ammo_cost;
            gunmount.attack_finished_single = time + autocvar_g_vehicle_mg_scorpion_bolt_refire;
            player.vehicle_ammo1 = (mg_scorpion.vehicle_ammo1 / autocvar_g_vehicle_mg_scorpion_bolt_ammo_max) * 100;
        }
}

void mg_scorpion_crossbow_thinklight() {
	if (self.owner.cb_arrowlit == 1 && self.cb_arrowlit == 1 && self.owner.vehicle_health > 0) {
		local vector vlporigin;
		
		vlporigin = gettaginfo(self.owner.bomb1, gettagindex(self.owner.bomb1, ""));
		//print (vtos(vlporigin), " light origin\n");
		
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = (self.owner.origin + '0 0 128');
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	vlporigin = (self.owner.origin + '0 0 64');
			if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  		vlporigin = (self.owner.origin);
		    	}
		  }
		}
		setorigin(self, vlporigin);
		self.nextthink = time;
		self.cb_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void mg_scorpion_crossbow_spawnlight(entity mg_scorpion) {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 128;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = mg_scorpion;
	newtorchlight.think = mg_scorpion_crossbow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.cb_arrowlit = 1;
	self.crossbowlight = newtorchlight;
}

void mg_scorpion_AttachFlameToShotorg(entity mg_scorpion, float particleeffectnbr, vector offset)
{
	entity flash;
	flash = spawn();
	vector v;
					
	v = gettaginfo(mg_scorpion.bomb1, gettagindex(mg_scorpion.bomb1, ""));
		
	if (mg_scorpion.shootfromside == 1) {
		makevectors(mg_scorpion.v_angle);
		offset = offset-(v_up*16); //For somereason offset badly, so fix
		
		v_x = v_x + offset_x;
		v_y = v_y + offset_y;
		v_z = v_z + offset_z;
		setorigin(flash, v);
	} else {
		//Normal
		v_x = v_x + offset_x;
		v_y = v_y + offset_y;
		v_z = v_z + offset_z;
		setorigin(flash, v);
	}

	pointparticles(particleeffectnbr, flash.origin, '0 0 0', 1);
	remove(flash);
}


float mg_scorpion_frame()
{
    vector ad;
    entity player, mg_scorpion;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    mg_scorpion = self.vehicle;
    self   = mg_scorpion;

    if (player.impulse == 20) {
    	//Last time reload was hit
    	mg_scorpion.crudebow_reloaded_time = time + 0.8;
    }
    
    mg_scorpion.vehicle_reloadplususeexit = 0;
    if (mg_scorpion.crudebow_reloaded_time > time) {
    	//Let Button_Use pass so we can light bolt
    } else if (player.BUTTON_USE) {
    	mg_scorpion.vehicle_reloadplususeexit = 1;
	//Special exit code.
    }
    
    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    
    if ((player.health < 1) || (player.deadflag != DEAD_NO)) {
    	vehicles_exit(VHEF_RELESE);
    }


    ad = gettaginfo(mg_scorpion.tur_head, gettagindex(mg_scorpion.tur_head, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_NORMAL, mg_scorpion);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(mg_scorpion.angles), AnglesTransform_FromAngles(ad))) - mg_scorpion.tur_head.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    ////UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_mg_scorpion_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    mg_scorpion.tur_head.angles_y = bound(autocvar_g_vehicle_mg_scorpion_gun_turnlimit * -1, mg_scorpion.tur_head.angles_y + ad_y, autocvar_g_vehicle_mg_scorpion_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_mg_scorpion_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    mg_scorpion.tur_head.angles_x = bound(autocvar_g_vehicle_mg_scorpion_gun_pitchlimit_down, mg_scorpion.tur_head.angles_x + ad_x, autocvar_g_vehicle_mg_scorpion_gun_pitchlimit_up);


    //fixedmakevectors(mg_scorpion.angles);
    makevectors(mg_scorpion.angles + '-2 0 0' * mg_scorpion.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_mg_scorpion_springlength, autocvar_g_vehicle_mg_scorpion_springup, autocvar_g_vehicle_mg_scorpion_springblend, autocvar_g_vehicle_mg_scorpion_tiltlimit);

    if(mg_scorpion.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                                
                movelib_beak_simple(autocvar_g_vehicle_mg_scorpion_speed_stop);
		setanim(player, player.anim_idle, TRUE, FALSE, FALSE);
        }
	
	if not(mg_scorpion.spawnflags & 32)
    	if(player.movement_y != 0)
   	 {
	 	mg_stdrotate(mg_scorpion, player, -200); //Gun, Player, divide playermovement Y by.
	 }
	 
	 if not(mg_scorpion.spawnflags >= 16)
	 if(player.movement_x != 0)
         {
          	mg_stdmove(mg_scorpion, player, autocvar_g_vehicle_mg_scorpion_speed_walk, autocvar_g_vehicle_mg_scorpion_movement_inertia);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_mg_scorpion_tiltlimit, self.angles_x, autocvar_g_vehicle_mg_scorpion_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_mg_scorpion_tiltlimit, self.angles_z, autocvar_g_vehicle_mg_scorpion_tiltlimit);
    
    mg_scorpion_checkmodel(mg_scorpion, mg_scorpion.tur_head);
    
    if (mg_scorpion.cb_arrowlit == 1) {
	if ((player.watertype == CONTENT_WATER || player.watertype == CONTENT_SLIME) && player.waterlevel > 2) {
		//pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
		pointparticles(particleeffectnum("smoke_big"), mg_scorpion.origin + '0 0 64', '0 0 30', 10);
		spamsound (mg_scorpion, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
		mg_scorpion.cb_arrowlit = 0;
				
	} else if (time > mg_scorpion.cb_arrownextburn) {
		mg_scorpion_AttachFlameToShotorg(mg_scorpion, particleeffectnum("torchflame"),'0 0 0');
		mg_scorpion.cb_arrownextburn = time + 0.2;
		
		if (mg_scorpion.crossbowlight) {
			mg_scorpion.crossbowlight.cb_arrowlit = 1;
		} else {
			mg_scorpion_crossbow_spawnlight(mg_scorpion);
		}
	} else {
		if (mg_scorpion.crossbowlight) {
			mg_scorpion.crossbowlight.cb_arrowlit = 1;
		} else {
			mg_scorpion_crossbow_spawnlight(mg_scorpion);
		}
	}
    }
    
    if(player.BUTTON_ATCK)
    {
	mg_scorpion_fire(mg_scorpion, player, mg_scorpion.tur_head);
	mg_scorpion.count = 0; //Will have to press R to resume reload
    } else {
    	if (mg_scorpion.count == 1) {
        vehicles_regen(mg_scorpion.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_scorpion_bolt_ammo_max,
                                           autocvar_g_vehicle_mg_scorpion_bolt_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_scorpion_bolt_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK) && !(player.BUTTON_USE)) {
		mg_scorpion.count = 1;
		sound (mg_scorpion, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		////Reload from own stores //75 ammo, 3 player ammo = 1 vehic ammo,
		////vehicles_replenishAmmo(player, mg_scorpion, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);
		//Reload from own stores //1 ammo, 1 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, mg_scorpion, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 1, 1);
	
	}
	
	if (mg_scorpion.crudebow_reloaded_time > time) {
	if(player.BUTTON_USE)
		//Reload and Use key (R and F, by default)
		if (!mg_scorpion.cb_arrowlit) {
			local vector mymgaimingvector;
			mymgaimingvector = mg_scorpion.angles;
			mymgaimingvector_x = mymgaimingvector_x + mg_scorpion.tur_head.angles_x;
			mymgaimingvector_y = mymgaimingvector_y + mg_scorpion.tur_head.angles_y;
			mymgaimingvector_z = mymgaimingvector_z + mg_scorpion.tur_head.angles_z;
			
			mymgaimingvector_x = mymgaimingvector_x * -1;
			
			if (W_CrossbowCanLightBoltExVec(mg_scorpion, 224, gettaginfo(mg_scorpion.bomb1, gettagindex(mg_scorpion.bomb1, "")), mymgaimingvector)) {
				mg_scorpion.cb_arrowlit = 1;
				mg_scorpion_crossbow_spawnlight(mg_scorpion);
			}
		}
	}
    }
       

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(mg_scorpion.dmg_time, vehicle_shield, autocvar_g_vehicle_mg_scorpion_shield, autocvar_g_vehicle_mg_scorpion_shield_regen_pause, autocvar_g_vehicle_mg_scorpion_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(mg_scorpion.dmg_time, vehicle_health, autocvar_g_vehicle_mg_scorpion_health, autocvar_g_vehicle_mg_scorpion_health_regen_pause, autocvar_g_vehicle_mg_scorpion_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;

    setorigin(player, mg_scorpion.origin + '0 0 1' * MG_SCORPION_MAX_z);
    player.velocity = mg_scorpion.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, mg_scorpion);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, mg_scorpion);

    player.vehicle_ammo1_current = mg_scorpion.vehicle_ammo1_current;
    player.vehicle_ammo1_max = mg_scorpion.vehicle_ammo1_max;

    self = player;
    mg_creatureframe(); //Workaround so player can be hurt by slime, lava, or drowned while in this open-air vehicle
    return 1;    
}
void mg_scorpion_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_mg_scorpion_speed_stop);

    if (self.cb_arrowlit == 1) {
	if (time > self.cb_arrownextburn) {
		mg_scorpion_AttachFlameToShotorg(self, particleeffectnum("torchflame"),'0 0 0');
		self.cb_arrownextburn = time + 0.2;
		self.crossbowlight.cb_arrowlit = 1;
	} else {
		self.crossbowlight.cb_arrowlit = 1;
	}
    }
    
    self.nextthink = time;
}

void mg_scorpion_enter()
{
    if (self.cb_arrowlit == 1) {
	if (time > self.cb_arrownextburn) {
		mg_scorpion_AttachFlameToShotorg(self, particleeffectnum("torchflame"),'0 0 0');
		self.cb_arrownextburn = time + 0.2;
		if (self.crossbowlight) {
			self.crossbowlight.cb_arrowlit = 1;
			self.crossbowlight.nextthink = time + 1; //So won't burn out
		} else {
			mg_scorpion_crossbow_spawnlight(self);
		}
	} else {
		if (self.crossbowlight) {
			self.crossbowlight.cb_arrowlit = 1;
			self.crossbowlight.nextthink = time + 1; //So won't burn out
		} else {
			mg_scorpion_crossbow_spawnlight(self);
		}
	}
    }
    
    self.vehicle_weapon2mode = SBRM_GUIDE;
    if (self.spawnflags >= 32) {
	   self.movetype = MOVETYPE_NONE;
    } else {
	   self.movetype = MOVETYPE_WALK;
    }
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_mg_scorpion_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_mg_scorpion_shield) * 100;

    mg_enter(self.owner);
    
    //We don't crouch for this weapon
    self.owner.crouch = FALSE;
    setsize(self.owner, PL_MIN,PL_MAX);
    setanim(self.owner, self.owner.anim_idle, TRUE, FALSE, FALSE);
}

void mg_scorpion_exit(float eject)
{
    vector spot;
    
    if (self.cb_arrowlit == 1) {
	if (time > self.cb_arrownextburn) {
		mg_scorpion_AttachFlameToShotorg(self, particleeffectnum("torchflame"),'0 0 0');
		self.cb_arrownextburn = time + 0.2;
		if (self.crossbowlight) {
			self.crossbowlight.cb_arrowlit = 1;
		} else {
			mg_scorpion_crossbow_spawnlight(self);
		}
	} else {
		if (self.crossbowlight) {
			self.crossbowlight.cb_arrowlit = 1;
		} else {
			mg_scorpion_crossbow_spawnlight(self);
		}
	}
    }

    if (self.vehicle_shieldtype) self.hitboxft.bot_attack = FALSE; //self.velocity   = '0 0 0';
    self.think      = mg_scorpion_think;
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
		if(vlen(self.velocity) > autocvar_g_vehicle_mg_scorpion_speed_strafe)
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

void mg_scorpion_impact()
{
    if(autocvar_g_vehicle_mg_scorpion_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_mg_scorpion_bouncepain_x, autocvar_g_vehicle_mg_scorpion_bouncepain_y, autocvar_g_vehicle_mg_scorpion_bouncepain_z);    
}

void mg_scorpion_headfade()
{
	self.think = mg_scorpion_headfade;
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

void mg_scorpion_blowup()
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

    setmodel(b,  "models/mountedguns/scorpion_mount.iqm");
    //h.lodmodel1 = "models/mountedguns/scorpiongun_lod1.iqm";
    //h.lodmodel2 = "models/mountedguns/scorpiongun_lod2.iqm";
    setmodel(h,  "models/mountedguns/scorpiongun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_mg_scorpion_respawntime, 10);
    h.fade_time     = time;
    h.think         = mg_scorpion_headfade;
    h.nextthink     = time;


    h.colormod = b.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_mg_scorpion_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_mg_scorpion_respawntime, 10));
    
    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.bomb1.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void mg_scorpion_die()
{
    self.cb_arrowlit 	    = 0; //Remove flame if loaded arrow is burning
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = mg_scorpion_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
	mg_shield_die(self, self.hitboxft);
}

void mg_scorpion_spawn(float _f)
{
    self.scale = 1.90;
    
    self.resist_acid = 1.0;   //Slime
    self.resist_blunt = 1.0;  //Warhammer, beatdown, melee
    self.resist_bullet = 1.0;
    self.resist_crush = 0.10;  //Vehicle crush
    self.resist_edged = 0.10;  //Axe, Sword, Claw
    self.resist_electricity = 1.0; //Lightning gun, Tesla arc, 
    self.resist_energy = 1.0; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
    self.resist_explode = 0;//Rockets etc
    self.resist_fall = 1.0;   //Shooting star, fall etc
    self.resist_fire = 0;   //Fire, Lava
    self.resist_laser = 1.0;  //Laser
    self.resist_nuke = 0;  //Nuclear explosion
    self.resist_pierce = 1.0; //Crossbow, Bite
    self.resist_sound = 1.0; //Tuba
    self.resist_ice = 1.0; //Freeze damage resistance
    self.resist_rotor = 1.0; //Helicopter/Aero-plane Rotor blades damage resistance, Special, evaluated before crush

    self.cb_arrowlit 	    = 0; //No flame on start
    self.vehicle_reloadplususe = 1;
    
    if(!self.gun1)
    {	
        self.gun1            = spawn();
	
	self.bomb1              = spawn(); 
	self.bomb1.scale = 1/self.scale; //Attached things are scaled to parent, so scale back down.
	setattachment(self.bomb1, self.tur_head, "tag_mgun");
	self.bomb1.alpha = -1;
	self.bomb1.origin = '42 0 0';
	setorigin(self.bomb1, self.bomb1.origin);
	setmodel(self.bomb1,  "models/ballistabolt.md3");
	
        self.gravity            = 2;
        self.mass               = 5000;
	
	setattachment(self.vehicle_hudmodel, self, "");
        setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	
	if (self.vehicle_shieldtype) self.hitboxft = spawn();
    }
    self.tur_head.lodowner = 1;
    //self.tur_head.lodmodel1 = "models/mountedguns/scorpiongun_lod1.iqm";
    //self.tur_head.lodmodel2 = "models/mountedguns/scorpiongun_lod2.iqm";
    //InitializeEntity(self.tur_head, LODmodel_attach, INITPRIO_FINDTARGET);
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    //self.frame              = 5;
    //self.tur_head.frame     = 1;
    self.think              = mg_scorpion_think;
    self.touch              = mg_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_mg_scorpion_health;
    self.vehicle_shield     = autocvar_g_vehicle_mg_scorpion_shield;
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
    self.vehicle_impact = mg_scorpion_impact;
    self.damageforcescale = 0.03;
    if (self.vehicle_shieldtype) mg_spawn_shield(self.vehicle_shieldtype, self, self.tur_head, self.hitboxft, autocvar_g_vehicle_mg_maxim_health);
}

void spawnfunc_mountedgun_scorpion()
{
    if(!autocvar_g_vehicle_mg_scorpion)
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
    	precache_model ( "models/mountedguns/scorpion_mount.iqm");
    	bodymodel = "models/mountedguns/scorpion_mount.iqm";
	self.vehicle_flags |= VHF_DMGSHAKE;
    }

    mg_shield_precache();
    precache_model ( "models/mountedguns/scorpiongun_loaded.iqm");
    precache_model ( "models/mountedguns/scorpiongun.iqm");
    //precache_model ( "models/mountedguns/scorpiongun_lod1.iqm");
    //precache_model ( "models/mountedguns/scorpiongun_lod2.iqm");
    precache_model ("models/ballistabolt.md3");
    precache_sound ( "resource/impact/Arrowimpwood_19.ogg" );
    precache_sound ( "weapons/rocket_impact.wav");
    
    		precache_sound("resource/impact/arrowimpmetal_213.ogg");
		precache_sound("resource/impact/arrowimpmetal_212.ogg");
		precache_sound("resource/impact/arrowimpmetal_211.ogg");
		precache_sound("resource/impact/arrowimpmetal_210.ogg");
		precache_sound("resource/impact/arrowimpmetal_29.ogg");
		precache_sound("resource/impact/arrowimpmetal_28.ogg");
		precache_sound("resource/impact/arrowimpmetal_27.ogg");
		precache_sound("resource/impact/arrowimpmetal_26.ogg");
		precache_sound("resource/impact/arrowimpmetal_25.ogg");
		precache_sound("resource/impact/arrowimpmetal_24.ogg");
		precache_sound("resource/impact/arrowimpmetal_23.ogg");
		precache_sound("resource/impact/arrowimpmetal_22.ogg");
		precache_sound("resource/impact/arrowimpmetal_21.ogg");
		precache_sound("resource/impact/arrowimpstone_212.ogg");
		precache_sound("resource/impact/arrowimpstone_211.ogg");
		precache_sound("resource/impact/arrowimpstone_210.ogg");
		precache_sound("resource/impact/arrowimpstone_29.ogg");
		precache_sound("resource/impact/arrowimpstone_28.ogg");
		precache_sound("resource/impact/arrowimpstone_27.ogg");
		precache_sound("resource/impact/arrowimpstone_26.ogg");
		precache_sound("resource/impact/arrowimpstone_25.ogg");
		precache_sound("resource/impact/arrowimpstone_24.ogg");
		precache_sound("resource/impact/arrowimpstone_23.ogg");
		precache_sound("resource/impact/arrowimpstone_22.ogg");
		precache_sound("resource/impact/arrowimpstone_21.ogg");
		precache_sound("resource/impact/Arrowimpwood_19.ogg");
		precache_sound("resource/impact/Arrowimpwood_18.ogg");
		precache_sound("resource/impact/Arrowimpwood_17.ogg");
		precache_sound("resource/impact/Arrowimpwood_16.ogg");
		precache_sound("resource/impact/Arrowimpwood_15.ogg");
		precache_sound("resource/impact/Arrowimpwood_14.ogg");
		precache_sound("resource/impact/Arrowimpwood_13.ogg");
		precache_sound("resource/impact/Arrowimpwood_12.ogg");
		precache_sound("resource/impact/Arrowimpwood_11.ogg");
		precache_sound("resource/impact/slingimpwood_22.ogg");
		precache_sound("resource/impact/slingimpwood_21.ogg");
		precache_sound("resource/impact/slingimpstone_210.ogg");
		precache_sound("resource/impact/slingimpstone_211.ogg");
    
    if(autocvar_g_vehicle_mg_scorpion_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_mg_scorpion_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_mg_scorpion_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
    if not (vehicle_initialize(
             "ScorpionBallista",
             bodymodel,
             "models/mountedguns/scorpiongun.iqm",
             "null",
             "tag_gunpivot", "tag_player", "",
             HUD_NORMAL,
             MG_SCORPION_MIN, MG_SCORPION_MAX,
             FALSE,
             mg_scorpion_spawn, autocvar_g_vehicle_mg_scorpion_respawntime,
             mg_scorpion_frame,
             mg_scorpion_enter, mg_scorpion_exit,
             mg_scorpion_die,   mg_scorpion_think,
             FALSE, 
             autocvar_g_vehicle_mg_scorpion_health,
             autocvar_g_vehicle_mg_scorpion_shield, 1, autocvar_g_vehicle_mg_scorpion_bolt_ammo_max * autocvar_g_vehicle_mg_scorpion_bolt_ammo_reserve, 0))
	     	//1 == yes, automatically colormap to same colormap as player
    {
        remove(self);
        return;
    }
}

