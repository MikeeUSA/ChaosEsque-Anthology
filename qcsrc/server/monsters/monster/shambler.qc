// size
const vector SHAMBLER_MIN = '-28 -28 -44';
const vector SHAMBLER_MAX = '28 28 88';

const vector SHAMBLER_DEAD_MIN = '-32 -32 -20';
const vector SHAMBLER_DEAD_MAX = '32 32 2';

// cvars
float autocvar_g_monster_shambler;
float autocvar_g_monster_shambler_health;
float autocvar_g_monster_shambler_damage;
float autocvar_g_monster_shambler_attack_lightning_damage;
float autocvar_g_monster_shambler_attack_claw_damage;
float autocvar_g_monster_shambler_speed_walk;
float autocvar_g_monster_shambler_speed_run;

// animations old hooded figure
//#define shambler_anim_stand 	0
//#define shambler_anim_walk 		1
//#define shambler_anim_run 		2
//#define shambler_anim_smash 	3
//#define shambler_anim_swingr 	4
//#define shambler_anim_swingl 	5
//#define shambler_anim_magic 	6
//#define shambler_anim_pain 		7
//#define shambler_anim_death 	8
//#define shambler_anim_dead	9
//#define shambler_anim_stone	10

// animations new
#define shambler_anim_stand 	11
#define shambler_anim_walk 	9
#define shambler_anim_run 	3
#define shambler_anim_smash 	1
#define shambler_anim_swingr 	0
#define shambler_anim_swingl 	0
#define shambler_anim_magic 	1
#define shambler_anim_pain 	8
#define shambler_anim_death 	4
#define shambler_anim_dead	6 //7 //be standing but lying down
#define shambler_anim_stone	6

void shambler_think ()
{
	monster_hook_think();
	
	self.think = shambler_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = shambler_anim_stone;
		
	monster_move(autocvar_g_monster_shambler_speed_run, autocvar_g_monster_shambler_speed_walk, 300, shambler_anim_run, shambler_anim_walk, shambler_anim_stand);
}

void shambler_smash ()
{
	float bigdmg = autocvar_g_monster_shambler_damage * self.scale;
	
	self.think = shambler_think;
	self.attack_finished_single = time + 0.4;
	self.nextthink = self.attack_finished_single;

	if (!self.enemy)
		return;

	if (enemy_range() > 100 * self.scale)
		return;
	
	Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_SHAMBLER_MELEE, self.enemy.origin, normalize(self.enemy.origin - self.origin));
}

void shambler_delayedsmash ()
{
	if (self.stoned || self.frozen) self.frame = shambler_anim_stone; else self.frame = shambler_anim_smash;
	self.think = shambler_smash;
	self.nextthink = time + 0.7;
}

void ShamClaw (float side)
{
	float bigdmg = autocvar_g_monster_shambler_attack_claw_damage * self.scale;
	
	monster_melee(self.enemy, bigdmg * monster_skill, 100, DEATH_MONSTER_SHAMBLER_CLAW);
}

void() shambler_swing_right;
void shambler_swing_left ()
{
	if (self.stoned || self.frozen) self.frame = shambler_anim_stone; else self.frame = shambler_anim_swingl;
	ShamClaw(250);
	self.attack_finished_single = time + 0.8;
	self.nextthink = self.attack_finished_single;
	self.think = shambler_think;
	if(random() < 0.5)
		self.think = shambler_swing_right;
}

void shambler_swing_right ()
{
	if (self.stoned || self.frozen) self.frame = shambler_anim_stone; else self.frame = shambler_anim_swingr;
	ShamClaw(-250);
	self.attack_finished_single = time + 0.8;
	self.nextthink = self.attack_finished_single;
	self.think = shambler_think;
	if(random() < 0.5)
		self.think = shambler_swing_left;
}

void sham_melee ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	local float chance = random();

	if (chance > 0.6)
		shambler_delayedsmash();
	else if (chance > 0.3)
		shambler_swing_right ();
	else
		shambler_swing_left ();
}

void CastLightningOld ()
{
	self.nextthink = time + 0.4;
	self.think = shambler_think;
	
	local vector org = '0 0 0', dir = '0 0 0';
	vector v = '0 0 0';

	self.effects |= EF_MUZZLEFLASH;

	org = self.origin + '0 0 40' * self.scale;

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	traceline (org, self.origin + dir * 1000, TRUE, self);
		
	FireRailgunBullet (org, org + dir * 1000, autocvar_g_monster_shambler_attack_lightning_damage * monster_skill, 0, 0, 0, 0, 0, DEATH_MONSTER_SHAMBLER_LIGHTNING);
	
	// teamcolor / hit beam effect
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	WarpZone_TrailParticles(world, particleeffectnum("TE_TEI_G3"), org, v);
}

