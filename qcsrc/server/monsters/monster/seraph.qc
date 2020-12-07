/**
 * Special purpose fields:
 * .delay - time at which to check if seraph's enemy is still in range
 * .enemy - enemy of this seraph
 * .state - state of the seraph, see SERAPH_STATE_*
 */
 
// cvars
float autocvar_g_monster_seraph;
float autocvar_g_monster_seraph_stopspeed;
float autocvar_g_monster_seraph_attack_leap_damage;
float autocvar_g_monster_seraph_attack_leap_delay;
float autocvar_g_monster_seraph_attack_leap_force;
float autocvar_g_monster_seraph_attack_leap_range;
float autocvar_g_monster_seraph_attack_leap_speed;
float autocvar_g_monster_seraph_attack_stand_damage;
float autocvar_g_monster_seraph_attack_stand_delay;
float autocvar_g_monster_seraph_attack_stand_range;
float autocvar_g_monster_seraph_health;
float autocvar_g_monster_seraph_idle_timer;
float autocvar_g_monster_seraph_speed_walk;
float autocvar_g_monster_seraph_speed_run;
float autocvar_g_monster_seraph_target_recheck_delay;
float autocvar_g_monster_seraph_target_range;

// seraph animations
#define seraph_anim_attackleap		 8
#define seraph_anim_attackrun1		 13
#define seraph_anim_attackrun2		 15
#define seraph_anim_attackrun3		 16
#define seraph_anim_attackstanding1	2
#define seraph_anim_attackstanding2	11
#define seraph_anim_attackstanding3	12
#define seraph_anim_blockend		   7
#define seraph_anim_blockstart		 8
#define seraph_anim_deathback1		 0
#define seraph_anim_deathback2		 0
#define seraph_anim_deathback3		 0
#define seraph_anim_deathfront1		1
#define seraph_anim_deathfront2		1
#define seraph_anim_deathfront3		1
#define seraph_anim_deathleft1		 0
#define seraph_anim_deathleft2		 0
#define seraph_anim_deathright1		1
#define seraph_anim_deathright2		1
#define seraph_anim_idle			   7
#define seraph_anim_painback1		  9
#define seraph_anim_painback2		  9
#define seraph_anim_painfront1		 10
#define seraph_anim_painfront2		 10
#define seraph_anim_runbackwards	   14
#define seraph_anim_runbackwardsleft   22
#define seraph_anim_runbackwardsright  21
#define seraph_anim_runforward		 13
#define seraph_anim_runforwardleft	 20
#define seraph_anim_runforwardright	19
#define seraph_anim_spawn			  6
#define seraph_anim_deadback1			  17
#define seraph_anim_deadfront1			18
#define seraph_anim_stone			  31
#define seraph_anim_attackcrossbow	11


const vector SERAPH_MIN				 = '-16 -16 -24';
const vector SERAPH_MAX				 = '16 16 45';

const vector SERAPH_DEAD_MIN				 = '-18 -18 -30';
const vector SERAPH_DEAD_MAX				 = '18 18 2';

#define SERAPH_STATE_SPAWNING		0
#define SERAPH_STATE_IDLE			1
#define SERAPH_STATE_ANGRY			2
#define SERAPH_STATE_ATTACK_LEAP	3

void seraph_spawn();
void spawnfunc_monster_seraph();
void seraph_think();

void seraph_attacheddeath()
{
		//Don't shine no more, don't shine
		self.effects = EF_DOUBLESIDED;
		
		//self.bomb2.alpha = -1;
		//self.bomb3.alpha = -1;
		self.bomb4.alpha = -1;
		self.bomb5.alpha = -1;
		self.bomb6.alpha = -1;
		self.bomb7.alpha = -1;
		self.bomb8.alpha = -1;
		
		self.light_lev = 0;
		self.weaponentity.light_lev = 0;
		self.weaponentity.effects = 0;
		self.bomb2.effects = self.bomb3.effects = self.effects = 0;		

}

void seraph_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = seraph_anim_stone; else self.frame = seraph_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	seraph_attacheddeath();
}

void seraph_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = seraph_anim_stone; else self.frame = seraph_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	seraph_attacheddeath();
}

