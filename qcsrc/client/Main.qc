// --------------------------------------------------------------------------
// BEGIN REQUIRED CSQC FUNCTIONS
//include "main.qh"

entity clearentity_ent;
void clearentity(entity e)
{
	if not(clearentity_ent)
	{
		clearentity_ent = spawn();
		clearentity_ent.classname = "clearentity";
	}
	float n = e.entnum;
	copyentity(clearentity_ent, e);
	e.entnum = n;
}

#define DP_CSQC_ENTITY_REMOVE_IS_B0RKED
void menu_show_error()
{
	drawstring('0 200 0', _("ERROR - MENU IS VISIBLE BUT NO MENU WAS DEFINED!"), '8 8 0', '1 0 0', 1, 0);
}

// CSQC_Init : Called every time the CSQC code is initialized (essentially at map load)
// Useful for precaching things

void menu_sub_null()
{
}

#ifdef USE_FTE
float __engine_check;
#endif

void precache_playermodel(string m)
{
	string f;

	if(substring(m, -9,5) == "_lod1")
		return;
	if(substring(m, -9,5) == "_lod2")
		return;
	precache_model(m);
	f = strcat(substring(m, 0, -5), "_lod1", substring(m, -4, -1));
	if(fexists(f))
		precache_model(f);
	f = strcat(substring(m, 0, -5), "_lod2", substring(m, -4, -1));
	if(fexists(f))
		precache_model(f);

	/*
	float globhandle, i, n;
	globhandle = search_begin(strcat(m, "_*.sounds"), TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		PrecachePlayerSounds(f);
	}
	search_end(globhandle);
	*/
}
void precache_all_playermodels(string pattern)
{
	float globhandle, i, n;
	string f;

	globhandle = search_begin(pattern, TRUE, FALSE);
	if (globhandle < 0)
		return;
	n = search_getsize(globhandle);
	for (i = 0; i < n; ++i)
	{
		//print(search_getfilename(globhandle, i), "\n");
		f = search_getfilename(globhandle, i);
		precache_playermodel(f);
	}
	search_end(globhandle);
}

string forcefog;
void WaypointSprite_Load();
void ConsoleCommand_macro_init();
void CSQC_Init(void)
{
	prvm_language = cvar_string("prvm_language");
#ifdef USE_FTE
#pragma target ID
	__engine_check = checkextension("DP_SV_WRITEPICTURE");
	if(!__engine_check)
	{
		print(_("^3Your engine build is outdated\n^3This Server uses a newer QC VM. Please update!\n"));
		localcmd("\ndisconnect\n");
		return;
	}
#pragma target FTE
#endif

	check_unacceptable_compiler_bugs();

#ifdef WATERMARK
	print(sprintf(_("^4CSQC Build information: ^1%s\n"), WATERMARK));
#endif

	float i;

#ifdef COMPAT_XON050_ENGINE
	// old engine lacks implementation of player_localnum
	player_localnum = player_localentnum - 1;
#endif

	binddb = db_create();
	tempdb = db_create();
	ClientProgsDB = db_load("client.db");
	compressShortVector_init();

	draw_endBoldFont();
	menu_visible = FALSE;
	menu_show = menu_show_error;
	menu_action = func_null;

	for(i = 0; i < 255; ++i)
		if(getplayerkeyvalue(i, "viewentity") == "")
			break;
	maxclients = i;

	//registercommand("hud_configure");
	//registercommand("hud_save");
	//registercommand("menu_action");
	
	ConsoleCommand_macro_init();

	registercvar("hud_usecsqc", "1");
	registercvar("scoreboard_columns", "default");

	gametype = 0;

	// hud_fields uses strunzone on the titles!
	for(i = 0; i < MAX_HUD_FIELDS; ++i)
		hud_title[i] = strzone("(null)");

	postinit = false;

	calledhooks = 0;

	teams = Sort_Spawn();
	players = Sort_Spawn();

	GetTeam(COLOR_SPECTATOR, true); // add specs first

	// needs to be done so early because of the constants they create
	CALL_ACCUMULATED_FUNCTION(RegisterWeapons);
	CALL_ACCUMULATED_FUNCTION(RegisterGametypes);

	WaypointSprite_Load();

	// precaches
	precache_model("null");
	precache_sound("misc/hit.wav");
	precache_sound("misc/typehit.wav");
	if (autocvar_cl_precacheplayermodels)
	{
		precache_all_playermodels("models/player/*.zym");
		precache_all_playermodels("models/player/*.dpm");
		precache_all_playermodels("models/player/*.md3");
		precache_all_playermodels("models/player/*.psk");
		precache_all_playermodels("models/player/*.iqm");
	}

	Projectile_Precache();
	Hook_Precache();
	GibSplash_Precache();
	Casings_Precache();
	DamageInfo_Precache();
	Vehicles_Precache();
	turrets_precache();
    Announcer_Precache();
	Tuba_Precache();
	CSQCPlayer_Precache();
	
	if(autocvar_cl_reticle)
	{
		if(autocvar_cl_reticle_item_normal) { precache_pic("gfx/reticle_normal"); }
		if(autocvar_cl_reticle_item_nex) { precache_pic("gfx/reticle_nex"); }
	}
	
	get_mi_min_max_texcoords(1); // try the CLEVER way first
	minimapname = strcat("gfx/", mi_shortname, "_radar.tga");
	shortmapname = mi_shortname;

	if(precache_pic(minimapname) == "")
	{
		// but maybe we have a non-clever minimap
		minimapname = strcat("gfx/", mi_shortname, "_mini.tga");
		if(precache_pic(minimapname) == "")
			minimapname = ""; // FAIL
		else
			get_mi_min_max_texcoords(0); // load new texcoords
	}

	mi_center = (mi_min + mi_max) * 0.5;
	mi_scale = mi_max - mi_min;
	minimapname = strzone(minimapname);

	WarpZone_Init();

	hud_configure_prev = -1;
	tab_panel = -1;

	draw_currentSkin = strzone(strcat("gfx/menu/", cvar_string("menu_skin")));
}

