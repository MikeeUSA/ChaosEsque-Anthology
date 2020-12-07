// size
const vector OGRE_MIN = '-32 -32 -24';
const vector OGRE_MAX = '32 32 32';
 
// cvars
float autocvar_g_monster_ogre;
float autocvar_g_monster_ogre_nexuiz;
float autocvar_g_monster_ogre_health;
float autocvar_g_monster_ogre_chainsaw_damage;
float autocvar_g_monster_ogre_speed_walk;
float autocvar_g_monster_ogre_speed_run;
float autocvar_g_monster_ogre_attack_uzi_bullets;

//Throw rock and use club perhaps

void chainsaw (float side)
{
	if (!self.enemy)
		return;

	if (vlen(self.enemy.origin - self.origin) > 100 * self.scale)
		return;

	Damage(self.enemy, self, self, autocvar_g_monster_ogre_chainsaw_damage * monster_skill, DEATH_MONSTER_OGRE_CHAINSAW, self.enemy.origin, normalize(self.enemy.origin - self.origin));
}

void ogre_think ()
{
	monster_hook_think();
	
	self.think = ogre_think;
	self.nextthink = time + 0.1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd;
	
	if(self.delay != -1)
		self.nextthink = self.delay;
	
	if (self.stoned || self.frozen)
		self.frame = self.anim_taunt_x;
	
	monster_move(monster_mvmntimpare_beast(autocvar_g_monster_ogre_speed_run), monster_mvmntimpare_beast(autocvar_g_monster_ogre_speed_walk), 300, self.anim_run_x, self.anim_forwardright_x, self.anim_idle_x);

	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
}


float ogre_attack_armed()
{
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	makevectors(self.angles);
	W_Cudgelspiked_Attack();
	return autocvar_g_balance_cudgel_primary_refire;
}

.float ogre_cycles;
void ogre_swing ()
{
	self.ogre_cycles += 1;
	if (self.stoned || self.frozen) self.frame = self.anim_taunt_x; else self.frame = self.anim_melee_x;
	
	if (self.ammount == 1) {
		local float myrefire;
		if (self.stoned || self.frozen) {
			self.nextthink = time + 0.2;
			self.think = ogre_think;
		} else {
			BITXOR_ASSIGN(self.effects, EF_RESTARTANIM_BIT); //Force anim reset
			if (random() > 0.15) 
				self.think = ogre_think;
			else
				self.think = ogre_swing;
				
			myrefire = ogre_attack_armed();
			myrefire = myrefire * 0.7; //Ogres are stronger than normal humans
			
			if (self.bomb1.count) //2 weapons, Faster
				self.nextthink = time + (myrefire * 0.4);
			else
				self.nextthink = time + myrefire;
		}
	} else {
		if(self.ogre_cycles == 1)
			self.attack_finished_single = time + 1.3 + (random()*0.25);
		self.angles_y = self.angles_y + random()* 25;
		self.nextthink = time + 0.2;
		self.think = ogre_swing;
		
		if(self.ogre_cycles <= 2)
			chainsaw(200);
		else if(self.ogre_cycles <= 4)
			chainsaw(-200);
		else
			chainsaw(0);
	
		if(self.ogre_cycles >= 4)
			self.think = ogre_think;
	}
}


void ogre_uzi_fire ()
{
	self.ogre_cycles += 1;
	
	if(self.ogre_cycles > autocvar_g_monster_ogre_attack_uzi_bullets)
	{
		self.monster_delayedattack = func_null;
		self.delay = -1;
		return;
	}
	W_UZI_Attack(DEATH_MONSTER_OGRE_NAIL);
	self.delay = time + 0.1;
	self.monster_delayedattack = ogre_uzi_fire;
}

void ogre_uzi ()
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
	
	if (self.stoned || self.frozen) self.frame = self.anim_taunt_x; else self.frame = self.anim_pain1_x;
	self.attack_finished_single = time + 0.8;
	self.delay = time + 0.1;
	self.monster_delayedattack = ogre_uzi_fire;
}

