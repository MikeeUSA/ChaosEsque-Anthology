//For setting a single-player esque spawns in DM etc matches.
void spawnfunc_info_player_team1();
void spawnfunc_info_player_team2();
void spawnfunc_info_player_team3();
void spawnfunc_info_player_team4();
float arena_roundbased;
vector Za_Select_Spawn_Point(float menviro);
entity Spawn_WeightedPoint(entity firstspot, float lower, float upper, float exponent);
entity Spawn_FilterOutBadSpots(entity firstspot, float mindist, float teamcheck);
entity SelectSpawnPoint (float anypoint);

entity questspawns_SelectBotOnlySpawnPoint (float anypoint)
{
	//Finds a deactivated point to respawn bots at

	float teamcheck;
	entity spot, firstspot;

	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

	if(anypoint || autocvar_g_spawn_useallspawns)
		teamcheck = -1;
	else if(have_team_spawns > 0)
	{
		if(have_team_spawns_forteam[self.team] == 0)
		{
			// we request a spawn for a team, and we have team
			// spawns, but that team has no spawns?
			if(have_team_spawns_forteam[0])
				// try noteam spawns
				teamcheck = 0;
			else
				// if not, any spawn has to do
				teamcheck = -1;
		}
		else
			teamcheck = self.team; // MUST be team
	}
	else if(have_team_spawns == 0 && have_team_spawns_forteam[0])
		teamcheck = 0; // MUST be noteam
	else
		teamcheck = -1;
		// if we get here, we either require team spawns but have none, or we require non-team spawns and have none; use any spawn then


	// get the entire list of spots
	firstspot = findchain(classname, "deactivatedinfoplayerdeathmatch");
	// filter out the bad ones
	// (note this returns the original list if none survived)
	if(anypoint)
	{
		spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
	}
	else
	{
		float mindist;
		if (arena_roundbased && !g_ca)
			mindist = 800;
		else
			mindist = 100;
		firstspot = Spawn_FilterOutBadSpots(firstspot, mindist, teamcheck);

		// there is 50/50 chance of choosing a random spot or the furthest spot
		// (this means that roughly every other spawn will be furthest, so you
		// usually won't get fragged at spawn twice in a row)
		if (random() > autocvar_g_spawn_furthest)
			spot = Spawn_WeightedPoint(firstspot, 1, 1, 1);
		else
			spot = Spawn_WeightedPoint(firstspot, 1, 5000, 5); // chooses a far far away spawnpoint
	}

	if (!spot)
	{
		spot = SelectSpawnPoint (TRUE); //Fallback
	}

	return spot;
}

float questspawns_spawnpoint_countall(void)
{
	local float nspawnpointcount;
	entity nspawnpoint;
	for(nspawnpoint = world; (nspawnpoint = find(nspawnpoint, classname, "info_player_deathmatch")); )
	{
		nspawnpointcount += 1;
	}
		
	return nspawnpointcount;
}

vector questspawns_spawnpoint_chooserandom(float mytotalspawns)
{
	local vector mychosenorigin;
	mychosenorigin = '0 0 0';
	entity nspawnpoint;
	for(nspawnpoint = world; (nspawnpoint = find(nspawnpoint, classname, "info_player_deathmatch")); )
	{
		if (nspawnpoint != world) {
			if (random() < 1/mytotalspawns) {
				return mychosenorigin;
			}
			mychosenorigin = nspawnpoint.origin;
		}
	}
		
	return mychosenorigin;
}

void questspawns_spawnpoint_deactall(void)
{
	entity nspawnpoint;
	for(nspawnpoint = world; (nspawnpoint = find(nspawnpoint, classname, "info_player_deathmatch")); )
	{
		if (nspawnpoint != world) {
			//print("G_QUESTSPAWNS: DEEEACTIVVVATIIIIIIIIIIIIIIINNNNEEEGGGGGGGGGGGGGG\n");
			nspawnpoint.classname = "deactivatedinfoplayerdeathmatch"; //Could re-use later
		}
	}
}

vector questspawns_makespawns(vector myspawnpt, float mamt, float myteam)
{
	entity oldself;
	entity newspawn, newspawn2, newspawn3, newspawn4, newspawn5;
	oldself = self;

	newspawn = spawn();
	newspawn.origin = myspawnpt;
	
	self = newspawn;
	self.angles_y = -180+(random()*360);
	
	if (myteam == 1)
		spawnfunc_info_player_team1();
	else if (myteam == 2)
		spawnfunc_info_player_team2();
	else
		spawnfunc_info_player_deathmatch();
		
	makevectors(self.angles);
	traceline(self.origin, self.origin + v_forward * mamt, MOVE_NORMAL, self);
	
	//
	newspawn2 = spawn();
	newspawn2.origin = trace_endpos;
	self = newspawn2;
	self.angles_y = -180+(random()*360);
	
	if (myteam == 1)
		spawnfunc_info_player_team1();
	else if (myteam == 2)
		spawnfunc_info_player_team2();
	else
		spawnfunc_info_player_deathmatch();
	
	traceline(self.origin, self.origin + v_forward * -1 * mamt, MOVE_NORMAL, self);
	
	//
	newspawn3 = spawn();
	newspawn3.origin = trace_endpos;
	self = newspawn3;
	self.angles_y = -180+(random()*360);
	
	if (myteam == 1)
		spawnfunc_info_player_team1();
	else if (myteam == 2)
		spawnfunc_info_player_team2();
	else
		spawnfunc_info_player_deathmatch();
	
	traceline(self.origin, self.origin + v_right * mamt, MOVE_NORMAL, self);
	
	//
	newspawn4 = spawn();
	newspawn4.origin = trace_endpos;
	self = newspawn4;
	self.angles_y = -180+(random()*360);
	
	if (myteam == 1)
		spawnfunc_info_player_team1();
	else if (myteam == 2)
		spawnfunc_info_player_team2();
	else
		spawnfunc_info_player_deathmatch();
	
	traceline(self.origin, self.origin + v_right * -1 * mamt, MOVE_NORMAL, self);
	
	
	//
	newspawn5 = spawn();
	newspawn5.origin = trace_endpos;
	self = newspawn5;
	self.angles_y = -180+(random()*360);
	
	if (myteam == 1)
		spawnfunc_info_player_team1();
	else if (myteam == 2)
		spawnfunc_info_player_team2();
	else
		spawnfunc_info_player_deathmatch();
	
	
	self = oldself;
	return trace_endpos;
}

void questspawns_do(void)
{
	local float mn;
	local float mamt;
	local vector mvec, mvec2;
		
	mn = questspawns_spawnpoint_countall();
	
	if ((!autocvar_g_questspawns_startx
	&& !autocvar_g_questspawns_starty
	&& !autocvar_g_questspawns_startz
	) || (autocvar_g_questspawns == 2))
	{
		print("G_QUESTSPAWNS: USING RANDOM PICKED SPAWN\n");
		mvec = questspawns_spawnpoint_chooserandom(mn);
	}
	else if (autocvar_g_questspawns == 3)
	{
		print("G_QUESTSPAWNS: USING RANDOM SPAWN\n");
		mvec = Za_Select_Spawn_Point(0);
		if(mvec == '0 0 0')
		{
			mvec = questspawns_spawnpoint_chooserandom(mn);		
		}
	}
	else if (autocvar_g_questspawns == 4)
	{
		print("G_QUESTSPAWNS: USING RANDOM WATER SPAWN OR RANDOM SPAWN\n");
		mvec = Za_Select_Spawn_Point(1);
		if(mvec == '0 0 0')
		{
			mvec = Za_Select_Spawn_Point(1);
		}
		if(mvec == '0 0 0')
		{
			mvec = Za_Select_Spawn_Point(1);
		}
		if(mvec == '0 0 0')
		{
			mvec = Za_Select_Spawn_Point(1);
		}
		if(mvec == '0 0 0')
		{
			mvec = Za_Select_Spawn_Point(0);
		}
		if(mvec == '0 0 0')
		{
			mvec = questspawns_spawnpoint_chooserandom(mn);		
		}
	}
	else
	{
		print("G_QUESTSPAWNS: Using Set Spawns\n");
		mvec_x = autocvar_g_questspawns_startx;
		mvec_y = autocvar_g_questspawns_starty;
		mvec_z = autocvar_g_questspawns_startz;
	}
	
	questspawns_spawnpoint_deactall();
	
	mvec2 = questspawns_makespawns(mvec, autocvar_g_questspawns_spread+(random()*autocvar_g_questspawns_spread), 0);
	if (teamplay) {
		mvec2 = questspawns_makespawns(mvec2, autocvar_g_questspawns_spread2+(random()*autocvar_g_questspawns_spread2), 1);
		mvec2 = questspawns_makespawns(mvec2, autocvar_g_questspawns_spread+(random()*autocvar_g_questspawns_spread), 2);
	}
	
	self.think = func_null;
	self.nextthink = 0;
	remove(self);
}

void questspawns_setup(void)
{
	entity questspawnthinker;
	entity oldself;
	
	oldself = self;
	
	questspawnthinker = spawn();
	
	self = questspawnthinker;
	self.think = questspawns_do;
	self.nextthink = time;
	//print(ftos(self.nextthink)," G_QUESTSPAWNS NEXTTHINK\n");
	self = oldself;
}

void g_questspawns(void)
{
	if (autocvar_g_questspawns)
	{
		questspawns_setup();
	}
}


///////////////////////////////////////////////////////////////////////////
//Here is for when we want to spawn in some more spawns randomly:

void randomadditionalspawns_loop(void)
{
	entity e;
	entity myolderself;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1))
	{
		myolderself = self;
		self = e;
		
		if (g_ctf || g_onslaught || g_assault) {
			//For now we'll just do the two, untill we find a better way to
			//detect number of teams (will have to root around in the code)
			//print("Spawn Team start\n");
			if (random() > 0.5) {
				spawnfunc_info_player_team1();
			} else {
				spawnfunc_info_player_team2();
			}
		} else {
			//print("Spawn Player start\n");
			spawnfunc_info_player_deathmatch();
		}
		
		//If quest spawns are enabled, we don't override them
		if (autocvar_g_questspawns) {
			if(autocvar_g_randomadditionalspawns && autocvar_g_randomadditionalspawns_ignore_g_questspawns) {
				//Do nothing if _not_ map suggested and instead set by player AND we are told to ignore
			} else {
				print("^2Deactivating - g_questspawns is enabled\n");
				self.classname = "deactivatedinfoplayerdeathmatch"; //Could re-use later (by bots etc)
			}
		}
		
		self = myolderself;
		if (autocvar_g_randomadditionalspawns) {
			print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional spawn\n");
		} else {
			print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional spawn\n");
		}
	} else {
		print("^4FAIL: no location for random additional spawn found\n");
		remove(e);
	}
}

