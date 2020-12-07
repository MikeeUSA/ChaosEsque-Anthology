#define LATENCY_THINKRATE 10
.float latency_sum;
.float latency_cnt;
.float latency_time;
entity pingplreport;
void PingPLReport_Think()
{
	float delta;
	entity e;

	delta = 3 / maxclients;
	if(delta < sys_frametime)
		delta = 0;
	self.nextthink = time + delta;

	e = edict_num(self.cnt + 1);
	if(clienttype(e) == CLIENTTYPE_REAL)
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, max(1, e.ping));
		WriteByte(MSG_BROADCAST, ceil(e.ping_packetloss * 255));
		WriteByte(MSG_BROADCAST, ceil(e.ping_movementloss * 255));

		// record latency times for clients throughout the match so we can report it to playerstats
		if(time > (e.latency_time + LATENCY_THINKRATE))
		{
			e.latency_sum += e.ping;
			e.latency_cnt += 1;
			e.latency_time = time;
			//print("sum: ", ftos(e.latency_sum), ", cnt: ", ftos(e.latency_cnt), ", avg: ", ftos(e.latency_sum / e.latency_cnt), ".\n");
		}
	}
	else
	{
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_PINGPLREPORT);
		WriteByte(MSG_BROADCAST, self.cnt);
		WriteShort(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
		WriteByte(MSG_BROADCAST, 0);
	}
	self.cnt = mod(self.cnt + 1, maxclients);
}
void PingPLReport_Spawn()
{
	pingplreport = spawn();
	pingplreport.classname = "pingplreport";
	pingplreport.think = PingPLReport_Think;
	pingplreport.nextthink = time;
}

float SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS = 1;
string redirection_target;
float world_initialized;

string GetMapname();
string GetGametype();
void GotoNextMap(float reinit);
void ShuffleMaplist();
float(float reinit) DoNextMapOverride;

void SetDefaultAlpha()
{
	if(autocvar_g_running_guns)
	{
		default_player_alpha = -1;
		default_weapon_alpha = +1;
	}
	else if(g_cloaked)
	{
		default_player_alpha = autocvar_g_balance_cloaked_alpha;
		default_weapon_alpha = default_player_alpha;
	}
	else
	{
		default_player_alpha = autocvar_g_player_alpha;
		if(default_player_alpha == 0)
			default_player_alpha = 1;
		default_weapon_alpha = default_player_alpha;
	}
}

void fteqcc_testbugs()
{
	float a, b;

	if(!autocvar_developer_fteqccbugs)
		return;

	dprint("*** fteqcc test: checking for bugs...\n");

	a = 1;
	b = 5;
	if(sqrt(a) - sqrt(b - a) == 0)
		dprint("*** fteqcc test: found same-function-twice bug\n");
	else
		dprint("*** fteqcc test: same-function-twice bug got FINALLY FIXED! HOORAY!\n");

	world.cnt = -10;
	world.enemy = world;
	world.enemy.cnt += 10;
	if(world.cnt > 0.2 || world.cnt < -0.2) // don't error out if it's just roundoff errors
		dprint("*** fteqcc test: found += bug\n");
	else
		dprint("*** fteqcc test: += bug got FINALLY FIXED! HOORAY!\n");
	world.cnt = 0;
}

void GotoFirstMap()
{
	float n;
	if(autocvar__sv_init)
	{
		// cvar_set("_sv_init", "0");
		// we do NOT set this to 0 any more, so someone "accidentally" changing
		// to this "init" map on a dedicated server will cause no permanent
		// harm
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		n = tokenizebyseparator(autocvar_g_maplist, " ");
		cvar_set("g_maplist_index", ftos(n - 1)); // jump to map 0 in GotoNextMap

		MapInfo_Enumerate();
		MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);

		if(!DoNextMapOverride(1))
			GotoNextMap(1);

		return;
	}

	if(time < 5)
	{
		self.nextthink = time;
	}
	else
	{
		self.nextthink = time + 1;
		print("Waiting for _sv_init being set to 1 by initialization scripts...\n");
	}
}

void cvar_changes_init()
{
	float h;
	string k, v, d;
	float n, i, adding, pureadding;

	if(cvar_changes)
		strunzone(cvar_changes);
	cvar_changes = string_null;
	if(cvar_purechanges)
		strunzone(cvar_purechanges);
	cvar_purechanges = string_null;
	cvar_purechanges_count = 0;

	h = buf_create();
	buf_cvarlist(h, "", "_"); // exclude all _ cvars as they are temporary
	n = buf_getsize(h);

	adding = TRUE;
	pureadding = TRUE;

	for(i = 0; i < n; ++i)
	{
		k = bufstr_get(h, i);

#define BADPREFIX(p) if(substring(k, 0, strlen(p)) == p) continue
#define BADPRESUFFIX(p,s) if(substring(k, 0, strlen(p)) == p && substring(k, -strlen(s), -1) == s) continue
#define BADCVAR(p) if(k == p) continue

		// general excludes and namespaces for server admin used cvars
		BADPREFIX("help_"); // PN's server has this listed as changed, let's not rat him out for THAT

		// internal
		BADPREFIX("csqc_");
		BADPREFIX("cvar_check_");
		BADCVAR("gamecfg");
		BADCVAR("g_configversion");
		BADCVAR("g_maplist_index");
		BADCVAR("halflifebsp");
		BADPREFIX("sv_world");

		// client
		BADPREFIX("chase_");
		BADPREFIX("cl_");
		BADPREFIX("con_");
		BADPREFIX("scoreboard_");
		BADPREFIX("g_campaign");
		BADPREFIX("g_waypointsprite_");
		BADPREFIX("gl_");
		BADPREFIX("joy");
		BADPREFIX("hud_");
		BADPREFIX("m_");
		BADPREFIX("menu_");
		BADPREFIX("net_slist_");
		BADPREFIX("r_");
		BADPREFIX("sbar_");
		BADPREFIX("scr_");
		BADPREFIX("snd_");
		BADPREFIX("show");
		BADPREFIX("sensitivity");
		BADPREFIX("userbind");
		BADPREFIX("v_");
		BADPREFIX("vid_");
		BADPREFIX("crosshair");
		BADCVAR("mod_q3bsp_lightmapmergepower");
		BADCVAR("mod_q3bsp_nolightmaps");
		BADCVAR("fov");
		BADCVAR("mastervolume");
		BADCVAR("volume");
		BADCVAR("bgmvolume");

		// private
		BADCVAR("developer");
		BADCVAR("log_dest_udp");
		BADCVAR("log_file");
		BADCVAR("net_address");
		BADCVAR("net_address_ipv6");
		BADCVAR("port");
		BADCVAR("savedgamecfg");
		BADCVAR("serverconfig");
		BADCVAR("sv_autoscreenshot");
		BADCVAR("sv_heartbeatperiod");
		BADCVAR("sv_vote_master_password");
		BADCVAR("sys_colortranslation");
		BADCVAR("sys_specialcharactertranslation");
		BADCVAR("timeformat");
		BADCVAR("timestamps");
		BADPREFIX("developer_");
		BADPREFIX("g_ban_");
		BADPREFIX("g_banned_list");
		BADPREFIX("g_chat_flood_");
		BADPREFIX("g_ghost_items");
		BADPREFIX("g_playerstats_");
		BADPREFIX("g_respawn_ghosts");
		BADPREFIX("g_voice_flood_");
		BADPREFIX("rcon_");
		BADPREFIX("sv_allowdownloads");
		BADPREFIX("sv_autodemo");
		BADPREFIX("sv_curl_");
		BADPREFIX("sv_eventlog");
		BADPREFIX("sv_logscores_");
		BADPREFIX("sv_master");
		BADPREFIX("sv_weaponstats_");
		BADPREFIX("sv_waypointsprite_");
		BADCVAR("rescan_pending");

		// these can contain player IDs, so better hide
		BADPREFIX("g_forced_team_");

		// mapinfo
		BADCVAR("fraglimit");
		BADCVAR("g_arena");
		BADCVAR("g_assault");
		BADCVAR("g_ca");
		BADCVAR("g_ctf");
		BADCVAR("g_cts");
		BADCVAR("g_dm");
		BADCVAR("g_domination");
		BADCVAR("g_domination_default_teams");
		BADCVAR("g_freezetag");
		BADCVAR("g_keepaway");
		BADCVAR("g_keyhunt");
		BADCVAR("g_keyhunt_teams");
		BADCVAR("g_keyhunt_teams");
		BADCVAR("g_lms");
		BADCVAR("g_nexball");
		BADCVAR("g_onslaught");
		BADCVAR("g_race");
		BADCVAR("g_race_qualifying_timelimit");
		BADCVAR("g_runematch");
		BADCVAR("g_tdm");
		BADCVAR("g_tdm_teams");
		BADCVAR("leadlimit");
		BADCVAR("nextmap");
		BADCVAR("teamplay");
		BADCVAR("timelimit");

		// long
		BADCVAR("hostname");
		BADCVAR("g_maplist");
		BADCVAR("g_maplist_mostrecent");
		BADCVAR("sv_motd");

		v = cvar_string(k);
		d = cvar_defstring(k);
		if(v == d)
			continue;

		if(adding)
		{
			cvar_changes = strcat(cvar_changes, k, " \"", v, "\" // \"", d, "\"\n");
			if(strlen(cvar_changes) > 16384)
			{
				cvar_changes = "// too many settings have been changed to show them here\n";
				adding = 0;
			}
		}

		// now check if the changes are actually gameplay relevant

		// does nothing visible
		BADCVAR("captureleadlimit_override");
		BADCVAR("g_arena_point_leadlimit");
		BADCVAR("g_balance_kill_delay");
		BADCVAR("g_ca_point_leadlimit");
		BADCVAR("g_ctf_captimerecord_always");
		BADCVAR("g_ctf_flag_glowtrails");
		BADCVAR("g_ctf_flag_pickup_verbosename");
		BADCVAR("g_domination_point_leadlimit");
		BADCVAR("g_forced_respawn");
		BADCVAR("g_keyhunt_point_leadlimit");
		BADPREFIX("g_mod_");
		BADCVAR("g_nexball_goalleadlimit");
		BADCVAR("g_runematch_point_leadlimit");
		BADCVAR("leadlimit_and_fraglimit");
		BADCVAR("leadlimit_override");
		BADCVAR("pausable");
		BADCVAR("sv_allow_fullbright");
		BADCVAR("sv_checkforpacketsduringsleep");
		BADCVAR("sv_fraginfo");
		BADCVAR("sv_timeout");
		BADPREFIX("sv_timeout_");
		BADCVAR("welcome_message_time");
		BADPREFIX("crypto_");
		BADPREFIX("g_chat_");
		BADPREFIX("g_ctf_captimerecord_");
		BADPREFIX("g_maplist_votable_");
		BADPREFIX("net_");
		BADPREFIX("prvm_");
		BADPREFIX("skill_");
		BADPREFIX("sv_cullentities_");
		BADPREFIX("sv_fraginfo_");
		BADPREFIX("sv_maxidle_");
		BADPREFIX("sv_vote_");
		BADPREFIX("timelimit_");
		BADCVAR("gameversion");
		BADPREFIX("gameversion_");
		BADCVAR("sv_namechangetimer");
#ifndef NO_LEGACY_NETWORKING
		BADCVAR("sv_use_csqc_players"); // transition
#endif

		// allowed changes to server admins (please sync this to server.cfg)
		// vi commands:
		//   :/"impure"/,$d
		//   :g!,^\/\/[^ /],d
		//   :%s,//\([^ ]*\).*,BADCVAR("\1");,
		//   :%!sort
		// yes, this does contain some redundant stuff, don't really care
		BADCVAR("bot_config_file");
		BADCVAR("bot_number");
		BADCVAR("bot_prefix");
		BADCVAR("bot_suffix");
		BADCVAR("capturelimit_override");
		BADCVAR("fraglimit_override");
		BADCVAR("gametype");
		BADCVAR("g_antilag");
		BADCVAR("g_balance_teams");
		BADCVAR("g_balance_teams_prevent_imbalance");
		BADCVAR("g_balance_teams_scorefactor");
		BADCVAR("g_ban_sync_trusted_servers");
		BADCVAR("g_ban_sync_uri");
		BADCVAR("g_ctf_ignore_frags");
		BADCVAR("g_domination_point_limit");
		BADCVAR("g_friendlyfire");
		BADCVAR("g_fullbrightitems");
		BADCVAR("g_fullbrightplayers");
		BADCVAR("g_keyhunt_point_limit");
		BADCVAR("g_keyhunt_teams_override");
		BADCVAR("g_lms_lives_override");
		BADCVAR("g_maplist");
		BADCVAR("g_maplist_check_waypoints");
		BADCVAR("g_maplist_mostrecent_count");
		BADCVAR("g_maplist_shuffle");
		BADCVAR("g_maplist_votable");
		BADCVAR("g_maplist_votable_abstain");
		BADCVAR("g_maplist_votable_nodetail");
		BADCVAR("g_maplist_votable_suggestions");
		BADCVAR("g_maxplayers");
		BADCVAR("g_mirrordamage");
		BADCVAR("g_nexball_goallimit");
		BADCVAR("g_powerups");
		BADCVAR("g_runematch_point_limit");
		BADCVAR("g_start_delay");
		BADCVAR("g_warmup");
		BADCVAR("g_weapon_stay"); BADPRESUFFIX("g_", "_weapon_stay");
		BADCVAR("hostname");
		BADCVAR("log_file");
		BADCVAR("maxplayers");
		BADCVAR("minplayers");
		BADCVAR("net_address");
		BADCVAR("port");
		BADCVAR("rcon_password");
		BADCVAR("rcon_restricted_commands");
		BADCVAR("rcon_restricted_password");
		BADCVAR("skill");
		BADCVAR("sv_adminnick");
		BADCVAR("sv_autoscreenshot");
		BADCVAR("sv_autotaunt");
		BADCVAR("sv_curl_defaulturl");
		BADCVAR("sv_defaultcharacter");
		BADCVAR("sv_defaultplayercolors");
		BADCVAR("sv_defaultplayermodel");
		BADCVAR("sv_defaultplayerskin");
		BADCVAR("sv_maxidle");
		BADCVAR("sv_maxrate");
		BADCVAR("sv_motd");
		BADCVAR("sv_public");
		BADCVAR("sv_ready_restart");
		BADCVAR("sv_status_privacy");
		BADCVAR("sv_taunt");
		BADCVAR("sv_vote_call");
		BADCVAR("sv_vote_commands");
		BADCVAR("sv_vote_majority_factor");
		BADCVAR("sv_vote_master");
		BADCVAR("sv_vote_master_commands");
		BADCVAR("sv_vote_master_password");
		BADCVAR("sv_vote_simple_majority_factor");
		BADCVAR("sys_ticrate");
		BADCVAR("teamplay_mode");
		BADCVAR("timelimit_override");
		BADCVAR("g_spawnshieldtime");
		BADPREFIX("g_warmup_");
		BADPREFIX("sv_ready_restart_");

		// mutators that announce themselves properly to the server browser
		BADCVAR("g_minstagib");
		BADCVAR("g_new_toys");
		BADCVAR("g_nix");

		if(autocvar_g_minstagib)
		{
			BADCVAR("g_grappling_hook");
			BADCVAR("g_jetpack");
		}
#undef BADPREFIX
#undef BADCVAR

		if(pureadding)
		{
			cvar_purechanges = strcat(cvar_purechanges, k, " \"", v, "\" // \"", d, "\"\n");
			if(strlen(cvar_purechanges) > 16384)
			{
				cvar_purechanges = "// too many settings have been changed to show them here\n";
				pureadding = 0;
			}
		}
		++cvar_purechanges_count;
		// WARNING: this variable is used for the server list
		// NEVER dare to skip this code!
		// Hacks to intentionally appearing as "pure server" even though you DO have
		// modified settings may be punished by removal from the server list.
		// You can do to the variables cvar_changes and cvar_purechanges all you want,
		// though.
	}
	buf_del(h);
	if(cvar_changes == "")
		cvar_changes = "// this server runs at default server settings\n";
	else
		cvar_changes = strcat("// this server runs at modified server settings:\n", cvar_changes);
	cvar_changes = strzone(cvar_changes);
	if(cvar_purechanges == "")
		cvar_purechanges = "// this server runs at default gameplay settings\n";
	else
		cvar_purechanges = strcat("// this server runs at modified gameplay settings:\n", cvar_purechanges);
	cvar_purechanges = strzone(cvar_purechanges);
}

void detect_maptype()
{
#if 0
	vector o, v;
	float i;

	for(;;)
	{
		o = world.mins;
		o_x += random() * (world.maxs_x - world.mins_x);
		o_y += random() * (world.maxs_y - world.mins_y);
		o_z += random() * (world.maxs_z - world.mins_z);

		tracebox(o, PL_MIN, PL_MAX, o - '0 0 32768', MOVE_WORLDONLY, world);
		if(trace_fraction == 1)
			continue;

		v = trace_endpos;

		for(i = 0; i < 64; i += 4)
		{
			tracebox(o, '-1 -1 -1' * i, '1 1 1' * i, o - '0 0 32768', MOVE_WORLDONLY, world);
	if(trace_fraction == 1)
		continue;
			print(ftos(i), " -> ", vtos(trace_endpos), "\n");
		}

		break;
	}
#endif
}

