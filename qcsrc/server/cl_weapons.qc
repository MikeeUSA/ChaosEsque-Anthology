void W_TriggerReload()
{
    weapon_action(self.weapon, WR_RELOAD);
}

// switch between weapons
void W_SwitchWeapon(float imp)
{
	if (self.switchweapon != imp)
	{
		if (client_hasweapon(self, imp, TRUE, TRUE))
			W_SwitchWeapon_Force(self, imp);
		else
			self.selectweapon = imp; // update selectweapon ANYWAY
	}
	else
	{
		W_TriggerReload();
	}
}

.float weaponcomplainindex;
float W_GetCycleWeapon(entity pl, string weaponorder, float dir, float imp, float complain, float skipmissing)
{
	// We cannot tokenize in this function, as GiveItems calls this
	// function. Thus we must use car/cdr.
	float weaponwant, first_valid, prev_valid, switchtonext, switchtolast, c;
	string rest;
	switchtonext = switchtolast = 0;
	first_valid = prev_valid = 0;
	float weaponcur;

	if(skipmissing || pl.selectweapon == 0)
		weaponcur = pl.switchweapon;
	else
		weaponcur = pl.selectweapon;

	if(dir == 0)
		switchtonext = 1;

	c = 0;

	rest = weaponorder;
	while(rest != "")
	{
		weaponwant = stof(car(rest)); rest = cdr(rest);
		if(imp >= 0)
			if((get_weaponinfo(weaponwant)).impulse != imp)
				continue;

		++c;

		if(!skipmissing || client_hasweapon(pl, weaponwant, TRUE, FALSE))
		{
			if(switchtonext)
				return weaponwant;
			if(!first_valid)
				first_valid = weaponwant;
			if(weaponwant == weaponcur)
			{
				if(dir >= 0)
					switchtonext = 1;
				else if(prev_valid)
					return prev_valid;
				else
					switchtolast = 1;
			}
			prev_valid = weaponwant;
		}
	}
	if(first_valid)
	{
		if(switchtolast)
			return prev_valid;
		else
			return first_valid;
	}
	// complain (but only for one weapon on the button that has been pressed)
	if(complain)
	{
		self.weaponcomplainindex += 1;
		c = mod(self.weaponcomplainindex, c) + 1;
		rest = weaponorder;
		while(rest != "")
		{
			weaponwant = stof(car(rest)); rest = cdr(rest);
			if(imp >= 0)
				if((get_weaponinfo(weaponwant)).impulse != imp)
					continue;

			--c;
			if(c == 0)
			{
				client_hasweapon(pl, weaponwant, TRUE, TRUE);
				break;
			}
		}
	}
	return 0;
}

void W_CycleWeapon(string weaponorder, float dir)
{
	self.peaceful = 0; //We are nolonger peaceful.
	float w;
	w = W_GetCycleWeapon(self, weaponorder, dir, -1, 1, TRUE);
	if(w > 0)
		W_SwitchWeapon(w);
}

void W_NextWeaponOnImpulse(float imp)
{
	self.peaceful = 0; //We are nolonger peaceful.
	float w;
	w = W_GetCycleWeapon(self, self.cvar_cl_weaponpriority, +1, imp, 1, (self.cvar_cl_weaponimpulsemode == 0));
	if(w > 0)
		W_SwitchWeapon(w);
}

// next weapon
void W_NextWeapon(float list)
{
	self.peaceful = 0; //We are nolonger peaceful.
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, -1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, -1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, -1);
}

// prev weapon
void W_PreviousWeapon(float list)
{
	self.peaceful = 0; //We are nolonger peaceful.
	if(list == 0)
		W_CycleWeapon(weaponorder_byid, +1);
	else if(list == 1)
		W_CycleWeapon(self.weaponorder_byimpulse, +1);
	else if(list == 2)
		W_CycleWeapon(self.cvar_cl_weaponpriority, +1);
}

