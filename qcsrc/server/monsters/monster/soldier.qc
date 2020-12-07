// size
const vector SOLDIER_MIN = '-16 -16 -24';
const vector SOLDIER_MAX = '16 16 45';

// cvars
float autocvar_g_monster_soldier;
float autocvar_g_monster_soldier_health;
float autocvar_g_monster_soldier_melee_damage;
float autocvar_g_monster_soldier_speed_walk;
float autocvar_g_monster_soldier_speed_jog_rate;
float autocvar_g_monster_soldier_speed_run;
float autocvar_g_monster_soldier_ammo;
float autocvar_g_monster_soldier_weapon_laser_chance;
float autocvar_g_monster_soldier_weapon_shotgun_chance;
float autocvar_g_monster_soldier_weapon_machinegun_chance;
float autocvar_g_monster_soldier_weapon_rocketlauncher_chance;
float autocvar_g_monster_soldier_attack_uzi_bullets;

// animations //old
//#define soldier_anim_stand 	0
//#define soldier_anim_death1 1
//#define soldier_anim_death2 2
//#define soldier_anim_reload 3
//#define soldier_anim_pain1 	4
//#define soldier_anim_pain2 	5
//#define soldier_anim_pain3 	6
//#define soldier_anim_run 	7
//#define soldier_anim_shoot 	8
//#define soldier_anim_prowl 	9
//#define soldier_anim_stone	10

#define soldier_anim_stand 	7
#define soldier_anim_death1 	0
#define soldier_anim_death2 	1
#define soldier_anim_reload 	2
#define soldier_anim_pain1 	4
#define soldier_anim_pain2 	5
#define soldier_anim_pain3 	6
#define soldier_anim_run 	33 //7 //13
#define soldier_anim_shoot 	11
#define soldier_anim_prowl 	33 //7 //13
#define soldier_anim_stone	31
#define soldier_anim_deadback1 	17
#define soldier_anim_deadfront1 18

void solider_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = soldier_anim_stone; else self.frame = soldier_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void solider_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = soldier_anim_stone; else self.frame = soldier_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void soldier_think ()
{
	monster_hook_think();
	
	if (self.stoned || self.frozen)
		self.frame = soldier_anim_stone;

	self.think = soldier_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if(self.delay != -1)
		self.nextthink = self.delay;
	
	if(time < self.attack_finished_single)
		monster_move(0, 0, 0, soldier_anim_shoot, soldier_anim_shoot, soldier_anim_shoot);

	monster_move(monster_mvmntimpare_human(autocvar_g_monster_soldier_speed_run), monster_mvmntimpare_human(autocvar_g_monster_soldier_speed_walk), 50, soldier_anim_run, soldier_anim_prowl, soldier_anim_stand);
}

void soldier_reload ()
{
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_reload;
	self.attack_finished_single = time + 2;
	self.currentammo = autocvar_g_monster_soldier_ammo;
	sound (self, CH_SHOTS, "weapons/reload.wav", VOL_BASE, ATTN_LARGE);
}

float SoldierCheckAttack ()
{
	local vector spot1 = '0 0 0', spot2 = '0 0 0';
	local entity targ = self.enemy;
	local float chance = 0;

	if (self.health <= 0 || targ.health < 1 || targ == world)
		return FALSE;

	if (vlen(targ.origin - self.origin) > 2000) // long traces are slow
		return FALSE;

	// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE; // don't have a clear shot

	if (trace_inwater)
	if (trace_inopen)
		return FALSE; // sight line crossed contents
		
	if(self.monster_delayedattack && self.delay != -1)
	{
		if(time < self.delay)
			return FALSE;
			
		self.monster_delayedattack();
	}

	// missile attack
	if (time < self.attack_finished_single)
		return FALSE;

	if (enemy_range() >= 2000)
		return FALSE;

	if (enemy_range() <= 120)
		chance = 0.9;
	else if (enemy_range() <= 500)
		chance = 0.6; // was 0.4
	else if (enemy_range() <= 1000)
		chance = 0.3; // was 0.05
	else
		chance = 0;

	if (chance > 0)
	if (chance > random())
		return FALSE;
		
	if(self.currentammo <= 0 && enemy_range() <= 120)
	{
		self.attack_melee();
		return TRUE;
	}
	
	if(self.currentammo <= 0)
	{
		soldier_reload();
		return FALSE;
	}

	if (self.attack_ranged())
		return TRUE;

	return FALSE;
}

