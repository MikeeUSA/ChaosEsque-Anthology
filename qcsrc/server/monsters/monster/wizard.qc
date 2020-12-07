// size
const vector WIZARD_MIN = '-16 -16 -24';
const vector WIZARD_MAX = '16 16 24';

// cvars
float autocvar_g_monster_wizard;
float autocvar_g_monster_wizard_health;
float autocvar_g_monster_wizard_speed_walk;
float autocvar_g_monster_wizard_speed_run;

// animations
#define wizard_anim_hover 	0
#define wizard_anim_fly 	1
#define wizard_anim_magic 	2
#define wizard_anim_pain 	3
#define wizard_anim_death 	4
#define wizard_anim_stone	6//5
#define wizard_anim_dead 	7

void Wiz_FastFire ()
{
	W_Plasma_TouchExplode();
}

void Wiz_FastTouch ()
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

void Wiz_StartFast ()
{
	local	entity	missile = world;
	local	vector	dir = '0 0 0';
	local	float	dist = 0, flytime = 0;

	dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	dist = vlen (self.enemy.origin - self.origin);
	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;
	
	self.v_angle = self.angles;
	makevectors (self.angles);

	missile = spawn ();
	missile.owner = missile.realowner = self;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward * 14 + '0 0 30' + v_right * 14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 3;
	missile.think = Wiz_FastFire;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.touch = Wiz_FastTouch;
	CSQCProjectile(missile, TRUE, PROJECTILE_CRYLINK, TRUE);
	
	missile = spawn ();
	missile.owner = missile.realowner = self;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward * 14 + '0 0 30' + v_right * -14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 3;
	missile.touch = Wiz_FastTouch;
	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.think = Wiz_FastFire;
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	CSQCProjectile(missile, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void wizard_death ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = wizard_anim_stone; else self.frame = wizard_anim_dead;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}


void wizard_think ()
{
	monster_hook_think();
	
	self.think = wizard_think;
	self.nextthink = time + 0.3;
	
	if (self.stoned || self.frozen) {
		self.frame = wizard_anim_stone;
	} else if (!self.ammount) {
		//So we're floating on something
		pointparticles(particleeffectnum("smoke_big"), self.origin+self.mins, '0 0 0', 1);
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
		}
		
		if (!self.ammount && !self.frozen) {
			//traceline (self.origin, self.origin + '0 0 -1' * 1000, TRUE, self);
			//print ("here\n");
			if (random() > 0.5) {
				self.velocity_x 	= 100*(random() - 0.5);
				self.velocity_y 	= 100*(random() - 0.5);
				self.velocity_z 	= 100*(random() - 0.5);
			} else {
				monster_move(monster_mvmntimpare_human(autocvar_g_monster_wizard_speed_run), monster_mvmntimpare_human(autocvar_g_monster_wizard_speed_walk), 300, wizard_anim_fly, wizard_anim_hover, wizard_anim_hover);
			}
			//self.velocity = self.velocity + '0 0 -1' * autocvar_sv_gravity;
		} else {
		monster_move(monster_mvmntimpare_human(autocvar_g_monster_wizard_speed_run), monster_mvmntimpare_human(autocvar_g_monster_wizard_speed_walk), 300, wizard_anim_fly, wizard_anim_hover, wizard_anim_hover);
		}
	}
}

void wizard_fastattack ()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
	
	if (CheckSpellNoCancel(self, 20, self.origin)) {
		Wiz_StartFast();
	}
}

void wizard_die ()
{
	if (self.model != "models/monsters/wizard.mdl") 
	{
		//For human only
		placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot
	}

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("wizard");
	
	self.think		  	= wizard_death;
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.flags		  	= FL_ONGROUND;
	self.nextthink	  	= time + 0.5;
	self.pain_finished  = self.nextthink; 
	self.velocity_x 	= -200 + 400*random();
	self.velocity_y 	= -200 + 400*random();
	self.velocity_z 	= 100 + 100*random();
	self.frame			= wizard_anim_death;
	
	monster_hook_death(); // for post-death mods
}

float Wiz_Missile ()
{
	wizard_fastattack();
	return TRUE;
}

void wizard_spawn ()
{
	if (self.health <= 0)
		self.health = autocvar_g_monster_wizard_health * self.scale;
	
	self.stoneskin = 1;
	self.sex = SEX_MALE;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	
	self.classname			= "monster_wizard";
	self.checkattack	 	= GenericCheckAttack;
	self.attack_ranged	  	= Wiz_Missile;
	self.nextthink		  	= time + random() * 0.5 + 0.1;
	self.movetype		   	= MOVETYPE_FLY; // TODO: make it fly up/down
	self.flags			   |= FL_FLY;
	self.think			  	= wizard_think;
	self.sprite_height	  	= 30 * self.scale;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void spawnfunc_monster_wizard ()
{	
	if not(autocvar_g_monster_wizard)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_wizard;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.resist_energy = 1;
	
	if not (monster_initialize(
			 "Scrag",
			 "models/monsters/mage.dpm",
			 WIZARD_MIN, WIZARD_MAX,
			 TRUE,
			 wizard_die, wizard_spawn))
	{
		remove(self);
		return;
	}
	
	precache_model ("models/spike.mdl");
	precache_sound ("weapons/spike.wav");
}

void spawnfunc_monster_wizardcreature ()
{	
	if not(autocvar_g_monster_wizard)
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_wizard;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.ammount = 1; //Here ammount is used to tell us what type of wizard we are, human or beast
	
	//self.scale = 1.3; models/monsters/wizard.mdl
	//self.scale = 1.3;
	
	if not (monster_initialize(
			 "Scrag",
			 "models/monsters/wizard.mdl",
			 WIZARD_MIN, WIZARD_MAX,
			 TRUE,
			 wizard_die, wizard_spawn))
	{
		remove(self);
		return;
	}
	
	precache_model ("models/spike.mdl");
	precache_sound ("weapons/spike.wav");
}

// compatibility with old spawns
void spawnfunc_monster_scrag () { spawnfunc_monster_wizard(); }
