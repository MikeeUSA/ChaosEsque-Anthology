// size
const vector ENFORCER_MIN = '-16 -16 -24';
const vector ENFORCER_MAX = '16 16 24';

// cvars
float autocvar_g_monster_enforcer;
float autocvar_g_monster_enforcer_health;
float autocvar_g_monster_enforcer_speed_walk;
float autocvar_g_monster_enforcer_speed_run;
float autocvar_g_monster_enforcer_attack_uzi_bullets;

// animations
#define enforcer_anim_stand 	0
#define enforcer_anim_walk 		1
#define enforcer_anim_run 		2
#define enforcer_anim_attack 	3
#define enforcer_anim_death1 	4
#define enforcer_anim_death2 	5
#define enforcer_anim_pain1 	6
#define enforcer_anim_pain2 	7
#define enforcer_anim_pain3 	8
#define enforcer_anim_pain4 	9
#define enforcer_anim_stone 	10

void enforcer_think ()
{
	monster_hook_think();
	
	self.think = enforcer_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if(self.delay != -1)
		self.nextthink = self.delay;
	
	if (self.stoned || self.frozen)
		self.frame = enforcer_anim_stone;
	
	if(time < self.attack_finished_single)
		monster_move(0, 0, 0, enforcer_anim_attack, enforcer_anim_attack, enforcer_anim_attack);
	else
		monster_move(monster_mvmntimpare_human(autocvar_g_monster_enforcer_speed_run), monster_mvmntimpare_human(autocvar_g_monster_enforcer_speed_walk), 100, enforcer_anim_run, enforcer_anim_walk, enforcer_anim_stand);
}

void enforcer_laser ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_attack;
	self.attack_finished_single = time + 0.8;
	W_Laser_Attack(0);
}

float enf_missile_laser ()
{
	enforcer_laser();
	return TRUE;
}

void enforcer_shotgun ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_attack;
	self.attack_finished_single = time + 0.8;
	W_Shotgun_Attack();
}

float enf_missile_shotgun ()
{
	enforcer_shotgun();
	return TRUE;
}

.float enf_cycles;
void enforcer_uzi_fire ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	self.enf_cycles += 1;
	
	if(self.enf_cycles > autocvar_g_monster_enforcer_attack_uzi_bullets)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
		return;
	}
	W_CARBINE_Attack(DEATH_MONSTER_ENFORCER_NAIL);
	self.delay = time + 0.1;
	self.monster_delayedattack = enforcer_uzi_fire;
}

void enforcer_uzi ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_attack;
	self.attack_finished_single = time + 0.8;
	self.delay = time + 0.1;
	self.monster_delayedattack = enforcer_uzi_fire;
}

float enf_missile_uzi ()
{
	self.enf_cycles = 0;
	enforcer_uzi();
	return TRUE;
}

void enforcer_rl ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_attack;
	self.attack_finished_single = time + 0.8;
	W_Rocket_Attack();
}

float enf_missile_rocket ()
{
	enforcer_rl();
	return TRUE;
}

void enforcer_electro ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_attack;
	self.attack_finished_single = time + 0.8;
	W_Electro_Attack();
}

float enf_missile_plasma ()
{
	enforcer_electro();
	return TRUE;
}

void enforcer_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("enforcer");
	
	self.solid		  	= SOLID_NOT;
	self.movetype		= MOVETYPE_TOSS;
	self.think			= Monster_Fade;
	self.takedamage	 	= DAMAGE_NO;
	self.event_damage   = func_null;
	self.enemy		  	= world;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	self.pain_finished  = self.nextthink;
	
	
	//If we're allowed to drop a weapon we shall.
	//Since we have energy weapons, and rocket weapons, we're a future or heavy weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (autocvar_g_monsters_dropweapon_futurehvy) {
		if (autocvar_g_monsters_dropweapon_futurehvy >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_futurehvy > random())
		{
				monsterdropweapon = 1;
		}
	}
	if (monsterdropweapon) {
		if (self.attack_ranged == enf_missile_rocket)
			W_ThrowNewWeapon(self, WEP_ROCKET_LAUNCHER, 0, self.origin, self.velocity);
		else if (self.attack_ranged == enf_missile_plasma)
			W_ThrowNewWeapon(self, WEP_ELECTRO, 0, self.origin, self.velocity);
		else if (self.attack_ranged == enf_missile_shotgun)
			W_ThrowNewWeapon(self, WEP_SHOTGUN, 0, self.origin, self.velocity);	   
		else if (self.attack_ranged == enf_missile_uzi)
			W_ThrowNewWeapon(self, WEP_CARBINE, 0, self.origin, self.velocity);
		else
			W_ThrowNewWeapon(self, WEP_LASER, 0, self.origin, self.velocity);
	}
	
	
	if (random() > 0.5)
		if (self.stoned || (self.frozen == 1)) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_death1;
	else
		if (self.stoned || (self.frozen == 1)) self.frame = enforcer_anim_stone; else self.frame = enforcer_anim_death2;
		
	monster_hook_death(); // for post-death mods
}

void enforcer_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_enforcer_health * self.scale;

	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.damageforcescale   = 0;
	self.classname			= "monster_enforcer";
	self.checkattack	 	= GenericCheckAttack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= enforcer_think;
	self.items				= (IT_SHELLS | IT_ROCKETS | IT_NAILS | IT_CELLS);
	self.sprite_height	  	= 30 * self.scale;
	self.vuln_movement_imparable = 0.4; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	
	local float r = random();
	if (r < 0.20)
		self.attack_ranged = enf_missile_rocket;
	else if (r < 0.40)
		self.attack_ranged = enf_missile_plasma;
	else if (r < 0.60)
		self.attack_ranged = enf_missile_shotgun;	  
	else if (r < 0.80)
		self.attack_ranged = enf_missile_uzi;
	else
		self.attack_ranged = enf_missile_laser;
		
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_enforcer ()
{	
	if not(autocvar_g_monster_enforcer)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_enforcer;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Enforcer",
			 "models/monsters/enforcer.mdl",
			 ENFORCER_MIN, ENFORCER_MAX,
			 FALSE,
			 enforcer_die, enforcer_spawn))
	{
		remove(self);
		return;
	}
}