entity randomseed;
float RandomSeed_Send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_RANDOMSEED);
	WriteShort(MSG_ENTITY, self.cnt);
	return TRUE;
}
void RandomSeed_Think()
{
	self.cnt = bound(0, floor(random() * 65536), 65535);
	self.nextthink = time + 5;

	self.SendFlags |= 1;
}
void RandomSeed_Spawn()
{
	randomseed = spawn();
	randomseed.think = RandomSeed_Think;
	Net_LinkEntity(randomseed, FALSE, 0, RandomSeed_Send);

	entity oldself;
	oldself = self;
	self = randomseed;
	self.think(); // sets random seed and nextthink
	self = oldself;
}

void spawnfunc___init_dedicated_server(void)
{
	// handler for _init/_init map (only for dedicated server initialization)

	world_initialized = -1; // don't complain
	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	remove = remove_unsafely;

	entity e;
	e = spawn();
	e.think = GotoFirstMap;
	e.nextthink = time; // this is usually 1 at this point

	e = spawn();
	e.classname = "info_player_deathmatch"; // safeguard against player joining

	self.classname = "worldspawn"; // safeguard against various stuff ;)

	// needs to be done so early because of the constants they create
	CALL_ACCUMULATED_FUNCTION(RegisterWeapons);
	CALL_ACCUMULATED_FUNCTION(RegisterGametypes);

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 0);
}

float Foliage_Suggested_Uses_Groves(void);

void shinrae_precache_growls();
void shinrae_precache_weapons();
void aocyborg_precache_growls();
void aocyborg_precache_weapons();
void horndemon_precache_weapons();
void hell_knight_precache_weapons();
void ninjaassassin_precache_weapons();
void goblin_precache_weapons();
void minotaur_precache_weapons();
void seraph_precache_weapons();
void knight_precacheforothers();
void soldier_precacheforothers();
void police_precache_weapons();
void skeleton_precache_weapons();
void imp_precache_weapons();
void biledemon_precache_weapons();
void fighter_precacheforothers();
void Foliage_Presets_Precache(void);
void Foliage_Presets_Set(float p);
void Foliage_GetAutoCvars_Precache(void);
void W_crossbowdtwr_precache_arrowsounds(void);

void warpzonedefaults_forworld (void)
{
	g_warpzone_defaults_enabled = 0;
	if (autocvar_sv_gameplayfix_warpzone_suggested) {
		//This is for making sure our settings are for the current map
		//Not a holdover from a crashed map
		if (autocvar_sv_gameplayfix_warpzone_suggested_mapnamecontains == "") {
			//Do nothing
		} else if (strlennocol(autocvar_sv_gameplayfix_warpzone_suggested_mapnamecontains) >= 3) {
			
			//print(ftos(strlennocol(autocvar_sv_gameplayfix_warpzone_suggested_mapnamecontains)),"\n");
			//Must be atleast 3 chars long, color ignored

			if (strstrofs(mapname, autocvar_sv_gameplayfix_warpzone_suggested_mapnamecontains, 0) != -1 )
			{
				g_warpzone_defaults_enabled = 1;
				print("***\n***\n***\n***Enabling Warpzone GameplayFix Defaults***\n***\n***\n***\n");
			}
		}
	}
}