void randomadditionalspawns_do (void)
{
	float i;
	
	if (autocvar_g_randomadditionalspawns) {
		//Overrides
		i = autocvar_g_randomadditionalspawns;
	} else {
		i = autocvar_g_suggested_randomadditionalspawns;
	}
	
	if (i > 1000) {
		print("^4RandomAdditionalSpawns set too high, setting to 1000\n");
		i = 1000; //Don't want to use too many ents.
	}
	
	while (i) {
		randomadditionalspawns_loop();
		i = i - 1;
	}
	remove(self);
}

void randomadditionalspawns_setup(void)
{
	//Got to wait till next frame, server doesn't know about map yet
	entity randomadditionalspawnsthinker;
	entity oldself;
	
	oldself = self;
	
	randomadditionalspawnsthinker = spawn();
	
	self = randomadditionalspawnsthinker;
	self.think = randomadditionalspawns_do;
	self.nextthink = time;
	//print(ftos(self.nextthink)," G_randomadditionalspawns NEXTTHINK\n");
	self = oldself;
}

void g_randomadditionalspawns(void)
{
	if (autocvar_g_randomadditionalspawns || autocvar_g_suggested_randomadditionalspawns)
	{
		randomadditionalspawns_setup();
	}
}


//Lets not error out when a bot trys to use a captured point
void failsafespawns_do(void)
{
	//print("Searching For FailSafe Spawns\n");
	entity nspawnpoint;
	for(nspawnpoint = world; (nspawnpoint = find(nspawnpoint, classname, "info_player_deathmatch")); )
	{
		if (nspawnpoint != world) {
			if (nspawnpoint.team == COLOR_TEAM1) {
				//print("Recording Failsafe Spawn T1\n");
				if (!failsafespawn0_team1found) {
					failsafespawn0_team1 = nspawnpoint;
					failsafespawn0_team1found = 1;
				} else if (!failsafespawn1_team1found) {
					failsafespawn1_team1 = nspawnpoint;
					failsafespawn1_team1found = 1;
				} 
			} else if (nspawnpoint.team == COLOR_TEAM2) {
				//print("Recording Failsafe Spawn T2\n");
				if (!failsafespawn0_team2found) {
					failsafespawn0_team2 = nspawnpoint;
					failsafespawn0_team2found = 1;
				} else if (!failsafespawn1_team2found) {
					failsafespawn1_team2 = nspawnpoint;
					failsafespawn1_team2found = 1;
				} 
			} else if (nspawnpoint.team == COLOR_TEAM3) {
				//print("Recording Failsafe Spawn T3\n");
				if (!failsafespawn0_team3found) {
					failsafespawn0_team3 = nspawnpoint;
					failsafespawn0_team3found = 1;
				} else if (!failsafespawn1_team3found) {
					failsafespawn1_team3 = nspawnpoint;
					failsafespawn1_team3found = 1;
				} 
			} else if (nspawnpoint.team == COLOR_TEAM4) {
				//print("Recording Failsafe Spawn T4\n");
				if (!failsafespawn0_team4found) {
					failsafespawn0_team4 = nspawnpoint;
					failsafespawn0_team4found = 1;
				} else if (!failsafespawn1_team4found) {
					failsafespawn1_team4 = nspawnpoint;
					failsafespawn1_team4found = 1;
				} 
			} else {
				//print("Recording Failsafe Spawn Generic\n");
				if (!failsafespawn0found) {
					failsafespawn0 = nspawnpoint;
					failsafespawn0found = 1;
				} else if (!failsafespawn1found) {
					failsafespawn1 = nspawnpoint;
					failsafespawn1found = 1;
				} else if (!failsafespawn2found) {
					failsafespawn2 = nspawnpoint;
					failsafespawn2found = 1;
				} else if (!failsafespawn3found) {
					failsafespawn3 = nspawnpoint;
					failsafespawn3found = 1;
				} 
			}
		
		}
	}
}


void failsafespawns_setup(void)
{
	//Got to wait till next frame, server doesn't know about map yet
	entity failsafespawnsthinker;
	entity oldself;
	
	oldself = self;
	
	failsafespawnsthinker = spawn();
	
	self = failsafespawnsthinker;
	self.think = failsafespawns_do;
	self.nextthink = time;
	//print(ftos(self.nextthink)," G_failsafespawns NEXTTHINK\n");
	self = oldself;
}

void failsafespawns_zeroout(void)
{
	failsafespawn0 = world;
	failsafespawn1 = world;
	failsafespawn2 = world;
	failsafespawn3 = world;
	failsafespawn0found = 0;
	failsafespawn1found = 0;
	failsafespawn2found = 0;
	failsafespawn3found = 0;

	failsafespawn0_team1 = world;
	failsafespawn1_team1 = world;
	failsafespawn0_team2 = world;
	failsafespawn1_team2 = world;
	failsafespawn0_team3 = world;
	failsafespawn1_team3 = world;
	failsafespawn0_team4 = world;
	failsafespawn1_team4 = world;
	failsafespawn0_team1found = 0;
	failsafespawn1_team1found = 0;
	failsafespawn0_team2found = 0;
	failsafespawn1_team2found = 0;
	failsafespawn0_team3found = 0;
	failsafespawn1_team3found = 0;
	failsafespawn0_team4found = 0;
	failsafespawn1_team4found = 0;
}

void g_failsafespawns(void)
{
		failsafespawns_zeroout();
		failsafespawns_setup();
}

entity failsafespawns_give(entity player)
{
	entity myspawnspot;
	float gaveaspawnpoint;
	gaveaspawnpoint = 0;
	if (g_ctf || g_onslaught || g_assault) {
		if (player.team == COLOR_TEAM1) {
			if (failsafespawn0_team1found && failsafespawn1_team1found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team1;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team1;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team1found) {
				myspawnspot = failsafespawn0_team1;
				gaveaspawnpoint = 1;
			}
		} else if (player.team == COLOR_TEAM2) {
			if (failsafespawn0_team2found && failsafespawn1_team2found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team2;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team2;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team2found) {
				myspawnspot = failsafespawn0_team2;
				gaveaspawnpoint = 1;
			}
		} else if (player.team == COLOR_TEAM3) {
			if (failsafespawn0_team3found && failsafespawn1_team3found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team3;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team3;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team3found) {
				myspawnspot = failsafespawn0_team3;
				gaveaspawnpoint = 1;
			}
		} else if (player.team == COLOR_TEAM4) {
			if (failsafespawn0_team4found && failsafespawn1_team4found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team4;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team4;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team4found) {
				myspawnspot = failsafespawn0_team4;
				gaveaspawnpoint = 1;
			}
		}
	}
	
	if not(myspawnspot) {
		gaveaspawnpoint = 0;
	}
	
	if (myspawnspot == world) {
		gaveaspawnpoint = 0;
	}
	
	if (gaveaspawnpoint) {
		print("RETURNING FAILSAFE TEAMSPAWN\n");
		return myspawnspot;
	}
		
	
	if (failsafespawn0found && failsafespawn1found && failsafespawn2found && failsafespawn3found)
	{
		if (random() > 0.75) {
			myspawnspot = failsafespawn0;
			gaveaspawnpoint = 1;
		} else if (random() > 0.50) {
			myspawnspot = failsafespawn1;
			gaveaspawnpoint = 1;
		} else if (random() > 0.25) {
			myspawnspot = failsafespawn2;
			gaveaspawnpoint = 1;
		} else {
			myspawnspot = failsafespawn3;
			gaveaspawnpoint = 1;
		}
	} else if (failsafespawn0found && failsafespawn1found && failsafespawn2found)
	{
		if (random() > 0.66) {
			myspawnspot = failsafespawn0;
			gaveaspawnpoint = 1;
		} else if (random() > 0.33) {
			myspawnspot = failsafespawn1;
			gaveaspawnpoint = 1;
		} else {
			myspawnspot = failsafespawn2;
			gaveaspawnpoint = 1;
		}
	} else if (failsafespawn0found && failsafespawn1found)
	{
		if (random() > 0.5) {
			myspawnspot = failsafespawn0;
			gaveaspawnpoint = 1;
		} else {
			myspawnspot = failsafespawn1;
			gaveaspawnpoint = 1;
		}	
	} else if (failsafespawn0found) {
		myspawnspot = failsafespawn0;
		gaveaspawnpoint = 1;
	//These shouldn't happen.. but we'll try
	} else if (failsafespawn1found) {
		myspawnspot = failsafespawn1;
		gaveaspawnpoint = 1;
	} else if (failsafespawn2found) {
		myspawnspot = failsafespawn2;
		gaveaspawnpoint = 1;
	} else if (failsafespawn3found) {
		myspawnspot = failsafespawn3;
		gaveaspawnpoint = 1;
	}		
	
	if not(myspawnspot) {
		gaveaspawnpoint = 0;
	}
	
	if (myspawnspot == world) {
		gaveaspawnpoint = 0;
	}
				
	if (gaveaspawnpoint) {
		print("RETURNING FAILSAFE SPAWN\n");
		return myspawnspot;
	}
	
	//OK so there are no regular spawns and we are not a teamgame that uses team spawns
	//maybe there are teamspawns we can use
	
	if (g_ctf || g_onslaught || g_assault) {
		//Nothing
	} else {
			if (failsafespawn0_team1found && failsafespawn1_team1found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team1;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team1;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team1found) {
				myspawnspot = failsafespawn0_team1;
				gaveaspawnpoint = 1;
			} else if (failsafespawn0_team2found && failsafespawn1_team2found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team2;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team2;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team2found) {
				myspawnspot = failsafespawn0_team2;
				gaveaspawnpoint = 1;
			} else if (failsafespawn0_team3found && failsafespawn1_team3found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team3;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team3;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team3found) {
				myspawnspot = failsafespawn0_team3;
				gaveaspawnpoint = 1;
			} else if (failsafespawn0_team4found && failsafespawn1_team4found)
			{
				if (random() > 0.5) {
					myspawnspot = failsafespawn0_team4;
					gaveaspawnpoint = 1;
				} else {
					myspawnspot = failsafespawn1_team4;
					gaveaspawnpoint = 1;
				}	
			} else if (failsafespawn0_team4found) {
				myspawnspot = failsafespawn0_team4;
				gaveaspawnpoint = 1;
			}	
	}
	
	if not(myspawnspot) {
		gaveaspawnpoint = 0;
	}
	
	if (myspawnspot == world) {
		gaveaspawnpoint = 0;
	}
	
	if (gaveaspawnpoint) {
		print("RETURNING FAILSAFE TEAMSPAWN IN NON TEAMSPAWN USING GAME MODE\n");
		return myspawnspot;
	}
	
	print("UNABLE TO FIND FAILSAFE SPAWN\n");
	return world;	
}