void ogre_gl ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	if (self.stat_bangflash > 99)
		return;
		
	if (self.stat_nukeflash > 99)
		return;	
	
	if (self.ammount == 1)
		W_Grenade_AttackBR();
	else
		W_Grenade_AttackB();
	
	if (self.stoned || self.frozen) self.frame = self.anim_taunt_x; else self.frame = self.anim_pain1_x;
	self.attack_finished_single = time + 0.8;
}

float ogre_missile ()
{	
	self.ogre_cycles = 0;
	if (self.ammount != 1 && (random() < 0.20))
	{
		//Medeval Orge doesn't do this
		ogre_uzi();
		return TRUE;
	}
	else
	{
		ogre_gl();
		return TRUE;
	}
}

void ogre_melee ()
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
		
	self.ogre_cycles = 0;
	ogre_swing();
}

void ogre_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = self.anim_taunt_x; else self.frame = self.anim_die2_x;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void ogre_die()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("ogre");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.nextthink	  	= time + 0.5;
	self.movetype		= MOVETYPE_TOSS;
	//We set think below to load the deadbody "animation", then fade
	self.think 			= ogre_death;
	self.frame			= self.anim_die1_x;
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
		
	//If we're allowed to drop a weapon we shall.
	//Since we have only medieval we're a medieval weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (self.ammount == 1 && self.weapon == WEP_CUDGEL) {
	  //Using Cudgel
	  //Making sure with the 2 statements
	  if (autocvar_g_monsters_dropweapon_medieval) {
		if (autocvar_g_monsters_dropweapon_medieval >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_medieval > random())
		{
				monsterdropweapon = 1;
		}
	  }
	} else if (self.ammount != 1 && self.weapon == WEP_GRENADE_LAUNCHER) {
	  //Grenade Launcher Type monster
	  //Making sure with the 2 statements
	  if (autocvar_g_monsters_dropweapon_futurehvy) {
		if (autocvar_g_monsters_dropweapon_futurehvy >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_futurehvy > random())
		{
				monsterdropweapon = 1;
		}
	  }
	}
	if (monsterdropweapon && self.weaponentity.count) {
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weapon == WEP_CUDGEL) {
			W_ThrowNewWeapon(self, WEP_CUDGEL, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CUDGEL, 0, self.origin, randomvec() * 225 + self.velocity);
		
		} else if (self.weapon == WEP_GRENADE_LAUNCHER) {
			W_ThrowNewWeapon(self, WEP_GRENADE_LAUNCHER, 0, self.origin, self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_GRENADE_LAUNCHER, 0, self.origin, randomvec() * 225 + self.velocity);
		
		}
	}
		
	monster_hook_death(); // for post-death mods
}