void precachestuff_forworld (void)
{
	precache_sound("resource/construction/con_stone_10.ogg"); //Used for some pickups and containers

	precache_model ("models/decalbulletholeglass.iqm");
	precache_model ("models/glassshardtriangle.iqm");
	precache_model ("models/glassshardtriangle2.iqm");
	precache_model ("models/glassshardtriangle3.iqm");
	precache_sound ("glassbreaking/mirrorbreaking.ogg");
	precache_sound ("glassbreaking/glassbreaking.ogg");
	precache_sound ("glassbreaking/lightbulbbreaking.ogg");
	
	precache_sound ("flare/fantasycore/level-up.ogg");
	
	if (cvar("mapforcerndmaddtnlfurn_barrel_wood2_amnt")
	|| cvar("rndmaddtnlfurn_barrel_wood2_amnt")) {
		//print("\n\n\n******PRECACHE BARREL******\n\n\n");
		precache_model ("models/barrels/barrel_wooden.iqm");
		precache_model ("maps/buildables/rubble_woodbar_block64.bsp");
	}
	
	if (cvar("mapforcerndmaddtnlfurn_chest_wood_amnt")
	|| cvar("rndmaddtnlfurn_chest_wood_amnt")) {
		precache_model ("models/containers/cassapanca.iqm");
		precache_model ("maps/buildables/rubble_woodbar_block64.bsp");
	}
	
	if (cvar("mapforcerndmaddtnlfurn_chestlarge_wood_amnt")
	|| cvar("rndmaddtnlfurn_chestlarge_wood_amnt")) {
		precache_model ("models/containers/largechest1.iqm");
		precache_model ("maps/buildables/rubble_woodbar_block64.bsp");
	}
	
	if (cvar("g_balance_multitool_barrel_wood2_trap")
	|| cvar("g_balance_multitool_chest_wood_trap")
	|| cvar("g_balance_multitool_chestlarge_wood_trap")
	) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_sound ("ardentryst/flame_whoosh.ogg");
		W_crossbowdtwr_precache_arrowsounds();
	}

	//Some models and sounds for spells if anyone has been given them at start
	if(cvar("g_start_spell_scepterofflame")
	|| cvar("g_start_spell_team1_scepterofflame")
	|| cvar("g_start_spell_team2_scepterofflame")
	|| cvar("g_start_spell_team3_scepterofflame")
	|| cvar("g_start_spell_team4_scepterofflame")) {
		precache_model ("models/misc/cylinderexpfire.iqm");
		precache_sound ("misc/ignition_firewall.ogg");
	}
	
	if(cvar("g_start_spell_vampyricconduit")
	|| cvar("g_start_spell_team1_vampyricconduit")
	|| cvar("g_start_spell_team2_vampyricconduit")
	|| cvar("g_start_spell_team3_vampyricconduit")
	|| cvar("g_start_spell_team4_vampyricconduit")) {
		precache_model ("models/circles/magiccircle.iqm");
	}
	
	if(cvar("g_start_spell_grace")
	|| cvar("g_start_spell_team1_grace")
	|| cvar("g_start_spell_team2_grace")
	|| cvar("g_start_spell_team3_grace")
	|| cvar("g_start_spell_team4_grace")) {
		precache_model ("models/circles/magiccircle.iqm");
		precache_sound ("ardentryst/Obelisk.ogg");
		precache_sound ("ardentryst/Maea.ogg");
	}
	
	if(cvar("g_start_spell_manashield")
	|| cvar("g_start_spell_team1_manashield")
	|| cvar("g_start_spell_team2_manashield")
	|| cvar("g_start_spell_team3_manashield")
	|| cvar("g_start_spell_team4_manashield")) {
		precache_sound ("relics/relic_effect.wav");
	}
	
	if(cvar("g_start_spell_clairvoyance")
	|| cvar("g_start_spell_team1_clairvoyance")
	|| cvar("g_start_spell_team2_clairvoyance")
	|| cvar("g_start_spell_team3_clairvoyance")
	|| cvar("g_start_spell_team4_clairvoyance")) {
		//precache_sound ("relics/relic_effect.wav");
	}
	
	if(cvar("g_start_spell_stonerain")
	|| cvar("g_start_spell_team1_stonerain")
	|| cvar("g_start_spell_team2_stonerain")
	|| cvar("g_start_spell_team3_stonerain")
	|| cvar("g_start_spell_team4_stonerain")) {
		precache_sound ("resource/impact/slingimpstone_21.ogg"); //For StoneRain
		precache_sound ("resource/impact/slingimpstone_22.ogg");
		precache_sound ("resource/impact/slingimpstone_23.ogg");
		precache_sound ("resource/impact/slingimpstone_24.ogg");
		precache_sound ("resource/impact/slingimpstone_25.ogg");
		precache_sound ("resource/impact/slingimpstone_26.ogg");
	}
	
	if(cvar("g_start_spell_lightining")
	|| cvar("g_start_spell_team1_lightining")
	|| cvar("g_start_spell_team2_lightining")
	|| cvar("g_start_spell_team3_lightining")
	|| cvar("g_start_spell_team4_lightining")
	|| cvar("g_start_spell_balllightining")
	|| cvar("g_start_spell_team1_balllightining")
	|| cvar("g_start_spell_team2_balllightining")
	|| cvar("g_start_spell_team3_balllightining")
	|| cvar("g_start_spell_team4_balllightining")
	|| cvar("g_start_spell_chainlightining")
	|| cvar("g_start_spell_team1_chainlightining")
	|| cvar("g_start_spell_team2_chainlightining")
	|| cvar("g_start_spell_team3_chainlightining")
	|| cvar("g_start_spell_team4_chainlightining")
	|| cvar("g_start_spell_lightiningburst")
	|| cvar("g_start_spell_team1_lightiningburst")
	|| cvar("g_start_spell_team2_lightiningburst")
	|| cvar("g_start_spell_team3_lightiningburst")
	|| cvar("g_start_spell_team4_lightiningburst")
	|| cvar("g_start_spell_chargedbolt")
	|| cvar("g_start_spell_team1_chargedbolt")
	|| cvar("g_start_spell_team2_chargedbolt")
	|| cvar("g_start_spell_team3_chargedbolt")
	|| cvar("g_start_spell_team4_chargedbolt")
	|| cvar("g_start_spell_lightiningwall")
	|| cvar("g_start_spell_team1_lightiningwall")
	|| cvar("g_start_spell_team2_lightiningwall")
	|| cvar("g_start_spell_team3_lightiningwall")
	|| cvar("g_start_spell_team4_lightiningwall")) {
		precache_sound ("weapons/lgbeam_fire.wav");
	}
	
	if(cvar("g_start_spell_explosion")
	|| cvar("g_start_spell_team1_explosion")
	|| cvar("g_start_spell_team2_explosion")
	|| cvar("g_start_spell_team3_explosion")
	|| cvar("g_start_spell_team4_explosion")) {
		precache_model ("models/sphere/sphexp2.iqm");
	}
	
	if(cvar("g_start_spell_corvuspenna")
	|| cvar("g_start_spell_team1_corvuspenna")
	|| cvar("g_start_spell_team2_corvuspenna")
	|| cvar("g_start_spell_team3_corvuspenna")
	|| cvar("g_start_spell_team4_corvuspenna")
	|| cvar("g_start_spell_plumosus")
	|| cvar("g_start_spell_team1_plumosus")
	|| cvar("g_start_spell_team2_plumosus")
	|| cvar("g_start_spell_team3_plumosus")
	|| cvar("g_start_spell_team4_plumosus")) {
		precache_model ("models/feathers/feathersmall.iqm");
	}
	
	if(cvar("g_start_spell_firebeam")
	|| cvar("g_start_spell_team1_firebeam")
	|| cvar("g_start_spell_team2_firebeam")
	|| cvar("g_start_spell_team3_firebeam")
	|| cvar("g_start_spell_team4_firebeam")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_sound ("ardentryst/flame_whoosh.ogg");
	}
	
	if(cvar("g_start_spell_magmasphere")
	|| cvar("g_start_spell_team1_magmasphere")
	|| cvar("g_start_spell_team2_magmasphere")
	|| cvar("g_start_spell_team3_magmasphere")
	|| cvar("g_start_spell_team4_magmasphere")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_sound ("ardentryst/flame_whoosh.ogg");
		precache_model ("models/sphere/cannonball.iqm");
	}
	
	if(cvar("g_start_spell_inferno")
	|| cvar("g_start_spell_team1_inferno")
	|| cvar("g_start_spell_team2_inferno")
	|| cvar("g_start_spell_team3_inferno")
	|| cvar("g_start_spell_team4_inferno")) {
		precache_sound ("ardentryst/flame_whoosh.ogg");
	}
	
	if(cvar("g_start_spell_acervilux")
	|| cvar("g_start_spell_team1_acervilux")
	|| cvar("g_start_spell_team2_acervilux")
	|| cvar("g_start_spell_team3_acervilux")
	|| cvar("g_start_spell_team4_acervilux")) {
		//precache_sound ("weapons/fireball_fire2.wav");
	}
	
	if(cvar("g_start_spell_holybolt")
	|| cvar("g_start_spell_team1_holybolt")
	|| cvar("g_start_spell_team2_holybolt")
	|| cvar("g_start_spell_team3_holybolt")
	|| cvar("g_start_spell_team4_holybolt")
	|| cvar("g_start_spell_holyword")
	|| cvar("g_start_spell_team1_holyword")
	|| cvar("g_start_spell_team2_holyword")
	|| cvar("g_start_spell_team3_holyword")
	|| cvar("g_start_spell_team4_holyword")) {
		precache_sound ("weather/thunder_crack.wav");
		precache_sound ("onslaught/shockwave.ogg");
	}
	
	if(cvar("g_start_spell_fireball")
	|| cvar("g_start_spell_team1_fireball")
	|| cvar("g_start_spell_team2_fireball")
	|| cvar("g_start_spell_team3_fireball")
	|| cvar("g_start_spell_team4_fireball")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_model ("models/sphere/sphere.md3");
	}
	
	if(cvar("g_start_spell_firebolt")
	|| cvar("g_start_spell_team1_firebolt")
	|| cvar("g_start_spell_team2_firebolt")
	|| cvar("g_start_spell_team3_firebolt")
	|| cvar("g_start_spell_team4_firebolt")) {
		precache_sound ("weapons/fireball_fire.wav");
	}
	
	if(cvar("g_start_spell_flameburst")
	|| cvar("g_start_spell_team1_flameburst")
	|| cvar("g_start_spell_team2_flameburst")
	|| cvar("g_start_spell_team3_flameburst")
	|| cvar("g_start_spell_team4_flameburst")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_model ("models/sphere/sphere.md3");
	}
	
	if(cvar("g_start_spell_firecentury")
	|| cvar("g_start_spell_team1_firecentury")
	|| cvar("g_start_spell_team2_firecentury")
	|| cvar("g_start_spell_team3_firecentury")
	|| cvar("g_start_spell_team4_firecentury")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_model ("models/sphere/sphere.md3");
	}
	
	if(cvar("g_start_spell_iceball")
	|| cvar("g_start_spell_team1_iceball")
	|| cvar("g_start_spell_team2_iceball")
	|| cvar("g_start_spell_team3_iceball")
	|| cvar("g_start_spell_team4_iceball")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_model ("models/sphere/sphere.md3");
	}
	
	if(cvar("g_start_spell_icestar")
	|| cvar("g_start_spell_team1_icestar")
	|| cvar("g_start_spell_team2_icestar")
	|| cvar("g_start_spell_team3_icestar")
	|| cvar("g_start_spell_team4_icestar")) {
		precache_sound ("weapons/fireball_fire2.wav");
		precache_model ("models/sphere/sphere.md3");
	}
	
	if(cvar("g_start_spell_firewall")
	|| cvar("g_start_spell_team1_firewall")
	|| cvar("g_start_spell_team2_firewall")
	|| cvar("g_start_spell_team3_firewall")
	|| cvar("g_start_spell_team4_firewall")
	|| cvar("g_start_spell_ringoffire")
	|| cvar("g_start_spell_team1_ringoffire")
	|| cvar("g_start_spell_team2_ringoffire")
	|| cvar("g_start_spell_team3_ringoffire")
	|| cvar("g_start_spell_team4_ringoffire")
	) {
		precache_sound ("misc/ignition_firewall.ogg");
	}
	
	if(cvar("g_nades")) {
		if (cvar("g_nades_smokenade_serversmoke")) {
			precache_model ("models/misc/billowingsmoke.iqm");
		}
	}
	
	if(cvar("g_allpiercingcausessteam_frompipes")
	|| cvar("g_allpiercingcausessteam")) {
		precache_sound ("map_red_planet/steam_loop.wav");
	}
	
	if(cvar("g_allpiercingcauseswater_frompipes")) {
		precache_sound ("machines/steam_fade.ogg");
	}
	
	if(cvar("g_allpiercingcausesice_frompipes")) {
		precache_model ("models/ice/ice.md3");
	}
	
	if(cvar("g_spawnvehiclesaround")) {
	precache_model ("models/vhshield.md3");
	precache_model ("models/vehicles/aerocommander_spinner.iqm");
	precache_model ("models/vehicles/aerocommander_spinner2.iqm");
	precache_model("models/vehicles/aerocommanderedits.iqm");
	precache_model ("models/vehicles/aerocommanderedits_lod1.iqm");
	precache_model("models/vehicles/aerocommanderedits_milspec.iqm");
	precache_model ("models/vehicles/aerocommanderedits_milspec_lod1.iqm");

	precache_model ("models/vehicles/blackhawkedits_smallspinner_milspec.iqm");
	precache_model ("models/vehicles/blackhawkedits_milspec_lod1.iqm");
	precache_model ("models/vehicles/blackhawkedits_milspec_lod2.iqm");
	precache_model ("models/vehicles/blackhawkedits_spinner_milspec.iqm");
	precache_model("models/vehicles/blackhawkedits_milspec.iqm");
		
	precache_model ("models/vehicles/blackhawkedits_smallspinner.iqm");
	precache_model ("models/vehicles/blackhawkedits_spinner.iqm");
	precache_model("models/vehicles/blackhawkedits.iqm");
	precache_model ("models/vehicles/blackhawkedits_lod1.iqm");
	precache_model ("models/vehicles/blackhawkedits_lod2.iqm");
		
	precache_model("models/vehicles/bumblebee_body.dpm");
	precache_model("models/vehicles/bumblebee_plasma_left.dpm");
	precache_model("models/vehicles/bumblebee_plasma_right.dpm");
	precache_model("models/vehicles/bumblebee_ray.dpm");
	precache_model("models/vehicles/wakizashi_cockpit.dpm");
	precache_model("models/vehicles/spiderbot_cockpit.dpm");
	precache_model("models/vehicles/raptor_cockpit.dpm");
	
	precache_model ("models/vehicles/challenger_exterior.iqm");
	precache_model ("models/vehicles/challenger_interior.iqm");
	precache_model ("models/vehicles/challenger_lod1.iqm");
	precache_model("models/vehicles/cruizerlimo.iqm");
	precache_model("models/vehicles/cruizerlimo_lod1.iqm");
	precache_model("models/vehicles/cruizer_lod1.iqm");
	precache_model ("models/vehicles/cruizer_exterior.iqm");
	precache_model ("models/vehicles/cruizer_interior.iqm");
	precache_model ("models/mine.md3");
	precache_model ("models/vehicles/farmanedits.iqm");
	precache_model ("models/vehicles/farmanedits_lod1.iqm");
	precache_model ("models/vehicles/sopwith_spinner.iqm");
	precache_model ("models/vehicles/sopwithedits_lod1.iqm");
	precache_model ("models/vehicles/eindeckeredits.iqm");
	precache_model ("models/vehicles/eindeckeredits_lod1.iqm");
	precache_model ("models/vehicles/eindeckeredits_lod2.iqm");
	precache_model ("models/vehicles/eindeckeredits_lod3.iqm");
	precache_model ("models/vehicles/eindecker_spinner.iqm");
	precache_model ("models/vehicles/eindecker_spinner_lod1.iqm");
	precache_model ("models/vehicles/eindecker_spinner_lod2.iqm");
	precache_model ("models/vehicles/eindecker_spinner_lod3.iqm");
	precache_model ("models/sphere/sphexp2.iqm");
	precache_model ("models/sphere/sphexp3.iqm");
	precache_model ("models/vehicles/clusterbomb_folded.md3");
	precache_model ("models/vehicles/nukebomb.md3");
	
	precache_model ("models/vhshield.md3");
	precache_model ("models/vhshield.md3");
	precache_model("models/vehicles/fastcar.iqm");
	precache_model("models/vehicles/fastcar_lod1.iqm");
	precache_model ("models/vehicles/fokkeredits.iqm");
	precache_model ("models/vehicles/fokkeredits_lod1.iqm");
	precache_model ("models/vehicles/fokker_spinner.iqm");
	precache_model ("models/rocket.md3");
	precache_model ("models/sphere/sphexp.md3");

	precache_model ("models/vehicles/nieuportedits.iqm");
	precache_model ("models/vehicles/nieuportedits_lod1.iqm");
	precache_model ("models/vehicles/nieuport_spinner.iqm");
	precache_model("models/vehicles/pickuptruck.iqm");
	precache_model("models/vehicles/pickuptruck_lod1.iqm");
	precache_model ( "models/ebomb.mdl");

	precache_model ("models/vehicles/r22edits_smallspinner.iqm");
	precache_model ("models/vehicles/r22edits_spinner.iqm");
	precache_model("models/vehicles/r22edits_milspec.iqm");
	precache_model("models/vehicles/r22edits.iqm");
	precache_model("models/vehicles/r22edits_lod1.iqm");
	precache_model("models/vehicles/r22edits_lod2.iqm");
	precache_model("models/vehicles/r22edits_milspec_lod1.iqm");
	precache_model("models/vehicles/r22edits_milspec_lod2.iqm");

	precache_model ("models/vehicles/wakizashi.dpm");
	precache_model ("models/vehicles/wakizashi_cockpit.dpm");
	precache_model ("models/vehicles/raptor.dpm");
	precache_model ("models/vehicles/raptor_gun.dpm");
	precache_model ("models/vehicles/spinner.dpm");
	precache_model ("models/vehicles/raptor_cockpit.dpm");

	precache_model ("models/vehicles/raptor_body.dpm");
	precache_model ("models/sphere/sphere.md3");
	precache_model("models/vehicles/sedan.iqm");
	precache_model("models/vehicles/sedan_lod1.iqm");
	precache_model("models/vehicles/smalltruck.iqm");
	precache_model("models/vehicles/smalltruck_lod1.iqm");
	precache_model ("models/vehicles/sopwithedits.iqm");
	precache_model ("models/vehicles/sopwith_spinner.iqm");
	precache_model ("models/grenademodel.md3");
	precache_model ("models/vehicles/sparrowedits.iqm");
	precache_model ("models/vehicles/sparrow_smallspinner.iqm");
	precache_model ("models/vehicles/sparrow_spinner.iqm");
	precache_model("models/vehicles/speedcar.iqm");
	precache_model ( "models/vehicles/spiderbot.dpm");
	precache_model ( "models/vehicles/spiderbot_top.dpm");
	precache_model ( "models/vehicles/spiderbot_barrels.dpm");
	precache_model ( "models/vehicles/spiderbot_cockpit.dpm");
	precache_model ("models/vehicles/sportster_exterior.iqm");
	precache_model ("models/vehicles/sportster_interior.iqm");
	precache_model ("models/vehicles/sportster_lod1.iqm");
	precache_model ( "models/vehicles/tankll24.iqm");
	precache_model ( "models/vehicles/tankt27_mgun.iqm");
	precache_model ( "models/vehicles/tankt27_mgun_lod1.iqm");
	precache_model ( "models/vehicles/tankt27_mgun_lod2.iqm");
	precache_model ( "models/vehicles/anglestabilizer.iqm");
	
	precache_model ( "models/vehicles/tankll48_lod1.iqm");
	precache_model ( "models/vehicles/tankll48_lod2.iqm");
	precache_model ( "models/vehicles/tankll37_lod1.iqm");
	precache_model ( "models/vehicles/tankll37_lod2.iqm");
	precache_model ( "models/vehicles/tankll24_lod1.iqm");
	precache_model ( "models/vehicles/tankll24_lod2.iqm");

	precache_model ( "models/vehicles/m134simple.iqm");
	precache_model ( "models/vehicles/m134simple_lod1.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	precache_model ( "models/vehicles/tankll24_aicannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	precache_model ( "models/vehicles/tankll24_heatcannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	precache_model ( "models/vehicles/tankll24_aacannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	precache_model ( "models/vehicles/tankll24_cannon.iqm");
	precache_model ( "models/vehicles/tankll24_turret.iqm");
	precache_model ( "models/vehicles/tankll37.iqm");
	precache_model ( "models/vehicles/tankll37_turret.iqm");
	precache_model ( "models/vehicles/tankll37_cannon.iqm");
	precache_model ( "models/vehicles/tankll48.iqm");
	precache_model ( "models/vehicles/tankll48_turret.iqm");
	precache_model ( "models/vehicles/tankll48_cannon.iqm");
	precache_model ( "models/vehicles/tankiv.iqm");
	precache_model ( "models/vehicles/tankiv_lod1.iqm");
	precache_model ( "models/vehicles/tanka7v.iqm");
	precache_model ( "models/vehicles/tanka7v_lod1.iqm");
	precache_model ( "models/vehicles/tanka7v_cannon.iqm");
	precache_model ( "models/vehicles/tanka7v_gear.iqm");
	precache_model ( "models/vehicles/tanka7v_smallgear.iqm");
	precache_model ( "models/vehicles/tankt27.iqm");
	precache_model ( "models/vehicles/tankt27_lod1.iqm");
	precache_model ( "models/vehicles/tankt27_lod2.iqm");
	precache_model ( "models/vehicles/tankt27_lod3.iqm");
	precache_model ( "models/vehicles/tankt27_wheel.iqm");
	precache_model ( "models/vehicles/tankt27_gear.iqm");
	precache_model ( "models/vehicles/tankt27_cannon.iqm");
	precache_model("models/vehicles/yugo.iqm");
	precache_model("models/vehicles/yugo_lod1.iqm");
	precache_model ( "models/player/megaerebus.iqm");
	precache_model ( "models/player/megaerebus_lod1.iqm");
	precache_model ( "models/player/megaerebus_lod2.iqm");
	precache_model ( "models/misc/playerspikes_head.iqm");
	precache_model ( "models/misc/playerspikes.iqm");
	precache_model ( "models/vehicles/megaerebus_headinterior.iqm");
	precache_model ( "models/vehicles/maxshotgun1.iqm");
    	precache_model ( "models/vehicles/maxshotgun2.iqm");
	
	precache_sound ( "object/impact_metal_3.ogg");
	precache_sound ( "object/impact_metal_4.ogg");
	precache_sound ("weapons/shotgun_fire.wav");
	precache_sound ("vehicles/raptor_fly.wav");
	precache_sound ("vehicles/raptor_speed.wav");
	precache_sound ("vehicles/missile_alarm.wav");
	precache_sound ("vehicles/racer_idle.wav");
	precache_sound ("vehicles/racer_move.wav");
	precache_sound ("vehicles/racer_boost.wav");
	precache_sound ( "vehicles/spiderbot_die.wav");
	precache_sound ( "vehicles/spiderbot_idle.wav");
	precache_sound ( "vehicles/spiderbot_jump.wav");
	precache_sound ( "vehicles/spiderbot_strafe.wav");
	precache_sound ( "vehicles/spiderbot_walk.wav");
	precache_sound ( "vehicles/spiderbot_land.wav");
	precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
	precache_sound ( "machines/generator_loop_pitchdown.ogg");
	}
	
	if((cvar("g_spawnmountedgunsaround")) || (cvar("g_spawnvehiclesaround"))) {
	precache_model ( "models/uziflash.md3");
	precache_model ( "models/mountedguns/maximgun_circmount.iqm");
	precache_model ( "models/mountedguns/maximgun_pointmount.iqm");
	precache_model ( "models/mountedguns/maximgun_mount.iqm");
	
		if((cvar("g_spawnmountedgunsaround_autonex_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_autonex_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_autonex_amnt"))) {
		precache_model ( "models/mountedguns/autonexgun.iqm");
		precache_model ( "models/mountedguns/autonexgun_lod1.iqm");
		}
	
		if((cvar("g_spawnmountedgunsaround_bpcannon_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_bpcannon_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_bpcannon_amnt"))
		|| (cvar("g_spawnmountedgunsaround_lasercannon_red_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_lasercannon_red_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_lasercannon_red_amnt"))) {
		precache_model ( "models/vehicles/bumblebee_plasma_left.dpm");
		}
	
		if((cvar("g_spawnmountedgunsaround_browning50_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_browning50_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_browning50_amnt"))) {
		precache_model ( "models/mountedguns/browning50gun.iqm");
		precache_model ( "models/mountedguns/browning50gun_lod1.iqm");
		precache_model ( "models/mountedguns/browning50gun_lod2.iqm");
		}
	
		if((cvar("g_spawnmountedgunsaround_gau19_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_gau19_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_gau19_amnt"))) {
		precache_model ( "models/mountedguns/gau19gun.iqm");
		precache_model ( "models/mountedguns/gau19gun_barrels.iqm");
		precache_model ( "models/mountedguns/gau19gun_lod1.iqm");
		precache_model ( "models/mountedguns/gau19gun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_grail_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_grail_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_grail_amnt"))) {
		precache_model ( "models/mountedguns/grailgun.iqm");
		precache_model ( "models/mountedguns/grailgun_lod1.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_lewis_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_lewis_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_lewis_amnt"))) {
		precache_model ( "models/mountedguns/lewisgun.iqm");
		precache_model ( "models/mountedguns/lewisgun_lod1.iqm");
		precache_model ( "models/mountedguns/lewisgun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_m134_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_m134_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_m134_amnt"))) {
		precache_model ( "models/mountedguns/m134gun.iqm");
		precache_model ( "models/mountedguns/m134gun_barrels.iqm");
		precache_model ( "models/mountedguns/m134gun_lod1.iqm");
		precache_model ( "models/mountedguns/m134gun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_maxim_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_maxim_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_maxim_amnt"))) {
		precache_model ( "models/mountedguns/maximgun.iqm");
		precache_model ( "models/mountedguns/maximgun_lod1.iqm");
		precache_model ( "models/mountedguns/maximgun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_rpk_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_rpk_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_rpk_amnt"))) {
		precache_model ( "models/mountedguns/rpkgun.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_shlac_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_shlac_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_shlac_amnt"))) {
		precache_model ( "models/mountedguns/shlacgun.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_spadu_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_spadu_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_spadu_amnt"))) {
		precache_model ( "models/mountedguns/spadugun.iqm");
		precache_model ( "models/mountedguns/spadugun_lod1.iqm");
		precache_model ( "models/mountedguns/spadugun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_t17mm_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_t17mm_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_t17mm_amnt"))) {
		precache_model ( "models/mountedguns/t17mmgun.iqm");
		precache_model ( "models/mountedguns/t17mmgun_lod1.iqm");
		precache_model ( "models/mountedguns/t17mmgun_lod2.iqm");
		precache_model ( "models/mountedguns/t17mmgun_lod3.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_deluge_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_deluge_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_deluge_amnt"))) {
		precache_model ( "models/mountedguns/delugegun.iqm");
		precache_model ( "models/mountedguns/delugegun_lod1.iqm");
		precache_model ( "models/mountedguns/delugegun_lod2.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_scorpion_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_scorpion_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_scorpion_amnt"))) {
		precache_model ( "models/mountedguns/scorpion_mount.iqm");
		precache_model ( "models/mountedguns/scorpiongun_loaded.iqm");
		precache_model ( "models/mountedguns/scorpiongun.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_batteringram_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_batteringram_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_batteringram_amnt"))) {
		precache_model ( "models/mountedguns/batteringram.bsp");
		precache_model ( "models/mountedguns/batteringram_frame.bsp");
		precache_model ( "models/misc/mg_shield_batteringram_wood.bsp");
		}
		
		if((cvar("g_spawnmountedgunsaround_charbelcher_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_charbelcher_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_charbelcher_amnt"))) {
		precache_model ( "models/mountedguns/charbelcher_mount.iqm");
		precache_model ( "models/mountedguns/charbelcher.iqm");
		precache_model ( "models/mountedguns/charbelcher_lod1.iqm");
		precache_model ( "models/mountedguns/charbelcher_lod2.iqm");
		precache_model ( "models/sphere/sphere.md3");
		precache_model ("models/map_xoylent/asteroid.obj");
		}
		
		if((cvar("g_spawnmountedgunsaround_siegemortar_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_siegemortar_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_siegemortar_amnt"))) {
		precache_model ( "models/mountedguns/siegemortar_mount.iqm");
		precache_model ( "models/mountedguns/siegemortar.iqm");
		precache_model ( "models/mountedguns/siegemortar_lod1.iqm");
		precache_model ( "models/mountedguns/siegemortar_lod2.iqm");
		precache_model ("models/sphere/cannonball.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_hotchkissm1914_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_hotchkissm1914_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_hotchkissm1914_amnt"))) {
		precache_model ( "models/mountedguns/hotchkissm1914.iqm");
		precache_model ( "models/mountedguns/hotchkissm1914_lod1.iqm");
		precache_model ( "models/mountedguns/hotchkissm1914_lod2.iqm");
		precache_model ( "models/mountedguns/hotchkissm1914_lod3.iqm");
		precache_model ( "models/mountedguns/hotchkissm1914_lod4.iqm");
		}
		
		if((cvar("g_spawnmountedgunsaround_gatling1877_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team1_gatling1877_amnt"))
		|| (cvar("g_spawnmountedgunsaround_team2_gatling1877_amnt"))) {
		precache_model ( "models/mountedguns/gatlingstand.iqm");
		precache_model ( "models/mountedguns/gatling1877gun.iqm");
		precache_model ( "models/mountedguns/gatling1877gun_lod1.iqm");
		precache_model ( "models/mountedguns/gatling1877gun_lod2.iqm");
		precache_model ( "models/mountedguns/gatling1877gun_barrels.iqm");
		}
	
	precache_model ( "models/misc/mg_shield_metal.bsp");
	precache_model ( "models/misc/mg_shield_energy.bsp");
	precache_model ( "models/misc/mg_shield_energy2.bsp");
	precache_model ( "models/misc/mg_shield_laser.bsp");
	precache_model ( "models/misc/mg_shield_iron.bsp");
	precache_model ( "models/misc/mg_shield_thinmetal.bsp");
	precache_model ( "models/misc/mg_shield_glass.bsp");
	precache_model ( "models/misc/mg_shield_roundel.bsp");
	precache_model ( "models/misc/mg_shield_roundel2.bsp");
	precache_model ( "models/misc/mg_shield_grail.bsp");
	precache_model ( "models/misc/mg_shield_rpk.bsp");
	precache_model ( "models/misc/mg_shield_wood.bsp");
	precache_model ( "models/misc/mg_shield_laser.bsp");
	
	
	precache_sound ( "machines/steam_fade.ogg" );
	precache_sound ( "weapons/uzi_fire.wav" );
	precache_sound ( "weapons/uzi_fire_bass.ogg" );
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	precache_sound ( "weapons/uzi_fire_somebass.wav" );
	precache_sound ( "weapons/ffsl_ak47_fire.ogg" );
	precache_sound ("weapons/campingrifle_fire.wav");
	precache_sound ( "weapons/campingrifle_fire_bass.wav" );
	precache_sound ( "weapons/campingrifle_fire_morebass.ogg" );
	precache_sound ( "weapons/lasergun_fire.wav" );
	precache_sound ( "weapons/flacexp3.wav" );
	precache_sound ( "weapons/electro_fire.wav" );
	precache_sound ( "weapons/electro_impact_combo.wav" );
	precache_sound ( "weapons/crylink_fire.wav" );
	precache_sound ( "weapons/nexfire.wav" );
	precache_sound ("weapons/neximpact.wav");	
	precache_sound ("weapons/grenade_bounce1.wav");
	precache_sound ("weapons/grenade_bounce2.wav");
	precache_sound ("weapons/grenade_bounce3.wav");
	precache_sound ("weapons/grenade_bounce4.wav");
	precache_sound ("weapons/grenade_bounce5.wav");
	precache_sound ("weapons/grenade_bounce6.wav");
	precache_sound ("weapons/grenade_stick.wav");
	precache_sound ("weapons/grenade_fire.wav");
	precache_sound ("weapons/mine_det.wav");
	precache_sound ("weapons/mine_fire.wav");
	precache_sound ("weapons/mine_stick.wav");
	precache_sound ("weapons/mine_trigger.wav");
	precache_sound ("weapons/rocket_fire.wav");
	precache_sound ( "weapons/rocket_impact.wav");
	precache_sound ("weapons/hagar_fire.wav");
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound("onslaught/ons_hit2.wav");
	precache_sound("onslaught/electricity_explode.wav");
	}
	
	if(cvar("g_spawnturretsaround")) {
	precache_model ("models/turrets/ewheel-base2.md3");
	precache_model ("models/turrets/ewheel-gun1.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/flac.md3");
	precache_model ("models/turrets/reactor.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/hellion.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/hk.md3");
	precache_model ("models/turrets/machinegun.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/mlrs.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/phaser.md3");
	precache_model ("models/turrets/phaser_beam.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/plasma.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/plasmad.md3");
	precache_model ("models/turrets/base.md3");
	precache_model ("models/turrets/tesla_head.md3");
	precache_model ("models/turrets/tesla_base.md3");
	precache_model ("models/turrets/walker_head_minigun.md3");
	precache_model ("models/turrets/walker_body.md3");
	precache_model ( "models/turrets/rocket.md3");
	
	precache_sound ("weapons/hagar_fire.wav");
	precache_sound ("weapons/neximpact.wav");
	precache_sound ("weapons/uzi_fire.wav");
	precache_sound ("turrets/phaser.wav");
	precache_sound ( "weapons/rocket_impact.wav" );
	}
	
	if(cvar("g_spawnfoliagearound"))
	{
		//print("PRECACHE FOLIAGE------------------------------------\n");
		Foliage_GetAutoCvars_Precache();	
	} else if (cvar("g_suggested_spawnfoliagearound")) {
		Foliage_Presets_Set(cvar("g_suggested_spawnfoliagearound_preset"));
		Foliage_Presets_Precache();
	}
	
	if(cvar("g_spawnmiscitemsaround")) {
	precache_model ("models/sphere/spikeball.iqm");
	precache_model ("models/sphere/spikeball_lod1.iqm");
	precache_model ("models/sphere/spikeball_lod2.iqm");
	
	precache_model ("models/sphere/smallsphere.iqm");
	precache_model ("models/sphere/smallsphere_lod1.iqm");
	precache_model ("models/sphere/smallsphere_lod2.iqm");
	
	precache_model ("models/sphere/smallspikeball.iqm");
	precache_model ("models/sphere/smallspikeball_lod1.iqm");
	precache_model ("models/sphere/smallspikeball_lod2.iqm");
	
	precache_model ("models/sphere/baloon.iqm");
	precache_model ("models/sphere/baloon_lod1.iqm");
	precache_model ("models/sphere/baloon_lod2.iqm");
	precache_model ("models/sphere/baloon_lod3.iqm");
	precache_model ("models/sphere/baloon_lod4.iqm");
	
	precache_model ("models/sphere/bumpersphere.iqm");
	precache_model ("models/sphere/bumpersphere_lod1.iqm");
	precache_model ("models/sphere/bumpersphere_lod2.iqm");
	precache_model ("models/sphere/bumpersphere_lod3.iqm");
	
	precache_model ("models/misc/spikes3x3.iqm");
	precache_model ("models/misc/spikes3x3_lod1.iqm");
	precache_model ("models/misc/spikes3x3_lod2.iqm");
	
	precache_model ("models/misc/tanktraps_pyramid.bsp");
	precache_model ("models/misc/abandoned_tower1.bsp");
	precache_model ("models/misc/abandoned_gtower1.bsp");
	
	precache_model ("models/xonotic_jumppad01/xonotic_jumppad01.md3");
	precache_model ("models/xonotic_jumppad01/xonotic_jumppad01_lod1.md3");
	
		if(cvar("g_spawnmiscitemsaround_abdbld_misc_amnt")) {
			w_multitool(WR_PRECACHE);
			print("PRECACHEd MultiTool Buildings\n");
		}
	
		if(cvar("g_spawnmiscitemsaround_abdbld_fisc_amnt")) {
			w_utilitool(WR_PRECACHE);
			print("PRECACHEd UtiliTool Buildings\n");
		}
	}
	
	if(cvar("g_za")) {
	precache_model ("progs/beam.mdl");
        precache_model ("models/spike.mdl");
	precache_model ("models/crossbowbolt.md3");
	
		//precache_model ("models/monsters/demon.mdl");
		
		
		if(cvar("g_za_monster_dog_amnt")) {
		precache_model ("models/monsters/dog.dpm");
		}
		
		if(cvar("g_za_monster_enforcer_amnt")) {
		precache_model ("models/monsters/enforcer.mdl");
		}
		
		if(cvar("g_za_monster_fish_amnt")) {
		precache_model ("models/monsters/fish.mdl");
		}
		
		//precache_model ("models/monsters/hknight.mdl");
		//precache_model ("models/monsters/knight.mdl");
		//precache_model ("models/monsters/ogre.dpm");
	
		if(cvar("g_za_monster_vore_amnt")) {
		precache_model ("models/monsters/shalrath.mdl");
		}
		
		//precache_model ("models/monsters/shambler.mdl");
		//precache_model ("models/monsters/soldier.mdl");
		
		if(cvar("g_za_monster_soldier_amnt")) {
		soldier_precacheforothers();
		}
		
		if(cvar("g_za_monster_ninjaassassin_amnt")) {
		precache_model ("models/monsters/ninjaassassin.iqm");
		ninjaassassin_precache_weapons();
		}
		
		if(cvar("g_za_monster_horndemon_amnt")) {
		precache_model ("models/monsters/horndemon_lod0.iqm");
		precache_model ("models/monsters/horndemon_lod1.iqm");
		precache_model ("models/monsters/horndemon_lod2.iqm");
		precache_model ("models/monsters/horndemon_lod3.iqm");
		horndemon_precache_weapons();
		}
		
		if(cvar("g_za_monster_seraph_amnt")) {
		precache_model ("models/monsters/armorknight.iqm");
		precache_model ("models/monsters/armorknight_lod1.iqm");
		precache_model ("models/monsters/armorknight_lod2.iqm");
		seraph_precache_weapons();
		}
		
		//precache_model ("models/containers/crate01.md3");
		
		if(cvar("g_za_monster_spider_amnt")) {
		precache_model ("models/monsters/spider.dpm");
		}
		
	//precache_model ("models/monsters/tarbaby.mdl");
	//precache_model ("models/monsters/wizard.mdl");
	
		if(cvar("g_za_monster_hellknight_amnt")) {
		precache_model ("models/monsters/royalguardhel.iqm");
		hell_knight_precache_weapons();
		}
	
		if(cvar("g_za_monster_knight_amnt")) {
		knight_precacheforothers();
		precache_model ("models/weapons/v_longsword.md3");
		precache_model ("models/weapons/v_poleaxe.md3");
		}
		
		if(cvar("g_za_monster_spawn_amnt")) {
		precache_model ("models/monsters/slime.dpm");
		}
		
		if(cvar("g_za_monster_imp_amnt")) {
		precache_model ("models/monsters/imp-edits.iqm");
		precache_model ("models/monsters/imp-edits_lod1.iqm");
		precache_model ("models/monsters/imp-edits_lod2.iqm");
		precache_model ("models/monsters/imp-edits_lod3.iqm");
		imp_precache_weapons();
		}
		
		if(cvar("g_za_monster_shambler_amnt")) {
		precache_model ("models/monsters/CH1monster3.iqm");
		precache_model ("models/monsters/CH1monster3_lod1.iqm");
		//precache_model ("models/weapons/g_nex.md3");
		}
		
	//precache_model ("models/monsters/mage.dpm");
		
		if(cvar("g_za_monster_demon_amnt")) {
		precache_model ("models/monsters/new_thin_zombie.iqm");
		precache_model ("models/monsters/new_thin_zombie_lod1.iqm");
		precache_model ("models/monsters/new_thin_zombie_lod2.iqm");
		}
		
		if(cvar("g_za_monster_ogre_amnt")) {
		precache_model ("models/monsters/ogre_edits3.iqm");
		precache_model ("models/weapons/v_cudgel.md3");
		}
		
		if(cvar("g_za_monster_biledemon_amnt")) {
		precache_model ("models/monsters/troll-edits.iqm");
		biledemon_precache_weapons();
		}
		
		if(cvar("g_za_monster_wyvern_amnt")) {
		precache_model ("models/monsters/wyvern-edits.iqm");
		precache_model ("models/monsters/wyvern-edits_lod1.iqm");
		precache_model ("models/monsters/wyvern-edits_lod2.iqm");
		}
	
		if(cvar("g_za_monster_zombie_amnt")) {
		//precache_model ("models/monsters/zombie.dpm");
		precache_model ("models/monsters/zombie-edits3.iqm");
		}
	
		if(cvar("g_za_monster_minotaur_amnt")) {
		precache_model ("models/monsters/minotaur.iqm");
		precache_model ("models/monsters/minotaur_bayonet.iqm");
		minotaur_precache_weapons();
		}
	
		if(cvar("g_za_monster_goblin_amnt")) {
		precache_model ("models/monsters/goblin.iqm");
		goblin_precache_weapons();
		}
	
		if(cvar("g_za_monster_wolf_amnt")) {
		precache_model ("models/monsters/wolf.iqm");
		}
	
		if(cvar("g_za_monster_golem_amnt")) {
		precache_model ("models/monsters/golem.iqm");
		}
		
		if(cvar("g_za_monster_police_amnt")) {
		precache_model ("models/monsters/police.iqm");
		police_precache_weapons();
		}
		
		if(cvar("g_za_monster_skeleton_amnt")) {
		precache_model ("models/monsters/skeletonwarrior.iqm");
		skeleton_precache_weapons();
		}
		
		if(cvar("g_za_monster_fighter_amnt")) {
		fighter_precacheforothers();
		precache_model ("models/weapons/v_fightersword.md3");
		}
		
		if(cvar("g_za_monster_shinrae_amnt")) {
		precache_model ("models/monsters/raptile.iqm");
		precache_model ("models/monsters/raptile_lod1.iqm");
		precache_model ("models/monsters/raptile_lod2.iqm");
		precache_model ("models/monsters/raptile_lod3.iqm");
		precache_model ("models/monsters/raptile_lod4.iqm");
		shinrae_precache_growls();
		shinrae_precache_weapons();
		}
		
		if(cvar("g_za_monster_aocyborg_amnt")) {
		precache_model ("models/monsters/ao_robot_lod0.iqm");
		precache_model ("models/monsters/ao_robot_lod1.iqm");
		precache_model ("models/monsters/ao_robot_lod2.iqm");
		aocyborg_precache_growls();
		aocyborg_precache_weapons();
		}

	//precache_model ("models/weapons/v_broadaxe.md3");
	//precache_model ("models/weapons/v_warhammerspiked.md3");
	//precache_model ("models/weapons/v_shortsword.md3");
	//precache_model ("models/weapons/v_crossbowdtwr.md3");
	//precache_model ("models/weapons/v_torch.md3");
	//precache_model ("models/weapons/v_torch_lit.md3");
	//precache_model ("models/weapons/v_longsword.md3");
	//precache_model ("models/weapons/v_katana.md3");
	//precache_model ("models/weapons/v_poleaxe.md3");
	//precache_model ("models/weapons/v_shiningstar.md3");
	//precache_model ("models/weapons/v_odachi.md3");
	//precache_model ("models/weapons/v_nagamaki.md3");
	//precache_model ("models/weapons/v_tetsubo.md3");
	//precache_model ("models/weapons/v_mac10_unsuppressed.md3");
	//precache_model ("models/weapons/v_campingrifle.md3");
	//precache_model ("models/weapons/v_pumpshotgun.md3");
	//precache_model ("models/weapons/v_shotgun.md3");
	//precache_model ("models/weapons/v_shotgunautomat.md3");
	//precache_model ("models/weapons/v_pistol.md3");
	//precache_model ("models/weapons/v_uzi.md3");
	precache_model ("models/misc/playerspikes_head.iqm");
	precache_model ("models/ice/ice.md3");
	
	precache_sound ("weapons/warhammerspiked_melee.wav");
	precache_sound ("weapons/spike.wav");
        precache_sound ("weapons/lgbeam_fire.wav");
        precache_sound ("weapons/shotgun_fire.wav");
        precache_sound ("weapons/uzi_fire.wav");
        precache_sound ("weapons/laser_fire.wav");
        precache_sound ("weapons/reload.wav");
        precache_sound("weapons/rocket_impact.wav");
        precache_sound ("weapons/spike.wav");
	precache_sound ("machines/steam_burst.ogg");
	precache_sound ("resource/impact/shieldimpmetal_215.ogg");
	precache_sound ("resource/impact/shieldimpmetal_214.ogg");
	precache_sound ("resource/impact/shieldimpmetal_213.ogg");
	precache_sound ("resource/impact/shieldimpmetal_212.ogg");
	precache_sound ("resource/impact/shieldimpmetal_211.ogg");
	precache_sound ("resource/impact/shieldimpmetal_210.ogg");
	precache_sound ("resource/impact/shieldimpmetal_29.ogg");
	precache_sound ("resource/impact/shieldimpmetal_28.ogg");
	precache_sound ("resource/impact/shieldimpmetal_27.ogg");
	precache_sound ("resource/impact/shieldimpmetal_26.ogg");
	precache_sound ("resource/impact/shieldimpmetal_25.ogg");
	precache_sound ("resource/impact/shieldimpmetal_24.ogg");
	precache_sound ("resource/impact/shieldimpmetal_23.ogg");
	precache_sound ("resource/impact/shieldimpmetal_22.ogg");
	precache_sound ("resource/impact/shieldimpmetal_21.ogg");
	precache_sound ("object/impact_wood_4.ogg");
	precache_sound ("object/impact_wood_3.ogg");
	precache_sound ("object/impact_wood_2.ogg");
	precache_sound ("object/impact_wood_1.ogg");
	precache_sound("resource/impact/arrowimpmetal_213.ogg");
	precache_sound("resource/impact/arrowimpmetal_212.ogg");
	precache_sound("resource/impact/arrowimpmetal_211.ogg");
	precache_sound("resource/impact/arrowimpmetal_210.ogg");
	precache_sound("resource/impact/arrowimpmetal_29.ogg");
	precache_sound("resource/impact/arrowimpmetal_28.ogg");
	precache_sound("resource/impact/arrowimpmetal_27.ogg");
	precache_sound("resource/impact/arrowimpmetal_26.ogg");
	precache_sound("resource/impact/arrowimpmetal_25.ogg");
	precache_sound("resource/impact/arrowimpmetal_24.ogg");
	precache_sound("resource/impact/arrowimpmetal_23.ogg");
	precache_sound("resource/impact/arrowimpmetal_22.ogg");
	precache_sound("resource/impact/arrowimpmetal_21.ogg");
	precache_sound("resource/impact/arrowimpstone_212.ogg");
	precache_sound("resource/impact/arrowimpstone_211.ogg");
	precache_sound("resource/impact/arrowimpstone_210.ogg");
	precache_sound("resource/impact/arrowimpstone_29.ogg");
	precache_sound("resource/impact/arrowimpstone_28.ogg");
	precache_sound("resource/impact/arrowimpstone_27.ogg");
	precache_sound("resource/impact/arrowimpstone_26.ogg");
	precache_sound("resource/impact/arrowimpstone_25.ogg");
	precache_sound("resource/impact/arrowimpstone_24.ogg");
	precache_sound("resource/impact/arrowimpstone_23.ogg");
	precache_sound("resource/impact/arrowimpstone_22.ogg");
	precache_sound("resource/impact/arrowimpstone_21.ogg");
	precache_sound("resource/impact/Arrowimpwood_19.ogg");
	precache_sound("resource/impact/Arrowimpwood_18.ogg");
	precache_sound("resource/impact/Arrowimpwood_17.ogg");
	precache_sound("resource/impact/Arrowimpwood_16.ogg");
	precache_sound("resource/impact/Arrowimpwood_15.ogg");
	precache_sound("resource/impact/Arrowimpwood_14.ogg");
	precache_sound("resource/impact/Arrowimpwood_13.ogg");
	precache_sound("resource/impact/Arrowimpwood_12.ogg");
	precache_sound("resource/impact/Arrowimpwood_11.ogg");
	precache_sound("resource/impact/slingimpwood_22.ogg");
	precache_sound("resource/impact/slingimpwood_21.ogg");
	precache_sound("resource/impact/slingimpstone_210.ogg");
	precache_sound("resource/impact/slingimpstone_211.ogg");
	}
	
	if (autocvar_sv_risque >= 1)
	{
		precache_model ("models/monsters/minotaur_bayonet.iqm");
		precache_model ("models/monsters/minotaur_bayonet_ex.iqm");
	}
	
}

