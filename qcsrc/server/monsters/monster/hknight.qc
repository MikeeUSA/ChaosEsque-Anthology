// size
//const vector HELLKNIGHT_MIN = '-16 -16 -24'; //Old hooded floater
//const vector HELLKNIGHT_MAX = '16 16 32'; //Old hooded floater

const vector HELLKNIGHT_MIN = '-16 -16 0';
const vector HELLKNIGHT_MAX  = '16 16 80';

const vector HELLKNIGHT_DEAD_MIN = '-18 -18 0';
const vector HELLKNIGHT_DEAD_MAX = '18 18 45';


// cvars
float autocvar_g_monster_hellknight;
float autocvar_g_monster_hellknight_health;
float autocvar_g_monster_hellknight_melee_damage;
float autocvar_g_monster_hellknight_inferno_damage;
float autocvar_g_monster_hellknight_inferno_damagetime;
float autocvar_g_monster_hellknight_inferno_chance;
float autocvar_g_monster_hellknight_speed_walk;
float autocvar_g_monster_hellknight_speed_run;
float autocvar_g_monster_hellknight_fireball_damage;
float autocvar_g_monster_hellknight_fireball_force;
float autocvar_g_monster_hellknight_fireball_radius;
float autocvar_g_monster_hellknight_fireball_chance;
float autocvar_g_monster_hellknight_fireball_edgedamage;
float autocvar_g_monster_hellknight_spike_chance;
float autocvar_g_monster_hellknight_spike_force;
float autocvar_g_monster_hellknight_spike_radius;
float autocvar_g_monster_hellknight_spike_edgedamage;
float autocvar_g_monster_hellknight_spike_damage;
float autocvar_g_monster_hellknight_jump_chance;
float autocvar_g_monster_hellknight_jump_damage;
float autocvar_g_monster_hellknight_jump_dist;

// animations old
//#define hellknight_anim_stand 	0
//#define hellknight_anim_walk 	1
//#define hellknight_anim_run 	2
//#define hellknight_anim_pain 	3
//#define hellknight_anim_death1 	4
//#define hellknight_anim_death2 	5
//#define hellknight_anim_charge1 6
//#define hellknight_anim_magic1 	7
//#define hellknight_anim_magic2 	8
//#define hellknight_anim_charge2 9
//#define hellknight_anim_slice 	10
//#define hellknight_anim_smash 	11
//#define hellknight_anim_wattack 12
//#define hellknight_anim_magic3 	13
//#define hellknight_anim_stone 	14


//animations New
#define hellknight_anim_stand 	19
#define hellknight_anim_walk 	1
#define hellknight_anim_run 	27
#define hellknight_anim_pain 	20
#define hellknight_anim_deathback 	9
#define hellknight_anim_deathfront 	12
#define hellknight_anim_charge1 0
#define hellknight_anim_magic1 	34
#define hellknight_anim_magic2 	2
#define hellknight_anim_charge2 1
#define hellknight_anim_slice 	4
#define hellknight_anim_smash 	5
#define hellknight_anim_wattack 6
#define hellknight_anim_magic3 	3
#define hellknight_anim_stone 	33
#define hellknight_anim_deadback1			  31
#define hellknight_anim_deadfront1			  32

void hellknight_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void hellknight_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void hellknight_attack_armed()
{
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_Warhammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_Morgenstern_Attack();
	} else if (self.weaponentity.count == 4) {
		W_FlangedMacespiked_Attack();
	}
}

void hknight_spike_think()
{
	if(self)
	{
		RadiusDamage (self, self.realowner, autocvar_g_monster_hellknight_spike_damage * self.realowner.scale, autocvar_g_monster_hellknight_spike_edgedamage, autocvar_g_monster_hellknight_spike_force, world, autocvar_g_monster_hellknight_spike_radius, WEP_CRYLINK, other);
		remove(self);
	}
}

void hknight_spike_touch()
{
	PROJECTILE_TOUCH;
	
	pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);
	
	hknight_spike_think();
}

void hknight_arrowspike_think()
{
	if(self)
	{
		RadiusDamage (self, self.realowner, autocvar_g_monster_hellknight_spike_damage * self.realowner.scale, autocvar_g_monster_hellknight_spike_edgedamage, autocvar_g_monster_hellknight_spike_force, world, autocvar_g_monster_hellknight_spike_radius, WEP_CROSSBOWDTWR, other);
		remove(self);
	}
}

