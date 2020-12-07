void race_send_recordtime(float msg);
void race_SendRankings(float pos, float prevpos, float del, float msg);
void PutItBackIfAble (entity player);
void WhipItOutIfAble (entity player);
void ErectItIfSet (entity player);
void GiveStartSpells (entity player);
void GiveStartSpells_team1 (entity player);
void GiveStartSpells_team2 (entity player);
void GiveStartSpells_team3 (entity player);
void GiveStartSpells_team4 (entity player);

void send_CSQC_teamnagger() {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_TEAMNAGGER);
}

void Announce(string snd) {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_ANNOUNCE);
	WriteString(MSG_BROADCAST, snd);
}

void AnnounceTo(entity e, string snd) {
	if (clienttype(e) == CLIENTTYPE_REAL)
	{
		msg_entity = e;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_CSQC_ANNOUNCE);
		WriteString(MSG_ONE, snd);
	}
}

/*
////////////////////////////////////////////////////////////////
//START Client Remeber
//
//These routines below have to do with saving info about player
//so stoned players stay stoned when they reconnect
///////////////////////////////////////////////////////////////
*/
float Client_Apply_Me_To_You (entity player, entity shadow) {
	//Apply me, then remove me
	float isprisoner;
	isprisoner = 0;
	player.model = shadow.svdstring1; //Reverse Abusing this
	
		if (shadow.permblinded) {
			player.permblinded = shadow.permblinded;
		}
		
		if (shadow.permmangled_l) {
			player.permmangled_l = shadow.permmangled_l;
		}
		if (shadow.permmangled_r) {
			player.permmangled_r = shadow.permmangled_r;
		}
		if (shadow.permhobbled_l) {
			player.permhobbled_l = shadow.permhobbled_l;
		}
		if (shadow.permhobbled_r) {
			player.permhobbled_r = shadow.permhobbled_r;
		}
		
		if (shadow.numhasdied) {
			player.numhasdied = shadow.numhasdied;
		}
		
		if (shadow.stoned) {
			player.stoned = shadow.stoned;
			player.strevive_progress = shadow.strevive_progress;
			player.strevive_speed = shadow.strevive_speed;
			player.stonedorigin = shadow.stonedorigin;
			player.stonedangles = shadow.stonedangles;
			player.skin = shadow.skin;
			player.stoneskin = shadow.stoneskin;
		}
		
		if (shadow.health_stable_reduce) {
			player.health_stable_reduce = shadow.health_stable_reduce;
		}
		
		if (shadow.armor_stable_reduce) {
			player.armor_stable_reduce = shadow.armor_stable_reduce;
		}
		
		if (shadow.mana_stable_reduce) {
			player.mana_stable_reduce = shadow.mana_stable_reduce;
		}
	
		player.body_phal_stat = shadow.body_phal_stat;
	
		if (shadow.body_phal)
		if (shadow.body_phal.cnt)
		{
			player.body_phal = spawn();
			player.body_phal.cnt = shadow.body_phal.cnt;
			player.body_phal.alpha = 0.0001;
		}
		
		if (shadow.prisonerlevel || shadow.handcuffed)
		{
			float is_player;
			player.handcuffed = shadow.handcuffed;
			player.jailor = shadow.jailor;
			
			if (player.jailor.jailee && player.jailor.jailee != world && player.jailor.jailee != player)
			{
				//print("jailee exists and is not world nor player\n");
				//print("IS:", etos(player.jailor.jailee),"\n");
			} else {
				player.jailor.jailee = player; //Restore
				//print("restoring jailness: ", etos(player.jailor)," is jailor of", etos(player.jailor.jailee),"\n");
			}
			player.prisonerlevel = shadow.prisonerlevel;
			player.prison1spot = shadow.prison1spot;
			player.prison2spot = shadow.prison2spot;
			player.prison3spot = shadow.prison3spot;
			player.prison3angles = shadow.prison3angles;
			player.prison3ent = shadow.prison3ent;
			//player.team_forced = shadow.team_forced;
			player.team = shadow.team;
			isprisoner = 1;
		}
		
	//If we have a placeholder statue
	if (shadow.subordinate) {
		if (shadow.subordinate != world) {
			shadow.subordinate.model = "null";
			shadow.subordinate.alpha = -1;
			shadow.subordinate.solid = SOLID_NOT;
			shadow.subordinate.nextthink = 0;
			shadow.subordinate.think = func_null;
			setmodel(shadow.subordinate, "null");
			remove_safely(shadow.subordinate);
		}
	}
	remove(shadow);
	return(isprisoner);
}

float Client_I_Remember_You (entity player)
{
	float isprisoner;
	//Called on spawn after connect to see if we remember this player
	entity shadowent;
	float foundshadow;
	
	//print(player.netaddress, " netaddress\n");
	//print(player.crypto_keyfp, " cryptokey\n");
	
	isprisoner = 0;
	foundshadow = 0;
	entity e;
  	for(e = findchain(classname, "i_remember_you"); e; e = e.chain)
	{
		//print("CRYPTIDspinning\n");
		if(player.crypto_keyfp) {
			if (e.svdstring2 == player.crypto_idfp) {
				dprint("player crypto_idfp matched, will reapply settings\n");
				shadowent = e;
				foundshadow = 1;
			}
		}		
	}
	
	if (foundshadow != 1)
	{
	  if(player.netaddress)
	  if(player.netaddress != "local")
	  if(player.netaddress != "null/botclient")
	  if(clienttype(player) != CLIENTTYPE_BOT)
	  {
	    for(e = findchain(classname, "i_remember_you"); e; e = e.chain)
	    {
	  	//print("NETADDRspinning\n");
		if (e.svdstring3 == player.netaddress) {
			shadowent = e;
			foundshadow = 1;
		}
	    }
	  }
	}
	
	if (foundshadow != 1)
	{
	  for(e = findchain(classname, "i_remember_you"); e; e = e.chain)
	  {
	  	//print("NICKNAMEspinning\n");
		if(player.netname)
		{
			//print("spinning2222 Enetname: ",e.svdstring0," Playernn: ",player.netname,"\n");
			if (e.svdstring0 == player.netname) {
				shadowent = e;
				foundshadow = 1;
			}
		}
	  }
	}
	
	if (foundshadow == 1)
	{
		//print("Remembed client: ",player.netname,"\n");
		isprisoner = Client_Apply_Me_To_You(player, shadowent);
	}
	
	return(isprisoner);
}

void Client_Record_statuemodel_think(void)
{
	//print("So the animation stays "static"\n");
	BITXOR_ASSIGN(self.effects, EF_RESTARTANIM_BIT);
	self.nextthink = time;
}

void Client_Record_statuemodel_respawn(void)
{
	self.health = 100;
	self.solid = SOLID_BBOX;
	self.alpha = autocvar_g_player_stonemodel_disconnected_alpha;
	self.think = Client_Record_statuemodel_think;
	self.nextthink = time;
}

void Client_Record_statuemodel_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	self.health = self.health - damage;
	if (self.health <= 0) {
		self.solid = SOLID_NOT;
		self.alpha = -1;
		self.think = Client_Record_statuemodel_respawn;
		self.nextthink = time + 10;
		if (MayWeDoGibs(deathtype)) {
			if (deathtype == DEATH_HURTLASER)
				Violence_GibSplash(self, 4, 1, attacker);
			else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE))
				Violence_GibSplash(self, 4, 1, attacker);
			else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV))
				Violence_GibSplash(self, 4, 1, attacker);
			else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI))
				Violence_GibSplash(self, 4, 1, attacker);
			else
				Violence_GibSplash(self, 1, 1, attacker);
		}
	}
}

void Client_Record (entity player)
{
	//Called on disconnect to record permanant things
	if (player.stoned || player.prisonerlevel || player.body_phal.cnt || player.handcuffed
	|| player.permblinded || player.permmangled_l || player.permmangled_r
	|| player.permhobbled_l || player.permhobbled_r || player.numhasdied
	|| player.health_stable_reduce || player.armor_stable_reduce || player.mana_stable_reduce)
	{
		entity shadow;
		entity oldself;
		shadow = spawn();
		shadow.alpha = 0.0001;
		shadow.classname = "i_remember_you";
		
		string m;
		m = strzone(player.crypto_idfp);
		shadow.svdstring2 = m; //Gotta do it this way because strings in QC are pointers, we are not pointing to this immutable string in m
		
		shadow.svdstring3 = strzone(player.netaddress);
		shadow.svdstring0 = strzone(player.netname);
		
		//shadow.svdstring1 = player.model; //Abusing this
	
		if (player.permblinded) {
			shadow.permblinded = player.permblinded;
		}
		
		if (player.permmangled_l) {
			shadow.permmangled_l = player.permmangled_l;
		}
		if (player.permmangled_r) {
			shadow.permmangled_r = player.permmangled_r;
		}
		if (player.permhobbled_l) {
			shadow.permhobbled_l = player.permhobbled_l;
		}
		if (player.permhobbled_r) {
			shadow.permhobbled_r = player.permhobbled_r;
		}
		
		if (player.numhasdied) {
			shadow.numhasdied = player.numhasdied;
		}
		
		if (player.stoned) {
			shadow.stoned = player.stoned;
			shadow.strevive_progress = player.strevive_progress;
			shadow.strevive_speed = player.strevive_speed;
			shadow.stonedorigin = player.stonedorigin;
			shadow.stonedangles = player.stonedangles;
			shadow.skin = player.skin;
			shadow.stoneskin = player.stoneskin;
			oldself = self;
			self = player;
			self.stoneskin = player_getstoneskin();
			self = oldself;
			
			//Spawn a slighly translucent model
			//To be a placeholder while client is disconnected
			local entity statuemodel;
			statuemodel = spawn();
			shadow.subordinate = statuemodel; //So we can remove this statue placeholder when client reconnects
			statuemodel.origin = shadow.stonedorigin;
			statuemodel.angles = shadow.stonedangles;
			statuemodel.model = player.model;
			statuemodel.frame = player.frame;
			statuemodel.skin = shadow.stoneskin;
			statuemodel.mins = player.mins;
			statuemodel.maxs = player.maxs;
			//print(vtos(player.mins), "pmins\n");
			statuemodel.alpha = autocvar_g_player_stonemodel_disconnected_alpha; //So you know client isn't there right now
			statuemodel.solid = SOLID_BBOX;
			statuemodel.stoned = 1;
			statuemodel.health = player.health; 
			statuemodel.takedamage = DAMAGE_YES;
			statuemodel.event_damage = Client_Record_statuemodel_damage;
			statuemodel.species = SPECIES_STONE; 
			//No movetype as that won't let us do the .think consistently
			statuemodel.ballistics_density = autocvar_g_ballistics_density_stone;
			oldself = self;
			self = statuemodel;
			self.think = Client_Record_statuemodel_think;
			self.nextthink = time;
			setmodel(self, self.model);
			setorigin(self, self.origin);
			setsize(self, PL_MIN, PL_MAX);
			self = oldself;
		}
		
		if (player.health_stable_reduce) {
			shadow.health_stable_reduce = player.health_stable_reduce;
		}
		
		if (player.armor_stable_reduce) {
			shadow.armor_stable_reduce = player.armor_stable_reduce;
		}
		
		if (player.mana_stable_reduce) {
			shadow.mana_stable_reduce = player.mana_stable_reduce;
		}
	
		shadow.body_phal_stat = player.body_phal_stat;

		if (player.body_phal)
		if (player.body_phal.cnt)
		{
			shadow.body_phal = spawn();
			shadow.body_phal.cnt = player.body_phal.cnt;
			shadow.body_phal.alpha = 0.0001;
		}
		
		if (player.prisonerlevel || player.handcuffed)
		{
			shadow.handcuffed = player.handcuffed;
			shadow.jailor = player.jailor;
			//print(shadow.jailor.netname, "JAILOR NAME\n");
			shadow.prisonerlevel = player.prisonerlevel;
			shadow.prison1spot = player.prison1spot;
			shadow.prison2spot = player.prison2spot;
			shadow.prison3spot = player.prison3spot;
			shadow.prison3angles = player.prison3angles;
			shadow.prison3ent = player.prison3ent;
			//shadow.team_forced = player.team_forced;
			shadow.team = player.team;
			
			if (player.handcuffed)
				player.jailor.jailee = world; //Be nice, If we come back we'll be jailed again.
		}
	}
}
/*
////////////////////////////////////////////////////////////////
//These routines ABOVE have to do with saving info about player
//so stoned players stay stoned when they reconnect
//
//END Client Remeber
////////////////////////////////////////////////////////////////
*/