void Map_MarkAsRecent(string m);
float world_already_spawned;
void Nagger_Init();
void ClientInit_Spawn();
void WeaponStats_Init();
void WeaponStats_Shutdown();
void spawnfunc_worldspawn (void)
{
	float fd, l, i, j, n;
	string s, col;

	cvar = cvar_normal;
	cvar_string = cvar_string_normal;
	cvar_set = cvar_set_normal;

	if(world_already_spawned)
		error("world already spawned - you may have EXACTLY ONE worldspawn!");
	world_already_spawned = TRUE;

	remove = remove_safely; // during spawning, watch what you remove!

	check_unacceptable_compiler_bugs();

	cvar_changes_init(); // do this very early now so it REALLY matches the server config

	compressShortVector_init();

	allowed_to_spawn = TRUE;

	entity head;
	head = nextent(world);
	maxclients = 0;
	while(head)
	{
		++maxclients;
		head = nextent(head);
	}

	// needs to be done so early because of the constants they create
	CALL_ACCUMULATED_FUNCTION(RegisterWeapons);
	CALL_ACCUMULATED_FUNCTION(RegisterGametypes);

	ServerProgsDB = db_load(strcat("server.db", autocvar_sessionid));

	TemporaryDB = db_create();

	// 0 normal
	lightstyle(0, "m");

	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");

	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");

	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");

	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");

	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");

	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");

	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");

	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");

	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");

	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");

	// styles 32-62 are assigned by the spawnfunc_light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	if(autocvar_g_campaign)
		CampaignPreInit();

	Map_MarkAsRecent(mapname);

	PlayerStats_Init(); // we need this to be initiated before InitGameplayMode

	precache_model ("null"); // we need this one before InitGameplayMode
	

	//precachestuff
	
	InitGameplayMode();
	readlevelcvars();
	precachestuff_forworld();
	warpzonedefaults_forworld();
	GrappleHookInit();
	ElectroInit();
	LaserInit();

	player_count = 0;
	bot_waypoints_for_items = autocvar_g_waypoints_for_items;
	if(bot_waypoints_for_items == 1)
		if(self.spawnflags & SPAWNFLAG_NO_WAYPOINTS_FOR_ITEMS)
			bot_waypoints_for_items = 0;

	precache();

	WaypointSprite_Init();

	//if (g_domination)
	//	dom_init();

	GameLogInit(); // prepare everything
	// NOTE for matchid:
	// changing the logic generating it is okay. But:
	// it HAS to stay <= 64 chars
	// character set: ASCII 33-126 without the following characters: : ; ' " \ $
	if(autocvar_sv_eventlog)
	{
		s = sprintf("%d.%s.%06d", ftos(autocvar_sv_eventlog_files_counter), strftime(FALSE, "%s"), floor(random() * 1000000));
		matchid = strzone(s);

		GameLogEcho(strcat(":gamestart:", GetGametype(), "_", GetMapname(), ":", s));
		s = ":gameinfo:mutators:LIST";

		ret_string = s;
		MUTATOR_CALLHOOK(BuildMutatorsString);
		s = ret_string;

		// simple, probably not good in the mutator system
		if(autocvar_g_grappling_hook)
			s = strcat(s, ":grappling_hook");

		// initialiation stuff, not good in the mutator system
		if(!autocvar_g_use_ammunition)
			s = strcat(s, ":no_use_ammunition");

		// initialiation stuff, not good in the mutator system
		if(autocvar_g_pickup_items == 0)
			s = strcat(s, ":no_pickup_items");
		if(autocvar_g_pickup_items > 0)
			s = strcat(s, ":pickup_items");

		// initialiation stuff, not good in the mutator system
		if(autocvar_g_weaponarena != "0")
			s = strcat(s, ":", autocvar_g_weaponarena, " arena");

		// TODO to mutator system
		if(autocvar_g_norecoil)
			s = strcat(s, ":norecoil");

		// TODO to mutator system
		if(autocvar_g_midair)
			s = strcat(s, ":midair");

		// TODO to mutator system
		if(autocvar_g_minstagib)
			s = strcat(s, ":minstagib");

		// TODO to mutator system
		if(autocvar_g_powerups == 0)
			s = strcat(s, ":no_powerups");
		if(autocvar_g_powerups > 0)
			s = strcat(s, ":powerups");

		GameLogEcho(s);
		GameLogEcho(":gameinfo:end");
	}
	else
		matchid = strzone(ftos(random()));

	cvar_set("nextmap", "");

	SetDefaultAlpha();

	if(autocvar_g_campaign)
		CampaignPostInit();

	fteqcc_testbugs();

	Ban_LoadBans();

	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);

	if(whichpack(strcat("maps/", mapname, ".cfg")) != "")
	{
		fd = fopen(strcat("maps/", mapname, ".cfg"), FILE_READ);
		if(fd != -1)
		{
			while((s = fgets(fd)))
			{
				l = tokenize_console(s);
				if(l < 2)
					continue;
				if(argv(0) == "cd")
				{
					print("Found ^1UNSUPPORTED^7 cd loop command in .cfg file; put this line in mapinfo instead:\n");
					print("  cdtrack ", argv(2), "\n");
				}
				else if(argv(0) == "fog")
				{
					print("Found ^1UNSUPPORTED^7 fog command in .cfg file; put this line in worldspawn in the .map/.bsp/.ent file instead:\n");
					print("  \"fog\" \"", s, "\"\n");
				}
				else if(argv(0) == "set")
				{
					print("Found ^1UNSUPPORTED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(1), " ", argv(2), "\n");
				}
				else if(argv(0) != "//")
				{
					print("Found ^1UNSUPPORTED^7 set command in .cfg file; put this line in mapinfo instead:\n");
					print("  clientsettemp_for_type all ", argv(0), " ", argv(1), "\n");
				}
			}
			fclose(fd);
		}
	}

	WeaponStats_Init();

	WEPSET_ADDSTAT();
	addstat(STAT_SWITCHWEAPON, AS_INT, switchweapon);
	addstat(STAT_SWITCHINGWEAPON, AS_INT, switchingweapon);
	addstat(STAT_GAMESTARTTIME, AS_FLOAT, stat_game_starttime);
	addstat(STAT_ALLOW_OLDNEXBEAM, AS_INT, stat_allow_oldnexbeam);
	Nagger_Init();

	addstat(STAT_STRENGTH_FINISHED, AS_FLOAT, strength_finished);
	addstat(STAT_INVINCIBLE_FINISHED, AS_FLOAT, invincible_finished);
	addstat(STAT_SUPERWEAPONS_FINISHED, AS_FLOAT, superweapons_finished);
	addstat(STAT_PRESSED_KEYS, AS_FLOAT, pressedkeys);
	addstat(STAT_FUEL, AS_INT, ammo_fuel);
	addstat(STAT_MANA, AS_INT, mana);
	addstat(STAT_SHOTORG, AS_INT, stat_shotorg);
	addstat(STAT_LEADLIMIT, AS_FLOAT, stat_leadlimit);
	addstat(STAT_WEAPON_CLIPLOAD, AS_INT, clip_load);
	addstat(STAT_WEAPON_CLIPSIZE, AS_INT, clip_size);
	addstat(STAT_LAST_PICKUP, AS_FLOAT, last_pickup);
	addstat(STAT_HIT_TIME, AS_FLOAT, hit_time);
	addstat(STAT_TYPEHIT_TIME, AS_FLOAT, typehit_time);
	addstat(STAT_LAYED_MINES, AS_INT, minelayer_mines);

	addstat(STAT_NEX_CHARGE, AS_FLOAT, nex_charge);
	addstat(STAT_NEX_CHARGEPOOL, AS_FLOAT, nex_chargepool_ammo);

	addstat(STAT_HAGAR_LOAD, AS_INT, hagar_load);

	if(g_ca || g_freezetag)
	{
		addstat(STAT_REDALIVE, AS_INT, redalive_stat);
		addstat(STAT_BLUEALIVE, AS_INT, bluealive_stat);
		addstat(STAT_YELLOWALIVE, AS_INT, yellowalive_stat);
		addstat(STAT_PINKALIVE, AS_INT, pinkalive_stat);
	}
	if(g_freezetag)
	{
		addstat(STAT_FROZEN, AS_INT, freezetag_frozen);
		addstat(STAT_REVIVE_PROGRESS, AS_FLOAT, freezetag_revive_progress);
	}
	
	addstat(STAT_FROZEN2, AS_INT, frozen); //Non-freezetag
	addstat(STAT_CLAIRVOYANCE, AS_INT, hasclairvoyance_cameraon); //If remote viewing is active 
	addstat(STAT_CLAIRVOYANCEX, AS_INT, hasclairvoyance_camerax); //Remote viewing origin coords x
	addstat(STAT_CLAIRVOYANCEY, AS_INT, hasclairvoyance_cameray); //Remote viewing origin coords y
	addstat(STAT_CLAIRVOYANCEZ, AS_INT, hasclairvoyance_cameraz); //Remote viewing origin coords z

	addstat(STAT_PLYRINFLTHLIQUID, AS_INT, wasinfilthliquidlastmetabolize); 

	// g_movementspeed hack
	addstat(STAT_MOVEVARS_AIRSPEEDLIMIT_NONQW, AS_FLOAT, stat_sv_airspeedlimit_nonqw);
	addstat(STAT_MOVEVARS_MAXSPEED, AS_FLOAT, stat_sv_maxspeed);
	addstat(STAT_MOVEVARS_AIRACCEL_QW, AS_FLOAT, stat_sv_airaccel_qw);
	addstat(STAT_MOVEVARS_AIRSTRAFEACCEL_QW, AS_FLOAT, stat_sv_airstrafeaccel_qw);

	// secrets
	addstat(STAT_SECRETS_TOTAL, AS_FLOAT, stat_secrets_total);
	addstat(STAT_SECRETS_FOUND, AS_FLOAT, stat_secrets_found);
	
	// monsters
	addstat(STAT_MONSTERS_TOTAL, AS_FLOAT, stat_monsters_total);
	addstat(STAT_MONSTERS_KILLED, AS_FLOAT, stat_monsters_killed);

	// misc
	addstat(STAT_RESPAWN_TIME, AS_FLOAT, stat_respawn_time);
	addstat(STAT_HUDSHOWNAMESENEMIES , AS_INT, stat_sv_hudshownameenemies);
	addstat(STAT_BLINDED , AS_INT, stat_blinded);
	addstat(STAT_NUKEFLASH , AS_INT, stat_nukeflash);
	addstat(STAT_BANGFLASH , AS_INT, stat_bangflash);
	addstat(STAT_STONED , AS_INT, stoned);

	next_pingtime = time + 5;

	detect_maptype();

	// set up information replies for clients and server to use
	lsmaps_reply = "^7Maps available: ";
	lsnewmaps_reply = "^7Maps without a record set: ";
	for(i = 0, j = 0; i < MapInfo_count; ++i)
	{
		if(MapInfo_Get_ByID(i))
			if not(MapInfo_Map_flags & (MAPINFO_FLAG_HIDDEN | MAPINFO_FLAG_FORBIDDEN))
			{
				if(mod(i, 2))
					col = "^2";
				else
					col = "^3";

				++j;

				lsmaps_reply = strcat(lsmaps_reply, col, MapInfo_Map_bspname, " ");

				if(g_race && !stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, RACE_RECORD, "time"))))
					lsnewmaps_reply = strcat(lsnewmaps_reply, col, MapInfo_Map_bspname, " ");
				else if(g_cts && !stof(db_get(ServerProgsDB, strcat(MapInfo_Map_bspname, CTS_RECORD, "time"))))
					lsnewmaps_reply = strcat(lsnewmaps_reply, col, MapInfo_Map_bspname, " ");
			}
	}

	lsmaps_reply = strzone(strcat(lsmaps_reply, "\n"));
	lsnewmaps_reply = strzone(strcat(((!g_race && !g_cts) ? "Need to be playing race or CTS for lsnewmaps to work." : lsnewmaps_reply), "\n"));

	maplist_reply = "^7Maps in list: ";
	n = tokenize_console(autocvar_g_maplist);
	for(i = 0, j = 0; i < n; ++i)
	{
		if(MapInfo_CheckMap(argv(i)))
		{
			if(mod(j, 2))
				col = "^2";
			else
				col = "^3";
			maplist_reply = strcat(maplist_reply, col, argv(i), " ");
			++j;
		}
	}
	maplist_reply = strzone(strcat(maplist_reply, "\n"));
	MapInfo_ClearTemps();

	for(i = 0; i < 10; ++i)
	{
		s = getrecords(i);
		if (s)
			records_reply[i] = strzone(s);
	}

	ladder_reply = strzone(getladder());

	rankings_reply = strzone(getrankings());

	// begin other init
	ClientInit_Spawn();
	RandomSeed_Spawn();
	PingPLReport_Spawn();

	CheatInit();

	localcmd("\n_sv_hook_gamestart ", GetGametype(), "\n");

	// fill sv_curl_serverpackages from .serverpackage files
	if(autocvar_sv_curl_serverpackages_auto)
	{
		s = "";
		n = tokenize_console(cvar_string("sv_curl_serverpackages"));
		for(i = 0; i < n; ++i)
			if(substring(argv(i), -14, -1) != "-serverpackage.txt")
			if(substring(argv(i), -14, -1) != ".serverpackage") // OLD legacy
				s = strcat(s, " ", argv(i));
		fd = search_begin("*-serverpackage.txt", TRUE, FALSE);
		if(fd >= 0)
		{
			j = search_getsize(fd);
			for(i = 0; i < j; ++i)
				s = strcat(s, " ", search_getfilename(fd, i));
			search_end(fd);
		}
		fd = search_begin("*.serverpackage", TRUE, FALSE);
		if(fd >= 0)
		{
			j = search_getsize(fd);
			for(i = 0; i < j; ++i)
				s = strcat(s, " ", search_getfilename(fd, i));
			search_end(fd);
		}
		cvar_set("sv_curl_serverpackages", substring(s, 1, -1));
	}

	// MOD AUTHORS: change this, and possibly remove a few of the blocks below to ignore certain changes
	modname = "Xonotic";
	// physics/balance/config changes that count as mod
	if(cvar_string("g_mod_physics") != cvar_defstring("g_mod_physics"))
		modname = cvar_string("g_mod_physics");
	if(cvar_string("g_mod_balance") != cvar_defstring("g_mod_balance"))
		modname = cvar_string("g_mod_balance");
	if(cvar_string("g_mod_config") != cvar_defstring("g_mod_config"))
		modname = cvar_string("g_mod_config");
	// weird mutators that deserve to count as mod
	if(autocvar_g_minstagib)
		modname = "MinstaGib";
	// extra mutators that deserve to count as mod
	MUTATOR_CALLHOOK(SetModname);
	// weird game types that deserve to count as mod
	if(g_cts)
		modname = "CTS";
	// save it for later
	modname = strzone(modname);

	WinningConditionHelper(); // set worldstatus

	g_failsafespawns();
	
	g_randomadditionalspawns();
	
	g_questspawns(); //change spawnpoints if g_questspawns enabled;
	
	g_randomadditionalweapons();
	
	g_randomadditionalitems();
	
	g_rndmaddtnlfurn();
	
	g_ambienttemperature();
	
	g_gameplayfix_spawnbbox();
	
	g_gameplayfix_spawnfilth();
	
	g_suggestedliquidlevels();
	
	world_initialized = 1;
}

