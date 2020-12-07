void Item_ScheduleRespawnVar(entity e, float a);

.float dmg;
.float dmg_edge;
.float dmg_force;
.float dmg_radius;

float Damage_DamageInfo_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_DAMAGEINFO);
	WriteShort(MSG_ENTITY, self.projectiledeathtype);
	WriteCoord(MSG_ENTITY, floor(self.origin_x));
	WriteCoord(MSG_ENTITY, floor(self.origin_y));
	WriteCoord(MSG_ENTITY, floor(self.origin_z));
	WriteByte(MSG_ENTITY, bound(1, self.dmg, 255));
	WriteByte(MSG_ENTITY, bound(0, self.dmg_radius, 255));
	WriteByte(MSG_ENTITY, bound(1, self.dmg_edge, 255));
	WriteShort(MSG_ENTITY, self.oldorigin_x);
	WriteByte(MSG_ENTITY, self.species);
	return TRUE;
}

void Damage_DamageInfo(vector org, float coredamage, float edgedamage, float rad, vector force, float deathtype, float bloodtype, entity dmgowner)
{
	// TODO maybe call this from non-edgedamage too?
	// TODO maybe make the client do the particle effects for the weapons and the impact sounds using this info?

	entity e;

	if(!sound_allowed(MSG_BROADCAST, dmgowner))
		deathtype |= 0x8000;

	e = spawn();
	setorigin(e, org);
	e.projectiledeathtype = deathtype;
	e.dmg = coredamage;
	e.dmg_edge = edgedamage;
	e.dmg_radius = rad;
	e.dmg_force = vlen(force);
	e.velocity = force;
	e.oldorigin_x = compressShortVector(e.velocity);
	e.species = bloodtype;

	Net_LinkEntity(e, FALSE, 0.2, Damage_DamageInfo_SendEntity);
}

float checkrules_firstblood;

float yoda;
float damage_goodhits;
float damage_gooddamage;
float headshot;
float damage_headshotbonus; // bonus multiplier for head shots, set to 0 after use
float coreshot;
float damage_coreshotbonus; // bonus multiplier for head shots, set to 0 after use


.float dmg_team;
.float teamkill_complain;
.float teamkill_soundtime;
.entity teamkill_soundsource;
.entity pusher;
.float istypefrag;
.float taunt_soundtime;


float IsDifferentTeam(entity a, entity b)
{
	if(teamplay)
	{
		if(a.team == b.team)
			return 0;
	}
	else
	{
		if(a == b)
			return 0;
	}
	return 1;
}

float IsFlying(entity a)
{
	if(a.flags & FL_ONGROUND)
		return 0;
	if(a.waterlevel >= WATERLEVEL_SWIMMING)
		return 0;
	traceline(a.origin, a.origin - '0 0 48', MOVE_NORMAL, a);
	if(trace_fraction < 1)
		return 0;
	return 1;
}

vector GetHeadshotMins(entity targ)
{
	return '-0.5 0 0' * PL_HEAD_x + '0 -0.5 0' * PL_HEAD_y + '0 0 1' * (targ.maxs_z - PL_HEAD_z);
}
vector GetHeadshotMaxs(entity targ)
{
	return '0.5 0 0' * PL_HEAD_x + '0 0.5 0' * PL_HEAD_y + '0 0 1' * targ.maxs_z;
}

vector GetCoreshotMins(entity targ)
{
	return '-0.5 0 0' * PL_CORE_x + '0 -0.5 0' * PL_CORE_y + '0 0 1' * (targ.maxs_z - PL_HEAD_z - autocvar_sv_player_necklength - PL_CORE_z); //(Minus 3 for neck?)
}
vector GetCoreshotMaxs(entity targ)
{
	return '0.5 0 0' * PL_CORE_x + '0 0.5 0' * PL_CORE_y + '0 0 1' * (targ.maxs_z - PL_HEAD_z - autocvar_sv_player_necklength);
}

void UpdateFrags(entity player, float f)
{
	PlayerTeamScore_AddScore(player, f);
}

// NOTE: f=0 means still count as a (positive) kill, but count no frags for it
void W_SwitchWeapon_Force(entity e, float w);
entity GiveFrags_randomweapons;
void GiveFrags (entity attacker, entity targ, float f, float deathtype)
{
	// TODO route through PlayerScores instead
	if(gameover) return;

	if(f < 0)
	{
		if(targ == attacker)
		{
			// suicide
			PlayerScore_Add(attacker, SP_SUICIDES, 1);
		}
		else
		{
			// teamkill
			PlayerScore_Add(attacker, SP_KILLS, -1); // or maybe add a teamkills field?
		}
	}
	else
	{
		// regular frag
		PlayerScore_Add(attacker, SP_KILLS, 1);
		if(targ.playerid)
			PlayerStats_Event(attacker, sprintf("kills-%d", targ.playerid), 1);
	}

	PlayerScore_Add(targ, SP_DEATHS, 1);

	if(g_arena || g_ca)
		if(autocvar_g_arena_roundbased)
			return;

	if(targ != attacker) // not for suicides
	if(g_weaponarena_random)
	{
		// after a frag, exchange the current weapon (or the culprit, if detectable) by a new random weapon
		float culprit;
		culprit = DEATH_WEAPONOF(deathtype);
		if(!culprit)
			culprit = attacker.weapon;
		else if(!WEPSET_CONTAINS_EW(attacker, culprit))
			culprit = attacker.weapon;

		if(g_weaponarena_random_with_laser && culprit == WEP_LASER)
		{
			// no exchange
		}
		else
		{
			if(!GiveFrags_randomweapons)
			{
				GiveFrags_randomweapons = spawn();
				GiveFrags_randomweapons.classname = "GiveFrags_randomweapons";
			}

			if(inWarmupStage)
				WEPSET_COPY_EA(GiveFrags_randomweapons, warmup_start_weapons);
			else
				WEPSET_COPY_EA(GiveFrags_randomweapons, start_weapons);

			// all others (including the culprit): remove
			WEPSET_ANDNOT_EE(GiveFrags_randomweapons, attacker);
			WEPSET_ANDNOT_EW(GiveFrags_randomweapons, culprit);

			// among the remaining ones, choose one by random
			W_RandomWeapons(GiveFrags_randomweapons, 1);

			if(!WEPSET_EMPTY_E(GiveFrags_randomweapons))
			{
				WEPSET_OR_EE(attacker, GiveFrags_randomweapons);
				WEPSET_ANDNOT_EW(attacker, culprit);
			}
		}

		// after a frag, choose another random weapon set
		if not(WEPSET_CONTAINS_EW(attacker, attacker.weapon))
			W_SwitchWeapon_Force(attacker, w_getbestweapon(attacker));
	}

	// FIXME fix the mess this is (we have REAL points now!)
	entity oldself;
	oldself = self;
	self = attacker;
	frag_attacker = attacker;
	frag_target = targ;
	frag_score = f;
	if(MUTATOR_CALLHOOK(GiveFragsForKill))
	{
		f = frag_score;
		self = oldself;
	}
	else
	{
		self = oldself;
		if(g_runematch)
		{
			f = RunematchHandleFrags(attacker, targ, f);
		}
		else if(g_lms)
		{
			// remove a life
			float tl;
			tl = PlayerScore_Add(targ, SP_LMS_LIVES, -1);
			if(tl < lms_lowest_lives)
				lms_lowest_lives = tl;
			if(tl <= 0)
			{
				if(!lms_next_place)
					lms_next_place = player_count;
				else
					lms_next_place = min(lms_next_place, player_count);
				PlayerScore_Add(targ, SP_LMS_RANK, lms_next_place); // won't ever spawn again
				--lms_next_place;
			}
			f = 0;
		}
	}

	attacker.totalfrags += f;

	if(f)
		UpdateFrags(attacker, f);
}

string Obituary_ExtraFragInfo(entity player) // Extra fragmessage information
{
	string health_output = string_null;
	string ping_output = string_null;
	string handicap_output = string_null;
	string output = string_null;

	if(autocvar_sv_fraginfo && ((autocvar_sv_fraginfo == 2) || inWarmupStage))
	{
		// health/armor of attacker (person who killed you)
		if(autocvar_sv_fraginfo_stats && (player.health >= 1))
			health_output = strcat("^7(Health ^1", ftos(rint(player.health)), "^7 / Armor ^2", ftos(rint(player.armorvalue)), "^7)");
		
		// ping display
		if(autocvar_sv_fraginfo_ping)
			ping_output = ((clienttype(player) == CLIENTTYPE_BOT) ? "^2Bot" : strcat("Ping ", ((player.ping >= 150) ? "^1" : "^2"), ftos(rint(player.ping)), "ms"));
			
		// handicap display 
		if(autocvar_sv_fraginfo_handicap) 
		{
			if(autocvar_sv_fraginfo_handicap == 2)	
				handicap_output = strcat(output, strcat("Handicap ^2", ((player.cvar_cl_handicap <= 1) ? "Off" : ftos(rint(player.cvar_cl_handicap)))));
			else if(player.cvar_cl_handicap) // with _handicap 1, only show this if there actually is a handicap enabled.	
				handicap_output = strcat("Handicap ^2", ftos(rint(player.cvar_cl_handicap)));
		}
		
		// format the string
		output = strcat(health_output, (health_output ? ((ping_output || handicap_output) ? " ^7(" : "") : ((ping_output || handicap_output) ? "^7(" : "")), 
			ping_output, (handicap_output ? "^7 / " : ""), 
			handicap_output, ((ping_output || handicap_output) ? "^7)" : ""));
		
		// add new line to the beginning if there is a message
		if(output) { output = strcat("\n", output); }
	}
	
	return output;
}

string AppendItemcodes(string s, entity player)
{
	float w;
	w = player.weapon;
	//if(w == 0)
	//	w = player.switchweapon;
	if(w == 0)
		w = player.cnt; // previous weapon!
	s = strcat(s, ftos(w));
	if(time < player.strength_finished)
		s = strcat(s, "S");
	if(time < player.invincible_finished)
		s = strcat(s, "I");
	if(player.flagcarried != world)
		s = strcat(s, "F");
	if(player.BUTTON_CHAT)
		s = strcat(s, "T");
	if(player.kh_next)
		s = strcat(s, "K");
	if(player.runes)
		s = strcat(s, "|", ftos(player.runes));
	return s;
}

void LogDeath(string mode, float deathtype, entity killer, entity killed)
{
	string s;
	if(!autocvar_sv_eventlog)
		return;
	s = strcat(":kill:", mode);
	s = strcat(s, ":", ftos(killer.playerid));
	s = strcat(s, ":", ftos(killed.playerid));
	s = strcat(s, ":type=", ftos(deathtype));
	s = strcat(s, ":items=");
	s = AppendItemcodes(s, killer);
	if(killed != killer)
	{
		s = strcat(s, ":victimitems=");
		s = AppendItemcodes(s, killed);
	}
	GameLogEcho(s);
}

void Send_KillNotification (string s1, string s2, string s3, float msg, float type)
{
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_KILLNOTIFY);
	WriteString(MSG_BROADCAST, s1);
	WriteString(MSG_BROADCAST, s2);
	WriteString(MSG_BROADCAST, s3);
	WriteShort(MSG_BROADCAST, msg);
	WriteByte(MSG_BROADCAST, type);
}

// Function is used to send a generic centerprint whose content CSQC gets to decide (gentle version or not in the below cases)
void Send_CSQC_KillCenterprint(entity e, string s1, string s2, float msg, float type)
{
	if (clienttype(e) == CLIENTTYPE_REAL)
	{
		msg_entity = e;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_KILLCENTERPRINT);
			WriteString(MSG_ONE, s1);
			WriteString(MSG_ONE, s2);
			WriteShort(MSG_ONE, msg);
			WriteByte(MSG_ONE, type);
		});
	}
}

void RecordIfBurnedOtherToDeath (entity attacker, entity inflictor, entity targ, float deathtype)
{
	if (targ == attacker) // suicides
		return;
	
	if (attacker != world)
	if (targ != world)
	if (DEATH_ISWEAPON(deathtype, WEP_FIREBALL)
	|| DEATH_ISWEAPON(deathtype, WEP_FLAMETHROWER)
	|| deathtype == DEATH_MONSTER_HELLKNIGHT_FIREBALL
	|| deathtype == DEATH_FIRE
	|| deathtype == WEP_TORCH + HITTYPE_SECONDARY)
	{
		//Omitted DEATH_LAVA
		
		local float mymultip = 0;
		local float mycount = 0;
		if (targ.classname == "player")
		{
			mycount = 1;
		} else if (targ.flags & FL_MONSTER) {
			if (isPlayerOrMonsterByClassname(targ)) {
				mycount = 0.1;
			} else {
				mycount = 0.01;
			}
		}
		
		if (targ.species == SPECIES_HUMAN || targ.species == SPECIES_FAE) {
			mymultip = 1;
		} else if (targ.species == SPECIES_ALIEN) {
			mymultip = 0.5;
		} else if (targ.species == SPECIES_ANIMAL) {
			mymultip = 0.2;
		} else if (targ.species == SPECIES_TAR) {
			mymultip = 0.1;
		} else if (targ.species == SPECIES_SKELETON) {
			mymultip = 0;
		} else if (targ.species == SPECIES_STONE) {
			mymultip = 0;
		} else if (targ.species == SPECIES_INSECT) {
			mymultip = 0.001;
		} else if (targ.species == SPECIES_ROBOT_SHINY
		  || targ.species == SPECIES_ROBOT_RUSTY
		  || targ.species == SPECIES_ROBOT_SOLID) {
		  	mymultip = 0.1;
		} else {
			mymultip = 0;
		}
		
		if (targ.vuln_isundead > 0) {
			mymultip = 0;
		}
		
		if (mymultip && mycount) {
			attacker.hasburned_others_to_death = attacker.hasburned_others_to_death + (mymultip*mycount);
		}
	}
}

void Obituary (entity attacker, entity inflictor, entity targ, float deathtype)
{
	string	s, a, msg;
	float type;

	if (targ.classname == "player")
	{
		s = targ.netname;
		a = attacker.netname;

		if (targ == attacker) // suicides
		{
			if (deathtype == DEATH_TEAMCHANGE || deathtype == DEATH_AUTOTEAMCHANGE)
				msg = ColoredTeamName(targ.team); // TODO: check if needed?
			else
				msg = "";
            if(!g_cts) // no "killed your own dumb self" message in CTS
                Send_CSQC_KillCenterprint(targ, msg, "", deathtype, MSG_SUICIDE);

			if(deathtype != DEATH_TEAMCHANGE && deathtype != DEATH_QUIET)
			{
				LogDeath("suicide", deathtype, targ, targ);
				GiveFrags(attacker, targ, -1, deathtype);
			}

			if (targ.killcount > 2)
				msg = ftos(targ.killcount);
			else
				msg = "";
			if(teamplay && deathtype == DEATH_MIRRORDAMAGE)
			{
				if(attacker.team == COLOR_TEAM1)
					deathtype = KILL_TEAM_RED;
				else
					deathtype = KILL_TEAM_BLUE;
			}

			Send_KillNotification(s, msg, "", deathtype, MSG_SUICIDE);
		}
		else if (attacker.classname == "player")
		{
			if(!IsDifferentTeam(attacker, targ))
			{
				if(attacker.team == COLOR_TEAM1)
					type = KILL_TEAM_RED;
				else
					type = KILL_TEAM_BLUE;

				GiveFrags(attacker, targ, -1, deathtype);

				Send_CSQC_KillCenterprint(attacker, s, "", type, MSG_KILL);

				if (targ.killcount > 2)
					msg = ftos(targ.killcount);
				else
					msg = "";

				if (attacker.killcount > 2) {
					msg = ftos(attacker.killcount);
					type = KILL_TEAM_SPREE;
				}
				Send_KillNotification(a, s, msg, type, MSG_KILL);

				attacker.killcount = 0;

				LogDeath("tk", deathtype, attacker, targ);
			}
			else
			{
				if (!checkrules_firstblood)
				{
					checkrules_firstblood = TRUE;
					Send_KillNotification(a, "", "", KILL_FIRST_BLOOD, MSG_KILL);
					// TODO: make these print a newline if they dont
					Send_CSQC_KillCenterprint(attacker, "", "", KILL_FIRST_BLOOD, MSG_KILL);
					Send_CSQC_KillCenterprint(targ, "", "", KILL_FIRST_VICTIM, MSG_KILL);
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_FIRSTBLOOD, 1);
					PlayerStats_Event(targ, PLAYERSTATS_ACHIEVEMENT_FIRSTVICTIM, 1);
				}

				if(targ.istypefrag) {
					Send_CSQC_KillCenterprint(attacker, s, Obituary_ExtraFragInfo(targ), KILL_TYPEFRAG, MSG_KILL);
					Send_CSQC_KillCenterprint(targ, a, Obituary_ExtraFragInfo(attacker), KILL_TYPEFRAGGED, MSG_KILL);
				} else {
					Send_CSQC_KillCenterprint(attacker, s, Obituary_ExtraFragInfo(targ), KILL_FRAG, MSG_KILL);
					Send_CSQC_KillCenterprint(targ, a, Obituary_ExtraFragInfo(attacker), KILL_FRAGGED, MSG_KILL);
				}
				
				if not(attacker.stoned)
				if not(attacker.frozen)
				attacker.taunt_soundtime = time + 1;

				if (deathtype == DEATH_HURTTRIGGER && inflictor.message2 != "")
					msg = inflictor.message2;
				else if (deathtype == DEATH_HURTLASER && inflictor.message2 != "")
					msg = inflictor.message2;
				else if (deathtype == DEATH_CUT && inflictor.message2 != "")
					msg = inflictor.message2;
				else if (deathtype == DEATH_IMPALE && inflictor.message2 != "")
					msg = inflictor.message2;
				else if (deathtype == DEATH_CRUSH && inflictor.message2 != "")
					msg = inflictor.message2;
				else if (deathtype == DEATH_CUSTOM)
					msg = deathmessage;
				else
					msg = "";

				if(strstrofs(msg, "%", 0) < 0)
					msg = strcat("%s ", msg, " by %s");

				Send_KillNotification(a, s, msg, deathtype, MSG_KILL);

				GiveFrags(attacker, targ, 1, deathtype);

				if (targ.killcount > 2) {
					Send_KillNotification(s, ftos(targ.killcount), a, KILL_END_SPREE, MSG_SPREE);
				}

				attacker.killcount = attacker.killcount + 1;

				if (attacker.killcount == 3)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_3, MSG_SPREE);
					AnnounceTo(attacker, "03kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_3, 1);
				}
				else if (attacker.killcount == 5)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_5, MSG_SPREE);
					AnnounceTo(attacker, "05kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_5, 1);
				}
				else if (attacker.killcount == 10)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_10, MSG_SPREE);
					AnnounceTo(attacker, "10kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_10, 1);
				}
				else if (attacker.killcount == 15)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_15, MSG_SPREE);
					AnnounceTo(attacker, "15kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_15, 1);
				}
				else if (attacker.killcount == 20)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_20, MSG_SPREE);
					AnnounceTo(attacker, "20kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_20, 1);
				}
				else if (attacker.killcount == 25)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_25, MSG_SPREE);
					AnnounceTo(attacker, "25kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_25, 1);
				}
				else if (attacker.killcount == 30)
				{
					Send_KillNotification(a, "", "", KILL_SPREE_30, MSG_SPREE);
					AnnounceTo(attacker, "30kills");
					PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_KILL_SPREE_30, 1);
				}
				else if (attacker.killcount > 2) {
					Send_KillNotification(a, ftos(attacker.killcount), "", KILL_SPREE, MSG_SPREE);
				}
				LogDeath("frag", deathtype, attacker, targ);
			}
		}
		else
		{
			Send_CSQC_KillCenterprint(targ, "", "", deathtype, MSG_KILL_ACTION);
			if (deathtype == DEATH_HURTTRIGGER && inflictor.message != "")
				msg = inflictor.message;
			else if (deathtype == DEATH_HURTLASER && inflictor.message != "")
				msg = inflictor.message;
			else if (deathtype == DEATH_CUT && inflictor.message != "")
				msg = inflictor.message;
			else if (deathtype == DEATH_IMPALE && inflictor.message != "")
				msg = inflictor.message;
			else if (deathtype == DEATH_CRUSH && inflictor.message != "")
				msg = inflictor.message;
			else if (deathtype == DEATH_CUSTOM)
				msg = deathmessage;
			else
				msg = "";
			if(strstrofs(msg, "%", 0) < 0)
				msg = strcat("%s ", msg);

			GiveFrags(targ, targ, -1, deathtype);
			if(PlayerScore_Add(targ, SP_SCORE, 0) == -5) {
				AnnounceTo(targ, "botlike");
				PlayerStats_Event(attacker, PLAYERSTATS_ACHIEVEMENT_BOTLIKE, 1);
			}
			Send_KillNotification(s, msg, "", deathtype, MSG_KILL_ACTION);

			if (targ.killcount > 2)
				Send_KillNotification(s, ftos(targ.killcount), "", 0, MSG_KILL_ACTION_SPREE);

			LogDeath("accident", deathtype, targ, targ);
		}

		targ.death_origin = targ.origin;
		if(targ != attacker)
			targ.killer_origin = attacker.origin;

		// FIXME: this should go in PutClientInServer
		if (targ.killcount)
			targ.killcount = 0;
	}
}


void Ice_Think()
{
	if(self.owner.health < 1)
	{
		remove(self);
		return;
	}
	setorigin(self, self.owner.origin - '0 0 16');
	self.nextthink = time;
}