/*
//////////////////////////////////////////////////////////////////////////////////////////////////
//START Client Remeber - Ownership Protection
//
//These routines BELOW have to do with the buildable building
//ownership protection feature (not used in teamgames - team owns there)
//////////////////////////////////////////////////////////////////////////////////////////////////
*/
float Client_checkCredentials (entity player, entity shadow)
{
	//Like checkFriends in miscfunctions.qc, leaves out some friend specific code however.
	if (shadow && shadow != world) {
		//Good
	} else {
		return FALSE;
	}
	
	float confidencelevel;
	confidencelevel = 0;
	
	if(player.crypto_keyfp) {
		if (shadow.svdstring2 == player.crypto_idfp) {
			dprint("player crypto_idfp matched, confidence level high\n");
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


void Client_Record_FindAndChange_ControlPoint_Owner (entity player, entity dummy)
{
	local entity efnd;
	local entity en;
	local entity oldother;
	
	efnd = findchainfloat(multitool_iscontrolpoint, 1);
        while(efnd)
        {
            if (efnd.realowner == player) {
		//Similar to (non team) multitool_controlpoint_touch code
		oldother = other;
		other = dummy;
	    	efnd.realowner = dummy;
		multitool_controlpoint_change(efnd.owner);
		other = oldother;
	    }
	    
            efnd = efnd.chain;
        }
}

void Client_Record_FindAndChange_Monster_Owner (entity player, entity dummy)
{
	local entity efnd;
	local entity en;
	local entity oldother;
	
	efnd = findchainfloat(monster_usedhousing, 1);
        while(efnd)
        {
            if (efnd.monster_owner == player) {
		//print("Found some monsters that need to change monster_owner\n");
	    	efnd.monster_owner = dummy;
	    }
	    
            efnd = efnd.chain;
        }
}

void Client_I_Remember_You_Ownership_Protection (entity player)
{
	local entity ec;
	local float confidencelevel;
	
	//Called on spawn after connect to see if we remember this player
	//And give him back his buildable buildings if we do
	
	if (teamplay)
		return;
		
	
	if (autocvar_g_ownership_protection)
	{
		if (autocvar_g_ownership_protection_level > 0) {
			confidencelevel = autocvar_g_ownership_protection_level;
		} else {
			confidencelevel = 1;
		}
	
		for(ec = findchain(classname, "dummy_bld_owner"); ec; ec = ec.chain)
		{
			if (Client_checkCredentials(player, ec) >= confidencelevel) {
				//print("\n\n\n\nFound a dummy\n\n\n\n");
				Client_Record_FindAndChange_ControlPoint_Owner(ec, player);
				Client_Record_FindAndChange_Monster_Owner(ec, player);
				remove_safely(ec); //Done so get rid of it
				return;
			}	
		}
	}
	
}

void Client_Record_Ownership_Protection (entity player)
{
	if (teamplay)
		return;
		
	//Called on disconnect to record ownership of buildable building control points
	if (autocvar_g_ownership_protection)
	{
		entity dummy;
		entity oldself;
		dummy = spawn();
		dummy.alpha = 0.0001;
		dummy.classname = "dummy_bld_owner";
		
		string m;
		m = strzone(player.crypto_idfp);
		dummy.svdstring2 = m; //Gotta do it this way because strings in QC are pointers, we are not pointing to this immutable string in m
		
		dummy.svdstring3 = strzone(player.netaddress);
		dummy.svdstring0 = strzone(player.netname);
		
		
		if (autocvar_g_allow_friends) {
			copyfriends(player, dummy);
			copytolerated(player, dummy);
			copyhated(player, dummy);
		}
		
		dummy.tolerateall = player.tolerateall;
		dummy.colormap = 1024; //White //Can't be player's color map as that is a pointer and another player might come on and take up the spot
		
		Client_Record_FindAndChange_ControlPoint_Owner(player, dummy);
		Client_Record_FindAndChange_Monster_Owner(player, dummy);
	}
}
/*
//////////////////////////////////////////////////////////////////////////////////////////////////
//These routines ABOVE have to do with the buildable building
//ownership protection feature
//
//END Client Remeber - Ownership Protection (not used in teamgames - team owns there, not player)
//////////////////////////////////////////////////////////////////////////////////////////////////
*/


float ClientData_Send(entity to, float sf)
{
	if(to != self.owner)
	{
		error("wtf");
		return FALSE;
	}

	entity e;

	e = to;
	if(to.classname == "spectator")
		e = to.enemy;

	sf = 0;

	if(e.race_completed)
		sf |= 1; // forced scoreboard
	if(to.spectatee_status)
		sf |= 2; // spectator ent number follows
	if(e.zoomstate)
		sf |= 4; // zoomed
	if(e.porto_v_angle_held)
		sf |= 8; // angles held

	WriteByte(MSG_ENTITY, ENT_CLIENT_CLIENTDATA);
	WriteByte(MSG_ENTITY, sf);

	if(sf & 2)
		WriteByte(MSG_ENTITY, to.spectatee_status);

	if(sf & 8)
	{
		WriteAngle(MSG_ENTITY, e.v_angle_x);
		WriteAngle(MSG_ENTITY, e.v_angle_y);
	}

	return TRUE;
}

void ClientData_Attach()
{
	Net_LinkEntity(self.clientdata = spawn(), FALSE, 0, ClientData_Send);
	self.clientdata.drawonlytoclient = self;
	self.clientdata.owner = self;
}

void ClientData_Detach()
{
	remove(self.clientdata);
	self.clientdata = world;
}

void ClientData_Touch(entity e)
{
	e.clientdata.SendFlags = 1;

	// make it spectatable
	entity e2;
	FOR_EACH_REALCLIENT(e2)
	{
		if(e2 != e)
			if(e2.classname == "spectator")
				if(e2.enemy == e)
					e2.clientdata.SendFlags = 1;
	}
}


.vector spawnpoint_score;
.string netname_previous;

void spawnfunc_info_player_survivor (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_start (void)
{
	spawnfunc_info_player_deathmatch();
}

void spawnfunc_info_player_deathmatch (void)
{
	self.classname = "info_player_deathmatch";
	relocate_spawnpoint();
}

void spawnpoint_use()
{
	if(teamplay)
	if(have_team_spawns > 0)
	{
		self.team = activator.team;
		some_spawn_has_been_used = 1;
	}
}

// Returns:
//   _x: prio (-1 if unusable)
//   _y: weight
vector Spawn_Score(entity spot, float mindist, float teamcheck)
{
	float shortest, thisdist;
	float prio;
	entity player;

	prio = 0;

	// filter out spots for the wrong team
	if(teamcheck >= 0)
		if(spot.team != teamcheck)
			return '-1 0 0';

	if(race_spawns)
		if(spot.target == "")
			return '-1 0 0';

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		if(spot.restriction == 1)
			return '-1 0 0';
	}
	else
	{
		if(spot.restriction == 2)
			return '-1 0 0';
	}
	
	//////////////////////////////////////////////////////////////////////////////////////
	//Filter out buildable building spots that don't allow other players
	//This is for spawnpoints in buildings that have been built with the multitool etc.
	//.cntrlowner is not set for spawnpoints in buildings in teamgames
	//_Not_ for map placed spawnpoints
	if(self != world) //Prob not necessary, but want to be careful as entity was not passed to this function, just implicit/global
	{
		if(spot.cntrlowner)
		if(spot.cntrlowner != world) //More or less redundant
		{
			if (autocvar_g_allow_spawnprefs && self.spawnpreferences == -1) {
					//print("We only like real map spawns\n");
				return '-1 0 0';
			}
			else if(spot.cntrlowner.realowner && spot.cntrlowner.realowner != world)
			{	
				//We're in someone's building
				if (self != spot.cntrlowner.realowner)
				{
					//We're not the owner
					if (autocvar_g_allow_friends) {
						if (autocvar_g_allow_spawnprefs
						 && (self.spawnpreferences < 2)
						 && (quickIsHatedOf(self, spot.cntrlowner.realowner)))
						{
							//preferences are less than "ANY"
							//And this is a spawnpoint owned by someone we hate
							//We are perhaps scared we'll be killed (maybe there is a reason
							//we put him on our hated list)
								//print("If we hate, we don't wish to spawn at his place either\n");
							return '-1 0 0';
						//Now to permissions owner of spawnpoint requires
						//More or less follows similar permissions to the monsters
						} else if (spot.cntrlowner.realowner.tolerateall >= 2) {
								//print("Everyone is loved\n");
							//LoveAll
							//All are permitted in
							//Do nothing
						} else if (spot.cntrlowner.realowner.tolerateall == -2) {
								//print("Everyone is hated\n");
							return '-1 0 0';
						} else if (quickIsHatedOf(spot.cntrlowner.realowner, self)) {
							//Those who are hated are not permitted spawnpoint, if not love all
							//Even if on friends list too
								//print("Is hated, no spot\n");
							return '-1 0 0';
						} else if not (quickIsFriendOf(spot.cntrlowner.realowner, self)) {
							//Not a friend? No spawn point
								//print("Is not friend, no spot\n");
							return '-1 0 0';
						}
					} else {
						return '-1 0 0';
					}
				}
			}
		}
	
		if (autocvar_g_allow_spawnprefs) {
			if (self.spawnpreferences == -1) {
				if(spot.spawnpointisofbuildable == 1) {
						//print("WE only like real map spawns\n");
					return '-1 0 0';
				}
			} else if (self.spawnpreferences == 4 && autocvar_g_allow_friends) {
				//We checked if allow friends, make sure of it ^^
				local float foundfriendspawn;
				foundfriendspawn = 0;
				////
				//Like abit below (self.spawnpreferences == 1), but we ONLY accept friends spawns
				//(Don't want our own spawns)
				////
				if (spot.cntrlowner && spot.cntrlowner.realowner) {
					if (self != spot.cntrlowner.realowner) {  //Looking for friends, not own
					if (spot.cntrlowner.realowner != world) {
					if (quickIsFriendOf(self, spot.cntrlowner.realowner)) {
					if (quickIsFriendOf(spot.cntrlowner.realowner, self)) {
						//Mutually friends of eachother
						//We're good, don't reject.
						//print("Found friend spawn\n");
						foundfriendspawn = 1;
					}
					}
					}
					}
				}
				
				if (!foundfriendspawn && (!spot.cntrlowner || !spot.cntrlowner.realowner ||
				(self == spot.cntrlowner.realowner))) //Our own spawns are no good either
				{
					//preferences are only our buildings
						//print("We only like our friends buildings\n");
					local float foundmine;
					local entity entmine;
					foundmine = 0;
					for(entmine = world; (entmine = find(entmine, classname, "info_player_deathmatch")); )
					{
						if (teamplay) {
							if(entmine.spawnpointisofbuildable == 1) {
								if (entmine.team == self.team) {
									foundmine++;
								}
							}
						} else {
								//Not self, but we also want spawns at friend's buildings?
								//Note: other player must have friended you too
								//Though above has allready may have been checked, we're going to make sure
								//As we don't want to spawn where the person doesn't consider
								//us a friend too, friendly bases only for this setting
								if(quickIsFriendOf(self, entmine.cntrlowner.realowner)) {
								if(quickIsFriendOf(entmine.cntrlowner.realowner, self)) {
									//Mutually friends of eachother
									//Don't want a spawn at base who isn't friendly
									//Found potential spawn so we can reject things
									if (quickIsHatedOf(entmine.cntrlowner.realowner, self)) {
										//Nope
									} else {
										foundmine++;
									}
								}
								}
						}
					}
					
					if (foundmine) {
						//Found 1 spot atleast, so we can reject without crashing
						if (teamplay) {
							if(spot.spawnpointisofbuildable) {
								//It is from a buildable
								//Maybe it is our team's?
								if(spot.team != self.team) {
									//No, then reject
									return '-1 0 0';	
								}
							} else {
								return '-1 0 0';
							}
						} else {
							return '-1 0 0';
						}
					}
				}
			} else if (self.spawnpreferences == 3 && autocvar_g_allow_friends) {
				local float foundfriendspawn;
				foundfriendspawn = 0;
				////
				//Like below (self.spawnpreferences == 1), but we also accept friends spawns
				////
				if (spot.cntrlowner && spot.cntrlowner.realowner) {
					if (self != spot.cntrlowner.realowner) { //Not looking for our own spawns for this
					if (spot.cntrlowner.realowner != world) {
					if (quickIsFriendOf(self, spot.cntrlowner.realowner)) {
					if (quickIsFriendOf(spot.cntrlowner.realowner, self)) {
						//Mutually friends of eachother
						//We're good, don't reject.
						//print("Found friend spawn A\n");
						foundfriendspawn = 1;
					}
					}
					}
					}
				}
				
				if (!foundfriendspawn && (!spot.cntrlowner || !spot.cntrlowner.realowner
				|| (self != spot.cntrlowner.realowner)))
				{
					//preferences are only our buildings
						//print("We only like our own buildings\n");
					local float foundmine;
					local entity entmine;
					foundmine = 0;
					for(entmine = world; (entmine = find(entmine, classname, "info_player_deathmatch")); )
					{
						if (teamplay) {
							if(entmine.spawnpointisofbuildable == 1) {
								if (entmine.team == self.team) {
									foundmine++;
								}
							}
						} else {
							if (entmine.cntrlowner.realowner == self) {
								foundmine++;
							} else {
								//Not self, but we also want spawns at friend's buildings?
								//Note: other player must have friended you too
								//Though above has allready may have been checked, we're going to make sure
								//As we don't want to spawn where the person doesn't consider
								//us a friend too, friendly bases only for this setting
								if(quickIsFriendOf(self, entmine.cntrlowner.realowner)) {
								if(quickIsFriendOf(entmine.cntrlowner.realowner, self)) {
									//Mutually friends of eachother
									//Don't want a spawn at base who isn't friendly
									//Found potential spawn so we can reject things
									if (quickIsHatedOf(entmine.cntrlowner.realowner, self)) {
										//Nope
									} else {
										foundmine++;
									}
								}
								}
							}
						}
					}
					
					if (foundmine) {
						//Found 1 spot atleast, so we can reject without crashing
						if (teamplay) {
							if(spot.spawnpointisofbuildable) {
								//It is from a buildable
								//Maybe it is our team's?
								if(spot.team != self.team) {
									//No, then reject
									return '-1 0 0';	
								}
							} else {
								return '-1 0 0';
							}
						} else {
							return '-1 0 0';
						}
					}
				}
			} else if (self.spawnpreferences == 1
			|| (self.spawnpreferences == 3 && !autocvar_g_allow_friends)
			|| (self.spawnpreferences == 4 && !autocvar_g_allow_friends)) {
				//If autocvar_g_allow_friends is disabled and we are set to spawn at friends or ours,
				//We use this as a fallback and spawn at ours if any
				////
				//For nonteamgames, player built spawns will have cntrlowner set
				//So if it isn't set then it isn't a player built building
				//And if the realowner of it isn't set to our player
				//then our player doesn't own it.
				//However for teamgames cntrlowner is not set
				//(As person may switch teams, so no reason to look at ctrlowner.realowner)
				//(The teamcolor of the spawn is set and reset on spawn and building capture)
				//So we have to check team of the spawnpoint itself
				//plus the .spawnpointisofbuildable flag
				//And can't just rely on lack of cntrlowner.realowner
				//NOTE: .cntrlowner was added SPECIFICALLY for this buildable building
				//spawn permissions code, so using it in this way is not improper.
				//The other code can be found in w_multitool.qc
				//It is not set in teamgames, but spawnpointisofbuildable is always set
				//for buildable building spawnpoints.
				////
				if (!spot.cntrlowner || !spot.cntrlowner.realowner
				|| (self != spot.cntrlowner.realowner))
				{
					//preferences are only our buildings
						//print("We only like our own buildings\n");
					local float foundmine;
					local entity entmine;
					foundmine = 0;
					for(entmine = world; (entmine = find(entmine, classname, "info_player_deathmatch")); )
					{
						if (teamplay) {
							if(entmine.spawnpointisofbuildable == 1) {
								if (entmine.team == self.team) {
									foundmine++;
								}
							}
						} else {
							if (entmine.cntrlowner.realowner == self) {
								//We are owner, so in code above,
								//even if we set ourselfs on the hated list
								//we still can spawn there
								foundmine++;
							}
						}
					}
					
					if (foundmine) {
						//Found 1 spot atleast, so we can reject without crashing
						if (teamplay) {
							if(spot.spawnpointisofbuildable) {
								//It is from a buildable
								//Maybe it is our team's?
								if(spot.team != self.team) {
									//No, then reject
									return '-1 0 0';	
								}
							} else {
								return '-1 0 0';
							}
						} else {
							return '-1 0 0';
						}
					}
				}
			}
		}
	}
	//////////////////////////////////////////////////////////////////////////////////////

	shortest = vlen(world.maxs - world.mins);
	FOR_EACH_PLAYER(player) if (player != self)
	{
		thisdist = vlen(player.origin - spot.origin);
		if (thisdist < shortest)
			shortest = thisdist;
	}
	if(shortest > mindist)
		prio += SPAWN_PRIO_GOOD_DISTANCE;

	spawn_score = prio * '1 0 0' + shortest * '0 1 0';
	spawn_spot = spot;

	// filter out spots for assault
	if(spot.target != "") {
		entity ent;
		float found;

		found = 0;
		for(ent = world; (ent = find(ent, targetname, spot.target)); )
		{
			++found;
			if(ent.spawn_evalfunc)
			{
				entity oldself = self;
				self = ent;
				spawn_score = ent.spawn_evalfunc(oldself, spot, spawn_score);
				self = oldself;
				if(spawn_score_x < 0)
					return spawn_score;
			}
		}

		if(!found)
		{
			dprint("WARNING: spawnpoint at ", vtos(spot.origin), " could not find its target ", spot.target, "\n");
			return '-1 0 0';
		}
	}

	MUTATOR_CALLHOOK(Spawn_Score);
	return spawn_score;
}

void Spawn_ScoreAll(entity firstspot, float mindist, float teamcheck)
{
	entity spot;
	for(spot = firstspot; spot; spot = spot.chain)
		spot.spawnpoint_score = Spawn_Score(spot, mindist, teamcheck);
}

entity Spawn_FilterOutBadSpots(entity firstspot, float mindist, float teamcheck)
{
	entity spot, spotlist, spotlistend;

	spotlist = world;
	spotlistend = world;

	Spawn_ScoreAll(firstspot, mindist, teamcheck);

	for(spot = firstspot; spot; spot = spot.chain)
	{
		if(spot.spawnpoint_score_x >= 0) // spawning allowed here
		{
			if(spotlistend)
				spotlistend.chain = spot;
			spotlistend = spot;
			if(!spotlist)
				spotlist = spot;
		}
	}
	if(spotlistend)
		spotlistend.chain = world;

	return spotlist;
}

entity Spawn_WeightedPoint(entity firstspot, float lower, float upper, float exponent)
{
	// weight of a point: bound(lower, mindisttoplayer, upper)^exponent
	// multiplied by spot.cnt (useful if you distribute many spawnpoints in a small area)
	entity spot;

	RandomSelection_Init();
	for(spot = firstspot; spot; spot = spot.chain)
		RandomSelection_Add(spot, 0, string_null, pow(bound(lower, spot.spawnpoint_score_y, upper), exponent) * spot.cnt, (spot.spawnpoint_score_y >= lower) * 0.5 + spot.spawnpoint_score_x);

	return RandomSelection_chosen_ent;
}

/*
=============
SelectSpawnPoint

Finds a point to respawn
=============
*/
entity SelectSpawnPoint (float anypoint)
{
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
	firstspot = findchain(classname, "info_player_deathmatch");
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
	
	if (!spot && self.spawnpreferences)
	{
		local float oldspawnprefs;
		oldspawnprefs = self.spawnpreferences;
		
		self.spawnpreferences = 0;
		
		print("No spawn, but spawnprefs is set, so trying again without to avoid error and program termination\n");
		spot = SelectSpawnPoint (anypoint);
		
		self.spawnpreferences = oldspawnprefs;
	}
	
	if (!spot)
	{
		spot = failsafespawns_give(self);
	}
	
	if (!spot)
	{
		if (autocvar_spawn_createifnone) {
			//We stare into the Abyss
			//Does it stare back?
			//(Last chance at not crashing or map change via error)
			spot = failsafespawn_create(self);
			if (!spot) {
				spot = failsafespawn_create_ignoreteam(self);
			}
			
			if (!spot) {
				spot = failsafespawn_createsimple(self);
			}
			
			//Map must have nothing if we've got here, no items, nothing!
			if (!spot) {
				spot = failsafespawn_create_barren(self);
			}
			
			if (!spot) {
				spot = failsafespawn_create_ignoreteam_barren(self);
			}
			
			if (!spot) {
				spot = failsafespawn_createsimple_barren(self);
			}
		}
	}

	if (!spot)
	{
		if(autocvar_spawn_debug)
			GotoNextMap(0);
		else
		{
			if(some_spawn_has_been_used)
				return world; // team can't spawn any more, because of actions of other team
			else
				error("Cannot find a spawn point - please fix the map!");
		}
	}

	return spot;
}

/*
=============
CheckPlayerModel

Checks if the argument string can be a valid playermodel.
Returns a valid one in doubt.
=============
*/
string FallbackPlayerModel;
string CheckPlayerModel(string plyermodel) {
	if(FallbackPlayerModel != cvar_defstring("_cl_playermodel"))
	{
		// note: we cannot summon Don Strunzone here, some player may
		// still have the model string set. In case anyone manages how
		// to change a cvar default, we'll have a small leak here.
		FallbackPlayerModel = strzone(cvar_defstring("_cl_playermodel"));
	}
	// only in right path
	if( substring(plyermodel,0,14) != "models/player/")
		return FallbackPlayerModel;
	// only good file extensions
	if(substring(plyermodel,-4,4) != ".zym")
	if(substring(plyermodel,-4,4) != ".dpm")
	if(substring(plyermodel,-4,4) != ".iqm")
	if(substring(plyermodel,-4,4) != ".md3")
	if(substring(plyermodel,-4,4) != ".psk")
		return FallbackPlayerModel;
	// forbid the LOD models
	if(substring(plyermodel, -9,5) == "_lod1")
		return FallbackPlayerModel;
	if(substring(plyermodel, -9,5) == "_lod2")
		return FallbackPlayerModel;
	if(plyermodel != strtolower(plyermodel))
		return FallbackPlayerModel;
	// also, restrict to server models
	if(autocvar_sv_servermodelsonly)
	{
		if(!fexists(plyermodel))
			return FallbackPlayerModel;
	}
	return plyermodel;
}

void setplayermodel(entity e, string modelname)
{
	precache_model(modelname);
	setmodel(e, modelname);
	player_setupanimsformodel();
	UpdatePlayerSounds();
}

/*
=============
PutObserverInServer

putting a client as observer in the server
=============
*/
void FixPlayermodel();
void PutObserverInServer (void)
{
	entity	spot;
    self.hud = HUD_NORMAL;
	race_PreSpawnObserver();
	
	if (autocvar_g_questspawns && autocvar_g_questspawns_botsusemapspawns
	&& (clienttype(self) == CLIENTTYPE_BOT)) {
		spot = questspawns_SelectBotOnlySpawnPoint (TRUE);
	} else {
		spot = SelectSpawnPoint (TRUE);
	}
	
	if(!spot)
		error("No spawnpoints for observers?!?\n");
	RemoveGrapplingHook(self); // Wazat's Grappling Hook

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}

	ExtinguishTorchlightForWarpzone(self);
	TurnOffFlashlightlightForWarpzone(self);
	DropAllRunes(self);
	MUTATOR_CALLHOOK(MakePlayerObserver);

	minstagib_stop_countdown(self);

	Portal_ClearAll(self);

	if(self.alivetime)
	{
		PlayerStats_Event(self, PLAYERSTATS_ALIVETIME, time - self.alivetime);
		self.alivetime = 0;
	}

	if(self.vehicle)
		vehicles_exit(VHEF_RELESE);	    

	WaypointSprite_PlayerDead();

	if not(g_ca)  // don't reset teams when moving a ca player to the spectators
		self.team = -1;  // move this as it is needed to log the player spectating in eventlog

	if(self.killcount != -666) {
		if(g_lms) {
			if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0)
				bprint ("^4", self.netname, "^4 has no more lives left\n");
			else
				bprint ("^4", self.netname, "^4 is spectating now\n"); // TODO turn this into a proper forfeit?
		} else
			bprint ("^4", self.netname, "^4 is spectating now\n");

		if(self.just_joined == FALSE) {
			LogTeamchange(self.playerid, -1, 4);
		} else
			self.just_joined = FALSE;
	}

	PlayerScore_Clear(self); // clear scores when needed

	accuracy_resend(self);

	self.spectatortime = time;
	
	self.classname = "observer";
	self.iscreature = FALSE;
	self.teleportable = TELEPORT_SIMPLE;
	self.damagedbycontents = FALSE;
	self.health = -666;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY_WORLDONLY; // user preference is controlled by playerprethink
	self.flags = FL_CLIENT | FL_NOTARGET;
	self.armorvalue = 666;
	self.effects = 0;
	self.armorvalue = autocvar_g_balance_armor_start;
	self.pauserotarmor_finished = 0;
	self.pauserotmana_finished = 0;
	self.pauserothealth_finished = 0;
	self.pauseregen_finished = 0;
	self.damageforcescale = 0;
	self.death_time = 0;
	self.respawn_time = 0;
	self.alpha = 0;
	self.scale = 0;
	self.fade_time = 0;
	self.pain_frame = 0;
	self.pain_finished = 0;
	self.strength_finished = 0;
	self.invincible_finished = 0;
	self.superweapons_finished = 0;
	self.pushltime = 0;
	self.istypefrag = 0;
	self.think = func_null;
	self.nextthink = 0;
	self.hook_time = 0;
	self.runes = 0;
	self.deadflag = DEAD_NO;
	self.angles = spot.angles;
	self.angles_z = 0;
	self.fixangle = TRUE;
	self.crouch = FALSE;

	//////setorigin (self, (spot.origin + PL_VIEW_OFS)); // offset it so that the spectator spawns higher off the ground, looks better this way
	//////yea and it crashes clients if view is now in solid brush and there are many warpzones to render suddenly in the "out of area" of the map that is now visible
	setorigin (self, spot.origin);
	self.prevorigin = self.origin;
	self.items = 0;
	WEPSET_CLEAR_E(self);
	self.model = "";
	FixPlayermodel();
	setmodel(self, "null");
	self.drawonlytoclient = self;

	setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX); // give the spectator some space between walls for MOVETYPE_FLY_WORLDONLY
	self.view_ofs = '0 0 0'; // so that your view doesn't go into the ceiling with MOVETYPE_FLY_WORLDONLY, previously "PL_VIEW_OFS"

	self.weapon = 0;
	self.weaponname = "";
	self.switchingweapon = 0;
	self.weaponmodel = "";
	self.weaponentity = world;
	self.exteriorweaponentity = world;
	self.killcount = -666;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.punchangle = '0 0 0';
	self.punchvector = '0 0 0';
	self.oldvelocity = self.velocity;
	self.fire_endtime = -1;

	if(g_arena)
	{
		if(self.version_mismatch)
		{
			Spawnqueue_Unmark(self);
			Spawnqueue_Remove(self);
		}
		else
		{
			Spawnqueue_Insert(self);
		}
	}
	else if(g_lms)
	{
		// Only if the player cannot play at all
		if(PlayerScore_Add(self, SP_LMS_RANK, 0) == 666)
			self.frags = FRAGS_SPECTATOR;
		else
			self.frags = FRAGS_LMS_LOSER;
	}
	else if(g_ca)
	{
		if(self.caplayer)
			self.frags = FRAGS_LMS_LOSER;
		else
			self.frags = FRAGS_SPECTATOR;
	}
	else
		self.frags = FRAGS_SPECTATOR;
}

void SetItSkinIfAble (entity player); //def for body part attachment subroutine. Declared as it is referenced below
void RemoveItIfNeeded (entity player); //def for body part attachment subroutine Declared as it is referenced below

