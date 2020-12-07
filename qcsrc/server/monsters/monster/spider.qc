// cvars
float autocvar_g_monster_spider;
float autocvar_g_monster_spider_stopspeed;
float autocvar_g_monster_spider_attack_leap_delay;
float autocvar_g_monster_spider_attack_leap_range;
float autocvar_g_monster_spider_attack_stand_damage;
float autocvar_g_monster_spider_attack_stand_delay;
float autocvar_g_monster_spider_attack_stand_range;
float autocvar_g_monster_spider_health;
float autocvar_g_monster_spider_idle_timer_min;
float autocvar_g_monster_spider_speed_walk;
float autocvar_g_monster_spider_speed_run;
float autocvar_g_monster_spider_target_recheck_delay;
float autocvar_g_monster_spider_target_range;
float autocvar_g_monster_spider_attack_type;

// spider animations
#define spider_anim_idle		 	0
#define spider_anim_walk		 	1
#define spider_anim_attack		 	2
#define spider_anim_attack2			3
#define spider_anim_stone			4

const vector SPIDER_MIN				 = '-18 -18 -25';
const vector SPIDER_MAX				 = '18 18 30';

.float spider_type; // used to switch between fire & ice attacks
const float SPIDER_TYPE_ICE		= 0;
const float SPIDER_TYPE_FIRE	= 1;

void spider_spawn();
void spawnfunc_monster_spider();
void spider_think();

void spider_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("spider");
	
	self.angles += '180 0 0';
	self.solid		  	= SOLID_NOT;
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	self.pain_finished  = self.nextthink;
	self.frame			= spider_anim_attack;
	
	monster_hook_death(); // for post-death mods
}

/**
 * Performe a standing attack on self.enemy.
 */
void spider_attack_standing() {
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float dot = 0, bigdmg = autocvar_g_monster_spider_attack_stand_damage * self.scale;

	self.velocity_x = 0;
	self.velocity_y = 0;
	
	if(self.monster_owner == self.enemy)
	{
		self.enemy = world;
		return;
	}

	makevectors (self.angles);
	dot = normalize (self.enemy.origin - self.origin) * v_forward;
	if(dot > 0.3)
	{
		Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
		
	if(random() < 0.50)
		if (self.stoned || self.frozen) self.frame = spider_anim_stone; else self.frame = spider_anim_attack;
	else
		if (self.stoned || self.frozen) self.frame = spider_anim_stone; else self.frame = spider_anim_attack2;

	self.nextthink = time + autocvar_g_monster_spider_attack_stand_delay;
}

void spider_web_explode ()
{
	RadiusDamage (self, self.realowner, 0, 0, 1, world, 0, self.projectiledeathtype, other);
	remove (self);
}

void freezetag_Freeze(entity attacker);
void spider_web_touch ()
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM) {
		//print("freeze2\n");
		entity oldself;
		oldself = self;
		self = other;
		Freeze(other, 0.3, 1); //(Target, Time, Type(0 = ice, 1 = para)
		self = oldself;
	}
		
	spider_web_explode();
}

void spider_shootweb()
{
	// clone of the electro secondary attack, with less bouncing
	entity proj = world;
	
	makevectors(self.angles);

	W_SetupShot_ProjectileSize (self, '0 0 -4', '0 0 -4', FALSE, 2, "machines/steam_burst.ogg", CH_WEAPON_A, 0);

	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("deluge_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma";
	proj.owner = proj.realowner = self;
	proj.use = spider_web_touch;
	proj.think = adaptor_think2use_hittype_splash;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = 0;
	proj.nextthink = time + autocvar_g_balance_electro_secondary_lifetime;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_MONSTER_MELEE;
	setorigin(proj, w_shotorg);

	//proj.glow_size = 50;
	//proj.glow_color = 45;
	proj.movetype = MOVETYPE_BOUNCE;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_electro_secondary);
	proj.touch = spider_web_touch;
	setsize(proj, '0 0 -4', '0 0 -4');
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = 0;
	proj.health = 500;
	proj.event_damage = W_Plasma_Damage;
	proj.flags = FL_PROJECTILE;
	proj.damagedbycontents = TRUE;

	proj.bouncefactor = 0.3;
	proj.bouncestop = 0.05;
	proj.missile_flags = MIF_SPLASH | MIF_ARC;

	CSQCProjectile(proj, TRUE, PROJECTILE_DELUGE, FALSE); // no culling, it has sound

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void spider_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = vectoangles(self.enemy.origin - self.origin);

	// face the enemy	
	if (self.stoned || self.frozen) self.frame = spider_anim_stone; else self.frame = spider_anim_attack2;
	self.angles_y = angles_face_y ;
	self.nextthink = time + autocvar_g_monster_spider_attack_leap_delay;
	
	makevectors(self.angles);
	
	switch(self.spider_type)
	{
		default:
		case SPIDER_TYPE_ICE:
			spider_shootweb(); break; // must... remember... breaks!
		case SPIDER_TYPE_FIRE:
			W_Fireball_Attack2(); break;
	}
}

