//***********************
//QUAKE 1 ENTITIES - So people can play quake1 maps with the xonotic weapons
//***********************
void spawnfunc_weapon_nailgun (void) {spawnfunc_weapon_electro();}
void spawnfunc_weapon_supernailgun (void) {spawnfunc_weapon_hagar();}
void spawnfunc_weapon_supershotgun (void) {spawnfunc_weapon_uzi();}

void spawnfunc_item_spikes (void) {spawnfunc_item_bullets();}
//void spawnfunc_item_armor1 (void) {spawnfunc_item_armor_medium;}  // FIXME: in Quake this is green armor, in Xonotic maps it is an armor shard
void spawnfunc_item_armor2 (void) {spawnfunc_item_armor_large();}
void item_armorInv (void) {spawnfunc_item_armor_large();}
void spawnfunc_item_health (void) {if (self.spawnflags & 2) spawnfunc_item_health_mega();else spawnfunc_item_health_medium();}

//spawnfunc_item_spikes
//spawnfunc_item_health

//Sometimes people seem to need change for the sake of change
//So someone somewhere decided to rename weapons
//Not add weapons... na, that's our job here.
//Rename them for no reason
//Some Nu Xonotic Aliases, untill we add fo rae
void spawnfunc_weapon_arc (void) { spawnfunc_weapon_lightninggun(); }
void spawnfunc_weapon_blaster (void) { spawnfunc_weapon_laser(); }
//void spawnfunc_weapon_devastator (void) { spawnfunc_weapon_rocketlauncher(); }
//void spawnfunc_weapon_mortar (void) { spawnfunc_weapon_grenadelauncher(); }
void spawnfunc_weapon_vortex (void) { spawnfunc_weapon_nex(); }
void spawnfunc_weapon_shockwave (void) { spawnfunc_weapon_shotgun(); }


void teleport_touch(void) {Teleport_Touch();} //Map didn't load because a change in case...
void trigger_once(void) {spawnfunc_trigger_once();}
void trigger_multiple(void) {spawnfunc_trigger_multiple();}
void trigger_teleport(void) {spawnfunc_trigger_teleport();}
void trigger_hurt(void) {spawnfunc_trigger_hurt();}
void SUB_Null(void){ } //Yep, a map didn't load because it couldn't find this...
void OgreGrenadeExplode(void) { W_Grenade_ExplodeB(); } //No fragmentation grenade
void enforcer_fire(void) {
	//Simple for now
	makevectors (self.angles);
	W_HLAC_Attack();
}

void SUB_regen(void)
{
	//For Quake1 maps only really. We restore the original mdl, and set solid trigger again
	self.solid = SOLID_TRIGGER;
	self.alpha = 1; //In lieu of the old quake way//self.model = self.mdl;
	setorigin (self, self.origin);
}

void barrel_explode(void) { multitool_oildrumexplosion(); } //We allready had a function! Burns foliage too, hope it works well in the Q1 maps

//The following is messy, just ported over to get Quake1 maps loading
//Actual monster code is in server/monsters/ etc 
//As more maps are tested / fail, we'll find (from GPL Quake1 QC), or code, etc the needed code (or atleast a skeleton) to make the map load

.entity movetarget;
.string targetname2, targetname3, targetname4;
//.void()		th_walk;
void tbaby_walk1(void) { };
void tbaby_walk9(void) { };
void tbaby_walk10(void) { };
void tbaby_walk11(void) { };
void tbaby_walk12(void) { };
void tbaby_walk13(void) { };
void tbaby_walk14(void) { };
void tbaby_walk15(void) { };
void tbaby_walk16(void) { };
void tbaby_walk17(void) { };
void tbaby_walk18(void) { };
void tbaby_walk19(void) { };
void tbaby_walk25(void) { };
////////////////////////////////////////////////////////////////////
/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