////////////////////////////////////////////
//Here we will create a spawn if need be
////////////////////////////////////////////

void failsafespawn_create_do(entity player, entity e)
{
		entity myolderself;
		
		myolderself = self;
		self = e;
		
		if (g_ctf || g_onslaught || g_assault) {
			//Reasons why it might not help
			//(for next spawn after this one atleast):
			//There are settings which can reverse the team of the 
			//spawnpoints.
			//In such a case, if the other team never trys to respawn,
			//We'll have alot of spawnpoints for them!
			if (player.team == COLOR_TEAM1) {
				spawnfunc_info_player_team1();
			} else if (player.team == COLOR_TEAM2) {
				spawnfunc_info_player_team2();
			} else if (player.team == COLOR_TEAM3) {
				spawnfunc_info_player_team3();
			} else if (player.team == COLOR_TEAM4) {
				spawnfunc_info_player_team4();
			} else {
				spawnfunc_info_player_deathmatch();
			}
		} else {
			spawnfunc_info_player_deathmatch();
		}
		
		self = myolderself;

}

void failsafespawn_create_do_ignoreteam(entity player, entity e)
{
		entity myolderself;
		
		myolderself = self;
		self = e;

		spawnfunc_info_player_deathmatch();
		
		self = myolderself;

}


entity failsafespawn_create(entity player)
{
	entity e;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on try 2\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on try 3\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on try 4\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on try 5\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on try 7\n");
		return e;
	} else {
		print("^4FAIL: no location for failsafe spawn found\n");
		remove(e);
		return world;
	}
}

entity failsafespawn_create_ignoreteam(entity player)
{
	entity e;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 2\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 3\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 4\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 5\n");
		return e;
	} else if(MoveToRandomMapLocationLimits(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 7\n");
		return e;
	} else {
		print("^4FAIL: no location for failsafe ignoreteam spawn found\n");
		remove(e);
		return world;
	}
}

entity failsafespawn_createsimple(entity player)
{
	entity e;
	entity myolderself;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs, TRUE))
	{
		myolderself = self;
		self = e;
		
		spawnfunc_info_player_deathmatch();
		
		self = myolderself;

		print(vtos(e.origin)," ^4SUCCESS: we created a simple failsafe spawn\n");
		return e;
	} else {
		print("^4FAIL: no location for simple failsafe spawn found\n");
		remove(e);
		return world;
	}
}




//Map is completely barren?

entity failsafespawn_create_barren(entity player)
{
	entity e;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 2\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 3\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 4\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 5\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 7\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRulesCanStartInSolid(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe spawn on barren map on try 8 -CanStartInSolid-\n");
		return e;
	} else {
		print("^4FAIL: no location for failsafe spawn on barren map found\n");
		remove(e);
		return world;
	}
}

entity failsafespawn_create_ignoreteam_barren(entity player)
{
	entity e;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 2 on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 3 on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 4 on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID, DPCONTENTS_SKY, Q3SURFACEFLAG_SKY, 20, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 5 on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRules(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 7 on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRulesCanStartInSolid(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs))
	{
		failsafespawn_create_do_ignoreteam(player, e);

		print(vtos(e.origin)," ^4SUCCESS: we created a failsafe ignoreteam spawn on try 8 -CanStartInSolid- on barren map\n");
		return e;
	} else {
		print("^4FAIL: no location for failsafe ignoreteam spawn on barren map found\n");
		remove(e);
		return world;
	}
}

entity failsafespawn_createsimple_barren(entity player)
{
	entity e;
	entity myolderself;
	e = spawn();
	e.mins = PL_MIN;
	e.maxs = PL_MAX;
	if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 128, 1, world.mins, world.maxs))
	{
		myolderself = self;
		self = e;
		
		spawnfunc_info_player_deathmatch();
		
		self = myolderself;

		print(vtos(e.origin)," ^4SUCCESS: we created a simple failsafe spawn on barren map\n");
		return e;
	} else if(MoveToRandomMapLocationLimitsFewRulesCanStartInSolid(e, 0, 0, 0, 10, 128, 1, world.mins, world.maxs))
	{
		myolderself = self;
		self = e;
		
		spawnfunc_info_player_deathmatch();
		
		self = myolderself;

		print(vtos(e.origin)," ^4SUCCESS: we created a simple failsafe -CanStartInSolid- spawn on barren map\n");
		return e;
	} else {
		print("^4FAIL: no location for simple failsafe spawn on barren map found\n");
		remove(e);
		return world;
	}
}






///////////////////////////////////////////////////////////////////////////
//Here is for when we want to spawn in some more weapons randomly:
float weapon_medievalreplacement(void);
float weapon_standardxonoticreplacement(void);
float weapon_moderngunsreplacement(void);
float weapon_moderngunscivilianreplacement(void);
float weapon_explosivesreplacement(void);
float weapon_energyreplacement(void);
float weapon_moderntoolsreplacement(void);
float weapon_oldwestreplacement(void);
float weapon_wwireplacement(void);
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

float randomadditionalweapons_chooseweapon(float mytype)
{
	local float myrandom;
	local float mywpn;
	mywpn = 0;
	//0 == normal
	//1 == energy
	//2 == explosives 
	//3 == legal guns
	//4 == mod guns
	//5 == mod tools
	//6 == mod guns, legal guns, mod explosives, mod energy, mod tools
	//7 == WWI guns
	//8 == Old West guns
	//9 == medeval
	
	//-9999 = additional processing needed 
	if (mytype == -9999) {
			//The additionals are 0...1... in range
			
			//Thus we use 1 for the baseline for original
			//print("Per spawn weapon rand choice\n");
			
			local float brandvar;
			brandvar = random() * (
			1
			+ autocvar_g_randomadditionalweapons1
			+ autocvar_g_randomadditionalweapons2
			+ autocvar_g_randomadditionalweapons3
			+ autocvar_g_randomadditionalweapons4
			+ autocvar_g_randomadditionalweapons5
			+ autocvar_g_randomadditionalweapons6
			+ autocvar_g_randomadditionalweapons7
			+ autocvar_g_randomadditionalweapons8
			+ autocvar_g_randomadditionalweapons9);
			
			if (brandvar <= 1) {
				mytype = autocvar_g_randomadditionalweapons_type;
			} else if ((autocvar_g_randomadditionalweapons1 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1)) {
				mytype = autocvar_g_randomadditionalweapons1_type;
			} else if ((autocvar_g_randomadditionalweapons2 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2)) {
				mytype = autocvar_g_randomadditionalweapons2_type;
			} else if ((autocvar_g_randomadditionalweapons3 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3)) {
				mytype = autocvar_g_randomadditionalweapons3_type;
			} else if ((autocvar_g_randomadditionalweapons4 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4)) {
				mytype = autocvar_g_randomadditionalweapons4_type;
			} else if ((autocvar_g_randomadditionalweapons5 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4
				+ autocvar_g_randomadditionalweapons5)) {
				mytype = autocvar_g_randomadditionalweapons5_type;
			} else if ((autocvar_g_randomadditionalweapons6 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4
				+ autocvar_g_randomadditionalweapons5
				+ autocvar_g_randomadditionalweapons6)) {
				mytype = autocvar_g_randomadditionalweapons6_type;
			} else if ((autocvar_g_randomadditionalweapons7 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4
				+ autocvar_g_randomadditionalweapons5
				+ autocvar_g_randomadditionalweapons6
				+ autocvar_g_randomadditionalweapons7)) {
				mytype = autocvar_g_randomadditionalweapons7_type;
			} else if ((autocvar_g_randomadditionalweapons8 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4
				+ autocvar_g_randomadditionalweapons5
				+ autocvar_g_randomadditionalweapons6
				+ autocvar_g_randomadditionalweapons7
				+ autocvar_g_randomadditionalweapons8)) {
				mytype = autocvar_g_randomadditionalweapons8_type;
			} else if ((autocvar_g_randomadditionalweapons9 > 0) && brandvar <= (1
				+ autocvar_g_randomadditionalweapons1
				+ autocvar_g_randomadditionalweapons2
				+ autocvar_g_randomadditionalweapons3
				+ autocvar_g_randomadditionalweapons4
				+ autocvar_g_randomadditionalweapons5
				+ autocvar_g_randomadditionalweapons6
				+ autocvar_g_randomadditionalweapons7
				+ autocvar_g_randomadditionalweapons8
				+ autocvar_g_randomadditionalweapons9)) {
				mytype = autocvar_g_randomadditionalweapons9_type;
				
			} else {
				//Shouldn't get here
				print("Random additional weapons Fallback - Shouldn't get here\n");
				mytype = autocvar_g_randomadditionalweapons_type;
			}
	}
	
	if (mytype == 1) {
		mywpn = weapon_energyreplacement();
	} else if (mytype == 2) {
		mywpn = weapon_explosivesreplacement();
	} else if (mytype == 3) {
		mywpn = weapon_moderngunscivilianreplacement();
	} else if (mytype == 4) {
		mywpn = weapon_moderngunsreplacement();
	} else if (mytype == 5) {
		mywpn = weapon_moderntoolsreplacement();
	} else if (mytype == 6) {
		myrandom = random();
		if (myrandom > 0.8) {
			mywpn = weapon_moderngunsreplacement();
		} else if (myrandom > 0.65) {
			mywpn = weapon_moderngunscivilianreplacement();
		} else if (myrandom > 0.55) {
			mywpn = weapon_explosivesreplacement();
		} else if (myrandom > 0.2) {
			mywpn = weapon_energyreplacement();
		} else {
			mywpn = weapon_moderntoolsreplacement();
		}
	} else if (mytype == 7) {
		mywpn = weapon_wwireplacement();
	} else if (mytype == 8) {
		mywpn = weapon_oldwestreplacement();		
	} else if (mytype == 9) {
		mywpn = weapon_medievalreplacement();
	} else {
		//0
		mywpn = weapon_standardxonoticreplacement();
	}
	
	return mywpn;
}