void spawnfunc_light (void)
{
	//makestatic (self); // Who the f___ did that?
	remove(self);
}

string GetGametype()
{
	return MapInfo_Type_ToString(MapInfo_LoadedGametype);
}

string getmapname_stored;
string GetMapname()
{
	return mapname;
}

float Map_Count, Map_Current;
string Map_Current_Name;

// NOTE: this now expects the map list to be already tokenized and the count in Map_Count
float GetMaplistPosition()
{
	float pos, idx;
	string map;

	map = GetMapname();
	idx = autocvar_g_maplist_index;

	if(idx >= 0)
		if(idx < Map_Count)
			if(map == argv(idx))
				return idx;

	for(pos = 0; pos < Map_Count; ++pos)
		if(map == argv(pos))
			return pos;

	// resume normal maplist rotation if current map is not in g_maplist
	return idx;
}

float MapHasRightSize(string map)
{
	float fh;
	if(currentbots || autocvar_bot_number || player_count < autocvar_minplayers)
	if(autocvar_g_maplist_check_waypoints)
	{
		dprint("checkwp "); dprint(map);
		if(!fexists(strcat("maps/", map, ".waypoints")))
		{
			dprint(": no waypoints\n");
			return FALSE;
		}
		dprint(": has waypoints\n");
	}

	// open map size restriction file
	dprint("opensize "); dprint(map);
	fh = fopen(strcat("maps/", map, ".sizes"), FILE_READ);
	if(fh >= 0)
	{
		float mapmin, mapmax;
		dprint(": ok, ");
		mapmin = stof(fgets(fh));
		mapmax = stof(fgets(fh));
		fclose(fh);
		if(player_count < mapmin)
		{
			dprint("not enough\n");
			return FALSE;
		}
		if(player_count > mapmax)
		{
			dprint("too many\n");
			return FALSE;
		}
		dprint("right size\n");
		return TRUE;
	}
	dprint(": not found\n");
	return TRUE;
}

string Map_Filename(float position)
{
	return strcat("maps/", argv(position), ".bsp");
}

string strwords(string s, float w)
{
	float endpos;
	for(endpos = 0; w && endpos >= 0; --w)
		endpos = strstrofs(s, " ", endpos + 1);
	if(endpos < 0)
		return s;
	else
		return substring(s, 0, endpos);
}

float strhasword(string s, string w)
{
	return strstrofs(strcat(" ", s, " "), strcat(" ", w, " "), 0) >= 0;
}

void Map_MarkAsRecent(string m)
{
	cvar_set("g_maplist_mostrecent", strwords(strcat(m, " ", autocvar_g_maplist_mostrecent), max(0, autocvar_g_maplist_mostrecent_count)));
}

