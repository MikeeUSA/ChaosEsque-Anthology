/**
 * Special purpose fields:
 * .delay - time at which to check if royalguard's enemy is still in range
 * .enemy - enemy of this royalguard
 * .state - state of the royalguard, see ROYALGUARD_STATE_*
 */
 
// cvars
float autocvar_g_monster_royalguard;
float autocvar_g_monster_royalguard_stopspeed;
float autocvar_g_monster_royalguard_attack_leap_damage;
float autocvar_g_monster_royalguard_attack_leap_delay;
float autocvar_g_monster_royalguard_attack_leap_force;
float autocvar_g_monster_royalguard_attack_leap_range;
float autocvar_g_monster_royalguard_attack_leap_speed;
float autocvar_g_monster_royalguard_attack_stand_damage;
float autocvar_g_monster_royalguard_attack_stand_delay;
float autocvar_g_monster_royalguard_attack_stand_range;
float autocvar_g_monster_royalguard_health;
float autocvar_g_monster_royalguard_idle_timer;
float autocvar_g_monster_royalguard_speed_walk;
float autocvar_g_monster_royalguard_speed_jog_rate;
float autocvar_g_monster_royalguard_speed_run;
float autocvar_g_monster_royalguard_target_recheck_delay;
float autocvar_g_monster_royalguard_target_range;
float autocvar_g_monster_royalguard_amnt;
float autocvar_g_monster_royalguard_burn_amnt;
float autocvar_g_monster_royalguard_dark_amnt;

// royalguard animations
#define royalguard_anim_attackleap		 0
#define royalguard_anim_attackrun1		 1
#define royalguard_anim_attackrun2		 2
#define royalguard_anim_attackrun3		 3
#define royalguard_anim_attackstanding1	4
#define royalguard_anim_attackstanding2	5
#define royalguard_anim_attackstanding3	6
#define royalguard_anim_blockend		   7
#define royalguard_anim_blockstart		 8
#define royalguard_anim_deathback1		 9
#define royalguard_anim_deathback2		 10
#define royalguard_anim_deathback3		 11
#define royalguard_anim_deathfront1		12
#define royalguard_anim_deathfront2		13
#define royalguard_anim_deathfront3		14
#define royalguard_anim_deathleft1		 15
#define royalguard_anim_deathleft2		 16
#define royalguard_anim_deathright1		17
#define royalguard_anim_deathright2		18
#define royalguard_anim_idle			   19
#define royalguard_anim_painback1		  20
#define royalguard_anim_painback2		  21
#define royalguard_anim_painfront1		 22
#define royalguard_anim_painfront2		 23
#define royalguard_anim_runbackwards	   24
#define royalguard_anim_runbackwardsleft   25
#define royalguard_anim_runbackwardsright  26
#define royalguard_anim_runforward		 27
#define royalguard_anim_runforwardleft	 28
#define royalguard_anim_runforwardright	29
#define royalguard_anim_spawn			  30
#define royalguard_anim_deadback1			  31
#define royalguard_anim_deadfront1			  32
#define royalguard_anim_stone			  33
#define royalguard_anim_attackcrossbow	34


const vector ROYALGUARD_MIN				 = '-11 -11 0';
const vector ROYALGUARD_MAX				 = '11 11 67';

const vector ROYALGUARD_DEAD_MIN				 = '-18 -18 0';
const vector ROYALGUARD_DEAD_MAX				 = '18 18 45';

#define ROYALGUARD_STATE_SPAWNING		0
#define ROYALGUARD_STATE_IDLE			1
#define ROYALGUARD_STATE_ANGRY			2
#define ROYALGUARD_STATE_ATTACK_LEAP	3

void royalguard_spawn();
void spawnfunc_monster_royalguard();
void royalguard_think();

