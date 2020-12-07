// size
const vector KNIGHT_MIN = '-16 -16 -24';
const vector KNIGHT_MAX = '16 16 45';
//const vector KNIGHT_MAX = '16 16 32'; //Old

const vector KNIGHT_DEAD_MIN = '-18 -18 18';
const vector KNIGHT_DEAD_MAX = '18 18 30';


// cvars
float autocvar_g_monster_knight;
float autocvar_g_monster_knight_health;
float autocvar_g_monster_knight_melee_damage;
float autocvar_g_monster_knight_speed_walk;
float autocvar_g_monster_knight_speed_jog_rate;
float autocvar_g_monster_knight_speed_run;

// animations
#define knight_anim_stand 		0
#define knight_anim_run 		1
#define knight_anim_runattack 	2
#define knight_anim_pain1 		3
#define knight_anim_pain2 		4
#define knight_anim_attack 		5
#define knight_anim_walk 		6
#define knight_anim_kneel 		7
#define knight_anim_standing 	8
#define knight_anim_death1 		9
#define knight_anim_death2 		10
#define knight_anim_stone 		11
#define knight_anim_dead 		12

float knight_GenericCheckAttack ()
{
	// checking attack while dead?
	if (self.health <= 0 || self.enemy == world)
		return FALSE;
		
	if(self.monster_delayedattack && self.delay != -1)
	{
		if(time < self.delay)
			return FALSE;
			
		self.monster_delayedattack();
	}
	
	if (time < self.attack_finished_single)
		return FALSE;
	
	if (enemy_range() > 2000) // long traces are slow
		return FALSE;	
		
	if(self.attack_melee) {
		if(self.weaponentity.count == 2) {
			if(enemy_range() <= autocvar_g_balance_poleaxe_primary_melee_range * self.scale)
			{
				self.attack_melee(); // don't wait for nextthink - too slow
				return TRUE;
			}
		} else if(self.weaponentity.count == 1) {
			if(enemy_range() <= autocvar_g_balance_longsword_primary_melee_range * self.scale)
			{
				self.attack_melee(); // don't wait for nextthink - too slow
				return TRUE;
			}
		} else {
			if(enemy_range() <= 100 * self.scale)
			{
				self.attack_melee(); // don't wait for nextthink - too slow
				return TRUE;
			}
		}
	}
	
	// monster doesn't have a ranged attack function, so stop here
	if(!self.attack_ranged)
		return FALSE;

	// see if any entities are in the way of the shot
	if (!findtrajectorywithleading(self.origin, '0 0 0', '0 0 0', self.enemy, 800, 0, 2.5, 0, self))
		return FALSE;

	self.attack_ranged(); // don't wait for nextthink - too slow
	return TRUE;
}

void knight_dead ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = knight_anim_stone; else self.frame = knight_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void knight_think ()
{
	monster_hook_think();
	
	self.think = knight_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = knight_anim_stone;
	
	monster_move(monster_mvmntimpare_human(autocvar_g_monster_knight_speed_run), monster_mvmntimpare_human(autocvar_g_monster_knight_speed_walk), 50, knight_anim_run, knight_anim_walk, knight_anim_stand);

	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
}

void knight_attack_armed()
{
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	
	makevectors(self.angles);
	if (self.weaponentity.count == 1) {
		if (random() > 0.35) {
			self.longsword_secondary = 0;
			W_LongSwordspiked_Attack();
		} else {
			self.longsword_secondary = 1;
			W_LongSwordspiked_Attack();
			self.attack_finished_single = time + 0.5; //Default 0.9, but we're faster here
		}
	} else if (self.weaponentity.count == 2) {
		if (random() > 0.85) {
			//Stab
			self.poleaxe_secondary = 0;
			W_PoleAxespiked_Attack();
		} else {
			//Chop
			self.poleaxe_secondary = 1;
			W_PoleAxespiked_Attack();
		}
	}
}

void knight_attack ()
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
		
	local float len = vlen(self.velocity);

	if (self.stoned || self.frozen) self.frame = knight_anim_stone; else self.frame = ((len < 50) ? knight_anim_attack : knight_anim_runattack);
	
	self.attack_finished_single = time + 0.9;
	
	if (!self.stoned && !self.frozen) {
		if (self.weaponentity.count) {
			knight_attack_armed();
			if (random() > 0.8) {
				//A kick or punch too
				monster_melee(self.enemy, autocvar_g_monster_knight_melee_damage, 80, DEATH_MONSTER_MELEE);
			}
		} else {
			//Unarmed
			monster_melee(self.enemy, autocvar_g_monster_knight_melee_damage, 80, DEATH_MONSTER_MELEE);
		}
	}
}

