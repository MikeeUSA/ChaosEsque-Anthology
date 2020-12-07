#define ISF_LOCATION 2
#define ISF_MODEL    4
#define ISF_STATUS   8
    #define ITS_STAYWEP   1
    #define ITS_ANIMATE1  2
    #define ITS_ANIMATE2  4
    #define ITS_AVAILABLE 8
    #define ITS_ALLOWFB   16
    #define ITS_SCALE   32
    #define ITS_POWERUP   64
    #define ITS_SKIN      128 //Has a skin, so send the skin number
    
    #define ITS_ALLOWSI   256 //Sorry bro, we want to use you for scale instead, we'll find another way for you... maybe
    #define ITS_DOUBLESIDED      512
#define ISF_COLORMAP 16
#define ISF_DROP 32
#define ISF_ANGLES 64

//We should limit the amount to weapons we will precache from a target_items
//so that one is less likely to create a massive load time map
//or precache more models than the engine can inform the client of
#define TARGETITEMSPRECACHELIMIT 64
float target_items_current_precache_number;

.float ItemStatus;

#ifdef CSQC

var float  autocvar_cl_animate_items = 1;
var float  autocvar_cl_ghost_items = 0.45;
var vector autocvar_cl_ghost_items_color = '-1 -1 -1';
var float  autocvar_cl_fullbright_items = 0;
var vector autocvar_cl_weapon_stay_color = '2 0.5 0.5';
var float  autocvar_cl_weapon_stay_alpha = 0.75;
var float  autocvar_cl_simple_items = 0;
var string autocvr_cl_simpleitems_postfix = "_simple";
.float  spawntime;
.float  gravity;
.vector colormod;
void ItemDraw()
{    
    if(self.gravity)
    {        
        Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);
        if(self.move_flags & FL_ONGROUND) 
        { // For some reason move_avelocity gets set to '0 0 0' here ...
            self.oldorigin = self.origin;
            self.gravity = 0;

            if(autocvar_cl_animate_items)   
            { // ... so reset it if animations are requested. 
                if(self.ItemStatus & ITS_ANIMATE1)
                    self.move_avelocity = '0 180 0';
                
                if(self.ItemStatus & ITS_ANIMATE2)
                    self.move_avelocity = '0 -90 0';
            }
        }
    }
    else if (autocvar_cl_animate_items)
    {        
        if(self.ItemStatus & ITS_ANIMATE1)
        {
            self.angles += self.move_avelocity * frametime;
            setorigin(self, '0 0 10' + self.oldorigin + '0 0 8' * sin(time * 2));        
        }    
        
        if(self.ItemStatus & ITS_ANIMATE2)
        {
            self.angles += self.move_avelocity * frametime;
            setorigin(self, '0 0 8' + self.oldorigin + '0 0 4' * sin(time * 3));        
        }
    }
}

void ItemDrawSimple()
{
    if(self.gravity)
    {        
        Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);    
        
        if(self.move_flags & FL_ONGROUND)
            self.gravity = 0;
    }
}

void ItemRead(float _IsNew)
{
    float sf = ReadByte();

    if(sf & ISF_LOCATION)
    {
        self.origin_x = ReadCoord();
        self.origin_y = ReadCoord();
        self.origin_z = ReadCoord();
        setorigin(self, self.origin);
        self.oldorigin = self.origin;
    }
    
    if(sf & ISF_ANGLES) 
    {
        self.angles_x = ReadCoord();
        self.angles_y = ReadCoord();
        self.angles_z = ReadCoord();        
        self.move_angles = self.angles;
    }
    
    if(sf & ISF_STATUS) // need to read/write status frist so model can handle simple, fb etc.
    {
        //self.ItemStatus = ReadByte();
        self.ItemStatus = ReadShort();
	
	//print(ftos(self.ItemStatus), "Recieved ItemStatus\n"); 
        
        if(self.ItemStatus & ITS_AVAILABLE)
        {
            self.alpha = 1;
            self.colormod = self.glowmod = '1 1 1';
        }
        else
        {
            if (autocvar_cl_ghost_items_color)
            {
                self.alpha = autocvar_cl_ghost_items;
                self.colormod = self.glowmod = autocvar_cl_ghost_items_color;
            }
            else
                self.alpha = -1;
        }    
        
        if(autocvar_cl_fullbright_items)
            if(self.ItemStatus & ITS_ALLOWFB)
                self.effects |= EF_FULLBRIGHT;
            
        if(self.ItemStatus & ITS_STAYWEP)
        {
            self.colormod = self.glowmod = autocvar_cl_weapon_stay_color;
            self.alpha = autocvar_cl_weapon_stay_alpha;
            
        }
        
        if(self.ItemStatus & ITS_POWERUP)
        {
            if(self.ItemStatus & ITS_AVAILABLE)
                self.effects |= (EF_ADDITIVE | EF_FULLBRIGHT);
            else
                 self.effects &~= (EF_ADDITIVE | EF_FULLBRIGHT);
        }
	
	if(self.ItemStatus & ITS_SKIN) {
    		self.skin = ReadShort();
   		//print("Skin info read\n");
    	}
	
	if(self.ItemStatus & ITS_SCALE) {
		self.scale = ReadShort() / 32; //Scale
    	}
    }
    
    if(sf & ISF_MODEL)
    {
        self.drawmask  = MASK_NORMAL;
        self.movetype  = MOVETYPE_NOCLIP;
        self.draw       = ItemDraw;
        
        if(self.mdl)
            strunzone(self.mdl);
        
        self.mdl = "";
        string _fn = ReadString();
	
	if (self.ItemStatus & ITS_DOUBLESIDED)
	{
		//print("Doublesided\n");
		self.effects |= EF_DOUBLESIDED;
	}
        
        if(autocvar_cl_simple_items && (self.ItemStatus & ITS_ALLOWSI))
        {
            string _fn2 = substring(_fn, 0 , strlen(_fn) -4);
            self.draw = ItemDrawSimple;
                    
            
            
            if(fexists(sprintf("%s%s.md3", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.md3", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.dpm", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.dpm", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.iqm", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.iqm", _fn2, autocvr_cl_simpleitems_postfix));
            else if(fexists(sprintf("%s%s.obj", _fn2, autocvr_cl_simpleitems_postfix)))
                self.mdl = strzone(sprintf("%s%s.obj", _fn2, autocvr_cl_simpleitems_postfix));
            else
            {
                self.draw = ItemDraw;
                dprint("Simple item requested for ", _fn, " but no model exsist for it\n");
            }
        }
        
        if(self.draw != ItemDrawSimple)        
            self.mdl = strzone(_fn);                
        
        
        if(self.mdl == "")
            dprint("^1WARNING!^7 self.mdl is unset for item ", self.classname, " tell tZork aboute this!\n");
        
        precache_model(self.mdl);
        setmodel(self, self.mdl);
    }
    
    if(sf & ISF_COLORMAP) {
    	local float isawpn;
        self.colormap = ReadShort();
	
	isawpn = ReadByte();
	if (isawpn) {
		//print("Is a weapon\n");
		CSQCPlayer_GlowMod_Apply();
	}
    }
    
    if(sf & ISF_DROP)
    {
        self.gravity = 1;
        self.move_angles = '0 0 0';
        self.move_movetype = MOVETYPE_TOSS;
        self.move_velocity_x = ReadCoord();
        self.move_velocity_y = ReadCoord();
        self.move_velocity_z = ReadCoord();
        self.velocity = self.move_velocity;
        self.move_origin = self.oldorigin;
        
        if(!self.move_time)
        {
            self.move_time = time;
            self.spawntime = time;
        }
        else
            self.move_time = max(self.move_time, time);
    }
        
    if(autocvar_cl_animate_items)
    {        
        if(self.ItemStatus & ITS_ANIMATE1)
            self.move_avelocity = '0 180 0';
                
        if(self.ItemStatus & ITS_ANIMATE2)
            self.move_avelocity = '0 -90 0';
    }
}

#endif

#ifdef SVQC
float autocvar_sv_simple_items;
float ItemSend(entity to, float sf)
{
    if(self.gravity)
        sf |= ISF_DROP;
    else
        sf &~= ISF_DROP;
	
	WriteByte(MSG_ENTITY, ENT_CLIENT_ITEM);	
	WriteByte(MSG_ENTITY, sf);

	//WriteByte(MSG_ENTITY, self.cnt);
    if(sf & ISF_LOCATION)
    {
        WriteCoord(MSG_ENTITY, self.origin_x);
        WriteCoord(MSG_ENTITY, self.origin_y);
        WriteCoord(MSG_ENTITY, self.origin_z);
    }
    
    if(sf & ISF_ANGLES)
    {
        WriteCoord(MSG_ENTITY, self.angles_x);
        WriteCoord(MSG_ENTITY, self.angles_y);
        WriteCoord(MSG_ENTITY, self.angles_z);
    }

    //print(ftos(self.ItemStatus), "Item Status for sending\n");
    if(sf & ISF_STATUS) {
        //WriteByte(MSG_ENTITY, self.ItemStatus);
        WriteShort(MSG_ENTITY, self.ItemStatus);

   	if(self.ItemStatus & ITS_SKIN) {
   		WriteShort(MSG_ENTITY, self.skin);
    		//print("skin info sent\n");
    	}
	
	if(self.ItemStatus & ITS_SCALE) {
		if (!self.scale)
			WriteShort(MSG_ENTITY, 32); //32 = scale 1 //Normally won't reach here since ITS_SCALE won't be set, but just incase
   		else if ((self.scale) && (self.scale < 0.04)) //Below this is 0, which is taken as "no scaling"
			WriteShort(MSG_ENTITY, 1);
		else
			WriteShort(MSG_ENTITY, floor(self.scale * 32));
    	}
    }
    
    if(sf & ISF_MODEL)
    {
        
        if(self.mdl == "")
            dprint("^1WARNING!^7 self.mdl is unset for item ", self.classname, "exspect a crash just aboute now\n");
        
        WriteString(MSG_ENTITY, self.mdl);
    }
        
        
    if(sf & ISF_COLORMAP) {
        WriteShort(MSG_ENTITY, self.colormap);
	
	//Lets inform our client if it is a weapon, if so we will apply glowmod clientside
	if (self.flags & FL_WEAPON) {
		WriteByte(MSG_ENTITY, 1);
	} else {
		WriteByte(MSG_ENTITY, 0);
	}
    }

    if(sf & ISF_DROP)
    {
        WriteCoord(MSG_ENTITY, self.velocity_x);
        WriteCoord(MSG_ENTITY, self.velocity_y);
        WriteCoord(MSG_ENTITY, self.velocity_z);
    }
    
    return TRUE;
}


void SUB_ItemSetToPerm (entity ent)
{
	ent.ItemStatus &~= ITS_ANIMATE1;
	ent.ItemStatus &~= ITS_ANIMATE2;
	ent.think = func_null;
	ent.nextthink = 0;
	Net_LinkEntity(self, FALSE, 0, ItemSend);
}

void SUB_ItemSetToPermWhen_Think (void)
{
	SUB_ItemSetToPerm(self);
}

void SUB_ItemSetToPermWhen (entity ent, float when)
{
	ent.think = SUB_ItemSetToPermWhen_Think;
	ent.nextthink = when;
}

//For Custom items you made which do not use the clientside code
//EG: Dropped single bullets
//Thus no netlink etc
void SUB_ItemServerSideSetToPerm (entity ent)
{
	ent.think = func_null;
	ent.nextthink = 0;
}

void SUB_ItemServerSideSetToPermWhen_Think (void)
{
	SUB_ItemServerSideSetToPerm(self);
}

void SUB_ItemServerSideSetToPermWhen (entity ent, float when)
{
	ent.think = SUB_ItemServerSideSetToPermWhen_Think;
	ent.nextthink = when;
}
//

float have_pickup_item(void)
{
	// minstagib: only allow filtered items
	if(g_minstagib)
		if(self.classname != "minstagib")
			return FALSE;

	if(self.flags & FL_POWERUP)
	{
		if(autocvar_g_powerups > 0)
			return TRUE;
		if(autocvar_g_powerups == 0)
			return FALSE;
		if(g_lms)
			return FALSE;
		if(g_ca)
			return FALSE;
		if(g_arena)
			return FALSE;
	}
	else
	{
		if(autocvar_g_pickup_items > 0)
			return TRUE;
		if(autocvar_g_pickup_items == 0)
			return FALSE;
		if(g_lms)
			return FALSE;
		if(g_ca)
			return FALSE;
		if(g_weaponarena)
			if(!WEPSET_EMPTY_E(self) || (self.items & IT_AMMO))
				return FALSE;
	}
	return TRUE;
}

#define ITEM_RESPAWN_TICKS 10

#define ITEM_RESPAWNTIME(i)         ((i).respawntime + crandom() * (i).respawntimejitter)
	// range: respawntime - respawntimejitter .. respawntime + respawntimejitter
#define ITEM_RESPAWNTIME_INITIAL(i) (ITEM_RESPAWN_TICKS + random() * ((i).respawntime + (i).respawntimejitter - ITEM_RESPAWN_TICKS))
	// range: 10 .. respawntime + respawntimejitter

floatfield Item_CounterField(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return ammo_shells;
		case IT_NAILS:       return ammo_nails;
		case IT_ROCKETS:     return ammo_rockets;
		case IT_CELLS:       return ammo_cells;
		case IT_FUEL:        return ammo_fuel;
		case IT_5HP:         return health;
		case IT_25HP:        return health;
		case IT_HEALTH:      return health;
		case IT_ARMOR_SHARD: return armorvalue;
		case IT_ARMOR:       return armorvalue;
		// add more things here (health, armor)
		default:             error("requested item has no counter field");
	}
#ifdef GMQCC
	// should never happen
	return health;
#endif
}

string Item_CounterFieldName(float it)
{
	switch(it)
	{
		case IT_SHELLS:      return "shells";
		case IT_NAILS:       return "nails";
		case IT_ROCKETS:     return "rockets";
		case IT_CELLS:       return "cells";
		case IT_FUEL:        return "fuel";

		// add more things here (health, armor)
		default:             error("requested item has no counter field name");
	}
#ifdef GMQCC
	// should never happen
	return string_null;
#endif
}

.float max_armorvalue;
.float pickup_anyway;
/*
float Item_Customize()
{
	if(self.spawnshieldtime)
		return TRUE;
	if(!WEPSET_CONTAINS_ALL_EE(other, self))
	{
		self.colormod = '0 0 0';
		self.glowmod = self.colormod;
		self.alpha = 0.5 + 0.5 * g_ghost_items; // halfway more alpha
		return TRUE;
	}
	else
	{
		if(g_ghost_items)
		{
			self.colormod = stov(autocvar_g_ghost_items_color);
			self.glowmod = self.colormod;
			self.alpha = g_ghost_items;
			return TRUE;
		}
		else
			return FALSE;
	}
}
*/

void Item_Show (entity e, float mode)
{    
	e.effects &~= EF_ADDITIVE | EF_STARDUST | EF_FULLBRIGHT | EF_NODEPTHTEST;
	e.ItemStatus &~= ITS_STAYWEP;
	if (mode > 0)
	{
		// make the item look normal, and be touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER;
		e.spawnshieldtime = 1;
		e.ItemStatus |= ITS_AVAILABLE;
	}
	else if (mode < 0)
	{
		// hide the item completely
		e.model = string_null;
		e.solid = SOLID_NOT;
		e.spawnshieldtime = 1;
		e.ItemStatus &~= ITS_AVAILABLE;
	}
	else if((e.flags & FL_WEAPON) && !(e.flags & FL_NO_WEAPON_STAY) && g_weapon_stay)
	{
		// make the item translucent and not touchable
		e.model = e.mdl;
		e.solid = SOLID_TRIGGER; // can STILL be picked up!
		e.effects |= EF_STARDUST;
		e.spawnshieldtime = 0; // field indicates whether picking it up may give you anything other than the weapon
		e.ItemStatus |= (ITS_AVAILABLE | ITS_STAYWEP);
	}
	else
	{
		//setmodel(e, "null");
		e.solid = SOLID_NOT;
		e.colormod = '0 0 0';
		e.glowmod = e.colormod;
		e.spawnshieldtime = 1;
		e.ItemStatus &~= ITS_AVAILABLE;
	}
	
	if (e.items & IT_STRENGTH || e.items & IT_INVINCIBLE)
	    e.ItemStatus |= ITS_POWERUP;    		
	
	if (autocvar_g_nodepthtestitems)
		e.effects |= EF_NODEPTHTEST;
		
    
    if (autocvar_g_fullbrightitems)
		e.ItemStatus |= ITS_ALLOWFB;
	
	if (autocvar_sv_simple_items)
        e.ItemStatus |= ITS_ALLOWSI;

	// relink entity (because solid may have changed)
	setorigin(e, e.origin);
    e.SendFlags |= ISF_STATUS;
}

void Item_Respawn (void)
{
	Item_Show(self, 1);
	if(!g_minstagib && self.items == IT_STRENGTH)
		sound (self, CH_TRIGGER, "misc/strength_respawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	else if(!g_minstagib && self.items == IT_INVINCIBLE)
		sound (self, CH_TRIGGER, "misc/shield_respawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	else
		sound (self, CH_TRIGGER, "misc/itemrespawn.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);

	//pointparticles(particleeffectnum("item_respawn"), self.origin + self.mins_z * '0 0 1' + '0 0 48', '0 0 0', 1);
	pointparticles(particleeffectnum("item_respawn"), self.origin + 0.5 * (self.mins + self.maxs), '0 0 0', 1);
}

void Item_RespawnCountdown (void)
{
	if(self.count >= ITEM_RESPAWN_TICKS)
	{
		if(self.waypointsprite_attached)
			WaypointSprite_Kill(self.waypointsprite_attached);
		Item_Respawn();
	}
	else
	{
		self.nextthink = time + 1;
		self.count += 1;
		if(self.count == 1)
		{
			string name;
			vector rgb = '1 0 1';
			name = string_null;
			if(g_minstagib)
			{
				switch(self.items)
				{
					case IT_STRENGTH:   name = "item-invis"; rgb = '0 0 1'; break;
					case IT_NAILS:      name = "item-extralife"; rgb = '1 0 0'; break;
					case IT_INVINCIBLE: name = "item-speed"; rgb = '1 0 1'; break;
				}
			}
			else
			{
				switch(self.items)
				{
					case IT_STRENGTH:   name = "item-strength"; rgb = '0 0 1'; break;
					case IT_INVINCIBLE: name = "item-shield"; rgb = '1 0 1'; break;
				}
			}
			switch(self.items)
			{
				case IT_FUEL_REGEN:     name = "item-fuelregen"; rgb = '1 0.5 0'; break;
				case IT_JETPACK:        name = "item-jetpack"; rgb = '0.5 0.5 0.5'; break;
			}
			if(self.flags & FL_WEAPON)
			{
				entity wi = get_weaponinfo(self.weapon);
				if(wi)
				{
					name = wi.model2;
					rgb = '1 0 0';
				}
			}
			if(name)
			{
				WaypointSprite_Spawn(name, 0, 0, self, '0 0 64', world, 0, self, waypointsprite_attached, TRUE, RADARICON_POWERUP, rgb);
				if(self.waypointsprite_attached)
					WaypointSprite_UpdateBuildFinished(self.waypointsprite_attached, time + ITEM_RESPAWN_TICKS);
			}
			else
			{
				print("Unknown powerup-marked item is wanting to respawn\n");
				localcmd(sprintf("prvm_edict server %d\n", num_for_edict(self)));
			}
		}
		sound (self, CH_TRIGGER, "misc/itemrespawncountdown.wav", VOL_BASE, ATTN_NORM);	// play respawn sound
		if(self.waypointsprite_attached)
		{
			WaypointSprite_Ping(self.waypointsprite_attached);
			//WaypointSprite_UpdateHealth(self.waypointsprite_attached, self.count);
		}
	}
}

void Item_ScheduleRespawnVarIn(entity e, float t, float a)
{
	if((e.flags & FL_POWERUP) || WEPSET_CONTAINS_ANY_EA(e, WEPBIT_SUPERWEAPONS))
	{
		e.think = Item_RespawnCountdown;
		e.nextthink = time + max(0, t - ITEM_RESPAWN_TICKS) + a;
		e.count = 0;
	}
	else
	{
		e.think = Item_Respawn;
		e.nextthink = time + t + a;
	}
}

void Item_ScheduleRespawnVar(entity e, float a)
{
	if(e.respawntime > 0)
	{
		Item_Show(e, 0);
		Item_ScheduleRespawnVarIn(e, ITEM_RESPAWNTIME(e), a);
	}
	else // if respawntime is -1, this item does not respawn
		Item_Show(e, -1);
}

void Item_ScheduleRespawnIn(entity e, float t)
{
	if((e.flags & FL_POWERUP) || WEPSET_CONTAINS_ANY_EA(e, WEPBIT_SUPERWEAPONS))
	{
		e.think = Item_RespawnCountdown;
		e.nextthink = time + max(0, t - ITEM_RESPAWN_TICKS);
		e.count = 0;
	}
	else
	{
		e.think = Item_Respawn;
		e.nextthink = time + t;
	}
}

void Item_ScheduleRespawn(entity e)
{
	if (autocvar_g_pickup_permitems) {
		if (autocvar_g_pickup_permitems_sanshealth
		&& (e.items == IT_5HP ||
		e.items == IT_25HP ||
		e.items == IT_HEALTH))
		{
			//Do nothing
			//print("here health\n");
		} else if (autocvar_g_pickup_permitems_sansarmor
		&& (e.items == IT_ARMOR_SHARD ||
		e.items == IT_ARMOR))
		{
			//Do nothing
			//print("here armor\n");
		} else if (autocvar_g_pickup_permitems_sansammo
		&& (e.items == IT_NAILS ||
		e.items == IT_ROCKETS ||
		e.items == IT_CELLS ||
		e.items == IT_FUEL))
		{
			//Do nothing
			//print("here ammo\n");
		} else if (autocvar_g_pickup_permitems_sanspowerups
		&& (self.ItemStatus & ITS_POWERUP))
		{
			//Do nothing
			//print("here powerup\n");
		} else {
			remove(e);
			return;
		}
	}
	
	if(e.respawntime > 0)
	{
		Item_Show(e, 0);
		Item_ScheduleRespawnIn(e, ITEM_RESPAWNTIME(e));
	}
	else // if respawntime is -1, this item does not respawn
		Item_Show(e, -1);
}

void Item_ScheduleInitialRespawn(entity e)
{
	Item_Show(e, 0);
	Item_ScheduleRespawnIn(e, game_starttime - time + ITEM_RESPAWNTIME_INITIAL(e));
}

float ITEM_MODE_NONE = 0;
float ITEM_MODE_HEALTH = 1;
float ITEM_MODE_ARMOR = 2;
float ITEM_MODE_FUEL = 3;
float ITEM_MODE_MANA = 4;
float Item_GiveAmmoTo(entity item, entity player, .float ammofield, float ammomax, float mode)
{
	if (!item.ammofield)
		return FALSE;

	if (item.spawnshieldtime)
	{
		if ((player.ammofield < ammomax) || item.pickup_anyway)
		{
			player.ammofield = bound(player.ammofield, ammomax, player.ammofield + item.ammofield);
			goto YEAH;
		}
	}
	else if(g_weapon_stay == 2)
	{
		float mi = min(item.ammofield, ammomax);
		if (player.ammofield < mi)
		{
			player.ammofield = mi;
			goto YEAH;
		}
	}

	return FALSE;

:YEAH
	switch(mode)
	{
		case ITEM_MODE_FUEL:
			player.pauserotfuel_finished = max(player.pauserotfuel_finished, time + autocvar_g_balance_pause_fuel_rot);
			break;
		case ITEM_MODE_HEALTH:
			player.pauserothealth_finished = max(player.pauserothealth_finished, time + autocvar_g_balance_pause_health_rot);
			if (player.tempmanhoblocked) {
				player.tempmanhobheal_nexttime = time + (player.tempmanhoblocked*0.1);
			}
			player.tempmanhoblocked = 0;
			
			if (player.tempmvmntimprdlocked) {
				player.tempmvmntimprdheal_nexttime = time + (player.tempmvmntimprdlocked*0.1);
			}
			player.tempmvmntimprdlocked = 0;
			break;
		case ITEM_MODE_ARMOR:
			player.pauserotarmor_finished = max(player.pauserotarmor_finished, time + autocvar_g_balance_pause_armor_rot);
			break;
		case ITEM_MODE_MANA:
			player.pauserotmana_finished = max(player.pauserotmana_finished, time + autocvar_g_balance_pause_mana_rot);
			break;
		default:
			break;
	}
	return TRUE;
}

float Item_GiveTo(entity item, entity player)
{
	float _switchweapon;
	float pickedup;
	float it;
	float i;

	// if nothing happens to player, just return without taking the item
	pickedup = FALSE;
	_switchweapon = FALSE;

	if (g_minstagib)
	{
		float prevcells = player.ammo_cells;

		pickedup |= Item_GiveAmmoTo(item, player, ammo_fuel, g_pickup_fuel_max, ITEM_MODE_FUEL);
		pickedup |= Item_GiveAmmoTo(item, player, ammo_cells, 999, ITEM_MODE_NONE);

		if(player.ammo_cells > prevcells)
		{
			_switchweapon = TRUE;

			// play some cool sounds ;)
			if (clienttype(player) == CLIENTTYPE_REAL)
			{
				if(player.health <= 5)
					AnnounceTo(player, "lastsecond");
				else if(player.health < 50)
					AnnounceTo(player, "narrowly");
			}
			// sound not available
			// else if(item.items == IT_CELLS)
			//	AnnounceTo(player, "ammo");

			if (WEPSET_CONTAINS_EW(item, WEP_MINSTANEX))
				W_GiveWeapon (player, WEP_MINSTANEX, item.netname);
			player.health = 100;
		}

		if((it = (item.items - (item.items & player.items)) & IT_PICKUPMASK))
		{
			pickedup = TRUE;
			player.items |= it;
			sprint (player, strcat("You got the ^2", item.netname, "\n"));
		}

		// extralife powerup
		if (item.max_health)
		{
			pickedup = TRUE;
			// sound not available
			// AnnounceTo(player, "_lives");
			player.armorvalue = bound(player.armorvalue, 999, player.armorvalue + autocvar_g_minstagib_extralives);
			sprint(player, "^3You picked up some extra lives\n");
		}

		// invis powerup
		if (item.strength_finished)
		{
			pickedup = TRUE;
			// sound not available
			// AnnounceTo(player, "invisible");
			player.strength_finished = max(player.strength_finished, time) + autocvar_g_balance_powerup_strength_time;
		}

		// speed powerup
		if (item.invincible_finished)
		{
			pickedup = TRUE;
			// sound not available
			// AnnounceTo(player, "speed");
			player.invincible_finished = max(player.invincible_finished, time) + autocvar_g_balance_powerup_invincible_time;
		}
	}
	else
	{
		// in case the player has autoswitch enabled do the following:
		// if the player is using their best weapon before items are given, they
		// probably want to switch to an even better weapon after items are given
		if (player.autoswitch)
		if (player.switchweapon == w_getbestweapon(player))
			_switchweapon = TRUE;

		if not(WEPSET_CONTAINS_EW(player, player.switchweapon))
			_switchweapon = TRUE;

		pickedup |= Item_GiveAmmoTo(item, player, ammo_fuel, g_pickup_fuel_max, ITEM_MODE_FUEL);
		pickedup |= Item_GiveAmmoTo(item, player, ammo_shells, g_pickup_shells_max, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, ammo_nails, g_pickup_nails_max, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, ammo_rockets, g_pickup_rockets_max, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, ammo_cells, g_pickup_cells_max, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, health, item.max_health, ITEM_MODE_HEALTH);
		pickedup |= Item_GiveAmmoTo(item, player, armorvalue, item.max_armorvalue, ITEM_MODE_ARMOR);
		pickedup |= Item_GiveAmmoTo(item, player, mana, item.max_mana, ITEM_MODE_MANA);
		
		//Coins/Money
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_tin, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_iron, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_bronze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_copper, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_silver, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_gold, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_plat, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_jade, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_amberium, 30000, ITEM_MODE_NONE);
		//Faux Coins (counterfeit)
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_tin, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_iron, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_bronze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_copper, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_silver, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_gold, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_plat, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_jade, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_f_amberium, 30000, ITEM_MODE_NONE);
		//Counterfeit Coins (blatant/old counterfeit, cladding rubbing off)
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_tin, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_iron, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_bronze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_copper, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_silver, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_gold, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_plat, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_jade, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_coin_cf_amberium, 30000, ITEM_MODE_NONE);
		//Casino Tokens
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_yellow, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_blue, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_gray, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_lightgreen, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_lightblue, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_rose, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_black, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_seabreeze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_red, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_cyan, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_tan, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_green, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_casinotoken_purple, 30000, ITEM_MODE_NONE);

		//Bars
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_tin, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_iron, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_bronze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_copper, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_silver, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_gold, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_plat, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_jade, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_amberium, 30000, ITEM_MODE_NONE);
		//Faux Bars
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_tin, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_iron, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_bronze, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_copper, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_silver, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_gold, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_plat, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_jade, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_bar_f_amberium, 30000, ITEM_MODE_NONE);
		
		
		//Gems
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_diamond, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_jacinth, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_ruby, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_peridot, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_emerald, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_topaz, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_sapphire, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_chalcedony, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_agate, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_onyx, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_mithril, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_amethyst, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_chrysoberyl, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_aquamarine, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_quartz, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_tourmaline, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_pearl, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_blackpearl, 30000, ITEM_MODE_NONE);
		//Faux gems, glass (Colormapped)
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_glass_r, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_glass_g, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_glass_b, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_glass_y, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_glass_w, 30000, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_diamond, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_jacinth, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_ruby, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_peridot, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_emerald, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_topaz, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_sapphire, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_chalcedony, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_agate, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_onyx, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_mithril, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_amethyst, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_chrysoberyl, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_aquamarine, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_quartz, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_tourmaline, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_pearl, 30000, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_gem_f_blackpearl, 30000, ITEM_MODE_NONE);
		
		//Spellbooks and Scrolls
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_agency, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_agency, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_death, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_death, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_book_drainlife, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_drainlife, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_cancellation, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_cancellation, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_book_castfromlife, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_castfromlife, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_confer, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_confer, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_iceball, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_iceball, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_icestar, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_icestar, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_firebolt, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_firebolt, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_fireball, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_fireball, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_magmasphere, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_magmasphere, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_firebeam, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_firebeam, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_inferno, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_inferno, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_firewall, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_firewall, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_scepterofflame, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_scepterofflame, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_explosion, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_explosion, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_phantasmalbarrier, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_phantasmalbarrier, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_raiseundead, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_raiseundead, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_flameburst, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_flameburst, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_firecentury, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_firecentury, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_frostbeam, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_frostbeam, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_grace, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_grace, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_holybolt, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_holybolt, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_holylight, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_holylight, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_acervilux, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_acervilux, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_aquacaelestis, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_aquacaelestis, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_book_nivosus, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_nivosus, 100, ITEM_MODE_NONE);
	
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_rosa, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_rosa, 100, ITEM_MODE_NONE);
	
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_corvuspenna, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_corvuspenna, 100, ITEM_MODE_NONE);
	
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_plumosus, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_plumosus, 100, ITEM_MODE_NONE);
			
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_heal, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_heal, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_repair, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_repair, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_holyword, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_holyword, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_extinguish, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_extinguish, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_darkritual, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_darkritual, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_lightining, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_lightining, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_balllightining, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_balllightining, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_lightiningburst, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_lightiningburst, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_chargedbolt, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_chargedbolt, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_chainlightining, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_chainlightining, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_lightiningstrike, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_lightiningstrike, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_lightiningwall, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_lightiningwall, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_monstertomouse, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_monstertomouse, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_monstertomonolith, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_monstertomonolith, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_magicbullets, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_magicbullets, 100, ITEM_MODE_NONE);
		
                pickedup |= Item_GiveAmmoTo(item, player, inv_book_magicmissile, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_magicmissile, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_meteor, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_meteor, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_meteorshower, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_meteorshower, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_stonerain, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_stonerain, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_timesink, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_timesink, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_vampyricconduit, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_vampyricconduit, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_manashield, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_manashield, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_book_clairvoyance, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_clairvoyance, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_book_mimic, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_mimic, 100, ITEM_MODE_NONE);

                pickedup |= Item_GiveAmmoTo(item, player, inv_book_paralyse, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_paralyse, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_ringoffire, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_ringoffire, 100, ITEM_MODE_NONE);

                pickedup |= Item_GiveAmmoTo(item, player, inv_book_stonecurse, 100, ITEM_MODE_NONE);
                pickedup |= Item_GiveAmmoTo(item, player, inv_scroll_stonecurse, 100, ITEM_MODE_NONE);
		
		//Knowledge books
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_carpentry, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_mortise, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_stonemasonry, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_ironworking, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_arch, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_welding, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_book_know_concrete, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressor45, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressormac10, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressor9mm, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressor5n7mm, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressorrifle, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_suppressorpdw, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_cylinder_r1856, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_ak47_50, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_ak47_100, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_drum_ak47_75, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_ak47_30, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_ak74_45, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_ak74_30, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_styeraug_42, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_styeraug_30, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_panmag_lewisgun_47, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_panmag_lewisgun_97, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_bar_40, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_bar_20, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_uzi_20, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_uzi_25, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_uzi_32, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_uzi_40, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_uzi_50, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_drum_uzi_82, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_uzi_106, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_tec9_10, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_tec9_20, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_tec9_32, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_tec9_36, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_tec9_50, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_drum_tec9_72, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_m16_20, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_m16_30, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_betacmag_m16, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_mag_lightpistol, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag_lightpistol, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_drum_lightpistol, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_betacmag_lightpistol, 100, ITEM_MODE_NONE);

		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_tinymag_pdw, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_smallmag_pdw, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_stdmag_pdw, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_exmag40_pdw, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_drum_pdw, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_misc_betacmag_pdw, 100, ITEM_MODE_NONE);
		
		pickedup |= Item_GiveAmmoTo(item, player, grenades, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, flashbangs, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smokenades, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, fragnades, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, atmines, 100, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, landmines, 100, ITEM_MODE_NONE);
		//Potions
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_health_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_health_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_health_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_mana_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_mana_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_mana_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_rejuv_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_rejuv_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_rejuv_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_vodka_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_vodka_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_vodka_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_merlot_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_merlot_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_merlot_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_ale_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_ale_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_ale_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_water_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_water_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_potion_water_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_bellpepper, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_bread, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_cheeze, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_garlic, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_grapes, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_onion, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_tomato, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_food_turkeyleg, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_faeces_small, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_faeces_medium, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, inv_faeces_large, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_acrid, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_alcohol, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_bodyodor, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_cheeze, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_earthy, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_faeces, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_garlic, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_urine, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_roses, 40, ITEM_MODE_NONE);
		pickedup |= Item_GiveAmmoTo(item, player, smell_rottingflesh, 40, ITEM_MODE_NONE);
		
		if ((item.flags & FL_WEAPON)
		|| (item.multitool_forceinventory_weapon))
		{
			WEPSET_DECLARE_A(it);
			WEPSET_COPY_AE(it, item);
			WEPSET_ANDNOT_AE(it, player);

			if (!WEPSET_EMPTY_A(it) || (item.spawnshieldtime && self.pickup_anyway))
			{
				pickedup = TRUE;
				for(i = WEP_FIRST; i <= WEP_LAST; ++i)
					if(WEPSET_CONTAINS_AW(it, i))
						W_GiveWeapon (player, i, item.netname);
			}
		}

		if((it = (item.items - (item.items & player.items)) & IT_PICKUPMASK))
		{
			pickedup = TRUE;
			player.items |= it;
			sprint (player, strcat("You got the ^2", item.netname, "\n"));
		}

		if (item.strength_finished)
		{
			pickedup = TRUE;
			player.strength_finished = max(player.strength_finished, time) + item.strength_finished;
		}
		if (item.invincible_finished)
		{
			pickedup = TRUE;
			player.invincible_finished = max(player.invincible_finished, time) + item.invincible_finished;
		}
		if (item.superweapons_finished)
		{
			pickedup = TRUE;
			player.superweapons_finished = max(player.superweapons_finished, time) + item.superweapons_finished;
		}
	}