////Subs
float SUB_FindNamedTarget(float num, string s)
{
	local entity e;
	if (num < 0)
		return FALSE;	//Was just return, fteqcc complained,
				//so I guess... return FALSE (0)?,
				//GMQCC didn't complain... 
				//but we always check with fteqcc atleast once...
				//August 2015
		
	e = find(world, targetname, s);
	while (e)
	{
		num = num - 1;
		if (num < 0)
		{
			other = e;
			return -1;
		}
		e = find(e, targetname, s);
	}
	e = find(world, targetname2, s);
	while (e)
	{
		num = num - 1;
		if (num < 0)
		{
			other = e;
			return -1;
		}
		e = find(e, targetname2,  s);
	}
	e = find(world, targetname3,  s);
	while (e)
	{
		num = num - 1;
		if (num < 0)
		{
			other = e;
			return -1;
		}
		e = find(e, targetname3, s);
	}
	e = find(world, targetname4, s);
	while (e)
	{
		num = num - 1;
		if (num < 0)
		{
			other = e;
			return -1;
		}
		e = find(e, targetname4, s);
	}
	return num;
}

entity SUB_FindTarget(float num)
{
	local float c;
	local entity otemp, e;
	
	otemp = other;
	other = world;
	
	if (self.target)
		num = SUB_FindNamedTarget( num, self.target );
	if (self.target2)
		num = SUB_FindNamedTarget( num, self.target2 );
	if (self.target3)
		num = SUB_FindNamedTarget( num, self.target3 );
	if (self.target4)
		num = SUB_FindNamedTarget( num, self.target4 );
	
	e = other;
	other = otemp;
	return e;
};



////Monsters
/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };

/* pOx - several fixes from URQP below

 1998-12-23 Movetarget correction in monster start functions fix by Maddes
            correcting if-clause
 1998-08-14 Monsters sometimes do not move fix by Perged
            setting nextthink correctly
 1997-12-23 Fish fix by Maddes
            correct total monster addition (don't count fishes twice)

*/

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/

//Have in monsters/lib/monsters.qc
void monster_use ();

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void monster_death_use(void)
{
	local entity 	ent, otemp, stemp;

	// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	if (!self.target)
		return;

	activator = self.enemy;
	SUB_UseTargets ();
}


//============================================================================

void walkmonster_start_go(void)
{
local string	stemp;
local entity	etemp;

	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	droptofloor();

	if (!walkmove(0,0))
	{
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = SUB_FindTarget(0);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
		{
			//self.th_walk ();
		}
		else
		{	// 1998-12-23 Movetarget correction in monster start functions fix by Maddes
			//self.pausetime = 99999999;
			//self.th_stand ();
		}	// 1998-12-23 Movetarget correction in monster start functions fix by Maddes
	}
	else
	{
		//self.pausetime = 99999999;
		//self.th_stand ();
	}

// spread think times so they don't all happen at same time
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
//	self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
}


void walkmonster_start(void)
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
//	self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
	self.think = walkmonster_start_go;
	if (!(self.spawnflags & 64))
		total_monsters = total_monsters + 1;
}



void flymonster_start_go(void)
{
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 25';
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!walkmove(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.target)
	{
		self.goalentity = self.movetarget = SUB_FindTarget(0);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
		{
			//self.th_walk ();
		}
		else
		{	// 1998-12-23 Movetarget correction in monster start functions fix by Maddes
			//self.pausetime = 99999999;
			//self.th_stand ();
		}	// 1998-12-23 Movetarget correction in monster start functions fix by Maddes
	}
	else
	{
		//self.pausetime = 99999999;
		//self.th_stand ();
	}
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
}

void flymonster_start(void)
{
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
	self.flags = self.flags | FL_FLY;	// don't let gravity affect them

// spread think times so they don't all happen at same time
//	self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
	self.think = flymonster_start_go;
	if (!(self.spawnflags & 64))
		total_monsters = total_monsters + 1;
}