// previously used if exists and has ammo, (second) best otherwise
void W_LastWeapon()
{
	self.peaceful = 0; //We are nolonger peaceful.
	if(client_hasweapon(self, self.cnt, TRUE, FALSE))
		W_SwitchWeapon(self.cnt);
	else
		W_SwitchToOtherWeapon(self);
}

float w_getbestweapon(entity e)
{
	return W_GetCycleWeapon(e, e.cvar_cl_weaponpriority, 0, -1, FALSE, TRUE);
}

// generic weapons table
// TODO should they be macros instead?
float weapon_action(float wpn, float wrequest)
{
	return (get_weaponinfo(wpn)).weapon_func(wrequest);
}

string W_Name(float weaponid)
{
	return (get_weaponinfo(weaponid)).message;
}

float W_AmmoItemCode(float wpn)
{
	return (get_weaponinfo(wpn)).items & IT_AMMO;
}

.float savenextthink;
void thrown_wep_think()
{
	self.owner = world;
	float timeleft = self.savenextthink - time;
	if (autocvar_g_pickup_permitems || self.inventory_permitems == 2)
		SUB_ItemSetToPermWhen(self, time + 5);
	else if(timeleft > 1)
		SUB_SetFade(self, self.savenextthink - 1, 1);
	else if(timeleft > 0)
		SUB_SetFade(self, time, timeleft);
	else
		SUB_VanishOrRemove(self);
}

// if we're a melee weapon that should not drop with ammo (nails in this case)
float W_DoNotDropWithNails (float mywpn)
{
	if(mywpn == WEP_MORGENSTERN
	|| mywpn == WEP_BROADAXE
	|| mywpn == WEP_POLEAXE
	|| mywpn == WEP_BARDICHE
	|| mywpn == WEP_CROWBAR
	|| mywpn == WEP_CUDGEL
	|| mywpn == WEP_FLANGEDMACE
	|| mywpn == WEP_FLASHLIGHT
	|| mywpn == WEP_HANDCUFFS
	|| mywpn == WEP_IRONCROW
	|| mywpn == WEP_ELVENSABRE
	|| mywpn == WEP_KATANA
	|| mywpn == WEP_SHIRASAYA
	|| mywpn == WEP_ZATOICHI
	|| mywpn == WEP_KIDUCHI
	|| mywpn == WEP_LONGSWORD
	|| mywpn == WEP_ARMINGSWORD
	|| mywpn == WEP_CRUSADERSWORD
	|| mywpn == WEP_IRONKNIFE
	|| mywpn == WEP_BOWIEKNIFE
	|| mywpn == WEP_MULTITOOL
	|| mywpn == WEP_NAGAMAKI
	|| mywpn == WEP_ELVENGLAIVE
	|| mywpn == WEP_ODACHI
	|| mywpn == WEP_RAPIER
	|| mywpn == WEP_DAGGER
	|| mywpn == WEP_ARKANSASTOOTHPICK
	|| mywpn == WEP_KNIFE
	|| mywpn == WEP_SAI
	|| mywpn == WEP_SHACKLES
	|| mywpn == WEP_SHININGSTAR
	|| mywpn == WEP_SPIKEDMACE
	|| mywpn == WEP_SHORTSWORD
	|| mywpn == WEP_SPEAR
	|| mywpn == WEP_STONEAXE
	|| mywpn == WEP_TETSUBO
	|| mywpn == WEP_BRONZECUDGEL
	|| mywpn == WEP_UTILITOOL
	|| mywpn == WEP_WARHAMMERSPIKED
	|| mywpn == WEP_WARMALLET
	|| mywpn == WEP_SPIKEDCLUB
	|| mywpn == WEP_SPIKEDCUDGEL
	|| mywpn == WEP_GREYIRONMALLET
	|| mywpn == WEP_YARI
	|| mywpn == WEP_CLAWHAMMER
	|| mywpn == WEP_STAFFFLAME
	|| mywpn == WEP_STAFFMAGI
	|| mywpn == WEP_BASTARDSWORD
	|| mywpn == WEP_CLAYMORE
	|| mywpn == WEP_FLAMBERGE
	|| mywpn == WEP_DEFENDERSWORD
	|| mywpn == WEP_SCIMITAR
	|| mywpn == WEP_FALCHION
	|| mywpn == WEP_DADAO
	|| mywpn == WEP_PUDAO
	|| mywpn == WEP_INFANTRYAXE
	|| mywpn == WEP_ELVENAXE
	|| mywpn == WEP_QUARTERSTAFF
	|| mywpn == WEP_INFANTRYSTAFF
	|| mywpn == WEP_WARAXE
	|| mywpn == WEP_SKIRMISHERSAXE
	|| mywpn == WEP_BATTLEAXE
	|| mywpn == WEP_TEMPLARAXE
	|| mywpn == WEP_ELVENSTAFF
	|| mywpn == WEP_ELVENGLAIVE
	|| mywpn == WEP_WOODAXE
	|| mywpn == WEP_DOUBLEBITAXE
	|| mywpn == WEP_AXE
	|| mywpn == WEP_BEARDEDAXE
	|| mywpn == WEP_PICKAXE
	|| mywpn == WEP_ELVENHAMMER
	|| mywpn == WEP_KRIEGSHAMMER
	|| mywpn == WEP_SPIKEDFLAIL
	|| mywpn == WEP_MILFLAIL
	|| mywpn == WEP_SHOOTINGSTAR
	|| mywpn == WEP_FIGHTERSWORD
	|| mywpn == WEP_LIGHTSABRE
	|| mywpn == WEP_LIGHTSABREII
	|| mywpn == WEP_LIGHTSABREIV
	|| mywpn == WEP_LIGHTSABREXI
	|| mywpn == WEP_BAT
	) {
		return TRUE;
	}
	return FALSE;
}

