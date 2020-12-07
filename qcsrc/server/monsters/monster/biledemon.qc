/**
 * Special purpose fields:
 * .delay - time at which to check if biledemon's enemy is still in range
 * .enemy - enemy of this biledemon
 * .state - state of the biledemon, see BILEDEMON_STATE_*
 */
 
// cvars
float autocvar_g_monster_biledemon;
float autocvar_g_monster_biledemon_stopspeed;
float autocvar_g_monster_biledemon_attack_leap_damage;
float autocvar_g_monster_biledemon_attack_leap_delay;
float autocvar_g_monster_biledemon_attack_leap_force;
float autocvar_g_monster_biledemon_attack_leap_range;
float autocvar_g_monster_biledemon_attack_leap_speed;
float autocvar_g_monster_biledemon_attack_stand_damage;
float autocvar_g_monster_biledemon_attack_stand_delay;
float autocvar_g_monster_biledemon_attack_stand_range;
float autocvar_g_monster_biledemon_health;
float autocvar_g_monster_biledemon_idle_timer;
float autocvar_g_monster_biledemon_speed_walk;
float autocvar_g_monster_biledemon_speed_run;
float autocvar_g_monster_biledemon_target_recheck_delay;
float autocvar_g_monster_biledemon_target_range;

// biledemon animations
#define biledemon_anim_attackleap		 8
#define biledemon_anim_attackrun1		 13
#define biledemon_anim_attackrun2		 15
#define biledemon_anim_attackrun3		 16
#define biledemon_anim_attackstanding1	2
#define biledemon_anim_attackstanding2	11
#define biledemon_anim_attackstanding3	12
#define biledemon_anim_blockend		   7
#define biledemon_anim_blockstart		 8
#define biledemon_anim_deathback1		 0
#define biledemon_anim_deathback2		 0
#define biledemon_anim_deathback3		 0
#define biledemon_anim_deathfront1		1
#define biledemon_anim_deathfront2		1
#define biledemon_anim_deathfront3		1
#define biledemon_anim_deathleft1		 0
#define biledemon_anim_deathleft2		 0
#define biledemon_anim_deathright1		1
#define biledemon_anim_deathright2		1
#define biledemon_anim_idle			   7
#define biledemon_anim_painback1		  9
#define biledemon_anim_painback2		  9
#define biledemon_anim_painfront1		 10
#define biledemon_anim_painfront2		 10
#define biledemon_anim_runbackwards	   14
#define biledemon_anim_runbackwardsleft   22
#define biledemon_anim_runbackwardsright  21
#define biledemon_anim_runforward		 13
#define biledemon_anim_runforwardleft	 20
#define biledemon_anim_runforwardright	19
#define biledemon_anim_spawn			  6
#define biledemon_anim_deadback1			  17
#define biledemon_anim_deadfront1			18
#define biledemon_anim_stone			  31
#define biledemon_anim_attackcrossbow	11


const vector BILEDEMON_MIN				 = '-16 -16 -24';
const vector BILEDEMON_MAX				 = '16 16 45';

const vector BILEDEMON_DEAD_MIN				 = '-18 -18 -30';
const vector BILEDEMON_DEAD_MAX				 = '18 18 2';

#define BILEDEMON_STATE_SPAWNING		0
#define BILEDEMON_STATE_IDLE			1
#define BILEDEMON_STATE_ANGRY			2
#define BILEDEMON_STATE_ATTACK_LEAP	3

void biledemon_spawn();
void spawnfunc_monster_biledemon();
void biledemon_think();