void hknight_arrowspike_touch()
{
	PROJECTILE_TOUCH;
	
	pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);
	
	hknight_spike_think();
}

void hknight_burningspike_think()
{
	if(self)
	{
		RadiusDamage (self, self.realowner, autocvar_g_monster_hellknight_spike_damage * self.realowner.scale, autocvar_g_monster_hellknight_spike_edgedamage, autocvar_g_monster_hellknight_spike_force, world, autocvar_g_monster_hellknight_spike_radius, DEATH_FIRE, other);
		Fire_AddDamage(self.enemy, self, autocvar_g_monster_hellknight_inferno_damage * monster_skill, autocvar_g_monster_hellknight_inferno_damagetime, self.projectiledeathtype);
		remove(self);
	}
}

void hknight_burningspike_touch()
{
	PROJECTILE_TOUCH;
	
	pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);
	
	hknight_burningspike_think();
}

void() hellknight_think;
void hknight_shoot ()
{
	local	entity 	missile = world;
	local	vector	dir = normalize((self.enemy.origin + '0 0 10') - (self.origin + '0 0 52'));
	local	float	dist = vlen (self.enemy.origin - self.origin), flytime = 0;

	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects |= EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + '0 0 62' + v_forward * 14);
	missile.scale = self.scale;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = hknight_spike_think;
	missile.enemy = self.enemy;
	missile.touch = hknight_spike_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_BULLET, TRUE);
}

void hknight_arrowshoot ()
{
	local	entity 	missile = world;
	local	vector	dir = normalize((self.enemy.origin + '0 0 10') - (self.origin + '0 0 52'));
	local	float	dist = vlen (self.enemy.origin - self.origin), flytime = 0;

	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects |= EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + '0 0 62' + v_forward * 14);
	missile.scale = self.scale;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = hknight_arrowspike_think;
	missile.enemy = self.enemy;
	missile.touch = hknight_arrowspike_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_BULLET_GLOWING_TRACER, TRUE);
}

void hknight_burningshoot ()
{
	local	entity 	missile = world;
	local	vector	dir = normalize((self.enemy.origin + '0 0 10') - (self.origin + '0 0 52'));
	local	float	dist = vlen (self.enemy.origin - self.origin), flytime = 0;

	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects |= EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/spike.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin(missile, self.origin + '0 0 62' + v_forward * 14);
	missile.scale = self.scale;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = hknight_burningspike_think;
	missile.enemy = self.enemy;
	missile.touch = hknight_burningspike_touch;
	CSQCProjectile(missile, TRUE, PROJECTILE_FIREMINE, TRUE);
}

void hknight_inferno ()
{
	traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, world);
	if (trace_fraction != 1)
		return; // not visible
	if(enemy_range() <= 2000)
		Fire_AddDamage(self.enemy, self, autocvar_g_monster_hellknight_inferno_damage * monster_skill, autocvar_g_monster_hellknight_inferno_damagetime, self.projectiledeathtype);
}

void hknight_infernowarning ()
{
	if(!self.enemy)
		return;
		
	traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, world);
	if (trace_fraction != 1)
		return; // not visible
	self.enemy.effects |= EF_MUZZLEFLASH;
	sound(self.enemy, CHAN_AUTO, "player/lava.wav", 1, ATTN_NORM);
	
	hknight_inferno();
}

//A test
void hknight_stone ()
{
	traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, world);
	if (trace_fraction != 1)
		return; // not visible
	if(enemy_range() <= 2000)
		Stone(self.enemy, 0.2/5);
}

void hknight_stonenowarning ()
{
	if(!self.enemy)
		return;
		
	traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, TRUE, world);
	if (trace_fraction != 1)
		return; // not visible
	
	hknight_stone();
}
//End Test

float() hknight_magic;
float hknight_checkmagic ()
{
	local vector v1 = '0 0 0', v2 = '0 0 0';
	local float dot = 0;

	// use magic to kill zombies as they heal too fast for sword
	if (self.enemy.classname == "monster_zombie")
	{
		traceline((self.absmin + self.absmax) * 0.5, (self.enemy.absmin + self.enemy.absmax) * 0.5, FALSE, self);
		if (trace_ent == self.enemy)
		{
			hknight_magic();
			return TRUE;
		}
	}

	if (random() < 0.25)
		return FALSE; // 25% of the time it won't do anything
	v1 = normalize(self.enemy.velocity);
	v2 = normalize(self.enemy.origin - self.origin);
	dot = v1 * v2;
	if (dot >= 0.7) // moving away
	if (vlen(self.enemy.velocity) >= 150) // walking/running away
		return hknight_magic();
	return FALSE;
}