void Freeze (entity targ, float freeze_time, float paralysis)
{
	float monster = (targ.flags & FL_MONSTER);
	float player = (targ.flags & FL_CLIENT);
	
	if(!player && !monster) // only specified entities can be freezed
		return;
		
	if(targ.frozen || targ.freezetag_frozen)
		return;
		
	if (paralysis)
		targ.frozen = 2;
	else
		targ.frozen = 1;
	
	targ.revive_progress = 0;
	//targ.health = 1;
	targ.revive_speed = freeze_time;

	if not (paralysis)
	{
		entity ice;
		ice = spawn();
		ice.owner = targ;
		ice.classname = "ice";
		ice.scale = targ.scale;
		ice.think = Ice_Think;
		ice.nextthink = time;
		ice.frame = floor(random() * 21); // ice model has 20 different looking frames
		setmodel(ice, "models/ice/ice.md3");

		entity oldself;
		oldself = self;
		self = ice;
		Ice_Think();
		self = oldself;
	}
	
	targ.lastV_angle = targ.v_angle;
	
	RemoveGrapplingHook(targ);
	unmarshalmonsters(targ);
}

void Stone (entity targ, float stone_time)
{
	float monster = (targ.flags & FL_MONSTER);
	float player = (targ.flags & FL_CLIENT);
	
	if(!player && !monster) // only specified entities can be freezed
		return;
		
	if(targ.stoned)
		return;
	
	if not(targ.stoneskin == -1) {
		targ.skin = targ.stoneskin;
		targ.stoned = 1;
	} else {
		targ.colormod = '-2 -2 -2';
		targ.stoned = 2;
	}
	
	if (targ.sex == SEX_MALE)
	{
		if (targ.body_phal)
		{
			if not(targ.body_phal.stoneskin == -1) {
				targ.body_phal.skin = targ.stoneskin;
				targ.body_phal.stoned = 1;
			} else {
				targ.body_phal.colormod = '-2 -2 -2';
				targ.body_phal.stoned = 2;
			}	
		}
	}
	
	targ.strevive_progress = 0;
	//targ.health = 1;
	targ.strevive_speed = stone_time;

	targ.stonedorigin = targ.origin;
	targ.stonedangles = targ.angles;
	targ.lastV_angle = targ.v_angle;
	
	RemoveGrapplingHook(targ);
	unmarshalmonsters(targ);
}

void Unfreeze (entity targ)
{
	targ.frozen = 0;
	targ.revive_progress = 0;
	//targ.health = ((targ.classname == STR_PLAYER) ? autocvar_g_balance_health_start : targ.max_health);

	// remove the ice block
	entity ice;
	for(ice = world; (ice = find(ice, classname, "ice")); ) if(ice.owner == targ)
	{
		remove(ice);
		break;
	}
}

void Unstone (entity targ)
{
	if (targ.stoned) {
		if(targ.stoned == 2) {
			targ.colormod = '0 0 0';
		} else {
			targ.skin = targ.realskin;
		}
	}
	
	if (targ.sex == SEX_MALE)
	{
		if (targ.body_phal)
		{
			if(targ.body_phal.stoned == 2) {
				targ.body_phal.colormod = '0 0 0';
			} else {
				targ.body_phal.skin = targ.realskin;
			}
			targ.body_phal.stoned = 0;
		}
	}
	
	targ.stoned = 0;
	targ.strevive_progress = 0;
	//targ.health = ((targ.classname == STR_PLAYER) ? autocvar_g_balance_health_start : targ.max_health);
}

float Fire_AddDamage(entity e, entity o, float d, float t, float dt);
void DamageVulnEffects (entity targ, entity myattacker, float damage, float deathtype)
{
	if (targ.vuln_beam_ignite) {
		if ((damage >= targ.vuln_beam_ignite)
		&& (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE)
		|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII)
		|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)
		|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)
		|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI)
		))
		{
			//These do their damage all in one hit
			//Ignite
			Fire_AddDamage(targ, myattacker, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, deathtype);
		} else if (((damage/frametime) >= targ.vuln_beam_ignite)
		&& (DEATH_ISWEAPON(deathtype, WEP_SUNBEAM)
		|| DEATH_ISWEAPON(deathtype, WEP_STARLASE)
		|| deathtype == DEATH_HURTLASER
		))
		{
			//These do their damage over time
			//Ignite
			Fire_AddDamage(targ, myattacker, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, deathtype);
		}
	}
}

float DamageManaShield (entity targ, float damage)
{
	if (targ.hasmanashield) {
		if ((targ.hasmanashield > time) && (targ.mana > 0)) {
			if (damage > targ.mana) {
				local float myleftoverdamage;
				local float myworkingdamage;
				myleftoverdamage = damage - targ.mana;
				myworkingdamage = targ.mana;
				myworkingdamage = myworkingdamage * 0.333333;
				targ.mana = 0;
				damage = myworkingdamage + myleftoverdamage;
				targ.hasmanashield = 0;
			} else {
				targ.mana = targ.mana - (damage * 0.666666);
				damage = damage * 0.333333;
			}
		} else {
			targ.hasmanashield = 0;
		}
	}
	return damage;
}

float Damage_eval_isexplosive(float deathtype)
{
	if (DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_MORTAR)
	|| DEATH_ISWEAPON(deathtype, WEP_HAGAR)
	|| DEATH_ISWEAPON(deathtype, WEP_SEEKER)
	|| DEATH_ISWEAPON(deathtype, WEP_MINE_LAYER)
	|| DEATH_ISWEAPON(deathtype, WEP_EXPLOSIVE_VEST)
	|| DEATH_ISWEAPON(deathtype, WEP_RPG7_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_RA4_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR)
	|| DEATH_ISWEAPON(deathtype, WEP_HAGAR2)
	|| deathtype == DEATH_RAPTOR_BOMB
	|| deathtype == DEATH_SBROCKET
	|| deathtype == DEATH_WAKIROCKET
	|| deathtype == DEATH_TURRET_FLAC
	|| deathtype == DEATH_TURRET_WALKER_ROCKET
	|| deathtype == DEATH_TURRET_HELLION
	|| deathtype == DEATH_TURRET_HK
	|| deathtype == DEATH_TURRET_MLRS
	|| deathtype == DEATH_TOUCHEXPLODE
	|| deathtype == DEATH_MONSTER_TARBABY_BLOWUP
	|| deathtype == DEATH_GRENADE
	)
	{
		//explosives (sans nuke)
		return(TRUE);
	} else {
		return(FALSE);
	}
}

float DamageSpecialCircumstances (entity targ, float damage, float deathtype, entity attacker)
{
	//So that one doesn't die while handcuffed just from being moved around
	if (targ.handcuffed) {
	if (deathtype == DEATH_FALL || deathtype == DEATH_VHCRUSH)
	{
		if (targ.jailor)
		if (targ.jailor != world)
		if(!targ.jailor.frozen)
		if(!targ.jailor.freezetag_frozen)
		if(!targ.jailor.stoned)
		if(targ.jailor.deadflag == DEAD_NO)
		if(targ.jailor.health > 0)
		{
			if (deathtype == DEATH_VHCRUSH) {
				if (attacker == targ.jailor)
				if (targ.jailor.vehicle)
				if (targ.jailor.vehicle != world)
				if (targ.jailor.vehicle.deadflag == DEAD_NO)
				{
					//No VHCrush Damage, We riding
					damage = 0;
				}
			} else {
				//No FALL Damage
				damage = 0;
			}
		}
	}
	}
	
	return damage;
}

void ZeroOutResists (entity e) {
	//Resistances to damage
	e.resist_acid = 0;   //Slime
	e.resist_blunt = 0;  //Warhammer, beatdown, melee
	e.resist_bullet = 0;
	e.resist_crush = 0;  //Vehicle crush
	e.resist_edged = 0;  //Axe, Sword, Claw
	e.resist_electricity = 0; //Lightning gun, Tesla arc, 
	e.resist_energy = 0; //Nex, Electro, Crylink, Wakigun, Bumbgun, Wakigun, "laser" gun, hlac
	e.resist_explode = 0;//Rockets etc
	e.resist_fall = 0;   //Shooting star, fall etc
	e.resist_fire = 0;   //Fire, Lava
	e.resist_laser = 0;  //Laser
	e.resist_nuke = 0;  //Nuclear explosion
	e.resist_pierce = 0; //Crossbow, Bite
	e.resist_sound = 0; //Tuba
	e.resist_ice = 0; //Freeze damage resistance
	e.resist_rotor = 0; //Helicopter/Aero-plane Rotor blades damage resistance, Special, evaluated before crush
	e.resist_holybolt = 0; //Resist holybolt type damage (usually only affects undead, here for completeness)
}

void ZeroOutVulns (entity e) {
	e.vuln_isundead = 0; //Is the monster/etc undead and thus suceptable to holybolt etc? To what degree?
	e.vuln_beam_ignite = 0; //Dmg rate at which a laser or lightsabre will ignite self (if monster has full fire resist, won't be such a vuln) (This is different from the rest as it does not use a 0 to 1 multiplicative scale, instead you specify the instantanious dmg that will ignight)
	e.vuln_movement_imparable = 0; //Dmg to lowerbody, legs, can slow this entity
}

void ZeroOutBuffs (entity e) {
	e.buff_wont_ignite = 0; //Entity won't ignite if hit by Fire_AddDamage
	e.buff_cancellation_immune = 0; //Cancellation won't nullify this entity's spells (rate: 0 to 1)
}

void ZeroOutVulnsResistsBuffs (entity e) {
	ZeroOutResists(e);
	ZeroOutVulns(e);
	ZeroOutBuffs(e);
}

float DamageResistance (entity targ, float damage, float deathtype)
{
	//print(ftos(deathtype)," deathtype \n");
	if (targ.resist_acid && deathtype == DEATH_SLIME)
	{
		//ACID
		damage = damage - (damage * targ.resist_acid);
	}
	else if ((targ.resist_blunt)
	&& (DEATH_ISWEAPON(deathtype, WEP_WARHAMMERSPIKED)
	|| DEATH_ISWEAPON(deathtype, WEP_CLAWHAMMER)
	|| DEATH_ISWEAPON(deathtype, WEP_ELVENHAMMER)
	|| DEATH_ISWEAPON(deathtype, WEP_KRIEGSHAMMER)
	|| DEATH_ISWEAPON(deathtype, WEP_MORGENSTERN)
	|| DEATH_ISWEAPON(deathtype, WEP_SHOOTINGSTAR)
	|| DEATH_ISWEAPON(deathtype, WEP_SPIKEDFLAIL)
	|| DEATH_ISWEAPON(deathtype, WEP_MILFLAIL)
	|| DEATH_ISWEAPON(deathtype, WEP_SHININGSTAR)
	|| DEATH_ISWEAPON(deathtype, WEP_SPIKEDMACE)
	|| DEATH_ISWEAPON(deathtype, WEP_WARMALLET)
	|| DEATH_ISWEAPON(deathtype, WEP_SPIKEDCLUB)
	|| DEATH_ISWEAPON(deathtype, WEP_SPIKEDCUDGEL)
	|| DEATH_ISWEAPON(deathtype, WEP_GREYIRONMALLET)
	|| DEATH_ISWEAPON(deathtype, WEP_FLASHLIGHT)
	|| DEATH_ISWEAPON(deathtype, WEP_MULTITOOL)
	|| DEATH_ISWEAPON(deathtype, WEP_SHACKLES)
	|| DEATH_ISWEAPON(deathtype, WEP_TETSUBO)
	|| DEATH_ISWEAPON(deathtype, WEP_BRONZECUDGEL)
	|| DEATH_ISWEAPON(deathtype, WEP_FLANGEDMACE)
	|| DEATH_ISWEAPON(deathtype, WEP_CUDGEL)
	|| DEATH_ISWEAPON(deathtype, WEP_QUARTERSTAFF)
	|| DEATH_ISWEAPON(deathtype, WEP_INFANTRYSTAFF)
	|| DEATH_ISWEAPON(deathtype, WEP_KIDUCHI)
	|| DEATH_ISWEAPON(deathtype, WEP_STAFFFLAME)
	|| DEATH_ISWEAPON(deathtype, WEP_STAFFMAGI)
	|| DEATH_ISWEAPON(deathtype, WEP_ELVENSTAFF)
	|| DEATH_ISWEAPON(deathtype, WEP_CROWBAR)
	|| DEATH_ISWEAPON(deathtype, WEP_IRONCROW)
	|| DEATH_ISWEAPON(deathtype, WEP_HANDCUFFS)
	|| DEATH_ISWEAPON(deathtype, WEP_BAT)
	|| deathtype == WEP_TORCH
	|| deathtype == DEATH_BEATDOWN
	|| deathtype == DEATH_TURRET_WALKER_MEELE
	|| deathtype == DEATH_MONSTER_DEMON_MELEE
	|| deathtype == DEATH_MONSTER_DEMON_JUMP
	|| deathtype == DEATH_MONSTER_SHAMBLER_MELEE
	|| deathtype == DEATH_MONSTER_DOG_JUMP
	|| deathtype == DEATH_MONSTER_SHALRATH_MELEE
	|| deathtype == DEATH_MONSTER_MELEE
	|| deathtype == DEATH_MONSTER_ZOMBIE
	))
	{	
		//BLUNT FORCE
		damage = damage - (damage * targ.resist_blunt);
	}
	else if ((targ.resist_bullet)
	&& (DEATH_ISWEAPON(deathtype, WEP_SHOTGUN)
	|| DEATH_ISWEAPON(deathtype, WEP_PUMPSHOTGUN)
	|| DEATH_ISWEAPON(deathtype, WEP_SPORTSHOTGUN)
	|| DEATH_ISWEAPON(deathtype, WEP_STREETSWEEPER)
	|| DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1897)
	|| DEATH_ISWEAPON(deathtype, WEP_M1897TRENCHGUN)
	|| DEATH_ISWEAPON(deathtype, WEP_ITHACASTAKEOUT)
	|| DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESHOTGUN)
	|| DEATH_ISWEAPON(deathtype, WEP_TENGAUGEDOUBLE)
	|| DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESAWEDOFF)
	|| DEATH_ISWEAPON(deathtype, WEP_TENGAUGESAWEDOFF)
	|| DEATH_ISWEAPON(deathtype, WEP_SPAS12)
	|| DEATH_ISWEAPON(deathtype, WEP_RIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_G98)
	|| DEATH_ISWEAPON(deathtype, WEP_MOSIN)
	|| DEATH_ISWEAPON(deathtype, WEP_T17MMRIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_M1903)
	|| DEATH_ISWEAPON(deathtype, WEP_TARGETPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_HENRY1860RIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1873RIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_HENRY1860MARESLEG)
	|| DEATH_ISWEAPON(deathtype, WEP_COLTLIGHTNING)
	|| DEATH_ISWEAPON(deathtype, WEP_SHARPSRIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_LRR)
	|| DEATH_ISWEAPON(deathtype, WEP_UZI)
	|| DEATH_ISWEAPON(deathtype, WEP_M1921)
	|| DEATH_ISWEAPON(deathtype, WEP_M1928)
	|| DEATH_ISWEAPON(deathtype, WEP_M1929)
	|| DEATH_ISWEAPON(deathtype, WEP_PDW)
	|| DEATH_ISWEAPON(deathtype, WEP_HMG)
	|| DEATH_ISWEAPON(deathtype, WEP_LEWISMG)
	|| DEATH_ISWEAPON(deathtype, WEP_HELLRIEGELSMG)
	|| DEATH_ISWEAPON(deathtype, WEP_MG0815)
	|| DEATH_ISWEAPON(deathtype, WEP_MG)
	|| DEATH_ISWEAPON(deathtype, WEP_SHOTGUNAUTOMAT)
	|| DEATH_ISWEAPON(deathtype, WEP_PISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_BIGPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_LONGPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_LARGEPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_FIVESEVENPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_MAUSERPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_M9PISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_M93RPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_BROWNINGHP)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTAUTO)
	|| DEATH_ISWEAPON(deathtype, WEP_MACHINEPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_CZSKORPION)
	|| DEATH_ISWEAPON(deathtype, WEP_SVSKORPION)
	|| DEATH_ISWEAPON(deathtype, WEP_MICROUZI)
	|| DEATH_ISWEAPON(deathtype, WEP_TEC9)
	|| DEATH_ISWEAPON(deathtype, WEP_POUNDERSMG)
	|| DEATH_ISWEAPON(deathtype, WEP_MINIUZI)
	|| DEATH_ISWEAPON(deathtype, WEP_REVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_FLINTLOCKPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_MUSKET)
	|| DEATH_ISWEAPON(deathtype, WEP_TANEGASHIMA)
	|| DEATH_ISWEAPON(deathtype, WEP_NAVY1851REVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_R1856REVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_COLT44REVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_SCHOFIELDREVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_MAGNUM)
	|| DEATH_ISWEAPON(deathtype, WEP_NAGANT1895)
	|| DEATH_ISWEAPON(deathtype, WEP_WEBLEY)
	|| DEATH_ISWEAPON(deathtype, WEP_WEBLEYLONG)
	|| DEATH_ISWEAPON(deathtype, WEP_FFMAGNUM)
	|| DEATH_ISWEAPON(deathtype, WEP_PEPPERBOXREVOLVER)
	|| DEATH_ISWEAPON(deathtype, WEP_CARBINE)
	|| DEATH_ISWEAPON(deathtype, WEP_AK47)
	|| DEATH_ISWEAPON(deathtype, WEP_RPD)
	|| DEATH_ISWEAPON(deathtype, WEP_PKM)
	|| DEATH_ISWEAPON(deathtype, WEP_M249PARA)
	|| DEATH_ISWEAPON(deathtype, WEP_SVD)
	|| DEATH_ISWEAPON(deathtype, WEP_BAR1918)
	|| DEATH_ISWEAPON(deathtype, WEP_CHAUCHAT)
	|| DEATH_ISWEAPON(deathtype, WEP_SHOSHO)
	|| DEATH_ISWEAPON(deathtype, WEP_AMR18)
	|| DEATH_ISWEAPON(deathtype, WEP_SKS45)
	|| DEATH_ISWEAPON(deathtype, WEP_M82RIFLE)
	|| DEATH_ISWEAPON(deathtype, WEP_AKS74U)
	|| DEATH_ISWEAPON(deathtype, WEP_M16MINI)
	|| DEATH_ISWEAPON(deathtype, WEP_SPECTRE)
	|| DEATH_ISWEAPON(deathtype, WEP_M16VN)
	|| DEATH_ISWEAPON(deathtype, WEP_M16A2)
	|| DEATH_ISWEAPON(deathtype, WEP_FNSCAR)
	|| DEATH_ISWEAPON(deathtype, WEP_G36C)
	|| DEATH_ISWEAPON(deathtype, WEP_L85A2)
	|| DEATH_ISWEAPON(deathtype, WEP_STYERAUG)
	|| DEATH_ISWEAPON(deathtype, WEP_STYERTMP)
	|| DEATH_ISWEAPON(deathtype, WEP_P90)
	|| DEATH_ISWEAPON(deathtype, WEP_FAMAS)
	|| DEATH_ISWEAPON(deathtype, WEP_TT33PISTOL)
	
	|| deathtype == DEATH_SPORTSTERGUN
	|| (deathtype == (DEATH_SPORTSTERGUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_SPORTSTERGUN + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_SPORTSTERGUN + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| (deathtype ==  DEATH_SPORTSTERGUNHV)
	|| (deathtype == (DEATH_SPORTSTERGUNHV + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_SPORTSTERGUNHV + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_SPORTSTERGUNHV + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| (deathtype ==  DEATH_SPORTSTERGUNLT)
	|| (deathtype == (DEATH_SPORTSTERGUNLT + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_SPORTSTERGUNLT + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_SPORTSTERGUNLT + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| deathtype == DEATH_TURRET_WALKER_GUN
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_CORESHOT))
	
	|| deathtype == DEATH_TURRET_MACHINEGUN
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_CORESHOT))	
	
	|| deathtype == DEATH_MONSTER_SOLDIER_NAIL
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| deathtype == DEATH_MONSTER_ENFORCER_NAIL
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| deathtype == DEATH_MONSTER_OGRE_NAIL
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	
	|| deathtype == DEATH_FRAGMENT
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	))
	{
		//BULLET
		damage = damage - (damage * targ.resist_bullet);
	}
	else if ((targ.resist_crush)
	&& (deathtype == DEATH_CRUSH
	|| deathtype == DEATH_VHCRUSH
	|| deathtype == DEATH_BATTERINGRAM
	))
	{
		//CRUSH
		damage = damage - (damage * targ.resist_crush);
	}
	else if ((targ.resist_edged)
	&& (DEATH_ISWEAPON(deathtype, WEP_SHORTSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_LONGSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_ARMINGSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_CRUSADERSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_FIGHTERSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_BASTARDSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_CLAYMORE)
	|| DEATH_ISWEAPON(deathtype, WEP_FLAMBERGE)
	|| DEATH_ISWEAPON(deathtype, WEP_DEFENDERSWORD)
	|| DEATH_ISWEAPON(deathtype, WEP_SCIMITAR)
	|| DEATH_ISWEAPON(deathtype, WEP_FALCHION)
	|| DEATH_ISWEAPON(deathtype, WEP_DADAO)
	|| DEATH_ISWEAPON(deathtype, WEP_PUDAO)
	|| DEATH_ISWEAPON(deathtype, WEP_BROADAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_WARAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_SKIRMISHERSAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_BATTLEAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_TEMPLARAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_DOUBLEBITAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_WOODAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_AXE)
	|| DEATH_ISWEAPON(deathtype, WEP_BEARDEDAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_INFANTRYAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_ELVENAXE)
	|| (DEATH_ISWEAPON(deathtype, WEP_POLEAXE) && (deathtype & HITTYPE_SECONDARY))
	|| (DEATH_ISWEAPON(deathtype, WEP_BARDICHE) && (deathtype & HITTYPE_SECONDARY))
	|| DEATH_ISWEAPON(deathtype, WEP_STONEAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_ELVENSABRE)
	|| DEATH_ISWEAPON(deathtype, WEP_KATANA)
	|| DEATH_ISWEAPON(deathtype, WEP_SHIRASAYA)
	|| DEATH_ISWEAPON(deathtype, WEP_ZATOICHI)
	|| DEATH_ISWEAPON(deathtype, WEP_ODACHI)
	|| DEATH_ISWEAPON(deathtype, WEP_NAGAMAKI)
	|| DEATH_ISWEAPON(deathtype, WEP_ELVENGLAIVE)
	|| DEATH_ISWEAPON(deathtype, WEP_IRONKNIFE)
	|| DEATH_ISWEAPON(deathtype, WEP_BOWIEKNIFE)
	|| (DEATH_ISWEAPON(deathtype, WEP_KNIFE) && (deathtype & HITTYPE_SECONDARY))
	|| DEATH_ISWEAPON(deathtype, WEP_CHAINSAW)
	|| DEATH_ISWEAPON(deathtype, WEP_POWERSAW)
	|| deathtype == DEATH_MONSTER_SHAMBLER_CLAW
	|| deathtype == DEATH_MONSTER_OGRE_CHAINSAW
	|| deathtype == DEATH_CUT
	))
	{
		//EDGED OR CLAW
		damage = damage - (damage * targ.resist_edged);
	}
	else if ((targ.resist_electricity)
	&& (DEATH_ISWEAPON(deathtype, WEP_LIGHTNINGGUN)
	|| deathtype == DEATH_TURRET_TESLA
	|| deathtype == DEATH_MONSTER_SHAMBLER_LIGHTNING
	))
	{
		//ELECTRICITY
		damage = damage - (damage * targ.resist_electricity);
	}
	else if ((targ.resist_energy)
	&& (DEATH_ISWEAPON(deathtype, WEP_LASER)
	|| DEATH_ISWEAPON(deathtype, WEP_NEX)
	|| DEATH_ISWEAPON(deathtype, WEP_MINSTANEX)
	|| DEATH_ISWEAPON(deathtype, WEP_CRYLINK)
	|| DEATH_ISWEAPON(deathtype, WEP_CRYPISTOL)
	|| DEATH_ISWEAPON(deathtype, WEP_CRYLANCER)
	|| DEATH_ISWEAPON(deathtype, WEP_ELECTRO)
	|| DEATH_ISWEAPON(deathtype, WEP_HLAC)
	|| DEATH_ISWEAPON(deathtype, WEP_STARBLAST)
	|| DEATH_ISWEAPON(deathtype, WEP_SUNBURST)
	|| DEATH_ISWEAPON(deathtype, WEP_SUNBOLT)
	|| deathtype == DEATH_WAKIGUN
	|| deathtype == DEATH_BUMB_GUN
	|| deathtype == DEATH_RAPTOR_CANNON
	|| deathtype == DEATH_TURRET_EWHEEL
	|| deathtype == DEATH_TURRET_PHASER
	|| deathtype == DEATH_TURRET_PLASMA
	|| deathtype == DEATH_TURRET_AUTOSHLAC
	))
	{
		//ENERGY
		damage = damage - (damage * targ.resist_energy);
	}
	else if ((targ.resist_explode)
	&& (Damage_eval_isexplosive(deathtype)
	))
	{
		//EXPLOSIVES (SANS NUKE)
		damage = damage - (damage * targ.resist_explode);
	}
	else if ((targ.resist_fall)
	&& (deathtype == DEATH_FALL
	|| deathtype == DEATH_SHOOTING_STAR
	))
	{
		//FALL
		damage = damage - (damage * targ.resist_fall);
	}
	else if ((targ.resist_fire)
	&& (DEATH_ISWEAPON(deathtype, WEP_FIREBALL)
	|| DEATH_ISWEAPON(deathtype, WEP_FLAMETHROWER)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI)
	|| deathtype == DEATH_MONSTER_HELLKNIGHT_FIREBALL
	|| deathtype == DEATH_FIRE
	|| deathtype == WEP_TORCH + HITTYPE_SECONDARY
	|| deathtype == DEATH_LAVA
	))
	{
		//FIRE
		damage = damage - (damage * targ.resist_fire);
	}
	else if (targ.resist_ice && deathtype == DEATH_ICE)
	{
		//ICE FREEZING DEATH
		damage = damage - (damage * targ.resist_ice);
	}
	else if ((targ.resist_laser)
	&& (deathtype == DEATH_HURTLASER
	|| DEATH_ISWEAPON(deathtype, WEP_SUNBEAM)
	|| DEATH_ISWEAPON(deathtype, WEP_STARLASE)
	))
	{
		//LASERBEAM
		damage = damage - (damage * targ.resist_laser);
	}
	else if (targ.resist_nuke && DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER))
	{
		//NUKE
		damage = damage - (damage * targ.resist_nuke);
	}
	else if ((targ.resist_pierce)
	&& (DEATH_ISWEAPON(deathtype, WEP_CROSSBOWDTWR)
	|| DEATH_ISWEAPON(deathtype, WEP_LIGHTCROSSBOW)
	|| DEATH_ISWEAPON(deathtype, WEP_LONGBOW)
	|| DEATH_ISWEAPON(deathtype, WEP_YUMIBOW)
	|| DEATH_ISWEAPON(deathtype, WEP_COMPOSITEBOW)
	|| DEATH_ISWEAPON(deathtype, WEP_CRUDEBOW)
	|| DEATH_ISWEAPON(deathtype, WEP_CALTROP)
	|| DEATH_ISWEAPON(deathtype, WEP_RAPIER)
	|| DEATH_ISWEAPON(deathtype, WEP_PICKAXE)
	|| DEATH_ISWEAPON(deathtype, WEP_DAGGER)
	|| DEATH_ISWEAPON(deathtype, WEP_ARKANSASTOOTHPICK)
	|| (DEATH_ISWEAPON(deathtype, WEP_KNIFE) && (!(deathtype & HITTYPE_SECONDARY)))
	|| DEATH_ISWEAPON(deathtype, WEP_SAI)
	|| DEATH_ISWEAPON(deathtype, WEP_SPEAR)
	|| DEATH_ISWEAPON(deathtype, WEP_YARI)
	|| (DEATH_ISWEAPON(deathtype, WEP_POLEAXE) && (!(deathtype & HITTYPE_SECONDARY)))
	|| (DEATH_ISWEAPON(deathtype, WEP_BARDICHE) && (!(deathtype & HITTYPE_SECONDARY)))
	|| deathtype == DEATH_MONSTER_DOG_BITE
	|| deathtype == DEATH_MONSTER_FISH_BITE
	|| deathtype == DEATH_MONSTER_HELLFISH_BITE
	|| deathtype == DEATH_IMPALE
	))
	{
		//PIERCE OR BITE
		damage = damage - (damage * targ.resist_pierce);
	}
	else if (targ.resist_sound && DEATH_ISWEAPON(deathtype, WEP_TUBA))
	{
		//TUBA
		damage = damage - (damage * targ.resist_sound);
	}
	else if (targ.resist_holybolt && deathtype == DEATH_HOLYBOLT)
	{
		//HOLYBOLT, used in spell, usually only damages .vuln_isundead beings in the spell code
		damage = damage - (damage * targ.resist_holybolt);
	}
	//Note Helicopter/Aero-plane Rotor blades damage resistances are Special
	//they are evaluated before crush in the vehicle code.
	
	
	return damage;
}

