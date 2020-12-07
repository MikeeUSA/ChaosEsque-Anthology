Know your way around:
When adding a new sourcecode file, reference it in: progs.src
New variables often are put in: defs.qh

A big mutator that controls many enviromental things (foliage, 
randomly placed buildings, ballons, bumpers, water, lava, etc)
is: mutators/mutator_spawnvehicles.qc

Zombie Apocalypse monster spawner mutator
mutators/mutator_zombie_apocalypse.qc

Mounted guns, vehicles and mannable turrets are in vehicles/
Unmanned turrets are in tturrets/

w_multitool.qc and w_utilitool.qc are for building buildings in game.
w_multitool.qc is the main code section for this.

cheats.qc has magic casting in it too, and inventory code, and cmd code.
t_items.qc is related as it has spell books etc

when adding a weapon mind:
w_all.qc, cl_player.qc, g_damage.qc, vehicles/vehicles.qc
also the projectiles and waypoint and damage code in clientside code.


================
(?Compiler?) Bugs:
There appears to be a bug in fteqcc.
If you drop the 48th weapon your own model index is suddenly incorrect
and you "dissappear".
"edict 1: SOLID_BSP with invalid modelindex!"

in W_ThrowNewWeapon this code causes a problem with fteqcc:

This line is what messes things up://self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading

		if(doreduce && g_weapon_stay == 2)
		{
			for(i = 0, j = 1; i < 24; ++i, j *= 2)
			{
				if(wa & j)
				{
					ammofield = Item_CounterField(j);

					// if our weapon is loaded, give its load back to the player
					if(self.(weapon_load[self.weapon]) > 0)
					{
						own.ammofield += self.(weapon_load[self.weapon]);
						self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
					}

					wep.ammofield = 0;
				}
			}
		}
		else if(doreduce)
		{
			for(i = 0, j = 1; i < 24; ++i, j *= 2)
			{
				if(wa & j)
				{
					ammofield = Item_CounterField(j);

					// if our weapon is loaded, give its load back to the player
					if(self.(weapon_load[self.weapon]) > 0)
					{
						own.ammofield += self.(weapon_load[self.weapon]);
						self.(weapon_load[self.weapon]) = -1; // schedule the weapon for reloading
					}

					thisammo = min(own.ammofield, wep.ammofield);
					wep.ammofield = thisammo;
					own.ammofield -= thisammo;
					s = strcat(s, " and ", ftos(thisammo), " ", Item_CounterFieldName(j));
				}
			}
			s = substring(s, 5, -1);
		}
		

This does not happen with gmqcc.

So we work around it by setting doreduce to 0 for the special case
of the 48th weapon (morningstar in this case), and not allowing it
to drop ammo by setting .ammo_nails to 0;

(Weapons with no ammo type can't be thrown, so can't do it that way)

GMQCC compiled menu doesn't work with other languages
for some reason, fteqcc does. (atleast on my setup)
