/**
 * Special purpose fields:
 * .delay - time at which to check if skeleton's enemy is still in range
 * .enemy - enemy of this skeleton
 * .state - state of the skeleton, see SKELETON_STATE_*
 */
 
// cvars
float autocvar_g_monster_skeleton;
float autocvar_g_monster_skeleton_stopspeed;
float autocvar_g_monster_skeleton_attack_leap_damage;
float autocvar_g_monster_skeleton_attack_leap_delay;
float autocvar_g_monster_skeleton_attack_leap_force;
float autocvar_g_monster_skeleton_attack_leap_range;
float autocvar_g_monster_skeleton_attack_leap_speed;
float autocvar_g_monster_skeleton_attack_stand_damage;
float autocvar_g_monster_skeleton_attack_stand_delay;
float autocvar_g_monster_skeleton_attack_stand_range;
float autocvar_g_monster_skeleton_health;
float autocvar_g_monster_skeleton_idle_timer;
float autocvar_g_monster_skeleton_speed_walk;
float autocvar_g_monster_skeleton_speed_run;
float autocvar_g_monster_skeleton_target_recheck_delay;
float autocvar_g_monster_skeleton_target_range;
float autocvar_g_monster_skeleton_amnt;
float autocvar_g_monster_skeleton_burn_amnt;
float autocvar_g_monster_skeleton_dark_amnt;
float autocvar_g_monster_skeleton_nocolormod;
float autocvar_g_monster_skeleton_noeffects;

float autocvar_g_monster_skeleton_burn_burningbolt;
float autocvar_g_monster_skeleton_burn_burningbolt_shoot;

// skeleton animations
#define skeleton_anim_attackleap		 0
#define skeleton_anim_attackrun1		 1
#define skeleton_anim_attackrun2		 2
#define skeleton_anim_attackrun3		 3
#define skeleton_anim_attackstanding1	4
#define skeleton_anim_attackstanding2	5
#define skeleton_anim_attackstanding3	6
#define skeleton_anim_blockend		   7
#define skeleton_anim_blockstart		 8
#define skeleton_anim_deathback1		 9
#define skeleton_anim_deathback2		 10
#define skeleton_anim_deathback3		 11
#define skeleton_anim_deathfront1		12
#define skeleton_anim_deathfront2		13
#define skeleton_anim_deathfront3		14
#define skeleton_anim_deathleft1		 15
#define skeleton_anim_deathleft2		 16
#define skeleton_anim_deathright1		17
#define skeleton_anim_deathright2		18
#define skeleton_anim_idle			   19
#define skeleton_anim_painback1		  20
#define skeleton_anim_painback2		  21
#define skeleton_anim_painfront1		 22
#define skeleton_anim_painfront2		 23
#define skeleton_anim_runbackwards	   24
#define skeleton_anim_runbackwardsleft   25
#define skeleton_anim_runbackwardsright  26
#define skeleton_anim_runforward		 27
#define skeleton_anim_runforwardleft	 28
#define skeleton_anim_runforwardright	29
#define skeleton_anim_spawn			  30
#define skeleton_anim_deadback1			  31
#define skeleton_anim_deadfront1			  32
#define skeleton_anim_stone			  33
#define skeleton_anim_attackcrossbow	34


const vector SKELETON_MIN				 = '-10 -10 -25';
const vector SKELETON_MAX				 = '10 10 47';

const vector SKELETON_DEAD_MIN				 = '-18 -18 20';
const vector SKELETON_DEAD_MAX				 = '18 18 45';

#define SKELETON_STATE_SPAWNING		0
#define SKELETON_STATE_IDLE			1
#define SKELETON_STATE_ANGRY			2
#define SKELETON_STATE_ATTACK_LEAP	3

void skeleton_spawn();
void spawnfunc_monster_skeleton();
void skeleton_think();

void skeleton_deathback ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_deadback1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void skeleton_deathfront ()
{
	if (self.stoned || (self.frozen == 1)) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_deadfront1;
	self.think			= Monster_Fade;
	self.nextthink	  	= time + (autocvar_g_monsters_fade_delay * 0.9);
}

