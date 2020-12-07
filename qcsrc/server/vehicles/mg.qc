float autocvar_g_vehicles_wetfeet_multi;
float autocvar_g_vehicles_swimming_multi;
float autocvar_g_vehicles_submerged_multi;
float autocvar_g_vehicles_wetfeet_friction;
float autocvar_g_vehicles_swimming_friction;
float autocvar_g_vehicles_submerged_friction;
float autocvar_g_vehicles_wetfeet_multi2;
float autocvar_g_vehicles_swimming_multi2;
float autocvar_g_vehicles_submerged_multi2;
float autocvar_g_vehicles_wetfeet_friction2;
float autocvar_g_vehicles_swimming_friction2;
float autocvar_g_vehicles_submerged_friction2;
float autocvar_g_vehicles_tank_wetfeet_multi_simple;
float autocvar_g_vehicles_tank_swimming_multi_simple;
float autocvar_g_vehicles_tank_submerged_multi_simple;
float autocvar_g_vehicles_oldtank_wetfeet_multi_simple;
float autocvar_g_vehicles_oldtank_swimming_multi_simple;
float autocvar_g_vehicles_oldtank_submerged_multi_simple;
float autocvar_g_vehicles_mech_wetfeet_multi_simple;
float autocvar_g_vehicles_mech_swimming_multi_simple;
float autocvar_g_vehicles_mech_submerged_multi_simple;
float autocvar_g_vehicles_tank_wetfeet_friction;
float autocvar_g_vehicles_tank_swimming_friction;
float autocvar_g_vehicles_tank_submerged_friction;
float autocvar_g_vehicles_tank_friction_rate;
float autocvar_g_vehicles_tank_friction_min;
.float dmgtime3;

.entity hitboxft;

float vehicles_frmadjst(float multi)
{
	//So that friction will be independent of framerate:
	//Goal: the fater the frame time
	//the more frames in the second
	//Thus we want to slow down the vehic at a slower speed
	//since there are more frames.
	//Thus the lower the frametime, the more frames there are
	//and thus we want to return a higher multiplier
	//because we are multiplying the vector by this multiplier
	//(The lower the multiplier the faster the vehic will slow down)
	//(more friction)
	float myrem;
	//float myrem2;
	//float myrem3;
	//float frameadjust;
	//frameadjust = (0.0222222/frametime);
	//myrem = 1 - multi;
	//myrem2 = (myrem / frameadjust);
	//myrem3 = 1 - myrem2;
	
	myrem = (1 - ((1 - multi) / (0.0222222/frametime)));
	
	//print(ftos(myrem),"------\n");
	
	return (myrem);
}

vector vehicles_waterspeed(entity player, vector df)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		df = df * autocvar_g_vehicles_submerged_multi;
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		df = df * autocvar_g_vehicles_swimming_multi;
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		df = df * autocvar_g_vehicles_wetfeet_multi;
	}
	
	return(df);
}

vector vehicles_waterfriction(entity player, entity vehic, vector vel)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_submerged_friction);
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_swimming_friction);
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_wetfeet_friction);
	}
	
	return(vel);
}


vector vehicles_waterspeed2(entity player, vector df)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		df = df * autocvar_g_vehicles_submerged_multi2;
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		df = df * autocvar_g_vehicles_swimming_multi2;
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		df = df * autocvar_g_vehicles_wetfeet_multi2;
	}
	
	return(df);
}

vector vehicles_waterfriction2(entity player, entity vehic, vector vel)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_submerged_friction2);
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_swimming_friction2);
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		vel = vel * vehicles_frmadjst(autocvar_g_vehicles_wetfeet_friction2);
	}
	
	return(vel);
}


float vehicles_tank_waterspeed_simple(entity player, float df)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		df = df * autocvar_g_vehicles_tank_submerged_multi_simple;
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		df = df * autocvar_g_vehicles_tank_swimming_multi_simple;
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		df = df * autocvar_g_vehicles_tank_wetfeet_multi_simple;
	}
	
	return(df);
}

float vehicles_oldtank_waterspeed_simple(entity player, float df)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		df = df * autocvar_g_vehicles_oldtank_submerged_multi_simple;
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		df = df * autocvar_g_vehicles_oldtank_swimming_multi_simple;
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		df = df * autocvar_g_vehicles_oldtank_wetfeet_multi_simple;
	}
	
	return(df);
}

vector vehicles_tank_waterfriction(entity player, vector vel)
{
	if (player.waterlevel) {
	if (vel_x > autocvar_g_vehicles_tank_friction_min
	|| vel_y > autocvar_g_vehicles_tank_friction_min
	|| vel_z > autocvar_g_vehicles_tank_friction_min) {
	if (random() < autocvar_g_vehicles_tank_friction_rate) {
		if (player.waterlevel == WATERLEVEL_SUBMERGED)
   		{
			vel = vel * vehicles_frmadjst(autocvar_g_vehicles_tank_submerged_friction);
		} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   		{
			vel = vel * vehicles_frmadjst(autocvar_g_vehicles_tank_swimming_friction);
		}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   		{
			vel = vel * vehicles_frmadjst(autocvar_g_vehicles_tank_wetfeet_friction);
		}
	}
	}
	}
	
	return(vel);
}

float vehicles_mech_waterspeed_simple(entity player, float df)
{
	if (player.waterlevel == WATERLEVEL_SUBMERGED)
   	{
		df = df * autocvar_g_vehicles_mech_submerged_multi_simple;
	} else if (player.waterlevel == WATERLEVEL_SWIMMING)
   	{
		df = df * autocvar_g_vehicles_mech_swimming_multi_simple;
	}  else if (player.waterlevel == WATERLEVEL_WETFEET)
   	{
		df = df * autocvar_g_vehicles_mech_wetfeet_multi_simple;
	}
	
	return(df);
}