void spider_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;

	if (self.stoned || self.frozen)
		self.frame = spider_anim_stone;

	self.think = spider_think;
	
	if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.enemy)
	if (self.enemy.team == self.team || self.monster_owner == self.enemy)
		self.enemy = world;
	
	if(teamplay && autocvar_g_monsters_teams && self.monster_owner.team != self.team)
		self.monster_owner = world;	
	
	// remove enemy that ran away
	if (self.enemy)
	if (self.delay <= time) // check if we can do the rescan now
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_spider_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_spider_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_spider_target_recheck_delay;
	}

	if (self.enemy) 
	{
		// this spider has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
			if (enemyDistance <= autocvar_g_monster_spider_attack_stand_range * self.scale && mySpeed <= 30) 
			{
				
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				spider_attack_standing();
				finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_spider_attack_leap_range * self.scale && !self.enemy.frozen) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				spider_attack_leap();
				finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if not(finished) 
	{
		monster_move(autocvar_g_monster_spider_speed_run, autocvar_g_monster_spider_speed_walk, autocvar_g_monster_spider_stopspeed, spider_anim_walk, spider_anim_walk, spider_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("spider is idling while waiting for some fresh meat...\n");
		if (mySpeed <= 10)
			if (self.stoned || self.frozen) self.frame = spider_anim_stone; else self.frame = spider_anim_idle;
		else
			if (self.stoned || self.frozen) self.frame = spider_anim_stone; else self.frame = spider_anim_walk;
		self.nextthink = time + autocvar_g_monster_spider_idle_timer_min * random();	
	}
}

/**
 * Spawn the spider.
 */
void spider_spawn() 
{
	if not(self.monster_forcetype) {
		//Mix
		if ((!self.scale) || (self.scale == 1))
		if not(self.scale == 1.5) {
			self.scale = 0.01 + (random() * 0.25);
			self.mins = SPIDER_MIN;
			self.maxs = SPIDER_MAX;
			self.mins_x *= self.scale;
			self.mins_y *= self.scale;
			self.mins_z *= self.scale;
			self.maxs_x *= self.scale;
			self.maxs_y *= self.scale;
			self.maxs_z *= self.scale;
			setsize(self, self.mins, self.maxs);
		}
		
		if (self.scale > 0.5)
			self.skin = 1;
	} else {
		if (self.monster_forcetype == 1) {
			//Small
			if ((!self.scale) || (self.scale == 1) || (self.scale == 1.5))
			{
				//Bosses/Giants are 1.5 scale at this point in the code
				if (self.scale != 1.5) {
					self.scale = 0.01 + (random() * 0.25);
				} else {
					self.scale = 0.20 + (random() * 0.25);
				}
				self.mins = SPIDER_MIN;
				self.maxs = SPIDER_MAX;
				self.mins_x *= self.scale;
				self.mins_y *= self.scale;
				self.mins_z *= self.scale;
				self.maxs_x *= self.scale;
				self.maxs_y *= self.scale;
				self.maxs_z *= self.scale;
				setsize(self, self.mins, self.maxs);
			}
			self.skin = 0;
		} else if (self.monster_forcetype == 2) {
			//Huge
			if ((!self.scale) || (self.scale == 1) || (self.scale == 1.5))
			{
				if (self.scale != 1.5) {
					self.scale = 0.95 + (random() * 0.25);
				} else {
					self.scale = 1.05 + (random() * 2.50);
				}
				self.mins = SPIDER_MIN;
				self.maxs = SPIDER_MAX;
				self.mins_x *= self.scale;
				self.mins_y *= self.scale;
				self.mins_z *= self.scale;
				self.maxs_x *= self.scale;
				self.maxs_y *= self.scale;
				self.maxs_z *= self.scale;
				setsize(self, self.mins, self.maxs);
			}
			self.skin = 1;
		}
	}
	
	if (self.monster_forcescale) {
		self.scale = self.monster_forcescale;
		self.mins = SPIDER_MIN;
		self.maxs = SPIDER_MAX;
		self.mins_x *= self.scale;
		self.mins_y *= self.scale;
		self.mins_z *= self.scale;
		self.maxs_x *= self.scale;
		self.maxs_y *= self.scale;
		self.maxs_z *= self.scale;
		setsize(self, self.mins, self.maxs);
	}

	if (self.health <= 0)
		self.health = autocvar_g_monster_spider_health * self.scale;
		
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.25);

	self.stoneskin = 2;
	self.species = SPECIES_INSECT;
	self.classname			= "monster_spider";
	self.nextthink	  		= time + random() * 0.5 + 0.1;
	self.pain_finished  	= self.nextthink;
	self.frame		  		= spider_anim_idle;
	self.think		  		= spider_think;
	self.sprite_height  	= 40 * self.scale;
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

/*QUAKED monster_spider (1 0 0) (-18 -18 -25) (18 18 47)
Spider, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/spider.dpm"
*/
void spawnfunc_monster_spider() 
{
	if not(autocvar_g_monster_spider) 
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_spider;
	self.classname = "monster_spider";
	if(!self.spider_type)
		self.spider_type = autocvar_g_monster_spider_attack_type;
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "Spider",
			 "models/monsters/spider.dpm",
			 SPIDER_MIN, SPIDER_MAX,
			 FALSE,
			 spider_die, spider_spawn))
	{
		remove(self);
		return;
	}
}

void spawnfunc_monster_spider_small() 
{
	if (self.scale) 
	{
		self.monster_forcescale = self.scale;
	}
	self.monster_forcetype = 1;
	spawnfunc_monster_spider();	
}

void spawnfunc_monster_spider_huge() 
{
	if (self.scale) 
	{
		self.monster_forcescale = self.scale;
	}
	self.monster_forcetype = 2;
	spawnfunc_monster_spider();	
}