void seraph_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("seraph");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, SERAPH_DEAD_MIN, SERAPH_DEAD_MAX);
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
			W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 3) {
			W_ThrowNewWeapon(self, WEP_SHININGSTAR, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHININGSTAR, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 4) {
			W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 6) {
			W_ThrowNewWeapon(self, WEP_YARI, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_YARI, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin, randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = seraph_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = seraph_anim_stone; else self.frame = seraph_anim_deathback1;
	} else {
		self.think = seraph_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = seraph_anim_stone; else self.frame = seraph_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

void seraph_check_torch()
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

float seraph_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_longsword_primary_refire;
	} else if (self.weaponentity.count == 2) {
		return autocvar_g_balance_warhammerspiked_primary_refire;
	} else if (self.weaponentity.count == 3) {
		return autocvar_g_balance_shiningstar_primary_refire;
	} else if (self.weaponentity.count == 4) {
		return autocvar_g_balance_torch_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_crossbowdtwr_primary_refire;
	} else if (self.weaponentity.count == 6) {
		return autocvar_g_balance_yari_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_lightcrossbow_primary_refire;
	} else {
		return autocvar_g_monster_seraph_attack_stand_delay;
	}
}

float seraph_attack_armed()
{
	vector angles_face;
				
	// face the enemy	
	angles_face = vectoangles(self.enemy.origin - self.origin);
	//self.angles_y = angles_face_y ;
	self.angles = angles_face; //Fully
	
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	
	if (self.weaponentity.count == 1) {
		W_LongSwordspiked_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_Warhammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_Shiningstar_Attack();
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
		W_Yarispiked_Attack();
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			//Skeleton style "aiming", won't be correct for lowgrav
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_lightcrossbow_primary_speed, 15.25);
			makevectors(self.v_angle);
		}
		W_LightCrossbowBolt_Attack();
	}
	
	return seraph_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void seraph_attack_standing()
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
	
	bigdmg = autocvar_g_monster_seraph_attack_stand_damage * self.scale;

	//print("seraph attacks!\n");
	makevectors (self.angles);
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		myrefire = seraph_attack_armed();
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_seraph_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = seraph_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = seraph_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = seraph_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = seraph_anim_attackstanding2;
		else
			self.frame = seraph_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.4);
	else
		self.nextthink = time + myrefire;
}


void seraph_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_seraph_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_seraph_attack_leap_force;
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		seraph_attack_armed();
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy seraph's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void seraph_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = seraph_attack_refire();
	else
		myrefire = autocvar_g_monster_seraph_attack_leap_delay;

	// face the enemy	
	self.state = SERAPH_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = seraph_anim_stone; else self.frame = seraph_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles = angles_face ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = seraph_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_seraph_attack_leap_speed;
}

/**
 * Main seraph think function.
 */
entity seraph_find_demon(entity mymonster)
{
	//Hate Demons, Hate Undead, will smite them
	local entity eburn;
	eburn = findradius(mymonster.origin, autocvar_g_monster_seraph_target_range);
	while(eburn)
	{
		if ((eburn.vuln_isundead || eburn.classname == "monster_imp" || eburn.classname == "monster_biledemon" || eburn.classname == "monster_horndemon")
		 && eburn.health > 0) {
			return eburn;
		}
		
		eburn = eburn.chain;
	}
	return world;
}
 