void DamageDoMangleHobble (entity targ, float concussdamage, float deathtype)
{
	if (g_weaponnomangleorhobble) {
		return;
	}
	
	if ((targ.resist_explode < 1)
	&& (DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_MINE_LAYER)
	|| DEATH_ISWEAPON(deathtype, WEP_EXPLOSIVE_VEST)
	|| DEATH_ISWEAPON(deathtype, WEP_RPG7_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_RA4_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR)
	|| deathtype == DEATH_RAPTOR_BOMB
	|| deathtype == DEATH_TURRET_HELLION
	|| deathtype == DEATH_TURRET_HK
	|| deathtype == DEATH_TURRET_MLRS
	|| deathtype == DEATH_MONSTER_TARBABY_BLOWUP
	))
	{
		//EXPLOSIVES (SANS NUKE)
		concussdamage = concussdamage;
	} else if ((targ.resist_explode < 1)
	&& (DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER)
	|| DEATH_ISWEAPON(deathtype, WEP_MORTAR)
	|| DEATH_ISWEAPON(deathtype, WEP_HAGAR)
	|| DEATH_ISWEAPON(deathtype, WEP_SEEKER)
	|| DEATH_ISWEAPON(deathtype, WEP_HAGAR2)
	|| deathtype == DEATH_SBROCKET
	|| deathtype == DEATH_WAKIROCKET
	|| deathtype == DEATH_TURRET_FLAC
	|| deathtype == DEATH_TURRET_WALKER_ROCKET
	|| deathtype == DEATH_TOUCHEXPLODE
	|| deathtype == DEATH_MONSTER_TARBABY_BLOWUP
	|| deathtype == DEATH_GRENADE
	))
	{
		//EXPLOSIVES (SANS NUKE)
		concussdamage = concussdamage * 0.5;
		
	} else if ((targ.resist_nuke < 1) && DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER))
	{
		//NUKE
		concussdamage = concussdamage * 2;
	} else {
		concussdamage = 0;
	}
	
	if (concussdamage) {
		if (concussdamage < 10) {
			//Do nothing
		} else if (concussdamage >= 100) {
			targ.tempmangled_l = 1;
			targ.tempmangled_r = 1;
			targ.temphobbled_l = 1;
			targ.temphobbled_r = 1;
			targ.tempmanhoblocked = concussdamage + targ.tempmanhoblocked;
		} else {
			if (concussdamage > (random()*100)) targ.tempmangled_l = 1;
			if (concussdamage > (random()*100)) targ.tempmangled_r = 1;
			if (concussdamage > (random()*100)) targ.temphobbled_l = 1;
			if (concussdamage > (random()*100)) targ.temphobbled_r = 1;
			if (concussdamage > (random()*100)) targ.tempmanhoblocked = concussdamage + targ.tempmanhoblocked;
		}
	}
}

void DamageDoMovementImpare (entity targ, float mydamage, float deathtype, entity myattacker)
{	
	if(targ.vuln_movement_imparable)
	if(targ.dmgmvmntimpare > 0)
	if(mydamage > 0)
	if(targ.dmgmvmntimparetime)
	if(targ.dmgmvmntimparetime == time)
	if(targ.dmgmvmntimparedthtyp)
	if(targ.dmgmvmntimparedthtyp == deathtype)
	if(targ.dmgmvmntimpareatkr == myattacker)
	{
		targ.tempmovementimpared = targ.tempmovementimpared + (targ.dmgmvmntimpare*targ.vuln_movement_imparable);
		targ.tempmvmntimprdlocked = mydamage + targ.tempmvmntimprdlocked;
	}
}

void DamageDoDisorientate (entity targ, float mydamage, float deathtype, entity myattacker)
{	
	if(targ.vuln_movement_imparable)
	if(targ.dmgdisorientate > 0)
	if(mydamage > 0)
	if(targ.dmgdisorientatetime)
	if(targ.dmgdisorientatetime == time)
	if(targ.dmgdisorientatedthtyp)
	if(targ.dmgdisorientatedthtyp == deathtype)
	if(targ.dmgdisorientateatkr == myattacker)
	{
		
		if ((targ.tempdisorientated_time > time) && targ.tempdisorientated) {
			targ.tempdisorientated_time = targ.tempdisorientated_time + (mydamage*targ.dmgdisorientate);
		} else {
			targ.tempdisorientated_time = time + (mydamage*targ.dmgdisorientate);
		}
		targ.tempdisorientated = 1;
		
		
		////Doesn't add much...
		//if (!targ.permblinded) {
		//	if (targ.stat_blinded < 10) {
		//		targ.stat_blinded = 10;
		//		targ.tempblinded_nexttime = time + 3;
		//	}
		//}
		////
	}
}


float DamageTargIsWithinGraceCircleAndHasGrace(entity targ)
{
	local float myvlentocenter;
	if (targ.gracegivingtime) {
		if (!targ.gracegivingent || targ.gracegivingent == world) {
			//
		} else if (time > targ.gracegivingtime) {
			//
		} else {
			myvlentocenter = vlen(targ.origin - targ.gracegivingent.origin);
			if (myvlentocenter < targ.gracegivingradius) {
				return TRUE;
			}
		}
	}

	return FALSE;
}

float DamageTargIsNotWithinGrace(entity targ)
{
	if (DamageTargIsWithinGraceCircleAndHasGrace(targ)) {
		return FALSE;
	}
	
	return TRUE;
}

float DamageTargAndAttackerWithinVampyricConduit(entity targ, entity targ2)
{
	local float myvlentocenter;
	if (targ.vampyricconduitgivingtime) {
		if (!targ.vampyricconduitgivingent || targ.vampyricconduitgivingent == world) {
			//
		} else if (time > targ.vampyricconduitgivingtime) {
			//
		} else {
			myvlentocenter = vlen(targ.origin - targ.vampyricconduitgivingent.origin);
			if (myvlentocenter < targ.vampyricconduitgivingradius) {
				myvlentocenter = vlen(targ2.origin - targ.vampyricconduitgivingent.origin);
				if (myvlentocenter < targ.vampyricconduitgivingradius) {
					return TRUE;
				}
			}
		}
	}

	return FALSE;
}

void IncreaseSpellExpAndMaybeLVL (float isscroll, entity caster, .float my_spell, .float my_spell_exp, float addexp, entity myother);

void DamageVampyricConduit (entity targ, float damage, float deathtype, entity attacker)
{
	float myhealthmultip;
	myhealthmultip = 1;
	if (DamageTargAndAttackerWithinVampyricConduit(attacker, targ))
	{
		if (attacker.vuln_isundead > 0 && targ.vuln_isundead > 0) {
			myhealthmultip = bound(0, attacker.vuln_isundead + targ.vuln_isundead, 1);
		} else if (!attacker.vuln_isundead && !targ.vuln_isundead) {
			//Nothing
		} else {
			myhealthmultip = bound(0, attacker.vuln_isundead + targ.vuln_isundead, 1);
			myhealthmultip = myhealthmultip * -1;
		}
		
		attacker.health = attacker.health + (damage * myhealthmultip);	
		
		if (damage) {
			if (attacker.vampyricconduitgivingent) {
				if (attacker.vampyricconduitgivingent.realowner && attacker.vampyricconduitgivingent.realowner != world) {
					if (!attacker.vampyricconduitgivingent.ammount2) {
						IncreaseSpellExpAndMaybeLVL(attacker.vampyricconduitgivingent.ammount2,
						attacker.vampyricconduitgivingent.realowner,
						spell_vampyricconduit,
						exp_spell_vampyricconduit,
						(0.5), targ); 
					}
				}
			}
		}
	}
}


float DamageGrace (entity targ, float damage, float deathtype, entity attacker) {
	if (targ.gracegivingtime) {
		local float myvlentocenter;
		local float attackervlentocenter;
		local float attackervlentotarg;
		local float healthmultiplier;
	
		healthmultiplier = 0;
		
		if (!targ.gracegivingent || targ.gracegivingent == world) {
			//print("NoEnt\n");
			targ.gracegivingtime = 0;
			targ.gracegivingradius = 0;
			targ.gracegivingent = world;
		} else if (time > targ.gracegivingtime) {
			//print("Time Expired\n");
			targ.gracegivingtime = 0;
			targ.gracegivingradius = 0;
			targ.gracegivingent = world;
		} else {
			//print("Time Is Good\n");
			if (DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER)) {
				return damage;
			}
		
			if (targ.vuln_isundead > 0) {
				//print("Undead\n");
				//Do nothing
			} else if (damage > 0) {
				//print("Dmg Good\n");
				myvlentocenter = vlen(targ.origin - targ.gracegivingent.origin);
				attackervlentocenter = vlen(attacker.origin - targ.gracegivingent.origin);
				attackervlentotarg = vlen(attacker.origin - targ.origin);
				
				//Furthur away, and higher spell level, more multip for health
				healthmultiplier = bound(0,
				bound(0.01, (targ.gracegivingent.cnt/10), 2) * 
				bound(0, (attackervlentotarg/2000), 4),
				10);
				
				//print(ftos(myvlentocenter), " MV2C,",
				//ftos(attackervlentocenter), " AV2C,",
				//ftos(attackervlentocenter), " AV2Targ,",
				//ftos(healthmultiplier), " HealthMultip\n");
				
				if (myvlentocenter < targ.gracegivingradius) {
					//print("Within Circle\n");
					if not (attackervlentocenter < targ.gracegivingradius) {
						//print("Attacker outside circle\n");
						
						if (targ.health < (90+(targ.gracegivingent.cnt*2))) {
							local float addhealthammount;
							local float addhealthammountmin;
							addhealthammount = ((damage) * healthmultiplier);
							addhealthammountmin = ((damage) * 0.2);
							if (myvlentocenter < (targ.gracegivingradius*0.5)) {
								//Close to center
								targ.health = targ.health + bound(addhealthammountmin, addhealthammount, addhealthammount);
							} else {
								//Furthur from center but still in circle
								local float mymulifromhalfcir;
								mymulifromhalfcir = (1 - ((myvlentocenter - (targ.gracegivingradius*0.5)) / (targ.gracegivingradius*0.5)));
								targ.health = targ.health + (bound(addhealthammountmin, addhealthammount, addhealthammount) * mymulifromhalfcir);
							}
							
							if (targ.health > (100+(targ.gracegivingent.cnt*5))) {
								targ.health = 100+(targ.gracegivingent.cnt*5);
							}
						}
						
						damage = 0;

						pointparticles(particleeffectnum("cherryblossom"), targ.origin+targ.view_ofs, '0 0 0', 1);
					} else if (deathtype == DEATH_FRAGMENT) {
						//print (etos(attacker),"Attacker\n");
						damage = 0;
						
						pointparticles(particleeffectnum("cherryblossom"), targ.origin+targ.view_ofs, '0 0 0', 1);
					}
				}
			}
		}
	}
	
	return damage;
}


void W_AutoEvaluatePipeTypeByDamage(float deathtype);

float DamageDoesCoreshotByClassname (entity targ)
{
				//No zombies (their vitals don't work, headshot them)
				if ((targ.classname == "player")
				|| (targ.classname == "monster_shambler")
				|| (targ.classname == "monster_soldier")
				|| (targ.classname == "monster_ogre")
				|| (targ.classname == "monster_knight")
				|| (targ.classname == "monster_hellknight")
				|| (targ.classname == "monster_minotaur")
				|| (targ.classname == "monster_goblin")
				|| (targ.classname == "monster_police")
				|| (targ.classname == "monster_royalguard")
				|| (targ.classname == "monster_demon")
				|| (targ.classname == "monster_imp")
				|| (targ.classname == "monster_biledemon")
				|| (targ.classname == "monster_horndemon")
				|| (targ.classname == "monster_seraph")
				|| (targ.classname == "monster_wizard")
				|| (targ.classname == "monster_fighter")
				|| (targ.classname == "monster_ninjaassassin")
				|| (targ.classname == "monster_shinrae"))
				{
					return TRUE;
				}
				
				return FALSE;
}
		
float DamageDoesHeadshotByClassname (entity targ)
{
				if ((targ.classname == "player")
				|| (targ.classname == "monster_zombie")
				|| (targ.classname == "monster_shambler")
				|| (targ.classname == "monster_soldier")
				|| (targ.classname == "monster_ogre")
				|| (targ.classname == "monster_knight")
				|| (targ.classname == "monster_hellknight")
				|| (targ.classname == "monster_minotaur")
				|| (targ.classname == "monster_goblin")
				|| (targ.classname == "monster_police")
				|| (targ.classname == "monster_royalguard")
				|| (targ.classname == "monster_demon")
				|| (targ.classname == "monster_imp")
				|| (targ.classname == "monster_biledemon")
				|| (targ.classname == "monster_horndemon")
				|| (targ.classname == "monster_seraph")
				|| (targ.classname == "monster_wizard")
				|| (targ.classname == "monster_fighter")
				|| (targ.classname == "monster_ninjaassassin")
				|| (targ.classname == "monster_shinrae")
				)
				{
					return TRUE;
				}
				
				return FALSE;
}


// these are updated by each Damage call for use in button triggering and such
entity damage_targ;
entity damage_inflictor;
entity damage_attacker;

