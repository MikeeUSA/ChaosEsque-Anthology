// cvars
float autocvar_g_monster_misc_nofullbright;
float autocvar_g_monsters_typefrag;
float autocvar_g_monsters_owners;
float autocvar_g_monsters_miniboss_chance;
float autocvar_g_monsters_miniboss_healthboost;
float autocvar_g_monsters_forcedrop;
string autocvar_g_monsters_drop_type;
string autocvar_g_monsters_drop_size;
float autocvar_g_monsters_teams;
float autocvar_g_monsters_healthbars;
float autocvar_g_monsters_respawn_delay;
float autocvar_g_monsters_respawn;
float autocvar_g_monsters_nogiants;
float autocvar_g_monsters_skill_easy;
float autocvar_g_monsters_skill_normal;
float autocvar_g_monsters_skill_hard;
float autocvar_g_monsters_skill_insane;
float autocvar_g_monsters_skill_nightmare;
float autocvar_g_monsters_thinkadd;
float autocvar_g_monsters_dropfallbackquakeish;
float autocvar_g_monsters_dofilth;
float autocvar_g_monsters_dobath;
.float monster_thinkadd; //Time to add to monster's think, random set too keep them out of sync
.float monster_lasernosteam;
.float monster_buringbolt;
.float monster_forcetype; //For spawning specific types/skins of monsters
.float monster_forcescale;
.float monster_spawn_as_archer; //Spawn as archer, if possible

// TODO: clean up this file?

void M_Item_Touch ()
{
	if(other.handcuffed)
		return;
	if(other.prisonerlevel >= 3)
		return;
	if(autocvar_g_noautopickup)
	{
		if((clienttype(other) == CLIENTTYPE_REAL) && !other.BUTTON_USE)
			return;
	}
	if (self.inventory_nopickuptill) {
		if (self.inventory_nopickupbytill) {
			if (other == self.inventory_nopickupbytill) {
				if (self.inventory_nopickuptill > time)
				{
					return;
				}	
			}
		} else {
			if (self.inventory_nopickuptill > time)
			{
				return;
			}
		}
	}
	if(!self.inventory_itemnosize && other.iscontainer_storage) {
		local float othertally;
		othertally = ContainerTallyStorage(other);
		if (othertally >= other.iscontainer_storage)
		{
			if ((clienttype(other) == CLIENTTYPE_REAL)) {
				if (other.inventory_annoymsgtime < time) {
					sprint(other, "Your inventory is full\n");
					other.inventory_annoymsgtime = time + 2;
				}
			}
			return;
		}
		else if ((othertally + ContainerTallyStorage(self)) > other.iscontainer_storage)
		{
			if ((clienttype(other) == CLIENTTYPE_REAL)) {
				if (other.inventory_annoymsgtime < time) {
					sprint(other, "Your inventory cannot fit that\n");
					other.inventory_annoymsgtime = time + 2;
				}
			}
			return;
		} 
	}
	if(self && other.classname == STR_PLAYER && other.deadflag == DEAD_NO)
	{
		Item_Touch();
		self.think = SUB_Remove;
		self.nextthink = time + 0.1;
	}
}

void Monster_DropItem_Potion()
{
	local float crand;
	crand = random();	
	if (crand < 0.03) spawnfunc_item_potion_rejuv_large();
	else if (crand < 0.09) spawnfunc_item_potion_rejuv_medium();
	else if (crand < 0.2) spawnfunc_item_potion_rejuv_small();
	else if (crand < 0.3) spawnfunc_item_potion_mana_large();
	else if (crand < 0.45) spawnfunc_item_potion_mana_medium();
	else if (crand < 0.5) spawnfunc_item_potion_mana_small();
	else if (crand < 0.6) spawnfunc_item_potion_health_large();
	else if (crand < 0.8) spawnfunc_item_potion_health_medium();
	else spawnfunc_item_potion_health_small();
}

//Low level spells
void Monster_DropItem_BookFire()
{
	local float crand;
	crand = random();	
	if (crand < 0.1) spawnfunc_item_book_spell_fireball();
	else if (crand < 0.3) spawnfunc_item_book_spell_firebeam();
	else spawnfunc_item_book_spell_firebolt();
}

void Monster_DropItem_BookIce()
{
	local float crand;
	crand = random();	
	if (crand < 0.4) spawnfunc_item_book_spell_iceball();
	else spawnfunc_item_book_spell_frostbeam();	
}

void Monster_DropItem_BookEMagic()
{
	local float crand;
	crand = random();	
	if (crand < 0.3) spawnfunc_item_book_spell_lightining();
	else spawnfunc_item_book_spell_magicmissile();	
}

void Monster_DropItem_ScrollFire()
{
	local float crand;
	crand = random();	
	if (crand < 0.1) spawnfunc_item_scroll_spell_fireball();
	else if (crand < 0.3) spawnfunc_item_scroll_spell_firebeam();
	else spawnfunc_item_scroll_spell_firebolt();
}

void Monster_DropItem_ScrollIce()
{
	local float crand;
	crand = random();	
	if (crand < 0.4) spawnfunc_item_scroll_spell_iceball();
	else spawnfunc_item_scroll_spell_frostbeam();	
}

void Monster_DropItem_ScrollEMagic()
{
	local float crand;
	crand = random();	
	if (crand < 0.3) spawnfunc_item_scroll_spell_lightining();
	else spawnfunc_item_scroll_spell_magicmissile();	
}