:skip
	// always eat teamed entities
	if(item.team)
		pickedup = TRUE;

	if (!pickedup)
		return 0;

	if (_switchweapon)
		if (player.switchweapon != w_getbestweapon(player))
			if (player.peaceful != 1)
				W_SwitchWeapon_Force(player, w_getbestweapon(player));

	return 1;
}

float ContainerTallyStorage (entity player);
void Item_Touch (void)
{
	entity e, head;
	
	// remove the item if it's currnetly in a NODROP brush or hits a NOIMPACT surface (such as sky)
	if(self.classname == "droppedweapon")
	{
		if (ITEM_TOUCH_NEEDKILL())
		{
			remove(self);
			return;
		}
	}

	if (other.classname != "player")
		return;
	if (other.deadflag)
		return;
	if (self.solid != SOLID_TRIGGER)
		return;
	if (self.owner == other)
		return;
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
	if(MUTATOR_CALLHOOK(ItemTouch))
		return;

	if (self.classname == "droppedweapon")
	{
		self.strength_finished = max(0, self.strength_finished - time);
		self.invincible_finished = max(0, self.invincible_finished - time);
		self.superweapons_finished = max(0, self.superweapons_finished - time);
	}
	
	//////
	//Check to see if we have the weapon we might change settings on pickup
	local float allreadyhaveweapon = 0;
	if (self.weapon) {
		if (self.weapon == WEP_AK47) {
			if (WEPSET_CONTAINS_EW(other, WEP_AK47)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_UZI) {
			if (WEPSET_CONTAINS_EW(other, WEP_UZI)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_BAR1918) {
			if (WEPSET_CONTAINS_EW(other, WEP_BAR1918)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_RIFLE) {
			if (WEPSET_CONTAINS_EW(other, WEP_RIFLE)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_TEC9) {
			if (WEPSET_CONTAINS_EW(other, WEP_TEC9)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_MINIUZI) {
			if (WEPSET_CONTAINS_EW(other, WEP_MINIUZI)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_M16MINI) {
			if (WEPSET_CONTAINS_EW(other, WEP_M16MINI)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_M249PARA) {
			if (WEPSET_CONTAINS_EW(other, WEP_M249PARA)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_M16A2) {
			if (WEPSET_CONTAINS_EW(other, WEP_M16A2)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_M16VN) {
			if (WEPSET_CONTAINS_EW(other, WEP_M16VN)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_MICROUZI) {
			if (WEPSET_CONTAINS_EW(other, WEP_MICROUZI)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_AKS74U) {
			if (WEPSET_CONTAINS_EW(other, WEP_AKS74U)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_LEWISMG) {
			if (WEPSET_CONTAINS_EW(other, WEP_LEWISMG)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_STYERAUG) {
			if (WEPSET_CONTAINS_EW(other, WEP_STYERAUG)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_LIGHTAUTO) {
			if (WEPSET_CONTAINS_EW(other, WEP_LIGHTAUTO)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_PDW) {
			if (WEPSET_CONTAINS_EW(other, WEP_PDW)) {
				allreadyhaveweapon = 1;
			}
		} else if (self.weapon == WEP_LIGHTPISTOL) {
			if (WEPSET_CONTAINS_EW(other, WEP_LIGHTPISTOL)) {
				allreadyhaveweapon = 1;
			}
		}
	} 
	//
	//////
	

	if(!Item_GiveTo(self, other))
	{
		if (self.classname == "droppedweapon")
		{
			// undo what we did above
			self.strength_finished += time;
			self.invincible_finished += time;
			self.superweapons_finished += time;
		}
		return;
	}
	
	
	//////
	//Change the settings if applicable
	if (self.weapon) {
		if (self.weapon == WEP_AK47) {
			w_ak47_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_UZI) {
			w_uzi_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_BAR1918) {
			w_bar1918_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_RIFLE) {
			w_rifle_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_TEC9) {
			w_tec9_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_MINIUZI) {
			w_miniuzi_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_M16MINI) {
			w_m16mini_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_M249PARA) {
			w_m249para_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_M16A2) {
			w_m16a2_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_M16VN) {
			w_m16vn_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_MICROUZI) {
			w_microuzi_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_AKS74U) {
			w_aks74u_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_LEWISMG) {
			w_lewismg_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_STYERAUG) {
			w_styeraug_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_LIGHTAUTO) {
			w_lightauto_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_PDW) {
			w_pdw_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_LIGHTPISTOL) {
			w_lightpistol_setwhenpickedup(self, other, allreadyhaveweapon);
		} else if (self.weapon == WEP_BIGPISTOL) {
			w_bigpistol_setwhenpickedup(self, other, allreadyhaveweapon);
		}
	}
	//
	//////
	
	other.last_pickup = time;

	pointparticles(particleeffectnum("item_pickup"), self.origin, '0 0 0', 1);
	sound (other, CH_TRIGGER, self.item_pickupsound, VOL_BASE, ATTN_NORM);

	if (self.classname == "droppedweapon")
		remove (self);
	else if not(self.spawnshieldtime)
		return;
	else
	{
		if(self.team)
		{
			RandomSelection_Init();
			for(head = world; (head = findfloat(head, team, self.team)); )
			{
				if(head.flags & FL_ITEM)
				{
					Item_Show(head, -1);
					RandomSelection_Add(head, 0, string_null, head.cnt, 0);
				}
			}
			e = RandomSelection_chosen_ent;

		}
		else
			e = self;
		Item_ScheduleRespawn(e);
	}
}

void Item_Reset()
{
	Item_Show(self, !self.state);
	setorigin (self, self.origin);

	if(self.classname != "droppedweapon")
	{
		self.think = func_null;
		self.nextthink = 0;

		if(self.waypointsprite_attached)
			WaypointSprite_Kill(self.waypointsprite_attached);

		if((self.flags & FL_POWERUP) | WEPSET_CONTAINS_ANY_EA(self, WEPBIT_SUPERWEAPONS)) // do not spawn powerups initially!
			Item_ScheduleInitialRespawn(self);
	}
}

void Item_FindTeam()
{
	entity head, e;

	if(self.effects & EF_NODRAW)
	{
		// marker for item team search
		dprint("Initializing item team ", ftos(self.team), "\n");
		RandomSelection_Init();
		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
			RandomSelection_Add(head, 0, string_null, head.cnt, 0);
		e = RandomSelection_chosen_ent;
		e.state = 0;
		Item_Show(e, 1);

		for(head = world; (head = findfloat(head, team, self.team)); ) if(head.flags & FL_ITEM)
		{
			if(head != e)
			{
				// make it a non-spawned item
				Item_Show(head, -1);
				head.state = 1; // state 1 = initially hidden item
			}
			head.effects &~= EF_NODRAW;
		}

		Item_Reset();
	}
}

// Savage: used for item garbage-collection
// TODO: perhaps nice special effect?
void RemoveItem(void)
{
	remove(self);
}

// pickup evaluation functions
// these functions decide how desirable an item is to the bots

float generic_pickupevalfunc(entity player, entity item) {return item.bot_pickupbasevalue;}

float weapon_pickupevalfunc(entity player, entity item)
{
	float c, j, position;

	// See if I have it already
	if(!WEPSET_CONTAINS_ALL_EE(player, item))
	{
		// If I can pick it up
		if(!item.spawnshieldtime)
			c = 0;
		else if(player.ammo_cells || player.ammo_shells || player.ammo_nails || player.ammo_rockets)
		{
			// Skilled bots will grab more
			c = bound(0, skill / 10, 1) * 0.5;
		}
		else
			c = 0;
	}
	else
		c = 1;

	// If custom weapon priorities for bots is enabled rate most wanted weapons higher
	if( bot_custom_weapon && c )
	{
		// Find the highest position on any range
		position = -1;
		for(j = 0; j < WEP_LAST ; ++j){
			if(
					bot_weapons_far[j] == item.weapon ||
					bot_weapons_mid[j] == item.weapon ||
					bot_weapons_close[j] == item.weapon ||
					bot_weapons_melee[j] == item.weapon
			  )
			{
				position = j;
				break;
			}
		}

		// Rate it
		if (position >= 0 )
		{
			position = WEP_LAST - position;
			// item.bot_pickupbasevalue is overwritten here
			return (BOT_PICKUP_RATING_LOW + ( (BOT_PICKUP_RATING_HIGH - BOT_PICKUP_RATING_LOW) * (position / WEP_LAST ))) * c;
		}
	}

	return item.bot_pickupbasevalue * c;
}

float commodity_pickupevalfunc(entity player, entity item)
{
	float c, i;
	float need_shells = FALSE, need_nails = FALSE, need_rockets = FALSE, need_cells = FALSE, need_fuel = FALSE;
	entity wi;
	c = 0;

	// Detect needed ammo
	for(i = WEP_FIRST; i <= WEP_LAST ; ++i)
	{
		wi = get_weaponinfo(i);

		if not(WEPSET_CONTAINS_EW(player, i))
			continue;

		if(wi.items & IT_SHELLS)
			need_shells = TRUE;
		else if(wi.items & IT_NAILS)
			need_nails = TRUE;
		else if(wi.items & IT_ROCKETS)
			need_rockets = TRUE;
		else if(wi.items & IT_CELLS)
			need_cells = TRUE;
		else if(wi.items & IT_FUEL)
			need_cells = TRUE;
	}

	// TODO: figure out if the player even has the weapon this ammo is for?
	// may not affect strategy much though...
	// find out how much more ammo/armor/health the player can hold
	if (need_shells)
	if (item.ammo_shells)
	if (player.ammo_shells < g_pickup_shells_max)
		c = c + max(0, 1 - player.ammo_shells / g_pickup_shells_max);
	if (need_nails)
	if (item.ammo_nails)
	if (player.ammo_nails < g_pickup_nails_max)
		c = c + max(0, 1 - player.ammo_nails / g_pickup_nails_max);
	if (need_rockets)
	if (item.ammo_rockets)
	if (player.ammo_rockets < g_pickup_rockets_max)
		c = c + max(0, 1 - player.ammo_rockets / g_pickup_rockets_max);
	if (need_cells)
	if (item.ammo_cells)
	if (player.ammo_cells < g_pickup_cells_max)
		c = c + max(0, 1 - player.ammo_cells / g_pickup_cells_max);
	if (need_fuel)
	if (item.ammo_fuel)
	if (player.ammo_fuel < g_pickup_fuel_max)
		c = c + max(0, 1 - player.ammo_fuel / g_pickup_fuel_max);
	if (item.armorvalue)
	if (player.armorvalue < item.max_armorvalue)
		c = c + max(0, 1 - player.armorvalue / item.max_armorvalue);
	if (item.health)
	if (player.health < item.max_health)
		c = c + max(0, 1 - player.health / item.max_health);

	return item.bot_pickupbasevalue * c;
}

void Item_Damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(ITEM_DAMAGE_NEEDKILL(deathtype))
		RemoveItem();
}

.float is_item;
void StartItem (string itemmodel, string pickupsound, float defaultrespawntime, float defaultrespawntimejitter, string itemname, float itemid, float weaponid, float itemflags, float(entity player, entity item) pickupevalfunc, float pickupbasevalue)
{
	startitem_failed = FALSE;

	if(self.model == "")
		self.model = itemmodel;
	
	if(self.model == "")
    {
        error(strcat("^1Tried to spawn ", itemname, " with no model!\n"));
        return;
    }
        
	if(self.item_pickupsound == "")
		self.item_pickupsound = pickupsound;
	
	if(!self.respawntime) // both need to be set
	{
		self.respawntime = defaultrespawntime;
		self.respawntimejitter = defaultrespawntimejitter;
	}

	self.items = itemid;
	self.weapon = weaponid;

	if(weaponid)
		WEPSET_COPY_EW(self, weaponid);
	
	self.flags = FL_ITEM | itemflags;

	if(MUTATOR_CALLHOOK(FilterItem)) // error means we do not want the item
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}

	// is it a dropped weapon?
	if (self.classname == "droppedweapon")
	{
		if (self.owner) {
			if (weaponid == WEP_AK47) {
				w_ak47_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_TORCH) {
				w_torch_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_UZI) {
				w_uzi_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_BAR1918) {
				w_bar1918_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_RIFLE) {
				w_rifle_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_MINIUZI) {
				w_miniuzi_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_M16MINI) {
				w_m16mini_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_M249PARA) {
				w_m249para_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_M16A2) {
				w_m16a2_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_M16VN) {
				w_m16vn_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_TEC9) {
				w_tec9_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_MICROUZI) {
				w_microuzi_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_AKS74U) {
				w_aks74u_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_LEWISMG) {
				w_lewismg_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_STYERAUG) {
				w_styeraug_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_LIGHTAUTO) {
				w_lightauto_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_PDW) {
				w_pdw_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_LIGHTPISTOL) {
				w_lightpistol_changedroppedgroundmodel(self, self.owner);
			} else if (weaponid == WEP_BIGPISTOL) {
				w_bigpistol_changedroppedgroundmodel(self, self.owner);
			}
			
		}
			
		self.reset = SUB_Remove;
		// it's a dropped weapon
		self.movetype = MOVETYPE_TOSS;

		// Savage: remove thrown items after a certain period of time ("garbage collection")
		self.think = RemoveItem;
		self.nextthink = time + 20;

		self.takedamage = DAMAGE_YES;
		self.event_damage = Item_Damage;

		if(self.strength_finished || self.invincible_finished || self.superweapons_finished)
		/*
		if(self.items == 0)
		if(WEPSET_CONTAINS_ALL_AE(WEPBIT_SUPERWEAPONS, self)) // only superweapons
		if(self.ammo_nails == 0)
		if(self.ammo_cells == 0)
		if(self.ammo_rockets == 0)
		if(self.ammo_shells == 0)
		if(self.ammo_fuel == 0)
		if(self.health == 0)
		if(self.armorvalue == 0)
		*/
		{
			// if item is worthless after a timer, have it expire then
			self.nextthink = max(self.strength_finished, self.invincible_finished, self.superweapons_finished);
		}

		// don't drop if in a NODROP zone (such as lava)
		traceline(self.origin, self.origin, MOVE_NORMAL, self);
		if (trace_dpstartcontents & DPCONTENTS_NODROP)
		{
			startitem_failed = TRUE;
			remove(self);
			return;
		}
	}
	else
	{
		if(!have_pickup_item())
		{
			startitem_failed = TRUE;
			remove (self);
			return;
		}
		
		if(self.angles != '0 0 0')
            self.SendFlags |= ISF_ANGLES;

		self.reset = Item_Reset;
		// it's a level item
		if(self.spawnflags & 1)
			self.noalign = 1;
		if (self.noalign)
			self.movetype = MOVETYPE_NONE;
		else
			self.movetype = MOVETYPE_TOSS;
		// do item filtering according to game mode and other things
		if (!self.noalign)
		{
			// first nudge it off the floor a little bit to avoid math errors
			setorigin(self, self.origin + '0 0 1');
			// set item size before we spawn a spawnfunc_waypoint
			if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
				setsize (self, '-16 -16 0', '16 16 48');
			else
				setsize (self, '-16 -16 0', '16 16 32');
			// note droptofloor returns FALSE if stuck/or would fall too far
			droptofloor();
			waypoint_spawnforitem(self);
		}

		/*
		 * can't do it that way, as it would break maps
		 * TODO make a target_give like entity another way, that perhaps has
		 * the weapon name in a key
		if(self.targetname)
		{
			// target_give not yet supported; maybe later
			print("removed targeted ", self.classname, "\n");
			startitem_failed = TRUE;
			remove (self);
			return;
		}
		*/

		if(autocvar_spawn_debug >= 2)
		{
			entity otheritem;
			for(otheritem = findradius(self.origin, 3); otheritem; otheritem = otheritem.chain)
			{
			    // why not flags & fl_item?
				if(otheritem.is_item)
				{
					dprint("XXX Found duplicated item: ", itemname, vtos(self.origin));
					dprint(" vs ", otheritem.netname, vtos(otheritem.origin), "\n");
					error("Mapper sucks.");
				}
			}
			self.is_item = TRUE;
		}

		WEPSET_OR_AW(weaponsInMap, weaponid);

		precache_model (self.model);
		precache_sound (self.item_pickupsound);

		precache_sound ("misc/itemrespawncountdown.wav");
		if(!g_minstagib && itemid == IT_STRENGTH)
			precache_sound ("misc/strength_respawn.wav");
		else if(!g_minstagib && itemid == IT_INVINCIBLE)
			precache_sound ("misc/shield_respawn.wav");
		else
			precache_sound ("misc/itemrespawn.wav");

		if((itemflags & (FL_POWERUP | FL_WEAPON)) || (itemid & (IT_HEALTH | IT_ARMOR | IT_KEY1 | IT_KEY2)))
			self.target = "###item###"; // for finding the nearest item using find()
	}

	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = pickupevalfunc;
	self.bot_pickupbasevalue = pickupbasevalue;
	self.mdl = self.model;
	self.netname = itemname;
	self.touch = Item_Touch;
	setmodel(self, "null"); // precision set below
	//self.effects |= EF_LOWPRECISION; 
	
	if((itemflags & FL_POWERUP) || self.health || self.armorvalue)
    {
        self.pos1 = '-16 -16 0';
        self.pos2 = '16 16 48';
    }
	else
    {
        self.pos1 = '-16 -16 0';
        self.pos2 = '16 16 32';
    }
    setsize (self, self.pos1, self.pos2);
    
    if(itemflags & FL_POWERUP) 
        self.ItemStatus |= ITS_ANIMATE1;
	
	if(self.armorvalue || self.health)
        self.ItemStatus |= ITS_ANIMATE2;
	
	if(itemflags & FL_WEAPON)
	{
		
		if (weaponid == WEP_P90) {
			self.skin = w_p90_skin(self.owner);
		} else if (weaponid == WEP_TARGETPISTOL) {
			self.skin = w_targetpistol_skin(self.owner);
		} else if (weaponid == WEP_STREETSWEEPER) {
			self.skin = w_streetsweeper_skin(self.owner);
		} else if (weaponid == WEP_LARGEPISTOL) {
			self.skin = w_largepistol_skin(self.owner);
				if (self.skin > 0) { // Skin 0 works without this
					//self.effects |= EF_DOUBLESIDED; //Na, going to set the itemstatus directly:
					self.ItemStatus |= ITS_DOUBLESIDED;
				}
		} else if (weaponid == WEP_BIGPISTOL) {
			self.skin = w_bigpistol_skin(self.owner);
		} else if (weaponid == WEP_AK47) {
			self.skin = w_ak47_skin(self.owner);
		} else if (weaponid == WEP_ELECTRO) {
			self.skin = w_electro_skin(self.owner);
			if (autocvar_g_balance_electro_defaultcolormap && self.skin <= 0)
			{
				self.colormap = autocvar_g_balance_electro_defaultcolormap;
			}
		} else if (weaponid == WEP_CRYLINK) {
			self.skin = w_crylink_skin(self.owner);
			if (autocvar_g_balance_crylink_defaultcolormap && self.skin <= 0)
			{
				self.colormap = autocvar_g_balance_crylink_defaultcolormap;
			}
		} else if (weaponid == WEP_TT33PISTOL) {
			self.skin = w_tt33pistol_skin(self.owner);
		} else if (weaponid == WEP_M82RIFLE) {
			self.skin = w_m82rifle_skin(self.owner);
		} else if (weaponid == WEP_LIGHTAUTO) {
			self.skin = w_lightauto_skin(self.owner);
		} else if (weaponid == WEP_PDW) {
			self.skin = w_pdw_skin(self.owner);
		} else if (weaponid == WEP_LEWISMG) {
			self.skin = w_lewismg_skin(self.owner);
		} else if (weaponid == WEP_STYERAUG) {
			self.skin = w_styeraug_skin(self.owner);
		} else if (weaponid == WEP_FAMAS) {
			self.skin = w_famas_skin(self.owner);
		} else if (weaponid == WEP_KNIFE) {
			self.skin = w_knife_skin(self.owner);
		}
	
		if (self.classname != "droppedweapon") { // if dropped, colormap is already set up nicely
            		if (weaponid == WEP_HLAC && autocvar_g_balance_hlac_defaultcolormap) {
				self.colormap = autocvar_g_balance_hlac_defaultcolormap;
			} else if (weaponid == WEP_LASER && autocvar_g_balance_laser_defaultcolormap) {
				self.colormap = autocvar_g_balance_laser_defaultcolormap;
			} else if (weaponid == WEP_CRYLINK && autocvar_g_balance_crylink_defaultcolormap) {
				self.colormap = autocvar_g_balance_crylink_defaultcolormap;
			} else if (weaponid == WEP_CRYPISTOL && autocvar_g_balance_crypistol_defaultcolormap) {
				self.colormap = autocvar_g_balance_crypistol_defaultcolormap;
			} else if (weaponid == WEP_CRYLANCER && autocvar_g_balance_crylancer_defaultcolormap) {
				self.colormap = autocvar_g_balance_crylancer_defaultcolormap;
			} else if (weaponid == WEP_RIFLE && autocvar_g_balance_rifle_defaultcolormap) {
				self.colormap = autocvar_g_balance_rifle_defaultcolormap;
			} else if (weaponid == WEP_LRR && autocvar_g_balance_lrr_defaultcolormap) {
				self.colormap = autocvar_g_balance_lrr_defaultcolormap;
			} else if (weaponid == WEP_UZI && autocvar_g_balance_uzi_defaultcolormap) {
				self.colormap = autocvar_g_balance_uzi_defaultcolormap;
			} else if (weaponid == WEP_CARBINE && autocvar_g_balance_carbine_defaultcolormap) {
				self.colormap = autocvar_g_balance_carbine_defaultcolormap;
			} else if (weaponid == WEP_GRENADE_LAUNCHER && autocvar_g_balance_grenadelauncher_defaultcolormap) {
				self.colormap = autocvar_g_balance_grenadelauncher_defaultcolormap;
			} else if (weaponid == WEP_ROCKET_LAUNCHER && autocvar_g_balance_rocketlauncher_defaultcolormap) {
				self.colormap = autocvar_g_balance_rocketlauncher_defaultcolormap;
			} else if (weaponid == WEP_MORTAR && autocvar_g_balance_mortar_defaultcolormap) {
				self.colormap = autocvar_g_balance_mortar_defaultcolormap;
			} else if (weaponid == WEP_HAGAR && autocvar_g_balance_hagar_defaultcolormap) {
				self.colormap = autocvar_g_balance_hagar_defaultcolormap;
			} else if (weaponid == WEP_HAGAR2 && autocvar_g_balance_hagar2_defaultcolormap) {
				self.colormap = autocvar_g_balance_hagar2_defaultcolormap;
			} else if (weaponid == WEP_DEVASTATOR && autocvar_g_balance_devastator_defaultcolormap) {
				self.colormap = autocvar_g_balance_devastator_defaultcolormap;
			} else if (weaponid == WEP_ELECTRO && autocvar_g_balance_electro_defaultcolormap) {
				self.colormap = autocvar_g_balance_electro_defaultcolormap;
			} else if (weaponid == WEP_LIGHTNINGGUN && autocvar_g_balance_lightninggun_defaultcolormap) {
				self.colormap = autocvar_g_balance_lightninggun_defaultcolormap;
			} else if (weaponid == WEP_NEX && autocvar_g_balance_nex_defaultcolormap) {
				self.colormap = autocvar_g_balance_nex_defaultcolormap;
			} else if (weaponid == WEP_MINSTANEX && autocvar_g_balance_minstanex_defaultcolormap) {
				self.colormap = autocvar_g_balance_minstanex_defaultcolormap;
			} else if (weaponid == WEP_SEEKER && autocvar_g_balance_seeker_defaultcolormap) {
				self.colormap = autocvar_g_balance_seeker_defaultcolormap;
			} else if (weaponid == WEP_MINE_LAYER && autocvar_g_balance_minelayer_defaultcolormap) {
				self.colormap = autocvar_g_balance_minelayer_defaultcolormap;
			} else if (weaponid == WEP_FIREBALL && autocvar_g_balance_fireball_defaultcolormap) {
				self.colormap = autocvar_g_balance_fireball_defaultcolormap;
			} else if (weaponid == WEP_FLAMBERGE) {
				self.colormap = (1024 + 1 + 1 * 16); //Orange
			} else {
				self.colormap = 1024; // color shirt=0 pants=0 grey
			}
        	} else
            		self.gravity = 1;
            
	    	if (self.noanimdroppeditems == 2) {
			//Usually used to flag things that don't 
			//No animation for this weapon
		} else {
			self.ItemStatus |= ITS_ANIMATE1;
		}
		
		self.ItemStatus |= ISF_COLORMAP;
	}

	if (self.skin) {
    		self.ItemStatus |= ITS_SKIN; //Has a skin
    	}

	if (self.scale) {
    		self.ItemStatus |= ITS_SCALE; //Has a scale
    	}

	self.state = 0;
	if(self.team) // broken, no idea why.
	{
		if(!self.cnt)
			self.cnt = 1; // item probability weight
			
		self.effects |= EF_NODRAW; // marker for item team search
		InitializeEntity(self, Item_FindTeam, INITPRIO_FINDTARGET);
	}
	else
		Item_Reset();
        
    Net_LinkEntity(self, FALSE, 0, ItemSend);

	// call this hook after everything else has been done
	if(MUTATOR_CALLHOOK(Item_Spawn))
	{
		startitem_failed = TRUE;
		remove(self);
		return;
	}
}

/* replace items in minstagib
 * IT_STRENGTH	 = invisibility
 * IT_NAILS	 = extra lives
 * IT_INVINCIBLE = speed
 */
void minstagib_items (float itemid) // will be deleted soon.
{
	float rnd;
	self.classname = "minstagib"; // ...?

	// replace rocket launchers and nex guns with ammo cells
	if (itemid == IT_CELLS)
	{
		self.ammo_cells = autocvar_g_minstagib_ammo_drop;
		StartItem ("models/items/a_cells.md3",
			"misc/itempickup.wav", 45, 0,
			"MinstaNex Ammo", IT_CELLS, 0, 0, generic_pickupevalfunc, 100);
		return;
	}

	// randomize
	rnd = random() * 3;
	if (rnd <= 1)
		itemid = IT_STRENGTH;
	else if (rnd <= 2)
		itemid = IT_NAILS;
	else
		itemid = IT_INVINCIBLE;

	// replace with invis
	if (itemid == IT_STRENGTH)
	{
		if(!self.strength_finished)
			self.strength_finished = autocvar_g_balance_powerup_strength_time;
		StartItem ("models/items/g_strength.md3",
			"misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Invisibility", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
	// replace with extra lives
	if (itemid == IT_NAILS)
	{
		self.max_health = 1;
		StartItem ("models/items/g_h100.md3",
			"misc/megahealth.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Extralife", IT_NAILS, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
	}
	// replace with speed
	if (itemid == IT_INVINCIBLE)
	{
		if(!self.invincible_finished)
			self.invincible_finished = autocvar_g_balance_powerup_invincible_time;
		StartItem ("models/items/g_invincible.md3",
			"misc/powerup_shield.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup,
			"Speed", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

float minst_no_auto_cells;
void minst_remove_item (void) {
	if(minst_no_auto_cells)
		remove(self);
}

float weaponswapping;
float internalteam;

void SMI_spawn_jumppad(vector selected_origin, float selected_color);
void SMI_spawn_spikes(vector selected_origin, float onceling);
void SMI_spawn_baloon(vector selected_origin, float selected_color);
void SMI_spawn_bumper(vector selected_origin, float selected_color);
void SMI_spawn_tnkpyr(vector selected_origin, float onceling, float randomangle, float allowliquid, float vfly);
void SMI_spawn_abdbld(vector selected_origin, float onceling, float randomangle, float allowliquid, float vfly, float bldtype);
//entity SMI_spawn_spikeball(vector selected_origin, float ballsize);
float SMI_select_color(float typeofcolor);
float SMI_select_skin();
float Foliage_Grow_Thicker(float spawns_we_want, vector givenorigin, float usegiven, float maxfail);
void Foliage_GetAutoCvars(void);
void Foliage_Presets(void);
float replaceweapondidfoliagecvars;

//These fires may reignite if put out
void weapon_burningreplacement_think(void)
{
	if not (self.fire_burner) {
		if (random() > 0.5) {
			Fire_AddDamage(self, self.owner, 10*9000000000, 9000000000, DEATH_FIRE);
			self.nextthink = time + 300;
		} else {
			self.solid = SOLID_NOT;
			self.think = func_null;
			self.nextthink = 0;
		}
	} else {
		self.nextthink = time + 300;
	}
}

float autocvar_g_spawnfoliagearound_oilfireent_rate;
float autocvar_g_spawnfoliagearound_oilfireent_radius;
float autocvar_g_spawnfoliagearound_oilfireent_think;
float autocvar_g_spawnfoliagearound_oilfireent_thinkjitter;
void weapon_burningreplacement_oilfire_think(void)
{
	if not (self.fire_burner) {
		if (random() > 0.5) {
			Fire_AddDamage(self, self.owner, 10*9000000000, 9000000000, DEATH_FIRE);
			self.nextthink = time + autocvar_g_spawnfoliagearound_oilfireent_think + (autocvar_g_spawnfoliagearound_oilfireent_thinkjitter * random());
		} else {
			self.solid = SOLID_NOT;
			self.think = func_null;
			self.nextthink = 0;
		}
	} else {
		entity eburn;
		eburn = findradius(self.origin, autocvar_g_spawnfoliagearound_oilfireent_radius);
		while(eburn)
		{
			if(eburn != world)
			if(!eburn.fire_burner)
			if (eburn.classname == "tree" || eburn.classname == "bush" ||
			eburn.classname == "building" || eburn.classname == "bldhitbx" ||
			isPlayerOrMonsterByClassname(eburn)) {
				eburn.fire_oilfire_entreignite = 1;
				eburn.fire_oilfire_entreignite_owner = self.owner;
				Fire_AddDamage(eburn, self.owner, 10*9000000000, 9000000000, DEATH_FIRE);
			}
			
			eburn = eburn.chain;
		}
		self.nextthink = time + autocvar_g_spawnfoliagearound_oilfireent_think + (autocvar_g_spawnfoliagearound_oilfireent_thinkjitter * random());
	}
}

//These fires may reignite if put out
void weapon_burningpillarreplacement_think(void)
{
	if not (self.fire_burner) {
		if (random() > 0.35) {
			Fire_AddDamage(self, self.owner, 100*9000000000, 9000000000, DEATH_FIRE);
			self.fire_intensity = 41;
			self.fire_nextpartcheck = 1;
			self.nextthink = time + 300;
		} else {
			self.solid = SOLID_NOT;
			self.think = func_null;
			self.nextthink = 0;
		}
	} else {
		self.nextthink = time + 300;
	}
}

void weapon_scrollreplacement(void);
void weapon_scrollreplacement_biased(void);

float weapon_medievalreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 70;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_BROADAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_CALTROP;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_COMPOSITEBOW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_CROSSBOWDTWR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_CRUDEBOW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_CUDGEL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_FLANGEDMACE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_KATANA;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_KIDUCHI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_LIGHTCROSSBOW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_LONGBOW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_LONGSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		return WEP_MORGENSTERN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		return WEP_NAGAMAKI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		return WEP_ODACHI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		return WEP_RAPIER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		return WEP_SHORTSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		return WEP_SPEAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		return WEP_STONEAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-20)))
		return WEP_TETSUBO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-21)))
		return WEP_WARHAMMERSPIKED;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-22)))
		return WEP_WARMALLET;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-23)))
		return WEP_YARI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-24)))
		return WEP_SHININGSTAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-25)))
		return WEP_POLEAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-26)))
		return WEP_YUMIBOW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-27)))
		return WEP_IRONCROW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-28)))
		return WEP_GREYIRONMALLET;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-29)))
		return WEP_IRONKNIFE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-30)))
		return WEP_DAGGER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-31)))
		return WEP_SPIKEDCLUB;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-32)))
		return WEP_BASTARDSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-33)))
		return WEP_SCIMITAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-34)))
		return WEP_INFANTRYAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-35)))
		return WEP_ELVENAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-36)))
		return WEP_QUARTERSTAFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-37)))
		return WEP_ELVENSABRE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-38)))
		return WEP_WARAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-39)))
		return WEP_ELVENSTAFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-40)))
		return WEP_ELVENGLAIVE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-41)))
		return WEP_WOODAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-42)))
		return WEP_DOUBLEBITAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-43)))
		return WEP_FALCHION;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-44)))
		return WEP_PICKAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-45)))
		return WEP_ELVENHAMMER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-46)))
		return WEP_SPIKEDFLAIL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-47)))
		return WEP_SHOOTINGSTAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-48)))
		return WEP_FIGHTERSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-49)))
		return WEP_SPIKEDMACE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-50)))
		return WEP_SAI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-51)))
		return WEP_ARMINGSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-52)))
		return WEP_BEARDEDAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-53)))
		return WEP_DEFENDERSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-54)))
		return WEP_SPIKEDCUDGEL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-55)))
		return WEP_BRONZECUDGEL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-56)))
		return WEP_MILFLAIL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-57)))
		return WEP_BATTLEAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-58)))
		return WEP_KRIEGSHAMMER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-59)))
		return WEP_INFANTRYSTAFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-60)))
		return WEP_DADAO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-61)))
		return WEP_SKIRMISHERSAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-62)))
		return WEP_BARDICHE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-63)))
		return WEP_TEMPLARAXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-64)))
		return WEP_CRUSADERSWORD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-65)))
		return WEP_FLAMBERGE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-66)))
		return WEP_SHIRASAYA;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-67)))
		return WEP_ZATOICHI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-68)))
		return WEP_CLAYMORE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-69)))
		return WEP_PUDAO;
	else
		return WEP_TORCH;
}