float W_G_ModelIsNotPreScaledByOnePointSix (float mywpn)
{
	//When we create a g_model in blender, we first
	//scale it to 1.6 times in blender
	//However we do not do this for pistols
	//Nor medieval weapons / melee weapons
	//For the pistols: to artistically underline their compactness
	//For the medieval weapons: for "realism"
	//This function is to inform the game, if it is desired to have
	//everything scaled the same
	//It's somewhat arbitrary what might be scaled and what is not
	//Thus when you choose not to scale (when you decide something
	//Is a pistol, add it to this list.)
	//(Example crypistol _is_ scaled to 1.6 in the blender file
	//for the g_model, so it is _excluded_ from this list, 
	//however sunbolt was _not_ scaled in the g_model in blender
	//so is on the list. The microuzi is _not_ scaled in the g_model
	//because the modeler decided it was more a pistol, so artistically
	//decided to keep it "real" scale rather than the default 
	//Xonotic artistic interpretation for weapon pickups of 1.6 scale,
	//Thus it is on this list.
	if(mywpn == WEP_BIGPISTOL
	|| mywpn == WEP_LARGEPISTOL
	|| mywpn == WEP_LIGHTPISTOL
	|| mywpn == WEP_FIVESEVENPISTOL
	|| mywpn == WEP_LONGPISTOL
	|| mywpn == WEP_M9PISTOL
	|| mywpn == WEP_M93RPISTOL
	|| mywpn == WEP_MACHINEPISTOL
	|| mywpn == WEP_MAUSERPISTOL
	|| mywpn == WEP_TT33PISTOL
	|| mywpn == WEP_SUNBOLT
	|| mywpn == WEP_REVOLVER
	|| mywpn == WEP_FLINTLOCKPISTOL
	|| mywpn == WEP_NAVY1851REVOLVER
	|| mywpn == WEP_R1856REVOLVER
	|| mywpn == WEP_COLT44REVOLVER
	|| mywpn == WEP_SCHOFIELDREVOLVER
	|| mywpn == WEP_BROWNINGHP
	|| mywpn == WEP_FFMAGNUM
	|| mywpn == WEP_PEPPERBOXREVOLVER
	|| mywpn == WEP_MAGNUM
	|| mywpn == WEP_WEBLEY
	|| mywpn == WEP_WEBLEYLONG
	|| mywpn == WEP_TARGETPISTOL
	|| mywpn == WEP_MICROUZI
	|| mywpn == WEP_COMPOSITEBOW
	|| mywpn == WEP_CROSSBOWDTWR
	|| mywpn == WEP_LIGHTCROSSBOW
	|| mywpn == WEP_CRUDEBOW
	|| mywpn == WEP_LONGBOW
	|| mywpn == WEP_YUMIBOW)
	{
		return TRUE;
	} else if (W_DoNotDropWithNails(mywpn)) {
		//These are all melee weapons which are not scaled in blender
		//If we ever create an exception we'll add it above as a false
		return TRUE;
	}
	return FALSE;
}

