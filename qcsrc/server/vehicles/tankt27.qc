const vector TANKT27_MIN = '-100 -100 2';
const vector TANKT27_MAX  = '100 100 158';

#ifdef SVQC
float autocvar_g_vehicle_tankt27;

float autocvar_g_vehicle_tankt27_respawntime;

float autocvar_g_vehicle_tankt27_speed_stop;
float autocvar_g_vehicle_tankt27_speed_strafe;
float autocvar_g_vehicle_tankt27_speed_walk;
float autocvar_g_vehicle_tankt27_movement_inertia;

float autocvar_g_vehicle_tankt27_springlength;
float autocvar_g_vehicle_tankt27_springup;
float autocvar_g_vehicle_tankt27_springblend;
float autocvar_g_vehicle_tankt27_tiltlimit;

float autocvar_g_vehicle_tankt27_gun_pitchlimit_down;
float autocvar_g_vehicle_tankt27_gun_pitchlimit_up;
float autocvar_g_vehicle_tankt27_gun_pitchspeed;
float autocvar_g_vehicle_tankt27_gun_turnlimit;
float autocvar_g_vehicle_tankt27_gun_turnspeed;

//float autocvar_g_vehicle_tankt27_energy;
//float autocvar_g_vehicle_tankt27_energy_regen;
//float autocvar_g_vehicle_tankt27_energy_regen_pause;

float autocvar_g_vehicle_tankt27_health;
float autocvar_g_vehicle_tankt27_health_regen;
float autocvar_g_vehicle_tankt27_health_regen_pause;

float autocvar_g_vehicle_tankt27_shield;
float autocvar_g_vehicle_tankt27_shield_regen;
float autocvar_g_vehicle_tankt27_shield_regen_pause;

//Overheating://
float autocvar_g_vehicle_mg_lewis_machinegun_cooldownrate;
float autocvar_g_vehicle_mg_lewis_machinegun_cooldownwait;
float autocvar_g_vehicle_mg_lewis_machinegun_heatconstant;
float autocvar_g_vehicle_mg_lewis_machinegun_heatmin;
//Overheating//

// Start Ballistic bullet cvars
float autocvar_g_vehicle_tankt27_machinegun_expelbulletcasings;
float autocvar_g_vehicle_tankt27_machinegun_speed;
float autocvar_g_vehicle_tankt27_machinegun_force;
float autocvar_g_vehicle_tankt27_machinegun_bulletconstant;
float autocvar_g_vehicle_tankt27_machinegun_headshotaddeddamage;
float autocvar_g_vehicle_tankt27_machinegun_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_tankt27_machinegun_damage;
float autocvar_g_vehicle_tankt27_machinegun_refire;
float autocvar_g_vehicle_tankt27_machinegun_spread;
float autocvar_g_vehicle_tankt27_machinegun_ammo_cost;
float autocvar_g_vehicle_tankt27_machinegun_ammo_max;
float autocvar_g_vehicle_tankt27_machinegun_ammo_regen;
float autocvar_g_vehicle_tankt27_machinegun_ammo_regen_pause;
float autocvar_g_vehicle_tankt27_machinegun_force;
float autocvar_g_vehicle_tankt27_machinegun_speed;
float autocvar_g_vehicle_tankt27_machinegun_bulletconstant;

// Start Ballistic bullet cvars
float autocvar_g_vehicle_tankt27_cannon_speed;
float autocvar_g_vehicle_tankt27_cannon_force;
float autocvar_g_vehicle_tankt27_cannon_bulletconstant;
float autocvar_g_vehicle_tankt27_cannon_headshotaddeddamage;
float autocvar_g_vehicle_tankt27_cannon_coreshotaddeddamage;
// End ballistic bullet cvars

float autocvar_g_vehicle_tankt27_cannon_damage;
float autocvar_g_vehicle_tankt27_cannon_refire;
float autocvar_g_vehicle_tankt27_cannon_spread;
float autocvar_g_vehicle_tankt27_cannon_ammo_cost;
float autocvar_g_vehicle_tankt27_cannon_ammo_max;
float autocvar_g_vehicle_tankt27_cannon_ammo_regen;
float autocvar_g_vehicle_tankt27_cannon_ammo_regen_pause;
float autocvar_g_vehicle_tankt27_cannon_force;
float autocvar_g_vehicle_tankt27_cannon_speed;
float autocvar_g_vehicle_tankt27_cannon_bulletconstant;
float autocvar_g_vehicle_tankt27_cannon_iter;
float autocvar_g_vehicle_tankt27_cannon_iterforward;
float autocvar_g_vehicle_tankt27_cannon_fragments;
float autocvar_g_vehicle_tankt27_cannon_fragments_frames;
float autocvar_g_vehicle_tankt27_cannon_pitchspeed;
float autocvar_g_vehicle_tankt27_cannon_pitchlimit_down;
float autocvar_g_vehicle_tankt27_cannon_pitchlimit_up;

vector autocvar_g_vehicle_tankt27_bouncepain;


.entity hitboxft;
.entity hitboxbk;
.entity subordinate;
.float subordinatespeed;
.float subordinateinertia;

void tankt27_exit(float eject);
void tankt27_enter();
void tankt27_spawn(float);