float weapon_standardxonoticreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 11;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_SHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_UZI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_GRENADE_LAUNCHER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_CRYLINK;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_NEX;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_HAGAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_ELECTRO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_ROCKET_LAUNCHER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_CARBINE;
	else
		return WEP_LASER;
}

float weapon_moderngunsreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 73;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_HMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_MG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_SHOTGUNAUTOMAT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_PUMPSHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_G98;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_BIGPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_M1921;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_LRR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_CARBINE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_PDW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		return WEP_LIGHTPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		return WEP_LARGEPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		return WEP_LIGHTAUTO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		return WEP_MAGNUM;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		return WEP_AK47;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		return WEP_AKS74U;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		return WEP_TT33PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-20)))
		return WEP_FFMAGNUM;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-21)))
		return WEP_M16MINI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-22)))
		return WEP_M16VN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-23)))
		return WEP_BROWNINGHP;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-24)))
		return WEP_MICROUZI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-25)))
		return WEP_MINIUZI;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-26)))
		return WEP_SKS45;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-27)))
		return WEP_SHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-28)))
		return WEP_SPORTSHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-29)))
		return WEP_STYERAUG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-30)))
		return WEP_M9PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-31)))
		return WEP_STYERTMP;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-32)))
		return WEP_M82RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-33)))
		return WEP_AMR18;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-34)))
		return WEP_SPAS12;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-35)))
		return WEP_LONGPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-36)))
		return WEP_M1903;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-37)))
		return WEP_MOSIN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-38)))
		return WEP_MAUSERPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-39)))
		return WEP_MACHINEPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-40)))
		return WEP_HELLRIEGELSMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-41)))
		return WEP_WEBLEY;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-42)))
		return WEP_WEBLEYLONG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-43)))
		return WEP_CHAUCHAT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-44)))
		return WEP_SHOSHO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-45)))
		return WEP_BAR1918;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-46)))
		return WEP_NAGANT1895;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-47)))
		return WEP_MG0815;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-48)))
		return WEP_LEWISMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-49)))
		return WEP_SVD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-50)))
		return WEP_SPECTRE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-51)))
		return WEP_TEC9;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-52)))
		return WEP_POUNDERSMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-53)))
		return WEP_L85A2;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-54)))
		return WEP_FNSCAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-55)))
		return WEP_G36C;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-56)))
		return WEP_M16A2;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-57)))
		return WEP_P90;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-58)))
		return WEP_FIVESEVENPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-59)))
		return WEP_M93RPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-60)))
		return WEP_T17MMRIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-61)))
		return WEP_FAMAS;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-62)))
		return WEP_M1928;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-63)))
		return WEP_M1929;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-64)))
		return WEP_CZSKORPION;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-65)))
		return WEP_SVSKORPION;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-66)))
		return WEP_M1897TRENCHGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-67)))
		return WEP_ITHACASTAKEOUT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-68)))
		return WEP_STREETSWEEPER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-69)))
		return WEP_TARGETPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-70)))
		return WEP_RPD;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-71)))
		return WEP_M249PARA;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-72)))
		return WEP_PKM;
	else
		return WEP_UZI;
}

float weapon_moderngunscivilianreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 22;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_PUMPSHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_G98;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_BIGPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_LRR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_LIGHTPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_LARGEPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_MAGNUM;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_TT33PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_FFMAGNUM;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_BROWNINGHP;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		return WEP_SPORTSHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		return WEP_M9PISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		return WEP_M1903;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		return WEP_MOSIN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		return WEP_MAUSERPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		return WEP_WEBLEY;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		return WEP_WEBLEYLONG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-20)))
		return WEP_NAGANT1895;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-21)))
		return WEP_TARGETPISTOL;
	else
		return WEP_SKS45;
}

float weapon_explosivesreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 11;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_MINE_LAYER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_HAGAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_ROCKET_LAUNCHER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_SEEKER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_EXPLOSIVE_VEST;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_RPG7_LAUNCHER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_RA4_LAUNCHER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_DEVASTATOR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_HAGAR2;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_MORTAR;
	else
		return WEP_GRENADE_LAUNCHER;
}

float weapon_oldwestreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 20;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_MUSKET;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_PEPPERBOXREVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_NAVY1851REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_COLT44REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_HENRY1860RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_EIGHTGAUGESHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_COLTLIGHTNING;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_SHARPSRIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_EIGHTGAUGESAWEDOFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_TENGAUGEDOUBLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_TENGAUGESAWEDOFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		return WEP_BOWIEKNIFE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		return WEP_ARKANSASTOOTHPICK;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		return WEP_HENRY1860MARESLEG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		return WEP_SCHOFIELDREVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		return WEP_R1856REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		return WEP_WINCHESTER1873RIFLE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		return WEP_WINCHESTER1897;
	else
		return WEP_FLINTLOCKPISTOL;
}

float weapon_wwireplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 24;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_MG0815;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_LEWISMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_NAGANT1895;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_NAVY1851REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_COLT44REVOLVER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_BAR1918;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_EIGHTGAUGESHOTGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_COLTLIGHTNING;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_SHOSHO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_CHAUCHAT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_WEBLEYLONG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_WEBLEY;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		return WEP_HELLRIEGELSMG;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		return WEP_MACHINEPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		return WEP_M1921;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		return WEP_MAUSERPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		return WEP_MOSIN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		return WEP_BIGPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		return WEP_M1903;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-20)))
		return WEP_G98;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-21)))
		return WEP_M1897TRENCHGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-22)))
		return WEP_EIGHTGAUGESAWEDOFF;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-23)))
		return WEP_TENGAUGESAWEDOFF;
	else
		return WEP_TENGAUGEDOUBLE;
}

float weapon_energyreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 13;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_ELECTRO;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_CRYLINK;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))
		return WEP_NEX;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		return WEP_HLAC;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		return WEP_LIGHTNINGGUN;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		return WEP_CRYPISTOL;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		return WEP_CRYLANCER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		return WEP_SUNBEAM;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		return WEP_STARBLAST;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		return WEP_SUNBURST;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		return WEP_SUNBOLT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		return WEP_STARLASE;
	else
		return WEP_LASER;
}

float weapon_moderntoolsreplacement(void)
{
		local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 9;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		return WEP_CHAINSAW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		return WEP_POWERSAW;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		return WEP_CLAWHAMMER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))	
		return WEP_AXE;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))	
		return WEP_CROWBAR;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))	
		return WEP_BAT;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))	
		return WEP_FLAMETHROWER;
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))	
		return WEP_KNIFE;
	else
		return WEP_FLASHLIGHT;
}

float W_G_ModelIsNotPreScaledByOnePointSix (float mywpn);

void weapon_defaultspawnfunc(float wpn)
{
	entity e;
	
	if (autocvar_g_delete_weapon_pickups) {
		if (time < game_starttime + autocvar_g_delete_weapon_pickups_time)
		{
			return;
		}
	}

	if (autocvar_g_replace_weapon_pickups)
	if (autocvar_g_replace_weapon_pickups_rate >= 1
	|| (autocvar_g_replace_weapon_pickups_rate > random()))
	{
	  if (time < game_starttime + autocvar_g_delete_weapon_pickups_time)
	  {
	  	local entity previousself;
		local float myshallreturn;
		myshallreturn = 1;
	  	if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_SPIKES) {
			SMI_spawn_spikes(self.origin, 0);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_FIRE || autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_PILLAR_OF_FIRE) {
			previousself = self;
			e = spawn();
			e.origin = previousself.origin;
			e.solid = SOLID_SLIDEBOX;
			
			if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_FIRE) {
				e.mins = ('-8 -8 -2');
				e.maxs = ('8 8 8');
				e.think = weapon_burningreplacement_think;
			} else {
				e.mins = ('-16 -16 -2');
				e.maxs = ('16 16 16');
				e.think = weapon_burningpillarreplacement_think;
			}
			e.alpha = -1;
			self = e;
			
			setorigin(self, self.origin);
			droptofloor();
			
			self.nextthink = time + 300;
			
			self = previousself;
			
			if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_PILLAR_OF_FIRE) {
				Fire_AddDamage(e, self, 100*9000000000, 9000000000, DEATH_FIRE);
				e.fire_intensity = 41;
				e.fire_nextpartcheck = 1;
			} else {
				Fire_AddDamage(e, self, 10*9000000000, 9000000000, DEATH_FIRE);
			}
			
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_JUMPPADS) {
			local float selected_skin;
			selected_skin = SMI_select_skin();
			SMI_spawn_jumppad(self.origin, selected_skin);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_BUMPERS) {
			local float selected_color;
			selected_color = SMI_select_color(0);
			SMI_spawn_bumper(self.origin, selected_color);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_BALOONS) {
			local float selected_color;
			selected_color = SMI_select_color(1);
			SMI_spawn_baloon(self.origin, selected_color);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_TANKTRAPS) {
			SMI_spawn_tnkpyr(self.origin, 0, 1, 1, 0);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_ABDBLDGS) {
			SMI_spawn_abdbld(self.origin, 0, 1, 1, 0, 0);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_FOLIAGE) {
			if (!replaceweapondidfoliagecvars) {
				Foliage_GetAutoCvars();
				Foliage_Presets();
				replaceweapondidfoliagecvars = 1;
			}
			Foliage_Grow_Thicker(1, self.origin, 2, 100);
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_SCROLLS) {
			previousself = self;
			e = spawn();
			e.origin = previousself.origin;
			
			if (autocvar_g_replace_weapon_pickups_scroll_biased_rate > random())
			{
				weapon_scrollreplacement_biased();
			} else {
				weapon_scrollreplacement();
			}
			
			self = e;
			
			setorigin(self, self.origin);
			droptofloor();			
			self = previousself;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_STDXONWPNS) {
			wpn = weapon_standardxonoticreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_ENRGYWPNS) {
			wpn = weapon_energyreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_EXPLSVWPNS) {
			wpn = weapon_explosivesreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MODGUNCIVILWPNS) {
			wpn = weapon_moderngunscivilianreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MODGUNWPNS) {
			wpn = weapon_moderngunsreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MODTOOLS) {
			wpn = weapon_moderntoolsreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_GUNXPLSVENRGYWPNS) {
			local float myrandom;
			myrandom = random();
			if (myrandom > 0.8) {
				wpn = weapon_moderngunsreplacement();
			} else if (myrandom > 0.65) {
				wpn = weapon_moderngunscivilianreplacement();
			} else if (myrandom > 0.55) {
				wpn = weapon_explosivesreplacement();
			} else if (myrandom > 0.2) {
				wpn = weapon_energyreplacement();
			} else {
				wpn = weapon_moderntoolsreplacement();
			}
		
			myshallreturn = 0; //Got to spawn the weapons so not return;
			
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_WWIWPNS) {
			wpn = weapon_wwireplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_OLDWESTWPNS) {
			wpn = weapon_oldwestreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;	
			
			
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS) {
			wpn = weapon_medievalreplacement();
			myshallreturn = 0; //Got to spawn the weapons so not return;
		} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS) {
			//Some scrolls, mostly medeval weapons
			if (autocvar_g_replace_weapon_pickups_scrollvsmedieval_rate > random()) {
				previousself = self;
				e = spawn();
				e.origin = previousself.origin;
			
				if (autocvar_g_replace_weapon_pickups_scroll_biased_rate > random())
				{
					weapon_scrollreplacement_biased();
				} else {
					weapon_scrollreplacement();
				}
			
				self = e;
			
				setorigin(self, self.origin);
				droptofloor();			
				self = previousself;
			} else {
				wpn = weapon_medievalreplacement();
				myshallreturn = 0; //Got to spawn the weapons so not return;
			}
		}
			
		if (myshallreturn) return;
	  }
	}
	
	
	
	if (autocvar_g_weapon_pickup_realsize) {
		if (W_G_ModelIsNotPreScaledByOnePointSix(wpn)) {
			//The weapon is not artistically pre-scaled to 1.6 times.
			if (autocvar_g_weapon_pickup_realsize == -1) {
				self.scale = 1.6;
			}
		} else {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				self.scale = 0.625;
			}
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
	
	
	
	float t;
	var .float ammofield;
	string s;
	entity oldself;
	float i, j;
	float f;

	if(self.classname != "droppedweapon" && self.classname != "replacedweapon")
	{
		e = get_weaponinfo(wpn);

		if(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
		{
			print("Attempted to spawn a mutator-blocked weapon; these guns will in the future require a mutator\n");
			/*
			objerror("Attempted to spawn a mutator-blocked weapon rejected");
			startitem_failed = TRUE;
			return;
			*/
		}
		
		if(self.spawnflags & g_weaponreplaceabsoluteflag) { //2^20 = 1048576, Arbitrary.
			self.absolute = 1; //Used to not do weaponreplace on weapons only
		}
		
		if ((g_weaponreplacedisabled)
		|| (self.absolute && g_weaponreplaceallowabsolute))
		{
			s = W_ApplyNo_Weaponreplace(e.netname);
		} else {
			s = W_Apply_Weaponreplace(e.netname);
		}
		ret_string = s;
		other = e;
		MUTATOR_CALLHOOK(SetWeaponreplace);
		s = ret_string;
		if(s == "")
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
		t = tokenize_console(s);
		if(t >= 2)
		{
			self.team = --internalteam;
			oldself = self;
			for(i = 1; i < t; ++i)
			{
				s = argv(i);
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(e.netname == s)
					{
						self = spawn();
						copyentity(oldself, self);
						self.classname = "replacedweapon";
						weapon_defaultspawnfunc(j);
						break;
					}
				}
				if(j > WEP_LAST)
				{
					print("The weapon replace list for ", oldself.classname, " contains an unknown weapon ", s, ". Skipped.\n");
				}
			}
			self = oldself;
		}
		if(t >= 1) // always the case!
		{
			s = argv(0);
			wpn = 0;
			for(j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if(e.netname == s)
				{
					wpn = j;
					break;
				}
			}
			if(j > WEP_LAST)
			{
				print("The weapon replace list for ", self.classname, " contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		if(wpn == 0)
		{
			remove(self);
			startitem_failed = TRUE;
			return;
		}
	}

	e = get_weaponinfo(wpn);

	if(!self.respawntime)
	{
		if(WEPSET_CONTAINS_ANY_EA(e, WEPBIT_SUPERWEAPONS))
		{
			self.respawntime = g_pickup_respawntime_superweapon;
			self.respawntimejitter = g_pickup_respawntimejitter_superweapon;
		}
		else
		{
			self.respawntime = g_pickup_respawntime_weapon;
			self.respawntimejitter = g_pickup_respawntimejitter_weapon;
		}
	}

	if(WEPSET_CONTAINS_ANY_EA(e, WEPBIT_SUPERWEAPONS))
		if(!self.superweapons_finished)
			self.superweapons_finished = autocvar_g_balance_superweapons_time;

	if(e.items)
	{
		for(i = 0, j = 1; i < 24; ++i, j *= 2)
		{
			if(e.items & j)
			{
				ammofield = Item_CounterField(j);
				if(!self.ammofield)
					self.ammofield = cvar(strcat("g_pickup_", Item_CounterFieldName(j), "_weapon"));
			}
		}
	}

	// pickup anyway
	if(g_pickup_weapons_anyway)
		self.pickup_anyway = TRUE;

	f = FL_WEAPON;

	// no weapon-stay on superweapons
	if(WEPSET_CONTAINS_ANY_EA(e, WEPBIT_SUPERWEAPONS))
		f |= FL_NO_WEAPON_STAY;

	// weapon stay isn't supported for teamed weapons
	if(self.team)
		f |= FL_NO_WEAPON_STAY;

	// stupid minstagib hack, don't ask
	if(g_minstagib)
		if(self.ammo_cells)
			self.ammo_cells = autocvar_g_minstagib_ammo_drop;

	StartItem(e.model, "weapons/weaponpickup.wav", self.respawntime, self.respawntimejitter, e.message, 0, e.weapon, f, weapon_pickupevalfunc, e.bot_pickupbasevalue);
	if (self.modelindex) // don't precache if self was removed
		weapon_action(e.weapon, WR_PRECACHE);
}


void spawnfunc_weapon_shotgun (void);
void spawnfunc_weapon_uzi (void) {
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_SHOTGUN);
		return;
	}
	weapon_defaultspawnfunc(WEP_UZI);
}

void spawnfunc_weapon_shotgun (void) {
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weapon_defaultspawnfunc(WEP_UZI);
		return;
	}
	weapon_defaultspawnfunc(WEP_SHOTGUN);
}

void spawnfunc_weapon_nex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_NEX);
}

void spawnfunc_weapon_minstanex (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS);
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_MINSTANEX);
}

void spawnfunc_weapon_rocketlauncher (void)
{
	if (g_minstagib)
	{
		minstagib_items(IT_CELLS); // replace rocketlauncher with cells
		self.think = minst_remove_item;
		self.nextthink = time;
		return;
	}
	weapon_defaultspawnfunc(WEP_ROCKET_LAUNCHER);
}

void spawnfunc_item_rockets (void) {
	if(!self.ammo_rockets)
		self.ammo_rockets = g_pickup_rockets;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_rockets.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "rockets", IT_ROCKETS, 0, 0, commodity_pickupevalfunc, 3000);
}

void spawnfunc_item_shells (void);
void spawnfunc_item_bullets (void) {
	if(!weaponswapping)
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_shells();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_nails)
		self.ammo_nails = g_pickup_nails;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_bullets.mdl", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "bullets", IT_NAILS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_cells (void) {
	if(!self.ammo_cells)
		self.ammo_cells = g_pickup_cells;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_cells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "cells", IT_CELLS, 0, 0, commodity_pickupevalfunc, 2000);
}

void spawnfunc_item_shells (void) {
	if(!weaponswapping)
	if(autocvar_sv_q3acompat_machineshotgunswap)
	if(self.classname != "droppedweapon")
	{
		weaponswapping = TRUE;
		spawnfunc_item_bullets();
		weaponswapping = FALSE;
		return;
	}

	if(!self.ammo_shells)
		self.ammo_shells = g_pickup_shells;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/a_shells.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "shells", IT_SHELLS, 0, 0, commodity_pickupevalfunc, 500);
}