void Monster_DropItem_SizeByNum (string itype, float intitemsize);
void Monster_DropItem (string itype, string itemsize)
{
	if(itype == "0")
		return; // someone didnt want an item...
	
	//Loopback items. We'll recall this function with the correct item	
	if (itype == "wealth")
	{
				local float drandvar;
				local float dintitemsize;
				
				drandvar = random();
				if (drandvar > 0.9)
					dintitemsize = 3; //Large
				else if (drandvar > 0.65)
					dintitemsize = 2; //Medium
				else
					dintitemsize = 1; //Small

		if (itemsize == "small")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinsbronze", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinsiron", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinstin", dintitemsize);
		} else if (itemsize == "mediumsmall")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinscopper", dintitemsize);
				else if (drandvar > 0.7)
					Monster_DropItem_SizeByNum("coinsbronze", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinsiron", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinstin", dintitemsize);
		} else if (itemsize == "medium")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinssilver", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinscopper", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinsbronze", dintitemsize);
		} else if (itemsize == "mediumlarge")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinsgold", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinssilver", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinscopper", dintitemsize);
		}
		else if (itemsize == "large")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinsplat", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinsgold", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinssilver", dintitemsize);
		}
		else if (itemsize == "huge")
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinsjade", dintitemsize);
				else if (drandvar > 0.5)
					Monster_DropItem_SizeByNum("coinsplat", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinsgold", dintitemsize);
		}
		else //Tiny
		{
				if (drandvar > 0.9)
					Monster_DropItem_SizeByNum("coinsiron", dintitemsize);
				else
					Monster_DropItem_SizeByNum("coinstin", dintitemsize);
		}
		return; //We spawned the item allready via one of the above calls
	}
	//End loopback items;
	
	vector backuporigin = self.origin + ((self.mins + self.maxs) * 0.5);
	entity oldself;
	
	oldself = self;
	self = spawn();
	
	if (itype == "armor")
	{
		if(itemsize == "large") spawnfunc_item_armor_large();
		else if (itemsize == "small") spawnfunc_item_armor_small();
		else if (itemsize == "medium") spawnfunc_item_armor_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "health")
	{
		if(itemsize == "large") spawnfunc_item_health_large();
		else if (itemsize == "small") spawnfunc_item_health_small();
		else if (itemsize == "medium") spawnfunc_item_health_medium();
		else if (itemsize == "mega") spawnfunc_item_health_mega();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "ammo")
	{
		if(itemsize == "shells") spawnfunc_item_shells();
		else if (itemsize == "cells") spawnfunc_item_cells();
		else if (itemsize == "bullets") spawnfunc_item_bullets();
		else if (itemsize == "rockets") spawnfunc_item_rockets();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionhealth")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_health_large();
		else if (itemsize == "small") spawnfunc_item_potion_health_small();
		else if (itemsize == "medium") spawnfunc_item_potion_health_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionmana")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_mana_large();
		else if (itemsize == "small") spawnfunc_item_potion_mana_small();
		else if (itemsize == "medium") spawnfunc_item_potion_mana_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionrejuv")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_rejuv_large();
		else if (itemsize == "small") spawnfunc_item_potion_rejuv_small();
		else if (itemsize == "medium") spawnfunc_item_potion_rejuv_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionvodka")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_vodka_large();
		else if (itemsize == "small") spawnfunc_item_potion_vodka_small();
		else if (itemsize == "medium") spawnfunc_item_potion_vodka_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionmerlot")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_merlot_large();
		else if (itemsize == "small") spawnfunc_item_potion_merlot_small();
		else if (itemsize == "medium") spawnfunc_item_potion_merlot_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionale")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_ale_large();
		else if (itemsize == "small") spawnfunc_item_potion_ale_small();
		else if (itemsize == "medium") spawnfunc_item_potion_ale_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "potionwater")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") spawnfunc_item_potion_water_large();
		else if (itemsize == "small") spawnfunc_item_potion_water_small();
		else if (itemsize == "medium") spawnfunc_item_potion_water_medium();
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinstin")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_tin(); }
		else if (itemsize == "small") { self.inv_coin = 3; spawnfunc_item_money_coin_tin(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_tin(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsiron")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_iron(); }
		else if (itemsize == "small") { self.inv_coin = 3; spawnfunc_item_money_coin_iron(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_iron(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsbronze")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_bronze(); }
		else if (itemsize == "small") { self.inv_coin = 3; spawnfunc_item_money_coin_bronze(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_bronze(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinscopper")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_copper(); }
		else if (itemsize == "small") { self.inv_coin = 3; spawnfunc_item_money_coin_copper(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_copper(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinssilver")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_silver(); }
		else if (itemsize == "small") { self.inv_coin = 2; spawnfunc_item_money_coin_silver(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_silver(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsgold")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_gold(); }
		else if (itemsize == "small") { self.inv_coin = 2; spawnfunc_item_money_coin_gold(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_gold(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsplat")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_plat(); }
		else if (itemsize == "small") { self.inv_coin = 2; spawnfunc_item_money_coin_plat(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_plat(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsjade")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_jade(); }
		else if (itemsize == "small") { self.inv_coin = 2; spawnfunc_item_money_coin_jade(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_jade(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "coinsamberium")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if(itemsize == "large") { self.inv_coin = 15; spawnfunc_item_money_coin_amberium(); }
		else if (itemsize == "small") { self.inv_coin = 2; spawnfunc_item_money_coin_amberium(); }
		else if (itemsize == "medium") { self.inv_coin = 10; spawnfunc_item_money_coin_amberium(); }
		else print("Invalid monster drop item selected.\n");
	}
	else if (itype == "spellbook")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		DropSpellByName(1, itemsize, 1); //Last parameter (, 1) is really for coin amounts etc only, but since it exists it has to be set, could be 0 aswell
	}
	else if (itype == "scroll")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		DropSpellByName(0, itemsize, 1);
	}
	else if (itype == "random")
	{
		self.ItemStatus |= ITS_ANIMATE1;
		if (itemsize == "potion")
		{
			Monster_DropItem_Potion();
		}
		else if (itemsize == "vore")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.1) Monster_DropItem_ScrollIce();
			else if (crand < 0.25) Monster_DropItem_ScrollEMagic();
			else Monster_DropItem_Potion();
		}
		else if (itemsize == "mage")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.05) Monster_DropItem_ScrollIce();
			else if (crand < 0.15) Monster_DropItem_ScrollFire();
			else if (crand < 0.25) Monster_DropItem_ScrollEMagic();
			else Monster_DropItem_Potion();
		}
		else if (itemsize == "mage2")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.01) Monster_DropItem_BookIce();
			else if (crand < 0.02) Monster_DropItem_BookFire();
			else if (crand < 0.03) Monster_DropItem_BookEMagic();
			else if (crand < 0.10) Monster_DropItem_ScrollIce();
			else if (crand < 0.20) Monster_DropItem_ScrollFire();
			else if (crand < 0.30) Monster_DropItem_ScrollEMagic();
			else Monster_DropItem_Potion();
		}
		else if (itemsize == "spellbook")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.33) Monster_DropItem_BookIce();
			else if (crand < 0.66) Monster_DropItem_BookFire();
			else Monster_DropItem_BookEMagic();
		}
		else if (itemsize == "scroll")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.33) Monster_DropItem_ScrollIce();
			else if (crand < 0.66) Monster_DropItem_ScrollFire();
			else Monster_DropItem_ScrollEMagic();
		}
		else if (itemsize == "basicfood")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.1) spawnfunc_item_food_garlic();
			else if (crand < 0.4) spawnfunc_item_food_cheeze();
			else spawnfunc_item_food_bread();
		}
		else if (itemsize == "food")
		{
			local float crand;
			crand = random();
			
			if (crand < 0.1) spawnfunc_item_food_grapes();
			else if (crand < 0.2) spawnfunc_item_food_tomato();
			else if (crand < 0.3) spawnfunc_item_food_garlic();
			else if (crand < 0.4) spawnfunc_item_food_onion();
			else if (crand < 0.5) spawnfunc_item_food_bellpepper();
			else if (crand < 0.6) spawnfunc_item_food_turkeyleg();
			else if (crand < 0.7) spawnfunc_item_food_cheeze();
			else spawnfunc_item_food_bread();
		}
		
	}
	
	self.velocity = randomvec() * 175 + '0 0 325';
	
	self.gravity = 1;
	self.origin = backuporigin;
	
	self.touch = M_Item_Touch;
	
	if (autocvar_g_pickup_permitems)
		SUB_ItemSetToPermWhen(self, time + 20);
	else 
		SUB_SetFade(self, time + 20, 1);
	
	self = oldself;
}

void Monster_DropItem_SizeByNum (string itype, float intitemsize)
{
	//For those who don't like strings
	if (intitemsize == 3) {
		Monster_DropItem (itype, "large");
	} else if (intitemsize == 2) {
		Monster_DropItem (itype, "medium");
	} else if (intitemsize == 1) {
		Monster_DropItem (itype, "small");
	}
	//And if you don't give us a number, we do nothing
}

float monster_isvalidtarget_extra (entity targ, entity ent)
{
	//Use mostly for marshaled monsters

	if (!teamplay)
	if (targ.monster_owner)
	if (ent.monster_owner)
	if (targ.monster_owner == ent.monster_owner)
	{
		return FALSE;
	}
	
	if (ent.monster_marshal)
	if (targ.monster_owner)
	if (ent.monster_marshal == targ.monster_owner)
	{
		return FALSE;
	}
	
	if (targ.monster_marshal)
	if (ent.monster_owner)
	if (targ.monster_marshal == ent.monster_owner)
	{
		return FALSE;
	}
	
	return TRUE;
}

float monster_isvalidtarget (entity targ, entity ent, float neutral, float hasattackedus)
{
	if(!targ || !ent)
		return FALSE; // this check should fix a crash
		
	if(targ.vehicle_flags & VHF_ISVEHICLE)
		targ = targ.vehicle;
		
	if(time < game_starttime)
		return FALSE; // monsters do nothing before the match has started
		
	traceline(ent.origin, targ.origin, FALSE, ent);
	
	if(vlen(targ.origin - ent.origin) >= 2000) {
		if (ent.monster_hasheightenedsenseofsmell) {
		  if(vlen(targ.origin - ent.origin) >= (2000 + (2000 * ent.monster_hasheightenedsenseofsmell))) {
		  	return FALSE; // enemy is too far away	
		  } else if(vlen(targ.origin - ent.origin) >= (2000 + (1500 * ent.monster_hasheightenedsenseofsmell))) {
			local float mytargethasbeenfound;
			mytargethasbeenfound = 0;
			local float mytarget_smell_bodyodor = 0.025;
			local float mytarget_smell_faeces = 0.015;
			local float mytarget_smell_urine = 0.035;
			
			
			if (targ.smell_bodyodor >= (mytarget_smell_bodyodor*4)) mytargethasbeenfound = 1;
			if (targ.smell_faeces >= (mytarget_smell_faeces*4)) mytargethasbeenfound = 1;
			if (targ.smell_urine >= (mytarget_smell_urine*4)) mytargethasbeenfound = 1;
			
			if (mytargethasbeenfound) {
				//Do nothing
				//print(ent.classname, " Monster Detect by scent - far\n");
			} else if(vlen(targ.origin - ent.origin) >= (2000 + (1000 * ent.monster_hasheightenedsenseofsmell))) {
				if (targ.smell_bodyodor >= (mytarget_smell_bodyodor*2)) mytargethasbeenfound = 1;
				if (targ.smell_faeces >= (mytarget_smell_faeces*2)) mytargethasbeenfound = 1;
				if (targ.smell_urine >= (mytarget_smell_urine*2)) mytargethasbeenfound = 1;
				
				if (mytargethasbeenfound) {
					//Do nothing
					//print(ent.classname, " Monster Detect by scent - medium\n");
				} else {
					//(>= 2000)
					if (targ.smell_bodyodor >= mytarget_smell_bodyodor) mytargethasbeenfound = 1;
					if (targ.smell_faeces >= mytarget_smell_faeces) mytargethasbeenfound = 1;
					if (targ.smell_urine >= mytarget_smell_urine) mytargethasbeenfound = 1;
					
					if (mytargethasbeenfound) {
						//Do nothing
						//print(ent.classname, " Monster Detect by scent - close\n");
					} else {
					return FALSE; // enemy is too far away
					}
				}
			}
		  }
		} else {
		return FALSE; // enemy is too far away
		}
	}

	if(trace_ent != targ)
		return FALSE; // we can't see the enemy
		
	if(neutral == TRUE)
		return TRUE; // we come in peace!
		
	if(targ.takedamage == DAMAGE_NO)
		return FALSE; // enemy can't be damaged
		
	if(targ.items & IT_INVISIBILITY)
		return FALSE; // enemy is invisible
	
	if(targ.classname == STR_SPECTATOR || targ.classname == STR_OBSERVER)
		return FALSE; // enemy is a spectator
	
	if(targ.deadflag != DEAD_NO || ent.deadflag != DEAD_NO || targ.health <= 0 || ent.health <= 0)
		return FALSE; // enemy/self is dead
	
	if(targ.monster_owner == ent || ent.monster_owner == targ)
		return FALSE; // enemy owns us, or we own them
		
	if (targ.monster_marshalable && ent.monster_marshalable) {
		if (targ.monster_marshal && (targ.monster_marshal == ent.monster_marshal)) {
			return FALSE; //enemy and we are under same marshal
		}
	}
	
	if (ent.monster_demeanor == 5) {
		//We tolerate ANY of same owner
		if (!teamplay)
		if (targ.monster_owner)
		if (ent.monster_owner)
		if (targ.monster_owner != world)
		if (targ.monster_owner == ent.monster_owner)
		{
			return FALSE;
		}
	} else if (ent.monster_demeanor == 4) {
		//We tolerate only those of same owner who will tolerate us
		if (!teamplay)
		if (targ.monster_owner)
		if (ent.monster_owner)
		if (targ.monster_owner != world)
		if (targ.monster_owner == ent.monster_owner)
		if (targ.monster_demeanor >= 4)
		{
			return FALSE;
		}
	}
		
	//Dont attack owners friends
	if (autocvar_g_allow_friends) {
	  if(ent.monster_owner && ent.monster_owner != world) {
		//print(etos(ent.monster_owner),"myrealowner\n");
		//print(etos(targ),"enemy\n");
		if (ent.monster_owner.tolerateall == -2
		|| quickIsHatedOf(ent.monster_owner, targ)) {
			//We don't like, yes can have frenimeies
		} else if (ent.monster_owner.tolerateall >= 2
		|| quickIsFriendOf(ent.monster_owner, targ)) {
			if (teamplay) {
			  if (autocvar_g_allow_friends < 2) {
			   if not(targ.team == ent.team) {
			   	//Continue
			   } else {
			   	//print("No attack friend of realowner on same team\n");
				return FALSE;
			   }
			  } else {
			  	//print("No attack friend of realowner even if other team\n");
				return FALSE;
			  }
			} else {	
				//print("No attack friend of realowner\n");
				return FALSE;
			}
		} else if ((ent.monster_owner.tolerateall != -1) &&
		(quickIsToleratedOf(ent.monster_owner, targ) || (ent.monster_owner.tolerateall == 1))) {
		   if not (hasattackedus)
		   {
		    //Monsters do not tolerate non-friend, merely tolerated players attacking them
		    //So only if this isn't being called from monster take damage
			if (teamplay) {
			  if (autocvar_g_allow_friends < 2) {
			   if not(targ.team == ent.team) {
			   	//Continue
			   } else {
			   	//print("No attack tolerated of realowner on same team\n");
				return FALSE;
			   }
			  } else {
			  	//print("No attack tolerated of realowner even if other team\n");
				return FALSE;
			  }
			} else {	
				//print("No attack tolerated of realowner\n");
				return FALSE;
			}
		   }
		}
		
	    ////////////////////////////
	    //Dont attack monsters owned by owners friends
	    if(targ.monster_owner && targ.monster_owner != world) {
		//print(etos(ent.monster_owner),"myrealowner\n");
		//print(etos(targ.monster_owner),"enemy\n");
		if (ent.monster_owner.tolerateall == -2
		|| quickIsHatedOf(ent.monster_owner, targ.monster_owner)) {
			//We don't like, yes can have frenimeies
		} else if (ent.monster_owner.tolerateall >= 2
		|| quickIsFriendOf(ent.monster_owner, targ.monster_owner)) {
			if (teamplay) {
			  if (autocvar_g_allow_friends < 2) {
			   if not(targ.monster_owner.team == ent.team) {
			   	//Continue
			   } else {
			   	//print("No attack friend of realowner on same team\n");
				return FALSE;
			   }
			  } else {
			  	//print("No attack friend of realowner even if other team\n");
				return FALSE;
			  }
			} else {	
				//print("No attack friend of realowner\n");
				return FALSE;
			}
		} else if ((ent.monster_owner.tolerateall != -1) &&
		(quickIsToleratedOf(ent.monster_owner, targ.monster_owner) || (ent.monster_owner.tolerateall == 1))) {
		   if not (hasattackedus)
		   {
		    //Monsters do not tolerate non-friend, merely tolerated players attacking them
		    //So only if this isn't being called from monster take damage
			if (teamplay) {
			  if (autocvar_g_allow_friends < 2) {
			   if not(targ.monster_owner.team == ent.team) {
			   	//Continue
			   } else {
			   	//print("No attack tolerated of realowner on same team\n");
				return FALSE;
			   }
			  } else {
			  	//print("No attack tolerated of realowner even if other team\n");
				return FALSE;
			  }
			} else {	
				//print("No attack tolerated of realowner\n");
				return FALSE;
			}
		   }
		}
	    }
	    ////////////////////////////////
	  
	  }
	}
	
	if(targ.flags & FL_NOTARGET)
		return FALSE; // enemy can't be targetted
	
	if not(autocvar_g_monsters_typefrag)
	if(targ.BUTTON_CHAT)
		return FALSE; // no typefragging!
	
	if(teamplay)
	if(targ.team == ent.team)
		return FALSE; // enemy is on our team
	
	return TRUE;
}

//string Checker(entity ent); //For gamemode chess
float MosterIsOpponentAThreat (entity otherent, entity myself)
{
	if (otherent.peaceful == 1) {
		return FALSE;
	}
	
	if(clienttype(otherent) == CLIENTTYPE_REAL || clienttype(otherent) == CLIENTTYPE_BOT)
	{
		//Here we assess if opponent has benign intentions we should ignore
		//Or if they are carrying a weapon and we should attack
		if (otherent.weapon == 0) {
			return FALSE;
		} else if
		(otherent.weapon == WEP_FLASHLIGHT
		|| otherent.weapon == WEP_TUBA
		|| otherent.weapon == WEP_UTILITOOL
		|| otherent.weapon == WEP_MULTITOOL
		){
			//Innocent items
			return FALSE;
		} else if
		(otherent.weapon == WEP_BAT
		|| otherent.weapon == WEP_CROWBAR
		|| otherent.weapon == WEP_TORCH
		|| otherent.weapon == WEP_IRONCROW
		|| otherent.weapon == WEP_CLAWHAMMER
		|| otherent.weapon == WEP_KIDUCHI
		|| otherent.weapon == WEP_CHAINSAW
		|| otherent.weapon == WEP_POWERSAW
		|| otherent.weapon == WEP_HANDCUFFS
		|| otherent.weapon == WEP_SHACKLES
		|| otherent.weapon == WEP_IRONKNIFE
		|| otherent.weapon == WEP_KNIFE
		|| otherent.weapon == WEP_STAFFFLAME
		|| otherent.weapon == WEP_STAFFMAGI
		|| otherent.weapon == WEP_ELVENSTAFF
		|| otherent.weapon == WEP_QUARTERSTAFF
		|| otherent.weapon == WEP_INFANTRYSTAFF
		) {
			//Possibly innocent tools, walking assistance
			if (vlen(otherent.origin - myself.origin) > 128) {
				return FALSE;
			}
		} else if
		(otherent.weapon == WEP_AXE
		|| otherent.weapon == WEP_DOUBLEBITAXE
		|| otherent.weapon == WEP_WOODAXE
		|| otherent.weapon == WEP_PICKAXE
		|| otherent.weapon == WEP_BEARDEDAXE
		) {
			//Possibly somewhat, but less, innocent tools, might be intended by party to be weapons
			if (vlen(otherent.origin - myself.origin) > 192) {
				return FALSE;
			}
		} else if
		(otherent.weapon == WEP_CALTROP) {
			//Concealed but clearly weapons
			if (vlen(otherent.origin - myself.origin) > 256) {
				return FALSE;
			}
		} else if
		(otherent.weapon == WEP_DAGGER) {
			//Concealed but clearly weapons
			if (vlen(otherent.origin - myself.origin) > 256) {
				if (random() > 0.05) {
					return FALSE;
				}
			}
		} else if
		(otherent.weapon == WEP_BOWIEKNIFE
		|| otherent.weapon == WEP_ARKANSASTOOTHPICK
		|| otherent.weapon == WEP_SAI
		) {
			//Concealed but clearly weapons
			if (vlen(otherent.origin - myself.origin) > 256) {
				if (random() > 0.1) {
					return FALSE;
				}
			}
		}
	}
	
	return TRUE;
}

void MonsterTouch ()
{
	if(other == world)
		return;
		
	float checkpeace;
	if (self.classname == "monster_police" || self.classname == "monster_knight" || self.classname == "monster_royalguard") { checkpeace = 1; } else { checkpeace = 0; }

	if(self.enemy != other)
	if(monster_isvalidtarget(other, self, FALSE, FALSE))
	if((checkpeace == 1 && MosterIsOpponentAThreat(other, self)) || (checkpeace != 1))
	{
		self.enemy = other;
	}
}

void monster_wanderpaththink ()
{
	vector v = '0 0 0', v1 = '0 0 0';
	float b = -1, c = 10;
	self.nextthink = time + random() * 10 + 1;
	if (self.owner.health <= 0)
	{
		self.owner.goalentity = world;
		remove(self);
		return;
	}
	while (c > 0)
	{
		c -= 1;
		v = randomvec();
		traceline(self.owner.origin, v * 1024 + self.owner.origin, FALSE, self);
		v = trace_endpos - (normalize(v) * 16) - self.owner.origin;
		if (vlen(v) > b)
		{
			b = vlen(v);
			v1 = v;
		}
	}
	setorigin(self, v1 + self.owner.origin);
}

void monster_wanderpathtouch ()
{
	if (other.health <= 0)
		return;
	if (other.goalentity != self)
		return;

	if (other.enemy)
		return;		// fighting, not following a path

	monster_wanderpaththink();
}

void monster_spawnwanderpath ()
{
	entity spawnpath = spawn();
	spawnpath.classname = "monster_wanderpath";
	spawnpath.solid = SOLID_TRIGGER;
	spawnpath.touch = monster_wanderpathtouch;
	setsize (spawnpath, '-8 -8 -8', '8 8 8');
	spawnpath.think = monster_wanderpaththink;
	spawnpath.nextthink = time + random() * 10 + 1;
	spawnpath.owner = self;
	self.goalentity = spawnpath;
}

void monster_melee (entity targ, float damg, float er, float deathtype)
{
	float bigdmg = 0, rdmg = damg * random();

	if (self.health <= 0)
		return;
	if (targ == world)
		return;

	if (vlen(self.origin - targ.origin) > er * self.scale)
		return;
		
	bigdmg = rdmg * self.scale;
	
	if(random() < 0.01) // critical hit ftw
		bigdmg = 200;
	
	Damage(targ, self, self, bigdmg * monster_skill, deathtype, targ.origin, normalize(targ.origin - self.origin));
}

void Monster_CheckDropCvars (string mon)
{
	string dropitem;
	string dropsize;
	float droprate;
	
	dropitem = cvar_string(strcat("g_monster_", mon, "_drop"));
	dropsize = cvar_string(strcat("g_monster_", mon, "_drop_size"));
	droprate = cvar(strcat("g_monster_", mon, "_drop_rate"));
	
	monster_dropitem = dropitem;
	monster_dropsize = dropsize;
	monster_droprate = droprate;
	MUTATOR_CALLHOOK(MonsterDropItem);
	dropitem = monster_dropitem;
	dropsize = monster_dropsize;
	droprate = monster_droprate;
	
	if ((droprate == 1)
	|| (droprate > random()))
	{
		if(autocvar_g_monsters_forcedrop)
			Monster_DropItem(autocvar_g_monsters_drop_type, autocvar_g_monsters_drop_size);
		else if(dropitem != "")
			Monster_DropItem(dropitem, dropsize);	   
		else {
			if (autocvar_g_monsters_dropfallbackquakeish) {
				Monster_DropItem("armor", "medium");
			} else {
				Monster_DropItem("wealth", "small");
			}
		}
	}
}

void ScaleMonster (float scle)
{
	self.scale = scle;
	setorigin(self, self.origin + ('0 0 30' * scle));
}

void Monster_CheckMinibossFlag ()
{
	if(MUTATOR_CALLHOOK(MonsterCheckBossFlag))
		return;
		
	float nospcolors;
	if (self.classname == "monster_minotaur"	
	|| self.classname == "monster_skeleton"
	|| self.classname == "monster_hellknight"
	|| self.classname == "monster_imp"
	|| self.classname == "monster_biledemon"
	|| self.classname == "monster_spider")
	{
		nospcolors = 1;
	}
	else
	{
		nospcolors = 0;
	}
			
	float healthboost = autocvar_g_monsters_miniboss_healthboost;
	float r = random() * 4;

	// g_monsters_miniboss_chance cvar or spawnflags 64 causes a monster to be a miniboss
	if ((self.spawnflags & MONSTERFLAG_MINIBOSS) || (random() * 100 < autocvar_g_monsters_miniboss_chance))
	{
		if (r < 2 || self.team == COLOR_TEAM2)
		{
			self.strength_finished = -1;  
			healthboost *= monster_skill;
			if (nospcolors)
			{
				if (random() > autocvar_g_monster_misc_nofullbright)
					self.effects |= (EF_FULLBRIGHT | EF_BLUE);
			} else if (self.classname == "monster_hellknight"
			|| self.classname == "monster_imp"
			|| self.classname == "monster_biledemon") {
				//No blue for us
			} else {
				self.effects |= (EF_FULLBRIGHT | EF_BLUE);
			}
		}
		else if (r >= 1 || self.team == COLOR_TEAM1)
		{
			self.invincible_finished = -1;
			healthboost *= bound(0.5, monster_skill, 1.5);
			if (nospcolors)
			{
				if (random() > autocvar_g_monster_misc_nofullbright)
					self.effects |= (EF_FULLBRIGHT | EF_RED);
			} else if (self.classname == "monster_seraph") {
				//No red for us
			} else {
				self.effects |= (EF_FULLBRIGHT | EF_RED);
			}
		}
		self.health += healthboost;
		self.cnt += 20;
		ScaleMonster(1.5);
		self.flags |= MONSTERFLAG_MINIBOSS;
		if(teamplay && autocvar_g_monsters_teams)
			return;
			
		if not(nospcolors)	
		{
			do
			{
				self.colormod_x = random();
				self.colormod_y = random();
				self.colormod_z = random();
				self.colormod = normalize(self.colormod);
			}
			while (self.colormod_x > 0.6 && self.colormod_y > 0.6 && self.colormod_z > 0.6);
		}
	}
}

//Fade for respawning monsters
void MonsterSUB_SetFade_Think (void)
{
	//print("DoingFade for", self.classname,"\n");
	if(self.alpha == 0)
		self.alpha = 1;
	self.think = MonsterSUB_SetFade_Think;
	self.nextthink = time;
	self.alpha -= frametime * self.fade_rate;
	if (self.alpha < 0.01) {
		self.think = self.monster_spawnfunc;
		self.nextthink = time + autocvar_g_monsters_respawn_delay;
		self.alpha = -1;
		self.monster_respawned = TRUE;
		setmodel(self, "");
		if (self.stoned)
		{
			setorigin(self, self.stonedorigin);
			self.angles = self.stonedangles;
		}
		else
		{
			setorigin(self, self.pos1);
			self.angles = self.pos2;
		}
		self.health = 0;
	} else
		self.nextthink = time;
}

void MonsterSUB_SetFade (entity ent, float when, float fadetime)
{
	//print("SetFade for", self.classname,"\n");
	//if (ent.flags & FL_CLIENT) // && ent.deadflag != DEAD_NO)
	//	return;
	//ent.alpha = 1;
	ent.fade_rate = 1/fadetime;
	ent.think = MonsterSUB_SetFade_Think;
	ent.nextthink = when;
}

void Monster_ReleaseHousing (entity mymonster)
{
	if (mymonster.monster_usedhousing)
	{
	  if (teamplay && mymonster.monster_usedhousingteam) {
		if (mymonster.monster_usedhousingteam == COLOR_TEAM1) {
		 current_housing_team1 = current_housing_team1 - mymonster.monster_usedhousing;
		 if (current_housing_team1 < 0) current_housing_team1 = 0;
		} else if (mymonster.monster_usedhousingteam == COLOR_TEAM2) {
		 current_housing_team2 = current_housing_team2 - mymonster.monster_usedhousing;
		 if (current_housing_team2 < 0) current_housing_team2 = 0;
		} else if (mymonster.monster_usedhousingteam == COLOR_TEAM3) {
		 current_housing_team3 = current_housing_team3 - mymonster.monster_usedhousing;
		 if (current_housing_team3 < 0) current_housing_team3 = 0;
		} else if (mymonster.monster_usedhousingteam == COLOR_TEAM4) {
		 current_housing_team4 = current_housing_team4 - mymonster.monster_usedhousing;
		 if (current_housing_team4 < 0) current_housing_team4 = 0;
		}
	  } else {
		current_housing_world = current_housing_world - mymonster.monster_usedhousing;
		if (current_housing_world < 0) current_housing_world = 0;
	  }
	}
}

void Monster_Fade ()
{
	Monster_ReleaseHousing(self);
	
	if not(self.spawnflags & MONSTERFLAG_NORESPAWN)
	if not(self.monster_norespawn)
	if(autocvar_g_monsters_respawn)
	{
		if ((autocvar_g_monsters_respawn_delay) >= 4)
			MonsterSUB_SetFade(self, time, 2);
		else 
			MonsterSUB_SetFade(self, time, 1);
	
		return;
	}
	self.takedamage	 	= DAMAGE_NO; //Do it here so we can do gib damage
	self.event_damage   = func_null;
	self.think = SUB_Remove;
	self.nextthink = time + 4;
		//So we are not going to respawn (we're past the return)
		//Time to clean up attachements if any still linger
		// remove ornaments if there still are any
		//Almost always allready removed
		if (self.body_phal) {
			remove_safely(self.body_phal);
		}
		if (self.weaponentity) {
			remove_safely(self.weaponentity);
		}
		if (self.bomb1) {
			remove_safely(self.bomb1);
		}
		if (self.bomb2) {
			remove_safely(self.bomb2);
		}
	if (self.alpha != -1) {
		SUB_SetFade(self, time + 3, 2);
	}
}

float Monster_CanJump (vector vel)
{
	local vector old = self.velocity;
	
	self.velocity = vel;
	tracetoss(self, self);
	self.velocity = old;
	if (trace_ent != self.enemy)
		return FALSE;

	return TRUE;
}

float monster_leap (float anm, void() touchfunc, vector vel, float anim_finished)
{
	if not(self.flags & FL_ONGROUND)
		return FALSE;
	if(self.health < 1)
		return FALSE; // called when dead?
	if not(Monster_CanJump(vel))
		return FALSE;
		
	self.frame = anm;
	self.state = MONSTER_STATE_ATTACK_LEAP;
	self.touch = touchfunc;
	self.origin_z += 1;
	self.velocity = vel;
	if (self.flags & FL_ONGROUND)
		self.flags -= FL_ONGROUND;
		
	self.attack_finished_single = time + anim_finished;
	
	return TRUE;
}

float GenericCheckAttack ()
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
	
	if (enemy_range() > 2000) // long traces are slow
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

void monster_use ()
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;

	if(!monster_isvalidtarget(activator, self, -1, FALSE))
		return;

	self.enemy = activator;
}

float trace_path(vector from, vector to)
{
	vector dir = normalize(to - from) * 15;
	vector offset = '0 0 0';
	
	offset_x = dir_y;
	offset_y = -dir_x;
	traceline (from+offset, to+offset, TRUE, self);
	float trace1 = trace_fraction;
	traceline(from-offset, to-offset, TRUE, self);
	if (trace1 < trace_fraction) 
		return trace1;
	else return trace_fraction;
}

vector monster_pickmovetarget(entity targ)
{
	if (self.monster_marshal) {
	 if (self.monster_marshal != world) {
	  if (self.monster_marshalable)
	  {
	  	local vector mymarattackspot;
		
		mymarattackspot = self.monster_marshal.origin;
		if (self.monster_marshal.marshalattack) {
			if (self.monster_marshal.marshalattack_spot_x != 0
			|| self.monster_marshal.marshalattack_spot_y != 0
			|| self.monster_marshal.marshalattack_spot_z != 0)
			{
				mymarattackspot = self.monster_marshal.marshalattack_spot;
			}
		} 
		
		
		if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_maxdistance)
		{
			if(trace_path(self.origin + '0 0 10', mymarattackspot + '0 0 10') > (0.99 - self.monster_marshal.marshaldedication)) {
				//print ("Marshal max distance\n");
				return mymarattackspot;
			}
		}
		
		if (self.enemy) {
			if (vlen(self.enemy.origin - self.origin) < autocvar_g_monsters_marshal_toenemydistance)
			{
				if (self.enemy.monster_marshal && (self.enemy.monster_marshal == self.monster_marshal)) {
					self.enemy = world; //Diffuse	
					//Don't go toward enemy who has same marshal as you, some discipline please!
				} else if(self.enemy && trace_path(self.origin + '0 0 10', self.enemy.origin + '0 0 10') > 0.99)
				{
					//print ("Marshal enemy\n");
					return self.enemy.origin + 60 * normalize(self.enemy.origin - self.origin);
				}
			}
		}
		
		if (self.monster_marshal.marshalformation == 1) {
			if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form1)
			{
				if(trace_path(self.origin + '0 0 10', mymarattackspot + '0 0 10') > (0.99 - self.monster_marshal.marshaldedication))
				{
					//print ("Marshal form1\n");
					return mymarattackspot;
				}
			}
		} else if (self.monster_marshal.marshalformation == 2) {
			if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form2)
			{
				if(trace_path(self.origin + '0 0 10', mymarattackspot + '0 0 10') > (0.99 - self.monster_marshal.marshaldedication))
				{
					//print ("Marshal form2\n");
					return mymarattackspot;
				}
			}
		} else if (self.monster_marshal.marshalformation == 3) {
			if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form3)
			{
				if(trace_path(self.origin + '0 0 10', mymarattackspot + '0 0 10') > (0.99 - self.monster_marshal.marshaldedication))
				{
					//print ("Marshal form3\n");
					return mymarattackspot;
				}
			}
		}
		
		
		
		if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance)
		{
			if(trace_path(self.origin + '0 0 10', mymarattackspot + '0 0 10') > (0.99 - self.monster_marshal.marshaldedication))
			{
				//print ("Marshal distance\n");
				return mymarattackspot;
			}
		}
			
	  }
	 }
	}
	
	// enemy is always preferred target
	if(self.enemy && trace_path(self.origin + '0 0 10', self.enemy.origin + '0 0 10') > 0.99)
		return self.enemy.origin + 60 * normalize(self.enemy.origin - self.origin);
	
	switch(self.monster_moveflags)
	{
		case MONSTER_MOVE_OWNER:
		{
			if(self.monster_owner && self.monster_owner.classname != "monster_swarm" && trace_path(self.origin + '0 0 10', self.monster_owner.origin + '0 0 10') > 0.99)
				return self.monster_owner.origin;
		}
		case MONSTER_MOVE_WANDER:
			if(targ) return targ.origin;
		case MONSTER_MOVE_SPAWNLOC:
			return self.pos1;
		default:
		case MONSTER_MOVE_NOMOVE:
			return self.origin;
	}
}

//Human: Slowed by lower injuries
float monster_mvmntimpare_human (float myspeed)
{
	if(self.vuln_movement_imparable) {
	if(self.tempmovementimpared)
	{
		if(self.tempmovementimpared > 0) {
			local float mytempmovementmultip;
			mytempmovementmultip = 1;
			if (self.tempmovementimpared >= 1.5) {
				mytempmovementmultip = 0.2;
			} else if (self.tempmovementimpared >= 1.25) {
				mytempmovementmultip = 0.25;
			} else if (self.tempmovementimpared >= 1) {
				mytempmovementmultip = 0.3;
			} else if (self.tempmovementimpared >= 0.75) {
				mytempmovementmultip = 0.4;
			} else if (self.tempmovementimpared >= 0.5) {
				mytempmovementmultip = 0.5;
			} else if (self.tempmovementimpared >= 0.4) {
				mytempmovementmultip = 0.6;
			} else if (self.tempmovementimpared >= 0.3) {
				mytempmovementmultip = 0.7;
			} else if (self.tempmovementimpared >= 0.2) {
				mytempmovementmultip = 0.8;
			} else {
				mytempmovementmultip = 0.9;
			}
		
			myspeed = myspeed * mytempmovementmultip;
		}
	}
	}
	
	return myspeed;
}

//Animal: Stronger than human
float monster_mvmntimpare_animal (float myspeed)
{
	if(self.vuln_movement_imparable) {
	if(self.tempmovementimpared)
	{
		if(self.tempmovementimpared > 0) {
			local float mytempmovementmultip;
			mytempmovementmultip = 1;
			if (self.tempmovementimpared >= 3) {
				mytempmovementmultip = 0.3;
			} else if (self.tempmovementimpared >= 2.5) {
				mytempmovementmultip = 0.35;
			} else if (self.tempmovementimpared >= 2) {
				mytempmovementmultip = 0.4;
			} else if (self.tempmovementimpared >= 1.5) {
				mytempmovementmultip = 0.45;
			} else if (self.tempmovementimpared >= 1) {
				mytempmovementmultip = 0.5;
			} else if (self.tempmovementimpared >= 0.8) {
				mytempmovementmultip = 0.6;
			} else if (self.tempmovementimpared >= 0.6) {
				mytempmovementmultip = 0.7;
			} else if (self.tempmovementimpared >= 0.4) {
				mytempmovementmultip = 0.8;
			} else {
				mytempmovementmultip = 0.9;
			}
		
			myspeed = myspeed * mytempmovementmultip;
		}
	}
	}
	
	return myspeed;
}

//Beast: Strong
float monster_mvmntimpare_beast (float myspeed)
{
	if(self.vuln_movement_imparable) {
	if(self.tempmovementimpared)
	{
		if(self.tempmovementimpared > 0) {
			local float mytempmovementmultip;
			mytempmovementmultip = 1;
			if (self.tempmovementimpared >= 4.5) {
				mytempmovementmultip = 0.4;
			} else if (self.tempmovementimpared >= 4) {
				mytempmovementmultip = 0.45;
			} else if (self.tempmovementimpared >= 3.5) {
				mytempmovementmultip = 0.50;
			} else if (self.tempmovementimpared >= 3) {
				mytempmovementmultip = 0.55;
			} else if (self.tempmovementimpared >= 2.5) {
				mytempmovementmultip = 0.6;
			} else if (self.tempmovementimpared >= 2) {
				mytempmovementmultip = 0.65;
			} else if (self.tempmovementimpared >= 1.5) {
				mytempmovementmultip = 0.7;
			} else if (self.tempmovementimpared >= 1.0) {
				mytempmovementmultip = 0.75;
			} else if (self.tempmovementimpared >= 0.8) {
				mytempmovementmultip = 0.8;
			} else if (self.tempmovementimpared >= 0.6) {
				mytempmovementmultip = 0.85;
			} else if (self.tempmovementimpared >= 0.4) {
				mytempmovementmultip = 0.9;
			} else {
				mytempmovementmultip = 0.95;
			}
		
			myspeed = myspeed * mytempmovementmultip;
		}
	}
	}
	
	return myspeed;
}

//Demon: Strongest
float monster_mvmntimpare_demon (float myspeed)
{
	if(self.vuln_movement_imparable)
	if(self.tempmovementimpared)
	{
		if(self.tempmovementimpared > 0) {
			local float mytempmovementmultip;
			mytempmovementmultip = 1;
			if (self.tempmovementimpared >= 3) {
				mytempmovementmultip = 0.55;
			} else if (self.tempmovementimpared >= 2.5) {
				mytempmovementmultip = 0.6;
			} else if (self.tempmovementimpared >= 2) {
				mytempmovementmultip = 0.65;
			} else if (self.tempmovementimpared >= 1.5) {
				mytempmovementmultip = 0.7;
			} else if (self.tempmovementimpared >= 1.0) {
				mytempmovementmultip = 0.75;
			} else if (self.tempmovementimpared >= 0.8) {
				mytempmovementmultip = 0.8;
			} else if (self.tempmovementimpared >= 0.6) {
				mytempmovementmultip = 0.85;
			} else if (self.tempmovementimpared >= 0.4) {
				mytempmovementmultip = 0.9;
			} else {
				mytempmovementmultip = 0.95;
			}
		
			myspeed = myspeed * mytempmovementmultip;
		}
	}
	
	return myspeed;
}

.float last_trace;
.float breath_checks;
void monster_move(float runspeed, float walkspeed, float stopspeed, float manim_run, float manim_walk, float manim_idle)
{
	if(self.target)
		self.goalentity = find(world, targetname, self.target);
		
	float l = vlen(self.moveto - self.origin);
	float t1 = trace_path(self.origin+'0 0 10', self.moveto+'0 0 10');
	float t2 = trace_path(self.origin-'0 0 15', self.moveto-'0 0 15'); 
	entity targ = self.goalentity;

	if (self.stat_bangflash) {
			//print(ftos(self.stat_bangflash), "\n");

		if (time > self.bangflash_nexttime) {	
			self.stat_bangflash = self.stat_bangflash - 1;
			//self.stat_bangflash = self.stat_bangflash - 3; //Monsters think at 0.3
			self.bangflash_nexttime = time + 0.1; //10 second flash fade for bang 
		}
	}

	if (self.stat_nukeflash) {
		if (time > self.nukeflash_nexttime) {	
			self.stat_nukeflash = self.stat_nukeflash - 1; //Monster thinking vs flash fade is About the same.
			self.nukeflash_nexttime = time + 0.3; //30 second flash fade for nuke 
		}
	}

	if(self.frozen)
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * self.revive_speed, 1);
		//self.health = max(1, self.revive_progress * self.max_health);
		
		if(self.sprite)
		{
			WaypointSprite_UpdateHealth(self.sprite, self.health);
		}
			
		self.velocity = '0 0 0';
		self.enemy = world;
		if(self.revive_progress >= 1)
			Unfreeze(self); // wait for next think before attacking
	}
	
	if(self.stoned)
	{
		self.strevive_progress = bound(0, self.strevive_progress + frametime * self.strevive_speed, 1);
			
		self.velocity = '0 0 0';
		self.enemy = world;
		if(self.strevive_progress >= 1)
			Unstone(self); // wait for next think before attacking
	}
	
	if(self.frozen || self.stoned)
	{
		self.nextthink = time + 0.1;
		return; // no moving while stoned
	}
	
	if(self.flags & FL_SWIM)
	{
		//....
		//Seems to be about swimming fish
		//If they're out of water, they die
		//....
		if(self.waterlevel < WATERLEVEL_WETFEET)
		{
			self.breath_checks += 1;
			self.angles = '0 0 -90';
			if(self.breath_checks == 25)
			{
				if not(self.flags & FL_ONGROUND)
					self.flags |= FL_ONGROUND;
				self.monster_die();
				if(self.realowner.flags & FL_CLIENT)
					self.realowner.monstercount -= 1;
				if(!(self.spawnflags & MONSTERFLAG_SPAWNED) && !self.monster_respawned)
					monsters_killed += 1;
				self.movetype = MOVETYPE_TOSS;
				return;
			}
			if(random() < 0.5)
			{
				self.velocity_y += random() * 50;
				self.velocity_x -= random() * 50;
			}
			else
			{
				self.velocity_y -= random() * 50;
				self.velocity_x += random() * 50;
			}
			self.velocity_z += random()*150;
			if (self.flags & FL_ONGROUND)
				self.flags -= FL_ONGROUND;
			self.movetype = MOVETYPE_BOUNCE;
			self.velocity_z = -200;
			return;
		}
		else
		{
			self.angles = '0 0 0';
			self.movetype = MOVETYPE_WALK;
			self.breath_checks = 0;
		}
	}
	
	PossiblyReigniteFireFromOilFire(self);
	
	if(self.deadflag == DEAD_NO)
	if (self.health > 0)
	{
		if (Fire_IsBurning(self)) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
		
		//Do we forget...
	  	if(self.prisoner2_sufferingmemory > 0) {
	  		if (time > (self.prisoner2_sufferingmemory_lasttime+60)) {
				self.prisoner2_sufferingmemory = self.prisoner2_sufferingmemory * 0.95;
				if (self.prisoner2_sufferingmemory < 1) {
					//Note: added at a multiple of 0.1
					self.prisoner2_sufferingmemory = 0;
				}
			}
	 	}
		
		if(self.prisoner3_sufferingmemory > 0) {
	  		if (time > (self.prisoner3_sufferingmemory_lasttime+60)) {
				self.prisoner3_sufferingmemory = self.prisoner3_sufferingmemory * 0.95;
				if (self.prisoner3_sufferingmemory < 1) {
					//Note: added at a multiple of 0.2
					self.prisoner3_sufferingmemory = 0;
				}
			}
	 	}
	
		////////////////////////
		//MonsterBath (Simplified bath)
		local float mymonstercandobath;
		mymonstercandobath = 0;
		
		if (self.waterlevel)
		{
			if ((g_spawnfoliagearound_oillevel_started)
			&& (g_spawnfoliagearound_oillevel && g_spawnfoliagearound_oillevel != 0)
			&& ((self.origin_z + self.mins_z) < g_spawnfoliagearound_oillevel_unchanging)) {
				//In Oil
				self.fire_oilfire_entwasinoil = 1;
			} else if ((g_spawnfoliagearound_methanelevel_started)
			&& (g_spawnfoliagearound_methanelevel && g_spawnfoliagearound_methanelevel != 0)
			&& ((self.origin_z + self.mins_z) < g_spawnfoliagearound_methanelevel_unchanging)) {
				//In Methane, Do nothing
			} else {
				mymonstercandobath = 1;
				//Clean Only Oil
				if (self.watertype != CONTENT_LAVA) {
				self.fire_oilfire_entwasinoil = 0;
				self.fire_oilfire_entreignite = 0;
				}
			}
		}
		//End MonsterBath
		////////////////////////
		
		if(self.nextmetabolize < time) //Every 1 second
	  	{
			if (autocvar_g_monsters_dofilth) {
				entity plyrfilthentity;
				plyrfilthentity = world;
		
				plyrfilthentity = PlayerIsInFilth(self);
		
				if (plyrfilthentity) {
				  if (plyrfilthentity != world) {
				    if (plyrfilthentity.isfilth) {
				    	mymonstercandobath = 0;
					TransferSmells (self, plyrfilthentity);
				    }	
				  }
				}
			}
			
			
			if (autocvar_g_monsters_dobath) {
				if (mymonstercandobath && (self.waterlevel == WATERLEVEL_SUBMERGED))
				{
					local float cleanmultip;
			
					if (self.watertype == CONTENT_LAVA) { cleanmultip = 10; }
					else if (self.watertype == CONTENT_SLIME) { cleanmultip = 100; } //Really cleans you up well
					else { cleanmultip = 1; }
					//Clean
					//Note: monster_smell_ is set when the monster is spawned.
					//the monster cannot be "cleaned" below that
					self.smell_acrid = bound(self.monster_smell_acrid, self.smell_acrid - (0.01 * cleanmultip), 10000);
					self.smell_alcohol =  bound(self.monster_smell_alcohol, self.smell_alcohol - (0.05 * cleanmultip), 10000);
					self.smell_bodyodor = bound(self.monster_smell_bodyodor, self.smell_bodyodor - (0.02 * cleanmultip), 10000);
					self.smell_cheeze = bound(self.monster_smell_cheeze, self.smell_cheeze - (0.03 * cleanmultip), 10000);
					self.smell_earthy = bound(self.monster_smell_earthy, self.smell_earthy - (0.03 * cleanmultip), 10000);
					self.smell_faeces = bound(self.monster_smell_faeces, self.smell_faeces - (0.01 * cleanmultip), 10000);
					self.smell_garlic = bound(self.monster_smell_garlic, self.smell_garlic- (0.02 * cleanmultip), 10000);
					self.smell_urine = bound(self.monster_smell_urine, self.smell_urine - (0.02 * cleanmultip), 10000);
					self.smell_roses = bound(self.monster_smell_roses, self.smell_roses - (0.1 * cleanmultip), 10000);
					self.smell_rottingflesh = bound(self.monster_smell_rottingflesh, self.smell_rottingflesh - (0.01 * cleanmultip), 10000);
				
				}
			}
		
			self.nextmetabolize = time + 1;
		}
	}
	
	if(gameover || time < game_starttime)
	{
		runspeed = walkspeed = 0;
		self.frame = manim_idle;
		movelib_beak_simple(stopspeed);
		return;
	}
	
	runspeed *= monster_skill;
	walkspeed *= monster_skill;
	
	monster_target = targ;
	monster_speed_run = runspeed;
	monster_speed_walk = walkspeed;
	MUTATOR_CALLHOOK(MonsterMove);
	targ = monster_target;
	runspeed = monster_speed_run;
	walkspeed = monster_speed_walk;
		
	if(IsDifferentTeam(self.monster_owner, self)) {
		if (!self.monster_keepowner) {
			self.monster_owner = world;
		}
	}
	
	if(self.enemy.health <= 0 || (!autocvar_g_monsters_typefrag && self.enemy.BUTTON_CHAT))
		self.enemy = world;
		
	if not(self.enemy)
		self.enemy = FindTarget(self);
		
	if(time >= self.last_trace)
	{
		self.last_trace = time + 0.5;
		self.moveto = monster_pickmovetarget(targ);
	}
	
	vector angles_face = vectoangles(self.moveto - self.origin);
	self.angles_y = angles_face_y;
	
	if(self.state == MONSTER_STATE_ATTACK_LEAP && checkbottom(self))
	{
		self.state = 0;
		self.touch = MonsterTouch;
	}
	 
	v_forward = normalize(self.moveto - self.origin);
	
	if(t1*l-t2*l>50 && (t1*l > 100 || t1 > 0.8))
	if(self.flags & FL_ONGROUND)
		movelib_jump_simple(100);

	if(vlen(self.moveto - self.origin) > 64)
	{
	
		if (self.monster_marshal
		&& (self.monster_marshal != world)
		&& self.monster_marshalable)
	  	{
			local vector mymarattackspot;
			local float mymarshaledmovefast;
			mymarshaledmovefast = 0;
		
			mymarattackspot = self.monster_marshal.origin;
			if (self.monster_marshal.marshalattack) {
				if (self.monster_marshal.marshalattack_spot_x != 0
				|| self.monster_marshal.marshalattack_spot_y != 0
				|| self.monster_marshal.marshalattack_spot_z != 0)
				{
					mymarattackspot = self.monster_marshal.marshalattack_spot;
				}
			} 
		
			//If marshaled we run or jog depending on settings
			if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_maxdistance)
			{
				mymarshaledmovefast = 1;	
			} else if (self.monster_marshal.marshalformation == 1) {
				if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form1)
				{
					mymarshaledmovefast = 1;	
				}
			} else if (self.monster_marshal.marshalformation == 2) {
				if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form2)
				{
					mymarshaledmovefast = 1;	
				}
			} else if (self.monster_marshal.marshalformation == 3) {
				if (vlen(mymarattackspot - self.origin) > autocvar_g_monsters_marshal_distance_form3)
				{
					mymarshaledmovefast = 1;	
				}
			}
		
			if (mymarshaledmovefast) {
				if (self.monster_jogspeedrate) {
					//jogspeed rate must be more than 0 and less than 1
					if (self.monster_jogspeedrate > 0 && self.monster_jogspeedrate < 1)
					{
						movelib_move_simple(v_forward, runspeed * self.monster_jogspeedrate, 0.6);
					} else {
						//Otherwise just use run speed
						movelib_move_simple(v_forward, runspeed, 0.6);
					}
				} else {
					movelib_move_simple(v_forward, runspeed, 0.6);
				}
			} else {
				//Close to player or target?, and no enemy, walk, mill about
				movelib_move_simple(v_forward, walkspeed, 0.6);
			}
		} else {
			movelib_move_simple(v_forward, ((self.enemy) ? runspeed : walkspeed), 0.6);
		}
		
		if(time > self.pain_finished)
			if(time > self.attack_finished_single)
				self.frame = ((self.enemy) ? manim_run : manim_walk);
	}
	else
	{
		movelib_beak_simple(stopspeed);
			if(time > self.attack_finished_single)
				if(time > self.pain_finished)
					if (vlen(self.velocity) <= 30)
						self.frame = manim_idle;
	}
		
	if(self.enemy)
	{
		if(!self.checkattack)
			return; // to stop other code from crashing here
			
		self.checkattack();
	}
}