void randomadditionalweapons_loop(float mytype, vector mymins, vector mymaxs, float mysearchfor)
{
	local float mywpn;
	entity e;
	entity myolderself;
	e = spawn();
	//e.mins = PL_MIN;
	//e.maxs = PL_MAX;
	//2qu off ground max:
	//if(MoveToRandomMapLocation(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 2, 1))
	if (mysearchfor != -1) {
		//Used with ZA limits (map specified etc)
		if(MoveToRandomMapLocationLimits(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 100, 2, 1, mymins, mymaxs, mysearchfor))
		{
			myolderself = self;
			self = e;
			
				//self.angles_x = 0;
				//self.angles_y = 0;
				//self.angles_z = 0;
				self.absolute = 1; //Used to not do weaponreplace on weapons only
				
				mywpn = randomadditionalweapons_chooseweapon(mytype);
				weapon_defaultspawnfunc(mywpn);
			
			self = myolderself;
			if (autocvar_g_randomadditionalweapons) {
				print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional weapon. Using Za limits\n");
			} else {
				print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional weapon. Using Za limits\n");
			}
		} else {
			print("^4FAIL: no location for random additional weapon found. Using Za limits\n");
			remove(e);
		}
	} else {
		//Normal
		if(MoveToRandomMapLocationLimitsFewRules(e, DPCONTENTS_SOLID | DPCONTENTS_CORPSE | DPCONTENTS_PLAYERCLIP, DPCONTENTS_SLIME | DPCONTENTS_LAVA | DPCONTENTS_WATER | DPCONTENTS_SKY | DPCONTENTS_BODY | DPCONTENTS_DONOTENTER, Q3SURFACEFLAG_SKY, 10, 2, 1, mymins, mymaxs))
		{
			myolderself = self;
			self = e;
			
				//self.angles_x = 0;
				//self.angles_y = 0;
				//self.angles_z = 0;
				self.absolute = 1; //Used to not do weaponreplace on weapons only
				
				mywpn = randomadditionalweapons_chooseweapon(mytype);
				weapon_defaultspawnfunc(mywpn);
			
			self = myolderself;
			if (autocvar_g_randomadditionalweapons) {
				print(vtos(e.origin)," ^4SUCCESS: we found a suitable location for random additional weapon\n");
			} else {
				print(vtos(e.origin)," ^3SUCCESS: we found a suitable location for map suggested random additional weapon\n");
			}
		} else {
			print("^4FAIL: no location for random additional weapon found\n");
			remove(e);
		}
	}
}

