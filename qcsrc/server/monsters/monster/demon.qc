// cvars
float autocvar_g_monster_demon;
float autocvar_g_monster_demon_health;
float autocvar_g_monster_demon_attack_jump_damage;
float autocvar_g_monster_demon_damage;
float autocvar_g_monster_demon_speed_walk;
float autocvar_g_monster_demon_speed_run;

// size
//const vector DEMON_MIN = '-32 -32 -24'; //Old Demonboy
//const vector DEMON_MAX = '32 32 24'; //Old Demonboy
const vector DEMON_MIN = '-18 -18 0';
const vector DEMON_MAX = '18 18 120';
const vector DEMON_DEAD_MIN = '-32 -32 40'; //new
const vector DEMON_DEAD_MAX = '32 32 65';   //new


// animation Old DemonBoy
//#define demon_anim_stand  0
//#define demon_anim_walk   1
//#define demon_anim_run	2
//#define demon_anim_leap   3
//#define demon_anim_pain   4
//#define demon_anim_death  5
//#define demon_anim_attack 6
//#define demon_anim_stone 7
// animation
#define demon_anim_stand  11
#define demon_anim_walk   13
#define demon_anim_run	12
#define demon_anim_leap   2
#define demon_anim_pain   7
#define demon_anim_death  3
#define demon_anim_attack 0
#define demon_anim_stone 15

void demon_think ()
{
	monster_hook_think();
	
	self.think = demon_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = demon_anim_stone;
	
	monster_move(monster_mvmntimpare_demon(autocvar_g_monster_demon_speed_run), monster_mvmntimpare_demon(autocvar_g_monster_demon_speed_walk), 100, demon_anim_run, demon_anim_walk, demon_anim_stand);
}

void demon_attack_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = autocvar_g_monster_demon_damage * self.scale;
	
	if (self.stoned || self.frozen) self.frame = demon_anim_stone; else self.frame = demon_anim_attack;
	self.attack_finished_single = time + 1;
	
	monster_melee(self.enemy, bigdmg * monster_skill, 120, DEATH_MONSTER_DEMON_MELEE);
}

void Demon_JumpTouch ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.health <= 0)
		return;
		
	float bigdmg = autocvar_g_monster_demon_attack_jump_damage * self.scale;

	if (monster_isvalidtarget(other, self, FALSE, FALSE))
	{
		if (vlen(self.velocity) > 300)
		{
			Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_DEMON_JUMP, other.origin, normalize(other.origin - self.origin));
			self.touch = MonsterTouch; // instantly turn it off to stop damage spam
		}
	}

	if(self.flags & FL_ONGROUND)
		self.touch = MonsterTouch;
}

float demon_jump ()
{
	if (self.frozen)
		return FALSE;
		
	if (self.stoned)
		return FALSE;
		
	makevectors(self.angles);
	if(monster_leap(demon_anim_leap, Demon_JumpTouch, v_forward * 700 + '0 0 300', 0.8))
		return TRUE;
		
	return FALSE;
}

void demon_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("demon");
	
	self.frame			= demon_anim_death;
	self.think		  	= Monster_Fade; 
	self.solid		  	= SOLID_NOT;
	self.takedamage	 	= DAMAGE_NO;
	self.event_damage   = func_null;
	self.movetype 		= MOVETYPE_TOSS;
	setsize (self, DEMON_DEAD_MIN, DEMON_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
	self.enemy		  	= world;
	self.nextthink	  	= time + 3;
	self.pain_finished  = self.nextthink;
	
	monster_hook_death(); // for post-death mods
}

void demon_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_demon_health * self.scale;

	self.stoneskin = 2;
	//self.skin = 1;//Test oil
	
	self.gibscale = 1.25;
	self.vuln_movement_imparable = 0.25; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.monster_hasheightenedsenseofsmell = 1;
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	if (random() > 0.9) {
		self.monster_smell_rottingflesh = self.smell_rottingflesh = 0.03 + (random()*0.23);
	} else {
		self.monster_smell_rottingflesh = self.smell_rottingflesh = 0.01 + (random()*0.1);
	}
	
	self.damageforcescale   = 0;
	self.species = SPECIES_ANIMAL;
	self.classname			= "monster_demon";
	self.checkattack 		= GenericCheckAttack;
	self.attack_melee		= demon_attack_melee;
	self.attack_ranged		= demon_jump;
	self.nextthink		 	= time + random() * 0.5 + 0.1;
	self.frame			  	= demon_anim_stand;
	self.think			  	= demon_think;
	self.sprite_height	  	= 30 * self.scale;
	
	self.lodmodel1 = "models/monsters/new_thin_zombie_lod1.iqm";
	self.lodmodel2 = "models/monsters/new_thin_zombie_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

/* QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush */
void spawnfunc_monster_demon ()
{	
	if not(autocvar_g_monster_demon)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_demon;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	//self.scale = 1.3; //Old Demonboy
	if (!self.scale || self.scale == 1) {
		self.scale = 0.7 + (0.4 * random());
		//For variety. In the monstertomouse
		//and monstertomonolith spell code
		//in cheats.qc, we take this into account
		//when dealing with classname = "monster_demon";
		//Usually normal monsters aren't scaled
		//Only spiders and golems are often (down and up)
		//Which we might not want to affect too much with said spell code
		//The Fiend/Demon is an exception
	}
	
	self.monster_painsoundset = 2; //Zombie
	
	if not (monster_initialize(
			 "Fiend",
			 "models/monsters/new_thin_zombie.iqm",
			 DEMON_MIN, DEMON_MAX,
			 FALSE,
			 demon_die, demon_spawn))
	{
		remove(self);
		return;
	}
}

// Compatibility with old spawns
void spawnfunc_monster_demon1 () { spawnfunc_monster_demon(); }