void monsters_setstatus()
{
	self.stat_monsters_total = monsters_total;
	self.stat_monsters_killed = monsters_killed;
}


/*
===================

Monster spawn code

===================
*/

void Monster_Appear ()
{
	self.enemy = activator;
	self.spawnflags -= MONSTERFLAG_APPEAR;
	self.monster_spawnfunc();
}

entity FindTarget (entity ent) 
{
	if(MUTATOR_CALLHOOK(MonsterFindTarget)) { return self.goalentity; } // Handled by a mutator
	float checkpeace;
	
	if (ent.classname == "monster_police" || ent.classname == "monster_knight" || self.classname == "monster_royalguard") { checkpeace = 1; } else { checkpeace = 0; }
	
	if (checkpeace == 1 //Those same classnames are affected by flashbangs etc, so save checking again
	|| ent.classname == "monster_soldier"
	|| ent.classname == "monster_goblin"
	|| ent.classname == "monster_fighter"
	|| ent.classname == "monster_ninjaassassin"
	|| ent.classname == "monster_ogre"
	|| ent.classname == "monster_hellknight"
	|| ent.classname == "monster_imp"
	|| ent.classname == "monster_seraph"
	|| ent.classname == "monster_biledemon"
	)
	{
		//Stunned and blind, lose enemy
		if (ent.stat_bangflash > 99) {
			return world;
		}
	
		if (ent.stat_nukeflash > 99) {
			return world;
		}
	}

	if (ent.monster_marshal) {
	 if (ent.monster_marshal != world) {
	  if (ent.monster_marshalable)
	  {
	  	if (ent.monster_marshal.marshalattack) {
			checkpeace = 0;
		}
	  }
	 }
	}
	
	//Normal
	local entity e;
	for(e = world; (e = findflags(e, monster_attack, TRUE)); ) 
	{
		if(monster_isvalidtarget(e, ent, FALSE, FALSE))
		if((checkpeace == 1 && MosterIsOpponentAThreat(e, ent)) || (checkpeace != 1))
		{
			return e;
		}
	}
	//End Normal
	
	if (ent.monster_marshal) {
	 if (ent.monster_marshal != world) {
	  if (ent.monster_marshalable)
	  {
		
	  	//If someone doesn't like our marshal, we attack them
	  	for(e = world; (e = findentity(e, enemy, ent.monster_marshal)); ) 
		{
			if(monster_isvalidtarget_extra(e, ent))
			if(monster_isvalidtarget(e, ent, FALSE, FALSE))
			if((checkpeace == 1 && MosterIsOpponentAThreat(e, ent)) || (checkpeace != 1))
			{
				//print("Found attacker to attack\n");
				return e;
			}
		}
		
		for(e = world; (e = findflags(e, flags, FL_MONSTER)); ) 
		{
			if(monster_isvalidtarget_extra(e, ent))
			if(monster_isvalidtarget(e, ent, FALSE, FALSE))
			if((checkpeace == 1 && MosterIsOpponentAThreat(e, ent)) || (checkpeace != 1))
			{
				//print("Found monster to attack\n");
				return e;
			}
		}
	  }
	 }
	}
	
	return world;
}

