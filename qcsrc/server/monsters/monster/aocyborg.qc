/**
 * Special purpose fields:
 * .delay - time at which to check if aocyborg's enemy is still in range
 * .enemy - enemy of this aocyborg
 * .state - state of the aocyborg, see AOCYBORG_STATE_*
 */
 
// cvars
float autocvar_g_monster_aocyborg;
float autocvar_g_monster_aocyborg_stopspeed;
float autocvar_g_monster_aocyborg_attack_leap_damage;
float autocvar_g_monster_aocyborg_attack_leap_delay;
float autocvar_g_monster_aocyborg_attack_leap_force;
float autocvar_g_monster_aocyborg_attack_leap_range;
float autocvar_g_monster_aocyborg_attack_leap_speed;
float autocvar_g_monster_aocyborg_attack_stand_damage;
float autocvar_g_monster_aocyborg_attack_stand_delay;
float autocvar_g_monster_aocyborg_attack_stand_range;
float autocvar_g_monster_aocyborg_health;
float autocvar_g_monster_aocyborg_idle_timer;
float autocvar_g_monster_aocyborg_speed_walk;
float autocvar_g_monster_aocyborg_speed_run;
float autocvar_g_monster_aocyborg_target_recheck_delay;
float autocvar_g_monster_aocyborg_target_range;
float autocvar_g_monster_aocyborg_stoptoshoot;
float autocvar_g_monster_aocyborg_attack_maxrange;

//Materials/Sections
//AOCircle          //eyes chest circle
//AObengkorah_jero //Internal skel
//AObunder2_dalam  //round inside
//AOdodo           //chest
//AOgulu           //Kneck
//AOpalaron        //ropes, not used
//AOpiston
//AOrai           //Lower face
//AOsenjata       //Weapon
//AOtutup_lengan  //Suit/armor

// aocyborg animations
#define aocyborg_anim_attackleap		 8
#define aocyborg_anim_attackrun1		 13
#define aocyborg_anim_attackrun2		 15
#define aocyborg_anim_attackrun3		 16
#define aocyborg_anim_attackstanding1	2
#define aocyborg_anim_attackstanding2	11
#define aocyborg_anim_attackstanding3	12
#define aocyborg_anim_blockend		   7
#define aocyborg_anim_blockstart		 8
#define aocyborg_anim_deathback1		 0
#define aocyborg_anim_deathback2		 0
#define aocyborg_anim_deathback3		 0
#define aocyborg_anim_deathfront1		1
#define aocyborg_anim_deathfront2		1
#define aocyborg_anim_deathfront3		1
#define aocyborg_anim_deathleft1		 0
#define aocyborg_anim_deathleft2		 0
#define aocyborg_anim_deathright1		1
#define aocyborg_anim_deathright2		1
#define aocyborg_anim_idle			   7
#define aocyborg_anim_painback1		  9
#define aocyborg_anim_painback2		  9
#define aocyborg_anim_painfront1		 10
#define aocyborg_anim_painfront2		 10
#define aocyborg_anim_runbackwards	   14
#define aocyborg_anim_runbackwardsleft   22
#define aocyborg_anim_runbackwardsright  21
#define aocyborg_anim_runforward		 13
#define aocyborg_anim_runforwardleft	 20
#define aocyborg_anim_runforwardright	19
#define aocyborg_anim_spawn			  6
#define aocyborg_anim_deadback1			  17
#define aocyborg_anim_deadfront1			18
#define aocyborg_anim_stone			  31
#define aocyborg_anim_attackcrossbow	11


const vector AOCYBORG_MIN				 = '-16 -16 -24';
const vector AOCYBORG_MAX				 = '16 16 40';

const vector AOCYBORG_DEAD_MIN				 = '-18 -18 -30';
const vector AOCYBORG_DEAD_MAX				 = '18 18 2';

#define AOCYBORG_STATE_SPAWNING		0
#define AOCYBORG_STATE_IDLE			1
#define AOCYBORG_STATE_ANGRY			2
#define AOCYBORG_STATE_ATTACK_LEAP	3

