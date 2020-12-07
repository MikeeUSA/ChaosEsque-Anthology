/**
 * Special purpose fields:
 * .delay - time at which to check if police's enemy is still in range
 * .enemy - enemy of this police
 * .state - state of the police, see POLICE_STATE_*
 */
 
// cvars
float autocvar_g_monster_police;
float autocvar_g_monster_police_stopspeed;
float autocvar_g_monster_police_attack_leap_damage;
float autocvar_g_monster_police_attack_leap_delay;
float autocvar_g_monster_police_attack_leap_force;
float autocvar_g_monster_police_attack_leap_range;
float autocvar_g_monster_police_attack_leap_speed;
float autocvar_g_monster_police_attack_stand_damage;
float autocvar_g_monster_police_attack_stand_delay;
float autocvar_g_monster_police_attack_stand_range;
float autocvar_g_monster_police_health;
float autocvar_g_monster_police_idle_timer;
float autocvar_g_monster_police_speed_walk;
float autocvar_g_monster_police_speed_run;
float autocvar_g_monster_police_target_recheck_delay;
float autocvar_g_monster_police_target_range;
float autocvar_g_monster_police_amnt;
float autocvar_g_monster_police_burn_amnt;
float autocvar_g_monster_police_dark_amnt;

// police animations
#define police_anim_attackleap		 0
#define police_anim_attackrun1		 1
#define police_anim_attackrun2		 2
#define police_anim_attackrun3		 3
#define police_anim_attackstanding1	4
#define police_anim_attackstanding2	5
#define police_anim_attackstanding3	6
#define police_anim_blockend		   7
#define police_anim_blockstart		 8
#define police_anim_deathback1		 9
#define police_anim_deathback2		 10
#define police_anim_deathback3		 11
#define police_anim_deathfront1		12
#define police_anim_deathfront2		13
#define police_anim_deathfront3		14
#define police_anim_deathleft1		 15
#define police_anim_deathleft2		 16
#define police_anim_deathright1		17
#define police_anim_deathright2		18
#define police_anim_idle			   19
#define police_anim_painback1		  20
#define police_anim_painback2		  21
#define police_anim_painfront1		 22
#define police_anim_painfront2		 23
#define police_anim_runbackwards	   24
#define police_anim_runbackwardsleft   25
#define police_anim_runbackwardsright  26
#define police_anim_runforward		 27
#define police_anim_runforwardleft	 28
#define police_anim_runforwardright	29
#define police_anim_spawn			  30
#define police_anim_deadback1			  31
#define police_anim_deadfront1			  32
#define police_anim_stone			  33
#define police_anim_attackcrossbow	1


const vector POLICE_MIN				 = '-8 -8 0';
const vector POLICE_MAX				 = '8 8 68';

const vector POLICE_DEAD_MIN				 = '-10 -10 0';
const vector POLICE_DEAD_MAX				 = '10 10 45';

#define POLICE_STATE_SPAWNING		0
#define POLICE_STATE_IDLE			1
#define POLICE_STATE_ANGRY			2
#define POLICE_STATE_ATTACK_LEAP	3

void police_spawn();
void spawnfunc_monster_police();
void police_think();

