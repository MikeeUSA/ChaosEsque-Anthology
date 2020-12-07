/**
 * Special purpose fields:
 * .delay - time at which to check if shinrae's enemy is still in range
 * .enemy - enemy of this shinrae
 * .state - state of the shinrae, see SHINRAE_STATE_*
 */
 
// cvars
float autocvar_g_monster_shinrae;
float autocvar_g_monster_shinrae_stopspeed;
float autocvar_g_monster_shinrae_attack_leap_damage;
float autocvar_g_monster_shinrae_attack_leap_delay;
float autocvar_g_monster_shinrae_attack_leap_force;
float autocvar_g_monster_shinrae_attack_leap_range;
float autocvar_g_monster_shinrae_attack_leap_speed;
float autocvar_g_monster_shinrae_attack_stand_damage;
float autocvar_g_monster_shinrae_attack_stand_delay;
float autocvar_g_monster_shinrae_attack_stand_range;
float autocvar_g_monster_shinrae_health;
float autocvar_g_monster_shinrae_idle_timer;
float autocvar_g_monster_shinrae_speed_walk;
float autocvar_g_monster_shinrae_speed_run;
float autocvar_g_monster_shinrae_target_recheck_delay;
float autocvar_g_monster_shinrae_target_range;
float autocvar_g_monster_shinrae_stoptoshoot;
float autocvar_g_monster_shinrae_attack_maxrange;

// shinrae animations
#define shinrae_anim_attackleap		 8
#define shinrae_anim_attackrun1		 13
#define shinrae_anim_attackrun2		 15
#define shinrae_anim_attackrun3		 16
#define shinrae_anim_attackstanding1	2
#define shinrae_anim_attackstanding2	11
#define shinrae_anim_attackstanding3	12
#define shinrae_anim_blockend		   7
#define shinrae_anim_blockstart		 8
#define shinrae_anim_deathback1		 0
#define shinrae_anim_deathback2		 0
#define shinrae_anim_deathback3		 0
#define shinrae_anim_deathfront1		1
#define shinrae_anim_deathfront2		1
#define shinrae_anim_deathfront3		1
#define shinrae_anim_deathleft1		 0
#define shinrae_anim_deathleft2		 0
#define shinrae_anim_deathright1		1
#define shinrae_anim_deathright2		1
#define shinrae_anim_idle			   7
#define shinrae_anim_painback1		  9
#define shinrae_anim_painback2		  9
#define shinrae_anim_painfront1		 10
#define shinrae_anim_painfront2		 10
#define shinrae_anim_runbackwards	   14
#define shinrae_anim_runbackwardsleft   22
#define shinrae_anim_runbackwardsright  21
#define shinrae_anim_runforward		 13
#define shinrae_anim_runforwardleft	 20
#define shinrae_anim_runforwardright	19
#define shinrae_anim_spawn			  6
#define shinrae_anim_deadback1			  17
#define shinrae_anim_deadfront1			18
#define shinrae_anim_stone			  31
#define shinrae_anim_attackcrossbow	11


const vector SHINRAE_MIN				 = '-16 -16 -24';
const vector SHINRAE_MAX				 = '16 16 40';

const vector SHINRAE_DEAD_MIN				 = '-18 -18 -30';
const vector SHINRAE_DEAD_MAX				 = '18 18 2';

#define SHINRAE_STATE_SPAWNING		0
#define SHINRAE_STATE_IDLE			1
#define SHINRAE_STATE_ANGRY			2
#define SHINRAE_STATE_ATTACK_LEAP	3

void shinrae_spawn();
void spawnfunc_monster_shinrae();
void shinrae_think();

void shinrae_precache_growls()
{
	precache_sound ("monsters/ifiygd_growl1.wav");
	precache_sound ("monsters/ifiygd_growl2.wav");
	precache_sound ("monsters/ifiygd_growl3.wav");
	precache_sound ("monsters/ifiygd_growl4.wav");
	precache_sound ("monsters/ifiygd_growl5.wav");
	precache_sound ("monsters/ifiygd_growl6.wav");
	
}

void shinrae_randomgrowl(entity myplayer, float myvolumemulti)
{
	local float snrandvar;
	snrandvar = floor(random()*6);
	switch(snrandvar)
	{
		default:
		case 0:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl1.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
		case 1:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl2.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
		case 2:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl3.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
		case 3:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl4.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
		case 4:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl5.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
		case 5:
			spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl6.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
			break;
	}
}

void shinrae_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void shinrae_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void shinrae_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("shinrae");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, SHINRAE_DEAD_MIN, SHINRAE_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	//We set think below to load the deadbody "animation", then fade
	self.nextthink	  	= time + 0.5;
	self.pain_finished  = self.nextthink;
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
	
	
	//If we're allowed to drop a weapon we shall.
	//Since we have only future weapons we're a future weapons monster
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
	if (monsterdropweapon && self.weaponentity.count) {
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weaponentity.count == 1) {
			W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CRYPISTOL, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CRYPISTOL, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_CRYLANCER, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CRYLANCER, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = shinrae_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_deathback1;
	} else {
		self.think = shinrae_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

float shinrae_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_broadaxe_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_crylancer_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_crypistol_primary_refire;
	} else {
		return autocvar_g_monster_shinrae_attack_stand_delay;
	}
}