// CSQC_Shutdown : Called every time the CSQC code is shutdown (changing maps, quitting, etc)
void Shutdown(void)
{
#ifdef USE_FTE
#pragma TARGET id
	if(!__engine_check)
		return 0;
#pragma TARGET fte
#endif

	localcmd(strcat("\nr_drawworld 1\n"));
	localcmd(strcat("\nr_drawentities 1\n"));
	//So if you were temp blind at map end, now you can see next map
	
	WarpZone_Shutdown();

	remove(teams);
	remove(players);
	db_close(binddb);
	db_close(tempdb);
	if(autocvar_cl_db_saveasdump)
		db_dump(ClientProgsDB, "client.db");
	else
		db_save(ClientProgsDB, "client.db");
	db_close(ClientProgsDB);

	if(camera_active)
		cvar_set("chase_active",ftos(chase_active_backup));

	// unset the event chasecam's chase_active
	if(autocvar_chase_active < 0)
		cvar_set("chase_active", "0");

	if not(isdemo())
	{
		if not(calledhooks & HOOK_START)
			localcmd("\n_cl_hook_gamestart nop\n");
		if not(calledhooks & HOOK_END)
			localcmd("\ncl_hook_gameend\n");
	}
}

.float has_team;
float SetTeam(entity o, float Team)
{
	entity tm;
	if(teamplay)
	{
		switch(Team)
		{
			case -1:
			case COLOR_TEAM1:
			case COLOR_TEAM2:
			case COLOR_TEAM3:
			case COLOR_TEAM4:
				break;
			default:
				if(GetTeam(Team, false) == world)
				{
					print(sprintf(_("trying to switch to unsupported team %d\n"), Team));
					Team = COLOR_SPECTATOR;
				}
				break;
		}
	}
	else
	{
		switch(Team)
		{
			case -1:
			case 0:
				break;
			default:
				if(GetTeam(Team, false) == world)
				{
					print(sprintf(_("trying to switch to unsupported team %d\n"), Team));
					Team = COLOR_SPECTATOR;
				}
				break;
		}
	}
	if(Team == -1) // leave
	{
		if(o.has_team)
		{
			tm = GetTeam(o.team, false);
			tm.team_size -= 1;
			o.has_team = 0;
			return TRUE;
		}
	}
	else
	{
		if not(o.has_team)
		{
			o.team = Team;
			tm = GetTeam(Team, true);
			tm.team_size += 1;
			o.has_team = 1;
			return TRUE;
		}
		else if(Team != o.team)
		{
			tm = GetTeam(o.team, false);
			tm.team_size -= 1;
			o.team = Team;
			tm = GetTeam(Team, true);
			tm.team_size += 1;
			return TRUE;
		}
	}
	return FALSE;
}

void Playerchecker_Think()
{
	float i;
	entity e;
	for(i = 0; i < maxclients; ++i)
	{
		e = playerslots[i];
		if(GetPlayerName(i) == "")
		{
			if(e.sort_prev)
			{
				// player disconnected
				SetTeam(e, -1);
				RemovePlayer(e);
				e.sort_prev = world;
				//e.gotscores = 0;
			}
		}
		else
		{
			if not(e.sort_prev)
			{
				// player connected
				if not(e)
					playerslots[i] = e = spawn();
				e.sv_entnum = i;
				e.ping = 0;
				e.ping_packetloss = 0;
				e.ping_movementloss = 0;
				//e.gotscores = 0; // we might already have the scores...
				SetTeam(e, GetPlayerColor(i)); // will not hurt; later updates come with HUD_UpdatePlayerTeams
				RegisterPlayer(e);
				HUD_UpdatePlayerPos(e);
			}
		}
	}
	self.nextthink = time + 0.2;
}

void Porto_Init();
void TrueAim_Init();
void PostInit(void)
{
	localcmd(strcat("\nscoreboard_columns_set ", autocvar_scoreboard_columns, ";\n"));

	entity playerchecker;
	playerchecker = spawn();
	playerchecker.think = Playerchecker_Think;
	playerchecker.nextthink = time + 0.2;

	Porto_Init();
	TrueAim_Init();

	postinit = true;
}

float button_zoom;