void skeleton_die ()
{
	if (!self.monster_noitemdrop) Monster_CheckDropCvars ("skeleton");
	
	self.monster_buringbolt = 0; //Reset
	self.solid		  	= SOLID_NOT;
	//Rather than standard DAMAGE_NO and event_damage func_null, we'll do a gibdamage routine
	//So no changing takedamage and we set event_damage to something other than func_null
	self.event_damage   = monsters_gibdamage;
	self.enemy		  	= world;
	self.movetype		= MOVETYPE_TOSS;
	setsize (self, SKELETON_DEAD_MIN, SKELETON_DEAD_MAX);
	tracebox(self.origin + '1 0 0', self.mins, self.maxs, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
	setorigin(self, trace_endpos);
	//We set think below to load the deadbody "animation", then fade
	self.nextthink	  	= time + 0.5;
	self.pain_finished  = self.nextthink;
	
	if (self.weaponentity.count)
		SUB_SetFade(self.weaponentity, time + 2, 1);
	if (self.bomb1.count)
		SUB_SetFade(self.bomb1, time + 2, 1);
	
	//print(ftos(self.weaponentity.count), "wepcnt\n");
	//If we're allowed to drop a weapon we shall.
	//Since we have only medieval we're a medieval weapons monster
	//Thus we use that cvar
	local float monsterdropweapon;
	monsterdropweapon = 0;
	if (autocvar_g_monsters_dropweapon_medieval) {
		//print(ftos(self.weaponentity.count), "here1\n");
		if (autocvar_g_monsters_dropweapon_medieval >= 1) {
			monsterdropweapon = 1;
		} else if (autocvar_g_monsters_dropweapon_medieval > random())
		{
				monsterdropweapon = 1;
		}
	}
	if (monsterdropweapon && self.weaponentity.count) {
		//print(ftos(self.weaponentity.count), "here2\n");
		self.weaponentity.alpha = -1;
		if (self.bomb1.count) self.bomb1.alpha = -1;
		
		if (self.weaponentity.count == 1) {
			W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BROADAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 2) {
			W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_WARHAMMERSPIKED, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 3) {
			W_ThrowNewWeapon(self, WEP_SHORTSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHORTSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 4) {
			W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TORCH, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 5) {
			W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CROSSBOWDTWR, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 6) {
			W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LONGSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 7) {
			W_ThrowNewWeapon(self, WEP_KATANA, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_KATANA, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 8) {
			W_ThrowNewWeapon(self, WEP_ODACHI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_ODACHI, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 9) {
			W_ThrowNewWeapon(self, WEP_NAGAMAKI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_NAGAMAKI, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 10) {
			W_ThrowNewWeapon(self, WEP_TETSUBO, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TETSUBO, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 11) {
			W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_LIGHTCROSSBOW, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 12) {
			W_ThrowNewWeapon(self, WEP_IRONCROW, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_IRONCROW, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 13) {
			W_ThrowNewWeapon(self, WEP_SCIMITAR, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SCIMITAR, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 14) {
			W_ThrowNewWeapon(self, WEP_BASTARDSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BASTARDSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 15) {
			W_ThrowNewWeapon(self, WEP_SPIKEDFLAIL, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SPIKEDFLAIL, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 16) {
			W_ThrowNewWeapon(self, WEP_MILFLAIL, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_MILFLAIL, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 17) {
			W_ThrowNewWeapon(self, WEP_BATTLEAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BATTLEAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 18) {
			W_ThrowNewWeapon(self, WEP_KRIEGSHAMMER, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_KRIEGSHAMMER, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 19) {
			W_ThrowNewWeapon(self, WEP_QUARTERSTAFF, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_QUARTERSTAFF, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 20) {
			W_ThrowNewWeapon(self, WEP_SAI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SAI, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 21) {
			W_ThrowNewWeapon(self, WEP_DADAO, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_DADAO, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 22) {
			W_ThrowNewWeapon(self, WEP_SKIRMISHERSAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SKIRMISHERSAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 23) {
			W_ThrowNewWeapon(self, WEP_BARDICHE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_BARDICHE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 24) {
			W_ThrowNewWeapon(self, WEP_TEMPLARAXE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_TEMPLARAXE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 25) {
			W_ThrowNewWeapon(self, WEP_ARMINGSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_ARMINGSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 26) {
			W_ThrowNewWeapon(self, WEP_CRUSADERSWORD, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CRUSADERSWORD, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 27) {
			W_ThrowNewWeapon(self, WEP_CLAYMORE, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_CLAYMORE, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 28) {
			W_ThrowNewWeapon(self, WEP_SHIRASAYA, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_SHIRASAYA, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 29) {
			W_ThrowNewWeapon(self, WEP_ZATOICHI, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_ZATOICHI, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		} else if (self.weaponentity.count == 30) {
			W_ThrowNewWeapon(self, WEP_PUDAO, 0, self.origin + '0 0 32', self.velocity);
			if (self.bomb1.count) W_ThrowNewWeapon(self, WEP_PUDAO, 0, self.origin + '0 0 32', randomvec() * 225 + self.velocity);
		
		}
	}
	
	
	if (random() > 0.5) {
		self.think = skeleton_deathback;
		if (self.stoned || (self.frozen == 1)) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_deathback1;
	} else {
		self.think = skeleton_deathfront;
		if (self.stoned || (self.frozen == 1)) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_deathfront1;
	}
	

	monster_hook_death(); // for post-death mods
}

void skeleton_check_torch()
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

float skeleton_attack_refire()
{
	if (self.weaponentity.count == 1) {
		return autocvar_g_balance_broadaxe_primary_refire;
	} else if (self.weaponentity.count == 2) {
		return autocvar_g_balance_warhammerspiked_primary_refire;
	} else if (self.weaponentity.count == 3) {
		return autocvar_g_balance_shortsword_primary_refire;
	} else if (self.weaponentity.count == 4) {
		return autocvar_g_balance_torch_primary_refire;
	} else if (self.weaponentity.count == 5) {
		return autocvar_g_balance_crossbowdtwr_primary_refire;
	} else if (self.weaponentity.count == 6) {
		return autocvar_g_balance_longsword_primary_refire;
	} else if (self.weaponentity.count == 7) {
		return autocvar_g_balance_katana_primary_refire;
	} else if (self.weaponentity.count == 8) {
		return autocvar_g_balance_odachi_primary_refire;
	} else if (self.weaponentity.count == 9) {
		return autocvar_g_balance_nagamaki_primary_refire;
	} else if (self.weaponentity.count == 10) {
		return autocvar_g_balance_tetsubo_primary_refire;
	} else if (self.weaponentity.count == 11) {
		return autocvar_g_balance_lightcrossbow_primary_refire;
	} else if (self.weaponentity.count == 12) {
		return autocvar_g_balance_ironcrow_primary_refire;
	} else if (self.weaponentity.count == 13) {
		return autocvar_g_balance_scimitar_primary_refire;
	} else if (self.weaponentity.count == 14) {
		return autocvar_g_balance_bastardsword_primary_refire;
	} else if (self.weaponentity.count == 15) {
		return autocvar_g_balance_spikedflail_primary_refire;
	} else if (self.weaponentity.count == 16) {
		return autocvar_g_balance_milflail_primary_refire;
	} else if (self.weaponentity.count == 17) {
		return autocvar_g_balance_battleaxe_primary_refire;
	} else if (self.weaponentity.count == 18) {
		return autocvar_g_balance_kriegshammer_primary_refire;
	} else if (self.weaponentity.count == 19) {
		return autocvar_g_balance_quarterstaff_primary_refire;
	} else if (self.weaponentity.count == 20) {
		return autocvar_g_balance_sai_primary_refire;
	} else if (self.weaponentity.count == 21) {
		return autocvar_g_balance_dadao_primary_refire;
	} else if (self.weaponentity.count == 22) {
		return autocvar_g_balance_skirmishersaxe_primary_refire;
	} else if (self.weaponentity.count == 23) {
		return autocvar_g_balance_bardiche_secondary_refire;
	} else if (self.weaponentity.count == 24) {
		return autocvar_g_balance_templaraxe_primary_refire;
	} else if (self.weaponentity.count == 25) {
		return autocvar_g_balance_armingsword_primary_refire;
	} else if (self.weaponentity.count == 26) {
		return autocvar_g_balance_crusadersword_primary_refire;
	} else if (self.weaponentity.count == 27) {
		return autocvar_g_balance_claymore_primary_refire;
	} else if (self.weaponentity.count == 28) {
		return autocvar_g_balance_katana_primary_refire; //Sameas
	} else if (self.weaponentity.count == 29) {
		return autocvar_g_balance_katana_primary_refire; //Sameas
	} else if (self.weaponentity.count == 30) {
		return autocvar_g_balance_pudao_primary_refire;
	} else {
		return autocvar_g_monster_skeleton_attack_stand_delay;
	}
}

float skeleton_style_aiming (entity mymonster, float myprojectilespeed, float myconstant)
{
	//This is in no way perfect, it isn't very accurate, your monsters won't be sharpshooters
	//The further away they are the more they'll miss
	local vector angles_face = '0 0 0';
	local float angles_addx;
	local float returnanglex;
	//Returns what mymonster's v_angle_x (up/down)
	//should be, in the opinion of a skeleton
	//Myconstant can be positive, we *-1 below, in the realm of 15 is usually good
	
	//Here we try to face the correct direction up/down
	angles_face = vectoangles(mymonster.enemy.origin - mymonster.origin);
	returnanglex = angles_face_x * -1;
	//print(vtos(mymonster.v_angle), "\n Vangles");
	
	//Here we try to deal with gravity
	//Note: Skeleton style "aiming", won't be correct for lowgrav
	angles_addx = (myconstant * -1)*(vlen(mymonster.enemy.origin - mymonster.origin) / myprojectilespeed);
	angles_addx = bound(-45, angles_addx, 0);
	returnanglex = returnanglex + angles_addx;
	
	return(returnanglex);
}

float skeleton_attack_armed()
{
	//Do the attack, return the refire time for that weap.
	self.v_angle = self.angles; //print(vtos(self.v_angle)," vangle\n");
	if (self.weaponentity.count == 1) {
		W_BroadAxe_Attack(); 
	} else if (self.weaponentity.count == 2) {
		W_Warhammerspiked_Attack();
	} else if (self.weaponentity.count == 3) {
		W_ShortSwordspiked_Attack();
	} else if (self.weaponentity.count == 4) {
		W_Torch_Attack();
	} else if (self.weaponentity.count == 5) {
		if (self.enemy != world) {
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_crossbowdtwr_primary_speed, 10);
			makevectors(self.v_angle);
		}
		
		if (self.fire_endtime > time) {
			W_CrossbowBolt_Burning_Attack();
		} else if (self.monster_buringbolt == 1) {
			//Burning dead
			if (autocvar_g_monster_skeleton_burn_burningbolt_shoot >= random()) {
				W_CrossbowBolt_Burning_Attack();
			}
		} else {
			W_CrossbowBolt_Attack();
		}
	} else if (self.weaponentity.count == 6) {
		W_LongSwordspiked_Attack();
	} else if (self.weaponentity.count == 7) {
		W_Katanaspiked_Attack();
	} else if (self.weaponentity.count == 8) {
		W_Odachispiked_Attack();
	} else if (self.weaponentity.count == 9) {
		W_Nagamakispiked_Attack();
	} else if (self.weaponentity.count == 10) {
		W_Tetsubospiked_Attack();
	} else if (self.weaponentity.count == 11) {
		if (self.enemy != world) {
			self.v_angle_x = skeleton_style_aiming (self, autocvar_g_balance_lightcrossbow_primary_speed, 15);
			makevectors(self.v_angle);
		}
		
		if (self.fire_endtime > time) {
			W_LightCrossbowBolt_Burning_Attack();
		} else if (self.monster_buringbolt == 1) {
			//Burning dead
			if (autocvar_g_monster_skeleton_burn_burningbolt_shoot >= random()) {
				W_LightCrossbowBolt_Burning_Attack();
			}
		} else {
			W_LightCrossbowBolt_Attack();
		}
	} else if (self.weaponentity.count == 12) {
		W_IronCrowspiked_Attack();
	} else if (self.weaponentity.count == 13) {
		W_Scimitarspiked_Attack();
	} else if (self.weaponentity.count == 14) {
		W_BastardSwordspiked_Attack();
	} else if (self.weaponentity.count == 15) {
		setmodel(self.weaponentity,  "models/weapons/v_spikedflail_swing.md3");
		if (self.bomb1.count) { //2 weapons
			setmodel(self.bomb1,  "models/weapons/v_spikedflail_swing.md3");
		}
		
		self.spikedflail_swinging = 1;
		self.spikedflail_nextatrest = time + autocvar_g_balance_spikedflail_primary_refire;
		W_SpikedFlail_Attack();
	} else if (self.weaponentity.count == 16) {
		setmodel(self.weaponentity,  "models/weapons/v_milflail_swing.md3");
		if (self.bomb1.count) { //2 weapons
			setmodel(self.bomb1,  "models/weapons/v_milflail_swing.md3");
		}
		
		self.milflail_swinging = 1;
		self.milflail_nextatrest = time + autocvar_g_balance_milflail_primary_refire;
		W_MilFlail_Attack();
	} else if (self.weaponentity.count == 17) {
		W_BattleAxe_Attack(); 
	} else if (self.weaponentity.count == 18) {
		W_KriegsHammerspiked_Attack();
	} else if (self.weaponentity.count == 19) {
		W_QuarterStaffspiked_Attack();
	} else if (self.weaponentity.count == 20) {
		W_Saispiked_Attack();
	} else if (self.weaponentity.count == 21) {
		W_Dadaospiked_Attack();
	} else if (self.weaponentity.count == 22) {
		W_SkirmishersAxe_Attack(); 
	} else if (self.weaponentity.count == 23) {
		self.bardiche_secondary = 1;
		W_Bardichespiked_Attack();
	} else if (self.weaponentity.count == 24) {
		W_TemplarAxe_Attack(); 
	} else if (self.weaponentity.count == 25) {
		W_ArmingSwordspiked_Attack();
	} else if (self.weaponentity.count == 26) {
		W_CrusaderSwordspiked_Attack();
	} else if (self.weaponentity.count == 27) {
		W_Claymorespiked_Attack();
	} else if (self.weaponentity.count == 28) {
		W_Shirasayaspiked_Attack();
	} else if (self.weaponentity.count == 29) {
		W_Zatoichispiked_Attack();
	} else if (self.weaponentity.count == 30) {
		W_Pudaospiked_Attack();
	}
	
	return skeleton_attack_refire();
}

/**
 * Perform a standing attack on self.enemy.
 */
void skeleton_attack_standing()
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
	
	bigdmg = autocvar_g_monster_skeleton_attack_stand_damage * self.scale;

	//print("skeleton attacks!\n");
	makevectors (self.angles);
	
	if (self.weaponentity.count) {
		myrefire = skeleton_attack_armed();
	} else {
		dot = normalize (self.enemy.origin - self.origin) * v_forward;
		if(dot > 0.3)
		{
			Damage(self.enemy, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, self.origin, '0 0 0');
		}
		myrefire = autocvar_g_monster_skeleton_attack_stand_delay;
	}
	
	if (!monster_isvalidtarget(self.enemy, self, FALSE, FALSE))
		self.enemy = world;
	
	if (self.stoned || self.frozen) {
		self.frame = skeleton_anim_stone;
	} else {
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
			self.frame = skeleton_anim_attackcrossbow;
		else if (rand < 0.33)
			self.frame = skeleton_anim_attackstanding1;
		else if (rand < 0.66)
			self.frame = skeleton_anim_attackstanding2;
		else
			self.frame = skeleton_anim_attackstanding3;
	}

	if (self.bomb1.count) //2 weapons, Faster
		self.nextthink = time + (myrefire * 0.4);
	else
		self.nextthink = time + myrefire;
}


void skeleton_attack_leap_touch()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0';
	float bigdmg = autocvar_g_monster_skeleton_attack_leap_damage * self.scale;
	
	if (other.deadflag != DEAD_NO)
		return;
		
	if (self.monster_owner == other)
		return;
	
	if (other.takedamage == DAMAGE_NO)
		return;
		
	//void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
	traceline(self.origin, other.origin, FALSE, self);

	angles_face = vectoangles(self.moveto - self.origin);
	angles_face = normalize(angles_face) * autocvar_g_monster_skeleton_attack_leap_force;
	
	if (self.weaponentity.count) {
		skeleton_attack_armed();
	} else {
		Damage(other, self, self, bigdmg * monster_skill, DEATH_MONSTER_MELEE, trace_endpos, angles_face);	
	}
	
	// make this guy skeleton's priority if it wasn't already
	if (other.deadflag == DEAD_NO)
	if (self.enemy != other)
		self.enemy = other;
		
	self.touch = MonsterTouch;
}

void skeleton_attack_leap()
{
	if (self.frozen)
		return;
		
	if (self.stoned)
		return;
		
	vector angles_face = '0 0 0', vel = '0 0 0';
	float myrefire;
	
	if (self.weaponentity)
		myrefire = skeleton_attack_refire();
	else
		myrefire = autocvar_g_monster_skeleton_attack_leap_delay;

	// face the enemy	
	self.state = SKELETON_STATE_ATTACK_LEAP;
	if (self.stoned || self.frozen) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_attackleap;
	angles_face = vectoangles(self.enemy.origin - self.origin);
	self.angles_y = angles_face_y ;
	
	if (self.bomb1.count)
		self.nextthink = time + (myrefire * 0.5);
	else
		self.nextthink = time + myrefire;
	
	self.touch = skeleton_attack_leap_touch;
	makevectors(self.angles);
	vel = normalize(v_forward);
	self.velocity = vel * autocvar_g_monster_skeleton_attack_leap_speed;
}

/**
 * Main skeleton think function.
 */
void skeleton_think()
{
	monster_hook_think();
	
	float finished = FALSE, enemyDistance = 0, mySpeed = 0;
	
	if (self.stoned || self.frozen)
		self.frame = skeleton_anim_stone;
	
	if (self.weaponentity && self.weaponentity.count == 4)
		skeleton_check_torch();
	
	self.think = skeleton_think;
	
	if (self.state == SKELETON_STATE_ATTACK_LEAP) {
		// reset to angry
		self.state = SKELETON_STATE_ANGRY;
		self.touch = func_null;
	}
	
	if (self.state == SKELETON_STATE_SPAWNING) {
		// become idle when skeleton spawned
		if (self.stoned || self.frozen) self.frame = skeleton_anim_stone; else self.frame = skeleton_anim_idle;
		self.state = SKELETON_STATE_IDLE;
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
	if (vlen(self.origin - self.enemy.origin) > autocvar_g_monster_skeleton_target_range * self.scale) 
	{
		//print("removing enemy, he is too far: ", ftos(vlen(self.origin - self.enemy.origin)), "\n");
		//print("delay was ", ftos(self.delay), "\n");
		self.enemy = world;
	} 
	else
		self.delay = time + autocvar_g_monster_skeleton_target_recheck_delay;
	
	// find an enemy if no enemy available
	if not(self.enemy) 
	{
		self.enemy = FindTarget(self);
		if (self.enemy)
			self.delay = time + autocvar_g_monster_skeleton_target_recheck_delay;
	}
	
	//"Animation" for flail
	if (self.weaponentity.count == 15) {
		if (self.spikedflail_swinging) {
			if (time > self.spikedflail_nextatrest)
			{
				self.spikedflail_swinging = 0;
				setmodel(self.weaponentity,  "models/weapons/v_spikedflail.md3");
				if (self.bomb1.count) { //2 weapons
					setmodel(self.bomb1,  "models/weapons/v_spikedflail.md3");
				}
			}
		}
	} else if (self.weaponentity.count == 16) {
		if (self.milflail_swinging) {
			if (time > self.milflail_nextatrest)
			{
				self.milflail_swinging = 0;
				setmodel(self.weaponentity,  "models/weapons/v_milflail.md3");
				if (self.bomb1.count) { //2 weapons
					setmodel(self.bomb1,  "models/weapons/v_milflail.md3");
				}
			}
		}
	}

	if (self.enemy) 
	{
		float mystandattackrange;
		
		if (self.weaponentity.count == 1)
			mystandattackrange = autocvar_g_balance_broadaxe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 2)
			mystandattackrange = autocvar_g_balance_warhammerspiked_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 3)
			mystandattackrange = autocvar_g_balance_shortsword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 4)
			mystandattackrange = autocvar_g_balance_torch_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 6)
			mystandattackrange = autocvar_g_balance_longsword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 7)
			mystandattackrange = autocvar_g_balance_katana_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 8)
			mystandattackrange = autocvar_g_balance_odachi_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 9)
			mystandattackrange = autocvar_g_balance_nagamaki_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 10)
			mystandattackrange = autocvar_g_balance_tetsubo_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 12)
			mystandattackrange = autocvar_g_balance_ironcrow_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 13)
			mystandattackrange = autocvar_g_balance_scimitar_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 14)
			mystandattackrange = autocvar_g_balance_bastardsword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 15)
			mystandattackrange = autocvar_g_balance_spikedflail_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 16)
			mystandattackrange = autocvar_g_balance_milflail_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 17)
			mystandattackrange = autocvar_g_balance_battleaxe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 18)
			mystandattackrange = autocvar_g_balance_kriegshammer_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 19)
			mystandattackrange = autocvar_g_balance_quarterstaff_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 20)
			mystandattackrange = autocvar_g_balance_sai_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 21)
			mystandattackrange = autocvar_g_balance_dadao_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 22)
			mystandattackrange = autocvar_g_balance_skirmishersaxe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 23)
			mystandattackrange = autocvar_g_balance_bardiche_secondary_melee_range * 0.94;
		else if (self.weaponentity.count == 24)
			mystandattackrange = autocvar_g_balance_templaraxe_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 25)
			mystandattackrange = autocvar_g_balance_armingsword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 26)
			mystandattackrange = autocvar_g_balance_crusadersword_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 27)
			mystandattackrange = autocvar_g_balance_claymore_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 28)
			mystandattackrange = autocvar_g_balance_katana_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 29)
			mystandattackrange = autocvar_g_balance_katana_primary_melee_range * 0.94;
		else if (self.weaponentity.count == 30)
			mystandattackrange = autocvar_g_balance_pudao_primary_melee_range * 0.94;
		else
			mystandattackrange = autocvar_g_monster_skeleton_attack_stand_range * self.scale;
		
		// make sure skeleton is angry
		self.state = SKELETON_STATE_ANGRY;
		

		// this skeleton has an enemy, attack if close enough, go to it if not!
		traceline(self.origin, self.enemy.origin, FALSE, self);
		enemyDistance = vlen(trace_endpos - self.origin);
		mySpeed = vlen(self.velocity);
		
		if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
		if (enemyDistance <= mystandattackrange * 40)
		{
			if (random() > 0.90) {
				//For crossbow sometimes we'll stop and fire
				mySpeed = 20;
				enemyDistance = autocvar_g_monster_skeleton_attack_stand_range;
			}
		}
		
		//print("speed ", ftos(mySpeed), "\n");
		
		if (!self.frozen)
		if (!self.stoned)
		if (trace_ent == self.enemy)
		if (self.enemy.deadflag == DEAD_NO)
		if (mySpeed <= 30)
			if (enemyDistance <= mystandattackrange) 
			{
				//RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
				skeleton_attack_standing();
				finished = TRUE;
			} 
			else if (enemyDistance <= autocvar_g_monster_skeleton_attack_leap_range * self.scale) 
			{
				// do attackleap (set yaw, velocity, and check do damage on the first player entity it touches)
				skeleton_attack_leap();
				finished = TRUE;
			}
		
	}
	
	self.nextthink = time + 1 + self.monster_thinkadd + autocvar_g_monsters_thinkadd; //Randomness so they don't all think on the same frame causing hangs and clicks

	if not(finished) 
	{
		monster_move(autocvar_g_monster_skeleton_speed_run, autocvar_g_monster_skeleton_speed_walk, autocvar_g_monster_skeleton_stopspeed, skeleton_anim_runforward, skeleton_anim_runforward, skeleton_anim_idle);
		
		if (self.enemy || self.monster_owner)
		{
			self.nextthink = time + 0.1;
			return;
		}   
	}
	
	if not(self.enemy || self.monster_owner || self.goalentity) 
	{
		// stay idle
		//print("skeleton is idling while waiting for some fresh meat...\n");
		if (self.stoned || self.frozen) self.frame = skeleton_anim_stone; else self.frame = ((mySpeed <= 20) ? skeleton_anim_idle : skeleton_anim_runforward);
		self.nextthink = time + autocvar_g_monster_skeleton_idle_timer * random();	
	}
}