// returns amount of ammo used as string, or -1 for failure, or 0 for no ammo count
string W_ThrowNewWeapon(entity own, float wpn, float doreduce, vector org, vector velo)
{
	entity oldself, wep;
	float wa, thisammo, i, j;
	string s;
	var .float ammofield;

	wep = spawn();
	
	if (own.noanimdroppeditems) {
		wep.noanimdroppeditems = 2; //2 means pertains to the weapon itself.
	}
	
	if (own.inventory_permitems) {
		wep.inventory_permitems = 2; //2 means pertains to the weapon itself.
	}

	setorigin(wep, org);
	wep.classname = "droppedweapon";
	wep.velocity = velo;
	wep.owner = wep.enemy = own;
	wep.flags |= FL_TOSSED;
	wep.colormap = own.colormap;
	
	if (wpn == WEP_TORCH) {
		if (own.torch_lit) {
			if (autocvar_g_balance_torch_allowthrownlight) {
				//print("spawning light\n");
				torch_thrown_spawnlight(wep);
			}
		}
	}

	if(WEPSET_CONTAINS_AW(WEPBIT_SUPERWEAPONS, wpn))
	{
		if(own.items & IT_UNLIMITED_SUPERWEAPONS)
		{
			wep.superweapons_finished = time + autocvar_g_balance_superweapons_time;
		}
		else
		{
			float superweapons = 1;
			for(i = WEP_FIRST; i <= WEP_LAST; ++i)
				if(WEPSET_CONTAINS_AW(WEPBIT_SUPERWEAPONS, i))
					if(WEPSET_CONTAINS_EW(own, i))
						++superweapons;
			if(superweapons <= 1)
			{
				wep.superweapons_finished = own.superweapons_finished;
				own.superweapons_finished = 0;
			}
			else
			{
				float timeleft = own.superweapons_finished - time;
				float weptimeleft = timeleft / superweapons;
				wep.superweapons_finished = time + weptimeleft;
				own.superweapons_finished -= weptimeleft;
			}
		}
	}

	wa = W_AmmoItemCode(wpn);
	if(wa == 0)
	{
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
		wep.glowmod = own.weaponentity_glowmod;
		wep.think = thrown_wep_think;
		wep.savenextthink = wep.nextthink;
		wep.nextthink = min(wep.nextthink, time + 0.5);
		wep.pickup_anyway = TRUE; // these are ALWAYS pickable
		return "";
	}
	else
	{
		s = "";
		oldself = self;
		self = wep;
		weapon_defaultspawnfunc(wpn);
		self = oldself;
		if(startitem_failed)
			return string_null;
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
		wep.glowmod = own.weaponentity_glowmod;
		wep.think = thrown_wep_think;
		wep.savenextthink = wep.nextthink;
		wep.nextthink = min(wep.nextthink, time + 0.5);
		wep.pickup_anyway = TRUE; // these are ALWAYS pickable
		
		if(W_DoNotDropWithNails(wpn)) {
			//Hack for fteqcc
			//MORGENSTERN is the 48th weapon
			//In fteqcc problems arise with the code above:
			//self.(weapon_load[self.weapon]) = -1;
			//causes your player to "dissapear"
			//"edict 1: SOLID_BSP with invalid modelindex!"
			//(gmqcc doesn't have a problem with it)
			//so we have set doreduce to 0 when throwing it
			//and here we set the .ammo_nails to 0
			//so the player can't drop, pickup, drop, pickup
			//and keep gaining ammo
			//
			//Addendum: other melee weapons shouldn't drop with ammo either
			wep.ammo_nails = 0;
		}
		
		return s;
	}
}