void monsters_gibdamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
  //dprint(strcat(ftos(self.alpha), " alpha2\n"));

  if (self.alpha == -1) {
  	self.takedamage	 	= DAMAGE_NO;
	self.event_damage   = func_null;
  } else {
	self.health -= damage;
	
	if(self.damageforcescale < 1 && self.damageforcescale > 0)
		self.velocity += force * self.damageforcescale;
	else
		self.velocity += force;
		
	if (MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self)) {
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);
	}
	
	if(self.health <= -autocvar_sv_gibhealth)
	if(MayWeDoGibs(deathtype) && DamageTargIsNotWithinGrace(self))
	{
		//dprint("GIB2\n");
		Violence_GibSplash(self, 1, 1, attacker);
		self.alpha = -1;
		self.takedamage	 	= DAMAGE_NO;
		self.event_damage   = func_null;
		if (self.body_phal) {
			self.body_phal.alpha = 0.001;
		}
	}
  }
}

float monsters_quakeonezombietakedamage (float damage, float deathtype)
{
	if (deathtype == DEATH_CRUSH) {
		//Helicopter rotor and things like that
		return damage; //If it's something this will be non-zero
	} else if (DEATH_ISWEAPON(deathtype, WEP_CHAINSAW)) {
		if (damage > (autocvar_g_balance_chainsaw_secondary_damage*2))
		{
			//Chainsaw damage is low when off, high when on
			//Here if we're 2x or more the secondary's (off)
			//damage, we're almost certainly turned on
			return damage; //If it's something this will be non-zero
		}
	}
	
	//Filter out things that can't gib us
	local entity testdmg;
	testdmg = spawn();
	testdmg.resist_acid = 1;   //Slime
	testdmg.resist_blunt = 1;  //Warhammer, beatdown, melee
	testdmg.resist_bullet = 1;
	testdmg.resist_crush = 1;  //Vehicle crush
	testdmg.resist_edged = 1;  //Axe, Sword, Claw
	testdmg.resist_electricity = 1; //Lightning gun, Tesla arc, 
	testdmg.resist_energy = 1; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	testdmg.resist_explode = 0;//Rockets etc
	testdmg.resist_fall = 1;   //Shooting star, fall etc
	testdmg.resist_fire = 1;   //Fire, Lava
	testdmg.resist_laser = 0;  //Laser
	testdmg.resist_nuke = 0;  //Nuclear explosion
	testdmg.resist_pierce = 1; //Crossbow, Bite
	testdmg.resist_sound = 1; //Tuba
	testdmg.resist_ice = 1; //Freeze damage resistance
	testdmg.resist_holybolt = 0; //Removes Undead
	testdmg.resist_rotor = 0; //Helicopter/Aero-plane Rotor blades damage resistance, Special, evaluated before crush

	
    	if (DamageResistance(testdmg, damage, deathtype)) {
		remove(testdmg);
		return TRUE;
	} else {
		remove(testdmg);
		return FALSE;
	}
}