void Damage (entity targ, entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float mirrordamage;
	float mirrorforce;
	float mirrorcomplain; //Complain anyway if mirrordamage is just virtual
	float teamdamage0;
	entity attacker_save;
	mirrordamage = 0;
	mirrorforce = 0;
	mirrorcomplain = 0;

	if (gameover || targ.killcount == -666)
		return;

	W_AutoEvaluatePipeTypeByDamage(deathtype); //Figure out what type of automatic pipe setting should be set, if applicable, for bullet hits on walls

	//Apply Vuln Effects (ignight on laser or beam hit, etc)
	DamageVulnEffects(targ, attacker, damage, deathtype);

	//Apply Resistances
	//print(ftos(damage), "before resist\n");
	damage = DamageSpecialCircumstances(targ, damage, deathtype, attacker); //Shackled player getting fall damage
	damage = DamageManaShield(targ, damage);
	damage = DamageResistance(targ, damage, deathtype);
	//print(etos(attacker), " :A - I: ", etos(inflictor),"\n");
        //print(ftos(damage), "after resist\n");
	
	if((targ.flags & FL_MONSTER) || (targ.flags & FL_CLIENT)) {
		damage = DamageGrace (targ, damage, deathtype, attacker);
		DamageVampyricConduit(targ, damage, deathtype, attacker);
		if (isPlayerOrMonsterByClassname(targ)) { //Make sure it's normal player or monster
			DamageDoMangleHobble(targ, damage, deathtype);
		}
		DamageDoMovementImpare(targ, damage, deathtype, attacker); //This checks if is vuln_movement_imparable in the function
		DamageDoDisorientate(targ, damage, deathtype, attacker); //This checks if is vuln_movement_imparable in the function

		if (damage > 0) {
			if (targ.prisonerlevel == 3) {
				targ.prisoner3_suffering = targ.prisoner3_suffering + damage; //resest at respawn
				targ.prisoner3_sufferingmemory = targ.prisoner3_sufferingmemory + (damage * 0.2); //doesn't get reset at respawn
				targ.prisoner3_sufferingmemory_lasttime = time;
				
				if (attacker != world) {
					if (DEATH_ISWEAPON(deathtype, WEP_SHACKLES)) {
						//Ignore
					} else if (DEATH_ISWEAPON(deathtype, WEP_HANDCUFFS)) {
						//Ignore
					} else if (damage > 2) {
						attacker.hasharmed_prisoner = attacker.hasharmed_prisoner + 0.1;
					}
				}
			} else if (targ.prisonerlevel == 2) {
				targ.prisoner2_suffering = targ.prisoner2_suffering + damage; //resest at respawn
				targ.prisoner2_sufferingmemory = targ.prisoner2_sufferingmemory + (damage * 0.2); //doesn't get reset at respawn
				targ.prisoner2_sufferingmemory_lasttime = time;
				
				if (attacker != world) {
					if (DEATH_ISWEAPON(deathtype, WEP_SHACKLES)) {
						//Ignore
					} else if (DEATH_ISWEAPON(deathtype, WEP_HANDCUFFS)) {
						//Ignore
					} else if (damage > 5) {
						attacker.hasharmed_prisoner = attacker.hasharmed_prisoner + 0.01;
					}
				}
			}
		}
	}
	targ.dmgmvmntimpare = 0;
	targ.dmgmvmntimparetime = 0;
	targ.dmgmvmntimparedthtyp = 0;
	targ.dmgmvmntimpareatkr = world;
	targ.dmgdisorientate = 0;
	targ.dmgdisorientatetime = 0;
	targ.dmgdisorientatedthtyp = 0;
	targ.dmgdisorientateatkr = world;

	entity oldself;
	oldself = self;
	self = targ;
        damage_targ = targ;
        damage_inflictor = inflictor;
        damage_attacker = attacker;
		attacker_save = attacker;

	if(targ.classname == "player")
		if(targ.hook)
			if(targ.hook.aiment)
				if(targ.hook.aiment == attacker)
					RemoveGrapplingHook(targ); // STOP THAT, you parasite!

	// special rule: gravity bomb does not hit team mates (other than for disconnecting the hook)
	if(DEATH_ISWEAPON(deathtype, WEP_HOOK) || DEATH_ISWEAPON(deathtype, WEP_TUBA))
	{
		if(targ.classname == "player")
			if not(IsDifferentTeam(targ, attacker))
			{
				self = oldself;
				return;
			}
	}
	
	//Apply health_stable_reduce if applicable. 
	//This perm removes health points
	//monster_blackdeath causes such
	if(attacker.damage_health_stable_reduce) {
		if(attacker.damage_health_stable_reduce > 0) {
			if (damage > 0) {
				targ.health_stable_reduce = targ.health_stable_reduce + attacker.damage_health_stable_reduce;
			}
		}
	}

	if(deathtype == DEATH_KILL || deathtype == DEATH_TEAMCHANGE || deathtype == DEATH_AUTOTEAMCHANGE || deathtype == DEATH_QUIET)
	{
		// These are ALWAYS lethal
		// No damage modification here
		// Instead, prepare the victim for his death...
		targ.armorvalue = 0;
		targ.spawnshieldtime = 0;
		targ.health = 0.9; // this is < 1
		targ.flags -= targ.flags & FL_GODMODE;
		damage = 100000;
	}
	else if(deathtype == DEATH_MIRRORDAMAGE || deathtype == DEATH_NOAMMO)
	{
		// no processing
	}
	else
	{
		/*
		skill based bot damage? gtfo. (tZork)
		if (targ.classname == "player")
		if (attacker.classname == "player")
		if (!targ.isbot)
		if (attacker.isbot)
			damage = damage * bound(0.1, (skill + 5) * 0.1, 1);
        */
        
		// nullify damage if teamplay is on
		if(deathtype != DEATH_TELEFRAG)
		if(attacker.classname == "player")
		{
			if(targ.classname == "player" && targ != attacker && (IS_INDEPENDENT_PLAYER(attacker) || IS_INDEPENDENT_PLAYER(targ)))
			{
				damage = 0;
				force = '0 0 0';
			}
			else if(!IsDifferentTeam(attacker, targ) && !(targ.classname == "bldhitbx"))
			{
				if(autocvar_teamplay_mode == 1)
					damage = 0;
				else if(attacker != targ)
				{
					if(autocvar_teamplay_mode == 3)
						damage = 0;
					else if(autocvar_teamplay_mode == 4)
					{
						if(targ.classname == "player" && targ.deadflag == DEAD_NO)
						{
							teamdamage0 = max(attacker.dmg_team, autocvar_g_teamdamage_threshold);
							attacker.dmg_team = attacker.dmg_team + damage;
							if(attacker.dmg_team > teamdamage0 && !g_ca)
								mirrordamage = autocvar_g_mirrordamage * (attacker.dmg_team - teamdamage0);
							mirrorforce = autocvar_g_mirrordamage * vlen(force);
							if(g_minstagib)
							{
								if(autocvar_g_friendlyfire == 0)
									damage = 0;
							}
							else if(g_ca)
								damage = 0;
							else
								damage = autocvar_g_friendlyfire * damage;
							// mirrordamage will be used LATER

							if(autocvar_g_mirrordamage_virtual)
							{
								vector v  = healtharmor_applydamage(attacker.armorvalue, autocvar_g_balance_armor_blockpercent, mirrordamage);
								attacker.dmg_take += v_x;
								attacker.dmg_save += v_y;
								attacker.dmg_inflictor = inflictor;
								mirrordamage = v_z; // = 0, to make fteqcc stfu
								mirrorforce = 0;
								mirrorcomplain = 1;
							}

							if(autocvar_g_friendlyfire_virtual)
							{
								vector v = healtharmor_applydamage(targ.armorvalue, autocvar_g_balance_armor_blockpercent, damage);
								targ.dmg_take += v_x;
								targ.dmg_save += v_y;
								targ.dmg_inflictor = inflictor;
								damage = 0;
								if(!autocvar_g_friendlyfire_virtual_force)
									force = '0 0 0';
							}
						}
						else
							damage = 0;
					}
				}
			}
		}
		
		if(g_colorwar) {
			if(autocvar_g_colorwar_nodamagetosame)
			if(attacker != world)
			if(clienttype(attacker) == CLIENTTYPE_REAL || clienttype(attacker) == CLIENTTYPE_BOT)
			if(clienttype(targ) == CLIENTTYPE_REAL || clienttype(targ) == CLIENTTYPE_BOT)
			{
				if(!teamplay)
				{	
					if (targ.clientcolors == attacker.clientcolors) {
						damage = 0;
					}
				}
			}
		}

		if(targ.classname == "player")
		if(attacker.classname == "player")
		if(attacker != targ)
		{
			targ.lms_traveled_distance = autocvar_g_lms_campcheck_distance;
			attacker.lms_traveled_distance = autocvar_g_lms_campcheck_distance;
		}

		if(targ.classname == "player")
		if (g_minstagib)
		{
			if ((deathtype == DEATH_FALL)  ||
				(deathtype == DEATH_DROWN) ||
				(deathtype == DEATH_SLIME) ||
				(deathtype == DEATH_LAVA)  ||
				(!DEATH_ISWEAPON(deathtype, WEP_LASER) && damage > 0 && damage < 100))
			{
				self = oldself;
				return;
			}
			if(damage > 0)
			    damage = 10000;
			if (targ.armorvalue && (deathtype == WEP_MINSTANEX) && damage)
			{
				targ.armorvalue -= 1;
				centerprint(targ, strcat("^3Remaining extra lives: ",ftos(targ.armorvalue)));
				damage = 0;
				targ.hitsound += 1;
				attacker.hitsound += 1; // TODO change this to a future specific hitsound for armor hit
			}
			if (DEATH_ISWEAPON(deathtype, WEP_LASER))
			{
				damage = 0;
				mirrordamage = 0;
				if (targ != attacker)
				{
					if ((targ.health >= 1) && (targ.classname == "player"))
						centerprint(attacker, "Secondary fire inflicts no damage!");
					force = '0 0 0';
					// keep mirrorforce
					attacker = targ;
				}
			}
		}

		if not(DEATH_ISSPECIAL(deathtype))
		{
			damage *= g_weapondamagefactor;
			mirrordamage *= g_weapondamagefactor;
			force = force * g_weaponforcefactor;
			mirrorforce *= g_weaponforcefactor;
		}
		
		if(targ.frozen == 1)
		{
			//frozen == 1 is ice (2 is paralysis)
			//ice protects to some degree
			if (deathtype == DEATH_ICE || damage < 30)
				damage = 0;
			else if (damage < 40)
				damage = 0.05;
			else if (damage < 50)
				damage = 0.1;
			else if (damage < 60)
				damage = 0.15;
			else if (damage < 70)
				damage = 0.2;
			else if (damage < 120)
				damage = 0.25;
			
			
			force *= 0.2;
		}
		
		if(targ.stoned)
		{
			if (DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER)
			|| DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER)
			|| DEATH_ISWEAPON(deathtype, WEP_MORTAR)
			|| DEATH_ISWEAPON(deathtype, WEP_HAGAR)
			|| DEATH_ISWEAPON(deathtype, WEP_SEEKER)
			|| DEATH_ISWEAPON(deathtype, WEP_MINE_LAYER)
			|| DEATH_ISWEAPON(deathtype, WEP_EXPLOSIVE_VEST)
			|| DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER)
			|| DEATH_ISWEAPON(deathtype, WEP_RPG7_LAUNCHER)
			|| DEATH_ISWEAPON(deathtype, WEP_RA4_LAUNCHER)
			|| DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR)
			|| DEATH_ISWEAPON(deathtype, WEP_HAGAR2)
			|| deathtype == DEATH_TURRET_FLAC
			|| deathtype == DEATH_TURRET_WALKER_ROCKET
			|| deathtype == DEATH_TURRET_HELLION
			|| deathtype == DEATH_TURRET_HK
			|| deathtype == DEATH_TURRET_MLRS
			|| deathtype == DEATH_TOUCHEXPLODE
			|| deathtype == DEATH_MONSTER_TARBABY_BLOWUP
			)
			{
				force *= 0.1;
				//Stone protects against all except explosives
				if (damage < 30)
					damage = 0;
				else if (damage < 40)
					damage = 0.05;
				else if (damage < 50)
					damage = 0.1;
				else if (damage < 60)
					damage = 0.15;
				else if (damage < 70)
					damage = 0.2;
				else if (damage < 120)
					damage = 0.25;
			} else {
				damage = 0;
				force *= 0;
			}
		}
		
		// should this be changed at all? If so, in what way?
		frag_attacker = attacker;
		frag_target = targ;
		frag_damage = damage;
		frag_force = force;
        frag_deathtype = deathtype;
		MUTATOR_CALLHOOK(PlayerDamage_Calculate);
		damage = frag_damage;
		force = frag_force;
		
		// apply strength multiplier
		if ((attacker.items & IT_STRENGTH) && !g_minstagib)
		{
			if(targ == attacker)
			{
				damage = damage * autocvar_g_balance_powerup_strength_selfdamage;
				force = force * autocvar_g_balance_powerup_strength_selfforce;
			}
			else
			{
				damage = damage * autocvar_g_balance_powerup_strength_damage;
				force = force * autocvar_g_balance_powerup_strength_force;
			}
		}

		// apply invincibility multiplier
		if (targ.items & IT_INVINCIBLE && !g_minstagib)
			damage = damage * autocvar_g_balance_powerup_invincible_takedamage;

		if (targ == attacker)
		{
			if(g_ca || (g_cts && !autocvar_g_cts_selfdamage))
				damage = 0;
			else
				damage = damage * autocvar_g_balance_selfdamagepercent;	// Partial damage if the attacker hits himself
		}

		if(g_runematch)
		{
			// apply strength rune
			if (attacker.runes & RUNE_STRENGTH)
			{
				if(attacker.runes & CURSE_WEAK) // have both curse & rune
				{
					damage = damage * autocvar_g_balance_rune_strength_combo_damage;
					force = force * autocvar_g_balance_rune_strength_combo_force;
				}
				else
				{
					damage = damage * autocvar_g_balance_rune_strength_damage;
					force = force * autocvar_g_balance_rune_strength_force;
				}
			}
			else if (attacker.runes & CURSE_WEAK)
			{
				damage = damage * autocvar_g_balance_curse_weak_damage;
				force = force * autocvar_g_balance_curse_weak_force;
			}

			// apply defense rune
			if (targ.runes & RUNE_DEFENSE)
			{
				if (targ.runes & CURSE_VULNER) // have both curse & rune
					damage = damage * autocvar_g_balance_rune_defense_combo_takedamage;
				else
					damage = damage * autocvar_g_balance_rune_defense_takedamage;
			}
			else if (targ.runes & CURSE_VULNER)
				damage = damage * autocvar_g_balance_curse_vulner_takedamage;
		}

		// count the damage
		if(attacker)
		if(!targ.deadflag)
		if(targ.takedamage == DAMAGE_AIM)
		if(targ != attacker)
		{
			//Start Adding coreshot (Heart, vitals, etc)
			if(damage_coreshotbonus)
			{
				//No zombies (their vitals don't work, headshot them)
				if(DamageDoesCoreshotByClassname(targ))
				{
					// CORE SHOT:
					// find height of hit on player axis
					// if above view_ofs and below maxs, and also in the middle half of the bbox, it is core shot
					vector coremins, coremaxs, org;
					org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(attacker));
					coremins = org + GetCoreshotMins(targ);
					coremaxs = org + GetCoreshotMaxs(targ);
					if(trace_hits_box(railgun_start, railgun_end, coremins, coremaxs))
					{
						deathtype |= HITTYPE_CORESHOT;
					}
				}
				
				if(deathtype & HITTYPE_CORESHOT)
					damage *= 1 + damage_coreshotbonus;
			}
			//End Adding coreshot (Heart, vitals, etc). Headshot is more important //so will override deathmessage hopefully

			if(damage_headshotbonus)
			{
				if(DamageDoesHeadshotByClassname(targ))
				{
					// HEAD SHOT:
					// find height of hit on player axis
					// if above view_ofs and below maxs, and also in the middle half of the bbox, it is head shot
					vector headmins, headmaxs, org;
					org = antilag_takebackorigin(targ, time - ANTILAG_LATENCY(attacker));
					headmins = org + GetHeadshotMins(targ);
					headmaxs = org + GetHeadshotMaxs(targ);
					if(trace_hits_box(railgun_start, railgun_end, headmins, headmaxs))
					{
						deathtype |= HITTYPE_HEADSHOT;
						targ.tempdisorientated = 1;
						targ.tempdisorientated_time = time + (5*60);
						if (!self.permblinded) {
							if (DamageTargIsNotWithinGrace(self)) {
								self.stat_blinded = 100;
								self.tempblinded_nexttime = time + 3;
								self.tempdisorientated_nexttime = time;
							}
						}
					}
				}
				else if(targ.classname == "turret_head")
				{
					deathtype |= HITTYPE_HEADSHOT;
				}
				if(deathtype & HITTYPE_HEADSHOT)
					if(damage_headshotbonus > 0)
						damage *= 1 + damage_headshotbonus;
			}

			entity victim;
			if((targ.vehicle_flags & VHF_ISVEHICLE) && targ.owner)
				victim = targ.owner;
			else
				victim = targ;

			if(victim.classname == "player" || victim.turrcaps_flags & TFL_TURRCAPS_ISTURRET || victim.flags & FL_MONSTER)
			{
				if(IsDifferentTeam(victim, attacker))
				{
					if(damage > 0)
					{
						if(deathtype != DEATH_FIRE)
						{
							if(victim.BUTTON_CHAT)
								attacker.typehitsound += 1;
							else
								attacker.hitsound += 1;
						}

						damage_goodhits += 1;
						damage_gooddamage += damage;

						if not(DEATH_ISSPECIAL(deathtype))
						{
							if(targ.classname == "player") // don't do this for vehicles
							if(!g_minstagib)
							if(IsFlying(victim))
								yoda = 1;

							if(g_minstagib)
							if(victim.items & IT_STRENGTH)
								yoda = 1;

							if(deathtype & HITTYPE_HEADSHOT)
								headshot = 1;
								
							if(deathtype & HITTYPE_CORESHOT)
								coreshot = 1;
						}
					}
				}
				else
				{
					if(deathtype != DEATH_FIRE)
					{
						attacker.typehitsound += 1;
					}
					if(mirrordamage > 0 || mirrorcomplain)
						if(time > attacker.teamkill_complain)
						if not(victim.stoned)
						if not(victim.frozen)
						{
							attacker.teamkill_complain = time + 5;
							attacker.teamkill_soundtime = time + 0.4;
							attacker.teamkill_soundsource = targ;
						}
				}
			}
		}
	}

	// apply push
	if (self.damageforcescale)
	if (vlen(force))
	if (self.classname != "player" || time >= self.spawnshieldtime || g_midair)
	{
		vector farce = damage_explosion_calcpush(self.damageforcescale * force, self.velocity, autocvar_g_balance_damagepush_speedfactor);
		if(self.movetype == MOVETYPE_PHYSICS)
		{
			entity farcent;
			farcent = spawn();
			farcent.classname = "farce";
			farcent.enemy = self;
			farcent.movedir = farce * 10;
			if(self.mass)
				farcent.movedir = farcent.movedir * self.mass;
			farcent.origin = hitloc;
			farcent.forcetype = FORCETYPE_FORCEATPOS;
			farcent.nextthink = time + 0.1;
			farcent.think = SUB_Remove;
		}
		else
			self.velocity = self.velocity + farce;
		self.flags &~= FL_ONGROUND;
		UpdateCSQCProjectile(self);
	}
	// apply damage
	if (damage != 0 || (self.damageforcescale && vlen(force)))
	if (self.event_damage)
		self.event_damage (inflictor, attacker, damage, deathtype, hitloc, force);
	self = oldself;

	if(targ.classname == "player" && attacker.classname == "player" && attacker != targ && attacker.health > 2)
	{
		if(g_runematch)
		{
			if (attacker.runes & RUNE_VAMPIRE)
			{
			// apply vampire rune
				if (attacker.runes & CURSE_EMPATHY) // have the curse too
				{
					//attacker.health = attacker.health + damage * autocvar_g_balance_rune_vampire_combo_absorb;
					attacker.health = bound(
						autocvar_g_balance_curse_empathy_minhealth, // LA: was 3, now 40
						attacker.health + damage * autocvar_g_balance_rune_vampire_combo_absorb,
						autocvar_g_balance_rune_vampire_maxhealth);	// LA: was 1000, now 500
				}
				else
				{
					//attacker.health = attacker.health + damage * autocvar_g_balance_rune_vampire_absorb;
					attacker.health = bound(
						attacker.health,	// LA: was 3, but changed so that you can't lose health
											// empathy won't let you gain health in the same way...
						attacker.health + damage * autocvar_g_balance_rune_vampire_absorb,
						autocvar_g_balance_rune_vampire_maxhealth);	// LA: was 1000, now 500
					}
			}
			// apply empathy curse
			else if (attacker.runes & CURSE_EMPATHY)
			{
				attacker.health = bound(
					autocvar_g_balance_curse_empathy_minhealth, // LA: was 3, now 20
					attacker.health + damage * autocvar_g_balance_curse_empathy_takedamage,
					attacker.health);
			}
		}
	}

	// apply mirror damage if any
	if(mirrordamage > 0 || mirrorforce > 0)
	{
		attacker = attacker_save;
		if(g_minstagib)
		if(mirrordamage > 0)
		{
			// just lose extra LIVES, don't kill the player for mirror damage
			if(attacker.armorvalue > 0)
			{
				attacker.armorvalue = attacker.armorvalue - 1;
				centerprint(attacker, strcat("^3Remaining extra lives: ",ftos(attacker.armorvalue)));
				attacker.hitsound += 1;
			}
			mirrordamage = 0;
		}

		force = normalize(attacker.origin + attacker.view_ofs - hitloc) * mirrorforce;
		Damage(attacker, inflictor, attacker, mirrordamage, DEATH_MIRRORDAMAGE, attacker.origin, force);
	}
}