// CSQC_InputEvent : Used to perform actions based on any key pressed, key released and mouse on the client.
// Return value should be 1 if CSQC handled the input, otherwise return 0 to have the input passed to the engine.
// All keys are in ascii.
// bInputType = 0 is key pressed, 1 is key released, 2 and 3 are mouse input.
// In the case of keyboard input, nPrimary is the ascii code, and nSecondary is 0.
// In the case of mouse input, nPrimary is xdelta, nSecondary is ydelta.
// In the case of mouse input after a setcursormode(1) call, nPrimary is xpos, nSecondary is ypos.
float CSQC_InputEvent(float bInputType, float nPrimary, float nSecondary)
{
	float bSkipKey;
	bSkipKey = false;

	if (HUD_Panel_InputEvent(bInputType, nPrimary, nSecondary))
		return true;

	if (MapVote_InputEvent(bInputType, nPrimary, nSecondary))
		return true;

	if(menu_visible && menu_action)
		if(menu_action(bInputType, nPrimary, nSecondary))
			return TRUE;

	return bSkipKey;
}

// END REQUIRED CSQC FUNCTIONS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// BEGIN OPTIONAL CSQC FUNCTIONS
void Ent_RemoveEntCS()
{
	entcs_receiver[self.sv_entnum] = world;
}
void Ent_ReadEntCS()
{
	float sf;
	InterpolateOrigin_Undo();

	self.classname = "entcs_receiver";
	sf = ReadByte();

	if(sf & 1)
		self.sv_entnum = ReadByte();
	if(sf & 2)
	{
		self.origin_x = ReadShort();
		self.origin_y = ReadShort();
		self.origin_z = ReadShort();
		setorigin(self, self.origin);
	}
	if(sf & 4)
	{
		self.angles_y = ReadByte() * 360.0 / 256;
		self.angles_x = self.angles_z = 0;
	}
	if(sf & 8)
		self.healthvalue = ReadByte() * 10;
	if(sf & 16)
		self.armorvalue = ReadByte() * 10;

	entcs_receiver[self.sv_entnum] = self;
	self.entremove = Ent_RemoveEntCS;

	InterpolateOrigin_Note();
}

void Ent_Remove();

void Ent_RemovePlayerScore()
{
	float i;

	if(self.owner)
	{
		SetTeam(self.owner, -1);
		self.owner.gotscores = 0;
		for(i = 0; i < MAX_SCORE; ++i)
			self.owner.(scores[i]) = 0; // clear all scores
	}
}

void Ent_ReadPlayerScore()
{
	float i, n;
	float isNew;
	entity o;

	// damnit -.- don't want to go change every single .sv_entnum in hud.qc AGAIN
	// (no I've never heard of M-x replace-string, sed, or anything like that)
	isNew = !self.owner; // workaround for DP bug
	n = ReadByte()-1;

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if(!isNew && n != self.sv_entnum)
	{
		//print(_("A CSQC entity changed its owner!\n"));
		print(sprintf(_("A CSQC entity changed its owner! (edict: %d, classname: %s)\n"), num_for_edict(self), self.classname));
		isNew = true;
		Ent_Remove();
		self.enttype = ENT_CLIENT_SCORES;
	}
#endif

	self.sv_entnum = n;

	if not(playerslots[self.sv_entnum])
		playerslots[self.sv_entnum] = spawn();
	o = self.owner = playerslots[self.sv_entnum];
	o.sv_entnum = self.sv_entnum;
	o.gotscores = 1;

	//if not(o.sort_prev)
	//	RegisterPlayer(o);
	//playerchecker will do this for us later, if it has not already done so

	float sf, lf;
#if MAX_SCORE <= 8
	sf = ReadByte();
	lf = ReadByte();
#else
	sf = ReadShort();
	lf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_SCORE; ++i, p *= 2)
		if(sf & p)
		{
			if(lf & p)
				o.(scores[i]) = ReadInt24_t();
			else
				o.(scores[i]) = ReadChar();
		}

	if(o.sort_prev)
		HUD_UpdatePlayerPos(o); // if not registered, we cannot do this yet!

	self.entremove = Ent_RemovePlayerScore;
}

void Ent_ReadTeamScore()
{
	float i;
	entity o;

	self.team = ReadByte();
	o = self.owner = GetTeam(self.team, true); // these team numbers can always be trusted

	float sf, lf;
#if MAX_TEAMSCORE <= 8
	sf = ReadByte();
	lf = ReadByte();
#else
	sf = ReadShort();
	lf = ReadShort();
#endif
	float p;
	for(i = 0, p = 1; i < MAX_TEAMSCORE; ++i, p *= 2)
		if(sf & p)
		{
			if(lf & p)
				o.(teamscores[i]) = ReadInt24_t();
			else
				o.(teamscores[i]) = ReadChar();
		}

	HUD_UpdateTeamPos(o);
}