.float model_randomizer;
void FixPlayermodel()
{
	string defaultmodel;
	float defaultskin, chmdl, oldskin, n, i;
	vector m1, m2;

	defaultmodel = "";
	defaultskin = 0;
	chmdl = FALSE;

	if(autocvar_sv_defaultcharacter == 1)
	{
		if(teamplay)
		{
			string s;
			s = Team_ColorNameLowerCase(self.team);
			if(s != "neutral")
			{
				defaultmodel = cvar_string(strcat("sv_defaultplayermodel_", s));
				defaultskin = cvar(strcat("sv_defaultplayerskin_", s));
			}
		}

		if(defaultmodel == "")
		{
			defaultmodel = autocvar_sv_defaultplayermodel;
			defaultskin = autocvar_sv_defaultplayerskin;
		}

		n = tokenize_console(defaultmodel);
		if(n > 0)
			defaultmodel = argv(floor(n * self.model_randomizer));

		i = strstrofs(defaultmodel, ":", 0);
		if(i >= 0)
		{
			defaultskin = stof(substring(defaultmodel, i+1, -1));
			defaultmodel = substring(defaultmodel, 0, i);
		}
	}

	if(defaultmodel != "")
	{
		if (defaultmodel != self.model)
		{
			m1 = self.mins;
			m2 = self.maxs;
			setplayermodel (self, defaultmodel);
			setsize (self, m1, m2);
			chmdl = TRUE;
		}

		oldskin = self.skin;
		self.skin = defaultskin;
	} else {
		if (self.playermodel != self.model || self.playermodel == "")
		{
			self.playermodel = CheckPlayerModel(self.playermodel); // this is never "", so no endless loop
			m1 = self.mins;
			m2 = self.maxs;
			setplayermodel (self, self.playermodel);
			setsize (self, m1, m2);
			chmdl = TRUE;
		}

		oldskin = self.skin;
		if (self.stoned)
		{
			self.skin = self.stoneskin; //If we have been turned to stone
			self.animstate_numframes = 2; //If it's less than 2 it animates regular
			self.animstate_framerate = 0.0001; //Has to be something, otherwise it animates regular
			self.animstate_override = 1;
			self.animstate_looping = 1;
		}
		else 
			self.skin = stof(self.playerskin);
	}

	if(chmdl || oldskin != self.skin)
	{
		self.species = player_getspecies(); // model or skin has changed
		self.skincolor = player_getskincolor();
		self.sex = player_getsex();
		self.age = player_getage();
		self.plweight = player_getweight();
		
		//Some applicable models have different bone settings, so do this
		if (self.body_phal)
		if (self.body_phal.alpha == 1)
		{
			float tempcnt;
			tempcnt = self.body_phal.cnt;
			PutItBackIfAble(self);
			WhipItOutIfAble(self);
			self.body_phal.cnt = tempcnt;
			ErectItIfSet(self);
		}
		
		self.getbone_phal = player_getbone_phal();
		RemoveItIfNeeded(self); //Removes a body part if inapplicable to new model
		if (!self.stoned) SetItSkinIfAble(self); //Sets proper skin for part
		if (!self.stoned || chmdl)
			self.stoneskin = player_getstoneskin();
	}

	if(!teamplay) {
		if(strlen(autocvar_sv_defaultplayercolors)) {
		
			if(self.clientcolors != stof(autocvar_sv_defaultplayercolors))
				setcolor(self, stof(autocvar_sv_defaultplayercolors));
		
		} else if (autocvar_sv_autoplayercolors) {
			if (self.autoclientcolorset) {
				setcolor(self, 16*self.autoclientcolorshirt + self.autoclientcolorpants);
			} else {
				print("\n...\n........CHOOOSING Pants/Shirt COLOR.........\n...\n");
				autoplayercolors_choose(self);
				setcolor(self, 16*self.autoclientcolorshirt + self.autoclientcolorpants);
			}
		}
	}
}

void PlayerTouchExplode(entity p1, entity p2)
{
	vector org;
	org = (p1.origin + p2.origin) * 0.5;
	org_z += (p1.mins_z + p2.mins_z) * 0.5;

	te_explosion(org);

	entity e;
	e = spawn();
	setorigin(e, org);
	RadiusDamage(e, world, g_touchexplode_damage, g_touchexplode_edgedamage, g_touchexplode_radius, world, g_touchexplode_force, DEATH_TOUCHEXPLODE, world);
	remove(e);
}


void PCIS_givespells(entity player, float myteamplay, float myteamoverrides) {
			if (myteamplay && myteamoverrides != 2) {
				if (myteamoverrides == 1) {
					//Nothing Given Till teams
				} else {
					GiveStartSpells(player);
				}
				if (player.team == COLOR_TEAM1)
					GiveStartSpells_team1(player);	
				else if (player.team == COLOR_TEAM2)
					GiveStartSpells_team2(player);
				else if (player.team == COLOR_TEAM3)
					GiveStartSpells_team3(player);
				else if (player.team == COLOR_TEAM4)
					GiveStartSpells_team4(player);
			} else {
				GiveStartSpells(player);
			}
}

/*
=============
PutClientInServer

Called when a client spawns in the server
=============
*/