void() hellknight_charge;
void CheckForCharge ()
{
	// check for mad charge
	if (time < self.attack_finished_single)
		return;
	if ( fabs(self.origin_z - self.enemy.origin_z) > 20)
		return;		// too much height change
	if ( vlen (self.origin - self.enemy.origin) < 80)
		return;		// use regular attack
	if (hknight_checkmagic())
		return; // chose magic

	// charge
	hellknight_charge();
}

void CheckContinueCharge ()
{
	if(hknight_checkmagic())
		return; // chose magic
	if(time >= self.attack_finished_single)
	{
		hellknight_think();
		return;		// done charging
	}
}

void hellknight_think ()
{
	monster_hook_think();
	
	self.think = hellknight_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = hellknight_anim_stone;
		
	monster_move(autocvar_g_monster_hellknight_speed_run, autocvar_g_monster_hellknight_speed_walk, 100, hellknight_anim_run, hellknight_anim_walk, hellknight_anim_stand);
}

.float hknight_cycles;
void hellknight_magic ()
{
	self.hknight_cycles += 1;
	self.think = hellknight_magic;
	
	if(self.hknight_cycles >= 5)
	{
		if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_magic1;
		self.attack_finished_single = time + 0.7;
		
		if (CheckSpellNoCancel(self, 20, self.origin)) {
			hknight_infernowarning();
		}
		
		self.think = hellknight_think;
	}
	
	self.nextthink = time + 0.1;
}

void hknight_fireball_explode(entity targ)
{
	float scle = self.realowner.scale;
	if(self)
	{
		RadiusDamage (self, self.realowner, autocvar_g_monster_hellknight_fireball_damage * scle, autocvar_g_monster_hellknight_fireball_edgedamage * scle, autocvar_g_monster_hellknight_fireball_force * scle, world, autocvar_g_monster_hellknight_fireball_radius * scle, WEP_FIREBALL, targ);
		if(targ)
			Fire_AddDamage(targ, self, 5 * monster_skill, autocvar_g_monster_hellknight_inferno_damagetime, self.projectiledeathtype);
		remove(self);
	}
}

void hknight_fireball_think()
{
	hknight_fireball_explode(world);
}

void hknight_fireball_touch()
{
	PROJECTILE_TOUCH;
	
	hknight_fireball_explode(other);
}

void hellknight_fireball ()
{
	local	entity 	missile = spawn();
	local	vector	dir = normalize((self.enemy.origin + '0 0 10') - (self.origin + '0 0 52'));
	vector fmins = ((self.scale >= 2) ? '-16 -16 -16' : '-4 -4 -4'), fmaxs = ((self.scale >= 2) ? '16 16 16' : '4 4 4');

	self.effects |= EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "weapons/fireball2.wav", 1, ATTN_NORM);

	missile.owner = missile.realowner = self;
	missile.solid = SOLID_TRIGGER;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setsize (missile, fmins, fmaxs);		
	setorigin(missile, self.origin + '0 0 62' + v_forward * 14);
	//setorigin(missile, self.origin + '0 0 10' + v_forward * 14); //Was for old hooded floater model
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.nextthink = time + 5;
	missile.think = hknight_fireball_think;
	missile.enemy = self.enemy;
	missile.touch = hknight_fireball_touch;
	CSQCProjectile(missile, TRUE, ((self.scale >= 2) ? PROJECTILE_FIREBALL : PROJECTILE_FIREMINE), TRUE);
	
	self.delay = -1;
}

void hellknight_magic2 ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_magic2;
	if (CheckSpellNoCancel(self, 20, self.origin)) {
		self.attack_finished_single = time + 1.2;
		self.delay = time + 0.4;
		self.monster_delayedattack = hellknight_fireball;
	}
}

void hellknight_spikes ()
{
	self.think = hellknight_spikes;
	self.nextthink = time + 0.1;
	self.hknight_cycles += 1;
	if (self.skin == 4) {
		hknight_burningshoot();
	} else if ((self.skin == 6 || self.skin == 0) && (random() > 0.5)) {
		hknight_arrowshoot(); //Different visual effect and dmg type
	} else {
		hknight_shoot();
	}
	if(self.hknight_cycles >= 7)
		self.think = hellknight_think;
}