void Ent_ClientData()
{
	float f;
	float newspectatee_status;

	f = ReadByte();

	scoreboard_showscores_force = (f & 1);

	if(f & 2)
	{
		newspectatee_status = ReadByte();
		if(newspectatee_status == player_localnum + 1)
			newspectatee_status = -1; // observing
	}
	else
		newspectatee_status = 0;

	spectatorbutton_zoom = (f & 4);

	if(f & 8)
	{
		angles_held_status = 1;
		angles_held_x = ReadAngle();
		angles_held_y = ReadAngle();
		angles_held_z = 0;
	}
	else
		angles_held_status = 0;

	if(newspectatee_status != spectatee_status)
	{
		// clear race stuff
		race_laptime = 0;
		race_checkpointtime = 0;
	}
	if (autocvar_hud_panel_healtharmor_progressbar_gfx)
	{
		if ( (spectatee_status == -1 && newspectatee_status > 0) //before observing, now spectating
		  || (spectatee_status > 0 && newspectatee_status > 0 && spectatee_status != newspectatee_status) //changed spectated player
		)
			prev_p_health = -1;
		else if(spectatee_status && !newspectatee_status) //before observing/spectating, now playing
			prev_health = -1;
	}
	spectatee_status = newspectatee_status;

	// non-COMPAT_XON050_ENGINE: we could get rid of spectatee_status, and derive it from player_localentnum and player_localnum
}

void Ent_Nagger()
{
	float nags, i, j, b, f;

	nags = ReadByte(); // NAGS NAGS NAGS NAGS NAGS NAGS NADZ NAGS NAGS NAGS

	if(!(nags & 4))
	{
		if(vote_called_vote)
			strunzone(vote_called_vote);
		vote_called_vote = string_null;
		vote_active = 0;
	}
	else
	{
		vote_active = 1;
	}

	if(nags & 64)
	{
		vote_yescount = ReadByte();
		vote_nocount = ReadByte();
		vote_needed = ReadByte();
		vote_highlighted = ReadChar();
	}

	if(nags & 128)
	{
		if(vote_called_vote)
			strunzone(vote_called_vote);
		vote_called_vote = strzone(ColorTranslateRGB(ReadString()));
	}

	if(nags & 1)
	{
		for(j = 0; j < maxclients; ++j)
			if(playerslots[j])
				playerslots[j].ready = 1;
		for(i = 1; i <= maxclients; i += 8)
		{
			f = ReadByte();
			for(j = i-1, b = 1; b < 256; b *= 2, ++j)
				if not(f & b)
					if(playerslots[j])
						playerslots[j].ready = 0;
		}
	}

	ready_waiting = (nags & 1);
	ready_waiting_for_me = (nags & 2);
	vote_waiting = (nags & 4);
	vote_waiting_for_me = (nags & 8);
	warmup_stage = (nags & 16);
}

void Ent_RandomSeed()
{
	float s;
	prandom_debug();
	s = ReadShort();
	psrandom(s);
}

void Ent_ReadAccuracy(void)
{
	float sf, f, w, b;
	sf = ReadInt24_t();
	if(sf == 0)
	{
		for(w = 0; w <= WEP_LAST - WEP_FIRST; ++w)
			weapon_accuracy[w] = -1;
		return;
	}

	for(w = 0, f = 1; w <= WEP_LAST - WEP_FIRST; ++w)
	{
		if(sf & f)
		{
			b = ReadByte();
			if(b == 0)
				weapon_accuracy[w] = -1;
			else if(b == 255)
				weapon_accuracy[w] = 1.0; // no better error handling yet, sorry
			else
				weapon_accuracy[w] = (b - 1.0) / 100.0;
		}
		if(f == 0x800000)
			f = 1;
		else
			f *= 2;
	}
}