float W_IsWeaponThrowable(float w)
{
	float wa;

	if (autocvar_g_nodropweapons)
		return 0;
	if (!autocvar_g_pickup_items)
		return 0;
	if (g_weaponarena)
		return 0;
	if (g_lms)
		return 0;
	if (g_ca)
		return 0;
	if (g_cts)
		return 0;
	if (g_nexball && w == WEP_GRENADE_LAUNCHER)
		return 0;
    if(w == 0)
        return 0;
	
	wa = W_AmmoItemCode(w);
	if(WEPSET_CONTAINS_AW(start_weapons, w))
	{
		// start weapons that take no ammo can't be dropped (this prevents dropping the laser, as long as it continues to use no ammo)
		if(start_items & IT_UNLIMITED_WEAPON_AMMO)
			return 0;
		if(wa == 0)
			return 0;
	}

	return 1;
}

// toss current weapon
void W_ThrowWeapon(vector velo, vector delta, float doreduce)
{
	float w;
	string a;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if(MUTATOR_CALLHOOK(ForbidThrowCurrentWeapon))
		return;
	if(!autocvar_g_weapon_throwable)
		return;
	if(self.weaponentity.state != WS_READY)
		return;
	if(!W_IsWeaponThrowable(w))
		return;

	if(!WEPSET_CONTAINS_EW(self, w))
		return;
	WEPSET_ANDNOT_EW(self, w);
	
	if (W_DoNotDropWithNails(w)) {
		//Hack for fteqcc
		//MORGENSTERN is the 48th weapon
		//In fteqcc problems arise with the W_ThrowNewWeapon code:
		//self.(weapon_load[self.weapon]) = -1;
		//causes your player to "dissapear"
		//"edict 1: SOLID_BSP with invalid modelindex!"
		//(gmqcc doesn't have a problem with the code, and this does not occur)
		//so we have set doreduce to 0 when throwing it
		//and later in W_ThrowNewWeapon we set for WEP_MORGENSTERN .ammo_nails to 0
		//so the player can't drop, pickup, drop, pickup
		//and keep gaining ammo
		//
		//Addendum: other melee weapons shouldn't drop with ammo either
		doreduce = 0;
	}

	W_SwitchWeapon_Force(self, w_getbestweapon(self));
	a = W_ThrowNewWeapon(self, w, doreduce, self.origin + delta, velo);
	if not(a)
		return;
	if(a == "")
		sprint(self, strcat("You dropped the ^2", W_Name(w), "\n"));
	else
		sprint(self, strcat("You dropped the ^2", W_Name(w), " with ", a, "\n"));
		
	weapon_action(self.weapon, WR_DROP);
}

//toss current weapon, switch to no weapon, used when dropping weaps do to injuries
void W_ThrowWeaponNoSwitch(vector velo, vector delta, float doreduce)
{
	float w;
	string a;

	w = self.weapon;
	if (w == 0)
		return; // just in case
	if(MUTATOR_CALLHOOK(ForbidThrowCurrentWeapon))
		return;
	if(!autocvar_g_weapon_throwable)
		return;
	if(self.weaponentity.state != WS_READY)
		return;
	if(!W_IsWeaponThrowable(w))
		return;

	if(!WEPSET_CONTAINS_EW(self, w))
		return;
	WEPSET_ANDNOT_EW(self, w);
	
	if (W_DoNotDropWithNails(w)) {
		//Hack for fteqcc
		//MORGENSTERN is the 48th weapon
		//In fteqcc problems arise with the W_ThrowNewWeapon code:
		//self.(weapon_load[self.weapon]) = -1;
		//causes your player to "dissapear"
		//"edict 1: SOLID_BSP with invalid modelindex!"
		//(gmqcc doesn't have a problem with the code, and this does not occur)
		//so we have set doreduce to 0 when throwing it
		//and later in W_ThrowNewWeapon we set for WEP_MORGENSTERN .ammo_nails to 0
		//so the player can't drop, pickup, drop, pickup
		//and keep gaining ammo
		//
		//Addendum: other melee weapons shouldn't drop with ammo either
		doreduce = 0;
	}

	W_SwitchWeapon_Force(self, 0);
	a = W_ThrowNewWeapon(self, w, doreduce, self.origin + delta, velo);
	if not(a)
		return;
	if(a == "")
		sprint(self, strcat("You dropped the ^2", W_Name(w), "\n"));
	else
		sprint(self, strcat("You dropped the ^2", W_Name(w), " with ", a, "\n"));
}