void knight_die ()
{
	placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("knight");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.frame 			= (random() > 0.5) ? knight_anim_death1 : knight_anim_death2;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.think			= knight_dead;
	self.movetype 		= MOVETYPE_TOSS;
	self.nextthink	  	= time + 0.75;
	self.pain_finished  = self.nextthink;
	setsize (self, KNIGHT_DEAD_MIN, KNIGHT_DEAD_MAX);
	self.velocity_z 	= 10 + 10*random();
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
	
	
	//If we're allowed to drop a weapon we shall.
	//Since we have only medieval we're a medieval weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (autocvar_g_monsters_dropweapon_medieval) {
		if (autocvar_g_monsters_dropweapon_medieval >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_medieval > random())
		{
				monsterdropweapon = 1;
		}
	}
	if (monsterdropweapon && self.weaponentity.count) {
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weaponentity.count == 1) {
			W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_POLEAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_POLEAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	monster_hook_death(); // for post-death mods
}

void knight_spawn ()
{
	local float wrand;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_knight_health * self.scale;

	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.monster_jogspeedrate = autocvar_g_monster_knight_speed_jog_rate;
	
	self.damageforcescale   = 0.003;
	self.classname			= "monster_knight";
	self.checkattack	 	= knight_GenericCheckAttack;
	self.attack_melee		= knight_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= knight_think;
	self.sprite_height	  	= 30 * self.scale;
	self.frame 				= knight_anim_stand;
	
	self.stoneskin = 1;
	self.gibscale = 0.8;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.sex = SEX_MALE;
	self.monster_demeanor = 4; //Don't ever attack those under same owner, unless attacked
	
	//if (self.scale) self.view_ofs = '0 0 60' * self.scale;
	//else self.view_ofs = '0 0 60';
	
	self.armorvalue = g_pickup_armormedium;
	
	self.lodmodel1 = "models/monsters/Defender_lod1-edits.iqm";
	self.lodmodel2 = "models/monsters/Defender_lod2-edits.iqm";
	self.lodmodel3 = "models/monsters/Defender_lod3-edits.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;
	wrand = random();
	if (wrand > 0.1)
	{
		self.weaponentity.alpha = 1;
		
		wrand = random();
		self.weaponentity.alpha = 1;
		self.weaponentity.angles    = '65 110 90';
		self.weaponentity.origin    = '0 0 0';
		if (wrand > 0.75) {
			setmodel(self.weaponentity,  "models/weapons/v_poleaxe.md3");
			self.weaponentity.count = 2;
			self.weaponentity.angles    = '15 0 0';
			self.weaponentity.origin    = '0 1 0'; //Furthur into palm (away from wrist)
		} else {
			setmodel(self.weaponentity,  "models/weapons/v_longsword.md3");
			self.weaponentity.count = 1;
			self.weaponentity.origin    = '0 4 0'; //Furthur into palm (away from wrist)
		}
		
		//setattachment(self.weaponentity, self, "RightHand"); //Move origin
		//setattachment(self.weaponentity, self, "RightFingerBase"); //Rotate
		setattachment(self.weaponentity, self, "RThumb");
	
		//wrand = random();
		//if (wrand > 0.75)
		//{
		//	self.bomb1.alpha = 1;
		//	self.bomb1.count = self.weaponentity.count;
		//	self.bomb1.model = self.weaponentity.model;
		//	setmodel(self.bomb1,  self.bomb1.model);
		//	
		//	//self.bomb1.angles    = '45 110 0';
		//	
		//	setattachment(self.bomb1, self, "LeftHand");
		//}
	}
	
	self.deadflag = DEAD_NO;

	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_knight ()
{	
	if not(autocvar_g_monster_knight)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_knight;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	//self.scale = 1.3; //Old
	
	if not (monster_initialize(
			 "Knight",
			 "models/monsters/Defender-edits.iqm",
			 KNIGHT_MIN, KNIGHT_MAX,
			 FALSE,
			 knight_die, knight_spawn))
	{
		remove(self);
		return;
	}
	
	precache_model ("models/weapons/v_longsword.md3");
	precache_model ("models/weapons/v_poleaxe.md3");
}

void knight_precacheforothers()
{
	if not(autocvar_g_monsters)
	{
		return;
	}
	if not(autocvar_g_monster_knight)
	{
		return;
	}
	precache_model("models/monsters/Defender-edits.iqm");
	precache_model ("models/monsters/Defender_lod1-edits.iqm");
	precache_model ("models/monsters/Defender_lod2-edits.iqm");
	precache_model ("models/monsters/Defender_lod3-edits.iqm");
	//This is for precacheing the model from multitool etc
	//Done here so if we change the model we'll remember to
	//Change it here too, rather than forgetting it is even
	//refrenced in w_multitool
}