void police_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = police_anim_stone; else self.frame = police_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void police_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = police_anim_stone; else self.frame = police_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void police_die ()
{
	placeraiseundeadmarker(self, 0); //For humans: Set a marker down so raiseundead spell can find death spot

	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("police");
	
	self.stat_bangflash = 0;
	self.stat_nukeflash = 0;
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, POLICE_DEAD_MIN, POLICE_DEAD_MAX);
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
	//Since we have firearms, but no future or heavier weapons we're a moderngun weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (autocvar_g_monsters_dropweapon_moderngun) {
		if (autocvar_g_monsters_dropweapon_moderngun >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_moderngun > random())
		{
				monsterdropweapon = 1;
		}
	}
	if (monsterdropweapon && self.weaponentity.count) {
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weaponentity.count == 1) {
			W_ThrowNewWeapon(self, WEP_AXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_AXE, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_CLAWHAMMER, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CLAWHAMMER, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 3) {
			W_ThrowNewWeapon(self, WEP_CROWBAR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CROWBAR, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 4) {
			W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CARBINE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CARBINE, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 6) {
			W_ThrowNewWeapon(self, WEP_UZI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_UZI, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 7) {
			W_ThrowNewWeapon(self, WEP_LRR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LRR, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 8) {
			W_ThrowNewWeapon(self, WEP_PUMPSHOTGUN, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_PUMPSHOTGUN, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 9) {
			W_ThrowNewWeapon(self, WEP_SHOTGUN, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHOTGUN, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 10) {
			W_ThrowNewWeapon(self, WEP_SHOTGUNAUTOMAT, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHOTGUNAUTOMAT, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_PISTOL, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_PISTOL, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		
		} else if (self.weaponentity.count == 12) {
			W_ThrowNewWeapon(self, WEP_HMG, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_HMG, 0, self.origin + '0 0 32', randomvec() * 25 + self.velocity);
		}
	}
	
	
	if (random() > 0.5) {
		self.think = police_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = police_anim_stone; else self.frame = police_anim_deathback1;
	} else {
		self.think = police_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = police_anim_stone; else self.frame = police_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

void police_check_torch()
{
	if (self.torch_lit == 1) {
		if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
			setmodel(self.weaponentity,  "models/weapons/v_torch.md3");
			self.torch_lit = 0;
		}
	} else {
		if not ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
			setmodel(self.weaponentity,  "models/weapons/v_torch_lit.md3");
			self.torch_lit = 1;
		}
	}
}

float police_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_axe_primary_refire;
	} else if (self.weaponentity.count == 2) {
		return autocvar_g_balance_clawhammer_primary_refire;
	} else if (self.weaponentity.count == 3) {
		return autocvar_g_balance_crowbar_primary_refire;
	} else if (self.weaponentity.count == 4) {
		return autocvar_g_balance_torch_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_carbine_sustained_refire;
	} else if (self.weaponentity.count == 6) {
		return autocvar_g_balance_uzi_sustained_refire;
	} else if (self.weaponentity.count == 7) {
		return (autocvar_g_balance_lrr_primary_refire * 2.5);
	} else if (self.weaponentity.count == 8) {
		return autocvar_g_balance_pumpshotgun_primary_refire;
	} else if (self.weaponentity.count == 9) {
		return autocvar_g_balance_shotgun_primary_refire;
	} else if (self.weaponentity.count == 10) {
		return autocvar_g_balance_shotgunautomat_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_pistol_primary_refire;
	} else if (self.weaponentity.count == 12) {
		return autocvar_g_balance_hmg_sustained_refire;
	} else {
		return autocvar_g_monster_police_attack_stand_delay;
	}
}

vector police_style_aiming (entity mymonster)
{
	local vector angles_face = '0 0 0';
	local vector myenemyorg;
	myenemyorg = mymonster.enemy.origin;
	//Simple aiming of weapon entity so W_SetupShot will be correct when called
	//Police shoot from their head area to players head area by default, here's to mix it up:
	if (mymonster.enemy.crouch) {
		myenemyorg_z = myenemyorg_z - 20;
		if (random() > 0.5) myenemyorg_z = myenemyorg_z - (49*random());
	} else {
		if (random() > 0.5) myenemyorg_z = myenemyorg_z - (69*random());
	}
		
	angles_face = vectoangles(myenemyorg - mymonster.origin);
	angles_face_x = angles_face_x * -1; //Inverted pitch for models (vs world), Quake Legacy
	
	//print(vtos(mymonster.v_angle), "\n Vangles");
	
	return(angles_face);
}

void police_attack_hmg()
{
	float hmg_spread;
	
	W_SetupShot (self, autocvar_g_antilag_bullets && autocvar_g_balance_hmg_speed >= autocvar_g_antilag_bullets, 0, "weapons/campingrifle_fire2.wav", CH_WEAPON_A, autocvar_g_balance_hmg_sustained_damage);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	hmg_spread = bound(autocvar_g_balance_hmg_spread_min, autocvar_g_balance_hmg_spread_min + (autocvar_g_balance_hmg_spread_add * self.misc_bulletcounter), autocvar_g_balance_hmg_spread_max);
	fireBallisticBullet(w_shotorg, w_shotdir, hmg_spread, autocvar_g_balance_hmg_speed, 5, autocvar_g_balance_hmg_sustained_damage, autocvar_g_balance_hmg_sustained_headshotaddeddamage, autocvar_g_balance_hmg_sustained_force, WEP_HMG, PROJECTILE_BULLETRIFLE9MM, 1, autocvar_g_balance_hmg_bulletconstant, autocvar_g_balance_hmg_sustained_coreshotaddeddamage);
	endFireBallisticBullet();

	self.misc_bulletcounter = self.misc_bulletcounter + 1;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	UziFlash();
	W_AttachToShotorg(self.muzzle_flash, '5 0 0');
	
	PlayerGunRise(self, autocvar_g_balance_hmg_gunrise, random() * autocvar_g_balance_hmg_gunrun);

	if (autocvar_g_casings >= 2) // casing code
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * 5 - 70) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 105, self);

}

float police_attack_armed()
{
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	
	if (self.enemy != world) {
		self.weaponentity.v_angle = police_style_aiming (self);
		makevectors(self.weaponentity.v_angle);
	}
	
	self.ammount = 0; //Used here to keep track if we should just keep firing
	
	if (self.weaponentity.count == 1) {
		W_Axe_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_ClawHammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_Crowbarspiked_Attack();
	} else if (self.weaponentity.count == 4) {
		W_Torch_Attack();
	} else if (self.weaponentity.count == 5) {
		//w_shotorg = self.origin + '0 0 64';
		self.carbine_jammed = 0;
		W_CARBINE_Attack(WEP_CARBINE);
		self.delay = time + 0.1;
		if (random() > 0.5) self.ammount = 1;
	} else if (self.weaponentity.count == 6) {
		self.uzi_jammed = 0;
		W_UZI_Attack(WEP_UZI);
		self.delay = time + 0.1;
		if (random() > 0.2) self.ammount = 1;
	} else if (self.weaponentity.count == 7) {
		self.lrr_jammed = 0;
		W_LRR_Attack();
		self.delay = time + 0.1;
	} else if (self.weaponentity.count == 8) {
		self.pumpshotgun_jammed = 0;
		W_PumpShotgun_Attack();
		self.delay = time + 0.1;
	} else if (self.weaponentity.count == 9) {
		self.shotgun_jammed = 0;
		W_Shotgun_Attack();
		self.delay = time + 0.1;
	} else if (self.weaponentity.count == 10) {
		self.shotgunautomat_jammed = 0;
		W_ShotgunAutomat_Attack();
		self.delay = time + 0.1;
		if (random() > 0.35) self.ammount = 1;
	} else if (self.weaponentity.count == 11) {
		self.pistol_jammed = 0;
		W_Pistol_Attack();
		self.delay = time + 0.1;
	} else if (self.weaponentity.count == 12) {
		self.hmg_jammed = 0;
		police_attack_hmg();
		self.delay = time + 0.1;
		if (random() > 0.1) self.ammount = 1;	
	}
	
	return police_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void police_attack_standing()
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
	
	bigdmg = autocvar_g_monster_police_attack_stand_damage * self.scale;

	//print("police attacks!\n");
	makevectors (self.angles);
	
	if ((self.weaponentity.count && random() > 0.01) || (self.weaponentity.count >= 5)) {
		myrefire = police_attack_armed();
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_police_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = police_anim_stone;
	} else {
		if (self.weaponentity.count >= 5)
			self.frame = police_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = police_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = police_anim_attackstanding2;
		else
			self.frame = police_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.4);
	else
		self.nextthink = time + myrefire;
}


void police_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_police_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_police_attack_leap_force;
	
	if ((self.weaponentity.count && random() > 0.01) || (self.weaponentity.count >= 5)) {
		police_attack_armed();
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy police's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void police_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = police_attack_refire();
	else
		myrefire = autocvar_g_monster_police_attack_leap_delay;

	// face the enemy	
	self.state = POLICE_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = police_anim_stone; else self.frame = police_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = police_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_police_attack_leap_speed;
}

/**
 * Main police think function.
 */
void police_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	float nostoptofire;
	float ksrandom;
	
	if (self.skin == 1) {
		//Anti-terror
		nostoptofire = 0.4;
		ksrandom = 0.5;
	} else if (self.skin == 2) {
		//Juggernaut
		nostoptofire = 0.15;
		ksrandom = 0;
	} else {
		nostoptofire = 0.5;
		ksrandom = 0.75;
	}
	
	if (self.stoned || self.frozen)
		self.frame = police_anim_stone;
	
	if (self.weaponentity && self.weaponentity.count == 4)
		police_check_torch();
	
	self.think = police_think;
	
	if (self.state == POLICE_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = POLICE_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == POLICE_STATE_SPAWNING) {
		// become idle when police spawned
		if (self.stoned || self.frozen) self.frame = police_anim_stone; else self.frame = police_anim_idle;
		self.state = POLICE_STATE_IDLE;
	}
	
	if(self.enemy && !monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stat_bangflash > 99)
		self.enemy = world;
		
	if (self.stat_nukeflash > 99)
		self.enemy = world;
	
	if (self.enemy)
	if (self.enemy.team == self.team || self.monster_owner == self.enemy)
		self.enemy = world;
	
	if(teamplay && autocvar_g_monsters_teams && self.monster_owner.team != self.team)
		self.monster_owner = world;	
	
	// remove enemy that ran away
	if (self.enemy)
	if (self.delay <= time) // check if we can do the rescan now
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_police_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_police_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_police_target_recheck_delay;
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks
	
	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_axe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 2)
			mystandattackrange = autocvar_g_balance_clawhammer_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 3)
			mystandattackrange = autocvar_g_balance_crowbar_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 4)
			mystandattackrange = autocvar_g_balance_torch_primary_melee_range * 0.94;
		//else if (self.weaponentity.count >= 5)
		//	mystandattackrange = autocvar_g_monster_police_target_range * 1.5;
		else
			mystandattackrange = autocvar_g_monster_police_attack_stand_range * self.scale;
		
		// make sure police is angry
		self.state = POLICE_STATE_ANGRY;
		

		// this police has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count >= 5)
		if (enemyDistance <= autocvar_g_monster_police_target_range * 1.5)
		{
			if (random() > nostoptofire) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20; //Set to force firing below
				enemyDistance = autocvar_g_monster_police_attack_stand_range;
			}
		}
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (self.ammount) {
			//Here .ammount is used to see if, when the police has an automatic weapon
			//he should keep firing
			if (!self.frozen)
			if (!self.stoned)
			{
				//print("Police Ammount\n");
				police_attack_standing();
				//We aren't finished...
			}
		} else {
			if (!self.frozen)
			if (!self.stoned)
			if (self.stat_bangflash < 99)
			if (self.stat_nukeflash < 99)
			if (trace_ent == self.enemy)
			if (self.enemy.deadflag == DEAD_NO)
			if (mySpeed <= 30)
				if (enemyDistance <= mystandattackrange) 
				{
					//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
					police_attack_standing();
					if (random() > ksrandom) finished = 2;
					else finished = TRUE;
				} 
				else if (enemyDistance <= autocvar_g_monster_police_attack_leap_range * self.scale) 
				{
					// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
					police_attack_leap();
					if (random() > ksrandom) finished = 2;
					else finished = TRUE;
				}
		}
		
	}
	
	if (!finished || finished == 2) 
	{
		monster_move(monster_mvmntimpare_human(autocvar_g_monster_police_speed_run), monster_mvmntimpare_human(autocvar_g_monster_police_speed_walk), autocvar_g_monster_police_stopspeed, police_anim_runforward, police_anim_runforward, police_anim_idle);
		
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
		//print("police is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = police_anim_stone; else self.frame = ((mySpeed <= 20) ? police_anim_idle : police_anim_runforward);
		self.nextthink = time + autocvar_g_monster_police_idle_timer * random();	
	}
}

