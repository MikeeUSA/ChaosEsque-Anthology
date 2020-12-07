// size
const vector WYVERN_MIN = '-18 -18 -18';
const vector WYVERN_MAX = '18 18 18';

// cvars
float autocvar_g_monster_wyvern;
float autocvar_g_monster_wyvern_range;
float autocvar_g_monster_wyvern_health;
float autocvar_g_monster_wyvern_speed_walk;
float autocvar_g_monster_wyvern_speed_run;
float autocvar_g_monster_wyvern_amnt;
float autocvar_g_monster_wyvern_fire_amnt;
float autocvar_g_monster_wyvern_water_amnt;
float autocvar_g_monster_wyvern_air_amnt;


// animations
#define wyvern_anim_hover 	0
#define wyvern_anim_fly 	1
#define wyvern_anim_magic 	2
#define wyvern_anim_pain 	3
#define wyvern_anim_death 	12
#define wyvern_anim_stone	6//5
#define wyvern_anim_dead 	11
#define wyvern_anim_ram 	5
#define wyvern_anim_grab 	9
#define wyvern_anim_spotaction 	8
#define wyvern_anim_flyfast 	10

float Wyvern_GenericCheckAttack ()
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
	
	if (enemy_range() > autocvar_g_monster_wyvern_range) // long traces are slow
		return FALSE;	
		
	if(self.attack_melee)
	if(enemy_range() <= 100 * self.scale)
	{
		self.attack_melee(); // don't wait for nextthink - too slow
		return TRUE;
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

void Wyvern_FastFire ()
{
	W_Plasma_TouchExplode();
}

void Wyvern_FastTouch ()
{		
	if(other == self.owner)
		return;
		
	if(teamplay)
	if(other.team == self.owner.team)
		return;
		
	pointparticles(particleeffectnum("TE_WIZSPIKE"), self.origin, '0 0 0', 1);
	
	self.projectiledeathtype = WEP_CRYLINK;
	W_Plasma_TouchExplode();
}

void Wyvern_StartFast ()
{
	vector angles_face;
				
	// face the enemy	
	angles_face = vectoangles(self.enemy.origin - self.origin);
	//self.angles_y = angles_face_y ;
	self.angles = angles_face; //Fully
	
	//print("here\n");
				
	//Magic Attack
	if (self.havocbot_nextmagicthink < time) {
		self.nextspell = 0;
		self.mana = 90000; //Always, we have enough
		if (self.ammount >= 100) {
			self.havocbot_nextmagicthink =  time+0.3;
		} else {
			self.havocbot_nextmagicthink =  time+0.5;
		}
		self.v_angle = self.angles;
		makevectors(self.v_angle);
		havocbot_castmagic();
	}
					
}

void wyvern_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = wyvern_anim_stone; else self.frame = wyvern_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}


void wyvern_think ()
{
	monster_hook_think();
	
	self.think = wyvern_think;
	self.nextthink = time + 0.3;
	
	if (self.stoned || self.frozen) {
		self.frame = wyvern_anim_stone;
	} else if (!self.ammount) {
		//So we're floating on something
		//pointparticles(particleeffectnum("smoke_big"), self.origin+self.mins, '0 0 0', 1);
	}
	
	if (self.stoned) {
		if (self.movetype != MOVETYPE_TOSS) {
			self.movetype = MOVETYPE_TOSS;
			self.flags		  	= FL_ONGROUND;
			//print ("here\n");
			//self.velocity_x 	= -200 + 400*random();
			//self.velocity_y 	= -200 + 400*random();
			//self.velocity_z 	= 100 + 100*random();
			self.velocity_z 	= 100 + 100*random();
			//self.velocity = self.velocity + '0 0 -1' * autocvar_sv_gravity;
		}
	} else {
		if (self.movetype == MOVETYPE_TOSS) {
			self.movetype		   	= MOVETYPE_FLY; // TODO: make it fly up/down
			self.flags			   |= FL_FLY;
		} else if (!self.frozen) {
				local float enemyDistance;
				
				if (self.enemy) {
					if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
						self.enemy = world;
	
					if (self.enemy)
					if (self.enemy.team == self.team || self.monster_owner == self.enemy)
						self.enemy = world;
				}
				
				if (self.enemy) {
					enemyDistance = vlen(self.origin - self.enemy.origin);
					if (enemyDistance <= 128) 
					{
						//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
						imp_attack_standing();
						//print("sTANDING ATTK\n");
					} 
					else if (enemyDistance <= 256) 
					{
						// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
						imp_attack_leap();
						//print("Leap ATTK\n");
					}
					
					if (random() > 0.5) {
						self.velocity_z = self.velocity_z + (100*random());
					} else {
						monster_move(autocvar_g_monster_wyvern_speed_run, autocvar_g_monster_wyvern_speed_walk, 300, wyvern_anim_flyfast, wyvern_anim_fly, wyvern_anim_hover);
					}
				} else {
					monster_move(autocvar_g_monster_wyvern_speed_run, autocvar_g_monster_wyvern_speed_walk, 300, wyvern_anim_flyfast, wyvern_anim_fly, wyvern_anim_hover);
				}
		}
	}
}