float Map_IsRecent(string m)
{
	return strhasword(autocvar_g_maplist_mostrecent, m);
}

float Map_Check(float position, float pass)
{
	string filename;
	string map_next;
	map_next = argv(position);
	if(pass <= 1)
	{
		if(Map_IsRecent(map_next))
			return 0;
	}
	filename = Map_Filename(position);
	if(MapInfo_CheckMap(map_next))
	{
		if(pass == 2)
			return 1;
		if(MapHasRightSize(map_next))
			return 1;
		return 0;
	}
	else
		dprint( "Couldn't select '", filename, "'..\n" );

	return 0;
}

void Map_Goto_SetStr(string nextmapname)
{
	if(getmapname_stored != "")
		strunzone(getmapname_stored);
	if(nextmapname == "")
		getmapname_stored = "";
	else
		getmapname_stored = strzone(nextmapname);
}

void Map_Goto_SetFloat(float position)
{
	cvar_set("g_maplist_index", ftos(position));
	Map_Goto_SetStr(argv(position));
}

void Map_Goto(float reinit)
{
	MapInfo_LoadMap(getmapname_stored, reinit);
}

// return codes of map selectors:
//   -1 = temporary failure (that is, try some method that is guaranteed to succeed)
//   -2 = permanent failure
float() MaplistMethod_Iterate = // usual method
{
	float pass, i;

	for(pass = 1; pass <= 2; ++pass)
	{
		for(i = 1; i < Map_Count; ++i)
		{
			float mapindex;
			mapindex = mod(i + Map_Current, Map_Count);
			if(Map_Check(mapindex, pass))
				return mapindex;
		}
	}
	return -1;
}

float() MaplistMethod_Repeat = // fallback method
{
	if(Map_Check(Map_Current, 2))
		return Map_Current;
	return -2;
}

float() MaplistMethod_Random = // random map selection
{
	float i, imax;

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		float mapindex;
		mapindex = mod(Map_Current + floor(random() * (Map_Count - 1) + 1), Map_Count); // any OTHER map
		if(Map_Check(mapindex, 1))
			return mapindex;
	}
	return -1;
}

float(float exponent) MaplistMethod_Shuffle = // more clever shuffling
// the exponent sets a bias on the map selection:
// the higher the exponent, the less likely "shortly repeated" same maps are
{
	float i, j, imax, insertpos;

	imax = 42;

	for(i = 0; i <= imax; ++i)
	{
		string newlist;

		// now reinsert this at another position
		insertpos = pow(random(), 1 / exponent);       // ]0, 1]
		insertpos = insertpos * (Map_Count - 1);       // ]0, Map_Count - 1]
		insertpos = ceil(insertpos) + 1;               // {2, 3, 4, ..., Map_Count}
		dprint("SHUFFLE: insert pos = ", ftos(insertpos), "\n");

		// insert the current map there
		newlist = "";
		for(j = 1; j < insertpos; ++j)                 // i == 1: no loop, will be inserted as first; however, i == 1 has been excluded above
			newlist = strcat(newlist, " ", argv(j));
		newlist = strcat(newlist, " ", argv(0));       // now insert the just selected map
		for(j = insertpos; j < Map_Count; ++j)         // i == Map_Count: no loop, has just been inserted as last
			newlist = strcat(newlist, " ", argv(j));
		newlist = substring(newlist, 1, strlen(newlist) - 1);
		cvar_set("g_maplist", newlist);
		Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");

		// NOTE: the selected map has just been inserted at (insertpos-1)th position
		Map_Current = insertpos - 1; // this is not really valid, but this way the fallback has a chance of working
		if(Map_Check(Map_Current, 1))
			return Map_Current;
	}
	return -1;
}