// CSQC_Ent_Update : Called every frame that the server has indicated an update to the SSQC / CSQC entity has occured.
// The only parameter reflects if the entity is "new" to the client, meaning it just came into the client's PVS.
void Ent_RadarLink();
void Ent_Init();
void Ent_ScoresInfo();
void CSQC_Ent_Update(float bIsNewEntity)
{
	float t;
	float savetime;
	t = ReadByte();

	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Ent_Update(%d) with self=%i self.entnum=%d self.enttype=%d t=%d\n", bIsNewEntity, self, self.entnum, self.enttype, t));

	// set up the "time" global for received entities to be correct for interpolation purposes
	savetime = time;
	if(servertime)
	{
		time = servertime;
	}
	else
	{
		serverprevtime = time;
		serverdeltatime = getstatf(STAT_MOVEVARS_TICRATE) * getstatf(STAT_MOVEVARS_TIMESCALE);
		time = serverprevtime + serverdeltatime;
	}

#ifdef DP_CSQC_ENTITY_REMOVE_IS_B0RKED
	if(self.enttype)
	{
		if(t != self.enttype || bIsNewEntity)
		{
			//print(_("A CSQC entity changed its type!\n"));
			print(sprintf(_("A CSQC entity changed its type! (edict: %d, server: %d, type: %d -> %d)\n"), num_for_edict(self), self.entnum, self.enttype, t));
			Ent_Remove();
			clearentity(self);
			bIsNewEntity = 1;
		}
	}
	else
	{
		if(!bIsNewEntity)
		{
			print(sprintf(_("A CSQC entity appeared out of nowhere! (edict: %d, server: %d, type: %d)\n"), num_for_edict(self), self.entnum, t));
			bIsNewEntity = 1;
		}
	}
#endif
	self.enttype = t;
	switch(t)
	{
		case ENT_CLIENT_ENTCS: Ent_ReadEntCS(); break;
		case ENT_CLIENT_SCORES: Ent_ReadPlayerScore(); break;
		case ENT_CLIENT_TEAMSCORES: Ent_ReadTeamScore(); break;
		case ENT_CLIENT_POINTPARTICLES: Ent_PointParticles(); break;
		case ENT_CLIENT_RAINSNOW: Ent_RainOrSnow(); break;
		case ENT_CLIENT_LASER: Ent_Laser(); break;
		case ENT_CLIENT_NAGGER: Ent_Nagger(); break;
		case ENT_CLIENT_WAYPOINT: Ent_WaypointSprite(); break;
		case ENT_CLIENT_RADARLINK: Ent_RadarLink(); break;
		case ENT_CLIENT_PROJECTILE: Ent_Projectile(); break;
		case ENT_CLIENT_GIBSPLASH: Ent_GibSplash(bIsNewEntity); break;
		case ENT_CLIENT_SMOKENADESPLASH: Ent_SmokenadeSplash(bIsNewEntity); break;
		case ENT_CLIENT_DAMAGEINFO: Ent_DamageInfo(bIsNewEntity); break;
		case ENT_CLIENT_CASING: Ent_Casing(bIsNewEntity); break;
		case ENT_CLIENT_INIT: Ent_Init(); break;
		case ENT_CLIENT_SCORES_INFO: Ent_ScoresInfo(); break;
		case ENT_CLIENT_MAPVOTE: Ent_MapVote(); break;
		case ENT_CLIENT_CLIENTDATA: Ent_ClientData(); break;
		case ENT_CLIENT_RANDOMSEED: Ent_RandomSeed(); break;
		case ENT_CLIENT_WALL: Ent_Wall(); break;
		case ENT_CLIENT_MODELEFFECT: Ent_ModelEffect(bIsNewEntity); break;
		case ENT_CLIENT_MODELEFFECT2: Ent_ModelEffect2(bIsNewEntity); break;
		case ENT_CLIENT_TUBANOTE: Ent_TubaNote(bIsNewEntity); break;
		case ENT_CLIENT_WARPZONE: WarpZone_Read(bIsNewEntity); break;
		case ENT_CLIENT_WARPZONE_CAMERA: WarpZone_Camera_Read(bIsNewEntity); break;
		case ENT_CLIENT_WARPZONE_TELEPORTED: WarpZone_Teleported_Read(bIsNewEntity); break;
		case ENT_CLIENT_TRIGGER_MUSIC: Ent_ReadTriggerMusic(); break;
		case ENT_CLIENT_HOOK: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_HOOK); break;
		case ENT_CLIENT_LGBEAM: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_LGBEAM); break;
		case ENT_CLIENT_FLAMETHROWERBEAM: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_FLAMETHROWERBEAM); break;
		case ENT_CLIENT_FROSTBEAM: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_FROSTBEAM); break;
		case ENT_CLIENT_POISONBEAM: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_POISONBEAM); break;
		case ENT_CLIENT_GAUNTLET: Ent_ReadHook(bIsNewEntity, ENT_CLIENT_GAUNTLET); break;
		case ENT_CLIENT_ACCURACY: Ent_ReadAccuracy(); break;
		case ENT_CLIENT_AUXILIARYXHAIR: Net_AuXair2(bIsNewEntity); break;
		case ENT_CLIENT_TURRET: ent_turret(); break; 
		case ENT_CLIENT_MODEL: CSQCModel_Read(bIsNewEntity); break;
		case ENT_CLIENT_ITEM: ItemRead(bIsNewEntity); break;  
		case ENT_CLIENT_BUMBLE_RAYGUN: bumble_raygun_read(bIsNewEntity); break;
		case ENT_CLIENT_SHUNDI_RAYGUN: shundi_raygun_read(bIsNewEntity); break;  
		default:
			//error(strcat(_("unknown entity type in CSQC_Ent_Update: %d\n"), self.enttype));
			error(sprintf(_("Unknown entity type in CSQC_Ent_Update (enttype: %d, edict: %d, classname: %s)\n"), self.enttype, num_for_edict(self), self.classname));
			break;
	}

	time = savetime;
}
// Destructor, but does NOT deallocate the entity by calling remove(). Also
// used when an entity changes its type. For an entity that someone interacts
// with others, make sure it can no longer do so.
void Ent_Remove()
{
	if(self.entremove)
		self.entremove();

	if(self.skeletonindex)
	{
		skel_delete(self.skeletonindex);
		self.skeletonindex = 0;
	}

	if(self.snd_looping > 0)
	{
		sound(self, self.snd_looping, "misc/null.wav", VOL_BASE, autocvar_g_jetpack_attenuation);
		self.snd_looping = 0;
	}

	self.enttype = 0;
	self.classname = "";
	self.draw = menu_sub_null;
	self.entremove = menu_sub_null;
	// TODO possibly set more stuff to defaults
}
// CSQC_Ent_Remove : Called when the server requests a SSQC / CSQC entity to be removed.  Essentially call remove(self) as well.
void CSQC_Ent_Remove()
{
	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Ent_Remove() with self=%i self.entnum=%d self.enttype=%d\n", self, self.entnum, self.enttype));

	if(wasfreed(self))
	{
		print("WARNING: CSQC_Ent_Remove called for already removed entity. Packet loss?\n");
		return;
	}
	if(self.enttype)
		Ent_Remove();
	remove(self);
}