void soldier_laser ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}
		
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_shoot;
	self.attack_finished_single = time + 0.8;
	W_Laser_Attack(0);
}

float soldier_missile_laser ()
{
	// FIXME: check if it would hit
	soldier_laser();
	return TRUE;
}

.float grunt_cycles;
void soldier_uzi_fire ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}
		
	self.currentammo -= 1;
	if(self.currentammo <= 0)
		return;
		
	self.grunt_cycles += 1;
	
	if(self.grunt_cycles > autocvar_g_monster_soldier_attack_uzi_bullets)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
		return;
	}
	W_CARBINE_Attack(DEATH_MONSTER_SOLDIER_NAIL);
	self.delay = time + 0.1;
	self.monster_delayedattack = soldier_uzi_fire;
}

void soldier_uzi ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}	
	
	if(self.currentammo <= 0)
		return;
		
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_shoot;
	self.attack_finished_single = time + 0.8;
	self.delay = time + 0.1;
	self.monster_delayedattack = soldier_uzi_fire;
}

float soldier_missile_uzi ()
{
	self.grunt_cycles = 0;
	// FIXME: check if it would hit
	soldier_uzi();
	return TRUE;
}

void soldier_shotgun ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}	
		
	self.currentammo -= 1;
	if(self.currentammo <= 0)
		return;
		
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_shoot;
	self.attack_finished_single = time + 0.8;
	W_Shotgun_Attack();
}

float soldier_missile_shotgun ()
{
	// FIXME: check if it would hit
	self.grunt_cycles = 0;
	soldier_shotgun();
	return TRUE;
}

void soldier_rl ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}	
		
	self.currentammo -= 1;
	if(self.currentammo <= 0)
		return;
		
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_shoot;
	self.attack_finished_single = time + 0.8;
	W_Rocket_Attack();
}

float soldier_missile_rl ()
{
	// FIXME: check if it would hit
	soldier_rl();
	return TRUE;
}

void soldier_bash ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99) {
		self.enemy = world;
		return;
	}
	
	if (self.stat_nukeflash > 99) {
		self.enemy = world;
		return;
	}	
		
	if (self.stoned || self.frozen) self.frame = soldier_anim_stone; else self.frame = soldier_anim_shoot;
	self.attack_finished_single = time + 0.8;
	monster_melee(self.enemy, autocvar_g_monster_soldier_melee_damage, 70, DEATH_MONSTER_SOLDIER_NAIL);
}

void soldier_die()
{
	placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("soldier");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.nextthink	  	= time + 0.5;
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
		if (self.attack_ranged == soldier_missile_uzi)
			W_ThrowNewWeapon(self, WEP_CARBINE, 0, self.origin, self.velocity);	   
		else if (self.attack_ranged == soldier_missile_shotgun)
			W_ThrowNewWeapon(self, WEP_SHOTGUN, 0, self.origin, self.velocity);
		else if (self.attack_ranged == soldier_missile_rl)
			W_ThrowNewWeapon(self, WEP_ROCKET_LAUNCHER, 0, self.origin, self.velocity);
		else
			W_ThrowNewWeapon(self, WEP_LASER, 0, self.origin, self.velocity);
	}
	
	if (random() < 0.5) {
		self.think = solider_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = soldier_anim_stone; else self.frame = soldier_anim_death1;
	} else {
		self.think = solider_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = soldier_anim_stone; else self.frame = soldier_anim_death2;
	}
	
	monster_hook_death(); // for post-death mods
}