void monsters_damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
  //dprint(strcat(ftos(self.alpha), " alpha.\n"));

  if (self.alpha == -1) {
  	self.takedamage	 	= DAMAGE_NO;
	self.event_damage   = func_null;
  } else {
	//////if(self.frozen) //Shouldn't be here, frozen monsters should still take damage
	//////	return;
		
	if(monster_isvalidtarget(attacker, self, FALSE, TRUE))
		self.enemy = attacker;
	
	self.health -= damage;
	
	if (self.monster_isquakezombie)
	{
		if (monsters_quakeonezombietakedamage(damage, deathtype))
		{
			//print("ShouldDie\n");
			self.monster_isquakezombie_shoulddie = 1; //We may die.
		} else {
			self.monster_isquakezombie_shoulddie = 0; //We shall not die
		}
	}
	
	if(self.sprite)
	{
		WaypointSprite_UpdateHealth(self.sprite, self.health);
	}
		
	self.dmg_time = time;
	
	if(!self.stoned) {
	 if(sound_allowed(MSG_BROADCAST, attacker)) {
		if (self.monster_painsoundset == 1) {
			//Skeleton
			if(random() > 0.65) {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/skeleton-hit.ogg", VOL_BASE*0.2, ATTN_NORM);  // FIXME: PLACEHOLDER
			} else {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/skeleton-die.ogg", VOL_BASE*0.2, ATTN_NORM);  // FIXME: PLACEHOLDER

			}
		} else if (self.monster_painsoundset == 2) {
			//Zombie
			if(self.health <= 0 && random() > 0.5) {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/zombie-critdie.ogg", VOL_BASE*0.75, ATTN_NORM);  // FIXME: PLACEHOLDER
			} else if(random() > 0.65) {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/zombie-die.ogg", VOL_BASE*0.75, ATTN_NORM);  // FIXME: PLACEHOLDER
			} else {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/zombie-hit.ogg", VOL_BASE*0.75, ATTN_NORM);  // FIXME: PLACEHOLDER

			}
		} else if (self.monster_painsoundset == 3) {
			//Minotaur
			if(random() > 0.65) {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/minotaur_hit.ogg", VOL_BASE, ATTN_NORM);  // FIXME: PLACEHOLDER
			} else {
				spamsound (self, CH_PAIN, "flare/fantasycore/enemies/minotaur-phys.ogg", VOL_BASE, ATTN_NORM);  // FIXME: PLACEHOLDER

			}
		} else {
			spamsound (self, CH_PAIN, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM);  // FIXME: PLACEHOLDER
	 	}
	 }
	}
	
	if(self.damageforcescale < 1 && self.damageforcescale > 0)
		self.velocity += force * self.damageforcescale;
	else
		self.velocity += force;
		
	if (MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self)) {
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);
	}
	if (damage > 50) {
		if (MayWeDoGibs(deathtype) && DamageTargIsNotWithinGrace(self)) {
			if not((deathtype == DEATH_HURTLASER) || (DEATH_ISWEAPON(deathtype, WEP_STARLASE)) || (DEATH_ISWEAPON(deathtype, WEP_SUNBEAM)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII)))
			{
				Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
			}
		}
	}
	if (damage > 100) {
		if (MayWeDoGibs(deathtype) && DamageTargIsNotWithinGrace(self)) {
			if not((deathtype == DEATH_HURTLASER) || (DEATH_ISWEAPON(deathtype, WEP_STARLASE)) || (DEATH_ISWEAPON(deathtype, WEP_SUNBEAM)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII)))
			{
				Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);
			}
		}
	}
		
	if(self.health <= 0)
	{	 
		if (DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER) && !autocvar_g_balance_multitool_ondth_fx_survives_nuke) {
			//Do nothing
		} else {
			if (self.trapondth) {
				if (allow_trapondth(self)) {
					trapspring_xyzz(self.trapondth_trap, self.trapondth_dirstyle, self.trapondth_amnt, self, self.origin+'0 0 16', attacker, 0.1);
				}
			}
			
			if(self.spwnmnstrondth) {
				//monster_spwnmnstrondth(self, 0.001, '0 0 0', 0); //Debug
				monster_spwnmnstrondth(self, 0.5+(frametime*5)+(random()*0.1), '0 0 0', 0);
			}
			
			if(self.readscrollondth) {
				if (self.readscrollondth_notdth) {
					//We must only be for onput or ontake
					//(traps)
				} else {
				//monster_readscrollondth(self, 0.001, '0 0 0', 0, 0); //Debug
				monster_readscrollondth(self, 0.01+frametime, '0 0 0', 0, 1);
				}
			}
			
			if(self.xplodondth) {
				multitool_xplodondth(self, self.origin, attacker, PROJECTILE_BULLETSHRAPNELDARK);
			}
		}
		
		//print(ftos(self.health),"\n");
		if(damage >= autocvar_sv_gibhealth)
		if((MayWeDoGibs(deathtype)) ||
			((self.species == SPECIES_SKELETON) && (self.health <= -55) && 
			((DEATH_ISWEAPON(deathtype, WEP_WARHAMMERSPIKED))
			|| (DEATH_ISWEAPON(deathtype, WEP_GREYIRONMALLET))
			|| (DEATH_ISWEAPON(deathtype, WEP_ELVENHAMMER))
			|| (DEATH_ISWEAPON(deathtype, WEP_QUARTERSTAFF))
			|| (DEATH_ISWEAPON(deathtype, WEP_BRONZECUDGEL))
			|| (DEATH_ISWEAPON(deathtype, WEP_SPIKEDCUDGEL))
			|| (DEATH_ISWEAPON(deathtype, WEP_CUDGEL))
			|| (DEATH_ISWEAPON(deathtype, WEP_TETSUBO))
			|| (DEATH_ISWEAPON(deathtype, WEP_FLANGEDMACE))
			|| (deathtype == DEATH_HOLYBOLT)
			|| ((DEATH_ISWEAPON(deathtype, WEP_POLEAXE)) && (deathtype & HITTYPE_SECONDARY))
			|| ((DEATH_ISWEAPON(deathtype, WEP_BARDICHE)) && (deathtype & HITTYPE_SECONDARY))
			|| (DEATH_ISWEAPON(deathtype, WEP_FIGHTERSWORD))
			|| (DEATH_ISWEAPON(deathtype, WEP_WARAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_BATTLEAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_TEMPLARAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_SKIRMISHERSAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_WOODAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_AXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_BEARDEDAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_DOUBLEBITAXE))
			|| (DEATH_ISWEAPON(deathtype, WEP_BROADAXE))))
		)
		{
			//dprint("GIB\n");
			if ((deathtype == DEATH_HURTLASER) || (DEATH_ISWEAPON(deathtype, WEP_STARLASE)) || (DEATH_ISWEAPON(deathtype, WEP_SUNBEAM)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)) || (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII)))
			{
				if (self.monster_lasernosteam) {
					//Skeleton does not much flesh/water to steam
					Violence_GibSplash(self, 1, 1, attacker);
				} else {
					Violence_GibSplash(self, 4, 1, attacker);
				}
			} else {
				Violence_GibSplash(self, 1, 1, attacker);
			}
			self.alpha = -1;
			self.takedamage	 	= DAMAGE_NO;
			self.event_damage   = func_null;
		}
	
		if(self.sprite)
		{
			// Update one more time to avoid waypoint fading without emptying healthbar
			WaypointSprite_UpdateHealth(self.sprite, 0);
		}
		
		if(self.flags & MONSTERFLAG_MINIBOSS) // TODO: cvarise the weapon drop?
			W_ThrowNewWeapon(self, WEP_NEX, 0, self.origin, self.velocity);
			
		
		
		RecordIfBurnedOtherToDeath (attacker, inflictor, self, deathtype);
		
		activator = attacker;
		other = self.enemy;
		self.target = self.target2;
		self.target2 = "";
		SUB_UseTargets();
		
		self.deadflag = DEAD_DEAD;
		self.monster_die();	
	}
  }
}