void hellknight_magic3 ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_magic3;
	if (CheckSpellNoCancel(self, 20, self.origin)) {
		self.attack_finished_single = time + 1;
		self.think = hellknight_spikes;
		self.nextthink = time + 0.4;
	}
}

void hellknight_charge ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_charge1;
	self.attack_finished_single = time + 0.5;
	
	hknight_checkmagic();
	monster_melee(self.enemy, autocvar_g_monster_hellknight_melee_damage, 70, DEATH_MONSTER_MELEE);
	hknight_checkmagic();
}

void hellknight_charge2 ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_charge2;
	self.attack_finished_single = time + 0.5;
	
	CheckContinueCharge ();
	monster_melee(self.enemy, autocvar_g_monster_hellknight_melee_damage, 70, DEATH_MONSTER_MELEE);
}

void hellknight_slice ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_slice;
	self.attack_finished_single = time + 0.7;
	monster_melee(self.enemy, autocvar_g_monster_hellknight_melee_damage, 70, DEATH_MONSTER_MELEE);
	hellknight_attack_armed();
}

void hellknight_smash ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_smash;
	self.attack_finished_single = time + 0.7;
	monster_melee(self.enemy, autocvar_g_monster_hellknight_melee_damage, 70, DEATH_MONSTER_MELEE);
	hellknight_attack_armed();
}

void hellknight_weapon_attack ()
{
	if (self.stoned || self.frozen) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_wattack;
	self.attack_finished_single = time + 0.7;
	monster_melee(self.enemy, autocvar_g_monster_hellknight_melee_damage, 70, DEATH_MONSTER_MELEE);
	hellknight_attack_armed();
}

float hknight_type;
void hknight_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	hknight_type += 1;

	if (hknight_type == 1)
		hellknight_slice();
	else if (hknight_type == 2)
		hellknight_smash();
	else
	{
		hellknight_weapon_attack();
		hknight_type = 0;
	}
}

float hknight_magic ()
{
	if (self.frozen)
		return FALSE;
		
	if (self.stoned)
		return FALSE;
		
	if not(self.flags & FL_ONGROUND)
		return FALSE;
		
	if not(self.enemy)
		return FALSE; // calling attack check with no enemy?!
		
	if(time < self.attack_finished_single)
		return FALSE;
		
	self.hknight_cycles = 0;

	if (self.enemy.classname == "monster_zombie")
	{
		// always use fireball to kill zombies
		hellknight_magic2();
		self.attack_finished_single = time + 2;
		return TRUE;
	}
	RandomSelection_Init();
	RandomSelection_Add(world, 0, "fireball", autocvar_g_monster_hellknight_fireball_chance, 1);
	RandomSelection_Add(world, 0, "inferno", autocvar_g_monster_hellknight_inferno_chance, 1);
	RandomSelection_Add(world, 0, "spikes", autocvar_g_monster_hellknight_spike_chance, 1);
	if(self.health >= 100)
		RandomSelection_Add(world, 0, "jump", ((enemy_range() > autocvar_g_monster_hellknight_jump_dist * self.scale) ? 1 : autocvar_g_monster_hellknight_jump_chance), 1);
	
	switch(RandomSelection_chosen_string)
	{
		case "fireball":
		{
			hellknight_magic2();
			self.attack_finished_single = time + 2;
			return TRUE;
		}
		case "spikes":
		{
			hellknight_magic3();
			self.attack_finished_single = time + 3;
			return TRUE;
		}
		case "inferno":
		{
			hellknight_magic();
			self.attack_finished_single = time + 3;
			return TRUE;
		}
		case "jump":
		{
			if (enemy_range() >= 400)
			if (findtrajectorywithleading(self.origin, self.mins, self.maxs, self.enemy, 1000, 0, 10, 0, self))
			{
				self.velocity = findtrajectory_velocity;
				Damage(self.enemy, self, self, autocvar_g_monster_hellknight_jump_damage * monster_skill, DEATH_VHCRUSH, self.enemy.origin, normalize(self.enemy.origin - self.origin));
				self.attack_finished_single = time + 2;
				return TRUE;
			}
			return FALSE;
		}
		default:
			return FALSE;
	}
	// never get here
}

