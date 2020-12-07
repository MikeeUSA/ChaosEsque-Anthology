var void remove(entity e);
void objerror(string s);
void droptofloor();
.vector dropped_origin;

void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void crosshair_trace(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}
void crosshair_trace2(entity pl)
{
	traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, pl, ANTILAG_LATENCY(pl));
}
void crosshair_trace_plusvisibletriggers(entity pl)
{
	entity first;
	entity e;
	first = findchainfloat(solid, SOLID_TRIGGER);

	for (e = first; e; e = e.chain)
		if (e.model != "")
			e.solid = SOLID_BSP;

	crosshair_trace(pl);

	for (e = first; e; e = e.chain)
		e.solid = SOLID_TRIGGER;
}
void WarpZone_traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag);
void WarpZone_crosshair_trace(entity pl)
{
	WarpZone_traceline_antilag(pl, pl.cursor_trace_start, pl.cursor_trace_start + normalize(pl.cursor_trace_endpos - pl.cursor_trace_start) * MAX_SHOT_DISTANCE, MOVE_NORMAL, pl, ANTILAG_LATENCY(pl));
}

void() spawnfunc_info_player_deathmatch; // needed for the other spawnpoints
void() spawnpoint_use;
string GetMapname();
string ColoredTeamName(float t);

string admin_name(void)
{
	if(autocvar_sv_adminnick != "")
		return autocvar_sv_adminnick;
	else
		return "SERVER ADMIN";
}

float DistributeEvenly_amount;
float DistributeEvenly_totalweight;
void DistributeEvenly_Init(float amount, float totalweight)
{
    if (DistributeEvenly_amount)
    {
        dprint("DistributeEvenly_Init: UNFINISHED DISTRIBUTION (", ftos(DistributeEvenly_amount), " for ");
        dprint(ftos(DistributeEvenly_totalweight), " left!)\n");
    }
    if (totalweight == 0)
        DistributeEvenly_amount = 0;
    else
        DistributeEvenly_amount = amount;
    DistributeEvenly_totalweight = totalweight;
}
float DistributeEvenly_Get(float weight)
{
    float f;
    if (weight <= 0)
        return 0;
    f = floor(0.5 + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
    DistributeEvenly_totalweight -= weight;
    DistributeEvenly_amount -= f;
    return f;
}
float DistributeEvenly_GetRandomized(float weight)
{
    float f;
    if (weight <= 0)
        return 0;
    f = floor(random() + DistributeEvenly_amount * weight / DistributeEvenly_totalweight);
    DistributeEvenly_totalweight -= weight;
    DistributeEvenly_amount -= f;
    return f;
}

#define move_out_of_solid(e) WarpZoneLib_MoveOutOfSolid(e)


string STR_PLAYER = "player";
string STR_SPECTATOR = "spectator";
string STR_OBSERVER = "observer";

#if 0
#define FOR_EACH_CLIENT(v) for(v = world; (v = findflags(v, flags, FL_CLIENT)) != world; )
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) for(v = world; (v = find(v, classname, STR_PLAYER)) != world; )
#define FOR_EACH_REALPLAYER(v) FOR_EACH_PLAYER(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_MONSTER(v) for(v = world; (v = findflags(v, flags, FL_MONSTER)) != world; )
#else
#define FOR_EACH_CLIENTSLOT(v) for(v = world; (v = nextent(v)) && (num_for_edict(v) <= maxclients); )
#define FOR_EACH_CLIENT(v) FOR_EACH_CLIENTSLOT(v) if(v.flags & FL_CLIENT)
#define FOR_EACH_REALCLIENT(v) FOR_EACH_CLIENT(v) if(clienttype(v) == CLIENTTYPE_REAL)
#define FOR_EACH_PLAYER(v) FOR_EACH_CLIENT(v) if(v.classname == STR_PLAYER)
#define FOR_EACH_SPEC(v) FOR_EACH_CLIENT(v) if(v.classname != STR_PLAYER)
#define FOR_EACH_REALPLAYER(v) FOR_EACH_REALCLIENT(v) if(v.classname == STR_PLAYER)
#define FOR_EACH_MONSTER(v) for(v = world; (v = findflags(v, flags, FL_MONSTER)) != world; )
#endif

#define CENTER_OR_VIEWOFS(ent) (ent.origin + ((ent.classname == STR_PLAYER) ? ent.view_ofs : ((ent.mins + ent.maxs) * 0.5)))

// copies a string to a tempstring (so one can strunzone it)
string strcat1(string s) = #115; // FRIK_FILE

float logfile_open;
float logfile;

void bcenterprint(string s)
{
    // TODO replace by MSG_ALL (would show it to spectators too, though)?
    entity head;
    FOR_EACH_PLAYER(head)
    if (clienttype(head) == CLIENTTYPE_REAL)
        centerprint(head, s);
}

void GameLogEcho(string s)
{
    string fn;
    float matches;

    if (autocvar_sv_eventlog_files)
    {
        if (!logfile_open)
        {
            logfile_open = TRUE;
            matches = autocvar_sv_eventlog_files_counter + 1;
            cvar_set("sv_eventlog_files_counter", ftos(matches));
            fn = ftos(matches);
            if (strlen(fn) < 8)
                fn = strcat(substring("00000000", 0, 8 - strlen(fn)), fn);
            fn = strcat(autocvar_sv_eventlog_files_nameprefix, fn, autocvar_sv_eventlog_files_namesuffix);
            logfile = fopen(fn, FILE_APPEND);
            fputs(logfile, ":logversion:3\n");
        }
        if (logfile >= 0)
        {
            if (autocvar_sv_eventlog_files_timestamps)
                fputs(logfile, strcat(":time:", strftime(TRUE, "%Y-%m-%d %H:%M:%S", "\n", s, "\n")));
            else
                fputs(logfile, strcat(s, "\n"));
        }
    }
    if (autocvar_sv_eventlog_console)
    {
        print(s, "\n");
    }
}

void GameLogInit()
{
    logfile_open = 0;
    // will be opened later
}

void GameLogClose()
{
    if (logfile_open && logfile >= 0)
    {
        fclose(logfile);
        logfile = -1;
    }
}

float spawnpoint_nag;
void relocate_spawnpoint()
{
    // nudge off the floor
    setorigin(self, self.origin + '0 0 1');

    tracebox(self.origin, PL_MIN, PL_MAX, self.origin, TRUE, self);
    if (trace_startsolid)
    {
        vector o;
        o = self.origin;
        self.mins = PL_MIN;
        self.maxs = PL_MAX;
        if (!move_out_of_solid(self))
            objerror("could not get out of solid at all!");
        print("^1NOTE: this map needs FIXING. Spawnpoint at ", vtos(o - '0 0 1'));
        print(" needs to be moved out of solid, e.g. by '", ftos(self.origin_x - o_x));
        print(" ", ftos(self.origin_y - o_y));
        print(" ", ftos(self.origin_z - o_z), "'\n");
        if (autocvar_g_spawnpoints_auto_move_out_of_solid)
        {
            if (!spawnpoint_nag)
                print("\{1}^1NOTE: this map needs FIXING (it contains spawnpoints in solid, see server log)\n");
            spawnpoint_nag = 1;
        }
        else
        {
            setorigin(self, o);
            self.mins = self.maxs = '0 0 0';
            objerror("player spawn point in solid, mapper sucks!\n");
            return;
        }
    }

    self.use = spawnpoint_use;
    self.team_saved = self.team;
    if (!self.cnt)
        self.cnt = 1;

    if (have_team_spawns != 0)
        if (self.team)
            have_team_spawns = 1;
    have_team_spawns_forteam[self.team] = 1;

    if (autocvar_r_showbboxes)
    {
        // show where spawnpoints point at too
        makevectors(self.angles);
        entity e;
        e = spawn();
        e.classname = "info_player_foo";
        setorigin(e, self.origin + v_forward * 24);
        setsize(e, '-8 -8 -8', '8 8 8');
        e.solid = SOLID_TRIGGER;
    }
}

#define strstr strstrofs
/*
// NOTE: DO NOT USE THIS FUNCTION TOO OFTEN.
// IT WILL MOST PROBABLY DESTROY _ALL_ OTHER TEMP
// STRINGS AND TAKE QUITE LONG. haystack and needle MUST
// BE CONSTANT OR strzoneD!
float strstr(string haystack, string needle, float offset)
{
	float len, endpos;
	string found;
	len = strlen(needle);
	endpos = strlen(haystack) - len;
	while(offset <= endpos)
	{
		found = substring(haystack, offset, len);
		if(found == needle)
			return offset;
		offset = offset + 1;
	}
	return -1;
}
*/

float NUM_NEAREST_ENTITIES = 4;
entity nearest_entity[NUM_NEAREST_ENTITIES];
float nearest_length[NUM_NEAREST_ENTITIES];
entity findnearest(vector point, .string field, string value, vector axismod)
{
    entity localhead;
    float i;
    float j;
    float len;
    vector dist;

    float num_nearest;
    num_nearest = 0;

    localhead = find(world, field, value);
    while (localhead)
    {
        if ((localhead.items == IT_KEY1 || localhead.items == IT_KEY2) && localhead.target == "###item###")
            dist = localhead.oldorigin;
        else
            dist = localhead.origin;
        dist = dist - point;
        dist = dist_x * axismod_x * '1 0 0' + dist_y * axismod_y * '0 1 0' + dist_z * axismod_z * '0 0 1';
        len = vlen(dist);

        for (i = 0; i < num_nearest; ++i)
        {
            if (len < nearest_length[i])
                break;
        }

        // now i tells us where to insert at
        //   INSERTION SORT! YOU'VE SEEN IT! RUN!
        if (i < NUM_NEAREST_ENTITIES)
        {
            for (j = NUM_NEAREST_ENTITIES - 1; j >= i; --j)
            {
                nearest_length[j + 1] = nearest_length[j];
                nearest_entity[j + 1] = nearest_entity[j];
            }
            nearest_length[i] = len;
            nearest_entity[i] = localhead;
            if (num_nearest < NUM_NEAREST_ENTITIES)
                num_nearest = num_nearest + 1;
        }

        localhead = find(localhead, field, value);
    }

    // now use the first one from our list that we can see
    for (i = 0; i < num_nearest; ++i)
    {
        traceline(point, nearest_entity[i].origin, TRUE, world);
        if (trace_fraction == 1)
        {
            if (i != 0)
            {
                dprint("Nearest point (");
                dprint(nearest_entity[0].netname);
                dprint(") is not visible, using a visible one.\n");
            }
            return nearest_entity[i];
        }
    }

    if (num_nearest == 0)
        return world;

    dprint("Not seeing any location point, using nearest as fallback.\n");
    /* DEBUGGING CODE:
    dprint("Candidates were: ");
    for(j = 0; j < num_nearest; ++j)
    {
    	if(j != 0)
    		dprint(", ");
    	dprint(nearest_entity[j].netname);
    }
    dprint("\n");
    */

    return nearest_entity[0];
}

void spawnfunc_target_location()
{
    self.classname = "target_location";
    // location name in netname
    // eventually support: count, teamgame selectors, line of sight?
}

void spawnfunc_info_location()
{
    self.classname = "target_location";
    self.message = self.netname;
}

string NearestLocation(vector p)
{
    entity loc;
    string ret;
    ret = "somewhere";
    loc = findnearest(p, classname, "target_location", '1 1 1');
    if (loc)
    {
        ret = loc.message;
    }
    else
    {
        loc = findnearest(p, target, "###item###", '1 1 4');
        if (loc)
            ret = loc.netname;
    }
    return ret;
}

string formatmessage(string msg)
{
	float p, p1, p2;
	float n;
	vector cursor;
	entity cursor_ent;
	string escape;
	string replacement;
	p = 0;
	n = 7;

	WarpZone_crosshair_trace(self);
	cursor = trace_endpos;
	cursor_ent = trace_ent;

	while (1) {
		if (n < 1)
			break; // too many replacements

		n = n - 1;
		p1 = strstr(msg, "%", p); // NOTE: this destroys msg as it's a tempstring!
		p2 = strstr(msg, "\\", p); // NOTE: this destroys msg as it's a tempstring!

		if (p1 < 0)
			p1 = p2;

		if (p2 < 0)
			p2 = p1;

		p = min(p1, p2);

		if (p < 0)
			break;

		replacement = substring(msg, p, 2);
		escape = substring(msg, p + 1, 1);

		if (escape == "%")
			replacement = "%";
		else if (escape == "\\")
			replacement = "\\";
		else if (escape == "n")
			replacement = "\n";
		else if (escape == "a")
			replacement = ftos(floor(self.armorvalue));
		else if (escape == "h")
			replacement = ftos(floor(self.health));
		else if (escape == "l")
			replacement = NearestLocation(self.origin);
		else if (escape == "y")
			replacement = NearestLocation(cursor);
		else if (escape == "d")
			replacement = NearestLocation(self.death_origin);
		else if (escape == "w") {
			float wep;
			wep = self.weapon;
			if (!wep)
				wep = self.switchweapon;
			if (!wep)
				wep = self.cnt;
			replacement = W_Name(wep);
		} else if (escape == "W") {
			if (self.items & IT_SHELLS) replacement = "shells";
			else if (self.items & IT_NAILS) replacement = "bullets";
			else if (self.items & IT_ROCKETS) replacement = "rockets";
			else if (self.items & IT_CELLS) replacement = "cells";
			else replacement = "batteries"; // ;)
		} else if (escape == "x") {
			replacement = cursor_ent.netname;
			if (replacement == "" || !cursor_ent)
				replacement = "nothing";
		} else if (escape == "s")
			replacement = ftos(vlen(self.velocity - self.velocity_z * '0 0 1'));
		else if (escape == "S")
			replacement = ftos(vlen(self.velocity));

		msg = strcat(substring(msg, 0, p), replacement, substring(msg, p+2, strlen(msg) - (p+2)));
		p = p + strlen(replacement);
	}
	return msg;
}

float boolean(float value) { // if value is 0 return FALSE (0), otherwise return TRUE (1)
	return (value == 0) ? FALSE : TRUE;
}

/*
=============
GetCvars
=============
Called with:
  0:  sends the request
  >0: receives a cvar from name=argv(f) value=argv(f+1)
*/
void GetCvars_handleString(string thisname, float f, .string field, string name)
{
	if (f < 0)
	{
		if (self.field)
			strunzone(self.field);
		self.field = string_null;
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if (self.field)
				strunzone(self.field);
			self.field = strzone(argv(f + 1));
		}
	}
	else
		stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleString_Fixup(string thisname, float f, .string field, string name, string(string) func)
{
	GetCvars_handleString(thisname, f, field, name);
	if (f >= 0) // also initialize to the fitting value for "" when sending cvars out
		if (thisname == name)
		{
			string s;
			s = func(strcat1(self.field));
			if (s != self.field)
			{
				strunzone(self.field);
				self.field = strzone(s);
			}
		}
}
void GetCvars_handleFloat(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
			self.field = stof(argv(f + 1));
	}
	else
		stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
}
void GetCvars_handleFloatOnce(string thisname, float f, .float field, string name)
{
	if (f < 0)
	{
	}
	else if (f > 0)
	{
		if (thisname == name)
		{
			if(!self.field)
			{
				self.field = stof(argv(f + 1));
				if(!self.field)
					self.field = -1;
			}
		}
	}
	else
	{
		if(!self.field)
			stuffcmd(self, strcat("cl_cmd sendcvar ", name, "\n"));
	}
}
float w_getbestweapon(entity e);
string W_FixWeaponOrder_ForceComplete_AndBuildImpulseList(string wo)
{
	string o;
	o = W_FixWeaponOrder_ForceComplete(wo);
	if(self.weaponorder_byimpulse)
	{
		strunzone(self.weaponorder_byimpulse);
		self.weaponorder_byimpulse = string_null;
	}
	self.weaponorder_byimpulse = strzone(W_FixWeaponOrder_BuildImpulseList(o));
	return o;
}
void GetCvars(float f)
{
	string s = string_null;

	if (f > 0)
		s = strcat1(argv(f));

	get_cvars_f = f;
	get_cvars_s = s;
	MUTATOR_CALLHOOK(GetCvars);
	GetCvars_handleFloat(s, f, autoswitch, "cl_autoswitch");
	GetCvars_handleFloat(s, f, cvar_cl_autoscreenshot, "cl_autoscreenshot");
	GetCvars_handleString(s, f, cvar_g_xonoticversion, "g_xonoticversion");
	GetCvars_handleFloat(s, f, cvar_cl_handicap, "cl_handicap");
	GetCvars_handleFloat(s, f, cvar_cl_clippedspectating, "cl_clippedspectating");
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriority, "cl_weaponpriority", W_FixWeaponOrder_ForceComplete_AndBuildImpulseList);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[0], "cl_weaponpriority0", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[1], "cl_weaponpriority1", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[2], "cl_weaponpriority2", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[3], "cl_weaponpriority3", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[4], "cl_weaponpriority4", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[5], "cl_weaponpriority5", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[6], "cl_weaponpriority6", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[7], "cl_weaponpriority7", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[8], "cl_weaponpriority8", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleString_Fixup(s, f, cvar_cl_weaponpriorities[9], "cl_weaponpriority9", W_FixWeaponOrder_AllowIncomplete);
	GetCvars_handleFloat(s, f, cvar_cl_weaponimpulsemode, "cl_weaponimpulsemode");
	GetCvars_handleFloat(s, f, cvar_cl_autotaunt, "cl_autotaunt");
	GetCvars_handleFloat(s, f, cvar_cl_noantilag, "cl_noantilag");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional, "cl_voice_directional");
	GetCvars_handleFloat(s, f, cvar_cl_voice_directional_taunt_attenuation, "cl_voice_directional_taunt_attenuation");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_share, "cl_accuracy_data_share");
	GetCvars_handleFloat(s, f, cvar_cl_accuracy_data_receive, "cl_accuracy_data_receive");

	self.cvar_cl_accuracy_data_share = boolean(self.cvar_cl_accuracy_data_share);
	self.cvar_cl_accuracy_data_receive = boolean(self.cvar_cl_accuracy_data_receive);

#ifdef ALLOW_FORCEMODELS
	GetCvars_handleFloat(s, f, cvar_cl_forceplayermodels, "cl_forceplayermodels");
	GetCvars_handleFloat(s, f, cvar_cl_forceplayermodelsfromxonotic, "cl_forceplayermodelsfromxonotic");
#endif
	GetCvars_handleFloatOnce(s, f, cvar_cl_gunalign, "cl_gunalign");
	GetCvars_handleFloat(s, f, cvar_cl_allow_uid2name, "cl_allow_uid2name");
	GetCvars_handleFloat(s, f, cvar_cl_allow_uidtracking, "cl_allow_uidtracking");
	GetCvars_handleFloat(s, f, cvar_cl_movement_track_canjump, "cl_movement_track_canjump");
	GetCvars_handleFloat(s, f, cvar_cl_newusekeysupported, "cl_newusekeysupported");

	// fixup of switchweapon (needed for LMS or when spectating is disabled, as PutClientInServer comes too early)
	if (f > 0)
	{
		if (s == "cl_weaponpriority")
			self.switchweapon = w_getbestweapon(self);
		if (s == "cl_allow_uidtracking")
			PlayerStats_AddPlayer(self);
	}
}

void backtrace(string msg)
{
    float dev, war;
    dev = autocvar_developer;
    war = autocvar_prvm_backtraceforwarnings;
    cvar_set("developer", "1");
    cvar_set("prvm_backtraceforwarnings", "1");
    print("\n");
    print("--- CUT HERE ---\nWARNING: ");
    print(msg);
    print("\n");
    remove(world); // isn't there any better way to cause a backtrace?
    print("\n--- CUT UNTIL HERE ---\n");
    cvar_set("developer", ftos(dev));
    cvar_set("prvm_backtraceforwarnings", ftos(war));
}

string Team_ColorCode(float teamid)
{
    if (teamid == COLOR_TEAM1)
        return "^1";
    else if (teamid == COLOR_TEAM2)
        return "^4";
    else if (teamid == COLOR_TEAM3)
        return "^3";
    else if (teamid == COLOR_TEAM4)
        return "^6";
    else
        return "^7";
}

string Team_ColorName(float t)
{
    // fixme: Search for team entities and get their .netname's!
    if (t == COLOR_TEAM1)
        return "Red";
    if (t == COLOR_TEAM2)
        return "Blue";
    if (t == COLOR_TEAM3)
        return "Yellow";
    if (t == COLOR_TEAM4)
        return "Pink";
    return "Neutral";
}

string Team_ColorNameLowerCase(float t)
{
    // fixme: Search for team entities and get their .netname's!
    if (t == COLOR_TEAM1)
        return "red";
    if (t == COLOR_TEAM2)
        return "blue";
    if (t == COLOR_TEAM3)
        return "yellow";
    if (t == COLOR_TEAM4)
        return "pink";
    return "neutral";
}

float ColourToNumber(string team_colour)
{
	if (team_colour == "red")
		return COLOR_TEAM1;

	if (team_colour == "blue")
		return COLOR_TEAM2;

	if (team_colour == "yellow")
		return COLOR_TEAM3;

	if (team_colour == "pink")
		return COLOR_TEAM4;

	if (team_colour == "auto")
		return 0;

	return -1;
}

float NumberToTeamNumber(float number)
{
	if (number == 1)
		return COLOR_TEAM1;

	if (number == 2)
		return COLOR_TEAM2;

	if (number == 3)
		return COLOR_TEAM3;

	if (number == 4)
		return COLOR_TEAM4;

	return -1;
}

// decolorizes and team colors the player name when needed
string playername(entity p)
{
    string t;
    if (teamplay && !intermission_running && p.classname == "player")
    {
        t = Team_ColorCode(p.team);
        return strcat(t, strdecolorize(p.netname));
    }
    else
        return p.netname;
}

vector randompos(vector m1, vector m2)
{
    vector v;
    m2 = m2 - m1;
    v_x = m2_x * random() + m1_x;
    v_y = m2_y * random() + m1_y;
    v_z = m2_z * random() + m1_z;
    return  v;
}

//#NO AUTOCVARS START

float g_pickup_shells;
float g_pickup_shells_max;
float g_pickup_nails;
float g_pickup_nails_max;
float g_pickup_rockets;
float g_pickup_rockets_max;
float g_pickup_cells;
float g_pickup_cells_max;
float g_pickup_fuel;
float g_pickup_fuel_jetpack;
float g_pickup_fuel_max;
float g_pickup_armorsmall;
float g_pickup_armorsmall_max;
float g_pickup_armorsmall_anyway;
float g_pickup_armormedium;
float g_pickup_armormedium_max;
float g_pickup_armormedium_anyway;
float g_pickup_armorbig;
float g_pickup_armorbig_max;
float g_pickup_armorbig_anyway;
float g_pickup_armorlarge;
float g_pickup_armorlarge_max;
float g_pickup_armorlarge_anyway;
float g_pickup_healthsmall;
float g_pickup_healthsmall_max;
float g_pickup_healthsmall_anyway;
float g_pickup_healthmedium;
float g_pickup_healthmedium_max;
float g_pickup_healthmedium_anyway;
float g_pickup_healthlarge;
float g_pickup_healthlarge_max;
float g_pickup_healthlarge_anyway;
float g_pickup_healthmega;
float g_pickup_healthmega_max;
float g_pickup_healthmega_anyway;
float g_pickup_ammo_anyway;
float g_pickup_weapons_anyway;
float g_weaponarena;
WEPSET_DECLARE_A(g_weaponarena_weapons);
float g_weaponarena_random;
float g_weaponarena_random_with_laser;
string g_weaponarena_list;
float g_weaponspeedfactor;
float g_weaponratefactor;
float g_weapondamagefactor;
float g_weaponforcefactor;
float g_weaponspreadfactor;
float g_weaponnomangleorhobble;

WEPSET_DECLARE_A(start_weapons_team1); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_team2); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_team3); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_team4); //Chaos-esque addition

//for playerclasses
float g_playerclass;
float playerclassset; //which set to use?
float PLAYERCLASSSET_DEFAULT = 1;
float PLAYERCLASSSET_DEFAULT2 = 2; //todo
float PLAYERCLASSSET_MEDIEVALFANTASY = 3;
float PLAYERCLASSSET_XON = 4;
float PLAYERCLASSSET_OLDWEST = 5;
float PLAYERCLASSSET_WWI = 6;
WEPSET_DECLARE_A(start_weapons_playerclass_longdistance); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_marksman); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_mediumdistance); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_assault); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_closerange); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_destructive); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_heavyweapons); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_pyromaniac); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_engineer); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_worker); //Chaos-esque addition
WEPSET_DECLARE_A(start_weapons_playerclass_healer); //Chaos-esque addition
float start_add_ammo_shells_playerclass_longdistance;
float start_add_ammo_nails_playerclass_longdistance;
float start_add_ammo_rockets_playerclass_longdistance;
float start_add_ammo_cells_playerclass_longdistance;
float start_add_ammo_fuel_playerclass_longdistance;
float start_add_health_playerclass_longdistance;
float start_add_armorvalue_playerclass_longdistance;
float start_add_mana_playerclass_longdistance;
float start_add_grenades_playerclass_longdistance;
float start_add_flashbangs_playerclass_longdistance;
float start_add_smokenades_playerclass_longdistance;
float start_add_fragnades_playerclass_longdistance;
float start_add_atmines_playerclass_longdistance;
float start_add_landmines_playerclass_longdistance;
float start_add_inv_potion_health_small_longdistance;
float start_add_inv_potion_health_medium_longdistance;
float start_add_inv_potion_health_large_longdistance;
float start_add_inv_potion_mana_small_longdistance;
float start_add_inv_potion_mana_medium_longdistance;
float start_add_inv_potion_mana_large_longdistance;
float start_add_inv_potion_rejuv_small_longdistance;
float start_add_inv_potion_rejuv_medium_longdistance;
float start_add_inv_potion_rejuv_large_longdistance;

float start_add_ammo_shells_playerclass_marksman;
float start_add_ammo_nails_playerclass_marksman;
float start_add_ammo_rockets_playerclass_marksman;
float start_add_ammo_cells_playerclass_marksman;
float start_add_ammo_fuel_playerclass_marksman;
float start_add_health_playerclass_marksman;
float start_add_armorvalue_playerclass_marksman;
float start_add_mana_playerclass_marksman;
float start_add_grenades_playerclass_marksman;
float start_add_flashbangs_playerclass_marksman;
float start_add_smokenades_playerclass_marksman;
float start_add_fragnades_playerclass_marksman;
float start_add_atmines_playerclass_marksman;
float start_add_landmines_playerclass_marksman;
float start_add_inv_potion_health_small_marksman;
float start_add_inv_potion_health_medium_marksman;
float start_add_inv_potion_health_large_marksman;
float start_add_inv_potion_mana_small_marksman;
float start_add_inv_potion_mana_medium_marksman;
float start_add_inv_potion_mana_large_marksman;
float start_add_inv_potion_rejuv_small_marksman;
float start_add_inv_potion_rejuv_medium_marksman;
float start_add_inv_potion_rejuv_large_marksman;

float start_add_ammo_shells_playerclass_mediumdistance;
float start_add_ammo_nails_playerclass_mediumdistance;
float start_add_ammo_rockets_playerclass_mediumdistance;
float start_add_ammo_cells_playerclass_mediumdistance;
float start_add_ammo_fuel_playerclass_mediumdistance;
float start_add_health_playerclass_mediumdistance;
float start_add_armorvalue_playerclass_mediumdistance;
float start_add_mana_playerclass_mediumdistance;
float start_add_grenades_playerclass_mediumdistance;
float start_add_flashbangs_playerclass_mediumdistance;
float start_add_smokenades_playerclass_mediumdistance;
float start_add_fragnades_playerclass_mediumdistance;
float start_add_atmines_playerclass_mediumdistance;
float start_add_landmines_playerclass_mediumdistance;
float start_add_inv_potion_health_small_mediumdistance;
float start_add_inv_potion_health_medium_mediumdistance;
float start_add_inv_potion_health_large_mediumdistance;
float start_add_inv_potion_mana_small_mediumdistance;
float start_add_inv_potion_mana_medium_mediumdistance;
float start_add_inv_potion_mana_large_mediumdistance;
float start_add_inv_potion_rejuv_small_mediumdistance;
float start_add_inv_potion_rejuv_medium_mediumdistance;
float start_add_inv_potion_rejuv_large_mediumdistance;

float start_add_ammo_shells_playerclass_assault;
float start_add_ammo_nails_playerclass_assault;
float start_add_ammo_rockets_playerclass_assault;
float start_add_ammo_cells_playerclass_assault;
float start_add_ammo_fuel_playerclass_assault;
float start_add_health_playerclass_assault;
float start_add_armorvalue_playerclass_assault;
float start_add_mana_playerclass_assault;
float start_add_grenades_playerclass_assault;
float start_add_flashbangs_playerclass_assault;
float start_add_smokenades_playerclass_assault;
float start_add_fragnades_playerclass_assault;
float start_add_atmines_playerclass_assault;
float start_add_landmines_playerclass_assault;
float start_add_inv_potion_health_small_assault;
float start_add_inv_potion_health_medium_assault;
float start_add_inv_potion_health_large_assault;
float start_add_inv_potion_mana_small_assault;
float start_add_inv_potion_mana_medium_assault;
float start_add_inv_potion_mana_large_assault;
float start_add_inv_potion_rejuv_small_assault;
float start_add_inv_potion_rejuv_medium_assault;
float start_add_inv_potion_rejuv_large_assault;

float start_add_ammo_shells_playerclass_closerange;
float start_add_ammo_nails_playerclass_closerange;
float start_add_ammo_rockets_playerclass_closerange;
float start_add_ammo_cells_playerclass_closerange;
float start_add_ammo_fuel_playerclass_closerange;
float start_add_health_playerclass_closerange;
float start_add_armorvalue_playerclass_closerange;
float start_add_mana_playerclass_closerange;
float start_add_grenades_playerclass_closerange;
float start_add_flashbangs_playerclass_closerange;
float start_add_smokenades_playerclass_closerange;
float start_add_fragnades_playerclass_closerange;
float start_add_atmines_playerclass_closerange;
float start_add_landmines_playerclass_closerange;
float start_add_inv_potion_health_small_closerange;
float start_add_inv_potion_health_medium_closerange;
float start_add_inv_potion_health_large_closerange;
float start_add_inv_potion_mana_small_closerange;
float start_add_inv_potion_mana_medium_closerange;
float start_add_inv_potion_mana_large_closerange;
float start_add_inv_potion_rejuv_small_closerange;
float start_add_inv_potion_rejuv_medium_closerange;
float start_add_inv_potion_rejuv_large_closerange;

float start_add_ammo_shells_playerclass_destructive;
float start_add_ammo_nails_playerclass_destructive;
float start_add_ammo_rockets_playerclass_destructive;
float start_add_ammo_cells_playerclass_destructive;
float start_add_ammo_fuel_playerclass_destructive;
float start_add_health_playerclass_destructive;
float start_add_armorvalue_playerclass_destructive;
float start_add_mana_playerclass_destructive;
float start_add_grenades_playerclass_destructive;
float start_add_flashbangs_playerclass_destructive;
float start_add_smokenades_playerclass_destructive;
float start_add_fragnades_playerclass_destructive;
float start_add_atmines_playerclass_destructive;
float start_add_landmines_playerclass_destructive;
float start_add_inv_potion_health_small_destructive;
float start_add_inv_potion_health_medium_destructive;
float start_add_inv_potion_health_large_destructive;
float start_add_inv_potion_mana_small_destructive;
float start_add_inv_potion_mana_medium_destructive;
float start_add_inv_potion_mana_large_destructive;
float start_add_inv_potion_rejuv_small_destructive;
float start_add_inv_potion_rejuv_medium_destructive;
float start_add_inv_potion_rejuv_large_destructive;

float start_add_ammo_shells_playerclass_heavyweapons;
float start_add_ammo_nails_playerclass_heavyweapons;
float start_add_ammo_rockets_playerclass_heavyweapons;
float start_add_ammo_cells_playerclass_heavyweapons;
float start_add_ammo_fuel_playerclass_heavyweapons;
float start_add_health_playerclass_heavyweapons;
float start_add_armorvalue_playerclass_heavyweapons;
float start_add_mana_playerclass_heavyweapons;
float start_add_grenades_playerclass_heavyweapons;
float start_add_flashbangs_playerclass_heavyweapons;
float start_add_smokenades_playerclass_heavyweapons;
float start_add_fragnades_playerclass_heavyweapons;
float start_add_atmines_playerclass_heavyweapons;
float start_add_landmines_playerclass_heavyweapons;
float start_add_inv_potion_health_small_heavyweapons;
float start_add_inv_potion_health_medium_heavyweapons;
float start_add_inv_potion_health_large_heavyweapons;
float start_add_inv_potion_mana_small_heavyweapons;
float start_add_inv_potion_mana_medium_heavyweapons;
float start_add_inv_potion_mana_large_heavyweapons;
float start_add_inv_potion_rejuv_small_heavyweapons;
float start_add_inv_potion_rejuv_medium_heavyweapons;
float start_add_inv_potion_rejuv_large_heavyweapons;

float start_add_ammo_shells_playerclass_pyromaniac;
float start_add_ammo_nails_playerclass_pyromaniac;
float start_add_ammo_rockets_playerclass_pyromaniac;
float start_add_ammo_cells_playerclass_pyromaniac;
float start_add_ammo_fuel_playerclass_pyromaniac;
float start_add_health_playerclass_pyromaniac;
float start_add_armorvalue_playerclass_pyromaniac;
float start_add_mana_playerclass_pyromaniac;
float start_add_grenades_playerclass_pyromaniac;
float start_add_flashbangs_playerclass_pyromaniac;
float start_add_smokenades_playerclass_pyromaniac;
float start_add_fragnades_playerclass_pyromaniac;
float start_add_atmines_playerclass_pyromaniac;
float start_add_landmines_playerclass_pyromaniac;
float start_add_inv_potion_health_small_pyromaniac;
float start_add_inv_potion_health_medium_pyromaniac;
float start_add_inv_potion_health_large_pyromaniac;
float start_add_inv_potion_mana_small_pyromaniac;
float start_add_inv_potion_mana_medium_pyromaniac;
float start_add_inv_potion_mana_large_pyromaniac;
float start_add_inv_potion_rejuv_small_pyromaniac;
float start_add_inv_potion_rejuv_medium_pyromaniac;
float start_add_inv_potion_rejuv_large_pyromaniac;

float start_add_ammo_shells_playerclass_engineer;
float start_add_ammo_nails_playerclass_engineer;
float start_add_ammo_rockets_playerclass_engineer;
float start_add_ammo_cells_playerclass_engineer;
float start_add_ammo_fuel_playerclass_engineer;
float start_add_health_playerclass_engineer;
float start_add_armorvalue_playerclass_engineer;
float start_add_mana_playerclass_engineer;
float start_add_grenades_playerclass_engineer;
float start_add_flashbangs_playerclass_engineer;
float start_add_smokenades_playerclass_engineer;
float start_add_fragnades_playerclass_engineer;
float start_add_atmines_playerclass_engineer;
float start_add_landmines_playerclass_engineer;
float start_add_inv_potion_health_small_engineer;
float start_add_inv_potion_health_medium_engineer;
float start_add_inv_potion_health_large_engineer;
float start_add_inv_potion_mana_small_engineer;
float start_add_inv_potion_mana_medium_engineer;
float start_add_inv_potion_mana_large_engineer;
float start_add_inv_potion_rejuv_small_engineer;
float start_add_inv_potion_rejuv_medium_engineer;
float start_add_inv_potion_rejuv_large_engineer;

float start_add_ammo_shells_playerclass_worker;
float start_add_ammo_nails_playerclass_worker;
float start_add_ammo_rockets_playerclass_worker;
float start_add_ammo_cells_playerclass_worker;
float start_add_ammo_fuel_playerclass_worker;
float start_add_health_playerclass_worker;
float start_add_armorvalue_playerclass_worker;
float start_add_mana_playerclass_worker;
float start_add_grenades_playerclass_worker;
float start_add_flashbangs_playerclass_worker;
float start_add_smokenades_playerclass_worker;
float start_add_fragnades_playerclass_worker;
float start_add_atmines_playerclass_worker;
float start_add_landmines_playerclass_worker;
float start_add_inv_potion_health_small_worker;
float start_add_inv_potion_health_medium_worker;
float start_add_inv_potion_health_large_worker;
float start_add_inv_potion_mana_small_worker;
float start_add_inv_potion_mana_medium_worker;
float start_add_inv_potion_mana_large_worker;
float start_add_inv_potion_rejuv_small_worker;
float start_add_inv_potion_rejuv_medium_worker;
float start_add_inv_potion_rejuv_large_worker;

float start_add_ammo_shells_playerclass_healer;
float start_add_ammo_nails_playerclass_healer;
float start_add_ammo_rockets_playerclass_healer;
float start_add_ammo_cells_playerclass_healer;
float start_add_ammo_fuel_playerclass_healer;
float start_add_health_playerclass_healer;
float start_add_armorvalue_playerclass_healer;
float start_add_mana_playerclass_healer;
float start_add_grenades_playerclass_healer;
float start_add_flashbangs_playerclass_healer;
float start_add_smokenades_playerclass_healer;
float start_add_fragnades_playerclass_healer;
float start_add_atmines_playerclass_healer;
float start_add_landmines_playerclass_healer;
float start_add_inv_potion_health_small_healer;
float start_add_inv_potion_health_medium_healer;
float start_add_inv_potion_health_large_healer;
float start_add_inv_potion_mana_small_healer;
float start_add_inv_potion_mana_medium_healer;
float start_add_inv_potion_mana_large_healer;
float start_add_inv_potion_rejuv_small_healer;
float start_add_inv_potion_rejuv_medium_healer;
float start_add_inv_potion_rejuv_large_healer;
//end for playerclasses

WEPSET_DECLARE_A(start_weapons);
WEPSET_DECLARE_A(start_weapons_default);
WEPSET_DECLARE_A(start_weapons_defaultmask);
float start_items;
float start_ammo_shells;
float start_ammo_nails;
float start_ammo_rockets;
float start_ammo_cells;
float start_ammo_fuel;
float start_health;
float start_armorvalue;
float start_mana;
float start_grenades;
float start_grenades_team1;
float start_grenades_team2;
float start_grenades_team3;
float start_grenades_team4;
float start_flashbangs;
float start_flashbangs_team1;
float start_flashbangs_team2;
float start_flashbangs_team3;
float start_flashbangs_team4;
float start_smokenades;
float start_smokenades_team1;
float start_smokenades_team2;
float start_smokenades_team3;
float start_smokenades_team4;
float start_fragnades;
float start_fragnades_team1;
float start_fragnades_team2;
float start_fragnades_team3;
float start_fragnades_team4;
float start_atmines;
float start_atmines_team1;
float start_atmines_team2;
float start_atmines_team3;
float start_atmines_team4;
float start_landmines;
float start_landmines_team1;
float start_landmines_team2;
float start_landmines_team3;
float start_landmines_team4;
WEPSET_DECLARE_A(warmup_start_weapons);
WEPSET_DECLARE_A(warmup_start_weapons_default);
WEPSET_DECLARE_A(warmup_start_weapons_defaultmask);
float warmup_start_ammo_shells;
float warmup_start_ammo_nails;
float warmup_start_ammo_rockets;
float warmup_start_ammo_cells;
float warmup_start_ammo_fuel;
float warmup_start_health;
float warmup_start_armorvalue;
float warmup_start_mana;
float warmup_start_grenades;
float warmup_start_flashbangs;
float warmup_start_smokenades;
float warmup_start_fragnades;
float warmup_start_atmines;
float warmup_start_landmines;
float g_weapon_stay;

entity get_weaponinfo(float w);

float want_weapon(string cvarprefix, entity weaponinfo, float allguns)
{
	var float i = weaponinfo.weapon;
	var float d = 0;

	if (!i)
		return 0;

	if (g_lms || g_ca || allguns)
	{
		if(weaponinfo.spawnflags & WEP_FLAG_NORMAL)
			d = TRUE;
		else
			d = FALSE;
	}
	else if (g_cts) {
		if (autocvar_g_defaultstartweaponset == 1) d = (i == WEP_PISTOL);
		else d = (i == WEP_SHOTGUN);
	} else if (g_nexball) {
		d = 0; // weapon is set a few lines later
	} else {
		local float donotgivedefaultset;
		donotgivedefaultset = 0;
		
		if (teamplay)
		{
			if (cvar("g_start_weapon_teamoverrides") == 1) {
				donotgivedefaultset = 1;
				//Fix for "bug" where pistol shows up in CTF etc even when disabled othrwise in both DM and team
				//If team overrides are enabled, then do not give the default weapon set
			} else if (autocvar_g_defaultstartweaponset == 1) {
				if (cvar("g_start_weapon_pistol") == 0) {
					donotgivedefaultset = 1;
				}
			}
		}
		
		
		if (!donotgivedefaultset) {
			if (autocvar_g_defaultstartweaponset == 1) d = (i == WEP_PISTOL);
			else d = (i == WEP_LASER || i == WEP_SHOTGUN);
		}
	}
		
	if(g_grappling_hook) // if possible, redirect off-hand hook to on-hand hook
		d |= (i == WEP_HOOK);
	if(weaponinfo.spawnflags & WEP_FLAG_MUTATORBLOCKED) // never default mutator blocked guns
		d = 0;

	var float t = cvar(strcat(cvarprefix, weaponinfo.netname));
	
	//print(strcat("want_weapon: ", weaponinfo.netname, " - d: ", ftos(d), ", t: ", ftos(t), ". \n"));
	
	// bit order in t:
	// 1: want or not
	// 2: is default?
	// 4: is set by default?
	if(t < 0)
		t = 4 | (3 * d);
	else
		t |= (2 * d);

	return t;
}

float weaponisinsomegunsweaponset (float i)
{
	local float d;
	d = FALSE;
	
	if (autocvar_g_defaultstartsomegunsweaponset) {
			local float mywpnstslctn;

			if (autocvar_g_defaultstartsomegunsweaponset_fllw_wpn_pkups) {
				//So as not to break theme
				if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_WWIWPNS)
				{
					mywpnstslctn = 7;
				}
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_OLDWESTWPNS)
				{
					mywpnstslctn = 8;
				}
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MODGUNCIVILWPNS)
				{
					mywpnstslctn = 6; //Pistols only...
				}
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_GUNXPLSVENRGYWPNS)
				{
					mywpnstslctn = 5;
				}
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_STDXONWPNS)
				{
					mywpnstslctn = 1;
				}
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_SCROLLS)
				{
					mywpnstslctn = 10000; //Fallback to medeval
				} 
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS)
				{
					mywpnstslctn = 10000; //Fallback to medeval
				} 
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS)
				{
					mywpnstslctn = 10000; //Fallback to medeval
				} else {
					mywpnstslctn = autocvar_g_defaultstartsomegunsweaponset;
				}
			} else {
				mywpnstslctn = autocvar_g_defaultstartsomegunsweaponset;
			}
			
			if (mywpnstslctn == 1) {
				//Old Xon
				switch(i)
				{	
					case WEP_LASER:
					case WEP_GRENADE_LAUNCHER:
					case WEP_ROCKET_LAUNCHER:
					case WEP_SHOTGUN:
					case WEP_CRYLINK:
					case WEP_ELECTRO:
					case WEP_NEX:
					case WEP_HAGAR:
					case WEP_CARBINE:
					case WEP_LRR:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 2) {
				//Early CEA
				switch(i)
				{	
					case WEP_LASER:
					case WEP_PISTOL:
					case WEP_GRENADE_LAUNCHER:
					case WEP_ROCKET_LAUNCHER:
					case WEP_SHOTGUN:
					case WEP_CRYLINK:
					case WEP_ELECTRO:
					case WEP_NEX:
					case WEP_HAGAR:
					case WEP_UZI:
					case WEP_RIFLE:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 3) {
				//Nu Xon
				switch(i)
				{	
					case WEP_LASER:
					case WEP_GRENADE_LAUNCHER:
					case WEP_DEVASTATOR:
					case WEP_LIGHTNINGGUN:
					case WEP_CRYLINK:
					case WEP_ELECTRO:
					case WEP_NEX:
					case WEP_HAGAR2:
					case WEP_CARBINE:
					case WEP_RIFLE:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 4) {
				//More
				switch(i)
				{	
					case WEP_LASER:
					case WEP_GRENADE_LAUNCHER:
					case WEP_ROCKET_LAUNCHER:
					case WEP_SHOTGUN:
					case WEP_CRYLINK:
					case WEP_ELECTRO:
					case WEP_NEX:
					case WEP_HAGAR:
					case WEP_CARBINE:
					case WEP_RIFLE:
					case WEP_PISTOL:
					case WEP_CRYPISTOL:
					case WEP_CRYLANCER:
					case WEP_STARBLAST:
					case WEP_SUNBURST:
					case WEP_SUNBOLT:
					case WEP_STARLASE:
					case WEP_DEVASTATOR:
					case WEP_HAGAR2:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 5) {
				//More but T style
				print("here2\n");
				switch(i)
				{	
					case WEP_LASER:
					case WEP_GRENADE_LAUNCHER:
					case WEP_ROCKET_LAUNCHER:
					case WEP_SHOTGUN:
					case WEP_LIGHTNINGGUN:
					case WEP_CRYLINK:
					case WEP_ELECTRO:
					case WEP_NEX:
					case WEP_HAGAR:
					case WEP_MINIUZI:
					case WEP_RIFLE:
					case WEP_LONGPISTOL:
					case WEP_CRYPISTOL:
					case WEP_CRYLANCER:
					case WEP_STARBLAST:
					case WEP_SUNBURST:
					case WEP_SUNBOLT:
					case WEP_STARLASE:
					case WEP_DEVASTATOR:
					case WEP_HAGAR2:
					case WEP_AMR18:
					case WEP_SPAS12:
					case WEP_TEC9:
					case WEP_PUMPSHOTGUN:
					case WEP_HMG:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 6) {
				//Pistols only
				switch(i)
				{	
					case WEP_BIGPISTOL:
					case WEP_LARGEPISTOL:
					case WEP_LONGPISTOL:
					case WEP_M9PISTOL:
					case WEP_MAUSERPISTOL:
					case WEP_PISTOL:
					case WEP_TT33PISTOL:
					case WEP_FFMAGNUM:
					case WEP_MAGNUM:
					case WEP_REVOLVER:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 7) {
				//WWI (Note: Tommygun was designed for WWI)
				switch(i)
				{	
					case WEP_MG0815:
					case WEP_LEWISMG:
					case WEP_NAGANT1895:
					case WEP_BAR1918:
					case WEP_CHAUCHAT:
					case WEP_WEBLEYLONG:
					case WEP_HELLRIEGELSMG:
					case WEP_M1903:
					case WEP_G98:
					case WEP_MOSIN:
					case WEP_MAUSERPISTOL:
					case WEP_BIGPISTOL:
					case WEP_MACHINEPISTOL:
					case WEP_M1897TRENCHGUN:
					case WEP_M1921:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else if (mywpnstslctn == 8) {
				//Old West only
				switch(i)
				{	
					case WEP_MUSKET:
					case WEP_REVOLVER:
					case WEP_PEPPERBOXREVOLVER:
					case WEP_NAVY1851REVOLVER:
					case WEP_COLT44REVOLVER:
					case WEP_SCHOFIELDREVOLVER:
					case WEP_HENRY1860RIFLE:
					case WEP_HENRY1860MARESLEG:
					case WEP_R1856REVOLVER:
					case WEP_WINCHESTER1873RIFLE:
					case WEP_WINCHESTER1897:
					case WEP_EIGHTGAUGESHOTGUN:
					case WEP_EIGHTGAUGESAWEDOFF:
					case WEP_TENGAUGEDOUBLE:
					case WEP_TENGAUGESAWEDOFF:
					case WEP_BOWIEKNIFE:
					case WEP_ARKANSASTOOTHPICK:
					case WEP_COLTLIGHTNING:
					case WEP_SHARPSRIFLE:
					case WEP_FLINTLOCKPISTOL:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			} else {
				//Some medieval
				switch(i)
				{	
					case WEP_WARHAMMERSPIKED:
					case WEP_CROSSBOWDTWR:
					case WEP_LIGHTCROSSBOW:
					case WEP_BROADAXE:
					case WEP_SHORTSWORD:
					case WEP_LONGSWORD:
					case WEP_LONGBOW:
					case WEP_CRUDEBOW:
					case WEP_COMPOSITEBOW:
					case WEP_SPIKEDCLUB:
					case WEP_QUARTERSTAFF:
					case WEP_ARMINGSWORD:
					case WEP_RAPIER:
					case WEP_MORGENSTERN:
					case WEP_SPIKEDFLAIL:
					case WEP_SHOOTINGSTAR:
					case WEP_CUDGEL:
					case WEP_SHININGSTAR:
					case WEP_FLANGEDMACE:
					case WEP_DAGGER:
					case WEP_IRONKNIFE:
						d = TRUE;
						break;
					default:
						d = FALSE;
						break;
				}
			}
	} else {
		d = TRUE;
	}
	
	return d;
}


float GiveItems(entity e, float beginarg, float endarg);
//Give items, playerclasses
float giveitemsfromcvar_playerclass(entity playerentity, float plyrclss, float pclassset) {
	local float myreturn = 0;
	if (pclassset == PLAYERCLASSSET_DEFAULT) {
		//default
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_longdistance_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_longdistance_default));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_start_add_giveitems_playerclass_marksman_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_marksman_default));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_mediumdistance_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_mediumdistance_default));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_start_add_giveitems_playerclass_assault_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_assault_default));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_start_add_giveitems_playerclass_closerange_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_closerange_default));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_start_add_giveitems_playerclass_destructive_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_destructive_default));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_start_add_giveitems_playerclass_heavyweapons_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_heavyweapons_default));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_start_add_giveitems_playerclass_pyromaniac_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_pyromaniac_default));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_start_add_giveitems_playerclass_engineer_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_engineer_default));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_start_add_giveitems_playerclass_worker_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_worker_default));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_start_add_giveitems_playerclass_healer_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_healer_default));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_MEDIEVALFANTASY) {
		//medievalfantasy
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_longdistance_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_longdistance_medievalfantasy));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_start_add_giveitems_playerclass_marksman_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_marksman_medievalfantasy));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_mediumdistance_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_mediumdistance_medievalfantasy));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_start_add_giveitems_playerclass_assault_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_assault_medievalfantasy));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_start_add_giveitems_playerclass_closerange_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_closerange_medievalfantasy));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_start_add_giveitems_playerclass_destructive_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_destructive_medievalfantasy));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_start_add_giveitems_playerclass_heavyweapons_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_heavyweapons_medievalfantasy));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_start_add_giveitems_playerclass_pyromaniac_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_pyromaniac_medievalfantasy));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_start_add_giveitems_playerclass_engineer_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_engineer_medievalfantasy));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_start_add_giveitems_playerclass_worker_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_worker_medievalfantasy));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_start_add_giveitems_playerclass_healer_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_healer_medievalfantasy));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_OLDWEST) {
		//oldwest
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_longdistance_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_longdistance_oldwest));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_start_add_giveitems_playerclass_marksman_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_marksman_oldwest));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_mediumdistance_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_mediumdistance_oldwest));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_start_add_giveitems_playerclass_assault_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_assault_oldwest));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_start_add_giveitems_playerclass_closerange_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_closerange_oldwest));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_start_add_giveitems_playerclass_destructive_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_destructive_oldwest));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_start_add_giveitems_playerclass_heavyweapons_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_heavyweapons_oldwest));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_start_add_giveitems_playerclass_pyromaniac_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_pyromaniac_oldwest));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_start_add_giveitems_playerclass_engineer_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_engineer_oldwest));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_start_add_giveitems_playerclass_worker_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_worker_oldwest));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_start_add_giveitems_playerclass_healer_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_healer_oldwest));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_XON) {
		//xon
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_longdistance_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_longdistance_xon));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_start_add_giveitems_playerclass_marksman_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_marksman_xon));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_mediumdistance_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_mediumdistance_xon));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_start_add_giveitems_playerclass_assault_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_assault_xon));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_start_add_giveitems_playerclass_closerange_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_closerange_xon));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_start_add_giveitems_playerclass_destructive_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_destructive_xon));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_start_add_giveitems_playerclass_heavyweapons_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_heavyweapons_xon));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_start_add_giveitems_playerclass_pyromaniac_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_pyromaniac_xon));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_start_add_giveitems_playerclass_engineer_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_engineer_xon));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_start_add_giveitems_playerclass_worker_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_worker_xon));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_start_add_giveitems_playerclass_healer_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_healer_xon));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_WWI) {
		//wwi
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_longdistance_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_longdistance_wwi));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_start_add_giveitems_playerclass_marksman_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_marksman_wwi));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_start_add_giveitems_playerclass_mediumdistance_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_mediumdistance_wwi));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_start_add_giveitems_playerclass_assault_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_assault_wwi));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_start_add_giveitems_playerclass_closerange_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_closerange_wwi));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_start_add_giveitems_playerclass_destructive_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_destructive_wwi));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_start_add_giveitems_playerclass_heavyweapons_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_heavyweapons_wwi));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_start_add_giveitems_playerclass_pyromaniac_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_pyromaniac_wwi));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_start_add_giveitems_playerclass_engineer_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_engineer_wwi));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_start_add_giveitems_playerclass_worker_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_worker_wwi));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_start_add_giveitems_playerclass_healer_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_start_add_giveitems_playerclass_healer_wwi));
			} break;
		default:
			//Do nothing
			break;
		}
		
	}
	
	return myreturn;
	
}
//at end execute these give lines, perhaps to take away what was given if or when player switches classes
float atend_giveitemsfromcvar_playerclass(entity playerentity, float plyrclss, float pclassset) {
	local float myreturn = 0;
	if (pclassset == PLAYERCLASSSET_DEFAULT) {
		//default
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_longdistance_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_longdistance_default));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_end_add_giveitems_playerclass_marksman_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_marksman_default));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_mediumdistance_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_mediumdistance_default));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_end_add_giveitems_playerclass_assault_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_assault_default));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_end_add_giveitems_playerclass_closerange_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_closerange_default));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_end_add_giveitems_playerclass_destructive_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_destructive_default));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_end_add_giveitems_playerclass_heavyweapons_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_heavyweapons_default));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_end_add_giveitems_playerclass_pyromaniac_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_pyromaniac_default));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_end_add_giveitems_playerclass_engineer_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_engineer_default));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_end_add_giveitems_playerclass_worker_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_worker_default));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_end_add_giveitems_playerclass_healer_default != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_healer_default));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_MEDIEVALFANTASY) {
		//medievalfantasy
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_longdistance_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_longdistance_medievalfantasy));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_end_add_giveitems_playerclass_marksman_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_marksman_medievalfantasy));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_mediumdistance_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_mediumdistance_medievalfantasy));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_end_add_giveitems_playerclass_assault_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_assault_medievalfantasy));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_end_add_giveitems_playerclass_closerange_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_closerange_medievalfantasy));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_end_add_giveitems_playerclass_destructive_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_destructive_medievalfantasy));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_end_add_giveitems_playerclass_heavyweapons_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_heavyweapons_medievalfantasy));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_end_add_giveitems_playerclass_pyromaniac_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_pyromaniac_medievalfantasy));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_end_add_giveitems_playerclass_engineer_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_engineer_medievalfantasy));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_end_add_giveitems_playerclass_worker_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_worker_medievalfantasy));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_end_add_giveitems_playerclass_healer_medievalfantasy != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_healer_medievalfantasy));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_OLDWEST) {
		//oldwest
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_longdistance_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_longdistance_oldwest));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_end_add_giveitems_playerclass_marksman_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_marksman_oldwest));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_mediumdistance_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_mediumdistance_oldwest));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_end_add_giveitems_playerclass_assault_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_assault_oldwest));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_end_add_giveitems_playerclass_closerange_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_closerange_oldwest));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_end_add_giveitems_playerclass_destructive_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_destructive_oldwest));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_end_add_giveitems_playerclass_heavyweapons_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_heavyweapons_oldwest));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_end_add_giveitems_playerclass_pyromaniac_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_pyromaniac_oldwest));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_end_add_giveitems_playerclass_engineer_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_engineer_oldwest));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_end_add_giveitems_playerclass_worker_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_worker_oldwest));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_end_add_giveitems_playerclass_healer_oldwest != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_healer_oldwest));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_XON) {
		//xon
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_longdistance_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_longdistance_xon));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_end_add_giveitems_playerclass_marksman_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_marksman_xon));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_mediumdistance_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_mediumdistance_xon));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_end_add_giveitems_playerclass_assault_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_assault_xon));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_end_add_giveitems_playerclass_closerange_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_closerange_xon));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_end_add_giveitems_playerclass_destructive_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_destructive_xon));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_end_add_giveitems_playerclass_heavyweapons_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_heavyweapons_xon));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_end_add_giveitems_playerclass_pyromaniac_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_pyromaniac_xon));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_end_add_giveitems_playerclass_engineer_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_engineer_xon));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_end_add_giveitems_playerclass_worker_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_worker_xon));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_end_add_giveitems_playerclass_healer_xon != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_healer_xon));
			} break;
		default:
			//Do nothing
			break;
		}
		
	} else if (pclassset == PLAYERCLASSSET_WWI) {
		//wwi
		switch (plyrclss)
		{
		case PLAYERCLASS_LONGDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_longdistance_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_longdistance_wwi));
			} break;
		case PLAYERCLASS_MARKSMAN:
			if (autocvar_g_end_add_giveitems_playerclass_marksman_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_marksman_wwi));
			} break;
		case PLAYERCLASS_MEDIUMDISTANCE:
			if (autocvar_g_end_add_giveitems_playerclass_mediumdistance_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_mediumdistance_wwi));
			} break;
		case PLAYERCLASS_ASSAULT:
			if (autocvar_g_end_add_giveitems_playerclass_assault_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_assault_wwi));
			} break;
		case PLAYERCLASS_CLOSERANGE:
			if (autocvar_g_end_add_giveitems_playerclass_closerange_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_closerange_wwi));
			} break;
		case PLAYERCLASS_DESTRUCTIVE:
			if (autocvar_g_end_add_giveitems_playerclass_destructive_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_destructive_wwi));
			} break;
		case PLAYERCLASS_HEAVYWEAPONS:
			if (autocvar_g_end_add_giveitems_playerclass_heavyweapons_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_heavyweapons_wwi));
			} break;
		case PLAYERCLASS_PYROMANIAC:
			if (autocvar_g_end_add_giveitems_playerclass_pyromaniac_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_pyromaniac_wwi));
			} break;
		case PLAYERCLASS_ENGINEER:
			if (autocvar_g_end_add_giveitems_playerclass_engineer_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_engineer_wwi));
			} break;
		case PLAYERCLASS_WORKER:
			if (autocvar_g_end_add_giveitems_playerclass_worker_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_worker_wwi));
			} break;
		case PLAYERCLASS_HEALER:
			if (autocvar_g_end_add_giveitems_playerclass_healer_wwi != "") {
			myreturn = GiveItems(playerentity, 0, tokenize_console(autocvar_g_end_add_giveitems_playerclass_healer_wwi));
			} break;
		default:
			//Do nothing
			break;
		}
		
	}
	
	return myreturn;
	
}

void execute_atend_giveitemsfromcvar_playerclass (entity myplayer, float plyrclss, float pclassset)
{
				if (myplayer.playerclass == PLAYERCLASS_LONGDISTANCE) {
			  		if (autocvar_g_playerclass_enable_longdistance) {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_MARKSMAN) {
			  		if (autocvar_g_playerclass_enable_marksman)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_MEDIUMDISTANCE) {
			  		if (autocvar_g_playerclass_enable_mediumdistance)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
			  	} else if (myplayer.playerclass == PLAYERCLASS_ASSAULT) {
			  		if (autocvar_g_playerclass_enable_assault)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_CLOSERANGE) {
			  		if (autocvar_g_playerclass_enable_closerange) { 
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_DESTRUCTIVE) {
			  		if (autocvar_g_playerclass_enable_destructive)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_HEAVYWEAPONS) {
			  		if (autocvar_g_playerclass_enable_heavyweapons) { 
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_PYROMANIAC) {
			  		if (autocvar_g_playerclass_enable_pyromaniac)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_ENGINEER) {
			  		if (autocvar_g_playerclass_enable_engineer)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_WORKER) {
			  		if (autocvar_g_playerclass_enable_worker)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				} else if (myplayer.playerclass == PLAYERCLASS_HEALER) {
			  		if (autocvar_g_playerclass_enable_healer)  {
						  atend_giveitemsfromcvar_playerclass(myplayer, myplayer.playerclass, playerclassset);
					}
				}
}

//player classes
void wepsetfromcvar_playerclass_longdistance(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_longdistance, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_marksman(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_marksman, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_mediumdistance(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_mediumdistance, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_assault(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_assault, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_closerange(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_closerange, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_destructive(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_destructive, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_heavyweapons(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_heavyweapons, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_pyromaniac(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_pyromaniac, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_engineer(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_engineer, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_worker(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_worker, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
void wepsetfromcvar_playerclass_healer(string mycvarstringweaponlist)
{
	entity e;
	float i, j, t;
	string s;
	
	s = cvar_string(mycvarstringweaponlist);
	if (s == "0" || s == "")
	{
		// no weapons
	} else {
		t = tokenize_console(s);
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(start_weapons_playerclass_healer, j);
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The playerclass weapon list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
	}
}
//end player classes

void readplayerstartcvars()
{
	entity e;
	float i, j, t;
	string s;
	
	float teamoverrides;

	// initialize starting values for players
	WEPSET_CLEAR_A(start_weapons_team1); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_team2); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_team3); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_team4); //Chaos-esque addition
	if (cvar("g_playerclass")) { g_playerclass = 1; }
	WEPSET_CLEAR_A(start_weapons_playerclass_longdistance); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_marksman); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_mediumdistance); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_assault); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_closerange); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_destructive); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_heavyweapons); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_pyromaniac); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_engineer); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_worker); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons_playerclass_healer); //Chaos-esque addition
	WEPSET_CLEAR_A(start_weapons);
	WEPSET_CLEAR_A(start_weapons_default);
	WEPSET_CLEAR_A(start_weapons_defaultmask);
	start_items = 0;
	start_ammo_shells = 0;
	start_ammo_nails = 0;
	start_ammo_rockets = 0;
	start_ammo_cells = 0;
	start_grenades = cvar("g_start_grenades");
	start_grenades_team1 = cvar("g_start_grenades_team1");
	start_grenades_team2 = cvar("g_start_grenades_team2");
	start_grenades_team3 = cvar("g_start_grenades_team3");
	start_grenades_team4 = cvar("g_start_grenades_team4");
	start_flashbangs = cvar("g_start_flashbangs");
	start_flashbangs_team1 = cvar("g_start_flashbangs_team1");
	start_flashbangs_team2 = cvar("g_start_flashbangs_team2");
	start_flashbangs_team3 = cvar("g_start_flashbangs_team3");
	start_flashbangs_team4 = cvar("g_start_flashbangs_team4");
	start_smokenades = cvar("g_start_smokenades");
	start_smokenades_team1 = cvar("g_start_smokenades_team1");
	start_smokenades_team2 = cvar("g_start_smokenades_team2");
	start_smokenades_team3 = cvar("g_start_smokenades_team3");
	start_smokenades_team4 = cvar("g_start_smokenades_team4");
	start_fragnades = cvar("g_start_fragnades");
	start_fragnades_team1 = cvar("g_start_fragnades_team1");
	start_fragnades_team2 = cvar("g_start_fragnades_team2");
	start_fragnades_team3 = cvar("g_start_fragnades_team3");
	start_fragnades_team4 = cvar("g_start_fragnades_team4");
	start_atmines = cvar("g_start_atmines");
	start_atmines_team1 = cvar("g_start_atmines_team1");
	start_atmines_team2 = cvar("g_start_atmines_team2");
	start_atmines_team3 = cvar("g_start_atmines_team3");
	start_atmines_team4 = cvar("g_start_atmines_team4");
	start_landmines = cvar("g_start_landmines");
	start_landmines_team1 = cvar("g_start_landmines_team1");
	start_landmines_team2 = cvar("g_start_landmines_team2");
	start_landmines_team3 = cvar("g_start_landmines_team3");
	start_landmines_team4 = cvar("g_start_landmines_team4");
	start_health = cvar("g_balance_health_start");
	start_armorvalue = cvar("g_balance_armor_start");
	start_mana = cvar("g_balance_mana_start");
	teamoverrides = cvar("g_start_weapon_teamoverrides"); //Chaos-esque addition
	raiseundeadmarker_max = cvar("g_raiseundeadmarker_max");
	raiseundeadmarker_current = 0;
	if (cvar("g_start_spell_raiseundead")
	|| cvar("g_start_spell_team1_raiseundead")
	|| cvar("g_start_spell_team2_raiseundead")
	|| cvar("g_start_spell_team3_raiseundead")
	|| cvar("g_start_spell_team4_raiseundead"))
	{
		raiseundeadmarkerenabled = 1;	
	}

	g_weaponarena = 0;
	WEPSET_CLEAR_A(g_weaponarena_weapons);

	s = cvar_string("g_weaponarena");
	if (s == "0" || s == "")
	{
		if(g_lms || g_ca)
			s = "some";
	}

	if (s == "0" || s == "")
	{
		// no arena
	}
	else if (s == "off")
	{
		// forcibly turn off weaponarena
	}
	else if (s == "all")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "All Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if not(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
				WEPSET_OR_AW(g_weaponarena_weapons, j);
		}
	}
	else if (s == "most")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "Most Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if not(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
				if (e.spawnflags & WEP_FLAG_NORMAL)
					WEPSET_OR_AW(g_weaponarena_weapons, j);
		}
	}
	else if (s == "some")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "Some Weapons";
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if not(e.spawnflags & WEP_FLAG_MUTATORBLOCKED)
				if (e.spawnflags & WEP_FLAG_NORMAL)
					if (weaponisinsomegunsweaponset(e.weapon))
						WEPSET_OR_AW(g_weaponarena_weapons, j);
		}
	}
	else if (s == "none")
	{
		g_weaponarena = 1;
		g_weaponarena_list = "No Weapons";
	}
	else
	{
		g_weaponarena = 1;
		t = tokenize_console(s);
		g_weaponarena_list = "";
		for (i = 0; i < t; ++i)
		{
			s = argv(i);
			for (j = WEP_FIRST; j <= WEP_LAST; ++j)
			{
				e = get_weaponinfo(j);
				if (e.netname == s)
				{
					WEPSET_OR_AW(g_weaponarena_weapons, j);
					g_weaponarena_list = strcat(g_weaponarena_list, e.message, " & ");
					break;
				}
			}
			if (j > WEP_LAST)
			{
				print("The weapon mutator list contains an unknown weapon ", s, ". Skipped.\n");
			}
		}
		g_weaponarena_list = strzone(substring(g_weaponarena_list, 0, strlen(g_weaponarena_list) - 3));
	}

	if(g_weaponarena)
		g_weaponarena_random = cvar("g_weaponarena_random");
	else
		g_weaponarena_random = 0;
	g_weaponarena_random_with_laser = cvar("g_weaponarena_random_with_laser");

	if (g_weaponarena)
	{
		g_minstagib = 0; // incompatible
		g_pinata = 0; // incompatible
		g_weapon_stay = 0; // incompatible
		WEPSET_COPY_AA(start_weapons, g_weaponarena_weapons);
		if(!(g_lms || g_ca))
			start_items |= IT_UNLIMITED_AMMO;
	}
	else if (g_minstagib)
	{
		g_pinata = 0; // incompatible
		g_weapon_stay = 0; // incompatible
		g_bloodloss = 0; // incompatible
		start_health = 100;
		start_armorvalue = 0;
		start_mana = 0;
		WEPSET_COPY_AW(start_weapons, WEP_MINSTANEX);
		g_minstagib_invis_alpha = cvar("g_minstagib_invis_alpha");
		start_items |= IT_UNLIMITED_SUPERWEAPONS;

		if (g_minstagib_invis_alpha <= 0)
			g_minstagib_invis_alpha = -1;
	}
	else
	{
		for (i = WEP_FIRST; i <= WEP_LAST; ++i)
		{
			e = get_weaponinfo(i);
			float w = want_weapon("g_start_weapon_", e, FALSE);
			if(w & 1)
				WEPSET_OR_AW(start_weapons, i);
			if(w & 2)
				WEPSET_OR_AW(start_weapons_default, i);
			if(w & 4)
				WEPSET_OR_AW(start_weapons_defaultmask, i);
			//Chaos-esque addition
			if (teamplay && teamoverrides != 2)
			{
				local float x;
				if (teamoverrides == 1)
					x = 0;
				else
					x = w;
					
				w = want_weapon("g_start_weapon_team1_", e, FALSE);
				if(w & 1 || x & 1)
					WEPSET_OR_AW(start_weapons_team1, i);
					
				w = want_weapon("g_start_weapon_team2_", e, FALSE);
				if(w & 1 || x & 1)
					WEPSET_OR_AW(start_weapons_team2, i);
				
				w = want_weapon("g_start_weapon_team3_", e, FALSE);
				if(w & 1 || x & 1)
					WEPSET_OR_AW(start_weapons_team3, i);
					
				w = want_weapon("g_start_weapon_team4_", e, FALSE);
				if(w & 1 || x & 1)
					WEPSET_OR_AW(start_weapons_team4, i);
			}
			//End Chaos-esque addition
		}
		
		
		//Chaos-esque addition
		if (g_playerclass) {
			//Depend on weap replace set
			float mypcselection;
			mypcselection = PLAYERCLASSSET_DEFAULT;
			
			if (autocvar_g_playerclass_set) {
				mypcselection = autocvar_g_playerclass_set;
			}
			
			if (autocvar_g_playerclass_fllw_wpn_pkups) {
			  if (!(autocvar_g_playerclass_set_force)) {
				//So as not to break theme
				if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_WWIWPNS)
				{
					mypcselection = PLAYERCLASSSET_WWI;
				} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_STDXONWPNS)
				{
					mypcselection = PLAYERCLASSSET_XON;
				} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_OLDWESTWPNS)
				{
					mypcselection = PLAYERCLASSSET_OLDWEST;
				} else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_SCROLLS)
				{
					mypcselection = PLAYERCLASSSET_MEDIEVALFANTASY; //Fallback to medeval
				} 
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS)
				{
					mypcselection = PLAYERCLASSSET_MEDIEVALFANTASY; //Fallback to medeval
				} 
				else if (autocvar_g_replace_weapon_pickups == GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS)
				{
					mypcselection = PLAYERCLASSSET_MEDIEVALFANTASY; //Fallback to medeval
				} else {
					mypcselection = PLAYERCLASSSET_DEFAULT;
				}
			  }
			}
			
			if (mypcselection == PLAYERCLASSSET_DEFAULT) {
				playerclassset = mypcselection;
				wepsetfromcvar_playerclass_longdistance("g_playerclass_weapons_longdistance_default");
				wepsetfromcvar_playerclass_marksman("g_playerclass_weapons_marksman_default");
				wepsetfromcvar_playerclass_mediumdistance("g_playerclass_weapons_mediumdistance_default");
				wepsetfromcvar_playerclass_assault("g_playerclass_weapons_assault_default");
				wepsetfromcvar_playerclass_closerange("g_playerclass_weapons_closerange_default");
				wepsetfromcvar_playerclass_destructive("g_playerclass_weapons_destructive_default");
				wepsetfromcvar_playerclass_heavyweapons("g_playerclass_weapons_heavyweapons_default");
				wepsetfromcvar_playerclass_pyromaniac("g_playerclass_weapons_pyromaniac_default");
				wepsetfromcvar_playerclass_engineer("g_playerclass_weapons_engineer_default");
				wepsetfromcvar_playerclass_worker("g_playerclass_weapons_worker_default");
				wepsetfromcvar_playerclass_healer("g_playerclass_weapons_healer_default");
				
				//Ammo
				 start_add_ammo_shells_playerclass_longdistance = cvar("g_start_add_ammo_shells_playerclass_longdistance_default");
				 start_add_ammo_nails_playerclass_longdistance = cvar("g_start_add_ammo_nails_playerclass_longdistance_default");
				 start_add_ammo_rockets_playerclass_longdistance = cvar("g_start_add_ammo_rockets_playerclass_longdistance_default");
				 start_add_ammo_cells_playerclass_longdistance = cvar("g_start_add_ammo_cells_playerclass_longdistance_default");
				 start_add_ammo_fuel_playerclass_longdistance = cvar("g_start_add_ammo_fuel_playerclass_longdistance_default");
				 start_add_health_playerclass_longdistance = cvar("g_start_add_health_playerclass_longdistance_default");
				 start_add_armorvalue_playerclass_longdistance = cvar("g_start_add_armorvalue_playerclass_longdistance_default");
				 start_add_mana_playerclass_longdistance = cvar("g_start_add_mana_playerclass_longdistance_default");
				 start_add_grenades_playerclass_longdistance = cvar("g_start_add_grenades_playerclass_longdistance_default");
				 start_add_flashbangs_playerclass_longdistance = cvar("g_start_add_flashbangs_playerclass_longdistance_default");
				 start_add_smokenades_playerclass_longdistance = cvar("g_start_add_smokenades_playerclass_longdistance_default");
				 start_add_fragnades_playerclass_longdistance = cvar("g_start_add_fragnades_playerclass_longdistance_default");
				 start_add_atmines_playerclass_longdistance = cvar("g_start_add_atmines_playerclass_longdistance_default");
				 start_add_landmines_playerclass_longdistance = cvar("g_start_add_landmines_playerclass_longdistance_default");
				 start_add_inv_potion_health_small_longdistance = cvar("g_start_add_inv_potion_health_small_longdistance_default");
				 start_add_inv_potion_health_medium_longdistance = cvar("g_start_add_inv_potion_health_medium_longdistance_default");
				 start_add_inv_potion_health_large_longdistance = cvar("g_start_add_inv_potion_health_large_longdistance_default");
				 start_add_inv_potion_mana_small_longdistance = cvar("g_start_add_inv_potion_mana_small_longdistance_default");
				 start_add_inv_potion_mana_medium_longdistance = cvar("g_start_add_inv_potion_mana_medium_longdistance_default");
				 start_add_inv_potion_mana_large_longdistance = cvar("g_start_add_inv_potion_mana_large_longdistance_default");
				 start_add_inv_potion_rejuv_small_longdistance = cvar("g_start_add_inv_potion_rejuv_small_longdistance_default");
				 start_add_inv_potion_rejuv_medium_longdistance = cvar("g_start_add_inv_potion_rejuv_medium_longdistance_default");
				 start_add_inv_potion_rejuv_large_longdistance = cvar("g_start_add_inv_potion_rejuv_large_longdistance_default");


				 start_add_ammo_shells_playerclass_marksman = cvar("g_start_add_ammo_shells_playerclass_marksman_default");
				 start_add_ammo_nails_playerclass_marksman = cvar("g_start_add_ammo_nails_playerclass_marksman_default");
				 start_add_ammo_rockets_playerclass_marksman = cvar("g_start_add_ammo_rockets_playerclass_marksman_default");
				 start_add_ammo_cells_playerclass_marksman = cvar("g_start_add_ammo_cells_playerclass_marksman_default");
				 start_add_ammo_fuel_playerclass_marksman = cvar("g_start_add_ammo_fuel_playerclass_marksman_default");
				 start_add_health_playerclass_marksman = cvar("g_start_add_health_playerclass_marksman_default");
				 start_add_armorvalue_playerclass_marksman = cvar("g_start_add_armorvalue_playerclass_marksman_default");
				 start_add_mana_playerclass_marksman = cvar("g_start_add_mana_playerclass_marksman_default");
				 start_add_grenades_playerclass_marksman = cvar("g_start_add_grenades_playerclass_marksman_default");
				 start_add_flashbangs_playerclass_marksman = cvar("g_start_add_flashbangs_playerclass_marksman_default");
				 start_add_smokenades_playerclass_marksman = cvar("g_start_add_smokenades_playerclass_marksman_default");
				 start_add_fragnades_playerclass_marksman = cvar("g_start_add_fragnades_playerclass_marksman_default");
				 start_add_atmines_playerclass_marksman = cvar("g_start_add_atmines_playerclass_marksman_default");
				 start_add_landmines_playerclass_marksman = cvar("g_start_add_landmines_playerclass_marksman_default");
				 start_add_inv_potion_health_small_marksman = cvar("g_start_add_inv_potion_health_small_marksman_default");
				 start_add_inv_potion_health_medium_marksman = cvar("g_start_add_inv_potion_health_medium_marksman_default");
				 start_add_inv_potion_health_large_marksman = cvar("g_start_add_inv_potion_health_large_marksman_default");
				 start_add_inv_potion_mana_small_marksman = cvar("g_start_add_inv_potion_mana_small_marksman_default");
				 start_add_inv_potion_mana_medium_marksman = cvar("g_start_add_inv_potion_mana_medium_marksman_default");
				 start_add_inv_potion_mana_large_marksman = cvar("g_start_add_inv_potion_mana_large_marksman_default");
				 start_add_inv_potion_rejuv_small_marksman = cvar("g_start_add_inv_potion_rejuv_small_marksman_default");
				 start_add_inv_potion_rejuv_medium_marksman = cvar("g_start_add_inv_potion_rejuv_medium_marksman_default");
				 start_add_inv_potion_rejuv_large_marksman = cvar("g_start_add_inv_potion_rejuv_large_marksman_default");


				 start_add_ammo_shells_playerclass_mediumdistance = cvar("g_start_add_ammo_shells_playerclass_mediumdistance_default");
				 start_add_ammo_nails_playerclass_mediumdistance = cvar("g_start_add_ammo_nails_playerclass_mediumdistance_default");
				 start_add_ammo_rockets_playerclass_mediumdistance = cvar("g_start_add_ammo_rockets_playerclass_mediumdistance_default");
				 start_add_ammo_cells_playerclass_mediumdistance = cvar("g_start_add_ammo_cells_playerclass_mediumdistance_default");
				 start_add_ammo_fuel_playerclass_mediumdistance = cvar("g_start_add_ammo_fuel_playerclass_mediumdistance_default");
				 start_add_health_playerclass_mediumdistance = cvar("g_start_add_health_playerclass_mediumdistance_default");
				 start_add_armorvalue_playerclass_mediumdistance = cvar("g_start_add_armorvalue_playerclass_mediumdistance_default");
				 start_add_mana_playerclass_mediumdistance = cvar("g_start_add_mana_playerclass_mediumdistance_default");
				 start_add_grenades_playerclass_mediumdistance = cvar("g_start_add_grenades_playerclass_mediumdistance_default");
				 start_add_flashbangs_playerclass_mediumdistance = cvar("g_start_add_flashbangs_playerclass_mediumdistance_default");
				 start_add_smokenades_playerclass_mediumdistance = cvar("g_start_add_smokenades_playerclass_mediumdistance_default");
				 start_add_fragnades_playerclass_mediumdistance = cvar("g_start_add_fragnades_playerclass_mediumdistance_default");
				 start_add_atmines_playerclass_mediumdistance = cvar("g_start_add_atmines_playerclass_mediumdistance_default");
				 start_add_landmines_playerclass_mediumdistance = cvar("g_start_add_landmines_playerclass_mediumdistance_default");
				 start_add_inv_potion_health_small_mediumdistance = cvar("g_start_add_inv_potion_health_small_mediumdistance_default");
				 start_add_inv_potion_health_medium_mediumdistance = cvar("g_start_add_inv_potion_health_medium_mediumdistance_default");
				 start_add_inv_potion_health_large_mediumdistance = cvar("g_start_add_inv_potion_health_large_mediumdistance_default");
				 start_add_inv_potion_mana_small_mediumdistance = cvar("g_start_add_inv_potion_mana_small_mediumdistance_default");
				 start_add_inv_potion_mana_medium_mediumdistance = cvar("g_start_add_inv_potion_mana_medium_mediumdistance_default");
				 start_add_inv_potion_mana_large_mediumdistance = cvar("g_start_add_inv_potion_mana_large_mediumdistance_default");
				 start_add_inv_potion_rejuv_small_mediumdistance = cvar("g_start_add_inv_potion_rejuv_small_mediumdistance_default");
				 start_add_inv_potion_rejuv_medium_mediumdistance = cvar("g_start_add_inv_potion_rejuv_medium_mediumdistance_default");
				 start_add_inv_potion_rejuv_large_mediumdistance = cvar("g_start_add_inv_potion_rejuv_large_mediumdistance_default");

				 
				 start_add_ammo_shells_playerclass_assault = cvar("g_start_add_ammo_shells_playerclass_assault_default");
				 start_add_ammo_nails_playerclass_assault = cvar("g_start_add_ammo_nails_playerclass_assault_default");
				 start_add_ammo_rockets_playerclass_assault = cvar("g_start_add_ammo_rockets_playerclass_assault_default");
				 start_add_ammo_cells_playerclass_assault = cvar("g_start_add_ammo_cells_playerclass_assault_default");
				 start_add_ammo_fuel_playerclass_assault = cvar("g_start_add_ammo_fuel_playerclass_assault_default");
				 start_add_health_playerclass_assault = cvar("g_start_add_health_playerclass_assault_default");
				 start_add_armorvalue_playerclass_assault = cvar("g_start_add_armorvalue_playerclass_assault_default");
				 start_add_mana_playerclass_assault = cvar("g_start_add_mana_playerclass_assault_default");
				 start_add_grenades_playerclass_assault = cvar("g_start_add_grenades_playerclass_assault_default");
				 start_add_flashbangs_playerclass_assault = cvar("g_start_add_flashbangs_playerclass_assault_default");
				 start_add_smokenades_playerclass_assault = cvar("g_start_add_smokenades_playerclass_assault_default");
				 start_add_fragnades_playerclass_assault = cvar("g_start_add_fragnades_playerclass_assault_default");
				 start_add_atmines_playerclass_assault = cvar("g_start_add_atmines_playerclass_assault_default");
				 start_add_landmines_playerclass_assault = cvar("g_start_add_landmines_playerclass_assault_default");
				 start_add_inv_potion_health_small_assault = cvar("g_start_add_inv_potion_health_small_assault_default");
				 start_add_inv_potion_health_medium_assault = cvar("g_start_add_inv_potion_health_medium_assault_default");
				 start_add_inv_potion_health_large_assault = cvar("g_start_add_inv_potion_health_large_assault_default");
				 start_add_inv_potion_mana_small_assault = cvar("g_start_add_inv_potion_mana_small_assault_default");
				 start_add_inv_potion_mana_medium_assault = cvar("g_start_add_inv_potion_mana_medium_assault_default");
				 start_add_inv_potion_mana_large_assault = cvar("g_start_add_inv_potion_mana_large_assault_default");
				 start_add_inv_potion_rejuv_small_assault = cvar("g_start_add_inv_potion_rejuv_small_assault_default");
				 start_add_inv_potion_rejuv_medium_assault = cvar("g_start_add_inv_potion_rejuv_medium_assault_default");
				 start_add_inv_potion_rejuv_large_assault = cvar("g_start_add_inv_potion_rejuv_large_assault_default");

				 


				 start_add_ammo_shells_playerclass_closerange = cvar("g_start_add_ammo_shells_playerclass_closerange_default");
				 start_add_ammo_nails_playerclass_closerange = cvar("g_start_add_ammo_nails_playerclass_closerange_default");
				 start_add_ammo_rockets_playerclass_closerange = cvar("g_start_add_ammo_rockets_playerclass_closerange_default");
				 start_add_ammo_cells_playerclass_closerange = cvar("g_start_add_ammo_cells_playerclass_closerange_default");
				 start_add_ammo_fuel_playerclass_closerange = cvar("g_start_add_ammo_fuel_playerclass_closerange_default");
				 start_add_health_playerclass_closerange = cvar("g_start_add_health_playerclass_closerange_default");
				 start_add_armorvalue_playerclass_closerange = cvar("g_start_add_armorvalue_playerclass_closerange_default");
				 start_add_mana_playerclass_closerange = cvar("g_start_add_mana_playerclass_closerange_default");
				 start_add_grenades_playerclass_closerange = cvar("g_start_add_grenades_playerclass_closerange_default");
				 start_add_flashbangs_playerclass_closerange = cvar("g_start_add_flashbangs_playerclass_closerange_default");
				 start_add_smokenades_playerclass_closerange = cvar("g_start_add_smokenades_playerclass_closerange_default");
				 start_add_fragnades_playerclass_closerange = cvar("g_start_add_fragnades_playerclass_closerange_default");
				 start_add_atmines_playerclass_closerange = cvar("g_start_add_atmines_playerclass_closerange_default");
				 start_add_landmines_playerclass_closerange = cvar("g_start_add_landmines_playerclass_closerange_default");
				 start_add_inv_potion_health_small_closerange = cvar("g_start_add_inv_potion_health_small_closerange_default");
				 start_add_inv_potion_health_medium_closerange = cvar("g_start_add_inv_potion_health_medium_closerange_default");
				 start_add_inv_potion_health_large_closerange = cvar("g_start_add_inv_potion_health_large_closerange_default");
				 start_add_inv_potion_mana_small_closerange = cvar("g_start_add_inv_potion_mana_small_closerange_default");
				 start_add_inv_potion_mana_medium_closerange = cvar("g_start_add_inv_potion_mana_medium_closerange_default");
				 start_add_inv_potion_mana_large_closerange = cvar("g_start_add_inv_potion_mana_large_closerange_default");
				 start_add_inv_potion_rejuv_small_closerange = cvar("g_start_add_inv_potion_rejuv_small_closerange_default");
				 start_add_inv_potion_rejuv_medium_closerange = cvar("g_start_add_inv_potion_rejuv_medium_closerange_default");
				 start_add_inv_potion_rejuv_large_closerange = cvar("g_start_add_inv_potion_rejuv_large_closerange_default");

				 
				 start_add_ammo_shells_playerclass_destructive = cvar("g_start_add_ammo_shells_playerclass_destructive_default");
				 start_add_ammo_nails_playerclass_destructive = cvar("g_start_add_ammo_nails_playerclass_destructive_default");
				 start_add_ammo_rockets_playerclass_destructive = cvar("g_start_add_ammo_rockets_playerclass_destructive_default");
				 start_add_ammo_cells_playerclass_destructive = cvar("g_start_add_ammo_cells_playerclass_destructive_default");
				 start_add_ammo_fuel_playerclass_destructive = cvar("g_start_add_ammo_fuel_playerclass_destructive_default");
				 start_add_health_playerclass_destructive = cvar("g_start_add_health_playerclass_destructive_default");
				 start_add_armorvalue_playerclass_destructive = cvar("g_start_add_armorvalue_playerclass_destructive_default");
				 start_add_mana_playerclass_destructive = cvar("g_start_add_mana_playerclass_destructive_default");
				 start_add_grenades_playerclass_destructive = cvar("g_start_add_grenades_playerclass_destructive_default");
				 start_add_flashbangs_playerclass_destructive = cvar("g_start_add_flashbangs_playerclass_destructive_default");
				 start_add_smokenades_playerclass_destructive = cvar("g_start_add_smokenades_playerclass_destructive_default");
				 start_add_fragnades_playerclass_destructive = cvar("g_start_add_fragnades_playerclass_destructive_default");
				 start_add_atmines_playerclass_destructive = cvar("g_start_add_atmines_playerclass_destructive_default");
				 start_add_landmines_playerclass_destructive = cvar("g_start_add_landmines_playerclass_destructive_default");
				 start_add_inv_potion_health_small_destructive = cvar("g_start_add_inv_potion_health_small_destructive_default");
				 start_add_inv_potion_health_medium_destructive = cvar("g_start_add_inv_potion_health_medium_destructive_default");
				 start_add_inv_potion_health_large_destructive = cvar("g_start_add_inv_potion_health_large_destructive_default");
				 start_add_inv_potion_mana_small_destructive = cvar("g_start_add_inv_potion_mana_small_destructive_default");
				 start_add_inv_potion_mana_medium_destructive = cvar("g_start_add_inv_potion_mana_medium_destructive_default");
				 start_add_inv_potion_mana_large_destructive = cvar("g_start_add_inv_potion_mana_large_destructive_default");
				 start_add_inv_potion_rejuv_small_destructive = cvar("g_start_add_inv_potion_rejuv_small_destructive_default");
				 start_add_inv_potion_rejuv_medium_destructive = cvar("g_start_add_inv_potion_rejuv_medium_destructive_default");
				 start_add_inv_potion_rejuv_large_destructive = cvar("g_start_add_inv_potion_rejuv_large_destructive_default");

				 
				 start_add_ammo_shells_playerclass_heavyweapons = cvar("g_start_add_ammo_shells_playerclass_heavyweapons_default");
				 start_add_ammo_nails_playerclass_heavyweapons = cvar("g_start_add_ammo_nails_playerclass_heavyweapons_default");
				 start_add_ammo_rockets_playerclass_heavyweapons = cvar("g_start_add_ammo_rockets_playerclass_heavyweapons_default");
				 start_add_ammo_cells_playerclass_heavyweapons = cvar("g_start_add_ammo_cells_playerclass_heavyweapons_default");
				 start_add_ammo_fuel_playerclass_heavyweapons = cvar("g_start_add_ammo_fuel_playerclass_heavyweapons_default");
				 start_add_health_playerclass_heavyweapons = cvar("g_start_add_health_playerclass_heavyweapons_default");
				 start_add_armorvalue_playerclass_heavyweapons = cvar("g_start_add_armorvalue_playerclass_heavyweapons_default");
				 start_add_mana_playerclass_heavyweapons = cvar("g_start_add_mana_playerclass_heavyweapons_default");
				 start_add_grenades_playerclass_heavyweapons = cvar("g_start_add_grenades_playerclass_heavyweapons_default");
				 start_add_flashbangs_playerclass_heavyweapons = cvar("g_start_add_flashbangs_playerclass_heavyweapons_default");
				 start_add_smokenades_playerclass_heavyweapons = cvar("g_start_add_smokenades_playerclass_heavyweapons_default");
				 start_add_fragnades_playerclass_heavyweapons = cvar("g_start_add_fragnades_playerclass_heavyweapons_default");
				 start_add_atmines_playerclass_heavyweapons = cvar("g_start_add_atmines_playerclass_heavyweapons_default");
				 start_add_landmines_playerclass_heavyweapons = cvar("g_start_add_landmines_playerclass_heavyweapons_default");
				 start_add_inv_potion_health_small_heavyweapons = cvar("g_start_add_inv_potion_health_small_heavyweapons_default");
				 start_add_inv_potion_health_medium_heavyweapons = cvar("g_start_add_inv_potion_health_medium_heavyweapons_default");
				 start_add_inv_potion_health_large_heavyweapons = cvar("g_start_add_inv_potion_health_large_heavyweapons_default");
				 start_add_inv_potion_mana_small_heavyweapons = cvar("g_start_add_inv_potion_mana_small_heavyweapons_default");
				 start_add_inv_potion_mana_medium_heavyweapons = cvar("g_start_add_inv_potion_mana_medium_heavyweapons_default");
				 start_add_inv_potion_mana_large_heavyweapons = cvar("g_start_add_inv_potion_mana_large_heavyweapons_default");
				 start_add_inv_potion_rejuv_small_heavyweapons = cvar("g_start_add_inv_potion_rejuv_small_heavyweapons_default");
				 start_add_inv_potion_rejuv_medium_heavyweapons = cvar("g_start_add_inv_potion_rejuv_medium_heavyweapons_default");
				 start_add_inv_potion_rejuv_large_heavyweapons = cvar("g_start_add_inv_potion_rejuv_large_heavyweapons_default");

				 
				 start_add_ammo_shells_playerclass_pyromaniac = cvar("g_start_add_ammo_shells_playerclass_pyromaniac_default");
				 start_add_ammo_nails_playerclass_pyromaniac = cvar("g_start_add_ammo_nails_playerclass_pyromaniac_default");
				 start_add_ammo_rockets_playerclass_pyromaniac = cvar("g_start_add_ammo_rockets_playerclass_pyromaniac_default");
				 start_add_ammo_cells_playerclass_pyromaniac = cvar("g_start_add_ammo_cells_playerclass_pyromaniac_default");
				 start_add_ammo_fuel_playerclass_pyromaniac = cvar("g_start_add_ammo_fuel_playerclass_pyromaniac_default");
				 start_add_health_playerclass_pyromaniac = cvar("g_start_add_health_playerclass_pyromaniac_default");
				 start_add_armorvalue_playerclass_pyromaniac = cvar("g_start_add_armorvalue_playerclass_pyromaniac_default");
				 start_add_mana_playerclass_pyromaniac = cvar("g_start_add_mana_playerclass_pyromaniac_default");
				 start_add_grenades_playerclass_pyromaniac = cvar("g_start_add_grenades_playerclass_pyromaniac_default");
				 start_add_flashbangs_playerclass_pyromaniac = cvar("g_start_add_flashbangs_playerclass_pyromaniac_default");
				 start_add_smokenades_playerclass_pyromaniac = cvar("g_start_add_smokenades_playerclass_pyromaniac_default");
				 start_add_fragnades_playerclass_pyromaniac = cvar("g_start_add_fragnades_playerclass_pyromaniac_default");
				 start_add_atmines_playerclass_pyromaniac = cvar("g_start_add_atmines_playerclass_pyromaniac_default");
				 start_add_landmines_playerclass_pyromaniac = cvar("g_start_add_landmines_playerclass_pyromaniac_default");
				 start_add_inv_potion_health_small_pyromaniac = cvar("g_start_add_inv_potion_health_small_pyromaniac_default");
				 start_add_inv_potion_health_medium_pyromaniac = cvar("g_start_add_inv_potion_health_medium_pyromaniac_default");
				 start_add_inv_potion_health_large_pyromaniac = cvar("g_start_add_inv_potion_health_large_pyromaniac_default");
				 start_add_inv_potion_mana_small_pyromaniac = cvar("g_start_add_inv_potion_mana_small_pyromaniac_default");
				 start_add_inv_potion_mana_medium_pyromaniac = cvar("g_start_add_inv_potion_mana_medium_pyromaniac_default");
				 start_add_inv_potion_mana_large_pyromaniac = cvar("g_start_add_inv_potion_mana_large_pyromaniac_default");
				 start_add_inv_potion_rejuv_small_pyromaniac = cvar("g_start_add_inv_potion_rejuv_small_pyromaniac_default");
				 start_add_inv_potion_rejuv_medium_pyromaniac = cvar("g_start_add_inv_potion_rejuv_medium_pyromaniac_default");
				 start_add_inv_potion_rejuv_large_pyromaniac = cvar("g_start_add_inv_potion_rejuv_large_pyromaniac_default");

				 
				 start_add_ammo_shells_playerclass_engineer = cvar("g_start_add_ammo_shells_playerclass_engineer_default");
				 start_add_ammo_nails_playerclass_engineer = cvar("g_start_add_ammo_nails_playerclass_engineer_default");
				 start_add_ammo_rockets_playerclass_engineer = cvar("g_start_add_ammo_rockets_playerclass_engineer_default");
				 start_add_ammo_cells_playerclass_engineer = cvar("g_start_add_ammo_cells_playerclass_engineer_default");
				 start_add_ammo_fuel_playerclass_engineer = cvar("g_start_add_ammo_fuel_playerclass_engineer_default");
				 start_add_health_playerclass_engineer = cvar("g_start_add_health_playerclass_engineer_default");
				 start_add_armorvalue_playerclass_engineer = cvar("g_start_add_armorvalue_playerclass_engineer_default");
				 start_add_mana_playerclass_engineer = cvar("g_start_add_mana_playerclass_engineer_default");
				 start_add_grenades_playerclass_engineer = cvar("g_start_add_grenades_playerclass_engineer_default");
				 start_add_flashbangs_playerclass_engineer = cvar("g_start_add_flashbangs_playerclass_engineer_default");
				 start_add_smokenades_playerclass_engineer = cvar("g_start_add_smokenades_playerclass_engineer_default");
				 start_add_fragnades_playerclass_engineer = cvar("g_start_add_fragnades_playerclass_engineer_default");
				 start_add_atmines_playerclass_engineer = cvar("g_start_add_atmines_playerclass_engineer_default");
				 start_add_landmines_playerclass_engineer = cvar("g_start_add_landmines_playerclass_engineer_default");
				 start_add_inv_potion_health_small_engineer = cvar("g_start_add_inv_potion_health_small_engineer_default");
				 start_add_inv_potion_health_medium_engineer = cvar("g_start_add_inv_potion_health_medium_engineer_default");
				 start_add_inv_potion_health_large_engineer = cvar("g_start_add_inv_potion_health_large_engineer_default");
				 start_add_inv_potion_mana_small_engineer = cvar("g_start_add_inv_potion_mana_small_engineer_default");
				 start_add_inv_potion_mana_medium_engineer = cvar("g_start_add_inv_potion_mana_medium_engineer_default");
				 start_add_inv_potion_mana_large_engineer = cvar("g_start_add_inv_potion_mana_large_engineer_default");
				 start_add_inv_potion_rejuv_small_engineer = cvar("g_start_add_inv_potion_rejuv_small_engineer_default");
				 start_add_inv_potion_rejuv_medium_engineer = cvar("g_start_add_inv_potion_rejuv_medium_engineer_default");
				 start_add_inv_potion_rejuv_large_engineer = cvar("g_start_add_inv_potion_rejuv_large_engineer_default");

				 
				 
				 start_add_ammo_shells_playerclass_worker = cvar("g_start_add_ammo_shells_playerclass_worker_default");
				 start_add_ammo_nails_playerclass_worker = cvar("g_start_add_ammo_nails_playerclass_worker_default");
				 start_add_ammo_rockets_playerclass_worker = cvar("g_start_add_ammo_rockets_playerclass_worker_default");
				 start_add_ammo_cells_playerclass_worker = cvar("g_start_add_ammo_cells_playerclass_worker_default");
				 start_add_ammo_fuel_playerclass_worker = cvar("g_start_add_ammo_fuel_playerclass_worker_default");
				 start_add_health_playerclass_worker = cvar("g_start_add_health_playerclass_worker_default");
				 start_add_armorvalue_playerclass_worker = cvar("g_start_add_armorvalue_playerclass_worker_default");
				 start_add_mana_playerclass_worker = cvar("g_start_add_mana_playerclass_worker_default");
				 start_add_grenades_playerclass_worker = cvar("g_start_add_grenades_playerclass_worker_default");
				 start_add_flashbangs_playerclass_worker = cvar("g_start_add_flashbangs_playerclass_worker_default");
				 start_add_smokenades_playerclass_worker = cvar("g_start_add_smokenades_playerclass_worker_default");
				 start_add_fragnades_playerclass_worker = cvar("g_start_add_fragnades_playerclass_worker_default");
				 start_add_atmines_playerclass_worker = cvar("g_start_add_atmines_playerclass_worker_default");
				 start_add_landmines_playerclass_worker = cvar("g_start_add_landmines_playerclass_worker_default");
				 start_add_inv_potion_health_small_worker = cvar("g_start_add_inv_potion_health_small_worker_default");
				 start_add_inv_potion_health_medium_worker = cvar("g_start_add_inv_potion_health_medium_worker_default");
				 start_add_inv_potion_health_large_worker = cvar("g_start_add_inv_potion_health_large_worker_default");
				 start_add_inv_potion_mana_small_worker = cvar("g_start_add_inv_potion_mana_small_worker_default");
				 start_add_inv_potion_mana_medium_worker = cvar("g_start_add_inv_potion_mana_medium_worker_default");
				 start_add_inv_potion_mana_large_worker = cvar("g_start_add_inv_potion_mana_large_worker_default");
				 start_add_inv_potion_rejuv_small_worker = cvar("g_start_add_inv_potion_rejuv_small_worker_default");
				 start_add_inv_potion_rejuv_medium_worker = cvar("g_start_add_inv_potion_rejuv_medium_worker_default");
				 start_add_inv_potion_rejuv_large_worker = cvar("g_start_add_inv_potion_rejuv_large_worker_default");

				 
				 start_add_ammo_shells_playerclass_healer = cvar("g_start_add_ammo_shells_playerclass_healer_default");
				 start_add_ammo_nails_playerclass_healer = cvar("g_start_add_ammo_nails_playerclass_healer_default");
				 start_add_ammo_rockets_playerclass_healer = cvar("g_start_add_ammo_rockets_playerclass_healer_default");
				 start_add_ammo_cells_playerclass_healer = cvar("g_start_add_ammo_cells_playerclass_healer_default");
				 start_add_ammo_fuel_playerclass_healer = cvar("g_start_add_ammo_fuel_playerclass_healer_default");
				 start_add_health_playerclass_healer = cvar("g_start_add_health_playerclass_healer_default");
				 start_add_armorvalue_playerclass_healer = cvar("g_start_add_armorvalue_playerclass_healer_default");
				 start_add_mana_playerclass_healer = cvar("g_start_add_mana_playerclass_healer_default");
				 start_add_grenades_playerclass_healer = cvar("g_start_add_grenades_playerclass_healer_default");
				 start_add_flashbangs_playerclass_healer = cvar("g_start_add_flashbangs_playerclass_healer_default");
				 start_add_smokenades_playerclass_healer = cvar("g_start_add_smokenades_playerclass_healer_default");
				 start_add_fragnades_playerclass_healer = cvar("g_start_add_fragnades_playerclass_healer_default");
				 start_add_atmines_playerclass_healer = cvar("g_start_add_atmines_playerclass_healer_default");
				 start_add_landmines_playerclass_healer = cvar("g_start_add_landmines_playerclass_healer_default");
				 start_add_inv_potion_health_small_healer = cvar("g_start_add_inv_potion_health_small_healer_default");
				 start_add_inv_potion_health_medium_healer = cvar("g_start_add_inv_potion_health_medium_healer_default");
				 start_add_inv_potion_health_large_healer = cvar("g_start_add_inv_potion_health_large_healer_default");
				 start_add_inv_potion_mana_small_healer = cvar("g_start_add_inv_potion_mana_small_healer_default");
				 start_add_inv_potion_mana_medium_healer = cvar("g_start_add_inv_potion_mana_medium_healer_default");
				 start_add_inv_potion_mana_large_healer = cvar("g_start_add_inv_potion_mana_large_healer_default");
				 start_add_inv_potion_rejuv_small_healer = cvar("g_start_add_inv_potion_rejuv_small_healer_default");
				 start_add_inv_potion_rejuv_medium_healer = cvar("g_start_add_inv_potion_rejuv_medium_healer_default");
				 start_add_inv_potion_rejuv_large_healer = cvar("g_start_add_inv_potion_rejuv_large_healer_default");

				 
			} else if (mypcselection == PLAYERCLASSSET_MEDIEVALFANTASY) {
				playerclassset = mypcselection;
				wepsetfromcvar_playerclass_longdistance("g_playerclass_weapons_longdistance_medievalfantasy");
				wepsetfromcvar_playerclass_marksman("g_playerclass_weapons_marksman_medievalfantasy");
				wepsetfromcvar_playerclass_mediumdistance("g_playerclass_weapons_mediumdistance_medievalfantasy");
				wepsetfromcvar_playerclass_assault("g_playerclass_weapons_assault_medievalfantasy");
				wepsetfromcvar_playerclass_closerange("g_playerclass_weapons_closerange_medievalfantasy");
				wepsetfromcvar_playerclass_destructive("g_playerclass_weapons_destructive_medievalfantasy");
				wepsetfromcvar_playerclass_heavyweapons("g_playerclass_weapons_heavyweapons_medievalfantasy");
				wepsetfromcvar_playerclass_pyromaniac("g_playerclass_weapons_pyromaniac_medievalfantasy");
				wepsetfromcvar_playerclass_engineer("g_playerclass_weapons_engineer_medievalfantasy");
				wepsetfromcvar_playerclass_worker("g_playerclass_weapons_worker_medievalfantasy");
				wepsetfromcvar_playerclass_healer("g_playerclass_weapons_healer_medievalfantasy");
				
				//Ammo
				 start_add_ammo_shells_playerclass_longdistance = cvar("g_start_add_ammo_shells_playerclass_longdistance_medievalfantasy");
				 start_add_ammo_nails_playerclass_longdistance = cvar("g_start_add_ammo_nails_playerclass_longdistance_medievalfantasy");
				 start_add_ammo_rockets_playerclass_longdistance = cvar("g_start_add_ammo_rockets_playerclass_longdistance_medievalfantasy");
				 start_add_ammo_cells_playerclass_longdistance = cvar("g_start_add_ammo_cells_playerclass_longdistance_medievalfantasy");
				 start_add_ammo_fuel_playerclass_longdistance = cvar("g_start_add_ammo_fuel_playerclass_longdistance_medievalfantasy");
				 start_add_health_playerclass_longdistance = cvar("g_start_add_health_playerclass_longdistance_medievalfantasy");
				 start_add_armorvalue_playerclass_longdistance = cvar("g_start_add_armorvalue_playerclass_longdistance_medievalfantasy");
				 start_add_mana_playerclass_longdistance = cvar("g_start_add_mana_playerclass_longdistance_medievalfantasy");
				 start_add_grenades_playerclass_longdistance = cvar("g_start_add_grenades_playerclass_longdistance_medievalfantasy");
				 start_add_flashbangs_playerclass_longdistance = cvar("g_start_add_flashbangs_playerclass_longdistance_medievalfantasy");
				 start_add_smokenades_playerclass_longdistance = cvar("g_start_add_smokenades_playerclass_longdistance_medievalfantasy");
				 start_add_fragnades_playerclass_longdistance = cvar("g_start_add_fragnades_playerclass_longdistance_medievalfantasy");
				 start_add_atmines_playerclass_longdistance = cvar("g_start_add_atmines_playerclass_longdistance_medievalfantasy");
				 start_add_landmines_playerclass_longdistance = cvar("g_start_add_landmines_playerclass_longdistance_medievalfantasy");
				 start_add_inv_potion_health_small_longdistance = cvar("g_start_add_inv_potion_health_small_longdistance_medievalfantasy");
				 start_add_inv_potion_health_medium_longdistance = cvar("g_start_add_inv_potion_health_medium_longdistance_medievalfantasy");
				 start_add_inv_potion_health_large_longdistance = cvar("g_start_add_inv_potion_health_large_longdistance_medievalfantasy");
				 start_add_inv_potion_mana_small_longdistance = cvar("g_start_add_inv_potion_mana_small_longdistance_medievalfantasy");
				 start_add_inv_potion_mana_medium_longdistance = cvar("g_start_add_inv_potion_mana_medium_longdistance_medievalfantasy");
				 start_add_inv_potion_mana_large_longdistance = cvar("g_start_add_inv_potion_mana_large_longdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_small_longdistance = cvar("g_start_add_inv_potion_rejuv_small_longdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_longdistance = cvar("g_start_add_inv_potion_rejuv_medium_longdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_large_longdistance = cvar("g_start_add_inv_potion_rejuv_large_longdistance_medievalfantasy");


				 start_add_ammo_shells_playerclass_marksman = cvar("g_start_add_ammo_shells_playerclass_marksman_medievalfantasy");
				 start_add_ammo_nails_playerclass_marksman = cvar("g_start_add_ammo_nails_playerclass_marksman_medievalfantasy");
				 start_add_ammo_rockets_playerclass_marksman = cvar("g_start_add_ammo_rockets_playerclass_marksman_medievalfantasy");
				 start_add_ammo_cells_playerclass_marksman = cvar("g_start_add_ammo_cells_playerclass_marksman_medievalfantasy");
				 start_add_ammo_fuel_playerclass_marksman = cvar("g_start_add_ammo_fuel_playerclass_marksman_medievalfantasy");
				 start_add_health_playerclass_marksman = cvar("g_start_add_health_playerclass_marksman_medievalfantasy");
				 start_add_armorvalue_playerclass_marksman = cvar("g_start_add_armorvalue_playerclass_marksman_medievalfantasy");
				 start_add_mana_playerclass_marksman = cvar("g_start_add_mana_playerclass_marksman_medievalfantasy");
				 start_add_grenades_playerclass_marksman = cvar("g_start_add_grenades_playerclass_marksman_medievalfantasy");
				 start_add_flashbangs_playerclass_marksman = cvar("g_start_add_flashbangs_playerclass_marksman_medievalfantasy");
				 start_add_smokenades_playerclass_marksman = cvar("g_start_add_smokenades_playerclass_marksman_medievalfantasy");
				 start_add_fragnades_playerclass_marksman = cvar("g_start_add_fragnades_playerclass_marksman_medievalfantasy");
				 start_add_atmines_playerclass_marksman = cvar("g_start_add_atmines_playerclass_marksman_medievalfantasy");
				 start_add_landmines_playerclass_marksman = cvar("g_start_add_landmines_playerclass_marksman_medievalfantasy");
				 start_add_inv_potion_health_small_marksman = cvar("g_start_add_inv_potion_health_small_marksman_medievalfantasy");
				 start_add_inv_potion_health_medium_marksman = cvar("g_start_add_inv_potion_health_medium_marksman_medievalfantasy");
				 start_add_inv_potion_health_large_marksman = cvar("g_start_add_inv_potion_health_large_marksman_medievalfantasy");
				 start_add_inv_potion_mana_small_marksman = cvar("g_start_add_inv_potion_mana_small_marksman_medievalfantasy");
				 start_add_inv_potion_mana_medium_marksman = cvar("g_start_add_inv_potion_mana_medium_marksman_medievalfantasy");
				 start_add_inv_potion_mana_large_marksman = cvar("g_start_add_inv_potion_mana_large_marksman_medievalfantasy");
				 start_add_inv_potion_rejuv_small_marksman = cvar("g_start_add_inv_potion_rejuv_small_marksman_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_marksman = cvar("g_start_add_inv_potion_rejuv_medium_marksman_medievalfantasy");
				 start_add_inv_potion_rejuv_large_marksman = cvar("g_start_add_inv_potion_rejuv_large_marksman_medievalfantasy");


				 start_add_ammo_shells_playerclass_mediumdistance = cvar("g_start_add_ammo_shells_playerclass_mediumdistance_medievalfantasy");
				 start_add_ammo_nails_playerclass_mediumdistance = cvar("g_start_add_ammo_nails_playerclass_mediumdistance_medievalfantasy");
				 start_add_ammo_rockets_playerclass_mediumdistance = cvar("g_start_add_ammo_rockets_playerclass_mediumdistance_medievalfantasy");
				 start_add_ammo_cells_playerclass_mediumdistance = cvar("g_start_add_ammo_cells_playerclass_mediumdistance_medievalfantasy");
				 start_add_ammo_fuel_playerclass_mediumdistance = cvar("g_start_add_ammo_fuel_playerclass_mediumdistance_medievalfantasy");
				 start_add_health_playerclass_mediumdistance = cvar("g_start_add_health_playerclass_mediumdistance_medievalfantasy");
				 start_add_armorvalue_playerclass_mediumdistance = cvar("g_start_add_armorvalue_playerclass_mediumdistance_medievalfantasy");
				 start_add_mana_playerclass_mediumdistance = cvar("g_start_add_mana_playerclass_mediumdistance_medievalfantasy");
				 start_add_grenades_playerclass_mediumdistance = cvar("g_start_add_grenades_playerclass_mediumdistance_medievalfantasy");
				 start_add_flashbangs_playerclass_mediumdistance = cvar("g_start_add_flashbangs_playerclass_mediumdistance_medievalfantasy");
				 start_add_smokenades_playerclass_mediumdistance = cvar("g_start_add_smokenades_playerclass_mediumdistance_medievalfantasy");
				 start_add_fragnades_playerclass_mediumdistance = cvar("g_start_add_fragnades_playerclass_mediumdistance_medievalfantasy");
				 start_add_atmines_playerclass_mediumdistance = cvar("g_start_add_atmines_playerclass_mediumdistance_medievalfantasy");
				 start_add_landmines_playerclass_mediumdistance = cvar("g_start_add_landmines_playerclass_mediumdistance_medievalfantasy");
				 start_add_inv_potion_health_small_mediumdistance = cvar("g_start_add_inv_potion_health_small_mediumdistance_medievalfantasy");
				 start_add_inv_potion_health_medium_mediumdistance = cvar("g_start_add_inv_potion_health_medium_mediumdistance_medievalfantasy");
				 start_add_inv_potion_health_large_mediumdistance = cvar("g_start_add_inv_potion_health_large_mediumdistance_medievalfantasy");
				 start_add_inv_potion_mana_small_mediumdistance = cvar("g_start_add_inv_potion_mana_small_mediumdistance_medievalfantasy");
				 start_add_inv_potion_mana_medium_mediumdistance = cvar("g_start_add_inv_potion_mana_medium_mediumdistance_medievalfantasy");
				 start_add_inv_potion_mana_large_mediumdistance = cvar("g_start_add_inv_potion_mana_large_mediumdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_small_mediumdistance = cvar("g_start_add_inv_potion_rejuv_small_mediumdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_mediumdistance = cvar("g_start_add_inv_potion_rejuv_medium_mediumdistance_medievalfantasy");
				 start_add_inv_potion_rejuv_large_mediumdistance = cvar("g_start_add_inv_potion_rejuv_large_mediumdistance_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_assault = cvar("g_start_add_ammo_shells_playerclass_assault_medievalfantasy");
				 start_add_ammo_nails_playerclass_assault = cvar("g_start_add_ammo_nails_playerclass_assault_medievalfantasy");
				 start_add_ammo_rockets_playerclass_assault = cvar("g_start_add_ammo_rockets_playerclass_assault_medievalfantasy");
				 start_add_ammo_cells_playerclass_assault = cvar("g_start_add_ammo_cells_playerclass_assault_medievalfantasy");
				 start_add_ammo_fuel_playerclass_assault = cvar("g_start_add_ammo_fuel_playerclass_assault_medievalfantasy");
				 start_add_health_playerclass_assault = cvar("g_start_add_health_playerclass_assault_medievalfantasy");
				 start_add_armorvalue_playerclass_assault = cvar("g_start_add_armorvalue_playerclass_assault_medievalfantasy");
				 start_add_mana_playerclass_assault = cvar("g_start_add_mana_playerclass_assault_medievalfantasy");
				 start_add_grenades_playerclass_assault = cvar("g_start_add_grenades_playerclass_assault_medievalfantasy");
				 start_add_flashbangs_playerclass_assault = cvar("g_start_add_flashbangs_playerclass_assault_medievalfantasy");
				 start_add_smokenades_playerclass_assault = cvar("g_start_add_smokenades_playerclass_assault_medievalfantasy");
				 start_add_fragnades_playerclass_assault = cvar("g_start_add_fragnades_playerclass_assault_medievalfantasy");
				 start_add_atmines_playerclass_assault = cvar("g_start_add_atmines_playerclass_assault_medievalfantasy");
				 start_add_landmines_playerclass_assault = cvar("g_start_add_landmines_playerclass_assault_medievalfantasy");
				 start_add_inv_potion_health_small_assault = cvar("g_start_add_inv_potion_health_small_assault_medievalfantasy");
				 start_add_inv_potion_health_medium_assault = cvar("g_start_add_inv_potion_health_medium_assault_medievalfantasy");
				 start_add_inv_potion_health_large_assault = cvar("g_start_add_inv_potion_health_large_assault_medievalfantasy");
				 start_add_inv_potion_mana_small_assault = cvar("g_start_add_inv_potion_mana_small_assault_medievalfantasy");
				 start_add_inv_potion_mana_medium_assault = cvar("g_start_add_inv_potion_mana_medium_assault_medievalfantasy");
				 start_add_inv_potion_mana_large_assault = cvar("g_start_add_inv_potion_mana_large_assault_medievalfantasy");
				 start_add_inv_potion_rejuv_small_assault = cvar("g_start_add_inv_potion_rejuv_small_assault_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_assault = cvar("g_start_add_inv_potion_rejuv_medium_assault_medievalfantasy");
				 start_add_inv_potion_rejuv_large_assault = cvar("g_start_add_inv_potion_rejuv_large_assault_medievalfantasy");

				 


				 start_add_ammo_shells_playerclass_closerange = cvar("g_start_add_ammo_shells_playerclass_closerange_medievalfantasy");
				 start_add_ammo_nails_playerclass_closerange = cvar("g_start_add_ammo_nails_playerclass_closerange_medievalfantasy");
				 start_add_ammo_rockets_playerclass_closerange = cvar("g_start_add_ammo_rockets_playerclass_closerange_medievalfantasy");
				 start_add_ammo_cells_playerclass_closerange = cvar("g_start_add_ammo_cells_playerclass_closerange_medievalfantasy");
				 start_add_ammo_fuel_playerclass_closerange = cvar("g_start_add_ammo_fuel_playerclass_closerange_medievalfantasy");
				 start_add_health_playerclass_closerange = cvar("g_start_add_health_playerclass_closerange_medievalfantasy");
				 start_add_armorvalue_playerclass_closerange = cvar("g_start_add_armorvalue_playerclass_closerange_medievalfantasy");
				 start_add_mana_playerclass_closerange = cvar("g_start_add_mana_playerclass_closerange_medievalfantasy");
				 start_add_grenades_playerclass_closerange = cvar("g_start_add_grenades_playerclass_closerange_medievalfantasy");
				 start_add_flashbangs_playerclass_closerange = cvar("g_start_add_flashbangs_playerclass_closerange_medievalfantasy");
				 start_add_smokenades_playerclass_closerange = cvar("g_start_add_smokenades_playerclass_closerange_medievalfantasy");
				 start_add_fragnades_playerclass_closerange = cvar("g_start_add_fragnades_playerclass_closerange_medievalfantasy");
				 start_add_atmines_playerclass_closerange = cvar("g_start_add_atmines_playerclass_closerange_medievalfantasy");
				 start_add_landmines_playerclass_closerange = cvar("g_start_add_landmines_playerclass_closerange_medievalfantasy");
				 start_add_inv_potion_health_small_closerange = cvar("g_start_add_inv_potion_health_small_closerange_medievalfantasy");
				 start_add_inv_potion_health_medium_closerange = cvar("g_start_add_inv_potion_health_medium_closerange_medievalfantasy");
				 start_add_inv_potion_health_large_closerange = cvar("g_start_add_inv_potion_health_large_closerange_medievalfantasy");
				 start_add_inv_potion_mana_small_closerange = cvar("g_start_add_inv_potion_mana_small_closerange_medievalfantasy");
				 start_add_inv_potion_mana_medium_closerange = cvar("g_start_add_inv_potion_mana_medium_closerange_medievalfantasy");
				 start_add_inv_potion_mana_large_closerange = cvar("g_start_add_inv_potion_mana_large_closerange_medievalfantasy");
				 start_add_inv_potion_rejuv_small_closerange = cvar("g_start_add_inv_potion_rejuv_small_closerange_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_closerange = cvar("g_start_add_inv_potion_rejuv_medium_closerange_medievalfantasy");
				 start_add_inv_potion_rejuv_large_closerange = cvar("g_start_add_inv_potion_rejuv_large_closerange_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_destructive = cvar("g_start_add_ammo_shells_playerclass_destructive_medievalfantasy");
				 start_add_ammo_nails_playerclass_destructive = cvar("g_start_add_ammo_nails_playerclass_destructive_medievalfantasy");
				 start_add_ammo_rockets_playerclass_destructive = cvar("g_start_add_ammo_rockets_playerclass_destructive_medievalfantasy");
				 start_add_ammo_cells_playerclass_destructive = cvar("g_start_add_ammo_cells_playerclass_destructive_medievalfantasy");
				 start_add_ammo_fuel_playerclass_destructive = cvar("g_start_add_ammo_fuel_playerclass_destructive_medievalfantasy");
				 start_add_health_playerclass_destructive = cvar("g_start_add_health_playerclass_destructive_medievalfantasy");
				 start_add_armorvalue_playerclass_destructive = cvar("g_start_add_armorvalue_playerclass_destructive_medievalfantasy");
				 start_add_mana_playerclass_destructive = cvar("g_start_add_mana_playerclass_destructive_medievalfantasy");
				 start_add_grenades_playerclass_destructive = cvar("g_start_add_grenades_playerclass_destructive_medievalfantasy");
				 start_add_flashbangs_playerclass_destructive = cvar("g_start_add_flashbangs_playerclass_destructive_medievalfantasy");
				 start_add_smokenades_playerclass_destructive = cvar("g_start_add_smokenades_playerclass_destructive_medievalfantasy");
				 start_add_fragnades_playerclass_destructive = cvar("g_start_add_fragnades_playerclass_destructive_medievalfantasy");
				 start_add_atmines_playerclass_destructive = cvar("g_start_add_atmines_playerclass_destructive_medievalfantasy");
				 start_add_landmines_playerclass_destructive = cvar("g_start_add_landmines_playerclass_destructive_medievalfantasy");
				 start_add_inv_potion_health_small_destructive = cvar("g_start_add_inv_potion_health_small_destructive_medievalfantasy");
				 start_add_inv_potion_health_medium_destructive = cvar("g_start_add_inv_potion_health_medium_destructive_medievalfantasy");
				 start_add_inv_potion_health_large_destructive = cvar("g_start_add_inv_potion_health_large_destructive_medievalfantasy");
				 start_add_inv_potion_mana_small_destructive = cvar("g_start_add_inv_potion_mana_small_destructive_medievalfantasy");
				 start_add_inv_potion_mana_medium_destructive = cvar("g_start_add_inv_potion_mana_medium_destructive_medievalfantasy");
				 start_add_inv_potion_mana_large_destructive = cvar("g_start_add_inv_potion_mana_large_destructive_medievalfantasy");
				 start_add_inv_potion_rejuv_small_destructive = cvar("g_start_add_inv_potion_rejuv_small_destructive_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_destructive = cvar("g_start_add_inv_potion_rejuv_medium_destructive_medievalfantasy");
				 start_add_inv_potion_rejuv_large_destructive = cvar("g_start_add_inv_potion_rejuv_large_destructive_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_heavyweapons = cvar("g_start_add_ammo_shells_playerclass_heavyweapons_medievalfantasy");
				 start_add_ammo_nails_playerclass_heavyweapons = cvar("g_start_add_ammo_nails_playerclass_heavyweapons_medievalfantasy");
				 start_add_ammo_rockets_playerclass_heavyweapons = cvar("g_start_add_ammo_rockets_playerclass_heavyweapons_medievalfantasy");
				 start_add_ammo_cells_playerclass_heavyweapons = cvar("g_start_add_ammo_cells_playerclass_heavyweapons_medievalfantasy");
				 start_add_ammo_fuel_playerclass_heavyweapons = cvar("g_start_add_ammo_fuel_playerclass_heavyweapons_medievalfantasy");
				 start_add_health_playerclass_heavyweapons = cvar("g_start_add_health_playerclass_heavyweapons_medievalfantasy");
				 start_add_armorvalue_playerclass_heavyweapons = cvar("g_start_add_armorvalue_playerclass_heavyweapons_medievalfantasy");
				 start_add_mana_playerclass_heavyweapons = cvar("g_start_add_mana_playerclass_heavyweapons_medievalfantasy");
				 start_add_grenades_playerclass_heavyweapons = cvar("g_start_add_grenades_playerclass_heavyweapons_medievalfantasy");
				 start_add_flashbangs_playerclass_heavyweapons = cvar("g_start_add_flashbangs_playerclass_heavyweapons_medievalfantasy");
				 start_add_smokenades_playerclass_heavyweapons = cvar("g_start_add_smokenades_playerclass_heavyweapons_medievalfantasy");
				 start_add_fragnades_playerclass_heavyweapons = cvar("g_start_add_fragnades_playerclass_heavyweapons_medievalfantasy");
				 start_add_atmines_playerclass_heavyweapons = cvar("g_start_add_atmines_playerclass_heavyweapons_medievalfantasy");
				 start_add_landmines_playerclass_heavyweapons = cvar("g_start_add_landmines_playerclass_heavyweapons_medievalfantasy");
				 start_add_inv_potion_health_small_heavyweapons = cvar("g_start_add_inv_potion_health_small_heavyweapons_medievalfantasy");
				 start_add_inv_potion_health_medium_heavyweapons = cvar("g_start_add_inv_potion_health_medium_heavyweapons_medievalfantasy");
				 start_add_inv_potion_health_large_heavyweapons = cvar("g_start_add_inv_potion_health_large_heavyweapons_medievalfantasy");
				 start_add_inv_potion_mana_small_heavyweapons = cvar("g_start_add_inv_potion_mana_small_heavyweapons_medievalfantasy");
				 start_add_inv_potion_mana_medium_heavyweapons = cvar("g_start_add_inv_potion_mana_medium_heavyweapons_medievalfantasy");
				 start_add_inv_potion_mana_large_heavyweapons = cvar("g_start_add_inv_potion_mana_large_heavyweapons_medievalfantasy");
				 start_add_inv_potion_rejuv_small_heavyweapons = cvar("g_start_add_inv_potion_rejuv_small_heavyweapons_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_heavyweapons = cvar("g_start_add_inv_potion_rejuv_medium_heavyweapons_medievalfantasy");
				 start_add_inv_potion_rejuv_large_heavyweapons = cvar("g_start_add_inv_potion_rejuv_large_heavyweapons_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_pyromaniac = cvar("g_start_add_ammo_shells_playerclass_pyromaniac_medievalfantasy");
				 start_add_ammo_nails_playerclass_pyromaniac = cvar("g_start_add_ammo_nails_playerclass_pyromaniac_medievalfantasy");
				 start_add_ammo_rockets_playerclass_pyromaniac = cvar("g_start_add_ammo_rockets_playerclass_pyromaniac_medievalfantasy");
				 start_add_ammo_cells_playerclass_pyromaniac = cvar("g_start_add_ammo_cells_playerclass_pyromaniac_medievalfantasy");
				 start_add_ammo_fuel_playerclass_pyromaniac = cvar("g_start_add_ammo_fuel_playerclass_pyromaniac_medievalfantasy");
				 start_add_health_playerclass_pyromaniac = cvar("g_start_add_health_playerclass_pyromaniac_medievalfantasy");
				 start_add_armorvalue_playerclass_pyromaniac = cvar("g_start_add_armorvalue_playerclass_pyromaniac_medievalfantasy");
				 start_add_mana_playerclass_pyromaniac = cvar("g_start_add_mana_playerclass_pyromaniac_medievalfantasy");
				 start_add_grenades_playerclass_pyromaniac = cvar("g_start_add_grenades_playerclass_pyromaniac_medievalfantasy");
				 start_add_flashbangs_playerclass_pyromaniac = cvar("g_start_add_flashbangs_playerclass_pyromaniac_medievalfantasy");
				 start_add_smokenades_playerclass_pyromaniac = cvar("g_start_add_smokenades_playerclass_pyromaniac_medievalfantasy");
				 start_add_fragnades_playerclass_pyromaniac = cvar("g_start_add_fragnades_playerclass_pyromaniac_medievalfantasy");
				 start_add_atmines_playerclass_pyromaniac = cvar("g_start_add_atmines_playerclass_pyromaniac_medievalfantasy");
				 start_add_landmines_playerclass_pyromaniac = cvar("g_start_add_landmines_playerclass_pyromaniac_medievalfantasy");
				 start_add_inv_potion_health_small_pyromaniac = cvar("g_start_add_inv_potion_health_small_pyromaniac_medievalfantasy");
				 start_add_inv_potion_health_medium_pyromaniac = cvar("g_start_add_inv_potion_health_medium_pyromaniac_medievalfantasy");
				 start_add_inv_potion_health_large_pyromaniac = cvar("g_start_add_inv_potion_health_large_pyromaniac_medievalfantasy");
				 start_add_inv_potion_mana_small_pyromaniac = cvar("g_start_add_inv_potion_mana_small_pyromaniac_medievalfantasy");
				 start_add_inv_potion_mana_medium_pyromaniac = cvar("g_start_add_inv_potion_mana_medium_pyromaniac_medievalfantasy");
				 start_add_inv_potion_mana_large_pyromaniac = cvar("g_start_add_inv_potion_mana_large_pyromaniac_medievalfantasy");
				 start_add_inv_potion_rejuv_small_pyromaniac = cvar("g_start_add_inv_potion_rejuv_small_pyromaniac_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_pyromaniac = cvar("g_start_add_inv_potion_rejuv_medium_pyromaniac_medievalfantasy");
				 start_add_inv_potion_rejuv_large_pyromaniac = cvar("g_start_add_inv_potion_rejuv_large_pyromaniac_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_engineer = cvar("g_start_add_ammo_shells_playerclass_engineer_medievalfantasy");
				 start_add_ammo_nails_playerclass_engineer = cvar("g_start_add_ammo_nails_playerclass_engineer_medievalfantasy");
				 start_add_ammo_rockets_playerclass_engineer = cvar("g_start_add_ammo_rockets_playerclass_engineer_medievalfantasy");
				 start_add_ammo_cells_playerclass_engineer = cvar("g_start_add_ammo_cells_playerclass_engineer_medievalfantasy");
				 start_add_ammo_fuel_playerclass_engineer = cvar("g_start_add_ammo_fuel_playerclass_engineer_medievalfantasy");
				 start_add_health_playerclass_engineer = cvar("g_start_add_health_playerclass_engineer_medievalfantasy");
				 start_add_armorvalue_playerclass_engineer = cvar("g_start_add_armorvalue_playerclass_engineer_medievalfantasy");
				 start_add_mana_playerclass_engineer = cvar("g_start_add_mana_playerclass_engineer_medievalfantasy");
				 start_add_grenades_playerclass_engineer = cvar("g_start_add_grenades_playerclass_engineer_medievalfantasy");
				 start_add_flashbangs_playerclass_engineer = cvar("g_start_add_flashbangs_playerclass_engineer_medievalfantasy");
				 start_add_smokenades_playerclass_engineer = cvar("g_start_add_smokenades_playerclass_engineer_medievalfantasy");
				 start_add_fragnades_playerclass_engineer = cvar("g_start_add_fragnades_playerclass_engineer_medievalfantasy");
				 start_add_atmines_playerclass_engineer = cvar("g_start_add_atmines_playerclass_engineer_medievalfantasy");
				 start_add_landmines_playerclass_engineer = cvar("g_start_add_landmines_playerclass_engineer_medievalfantasy");
				 start_add_inv_potion_health_small_engineer = cvar("g_start_add_inv_potion_health_small_engineer_medievalfantasy");
				 start_add_inv_potion_health_medium_engineer = cvar("g_start_add_inv_potion_health_medium_engineer_medievalfantasy");
				 start_add_inv_potion_health_large_engineer = cvar("g_start_add_inv_potion_health_large_engineer_medievalfantasy");
				 start_add_inv_potion_mana_small_engineer = cvar("g_start_add_inv_potion_mana_small_engineer_medievalfantasy");
				 start_add_inv_potion_mana_medium_engineer = cvar("g_start_add_inv_potion_mana_medium_engineer_medievalfantasy");
				 start_add_inv_potion_mana_large_engineer = cvar("g_start_add_inv_potion_mana_large_engineer_medievalfantasy");
				 start_add_inv_potion_rejuv_small_engineer = cvar("g_start_add_inv_potion_rejuv_small_engineer_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_engineer = cvar("g_start_add_inv_potion_rejuv_medium_engineer_medievalfantasy");
				 start_add_inv_potion_rejuv_large_engineer = cvar("g_start_add_inv_potion_rejuv_large_engineer_medievalfantasy");

				 
				 
				 start_add_ammo_shells_playerclass_worker = cvar("g_start_add_ammo_shells_playerclass_worker_medievalfantasy");
				 start_add_ammo_nails_playerclass_worker = cvar("g_start_add_ammo_nails_playerclass_worker_medievalfantasy");
				 start_add_ammo_rockets_playerclass_worker = cvar("g_start_add_ammo_rockets_playerclass_worker_medievalfantasy");
				 start_add_ammo_cells_playerclass_worker = cvar("g_start_add_ammo_cells_playerclass_worker_medievalfantasy");
				 start_add_ammo_fuel_playerclass_worker = cvar("g_start_add_ammo_fuel_playerclass_worker_medievalfantasy");
				 start_add_health_playerclass_worker = cvar("g_start_add_health_playerclass_worker_medievalfantasy");
				 start_add_armorvalue_playerclass_worker = cvar("g_start_add_armorvalue_playerclass_worker_medievalfantasy");
				 start_add_mana_playerclass_worker = cvar("g_start_add_mana_playerclass_worker_medievalfantasy");
				 start_add_grenades_playerclass_worker = cvar("g_start_add_grenades_playerclass_worker_medievalfantasy");
				 start_add_flashbangs_playerclass_worker = cvar("g_start_add_flashbangs_playerclass_worker_medievalfantasy");
				 start_add_smokenades_playerclass_worker = cvar("g_start_add_smokenades_playerclass_worker_medievalfantasy");
				 start_add_fragnades_playerclass_worker = cvar("g_start_add_fragnades_playerclass_worker_medievalfantasy");
				 start_add_atmines_playerclass_worker = cvar("g_start_add_atmines_playerclass_worker_medievalfantasy");
				 start_add_landmines_playerclass_worker = cvar("g_start_add_landmines_playerclass_worker_medievalfantasy");
				 start_add_inv_potion_health_small_worker = cvar("g_start_add_inv_potion_health_small_worker_medievalfantasy");
				 start_add_inv_potion_health_medium_worker = cvar("g_start_add_inv_potion_health_medium_worker_medievalfantasy");
				 start_add_inv_potion_health_large_worker = cvar("g_start_add_inv_potion_health_large_worker_medievalfantasy");
				 start_add_inv_potion_mana_small_worker = cvar("g_start_add_inv_potion_mana_small_worker_medievalfantasy");
				 start_add_inv_potion_mana_medium_worker = cvar("g_start_add_inv_potion_mana_medium_worker_medievalfantasy");
				 start_add_inv_potion_mana_large_worker = cvar("g_start_add_inv_potion_mana_large_worker_medievalfantasy");
				 start_add_inv_potion_rejuv_small_worker = cvar("g_start_add_inv_potion_rejuv_small_worker_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_worker = cvar("g_start_add_inv_potion_rejuv_medium_worker_medievalfantasy");
				 start_add_inv_potion_rejuv_large_worker = cvar("g_start_add_inv_potion_rejuv_large_worker_medievalfantasy");

				 
				 start_add_ammo_shells_playerclass_healer = cvar("g_start_add_ammo_shells_playerclass_healer_medievalfantasy");
				 start_add_ammo_nails_playerclass_healer = cvar("g_start_add_ammo_nails_playerclass_healer_medievalfantasy");
				 start_add_ammo_rockets_playerclass_healer = cvar("g_start_add_ammo_rockets_playerclass_healer_medievalfantasy");
				 start_add_ammo_cells_playerclass_healer = cvar("g_start_add_ammo_cells_playerclass_healer_medievalfantasy");
				 start_add_ammo_fuel_playerclass_healer = cvar("g_start_add_ammo_fuel_playerclass_healer_medievalfantasy");
				 start_add_health_playerclass_healer = cvar("g_start_add_health_playerclass_healer_medievalfantasy");
				 start_add_armorvalue_playerclass_healer = cvar("g_start_add_armorvalue_playerclass_healer_medievalfantasy");
				 start_add_mana_playerclass_healer = cvar("g_start_add_mana_playerclass_healer_medievalfantasy");
				 start_add_grenades_playerclass_healer = cvar("g_start_add_grenades_playerclass_healer_medievalfantasy");
				 start_add_flashbangs_playerclass_healer = cvar("g_start_add_flashbangs_playerclass_healer_medievalfantasy");
				 start_add_smokenades_playerclass_healer = cvar("g_start_add_smokenades_playerclass_healer_medievalfantasy");
				 start_add_fragnades_playerclass_healer = cvar("g_start_add_fragnades_playerclass_healer_medievalfantasy");
				 start_add_atmines_playerclass_healer = cvar("g_start_add_atmines_playerclass_healer_medievalfantasy");
				 start_add_landmines_playerclass_healer = cvar("g_start_add_landmines_playerclass_healer_medievalfantasy");
				 start_add_inv_potion_health_small_healer = cvar("g_start_add_inv_potion_health_small_healer_medievalfantasy");
				 start_add_inv_potion_health_medium_healer = cvar("g_start_add_inv_potion_health_medium_healer_medievalfantasy");
				 start_add_inv_potion_health_large_healer = cvar("g_start_add_inv_potion_health_large_healer_medievalfantasy");
				 start_add_inv_potion_mana_small_healer = cvar("g_start_add_inv_potion_mana_small_healer_medievalfantasy");
				 start_add_inv_potion_mana_medium_healer = cvar("g_start_add_inv_potion_mana_medium_healer_medievalfantasy");
				 start_add_inv_potion_mana_large_healer = cvar("g_start_add_inv_potion_mana_large_healer_medievalfantasy");
				 start_add_inv_potion_rejuv_small_healer = cvar("g_start_add_inv_potion_rejuv_small_healer_medievalfantasy");
				 start_add_inv_potion_rejuv_medium_healer = cvar("g_start_add_inv_potion_rejuv_medium_healer_medievalfantasy");
				 start_add_inv_potion_rejuv_large_healer = cvar("g_start_add_inv_potion_rejuv_large_healer_medievalfantasy");

				 
			} else if (mypcselection == PLAYERCLASSSET_OLDWEST) {
				playerclassset = mypcselection;
				wepsetfromcvar_playerclass_longdistance("g_playerclass_weapons_longdistance_oldwest");
				wepsetfromcvar_playerclass_marksman("g_playerclass_weapons_marksman_oldwest");
				wepsetfromcvar_playerclass_mediumdistance("g_playerclass_weapons_mediumdistance_oldwest");
				wepsetfromcvar_playerclass_assault("g_playerclass_weapons_assault_oldwest");
				wepsetfromcvar_playerclass_closerange("g_playerclass_weapons_closerange_oldwest");
				wepsetfromcvar_playerclass_destructive("g_playerclass_weapons_destructive_oldwest");
				wepsetfromcvar_playerclass_heavyweapons("g_playerclass_weapons_heavyweapons_oldwest");
				wepsetfromcvar_playerclass_pyromaniac("g_playerclass_weapons_pyromaniac_oldwest");
				wepsetfromcvar_playerclass_engineer("g_playerclass_weapons_engineer_oldwest");
				wepsetfromcvar_playerclass_worker("g_playerclass_weapons_worker_oldwest");
				wepsetfromcvar_playerclass_healer("g_playerclass_weapons_healer_oldwest");
				
				//Ammo
				 start_add_ammo_shells_playerclass_longdistance = cvar("g_start_add_ammo_shells_playerclass_longdistance_oldwest");
				 start_add_ammo_nails_playerclass_longdistance = cvar("g_start_add_ammo_nails_playerclass_longdistance_oldwest");
				 start_add_ammo_rockets_playerclass_longdistance = cvar("g_start_add_ammo_rockets_playerclass_longdistance_oldwest");
				 start_add_ammo_cells_playerclass_longdistance = cvar("g_start_add_ammo_cells_playerclass_longdistance_oldwest");
				 start_add_ammo_fuel_playerclass_longdistance = cvar("g_start_add_ammo_fuel_playerclass_longdistance_oldwest");
				 start_add_health_playerclass_longdistance = cvar("g_start_add_health_playerclass_longdistance_oldwest");
				 start_add_armorvalue_playerclass_longdistance = cvar("g_start_add_armorvalue_playerclass_longdistance_oldwest");
				 start_add_mana_playerclass_longdistance = cvar("g_start_add_mana_playerclass_longdistance_oldwest");
				 start_add_grenades_playerclass_longdistance = cvar("g_start_add_grenades_playerclass_longdistance_oldwest");
				 start_add_flashbangs_playerclass_longdistance = cvar("g_start_add_flashbangs_playerclass_longdistance_oldwest");
				 start_add_smokenades_playerclass_longdistance = cvar("g_start_add_smokenades_playerclass_longdistance_oldwest");
				 start_add_fragnades_playerclass_longdistance = cvar("g_start_add_fragnades_playerclass_longdistance_oldwest");
				 start_add_atmines_playerclass_longdistance = cvar("g_start_add_atmines_playerclass_longdistance_oldwest");
				 start_add_landmines_playerclass_longdistance = cvar("g_start_add_landmines_playerclass_longdistance_oldwest");
				 start_add_inv_potion_health_small_longdistance = cvar("g_start_add_inv_potion_health_small_longdistance_oldwest");
				 start_add_inv_potion_health_medium_longdistance = cvar("g_start_add_inv_potion_health_medium_longdistance_oldwest");
				 start_add_inv_potion_health_large_longdistance = cvar("g_start_add_inv_potion_health_large_longdistance_oldwest");
				 start_add_inv_potion_mana_small_longdistance = cvar("g_start_add_inv_potion_mana_small_longdistance_oldwest");
				 start_add_inv_potion_mana_medium_longdistance = cvar("g_start_add_inv_potion_mana_medium_longdistance_oldwest");
				 start_add_inv_potion_mana_large_longdistance = cvar("g_start_add_inv_potion_mana_large_longdistance_oldwest");
				 start_add_inv_potion_rejuv_small_longdistance = cvar("g_start_add_inv_potion_rejuv_small_longdistance_oldwest");
				 start_add_inv_potion_rejuv_medium_longdistance = cvar("g_start_add_inv_potion_rejuv_medium_longdistance_oldwest");
				 start_add_inv_potion_rejuv_large_longdistance = cvar("g_start_add_inv_potion_rejuv_large_longdistance_oldwest");


				 start_add_ammo_shells_playerclass_marksman = cvar("g_start_add_ammo_shells_playerclass_marksman_oldwest");
				 start_add_ammo_nails_playerclass_marksman = cvar("g_start_add_ammo_nails_playerclass_marksman_oldwest");
				 start_add_ammo_rockets_playerclass_marksman = cvar("g_start_add_ammo_rockets_playerclass_marksman_oldwest");
				 start_add_ammo_cells_playerclass_marksman = cvar("g_start_add_ammo_cells_playerclass_marksman_oldwest");
				 start_add_ammo_fuel_playerclass_marksman = cvar("g_start_add_ammo_fuel_playerclass_marksman_oldwest");
				 start_add_health_playerclass_marksman = cvar("g_start_add_health_playerclass_marksman_oldwest");
				 start_add_armorvalue_playerclass_marksman = cvar("g_start_add_armorvalue_playerclass_marksman_oldwest");
				 start_add_mana_playerclass_marksman = cvar("g_start_add_mana_playerclass_marksman_oldwest");
				 start_add_grenades_playerclass_marksman = cvar("g_start_add_grenades_playerclass_marksman_oldwest");
				 start_add_flashbangs_playerclass_marksman = cvar("g_start_add_flashbangs_playerclass_marksman_oldwest");
				 start_add_smokenades_playerclass_marksman = cvar("g_start_add_smokenades_playerclass_marksman_oldwest");
				 start_add_fragnades_playerclass_marksman = cvar("g_start_add_fragnades_playerclass_marksman_oldwest");
				 start_add_atmines_playerclass_marksman = cvar("g_start_add_atmines_playerclass_marksman_oldwest");
				 start_add_landmines_playerclass_marksman = cvar("g_start_add_landmines_playerclass_marksman_oldwest");
				 start_add_inv_potion_health_small_marksman = cvar("g_start_add_inv_potion_health_small_marksman_oldwest");
				 start_add_inv_potion_health_medium_marksman = cvar("g_start_add_inv_potion_health_medium_marksman_oldwest");
				 start_add_inv_potion_health_large_marksman = cvar("g_start_add_inv_potion_health_large_marksman_oldwest");
				 start_add_inv_potion_mana_small_marksman = cvar("g_start_add_inv_potion_mana_small_marksman_oldwest");
				 start_add_inv_potion_mana_medium_marksman = cvar("g_start_add_inv_potion_mana_medium_marksman_oldwest");
				 start_add_inv_potion_mana_large_marksman = cvar("g_start_add_inv_potion_mana_large_marksman_oldwest");
				 start_add_inv_potion_rejuv_small_marksman = cvar("g_start_add_inv_potion_rejuv_small_marksman_oldwest");
				 start_add_inv_potion_rejuv_medium_marksman = cvar("g_start_add_inv_potion_rejuv_medium_marksman_oldwest");
				 start_add_inv_potion_rejuv_large_marksman = cvar("g_start_add_inv_potion_rejuv_large_marksman_oldwest");


				 start_add_ammo_shells_playerclass_mediumdistance = cvar("g_start_add_ammo_shells_playerclass_mediumdistance_oldwest");
				 start_add_ammo_nails_playerclass_mediumdistance = cvar("g_start_add_ammo_nails_playerclass_mediumdistance_oldwest");
				 start_add_ammo_rockets_playerclass_mediumdistance = cvar("g_start_add_ammo_rockets_playerclass_mediumdistance_oldwest");
				 start_add_ammo_cells_playerclass_mediumdistance = cvar("g_start_add_ammo_cells_playerclass_mediumdistance_oldwest");
				 start_add_ammo_fuel_playerclass_mediumdistance = cvar("g_start_add_ammo_fuel_playerclass_mediumdistance_oldwest");
				 start_add_health_playerclass_mediumdistance = cvar("g_start_add_health_playerclass_mediumdistance_oldwest");
				 start_add_armorvalue_playerclass_mediumdistance = cvar("g_start_add_armorvalue_playerclass_mediumdistance_oldwest");
				 start_add_mana_playerclass_mediumdistance = cvar("g_start_add_mana_playerclass_mediumdistance_oldwest");
				 start_add_grenades_playerclass_mediumdistance = cvar("g_start_add_grenades_playerclass_mediumdistance_oldwest");
				 start_add_flashbangs_playerclass_mediumdistance = cvar("g_start_add_flashbangs_playerclass_mediumdistance_oldwest");
				 start_add_smokenades_playerclass_mediumdistance = cvar("g_start_add_smokenades_playerclass_mediumdistance_oldwest");
				 start_add_fragnades_playerclass_mediumdistance = cvar("g_start_add_fragnades_playerclass_mediumdistance_oldwest");
				 start_add_atmines_playerclass_mediumdistance = cvar("g_start_add_atmines_playerclass_mediumdistance_oldwest");
				 start_add_landmines_playerclass_mediumdistance = cvar("g_start_add_landmines_playerclass_mediumdistance_oldwest");
				 start_add_inv_potion_health_small_mediumdistance = cvar("g_start_add_inv_potion_health_small_mediumdistance_oldwest");
				 start_add_inv_potion_health_medium_mediumdistance = cvar("g_start_add_inv_potion_health_medium_mediumdistance_oldwest");
				 start_add_inv_potion_health_large_mediumdistance = cvar("g_start_add_inv_potion_health_large_mediumdistance_oldwest");
				 start_add_inv_potion_mana_small_mediumdistance = cvar("g_start_add_inv_potion_mana_small_mediumdistance_oldwest");
				 start_add_inv_potion_mana_medium_mediumdistance = cvar("g_start_add_inv_potion_mana_medium_mediumdistance_oldwest");
				 start_add_inv_potion_mana_large_mediumdistance = cvar("g_start_add_inv_potion_mana_large_mediumdistance_oldwest");
				 start_add_inv_potion_rejuv_small_mediumdistance = cvar("g_start_add_inv_potion_rejuv_small_mediumdistance_oldwest");
				 start_add_inv_potion_rejuv_medium_mediumdistance = cvar("g_start_add_inv_potion_rejuv_medium_mediumdistance_oldwest");
				 start_add_inv_potion_rejuv_large_mediumdistance = cvar("g_start_add_inv_potion_rejuv_large_mediumdistance_oldwest");

				 
				 start_add_ammo_shells_playerclass_assault = cvar("g_start_add_ammo_shells_playerclass_assault_oldwest");
				 start_add_ammo_nails_playerclass_assault = cvar("g_start_add_ammo_nails_playerclass_assault_oldwest");
				 start_add_ammo_rockets_playerclass_assault = cvar("g_start_add_ammo_rockets_playerclass_assault_oldwest");
				 start_add_ammo_cells_playerclass_assault = cvar("g_start_add_ammo_cells_playerclass_assault_oldwest");
				 start_add_ammo_fuel_playerclass_assault = cvar("g_start_add_ammo_fuel_playerclass_assault_oldwest");
				 start_add_health_playerclass_assault = cvar("g_start_add_health_playerclass_assault_oldwest");
				 start_add_armorvalue_playerclass_assault = cvar("g_start_add_armorvalue_playerclass_assault_oldwest");
				 start_add_mana_playerclass_assault = cvar("g_start_add_mana_playerclass_assault_oldwest");
				 start_add_grenades_playerclass_assault = cvar("g_start_add_grenades_playerclass_assault_oldwest");
				 start_add_flashbangs_playerclass_assault = cvar("g_start_add_flashbangs_playerclass_assault_oldwest");
				 start_add_smokenades_playerclass_assault = cvar("g_start_add_smokenades_playerclass_assault_oldwest");
				 start_add_fragnades_playerclass_assault = cvar("g_start_add_fragnades_playerclass_assault_oldwest");
				 start_add_atmines_playerclass_assault = cvar("g_start_add_atmines_playerclass_assault_oldwest");
				 start_add_landmines_playerclass_assault = cvar("g_start_add_landmines_playerclass_assault_oldwest");
				 start_add_inv_potion_health_small_assault = cvar("g_start_add_inv_potion_health_small_assault_oldwest");
				 start_add_inv_potion_health_medium_assault = cvar("g_start_add_inv_potion_health_medium_assault_oldwest");
				 start_add_inv_potion_health_large_assault = cvar("g_start_add_inv_potion_health_large_assault_oldwest");
				 start_add_inv_potion_mana_small_assault = cvar("g_start_add_inv_potion_mana_small_assault_oldwest");
				 start_add_inv_potion_mana_medium_assault = cvar("g_start_add_inv_potion_mana_medium_assault_oldwest");
				 start_add_inv_potion_mana_large_assault = cvar("g_start_add_inv_potion_mana_large_assault_oldwest");
				 start_add_inv_potion_rejuv_small_assault = cvar("g_start_add_inv_potion_rejuv_small_assault_oldwest");
				 start_add_inv_potion_rejuv_medium_assault = cvar("g_start_add_inv_potion_rejuv_medium_assault_oldwest");
				 start_add_inv_potion_rejuv_large_assault = cvar("g_start_add_inv_potion_rejuv_large_assault_oldwest");

				 


				 start_add_ammo_shells_playerclass_closerange = cvar("g_start_add_ammo_shells_playerclass_closerange_oldwest");
				 start_add_ammo_nails_playerclass_closerange = cvar("g_start_add_ammo_nails_playerclass_closerange_oldwest");
				 start_add_ammo_rockets_playerclass_closerange = cvar("g_start_add_ammo_rockets_playerclass_closerange_oldwest");
				 start_add_ammo_cells_playerclass_closerange = cvar("g_start_add_ammo_cells_playerclass_closerange_oldwest");
				 start_add_ammo_fuel_playerclass_closerange = cvar("g_start_add_ammo_fuel_playerclass_closerange_oldwest");
				 start_add_health_playerclass_closerange = cvar("g_start_add_health_playerclass_closerange_oldwest");
				 start_add_armorvalue_playerclass_closerange = cvar("g_start_add_armorvalue_playerclass_closerange_oldwest");
				 start_add_mana_playerclass_closerange = cvar("g_start_add_mana_playerclass_closerange_oldwest");
				 start_add_grenades_playerclass_closerange = cvar("g_start_add_grenades_playerclass_closerange_oldwest");
				 start_add_flashbangs_playerclass_closerange = cvar("g_start_add_flashbangs_playerclass_closerange_oldwest");
				 start_add_smokenades_playerclass_closerange = cvar("g_start_add_smokenades_playerclass_closerange_oldwest");
				 start_add_fragnades_playerclass_closerange = cvar("g_start_add_fragnades_playerclass_closerange_oldwest");
				 start_add_atmines_playerclass_closerange = cvar("g_start_add_atmines_playerclass_closerange_oldwest");
				 start_add_landmines_playerclass_closerange = cvar("g_start_add_landmines_playerclass_closerange_oldwest");
				 start_add_inv_potion_health_small_closerange = cvar("g_start_add_inv_potion_health_small_closerange_oldwest");
				 start_add_inv_potion_health_medium_closerange = cvar("g_start_add_inv_potion_health_medium_closerange_oldwest");
				 start_add_inv_potion_health_large_closerange = cvar("g_start_add_inv_potion_health_large_closerange_oldwest");
				 start_add_inv_potion_mana_small_closerange = cvar("g_start_add_inv_potion_mana_small_closerange_oldwest");
				 start_add_inv_potion_mana_medium_closerange = cvar("g_start_add_inv_potion_mana_medium_closerange_oldwest");
				 start_add_inv_potion_mana_large_closerange = cvar("g_start_add_inv_potion_mana_large_closerange_oldwest");
				 start_add_inv_potion_rejuv_small_closerange = cvar("g_start_add_inv_potion_rejuv_small_closerange_oldwest");
				 start_add_inv_potion_rejuv_medium_closerange = cvar("g_start_add_inv_potion_rejuv_medium_closerange_oldwest");
				 start_add_inv_potion_rejuv_large_closerange = cvar("g_start_add_inv_potion_rejuv_large_closerange_oldwest");

				 
				 start_add_ammo_shells_playerclass_destructive = cvar("g_start_add_ammo_shells_playerclass_destructive_oldwest");
				 start_add_ammo_nails_playerclass_destructive = cvar("g_start_add_ammo_nails_playerclass_destructive_oldwest");
				 start_add_ammo_rockets_playerclass_destructive = cvar("g_start_add_ammo_rockets_playerclass_destructive_oldwest");
				 start_add_ammo_cells_playerclass_destructive = cvar("g_start_add_ammo_cells_playerclass_destructive_oldwest");
				 start_add_ammo_fuel_playerclass_destructive = cvar("g_start_add_ammo_fuel_playerclass_destructive_oldwest");
				 start_add_health_playerclass_destructive = cvar("g_start_add_health_playerclass_destructive_oldwest");
				 start_add_armorvalue_playerclass_destructive = cvar("g_start_add_armorvalue_playerclass_destructive_oldwest");
				 start_add_mana_playerclass_destructive = cvar("g_start_add_mana_playerclass_destructive_oldwest");
				 start_add_grenades_playerclass_destructive = cvar("g_start_add_grenades_playerclass_destructive_oldwest");
				 start_add_flashbangs_playerclass_destructive = cvar("g_start_add_flashbangs_playerclass_destructive_oldwest");
				 start_add_smokenades_playerclass_destructive = cvar("g_start_add_smokenades_playerclass_destructive_oldwest");
				 start_add_fragnades_playerclass_destructive = cvar("g_start_add_fragnades_playerclass_destructive_oldwest");
				 start_add_atmines_playerclass_destructive = cvar("g_start_add_atmines_playerclass_destructive_oldwest");
				 start_add_landmines_playerclass_destructive = cvar("g_start_add_landmines_playerclass_destructive_oldwest");
				 start_add_inv_potion_health_small_destructive = cvar("g_start_add_inv_potion_health_small_destructive_oldwest");
				 start_add_inv_potion_health_medium_destructive = cvar("g_start_add_inv_potion_health_medium_destructive_oldwest");
				 start_add_inv_potion_health_large_destructive = cvar("g_start_add_inv_potion_health_large_destructive_oldwest");
				 start_add_inv_potion_mana_small_destructive = cvar("g_start_add_inv_potion_mana_small_destructive_oldwest");
				 start_add_inv_potion_mana_medium_destructive = cvar("g_start_add_inv_potion_mana_medium_destructive_oldwest");
				 start_add_inv_potion_mana_large_destructive = cvar("g_start_add_inv_potion_mana_large_destructive_oldwest");
				 start_add_inv_potion_rejuv_small_destructive = cvar("g_start_add_inv_potion_rejuv_small_destructive_oldwest");
				 start_add_inv_potion_rejuv_medium_destructive = cvar("g_start_add_inv_potion_rejuv_medium_destructive_oldwest");
				 start_add_inv_potion_rejuv_large_destructive = cvar("g_start_add_inv_potion_rejuv_large_destructive_oldwest");

				 
				 start_add_ammo_shells_playerclass_heavyweapons = cvar("g_start_add_ammo_shells_playerclass_heavyweapons_oldwest");
				 start_add_ammo_nails_playerclass_heavyweapons = cvar("g_start_add_ammo_nails_playerclass_heavyweapons_oldwest");
				 start_add_ammo_rockets_playerclass_heavyweapons = cvar("g_start_add_ammo_rockets_playerclass_heavyweapons_oldwest");
				 start_add_ammo_cells_playerclass_heavyweapons = cvar("g_start_add_ammo_cells_playerclass_heavyweapons_oldwest");
				 start_add_ammo_fuel_playerclass_heavyweapons = cvar("g_start_add_ammo_fuel_playerclass_heavyweapons_oldwest");
				 start_add_health_playerclass_heavyweapons = cvar("g_start_add_health_playerclass_heavyweapons_oldwest");
				 start_add_armorvalue_playerclass_heavyweapons = cvar("g_start_add_armorvalue_playerclass_heavyweapons_oldwest");
				 start_add_mana_playerclass_heavyweapons = cvar("g_start_add_mana_playerclass_heavyweapons_oldwest");
				 start_add_grenades_playerclass_heavyweapons = cvar("g_start_add_grenades_playerclass_heavyweapons_oldwest");
				 start_add_flashbangs_playerclass_heavyweapons = cvar("g_start_add_flashbangs_playerclass_heavyweapons_oldwest");
				 start_add_smokenades_playerclass_heavyweapons = cvar("g_start_add_smokenades_playerclass_heavyweapons_oldwest");
				 start_add_fragnades_playerclass_heavyweapons = cvar("g_start_add_fragnades_playerclass_heavyweapons_oldwest");
				 start_add_atmines_playerclass_heavyweapons = cvar("g_start_add_atmines_playerclass_heavyweapons_oldwest");
				 start_add_landmines_playerclass_heavyweapons = cvar("g_start_add_landmines_playerclass_heavyweapons_oldwest");
				 start_add_inv_potion_health_small_heavyweapons = cvar("g_start_add_inv_potion_health_small_heavyweapons_oldwest");
				 start_add_inv_potion_health_medium_heavyweapons = cvar("g_start_add_inv_potion_health_medium_heavyweapons_oldwest");
				 start_add_inv_potion_health_large_heavyweapons = cvar("g_start_add_inv_potion_health_large_heavyweapons_oldwest");
				 start_add_inv_potion_mana_small_heavyweapons = cvar("g_start_add_inv_potion_mana_small_heavyweapons_oldwest");
				 start_add_inv_potion_mana_medium_heavyweapons = cvar("g_start_add_inv_potion_mana_medium_heavyweapons_oldwest");
				 start_add_inv_potion_mana_large_heavyweapons = cvar("g_start_add_inv_potion_mana_large_heavyweapons_oldwest");
				 start_add_inv_potion_rejuv_small_heavyweapons = cvar("g_start_add_inv_potion_rejuv_small_heavyweapons_oldwest");
				 start_add_inv_potion_rejuv_medium_heavyweapons = cvar("g_start_add_inv_potion_rejuv_medium_heavyweapons_oldwest");
				 start_add_inv_potion_rejuv_large_heavyweapons = cvar("g_start_add_inv_potion_rejuv_large_heavyweapons_oldwest");

				 
				 start_add_ammo_shells_playerclass_pyromaniac = cvar("g_start_add_ammo_shells_playerclass_pyromaniac_oldwest");
				 start_add_ammo_nails_playerclass_pyromaniac = cvar("g_start_add_ammo_nails_playerclass_pyromaniac_oldwest");
				 start_add_ammo_rockets_playerclass_pyromaniac = cvar("g_start_add_ammo_rockets_playerclass_pyromaniac_oldwest");
				 start_add_ammo_cells_playerclass_pyromaniac = cvar("g_start_add_ammo_cells_playerclass_pyromaniac_oldwest");
				 start_add_ammo_fuel_playerclass_pyromaniac = cvar("g_start_add_ammo_fuel_playerclass_pyromaniac_oldwest");
				 start_add_health_playerclass_pyromaniac = cvar("g_start_add_health_playerclass_pyromaniac_oldwest");
				 start_add_armorvalue_playerclass_pyromaniac = cvar("g_start_add_armorvalue_playerclass_pyromaniac_oldwest");
				 start_add_mana_playerclass_pyromaniac = cvar("g_start_add_mana_playerclass_pyromaniac_oldwest");
				 start_add_grenades_playerclass_pyromaniac = cvar("g_start_add_grenades_playerclass_pyromaniac_oldwest");
				 start_add_flashbangs_playerclass_pyromaniac = cvar("g_start_add_flashbangs_playerclass_pyromaniac_oldwest");
				 start_add_smokenades_playerclass_pyromaniac = cvar("g_start_add_smokenades_playerclass_pyromaniac_oldwest");
				 start_add_fragnades_playerclass_pyromaniac = cvar("g_start_add_fragnades_playerclass_pyromaniac_oldwest");
				 start_add_atmines_playerclass_pyromaniac = cvar("g_start_add_atmines_playerclass_pyromaniac_oldwest");
				 start_add_landmines_playerclass_pyromaniac = cvar("g_start_add_landmines_playerclass_pyromaniac_oldwest");
				 start_add_inv_potion_health_small_pyromaniac = cvar("g_start_add_inv_potion_health_small_pyromaniac_oldwest");
				 start_add_inv_potion_health_medium_pyromaniac = cvar("g_start_add_inv_potion_health_medium_pyromaniac_oldwest");
				 start_add_inv_potion_health_large_pyromaniac = cvar("g_start_add_inv_potion_health_large_pyromaniac_oldwest");
				 start_add_inv_potion_mana_small_pyromaniac = cvar("g_start_add_inv_potion_mana_small_pyromaniac_oldwest");
				 start_add_inv_potion_mana_medium_pyromaniac = cvar("g_start_add_inv_potion_mana_medium_pyromaniac_oldwest");
				 start_add_inv_potion_mana_large_pyromaniac = cvar("g_start_add_inv_potion_mana_large_pyromaniac_oldwest");
				 start_add_inv_potion_rejuv_small_pyromaniac = cvar("g_start_add_inv_potion_rejuv_small_pyromaniac_oldwest");
				 start_add_inv_potion_rejuv_medium_pyromaniac = cvar("g_start_add_inv_potion_rejuv_medium_pyromaniac_oldwest");
				 start_add_inv_potion_rejuv_large_pyromaniac = cvar("g_start_add_inv_potion_rejuv_large_pyromaniac_oldwest");

				 
				 start_add_ammo_shells_playerclass_engineer = cvar("g_start_add_ammo_shells_playerclass_engineer_oldwest");
				 start_add_ammo_nails_playerclass_engineer = cvar("g_start_add_ammo_nails_playerclass_engineer_oldwest");
				 start_add_ammo_rockets_playerclass_engineer = cvar("g_start_add_ammo_rockets_playerclass_engineer_oldwest");
				 start_add_ammo_cells_playerclass_engineer = cvar("g_start_add_ammo_cells_playerclass_engineer_oldwest");
				 start_add_ammo_fuel_playerclass_engineer = cvar("g_start_add_ammo_fuel_playerclass_engineer_oldwest");
				 start_add_health_playerclass_engineer = cvar("g_start_add_health_playerclass_engineer_oldwest");
				 start_add_armorvalue_playerclass_engineer = cvar("g_start_add_armorvalue_playerclass_engineer_oldwest");
				 start_add_mana_playerclass_engineer = cvar("g_start_add_mana_playerclass_engineer_oldwest");
				 start_add_grenades_playerclass_engineer = cvar("g_start_add_grenades_playerclass_engineer_oldwest");
				 start_add_flashbangs_playerclass_engineer = cvar("g_start_add_flashbangs_playerclass_engineer_oldwest");
				 start_add_smokenades_playerclass_engineer = cvar("g_start_add_smokenades_playerclass_engineer_oldwest");
				 start_add_fragnades_playerclass_engineer = cvar("g_start_add_fragnades_playerclass_engineer_oldwest");
				 start_add_atmines_playerclass_engineer = cvar("g_start_add_atmines_playerclass_engineer_oldwest");
				 start_add_landmines_playerclass_engineer = cvar("g_start_add_landmines_playerclass_engineer_oldwest");
				 start_add_inv_potion_health_small_engineer = cvar("g_start_add_inv_potion_health_small_engineer_oldwest");
				 start_add_inv_potion_health_medium_engineer = cvar("g_start_add_inv_potion_health_medium_engineer_oldwest");
				 start_add_inv_potion_health_large_engineer = cvar("g_start_add_inv_potion_health_large_engineer_oldwest");
				 start_add_inv_potion_mana_small_engineer = cvar("g_start_add_inv_potion_mana_small_engineer_oldwest");
				 start_add_inv_potion_mana_medium_engineer = cvar("g_start_add_inv_potion_mana_medium_engineer_oldwest");
				 start_add_inv_potion_mana_large_engineer = cvar("g_start_add_inv_potion_mana_large_engineer_oldwest");
				 start_add_inv_potion_rejuv_small_engineer = cvar("g_start_add_inv_potion_rejuv_small_engineer_oldwest");
				 start_add_inv_potion_rejuv_medium_engineer = cvar("g_start_add_inv_potion_rejuv_medium_engineer_oldwest");
				 start_add_inv_potion_rejuv_large_engineer = cvar("g_start_add_inv_potion_rejuv_large_engineer_oldwest");

				 
				 
				 start_add_ammo_shells_playerclass_worker = cvar("g_start_add_ammo_shells_playerclass_worker_oldwest");
				 start_add_ammo_nails_playerclass_worker = cvar("g_start_add_ammo_nails_playerclass_worker_oldwest");
				 start_add_ammo_rockets_playerclass_worker = cvar("g_start_add_ammo_rockets_playerclass_worker_oldwest");
				 start_add_ammo_cells_playerclass_worker = cvar("g_start_add_ammo_cells_playerclass_worker_oldwest");
				 start_add_ammo_fuel_playerclass_worker = cvar("g_start_add_ammo_fuel_playerclass_worker_oldwest");
				 start_add_health_playerclass_worker = cvar("g_start_add_health_playerclass_worker_oldwest");
				 start_add_armorvalue_playerclass_worker = cvar("g_start_add_armorvalue_playerclass_worker_oldwest");
				 start_add_mana_playerclass_worker = cvar("g_start_add_mana_playerclass_worker_oldwest");
				 start_add_grenades_playerclass_worker = cvar("g_start_add_grenades_playerclass_worker_oldwest");
				 start_add_flashbangs_playerclass_worker = cvar("g_start_add_flashbangs_playerclass_worker_oldwest");
				 start_add_smokenades_playerclass_worker = cvar("g_start_add_smokenades_playerclass_worker_oldwest");
				 start_add_fragnades_playerclass_worker = cvar("g_start_add_fragnades_playerclass_worker_oldwest");
				 start_add_atmines_playerclass_worker = cvar("g_start_add_atmines_playerclass_worker_oldwest");
				 start_add_landmines_playerclass_worker = cvar("g_start_add_landmines_playerclass_worker_oldwest");
				 start_add_inv_potion_health_small_worker = cvar("g_start_add_inv_potion_health_small_worker_oldwest");
				 start_add_inv_potion_health_medium_worker = cvar("g_start_add_inv_potion_health_medium_worker_oldwest");
				 start_add_inv_potion_health_large_worker = cvar("g_start_add_inv_potion_health_large_worker_oldwest");
				 start_add_inv_potion_mana_small_worker = cvar("g_start_add_inv_potion_mana_small_worker_oldwest");
				 start_add_inv_potion_mana_medium_worker = cvar("g_start_add_inv_potion_mana_medium_worker_oldwest");
				 start_add_inv_potion_mana_large_worker = cvar("g_start_add_inv_potion_mana_large_worker_oldwest");
				 start_add_inv_potion_rejuv_small_worker = cvar("g_start_add_inv_potion_rejuv_small_worker_oldwest");
				 start_add_inv_potion_rejuv_medium_worker = cvar("g_start_add_inv_potion_rejuv_medium_worker_oldwest");
				 start_add_inv_potion_rejuv_large_worker = cvar("g_start_add_inv_potion_rejuv_large_worker_oldwest");

				 
				 start_add_ammo_shells_playerclass_healer = cvar("g_start_add_ammo_shells_playerclass_healer_oldwest");
				 start_add_ammo_nails_playerclass_healer = cvar("g_start_add_ammo_nails_playerclass_healer_oldwest");
				 start_add_ammo_rockets_playerclass_healer = cvar("g_start_add_ammo_rockets_playerclass_healer_oldwest");
				 start_add_ammo_cells_playerclass_healer = cvar("g_start_add_ammo_cells_playerclass_healer_oldwest");
				 start_add_ammo_fuel_playerclass_healer = cvar("g_start_add_ammo_fuel_playerclass_healer_oldwest");
				 start_add_health_playerclass_healer = cvar("g_start_add_health_playerclass_healer_oldwest");
				 start_add_armorvalue_playerclass_healer = cvar("g_start_add_armorvalue_playerclass_healer_oldwest");
				 start_add_mana_playerclass_healer = cvar("g_start_add_mana_playerclass_healer_oldwest");
				 start_add_grenades_playerclass_healer = cvar("g_start_add_grenades_playerclass_healer_oldwest");
				 start_add_flashbangs_playerclass_healer = cvar("g_start_add_flashbangs_playerclass_healer_oldwest");
				 start_add_smokenades_playerclass_healer = cvar("g_start_add_smokenades_playerclass_healer_oldwest");
				 start_add_fragnades_playerclass_healer = cvar("g_start_add_fragnades_playerclass_healer_oldwest");
				 start_add_atmines_playerclass_healer = cvar("g_start_add_atmines_playerclass_healer_oldwest");
				 start_add_landmines_playerclass_healer = cvar("g_start_add_landmines_playerclass_healer_oldwest");
				 start_add_inv_potion_health_small_healer = cvar("g_start_add_inv_potion_health_small_healer_oldwest");
				 start_add_inv_potion_health_medium_healer = cvar("g_start_add_inv_potion_health_medium_healer_oldwest");
				 start_add_inv_potion_health_large_healer = cvar("g_start_add_inv_potion_health_large_healer_oldwest");
				 start_add_inv_potion_mana_small_healer = cvar("g_start_add_inv_potion_mana_small_healer_oldwest");
				 start_add_inv_potion_mana_medium_healer = cvar("g_start_add_inv_potion_mana_medium_healer_oldwest");
				 start_add_inv_potion_mana_large_healer = cvar("g_start_add_inv_potion_mana_large_healer_oldwest");
				 start_add_inv_potion_rejuv_small_healer = cvar("g_start_add_inv_potion_rejuv_small_healer_oldwest");
				 start_add_inv_potion_rejuv_medium_healer = cvar("g_start_add_inv_potion_rejuv_medium_healer_oldwest");
				 start_add_inv_potion_rejuv_large_healer = cvar("g_start_add_inv_potion_rejuv_large_healer_oldwest");

				 
			}  else if (mypcselection == PLAYERCLASSSET_XON) {
				playerclassset = mypcselection;
				wepsetfromcvar_playerclass_longdistance("g_playerclass_weapons_longdistance_xon");
				wepsetfromcvar_playerclass_marksman("g_playerclass_weapons_marksman_xon");
				wepsetfromcvar_playerclass_mediumdistance("g_playerclass_weapons_mediumdistance_xon");
				wepsetfromcvar_playerclass_assault("g_playerclass_weapons_assault_xon");
				wepsetfromcvar_playerclass_closerange("g_playerclass_weapons_closerange_xon");
				wepsetfromcvar_playerclass_destructive("g_playerclass_weapons_destructive_xon");
				wepsetfromcvar_playerclass_heavyweapons("g_playerclass_weapons_heavyweapons_xon");
				wepsetfromcvar_playerclass_pyromaniac("g_playerclass_weapons_pyromaniac_xon");
				wepsetfromcvar_playerclass_engineer("g_playerclass_weapons_engineer_xon");
				wepsetfromcvar_playerclass_worker("g_playerclass_weapons_worker_xon");
				wepsetfromcvar_playerclass_healer("g_playerclass_weapons_healer_xon");
				
				//Ammo
				 start_add_ammo_shells_playerclass_longdistance = cvar("g_start_add_ammo_shells_playerclass_longdistance_xon");
				 start_add_ammo_nails_playerclass_longdistance = cvar("g_start_add_ammo_nails_playerclass_longdistance_xon");
				 start_add_ammo_rockets_playerclass_longdistance = cvar("g_start_add_ammo_rockets_playerclass_longdistance_xon");
				 start_add_ammo_cells_playerclass_longdistance = cvar("g_start_add_ammo_cells_playerclass_longdistance_xon");
				 start_add_ammo_fuel_playerclass_longdistance = cvar("g_start_add_ammo_fuel_playerclass_longdistance_xon");
				 start_add_health_playerclass_longdistance = cvar("g_start_add_health_playerclass_longdistance_xon");
				 start_add_armorvalue_playerclass_longdistance = cvar("g_start_add_armorvalue_playerclass_longdistance_xon");
				 start_add_mana_playerclass_longdistance = cvar("g_start_add_mana_playerclass_longdistance_xon");
				 start_add_grenades_playerclass_longdistance = cvar("g_start_add_grenades_playerclass_longdistance_xon");
				 start_add_flashbangs_playerclass_longdistance = cvar("g_start_add_flashbangs_playerclass_longdistance_xon");
				 start_add_smokenades_playerclass_longdistance = cvar("g_start_add_smokenades_playerclass_longdistance_xon");
				 start_add_fragnades_playerclass_longdistance = cvar("g_start_add_fragnades_playerclass_longdistance_xon");
				 start_add_atmines_playerclass_longdistance = cvar("g_start_add_atmines_playerclass_longdistance_xon");
				 start_add_landmines_playerclass_longdistance = cvar("g_start_add_landmines_playerclass_longdistance_xon");
				 start_add_inv_potion_health_small_longdistance = cvar("g_start_add_inv_potion_health_small_longdistance_xon");
				 start_add_inv_potion_health_medium_longdistance = cvar("g_start_add_inv_potion_health_medium_longdistance_xon");
				 start_add_inv_potion_health_large_longdistance = cvar("g_start_add_inv_potion_health_large_longdistance_xon");
				 start_add_inv_potion_mana_small_longdistance = cvar("g_start_add_inv_potion_mana_small_longdistance_xon");
				 start_add_inv_potion_mana_medium_longdistance = cvar("g_start_add_inv_potion_mana_medium_longdistance_xon");
				 start_add_inv_potion_mana_large_longdistance = cvar("g_start_add_inv_potion_mana_large_longdistance_xon");
				 start_add_inv_potion_rejuv_small_longdistance = cvar("g_start_add_inv_potion_rejuv_small_longdistance_xon");
				 start_add_inv_potion_rejuv_medium_longdistance = cvar("g_start_add_inv_potion_rejuv_medium_longdistance_xon");
				 start_add_inv_potion_rejuv_large_longdistance = cvar("g_start_add_inv_potion_rejuv_large_longdistance_xon");


				 start_add_ammo_shells_playerclass_marksman = cvar("g_start_add_ammo_shells_playerclass_marksman_xon");
				 start_add_ammo_nails_playerclass_marksman = cvar("g_start_add_ammo_nails_playerclass_marksman_xon");
				 start_add_ammo_rockets_playerclass_marksman = cvar("g_start_add_ammo_rockets_playerclass_marksman_xon");
				 start_add_ammo_cells_playerclass_marksman = cvar("g_start_add_ammo_cells_playerclass_marksman_xon");
				 start_add_ammo_fuel_playerclass_marksman = cvar("g_start_add_ammo_fuel_playerclass_marksman_xon");
				 start_add_health_playerclass_marksman = cvar("g_start_add_health_playerclass_marksman_xon");
				 start_add_armorvalue_playerclass_marksman = cvar("g_start_add_armorvalue_playerclass_marksman_xon");
				 start_add_mana_playerclass_marksman = cvar("g_start_add_mana_playerclass_marksman_xon");
				 start_add_grenades_playerclass_marksman = cvar("g_start_add_grenades_playerclass_marksman_xon");
				 start_add_flashbangs_playerclass_marksman = cvar("g_start_add_flashbangs_playerclass_marksman_xon");
				 start_add_smokenades_playerclass_marksman = cvar("g_start_add_smokenades_playerclass_marksman_xon");
				 start_add_fragnades_playerclass_marksman = cvar("g_start_add_fragnades_playerclass_marksman_xon");
				 start_add_atmines_playerclass_marksman = cvar("g_start_add_atmines_playerclass_marksman_xon");
				 start_add_landmines_playerclass_marksman = cvar("g_start_add_landmines_playerclass_marksman_xon");
				 start_add_inv_potion_health_small_marksman = cvar("g_start_add_inv_potion_health_small_marksman_xon");
				 start_add_inv_potion_health_medium_marksman = cvar("g_start_add_inv_potion_health_medium_marksman_xon");
				 start_add_inv_potion_health_large_marksman = cvar("g_start_add_inv_potion_health_large_marksman_xon");
				 start_add_inv_potion_mana_small_marksman = cvar("g_start_add_inv_potion_mana_small_marksman_xon");
				 start_add_inv_potion_mana_medium_marksman = cvar("g_start_add_inv_potion_mana_medium_marksman_xon");
				 start_add_inv_potion_mana_large_marksman = cvar("g_start_add_inv_potion_mana_large_marksman_xon");
				 start_add_inv_potion_rejuv_small_marksman = cvar("g_start_add_inv_potion_rejuv_small_marksman_xon");
				 start_add_inv_potion_rejuv_medium_marksman = cvar("g_start_add_inv_potion_rejuv_medium_marksman_xon");
				 start_add_inv_potion_rejuv_large_marksman = cvar("g_start_add_inv_potion_rejuv_large_marksman_xon");


				 start_add_ammo_shells_playerclass_mediumdistance = cvar("g_start_add_ammo_shells_playerclass_mediumdistance_xon");
				 start_add_ammo_nails_playerclass_mediumdistance = cvar("g_start_add_ammo_nails_playerclass_mediumdistance_xon");
				 start_add_ammo_rockets_playerclass_mediumdistance = cvar("g_start_add_ammo_rockets_playerclass_mediumdistance_xon");
				 start_add_ammo_cells_playerclass_mediumdistance = cvar("g_start_add_ammo_cells_playerclass_mediumdistance_xon");
				 start_add_ammo_fuel_playerclass_mediumdistance = cvar("g_start_add_ammo_fuel_playerclass_mediumdistance_xon");
				 start_add_health_playerclass_mediumdistance = cvar("g_start_add_health_playerclass_mediumdistance_xon");
				 start_add_armorvalue_playerclass_mediumdistance = cvar("g_start_add_armorvalue_playerclass_mediumdistance_xon");
				 start_add_mana_playerclass_mediumdistance = cvar("g_start_add_mana_playerclass_mediumdistance_xon");
				 start_add_grenades_playerclass_mediumdistance = cvar("g_start_add_grenades_playerclass_mediumdistance_xon");
				 start_add_flashbangs_playerclass_mediumdistance = cvar("g_start_add_flashbangs_playerclass_mediumdistance_xon");
				 start_add_smokenades_playerclass_mediumdistance = cvar("g_start_add_smokenades_playerclass_mediumdistance_xon");
				 start_add_fragnades_playerclass_mediumdistance = cvar("g_start_add_fragnades_playerclass_mediumdistance_xon");
				 start_add_atmines_playerclass_mediumdistance = cvar("g_start_add_atmines_playerclass_mediumdistance_xon");
				 start_add_landmines_playerclass_mediumdistance = cvar("g_start_add_landmines_playerclass_mediumdistance_xon");
				 start_add_inv_potion_health_small_mediumdistance = cvar("g_start_add_inv_potion_health_small_mediumdistance_xon");
				 start_add_inv_potion_health_medium_mediumdistance = cvar("g_start_add_inv_potion_health_medium_mediumdistance_xon");
				 start_add_inv_potion_health_large_mediumdistance = cvar("g_start_add_inv_potion_health_large_mediumdistance_xon");
				 start_add_inv_potion_mana_small_mediumdistance = cvar("g_start_add_inv_potion_mana_small_mediumdistance_xon");
				 start_add_inv_potion_mana_medium_mediumdistance = cvar("g_start_add_inv_potion_mana_medium_mediumdistance_xon");
				 start_add_inv_potion_mana_large_mediumdistance = cvar("g_start_add_inv_potion_mana_large_mediumdistance_xon");
				 start_add_inv_potion_rejuv_small_mediumdistance = cvar("g_start_add_inv_potion_rejuv_small_mediumdistance_xon");
				 start_add_inv_potion_rejuv_medium_mediumdistance = cvar("g_start_add_inv_potion_rejuv_medium_mediumdistance_xon");
				 start_add_inv_potion_rejuv_large_mediumdistance = cvar("g_start_add_inv_potion_rejuv_large_mediumdistance_xon");

				 
				 start_add_ammo_shells_playerclass_assault = cvar("g_start_add_ammo_shells_playerclass_assault_xon");
				 start_add_ammo_nails_playerclass_assault = cvar("g_start_add_ammo_nails_playerclass_assault_xon");
				 start_add_ammo_rockets_playerclass_assault = cvar("g_start_add_ammo_rockets_playerclass_assault_xon");
				 start_add_ammo_cells_playerclass_assault = cvar("g_start_add_ammo_cells_playerclass_assault_xon");
				 start_add_ammo_fuel_playerclass_assault = cvar("g_start_add_ammo_fuel_playerclass_assault_xon");
				 start_add_health_playerclass_assault = cvar("g_start_add_health_playerclass_assault_xon");
				 start_add_armorvalue_playerclass_assault = cvar("g_start_add_armorvalue_playerclass_assault_xon");
				 start_add_mana_playerclass_assault = cvar("g_start_add_mana_playerclass_assault_xon");
				 start_add_grenades_playerclass_assault = cvar("g_start_add_grenades_playerclass_assault_xon");
				 start_add_flashbangs_playerclass_assault = cvar("g_start_add_flashbangs_playerclass_assault_xon");
				 start_add_smokenades_playerclass_assault = cvar("g_start_add_smokenades_playerclass_assault_xon");
				 start_add_fragnades_playerclass_assault = cvar("g_start_add_fragnades_playerclass_assault_xon");
				 start_add_atmines_playerclass_assault = cvar("g_start_add_atmines_playerclass_assault_xon");
				 start_add_landmines_playerclass_assault = cvar("g_start_add_landmines_playerclass_assault_xon");
				 start_add_inv_potion_health_small_assault = cvar("g_start_add_inv_potion_health_small_assault_xon");
				 start_add_inv_potion_health_medium_assault = cvar("g_start_add_inv_potion_health_medium_assault_xon");
				 start_add_inv_potion_health_large_assault = cvar("g_start_add_inv_potion_health_large_assault_xon");
				 start_add_inv_potion_mana_small_assault = cvar("g_start_add_inv_potion_mana_small_assault_xon");
				 start_add_inv_potion_mana_medium_assault = cvar("g_start_add_inv_potion_mana_medium_assault_xon");
				 start_add_inv_potion_mana_large_assault = cvar("g_start_add_inv_potion_mana_large_assault_xon");
				 start_add_inv_potion_rejuv_small_assault = cvar("g_start_add_inv_potion_rejuv_small_assault_xon");
				 start_add_inv_potion_rejuv_medium_assault = cvar("g_start_add_inv_potion_rejuv_medium_assault_xon");
				 start_add_inv_potion_rejuv_large_assault = cvar("g_start_add_inv_potion_rejuv_large_assault_xon");

				 


				 start_add_ammo_shells_playerclass_closerange = cvar("g_start_add_ammo_shells_playerclass_closerange_xon");
				 start_add_ammo_nails_playerclass_closerange = cvar("g_start_add_ammo_nails_playerclass_closerange_xon");
				 start_add_ammo_rockets_playerclass_closerange = cvar("g_start_add_ammo_rockets_playerclass_closerange_xon");
				 start_add_ammo_cells_playerclass_closerange = cvar("g_start_add_ammo_cells_playerclass_closerange_xon");
				 start_add_ammo_fuel_playerclass_closerange = cvar("g_start_add_ammo_fuel_playerclass_closerange_xon");
				 start_add_health_playerclass_closerange = cvar("g_start_add_health_playerclass_closerange_xon");
				 start_add_armorvalue_playerclass_closerange = cvar("g_start_add_armorvalue_playerclass_closerange_xon");
				 start_add_mana_playerclass_closerange = cvar("g_start_add_mana_playerclass_closerange_xon");
				 start_add_grenades_playerclass_closerange = cvar("g_start_add_grenades_playerclass_closerange_xon");
				 start_add_flashbangs_playerclass_closerange = cvar("g_start_add_flashbangs_playerclass_closerange_xon");
				 start_add_smokenades_playerclass_closerange = cvar("g_start_add_smokenades_playerclass_closerange_xon");
				 start_add_fragnades_playerclass_closerange = cvar("g_start_add_fragnades_playerclass_closerange_xon");
				 start_add_atmines_playerclass_closerange = cvar("g_start_add_atmines_playerclass_closerange_xon");
				 start_add_landmines_playerclass_closerange = cvar("g_start_add_landmines_playerclass_closerange_xon");
				 start_add_inv_potion_health_small_closerange = cvar("g_start_add_inv_potion_health_small_closerange_xon");
				 start_add_inv_potion_health_medium_closerange = cvar("g_start_add_inv_potion_health_medium_closerange_xon");
				 start_add_inv_potion_health_large_closerange = cvar("g_start_add_inv_potion_health_large_closerange_xon");
				 start_add_inv_potion_mana_small_closerange = cvar("g_start_add_inv_potion_mana_small_closerange_xon");
				 start_add_inv_potion_mana_medium_closerange = cvar("g_start_add_inv_potion_mana_medium_closerange_xon");
				 start_add_inv_potion_mana_large_closerange = cvar("g_start_add_inv_potion_mana_large_closerange_xon");
				 start_add_inv_potion_rejuv_small_closerange = cvar("g_start_add_inv_potion_rejuv_small_closerange_xon");
				 start_add_inv_potion_rejuv_medium_closerange = cvar("g_start_add_inv_potion_rejuv_medium_closerange_xon");
				 start_add_inv_potion_rejuv_large_closerange = cvar("g_start_add_inv_potion_rejuv_large_closerange_xon");

				 
				 start_add_ammo_shells_playerclass_destructive = cvar("g_start_add_ammo_shells_playerclass_destructive_xon");
				 start_add_ammo_nails_playerclass_destructive = cvar("g_start_add_ammo_nails_playerclass_destructive_xon");
				 start_add_ammo_rockets_playerclass_destructive = cvar("g_start_add_ammo_rockets_playerclass_destructive_xon");
				 start_add_ammo_cells_playerclass_destructive = cvar("g_start_add_ammo_cells_playerclass_destructive_xon");
				 start_add_ammo_fuel_playerclass_destructive = cvar("g_start_add_ammo_fuel_playerclass_destructive_xon");
				 start_add_health_playerclass_destructive = cvar("g_start_add_health_playerclass_destructive_xon");
				 start_add_armorvalue_playerclass_destructive = cvar("g_start_add_armorvalue_playerclass_destructive_xon");
				 start_add_mana_playerclass_destructive = cvar("g_start_add_mana_playerclass_destructive_xon");
				 start_add_grenades_playerclass_destructive = cvar("g_start_add_grenades_playerclass_destructive_xon");
				 start_add_flashbangs_playerclass_destructive = cvar("g_start_add_flashbangs_playerclass_destructive_xon");
				 start_add_smokenades_playerclass_destructive = cvar("g_start_add_smokenades_playerclass_destructive_xon");
				 start_add_fragnades_playerclass_destructive = cvar("g_start_add_fragnades_playerclass_destructive_xon");
				 start_add_atmines_playerclass_destructive = cvar("g_start_add_atmines_playerclass_destructive_xon");
				 start_add_landmines_playerclass_destructive = cvar("g_start_add_landmines_playerclass_destructive_xon");
				 start_add_inv_potion_health_small_destructive = cvar("g_start_add_inv_potion_health_small_destructive_xon");
				 start_add_inv_potion_health_medium_destructive = cvar("g_start_add_inv_potion_health_medium_destructive_xon");
				 start_add_inv_potion_health_large_destructive = cvar("g_start_add_inv_potion_health_large_destructive_xon");
				 start_add_inv_potion_mana_small_destructive = cvar("g_start_add_inv_potion_mana_small_destructive_xon");
				 start_add_inv_potion_mana_medium_destructive = cvar("g_start_add_inv_potion_mana_medium_destructive_xon");
				 start_add_inv_potion_mana_large_destructive = cvar("g_start_add_inv_potion_mana_large_destructive_xon");
				 start_add_inv_potion_rejuv_small_destructive = cvar("g_start_add_inv_potion_rejuv_small_destructive_xon");
				 start_add_inv_potion_rejuv_medium_destructive = cvar("g_start_add_inv_potion_rejuv_medium_destructive_xon");
				 start_add_inv_potion_rejuv_large_destructive = cvar("g_start_add_inv_potion_rejuv_large_destructive_xon");

				 
				 start_add_ammo_shells_playerclass_heavyweapons = cvar("g_start_add_ammo_shells_playerclass_heavyweapons_xon");
				 start_add_ammo_nails_playerclass_heavyweapons = cvar("g_start_add_ammo_nails_playerclass_heavyweapons_xon");
				 start_add_ammo_rockets_playerclass_heavyweapons = cvar("g_start_add_ammo_rockets_playerclass_heavyweapons_xon");
				 start_add_ammo_cells_playerclass_heavyweapons = cvar("g_start_add_ammo_cells_playerclass_heavyweapons_xon");
				 start_add_ammo_fuel_playerclass_heavyweapons = cvar("g_start_add_ammo_fuel_playerclass_heavyweapons_xon");
				 start_add_health_playerclass_heavyweapons = cvar("g_start_add_health_playerclass_heavyweapons_xon");
				 start_add_armorvalue_playerclass_heavyweapons = cvar("g_start_add_armorvalue_playerclass_heavyweapons_xon");
				 start_add_mana_playerclass_heavyweapons = cvar("g_start_add_mana_playerclass_heavyweapons_xon");
				 start_add_grenades_playerclass_heavyweapons = cvar("g_start_add_grenades_playerclass_heavyweapons_xon");
				 start_add_flashbangs_playerclass_heavyweapons = cvar("g_start_add_flashbangs_playerclass_heavyweapons_xon");
				 start_add_smokenades_playerclass_heavyweapons = cvar("g_start_add_smokenades_playerclass_heavyweapons_xon");
				 start_add_fragnades_playerclass_heavyweapons = cvar("g_start_add_fragnades_playerclass_heavyweapons_xon");
				 start_add_atmines_playerclass_heavyweapons = cvar("g_start_add_atmines_playerclass_heavyweapons_xon");
				 start_add_landmines_playerclass_heavyweapons = cvar("g_start_add_landmines_playerclass_heavyweapons_xon");
				 start_add_inv_potion_health_small_heavyweapons = cvar("g_start_add_inv_potion_health_small_heavyweapons_xon");
				 start_add_inv_potion_health_medium_heavyweapons = cvar("g_start_add_inv_potion_health_medium_heavyweapons_xon");
				 start_add_inv_potion_health_large_heavyweapons = cvar("g_start_add_inv_potion_health_large_heavyweapons_xon");
				 start_add_inv_potion_mana_small_heavyweapons = cvar("g_start_add_inv_potion_mana_small_heavyweapons_xon");
				 start_add_inv_potion_mana_medium_heavyweapons = cvar("g_start_add_inv_potion_mana_medium_heavyweapons_xon");
				 start_add_inv_potion_mana_large_heavyweapons = cvar("g_start_add_inv_potion_mana_large_heavyweapons_xon");
				 start_add_inv_potion_rejuv_small_heavyweapons = cvar("g_start_add_inv_potion_rejuv_small_heavyweapons_xon");
				 start_add_inv_potion_rejuv_medium_heavyweapons = cvar("g_start_add_inv_potion_rejuv_medium_heavyweapons_xon");
				 start_add_inv_potion_rejuv_large_heavyweapons = cvar("g_start_add_inv_potion_rejuv_large_heavyweapons_xon");

				 
				 start_add_ammo_shells_playerclass_pyromaniac = cvar("g_start_add_ammo_shells_playerclass_pyromaniac_xon");
				 start_add_ammo_nails_playerclass_pyromaniac = cvar("g_start_add_ammo_nails_playerclass_pyromaniac_xon");
				 start_add_ammo_rockets_playerclass_pyromaniac = cvar("g_start_add_ammo_rockets_playerclass_pyromaniac_xon");
				 start_add_ammo_cells_playerclass_pyromaniac = cvar("g_start_add_ammo_cells_playerclass_pyromaniac_xon");
				 start_add_ammo_fuel_playerclass_pyromaniac = cvar("g_start_add_ammo_fuel_playerclass_pyromaniac_xon");
				 start_add_health_playerclass_pyromaniac = cvar("g_start_add_health_playerclass_pyromaniac_xon");
				 start_add_armorvalue_playerclass_pyromaniac = cvar("g_start_add_armorvalue_playerclass_pyromaniac_xon");
				 start_add_mana_playerclass_pyromaniac = cvar("g_start_add_mana_playerclass_pyromaniac_xon");
				 start_add_grenades_playerclass_pyromaniac = cvar("g_start_add_grenades_playerclass_pyromaniac_xon");
				 start_add_flashbangs_playerclass_pyromaniac = cvar("g_start_add_flashbangs_playerclass_pyromaniac_xon");
				 start_add_smokenades_playerclass_pyromaniac = cvar("g_start_add_smokenades_playerclass_pyromaniac_xon");
				 start_add_fragnades_playerclass_pyromaniac = cvar("g_start_add_fragnades_playerclass_pyromaniac_xon");
				 start_add_atmines_playerclass_pyromaniac = cvar("g_start_add_atmines_playerclass_pyromaniac_xon");
				 start_add_landmines_playerclass_pyromaniac = cvar("g_start_add_landmines_playerclass_pyromaniac_xon");
				 start_add_inv_potion_health_small_pyromaniac = cvar("g_start_add_inv_potion_health_small_pyromaniac_xon");
				 start_add_inv_potion_health_medium_pyromaniac = cvar("g_start_add_inv_potion_health_medium_pyromaniac_xon");
				 start_add_inv_potion_health_large_pyromaniac = cvar("g_start_add_inv_potion_health_large_pyromaniac_xon");
				 start_add_inv_potion_mana_small_pyromaniac = cvar("g_start_add_inv_potion_mana_small_pyromaniac_xon");
				 start_add_inv_potion_mana_medium_pyromaniac = cvar("g_start_add_inv_potion_mana_medium_pyromaniac_xon");
				 start_add_inv_potion_mana_large_pyromaniac = cvar("g_start_add_inv_potion_mana_large_pyromaniac_xon");
				 start_add_inv_potion_rejuv_small_pyromaniac = cvar("g_start_add_inv_potion_rejuv_small_pyromaniac_xon");
				 start_add_inv_potion_rejuv_medium_pyromaniac = cvar("g_start_add_inv_potion_rejuv_medium_pyromaniac_xon");
				 start_add_inv_potion_rejuv_large_pyromaniac = cvar("g_start_add_inv_potion_rejuv_large_pyromaniac_xon");

				 
				 start_add_ammo_shells_playerclass_engineer = cvar("g_start_add_ammo_shells_playerclass_engineer_xon");
				 start_add_ammo_nails_playerclass_engineer = cvar("g_start_add_ammo_nails_playerclass_engineer_xon");
				 start_add_ammo_rockets_playerclass_engineer = cvar("g_start_add_ammo_rockets_playerclass_engineer_xon");
				 start_add_ammo_cells_playerclass_engineer = cvar("g_start_add_ammo_cells_playerclass_engineer_xon");
				 start_add_ammo_fuel_playerclass_engineer = cvar("g_start_add_ammo_fuel_playerclass_engineer_xon");
				 start_add_health_playerclass_engineer = cvar("g_start_add_health_playerclass_engineer_xon");
				 start_add_armorvalue_playerclass_engineer = cvar("g_start_add_armorvalue_playerclass_engineer_xon");
				 start_add_mana_playerclass_engineer = cvar("g_start_add_mana_playerclass_engineer_xon");
				 start_add_grenades_playerclass_engineer = cvar("g_start_add_grenades_playerclass_engineer_xon");
				 start_add_flashbangs_playerclass_engineer = cvar("g_start_add_flashbangs_playerclass_engineer_xon");
				 start_add_smokenades_playerclass_engineer = cvar("g_start_add_smokenades_playerclass_engineer_xon");
				 start_add_fragnades_playerclass_engineer = cvar("g_start_add_fragnades_playerclass_engineer_xon");
				 start_add_atmines_playerclass_engineer = cvar("g_start_add_atmines_playerclass_engineer_xon");
				 start_add_landmines_playerclass_engineer = cvar("g_start_add_landmines_playerclass_engineer_xon");
				 start_add_inv_potion_health_small_engineer = cvar("g_start_add_inv_potion_health_small_engineer_xon");
				 start_add_inv_potion_health_medium_engineer = cvar("g_start_add_inv_potion_health_medium_engineer_xon");
				 start_add_inv_potion_health_large_engineer = cvar("g_start_add_inv_potion_health_large_engineer_xon");
				 start_add_inv_potion_mana_small_engineer = cvar("g_start_add_inv_potion_mana_small_engineer_xon");
				 start_add_inv_potion_mana_medium_engineer = cvar("g_start_add_inv_potion_mana_medium_engineer_xon");
				 start_add_inv_potion_mana_large_engineer = cvar("g_start_add_inv_potion_mana_large_engineer_xon");
				 start_add_inv_potion_rejuv_small_engineer = cvar("g_start_add_inv_potion_rejuv_small_engineer_xon");
				 start_add_inv_potion_rejuv_medium_engineer = cvar("g_start_add_inv_potion_rejuv_medium_engineer_xon");
				 start_add_inv_potion_rejuv_large_engineer = cvar("g_start_add_inv_potion_rejuv_large_engineer_xon");

				 
				 
				 start_add_ammo_shells_playerclass_worker = cvar("g_start_add_ammo_shells_playerclass_worker_xon");
				 start_add_ammo_nails_playerclass_worker = cvar("g_start_add_ammo_nails_playerclass_worker_xon");
				 start_add_ammo_rockets_playerclass_worker = cvar("g_start_add_ammo_rockets_playerclass_worker_xon");
				 start_add_ammo_cells_playerclass_worker = cvar("g_start_add_ammo_cells_playerclass_worker_xon");
				 start_add_ammo_fuel_playerclass_worker = cvar("g_start_add_ammo_fuel_playerclass_worker_xon");
				 start_add_health_playerclass_worker = cvar("g_start_add_health_playerclass_worker_xon");
				 start_add_armorvalue_playerclass_worker = cvar("g_start_add_armorvalue_playerclass_worker_xon");
				 start_add_mana_playerclass_worker = cvar("g_start_add_mana_playerclass_worker_xon");
				 start_add_grenades_playerclass_worker = cvar("g_start_add_grenades_playerclass_worker_xon");
				 start_add_flashbangs_playerclass_worker = cvar("g_start_add_flashbangs_playerclass_worker_xon");
				 start_add_smokenades_playerclass_worker = cvar("g_start_add_smokenades_playerclass_worker_xon");
				 start_add_fragnades_playerclass_worker = cvar("g_start_add_fragnades_playerclass_worker_xon");
				 start_add_atmines_playerclass_worker = cvar("g_start_add_atmines_playerclass_worker_xon");
				 start_add_landmines_playerclass_worker = cvar("g_start_add_landmines_playerclass_worker_xon");
				 start_add_inv_potion_health_small_worker = cvar("g_start_add_inv_potion_health_small_worker_xon");
				 start_add_inv_potion_health_medium_worker = cvar("g_start_add_inv_potion_health_medium_worker_xon");
				 start_add_inv_potion_health_large_worker = cvar("g_start_add_inv_potion_health_large_worker_xon");
				 start_add_inv_potion_mana_small_worker = cvar("g_start_add_inv_potion_mana_small_worker_xon");
				 start_add_inv_potion_mana_medium_worker = cvar("g_start_add_inv_potion_mana_medium_worker_xon");
				 start_add_inv_potion_mana_large_worker = cvar("g_start_add_inv_potion_mana_large_worker_xon");
				 start_add_inv_potion_rejuv_small_worker = cvar("g_start_add_inv_potion_rejuv_small_worker_xon");
				 start_add_inv_potion_rejuv_medium_worker = cvar("g_start_add_inv_potion_rejuv_medium_worker_xon");
				 start_add_inv_potion_rejuv_large_worker = cvar("g_start_add_inv_potion_rejuv_large_worker_xon");

				 
				 start_add_ammo_shells_playerclass_healer = cvar("g_start_add_ammo_shells_playerclass_healer_xon");
				 start_add_ammo_nails_playerclass_healer = cvar("g_start_add_ammo_nails_playerclass_healer_xon");
				 start_add_ammo_rockets_playerclass_healer = cvar("g_start_add_ammo_rockets_playerclass_healer_xon");
				 start_add_ammo_cells_playerclass_healer = cvar("g_start_add_ammo_cells_playerclass_healer_xon");
				 start_add_ammo_fuel_playerclass_healer = cvar("g_start_add_ammo_fuel_playerclass_healer_xon");
				 start_add_health_playerclass_healer = cvar("g_start_add_health_playerclass_healer_xon");
				 start_add_armorvalue_playerclass_healer = cvar("g_start_add_armorvalue_playerclass_healer_xon");
				 start_add_mana_playerclass_healer = cvar("g_start_add_mana_playerclass_healer_xon");
				 start_add_grenades_playerclass_healer = cvar("g_start_add_grenades_playerclass_healer_xon");
				 start_add_flashbangs_playerclass_healer = cvar("g_start_add_flashbangs_playerclass_healer_xon");
				 start_add_smokenades_playerclass_healer = cvar("g_start_add_smokenades_playerclass_healer_xon");
				 start_add_fragnades_playerclass_healer = cvar("g_start_add_fragnades_playerclass_healer_xon");
				 start_add_atmines_playerclass_healer = cvar("g_start_add_atmines_playerclass_healer_xon");
				 start_add_landmines_playerclass_healer = cvar("g_start_add_landmines_playerclass_healer_xon");
				 start_add_inv_potion_health_small_healer = cvar("g_start_add_inv_potion_health_small_healer_xon");
				 start_add_inv_potion_health_medium_healer = cvar("g_start_add_inv_potion_health_medium_healer_xon");
				 start_add_inv_potion_health_large_healer = cvar("g_start_add_inv_potion_health_large_healer_xon");
				 start_add_inv_potion_mana_small_healer = cvar("g_start_add_inv_potion_mana_small_healer_xon");
				 start_add_inv_potion_mana_medium_healer = cvar("g_start_add_inv_potion_mana_medium_healer_xon");
				 start_add_inv_potion_mana_large_healer = cvar("g_start_add_inv_potion_mana_large_healer_xon");
				 start_add_inv_potion_rejuv_small_healer = cvar("g_start_add_inv_potion_rejuv_small_healer_xon");
				 start_add_inv_potion_rejuv_medium_healer = cvar("g_start_add_inv_potion_rejuv_medium_healer_xon");
				 start_add_inv_potion_rejuv_large_healer = cvar("g_start_add_inv_potion_rejuv_large_healer_xon");

				 
			} else if (mypcselection == PLAYERCLASSSET_WWI) {
				playerclassset = mypcselection;
				wepsetfromcvar_playerclass_longdistance("g_playerclass_weapons_longdistance_wwi");
				wepsetfromcvar_playerclass_marksman("g_playerclass_weapons_marksman_wwi");
				wepsetfromcvar_playerclass_mediumdistance("g_playerclass_weapons_mediumdistance_wwi");
				wepsetfromcvar_playerclass_assault("g_playerclass_weapons_assault_wwi");
				wepsetfromcvar_playerclass_closerange("g_playerclass_weapons_closerange_wwi");
				wepsetfromcvar_playerclass_destructive("g_playerclass_weapons_destructive_wwi");
				wepsetfromcvar_playerclass_heavyweapons("g_playerclass_weapons_heavyweapons_wwi");
				wepsetfromcvar_playerclass_pyromaniac("g_playerclass_weapons_pyromaniac_wwi");
				wepsetfromcvar_playerclass_engineer("g_playerclass_weapons_engineer_wwi");
				wepsetfromcvar_playerclass_worker("g_playerclass_weapons_worker_wwi");
				wepsetfromcvar_playerclass_healer("g_playerclass_weapons_healer_wwi");
				
				//Ammo
				 start_add_ammo_shells_playerclass_longdistance = cvar("g_start_add_ammo_shells_playerclass_longdistance_wwi");
				 start_add_ammo_nails_playerclass_longdistance = cvar("g_start_add_ammo_nails_playerclass_longdistance_wwi");
				 start_add_ammo_rockets_playerclass_longdistance = cvar("g_start_add_ammo_rockets_playerclass_longdistance_wwi");
				 start_add_ammo_cells_playerclass_longdistance = cvar("g_start_add_ammo_cells_playerclass_longdistance_wwi");
				 start_add_ammo_fuel_playerclass_longdistance = cvar("g_start_add_ammo_fuel_playerclass_longdistance_wwi");
				 start_add_health_playerclass_longdistance = cvar("g_start_add_health_playerclass_longdistance_wwi");
				 start_add_armorvalue_playerclass_longdistance = cvar("g_start_add_armorvalue_playerclass_longdistance_wwi");
				 start_add_mana_playerclass_longdistance = cvar("g_start_add_mana_playerclass_longdistance_wwi");
				 start_add_grenades_playerclass_longdistance = cvar("g_start_add_grenades_playerclass_longdistance_wwi");
				 start_add_flashbangs_playerclass_longdistance = cvar("g_start_add_flashbangs_playerclass_longdistance_wwi");
				 start_add_smokenades_playerclass_longdistance = cvar("g_start_add_smokenades_playerclass_longdistance_wwi");
				 start_add_fragnades_playerclass_longdistance = cvar("g_start_add_fragnades_playerclass_longdistance_wwi");
				 start_add_atmines_playerclass_longdistance = cvar("g_start_add_atmines_playerclass_longdistance_wwi");
				 start_add_landmines_playerclass_longdistance = cvar("g_start_add_landmines_playerclass_longdistance_wwi");
				 start_add_inv_potion_health_small_longdistance = cvar("g_start_add_inv_potion_health_small_longdistance_wwi");
				 start_add_inv_potion_health_medium_longdistance = cvar("g_start_add_inv_potion_health_medium_longdistance_wwi");
				 start_add_inv_potion_health_large_longdistance = cvar("g_start_add_inv_potion_health_large_longdistance_wwi");
				 start_add_inv_potion_mana_small_longdistance = cvar("g_start_add_inv_potion_mana_small_longdistance_wwi");
				 start_add_inv_potion_mana_medium_longdistance = cvar("g_start_add_inv_potion_mana_medium_longdistance_wwi");
				 start_add_inv_potion_mana_large_longdistance = cvar("g_start_add_inv_potion_mana_large_longdistance_wwi");
				 start_add_inv_potion_rejuv_small_longdistance = cvar("g_start_add_inv_potion_rejuv_small_longdistance_wwi");
				 start_add_inv_potion_rejuv_medium_longdistance = cvar("g_start_add_inv_potion_rejuv_medium_longdistance_wwi");
				 start_add_inv_potion_rejuv_large_longdistance = cvar("g_start_add_inv_potion_rejuv_large_longdistance_wwi");


				 start_add_ammo_shells_playerclass_marksman = cvar("g_start_add_ammo_shells_playerclass_marksman_wwi");
				 start_add_ammo_nails_playerclass_marksman = cvar("g_start_add_ammo_nails_playerclass_marksman_wwi");
				 start_add_ammo_rockets_playerclass_marksman = cvar("g_start_add_ammo_rockets_playerclass_marksman_wwi");
				 start_add_ammo_cells_playerclass_marksman = cvar("g_start_add_ammo_cells_playerclass_marksman_wwi");
				 start_add_ammo_fuel_playerclass_marksman = cvar("g_start_add_ammo_fuel_playerclass_marksman_wwi");
				 start_add_health_playerclass_marksman = cvar("g_start_add_health_playerclass_marksman_wwi");
				 start_add_armorvalue_playerclass_marksman = cvar("g_start_add_armorvalue_playerclass_marksman_wwi");
				 start_add_mana_playerclass_marksman = cvar("g_start_add_mana_playerclass_marksman_wwi");
				 start_add_grenades_playerclass_marksman = cvar("g_start_add_grenades_playerclass_marksman_wwi");
				 start_add_flashbangs_playerclass_marksman = cvar("g_start_add_flashbangs_playerclass_marksman_wwi");
				 start_add_smokenades_playerclass_marksman = cvar("g_start_add_smokenades_playerclass_marksman_wwi");
				 start_add_fragnades_playerclass_marksman = cvar("g_start_add_fragnades_playerclass_marksman_wwi");
				 start_add_atmines_playerclass_marksman = cvar("g_start_add_atmines_playerclass_marksman_wwi");
				 start_add_landmines_playerclass_marksman = cvar("g_start_add_landmines_playerclass_marksman_wwi");
				 start_add_inv_potion_health_small_marksman = cvar("g_start_add_inv_potion_health_small_marksman_wwi");
				 start_add_inv_potion_health_medium_marksman = cvar("g_start_add_inv_potion_health_medium_marksman_wwi");
				 start_add_inv_potion_health_large_marksman = cvar("g_start_add_inv_potion_health_large_marksman_wwi");
				 start_add_inv_potion_mana_small_marksman = cvar("g_start_add_inv_potion_mana_small_marksman_wwi");
				 start_add_inv_potion_mana_medium_marksman = cvar("g_start_add_inv_potion_mana_medium_marksman_wwi");
				 start_add_inv_potion_mana_large_marksman = cvar("g_start_add_inv_potion_mana_large_marksman_wwi");
				 start_add_inv_potion_rejuv_small_marksman = cvar("g_start_add_inv_potion_rejuv_small_marksman_wwi");
				 start_add_inv_potion_rejuv_medium_marksman = cvar("g_start_add_inv_potion_rejuv_medium_marksman_wwi");
				 start_add_inv_potion_rejuv_large_marksman = cvar("g_start_add_inv_potion_rejuv_large_marksman_wwi");


				 start_add_ammo_shells_playerclass_mediumdistance = cvar("g_start_add_ammo_shells_playerclass_mediumdistance_wwi");
				 start_add_ammo_nails_playerclass_mediumdistance = cvar("g_start_add_ammo_nails_playerclass_mediumdistance_wwi");
				 start_add_ammo_rockets_playerclass_mediumdistance = cvar("g_start_add_ammo_rockets_playerclass_mediumdistance_wwi");
				 start_add_ammo_cells_playerclass_mediumdistance = cvar("g_start_add_ammo_cells_playerclass_mediumdistance_wwi");
				 start_add_ammo_fuel_playerclass_mediumdistance = cvar("g_start_add_ammo_fuel_playerclass_mediumdistance_wwi");
				 start_add_health_playerclass_mediumdistance = cvar("g_start_add_health_playerclass_mediumdistance_wwi");
				 start_add_armorvalue_playerclass_mediumdistance = cvar("g_start_add_armorvalue_playerclass_mediumdistance_wwi");
				 start_add_mana_playerclass_mediumdistance = cvar("g_start_add_mana_playerclass_mediumdistance_wwi");
				 start_add_grenades_playerclass_mediumdistance = cvar("g_start_add_grenades_playerclass_mediumdistance_wwi");
				 start_add_flashbangs_playerclass_mediumdistance = cvar("g_start_add_flashbangs_playerclass_mediumdistance_wwi");
				 start_add_smokenades_playerclass_mediumdistance = cvar("g_start_add_smokenades_playerclass_mediumdistance_wwi");
				 start_add_fragnades_playerclass_mediumdistance = cvar("g_start_add_fragnades_playerclass_mediumdistance_wwi");
				 start_add_atmines_playerclass_mediumdistance = cvar("g_start_add_atmines_playerclass_mediumdistance_wwi");
				 start_add_landmines_playerclass_mediumdistance = cvar("g_start_add_landmines_playerclass_mediumdistance_wwi");
				 start_add_inv_potion_health_small_mediumdistance = cvar("g_start_add_inv_potion_health_small_mediumdistance_wwi");
				 start_add_inv_potion_health_medium_mediumdistance = cvar("g_start_add_inv_potion_health_medium_mediumdistance_wwi");
				 start_add_inv_potion_health_large_mediumdistance = cvar("g_start_add_inv_potion_health_large_mediumdistance_wwi");
				 start_add_inv_potion_mana_small_mediumdistance = cvar("g_start_add_inv_potion_mana_small_mediumdistance_wwi");
				 start_add_inv_potion_mana_medium_mediumdistance = cvar("g_start_add_inv_potion_mana_medium_mediumdistance_wwi");
				 start_add_inv_potion_mana_large_mediumdistance = cvar("g_start_add_inv_potion_mana_large_mediumdistance_wwi");
				 start_add_inv_potion_rejuv_small_mediumdistance = cvar("g_start_add_inv_potion_rejuv_small_mediumdistance_wwi");
				 start_add_inv_potion_rejuv_medium_mediumdistance = cvar("g_start_add_inv_potion_rejuv_medium_mediumdistance_wwi");
				 start_add_inv_potion_rejuv_large_mediumdistance = cvar("g_start_add_inv_potion_rejuv_large_mediumdistance_wwi");

				 
				 start_add_ammo_shells_playerclass_assault = cvar("g_start_add_ammo_shells_playerclass_assault_wwi");
				 start_add_ammo_nails_playerclass_assault = cvar("g_start_add_ammo_nails_playerclass_assault_wwi");
				 start_add_ammo_rockets_playerclass_assault = cvar("g_start_add_ammo_rockets_playerclass_assault_wwi");
				 start_add_ammo_cells_playerclass_assault = cvar("g_start_add_ammo_cells_playerclass_assault_wwi");
				 start_add_ammo_fuel_playerclass_assault = cvar("g_start_add_ammo_fuel_playerclass_assault_wwi");
				 start_add_health_playerclass_assault = cvar("g_start_add_health_playerclass_assault_wwi");
				 start_add_armorvalue_playerclass_assault = cvar("g_start_add_armorvalue_playerclass_assault_wwi");
				 start_add_mana_playerclass_assault = cvar("g_start_add_mana_playerclass_assault_wwi");
				 start_add_grenades_playerclass_assault = cvar("g_start_add_grenades_playerclass_assault_wwi");
				 start_add_flashbangs_playerclass_assault = cvar("g_start_add_flashbangs_playerclass_assault_wwi");
				 start_add_smokenades_playerclass_assault = cvar("g_start_add_smokenades_playerclass_assault_wwi");
				 start_add_fragnades_playerclass_assault = cvar("g_start_add_fragnades_playerclass_assault_wwi");
				 start_add_atmines_playerclass_assault = cvar("g_start_add_atmines_playerclass_assault_wwi");
				 start_add_landmines_playerclass_assault = cvar("g_start_add_landmines_playerclass_assault_wwi");
				 start_add_inv_potion_health_small_assault = cvar("g_start_add_inv_potion_health_small_assault_wwi");
				 start_add_inv_potion_health_medium_assault = cvar("g_start_add_inv_potion_health_medium_assault_wwi");
				 start_add_inv_potion_health_large_assault = cvar("g_start_add_inv_potion_health_large_assault_wwi");
				 start_add_inv_potion_mana_small_assault = cvar("g_start_add_inv_potion_mana_small_assault_wwi");
				 start_add_inv_potion_mana_medium_assault = cvar("g_start_add_inv_potion_mana_medium_assault_wwi");
				 start_add_inv_potion_mana_large_assault = cvar("g_start_add_inv_potion_mana_large_assault_wwi");
				 start_add_inv_potion_rejuv_small_assault = cvar("g_start_add_inv_potion_rejuv_small_assault_wwi");
				 start_add_inv_potion_rejuv_medium_assault = cvar("g_start_add_inv_potion_rejuv_medium_assault_wwi");
				 start_add_inv_potion_rejuv_large_assault = cvar("g_start_add_inv_potion_rejuv_large_assault_wwi");

				 


				 start_add_ammo_shells_playerclass_closerange = cvar("g_start_add_ammo_shells_playerclass_closerange_wwi");
				 start_add_ammo_nails_playerclass_closerange = cvar("g_start_add_ammo_nails_playerclass_closerange_wwi");
				 start_add_ammo_rockets_playerclass_closerange = cvar("g_start_add_ammo_rockets_playerclass_closerange_wwi");
				 start_add_ammo_cells_playerclass_closerange = cvar("g_start_add_ammo_cells_playerclass_closerange_wwi");
				 start_add_ammo_fuel_playerclass_closerange = cvar("g_start_add_ammo_fuel_playerclass_closerange_wwi");
				 start_add_health_playerclass_closerange = cvar("g_start_add_health_playerclass_closerange_wwi");
				 start_add_armorvalue_playerclass_closerange = cvar("g_start_add_armorvalue_playerclass_closerange_wwi");
				 start_add_mana_playerclass_closerange = cvar("g_start_add_mana_playerclass_closerange_wwi");
				 start_add_grenades_playerclass_closerange = cvar("g_start_add_grenades_playerclass_closerange_wwi");
				 start_add_flashbangs_playerclass_closerange = cvar("g_start_add_flashbangs_playerclass_closerange_wwi");
				 start_add_smokenades_playerclass_closerange = cvar("g_start_add_smokenades_playerclass_closerange_wwi");
				 start_add_fragnades_playerclass_closerange = cvar("g_start_add_fragnades_playerclass_closerange_wwi");
				 start_add_atmines_playerclass_closerange = cvar("g_start_add_atmines_playerclass_closerange_wwi");
				 start_add_landmines_playerclass_closerange = cvar("g_start_add_landmines_playerclass_closerange_wwi");
				 start_add_inv_potion_health_small_closerange = cvar("g_start_add_inv_potion_health_small_closerange_wwi");
				 start_add_inv_potion_health_medium_closerange = cvar("g_start_add_inv_potion_health_medium_closerange_wwi");
				 start_add_inv_potion_health_large_closerange = cvar("g_start_add_inv_potion_health_large_closerange_wwi");
				 start_add_inv_potion_mana_small_closerange = cvar("g_start_add_inv_potion_mana_small_closerange_wwi");
				 start_add_inv_potion_mana_medium_closerange = cvar("g_start_add_inv_potion_mana_medium_closerange_wwi");
				 start_add_inv_potion_mana_large_closerange = cvar("g_start_add_inv_potion_mana_large_closerange_wwi");
				 start_add_inv_potion_rejuv_small_closerange = cvar("g_start_add_inv_potion_rejuv_small_closerange_wwi");
				 start_add_inv_potion_rejuv_medium_closerange = cvar("g_start_add_inv_potion_rejuv_medium_closerange_wwi");
				 start_add_inv_potion_rejuv_large_closerange = cvar("g_start_add_inv_potion_rejuv_large_closerange_wwi");

				 
				 start_add_ammo_shells_playerclass_destructive = cvar("g_start_add_ammo_shells_playerclass_destructive_wwi");
				 start_add_ammo_nails_playerclass_destructive = cvar("g_start_add_ammo_nails_playerclass_destructive_wwi");
				 start_add_ammo_rockets_playerclass_destructive = cvar("g_start_add_ammo_rockets_playerclass_destructive_wwi");
				 start_add_ammo_cells_playerclass_destructive = cvar("g_start_add_ammo_cells_playerclass_destructive_wwi");
				 start_add_ammo_fuel_playerclass_destructive = cvar("g_start_add_ammo_fuel_playerclass_destructive_wwi");
				 start_add_health_playerclass_destructive = cvar("g_start_add_health_playerclass_destructive_wwi");
				 start_add_armorvalue_playerclass_destructive = cvar("g_start_add_armorvalue_playerclass_destructive_wwi");
				 start_add_mana_playerclass_destructive = cvar("g_start_add_mana_playerclass_destructive_wwi");
				 start_add_grenades_playerclass_destructive = cvar("g_start_add_grenades_playerclass_destructive_wwi");
				 start_add_flashbangs_playerclass_destructive = cvar("g_start_add_flashbangs_playerclass_destructive_wwi");
				 start_add_smokenades_playerclass_destructive = cvar("g_start_add_smokenades_playerclass_destructive_wwi");
				 start_add_fragnades_playerclass_destructive = cvar("g_start_add_fragnades_playerclass_destructive_wwi");
				 start_add_atmines_playerclass_destructive = cvar("g_start_add_atmines_playerclass_destructive_wwi");
				 start_add_landmines_playerclass_destructive = cvar("g_start_add_landmines_playerclass_destructive_wwi");
				 start_add_inv_potion_health_small_destructive = cvar("g_start_add_inv_potion_health_small_destructive_wwi");
				 start_add_inv_potion_health_medium_destructive = cvar("g_start_add_inv_potion_health_medium_destructive_wwi");
				 start_add_inv_potion_health_large_destructive = cvar("g_start_add_inv_potion_health_large_destructive_wwi");
				 start_add_inv_potion_mana_small_destructive = cvar("g_start_add_inv_potion_mana_small_destructive_wwi");
				 start_add_inv_potion_mana_medium_destructive = cvar("g_start_add_inv_potion_mana_medium_destructive_wwi");
				 start_add_inv_potion_mana_large_destructive = cvar("g_start_add_inv_potion_mana_large_destructive_wwi");
				 start_add_inv_potion_rejuv_small_destructive = cvar("g_start_add_inv_potion_rejuv_small_destructive_wwi");
				 start_add_inv_potion_rejuv_medium_destructive = cvar("g_start_add_inv_potion_rejuv_medium_destructive_wwi");
				 start_add_inv_potion_rejuv_large_destructive = cvar("g_start_add_inv_potion_rejuv_large_destructive_wwi");

				 
				 start_add_ammo_shells_playerclass_heavyweapons = cvar("g_start_add_ammo_shells_playerclass_heavyweapons_wwi");
				 start_add_ammo_nails_playerclass_heavyweapons = cvar("g_start_add_ammo_nails_playerclass_heavyweapons_wwi");
				 start_add_ammo_rockets_playerclass_heavyweapons = cvar("g_start_add_ammo_rockets_playerclass_heavyweapons_wwi");
				 start_add_ammo_cells_playerclass_heavyweapons = cvar("g_start_add_ammo_cells_playerclass_heavyweapons_wwi");
				 start_add_ammo_fuel_playerclass_heavyweapons = cvar("g_start_add_ammo_fuel_playerclass_heavyweapons_wwi");
				 start_add_health_playerclass_heavyweapons = cvar("g_start_add_health_playerclass_heavyweapons_wwi");
				 start_add_armorvalue_playerclass_heavyweapons = cvar("g_start_add_armorvalue_playerclass_heavyweapons_wwi");
				 start_add_mana_playerclass_heavyweapons = cvar("g_start_add_mana_playerclass_heavyweapons_wwi");
				 start_add_grenades_playerclass_heavyweapons = cvar("g_start_add_grenades_playerclass_heavyweapons_wwi");
				 start_add_flashbangs_playerclass_heavyweapons = cvar("g_start_add_flashbangs_playerclass_heavyweapons_wwi");
				 start_add_smokenades_playerclass_heavyweapons = cvar("g_start_add_smokenades_playerclass_heavyweapons_wwi");
				 start_add_fragnades_playerclass_heavyweapons = cvar("g_start_add_fragnades_playerclass_heavyweapons_wwi");
				 start_add_atmines_playerclass_heavyweapons = cvar("g_start_add_atmines_playerclass_heavyweapons_wwi");
				 start_add_landmines_playerclass_heavyweapons = cvar("g_start_add_landmines_playerclass_heavyweapons_wwi");
				 start_add_inv_potion_health_small_heavyweapons = cvar("g_start_add_inv_potion_health_small_heavyweapons_wwi");
				 start_add_inv_potion_health_medium_heavyweapons = cvar("g_start_add_inv_potion_health_medium_heavyweapons_wwi");
				 start_add_inv_potion_health_large_heavyweapons = cvar("g_start_add_inv_potion_health_large_heavyweapons_wwi");
				 start_add_inv_potion_mana_small_heavyweapons = cvar("g_start_add_inv_potion_mana_small_heavyweapons_wwi");
				 start_add_inv_potion_mana_medium_heavyweapons = cvar("g_start_add_inv_potion_mana_medium_heavyweapons_wwi");
				 start_add_inv_potion_mana_large_heavyweapons = cvar("g_start_add_inv_potion_mana_large_heavyweapons_wwi");
				 start_add_inv_potion_rejuv_small_heavyweapons = cvar("g_start_add_inv_potion_rejuv_small_heavyweapons_wwi");
				 start_add_inv_potion_rejuv_medium_heavyweapons = cvar("g_start_add_inv_potion_rejuv_medium_heavyweapons_wwi");
				 start_add_inv_potion_rejuv_large_heavyweapons = cvar("g_start_add_inv_potion_rejuv_large_heavyweapons_wwi");

				 
				 start_add_ammo_shells_playerclass_pyromaniac = cvar("g_start_add_ammo_shells_playerclass_pyromaniac_wwi");
				 start_add_ammo_nails_playerclass_pyromaniac = cvar("g_start_add_ammo_nails_playerclass_pyromaniac_wwi");
				 start_add_ammo_rockets_playerclass_pyromaniac = cvar("g_start_add_ammo_rockets_playerclass_pyromaniac_wwi");
				 start_add_ammo_cells_playerclass_pyromaniac = cvar("g_start_add_ammo_cells_playerclass_pyromaniac_wwi");
				 start_add_ammo_fuel_playerclass_pyromaniac = cvar("g_start_add_ammo_fuel_playerclass_pyromaniac_wwi");
				 start_add_health_playerclass_pyromaniac = cvar("g_start_add_health_playerclass_pyromaniac_wwi");
				 start_add_armorvalue_playerclass_pyromaniac = cvar("g_start_add_armorvalue_playerclass_pyromaniac_wwi");
				 start_add_mana_playerclass_pyromaniac = cvar("g_start_add_mana_playerclass_pyromaniac_wwi");
				 start_add_grenades_playerclass_pyromaniac = cvar("g_start_add_grenades_playerclass_pyromaniac_wwi");
				 start_add_flashbangs_playerclass_pyromaniac = cvar("g_start_add_flashbangs_playerclass_pyromaniac_wwi");
				 start_add_smokenades_playerclass_pyromaniac = cvar("g_start_add_smokenades_playerclass_pyromaniac_wwi");
				 start_add_fragnades_playerclass_pyromaniac = cvar("g_start_add_fragnades_playerclass_pyromaniac_wwi");
				 start_add_atmines_playerclass_pyromaniac = cvar("g_start_add_atmines_playerclass_pyromaniac_wwi");
				 start_add_landmines_playerclass_pyromaniac = cvar("g_start_add_landmines_playerclass_pyromaniac_wwi");
				 start_add_inv_potion_health_small_pyromaniac = cvar("g_start_add_inv_potion_health_small_pyromaniac_wwi");
				 start_add_inv_potion_health_medium_pyromaniac = cvar("g_start_add_inv_potion_health_medium_pyromaniac_wwi");
				 start_add_inv_potion_health_large_pyromaniac = cvar("g_start_add_inv_potion_health_large_pyromaniac_wwi");
				 start_add_inv_potion_mana_small_pyromaniac = cvar("g_start_add_inv_potion_mana_small_pyromaniac_wwi");
				 start_add_inv_potion_mana_medium_pyromaniac = cvar("g_start_add_inv_potion_mana_medium_pyromaniac_wwi");
				 start_add_inv_potion_mana_large_pyromaniac = cvar("g_start_add_inv_potion_mana_large_pyromaniac_wwi");
				 start_add_inv_potion_rejuv_small_pyromaniac = cvar("g_start_add_inv_potion_rejuv_small_pyromaniac_wwi");
				 start_add_inv_potion_rejuv_medium_pyromaniac = cvar("g_start_add_inv_potion_rejuv_medium_pyromaniac_wwi");
				 start_add_inv_potion_rejuv_large_pyromaniac = cvar("g_start_add_inv_potion_rejuv_large_pyromaniac_wwi");

				 
				 start_add_ammo_shells_playerclass_engineer = cvar("g_start_add_ammo_shells_playerclass_engineer_wwi");
				 start_add_ammo_nails_playerclass_engineer = cvar("g_start_add_ammo_nails_playerclass_engineer_wwi");
				 start_add_ammo_rockets_playerclass_engineer = cvar("g_start_add_ammo_rockets_playerclass_engineer_wwi");
				 start_add_ammo_cells_playerclass_engineer = cvar("g_start_add_ammo_cells_playerclass_engineer_wwi");
				 start_add_ammo_fuel_playerclass_engineer = cvar("g_start_add_ammo_fuel_playerclass_engineer_wwi");
				 start_add_health_playerclass_engineer = cvar("g_start_add_health_playerclass_engineer_wwi");
				 start_add_armorvalue_playerclass_engineer = cvar("g_start_add_armorvalue_playerclass_engineer_wwi");
				 start_add_mana_playerclass_engineer = cvar("g_start_add_mana_playerclass_engineer_wwi");
				 start_add_grenades_playerclass_engineer = cvar("g_start_add_grenades_playerclass_engineer_wwi");
				 start_add_flashbangs_playerclass_engineer = cvar("g_start_add_flashbangs_playerclass_engineer_wwi");
				 start_add_smokenades_playerclass_engineer = cvar("g_start_add_smokenades_playerclass_engineer_wwi");
				 start_add_fragnades_playerclass_engineer = cvar("g_start_add_fragnades_playerclass_engineer_wwi");
				 start_add_atmines_playerclass_engineer = cvar("g_start_add_atmines_playerclass_engineer_wwi");
				 start_add_landmines_playerclass_engineer = cvar("g_start_add_landmines_playerclass_engineer_wwi");
				 start_add_inv_potion_health_small_engineer = cvar("g_start_add_inv_potion_health_small_engineer_wwi");
				 start_add_inv_potion_health_medium_engineer = cvar("g_start_add_inv_potion_health_medium_engineer_wwi");
				 start_add_inv_potion_health_large_engineer = cvar("g_start_add_inv_potion_health_large_engineer_wwi");
				 start_add_inv_potion_mana_small_engineer = cvar("g_start_add_inv_potion_mana_small_engineer_wwi");
				 start_add_inv_potion_mana_medium_engineer = cvar("g_start_add_inv_potion_mana_medium_engineer_wwi");
				 start_add_inv_potion_mana_large_engineer = cvar("g_start_add_inv_potion_mana_large_engineer_wwi");
				 start_add_inv_potion_rejuv_small_engineer = cvar("g_start_add_inv_potion_rejuv_small_engineer_wwi");
				 start_add_inv_potion_rejuv_medium_engineer = cvar("g_start_add_inv_potion_rejuv_medium_engineer_wwi");
				 start_add_inv_potion_rejuv_large_engineer = cvar("g_start_add_inv_potion_rejuv_large_engineer_wwi");

				 
				 
				 start_add_ammo_shells_playerclass_worker = cvar("g_start_add_ammo_shells_playerclass_worker_wwi");
				 start_add_ammo_nails_playerclass_worker = cvar("g_start_add_ammo_nails_playerclass_worker_wwi");
				 start_add_ammo_rockets_playerclass_worker = cvar("g_start_add_ammo_rockets_playerclass_worker_wwi");
				 start_add_ammo_cells_playerclass_worker = cvar("g_start_add_ammo_cells_playerclass_worker_wwi");
				 start_add_ammo_fuel_playerclass_worker = cvar("g_start_add_ammo_fuel_playerclass_worker_wwi");
				 start_add_health_playerclass_worker = cvar("g_start_add_health_playerclass_worker_wwi");
				 start_add_armorvalue_playerclass_worker = cvar("g_start_add_armorvalue_playerclass_worker_wwi");
				 start_add_mana_playerclass_worker = cvar("g_start_add_mana_playerclass_worker_wwi");
				 start_add_grenades_playerclass_worker = cvar("g_start_add_grenades_playerclass_worker_wwi");
				 start_add_flashbangs_playerclass_worker = cvar("g_start_add_flashbangs_playerclass_worker_wwi");
				 start_add_smokenades_playerclass_worker = cvar("g_start_add_smokenades_playerclass_worker_wwi");
				 start_add_fragnades_playerclass_worker = cvar("g_start_add_fragnades_playerclass_worker_wwi");
				 start_add_atmines_playerclass_worker = cvar("g_start_add_atmines_playerclass_worker_wwi");
				 start_add_landmines_playerclass_worker = cvar("g_start_add_landmines_playerclass_worker_wwi");
				 start_add_inv_potion_health_small_worker = cvar("g_start_add_inv_potion_health_small_worker_wwi");
				 start_add_inv_potion_health_medium_worker = cvar("g_start_add_inv_potion_health_medium_worker_wwi");
				 start_add_inv_potion_health_large_worker = cvar("g_start_add_inv_potion_health_large_worker_wwi");
				 start_add_inv_potion_mana_small_worker = cvar("g_start_add_inv_potion_mana_small_worker_wwi");
				 start_add_inv_potion_mana_medium_worker = cvar("g_start_add_inv_potion_mana_medium_worker_wwi");
				 start_add_inv_potion_mana_large_worker = cvar("g_start_add_inv_potion_mana_large_worker_wwi");
				 start_add_inv_potion_rejuv_small_worker = cvar("g_start_add_inv_potion_rejuv_small_worker_wwi");
				 start_add_inv_potion_rejuv_medium_worker = cvar("g_start_add_inv_potion_rejuv_medium_worker_wwi");
				 start_add_inv_potion_rejuv_large_worker = cvar("g_start_add_inv_potion_rejuv_large_worker_wwi");

				 
				 start_add_ammo_shells_playerclass_healer = cvar("g_start_add_ammo_shells_playerclass_healer_wwi");
				 start_add_ammo_nails_playerclass_healer = cvar("g_start_add_ammo_nails_playerclass_healer_wwi");
				 start_add_ammo_rockets_playerclass_healer = cvar("g_start_add_ammo_rockets_playerclass_healer_wwi");
				 start_add_ammo_cells_playerclass_healer = cvar("g_start_add_ammo_cells_playerclass_healer_wwi");
				 start_add_ammo_fuel_playerclass_healer = cvar("g_start_add_ammo_fuel_playerclass_healer_wwi");
				 start_add_health_playerclass_healer = cvar("g_start_add_health_playerclass_healer_wwi");
				 start_add_armorvalue_playerclass_healer = cvar("g_start_add_armorvalue_playerclass_healer_wwi");
				 start_add_mana_playerclass_healer = cvar("g_start_add_mana_playerclass_healer_wwi");
				 start_add_grenades_playerclass_healer = cvar("g_start_add_grenades_playerclass_healer_wwi");
				 start_add_flashbangs_playerclass_healer = cvar("g_start_add_flashbangs_playerclass_healer_wwi");
				 start_add_smokenades_playerclass_healer = cvar("g_start_add_smokenades_playerclass_healer_wwi");
				 start_add_fragnades_playerclass_healer = cvar("g_start_add_fragnades_playerclass_healer_wwi");
				 start_add_atmines_playerclass_healer = cvar("g_start_add_atmines_playerclass_healer_wwi");
				 start_add_landmines_playerclass_healer = cvar("g_start_add_landmines_playerclass_healer_wwi");
				 start_add_inv_potion_health_small_healer = cvar("g_start_add_inv_potion_health_small_healer_wwi");
				 start_add_inv_potion_health_medium_healer = cvar("g_start_add_inv_potion_health_medium_healer_wwi");
				 start_add_inv_potion_health_large_healer = cvar("g_start_add_inv_potion_health_large_healer_wwi");
				 start_add_inv_potion_mana_small_healer = cvar("g_start_add_inv_potion_mana_small_healer_wwi");
				 start_add_inv_potion_mana_medium_healer = cvar("g_start_add_inv_potion_mana_medium_healer_wwi");
				 start_add_inv_potion_mana_large_healer = cvar("g_start_add_inv_potion_mana_large_healer_wwi");
				 start_add_inv_potion_rejuv_small_healer = cvar("g_start_add_inv_potion_rejuv_small_healer_wwi");
				 start_add_inv_potion_rejuv_medium_healer = cvar("g_start_add_inv_potion_rejuv_medium_healer_wwi");
				 start_add_inv_potion_rejuv_large_healer = cvar("g_start_add_inv_potion_rejuv_large_healer_wwi");

				 
			} 
		}
		//End Chaos-esque addition
	}

	if(!cvar("g_use_ammunition"))
		start_items |= IT_UNLIMITED_AMMO;

	if(cvar("g_nexball"))
		start_items |= IT_UNLIMITED_SUPERWEAPONS; // FIXME BAD BAD BAD BAD HACK, NEXBALL SHOULDN'T ABUSE PORTO'S WEAPON SLOT

	if(g_minstagib)
	{
		start_ammo_cells = cvar("g_minstagib_ammo_start");
		start_ammo_fuel = cvar("g_start_ammo_fuel");
	}
	else if(start_items & IT_UNLIMITED_WEAPON_AMMO)
	{
		start_ammo_rockets = 999;
		start_ammo_shells = 999;
		start_ammo_cells = 999;
		start_ammo_nails = 999;
		start_ammo_fuel = 999;
	}
	else
	{
		if(g_lms || g_ca)
		{
			start_ammo_shells = cvar("g_lms_start_ammo_shells");
			start_ammo_nails = cvar("g_lms_start_ammo_nails");
			start_ammo_rockets = cvar("g_lms_start_ammo_rockets");
			start_ammo_cells = cvar("g_lms_start_ammo_cells");
			start_ammo_fuel = cvar("g_lms_start_ammo_fuel");
		}
		else
		{
			start_ammo_shells = cvar("g_start_ammo_shells");
			start_ammo_nails = cvar("g_start_ammo_nails");
			start_ammo_rockets = cvar("g_start_ammo_rockets");
			start_ammo_cells = cvar("g_start_ammo_cells");
			start_ammo_fuel = cvar("g_start_ammo_fuel");
		}
	}

	if (g_lms || g_ca)
	{
		start_health = cvar("g_lms_start_health");
		start_armorvalue = cvar("g_lms_start_armor");
		start_mana = cvar("g_lms_start_mana");
	}

	if (inWarmupStage)
	{
		warmup_start_ammo_shells = start_ammo_shells;
		warmup_start_ammo_nails = start_ammo_nails;
		warmup_start_ammo_rockets = start_ammo_rockets;
		warmup_start_ammo_cells = start_ammo_cells;
		warmup_start_ammo_fuel = start_ammo_fuel;
		warmup_start_health = start_health;
		warmup_start_armorvalue = start_armorvalue;
		warmup_start_mana = start_mana;
		warmup_start_grenades = start_grenades;
		warmup_start_flashbangs = start_flashbangs;
		warmup_start_smokenades = start_smokenades;
		warmup_start_fragnades = start_fragnades;
		warmup_start_atmines = start_atmines;
		warmup_start_landmines = start_landmines;
		WEPSET_COPY_AA(warmup_start_weapons, start_weapons);
		WEPSET_COPY_AA(warmup_start_weapons_default, start_weapons_default);
		WEPSET_COPY_AA(warmup_start_weapons_defaultmask, start_weapons_defaultmask);

		if (!g_weaponarena && !g_minstagib && !g_ca)
		{
			warmup_start_ammo_shells = cvar("g_warmup_start_ammo_shells");
			warmup_start_ammo_cells = cvar("g_warmup_start_ammo_cells");
			warmup_start_ammo_nails = cvar("g_warmup_start_ammo_nails");
			warmup_start_ammo_rockets = cvar("g_warmup_start_ammo_rockets");
			warmup_start_ammo_fuel = cvar("g_warmup_start_ammo_fuel");
			warmup_start_health = cvar("g_warmup_start_health");
			warmup_start_armorvalue = cvar("g_warmup_start_armor");
			warmup_start_mana = cvar("g_warmup_start_mana");
			warmup_start_grenades = cvar("g_warmup_start_grenades");
			warmup_start_flashbangs = cvar("g_warmup_start_flashbangs");
			warmup_start_smokenades = cvar("g_warmup_start_smokenades");
			warmup_start_fragnades = cvar("g_warmup_start_fragnades");
			warmup_start_atmines = cvar("g_warmup_start_atmines");
			warmup_start_landmines = cvar("g_warmup_start_landmines");
			WEPSET_CLEAR_A(warmup_start_weapons);
			WEPSET_CLEAR_A(warmup_start_weapons_default);
			WEPSET_CLEAR_A(warmup_start_weapons_defaultmask);
			for (i = WEP_FIRST; i <= WEP_LAST; ++i)
			{
				e = get_weaponinfo(i);
				float w = want_weapon("g_start_weapon_", e, cvar("g_warmup_allguns"));
				if(w & 1)
					WEPSET_OR_AW(warmup_start_weapons, i);
				if(w & 2)
					WEPSET_OR_AW(warmup_start_weapons_default, i);
				if(w & 4)
					WEPSET_OR_AW(warmup_start_weapons_defaultmask, i);
			}
		}
	}

	if (g_jetpack)
		start_items |= IT_JETPACK;

	MUTATOR_CALLHOOK(SetStartItems);

	if ((start_items & IT_JETPACK) || (g_grappling_hook && WEPSET_CONTAINS_AW(start_weapons, WEP_HOOK)))
	{
		g_grappling_hook = 0; // these two can't coexist, as they use the same button
		start_items |= IT_FUEL_REGEN;
		start_ammo_fuel = max(start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
		warmup_start_ammo_fuel = max(warmup_start_ammo_fuel, cvar("g_balance_fuel_rotstable"));
	}

	for (i = WEP_FIRST; i <= WEP_LAST; ++i)
	{
		e = get_weaponinfo(i);
		///////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////
		if(WEPSET_CONTAINS_AW(start_weapons, i) || WEPSET_CONTAINS_AW(warmup_start_weapons, i)
		
		|| (teamplay &&
		               (  (WEPSET_CONTAINS_AW(start_weapons_team1, i))
				||(WEPSET_CONTAINS_AW(start_weapons_team2, i))
				||(WEPSET_CONTAINS_AW(start_weapons_team3, i))
				||(WEPSET_CONTAINS_AW(start_weapons_team4, i))  )  
		   )
		
		|| (g_playerclass &&
		       (  (WEPSET_CONTAINS_AW(start_weapons_playerclass_longdistance, i))
		        ||(WEPSET_CONTAINS_AW(start_weapons_playerclass_marksman, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_mediumdistance, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_assault, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_closerange, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_destructive, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_heavyweapons, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_pyromaniac, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_engineer, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_worker, i))
			||(WEPSET_CONTAINS_AW(start_weapons_playerclass_healer, i))  )  
		   )
		)
			{
				weapon_action(i, WR_PRECACHE);
			}
		///////////////////////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////////////////////
	}

	start_ammo_shells = max(0, start_ammo_shells);
	start_ammo_nails = max(0, start_ammo_nails);
	start_ammo_cells = max(0, start_ammo_cells);
	start_ammo_rockets = max(0, start_ammo_rockets);
	start_ammo_fuel = max(0, start_ammo_fuel);
	start_grenades = max(0, start_grenades);
	start_grenades_team1 = max(0, start_grenades_team1);
	start_grenades_team2 = max(0, start_grenades_team2);
	start_grenades_team3 = max(0, start_grenades_team3);
	start_grenades_team4 = max(0, start_grenades_team4);
	start_flashbangs = max(0, start_flashbangs);
	start_flashbangs_team1 = max(0, start_flashbangs_team1);
	start_flashbangs_team2 = max(0, start_flashbangs_team2);
	start_flashbangs_team3 = max(0, start_flashbangs_team3);
	start_flashbangs_team4 = max(0, start_flashbangs_team4);
	start_smokenades = max(0, start_smokenades);
	start_smokenades_team1 = max(0, start_smokenades_team1);
	start_smokenades_team2 = max(0, start_smokenades_team2);
	start_smokenades_team3 = max(0, start_smokenades_team3);
	start_smokenades_team4 = max(0, start_smokenades_team4);
	start_fragnades = max(0, start_fragnades);
	start_fragnades_team1 = max(0, start_fragnades_team1);
	start_fragnades_team2 = max(0, start_fragnades_team2);
	start_fragnades_team3 = max(0, start_fragnades_team3);
	start_fragnades_team4 = max(0, start_fragnades_team4);
	start_atmines = max(0, start_atmines);
	start_atmines_team1 = max(0, start_atmines_team1);
	start_atmines_team2 = max(0, start_atmines_team2);
	start_atmines_team3 = max(0, start_atmines_team3);
	start_atmines_team4 = max(0, start_atmines_team4);
	start_landmines = max(0, start_landmines);
	start_landmines_team1 = max(0, start_landmines_team1);
	start_landmines_team2 = max(0, start_landmines_team2);
	start_landmines_team3 = max(0, start_landmines_team3);
	start_landmines_team4 = max(0, start_landmines_team4);
	
	warmup_start_ammo_shells = max(0, warmup_start_ammo_shells);
	warmup_start_ammo_nails = max(0, warmup_start_ammo_nails);
	warmup_start_ammo_cells = max(0, warmup_start_ammo_cells);
	warmup_start_ammo_rockets = max(0, warmup_start_ammo_rockets);
	warmup_start_ammo_fuel = max(0, warmup_start_ammo_fuel);
	warmup_start_grenades = max(0, warmup_start_grenades);
	warmup_start_flashbangs = max(0, warmup_start_flashbangs);
	warmup_start_smokenades = max(0, warmup_start_smokenades);
	warmup_start_fragnades = max(0, warmup_start_fragnades);
	warmup_start_atmines = max(0, warmup_start_atmines);
	warmup_start_landmines = max(0, warmup_start_landmines);
}

float g_bugrigs;
float g_bugrigs_planar_movement;
float g_bugrigs_planar_movement_car_jumping;
float g_bugrigs_reverse_spinning;
float g_bugrigs_reverse_speeding;
float g_bugrigs_reverse_stopping;
float g_bugrigs_air_steering;
float g_bugrigs_angle_smoothing;
float g_bugrigs_friction_floor;
float g_bugrigs_friction_brake;
float g_bugrigs_friction_air;
float g_bugrigs_accel;
float g_bugrigs_speed_ref;
float g_bugrigs_speed_pow;
float g_bugrigs_steer;

float g_touchexplode;
float g_touchexplode_radius;
float g_touchexplode_damage;
float g_touchexplode_edgedamage;
float g_touchexplode_force;

float g_colorwar;

float g_door_rotating_nogibblocked;

float g_allow_shootfromside;

float g_weaponreplacedisabled;
float g_weaponreplaceallowabsolute;
float g_weaponreplaceabsoluteflag;

float g_doorsrequireuse;
float g_doorshealthignoreprisoners;

float bot_shootbreakable;
float bot_shootdestructable;

float sv_autotaunt;
float sv_taunt;

float sv_hudshownameenemies;

float sv_pitch_min;
float sv_pitch_max;
float sv_pitch_fixyaw;

string GetGametype(); // g_world.qc
void readlevelcvars(void)
{
	g_minstagib = cvar("g_minstagib");
	g_colorwar = cvar("g_colorwar");
	g_door_rotating_nogibblocked = cvar("g_door_rotating_nogibblocked");
	sv_hudshownameenemies = cvar("sv_hudshownameenemies");
	
	monster_skill = cvar("g_monsters_skill");

	// load ALL the mutators
	if(cvar("g_dodging"))
		MUTATOR_ADD(mutator_dodging);
	if(cvar("g_brawling"))
		MUTATOR_ADD(mutator_brawling);
	if(cvar("g_spawn_near_teammate"))
		MUTATOR_ADD(mutator_spawn_near_teammate);
	if(cvar("g_physical_items"))
		MUTATOR_ADD(mutator_physical_items);
	if(cvar("g_spawnfoliagearound"))
		MUTATOR_ADD(mutator_spawnfoliage);
	if(cvar("g_suggested_spawnfoliagearound"))
		MUTATOR_ADD(mutator_suggested_spawnfoliage);
	if(cvar("g_spawnmiscitemsaround"))
		MUTATOR_ADD(mutator_spawnmiscitems);
	if(cvar("g_skycycle"))
	{
		MUTATOR_ADD(mutator_skycycle);
		serverflags |= SERVERFLAG_ALLOW_FULLBRIGHT;
	}
	if(
	!(cvar("g_suggested_spawnfoliagearound")) &&
	!(cvar("g_spawnfoliagearound"))
	)
	{
		//Usuall spawn foliage mutators deal with the
		//waterlevel code, if they are not on there is a
		//stripped down mutator that can
		if((cvar("g_spawnfoliagearound_waterlevel"))
		|| (cvar("g_spawnfoliagearound_lavalevel"))
		|| (cvar("g_spawnfoliagearound_slimelevel"))
		|| (cvar("g_spawnfoliagearound_chemlevel"))
		|| (cvar("g_spawnfoliagearound_methanelevel"))
		|| (cvar("g_spawnfoliagearound_oillevel"))
		|| (cvar("g_suggested_spawnfoliagearound_waterlevel"))
		|| (cvar("g_suggested_spawnfoliagearound_lavalevel"))
		|| (cvar("g_suggested_spawnfoliagearound_slimelevel"))
		|| (cvar("g_suggested_spawnfoliagearound_chemlevel"))
		|| (cvar("g_suggested_spawnfoliagearound_methanelevel"))
		|| (cvar("g_suggested_spawnfoliagearound_oillevel")))
		{
			MUTATOR_ADD(mutator_waterlevel);
		}
	}
	if(!g_minstagib)
	{
		if(cvar("g_invincible_projectiles"))
			MUTATOR_ADD(mutator_invincibleprojectiles);
		if(cvar("g_new_toys"))
			MUTATOR_ADD(mutator_new_toys);
		if(cvar("g_nix"))
			MUTATOR_ADD(mutator_nix);
		if(cvar("g_rocket_flying"))
			MUTATOR_ADD(mutator_rocketflying);
		if(cvar("g_vampire"))
			MUTATOR_ADD(mutator_vampire);		
		if(cvar("g_superspectate"))
			MUTATOR_ADD(mutator_superspec);
		if(cvar("g_spawnvehiclesaround"))
			MUTATOR_ADD(mutator_spawnvehicles);
		if(cvar("g_spawnmountedgunsaround"))
			MUTATOR_ADD(mutator_spawnmountedguns);
		if(cvar("g_spawnturretsaround"))
			MUTATOR_ADD(mutator_spawnturrets);
		if(cvar("g_za"))
			MUTATOR_ADD(mutator_zombie_apocalypse);
		if(cvar("g_nades"))
			MUTATOR_ADD(mutator_nades);
	}

	// is this a mutator? is this a mode?
	if(cvar("g_sandbox"))
		MUTATOR_ADD(sandbox);

	if(cvar("sv_allow_fullbright"))
		serverflags |= SERVERFLAG_ALLOW_FULLBRIGHT;

    g_bugrigs = cvar("g_bugrigs");
    g_bugrigs_planar_movement = cvar("g_bugrigs_planar_movement");
    g_bugrigs_planar_movement_car_jumping = cvar("g_bugrigs_planar_movement_car_jumping");
    g_bugrigs_reverse_spinning = cvar("g_bugrigs_reverse_spinning");
    g_bugrigs_reverse_speeding = cvar("g_bugrigs_reverse_speeding");
    g_bugrigs_reverse_stopping = cvar("g_bugrigs_reverse_stopping");
    g_bugrigs_air_steering = cvar("g_bugrigs_air_steering");
    g_bugrigs_angle_smoothing = cvar("g_bugrigs_angle_smoothing");
    g_bugrigs_friction_floor = cvar("g_bugrigs_friction_floor");
    g_bugrigs_friction_brake = cvar("g_bugrigs_friction_brake");
    g_bugrigs_friction_air = cvar("g_bugrigs_friction_air");
    g_bugrigs_accel = cvar("g_bugrigs_accel");
    g_bugrigs_speed_ref = cvar("g_bugrigs_speed_ref");
    g_bugrigs_speed_pow = cvar("g_bugrigs_speed_pow");
    g_bugrigs_steer = cvar("g_bugrigs_steer");
    
    g_allow_shootfromside = cvar("g_allow_shootfromside");
    
    g_doorsrequireuse = cvar("g_doorsrequireuse");
    g_doorshealthignoreprisoners = cvar("g_doorshealthignoreprisoners");
    
    g_weaponreplacedisabled = cvar("g_weaponreplacedisabled");
    g_weaponreplaceallowabsolute = cvar("g_weaponreplaceallowabsolute");
    g_weaponreplaceabsoluteflag = cvar("g_weaponreplaceabsoluteflag");
    if ((!g_weaponreplaceabsoluteflag)
    || (g_weaponreplaceabsoluteflag == 0)
    || (g_weaponreplaceabsoluteflag == 1)
    || (g_weaponreplaceabsoluteflag < 2)) {
    	//This variable must be something other than 0 or 1 (floating)
    	g_weaponreplaceabsoluteflag = 1048576; //2^20, Arbitrary.
    }

    bot_shootbreakable = cvar("bot_shootbreakable");
    bot_shootdestructable = cvar("bot_shootbreakable");

    g_touchexplode = cvar("g_touchexplode");
    g_touchexplode_radius = cvar("g_touchexplode_radius");
    g_touchexplode_damage = cvar("g_touchexplode_damage");
    g_touchexplode_edgedamage = cvar("g_touchexplode_edgedamage");
    g_touchexplode_force = cvar("g_touchexplode_force");

#ifdef ALLOW_FORCEMODELS
	sv_clforceplayermodels = cvar("sv_clforceplayermodels");
#endif

	sv_clones = cvar("sv_clones");
	sv_gentle = cvar("sv_gentle");
	sv_foginterval = cvar("sv_foginterval");
	g_cloaked = cvar("g_cloaked");
    if(g_cts)
        g_cloaked = 1; // always enable cloak in CTS
	g_jump_grunt = cvar("g_jump_grunt");
	g_footsteps = cvar("g_footsteps");
	g_grappling_hook = cvar("g_grappling_hook");
	g_jetpack = cvar("g_jetpack");
	g_midair = cvar("g_midair");
	g_norecoil = cvar("g_norecoil");
	g_bloodloss = cvar("g_bloodloss");
	sv_maxidle = cvar("sv_maxidle");
	sv_maxidle_spectatorsareidle = cvar("sv_maxidle_spectatorsareidle");
	sv_autotaunt = cvar("sv_autotaunt");
	sv_taunt = cvar("sv_taunt");

	inWarmupStage = cvar("g_warmup");
	g_warmup_limit = cvar("g_warmup_limit");
	g_warmup_allguns = cvar("g_warmup_allguns");
	g_warmup_allow_timeout = cvar("g_warmup_allow_timeout");

	if ((g_race && g_race_qualifying == 2) || g_runematch || g_arena || g_assault || cvar("g_campaign"))
		inWarmupStage = 0; // these modes cannot work together, sorry

	g_pickup_respawntime_weapon = cvar("g_pickup_respawntime_weapon");
	g_pickup_respawntime_superweapon = cvar("g_pickup_respawntime_superweapon");
	g_pickup_respawntime_ammo = cvar("g_pickup_respawntime_ammo");
	g_pickup_respawntime_short = cvar("g_pickup_respawntime_short");
	g_pickup_respawntime_medium = cvar("g_pickup_respawntime_medium");
	g_pickup_respawntime_long = cvar("g_pickup_respawntime_long");
	g_pickup_respawntime_powerup = cvar("g_pickup_respawntime_powerup");
	g_pickup_respawntimejitter_weapon = cvar("g_pickup_respawntimejitter_weapon");
	g_pickup_respawntimejitter_superweapon = cvar("g_pickup_respawntimejitter_superweapon");
	g_pickup_respawntimejitter_ammo = cvar("g_pickup_respawntimejitter_ammo");
	g_pickup_respawntimejitter_short = cvar("g_pickup_respawntimejitter_short");
	g_pickup_respawntimejitter_medium = cvar("g_pickup_respawntimejitter_medium");
	g_pickup_respawntimejitter_long = cvar("g_pickup_respawntimejitter_long");
	g_pickup_respawntimejitter_powerup = cvar("g_pickup_respawntimejitter_powerup");
	
	g_pickup_respawntime_wealth = cvar("g_pickup_respawntime_wealth"); //Treasure like crowns, bullion
	g_pickup_respawntime_coin = cvar("g_pickup_respawntime_coin");
	g_pickup_respawntime_gem = cvar("g_pickup_respawntime_gem");
	g_pickup_respawntime_scroll = cvar("g_pickup_respawntime_scroll");
	g_pickup_respawntime_spellbook = cvar("g_pickup_respawntime_spellbook");
	g_pickup_respawntime_potion = cvar("g_pickup_respawntime_potion");
	g_pickup_respawntime_food = cvar("g_pickup_respawntime_food");
	g_pickup_respawntime_miscitem = cvar("g_pickup_respawntime_miscitem");

	g_weaponspeedfactor = cvar("g_weaponspeedfactor");
	g_weaponratefactor = cvar("g_weaponratefactor");
	g_weapondamagefactor = cvar("g_weapondamagefactor");
	g_weaponforcefactor = cvar("g_weaponforcefactor");
	g_weaponspreadfactor = cvar("g_weaponspreadfactor");
	g_weaponnomangleorhobble = cvar("g_weaponnomangleorhobble");

	g_pickup_shells = cvar("g_pickup_shells");
	g_pickup_shells_max = cvar("g_pickup_shells_max");
	g_pickup_nails = cvar("g_pickup_nails");
	g_pickup_nails_max = cvar("g_pickup_nails_max");
	g_pickup_rockets = cvar("g_pickup_rockets");
	g_pickup_rockets_max = cvar("g_pickup_rockets_max");
	g_pickup_cells = cvar("g_pickup_cells");
	g_pickup_cells_max = cvar("g_pickup_cells_max");
	g_pickup_fuel = cvar("g_pickup_fuel");
	g_pickup_fuel_jetpack = cvar("g_pickup_fuel_jetpack");
	g_pickup_fuel_max = cvar("g_pickup_fuel_max");
	g_pickup_armorsmall = cvar("g_pickup_armorsmall");
	g_pickup_armorsmall_max = cvar("g_pickup_armorsmall_max");
	g_pickup_armorsmall_anyway = cvar("g_pickup_armorsmall_anyway");
	g_pickup_armormedium = cvar("g_pickup_armormedium");
	g_pickup_armormedium_max = cvar("g_pickup_armormedium_max");
	g_pickup_armormedium_anyway = cvar("g_pickup_armormedium_anyway");
	g_pickup_armorbig = cvar("g_pickup_armorbig");
	g_pickup_armorbig_max = cvar("g_pickup_armorbig_max");
	g_pickup_armorbig_anyway = cvar("g_pickup_armorbig_anyway");
	g_pickup_armorlarge = cvar("g_pickup_armorlarge");
	g_pickup_armorlarge_max = cvar("g_pickup_armorlarge_max");
	g_pickup_armorlarge_anyway = cvar("g_pickup_armorlarge_anyway");
	g_pickup_healthsmall = cvar("g_pickup_healthsmall");
	g_pickup_healthsmall_max = cvar("g_pickup_healthsmall_max");
	g_pickup_healthsmall_anyway = cvar("g_pickup_healthsmall_anyway");
	g_pickup_healthmedium = cvar("g_pickup_healthmedium");
	g_pickup_healthmedium_max = cvar("g_pickup_healthmedium_max");
	g_pickup_healthmedium_anyway = cvar("g_pickup_healthmedium_anyway");
	g_pickup_healthlarge = cvar("g_pickup_healthlarge");
	g_pickup_healthlarge_max = cvar("g_pickup_healthlarge_max");
	g_pickup_healthlarge_anyway = cvar("g_pickup_healthlarge_anyway");
	g_pickup_healthmega = cvar("g_pickup_healthmega");
	g_pickup_healthmega_max = cvar("g_pickup_healthmega_max");
	g_pickup_healthmega_anyway = cvar("g_pickup_healthmega_anyway");

	g_pickup_ammo_anyway = cvar("g_pickup_ammo_anyway");
	g_pickup_weapons_anyway = cvar("g_pickup_weapons_anyway");

	g_pinata = cvar("g_pinata");

    g_weapon_stay = cvar(strcat("g_", GetGametype(), "_weapon_stay"));
    if(!g_weapon_stay)
        g_weapon_stay = cvar("g_weapon_stay");

	if not(inWarmupStage && !g_ca)
		game_starttime = cvar("g_start_delay");

	sv_pitch_min = cvar("sv_pitch_min");
	sv_pitch_max = cvar("sv_pitch_max");
	sv_pitch_fixyaw = cvar("sv_pitch_fixyaw");

	readplayerstartcvars();
}

//#NO AUTOCVARS END

// Sound functions
string precache_sound (string s) = #19;
float precache_sound_index (string s) = #19;

#define SND_VOLUME      1
#define SND_ATTENUATION 2
#define SND_LARGEENTITY 8
#define SND_LARGESOUND  16

float sound_allowed(float dest, entity e)
{
    local float mycounter = 0; //We shouldn't need this
    // sounds from world may always pass
    for (;;)
    {
        if (e.classname == "body")
            e = e.enemy;
	else if (e.realowner && e.realowner != e)
            e = e.realowner;
	else if (e.owner && e.owner != e)
            e = e.owner;
        else
            break;
	    
	mycounter++; //We shouldn't need this
	
	if (mycounter > 1000) {
		//This is some code to limit a runaway loop that happens sometimes
		//Usually involving a flameburst, but potentially other times too
		//
		//I don't believe we should get here
		//For normal things the correct "count usually seems to be 0 or 1...
		//(sometimes a 2 when an explosive goes off...., esp ones with fragments)
		//(sometimes a 3, or a 4)
		//But for a flame burst going off at once on 3 skeletons in the middle...
		//
		//Well.. the code shoots for the moon...
		//
		////server Profile:
		////[CallCount] [Statement] [BuiltinCt] [StmtTotal] [BltnTotal] [self]
		////Host_Error: server runaway loop counter hit limit of 10000000 jumps
		////tip: read above for list of most-executed functions
		////QuakeC crash report for server:
		////s153150: miscfunctions.qc:1887: FIELD_S    GLOBAL57167, classname (=.classname), GLOBAL57141
		////s153151: miscfunctions.qc:1887: EQ_S       GLOBAL57141, GLOBAL32837, GLOBAL57141
		////s153152: miscfunctions.qc:1887: IFNOT      GLOBAL57141, statement 153155
		////s153153: miscfunctions.qc:1888: FIELD_ENT  GLOBAL57167, enemy (=.enemy), GLOBAL57167
		////s153154: miscfunctions.qc:1885: GOTO       , statement 153150
		////miscfunctions.qc:1885 : sound_allowed : statement 4
		////g_violence.qc:44 : Violence_GibSplash_At : statement 13
		////lib/monsters.qc:2012 : monsters_gibdamage : statement 45
 		////g_damage.qc:2202 : Damage : statement 237
 		////g_damage.qc:2829 : Fire_ApplyDamage : statement 86
 		////g_damage.qc:3105 : fireburner_think : statement 12
		//
		//See that dedication, that... will to do what others thought could not be done
		//To achieve something other than a zero or a one...
		//Some are more than just existing or not...
		//Some are...
		//
		//This also seems to happen if you are playing the game
		//But then a flight of fancy hits you....
		//You change to another workspace for awhile
		//You come back and your game is crashed from this loop
		//...
		//Not anymore (we hope!)
		//
		//Might aswell put a break in this loop...
		//
		//mycounter > values:
		//2000000 too high, hits counter
		//1000000 nope
		//500000 seems to be ok
		//200000 ok usually... but crashed too after much not-crashing
		//("Crash" meaning hit loop counter)
		////[CallCount] [Statement] [BuiltinCt] [StmtTotal] [BltnTotal] [self]
		////Host_Error: server runaway loop counter hit limit of 10000000 jumps
		////tip: read above for list of most-executed functions
		////QuakeC crash report for server:
		////s153167: miscfunctions.qc:1954: IFNOT      autocvar_bot_sound_monopoly (=0), statement 153173
		////s153168: miscfunctions.qc:1955: STORE_ENT  GLOBAL57154, GLOBAL4
		////s153169: miscfunctions.qc:1955: CALL1      clienttype (=clienttype())
		////s153170: miscfunctions.qc:1955: EQ_F       GLOBAL1, GLOBAL457, GLOBAL57128
		////s153171: miscfunctions.qc:1955: IFNOT      GLOBAL57128, statement 153173
		////s153172: miscfunctions.qc:1956: RETURN     GLOBAL94
		////s153173: miscfunctions.qc:1958: RETURN     GLOBAL95
		////s153174: miscfunctions.qc:1886: GOTO       , statement 153151
		////miscfunctions.qc:1886 : sound_allowed : statement 24
		////lib/monsters.qc:2112 : monsters_damage : statement 657
		//// g_damage.qc:2202 : Damage : statement 237
		////w_shortsword.qc:196 : shortsword_meleethink : statement 658
		////w_shortsword.qc:260 : shortsword_primarythink : statement 4
		//
		//Trying 20000
		//20000 is good, but do we need it so high?
		print("Was on the way to 10000000!\n");
		break;
	}
    }
    
    ////if (mycounter > 1) {
    ////	print(ftos(mycounter),"\n");
    ////}
    
    // sounds to self may always pass
    if (dest == MSG_ONE)
        if (e == msg_entity)
            return TRUE;
    // sounds by players can be removed
    if (autocvar_bot_sound_monopoly)
        if (clienttype(e) == CLIENTTYPE_REAL)
            return FALSE;
    // anything else may pass
    return TRUE;
}

#ifdef COMPAT_XON010_CHANNELS
void(entity e, float chan, string samp, float vol, float atten) builtin_sound = #8;
void sound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;
    builtin_sound(e, chan, samp, vol, atten);
}
#else
#undef sound
void sound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;
    sound7(e, chan, samp, vol, atten, 0, 0);
}
#endif

void soundtoat(float dest, entity e, vector o, float chan, string samp, float vol, float atten)
{
    float entno, idx;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);
    idx = precache_sound_index(samp);

    float sflags;
    sflags = 0;

    atten = floor(atten * 64);
    vol = floor(vol * 255);

    if (vol != 255)
        sflags |= SND_VOLUME;
    if (atten != 64)
        sflags |= SND_ATTENUATION;
    if (entno >= 8192 || chan < 0 || chan > 7)
        sflags |= SND_LARGEENTITY;
    if (idx >= 256)
        sflags |= SND_LARGESOUND;

    WriteByte(dest, SVC_SOUND);
    WriteByte(dest, sflags);
    if (sflags & SND_VOLUME)
        WriteByte(dest, vol);
    if (sflags & SND_ATTENUATION)
        WriteByte(dest, atten);
    if (sflags & SND_LARGEENTITY)
    {
        WriteShort(dest, entno);
        WriteByte(dest, chan);
    }
    else
    {
        WriteShort(dest, entno * 8 + chan);
    }
    if (sflags & SND_LARGESOUND)
        WriteShort(dest, idx);
    else
        WriteByte(dest, idx);

    WriteCoord(dest, o_x);
    WriteCoord(dest, o_y);
    WriteCoord(dest, o_z);
}
void soundto(float dest, entity e, float chan, string samp, float vol, float atten)
{
    vector o;

    if (!sound_allowed(dest, e))
        return;

    o = e.origin + 0.5 * (e.mins + e.maxs);
    soundtoat(dest, e, o, chan, samp, vol, atten);
}
void soundat(entity e, vector o, float chan, string samp, float vol, float atten)
{
    soundtoat(((chan & 8) ? MSG_ALL : MSG_BROADCAST), e, o, chan, samp, vol, atten);
}
void stopsoundto(float dest, entity e, float chan)
{
    float entno;

    if (!sound_allowed(dest, e))
        return;

    entno = num_for_edict(e);

    if (entno >= 8192 || chan < 0 || chan > 7)
    {
        float idx, sflags;
        idx = precache_sound_index("misc/null.wav");
        sflags = SND_LARGEENTITY;
        if (idx >= 256)
            sflags |= SND_LARGESOUND;
        WriteByte(dest, SVC_SOUND);
        WriteByte(dest, sflags);
        WriteShort(dest, entno);
        WriteByte(dest, chan);
        if (sflags & SND_LARGESOUND)
            WriteShort(dest, idx);
        else
            WriteByte(dest, idx);
        WriteCoord(dest, e.origin_x);
        WriteCoord(dest, e.origin_y);
        WriteCoord(dest, e.origin_z);
    }
    else
    {
        WriteByte(dest, SVC_STOPSOUND);
        WriteShort(dest, entno * 8 + chan);
    }
}
void stopsound(entity e, float chan)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return;

    stopsoundto(MSG_BROADCAST, e, chan); // unreliable, gets there fast
    stopsoundto(MSG_ALL, e, chan); // in case of packet loss
}

void play2(entity e, string filename)
{
    //stuffcmd(e, strcat("play2 ", filename, "\n"));
    msg_entity = e;
    soundtoat(MSG_ONE, world, '0 0 0', CH_INFO, filename, VOL_BASE, ATTN_NONE);
}

// use this one if you might be causing spam (e.g. from touch functions that might get called more than once per frame)
.float spamtime;
float spamsound(entity e, float chan, string samp, float vol, float atten)
{
    if (!sound_allowed(MSG_BROADCAST, e))
        return FALSE;

    if (time > e.spamtime)
    {
        e.spamtime = time;
        sound(e, chan, samp, vol, atten);
        return TRUE;
    }
    return FALSE;
}

void play2team(float t, string filename)
{
    entity head;

    if (autocvar_bot_sound_monopoly)
        return;

    FOR_EACH_REALPLAYER(head)
    {
        if (head.team == t)
            play2(head, filename);
    }
}

void play2all(string samp)
{
    if (autocvar_bot_sound_monopoly)
        return;

    sound(world, CH_INFO, samp, VOL_BASE, ATTN_NONE);
}

void PrecachePlayerSounds(string f);
void precache_playermodel(string m)
{
	float globhandle, i, n;
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

void precache()
{
    // gamemode related things
    precache_model ("models/misc/chatbubble.spr");
    if (g_runematch)
    {
        precache_model ("models/runematch/curse.mdl");
        precache_model ("models/runematch/rune.mdl");
    }

#ifdef TTURRETS_ENABLED
    if (autocvar_g_turrets)
        turrets_precash();
#endif

    // Precache all player models if desired
    if (autocvar_sv_precacheplayermodels)
    {
        PrecachePlayerSounds("sound/player/default.sounds");
        precache_all_playermodels("models/player/*.zym");
        precache_all_playermodels("models/player/*.dpm");
        precache_all_playermodels("models/player/*.md3");
        precache_all_playermodels("models/player/*.psk");
        precache_all_playermodels("models/player/*.iqm");
    }

    if (autocvar_sv_defaultcharacter)
    {
        string s;
        s = autocvar_sv_defaultplayermodel_red;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_blue;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_yellow;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel_pink;
        if (s != "")
            precache_playermodel(s);
        s = autocvar_sv_defaultplayermodel;
        if (s != "")
            precache_playermodel(s);
    }

    if (g_footsteps)
    {
        PrecacheGlobalSound((globalsound_step = "misc/footstep0 6"));
        PrecacheGlobalSound((globalsound_metalstep = "misc/metalfootstep0 6"));
    }

    // gore and miscellaneous sounds
    //precache_sound ("misc/h2ohit.wav");
    precache_model ("models/hook.md3");
    precache_sound ("misc/armorimpact.wav");
    precache_sound ("misc/bodyimpact1.wav");
    precache_sound ("misc/bodyimpact2.wav");
    precache_sound ("misc/gib.wav");
    precache_sound ("misc/gib_splat01.wav");
    precache_sound ("misc/gib_splat02.wav");
    precache_sound ("misc/gib_splat03.wav");
    precache_sound ("misc/gib_splat04.wav");
    PrecacheGlobalSound((globalsound_fall = "misc/hitground 4"));
    PrecacheGlobalSound((globalsound_metalfall = "misc/metalhitground 4"));
    precache_sound ("misc/null.wav");
    precache_sound ("misc/spawn.wav");
    precache_sound ("misc/talk.wav");
    precache_sound ("misc/teleport.wav");
    precache_sound ("misc/poweroff.wav");
    precache_sound ("player/lava.wav");
    precache_sound ("player/slime.wav");

    precache_model ("models/sprites/0.spr32");
    precache_model ("models/sprites/1.spr32");
    precache_model ("models/sprites/2.spr32");
    precache_model ("models/sprites/3.spr32");
    precache_model ("models/sprites/4.spr32");
    precache_model ("models/sprites/5.spr32");
    precache_model ("models/sprites/6.spr32");
    precache_model ("models/sprites/7.spr32");
    precache_model ("models/sprites/8.spr32");
    precache_model ("models/sprites/9.spr32");
    precache_model ("models/sprites/10.spr32");

    // common weapon precaches
	precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound here
    precache_sound ("weapons/weapon_switch.wav");
    precache_sound ("weapons/weaponpickup.wav");
    precache_sound ("weapons/unavailable.wav");
    precache_sound ("weapons/dryfire.wav");
    if (g_grappling_hook)
    {
        precache_sound ("weapons/hook_fire.wav"); // hook
        precache_sound ("weapons/hook_impact.wav"); // hook
    }

    if(autocvar_sv_precacheweapons)
    {
        //precache weapon models/sounds
        float wep;
        wep = WEP_FIRST;
        while (wep <= WEP_LAST)
        {
            weapon_action(wep, WR_PRECACHE);
            wep = wep + 1;
        }
    }

    precache_model("models/elaser.mdl");
    precache_model("models/laser.mdl");
    precache_model("models/ebomb.mdl");

#if 0
    // Disabled this code because it simply does not work (e.g. ignores bgmvolume, overlaps with "cd loop" controlled tracks).

    if (!self.noise && self.music) // quake 3 uses the music field
        self.noise = self.music;

    // plays music for the level if there is any
    if (self.noise)
    {
        precache_sound (self.noise);
        ambientsound ('0 0 0', self.noise, VOL_BASE, ATTN_NONE);
    }
#endif
}

// sorry, but using \ in macros breaks line numbers
#define WRITESPECTATABLE_MSG_ONE_VARNAME(varname,statement) entity varname; varname = msg_entity; FOR_EACH_REALCLIENT(msg_entity) if(msg_entity == varname || (msg_entity.classname == STR_SPECTATOR && msg_entity.enemy == varname)) statement msg_entity = varname
#define WRITESPECTATABLE_MSG_ONE(statement) WRITESPECTATABLE_MSG_ONE_VARNAME(oldmsg_entity, statement)
#define WRITESPECTATABLE(msg,statement) if(msg == MSG_ONE) { WRITESPECTATABLE_MSG_ONE(statement); } else statement float WRITESPECTATABLE_workaround = 0


void Send_CSQC_Centerprint_Generic(entity e, float id, string s, float duration, float countdown_num)
{
	if ((clienttype(e) == CLIENTTYPE_REAL) && (e.flags & FL_CLIENT))
	{
		msg_entity = e;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_CENTERPRINT_GENERIC);
			WriteByte(MSG_ONE, id);
			WriteString(MSG_ONE, s);
			if (id != 0 && s != "")
			{
				WriteByte(MSG_ONE, duration);
				WriteByte(MSG_ONE, countdown_num);
			}
		});
	}
}
void Send_CSQC_Centerprint_Generic_Expire(entity e, float id)
{
	Send_CSQC_Centerprint_Generic(e, id, "", 1, 0);
}
// WARNING: this kills the trace globals
#define EXACTTRIGGER_TOUCH if(WarpZoneLib_ExactTrigger_Touch()) return
#define EXACTTRIGGER_INIT  WarpZoneLib_ExactTrigger_Init()

#define INITPRIO_FIRST              0
#define INITPRIO_GAMETYPE           0
#define INITPRIO_GAMETYPE_FALLBACK  1
#define INITPRIO_FINDTARGET        10
#define INITPRIO_DROPTOFLOOR       20
#define INITPRIO_SETLOCATION       90
#define INITPRIO_LINKDOORS         91
#define INITPRIO_LAST              99

.void(void) initialize_entity;
.float initialize_entity_order;
.entity initialize_entity_next;
entity initialize_entity_first;

void make_safe_for_remove(entity e)
{
    if (e.initialize_entity)
    {
        entity ent, prev = world;
        for (ent = initialize_entity_first; ent; )
        {
            if ((ent == e) || ((ent.classname == "initialize_entity") && (ent.enemy == e)))
            {
                //print("make_safe_for_remove: getting rid of initializer ", etos(ent), "\n");
                // skip it in linked list
                if (prev)
                {
                    prev.initialize_entity_next = ent.initialize_entity_next;
                    ent = prev.initialize_entity_next;
                }
                else
                {
                    initialize_entity_first = ent.initialize_entity_next;
                    ent = initialize_entity_first;
                }
            }
            else
            {
                prev = ent;
                ent = ent.initialize_entity_next;
            }
        }
    }
}

void objerror(string s)
{
    make_safe_for_remove(self);
    builtin_objerror(s);
}

.float remove_except_protected_forbidden;
void remove_except_protected(entity e)
{
	if(e.remove_except_protected_forbidden)
		error("not allowed to remove this at this point");
	builtin_remove(e);
}

void remove_unsafely(entity e)
{
    if(e.classname == "spike")
        error("Removing spikes is forbidden (crylink bug), please report");
    builtin_remove(e);
}

void remove_safely(entity e)
{
    make_safe_for_remove(e);
    builtin_remove(e);
}

void InitializeEntity(entity e, void(void) func, float order)
{
    entity prev, cur;

    if (!e || e.initialize_entity)
    {
        // make a proxy initializer entity
        entity e_old;
        e_old = e;
        e = spawn();
        e.classname = "initialize_entity";
        e.enemy = e_old;
    }

    e.initialize_entity = func;
    e.initialize_entity_order = order;

    cur = initialize_entity_first;
    prev = world;
    for (;;)
    {
        if (!cur || cur.initialize_entity_order > order)
        {
            // insert between prev and cur
            if (prev)
                prev.initialize_entity_next = e;
            else
                initialize_entity_first = e;
            e.initialize_entity_next = cur;
            return;
        }
        prev = cur;
        cur = cur.initialize_entity_next;
    }
}
void InitializeEntitiesRun()
{
    entity startoflist;
    startoflist = initialize_entity_first;
    initialize_entity_first = world;
    remove = remove_except_protected;
    for (self = startoflist; self; self = self.initialize_entity_next)
    {
	self.remove_except_protected_forbidden = 1;
    }
    for (self = startoflist; self; )
    {
        entity e;
        var void(void) func;
        e = self.initialize_entity_next;
        func = self.initialize_entity;
        self.initialize_entity_order = 0;
        self.initialize_entity = func_null;
        self.initialize_entity_next = world;
	self.remove_except_protected_forbidden = 0;
        if (self.classname == "initialize_entity")
        {
            entity e_old;
            e_old = self.enemy;
            builtin_remove(self);
            self = e_old;
        }
        //dprint("Delayed initialization: ", self.classname, "\n");
        if(func)
            func();
        else
        {
            eprint(self);
            backtrace(strcat("Null function in: ", self.classname, "\n"));
        }
        self = e;
    }
    remove = remove_unsafely;
}

.float uncustomizeentityforclient_set;
.void(void) uncustomizeentityforclient;
void UncustomizeEntitiesRun()
{
    entity oldself;
    oldself = self;
    for (self = world; (self = findfloat(self, uncustomizeentityforclient_set, 1)); )
        self.uncustomizeentityforclient();
    self = oldself;
}
void SetCustomizer(entity e, float(void) customizer, void(void) uncustomizer)
{
    e.customizeentityforclient = customizer;
    e.uncustomizeentityforclient = uncustomizer;
    e.uncustomizeentityforclient_set = !!uncustomizer;
}

.float nottargeted;
#define IFTARGETED if(!self.nottargeted && self.targetname != "")

void() SUB_Remove;
void Net_LinkEntity(entity e, float docull, float dt, float(entity, float) sendfunc)
{
    vector mi, ma;

    if (e.classname == "")
        e.classname = "net_linked";

    if (e.model == "" || self.modelindex == 0)
    {
        mi = e.mins;
        ma = e.maxs;
        setmodel(e, "null");
        setsize(e, mi, ma);
    }

    e.SendEntity = sendfunc;
    e.SendFlags = 0xFFFFFF;

    if (!docull)
        e.effects |= EF_NODEPTHTEST;

    if (dt)
    {
        e.nextthink = time + dt;
        e.think = SUB_Remove;
    }
}

void adaptor_think2touch()
{
    entity o;
    o = other;
    other = world;
    self.touch();
    other = o;
}

void adaptor_think2use()
{
    entity o, a;
    o = other;
    a = activator;
    activator = world;
    other = world;
    self.use();
    other = o;
    activator = a;
}

void adaptor_think2use_hittype_splash() // for timed projectile detonation
{
	if not(self.flags & FL_ONGROUND) // if onground, we ARE touching something, but HITTYPE_SPLASH is to be networked if the damage causing projectile is not touching ANYTHING
		self.projectiledeathtype |= HITTYPE_SPLASH;
	adaptor_think2use();
}

// deferred dropping
void DropToFloor_Handler()
{
    builtin_droptofloor();
    self.dropped_origin = self.origin;
}

void droptofloor()
{
    InitializeEntity(self, DropToFloor_Handler, INITPRIO_DROPTOFLOOR);
}



float trace_hits_box_a0, trace_hits_box_a1;

float trace_hits_box_1d(float end, float thmi, float thma)
{
    if (end == 0)
    {
        // just check if x is in range
        if (0 < thmi)
            return FALSE;
        if (0 > thma)
            return FALSE;
    }
    else
    {
        // do the trace with respect to x
        // 0 -> end has to stay in thmi -> thma
        trace_hits_box_a0 = max(trace_hits_box_a0, min(thmi / end, thma / end));
        trace_hits_box_a1 = min(trace_hits_box_a1, max(thmi / end, thma / end));
        if (trace_hits_box_a0 > trace_hits_box_a1)
            return FALSE;
    }
    return TRUE;
}

float trace_hits_box(vector start, vector end, vector thmi, vector thma)
{
    end -= start;
    thmi -= start;
    thma -= start;
    // now it is a trace from 0 to end

    trace_hits_box_a0 = 0;
    trace_hits_box_a1 = 1;

    if (!trace_hits_box_1d(end_x, thmi_x, thma_x))
        return FALSE;
    if (!trace_hits_box_1d(end_y, thmi_y, thma_y))
        return FALSE;
    if (!trace_hits_box_1d(end_z, thmi_z, thma_z))
        return FALSE;

    return TRUE;
}

float tracebox_hits_box(vector start, vector mi, vector ma, vector end, vector thmi, vector thma)
{
    return trace_hits_box(start, end, thmi - ma, thma - mi);
}

float SUB_NoImpactCheck()
{
	// zero hitcontents = this is not the real impact, but either the
	// mirror-impact of something hitting the projectile instead of the
	// projectile hitting the something, or a touchareagrid one. Neither of
	// these stop the projectile from moving, so...
	if(trace_dphitcontents == 0)
	{
		//dprint("A hit happened with zero hit contents... DEBUG THIS, this should never happen for projectiles! Projectile will self-destruct.\n");
		dprint(sprintf(_("A hit from a projectile happened with no hit contents! DEBUG THIS, this should never happen for projectiles! Profectile will self-destruct. (edict: %d, classname: %s, origin: %s)\n"), num_for_edict(self), self.classname, vtos(self.origin)));
		checkclient();
	}
    if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        return 1;
    if (other.noimpactingprojectiles)
    	return 1;
    if (other == world && self.size != '0 0 0')
    {
        vector tic;
        tic = self.velocity * sys_frametime;
        tic = tic + normalize(tic) * vlen(self.maxs - self.mins);
        traceline(self.origin - tic, self.origin + tic, MOVE_NORMAL, self);
        if (trace_fraction >= 1)
        {
            dprint("Odd... did not hit...?\n");
        }
        else if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
        {
            dprint("Detected and prevented the sky-grapple bug.\n");
            return 1;
        }
    }

    return 0;
}

#define SUB_OwnerCheck() (other && (other == self.owner))

void RemoveGrapplingHook(entity pl);
void W_Crylink_Dequeue(entity e);
float WarpZone_Projectile_Touch_ImpactFilter_Callback()
{
	if(SUB_OwnerCheck())
		return TRUE;
	if(SUB_NoImpactCheck())
	{
		if(self.classname == "grapplinghook")
			RemoveGrapplingHook(self.realowner);
		else if(self.classname == "spike")
		{
			W_Crylink_Dequeue(self);
			remove(self);
		}
		else
			remove(self);
		return TRUE;
	}
	if(trace_ent && trace_ent.solid > SOLID_TRIGGER)
		UpdateCSQCProjectile(self);
	return FALSE;
}
#define PROJECTILE_TOUCH if(WarpZone_Projectile_Touch()) return

#define ITEM_TOUCH_NEEDKILL() (((trace_dpstartcontents | trace_dphitcontents) & DPCONTENTS_NODROP) || (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY))
#define ITEM_DAMAGE_NEEDKILL(dt) (((dt) == DEATH_HURTTRIGGER) || ((dt) == DEATH_HURTLASER) || ((dt) == DEATH_CRUSH) || ((dt) == DEATH_SLIME) || ((dt) == DEATH_LAVA) || ((dt) == DEATH_SWAMP))

void URI_Get_Callback(float id, float status, string data)
{
	if(url_URI_Get_Callback(id, status, data))
	{
		// handled
	}
	else if (id == URI_GET_DISCARD)
	{
		// discard
	}
	else if (id >= URI_GET_CURL && id <= URI_GET_CURL_END)
	{
		// sv_cmd curl
		Curl_URI_Get_Callback(id, status, data);
	}
	else if (id >= URI_GET_IPBAN && id <= URI_GET_IPBAN_END)
	{
		// online ban list
		OnlineBanList_URI_Get_Callback(id, status, data);
	}
	else
	{
		print("Received HTTP request data for an invalid id ", ftos(id), ".\n");
	}
}

string uid2name(string myuid) {
	string s;
	s = db_get(ServerProgsDB, strcat("/uid2name/", myuid));

	// FIXME remove this later after 0.6 release
	// convert old style broken records to correct style
	if(s == "")
	{
		s = db_get(ServerProgsDB, strcat("uid2name", myuid));
		if(s != "")
		{
			db_put(ServerProgsDB, strcat("/uid2name/", myuid), s);
			db_put(ServerProgsDB, strcat("uid2name", myuid), "");
		}
	}
	
	if(s == "")
		s = "^1Unregistered Player";
	return s;
}

float race_readTime(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return stof(db_get(ServerProgsDB, strcat(map, rr, "time", ftos(pos))));
}

string race_readUID(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return db_get(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(pos)));
}

float race_readPos(string map, float t) {
	float i;
	for (i = 1; i <= RANKINGS_CNT; ++i)
		if (race_readTime(map, i) == 0 || race_readTime(map, i) > t)
			return i;

	return 0; // pos is zero if unranked
}

void race_writeTime(string map, float t, string myuid)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	float newpos;
	newpos = race_readPos(map, t);

	float i, prevpos = 0;
	for(i = 1; i <= RANKINGS_CNT; ++i)
	{
		if(race_readUID(map, i) == myuid)
			prevpos = i;
	}
	if (prevpos) { // player improved his existing record, only have to iterate on ranks between new and old recs
		for (i = prevpos; i > newpos; --i) {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), ftos(race_readTime(map, i - 1)));
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), race_readUID(map, i - 1));
		}
	} else { // player has no ranked record yet
		for (i = RANKINGS_CNT; i > newpos; --i) {
			db_put(ServerProgsDB, strcat(map, rr, "time", ftos(i)), ftos(race_readTime(map, i - 1)));
			db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(i)), race_readUID(map, i - 1));
		}
	}

	// store new time itself
	db_put(ServerProgsDB, strcat(map, rr, "time", ftos(newpos)), ftos(t));
	db_put(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(newpos)), myuid);
}

string race_readName(string map, float pos)
{
	string rr;
	if(g_cts)
		rr = CTS_RECORD;
	else
		rr = RACE_RECORD;

	return uid2name(db_get(ServerProgsDB, strcat(map, rr, "crypto_idfp", ftos(pos))));
}

string race_placeName(float pos) {
	if(floor((mod(pos, 100))/10) * 10 != 10) // examples: 12th, 111th, 213th will not execute this block
	{
		if(mod(pos, 10) == 1)
			return strcat(ftos(pos), "st");
		else if(mod(pos, 10) == 2)
			return strcat(ftos(pos), "nd");
		else if(mod(pos, 10) == 3)
			return strcat(ftos(pos), "rd");
		else
			return strcat(ftos(pos), "th");
	}
	else
		return strcat(ftos(pos), "th");
}

float MoveToRandomMapLocation(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = world.mins;
    delta = world.maxs - world.mins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;

	// rule 4: we must "see" some spawnpoint
	for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
		if(checkpvs(mstart, sp))
			break;
	if(!sp)
	{
		for(sp = world; (sp = findflags(sp, flags, FL_ITEM)); )
			if(checkpvs(mstart, sp))
				break;
		if(!sp)
			continue;
	}

        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        // rule 5: don't want to look at sky
        if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
            continue;

        // rule 6: we must not end up in trigger_hurt
        if (tracebox_hits_trigger_hurt(start, e.mins, e.maxs, enddown))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("Needed ", ftos(i + 1), " attempts\n");
        return TRUE;
    }
    else
        return FALSE;
}

//This is similar to the above, but you set your own limits
float MoveToRandomMapLocationLimits(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance, vector mymins, vector mymaxs, float ignorespawnpointrule)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = mymins;
    delta = mymaxs - mymins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;

	if not (ignorespawnpointrule) {
	
		// rule 4: we must "see" some spawnpoint
		for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
			if(checkpvs(mstart, sp))
				break;
				
	} else if (ignorespawnpointrule == 2) {
		// rule 4: we must "see" some notnull entity instead
		for(sp = world; (sp = find(sp, classname, "info_notnull")); )
			if(checkpvs(mstart, sp))
				break;
	} else if (ignorespawnpointrule == 3) {
		for(sp = world; (sp = find(sp, classname, "info_notnull")); )
			if(checkpvs(mstart, sp))
				break;
		
		if(!sp)
			for(sp = world; (sp = findflags(sp, flags, FL_ITEM)); )
				if(checkpvs(mstart, sp))
					break;
					
		if(!sp)
			for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
				if(checkpvs(mstart, sp))
					break;
		
		if(!sp)
			for(sp = world; (sp = find(sp, classname, "func_pointparticles")); )
				if(checkpvs(mstart, sp))
					break;
					
		if(!sp)
			for(sp = world; (sp = find(sp, classname, "func_door_rotating")); )
				if(checkpvs(mstart, sp))
					break;
					
		if(!sp)
			continue;
			
			
	} 
	
	if (ignorespawnpointrule == 4) {
		//Do nothing
	} else if(!sp)
	{
		for(sp = world; (sp = findflags(sp, flags, FL_ITEM)); )
			if(checkpvs(mstart, sp))
				break;
		if(!sp)
			continue;
	}

        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        // rule 5: don't want to look at sky
        if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
            continue;

        // rule 6: we must not end up in trigger_hurt
        if (tracebox_hits_trigger_hurt(start, e.mins, e.maxs, enddown))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("NeEDED ", ftos(i + 1), " AtTEMPTS\n"); //Caps so we know which sub we're in if we want to check
        return TRUE;
    }
    else
        return FALSE;
}

//This is similar to the above,: you set your own limits, But there are few disqualifying rules
float MoveToRandomMapLocationLimitsFewRules(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance, vector mymins, vector mymaxs)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = mymins;
    delta = mymaxs - mymins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;


        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("NeEDED ", ftos(i + 1), " AtTEMPTS\n"); //Caps so we know which sub we're in if we want to check
        return TRUE;
    }
    else
        return FALSE;
}


//This is similar to the above,: you set your own limits, But there are few disqualifying rules
//Allows starting in solid
float MoveToRandomMapLocationLimitsFewRulesCanStartInSolid(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance, vector mymins, vector mymaxs)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = mymins;
    delta = mymaxs - mymins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;

        // rule 1: start inside world bounds, and outside
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;


        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);

        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("NeEDED ", ftos(i + 1), " AtTEMPTS\n"); //Caps so we know which sub we're in if we want to check
        return TRUE;
    }
    else
        return FALSE;
}



float isWithinRadiusXY(float myx, float myy, float myoriginx, float myoriginy, float myradius)
{
	////(x - origin_x)^2 + (y - origin_y)^2 < radius^2
	if ((pow((myx - myoriginx), 2) + pow((myy - myoriginy), 2)) < (pow(myradius, 2)))
	{
		return TRUE;
	} else {
		return FALSE;
	}
}

//This is similar to the above, but you set your own limits AND radius (XY) (and centerpoint)
//Thus you can define circles, trunucated boxes, etc by defining where the centerpoint is and radius
//You can also invert the circle and only be outside of it (but within the limits of the box)
float MoveToRandomMapLocationLimitsRadius(entity e, float goodcontents, float badcontents, float badsurfaceflags, float attempts, float maxaboveground, float minviewdistance, vector mymins, vector mymaxs, float ignorespawnpointrule, vector myorigin, float myradius, float cinvert)
{
    float m, i;
    vector start, org, delta, end, enddown, mstart;
    entity sp;

    m = e.dphitcontentsmask;
    e.dphitcontentsmask = goodcontents | badcontents;

    org = mymins;
    delta = mymaxs - mymins;

    start = end = org;

    for (i = 0; i < attempts; ++i)
    {
        start_x = org_x + random() * delta_x;
        start_y = org_y + random() * delta_y;
        start_z = org_z + random() * delta_z;
	
	
	
	if (!cinvert && !isWithinRadiusXY(start_x, start_y, myorigin_x, myorigin_y, myradius))
	{
		//Rule 0: be within radius	
		continue;
	} else if (cinvert && isWithinRadiusXY(start_x, start_y, myorigin_x, myorigin_y, myradius))
	{
		//Rule 0: be without radius	
		continue;
	}

        // rule 1: start inside world bounds, and outside
        // solid, and don't start from somewhere where you can
        // fall down to evil
        tracebox(start, e.mins, e.maxs, start - '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        if (trace_startsolid)
            continue;
        if (trace_dphitcontents & badcontents)
            continue;
        if (trace_dphitq3surfaceflags & badsurfaceflags)
            continue;

        // rule 2: if we are too high, lower the point
        if (trace_fraction * delta_z > maxaboveground)
            start = trace_endpos + '0 0 1' * maxaboveground;
        enddown = trace_endpos;

        // rule 3: make sure we aren't outside the map. This only works
        // for somewhat well formed maps. A good rule of thumb is that
        // the map should have a convex outside hull.
        // these can be traceLINES as we already verified the starting box
        mstart = start + 0.5 * (e.mins + e.maxs);
        traceline(mstart, mstart + '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '1 0 0' * delta_x, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart - '0 1 0' * delta_y, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;
        traceline(mstart, mstart + '0 0 1' * delta_z, MOVE_NORMAL, e);
        if (trace_fraction >= 1)
            continue;

	if not (ignorespawnpointrule) {
	
		// rule 4: we must "see" some spawnpoint
		for(sp = world; (sp = find(sp, classname, "info_player_deathmatch")); )
			if(checkpvs(mstart, sp))
				break;
				
	} else if (ignorespawnpointrule == 2) {
		// rule 4: we must "see" some notnull entity instead
		for(sp = world; (sp = find(sp, classname, "info_notnull")); )
			if(checkpvs(mstart, sp))
				break;
	}
	
	if(!sp)
	{
		for(sp = world; (sp = findflags(sp, flags, FL_ITEM)); )
			if(checkpvs(mstart, sp))
				break;
		if(!sp)
			continue;
	}

        // find a random vector to "look at"
        end_x = org_x + random() * delta_x;
        end_y = org_y + random() * delta_y;
        end_z = org_z + random() * delta_z;
        end = start + normalize(end - start) * vlen(delta);

        // rule 4: start TO end must not be too short
        tracebox(start, e.mins, e.maxs, end, MOVE_NORMAL, e);
        if (trace_startsolid)
            continue;
        if (trace_fraction < minviewdistance / vlen(delta))
            continue;

        // rule 5: don't want to look at sky
        if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_SKY)
            continue;

        // rule 6: we must not end up in trigger_hurt
        if (tracebox_hits_trigger_hurt(start, e.mins, e.maxs, enddown))
            continue;

        break;
    }

    e.dphitcontentsmask = m;

    if (i < attempts)
    {
        setorigin(e, start);
        e.angles = vectoangles(end - start);
        dprint("NeEDED ", ftos(i + 1), " AtTEMPTS\n"); //Caps so we know which sub we're in if we want to check
        return TRUE;
    }
    else
        return FALSE;
}




float zcurveparticles_effectno;
vector zcurveparticles_start;
float zcurveparticles_spd;

void endzcurveparticles()
{
	if(zcurveparticles_effectno)
	{
		// terminator
		WriteShort(MSG_BROADCAST, zcurveparticles_spd | 0x8000);
	}
	zcurveparticles_effectno = 0;
}

void zcurveparticles(float effectno, vector start, vector end, float end_dz, float spd)
{
	spd = bound(0, floor(spd / 16), 32767);
	if(effectno != zcurveparticles_effectno || start != zcurveparticles_start)
	{
		endzcurveparticles();
		WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte(MSG_BROADCAST, TE_CSQC_ZCURVEPARTICLES);
		WriteShort(MSG_BROADCAST, effectno);
		WriteCoord(MSG_BROADCAST, start_x);
		WriteCoord(MSG_BROADCAST, start_y);
		WriteCoord(MSG_BROADCAST, start_z);
		zcurveparticles_effectno = effectno;
		zcurveparticles_start = start;
	}
	else
		WriteShort(MSG_BROADCAST, zcurveparticles_spd);
	WriteCoord(MSG_BROADCAST, end_x);
	WriteCoord(MSG_BROADCAST, end_y);
	WriteCoord(MSG_BROADCAST, end_z);
	WriteCoord(MSG_BROADCAST, end_dz);
	zcurveparticles_spd = spd;
}

void zcurveparticles_from_tracetoss(float effectno, vector start, vector end, vector vel)
{
	float end_dz;
	vector vecxy, velxy;

	vecxy = end - start;
	vecxy_z = 0;
	velxy = vel;
	velxy_z = 0;

	if (vlen(velxy) < 0.000001 * fabs(vel_z))
	{
		endzcurveparticles();
		trailparticles(world, effectno, start, end);
		return;
	}

	end_dz = vlen(vecxy) / vlen(velxy) * vel_z - (end_z - start_z);
	zcurveparticles(effectno, start, end, end_dz, vlen(vel));
}

void write_recordmarker(entity pl, float tstart, float dt)
{
    GameLogEcho(strcat(":recordset:", ftos(pl.playerid), ":", ftos(dt)));

    // also write a marker into demo files for demotc-race-record-extractor to find
    stuffcmd(pl,
             strcat(
                 strcat("//", strconv(2, 0, 0, GetGametype()), " RECORD SET ", TIME_ENCODED_TOSTRING(TIME_ENCODE(dt))),
                 " ", ftos(tstart), " ", ftos(dt), "\n"));
}

vector shotorg_adjustfromclient(vector vecs, float y_is_right, float allowcenter, float algn)
{
	switch(algn)
	{
		default:
		case 3: // right
			break;

		case 4: // left
			vecs_y = -vecs_y;
			break;

		case 1:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 2;
			}
			else
			{
				// right
			}
			break;

		case 2:
			if(allowcenter) // 2: allow center handedness
			{
				// center
				vecs_y = 0;
				vecs_z -= 2;
			}
			else
			{
				// left
				vecs_y = -vecs_y;
			}
			break;
	}
	return vecs;
}

vector shotorg_adjust_values(vector vecs, float y_is_right, float visual, float algn)
{
	string s;
	vector v;

	if (autocvar_g_shootfromeye)
	{
		if (visual)
		{
			if (autocvar_g_shootfromclient) { vecs = shotorg_adjustfromclient(vecs, y_is_right, (autocvar_g_shootfromclient >= 2), algn); }
			else { vecs_y = 0; vecs_z -= 2; }
		}
		else
		{
			vecs_y = 0;
			vecs_z = 0;
		}
	}
	else if (autocvar_g_shootfromcenter)
	{
		vecs_y = 0;
		vecs_z -= 2;
	}
	else if ((s = autocvar_g_shootfromfixedorigin) != "")
	{
		v = stov(s);
		
		
		if (self.owner.weaponinitaimmotif_use) {
			//This is for modifying improper/annoying v_weapon
			//placement as default (see: devastator)
			//(When interacting with shootfromfixedorigin)
			if (self.owner.weaponinitaimmotif_use == 2) {
				//relative (used by w_devastator.qc)
				v_x = v_x + self.owner.weaponinitaimmotif_x;
				v_y = v_y + self.owner.weaponinitaimmotif_y;
				v_z = v_z + self.owner.weaponinitaimmotif_z;
			} else {
				//absolute (default)
				v_x = self.owner.weaponinitaimmotif_x;
				v_y = self.owner.weaponinitaimmotif_y;
				v_z = self.owner.weaponinitaimmotif_z;
			}
		}
		
		
		if (y_is_right)
			v_y = -v_y;
		if (v_x != 0)
			vecs_x = v_x;
		vecs_y = v_y;
		vecs_z = v_z;
		
		//This allows an alternative aim point to be chosen
		//self.owner seems to always be the player when this routine is used
		//Thus we don't have to drag an entity through the function calls
		//print(etos(self.owner), " self.owner\n"); 
		if (autocvar_g_shootfromfixedorigin_alt_allow)
		{
			//print("allowed\n");
			if (self.owner.shootfromaltaim)
			{
				//print("set\n");
				if (self.owner.weaponaltaim_use) {
					//print("per-weapon aim\n");
					if (self.owner.weaponaltaim_use == 2) {
						if (y_is_right)
							v_y = -v_y; //reset
						
						//relative
						v_x = v_x + self.owner.weaponaltaim_x;
						v_y = v_y + self.owner.weaponaltaim_y;
						v_z = v_z + self.owner.weaponaltaim_z;
						
						if (y_is_right)
							v_y = -v_y; //redo inversion
					} else {
						//absolute (default)
						v_x = self.owner.weaponaltaim_x;
						v_y = self.owner.weaponaltaim_y;
						v_z = self.owner.weaponaltaim_z;
					
						//print (vtos(v), "vecs\n");
						if (y_is_right)
							v_y = -v_y;
					}
					if (v_x != 0)
						vecs_x = v_x;
					vecs_y = v_y;
					vecs_z = v_z;
				} else if ((s = autocvar_g_shootfromfixedorigin_alt) != "")
				{
					//print("doing\n");
					v = stov(s);
					if (y_is_right)
						v_y = -v_y;
					if (v_x != 0)
						vecs_x = v_x;
					vecs_y = v_y;
					vecs_z = v_z;	
				}
			}
		}
	}
	else if (autocvar_g_shootfromclient)
	{
		vecs = shotorg_adjustfromclient(vecs, y_is_right, (autocvar_g_shootfromclient >= 2), algn);
	}
	return vecs;
}

vector shotorg_adjust(vector vecs, float y_is_right, float visual)
{
	return shotorg_adjust_values(vecs, y_is_right, visual, self.owner.cvar_cl_gunalign);
}


void attach_sameorigin(entity e, entity to, string tag)
{
    vector org, t_forward, t_left, t_up, e_forward, e_up;
    float tagscale;

    org = e.origin - gettaginfo(to, gettagindex(to, tag));
    tagscale = pow(vlen(v_forward), -2); // undo a scale on the tag
    t_forward = v_forward * tagscale;
    t_left = v_right * -tagscale;
    t_up = v_up * tagscale;

    e.origin_x = org * t_forward;
    e.origin_y = org * t_left;
    e.origin_z = org * t_up;

    // current forward and up directions
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_FromVAngles(e.angles);
	else
		e.angles = AnglesTransform_FromAngles(e.angles);
    fixedmakevectors(e.angles);

    // untransform forward, up!
    e_forward_x = v_forward * t_forward;
    e_forward_y = v_forward * t_left;
    e_forward_z = v_forward * t_up;
    e_up_x = v_up * t_forward;
    e_up_y = v_up * t_left;
    e_up_z = v_up * t_up;

    e.angles = fixedvectoangles2(e_forward, e_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);

    setattachment(e, to, tag);
    setorigin(e, e.origin);
}

void detach_sameorigin(entity e)
{
    vector org;
    org = gettaginfo(e, 0);
    e.angles = fixedvectoangles2(v_forward, v_up);
    if (substring(e.model, 0, 1) == "*") // bmodels have their own rules
		e.angles = AnglesTransform_ToVAngles(e.angles);
	else
		e.angles = AnglesTransform_ToAngles(e.angles);
    setorigin(e, org);
    setattachment(e, world, "");
    setorigin(e, e.origin);
}

void follow_sameorigin(entity e, entity to)
{
    e.movetype = MOVETYPE_FOLLOW; // make the hole follow
    e.aiment = to; // make the hole follow bmodel
    e.punchangle = to.angles; // the original angles of bmodel
    e.view_ofs = e.origin - to.origin; // relative origin
    e.v_angle = e.angles - to.angles; // relative angles
}

void unfollow_sameorigin(entity e)
{
    e.movetype = MOVETYPE_NONE;
}

entity gettaginfo_relative_ent;
vector gettaginfo_relative(entity e, float tag)
{
    if (!gettaginfo_relative_ent)
    {
        gettaginfo_relative_ent = spawn();
        gettaginfo_relative_ent.effects = EF_NODRAW;
    }
    gettaginfo_relative_ent.model = e.model;
    gettaginfo_relative_ent.modelindex = e.modelindex;
    gettaginfo_relative_ent.frame = e.frame;
    return gettaginfo(gettaginfo_relative_ent, tag);
}

.float scale2;

float modeleffect_SendEntity(entity to, float sf)
{
	float f;
	WriteByte(MSG_ENTITY, ENT_CLIENT_MODELEFFECT);

	f = 0;
	if(self.velocity != '0 0 0')
		f |= 1;
	if(self.angles != '0 0 0')
		f |= 2;
	if(self.avelocity != '0 0 0')
		f |= 4;

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, self.modelindex);
	WriteByte(MSG_ENTITY, self.skin);
	WriteByte(MSG_ENTITY, self.frame);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	if(f & 1)
	{
		WriteCoord(MSG_ENTITY, self.velocity_x);
		WriteCoord(MSG_ENTITY, self.velocity_y);
		WriteCoord(MSG_ENTITY, self.velocity_z);
	}
	if(f & 2)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);
	}
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.avelocity_x);
		WriteCoord(MSG_ENTITY, self.avelocity_y);
		WriteCoord(MSG_ENTITY, self.avelocity_z);
	}
	WriteShort(MSG_ENTITY, self.scale * 256.0);
	WriteShort(MSG_ENTITY, self.scale2 * 256.0);
	WriteByte(MSG_ENTITY, self.teleport_time * 100.0);
	WriteByte(MSG_ENTITY, self.fade_time * 100.0);
	WriteByte(MSG_ENTITY, self.alpha * 255.0);

	return TRUE;
}

void modeleffect_spawn(string m, float s, float f, vector o, vector v, vector ang, vector angv, float s0, float s2, float a, float t1, float t2)
{
	entity e;
	float sz;
	e = spawn();
	e.classname = "modeleffect";
	setmodel(e, m);
	e.frame = f;
	setorigin(e, o);
	e.velocity = v;
	e.angles = ang;
	e.avelocity = angv;
	e.alpha = a;
	e.teleport_time = t1;
	e.fade_time = t2;
	e.skin = s;
	if(s0 >= 0)
		e.scale = s0 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale = -s0;
	if(s2 >= 0)
		e.scale2 = s2 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale2 = -s2;
	sz = max(e.scale, e.scale2);
	setsize(e, e.mins * sz, e.maxs * sz);
	Net_LinkEntity(e, FALSE, 0.1, modeleffect_SendEntity);
}

//Bigger to support larger scales (ie: nukes)
float modeleffect2_SendEntity(entity to, float sf)
{
	float f;
	WriteByte(MSG_ENTITY, ENT_CLIENT_MODELEFFECT2);

	f = 0;
	if(self.velocity != '0 0 0')
		f |= 1;
	if(self.angles != '0 0 0')
		f |= 2;
	if(self.avelocity != '0 0 0')
		f |= 4;

	WriteByte(MSG_ENTITY, f);
	WriteShort(MSG_ENTITY, self.modelindex);
	WriteByte(MSG_ENTITY, self.skin);
	WriteByte(MSG_ENTITY, self.frame);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	if(f & 1)
	{
		WriteCoord(MSG_ENTITY, self.velocity_x);
		WriteCoord(MSG_ENTITY, self.velocity_y);
		WriteCoord(MSG_ENTITY, self.velocity_z);
	}
	if(f & 2)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);
	}
	if(f & 4)
	{
		WriteCoord(MSG_ENTITY, self.avelocity_x);
		WriteCoord(MSG_ENTITY, self.avelocity_y);
		WriteCoord(MSG_ENTITY, self.avelocity_z);
	}
	WriteLong(MSG_ENTITY, self.scale); //Not multiplying, this is for big explosions
	WriteLong(MSG_ENTITY, self.scale2);//Not multiplying, this is for big explosions
	WriteLong(MSG_ENTITY, self.teleport_time * 100.0);
	WriteLong(MSG_ENTITY, self.fade_time * 100.0);
	WriteByte(MSG_ENTITY, self.alpha * 255.0);

	return TRUE;
}

void modeleffect2_spawn(string m, float s, float f, vector o, vector v, vector ang, vector angv, float s0, float s2, float a, float t1, float t2)
{
	entity e;
	float sz;
	e = spawn();
	e.classname = "modeleffect";
	setmodel(e, m);
	e.frame = f;
	setorigin(e, o);
	e.velocity = v;
	e.angles = ang;
	e.avelocity = angv;
	e.alpha = a;
	e.teleport_time = t1;
	e.fade_time = t2;
	e.skin = s;
	if(s0 >= 0)
		e.scale = s0 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale = -s0;
	if(s2 >= 0)
		e.scale2 = s2 / max6(-e.mins_x, -e.mins_y, -e.mins_z, e.maxs_x, e.maxs_y, e.maxs_z);
	else
		e.scale2 = -s2;
	sz = max(e.scale, e.scale2);
	setsize(e, e.mins * sz, e.maxs * sz);
	Net_LinkEntity(e, FALSE, 0.1, modeleffect2_SendEntity);
}

void shockwave_spawn(string m, vector org, float sz, float t1, float t2)
{
	return modeleffect_spawn(m, 0, 0, org, '0 0 0', '0 0 0', '0 0 0', 0, sz, 1, t1, t2);
}

float randombit(float bits)
{
	if not(bits & (bits-1)) // this ONLY holds for powers of two!
		return bits;

	float n, f, b, r;

	r = random();
	b = 0;
	n = 0;

	for(f = 1; f <= bits; f *= 2)
	{
		if(bits & f)
		{
			++n;
			r *= n;
			if(r <= 1)
				b = f;
			else
				r = (r - 1) / (n - 1);
		}
	}

	return b;
}

float randombits(float bits, float k, float error_return)
{
	float r;
	r = 0;
	while(k > 0 && bits != r)
	{
		r += randombit(bits - r);
		--k;
	}
	if(error_return)
		if(k > 0)
			return -1; // all
	return r;
}

void randombit_test(float bits, float iter)
{
	while(iter > 0)
	{
		print(ftos(randombit(bits)), "\n");
		--iter;
	}
}

float ExponentialFalloff(float mindist, float maxdist, float halflifedist, float d)
{
	if(halflifedist > 0)
		return pow(0.5, (bound(mindist, d, maxdist) - mindist) / halflifedist);
	else if(halflifedist < 0)
		return pow(0.5, (bound(mindist, d, maxdist) - maxdist) / halflifedist);
	else
		return 1;
}




#ifdef RELEASE
#define cvar_string_normal builtin_cvar_string
#define cvar_normal builtin_cvar
#else
string cvar_string_normal(string n)
{
	if not(cvar_type(n) & 1)
		backtrace(strcat("Attempt to access undefined cvar: ", n));
	return builtin_cvar_string(n);
}

float cvar_normal(string n)
{
	return stof(cvar_string_normal(n));
}
#endif
#define cvar_set_normal builtin_cvar_set

void defer_think()
{
    entity oself;

    oself           = self;
    self            = self.owner;
    oself.think     = SUB_Remove;
    oself.nextthink = time;

    oself.use();
}

/*
    Execute func() after time + fdelay.
    self when func is executed = self when defer is called
*/
void defer(float fdelay, void() func)
{
    entity e;

    e           = spawn();
    e.owner     = self;
    e.use       = func;
    e.think     = defer_think;
    e.nextthink = time + fdelay;
}

.string aiment_classname;
.float aiment_deadflag;
void SetMovetypeFollow(entity ent, entity e)
{
	// FIXME this may not be warpzone aware
	ent.movetype = MOVETYPE_FOLLOW; // make the hole follow
	ent.solid = SOLID_NOT; // MOVETYPE_FOLLOW is always non-solid - this means this cannot be teleported by warpzones any more! Instead, we must notice when our owner gets teleported.
	ent.aiment = e; // make the hole follow bmodel
	ent.punchangle = e.angles; // the original angles of bmodel
	ent.view_ofs = ent.origin - e.origin; // relative origin
	ent.v_angle = ent.angles - e.angles; // relative angles
	ent.aiment_classname = strzone(e.classname);
	ent.aiment_deadflag = e.deadflag;
}
void UnsetMovetypeFollow(entity ent)
{
	ent.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(ent);
	ent.aiment = world;
}
float LostMovetypeFollow(entity ent)
{
/*
	if(ent.movetype != MOVETYPE_FOLLOW)
		if(ent.aiment)
			error("???");
*/
	if(ent.aiment)
	{
		if(ent.aiment.classname != ent.aiment_classname)
			return 1;
		if(ent.aiment.deadflag != ent.aiment_deadflag)
			return 1;
	}
	return 0;
}

float isPushable(entity e)
{
	if(e.iscreature)
		return TRUE;
	if(e.pushable)
		return TRUE;
	switch(e.classname)
	{
		case "body":
		case "droppedweapon":
		case "keepawayball":
		case "nexball_basketball":
		case "nexball_football":
			return TRUE;
		case "bullet": // antilagged bullets can't hit this either
			return FALSE;
	}
	if (e.projectiledeathtype)
		return TRUE;
	return FALSE;
}

float isPlayerOrMonsterByClassname (entity e)
{
	float is_player;
	is_player = (e.classname == "player" || e.classname == "body"
		|| e.classname == "monster_zombie"
		|| e.classname == "monster_ogre"
		|| e.classname == "monster_enforcer"
		|| e.classname == "monster_fish"
		|| e.classname == "monster_shalrath"
		|| e.classname == "monster_shambler"
		|| e.classname == "monster_spider"
		|| e.classname == "monster_dog"
		|| e.classname == "monster_wolf"
		|| e.classname == "monster_skeleton"
		|| e.classname == "monster_minotaur"
		|| e.classname == "monster_soldier"
		|| e.classname == "monster_demon"
		|| e.classname == "monster_goblin"
		|| e.classname == "monster_knight"
		|| e.classname == "monster_hellknight"
		|| e.classname == "monster_golem"
		|| e.classname == "monster_wyvern"
		|| e.classname == "monster_seraph"
		|| e.classname == "monster_police"
		|| e.classname == "monster_royalguard"
		|| e.classname == "monster_imp"
		|| e.classname == "monster_biledemon"
		|| e.classname == "monster_horndemon"
		|| e.classname == "monster_wizard"
		|| e.classname == "monster_fighter"
		|| e.classname == "monster_ninjaassassin"
		|| e.classname == "monster_shinrae"
		|| e.classname == "monster_aocyborg");
		
	//Omit monster_tarbaby for now, it's more a ... mass of tar	
	
	if (is_player)
		return TRUE;
	else
		return FALSE;
}

float vehicles_lightvehicle(entity e);
float vehicles_mediumvehicle(entity e);
float vehicles_heavyvehicle(entity e);
float isVehicleOrMGByClassname (entity e)
{
	float is_player;
	is_player = (vehicles_lightvehicle(e)
	|| vehicles_mediumvehicle(e)
	|| vehicles_heavyvehicle(e)
	|| e.netname == "Browning50Gun"
	|| e.netname == "GAU19Gun"
	|| e.netname == "LewisGun"
	|| e.netname == "M134Gun"
	|| e.netname == "RpkGun"
	|| e.netname == "RpdGun"
	|| e.netname == "M249ParaGun"
	|| e.netname == "HotchkissM1914Gun"
	|| e.netname == "Gatling1877Gun"
	|| e.netname == "SpaduGun"
	|| e.netname == "T17mmGun"
	|| e.netname == "AutoNexGun"
	|| e.netname == "DelugeGun"
	|| e.netname == "GRailGun"
	|| e.netname == "SHlacGun"
	|| e.netname == "LaserCannon"
	|| e.netname == "ScorpionBallista"
	|| e.netname == "CharMortar"
	|| e.netname == "BatteringRam"
	|| e.netname == "SiegeMortar");
	
	if (is_player)
		return TRUE;
	else
		return FALSE;
}

float isVehicleOrMGNear (entity player, float sradius)
{
	local entity head;
	head = findradius(player.origin, sradius);
	while (head)
	{
		if (isVehicleOrMGByClassname(head))
			return TRUE;
	
		head = head.chain;
	}
	return FALSE;
}

//Some stuff for setting friends, checking friends, etc
float checkFriend (entity player, entity shadow)
{
	if (shadow && shadow != world) {
		//Good
	} else {
		return FALSE;
	}
	
	float confidencelevel;
	confidencelevel = 0;
	
	if(player.crypto_keyfp) {
		if (shadow.svdstring2 == player.crypto_idfp) {
			dprint("player crypto_idfp matched, will reapply settings\n");
			confidencelevel = confidencelevel + 4;
		}
	}
	
	if(player.netname)
	{
		//print("spinning2222 Enetname: ",e.svdstring0," Playernn: ",player.netname,"\n");
		if (shadow.svdstring0 == player.netname) {
			confidencelevel = confidencelevel + 0.5;	
		}
	}
	
	if(shadow.friendent != world) {
		if(player == shadow.friendent) {
			confidencelevel = confidencelevel + 0.25;
			if ((clienttype(player) == CLIENTTYPE_BOT)
			|| (clienttype(player) == CLIENTTYPE_REAL)) {
				confidencelevel = confidencelevel + 0.25;
			}
		}
	}
	
	if(player.netaddress)
	if(player.netaddress != "local")
	if(player.netaddress != "null/botclient")
	if(clienttype(player) != CLIENTTYPE_BOT)
	{
		if (shadow.svdstring3 == player.netaddress) {
			confidencelevel = confidencelevel + 0.5;
		}
	}
	
	return(confidencelevel);
}

float isFriendOf (entity player, entity pfother, float confidencelevel)
{
	//(Player, Player'sPotentialFriend, ConfidenceLevel)
	if (player.hasfriends) {
		//Many checkFriends
		if (checkFriend(pfother, player.friend0) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend1) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend2) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend3) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend4) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend5) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend6) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend7) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend8) >= confidencelevel) return TRUE;
		if (checkFriend(pfother, player.friend9) >= confidencelevel) return TRUE;
	}
	return FALSE;
}

//When doing this shadow shall be one of the player.friend entities
//First remove, then create another (or set to world, then create another)
void setFriend (entity player, entity shadow)
{
	shadow.classname = "plrfrndentry"; //Only set this now
	shadow.friendent = player;
	string m;
	m = strzone(player.crypto_idfp);
	shadow.svdstring2 = m; //Gotta do it this way because strings in QC are pointers, we are not pointing to this immutable string in m
	
	shadow.svdstring3 = strzone(player.netaddress);
	shadow.svdstring0 = strzone(player.netname);
}

float quickIsFriendOf(entity player, entity pfother)
{
	//For turret checking etc.
	//(Player, Player'sPotentialFriend)
	//Quicker than otherway
	//And now for excessive checking (world is ent 0 so checking the boolean is redundant)
	//But what if... someday... that changes????
	//Don't like to trust... Not QuakeC
	if (player.hasfriends) {
		if (player.friend0 && player.friend0 != world
		&& player.friend0.friendent && player.friend0.friendent != world
		&& player.friend0.friendent == pfother) {
			return TRUE;
		} else if (player.friend1 && player.friend1 != world
		&& player.friend1.friendent && player.friend1.friendent != world
		&& player.friend1.friendent == pfother) {
			return TRUE;
		} else if (player.friend2 && player.friend2 != world
		&& player.friend2.friendent && player.friend2.friendent != world
		&& player.friend2.friendent == pfother) {
			return TRUE;
		} else if (player.friend3 && player.friend3 != world
		&& player.friend3.friendent && player.friend3.friendent != world
		&& player.friend3.friendent == pfother) {
			return TRUE;
		} else if (player.friend4 && player.friend4 != world
		&& player.friend4.friendent && player.friend4.friendent != world
		&& player.friend4.friendent == pfother) {
			return TRUE;
		} else if (player.friend5 && player.friend5 != world
		&& player.friend5.friendent && player.friend5.friendent != world
		&& player.friend5.friendent == pfother) {
			return TRUE;
		} else if (player.friend6 && player.friend6 != world
		&& player.friend6.friendent && player.friend6.friendent != world
		&& player.friend6.friendent == pfother) {
			return TRUE;
		} else if (player.friend7 && player.friend7 != world
		&& player.friend7.friendent && player.friend7.friendent != world
		&& player.friend7.friendent == pfother) {
			return TRUE;
		} else if (player.friend8 && player.friend8 != world
		&& player.friend8.friendent && player.friend8.friendent != world
		&& player.friend8.friendent == pfother) {
			return TRUE;
		} else if (player.friend9 && player.friend9 != world
		&& player.friend9.friendent && player.friend9.friendent != world
		&& player.friend9.friendent == pfother) {
			return TRUE;
		} else {
			return FALSE;
		}
	}
	
	return FALSE;
		
}

//When doing this shadow shall be one of the player.tolerated entities
//First remove, then create another (or set to world, then create another)
void setTolerated (entity player, entity shadow)
{
	shadow.classname = "tolrtddentry"; //Only set this now
	shadow.toleratedent = player;
	string m;
	m = strzone(player.crypto_idfp);
	shadow.svdstring2 = m; //Gotta do it this way because strings in QC are pointers, we are not pointing to this immutable string in m
	
	shadow.svdstring3 = strzone(player.netaddress);
	shadow.svdstring0 = strzone(player.netname);
}


float quickIsToleratedOf(entity player, entity pfother)
{
	//For turret checking etc.
	//(Player, Player'sPotentialTolerated)
	//Quicker than otherway
	//And now for excessive checking (world is ent 0 so checking the boolean is redundant)
	//But what if... someday... that changes????
	//Don't like to trust... Not QuakeC
	if (player.hastolerateds) {
		if (player.tolerated0 && player.tolerated0 != world
		&& player.tolerated0.toleratedent && player.tolerated0.toleratedent != world
		&& player.tolerated0.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated1 && player.tolerated1 != world
		&& player.tolerated1.toleratedent && player.tolerated1.toleratedent != world
		&& player.tolerated1.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated2 && player.tolerated2 != world
		&& player.tolerated2.toleratedent && player.tolerated2.toleratedent != world
		&& player.tolerated2.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated3 && player.tolerated3 != world
		&& player.tolerated3.toleratedent && player.tolerated3.toleratedent != world
		&& player.tolerated3.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated4 && player.tolerated4 != world
		&& player.tolerated4.toleratedent && player.tolerated4.toleratedent != world
		&& player.tolerated4.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated5 && player.tolerated5 != world
		&& player.tolerated5.toleratedent && player.tolerated5.toleratedent != world
		&& player.tolerated5.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated6 && player.tolerated6 != world
		&& player.tolerated6.toleratedent && player.tolerated6.toleratedent != world
		&& player.tolerated6.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated7 && player.tolerated7 != world
		&& player.tolerated7.toleratedent && player.tolerated7.toleratedent != world
		&& player.tolerated7.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated8 && player.tolerated8 != world
		&& player.tolerated8.toleratedent && player.tolerated8.toleratedent != world
		&& player.tolerated8.toleratedent == pfother) {
			return TRUE;
		} else if (player.tolerated9 && player.tolerated9 != world
		&& player.tolerated9.toleratedent && player.tolerated9.toleratedent != world
		&& player.tolerated9.toleratedent == pfother) {
			return TRUE;
		} else {
			return FALSE;
		}
	}
	
	return FALSE;
		
}

//When doing this shadow shall be one of the player.hated entities
//First remove, then create another (or set to world, then create another)
void setHated (entity player, entity shadow)
{
	shadow.classname = "hatedentry"; //Only set this now
	shadow.hatedent = player;
	string m;
	m = strzone(player.crypto_idfp);
	shadow.svdstring2 = m; //Gotta do it this way because strings in QC are pointers, we are not pointing to this immutable string in m
	
	shadow.svdstring3 = strzone(player.netaddress);
	shadow.svdstring0 = strzone(player.netname);
}


float quickIsHatedOf(entity player, entity pfother)
{
	//For turret checking etc.
	//(Player, Player'sPotentialHated)
	//Quicker than otherway
	//And now for excessive checking (world is ent 0 so checking the boolean is redundant)
	//But what if... someday... that changes????
	//Don't like to trust... Not QuakeC
	if (player.hashateds) {
		if (player.hated0 && player.hated0 != world
		&& player.hated0.hatedent && player.hated0.hatedent != world
		&& player.hated0.hatedent == pfother) {
			return TRUE;
		} else if (player.hated1 && player.hated1 != world
		&& player.hated1.hatedent && player.hated1.hatedent != world
		&& player.hated1.hatedent == pfother) {
			return TRUE;
		} else if (player.hated2 && player.hated2 != world
		&& player.hated2.hatedent && player.hated2.hatedent != world
		&& player.hated2.hatedent == pfother) {
			return TRUE;
		} else if (player.hated3 && player.hated3 != world
		&& player.hated3.hatedent && player.hated3.hatedent != world
		&& player.hated3.hatedent == pfother) {
			return TRUE;
		} else if (player.hated4 && player.hated4 != world
		&& player.hated4.hatedent && player.hated4.hatedent != world
		&& player.hated4.hatedent == pfother) {
			return TRUE;
		} else if (player.hated5 && player.hated5 != world
		&& player.hated5.hatedent && player.hated5.hatedent != world
		&& player.hated5.hatedent == pfother) {
			return TRUE;
		} else if (player.hated6 && player.hated6 != world
		&& player.hated6.hatedent && player.hated6.hatedent != world
		&& player.hated6.hatedent == pfother) {
			return TRUE;
		} else if (player.hated7 && player.hated7 != world
		&& player.hated7.hatedent && player.hated7.hatedent != world
		&& player.hated7.hatedent == pfother) {
			return TRUE;
		} else if (player.hated8 && player.hated8 != world
		&& player.hated8.hatedent && player.hated8.hatedent != world
		&& player.hated8.hatedent == pfother) {
			return TRUE;
		} else if (player.hated9 && player.hated9 != world
		&& player.hated9.hatedent && player.hated9.hatedent != world
		&& player.hated9.hatedent == pfother) {
			return TRUE;
		} else {
			return FALSE;
		}
	}
	
	return FALSE;
		
}


//At reconnect
void reinsertFriend (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}
	
		local entity fndmyent;
		fndmyent = find(world, classname, "plrfrndentry");
		while(fndmyent)
		{
		
			if (fndmyent.friendent == world)
			{
				if(player.crypto_keyfp) {
					if (fndmyent.svdstring2 == player.crypto_idfp) {
						//dprint("player crypto_idfp matched, will reapply settings\n");
						dprint("player crypto_idfp matched, will reinsert as friend\n");
						fndmyent.friendent = player;
					}
				}
			}
			fndmyent = find(fndmyent, classname, "plrfrndentry");
		}
}

//Delists at disconnect
void deinsertFriend (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}

		local entity fndmyent;
		fndmyent = find(world, classname, "plrfrndentry");
		while(fndmyent)
		{
		 	if (fndmyent.friendent == player)
			{
				//reset to world, doesn't change cryptostuff so can refind later
				fndmyent.friendent = world;
			}
			fndmyent = find(fndmyent, classname, "plrfrndentry");
		}
}

//At reconnect
void reinsertExFriend (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}
	
		local entity fndmyent;
		fndmyent = find(world, classname, "exfrndentry");
		while(fndmyent)
		{
		
			if (fndmyent.exfriendent == world)
			{
				if(player.crypto_keyfp) {
					if (fndmyent.svdstring2 == player.crypto_idfp) {
						//dprint("player crypto_idfp matched, will reapply settings\n");
						dprint("player crypto_idfp matched, will reinsert as friend\n");
						fndmyent.exfriendent = player;
					}
				}
			}
			fndmyent = find(fndmyent, classname, "exfrndentry");
		}
}

//Delists at disconnect
void deinsertExFriend (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}

		local entity fndmyent;
		fndmyent = find(world, classname, "exfrndentry");
		while(fndmyent)
		{
		 	if (fndmyent.exfriendent == player)
			{
				//reset to world, doesn't change cryptostuff so can refind later
				fndmyent.exfriendent = world;
			}
			fndmyent = find(fndmyent, classname, "exfrndentry");
		}
}

//At reconnect
void reinsertTolerated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}
	
		local entity fndmyent;
		fndmyent = find(world, classname, "tolrtddentry");
		while(fndmyent)
		{
		
			if (fndmyent.toleratedent == world)
			{
				if(player.crypto_keyfp) {
					if (fndmyent.svdstring2 == player.crypto_idfp) {
						//dprint("player crypto_idfp matched, will reapply settings\n");
						dprint("player crypto_idfp matched, will reinsert as friend\n");
						fndmyent.toleratedent = player;
					}
				}
			}
			fndmyent = find(fndmyent, classname, "tolrtddentry");
		}
}

//Delists at disconnect
void deinsertTolerated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}

		local entity fndmyent;
		fndmyent = find(world, classname, "tolrtddentry");
		while(fndmyent)
		{
		 	if (fndmyent.toleratedent == player)
			{
				//reset to world, doesn't change cryptostuff so can refind later
				fndmyent.toleratedent = world;
			}
			fndmyent = find(fndmyent, classname, "tolrtddentry");
		}
}

//At reconnect
void reinsertHated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}
	
		local entity fndmyent;
		fndmyent = find(world, classname, "hatedentry");
		while(fndmyent)
		{
		
			if (fndmyent.hatedent == world)
			{
				if(player.crypto_keyfp) {
					if (fndmyent.svdstring2 == player.crypto_idfp) {
						//dprint("player crypto_idfp matched, will reapply settings\n");
						dprint("player crypto_idfp matched, will reinsert as friend\n");
						fndmyent.hatedent = player;
					}
				}
			}
			fndmyent = find(fndmyent, classname, "hatedentry");
		}
}

//Delists at disconnect
void deinsertHated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}

		local entity fndmyent;
		fndmyent = find(world, classname, "hatedentry");
		while(fndmyent)
		{
		 	if (fndmyent.hatedent == player)
			{
				//reset to world, doesn't change cryptostuff so can refind later
				fndmyent.hatedent = world;
			}
			fndmyent = find(fndmyent, classname, "hatedentry");
		}
}

//At reconnect
void reinsertExHated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}
	
		local entity fndmyent;
		fndmyent = find(world, classname, "exhtedentry");
		while(fndmyent)
		{
		
			if (fndmyent.exhatedent == world)
			{
				if(player.crypto_keyfp) {
					if (fndmyent.svdstring2 == player.crypto_idfp) {
						//dprint("player crypto_idfp matched, will reapply settings\n");
						dprint("player crypto_idfp matched, will reinsert as hated\n");
						fndmyent.exhatedent = player;
					}
				}
			}
			fndmyent = find(fndmyent, classname, "exhtedentry");
		}
}

//Delists at disconnect
void deinsertExHated (entity player)
{
	if not (autocvar_g_allow_friends) {
		return;
	}

		local entity fndmyent;
		fndmyent = find(world, classname, "exhtedentry");
		while(fndmyent)
		{
		 	if (fndmyent.exhatedent == player)
			{
				//reset to world, doesn't change cryptostuff so can refind later
				fndmyent.exhatedent = world;
			}
			fndmyent = find(fndmyent, classname, "exhtedentry");
		}
}

.entity subordinate5; //for misc stuff

void removeraiseundeadmarker ()
{
	if (raiseundeadmarker_first == world) {
			//print("raiseundeadmarker_first is world\n");
		return;
	}
	if (raiseundeadmarker_first.subordinate5 == world) {
			//print("raiseundeadmarker_first.subordinate5 is world\n");
		return;
	}
	
	local entity mytempent;
	local entity myremoveent;
	mytempent = raiseundeadmarker_first.subordinate5;
	myremoveent = raiseundeadmarker_first;
	raiseundeadmarker_first = mytempent;
	remove(myremoveent);
	
		//print("removed a raiseundeadmarker\n");
		
	raiseundeadmarker_current = raiseundeadmarker_current - 1;
}

//So we know where a humanoid died.
void placeraiseundeadmarker (entity player, float isplayerorbot)
{
	if not (raiseundeadmarkerenabled)
	{
			//print("Raise Undead spell isn't given in this match, so NOT setting death marker\n");
		return;
	}
	
		//print("May set death marker\n");
	
	if (player.stoned) 
	{
		//Killed while stone: crumble: no zombie to raise
		return;
	}
		
	entity marker;
	marker = spawn();
	marker.classname = "raise_undead_marker";
	marker.origin = player.origin;
	marker.species = player.species;
	marker.cnt = 0;
	marker.count = isplayerorbot;
	
	if (!raiseundeadmarker_current) {
		//We're 0, let's start
		raiseundeadmarker_first = marker;
	} else if (raiseundeadmarker_current == 1) {
		local entity mytempent;
		mytempent = raiseundeadmarker_first;
		mytempent.subordinate5 = marker; //Start our linked list.
		raiseundeadmarker_previous = marker; //So we know who to set next time around
	} else {
		if (raiseundeadmarker_previous != world) {
			local entity mytempent;
			mytempent = raiseundeadmarker_previous;
			mytempent.subordinate5 = marker; //Continue our linked list.
			raiseundeadmarker_previous = marker; //So we know who to set next time around.. And so on and so on.
		}
	}
	
	raiseundeadmarker_current = raiseundeadmarker_current + 1;
		//print(ftos(raiseundeadmarker_current), "-current ", ftos(raiseundeadmarker_max), "-max\n");
	if (raiseundeadmarker_current >= raiseundeadmarker_max)
	{
		removeraiseundeadmarker();
	}
	setorigin(marker, marker.origin);
}

void copyfriends (entity froment, entity toent)
{
	if (!froment)
		return;
		
	if (froment == world)
		return;
		
	if (!toent)
		return;
	
	if (toent == world)
		return;
	
	if (!froment.hasfriends)
		return;
	
	toent.hasfriends = froment.hasfriends;
	
	if (froment.friend0 && froment.friend0 != world
	&& froment.friend0.friendent && froment.friend0.friendent != world)
		toent.friend0 = froment.friend0;
	
	if (froment.friend1 && froment.friend1 != world
	&& froment.friend1.friendent && froment.friend1.friendent != world)
		toent.friend1 = froment.friend1;	
		
	if (froment.friend2 && froment.friend2 != world
	&& froment.friend2.friendent && froment.friend2.friendent != world)
		toent.friend2 = froment.friend2;
	
	if (froment.friend3 && froment.friend3 != world
	&& froment.friend3.friendent && froment.friend3.friendent != world)
		toent.friend3 = froment.friend3;
		
	if (froment.friend4 && froment.friend4 != world
	&& froment.friend4.friendent && froment.friend4.friendent != world)
		toent.friend4 = froment.friend4;
		
	if (froment.friend5 && froment.friend5 != world
	&& froment.friend5.friendent && froment.friend5.friendent != world)	
		toent.friend5 = froment.friend5;
		
	if (froment.friend6 && froment.friend6 != world
	&& froment.friend6.friendent && froment.friend6.friendent != world)	
		toent.friend6 = froment.friend6;
	
	if (froment.friend7 && froment.friend7 != world
	&& froment.friend7.friendent && froment.friend7.friendent != world)
		toent.friend7 = froment.friend7;
	
	if (froment.friend8 && froment.friend8 != world
	&& froment.friend8.friendent && froment.friend8.friendent != world)
		toent.friend8 = froment.friend8;
	
	if (froment.friend9 && froment.friend9 != world
	&& froment.friend9.friendent && froment.friend9.friendent != world)
		toent.friend9 = froment.friend9;
}

void copytolerated (entity froment, entity toent)
{
	if (!froment)
		return;
		
	if (froment == world)
		return;
		
	if (!toent)
		return;
	
	if (toent == world)
		return;
	
	if (!froment.hastolerateds)
		return;
	
	toent.hastolerateds = froment.hastolerateds;
	
	if (froment.tolerated0 && froment.tolerated0 != world
	&& froment.tolerated0.toleratedent && froment.tolerated0.toleratedent != world)
		toent.tolerated0 = froment.tolerated0;
	
	if (froment.tolerated1 && froment.tolerated1 != world
	&& froment.tolerated1.toleratedent && froment.tolerated1.toleratedent != world)
		toent.tolerated1 = froment.tolerated1;	
		
	if (froment.tolerated2 && froment.tolerated2 != world
	&& froment.tolerated2.toleratedent && froment.tolerated2.toleratedent != world)
		toent.tolerated2 = froment.tolerated2;
	
	if (froment.tolerated3 && froment.tolerated3 != world
	&& froment.tolerated3.toleratedent && froment.tolerated3.toleratedent != world)
		toent.tolerated3 = froment.tolerated3;
		
	if (froment.tolerated4 && froment.tolerated4 != world
	&& froment.tolerated4.toleratedent && froment.tolerated4.toleratedent != world)
		toent.tolerated4 = froment.tolerated4;
		
	if (froment.tolerated5 && froment.tolerated5 != world
	&& froment.tolerated5.toleratedent && froment.tolerated5.toleratedent != world)	
		toent.tolerated5 = froment.tolerated5;
		
	if (froment.tolerated6 && froment.tolerated6 != world
	&& froment.tolerated6.toleratedent && froment.tolerated6.toleratedent != world)	
		toent.tolerated6 = froment.tolerated6;
	
	if (froment.tolerated7 && froment.tolerated7 != world
	&& froment.tolerated7.toleratedent && froment.tolerated7.toleratedent != world)
		toent.tolerated7 = froment.tolerated7;
	
	if (froment.tolerated8 && froment.tolerated8 != world
	&& froment.tolerated8.toleratedent && froment.tolerated8.toleratedent != world)
		toent.tolerated8 = froment.tolerated8;
	
	if (froment.tolerated9 && froment.tolerated9 != world
	&& froment.tolerated9.toleratedent && froment.tolerated9.toleratedent != world)
		toent.tolerated9 = froment.tolerated9;
}

void copyhated (entity froment, entity toent)
{
	if (!froment)
		return;
		
	if (froment == world)
		return;
		
	if (!toent)
		return;
	
	if (toent == world)
		return;
		
	if (!froment.hashateds)
		return;
				
	toent.hashateds = froment.hashateds;
	
	if (froment.hated0 && froment.hated0 != world
	&& froment.hated0.hatedent && froment.hated0.hatedent != world) {
		toent.hated0 = froment.hated0; 
	}
	
	if (froment.hated1 && froment.hated1 != world
	&& froment.hated1.hatedent && froment.hated1.hatedent != world)
		toent.hated1 = froment.hated1;	
		
	if (froment.hated2 && froment.hated2 != world
	&& froment.hated2.hatedent && froment.hated2.hatedent != world)
		toent.hated2 = froment.hated2;
	
	if (froment.hated3 && froment.hated3 != world
	&& froment.hated3.hatedent && froment.hated3.hatedent != world)
		toent.hated3 = froment.hated3;
		
	if (froment.hated4 && froment.hated4 != world
	&& froment.hated4.hatedent && froment.hated4.hatedent != world)
		toent.hated4 = froment.hated4;
		
	if (froment.hated5 && froment.hated5 != world
	&& froment.hated5.hatedent && froment.hated5.hatedent != world)	
		toent.hated5 = froment.hated5;
		
	if (froment.hated6 && froment.hated6 != world
	&& froment.hated6.hatedent && froment.hated6.hatedent != world)	
		toent.hated6 = froment.hated6;
	
	if (froment.hated7 && froment.hated7 != world
	&& froment.hated7.hatedent && froment.hated7.hatedent != world)
		toent.hated7 = froment.hated7;
	
	if (froment.hated8 && froment.hated8 != world
	&& froment.hated8.hatedent && froment.hated8.hatedent != world)
		toent.hated8 = froment.hated8;
	
	if (froment.hated9 && froment.hated9 != world
	&& froment.hated9.hatedent && froment.hated9.hatedent != world)
		toent.hated9 = froment.hated9;
}



float unmarshalmonsters(entity player)
{
	entity e;
	float unmarshalednumber;
	unmarshalednumber = 0;

	//remove self from marshaled monsters
	for(e = world; (e = findentity(e, monster_marshal, player)); ) {
		if (e.monster_marshalable) {
			e.monster_marshal = world;
			unmarshalednumber = unmarshalednumber + 1;
		}
	}
	
	return unmarshalednumber;
}

float marshalmonsters(entity player, vector srchorigin, float range)
{
	entity e;
	float marshalednumber;
	marshalednumber = 0;
	
	e = findradius(srchorigin,range);
	while (e)
	{
	 if (e.monster_marshalable){
	  if (!e.monster_marshal || e.monster_marshal == world) 
	  {
	  //Yes I know world is currently always 0
	  
		if (teamplay) {
	 		if (e.team == player.team) {
				e.monster_marshal = player;
				marshalednumber = marshalednumber + 1;
			}
		} else {
			if (e.monster_owner == player) {
				e.monster_marshal = player;
				marshalednumber = marshalednumber + 1;
			}
		}
	  }
	 }
	
		
	e = e.chain;
	}
	
	return marshalednumber;
}

float printmarshalmonsters(entity player)
{
	entity e;
	float marshalednumber;
	marshalednumber = 0;

	//remove self from marshaled monsters
	for(e = world; (e = findentity(e, monster_marshal, player)); ) {
		if (e.monster_marshalable) {
			marshalednumber = marshalednumber + 1;
			
			sprint(player, strcat("[", e.netname, "] ^xFAAHealth: ^xF00",
			ftos(floor(e.health)), "^x444/^xF00", ftos(floor(e.max_health)),
			"^7  ^xAFAArmor: ^x0F0", ftos(floor(e.armorvalue))));
			
			sprint(player, strcat("^7  ^xFCASoliderNumber: ", ftos(marshalednumber), "^7\n"));
			
		}
	}
	
	return marshalednumber;
}


void autoplayercolors_choose(entity player) {
	//If only we had matrixes or fast hashes... or fast arrays... but we don't
	//0(white)-14 max (15 is swirly.)
	float xc; //just A counter
	float arandvar;
	float foundgoodcolor = 0;
	//float plamt = 0;
	float s0p0, s1p0, s2p0, s3p0, s4p0, s5p0, s6p0, s7p0, s8p0, s9p0, s10p0, s11p0, s12p0, s13p0, s14p0 = 0;
	float s0p1, s1p1, s2p1, s3p1, s4p1, s5p1, s6p1, s7p1, s8p1, s9p1, s10p1, s11p1, s12p1, s13p1, s14p1 = 0;
	float s0p2, s1p2, s2p2, s3p2, s4p2, s5p2, s6p2, s7p2, s8p2, s9p2, s10p2, s11p2, s12p2, s13p2, s14p2 = 0;
	float s0p3, s1p3, s2p3, s3p3, s4p3, s5p3, s6p3, s7p3, s8p3, s9p3, s10p3, s11p3, s12p3, s13p3, s14p3 = 0;
	float s0p4, s1p4, s2p4, s3p4, s4p4, s5p4, s6p4, s7p4, s8p4, s9p4, s10p4, s11p4, s12p4, s13p4, s14p4 = 0;
	float s0p5, s1p5, s2p5, s3p5, s4p5, s5p5, s6p5, s7p5, s8p5, s9p5, s10p5, s11p5, s12p5, s13p5, s14p5 = 0;
	float s0p6, s1p6, s2p6, s3p6, s4p6, s5p6, s6p6, s7p6, s8p6, s9p6, s10p6, s11p6, s12p6, s13p6, s14p6 = 0;
	float s0p7, s1p7, s2p7, s3p7, s4p7, s5p7, s6p7, s7p7, s8p7, s9p7, s10p7, s11p7, s12p7, s13p7, s14p7 = 0;
	float s0p8, s1p8, s2p8, s3p8, s4p8, s5p8, s6p8, s7p8, s8p8, s9p8, s10p8, s11p8, s12p8, s13p8, s14p8 = 0;
	float s0p9, s1p9, s2p9, s3p9, s4p9, s5p9, s6p9, s7p9, s8p9, s9p9, s10p9, s11p9, s12p9, s13p9, s14p9 = 0;
	float s0p10, s1p10, s2p10, s3p10, s4p10, s5p10, s6p10, s7p10, s8p10, s9p10, s10p10, s11p10, s12p10, s13p10, s14p10 = 0;
	float s0p11, s1p11, s2p11, s3p11, s4p11, s5p11, s6p11, s7p11, s8p11, s9p11, s10p11, s11p11, s12p11, s13p11, s14p11 = 0;
	float s0p12, s1p12, s2p12, s3p12, s4p12, s5p12, s6p12, s7p12, s8p12, s9p12, s10p12, s11p12, s12p12, s13p12, s14p12 = 0;
	float s0p13, s1p13, s2p13, s3p13, s4p13, s5p13, s6p13, s7p13, s8p13, s9p13, s10p13, s11p13, s12p13, s13p13, s14p13 = 0;
	float s0p14, s1p14, s2p14, s3p14, s4p14, s5p14, s6p14, s7p14, s8p14, s9p14, s10p14, s11p14, s12p14, s13p14, s14p14 = 0;
	
	entity e;
  	for(e = findchain(classname, "player"); e; e = e.chain)
	{
	  if (e.autoclientcolorset) {
	        //plamt = plamt + 1;
		if (e.autoclientcolorshirt == 0) {
			if (e.autoclientcolorpants == 0) {
				s0p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s0p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s0p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s0p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s0p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s0p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s0p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s0p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s0p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s0p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s0p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s0p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s0p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s0p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s0p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 1) {
			if (e.autoclientcolorpants == 0) {
				s1p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s1p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s1p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s1p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s1p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s1p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s1p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s1p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s1p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s1p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s1p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s1p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s1p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s1p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s1p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 2) {
			if (e.autoclientcolorpants == 0) {
				s2p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s2p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s2p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s2p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s2p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s2p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s2p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s2p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s2p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s2p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s2p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s2p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s2p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s2p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s2p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 3) {
			if (e.autoclientcolorpants == 0) {
				s3p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s3p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s3p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s3p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s3p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s3p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s3p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s3p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s3p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s3p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s3p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s3p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s3p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s3p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s3p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 4) {
			if (e.autoclientcolorpants == 0) {
				s4p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s4p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s4p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s4p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s4p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s4p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s4p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s4p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s4p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s4p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s4p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s4p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s4p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s4p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s4p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 5) {
			if (e.autoclientcolorpants == 0) {
				s5p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s5p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s5p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s5p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s5p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s5p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s5p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s5p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s5p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s5p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s5p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s5p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s5p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s5p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s5p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 6) {
			if (e.autoclientcolorpants == 0) {
				s6p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s6p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s6p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s6p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s6p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s6p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s6p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s6p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s6p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s6p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s6p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s6p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s6p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s6p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s6p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 7) {
			if (e.autoclientcolorpants == 0) {
				s7p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s7p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s7p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s7p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s7p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s7p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s7p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s7p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s7p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s7p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s7p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s7p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s7p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s7p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s7p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 8) {
			if (e.autoclientcolorpants == 0) {
				s8p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s8p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s8p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s8p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s8p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s8p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s8p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s8p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s8p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s8p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s8p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s8p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s8p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s8p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s8p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 9) {
			if (e.autoclientcolorpants == 0) {
				s9p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s9p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s9p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s9p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s9p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s9p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s9p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s9p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s9p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s9p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s9p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s9p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s9p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s9p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s9p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 10) {
			if (e.autoclientcolorpants == 0) {
				s10p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s10p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s10p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s10p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s10p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s10p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s10p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s10p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s10p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s10p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s10p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s10p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s10p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s10p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s10p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 11) {
			if (e.autoclientcolorpants == 0) {
				s11p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s11p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s11p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s11p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s11p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s11p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s11p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s11p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s11p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s11p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s11p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s11p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s11p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s11p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s11p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 12) {
			if (e.autoclientcolorpants == 0) {
				s12p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s12p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s12p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s12p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s12p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s12p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s12p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s12p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s12p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s12p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s12p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s12p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s12p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s12p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s12p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 13) {
			if (e.autoclientcolorpants == 0) {
				s13p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s13p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s13p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s13p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s13p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s13p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s13p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s13p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s13p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s13p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s13p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s13p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s13p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s13p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s13p14 = 1;
			}
		} else if (e.autoclientcolorshirt == 14) {
			if (e.autoclientcolorpants == 0) {
				s14p0 = 1;
			} else if (e.autoclientcolorpants == 1) {
				s14p1 = 1;
			} else if (e.autoclientcolorpants == 2) {
				s14p2 = 1;
			} else if (e.autoclientcolorpants == 3) {
				s14p3 = 1;
			} else if (e.autoclientcolorpants == 4) {
				s14p4 = 1;
			} else if (e.autoclientcolorpants == 5) {
				s14p5 = 1;
			} else if (e.autoclientcolorpants == 6) {
				s14p6 = 1;
			} else if (e.autoclientcolorpants == 7) {
				s14p7 = 1;
			} else if (e.autoclientcolorpants == 8) {
				s14p8 = 1;
			} else if (e.autoclientcolorpants == 9) {
				s14p9 = 1;
			} else if (e.autoclientcolorpants == 10) {
				s14p10 = 1;
			} else if (e.autoclientcolorpants == 11) {
				s14p11 = 1;
			} else if (e.autoclientcolorpants == 12) {
				s14p12 = 1;
			} else if (e.autoclientcolorpants == 13) {
				s14p13 = 1;
			} else if (e.autoclientcolorpants == 14) {
				s14p14 = 1;
			}
		}
		
	  }
	}
	
	if (s0p0 && s1p1 && s2p2 && s3p3 && s4p4 && s5p5 && s6p6 && s7p7 && s8p8 && s9p9 && s10p10 && s11p11 && s12p12 && s13p13 && s14p14)
	{
			//Nothing, we'll have to use the combinations
	} else {

			//we can use solid colors
			xc = 0;
			while(xc < 392)
			{
				arandvar = floor(random() * 15);
				
				//print("...Trying to find a color", ftos(arandvar), "\n");
				
				if (arandvar == 14 && !s14p14) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 14;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 13 && !s13p13) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 13;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 12 && !s12p12) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 12;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 11 && !s11p11) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 11;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 10 && !s10p10) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 10;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 9 && !s9p9) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 9;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 8 && !s8p8) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 8;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 7 && !s7p7) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 7;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 6 && !s6p6) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 6;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 5 && !s5p5) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 5;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 4 && !s4p4) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 4;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 3 && !s3p3) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 3;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 2 && !s2p2) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 2;
					foundgoodcolor = 1;
					break;
				} else if (arandvar == 1 && !s1p1) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 1;
					foundgoodcolor = 1;
					break;
				} else if (!s0p0) {
					player.autoclientcolorshirt = player.autoclientcolorpants = 0;
					foundgoodcolor = 1;
					break;
				}
				
				
				xc = xc + 1;
			}
	}
	
	if (foundgoodcolor) {
		player.autoclientcolorset = 1;
		return;
	}
	
	//Fk it
	xc = 0;
	while(xc < 100)
	{
		player.autoclientcolorshirt = floor(random() * 15);
		player.autoclientcolorpants = floor(random() * 15);
		
		//print(".....Trying to find a color", ftos(player.autoclientcolorshirt), " ", ftos(player.autoclientcolorpants), "\n");
		
		if (player.autoclientcolorshirt != player.autoclientcolorpants) {
			break;
		}
		
		xc = xc + 1;
	}
	
	player.autoclientcolorset = 1;
	
	return;
}












void WindDownTimesinksOfPlayer (entity player)
{
		player.timesinkfalldamageaccelprotection = 0;
		if (timesinksactive) {
			if (player.timesinkent && player.timesinkent != world) {
				if (player.timesinkent.ammount3 != 2) {
				player.timesinkent.ammount2 = time+player.timesinkent.cnt;
				player.timesinkent.ammount3 = 2; //Phase
				}
			}
		}
}

void TimesinksMatchEnded ()
{
	if (timesinksactive) {
		localcmd(strcat("slowmo ", ftos(timesink_orig_slowmo), "\n"));
	}	
}





void DoClairvoyanceView (entity player, entity spiedonplayer)
{
    if (clienttype(player) == CLIENTTYPE_REAL)
    {
    	////Now using stats and setproperty(VF_ORIGIN... in client/View.qc
	////As SVC_SETVIEW didn't work well for arbitrary views (visculling)
        
	player.hasclairvoyance_camerax = spiedonplayer.origin_x + spiedonplayer.view_ofs_x;
	player.hasclairvoyance_cameray = spiedonplayer.origin_y + spiedonplayer.view_ofs_y;
	player.hasclairvoyance_cameraz = spiedonplayer.origin_z + spiedonplayer.view_ofs_z;
	
	//print("SERVERCLAIRVOYANCE_", vtos(spiedonplayer.origin),"_\n");
    }
}

entity DoClairvoyanceSelectPlayer(entity caster, float myradius)
{	
	local entity enextent;
	enextent = findradius(caster.origin, myradius);
	while(enextent)
	{
		if (enextent != world)
		if (enextent != caster) {
	 		if(enextent.flags & FL_CLIENT)
			{
				if(!enextent.frozen)
				if(!enextent.freezetag_frozen)
				if(!enextent.stoned)
				if(enextent.deadflag == DEAD_NO)
				if(enextent.health > 0)
				if (enextent.classname == "player")
				{
					return(enextent);
				}
			}
		}
		
		enextent = enextent.chain;
	}
	
	return(world);
}

entity DoClairvoyanceSelectMonster(entity caster, float myradius)
{	
	local entity enextent;
	enextent = findradius(caster.origin, myradius);
	while(enextent)
	{
		if (enextent != world)
		if (enextent != caster) {
	 		if(enextent.flags & FL_MONSTER)
			{
				if(!enextent.frozen)
				if(!enextent.freezetag_frozen)
				if(!enextent.stoned)
				if(enextent.deadflag == DEAD_NO)
				if(enextent.health > 0)
				{
					return(enextent);
				}
			}
		}
		
		enextent = enextent.chain;
	}
	
	return(world);
}

void DoClairvoyance (entity player) {
	local entity myselection;
	if (player.hasclairvoyance_cameraon && !player.hasclairvoyance_count) {
		//"Reset"
		player.hasclairvoyance_cameraon = 0;
	} else if (player.hasclairvoyance_count >= 10) {
		if (random() > 0.8) {
			//Reversed
			myselection = DoClairvoyanceSelectMonster(player, 128+player.hasclairvoyance_lvl*128);
			if (myselection == world) {
				myselection = DoClairvoyanceSelectPlayer(player, 128+player.hasclairvoyance_lvl*128);
			}
		} else {
			//Normal
			myselection = DoClairvoyanceSelectPlayer(player, 128+player.hasclairvoyance_lvl*128);
			if (myselection == world) {
				myselection = DoClairvoyanceSelectMonster(player, 128+player.hasclairvoyance_lvl*128);
			}
		}
	
	
		if (myselection != world) {
			//print(etos(myselection), "__", myselection.classname, "\n");
			player.hasclairvoyance_nextcastaddexp = player.hasclairvoyance_nextcastaddexp + 0.02;
			DoClairvoyanceView (player, myselection);
			player.hasclairvoyance_cameraon = 1;
		}
		
		if (time > player.hasclairvoyance_endseertime) {
			player.hasclairvoyance_count = 0;
		}
	} else {
		if (time > player.hasclairvoyance_endwaittime) {
			player.hasclairvoyance_endwaittime = time + 0.1;
			player.hasclairvoyance_count = player.hasclairvoyance_count + 1;
			
			if (player.hasclairvoyance_lvl >= 5) {
				player.hasclairvoyance_endseertime = time + 0.1 + bound(0, player.hasclairvoyance_lvl*0.01, 0.2);
			} else {
				player.hasclairvoyance_endseertime = time + 0.1;
			}
		}
	}
}



void MaybeDoClairvoyance (entity player) {
	if(player.vehicle)
		return;
	
	if(player.hasclairvoyance > time)
	if(!self.frozen)
	if(!self.freezetag_frozen)
	if(!self.stoned)
	if(self.deadflag == DEAD_NO)
	if(self.health > 0)
	{
		DoClairvoyance(player);
		return;
	}
	
	if (player.hasclairvoyance_cameraon) {
		//"Reset"
		player.hasclairvoyance_cameraon = 0;
	}
}







void IncreaseSpellExpAndMaybeLVL (float isscroll, entity caster, .float my_spell, .float my_spell_exp, float addexp, entity myother);

float existantfuncrainsnow;
float nextfuncrainchecktime;
.entity subordinate4;
.entity subordinate5;

float CheckIfEntityIsInRainAdv(entity player, float mytracemovetype) {
	
	entity e;
	vector myzmax;
	float myendposz;
	float myfuncrainfound;
	float mycountrating;
	
		//print(ftos(existantfuncrainsnow),"\n");
	
	if (existantfuncrainsnow > 0) {
		//Do nothing, continue
	} else {
		return 0;
	}	

	
	if not(nextfuncrainchecktime) {
		nextfuncrainchecktime = time;
	}
	
	
	if (nextfuncrainchecktime > time) {
		//return if it's before the global recheck map time
		return 0;
	}
	

	myzmax = self.origin; //We'll use this vector for storage now, later we use it for its intended use
	myzmax_z = world.maxs_z;
	traceline(player.origin + '0 0 1', myzmax, mytracemovetype, world);
	myendposz = trace_endpos_z;

	
	myfuncrainfound = 0;
	e = world;
  	for(e = findchain(classname, "func_rain"); e; e = e.chain)
	{
		if (e != world) {
		if (e != player) {
			myfuncrainfound = myfuncrainfound + 1;
			myzmax = player.absmax; //Intended use of this myzmax vector
			myzmax_z = myendposz; //Because some rain is set uphigh not as a box coming all the way down
			if(boxesoverlap(e.absmin, e.absmax, player.absmin, myzmax))
			{
				mycountrating = e.ammount2; //Saved initial value 
				
					//print(ftos(e.count),"_Player in rain\n");
					//print(ftos(mycountrating),"_Countrating\n");
				
				if (e.ammount3) {
					//If is spell placed, add exp
					IncreaseSpellExpAndMaybeLVL(e.ammount4,
					e.subordinate4,
					spell_aquacaelestis,
					exp_spell_aquacaelestis,
					1, player); 
				}
				
				nextfuncrainchecktime = time;
				return mycountrating;
			}
		}
		}
	}
	
	
	e = world;
  	for(e = findchain(classname, "func_snow"); e; e = e.chain)
	{
		if (e != world) {
		if (e != player) {
			myfuncrainfound = myfuncrainfound + 1;
			myzmax = player.absmax; //Intended use of this myzmax vector
			myzmax_z = myendposz; //Because some snow is set uphigh not as a box coming all the way down
			if(boxesoverlap(e.absmin, e.absmax, player.absmin, myzmax))
			{
				mycountrating = e.ammount2;
				
					//print(ftos(e.count),"Player in snow\n");
					//print(ftos(mycountrating),"_Countrating\n");
					//print(ftos(mycountrating*0.1),"_Countrating_post\n");
				
				if (e.ammount3) {
					//If is spell placed, add exp
					IncreaseSpellExpAndMaybeLVL(e.ammount4,
					e.subordinate4,
					spell_nivosus,
					exp_spell_nivosus,
					1, player); 
				}
				
				nextfuncrainchecktime = time;
				return (mycountrating*0.1); //one tenth the problem that rain is
			}
		}
		}
	}
	
	if (myfuncrainfound > 0) {
		//print("Some rain found in map\n");
		nextfuncrainchecktime = time;
	} else {
		//print("No rain found in map\n");
		//No func_rains exist in map.
		nextfuncrainchecktime =  time + 60;
	}
	
	return 0;
}


float CheckIfEntityIsInRain(entity player) {
	return CheckIfEntityIsInRainAdv(player, MOVE_NORMAL);
}


void func_donothing (void) {
	//Doing nothing, but we're not null!
}

float func_donothing_sucessfully (void) {
	//Doing nothing, but we did it right!
	return TRUE;
}

float func_donothing_unsucessfully (void) {
	//Doing nothing, but we failed somehow!
	return FALSE;
}



void setmodel_and_precacheif (float doprecache, entity myent, string mymodel) {
	if (doprecache) {
		//print("Precache model ", mymodel, " for setmodel_and_precacheif\n");
		precache_model (mymodel);
	}
	setmodel(myent,  mymodel);
}

void setmodel_and_precache (entity myent, string mymodel) {
	setmodel_and_precacheif (1, myent, mymodel);
}