float shinrae_attack_armed()
{	
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	
	} else if (self.weaponentity.count == 5) {
		if (self.enemy != world) {
			self.weaponentity.v_angle = police_style_aiming (self);
			makevectors(self.weaponentity.v_angle);
		}
		
		
		if (random() > 0.1) {
			W_Crylancer_Attack();
		} else {
			W_Crylancer_Attack2();
			return autocvar_g_balance_crylancer_secondary_refire;
		}
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			self.weaponentity.v_angle = police_style_aiming (self);
			makevectors(self.weaponentity.v_angle);
		}
		
		if (random() > 0.5) {
			W_Crypistol_Attack();
		} else {
			W_Crypistol_Attack2();
			return autocvar_g_balance_crypistol_secondary_refire;
		}
	}
	
	return shinrae_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void shinrae_attack_standing()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	float myrefire;
	float rand = random(), dot = 0, bigdmg = 0;

	self.velocity_x = 0;
	self.velocity_y = 0;
	
	if(self.monster_owner == self.enemy)
	{
		self.enemy = world;
		return;
	}
	
	bigdmg = autocvar_g_monster_shinrae_attack_stand_damage * self.scale;

	//print("shinrae attacks!\n");
	makevectors (self.angles);
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		myrefire = shinrae_attack_armed();
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_shinrae_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = shinrae_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = shinrae_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = shinrae_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = shinrae_anim_attackstanding2;
		else
			self.frame = shinrae_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
}


void shinrae_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_shinrae_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_shinrae_attack_leap_force;
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		shinrae_attack_armed();
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy shinrae's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void shinrae_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = shinrae_attack_refire();
	else
		myrefire = autocvar_g_monster_shinrae_attack_leap_delay;

	// face the enemy	
	self.state = SHINRAE_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = shinrae_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_shinrae_attack_leap_speed;
}

/**
 * Main shinrae think function.
 */