void randomadditionalweapons_do (void)
{
	float i;
	float mytype;
	local float myreturn;
	local float mysearchfor;
	local float myhavesetalimit;
	local vector mymins;
	local vector mymaxs;
	
	if (autocvar_g_randomadditionalweapons) {
		//Overrides
		i = autocvar_g_randomadditionalweapons;
		mytype = autocvar_g_randomadditionalweapons_type;
		
		//The additionals are 0...1...2 in range
		//Thus we use 1 for the baseline for original
		if (autocvar_g_randomadditionalweapons1
		|| autocvar_g_randomadditionalweapons2
		|| autocvar_g_randomadditionalweapons3
		|| autocvar_g_randomadditionalweapons4
		|| autocvar_g_randomadditionalweapons5
		|| autocvar_g_randomadditionalweapons6
		|| autocvar_g_randomadditionalweapons7
		|| autocvar_g_randomadditionalweapons8
		|| autocvar_g_randomadditionalweapons9) {
			mytype = -9999;
		}
	} else {
		i = autocvar_g_suggested_randomadditionalweapons;
		mytype = autocvar_g_suggested_randomadditionalweapons_type;
	}
	
	if (i > 1000) {
		print("^4RandomAdditionalWeapons set too high, setting to 1000\n");
		i = 1000; //Don't want to use too many ents.
	}
	
	if (autocvar_g_randomadditionalweapons_ignore_za_limits) {
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
	} else if ((!autocvar_g_za_usezlimits) || (!autocvar_g_za_maxz &&
	!autocvar_g_za_minz &&
	!autocvar_g_suggested_za_maxz &&
	!autocvar_g_suggested_za_minz))
	{
		mymins = world.mins;
		mymaxs = world.maxs;
		mysearchfor = -1;
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
				print("G_RANDOMADDITIONALWEAPONS NOT DOING ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
			} else {
				mymins_z = autocvar_g_za_minz;
			}
		} else if (autocvar_g_suggested_za_minz) {
			if (myhavesetalimit && myhavesetalimit <= autocvar_g_suggested_za_minz) {
				print("G_RANDOMADDITIONALWEAPONS NOT DOING SUGGESTED ZA MIN LIMIT: MAX LIMIT ALLREADY SET TO SAME OR BELOW MIN, WILL INFINITE LOOP OTHERWISE\n");
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
		
	}
	
	while (i) {
		randomadditionalweapons_loop(mytype, mymins, mymaxs, mysearchfor);
		i = i - 1;
	}
	remove(self);
}

void randomadditionalweapons_setup(void)
{
	entity randomadditionalweaponthinker;
	entity oldself;
	
	oldself = self;
	
	randomadditionalweaponthinker = spawn();
	
	self = randomadditionalweaponthinker;
	self.think = randomadditionalweapons_do;
	
	if (autocvar_g_randomadditionalweapons) {
		//Overrides
		self.nextthink = time + autocvar_g_randomadditionalweapons_wait;
	} else {
		self.nextthink = time + autocvar_g_suggested_randomadditionalweapons_wait;
	}
	
	//print(ftos(self.nextthink)," G_RANDOMADDITIONALWEAPONS NEXTTHINK\n");
	self = oldself;
}

void g_randomadditionalweapons(void)
{
	if (autocvar_g_randomadditionalweapons || autocvar_g_suggested_randomadditionalweapons)
	{
		randomadditionalweapons_setup();
	}
}

void g_randomadditionalitems(void); //Declared here for benifit of g_world.qc, in g_randomadditionalitems.qc
void g_rndmaddtnlfurn(void); //Declared here for benifit of g_world.qc, in g_rndmaddtnlfurn.qc



///////////////////////////////////////////////////////////////////////////
//Ambient Temperature
//So you can burn or freeze
//Temp is in centigrade
float sfalqdlvl(string mycvar, string altcvar);
float Fire_AddDamage(entity e, entity o, float d, float t, float dt);
void Freeze (entity targ, float freeze_time, float paralysis);
float multitool_iswooden(float mytype);
.entity multitool_hitbox;
.entity fire_burner;
.float fire_endtime;

float ambient_temperature_entitywithinlimits(entity ent)
{
	if (!ambient_temperature_uselimits) {
		return TRUE; //Bail out early, no limits set, temp applys to all
	}
	
	if(
	(ent.origin_x < ambient_temperature_maxx) &&
	(ent.origin_y < ambient_temperature_maxy) &&
	(ent.origin_z < ambient_temperature_maxz) &&
	(ent.origin_x > ambient_temperature_minx) &&
	(ent.origin_y > ambient_temperature_miny) &&
	(ent.origin_z > ambient_temperature_minz)
	) {
		if (ambient_temperature_uselimits_reverse) {
			return FALSE; //Warm within limit, ambient outside limit
		} else {
			return TRUE; //Ambient inside limit
		}
	}
	
	if (ambient_temperature_uselimits_reverse) {
		return TRUE; //Ambient outside limit
	}
	
	return FALSE;
}

void ambient_temperature_setlimits(void)
{
	if (autocvar_g_ambient_temperature_uselimits) {
		ambient_temperature_uselimits = 1;
		if (autocvar_g_ambient_temperature_uselimits_reverse) {
			ambient_temperature_uselimits_reverse = 1;
		} else {
			ambient_temperature_uselimits_reverse = 0;
		}
	} else {
		ambient_temperature_uselimits = 0;
		ambient_temperature_uselimits_reverse = 0;
	}
	
	if (autocvar_g_ambient_temperature_maxx) {
		ambient_temperature_maxx = autocvar_g_ambient_temperature_maxx;
	} else {
		ambient_temperature_maxx = world.maxs_x;
	}
	
	
	if (autocvar_g_ambient_temperature_maxy) {
		ambient_temperature_maxy = autocvar_g_ambient_temperature_maxy;
	} else {
		ambient_temperature_maxy = world.maxs_y;
	}
	
	
	if (autocvar_g_ambient_temperature_maxz) {
		ambient_temperature_maxz = autocvar_g_ambient_temperature_maxz;
	} else {
		ambient_temperature_maxz = world.maxs_z;
	}
	
	if (autocvar_g_ambient_temperature_minx) {
		ambient_temperature_minx = autocvar_g_ambient_temperature_minx;
	} else {
		ambient_temperature_minx = world.mins_x;
	}
	
	if (autocvar_g_ambient_temperature_miny) {
		ambient_temperature_miny = autocvar_g_ambient_temperature_miny;
	} else {
		ambient_temperature_miny = world.mins_y;
	}
	
	if (autocvar_g_ambient_temperature_minz) {
		ambient_temperature_minz = autocvar_g_ambient_temperature_minz;
	} else {
		ambient_temperature_minz = world.mins_z;
	}
}

void ambient_temperature_setlimits_suggested(void)
{
	if (autocvar_g_suggested_ambient_temperature_uselimits) {
		ambient_temperature_uselimits = 1;
		if (autocvar_g_suggested_ambient_temperature_uselimits_reverse) {
			ambient_temperature_uselimits_reverse = 1;
		} else {
			ambient_temperature_uselimits_reverse = 0;
		}
	} else {
		ambient_temperature_uselimits = 0;
		ambient_temperature_uselimits_reverse = 0;
	}
	
	if (autocvar_g_suggested_ambient_temperature_maxx) {
		ambient_temperature_maxx = autocvar_g_suggested_ambient_temperature_maxx;
	} else {
		ambient_temperature_maxx = world.maxs_x;
	}
	
	
	if (autocvar_g_suggested_ambient_temperature_maxy) {
		ambient_temperature_maxy = autocvar_g_suggested_ambient_temperature_maxy;
	} else {
		ambient_temperature_maxy = world.maxs_y;
	}
	
	
	if (autocvar_g_suggested_ambient_temperature_maxz) {
		ambient_temperature_maxz = autocvar_g_suggested_ambient_temperature_maxz;
	} else {
		ambient_temperature_maxz = world.maxs_z;
	}
	
	if (autocvar_g_suggested_ambient_temperature_minx) {
		ambient_temperature_minx = autocvar_g_suggested_ambient_temperature_minx;
	} else {
		ambient_temperature_minx = world.mins_x;
	}
	
	if (autocvar_g_suggested_ambient_temperature_miny) {
		ambient_temperature_miny = autocvar_g_suggested_ambient_temperature_miny;
	} else {
		ambient_temperature_miny = world.mins_y;
	}
	
	if (autocvar_g_suggested_ambient_temperature_minz) {
		ambient_temperature_minz = autocvar_g_suggested_ambient_temperature_minz;
	} else {
		ambient_temperature_minz = world.mins_z;
	}
}


float ambient_temperature_playerphysics_findbase(entity mysrchent, float myrad)
{
	if (!g_ctf && !g_onslaught) return FALSE;
	
	entity f;
	f = findradius(mysrchent.origin, myrad);
  	while(f)
  	{
		if (f != mysrchent)
		{
			
			if (g_ctf) {
					if (f.classname == "item_flag_team_base") {
						//print("Found FLAGBASE\n");
			 			return TRUE;
					}
			} else if (g_onslaught) {
					if (f.classname == "onslaught_generator"
					|| f.classname == "onslaught_controlpoint") {
						//print("Found ONSBASE\n");
			 			return TRUE;
					}
			}
		}
    		f = f.chain;
  	}
	return FALSE;
}

float ambient_temperature_playerphysics_inbld(entity player)
{
	traceline(player.origin, player.origin + '0 0 -256', MOVE_NOMONSTERS, player);
	
	if (trace_ent) {
		if (trace_ent != world) {
			if (trace_ent.isabdbld) {
				return 1;
			}
		}
	}
	
	traceline(player.origin, player.origin + '0 0 512', MOVE_NOMONSTERS, player);

	if (trace_ent) {
		if (trace_ent != world) {
			if (trace_ent.isabdbld) {
				return 1;
			}
		}
	}
	
	return 0;
}
	

float ambient_temperature_playerphysics_findbld(entity player, float srchradius)
{
	entity eburn;
	
	if (ambient_temperature_playerphysics_inbld(player)) {
		//print("On or In Abdbld\n");
		return 1;
	}
	
	eburn = findradius(player.origin, srchradius);
	while(eburn)
	{
		if (eburn != world) {
			if (eburn.isabdbld) {
				//print("Found Abdbld\n");
				return 1;
			} else if (eburn.classname == "building") {
				if (eburn.multitool_hitbox) {
					if (eburn.multitool_hitbox.classname == "bldhitbx") {
						//print("Found Bldng\n");
						return 1;
					}
				}
			}
		}
			
		eburn = eburn.chain;
	}
	
	return 0;
}

float ambient_temperature_playerphysics_findfire(entity player, float srchradius)
{
	entity eburn;
	
	eburn = findradius(player.origin, srchradius);
	while(eburn)
	{
		if (eburn != world) {
			if (eburn.fire_burner) {
				if (eburn.fire_endtime > time) {
					//print("Found Fire\n");
					return 1;
				}
			}
		}
			
		eburn = eburn.chain;
	}
	
	return 0;
}

float ambient_temperature_playerphysics_findtorch(entity player, float srchradius)
{
	entity eburn;
	
	eburn = findradius(player.origin, srchradius);
	while(eburn)
	{
		if (eburn != world) {
			if (eburn.classname == "func_pointparticles") {
				//Similar code is in w_crossbowdtwr and mutators_spawnvehicles
				//perhaps consolidate at some point
				if (eburn.mdl == "torchflame"
				|| eburn.mdl == "torch_small"
				|| eburn.mdl == "flamethrower"
				|| eburn.mdl == "firefield"
				|| eburn.mdl == "TE_FLAMEJET"
				|| eburn.mdl == "EF_BIGFLAME"
				|| eburn.mdl == "EF_LARGEFLAME"
				|| eburn.mdl == "EF_HUGEFLAME"
				|| eburn.mdl == "EF_IMMENSEFLAME") {
					return 1;
				}
			}
		}
			
		eburn = eburn.chain;
	}
	
	return 0;
}

void ambient_temperature_playerphysics(entity player, float nofreeze)
{
	//Set to nofreeze if using for monster perhaps.
	float mynexttime;
	float docoldmsg;
	float felttemp;
	float atwithinlimits;
	if (autocvar_g_ambient_temperature_disable) return;
	
	if (!ambient_temperature) return;
	
	docoldmsg = 0;
	mynexttime = 20; //Default, is adjusted below if needed.
	
	atwithinlimits = ambient_temperature_entitywithinlimits(player);
	
	//////if(!player.frozen)
	if(!player.freezetag_frozen)
	if(!player.stoned)
	if(player.deadflag == DEAD_NO)
	if(player.health > 0)
	if(player.nextbodycoretempadjust < time) 
	if(atwithinlimits || autocvar_g_ambient_temperature_warmoutsidelimits)
	{
		//print("Ambient Temp for player physics\n");
		if(!atwithinlimits) {
			if (autocvar_g_ambient_temperature_warmoutsidelimits < 0) {
				//print("Ambient Temp for player physics: Cooling outside limits\n");
				if (player.bodycoretemp > autocvar_g_ambient_temperature_warmoutsidelimitsmin) {
					player.bodycoretemp = bound(autocvar_g_ambient_temperature_warmoutsidelimitsmin, player.bodycoretemp + autocvar_g_ambient_temperature_warmoutsidelimits, 37);
					mynexttime = 20;
					goto ambient_temperature_applycold;
				}
			} else if (autocvar_g_ambient_temperature_warmoutsidelimits) {
				//print("Ambient Temp for player physics: Warming outside limits\n");
				if (player.bodycoretemp < 37) {
					player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + autocvar_g_ambient_temperature_warmoutsidelimits, 37);
					mynexttime = 20;
				}
			}
		} else if(ambient_temperature >= 10) {
			//print("Ambient Temp for player physics: Good temp\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 3, 37);
				mynexttime = 20;
			}
		} else if(player.vehicle && player.vehicle.deadflag == DEAD_NO) {
			//print("Ambient Temp for player physics: In vehicle, warming\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 12, 37);
				mynexttime = 20;
			}
		} else if (ambient_temperature_playerphysics_findfire(player, 512)) {
			//print("Ambient Temp for player physics: Near fire, warming\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 15, 37);
				mynexttime = 20;
			}
		} else if (ambient_temperature_playerphysics_findbase(player, 1024)) {
			//print("Ambient Temp for player physics: Near base, warming\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 12, 37);
				mynexttime = 20;
			}
		} else if (ambient_temperature_playerphysics_findbld(player, 1024)) {
			//print("Ambient Temp for player physics: Near Building, warming\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 10, 37);
				mynexttime = 20;
			}
		} else if (ambient_temperature_playerphysics_findtorch(player, 256)) {
			//print("Ambient Temp for player physics: Near Torch, warming\n");
			if (player.bodycoretemp < 37) {
				player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 8, 37);
				mynexttime = 20;
			}
		} else {
:ambient_temperature_applycold
				//print("Ambient Temp for player physics: Core temp above ambient and not near anything\n");
				
				//print(ftos(player.bodycoretemp), "-A\n");
				//print(ftos(ambient_temperature), "-AT\n");
				
				felttemp = ambient_temperature;
				if (player.watertype == CONTENT_WATER) {
					if (ambient_temperature > 0) {
						//Not freezing but pulls body heat
						if (player.waterlevel == WATERLEVEL_WETFEET) {
							felttemp = felttemp - 5;
						} else if (player.waterlevel == WATERLEVEL_SWIMMING) {
							felttemp = felttemp - 10;
						} else if (player.waterlevel == WATERLEVEL_SUBMERGED) {
							felttemp = felttemp - 15;
						}
					} else {
						//Freeeezing
						if (player.waterlevel == WATERLEVEL_WETFEET) {
							felttemp = felttemp - 10;
						} else if (player.waterlevel == WATERLEVEL_SWIMMING) {
							felttemp = felttemp - 20;
						} else if (player.waterlevel == WATERLEVEL_SUBMERGED) {
							felttemp = felttemp - 40;
						}
					}
				} else if (player.watertype == CONTENT_LAVA) {
					if (player.waterlevel == WATERLEVEL_WETFEET) {
						felttemp = felttemp + 35;
					} else if (player.waterlevel == WATERLEVEL_SWIMMING) {
						felttemp = felttemp + 60;
					} else if (player.waterlevel == WATERLEVEL_SUBMERGED) {
						felttemp = felttemp + 110;
					}
				}
				
				if (felttemp <= -273.15) {
						//print("X14\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 100, player.bodycoretemp);
					mynexttime = 1;
				} else if (felttemp <= -100) {
						//print("X13\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 75, player.bodycoretemp);
					mynexttime = 1;
				} else if (felttemp <= -75) {
						//print("X12\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 50, player.bodycoretemp);
					mynexttime = 5;	
				} else if (felttemp < -45) {
						//print("X10\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 25, player.bodycoretemp);
					mynexttime = 5;
				} else if (felttemp < -40) {
						//print("X9\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 20, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -35) {
						//print("X8\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 15, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -30) {
						//print("X7\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 13, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -25) {
						//print("X6\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 11, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -20) {
						//print("X5\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 9, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -15) {
						//print("X4\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 7, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < -10) {
						//print("X3\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 5, player.bodycoretemp);
					mynexttime = 10;
				} else if (felttemp < 0) {
						//print("X2\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 2, player.bodycoretemp);
					mynexttime = 20;
				} else if (felttemp < 10) {
						//print("X\n");
					player.bodycoretemp = bound(felttemp, player.bodycoretemp - 1, player.bodycoretemp);
					mynexttime = 20;
				} else if (felttemp >= 10) {
					//Our felt temp is at or above 10 now (due to lava), so we add some body heat
					if (player.bodycoretemp < 37) {
						player.bodycoretemp = bound(player.bodycoretemp, player.bodycoretemp + 3, 37);
						mynexttime = 20;
					}
				}
			
			//print(ftos(player.bodycoretemp), "-B\n");
			
			if (player.bodycoretemp < -150) {
					//print("Y9\n");
				//hurt, freeze, etc
				Damage (player, player, player, 100, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.05, 0);
				docoldmsg = 7;
			} else if (player.bodycoretemp < -100) {
					//print("Y8\n");
				//hurt, freeze, etc
				Damage (player, player, player, 50, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.05, 0);
				docoldmsg = 7;
			} else if (player.bodycoretemp < -50) {
					//print("Y7\n");
				//hurt, freeze, etc
				Damage (player, player, player, 30, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.1, 0);
				docoldmsg = 7;
			} else if (player.bodycoretemp < -20) {
					//print("Y6\n");
				//hurt, freeze, etc
				Damage (player, player, player, 25, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.1, 0);
				docoldmsg = 7;
			} else if (player.bodycoretemp < -5) {
					//print("Y5\n");
				//hurt, freeze, etc
				Damage (player, player, player, 20, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.1, 0);
				docoldmsg = 6;
			} else if (player.bodycoretemp < -1) {
					//print("Y4\n");
				//hurt, freeze, etc
				Damage (player, player, player, 18, DEATH_ICE, player.origin, '0 0 0');
				if (!nofreeze) Freeze(player, 0.1, 0);
				docoldmsg = 6;
			} else if (player.bodycoretemp < 0) {
					//print("Y3\n");
				//hurt, freeze, etc
				Damage (player, player, player, 15, DEATH_ICE, player.origin, '0 0 0');
				docoldmsg = 5;
			} else if (player.bodycoretemp < 3) {
					//print("Y2\n");
				//hurt, freeze, etc
				Damage (player, player, player, 10, DEATH_ICE, player.origin, '0 0 0');
				docoldmsg = 4;
			} else if (player.bodycoretemp < 10) {
					//print("Y1\n");
				//hurt, freeze, etc
				Damage (player, player, player, 5, DEATH_ICE, player.origin, '0 0 0');
				docoldmsg = 3;
			} else if (player.bodycoretemp < 15) {
					//print("Y1\n");
				//hurt, freeze, etc
				Damage (player, player, player, 2, DEATH_ICE, player.origin, '0 0 0');
				docoldmsg = 2;
			} else if (player.bodycoretemp < 20) {
					//print("Y\n");
				//hurt, freeze, etc
				Damage (player, player, player, 1, DEATH_ICE, player.origin, '0 0 0');
				docoldmsg = 1;
			}
			
			if (docoldmsg) {
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				if (docoldmsg == 1) {
					sprint(self, "^x0CDYour body temperature is starting to drop^7\n");
				} else if (docoldmsg == 2) {
					sprint(self, "^x0CEYour body temperature continues to drop^7\n");
				} else if (docoldmsg == 3) {
					sprint(self, "^x08DYou feel cold^7\n");
				} else if (docoldmsg == 4) {
					sprint(self, "^x08DYou are cold^7\n");
				} else if (docoldmsg == 5) {
					sprint(self, "^x03AYou are freezing^7\n");
				} else if (docoldmsg == 6) {
					sprint(self, "^x019You are frozen^7\n");
				} else if (docoldmsg == 7) {
					sprint(self, "^x779You are frozen solid^7\n");
				} else {
					sprint(self, "^x00CYou are cold^7\n");
				}
			}
			}
		}
		
		player.nextbodycoretempadjust = time + mynexttime;
	}
	
}