void Gamemode_Init()
{
	if not(isdemo())
	{
		if(!(calledhooks & HOOK_START))
			localcmd("\n_cl_hook_gamestart ", MapInfo_Type_ToString(gametype), "\n");
		calledhooks |= HOOK_START;
	}
}
// CSQC_Parse_StuffCmd : Provides the stuffcmd string in the first parameter that the server provided.  To execute standard behavior, simply execute localcmd with the string.
void CSQC_Parse_StuffCmd(string strMessage)
{
	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Parse_StuffCmd(\"%s\")\n", strMessage));

	localcmd(strMessage);
}
// CSQC_Parse_Print : Provides the print string in the first parameter that the server provided.  To execute standard behavior, simply execute print with the string.
void CSQC_Parse_Print(string strMessage)
{
	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Parse_Print(\"%s\")\n", strMessage));

	print(ColorTranslateRGB(strMessage));
}

// CSQC_Parse_CenterPrint : Provides the centerprint_hud string in the first parameter that the server provided.
void CSQC_Parse_CenterPrint(string strMessage)
{
	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Parse_CenterPrint(\"%s\")\n", strMessage));

	centerprint_hud(strMessage);
}

string notranslate_fogcmd1 = "\nfog ";
string notranslate_fogcmd2 = "\nr_fog_exp2 0\nr_drawfog 1\n";
void Fog_Force()
{
	// TODO somehow thwart prvm_globalset client ...

	if(forcefog != "")
		localcmd(strcat(notranslate_fogcmd1, forcefog, notranslate_fogcmd2));
}

void Gamemode_Init();
void Ent_ScoresInfo()
{
	float i;
	self.classname = "ent_client_scores_info";
	gametype = ReadInt24_t();
	for(i = 0; i < MAX_SCORE; ++i)
	{
		scores_label[i] = strzone(ReadString());
		scores_flags[i] = ReadByte();
	}
	for(i = 0; i < MAX_TEAMSCORE; ++i)
	{
		teamscores_label[i] = strzone(ReadString());
		teamscores_flags[i] = ReadByte();
	}
	HUD_InitScores();
	Gamemode_Init();
}

void Ent_Init()
{
	self.classname = "ent_client_init";

	nb_pb_period = ReadByte() / 32; //Accuracy of 1/32th

	hook_shotorigin[0] = decompressShotOrigin(ReadInt24_t());
	hook_shotorigin[1] = decompressShotOrigin(ReadInt24_t());
	hook_shotorigin[2] = decompressShotOrigin(ReadInt24_t());
	hook_shotorigin[3] = decompressShotOrigin(ReadInt24_t());
	electro_shotorigin[0] = decompressShotOrigin(ReadInt24_t());
	electro_shotorigin[1] = decompressShotOrigin(ReadInt24_t());
	electro_shotorigin[2] = decompressShotOrigin(ReadInt24_t());
	electro_shotorigin[3] = decompressShotOrigin(ReadInt24_t());
	gauntlet_shotorigin[0] = decompressShotOrigin(ReadInt24_t());
	gauntlet_shotorigin[1] = decompressShotOrigin(ReadInt24_t());
	gauntlet_shotorigin[2] = decompressShotOrigin(ReadInt24_t());
	gauntlet_shotorigin[3] = decompressShotOrigin(ReadInt24_t());

	if(forcefog)
		strunzone(forcefog);
	forcefog = strzone(ReadString());

	armorblockpercent = ReadByte() / 255.0;

	g_weaponswitchdelay = ReadByte() / 255.0;

	g_balance_grenadelauncher_bouncefactor = ReadCoord();
	g_balance_grenadelauncher_bouncestop = ReadCoord();
	g_balance_electro_secondary_bouncefactor = ReadCoord();
	g_balance_electro_secondary_bouncestop = ReadCoord();

	nex_scope = !ReadByte();
	rifle_scope = !ReadByte();

	serverflags = ReadByte();

	minelayer_maxmines = ReadByte();

	hagar_maxrockets = ReadByte();

	g_trueaim_minrange = ReadCoord();
	g_balance_porto_secondary = ReadByte();

	if(!postinit)
		PostInit();
}