void royalguard_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void royalguard_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void royalguard_die ()
{
	placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("royalguard");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.angles_z = 55 + (35 * random());
	setsize (self, ROYALGUARD_DEAD_MIN, ROYALGUARD_DEAD_MAX);
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
			W_ThrowNewWeapon(self, WEP_SHORTSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHORTSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 4) {
			W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 6) {
			W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 7) {
			W_ThrowNewWeapon(self, WEP_SPEAR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SPEAR, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = royalguard_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_deathback1;
	} else {
		self.think = royalguard_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

void royalguard_check_torch()
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

float royalguard_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_broadaxe_primary_refire;
	} else if (self.weaponentity.count == 2) {
		return autocvar_g_balance_warhammerspiked_primary_refire;
	} else if (self.weaponentity.count == 3) {
		return autocvar_g_balance_shortsword_primary_refire;
	} else if (self.weaponentity.count == 4) {
		return autocvar_g_balance_torch_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_crossbowdtwr_primary_refire;
	} else if (self.weaponentity.count == 6) {
		return autocvar_g_balance_longsword_primary_refire;
	} else if (self.weaponentity.count == 7) {
		return autocvar_g_balance_spear_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_lightcrossbow_primary_refire;
	} else {
		return autocvar_g_monster_royalguard_attack_stand_delay;
	}
}

float royalguard_attack_armed()
{
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_Warhammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_ShortSwordspiked_Attack();
	} else if (self.weaponentity.count == 4) {
		W_Torch_Attack();
	} else if (self.weaponentity.count == 5) {
		if (self.enemy != world) {
			//Skeleton style "aiming", won't be correct for lowgrav
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_crossbowdtwr_primary_speed, 10.15);
			makevectors(self.v_angle);
		}
		W_CrossbowBolt_Attack();
	} else if (self.weaponentity.count == 6) {
		W_LongSwordspiked_Attack();
	} else if (self.weaponentity.count == 7) {
		self.spear_secondary = 1;
		W_Spearspiked_Attack();
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			//Skeleton style "aiming", won't be correct for lowgrav
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_lightcrossbow_primary_speed, 15.15);
			makevectors(self.v_angle);
		}
		W_LightCrossbowBolt_Attack();
	}
	
	return royalguard_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void royalguard_attack_standing()
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
	
	bigdmg = autocvar_g_monster_royalguard_attack_stand_damage * self.scale;

	//print("royalguard attacks!\n");
	makevectors (self.angles);
	
	if (self.weaponentity.count) {
		if (!self.stoned && !self.frozen) {
			vector angles_face = vectoangles(self.enemy.origin - self.origin);
			self.angles_y = angles_face_y;
		}
		
		myrefire = royalguard_attack_armed();
		
		if (self.weaponentity.count != 5)
		if (random() > 0.33)
		{
			if (vlen(self.origin - self.enemy.origin) < autocvar_g_monster_royalguard_attack_stand_range*2) 
			{
				dot = normalize (self.enemy.origin - self.origin) * v_forward;
				if(dot > 0.3)
				{
					Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
				}
			}
		}
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_royalguard_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, TRUE))
		self.enemy = world;
		//The TRUE has to do with recruited monsters
		//We pass TRUE for attackedus as this enemy was found
		//via either find target or when it attacked this guard
		//If it was by find target TRUE was not set and
		//Thus we wouldn't have this enemy in the first place
		//So we don't want to drop the enemy if it was
		//Set because someone attacked this guard
		//If we set FALSE)) here a tolerated player
		//Who attacked the guard would not be an enemy
		//
		//If other similarly coded monsters are added
		//for multitool recruitment, the same thing will have to
		//be done for them
		
	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = royalguard_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = royalguard_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = royalguard_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = royalguard_anim_attackstanding2;
		else
			self.frame = royalguard_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.4);
	else
		self.nextthink = time + myrefire;
}


void royalguard_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_royalguard_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_royalguard_attack_leap_force;
	
	if (self.weaponentity.count) {
		royalguard_attack_armed();
		if (self.weaponentity.count != 5)
		if (random() > 0.33)
		{
				Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);
		}
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy royalguard's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void royalguard_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity.count) {
		myrefire = royalguard_attack_refire();
	} else {
		myrefire = autocvar_g_monster_royalguard_attack_leap_delay;
	}

	// face the enemy	
	self.state = ROYALGUARD_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = royalguard_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_royalguard_attack_leap_speed;
}

/**
 * Main royalguard think function.
 */
