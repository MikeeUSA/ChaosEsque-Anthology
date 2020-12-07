/**
 * Special purpose fields:
 * .delay - time at which to check if zombie's enemy is still in range
 * .enemy - enemy of this zombie
 * .state - state of the zombie, see ZOMBIE_STATE_*
 */
 
// cvars
float autocvar_g_monster_zombie;
float autocvar_g_monster_zombie_nexuiz;
float autocvar_g_monster_zombie_quakelike;
float autocvar_g_monster_zombie_stopspeed;
float autocvar_g_monster_zombie_attack_leap_damage;
float autocvar_g_monster_zombie_attack_leap_delay;
float autocvar_g_monster_zombie_attack_leap_force;
float autocvar_g_monster_zombie_attack_leap_range;
float autocvar_g_monster_zombie_attack_leap_speed;
float autocvar_g_monster_zombie_attack_stand_damage;
float autocvar_g_monster_zombie_attack_stand_delay;
float autocvar_g_monster_zombie_attack_stand_range;
float autocvar_g_monster_zombie_health;
float autocvar_g_monster_zombie_idle_timer;
float autocvar_g_monster_zombie_speed_walk;
float autocvar_g_monster_zombie_speed_run;
float autocvar_g_monster_zombie_target_recheck_delay;
float autocvar_g_monster_zombie_target_range;
float autocvar_g_monster_zombie_nocolormod;
float autocvar_g_monster_zombie_noeffects;


// zombie animations
#define zombie_anim_attackleap		 0
#define zombie_anim_attackrun1		 1
#define zombie_anim_attackrun2		 2
#define zombie_anim_attackrun3		 3
#define zombie_anim_attackstanding1	4
#define zombie_anim_attackstanding2	5
#define zombie_anim_attackstanding3	6
#define zombie_anim_blockend		   7
#define zombie_anim_blockstart		 8
#define zombie_anim_deathback1		 9
#define zombie_anim_deathback2		 10
#define zombie_anim_deathback3		 11
#define zombie_anim_deathfront1		12
#define zombie_anim_deathfront2		13
#define zombie_anim_deathfront3		14
#define zombie_anim_deathleft1		 15
#define zombie_anim_deathleft2		 16
#define zombie_anim_deathright1		17
#define zombie_anim_deathright2		18
#define zombie_anim_idle			   19
#define zombie_anim_painback1		  20
#define zombie_anim_painback2		  21
#define zombie_anim_painfront1		 22
#define zombie_anim_painfront2		 23
#define zombie_anim_runbackwards	   24
#define zombie_anim_runbackwardsleft   25
#define zombie_anim_runbackwardsright  26
#define zombie_anim_runforward		 27
#define zombie_anim_runforwardleft	 28
#define zombie_anim_runforwardright	29
#define zombie_anim_spawn			  30
#define zombie_anim_deadback1			  31
#define zombie_anim_deadfront1			  32
#define zombie_anim_stone			  33


const vector ZOMBIE_MIN				 = '-18 -18 -25';
const vector ZOMBIE_MAX				 = '18 18 47';

//For ammount = 1 zombies (non nexuiz zombies)
const vector ZOMBIE_DEAD_MIN			 = '-18 -18 20';
const vector ZOMBIE_DEAD_MAX		 	 = '18 18 47';

#define ZOMBIE_STATE_SPAWNING		0
#define ZOMBIE_STATE_IDLE			1
#define ZOMBIE_STATE_ANGRY			2
#define ZOMBIE_STATE_ATTACK_LEAP	3

void zombie_spawn();
void spawnfunc_monster_zombie();
void zombie_think();

void zombie_undie() 
{
	if (self.health <= 0) {
		self.health = (autocvar_g_monster_zombie_health * 0.5) + (autocvar_g_monster_zombie_health * 0.5 * random());
	}
	
	local vector mysizemaxs;
	local vector mysizemins;
	if (self.scale) {
		mysizemaxs = ZOMBIE_MAX;
		mysizemaxs_x = mysizemaxs_x * self.scale; 
		mysizemaxs_y = mysizemaxs_y * self.scale; 
		mysizemaxs_z = mysizemaxs_z * self.scale; 
		mysizemins = ZOMBIE_MIN;
		mysizemins_x = mysizemins_x * self.scale; 
		mysizemins_y = mysizemins_y * self.scale; 
		mysizemins_z = mysizemins_z * self.scale; 
		setsize (self, mysizemins, mysizemaxs);
	} else {
		setsize (self, ZOMBIE_MIN, ZOMBIE_MAX);
	}
	self.event_damage   = monsters_damage;
	self.solid				= SOLID_BBOX;
	self.movetype			= MOVETYPE_WALK;
	self.classname			= "monster_zombie";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= ZOMBIE_STATE_SPAWNING;
	self.frame		  		= zombie_anim_spawn;
	self.think		  		= zombie_think;
	self.sprite_height  	= 50 * self.scale;
	self.takedamage	 	= DAMAGE_AIM;
	//self.skin 				= rint(random() * 4);
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.monster_isquakezombie_shoulddie = 0;
	
	self.deadflag = DEAD_NO;
	
	self.monster_isquakezombie_shoulddie = 0;
	
	monster_hook_spawn(); // for post-spawn mods
}