void Maplist_Init()
{
	Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");
	if(Map_Count == 0)
	{
		bprint( "Maplist is empty!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		Map_Count = tokenizebyseparator(autocvar_g_maplist, " ");
	}
	if(Map_Count == 0)
		error("empty maplist, cannot select a new map");
	Map_Current = bound(0, GetMaplistPosition(), Map_Count - 1);

	if(Map_Current_Name)
		strunzone(Map_Current_Name);
	Map_Current_Name = strzone(argv(Map_Current)); // will be automatically freed on exit thanks to DP
	// this may or may not be correct, but who cares, in the worst case a map
	// isn't chosen in the first pass that should have been
}

string GetNextMap()
{
	float nextMap;

	Maplist_Init();
	nextMap = -1;

	if(nextMap == -1)
		if(autocvar_g_maplist_shuffle > 0)
			nextMap = MaplistMethod_Shuffle(autocvar_g_maplist_shuffle + 1);

	if(nextMap == -1)
		if(autocvar_g_maplist_selectrandom)
			nextMap = MaplistMethod_Random();

	if(nextMap == -1)
		nextMap = MaplistMethod_Iterate();

	if(nextMap == -1)
		nextMap = MaplistMethod_Repeat();

	if(nextMap >= 0)
	{
		Map_Goto_SetFloat(nextMap);
		return getmapname_stored;
	}

	return "";
}

float DoNextMapOverride(float reinit)
{
	if(autocvar_g_campaign)
	{
		CampaignPostIntermission();
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(autocvar_quit_when_empty)
	{
		if(player_count <= currentbots)
		{
			localcmd("quit\n");
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	}
	if(autocvar_quit_and_redirect != "")
	{
		redirection_target = strzone(autocvar_quit_and_redirect);
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if (!reinit && autocvar_samelevel) // if samelevel is set, stay on same level
	{
		localcmd("restart\n");
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	if(autocvar_nextmap != "")
		if(MapInfo_CheckMap(autocvar_nextmap))
		{
			Map_Goto_SetStr(autocvar_nextmap);
			Map_Goto(reinit);
			alreadychangedlevel = TRUE;
			return TRUE;
		}
	if(!reinit && autocvar_lastlevel)
	{
		cvar_settemp_restore();
		localcmd("set lastlevel 0\ntogglemenu 1\n");
		alreadychangedlevel = TRUE;
		return TRUE;
	}
	return FALSE;
}

void GotoNextMap(float reinit)
{
	//string nextmap;
	//float n, nummaps;
	//string s;
	if (alreadychangedlevel)
		return;
	alreadychangedlevel = TRUE;

	{
		string nextMap;
		float allowReset;

		for(allowReset = 1; allowReset >= 0; --allowReset)
		{
			nextMap = GetNextMap();
			if(nextMap != "")
				break;

			if(allowReset)
			{
				bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
				cvar_set("g_maplist", MapInfo_ListAllAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
				if(autocvar_g_maplist_shuffle)
					ShuffleMaplist();
				localcmd("\nmenu_cmd sync\n");
			}
			else
			{
				error("Everything is broken - not even the default map list works. Please report this to the developers.");
			}
		}
		Map_Goto(reinit);
	}
}


/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
.float autoscreenshot;
void() MapVote_Start;
void() MapVote_Think;
float mapvote_initialized;
void IntermissionThink()
{
	FixIntermissionClient(self);

	float server_screenshot = (autocvar_sv_autoscreenshot && self.cvar_cl_autoscreenshot);
	float client_screenshot = (self.cvar_cl_autoscreenshot == 2);

	if( (server_screenshot || client_screenshot)
		&& ((self.autoscreenshot > 0) && (time > self.autoscreenshot)) )
	{
		self.autoscreenshot = -1;
		if(clienttype(self) == CLIENTTYPE_REAL) { stuffcmd(self, sprintf("\nscreenshot screenshots/autoscreenshot/%s-%s.jpg; echo \"^5A screenshot has been taken at request of the server.\"", GetMapname(), strftime(FALSE, "%s"))); }
		return;
	}

	if (time < intermission_exittime)
		return;

	if(!mapvote_initialized)
		if (time < intermission_exittime + 10 && !(self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE))
			return;

	MapVote_Start();
}

/*
============
FindIntermission

Returns the entity to view from
============
*/
/*
entity FindIntermission()
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

// then look for the start position
	spot = find (world, classname, "info_player_deathmatch");
	if (spot)
		return spot;

	//objerror ("FindIntermission: no spot");
	return world;
}
*/

/*
===============================================================================

RULES

===============================================================================
*/

void DumpStats(float final)
{
	float file;
	string s;
	float to_console;
	float to_eventlog;
	float to_file;
	float i;

	to_console = autocvar_sv_logscores_console;
	to_eventlog = autocvar_sv_eventlog;
	to_file = autocvar_sv_logscores_file;

	if(!final)
	{
		to_console = TRUE; // always print printstats replies
		to_eventlog = FALSE; // but never print them to the event log
	}

	if(to_eventlog)
		if(autocvar_sv_eventlog_console)
			to_console = FALSE; // otherwise we get the output twice

	if(final)
		s = ":scores:";
	else
		s = ":status:";
	s = strcat(s, GetGametype(), "_", GetMapname(), ":", ftos(rint(time)));

	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);

	file = -1;
	if(to_file)
	{
		file = fopen(autocvar_sv_logscores_filename, FILE_APPEND);
		if(file == -1)
			to_file = FALSE;
		else
			fputs(file, strcat(s, "\n"));
	}

	s = strcat(":labels:player:", GetPlayerScoreString(world, 0));
	if(to_console)
		print(s, "\n");
	if(to_eventlog)
		GameLogEcho(s);
	if(to_file)
		fputs(file, strcat(s, "\n"));

	FOR_EACH_CLIENT(other)
	{
		if ((clienttype(other) == CLIENTTYPE_REAL) || (clienttype(other) == CLIENTTYPE_BOT && autocvar_sv_logscores_bots))
		{
			s = strcat(":player:see-labels:", GetPlayerScoreString(other, 0), ":");
			s = strcat(s, ftos(rint(time - other.jointime)), ":");
			if(other.classname == "player" || g_arena || g_ca || g_lms)
				s = strcat(s, ftos(other.team), ":");
			else
				s = strcat(s, "spectator:");

			if(to_console)
				print(s, other.netname, "\n");
			if(to_eventlog)
				GameLogEcho(strcat(s, ftos(other.playerid), ":", other.netname));
			if(to_file)
				fputs(file, strcat(s, other.netname, "\n"));
		}
	}

	if(teamplay)
	{
		s = strcat(":labels:teamscores:", GetTeamScoreString(0, 0));
		if(to_console)
			print(s, "\n");
		if(to_eventlog)
			GameLogEcho(s);
		if(to_file)
			fputs(file, strcat(s, "\n"));

		for(i = 1; i < 16; ++i)
		{
			s = strcat(":teamscores:see-labels:", GetTeamScoreString(i, 0));
			s = strcat(s, ":", ftos(i));
			if(to_console)
				print(s, "\n");
			if(to_eventlog)
				GameLogEcho(s);
			if(to_file)
				fputs(file, strcat(s, "\n"));
		}
	}

	if(to_console)
		print(":end\n");
	if(to_eventlog)
		GameLogEcho(":end");
	if(to_file)
	{
		fputs(file, ":end\n");
		fclose(file);
	}
}

void FixIntermissionClient(entity e)
{
	string s;
	if(!e.autoscreenshot) // initial call
	{
		e.autoscreenshot = time + 0.8;	// used for autoscreenshot
		e.health = -2342;
		// first intermission phase; voting phase has positive health (used to decide whether to send SVC_FINALE or not)
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		e.takedamage = DAMAGE_NO;
		if(e.weaponentity)
		{
			e.weaponentity.effects = EF_NODRAW;
			if (e.weaponentity.weaponentity)
				e.weaponentity.weaponentity.effects = EF_NODRAW;
		}
		if(clienttype(e) == CLIENTTYPE_REAL)
		{
			stuffcmd(e, "\nscr_printspeed 1000000\n");
			s = autocvar_sv_intermission_cdtrack;
			if(s != "")
				stuffcmd(e, strcat("\ncd loop ", s, "\n"));
			msg_entity = e;
			WriteByte(MSG_ONE, SVC_INTERMISSION);
		}
	}
}

void minstagib_stop_countdown(entity e);
/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void NextLevel()
{
	gameover = TRUE;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
	if(player_count > 0)
		intermission_exittime = time + autocvar_sv_mapchange_delay;
	else
		intermission_exittime = -1;

	/*
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	// done in FixIntermission
	*/

	//pos = FindIntermission ();

	VoteReset();

	DumpStats(TRUE);

	// send statistics
	entity e;
	PlayerStats_EndMatch(1);
	FOR_EACH_CLIENT(e)
		PlayerStats_AddGlobalInfo(e);
	PlayerStats_Shutdown();
	WeaponStats_Shutdown();

	if(autocvar_sv_eventlog)
		GameLogEcho(":gameover");

	GameLogClose();

	FOR_EACH_PLAYER(other) {
		minstagib_stop_countdown(other);
		FixIntermissionClient(other);
		if(other.winning)
			bprint(other.netname, " ^7wins.\n");
	}

	if(autocvar_g_campaign)
		CampaignPreIntermission();

	TimesinksMatchEnded();
	
	MUTATOR_CALLHOOK(MatchEnd);

	localcmd("\nsv_hook_gameend\n");
}

/*
============
CheckRules_Player

Exit deathmatch games upon conditions
============
*/
void CheckRules_Player()
{
	if (gameover)	// someone else quit the game already
		return;

	if(self.deadflag == DEAD_NO)
		self.play_time += frametime;

	// fixme: don't check players; instead check spawnfunc_dom_team and spawnfunc_ctf_team entities
	//   (div0: and that in CheckRules_World please)
}

float checkrules_equality;
float checkrules_suddendeathwarning;
float checkrules_suddendeathend;
float checkrules_overtimesadded; //how many overtimes have been already added

float WINNING_NO = 0; // no winner, but time limits may terminate the game
float WINNING_YES = 1; // winner found
float WINNING_NEVER = 2; // no winner, enter overtime if time limit is reached
float WINNING_STARTSUDDENDEATHOVERTIME = 3; // no winner, enter suddendeath overtime NOW

float InitiateSuddenDeath()
{
	// Check first whether normal overtimes could be added before initiating suddendeath mode
	// - for this timelimit_overtime needs to be >0 of course
	// - also check the winning condition calculated in the previous frame and only add normal overtime
	//   again, if at the point at which timelimit would be extended again, still no winner was found
	if (!autocvar_g_campaign && (checkrules_overtimesadded >= 0) && (checkrules_overtimesadded < autocvar_timelimit_overtimes) && autocvar_timelimit_overtime && !(g_race && !g_race_qualifying))
	{
		return 1; // need to call InitiateOvertime later
	}
	else
	{
		if(!checkrules_suddendeathend)
		{
			if(autocvar_g_campaign)
				checkrules_suddendeathend = time; // no suddendeath in campaign
			else
				checkrules_suddendeathend = time + 60 * autocvar_timelimit_suddendeath;
			if(g_race && !g_race_qualifying)
				race_StartCompleting();
		}
		return 0;
	}
}

void InitiateOvertime() // ONLY call this if InitiateSuddenDeath returned true
{
	++checkrules_overtimesadded;
	//add one more overtime by simply extending the timelimit
	float tl;
	tl = autocvar_timelimit;
	tl += autocvar_timelimit_overtime;
	cvar_set("timelimit", ftos(tl));
	string minutesPlural;
	if (autocvar_timelimit_overtime == 1)
		minutesPlural = " ^3minute";
	else
		minutesPlural = " ^3minutes";

	bcenterprint(
		strcat(
			"^3Now playing ^1OVERTIME^3!\n\n^3Added ^1",
			ftos(autocvar_timelimit_overtime),
			minutesPlural,
			" to the game!"
		)
	);
}

float GetWinningCode(float fraglimitreached, float equality)
{
	if(autocvar_g_campaign == 1)
		if(fraglimitreached)
			return WINNING_YES;
		else
			return WINNING_NO;

	else
		if(equality)
			if(fraglimitreached)
				return WINNING_STARTSUDDENDEATHOVERTIME;
			else
				return WINNING_NEVER;
		else
			if(fraglimitreached)
				return WINNING_YES;
			else
				return WINNING_NO;
}

// set the .winning flag for exactly those players with a given field value
void SetWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = (head.field == value);
}

// set the .winning flag for those players with a given field value
void AddWinners(.float field, float value)
{
	entity head;
	FOR_EACH_PLAYER(head)
		if(head.field == value)
			head.winning = 1;
}

// clear the .winning flags
void ClearWinners(void)
{
	entity head;
	FOR_EACH_PLAYER(head)
		head.winning = 0;
}

// Onslaught winning condition:
// game terminates if only one team has a working generator (or none)
float WinningCondition_Onslaught()
{
	entity head;
	float t1, t2, t3, t4;

	WinningConditionHelper(); // set worldstatus

	if(inWarmupStage)
		return WINNING_NO;

	// first check if the game has ended
	t1 = t2 = t3 = t4 = 0;
	head = find(world, classname, "onslaught_generator");
	while (head)
	{
		if (head.health > 0)
		{
			if (head.team == COLOR_TEAM1) t1 = 1;
			if (head.team == COLOR_TEAM2) t2 = 1;
			if (head.team == COLOR_TEAM3) t3 = 1;
			if (head.team == COLOR_TEAM4) t4 = 1;
		}
		head = find(head, classname, "onslaught_generator");
	}
	if (t1 + t2 + t3 + t4 < 2)
	{
		// game over, only one team remains (or none)
		ClearWinners();
		if (t1) SetWinners(team, COLOR_TEAM1);
		if (t2) SetWinners(team, COLOR_TEAM2);
		if (t3) SetWinners(team, COLOR_TEAM3);
		if (t4) SetWinners(team, COLOR_TEAM4);
		dprint("Have a winner, ending game.\n");
		return WINNING_YES;
	}

	// Two or more teams remain
	return WINNING_NO;
}

float LMS_NewPlayerLives()
{
	float fl;
	fl = autocvar_fraglimit;
	if(fl == 0)
		fl = 999;

	// first player has left the game for dying too much? Nobody else can get in.
	if(lms_lowest_lives < 1)
		return 0;

	if(!autocvar_g_lms_join_anytime)
		if(lms_lowest_lives < fl - autocvar_g_lms_last_join)
			return 0;

	return bound(1, lms_lowest_lives, fl);
}

// Assault winning condition: If the attackers triggered a round end (by fulfilling all objectives)
// they win. Otherwise the defending team wins once the timelimit passes.
void assault_new_round();
float WinningCondition_Assault()
{
	float status;

	WinningConditionHelper(); // set worldstatus

	status = WINNING_NO;
	// as the timelimit has not yet passed just assume the defending team will win
	if(assault_attacker_team == COLOR_TEAM1)
	{
		SetWinners(team, COLOR_TEAM2);
	}
	else
	{
		SetWinners(team, COLOR_TEAM1);
	}

	entity ent;
	ent = find(world, classname, "target_assault_roundend");
	if(ent)
	{
		if(ent.winning)	// round end has been triggered by attacking team
		{
			bprint("ASSAULT: round completed...\n");
			SetWinners(team, assault_attacker_team);

			TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 666 - TeamScore_AddToTeam(assault_attacker_team, ST_ASSAULT_OBJECTIVES, 0));

			if(ent.cnt == 1 || autocvar_g_campaign) // this was the second round
			{
				status = WINNING_YES;
			}
			else
			{
				entity oldself;
				oldself = self;
				self = ent;
				assault_new_round();
				self = oldself;
			}
		}
	}

	return status;
}

// LMS winning condition: game terminates if and only if there's at most one
// one player who's living lives. Top two scores being equal cancels the time
// limit.
float WinningCondition_LMS()
{
	entity head, head2;
	float have_player;
	float have_players;
	float l;

	have_player = FALSE;
	have_players = FALSE;
	l = LMS_NewPlayerLives();

	head = find(world, classname, "player");
	if(head)
		have_player = TRUE;
	head2 = find(head, classname, "player");
	if(head2)
		have_players = TRUE;

	if(have_player)
	{
		// we have at least one player
		if(have_players)
		{
			// two or more active players - continue with the game
		}
		else
		{
			// exactly one player?

			ClearWinners();
			SetWinners(winning, 0); // NOTE: exactly one player is still "player", so this works out

			if(l)
			{
				// game still running (that is, nobody got removed from the game by a frag yet)? then continue
				return WINNING_NO;
			}
			else
			{
				// a winner!
				// and assign him his first place
				PlayerScore_Add(head, SP_LMS_RANK, 1);
				return WINNING_YES;
			}
		}
	}
	else
	{
		// nobody is playing at all...
		if(l)
		{
			// wait for players...
		}
		else
		{
			// SNAFU (maybe a draw game?)
			ClearWinners();
			dprint("No players, ending game.\n");
			return WINNING_YES;
		}
	}

	// When we get here, we have at least two players who are actually LIVING,
	// now check if the top two players have equal score.
	WinningConditionHelper();

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = TRUE;
	if(WinningConditionHelper_topscore == WinningConditionHelper_secondscore)
		return WINNING_NEVER;

	// Top two have different scores? Way to go for our beloved TIMELIMIT!
	return WINNING_NO;
}

void ShuffleMaplist()
{
	cvar_set("g_maplist", shufflewords(autocvar_g_maplist));
}

float leaderfrags;
float WinningCondition_Scores(float limit, float leadlimit)
{
	float limitreached;

	// TODO make everything use THIS winning condition (except LMS)
	WinningConditionHelper();

	if(teamplay)
	{
		team1_score = TeamScore_GetCompareValue(COLOR_TEAM1);
		team2_score = TeamScore_GetCompareValue(COLOR_TEAM2);
		team3_score = TeamScore_GetCompareValue(COLOR_TEAM3);
		team4_score = TeamScore_GetCompareValue(COLOR_TEAM4);
	}

	ClearWinners();
	if(WinningConditionHelper_winner)
		WinningConditionHelper_winner.winning = 1;
	if(WinningConditionHelper_winnerteam >= 0)
		SetWinners(team, WinningConditionHelper_winnerteam);

	if(WinningConditionHelper_lowerisbetter)
	{
		WinningConditionHelper_topscore = -WinningConditionHelper_topscore;
		WinningConditionHelper_secondscore = -WinningConditionHelper_secondscore;
		limit = -limit;
	}

	if(WinningConditionHelper_zeroisworst)
		leadlimit = 0; // not supported in this mode

	if(g_dm || g_tdm || g_arena || g_ca || (g_race && !g_race_qualifying) || g_nexball)
	// these modes always score in increments of 1, thus this makes sense
	{
		if(leaderfrags != WinningConditionHelper_topscore)
		{
			leaderfrags = WinningConditionHelper_topscore;

			if (limit)
			if (leaderfrags == limit - 1)
				Announce("1fragleft");
			else if (leaderfrags == limit - 2)
				Announce("2fragsleft");
			else if (leaderfrags == limit - 3)
				Announce("3fragsleft");
		}
	}

	limitreached = FALSE;
	if(limit)
		if(WinningConditionHelper_topscore >= limit)
			limitreached = TRUE;
	if(leadlimit)
	{
		float leadlimitreached;
		leadlimitreached = (WinningConditionHelper_topscore - WinningConditionHelper_secondscore >= leadlimit);
		if(autocvar_leadlimit_and_fraglimit)
			limitreached = (limitreached && leadlimitreached);
		else
			limitreached = (limitreached || leadlimitreached);
	}

	if(limit)
		game_completion_ratio = max(game_completion_ratio, bound(0, WinningConditionHelper_topscore / limit, 1));

	return GetWinningCode(
		WinningConditionHelper_topscore && limitreached,
		WinningConditionHelper_equality
	);
}

float WinningCondition_Race(float fraglimit)
{
	float wc;
	entity p;
	float n, c;

	n = 0;
	c = 0;
	FOR_EACH_PLAYER(p)
	{
		++n;
		if(p.race_completed)
			++c;
	}
	if(n && (n == c))
		return WINNING_YES;
	wc = WinningCondition_Scores(fraglimit, 0);

	// ALWAYS initiate overtime, unless EVERYONE has finished the race!
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	// do NOT support equality when the laps are all raced!
		return WINNING_STARTSUDDENDEATHOVERTIME;
	else
		return WINNING_NEVER;
}

float WinningCondition_QualifyingThenRace(float limit)
{
	float wc;
	wc = WinningCondition_Scores(limit, 0);

	// NEVER initiate overtime
	if(wc == WINNING_YES || wc == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		return WINNING_YES;
	}

	return wc;
}

float WinningCondition_RanOutOfSpawns()
{
	entity head;

	if(have_team_spawns <= 0)
		return WINNING_NO;

	if(autocvar_g_spawn_useallspawns <= 0)
		return WINNING_NO;

	if(!some_spawn_has_been_used)
		return WINNING_NO;

	team1_score = team2_score = team3_score = team4_score = 0;

	FOR_EACH_PLAYER(head) if(head.deadflag == DEAD_NO)
	{
		if(head.team == COLOR_TEAM1)
			team1_score = 1;
		else if(head.team == COLOR_TEAM2)
			team2_score = 1;
		else if(head.team == COLOR_TEAM3)
			team3_score = 1;
		else if(head.team == COLOR_TEAM4)
			team4_score = 1;
	}

	for(head = world; (head = find(head, classname, "info_player_deathmatch")) != world; )
	{
		if(head.team == COLOR_TEAM1)
			team1_score = 1;
		else if(head.team == COLOR_TEAM2)
			team2_score = 1;
		else if(head.team == COLOR_TEAM3)
			team3_score = 1;
		else if(head.team == COLOR_TEAM4)
			team4_score = 1;
	}

	ClearWinners();
	if(team1_score + team2_score + team3_score + team4_score == 0)
	{
		checkrules_equality = TRUE;
		return WINNING_YES;
	}
	else if(team1_score + team2_score + team3_score + team4_score == 1)
	{
		float t, i;
		if(team1_score)
			t = COLOR_TEAM1;
		else if(team2_score)
			t = COLOR_TEAM2;
		else if(team3_score)
			t = COLOR_TEAM3;
		else // if(team4_score)
			t = COLOR_TEAM4;
		CheckAllowedTeams(world);
		for(i = 0; i < MAX_TEAMSCORE; ++i)
		{
			if(t != COLOR_TEAM1) if(c1 >= 0) TeamScore_AddToTeam(COLOR_TEAM1, i, -1000);
			if(t != COLOR_TEAM2) if(c2 >= 0) TeamScore_AddToTeam(COLOR_TEAM2, i, -1000);
			if(t != COLOR_TEAM3) if(c3 >= 0) TeamScore_AddToTeam(COLOR_TEAM3, i, -1000);
			if(t != COLOR_TEAM4) if(c4 >= 0) TeamScore_AddToTeam(COLOR_TEAM4, i, -1000);
		}

		AddWinners(team, t);
		return WINNING_YES;
	}
	else
		return WINNING_NO;
}

/*
============
CheckRules_World

Exit deathmatch games upon conditions
============
*/
void ReadyRestart();
void CheckRules_World()
{
	float timelimit;
	float fraglimit;
	float leadlimit;

	VoteThink();
	MapVote_Think();

	SetDefaultAlpha();

	/*
	MapVote_Think should now do that part
	if (intermission_running)
		if (time >= intermission_exittime + 60)
		{
			if(!DoNextMapOverride())
				GotoNextMap();
			return;
		}
	*/

	if (gameover)	// someone else quit the game already
	{
		if(player_count == 0) // Nobody there? Then let's go to the next map
			MapVote_Start();
			// this will actually check the player count in the next frame
			// again, but this shouldn't hurt
		return;
	}

	timelimit = autocvar_timelimit * 60;
	fraglimit = autocvar_fraglimit;
	leadlimit = autocvar_leadlimit;

	if(inWarmupStage || time <= game_starttime) // NOTE: this is <= to prevent problems in the very tic where the game starts
	{
		if(timelimit > 0)
			timelimit = 0; // timelimit is not made for warmup
		if(fraglimit > 0)
			fraglimit = 0; // no fraglimit for now
		leadlimit = 0; // no leadlimit for now
	}

	if(timelimit > 0)
	{
		timelimit += game_starttime;
	}
	else if (timelimit < 0)
	{
		// endmatch
		NextLevel();
		return;
	}

	if(g_onslaught)
		timelimit = 0; // ONS has its own overtime rule

	float wantovertime;
	wantovertime = 0;

	if(timelimit > game_starttime)
		game_completion_ratio = (time - game_starttime) / (timelimit - game_starttime);
	else
		game_completion_ratio = 0;

	if(checkrules_suddendeathend)
	{
		if(!checkrules_suddendeathwarning)
		{
			checkrules_suddendeathwarning = TRUE;
			if(g_race && !g_race_qualifying)
				bcenterprint("^3Everyone, finish your lap! The race is over!");
			else
				bcenterprint("^3Now playing ^1OVERTIME^3!\n\n^3Keep fragging until we have a ^1winner^3!");
		}
	}
	else
	{
		if (timelimit && time >= timelimit)
		{
			if(g_race && (g_race_qualifying == 2) && timelimit > 0)
			{
				float totalplayers;
				float playerswithlaps;
				float readyplayers;
				entity head;
				totalplayers = playerswithlaps = readyplayers = 0;
				FOR_EACH_PLAYER(head)
				{
					++totalplayers;
					if(PlayerScore_Add(head, SP_RACE_FASTEST, 0))
						++playerswithlaps;
					if(head.ready)
						++readyplayers;
				}

				// at least 2 of the players have completed a lap: start the RACE
				// otherwise, the players should end the qualifying on their own
				if(readyplayers || playerswithlaps >= 2)
				{
					checkrules_suddendeathend = 0;
					ReadyRestart(); // go to race
					return;
				}
				else
					wantovertime |= InitiateSuddenDeath();
			}
			else
				wantovertime |= InitiateSuddenDeath();
		}
	}

	if (checkrules_suddendeathend && time >= checkrules_suddendeathend)
	{
		NextLevel();
		return;
	}

	float checkrules_status;
	checkrules_status = WinningCondition_RanOutOfSpawns();
	if(checkrules_status == WINNING_YES)
	{
		bprint("Hey! Someone ran out of spawns!\n");
	}
	else if(g_race && !g_race_qualifying && timelimit >= 0)
	{
		checkrules_status = WinningCondition_Race(fraglimit);
		//print("WC_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_race && g_race_qualifying == 2 && timelimit >= 0)
	{
		checkrules_status = WinningCondition_QualifyingThenRace(fraglimit);
		//print("WC_QUALIFYING_THEN_RACE yields ", ftos(checkrules_status), "\n");
	}
	else if(g_assault)
	{
		checkrules_status = WinningCondition_Assault(); // TODO remove this?
	}
	else if(g_lms)
	{
		checkrules_status = WinningCondition_LMS();
	}
	else if (g_onslaught)
	{
		checkrules_status = WinningCondition_Onslaught(); // TODO remove this?
	}
	else
	{
		checkrules_status = WinningCondition_Scores(fraglimit, leadlimit);
		//print("WC_SCORES yields ", ftos(checkrules_status), "\n");
	}

	if(checkrules_status == WINNING_STARTSUDDENDEATHOVERTIME)
	{
		checkrules_status = WINNING_NEVER;
		checkrules_overtimesadded = -1;
		wantovertime |= InitiateSuddenDeath();
	}

	if(checkrules_status == WINNING_NEVER)
		// equality cases! Nobody wins if the overtime ends in a draw.
		ClearWinners();

	if(wantovertime)
	{
		if(checkrules_status == WINNING_NEVER)
			InitiateOvertime();
		else
			checkrules_status = WINNING_YES;
	}

	if(checkrules_suddendeathend)
		if(checkrules_status != WINNING_NEVER || time >= checkrules_suddendeathend)
			checkrules_status = WINNING_YES;

	if(checkrules_status == WINNING_YES)
	{
		//print("WINNING\n");
		NextLevel();
	}
}

float mapvote_nextthink;
float mapvote_initialized;
float mapvote_keeptwotime;
float mapvote_timeout;
string mapvote_message;
#define MAPVOTE_SCREENSHOT_DIRS_COUNT 4
string mapvote_screenshot_dirs[MAPVOTE_SCREENSHOT_DIRS_COUNT];
float mapvote_screenshot_dirs_count;

float mapvote_count;
float mapvote_count_real;
string mapvote_maps[MAPVOTE_COUNT];
float mapvote_maps_screenshot_dir[MAPVOTE_COUNT];
string mapvote_maps_pakfile[MAPVOTE_COUNT];
float mapvote_maps_suggested[MAPVOTE_COUNT];
string mapvote_suggestions[MAPVOTE_COUNT];
float mapvote_suggestion_ptr;
float mapvote_voters;
float mapvote_selections[MAPVOTE_COUNT];
float mapvote_run;
float mapvote_detail;
float mapvote_abstain;
.float mapvote;

void MapVote_ClearAllVotes()
{
	FOR_EACH_CLIENT(other)
		other.mapvote = 0;
}

string MapVote_Suggest(string m)
{
	float i;
	if(m == "")
		return "That's not how to use this command.";
	if(!autocvar_g_maplist_votable_suggestions)
		return "Suggestions are not accepted on this server.";
	if(mapvote_initialized)
		return "Can't suggest - voting is already in progress!";
	m = MapInfo_FixName(m);
	if not(m)
		return "The map you suggested is not available on this server.";
	if(!autocvar_g_maplist_votable_suggestions_override_mostrecent)
		if(Map_IsRecent(m))
			return "This server does not allow for recent maps to be played again. Please be patient for some rounds.";

	if(!MapInfo_CheckMap(m))
		return "The map you suggested does not support the current game mode.";
	for(i = 0; i < mapvote_suggestion_ptr; ++i)
		if(mapvote_suggestions[i] == m)
			return "This map was already suggested.";
	if(mapvote_suggestion_ptr >= MAPVOTE_COUNT)
	{
		i = floor(random() * mapvote_suggestion_ptr);
	}
	else
	{
		i = mapvote_suggestion_ptr;
		mapvote_suggestion_ptr += 1;
	}
	if(mapvote_suggestions[i] != "")
		strunzone(mapvote_suggestions[i]);
	mapvote_suggestions[i] = strzone(m);
	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":vote:suggested:", m, ":", ftos(self.playerid)));
	return strcat("Suggestion of ", m, " accepted.");
}

void MapVote_AddVotable(string nextMap, float isSuggestion)
{
	float j, i, o;
	string pakfile, mapfile;

	if(nextMap == "")
		return;
	for(j = 0; j < mapvote_count; ++j)
		if(mapvote_maps[j] == nextMap)
			return;
	// suggestions might be no longer valid/allowed after gametype switch!
	if(isSuggestion)
		if(!MapInfo_CheckMap(nextMap))
			return;
	mapvote_maps[mapvote_count] = strzone(nextMap);
	mapvote_maps_suggested[mapvote_count] = isSuggestion;

	pakfile = string_null;
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
	{
		mapfile = strcat(mapvote_screenshot_dirs[i], "/", mapvote_maps[i]);
		pakfile = whichpack(strcat(mapfile, ".tga"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".jpg"));
		if(pakfile == "")
			pakfile = whichpack(strcat(mapfile, ".png"));
		if(pakfile != "")
			break;
	}
	if(i >= mapvote_screenshot_dirs_count)
		i = 0; // FIXME maybe network this error case, as that means there is no mapshot on the server?
	for(o = strstr(pakfile, "/", 0)+1; o > 0; o = strstr(pakfile, "/", 0)+1)
		pakfile = substring(pakfile, o, -1);

	mapvote_maps_screenshot_dir[mapvote_count] = i;
	mapvote_maps_pakfile[mapvote_count] = strzone(pakfile);

	mapvote_count += 1;
}

void MapVote_Spawn();
void MapVote_Init()
{
	float i;
	float nmax, smax;

	MapVote_ClearAllVotes();

	mapvote_count = 0;
	mapvote_detail = !autocvar_g_maplist_votable_nodetail;
	mapvote_abstain = autocvar_g_maplist_votable_abstain;

	if(mapvote_abstain)
		nmax = min(MAPVOTE_COUNT - 1, autocvar_g_maplist_votable);
	else
		nmax = min(MAPVOTE_COUNT, autocvar_g_maplist_votable);
	smax = min3(nmax, autocvar_g_maplist_votable_suggestions, mapvote_suggestion_ptr);

	// we need this for AddVotable, as that cycles through the screenshot dirs
	mapvote_screenshot_dirs_count = tokenize_console(autocvar_g_maplist_votable_screenshot_dir);
	if(mapvote_screenshot_dirs_count == 0)
		mapvote_screenshot_dirs_count = tokenize_console("maps levelshots");
	mapvote_screenshot_dirs_count = min(mapvote_screenshot_dirs_count, MAPVOTE_SCREENSHOT_DIRS_COUNT);
	for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
		mapvote_screenshot_dirs[i] = strzone(argv(i));

	if(mapvote_suggestion_ptr)
		for(i = 0; i < 100 && mapvote_count < smax; ++i)
			MapVote_AddVotable(mapvote_suggestions[floor(random() * mapvote_suggestion_ptr)], TRUE);

	for(i = 0; i < 100 && mapvote_count < nmax; ++i)
		MapVote_AddVotable(GetNextMap(), FALSE);

	if(mapvote_count == 0)
	{
		bprint( "Maplist contains no single playable map!  Resetting it to default map list.\n" );
		cvar_set("g_maplist", MapInfo_ListAllAllowedMaps(MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags()));
		if(autocvar_g_maplist_shuffle)
			ShuffleMaplist();
		localcmd("\nmenu_cmd sync\n");
		for(i = 0; i < 100 && mapvote_count < nmax; ++i)
			MapVote_AddVotable(GetNextMap(), FALSE);
	}

	mapvote_count_real = mapvote_count;
	if(mapvote_abstain)
		MapVote_AddVotable("don't care", 0);

	//dprint("mapvote count is ", ftos(mapvote_count), "\n");

	mapvote_keeptwotime = time + autocvar_g_maplist_votable_keeptwotime;
	mapvote_timeout = time + autocvar_g_maplist_votable_timeout;
	if(mapvote_count_real < 3 || mapvote_keeptwotime <= time)
		mapvote_keeptwotime = 0;
	mapvote_message = "Choose a map and press its key!";

	MapVote_Spawn();
}

void MapVote_SendPicture(float id)
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CSQC_PICTURE);
	WriteByte(MSG_ONE, id);
	WritePicture(MSG_ONE, strcat(mapvote_screenshot_dirs[mapvote_maps_screenshot_dir[id]], "/", mapvote_maps[id]), 3072);
}

