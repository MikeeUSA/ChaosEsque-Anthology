// size
const vector SHALRATH_MIN = '-32 -32 -24';
const vector SHALRATH_MAX = '32 32 32';

// cvars
float autocvar_g_monster_shalrath;
float autocvar_g_monster_shalrath_health;
float autocvar_g_monster_shalrath_damage;
float autocvar_g_monster_shalrath_speed;

// animations
#define shalrath_anim_attack 	0
#define shalrath_anim_pain 		1
#define shalrath_anim_death 	2
#define shalrath_anim_walk 		3
#define shalrath_anim_stone 		4

void() ShalMissile;

void shalrath_think ()
{
	monster_hook_think();
	
	self.think = shalrath_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if(self.delay != -1)
		self.nextthink = self.delay;
	
	if (self.stoned || self.frozen)
		self.frame = shalrath_anim_stone;
		
	monster_move(autocvar_g_monster_shalrath_speed, autocvar_g_monster_shalrath_speed, 50, shalrath_anim_walk, shalrath_anim_walk, shalrath_anim_walk);
}

void shalrath_attack ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = shalrath_anim_stone; else self.frame = shalrath_anim_attack;
	if(random() > 0.08) {
		//Homing magic missile
		self.delay = time + 0.1;
		self.attack_finished_single = time + 0.7;
		self.monster_delayedattack = ShalMissile;
	} else {
		//Ice Attack
		self.delay = time + 0.05;
		self.attack_finished_single = time + 0.4;
		self.monster_delayedattack = W_Iceball_Attack1;
	}
}

void shalrathattack_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float bigdmg = 0, rdmg = autocvar_g_monster_shalrath_damage * random();

	bigdmg = rdmg * self.scale;

	monster_melee(self.enemy, bigdmg * monster_skill, 120, DEATH_MONSTER_SHALRATH_MELEE);
}

void shalrath_attack_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	self.monster_delayedattack = shalrathattack_melee;
	self.delay = time + 0.2;
	if (self.stoned || self.frozen) self.frame = shalrath_anim_stone; else self.frame = shalrath_anim_attack;
	self.attack_finished_single = time + 0.7;
}

float shal_missile ()
{
	if (self.frozen)
		return FALSE;
		
	if (self.stoned)
		return FALSE;
		
	// don't throw if it is blocked
	traceline(self.origin + '0 0 10', self.enemy.origin + '0 0 10', FALSE, self);
	if (enemy_range() > 1000)
		return FALSE;
	if (trace_ent != self.enemy)
		return FALSE;
	shalrath_attack();
	return TRUE;
}

void() ShalHome;
void ShalMissile_Spawn ()
{
	local	vector	dir = '0 0 0';
	local	float	dist = 0;
	
	self.realowner.effects |= EF_MUZZLEFLASH;
	
	dir = normalize((self.owner.enemy.origin + '0 0 10') - self.owner.origin);
	dist = vlen (self.owner.enemy.origin - self.owner.origin);
	
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_FLYMISSILE;
	CSQCProjectile(self, TRUE, PROJECTILE_CRYLINK, TRUE);
	
	self.realowner.v_angle = self.realowner.angles;
	makevectors (self.realowner.angles);

	setsize (self, '0 0 0', '0 0 0');		

	setorigin (self, self.realowner.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	self.velocity = dir * 400;
	self.avelocity = '300 300 300';
	self.enemy = self.realowner.enemy;
	self.projectiledeathtype = WEP_CRYLINK;
	self.touch = W_Plasma_TouchExplode;
	ShalHome();
}

void ShalMissile ()
{
	local	entity 	missile = world;

	sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = missile.realowner = self;

	missile.think = ShalMissile_Spawn;
	missile.nextthink = time;
}

.float shal_cycles;
void ShalHome ()
{
	local vector dir = '0 0 0', vtemp = self.enemy.origin + '0 0 10';
	
	self.shal_cycles += 1;
	if (self.enemy.health <= 0 || self.owner.health <= 0 || self.shal_cycles >= 20)
	{
		remove(self);
		return;
	}
	dir = normalize(vtemp - self.origin);
	UpdateCSQCProjectile(self);
	if (autocvar_skill == 3)
		self.velocity = dir * 350;
	else
		self.velocity = dir * 250;
	self.nextthink = time + 0.2;
	self.think = ShalHome;	
}

float ShalrathCheckAttack ()
{
	local vector spot1 = '0 0 0', spot2 = '0 0 0';
	local entity targ = self.enemy;

	if (self.health <= 0 || targ == world || targ.health < 1)
		return FALSE;
	
	if(self.monster_delayedattack && self.delay != -1)
	{
		if(time < self.delay)
			return FALSE;
			
		self.monster_delayedattack();
		self.delay = -1;
		self.monster_delayedattack = func_null;
	}
	
	if(time < self.attack_finished_single)
		return FALSE;
	
	if (vlen(self.enemy.origin - self.origin) <= 120)
	{	// melee attack
		if (self.attack_melee)
		{
			self.attack_melee();
			return TRUE;
		}
	}

	if (vlen(targ.origin - self.origin) >= 2000) // long traces are slow
		return FALSE;

// see if any entities are in the way of the shot
	spot1 = self.origin + '0 0 10';
	spot2 = targ.origin + '0 0 10';

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ && trace_fraction < 1)
		return FALSE; // don't have a clear shot

	//if (trace_inopen && trace_inwater)
	//	return FALSE; // sight line crossed contents

	if (random() < 0.2)
	if (self.attack_ranged())
		return TRUE;

	return FALSE;
}

void shalrath_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("shalrath");
	
	self.think		  	= Monster_Fade;
	self.frame			= shalrath_anim_death;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	self.pain_finished  = self.nextthink;	
	self.movetype		= MOVETYPE_TOSS;
	
	monster_hook_death(); // for post-death mods
}

void shalrath_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_shalrath_health * self.scale;

	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);

	self.damageforcescale   = 0.003;
	self.classname			= "monster_shalrath";
	self.checkattack	 	= ShalrathCheckAttack;
	self.attack_ranged	  	= shal_missile;
	self.attack_melee		= shalrath_attack_melee;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= shalrath_think;
	self.frame				= shalrath_anim_walk;
	self.sprite_height	  	= 40 * self.scale;
	
	self.resist_ice = 0.5;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_shalrath ()
{	
	if not(autocvar_g_monster_shalrath)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_shalrath;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		
		return;
	}
	
	self.scale = 1.3;
	
	if not (monster_initialize(
			 "Vore",
			 "models/monsters/shalrath.mdl",
			 SHALRATH_MIN, SHALRATH_MAX,
			 FALSE,
			 shalrath_die, shalrath_spawn))
	{
		remove(self);
		return;
	}
}

// compatibility with old spawns
void spawnfunc_monster_vore () { spawnfunc_monster_shalrath(); }