void aocyborg_spawn();
void spawnfunc_monster_aocyborg();
void aocyborg_think();

void aocyborg_precache_growls()
{
	return;
	//precache_sound ("monsters/ifiygd_growl1.wav");
	//precache_sound ("monsters/ifiygd_growl2.wav");
	//precache_sound ("monsters/ifiygd_growl3.wav");
	//precache_sound ("monsters/ifiygd_growl4.wav");
	//precache_sound ("monsters/ifiygd_growl5.wav");
	//precache_sound ("monsters/ifiygd_growl6.wav");
	
}

void aocyborg_randomgrowl(entity myplayer, float myvolumemulti)
{
	return;
	//local float snrandvar;
	//snrandvar = floor(random()*6);
	//switch(snrandvar)
	//{
	//	default:
	//	case 0:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl1.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//	case 1:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl2.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//	case 2:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl3.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//	case 3:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl4.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//	case 4:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl5.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//	case 5:
	//		spamsound (myplayer, CH_AMBIENT, "monsters/ifiygd_growl6.wav", VOL_BASE * myvolumemulti, ATTN_NORM);
	//		break;
	//}
}

void aocyborg_lightoff()
{
	self.effects = 0;
	self.light_lev = 0;
	self.weaponentity.effects = 0;
	self.weaponentity.light_lev = 0;
}

void aocyborg_lighton()
{
	//self.effects = EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH | EF_NOSHADOW;
	self.weaponentity.effects = EF_BRIGHTFIELD | EF_BRIGHTLIGHT | EF_MUZZLEFLASH | EF_NOSHADOW;
	
	self.effects = EF_NOSHADOW;
	//self.weaponentity.effects = EF_NOSHADOW;
	
	self.pflags = PFLAGS_FULLDYNAMIC;
	self.light_lev = 500;
	//self.color = '0.7 0.7 0.45';
	self.style = 0;
	self.weaponentity.pflags = PFLAGS_FULLDYNAMIC;
	self.weaponentity.color = self.color;
	self.weaponentity.light_lev = self.light_lev;
}

void aocyborg_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	aocyborg_lightoff();
}

void aocyborg_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
	aocyborg_lightoff();
}

void aocyborg_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("aocyborg");
	
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, AOCYBORG_DEAD_MIN, AOCYBORG_DEAD_MAX);
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
			W_ThrowNewWeapon(self, WEP_HLAC, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_HLAC, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_NEX, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_NEX, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = aocyborg_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_deathback1;
	} else {
		self.think = aocyborg_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_deathfront1;
	}
	
	if (!self.stoned && (!(self.frozen == 1))) {
		if (random() > 0.2) {
			if (random() > 0.2) {
				W_Plasma_TriggerCombo(self.origin, autocvar_g_balance_electro_combo_comboradius, self.realowner);
				RadiusDamage (self, self, autocvar_g_balance_electro_combo_damage, autocvar_g_balance_electro_combo_edgedamage, autocvar_g_balance_electro_combo_radius, world, autocvar_g_balance_electro_combo_force, WEP_ELECTRO | HITTYPE_BOUNCE, world); // use THIS type for a combo because primary can't bounce
				Chemical_flash_maybe(self);
			}
			
			if (random() > 0.2) {
				if (random() > 0.5) {
					lgunbeam_arcsp(autocvar_g_balance_lightninggun_primary_damage * frametime,
					autocvar_g_balance_lightninggun_primary_arcrange * 5, self.origin+'0 0 32', self);
				} else {
					lgunbeam_arcsc(autocvar_g_balance_lightninggun_primary_damage * frametime,
					autocvar_g_balance_lightninggun_primary_arcrange * 5, self.origin+'0 0 32', self);
				}
			}
		
			if (random() > 0.2) {
				local entity myoldself;
				local entity xc;
				myoldself = self;
				xc = spawn();
				xc.origin = self.origin;
				xc.realowner = self;
				self.projectiledeathtype = WEP_ELECTRO;
				setorigin (xc, xc.origin);
				self = xc;
				if (random() > 0.7) {
					//Big
					//print("big\n");
					tankll37_Grenade_Explode2();
				} else {
					//print("2\n");
					tankll24_Grenade_Explode2();
				}
				//It removes itself
				self = myoldself;
			}
		}
	}
	

	monster_hook_death(); // for post-death mods
}