// used to hook into monster post death functions without a mutator
void monster_hook_death()
{
	if(self.sprite)
        WaypointSprite_Kill(self.sprite);
		
	if(self.realowner.flags & FL_CLIENT)
		self.realowner.monstercount -= 1;
		
	if(!(self.spawnflags & MONSTERFLAG_SPAWNED) && !self.monster_respawned)
		monsters_killed += 1;
		
	if(self.realowner.flags & FL_CLIENT)
			self.realowner.monstercount -= 1;
		
	totalspawned -= 1;
	
	if (self.stoned)
	{
		self.stonedorigin = self.origin;
	}
	
	if (self.body_phal) self.body_phal.alpha = 0.001;
	
	self.handcuffed = 0;
	if (self.prisonerlevel == 1) self.prisonerlevel = 0;
	self.jailee = world;
	
	self.darkritual_mana_max = 0;
	self.darkritual_mana_stable = 0;
	self.hasmanashield = 0;
	self.hascastfromlife = 0;
	self.hasclairvoyance = 0;
	self.tempmangled_l = 0;
	self.tempmangled_r = 0;
	self.temphobbled_l = 0;
	self.temphobbled_r = 0;
	self.tempmanhoblocked = 0;
	self.tempmanhobheal_nexttime = 0;
	self.tempmovementimpared = 0;
	self.tempmvmntimprdlocked = 0;
	self.tempmvmntimprdheal_nexttime = 0;
	self.prisoner2_suffering = 0;
	self.prisoner3_suffering = 0;
	self.fire_oilfire_entreignite = 0;
	self.fire_oilfire_entreignite_owner = world;
	self.fire_oilfire_entwasinoil = 0;
	if (self.holylightspellent && (self.holylightspellent != world)) {
		self.holylightspellent.realowner = world;
	}
	self.holylightspellent = world;
	self.hasmanashield = 0;
	
	ZeroOutVulnsResistsBuffs(self);
	
	self.monster_marshal = world;
	//////////////////////////////////////////////
	//Start removing crossbow bolts etc at death//
	local entity dropent;
	dropent = find(world, classname, "drop_at_death");
	while(dropent)
	{
	 	if (dropent.tag_entity == self)
		{
			//remove(dropent);
			dropent.origin = gettaginfo(dropent, 0);
			dropent.angles = vectoangles2(v_forward, v_up);
			dropent.tag_entity = world;
			dropent.movetype = MOVETYPE_TOSS;
		}
		dropent = find(dropent, classname, "drop_at_death");
	}
	//End removing crossbow bolts etc at death//
	////////////////////////////////////////////
	
	MUTATOR_CALLHOOK(MonsterDies);
}