void zombie_death()
{
	if (self.monster_isquakezombie && !self.stoned) {
		if (self.monster_isquakezombie_shoulddie) {
			//print("DIE\n");
			self.monster_isquakezombie_shoulddie = 0;
			self.think			= Monster_Fade;
			self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
		} else {
			//We come back!
			self.think		= zombie_undie;
			
			//print("Back\n");
			
			if (autocvar_g_monsters_respawn_delay > 0.5)
				self.nextthink = time + 0.5;
			else
				self.nextthink = time + (autocvar_g_monsters_respawn_delay*0.5);
		}
	} else {
		self.think			= Monster_Fade;
		self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	}
}

void zombie_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = zombie_anim_stone; else self.frame = zombie_anim_deadback1;
	zombie_death();
}

void zombie_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = zombie_anim_stone; else self.frame = zombie_anim_deadfront1;
	zombie_death();
}

void zombie_die ()
{
	local float myzombiedied;
	myzombiedied = 1;
	
	if (self.monster_isquakezombie)
	{
		if (self.monster_isquakezombie_shoulddie)
		{
			//We're dead
		} else {
			//Not dead, just stunned, set this to 0.
			myzombiedied = 0;
		}
	}
	
	if (myzombiedied) {
		if (!self.monster_noitemdrop) Monster_CheckDropCvars ("zombie");

		self.solid		  	= SOLID_NOT;
		//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
		//So no changing takedamage and we set event_damage to something other than func_null
		self.event_damage   = monsters_gibdamage;
		self.enemy		  	= world;
		self.movetype		= MOVETYPE_TOSS;
		//We set think below to load the deadbody "animation", then fade
		self.nextthink	  	= time + 0.5;
		self.pain_finished  = self.nextthink;
	} else {
		//Didn't Die, just stunned
		self.solid		  	= SOLID_NOT;
		//self.event_damage   = monsters_gibdamage;
		//self.enemy		  	= world;
		self.movetype		= MOVETYPE_TOSS;
		//We set think below to load the deadbody "animation", then fade
		self.nextthink	  	= time;
		self.pain_finished  = self.nextthink;
	}
	
	if (self.ammount == 1) {
		//Not old nexuiz zombie
		setsize (self, ZOMBIE_DEAD_MIN, ZOMBIE_DEAD_MAX);
		tracebox(self.origin + '0 0 1', self.mins, self.maxs, self.origin - '0 0 128', MOVE_WORLDONLY, self);
		self.velocity_z 	= 100 + 100*random();
	}
	
	if (random() > 0.5) {
		self.think = zombie_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = zombie_anim_stone; else self.frame = zombie_anim_deathback1;
	} else {
		self.think = zombie_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = zombie_anim_stone; else self.frame = zombie_anim_deathfront1;
	}
	
	monster_hook_death(); // for post-death mods
}

/**
 * Perform a standing attack on self.enemy.
 */
void zombie_attack_standing()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;

	float rand = random(), dot = 0, bigdmg = 0;

	self.velocity_x = 0;
	self.velocity_y = 0;
	
	if(self.monster_owner == self.enemy)
	{
		self.enemy = world;
		return;
	}
	
	bigdmg = autocvar_g_monster_zombie_attack_stand_damage * self.scale;
	
	if (self.monster_forcetype == 2000) {
		bigdmg = bigdmg * 2;
	}
	
	//print("zombie attacks!\n");
	makevectors (self.angles);
	dot = normalize (self.enemy.origin - self.origin) * v_forward;
	if(dot > 0.3)
	{
		Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
		
	if (rand < 0.33)
		if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = zombie_anim_attackstanding1;
	else if (rand < 0.66)
		if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = zombie_anim_attackstanding2;
	else
		if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = zombie_anim_attackstanding3;

	self.nextthink = time + autocvar_g_monster_zombie_attack_stand_delay;
}


void zombie_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_zombie_attack_leap_damage * self.scale;
	
	if (self.monster_forcetype == 2000) {
		bigdmg = bigdmg * 2;
	}
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_zombie_attack_leap_force;
	Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	

	// make this guy zombie's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void zombie_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';

	// face the enemy	
	self.state = ZOMBIE_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = zombie_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	self.nextthink = time + autocvar_g_monster_zombie_attack_leap_delay;
	self.touch = zombie_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_zombie_attack_leap_speed;
}

/**
 * Main zombie think function.
 */