void PutClientInServer (void)
{
	local float doteamoverrides;
	local float dodelaygivespells;
	 doteamoverrides = 0;
	 dodelaygivespells = 0;
	  
	self.bodycoretemp = 37; //in degrees C
	self.nextbodycoretempadjust = time + 20;
	self.wasinfilthliquidlastmetabolize = 0;
	self.vuln_movement_imparable = 1;
	float disconnectedprisoner; //Movement can be impared by melee weapon / arrow damage to the lowerbody/legs
	disconnectedprisoner = 0;
	disconnectedprisoner = Client_I_Remember_You(self);
	Client_I_Remember_You_Ownership_Protection(self);
	reinsertFriend(self); //Reinsert friend into friends lists if cryptoid matches
	reinsertExFriend(self); //Reinsert exfriend into exfriends lists if cryptoid matches
	reinsertTolerated(self); //Reinsert tolerated into tolerated lists if cryptoid matches
	reinsertHated(self);
	reinsertExHated(self);
	
	if(clienttype(self) == CLIENTTYPE_BOT)
	{
		self.classname = "player";
		if(g_ca)
			self.caplayer = 1;
	}
	else if(clienttype(self) == CLIENTTYPE_REAL)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_SETVIEW);
		WriteEntity(MSG_ONE, self);
	}

	// reset player keys
	self.itemkeys = 0;

	// player is dead and becomes observer
	// FIXME fix LMS scoring for new system
	if(g_lms)
	{
		if(PlayerScore_Add(self, SP_LMS_RANK, 0) > 0)
			self.classname = "observer";
	}

	if((g_arena && !self.spawned) || (g_ca && !allowed_to_spawn))
		self.classname = "observer";

	if(gameover)
		self.classname = "observer";
		
	if(autocvar_g_maxlives) {
		if(self.numhasdied >= autocvar_g_maxlives) {
			if(clienttype(self) == CLIENTTYPE_BOT && autocvar_g_maxlives_ignorebots) {
				//Carry on
			} else {
				self.classname = "observer";
			}
		}
	}

	if(self.classname == "player" && (!g_ca || (g_ca && allowed_to_spawn))) {
		entity spot, oldself;
		float j;

		accuracy_resend(self);

		if(self.team < 0)
			JoinBestTeam(self, FALSE, TRUE);

		race_PreSpawn();
		
		if (autocvar_g_questspawns && autocvar_g_questspawns_botsusemapspawns
		&& (clienttype(self) == CLIENTTYPE_BOT)) {
			spot = questspawns_SelectBotOnlySpawnPoint (FALSE);
		} else {
			spot = SelectSpawnPoint (FALSE);
		}
		
		if(!spot)
		{
			centerprint(self, "Sorry, no spawnpoints available!\nHope your team can fix it...");
			return; // spawn failed
		}

		RemoveGrapplingHook(self); // Wazat's Grappling Hook
		
		if not(disconnectedprisoner)
		{
			self.handcuffed = 0;
			if (self.prisonerlevel == 1) self.prisonerlevel = 0;
			if (self.jailee != world)
			{
				self.jailee.jailor = world;
				self.jailee = world;
			}
		}
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
		self.timesinkfalldamageaccelprotection = 0;
		self.tempdisorientated = 0;
		if (!self.permblinded) {
			self.stat_blinded = 0;
		} else {
			self.stat_blinded = 101;
		}
		self.darkritual_mana_max = 0;
		self.darkritual_mana_stable = 0;
		self.hasmanashield = 0;
		self.hascastfromlife = 0;
		self.hasclairvoyance = 0;
		self.tempmangled_l = 0;
		self.tempmangled_r = 0;
		multitool_setstartcastlecolormaybe(self); //for applying g_suggested_multitool_castlecolor
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
		ZeroOutMagicInventory(self);
		if (autocvar_sv_player_maxinventory) {
			self.iscontainer_storage = autocvar_sv_player_maxinventory;
		} else {
			self.iscontainer_storage = 0;
		}
		RemoveStartSpells(self);
		self.stat_bangflash = 0;
		self.classname = "player";
		self.wasplayer = TRUE;
		self.iscreature = TRUE;
		self.teleportable = TELEPORT_NORMAL;
		self.damagedbycontents = TRUE;
		self.movetype = MOVETYPE_WALK;
		self.solid = SOLID_SLIDEBOX;
		self.dphitcontentsmask = DPCONTENTS_BODY | DPCONTENTS_SOLID;
		if(autocvar_g_playerclip_collisions)
			self.dphitcontentsmask |= DPCONTENTS_PLAYERCLIP;
		if(clienttype(self) == CLIENTTYPE_BOT && autocvar_g_botclip_collisions)
			self.dphitcontentsmask |= DPCONTENTS_BOTCLIP;
		self.frags = FRAGS_PLAYER;
		if(INDEPENDENT_PLAYERS)
			MAKE_INDEPENDENT_PLAYER(self);
		self.flags = FL_CLIENT;
		if(autocvar__notarget)
			self.flags |= FL_NOTARGET;
		self.takedamage = DAMAGE_AIM;
		if(g_minstagib)
			self.effects = EF_FULLBRIGHT;
		else
			self.effects = 0;
		self.effects |= EF_TELEPORT_BIT | EF_RESTARTANIM_BIT;
		self.air_finished = time + 12;
		self.dmg = 2;
		if(autocvar_g_balance_nex_charge)
		{
			if(autocvar_g_balance_nex_secondary_chargepool)
				self.nex_chargepool_ammo = 1;
			self.nex_charge = autocvar_g_balance_nex_charge_start;
		}
		
		//Playerclass give weapon and/or ammo?
		float pcgiveweaps, pcgiveammo;
		pcgiveweaps = 0;
		pcgiveammo = 0;
		//Set below

		if((self.prisonerlevel > 1 || self.handcuffed)
		|| ((autocvar_g_startobjectsonlyonce)
			&& ((self.numhasdied >= autocvar_g_startobjectsonlyonce)
			&& (!autocvar_g_startobjectsonlyonce_excludeweapsonly)
			&& (!(clienttype(self) == CLIENTTYPE_BOT && autocvar_g_startobjectsonlyonce_ignorebots)))
			)
		)
		{
			//Start without if prisoner.
			self.ammo_shells = 0;
			self.ammo_shells = 0;
			self.ammo_nails = 0;
			self.ammo_rockets = 0;
			self.ammo_cells = 0;
			self.ammo_fuel = 0;
			self.health = start_health;
				if (self.health > 0 && self.health_stable_reduce > 0) {
					if (autocvar_sv_gameplayfix_health_stable_reduce_noprotect) {
						self.health = self.health - self.health_stable_reduce;
					} else {
						if (self.health_stable_reduce >= start_health) {
							self.health = 1; 
						} else {
							self.health = self.health - self.health_stable_reduce;
						}
					
					}
					
					if (self.health < 0) {
						self.health = 0;
					}
				}
			self.armorvalue = 0;
			self.mana = start_mana;
				if (self.mana > 0 && self.mana_stable_reduce > 0) {
					self.mana = self.mana - self.mana_stable_reduce;
					if (self.mana < 0) {
						self.mana = 0;
					}
				}
			self.grenades = 0;
			self.flashbangs = 0;
			self.smokenades = 0;
			self.fragnades = 0;
			self.atmines = 0;
			self.landmines = 0;
			WEPSET_CLEAR_E(self);
		}
		else if(inWarmupStage)
		{
			self.ammo_shells = warmup_start_ammo_shells;
			self.ammo_nails = warmup_start_ammo_nails;
			self.ammo_rockets = warmup_start_ammo_rockets;
			self.ammo_cells = warmup_start_ammo_cells;
			self.ammo_fuel = warmup_start_ammo_fuel;
			self.health = warmup_start_health;
				if (self.health > 0 && self.health_stable_reduce > 0) {
					if (autocvar_sv_gameplayfix_health_stable_reduce_noprotect) {
						self.health = self.health - self.health_stable_reduce;
					} else {
						if (self.health_stable_reduce >= start_health) {
							self.health = 1; 
						} else {
							self.health = self.health - self.health_stable_reduce;
						}
					
					}
					
					if (self.health < 0) {
						self.health = 0;
					}
				}
			self.armorvalue = warmup_start_armorvalue;
				if (self.armorvalue > 0 && self.armor_stable_reduce > 0) {
					self.armorvalue = self.armorvalue - self.armor_stable_reduce;
					if (self.armorvalue < 0) {
						self.armorvalue = 0;
					}
				}
			self.mana = warmup_start_mana;
				if (self.mana > 0 && self.mana_stable_reduce > 0) {
					self.mana = self.mana - self.mana_stable_reduce;
					if (self.mana < 0) {
						self.mana = 0;
					}
				}
			self.grenades = warmup_start_grenades;
			self.flashbangs = warmup_start_flashbangs;
			self.smokenades = warmup_start_smokenades;
			self.fragnades = warmup_start_fragnades;
			self.atmines = warmup_start_atmines;
			self.landmines = warmup_start_landmines;
			WEPSET_COPY_EA(self, warmup_start_weapons);
		}
		else
		{
			//Bots using playerclasses
			if (g_playerclass) {
			  if (clienttype(self) == CLIENTTYPE_BOT) {
			    if not(self.playerclass_desired) {
			      if not(autocvar_g_playerclass_nobots) {
				float mypcrand;
				mypcrand = random()*12;
				
				if (mypcrand < 1 && autocvar_g_playerclass_enable_longdistance) 
					self.playerclass_desired = PLAYERCLASS_LONGDISTANCE;
				else if (mypcrand < 2 && autocvar_g_playerclass_enable_marksman) 
					self.playerclass_desired = PLAYERCLASS_MARKSMAN;
				else if (mypcrand < 3 && autocvar_g_playerclass_enable_mediumdistance) 
					self.playerclass_desired = PLAYERCLASS_MEDIUMDISTANCE;
				else if (mypcrand < 4 && autocvar_g_playerclass_enable_assault) 
					self.playerclass_desired = PLAYERCLASS_ASSAULT;
				else if (mypcrand < 5 && autocvar_g_playerclass_enable_closerange) 
					self.playerclass_desired = PLAYERCLASS_CLOSERANGE;
				else if (mypcrand < 6 && autocvar_g_playerclass_enable_destructive) 
					self.playerclass_desired = PLAYERCLASS_DESTRUCTIVE;
				else if (mypcrand < 7 && autocvar_g_playerclass_enable_heavyweapons) 
					self.playerclass_desired = PLAYERCLASS_HEAVYWEAPONS;
				else if (mypcrand < 8 && autocvar_g_playerclass_enable_pyromaniac) 
					self.playerclass_desired = PLAYERCLASS_PYROMANIAC;
				else if (mypcrand < 9 && autocvar_g_playerclass_enable_engineer) 
					self.playerclass_desired = PLAYERCLASS_ENGINEER;
				else if (mypcrand < 10 && autocvar_g_playerclass_enable_worker) 
					self.playerclass_desired = PLAYERCLASS_WORKER;
				else if (mypcrand < 11 && autocvar_g_playerclass_enable_healer) 
					self.playerclass_desired = PLAYERCLASS_HEALER;
				else 
					self.playerclass_desired = -2; //So we don't come back here
				
			     }
			    }
			  }
			}
			//EndBots using playerclasses
			
			self.ammo_shells = start_ammo_shells;
			self.ammo_nails = start_ammo_nails;
			self.ammo_rockets = start_ammo_rockets;
			self.ammo_cells = start_ammo_cells;
			self.ammo_fuel = start_ammo_fuel;
			self.health = start_health;
				if (self.health > 0 && self.health_stable_reduce > 0) {
					if (autocvar_sv_gameplayfix_health_stable_reduce_noprotect) {
						self.health = self.health - self.health_stable_reduce;
					} else {
						if (self.health_stable_reduce >= start_health) {
							self.health = 1; 
						} else {
							self.health = self.health - self.health_stable_reduce;
						}
					
					}
					
					if (self.health < 0) {
						self.health = 0;
					}
				}
			self.armorvalue = start_armorvalue;
				if (self.armorvalue > 0 && self.armor_stable_reduce > 0) {
					self.armorvalue = self.armorvalue - self.armor_stable_reduce;
					if (self.armorvalue < 0) {
						self.armorvalue = 0;
					}
				}
			self.mana = start_mana;
				if (self.mana > 0 && self.mana_stable_reduce > 0) {
					self.mana = self.mana - self.mana_stable_reduce;
					if (self.mana < 0) {
						self.mana = 0;
					}
				}
			
			//Chaos-esque addition
			float teamoverrides;
			teamoverrides = cvar("g_start_weapon_teamoverrides");
			
			doteamoverrides = teamoverrides;
			
			if (clienttype(self) == CLIENTTYPE_BOT && (autocvar_bot_start_unarmed == 2)) {
				//NoWeaps
				WEPSET_CLEAR_E(self);
					//print (autocvar_bot_start_unarmed_inventory," :: bot starting with\n");
				GiveItems(self, 0, tokenize_console(autocvar_bot_start_unarmed_inventory));
			} else if (clienttype(self) == CLIENTTYPE_BOT && autocvar_bot_start_unarmed) {
				//NoWeaps
				WEPSET_CLEAR_E(self);
			} else if((autocvar_g_startobjectsonlyonce)
			&& ((self.numhasdied >= autocvar_g_startobjectsonlyonce)
			&& (autocvar_g_startobjectsonlyonce_excludeweapsonly)
			&& (!(clienttype(self) == CLIENTTYPE_BOT && autocvar_g_startobjectsonlyonce_ignorebots))
			))
			{
				//NoWeaps
				WEPSET_CLEAR_E(self);
			} else {
			  ////StartWeaponStuff////
			  WEPSET_COPY_EA(self, start_weapons);
			  if (g_ca) {
			  	//start_weapons is what we want
			  } else if (teamplay && teamoverrides != 2) {
				if (self.team == COLOR_TEAM1)
					WEPSET_COPY_EA(self, start_weapons_team1);	
				else if (self.team == COLOR_TEAM2)
					WEPSET_COPY_EA(self, start_weapons_team2);
				else if (self.team == COLOR_TEAM3)
					WEPSET_COPY_EA(self, start_weapons_team3);
				else if (self.team == COLOR_TEAM4)
					WEPSET_COPY_EA(self, start_weapons_team4);
			  }
			  ////EndWeaponStuff////
			  pcgiveweaps = 1; //Will give player class weapons
			}
			
			pcgiveammo = 1;  //Will give player class ammo

			
			//Spells
			if (g_playerclass) {
				//We have to delay giving spells if using playerclasses 
				//untill after the playerclass code is run
				//due to the ability to give and take depending on class
				dodelaygivespells = 1;
			} else {
				PCIS_givespells(self, teamplay, teamoverrides);
			}
			
			//Grenades
			if (teamplay && teamoverrides != 2) {
				if (teamoverrides == 1) {
					self.grenades = 0;
					self.flashbangs = 0;
					self.smokenades = 0;
					self.fragnades = 0;
					self.atmines = 0;
					self.landmines = 0;
				} else {
					self.grenades = start_grenades;
					self.flashbangs = start_flashbangs;
					self.smokenades = start_smokenades;
					self.fragnades = start_fragnades;
					self.atmines = start_atmines;
					self.landmines = start_landmines;
				}
				
				if (self.team == COLOR_TEAM1)
					self.grenades = self.grenades + start_grenades_team1;
				else if (self.team == COLOR_TEAM2)
					self.grenades = self.grenades + start_grenades_team2;
				else if (self.team == COLOR_TEAM3)
					self.grenades = self.grenades + start_grenades_team3;
				else if (self.team == COLOR_TEAM4)
					self.grenades = self.grenades + start_grenades_team4;
					
				if (self.team == COLOR_TEAM1)
					self.flashbangs = self.flashbangs + start_flashbangs_team1;
				else if (self.team == COLOR_TEAM2)
					self.flashbangs = self.flashbangs + start_flashbangs_team2;
				else if (self.team == COLOR_TEAM3)
					self.flashbangs = self.flashbangs + start_flashbangs_team3;
				else if (self.team == COLOR_TEAM4)
					self.flashbangs = self.flashbangs + start_flashbangs_team4;
					
				if (self.team == COLOR_TEAM1)
					self.smokenades = self.smokenades + start_smokenades_team1;
				else if (self.team == COLOR_TEAM2)
					self.smokenades = self.smokenades + start_smokenades_team2;
				else if (self.team == COLOR_TEAM3)
					self.smokenades = self.smokenades + start_smokenades_team3;
				else if (self.team == COLOR_TEAM4)
					self.smokenades = self.smokenades + start_smokenades_team4;
					
				if (self.team == COLOR_TEAM1)
					self.fragnades = self.fragnades + start_fragnades_team1;
				else if (self.team == COLOR_TEAM2)
					self.fragnades = self.fragnades + start_fragnades_team2;
				else if (self.team == COLOR_TEAM3)
					self.fragnades = self.fragnades + start_fragnades_team3;
				else if (self.team == COLOR_TEAM4)
					self.fragnades = self.fragnades + start_fragnades_team4;
				
				if (self.team == COLOR_TEAM1)
					self.atmines = self.atmines + start_atmines_team1;
				else if (self.team == COLOR_TEAM2)
					self.atmines = self.atmines + start_atmines_team2;
				else if (self.team == COLOR_TEAM3)
					self.atmines = self.atmines + start_atmines_team3;
				else if (self.team == COLOR_TEAM4)
					self.atmines = self.atmines + start_atmines_team4;
					
				if (self.team == COLOR_TEAM1)
					self.landmines = self.landmines + start_landmines_team1;
				else if (self.team == COLOR_TEAM2)
					self.landmines = self.landmines + start_landmines_team2;
				else if (self.team == COLOR_TEAM3)
					self.landmines = self.landmines + start_landmines_team3;
				else if (self.team == COLOR_TEAM4)
					self.landmines = self.landmines + start_landmines_team4;
			} else {
				self.grenades = start_grenades;
				self.flashbangs = start_flashbangs;
				self.smokenades = start_smokenades;
				self.fragnades = start_fragnades;
				self.atmines = start_atmines;
				self.landmines = start_landmines;
			}
			//End Chaos-esque addition
		}

		if(WEPSET_CONTAINS_ANY_EA(self, WEPBIT_SUPERWEAPONS)) // exception for minstagib, as minstanex is a superweapon
			self.superweapons_finished = time + autocvar_g_balance_superweapons_time;
		else
			self.superweapons_finished = 0;

		if(g_weaponarena_random)
		{
			if(g_weaponarena_random_with_laser)
				WEPSET_ANDNOT_EW(self, WEP_LASER);
			W_RandomWeapons(self, g_weaponarena_random);
			if(g_weaponarena_random_with_laser)
				WEPSET_OR_EW(self, WEP_LASER);
		}

		self.items = start_items;

		self.spawnshieldtime = time + autocvar_g_spawnshieldtime;
		self.pauserotarmor_finished = time + autocvar_g_balance_pause_armor_rot_spawn;
		self.pauserotmana_finished = time + autocvar_g_balance_pause_mana_rot_spawn;
		self.pauserothealth_finished = time + autocvar_g_balance_pause_health_rot_spawn;
		self.pauserotfuel_finished = time + autocvar_g_balance_pause_fuel_rot_spawn;
		self.pauseregen_finished = time + autocvar_g_balance_pause_health_regen_spawn;
		//extend the pause of rotting if client was reset at the beginning of the countdown
		if(!autocvar_sv_ready_restart_after_countdown && time < game_starttime) { // TODO why is this cvar NOTted?
			self.spawnshieldtime += game_starttime - time;
			self.pauserotarmor_finished += game_starttime - time;
			self.pauserotmana_finished += game_starttime - time;
			self.pauserothealth_finished += game_starttime - time;
			self.pauseregen_finished += game_starttime - time;
		}
		
		
		//Player classes
		if (g_playerclass) {
			 if (self.playerclass_desired != self.playerclass) {
			  	if (self.playerclass_desired == PLAYERCLASS_LONGDISTANCE) {
			  		if (autocvar_g_playerclass_enable_longdistance) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset); //Playerclass changing, remove items/stat possibly (ex:spells)
						self.playerclass = PLAYERCLASS_LONGDISTANCE;
					}
				
				} else if (self.playerclass_desired == PLAYERCLASS_MARKSMAN) {
			  		if (autocvar_g_playerclass_enable_marksman) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_MARKSMAN;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_MEDIUMDISTANCE) {
			  		if (autocvar_g_playerclass_enable_mediumdistance) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_MEDIUMDISTANCE;
					}
						
			  	} else if (self.playerclass_desired == PLAYERCLASS_ASSAULT) {
			  		if (autocvar_g_playerclass_enable_assault) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_ASSAULT;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_CLOSERANGE) {
			  		if (autocvar_g_playerclass_enable_closerange) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_CLOSERANGE;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_DESTRUCTIVE) {
			  		if (autocvar_g_playerclass_enable_destructive) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_DESTRUCTIVE;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_HEAVYWEAPONS) {
			  		if (autocvar_g_playerclass_enable_heavyweapons) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_HEAVYWEAPONS;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_PYROMANIAC) {
			  		if (autocvar_g_playerclass_enable_pyromaniac) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_PYROMANIAC;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_ENGINEER) {
			  		if (autocvar_g_playerclass_enable_engineer) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_ENGINEER;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_WORKER) {
			  		if (autocvar_g_playerclass_enable_worker) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_WORKER;
					}
			  	
				} else if (self.playerclass_desired == PLAYERCLASS_HEALER) {
			  		if (autocvar_g_playerclass_enable_healer) {
						//if (pcgiveammo) //This execute_atend... is use primarily for removing classgiven items that would persist, like spell levels, so we do not do the ammo allowed check
						execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						self.playerclass = PLAYERCLASS_HEALER;
					}
			  	
					
				//These are always allowed (so far)	
			  	} else if (self.playerclass_desired == PLAYERCLASS_NONE) { //IE: 0
					execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
					self.playerclass = PLAYERCLASS_NONE;
			  	} else if (self.playerclass_desired == 0) { //Should be same
					execute_atend_giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
					self.playerclass = 0;
			  	}
			 }
			 
			 //////#
			 if (self.playerclass) {
			 	//////#
				if (self.playerclass == PLAYERCLASS_LONGDISTANCE) {
			  		if (autocvar_g_playerclass_enable_longdistance) {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_longdistance);
				  		self.health = self.health +start_add_health_playerclass_longdistance;
				  		self.mana = self.mana +start_add_mana_playerclass_longdistance;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_longdistance;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_longdistance;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_longdistance;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_longdistance;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_longdistance;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_longdistance;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_longdistance;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_longdistance;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_longdistance;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_longdistance;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_longdistance;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_longdistance; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_longdistance;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_longdistance;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_longdistance;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_longdistance;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_longdistance;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_longdistance;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_longdistance;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_longdistance;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_longdistance;
					
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_MARKSMAN) {
			  		if (autocvar_g_playerclass_enable_marksman)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_marksman);
				  		self.health = self.health +start_add_health_playerclass_marksman;
				  		self.mana = self.mana +start_add_mana_playerclass_marksman;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_marksman;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_marksman;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_marksman;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_marksman;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_marksman;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_marksman;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_marksman;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_marksman;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_marksman;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_marksman;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_marksman;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_marksman; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_marksman;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_marksman;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_marksman;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_marksman;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_marksman;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_marksman;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_marksman;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_marksman;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_marksman;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_MEDIUMDISTANCE) {
			  		if (autocvar_g_playerclass_enable_mediumdistance)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_mediumdistance);
				  		self.health = self.health +start_add_health_playerclass_mediumdistance;
				  		self.mana = self.mana +start_add_mana_playerclass_mediumdistance;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_mediumdistance;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_mediumdistance;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_mediumdistance;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_mediumdistance;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_mediumdistance;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_mediumdistance;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_mediumdistance;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_mediumdistance;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_mediumdistance;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_mediumdistance;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_mediumdistance;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_mediumdistance; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_mediumdistance;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_mediumdistance;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_mediumdistance;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_mediumdistance;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_mediumdistance;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_mediumdistance;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_mediumdistance;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_mediumdistance;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_mediumdistance;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
			  	} else if (self.playerclass == PLAYERCLASS_ASSAULT) {
			  		if (autocvar_g_playerclass_enable_assault)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_assault);
				  		self.health = self.health +start_add_health_playerclass_assault;
				  		self.mana = self.mana +start_add_mana_playerclass_assault;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_assault;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_assault;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_assault;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_assault;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_assault;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_assault;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_assault;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_assault;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_assault;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_assault;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_assault;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_assault; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_assault;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_assault;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_assault;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_assault;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_assault;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_assault;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_assault;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_assault;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_assault;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_CLOSERANGE) {
			  		if (autocvar_g_playerclass_enable_closerange) { 
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_closerange);
				  		self.health = self.health +start_add_health_playerclass_closerange;
				  		self.mana = self.mana +start_add_mana_playerclass_closerange;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_closerange;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_closerange;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_closerange;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_closerange;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_closerange;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_closerange;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_closerange;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_closerange;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_closerange;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_closerange;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_closerange;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_closerange; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_closerange;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_closerange;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_closerange;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_closerange;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_closerange;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_closerange;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_closerange;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_closerange;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_closerange;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_DESTRUCTIVE) {
			  		if (autocvar_g_playerclass_enable_destructive)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_destructive);
				  		self.health = self.health +start_add_health_playerclass_destructive;
				  		self.mana = self.mana +start_add_mana_playerclass_destructive;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_destructive;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_destructive;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_destructive;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_destructive;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_destructive;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_destructive;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_destructive;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_destructive;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_destructive;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_destructive;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_destructive;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_destructive; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_destructive;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_destructive;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_destructive;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_destructive;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_destructive;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_destructive;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_destructive;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_destructive;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_destructive;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_HEAVYWEAPONS) {
			  		if (autocvar_g_playerclass_enable_heavyweapons) { 
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_heavyweapons);
				  		self.health = self.health +start_add_health_playerclass_heavyweapons;
				  		self.mana = self.mana +start_add_mana_playerclass_heavyweapons;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_heavyweapons;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_heavyweapons;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_heavyweapons;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_heavyweapons;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_heavyweapons;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_heavyweapons;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_heavyweapons;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_heavyweapons;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_heavyweapons;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_heavyweapons;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_heavyweapons;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_heavyweapons; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_heavyweapons;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_heavyweapons;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_heavyweapons;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_heavyweapons;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_heavyweapons;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_heavyweapons;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_heavyweapons;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_heavyweapons;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_heavyweapons;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_PYROMANIAC) {
			  		if (autocvar_g_playerclass_enable_pyromaniac)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_pyromaniac);
				  		self.health = self.health +start_add_health_playerclass_pyromaniac;
				  		self.mana = self.mana +start_add_mana_playerclass_pyromaniac;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_pyromaniac;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_pyromaniac;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_pyromaniac;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_pyromaniac;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_pyromaniac;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_pyromaniac;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_pyromaniac;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_pyromaniac;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_pyromaniac;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_pyromaniac;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_pyromaniac;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_pyromaniac; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_pyromaniac;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_pyromaniac;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_pyromaniac;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_pyromaniac;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_pyromaniac;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_pyromaniac;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_pyromaniac;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_pyromaniac;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_pyromaniac;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_ENGINEER) {
			  		if (autocvar_g_playerclass_enable_engineer)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_engineer);
				  		self.health = self.health +start_add_health_playerclass_engineer;
				  		self.mana = self.mana +start_add_mana_playerclass_engineer;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_engineer;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_engineer;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_engineer;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_engineer;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_engineer;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_engineer;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_engineer;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_engineer;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_engineer;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_engineer;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_engineer;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_engineer; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_engineer;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_engineer;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_engineer;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_engineer;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_engineer;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_engineer;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_engineer;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_engineer;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_engineer;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_WORKER) {
			  		if (autocvar_g_playerclass_enable_worker)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_worker);
				  		self.health = self.health +start_add_health_playerclass_worker;
				  		self.mana = self.mana +start_add_mana_playerclass_worker;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_worker;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_worker;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_worker;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_worker;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_worker;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_worker;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_worker;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_worker;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_worker;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_worker;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_worker;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_worker; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_worker;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_worker;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_worker;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_worker;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_worker;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_worker;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_worker;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_worker;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_worker;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				} else if (self.playerclass == PLAYERCLASS_HEALER) {
			  		if (autocvar_g_playerclass_enable_healer)  {
						if (pcgiveweaps) WEPSET_COPY_EA(self, start_weapons_playerclass_healer);
				  		self.health = self.health +start_add_health_playerclass_healer;
				  		self.mana = self.mana +start_add_mana_playerclass_healer;
						if (pcgiveammo) {
						  self.ammo_shells = self.ammo_shells +start_add_ammo_shells_playerclass_healer;
				 		  self.ammo_nails = self.ammo_nails +start_add_ammo_nails_playerclass_healer;
				  		  self.ammo_rockets = self.ammo_rockets +start_add_ammo_rockets_playerclass_healer;
				  		  self.ammo_cells = self.ammo_cells +start_add_ammo_cells_playerclass_healer;
				  		  self.ammo_fuel = self.ammo_fuel +start_add_ammo_fuel_playerclass_healer;
				  		  self.armorvalue = self.armorvalue +start_add_armorvalue_playerclass_healer;
				  		  if (autocvar_g_playerclass_bots_noaddgrenades && clienttype(self) == CLIENTTYPE_BOT) {
							//No playerclass added grenades for bots
						  } else {
						  self.grenades = self.grenades +start_add_grenades_playerclass_healer;
				  		  self.flashbangs = self.flashbangs +start_add_flashbangs_playerclass_healer;
				  		  self.smokenades = self.smokenades +start_add_smokenades_playerclass_healer;
				  		  self.fragnades = self.fragnades +start_add_fragnades_playerclass_healer;
				  		  self.atmines = self.atmines +start_add_atmines_playerclass_healer;
				  		  self.landmines = self.landmines +start_add_landmines_playerclass_healer; 
						  }
						  self.inv_potion_health_small += start_add_inv_potion_health_small_healer;
						  self.inv_potion_health_medium += start_add_inv_potion_health_medium_healer;
						  self.inv_potion_health_large += start_add_inv_potion_health_large_healer;
						  self.inv_potion_mana_small += start_add_inv_potion_mana_small_healer;
						  self.inv_potion_mana_medium += start_add_inv_potion_mana_medium_healer;
						  self.inv_potion_mana_large += start_add_inv_potion_mana_large_healer;
						  self.inv_potion_rejuv_small += start_add_inv_potion_rejuv_small_healer;
						  self.inv_potion_rejuv_medium += start_add_inv_potion_rejuv_medium_healer;
						  self.inv_potion_rejuv_large += start_add_inv_potion_rejuv_large_healer;
						
						  giveitemsfromcvar_playerclass(self, self.playerclass, playerclassset);
						}
					}
				}
				//////#		
			 }
			 //////#
		}
		//End playerclasses
		
		
			 
		//We have to delay giving spells if using playerclasses 
		if (dodelaygivespells) {
			PCIS_givespells(self, teamplay, doteamoverrides);
		}
			
		self.damageforcescale = 2;
		self.death_time = 0;
		self.respawn_time = 0;
		self.scale = 0;
		self.fade_time = 0;
		self.pain_frame = 0;
		self.pain_finished = 0;
		self.strength_finished = 0;
		self.invincible_finished = 0;
		self.pushltime = 0;
		// players have no think function
		self.think = func_null;
		self.nextthink = 0;
		self.hook_time = 0;
		self.dmg_team = 0;
		self.ballistics_density = autocvar_g_ballistics_density_player;

		self.metertime = 0;

		self.runes = 0;

		self.deadflag = DEAD_NO;
		
		if (self.stoned)
			self.angles = self.stonedangles;
		else if (self.prisonerlevel == 3)
			self.angles = self.prison3angles;
		else
			self.angles = spot.angles;

		self.angles_z = 0; // never spawn tilted even if the spot says to
		self.fixangle = TRUE; // turn this way immediately
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.punchangle = '0 0 0';
		self.punchvector = '0 0 0';
		self.oldvelocity = self.velocity;
		self.fire_endtime = -1;

		msg_entity = self;
		WRITESPECTATABLE_MSG_ONE({
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_CSQC_SPAWN);
		});

		self.model = "";
		FixPlayermodel();
		self.drawonlytoclient = world;

		self.crouch = FALSE;
		self.view_ofs = PL_VIEW_OFS;
		setsize (self, PL_MIN, PL_MAX);
		
		if (self.stoned)
		{
			self.spawnorigin = self.stonedorigin;
			setorigin (self, self.stonedorigin + '0 0 1' * (1 - self.mins_z - 24));
		}
		else if (self.prisonerlevel == 2)
		{
			self.spawnorigin = self.prison2spot;
			setorigin (self, self.prison2spot + '0 0 1' * (1 - self.mins_z - 24));
		}
		else if (self.prisonerlevel == 3)
		{
			self.spawnorigin = self.prison3spot;
			//setorigin (self, self.prison3spot + '0 0 1' * (1 - self.mins_z - 24));
			setorigin (self, self.prison3spot);
		}
		else
		{
			self.spawnorigin = spot.origin;
			setorigin (self, spot.origin + '0 0 1' * (1 - self.mins_z - 24));
		}
		// don't reset back to last position, even if new position is stuck in solid
		self.oldorigin = self.origin;
		self.prevorigin = self.origin;
		self.lastrocket = world; // stop rocket guiding, no revenge from the grave!
		self.lastteleporttime = time; // prevent insane speeds due to changing origin
        self.hud = HUD_NORMAL;

		if(g_arena)
		{
			Spawnqueue_Remove(self);
			Spawnqueue_Mark(self);
		}
		else if(g_ca)
			self.caplayer = 1;

		self.event_damage = PlayerDamage;

		self.bot_attack = TRUE;
		self.monster_attack = TRUE;

		self.statdraintime = time + 5;
		self.BUTTON_ATCK = self.BUTTON_JUMP = self.BUTTON_ATCK2 = 0;

		if(self.killcount == -666) {
			PlayerScore_Clear(self);
			self.killcount = 0;
		}

		CL_SpawnWeaponentity();
		self.alpha = default_player_alpha;
		self.colormod = '1 1 1' * autocvar_g_player_brightness;
		self.exteriorweaponentity.alpha = default_weapon_alpha;

		self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval*2;
		self.lms_traveled_distance = 0;
		self.speedrunning = FALSE;

		race_PostSpawn(spot);

		//stuffcmd(self, "chase_active 0");
	 	//stuffcmd(self, "set viewsize $tmpviewsize \n");

		if(g_assault) {
			if(self.team == assault_attacker_team)
				centerprint(self, "You are attacking!");
			else
				centerprint(self, "You are defending!");
		}

		target_voicescript_clear(self);

		// reset fields the weapons may use
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			self.weaponaltaim_use = 0;
			self.weaponinitaimmotif_use = 0;
			weapon_action(j, WR_RESETPLAYER);

			// all weapons must be fully loaded when we spawn
			entity e;
			e = get_weaponinfo(j);
			if(e.spawnflags & WEP_FLAG_RELOADABLE) { // prevent accessing undefined cvars
				self.(weapon_load[j]) = cvar(strcat("g_balance_", e.netname, "_reload_ammo"));
				
				//Chaos-esque addition
				if not (self.(weapon_load[j])) {
					//If we are a weapon that has the reloadable flag
					////NOTE: melee weapons do not have the reloadable flag set
					////Thus we do not reach here with them
					//and we have our magazine size set to 0
					//(and thus we pull directly from the player ammo)
					//but no start ammo is given for our ammo type
					//normally we wouldn't be able to use the weapons
					//(until we picked up some of the ammo, if it exists on the map at all)
					//Here is a fall-back option that adds some ammo
					//This is usefull for when you select start weapons
					//But forget or do not know to also load up on some ammo
					//A player might think said weapons are broken
					//This option alleviates the problem by giving some
					//ammo in such situations
					//
					//This code us used only IF no starting ammo of a type needed is set
					if (autocvar_g_start_ammo_ifnoloadweaponstart_cells) {
						if (e.weapon)
						if (!self.ammo_cells)
						if (e.items & IT_CELLS)
						{
							if (WEPSET_CONTAINS_EW(self, e.weapon)) {
								self.ammo_cells = autocvar_g_start_ammo_ifnoloadweaponstart_cells;
							}
						}
					}
					
					if (autocvar_g_start_ammo_ifnoloadweaponstart_nails) {
						if (e.weapon)
						if (!self.ammo_nails)
						if (e.items & IT_NAILS)
						{
							if (WEPSET_CONTAINS_EW(self, e.weapon)) {
								self.ammo_nails = autocvar_g_start_ammo_ifnoloadweaponstart_nails;
							}
						}
					}
					
					if (autocvar_g_start_ammo_ifnoloadweaponstart_shells) {
						if (e.weapon)
						if (!self.ammo_shells)
						if (e.items & IT_SHELLS)
						{
							if (WEPSET_CONTAINS_EW(self, e.weapon)) {
								self.ammo_shells = autocvar_g_start_ammo_ifnoloadweaponstart_shells;
							}
						}
					}
					
					if (autocvar_g_start_ammo_ifnoloadweaponstart_rockets) {
						if (e.weapon)
						if (!self.ammo_rockets)
						if (e.items & IT_ROCKETS)
						{
							if (WEPSET_CONTAINS_EW(self, e.weapon)) {
								self.ammo_rockets = autocvar_g_start_ammo_ifnoloadweaponstart_rockets;
							}
						}
					}
					
					if (autocvar_g_start_ammo_ifnoloadweaponstart_fuel) {
						if (e.weapon)
						if (!self.ammo_fuel)
						if (e.items & IT_FUEL)
						{
							if (WEPSET_CONTAINS_EW(self, e.weapon)) {
								self.ammo_fuel = autocvar_g_start_ammo_ifnoloadweaponstart_fuel;
							}
						}
					}
				}
				//End Chaos-esque addition
			}
		}

		oldself = self;
		self = spot;
			activator = oldself;
				string s;
				s = self.target;
				self.target = string_null;
				SUB_UseTargets();
				self.target = s;
			activator = world;
		self = oldself;

		spawn_spot = spot;
		Unfreeze(self);
		W_AutoEvaluatePipeTypeByMapInfo();
		MUTATOR_CALLHOOK(PlayerSpawn);

		if(autocvar_spawn_debug)
		{
			sprint(self, strcat("spawnpoint origin:  ", vtos(spot.origin), "\n"));
			remove(spot);	// usefull for checking if there are spawnpoints, that let drop through the floor
		}

		self.switchweapon = w_getbestweapon(self);
		self.cnt = -1; // W_LastWeapon will not complain
		self.weapon = 0;
		self.weaponname = "";
		self.switchingweapon = 0;

		if(self.peaceful) W_SwitchWeapon_Force(self, 0);
		
		if(self.prisonerlevel > 1 || self.handcuffed) WEPSET_CLEAR_E(self);
		
		if(!self.alivetime)
			self.alivetime = time;

		antilag_clear(self);

		if (autocvar_g_spawnsound)
			soundat(world, self.origin, CH_TRIGGER, "misc/spawn.wav", VOL_BASE, ATTN_NORM);
	} else if(self.classname == "observer") {
		PutObserverInServer ();
	}
}