// used to hook into monster post spawn functions without a mutator
void monster_hook_spawn()
{
	self.health *= monster_skill; // skill based monster health?
	
	if (self.isweak || self.isveryweak) {
		if (self.isveryweak
			&& (self.isveryweak >= 1
			|| self.isveryweak > random())) {
				//print("MonsterIsVeryWeak\n");
				self.health = self.health * 0.01;
		} else if (self.isweak
			&& (self.isweak >= 1
			|| self.isweak > random())) {
				//print("MonsterIsWeak\n");
				self.health = self.health * 0.1;
		}
	}
	
	self.max_health = self.health;
	self.alpha = 1;
	
	if (self.prisonerlevel <= 1) {
		self.prisonerdamageonrelease = 0;
		self.prisonerdamagetypeonrelease = 0;
	} else if (self.prisonerlevel == 3) {
		if (self.prison3ent != world)
		{
			if (self.prison3ent.prisondamageonrelease) {
				self.prisondamageonrelease = self.prison3ent.prisondamageonrelease;
				if (self.prison3ent.prisondamagetypeonrelease) {
					self.prisondamagetypeonrelease = self.prison3ent.prisondamagetypeonrelease;
				}
			}
		}
	}
	
	if(self.frozen)
		Unfreeze(self); //Unfreeze
	
	if(self.stoned)
	{
		if not(self.stoneskin == -1) {
			self.skin = self.stoneskin;
			self.stoned = 1;
		} else {
			self.colormod = '-2 -2 -2';
			self.stoned = 2;
		}
	}
	else if (self.prisonerlevel == 2)
	{
		setorigin (self, self.prison2spot);
	}
	else if (self.prisonerlevel == 3)
	{
		self.angles = self.prison3angles;
		setorigin (self, self.prison3spot);
	}
	
	if(teamplay && autocvar_g_monsters_teams)
	{
		if not(self.monster_noteamcolors) {
			self.colormod = TeamColor(self.team);
		}
		self.monster_attack = TRUE;
	}
	
	if (self.target)
	{
		self.target2 = self.target;
		self.goalentity = find(world, targetname, self.target);
		if (!self.goalentity)
			monster_spawnwanderpath();
	}
	else
		monster_spawnwanderpath();
		
	if(autocvar_g_monsters_healthbars)
	{
		WaypointSprite_Spawn(self.netname, 0, 600, self, '0 0 1' * self.sprite_height, world, 0, self, sprite, FALSE, RADARICON_DANGER, ((teamplay) ? TeamColor(self.team) : '1 0 0'));	
		WaypointSprite_UpdateMaxHealth(self.sprite, self.max_health);
		WaypointSprite_UpdateHealth(self.sprite, self.health);
	}
	
	MUTATOR_CALLHOOK(MonsterSpawn);
}

void monster_imprisoned()
{
	if(self.handcuffed)
	{
		if (self.jailor != world)
		{
			self.origin = self.jailor.origin + self.prison1spot;
			setorigin(self, self.origin);
		}
	} else if (self.prisonerlevel == 3)
	{
		if (self.prison3ent != world)
		{
			self.prison3angles = self.prison3ent.angles;
			self.prison3spot = self.prison3ent.origin;
		}
		
		self.angles = self.prison3angles;

		if (self.origin != self.prison3spot)
		{	
			self.origin = self.prison3spot;
			setorigin(self, self.origin);
		}	
		if (self.movetype != MOVETYPE_NONE)
			self.movetype = MOVETYPE_NONE;	
	}
}

void monster_hook_think()
{
	monster_imprisoned();
}

float monster_initialize(string  net_name,
						 string  bodymodel,
						 vector  min_s,
						 vector  max_s,
						 float   nodrop,
						 void() dieproc,
						 void() spawnproc)
{
	if(!autocvar_g_monsters)
		return FALSE;
		
	// support for quake style removing monsters based on skill
	if(autocvar_skill <= autocvar_g_monsters_skill_easy && (self.spawnflags & MONSTERSKILL_NOTEASY)) { return FALSE; }
	else if(autocvar_skill == autocvar_g_monsters_skill_normal && (self.spawnflags & MONSTERSKILL_NOTMEDIUM)) { return FALSE; }
	else if(autocvar_skill == autocvar_g_monsters_skill_hard && (self.spawnflags & MONSTERSKILL_NOTHARD)) { return FALSE; }
	else if(autocvar_skill == autocvar_g_monsters_skill_insane && (self.spawnflags & MONSTERSKILL_NOTINSANE)) { return FALSE; }
	else if(autocvar_skill >= autocvar_g_monsters_skill_nightmare && (self.spawnflags & MONSTERSKILL_NOTNIGHTMARE)) { return FALSE; }

	if(self.model == "")
	if(bodymodel == "")
		error("monsters: missing bodymodel!");

	if(self.netname == "")
	{
		if(net_name != "" && self.realowner.classname == STR_PLAYER)
			net_name = strzone(strdecolorize(sprintf("%s's %s", self.realowner.netname, net_name)));
		self.netname = ((net_name == "") ? self.classname : net_name);
	}
	
	if(self.spawnflags & MONSTERFLAG_GIANT && !autocvar_g_monsters_nogiants)
		ScaleMonster(5);
	else if(!self.scale)
		ScaleMonster(1);
	else
		ScaleMonster(self.scale);
		
	Monster_CheckMinibossFlag();
		
	min_s *= self.scale;
	max_s *= self.scale;

	if(self.team && !teamplay)
		self.team = 0;

	self.flags = FL_MONSTER;
	
	if(self.model != "")
		bodymodel = self.model;
		
	if not(self.spawnflags & MONSTERFLAG_SPAWNED) // naturally spawned monster
	if not(!self.monster_respawned)
		monsters_total += 1;
	
	precache_model(bodymodel);

	setmodel(self, bodymodel);
	
	if (self.monster_painsoundset == 1) {
		precache_sound ("flare/fantasycore/enemies/skeleton-hit.ogg");
		precache_sound ("flare/fantasycore/enemies/skeleton-die.ogg");
	} else if (self.monster_painsoundset == 2) {
		precache_sound ("flare/fantasycore/enemies/zombie-critdie.ogg");
		precache_sound ("flare/fantasycore/enemies/zombie-die.ogg");
		precache_sound ("flare/fantasycore/enemies/zombie-hit.ogg");
	} else if (self.monster_painsoundset == 3) {
		precache_sound ("flare/fantasycore/enemies/minotaur_hit.ogg");
		precache_sound ("flare/fantasycore/enemies/minotaur-phys.ogg");
	}
	
	setsize(self, min_s, max_s);

	self.takedamage		 	= DAMAGE_AIM;
	self.bot_attack		 	= TRUE;
	self.iscreature		 	= TRUE;
	self.teleportable	   	= TRUE;
	self.damagedbycontents	= TRUE;
	self.damageforcescale   = 0.003;
	self.monster_die		= dieproc;
	self.event_damage	   	= monsters_damage;
	self.touch			  	= MonsterTouch;
	self.use				= monster_use;
	self.solid				= SOLID_BBOX;
	self.movetype			= MOVETYPE_WALK;
	self.delay				= -1; // used in attack delay code
	monsters_spawned	   += 1;
	self.think				= spawnproc;
	self.nextthink			= time;
	self.enemy				= world;
	self.velocity			= '0 0 0';
	self.moveto				= self.origin;
	self.pos1				= self.origin;
	self.pos2				= self.angles;
	self.deadflag                   = DEAD_NO; // UNDEAD
	self.dphitcontentsmask  = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_BOTCLIP | DPCONTENTS_MONSTERCLIP;
	
	if not(self.monster_moveflags)
		self.monster_moveflags = MONSTER_MOVE_WANDER;

	if(autocvar_g_nodepthtestplayers)
		self.effects |= EF_NODEPTHTEST;

	if(autocvar_g_fullbrightplayers)
		self.effects |= EF_FULLBRIGHT;

	if not(nodrop)
	{
		setorigin(self, self.origin);
		
		if (self.monster_nodrop) {
			//Set per entity, example: in w_multitool
			//Do nothing more, no drop
		} else {
			tracebox(self.origin + '0 0 100', min_s, max_s, self.origin - '0 0 10000', MOVE_WORLDONLY, self);
			setorigin(self, trace_endpos);
		}
	}

	return TRUE;
}