float tankt27_maywepounddown(entity mytank, entity othertree)
{
	float myreturn;
	float msizea;
	float msizeb;
	
	myreturn = 0;
	msizea = 0;
	msizeb = 0;
	
	if (mytank.vehicle_pounddownclass >= 5) {
		myreturn = 32; //Pound down 32 units per second.
		return (myreturn);
	}
	
	msizea = othertree.maxs_x - othertree.mins_x;
	msizeb = othertree.maxs_y - othertree.mins_y;
	
	//print(ftos(msizea), "A\n");
	//print(ftos(msizeb), "B\n");
	//print(ftos(mytank.vehicle_pounddownclass), "Class\n");
	
	if (mytank.vehicle_pounddownclass >= 4) {
		if (msizea > 220
		&&  msizeb > 220) {
			myreturn = 0;
		} else if (msizea > 200
			&& msizeb > 200) {
			myreturn = 0.1;
		} else if (msizea > 180
			&& msizeb > 180) {
			myreturn = 0.2;
		} else if (msizea > 160
			&& msizeb > 160) {
			myreturn = 0.4;	
		} else if (msizea > 140
			&& msizeb > 140) {
			myreturn = 1;
		} else if (msizea > 120
			&& msizeb > 120) {
			myreturn = 2;
		} else if (msizea > 100
			&& msizeb > 100) {
			myreturn = 8;
		} else if (msizea > 80
			&& msizeb > 80) {
			myreturn = 16;
		} else {
			myreturn = 32;
		}
	} else if (mytank.vehicle_pounddownclass >= 3) {
		if (msizea > 200
		&&  msizeb > 200) {
			myreturn = 0;
		} else if (msizea > 180
			&& msizeb > 180) {
			myreturn = 0.1;
		} else if (msizea > 160
			&& msizeb > 160) {
			myreturn = 0.2;
		} else if (msizea > 140
			&& msizeb > 140) {
			myreturn = 0.4;	
		} else if (msizea > 120
			&& msizeb > 120) {
			myreturn = 1;
		} else if (msizea > 100
			&& msizeb > 100) {
			myreturn = 2;
		} else if (msizea > 80
			&& msizeb > 80) {
			myreturn = 8;
		} else if (msizea > 60
			&& msizeb > 60) {
			myreturn = 16;
		} else {
			myreturn = 32;
		}
	} else if (mytank.vehicle_pounddownclass >= 2) {
		if (msizea > 150
		&&  msizeb > 150) {
			myreturn = 0;
		} else if (msizea > 130
			&& msizeb > 130) {
			myreturn = 0.1;
		} else if (msizea > 110
			&& msizeb > 110) {
			myreturn = 0.2;
		} else if (msizea > 90
			&& msizeb > 90) {
			myreturn = 0.4;	
		} else if (msizea > 70
			&& msizeb > 70) {
			myreturn = 1;
		} else if (msizea > 50
			&& msizeb > 50) {
			myreturn = 2;
		} else if (msizea > 40
			&& msizeb > 40) {
			myreturn = 8;
		} else if (msizea > 30
			&& msizeb > 30) {
			myreturn = 16;
		} else {
			myreturn = 32;
		}
	} else if (mytank.vehicle_pounddownclass >= 1) {
		if (msizea > 130
		&&  msizeb > 130) {
			myreturn = 0;
		} else if (msizea > 110
			&& msizeb > 110) {
			myreturn = 0.1;
		} else if (msizea > 90
			&& msizeb > 90) {
			myreturn = 0.2;
		} else if (msizea > 80
			&& msizeb > 80) {
			myreturn = 0.4;	
		} else if (msizea > 64
			&& msizeb > 64) {
			myreturn = 1;
		} else if (msizea > 50
			&& msizeb > 50) {
			myreturn = 2;
		} else if (msizea > 40
			&& msizeb > 40) {
			myreturn = 8;
		} else if (msizea > 30
			&& msizeb > 30) {
			myreturn = 16;
		} else {
			myreturn = 32;
		}
	} else {
		if (msizea > 120
		&&  msizeb > 120) {
			myreturn = 0;
		} else if (msizea > 100
			&& msizeb > 100) {
			myreturn = 0.1;
		} else if (msizea > 80
			&& msizeb > 80) {
			myreturn = 0.2;
		} else if (msizea > 70
			&& msizeb > 70) {
			myreturn = 0.4;	
		} else if (msizea > 64
			&& msizeb > 64) {
			myreturn = 1;
		} else if (msizea > 50
			&& msizeb > 50) {
			myreturn = 2;
		} else if (msizea > 30
			&& msizeb > 30) {
			myreturn = 8;
		} else if (msizea > 20
			&& msizeb > 20) {
			myreturn = 16;
		} else {
			myreturn = 32;
		}
	}
	
	
	return (myreturn);
}

float tankt27_EvaluateMaterialHit(entity hitent, float currentvalue)
{
		float newiterforward;
		float hitmaterial;
		
		if(hitent.ballistics_density > 1) {
			//Not going to go below 1. For less dense materials standard explosion iter forward
			newiterforward = currentvalue / hitent.ballistics_density;
		} else {
			//Only materials more dense than 1
			hitmaterial = W_EvaluateMaterialHit();
		
			switch(hitmaterial)
			{
			case 1:
				newiterforward = currentvalue / autocvar_g_ballistics_density_metal;
				break;
			case 2:
				newiterforward = currentvalue / autocvar_g_ballistics_density_metal;
				break;
			case 3:
				newiterforward = currentvalue / autocvar_g_ballistics_density_stone;
				break;
			case 4:
				newiterforward = currentvalue / autocvar_g_ballistics_density_brick;
				break;
			case 5:
				newiterforward = currentvalue / autocvar_g_ballistics_density_concrete;
				break;
			default:
				//Otherwise change nothing
				newiterforward = currentvalue;
				break;
			}
		}
		return newiterforward;
}

void tankt27_vehicles_damage_hitboxft(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.vehicle_health <= 0)
	{
		//print("FWD DMG\n");
		self.event_damage       = func_null;
   		self.takedamage         = DAMAGE_NO;
    		self.touch              = func_null;
    		self.think              = func_null;
    		self.deadflag           = DEAD_DEAD;
    		self.solid      = SOLID_NOT;
	} else {
		self.dmg_time = time;
	
		damage = vehicles_evaldamage(damage, deathtype);
		
		if(self.vehicle_tankresists == 1) {
    			damage = vehicles_evaltankdamage(damage, deathtype);
    		}
		
		self.vehicle_health -= damage;
		
		if(sound_allowed(MSG_BROADCAST, attacker))
            		spamsound (self, CH_PAIN, "object/impact_metal_3.ogg", VOL_BASE, ATTN_NORM);
			
		//print("DMG\n");
	}
}

void tankt27_vehicles_damage_hitboxbk(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.vehicle_health <= 0)
	{
		self.event_damage       = func_null;
   		self.takedamage         = DAMAGE_NO;
    		self.touch              = func_null;
    		self.think              = func_null;
    		self.deadflag           = DEAD_DEAD;
    		self.solid      = SOLID_NOT;
	} else {
		float ardamage; //Damage to armor
		self.dmg_time = time;
		ardamage = vehicles_evaldamage(damage, deathtype);
		self.vehicle_health -= ardamage;
		
		if(sound_allowed(MSG_BROADCAST, attacker))
            		spamsound (self, CH_PAIN, "object/impact_metal_4.ogg", VOL_BASE, ATTN_NORM);
		
		self = self.owner;
	 	vehicles_damage(inflictor, attacker, damage, deathtype, hitloc, force);
		
		//print("BKDMG\n");
	}
}

