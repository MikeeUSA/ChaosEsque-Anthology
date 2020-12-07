// size
const vector TARBABY_MIN = '-16 -16 -24';
const vector TARBABY_MAX = '16 16 32';

// cvars
float autocvar_g_monster_tarbaby;
float autocvar_g_monster_tarbaby_health;
float autocvar_g_monster_tarbaby_speed_walk;
float autocvar_g_monster_tarbaby_speed_run;

// animations
#define tarbaby_anim_walk		0
#define tarbaby_anim_run		1
#define tarbaby_anim_jump		2
#define tarbaby_anim_fly		3
#define tarbaby_anim_explode	4
#define tarbaby_anim_stone	5

void tarbaby_think ()
{
	monster_hook_think();
	
	self.think = tarbaby_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = tarbaby_anim_stone;

	monster_move(autocvar_g_monster_tarbaby_speed_run, autocvar_g_monster_tarbaby_speed_walk, 20, tarbaby_anim_run, tarbaby_anim_walk, tarbaby_anim_walk);
}

void Tar_JumpTouch ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	// dunno why this would be called when dead, but to be safe
	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	if (vlen(self.velocity) > 200)
	{
		// make the monster die
		self.event_damage(self, self, self.health + self.max_health, DEATH_TOUCHEXPLODE, self.origin, '0 0 0');
			
		return;
	}

	if (trace_dphitcontents)
	{
		if not(self.flags & FL_ONGROUND)
		{
			self.touch = MonsterTouch;
			self.flags |= FL_ONGROUND;
			self.movetype = MOVETYPE_WALK;
		}
	}
}

void tarbaby_jump ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if not(self.flags & FL_ONGROUND)
		return;
	if (self.stoned || self.frozen) self.frame = tarbaby_anim_stone; else self.frame = tarbaby_anim_jump;
	// dunno why this would be called when dead, but to be safe
	if (self.health <= 0)
		return;
	self.movetype = MOVETYPE_BOUNCE;
	self.touch = Tar_JumpTouch;
	makevectors (self.angles);
	self.origin_z += 1;
	self.velocity = v_forward * 600 + '0 0 200';
	self.velocity_z += random()*150;
	if (self.flags & FL_ONGROUND)
		self.flags -= FL_ONGROUND;
		
	self.attack_finished_single = time + 0.5;
}

float tbaby_jump ()
{
	tarbaby_jump();
	return TRUE;
}

void tarbaby_blowup ()
{
	float bigboom = 250 * (self.scale * 0.7);
	RadiusDamage(self, self, 250 * monster_skill, 15, bigboom * (monster_skill * 0.7), world, 250, DEATH_MONSTER_TARBABY_BLOWUP, world);
	pointparticles(particleeffectnum(((self.scale > 3) ? "explosion_big" : "explosion_medium")), self.origin, '0 0 0', 1);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("tarbaby"); // drop items after exploding to prevent player picking up item before dying
	
	setmodel(self, "");
}

void tarbaby_die ()
{
	self.solid		  	= SOLID_NOT;
	self.takedamage	 	= DAMAGE_NO;
	self.event_damage   = func_null;
	self.movetype		= MOVETYPE_NONE;
	self.enemy		  	= world;
	self.think			= Monster_Fade;
	self.nextthink		= time + 0.1;
	
	tarbaby_blowup();
	
	monster_hook_death(); // for post-death mods
}

void tarbaby_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_tarbaby_health * self.scale;
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.stoneskin = 1;
	
	self.species = SPECIES_TAR;
	self.damageforcescale   = 0.003;
	self.classname			= "monster_tarbaby";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_ranged	  	= tbaby_jump;
	self.attack_melee	   	= tarbaby_jump;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= tarbaby_think;
	self.sprite_height	  	= 40 * self.scale;
	self.frame				= tarbaby_anim_walk;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void tarpumpkin_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_tarbaby_health * self.scale;
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.species = SPECIES_TAR;
	self.damageforcescale   = 0.003;
	self.classname			= "monster_tarbaby";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_ranged	  	= tbaby_jump;
	self.attack_melee	   	= tarbaby_jump;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= tarbaby_think;
	self.sprite_height	  	= 40 * self.scale;
	self.frame				= tarbaby_anim_walk;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_tarbaby ()
{	
	if not(autocvar_g_monster_tarbaby)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_tarbaby;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Spawn",
			 "models/monsters/slime.dpm",
			 TARBABY_MIN, TARBABY_MAX,
			 FALSE,
			 tarbaby_die, tarbaby_spawn))
	{
		remove(self);
		return;
	}
	
	precache_sound ("weapons/rocket_impact.wav");
}

void spawnfunc_monster_pumpkin ()
{	
	if not(autocvar_g_monster_tarbaby)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_tarbaby;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Spawn",
			 "models/monsters/tarbaby.mdl",
			 TARBABY_MIN, TARBABY_MAX,
			 FALSE,
			 tarbaby_die, tarpumpkin_spawn))
	{
		remove(self);
		return;
	}
	
	precache_sound ("weapons/rocket_impact.wav");
}

// compatibility with old spawns
void spawnfunc_monster_spawn () { spawnfunc_monster_tarbaby(); }