void skeleton_precache_weapons()
{
	if (autocvar_g_monsters_jitprecacheonly <= 0) {
	precache_model ("models/weapons/v_broadaxe.md3");
	precache_model ("models/weapons/v_battleaxe.md3");
	precache_model ("models/weapons/v_templaraxe.md3");
	precache_model ("models/weapons/v_skirmishersaxe.md3");
	precache_model ("models/weapons/v_warhammerspiked.md3");
	precache_model ("models/weapons/v_kriegshammer.md3");
	precache_model ("models/weapons/v_shortsword.md3");
	precache_model ("models/weapons/v_crossbowdtwr.md3");
	precache_model ("models/weapons/v_lightcrossbow.md3");
	precache_model ("models/weapons/v_torch.md3");
	precache_model ("models/weapons/v_torch_lit.md3");
	precache_model ("models/weapons/v_longsword.md3");
	precache_model ("models/weapons/v_armingsword.md3");
	precache_model ("models/weapons/v_crusadersword.md3");
	precache_model ("models/weapons/v_shirasaya.md3");
	precache_model ("models/weapons/v_zatoichi.md3");
	precache_model ("models/weapons/v_claymore.md3");
	precache_model ("models/weapons/v_katana.md3");
	precache_model ("models/weapons/v_odachi.md3");
	precache_model ("models/weapons/v_nagamaki.md3");
	precache_model ("models/weapons/v_bardiche.md3");
	precache_model ("models/weapons/v_tetsubo.md3");
	precache_model ("models/weapons/v_ironcrow.md3");
	precache_model ("models/weapons/v_sai.md3");
	precache_model ("models/weapons/v_quarterstaff.md3");
	precache_model ("models/weapons/v_scimitar.md3");
	precache_model ("models/weapons/v_dadao.md3");
	precache_model ("models/weapons/v_pudao.md3");
	precache_model ("models/weapons/v_bastardsword.md3");
	precache_model ("models/weapons/v_spikedflail.md3");
	precache_model ("models/weapons/v_spikedflail_swing.md3");
	precache_model ("models/weapons/v_milflail.md3");
	precache_model ("models/weapons/v_milflail_swing.md3");
	}
	
	if (autocvar_g_monsters_jitprecacheonly <= 1) {
	precache_model ("models/misc/playerspikes_head.iqm");	
	}
}