void biledemon_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void biledemon_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void biledemon_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("biledemon");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, BILEDEMON_DEAD_MIN, BILEDEMON_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	//We set think below to load the deadbody "animation", then fade
	self.nextthink	  	= time + 0.5;
	self.pain_finished  = self.nextthink;
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
	
	
	//If we're allowed to drop a weapon we shall.
	//Since we have only medieval we're a medieval weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (autocvar_g_monsters_dropweapon_medieval) {
		if (autocvar_g_monsters_dropweapon_medieval >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_medieval > random())
		{
				monsterdropweapon = 1;
		}
	}
	if (monsterdropweapon && self.weaponentity.count) {
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weaponentity.count == 1) {
			W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 3) {
			W_ThrowNewWeapon(self, WEP_MORGENSTERN, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_MORGENSTERN, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 4) {
			W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 6) {
			W_ThrowNewWeapon(self, WEP_TETSUBO, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TETSUBO, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = biledemon_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_deathback1;
	} else {
		self.think = biledemon_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

void biledemon_check_torch()
{
	if (self.torch_lit == 1) {
		if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
			setmodel(self.weaponentity,  "models/weapons/v_torch.md3");
			self.torch_lit = 0;
		}
	} else {
		if not ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
			setmodel(self.weaponentity,  "models/weapons/v_torch_lit.md3");
			self.torch_lit = 1;
		}
	}
}

float biledemon_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_broadaxe_primary_refire;
	} else if (self.weaponentity.count == 2) {
		return autocvar_g_balance_warhammerspiked_primary_refire;
	} else if (self.weaponentity.count == 3) {
		return autocvar_g_balance_morgenstern_primary_refire;
	} else if (self.weaponentity.count == 4) {
		return autocvar_g_balance_torch_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_crossbowdtwr_primary_refire;
	} else if (self.weaponentity.count == 6) {
		return autocvar_g_balance_tetsubo_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_lightcrossbow_primary_refire;
	} else {
		return autocvar_g_monster_biledemon_attack_stand_delay;
	}
}

float biledemon_attack_armed()
{
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_Warhammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_Morgenstern_Attack();
	} else if (self.weaponentity.count == 4) {
		W_Torch_Attack();
	} else if (self.weaponentity.count == 5) {
		if (self.enemy != world) {
			//Skeleton style "aiming", won't be correct for lowgrav
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_crossbowdtwr_primary_speed, 10.25);
			makevectors(self.v_angle);
		}
		W_CrossbowBolt_Attack();
	} else if (self.weaponentity.count == 6) {
		W_Tetsubospiked_Attack();
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			//Skeleton style "aiming", won't be correct for lowgrav
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_lightcrossbow_primary_speed, 15.25);
			makevectors(self.v_angle);
		}
		W_LightCrossbowBolt_Attack();
	}
	
	return biledemon_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void biledemon_attack_standing()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float myrefire;
	float rand = random(), dot = 0, bigdmg = 0;

	self.velocity_x = 0;
	self.velocity_y = 0;
	
	if(self.monster_owner == self.enemy)
	{
		self.enemy = world;
		return;
	}
	
	bigdmg = autocvar_g_monster_biledemon_attack_stand_damage * self.scale;

	//print("biledemon attacks!\n");
	makevectors (self.angles);
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		myrefire = biledemon_attack_armed();
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_biledemon_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = biledemon_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = biledemon_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = biledemon_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = biledemon_anim_attackstanding2;
		else
			self.frame = biledemon_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.4);
	else
		self.nextthink = time + myrefire;
}


void biledemon_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_biledemon_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_biledemon_attack_leap_force;
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		biledemon_attack_armed();
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy biledemon's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void biledemon_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = biledemon_attack_refire();
	else
		myrefire = autocvar_g_monster_biledemon_attack_leap_delay;

	// face the enemy	
	self.state = BILEDEMON_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = biledemon_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_biledemon_attack_leap_speed;
}

/**
 * Main biledemon think function.
 */
