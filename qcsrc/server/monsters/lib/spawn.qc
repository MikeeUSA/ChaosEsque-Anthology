float autocvar_g_monsters_giants_only;

float spawnmonster_checkinlist(string monster, string list)
{
	string l = strcat(" ", list, " ");
	
	if(strstrofs(l, strcat(" ", monster, " "), 0) >= 0)
		return TRUE;
	
	return FALSE;
}

entity spawnmonster (string monster, entity spawnedby, entity own, vector orig, float respwn, float moveflag)
{
	if not(autocvar_g_monsters)
	{
		if(spawnedby.flags & FL_CLIENT)
			sprint(spawnedby, "Monsters are disabled. Enable g_monsters to spawn monsters\n");
		return world;
	}
	
	if(spawnedby.vehicle) // no vehicle player spawning...
		return world;
	
	if(!spawncode_first_load)
	{
		initialize_field_db();
		spawncode_first_load = TRUE;
	}
	
	entity e = spawn();
	
	e.spawnflags = MONSTERFLAG_SPAWNED;
	
	if not(respwn)
		e.spawnflags |= MONSTERFLAG_NORESPAWN;
	
	e.origin = orig;
	e.stoneskin = -1; //Changed in spawn() for those that have a stoneskin
	
	if not(spawnmonster_checkinlist(monster, monsterlist()))
		monster = "knight";
	
	if (monster == "spider")
		e.scale = 0.01 + (random() * 0.25);
	
	e.realowner = spawnedby;
	
	if(moveflag)
		e.monster_moveflags = moveflag;
	
	if (spawnedby.classname == "monster_swarm")
		e.monster_owner = own;  
	else if(spawnedby.flags & FL_CLIENT)
	{
		if(teamplay && autocvar_g_monsters_teams)
			e.team = spawnedby.team; // colors handled in spawn code
			
		if not(teamplay)
			e.colormap = spawnedby.colormap;
			
		if(autocvar_g_monsters_owners)
			e.monster_owner = own;
			
		e.angles = spawnedby.angles;
	}
	else if(spawnedby.classname == "zatspwn")
	{
		//We're a zombie apocalypse team-monster spawner
		if(teamplay && autocvar_g_monsters_teams) {
			e.team = spawnedby.team; // colors handled in spawn code
			e.monster_noteamcolors = spawnedby.monster_noteamcolors;
		}
	}
	
	if(autocvar_g_monsters_giants_only)
		e.spawnflags |= MONSTERFLAG_GIANT;
		
	monster = strcat("$ spawnfunc_monster_", monster);
		
	target_spawn_edit_entity(e, monster, world, world, world, world, world);
		
	return e;
}