/**
 * Spawn the skeleton.
 */
void skeleton_spawn() 
{
	local float wrand;
	float srandvar;
	
	if (self.health <= 0)
		self.health = autocvar_g_monster_skeleton_health * self.scale;
	
	self.monster_thinkadd = ((random() - 0.5)*0.25);
	self.monster_lasernosteam = 1;
	//print(ftos(self.monster_thinkadd), "think add\n");
	self.species = SPECIES_SKELETON;
	self.classname			= "monster_skeleton";
	self.nextthink	  		= time + (random()*0.5) + 1.85;
	self.pain_finished  	= self.nextthink;
	self.state		  		= SKELETON_STATE_SPAWNING;
	self.frame		  		= skeleton_anim_spawn;
	self.think		  		= skeleton_think;
	self.sprite_height  	= 50 * self.scale;
	self.stoneskin = 3;
	//self.skin 				= rint(random() * 3);
	self.vuln_isundead = 1.5; //Vuln to holy bolt for 150% damage
	
	
	
	if (self.monster_forcetype) {
		if (self.monster_forcetype == 1)
			self.skin = 1;
		else if (self.monster_forcetype == 2)
			self.skin = 2;
		else
			self.skin = 0;
	} else {
		//Selecting the type by Ratio
		srandvar = random() *
		(autocvar_g_monster_skeleton_amnt
		+ autocvar_g_monster_skeleton_burn_amnt
		+ autocvar_g_monster_skeleton_dark_amnt);

		if (srandvar < autocvar_g_monster_skeleton_amnt) {
			self.skin = 0;
		} else if (srandvar < (
		autocvar_g_monster_skeleton_amnt
		+ autocvar_g_monster_skeleton_burn_amnt
		)) {
			self.skin = 1;
		} else if (srandvar < (
		autocvar_g_monster_skeleton_amnt
		+ autocvar_g_monster_skeleton_burn_amnt
		+ autocvar_g_monster_skeleton_dark_amnt
		)) {
			self.skin = 2;
		} else {
			self.skin = 0;
		}
	}
	
	self.resist_bullet = 0.75;
	self.resist_edged = 0.33;
	self.resist_energy = 1;
	self.resist_ice = 0.87;
	self.resist_pierce = 0.6;
	self.resist_sound = 1;
	
	if (self.skin == 1) {
		self.resist_fire = 1;
		self.resist_laser = 0.75;
		self.vuln_beam_ignite = 100;
		if (autocvar_g_monster_skeleton_burn_burningbolt) {
			if (autocvar_g_monster_skeleton_burn_burningbolt >= random()) {
				self.monster_buringbolt = 1;
			}
		}
	} else {
		self.resist_fire = 0.5;
	}
		
	if (self.skin == 2)
		self.resist_electricity = 1;
	else
		self.resist_electricity = 0.75;
	
	wrand = random();
	if (wrand > 0.90)
	{
		//Steel Armor
		self.stoneskin = 15;
		if (self.skin == 1) self.skin = 13;
		else if (self.skin == 2) self.skin = 14;
		else self.skin = 12;
		self.resist_edged = 0.60;
		self.resist_pierce = 0.75;
		self.health = self.health + 25;
	} else if (wrand > 0.70)
	{
		//Copper Armor
		self.stoneskin = 11;
		if (self.skin == 1) self.skin = 9;
		else if (self.skin == 2) self.skin = 10;
		else self.skin = 8;
		self.resist_edged = 0.50;
		self.resist_pierce = 0.7;
		self.health = self.health + 15;
	}
	else if (wrand > 0.45)
	{
		//Rusted armor
		self.resist_edged = 0.40;
		self.resist_pierce = 0.65;
	} else {
		//No Armor
		self.stoneskin = 7;
		if (self.skin == 1) self.skin = 5;
		else if (self.skin == 2) self.skin = 6;
		else self.skin = 4;
	}
	
	self.weaponentity = spawn();
	self.bomb1 = spawn();
	self.bomb2 = spawn();
	setmodel(self.weaponentity,  "null");
	setmodel(self.bomb1,  "null");
	setmodel(self.bomb2,  "null");
	self.weaponentity.count = self.bomb1.count = self.bomb2.count = 0;

	wrand = random();
	if (wrand > 0.2 || self.monster_spawn_as_archer)
	{
		wrand = random();
		self.weaponentity.alpha = 1;
		self.weaponentity.angles    = '65 110 0';
		if (self.monster_spawn_as_archer == 1) 
		{
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
			self.weaponentity.count = 11;
			self.weaponentity.angles    = '0 110 0';
		} else if (self.monster_spawn_as_archer == 2) 
		{
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
			self.weaponentity.count = 5;
			self.weaponentity.angles    = '0 110 0';
		} else if (wrand > 0.90) {
			if (random() > 0.75) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_nagamaki.md3");
				self.weaponentity.count = 9;
			} else {
				if (random() > 0.5) {
					if (random() > 0.3) {
						if (random() > 0.4) {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_broadaxe.md3");
							self.weaponentity.count = 1;
						} else {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_templaraxe.md3");
							self.weaponentity.count = 24;
						}
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_bardiche.md3");
						self.weaponentity.count = 23;
					}
				} else {
					if (random() > 0.5) {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_battleaxe.md3");
						self.weaponentity.count = 17;
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_skirmishersaxe.md3");
						self.weaponentity.count = 22;
					}
				}
			}
		} else if (wrand > 0.75) {
			if (random() > 0.70) {
				if (random() > 0.4) {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_tetsubo.md3");
					self.weaponentity.count = 10;
				} else {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_sai.md3");
					self.weaponentity.count = 20;
				}
			} else if (random() > 0.60) {
				if (random() > 0.4) {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_ironcrow.md3");
					self.weaponentity.count = 12;
				} else {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_quarterstaff.md3");
					self.weaponentity.count = 19;
				}
			} else if (random() > 0.40) {
				if (random() > 0.5) {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_spikedflail.md3");
					self.weaponentity.count = 15;
				} else {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_milflail.md3");
					self.weaponentity.count = 16;
				}
			} else {	
				if (random() > 0.5) {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_warhammerspiked.md3");
					self.weaponentity.count = 2;
				} else {
					setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_kriegshammer.md3");
					self.weaponentity.count = 18;
				}
			}
		} else if (wrand > 0.35) {
			setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shortsword.md3");
			self.weaponentity.count = 3;
		} else if (wrand > 0.22) {
			if (random() > 0.66) {
				if (random() > 0.66) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_odachi.md3");
				self.weaponentity.count = 8;
				} else {
					if (random() > 0.75) {
						if (random() > 0.75) {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_zatoichi.md3");
							self.weaponentity.count = 29;
						} else {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_shirasaya.md3");
							self.weaponentity.count = 28;
						}
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_katana.md3");
						self.weaponentity.count = 7;
					}
				}
			} else {
				if (random() > 0.9) {
					if (random() > 0.7) {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_claymore.md3");
						self.weaponentity.count = 27;
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_bastardsword.md3");
						self.weaponentity.count = 14;
					}
				} else if (random() > 0.7) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_scimitar.md3");
				self.weaponentity.count = 13;
				} else if (random() > 0.5) {
					if (random() > 0.45) {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_pudao.md3");
						self.weaponentity.count = 30;
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_dadao.md3");
						self.weaponentity.count = 21;
					}
				} else {
					if (random() > 0.6) {
						if (random() > 0.7) {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crusadersword.md3");
							self.weaponentity.count = 26;
						} else {
							setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_armingsword.md3");
							self.weaponentity.count = 25;
						}
					} else {
						setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_longsword.md3");
						self.weaponentity.count = 6;
					}
				}
			}	
		} else if (wrand > 0.20) {
			if (autocvar_g_monsters_jitprecacheonly) {
				precache_model ("models/weapons/v_torch_lit.md3");
				precache_model ("models/weapons/v_torch.md3");
			}
			skeleton_check_torch();
			self.weaponentity.count = 4;
		} else {
			if (random() > 0.6) {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
				self.weaponentity.count = 5;
				self.weaponentity.angles    = '0 110 0';
			} else {
				setmodel_and_precacheif(autocvar_g_monsters_jitprecacheonly, self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
				self.weaponentity.count = 11;
				self.weaponentity.angles    = '0 110 0';
			}
		}
		//Testing
		//setmodel(self.weaponentity,  "models/weapons/v_lightcrossbow.md3");
		//self.weaponentity.count = 11;
		//self.weaponentity.angles    = '0 110 0';
		//
		//setmodel(self.weaponentity,  "models/weapons/v_crossbowdtwr.md3");
		//self.weaponentity.count = 5;
		//self.weaponentity.angles    = '0 110 0';
		//setmodel(self.weaponentity,  "models/weapons/v_spikedflail.md3");
		//self.weaponentity.count = 15;
		//self.weaponentity.angles    = '65 110 0';
		//End Testing
		
		
		setattachment(self.weaponentity, self, "Hand.Right");
		
		wrand = random();
		if (wrand > 0.75)
		{
			self.bomb1.alpha = 1;
			self.bomb1.count = self.weaponentity.count;
			self.bomb1.model = self.weaponentity.model;
			setmodel(self.bomb1,  self.bomb1.model);
			
			if (self.weaponentity.count == 5 || self.weaponentity.count == 11)
				self.bomb1.angles    = '0 110 0';
			else
				self.bomb1.angles    = '45 110 0';
			
			setattachment(self.bomb1, self, "Hand.Left");
		}
		
		//Head Ornament
		wrand = random();
		if (wrand > 0.95)
		{
			self.bomb2.alpha = 1;
			if (autocvar_g_monsters_jitprecacheonly > 1) {
				precache_model ("models/misc/playerspikes_head.iqm");
			}
			setmodel(self.bomb2,  "models/misc/playerspikes_head.iqm");
			self.bomb2.angles    = '0 0 -90';
			setattachment(self.bomb2, self, "Head");
			setorigin(self.bomb2, '0 8 -2');    // Move attch spot up 8// back 2// yes fscked up bone  
			self.health = self.health * 1.25;
			self.armorvalue = g_pickup_armormedium;
		}
	}
	
	if (autocvar_g_monster_skeleton_nocolormod) {
		self.colormod = '0 0 0';
	}	
	
	if (autocvar_g_monster_skeleton_noeffects) {
		self.effects &~= (EF_FULLBRIGHT | EF_RED | EF_BLUE); //Disable these if enabled
	}	
	
	self.deadflag = DEAD_NO;
	monster_hook_spawn(); // for post-spawn mods
}

