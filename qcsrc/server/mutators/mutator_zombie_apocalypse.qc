float autocvar_g_za_monster_ogre_amnt;
float autocvar_g_za_monster_demon_amnt;
float autocvar_g_za_monster_shambler_amnt;
float autocvar_g_za_monster_knight_amnt;
float autocvar_g_za_monster_soldier_amnt;
float autocvar_g_za_monster_scrag_amnt;
float autocvar_g_za_monster_dog_amnt;
float autocvar_g_za_monster_spawn_amnt;
float autocvar_g_za_monster_hellknight_amnt;
float autocvar_g_za_monster_fish_amnt;
float autocvar_g_za_monster_vore_amnt;
float autocvar_g_za_monster_enforcer_amnt;
float autocvar_g_za_monster_zombie_amnt;
float autocvar_g_za_monster_spawner_amnt;
float autocvar_g_za_monster_spider_amnt;
float autocvar_g_za_monster_skeleton_amnt;
float autocvar_g_za_monster_minotaur_amnt;
float autocvar_g_za_monster_goblin_amnt;
float autocvar_g_za_monster_wolf_amnt;
float autocvar_g_za_monster_golem_amnt;
float autocvar_g_za_monster_police_amnt;
float autocvar_g_za_monster_royalguard_amnt;
float autocvar_g_za_monster_imp_amnt;
float autocvar_g_za_monster_biledemon_amnt;
float autocvar_g_za_monster_wyvern_amnt;
float autocvar_g_za_monster_seraph_amnt;
float autocvar_g_za_monster_fighter_amnt;
float autocvar_g_za_monster_ninjaassassin_amnt;
float autocvar_g_za_monster_shinrae_amnt;
float autocvar_g_za_monster_horndemon_amnt;
float autocvar_g_za_monster_aocyborg_amnt;
float autocvar_g_za_monster_blackdeath_amnt;
float autocvar_g_za_monster_rottingcorpse_amnt;

float autocvar_g_za_spawnnearteam; //0, 1, 2, 3, 4
float autocvar_g_za_spawnnearteam_setteamto; //Set monster's team to spawnnearteam setting
float autocvar_g_za_spawnnearteam_showteam; //Show your team colors as a za spawned monster?

float autocvar_g_za_usezlimits; //Set limits for Z?//Should be on by default

float autocvar_g_za_maxz; //player set limits, if non 0
float autocvar_g_za_minz; //player set limits, if non 0
float autocvar_g_za_spawnatinfonotnull; //player set: spawn at info not nulls rather than spawnpoints, for darkhold etc
float autocvar_g_za_alwaysspawnatpoint; //Always spawn at a spawnpoint (or an info_notnull), not random area

float autocvar_g_suggested_za_maxz; //Map Suggested limits, if non 0 //Don't set both
float autocvar_g_suggested_za_minz; //Map Suggested limits, if non 0 //Don't set both
float autocvar_g_suggested_za_zlimitsearchfor; //0 == player, 1 == nothing, 2 == not null
float autocvar_g_suggested_za_spawnatinfonotnull; //spawn at info not nulls rather than spawnpoints, for darkhold etc
float autocvar_g_suggested_za_alwaysspawnatpoint; //Always spawn at a spawnpoint (or an info_notnull), not random area

float autocvar_g_za_noitemdrop;
//float autocvar_g_za_monster_count_add;
float autocvar_g_za_round_time;
//float autocvar_g_za_monster_types;
float g_za_monster_round_current;
float g_za_monster_count_current;
float g_za;
float za_numspawns;