void MagicInventoryDropByName (entity player, string mitype, string misize, string mysize, float coinamount, float isput, entity donee);
// toss current weapon or ammo (used for impulse17: dropweapon)
// if we have the use key pressed (F) we throw ammo instead
void W_ThrowWeaponOrAmmo(vector velo, vector delta, float doreduce)
{
	if(self.BUTTON_USE) {
		if (self.items & IT_CELLS) {
			MagicInventoryDropByName(self, "ammo", "cells", "", 1, 0, world);
		} else if (self.items & IT_ROCKETS) {
			MagicInventoryDropByName(self, "ammo", "rockets", "", 1, 0, world);
		} else if (self.items & IT_NAILS) {
			MagicInventoryDropByName(self, "ammo", "nails", "", 1, 0, world);
		} else if (self.items & IT_SHELLS) {
			MagicInventoryDropByName(self, "ammo", "shells", "", 1, 0, world);
		}
	} else {
		W_ThrowWeapon(velo, delta, doreduce);
	}
}


// Bringed back weapon frame
void W_WeaponFrame()
{
	vector fo, ri, up;

	if (frametime)
		self.weapon_frametime = frametime;

	if(((arena_roundbased || g_ca || g_freezetag) && time < warmup) || ((time < game_starttime) && !autocvar_sv_ready_restart_after_countdown))
		return;

	if(self.freezetag_frozen == 1)
		return;
		
	if(self.frozen)
		return;
		
	if(self.stoned)
		return;

	if (!self.weaponentity || self.health < 1)
		return; // Dead player can't use weapons and injure impulse commands

	if(!self.switchweapon)
	{
		self.weapon = 0;
		self.switchingweapon = 0;
		self.weaponentity.state = WS_CLEAR;
		self.weaponname = "";
		self.items &~= IT_AMMO;
		return;
	}

	makevectors(self.v_angle);
	fo = v_forward; // save them in case the weapon think functions change it
	ri = v_right;
	up = v_up;

	// Change weapon
	if (self.weapon != self.switchweapon)
	{
		if (self.weaponentity.state == WS_CLEAR)
		{
			if (self.alpha != -1)
			if (self.switchweapon != WEP_MULTITOOL)
			{
				//Alpha -1 == invisible, prob in vehicle
				//if we're not multitool, nor in vehicle
				//set the ammo reserve display counters to 0
				self.vehicle_ammo1_current = 0;
				self.vehicle_ammo1_max = 0;
			}
			// end switching!
			self.switchingweapon = self.switchweapon;

			//setanim(self, self.anim_draw, FALSE, TRUE, TRUE);
			self.weaponentity.state = WS_RAISE;
			self.weaponaltaim_use = 0;
			self.weaponinitaimmotif_use = 0;
			weapon_action(self.switchweapon, WR_SETUP);

			// set our clip load to the load of the weapon we switched to, if it's reloadable
			entity e;
			e = get_weaponinfo(self.switchweapon);
			if(e.spawnflags & WEP_FLAG_RELOADABLE && cvar(strcat("g_balance_", e.netname, "_reload_ammo"))) // prevent accessing undefined cvars
			{
				self.clip_load = self.(weapon_load[self.switchweapon]);
				self.clip_size = cvar(strcat("g_balance_", e.netname, "_reload_ammo"));
				
				weapon_action(self.switchweapon, WR_CLIPSETUP); //For extended mag weapons
			}
			else
				self.clip_load = self.clip_size = 0;

			// VorteX: add player model weapon select frame here
			// setcustomframe(PlayerWeaponRaise);
			weapon_thinkf(WFRAME_IDLE, autocvar_g_balance_weaponswitchdelay, w_ready);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, '0 0 0');
		}
		else if (self.weaponentity.state == WS_DROP)
		{
			// in dropping phase we can switch at any time
			self.switchingweapon = self.switchweapon;
		}
		else if (self.weaponentity.state == WS_READY)
		{
			// start switching!
			self.switchingweapon = self.switchweapon;

#ifndef INDEPENDENT_ATTACK_FINISHED
			if(ATTACK_FINISHED(self) <= time + self.weapon_frametime * 0.5)
			{
#endif
			sound (self, CH_WEAPON_SINGLE, "weapons/weapon_switch.wav", VOL_BASE, ATTN_NORM);
			self.weaponentity.state = WS_DROP;
			// set up weapon switch think in the future, and start drop anim
			weapon_thinkf(WFRAME_DONTCHANGE, autocvar_g_balance_weaponswitchdelay, w_clear);
			weapon_boblayer1(PLAYER_WEAPONSELECTION_SPEED, PLAYER_WEAPONSELECTION_RANGE);
#ifndef INDEPENDENT_ATTACK_FINISHED
			}
#endif
		}
	}

	// LordHavoc: network timing test code
	//if (self.button0)
	//	print(ftos(frametime), " ", ftos(time), " >= ", ftos(ATTACK_FINISHED(self)), " >= ", ftos(self.weapon_nextthink), "\n");

	float w;
	w = self.weapon;

	// call the think code which may fire the weapon
	// and do so multiple times to resolve framerate dependency issues if the
	// server framerate is very low and the weapon fire rate very high
	float c;
	c = 0;
	while (c < W_TICSPERFRAME)
	{
		c = c + 1;
		if(w && !WEPSET_CONTAINS_EW(self, w))
		{
			if(self.weapon == self.switchweapon)
				W_SwitchWeapon_Force(self, w_getbestweapon(self));
			w = 0;
		}

		v_forward = fo;
		v_right = ri;
		v_up = up;

		if(w)
			weapon_action(self.weapon, WR_THINK);
		else
			weapon_action(self.weapon, WR_GONETHINK);

		if (time + self.weapon_frametime * 0.5 >= self.weapon_nextthink)
		{
			if(self.weapon_think)
			{
				v_forward = fo;
				v_right = ri;
				v_up = up;
				self.weapon_think();
			}
			else
				bprint("\{1}^1ERROR: undefined weapon think function for ", self.netname, "\n");
		}
	}

	// don't let attack_finished fall behind when not firing (must be after weapon_setup calls!)
	//if (ATTACK_FINISHED(self) < time)
	//	ATTACK_FINISHED(self) = time;

	//if (self.weapon_nextthink < time)
	//	self.weapon_nextthink = time;

	// update currentammo incase it has changed
#if 0
	if (self.items & IT_CELLS)
		self.currentammo = self.ammo_cells;
	else if (self.items & IT_ROCKETS)
		self.currentammo = self.ammo_rockets;
	else if (self.items & IT_NAILS)
		self.currentammo = self.ammo_nails;
	else if (self.items & IT_SHELLS)
		self.currentammo = self.ammo_shells;
	else
		self.currentammo = 1;
#endif
}

string W_Apply_Weaponreplace(string in)
{
	float n = tokenize_console(in);
	string out = "";
	float i;
	for(i = 0; i < n; ++i)
	{
		string s = argv(i);
		string r = cvar_string(strcat("g_weaponreplace_", s));
		if(r == "")
			out = strcat(out, " ", s);
		else if(r != "0")
			out = strcat(out, " ", r);
	}
	return substring(out, 1, -1);
}

string W_ApplyNo_Weaponreplace(string in)
{
	string out = "";
	out = strcat(out, " ", in);
	
	return substring(out, 1, -1);
}