/**
 * Spawn the police.
 */
void police_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_police_health * self.scale;
	
	self.classname			= "monster_police";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= POLICE_STATE_SPAWNING;
	self.frame		  		= police_anim_spawn;
	self.think		  		= police_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	self.vuln_movement_imparable = 1; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	
	self.sex = SEX_MALE;
	
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	
	self.scale = self.scale + ((random()-0.25)*0.2);
	
	if (self.scale) self.view_ofs = '0 0 60' * self.scale;
	else self.view_ofs = '0 0 60';
	
	self.items &~= IT_UNLIMITED_WEAPON_AMMO;
	
	//self.skin 				= rint(random() * 3);
	
		//Selecting the type by Ratio
		srandvar = random() *
		(autocvar_g_monster_police_amnt
		+ autocvar_g_monster_police_burn_amnt
		+ autocvar_g_monster_police_dark_amnt);

		if (srandvar < autocvar_g_monster_police_amnt) {
			self.skin = 0;
		} else if (srandvar < (
		autocvar_g_monster_police_amnt
		+ autocvar_g_monster_police_burn_amnt
		)) {
			self.skin = 1;
		} else if (srandvar < (
		autocvar_g_monster_police_amnt
		+ autocvar_g_monster_police_burn_amnt
		+ autocvar_g_monster_police_dark_amnt
		)) {
			self.skin = 2;
		} else {
			self.skin = 0;
		}
	
	self.resist_ice = 0.5;
	
	if (self.skin == 1)
	{	
		self.resist_bullet = 0.85; //Bulletproof armor
		self.resist_fire = 0.75;
		self.health = self.health + 150;
	}
		
	if (self.skin == 2)
	{
		self.resist_bullet = 0.99; //Bulletproof armor Juggarnaught
		self.resist_edged = 0.5;
		self.resist_energy = 0.33;
		self.resist_electricity = 0.5;
		self.resist_ice = 0.75;
		self.resist_fire = 0.65;
		self.resist_pierce = 0.2;
		self.resist_explode = 0.60;
		self.health = self.health + 350;
	}
	//print(ftos(self.health),"\n");
	
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
		float skipskinrandwep;
		skipskinrandwep = 0;
		wrand = random();
		
		self.weaponentity.alpha = 1;
		self.weaponentity.angles    = '180 -45 90';
		
		if (self.skin == 2)
		{
			if (wrand > 0.80) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shotgunautomat.md3");
				self.weaponentity.count = 10;
			} else if (wrand > 0.50) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_hmg.md3");
				self.weaponentity.count = 12;
			} else if (wrand > 0.35) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pumpshotgun.md3");
				self.weaponentity.count = 8;
			} else if (wrand > 0.20) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shotgun.md3");
				self.weaponentity.count = 9;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		}
		else if (self.skin == 1)
		{
			if (wrand > 0.80) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_mac10_unsuppressed.md3");
				self.weaponentity.count = 6;
				self.weaponentity.angles    = '90 80 180';
			} else if (wrand > 0.50) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_uzi.md3");
				self.weaponentity.count = 5;
			} else if (wrand > 0.30) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_campingrifle.md3");
				self.weaponentity.count = 7;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		}
		else if (self.skin == 0)
		{
			if (wrand > 0.80) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_uzi.md3");
				self.weaponentity.count = 5;
			} else if (wrand > 0.60) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pumpshotgun.md3");
				self.weaponentity.count = 8;
			} else if (wrand > 0.40) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pistol.md3");
				self.weaponentity.count = 11;
			} else {
				skipskinrandwep = 1;
				wrand = random();
			}
		} else {
			skipskinrandwep = 1;
		}
		
		
		if (skipskinrandwep == 1) {
			if (wrand > 0.99) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_axe.md3");
				self.weaponentity.count = 1;
			} else if (wrand > 0.98) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_clawhammer.md3");
				self.weaponentity.count = 2;
			} else if (wrand > 0.97) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crowbar.md3");
				self.weaponentity.count = 3;	
			} else if (wrand > 0.95) {
				if (autocvar_g_monsters_jitprecacheonly) {
					precache_model ("models/weapons/v_torch_lit.md3");
					precache_model ("models/weapons/v_torch.md3");
				}
				police_check_torch();
				self.weaponentity.count = 4;
			} else if (wrand > 0.70) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_mac10_unsuppressed.md3");
				self.weaponentity.count = 6;
				self.weaponentity.angles    = '90 80 180';
			} else if (wrand > 0.50) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_campingrifle.md3");
				self.weaponentity.count = 7;
			} else if (wrand > 0.35) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pumpshotgun.md3");
				self.weaponentity.count = 8;
			} else if (wrand > 0.25) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shotgun.md3");
				self.weaponentity.count = 9;
			} else if (wrand > 0.15) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shotgunautomat.md3");
				self.weaponentity.count = 10;
			} else if (wrand > 0.10) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pistol.md3");
				self.weaponentity.count = 11;		
			} else {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_uzi.md3");
				self.weaponentity.count = 5;
			}
		}
		
		if (self.weaponentity.count >= 5) self.weaponentity.angles    = '90 0 -90';
		
		
		setattachment(self.weaponentity, self, "Weapon");
		//setorigin(self.weaponentity, '2.1 6 -1');    // Move attch spot up 8// forward 4// yes fscked up bone  

		wrand = random();
		if (wrand > 0.8)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			self.bomb1.origin = self.weaponentity.origin;
			setmodel(self.bomb1,  self.bomb1.model);
			setorigin(self.bomb1,  self.bomb1.origin);
			
			if (self.weaponentity.count >= 5)
				self.bomb1.angles    = '0 110 0';
			else
				self.bomb1.angles    = '-45 60 50';
			
			setattachment(self.bomb1, self, "Palm.l");
		}
		
		//Head Ornament
		wrand = random();
		if (wrand > 0.95)
		{
			self.bomb2.alpha = 1;
			setmodel(self.bomb2,  "models/misc/playerspikes_head.iqm");
			self.bomb2.angles    = '0 0 -90';
			setattachment(self.bomb2, self, "Head");
			setorigin(self.bomb2, '0 8 -2');    // Move attch spot up 8// back 2// yes fscked up bone  
			self.health = self.health * 1.25;
			self.armorvalue = g_pickup_armormedium;
		}
	}
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