void Net_ReadRace()
{
	float b;

	b = ReadByte();

	switch(b)
	{
		case RACE_NET_CHECKPOINT_HIT_QUALIFYING:
			race_checkpoint = ReadByte();
			race_time = ReadInt24_t();
			race_previousbesttime = ReadInt24_t();
			if(race_previousbestname)
				strunzone(race_previousbestname);
			race_previousbestname = strzone(ColorTranslateRGB(ReadString()));

			race_checkpointtime = time;

			if(race_checkpoint == 0 || race_checkpoint == 254)
			{
				race_penaltyaccumulator = 0;
				race_laptime = time; // valid
			}

			break;

		case RACE_NET_CHECKPOINT_CLEAR:
			race_laptime = 0;
			race_checkpointtime = 0;
			break;

		case RACE_NET_CHECKPOINT_NEXT_SPEC_QUALIFYING:
			race_laptime = ReadCoord();
			race_checkpointtime = -99999;
			// fall through
		case RACE_NET_CHECKPOINT_NEXT_QUALIFYING:
			race_nextcheckpoint = ReadByte();

			race_nextbesttime = ReadInt24_t();
			if(race_nextbestname)
				strunzone(race_nextbestname);
			race_nextbestname = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_CHECKPOINT_HIT_RACE:
			race_mycheckpoint = ReadByte();
			race_mycheckpointtime = time;
			race_mycheckpointdelta = ReadInt24_t();
			race_mycheckpointlapsdelta = ReadByte();
			if(race_mycheckpointlapsdelta >= 128)
				race_mycheckpointlapsdelta -= 256;
			if(race_mycheckpointenemy)
				strunzone(race_mycheckpointenemy);
			race_mycheckpointenemy = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_CHECKPOINT_HIT_RACE_BY_OPPONENT:
			race_othercheckpoint = ReadByte();
			race_othercheckpointtime = time;
			race_othercheckpointdelta = ReadInt24_t();
			race_othercheckpointlapsdelta = ReadByte();
			if(race_othercheckpointlapsdelta >= 128)
				race_othercheckpointlapsdelta -= 256;
			if(race_othercheckpointenemy)
				strunzone(race_othercheckpointenemy);
			race_othercheckpointenemy = strzone(ColorTranslateRGB(ReadString()));
			break;

		case RACE_NET_PENALTY_RACE:
			race_penaltyeventtime = time;
			race_penaltytime = ReadShort();
			//race_penaltyaccumulator += race_penaltytime;
			if(race_penaltyreason)
				strunzone(race_penaltyreason);
			race_penaltyreason = strzone(ReadString());
			break;

		case RACE_NET_PENALTY_QUALIFYING:
			race_penaltyeventtime = time;
			race_penaltytime = ReadShort();
			race_penaltyaccumulator += race_penaltytime;
			if(race_penaltyreason)
				strunzone(race_penaltyreason);
			race_penaltyreason = strzone(ReadString());
			break;

		case RACE_NET_SERVER_RECORD:
			race_server_record = ReadInt24_t();
			break;
		case RACE_NET_SPEED_AWARD:
			race_speedaward = ReadInt24_t();
			if(race_speedaward_holder)
				strunzone(race_speedaward_holder);
			race_speedaward_holder = strzone(ReadString());
			break;
		case RACE_NET_SPEED_AWARD_BEST:
			race_speedaward_alltimebest = ReadInt24_t();
			if(race_speedaward_alltimebest_holder)
				strunzone(race_speedaward_alltimebest_holder);
			race_speedaward_alltimebest_holder = strzone(ReadString());
			break;
		case RACE_NET_SERVER_RANKINGS:
			float pos, prevpos, del;
			pos = ReadShort();
			prevpos = ReadShort();
			del = ReadShort();

			// move other rankings out of the way
			float i;
			if (prevpos) {
				for (i=prevpos-1;i>pos-1;--i) {
					grecordtime[i] = grecordtime[i-1];
					if(grecordholder[i])
						strunzone(grecordholder[i]);
					grecordholder[i] = strzone(grecordholder[i-1]);
				}
			} else if (del) { // a record has been deleted by the admin
				for (i=pos-1; i<= RANKINGS_CNT-1; ++i) {
					if (i == RANKINGS_CNT-1) { // clear out last record
						grecordtime[i] = 0;
						if (grecordholder[i])
							strunzone(grecordholder[i]);
						grecordholder[i] = string_null;
					}
					else {
						grecordtime[i] = grecordtime[i+1];
						if (grecordholder[i])
							strunzone(grecordholder[i]);
						grecordholder[i] = strzone(grecordholder[i+1]);
					}
				}
			} else { // player has no ranked record yet
				for (i=RANKINGS_CNT-1;i>pos-1;--i) {
					grecordtime[i] = grecordtime[i-1];
					if(grecordholder[i])
						strunzone(grecordholder[i]);
					grecordholder[i] = strzone(grecordholder[i-1]);
				}
			}

			// store new ranking
			if(grecordholder[pos-1] != "")
				strunzone(grecordholder[pos-1]);
			grecordholder[pos-1] = strzone(ReadString());
			grecordtime[pos-1] = ReadInt24_t();
			if(grecordholder[pos-1] == GetPlayerName(player_localnum))
				race_myrank = pos;
			break;
		case RACE_NET_SERVER_STATUS:
			race_status = ReadShort();
			if(race_status_name)
				strunzone(race_status_name);
			race_status_name = strzone(ReadString());
	}
}

void Net_ReadSpawn()
{
	zoomin_effect = 1;
	current_viewzoom = 0.6;
}

void Net_TeamNagger()
{
	teamnagger = 1;
}