float RadiusDamage_running;
float RadiusDamage (entity inflictor, entity attacker, float coredamage, float edgedamage, float rad, entity ignore, float forceintensity, float deathtype, entity directhitentity)
	// Returns total damage applies to creatures
{
	entity	targ;
	vector	blastorigin;
	vector	force;
	float   total_damage_to_creatures;
	entity  next;
	float   tfloordmg;
	float   tfloorforce;
	
	vector savedforce; //Used to save the force for the damageinfo cosmetics later in the function

	float stat_damagedone;

	if(RadiusDamage_running)
	{
		backtrace("RadiusDamage called recursively! Expect stuff to go HORRIBLY wrong.");
		return 0;
	}

	RadiusDamage_running = 1;

	tfloordmg = autocvar_g_throughfloor_damage;
	tfloorforce = autocvar_g_throughfloor_force;

	blastorigin = (inflictor.origin + (inflictor.mins + inflictor.maxs) * 0.5);
	total_damage_to_creatures = 0;

	savedforce = '0 0 0';
	if(deathtype != (WEP_HOOK | HITTYPE_SECONDARY | HITTYPE_BOUNCE)) // only send gravity bomb damage once
		if(DEATH_WEAPONOF(deathtype) != WEP_TUBA) // do not send tuba damage (bandwidth hog)
		{
			force = inflictor.velocity;
			if(vlen(force) == 0)
				force = '0 0 -1';
			else
				force = normalize(force);
			
			if (DEATH_ISWEAPON(deathtype, WEP_CALTROP) || DEATH_ISWEAPON(deathtype, WEP_CROSSBOWDTWR) || DEATH_ISWEAPON(deathtype, WEP_CRUDEBOW) || DEATH_ISWEAPON(deathtype, WEP_COMPOSITEBOW) || DEATH_ISWEAPON(deathtype, WEP_LONGBOW) || DEATH_ISWEAPON(deathtype, WEP_YUMIBOW) || DEATH_ISWEAPON(deathtype, WEP_LIGHTCROSSBOW))
			{
				savedforce = force;
				//The DamageInfo stuff has been Moved to below
				//where we'll know the species of the target
			} else {
				if(forceintensity >= 0)
					Damage_DamageInfo(blastorigin, coredamage, edgedamage, rad, forceintensity * savedforce, deathtype, 0, attacker);
				else
					Damage_DamageInfo(blastorigin, coredamage, edgedamage, -rad, (-forceintensity) * savedforce, deathtype, 0, attacker);
			
				savedforce = '0 0 0'; //Explosives don't need the species DamageInfo codeblock below, disable
			}
		}

	stat_damagedone = 0;

	targ = WarpZone_FindRadius (blastorigin, rad + MAX_DAMAGEEXTRARADIUS, FALSE);
	while (targ)
	{
		next = targ.chain;
		if (targ != inflictor)
			if (ignore != targ) if(targ.takedamage)
			{
				vector nearest;
				vector diff;
				float power;

				// LordHavoc: measure distance to nearest point on target (not origin)
				// (this guarentees 100% damage on a touch impact)
				nearest = targ.WarpZone_findradius_nearest;
				diff = targ.WarpZone_findradius_dist;
				// round up a little on the damage to ensure full damage on impacts
				// and turn the distance into a fraction of the radius
				power = 1 - ((vlen (diff) - bound(MIN_DAMAGEEXTRARADIUS, targ.damageextraradius, MAX_DAMAGEEXTRARADIUS)) / rad);
				//bprint(" ");
				//bprint(ftos(power));
				//if (targ == attacker)
				//	print(ftos(power), "\n");
				if (power > 0)
				{
					float finaldmg;
					if (power > 1)
						power = 1;
					finaldmg = coredamage * power + edgedamage * (1 - power);
					if (finaldmg > 0)
					{
						float a;
						float c;
						vector hitloc;
						vector myblastorigin;
						vector center;

						myblastorigin = WarpZone_TransformOrigin(targ, blastorigin);

						// if it's a player, use the view origin as reference
						center = CENTER_OR_VIEWOFS(targ);

						force = normalize(center - myblastorigin);
						force = force * (finaldmg / coredamage) * forceintensity;
						hitloc = nearest;

						if(targ != directhitentity)
						{
							float hits;
							float total;
							float hitratio;
							float mininv_f, mininv_d;

							// test line of sight to multiple positions on box,
							// and do damage if any of them hit
							hits = 0;

							// we know: max stddev of hitratio = 1 / (2 * sqrt(n))
							// so for a given max stddev:
							// n = (1 / (2 * max stddev of hitratio))^2

							mininv_d = (finaldmg * (1-tfloordmg)) / autocvar_g_throughfloor_damage_max_stddev;
							mininv_f = (vlen(force) * (1-tfloorforce)) / autocvar_g_throughfloor_force_max_stddev;

							if(autocvar_g_throughfloor_debug)
								print(sprintf("THROUGHFLOOR: D=%f F=%f max(dD)=1/%f max(dF)=1/%f", finaldmg, vlen(force), mininv_d, mininv_f));

							total = 0.25 * pow(max(mininv_f, mininv_d), 2);

							if(autocvar_g_throughfloor_debug)
								print(sprintf(" steps=%f", total));

							if (targ.classname == "player")
								total = ceil(bound(autocvar_g_throughfloor_min_steps_player, total, autocvar_g_throughfloor_max_steps_player));
							else
								total = ceil(bound(autocvar_g_throughfloor_min_steps_other, total, autocvar_g_throughfloor_max_steps_other));

							if(autocvar_g_throughfloor_debug)
								print(sprintf(" steps=%f dD=%f dF=%f", total, finaldmg * (1-tfloordmg) / (2 * sqrt(total)), vlen(force) * (1-tfloorforce) / (2 * sqrt(total))));

							for(c = 0; c < total; ++c)
							{
								//traceline(targ.WarpZone_findradius_findorigin, nearest, MOVE_NOMONSTERS, inflictor);
								WarpZone_TraceLine(blastorigin, WarpZone_UnTransformOrigin(targ, nearest), MOVE_NOMONSTERS, inflictor);
								if (trace_fraction == 1 || trace_ent == targ)
								{
									++hits;
									if (hits > 1)
										hitloc = hitloc + nearest;
									else
										hitloc = nearest;
								}
								nearest_x = targ.origin_x + targ.mins_x + random() * targ.size_x;
								nearest_y = targ.origin_y + targ.mins_y + random() * targ.size_y;
								nearest_z = targ.origin_z + targ.mins_z + random() * targ.size_z;
							}

							nearest = hitloc * (1 / max(1, hits));
							hitratio = (hits / total);
							a = bound(0, tfloordmg + (1-tfloordmg) * hitratio, 1);
							finaldmg = finaldmg * a;
							a = bound(0, tfloorforce + (1-tfloorforce) * hitratio, 1);
							force = force * a;

							if(autocvar_g_throughfloor_debug)
								print(sprintf(" D=%f F=%f\n", finaldmg, vlen(force)));
						}

						// laser force adjustments :P
						if(DEATH_WEAPONOF(deathtype) == WEP_LASER)
						{
							if (targ == attacker)
							{
								vector vel;

								float force_zscale;
								float force_velocitybiasramp;
								float force_velocitybias;

								force_velocitybiasramp = autocvar_sv_maxspeed;
								if(deathtype & HITTYPE_SECONDARY)
								{
									force_zscale = autocvar_g_balance_laser_secondary_force_zscale;
									force_velocitybias = autocvar_g_balance_laser_secondary_force_velocitybias;
								}
								else
								{
									force_zscale = autocvar_g_balance_laser_primary_force_zscale;
									force_velocitybias = autocvar_g_balance_laser_primary_force_velocitybias;
								}

								vel = targ.velocity;
								vel_z = 0;
								vel = normalize(vel) * bound(0, vlen(vel) / force_velocitybiasramp, 1) * force_velocitybias;
								force =
									vlen(force)
									*
									normalize(normalize(force) + vel);

								force_z *= force_zscale;
							}
							else
							{
								if(deathtype & HITTYPE_SECONDARY)
								{
									force *= autocvar_g_balance_laser_secondary_force_other_scale;
								}
								else
								{
									force *= autocvar_g_balance_laser_primary_force_other_scale;
								}
							}
						}

						//if (targ == attacker)
						//{
						//	print("hits ", ftos(hits), " / ", ftos(total));
						//	print(" finaldmg ", ftos(finaldmg), " force ", vtos(force));
						//	print(" (", ftos(a), ")\n");
						//}
						if(finaldmg || vlen(force))
						{
							if(targ.iscreature)
							{
								total_damage_to_creatures += finaldmg;

								if(accuracy_isgooddamage(attacker, targ))
									stat_damagedone += finaldmg;
							}

							if(targ == directhitentity || DEATH_ISSPECIAL(deathtype))
								Damage (targ, inflictor, attacker, finaldmg, deathtype, nearest, force);
							else
								Damage (targ, inflictor, attacker, finaldmg, deathtype | HITTYPE_SPLASH, nearest, force);
						
							//Moved to here so we can find the species.
							if(savedforce != '0 0 0') {	
								if((!targ.iscreature && DEATH_ISWEAPON(deathtype, WEP_CALTROP)) || targ.stoned)
								{
									//print("no creature, no caltrop blood\n");
									//If the target is not a creature, and the 
									//deathtype is caltrops, we won't send the
									//cosmetic damageinfo. This way robot and
									//alien players won't have red blood on 
									//their feet.
									//If the target has been turned to stone
									//we won't have it bleed.
								}
								else
								{
									if(forceintensity >= 0)
										Damage_DamageInfo(blastorigin, coredamage, edgedamage, rad, forceintensity * savedforce, deathtype, targ.species, attacker);
									else
										Damage_DamageInfo(blastorigin, coredamage, edgedamage, -rad, (-forceintensity) * savedforce, deathtype, targ.species, attacker);
								}
								savedforce = '0 0 0'; //So we only do it once.
							}
							//
						}
					}
				}
			}
		targ = next;
	}

	RadiusDamage_running = 0;

	if(!DEATH_ISSPECIAL(deathtype))
		accuracy_add(attacker, DEATH_WEAPONOFWEAPONDEATH(deathtype), 0, min(coredamage, stat_damagedone));

	return total_damage_to_creatures;
}

.float fire_damagepersec;
.float fire_endtime;
.float fire_deathtype;
.float fire_intensity;
.float fire_burnamt;
.float fire_nextspread;
.float fire_spreadradius;
.float fire_nextpartcheck;
.float fire_oilfirespreadfailed;
.entity fire_owner;
.float fire_hitsound;
.entity fire_burner;
.float fire_nextraincheck;

void fireburner_think();
float multitool_iswooden(float mytype);
.entity multitool_hitbox;
void OilFire_spawnoilburnermaybe (entity myself);

float Fire_IsBurning(entity e)
{
	return (time < e.fire_endtime);
}