void mg_creatureframe (void)
{
    //Workaround since this doesn't work regularly when player is in an open mounted gun
    if (pointcontents (self.origin + '0 0 2') == CONTENT_WATER) {
    	if (pointcontents (self.origin+'0 0 24') == CONTENT_WATER) {
		//note self.view_ofs is '0 0 0' so we're not using it here
    		self.watertype = CONTENT_WATER;
		self.waterlevel = WATERLEVEL_SUBMERGED;
	}
    }
    
    
    if (pointcontents (self.origin + '0 0 2') == CONTENT_SLIME) {
    	self.watertype = CONTENT_SLIME;
    }
    if (pointcontents (self.origin + '0 0 2') == CONTENT_LAVA) {
    	self.watertype = CONTENT_LAVA;
    }
    	if (self.dmgtime3 < time)
    	{
		self.dmgtime3 = time + autocvar_g_balance_contents_damagerate; 
    		CreatureFrame_Slime_Lava();
    	}
	
	if (self.watertype == CONTENT_WATER)
	{
		if (self.waterlevel != WATERLEVEL_SUBMERGED)
		{
			CreatureFrame_Gasp();
		}
		else if (self.air_finished < time)
		{
			CreatureFrame_Drown();
		}
	} else if (self.watertype != CONTENT_SLIME && self.watertype != CONTENT_LAVA)
	{
		
	}
}

void mg_stdrotate (entity gun, entity player, float divrotate)
{
		local float normalizeft = sys_frametime/0.0333333;
		//divrotate is set to negative number,
		//like -200, higher == slower, sign sets rotation direction
		if(player.v_angle_y > 180)  player.v_angle_y -= 360;
    		if(player.v_angle_y < -180) player.v_angle_y += 360;
		
		if(player.angles_y > 180)  player.angles_y -= 360;
    		if(player.angles_y < -180) player.angles_y += 360;
		
		if(gun.angles_y > 180)  gun.angles_y -= 360;
    		if(gun.angles_y < -180) gun.angles_y += 360;
		gun.angles_y = bound(-184,gun.angles_y + (player.movement_y / divrotate) * normalizeft,184);	
		
		if(gun.angles_y >= -1 && gun.angles_y <= -1)
            		gun.angles_y = 0;	

		player.angles_y = player.angles_y + (player.movement_y / divrotate) * normalizeft;
		
		if (gun.spawnflags == 16)
		{
			//Circ mount (like a turret)
			player.v_angle_y = gun.angles_y;
		} else {
			//Other mounts
			float degree_y;

			degree_y = (player.movement_y / divrotate);
			player.v_angle_y = player.v_angle_y + (degree_y * normalizeft);
				
			//if(player.v_angle_y > gun.angles_y + gun.tur_head.angles_y + 10) player.v_angle_y = gun.angles_y;
			//if(player.v_angle_y < gun.angles_y + gun.tur_head.angles_y - 10) player.v_angle_y = gun.angles_y;
		}
		
		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}

		if(player.movement_y > 0)
                {
			if (player.crouch)
				setanim(player, player.anim_duckwalkstrafeleft, TRUE, FALSE, FALSE);
			else
				setanim(player, player.anim_strafeleft, TRUE, FALSE, FALSE);	
                }
                else if(player.movement_y < 0)
                {
			if (player.crouch)
				setanim(player, player.anim_duckwalkstraferight, TRUE, FALSE, FALSE);
			else
				setanim(player, player.anim_straferight, TRUE, FALSE, FALSE);
                }
}

void mg_stdmove (entity gun, entity player, float gnwalkspeed, float gninertia)
{
                    //Walking forward
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
			if (player.crouch) {
				setanim(player, player.anim_duckwalk, TRUE, FALSE, FALSE);
			} else {
				setanim(player, player.anim_run, TRUE, FALSE, FALSE);
			}
                        gun.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
			if (player.crouch) {
				setanim(player, player.anim_duckwalkbackwards, TRUE, FALSE, FALSE);
			} else {
				setanim(player, player.anim_runbackwards, TRUE, FALSE, FALSE);
			}
                        gun.frame = 1;
                    }
		    
		    
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(gun.angles);
    			makevectors(gun.angles + '-2 0 0' * gun.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),gnwalkspeed,gninertia);
}

void mg_enter (entity player)
{
	//Called when you enter a mounted gun.
	//TODO: move the generic mg_bla_enter stuff here
	setsize(player, PL_CROUCH_MIN,PL_CROUCH_MAX);
	player.crouch = TRUE;
        player.takedamage     = DAMAGE_AIM;
        player.solid          = SOLID_SLIDEBOX;
        player.effects        &~= EF_NODRAW;
        player.alpha          = 1;
        player.event_damage   = PlayerDamage;
        //player.hud            = HUD_NORMAL;
	setanim(player, player.anim_duckidle, TRUE, FALSE, FALSE);
	
	antilag_clear(player);
	
	if (player.vehicle.vehicle_shieldtype)
	{
		player.vehicle.hitboxft.bot_attack = TRUE;
		if (teamplay) player.vehicle.hitboxft.team = player.team;
	}
}

void mg_vehicles_touch()
{
    // Vehicle currently in use
    if(self.owner)
    {
        return;
    }

    if(other.classname != "player")
        return;

    if(other.deadflag != DEAD_NO)
        return;

    if(other.vehicle != world)
        return;

    if (vehicles_evalenter(other)) {
    	vehicles_enter();
    } else {
    	return;
    }
}