void Net_ReadPingPLReport()
{
	float e, pi, pl, ml;
	e = ReadByte();
	pi = ReadShort();
	pl = ReadByte();
	ml = ReadByte();
	if not(playerslots[e])
		return;
	playerslots[e].ping = pi;
	playerslots[e].ping_packetloss = pl / 255.0;
	playerslots[e].ping_movementloss = ml / 255.0;
}

void Net_WeaponComplain() {
	complain_weapon = ReadByte();

	if(complain_weapon_name)
		strunzone(complain_weapon_name);
	complain_weapon_name = strzone(ReadString());

	complain_weapon_type = ReadByte();

	complain_weapon_time = time;
	weapontime = time; // ping the weapon panel
}

// CSQC_Parse_TempEntity : Handles all temporary entity network data in the CSQC layer.
// You must ALWAYS first acquire the temporary ID, which is sent as a byte.
// Return value should be 1 if CSQC handled the temporary entity, otherwise return 0 to have the engine process the event.
float CSQC_Parse_TempEntity()
{
	float bHandled;
		bHandled  = true;
	// Acquire TE ID
	float nTEID;
		nTEID = ReadByte();

	if(autocvar_developer_csqcentities)
		print(sprintf("CSQC_Parse_TempEntity() with nTEID=%d\n", nTEID));

		// NOTE: Could just do return instead of break...
	switch(nTEID)
	{
		case TE_CSQC_TARGET_MUSIC:
			Net_TargetMusic();
			bHandled = true;
			break;
		case TE_CSQC_PICTURE:
			Net_MapVote_Picture();
			bHandled = true;
			break;
		case TE_CSQC_RACE:
			Net_ReadRace();
			bHandled = true;
			break;
		case TE_CSQC_SPAWN:
			Net_ReadSpawn();
			bHandled = true;
			break;
		case TE_CSQC_ZCURVEPARTICLES:
			Net_ReadZCurveParticles();
			bHandled = true;
			break;
		case TE_CSQC_NEXGUNBEAMPARTICLE:
			Net_ReadNexgunBeamParticle();
			bHandled = true;
			break;
		case TE_CSQC_TEAMNAGGER:
			Net_TeamNagger();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARC:
			Net_ReadLightningarc();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARCB:
			Net_ReadLightningarcb();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARCC:
			Net_ReadLightningarcc();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARCD:
			Net_ReadLightningarcd();
			bHandled = true;
			break;
		case TE_CSQC_LIGHTNINGARCP:
			Net_ReadLightningarcp();
			bHandled = true;
			break;
		case TE_CSQC_FIREARC:
			Net_ReadFirearc();
			bHandled = true;
			break;
		case TE_CSQC_PINGPLREPORT:
			Net_ReadPingPLReport();
			bHandled = true;
			break;
		case TE_CSQC_ANNOUNCE:
			Announcer_Play(ReadString());
			bHandled = true;
			break;
		case TE_CSQC_KILLNOTIFY:
			HUD_KillNotify(ReadString(), ReadString(), ReadString(), ReadShort(), ReadByte());
			bHandled = true;
			break;
		case TE_CSQC_KILLCENTERPRINT:
			HUD_KillCenterprint(ReadString(), ReadString(), ReadShort(), ReadByte());
			bHandled = true;
			break;
		case TE_CSQC_CENTERPRINT_GENERIC:
			float id;
			string s;
			id = ReadByte();
			s = ReadString();
			if (id != 0 && s != "")
				centerprint_generic(id, s, ReadByte(), ReadByte());
			else
				centerprint_generic(id, s, 0, 0);
			bHandled = true;
			break;
		case TE_CSQC_WEAPONCOMPLAIN:
			Net_WeaponComplain();
			bHandled = true;
			break;
		case TE_CSQC_VEHICLESETUP:
			Net_VehicleSetup();
			bHandled = true;
			break;
		case TE_CSQC_SVNOTICE:
			cl_notice_read();
			bHandled = true;
			break;
		default:
			// No special logic for this temporary entity; return 0 so the engine can handle it
			bHandled = false;
			break;
	}

	return bHandled;
}

string getcommandkey(string text, string command)
{
	string keys;
	float n, j, k, l = 0;

	if (!autocvar_hud_showbinds)
		return text;

	keys = db_get(binddb, command);
	if (keys == "")
	{
		n = tokenize(findkeysforcommand(command, 0)); // uses '...' strings
		for(j = 0; j < n; ++j)
		{
			k = stof(argv(j));
			if(k != -1)
			{
				if ("" == keys)
					keys = keynumtostring(k);
				else
					keys = strcat(keys, ", ", keynumtostring(k));

				++l;
				if (autocvar_hud_showbinds_limit > 0 && autocvar_hud_showbinds_limit >= l) break;
			}

		}
		if (keys == "")
			keys = "NO_KEY";
		db_put(binddb, command, keys);
	}

	if (keys == "NO_KEY") {
		if (autocvar_hud_showbinds > 1)
			return sprintf(_("%s (not bound)"), text);
		else
			return text;
	}
	else if (autocvar_hud_showbinds > 1)
		return sprintf(_("%s (%s)"), text, keys);
	else
		return keys;
}
