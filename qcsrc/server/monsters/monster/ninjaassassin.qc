// size
const vector NINJAASSASSIN_MIN = '-10 -10 -24';
const vector NINJAASSASSIN_MAX = '10 10 40';
//const vector NINJAASSASSIN_MAX = '16 16 32'; //Old

const vector NINJAASSASSIN_DEAD_MIN = '-18 -18 -24';
const vector NINJAASSASSIN_DEAD_MAX = '18 18 8';


// cvars
float autocvar_g_monster_ninjaassassin;
float autocvar_g_monster_ninjaassassin_health;
float autocvar_g_monster_ninjaassassin_melee_damage;
float autocvar_g_monster_ninjaassassin_speed_walk;
float autocvar_g_monster_ninjaassassin_speed_jog_rate;
float autocvar_g_monster_ninjaassassin_speed_run;

// animations
#define ninjaassassin_anim_stand 		7
#define ninjaassassin_anim_run 		13
#define ninjaassassin_anim_runattack 	8
#define ninjaassassin_anim_pain1 		3
#define ninjaassassin_anim_pain2 		3
#define ninjaassassin_anim_attack 		23
#define ninjaassassin_anim_walk 		13
#define ninjaassassin_anim_kneel 		6
#define ninjaassassin_anim_standing 	7
#define ninjaassassin_anim_death1 		0
#define ninjaassassin_anim_death2 		1
#define ninjaassassin_anim_stone 		31
#define ninjaassassin_anim_dead 		17

float ninjaassassin_GenericCheckAttack ()
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
			if(enemy_range() <= autocvar_g_balance_nagamaki_primary_melee_range * self.scale)
			{
				self.attack_melee(); // don't wait for nextthink - too slow
				return TRUE;
			}
		} else if(self.weaponentity.count == 1) {
			if(enemy_range() <= autocvar_g_balance_katana_primary_melee_range * self.scale)
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

void ninjaassassin_dead ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = ninjaassassin_anim_stone; else self.frame = ninjaassassin_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void ninjaassassin_think ()
{
	monster_hook_think();
	
	self.think = ninjaassassin_think;
	self.nextthink = time + 0.3 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.stoned || self.frozen)
		self.frame = ninjaassassin_anim_stone;
	
	monster_move(monster_mvmntimpare_human(autocvar_g_monster_ninjaassassin_speed_run), monster_mvmntimpare_human(autocvar_g_monster_ninjaassassin_speed_walk), 50, ninjaassassin_anim_run, ninjaassassin_anim_walk, ninjaassassin_anim_stand);

	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
		
	if (!self.enemy || self.enemy == world) {
		//No flying
		movelib_jump_simple(-32);
	}
}

void ninjaassassin_attack_armed()
{
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	
	makevectors(self.angles);
	if (self.weaponentity.count == 1) {
		if (random() > 0.35) {
			self.katana_secondary = 0;
			W_Katanaspiked_Attack();
			self.attack_finished_single = time + (autocvar_g_balance_katana_primary_refire * 0.8);
		} else {
			self.katana_secondary = 1;
			W_Katanaspiked_Attack();
			self.attack_finished_single = time + (autocvar_g_balance_katana_secondary_refire * 0.8);
		}
	} else if (self.weaponentity.count == 2) {
		if (random() > 0.85) {
			//Stab
			self.nagamaki_secondary = 0;
			W_Nagamakispiked_Attack();
			self.attack_finished_single = time + (autocvar_g_balance_nagamaki_primary_refire * 0.9);
		} else {
			//Chop
			self.nagamaki_secondary = 1;
			W_Nagamakispiked_Attack();
			self.attack_finished_single = time + (autocvar_g_balance_nagamaki_secondary_refire * 0.9);
		}
	}
}

void ninjaassassin_attack ()
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

	if (self.stoned || self.frozen) self.frame = ninjaassassin_anim_stone; else self.frame = ((len < 50) ? ninjaassassin_anim_attack : ninjaassassin_anim_runattack);
	
	self.attack_finished_single = time + 0.75;
	
	if (!self.stoned && !self.frozen) {
		if (self.weaponentity.count) {
			ninjaassassin_attack_armed();
			if (random() > 0.8) {
				//A kick or punch too
				monster_melee(self.enemy, autocvar_g_monster_ninjaassassin_melee_damage, 80, DEATH_MONSTER_MELEE);
			}
		} else {
			//Unarmed
			monster_melee(self.enemy, autocvar_g_monster_ninjaassassin_melee_damage, 80, DEATH_MONSTER_MELEE);
		}
	}
}