float aocyborg_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_broadaxe_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_nex_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_hlac_primary_refire;
	} else {
		return autocvar_g_monster_aocyborg_attack_stand_delay;
	}
}

vector aocyborg_style_aiming (entity mymonster)
{
	local vector angles_face = '0 0 0';
	local vector myenemyorg;
	myenemyorg = mymonster.enemy.origin;
	//Simple aiming of weapon entity so W_SetupShot will be correct when called
	//Police shoot from their head area to players head area by default, here's to mix it up:
	
	myenemyorg_z = myenemyorg_z - self.view_ofs_z;
	
	angles_face = vectoangles(myenemyorg - mymonster.origin);
	angles_face_x = angles_face_x * -1; //Inverted pitch for models (vs world), Quake Legacy
	
	//print(vtos(mymonster.v_angle), "\n Vangles");
	
	return(angles_face);
}

float aocyborg_attack_armed()
{	
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	
	} else if (self.weaponentity.count == 5) {
		if (self.enemy != world) {
			self.weaponentity.v_angle = aocyborg_style_aiming (self);
			makevectors(self.weaponentity.v_angle);
		}
		
		self.nex_charge = autocvar_g_balance_nex_charge_limit;
			W_Nex_Attack(0);
		
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			self.weaponentity.v_angle = police_style_aiming (self);
			makevectors(self.weaponentity.v_angle);
		}
		
		if (random() > 0.025) {
			//ATTACK_FINISHED(self) = time + autocvar_g_balance_hlac_primary_refire * W_WeaponRateFactor();
			W_HLAC_Attack();
			self.misc_bulletcounter = self.misc_bulletcounter + 1;
		} else {
			self.misc_bulletcounter = 0;
			W_HLAC_Attack2();
			return autocvar_g_balance_hlac_secondary_refire;
		}
	}
	
	return aocyborg_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void aocyborg_attack_standing()
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
	
	bigdmg = autocvar_g_monster_aocyborg_attack_stand_damage * self.scale;

	//print("aocyborg attacks!\n");
	makevectors (self.angles);
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		myrefire = aocyborg_attack_armed();
	} else {
		self.misc_bulletcounter = 0; //For HLAC
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_aocyborg_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = aocyborg_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = aocyborg_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = aocyborg_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = aocyborg_anim_attackstanding2;
		else
			self.frame = aocyborg_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
}


void aocyborg_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_aocyborg_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_aocyborg_attack_leap_force;
	
	if ((self.weaponentity.count && random() > 0.5) || (self.weaponentity.count == 5 || self.weaponentity.count == 11)) {
		aocyborg_attack_armed();
	} else {
		self.misc_bulletcounter = 0; //For HLAC
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy aocyborg's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void aocyborg_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = aocyborg_attack_refire();
	else
		myrefire = autocvar_g_monster_aocyborg_attack_leap_delay;

	// face the enemy	
	self.state = AOCYBORG_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = aocyborg_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_aocyborg_attack_leap_speed;
}

/**
 * Main aocyborg think function.
 */