.float ebouncefactor, ebouncestop; // electro's values
// TODO do we need all these fields, or should we stop autodetecting runtime
// changes and just have a console command to update this?
float ClientInit_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_INIT);
	WriteByte(MSG_ENTITY, g_nexball_meter_period * 32);
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(hook_shotorigin[3]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(electro_shotorigin[3]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[0]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[1]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[2]));
	WriteInt24_t(MSG_ENTITY, compressShotOrigin(gauntlet_shotorigin[3]));
	if(sv_foginterval && world.fog != "")
		WriteString(MSG_ENTITY, world.fog);
	else
		WriteString(MSG_ENTITY, "");
	WriteByte(MSG_ENTITY, self.count * 255.0); // g_balance_armor_blockpercent
	WriteByte(MSG_ENTITY, self.cnt * 255.0); // g_balance_weaponswitchdelay
	WriteCoord(MSG_ENTITY, self.bouncefactor); // g_balance_grenadelauncher_bouncefactor
	WriteCoord(MSG_ENTITY, self.bouncestop); // g_balance_grenadelauncher_bouncestop
	WriteCoord(MSG_ENTITY, self.ebouncefactor); // g_balance_grenadelauncher_bouncefactor
	WriteCoord(MSG_ENTITY, self.ebouncestop); // g_balance_grenadelauncher_bouncestop
	WriteByte(MSG_ENTITY, autocvar_g_balance_nex_secondary); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, autocvar_g_balance_rifle_secondary); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, serverflags); // client has to know if it should zoom or not
	WriteByte(MSG_ENTITY, autocvar_g_balance_minelayer_limit); // minelayer max mines
	WriteByte(MSG_ENTITY, autocvar_g_balance_hagar_secondary_load_max); // hagar max loadable rockets
	WriteCoord(MSG_ENTITY, autocvar_g_trueaim_minrange);
	WriteByte(MSG_ENTITY, autocvar_g_balance_porto_secondary);
	return TRUE;
}

void ClientInit_CheckUpdate()
{
	self.nextthink = time;
	if(self.count != autocvar_g_balance_armor_blockpercent)
	{
		self.count = autocvar_g_balance_armor_blockpercent;
		self.SendFlags |= 1;
	}
	if(self.cnt != autocvar_g_balance_weaponswitchdelay)
	{
		self.cnt = autocvar_g_balance_weaponswitchdelay;
		self.SendFlags |= 1;
	}
	if(self.bouncefactor != autocvar_g_balance_grenadelauncher_bouncefactor)
	{
		self.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
		self.SendFlags |= 1;
	}
	if(self.bouncestop != autocvar_g_balance_grenadelauncher_bouncestop)
	{
		self.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
		self.SendFlags |= 1;
	}
	if(self.ebouncefactor != autocvar_g_balance_electro_secondary_bouncefactor)
	{
		self.ebouncefactor = autocvar_g_balance_electro_secondary_bouncefactor;
		self.SendFlags |= 1;
	}
	if(self.ebouncestop != autocvar_g_balance_electro_secondary_bouncestop)
	{
		self.ebouncestop = autocvar_g_balance_electro_secondary_bouncestop;
		self.SendFlags |= 1;
	}
}

void ClientInit_Spawn()
{
	entity o;
	entity e;
	e = spawn();
	e.classname = "clientinit";
	e.think = ClientInit_CheckUpdate;
	Net_LinkEntity(e, FALSE, 0, ClientInit_SendEntity);

	o = self;
	self = e;
	ClientInit_CheckUpdate();
	self = o;
}

/*
=============
SetNewParms
=============
*/
void SetNewParms (void)
{
	// initialize parms for a new player
	parm1 = -(86400 * 366);
}

/*
=============
SetChangeParms
=============
*/
void SetChangeParms (void)
{
	// save parms for level change
	parm1 = self.parm_idlesince - time;
}

/*
=============
DecodeLevelParms
=============
*/
void DecodeLevelParms (void)
{
	// load parms
	self.parm_idlesince = parm1;
	if(self.parm_idlesince == -(86400 * 366))
		self.parm_idlesince = time;

	// whatever happens, allow 60 seconds of idling directly after connect for map loading
	self.parm_idlesince = max(self.parm_idlesince, time - sv_maxidle + 60);
}

/*
=============
ClientKill

Called when a client types 'kill' in the console
=============
*/