void police_precache_weapons()
{
	if (autocvar_g_monsters_jitprecacheonly <= 0) {
		precache_model ("models/weapons/v_axe.md3");
		precache_model ("models/weapons/v_clawhammer.md3");
		precache_model ("models/weapons/v_crowbar.md3");
		precache_model ("models/weapons/v_mac10_unsuppressed.md3");
		precache_model ("models/weapons/v_campingrifle.md3");
		precache_model ("models/weapons/v_pumpshotgun.md3");
		precache_model ("models/weapons/v_shotgun.md3");
		precache_model ("models/weapons/v_shotgunautomat.md3");
		precache_model ("models/weapons/v_pistol.md3");
		precache_model ("models/weapons/v_uzi.md3");
	}
	
	if (autocvar_g_monsters_jitprecacheonly <= 1) {
	precache_model ("models/misc/playerspikes_head.iqm");	
	}
}

/*QUAKED monster_police (1 0 0) (-18 -18 -25) (18 18 47)
Police, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 police entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/police.dpm"
*/
void spawnfunc_monster_police() 
{
	if not(autocvar_g_monster_police) 
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_police;
	precache_model ("models/weapons/v_crowbar.md3");
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	if not (monster_initialize(
			 "Police",
			 "models/monsters/police.iqm",
			 POLICE_MIN, POLICE_MAX,
			 FALSE,
			 police_die, police_spawn))
	{
		remove(self);
		return;
	}
}