void swimmonster_start_go(void)
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;
//	total_monsters = total_monsters + 1;		// 1997-12-23 Fish fix by Maddes  don't count fishes twice

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;

	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.target)
	{
		self.goalentity = self.movetarget = SUB_FindTarget(0);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		//self.th_walk ();
	}
	else
	{
		//self.pausetime = 99999999;
		//self.th_stand ();
	}

// spread think times so they don't all happen at same time
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
//	self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
}

void swimmonster_start(void)
{
// spread think times so they don't all happen at same time
// 1998-08-14 Monsters sometimes do not move fix by Perged  start
	self.flags = self.flags | FL_SWIM;

// spread think times so they don't all happen at same time
//	self.nextthink = self.nextthink + random()*0.5;
	self.nextthink = time + 0.1 + random()*0.5;
// 1998-08-14 Monsters sometimes do not move fix by Perged  end
	self.think = swimmonster_start_go;
	if (!(self.spawnflags & 64))
		total_monsters = total_monsters + 1;
}



void boss_awake (void)
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.takedamage = DAMAGE_NO;

	//setmodel (self, "progs/boss.mdl");
	setsize (self, '-128 -128 -24', '128 128 256');

	//if (skill == 0)
	//	self.health = 1;
	//else
	//	self.health = 3;
	if not(self.health)
		self.health = 3000;

	self.enemy = activator;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	self.yaw_speed = 20;
	//boss_rise1 ();
}

void boss_death10 (void)
{
	//killed_monsters = killed_monsters + 1;
	//WriteByte (MSG_ALL, SVC_KILLEDMONSTER);	// FIXME: reliable broadcast
	SUB_UseTargets ();
	remove (self);
}
void boss_death1 (void) { boss_death10(); }
void boss_death2 (void) { boss_death10(); }
void boss_death3 (void) { boss_death10(); }
void boss_death4 (void) { boss_death10(); }
void boss_death5 (void) { boss_death10(); }
void boss_death6 (void) { boss_death10(); }
void boss_death7 (void) { boss_death10(); }
void boss_death8 (void) { boss_death10(); }
void boss_death9 (void) { boss_death10(); }

////Items and Item accesories
//A map failed to load because we didn't have this function... 
void PlaceItem(void)
{
	local float	oldz;

	self.alpha = 1; //in lieu of the old //self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	droptofloor();
}

void ammo_touch(void){ }
void BackpackTouch(void){ }
void health_touch(void){ }

void GibPlayer(void) {
	//A Q1 map wanted this. Nexuiz/Xonotic uses other ways
	//For now we'll keep it simple and just set dead (don't wan't to throw gibs for just anything)
	//Wonder what that map is gibbing the player for?
	//If you overuse an effect it loses any meaning
	self.deadflag = DEAD_DEAD;
}


float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void misc_fire_crossbowbolt_attack (void);
void misc_fire_laser_attack ();
//void misc_fire_fireball_attack1();
void misc_fire_fireBallistaBolt (void);
.float link;

void spikeshooter_use()
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		//LaunchLaser (self.origin, self.movedir);
		misc_fire_laser_attack();
	}
	else
	{
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE) {
			misc_fire_fireBallistaBolt();
		} else {
			misc_fire_crossbowbolt_attack();
		}
	}
}

/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/
void trap_spikeshooter()
{
	//Our version doesn't set movedir, just uses the angles //SetMovedir ();
	//Hope all maps are compatable with that, it seems to be what they use
	//and our routines to fire traps use self.angles natively
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{		
		precache_sound ("weapons/lasergun_fire.wav");
	}
	
	if (self.link)
		self.movetype = MOVETYPE_NOCLIP;

}

void spawnfunc_trap_spikeshooter()
{
	trap_spikeshooter();
}

void shooter_think() 
{
	spikeshooter_use();
	self.nextthink = time + self.wait;
}

/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void trap_shooter()
{
	trap_spikeshooter ();

	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
	if (self.link)
		self.movetype = MOVETYPE_NOCLIP;

}

void spawnfunc_trap_shooter()
{
	trap_shooter();
}