void seraph_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = seraph_anim_stone;
	
	if (self.weaponentity && self.weaponentity.count == 4)
		seraph_check_torch();
	
	self.think = seraph_think;
	
	if (self.stoned) {
		if (self.movetype != MOVETYPE_TOSS) {
			self.movetype = MOVETYPE_TOSS;
			self.flags		  	= FL_ONGROUND;
			//print ("here\n");
			//self.velocity_x 	= -200 + 400*random();
			//self.velocity_y 	= -200 + 400*random();
			//self.velocity_z 	= 100 + 100*random();
			self.velocity_z 	= 100 + 100*random();
			//self.velocity = self.velocity + '0 0 -1' * autocvar_sv_gravity;
			
			self.effects = EF_DOUBLESIDED;
			self.bomb2.effects = self.bomb3.effects = self.effects;
			
			self.alpha = 1;
			self.bomb2.alpha = 1;
			self.bomb3.alpha = 1;
			self.bomb4.alpha = -1;
			self.bomb5.alpha = -1;
			self.bomb6.alpha = -1;
			self.bomb7.alpha = -1;
			self.bomb8.alpha = -1;
			
			self.bomb2.skin = self.stoneskin;
			self.bomb3.skin = self.stoneskin;
		}
		
		self.light_lev = 0;
		self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
		
		self.weaponentity.light_lev = 0;
		self.weaponentity.effects = 0;
		self.weaponentity.alpha = 1;
		
		monster_move(0, 0, 100, seraph_anim_stone, seraph_anim_stone, seraph_anim_stone); //So can decrement stonation

		return;
	} else {
		if (self.movetype == MOVETYPE_TOSS) {
			self.movetype = MOVETYPE_FLY; // TODO: make it fly up/down
			self.flags |= FL_FLY;
			self.light_lev = 8000;
			
			
			self.effects = EF_FULLBRIGHT | EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH | EF_NOSHADOW | EF_DOUBLESIDED;
			self.bomb2.effects = self.bomb3.effects = self.effects;
			
			self.alpha = 0.75;
			
			self.weaponentity.light_lev = 1000;
			self.weaponentity.effects = EF_FULLBRIGHT | EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH;
			self.weaponentity.alpha = self.alpha;

			self.bomb2.alpha = 0.75;
			self.bomb3.alpha = 0.75;
			self.bomb4.alpha = 0.04;
			self.bomb5.alpha = 0.04;
			self.bomb6.alpha = 0.04;
			self.bomb7.alpha = 0.02;
			self.bomb8.alpha = 0.04;
			
			self.bomb2.skin = 2;
			self.bomb3.skin = 2;
		}
	}
	
	if (self.state == SERAPH_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = SERAPH_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == SERAPH_STATE_SPAWNING) {
		// become idle when seraph spawned
		if (self.stoned || self.frozen) self.frame = seraph_anim_stone; else self.frame = seraph_anim_idle;
		self.state = SERAPH_STATE_IDLE;
	}
	
	if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.enemy)
	if (self.enemy.team == self.team || self.monster_owner == self.enemy)
		self.enemy = world;
	
	if(teamplay && autocvar_g_monsters_teams && self.monster_owner.team != self.team)
		self.monster_owner = world;	
	
	// remove enemy that ran away
	if (self.enemy)
	if (self.delay <= time) // check if we can do the rescan now
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_seraph_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_seraph_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_seraph_target_recheck_delay;
	}
	
	if not(self.enemy) 
	{	
		local entity myfounddemon;
		myfounddemon = seraph_find_demon(self);
		if (myfounddemon != world) {
			self.enemy = myfounddemon; //Hate demons, nomatter what
		}
	}
	
	//if not(self.stoned || self.frozen) {
	//	if (random() > 0.25) {
	//		self.velocity_z = self.velocity_z + (1*random());
	//	} 
	//}

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_longsword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 2)
			mystandattackrange = autocvar_g_balance_warhammerspiked_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 3)
			mystandattackrange = autocvar_g_balance_shiningstar_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 4)
			mystandattackrange = autocvar_g_balance_torch_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 6)
			mystandattackrange = autocvar_g_balance_yari_primary_melee_range * 0.94;
		else
			mystandattackrange = autocvar_g_monster_seraph_attack_stand_range * self.scale;
		
		// make sure seraph is angry
		self.state = SERAPH_STATE_ANGRY;
		
		vector angles_face;
				
		// face the enemy	
		angles_face = vectoangles(self.enemy.origin - self.origin);
		//self.angles_y = angles_face_y ;
		self.angles = angles_face; //Fully

		// this seraph has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= mystandattackrange * 40)
		{
			if (random() > 0.90) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20;
				enemyDistance = autocvar_g_monster_seraph_attack_stand_range;
			}
		}
		
		//Magic Attack
		
		if (self.enemy.vuln_isundead) {
			self.spell_holybolt = 25;
			self.spell_holyword = 0;
			self.spell_lightining = 0;
			self.spell_lightiningstrike = 40; //Much hatred
			self.spell_paralyse = 0;
			if (random() > 0.25) {
				self.spell_holyword = 40;
				if (random() > 0.25) {
					self.spell_holyword = 100;
				}
			}
		} else {
			//Holybolt cures the living
			self.spell_holybolt = 0;
			self.spell_holyword = 0;
			self.spell_lightining = 25;
			self.spell_lightiningstrike = 25;
			self.spell_paralyse = 25;
		}
	
		if (self.havocbot_nextmagicthink < time) {
			local float mypreviousarmorvalue;
			mypreviousarmorvalue = self.armorvalue;
			self.armorvalue = 0; //So we don't fumble
			self.mana = 90000; //Always, we have enough
			self.havocbot_nextmagicthink =  time + 3;
			self.v_angle = self.angles;
			makevectors(self.v_angle);
			havocbot_castmagic();
			
			if (self.nextspell > 0.5) {
				self.nextspell = 0.5;
			}
			self.armorvalue = mypreviousarmorvalue; //Restore
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
				seraph_attack_standing();
				//finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_seraph_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				seraph_attack_leap();
				//finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if not(finished) 
	{
		if (random() > 0.25) {
			self.velocity_z = self.velocity_z + (8*random());
		} else {
			monster_move(autocvar_g_monster_seraph_speed_run, autocvar_g_monster_seraph_speed_walk, autocvar_g_monster_seraph_stopspeed, seraph_anim_runforward, seraph_anim_runforward, seraph_anim_idle);
		}
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("seraph is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = seraph_anim_stone; else self.frame = ((mySpeed <= 20) ? seraph_anim_idle : seraph_anim_runforward);
		self.nextthink = time + autocvar_g_monster_seraph_idle_timer * random();	
	}
}

/**
 * Spawn the seraph.
 */
void seraph_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_seraph_health * self.scale;
	
	self.classname			= "monster_seraph";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.movetype		   	= MOVETYPE_FLY; // TODO: make it fly up/down
	self.flags			   |= FL_FLY;
	self.pain_finished  	= self.nextthink;
	self.state		  		= SERAPH_STATE_SPAWNING;
	self.frame		  		= seraph_anim_spawn;
	self.think		  		= seraph_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	self.gibscale = 0.8;
	self.skin = 2;
	self.alpha = 0.75;
	
	self.sex = SEX_UNKNOWN;
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.armorvalue = g_pickup_armorlarge * 3;
	
	self.effects = EF_FULLBRIGHT | EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH | EF_NOSHADOW | EF_DOUBLESIDED;

	self.pflags = PFLAGS_FULLDYNAMIC;
	self.light_lev = 8000;
	self.color = '0.90 0.90 0.75';
	self.style = 0;
	
	
	self.resist_acid = 0.5;   //Slime
	self.resist_blunt = 0.5;  //Warhammer, beatdown, melee
	self.resist_bullet = 0.97; //Bullets do little damage, almost pass right through
	self.resist_crush = 0.5;  //Vehicle crush
	self.resist_edged = 0.75;  //Axe, Sword, Claw Full Plate Armor is good against this
	self.resist_electricity = 0.95; //Lightning gun, Tesla arc, 
	self.resist_energy = 0.95; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	self.resist_explode = 0.85;//Rockets etc (Some reist to explosions (ethereal)
	self.resist_fall = 0.97;   //Shooting star, fall etc (angel has lots of resistance to this
	self.resist_fire = 0.5;   //Fire, Lava
	self.resist_laser = 0.5;  //Laser
	self.resist_nuke = 0.5;  //Nuclear explosion (angel has some resistance)
	self.resist_pierce = 0.7; //Crossbow, Bite, Full Plate Armor pretty is good against this
	self.resist_sound = 1; //Tuba
	self.resist_ice = 0.5; //Freeze damage resistance
	self.resist_rotor = 1; //Heli rotor blades do no damage to it (angel)
	
	self.buff_cancellation_immune = 0.8; //Hard to nullify an angel's attacks
	
	self.lodmodel1 = "models/monsters/armorknight_lod1.iqm";
	self.lodmodel2 = "models/monsters/armorknight_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	self.bomb3 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	setmodel(self.bomb3,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = self.bomb3.count = 0;

	wrand = random();
	if (wrand > 0.2 || self.monster_spawn_as_archer)
	{
		wrand = random();
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '180 -45 90';
		if (self.monster_spawn_as_archer == 1) 
		{
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
			self.weaponentity.count = 11;
			self.weaponentity.angles    = '0 110 0';
		} else if (self.monster_spawn_as_archer == 2) 
		{
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
			self.weaponentity.count = 5;
			self.weaponentity.angles    = '0 110 0';
		} else if (wrand > 0.60) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_longsword.md3");
			self.weaponentity.count = 1;
		} else if (wrand > 0.40) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
			self.weaponentity.count = 2;
		} else if (wrand > 0.25) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shiningstar.md3");
			self.weaponentity.count = 3;
		} else if (wrand > 0.15) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_yari.md3");
			self.weaponentity.count = 6;	
		//} else if (wrand > 0.10) {
		//	if (autocvar_g_monsters_jitprecacheonly) {
		//		precache_model ("models/weapons/v_torch_lit.md3");
		//		precache_model ("models/weapons/v_torch.md3");
		//	}
		//	seraph_check_torch();
		//	self.weaponentity.count = 4;
		} else {
			if (random() > 0.75) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
				self.weaponentity.count = 5;
				self.weaponentity.angles    = '0 110 0';
			} else {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
				self.weaponentity.count = 11;
				self.weaponentity.angles    = '0 110 0';
			}
		}
		
		
		setattachment(self.weaponentity, self, "bip01 r hand");
		setorigin(self.weaponentity, '2.1 6 -1');    // Move attch spot up 8// forward 4// yes fscked up bone  

		self.weaponentity.pflags = PFLAGS_FULLDYNAMIC;
		self.weaponentity.light_lev = 1000;
		self.weaponentity.color = '0.90 0.90 0.75';
		self.weaponentity.style = 0;
		self.weaponentity.effects = EF_FULLBRIGHT | EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH;
		self.weaponentity.alpha = self.alpha;
		
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
			
	}
	
	//Wings Ornament
	self.bomb2.effects = self.bomb3.effects = self.effects;
	self.bomb2.alpha = self.bomb3.alpha = self.alpha;
	self.bomb2.skin = self.bomb3.skin = 2;
	setmodel(self.bomb2,  "models/monsters/wing1.iqm");
	setmodel(self.bomb3,  "models/monsters/wing2.iqm");
	self.bomb2.angles = '0 90 0';
	self.bomb3.angles = '0 -90 0';
	setattachment(self.bomb2, self, "shoulder_L");
	setattachment(self.bomb3, self, "shoulder_R");
	setorigin(self.bomb2, '0 8 9');    // Move attch spot up 8// back 2// yes fscked up bone  
	setorigin(self.bomb3, '0 8 9');    // Move attch spot up 8// back 2// yes fscked up bone  
	
	//Orb
	self.bomb7 = spawn();
	self.bomb7.effects = EF_FULLBRIGHT | EF_NOSHADOW;
	setattachment(self.bomb7, self, "");
	setmodel(self.bomb7,  "models/sphere/sphere.md3");
	self.bomb7.alpha = 0.02;
	self.bomb7.scale = 1.25;
	
	//Orb
	self.bomb4 = spawn();
	self.bomb4.effects = EF_FULLBRIGHT | EF_NOSHADOW;
	setattachment(self.bomb4, self, "");
	setmodel(self.bomb4,  "models/sphere/sphere.md3");
	self.bomb4.alpha = 0.04;
	self.bomb4.scale = 1;
	
	//Orb
	self.bomb5 = spawn();
	self.bomb5.effects = EF_FULLBRIGHT | EF_NOSHADOW;
	setattachment(self.bomb5, self, "");
	setmodel(self.bomb5,  "models/sphere/sphere.md3");
	self.bomb5.alpha = 0.04;
	self.bomb5.scale = 0.75;
	
	//Orb
	self.bomb6 = spawn();
	self.bomb6.effects = EF_FULLBRIGHT | EF_NOSHADOW;
	setattachment(self.bomb6, self, "");
	setmodel(self.bomb6,  "models/sphere/sphere.md3");
	self.bomb6.alpha = 0.04;
	self.bomb6.scale = 0.5;
	
	//Orb
	self.bomb8 = spawn();
	self.bomb8.effects = EF_FULLBRIGHT | EF_NOSHADOW;
	setattachment(self.bomb8, self, "");
	setmodel(self.bomb8,  "models/sphere/sphere.md3");
	self.bomb8.alpha = 0.04;
	self.bomb8.scale = 0.25;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void seraph_precache_weapons()
{
	if (autocvar_g_monsters_jitprecacheonly <= 0) {
	precache_model ("models/weapons/v_longsword.md3");
	precache_model ("models/weapons/v_warhammerspiked.md3");
	precache_model ("models/weapons/v_shiningstar.md3");
	precache_model ("models/weapons/v_crossbowdtwr.md3");
	precache_model ("models/weapons/v_lightcrossbow.md3");
	precache_model ("models/weapons/v_torch.md3");
	precache_model ("models/weapons/v_torch_lit.md3");
	precache_model ("models/weapons/v_yari.md3");
	}
	
	precache_model ("models/monsters/wing1.iqm");
	precache_model ("models/monsters/wing2.iqm");
	precache_model ("models/sphere/sphere.md3");
}


/*QUAKED monster_seraph (1 0 0) (-18 -18 -25) (18 18 47)
Seraph, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 seraph entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/seraph.dpm"
*/
void spawnfunc_monster_seraph() 
{
	if not(autocvar_g_monster_seraph) 
	{
		remove(self);
		return;
	}
	
	seraph_precache_weapons();
	
	self.monster_spawnfunc = spawnfunc_monster_seraph;
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.scale = 1.05;
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
			 "Seraph",
			 "models/monsters/armorknight.iqm",
			 SERAPH_MIN, SERAPH_MAX,
			 FALSE,
			 seraph_die, seraph_spawn))
	{
		remove(self);
		return;
	}
}


void spawnfunc_monster_seraph_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	spawnfunc_monster_seraph();	
}