entity spawnmonster (string monster, entity spawnedby, entity own, vector orig, float respwn, float moveflag);
void monster_spwnmnstrondth_do (entity dthent)
{	
	if (dthent.spwnmnstrondth >= 1) {
		//Do nothing
	} else if (dthent.spwnmnstrondth > random()) {
		//Do nothing
	} else {
		return;
	}
	
	if (!dthent.origin_x
	&& !dthent.origin_y
	&& !dthent.origin_z) {
		//print("monster_spwnmnstrondth given 0 0 0 origin, probably an error, not commencing spawn\n");
		return;
	}
	
	entity theoldself;
	entity mon;
	float mycount;
	float mymax;
	theoldself = self;
	
	if (dthent.spwnmnstrondth_amnt > 1) {
		mymax = dthent.spwnmnstrondth_amnt;
	} else {
		mymax = 1;
	}
	
	mycount = 0;
	while (mymax > mycount) {
		//print("SPAWING MONSTER ON DEATH for ", etos(dthent), "\n");
		mon = spawnmonster(dthent.spwnmnstrondth_monster, dthent, dthent, dthent.origin, dthent.spwnmnstrondth_respawns, 2);
		if (mon == world) {
			//print("Spawning Monster Failed - Monster is world\n");
		} else if (dthent.spwnmnstrondth_propagate || dthent.spwnmnstrondth_propagateinf) {
			mon.spwnmnstrondth = dthent.spwnmnstrondth;
			mon.spwnmnstrondth_monster = dthent.spwnmnstrondth_monster;
			mon.spwnmnstrondth_amnt = dthent.spwnmnstrondth_amnt;
			mon.spwnmnstrondth_respawns = dthent.spwnmnstrondth_respawns;
			if (dthent.spwnmnstrondth_propagateinf) {
				mon.spwnmnstrondth_propagateinf = dthent.spwnmnstrondth_propagateinf;
				mon.spwnmnstrondth_propagate = dthent.spwnmnstrondth_propagate;
			} else if (dthent.spwnmnstrondth_propagate >= 2) {
				//propagate a number of times
				mon.spwnmnstrondth_propagate = dthent.spwnmnstrondth_propagate - 1;
			}
		}
		
		if (dthent.readscrollondth_propagate || dthent.readscrollondth_propagateinf) {
			if (dthent.readscrollondth) {
				if (dthent.readscrollondth_spell != "") {
					mon.readscrollondth = dthent.readscrollondth;
					mon.readscrollondth_spell = dthent.readscrollondth_spell;
					mon.readscrollondth_amnt = dthent.readscrollondth_amnt;
					mon.readscrollondth_lvl = dthent.readscrollondth_lvl;
					mon.readscrollondth_genincrease = dthent.readscrollondth_genincrease;
					mon.readscrollondth_propagatespell = dthent.readscrollondth_propagatespell;
					if (dthent.readscrollondth_propagateinf) {
						mon.readscrollondth_propagateinf = dthent.readscrollondth_propagateinf;
						mon.readscrollondth_propagate = dthent.readscrollondth_propagate;
					} else if (dthent.readscrollondth_propagate >= 2) {
						//propagate a number of times
						mon.readscrollondth_propagate = dthent.readscrollondth_propagate - 1;
					}
					mon.readscrollondth_gen = dthent.readscrollondth_gen + 1;
				}
			}
		}
		
		
		mycount = mycount + 1;
	}
	
	
	self = theoldself;
}

void monster_spwnmnstrondth_think()
{
	//print("do m think\n");
	monster_spwnmnstrondth_do(self);
	remove(self);
}

void monster_spwnmnstrondth (entity dthent, float dlytime, vector myoffset, float useoffsetasorigin)
{
	if (dthent.spwnmnstrondth) {
		entity e;
		e = spawn();
		e.spwnmnstrondth = dthent.spwnmnstrondth;
		e.spwnmnstrondth_monster = dthent.spwnmnstrondth_monster;
		e.spwnmnstrondth_amnt = dthent.spwnmnstrondth_amnt;
		e.spwnmnstrondth_respawns = dthent.spwnmnstrondth_respawns;
		e.spwnmnstrondth_propagate = dthent.spwnmnstrondth_propagate;
		e.spwnmnstrondth_propagateinf = dthent.spwnmnstrondth_propagateinf;
		if (useoffsetasorigin) {
			e.origin = myoffset;
		} else {
			e.origin = dthent.origin;
			e.origin_x = e.origin_x + myoffset_x;
			e.origin_y = e.origin_y + myoffset_y;
			e.origin_z = e.origin_z + myoffset_z;
		}
		
		if (dthent.readscrollondth_propagate || dthent.readscrollondth_propagateinf) {
			if (dthent.readscrollondth) {
				if (dthent.readscrollondth_spell == ""
				&& dthent.readscrollondth_propagatespell == "") {
					//Do nothing
				} else {
				e.readscrollondth = dthent.readscrollondth;
				e.readscrollondth_spell = dthent.readscrollondth_spell;
				e.readscrollondth_amnt = dthent.readscrollondth_amnt;
				e.readscrollondth_lvl = dthent.readscrollondth_lvl;
				e.readscrollondth_genincrease = dthent.readscrollondth_genincrease;
				e.readscrollondth_propagateinf = dthent.readscrollondth_propagateinf;
				e.readscrollondth_propagate = dthent.readscrollondth_propagate;
				e.readscrollondth_propagatespell = dthent.readscrollondth_propagatespell;
						if (e.readscrollondth_propagatespell != "") {
							//print("Setting spell to the propagate spell\n");
							e.readscrollondth_spell = dthent.readscrollondth_propagatespell;
						}
				e.readscrollondth_gen = dthent.readscrollondth_gen;
				}
			}
		}
		
		e.takedamage = DAMAGE_NO;
		e.think = monster_spwnmnstrondth_think;
		e.nextthink = time + dlytime;
	}
}

//////



void monster_readscrollondth_do (entity dthent)
{	
	if (dthent.readscrollondth >= 1) {
		//Do nothing
	} else if (dthent.readscrollondth > random()) {
		//Do nothing
	} else {
		return;
	}
	
	if (dthent.readscrollondth_propagateonly) {
		//print("Only propogating\n");
		return;
	}
	
	if (dthent.readscrollondth_spell == "") {
		//print("no spell stated\n");
		return;
	}
	
	if (!dthent.origin_x
	&& !dthent.origin_y
	&& !dthent.origin_z) {
		//print("monster_readscrollondth given 0 0 0 origin, probably an error, not commencing spawn\n");
		return;
	}
	
	entity theoldself;
	entity mon;
	float mycount;
	float mymax;
	float myspelllvl;
	theoldself = self;
	
	if (dthent.readscrollondth_amnt > 1) {
		mymax = dthent.readscrollondth_amnt;
	} else {
		mymax = 1;
	}
	
	if (dthent.readscrollondth_lvl >= 1) {
		myspelllvl = dthent.readscrollondth_lvl;
	} else {
		myspelllvl = 5; //Standard scroll level
	}
	
	//print(ftos(dthent.readscrollondth_genincrease), " Gen Increase\n");
	//print(ftos(dthent.readscrollondth_gen), " generation\n");
	
	if (dthent.readscrollondth_genincrease && dthent.readscrollondth_gen) {
		if (dthent.readscrollondth_genincrease < 1) {
			//Spell levels can fade away with the generations...
			//myspelllvl = myspelllvl * (dthent.readscrollondth_genincrease/dthent.readscrollondth_gen);
			print("Spell level decreased to", ftos(myspelllvl),"\n");
		} else {
			//Or they can increase
			//myspelllvl = myspelllvl * dthent.readscrollondth_genincrease * dthent.readscrollondth_gen;
			print("Spell level increased to", ftos(myspelllvl),"\n");
		}
	}
	
	if (myspelllvl < 1) {
		//print("Spell level lower than 1, not casting\n");
	} else {
		mycount = 0;
		while (mymax > mycount) {
			//print("READING SCROLL ON DEATH for ", etos(dthent), "\n");
					
			if (dthent.readscrollondth_spell != "") {
				local float myresetstuff;
				local float myoldsolidtype;
				local vector myoldorigin;
				
				myresetstuff = 0;
				if (dthent.subordinate10
				&& dthent.subordinate10 != world) {
					myresetstuff = 1;
					myoldsolidtype = dthent.subordinate10.solid;
					if (dthent.subordinate10.iscontainer_storage) {
						myresetstuff = 2;
						myoldorigin = dthent.origin;
						
						//Dealing with the put/take/search code
						
						dthent.subordinate10.solid = SOLID_NOT;
						makevectors(dthent.v_angle);
						traceline(dthent.origin, (dthent.origin)+(v_forward *32), MOVE_NORMAL, dthent.subordinate10);
						dthent.origin = trace_endpos;
					}
				}
				
				CastSpellByName(myspelllvl, dthent, dthent.readscrollondth_spell);
				
				if (dthent.subordinate10
				&& dthent.subordinate10 != world) {
					if (myresetstuff) {
						dthent.subordinate10.solid = myoldsolidtype;
					}
				}
				
				if (myresetstuff == 2) {
					dthent.origin = myoldorigin;
				}
			}
			
			mycount = mycount + 1;
		}
	}
	
	
	self = theoldself;
}
void monster_readscrollondth_think()
{
	//print("do scr think\n");
	//print(vtos(self.angles), vtos(self.v_angle), "\n");
	monster_readscrollondth_do(self);
	remove(self);
}

void monster_readscrollondth (entity dthent, float dlytime, vector myoffset, float useoffsetasorigin, float mystvagls)
{
	if (dthent.readscrollondth) {
	if (dthent.readscrollondth_spell == ""
	&& dthent.readscrollondth_propagatespell == "") {
		//Do nothing
	} else {
		entity e;
		e = spawn();
		e.angles = dthent.angles;
		if (mystvagls) {
			//for buildings, barrels, etc
			e.v_angle = dthent.angles;
			if (mystvagls != 1) {
				e.v_angle_y = e.v_angle_y + mystvagls;
			}
		} else {
			e.v_angle = dthent.v_angle;
		}
		e.subordinate10 = dthent;
		e.readscrollondth = dthent.readscrollondth;
		e.readscrollondth_spell = dthent.readscrollondth_spell;
		e.readscrollondth_amnt = dthent.readscrollondth_amnt;
		e.readscrollondth_lvl = dthent.readscrollondth_lvl;
		e.readscrollondth_genincrease = dthent.readscrollondth_genincrease;
		e.readscrollondth_gen = dthent.readscrollondth_gen;
		e.readscrollondth_propagate = dthent.readscrollondth_propagate;
		e.readscrollondth_propagateinf = dthent.readscrollondth_propagateinf;
		e.readscrollondth_propagateonly = dthent.readscrollondth_propagateonly;
		e.readscrollondth_propagatespell = dthent.readscrollondth_propagatespell;
		if (useoffsetasorigin) {
			e.origin = myoffset;
		} else {
			e.origin = dthent.origin;
			e.origin_x = e.origin_x + myoffset_x;
			e.origin_y = e.origin_y + myoffset_y;
			e.origin_z = e.origin_z + myoffset_z;
		}
		e.nohitplotanalysis = 1; //We aren't a player nor are we a bot
		e.noaccuracyfrags = 1;
		e.takedamage = DAMAGE_NO;
		e.think = monster_readscrollondth_think;
		e.nextthink = time + dlytime;
	}
	}
}