void ambient_temperature_ignitewooden()
{
	//print("Igniting Trees and bushes in Lava\n");
	local float mywaterlevel;
	mywaterlevel = sfalqdlvl("g_spawnfoliagearound_waterlevel", "g_suggested_spawnfoliagearound_waterlevel");
	entity e;
	
  	for(e = world; (e = find(e, classname, "tree")); )
	{
		if (e.origin_z > mywaterlevel || !mywaterlevel)
		{
			if (pointcontents(e.origin) == CONTENT_WATER) {
				//Do nothing
			} else if (ambient_temperature_entitywithinlimits(e)) {
				Fire_AddDamage(e, world, autocvar_g_balance_nukelayer_fire2_damage *
				120, 120, 
				WEP_FIREBALL); //Optional set an intensity: //e.fire_intensity = 5;	
			}
		}
    	}
	
	for(e = world; (e = find(e, classname, "bush")); )
	{
		if (e.origin_z > mywaterlevel || !mywaterlevel)
		{
			if (pointcontents(e.origin) == CONTENT_WATER) {
				//Do nothing
			} else if (ambient_temperature_entitywithinlimits(e)) {
				Fire_AddDamage(e, world, autocvar_g_balance_nukelayer_fire2_damage *
				120, 120, 
				WEP_FIREBALL);
			}
		}
    	}
	
	//buildings
	for(e = world; (e = find(e, classname, "building")); )
	{
		if (e.origin_z > mywaterlevel || !mywaterlevel)
		{
			if (pointcontents(e.origin) == CONTENT_WATER) {
				//Do nothing
			} else if (multitool_iswooden(e.multitool_hitbox.count)) {
				if (ambient_temperature_entitywithinlimits(e)) {
					Fire_AddDamage(e.multitool_hitbox, world, autocvar_g_balance_nukelayer_fire2_damage *
					120, 120, 
					WEP_FIREBALL);
				}
			} else if (e.abdbldcanburn) {
				if (ambient_temperature_entitywithinlimits(e)) {
					Fire_AddDamage(e, world, autocvar_g_balance_nukelayer_fire2_damage *
					120, 120, 
					WEP_FIREBALL);
				}
			}
		}
    	}
}

void ambient_temperature_do (void)
{
	self.nextthink = time + 1 + autocvar_g_ambient_temperature_addtonexttime;

	if (autocvar_g_ambient_temperature_disable)
		return;
	
	if (autocvar_g_ambient_temperature) {
		ambient_temperature = autocvar_g_ambient_temperature;
		if (autocvar_g_ambient_temperature_uselimits_usesuggested) {
			ambient_temperature_setlimits_suggested(); //Contrarian
		} else {
			ambient_temperature_setlimits(); //Normal
		}
	} else {
		ambient_temperature = autocvar_g_suggested_ambient_temperature;
		if (autocvar_g_suggested_ambient_temperature_uselimits_usenotsuggested) {
			ambient_temperature_setlimits(); //Contrarian
		} else {
			ambient_temperature_setlimits_suggested(); //Normal
		}
	}
	
	
	if (ambient_temperature >= 300) {
		//Ignite wood
		ambient_temperature_ignitewooden();
	}
	
	//print(ftos(self.nextthink)," G_AMBIENT_TEMPERATURE NEXTTHINK\n");
}

void ambient_temperature_setup(void)
{
	entity ambienttemperaturethinker;
	entity oldself;
	
	oldself = self;
	
	ambienttemperaturethinker = spawn();
	
	self = ambienttemperaturethinker;
	self.think = ambient_temperature_do;
	
	if (autocvar_g_ambient_temperature) {
		//Overrides
		self.nextthink = time + autocvar_g_ambient_temperature_wait;
		ambient_temperature = autocvar_g_ambient_temperature;
		if (autocvar_g_ambient_temperature_uselimits_usesuggested) {
			ambient_temperature_setlimits_suggested(); //Contrarian
		} else {
			ambient_temperature_setlimits(); //Normal
		}
	} else {
		self.nextthink = time + autocvar_g_suggested_ambient_temperature_wait;
		ambient_temperature = autocvar_g_suggested_ambient_temperature;
		if (autocvar_g_suggested_ambient_temperature_uselimits_usenotsuggested) {
			ambient_temperature_setlimits(); //Contrarian
		} else {
			ambient_temperature_setlimits_suggested(); //Normal
		}
	}
	
	if (ambient_temperature < 0) {
		precache_model ("models/ice/ice.md3");
	}
	
	//print(ftos(self.nextthink)," G_AMBIENT_TEMPERATURE NEXTTHINK\n");
	self = oldself;
}

void g_ambienttemperature(void)
{
	ambient_temperature = 0; //Will be set below
	if (autocvar_g_ambient_temperature || autocvar_g_suggested_ambient_temperature)
	{
		if (!autocvar_g_ambient_temperature_disable) {
			ambient_temperature_setup();
		}
	}
}