.float clientkill_nexttime;
void ClientKill_Now_TeamChange()
{
	if(self.killindicator_teamchange == -1)
	{
		JoinBestTeam( self, FALSE, TRUE );
	}
	else if(self.killindicator_teamchange == -2)
	{
		if(g_ca)
			self.caplayer = 0;
		if(blockSpectators)
			sprint(self, strcat("^7You have to become a player within the next ", ftos(autocvar_g_maxplayers_spectator_blocktime), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
		PutObserverInServer();
	}
	else
		SV_ChangeTeam(self.killindicator_teamchange - 1);
}

void ClientKill_Now()
{
	if(self.vehicle)
	{
	    vehicles_exit(VHEF_RELESE);
	    if(!self.killindicator_teamchange)
	    {
            self.vehicle_health = -1;
            Damage(self, self, self, 1 , DEATH_KILL, self.origin, '0 0 0');	        
	    }
	}

	if(self.killindicator && !wasfreed(self.killindicator))
		remove(self.killindicator);

	self.killindicator = world;

	if(self.killindicator_teamchange)
		ClientKill_Now_TeamChange();

	// in any case:
	Damage(self, self, self, 100000, DEATH_KILL, self.origin, '0 0 0');

	// now I am sure the player IS dead
}
void KillIndicator_Think()
{
	if (gameover)
	{
		self.owner.killindicator = world;
		remove(self);
		return;
	}

	if (self.owner.alpha < 0 && !self.owner.vehicle)
	{
		self.owner.killindicator = world;
		remove(self);
		return;
	}

	if(self.cnt <= 0)
	{
		self = self.owner;
		ClientKill_Now(); // no oldself needed
		return;
	}
    else if(g_cts && self.health == 1) // health == 1 means that it's silent
    {
        self.nextthink = time + 1;
        self.cnt -= 1;
    }
	else
	{
		if(self.cnt <= 10)
			setmodel(self, strcat("models/sprites/", ftos(self.cnt), ".spr32"));
		if(clienttype(self.owner) == CLIENTTYPE_REAL)
		{
			if(self.cnt <= 10)
				AnnounceTo(self.owner, strcat(ftos(self.cnt), ""));
		}
		self.nextthink = time + 1;
		self.cnt -= 1;
	}
}

float clientkilltime;
void ClientKill_TeamChange (float targetteam) // 0 = don't change, -1 = auto, -2 = spec
{
	float killtime;
	float starttime;
	entity e;

	if (gameover)
		return;

	if (self.stoned)
		return; //Players turned to stone can't f3 kill self, frozen players can
		
	if (self.prisonerlevel || self.handcuffed)
		return; //Prisoners can't change teams by their on volition

	killtime = autocvar_g_balance_kill_delay;

	if(g_race_qualifying || g_cts)
		killtime = 0;

    if(g_cts && self.killindicator && self.killindicator.health == 1) // self.killindicator.health == 1 means that the kill indicator was spawned by CTS_ClientKill
    {
		remove(self.killindicator);
		self.killindicator = world;

        ClientKill_Now(); // allow instant kill in this case
        return;
    }

	self.killindicator_teamchange = targetteam;

    if(!self.killindicator)
	{
		if(self.deadflag == DEAD_NO)
		{
			killtime = max(killtime, self.clientkill_nexttime - time);
			self.clientkill_nexttime = time + killtime + autocvar_g_balance_kill_antispam;
		}

		if(killtime <= 0 || self.classname != "player" || self.deadflag != DEAD_NO)
		{
			ClientKill_Now();
		}
		else
		{
			starttime = max(time, clientkilltime);

			self.killindicator = spawn();
			self.killindicator.owner = self;
			self.killindicator.scale = 0.5;
			setattachment(self.killindicator, self, "");
			setorigin(self.killindicator, '0 0 52');
			self.killindicator.think = KillIndicator_Think;
			self.killindicator.nextthink = starttime + (self.lip) * 0.05;
			clientkilltime = max(clientkilltime, self.killindicator.nextthink + 0.05);
			self.killindicator.cnt = ceil(killtime);
			self.killindicator.count = bound(0, ceil(killtime), 10);
			//sprint(self, strcat("^1You'll be dead in ", ftos(self.killindicator.cnt), " seconds\n"));

			for(e = world; (e = find(e, classname, "body")) != world; )
			{
				if(e.enemy != self)
					continue;
				e.killindicator = spawn();
				e.killindicator.owner = e;
				e.killindicator.scale = 0.5;
				setattachment(e.killindicator, e, "");
				setorigin(e.killindicator, '0 0 52');
				e.killindicator.think = KillIndicator_Think;
				e.killindicator.nextthink = starttime + (e.lip) * 0.05;
				clientkilltime = max(clientkilltime, e.killindicator.nextthink + 0.05);
				e.killindicator.cnt = ceil(killtime);
			}
			self.lip = 0;
		}
	}
	if(self.killindicator)
	{
		if(targetteam == 0) // just die
		{
			self.killindicator.colormod = '0 0 0';
			if(clienttype(self) == CLIENTTYPE_REAL)
			if(self.killindicator.cnt > 0)
				Send_CSQC_Centerprint_Generic(self, CPID_TEAMCHANGE, "^1Suicide in %d seconds", 1, self.killindicator.cnt);
		}
		else if(targetteam == -1) // auto
		{
			self.killindicator.colormod = '0 1 0';
			if(clienttype(self) == CLIENTTYPE_REAL)
			if(self.killindicator.cnt > 0)
				Send_CSQC_Centerprint_Generic(self, CPID_TEAMCHANGE, "Changing team in %d seconds", 1, self.killindicator.cnt);
		}
		else if(targetteam == -2) // spectate
		{
			self.killindicator.colormod = '0.5 0.5 0.5';
			if(clienttype(self) == CLIENTTYPE_REAL)
			if(self.killindicator.cnt > 0)
				Send_CSQC_Centerprint_Generic(self, CPID_TEAMCHANGE, "Spectating in %d seconds", 1, self.killindicator.cnt);
		}
		else
		{
			self.killindicator.colormod = TeamColor(targetteam);
			if(clienttype(self) == CLIENTTYPE_REAL)
			if(self.killindicator.cnt > 0)
				Send_CSQC_Centerprint_Generic(self, CPID_TEAMCHANGE, strcat("Changing to ", ColoredTeamName(targetteam), " in %d seconds"), 1, self.killindicator.cnt);
		}
	}

}

void ClientKill (void)
{
	if (gameover)
		return;

	if((g_arena || g_ca) && ((champion && champion.classname == "player" && player_count > 1) || player_count == 1)) // don't allow a kill in this case either
	{
		// do nothing
	}
	else if(self.frozen)
    	{
        	// do nothing
    	}
	else if(self.stoned)
    	{
        	// do nothing
    	}
	else if(self.prisonerlevel == 3 || self.handcuffed)
    	{
        	// do nothing //Shackled or chained prisoners cannot kill themselves (jailed (2) can)
    	}
    else if(self.freezetag_frozen)
    {
        // do nothing
    }
	else
		ClientKill_TeamChange(0);
}

void CTS_ClientKill (entity e) // silent version of ClientKill, used when player finishes a CTS run. Useful to prevent cheating by running back to the start line and starting out with more speed
{
    e.killindicator = spawn();
    e.killindicator.owner = e;
    e.killindicator.think = KillIndicator_Think;
    e.killindicator.nextthink = time + (e.lip) * 0.05;
    e.killindicator.cnt = ceil(autocvar_g_cts_finish_kill_delay);
    e.killindicator.health = 1; // this is used to indicate that it should be silent
    e.lip = 0;
}

void FixClientCvars(entity e)
{
	// send prediction settings to the client
	stuffcmd(e, "\nin_bindmap 0 0\n");
	if(g_race || g_cts)
		stuffcmd(e, "cl_cmd settemp cl_movecliptokeyboard 2\n");
	if(autocvar_g_antilag == 3) // client side hitscan
		stuffcmd(e, "cl_cmd settemp cl_prydoncursor_notrace 0\n");
	if(sv_gentle)
		stuffcmd(e, "cl_cmd settemp cl_gentle 1\n");
	/*
	 * we no longer need to stuff this. Remove this comment block if you feel
	 * 2.3 and higher (or was it 2.2.3?) don't need these any more
	stuffcmd(e, strcat("cl_gravity ", ftos(autocvar_sv_gravity), "\n"));
	stuffcmd(e, strcat("cl_movement_accelerate ", ftos(autocvar_sv_accelerate), "\n"));
	stuffcmd(e, strcat("cl_movement_friction ", ftos(autocvar_sv_friction), "\n"));
	stuffcmd(e, strcat("cl_movement_maxspeed ", ftos(autocvar_sv_maxspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_airaccelerate ", ftos(autocvar_sv_airaccelerate), "\n"));
	stuffcmd(e, strcat("cl_movement_maxairspeed ", ftos(autocvar_sv_maxairspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_stopspeed ", ftos(autocvar_sv_stopspeed), "\n"));
	stuffcmd(e, strcat("cl_movement_jumpvelocity ", ftos(autocvar_sv_jumpvelocity), "\n"));
	stuffcmd(e, strcat("cl_movement_stepheight ", ftos(autocvar_sv_stepheight), "\n"));
	stuffcmd(e, strcat("set cl_movement_friction_on_land ", ftos(autocvar_sv_friction_on_land), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_qw ", ftos(autocvar_sv_airaccel_qw), "\n"));
	stuffcmd(e, strcat("set cl_movement_airaccel_sideways_friction ", ftos(autocvar_sv_airaccel_sideways_friction), "\n"));
	stuffcmd(e, "cl_movement_edgefriction 1\n");
	 */
}

float PlayerInIDList(entity p, string idlist)
{
	float n, i;
	string s;

	// NOTE: we do NOT check crypto_keyfp here, an unsigned ID is fine too for this
	if not(p.crypto_idfp)
		return 0;

	// this function allows abbreviated player IDs too!
	n = tokenize_console(idlist);
	for(i = 0; i < n; ++i)
	{
		s = argv(i);
		if(s == substring(p.crypto_idfp, 0, strlen(s)))
			return 1;
	}

	return 0;
}

/*
=============
ClientConnect

Called when a client connects to the server
=============
*/
string ColoredTeamName(float t);
void DecodeLevelParms (void);
//void dom_player_join_team(entity pl);
void set_dom_state(entity e);
void ClientConnect (void)
{
	float t;

	if(self.flags & FL_CLIENT)
	{
		print("Warning: ClientConnect, but already connected!\n");
		return;
	}

	if(Ban_MaybeEnforceBan(self))
		return;

	DecodeLevelParms();

#ifdef WATERMARK
	sprint(self, strcat("^4SVQC Build information: ^1", WATERMARK, "\n"));
#endif

	self.classname = "player_joining";

	self.flags = FL_CLIENT;
	self.version_nagtime = time + 10 + random() * 10;

	if(player_count<0)
	{
		dprint("BUG player count is lower than zero, this cannot happen!\n");
		player_count = 0;
	}

	PlayerScore_Attach(self);
	ClientData_Attach();
	accuracy_init(self);

	bot_clientconnect();

	playerdemo_init();

	anticheat_init();

	race_PreSpawnObserver();

	//if(g_domination)
	//	dom_player_join_team(self);

	// identify the right forced team
	if(autocvar_g_campaign)
	{
		if(clienttype(self) == CLIENTTYPE_REAL) // only players, not bots
		{
			switch(autocvar_g_campaign_forceteam)
			{
				case 1: self.team_forced = COLOR_TEAM1; break;
				case 2: self.team_forced = COLOR_TEAM2; break;
				case 3: self.team_forced = COLOR_TEAM3; break;
				case 4: self.team_forced = COLOR_TEAM4; break;
				default: self.team_forced = 0;
			}
		}
	}
	else if(PlayerInIDList(self, autocvar_g_forced_team_red))
		self.team_forced = COLOR_TEAM1;
	else if(PlayerInIDList(self, autocvar_g_forced_team_blue))
		self.team_forced = COLOR_TEAM2;
	else if(PlayerInIDList(self, autocvar_g_forced_team_yellow))
		self.team_forced = COLOR_TEAM3;
	else if(PlayerInIDList(self, autocvar_g_forced_team_pink))
		self.team_forced = COLOR_TEAM4;
	else if(autocvar_g_forced_team_otherwise == "red")
		self.team_forced = COLOR_TEAM1;
	else if(autocvar_g_forced_team_otherwise == "blue")
		self.team_forced = COLOR_TEAM2;
	else if(autocvar_g_forced_team_otherwise == "yellow")
		self.team_forced = COLOR_TEAM3;
	else if(autocvar_g_forced_team_otherwise == "pink")
		self.team_forced = COLOR_TEAM4;
	else if(autocvar_g_forced_team_otherwise == "spectate")
		self.team_forced = -1;
	else if(autocvar_g_forced_team_otherwise == "spectator")
		self.team_forced = -1;
	else
		self.team_forced = 0;

	if(!teamplay)
		if(self.team_forced > 0)
			self.team_forced = 0;

	JoinBestTeam(self, FALSE, FALSE); // if the team number is valid, keep it

	if((autocvar_sv_spectate == 1 && !g_lms) || autocvar_g_campaign || self.team_forced < 0) {
		self.classname = "observer";
	} else {
		if(teamplay)
		{
			if(autocvar_g_balance_teams)
			{
				self.classname = "player";
				campaign_bots_may_start = 1;
			}
			else
			{
				self.classname = "observer"; // do it anyway
			}
		}
		else
		{
			self.classname = "player";
			campaign_bots_may_start = 1;
		}
	}

	self.playerid = (playerid_last = playerid_last + 1);

	PlayerStats_AddEvent(sprintf("kills-%d", self.playerid));

    if(clienttype(self) == CLIENTTYPE_BOT)
        PlayerStats_AddPlayer(self);

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":join:", ftos(self.playerid), ":", ftos(num_for_edict(self)), ":", ((clienttype(self) == CLIENTTYPE_REAL) ? self.netaddress : "bot"), ":", self.netname));

	LogTeamchange(self.playerid, self.team, 1);

	self.just_joined = TRUE;  // stop spamming the eventlog with additional lines when the client connects

	self.netname_previous = strzone(self.netname);

	bprint("^4", self.netname, "^4 connected");

	if(self.classname != "observer" && (g_domination || g_ctf))
		bprint(" and joined the ", ColoredTeamName(self.team));

	bprint("\n");

	stuffcmd(self, strcat(clientstuff, "\n"));
	stuffcmd(self, "cl_particles_reloadeffects\n"); // TODO do we still need this?

	FixClientCvars(self);

	// spawnfunc_waypoint sprites
	WaypointSprite_InitClient(self);

	// Wazat's grappling hook
	SetGrappleHookBindings();

	// get version info from player
	stuffcmd(self, "cmd clientversion $gameversion\n");

	// get other cvars from player
	GetCvars(0);

	// notify about available teams
	if(teamplay)
	{
		CheckAllowedTeams(self);
		t = 0; if(c1 >= 0) t |= 1; if(c2 >= 0) t |= 2; if(c3 >= 0) t |= 4; if(c4 >= 0) t |= 8;
		stuffcmd(self, strcat("set _teams_available ", ftos(t), "\n"));
	}
	else
		stuffcmd(self, "set _teams_available 0\n");

	// notify about available player classes
	if (g_playerclass) {
		if (playerclassset == PLAYERCLASSSET_DEFAULT) {
			//print("default playerclassset\n");
			stuffcmd(self, "set _playerclassset 11\n");
		} else if  (playerclassset == PLAYERCLASSSET_MEDIEVALFANTASY){
			//print("medievalfantasy playerclassset\n");
			stuffcmd(self, "set _playerclassset 21\n");
		} else if  (playerclassset == PLAYERCLASSSET_OLDWEST){
			//print("oldwest playerclassset\n");
			stuffcmd(self, "set _playerclassset 31\n");
		} else if  (playerclassset == PLAYERCLASSSET_XON){
			//print("oldwest playerclassset\n");
			stuffcmd(self, "set _playerclassset 41\n");
		} else if  (playerclassset == PLAYERCLASSSET_WWI){
			//print("oldwest playerclassset\n");
			stuffcmd(self, "set _playerclassset 51\n");
		} else {
			//print("no playerclassset\n");
			stuffcmd(self, "set _playerclassset 0\n");
		}
		
		
		if (autocvar_g_playerclass_enable_longdistance) {
				stuffcmd(self, "set _playerclass_longdistance 1\n");
			} else {
				stuffcmd(self, "set _playerclass_longdistance 0\n");
			}
			
		if (autocvar_g_playerclass_enable_marksman) {
				stuffcmd(self, "set _playerclass_marksman 1\n");
			} else {
				stuffcmd(self, "set _playerclass_marksman 0\n");
			}
			
		if (autocvar_g_playerclass_enable_mediumdistance) {
				stuffcmd(self, "set _playerclass_mediumdistance 1\n");
			} else {
				stuffcmd(self, "set _playerclass_mediumdistance 0\n");
			}
			
		if (autocvar_g_playerclass_enable_assault) {
				stuffcmd(self, "set _playerclass_assault 1\n");
			} else {
				stuffcmd(self, "set _playerclass_assault 0\n");
			}
			
		if (autocvar_g_playerclass_enable_closerange) {
				stuffcmd(self, "set _playerclass_closerange 1\n");
			} else {
				stuffcmd(self, "set _playerclass_closerange 0\n");
			}
			
		if (autocvar_g_playerclass_enable_destructive) {
				stuffcmd(self, "set _playerclass_destructive 1\n");
			} else {
				stuffcmd(self, "set _playerclass_destructive 0\n");
			}
			
		if (autocvar_g_playerclass_enable_heavyweapons) {
				stuffcmd(self, "set _playerclass_heavyweapons 1\n");
			} else {
				stuffcmd(self, "set _playerclass_heavyweapons 0\n");
			}
			
		if (autocvar_g_playerclass_enable_pyromaniac) {
				stuffcmd(self, "set _playerclass_pyromaniac 1\n");
			} else {
				stuffcmd(self, "set _playerclass_pyromaniac 0\n");
			}
			
		if (autocvar_g_playerclass_enable_engineer) {
				stuffcmd(self, "set _playerclass_engineer 1\n");
			} else {
				stuffcmd(self, "set _playerclass_engineer 0\n");
			}
			
		if (autocvar_g_playerclass_enable_worker) {
				stuffcmd(self, "set _playerclass_worker 1\n");
			} else {
				stuffcmd(self, "set _playerclass_worker 0\n");
			}
			
		if (autocvar_g_playerclass_enable_healer) {
				stuffcmd(self, "set _playerclass_healer 1\n");
			} else {
				stuffcmd(self, "set _playerclass_healer 0\n");
			}
	}	
	
	if(g_arena || g_ca)
	{
		self.classname = "observer";
		if(g_arena)
			Spawnqueue_Insert(self);
	}

	attach_entcs();

	bot_relinkplayerlist();

	self.spectatortime = time;
	if(blockSpectators)
	{
		sprint(self, strcat("^7You have to become a player within the next ", ftos(autocvar_g_maxplayers_spectator_blocktime), " seconds, otherwise you will be kicked, because spectators aren't allowed at this time!\n"));
	}

	self.jointime = time;
	self.allowed_timeouts = autocvar_sv_timeout_number;

	if(clienttype(self) == CLIENTTYPE_REAL)
	{
		if(autocvar_g_bugrigs || WEPSET_EQ_AW(g_weaponarena_weapons, WEP_TUBA))
			stuffcmd(self, "cl_cmd settemp chase_active 1\n");
	}

	if(g_lms)
	{
		if(PlayerScore_Add(self, SP_LMS_LIVES, LMS_NewPlayerLives()) <= 0)
		{
			PlayerScore_Add(self, SP_LMS_RANK, 666);
			self.frags = FRAGS_SPECTATOR;
		}
	}

	if(!sv_foginterval && world.fog != "")
		stuffcmd(self, strcat("\nfog ", world.fog, "\nr_fog_exp2 0\nr_drawfog 1\n"));

	if(autocvar_g_hitplots || strstrofs(strcat(" ", autocvar_g_hitplots_individuals, " "), strcat(" ", self.netaddress, " "), 0) >= 0)
	{
		self.hitplotfh = fopen(strcat("hits-", matchid, "-", self.netaddress, "-", ftos(self.playerid), ".plot"), FILE_WRITE);
		fputs(self.hitplotfh, strcat("#name ", self.netname, "\n"));
	}
	else
		self.hitplotfh = -1;

	if(g_race || g_cts) {
		string rr;
		if(g_cts)
			rr = CTS_RECORD;
		else
			rr = RACE_RECORD;

		msg_entity = self;
		race_send_recordtime(MSG_ONE);
		race_send_speedaward(MSG_ONE);

		speedaward_alltimebest = stof(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/speed")));
		speedaward_alltimebest_holder = uid2name(db_get(ServerProgsDB, strcat(GetMapname(), rr, "speed/crypto_idfp")));
		race_send_speedaward_alltimebest(MSG_ONE);

		float i;
		for (i = 1; i <= RANKINGS_CNT; ++i) {
			race_SendRankings(i, 0, 0, MSG_ONE);
		}
	}
	else if(autocvar_sv_teamnagger && !(autocvar_bot_vs_human && (c3==-1 && c4==-1)) && !g_ca) // teamnagger is currently bad for ca
		send_CSQC_teamnagger();

	if (g_domination)
		set_dom_state(self);

	CheatInitClient();

	if(!autocvar_g_campaign)
		Send_CSQC_Centerprint_Generic(self, CPID_MOTD, getwelcomemessage(), autocvar_welcome_message_time, 0);

	CSQCMODEL_AUTOINIT();

	self.model_randomizer = random();
    
    if(clienttype(self) != CLIENTTYPE_REAL)
        return;
        
    sv_notice_join();
    
    MUTATOR_CALLHOOK(ClientConnect);
}
/*
=============
ClientDisconnect

Called when a client disconnects from the server
=============
*/
.entity chatbubbleentity;
void ReadyCount();
void ClientDisconnect (void)
{
	Client_Record(self);
	Client_Record_Ownership_Protection(self);
	PutItBackIfAble(self); //So won't be visibly attached to random other things, hopefully
	deinsertFriend(self); //Set .friendent of plrfrndentry s to world to delist disconnecting friends
	deinsertExFriend(self); //Set .exfriendent of exfrndentry s to world to delist disconnecting exfriends
	deinsertTolerated(self); //Set .toleratedent of tolrtddentry s to world to delist disconnecting exfriends
	deinsertHated(self);
	deinsertExHated(self);
	
	if(self.vehicle)
	    vehicles_exit(VHEF_RELESE);

	if not(self.flags & FL_CLIENT)
	{
		print("Warning: ClientDisconnect without ClientConnect\n");
		return;
	}

	PlayerStats_AddGlobalInfo(self);

	CheatShutdownClient();

	if(self.hitplotfh >= 0)
	{
		fclose(self.hitplotfh);
		self.hitplotfh = -1;
	}

	anticheat_report();
	anticheat_shutdown();

	playerdemo_shutdown();

	bot_clientdisconnect();

	if(self.entcs)
		detach_entcs();

	if(autocvar_sv_eventlog)
		GameLogEcho(strcat(":part:", ftos(self.playerid)));
	bprint ("^4",self.netname);
	bprint ("^4 disconnected\n");

	ExtinguishTorchlightForWarpzone(self);
	TurnOffFlashlightlightForWarpzone(self);
	DropAllRunes(self);
	WindDownTimesinksOfPlayer(self);
	MUTATOR_CALLHOOK(ClientDisconnect);

	Portal_ClearAll(self);

	RemoveGrapplingHook(self);

	// Here, everything has been done that requires this player to be a client.

	self.flags &~= FL_CLIENT;

	if (self.chatbubbleentity)
		remove (self.chatbubbleentity);

	if (self.killindicator)
		remove (self.killindicator);

	WaypointSprite_PlayerGone();

	bot_relinkplayerlist();
	
	// remove laserdot
	if(self.weaponentity)
		if(self.weaponentity.lasertarget)
			remove(self.weaponentity.lasertarget);
			
	unmarshalmonsters(self);
	self.marshalattack = 0;
	
	// remove ornaments
	if (self.body_phal)
		remove(self.body_phal);

	if(g_arena)
	{
		Spawnqueue_Unmark(self);
		Spawnqueue_Remove(self);
	}

	accuracy_free(self);
	ClientData_Detach();
	PlayerScore_Detach(self);

	if(self.netname_previous)
		strunzone(self.netname_previous);
	if(self.clientstatus)
		strunzone(self.clientstatus);
	if(self.weaponorder_byimpulse)
		strunzone(self.weaponorder_byimpulse);

	ClearPlayerSounds();

	if(self.personal)
		remove(self.personal);

	self.playerid = 0;
	ReadyCount();

	// free cvars
	GetCvars(-1);
}

.float BUTTON_CHAT;
void ChatBubbleThink()
{
	self.nextthink = time;
	if ((self.owner.alpha < 0) || self.owner.chatbubbleentity != self)
	{
		if(self.owner) // but why can that ever be world?
			self.owner.chatbubbleentity = world;
		remove(self);
		return;
	}
	if ((self.owner.BUTTON_CHAT && !self.owner.deadflag)
#ifdef TETRIS
		|| self.owner.tetris_on
#endif
	)
		self.model = self.mdl;
	else
		self.model = "";
}

void UpdateChatBubble()
{
	if (self.alpha < 0)
		return;
	// spawn a chatbubble entity if needed
	if (!self.chatbubbleentity)
	{
		self.chatbubbleentity = spawn();
		self.chatbubbleentity.owner = self;
		self.chatbubbleentity.exteriormodeltoclient = self;
		self.chatbubbleentity.think = ChatBubbleThink;
		self.chatbubbleentity.nextthink = time;
		setmodel(self.chatbubbleentity, "models/misc/chatbubble.spr"); // precision set below
		//setorigin(self.chatbubbleentity, self.origin + '0 0 15' + self.maxs_z * '0 0 1');
		setorigin(self.chatbubbleentity, '0 0 15' + self.maxs_z * '0 0 1');
		setattachment(self.chatbubbleentity, self, "");  // sticks to moving player better, also conserves bandwidth
		self.chatbubbleentity.mdl = self.chatbubbleentity.model;
		self.chatbubbleentity.model = "";
		self.chatbubbleentity.effects = EF_LOWPRECISION;
	}
}


// LordHavoc: this hack will be removed when proper _pants/_shirt layers are
// added to the model skins
/*void UpdateColorModHack()
{
	float c;
	c = self.clientcolors & 15;
	// LordHavoc: only bothering to support white, green, red, yellow, blue
	     if (!teamplay) self.colormod = '0 0 0';
	else if (c ==  0) self.colormod = '1.00 1.00 1.00';
	else if (c ==  3) self.colormod = '0.10 1.73 0.10';
	else if (c ==  4) self.colormod = '1.73 0.10 0.10';
	else if (c == 12) self.colormod = '1.22 1.22 0.10';
	else if (c == 13) self.colormod = '0.10 0.10 1.73';
	else self.colormod = '1 1 1';
}*/

void respawn(void)
{
	local float isgracerespawn;
	isgracerespawn = DamageTargIsWithinGraceCircleAndHasGrace(self);
	if(self.alpha >= 0 && (autocvar_g_respawn_ghosts || isgracerespawn))
	{
		self.solid = SOLID_NOT;
		self.takedamage = DAMAGE_NO;
		self.movetype = MOVETYPE_FLY;
		self.velocity = '0 0 1' * autocvar_g_respawn_ghosts_speed;
		self.avelocity = randomvec() * autocvar_g_respawn_ghosts_speed * 3 - randomvec() * autocvar_g_respawn_ghosts_speed * 3;
		self.effects |= CSQCMODEL_EF_RESPAWNGHOST;
		pointparticles(particleeffectnum("respawn_ghost"), self.origin, '0 0 0', 1);
		
		if (isgracerespawn) {
			self.alpha = 0.8;
			SUB_SetFade (self, time + (autocvar_g_respawn_ghosts_maxtime + 50) / 2 + random () * ((autocvar_g_respawn_ghosts_maxtime + 50) - (autocvar_g_respawn_ghosts_maxtime + 50) / 2), 1.5);
		} else {
			if(autocvar_g_respawn_ghosts_maxtime)
				SUB_SetFade (self, time + autocvar_g_respawn_ghosts_maxtime / 2 + random () * (autocvar_g_respawn_ghosts_maxtime - autocvar_g_respawn_ghosts_maxtime / 2), 1.5);
		}
	}

	CopyBody(1);

	self.effects |= EF_NODRAW; // prevent another CopyBody
	PutClientInServer();
}

void play_countdown(float finished, string samp)
{
	if(clienttype(self) == CLIENTTYPE_REAL)
		if(floor(finished - time - frametime) != floor(finished - time))
			if(finished - time < 6)
				sound (self, CH_INFO, samp, VOL_BASE, ATTN_NORM);
}

void player_powerups (void)
{
	// add a way to see what the items were BEFORE all of these checks for the mutator hook
	olditems = self.items;

	if((self.items & IT_USING_JETPACK) && !self.deadflag)
		self.modelflags |= MF_ROCKET;
	else
		self.modelflags &~= MF_ROCKET;

	self.effects &~= (EF_RED | EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT | EF_FLAME | EF_NODEPTHTEST);

	if(self.alpha < 0 || self.deadflag) // don't apply the flags if the player is gibbed
		return;

	Fire_ApplyDamage(self);
	Fire_ApplyEffect(self);

	if (g_minstagib)
	{
		self.effects |= EF_FULLBRIGHT;

		if (self.items & IT_STRENGTH)
		{
			play_countdown(self.strength_finished, "misc/poweroff.wav");
			if (time > self.strength_finished)
			{
				self.alpha = default_player_alpha;
				self.exteriorweaponentity.alpha = default_weapon_alpha;
				self.items &~= IT_STRENGTH;
				sprint(self, "^3Invisibility has worn off\n");
			}
		}
		else
		{
			if (time < self.strength_finished)
			{
				self.alpha = g_minstagib_invis_alpha;
				self.exteriorweaponentity.alpha = g_minstagib_invis_alpha;
				self.items |= IT_STRENGTH;
				sprint(self, "^3You are invisible\n");
			}
		}

		if (self.items & IT_INVINCIBLE)
		{
			play_countdown(self.invincible_finished, "misc/poweroff.wav");
			if (time > self.invincible_finished)
			{
				self.items = self.items - (self.items & IT_INVINCIBLE);
				sprint(self, "^3Speed has worn off\n");
			}
		}
		else
		{
			if (time < self.invincible_finished)
			{
				self.items = self.items | IT_INVINCIBLE;
				sprint(self, "^3You are on speed\n");
			}
		}
	}
	else // if we're not in minstagib, continue. I added this else to replace the "return" which was here that broke the callhook for this function -- This code is nasty.
	{
		if (self.items & IT_STRENGTH)
		{
			play_countdown(self.strength_finished, "misc/poweroff.wav");
			self.effects = self.effects | (EF_BLUE | EF_ADDITIVE | EF_FULLBRIGHT);
			if (time > self.strength_finished)
			{
				self.items = self.items - (self.items & IT_STRENGTH);
				sprint(self, "^3Strength has worn off\n");
			}
		}
		else
		{
			if (time < self.strength_finished)
			{
				self.items = self.items | IT_STRENGTH;
				sprint(self, "^3Strength infuses your weapons with devastating power\n");
			}
		}
		if (self.items & IT_INVINCIBLE)
		{
			play_countdown(self.invincible_finished, "misc/poweroff.wav");
			self.effects = self.effects | (EF_RED | EF_ADDITIVE | EF_FULLBRIGHT);
			if (time > self.invincible_finished)
			{
				self.items = self.items - (self.items & IT_INVINCIBLE);
				sprint(self, "^3Shield has worn off\n");
			}
		}
		else
		{
			if (time < self.invincible_finished)
			{
				self.items = self.items | IT_INVINCIBLE;
				sprint(self, "^3Shield surrounds you\n");
			}
		}
		if (self.items & IT_SUPERWEAPON)
		{
			if (!WEPSET_CONTAINS_ANY_EA(self, WEPBIT_SUPERWEAPONS))
			{
				self.superweapons_finished = 0;
				self.items = self.items - (self.items & IT_SUPERWEAPON);
				sprint(self, "^3Superweapons have been lost\n");
			}
			else if (self.items & IT_UNLIMITED_SUPERWEAPONS)
			{
				// don't let them run out
			}
			else
			{
				play_countdown(self.superweapons_finished, "misc/poweroff.wav");
				if (time > self.superweapons_finished)
				{
					self.items = self.items - (self.items & IT_SUPERWEAPON);
					WEPSET_ANDNOT_EA(self, WEPBIT_SUPERWEAPONS);
					sprint(self, "^3Superweapons have broken down\n");
				}
			}
		}
		else if(WEPSET_CONTAINS_ANY_EA(self, WEPBIT_SUPERWEAPONS))
		{
			if (time < self.superweapons_finished || (self.items & IT_UNLIMITED_SUPERWEAPONS))
			{
				self.items = self.items | IT_SUPERWEAPON;
				sprint(self, "^3You now have a superweapon\n");
			}
			else
			{
				self.superweapons_finished = 0;
				WEPSET_ANDNOT_EA(self, WEPBIT_SUPERWEAPONS);
			}
		}
		else
		{
			self.superweapons_finished = 0;
		}
	}
	
	if(autocvar_g_nodepthtestplayers)
		self.effects = self.effects | EF_NODEPTHTEST;

	if(autocvar_g_fullbrightplayers)
		self.effects = self.effects | EF_FULLBRIGHT;

	// midair gamemode: damage only while in the air
	// if in midair mode, being on ground grants temporary invulnerability
	// (this is so that multishot weapon don't clear the ground flag on the
	// first damage in the frame, leaving the player vulnerable to the
	// remaining hits in the same frame)
	if (self.flags & FL_ONGROUND)
	if (g_midair)
		self.spawnshieldtime = max(self.spawnshieldtime, time + autocvar_g_midair_shieldtime);

	if (time >= game_starttime)
	if (time < self.spawnshieldtime)
		self.effects = self.effects | (EF_ADDITIVE | EF_FULLBRIGHT);

	MUTATOR_CALLHOOK(PlayerPowerups);
}

float CalcRegen(float current, float stable, float regenfactor, float regenframetime)
{
	if(current > stable)
		return current;
	else if(current > stable - 0.25) // when close enough, "snap"
		return stable;
	else
		return min(stable, current + (stable - current) * regenfactor * regenframetime);
}

float CalcRot(float current, float stable, float rotfactor, float rotframetime)
{
	if(current < stable)
		return current;
	else if(current < stable + 0.25) // when close enough, "snap"
		return stable;
	else
		return max(stable, current + (stable - current) * rotfactor * rotframetime);
}

float CalcRotRegen(float current, float regenstable, float regenfactor, float regenlinear, float regenframetime, float rotstable, float rotfactor, float rotlinear, float rotframetime, float limit)
{
	if(current > rotstable)
	{
		if(rotframetime > 0)
		{
			current = CalcRot(current, rotstable, rotfactor, rotframetime);
			current = max(rotstable, current - rotlinear * rotframetime);
		}
	}
	else if(current < regenstable)
	{
		if(regenframetime > 0)
		{
			current = CalcRegen(current, regenstable, regenfactor, regenframetime);
			current = min(regenstable, current + regenlinear * regenframetime);
		}
	}

	if(current > limit)
		current = limit;

	return current;
}

void player_regen (void)
{
	float minh, mina, minf, minm, maxh, maxa, maxf, maxm, limith, limita, limitf, limitm, max_mod, regen_mod, rot_mod, limit_mod;
	maxh = autocvar_g_balance_health_rotstable;
		if (maxh > 0 && self.health_stable_reduce > 0) {
			maxh = maxh - self.health_stable_reduce;
			if (maxh < 0) {
				maxh = 0;
			}
		}
	maxa = autocvar_g_balance_armor_rotstable;
		if (maxa > 0 && self.armor_stable_reduce > 0) {
			maxa = maxa - self.armor_stable_reduce;
			if (maxa < 0) {
				maxa = 0;
			}
		}
	maxf = autocvar_g_balance_fuel_rotstable;
	maxm = autocvar_g_balance_mana_rotstable;
		if (self.darkritual_mana_stable) {
			if (self.darkritual_mana_stable > autocvar_g_balance_mana_rotstable) {
				if (autocvar_sv_gameplayfix_darkritual_nomanastableadd) {
					//do nothing
				} else {
					maxm = self.darkritual_mana_stable;
				}
			}
		}
	
		if (maxm > 0 && self.mana_stable_reduce > 0) {
			maxm = maxm - self.mana_stable_reduce;
			if (maxm < 0) {
				maxm = 0;
			}
		}
	minh = autocvar_g_balance_health_regenstable;
		if (minh > 0 && self.health_stable_reduce > 0) {
			minh = minh - self.health_stable_reduce;
			if (minh < 0) {
				minh = 0;
			}
		}
	mina = autocvar_g_balance_armor_regenstable;
		if (mina > 0 && self.armor_stable_reduce > 0) {
			mina = mina - self.armor_stable_reduce;
			if (mina < 0) {
				mina = 0;
			}
		}
	minf = autocvar_g_balance_fuel_regenstable;
	minm = autocvar_g_balance_mana_regenstable;
		if (minm > 0 && self.mana_stable_reduce > 0) {
			minm = minm - self.mana_stable_reduce;
			if (minm < 0) {
				minm = 0;
			}
		}
	limith = autocvar_g_balance_health_limit;
	limita = autocvar_g_balance_armor_limit;
	limitf = autocvar_g_balance_fuel_limit;
	limitm = autocvar_g_balance_mana_limit;
	
	if (self.darkritual_mana_max) {
		if (self.darkritual_mana_max > autocvar_g_balance_mana_limit) {
			if (autocvar_sv_gameplayfix_darkritual_nomanastableadd) {
				//do nothing
			} else {
				limitm = self.darkritual_mana_max;
			}
		}
	}

	max_mod = regen_mod = rot_mod = limit_mod = 1;

	if (self.runes & RUNE_REGEN)
	{
		if (self.runes & CURSE_VENOM) // do we have both rune/curse?
		{
			regen_mod = autocvar_g_balance_rune_regen_combo_regenrate;
			max_mod = autocvar_g_balance_rune_regen_combo_hpmod;
			limit_mod = autocvar_g_balance_rune_regen_combo_limitmod;
		}
		else
		{
			regen_mod = autocvar_g_balance_rune_regen_regenrate;
			max_mod = autocvar_g_balance_rune_regen_hpmod;
			limit_mod = autocvar_g_balance_rune_regen_limitmod;
		}
	}
	else if (self.runes & CURSE_VENOM)
	{
		max_mod = autocvar_g_balance_curse_venom_hpmod;
		if (self.runes & RUNE_REGEN) // do we have both rune/curse?
			rot_mod = autocvar_g_balance_rune_regen_combo_rotrate;
		else
			rot_mod = autocvar_g_balance_curse_venom_rotrate;
		limit_mod = autocvar_g_balance_curse_venom_limitmod;
		//if (!self.runes & RUNE_REGEN)
		//	rot_mod = autocvar_g_balance_curse_venom_rotrate;
	}
	maxh = maxh * max_mod;
	//maxa = maxa * max_mod;
	//maxf = maxf * max_mod;
	minh = minh * max_mod;
	//mina = mina * max_mod;
	//minf = minf * max_mod;
	limith = limith * limit_mod;
	limita = limita * limit_mod;
	//limitf = limitf * limit_mod;
	limitm = limitm * limit_mod;

	if(g_lms && g_ca)
		rot_mod = 0;

	if (!g_minstagib && !g_ca && (!g_lms || autocvar_g_lms_regenerate))
	{
		self.armorvalue = CalcRotRegen(self.armorvalue, mina, autocvar_g_balance_armor_regen, autocvar_g_balance_armor_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished), maxa, autocvar_g_balance_armor_rot, autocvar_g_balance_armor_rotlinear, rot_mod * frametime * (time > self.pauserotarmor_finished), limita);
		self.health = CalcRotRegen(self.health, minh, autocvar_g_balance_health_regen, autocvar_g_balance_health_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished), maxh, autocvar_g_balance_health_rot, autocvar_g_balance_health_rotlinear, rot_mod * frametime * (time > self.pauserothealth_finished), limith);
		
		self.mana = CalcRotRegen(self.mana, minm, autocvar_g_balance_mana_regen, autocvar_g_balance_mana_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished), maxm, autocvar_g_balance_mana_rot, autocvar_g_balance_mana_rotlinear, rot_mod * frametime * (time > self.pauserotmana_finished), limitm);

		
		// if player rotted to death...  die!
		if(self.health < 1)
			if (self.event_damage)
				self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
	}

	if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
		self.ammo_fuel = CalcRotRegen(self.ammo_fuel, minf, autocvar_g_balance_fuel_regen, autocvar_g_balance_fuel_regenlinear, regen_mod * frametime * (time > self.pauseregen_finished) * (self.items & IT_FUEL_REGEN != 0), maxf, autocvar_g_balance_fuel_rot, autocvar_g_balance_fuel_rotlinear, rot_mod * frametime * (time > self.pauserotfuel_finished), limitf);
}