void hellknight_die ()
{
	if (self.skin == 1 || self.skin == 2) {
		placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot
		//Others are inhuman
	}

	float chance = random();
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("hellknight");
	
	//self.stat_bangflash = 0; //Not affected
	//self.stat_nukeflash = 0; //Not affected
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	self.pain_finished  = self.nextthink;
	self.angles_z = 55 + (35 * random());
	setsize (self, HELLKNIGHT_DEAD_MIN, HELLKNIGHT_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 128', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	
	//if(chance < 0.10 || self.flags & MONSTERFLAG_MINIBOSS)
	//{
	//	self.superweapons_finished = time + autocvar_g_balance_superweapons_time;
	//	W_ThrowNewWeapon(self, WEP_FIREBALL, 0, self.origin, self.velocity);
	//}
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
		
	
	if (random() > 0.5) {
		self.think = hellknight_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_deathback;
	} else {
		self.think = hellknight_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = hellknight_anim_stone; else self.frame = hellknight_anim_deathfront;
	}
		
	monster_hook_death(); // for post-death mods
}

void hellknight_spawn ()
{
	local float wrand;
	if (self.health <= 0)
		self.health = autocvar_g_monster_hellknight_health * self.scale;

	self.stoneskin = 3;

	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.scale = self.scale + ((random()-0.15)*0.2);
	
	self.damageforcescale   = 0.003;
	self.classname			= "monster_hellknight";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_melee	   	= hknight_melee;
	self.attack_ranged	  	= hknight_magic;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= hellknight_think;
	self.sprite_height	  	= 30 * self.scale;
	self.frame				= hellknight_anim_stand;
	
	self.armorvalue = g_pickup_armormedium;
	
	if (self.scale > 1.2) {
		self.skin = 4;
		self.resist_fire = 1; //BurningHellknight
		self.resist_laser = 0.75;
		self.vuln_beam_ignite = 100;
	} else if (self.scale < 1) {
		if (random() > 0.5) {
			self.skin = 1;
		} else {
			self.skin = 2;
		}
		//Deathknight	
	} else {
		if (random() > 0.5) {
			self.skin = 0;
		} else {
			self.skin = 6;
		}
		self.resist_fire = 0.85; //Hellknight
	}

	if (self.scale) self.view_ofs = '0 0 55' * self.scale;
	else self.view_ofs = '0 0 55';
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;
	
	self.weaponentity.alpha = 1;
	self.weaponentity.angles    = '65 -30 0';
	
	wrand = random();
	if (wrand > 0.85)
	{
		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_broadaxe.md3");
		self.weaponentity.count = 1;
	} else if (wrand > 0.75) {
		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
		self.weaponentity.count = 2;
	} else if (wrand > 0.50) {
		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_morgenstern.md3");
		self.weaponentity.count = 3;
	} else {
		setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_flangedmace.md3");
		self.weaponentity.count = 4;
	}
	
	setattachment(self.weaponentity, self, "hand_ctrl_r");
		
		wrand = random();
		if (wrand > 0.95)
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
			if (autocvar_g_monsters_jitprecacheonly > 1) {
				precache_model ("models/misc/playerspikes_head.iqm");
			}
			setmodel(self.bomb2,  "models/misc/playerspikes_head.iqm");
			self.bomb2.angles    = '0 0 -90';
			setattachment(self.bomb2, self, "skull");
			setorigin(self.bomb2, '0 12 -2');    // Move attch spot up 12// back 2// yes fscked up bone  
			self.health = self.health * 1.25;
			self.armorvalue = self.armorvalue + g_pickup_armormedium;
		}
				
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void hell_knight_precache_weapons()
{
	if (autocvar_g_monsters_jitprecacheonly <= 0) {
	precache_model ("models/weapons/v_warhammerspiked.md3");
	precache_model ("models/weapons/v_morgenstern.md3");
	precache_model ("models/weapons/v_broadaxe.md3");
	precache_model ("models/weapons/v_flangedmace.md3");
	}
	
	if (autocvar_g_monsters_jitprecacheonly <= 1) {
	precache_model ("models/misc/playerspikes_head.iqm");	
	}
}

void spawnfunc_monster_hell_knight ()
{	
	if not(autocvar_g_monster_hellknight)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_hell_knight;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	//self.scale = 1.3; //Old
	
	if not (monster_initialize(
			 "Hell-knight",
			 "models/monsters/royalguardhel.iqm",
			 HELLKNIGHT_MIN, HELLKNIGHT_MAX,
			 FALSE,
			 hellknight_die, hellknight_spawn))
	{
		remove(self);
		return;
	}
	
	precache_sound ("weapons/spike.wav");
	
	hell_knight_precache_weapons();
}

// compatibility with old spawns
void spawnfunc_monster_hellknight () { spawnfunc_monster_hell_knight(); }