void aocyborg_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = aocyborg_anim_stone;
	
	if (self.stoned) {
		aocyborg_lightoff();
	} else {
		aocyborg_lighton();
	}
	
	self.think = aocyborg_think;
	
	if (self.state == AOCYBORG_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = AOCYBORG_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == AOCYBORG_STATE_SPAWNING) {
		// become idle when aocyborg spawned
		if (self.stoned || self.frozen) self.frame = aocyborg_anim_stone; else self.frame = aocyborg_anim_idle;
		self.state = AOCYBORG_STATE_IDLE;
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
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_aocyborg_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_aocyborg_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.misc_bulletcounter = 0; //For HLAC
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_aocyborg_target_recheck_delay;
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_broadaxe_primary_melee_range * 0.94;
		else
			mystandattackrange = autocvar_g_monster_aocyborg_attack_stand_range * self.scale;
		
		// make sure aocyborg is angry
		self.state = AOCYBORG_STATE_ANGRY;
		

		// this aocyborg has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= autocvar_g_monster_aocyborg_attack_maxrange)
		{
			if (random() > 0.60) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20; //Set to force firing below
				enemyDistance = autocvar_g_monster_aocyborg_attack_stand_range;
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
				if (random() > 0.25) aocyborg_randomgrowl(self, 1);
				aocyborg_attack_standing();
				if (random() > autocvar_g_monster_aocyborg_stoptoshoot) finished = 2; //Most of the time we keep on truckin
				else finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_aocyborg_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				if (random() > 0.35) aocyborg_randomgrowl(self, 1);
				aocyborg_attack_leap();
				if (random() > autocvar_g_monster_aocyborg_stoptoshoot) finished = 2; //Most of the time we keep on truckin
				else finished = TRUE;
			}
		
	} else if (random() > 0.90) {
		aocyborg_randomgrowl(self, bound(0.2, random(), 0.9));
	}
	
	if (!finished || finished == 2) 
	{
		monster_move(autocvar_g_monster_aocyborg_speed_run, autocvar_g_monster_aocyborg_speed_walk, autocvar_g_monster_aocyborg_stopspeed, aocyborg_anim_runforward, aocyborg_anim_runforward, aocyborg_anim_idle);
		
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
		//print("aocyborg is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = aocyborg_anim_stone; else self.frame = ((mySpeed <= 20) ? aocyborg_anim_idle : aocyborg_anim_runforward);
		self.nextthink = time + autocvar_g_monster_aocyborg_idle_timer * random();	
	}
}

/**
 * Spawn the aocyborg.
 */