void spawnfunc_item_armor_small (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorsmall;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorsmall_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorsmall_anyway;
	StartItem ("models/items/item_armor_small.md3", "misc/armor1.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Armor", IT_ARMOR_SHARD, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_armor_medium (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armormedium;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armormedium_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armormedium_anyway;
	StartItem ("models/items/item_armor_medium.md3", "misc/armor10.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "25 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_armor_big (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorbig;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorbig_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorbig_anyway;
	StartItem ("models/items/item_armor_big.md3", "misc/armor17_5.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "50 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, 20000);
}

void spawnfunc_item_armor_large (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.armorvalue)
		self.armorvalue = g_pickup_armorlarge;
	if(!self.max_armorvalue)
		self.max_armorvalue = g_pickup_armorlarge_max;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_armorlarge_anyway;
	StartItem ("models/items/item_armor_large.md3", "misc/armor25.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Armor", IT_ARMOR, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
}

void spawnfunc_item_health_small (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.max_health)
		self.max_health = g_pickup_healthsmall_max;
	if(!self.health)
		self.health = g_pickup_healthsmall;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthsmall_anyway;
	StartItem ("models/items/g_h1.md3", "misc/minihealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "5 Health", IT_5HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_health_medium (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.max_health)
		self.max_health = g_pickup_healthmedium_max;
	if(!self.health)
		self.health = g_pickup_healthmedium;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthmedium_anyway;
	StartItem ("models/items/g_h25.md3", "misc/mediumhealth.wav", g_pickup_respawntime_short, g_pickup_respawntimejitter_short, "25 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_health_large (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(!self.max_health)
		self.max_health = g_pickup_healthlarge_max;
	if(!self.health)
		self.health = g_pickup_healthlarge;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_healthlarge_anyway;
	StartItem ("models/items/g_h50.md3", "misc/mediumhealth.wav", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "50 Health", IT_25HP, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_health_mega (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(g_minstagib) {
		minstagib_items(IT_NAILS);
	} else {
		if(!self.max_health)
			self.max_health = g_pickup_healthmega_max;
		if(!self.health)
			self.health = g_pickup_healthmega;
		if(!self.pickup_anyway)
			self.pickup_anyway = g_pickup_healthmega_anyway;
		StartItem ("models/items/g_h100.md3", "misc/megahealth.wav", g_pickup_respawntime_long, g_pickup_respawntimejitter_long, "100 Health", IT_HEALTH, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_HIGH);
	}
}

void spawnfunc_item_grenades (void) {
	if(!self.grenades)
		self.grenades = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/weapons/v_ok_grenade.md3", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Grenade", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_fragnades (void) {
	if(!self.fragnades)
		self.fragnades = 1;
	
	self.colormap = (1024 + 3 + 3 * 16);
	StartItem ("models/weapons/v_ok_grenade.md3", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Fragmentation Grenade", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_flashbangs (void) {
	if(!self.flashbangs)
		self.flashbangs = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/weapons/v_ok_grenade.md3", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Flashbang", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_smokenades (void) {
	if(!self.smokenades)
		self.smokenades = 1;
	
	self.colormap = 1023; //Black Hack
	StartItem ("models/weapons/v_ok_grenade.md3", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Smoke Grenade", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_atmines (void) {
	if(!self.atmines)
		self.atmines = 1;
	
	//self.colormap = 1023; //Black Hack
	StartItem ("models/atmine.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Anti-Tank Mine", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_landmines (void) {
	if(!self.landmines)
		self.landmines = 1;
	
	//self.colormap = 1023; //Black Hack
	StartItem ("models/mine.md3", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_medium, g_pickup_respawntimejitter_medium, "Landmine", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void StartItemBullionBarModel (float numberofcoins) {
	local float brand;
	brand = random();
	if (numberofcoins >= 8) {
		if (brand > 0.5) 
			StartItem ("models/wealth/bullionbars/bullionbar8a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar8b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 7) {
		if (brand > 0.66) 
			StartItem ("models/wealth/bullionbars/bullionbar7a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else if (brand > 0.33) 
			StartItem ("models/wealth/bullionbars/bullionbar7b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar7c.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 6) {
		if (brand > 0.66) 
			StartItem ("models/wealth/bullionbars/bullionbar6a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else if (brand > 0.33)
			StartItem ("models/wealth/bullionbars/bullionbar6b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar6c.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 5) {
		if (brand > 0.5) 
			StartItem ("models/wealth/bullionbars/bullionbar5a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar5b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		if (brand > 0.5) 
			StartItem ("models/wealth/bullionbars/bullionbar4a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar4b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		if (brand > 0.75) 
			StartItem ("models/wealth/bullionbars/bullionbar3a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else if (brand > 0.50)
			StartItem ("models/wealth/bullionbars/bullionbar3b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else if (brand > 0.25)
			StartItem ("models/wealth/bullionbars/bullionbar3c.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar3d.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		if (brand > 0.5) 
			StartItem ("models/wealth/bullionbars/bullionbar2a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else	
			StartItem ("models/wealth/bullionbars/bullionbar2b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		if (brand > 0.5) 
			StartItem ("models/wealth/bullionbars/bullionbar1a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
		else
			StartItem ("models/wealth/bullionbars/bullionbar1b.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/wealth/bullionbars/bullionbar1a.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_wealth, g_pickup_respawntimejitter_medium, "Bar", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemCoinModel (float numberofcoins) {
	if (numberofcoins >= 20) {
		StartItem ("models/money/coin20.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 19) {
		StartItem ("models/money/coin19.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 18) {
		StartItem ("models/money/coin18.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 17) {
		StartItem ("models/money/coin17.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 16) {
		StartItem ("models/money/coin16.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 15) {
		StartItem ("models/money/coin15.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 14) {
		StartItem ("models/money/coin14.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 13) {
		StartItem ("models/money/coin13.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 12) {
		StartItem ("models/money/coin12.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 11) {
		StartItem ("models/money/coin11.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 10) {
		StartItem ("models/money/coin10.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 9) {
		StartItem ("models/money/coin9.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 8) {
		StartItem ("models/money/coin8.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 7) {
		StartItem ("models/money/coin7.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 6) {
		StartItem ("models/money/coin6.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 5) {
		StartItem ("models/money/coin5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/money/coin4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/money/coin3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/money/coin2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/money/coin1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/money/coin1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_coin, g_pickup_respawntimejitter_medium, "Coin", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemCoinClearAmounts (void) {
	self.inv_coin = 0;
	self.inv_coin_tin = 0;
	self.inv_coin_iron = 0;
	self.inv_coin_bronze = 0;
	self.inv_coin_copper = 0;
	self.inv_coin_silver = 0;
	self.inv_coin_gold = 0;
	self.inv_coin_plat = 0;
	self.inv_coin_jade = 0;
	self.inv_coin_amberium = 0;
	//Faux
	self.inv_coin_f_tin = 0;
	self.inv_coin_f_iron = 0;
	self.inv_coin_f_bronze = 0;
	self.inv_coin_f_copper = 0;
	self.inv_coin_f_silver = 0;
	self.inv_coin_f_gold = 0;
	self.inv_coin_f_plat = 0;
	self.inv_coin_f_jade = 0;
	self.inv_coin_f_amberium = 0;
	//Counterfeit (old, cladding rubbing off)
	self.inv_coin_cf_tin = 0;
	self.inv_coin_cf_iron = 0;
	self.inv_coin_cf_bronze = 0;
	self.inv_coin_cf_copper = 0;
	self.inv_coin_cf_silver = 0;
	self.inv_coin_cf_gold = 0;
	self.inv_coin_cf_plat = 0;
	self.inv_coin_cf_jade = 0;
	self.inv_coin_cf_amberium = 0;
	//Casino Tokens
	self.inv_casinotoken_yellow = 0;
	self.inv_casinotoken_blue = 0;
	self.inv_casinotoken_gray = 0;
	self.inv_casinotoken_lightgreen = 0;
	self.inv_casinotoken_lightblue = 0;
	self.inv_casinotoken_rose = 0;
	self.inv_casinotoken_black = 0;
	self.inv_casinotoken_seabreeze = 0;
	self.inv_casinotoken_red = 0;
	self.inv_casinotoken_cyan = 0;
	self.inv_casinotoken_tan = 0;
	self.inv_casinotoken_green = 0;
	self.inv_casinotoken_purple = 0;
	//Bars
	self.inv_bar_tin = 0;
	self.inv_bar_iron = 0;
	self.inv_bar_bronze = 0;
	self.inv_bar_copper = 0;
	self.inv_bar_silver = 0;
	self.inv_bar_gold = 0;
	self.inv_bar_plat = 0;
	self.inv_bar_jade = 0;
	self.inv_bar_amberium = 0;
	//Faux Bars
	self.inv_bar_f_tin = 0;
	self.inv_bar_f_iron = 0;
	self.inv_bar_f_bronze = 0;
	self.inv_bar_f_copper = 0;
	self.inv_bar_f_silver = 0;
	self.inv_bar_f_gold = 0;
	self.inv_bar_f_plat = 0;
	self.inv_bar_f_jade = 0;
	self.inv_bar_f_amberium = 0;
	//Gems
	self.inv_gem = 0;
	self.inv_gem_diamond = 0;
	self.inv_gem_jacinth = 0;
	self.inv_gem_ruby = 0;
	self.inv_gem_peridot = 0;
	self.inv_gem_emerald = 0;
	self.inv_gem_topaz = 0;
	self.inv_gem_sapphire = 0;
	self.inv_gem_chalcedony = 0;
	self.inv_gem_agate = 0;
	self.inv_gem_onyx = 0;
	self.inv_gem_mithril = 0;
	self.inv_gem_amethyst = 0;
	self.inv_gem_chrysoberyl = 0;
	self.inv_gem_aquamarine = 0;
	self.inv_gem_quartz = 0;
	self.inv_gem_tourmaline = 0;
	self.inv_gem_pearl = 0;
	self.inv_gem_blackpearl = 0;
	self.inv_gem_glass_r = 0;
	self.inv_gem_glass_g = 0;
	self.inv_gem_glass_b = 0;
	self.inv_gem_glass_y = 0;
	self.inv_gem_glass_w = 0;
	//Faux
	self.inv_gem_f_diamond = 0;
	self.inv_gem_f_jacinth = 0;
	self.inv_gem_f_ruby = 0;
	self.inv_gem_f_peridot = 0;
	self.inv_gem_f_emerald = 0;
	self.inv_gem_f_topaz = 0;
	self.inv_gem_f_sapphire = 0;
	self.inv_gem_f_chalcedony = 0;
	self.inv_gem_f_agate = 0;	
	self.inv_gem_f_onyx = 0;
	self.inv_gem_f_mithril = 0;
	self.inv_gem_f_amethyst = 0;
	self.inv_gem_f_chrysoberyl = 0;
	self.inv_gem_f_aquamarine = 0;
	self.inv_gem_f_quartz = 0;
	self.inv_gem_f_tourmaline = 0;
	self.inv_gem_f_pearl = 0;
	self.inv_gem_f_blackpearl = 0;
}

void StartItemGemModelDia (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/dia/diamond5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/dia/diamond4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/dia/diamond3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/dia/diamond2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/dia/diamond1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/dia/diamond1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelEm (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/em/emerald5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/em/emerald4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/em/emerald3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/em/emerald2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/em/emerald1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/em/emerald1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelGlass (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/glass/glass5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/glass/glass4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/glass/glass3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/glass/glass2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/glass/glass1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/glass/glass1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelHex (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/hex/hex5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/hex/hex4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/hex/hex3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/hex/hex2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/hex/hex1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/hex/hex1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelPeri (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/peri/peridot5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/peri/peridot4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/peri/peridot3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/peri/peridot2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/peri/peridot1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/peri/peridot1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelRb (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/rb/ruby5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/rb/ruby4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/rb/ruby3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/rb/ruby2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/rb/ruby1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/rb/ruby1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelPearl (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/perl/perl5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/perl/perl4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/perl/perl3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/perl/perl2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/perl/perl1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/perl/perl1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void StartItemGemModelSaph (float numberofcoins) {
	if (numberofcoins >= 5) {
		StartItem ("models/gems/saph/sapphire5.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 4) {
		StartItem ("models/gems/saph/sapphire4.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 3) {
		StartItem ("models/gems/saph/sapphire3.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 2) {
		StartItem ("models/gems/saph/sapphire2.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else if (numberofcoins >= 1) {
		StartItem ("models/gems/saph/sapphire1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	} else {
		StartItem ("models/gems/saph/sapphire1.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_gem, g_pickup_respawntimejitter_medium, "Gem Stone", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

float StartItemCoinAmountFailsafe (void) {
	//This way you can set any coin amount
	//To any coin and just change the classname
	if(self.inv_coin)	//Catch all
		return(self.inv_coin);
		
	if(self.inv_gem)	//Catch all 2
		return(self.inv_gem);
		
	//Reverse priority, less likely that mapper
	//when copying one coin and changing it to another classname
	//added too much to an expensive coin at the start
	//more likely that less expensive coins with have greater number
	//(IE: better to err on the side of less)
	if(self.inv_coin_amberium)
		return(self.inv_coin_amberium);
	if(self.inv_coin_jade)
		return(self.inv_coin_jade);
	if(self.inv_coin_plat)
		return(self.inv_coin_plat);
	if(self.inv_coin_gold)
		return(self.inv_coin_gold);
	if(self.inv_coin_silver)
		return(self.inv_coin_silver);
	if(self.inv_coin_copper)
		return(self.inv_coin_copper);
	if(self.inv_coin_bronze)
		return(self.inv_coin_bronze);
	if(self.inv_coin_iron)
		return(self.inv_coin_iron);
	if(self.inv_coin_tin)
		return(self.inv_coin_tin);
		
	if(self.inv_coin_f_amberium)
		return(self.inv_coin_f_amberium);
	if(self.inv_coin_f_jade)
		return(self.inv_coin_f_jade);
	if(self.inv_coin_f_plat)
		return(self.inv_coin_f_plat);
	if(self.inv_coin_f_gold)
		return(self.inv_coin_f_gold);
	if(self.inv_coin_f_silver)
		return(self.inv_coin_f_silver);
	if(self.inv_coin_f_copper)
		return(self.inv_coin_f_copper);
	if(self.inv_coin_f_bronze)
		return(self.inv_coin_f_bronze);
	if(self.inv_coin_f_iron)
		return(self.inv_coin_f_iron);
	if(self.inv_coin_f_tin)
		return(self.inv_coin_f_tin);
		
	if(self.inv_coin_cf_amberium)
		return(self.inv_coin_cf_amberium);
	if(self.inv_coin_cf_jade)
		return(self.inv_coin_cf_jade);
	if(self.inv_coin_cf_plat)
		return(self.inv_coin_cf_plat);
	if(self.inv_coin_cf_gold)
		return(self.inv_coin_cf_gold);
	if(self.inv_coin_cf_silver)
		return(self.inv_coin_cf_silver);
	if(self.inv_coin_cf_copper)
		return(self.inv_coin_cf_copper);
	if(self.inv_coin_cf_bronze)
		return(self.inv_coin_cf_bronze);
	if(self.inv_coin_cf_iron)
		return(self.inv_coin_cf_iron);
	if(self.inv_coin_cf_tin)
		return(self.inv_coin_cf_tin);
	
	if(self.inv_casinotoken_yellow)
		return(self.inv_casinotoken_yellow);	
	if(self.inv_casinotoken_blue)
		return(self.inv_casinotoken_blue);	
	if(self.inv_casinotoken_gray)
		return(self.inv_casinotoken_gray);
	if(self.inv_casinotoken_lightgreen)
		return(self.inv_casinotoken_lightgreen);
	if(self.inv_casinotoken_lightblue)
		return(self.inv_casinotoken_lightblue);
	if(self.inv_casinotoken_rose)
		return(self.inv_casinotoken_rose);
	if(self.inv_casinotoken_black)
		return(self.inv_casinotoken_black);
	if(self.inv_casinotoken_seabreeze)
		return(self.inv_casinotoken_seabreeze);
	if(self.inv_casinotoken_red)
		return(self.inv_casinotoken_red);
	if(self.inv_casinotoken_cyan)
		return(self.inv_casinotoken_cyan);
	if(self.inv_casinotoken_tan)
		return(self.inv_casinotoken_tan);
	if(self.inv_casinotoken_green)
		return(self.inv_casinotoken_green);
	if(self.inv_casinotoken_purple)
		return(self.inv_casinotoken_purple);
		
	
		
	if(self.inv_bar)	//Catch all 3
		return(self.inv_bar);
		
	if(self.ammount)	//Catch all 4
		return(self.ammount);
		
	//If all else fails, guess we're going with one coin.
	return(1);
}

//Gems
//Skin 0 is colormap able
void spawnfunc_item_gem_diamond (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_diamond) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_diamond = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_diamond;
		StartItemCoinClearAmounts();
		self.inv_gem_diamond = mycoinamnt;
	}
	
	self.skin = 1;
	StartItemGemModelDia (self.inv_gem_diamond);
}

void spawnfunc_item_gem_jacinth (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_jacinth) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_jacinth = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_jacinth;
		StartItemCoinClearAmounts();
		self.inv_gem_jacinth = mycoinamnt;
	}
	
	self.skin = 2;
	StartItemGemModelDia (self.inv_gem_jacinth);
}

void spawnfunc_item_gem_emerald (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_emerald) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_emerald = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_emerald;
		StartItemCoinClearAmounts();
		self.inv_gem_emerald = mycoinamnt;
	}
	
	self.skin = 1;
	StartItemGemModelEm (self.inv_gem_emerald);
}

void spawnfunc_item_gem_topaz (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_topaz) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_topaz = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_topaz;
		StartItemCoinClearAmounts();
		self.inv_gem_topaz = mycoinamnt;
	}
	
	self.skin = 2;
	StartItemGemModelEm (self.inv_gem_topaz);
}

void spawnfunc_item_gem_amethyst (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_amethyst) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_amethyst = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_amethyst;
		StartItemCoinClearAmounts();
		self.inv_gem_amethyst = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	if (hrand > 0.75) self.skin = 4;
	else if (hrand > 0.5) self.skin = 3;
	else if (hrand > 0.25) self.skin = 2;
	else self.skin = 1;
	
	StartItemGemModelHex (self.inv_gem_amethyst);
}

void spawnfunc_item_gem_chrysoberyl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_chrysoberyl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_chrysoberyl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_chrysoberyl;
		StartItemCoinClearAmounts();
		self.inv_gem_chrysoberyl = mycoinamnt;
	}
	
	self.skin = 5;
	StartItemGemModelHex (self.inv_gem_chrysoberyl);
}

void spawnfunc_item_gem_aquamarine (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_aquamarine) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_aquamarine = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_aquamarine;
		StartItemCoinClearAmounts();
		self.inv_gem_aquamarine = mycoinamnt;
	}
	
	self.skin = 6;
	StartItemGemModelHex (self.inv_gem_aquamarine);
}

void spawnfunc_item_gem_quartz (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_quartz) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_quartz = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_quartz;
		StartItemCoinClearAmounts();
		self.inv_gem_quartz = mycoinamnt;
	}
	
	self.skin = 7;
	StartItemGemModelHex (self.inv_gem_quartz);
}

void spawnfunc_item_gem_tourmaline (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_tourmaline) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_tourmaline = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_tourmaline;
		StartItemCoinClearAmounts();
		self.inv_gem_tourmaline = mycoinamnt;
	}
	
	self.skin = 8;
	StartItemGemModelHex (self.inv_gem_tourmaline);
}

void spawnfunc_item_gem_peridot (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_peridot) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_peridot = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_peridot;
		StartItemCoinClearAmounts();
		self.inv_gem_peridot = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	if (hrand > 0.75) self.skin = 4;
	else if (hrand > 0.5) self.skin = 3;
	else if (hrand > 0.25) self.skin = 2;
	else self.skin = 1;
	
	StartItemGemModelPeri (self.inv_gem_peridot);
}

void spawnfunc_item_gem_ruby (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_ruby) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_ruby = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_ruby;
		StartItemCoinClearAmounts();
		self.inv_gem_ruby = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	if (hrand > 0.8) self.skin = 3;
	if (hrand > 0.65) self.skin = 2;
	else self.skin = 1;
	
	StartItemGemModelRb (self.inv_gem_ruby);
}

void spawnfunc_item_gem_pearl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_pearl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_pearl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_pearl;
		StartItemCoinClearAmounts();
		self.inv_gem_pearl = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 0;
	
	StartItemGemModelPearl (self.inv_gem_pearl);
}

void spawnfunc_item_gem_blackpearl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_blackpearl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_blackpearl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_blackpearl;
		StartItemCoinClearAmounts();
		self.inv_gem_blackpearl = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 1;
	
	StartItemGemModelPearl (self.inv_gem_blackpearl);
}

void spawnfunc_item_gem_sapphire (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_sapphire) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_sapphire = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_sapphire;
		StartItemCoinClearAmounts();
		self.inv_gem_sapphire = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	if (hrand > 0.50) self.skin = 2;
	else self.skin = 1;
	
	StartItemGemModelSaph (self.inv_gem_sapphire);
}

void spawnfunc_item_gem_chalcedony (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_chalcedony) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_chalcedony = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_chalcedony;
		StartItemCoinClearAmounts();
		self.inv_gem_chalcedony = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	if (hrand > 0.50) self.skin = 4;
	else self.skin = 3;
	
	StartItemGemModelSaph (self.inv_gem_chalcedony);
}

void spawnfunc_item_gem_agate (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_agate) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_agate = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_agate;
		StartItemCoinClearAmounts();
		self.inv_gem_agate = mycoinamnt;
	}
	
	self.skin = 5;
	
	StartItemGemModelSaph (self.inv_gem_agate);
}

void spawnfunc_item_gem_onyx (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_onyx) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_onyx = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_onyx;
		StartItemCoinClearAmounts();
		self.inv_gem_onyx = mycoinamnt;
	}
	
	self.skin = 6;
	
	StartItemGemModelSaph (self.inv_gem_onyx);
}

void spawnfunc_item_gem_mithril (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_mithril) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_mithril = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_mithril;
		StartItemCoinClearAmounts();
		self.inv_gem_mithril = mycoinamnt;
	}
	
	self.skin = 7;
	
	StartItemGemModelSaph (self.inv_gem_mithril);
}

//Faux Gems
void spawnfunc_item_gem_f_diamond (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_diamond) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_diamond = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_diamond;
		StartItemCoinClearAmounts();
		self.inv_gem_f_diamond = mycoinamnt;
	}
	
	self.skin = 0; //colormap //1;
	StartItemGemModelDia (self.inv_gem_f_diamond);
}

void spawnfunc_item_gem_f_jacinth (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_jacinth) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_jacinth = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_jacinth;
		StartItemCoinClearAmounts();
		self.inv_gem_f_jacinth = mycoinamnt;
	}
	
	self.skin = 0; //colormap //2;
	self.colormap = (1024 + 1 + 1 * 16); //Orange
	StartItemGemModelDia (self.inv_gem_f_jacinth);
}

void spawnfunc_item_gem_f_emerald (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_emerald) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_emerald = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_emerald;
		StartItemCoinClearAmounts();
		self.inv_gem_f_emerald = mycoinamnt;
	}
	
	self.skin = 0; //colormap //1;
	self.colormap = (1024 + 3 + 3 * 16); //green
	StartItemGemModelEm (self.inv_gem_f_emerald);
}

void spawnfunc_item_gem_f_topaz (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_topaz) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_topaz = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_topaz;
		StartItemCoinClearAmounts();
		self.inv_gem_f_topaz = mycoinamnt;
	}
	self.colormap = (1024 + 12 + 12 * 16); //Yellow
	self.skin = 0; //colormap //2;
	StartItemGemModelEm (self.inv_gem_f_topaz);
}

void spawnfunc_item_gem_f_amethyst (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_amethyst) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_amethyst = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_amethyst;
		StartItemCoinClearAmounts();
		self.inv_gem_f_amethyst = mycoinamnt;
	}
	
	self.skin = 0; //colormap //1;
	self.colormap = (1024 + 8 + 8 * 16); //Purple
	StartItemGemModelHex (self.inv_gem_f_amethyst);
}

void spawnfunc_item_gem_f_chrysoberyl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_chrysoberyl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_chrysoberyl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_chrysoberyl;
		StartItemCoinClearAmounts();
		self.inv_gem_f_chrysoberyl = mycoinamnt;
	}
	
	self.skin = 0; //colormap //5;
	self.colormap = (1024 + 12 + 12 * 16); //Yellow
	StartItemGemModelHex (self.inv_gem_f_chrysoberyl);
}

void spawnfunc_item_gem_f_aquamarine (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_aquamarine) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_aquamarine = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_aquamarine;
		StartItemCoinClearAmounts();
		self.inv_gem_f_aquamarine = mycoinamnt;
	}
	
	self.skin = 0; //colormap //6;
	self.colormap = (1024 + 6 + 6 * 16); //Cyan
	StartItemGemModelHex (self.inv_gem_f_aquamarine);
}

void spawnfunc_item_gem_f_quartz (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_quartz) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_quartz = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_quartz;
		StartItemCoinClearAmounts();
		self.inv_gem_f_quartz = mycoinamnt;
	}
	
	self.skin = 0; //colormap //7;
	self.colormap = (1024 + 9 + 4 * 16); //Pinkmix
	StartItemGemModelHex (self.inv_gem_f_quartz);
}

void spawnfunc_item_gem_f_tourmaline (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_tourmaline) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_tourmaline = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_tourmaline;
		StartItemCoinClearAmounts();
		self.inv_gem_f_tourmaline = mycoinamnt;
	}
	
	self.skin = 0; //colormap //8;
	self.colormap = (1024 + 4 + 3 * 16); //Mixed red green
	StartItemGemModelHex (self.inv_gem_f_tourmaline);
}

void spawnfunc_item_gem_f_peridot (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_peridot) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_peridot = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_peridot;
		StartItemCoinClearAmounts();
		self.inv_gem_f_peridot = mycoinamnt;
	}
	self.skin = 0; //colormap //1;
	self.colormap = (1024 + 7 + 7 * 16); //Limegreen
	StartItemGemModelPeri (self.inv_gem_f_peridot);
}

void spawnfunc_item_gem_f_ruby (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_ruby) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_ruby = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_ruby;
		StartItemCoinClearAmounts();
		self.inv_gem_f_ruby = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 0; //colormap //1;
	self.colormap = (1024 + 4 + 4 * 16); //Red
	
	StartItemGemModelRb (self.inv_gem_f_ruby);
}

void spawnfunc_item_gem_f_pearl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_pearl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_pearl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_pearl;
		StartItemCoinClearAmounts();
		self.inv_gem_f_pearl = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 0; //colormap //0;
	
	StartItemGemModelPearl (self.inv_gem_f_pearl);
}

void spawnfunc_item_gem_f_blackpearl (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_blackpearl) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_blackpearl = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_blackpearl;
		StartItemCoinClearAmounts();
		self.inv_gem_f_blackpearl = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 1; //colormap //1;
	//self.colormap = 1023; //Black hack
	
	StartItemGemModelPearl (self.inv_gem_f_blackpearl);
}

void spawnfunc_item_gem_f_sapphire (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_sapphire) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_sapphire = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_sapphire;
		StartItemCoinClearAmounts();
		self.inv_gem_f_sapphire = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 0; //colormap //1;
	self.colormap = (1024 + 11 + 11 * 16); //Blue
	
	StartItemGemModelSaph (self.inv_gem_f_sapphire);
}

void spawnfunc_item_gem_f_chalcedony (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_chalcedony) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_chalcedony = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_chalcedony;
		StartItemCoinClearAmounts();
		self.inv_gem_f_chalcedony = mycoinamnt;
	}
	
	float hrand;
	hrand = random();
	
	self.skin = 0; //colormap //3;
	self.colormap = (1024 + 13 + 13 * 16); //Blue (less intense)
	
	StartItemGemModelSaph (self.inv_gem_f_chalcedony);
}

void spawnfunc_item_gem_f_agate (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_agate) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_agate = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_agate;
		StartItemCoinClearAmounts();
		self.inv_gem_f_agate = mycoinamnt;
	}
	
	self.skin = 0; //colormap //5;
	self.colormap = (1024 + 1 + 1 * 16); //Orange
	
	StartItemGemModelSaph (self.inv_gem_f_agate);
}

void spawnfunc_item_gem_f_onyx (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_onyx) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_onyx = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_onyx;
		StartItemCoinClearAmounts();
		self.inv_gem_f_onyx = mycoinamnt;
	}
	
	self.skin = 0; //colormap //6;
	//self.colormap = 1023; //Black Hack
	
	StartItemGemModelSaph (self.inv_gem_f_onyx);
}

void spawnfunc_item_gem_f_mithril (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_f_mithril) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_f_mithril = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_f_mithril;
		StartItemCoinClearAmounts();
		self.inv_gem_f_mithril = mycoinamnt;
	}
	
	self.skin = 0; //colormap //7;
	
	StartItemGemModelSaph (self.inv_gem_f_mithril);
}

//Glass
void spawnfunc_item_gem_glass_r (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_glass_r) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_glass_r = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_glass_w;
		StartItemCoinClearAmounts();
		self.inv_gem_glass_r = mycoinamnt;
	}
	
	self.skin = 0;
	self.colormap = (1024 + 4 + 4 * 16);
	
	StartItemGemModelGlass (self.inv_gem_glass_r);
}

void spawnfunc_item_gem_glass_g (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_glass_g) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_glass_g = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_glass_g;
		StartItemCoinClearAmounts();
		self.inv_gem_glass_g = mycoinamnt;
	}
	
	self.skin = 0;
	self.colormap = (1024 + 3 + 3 * 16);
	StartItemGemModelGlass (self.inv_gem_glass_g);
}

void spawnfunc_item_gem_glass_b (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_glass_b) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_glass_b = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_glass_b;
		StartItemCoinClearAmounts();
		self.inv_gem_glass_b = mycoinamnt;
	}
	
	self.skin = 0;
	self.colormap = (1024 + 11 + 11 * 16);
	
	StartItemGemModelGlass (self.inv_gem_glass_b);
}

void spawnfunc_item_gem_glass_y (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_glass_y) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_glass_y = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_glass_y;
		StartItemCoinClearAmounts();
		self.inv_gem_glass_y = mycoinamnt;
	}
	
	self.skin = 0;
	self.colormap = (1024 + 12 + 12 * 16);
	
	StartItemGemModelGlass (self.inv_gem_glass_y);
}


void spawnfunc_item_gem_glass_w (void) {
	local float mycoinamnt;
	
	if(!self.inv_gem_glass_w) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_gem_glass_w = mycoinamnt;
	} else {
		mycoinamnt = self.inv_gem_glass_w;
		StartItemCoinClearAmounts();
		self.inv_gem_glass_w = mycoinamnt;
	}
	
	self.skin = 0;
	
	StartItemGemModelGlass (self.inv_gem_glass_w);
}

//Coins/Money
//Skin 0 is colormap able
void spawnfunc_item_money_coin_tin (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_tin) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_tin = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_tin;
		StartItemCoinClearAmounts();
		self.inv_coin_tin = mycoinamnt;
	}
	
	self.skin = 1;
	StartItemCoinModel (self.inv_coin_tin);
}

void spawnfunc_item_money_coin_iron (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_iron) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_iron = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_iron;
		StartItemCoinClearAmounts();
		self.inv_coin_iron = mycoinamnt;
	}
	
	self.skin = 2;
	StartItemCoinModel (self.inv_coin_iron);
}

void spawnfunc_item_money_coin_bronze (void) {
	local float mycoinamnt;

	if(!self.inv_coin_bronze) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_bronze = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_bronze;
		StartItemCoinClearAmounts();
		self.inv_coin_bronze = mycoinamnt;
	}
	
	self.skin = 3;
	StartItemCoinModel (self.inv_coin_bronze);
}

void spawnfunc_item_money_coin_copper (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_copper) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_copper = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_copper;
		StartItemCoinClearAmounts();
		self.inv_coin_copper = mycoinamnt;
	}
	
	self.skin = 4;
	StartItemCoinModel (self.inv_coin_copper);
}

void spawnfunc_item_money_coin_silver (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_silver) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_silver = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_silver;
		StartItemCoinClearAmounts();
		self.inv_coin_silver = mycoinamnt;
	}
	
	self.skin = 5;
	StartItemCoinModel (self.inv_coin_silver);
}

void spawnfunc_item_money_coin_gold (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_gold) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_gold = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_gold;
		StartItemCoinClearAmounts();
		self.inv_coin_gold = mycoinamnt;
	}
	
	self.skin = 6;
	StartItemCoinModel (self.inv_coin_gold);
}

void spawnfunc_item_money_coin_plat (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_plat) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_plat = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_plat;
		StartItemCoinClearAmounts();
		self.inv_coin_plat = mycoinamnt;
	}
	
	self.skin = 7;
	StartItemCoinModel (self.inv_coin_plat);
}

void spawnfunc_item_money_coin_jade (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_jade) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_jade = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_jade;
		StartItemCoinClearAmounts();
		self.inv_coin_jade = mycoinamnt;
	}
	
	self.skin = 8;
	StartItemCoinModel (self.inv_coin_jade);
}

void spawnfunc_item_money_coin_amberium (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_amberium) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_amberium = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_amberium;
		StartItemCoinClearAmounts();
		self.inv_coin_amberium = mycoinamnt;
	}
	
	self.skin = 9;
	StartItemCoinModel (self.inv_coin_amberium);
}

//Faux Coins: Fake Coins
//Skin 10 is colormap able
void spawnfunc_item_money_coin_f_tin (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_tin) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_tin = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_tin;
		StartItemCoinClearAmounts();
		self.inv_coin_f_tin = mycoinamnt;
	}
	
	self.skin = 11;
	StartItemCoinModel (self.inv_coin_f_tin);
}

void spawnfunc_item_money_coin_f_iron (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_iron) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_iron = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_iron;
		StartItemCoinClearAmounts();
		self.inv_coin_f_iron = mycoinamnt;
	}
	
	self.skin = 12;
	StartItemCoinModel (self.inv_coin_f_iron);
}

void spawnfunc_item_money_coin_f_bronze (void) {
	local float mycoinamnt;

	if(!self.inv_coin_f_bronze) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_bronze = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_bronze;
		StartItemCoinClearAmounts();
		self.inv_coin_f_bronze = mycoinamnt;
	}
	
	self.skin = 13;
	StartItemCoinModel (self.inv_coin_f_bronze);
}

void spawnfunc_item_money_coin_f_copper (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_copper) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_copper = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_copper;
		StartItemCoinClearAmounts();
		self.inv_coin_f_copper = mycoinamnt;
	}
	
	self.skin = 14;
	StartItemCoinModel (self.inv_coin_f_copper);
}

void spawnfunc_item_money_coin_f_silver (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_silver) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_silver = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_silver;
		StartItemCoinClearAmounts();
		self.inv_coin_f_silver = mycoinamnt;
	}
	
	self.skin = 15;
	StartItemCoinModel (self.inv_coin_f_silver);
}

void spawnfunc_item_money_coin_f_gold (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_gold) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_gold = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_gold;
		StartItemCoinClearAmounts();
		self.inv_coin_f_gold = mycoinamnt;
	}
	
	self.skin = 16;
	StartItemCoinModel (self.inv_coin_f_gold);
}

void spawnfunc_item_money_coin_f_plat (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_plat) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_plat = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_plat;
		StartItemCoinClearAmounts();
		self.inv_coin_f_plat = mycoinamnt;
	}
	
	self.skin = 17;
	StartItemCoinModel (self.inv_coin_f_plat);
}

void spawnfunc_item_money_coin_f_jade (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_jade) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_jade = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_jade;
		StartItemCoinClearAmounts();
		self.inv_coin_f_jade = mycoinamnt;
	}
	
	self.skin = 18;
	StartItemCoinModel (self.inv_coin_f_jade);
}

void spawnfunc_item_money_coin_f_amberium (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_f_amberium) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_f_amberium = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_f_amberium;
		StartItemCoinClearAmounts();
		self.inv_coin_f_amberium = mycoinamnt;
	}
	
	self.skin = 19;
	StartItemCoinModel (self.inv_coin_f_amberium);
}


//Counterfeit Coins: Old counterfeit Coins with cladding rubbing off
//Skin 20 (will be) colormap able
void spawnfunc_item_money_coin_cf_tin (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_tin) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_tin = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_tin;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_tin = mycoinamnt;
	}
	
	self.skin = 21;
	StartItemCoinModel (self.inv_coin_cf_tin);
}

void spawnfunc_item_money_coin_cf_iron (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_iron) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_iron = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_iron;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_iron = mycoinamnt;
	}
	
	self.skin = 22;
	StartItemCoinModel (self.inv_coin_cf_iron);
}

void spawnfunc_item_money_coin_cf_bronze (void) {
	local float mycoinamnt;

	if(!self.inv_coin_cf_bronze) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_bronze = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_bronze;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_bronze = mycoinamnt;
	}
	
	self.skin = 23;
	StartItemCoinModel (self.inv_coin_cf_bronze);
}

void spawnfunc_item_money_coin_cf_copper (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_copper) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_copper = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_copper;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_copper = mycoinamnt;
	}
	
	self.skin = 24;
	StartItemCoinModel (self.inv_coin_cf_copper);
}

void spawnfunc_item_money_coin_cf_silver (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_silver) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_silver = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_silver;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_silver = mycoinamnt;
	}
	
	self.skin = 25;
	StartItemCoinModel (self.inv_coin_cf_silver);
}

void spawnfunc_item_money_coin_cf_gold (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_gold) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_gold = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_gold;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_gold = mycoinamnt;
	}
	
	self.skin = 26;
	StartItemCoinModel (self.inv_coin_cf_gold);
}

void spawnfunc_item_money_coin_cf_plat (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_plat) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_plat = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_plat;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_plat = mycoinamnt;
	}
	
	self.skin = 27;
	StartItemCoinModel (self.inv_coin_cf_plat);
}

void spawnfunc_item_money_coin_cf_jade (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_jade) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_jade = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_jade;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_jade = mycoinamnt;
	}
	
	self.skin = 28;
	StartItemCoinModel (self.inv_coin_cf_jade);
}

void spawnfunc_item_money_coin_cf_amberium (void) {
	local float mycoinamnt;
	
	if(!self.inv_coin_cf_amberium) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_coin_cf_amberium = mycoinamnt;
	} else {
		mycoinamnt = self.inv_coin_cf_amberium;
		StartItemCoinClearAmounts();
		self.inv_coin_cf_amberium = mycoinamnt;
	}
	
	self.skin = 29;
	StartItemCoinModel (self.inv_coin_cf_amberium);
}



//Casino Tokens
//No "intrinsic" value
//Yellow: maybe: 10 Plat
void spawnfunc_item_casinotoken_yellow (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_yellow) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_yellow = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_yellow;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_yellow = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 12 + 12 * 16); //Yellow
	StartItemCoinModel (self.inv_casinotoken_yellow);
}

//Blue: perhaps: 20 Plat
void spawnfunc_item_casinotoken_blue (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_blue) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_blue = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_blue;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_blue = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 11 + 11 * 16); //Blue
	StartItemCoinModel (self.inv_casinotoken_blue);
}

//Gray: maybe: 35 Plat
void spawnfunc_item_casinotoken_gray (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_gray) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_gray = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_gray;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_gray = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = 1024;
	StartItemCoinModel (self.inv_casinotoken_gray);
}

//Lightgreen: maybe: 50 Plat
void spawnfunc_item_casinotoken_lightgreen (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_lightgreen) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_lightgreen = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_lightgreen;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_lightgreen = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 7 + 7 * 16); //LightGreen
	StartItemCoinModel (self.inv_casinotoken_lightgreen);
}

//Lightblue: maybe: 75 Plat
void spawnfunc_item_casinotoken_lightblue (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_lightblue) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_lightblue = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_lightblue;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_lightblue = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 5 + 5 * 16); //LightBlue
	StartItemCoinModel (self.inv_casinotoken_lightblue);
}

//Rose: maybe: 100 Plat
void spawnfunc_item_casinotoken_rose (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_rose) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_rose = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_rose;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_rose = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 10 + 10 * 16); //Rose
	StartItemCoinModel (self.inv_casinotoken_rose);
}

//Black: maybe: 150 Plat
void spawnfunc_item_casinotoken_black (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_black) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_black = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_black;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_black = mycoinamnt;
	}
	
	//self.skin = 30;
	////self.colormap = (1024 + 0 + 0 * 16);
	//self.colormap = 1024;
	self.skin = 31;
	StartItemCoinModel (self.inv_casinotoken_black);
}

//Seabreeze: maybe: 200 Plat
void spawnfunc_item_casinotoken_seabreeze (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_seabreeze) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_seabreeze = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_seabreeze;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_seabreeze = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 2 + 2 * 16); //Seabreeze
	StartItemCoinModel (self.inv_casinotoken_seabreeze);
}

//Red: perhaps: 400 Plat (20*20)
void spawnfunc_item_casinotoken_red (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_red) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_red = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_red;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_red = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 4 + 4 * 16); //Red
	StartItemCoinModel (self.inv_casinotoken_red);
}

//Cyan: perhaps: 8000 Plat (400*20)
void spawnfunc_item_casinotoken_cyan (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_cyan) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_cyan = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_cyan;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_cyan = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 6 + 6 * 16); //Cyan
	StartItemCoinModel (self.inv_casinotoken_cyan);
}

//Tan perhaps: 160000 Plat (8000*20)
void spawnfunc_item_casinotoken_tan (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_tan) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_tan = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_tan;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_tan = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 1 + 1 * 16); //orange
	StartItemCoinModel (self.inv_casinotoken_tan);
}

//Green perhaps: 3200000 Plat (160000*20)
void spawnfunc_item_casinotoken_green (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_green) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_green = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_green;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_green = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 3 + 3 * 16); //Green
	StartItemCoinModel (self.inv_casinotoken_green);
}