void ninjaassassin_die ()
{
	placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("ninjaassassin");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.frame 			= (random() > 0.5) ? ninjaassassin_anim_death1 : ninjaassassin_anim_death2;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.think			= ninjaassassin_dead;
	self.movetype 		= MOVETYPE_TOSS;
	self.nextthink	  	= time + 0.75;
	self.pain_finished  = self.nextthink;
	setsize (self, NINJAASSASSIN_DEAD_MIN, NINJAASSASSIN_DEAD_MAX);
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
			W_ThrowNewWeapon(self, WEP_KATANA, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_KATANA, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_NAGAMAKI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_NAGAMAKI, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	monster_hook_death(); // for post-death mods
}

void ninjaassassin_spawn ()
{
	local float wrand;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_ninjaassassin_health * self.scale;

	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.monster_jogspeedrate = autocvar_g_monster_ninjaassassin_speed_jog_rate;
	
	self.damageforcescale   = 0.003;
	self.classname			= "monster_ninjaassassin";
	self.checkattack	 	= ninjaassassin_GenericCheckAttack;
	self.attack_melee		= ninjaassassin_attack;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.think			  	= ninjaassassin_think;
	self.sprite_height	  	= 30 * self.scale;
	self.frame 				= ninjaassassin_anim_stand;
	
	self.stoneskin = 1;
	self.gibscale = 0.8;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.effects |= EF_DOUBLESIDED;
	
	self.sex = SEX_MALE;
	self.monster_demeanor = 4; //Don't ever attack those under same owner, unless attacked
	
	//if (self.scale) self.view_ofs = '0 0 60' * self.scale;
	//else self.view_ofs = '0 0 60';
	
	self.armorvalue = 8;
	
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
		//wrand = 0; //Force katana for now
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '65 110 90';
		//self.weaponentity.angles    = '85 0 45';
		//self.weaponentity.angles    = '85 45 45';
		//self.weaponentity.angles    = '85 45 0';
		self.weaponentity.origin    = '0 0 0';
		if (wrand > 0.75) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,   "models/weapons/v_nagamaki.md3");
			self.weaponentity.count = 2;
			self.weaponentity.origin    = '0 1 0'; //Furthur into palm (away from wrist)
		} else {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,   "models/weapons/v_katana.md3");
			self.weaponentity.count = 1;
			self.weaponentity.origin    = '0 4 0'; //Furthur into palm (away from wrist)
		}
		
		//setattachment(self.weaponentity, self, "RightHand"); //Move origin
		//setattachment(self.weaponentity, self, "RightFingerBase"); //Rotate
		//setattachment(self.weaponentity, self, "RThumb");
		
		setattachment(self.weaponentity, self, "bip01 r hand");
		setorigin(self.weaponentity, '2.1 6 -1');    // Move attch spot up 8// forward 4// yes fscked up bone  

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

void spawnfunc_monster_ninjaassassin ()
{	
	if not(autocvar_g_monster_ninjaassassin)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_ninjaassassin;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if (self.scale < 1.1) {
		self.scale = 1.1; //Old
	}
	
	if not (monster_initialize(
			 "Ninja Assassin",
			 "models/monsters/ninjaassassin.iqm",
			 NINJAASSASSIN_MIN, NINJAASSASSIN_MAX,
			 FALSE,
			 ninjaassassin_die, ninjaassassin_spawn))
	{
		remove(self);
		return;
	}
	
	ninjaassassin_precache_weapons();
}

void ninjaassassin_precache_weapons()
{
	precache_model ("models/weapons/v_katana.md3");
	precache_model ("models/weapons/v_nagamaki.md3");
}

void ninjaassassin_precacheforothers()
{
	if not(autocvar_g_monsters)
	{
		return;
	}
	if not(autocvar_g_monster_ninjaassassin)
	{
		return;
	}
	precache_model("models/monsters/ninjaassassin.iqm");
	//This is for precacheing the model from multitool etc
	//Done here so if we change the model we'll remember to
	//Change it here too, rather than forgetting it is even
	//refrenced in w_multitool
}