float Fire_AddDamage(entity e, entity o, float d, float t, float dt)
{
	float dps;
	float maxtime, mintime, maxdamage, mindamage, maxdps, mindps, totaldamage, totaltime;

	if(e.classname == "player")
	{
		if(e.deadflag)
			return -1;
	} else if (e.buff_wont_ignite) {
		return -1;
	}
	else
	{
		if (e.fire_burnamt >= autocvar_g_spawnfoliagearound_fire_burnmax)
		if (e.classname == "tree" || e.classname == "bush")
		{
			return -1;
		}
		
		if (e.classname == "building" || e.classname == "bldhitbx")
		if not(multitool_iswooden(e.count) || (e.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) )
		{
			//print(e.classname, " Not wooden, won't burn\n");
			return -1;
		}
				
		if (e.classname == "building" && (!e.abdbldcanburn)) {
			//Fwd damage to hitbox instead, at reduced rate
			//We only get here if building was determined to be wooden
			if (!e.multitool_hitbox.fire_burner) {
				//print("no fireburner yet, will forward\n");
				if ((e.multitool_hitbox) && (e.multitool_hitbox != world)) {
					Fire_AddDamage(e.multitool_hitbox, o, (d*0.2), (t*0.5), dt); // 1/5th damage for 1/2 the time
				}
			}
			return -1;
		}
		
		
		if(!e.fire_burner)
		{
			// print("adding a fire burner to ", e.classname, "\n");
			e.fire_burner = spawn();
			e.fire_burner.classname = "fireburner";
			e.fire_burner.think = fireburner_think;
			e.fire_burner.nextthink = time;
			e.fire_burner.owner = e;
			e.fire_intensity = 0;
			e.fire_nextspread = 0;
			e.fire_nextpartcheck = 0;
			
			if (e.classname == "tree" || e.classname == "bush" || (e.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (e.classname == "bldhitbx" && multitool_iswooden(e.count)))
			{
				//For now this is just for things like trees etc
				//If it hasn't been burnt much, heals
				if (e.fire_burnamt < 10)
				{
					e.fire_burnamt = 0;
				}
			} else {
				e.fire_burnamt = 0;
			}
		} else {
			if (e.classname == "tree" || e.classname == "bush" || (e.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (e.classname == "bldhitbx" && multitool_iswooden(e.count))) {
				e.fire_intensity += 1;
				e.fire_burnamt += 1;
				e.fire_nextpartcheck = time + 2;
				e.fire_nextspread = time + autocvar_g_spawnfoliagearound_fire_spreadtime + (autocvar_g_spawnfoliagearound_fire_spreadtime_jitter * random());
				e.fire_endtime = e.fire_endtime + autocvar_g_spawnfoliagearound_fire_spreadtime + 0.1;
				//So we don't go out if a firestorm is around us
				//print(sprintf("Shit just got more intense: %f\n", e.fire_intensity));
			}
		}
	}
	
	if(e.fire_oilfire_entwasinoil) {
		//If we're covered in oil and get set on fire, it doesn't go out forever in oil
		//Player will have to bathe in water or slime
		e.fire_oilfire_entreignite = 1;
		e.fire_oilfire_entreignite_owner = o;
	}

	t = max(t, 0.1);
	dps = d / t;
	if(Fire_IsBurning(e))
	{
		mintime = e.fire_endtime - time;
		maxtime = max(mintime, t);

		mindps = e.fire_damagepersec;
		maxdps = max(mindps, dps);

		if(maxtime > mintime || maxdps > mindps)
		{
			// Constraints:
			
			// damage we have right now
			mindamage = mindps * mintime;

			// damage we want to get
			maxdamage = mindamage + d;

			// but we can't exceed maxtime * maxdps!
			totaldamage = min(maxdamage, maxtime * maxdps);

			// LEMMA:
			// Look at:
			// totaldamage = min(mindamage + d, maxtime * maxdps)
			// We see:
			// totaldamage <= maxtime * maxdps
			// ==> totaldamage / maxdps <= maxtime.
			// We also see:
			// totaldamage / mindps = min(mindamage / mindps + d, maxtime * maxdps / mindps)
			//                     >= min(mintime, maxtime)
			// ==> totaldamage / maxdps >= mintime.

			/*
			// how long do we damage then?
			// at least as long as before
			// but, never exceed maxdps
			totaltime = max(mintime, totaldamage / maxdps); // always <= maxtime due to lemma
			*/

			// alternate:
			// at most as long as maximum allowed
			// but, never below mindps
			totaltime = min(maxtime, totaldamage / mindps); // always >= mintime due to lemma

			// assuming t > mintime, dps > mindps:
			// we get d = t * dps = maxtime * maxdps
			// totaldamage = min(maxdamage, maxtime * maxdps) = min(... + d, maxtime * maxdps) = maxtime * maxdps
			// totaldamage / maxdps = maxtime
			// totaldamage / mindps > totaldamage / maxdps = maxtime
			// FROM THIS:
			// a) totaltime = max(mintime, maxtime) = maxtime
			// b) totaltime = min(maxtime, totaldamage / maxdps) = maxtime

			// assuming t <= mintime:
			// we get maxtime = mintime
			// a) totaltime = max(mintime, ...) >= mintime, also totaltime <= maxtime by the lemma, therefore totaltime = mintime = maxtime
			// b) totaltime = min(maxtime, ...) <= maxtime, also totaltime >= mintime by the lemma, therefore totaltime = mintime = maxtime

			// assuming dps <= mindps:
			// we get mindps = maxdps.
			// With this, the lemma says that mintime <= totaldamage / mindps = totaldamage / maxdps <= maxtime.
			// a) totaltime = max(mintime, totaldamage / maxdps) = totaldamage / maxdps
			// b) totaltime = min(maxtime, totaldamage / mindps) = totaldamage / maxdps

			e.fire_damagepersec = totaldamage / totaltime;
			e.fire_endtime = time + totaltime;
			if(totaldamage > 1.2 * mindamage)
			{
				e.fire_deathtype = dt;
				if(e.fire_owner != o)
				{
					e.fire_owner = o;
					e.fire_hitsound = FALSE;
				}
			}
			if(accuracy_isgooddamage(o, e))
				accuracy_add(o, DEATH_WEAPONOFWEAPONDEATH(dt), 0, max(0, totaldamage - mindamage));
			return max(0, totaldamage - mindamage); // can never be negative, but to make sure
		}
		else
			return 0;
	}
	else
	{
		e.fire_damagepersec = dps;
		e.fire_endtime = time + t;
		e.fire_deathtype = dt;
		e.fire_owner = o;
		e.fire_hitsound = FALSE;
		if(accuracy_isgooddamage(o, e))
			accuracy_add(o, DEATH_WEAPONOFWEAPONDEATH(dt), 0, d);
		return d;
	}
}

void Fire_ApplyDamage(entity e)
{
	float t, d, hi, ty;
	entity o;

	if not(Fire_IsBurning(e))
		return;

	for(t = 0, o = e.owner; o.owner && t < 16; o = o.owner, ++t);
	if(clienttype(o) == CLIENTTYPE_NOTACLIENT)
		o = e.fire_owner;

	// water and slime stop fire
	if(e.waterlevel)
	if(e.watertype != CONTENT_LAVA)
		e.fire_endtime = 0;

	// ice stops fire
	if(e.freezetag_frozen || e.frozen == 1) //frozen == 2 is paralyze, not ice
		e.fire_endtime = 0;
		
	// dead monster stops fire soon
	if(e.flags & FL_MONSTER)
	if(e.health <= 0)
	{
		//print("monster\n");
		e.fire_endtime = 0;
	}
	
	//check if in rain or snow
	if (existantfuncrainsnow > 0) {
		if (e.fire_endtime) {
		if (e.fire_endtime > time) {
		if (time > e.fire_nextraincheck) {
			e.fire_nextraincheck = time + 5 + (random()*2);
			
			
			local float myraincheck;
			myraincheck = CheckIfEntityIsInRainAdv(e, MOVE_WORLDONLY);
			
			//print(ftos(myraincheck),"_checking rain in fire\n");
			
			if (myraincheck) {
				if (myraincheck >= 90) {
					e.fire_endtime = e.fire_endtime * 0.0125;
				} else if (myraincheck >= 85) {
					e.fire_endtime = e.fire_endtime * 0.025;
				} else if (myraincheck >= 80) {
					e.fire_endtime = e.fire_endtime * 0.05;
				} else if (myraincheck >= 75) {
					e.fire_endtime = e.fire_endtime * 0.10;
				} else if (myraincheck >= 70) {
					e.fire_endtime = e.fire_endtime * 0.15;
				} else if (myraincheck >= 65) {
					e.fire_endtime = e.fire_endtime * 0.20;
				} else if (myraincheck >= 60) {
					e.fire_endtime = e.fire_endtime * 0.25;
				} else if (myraincheck >= 55) {
					e.fire_endtime = e.fire_endtime * 0.30;
				} else if (myraincheck >= 50) {
					e.fire_endtime = e.fire_endtime * 0.35;
				} else if (myraincheck >= 45) {
					e.fire_endtime = e.fire_endtime * 0.40;
				} else if (myraincheck >= 40) {
					e.fire_endtime = e.fire_endtime * 0.45;
				} else if (myraincheck >= 35) {
					e.fire_endtime = e.fire_endtime * 0.5;
				} else if (myraincheck >= 30) {
					e.fire_endtime = e.fire_endtime * 0.55;
				} else if (myraincheck >= 25) {
					e.fire_endtime = e.fire_endtime * 0.6;
				} else if (myraincheck >= 20) {
					e.fire_endtime = e.fire_endtime * 0.65;
				} else if (myraincheck >= 15) {
					e.fire_endtime = e.fire_endtime * 0.75;
				} else if (myraincheck >= 10) {
					e.fire_endtime = e.fire_endtime * 0.85;
				} else if (myraincheck >= 5) {
					e.fire_endtime = e.fire_endtime * 0.9;
				} else if (myraincheck >= 3) {
					e.fire_endtime = e.fire_endtime * 0.95;
				}
			}
		}
		}
		}
	}

	t = min(frametime, e.fire_endtime - time);
	d = e.fire_damagepersec * t;

	hi = e.fire_owner.hitsound;
	ty = e.fire_owner.typehitsound;
	Damage(e, e, e.fire_owner, d, e.fire_deathtype, e.origin, '0 0 0');
	if(e.fire_hitsound && e.fire_owner)
	{
		e.fire_owner.hitsound = hi;
		e.fire_owner.typehitsound = ty;
	}
	e.fire_hitsound = TRUE;

	if not(IS_INDEPENDENT_PLAYER(e))
	FOR_EACH_PLAYER(other) if(e != other)
	{
		if(other.classname == "player")
		if(other.deadflag == DEAD_NO)
		if not(IS_INDEPENDENT_PLAYER(other))
		if(boxesoverlap(e.absmin, e.absmax, other.absmin, other.absmax))
		{
			t = autocvar_g_balance_firetransfer_time * (e.fire_endtime - time);
			d = autocvar_g_balance_firetransfer_damage * e.fire_damagepersec * t;
			if (Fire_AddDamage(other, o, d, t, DEATH_FIRE) != -1) {
				if (e.fire_oilfire_addsentreignite == 1) {
					other.fire_oilfire_entreignite = 1;
					other.fire_oilfire_entreignite_owner = o;
					//print("Reignite added\n");
				}
			}
		}
	}
	
	OilFire_spawnoilburnermaybe(e); //If there is an oil ocean, spread fires if in vapour area
	
	if (e.fire_intensity > 0)
	if (e.fire_nextspread < time)
	{
		e.fire_nextspread = time + autocvar_g_spawnfoliagearound_fire_spreadtime + (autocvar_g_spawnfoliagearound_fire_spreadtime_jitter * random());
		
		local entity eburn;
		
		if (e.classname == "bldhitbx") {
			local float faddmax;
			if (e.owner && e.owner != world) {
				faddmax = e.owner.maxs_x;
			} else {
				faddmax = e.maxs_x;
			}
			eburn = findradius(e.origin, bound(0,(autocvar_g_spawnfoliagearound_fire_spreadradius + faddmax + e.fire_intensity * 1.5), autocvar_g_spawnfoliagearound_fire_spreadmax));
		} else {
			eburn = findradius(e.origin, bound(0,(autocvar_g_spawnfoliagearound_fire_spreadradius + e.fire_intensity * 1.5), autocvar_g_spawnfoliagearound_fire_spreadmax));
		}
		
		while(eburn)
		{
			if (eburn.classname == "tree" || eburn.classname == "bush" || (e.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)))
			{
				t = autocvar_g_balance_firetransfer_time * (e.fire_endtime - time);
				d = autocvar_g_balance_firetransfer_damage * e.fire_damagepersec * t;
				Fire_AddDamage(eburn, o, d, t, DEATH_FIRE);
				//print("spreading\n");
			}
			else if (eburn.flags & (FL_ITEM | FL_WEAPON | FL_POWERUP))
			{
				if (time > eburn.nextthink) {
				//See if it has been pickedup/deactivated allready
					if(eburn.items & IT_ROCKETS)
					{	
						//print("rockets\n");
						RadiusDamage (eburn, e.fire_owner, autocvar_g_balance_rocketlauncher_damage, autocvar_g_balance_rocketlauncher_edgedamage, autocvar_g_balance_rocketlauncher_radius * 1.5, world, autocvar_g_balance_rocketlauncher_force, WEP_ROCKET_LAUNCHER, other);
					
						if (autocvar_g_balance_rocketlauncher_enableshockwave == 1) {
							//modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, eburn.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rocketlauncher_radius * 1.5, 0.95, 0.05, 0.25);
							modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, eburn.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rocketlauncher_radius * 1.5, 0.95, 0.05, 0.25);
							modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, eburn.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_rocketlauncher_radius * 1.5, 0.4, 1, 1.0);
						}
						
						pointparticles(particleeffectnum("explosion_medium"), eburn.origin, '0 0 0', 1);
						sound(eburn, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);

						Item_ScheduleRespawnVar(eburn, 10);
					}
					else if ((eburn.items & IT_FUEL) || (eburn.items & IT_FUEL_REGEN) || (eburn.items & IT_JETPACK))
					{
						//print("fuel\n");
						RadiusDamage (eburn, e.fire_owner, autocvar_g_balance_grenadelauncher_primary_damage, autocvar_g_balance_grenadelauncher_primary_edgedamage, autocvar_g_balance_grenadelauncher_primary_radius * 1.5, world, autocvar_g_balance_grenadelauncher_primary_force, WEP_GRENADE_LAUNCHER, other);

						pointparticles(particleeffectnum("explosion_medium"), eburn.origin, '0 0 0', 1);
						sound(eburn, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
					
						Item_ScheduleRespawnVar(eburn, bound(10, e.fire_intensity * 0.1, 100));
					}
					else if (eburn.items & (IT_SHELLS
					| IT_CELLS | IT_NAILS | IT_5HP
					| IT_25HP |IT_HEALTH | IT_INVINCIBLE
					| IT_STRENGTH |IT_UNLIMITED_AMMO
					| IT_UNLIMITED_WEAPON_AMMO
					| IT_UNLIMITED_SUPERWEAPONS | IT_MISCITEM)
					)
					{
						//print("health and such\n");
						Item_ScheduleRespawnVar(eburn, bound(120, e.fire_intensity, 1024));
					} else {
						//print("otherstuff\n");
						
						RadiusDamage (eburn, e.fire_owner, autocvar_g_balance_grenadelauncher_primary_damage, autocvar_g_balance_grenadelauncher_primary_edgedamage, autocvar_g_balance_grenadelauncher_primary_radius * 0.5, world, autocvar_g_balance_grenadelauncher_primary_force, WEP_GRENADE_LAUNCHER, other);

						pointparticles(particleeffectnum("rocket_explosion"), eburn.origin, '0 0 0', 1);
						sound(eburn, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
						
						Item_ScheduleRespawnVar(eburn, bound(120, e.fire_intensity, 1024));
					}
				}
			}
			
			eburn = eburn.chain;
		}
		
		eburn = findradius(e.origin, bound(0,(autocvar_g_spawnfoliagearound_fire_spreadradius + e.fire_intensity * 1.5)  * 0.5, autocvar_g_spawnfoliagearound_fire_spreadmax));
		while(eburn)
		{
			if (
			((eburn.classname == "player" && eburn.health > 0) && (eburn.deadflag == DEAD_NO))
			|| ((eburn.flags & FL_MONSTER) && (eburn.health > 0))
			)
			{
				t = autocvar_g_balance_firetransfer_time * (e.fire_endtime - time);
				d = autocvar_g_balance_firetransfer_damage * e.fire_damagepersec * t;
				Fire_AddDamage(eburn, o, d, t, DEATH_FIRE);
			}
			
			eburn = eburn.chain;
		}
		
		if (e.fire_intensity > 20)
		{
			eburn = findradius(e.origin, bound(0,(autocvar_g_spawnfoliagearound_fire_spreadradius + e.fire_intensity * 1.5) * 0.25, autocvar_g_spawnfoliagearound_fire_spreadmax));
			while(eburn)
			{
				if (eburn != world)
				if not(eburn.classname == "player")
				if not((eburn.classname == "player" && eburn.health > 0) && (eburn.deadflag == DEAD_NO))
				if (eburn.solid != SOLID_NOT)
				if (eburn.solid != SOLID_TRIGGER)
				{
					t = autocvar_g_balance_firetransfer_time * (e.fire_endtime - time);
					d = autocvar_g_balance_firetransfer_damage * e.fire_damagepersec * t;
					Fire_AddDamage(eburn, o, d, t, DEATH_FIRE);
				}
				
				eburn = eburn.chain;
			}	
		}
	}
}

void Fire_ApplyEffect_Blacken(entity e)
{
	//used in Fire_ApplyEffect//
				if ((e.colormod != '-2 -2 -2')
				&& !(e.colormod))
				{
					e.colormod = '0.99 0.99 0.99';
					//print("first darken\n");
				
					//These models have black skins available, use them
				
					if ( strstrofs(e.model, "beechtree", 0) != -1 ) {
						e.skin = 9;
					} else if ( strstrofs(e.model, "quercustree", 0) != -1 ) {
						e.skin = 9;
					} else if ( strstrofs(e.model, "oldoaktree", 0) != -1 ) {
						e.skin = 9;
					} else if ( strstrofs(e.model, "epinetree", 0) != -1 ) {
						e.skin = 2;
					} else if ( strstrofs(e.model, "iftree", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "eucatree", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "jubpalmtree", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "cedartree", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "swamptree", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "dyp_bush", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "bna_bush", 0) != -1 ) {
						e.skin = 1;
					} else if ( strstrofs(e.model, "grassyarea", 0) != -1 ) {
						//Note for later:
						//If use different textures/skins
						//for different type of foliage later
						//make sure to test .skin range
						//to set proper burnt skin
						e.skin = 1;
					} else {
						e.colormod = '-2 -2 -2';
						//The foliage is very burnt, so make it black
					}
				}
				else if ((e.colormod != '-2 -2 -2') && (e.colormod != '0.01 0.01 0.01'))
				{
					e.colormod = e.colormod + '-0.01 -0.01 -0.01';
					//print("darken more\n");
					//Darken it abit.
				}
}

void Fire_ApplyEffect(entity e)
{
	if(Fire_IsBurning(e))
	{
		e.effects |= EF_FLAME;

		if (e.fire_nextpartcheck)
		if (e.fire_nextpartcheck < time)
		if (e.fire_intensity > 5)
		{
			e.effects &~= EF_FLAME; //Using something else so disable
			
			if (e.fire_intensity > 30)
			{
				//Change to burnt skin, or make black
				Fire_ApplyEffect_Blacken(e);
			}
			
			if (e.classname == "tree"
			&& e.fire_intensity < 20 && e.scale > 8)
			{
				//Dont bother, won't beable to see it.
				//Tree too fat, fire too small
			}
			else
			{
				if (e.fire_intensity > 40) {
					pointparticles(particleeffectnum("EF_IMMENSEFLAME"), e.origin, '0 0 0', 2);
				} else if (e.fire_intensity > 20) {
					pointparticles(particleeffectnum("EF_HUGEFLAME"), e.origin, '0 0 0', 2);
				} else if (e.fire_intensity > 10) {
					pointparticles(particleeffectnum("EF_LARGEFLAME"), e.origin, '0 0 0', 2);
				} else {
					//Greater than 5
					pointparticles(particleeffectnum("EF_BIGFLAME"), e.origin, '0 0 0', 2);
				}
			}
			
			e.fire_nextpartcheck = time + 2;
			
			if (e.fire_burnamt >= autocvar_g_spawnfoliagearound_fire_burnmax)
			{
				//If we're all burnt out, we end
				e.fire_endtime = 0;
			}
		}
	}
	else
	{
		e.effects &~= EF_FLAME;
		e.fire_intensity = 0;
		e.fire_nextspread = 0;
	}
}

void fireburner_think()
{
	// for players, this is done in the regular loop
	if(wasfreed(self.owner))
	{
		remove(self);
		return;
	}
	Fire_ApplyEffect(self.owner);
	if(!Fire_IsBurning(self.owner))
	{
		self.owner.fire_burner = world;
		remove(self);
		return;
	}
	Fire_ApplyDamage(self.owner);
	self.nextthink = time;
}


//This is for if there is oil everywhere (oil ocean), maybe we spread.
float autocvar_g_spawnfoliagearound_oilspread_global;
float autocvar_g_spawnfoliagearound_oilspread_globaljitter;
float autocvar_g_spawnfoliagearound_oilspreadlimitless;
float autocvar_g_spawnfoliagearound_oilspread;
float autocvar_g_spawnfoliagearound_oilspreadjitter;
float autocvar_g_spawnfoliagearound_oilfires;
float autocvar_g_spawnfoliagearound_oilfire_expl_spreadrate;
float autocvar_g_spawnfoliagearound_oilfire_expl_nolimit;
float autocvar_g_spawnfoliagearound_oilfire_spreadrate;
float autocvar_g_spawnfoliagearound_oilfire_spreadradius;
float autocvar_g_spawnfoliagearound_oilfire_vapourdepth;
float autocvar_g_spawnfoliagearound_oilfire_tooclose;
float autocvar_g_spawnfoliagearound_oilfire_tooclose_amnt;
float autocvar_g_spawnfoliagearound_oilfireent_rate;
float autocvar_g_spawnfoliagearound_oilfireent_radius;
float autocvar_g_spawnfoliagearound_oilfireent_think;
float autocvar_g_spawnfoliagearound_oilfireent_thinkjitter;
float autocvar_g_spawnfoliagearound_oilfireent_spreadmaxfail;
void weapon_burningreplacement_think(void);
void weapon_burningreplacement_oilfire_think(void);
float g_spawnfoliagearound_oillevel;
float g_spawnfoliagearound_oillevel_started;
float g_spawnfoliagearound_oillevel_unchanging;
float g_spawnfoliagearound_chemlevel;
float g_spawnfoliagearound_chemlevel_started;
float g_spawnfoliagearound_chemlevel_unchanging;
float g_spawnfoliagearound_methanelevel;
float g_spawnfoliagearound_methanelevel_started;
float g_spawnfoliagearound_methanelevel_unchanging;
float autocvar_g_spawnfoliagearound_methane_vapourdepth;
float autocvar_g_spawnfoliagearound_methane_expl_radius;
float autocvar_g_spawnfoliagearound_methane_expl_force;
float autocvar_g_spawnfoliagearound_methane_expl_damage;
float autocvar_g_spawnfoliagearound_methane_expl_edgedamage;
float autocvar_g_spawnfoliagearound_methane_expl_rate;
float autocvar_g_spawnfoliagearound_methane_explbullet_rate;
float autocvar_g_spawnfoliagearound_methane_explbullet_radius;
float autocvar_g_spawnfoliagearound_methane_explbullet_damage;
float autocvar_g_spawnfoliagearound_methane_explbullet_edgedamage;
float autocvar_g_spawnfoliagearound_methane_explbullet_force;
float nextspawnoilburner;
.float nextspawnoilburnertime;

float OilFire_TooClose (vector mygivenorigin) {
	local entity eburn;
	local float mynumfires;
	mynumfires = 0;
	eburn = findradius(mygivenorigin, autocvar_g_spawnfoliagearound_oilfire_tooclose);
	while(eburn)
	{
		if (eburn.classname == "oilfire") {
			mynumfires = mynumfires + 1;
		}
		if (mynumfires >= autocvar_g_spawnfoliagearound_oilfire_tooclose_amnt) {
			return TRUE;
		}
		eburn = eburn.chain;
	}
	return FALSE;
}

void OilFire_spawnoilburnerat (vector forigin)
{
	//print("he11 lets see if it is ok to spawn some ambient fire\n");
	//Don't spread beyond world, don't spread into solids
	if not(forigin_x > world.maxs_x || forigin_y > world.maxs_y || forigin_z > world.maxs_z || forigin_x < world.mins_x || forigin_y < world.mins_y || forigin_z < world.mins_z)
	{
	 //print("not outside of world\n");
	 if (pointcontents (forigin) != CONTENT_SOLID)
	 {
		//print("not in solid\n");
		local entity previousself, oile;
		previousself = self;
		oile = spawn();
		oile.origin = previousself.origin;
		oile.solid = SOLID_SLIDEBOX;
			
		oile.mins = ('-8 -8 -2');
		oile.maxs = ('8 8 8');
		
		if (random() < autocvar_g_spawnfoliagearound_oilfireent_rate) {
			oile.think = weapon_burningreplacement_oilfire_think;
			oile.nextthink = time + autocvar_g_spawnfoliagearound_oilfireent_think + (autocvar_g_spawnfoliagearound_oilfireent_thinkjitter * random());
		} else {
			oile.think = weapon_burningreplacement_think;
			oile.nextthink = time + 300;
		}
			
		oile.alpha = -1;
		oile.origin = forigin;
		oile.classname = "oilfire";
		oile.fire_oilfire_addsentreignite = 1;
		self = oile;
			
		setorigin(self, self.origin);
						
		self = previousself;
			
		Fire_AddDamage(oile, self, 10*9000000000, 9000000000, DEATH_FIRE);
	 }
	}
}

////////////////////////////////////////////////
//For map brush entities such at trigger_oilreactarea
vector OilFire_RandSpreadExt(vector myorigin, float mvamnt, float myzamnt)
{
	local vector myrandorigin;
	local float neg_or_pos;
	
		if (random() > 0.5) neg_or_pos = -1;
		else neg_or_pos = 1;
	
	myrandorigin_x = myorigin_x + (random() * mvamnt * neg_or_pos);
	
		if (random() > 0.5) neg_or_pos = -1;
		else neg_or_pos = 1;
	
	myrandorigin_y = myorigin_y + (random() * mvamnt * neg_or_pos);
	myrandorigin_z = myzamnt;
	return myrandorigin;
}
//For map brush entities such at trigger_oilreactarea
float OilFire_spawnoilburnerExt (vector myorigin, float mvamnt, float ignorespreadlimit, float myzamnt)
{
	local vector myrandorigin;
	local float mysuccessspread;
	mysuccessspread = 0;
	myrandorigin = OilFire_RandSpreadExt(myorigin, mvamnt, myzamnt);
	
	if ((time > nextspawnoilburner) || autocvar_g_spawnfoliagearound_oilspreadlimitless || ignorespreadlimit) {
		if (OilFire_TooClose(myrandorigin)) {
			//print("tooclose 1\n");
			myrandorigin = OilFire_RandSpreadExt(myrandorigin, mvamnt*2, myzamnt);
			if not (OilFire_TooClose(myrandorigin)) {
				//print("tooclose 2\n");
				OilFire_spawnoilburnerat(myrandorigin);
				mysuccessspread = 1;
			}
		} else {
			//print("not close, continue\n");
			OilFire_spawnoilburnerat(myrandorigin);
			mysuccessspread = 1;
		}
		nextspawnoilburner = time + autocvar_g_spawnfoliagearound_oilspread_global + (autocvar_g_spawnfoliagearound_oilspread_globaljitter * random()); //Global to limit spread
	}
	
	return mysuccessspread;
}	
////////////////////////////////////////////////

//Normal oilfire subroutines:
vector OilFire_RandSpread(vector myorigin, float mvamnt)
{
	local vector myrandorigin;
	local float neg_or_pos;
	
		if (random() > 0.5) neg_or_pos = -1;
		else neg_or_pos = 1;
	
	myrandorigin_x = myorigin_x + (random() * mvamnt * neg_or_pos);
	
		if (random() > 0.5) neg_or_pos = -1;
		else neg_or_pos = 1;
	
	myrandorigin_y = myorigin_y + (random() * mvamnt * neg_or_pos);
	myrandorigin_z = g_spawnfoliagearound_oillevel_unchanging + 1;
	return myrandorigin;
}

float OilFire_spawnoilburner (vector myorigin, float mvamnt, float ignorespreadlimit)
{
	local vector myrandorigin;
	local float mysuccessspread;
	mysuccessspread = 0;
	myrandorigin = OilFire_RandSpread(myorigin, mvamnt);
	
	if ((time > nextspawnoilburner) || autocvar_g_spawnfoliagearound_oilspreadlimitless || ignorespreadlimit) {
		if (OilFire_TooClose(myrandorigin)) {
			//print("tooclose 1\n");
			myrandorigin = OilFire_RandSpread(myrandorigin, mvamnt*2);
			if not (OilFire_TooClose(myrandorigin)) {
				//print("tooclose 2\n");
				OilFire_spawnoilburnerat(myrandorigin);
				mysuccessspread = 1;
			}
		} else {
			//print("not close, continue\n");
			OilFire_spawnoilburnerat(myrandorigin);
			mysuccessspread = 1;
		}
		nextspawnoilburner = time + autocvar_g_spawnfoliagearound_oilspread_global + (autocvar_g_spawnfoliagearound_oilspread_globaljitter * random()); //Global to limit spread
	}
	
	return mysuccessspread;
}		

void OilFire_spawnoilburnermaybe (entity myself)
{
	local vector entsorigin;	
	//Is oillvl mutator enabled, and if so
	//are we within the vapour area of the oil
	if (g_spawnfoliagearound_oillevel_started)
	if (g_spawnfoliagearound_oillevel && g_spawnfoliagearound_oillevel != 0)
	if (autocvar_g_spawnfoliagearound_oilfires)
	{
		entsorigin = myself.origin;
		if (entsorigin_z >= g_spawnfoliagearound_oillevel_unchanging)
		if (entsorigin_z < (g_spawnfoliagearound_oillevel_unchanging + autocvar_g_spawnfoliagearound_oilfire_vapourdepth))
		{
			
			if (time > myself.nextspawnoilburnertime) {
				if (myself.think == weapon_burningreplacement_oilfire_think && myself.fire_oilfirespreadfailed) {
					if (myself.fire_oilfirespreadfailed < autocvar_g_spawnfoliagearound_oilfireent_spreadmaxfail)
					{
						if (random() < autocvar_g_spawnfoliagearound_oilfire_spreadrate) {
							if (OilFire_spawnoilburner(entsorigin, autocvar_g_spawnfoliagearound_oilfire_spreadradius, 0)) { //Try to spawn some burnation within 192 radius
								//Do nothing
							} else {
								//print("oilfire failed to spread\n");
								myself.fire_oilfirespreadfailed = myself.fire_oilfirespreadfailed + 1;
							}
						}
						myself.nextspawnoilburnertime = time + autocvar_g_spawnfoliagearound_oilspread + (autocvar_g_spawnfoliagearound_oilspreadjitter * random()); //Local
					}
				} else {
					if (random() < autocvar_g_spawnfoliagearound_oilfire_spreadrate) {
						OilFire_spawnoilburner(entsorigin, autocvar_g_spawnfoliagearound_oilfire_spreadradius, 0); //Try to spawn some burnation within 192 radius
					}
					myself.nextspawnoilburnertime = time + autocvar_g_spawnfoliagearound_oilspread + (autocvar_g_spawnfoliagearound_oilspreadjitter * random()); //Local
				}
			}
		}
	}
}

void PossiblyReigniteFireFromOilFire (entity e) {
	//Reignite a player that emerges from oil
	if(!e.frozen)
	if(!e.freezetag_frozen)
	if(!e.stoned)
	if(e.deadflag == DEAD_NO)
	if(e.health > 0)
	{
	  if (e.fire_oilfire_entreignite > 0) {
	  	if (e.fire_oilfire_entwasinoil > 0) {
			if not(e.waterlevel) {
				if(!e.fire_burner) {
	  				Fire_AddDamage(e, e.fire_oilfire_entreignite_owner, 10*9000000000, 9000000000, DEATH_FIRE);
				}
			}
	  	}
	  }
	}
}


void Methane_Explode (void);

//NOTE: //This is just for spawning the flash, use // OilFire_explosion_spawnoilburnermaybe //
void OilFire_explosion_spawnoilburnermaybe_spawnmethaneflashent (entity myself, vector entsorigin)
{
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
			
				if (myself.realowner)
					flashent.realowner = myself.realowner;
				else if (myself.owner)
					flashent.realowner = myself.owner;
				else
					flashent.realowner = myself;
			
				if (myself.projectiledeathtype)
					flashent.projectiledeathtype = myself.projectiledeathtype;
				else
					flashent.projectiledeathtype = WEP_HAGAR;
					
				setmodel(flashent, "models/uziflash.md3");
				flashent.think = Methane_Explode; //ent will be removed once this happens
				flashent.nextthink = time + 0.1; // delay combo chains, looks cooler
				flashent.origin = entsorigin;
				setorigin(flashent, flashent.origin);
}

//When munitions explode, or an open flame is around, or someone is on fire, call this:
//Returns true if it exploded, the return is usually not used, but is used in w_torch.qc
float OilFire_explosion_spawnoilburnermaybe (entity myself)
{
	local float myreturn;
	local float didmethaneexp, didoilburnerspwn;
	myreturn = 0;
	didmethaneexp = 0;
	didoilburnerspwn = 0;
	local vector entsorigin;
	local entity entm;	
	//Is oillvl mutator enabled, and if so
	//are we within the vapour area of the oil
	if (g_spawnfoliagearound_oillevel_started)
	if (g_spawnfoliagearound_oillevel && g_spawnfoliagearound_oillevel != 0)
	if (autocvar_g_spawnfoliagearound_oilfires)
	{
		entsorigin = myself.origin;
		if (entsorigin_z >= g_spawnfoliagearound_oillevel_unchanging)
		if (entsorigin_z < (g_spawnfoliagearound_oillevel_unchanging + autocvar_g_spawnfoliagearound_oilfire_vapourdepth))
		{
			if (time > myself.nextspawnoilburnertime) {
				if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_spreadrate) {
					OilFire_spawnoilburner(entsorigin, autocvar_g_spawnfoliagearound_oilfire_spreadradius, autocvar_g_spawnfoliagearound_oilfire_expl_nolimit); //Try to spawn some burnation within 192 radius
					didoilburnerspwn = 1;
				}
				myself.nextspawnoilburnertime = time + autocvar_g_spawnfoliagearound_oilspread; //Local
			}
		}
	}
	
	if (g_spawnfoliagearound_methanelevel_started)
	if (g_spawnfoliagearound_methanelevel && g_spawnfoliagearound_methanelevel != 0)
	//if (autocvar_g_spawnfoliagearound_methaneflash)
	{
		entsorigin = myself.origin;
		if (entsorigin_z >= (g_spawnfoliagearound_methanelevel_unchanging - 16))
		if (entsorigin_z < (g_spawnfoliagearound_methanelevel_unchanging + autocvar_g_spawnfoliagearound_methane_vapourdepth))
		{
			if (random() < autocvar_g_spawnfoliagearound_methane_expl_rate)
			{
				OilFire_explosion_spawnoilburnermaybe_spawnmethaneflashent (myself, entsorigin);
				didmethaneexp = 1; //Remember so we don't do another below
				myreturn = 1;
			}
		}
	}
	
	//For map trigger_oilreactarea brush entities:
	if (oilreactareasexist) {
	if (didoilburnerspwn == 0) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		oilreactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(isoilreactarea, 1);
    		while (entm)
    		{
    		    oilreactareasexist = oilreactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	if (time > myself.nextspawnoilburnertime) {
				if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_spreadrate) {
					//print(ftos(entm.absmin_z), "_minz ", ftos(entsorigin_z), "_Z\n");
					OilFire_spawnoilburnerExt(entsorigin, autocvar_g_spawnfoliagearound_oilfire_spreadradius, autocvar_g_spawnfoliagearound_oilfire_expl_nolimit, (entm.absmin_z + 10)); //Try to spawn some burnation within 192 radius, Z + 10 as fireburner mins/max is -2,8 = 10 and bottom could be end of map, solid, etc)
				}
				myself.nextspawnoilburnertime = time + autocvar_g_spawnfoliagearound_oilspread; //Local
			}
		    }
    		    entm = entm.chain;
    		}	
	}
	}
	
	//For map trigger_methanereactarea brush entities:
	if (methanereactareasexist) {
	if (didmethaneexp == 0) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		methanereactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(ismethanereactarea, 1);
    		while (entm)
    		{
    		    methanereactareasexist = methanereactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	if (random() < autocvar_g_spawnfoliagearound_methane_expl_rate)
			{
		    	OilFire_explosion_spawnoilburnermaybe_spawnmethaneflashent (myself, entsorigin);
		    	myreturn = 1;
			}
		    }
    		    entm = entm.chain;
    		}	
	}
	}
	
	return myreturn;
}