void biledemon_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = biledemon_anim_stone;
	
	if (self.weaponentity && self.weaponentity.count == 4)
		biledemon_check_torch();
	
	self.think = biledemon_think;
	
	if (self.state == BILEDEMON_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = BILEDEMON_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == BILEDEMON_STATE_SPAWNING) {
		// become idle when biledemon spawned
		if (self.stoned || self.frozen) self.frame = biledemon_anim_stone; else self.frame = biledemon_anim_idle;
		self.state = BILEDEMON_STATE_IDLE;
	}
	
	if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.enemy)
	if (self.enemy.team == self.team || self.monster_owner == self.enemy)
		self.enemy = world;
	
	if (!self.stoned && !self.frozen)
	if (self.sex == SEX_MALE)
	if (self.body_phal)
	if (!self.body_phal_stat)
	{
		//if ((self.enemy != world)
		//&& (self.enemy.classname == "player" || self.enemy.classname == "body")
		//&& (self.body_phal.cnt == 0))
		//{
		//		self.body_phal.cnt = 1;
		//		setmodel(self.body_phal,  "models/monsters/minotaur_bayonet_ex.iqm");
		//} else {
		//	if(self.body_phal.cnt > 0)
		//	{
		//		self.body_phal.cnt = self.body_phal.cnt - 0.1;
		//		
		//		if(self.body_phal.cnt <= 0)
		//		{
		//			self.body_phal.cnt = 0;
		//			setmodel(self.body_phal,  "models/monsters/minotaur_bayonet.iqm");
		//		}	
		//	}
		//}
	}
	
	if(teamplay && autocvar_g_monsters_teams && self.monster_owner.team != self.team)
		self.monster_owner = world;	
	
	// remove enemy that ran away
	if (self.enemy)
	if (self.delay <= time) // check if we can do the rescan now
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_biledemon_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_biledemon_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_biledemon_target_recheck_delay;
	}

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_broadaxe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 2)
			mystandattackrange = autocvar_g_balance_warhammerspiked_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 3)
			mystandattackrange = autocvar_g_balance_morgenstern_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 4)
			mystandattackrange = autocvar_g_balance_torch_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 6)
			mystandattackrange = autocvar_g_balance_tetsubo_primary_melee_range * 0.94;
		else
			mystandattackrange = autocvar_g_monster_biledemon_attack_stand_range * self.scale;
		
		// make sure biledemon is angry
		self.state = BILEDEMON_STATE_ANGRY;
		

		// this biledemon has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= mystandattackrange * 40)
		{
			if (random() > 0.90) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20;
				enemyDistance = autocvar_g_monster_biledemon_attack_stand_range;
			}
		}
		
		//Magic Attack
		if (self.havocbot_nextmagicthink < time) {
			self.mana = 90000; //Always, we have enough
			self.havocbot_nextmagicthink =  time+6;
			self.v_angle = self.angles;
			makevectors(self.v_angle);
			havocbot_castmagic();
		}
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (!self.frozen)
		if (!self.stoned)
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
		if (mySpeed <= 30)
			if (enemyDistance <= mystandattackrange) 
			{
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				biledemon_attack_standing();
				finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_biledemon_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				biledemon_attack_leap();
				finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if not(finished) 
	{
		monster_move(monster_mvmntimpare_demon(autocvar_g_monster_biledemon_speed_run), monster_mvmntimpare_demon(autocvar_g_monster_biledemon_speed_walk), autocvar_g_monster_biledemon_stopspeed, biledemon_anim_runforward, biledemon_anim_runforward, biledemon_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("biledemon is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = biledemon_anim_stone; else self.frame = ((mySpeed <= 20) ? biledemon_anim_idle : biledemon_anim_runforward);
		self.nextthink = time + autocvar_g_monster_biledemon_idle_timer * random();	
	}
}

/**
 * Spawn the biledemon.
 */
void biledemon_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_biledemon_health * self.scale;
	
	self.classname			= "monster_biledemon";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= BILEDEMON_STATE_SPAWNING;
	self.frame		  		= biledemon_anim_spawn;
	self.think		  		= biledemon_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	//self.gibscale = 0.8;
	self.vuln_movement_imparable = 0.25; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	
	if (random() > 0.7) {
		if (random() > 0.6)
			self.skin = 2; //Demon
		else
			self.skin = 6; //Demon
	} else if (random() > 0.6) {
		self.skin = 5; //Red
	} else {
		self.skin = 4; //Red
	}
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.monster_smell_bodyodor = self.smell_bodyodor = 0.6 + random();
	self.monster_smell_faeces = self.smell_faeces = 0.2 + random();
	self.monster_hasheightenedsenseofsmell = 0.5;
	
	self.vuln_isundead = 0.1; //Vuln to holy bolt for 10% damage
	
	self.spell_firewall = 5;
	
	self.resist_fire = 1;
	self.resist_blunt = 0.4;
	self.resist_bullet = 0.35;
	self.resist_crush = 0.45;
	self.resist_edged = 0.4;
	self.resist_pierce = 0.2;
	
	//self.resist_sound = 1;

		//Each respawn of this monster this becomes more likely since we don't reset anything
		if(random() > 0.5) {
			self.species = SPECIES_ANIMAL;
		}
		
		if not(self.sex) {
			self.sex = SEX_EUNICH;
		
			if (random() > 0.4)
			{
				self.sex = SEX_MALE;
			}
		}
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;

	wrand = random();
	if (wrand > 0.2 || self.monster_spawn_as_archer)
	{
		wrand = random();
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '180 -45 90';
		if (self.monster_spawn_as_archer == 1) 
		{
			//If you want to force it
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
			self.weaponentity.count = 11;
			self.weaponentity.angles    = '0 110 0';
		} else if (self.monster_spawn_as_archer == 2) 
		{
			//If you want to force it
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
			self.weaponentity.count = 5;
			self.weaponentity.angles    = '0 110 0';
		} else if (wrand > 0.60) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_broadaxe.md3");
			self.weaponentity.count = 1;
		} else if (wrand > 0.40) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
			self.weaponentity.count = 2;
		} else if (wrand > 0.25) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_morgenstern.md3");
			self.weaponentity.count = 3;
		} else if (wrand > 0.15) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_tetsubo.md3");
			self.weaponentity.count = 6;	
		} else if (wrand > 0.10) {
			if (autocvar_g_monsters_jitprecacheonly) {
				precache_model ("models/weapons/v_torch_lit.md3");
				precache_model ("models/weapons/v_torch.md3");
			}
			biledemon_check_torch();
			self.weaponentity.count = 4;
		} else {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_morgenstern.md3");
			self.weaponentity.count = 3;
		}
		//} else {
		//	if (random() > 0.75) {
		//		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
		//		self.weaponentity.count = 5;
		//		self.weaponentity.angles    = '0 110 0';
		//	} else {
		//		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
		//		self.weaponentity.count = 11;
		//		self.weaponentity.angles    = '0 110 0';
		//	}
		//}
		
		
		setattachment(self.weaponentity, self, "bip01 r hand");
		setorigin(self.weaponentity, '2.1 6 -1');    // Move attch spot up 8// forward 4// yes fscked up bone  

		wrand = random();
		if (wrand > 0.8)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			self.bomb1.origin = self.weaponentity.origin;
			setmodel(self.bomb1,  self.bomb1.model);
			setorigin(self.bomb1,  self.bomb1.origin);
			
			if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
				self.bomb1.angles    = '0 110 0';
			else
				self.bomb1.angles    = '-45 60 50';
			
			setattachment(self.bomb1, self, "hand_L");
		}
		
		//Head Ornament
		wrand = random();
		if (wrand > 0.2)
		{
			self.bomb2.alpha = 1;
			if (autocvar_g_monsters_jitprecacheonly > 1) {
				precache_model ("models/misc/playerhorns_head.iqm");
			}
			setmodel(self.bomb2,  "models/misc/playerhorns_head.iqm");
			self.bomb2.angles    = '0 0 -90';
			setattachment(self.bomb2, self, "Head");
			setorigin(self.bomb2, '0 8 -2');    // Move attch spot up 8// back 2// yes fscked up bone  
			self.health = self.health * 1.25;
			self.armorvalue = g_pickup_armormedium;
		}
	}
	
	//if(self.body_phal) print("here222\n");
	//self.sex = SEX_MALE;
	
	if ((autocvar_sv_risque >= 0.75) && (self.sex == SEX_MALE))
	{
		if not(self.body_phal)
		{
			self.body_phal = spawn();
			self.body_phal.scale = 1.5 + random();
			if (random() > 0.75)
				self.body_phal.scale = self.body_phal.scale + random();
		}
		
		self.body_phal.effects = self.effects;
		self.body_phal.colormod = self.colormod;
		self.body_phal.alpha = 1;
			
		if not(self.stoned)
		{
				//if (random() > 0.5)
				//{
					self.body_phal.skin = 16; //Demon
				//} else {
				//	self.body_phal.skin = 2; //FurDark
				//}
			
			self.body_phal.stoneskin = 3; //This doesn't seem to work right, just goes with parent stone skin, will have to investigate
			self.body_phal.cnt = 0;
			setmodel(self.body_phal,  "models/monsters/minotaur_bayonet.iqm");
			
			if (autocvar_sv_risque >= 1) {
				if (self.body_phal_stat == 1) {
					setmodel(self.body_phal,  "models/monsters/minotaur_bayonet_e_base.iqm");
				} else if (self.body_phal_stat == 2) {
					setmodel(self.body_phal,  "models/monsters/minotaur_bayonet_c_base.iqm");
				} else if (self.body_phal_stat == 3) {
					setmodel(self.body_phal,  "models/monsters/minotaur_bayonet_d_base.iqm");
				}
			}
		}
		
		self.body_phal.angles    = '0 0 -90';
		setattachment(self.body_phal, self, "spine1");
		self.body_phal.scale = 1 + (random()*0.5);
		setorigin(self.body_phal, '0 -12 2.5');    // Move attch down 16// forward 2// yes fscked up bone  
	} else {
		if (self.body_phal) { self.body_phal.alpha = 0.0001; setmodel(self.body_phal, "null"); remove_safely(self.body_phal); }
	}		
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void biledemon_precache_weapons()
{
	if (autocvar_g_monsters_jitprecacheonly <= 0) {
	precache_model ("models/weapons/v_broadaxe.md3");
	precache_model ("models/weapons/v_warhammerspiked.md3");
	precache_model ("models/weapons/v_morgenstern.md3");
	//precache_model ("models/weapons/v_crossbowdtwr.md3");
	//precache_model ("models/weapons/v_lightcrossbow.md3");
	precache_model ("models/weapons/v_torch.md3");
	precache_model ("models/weapons/v_torch_lit.md3");
	precache_model ("models/weapons/v_tetsubo.md3");
	}
	
	if (autocvar_g_monsters_jitprecacheonly <= 1) {
	precache_model ("models/misc/playerhorns_head.iqm");	
	}
}


/*QUAKED monster_biledemon (1 0 0) (-18 -18 -25) (18 18 47)
BileDemon, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 biledemon entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/biledemon.dpm"
*/
void spawnfunc_monster_biledemon() 
{
	if not(autocvar_g_monster_biledemon) 
	{
		remove(self);
		return;
	}
	
	precache_model("models/monsters/minotaur_bayonet.iqm");
	precache_model("models/monsters/minotaur_bayonet_ex.iqm");

	biledemon_precache_weapons();
	
	self.monster_spawnfunc = spawnfunc_monster_biledemon;
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.scale = 1.25;
		self.ammount = 1;
		if (random() > 0.45)
			self.scale = self.scale + (random()*0.5);
		else 
			self.scale = self.scale + (random()*1.3);
	}
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "BileDemon",
			 "models/monsters/troll-edits.iqm",
			 BILEDEMON_MIN, BILEDEMON_MAX,
			 FALSE,
			 biledemon_die, biledemon_spawn))
	{
		remove(self);
		return;
	}
}


void spawnfunc_monster_biledemon_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	spawnfunc_monster_biledemon();	
}

