// size
const vector GOLEM_MIN = '-70 -70 -1';
const vector GOLEM_MAX = '70 70 240';
 
// cvars
float autocvar_g_monster_golem;
float autocvar_g_monster_golem_health;
float autocvar_g_monster_golem_chainsaw_damage;
float autocvar_g_monster_golem_speed_walk;
float autocvar_g_monster_golem_speed_run;
float autocvar_g_monster_golem_attack_uzi_bullets;
float autocvar_g_monster_golem_amnt;
float autocvar_g_monster_golem_ice_amnt;
float autocvar_g_monster_golem_fire_amnt;

// animations
#define golem_anim_idle 		0
#define golem_anim_walk 		1
#define golem_anim_run 		2
#define golem_anim_pain 		3
#define golem_anim_swing 	4
#define golem_anim_die 		5
#define golem_anim_dead 		6
#define golem_anim_stone 	7
#define golem_anim_throw 	8

void golem_chainsaw (float side)
{
	if (!self.enemy)
		return;

	if (vlen(self.enemy.origin - self.origin) > 100 * self.scale)
		return;

	Damage(self.enemy, self, self, autocvar_g_monster_golem_chainsaw_damage * monster_skill, DEATH_CRUSH, self.enemy.origin, normalize(self.enemy.origin - self.origin));
}

void golem_think ()
{
	monster_hook_think();
	
	self.think = golem_think;
	self.nextthink = time + 0.1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd;
	
	if(self.delay != -1)
		self.nextthink = self.delay;
	
	if (self.stoned || self.frozen)
		self.frame = golem_anim_stone;
	
	monster_move(autocvar_g_monster_golem_speed_run, autocvar_g_monster_golem_speed_walk, 300, golem_anim_run, golem_anim_walk, golem_anim_idle);
	//No flying
	movelib_jump_simple(-120);
}

.float golem_cycles;
void golem_swing ()
{
	self.golem_cycles += 1;
	if (self.stoned || self.frozen) self.frame = golem_anim_stone; else self.frame = golem_anim_swing;
	if(self.golem_cycles == 1)
		self.attack_finished_single = time + 1.3;
	self.angles_y = self.angles_y + random()* 25;
	self.nextthink = time + 0.2;
	self.think = golem_swing;
	
	if(self.golem_cycles <= 2)
		golem_chainsaw(200);
	else if(self.golem_cycles <= 4)
		golem_chainsaw(-200);
	else
		golem_chainsaw(0);
	
	if(self.golem_cycles >= 4)
		self.think = golem_think;
}

void golem_uzi_fire ()
{
	self.golem_cycles += 1;
	
	if(self.golem_cycles > autocvar_g_monster_golem_attack_uzi_bullets)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
		return;
	}
	//W_UZI_Attack(DEATH_MONSTER_OGRE_NAIL);
	
	if (self.skin == 2) W_Fireball_Attack2();
	
	self.delay = time + 0.1;
	self.monster_delayedattack = golem_uzi_fire;
}

void golem_uzi ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
	
	if (self.stoned || self.frozen) self.frame = golem_anim_stone; else self.frame = golem_anim_pain;
	self.attack_finished_single = time + 1.8;
	self.delay = time + 0.1;
	self.monster_delayedattack = golem_uzi_fire;
}

void golem_gl ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
	
	if (self.skin == 1) W_Iceball_Attack1();
	else if (self.skin == 2) W_Fireball_Attack1();
	
	if (self.stoned || self.frozen) self.frame = golem_anim_stone; else self.frame = golem_anim_pain;
	self.attack_finished_single = time + 1.8;
}

float golem_missile ()
{	
	self.golem_cycles = 0;
	if (random() < 0.62)
	{
		if (self.skin > 1) golem_uzi(); //No small ranged for stone or ice golem.
		return TRUE;
	}
	else
	{
		if (self.skin > 0) golem_gl(); //No ranged for stone golem.
		return TRUE;
	}
}

void golem_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	self.golem_cycles = 0;
	golem_swing();
}

void golem_fire_touch (void)
{
	//PROJECTILE_TOUCH;
	if (other.classname == "tree" || other.classname == "bush" || isPlayerOrMonsterByClassname(other)) {
		Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime * 2, autocvar_g_balance_fireball_secondary_damagetime * 2, DEATH_FIRE);
	}
	//W_Fireball_Explode ();
}