void OilFire_explosion_spawnoilburnermaybe_viacoords (vector myorigin)
{
	entity evc;
	evc = spawn();
	evc.origin = myorigin;
	OilFire_explosion_spawnoilburnermaybe(evc);
	remove(evc);
}

void W_Plasma_Explode_Combo (void);
void Chemical_flash_maybe (entity myself)
{
	local vector entsorigin;
	local entity flashent;
	local float didchemexp;
	local entity entm;
	
	didchemexp = 0;
	
	//Is chemlvl mutator enabled, and if so
	//are we within the vapour area of the chem
	if (g_spawnfoliagearound_chemlevel_started)
	if (g_spawnfoliagearound_chemlevel && g_spawnfoliagearound_chemlevel != 0)
	//if (autocvar_g_spawnfoliagearound_chemflash)
	{
		entsorigin = myself.origin;
		if (entsorigin_z >= (g_spawnfoliagearound_chemlevel_unchanging - 32))
		if (entsorigin_z < (g_spawnfoliagearound_chemlevel_unchanging + 64))
		{
			if (random() < 0.5)
			{
			flashent = spawn();
			
			flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
			flashent.noaccuracyfrags = 1;
			
			flashent.realowner = myself.realowner;
			flashent.think = W_Plasma_Explode_Combo; //ent will be removed once this happens
			flashent.nextthink = time + vlen(flashent.WarpZone_findradius_dist) / autocvar_g_balance_electro_combo_speed; // delay combo chains, looks cooler
			flashent.origin = entsorigin;
			setorigin(flashent, flashent.origin);
			didchemexp = 1;
			}
		}
	}
	
	//For map trigger_chemreactarea brush entities:
	if (chemreactareasexist) {
	if (didchemexp == 0) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		chemreactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(ischemreactarea, 1);
    		while (entm)
    		{
    		    chemreactareasexist = chemreactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	if (random() < 0.5)
			{
			flashent = spawn();
			
			flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
			flashent.noaccuracyfrags = 1;
			
			flashent.realowner = myself.realowner;
			flashent.think = W_Plasma_Explode_Combo; //ent will be removed once this happens
			flashent.nextthink = time + vlen(flashent.WarpZone_findradius_dist) / autocvar_g_balance_electro_combo_speed; // delay combo chains, looks cooler
			flashent.origin = entsorigin;
			setorigin(flashent, flashent.origin);
			}
		    }
    		    entm = entm.chain;
    		}	
	}
	}
}

void Chemical_flash_maybe_at (vector entsorigin, entity myowner)
{
	local entity flashent;
	local float didchemexp;
	local entity entm;
	//Is chemlvl mutator enabled, and if so
	//are we within the vapour area of the chem
	if (g_spawnfoliagearound_chemlevel_started)
	if (g_spawnfoliagearound_chemlevel && g_spawnfoliagearound_chemlevel != 0)
	//if (autocvar_g_spawnfoliagearound_chemflash)
	{
		if (entsorigin_z >= (g_spawnfoliagearound_chemlevel_unchanging - 32))
		if (entsorigin_z < (g_spawnfoliagearound_chemlevel_unchanging + 64))
		{
			if (random() < 0.5)
			{
			flashent = spawn();
			
			flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
			flashent.noaccuracyfrags = 1;
			
			flashent.realowner = myowner;
			flashent.think = W_Plasma_Explode_Combo; //ent will be removed once this happens
			flashent.nextthink = time + vlen(flashent.WarpZone_findradius_dist) / autocvar_g_balance_electro_combo_speed; // delay combo chains, looks cooler
			flashent.origin = entsorigin;
			setorigin(flashent, flashent.origin);
			didchemexp = 1;
			}
		}
	}
	
	//For map trigger_chemreactarea brush entities:
	if (chemreactareasexist) {
	if (didchemexp == 0) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = entsorigin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = entsorigin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		chemreactareasexist = 0;
		
		entm = findchainfloat(ischemreactarea, 1);
    		while (entm)
    		{
    		    chemreactareasexist = chemreactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	if (random() < 0.5)
			{
			flashent = spawn();
			
			flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
			flashent.noaccuracyfrags = 1;
			
			flashent.realowner = myowner;
			flashent.think = W_Plasma_Explode_Combo; //ent will be removed once this happens
			flashent.nextthink = time + vlen(flashent.WarpZone_findradius_dist) / autocvar_g_balance_electro_combo_speed; // delay combo chains, looks cooler
			flashent.origin = entsorigin;
			setorigin(flashent, flashent.origin);
			}
		    }
    		    entm = entm.chain;
    		}	
	}
	}
}

void Methane_Explode (void)
{
	local float oldnohitplotanalysis, oldnoaccuracyfrags, myclienttype;
	oldnohitplotanalysis = self.realowner.nohitplotanalysis;
	oldnoaccuracyfrags = self.realowner.noaccuracyfrags;
	
	self.event_damage = func_null;
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_spawnfoliagearound_methane_expl_radius, 0.75, 0.07, 0.4);
	
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
	
	myclienttype = clienttype(self.realowner);
	if (myclienttype == CLIENTTYPE_REAL || myclienttype == CLIENTTYPE_BOT) {
		//Do nothing
	} else {
		self.realowner.nohitplotanalysis = 1; //We aren't a player nor are we a bot
		self.realowner.noaccuracyfrags = 1;
	}
	
	RadiusDamage (self, self.realowner, autocvar_g_spawnfoliagearound_methane_expl_damage, autocvar_g_spawnfoliagearound_methane_expl_edgedamage, autocvar_g_spawnfoliagearound_methane_expl_radius, world, autocvar_g_spawnfoliagearound_methane_expl_force, self.projectiledeathtype, other);
	
	self.realowner.nohitplotanalysis = oldnohitplotanalysis;
	self.realowner.noaccuracyfrags = oldnoaccuracyfrags;
	
	remove (self);
}

void Methane_ExplodeBullet (void)
{
	local float oldnohitplotanalysis, oldnoaccuracyfrags, myclienttype;
	oldnohitplotanalysis = self.realowner.nohitplotanalysis;
	oldnoaccuracyfrags = self.realowner.noaccuracyfrags;
	
	self.event_damage = func_null;
	pointparticles(particleeffectnum("explosion_small"), self.origin, '0 0 0', 1);
	
	myclienttype = clienttype(self.realowner);
	if (myclienttype == CLIENTTYPE_REAL || myclienttype == CLIENTTYPE_BOT) {
		//Do nothing
	} else {
		self.realowner.nohitplotanalysis = 1; //We aren't a player nor are we a bot
		self.realowner.noaccuracyfrags = 1;
	}
	
	RadiusDamage (self, self.realowner, autocvar_g_spawnfoliagearound_methane_explbullet_damage, autocvar_g_spawnfoliagearound_methane_explbullet_edgedamage, autocvar_g_spawnfoliagearound_methane_explbullet_radius, world, autocvar_g_spawnfoliagearound_methane_explbullet_force, self.projectiledeathtype, other);
	
	self.realowner.nohitplotanalysis = oldnohitplotanalysis;
	self.realowner.noaccuracyfrags = oldnoaccuracyfrags;
	
	remove (self);
}

//NOTE: // This is just for spawning the flash, use // Methane_ExplodeBullet_maybe_at //
void Methane_ExplodeBullet_maybe_at_spawnmethaneflash (vector entsorigin, entity myowner)
{
				local entity flashent;
				flashent = spawn();
			
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				
				flashent.realowner = myowner;
				flashent.projectiledeathtype = WEP_HAGAR;
				setmodel(flashent, "models/uziflash.md3");
				flashent.think = Methane_ExplodeBullet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = entsorigin;
				setorigin(flashent, flashent.origin);
}

//When a bullet is fired, call this:
void Methane_ExplodeBullet_maybe_at (vector entsorigin, entity myowner)
{
	local float didmethaneflash;
	local entity entm;
	didmethaneflash = 0;
	if (g_spawnfoliagearound_methanelevel_started)
	if (g_spawnfoliagearound_methanelevel && g_spawnfoliagearound_methanelevel != 0)
	//if (autocvar_g_spawnfoliagearound_methaneflash)
	{
		if (entsorigin_z >= (g_spawnfoliagearound_methanelevel_unchanging - 16))
		if (entsorigin_z < (g_spawnfoliagearound_methanelevel_unchanging + autocvar_g_spawnfoliagearound_methane_vapourdepth))
		{
			if (random() < autocvar_g_spawnfoliagearound_methane_explbullet_rate)
			{
				Methane_ExplodeBullet_maybe_at_spawnmethaneflash (entsorigin, myowner);
				
				didmethaneflash = 1;
			}
		}
	}
	
	//For map trigger_methanereactarea brush entities:
	if (methanereactareasexist) {
	if (didmethaneflash == 0) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = entsorigin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = entsorigin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		methanereactareasexist = 0;
		
		entm = findchainfloat(ismethanereactarea, 1);
    		while (entm)
    		{
    		    methanereactareasexist = methanereactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	if (random() < autocvar_g_spawnfoliagearound_methane_explbullet_rate)
			{
				Methane_ExplodeBullet_maybe_at_spawnmethaneflash (entsorigin, myowner);
			}
		    }
    		    entm = entm.chain;
    		}	
	}
	}
}



void flamethrower_spawnlight(entity myplayer);
void flamethrowerbeam_think_do(entity owner_player, entity damage_owner_player, float dt, float flamethrowerdamage, float flamethrowerforce, float flamethrowerforceup, float myburndamage, float myelementaltype);

.entity flamethrowerbeam;
.float prevflamethrowerfire;
.float flamethrower_arrowlit;
float flamethrowerbeam_send(entity to, float sf);
float frostbeam_send(entity to, float sf);
float poisonbeam_send(entity to, float sf);
vector w_shotorg;
vector w_shotend;

void PiercingCausesFire_FireJet_Think(void)
{
	local vector oldwshotorg, oldwshotend;
	local float mytestpointcontents, myjitter;
	
	mytestpointcontents = pointcontents(self.owner.origin);
	if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME) {
		remove(self);
		return;
	}
	
	self.owner.prevflamethrowerfire = time;
	if (self != self.owner.flamethrowerbeam)
	{
		remove(self);
		return;
	}

	if (!self.owner || self.owner == world)
	{
		if(self == self.owner.flamethrowerbeam)
			self.owner.flamethrowerbeam = world;
		remove(self);
		return;
	}
	
	self.nextthink = time;
	
	oldwshotorg = w_shotorg;
	oldwshotend = w_shotend;
	
	
		myjitter = 0;
		
		if (self.owner.ammount4 != 0) {
			//per flame set jitter
			myjitter = self.owner.ammount4;
			
			//Real time jitter;
			myjitter = myjitter + (crandom() * (myjitter*0.25)); //Looks cool, plume of fire on the end
		}
		
		makevectors(self.owner.v_angle);
		w_shotorg = self.owner.origin + v_forward * 2;
		w_shotend = w_shotorg + v_forward * (self.owner.ammount + myjitter);
		

		
		mytestpointcontents = pointcontents(w_shotorg);
		if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME) {
			remove(self);
			return;
		}
		
		Methane_ExplodeBullet_maybe_at (w_shotorg, self.owner); //If we are in methane, maybe cause an explosion

		if (!self.owner.flamethrower_arrowlit) {
			self.owner.flamethrower_arrowlit = 1;
			flamethrower_spawnlight(self.owner);
		}
	
		WarpZone_TraceLine(w_shotorg, w_shotend, MOVE_NOMONSTERS, self);
				
	
		flamethrowerbeam_think_do(self.owner, self.realowner, frametime,
		self.owner.ammount2,
		autocvar_g_balance_flamethrower_primary_force,
		autocvar_g_balance_flamethrower_primary_force_up,
		self.owner.ammount3,
		0);

	
	w_shotorg = oldwshotorg;
	w_shotorg = oldwshotend;		
}

void PiercingCausesFire_FireJet(void)
{
	local float mytestpointcontents;
	local entity oldflamethrowerbeam;

	self.nextthink = time + autocvar_g_balance_flamethrower_primary_refire;
	
	if (time > self.amnt) {
		self.flamethrower_arrowlit = 0;
		if (self.flamethrowerbeam) {
			oldflamethrowerbeam = self.flamethrowerbeam;
			self.flamethrowerbeam = world;
			remove(oldflamethrowerbeam);
		}
		remove (self);
		return;
	}
		
	mytestpointcontents = pointcontents(self.origin);
	if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
	if ((!self.flamethrowerbeam) || wasfreed(self.flamethrowerbeam))
	{
	self.canigniteflame = 1; //The emitter can ignite a flame for a crossbow bolt etc
	
	Methane_ExplodeBullet_maybe_at (self.origin, self); //If we are in methane, maybe cause an explosion

	pointparticles(particleeffectnum("torchflame"), self.origin, '0 0 0', 1);

	entity beam, oldself;

	self.flamethrowerbeam = beam = spawn();
	beam.classname = "flamethrowerbeam";
	beam.solid = SOLID_NOT;
	beam.think = PiercingCausesFire_FireJet_Think;
	beam.owner = self;
	beam.realowner = self.realowner;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_flamethrower_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, flamethrowerbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
	
	}
}

void PiercingCausesFire_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causeafirejet;
	if (autocvar_g_allpiercingcausesfire_disabled)
		return;
		
	if (!myobject.piercingcausesfire && !autocvar_g_allpiercingcausesfire && !ispipeforcejet)
		return;
		
	causeafirejet = 0;
	
	if (myobject.piercingcausesfire >= 1) {
		causeafirejet = 1;
	}
	
	if (ispipeforcejet) {
		causeafirejet = 1;
	}
	
	
	if (!causeafirejet) {
		if (autocvar_g_allpiercingcausesfire) {
			if (autocvar_g_allpiercingcausesfire >= 1) {
				causeafirejet = 1;
			} else if (random() < autocvar_g_allpiercingcausesfire) {
				causeafirejet = 1;
			}
		}
	}
	
	
	if (!causeafirejet) {
		if (random() < myobject.piercingcausesfire) {
			causeafirejet = 1;
		}
	}
	
	
	if (causeafirejet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				//flashent.projectiledeathtype = WEP_FLAMETHROWER;
				//setmodel(flashent, "models/uziflash.md3");
				flashent.think = PiercingCausesFire_FireJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				flashent.angles = vectoangles(mynormal);
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!myobject.piercingcausesfire_time && !ispipeforcejet) {
					flashent.amnt = time + 4;
				} else if (ispipeforcejet) {
					flashent.amnt = time + autocvar_g_allpiercingcausesfire_frompipes_time;
				} else {
					flashent.amnt = time + myobject.piercingcausesfire_time;
				}
				
				if (!myobject.piercingcausesfire_length && !ispipeforcejet) {
					flashent.ammount = 64;
				} else if (ispipeforcejet) {
					flashent.ammount = autocvar_g_allpiercingcausesfire_frompipes_length;
				} else {
					flashent.ammount = myobject.piercingcausesfire_length;
				}
				
				if (!myobject.piercingcausesfire_dmg && !ispipeforcejet) {
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				} else if (ispipeforcejet) {
					flashent.ammount2 = autocvar_g_allpiercingcausesfire_frompipes_dmg;
				} else {
					flashent.ammount2 = myobject.piercingcausesfire_dmg;
				}
				
				if (!myobject.piercingcausesfire_intensity && !ispipeforcejet) {
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				} else if (ispipeforcejet) {
					flashent.ammount3 = autocvar_g_allpiercingcausesfire_frompipes_intensity;
				} else {
					flashent.ammount3 = myobject.piercingcausesfire_dmg;
				}
				
				//Get it
				if (!myobject.piercingcausesfire_jitter && !ispipeforcejet) {
					flashent.ammount4 = 32;
				} else if (ispipeforcejet) {
					flashent.ammount4 = autocvar_g_allpiercingcausesfire_frompipes_jitter;
				} else {
					flashent.ammount4 = myobject.piercingcausesfire_jitter;
				}
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}


//

void PiercingCausesIce_IceJet_Think(void)
{
	local vector oldwshotorg, oldwshotend;
	local float mytestpointcontents, myjitter;
	
	mytestpointcontents = pointcontents(self.owner.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		remove(self);
		return;
	}
	
	self.owner.prevflamethrowerfire = time;
	if (self != self.owner.flamethrowerbeam)
	{
		remove(self);
		return;
	}

	if (!self.owner || self.owner == world)
	{
		if(self == self.owner.flamethrowerbeam)
			self.owner.flamethrowerbeam = world;
		remove(self);
		return;
	}
	
	self.nextthink = time;
	
	oldwshotorg = w_shotorg;
	oldwshotend = w_shotend;
	
	
		myjitter = 0;
		
		if (self.owner.ammount4 != 0) {
			//per flame set jitter
			myjitter = self.owner.ammount4;
			
			//Real time jitter;
			myjitter = myjitter + (crandom() * (myjitter*0.25)); //Looks cool, plume of fire on the end
		}
		
		makevectors(self.owner.v_angle);
		w_shotorg = self.owner.origin + v_forward * 2;
		w_shotend = w_shotorg + v_forward * (self.owner.ammount + myjitter);
		

		
		mytestpointcontents = pointcontents(w_shotorg);
		if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
			remove(self);
			return;
		}

	
		WarpZone_TraceLine(w_shotorg, w_shotend, MOVE_NOMONSTERS, self);
				
	
		flamethrowerbeam_think_do(self.owner, self.realowner, frametime,
		self.owner.ammount2,
		autocvar_g_balance_flamethrower_primary_force,
		autocvar_g_balance_flamethrower_primary_force_up,
		self.owner.ammount3,
		1);

	
	w_shotorg = oldwshotorg;
	w_shotorg = oldwshotend;		
}