////Gameplay fix:
void spawnfunc_misc_clientmodel();
void  gameplayfix_spawnbbox_do(void)
{
	print("------Spawning gameplayfix_spawnbbox\n");
	entity myolderself;
	entity mybbox;
	myolderself = self;
	mybbox = spawn();
	mybbox.origin_x = autocvar_sv_gameplayfix_spawnbbox_originx;
	mybbox.origin_y = autocvar_sv_gameplayfix_spawnbbox_originy;
	mybbox.origin_z = autocvar_sv_gameplayfix_spawnbbox_originz;
	mybbox.mins_x = autocvar_sv_gameplayfix_spawnbbox_minx;
	mybbox.mins_y = autocvar_sv_gameplayfix_spawnbbox_miny;
	mybbox.mins_z = autocvar_sv_gameplayfix_spawnbbox_minz;
	mybbox.maxs_x = autocvar_sv_gameplayfix_spawnbbox_maxx;
	mybbox.maxs_y = autocvar_sv_gameplayfix_spawnbbox_maxy;
	mybbox.maxs_z = autocvar_sv_gameplayfix_spawnbbox_maxz;
	mybbox.solid = SOLID_BBOX;
	//mybbox.dphitcontentsmask = DPCONTENTS_SKY;
	mybbox.noimpactingprojectiles = 1;
	mybbox.movetype = MOVETYPE_PUSH;
	mybbox.effects = EF_NODRAW + EF_NOSHADOW + EF_LOWPRECISION;
	mybbox.alpha = -1;
	self = mybbox;
	setorigin(self, mybbox.origin);
	setsize(self, mybbox.mins, mybbox.maxs);
	print (vtos(self.origin), " origin\n");
	print (vtos(self.mins), " mins\n");
	print (vtos(self.maxs), " maxs\n");
	self = myolderself;
	remove(self);
}

void gameplayfix_spawnbbox(void)
{
	entity gameplayfixspawnbboxthinker;
	entity oldself;
	
	oldself = self;
	
	gameplayfixspawnbboxthinker = spawn();
	
	self = gameplayfixspawnbboxthinker;
	self.think = gameplayfix_spawnbbox_do;
	self.nextthink = time;

	self = oldself;
}

void g_gameplayfix_spawnbbox(void)
{
	if (autocvar_sv_gameplayfix_spawnbbox)
	{
		gameplayfix_spawnbbox();
	}
}


void spawnfoliagearoundwaterplayerspawn();
void spawnfoliagearoundlavaplayerspawn();
void spawnfoliagearoundslimeplayerspawn();
void spawnfoliagearoundoilplayerspawn();
void spawnfoliagearoundchemplayerspawn();
void spawnfoliagearoundmethaneplayerspawn();

void g_suggestedliquidlevels(void)
{
	//Start mapsuggested liquid levels at map start, even before playerspawns
	//so that the map looks as the author intended from the begining
	//EX (an): Oil Ocean, Methane Sea, Chemical Lake, Lava Landscape, Slime Ravine...., or a Water World
	//Ofcourse, the last 3 one can just do in the map itself..
	if(cvar("g_suggested_spawnfoliagearound_waterlevel"))
		spawnfoliagearoundwaterplayerspawn();
		
	if(cvar("g_suggested_spawnfoliagearound_lavalevel"))
		spawnfoliagearoundlavaplayerspawn();
	
	if(cvar("g_suggested_spawnfoliagearound_slimelevel"))
		spawnfoliagearoundslimeplayerspawn();
		
	if(cvar("g_suggested_spawnfoliagearound_oillevel"))
		spawnfoliagearoundoilplayerspawn();
		
	if(cvar("g_suggested_spawnfoliagearound_chemlevel"))
		spawnfoliagearoundchemplayerspawn();
		
	if(cvar("g_suggested_spawnfoliagearound_methanelevel"))
		spawnfoliagearoundmethaneplayerspawn();
	
}







////Gameplay fix:
void gameplayfix_spawnfilth(vector myorigin, vector myminmaxs,
vector myaltmins, vector myaltmaxs,
vector mytransfersmellrate_liquid_any,
vector mytransfersmellrate_lava_slime_water,
vector my_acrid_alcohol_earthy,
vector my_roses_garlic_cheeze,
vector my_bodyodor_urine_rottingflesh,
float my_faeces)
{
	dprint("       7 FhBx\n");
	entity myolderself;
	entity mybbox;
	myolderself = self;
	mybbox = spawn();
	mybbox.origin = myorigin;
	
	dprint(vtos(myminmaxs), "fhbx: minmaxs\n");
	dprint(vtos(myaltmins), "fhbx: myaltmins\n");
	dprint(vtos(myaltmaxs), "fhbx: myaltmaxs\n");
	
	if (myminmaxs_x) {
		mybbox.mins_x = myminmaxs_x * -1;
		mybbox.maxs_x = myminmaxs_x;
	} else {
		mybbox.mins_x = myaltmins_x;
		mybbox.maxs_x = myaltmaxs_x;
	}
	
	
	if (myminmaxs_y) {
		mybbox.mins_y = myminmaxs_y * -1;
		mybbox.maxs_y = myminmaxs_y;
	} else {
		mybbox.mins_y = myaltmins_y;
		mybbox.maxs_y = myaltmaxs_y;
	}
	
	
	if (myminmaxs_z) {
		mybbox.mins_z = myminmaxs_z * -1;
		mybbox.maxs_z = myminmaxs_z;
	} else {
		mybbox.mins_z = myaltmins_z;
		mybbox.maxs_z = myaltmaxs_z;
	}
	
	dprint("        8 FhBx\n");
	
	if (mybbox.mins_x == 0
	&& mybbox.mins_y == 0
	&& mybbox.mins_z == 0
	&& mybbox.maxs_x == 0
	&& mybbox.maxs_y == 0
	&& mybbox.maxs_z == 0)
	{
		remove(self);
		dprint ("Failed to create FhBx: no min/maxs\n");
		return;
	} else if ((mybbox.mins_x > mybbox.maxs_x)
	|| (mybbox.mins_y > mybbox.maxs_y)
	|| (mybbox.mins_z > mybbox.maxs_z))
	{
		remove(self);
		dprint ("Failed to create FhBx: improper min/maxs ", "MAXS :", vtos(mybbox.maxs),"   mins:", vtos(mybbox.mins),"\n");
		return;
	}
	
	
	dprint(" * \n * \n * \n*****SPAWNING FHBX***** at", vtos(mybbox.origin)," - MAXS ", vtos(mybbox.maxs)," - mins ", vtos(mybbox.mins),"\n * \n * \n * \n");
	
	mybbox.solid = SOLID_NOT;
	//mybbox.dphitcontentsmask = DPCONTENTS_SKY;
	mybbox.noimpactingprojectiles = 1;
	mybbox.movetype = MOVETYPE_NONE;
	mybbox.effects = EF_NODRAW + EF_NOSHADOW + EF_LOWPRECISION;
	mybbox.alpha = -1;
	
	mybbox.isfilth = 1;
	mybbox.transfer_smell_rate_liquid = mytransfersmellrate_liquid_any_x;
	mybbox.transfer_smell_rate_any = mytransfersmellrate_liquid_any_y;
	mybbox.transfer_smell_rate_lava = mytransfersmellrate_lava_slime_water_x;
	mybbox.transfer_smell_rate_slime = mytransfersmellrate_lava_slime_water_y;
	mybbox.transfer_smell_rate_water = mytransfersmellrate_lava_slime_water_z;
	//my_acrid_alcohol_earthy
	mybbox.smell_acrid = my_acrid_alcohol_earthy_x; //Like chemically
	mybbox.smell_alcohol = my_acrid_alcohol_earthy_y;
	mybbox.smell_earthy = my_acrid_alcohol_earthy_z;
	//my_roses_garlic_cheeze
	mybbox.smell_roses = my_roses_garlic_cheeze_x;
	mybbox.smell_garlic = my_roses_garlic_cheeze_y;
	mybbox.smell_cheeze = my_roses_garlic_cheeze_z;
	//my_bodyodor_urine_rottingflesh
	mybbox.smell_bodyodor = my_bodyodor_urine_rottingflesh_x;
	mybbox.smell_urine = my_bodyodor_urine_rottingflesh_y;
	mybbox.smell_rottingflesh = my_bodyodor_urine_rottingflesh_z;
	//my_faeces
	mybbox.smell_faeces = my_faeces;

	self = mybbox;
	setorigin(self, mybbox.origin);
	setsize(self, mybbox.mins, mybbox.maxs);
	dprint (vtos(self.origin), " origin FhBx\n");
	dprint (vtos(self.mins), " mins FhBx\n");
	dprint (vtos(self.maxs), " maxs FhBx\n");
	
	dprint("         9 FhBx\n");
	
	
	dprint(ftos(self.transfer_smell_rate_liquid), " fhbx t rate l\n");
	dprint(ftos(self.transfer_smell_rate_any), " fhbx t rate a\n");
	dprint(ftos(self.smell_faeces), " fhbx s tst1\n");
	dprint(ftos(self.smell_urine), " fhbx s tst2\n");
	
	self = myolderself;
}