void royalguard_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = royalguard_anim_stone;
	
	if (self.weaponentity && self.weaponentity.count == 4)
		royalguard_check_torch();
	
	self.think = royalguard_think;
	
	if (self.state == ROYALGUARD_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = ROYALGUARD_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == ROYALGUARD_STATE_SPAWNING) {
		// become idle when royalguard spawned
		if (self.stoned || self.frozen) self.frame = royalguard_anim_stone; else self.frame = royalguard_anim_idle;
		self.state = ROYALGUARD_STATE_IDLE;
	}
	
	if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, TRUE))
		self.enemy = world;
		//The TRUE has to do with recruited monsters
		//We pass TRUE for attackedus as this enemy was found
		//via either find target or when it attacked this guard
		//If it was by find target TRUE was not set and
		//Thus we wouldn't have this enemy in the first place
		//So we don't want to drop the enemy if it was
		//Set because someone attacked this guard
		//If we set FALSE)) here a tolerated player
		//Who attacked the guard would not be an enemy
		//
		//If other similarly coded monsters are added
		//for multitool recruitment, the same thing will have to
		//be done for them
		
	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
	
	if (self.enemy)
	if (self.enemy.team == self.team || self.monster_owner == self.enemy)
		self.enemy = world;
	
	if(teamplay && autocvar_g_monsters_teams && self.monster_owner.team != self.team)
		self.monster_owner = world;	
	
	// remove enemy that ran away
	if (self.enemy)
	if (self.delay <= time) // check if we can do the rescan now
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_royalguard_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_royalguard_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_royalguard_target_recheck_delay;
	}

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_broadaxe_primary_melee_range * 0.94 * 4;
		else if (self.weaponentity.count == 2)
			mystandattackrange = autocvar_g_balance_warhammerspiked_primary_melee_range * 0.94 * 4;
		else if (self.weaponentity.count == 3)
			mystandattackrange = autocvar_g_balance_shortsword_primary_melee_range * 0.94 * 4;
		else if (self.weaponentity.count == 4)
			mystandattackrange = autocvar_g_balance_torch_primary_melee_range * 0.94 * 4;
		else if (self.weaponentity.count == 6)
			mystandattackrange = autocvar_g_balance_longsword_primary_melee_range * 0.94 * 4;
		else if (self.weaponentity.count == 7)
			mystandattackrange = autocvar_g_balance_spear_primary_melee_range * 0.98 * 4;
		else
			mystandattackrange = autocvar_g_monster_royalguard_attack_stand_range * self.scale;
		
		// make sure royalguard is angry
		self.state = ROYALGUARD_STATE_ANGRY;
		

		// this royalguard has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= mystandattackrange * 40)
		{
			if (random() > 0.90) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20;
				enemyDistance = autocvar_g_monster_royalguard_attack_stand_range;
			}
		}
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (!self.frozen)
		if (!self.stoned)
		if (self.stat_bangflash < 99)
		if (self.stat_nukeflash < 99)
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
		if (mySpeed <= 30)
			if (enemyDistance <= mystandattackrange) 
			{
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				royalguard_attack_standing();
				finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_royalguard_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				royalguard_attack_leap();
				finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.monster_spclcnsd)
	{
		//Special considerations for _grounded
		//Stay on ground no matter what
		//(only really a prob with multitool spawned ones for some reason
		//guess the others always find an enemy.
		//spawned ones won't take the owner player as enemy
		//and will wander into the clouds
		if (self.stoned || self.frozen) {
			//No move
		} else {
			//print("No flying\n");
			if (random() > 0.5) {
				movelib_jump_simple(-512);
			} else {
				movelib_jump_simple(-1024);
			}
		}
	}
	
	if not(finished) 
	{
		monster_move(monster_mvmntimpare_human(autocvar_g_monster_royalguard_speed_run), monster_mvmntimpare_human(autocvar_g_monster_royalguard_speed_walk), autocvar_g_monster_royalguard_stopspeed, royalguard_anim_runforward, royalguard_anim_runforward, royalguard_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("royalguard is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = royalguard_anim_stone; else self.frame = ((mySpeed <= 20) ? royalguard_anim_idle : royalguard_anim_runforward);
		self.nextthink = time + autocvar_g_monster_royalguard_idle_timer * random();	
	}
}

/**
 * Spawn the royalguard.
 */
void royalguard_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_royalguard_health * self.scale;
	
	
	self.monster_jogspeedrate = autocvar_g_monster_royalguard_speed_jog_rate;
	
	self.classname			= "monster_royalguard";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= ROYALGUARD_STATE_SPAWNING;
	self.frame		  		= royalguard_anim_spawn;
	self.think		  		= royalguard_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.sex = SEX_MALE;
	self.monster_demeanor = 4; //Don't ever attack those under same owner, unless attacked
	
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.scale = self.scale + ((random()-0.25)*0.2);
	
	if (self.scale) self.view_ofs = '0 0 55' * self.scale;
	else self.view_ofs = '0 0 55';
	
	//self.skin 				= rint(random() * 3);
	
		//Selecting the type by Ratio
		srandvar = random() *
		(autocvar_g_monster_royalguard_amnt
		+ autocvar_g_monster_royalguard_burn_amnt
		+ autocvar_g_monster_royalguard_dark_amnt);

		if (srandvar < autocvar_g_monster_royalguard_amnt) {
			self.skin = 0;
		} else if (srandvar < (
		autocvar_g_monster_royalguard_amnt
		+ autocvar_g_monster_royalguard_burn_amnt
		)) {
			self.skin = 1;
		} else if (srandvar < (
		autocvar_g_monster_royalguard_amnt
		+ autocvar_g_monster_royalguard_burn_amnt
		+ autocvar_g_monster_royalguard_dark_amnt
		)) {
			self.skin = 2;
		} else {
			self.skin = 0;
		}
	
	self.armorvalue = g_pickup_armorlarge;
	
	self.resist_bullet = 0.33; //Armor is somewhat bulletproof
	self.resist_edged = 0.4;
	self.resist_pierce = 0.25;
	
	if (self.skin == 1) {
		self.resist_bullet = 0.20; //Copper armor less protective
		self.resist_fire = 0.15;   //Moves heat around abit better
		self.resist_edged = 0.5;
		self.resist_pierce = 0.35;
		self.health = self.health + 100;
	}
		
	if (self.skin == 2) {
		self.resist_electricity = 0.5;
		self.resist_energy = 0.5;
		self.resist_bullet = 0.40;
		self.resist_edged = 0.65;
		self.resist_pierce = 0.45;
		self.health = self.health + 200;
	}
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;

	wrand = random();
	if (wrand > 0.05)
	{
		float skipskinrandwep;
		skipskinrandwep = 0;
		
		wrand = random();
		self.weaponentity.alpha = 1;
		self.weaponentity.angles    = '65 -30 0';
		
		if (self.skin == 2)
		{
			if (wrand > 0.80) {
				if (random() > 0.9) {
					setmodel(self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
					self.weaponentity.count = 5;
					self.weaponentity.angles    = '65 0 0';
				} else {
					setmodel(self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
					self.weaponentity.count = 11;
					self.weaponentity.angles    = '65 0 0';
				}
			} else if (wrand > 0.60) {
				setmodel(self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
				self.weaponentity.count = 2;
			} else if (wrand > 0.50) {
				setmodel(self.weaponentity,  "models/weapons/v_spear.md3");
				self.weaponentity.count = 7;
			} else if (wrand > 0.20) {
				setmodel(self.weaponentity,  "models/weapons/v_longsword.md3");
				self.weaponentity.count = 6;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		}
		else if (self.skin == 1)
		{
			if (wrand > 0.75) {
				setmodel(self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
				self.weaponentity.count = 5;
				self.weaponentity.angles    = '65 0 0';
			} else if (wrand > 0.50) {
				setmodel(self.weaponentity,  "models/weapons/v_broadaxe.md3");
				self.weaponentity.count = 1;
			} else if (wrand > 0.40) {
				setmodel(self.weaponentity,  "models/weapons/v_shortsword.md3");
				self.weaponentity.count = 3;
			} else if (wrand > 0.05) {
				royalguard_check_torch();
				self.weaponentity.count = 4;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		}
		else if (self.skin == 0)
		{
			if (wrand > 0.85) {
				setmodel(self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
				self.weaponentity.count = 5;
				self.weaponentity.angles    = '65 0 0';
			} else if (wrand > 0.70) {
				setmodel(self.weaponentity,  "models/weapons/v_shortsword.md3");
				self.weaponentity.count = 3;
			} else if (wrand > 0.60) {
				setmodel(self.weaponentity,  "models/weapons/v_spear.md3");
				self.weaponentity.count = 7;
			} else if (wrand > 0.20) {
				setmodel(self.weaponentity,  "models/weapons/v_longsword.md3");
				self.weaponentity.count = 6;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		}
		
		if (skipskinrandwep == 1) {
			if (wrand > 0.90) {
				setmodel(self.weaponentity,  "models/weapons/v_broadaxe.md3");
				self.weaponentity.count = 1;
			} else if (wrand > 0.75) {
				setmodel(self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
				self.weaponentity.count = 2;
			} else if (wrand > 0.35) {
				setmodel(self.weaponentity,  "models/weapons/v_shortsword.md3");
				self.weaponentity.count = 3;
			} else if (wrand > 0.22) {
				setmodel(self.weaponentity,  "models/weapons/v_longsword.md3");
				self.weaponentity.count = 6;	
			} else if (wrand > 0.20) {
				royalguard_check_torch();
				self.weaponentity.count = 4;
			} else {
				setmodel(self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
				self.weaponentity.count = 5;
				self.weaponentity.angles    = '65 0 0';
			}
		}
		
		
		setattachment(self.weaponentity, self, "hand_ctrl_r");
		
		wrand = random();
		if (wrand > 0.75)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			setmodel(self.bomb1,  self.bomb1.model);
			
			if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
				self.bomb1.angles    = '0 110 0';
			else
				self.bomb1.angles    = '45 110 0';
			
			setattachment(self.bomb1, self, "hand_ctrl_l");
		}
		
		//Head Ornament
		wrand = random();
		if (wrand > 0.95)
		{
			self.bomb2.alpha = 1;
			setmodel(self.bomb2,  "models/misc/playerspikes_head.iqm");
			self.bomb2.angles    = '0 0 -90';
			setattachment(self.bomb2, self, "skull");
			setorigin(self.bomb2, '0 8 -2');    // Move attch spot up 8// back 2// yes fscked up bone  
			self.health = self.health * 1.25;
			self.armorvalue = self.armorvalue + g_pickup_armormedium;
		}
	}
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

/*QUAKED monster_royalguard (1 0 0) (-18 -18 -25) (18 18 47)
RoyalGuard, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 royalguard entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/royalguard.dpm"
*/
void spawnfunc_monster_royalguard() 
{
	if not(autocvar_g_monster_royalguard) 
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_royalguard;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "RoyalGuard",
			 "models/monsters/royalguard.iqm",
			 ROYALGUARD_MIN, ROYALGUARD_MAX,
			 FALSE,
			 royalguard_die, royalguard_spawn))
	{
		remove(self);
		return;
	}
}

void spawnfunc_monster_royalguard_grounded() 
{
	if not(autocvar_g_monster_royalguard) 
	{
		remove(self);
		return;
	}
	
	self.monster_spclcnsd = 1; //Special consideration,
	//for this monster this first bit is set and we will add
	// a vector to go down to stay at ground
	//We don't do this all the time because we want the
	//ones in darkhold etc to be very fluid in movement
	//but ones spawned by multitool to be very grounded
	self.monster_spawnfunc = spawnfunc_monster_royalguard;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "RoyalGuard",
			 "models/monsters/royalguard.iqm",
			 ROYALGUARD_MIN, ROYALGUARD_MAX,
			 FALSE,
			 royalguard_die, royalguard_spawn))
	{
		remove(self);
		return;
	}
}

void royalguard_precacheforothers()
{
	if not(autocvar_g_monsters)
	{
		return;
	}
	if not(autocvar_g_monster_royalguard) 
	{
		return;
	}
	precache_model("models/monsters/royalguard.iqm");
	//This is for precacheing the model from multitool etc
	//Done here so if we change the model we'll remember to
	//Change it here too, rather than forgetting it is even
	//refrenced in w_multitool
}