float Za_MoveToRandomMapLocation(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance)
{
	local float myreturn;
	local float mysearchfor;
	local float myhavesetalimit;
	local vector mymins;
	local vector mymaxs;
	
	if ((!autocvar_g_za_usezlimits) || (!autocvar_g_za_maxz &&
	!autocvar_g_za_minz &&
	!autocvar_g_suggested_za_maxz &&
	!autocvar_g_suggested_za_minz))
	{
		myreturn = MoveToRandomMapLocation(e, goodcontents, badcontents, badsurfaceflags, attempts, maxaboveground, minviewdistance);
		//if (myreturn) {
		//	print("NormalPlacement\n");
		//}
	} else {
		myhavesetalimit = 0;
		mymins = world.mins;
		mymaxs = world.maxs;
			
		if (autocvar_g_za_maxz) {
			myhavesetalimit = autocvar_g_za_maxz;
			mymaxs_z = autocvar_g_za_maxz;
		} else if (autocvar_g_suggested_za_maxz) {
			myhavesetalimit = autocvar_g_suggested_za_maxz;
			mymaxs_z = autocvar_g_suggested_za_maxz;
		}
		
		if (autocvar_g_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_za_minz) {
				print("NOT DOING ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_za_minz;
			}
		} else if (autocvar_g_suggested_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_suggested_za_minz) {
				print("NOT DOING SUGGESTED ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_suggested_za_minz;
			}
		}
		
		//0 == player start, 1 == nothing, 2 == info_notnull (darkhold etc)
		if (autocvar_g_suggested_za_zlimitsearchfor == 1) {
			mysearchfor = 1;
		} else if (autocvar_g_suggested_za_zlimitsearchfor == 2) {
			mysearchfor = 2;
		} else if (autocvar_g_suggested_za_zlimitsearchfor > 2) {
			mysearchfor = 0;
		} else if (autocvar_g_suggested_za_zlimitsearchfor < 0) {
			mysearchfor = 0;	
		} else {
			mysearchfor = 0;
		}
		
		myreturn = MoveToRandomMapLocationLimits(e, goodcontents, badcontents, badsurfaceflags, attempts, maxaboveground, minviewdistance, mymins, mymaxs, mysearchfor);
							
		//if (myreturn) {
		//	print("FoundSomePlaceToPut\n");
		//}
	}
	return myreturn;
}

vector Za_Select_Spawn_PointChoose(float menviro)
{
	entity e = spawn();
	e.mins = '-20 -20 -20';
	e.maxs = '20 20 20';
	//setorigin(e, '0 0 0');

	if (menviro == 1) {
		//Spawn in water only
		// tries 50 times then gives up, that's what the number 50 stands for
		if(Za_MoveToRandomMapLocation(e, DPCONTENTS_WATER, DPCONTENTS_LAVA | DPCONTENTS_SLIME | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER | DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, Q3SURFACEFLAG_SKY, 50, 0, 1))
		{
			// yay we found a suitable location!
			vector selected_origin = e.origin;
			remove(e);
			//print("^4SUCCESS: we found a suitable location.\n");
			return selected_origin;
		}
		else
		{
			//print("^4NOSUCCESS: we found no suitable location.\n");
			// no place found, better luck next time
			remove(e);
			return '0 0 0';
		}
	} else if (menviro == 2) {
		//Spawn in water or slime
		// tries 50 times then gives up, that's what the number 50 stands for
		float i;
		i = 0;
    		if(Za_MoveToRandomMapLocation(e, DPCONTENTS_WATER | DPCONTENTS_SLIME, DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER | DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, Q3SURFACEFLAG_SKY, 50, 0, 1))
		{
			// yay we found a suitable location!
			vector selected_origin = e.origin;
			remove(e);
			//print("^4SUCCESS: we found a suitable location.\n");
			return selected_origin;
		}
		else
		{
			//print("^4NOSUCCESS: we found no suitable location.\n");
			// no place found, better luck next time
			remove(e);
			return '0 0 0';
		}
	} else if (menviro == 3) {
		//Spawn in lava only
		// tries 50 times then gives up, that's what the number 50 stands for
		if(Za_MoveToRandomMapLocation(e, DPCONTENTS_LAVA, DPCONTENTS_WATER | DPCONTENTS_SLIME | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER | DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, Q3SURFACEFLAG_SKY, 50, 0, 1))
		{
			// yay we found a suitable location!
			vector selected_origin = e.origin;
			remove(e);
			//print("^4SUCCESS: we found a suitable location.\n");
			return selected_origin;
		}
		else
		{
			// no place found, better luck next time
			remove(e);
			return '0 0 0';
		}
	} else if (menviro == 4) {
		//Spawn in regular or lava. Not water tho
		// tries 50 times then gives up, that's what the number 10 stands for
		if(Za_MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP | DPCONTENTS_LAVA, DPCONTENTS_SLIME | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER | DPCONTENTS_WATER, Q3SURFACEFLAG_SKY, 50, 128, 1))
		{
			// yay we found a suitable location!
			vector selected_origin = e.origin;
			remove(e);
			//print("^4SUCCESS: we found a suitable location.\n");
			return selected_origin;
		}
		else
		{
			// no place found, better luck next time
			remove(e);
			return '0 0 0';
		}
	} else {
		//Spawn regular
		// tries 10 times then gives up, that's what the number 10 stands for
		if(Za_MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1))
		{
			// yay we found a suitable location!
			vector selected_origin = e.origin;
			remove(e);
			//print("^4SUCCESS: we found a suitable location.\n");
			return selected_origin;
		}
		else
		{
			// no place found, better luck next time
			remove(e);
			return '0 0 0';
		}
	}
}