void soldier_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_soldier_health * self.scale;

	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);

	self.monster_jogspeedrate = autocvar_g_monster_soldier_speed_jog_rate;

	self.damageforcescale   = 0.003;
	self.classname			= "monster_soldier";
	self.checkattack	 	= SoldierCheckAttack;
	self.attack_melee		= soldier_bash;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= soldier_think;
	self.sprite_height	  	= 30 * self.scale;
	self.items				= (IT_SHELLS | IT_ROCKETS | IT_NAILS);
	self.shot_dmg			= 20;
	self.shot_spread		= 0;
	self.shot_speed			= 2000;
	self.shot_force			= 200;
	self.shot_radius		= 100;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.stoneskin = 3;
	if (!self.colormap && !self.monster_marshalable) {
		//If we aren't a recruitment-post spawned monster
		//AND we don't have a colormap
		//Use this one
		self.colormap = (1024 + 4 + 4 * 16);
	}
	self.monster_demeanor = 4; //Don't ever attack those under same owner, unless attacked
	

	self.lodmodel1 = "models/monsters/armor_rigging-edits4_lod1.iqm";
	self.lodmodel2 = "models/monsters/armor_rigging-edits4_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

	
	RandomSelection_Init();
	RandomSelection_Add(world, WEP_LASER, string_null, autocvar_g_monster_soldier_weapon_laser_chance, 1);
	RandomSelection_Add(world, WEP_SHOTGUN, string_null, autocvar_g_monster_soldier_weapon_shotgun_chance, 1);
	RandomSelection_Add(world, WEP_CARBINE, string_null, autocvar_g_monster_soldier_weapon_machinegun_chance, 1);
	RandomSelection_Add(world, WEP_ROCKET_LAUNCHER, string_null, autocvar_g_monster_soldier_weapon_rocketlauncher_chance, 1);
	
	if (RandomSelection_chosen_float == WEP_ROCKET_LAUNCHER)
	{
		self.weapon = WEP_ROCKET_LAUNCHER;
		self.currentammo = self.ammo_rockets;
		self.armorvalue = 10;
		self.attack_ranged = soldier_missile_rl;
	}
	else if (RandomSelection_chosen_float == WEP_CARBINE)
	{
		self.weapon = WEP_CARBINE;
		self.currentammo = self.ammo_nails;
		self.armorvalue = 100;
		self.attack_ranged = soldier_missile_uzi;
	}
	else if (RandomSelection_chosen_float == WEP_SHOTGUN)
	{
		self.weapon = WEP_SHOTGUN;
		self.currentammo = self.ammo_shells;
		self.armorvalue = 25;
		self.attack_ranged = soldier_missile_shotgun;
	}
	else
	{
		self.weapon = WEP_LASER;
		self.armorvalue = 60;
		self.currentammo = self.ammo_none;
		self.attack_ranged = soldier_missile_laser;
	}

	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_soldier ()
{	
	if not(autocvar_g_monster_soldier)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_soldier;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	//self.scale = 1.3;
	//"models/monsters/soldier.mdl",
	
	if not (monster_initialize(
			 "Grunt",
			 "models/monsters/armor_rigging-edits4.iqm",
			 SOLDIER_MIN, SOLDIER_MAX,
			 FALSE,
			 soldier_die, soldier_spawn))
	{
		remove(self);
		return;
	}
	
	precache_sound ("weapons/shotgun_fire.wav");
	precache_sound ("weapons/uzi_fire.wav");
	precache_sound ("weapons/laser_fire.wav");
	precache_sound ("weapons/reload.wav");
}

void soldier_precacheforothers()
{
	if not(autocvar_g_monsters)
	{
		return;
	}
	if not(autocvar_g_monster_soldier)
	{
		return;
	}
	precache_model("models/monsters/armor_rigging-edits4.iqm");
	precache_model("models/monsters/armor_rigging-edits4_lod1.iqm");
	precache_model("models/monsters/armor_rigging-edits4_lod2.iqm");
	//This is for precacheing the model from multitool etc
	//Done here so if we change the model we'll remember to
	//Change it here too, rather than forgetting it is even
	//refrenced in w_multitool
}


// compatibility with old spawns
void spawnfunc_monster_army () { spawnfunc_monster_soldier(); }