float zoomstate_set;
void SetZoomState(float z)
{
	if(z != self.zoomstate)
	{
		self.zoomstate = z;
		ClientData_Touch(self);
	}
	zoomstate_set = 1;
}

void GetPressedKeys(void) {
	MUTATOR_CALLHOOK(GetPressedKeys);
	if (self.movement_x > 0) // get if movement keys are pressed
	{	// forward key pressed
		self.pressedkeys |= KEY_FORWARD;
		self.pressedkeys &~= KEY_BACKWARD;
	}
	else if (self.movement_x < 0)
	{	// backward key pressed
		self.pressedkeys |= KEY_BACKWARD;
		self.pressedkeys &~= KEY_FORWARD;
	}
	else
	{	// no x input
		self.pressedkeys &~= KEY_FORWARD;
		self.pressedkeys &~= KEY_BACKWARD;
	}

	if (self.movement_y > 0)
	{	// right key pressed
		self.pressedkeys |= KEY_RIGHT;
		self.pressedkeys &~= KEY_LEFT;
	}
	else if (self.movement_y < 0)
	{	// left key pressed
		self.pressedkeys |= KEY_LEFT;
		self.pressedkeys &~= KEY_RIGHT;
	}
	else
	{	// no y input
		self.pressedkeys &~= KEY_RIGHT;
		self.pressedkeys &~= KEY_LEFT;
	}

	if (self.BUTTON_JUMP) // get if jump and crouch keys are pressed
		self.pressedkeys |= KEY_JUMP;
	else
		self.pressedkeys &~= KEY_JUMP;
	if (self.BUTTON_CROUCH)
		self.pressedkeys |= KEY_CROUCH;
	else
		self.pressedkeys &~= KEY_CROUCH;

	if (self.BUTTON_ATCK)
		self.pressedkeys |= KEY_ATCK;
	else
		self.pressedkeys &~= KEY_ATCK;
	if (self.BUTTON_ATCK2)
		self.pressedkeys |= KEY_ATCK2;
	else
		self.pressedkeys &~= KEY_ATCK2;
}

/*
======================
spectate mode routines
======================
*/

void SpectateCopy(entity spectatee) {
	other = spectatee;
	MUTATOR_CALLHOOK(SpectateCopy);
	self.armortype = spectatee.armortype;
	self.armorvalue = spectatee.armorvalue;
	self.ammo_cells = spectatee.ammo_cells;
	self.ammo_shells = spectatee.ammo_shells;
	self.ammo_nails = spectatee.ammo_nails;
	self.ammo_rockets = spectatee.ammo_rockets;
	self.ammo_fuel = spectatee.ammo_fuel;
	self.clip_load = spectatee.clip_load;
	self.clip_size = spectatee.clip_size;
	self.effects = spectatee.effects & EFMASK_CHEAP; // eat performance
	self.health = spectatee.health;
	self.impulse = 0;
	self.items = spectatee.items;
	self.last_pickup = spectatee.last_pickup;
	self.hit_time = spectatee.hit_time;
	self.metertime = spectatee.metertime;
	self.strength_finished = spectatee.strength_finished;
	self.invincible_finished = spectatee.invincible_finished;
	self.pressedkeys = spectatee.pressedkeys;
	WEPSET_COPY_EE(self, spectatee);
	self.switchweapon = spectatee.switchweapon;
	self.switchingweapon = spectatee.switchingweapon;
	self.weapon = spectatee.weapon;
	self.nex_charge = spectatee.nex_charge;
	self.nex_chargepool_ammo = spectatee.nex_chargepool_ammo;
	self.hagar_load = spectatee.hagar_load;
	self.minelayer_mines = spectatee.minelayer_mines;
	self.nukelayer_nukes = spectatee.nukelayer_nukes;
	self.punchangle = spectatee.punchangle;
	self.view_ofs = spectatee.view_ofs;
	self.velocity = spectatee.velocity;
	self.dmg_take = spectatee.dmg_take;
	self.dmg_save = spectatee.dmg_save;
	self.dmg_inflictor = spectatee.dmg_inflictor;
	self.v_angle = spectatee.v_angle;
	self.angles = spectatee.v_angle;
	self.stat_respawn_time = spectatee.stat_respawn_time;
	if(!self.BUTTON_USE)
		self.fixangle = TRUE;
	setorigin(self, spectatee.origin);
	setsize(self, spectatee.mins, spectatee.maxs);
	SetZoomState(spectatee.zoomstate);
    
    anticheat_spectatecopy(spectatee);
	self.hud = spectatee.hud;
	if(spectatee.vehicle)
    {
        self.fixangle = FALSE;
        //self.velocity = spectatee.vehicle.velocity;
        self.vehicle_health = spectatee.vehicle_health;
        self.vehicle_shield = spectatee.vehicle_shield;
        self.vehicle_energy = spectatee.vehicle_energy;
        self.vehicle_ammo1 = spectatee.vehicle_ammo1;
        self.vehicle_ammo2 = spectatee.vehicle_ammo2;
        self.vehicle_reload1 = spectatee.vehicle_reload1;
        self.vehicle_reload2 = spectatee.vehicle_reload2;

        msg_entity = self;
        
        WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
            WriteAngle(MSG_ONE,  spectatee.v_angle_x);
            WriteAngle(MSG_ONE,  spectatee.v_angle_y);
            WriteAngle(MSG_ONE,  spectatee.v_angle_z);

        //WriteByte (MSG_ONE, SVC_SETVIEW);
        //    WriteEntity(MSG_ONE, self);            
        //makevectors(spectatee.v_angle);
        //setorigin(self, spectatee.origin - v_forward * 400 + v_up * 300);*/    
    }
}

float SpectateUpdate() {
	if(!self.enemy)
	    return 0;		

	if (self == self.enemy)
		return 0;

	if(self.enemy.classname != "player")
		return 0;

	SpectateCopy(self.enemy);

	return 1;
}


// Returns next available player to spectate if g_ca_spectate_enemies == 0
entity CA_SpectateNext(entity start) {
	if (start.team == self.team) {
		return start;
	}
	
	other = start;
	// continue from current player
	while(other && other.team != self.team) {
		other = find(other, classname, "player");
	}
	
	if (!other) {
		// restart from begining
		other = find(other, classname, "player");
		while(other && other.team != self.team) {
			other = find(other, classname, "player");
		}
	}
	
	return other;
}

float SpectateNext(entity _prefer) {
	
	if(_prefer)
		other = _prefer;	
	else
		other = find(self.enemy, classname, "player");
	
	if (g_ca && !autocvar_g_ca_spectate_enemies && self.caplayer) {
		// CA and ca players when spectating enemies is forbidden
		other = CA_SpectateNext(other);
	} else {
		// other modes and ca spectators or spectating enemies is allowed
		if (!other)
			other = find(other, classname, "player");
	}
	
	if (other)
		self.enemy = other;

	if(self.enemy.classname == "player") {
	    /*if(self.enemy.vehicle)
	    {	   
            
            msg_entity = self;
            WriteByte(MSG_ONE, SVC_SETVIEW);
            WriteEntity(MSG_ONE, self.enemy);
            //stuffcmd(self, "set viewsize $tmpviewsize \n");
            
            self.movetype = MOVETYPE_NONE;
            accuracy_resend(self);
	    }
	    else 
	    {*/	        
            msg_entity = self;
            WriteByte(MSG_ONE, SVC_SETVIEW);
            WriteEntity(MSG_ONE, self.enemy);
            //stuffcmd(self, "set viewsize $tmpviewsize \n");
            self.movetype = MOVETYPE_NONE;
            accuracy_resend(self);

            if(!SpectateUpdate())
                PutObserverInServer();
        //}
        return 1;
	} else {
		return 0;
	}
}

/*
=============
ShowRespawnCountdown()

Update a respawn countdown display.
=============
*/
void ShowRespawnCountdown()
{
	float number;
	if(self.deadflag == DEAD_NO) // just respawned?
		return;
	else
	{
		number = ceil(self.respawn_time - time);
		if(number <= 0)
			return;
		if(number <= self.respawn_countdown)
		{
			self.respawn_countdown = number - 1;
			if(ceil(self.respawn_time - (time + 0.5)) == number) // only say it if it is the same number even in 0.5s; to prevent overlapping sounds
				AnnounceTo(self, strcat(ftos(number), ""));
		}
	}
}

.float prevent_join_msgtime;
void LeaveSpectatorMode_main()
{
		if(!teamplay || autocvar_g_campaign || autocvar_g_balance_teams || (self.wasplayer && autocvar_g_changeteam_banned) || self.team_forced > 0) {
			self.classname = "player";

			if(autocvar_g_campaign || autocvar_g_balance_teams)
				JoinBestTeam(self, FALSE, TRUE);

			if(autocvar_g_campaign)
				campaign_bots_may_start = 1;

			PutClientInServer();

			if(self.classname == "player")
				bprint ("^4", self.netname, "^4 is playing now\n");

			if(!autocvar_g_campaign)
			if (time < self.jointime + autocvar_welcome_message_time)
				Send_CSQC_Centerprint_Generic_Expire(self, CPID_MOTD); // clear MOTD

			if (self.prevent_join_msgtime)
			{
				Send_CSQC_Centerprint_Generic_Expire(self, CPID_PREVENT_JOIN);
				self.prevent_join_msgtime = 0;
			}

			return;
		} else {
			if (g_ca && self.caplayer) {
			}	// do nothing
			else
				stuffcmd(self,"menu_showteamselect\n");
			return;
		}
}

void LeaveSpectatorMode()
{
	if(nJoinAllowed(self)) {
		if (g_playerclass) {
			stuffcmd(self,"menu_showplayerclassselect\n");
			return;
		}
	
		LeaveSpectatorMode_main(); //See above
	}
	else {
		//player may not join because of g_maxplayers is set
		if (time - self.prevent_join_msgtime > 2)
		{
			Send_CSQC_Centerprint_Generic(self, CPID_PREVENT_JOIN, PREVENT_JOIN_TEXT, 0, 0);
			self.prevent_join_msgtime = time;
		}
	}
}

//This is for dealing with the playerclasses we added
void LeaveSpectatorMode_after_playerclass()
{
	if(nJoinAllowed(self)) { //Make sure again, just incase
		LeaveSpectatorMode_main(); //Executed after we decide player class
	}
}


/**
 * Determines whether the player is allowed to join. This depends on cvar
 * g_maxplayers, if it isn't used this function always return TRUE, otherwise
 * it checks whether the number of currently playing players exceeds g_maxplayers.
 * @return int number of free slots for players, 0 if none
 */
float nJoinAllowed(entity ignore) {
	if(!ignore)
	// this is called that way when checking if anyone may be able to join (to build qcstatus)
	// so report 0 free slots if restricted
	{
		if(autocvar_g_forced_team_otherwise == "spectate")
			return 0;
		if(autocvar_g_forced_team_otherwise == "spectator")
			return 0;
	}

	if(self.team_forced < 0)
		return 0; // forced spectators can never join

	// TODO simplify this
	entity e;
	float totalClients = 0;
	FOR_EACH_CLIENT(e)
		if(e != ignore)
			totalClients += 1;

	if (!autocvar_g_maxplayers)
		return maxclients - totalClients;

	float currentlyPlaying = 0;
	FOR_EACH_REALPLAYER(e)
		currentlyPlaying += 1;

	if(currentlyPlaying < autocvar_g_maxplayers)
		return min(maxclients - totalClients, autocvar_g_maxplayers - currentlyPlaying);

	return 0;
}

/**
 * Checks whether the client is an observer or spectator, if so, he will get kicked after
 * g_maxplayers_spectator_blocktime seconds
 */
void checkSpectatorBlock() {
	if(self.classname == "spectator" || self.classname == "observer") {
		if( time > (self.spectatortime + autocvar_g_maxplayers_spectator_blocktime) ) {
			sprint(self, "^7You were kicked from the server because you are spectator and spectators aren't allowed at the moment.\n");
			dropclient(self);
		}
	}
}

.float motd_actived_time; // used for both motd and campaign_message
void PrintWelcomeMessage()
{
	if (self.motd_actived_time == 0) { // is there already a message showing?
		if (autocvar_g_campaign) {
			if ((self.classname == "player" && self.BUTTON_INFO) || (self.classname != "player")) {
				self.motd_actived_time = time;
				Send_CSQC_Centerprint_Generic(self, CPID_MOTD, campaign_message, -1, 0);
			}
		} else {
			if ((time - self.jointime > autocvar_welcome_message_time) && self.BUTTON_INFO) {
				self.motd_actived_time = time;
				Send_CSQC_Centerprint_Generic(self, CPID_MOTD, getwelcomemessage(), -1, 0);
			}
		}
	} else { // showing MOTD or campaign message
		if (autocvar_g_campaign) {
			if (self.BUTTON_INFO)
				self.motd_actived_time = time;
			else if ((time - self.motd_actived_time > 2) && self.classname == "player") { // hide it some seconds after BUTTON_INFO has been released
				self.motd_actived_time = 0;
				Send_CSQC_Centerprint_Generic_Expire(self, CPID_MOTD);
			}
		} else {
			if ((time - self.jointime) > autocvar_welcome_message_time) {
				if (self.BUTTON_INFO)
					self.motd_actived_time = time;
				else if (time - self.motd_actived_time > 2) { // hide it some seconds after BUTTON_INFO has been released
					self.motd_actived_time = 0;
					Send_CSQC_Centerprint_Generic_Expire(self, CPID_MOTD);
				}
			}
		}
	}
}

void ObserverThink()
{
	float prefered_movetype;
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.flags &~= FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK && !self.version_mismatch) {
			self.flags &~= FL_JUMPRELEASED;
			if(SpectateNext(world) == 1) {
				self.classname = "spectator";
			}
		} else {
			prefered_movetype = ((!self.BUTTON_USE ? self.cvar_cl_clippedspectating : !self.cvar_cl_clippedspectating) ? MOVETYPE_FLY_WORLDONLY : MOVETYPE_NOCLIP);
			if (self.movetype != prefered_movetype)
				self.movetype = prefered_movetype;
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_JUMP)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &~= FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
	}

	PrintWelcomeMessage();
}

void SpectatorThink()
{
	if (self.flags & FL_JUMPRELEASED) {
		if (self.BUTTON_JUMP && !self.version_mismatch) {
			self.flags &~= FL_JUMPRELEASED;
			self.flags |= FL_SPAWNING;
		} else if(self.BUTTON_ATCK) {
			self.flags &~= FL_JUMPRELEASED;
			if(SpectateNext(world) == 1) {
				self.classname = "spectator";
			} else {
				self.classname = "observer";
				PutClientInServer();
			}
		} else if (self.BUTTON_ATCK2) {
			self.flags &~= FL_JUMPRELEASED;
			self.classname = "observer";
			PutClientInServer();
		} else {
			if(!SpectateUpdate())
				PutObserverInServer();
		}
	} else {
		if (!(self.BUTTON_ATCK || self.BUTTON_ATCK2)) {
			self.flags |= FL_JUMPRELEASED;
			if(self.flags & FL_SPAWNING)
			{
				self.flags &~= FL_SPAWNING;
				LeaveSpectatorMode();
				return;
			}
		}
		if(!SpectateUpdate())
			PutObserverInServer();
	}

	PrintWelcomeMessage();
	self.flags |= FL_CLIENT | FL_NOTARGET;
}

void PlayerUseKey()
{
	if(self.classname != "player")
		return;

	if(self.vehicle)
	{
		if(self.vehicle.vehicle_reloadplususe && !self.vehicle.vehicle_reloadplususeexit)
		{
			//Do nothing
		} else {
        		vehicles_exit(VHEF_NORMAL);
		}
        	return;
	}
	
	// a use key was pressed; call handlers
	MUTATOR_CALLHOOK(PlayerUseKey);
}

.float touchexplode_time;