float MapVote_GetMapMask()
{
	float mask, i, power;
	mask = 0;
	for(i = 0, power = 1; i < mapvote_count; ++i, power *= 2)
		if(mapvote_maps[i] != "")
			mask |= power;
	return mask;
}

entity mapvote_ent;
float MapVote_SendEntity(entity to, float sf)
{
	float i;

	if(sf & 1)
		sf &~= 2; // if we send 1, we don't need to also send 2

	WriteByte(MSG_ENTITY, ENT_CLIENT_MAPVOTE);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 1)
	{
		// flag 1 == initialization
		for(i = 0; i < mapvote_screenshot_dirs_count; ++i)
			WriteString(MSG_ENTITY, mapvote_screenshot_dirs[i]);
		WriteString(MSG_ENTITY, "");
		WriteByte(MSG_ENTITY, mapvote_count);
		WriteByte(MSG_ENTITY, mapvote_abstain);
		WriteByte(MSG_ENTITY, mapvote_detail);
		WriteCoord(MSG_ENTITY, mapvote_timeout);
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				if(mapvote_abstain && i == mapvote_count - 1)
				{
					WriteString(MSG_ENTITY, ""); // abstain needs no text
					WriteString(MSG_ENTITY, ""); // abstain needs no pack
					WriteByte(MSG_ENTITY, 0); // abstain needs no screenshot dir
				}
				else
				{
					WriteString(MSG_ENTITY, mapvote_maps[i]);
					WriteString(MSG_ENTITY, mapvote_maps_pakfile[i]);
					WriteByte(MSG_ENTITY, mapvote_maps_screenshot_dir[i]);
				}
			}
	}

	if(sf & 2)
	{
		// flag 2 == update of mask
		if(mapvote_count <= 8)
			WriteByte(MSG_ENTITY, MapVote_GetMapMask());
		else
			WriteShort(MSG_ENTITY, MapVote_GetMapMask());
	}

	if(sf & 4)
	{
		if(mapvote_detail)
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
					WriteByte(MSG_ENTITY, mapvote_selections[i]);

		WriteByte(MSG_ENTITY, to.mapvote);
	}

	return TRUE;
}

void MapVote_Spawn()
{
	Net_LinkEntity(mapvote_ent = spawn(), FALSE, 0, MapVote_SendEntity);
}

void MapVote_TouchMask()
{
	mapvote_ent.SendFlags |= 2;
}

void MapVote_TouchVotes(entity voter)
{
	mapvote_ent.SendFlags |= 4;
}

float MapVote_Finished(float mappos)
{
	string result;
	float i;
	float didntvote;

	if(autocvar_sv_eventlog)
	{
		result = strcat(":vote:finished:", mapvote_maps[mappos]);
		result = strcat(result, ":", ftos(mapvote_selections[mappos]), "::");
		didntvote = mapvote_voters;
		for(i = 0; i < mapvote_count; ++i)
			if(mapvote_maps[i] != "")
			{
				didntvote -= mapvote_selections[i];
				if(i != mappos)
				{
					result = strcat(result, ":", mapvote_maps[i]);
					result = strcat(result, ":", ftos(mapvote_selections[i]));
				}
			}
		result = strcat(result, ":didn't vote:", ftos(didntvote));

		GameLogEcho(result);
		if(mapvote_maps_suggested[mappos])
			GameLogEcho(strcat(":vote:suggestion_accepted:", mapvote_maps[mappos]));
	}

	FOR_EACH_REALCLIENT(other)
		FixClientCvars(other);

	Map_Goto_SetStr(mapvote_maps[mappos]);
	Map_Goto(0);
	alreadychangedlevel = TRUE;
	return TRUE;
}
void MapVote_CheckRules_1()
{
	float i;

	for(i = 0; i < mapvote_count; ++i) if(mapvote_maps[i] != "")
	{
		//dprint("Map ", ftos(i), ": "); dprint(mapvote_maps[i], "\n");
		mapvote_selections[i] = 0;
	}

	mapvote_voters = 0;
	FOR_EACH_REALCLIENT(other)
	{
		++mapvote_voters;
		if(other.mapvote)
		{
			i = other.mapvote - 1;
			//dprint("Player ", other.netname, " vote = ", ftos(other.mapvote - 1), "\n");
			mapvote_selections[i] = mapvote_selections[i] + 1;
		}
	}
}

float MapVote_CheckRules_2()
{
	float i;
	float firstPlace, secondPlace;
	float firstPlaceVotes, secondPlaceVotes;
	float mapvote_voters_real;
	string result;

	if(mapvote_count_real == 1)
		return MapVote_Finished(0);

	mapvote_voters_real = mapvote_voters;
	if(mapvote_abstain)
		mapvote_voters_real -= mapvote_selections[mapvote_count - 1];

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
	firstPlace = RandomSelection_chosen_float;
	firstPlaceVotes = RandomSelection_best_priority;
	//dprint("First place: ", ftos(firstPlace), "\n");
	//dprint("First place votes: ", ftos(firstPlaceVotes), "\n");

	RandomSelection_Init();
	for(i = 0; i < mapvote_count_real; ++i) if(mapvote_maps[i] != "")
		if(i != firstPlace)
			RandomSelection_Add(world, i, string_null, 1, mapvote_selections[i]);
	secondPlace = RandomSelection_chosen_float;
	secondPlaceVotes = RandomSelection_best_priority;
	//dprint("Second place: ", ftos(secondPlace), "\n");
	//dprint("Second place votes: ", ftos(secondPlaceVotes), "\n");

	if(firstPlace == -1)
		error("No first place in map vote... WTF?");

	if(secondPlace == -1 || time > mapvote_timeout || (mapvote_voters_real - firstPlaceVotes) < firstPlaceVotes)
		return MapVote_Finished(firstPlace);

	if(mapvote_keeptwotime)
		if(time > mapvote_keeptwotime || (mapvote_voters_real - firstPlaceVotes - secondPlaceVotes) < secondPlaceVotes)
		{
			float didntvote;
			MapVote_TouchMask();
			mapvote_message = "Now decide between the TOP TWO!";
			mapvote_keeptwotime = 0;
			result = strcat(":vote:keeptwo:", mapvote_maps[firstPlace]);
			result = strcat(result, ":", ftos(firstPlaceVotes));
			result = strcat(result, ":", mapvote_maps[secondPlace]);
			result = strcat(result, ":", ftos(secondPlaceVotes), "::");
			didntvote = mapvote_voters;
			for(i = 0; i < mapvote_count; ++i)
				if(mapvote_maps[i] != "")
				{
					didntvote -= mapvote_selections[i];
					if(i != firstPlace)
						if(i != secondPlace)
						{
							result = strcat(result, ":", mapvote_maps[i]);
							result = strcat(result, ":", ftos(mapvote_selections[i]));
							if(i < mapvote_count_real)
							{
								strunzone(mapvote_maps[i]);
								mapvote_maps[i] = "";
								strunzone(mapvote_maps_pakfile[i]);
								mapvote_maps_pakfile[i] = "";
							}
						}
				}
			result = strcat(result, ":didn't vote:", ftos(didntvote));
			if(autocvar_sv_eventlog)
				GameLogEcho(result);
		}

	return FALSE;
}
void MapVote_Tick()
{
	float keeptwo;
	float totalvotes;

	keeptwo = mapvote_keeptwotime;
	MapVote_CheckRules_1(); // count
	if(MapVote_CheckRules_2()) // decide
		return;

	totalvotes = 0;
	FOR_EACH_REALCLIENT(other)
	{
		// hide scoreboard again
		if(other.health != 2342)
		{
			other.health = 2342;
			other.impulse = 0;
			if(clienttype(other) == CLIENTTYPE_REAL)
			{
				msg_entity = other;
				WriteByte(MSG_ONE, SVC_FINALE);
				WriteString(MSG_ONE, "");
			}
		}

		// clear possibly invalid votes
		if(mapvote_maps[other.mapvote - 1] == "")
			other.mapvote = 0;
		// use impulses as new vote
		if(other.impulse >= 1 && other.impulse <= mapvote_count)
			if(mapvote_maps[other.impulse - 1] != "")
			{
				other.mapvote = other.impulse;
				MapVote_TouchVotes(other);
			}
		other.impulse = 0;

		if(other.mapvote)
			++totalvotes;
	}

	MapVote_CheckRules_1(); // just count
}
void MapVote_Start()
{
	if(mapvote_run)
		return;

	// wait for stats to be sent first
	if(!playerstats_waitforme)
		return;

	MapInfo_Enumerate();
	if(MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
		mapvote_run = TRUE;
}
void MapVote_Think()
{
	if(!mapvote_run)
		return;

	if(alreadychangedlevel)
		return;

	if(time < mapvote_nextthink)
		return;
	//dprint("tick\n");

	mapvote_nextthink = time + 0.5;

	if(!mapvote_initialized)
	{
		if(autocvar_rescan_pending == 1)
		{
			cvar_set("rescan_pending", "2");
			localcmd("fs_rescan\nrescan_pending 3\n");
			return;
		}
		else if(autocvar_rescan_pending == 2)
		{
			return;
		}
		else if(autocvar_rescan_pending == 3)
		{
			// now build missing mapinfo files
			if(!MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1))
				return;

			// we're done, start the timer
			cvar_set("rescan_pending", "0");
		}

		mapvote_initialized = TRUE;
		if(DoNextMapOverride(0))
			return;
		if(!autocvar_g_maplist_votable || player_count <= 0)
		{
			GotoNextMap(0);
			return;
		}
		MapVote_Init();
	}

	MapVote_Tick();
}

string GotoMap(string m)
{
	if(!MapInfo_CheckMap(m))
		return "The map you chose is not available on this server.";
	cvar_set("nextmap", m);
	cvar_set("timelimit", "-1");
	if(mapvote_initialized || alreadychangedlevel)
	{
		if(DoNextMapOverride(0))
			return "Map switch initiated.";
		else
			return "Hm... no. For some reason I like THIS map more.";
	}
	else
		return "Map switch will happen after scoreboard.";
}


void EndFrame()
{
	float altime;
	FOR_EACH_REALCLIENT(self)
	{
		if(self.classname == "spectator")
		{
			if(self.enemy.typehitsound)
				self.typehit_time = time;
			else if(self.enemy.hitsound)
				self.hit_time = time;
		}
		else
		{
			if(self.typehitsound)
				self.typehit_time = time;
			else if(self.hitsound)
				self.hit_time = time;
		}
	}
	altime = time + frametime * (1 + autocvar_g_antilag_nudge);
	// add 1 frametime because after this, engine SV_Physics
	// increases time by a frametime and then networks the frame
	// add another frametime because client shows everything with
	// 1 frame of lag (cl_nolerp 0). The last +1 however should not be
	// needed!
	FOR_EACH_CLIENT(self)
	{
		self.hitsound = FALSE;
		self.typehitsound = FALSE;
		antilag_record(self, altime);
	}
}


/*
 * RedirectionThink:
 * returns TRUE if redirecting
 */
float redirection_timeout;
float redirection_nextthink;
float RedirectionThink()
{
	float clients_found;

	if(redirection_target == "")
		return FALSE;

	if(!redirection_timeout)
	{
		cvar_set("sv_public", "-2");
		redirection_timeout = time + 0.6; // this will only try twice... should be able to keep more clients
		if(redirection_target == "self")
			bprint("^3SERVER NOTICE:^7 restarting the server\n");
		else
			bprint("^3SERVER NOTICE:^7 redirecting everyone to ", redirection_target, "\n");
	}

	if(time < redirection_nextthink)
		return TRUE;

	redirection_nextthink = time + 1;

	clients_found = 0;
	FOR_EACH_REALCLIENT(self)
	{
		// TODO add timer
		print("Redirecting: sending connect command to ", self.netname, "\n");
		if(redirection_target == "self")
			stuffcmd(self, "\ndisconnect; defer ", ftos(autocvar_quit_and_redirect_timer), " reconnect\n");
		else
			stuffcmd(self, strcat("\ndisconnect; defer ", ftos(autocvar_quit_and_redirect_timer), " \"connect ", redirection_target, "\"\n"));
		++clients_found;
	}

	print("Redirecting: ", ftos(clients_found), " clients left.\n");

	if(time > redirection_timeout || clients_found == 0)
		localcmd("\nwait; wait; wait; quit\n");

	return TRUE;
}

void TargetMusic_RestoreGame();
void RestoreGame()
{
	// Loaded from a save game
	// some things then break, so let's work around them...

	// Progs DB (capture records)
	ServerProgsDB = db_load(strcat("server.db", autocvar_sessionid));

	// Mapinfo
	MapInfo_Shutdown();
	MapInfo_Enumerate();
	MapInfo_FilterGametype(MapInfo_CurrentGametype(), MapInfo_CurrentFeatures(), MapInfo_RequiredFlags(), MapInfo_ForbiddenFlags(), 1);
	WeaponStats_Init();

	TargetMusic_RestoreGame();
}

void Shutdown()
{
	entity e;

	gameover = 2;

	if(world_initialized > 0)
	{
		world_initialized = 0;
		print("Saving persistent data...\n");
		Ban_SaveBans();

		PlayerStats_EndMatch(0);
		FOR_EACH_CLIENT(e)
			PlayerStats_AddGlobalInfo(e);
		PlayerStats_Shutdown();

		if(!cheatcount_total)
		{
			if(autocvar_sv_db_saveasdump)
				db_dump(ServerProgsDB, strcat("server.db", autocvar_sessionid));
			else
				db_save(ServerProgsDB, strcat("server.db", autocvar_sessionid));
		}
		if(autocvar_developer)
		{
			if(autocvar_sv_db_saveasdump)
				db_dump(TemporaryDB, "server-temp.db");
			else
				db_save(TemporaryDB, "server-temp.db");
		}
		CheatShutdown(); // must be after cheatcount check
		db_close(ServerProgsDB);
		db_close(TemporaryDB);
		print("done!\n");
		// tell the bot system the game is ending now
		bot_endgame();

		WeaponStats_Shutdown();
		MapInfo_Shutdown();
	}
	else if(world_initialized == 0)
	{
		print("NOTE: crashed before even initializing the world, not saving persistent data\n");
	}
}