void wyvern_fastattack ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	Wyvern_StartFast();
}

void wyvern_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("wyvern");
	
	self.think		  	= wyvern_death;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.flags		  	= FL_ONGROUND;
	self.nextthink	  	= time + 0.5;
	self.angles_z = 55 + (35 * random());
	self.pain_finished  = self.nextthink; 
	self.velocity_x 	= -200 + 400*random();
	self.velocity_y 	= -200 + 400*random();
	self.velocity_z 	= 100 + 100*random();
	self.frame			= wyvern_anim_death;
	
	monster_hook_death(); // for post-death mods
}

float Wyvern_Missile ()
{
	wyvern_fastattack();
	return TRUE;
}

float wyvernselectrandtype ()
{
	float mynum;
	float srandvar;	
	
		srandvar = random() *
		(autocvar_g_monster_wyvern_amnt
		+ autocvar_g_monster_wyvern_fire_amnt
		+ autocvar_g_monster_wyvern_water_amnt
		+ autocvar_g_monster_wyvern_air_amnt);

		if (srandvar < autocvar_g_monster_wyvern_amnt) {
			mynum = 10;
		} else if (srandvar < (
		autocvar_g_monster_wyvern_amnt
		+ autocvar_g_monster_wyvern_fire_amnt
		)) {
			mynum = 20;
		} else if (srandvar < (
		autocvar_g_monster_wyvern_amnt
		+ autocvar_g_monster_wyvern_fire_amnt
		+ autocvar_g_monster_wyvern_water_amnt
		)) {
			mynum = 30;
		} else if (srandvar < (
		autocvar_g_monster_wyvern_amnt
		+ autocvar_g_monster_wyvern_fire_amnt
		+ autocvar_g_monster_wyvern_water_amnt
		+ autocvar_g_monster_wyvern_air_amnt
		)) {
			mynum = 40;
		} else {
			mynum = 10;
		}
		
	if (random() > 0.75)
		mynum = mynum * 10;
		
	
	return mynum;
}