void tankt27_vehicles_touch()
{
    // Vehicle currently in use
    if(self.owner)
    {
        if(other != world)
        if(vehicles_crushable(other))
        {
	    if((self.origin_z + self.maxs_z) > (other.origin_z)) //If player or creature is ontop of tank, do not crush.
            if(vlen(self.velocity) != 0) {
	    	float dmgalgo;
		dmgalgo = autocvar_g_vehicles_crush_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012);
                Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
	    }

            return; // Dont do selfdamage when hitting "soft targets".
	} else if (vehicles_lightvehicle(other)) {
		if(vlen(self.velocity) != 0) {
			float dmgalgo;
			dmgalgo = (self.mass/(self.mass + other.mass)) * (autocvar_g_vehicles_crash_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012));
                	Damage(other, self, self.owner, dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
			
			makevectors(other.angles);
			setorigin(other, (other.origin + v_up * -2)); //Down 2 qunits
		}

            return; // Dont do selfdamage when hitting cars and light planes
	} else if (vehicles_mediumvehicle(other)) {
		//Less damage to medium vehicles
		if(vlen(self.velocity) != 0) {
			float dmgalgo;
			dmgalgo = (self.mass/(self.mass + other.mass)) * ((autocvar_g_vehicles_crash_dmg * 0.1) * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012));
                	Damage(other, self, self.owner, dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
			
			makevectors(other.angles);
			setorigin(other, (other.origin + v_up * -2)); //Down 2 qunits
		}

            return; // Dont do selfdamage when hitting cars and light planes    
        } else if (self.flags & FL_ONGROUND) {
		//print(strcat(other.netname, " model ", other.model, " etc\n"));
		//print(ftos(other.nopounddown), "no pound down", etos(other), "\n");

		if (other.classname == "building" && other.multitool_hitbox != world
		&& (multitool_tankcrushableextra(other.multitool_hitbox.count)))
		{
			//Damage barbed wire, wooden stakes, wire fence
				//float dmgalgo;
				//dmgalgo = autocvar_g_vehicles_crush_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012);
                
				Damage(other.multitool_hitbox, world, world, 
				(autocvar_g_vehicles_crush_dmg * 120 * frametime), DEATH_BATTERINGRAM, 
				'0 0 0', 
				'0 0 0');
				//print("Damaging tank destroyable\n");
		} else if (other.classname == "building" && other.multitool_isscaffold) {
			//Damage scaffolds
			Damage(other, world, world, 
				(autocvar_g_vehicles_crush_dmg * 120 * frametime), DEATH_BATTERINGRAM, 
				'0 0 0', 
				'0 0 0');
		} else if (other.nopounddown)
		{
			if (other.isfurniture && other.classname == "building") {
				if(other.multitool_hitbox)
				if((self.origin_z + self.maxs_z) > (other.origin_z)) //item is ontop of tank, do not crush.
            			if(vlen(self.velocity) != 0) {
	    				float dmgalgo;
					dmgalgo = autocvar_g_vehicles_crush_dmg * 30;
                			Damage(other.multitool_hitbox, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
	    			}
			}
		} else {
			if(other.classname == "tree") {
				local float maywepounddown;
				
				maywepounddown = 0;
				maywepounddown = tankt27_maywepounddown(self, other);
				
				if (maywepounddown) {
					makevectors(other.angles);
					setorigin(other, (other.origin + v_up * (maywepounddown * -1))); //Down maywepounddown qunits
		 		}
			} else if (
		 	( strstrofs(other.model, "tree", 0) != -1 )
		 	|| ( strstrofs(other.model, "lightpost", 0) != -1 )
		 	|| ( strstrofs(other.model, "peach", 0) != -1 )
		 	|| ( strstrofs(other.model, "statue", 0) != -1 )
		 	 ) {
		 		makevectors(other.angles);
				setorigin(other, (other.origin + v_up * -32)); //Down 32 qunits
		  	}
		}
	}

        if(self.play_time < time)
        if(self.vehicle_impact)
            self.vehicle_impact();

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

void tankt27_vehicles_touch2()
{
    //This is mostly the same as above but whatever is set as self.subordinate
    //is tested for weather it is above or below other rather than self
    //Used for tanks with hitboxes other than the main one: max is thus the max of the subordinate hitbox
    //self.subordinate is set at tank_spawn (usually to the forward hitbox)
    // Vehicle currently in use
    if(self.owner)
    {
        if(other != world)
        if(vehicles_crushable(other))
        {
	    if((self.subordinate.origin_z + self.subordinate.maxs_z) > (other.origin_z)) { //If player or creature is ontop of tank, do not crush.
            	if(vlen(self.velocity) != 0) {
	    		float dmgalgo;
			dmgalgo = autocvar_g_vehicles_crush_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012);
                	Damage(other, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
	    	}
	    } else if(vlen(self.velocity) != 0) {
	    	//Push player etc
		makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1'); //Inverted pitch on models
		entity oldself; oldself = self; self = other;
		movelib_move_simple(normalize(v_forward * oldself.owner.movement_x),oldself.subordinatespeed,oldself.subordinateinertia);
	    	self = oldself;
	    }

            return; // Dont do selfdamage when hitting "soft targets".
	} else if (vehicles_lightvehicle(other)) {
		if(vlen(self.velocity) != 0) {
			float dmgalgo;
			dmgalgo = (self.mass/(self.mass + other.mass)) * (autocvar_g_vehicles_crash_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012));
                	Damage(other, self, self.owner, dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
			
			makevectors(other.angles);
			setorigin(other, (other.origin + v_up * -2)); //Down 2 qunits
		}

            return; // Dont do selfdamage when hitting cars and light planes
	} else if (vehicles_mediumvehicle(other)) {
		//Less damage to medium vehicles
		if(vlen(self.velocity) != 0) {
			float dmgalgo;
			dmgalgo = (self.mass/(self.mass + other.mass)) * ((autocvar_g_vehicles_crash_dmg * 0.1) * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012));
                	Damage(other, self, self.owner, dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
			
			makevectors(other.angles);
			setorigin(other, (other.origin + v_up * -2)); //Down 2 qunits
		}

            return; // Dont do selfdamage when hitting cars and light planes    
        } else if (self.flags & FL_ONGROUND) {
		//print(strcat(other.netname, " model ", other.model, " etc\n"));
		if (other.classname == "building" && other.multitool_hitbox != world
		&& (multitool_tankcrushableextra(other.multitool_hitbox.count)))
		{
			//Damage barbed wire, wooden stakes, wire fence
				//float dmgalgo;
				//dmgalgo = autocvar_g_vehicles_crush_dmg * (self.mass*(vlen((self.velocity-other.velocity)))*0.0000012);
                
				Damage(other.multitool_hitbox, world, world, 
				(autocvar_g_vehicles_crush_dmg * 120 * frametime), DEATH_BATTERINGRAM, 
				'0 0 0', 
				'0 0 0');
				//print("Damaging tank destroyable2\n");
		} else if (other.classname == "building" && other.multitool_isscaffold) {
			//Damage scaffolds
			Damage(other, world, world, 
				(autocvar_g_vehicles_crush_dmg * 120 * frametime), DEATH_BATTERINGRAM, 
				'0 0 0', 
				'0 0 0');
		} else if (other.nopounddown)
		{
			if (other.isfurniture && other.classname == "building") {
				if(other.multitool_hitbox)
				if((self.origin_z + self.maxs_z) > (other.origin_z)) //item is ontop of tank, do not crush.
            			if(vlen(self.velocity) != 0) {
	    				float dmgalgo;
					dmgalgo = autocvar_g_vehicles_crush_dmg * 30;
                			Damage(other.multitool_hitbox, self, self.owner, autocvar_g_vehicles_crush_dmg + dmgalgo, DEATH_VHCRUSH, '0 0 0', normalize(other.origin - self.origin) * autocvar_g_vehicles_crush_force);
	    			}
			}
		} else {
			if(other.classname == "tree") {
				local float maywepounddown;
				
				maywepounddown = 0;
				maywepounddown = tankt27_maywepounddown(self, other);
				
				if (maywepounddown) {
					makevectors(other.angles);
					setorigin(other, (other.origin + v_up * (maywepounddown * -1))); //Down maywepounddown qunits
		 		}
			} else if (
			( strstrofs(other.model, "tree", 0) != -1 )
			|| ( strstrofs(other.model, "lightpost", 0) != -1 )
			|| ( strstrofs(other.model, "peach", 0) != -1 )
			|| ( strstrofs(other.model, "statue", 0) != -1 )
			 ) {
			 	makevectors(other.angles);
				setorigin(other, (other.origin + v_up * -32)); //Down 32 qunits
			 }
		}
	}

        if(self.play_time < time)
        if(self.vehicle_impact)
            self.vehicle_impact();

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

void tankt27_vehicles_touch_hitbox()
{
	self = self.owner;
	tankt27_vehicles_touch2(); //This way self.subordinate is tested for max_z rather than self
}

void tankt27_impact_hitbox()
{
	self = self.owner;
	self.vehicle_impact();
}

void tankt27_spawn_hitbox(float position, entity vehic, entity hitbox, vector min_s, vector max_s, float fwd_s, float vehic_health)
{
    hitbox.owner              = vehic;
    if (position == 1) {
    	//Back armor
    	hitbox.touch              = tankt27_vehicles_touch_hitbox;
    	hitbox.event_damage       = tankt27_vehicles_damage_hitboxbk;
    } else {
    	//Front armor
    	hitbox.touch              = tankt27_vehicles_touch_hitbox;
    	hitbox.event_damage       = tankt27_vehicles_damage_hitboxft;
	hitbox.vehicle_tankresists = 1; //Front armor gets extra protections
    }
    hitbox.buff_wont_ignite = vehic.buff_wont_ignite;
    hitbox.bot_attack         = TRUE;
    hitbox.iscreature         = TRUE;
    hitbox.teleportable       = FALSE; // no teleporting for vehicles, too buggy
    hitbox.damagedbycontents	= TRUE;
    hitbox.movetype           = MOVETYPE_WALK;
    hitbox.solid              = SOLID_SLIDEBOX;
    hitbox.takedamage         = DAMAGE_AIM;
    hitbox.deadflag           = DEAD_NO;
    hitbox.bot_attack         = TRUE;
    hitbox.flags              = FL_NOTARGET;
    hitbox.think              = func_null;
    hitbox.vehicle_health = vehic_health;
    setsize(hitbox, min_s, max_s);
    makevectors(vehic.angles_x * '-1 0 0' + vehic.angles_y * '0 1 0' + vehic.angles_z * '0 0 1'); //Inverted pitch on models
    setorigin(hitbox, (vehic.origin + v_forward * fwd_s)); //Forward X qunits
    follow_sameorigin(hitbox, vehic); //Follow vehic
    
    hitbox.damageforcescale = 0.03;
    hitbox.ballistics_density = autocvar_g_ballistics_density_metal;
}

void tankt27_hitbox_die(entity hitbox)
{
    hitbox.health             = 0;
    hitbox.event_damage       = func_null;
    hitbox.takedamage         = DAMAGE_NO;
    hitbox.touch              = func_null;
    hitbox.think              = func_null;
    hitbox.deadflag           = DEAD_DEAD;
    hitbox.movetype           = MOVETYPE_NONE;
    hitbox.solid      = SOLID_NOT;
}

void tankt27_FragsOverTime (void)
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
	if (self.cnt >= autocvar_g_vehicle_tankt27_cannon_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}


void tankt27_FragsOverTimeSpawn (entity gren)
{
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	e.think = tankt27_FragsOverTime;
	e.count = floor(autocvar_g_vehicle_tankt27_cannon_fragments / autocvar_g_vehicle_tankt27_cannon_fragments_frames)+1;
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void tankt27_Grenade_Explode2 (void)
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
	iterfwd = tankt27_EvaluateMaterialHit(other, autocvar_g_vehicle_tankt27_cannon_iterforward);
	//print(sprintf("IterFWD %f \n", (iterfwd)));

	float	xc;
	for (xc = 0;xc < autocvar_g_vehicle_tankt27_cannon_iter;xc = xc + 1) {
	
		RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);

		OilFire_explosion_spawnoilburnermaybe(self);
		
		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
			if(autocvar_g_vehicle_tankt27_cannon_fragments_frames < 2)
			{
				//Start Grenade Fragmentation
				float	sc;
				for (sc = 0;sc < autocvar_g_vehicle_tankt27_cannon_fragments;sc = sc + 1) {
	
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
				tankt27_FragsOverTimeSpawn(self); //Spread out fragment spawning
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

void tankt27_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void tankt27_fire_cannon(string tagname)
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
	gren.use = tankt27_Grenade_Explode2;
	gren.touch = tankt27_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankt27_cannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	//if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	//else
	//	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float tankt27_aiframe()
{
    return FALSE;
}




//Add For multi
float tankt27_gunner_frame()
{
	entity vehic    = self.vehicle.owner;
	entity gun      = self.vehicle;
	entity gunner   = self;
	self = vehic;

	
	vehic.solid = SOLID_NOT;
	setorigin(gunner, vehic.origin + '0 0 32'); //+32 so not in ground

	gunner.velocity = vehic.velocity;
	


    if not (autocvar_g_vehicles_noauxaimforpassengervehic) {
    ////////////////////
    ////////////////////
        
    makevectors(gun.angles);
    
    float ftmp;
    vector ad;
    vector myvehicangles;
    myvehicangles = vehic.angles;
    
    
    ad = gettaginfo(gun, gettagindex(gun, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, vehic);
    
   
    crosshair_trace2(gunner);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(myvehicangles), AnglesTransform_FromAngles(ad))) - gun.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);



    // Yaw //KISS
    float gunnerangley;
    
   
    //Forward facing
    gunnerangley = gunner.v_angle_y - vehic.angles_y - vehic.tur_head.angles_y;
    
    
    //ftmp = autocvar_g_vehicle_tankt27_gun_turnspeed * sys_frametime;
    ftmp = autocvar_g_vehicle_tankt27_gun_turnspeed * sys_frametime;

    ftmp = bound(-ftmp, shortangle_f(gunnerangley - gun.angles_y, gun.angles_y), ftmp);
    gun.angles_y = anglemods(gun.angles_y + ftmp);

    // Pitch head
    ftmp = autocvar_g_vehicle_tankt27_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    gun.angles_x = bound(autocvar_g_vehicle_tankt27_gun_pitchlimit_down, gun.angles_x + ad_x, autocvar_g_vehicle_tankt27_gun_pitchlimit_up);
    
    ////////////////////
    ////////////////////
    }
	
	//Allow gunner to reload cannon too, so pilot doesn't have to get out
	if (gunner.impulse == 20) {
	if (gunner.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 gunner ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(gunner, vehic, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
	}
	}

	VEHICLE_UPDATE_PLAYER(gunner, health, tankt27);

	if(vehic.vehicle_flags & VHF_HASSHIELD)
		VEHICLE_UPDATE_PLAYER(gunner, shield, tankt27);

	if not (autocvar_g_vehicles_noauxaimforpassengervehic) {
		if (gun == vehic.gun1 || gun == vehic.gun2) {
			UpdateAuxiliaryXhair(gunner, trace_endpos, '1 0 0', 0);
		}
	}

	vehic.solid = SOLID_SLIDEBOX;
	gunner.BUTTON_ATCK = gunner.BUTTON_ATCK2 = gunner.BUTTON_CROUCH = 0;

	gunner.vehicle_ammo1_current = vehic.vehicle_ammo1_current;
    	gunner.vehicle_ammo1_max = vehic.vehicle_ammo1_max;
	gunner.vehicle_ammo2_current = vehic.vehicle_ammo2_current;
    	gunner.vehicle_ammo2_max = vehic.vehicle_ammo2_max;

	self = gunner;
	return 1;
}

void tankt27_gunner_exit(float _exitflag)
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

float tankt27_gunner_enter(float selectgun)
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
		self.gunner1 = other;
	}
	else
	{
		dprint("^1ERROR:^7Tried to enter a fully occupied vehicle!\n");
		return FALSE;
	}

	_gunner            = other;
	_gunner.vehicle    = _gun;
	_gun.switchweapon  = other.switchweapon;
	_gun.vehicle_exit  = tankt27_gunner_exit;

	other.vehicle_playerisgunner = 1;
	other.vehicle_playergunnervehicle  = self;
	other.vehicle_changeseat	= tankt27_gunner_enter;
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
	other.PlayerPhysplug    = tankt27_gunner_frame;
	other.flags             &~= FL_ONGROUND;

	msg_entity = other;
	WriteByte(MSG_ONE, SVC_SETVIEWPORT);
	WriteEntity(MSG_ONE, _gun.vehicle_viewport);
	WriteByte(MSG_ONE, SVC_SETVIEWANGLES);
	
		WriteAngle(MSG_ONE, _gun.angles_x + self.angles_x);    // tilt
		WriteAngle(MSG_ONE, _gun.angles_y + self.angles_y);    // yaw
		WriteAngle(MSG_ONE, 0);                             // roll

	_gun.vehicle_hudmodel.viewmodelforclient = other;

	CSQCVehicleSetup(other, other.hud);
	
    vh_player = other;
    vh_vehicle = _gun;
    MUTATOR_CALLHOOK(VehicleEnter);
    other = vh_player;
    _gun = vh_vehicle;

	return TRUE;
}

float tankt27vehicles_valid_pilot()
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

void tankt27_touch()
{

	if ((vlen(self.velocity) > autocvar_g_vehicles_maxenterspeed) || (self.gunner1 != world && self.gunner2 != world && self.gunner3 != world && self.gunner4 != world && self.gunner5 != world))
	{
		tankt27_vehicles_touch();
		return;
	}

	if(tankt27vehicles_valid_pilot())
	{
		if not(vehicles_evalenter(other)) return;
		
		if(self.gun1.phase <= time)
			if(tankt27_gunner_enter(0))
				return;
		
		if(self.gun2.phase <= time)
			if(tankt27_gunner_enter(0))
				return;
	}

	tankt27_vehicles_touch();
}



//Done For multi





float tankt27_frame()
{
    vector ad, vf;
    entity player, tankt27;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    tankt27 = self.vehicle;
    self   = tankt27;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;
    


    ad = gettaginfo(tankt27.gun0, gettagindex(tankt27.gun0, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankt27);
    UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload1) + ('0 1 0' * (1 - player.vehicle_reload1)), 0);
    
    vf = ad;
    ad = gettaginfo(tankt27.gun00, gettagindex(tankt27.gun00, "tag_cannon"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankt27);
    UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 1);
    //ad = 0.5 * (ad + vf);
    ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankt27.angles), AnglesTransform_FromAngles(ad))) - tankt27.gun0.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    //UpdateAuxiliaryXhair(player, trace_endpos, ('1 0 0' * player.vehicle_reload2) + ('0 1 0' * (1 - player.vehicle_reload2)), 2);
    
    // Rotate head
    ftmp = autocvar_g_vehicle_tankt27_gun_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    tankt27.gun0.angles_y = bound(autocvar_g_vehicle_tankt27_gun_turnlimit * -1, tankt27.gun0.angles_y + ad_y, autocvar_g_vehicle_tankt27_gun_turnlimit);

    // Pitch head
    ftmp = autocvar_g_vehicle_tankt27_gun_pitchspeed * sys_frametime;    
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    tankt27.gun0.angles_x = bound(autocvar_g_vehicle_tankt27_gun_pitchlimit_down, tankt27.gun0.angles_x + ad_x, autocvar_g_vehicle_tankt27_gun_pitchlimit_up);


    //fixedmakevectors(tankt27.angles);
    makevectors(tankt27.angles + '-2 0 0' * tankt27.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_tankt27_springlength, autocvar_g_vehicle_tankt27_springup, autocvar_g_vehicle_tankt27_springblend, autocvar_g_vehicle_tankt27_tiltlimit);

    if(tankt27.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("tankt27_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_tankt27_speed_stop);
                //tankt27.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0)
   	 {
	 	if(tankt27.angles_y > 180)  tankt27.angles_y -= 360;
    		if(tankt27.angles_y < -180) tankt27.angles_y += 360;
		tankt27.angles_y = bound(-184,tankt27.angles_y + ((player.movement_y * sys_frametime) / -6.66666),184);	
		
		if(tankt27.angles_y >= -1 && tankt27.angles_y <= -1)
            		tankt27.angles_y = 0;	

		////float degree_y;
		////player.angles_y = player.angles_y + ((player.movement_y * sys_frametime) / -6.66666);
		////degree_y = ((player.movement_y * sys_frametime) / -6.66666);
		////player.v_angle_y += degree_y;
		
		player.v_angle_y = tankt27.angles_y; //kiss

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
  		//////WriteAngle( MSG_ONE, tankt27.angles_x); 
  		//////WriteAngle( MSG_ONE, tankt27.angles_y);
  		//////WriteAngle( MSG_ONE, tankt27.angles_z);
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
                        tankt27.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        tankt27.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(tankt27.angles);
    			makevectors(tankt27.angles + '-2 0 0' * tankt27.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_oldtank_waterspeed_simple(player, autocvar_g_vehicle_tankt27_speed_walk),autocvar_g_vehicle_tankt27_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 4; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("tankt27_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_tankt27_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_tankt27_tiltlimit, self.angles_x, autocvar_g_vehicle_tankt27_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_tankt27_tiltlimit, self.angles_z, autocvar_g_vehicle_tankt27_tiltlimit);

    if(player.BUTTON_JUMP) {
    	tankt27.gun00.angles_x = bound(autocvar_g_vehicle_tankt27_cannon_pitchlimit_down, tankt27.gun00.angles_x + (autocvar_g_vehicle_tankt27_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankt27_cannon_pitchlimit_up);
    }
    
    if(player.BUTTON_CROUCH ) {
    	tankt27.gun00.angles_x = bound(autocvar_g_vehicle_tankt27_cannon_pitchlimit_down, tankt27.gun00.angles_x - (autocvar_g_vehicle_tankt27_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankt27_cannon_pitchlimit_up);
    }
    
    player.BUTTON_CROUCH    = 0;

    if(player.BUTTON_ATCK)
    {
        tankt27.cnt = time;
        if(tankt27.vehicle_ammo1 >= autocvar_g_vehicle_tankt27_machinegun_ammo_cost && tankt27.gun0.attack_finished_single <= time)
        {
            vector v;
            tankt27.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(tankt27.gun0, gettagindex(tankt27.gun0, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankt27_machinegun_spread, autocvar_g_vehicle_tankt27_machinegun_speed, 5, autocvar_g_vehicle_tankt27_machinegun_damage, autocvar_g_vehicle_tankt27_machinegun_headshotaddeddamage, autocvar_g_vehicle_tankt27_machinegun_force, DEATH_SPORTSTERGUN, PROJECTILE_BULLETRIFLE30, 1, autocvar_g_vehicle_tankt27_machinegun_bulletconstant, autocvar_g_vehicle_tankt27_machinegun_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	    
    UziFlash();
    sportster_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_mgun");
	 
	 sound (tankt27.gun0, CH_WEAPON_A, "weapons/uzi_fire_bass.ogg", VOL_BASE, ATTN_NORM);

	// End Ballistic bullet
	    
   if (autocvar_g_vehicle_tankt27_machinegun_expelbulletcasings == 1) {
  	if (autocvar_g_casings >= 2) {
		SpawnCasing (((random () * 50 + 50) * v_right) - 
		(v_forward * (random () * 25 + 25)) - 
		((random () * 5 - 70) * v_up), 2, 
		vectoangles(v_forward),'0 250 0', 100, 105, self);
	}
   }

            self = tankt27;

            tankt27.vehicle_ammo1 -= autocvar_g_vehicle_tankt27_machinegun_ammo_cost;
            tankt27.gun0.attack_finished_single = time + autocvar_g_vehicle_tankt27_machinegun_refire;
            player.vehicle_ammo1 = (tankt27.vehicle_ammo1 / autocvar_g_vehicle_tankt27_machinegun_ammo_max) * 100;
         
	    tankt27.gun0.count = 0; //Will have to press R to resume reload 
	    
	    //Overheating//
	    tankt27.gun0.cnt = tankt27.gun0.cnt + autocvar_g_vehicle_mg_lewis_machinegun_heatconstant;
         
	    if (tankt27.gun0.cnt > random() )
 	    {
		sprint(player, "Your machinegun overheated\n");
		
		pointparticles(particleeffectnum("shotgun_muzzleflash"), gettaginfo(tankt27.gun0, gettagindex(tankt27.gun0, "tag_casings")), v_forward * 2, 1);
		
		tankt27.gun0.attack_finished_single = tankt27.gun0.attack_finished_single + (autocvar_g_vehicle_mg_lewis_machinegun_cooldownwait * (tankt27.gun0.cnt + 1));
	    }
	    //Overheating//
        }
    }
    else
    {
    	if (tankt27.gun0.count == 1 && tankt27.vehicle_ammo1_current > 0) {
        vehicles_regen(tankt27.cnt, vehicle_ammo1, autocvar_g_vehicle_tankt27_machinegun_ammo_max,
                                           autocvar_g_vehicle_tankt27_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_tankt27_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
       	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
			tankt27.gun0.count = 1;
			sound (tankt27, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
    		//Reload from own stores //50 ammo, 2 player ammo = 1 vehic ammo,
		vehicles_replenishAmmo(player, tankt27, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 50, 2);
    	}  
	//Overheating and cooldown stuff://
	if (tankt27.gun0.cnt < autocvar_g_vehicle_mg_lewis_machinegun_heatmin) {
		tankt27.gun0.cnt = autocvar_g_vehicle_mg_lewis_machinegun_heatmin;
	} else {
		tankt27.gun0.cnt = tankt27.gun0.cnt - (autocvar_g_vehicle_mg_lewis_machinegun_cooldownrate * sys_frametime);
	}
	//Overheating and cooldown stuff Done//
    }

    if(player.BUTTON_ATCK2)
    {
        tankt27.cnt = time;
	if not(tankt27.gun00.count)
        if(tankt27.vehicle_ammo2 >= autocvar_g_vehicle_tankt27_cannon_ammo_cost && tankt27.tur_head.attack_finished_single <= time)
        {
            vector v;
            tankt27.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(tankt27.gun00, gettagindex(tankt27.gun00, "tag_cannon"));
            v_forward = normalize(v_forward);
            v += v_forward * 12;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankt27_cannon_spread, autocvar_g_vehicle_tankt27_cannon_speed, 5, autocvar_g_vehicle_tankt27_cannon_damage, autocvar_g_vehicle_tankt27_cannon_headshotaddeddamage, autocvar_g_vehicle_tankt27_cannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankt27_cannon_bulletconstant, autocvar_g_vehicle_tankt27_cannon_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 
	 
	 sound (tankt27.gun00, CH_WEAPON_A, "weapons/campingrifle_fire.wav", VOL_BASE, ATTN_NORM);

	// End Ballistic bullet

            pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);


            self = tankt27;
	    
	    makevectors(self.angles);
	    v = gettaginfo(tankt27.gun00, gettagindex(tankt27.gun00, "tag_cannon"));
            v_forward = normalize(v_forward);
	    
	    tankt27_fire_cannon("tag_cannon");


            tankt27.vehicle_ammo2 -= autocvar_g_vehicle_tankt27_cannon_ammo_cost;
            tankt27.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankt27_cannon_refire;
            player.vehicle_ammo2 = (tankt27.vehicle_ammo2 / autocvar_g_vehicle_tankt27_cannon_ammo_max) * 100;
            
	    tankt27.count = 0; //Will have to press R to resume reload 
	    tankt27.gun00.count = 1; //Will have to press R to reload gun, not semiauto, old tank
        }
    }
    else
    {
    	if (tankt27.count == 1) {
        vehicles_regen(tankt27.cnt, vehicle_ammo2, autocvar_g_vehicle_tankt27_cannon_ammo_max,
                                           autocvar_g_vehicle_tankt27_cannon_ammo_regen_pause,
                                           autocvar_g_vehicle_tankt27_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    	} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
		if (autocvar_g_casings >= 2)
		{
			if not(tankt27.count == 0 && tankt27.gun00.count == 0) {
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
		tankt27.count = 1;
		sound (tankt27, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		tankt27.gun00.count = 0;
    	}
	
	if (player.impulse == 20)
	if (player.BUTTON_HOOK) {
		//Reload from own stores //10 ammo, 10 player ammo = 50 vehic ammo, 10/0.20 = 50 (the normal one shot ammo cost for this weapon)
		vehicles_replenishAmmo(player, tankt27, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 10, 0.20);
	}
    }
    
    //tankt27_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(tankt27.dmg_time, vehicle_shield, autocvar_g_vehicle_tankt27_shield, autocvar_g_vehicle_tankt27_shield_regen_pause, autocvar_g_vehicle_tankt27_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(tankt27.dmg_time, vehicle_health, autocvar_g_vehicle_tankt27_health, autocvar_g_vehicle_tankt27_health_regen_pause, autocvar_g_vehicle_tankt27_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = tankt27.tur_head.frame;

    if(tankt27.gun00.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((tankt27.gun00.cnt - time) / tankt27.attack_finished_single) * 100;

    setorigin(player, tankt27.origin + '0 0 1' * TANKT27_MAX_z);
    tankt27.velocity = vehicles_tank_waterfriction(player, tankt27.velocity);
    player.velocity = tankt27.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, tankt27);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, tankt27);

    //VEHICLE_UPDATE_PLAYER2(player, ammo1_current, tankt27);
    //VEHICLE_UPDATE_PLAYER2(player, ammo1_max, tankt27);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_current, tankt27);
    //VEHICLE_UPDATE_PLAYER2(player, ammo2_max, tankt27);
    player.vehicle_ammo1_current = tankt27.vehicle_ammo1_current;
    player.vehicle_ammo1_max = tankt27.vehicle_ammo1_max;
    player.vehicle_ammo2_current = tankt27.vehicle_ammo2_current;
    player.vehicle_ammo2_max = tankt27.vehicle_ammo2_max;
    
    self = player;
    return 1;    
}
void tankt27_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_tankt27_speed_stop);

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
		
		
	}
	//done for multi
}

void tankt27_enter()
{
    self.touch = tankt27_touch; //Add
    self.nextthink = 0;  //Add

    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankt27_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankt27_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void tankt27_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = tankt27_think;
    self.touch = tankt27_vehicles_touch; //Added for multi
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
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
		if(vlen(self.velocity) > autocvar_g_vehicle_tankt27_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_NORMAL);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void tankt27_impact()
{
    if(autocvar_g_vehicle_tankt27_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_tankt27_bouncepain_x, autocvar_g_vehicle_tankt27_bouncepain_y, autocvar_g_vehicle_tankt27_bouncepain_z);    
}

void tankt27_headfade()
{
	self.think = tankt27_headfade;
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

void tankt27_blowup()
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

    b.loddistance1 = 320;
    b.loddistance2 = 640;
    b.loddistance3 = 1024;
    b.lodmodel1 = "models/vehicles/tankt27_lod1.iqm";
    b.lodmodel2 = "models/vehicles/tankt27_lod2.iqm";
    b.lodmodel3 = "models/vehicles/tankt27_lod3.iqm";
    setmodel(b,  "models/vehicles/tankt27.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    setmodel(h,  "models/vehicles/tankt27_cannon.iqm");
    g1.lodmodel1 = "models/vehicles/tankt27_mgun_lod1.iqm";
    g1.lodmodel2 = "models/vehicles/tankt27_mgun_lod2.iqm";
    setmodel(g1, "models/vehicles/tankt27_mgun.iqm");
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
    h.fade_rate     = 1 / min(autocvar_g_vehicle_tankt27_respawntime, 10);
    h.fade_time     = time;
    h.think         = tankt27_headfade;
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

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankt27_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankt27_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankt27_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankt27_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun0.alpha = self.gun00.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void tankt27_die()
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
	
	self.vehicle_exit(VHEF_EJECT);
	
	//done for multi

    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = tankt27_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
}

void tankt27_spawn(float _f)
{
    self.vehicle_pilotchangeseat = tankt27_gunner_enter; //Function to exec if pilot wants to change seat

    self.buff_wont_ignite = 1;
    self.vehicle_tankresists = 1;
    
    if(!self.gun0)
    {
    	self.loddistance1 = 320; //Lod0 Model somewhat complex, so only use when very close
	self.loddistance2 = 640;
	self.loddistance3 = 1024;
    	self.lodmodel1 = "models/vehicles/tankt27_lod1.iqm";
	self.lodmodel2 = "models/vehicles/tankt27_lod2.iqm";
	self.lodmodel3 = "models/vehicles/tankt27_lod3.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
        self.gun0               = spawn();
		self.gun1 = spawn(); //Added for multi
		self.gun2 = spawn(); //Added for multi
	
	//Overheating and cooldown stuff//
	self.gun0.cnt = autocvar_g_vehicle_mg_lewis_machinegun_heatmin;
	//Overheating and cooldown stuff//   
	
        self.gun00               = spawn();
	self.gun0.owner = self;
	self.gun0.lodowner = 1; //Use owner origin for computing LOD
	self.gun0.lodmodel1 = "models/vehicles/tankt27_mgun_lod1.iqm";
	self.gun0.lodmodel2 = "models/vehicles/tankt27_mgun_lod2.iqm";
        setmodel(self.gun0, "models/vehicles/tankt27_mgun.iqm");
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
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun0, "tag_gcamera");
	setattachment(self.vehicle_viewport, self, "tag_camera");
	
	
		//Added for multi
		self.vehicle_flags |= VHF_MULTISLOT;

		setmodel(self.gun1, "null");
		self.gun1.owner = self;
        	setattachment(self.gun1, self, "tag_cannon_pivot");
		self.gun1.owner = self;

		setmodel(self.gun2, "null");
		self.gun2.owner = self;
        	setattachment(self.gun2, self, "tag_cannon_pivot");
		self.gun2.owner = self;
	
		vehicle_addplayerslot(self, self.gun1, HUD_TANK, "null", tankt27_gunner_frame, tankt27_gunner_exit);
		setattachment(self.gun1.vehicle_viewport, self.gun1, "tag_cannon_pivot");
		self.gun1.vehicle_viewport.origin = '-96 32 16';
		
		vehicle_addplayerslot(self, self.gun2, HUD_TANK, "null", tankt27_gunner_frame, tankt27_gunner_exit);
		setattachment(self.gun2.vehicle_viewport, self.gun2, "tag_cannon_pivot");
		self.gun2.vehicle_viewport.origin = '-96 -32 16';
	
		//End  for multi	
    
    }

    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = tankt27_think;
    self.touch              = tankt27_vehicles_touch;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_tankt27_health;
    self.vehicle_shield     = autocvar_g_vehicle_tankt27_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    self.alpha              = self.tur_head.alpha = self.gun0.alpha = self.gun00.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun00.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = tankt27_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
}

void spawnfunc_vehicle_tankt27()
{
    if(!autocvar_g_vehicle_tankt27)
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
    precache_model ( "models/vehicles/tankt27.iqm");
    precache_model ( "models/vehicles/tankt27_lod1.iqm");
    precache_model ( "models/vehicles/tankt27_lod2.iqm");
    precache_model ( "models/vehicles/tankt27_lod3.iqm");
    precache_model ( "models/vehicles/tankt27_mgun.iqm");
    precache_model ( "models/vehicles/tankt27_mgun_lod1.iqm");
    precache_model ( "models/vehicles/tankt27_mgun_lod2.iqm");
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    precache_model ( "models/vehicles/tankt27_cannon.iqm");
    precache_model ( "models/uziflash.md3");

    precache_sound ( "weapons/campingrifle_fire.wav" );
    precache_sound ( "weapons/uzi_fire_bass.ogg" );
    precache_sound ( "weapons/grenade_fire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    
    precache_sound ( "vehicles/tankt27_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/tankt27_jump.wav");
    precache_sound ( "vehicles/tankt27_strafe.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "vehicles/tankt27_land.wav");

    if(autocvar_g_vehicle_tankt27_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_tankt27_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_tankt27_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = 1023;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "T27",
             "models/vehicles/tankt27.iqm",
             "null",
             "null",
             "", "tag_camera", "",
             HUD_TANK,
             TANKT27_MIN, TANKT27_MAX,
             FALSE,
             tankt27_spawn, autocvar_g_vehicle_tankt27_respawntime,
             tankt27_frame,
             tankt27_enter, tankt27_exit,
             tankt27_die,   tankt27_think,
             FALSE, 
             autocvar_g_vehicle_tankt27_health,
             autocvar_g_vehicle_tankt27_shield, autocolor, autocvar_g_vehicle_tankt27_machinegun_ammo_max * 10, autocvar_g_vehicle_tankt27_cannon_ammo_max * 3))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}
#endif // SVQC