void PiercingCausesIce_IceJet(void)
{
	local float mytestpointcontents;
	local entity oldflamethrowerbeam;

	self.nextthink = time + autocvar_g_balance_flamethrower_primary_refire;
	
	if (time > self.amnt) {
		if (self.flamethrowerbeam) {
			oldflamethrowerbeam = self.flamethrowerbeam;
			self.flamethrowerbeam = world;
			remove(oldflamethrowerbeam);
		}
		remove (self);
		return;
	}
		
	mytestpointcontents = pointcontents(self.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
	if ((!self.flamethrowerbeam) || wasfreed(self.flamethrowerbeam))
	{
	
	pointparticles(particleeffectnum("steam"), self.origin, '0 0 0', 1);

	entity beam, oldself;

	self.flamethrowerbeam = beam = spawn();
	beam.classname = "flamethrowerbeam";
	beam.solid = SOLID_NOT;
	beam.think = PiercingCausesIce_IceJet_Think;
	beam.owner = self;
	beam.realowner = self.realowner;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_flamethrower_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, frostbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
	
	}
}

void PiercingCausesIce_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causeaicejet;
	if (autocvar_g_allpiercingcausesice_disabled)
		return;
		
	if (!myobject.piercingcausesice && !autocvar_g_allpiercingcausesice && !ispipeforcejet)
		return;
		
	causeaicejet = 0;
	
	if (myobject.piercingcausesice >= 1) {
		causeaicejet = 1;
	}
	
	if (ispipeforcejet) {
		causeaicejet = 1;
	}
	
	
	if (!causeaicejet) {
		if (autocvar_g_allpiercingcausesice) {
			if (autocvar_g_allpiercingcausesice >= 1) {
				causeaicejet = 1;
			} else if (random() < autocvar_g_allpiercingcausesice) {
				causeaicejet = 1;
			}
		}
	}
	
	
	if (!causeaicejet) {
		if (random() < myobject.piercingcausesice) {
			causeaicejet = 1;
		}
	}
	
	
	if (causeaicejet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				//flashent.projectiledeathtype = WEP_FLAMETHROWER;
				//setmodel(flashent, "models/uziflash.md3");
				flashent.think = PiercingCausesIce_IceJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				flashent.angles = vectoangles(mynormal);
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!myobject.piercingcausesice_time && !ispipeforcejet) {
					flashent.amnt = time + 4;
				} else if (ispipeforcejet) {
					flashent.amnt = time + autocvar_g_allpiercingcausesice_frompipes_time;
				} else {
					flashent.amnt = time + myobject.piercingcausesice_time;
				}
				
				if (!myobject.piercingcausesice_length && !ispipeforcejet) {
					flashent.ammount = 64;
				} else if (ispipeforcejet) {
					flashent.ammount = autocvar_g_allpiercingcausesice_frompipes_length;
				} else {
					flashent.ammount = myobject.piercingcausesice_length;
				}
				
				if (!myobject.piercingcausesice_dmg && !ispipeforcejet) {
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				} else if (ispipeforcejet) {
					flashent.ammount2 = autocvar_g_allpiercingcausesice_frompipes_dmg;
				} else {
					flashent.ammount2 = myobject.piercingcausesice_dmg;
				}
				
				if (!myobject.piercingcausesice_intensity && !ispipeforcejet) {
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				} else if (ispipeforcejet) {
					flashent.ammount3 = autocvar_g_allpiercingcausesice_frompipes_intensity;
				} else {
					flashent.ammount3 = myobject.piercingcausesice_dmg;
				}
				
				//Get it
				if (!myobject.piercingcausesice_jitter && !ispipeforcejet) {
					flashent.ammount4 = 32;
				} else if (ispipeforcejet) {
					flashent.ammount4 = autocvar_g_allpiercingcausesice_frompipes_jitter;
				} else {
					flashent.ammount4 = myobject.piercingcausesice_jitter;
				}
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}


//

void spawnfunc_func_pointparticles();
void spawnfunc_target_speaker();

.entity subordinate;
.entity subordinate4;
void PiercingCausesSteam_Think(void)
{

	if (self.subordinate && self.subordinate != world) {
		remove (self.subordinate);
	}
	
	if (self.subordinate4 && self.subordinate4 != world) {
		remove (self.subordinate4);
	}
	
	remove (self);
	return;
}
	
void PiercingCausesSteam_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causeasteamjet;
	if (autocvar_g_allpiercingcausessteam_disabled)
		return;
		
	if (!myobject.piercingcausessteam && !autocvar_g_allpiercingcausessteam && !ispipeforcejet)
		return;
		
	causeasteamjet = 0;
	
	if (myobject.piercingcausessteam >= 1) {
		causeasteamjet = 1;
	}
	
	if (ispipeforcejet) {
		causeasteamjet = 1;
	}
	
	if (!causeasteamjet) {
		if (autocvar_g_allpiercingcausessteam) {
			if (autocvar_g_allpiercingcausessteam >= 1) {
				causeasteamjet = 1;
			} else if (random() < autocvar_g_allpiercingcausessteam) {
				causeasteamjet = 1;
			}
		}
	}
	
	
	if (!causeasteamjet) {
		if (random() < myobject.piercingcausessteam) {
			causeasteamjet = 1;
		}
	}
	
	
	if (causeasteamjet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_WATER || mytestpointcontents == CONTENT_SLIME || mytestpointcontents == CONTENT_LAVA) {
		return;
	}
	
				local entity flashent;
				local entity mysteam;
				local entity oldself;
				oldself = self;
				flashent = spawn();
			
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				flashent.think = PiercingCausesSteam_Think; //ent will be removed once this happens
				
				if (!myobject.piercingcausessteam_time && !ispipeforcejet) {
					flashent.nextthink = time + 4;
				} else if (ispipeforcejet) {
					flashent.nextthink = time + autocvar_g_allpiercingcausessteam_frompipes_time;
				} else {
					flashent.nextthink = time + myobject.piercingcausessteam_time;
				}

				
				mysteam = spawn();
				mysteam.mins = '0 0 0';
				mysteam.maxs = '0 0 0';
				mysteam.mdl = "pipe_smoke";
				mysteam.origin = mybullet.origin;
				if (!myobject.piercingcausessteam_amount && !ispipeforcejet) {
					mysteam.impulse = 50;
				} else if (ispipeforcejet) {
					mysteam.impulse = autocvar_g_allpiercingcausessteam_frompipes_amount;
				} else {
					mysteam.impulse = myobject.piercingcausessteam_amount;
				}
				
				if (!myobject.piercingcausessteam_speed && !ispipeforcejet) {
					mysteam.velocity = mynormal * 20;
				} else if (ispipeforcejet) {
					mysteam.velocity = mynormal * autocvar_g_allpiercingcausessteam_frompipes_speed;
				} else {
					mysteam.velocity = mynormal * myobject.piercingcausessteam_speed;
				}

				flashent.subordinate = mysteam;

				self = mysteam;
				setorigin(self, self.origin);
				spawnfunc_func_pointparticles();
				
				spamsound (self, CH_SHOTS, "map_red_planet/steam_loop.wav", VOL_BASE, ATTN_NORM);
				
				
				self = oldself;
				
				
}

//
void mg_deluge_attack(string tagname, entity spigot, float myspeed, float mydelugetype);
void PiercingCausesWater_WaterJet(void)
{
	local float mytestpointcontents;

	self.nextthink = time + 0.1;
	
	if (time > self.amnt) {
		remove (self);
		return;
	}
		
	mytestpointcontents = pointcontents(self.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
		local float myjitter;
		myjitter = 0;
		if (self.ammount4 != 0) {
			//per flame set jitter
			myjitter = self.owner.ammount4;
			
			//Real time jitter;
			myjitter = myjitter + (crandom() * (myjitter*0.25)); //Looks cool, plume of fire on the end
		}
		
	makevectors(self.angles);
	mg_deluge_attack("", self, self.ammount+myjitter, 0);
	
}

void PiercingCausesWater_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causeawaterjet;
	if (autocvar_g_allpiercingcauseswater_disabled)
		return;
		
	if (!myobject.piercingcauseswater && !autocvar_g_allpiercingcauseswater && !ispipeforcejet)
		return;
		
	causeawaterjet = 0;
	
	if (myobject.piercingcauseswater >= 1) {
		causeawaterjet = 1;
	}
	
	if (ispipeforcejet) {
		causeawaterjet = 1;
	}
	
	
	if (!causeawaterjet) {
		if (autocvar_g_allpiercingcauseswater) {
			if (autocvar_g_allpiercingcauseswater >= 1) {
				causeawaterjet = 1;
			} else if (random() < autocvar_g_allpiercingcauseswater) {
				causeawaterjet = 1;
			}
		}
	}
	
	
	if (!causeawaterjet) {
		if (random() < myobject.piercingcauseswater) {
			causeawaterjet = 1;
		}
	}
	
	
	if (causeawaterjet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_SLIME) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				flashent.think = PiercingCausesWater_WaterJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				flashent.angles = vectoangles(mynormal);
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!myobject.piercingcauseswater_time && !ispipeforcejet) {
					flashent.amnt = time + 4;
				} else if (ispipeforcejet) {
					flashent.amnt = time + autocvar_g_allpiercingcauseswater_frompipes_time;
				} else {
					flashent.amnt = time + myobject.piercingcauseswater_time;
				}
				
				if (!myobject.piercingcauseswater_speed && !ispipeforcejet) {
					flashent.ammount = 650;
				} else if (ispipeforcejet) {
					flashent.ammount = autocvar_g_allpiercingcauseswater_frompipes_speed;
				} else {
					flashent.ammount = myobject.piercingcauseswater_speed;
				}
				
				//Get it
				if (!myobject.piercingcauseswater_jitter && !ispipeforcejet) {
					flashent.ammount4 = 225;
				} else if (ispipeforcejet) {
					flashent.ammount4 = autocvar_g_allpiercingcauseswater_frompipes_jitter;
				} else {
					flashent.ammount4 = myobject.piercingcauseswater_jitter;
				}
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}



//

void PiercingCausesPoison_PoisonJet_Think(void)
{
	local vector oldwshotorg, oldwshotend;
	local float mytestpointcontents, myjitter;
	
	mytestpointcontents = pointcontents(self.owner.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER) {
		remove(self);
		return;
	}
	
	self.owner.prevflamethrowerfire = time;
	if (self != self.owner.flamethrowerbeam)
	{
		remove(self);
		return;
	}

	if (!self.owner || self.owner == world)
	{
		if(self == self.owner.flamethrowerbeam)
			self.owner.flamethrowerbeam = world;
		remove(self);
		return;
	}
	
	self.nextthink = time;
	
	oldwshotorg = w_shotorg;
	oldwshotend = w_shotend;
	
	
		myjitter = 0;
		
		if (self.owner.ammount4 != 0) {
			//per flame set jitter
			myjitter = self.owner.ammount4;
			
			//Real time jitter;
			myjitter = myjitter + (crandom() * (myjitter*0.25)); //Looks cool, plume of fire on the end
		}
		
		makevectors(self.owner.v_angle);
		w_shotorg = self.owner.origin + v_forward * 2;
		w_shotend = w_shotorg + v_forward * (self.owner.ammount + myjitter);
		

		
		mytestpointcontents = pointcontents(w_shotorg);
		if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER) {
			remove(self);
			return;
		}

	
		WarpZone_TraceLine(w_shotorg, w_shotend, MOVE_NOMONSTERS, self);
				
	
		flamethrowerbeam_think_do(self.owner, self.realowner, frametime,
		self.owner.ammount2,
		autocvar_g_balance_flamethrower_primary_force,
		autocvar_g_balance_flamethrower_primary_force_up,
		self.owner.ammount3,
		2);

	
	w_shotorg = oldwshotorg;
	w_shotorg = oldwshotend;		
}

void PiercingCausesPoison_PoisonJet(void)
{
	local float mytestpointcontents;
	local entity oldflamethrowerbeam;

	self.nextthink = time + autocvar_g_balance_flamethrower_primary_refire;
	
	if (time > self.amnt) {
		if (self.flamethrowerbeam) {
			oldflamethrowerbeam = self.flamethrowerbeam;
			self.flamethrowerbeam = world;
			remove(oldflamethrowerbeam);
		}
		remove (self);
		return;
	}
		
	mytestpointcontents = pointcontents(self.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER) {
		return;
	}
	
	if ((!self.flamethrowerbeam) || wasfreed(self.flamethrowerbeam))
	{
	
	pointparticles(particleeffectnum("steam"), self.origin, '0 0 0', 1);

	entity beam, oldself;

	self.flamethrowerbeam = beam = spawn();
	beam.classname = "flamethrowerbeam";
	beam.solid = SOLID_NOT;
	beam.think = PiercingCausesPoison_PoisonJet_Think;
	beam.owner = self;
	beam.realowner = self.realowner;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_flamethrower_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, poisonbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
	
	}
}

void PiercingCausesPoison_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causeapoisonjet;
	if (autocvar_g_allpiercingcausespoison_disabled)
		return;
		
	if (!myobject.piercingcausespoison && !autocvar_g_allpiercingcausespoison && !ispipeforcejet)
		return;
		
	causeapoisonjet = 0;
	
	if (myobject.piercingcausespoison >= 1) {
		causeapoisonjet = 1;
	}
	
	if (ispipeforcejet) {
		causeapoisonjet = 1;
	}
	
	
	if (!causeapoisonjet) {
		if (autocvar_g_allpiercingcausespoison) {
			if (autocvar_g_allpiercingcausespoison >= 1) {
				causeapoisonjet = 1;
			} else if (random() < autocvar_g_allpiercingcausespoison) {
				causeapoisonjet = 1;
			}
		}
	}
	
	
	if (!causeapoisonjet) {
		if (random() < myobject.piercingcausespoison) {
			causeapoisonjet = 1;
		}
	}
	
	
	if (causeapoisonjet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_LAVA || mytestpointcontents == CONTENT_WATER) {
		return;
	}
	
				local entity flashent;
				flashent = spawn();
				
				flashent.nohitplotanalysis = 1; //We aren't a player nor are we a bot
				flashent.noaccuracyfrags = 1;
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				//flashent.projectiledeathtype = WEP_FLAMETHROWER;
				//setmodel(flashent, "models/uziflash.md3");
				flashent.think = PiercingCausesPoison_PoisonJet; //ent will be removed once this happens
				flashent.nextthink = time; //Nearly No Delay for bullet
				flashent.origin = mybullet.origin;
				flashent.angles = vectoangles(mynormal);
				flashent.angles_x = flashent.angles_x * -1;
				flashent.v_angle = flashent.angles;
				
				if (!myobject.piercingcausespoison_time && !ispipeforcejet) {
					flashent.amnt = time + 4;
				} else if (ispipeforcejet) {
					flashent.amnt = time + autocvar_g_allpiercingcausespoison_frompipes_time;
				} else {
					flashent.amnt = time + myobject.piercingcausespoison_time;
				}
				
				if (!myobject.piercingcausespoison_length && !ispipeforcejet) {
					flashent.ammount = 64;
				} else if (ispipeforcejet) {
					flashent.ammount = autocvar_g_allpiercingcausespoison_frompipes_length;
				} else {
					flashent.ammount = myobject.piercingcausespoison_length;
				}
				
				if (!myobject.piercingcausespoison_dmg && !ispipeforcejet) {
					flashent.ammount2 = autocvar_g_balance_flamethrower_primary_damage;
				} else if (ispipeforcejet) {
					flashent.ammount2 = autocvar_g_allpiercingcausespoison_frompipes_dmg;
				} else {
					flashent.ammount2 = myobject.piercingcausespoison_dmg;
				}
				
				if (!myobject.piercingcausespoison_intensity && !ispipeforcejet) {
					flashent.ammount3 = autocvar_g_balance_torch_fire_damage;
				} else if (ispipeforcejet) {
					flashent.ammount3 = autocvar_g_allpiercingcausespoison_frompipes_intensity;
				} else {
					flashent.ammount3 = myobject.piercingcausespoison_dmg;
				}
				
				//Get it
				if (!myobject.piercingcausespoison_jitter && !ispipeforcejet) {
					flashent.ammount4 = 32;
				} else if (ispipeforcejet) {
					flashent.ammount4 = autocvar_g_allpiercingcausespoison_frompipes_jitter;
				} else {
					flashent.ammount4 = myobject.piercingcausespoison_jitter;
				}
				
				
				//Now set it:
				if (flashent.ammount4 > 0) {
					flashent.ammount4 = crandom() * flashent.ammount4;
				} else {
					flashent.ammount4 = 0;
				}
		
				
				setorigin(flashent, flashent.origin);
				
				
				
}



//

.float modelscale;
void spawnfunc_misc_laser();

void PiercingCausesLaser_Think(void)
{

	if (self.subordinate && self.subordinate != world) {
		remove (self.subordinate);
	}
	
	//if (self.subordinate4 && self.subordinate4 != world) {
	//	remove (self.subordinate4);
	//}
	
	remove (self);
	return;
}
	
void PiercingCausesLaser_maybe(entity mybullet, entity myobject, vector mynormal, float ispipeforcejet)
{
	local float causealaserjet;
	if (autocvar_g_allpiercingcauseslaser_disabled)
		return;
		
	if (!myobject.piercingcauseslaser && !autocvar_g_allpiercingcauseslaser && !ispipeforcejet)
		return;
		
	causealaserjet = 0;
	
	if (myobject.piercingcauseslaser >= 1) {
		causealaserjet = 1;
	}
	
	if (ispipeforcejet) {
		causealaserjet = 1;
	}
	
	if (!causealaserjet) {
		if (autocvar_g_allpiercingcauseslaser) {
			if (autocvar_g_allpiercingcauseslaser >= 1) {
				causealaserjet = 1;
			} else if (random() < autocvar_g_allpiercingcauseslaser) {
				causealaserjet = 1;
			}
		}
	}
	
	
	if (!causealaserjet) {
		if (random() < myobject.piercingcauseslaser) {
			causealaserjet = 1;
		}
	}
	
	
	if (causealaserjet) {
		//Nothing
	} else {
		return;
	}

	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mybullet.origin);
	if (mytestpointcontents == CONTENT_SLIME || mytestpointcontents == CONTENT_LAVA) {
		return;
	}
	
				local entity flashent;
				local entity mylaser;
				local entity oldself;
				oldself = self;
				flashent = spawn();
			
				flashent.realowner = mybullet.realowner;
				flashent.classname = "piercedjetemitter";
				flashent.think = PiercingCausesLaser_Think; //ent will be removed once this happens
				
				if (!myobject.piercingcauseslaser_time && !ispipeforcejet) {
					flashent.nextthink = time + 4;
				} else if (ispipeforcejet) {
					flashent.nextthink = time + autocvar_g_allpiercingcauseslaser_frompipes_time;
				} else {
					flashent.nextthink = time + myobject.piercingcauseslaser_time;
				}

				
				mylaser = spawn();
				mylaser.origin = mybullet.origin;
				mylaser.angles = vectoangles(mynormal);
				mylaser.angles_x = mylaser.angles_x * -1;
				mylaser.v_angle = mylaser.angles;
				if ((myobject.piercingcauseslaser_colormod == '0 0 0') && !ispipeforcejet) {
					////mylaser.colormod = '0 0 0';
				} else if (ispipeforcejet) {
					mylaser.colormod_x = autocvar_g_allpiercingcauseslaser_frompipes_colorred;
					mylaser.colormod_y = autocvar_g_allpiercingcauseslaser_frompipes_colorgreen;
					mylaser.colormod_z = autocvar_g_allpiercingcauseslaser_frompipes_colorblue;
				} else {
					mylaser.colormod = myobject.piercingcauseslaser_colormod;
				}
				
				if (!myobject.piercingcauseslaser_dmg && !ispipeforcejet) {
					////mylaser.dmg = 0;
				} else if (ispipeforcejet) {
					mylaser.dmg = autocvar_g_allpiercingcauseslaser_frompipes_dmg;
				} else {
					mylaser.dmg = myobject.piercingcauseslaser_dmg;
				}
				
				if (!myobject.piercingcauseslaser_alpha && !ispipeforcejet) {
					////mylaser.alpha = 0;
				} else if (ispipeforcejet) {
					mylaser.alpha = autocvar_g_allpiercingcauseslaser_frompipes_alpha;
				} else {
					mylaser.alpha = myobject.piercingcauseslaser_alpha;
				}
				
				if (!myobject.piercingcauseslaser_scale && !ispipeforcejet) {
					////mylaser.scale = 0;
				} else if (ispipeforcejet) {
					mylaser.scale = autocvar_g_allpiercingcauseslaser_frompipes_scale;
				} else {
					mylaser.scale = myobject.piercingcauseslaser_scale;
				}
				
				if (!myobject.piercingcauseslaser_modelscale && !ispipeforcejet) {
					////mylaser.modelscale = 0;
				} else if (ispipeforcejet) {
					mylaser.modelscale = autocvar_g_allpiercingcauseslaser_frompipes_modelscale;
				} else {
					mylaser.modelscale = myobject.piercingcauseslaser_modelscale;
				}

				flashent.subordinate = mylaser;

				self = mylaser;
				setorigin(self, self.origin);
				spawnfunc_misc_laser();				
				
				self = oldself;
				
				
}

//