//Purple perhaps: 64000000 Plat (3200000*20)
void spawnfunc_item_casinotoken_purple (void) {
	local float mycoinamnt;
	
	if(!self.inv_casinotoken_purple) {
		mycoinamnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_casinotoken_purple = mycoinamnt;
	} else {
		mycoinamnt = self.inv_casinotoken_purple;
		StartItemCoinClearAmounts();
		self.inv_casinotoken_purple = mycoinamnt;
	}
	
	self.skin = 30;
	self.colormap = (1024 + 8 + 8 * 16); //Purple
	StartItemCoinModel (self.inv_casinotoken_purple);
}



//Bullion Bars
//Skin 0 is colormap able
void spawnfunc_item_bullion_bar_tin (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_tin) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_tin = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_tin;
		StartItemCoinClearAmounts();
		self.inv_bar_tin = mybaramnt;
	}
	
	self.skin = 1;
	StartItemBullionBarModel (self.inv_bar_tin);
}

void spawnfunc_item_bullion_bar_iron (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_iron) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_iron = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_iron;
		StartItemCoinClearAmounts();
		self.inv_bar_iron = mybaramnt;
	}
	
	self.skin = 2;
	StartItemBullionBarModel (self.inv_bar_iron);
}

void spawnfunc_item_bullion_bar_bronze (void) {
	local float mybaramnt;

	if(!self.inv_bar_bronze) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_bronze = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_bronze;
		StartItemCoinClearAmounts();
		self.inv_bar_bronze = mybaramnt;
	}
	
	self.skin = 3;
	StartItemBullionBarModel (self.inv_bar_bronze);
}

void spawnfunc_item_bullion_bar_copper (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_copper) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_copper = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_copper;
		StartItemCoinClearAmounts();
		self.inv_bar_copper = mybaramnt;
	}
	
	self.skin = 4;
	StartItemBullionBarModel (self.inv_bar_copper);
}

void spawnfunc_item_bullion_bar_silver (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_silver) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_silver = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_silver;
		StartItemCoinClearAmounts();
		self.inv_bar_silver = mybaramnt;
	}
	
	self.skin = 5;
	StartItemBullionBarModel (self.inv_bar_silver);
}

void spawnfunc_item_bullion_bar_gold (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_gold) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_gold = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_gold;
		StartItemCoinClearAmounts();
		self.inv_bar_gold = mybaramnt;
	}
	
	self.skin = 6;
	StartItemBullionBarModel (self.inv_bar_gold);
}

void spawnfunc_item_bullion_bar_plat (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_plat) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_plat = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_plat;
		StartItemCoinClearAmounts();
		self.inv_bar_plat = mybaramnt;
	}
	
	self.skin = 7;
	StartItemBullionBarModel (self.inv_bar_plat);
}

void spawnfunc_item_bullion_bar_jade (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_jade) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_jade = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_jade;
		StartItemCoinClearAmounts();
		self.inv_bar_jade = mybaramnt;
	}
	
	self.skin = 8;
	StartItemBullionBarModel (self.inv_bar_jade);
}

void spawnfunc_item_bullion_bar_amberium (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_amberium) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_amberium = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_amberium;
		StartItemCoinClearAmounts();
		self.inv_bar_amberium = mybaramnt;
	}
	
	self.skin = 9;
	StartItemBullionBarModel (self.inv_bar_amberium);
}

//Faux Fake bars
void spawnfunc_item_bullion_bar_f_tin (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_tin) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_tin = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_tin;
		StartItemCoinClearAmounts();
		self.inv_bar_f_tin = mybaramnt;
	}
	
	self.skin = 0; // 1;
	StartItemBullionBarModel (self.inv_bar_f_tin);
}

void spawnfunc_item_bullion_bar_f_iron (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_iron) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_iron = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_iron;
		StartItemCoinClearAmounts();
		self.inv_bar_f_iron = mybaramnt;
	}
	
	self.skin = 11; // 2;
	//self.colormap = -1;
	//self.colormod = '-1 -1 -1';
	StartItemBullionBarModel (self.inv_bar_f_iron);
}

void spawnfunc_item_bullion_bar_f_bronze (void) {
	local float mybaramnt;

	if(!self.inv_bar_f_bronze) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_bronze = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_bronze;
		StartItemCoinClearAmounts();
		self.inv_bar_f_bronze = mybaramnt;
	}
	
	self.skin = 0; // 3;
	//self.colormap = (1024 + 1 + 4 * 16); //Redish
	//self.colormap = (1024 + 1 + 5 * 16); //Silver 
	//self.colormap = (1024 + 12 + 4 * 16); //Orange
	//self.colormap = (1024 + 12 + 6 * 16); //Lighter green
	//self.colormap = (1024 + 12 + 7 * 16); //Yellow greenish
	//self.colormap = (1024 + 12 + 8 * 16); //Light purplrish, almost brown
	//self.colormap = (1024 + 1 + 8 * 16); //pinkish
	//self.colormap = (1024 + 12 + 9 * 16); //lighter pink
	self.colormap = (1024 + 12 + 10 * 16); //pink almost brown
	//self.colormap = (1024 + 12 + 11 * 16); //silver color
	//self.colormap = (1024 + 12 + 13 * 16); //Mixes to light green, pastel
	//self.colormap = (1024 + 12 + 14 * 16); //Yellowish
	//self.colormap = (1024 + 4 + 14 * 16); //pinkish
	//self.colormap = (1024 + 1 + 14 * 16); //Orange
	//self.colormap = (1024 + 12 + 8 * 16);
	StartItemBullionBarModel (self.inv_bar_f_bronze);
}

void spawnfunc_item_bullion_bar_f_copper (void) {
	local float mybaramnt;

	if(!self.inv_bar_f_copper) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_copper = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_copper;
		StartItemCoinClearAmounts();
		self.inv_bar_f_copper = mybaramnt;
	}
	
	self.skin = 0; // 4;
	self.colormap = (1024 + 12 + 1 * 16); //Orange Yellow
	StartItemBullionBarModel (self.inv_bar_f_copper);
}

void spawnfunc_item_bullion_bar_f_silver (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_silver) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_silver = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_silver;
		StartItemCoinClearAmounts();
		self.inv_bar_f_silver = mybaramnt;
	}
	
	self.skin = 0; // 5;
	self.colormap = (1024 + 6 + 4 * 16); //Mixes to lighter siver
	StartItemBullionBarModel (self.inv_bar_f_silver);
}

void spawnfunc_item_bullion_bar_f_gold (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_gold) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_gold = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_gold;
		StartItemCoinClearAmounts();
		self.inv_bar_f_gold = mybaramnt;
	}
	
	self.skin = 0; // 6;
	self.colormap = (1024 + 12 + 12 * 16); //Yellow
	StartItemBullionBarModel (self.inv_bar_f_gold);
}

void spawnfunc_item_bullion_bar_f_plat (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_plat) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_plat = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_plat;
		StartItemCoinClearAmounts();
		self.inv_bar_f_plat = mybaramnt;
	}
	
	self.skin = 0; // 7;
	self.colormap = (1024 + 1 + 13 * 16); //Orange Blue
	StartItemBullionBarModel (self.inv_bar_f_plat);
}

void spawnfunc_item_bullion_bar_f_jade (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_jade) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_jade = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_jade;
		StartItemCoinClearAmounts();
		self.inv_bar_f_jade = mybaramnt;
	}
	
	self.skin = 0; // 8;
	//self.colormap = (1024 + 3 + 6 * 16); //
	self.colormap = (1024 + 12 + 6 * 16);
	StartItemBullionBarModel (self.inv_bar_f_jade);
}

void spawnfunc_item_bullion_bar_f_amberium (void) {
	local float mybaramnt;
	
	if(!self.inv_bar_f_amberium) {
		mybaramnt = StartItemCoinAmountFailsafe();
		StartItemCoinClearAmounts();
		self.inv_bar_f_amberium = mybaramnt;
	} else {
		mybaramnt = self.inv_bar_f_amberium;
		StartItemCoinClearAmounts();
		self.inv_bar_f_amberium = mybaramnt;
	}
	
	self.skin = 0; // 9;
	self.colormap = (1024 + 14 + 14 * 16); //Orange2
	StartItemBullionBarModel (self.inv_bar_f_amberium);
}



//Potions