/*QUAKED monster_skeleton (1 0 0) (-18 -18 -25) (18 18 47)
Skeleton, 60 health points.
-------- KEYS --------
-------- SPAWNFLAGS --------
MONSTERFLAG_APPEAR: monster will spawn when triggered.
---------NOTES----------
Original Quake 1 skeleton entity used a smaller box ('-16 -16 -24', '16 16 32').
-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
modeldisabled="models/monsters/skeleton.dpm"
*/
void spawnfunc_monster_skeleton() 
{
	if not(autocvar_g_monster_skeleton) 
	{
		remove(self);
		return;
	}
	
	self.monster_spawnfunc = spawnfunc_monster_skeleton;
	skeleton_precache_weapons();
	
	if(self.spawnflags & MONSTERFLAG_APPEAR)
	{
		self.think = func_null;
		self.nextthink = -1;
		self.use = Monster_Appear;
		return;
	}
	
	self.monster_painsoundset = 1; //Skeleton
	
	if not (monster_initialize(
			 "Skeleton",
			 "models/monsters/skeletonwarrior.iqm",
			 SKELETON_MIN, SKELETON_MAX,
			 FALSE,
			 skeleton_die, skeleton_spawn))
	{
		remove(self);
		return;
	}
}

void spawnfunc_monster_skeleton_burn() 
{
	self.monster_forcetype = 1;
	spawnfunc_monster_skeleton();	
}

void spawnfunc_monster_skeleton_dark() 
{
	self.monster_forcetype = 2;
	spawnfunc_monster_skeleton();	
}

void spawnfunc_monster_skeleton_bone() 
{
	self.monster_forcetype = 300; //Default
	spawnfunc_monster_skeleton();	
}





void spawnfunc_monster_skeleton_burn_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	self.monster_forcetype = 1;
	spawnfunc_monster_skeleton();	
}

void spawnfunc_monster_skeleton_dark_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	self.monster_forcetype = 2;
	spawnfunc_monster_skeleton();	
}

void spawnfunc_monster_skeleton_bone_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	self.monster_forcetype = 300; //Default
	spawnfunc_monster_skeleton();	
}



void spawnfunc_monster_skeleton_archer() 
{
	if (!self.monster_spawn_as_archer) {
		self.monster_spawn_as_archer = 1;
	}
	spawnfunc_monster_skeleton();	
}