/*
=============
PlayerPreThink

Called every frame for each client before the physics are run
=============
*/
.float usekeypressed;
void() nexball_setstatus;
.float items_added;
void PlayerPreThink (void)
{
	WarpZone_PlayerPhysics_FixVAngle();
	
	if not(self.handcuffed)
	{ if (self.prisonerlevel == 3)
	{
		//Needed to have chained prisoners rotate on the wheel etc.
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
	}
	}
	
	self.stat_game_starttime = game_starttime;
	self.stat_allow_oldnexbeam = autocvar_g_allow_oldnexbeam;
	self.stat_leadlimit = autocvar_leadlimit;

	if(g_arena || (g_ca && !allowed_to_spawn))
		self.stat_respawn_time = 0;
	else
		self.stat_respawn_time = self.respawn_time;

	if(frametime)
	{
		// physics frames: update anticheat stuff
		anticheat_prethink();
	}

	if(blockSpectators && frametime)
		// WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
		checkSpectatorBlock();

	zoomstate_set = 0;

	if(self.netname_previous != self.netname)
	{
		if(autocvar_sv_eventlog)
			GameLogEcho(strcat(":name:", ftos(self.playerid), ":", self.netname));
		if(self.netname_previous)
			strunzone(self.netname_previous);
		self.netname_previous = strzone(self.netname);
	}

	// version nagging
	if(self.version_nagtime)
		if(self.cvar_g_xonoticversion)
			if(time > self.version_nagtime)
			{
				// don't notify git users
				if(strstr(self.cvar_g_xonoticversion, "git", 0) < 0 && strstr(self.cvar_g_xonoticversion, "autobuild", 0) < 0)
				{
					if(strstr(autocvar_g_xonoticversion, "git", 0) >= 0 || strstr(autocvar_g_xonoticversion, "autobuild", 0) >= 0)
					{
						// notify release users if connecting to git
						dprint("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Xonotic ", autocvar_g_xonoticversion, " (beta)^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n");
						sprint(self, strcat("\{1}^1NOTE: ^7the server is running ^3Xonotic ", autocvar_g_xonoticversion, " (beta)^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n"));
					}
					else
					{
						float r;
						r = vercmp(self.cvar_g_xonoticversion, autocvar_g_xonoticversion);
						if(r < 0)
						{
							// give users new version
							dprint("^1NOTE^7 to ", self.netname, "^7 - ^3Xonotic ", autocvar_g_xonoticversion, "^7 is out, and you still have ^3Xonotic ", self.cvar_g_xonoticversion, "^1 - get the update from ^4http://www.xonotic.org/^1!\n");
							sprint(self, strcat("\{1}^1NOTE: ^3Xonotic ", autocvar_g_xonoticversion, "^7 is out, and you still have ^3Xonotic ", self.cvar_g_xonoticversion, "^1 - get the update from ^4http://www.xonotic.org/^1!\n"));
						}
						else if(r > 0)
						{
							// notify users about old server version
							print("^1NOTE^7 to ", self.netname, "^7 - the server is running ^3Xonotic ", autocvar_g_xonoticversion, "^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n");
							sprint(self, strcat("\{1}^1NOTE: ^7the server is running ^3Xonotic ", autocvar_g_xonoticversion, "^7, you have ^3Xonotic ", self.cvar_g_xonoticversion, "^1\n"));
						}
					}
				}
				self.version_nagtime = 0;
			}

	// GOD MODE info
	if(!(self.flags & FL_GODMODE)) if(self.max_armorvalue)
	{
		sprint(self, strcat("godmode saved you ", ftos(self.max_armorvalue), " units of damage, cheater!\n"));
		self.max_armorvalue = 0;
	}

#ifdef TETRIS
	if (TetrisPreFrame())
		return;
#endif

	MUTATOR_CALLHOOK(PlayerPreThink);

	if(!self.cvar_cl_newusekeysupported) // FIXME remove this - it was a stupid idea to begin with, we can JUST use the button
	{
		if(self.BUTTON_USE && !self.usekeypressed)
			PlayerUseKey();
		self.usekeypressed = self.BUTTON_USE;
	}

	PrintWelcomeMessage();

	if(self.classname == "player") {
//		if(self.netname == "Wazat")
//			bprint(self.classname, "\n");

		CheckRules_Player();

		if (intermission_running)
		{
			IntermissionThink ();	// otherwise a button could be missed between
			return;					// the think tics
		}

		//don't allow the player to turn around while game is paused!
		//or made of stone, or frozen (but note: not freezetag frozen)
		if(timeout_status == TIMEOUT_ACTIVE
		|| self.frozen) {
			// FIXME turn this into CSQC stuff
			self.v_angle = self.lastV_angle;
			self.angles = self.lastV_angle;
			self.fixangle = TRUE;
		} else if (self.stoned) {
			//Petrifaction does its other angles elsewhere
			self.v_angle = self.lastV_angle;
			self.fixangle = TRUE;
		}

		if(frametime)
		{
#ifndef NO_LEGACY_NETWORKING
			self.glowmod = colormapPaletteColor(self.clientcolors & 0x0F, TRUE) * 2;
#endif

			if(self.weapon == WEP_NEX && autocvar_g_balance_nex_charge)
			{
				self.weaponentity_glowmod_x = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_red_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);
				self.weaponentity_glowmod_y = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_green_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);
				self.weaponentity_glowmod_z = autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_blue_half * min(1, self.nex_charge / autocvar_g_balance_nex_charge_animlimit);

				if(self.nex_charge > autocvar_g_balance_nex_charge_animlimit)
				{
					self.weaponentity_glowmod_x = self.weaponentity_glowmod_x + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_red_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
					self.weaponentity_glowmod_y = self.weaponentity_glowmod_y + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_green_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
					self.weaponentity_glowmod_z = self.weaponentity_glowmod_z + autocvar_g_weapon_charge_colormod_hdrmultiplier * autocvar_g_weapon_charge_colormod_blue_full * (self.nex_charge - autocvar_g_balance_nex_charge_animlimit) / (1 - autocvar_g_balance_nex_charge_animlimit);
				}
			} else if (self.weapon == WEP_LIGHTSABREII) {
				self.weaponentity_glowmod_x = 1;
				self.weaponentity_glowmod_y = 0;
				self.weaponentity_glowmod_z = 0;

			} else if (self.weapon == WEP_LIGHTSABREIV) {
				self.weaponentity_glowmod_x = 0;
				self.weaponentity_glowmod_y = 1;
				self.weaponentity_glowmod_z = 0;
				
			} else if (self.weapon == WEP_LIGHTSABREXI) {
				self.weaponentity_glowmod_x = 0;
				self.weaponentity_glowmod_y = 0.93;
				self.weaponentity_glowmod_z = 0.8;
				
			} else if (self.weapon == WEP_TORCH) {
				self.weaponentity_glowmod_x = 1;
				self.weaponentity_glowmod_y = 0.5;
				self.weaponentity_glowmod_z = 0;
				
			} else if (self.weapon == WEP_ELECTRO) {
				if (autocvar_g_balance_electro_defaultcolormap && self.weaponentity.skin <= 0)
					self.weaponentity_glowmod = colormapPaletteColor(mod(autocvar_g_balance_electro_defaultcolormap - 1024, 16), 0); //Shirt
				else
					self.weaponentity_glowmod = colormapPaletteColor(self.clientcolors & 0x0F, TRUE) * 2;
			} else if (self.weapon == WEP_CRYLINK) {
				if (autocvar_g_balance_crylink_defaultcolormap && self.weaponentity.skin <= 0)
					self.weaponentity_glowmod = colormapPaletteColor(mod(autocvar_g_balance_crylink_defaultcolormap - 1024, 16), 0); //Shirt
				else
					self.weaponentity_glowmod = colormapPaletteColor(self.clientcolors & 0x0F, TRUE) * 2;
			}
			else
				self.weaponentity_glowmod = colormapPaletteColor(self.clientcolors & 0x0F, TRUE) * 2;

			player_powerups();
		}

		if (g_minstagib)
			minstagib_ammocheck();

		if (self.deadflag != DEAD_NO)
		{
			float button_pressed, force_respawn;
			if(self.personal && g_race_qualifying)
			{
				if(time > self.respawn_time)
				{
					self.respawn_time = time + 1; // only retry once a second
					respawn();
					self.impulse = 141;
				}
			}
			else
			{
				if(frametime)
					player_anim();
				button_pressed = (self.BUTTON_ATCK || self.BUTTON_JUMP || self.BUTTON_ATCK2 || self.BUTTON_HOOK || self.BUTTON_USE);
				force_respawn = (g_lms || g_ca || g_cts || autocvar_g_forced_respawn);
				if (self.deadflag == DEAD_DYING)
				{
					if(force_respawn)
						self.deadflag = DEAD_RESPAWNING;
					else if(!button_pressed)
						self.deadflag = DEAD_DEAD;
				}
				else if (self.deadflag == DEAD_DEAD)
				{
					if(button_pressed)
						self.deadflag = DEAD_RESPAWNABLE;
				}
				else if (self.deadflag == DEAD_RESPAWNABLE)
				{
					if(!button_pressed)
						self.deadflag = DEAD_RESPAWNING;
				}
				else if (self.deadflag == DEAD_RESPAWNING)
				{
					if(time > self.respawn_time)
					{
						self.respawn_time = time + 1; // only retry once a second
						respawn();
					}
				}
				ShowRespawnCountdown();
			}

			// if respawning, invert stat_respawn_time to indicate this, the client translates it
			if(self.deadflag == DEAD_RESPAWNING && self.stat_respawn_time > 0)
				self.stat_respawn_time *= -1;

			return;
		}
		// FIXME from now on self.deadflag is always 0 (and self.health is never < 1)
		// so (self.deadflag == DEAD_NO) is always true in the code below

		if(g_touchexplode)
		if(time > self.touchexplode_time)
		if(self.classname == "player")
		if(self.deadflag == DEAD_NO)
		if not(IS_INDEPENDENT_PLAYER(self))
		FOR_EACH_PLAYER(other) if(self != other)
		{
			if(time > other.touchexplode_time)
			if(other.deadflag == DEAD_NO)
			if not(IS_INDEPENDENT_PLAYER(other))
			if(boxesoverlap(self.absmin, self.absmax, other.absmin, other.absmax))
			{
				PlayerTouchExplode(self, other);
				self.touchexplode_time = other.touchexplode_time = time + 0.2;
			}
		}

		if(g_lms && !self.deadflag && autocvar_g_lms_campcheck_interval)
		{
			vector dist;

			// calculate player movement (in 2 dimensions only, so jumping on one spot doesn't count as movement)
			dist = self.prevorigin - self.origin;
			dist_z = 0;
			self.lms_traveled_distance += fabs(vlen(dist));

			if((autocvar_g_campaign && !campaign_bots_may_start) || (time < game_starttime))
			{
				self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval*2;
				self.lms_traveled_distance = 0;
			}

			if(time > self.lms_nextcheck)
			{
				//sprint(self, "distance: ", ftos(self.lms_traveled_distance), "\n");
				if(self.lms_traveled_distance < autocvar_g_lms_campcheck_distance)
				{
					centerprint(self, autocvar_g_lms_campcheck_message);
					// FIXME KadaverJack: gibbing player here causes playermodel to bounce around, instead of eye.md3
					// I wasn't able to find out WHY that happens, so I put a workaround in place that shall prevent players from being gibbed :(
					Damage(self, self, self, bound(0, autocvar_g_lms_campcheck_damage, self.health + self.armorvalue * autocvar_g_balance_armor_blockpercent + 5), DEATH_CAMP, self.origin, '0 0 0');
				}
				self.lms_nextcheck = time + autocvar_g_lms_campcheck_interval;
				self.lms_traveled_distance = 0;
			}
		}

		self.prevorigin = self.origin;

		if (!self.vehicle)
		if (((self.BUTTON_CROUCH && !self.hook.state) || self.health <= g_bloodloss
		|| ( ((self.permhobbled_l || self.temphobbled_l) && (self.permhobbled_r || self.temphobbled_r))
		  || ((self.permhobbled_l || self.temphobbled_l || self.permhobbled_r || self.temphobbled_r) && self.parthobbledtime) )
		) && self.animstate_startframe != self.anim_melee_x && !self.freezetag_frozen && !self.frozen && !self.stoned && (self.prisonerlevel < 3)) // prevent crouching if using melee attack
		{
			if (!self.crouch)
			{
				self.crouch = TRUE;
				self.view_ofs = PL_CROUCH_VIEW_OFS;
				setsize (self, PL_CROUCH_MIN, PL_CROUCH_MAX);
				// setanim(self, self.anim_duck, FALSE, TRUE, TRUE); // this anim is BROKEN anyway
			}
		}
		else
		{
			if (self.crouch)
			{
				tracebox(self.origin, PL_MIN, PL_MAX, self.origin, FALSE, self);
				if (!trace_startsolid)
				{
					self.crouch = FALSE;
					self.view_ofs = PL_VIEW_OFS;
					setsize (self, PL_MIN, PL_MAX);
				}
			}
		}

		if(self.health <= g_bloodloss && self.deadflag == DEAD_NO)
		{
			if(self.bloodloss_timer < time)
			{
				if(!self.freezetag_frozen) {
					if (self.event_damage) {
						self.event_damage(self, self, 1, DEATH_ROT, self.origin, '0 0 0');
					}
				}
				self.bloodloss_timer = time + 0.5 + random() * 0.5;
			}
		}

		FixPlayermodel();

		GrapplingHookFrame();

		// LordHavoc: allow firing on move frames (sub-ticrate), this gives better timing on slow servers
		//if(frametime)
		{
			self.items &~= self.items_added;

			W_WeaponFrame();

			self.items_added = 0;
			if(self.items & IT_JETPACK)
				if(self.items & IT_FUEL_REGEN || self.ammo_fuel >= 0.01)
					self.items_added |= IT_FUEL;

			self.items |= self.items_added;
		}

		player_regen();

		// rot nex charge to the charge limit
		if(autocvar_g_balance_nex_charge_rot_rate && self.nex_charge > autocvar_g_balance_nex_charge_limit && self.nex_charge_rottime < time)
			self.nex_charge = bound(autocvar_g_balance_nex_charge_limit, self.nex_charge - autocvar_g_balance_nex_charge_rot_rate * frametime / W_TICSPERFRAME, 1);

		if(frametime)
			player_anim();

		if(g_nexball)
			nexball_setstatus();
		
		// secret status
		secrets_setstatus();
		
		// monsters status
		monsters_setstatus();
		
		self.dmg_team = max(0, self.dmg_team - autocvar_g_teamdamage_resetspeed * frametime);

		//self.angles_y=self.v_angle_y + 90;   // temp
	} else if(gameover) {
		if (intermission_running)
			IntermissionThink ();	// otherwise a button could be missed between
		return;
	} else if(self.classname == "observer") {
		ObserverThink();
	} else if(self.classname == "spectator") {
		SpectatorThink();
	}

	if(!zoomstate_set)
		SetZoomState(self.BUTTON_ZOOM || self.BUTTON_ZOOMSCRIPT || (self.BUTTON_ATCK2 && self.weapon == WEP_NEX) || (self.BUTTON_ATCK2 && self.weapon == WEP_LRR) || (self.BUTTON_ATCK2 && self.weapon == WEP_RIFLE && autocvar_g_balance_rifle_secondary == 0));

	float oldspectatee_status;
	oldspectatee_status = self.spectatee_status;
	if(self.classname == "spectator")
		self.spectatee_status = num_for_edict(self.enemy);
	else if(self.classname == "observer")
		self.spectatee_status = num_for_edict(self);
	else
		self.spectatee_status = 0;
	if(self.spectatee_status != oldspectatee_status)
	{
		ClientData_Touch(self);
		if(g_race || g_cts)
			race_InitSpectator();
	}

	if(self.teamkill_soundtime)
	if(time > self.teamkill_soundtime)
	{
		self.teamkill_soundtime = 0;

		entity oldpusher, oldself;

		oldself = self; self = self.teamkill_soundsource;
		oldpusher = self.pusher; self.pusher = oldself;

		PlayerSound(playersound_teamshoot, CH_VOICE, VOICETYPE_LASTATTACKER_ONLY);

		self.pusher = oldpusher;
		self = oldself;
	}

	if(self.taunt_soundtime)
	if(time > self.taunt_soundtime)
	{
		self.taunt_soundtime = 0;
		PlayerSound(playersound_taunt, CH_VOICE, VOICETYPE_AUTOTAUNT);
	}

	target_voicescript_next(self);

	// if a player goes unarmed after holding a loaded weapon, empty his clip size and remove the crosshair ammo ring
	if(!self.weapon)
		self.clip_load = self.clip_size = 0;
}

float isInvisibleString(string s)
{
	float i, n, c;
	s = strdecolorize(s);
	for((i = 0), (n = strlen(s)); i < n; ++i)
	{
		c = str2chr(s, i);
		switch(c)
		{
			case 0:
			case 32: // space
				break;
			case 192: // charmap space
				if (!autocvar_utf8_enable)
					break;
				return FALSE;
			case 160: // space in unicode fonts
			case 0xE000 + 192: // utf8 charmap space
				if (autocvar_utf8_enable)
					break;
			default:
				return FALSE;
		}
	}
	return TRUE;
}

/*
=============
PlayerPostThink

Called every frame for each client after the physics are run
=============
*/
.float idlekick_lasttimeleft;
.entity showheadshotbbox;
void showheadshotbbox_think()
{
	if(self.owner.showheadshotbbox != self)
	{
		remove(self);
		return;
	}
	self.nextthink = time;
	setorigin(self, self.owner.origin);
	setsize(self, GetHeadshotMins(self.owner), GetHeadshotMaxs(self.owner));
}
void PlayerPostThink (void)
{
	// Savage: Check for nameless players
	if (isInvisibleString(self.netname)) {
		self.netname = "Player";
		stuffcmd(self, strcat("name ", self.netname, substring(ftos(random()), 2, -1), "\n"));
	}

	if(sv_maxidle && frametime) // WORKAROUND: only use dropclient in server frames (frametime set). Never use it in cl_movement frames (frametime zero).
	{
		if (time - self.parm_idlesince < 1) // instead of (time == self.parm_idlesince) to support sv_maxidle <= 10
		{
			if(self.idlekick_lasttimeleft)
			{
				Send_CSQC_Centerprint_Generic_Expire(self, CPID_DISCONNECT_IDLING);
				self.idlekick_lasttimeleft = 0;
			}
		}
		else
		{
			float timeleft;
			timeleft = ceil(sv_maxidle - (time - self.parm_idlesince));
			if(timeleft == min(10, sv_maxidle - 1)) // - 1 to support sv_maxidle <= 10
			{
				if(!self.idlekick_lasttimeleft)
					Send_CSQC_Centerprint_Generic(self, CPID_DISCONNECT_IDLING, "^3Stop idling!\n^3Disconnecting in %d seconds...", 1, timeleft);
			}
			if(timeleft <= 0)
			{
				bprint("^3", self.netname, "^3 was kicked for idling.\n");
				AnnounceTo(self, "terminated");
				dropclient(self);
				return;
			}
			else if(timeleft <= 10)
			{
				if(timeleft != self.idlekick_lasttimeleft)
					AnnounceTo(self, ftos(timeleft));
				self.idlekick_lasttimeleft = timeleft;
			}
		}
	}

#ifdef TETRIS
	if(self.impulse == 100)
		ImpulseCommands();
	if (!TetrisPostFrame())
	{
#endif

	CheatFrame();

	//CheckPlayerJump();

	if(self.classname == "player") {
		CheckRules_Player();
		UpdateChatBubble();
		if (self.impulse)
			ImpulseCommands();
		if (intermission_running)
			return;		// intermission or finale
		GetPressedKeys();
	}
	
#ifdef TETRIS
	}
#endif

	/*
	float i;
	for(i = 0; i < 1000; ++i)
	{
		vector end;
		end = self.origin + '0 0 1024' + 512 * randomvec();
		tracebox(self.origin, self.mins, self.maxs, end, MOVE_NORMAL, self);
		if(trace_fraction < 1)
		if(!(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT))
		{
			print("I HIT SOLID: ", vtos(self.origin), " -> ", vtos(end), "\n");
			break;
		}
	}
	*/

	//pointparticles(particleeffectnum("machinegun_impact"), self.origin + self.view_ofs + '0 0 7', '0 0 0', 1);

	if(self.waypointsprite_attachedforcarrier)
		WaypointSprite_UpdateHealth(self.waypointsprite_attachedforcarrier, '1 0 0' * healtharmor_maxdamage(self.health, self.armorvalue, autocvar_g_balance_armor_blockpercent));

	if(self.classname == "player" && self.deadflag == DEAD_NO && autocvar_r_showbboxes)
	{
		if(!self.showheadshotbbox)
		{
			self.showheadshotbbox = spawn();
			self.showheadshotbbox.classname = "headshotbbox";
			self.showheadshotbbox.owner = self;
			self.showheadshotbbox.think = showheadshotbbox_think;
			self.showheadshotbbox.nextthink = time;
			self = self.showheadshotbbox;
			self.think();
			self = self.owner;
		}
	}
	else
	{
		if(self.showheadshotbbox)
			if(self.showheadshotbbox && !wasfreed(self.showheadshotbbox))
                remove(self.showheadshotbbox);
	}

	playerdemo_write();

	if((g_cts || g_race) && self.cvar_cl_allow_uidtracking == 1 && self.cvar_cl_allow_uid2name == 1)
	{
		if not(self.stored_netname)
			self.stored_netname = strzone(uid2name(self.crypto_idfp));
		if(self.stored_netname != self.netname)
		{
			db_put(ServerProgsDB, strcat("/uid2name/", self.crypto_idfp), self.netname);
			strunzone(self.stored_netname);
			self.stored_netname = strzone(self.netname);
		}
	}

	/*
	if(g_race)
		dprint(sprintf("%f %.6f\n", time, race_GetFractionalLapCount(self)));
	*/

	CSQCMODEL_AUTOUPDATE();
}