vector Za_Select_Spawn_Point(float menviro)
{
	local float counter2;
	local float ex;
	local vector myorigin;
	myorigin = '0 0 0';
	ex = 0;
	counter2 = 0;
	while (ex != 1) {
		myorigin = Za_Select_Spawn_PointChoose(menviro);
		if (SMI_AbdBld_BuildNearBase(autocvar_g_za_spawnnearteam, myorigin))
		{
			ex = 1; //Exit
			//print("Za: Found spawn point, exit were good\n");
		} else {
			myorigin = '0 0 0';
			if (counter2 > 20) {
				ex = 1; //Exit
				//print("Za: Did not find spawn point exit were not good\n");
			}
		}
		counter2 = counter2 + 1;
	}
	
	return myorigin;
}



float PickZombieSpawnValidateLimits (vector myorigin)
{			
		if (autocvar_g_za_maxz) {
			if (myorigin_z > autocvar_g_za_maxz) {
				return FALSE;
			}
		} else if (autocvar_g_suggested_za_maxz) {
			if (myorigin_z > autocvar_g_suggested_za_maxz) {
				return FALSE;
			}
		}
		
		if (autocvar_g_za_minz) {
			if (myorigin_z < autocvar_g_za_minz) {
				return FALSE;
			}
		} else if (autocvar_g_suggested_za_minz) {
				if (myorigin_z < autocvar_g_suggested_za_minz) {
				return FALSE;
			}
		}
		
		return TRUE;
}


entity PickZombieSpawnChoose()
{
	entity sp;
	
	RandomSelection_Init();
	
	if (autocvar_g_za_spawnatinfonotnull == 1)
	{
		for(sp = world; (sp = find(sp, classname, "info_notnull")); )
		{
			if (PickZombieSpawnValidateLimits(sp.origin)) {
				//Just doing this for the info not nulls for now, don't want to mess up the defaults below
				//print("Valid\n");
				RandomSelection_Add(sp, 0, string_null, 1, 1);
			}
		}
	} else if (!autocvar_g_za_spawnatinfonotnull && autocvar_g_suggested_za_spawnatinfonotnull)
	{
		//If g_za_spawnatinfonotnull is not set but g_suggested_za_spawnatinfonotnull is
		//Otherwise if g_za_spawnatinfonotnull is set to anything other than 1 do the default below
		for(sp = world; (sp = find(sp, classname, "info_notnull")); )
		{
			if (PickZombieSpawnValidateLimits(sp.origin)) {
				//print("Valid\n");
				RandomSelection_Add(sp, 0, string_null, 1, 1);
			}
		}
	}
	else if(teamplay)
	{
		if (0.5 > random()) {
			for(sp = world; (sp = find(sp, classname, "info_player_team1")); )
			{
				RandomSelection_Add(sp, 0, string_null, 1, 1);
			}
		} else {
			for(sp = world; (sp = find(sp, classname, "info_player_team2")); )
			{
				RandomSelection_Add(sp, 0, string_null, 1, 1);
			}
		}
	}
	else
	{
		for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
		{
			RandomSelection_Add(sp, 0, string_null, 1, 1);
		}
	}
	
	return RandomSelection_chosen_ent;
}

entity PickZombieSpawn()
{
	local float counter2;
	local float ex;
	local entity myent;
	myent = world;
	ex = 0;
	counter2 = 0;
	while (ex != 1) {
		myent = PickZombieSpawnChoose();
		if (SMI_AbdBld_BuildNearBase(autocvar_g_za_spawnnearteam, myent.origin))
		{
			ex = 1; //Exit
			//print("Za: Picked SpawnPoint exit were good\n");
		} else {
			myent = world;
			if (counter2 > 20) {
				ex = 1; //Exit
				//print("Za: Did not Pick Spawn point, exit were not good\n");
			}
		}
		counter2 = counter2 + 1;
	}
	
	return myent;	
}