void ogre_spawn ()
{
	if not(self.health)
		self.health = autocvar_g_monster_ogre_health * self.scale;
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.125);
	self.monster_hasheightenedsenseofsmell = 0.5;
	
	self.stoneskin = 1;

	self.damageforcescale   = 0.003;
	self.classname			= "monster_ogre";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_melee		= ogre_melee;
	self.frame				= self.anim_idle_x;
	self.attack_ranged	 	= ogre_missile;
	self.nextthink		  	= time + 0.1;
	self.think			  	= ogre_think;
	self.sprite_height	  	= 40;
	self.weapon				= WEP_GRENADE_LAUNCHER;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	if (self.ammount == 1) {
		self.weapon = WEP_CUDGEL;
		
		local float wrand;
		//if (self.scale) self.view_ofs = '0 0 55' * self.scale;
		//else self.view_ofs = '0 0 55';
	
		self.weaponentity = spawn();
		self.bomb1 = spawn();
		self.bomb2 = spawn();
		setmodel(self.weaponentity,  "null");
		setmodel(self.bomb1,  "null");
		setmodel(self.bomb2,  "null");
		self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;
		
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '65 -30 0';
		
		setmodel(self.weaponentity,  "models/weapons/v_cudgel.md3");
		self.weaponentity.count = 1;
		
		setattachment(self.weaponentity, self, "bip01 r hand");

		wrand = random();
		if (wrand > 0.95)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			setmodel(self.bomb1,  self.bomb1.model);
			
			//if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			//	self.bomb1.angles    = '0 110 0';
			//else
			//	self.bomb1.angles    = '45 110 0';
			
			setattachment(self.bomb1, self, "hand_L");
		}
		
		
	}
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}
//"models/monsters/ogre.dpm",
void spawnfunc_monster_ogre ()
{	
	if not(autocvar_g_monster_ogre) { remove(self); return; }
	
	self.monster_spawnfunc = spawnfunc_monster_ogre;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.scale = 1.3;
		self.ammount = 1; //Works with medeval look
	
		if (autocvar_g_monster_ogre_nexuiz) {
			if (autocvar_g_monster_ogre_nexuiz >= 1) {
				self.ammount = -1; //Older Ogre Style
			} else if (autocvar_g_monster_ogre_nexuiz > random())
			{
				self.ammount = -1; //Older Ogre Style
			}
		}
		
		if (self.ammount == 1) {
			self.scale = self.scale + (random()*0.7);
		}

	}
	
	if (self.ammount == 1) {
		if not (monster_initialize(
			 "Ogre",
			 "models/monsters/ogre_edits3.iqm",
			 OGRE_MIN, OGRE_MAX,
			 FALSE,
			 ogre_die, ogre_spawn))
		{
		remove(self);
		return;
		}
		precache_sound ("resource/impact/slingimpstone_21.ogg");
		precache_sound ("resource/impact/slingimpstone_22.ogg");
		precache_sound ("resource/impact/slingimpstone_23.ogg");
		precache_sound ("resource/impact/slingimpstone_24.ogg");
		precache_sound ("resource/impact/slingimpstone_25.ogg");
		precache_sound ("resource/impact/slingimpstone_26.ogg");
		precache_sound ("resource/gathering/gather_field_11.ogg");
		
		//Abusing these vars so we can use diff models with diff anims
		// animations new
		self.anim_idle_x = 7; //#define ogre_anim_idle 		7
		self.anim_forwardright_x = 19; // #define ogre_anim_walk 		19
		self.anim_run_x = 13; // #define ogre_anim_run 		13
		self.anim_pain1_x = 9; // #define ogre_anim_pain 		9
		self.anim_melee_x = 23; // #define ogre_anim_swing 	23
		self.anim_die1_x = 0; // #define ogre_anim_die 		0
		self.anim_die2_x = 17; // #define ogre_anim_dead 		17
		self.anim_taunt_x = 31; // #define ogre_anim_stone 	31
	} else {
		if not (monster_initialize(
			 "Ogre",
			 "models/monsters/ogre.dpm",
			 OGRE_MIN, OGRE_MAX,
			 FALSE,
			 ogre_die, ogre_spawn))
		{
		remove(self);
		return;
		}
		
		// animations old
		self.anim_idle_x = 0; //#define ogre_anim_idle 		0
		self.anim_forwardright_x = 1; //#define ogre_anim_walk 		1
		self.anim_run_x = 2; //#define ogre_anim_run 		2
		self.anim_pain1_x = 3; //#define ogre_anim_pain 		3
		self.anim_melee_x = 4; //#define ogre_anim_swing 	4
		self.anim_die1_x = 5; //#define ogre_anim_die 		5
		self.anim_die2_x = 6; //#define ogre_anim_dead 		6
		self.anim_taunt_x = 7; //#define ogre_anim_stone 	7
	}
	
	weapon_action(WEP_GRENADE_LAUNCHER, WR_PRECACHE);
}