////////
////////
void  gameplayfix_spawnfilth_setup(void)
{
	dprint("    4 FhBx spawnfilth\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth) {
		dprint("     5 FhBx spawnfilth\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////


////////
////////
void  gameplayfix_spawnfilth0_setup(void)
{
	dprint("    4 FhBx spawnfilth0\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth0) {
		dprint("     5 FhBx spawnfilth0\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth0_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth0_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth0_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth0_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth0_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth0_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth0_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth0_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth0_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth0_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth0_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth0_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth0_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth0_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth0_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth0_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth0_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth0_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth0_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth0_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth0_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth0_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth0_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth0_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth0_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth0_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth0_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth0_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth0_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth0_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth0_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth0_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth0_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth0_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////




////////
////////
void  gameplayfix_spawnfilth1_setup(void)
{
	dprint("    4 FhBx spawnfilth1\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth1) {
		dprint("     5 FhBx spawnfilth1\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth1_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth1_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth1_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth1_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth1_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth1_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth1_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth1_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth1_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth1_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth1_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth1_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth1_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth1_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth1_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth1_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth1_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth1_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth1_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth1_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth1_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth1_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth1_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth1_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth1_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth1_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth1_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth1_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth1_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth1_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth1_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth1_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth1_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth1_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////





////////
////////
void  gameplayfix_spawnfilth2_setup(void)
{
	dprint("    4 FhBx spawnfilth2\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth2) {
		dprint("     5 FhBx spawnfilth2\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth2_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth2_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth2_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth2_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth2_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth2_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth2_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth2_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth2_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth2_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth2_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth2_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth2_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth2_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth2_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth2_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth2_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth2_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth2_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth2_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth2_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth2_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth2_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth2_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth2_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth2_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth2_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth2_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth2_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth2_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth2_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth2_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth2_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth2_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////






////////
////////
void  gameplayfix_spawnfilth3_setup(void)
{
	dprint("    4 FhBx spawnfilth3\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth3) {
		dprint("     5 FhBx spawnfilth3\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth3_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth3_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth3_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth3_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth3_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth3_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth3_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth3_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth3_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth3_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth3_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth3_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth3_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth3_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth3_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth3_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth3_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth3_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth3_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth3_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth3_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth3_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth3_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth3_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth3_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth3_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth3_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth3_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth3_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth3_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth3_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth3_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth3_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth3_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////








////////
////////
void  gameplayfix_spawnfilth4_setup(void)
{
	dprint("    4 FhBx spawnfilth4\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth4) {
		dprint("     5 FhBx spawnfilth4\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth4_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth4_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth4_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth4_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth4_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth4_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth4_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth4_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth4_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth4_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth4_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth4_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth4_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth4_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth4_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth4_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth4_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth4_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth4_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth4_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth4_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth4_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth4_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth4_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth4_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth4_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth4_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth4_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth4_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth4_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth4_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth4_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth4_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth4_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////







////////
////////
void  gameplayfix_spawnfilth5_setup(void)
{
	dprint("    4 FhBx spawnfilth5\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth5) {
		dprint("     5 FhBx spawnfilth5\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth5_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth5_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth5_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth5_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth5_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth5_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth5_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth5_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth5_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth5_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth5_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth5_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth5_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth5_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth5_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth5_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth5_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth5_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth5_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth5_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth5_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth5_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth5_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth5_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth5_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth5_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth5_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth5_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth5_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth5_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth5_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth5_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth5_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth5_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////







////////
////////
void  gameplayfix_spawnfilth6_setup(void)
{
	dprint("    4 FhBx spawnfilth6\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth6) {
		dprint("     5 FhBx spawnfilth6\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth6_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth6_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth6_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth6_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth6_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth6_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth6_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth6_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth6_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth6_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth6_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth6_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth6_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth6_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth6_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth6_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth6_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth6_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth6_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth6_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth6_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth6_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth6_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth6_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth6_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth6_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth6_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth6_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth6_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth6_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth6_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth6_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth6_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth6_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////





////////
////////
void  gameplayfix_spawnfilth7_setup(void)
{
	dprint("    4 FhBx spawnfilth7\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth7) {
		dprint("     5 FhBx spawnfilth7\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth7_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth7_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth7_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth7_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth7_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth7_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth7_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth7_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth7_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth7_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth7_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth7_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth7_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth7_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth7_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth7_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth7_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth7_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth7_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth7_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth7_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth7_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth7_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth7_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth7_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth7_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth7_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth7_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth7_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth7_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth7_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth7_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth7_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth7_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////





////////
////////
void  gameplayfix_spawnfilth8_setup(void)
{
	dprint("    4 FhBx spawnfilth8\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth8) {
		dprint("     5 FhBx spawnfilth8\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth8_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth8_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth8_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth8_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth8_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth8_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth8_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth8_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth8_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth8_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth8_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth8_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth8_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth8_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth8_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth8_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth8_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth8_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth8_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth8_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth8_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth8_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth8_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth8_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth8_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth8_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth8_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth8_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth8_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth8_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth8_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth8_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth8_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth8_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////






////////
////////
void  gameplayfix_spawnfilth9_setup(void)
{
	dprint("    4 FhBx spawnfilth9\n");
	local vector myorigin, myminmaxs, myaltmins, myaltmaxs;
	local vector mytransfersmellrate_liquid_any, mytransfersmellrate_lava_slime_water;
	local vector my_acrid_alcohol_earthy, my_roses_garlic_cheeze, my_bodyodor_urine_rottingflesh;
	local float my_faeces;
	
	if (autocvar_sv_gameplayfix_spawnfilth9) {
		dprint("     5 FhBx spawnfilth9\n");
		
		myorigin = myminmaxs = myaltmins = myaltmaxs = '0 0 0';
		mytransfersmellrate_liquid_any = mytransfersmellrate_lava_slime_water = '0 0 0';
		my_acrid_alcohol_earthy = my_roses_garlic_cheeze = my_bodyodor_urine_rottingflesh = '0 0 0';
		my_faeces = 0;
		
		myorigin_x = autocvar_sv_gameplayfix_spawnfilth9_originx;
		myorigin_y = autocvar_sv_gameplayfix_spawnfilth9_originy;
		myorigin_z = autocvar_sv_gameplayfix_spawnfilth9_originz;
		
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth9_minmaxx), " min-max-x\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth9_minmaxy), " min-max-y\n");
		dprint(ftos(autocvar_sv_gameplayfix_spawnfilth9_minmaxz), " min-max-z\n");
		
		if (autocvar_sv_gameplayfix_spawnfilth9_minmaxx) { myminmaxs_x = autocvar_sv_gameplayfix_spawnfilth9_minmaxx;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth9_minx) { myaltmins_x = autocvar_sv_gameplayfix_spawnfilth9_minx; }
			if (autocvar_sv_gameplayfix_spawnfilth9_maxx) { myaltmaxs_x = autocvar_sv_gameplayfix_spawnfilth9_maxx; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_minmaxy) { myminmaxs_y = autocvar_sv_gameplayfix_spawnfilth9_minmaxy;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth9_miny) { myaltmins_y = autocvar_sv_gameplayfix_spawnfilth9_miny; }
			if (autocvar_sv_gameplayfix_spawnfilth9_maxy) { myaltmaxs_y = autocvar_sv_gameplayfix_spawnfilth9_maxy; }
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_minmaxz) { myminmaxs_z = autocvar_sv_gameplayfix_spawnfilth9_minmaxz;
		} else {
			if (autocvar_sv_gameplayfix_spawnfilth9_minz) { myaltmins_z = autocvar_sv_gameplayfix_spawnfilth9_minz; }
			if (autocvar_sv_gameplayfix_spawnfilth9_maxz) { myaltmaxs_z = autocvar_sv_gameplayfix_spawnfilth9_maxz; }
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_liquid) {
			mytransfersmellrate_liquid_any_x = autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_liquid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_any) {
			mytransfersmellrate_liquid_any_y = autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_any;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_lava) {
			mytransfersmellrate_lava_slime_water_x = autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_lava;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_slime) {
			mytransfersmellrate_lava_slime_water_y = autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_slime;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_water) {
			mytransfersmellrate_lava_slime_water_z = autocvar_sv_gameplayfix_spawnfilth9_transfersmellrate_water;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_acrid) {
			my_acrid_alcohol_earthy_x = autocvar_sv_gameplayfix_spawnfilth9_smell_acrid;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_alcohol) {
			my_acrid_alcohol_earthy_y = autocvar_sv_gameplayfix_spawnfilth9_smell_alcohol;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_earthy) {
			my_acrid_alcohol_earthy_z = autocvar_sv_gameplayfix_spawnfilth9_smell_earthy;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_roses) {
			my_roses_garlic_cheeze_x = autocvar_sv_gameplayfix_spawnfilth9_smell_roses;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_garlic) {
			my_roses_garlic_cheeze_y = autocvar_sv_gameplayfix_spawnfilth9_smell_garlic;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_cheeze) {
			my_roses_garlic_cheeze_z = autocvar_sv_gameplayfix_spawnfilth9_smell_cheeze;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_bodyodor) {
			my_bodyodor_urine_rottingflesh_x = autocvar_sv_gameplayfix_spawnfilth9_smell_bodyodor;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_urine) {
			my_bodyodor_urine_rottingflesh_y = autocvar_sv_gameplayfix_spawnfilth9_smell_urine;
		}
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_rottingflesh) {
			my_bodyodor_urine_rottingflesh_z = autocvar_sv_gameplayfix_spawnfilth9_smell_rottingflesh;
		}
		
		//////////
		
		if (autocvar_sv_gameplayfix_spawnfilth9_smell_faeces) {
			my_faeces = autocvar_sv_gameplayfix_spawnfilth9_smell_faeces;
		}
		
		gameplayfix_spawnfilth(myorigin, myminmaxs,
		 myaltmins, myaltmaxs,
		 mytransfersmellrate_liquid_any,
		 mytransfersmellrate_lava_slime_water,
		 my_acrid_alcohol_earthy,
		 my_roses_garlic_cheeze,
		 my_bodyodor_urine_rottingflesh,
		 my_faeces);
	}
}
////////
////////









void  gameplayfix_spawnfilth_do(void)
{

	dprint("   3 FhBx\n");
	dprint("------gameplayfix fhbx\n");
	
	gameplayfix_spawnfilth_setup();
	gameplayfix_spawnfilth0_setup();
	gameplayfix_spawnfilth1_setup();
	gameplayfix_spawnfilth2_setup();
	gameplayfix_spawnfilth3_setup();
	gameplayfix_spawnfilth4_setup();
	gameplayfix_spawnfilth5_setup();
	gameplayfix_spawnfilth6_setup();
	gameplayfix_spawnfilth7_setup();
	gameplayfix_spawnfilth8_setup();
	gameplayfix_spawnfilth9_setup();
	
	remove(self);
}

void gameplayfix_spawnfilth_thinker(void)
{
	dprint("  2 FhBx\n");
	entity gameplayfixspawnfilththinker;
	entity oldself;
	
	oldself = self;
	
	gameplayfixspawnfilththinker = spawn();
	
	self = gameplayfixspawnfilththinker;
	self.think = gameplayfix_spawnfilth_do;
	self.nextthink = time;

	self = oldself;
}

void g_gameplayfix_spawnfilth(void)
{
	if (autocvar_sv_gameplayfix_spawnfilth
	|| autocvar_sv_gameplayfix_spawnfilth0
	|| autocvar_sv_gameplayfix_spawnfilth1
	|| autocvar_sv_gameplayfix_spawnfilth2
	|| autocvar_sv_gameplayfix_spawnfilth3
	|| autocvar_sv_gameplayfix_spawnfilth4
	|| autocvar_sv_gameplayfix_spawnfilth5
	|| autocvar_sv_gameplayfix_spawnfilth6
	|| autocvar_sv_gameplayfix_spawnfilth7
	|| autocvar_sv_gameplayfix_spawnfilth8
	|| autocvar_sv_gameplayfix_spawnfilth9)
	{
		dprint(" 1 FhBx\n");
		gameplayfix_spawnfilth_thinker();
	}
}