void zombie_spawn_somewhere ()
{
    if(gameover) { return; }
    float i;
    i = 0;
    while (i == 0) {
    //Untill Za_MoveToRandomMapLocation finds a location, we are going to loop.
    
    	float nospawn = 0;
    	entity mon, sp;
	vector selected_origin = '0 0 0';
	
	if((Za_MoveToRandomMapLocation(self, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 1024, 256))
	&&
	SMI_AbdBld_BuildNearBase(autocvar_g_za_spawnnearteam, self.origin)
	)
	{
		float mrandvar;
		float menviro;
		
		if (cvar("g_za_monster_types") < 1) {
		//Ratio way
			
			string mstring;
			//monster list "ogre demon shambler knight soldier scrag dog spawn hellknight fish vore enforcer zombie spawner spider skeleton minotaur goblin wolf golem police royalguard imp biledemon wyvern seraph fighter ninjaassassin shinrae horndemon aocyborg rottingcorpse blackdeath"
			
			menviro = 0; //Regular spawn place
			mrandvar = random() *
			(autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			+ autocvar_g_za_monster_horndemon_amnt
			+ autocvar_g_za_monster_aocyborg_amnt
			+ autocvar_g_za_monster_blackdeath_amnt
			+ autocvar_g_za_monster_rottingcorpse_amnt
			);
		
			if (mrandvar < autocvar_g_za_monster_ogre_amnt) {
				mstring = "ogre";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			)) {
				mstring = "demon";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			)) {
				mstring = "shambler";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			)) {
				mstring = "knight";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			)) {
				mstring = "soldier";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			)) {
				mstring = "scrag";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			)) {
				mstring = "dog";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			)) {
				mstring = "spawn";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			)) {
				mstring = "hellknight";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			)) {
				mstring = "fish";
				menviro = 2; //Water or Slime
				selected_origin = Za_Select_Spawn_Point(menviro);
				if(selected_origin != '0 0 0')
				{
					self.origin = selected_origin;
				} else {
					nospawn = 1;
				}
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			)) {
				mstring = "vore";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			)) {
				mstring = "enforcer";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			)) {
				mstring = "zombie";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			)) {
				mstring = "spawner";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			)) {
				mstring = "spider";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			)) {
				mstring = "skeleton";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			)) {
				mstring = "minotaur";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			)) {
				mstring = "goblin";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			)) {
				mstring = "wolf";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			)) {
				mstring = "golem";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			)) {
				mstring = "police";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			)) {
				mstring = "royalguard";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			)) {
				mstring = "imp";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			)) {
				mstring = "biledemon";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			)) {
				mstring = "wyvern";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			)) {
				mstring = "seraph";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			)) {
				mstring = "fighter";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			)) {
				mstring = "ninjaassassin";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			)) {
				mstring = "shinrae";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			+ autocvar_g_za_monster_horndemon_amnt
			)) {
				mstring = "horndemon";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			+ autocvar_g_za_monster_horndemon_amnt
			+ autocvar_g_za_monster_aocyborg_amnt
			)) {
				mstring = "aocyborg";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			+ autocvar_g_za_monster_horndemon_amnt
			+ autocvar_g_za_monster_aocyborg_amnt
			+ autocvar_g_za_monster_blackdeath_amnt
			)) {
				mstring = "blackdeath";
			} else if (mrandvar < (
			autocvar_g_za_monster_ogre_amnt
			+ autocvar_g_za_monster_demon_amnt
			+ autocvar_g_za_monster_shambler_amnt
			+ autocvar_g_za_monster_knight_amnt
			+ autocvar_g_za_monster_soldier_amnt
			+ autocvar_g_za_monster_scrag_amnt
			+ autocvar_g_za_monster_dog_amnt
			+ autocvar_g_za_monster_spawn_amnt
			+ autocvar_g_za_monster_hellknight_amnt
			+ autocvar_g_za_monster_fish_amnt
			+ autocvar_g_za_monster_vore_amnt
			+ autocvar_g_za_monster_enforcer_amnt
			+ autocvar_g_za_monster_zombie_amnt
			+ autocvar_g_za_monster_spawner_amnt
			+ autocvar_g_za_monster_spider_amnt
			+ autocvar_g_za_monster_skeleton_amnt
			+ autocvar_g_za_monster_minotaur_amnt
			+ autocvar_g_za_monster_goblin_amnt
			+ autocvar_g_za_monster_wolf_amnt
			+ autocvar_g_za_monster_golem_amnt
			+ autocvar_g_za_monster_police_amnt
			+ autocvar_g_za_monster_royalguard_amnt
			+ autocvar_g_za_monster_imp_amnt
			+ autocvar_g_za_monster_biledemon_amnt
			+ autocvar_g_za_monster_wyvern_amnt
			+ autocvar_g_za_monster_seraph_amnt
			+ autocvar_g_za_monster_fighter_amnt
			+ autocvar_g_za_monster_ninjaassassin_amnt
			+ autocvar_g_za_monster_shinrae_amnt
			+ autocvar_g_za_monster_horndemon_amnt
			+ autocvar_g_za_monster_aocyborg_amnt
			+ autocvar_g_za_monster_blackdeath_amnt
			+ autocvar_g_za_monster_rottingcorpse_amnt
			)) {
				mstring = "rottingcorpse";
			} else {
				//Failsafe
				mstring = "zombie";
			}
			
			if not (nospawn == 1) 
				mon = spawnmonster(mstring, self, self, self.origin, TRUE, 2);
		} else {
		//List way
		  if (cvar("g_za_monster_types") == 1) {
			//Zombies
			mon = spawnmonster("zombie", self, self, self.origin, TRUE, 2);
		  } else if (cvar("g_za_monster_types") == 2) {
			//Dogs
			mon = spawnmonster("dog", self, self, self.origin, TRUE, 2);
		  } else if (cvar("g_za_monster_types") == 3) {
			//Dogs and zombies
			mrandvar = random();
			if (mrandvar > 0.70) {
				mon = spawnmonster("dog", self, self, self.origin, TRUE, 2);
			} else {
				mon = spawnmonster("zombie", self, self, self.origin, TRUE, 2);
			}
		  } else if (cvar("g_za_monster_types") == 4) {
			//Shamblers and zombies
			mrandvar = random();
			if (mrandvar > 0.25) {
				mon = spawnmonster("shambler", self, self, self.origin, TRUE, 2);
			} else {
				mon = spawnmonster("zombie", self, self, self.origin, TRUE, 2);
			}
		  } else if (cvar("g_za_monster_types") == 5) {
			//Dogs and people
			mrandvar = random();
			if (mrandvar > 0.70) {
				mon = spawnmonster("enforcer", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.30) {
				mon = spawnmonster("soldier", self, self, self.origin, TRUE, 2);		
			} else {
				mon = spawnmonster("dog", self, self, self.origin, TRUE, 2);
			}
		  } else if (cvar("g_za_monster_types") == 6) {
			//Dogs and quests
			mrandvar = random();
			if (mrandvar > 0.70) {
				mon = spawnmonster("hellknight", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.30) {
				mon = spawnmonster("knight", self, self, self.origin, TRUE, 2);		
			} else {
				mon = spawnmonster("dog", self, self, self.origin, TRUE, 2);
			}
		  } else {
			//Almost Everything
			//monster list "ogre demon shambler knight soldier scrag dog spawn hellknight fish vore enforcer zombie spawner spider"
			mrandvar = random();
			if (mrandvar > .95) {
				mon = spawnmonster("shambler", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.90) {
				mon = spawnmonster("hellknight", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.80) {
				mon = spawnmonster("vore", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.70) {
				mon = spawnmonster("demon", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.60) {
				mon = spawnmonster("scrag", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.50) {
				mon = spawnmonster("knight", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.40) {
				mon = spawnmonster("ogre", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.35) {
				mon = spawnmonster("zombie", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.30) {
				mon = spawnmonster("spawn", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.25) {
				mon = spawnmonster("scrag", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.20) {
				mon = spawnmonster("enforcer", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.15) {
				mon = spawnmonster("skeleton", self, self, self.origin, TRUE, 2);
			} else if (mrandvar > 0.10) {
				mon = spawnmonster("soldier", self, self, self.origin, TRUE, 2);		
			} else {
				mon = spawnmonster("dog", self, self, self.origin, TRUE, 2);
			}
		  }
		}
		
		if (autocvar_g_za_noitemdrop) {
			if (autocvar_g_za_noitemdrop >= 1) {
				mon.monster_noitemdrop = 1;
			} else if (autocvar_g_za_noitemdrop > random())
			{
				mon.monster_noitemdrop = 1;
			}
		}
		
		if not(nospawn == 1) {
		   tracebox(mon.origin, mon.mins, mon.maxs, mon.origin, MOVE_NOMONSTERS, mon);
		
		   if(trace_startsolid)
		   {
			float randvar;
			if (g_za_monster_round_current > 50) {
				randvar = random() * 2 * g_za_monster_round_current;
				//Keep it at 50/50 infiltration/random spawn for past round 50
			} else {
				randvar = random() * 100;
			}
			
			if (autocvar_g_za_alwaysspawnatpoint == 1) {
				sp = PickZombieSpawn();
				if(sp) {
					mon.origin = sp.origin;
				}
			} else if (!autocvar_g_za_alwaysspawnatpoint && autocvar_g_suggested_za_alwaysspawnatpoint) {
				//If g_za_alwaysspawnatpoint is set but not to 1, we force default over suggested
				//But if it's not set but suggested is set, we pick a spawn point (or info_notnull)
				//(if the proper vars are set)etc, not random area
				//Important for some maps that have alot of blank space between walls within
				//the confines of the map bounds (darkhold etc) but have alot of spawnpoints or info_notnulls
				sp = PickZombieSpawn();
				if(sp) {
					mon.origin = sp.origin;
				}
			} else if (g_za_monster_round_current > randvar) {
				//More rounds more likely zombies will spawn at your spawn!
				sp = PickZombieSpawn();
				if(sp) {
					mon.origin = sp.origin;
				}
			} else {		
				selected_origin = Za_Select_Spawn_Point(menviro);
				if(selected_origin != '0 0 0')
				{
					mon.origin = selected_origin;
				}
			}
		   }
			
        	   za_numspawns += 1;
		}
		i = 1;
	}
	else
	{
		i = 0; //Try Again
	}

    }
}

void za_zeroout ()
{
	g_za_monster_count_current = 0;
}

void spawn_zombies ()
{
  if (g_za) {
	float numzoms;
	entity x;
    
	print("More of the dead arise\n");

	if (g_za_monster_round_current == 0) {
		numzoms = cvar("g_za_monster_count");
	} else {
		numzoms = cvar("g_za_monster_count_add");
		//They don't seem to be removed when you kill them, so just add more
	}

	if (autocvar_g_monsters) {
	//////////
	while(numzoms > 0)
	{
        	x = spawn();
		
		if (teamplay) {
		 if (autocvar_g_za_spawnnearteam_setteamto) {
		  if (autocvar_g_za_spawnnearteam)
		  {
		  	x.classname = "zatspwn";
			if (autocvar_g_za_spawnnearteam_showteam) {
				x.monster_noteamcolors = 0;
			} else {
				x.monster_noteamcolors = 1;
			}
			
			if (autocvar_g_za_spawnnearteam == 1)
				x.team = COLOR_TEAM1;
			else if (autocvar_g_za_spawnnearteam == 2)
				x.team = COLOR_TEAM2;
			else if (autocvar_g_za_spawnnearteam == 3)
				x.team = COLOR_TEAM3;
			else if (autocvar_g_za_spawnnearteam == 4)
				x.team = COLOR_TEAM4;
		  	
		  }
		 }
		}
		
		x.think = zombie_spawn_somewhere;
        	x.nextthink = time;

		numzoms -= 1;
	}
	//////////
	}
	g_za_monster_round_current = g_za_monster_round_current + 1;

	self.nextthink = time + autocvar_g_za_round_time;
	//if(self) { //Remove init? Na, we'll use it
	//       remove(self);
	//}
  }
}

void za_init ()
{
	entity e;
    
	e = spawn();
	e.think = spawn_zombies;
	e.nextthink = time + 3; //Start in 3 seconds
}

MUTATOR_HOOKFUNCTION(Zombies_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Zombie Apocalypse");
	return 0;
}

MUTATOR_HOOKFUNCTION(Zombies_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Zombie Apocalypse");
	return 0;
}

MUTATOR_HOOKFUNCTION(Zombies_MatchEnd)
{
	za_zeroout();
	return TRUE;
}

MUTATOR_DEFINITION(mutator_zombie_apocalypse)
{
	MUTATOR_HOOK(MatchEnd, Zombies_MatchEnd, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, Zombies_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, Zombies_BuildMutatorsPrettyString, CBC_ORDER_ANY);
    
    MUTATOR_ONADD
    {
        za_init();
	g_za = 1;
    }
    
    MUTATOR_ONREMOVE
    {
    	g_za = 0;
    }

	return 0;
}