void shinrae_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = shinrae_anim_stone;
	
	
	self.think = shinrae_think;
	
	if (self.state == SHINRAE_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = SHINRAE_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == SHINRAE_STATE_SPAWNING) {
		// become idle when shinrae spawned
		if (self.stoned || self.frozen) self.frame = shinrae_anim_stone; else self.frame = shinrae_anim_idle;
		self.state = SHINRAE_STATE_IDLE;
	}
	
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
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_shinrae_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_shinrae_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_shinrae_target_recheck_delay;
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_broadaxe_primary_melee_range * 0.94;
		else
			mystandattackrange = autocvar_g_monster_shinrae_attack_stand_range * self.scale;
		
		// make sure shinrae is angry
		self.state = SHINRAE_STATE_ANGRY;
		

		// this shinrae has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= autocvar_g_monster_shinrae_attack_maxrange)
		{
			if (random() > 0.60) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20; //Set to force firing below
				enemyDistance = autocvar_g_monster_shinrae_attack_stand_range;
			}
		}
		
		////Magic Attack
		//if (self.havocbot_nextmagicthink < time) {
		//	self.mana = 90000; //Always, we have enough
		//	self.havocbot_nextmagicthink =  time+6;
		//	self.v_angle = self.angles;
		//	makevectors(self.v_angle);
		//	havocbot_castmagic();
		//}
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (!self.frozen)
		if (!self.stoned)
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
		if (mySpeed <= 30)
			if (enemyDistance <= mystandattackrange) 
			{
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				if (random() > 0.25) shinrae_randomgrowl(self, 1);
				shinrae_attack_standing();
				if (random() > autocvar_g_monster_shinrae_stoptoshoot) finished = 2; //Most of the time we keep on truckin
				else finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_shinrae_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				if (random() > 0.35) shinrae_randomgrowl(self, 1);
				shinrae_attack_leap();
				if (random() > autocvar_g_monster_shinrae_stoptoshoot) finished = 2; //Most of the time we keep on truckin
				else finished = TRUE;
			}
		
	} else if (random() > 0.90) {
		shinrae_randomgrowl(self, bound(0.2, random(), 0.9));
	}
	
	if (!finished || finished == 2) 
	{
		monster_move(monster_mvmntimpare_beast(autocvar_g_monster_shinrae_speed_run), monster_mvmntimpare_beast(autocvar_g_monster_shinrae_speed_walk), autocvar_g_monster_shinrae_stopspeed, shinrae_anim_runforward, shinrae_anim_runforward, shinrae_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			if (finished != 2) {
				//Allready set if 2 so skip unless not 2
				self.nextthink = time + 0.1;
			}
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("shinrae is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = shinrae_anim_stone; else self.frame = ((mySpeed <= 20) ? shinrae_anim_idle : shinrae_anim_runforward);
		self.nextthink = time + autocvar_g_monster_shinrae_idle_timer * random();	
	}
}

/**
 * Spawn the shinrae.
 */
void shinrae_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_shinrae_health * self.scale;
	
	self.classname			= "monster_shinrae";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= SHINRAE_STATE_SPAWNING;
	self.frame		  		= shinrae_anim_spawn;
	self.think		  		= shinrae_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	//self.gibscale = 0.8;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	
	
	//if (self.scale) self.view_ofs = '0 0 55' * self.scale;
	//else self.view_ofs = '0 0 55';
	
	if (self.scale) self.view_ofs = '0 0 32' * self.scale;
	else self.view_ofs = '0 0 32';
	
	self.ballistics_density = autocvar_g_ballistics_density_player;
	self.monster_thinkadd = ((random() - 0.5)*0.15);
	self.monster_smell_bodyodor = self.smell_bodyodor = 0.1 + (random() * 0.2);
			
	self.resist_blunt = 0.3;
	self.resist_bullet = 0.3;
	self.resist_crush = 0.3;
	self.resist_edged = 0.3;
	self.resist_pierce = 0.15;
	
	self.resist_sound = 0.5;
	
	self.lodmodel1 = "models/monsters/raptile_lod1.iqm";
	self.lodmodel2 = "models/monsters/raptile_lod2.iqm";
	self.lodmodel3 = "models/monsters/raptile_lod3.iqm";
	self.lodmodel4 = "models/monsters/raptile_lod4.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	

		self.species = SPECIES_ALIEN;
		
		////Unknown
		//if not(self.sex) {
		//	self.sex = SEX_EUNICH;
		//
		//	if (random() > 0.4)
		//	{
		//		self.sex = SEX_MALE;
		//	}
		//}
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;

	wrand = random();
	if (wrand > 0.2)
	{
		wrand = random();
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '180 -45 90';
	
		if (random() > 0.65) {
			setmodel(self.weaponentity,  "models/weapons/v_crylancer.md3");
			self.weaponentity.count = 5;
			self.weaponentity.angles    = '0 110 0';
		} else {
			setmodel(self.weaponentity,  "models/weapons/v_crypistol.md3");
			self.weaponentity.count = 11;
			self.weaponentity.angles    = '0 110 0';
		}
		
		
		setattachment(self.weaponentity, self, "bip01 r hand");
		setorigin(self.weaponentity, '2.1 6 -1');    // Move attch spot up 8// forward 4// yes fscked up bone  

		wrand = random();
		if (wrand > 0.8)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			self.bomb1.origin = self.weaponentity.origin;
			setmodel(self.bomb1,  self.bomb1.model);
			setorigin(self.bomb1,  self.bomb1.origin);
			
			if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
				self.bomb1.angles    = '0 110 0';
			else
				self.bomb1.angles    = '-45 60 50';
			
			setattachment(self.bomb1, self, "hand_L");
		}
		
		////Head Ornament
		//wrand = random();
		//if (wrand > 0.2)
		//{
		//	self.bomb2.alpha = 1;
		//	setmodel(self.bomb2,  "models/misc/playerhorns_head.iqm");
		//	self.bomb2.angles    = '0 0 -90';
		//	setattachment(self.bomb2, self, "Head");
		//	setorigin(self.bomb2, '0 8 -2');    // Move attch spot up 8// back 2// yes fscked up bone  
		//	self.health = self.health * 1.25;
		//	self.armorvalue = g_pickup_armormedium;
		//}
	}
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void shinrae_precache_weapons()
{
	precache_model ("models/weapons/v_crylancer.md3");
	precache_model ("models/weapons/v_crypistol.md3");
	//precache_model ("models/misc/playerhorns_head.iqm");	
}


/*QUAKED monster_shinrae (1 0 0) (-18 -18 -25) (18 18 47)
ShinRae, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 shinrae entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/shinrae.dpm"
*/
void spawnfunc_monster_shinrae() 
{
	if not(autocvar_g_monster_shinrae) 
	{
		remove(self);
		return;
	}
	
	shinrae_precache_growls();
	shinrae_precache_weapons();
	
	self.monster_spawnfunc = spawnfunc_monster_shinrae;
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.scale = 1.25;
		self.ammount = 1;
		if (random() > 0.45)
			self.scale = self.scale + (random()*0.9);
		else 
			self.scale = self.scale + (random()*1.2);
	}
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "ShinRae",
			 "models/monsters/raptile.iqm",
			 SHINRAE_MIN, SHINRAE_MAX,
			 FALSE,
			 shinrae_die, shinrae_spawn))
	{
		remove(self);
		return;
	}
}
