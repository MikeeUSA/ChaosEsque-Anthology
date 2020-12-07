// size
const vector WOLF_MAX = '16 16 36';
const vector WOLF_MIN = '-16 -16 0';

const vector WOLF_DEAD_MAX = '16 16 12';
const vector WOLF_DEAD_MIN = '-16 -16 -24';

// cvars
float autocvar_g_monster_wolf;
float autocvar_g_monster_wolf_health;
float autocvar_g_monster_wolf_bite_damage;
float autocvar_g_monster_wolf_attack_jump_damage;
float autocvar_g_monster_wolf_speed_walk;
float autocvar_g_monster_wolf_speed_run;
float autocvar_g_monster_wolf_amnt;
float autocvar_g_monster_wolf_winter_amnt;
float autocvar_g_monster_wolf_dark_amnt;

// animations
#define wolf_anim_idle 		0
#define wolf_anim_walk 		1
#define wolf_anim_run 		2
#define wolf_anim_attack 	3
#define wolf_anim_die 		4
#define wolf_anim_pain 		5
#define wolf_anim_dead 		6
#define wolf_anim_stone		7

void Wolf_JumpTouch ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = autocvar_g_monster_wolf_attack_jump_damage * self.scale;
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

void wolf_think ()
{
	monster_hook_think();
	
	self.think = wolf_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = wolf_anim_stone;
	
	if (self.skin == 1) {
		//winter skinned alittle faster
		monster_move(monster_mvmntimpare_animal(autocvar_g_monster_wolf_speed_run * 1.1), monster_mvmntimpare_animal(autocvar_g_monster_wolf_speed_walk * 1.1), 50, wolf_anim_run, wolf_anim_walk, wolf_anim_idle);
	} else {
		monster_move(monster_mvmntimpare_animal(autocvar_g_monster_wolf_speed_run), monster_mvmntimpare_animal(autocvar_g_monster_wolf_speed_walk), 50, wolf_anim_run, wolf_anim_walk, wolf_anim_idle);
	}
	
	if (!self.stoned && !self.frozen)
	if (self.sex == SEX_MALE)
	if (self.body_phal)
	if (!self.body_phal_stat)
	{
		if ((self.enemy != world)
		&& (random() > 0.7)
		&& (self.enemy.classname == "player" || self.enemy.classname == "body")
		&& (self.body_phal.cnt == 0))
		{
				self.body_phal.cnt = 1;
				setmodel(self.body_phal,  "models/monsters/minotaur_bayonet_ex.iqm");
		} else {
			if(self.body_phal.cnt > 0)
			{
				self.body_phal.cnt = self.body_phal.cnt - 0.1;
				
				if(self.body_phal.cnt <= 0)
				{
					self.body_phal.cnt = 0;
					setmodel(self.body_phal,  "models/monsters/minotaur_bayonet.iqm");
				}	
			}
		}
	}
	
	//No flying
	//tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 100', MOVE_NORMAL, self);
	//setorigin(self, trace_endpos);
	movelib_jump_simple(-50);
}

void wolf_attack ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = autocvar_g_monster_wolf_bite_damage * self.scale;
	
	if (self.stoned || self.frozen) self.frame = wolf_anim_stone; else self.frame = wolf_anim_attack;
	self.attack_finished_single = time + 0.7;

	monster_melee(self.enemy, bigdmg * monster_skill, 100, DEATH_MONSTER_DOG_BITE);
}

float wolf_jump ()
{	
	makevectors(self.angles);
	if(monster_leap(wolf_anim_attack, Wolf_JumpTouch, v_forward * 300 + '0 0 200', 0.8))
		return TRUE;
		
	return FALSE;
}

void wolf_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = wolf_anim_stone; else self.frame = wolf_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void wolf_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("wolf");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + 0.75;
	self.angles_z = 55 + (35 * random());
	setsize (self, WOLF_DEAD_MIN, WOLF_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	//We set think below to load the deadbody "animation", then fade
	self.think 		= wolf_death;
	self.pain_finished  = self.nextthink;
	self.movetype 		= MOVETYPE_TOSS;
	self.frame 			= wolf_anim_die;
	
	monster_hook_death(); // for post-death mods
}

void wolf_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_wolf_health * self.scale;

	self.damageforcescale   = 0;
	self.stoneskin = 3;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.monster_smell_bodyodor = self.smell_bodyodor = 0.25 + random();
	self.monster_hasheightenedsenseofsmell = 2;
	
		local float srandvar;
		//Selecting the type by Ratio
		srandvar = random() *
		(autocvar_g_monster_wolf_amnt
		+ autocvar_g_monster_wolf_winter_amnt
		+ autocvar_g_monster_wolf_dark_amnt);

		if (srandvar < autocvar_g_monster_wolf_amnt) {
			self.skin = 0;
		} else if (srandvar < (
		autocvar_g_monster_wolf_amnt
		+ autocvar_g_monster_wolf_winter_amnt
		)) {
			self.skin = 1;
		} else if (srandvar < (
		autocvar_g_monster_wolf_amnt
		+ autocvar_g_monster_wolf_winter_amnt
		+ autocvar_g_monster_wolf_dark_amnt
		)) {
			self.skin = 2;
		} else {
			self.skin = 0;
		}
	
	self.resist_ice = 0.5;
	
	if (self.skin == 1)
	{
		self.resist_ice = 0.95;
		self.resist_energy = 0.45;
	}
	
	if (self.skin == 2)
	{
		self.resist_bullet = 0.25;
		self.resist_edged = 0.3;
		self.resist_energy = 0.65;
		self.resist_ice = 0.75;
		self.resist_pierce = 0.2;
	}
	
	self.species = SPECIES_ANIMAL;
	self.classname			= "monster_wolf";
	self.attack_melee	   	= wolf_attack;
	self.attack_ranged	  	= wolf_jump;
	self.checkattack	 	= GenericCheckAttack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= wolf_think;
	self.frame				= wolf_anim_idle;
	self.sprite_height	  	= 20 * self.scale;
	
	if not(self.sex) {		
			if (random() > 0.6)
			{
				self.sex = SEX_MALE;
			} else {
				self.sex = SEX_FEMALE;
			}
	}
	
	if ((autocvar_sv_risque >= 0.75) && (self.sex == SEX_MALE))
	{
		if not(self.body_phal)
		{
			self.body_phal = spawn();
			self.body_phal.scale = 1.1 + random();
		}
		
		self.body_phal.effects = self.effects;
		self.body_phal.colormod = self.colormod;
		self.body_phal.alpha = 1;
			
		if not(self.stoned)
		{
			if (self.skin == 1) {
				self.body_phal.skin = 11;
			} else if (self.skin == 2) {
				self.body_phal.skin = 10;
			} else {
				self.body_phal.skin = 9;
			}
			
			self.body_phal.stoneskin = 3;
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
		
		self.body_phal.angles    = '0 0 90';
		setattachment(self.body_phal, self, "bodyBehind");
		setorigin(self.body_phal, '0 17 -5');    // Move attch down 16// forward 2// yes fscked up bone  
	} else {
		if (self.body_phal) { self.body_phal.alpha = 0.0001; setmodel(self.body_phal, "null"); remove_safely(self.body_phal); }
	}
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_wolf ()
{	
	if not(autocvar_g_monster_wolf)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_wolf;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "Wolf",
			 "models/monsters/wolf.iqm",
			 WOLF_MIN, WOLF_MAX,
			 FALSE,
			 wolf_die, wolf_spawn))
	{
		remove(self);
		return;
	}
}