void zombie_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	self.think = zombie_think;
	
	if (self.stoned || self.frozen)
		self.frame = zombie_anim_stone;
	
	if (self.state == ZOMBIE_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = ZOMBIE_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == ZOMBIE_STATE_SPAWNING) {
		// become idle when zombie spawned
		if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = zombie_anim_idle;
		self.state = ZOMBIE_STATE_IDLE;
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
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_zombie_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_zombie_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_zombie_target_recheck_delay;
	}

	if (self.enemy) 
	{
		// make sure zombie is angry
		self.state = ZOMBIE_STATE_ANGRY;
		

		// this zombie has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
		if (mySpeed <= 30)
			if (enemyDistance <= autocvar_g_monster_zombie_attack_stand_range * self.scale) 
			{
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				zombie_attack_standing();
				finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_zombie_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				zombie_attack_leap();
				finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if not(finished) 
	{
		monster_move(autocvar_g_monster_zombie_speed_run, autocvar_g_monster_zombie_speed_walk, autocvar_g_monster_zombie_stopspeed, zombie_anim_runforward, zombie_anim_runforward, zombie_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("zombie is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = zombie_anim_stone; else self.frame = ((mySpeed <= 20) ? zombie_anim_idle : zombie_anim_runforward);
		self.nextthink = time + autocvar_g_monster_zombie_idle_timer * random();	
	}
}

/**
 * Spawn the zombie.
 */
void zombie_spawn() 
{
	if (self.health <= 0) {
		self.health = autocvar_g_monster_zombie_health * self.scale;
		
		if (self.monster_forcetype == 2000) {
			self.health = self.health * 1.5;
		}
	}
	
	self.classname			= "monster_zombie";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= ZOMBIE_STATE_SPAWNING;
	self.frame		  		= zombie_anim_spawn;
	self.think		  		= zombie_think;
	self.sprite_height  	= 50 * self.scale;
	//self.skin 				= rint(random() * 4);
	
	
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	if (random() > 0.9) {
		self.monster_smell_rottingflesh = self.smell_rottingflesh = 1 + (random()*1.5);
	} else {
		self.monster_smell_rottingflesh = self.smell_rottingflesh = 1 + random();
	}
	
	self.monster_isquakezombie_shoulddie = 0;
	
	self.vuln_isundead = 1; //Vuln to holy bolt for 100% damage
	
	float zsrand;
	zsrand = random();
	if (zsrand < 0.33)
		self.skin = 0;
	else if (zsrand < 0.66)
		self.skin = 1;
	else
		self.skin = 2;
		
		
	if (autocvar_g_monster_zombie_nocolormod) {
		self.colormod = '0 0 0';
	}	
	
	if (autocvar_g_monster_zombie_noeffects) {
		self.effects &~= (EF_FULLBRIGHT | EF_RED | EF_BLUE); //Disable these if enabled
	}
	
	if (self.monster_forcetype == 2000) {
		//rottingcorpse
		self.colormap = 1024; //1023;
		self.skin = 7;
		self.colormod = '0 0 0';
		self.effects &~= (EF_FULLBRIGHT | EF_RED | EF_BLUE); //Disable these if enabled
	} else if (self.monster_forcetype == 1000) {
		//blackdeath
		self.colormap = (1024 + 12 + 12 * 16);
		self.skin = 6;
		self.colormod = '0 0 0';
		self.effects &~= (EF_FULLBRIGHT | EF_RED | EF_BLUE); //Disable these if enabled
		//So there is no confusion, colorwise
	}
	
	self.stoneskin = 3;
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

/*QUAKED monster_zombie (1 0 0) (-18 -18 -25) (18 18 47)
Zombie, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 zombie entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/zombie.dpm"
*/
void spawnfunc_monster_zombie() 
{
	if not(autocvar_g_monster_zombie) 
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_zombie;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.ammount = 1; //Using this to specify zombie type, Not nexuiz zombie

		if (autocvar_g_monster_zombie_nexuiz) {
			if (autocvar_g_monster_zombie_nexuiz >= 1) {
				self.ammount = -1; //Nexuiz Zombie
			} else if (autocvar_g_monster_zombie_nexuiz > random())
			{
				self.ammount = -1; //Nexuiz Zombie
			}
		}
	}
	
	self.monster_isquakezombie = 0;
	if (autocvar_g_monster_zombie_quakelike) {
		if (autocvar_g_monster_zombie_quakelike >= 1) {
			self.monster_isquakezombie = 1; //Quake Zombie
		} else if (autocvar_g_monster_zombie_nexuiz > random())
		{
			self.monster_isquakezombie = 1; //Quake Zombie
		}
	}
	
	self.monster_painsoundset = 2; //Zombie
	
	if (self.ammount == 1) {
		if not (monster_initialize(
			 "Zombie",
			 "models/monsters/zombie-edits3.iqm",
			 ZOMBIE_MIN, ZOMBIE_MAX,
			 FALSE,
			 zombie_die, zombie_spawn))
		{
			remove(self);
			return;
		}
	} else {
		if not (monster_initialize(
			 "Zombie",
			 "models/monsters/zombie.dpm",
			 ZOMBIE_MIN, ZOMBIE_MAX,
			 FALSE,
			 zombie_die, zombie_spawn))
		{
			remove(self);
			return;
		}
	}
}


void spawnfunc_monster_blackdeath() 
{
	if (!self.damage_health_stable_reduce
	|| self.damage_health_stable_reduce < 1) {
		self.damage_health_stable_reduce = 1;
	}
	self.monster_forcetype = 1000;
	spawnfunc_monster_zombie();	
}

void spawnfunc_monster_rottingcorpse() 
{
	self.monster_forcetype = 2000;
	spawnfunc_monster_zombie();	
}