void golem_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = golem_anim_stone; else self.frame = golem_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void golem_die()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("golem");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + 0.5;
	self.movetype		= MOVETYPE_TOSS;
	//We set think below to load the deadbody "animation", then fade
	self.think 			= golem_death;
	self.frame			= golem_anim_die;
		
	monster_hook_death(); // for post-death mods
}

void golem_spawn ()
{
	if not(self.health)
		self.health = autocvar_g_monster_golem_health * self.scale;

	self.monster_thinkadd = ((random() - 0.5)*0.125);
	self.damageforcescale   = 0.003;
	self.classname			= "monster_golem";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_melee		= golem_melee;
	self.frame				= golem_anim_idle;
	self.attack_ranged	 	= golem_missile;
	self.nextthink		  	= time + 0.1 + (random()*0.25);
	self.think			  	= golem_think;
	self.sprite_height	  	= 40;
	self.weapon				= WEP_GRENADE_LAUNCHER;
	self.stoneskin = 3;
	
		//Selecting the type by Ratio
		float srandvar;
		srandvar = random() *
		(autocvar_g_monster_golem_amnt
		+ autocvar_g_monster_golem_ice_amnt
		+ autocvar_g_monster_golem_fire_amnt);

		if (srandvar < autocvar_g_monster_golem_amnt) {
			self.skin = 0;
		} else if (srandvar < (
		autocvar_g_monster_golem_amnt
		+ autocvar_g_monster_golem_ice_amnt
		)) {
			self.skin = 1;
		} else if (srandvar < (
		autocvar_g_monster_golem_amnt
		+ autocvar_g_monster_golem_ice_amnt
		+ autocvar_g_monster_golem_fire_amnt
		)) {
			self.skin = 2;
		} else {
			self.skin = 0;
		}
		
	self.species = SPECIES_STONE;
	
	self.resist_acid = 0.8;   //Slime
	self.resist_blunt = 0.8;  //Warhammer, beatdown, melee
	self.resist_bullet = 0.8;
	self.resist_crush = 0.8;  //Vehicle crush
	self.resist_edged = 0.8;  //Axe, Sword, Claw
	self.resist_electricity = 1; //Lightning gun, Tesla arc, 
	self.resist_energy = 0.9; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	self.resist_explode = 0.8;//Rockets etc
	self.resist_fall = 0.8;   //Shooting star, fall etc
	self.resist_fire = 0.8;   //Fire, Lava
	self.resist_laser = 0.8;  //Laser
	self.resist_nuke = 0.8;  //Nuclear explosion
	self.resist_pierce = 0.8; //Crossbow, Bite
	self.resist_sound = 1; //Tuba
	self.resist_ice = 0.8; //Freeze damage resistance
	self.resist_rotor = 1; //Heli rotor blades do no damage to it
	
	if (self.skin == 0)
	{
		//Stone Golem
		self.resist_acid = 0;
		self.resist_crush = 0.95;
		self.resist_nuke = 0.9;
		self.ballistics_density = autocvar_g_ballistics_density_stone;
	}
	
	if (self.skin == 1)
	{	
		//Ice Golem
		self.resist_bullet = 0;
		self.resist_explode = 0; //Fragile ice.
		self.resist_sound = 0; //Resonate
		self.resist_ice = 1;
		self.ballistics_density = autocvar_g_ballistics_density_concrete;
	}
		
	if (self.skin == 2)
	{
		//Fire Golem
		self.resist_electricity = 0.6;
		self.resist_energy = 0.6;
		self.resist_explode = 1;
		self.resist_fire = 1;
		self.touch = golem_fire_touch;
		self.ballistics_density = autocvar_g_ballistics_density_dirt;
	}
		
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_golem ()
{	
	if not(autocvar_g_monster_golem) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_golem;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	//self.scale = 1.3;
	
	if not (monster_initialize(
			 "Golem",
			 "models/monsters/golem.iqm",
			 GOLEM_MIN, GOLEM_MAX,
			 FALSE,
			 golem_die, golem_spawn))
	{
		remove(self);
		return;
	}
	
	weapon_action(WEP_GRENADE_LAUNCHER, WR_PRECACHE);
}