void aocyborg_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_aocyborg_health * self.scale;
	
	self.classname			= "monster_aocyborg";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= AOCYBORG_STATE_SPAWNING;
	self.frame		  		= aocyborg_anim_spawn;
	self.think		  		= aocyborg_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	if (!self.colormap && !self.monster_marshalable) {
		//If we aren't a recruitment-post spawned monster
		//AND we don't have a colormap
		//Use this one
		wrand = random();
		
		if (wrand > 0.8) {
			self.skin = 1;
		} else if (wrand > 0.6) {
			//Light
			self.skin = 2;
		} else {
			self.skin = 0;
			wrand = random();
			if (wrand > 0.95) {
				self.colormap = (1024 + 2 + 2 * 16);
			} else if (wrand > 0.9) {
				self.colormap = (1024 + 3 + 3 * 16);
			} else if (wrand > 0.85) {
				self.colormap = (1024 + 5 + 5 * 16);
			} else if (wrand > 0.8) {
				self.colormap = (1024 + 6 + 6 * 16);
			} else if (wrand > 0.75) {
				self.colormap = (1024 + 7 + 7 * 16);
			} else if (wrand > 0.7) {
				self.colormap = (1024 + 0 + 0 * 16);
			} else if (wrand > 0.65) {
				self.colormap = (1024 + 8 + 8 * 16);
			} else if (wrand > 0.6) {
				self.colormap = (1024 + 9 + 9 * 16);
			} else if (wrand > 0.55) {
				self.colormap = (1024 + 10 + 10 * 16);
			} else if (wrand > 0.5) {
				self.colormap = (1024 + 11 + 11 * 16);
			} else if (wrand > 0.45) {
				self.colormap = (1024 + 12 + 12 * 16);
			} else if (wrand > 0.4) {
				self.colormap = (1024 + 13 + 13 * 16);
			} else if (wrand > 0.35) {
				self.colormap = (1024 + 14 + 14 * 16);
			} else {
				self.colormap = (1024 + 1 + 1 * 16);
			}
		}
	}
	self.monster_demeanor = 4; //Don't ever attack those under same owner, unless attacked
	
	self.gibscale = 3; //The species gibs are small.
	
	
	//if (self.scale) self.view_ofs = '0 0 55' * self.scale;
	//else self.view_ofs = '0 0 55';
	
	if (self.scale) self.view_ofs = '0 0 32' * self.scale;
	else self.view_ofs = '0 0 32';
	
	//self.ballistics_density = autocvar_g_ballistics_density_player;
	self.ballistics_density = autocvar_g_ballistics_density_player*2;
	self.monster_thinkadd = ((random() - 0.5)*0.15);
				
	self.resist_acid = 0.3;
	self.resist_blunt = 0.7;
	self.resist_bullet = 0.5;
	self.resist_crush = 0.5;
	self.resist_edged = 0.9;
	self.resist_electricity = 0;
	self.resist_energy = 0.5;
	self.resist_explode = 0;
	self.resist_fall = 0.9;
	self.resist_fire = 0.3;
	self.resist_laser = 0.5;
	self.resist_pierce = 0.9;
	self.resist_ice = 1;
	self.resist_rotor = 0.7;
	
	self.resist_sound = 1;
	
	self.buff_wont_ignite = 1;
	
	self.armorvalue = 200;
	
	self.lodmodel1 = "models/monsters/ao_robot_lod1.iqm";
	self.lodmodel2 = "models/monsters/ao_robot_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
	

		self.species = SPECIES_ROBOT_SHINY;
		
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

	self.clientcolors = self.colormap;
	lightsabre_setcolors(self, self);
	//Soften color:
	self.color_x = (self.color_x * 0.5) + 0.5;
	self.color_y = (self.color_y * 0.5) + 0.5;
	self.color_z = (self.color_z * 0.5) + 0.5;
	//Apply to wep entity
	self.weaponentity.color = self.color;
	aocyborg_lighton();
	
	wrand = random();
	if (wrand > 0.2)
	{
		wrand = random();
		self.weaponentity.alpha = 1;
		//self.weaponentity.angles    = '180 -45 90';
	
		if (random() > 0.65) {
			setmodel(self.weaponentity,  "models/weapons/v_nex.md3");
			self.weaponentity.count = 5;
			self.weaponentity.angles    = '0 110 0';
			//self.view_ofs = '0 0 0';
			if (self.scale) self.view_ofs = '0 0 16' * self.scale;
			else self.view_ofs = '0 0 16';
		} else {
			setmodel(self.weaponentity,  "models/weapons/v_hlac.md3");
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

void aocyborg_precache_weapons()
{
	precache_model ("models/weapons/v_nex.md3");
	precache_model ("models/weapons/v_hlac.md3");
	//precache_model ("models/misc/playerhorns_head.iqm");	
}


/*QUAKED monster_aocyborg (1 0 0) (-18 -18 -25) (18 18 47)
AOCyborg, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 aocyborg entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/aocyborg.dpm"
*/
void spawnfunc_monster_aocyborg() 
{
	if not(autocvar_g_monster_aocyborg) 
	{
		remove(self);
		return;
	}
	
	aocyborg_precache_growls();
	aocyborg_precache_weapons();
	
	self.monster_spawnfunc = spawnfunc_monster_aocyborg;
	
	if (self.ammount) {
		//Do nothing, we have all these things set allready, We are probably respawning
	} else {
		self.scale = 1.2;
		self.ammount = 1;
		if (random() > 0.45)
			self.scale = self.scale + (random()*1);
		else 
			self.scale = self.scale + (random()*1.4);
	}
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "AO:Cyborg",
			 "models/monsters/ao_robot_lod0.iqm",
			 AOCYBORG_MIN, AOCYBORG_MAX,
			 FALSE,
			 aocyborg_die, aocyborg_spawn))
	{
		remove(self);
		return;
	}
}
