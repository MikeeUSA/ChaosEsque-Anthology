// size
const vector DOG_MAX = '16 16 12';
const vector DOG_MIN = '-16 -16 -24';

// cvars
float autocvar_g_monster_dog;
float autocvar_g_monster_dog_health;
float autocvar_g_monster_dog_bite_damage;
float autocvar_g_monster_dog_attack_jump_damage;
float autocvar_g_monster_dog_speed_walk;
float autocvar_g_monster_dog_speed_run;

// animations
#define dog_anim_idle 		0
#define dog_anim_walk 		1
#define dog_anim_run 		2
#define dog_anim_attack 	3
#define dog_anim_die 		4
#define dog_anim_pain 		5
#define dog_anim_dead 		6
#define dog_anim_stone		7

void Dog_JumpTouch ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = autocvar_g_monster_dog_attack_jump_damage * self.scale;
	if (self.health <= 0)
		return;

	if (other.takedamage)
	{
		if (vlen(self.velocity) > 300)
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_DOG_JUMP, self.enemy.origin, normalize(self.enemy.origin - self.origin));
	}

	if(self.flags & FL_ONGROUND)
		self.touch = MonsterTouch;
}

void dog_think ()
{
	monster_hook_think();
	
	self.think = dog_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = dog_anim_stone;
	
	if (self.skin == 1) {
		//cheeta skinned alittle faster
		monster_move(monster_mvmntimpare_animal(autocvar_g_monster_dog_speed_run * 1.1), monster_mvmntimpare_animal(autocvar_g_monster_dog_speed_walk * 1.1), 50, dog_anim_run, dog_anim_walk, dog_anim_idle);
	} else {
		monster_move(monster_mvmntimpare_animal(autocvar_g_monster_dog_speed_run), monster_mvmntimpare_animal(autocvar_g_monster_dog_speed_walk), 50, dog_anim_run, dog_anim_walk, dog_anim_idle);
	}
	
	//NoFlying
	movelib_jump_simple(-65);
}

void dog_attack ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = autocvar_g_monster_dog_bite_damage * self.scale;
	
	if (self.stoned || self.frozen) self.frame = dog_anim_stone; else self.frame = dog_anim_attack;
	self.attack_finished_single = time + 0.7;

	monster_melee(self.enemy, bigdmg * monster_skill, 100, DEATH_MONSTER_DOG_BITE);
}

float dog_jump ()
{	
	makevectors(self.angles);
	if(monster_leap(dog_anim_attack, Dog_JumpTouch, v_forward * 300 + '0 0 200', 0.8))
		return TRUE;
		
	return FALSE;
}

void dog_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = dog_anim_stone; else self.frame = dog_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void dog_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("dog");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + 0.75;
	//We set think below to load the deadbody "animation", then fade
	self.think 		= dog_death;
	self.pain_finished  = self.nextthink;
	self.movetype 		= MOVETYPE_TOSS;
	self.frame 			= dog_anim_die;
	
	monster_hook_death(); // for post-death mods
}

void dog_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_dog_health * self.scale;

	self.damageforcescale   = 0;
	self.stoneskin = 2;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.monster_smell_bodyodor = self.smell_bodyodor = 0.5 + random();
	self.monster_hasheightenedsenseofsmell = 2;
	
	if (0.7 < random()) {
		//Cheeta skin
		self.skin = 1;
	} else {
		//Regular dark brown skin
		self.skin = 0;
	}
	
	self.species = SPECIES_ANIMAL;
	self.classname			= "monster_dog";
	self.attack_melee	   	= dog_attack;
	self.attack_ranged	  	= dog_jump;
	self.checkattack	 	= GenericCheckAttack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= dog_think;
	self.frame				= dog_anim_idle;
	self.sprite_height	  	= 20 * self.scale;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_dog ()
{	
	if not(autocvar_g_monster_dog)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_dog;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "Cerberus",
			 "models/monsters/dog.dpm",
			 DOG_MIN, DOG_MAX,
			 FALSE,
			 dog_die, dog_spawn))
	{
		remove(self);
		return;
	}
}