void CastLightning ()
{
	self.nextthink = time + 0.4;
	self.think = shambler_think;
	
	local vector org = '0 0 0', dir = '0 0 0';
	vector v = '0 0 0';

	self.effects |= EF_MUZZLEFLASH;

	org = self.origin + '0 0 40' * self.scale;

	dir = self.enemy.origin + '0 0 16' - org;
	dir = normalize (dir);

	traceline (org, self.origin + dir * 1000, TRUE, self);
		
	local float trandvar;
	trandvar = random();
	if (trandvar > 0.75) {
		te_csqc_lightningarc(org,trace_endpos);
		lgunbeam_arcs(36 + 50, autocvar_g_balance_lightninggun_primary_arcrange * 4, trace_endpos, self);
	} else if (trandvar > 0.5) {
		te_csqc_lightningarcd(org,trace_endpos);
		lgunbeam_arcsd(36 + 50, autocvar_g_balance_lightninggun_primary_arcrange * 4, trace_endpos, self);
	} else if (trandvar > 0.25) {
		te_csqc_lightningarcp(org,trace_endpos);
		lgunbeam_arcsp(36 + 50, autocvar_g_balance_lightninggun_primary_arcrange * 4, trace_endpos, self);
	} else {
		te_csqc_lightningarcc(org,trace_endpos);
		lgunbeam_arcsc(36 + 50, autocvar_g_balance_lightninggun_primary_arcrange * 4, trace_endpos, self);
	}


	if (random() > 0.4) sound (self, CH_WEAPON_A, "weapons/lgbeam_fire.wav", VOL_BASE*(0.3+(random()*0.7)), ATTN_NORM);
}

void shambler_magic ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stoned || self.frozen) self.frame = shambler_anim_stone; else self.frame = shambler_anim_magic;
	self.attack_finished_single = time + 1.1;
	self.nextthink = time + 0.6;
	self.think = CastLightning;
}
	
float sham_lightning ()
{
	shambler_magic();
	return TRUE;
}

void shambler_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = shambler_anim_stone; else self.frame = shambler_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void shambler_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("shambler");
	
	//W_ThrowNewWeapon(self, WEP_NEX, 0, self.origin, self.velocity);
	//We set think below to load the deadbody "animation", then fade
	self.think		  	= shambler_death;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	self.frame			= shambler_anim_death;
	self.pain_finished  = self.nextthink;
	self.movetype 		= MOVETYPE_TOSS;
	self.angles_z = 55 + (35 * random());
	setsize (self, SHAMBLER_DEAD_MIN, SHAMBLER_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 128', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	
	
	monster_hook_death(); // for post-death mods
}

void shambler_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_shambler_health * self.scale;

	self.stoneskin = 1;
	
	self.gibscale = 1.5;
	
	self.monster_hasheightenedsenseofsmell = 0.75;
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);

	self.damageforcescale   = 0.003;
	self.species = SPECIES_ANIMAL;
	self.classname			= "monster_shambler";
	self.attack_melee		= sham_melee;
	self.checkattack	 	= GenericCheckAttack;
	self.attack_ranged	  	= sham_lightning;
	self.nextthink		 	= time + random() * 0.5 + 0.1;
	self.frame				= shambler_anim_stand;
	self.think			  	= shambler_think;
	self.sprite_height	  	= 70 * self.scale;
	
	self.resist_bullet = 0.65;
	self.resist_blunt = 0.75;  //Warhammer, beatdown, melee
	self.resist_crush = 0.75;  //Vehicle crush
	self.resist_edged = 0.5;  //Axe, Sword, Claw
	self.resist_electricity = 0.5; //Lightning gun, Tesla arc, 
	//self.resist_energy = 0; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	self.resist_explode = 0.85; //Rockets etc //Shrugs off like it's nothing?
	self.resist_fall = 0.2;   //Shooting star, fall etc
	//self.resist_fire = 0;   //Fire, Lava
	//self.resist_laser = 0;  //Laser
	//self.resist_nuke = 0;  //Nuclear explosion
	self.resist_pierce = 0.5; //Crossbow, Bite
	self.resist_sound = 1; //Tuba
	self.resist_ice = 0.6; //Freeze damage resistance
	self.resist_rotor = 0.6; //Heli rotor blades do less damage than normal
	
	self.loddistance1 = 2048;
	self.lodmodel1 = "models/monsters/CH1monster3_lod1.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_shambler ()
{	
	if not(autocvar_g_monster_shambler)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_shambler;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "Shambler",
			 "models/monsters/CH1monster3.iqm",
			 SHAMBLER_MIN, SHAMBLER_MAX,
			 FALSE,
			 shambler_die, shambler_spawn))
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/beam.mdl");
	precache_model ("models/weapons/g_nex.md3");
	
	precache_sound ("weapons/lgbeam_fire.wav");
}