void spawnfunc_item_potion_health_small (void) {
	if(!self.inv_potion_health_small)
		self.inv_potion_health_small = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	if (random() > 0.5) self.skin = 6; else self.skin = 3;
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Healing", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_health_medium (void) {
	if(!self.inv_potion_health_medium)
		self.inv_potion_health_medium = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	if (random() > 0.5) self.skin = 6; else self.skin = 3;
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Healing", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_health_large (void) {
	if(!self.inv_potion_health_large)
		self.inv_potion_health_large = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	if (random() > 0.5) self.skin = 6; else self.skin = 3;
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Healing", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_mana_small (void) {
	if(!self.inv_potion_mana_small)
		self.inv_potion_mana_small = 1;
	
	//self.colormap = (1024 + 11 + 11 * 16);
	if (random() > 0.5) self.skin = 7; else self.skin = 4;
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Mana", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_mana_medium (void) {
	if(!self.inv_potion_mana_medium)
		self.inv_potion_mana_medium = 1;
	
	//self.colormap = (1024 + 11 + 11 * 16);
	if (random() > 0.5) self.skin = 7; else self.skin = 4;
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Mana", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_potion_mana_large (void) {
	if(!self.inv_potion_mana_large)
		self.inv_potion_mana_large = 1;
	
	//self.colormap = (1024 + 11 + 11 * 16);
	if (random() > 0.5) self.skin = 7; else self.skin = 4;
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Mana", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_rejuv_small (void) {
	if(!self.inv_potion_rejuv_small)
		self.inv_potion_rejuv_small = 1;

	//self.colormap = (1024 + 12 + 12 * 16);
	if (random() > 0.5) self.skin = 8; else self.skin = 5;
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Rejuvenation", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_rejuv_medium (void) {
	if(!self.inv_potion_rejuv_medium)
		self.inv_potion_rejuv_medium = 1;
	
	//self.colormap = (1024 + 12 + 12 * 16);
	if (random() > 0.5) self.skin = 8; else self.skin = 5;
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Rejuvenation", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_potion_rejuv_large (void) {
	if(!self.inv_potion_rejuv_large)
		self.inv_potion_rejuv_large = 1;
	
	//self.colormap = (1024 + 12 + 12 * 16);
	if (random() > 0.5) self.skin = 8; else self.skin = 5;
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Rejuvenation", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
//
void spawnfunc_item_potion_vodka_small (void) {
	if(!self.inv_potion_vodka_small)
		self.inv_potion_vodka_small = 1;

	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Vodka", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_vodka_medium (void) {
	if(!self.inv_potion_vodka_medium)
		self.inv_potion_vodka_medium = 1;
	
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Vodka", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_vodka_large (void) {
	if(!self.inv_potion_vodka_large)
		self.inv_potion_vodka_large = 1;
	
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Vodka", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
//
void spawnfunc_item_potion_merlot_small (void) {
	if(!self.inv_potion_merlot_small)
		self.inv_potion_merlot_small = 1;

	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Merlot", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_merlot_medium (void) {
	if(!self.inv_potion_merlot_medium)
		self.inv_potion_merlot_medium = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Merlot", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_merlot_large (void) {
	if(!self.inv_potion_merlot_large)
		self.inv_potion_merlot_large = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Merlot", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
//
void spawnfunc_item_potion_ale_small (void) {
	if(!self.inv_potion_ale_small)
		self.inv_potion_ale_small = 1;

	self.colormap = (1024 + 14 + 14 * 16);
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Ale", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_ale_medium (void) {
	if(!self.inv_potion_ale_medium)
		self.inv_potion_ale_medium = 1;
	
	self.colormap = (1024 + 14 + 14 * 16);
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Ale", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_ale_large (void) {
	if(!self.inv_potion_ale_large)
		self.inv_potion_ale_large = 1;
	
	self.colormap = (1024 + 14 + 14 * 16);
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Ale", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
//
void spawnfunc_item_potion_water_small (void) {
	if(!self.inv_potion_water_small)
		self.inv_potion_water_small = 1;

	self.colormap = (1024 + 13 + 2 * 16);
	StartItem ("models/items/potion_small.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Small Potion of Water", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_water_medium (void) {
	if(!self.inv_potion_water_medium)
		self.inv_potion_water_medium = 1;
	
	self.colormap = (1024 + 13 + 2 * 16);
	StartItem ("models/items/potion_medium.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Potion of Water", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_potion_water_large (void) {
	if(!self.inv_potion_water_large)
		self.inv_potion_water_large = 1;
	
	self.colormap = (1024 + 13 + 2 * 16);
	StartItem ("models/items/potion_large.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_potion, g_pickup_respawntimejitter_medium, "Large Potion of Water", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
//
void spawnfunc_item_food_bellpepper (void) {
	if(!self.inv_food_bellpepper)
		self.inv_food_bellpepper = 1;

	StartItem ("models/food/bellpepper.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Bellpepper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_bread (void) {
	if(!self.inv_food_bread)
		self.inv_food_bread = 1;

	StartItem ("models/food/bread.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Loaf of Bread", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_cheeze (void) {
	if(!self.inv_food_cheeze)
		self.inv_food_cheeze = 1;

	StartItem ("models/food/cheeze.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Wedge of Cheeze", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_garlic (void) {
	if(!self.inv_food_garlic)
		self.inv_food_garlic = 1;
	if(!self.smell_garlic)	
		self.smell_garlic = 0.01;

	StartItem ("models/food/garlic.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Garlic", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_grapes (void) {
	if(!self.inv_food_grapes)
		self.inv_food_grapes = 1;

	StartItem ("models/food/grapes.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Grapes", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_onion (void) {
	if(!self.inv_food_onion)
		self.inv_food_onion = 1;

	StartItem ("models/food/onion.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Onion", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_tomato (void) {
	if(!self.inv_food_tomato)
		self.inv_food_tomato = 1;

	StartItem ("models/food/tomato.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "Tomato", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_food_turkeyleg (void) {
	if(!self.inv_food_turkeyleg)
		self.inv_food_turkeyleg = 1;

	StartItem ("models/food/turkeyleg.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_food, g_pickup_respawntimejitter_medium, "TurkeyLeg", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_faeces_small (void) {
	if (autocvar_sv_risque >= 0.5) {
	
		if(!self.inv_faeces_small)
			self.inv_faeces_small = 1;
		if(!self.smell_faeces)	
			self.smell_faeces = 0.15;

		self.isfilth = 1;
		self.transfer_smell_rate_any = 0.75;
		StartItem ("models/food/byprdct/faeces0.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "faeces", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void spawnfunc_item_faeces_medium (void) {
	if (autocvar_sv_risque >= 0.5) {
		if(!self.inv_faeces_medium)
			self.inv_faeces_medium = 1;
		if(!self.smell_faeces)	
			self.smell_faeces = 0.25;

		self.isfilth = 1;
		self.transfer_smell_rate_any = 0.75;
		StartItem ("models/food/byprdct/faeces1.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "faeces", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

void spawnfunc_item_faeces_large (void) {
	if (autocvar_sv_risque >= 0.5) {
		if(!self.inv_faeces_large)
			self.inv_faeces_large = 1;
		if(!self.smell_faeces)	
			self.smell_faeces = 0.35;

		self.isfilth = 1;
		self.transfer_smell_rate_any = 0.75;
		StartItem ("models/food/byprdct/faeces1.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "faeces", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
	}
}

//Misc Items
void spawnfunc_item_misc_suppressor45 (void) {
	if(!self.inv_misc_suppressor45)
		self.inv_misc_suppressor45 = 1;
		
	StartItem ("models/misc/suppressors/suppressor45.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_suppressormac10 (void) {
	if(!self.inv_misc_suppressormac10)
		self.inv_misc_suppressormac10 = 1;
		
	StartItem ("models/misc/suppressors/suppressormac10.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_suppressor9mm (void) {
	if(!self.inv_misc_suppressor9mm)
		self.inv_misc_suppressor9mm = 1;
		
	StartItem ("models/misc/suppressors/suppressor9mm.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_suppressorpdw (void) {
	if(!self.inv_misc_suppressorpdw)
		self.inv_misc_suppressorpdw = 1;
		
	StartItem ("models/misc/suppressors/suppressorpdw.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_suppressor5n7mm (void) {
	if(!self.inv_misc_suppressor5n7mm)
		self.inv_misc_suppressor5n7mm = 1;
		
	StartItem ("models/misc/suppressors/suppressor5n7mm.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_suppressorrifle (void) {
	if(!self.inv_misc_suppressorrifle)
		self.inv_misc_suppressorrifle = 1;
		
	StartItem ("models/misc/suppressors/suppressorrifle.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_cylinder_r1856 (void) {
	if(!self.inv_misc_cylinder_r1856)
		self.inv_misc_cylinder_r1856 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item is not artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize == -1) {
			self.scale = 1.6;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/cylinders/cylinder_r1856.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_exmag_ak47_50 (void) {
	if(!self.inv_misc_exmag_ak47_50)
		self.inv_misc_exmag_ak47_50 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak47exmag50.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_exmag_ak47_100 (void) {
	if(!self.inv_misc_exmag_ak47_100)
		self.inv_misc_exmag_ak47_100 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak47exmag100.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_drum_ak47_75 (void) {
	if(!self.inv_misc_drum_ak47_75)
		self.inv_misc_drum_ak47_75 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak47drum75.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



void spawnfunc_item_misc_mag_ak47_30 (void) {
	if(!self.inv_misc_mag_ak47_30)
		self.inv_misc_mag_ak47_30 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak47mag30.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}





void spawnfunc_item_misc_exmag_uzi_40 (void) {
	if(!self.inv_misc_exmag_uzi_40)
		self.inv_misc_exmag_uzi_40 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uziexmag40.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_exmag_uzi_50 (void) {
	if(!self.inv_misc_exmag_uzi_50)
		self.inv_misc_exmag_uzi_50 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uziexmag50.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_exmag_uzi_106 (void) {
	if(!self.inv_misc_exmag_uzi_106)
		self.inv_misc_exmag_uzi_106 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uziexmag106.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_drum_uzi_82 (void) {
	if(!self.inv_misc_drum_uzi_82)
		self.inv_misc_drum_uzi_82 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uzidrum82.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



void spawnfunc_item_misc_mag_uzi_32 (void) {
	if(!self.inv_misc_mag_uzi_32)
		self.inv_misc_mag_uzi_32 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uzimag32.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_mag_uzi_25 (void) {
	if(!self.inv_misc_mag_uzi_25)
		self.inv_misc_mag_uzi_25 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uzimag25.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_uzi_20 (void) {
	if(!self.inv_misc_mag_uzi_20)
		self.inv_misc_mag_uzi_20 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/uzimag20.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_mag_m16_20 (void) {
	if(!self.inv_misc_mag_m16_20)
		self.inv_misc_mag_m16_20 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/m16mag20.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_m16_30 (void) {
	if(!self.inv_misc_mag_m16_30)
		self.inv_misc_mag_m16_30 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/m16mag30.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_betacmag_m16 (void) {
	if(!self.inv_misc_betacmag_m16)
		self.inv_misc_betacmag_m16 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/m16betacmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}





void spawnfunc_item_misc_betacmag_lightpistol (void) {
	if(!self.inv_misc_betacmag_lightpistol)
		self.inv_misc_betacmag_lightpistol = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item is not artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize == -1) {
			self.scale = 1.6;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lightpistolbetacmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_drum_lightpistol (void) {
	if(!self.inv_misc_drum_lightpistol)
		self.inv_misc_drum_lightpistol = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item is not artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize == -1) {
			self.scale = 1.6;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lightpistoldrum.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_exmag_lightpistol (void) {
	if(!self.inv_misc_exmag_lightpistol)
		self.inv_misc_exmag_lightpistol = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item is not artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize == -1) {
			self.scale = 1.6;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lightpistolexmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_lightpistol (void) {
	if(!self.inv_misc_mag_lightpistol)
		self.inv_misc_mag_lightpistol = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item is not artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize == -1) {
			self.scale = 1.6;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lightpistolmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}










void spawnfunc_item_misc_betacmag_pdw (void) {
	if(!self.inv_misc_betacmag_pdw)
		self.inv_misc_betacmag_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwbetacmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_drum_pdw (void) {
	if(!self.inv_misc_drum_pdw)
		self.inv_misc_drum_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwdrum.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_exmag40_pdw (void) {
	if(!self.inv_misc_exmag40_pdw)
		self.inv_misc_exmag40_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwexmag40.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_stdmag_pdw (void) {
	if(!self.inv_misc_stdmag_pdw)
		self.inv_misc_stdmag_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwstdmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_misc_smallmag_pdw (void) {
	if(!self.inv_misc_smallmag_pdw)
		self.inv_misc_smallmag_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwsmallmag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_tinymag_pdw (void) {
	if(!self.inv_misc_tinymag_pdw)
		self.inv_misc_tinymag_pdw = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/pdwtinymag.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}













void spawnfunc_item_misc_exmag_ak74_45 (void) {
	if(!self.inv_misc_exmag_ak74_45)
		self.inv_misc_exmag_ak74_45 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak74exmag45.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_ak74_30 (void) {
	if(!self.inv_misc_mag_ak74_30)
		self.inv_misc_mag_ak74_30 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/ak74mag30.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}




//
void spawnfunc_item_misc_exmag_styeraug_42 (void) {
	if(!self.inv_misc_exmag_styeraug_42)
		self.inv_misc_exmag_styeraug_42 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/styeraugexmag42.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_styeraug_30 (void) {
	if(!self.inv_misc_mag_styeraug_30)
		self.inv_misc_mag_styeraug_30 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/styeraugmag30.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


//



//
void spawnfunc_item_misc_exmag_bar_40 (void) {
	if(!self.inv_misc_exmag_bar_40)
		self.inv_misc_exmag_bar_40 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/barexmag40.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_bar_20 (void) {
	if(!self.inv_misc_mag_bar_20)
		self.inv_misc_mag_bar_20 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/barmag20.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


//


//
void spawnfunc_item_misc_panmag_lewisgun_97 (void) {
	if(!self.inv_misc_panmag_lewisgun_97)
		self.inv_misc_panmag_lewisgun_97 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lewisgunpanmag97.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_panmag_lewisgun_47 (void) {
	if(!self.inv_misc_panmag_lewisgun_47)
		self.inv_misc_panmag_lewisgun_47 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/lewisgunpanmag47.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


//


void spawnfunc_item_misc_exmag_tec9_36 (void) {
	if(!self.inv_misc_exmag_tec9_36)
		self.inv_misc_exmag_tec9_36 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9exmag36.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_exmag_tec9_50 (void) {
	if(!self.inv_misc_exmag_tec9_50)
		self.inv_misc_exmag_tec9_50 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9exmag50.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_drum_tec9_72 (void) {
	if(!self.inv_misc_drum_tec9_72)
		self.inv_misc_drum_tec9_72 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9drum72.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



void spawnfunc_item_misc_mag_tec9_32 (void) {
	if(!self.inv_misc_mag_tec9_32)
		self.inv_misc_mag_tec9_32 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9mag32.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_misc_mag_tec9_10 (void) {
	if(!self.inv_misc_mag_tec9_10)
		self.inv_misc_mag_tec9_10 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9mag10.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_misc_mag_tec9_20 (void) {
	if(!self.inv_misc_mag_tec9_20)
		self.inv_misc_mag_tec9_20 = 1;
	
	if (autocvar_g_weapon_pickup_realsize) {
		//This item _is_ artistically pre-scaled to 1.6 times.
		if (autocvar_g_weapon_pickup_realsize > 0) {
			self.scale = 0.625;
		}
		
		if (autocvar_g_weapon_pickup_realsize != 1) {
			if (autocvar_g_weapon_pickup_realsize > 0) {
				if (!self.scale) {
					self.scale = 1;
				}
				
				self.scale = self.scale * autocvar_g_weapon_pickup_realsize;
			}
		}
	}
		
	StartItem ("models/misc/extendedmags/tec9mag20.iqm", "resource/construction/con_stone_10.ogg", g_pickup_respawntime_miscitem, g_pickup_respawntimejitter_medium, "suppressor", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



//Spellbooks and scrolls

void spawnfunc_item_book_spell_agency (void) {
	if(!self.inv_book_agency)
		self.inv_book_agency = 1;
	
	self.colormap = (1024 + 14 + 14 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_agency (void) {
	if(!self.inv_scroll_agency)
		self.inv_scroll_agency = 1;
	
	self.colormap = (1024 + 14 + 14 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_death (void) {
	if(!self.inv_book_death)
		self.inv_book_death = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_death (void) {
	if(!self.inv_scroll_death)
		self.inv_scroll_death = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_extinguish (void) {
	if(!self.inv_book_extinguish)
		self.inv_book_extinguish = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_extinguish (void) {
	if(!self.inv_scroll_extinguish)
		self.inv_scroll_extinguish = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_darkritual (void) {
	if(!self.inv_book_darkritual)
		self.inv_book_darkritual = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_darkritual (void) {
	if(!self.inv_scroll_darkritual)
		self.inv_scroll_darkritual = 1;
	
	self.colormap = 1023;
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_drainlife (void) {
	if(!self.inv_book_drainlife)
		self.inv_book_drainlife = 1;
	
	self.colormap = (1024 + 9 + 9 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_drainlife (void) {
	if(!self.inv_scroll_drainlife)
		self.inv_scroll_drainlife = 1;
	
	self.colormap = (1024 + 9 + 9 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_castfromlife (void) {
	if(!self.inv_book_castfromlife)
		self.inv_book_castfromlife = 1;
	
	self.colormap = (1024 + 10 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_castfromlife (void) {
	if(!self.inv_scroll_castfromlife)
		self.inv_scroll_castfromlife = 1;
	
	self.colormap = (1024 + 10 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_vampyricconduit (void) {
	precache_model ("models/circles/magiccircle.iqm");
	
	if(!self.inv_book_vampyricconduit)
		self.inv_book_vampyricconduit = 1;
	
	self.colormap = (1024 + 10 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_vampyricconduit (void) {
	precache_model ("models/circles/magiccircle.iqm");
	
	if(!self.inv_scroll_vampyricconduit)
		self.inv_scroll_vampyricconduit = 1;
	
	self.colormap = (1024 + 10 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_confer (void) {
	if(!self.inv_book_confer)
		self.inv_book_confer = 1;
	
	self.colormap = (1024 + 12 + 12 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_confer (void) {
	if(!self.inv_scroll_confer)
		self.inv_scroll_confer = 1;
	
	self.colormap = (1024 + 12 + 12 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_iceball (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_iceball)
		self.inv_book_iceball = 1;
	
	self.colormap = (1024 + 11 + 11 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_iceball (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_iceball)
		self.inv_scroll_iceball = 1;
	
	self.colormap = (1024 + 11 + 11 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_icestar (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_icestar)
		self.inv_book_icestar = 1;
	
	self.colormap = (1024 + 11 + 11 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_icestar (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_icestar)
		self.inv_scroll_icestar = 1;
	
	self.colormap = (1024 + 11 + 11 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_firebolt (void) {
	precache_sound ("weapons/fireball_fire.wav");
	if(!self.inv_book_firebolt)
		self.inv_book_firebolt = 1;
	
	self.colormap = (1024 + 1 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_firebolt (void) {
	precache_sound ("weapons/fireball_fire.wav");
	if(!self.inv_scroll_firebolt)
		self.inv_scroll_firebolt = 1;
	
	self.colormap = (1024 + 1 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_fireball (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_fireball)
		self.inv_book_fireball = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_fireball (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_fireball)
		self.inv_scroll_fireball = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_magmasphere (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_sound ("ardentryst/flame_whoosh.ogg");
	precache_model ("models/sphere/cannonball.iqm");
	if(!self.inv_book_magmasphere)
		self.inv_book_magmasphere = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_magmasphere (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_sound ("ardentryst/flame_whoosh.ogg");
	precache_model ("models/sphere/cannonball.iqm");
	if(!self.inv_scroll_magmasphere)
		self.inv_scroll_magmasphere = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_firebeam (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_sound ("ardentryst/flame_whoosh.ogg");
	if(!self.inv_book_firebeam)
		self.inv_book_firebeam = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_firebeam (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_sound ("ardentryst/flame_whoosh.ogg");
	if(!self.inv_scroll_firebeam)
		self.inv_scroll_firebeam = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_inferno (void) {
	precache_sound ("ardentryst/flame_whoosh.ogg");
	if(!self.inv_book_inferno)
		self.inv_book_inferno = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_inferno (void) {
	precache_sound ("ardentryst/flame_whoosh.ogg");
	if(!self.inv_scroll_inferno)
		self.inv_scroll_inferno = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_firewall (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	if(!self.inv_book_firewall)
		self.inv_book_firewall = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_firewall (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	if(!self.inv_scroll_firewall)
		self.inv_scroll_firewall = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_scepterofflame (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	precache_model ("models/misc/cylinderexpfire.iqm");
	if(!self.inv_book_scepterofflame)
		self.inv_book_scepterofflame = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_scepterofflame (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	precache_model ("models/misc/cylinderexpfire.iqm");
	if(!self.inv_scroll_scepterofflame)
		self.inv_scroll_scepterofflame = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_explosion (void) {
	//precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphexp2.iqm");
	if(!self.inv_book_explosion)
		self.inv_book_explosion = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_explosion (void) {
	//precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphexp2.iqm");
	if(!self.inv_scroll_explosion)
		self.inv_scroll_explosion = 1;
	
	self.colormap = (1024 + 4 + 12 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_phantasmalbarrier (void) {
	if(!self.inv_book_phantasmalbarrier)
		self.inv_book_phantasmalbarrier = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_phantasmalbarrier (void) {
	if(!self.inv_scroll_phantasmalbarrier)
		self.inv_scroll_phantasmalbarrier = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_timesink (void) {
	if(!self.inv_book_timesink)
		self.inv_book_timesink = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_timesink (void) {
	if(!self.inv_scroll_timesink)
		self.inv_scroll_timesink = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_raiseundead (void) {
	raiseundeadmarkerenabled = 1; //So we will place death markers if not allready doing so
		
	if(!self.inv_book_raiseundead)
		self.inv_book_raiseundead = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_raiseundead (void) {
	raiseundeadmarkerenabled = 1; //So we will place death markers if not allready doing so

	if(!self.inv_scroll_raiseundead)
		self.inv_scroll_raiseundead = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_ringoffire (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	if(!self.inv_book_ringoffire)
		self.inv_book_ringoffire = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_ringoffire (void) {
	precache_sound ("misc/ignition_firewall.ogg");
	if(!self.inv_scroll_ringoffire)
		self.inv_scroll_ringoffire = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_flameburst (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_flameburst)
		self.inv_book_flameburst = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_flameburst (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_flameburst)
		self.inv_scroll_flameburst = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_firecentury (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_firecentury)
		self.inv_book_firecentury = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_firecentury (void) {
	precache_sound ("weapons/fireball_fire2.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_firecentury)
		self.inv_scroll_firecentury = 1;
	
	self.colormap = (1024 + 4 + 1 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_frostbeam (void) {
	if(!self.inv_book_frostbeam)
		self.inv_book_frostbeam = 1;
	
	self.colormap = (1024 + 6 + 6 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_frostbeam (void) {
	if(!self.inv_scroll_frostbeam)
		self.inv_scroll_frostbeam = 1;
	
	self.colormap = (1024 + 6 + 6 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_grace (void) {
	precache_sound ("ardentryst/Obelisk.ogg");
	precache_sound ("ardentryst/Maea.ogg");
	precache_model ("models/circles/magiccircle.iqm");
	if(!self.inv_book_grace)
		self.inv_book_grace = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_grace (void) {
	precache_sound ("ardentryst/Obelisk.ogg");
	precache_sound ("ardentryst/Maea.ogg");
	precache_model ("models/circles/magiccircle.iqm");
	if(!self.inv_scroll_grace)
		self.inv_scroll_grace = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_holybolt (void) {
	precache_sound ("weather/thunder_crack.wav");
	precache_sound ("onslaught/shockwave.ogg");
	
	if(!self.inv_book_holybolt)
		self.inv_book_holybolt = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_holybolt (void) {
	precache_sound ("weather/thunder_crack.wav");
	precache_sound ("onslaught/shockwave.ogg");

	if(!self.inv_scroll_holybolt)
		self.inv_scroll_holybolt = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_holylight (void) {

	if(!self.inv_book_holylight)
		self.inv_book_holylight = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_holylight (void) {

	if(!self.inv_scroll_holylight)
		self.inv_scroll_holylight = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_acervilux (void) {
	//precache_sound ("weather/thunder_crack.wav");
	//precache_sound ("onslaught/shockwave.ogg");
	
	if(!self.inv_book_acervilux)
		self.inv_book_acervilux = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_acervilux (void) {
	//precache_sound ("weather/thunder_crack.wav");
	//precache_sound ("onslaught/shockwave.ogg");

	if(!self.inv_scroll_acervilux)
		self.inv_scroll_acervilux = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}




void spawnfunc_item_book_spell_aquacaelestis (void) {

	if(!self.inv_book_aquacaelestis)
		self.inv_book_aquacaelestis = 1;
	
	self.colormap = (1024 + 11 + 11 * 16); //Blue
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_aquacaelestis (void) {

	if(!self.inv_scroll_aquacaelestis)
		self.inv_scroll_aquacaelestis = 1;
	
	self.colormap = (1024 + 11 + 11 * 16); //Blue
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_nivosus (void) {

	if(!self.inv_book_nivosus)
		self.inv_book_nivosus = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_nivosus (void) {

	if(!self.inv_scroll_nivosus)
		self.inv_scroll_nivosus = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}




void spawnfunc_item_book_spell_rosa (void) {

	if(!self.inv_book_rosa)
		self.inv_book_rosa = 1;
	
	self.colormap = (1024 + 4 + 9 * 16); //Red plus a magenta
	
	if(!self.smell_roses)
		self.smell_roses = 0.30;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_rosa (void) {

	if(!self.inv_scroll_rosa)
		self.inv_scroll_rosa = 1;
	
	self.colormap = (1024 + 4 + 9 * 16); //Red plus a magenta
	
	if(!self.smell_roses)
		self.smell_roses = 0.15;
	
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



void spawnfunc_item_book_spell_corvuspenna (void) {
	precache_model ("models/feathers/feathersmall.iqm");
	if(!self.inv_book_corvuspenna)
		self.inv_book_corvuspenna = 1;
	
	self.colormap = 1023; //Hack for black;
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_corvuspenna (void) {
	precache_model ("models/feathers/feathersmall.iqm");
	if(!self.inv_scroll_corvuspenna)
		self.inv_scroll_corvuspenna = 1;
	
	self.colormap = 1023; //Hack for black
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



void spawnfunc_item_book_spell_plumosus (void) {
	precache_model ("models/feathers/feathersmall.iqm");
	if(!self.inv_book_plumosus)
		self.inv_book_plumosus = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_plumosus (void) {
	precache_model ("models/feathers/feathersmall.iqm");
	if(!self.inv_scroll_plumosus)
		self.inv_scroll_plumosus = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}




void spawnfunc_item_book_spell_heal (void) {
	if(!self.inv_book_heal)
		self.inv_book_heal = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_heal (void) {
	if(!self.inv_scroll_heal)
		self.inv_scroll_heal = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_holyword (void) {
	precache_sound ("weather/thunder_crack.wav");
	precache_sound ("onslaught/shockwave.ogg");
	
	if(!self.inv_book_holyword)
		self.inv_book_holyword = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_holyword (void) {
	precache_sound ("weather/thunder_crack.wav");
	precache_sound ("onslaught/shockwave.ogg");

	if(!self.inv_scroll_holyword)
		self.inv_scroll_holyword = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_lightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_lightining)
		self.inv_book_lightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_lightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_scroll_lightining)
		self.inv_scroll_lightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_balllightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_balllightining)
		self.inv_book_balllightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_balllightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_scroll_balllightining)
		self.inv_scroll_balllightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_chainlightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_chainlightining)
		self.inv_book_chainlightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_chainlightining (void) {
	precache_sound ("weapons/lgbeam_fire.wav");

	if(!self.inv_scroll_chainlightining)
		self.inv_scroll_chainlightining = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_lightiningburst (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_lightiningburst)
		self.inv_book_lightiningburst = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_lightiningburst (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_scroll_lightiningburst)
		self.inv_scroll_lightiningburst = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_chargedbolt (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_chargedbolt)
		self.inv_book_chargedbolt = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_chargedbolt (void) {
	precache_sound ("weapons/lgbeam_fire.wav");

	if(!self.inv_scroll_chargedbolt)
		self.inv_scroll_chargedbolt = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}


void spawnfunc_item_book_spell_lightiningwall (void) {
	precache_sound ("weapons/lgbeam_fire.wav");
	
	if(!self.inv_book_lightiningwall)
		self.inv_book_lightiningwall = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_lightiningwall (void) {
	precache_sound ("weapons/lgbeam_fire.wav");

	if(!self.inv_scroll_lightiningwall)
		self.inv_scroll_lightiningwall = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_lightiningstrike (void) {
	precache_sound ("weather/thunder_crack.wav");
	
	if(!self.inv_book_lightiningstrike)
		self.inv_book_lightiningstrike = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_lightiningstrike (void) {
	precache_sound ("weather/thunder_crack.wav");
	
	if(!self.inv_scroll_lightiningstrike)
		self.inv_scroll_lightiningstrike = 1;
	
	self.colormap = (1024 + 0 + 5 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_monstertomonolith (void) {
	if(!self.inv_book_monstertomonolith)
		self.inv_book_monstertomonolith = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_monstertomonolith (void) {
	if(!self.inv_scroll_monstertomonolith)
		self.inv_scroll_monstertomonolith = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_monstertomouse (void) {
	if(!self.inv_book_monstertomouse)
		self.inv_book_monstertomouse = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_monstertomouse (void) {
	if(!self.inv_scroll_monstertomouse)
		self.inv_scroll_monstertomouse = 1;
	
	self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_magicbullets (void) {
	if(!self.inv_book_magicbullets)
		self.inv_book_magicbullets = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_magicbullets (void) {
	if(!self.inv_scroll_magicbullets)
		self.inv_scroll_magicbullets = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_magicmissile (void) {
	if(!self.inv_book_magicmissile)
		self.inv_book_magicmissile = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_magicmissile (void) {
	if(!self.inv_scroll_magicmissile)
		self.inv_scroll_magicmissile = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_repair (void) {
	if(!self.inv_book_repair)
		self.inv_book_repair = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_repair (void) {
	if(!self.inv_scroll_repair)
		self.inv_scroll_repair = 1;
	
	self.colormap = (1024 + 8 + 8 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_meteor (void) {
	precache_sound ("weapons/fireball_fire.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_meteor)
		self.inv_book_meteor = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_meteor (void) {
	precache_sound ("weapons/fireball_fire.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_meteor)
		self.inv_scroll_meteor = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_meteorshower (void) {
	precache_sound ("weapons/fireball_fire.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_book_meteorshower)
		self.inv_book_meteorshower = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_meteorshower (void) {
	precache_sound ("weapons/fireball_fire.wav");
	precache_model ("models/sphere/sphere.md3");
	if(!self.inv_scroll_meteorshower)
		self.inv_scroll_meteorshower = 1;
	
	self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_stonerain (void) {
	precache_sound ("resource/impact/slingimpstone_21.ogg"); //For StoneRain
	precache_sound ("resource/impact/slingimpstone_22.ogg");
	precache_sound ("resource/impact/slingimpstone_23.ogg");
	precache_sound ("resource/impact/slingimpstone_24.ogg");
	precache_sound ("resource/impact/slingimpstone_25.ogg");
	precache_sound ("resource/impact/slingimpstone_26.ogg");
				
	if(!self.inv_book_stonerain)
		self.inv_book_stonerain = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_stonerain (void) {
	precache_sound ("resource/impact/slingimpstone_21.ogg"); //For StoneRain
	precache_sound ("resource/impact/slingimpstone_22.ogg");
	precache_sound ("resource/impact/slingimpstone_23.ogg");
	precache_sound ("resource/impact/slingimpstone_24.ogg");
	precache_sound ("resource/impact/slingimpstone_25.ogg");
	precache_sound ("resource/impact/slingimpstone_26.ogg");
	
	if(!self.inv_scroll_stonerain)
		self.inv_scroll_stonerain = 1;
	
	//self.colormap = (1024 + 4 + 4 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_cancellation (void) {
	precache_sound ("porto/expire.ogg");

	if(!self.inv_book_cancellation)
		self.inv_book_cancellation = 1;
	
	self.colormap = 1023; //Hack for back
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_cancellation (void) {
	precache_sound ("porto/expire.ogg");

	if(!self.inv_scroll_cancellation)
		self.inv_scroll_cancellation = 1;
	
	self.colormap = 1023; //Hack for black
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_manashield (void) {
	precache_sound ("relics/relic_effect.wav");
	
	if(!self.inv_book_manashield)
		self.inv_book_manashield = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_manashield (void) {
	precache_sound ("relics/relic_effect.wav");
	
	if(!self.inv_scroll_manashield)
		self.inv_scroll_manashield = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_clairvoyance (void) {
	//precache_sound ("relics/relic_effect.wav");
	
	if(!self.inv_book_clairvoyance)
		self.inv_book_clairvoyance = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_clairvoyance (void) {
	//precache_sound ("relics/relic_effect.wav");
	
	if(!self.inv_scroll_clairvoyance)
		self.inv_scroll_clairvoyance = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_mimic (void) {
	if(!self.inv_book_mimic)
		self.inv_book_mimic = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_mimic (void) {
	if(!self.inv_scroll_mimic)
		self.inv_scroll_mimic = 1;
	
	self.colormap = (1024 + 10 + 10 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_paralyse (void) {
	if(!self.inv_book_paralyse)
		self.inv_book_paralyse = 1;
	
	self.colormap = (1024 + 3 + 3 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_paralyse (void) {
	if(!self.inv_scroll_paralyse)
		self.inv_scroll_paralyse = 1;
	
	self.colormap = (1024 + 3 + 3 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_spell_stonecurse (void) {
	if(!self.inv_book_stonecurse)
		self.inv_book_stonecurse = 1;
	
	//self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}
void spawnfunc_item_scroll_spell_stonecurse (void) {
	if(!self.inv_scroll_stonecurse)
		self.inv_scroll_stonecurse = 1;
	
	//self.colormap = (1024 + 0 + 0 * 16);
	StartItem ("models/items/scroll.iqm", "resource/foraging/leaves_15.ogg", g_pickup_respawntime_scroll, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

//Knowlege books //Maybe use other models at somepoint?
void spawnfunc_item_book_know_carpentry (void) {	
	if(!self.inv_book_know_carpentry)
		self.inv_book_know_carpentry = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_mortise (void) {	
	if(!self.inv_book_know_mortise)
		self.inv_book_know_mortise = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_stonemasonry (void) {	
	if(!self.inv_book_know_stonemasonry)
		self.inv_book_know_stonemasonry = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_ironworking (void) {	
	if(!self.inv_book_know_ironworking)
		self.inv_book_know_ironworking = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_arch (void) {	
	if(!self.inv_book_know_arch)
		self.inv_book_know_arch = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_welding (void) {	
	if(!self.inv_book_know_welding)
		self.inv_book_know_welding = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}

void spawnfunc_item_book_know_concrete (void) {	
	if(!self.inv_book_know_concrete)
		self.inv_book_know_concrete = 1;
	
	StartItem ("models/items/oldbook.iqm", "resource/construction/con_saw_11.ogg", g_pickup_respawntime_spellbook, g_pickup_respawntimejitter_medium, "Paper", IT_MISCITEM, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_MID);
}



//For dropping ammo
void M_Item_Touch ();
void SpawnLiveCartridge_Offset(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, vector mycasingoffset, float ammocost)
{
	entity e;
	entity oldself;
	vector org;

	org = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
	org = org + (mycasingoffset_x * v_forward) - (mycasingoffset_y * v_right) + (mycasingoffset_z * v_up); //Do it the Same way
	
	//if(!sound_allowed(MSG_BROADCAST, casingowner))
	//	casingtype |= 0x80;

	e = spawn();
	//e.state = casingtype;
	setorigin(e, org);
	e.velocity = vel;
	e.angles = ang;

	oldself = self;
	self = e;
	
	//self.ItemStatus |= ITS_ANIMATE1;
	
	self.respawntime = g_pickup_respawntime_ammo;
	self.respawntimejitter = g_pickup_respawntimejitter_ammo;
		
	self.inventory_nopickuptill = time + 2;
	self.inventory_nopickupbytill = casingowner;
	
	self.ammo_nails = ammocost;
	
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	
		//Similar to client/casings.qc
		switch(casingtype)
		{
			case 1:
				self.ammo_nails = 0;
				self.ammo_shells = ammocost;
				self.model = "models/casing_shell.mdl";
				break;
			case 3:
				//30 cal
				self.model = "models/casing_bronze.iqm";
				self.scale = 0.66666;
				break;
			case 5:
				//9 mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 0.77;
				break;
			case 6:
				//.45 cal
				self.model = "models/casing_bronze.iqm";
				self.scale = 1;
				break;
			case 7:
				//.50 cal
				self.model = "models/casing_bronze.iqm";
				self.scale = 1.11;
				break;
			case 8:
				//17mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 1.46;
				break;
			case 9:
				//20mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 1.72;
				break;
			case 10:
				//30mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 2.58;
				break;
			case 11:
				//40mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 3.44;
				break;
			case 12:
				//55mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 4.72;
				break;
			case 13:
				//100mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 8.60;
				break;
			case 14:
				//125mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 10.75;
				break;
			case 15:
				//Placeholder
				self.model = "models/casing_bronze.iqm";
				self.scale = 13.50;
				break;
			case 16:
				//Placehilder
				self.model = "models/casing_bronze.iqm";
				self.scale = 17;
				break;
			case 17:
				//250mm
				self.model = "models/casing_bronze.iqm";
				self.scale = 21.5;
				break;
			case 25:
				//9 mm Long case
				self.model = "models/casing_long.iqm";
				self.scale = 0.77;
				break;
			case 26:
				//.45 cal Long case
				self.model = "models/casing_long.iqm";
				self.scale = 1;
				break;
			case 27:
				//.50 cal Long case
				self.model = "models/casing_long.iqm";
				self.scale = 1.11;
				break;
			case 29:
				//17mm Long case
				self.model = "models/items/casinglongriflebullet.iqm";
				self.scale = 1.46;
				break;
			case 30:
				//20mm
				self.model = "models/casing_long.iqm";
				self.scale = 1.72;
				break;
			case 31:
				//30mm
				self.model = "models/casing_long.iqm";
				self.scale = 2.58;
				break;
			case 32:
				//Old lead ball straight case
				self.model = "models/casing_steel.mdl";
				self.scale = 1;
				break;
			case 33:
				//RPG7 backstop
				self.model = "models/rpg7casing.iqm";
				self.scale = 1;
				break;
			case 34:
				//Casinglink  .25 cal
				self.model = "models/casinglink.iqm";
				self.scale = 0.555;
				break;
			case 35:
				//Casinglink  9mm
				self.model = "models/casinglink.iqm";
				self.scale = 0.77;
				break;
			case 36:
				//Casinglink .45 cal
				self.model = "models/casinglink.iqm";
				self.scale = 1;
				break;
			case 37:
				//Casinglink  .50 cal
				self.model = "models/casinglink.iqm";
				self.scale = 1.11;
				break;
			case 38:
				//Casinglink  17mm
				self.model = "models/casinglink.iqm";
				self.scale = 1.46;
				break;
			case 39:
				//Casinglink  20mm
				self.model = "models/casinglink.iqm";
				self.scale = 1.72;
				break;
			case 40:
				//Casinglink  30mm
				self.model = "models/casinglink.iqm";
				self.scale = 2.58;
				break;
			case 45:
				//9 mm AE style pistol round, in between long and normal
				self.model = "models/casing_ae.iqm";
				self.scale = 0.77;
				break;
			case 46:
				//.45 cal AE style pistol round, in between long and normal
				self.model = "models/casing_ae.iqm";
				self.scale = 1;
				break;
			case 47:
				//.50 cal AE style pistol round, in between long and normal
				self.model = "models/casing_ae.iqm";
				self.scale = 1.11;
				break;
			case 55:
				//Nagant casing
				self.model = "models/casing_nagant.iqm";
				self.scale = 0.77;
				break;
			case 56:
				//Old lead ball straight case scaled for .36
				self.model = "models/casing_steel.mdl";
				self.scale = 0.8;
				break;
			case 57:
				//Old lead ball straight case scaled for .69
				self.model = "models/casing_steel.mdl";
				self.scale = 1.533333;
				break;
			case 58:
				//Old lead ball straight case scaled for .50
				self.model = "models/casing_steel.mdl";
				self.scale = 1.11;
				break;
			case 59:
				//8 gauge shotgun
				self.ammo_nails = 0;
				self.ammo_shells = ammocost;
				self.model = "models/casing_shell.mdl";
				self.scale = 1.145;
				break;
			case 60:
				//10 gauge shotgun
				self.ammo_nails = 0;
				self.ammo_shells = ammocost;
				self.model = "models/casing_shell.mdl";
				self.scale = 1.064;
				break;
			case 61:
				//Necked-down pistol ammunition
				//Five-Seven ammunition (P-90)
				//(which is .22 cal)
				self.model = "models/casing_nkdnpstl.iqm";
				self.scale = 0.488;
				break;
			case 62:
				//Tokarev (7.62×25mm necked-down pistol ammunition)
				self.model = "models/casing_tokarev.iqm";
				self.scale = 0.67;
				break;
			case 63:
				//8 mm lebel
				self.model = "models/casing_lebel.iqm";
				self.scale = 0.757; //neck diameter 8.85mm 
				break;
			case 99:
				//9 mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 0.77;
				break;
			case 103:
				//.22 cal
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 0.488;
				break;
			case 104:
				//Placeholder .25 cal
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 0.555;
				break;
			case 105:
				//.30 cal
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 0.66;
				break;
			case 106:
				//.45 cal
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 1;
				break;
			case 107:
				//.50 cal
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 1.11;
				break;
			case 108:
				//17mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 1.46;
				break;
			case 109:
				//20mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 1.72;
				break;
			case 110:
				//30mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 2.58;
				break;
			case 111:
				//40mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 3.44;
				break;
			case 112:
				//55mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 4.72;
				break;
			case 113:
				//100mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 8.60;
				break;
			case 114:
				//125mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 10.75;
				break;
			case 115:
				//Placeholder
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 13.50;
				break;
			case 116:
				//Placehilder
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 17;
				break;
			case 117:
				//250mm
				self.model = "models/items/casingriflebullet.iqm";
				self.scale = 21.5;
				break;
			//RUSSIAN
			case 123:
				//.22 cal  AK74 
				self.model = "models/items/casingriflerusshortbullet.iqm";
				self.scale = 0.488;
				break;
			case 124:
				//7.62mm (30 cal) short  AK47
				self.model = "models/items/casingriflerusshortbullet.iqm";
				self.scale = 0.66;
				break;
			case 125:
				//7.62mm (30 cal)   SVD, PKM, Mosin
				self.model = "models/items/casingriflerusbullet.iqm";
				self.scale = 0.66;
				break;
			default:
				//.45 representation of
				self.model = "models/casing_bronze.iqm";
				break;
		}
		
	self.item_pickupsound = "misc/itempickup.wav";
	
	precache_model (self.model);
	precache_sound (self.item_pickupsound);
	
	self.movetype = MOVETYPE_TOSS;
	self.solid = SOLID_TRIGGER;

	self.bot_pickup = TRUE;
	self.bot_pickupevalfunc = commodity_pickupevalfunc;
	self.bot_pickupbasevalue = BOT_PICKUP_RATING_LOW;
	self.mdl = self.model;
	self.netname = "bullets";
	self.items = IT_NAILS;
	self.flags = FL_ITEM;
	self.spawnshieldtime = 1;
	self.ItemStatus |= ITS_AVAILABLE;
	
	self.pos1 = '-1 -1 0';
        self.pos2 = '1 1 4';
	
	self.gravity = 1;
	
	self.state = 0;
	
	self.touch = M_Item_Touch;
	
	if (autocvar_g_pickup_permitems)
		SUB_ItemServerSideSetToPermWhen(self, time + 20);
	else 
		SUB_SetFade(self, time + 20, 1);
		

	setmodel(self, self.model);
	setsize (self, self.pos1, self.pos2);
	
	
	self = oldself;
}




//Random, non-biased, Scroll pick
void weapon_scrollreplacement(void)
{
	local float myrandvar;
	local float myscrolls;
	myrandvar = random();
	myscrolls = 57;
	if (myrandvar > ((1/myscrolls)*(myscrolls-1)))
		spawnfunc_item_scroll_spell_agency();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-2)))
		spawnfunc_item_scroll_spell_death();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-3)))	
		spawnfunc_item_scroll_spell_drainlife();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-4)))
		spawnfunc_item_scroll_spell_confer();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-5)))
		spawnfunc_item_scroll_spell_iceball();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-6)))
		spawnfunc_item_scroll_spell_icestar();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-7)))
		spawnfunc_item_scroll_spell_firebolt();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-8)))
		spawnfunc_item_scroll_spell_fireball();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-9)))
		spawnfunc_item_scroll_spell_firebeam();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-10)))
		spawnfunc_item_scroll_spell_flameburst();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-11)))
		spawnfunc_item_scroll_spell_frostbeam();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-12)))
		spawnfunc_item_scroll_spell_holybolt();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-13)))
		spawnfunc_item_scroll_spell_lightining();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-14)))
		spawnfunc_item_scroll_spell_monstertomonolith();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-15)))
		spawnfunc_item_scroll_spell_monstertomouse();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-16)))
		spawnfunc_item_scroll_spell_magicmissile();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-17)))
		spawnfunc_item_scroll_spell_meteor();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-18)))
		spawnfunc_item_scroll_spell_meteorshower();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-19)))
		spawnfunc_item_scroll_spell_mimic();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-20)))
		spawnfunc_item_scroll_spell_paralyse();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-21)))
		spawnfunc_item_scroll_spell_firewall();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-22)))
		spawnfunc_item_scroll_spell_ringoffire();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-23)))
		spawnfunc_item_scroll_spell_lightiningstrike();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-24)))
		spawnfunc_item_scroll_spell_holyword();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-25)))
		spawnfunc_item_scroll_spell_stonerain();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-26)))
		spawnfunc_item_scroll_spell_manashield();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-27)))
		spawnfunc_item_scroll_spell_cancellation();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-28)))
		spawnfunc_item_scroll_spell_magicbullets();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-29)))
		spawnfunc_item_scroll_spell_castfromlife();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-30)))
		spawnfunc_item_scroll_spell_phantasmalbarrier();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-31)))
		spawnfunc_item_scroll_spell_raiseundead();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-32)))
		spawnfunc_item_scroll_spell_scepterofflame();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-33)))
		spawnfunc_item_scroll_spell_explosion();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-34)))
		spawnfunc_item_scroll_spell_timesink();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-35)))
		spawnfunc_item_scroll_spell_grace();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-36)))
		spawnfunc_item_scroll_spell_vampyricconduit();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-37)))
		spawnfunc_item_scroll_spell_extinguish();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-38)))
		spawnfunc_item_scroll_spell_darkritual();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-39)))
		spawnfunc_item_scroll_spell_clairvoyance();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-40)))
		spawnfunc_item_scroll_spell_heal();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-41)))
		spawnfunc_item_scroll_spell_repair();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-42)))
		spawnfunc_item_scroll_spell_inferno();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-43)))
		spawnfunc_item_scroll_spell_acervilux();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-44)))
		spawnfunc_item_scroll_spell_chainlightining();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-45)))
		spawnfunc_item_scroll_spell_balllightining();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-46)))
		spawnfunc_item_scroll_spell_lightiningburst();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-47)))
		spawnfunc_item_scroll_spell_chargedbolt();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-48)))
		spawnfunc_item_scroll_spell_lightiningwall();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-49)))
		spawnfunc_item_scroll_spell_holylight();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-50)))
		spawnfunc_item_scroll_spell_aquacaelestis();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-51)))
		spawnfunc_item_scroll_spell_nivosus();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-52)))
		spawnfunc_item_scroll_spell_rosa();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-53)))
		spawnfunc_item_scroll_spell_corvuspenna();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-54)))
		spawnfunc_item_scroll_spell_plumosus();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-55)))
		spawnfunc_item_scroll_spell_magmasphere();
	else if (myrandvar > ((1/myscrolls)*(myscrolls-56)))
		spawnfunc_item_scroll_spell_firecentury();
	else
		spawnfunc_item_scroll_spell_stonecurse();
}

//Biased scroll picking (also have a few skill books, usually set to 0, make sure to put new spell scrolls _under_ them in the list (just keep adding)
void weapon_scrollorspellbookreplacement_biased(float insteadspawnbook)
{
	//Any new scrolls add to the end.
	//Do not add in the middle or alphabetically
	//past what has allready been done initially
	//Add to the end, that's how this code works
	local float brandvar;
	///////////////////Start////////////////////////
	brandvar = random() *
	(autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	+ autocvar_g_replace_weapon_pickups_scroll_corvuspenna
	+ autocvar_g_replace_weapon_pickups_scroll_plumosus
	+ autocvar_g_replace_weapon_pickups_scroll_magmasphere
	+ autocvar_g_replace_weapon_pickups_scroll_firecentury
	);
	
	if (brandvar < autocvar_g_replace_weapon_pickups_scroll_agency) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_agency();
		else
			spawnfunc_item_scroll_spell_agency();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_death();
		else
			spawnfunc_item_scroll_spell_death();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_drainlife();
		else
			spawnfunc_item_scroll_spell_drainlife();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_confer();
		else
			spawnfunc_item_scroll_spell_confer();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_iceball();
		else
			spawnfunc_item_scroll_spell_iceball();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_icestar();
		else
			spawnfunc_item_scroll_spell_icestar();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_firebolt();
		else
			spawnfunc_item_scroll_spell_firebolt();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_fireball();
		else
			spawnfunc_item_scroll_spell_fireball();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_firebeam();
		else
			spawnfunc_item_scroll_spell_firebeam();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_flameburst();
		else
			spawnfunc_item_scroll_spell_flameburst();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_frostbeam();
		else
			spawnfunc_item_scroll_spell_frostbeam();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_holybolt();
		else
			spawnfunc_item_scroll_spell_holybolt();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_lightining();
		else
			spawnfunc_item_scroll_spell_lightining();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_monstertomonolith();
		else
			spawnfunc_item_scroll_spell_monstertomonolith();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	)) {	
		if (insteadspawnbook)
			spawnfunc_item_book_spell_monstertomouse();
		else
			spawnfunc_item_scroll_spell_monstertomouse();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_magicmissile();
		else
			spawnfunc_item_scroll_spell_magicmissile();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_meteor();
		else
			spawnfunc_item_scroll_spell_meteor();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_meteorshower();
		else
			spawnfunc_item_scroll_spell_meteorshower();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_mimic();
		else
			spawnfunc_item_scroll_spell_mimic();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_paralyse();
		else
			spawnfunc_item_scroll_spell_paralyse();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_stonecurse();
		else
			spawnfunc_item_scroll_spell_stonecurse();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_firewall();
		else
			spawnfunc_item_scroll_spell_firewall();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_ringoffire();
		else
			spawnfunc_item_scroll_spell_ringoffire();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_lightiningstrike();
		else
			spawnfunc_item_scroll_spell_lightiningstrike();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_holyword();
		else
			spawnfunc_item_scroll_spell_holyword();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_stonerain();
		else
			spawnfunc_item_scroll_spell_stonerain();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_manashield();
		else
			spawnfunc_item_scroll_spell_manashield();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_cancellation();
		else
			spawnfunc_item_scroll_spell_cancellation();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_magicbullets();
		else
			spawnfunc_item_scroll_spell_magicbullets();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	//+ place new spell scrolls here, continue the pattern from here, don't group them, just keep adding them
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_castfromlife();
		else
			spawnfunc_item_scroll_spell_castfromlife();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_phantasmalbarrier();
		else
			spawnfunc_item_scroll_spell_phantasmalbarrier();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_raiseundead();
		else
			spawnfunc_item_scroll_spell_raiseundead();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_scepterofflame();
		else
			spawnfunc_item_scroll_spell_scepterofflame();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_explosion();
		else
			spawnfunc_item_scroll_spell_explosion();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	)) {
		spawnfunc_item_book_know_carpentry();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	)) {
		spawnfunc_item_book_know_mortise();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	)) {
		spawnfunc_item_book_know_stonemasonry();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	)) {
		spawnfunc_item_book_know_ironworking();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	)) {
		spawnfunc_item_book_know_arch();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	)) {
		spawnfunc_item_book_know_welding();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	)) {
		spawnfunc_item_book_know_concrete();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_timesink();
		else
			spawnfunc_item_scroll_spell_timesink();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_grace();
		else
			spawnfunc_item_scroll_spell_grace();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_vampyricconduit();
		else
			spawnfunc_item_scroll_spell_vampyricconduit();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_extinguish();
		else
			spawnfunc_item_scroll_spell_extinguish();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_darkritual();
		else
			spawnfunc_item_scroll_spell_darkritual();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_clairvoyance();
		else
			spawnfunc_item_scroll_spell_clairvoyance();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_heal();
		else
			spawnfunc_item_scroll_spell_heal();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_repair();
		else
			spawnfunc_item_scroll_spell_repair();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_inferno();
		else
			spawnfunc_item_scroll_spell_inferno();	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_acervilux();
		else
			spawnfunc_item_scroll_spell_acervilux();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_chainlightining();
		else
			spawnfunc_item_scroll_spell_chainlightining();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_balllightining();
		else
			spawnfunc_item_scroll_spell_balllightining();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_lightiningburst();
		else
			spawnfunc_item_scroll_spell_lightiningburst();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_chargedbolt();
		else
			spawnfunc_item_scroll_spell_chargedbolt();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_lightiningwall();
		else
			spawnfunc_item_scroll_spell_lightiningwall();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_holylight();
		else
			spawnfunc_item_scroll_spell_holylight();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_aquacaelestis();
		else
			spawnfunc_item_scroll_spell_aquacaelestis();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_nivosus();
		else
			spawnfunc_item_scroll_spell_nivosus();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_rosa();
		else
			spawnfunc_item_scroll_spell_rosa();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	+ autocvar_g_replace_weapon_pickups_scroll_corvuspenna
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_corvuspenna();
		else
			spawnfunc_item_scroll_spell_corvuspenna();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	+ autocvar_g_replace_weapon_pickups_scroll_corvuspenna
	+ autocvar_g_replace_weapon_pickups_scroll_plumosus
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_plumosus();
		else
			spawnfunc_item_scroll_spell_plumosus();
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	+ autocvar_g_replace_weapon_pickups_scroll_corvuspenna
	+ autocvar_g_replace_weapon_pickups_scroll_plumosus
	+ autocvar_g_replace_weapon_pickups_scroll_magmasphere
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_magmasphere();
		else
			spawnfunc_item_scroll_spell_magmasphere();
	
	} else if (brandvar < (
	autocvar_g_replace_weapon_pickups_scroll_agency
	+ autocvar_g_replace_weapon_pickups_scroll_death
	+ autocvar_g_replace_weapon_pickups_scroll_drainlife
	+ autocvar_g_replace_weapon_pickups_scroll_confer
	+ autocvar_g_replace_weapon_pickups_scroll_iceball
	+ autocvar_g_replace_weapon_pickups_scroll_icestar
	+ autocvar_g_replace_weapon_pickups_scroll_firebolt
	+ autocvar_g_replace_weapon_pickups_scroll_fireball
	+ autocvar_g_replace_weapon_pickups_scroll_firebeam
	+ autocvar_g_replace_weapon_pickups_scroll_flameburst
	+ autocvar_g_replace_weapon_pickups_scroll_frostbeam
	+ autocvar_g_replace_weapon_pickups_scroll_holybolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightining
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomonolith
	+ autocvar_g_replace_weapon_pickups_scroll_monstertomouse
	+ autocvar_g_replace_weapon_pickups_scroll_magicmissile
	+ autocvar_g_replace_weapon_pickups_scroll_meteor
	+ autocvar_g_replace_weapon_pickups_scroll_meteorshower
	+ autocvar_g_replace_weapon_pickups_scroll_mimic
	+ autocvar_g_replace_weapon_pickups_scroll_paralyse
	+ autocvar_g_replace_weapon_pickups_scroll_stonecurse
	+ autocvar_g_replace_weapon_pickups_scroll_firewall
	+ autocvar_g_replace_weapon_pickups_scroll_ringoffire
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningstrike
	+ autocvar_g_replace_weapon_pickups_scroll_holyword
	+ autocvar_g_replace_weapon_pickups_scroll_stonerain
	+ autocvar_g_replace_weapon_pickups_scroll_manashield
	+ autocvar_g_replace_weapon_pickups_scroll_cancellation
	+ autocvar_g_replace_weapon_pickups_scroll_magicbullets
	+ autocvar_g_replace_weapon_pickups_scroll_castfromlife
	+ autocvar_g_replace_weapon_pickups_scroll_phantasmalbarrier
	+ autocvar_g_replace_weapon_pickups_scroll_raiseundead
	+ autocvar_g_replace_weapon_pickups_scroll_scepterofflame
	+ autocvar_g_replace_weapon_pickups_scroll_explosion
	+ autocvar_g_replace_weapon_pickups_book_know_carpentry
	+ autocvar_g_replace_weapon_pickups_book_know_mortise
	+ autocvar_g_replace_weapon_pickups_book_know_stonemasonry
	+ autocvar_g_replace_weapon_pickups_book_know_ironworking
	+ autocvar_g_replace_weapon_pickups_book_know_arch
	+ autocvar_g_replace_weapon_pickups_book_know_welding
	+ autocvar_g_replace_weapon_pickups_book_know_concrete
	+ autocvar_g_replace_weapon_pickups_scroll_timesink
	+ autocvar_g_replace_weapon_pickups_scroll_grace
	+ autocvar_g_replace_weapon_pickups_scroll_vampyricconduit
	+ autocvar_g_replace_weapon_pickups_scroll_extinguish
	+ autocvar_g_replace_weapon_pickups_scroll_darkritual
	+ autocvar_g_replace_weapon_pickups_scroll_clairvoyance
	+ autocvar_g_replace_weapon_pickups_scroll_heal
	+ autocvar_g_replace_weapon_pickups_scroll_repair
	+ autocvar_g_replace_weapon_pickups_scroll_inferno
	+ autocvar_g_replace_weapon_pickups_scroll_acervilux
	+ autocvar_g_replace_weapon_pickups_scroll_chainlightining
	+ autocvar_g_replace_weapon_pickups_scroll_balllightining
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningburst
	+ autocvar_g_replace_weapon_pickups_scroll_chargedbolt
	+ autocvar_g_replace_weapon_pickups_scroll_lightiningwall
	+ autocvar_g_replace_weapon_pickups_scroll_holylight
	+ autocvar_g_replace_weapon_pickups_scroll_aquacaelestis
	+ autocvar_g_replace_weapon_pickups_scroll_nivosus
	+ autocvar_g_replace_weapon_pickups_scroll_rosa
	+ autocvar_g_replace_weapon_pickups_scroll_corvuspenna
	+ autocvar_g_replace_weapon_pickups_scroll_plumosus
	+ autocvar_g_replace_weapon_pickups_scroll_magmasphere
	+ autocvar_g_replace_weapon_pickups_scroll_firecentury
	)) {
		if (insteadspawnbook)
			spawnfunc_item_book_spell_firecentury();
		else
			spawnfunc_item_scroll_spell_firecentury();
	}
	else
	{
		//Shouldn't Get here, So if you see a health in a weapon spot...
		spawnfunc_item_health_small();	
	}	
}

void weapon_scrollreplacement_biased(void)
{
	weapon_scrollorspellbookreplacement_biased(0);
}

void weapon_spellbookreplacement_biased(void)
{
	weapon_scrollorspellbookreplacement_biased(1);
}

// support old misnamed entities
void spawnfunc_item_armor1() { spawnfunc_item_armor_small(); }  // FIXME: in Quake this is green armor, in Xonotic maps it is an armor shard
void spawnfunc_item_armor25() { spawnfunc_item_armor_large(); }
void spawnfunc_item_health1() { spawnfunc_item_health_small(); }
void spawnfunc_item_health25() { spawnfunc_item_health_medium(); }
void spawnfunc_item_health100() { spawnfunc_item_health_mega(); }

void spawnfunc_item_strength (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(g_minstagib) {
		minstagib_items(IT_STRENGTH);
	} else {
		precache_sound("weapons/strength_fire.wav");
		if(!self.strength_finished)
			self.strength_finished = autocvar_g_balance_powerup_strength_time;
		StartItem ("models/items/g_strength.md3", "misc/powerup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Strength Powerup", IT_STRENGTH, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}

void spawnfunc_item_invincible (void) {
	self.inventory_itemnosize = 1; //Will be picked up even if no room in inventory
	if(g_minstagib) {
		minstagib_items(IT_INVINCIBLE);
	} else {
		if(!self.invincible_finished)
			self.invincible_finished = autocvar_g_balance_powerup_invincible_time;
		StartItem ("models/items/g_invincible.md3", "misc/powerup_shield.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Shield", IT_INVINCIBLE, 0, FL_POWERUP, generic_pickupevalfunc, 100000);
	}
}

void spawnfunc_item_minst_cells (void) {
	if (g_minstagib)
	{
		minst_no_auto_cells = TRUE;
		minstagib_items(IT_CELLS);
	}
	else
		remove(self);
}

// compatibility:
void spawnfunc_item_quad (void) {self.classname = "item_strength";spawnfunc_item_strength();}

float GiveItems(entity e, float beginarg, float endarg);
void target_items_use (void)
{
	if(activator.classname == "droppedweapon")
	{
		EXACTTRIGGER_TOUCH;
		remove(activator);
		return;
	}

	if(activator.classname != "player")
		return;
	if(activator.deadflag != DEAD_NO)
		return;
	EXACTTRIGGER_TOUCH;

	entity e;
	for(e = world; (e = find(e, classname, "droppedweapon")); )
		if(e.enemy == activator)
			remove(e);

	if(GiveItems(activator, 0, tokenize_console(self.netname)))
		centerprint(activator, self.message);
}

void spawnfunc_target_items (void)
{
	float n, i, j;
	entity e;

	self.use = target_items_use;
	if(!self.strength_finished)
		self.strength_finished = autocvar_g_balance_powerup_strength_time;
	if(!self.invincible_finished)
		self.invincible_finished = autocvar_g_balance_powerup_invincible_time;
	if(!self.superweapons_finished)
		self.superweapons_finished = autocvar_g_balance_superweapons_time;

	precache_sound("misc/itempickup.wav");
	precache_sound("misc/megahealth.wav");
	precache_sound("misc/armor25.wav");
	precache_sound("misc/powerup.wav");
	precache_sound("misc/poweroff.wav");
	precache_sound("weapons/weaponpickup.wav");

	n = tokenize_console(self.netname);
	if(argv(0) == "give")
	{
		self.netname = substring(self.netname, argv_start_index(1), argv_end_index(-1) - argv_start_index(1));
	}
	else
	{
		for(i = 0; i < n; ++i)
		{
			if     (argv(i) == "unlimited_ammo")         self.items |= IT_UNLIMITED_AMMO;
			else if(argv(i) == "unlimited_weapon_ammo")  self.items |= IT_UNLIMITED_WEAPON_AMMO;
			else if(argv(i) == "unlimited_superweapons") self.items |= IT_UNLIMITED_SUPERWEAPONS;
			else if(argv(i) == "strength")               self.items |= IT_STRENGTH;
			else if(argv(i) == "invincible")             self.items |= IT_INVINCIBLE;
			else if(argv(i) == "superweapons")           self.items |= IT_SUPERWEAPON;
			else if(argv(i) == "jetpack")                self.items |= IT_JETPACK;
			else if(argv(i) == "fuel_regen")             self.items |= IT_FUEL_REGEN;
			else
			{
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					e = get_weaponinfo(j);
					if(argv(i) == e.netname)
					{
						WEPSET_OR_EW(self, j);
						if(self.spawnflags == 0 || self.spawnflags == 2)
							weapon_action(e.weapon, WR_PRECACHE);
						break;
					}
				}
				if(j > WEP_LAST)
					print("target_items: invalid item ", argv(i), "\n");
			}
		}

		string itemprefix, valueprefix;
		if(self.spawnflags == 0)
		{
			itemprefix = "";
			valueprefix = "";
		}
		else if(self.spawnflags == 1)
		{
			itemprefix = "max ";
			valueprefix = "max ";
		}
		else if(self.spawnflags == 2)
		{
			itemprefix = "min ";
			valueprefix = "min ";
		}
		else if(self.spawnflags == 4)
		{
			itemprefix = "minus ";
			valueprefix = "max ";
		}
		else
		{
			error("invalid spawnflags");
#ifdef GMQCC
			itemprefix = string_null;
			valueprefix = string_null;
#endif
		}

		self.netname = "";
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_WEAPON_AMMO), "unlimited_weapon_ammo");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_UNLIMITED_SUPERWEAPONS), "unlimited_superweapons");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.strength_finished * !!(self.items & IT_STRENGTH), "strength");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.invincible_finished * !!(self.items & IT_INVINCIBLE), "invincible");
		self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, self.superweapons_finished * !!(self.items & IT_SUPERWEAPON), "superweapons");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_JETPACK), "jetpack");
		self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, !!(self.items & IT_FUEL_REGEN), "fuel_regen");
		if(self.ammo_shells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_shells), "shells");
		if(self.ammo_nails != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_nails), "nails");
		if(self.ammo_rockets != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_rockets), "rockets");
		if(self.ammo_cells != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_cells), "cells");
		if(self.ammo_fuel != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.ammo_fuel), "fuel");
		if(self.health != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "health");
		if(self.armorvalue != 0) self.netname = sprintf("%s %s%d %s", self.netname, valueprefix, max(0, self.health), "armor");
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(e.weapon)
				self.netname = sprintf("%s %s%d %s", self.netname, itemprefix, WEPSET_CONTAINS_EW(self, j), e.netname);
		}
	}
	self.netname = strzone(self.netname);
	//print(self.netname, "\n");

	local float k; //Had to add this so we don't precache all the weapons.. there was a bug ...
	k = 0;
	
	n = tokenize_console(self.netname);
	for(i = 0; i < n; ++i)
	{
		//print(argv(i), "_CurrentStringIterQuanta\n"); //can be weapon names or some command for giving or numbers denoting if a weapon will be given
		
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
			{
				if (k == 1) //The previous string iter quanta was a "1": so that means the user gets that weapon on touching this, so we precache
				{
					if (target_items_current_precache_number > TARGETITEMSPRECACHELIMIT) {
						//print("Limit Reached: Refusing to Precache: ", e.netname,"\n");
					} else {
						//print("Precaching: ", e.netname,"\n");
						weapon_action(e.weapon, WR_PRECACHE);
						target_items_current_precache_number = target_items_current_precache_number + 1;
					}
				}
				k = 0;
				break;
			}
		}
		
		if (argv(i) == "1") {
			k = 1; //We want to get ready to precache: we find out the weapon name next pass
		} else if (argv(i) == "0") {
			k = 0; //We don't precache the upcoming weapon since said weapon is not given: hence the 0
		}
	}
}

void spawnfunc_item_fuel(void)
{
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel;
	if(!self.pickup_anyway)
		self.pickup_anyway = g_pickup_ammo_anyway;
	StartItem ("models/items/g_fuel.md3", "misc/itempickup.wav", g_pickup_respawntime_ammo, g_pickup_respawntimejitter_ammo, "Fuel", IT_FUEL, 0, 0, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_fuel_regen(void)
{
	if(start_items & IT_FUEL_REGEN)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_fuelregen.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Fuel regenerator", IT_FUEL_REGEN, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}

void spawnfunc_item_jetpack(void)
{
	if(g_grappling_hook)
		return; // sorry, but these two can't coexist (same button); spawn fuel instead
	if(!self.ammo_fuel)
		self.ammo_fuel = g_pickup_fuel_jetpack;
	if(start_items & IT_JETPACK)
	{
		spawnfunc_item_fuel();
		return;
	}
	StartItem ("models/items/g_jetpack.md3", "misc/itempickup.wav", g_pickup_respawntime_powerup, g_pickup_respawntimejitter_powerup, "Jet pack", IT_JETPACK, 0, FL_POWERUP, commodity_pickupevalfunc, BOT_PICKUP_RATING_LOW);
}


#define OP_SET 0
#define OP_MIN 1
#define OP_MAX 2
#define OP_PLUS 3
#define OP_MINUS 4
#define OP_REVERSEIFNEGATIVEORMIN 5
#define OP_REVERSEIFMORETHANORZEROOUT 6

float GiveWeapon(entity e, float wpn, float op, float val)
{
	float v0, v1;
	v0 = WEPSET_CONTAINS_EW(e, wpn);
	switch(op)
	{
		case OP_SET:
			if(val > 0)
				WEPSET_OR_EW(e, wpn);
			else
				WEPSET_ANDNOT_EW(e, wpn);
			break;
		case OP_MIN:
		case OP_PLUS:
			if(val > 0)
				WEPSET_OR_EW(e, wpn);
			break;
		case OP_MAX:
			if(val <= 0)
				WEPSET_ANDNOT_EW(e, wpn);
			break;
		case OP_MINUS:
			if(val > 0)
				WEPSET_ANDNOT_EW(e, wpn);
			break;
	}
	v1 = WEPSET_CONTAINS_EW(e, wpn);
	return (v0 != v1);
}

float GiveBit(entity e, .float fld, float bit, float op, float val)
{
	float v0, v1;
	v0 = (e.fld & bit);
	switch(op)
	{
		case OP_SET:
			if(val > 0)
				e.fld |= bit;
			else
				e.fld &~= bit;
			break;
		case OP_MIN:
		case OP_PLUS:
			if(val > 0)
				e.fld |= bit;
			break;
		case OP_MAX:
			if(val <= 0)
				e.fld &~= bit;
			break;
		case OP_MINUS:
			if(val > 0)
				e.fld &~= bit;
			break;
	}
	v1 = (e.fld & bit);
	return (v0 != v1);
}

float GiveValue(entity e, .float fld, float op, float val)
{
	float v0, v1;
	v0 = e.fld;
	switch(op)
	{
		case OP_SET:
			e.fld = val;
			break;
		case OP_MIN:
			e.fld = max(e.fld, val); // min 100 cells = at least 100 cells
			break;
		case OP_MAX:
			e.fld = min(e.fld, val);
			break;
		case OP_PLUS:
			e.fld += val;
			break;
		case OP_MINUS:
			e.fld -= val;
			break;
		case OP_REVERSEIFNEGATIVEORMIN:
			if (e.fld < 0) {
				e.fld = e.fld * -1;
			} else {
				e.fld = max(e.fld, val); // min 100 cells = at least 100 cells
			}
			break;
		case OP_REVERSEIFMORETHANORZEROOUT:
			if (e.fld > val) {
				e.fld = e.fld * -1;
			} else {
				e.fld = 0;
			}
			break;
		
	}
	v1 = e.fld;
	return (v0 != v1);
}

void GiveSound(entity e, float v0, float v1, float t, string snd_incr, string snd_decr)
{
	if(v1 == v0)
		return;
	if(v1 <= v0 - t)
	{
		if(snd_decr != "")
			sound (e, CH_TRIGGER, snd_decr, VOL_BASE, ATTN_NORM);
	}
	else if(v0 >= v0 + t)
	{
		if(snd_incr != "")
			sound (e, CH_TRIGGER, snd_incr, VOL_BASE, ATTN_NORM);
	}
}

void GiveRot(entity e, float v0, float v1, .float rotfield, float rottime, .float regenfield, float regentime)
{
	if(v0 < v1)
		e.rotfield = max(e.rotfield, time + rottime);
	else if(v0 > v1)
		e.regenfield = max(e.regenfield, time + regentime);
}

#define PREGIVE_WEAPONS(e) WEPSET_DECLARE_A(save_weapons); WEPSET_COPY_AE(save_weapons, e)
#define PREGIVE(e,f) float save_##f; save_##f = (e).f
#define POSTGIVE_WEAPON(e,b,snd_incr,snd_decr) GiveSound((e), WEPSET_CONTAINS_AW(save_weapons, b), WEPSET_CONTAINS_EW(e, b), 0, snd_incr, snd_decr)
#define POSTGIVE_BIT(e,f,b,snd_incr,snd_decr) GiveSound((e), save_##f & (b), (e).f & (b), 0, snd_incr, snd_decr)
#define POSTGIVE_VALUE(e,f,t,snd_incr,snd_decr) GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)
#define POSTGIVE_VALUE_ROT(e,f,t,rotfield,rottime,regenfield,regentime,snd_incr,snd_decr) GiveRot((e), save_##f, (e).f, rotfield, rottime, regenfield, regentime); GiveSound((e), save_##f, (e).f, t, snd_incr, snd_decr)

float GiveItems(entity e, float beginarg, float endarg)
{
	float got, i, j, val, op;
	float _switchweapon;
	entity wi;
	string cmd;

	val = 999;
	op = OP_SET;

	got = 0;

	_switchweapon = FALSE;
	if (e.autoswitch)
		if (e.switchweapon == w_getbestweapon(e))
			_switchweapon = TRUE;

	e.strength_finished = max(0, e.strength_finished - time);
	e.invincible_finished = max(0, e.invincible_finished - time);
	e.superweapons_finished = max(0, e.superweapons_finished - time);
	
	PREGIVE(e, items);
	PREGIVE_WEAPONS(e);
	PREGIVE(e, strength_finished);
	PREGIVE(e, invincible_finished);
	PREGIVE(e, superweapons_finished);
	PREGIVE(e, ammo_nails);
	PREGIVE(e, ammo_cells);
	PREGIVE(e, ammo_shells);
	PREGIVE(e, ammo_rockets);
	PREGIVE(e, ammo_fuel);
	PREGIVE(e, armorvalue);
	PREGIVE(e, health);
	PREGIVE(e, mana);

	for(i = beginarg; i < endarg; ++i)
	{
		cmd = argv(i);
		
		
		if (val == 999 && autocvar_sv_gameplayfix_cmd_give_set_defaults) {
			if (autocvar_sv_gameplayfix_cmd_give_set_defaults == -2) {
				switch(cmd)
				{
					default:
						val = 1;
						break;
					case "ALL":
					case "all":
					case "allweapons":
					case "allammo":
					case "unlimited_ammo":
					case "unlimited_weapon_ammo":
					case "unlimited_superweapons":
					case "jetpack":
					case "fuel_regen":
					case "strength":
					case "invincible":
					case "superweapons":
						//Keep as 999
						break;
				}
			} else if (autocvar_sv_gameplayfix_cmd_give_set_defaults == -1) {
				switch(cmd)
				{
					default:
						val = 1;
					break;
					case "ALL":
					case "all":
					case "allweapons":
					case "allammo":
					case "unlimited_ammo":
					case "unlimited_weapon_ammo":
					case "unlimited_superweapons":
					case "jetpack":
					case "fuel_regen":
					case "strength":
					case "invincible":
					case "superweapons":
					case "cells":
					case "shells":
					case "nails":
					case "bullets":
					case "rockets":
					case "health":
					case "armor":
					case "mana":
					case "fuel":
						//Keep as 999
						break;
				}
			} else {
				val = autocvar_sv_gameplayfix_cmd_give_set_defaults;
			}
		}
		

		if(cmd == "0" || stof(cmd))
		{
			val = stof(cmd);
			continue;
		}
		switch(cmd)
		{
			case "no":
				op = OP_MAX;
				val = 0;
				continue;
			case "max":
				op = OP_MAX;
				continue;
			case "min":
				op = OP_MIN;
				continue;
			case "plus":
				op = OP_PLUS;
				continue;
			case "minus":
				op = OP_MINUS;
				continue;
			case "reverseifnegativeormin":
				op = OP_REVERSEIFNEGATIVEORMIN;
				continue;
			case "reverseifmorethanorzeroout":
				op = OP_REVERSEIFMORETHANORZEROOUT;
				continue;
			case "ALL":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				got += GiveValue(e, strength_finished, op, val);
				got += GiveValue(e, invincible_finished, op, val);
				got += GiveValue(e, superweapons_finished, op, val);
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
			case "all":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				got += GiveValue(e, health, op, val);
				got += GiveValue(e, armorvalue, op, val);
			case "allweapons":
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(wi.weapon)
						if not(wi.spawnflags & WEP_FLAG_MUTATORBLOCKED)
							got += GiveWeapon(e, j, op, val);
				}
			case "allammo":
				got += GiveValue(e, ammo_cells, op, val);
				got += GiveValue(e, ammo_shells, op, val);
				got += GiveValue(e, ammo_nails, op, val);
				got += GiveValue(e, ammo_rockets, op, val);
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			case "unlimited_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_AMMO, op, val);
				break;
			case "unlimited_weapon_ammo":
				got += GiveBit(e, items, IT_UNLIMITED_WEAPON_AMMO, op, val);
				break;
			case "unlimited_superweapons":
				got += GiveBit(e, items, IT_UNLIMITED_SUPERWEAPONS, op, val);
				break;
			case "jetpack":
				got += GiveBit(e, items, IT_JETPACK, op, val);
				break;
			case "fuel_regen":
				got += GiveBit(e, items, IT_FUEL_REGEN, op, val);
				break;
			case "strength":
				got += GiveValue(e, strength_finished, op, val);
				break;
			case "invincible":
				got += GiveValue(e, invincible_finished, op, val);
				break;
			case "superweapons":
				got += GiveValue(e, superweapons_finished, op, val);
				break;
			case "cells":
				got += GiveValue(e, ammo_cells, op, val);
				break;
			case "shells":
				got += GiveValue(e, ammo_shells, op, val);
				break;
			case "nails":
			case "bullets":
				got += GiveValue(e, ammo_nails, op, val);
				break;
			case "rockets":
				got += GiveValue(e, ammo_rockets, op, val);
				break;
			case "health":
				got += GiveValue(e, health, op, val);
				break;
			case "armor":
				got += GiveValue(e, armorvalue, op, val);
				break;
			case "mana":
				got += GiveValue(e, mana, op, val);
				break;
			case "fuel":
				got += GiveValue(e, ammo_fuel, op, val);
				break;
			case "health_stable_reduce":
				got += GiveValue(e, health_stable_reduce, op, val);
				break;
			case "armor_stable_reduce":
				got += GiveValue(e, armor_stable_reduce, op, val);
				break;
			case "mana_stable_reduce":
				got += GiveValue(e, mana_stable_reduce, op, val);
				break;
			case "bellpepper":
				got += GiveValue(e, inv_food_bellpepper, op, val);
				break;
			case "bread":
				got += GiveValue(e, inv_food_bread, op, val);
				break;
			case "cheeze":
				got += GiveValue(e, inv_food_cheeze, op, val);
				break;
			case "garlic":
				got += GiveValue(e, inv_food_garlic, op, val);
				break;
			case "grapes":
				got += GiveValue(e, inv_food_grapes, op, val);
				break;
			case "onion":
				got += GiveValue(e, inv_food_onion, op, val);
				break;
			case "tomato":
				got += GiveValue(e, inv_food_tomato, op, val);
				break;
			case "turkeyleg":
				got += GiveValue(e, inv_food_turkeyleg, op, val);
				break;
			case "grenades":
				got += GiveValue(e, grenades, op, val);
				break;
			case "flashbangs":
				got += GiveValue(e, flashbangs, op, val);
				break;
			case "smokenades":
				got += GiveValue(e, smokenades, op, val);
				break;
			case "atmines":
				got += GiveValue(e, atmines, op, val);
				break;
			case "landmines":
				got += GiveValue(e, landmines, op, val);
				break;
			case "water":
			case "mediumwater":
				got += GiveValue(e, inv_potion_water_medium, op, val);
				break;
			case "ale":
			case "mediumale":
				got += GiveValue(e, inv_potion_ale_medium, op, val);
				break;
			case "merlot":
			case "mediummerlot":
				got += GiveValue(e, inv_potion_merlot_medium, op, val);
				break;
			case "vodka":
			case "mediumvodka":
				got += GiveValue(e, inv_potion_vodka_medium, op, val);
				break;
			case "healthpotion":
			case "mediumhealthpotion":
				got += GiveValue(e, inv_potion_health_medium, op, val);
				break;
			case "manapotion":
			case "mediummanapotion":
				got += GiveValue(e, inv_potion_mana_medium, op, val);
				break;
			case "rejuvpotion":
			case "mediumrejuvpotion":
				got += GiveValue(e, inv_potion_rejuv_medium, op, val);
				break;
			case "smallwater":
			case "watervial":
				got += GiveValue(e, inv_potion_water_small, op, val);
				break;
			case "smallale":
			case "alevial":
				got += GiveValue(e, inv_potion_ale_small, op, val);
				break;
			case "smallmerlot":
			case "merlotvial":
				got += GiveValue(e, inv_potion_merlot_small, op, val);
				break;
			case "smallvodka":
			case "vodkavial":
				got += GiveValue(e, inv_potion_vodka_small, op, val);
				break;
			case "smallhealthpotion":
			case "healthvial":
				got += GiveValue(e, inv_potion_health_small, op, val);
				break;
			case "smallmanapotion":
			case "manavial":
				got += GiveValue(e, inv_potion_mana_small, op, val);
				break;
			case "smallrejuvpotion":
			case "rejuvvial":
				got += GiveValue(e, inv_potion_rejuv_small, op, val);
				break;
			case "largewater":
			case "bigwater":
			case "fullwater":
				got += GiveValue(e, inv_potion_water_large, op, val);
				break;
			case "largeale":
			case "bigale":
			case "fullale":
				got += GiveValue(e, inv_potion_ale_large, op, val);
				break;
			case "largemerlot":
			case "bigmerlot":
			case "fullmerlot":
				got += GiveValue(e, inv_potion_merlot_large, op, val);
				break;
			case "largevodka":
			case "bigvodka":
			case "fullvodka":
				got += GiveValue(e, inv_potion_vodka_large, op, val);
				break;
			case "largehealthpotion":
			case "bighealthpotion":
			case "fullhealthpotion":
				got += GiveValue(e, inv_potion_health_large, op, val);
				break;
			case "largemanapotion":
			case "bigmanapotion":
			case "fullmanapotion":
				got += GiveValue(e, inv_potion_mana_large, op, val);
				break;
			case "largerejuvpotion":
			case "bigrejuvpotion":
			case "fullrejuvpotion":
				got += GiveValue(e, inv_potion_rejuv_large, op, val);
				break;
			case "faeces_small":
					if (autocvar_sv_risque >= 0.5) {
					got += GiveValue(e, inv_faeces_small, op, val);
					}
				break;
			case "faeces_medium":
					if (autocvar_sv_risque >= 0.5) {
					got += GiveValue(e, inv_faeces_medium, op, val);
					}
				break;
			case "faeces_large":
					if (autocvar_sv_risque >= 0.5) {
					got += GiveValue(e, inv_faeces_large, op, val);
					}
				break;
			case "book_agency":
				got += GiveValue(e, inv_book_agency, op, val);
				break;
			case "scroll_agency":
				got += GiveValue(e, inv_scroll_agency, op, val);
				break;
			case "spell_agency":
				got += GiveValue(e, spell_agency, op, val);
				break;
			case "book_death":
				
				got += GiveValue(e, inv_book_death, op, val);
				break;
			case "scroll_death":
				got += GiveValue(e, inv_scroll_death, op, val);
				break;
			case "spell_death":
				got += GiveValue(e, spell_death, op, val);
				break;
			case "book_drainlife":
				got += GiveValue(e, inv_book_drainlife, op, val);
				break;
			case "scroll_drainlife":
				got += GiveValue(e, inv_scroll_drainlife, op, val);
				break;
			case "spell_drainlife":
				got += GiveValue(e, spell_drainlife, op, val);
				break;
			case "book_cancellation":
				got += GiveValue(e, inv_book_cancellation, op, val);
				break;
			case "scroll_cancellation":
				got += GiveValue(e, inv_scroll_cancellation, op, val);
				break;
			case "spell_cancellation":
				got += GiveValue(e, spell_cancellation, op, val);
				break;
			case "book_castfromlife":
				got += GiveValue(e, inv_book_castfromlife, op, val);
				break;
			case "scroll_castfromlife":
				got += GiveValue(e, inv_scroll_castfromlife, op, val);
				break;
			case "spell_castfromlife":
				got += GiveValue(e, spell_castfromlife, op, val);
				break;
			case "book_confer":
				got += GiveValue(e, inv_book_confer, op, val);
				break;
			case "scroll_confer":
				got += GiveValue(e, inv_scroll_confer, op, val);
				break;
			case "spell_confer":
				got += GiveValue(e, spell_confer, op, val);
				break;
			case "book_iceball":	
				got += GiveValue(e, inv_book_iceball, op, val);
				break;
			case "scroll_iceball":
				got += GiveValue(e, inv_scroll_iceball, op, val);
				break;
			case "spell_iceball":
				got += GiveValue(e, spell_iceball, op, val);
				break;
			case "book_icestar":
				got += GiveValue(e, inv_book_icestar, op, val);
				break;
			case "scroll_icestar":
				got += GiveValue(e, inv_scroll_icestar, op, val);
				break;
			case "spell_icestar":
				got += GiveValue(e, spell_icestar, op, val);
				break;
			case "book_firebolt":
				got += GiveValue(e, inv_book_firebolt, op, val);
				break;
			case "scroll_firebolt":
				got += GiveValue(e, inv_scroll_firebolt, op, val);
				break;
			case "spell_firebolt":
				got += GiveValue(e, spell_firebolt, op, val);
				break;
			case "book_fireball":
				got += GiveValue(e, inv_book_fireball, op, val);
				break;
			case "scroll_fireball":
				got += GiveValue(e, inv_scroll_fireball, op, val);
				break;
			case "spell_fireball":
				got += GiveValue(e, spell_fireball, op, val);
				break;
			case "book_magmasphere":
				got += GiveValue(e, inv_book_magmasphere, op, val);
				break;
			case "scroll_magmasphere":
				got += GiveValue(e, inv_scroll_magmasphere, op, val);
				break;
			case "spell_magmasphere":
				got += GiveValue(e, spell_magmasphere, op, val);
				break;
			case "book_firebeam":
				got += GiveValue(e, inv_book_firebeam, op, val);
				break;
			case "scroll_firebeam":
				got += GiveValue(e, inv_scroll_firebeam, op, val);
				break;
			case "spell_firebeam":
				got += GiveValue(e, spell_firebeam, op, val);
				break;
			case "book_inferno":
				got += GiveValue(e, inv_book_inferno, op, val);
				break;
			case "scroll_inferno":
				got += GiveValue(e, inv_scroll_inferno, op, val);
				break;
			case "spell_inferno":
				got += GiveValue(e, spell_inferno, op, val);
				break;
			case "book_firewall":
				got += GiveValue(e, inv_book_firewall, op, val);
				break;
			case "scroll_firewall":
				got += GiveValue(e, inv_scroll_firewall, op, val);
				break;
			case "spell_firewall":
				got += GiveValue(e, spell_firewall, op, val);
				break;
			case "book_scepterofflame":
				got += GiveValue(e, inv_book_scepterofflame, op, val);
				break;
			case "scroll_scepterofflame":
				got += GiveValue(e, inv_scroll_scepterofflame, op, val);
				break;
			case "spell_scepterofflame":
				got += GiveValue(e, spell_scepterofflame, op, val);
				break;
			case "book_explosion":
				got += GiveValue(e, inv_book_explosion, op, val);
				break;
			case "scroll_explosion":
				got += GiveValue(e, inv_scroll_explosion, op, val);
				break;
			case "spell_explosion":
				got += GiveValue(e, spell_explosion, op, val);
				break;
			case "book_phantasmalbarrier":
				got += GiveValue(e, inv_book_phantasmalbarrier, op, val);
				break;
			case "scroll_phantasmalbarrier":
				got += GiveValue(e, inv_scroll_phantasmalbarrier, op, val);
				break;
			case "spell_phantasmalbarrier":
				got += GiveValue(e, spell_phantasmalbarrier, op, val);
				break;
			case "book_raiseundead":
				raiseundeadmarkerenabled = 1; //So we will place death markers if not allready doing so
				got += GiveValue(e, inv_book_raiseundead, op, val);
				break;
			case "scroll_raiseundead":
				raiseundeadmarkerenabled = 1; //So we will place death markers if not allready doing so
				got += GiveValue(e, inv_scroll_raiseundead, op, val);
				break;
			case "spell_raiseundead":
				raiseundeadmarkerenabled = 1; //So we will place death markers if not allready doing so
				got += GiveValue(e, spell_raiseundead, op, val);
				break;
			case "book_flameburst":
				got += GiveValue(e, inv_book_flameburst, op, val);
				break;
			case "scroll_flameburst":
				got += GiveValue(e, inv_scroll_flameburst, op, val);
				break;
			case "spell_flameburst":
				got += GiveValue(e, spell_flameburst, op, val);
				break;
			case "book_firecentury":
				got += GiveValue(e, inv_book_firecentury, op, val);
				break;
			case "scroll_firecentury":
				got += GiveValue(e, inv_scroll_firecentury, op, val);
				break;
			case "spell_firecentury":
				got += GiveValue(e, spell_firecentury, op, val);
				break;
			case "book_frostbeam":	
                		got += GiveValue(e, inv_book_frostbeam, op, val);
				break;
			case "scroll_frostbeam":
                		got += GiveValue(e, inv_scroll_frostbeam, op, val);
				break;
			case "spell_frostbeam":
                		got += GiveValue(e, spell_frostbeam, op, val);
				break;
			case "book_grace":
				got += GiveValue(e, inv_book_grace, op, val);
				break;
			case "scroll_grace":
				got += GiveValue(e, inv_scroll_grace, op, val);
				break;
			case "spell_grace":
				got += GiveValue(e, spell_grace, op, val);
				break;
			case "book_holybolt":
				got += GiveValue(e, inv_book_holybolt, op, val);
				break;
			case "scroll_holybolt":
				got += GiveValue(e, inv_scroll_holybolt, op, val);
				break;
			case "spell_holybolt":
				got += GiveValue(e, spell_holybolt, op, val);
				break;
			case "book_holylight":
				got += GiveValue(e, inv_book_holylight, op, val);
				break;
			case "scroll_holylight":
				got += GiveValue(e, inv_scroll_holylight, op, val);
				break;
			case "spell_holylight":
				got += GiveValue(e, spell_holylight, op, val);
				break;
			case "book_acervilux":
				got += GiveValue(e, inv_book_acervilux, op, val);
				break;
			case "scroll_acervilux":
				got += GiveValue(e, inv_scroll_acervilux, op, val);
				break;
			case "spell_acervilux":
				got += GiveValue(e, spell_acervilux, op, val);
				break;
			case "book_aquacaelestis":
				got += GiveValue(e, inv_book_aquacaelestis, op, val);
				break;
			case "scroll_aquacaelestis":
				got += GiveValue(e, inv_scroll_aquacaelestis, op, val);
				break;
			case "spell_aquacaelestis":
				got += GiveValue(e, spell_aquacaelestis, op, val);
				break;
			case "book_nivosus":
				got += GiveValue(e, inv_book_nivosus, op, val);
				break;
			case "scroll_nivosus":
				got += GiveValue(e, inv_scroll_nivosus, op, val);
				break;
			case "spell_nivosus":
				got += GiveValue(e, spell_nivosus, op, val);
				break;
			case "book_rosa":
				got += GiveValue(e, inv_book_rosa, op, val);
				break;
			case "scroll_rosa":
				got += GiveValue(e, inv_scroll_rosa, op, val);
				break;
			case "spell_rosa":
				got += GiveValue(e, spell_rosa, op, val);
				break;
			case "book_corvuspenna":
				got += GiveValue(e, inv_book_corvuspenna, op, val);
				break;
			case "scroll_corvuspenna":
				got += GiveValue(e, inv_scroll_corvuspenna, op, val);
				break;
			case "spell_corvuspenna":
				got += GiveValue(e, spell_corvuspenna, op, val);
				break;
			case "book_plumosus":
				got += GiveValue(e, inv_book_plumosus, op, val);
				break;
			case "scroll_plumosus":
				got += GiveValue(e, inv_scroll_plumosus, op, val);
				break;
			case "spell_plumosus":
				got += GiveValue(e, spell_plumosus, op, val);
				break;
			case "book_heal":
				got += GiveValue(e, inv_book_heal, op, val);
				break;
			case "scroll_heal":
				got += GiveValue(e, inv_scroll_heal, op, val);
				break;
			case "spell_heal":
				got += GiveValue(e, spell_heal, op, val);
				break;
			case "book_repair":
				got += GiveValue(e, inv_book_repair, op, val);
				break;
			case "scroll_repair":
				got += GiveValue(e, inv_scroll_repair, op, val);
				break;
			case "spell_repair":
				got += GiveValue(e, spell_repair, op, val);
				break;
			case "book_holyword":
				got += GiveValue(e, inv_book_holyword, op, val);
				break;
			case "scroll_holyword":
				got += GiveValue(e, inv_scroll_holyword, op, val);
				break;
			case "spell_holyword":
				got += GiveValue(e, spell_holyword, op, val);
				break;
			case "book_extinguish":
				got += GiveValue(e, inv_book_extinguish, op, val);
				break;
			case "scroll_extinguish":
				got += GiveValue(e, inv_scroll_extinguish, op, val);
				break;
			case "spell_extinguish":
				got += GiveValue(e, spell_extinguish, op, val);
				break;
			case "book_darkritual":
				got += GiveValue(e, inv_book_darkritual, op, val);
				break;
			case "scroll_darkritual":
				got += GiveValue(e, inv_scroll_darkritual, op, val);
				break;
			case "spell_darkritual":
				got += GiveValue(e, spell_darkritual, op, val);
				break;
			case "book_lightining":
                		got += GiveValue(e, inv_book_lightining, op, val);
				break;
			case "scroll_lightining":
                		got += GiveValue(e, inv_scroll_lightining, op, val);
				break;
			case "spell_lightining":
                		got += GiveValue(e, spell_lightining, op, val);
				break;
			case "book_balllightining":
               			got += GiveValue(e, inv_book_balllightining, op, val);
				break;
			case "scroll_balllightining":
                		got += GiveValue(e, inv_scroll_balllightining, op, val);
				break;
			case "spell_balllightining":
                		got += GiveValue(e, spell_balllightining, op, val);
				break;
			case "book_lightiningburst":
                		got += GiveValue(e, inv_book_lightiningburst, op, val);
				break;
			case "scroll_lightiningburst":
                		got += GiveValue(e, inv_scroll_lightiningburst, op, val);
				break;
			case "spell_lightiningburst":
                		got += GiveValue(e, spell_lightiningburst, op, val);
				break;
			case "book_chargedbolt":
                		got += GiveValue(e, inv_book_chargedbolt, op, val);
				break;
			case "scroll_chargedbolt":
                		got += GiveValue(e, inv_scroll_chargedbolt, op, val);
				break;
			case "spell_chargedbolt":
                		got += GiveValue(e, spell_chargedbolt, op, val);
				break;
			case "book_chainlightining":
                		got += GiveValue(e, inv_book_chainlightining, op, val);
				break;
			case "scroll_chainlightining":
                		got += GiveValue(e, inv_scroll_chainlightining, op, val);
				break;
			case "spell_chainlightining":
                		got += GiveValue(e, spell_chainlightining, op, val);
				break;
			case "book_lightiningstrike":
				got += GiveValue(e, inv_book_lightiningstrike, op, val);
				break;
			case "scroll_lightiningstrike":
                		got += GiveValue(e, inv_scroll_lightiningstrike, op, val);
				break;
			case "spell_lightiningstrike":
                		got += GiveValue(e, spell_lightiningstrike, op, val);
				break;
			case "book_lightiningwall":
				got += GiveValue(e, inv_book_lightiningwall, op, val);
				break;
			case "scroll_lightiningwall":
                		got += GiveValue(e, inv_scroll_lightiningwall, op, val);
				break;
			case "spell_lightiningwall":
                		got += GiveValue(e, spell_lightiningwall, op, val);
				break;
			case "book_monstertomouse":
				got += GiveValue(e, inv_book_monstertomouse, op, val);
				break;
			case "scroll_monstertomouse":
                		got += GiveValue(e, inv_scroll_monstertomouse, op, val);
				break;
			case "spell_monstertomouse":
                		got += GiveValue(e, spell_monstertomouse, op, val);
				break;
			case "book_monstertomonolith":
				got += GiveValue(e, inv_book_monstertomonolith, op, val);
				break;
			case "scroll_monstertomonolith":
                		got += GiveValue(e, inv_scroll_monstertomonolith, op, val);
				break;
			case "spell_monstertomonolith":
                		got += GiveValue(e, spell_monstertomonolith, op, val);
				break;
			case "book_magicbullets":
				got += GiveValue(e, inv_book_magicbullets, op, val);
				break;
			case "scroll_magicbullets":
                		got += GiveValue(e, inv_scroll_magicbullets, op, val);
				break;
			case "spell_magicbullets":
                		got += GiveValue(e, spell_magicbullets, op, val);
				break;
			case "book_magicmissile":
                		got += GiveValue(e, inv_book_magicmissile, op, val);
				break;
			case "scroll_magicmissile":
                		got += GiveValue(e, inv_scroll_magicmissile, op, val);
				break;
			case "spell_magicmissile":
                		got += GiveValue(e, spell_magicmissile, op, val);
				break;
			case "book_meteor":
				got += GiveValue(e, inv_book_meteor, op, val);
				break;
			case "scroll_meteor":
				got += GiveValue(e, inv_scroll_meteor, op, val);
				break;
			case "spell_meteor":
				got += GiveValue(e, spell_meteor, op, val);
				break;
			case "book_meteorshower":
				got += GiveValue(e, inv_book_meteorshower, op, val);
				break;
			case "scroll_meteorshower":
				got += GiveValue(e, inv_scroll_meteorshower, op, val);
				break;
			case "spell_meteorshower":
				got += GiveValue(e, spell_meteorshower, op, val);
				break;
			case "book_stonerain":
				got += GiveValue(e, inv_book_stonerain, op, val);
				break;
			case "scroll_stonerain":
				got += GiveValue(e, inv_scroll_stonerain, op, val);
				break;
			case "spell_stonerain":
				got += GiveValue(e, spell_stonerain, op, val);
				break;
			case "book_timesink":
				got += GiveValue(e, inv_book_timesink, op, val);
				break;
			case "scroll_timesink":
				got += GiveValue(e, inv_scroll_timesink, op, val);
				break;
			case "spell_timesink":
				got += GiveValue(e, spell_timesink, op, val);
				break;
			case "book_vampyricconduit":
				got += GiveValue(e, inv_book_vampyricconduit, op, val);
				break;
			case "scroll_vampyricconduit":
				got += GiveValue(e, inv_scroll_vampyricconduit, op, val);
				break;
			case "spell_vampyricconduit":
				got += GiveValue(e, spell_vampyricconduit, op, val);
				break;
			case "book_manashield":
				got += GiveValue(e, inv_book_manashield, op, val);
				break;
			case "scroll_manashield":
				got += GiveValue(e, inv_scroll_manashield, op, val);
				break;
			case "spell_manashield":
				got += GiveValue(e, spell_manashield, op, val);
				break;
			case "book_clairvoyance":
				got += GiveValue(e, inv_book_clairvoyance, op, val);
				break;
			case "scroll_clairvoyance":
				got += GiveValue(e, inv_scroll_clairvoyance, op, val);
				break;
			case "spell_clairvoyance":
				got += GiveValue(e, spell_clairvoyance, op, val);
				break;
			case "book_mimic":
				got += GiveValue(e, inv_book_mimic, op, val);
				break;
			case "scroll_mimic":
				got += GiveValue(e, inv_scroll_mimic, op, val);
				break;
			case "spell_mimic":
				got += GiveValue(e, spell_mimic, op, val);
				break;
			case "book_paralyse":
               			got += GiveValue(e, inv_book_paralyse, op, val);
				break;
			case "scroll_paralyse":
                		got += GiveValue(e, inv_scroll_paralyse, op, val);
				break;
			case "spell_paralyse":
                		got += GiveValue(e, spell_paralyse, op, val);
				break;
			case "book_ringoffire":
				got += GiveValue(e, inv_book_ringoffire, op, val);
				break;
			case "scroll_ringoffire":
				got += GiveValue(e, inv_scroll_ringoffire, op, val);
				break;
			case "spell_ringoffire":
				got += GiveValue(e, spell_ringoffire, op, val);
				break;
			case "book_stonecurse":
               			got += GiveValue(e, inv_book_stonecurse, op, val);
				break;
			case "scroll_stonecurse":
                		got += GiveValue(e, inv_scroll_stonecurse, op, val);
				break;
			case "spell_stonecurse":
                		got += GiveValue(e, spell_stonecurse, op, val);
				break;
			case "book_know_carpentry":
				got += GiveValue(e, inv_book_know_carpentry, op, val);
				break;
			case "book_know_mortise":
				got += GiveValue(e, inv_book_know_mortise, op, val);
				break;
			case "book_know_stonemasonry":
				got += GiveValue(e, inv_book_know_stonemasonry, op, val);
				break;
			case "book_know_ironworking":
				got += GiveValue(e, inv_book_know_ironworking, op, val);
				break;
			case "book_know_arch":
				got += GiveValue(e, inv_book_know_arch, op, val);
				break;
			case "book_know_welding":
				got += GiveValue(e, inv_book_know_welding, op, val);
				break;
			case "book_know_concrete":
				got += GiveValue(e, inv_book_know_concrete, op, val);
				break;
			case "m82rifle_customskin":
				got += GiveValue(e, m82rifle_customskin, op, val);
				break;
			case "knife_customskin":
				got += GiveValue(e, knife_customskin, op, val);
				break;
			case "famas_customskin":
				got += GiveValue(e, famas_customskin, op, val);
				break;
			case "styeraug_customskin":
				got += GiveValue(e, styeraug_customskin, op, val);
				break;
			case "lewismg_customskin":
				got += GiveValue(e, lewismg_customskin, op, val);
				break;
			case "lightauto_customskin":
				got += GiveValue(e, lightauto_customskin, op, val);
				break;
			case "pdw_customskin":
				got += GiveValue(e, pdw_customskin, op, val);
				break;
			case "streetsweeper_customskin":
				got += GiveValue(e, streetsweeper_customskin, op, val);
				break;
			case "electro_customskin":
				got += GiveValue(e, electro_customskin, op, val);
				break;
			case "crylink_customskin":
				got += GiveValue(e, crylink_customskin, op, val);
				break;
			case "largepistol_customskin":
				got += GiveValue(e, largepistol_customskin, op, val);
				break;
			case "bigpistol_customskin":
				got += GiveValue(e, bigpistol_customskin, op, val);
				break;
			case "ak47_customskin":
				got += GiveValue(e, ak47_customskin, op, val);
				break;
			case "tt33pistol_customskin":
				got += GiveValue(e, tt33pistol_customskin, op, val);
				break;
			case "targetpistol_customskin":
				got += GiveValue(e, targetpistol_customskin, op, val);
				break;
			case "p90_customskin":
				got += GiveValue(e, p90_customskin, op, val);
				break;
			case "suppressor45":
				got += GiveValue(e, inv_misc_suppressor45, op, val);
				break;
			case "suppressormac10":
				got += GiveValue(e, inv_misc_suppressormac10, op, val);
				break;
			case "suppressor9mm":
				got += GiveValue(e, inv_misc_suppressor9mm, op, val);
				break;
			case "suppressor5n7mm":
				got += GiveValue(e, inv_misc_suppressor5n7mm, op, val);
				break;
			case "suppressorrifle":
				got += GiveValue(e, inv_misc_suppressorrifle, op, val);
				break;
			case "suppressorpdw":
				got += GiveValue(e, inv_misc_suppressorpdw, op, val);
				break;
			case "ak47exmag50":
				got += GiveValue(e, inv_misc_exmag_ak47_50, op, val);
				break;
			case "ak47exmag100":
				got += GiveValue(e, inv_misc_exmag_ak47_100, op, val);
				break;
			case "ak47drum75":
				got += GiveValue(e, inv_misc_drum_ak47_75, op, val);
				break;
			case "ak47mag30":
				got += GiveValue(e, inv_misc_mag_ak47_30, op, val);
				break;
			case "m16mag20":
				got += GiveValue(e, inv_misc_mag_m16_20, op, val);
				break;
			case "m16mag30":
				got += GiveValue(e, inv_misc_mag_m16_30, op, val);
				break;
			case "m16betacmag":
				got += GiveValue(e, inv_misc_betacmag_m16, op, val);
				break;
			case "lightpistolmag":
				got += GiveValue(e, inv_misc_mag_lightpistol, op, val);
				break;
			case "lightpistolexmag":
				got += GiveValue(e, inv_misc_exmag_lightpistol, op, val);
				break;
			case "lightpistoldrum":
				got += GiveValue(e, inv_misc_drum_lightpistol, op, val);
				break;
			case "lightpistolbetacmag":
				got += GiveValue(e, inv_misc_betacmag_lightpistol, op, val);
				break;
			case "pdwtinymag":
				got += GiveValue(e, inv_misc_tinymag_pdw, op, val);
				break;	
			case "pdwsmallmag":
				got += GiveValue(e, inv_misc_smallmag_pdw, op, val);
				break;	
			case "pdwstdmag":
				got += GiveValue(e, inv_misc_stdmag_pdw, op, val);
				break;
			case "pdwexmag40":
				got += GiveValue(e, inv_misc_exmag40_pdw, op, val);
				break;
			case "pdwdrum":
				got += GiveValue(e, inv_misc_drum_pdw, op, val);
				break;
			case "pdwbetacmag":
				got += GiveValue(e, inv_misc_betacmag_pdw, op, val);
				break;
			case "uzimag20":
				got += GiveValue(e, inv_misc_mag_uzi_20, op, val);
				break;
			case "uzimag25":
				got += GiveValue(e, inv_misc_mag_uzi_25, op, val);
				break;
			case "uzimag32":
				got += GiveValue(e, inv_misc_mag_uzi_32, op, val);
				break;
			case "uziexmag40":
				got += GiveValue(e, inv_misc_exmag_uzi_40, op, val);
				break;
			case "uziexmag50":
				got += GiveValue(e, inv_misc_exmag_uzi_50, op, val);
				break;
			case "uzidrum82":
				got += GiveValue(e, inv_misc_drum_uzi_82, op, val);
				break;
			case "uziexmag106":
				got += GiveValue(e, inv_misc_exmag_uzi_106, op, val);
				break;
			case "tec9mag20":
				got += GiveValue(e, inv_misc_mag_tec9_20, op, val);
				break;
			case "tec9mag10":
				got += GiveValue(e, inv_misc_mag_tec9_10, op, val);
				break;
			case "tec9mag32":
				got += GiveValue(e, inv_misc_mag_tec9_32, op, val);
				break;
			case "tec9exmag36":
				got += GiveValue(e, inv_misc_exmag_tec9_36, op, val);
				break;
			case "tec9exmag50":
				got += GiveValue(e, inv_misc_exmag_tec9_50, op, val);
				break;
			case "tec9drum72":
				got += GiveValue(e, inv_misc_drum_tec9_72, op, val);
				break;
			case "ak74exmag45":
				got += GiveValue(e, inv_misc_exmag_ak74_45, op, val);
				break;
			case "ak74mag30":
				got += GiveValue(e, inv_misc_mag_ak74_30, op, val);
				break;
			case "styeraugexmag42":
				got += GiveValue(e, inv_misc_exmag_styeraug_42, op, val);
				break;
			case "styeraugmag30":
				got += GiveValue(e, inv_misc_mag_styeraug_30, op, val);
				break;
			case "barexmag40":
				got += GiveValue(e, inv_misc_exmag_bar_40, op, val);
				break;
			case "barmag20":
				got += GiveValue(e, inv_misc_mag_bar_20, op, val);
				break;
			case "lewisgunpanmag97":
				got += GiveValue(e, inv_misc_panmag_lewisgun_97, op, val);
				break;
			case "lewisgunpanmag47":
				got += GiveValue(e, inv_misc_panmag_lewisgun_47, op, val);
				break;
			case "cylinder_r1856":
			case "cylinderr1856":
			case "cylinder1856":
			case "cylinderrevolver":
			case "revolvercylinder":
				got += GiveValue(e, inv_misc_cylinder_r1856, op, val);
				break;
			case "tin":
				got += GiveValue(e, inv_coin_tin, op, val);
				break;
			case "iron":
				got += GiveValue(e, inv_coin_iron, op, val);
				break;
			case "bronze":
				got += GiveValue(e, inv_coin_bronze, op, val);
				break;
			case "copper":
				got += GiveValue(e, inv_coin_copper, op, val);
				break;
			case "silver":
				got += GiveValue(e, inv_coin_silver, op, val);
				break;
			case "gold":
				got += GiveValue(e, inv_coin_gold, op, val);
				break;
			case "plat":
				got += GiveValue(e, inv_coin_plat, op, val);
				break;
			case "jade":
				got += GiveValue(e, inv_coin_jade, op, val);
				break;
			case "amberium":
				got += GiveValue(e, inv_coin_amberium, op, val);
				break;
			case "fauxtin":
				got += GiveValue(e, inv_coin_f_tin, op, val);
				break;
			case "fauxiron":
				got += GiveValue(e, inv_coin_f_iron, op, val);
				break;
			case "fauxbronze":
				got += GiveValue(e, inv_coin_f_bronze, op, val);
				break;
			case "fauxcopper":
				got += GiveValue(e, inv_coin_f_copper, op, val);
				break;
			case "fauxsilver":
				got += GiveValue(e, inv_coin_f_silver, op, val);
				break;
			case "fauxgold":
				got += GiveValue(e, inv_coin_f_gold, op, val);
				break;
			case "fauxplat":
				got += GiveValue(e, inv_coin_f_plat, op, val);
				break;
			case "fauxjade":
				got += GiveValue(e, inv_coin_f_jade, op, val);
				break;
			case "fauxamberium":
				got += GiveValue(e, inv_coin_f_amberium, op, val);
				break;
			case "counterfeittin":
				got += GiveValue(e, inv_coin_cf_tin, op, val);
				break;
			case "counterfeitiron":
				got += GiveValue(e, inv_coin_cf_iron, op, val);
				break;
			case "counterfeitbronze":
				got += GiveValue(e, inv_coin_cf_bronze, op, val);
				break;
			case "counterfeitcopper":
				got += GiveValue(e, inv_coin_cf_copper, op, val);
				break;
			case "counterfeitsilver":
				got += GiveValue(e, inv_coin_cf_silver, op, val);
				break;
			case "counterfeitgold":
				got += GiveValue(e, inv_coin_cf_gold, op, val);
				break;
			case "counterfeitplat":
				got += GiveValue(e, inv_coin_cf_plat, op, val);
				break;
			case "counterfeitjade":
				got += GiveValue(e, inv_coin_cf_jade, op, val);
				break;
			case "counterfeitamberium":
				got += GiveValue(e, inv_coin_cf_amberium, op, val);
				break;
			case "casinotokenyellow":
				got += GiveValue(e, inv_casinotoken_yellow, op, val);
				break;
			case "casinotokenblue":
				got += GiveValue(e, inv_casinotoken_blue, op, val);
				break;	
			case "casinotokengray":
				got += GiveValue(e, inv_casinotoken_gray, op, val);
				break;	
			case "casinotokenlightgreen":
				got += GiveValue(e, inv_casinotoken_lightgreen, op, val);
				break;
			case "casinotokenlightblue":
				got += GiveValue(e, inv_casinotoken_lightblue, op, val);
				break;
			case "casinotokenrose":
				got += GiveValue(e, inv_casinotoken_rose, op, val);
				break;
			case "casinotokenblack":
				got += GiveValue(e, inv_casinotoken_black, op, val);
				break;
			case "casinotokenseabreeze":
				got += GiveValue(e, inv_casinotoken_seabreeze, op, val);
				break;
			case "casinotokenred":
				got += GiveValue(e, inv_casinotoken_red, op, val);
				break;	
			case "casinotokencyan":
				got += GiveValue(e, inv_casinotoken_cyan, op, val);
				break;	
			case "casinotokentan":
				got += GiveValue(e, inv_casinotoken_tan, op, val);
				break;	
			case "casinotokengreen":
				got += GiveValue(e, inv_casinotoken_green, op, val);
				break;	
			case "casinotokenpurple":
				got += GiveValue(e, inv_casinotoken_purple, op, val);
				break;
			case "ironbar":
				got += GiveValue(e, inv_bar_iron, op, val);
				break;
			case "bronzebar":
				got += GiveValue(e, inv_bar_bronze, op, val);
				break;
			case "copperbar":
				got += GiveValue(e, inv_bar_copper, op, val);
				break;
			case "silverbar":
				got += GiveValue(e, inv_bar_silver, op, val);
				break;
			case "goldbar":
				got += GiveValue(e, inv_bar_gold, op, val);
				break;
			case "platbar":
				got += GiveValue(e, inv_bar_plat, op, val);
				break;
			case "jadebar":
				got += GiveValue(e, inv_bar_jade, op, val);
				break;
			case "amberiumbar":
				got += GiveValue(e, inv_bar_amberium, op, val);
				break;
			case "fauxironbar":
				got += GiveValue(e, inv_bar_f_iron, op, val);
				break;
			case "fauxbronzebar":
				got += GiveValue(e, inv_bar_f_bronze, op, val);
				break;
			case "fauxcopperbar":
				got += GiveValue(e, inv_bar_f_copper, op, val);
				break;
			case "fauxsilverbar":
				got += GiveValue(e, inv_bar_f_silver, op, val);
				break;
			case "fauxgoldbar":
				got += GiveValue(e, inv_bar_f_gold, op, val);
				break;
			case "fauxplatbar":
				got += GiveValue(e, inv_bar_f_plat, op, val);
				break;
			case "fauxjadebar":
				got += GiveValue(e, inv_bar_f_jade, op, val);
				break;
			case "fauxamberiumbar":
				got += GiveValue(e, inv_bar_f_amberium, op, val);
				break;
			case "diamond":
				got += GiveValue(e, inv_gem_diamond, op, val);
				break;
			case "jacinth":
				got += GiveValue(e, inv_gem_jacinth, op, val);
				break;
			case "ruby":
				got += GiveValue(e, inv_gem_ruby, op, val);
				break;
			case "peridot":
				got += GiveValue(e, inv_gem_peridot, op, val);
				break;
			case "emerald":
				got += GiveValue(e, inv_gem_emerald, op, val);
				break;
			case "topaz":
				got += GiveValue(e, inv_gem_topaz, op, val);
				break;
			case "sapphire":
				got += GiveValue(e, inv_gem_sapphire, op, val);
				break;
			case "chalcedony":
				got += GiveValue(e, inv_gem_chalcedony, op, val);
				break;
			case "agate":
				got += GiveValue(e, inv_gem_agate, op, val);
				break;
			case "onyx":
				got += GiveValue(e, inv_gem_onyx, op, val);
				break;
			case "mithril":
				got += GiveValue(e, inv_gem_mithril, op, val);
				break;
			case "amethyst":
				got += GiveValue(e, inv_gem_amethyst, op, val);
				break;
			case "chrysoberyl":
				got += GiveValue(e, inv_gem_chrysoberyl, op, val);
				break;
			case "aquamarine":
				got += GiveValue(e, inv_gem_aquamarine, op, val);
				break;
			case "quartz":
				got += GiveValue(e, inv_gem_quartz, op, val);
				break;
			case "tourmaline":
				got += GiveValue(e, inv_gem_tourmaline, op, val);
				break;
			case "pearl":
				got += GiveValue(e, inv_gem_pearl, op, val);
				break;
			case "blackpearl":
				got += GiveValue(e, inv_gem_blackpearl, op, val);
				break;
			case "fauxdiamond":
				got += GiveValue(e, inv_gem_f_diamond, op, val);
				break;
			case "fauxjacinth":
				got += GiveValue(e, inv_gem_f_jacinth, op, val);
				break;
			case "fauxruby":
				got += GiveValue(e, inv_gem_f_ruby, op, val);
				break;
			case "fauxperidot":
				got += GiveValue(e, inv_gem_f_peridot, op, val);
				break;
			case "fauxemerald":
				got += GiveValue(e, inv_gem_f_emerald, op, val);
				break;
			case "fauxtopaz":
				got += GiveValue(e, inv_gem_f_topaz, op, val);
				break;
			case "fauxsapphire":
				got += GiveValue(e, inv_gem_f_sapphire, op, val);
				break;
			case "fauxchalcedony":
				got += GiveValue(e, inv_gem_f_chalcedony, op, val);
				break;
			case "fauxagate":
				got += GiveValue(e, inv_gem_f_agate, op, val);
				break;
			case "fauxonyx":
				got += GiveValue(e, inv_gem_f_onyx, op, val);
				break;
			case "fauxmithril":
				got += GiveValue(e, inv_gem_f_mithril, op, val);
				break;
			case "fauxamethyst":
				got += GiveValue(e, inv_gem_f_amethyst, op, val);
				break;
			case "fauxchrysoberyl":
				got += GiveValue(e, inv_gem_f_chrysoberyl, op, val);
				break;
			case "fauxaquamarine":
				got += GiveValue(e, inv_gem_f_aquamarine, op, val);
				break;
			case "fauxquartz":
				got += GiveValue(e, inv_gem_f_quartz, op, val);
				break;
			case "fauxtourmaline":
				got += GiveValue(e, inv_gem_f_tourmaline, op, val);
				break;
			case "fauxpearl":
				got += GiveValue(e, inv_gem_f_pearl, op, val);
				break;
			case "fauxblackpearl":
				got += GiveValue(e, inv_gem_f_blackpearl, op, val);
				break;
			case "cutglass":
			case "whitecutglass":
			case "whiteglass":
				got += GiveValue(e, inv_gem_glass_w, op, val);
				break;
			case "redcutglass":
			case "redglass":
				got += GiveValue(e, inv_gem_glass_r, op, val);
				break;
			case "greencutglass":
			case "greenglass":
				got += GiveValue(e, inv_gem_glass_g, op, val);
				break;
			case "bluecutglass":
			case "blueglass":
				got += GiveValue(e, inv_gem_glass_b, op, val);
				break;
			case "yellowcutglass":
			case "yellowglass":
				got += GiveValue(e, inv_gem_glass_y, op, val);
				break;
			default:
				for(j = WEP_FIRST; j <= WEP_LAST; ++j)
				{
					wi = get_weaponinfo(j);
					if(cmd == wi.netname)
					{
						got += GiveWeapon(e, j, op, val);
						break;
					}
				}
				if(j > WEP_LAST)
					print("give: invalid item ", cmd, "\n");
				break;
		}
		val = 999;
		op = OP_SET;
	}

	POSTGIVE_BIT(e, items, IT_FUEL_REGEN, "misc/itempickup.wav", string_null);
	POSTGIVE_BIT(e, items, IT_UNLIMITED_SUPERWEAPONS, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_UNLIMITED_WEAPON_AMMO, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_BIT(e, items, IT_JETPACK, "misc/itempickup.wav", string_null);
	for(j = WEP_FIRST; j <= WEP_LAST; ++j)
	{
		wi = get_weaponinfo(j);
		if(wi.weapon)
		{
			POSTGIVE_WEAPON(e, j, "weapons/weaponpickup.wav", string_null);
			if not(WEPSET_CONTAINS_AW(save_weapons, j))
				if(WEPSET_CONTAINS_EW(e, j))
					weapon_action(wi.weapon, WR_PRECACHE);
		}
	}
	POSTGIVE_VALUE(e, strength_finished, 1, "misc/powerup.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, invincible_finished, 1, "misc/powerup_shield.wav", "misc/poweroff.wav");
	POSTGIVE_VALUE(e, ammo_nails, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_cells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_shells, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE(e, ammo_rockets, 0, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, ammo_fuel, 1, pauserotfuel_finished, autocvar_g_balance_pause_fuel_rot, pauseregen_finished, autocvar_g_balance_pause_fuel_regen, "misc/itempickup.wav", string_null);
	POSTGIVE_VALUE_ROT(e, armorvalue, 1, pauserotarmor_finished, autocvar_g_balance_pause_armor_rot, pauseregen_finished, autocvar_g_balance_pause_health_regen, "misc/armor25.wav", string_null);
	POSTGIVE_VALUE_ROT(e, health, 1, pauserothealth_finished, autocvar_g_balance_pause_health_rot, pauseregen_finished, autocvar_g_balance_pause_health_regen, "misc/megahealth.wav", string_null);

	if(e.superweapons_finished <= 0)
		if(WEPSET_CONTAINS_ANY_EA(self, WEPBIT_SUPERWEAPONS))
			e.superweapons_finished = autocvar_g_balance_superweapons_time;

	if (g_minstagib)
	{
		e.health = bound(0, e.health, 100);
		e.armorvalue = bound(0, e.armorvalue, 999);
	}

	if(e.strength_finished <= 0)
		e.strength_finished = 0;
	else
		e.strength_finished += time;
	if(e.invincible_finished <= 0)
		e.invincible_finished = 0;
	else
		e.invincible_finished += time;
	if(e.superweapons_finished <= 0)
		e.superweapons_finished = 0;
	else
		e.superweapons_finished += time;

	if not(WEPSET_CONTAINS_EW(e, e.switchweapon))
		_switchweapon = TRUE;
	if(_switchweapon)
		W_SwitchWeapon_Force(e, w_getbestweapon(e));

	return got;
}
#endif