void wyvern_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_wyvern_health;
	
	self.stoneskin = 3;
	self.gibscale = 2;

	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_hasheightenedsenseofsmell = 1.5;
	
	self.classname			= "monster_wyvern";
	self.checkattack	 	= Wyvern_GenericCheckAttack;
	self.attack_ranged	  	= Wyvern_Missile;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.movetype		   	= MOVETYPE_FLY; // TODO: make it fly up/down
	self.flags			   |= FL_FLY;
	self.think			  	= wyvern_think;
	self.sprite_height	  	= 30 * self.scale;
	
	self.species = SPECIES_ANIMAL;
	
	self.resist_acid = 0.8;   //Slime
	self.resist_blunt = 0.8;  //Warhammer, beatdown, melee
	self.resist_bullet = 0.8;
	self.resist_crush = 0.8;  //Vehicle crush
	self.resist_edged = 0.8;  //Axe, Sword, Claw
	self.resist_electricity = 0.8; //Lightning gun, Tesla arc, 
	self.resist_energy = 0.8; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	self.resist_explode = 0.8;//Rockets etc
	self.resist_fall = 0.98;   //Shooting star, fall etc //(lots as we're fast, don't want to break due to a dive)
	self.resist_fire = 0.8;   //Fire, Lava
	self.resist_laser = 0.8;  //Laser
	//self.resist_nuke = 0;  //Nuclear explosion
	self.resist_pierce = 0.8; //Crossbow, Bite
	self.resist_sound = 0.8; //Tuba
	self.resist_ice = 0.8; //Freeze damage resistance
	self.resist_rotor = 0.8; //Heli rotor blades do little
	
	self.buff_cancellation_immune = 1; //Natural abilities can't be cancelled
	
	if (self.ammount != 1) {
		self.loddistance1 = 8192;
		self.loddistance2 = 16384;
		self.lodmodel1 = "models/monsters/wyvern-edits_lod1.iqm";
		self.lodmodel2 = "models/monsters/wyvern-edits_lod2.iqm";
		InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	}
	
	if (!self.ammount) {
		self.ammount = wyvernselectrandtype();
	}
	
	if (self.ammount == 10) {
		//Green, earth dragon
		self.skin = 0;
		self.scale = 1;
		self.resist_crush = 0.98;
		self.resist_rotor = 0.98;
		self.resist_blunt = 0.98;
		self.resist_bullet = 0.98;
	} else if (self.ammount == 100) {
		//Green, earth dragon
		self.skin = 0;
		self.scale = 4;
		self.resist_crush = 0.98;
		self.resist_rotor = 0.98;
		self.resist_blunt = 0.98;
		self.resist_bullet = 0.98;
		self.health = self.health * 5;
	} else if (self.ammount == 20) {
		//Red, fire dragon
		self.skin = 2;
		self.scale = 1;
		self.resist_fire = 1;
		self.resist_bullet = 0.9;
		self.spell_firebeam = 40;
	} else if (self.ammount == 200) {
		//Red, fire dragon
		self.skin = 2;
		self.scale = 4;
		self.resist_fire = 1;
		self.resist_bullet = 0.9;
		self.spell_firebeam = 200;
		self.health = self.health * 5;
	} else if (self.ammount == 30) {
		//Blue, water dragon
		self.skin = 4;
		self.scale = 1;
		self.resist_ice = 1;
		self.spell_frostbeam = 40;
	} else if (self.ammount == 300) {
		//Blue, water dragon
		self.skin = 4;
		self.scale = 4;
		self.resist_ice = 1;
		self.spell_frostbeam = 200;
		self.health = self.health * 5;
	} else if (self.ammount == 40) {
		//Air dragon
		self.skin = 1;
		self.scale = 1;
		self.resist_electricity = 1;
		self.resist_explode = 0.5; //Lessened
		self.resist_bullet = 0.7;
		self.resist_pierce = 0.7;
		self.spell_lightining = 40;
	} else if (self.ammount == 400) {
		//Air dragon
		self.skin = 1;
		self.scale = 4;
		self.resist_electricity = 1;
		self.resist_explode = 0.5; //Lessened
		self.resist_bullet = 0.7;
		self.resist_pierce = 0.7;
		self.spell_lightining = 100;
		self.health = self.health * 5;
	}
	
	setsize (self, WYVERN_MIN * self.scale, WYVERN_MAX * self.scale);
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_wyvern ()
{	
	if not(autocvar_g_monster_wyvern)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_wyvern;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.resist_energy = 1;
	
	if not (monster_initialize(
			 "Wyvern",
			 "models/monsters/wyvern-edits.iqm",
			 WYVERN_MIN, WYVERN_MAX,
			 TRUE,
			 wyvern_die, wyvern_spawn))
	{
		remove(self);
		return;
	}
	
	precache_sound ("weapons/fireball_fire2.wav");
}

void spawnfunc_monster_wyvern_earth ()
{
	self.ammount = 10;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_dragon_earth ()
{
	self.ammount = 100;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_wyvern_fire ()
{
	self.ammount = 20;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_dragon_fire ()
{
	self.ammount = 200;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_wyvern_water ()
{
	self.ammount = 30;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_dragon_water ()
{
	self.ammount = 300;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_wyvern_air ()
{
	self.ammount = 40;
	spawnfunc_monster_wyvern();
}
void spawnfunc_monster_dragon_air ()
{
	self.ammount = 400;
	spawnfunc_monster_wyvern();
}


void spawnfunc_monster_wyverncreature ()
{	
	if not(autocvar_g_monster_wyvern)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_wyvern;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.ammount = 1; //Here ammount is used to tell us what type of wyvern we are, human or beast
	
	//self.scale = 1.3; models/monsters/wyvern.mdl
	//self.scale = 1.3;
	
	if not (monster_initialize(
			 "Scrag",
			 "models/monsters/wyvern.mdl",
			 WYVERN_MIN, WYVERN_MAX,
			 TRUE,
			 wyvern_die, wyvern_spawn))
	{
		remove(self);
		return;
	}
	
	precache_model ("models/spike.mdl");
	precache_sound ("weapons/spike.wav");
}

