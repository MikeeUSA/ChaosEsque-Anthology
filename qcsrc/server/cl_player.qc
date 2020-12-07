.entity accuracy;
.float accuracy_frags[WEP_MAXCOUNT];

float weaponstats_buffer;

void WeaponStats_Init()
{
	if(autocvar_sv_weaponstats_file != "")
		weaponstats_buffer = buf_create();
	else
		weaponstats_buffer = -1;
}

#define WEAPONSTATS_GETINDEX(awep,abot,vwep,vbot) (((vwep) + (awep) * (WEP_LAST - WEP_FIRST + 1) - (WEP_FIRST + WEP_FIRST * (WEP_LAST - WEP_FIRST + 1))) * 4 + (abot) * 2 + (vbot))

void WeaponStats_ready(entity fh, entity pass, float status)
{
	float i, j, n, ibot, jbot, idx;
	vector v;
	string prefix, s;
	switch(status)
	{
		case URL_READY_CANWRITE:
			// we can write
			prefix = strcat(autocvar_hostname, "\t", GetGametype(), "_", GetMapname(), "\t");
			url_fputs(fh, "#begin statsfile\n");
			url_fputs(fh, strcat("#date ", strftime(TRUE, "%a %b %e %H:%M:%S %Z %Y"), "\n"));
#ifdef WATERMARK
			url_fputs(fh, strcat("#version ", WATERMARK, "\n"));
#endif
			url_fputs(fh, strcat("#config ", ftos(crc16(FALSE, cvar_purechanges)), "\n"));
			url_fputs(fh, strcat("#cvar_purechanges ", ftos(cvar_purechanges_count), "\n"));
			n = tokenizebyseparator(cvar_purechanges, "\n");
			for(i = 0; i < n; ++i)
				url_fputs(fh, strcat("#cvar_purechange ", argv(i), "\n"));
			for(i = WEP_FIRST; i <= WEP_LAST; ++i) for(ibot = 0; ibot <= 1; ++ibot)
				for(j = WEP_FIRST; j <= WEP_LAST; ++j) for(jbot = 0; jbot <= 1; ++jbot)
				{
					idx = WEAPONSTATS_GETINDEX(i, ibot, j, jbot);
					v = stov(bufstr_get(weaponstats_buffer, idx));
					if(v != '0 0 0')
					{
						//vector is: kills hits damage
						url_fputs(fh, sprintf("%s%d %d\t%d %d\t", prefix, i, ibot, j, jbot));
						url_fputs(fh, sprintf("%d %d %g\n", v_x, v_y, v_z));
					}
				}
			url_fputs(fh, "#end\n\n");
			url_fclose(fh);
			break;
		case URL_READY_CANREAD:
			// url_fclose is processing, we got a response for writing the data
			// this must come from HTTP
			print("Got response from weapon stats server:\n");
			while((s = url_fgets(fh)))
				print("  ", s, "\n");
			print("End of response.\n");
			url_fclose(fh);
			break;
		case URL_READY_CLOSED:
			// url_fclose has finished
			print("Weapon stats written\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
		case URL_READY_ERROR:
		default:
			print("Weapon stats writing failed: ", ftos(status), "\n");
			buf_del(weaponstats_buffer);
			weaponstats_buffer = -1;
			break;
	}
}

void WeaponStats_Shutdown()
{
	if(weaponstats_buffer < 0)
		return;
	if(autocvar_sv_weaponstats_file != "")
	{
		url_multi_fopen(autocvar_sv_weaponstats_file, FILE_APPEND, WeaponStats_ready, world);
	}
	else
	{
		buf_del(weaponstats_buffer);
		weaponstats_buffer = -1;
	}
}

void WeaponStats_LogItem(float awep, float abot, float vwep, float vbot, vector item)
{
	float idx;
	if(weaponstats_buffer < 0)
		return;
	if(awep < WEP_FIRST || vwep < WEP_FIRST)
		return;
	if(awep > WEP_LAST || vwep > WEP_LAST)
		return;
	idx = WEAPONSTATS_GETINDEX(awep,abot,vwep,vbot);
	bufstr_set(weaponstats_buffer, idx, vtos(stov(bufstr_get(weaponstats_buffer, idx)) + item));
}
void WeaponStats_LogDamage(float awep, float abot, float vwep, float vbot, float damage)
{
	if(damage < 0)
		error("negative damage?");
	WeaponStats_LogItem(awep, abot, vwep, vbot, '0 0 1' * damage + '0 1 0');
}
void WeaponStats_LogKill(float awep, float abot, float vwep, float vbot)
{
	WeaponStats_LogItem(awep, abot, vwep, vbot, '1 0 0');
}

// changes by LordHavoc on 03/29/04 and 03/30/04 at Vermeulen's request
// merged player_run and player_stand to player_anim
// added death animations to player_anim
// can now spawn thrown weapons from anywhere, not just from players
// thrown weapons now fade out after 20 seconds
// created PlayerGib function
// PlayerDie no longer uses hitloc or damage
// PlayerDie now supports dying animations as well as gibbing
// cleaned up PlayerDie a lot
// added CopyBody

.entity pusher;
.float pushltime;
.float istypefrag;

.float CopyBody_nextthink;
.void(void) CopyBody_think;
void CopyBody_Think(void)
{
	if(self.CopyBody_nextthink && time > self.CopyBody_nextthink)
	{
		self.CopyBody_think();
		if(wasfreed(self))
			return;
		self.CopyBody_nextthink = self.nextthink;
		self.CopyBody_think = self.think;
		self.think = CopyBody_Think;
	}
	CSQCMODEL_AUTOUPDATE();
	self.nextthink = time;
}
string player_getbone_phal();
void CopyBody(float keepvelocity)
{
	entity oldself;
	if (self.effects & EF_NODRAW)
		return;	
	self.getbone_phal = player_getbone_phal();
	oldself = self;
	self = spawn();
	self.enemy = oldself;
	self.lip = oldself.lip;
	self.colormap = oldself.colormap;
	self.iscreature = oldself.iscreature;
	self.teleportable = oldself.teleportable;
	self.damagedbycontents = oldself.damagedbycontents;
	self.angles = oldself.angles;
	self.avelocity = oldself.avelocity;
	self.classname = "body";
	self.damageforcescale = oldself.damageforcescale;
	self.effects = oldself.effects;
	self.glowmod = oldself.glowmod;
	self.event_damage = oldself.event_damage;
	self.animstate_startframe = oldself.animstate_startframe;
	self.animstate_numframes = oldself.animstate_numframes;
	self.animstate_framerate = oldself.animstate_framerate;
	self.animstate_starttime = oldself.animstate_starttime;
	self.animstate_endtime = oldself.animstate_endtime;
	self.animstate_override = oldself.animstate_override;
	self.animstate_looping = oldself.animstate_looping;
	self.dphitcontentsmask = oldself.dphitcontentsmask;
	self.death_time = oldself.death_time;
	self.frame = oldself.frame;
	self.pain_finished = oldself.pain_finished;
	self.health = oldself.health;
	self.armorvalue = oldself.armorvalue;
	self.armortype = oldself.armortype;
	self.mana = oldself.mana;
	self.model = oldself.model;
	self.modelindex = oldself.modelindex;
	self.skin = oldself.skin;
	self.species = oldself.species;
	self.skincolor = oldself.skincolor;
	self.sex = oldself.sex;
	self.getbone_phal = oldself.getbone_phal;
	if (oldself.sex == SEX_MALE)
	{
		if (oldself.body_phal)
		if (oldself.body_phal.alpha == 1 && (oldself.getbone_phal != ""))
		{
			self.body_phal = spawn();
			self.body_phal.scale = oldself.body_phal.scale;
			self.body_phal.effects = oldself.body_phal.effects;
			self.body_phal.colormod = oldself.body_phal.colormod;
			self.body_phal.alpha = oldself.body_phal.alpha;
			self.body_phal.skin = oldself.body_phal.skin;
			self.body_phal.stoneskin = oldself.body_phal.stoneskin;
			self.body_phal.cnt = oldself.body_phal.cnt;
			self.body_phal.modelindex = oldself.body_phal.modelindex;
			setmodel(self.body_phal,  oldself.body_phal.model);
			self.body_phal.angles = oldself.body_phal.angles;
			setattachment(self.body_phal, self, oldself.getbone_phal);
			setorigin(self.body_phal, oldself.body_phal.origin);
		}
	}
	self.plweight = oldself.plweight;
	self.age = oldself.age;
	self.stonedorigin = oldself.stonedorigin;
	self.stonedangles = oldself.stonedangles;
	self.stoneskin = oldself.stoneskin;
	self.realskin = oldself.realskin;
	self.movetype = oldself.movetype;
	self.solid = oldself.solid;
	self.ballistics_density = oldself.ballistics_density;
	self.takedamage = oldself.takedamage;
	self.customizeentityforclient = oldself.customizeentityforclient;
	self.uncustomizeentityforclient = oldself.uncustomizeentityforclient;
	self.uncustomizeentityforclient_set = oldself.uncustomizeentityforclient_set;
	if (keepvelocity == 1)
		self.velocity = oldself.velocity;
	self.oldvelocity = self.velocity;
	self.alpha = oldself.alpha;
	self.fade_time = oldself.fade_time;
	self.fade_rate = oldself.fade_rate;
	//self.weapon = oldself.weapon;
	setorigin(self, oldself.origin);
	setsize(self, oldself.mins, oldself.maxs);
	self.prevorigin = oldself.origin;
	self.reset = SUB_Remove;

	Drag_MoveDrag(oldself, self);

	if(self.colormap <= maxclients && self.colormap > 0)
		self.colormap = 1024 + oldself.clientcolors;

	CSQCMODEL_AUTOINIT();
	self.CopyBody_nextthink = oldself.nextthink;
	self.CopyBody_think = oldself.think;
	self.nextthink = time;
	self.think = CopyBody_Think;

	self = oldself;
}

float player_getspecies()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_species;
	get_model_parameters(string_null, 0);
	if(s < 0)
		return SPECIES_HUMAN;
	return s;
}

float player_getskincolor()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_skincolor;
	get_model_parameters(string_null, 0);
	if(s < -1)
		return SKINCOLOR_UNKNOWN;
	return s;
}

float player_getstoneskin()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_stoneskin;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getage()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_age;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getweight()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_weight;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getsex()
{
	string s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_sex;
	get_model_parameters(string_null, 0);
	if (s == "Male")
		return SEX_MALE;
	else if (s == "Female")
		return SEX_FEMALE;
	else if (s == "Hermaphrodite" || s == "Intersexed")
		return SEX_HERMAPHRODITE;
	else if (s == "Eunich")
		return SEX_EUNICH;
	else if (s == "None")
		return SEX_NONE;
	else
		return SEX_UNKNOWN;
}

string player_getbone_phal()
{
	string s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_setpos()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_setpos;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_setangle()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_setangle;
	get_model_parameters(string_null, 0);
	return s;
}

//Normal
float player_getbone_phal_posx()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_posx;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_posy()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_posy;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_posz()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_posz;
	get_model_parameters(string_null, 0);
	return s;
}

//If cut
float player_getbone_phal_pos2x()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_pos2x;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_pos2y()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_pos2y;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_pos2z()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_pos2z;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_anglex()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_anglex;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_angley()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_angley;
	get_model_parameters(string_null, 0);
	return s;
}

float player_getbone_phal_anglez()
{
	float s;
	get_model_parameters(self.model, self.skin);
	s = get_model_parameters_bone_phal_anglez;
	get_model_parameters(string_null, 0);
	return s;
}

void player_setupanimsformodel()
{
	// defaults for legacy .zym models without animinfo files
	self.anim_die1 = animfixfps(self, '0 1 0.5'); // 2 seconds
	self.anim_die2 = animfixfps(self, '1 1 0.5'); // 2 seconds
	self.anim_draw = animfixfps(self, '2 1 3');
	// self.anim_duck = '3 1 100'; // This anim is broken, use slot 3 as a new free slot in the future ;)
	self.anim_duckwalk = animfixfps(self, '4 1 1');
	self.anim_duckjump = '5 1 100'; // NOTE: zym anims keep playing until changed, so this only has to start the anim, landing will end it
	self.anim_duckidle = animfixfps(self, '6 1 1');
	self.anim_idle = animfixfps(self, '7 1 1');
	self.anim_jump = '8 1 100'; // NOTE: zym anims keep playing until changed, so this only has to start the anim, landing will end it
	self.anim_pain1 = animfixfps(self, '9 1 2'); // 0.5 seconds
	self.anim_pain2 = animfixfps(self, '10 1 2'); // 0.5 seconds
	self.anim_shoot = animfixfps(self, '11 1 5'); // analyze models and set framerate
	self.anim_taunt = animfixfps(self, '12 1 0.33');
	self.anim_run = animfixfps(self, '13 1 1');
	self.anim_runbackwards = animfixfps(self, '14 1 1');
	self.anim_strafeleft = animfixfps(self, '15 1 1');
	self.anim_straferight = animfixfps(self, '16 1 1');
	//self.anim_dead1 = animfixfps(self, '17 1 1');
	//self.anim_dead2 = animfixfps(self, '18 1 1');
	self.anim_forwardright = animfixfps(self, '19 1 1');
	self.anim_forwardleft = animfixfps(self, '20 1 1');
	self.anim_backright = animfixfps(self, '21 1 1');
	self.anim_backleft  = animfixfps(self, '22 1 1');
	self.anim_melee = animfixfps(self, '23 1 1');
	self.anim_duckwalkbackwards = animfixfps(self, '24 1 1');
	self.anim_duckwalkstrafeleft = animfixfps(self, '25 1 1');
	self.anim_duckwalkstraferight = animfixfps(self, '26 1 1');
	self.anim_duckwalkforwardright = animfixfps(self, '27 1 1');
	self.anim_duckwalkforwardleft = animfixfps(self, '28 1 1');
	self.anim_duckwalkbackright = animfixfps(self, '29 1 1');
	self.anim_duckwalkbackleft  = animfixfps(self, '30 1 1');
	// TODO introspect models for finding right "fps" value (1/duration)
	// reset animstate now
	setanim(self, self.anim_idle, TRUE, FALSE, TRUE);
}

void player_anim (void)
{
	updateanim(self);
	if (self.weaponentity)
		updateanim(self.weaponentity);

	if (self.deadflag != DEAD_NO)
		return;

	if (!self.animstate_override)
	{
		if (self.freezetag_frozen || self.frozen || self.stoned)
			setanim(self, self.anim_idle, TRUE, FALSE, FALSE);
		else if (!(self.flags & FL_ONGROUND) || self.BUTTON_JUMP)
		{
			if (self.crouch)
			{
				if (self.animstate_startframe != self.anim_duckjump_x) // don't perform another trace if already playing the crouch jump anim
				{
					traceline(self.origin + '0 0 1' * PL_CROUCH_MIN_z, self.origin + '0 0 1' * (PL_CROUCH_MIN_z - autocvar_sv_player_jumpanim_minfall), TRUE, self);
					if(!trace_startsolid && trace_fraction == 1 || !(self.animstate_startframe == self.anim_duckwalk_x || self.animstate_startframe == self.anim_duckidle_x)) // don't get stuck on non-crouch anims
					{
						setanim(self, self.anim_duckjump, FALSE, TRUE, self.restart_jump);
						self.restart_jump = FALSE;
					}
				}
			}
			else
			{
                if (self.animstate_startframe != self.anim_jump_x) // don't perform another trace if already playing the jump anim
                {
                    traceline(self.origin + '0 0 1' * PL_MIN_z, self.origin + '0 0 1' * (PL_MIN_z - autocvar_sv_player_jumpanim_minfall), TRUE, self);
                    if(!trace_startsolid && trace_fraction == 1 || self.animstate_startframe == self.anim_idle_x || (self.animstate_startframe == self.anim_melee_x && time - self.animstate_starttime >= 21/20)) // don't get stuck on idle animation in midair, nor melee after it finished
                    {
                        setanim(self, self.anim_jump, FALSE, TRUE, self.restart_jump);
                        self.restart_jump = FALSE;
                    }
                }
			}
		}
		else if (self.crouch)
		{
			if (self.movement_x > 0 && self.movement_y == 0)
				setanim(self, self.anim_duckwalk, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y == 0)
				setanim(self, self.anim_duckwalkbackwards, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y > 0)
				setanim(self, self.anim_duckwalkstraferight, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y < 0)
				setanim(self, self.anim_duckwalkstrafeleft, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y > 0)
				setanim(self, self.anim_duckwalkforwardright, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y < 0)
				setanim(self, self.anim_duckwalkforwardleft, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y > 0)
				setanim(self, self.anim_duckwalkbackright, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y < 0)
				setanim(self, self.anim_duckwalkbackleft, TRUE, FALSE, FALSE);
			else
				setanim(self, self.anim_duckidle, TRUE, FALSE, FALSE);
		}
		else if ((self.movement_x * self.movement_x + self.movement_y * self.movement_y) > 20)
		{
			if (self.movement_x > 0 && self.movement_y == 0)
				setanim(self, self.anim_run, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y == 0)
				setanim(self, self.anim_runbackwards, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y > 0)
				setanim(self, self.anim_straferight, TRUE, FALSE, FALSE);
			else if (self.movement_x == 0 && self.movement_y < 0)
				setanim(self, self.anim_strafeleft, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y > 0)
				setanim(self, self.anim_forwardright, TRUE, FALSE, FALSE);
			else if (self.movement_x > 0 && self.movement_y < 0)
				setanim(self, self.anim_forwardleft, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y > 0)
				setanim(self, self.anim_backright, TRUE, FALSE, FALSE);
			else if (self.movement_x < 0 && self.movement_y < 0)
				setanim(self, self.anim_backleft, TRUE, FALSE, FALSE);
			else
				setanim(self, self.anim_run, TRUE, FALSE, FALSE);
		}
		else
			setanim(self, self.anim_idle, TRUE, FALSE, FALSE);
	}

	if (self.weaponentity)
	if (!self.weaponentity.animstate_override)
		setanim(self.weaponentity, self.weaponentity.anim_idle, TRUE, FALSE, FALSE);
}

void MagicInventoryPinata (entity player);
void SpawnThrownWeapon (vector org, float w)
{
	if(g_minstagib)
	if(self.ammo_cells <= 0)
		return;

	if(g_pinata)
	{
		float j;
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			if(WEPSET_CONTAINS_EW(self, j))
				if(W_IsWeaponThrowable(j))
					W_ThrowNewWeapon(self, j, FALSE, org, randomvec() * 175 + '0 0 325');
		}
		
		MagicInventoryPinata(self);
	}
	else
	{
		if(W_IsWeaponThrowable(self.weapon))
			W_ThrowNewWeapon(self, self.weapon, FALSE, org, randomvec() * 125 + '0 0 200');
	}
}

float MayWeDoBlood(float deathtype) {
	//Noblood for corpses. When adding new weapons make sure to add to noblood for playerdamage too
	//Also makesure to add the nogib stuff below in this function too
	if (
	!( DEATH_ISWEAPON(deathtype, WEP_TUBA) && autocvar_g_balance_tuba_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LASER) && autocvar_g_balance_laser_noblood) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_NEX) && autocvar_g_balance_nex_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINSTANEX) && autocvar_g_balance_minstanex_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYLINK) && autocvar_g_balance_crylink_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYPISTOL) && autocvar_g_balance_crypistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYLANCER) && autocvar_g_balance_crylancer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STARBLAST) && autocvar_g_balance_starblast_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBURST) && autocvar_g_balance_sunburst_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBOLT) && autocvar_g_balance_sunbolt_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBEAM) && autocvar_g_balance_sunbeam_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STARLASE) && autocvar_g_balance_starlase_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELECTRO) && autocvar_g_balance_electro_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTNINGGUN) && autocvar_g_balance_lightninggun_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLAMETHROWER) && autocvar_g_balance_flamethrower_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HLAC) && autocvar_g_balance_hlac_noblood) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && autocvar_g_balance_shotgun_noblood) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_PUMPSHOTGUN) && autocvar_g_balance_pumpshotgun_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPORTSHOTGUN) && autocvar_g_balance_sportshotgun_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STREETSWEEPER) && autocvar_g_balance_streetsweeper_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1897) && autocvar_g_balance_winchester1897_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1897TRENCHGUN) && autocvar_g_balance_m1897trenchgun_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ITHACASTAKEOUT) && autocvar_g_balance_ithacastakeout_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESHOTGUN) && autocvar_g_balance_eightgaugeshotgun_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TENGAUGEDOUBLE) && autocvar_g_balance_tengaugedouble_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TENGAUGESAWEDOFF) && autocvar_g_balance_tengaugesawedoff_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESAWEDOFF) && autocvar_g_balance_eightgaugesawedoff_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPAS12) && autocvar_g_balance_spas12_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RIFLE) && autocvar_g_balance_rifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_G98) && autocvar_g_balance_g98_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MOSIN) && autocvar_g_balance_mosin_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_T17MMRIFLE) && autocvar_g_balance_t17mmrifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1903) && autocvar_g_balance_m1903_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TARGETPISTOL) && autocvar_g_balance_targetpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HENRY1860RIFLE) && autocvar_g_balance_henry1860rifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1873RIFLE) && autocvar_g_balance_winchester1873rifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HENRY1860MARESLEG) && autocvar_g_balance_henry1860maresleg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COLTLIGHTNING) && autocvar_g_balance_coltlightning_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHARPSRIFLE) && autocvar_g_balance_sharpsrifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LRR) && autocvar_g_balance_lrr_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_UZI) && autocvar_g_balance_uzi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1921) && autocvar_g_balance_m1921_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1928) && autocvar_g_balance_m1928_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1929) && autocvar_g_balance_m1929_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PDW) && autocvar_g_balance_pdw_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HMG) && autocvar_g_balance_hmg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LEWISMG) && autocvar_g_balance_lewismg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HELLRIEGELSMG) && autocvar_g_balance_hellriegelsmg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MG0815) && autocvar_g_balance_mg0815_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MG) && autocvar_g_balance_mg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CARBINE) && autocvar_g_balance_carbine_noblood) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER) && autocvar_g_balance_rocketlauncher_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER) && autocvar_g_balance_grenadelauncher_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HAGAR) && autocvar_g_balance_hagar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SEEKER) && autocvar_g_balance_seeker_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINE_LAYER) && autocvar_g_balance_minelayer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HAGAR2) && autocvar_g_balance_hagar2_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MORTAR) && autocvar_g_balance_mortar_noblood) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_EXPLOSIVE_VEST) && autocvar_g_balance_explosivevest_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOTGUNAUTOMAT) && autocvar_g_balance_shotgunautomat_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER) && autocvar_g_balance_nukelayer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PISTOL) && autocvar_g_balance_pistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BIGPISTOL) && autocvar_g_balance_bigpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGPISTOL) && autocvar_g_balance_longpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LARGEPISTOL) && autocvar_g_balance_largepistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTPISTOL) && autocvar_g_balance_lightpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FIVESEVENPISTOL) && autocvar_g_balance_fivesevenpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MAUSERPISTOL) && autocvar_g_balance_mauserpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M9PISTOL) && autocvar_g_balance_m9pistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M93RPISTOL) && autocvar_g_balance_m93rpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BROWNINGHP) && autocvar_g_balance_browninghp_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTAUTO) && autocvar_g_balance_lightauto_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MACHINEPISTOL) && autocvar_g_balance_machinepistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CZSKORPION) && autocvar_g_balance_czskorpion_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SVSKORPION) && autocvar_g_balance_svskorpion_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MICROUZI) && autocvar_g_balance_microuzi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TEC9) && autocvar_g_balance_tec9_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POUNDERSMG) && autocvar_g_balance_poundersmg_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINIUZI) && autocvar_g_balance_miniuzi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_REVOLVER) && autocvar_g_balance_revolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLINTLOCKPISTOL) && autocvar_g_balance_flintlockpistol_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MUSKET) && autocvar_g_balance_musket_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TANEGASHIMA) && autocvar_g_balance_tanegashima_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAVY1851REVOLVER) && autocvar_g_balance_navy1851revolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_R1856REVOLVER) && autocvar_g_balance_r1856revolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COLT44REVOLVER) && autocvar_g_balance_colt44revolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SCHOFIELDREVOLVER) && autocvar_g_balance_schofieldrevolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MAGNUM) && autocvar_g_balance_magnum_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAGANT1895) && autocvar_g_balance_nagant1895_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WEBLEY) && autocvar_g_balance_webley_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WEBLEYLONG) && autocvar_g_balance_webleylong_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FFMAGNUM) && autocvar_g_balance_ffmagnum_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PEPPERBOXREVOLVER) && autocvar_g_balance_pepperboxrevolver_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGBOW) && autocvar_g_balance_longbow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_YUMIBOW) && autocvar_g_balance_yumibow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTCROSSBOW) && autocvar_g_balance_lightcrossbow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COMPOSITEBOW) && autocvar_g_balance_compositebow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRUDEBOW) && autocvar_g_balance_crudebow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CROSSBOWDTWR) && autocvar_g_balance_crossbowdtwr_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARHAMMERSPIKED) && autocvar_g_balance_warhammerspiked_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CLAWHAMMER) && autocvar_g_balance_clawhammer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MORGENSTERN) && autocvar_g_balance_morgenstern_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOOTINGSTAR) && autocvar_g_balance_shootingstar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDFLAIL) && autocvar_g_balance_spikedflail_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MILFLAIL) && autocvar_g_balance_milflail_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHININGSTAR) && autocvar_g_balance_shiningstar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDMACE) && autocvar_g_balance_spikedmace_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARMALLET) && autocvar_g_balance_warmallet_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDCLUB) && autocvar_g_balance_spikedclub_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDCUDGEL) && autocvar_g_balance_spikedcudgel_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_GREYIRONMALLET) && autocvar_g_balance_greyironmallet_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHORTSWORD) && autocvar_g_balance_shortsword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGSWORD) && autocvar_g_balance_longsword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ARMINGSWORD) && autocvar_g_balance_armingsword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRUSADERSWORD) && autocvar_g_balance_crusadersword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FIGHTERSWORD) && autocvar_g_balance_fightersword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SCIMITAR) && autocvar_g_balance_scimitar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FALCHION) && autocvar_g_balance_falchion_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DADAO) && autocvar_g_balance_dadao_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PUDAO) && autocvar_g_balance_dadao_noblood) &&		//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_BASTARDSWORD) && autocvar_g_balance_bastardsword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CLAYMORE) && autocvar_g_balance_bastardsword_noblood) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_FLAMBERGE) && autocvar_g_balance_flamberge_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DEFENDERSWORD) && autocvar_g_balance_defendersword_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_IRONKNIFE) && autocvar_g_balance_ironknife_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BOWIEKNIFE) && autocvar_g_balance_bowieknife_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENSABRE) && autocvar_g_balance_elvensabre_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KATANA) && autocvar_g_balance_katana_noblood) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_SHIRASAYA) && autocvar_g_balance_katana_noblood) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_ZATOICHI) && autocvar_g_balance_katana_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ODACHI) && autocvar_g_balance_odachi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAGAMAKI) && autocvar_g_balance_nagamaki_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENGLAIVE) && autocvar_g_balance_elvenglaive_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RAPIER) && autocvar_g_balance_rapier_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DAGGER) && autocvar_g_balance_dagger_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ARKANSASTOOTHPICK) && autocvar_g_balance_arkansastoothpick_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KNIFE) && autocvar_g_balance_knife_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SAI) && autocvar_g_balance_sai_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE) && autocvar_g_balance_lightsabre_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII) && autocvar_g_balance_lightsabreii_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV) && autocvar_g_balance_lightsabreiv_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI) && autocvar_g_balance_lightsabrexi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPEAR) && autocvar_g_balance_spear_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_YARI) && autocvar_g_balance_yari_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POLEAXE) && autocvar_g_balance_poleaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BARDICHE) && autocvar_g_balance_bardiche_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_INFANTRYAXE) && autocvar_g_balance_infantryaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENAXE) && autocvar_g_balance_elvenaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BROADAXE) && autocvar_g_balance_broadaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARAXE) && autocvar_g_balance_waraxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SKIRMISHERSAXE) && autocvar_g_balance_skirmishersaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BATTLEAXE) && autocvar_g_balance_battleaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TEMPLARAXE) && autocvar_g_balance_templaraxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WOODAXE) && autocvar_g_balance_woodaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PICKAXE) && autocvar_g_balance_pickaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENHAMMER) && autocvar_g_balance_elvenhammer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KRIEGSHAMMER) && autocvar_g_balance_kriegshammer_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AXE) && autocvar_g_balance_axe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BEARDEDAXE) && autocvar_g_balance_beardedaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DOUBLEBITAXE) && autocvar_g_balance_doublebitaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CHAINSAW) && autocvar_g_balance_chainsaw_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POWERSAW) && autocvar_g_balance_powersaw_noblood) &&	
	!( DEATH_ISWEAPON(deathtype, WEP_STONEAXE) && autocvar_g_balance_stoneaxe_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TETSUBO) && autocvar_g_balance_tetsubo_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BRONZECUDGEL) && autocvar_g_balance_bronzecudgel_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLANGEDMACE) && autocvar_g_balance_flangedmace_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CUDGEL) && autocvar_g_balance_cudgel_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BAT) && autocvar_g_balance_bat_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_QUARTERSTAFF) && autocvar_g_balance_quarterstaff_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_INFANTRYSTAFF) && autocvar_g_balance_infantrystaff_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KIDUCHI) && autocvar_g_balance_kiduchi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STAFFFLAME) && autocvar_g_balance_staffflame_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STAFFMAGI) && autocvar_g_balance_staffmagi_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENSTAFF) && autocvar_g_balance_elvenstaff_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CROWBAR) && autocvar_g_balance_crowbar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_IRONCROW) && autocvar_g_balance_ironcrow_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TORCH) && autocvar_g_balance_torch_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CALTROP) && autocvar_g_balance_caltrop_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLASHLIGHT) && autocvar_g_balance_flashlight_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MULTITOOL) && autocvar_g_balance_multitool_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHACKLES) && autocvar_g_balance_shackles_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HANDCUFFS) && autocvar_g_balance_handcuffs_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AK47) && autocvar_g_balance_ak47_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RPD) && autocvar_g_balance_rpd_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PKM) && autocvar_g_balance_pkm_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M249PARA) && autocvar_g_balance_m249para_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SVD) && autocvar_g_balance_svd_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BAR1918) && autocvar_g_balance_bar1918_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CHAUCHAT) && autocvar_g_balance_chauchat_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOSHO) && autocvar_g_balance_shosho_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AMR18) && autocvar_g_balance_amr18_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SKS45) && autocvar_g_balance_sks45_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M82RIFLE) && autocvar_g_balance_m82rifle_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RPG7_LAUNCHER) && autocvar_g_balance_rpg7launcher_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR) && autocvar_g_balance_devastator_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RA4_LAUNCHER) && autocvar_g_balance_ra4launcher_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AKS74U) && autocvar_g_balance_aks74u_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16MINI) && autocvar_g_balance_m16mini_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPECTRE) && autocvar_g_balance_spectre_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16VN) && autocvar_g_balance_m16vn_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16A2) && autocvar_g_balance_m16a2_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FNSCAR) && autocvar_g_balance_fnscar_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_G36C) && autocvar_g_balance_g36c_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_L85A2) && autocvar_g_balance_l85a2_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STYERAUG) && autocvar_g_balance_styeraug_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STYERTMP) && autocvar_g_balance_styertmp_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_P90) && autocvar_g_balance_p90_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FAMAS) && autocvar_g_balance_famas_noblood) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TT33PISTOL) && autocvar_g_balance_tt33pistol_noblood) &&
	
	!( (deathtype == DEATH_WAKIGUN) && autocvar_g_vehicle_racer_cannon_noblood) &&
	!( (deathtype == DEATH_BUMB_GUN) && autocvar_g_vehicle_bumblebee_cannon_noblood) &&
	!( (deathtype == DEATH_RAPTOR_CANNON) && autocvar_g_vehicle_raptor_cannon_noblood) &&
	!( (deathtype == DEATH_VHCRUSH) && autocvar_g_vehicle_crush_noblood) &&

	!( ((deathtype == DEATH_SPORTSTERGUN
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
	)) && autocvar_g_vehicle_sportster_cannon_noblood) &&
	
	!( (deathtype == DEATH_TURRET_WALKER_MEELE) && autocvar_g_turrets_unit_walker_std_meele_noblood) &&
	
	!( ((deathtype == DEATH_TURRET_WALKER_GUN
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_CORESHOT))
	)) && autocvar_g_turrets_unit_walker_std_shot_noblood) &&
	
	!( ((deathtype == DEATH_TURRET_MACHINEGUN
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_CORESHOT))
	)) && autocvar_g_turrets_unit_machinegun_std_shot_noblood) &&
	
	!( (deathtype == DEATH_TURRET_EWHEEL) && autocvar_g_turrets_unit_ewheel_std_shot_noblood) &&
	!( (deathtype == DEATH_TURRET_PHASER) && autocvar_g_turrets_unit_phaser_std_shot_noblood) &&
	!( (deathtype == DEATH_TURRET_PLASMA) && autocvar_g_turrets_unit_plasma_std_shot_noblood) &&
	!( (deathtype == DEATH_TURRET_TESLA) && autocvar_g_turrets_unit_tesla_std_shot_noblood) &&
	!( (deathtype == DEATH_TURRET_AUTOSHLAC) && autocvar_g_balance_hlac_noblood) &&
	
	!( (deathtype == DEATH_BEATDOWN) && autocvar_g_death_beatdown_noblood) &&
	!( (deathtype == DEATH_FALL) && autocvar_g_death_fall_noblood) &&
	!( (deathtype == DEATH_DROWN) && autocvar_g_death_drown_noblood) &&
	!( (deathtype == DEATH_HURTTRIGGER) && autocvar_g_death_hurttrigger_noblood) &&
	!( (deathtype == DEATH_HURTLASER) && autocvar_g_death_hurtlaser_noblood) &&
	!( (deathtype == DEATH_LAVA) && autocvar_g_death_lava_noblood) &&
	!( (deathtype == DEATH_SLIME) && autocvar_g_death_slime_noblood) &&
	!( (deathtype == DEATH_KILL) && autocvar_g_death_kill_noblood) &&
	!( (deathtype == DEATH_NOAMMO) && autocvar_g_death_noammo_noblood) &&
	!( (deathtype == DEATH_SWAMP) && autocvar_g_death_swamp_noblood) &&
	!( (deathtype == DEATH_TEAMCHANGE) && autocvar_g_death_teamchange_noblood) &&
	!( (deathtype == DEATH_AUTOTEAMCHANGE) && autocvar_g_death_autoteamchange_noblood) &&
	!( (deathtype == DEATH_CAMP) && autocvar_g_death_camp_noblood) &&
	!( (deathtype == DEATH_SHOOTING_STAR) && autocvar_g_death_shooting_star_noblood) &&
	!( (deathtype == DEATH_HOLYBOLT) && autocvar_g_death_holybolt_noblood) &&
	!( (deathtype == DEATH_ROT) && autocvar_g_death_rot_noblood) &&
	!( (deathtype == DEATH_MIRRORDAMAGE) && autocvar_g_death_mirrordamage_noblood) &&
	!( (deathtype == DEATH_TOUCHEXPLODE) && autocvar_g_death_touchexplode_noblood) &&
	!( (deathtype == DEATH_CHEAT) && autocvar_g_death_cheat_noblood) &&
	!( (deathtype == DEATH_FIRE) && autocvar_g_death_fire_noblood) &&
	!( (deathtype == DEATH_ICE) && autocvar_g_death_ice_noblood) &&
	!( (deathtype == DEATH_QUIET) && autocvar_g_death_quiet_noblood) &&
	!( (deathtype == DEATH_CRUSH) && autocvar_g_death_crush_noblood) &&
	!( (deathtype == DEATH_BATTERINGRAM) && autocvar_g_death_batteringram_noblood) &&
	!( (deathtype == DEATH_CUT) && autocvar_g_death_cut_noblood) &&
	!( (deathtype == DEATH_IMPALE) && autocvar_g_death_impale_noblood) &&
	
	!( (deathtype == DEATH_MONSTER_DEMON_MELEE ) && autocvar_g_monsters_demon_melee_noblood) &&
	!( (deathtype == DEATH_MONSTER_DEMON_JUMP ) && autocvar_g_monsters_demon_jump_noblood) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_MELEE ) && autocvar_g_monsters_shambler_melee_noblood) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_CLAW ) && autocvar_g_monsters_shambler_claw_noblood) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_LIGHTNING ) && autocvar_g_monsters_shambler_lightning_noblood) &&
	!( (deathtype == DEATH_MONSTER_DOG_BITE ) && autocvar_g_monsters_dog_bite_noblood) &&
	!( (deathtype == DEATH_MONSTER_DOG_JUMP ) && autocvar_g_monsters_dog_jump_noblood) &&
	!( (deathtype == DEATH_MONSTER_TARBABY_BLOWUP ) && autocvar_g_monsters_tarbaby_blowup_noblood) &&
	!( (deathtype == DEATH_MONSTER_FISH_BITE ) && autocvar_g_monsters_fish_bite_noblood) &&
	!( (deathtype == DEATH_MONSTER_HELLFISH_BITE  ) && autocvar_g_monsters_hellfish_bite_noblood) &&
	!( (deathtype == DEATH_MONSTER_SHALRATH_MELEE ) && autocvar_g_monsters_shalrath_melee_noblood) &&
	!( (deathtype == DEATH_MONSTER_OGRE_CHAINSAW ) && autocvar_g_monsters_orge_chainsaw_noblood) &&
	!( (deathtype == DEATH_MONSTER_MELEE ) && autocvar_g_monsters_melee_noblood) &&
	!( (deathtype == DEATH_MONSTER_ZOMBIE ) && autocvar_g_monsters_zombie_attack_noblood) &&
	!( (deathtype == DEATH_MONSTER_HELLKNIGHT_FIREBALL ) && autocvar_g_monsters_hellknight_fireball_noblood) &&
	
	!( ((deathtype == DEATH_MONSTER_SOLDIER_NAIL
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_solider_nail_noblood) &&
	
	!( ((deathtype == DEATH_MONSTER_ENFORCER_NAIL
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_enforcer_nail_noblood) &&
	
	!( ((deathtype == DEATH_MONSTER_OGRE_NAIL
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_ogre_nail_noblood) &&
	
	!( ((deathtype == DEATH_FRAGMENT
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_death_fragment_noblood) &&
	
	!( (deathtype == DEATH_GRENADE) && autocvar_g_death_grenade_noblood) &&
	!( (deathtype == DEATH_GENERIC) && autocvar_g_death_generic_noblood) &&
	!( (deathtype == DEATH_WEAPON) && autocvar_g_death_weapon_noblood) &&
	!( (deathtype == DEATH_CUSTOM) && autocvar_g_death_custom_noblood) &&

	!( DEATH_ISWEAPON(deathtype, WEP_FIREBALL) && autocvar_g_balance_fireball_noblood)
	)
	{
		//print("Yes you may do blood\n");
		return 1;
	} else {
		//print("NO you may NOT do blood - It is forbidden\n");
		return 0;
	}
}

float MayWeDoGibs(float deathtype) {
	//Noblood for corpses. When adding new weapons make sure to add to noblood for playerdamage too
	//Also makesure to add the nogib stuff below in this function too
	if (
	!( DEATH_ISWEAPON(deathtype, WEP_TUBA) && autocvar_g_balance_tuba_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LASER) && autocvar_g_balance_laser_nogibs) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_NEX) && autocvar_g_balance_nex_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINSTANEX) && autocvar_g_balance_minstanex_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYLINK) && autocvar_g_balance_crylink_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYPISTOL) && autocvar_g_balance_crypistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRYLANCER) && autocvar_g_balance_crylancer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STARBLAST) && autocvar_g_balance_starblast_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBURST) && autocvar_g_balance_sunburst_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBOLT) && autocvar_g_balance_sunbolt_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SUNBEAM) && autocvar_g_balance_sunbeam_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STARLASE) && autocvar_g_balance_starlase_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELECTRO) && autocvar_g_balance_electro_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTNINGGUN) && autocvar_g_balance_lightninggun_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLAMETHROWER) && autocvar_g_balance_flamethrower_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HLAC) && autocvar_g_balance_hlac_nogibs) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && autocvar_g_balance_shotgun_nogibs) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_PUMPSHOTGUN) && autocvar_g_balance_pumpshotgun_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPORTSHOTGUN) && autocvar_g_balance_sportshotgun_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STREETSWEEPER) && autocvar_g_balance_streetsweeper_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1897) && autocvar_g_balance_winchester1897_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1897TRENCHGUN) && autocvar_g_balance_m1897trenchgun_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ITHACASTAKEOUT) && autocvar_g_balance_ithacastakeout_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESHOTGUN) && autocvar_g_balance_eightgaugeshotgun_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TENGAUGEDOUBLE) && autocvar_g_balance_tengaugedouble_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TENGAUGESAWEDOFF) && autocvar_g_balance_tengaugesawedoff_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_EIGHTGAUGESAWEDOFF) && autocvar_g_balance_eightgaugesawedoff_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPAS12) && autocvar_g_balance_spas12_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RIFLE) && autocvar_g_balance_rifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_G98) && autocvar_g_balance_g98_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MOSIN) && autocvar_g_balance_mosin_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_T17MMRIFLE) && autocvar_g_balance_t17mmrifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1903) && autocvar_g_balance_m1903_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TARGETPISTOL) && autocvar_g_balance_targetpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HENRY1860RIFLE) && autocvar_g_balance_henry1860rifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WINCHESTER1873RIFLE) && autocvar_g_balance_winchester1873rifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HENRY1860MARESLEG) && autocvar_g_balance_henry1860maresleg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COLTLIGHTNING) && autocvar_g_balance_coltlightning_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHARPSRIFLE) && autocvar_g_balance_sharpsrifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LRR) && autocvar_g_balance_lrr_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_UZI) && autocvar_g_balance_uzi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1921) && autocvar_g_balance_m1921_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1928) && autocvar_g_balance_m1928_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M1929) && autocvar_g_balance_m1929_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PDW) && autocvar_g_balance_pdw_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HMG) && autocvar_g_balance_hmg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LEWISMG) && autocvar_g_balance_lewismg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HELLRIEGELSMG) && autocvar_g_balance_hellriegelsmg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MG0815) && autocvar_g_balance_mg0815_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MG) && autocvar_g_balance_mg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CARBINE) && autocvar_g_balance_carbine_nogibs) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_ROCKET_LAUNCHER) && autocvar_g_balance_rocketlauncher_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_GRENADE_LAUNCHER) && autocvar_g_balance_grenadelauncher_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HAGAR) && autocvar_g_balance_hagar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SEEKER) && autocvar_g_balance_seeker_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINE_LAYER) && autocvar_g_balance_minelayer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HAGAR2) && autocvar_g_balance_hagar2_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MORTAR) && autocvar_g_balance_mortar_nogibs) &&
	
	!( DEATH_ISWEAPON(deathtype, WEP_EXPLOSIVE_VEST) && autocvar_g_balance_explosivevest_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOTGUNAUTOMAT) && autocvar_g_balance_shotgunautomat_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NUKE_LAYER) && autocvar_g_balance_nukelayer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PISTOL) && autocvar_g_balance_pistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BIGPISTOL) && autocvar_g_balance_bigpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGPISTOL) && autocvar_g_balance_longpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LARGEPISTOL) && autocvar_g_balance_largepistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTPISTOL) && autocvar_g_balance_lightpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FIVESEVENPISTOL) && autocvar_g_balance_fivesevenpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MAUSERPISTOL) && autocvar_g_balance_mauserpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M9PISTOL) && autocvar_g_balance_m9pistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M93RPISTOL) && autocvar_g_balance_m93rpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BROWNINGHP) && autocvar_g_balance_browninghp_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTAUTO) && autocvar_g_balance_lightauto_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MACHINEPISTOL) && autocvar_g_balance_machinepistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CZSKORPION) && autocvar_g_balance_czskorpion_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SVSKORPION) && autocvar_g_balance_svskorpion_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MICROUZI) && autocvar_g_balance_microuzi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TEC9) && autocvar_g_balance_tec9_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POUNDERSMG) && autocvar_g_balance_poundersmg_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MINIUZI) && autocvar_g_balance_miniuzi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_REVOLVER) && autocvar_g_balance_revolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLINTLOCKPISTOL) && autocvar_g_balance_flintlockpistol_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MUSKET) && autocvar_g_balance_musket_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TANEGASHIMA) && autocvar_g_balance_tanegashima_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAVY1851REVOLVER) && autocvar_g_balance_navy1851revolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_R1856REVOLVER) && autocvar_g_balance_r1856revolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COLT44REVOLVER) && autocvar_g_balance_colt44revolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SCHOFIELDREVOLVER) && autocvar_g_balance_schofieldrevolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MAGNUM) && autocvar_g_balance_magnum_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAGANT1895) && autocvar_g_balance_nagant1895_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WEBLEY) && autocvar_g_balance_webley_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WEBLEYLONG) && autocvar_g_balance_webleylong_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FFMAGNUM) && autocvar_g_balance_ffmagnum_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PEPPERBOXREVOLVER) && autocvar_g_balance_pepperboxrevolver_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGBOW) && autocvar_g_balance_longbow_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_YUMIBOW) && autocvar_g_balance_yumibow_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTCROSSBOW) && autocvar_g_balance_lightcrossbow_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_COMPOSITEBOW) && autocvar_g_balance_compositebow_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRUDEBOW) && autocvar_g_balance_crudebow_nogibs) &&		
	!( DEATH_ISWEAPON(deathtype, WEP_CROSSBOWDTWR) && autocvar_g_balance_crossbowdtwr_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARHAMMERSPIKED) && autocvar_g_balance_warhammerspiked_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CLAWHAMMER) && autocvar_g_balance_clawhammer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MORGENSTERN) && autocvar_g_balance_morgenstern_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOOTINGSTAR) && autocvar_g_balance_shootingstar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDFLAIL) && autocvar_g_balance_spikedflail_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MILFLAIL) && autocvar_g_balance_milflail_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHININGSTAR) && autocvar_g_balance_shiningstar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDMACE) && autocvar_g_balance_spikedmace_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARMALLET) && autocvar_g_balance_warmallet_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDCLUB) && autocvar_g_balance_spikedclub_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPIKEDCUDGEL) && autocvar_g_balance_spikedcudgel_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_GREYIRONMALLET) && autocvar_g_balance_greyironmallet_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHORTSWORD) && autocvar_g_balance_shortsword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LONGSWORD) && autocvar_g_balance_longsword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ARMINGSWORD) && autocvar_g_balance_armingsword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CRUSADERSWORD) && autocvar_g_balance_crusadersword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FIGHTERSWORD) && autocvar_g_balance_fightersword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SCIMITAR) && autocvar_g_balance_scimitar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FALCHION) && autocvar_g_balance_falchion_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DADAO) && autocvar_g_balance_dadao_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PUDAO) && autocvar_g_balance_dadao_nogibs) &&		//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_BASTARDSWORD) && autocvar_g_balance_bastardsword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CLAYMORE) && autocvar_g_balance_bastardsword_nogibs) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_FLAMBERGE) && autocvar_g_balance_flamberge_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DEFENDERSWORD) && autocvar_g_balance_defendersword_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_IRONKNIFE) && autocvar_g_balance_ironknife_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BOWIEKNIFE) && autocvar_g_balance_bowieknife_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENSABRE) && autocvar_g_balance_elvensabre_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KATANA) && autocvar_g_balance_katana_nogibs) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_SHIRASAYA) && autocvar_g_balance_katana_nogibs) &&	//Uses same as above
	!( DEATH_ISWEAPON(deathtype, WEP_ZATOICHI) && autocvar_g_balance_katana_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ODACHI) && autocvar_g_balance_odachi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_NAGAMAKI) && autocvar_g_balance_nagamaki_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENGLAIVE) && autocvar_g_balance_elvenglaive_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RAPIER) && autocvar_g_balance_rapier_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DAGGER) && autocvar_g_balance_dagger_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ARKANSASTOOTHPICK) && autocvar_g_balance_arkansastoothpick_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KNIFE) && autocvar_g_balance_knife_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SAI) && autocvar_g_balance_sai_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE) && autocvar_g_balance_lightsabre_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII) && autocvar_g_balance_lightsabreii_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV) && autocvar_g_balance_lightsabreiv_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI) && autocvar_g_balance_lightsabrexi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPEAR) && autocvar_g_balance_spear_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_YARI) && autocvar_g_balance_yari_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POLEAXE) && autocvar_g_balance_poleaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BARDICHE) && autocvar_g_balance_bardiche_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_INFANTRYAXE) && autocvar_g_balance_infantryaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENAXE) && autocvar_g_balance_elvenaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BROADAXE) && autocvar_g_balance_broadaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WARAXE) && autocvar_g_balance_waraxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SKIRMISHERSAXE) && autocvar_g_balance_skirmishersaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BATTLEAXE) && autocvar_g_balance_battleaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TEMPLARAXE) && autocvar_g_balance_templaraxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_WOODAXE) && autocvar_g_balance_woodaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PICKAXE) && autocvar_g_balance_pickaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENHAMMER) && autocvar_g_balance_elvenhammer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KRIEGSHAMMER) && autocvar_g_balance_kriegshammer_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AXE) && autocvar_g_balance_axe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BEARDEDAXE) && autocvar_g_balance_beardedaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DOUBLEBITAXE) && autocvar_g_balance_doublebitaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CHAINSAW) && autocvar_g_balance_chainsaw_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_POWERSAW) && autocvar_g_balance_powersaw_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STONEAXE) && autocvar_g_balance_stoneaxe_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TETSUBO) && autocvar_g_balance_tetsubo_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BRONZECUDGEL) && autocvar_g_balance_bronzecudgel_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLANGEDMACE) && autocvar_g_balance_flangedmace_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CUDGEL) && autocvar_g_balance_cudgel_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BAT) && autocvar_g_balance_bat_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_QUARTERSTAFF) && autocvar_g_balance_quarterstaff_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_INFANTRYSTAFF) && autocvar_g_balance_infantrystaff_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_KIDUCHI) && autocvar_g_balance_kiduchi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STAFFFLAME) && autocvar_g_balance_staffflame_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STAFFMAGI) && autocvar_g_balance_staffmagi_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_ELVENSTAFF) && autocvar_g_balance_elvenstaff_nogibs) &&	
	!( DEATH_ISWEAPON(deathtype, WEP_CROWBAR) && autocvar_g_balance_crowbar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_IRONCROW) && autocvar_g_balance_ironcrow_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TORCH) && autocvar_g_balance_torch_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CALTROP) && autocvar_g_balance_caltrop_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FLASHLIGHT) && autocvar_g_balance_flashlight_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_MULTITOOL) && autocvar_g_balance_multitool_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHACKLES) && autocvar_g_balance_shackles_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_HANDCUFFS) && autocvar_g_balance_handcuffs_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AK47) && autocvar_g_balance_ak47_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RPD) && autocvar_g_balance_rpd_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_PKM) && autocvar_g_balance_pkm_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M249PARA) && autocvar_g_balance_m249para_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SVD) && autocvar_g_balance_svd_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_BAR1918) && autocvar_g_balance_bar1918_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_CHAUCHAT) && autocvar_g_balance_chauchat_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SHOSHO) && autocvar_g_balance_shosho_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AMR18) && autocvar_g_balance_amr18_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SKS45) && autocvar_g_balance_sks45_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M82RIFLE) && autocvar_g_balance_m82rifle_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RPG7_LAUNCHER) && autocvar_g_balance_rpg7launcher_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_DEVASTATOR) && autocvar_g_balance_devastator_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_RA4_LAUNCHER) && autocvar_g_balance_ra4launcher_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_AKS74U) && autocvar_g_balance_aks74u_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16MINI) && autocvar_g_balance_m16mini_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_SPECTRE) && autocvar_g_balance_spectre_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16VN) && autocvar_g_balance_m16vn_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_M16A2) && autocvar_g_balance_m16a2_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FNSCAR) && autocvar_g_balance_fnscar_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_G36C) && autocvar_g_balance_g36c_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_L85A2) && autocvar_g_balance_l85a2_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STYERAUG) && autocvar_g_balance_styeraug_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_STYERTMP) && autocvar_g_balance_styertmp_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_P90) && autocvar_g_balance_p90_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_FAMAS) && autocvar_g_balance_famas_nogibs) &&
	!( DEATH_ISWEAPON(deathtype, WEP_TT33PISTOL) && autocvar_g_balance_tt33pistol_nogibs) &&
	
	!( (deathtype == DEATH_WAKIGUN) && autocvar_g_vehicle_racer_cannon_nogibs) &&
	!( (deathtype == DEATH_BUMB_GUN) && autocvar_g_vehicle_bumblebee_cannon_nogibs) &&
	!( (deathtype == DEATH_RAPTOR_CANNON) && autocvar_g_vehicle_raptor_cannon_nogibs) &&
	!( (deathtype == DEATH_VHCRUSH) && autocvar_g_vehicle_crush_nogibs) &&

	!( ((deathtype == DEATH_SPORTSTERGUN
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
	)) && autocvar_g_vehicle_sportster_cannon_nogibs) &&
	
	!( (deathtype == DEATH_TURRET_WALKER_MEELE) && autocvar_g_turrets_unit_walker_std_meele_nogibs) &&
	
	!( ((deathtype == DEATH_TURRET_WALKER_GUN
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_TURRET_WALKER_GUN + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_turrets_unit_walker_std_shot_nogibs) &&
	
	!( ((deathtype == DEATH_TURRET_MACHINEGUN
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_TURRET_MACHINEGUN + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_turrets_unit_machinegun_std_shot_nogibs) &&
	
	!( (deathtype == DEATH_TURRET_EWHEEL) && autocvar_g_turrets_unit_ewheel_std_shot_nogibs) &&
	!( (deathtype == DEATH_TURRET_PHASER) && autocvar_g_turrets_unit_phaser_std_shot_nogibs) &&
	!( (deathtype == DEATH_TURRET_PLASMA) && autocvar_g_turrets_unit_plasma_std_shot_nogibs) &&
	!( (deathtype == DEATH_TURRET_TESLA) && autocvar_g_turrets_unit_tesla_std_shot_nogibs) &&
	!( (deathtype == DEATH_TURRET_AUTOSHLAC) && autocvar_g_balance_hlac_nogibs) &&	
	
	!( (deathtype == DEATH_BEATDOWN) && autocvar_g_death_beatdown_nogibs) &&
	!( (deathtype == DEATH_FALL) && autocvar_g_death_fall_nogibs) &&
	!( (deathtype == DEATH_DROWN) && autocvar_g_death_drown_nogibs) &&
	!( (deathtype == DEATH_HURTTRIGGER) && autocvar_g_death_hurttrigger_nogibs) &&
	!( (deathtype == DEATH_HURTLASER) && autocvar_g_death_hurtlaser_nogibs) &&
	!( (deathtype == DEATH_LAVA) && autocvar_g_death_lava_nogibs) &&
	!( (deathtype == DEATH_SLIME) && autocvar_g_death_slime_nogibs) &&
	!( (deathtype == DEATH_KILL) && autocvar_g_death_kill_nogibs) &&
	!( (deathtype == DEATH_NOAMMO) && autocvar_g_death_noammo_nogibs) &&
	!( (deathtype == DEATH_SWAMP) && autocvar_g_death_swamp_nogibs) &&
	!( (deathtype == DEATH_TEAMCHANGE) && autocvar_g_death_teamchange_nogibs) &&
	!( (deathtype == DEATH_AUTOTEAMCHANGE) && autocvar_g_death_autoteamchange_nogibs) &&
	!( (deathtype == DEATH_CAMP) && autocvar_g_death_camp_nogibs) &&
	!( (deathtype == DEATH_SHOOTING_STAR) && autocvar_g_death_shooting_star_nogibs) &&
	!( (deathtype == DEATH_HOLYBOLT) && autocvar_g_death_holybolt_nogibs) &&
	!( (deathtype == DEATH_ROT) && autocvar_g_death_rot_nogibs) &&
	!( (deathtype == DEATH_MIRRORDAMAGE) && autocvar_g_death_mirrordamage_nogibs) &&
	!( (deathtype == DEATH_TOUCHEXPLODE) && autocvar_g_death_touchexplode_nogibs) &&
	!( (deathtype == DEATH_CHEAT) && autocvar_g_death_cheat_nogibs) &&
	!( (deathtype == DEATH_FIRE) && autocvar_g_death_fire_nogibs) &&
	!( (deathtype == DEATH_ICE) && autocvar_g_death_ice_nogibs) &&
	!( (deathtype == DEATH_QUIET) && autocvar_g_death_quiet_nogibs) &&
	!( (deathtype == DEATH_CRUSH) && autocvar_g_death_crush_nogibs) &&
	!( (deathtype == DEATH_BATTERINGRAM) && autocvar_g_death_batteringram_nogibs) &&
	!( (deathtype == DEATH_CUT) && autocvar_g_death_cut_nogibs) &&
	!( (deathtype == DEATH_IMPALE) && autocvar_g_death_impale_nogibs) &&
	
	!( (deathtype == DEATH_MONSTER_DEMON_MELEE ) && autocvar_g_monsters_demon_melee_nogibs) &&
	!( (deathtype == DEATH_MONSTER_DEMON_JUMP ) && autocvar_g_monsters_demon_jump_nogibs) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_MELEE ) && autocvar_g_monsters_shambler_melee_nogibs) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_CLAW ) && autocvar_g_monsters_shambler_claw_nogibs) &&
	!( (deathtype == DEATH_MONSTER_SHAMBLER_LIGHTNING ) && autocvar_g_monsters_shambler_lightning_nogibs) &&
	!( (deathtype == DEATH_MONSTER_DOG_BITE ) && autocvar_g_monsters_dog_bite_nogibs) &&
	!( (deathtype == DEATH_MONSTER_DOG_JUMP ) && autocvar_g_monsters_dog_jump_nogibs) &&
	!( (deathtype == DEATH_MONSTER_TARBABY_BLOWUP ) && autocvar_g_monsters_tarbaby_blowup_nogibs) &&
	!( (deathtype == DEATH_MONSTER_FISH_BITE ) && autocvar_g_monsters_fish_bite_nogibs) &&
	!( (deathtype == DEATH_MONSTER_HELLFISH_BITE  ) && autocvar_g_monsters_hellfish_bite_nogibs) &&
	!( (deathtype == DEATH_MONSTER_SHALRATH_MELEE ) && autocvar_g_monsters_shalrath_melee_nogibs) &&
	!( (deathtype == DEATH_MONSTER_OGRE_CHAINSAW ) && autocvar_g_monsters_orge_chainsaw_nogibs) &&
	!( (deathtype == DEATH_MONSTER_MELEE ) && autocvar_g_monsters_melee_nogibs) &&
	!( (deathtype == DEATH_MONSTER_ZOMBIE ) && autocvar_g_monsters_zombie_attack_nogibs) &&
	!( (deathtype == DEATH_MONSTER_HELLKNIGHT_FIREBALL ) && autocvar_g_monsters_hellknight_fireball_nogibs) &&
	
	!( ((deathtype == DEATH_MONSTER_SOLDIER_NAIL
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_SOLDIER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_solider_nail_nogibs) &&
	
	!( ((deathtype == DEATH_MONSTER_ENFORCER_NAIL
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_ENFORCER_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_enforcer_nail_nogibs) &&
	
	!( ((deathtype == DEATH_MONSTER_OGRE_NAIL
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_MONSTER_OGRE_NAIL + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_monsters_ogre_nail_nogibs) &&
	
	!( ((deathtype == DEATH_FRAGMENT
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_HEADSHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT))
	|| (deathtype == (DEATH_FRAGMENT + HITTYPE_CORESHOT + HITTYPE_HEADSHOT))
	)) && autocvar_g_death_fragment_nogibs) &&
	
	!( (deathtype == DEATH_GRENADE) && autocvar_g_death_grenade_nogibs) &&
	!( (deathtype == DEATH_GENERIC) && autocvar_g_death_generic_nogibs) &&
	!( (deathtype == DEATH_WEAPON) && autocvar_g_death_weapon_nogibs) &&
	!( (deathtype == DEATH_CUSTOM) && autocvar_g_death_custom_nogibs) &&

	!( DEATH_ISWEAPON(deathtype, WEP_FIREBALL) && autocvar_g_balance_fireball_nogibs)
	)
	{
		//print("Yes you may do gibs\n");
		return 1;
	} else {
		//print("NO you may NOT do blood - It is forbidden\n");
		return 0;
	}
}

void PlayerGunRise(entity player, float degree_x, float degree_y) {
		if (self.shootfromside == 1) {
			//Abnormal (shooting from side)
			player.v_angle_x += degree_y; //Not the same
			player.v_angle_y += degree_x;
		} else {
		//Normal
		player.v_angle_x -= degree_x; //Because
		player.v_angle_y += degree_y;
		}

		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}
}

void PlayerCorpseDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float take, save;
	vector v;
	
	if (MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
		Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);

	// damage resistance (ignore most of the damage from a bullet or similar)
	damage = max(damage - 5, 1);

	v = healtharmor_applydamage(self.armorvalue, autocvar_g_balance_armor_blockpercent, damage);
	take = v_x;
	save = v_y;

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CH_SHOTS, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CH_SHOTS, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CH_SHOTS, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM);
	}

	if ((take > 50) && MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if ((take > 100) && MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

	if (!(self.flags & FL_GODMODE))
	{
		self.armorvalue = self.armorvalue - save;
		self.health = self.health - take;
		// pause regeneration for 5 seconds
		self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_health_regen);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	//print(sprintf("Gib Health: %v\n", self.health));
	//print(sprintf("Deathtype: %f\n", deathtype));
	// if ( DEATH_ISWEAPON(deathtype, WEP_HMG)) {
	// 	print(sprintf("HMG: %f\n", deathtype));
	// }
	//This code allows the server to set which weapons can gib and which never gib.
	//I grouped the weapons mostly by ammo type, leaving one group for my own weapons.
	//The last weapon is the fireball so that one can easily delete references to my weapons if desired.
	//Turning off gibbing on the shotgun doesn't work, it seems the last pellet or so are not tracked properly.
	//This is perhaps a bug in the ballistic bullet code, but perhaps not as uzi and rifle work fine, however they
	//are much slower in spawing ballisticbullets than the shotgun (which spawns many almost all at once).
	//Crylink can also eventually gib, but it takes many many shots, with this off it gibs quickly, I'm guessing
	//that there is a race condition between DEATH_ISWEAPON and the dmg code, I'm not sure.
	//The RocketLauncher and GrenadeLauncher seem to gib regardless.
	//I suggest turning off gibbing on the uzi and rifle, perhaps on the crylink and other energy weapons
	//This way gibbing is special for powerful weapons that provide the needed shearing force (Explosives, etc)
	if (
	(self.health <= -autocvar_sv_gibhealth && self.alpha >= 0) &&
	MayWeDoGibs(deathtype) &&
	DamageTargIsNotWithinGrace(self)
	)
	{
		// don't use any animations as a gib
		self.frame = 0;
		// view just above the floor
		self.view_ofs = '0 0 4';
		
		if (deathtype == DEATH_HURTLASER)
			Violence_GibSplash(self, 4, 1, attacker);
		else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABRE))
			Violence_GibSplash(self, 4, 1, attacker);
		else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREII))
			Violence_GibSplash(self, 4, 1, attacker);
		else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREIV))
			Violence_GibSplash(self, 4, 1, attacker);
		else if (DEATH_ISWEAPON(deathtype, WEP_LIGHTSABREXI))
			Violence_GibSplash(self, 4, 1, attacker);
		else
			Violence_GibSplash(self, 1, 1, attacker);
		
		self.alpha = -1;
		self.solid = SOLID_NOT; // restore later
		self.takedamage = DAMAGE_NO; // restore later
		self.damagedbycontents = FALSE;
	} else if (self.health <= -autocvar_sv_gibhealth && self.alpha >= 0) {
		//print("No Gib tripped\n");
		//If we failed the first test due solely to the weapon being used on the corpse 
		//being set to nogib, but for all other reasons gibbing should occur
		//Let us give health back to the gib to make sure that it does not gib due to
		//the nogib weapon pushing it against a wall.
		self.health = -1;
		
		//We will allow the server admin to set how much health to add to such a gib, to make it resilient
		//so that it will not be easily destroyed. By default, nothing.
		self.health = self.health + autocvar_sv_gibhealth_weapon_nogib_add;
	}
}

void ClientKill_Now_TeamChange();
void freezetag_CheckWinner();
void ZeroOutMagicInventory (entity player);
void RemoveStartSpells (entity player);

void PlayerDamage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	float take, save, waves, sdelay, dh, da, j;
	vector v;
	float valid_damage_for_weaponstats;
	float excess;

	if((g_arena && numspawned < 2) || (g_ca && allowed_to_spawn) && !inWarmupStage)
		return;

	dh = max(self.health, 0);
	da = max(self.armorvalue, 0);

	if(!DEATH_ISSPECIAL(deathtype))
	{
		damage *= sqrt(bound(1.0, self.cvar_cl_handicap, 100.0));
		if(self != attacker)
			damage /= sqrt(bound(1.0, attacker.cvar_cl_handicap, 100.0));
	}

	if((DEATH_ISWEAPON(deathtype, WEP_TUBA)) && MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
	{
		// tuba causes blood to come out of the ears
		vector ear1, ear2;
		vector d;
		float f;
		ear1 = self.origin;
		ear1_z += 0.125 * self.view_ofs_z + 0.875 * self.maxs_z; // 7/8
		ear2 = ear1;
		makevectors(self.angles);
		ear1 += v_right * -10;
		ear2 += v_right * +10;
		d = inflictor.origin - self.origin;
		f = (d * v_right) / vlen(d); // this is cos of angle of d and v_right!
		force = v_right * vlen(force);
		Violence_GibSplash_At(ear1, force * -1, 2, bound(0, damage, 25) / 2 * (0.5 - 0.5 * f), self, attacker);
		Violence_GibSplash_At(ear2, force,      2, bound(0, damage, 25) / 2 * (0.5 + 0.5 * f), self, attacker);
		if(f > 0)
		{
			hitloc = ear1;
			force = force * -1;
		}
		else
		{
			hitloc = ear2;
			// force is already good
		}
	}
	else if (MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self)) 
	{
		float svgorelvl, clgorelvl;
		svgorelvl = autocvar_g_balance_svgorelvl;
		clgorelvl = autocvar_g_balance_clgorelvl;
		if (DEATH_ISWEAPON(deathtype, WEP_RAPIER)
		|| DEATH_ISWEAPON(deathtype, WEP_DAGGER)) {
			if (self.armorvalue < 25)
			{
				local vector hl;
				local vector hlc;
				hlc_x = self.origin_x;
				hlc_y = self.origin_y;
				hlc_z = hitloc_z;
				
				hl = hlc + ('1 1 1' * (random() - 0.5));
				//print(vtos(hl), "hl\n");
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);	
			}
		} else if (DEATH_ISWEAPON(deathtype, WEP_SHORTSWORD) || DEATH_ISWEAPON(deathtype, WEP_LONGSWORD) || DEATH_ISWEAPON(deathtype, WEP_CRUSADERSWORD) || DEATH_ISWEAPON(deathtype, WEP_ARMINGSWORD) || DEATH_ISWEAPON(deathtype, WEP_SCIMITAR) || DEATH_ISWEAPON(deathtype, WEP_DADAO) || DEATH_ISWEAPON(deathtype, WEP_PUDAO) || DEATH_ISWEAPON(deathtype, WEP_FALCHION) || DEATH_ISWEAPON(deathtype, WEP_DEFENDERSWORD) || DEATH_ISWEAPON(deathtype, WEP_BASTARDSWORD) || DEATH_ISWEAPON(deathtype, WEP_CLAYMORE) || DEATH_ISWEAPON(deathtype, WEP_FLAMBERGE)
		|| DEATH_ISWEAPON(deathtype, WEP_KATANA) || DEATH_ISWEAPON(deathtype, WEP_SHIRASAYA) || DEATH_ISWEAPON(deathtype, WEP_ZATOICHI) || DEATH_ISWEAPON(deathtype, WEP_ODACHI) || DEATH_ISWEAPON(deathtype, WEP_FIGHTERSWORD)
		|| DEATH_ISWEAPON(deathtype, WEP_ELVENSABRE) || DEATH_ISWEAPON(deathtype, WEP_ELVENGLAIVE) || DEATH_ISWEAPON(deathtype, WEP_NAGAMAKI)) {
			if (self.armorvalue < 50)
			{
				local vector hl;
				local vector hlc;
				hlc_x = self.origin_x;
				hlc_y = self.origin_y;
				hlc_z = hitloc_z;
				//print(vtos(self.origin), "s origin\n");
				//print(vtos(attacker.origin), "at origin\n");
				//print(vtos(hitloc), "hloc\n");
				//print(vtos(hlc), "hlc\n");
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				//print(vtos(hl), "hl\n");
				if (self.armorvalue < 1) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 2) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				if (self.armorvalue < 5) {
				if (svgorelvl > 1) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 1) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}

				if (self.armorvalue < 15) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 25) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 35) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 45) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (svgorelvl > 1) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 200) / 2, self, attacker);
				if (clgorelvl > 1) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_SHORTSWORD, self.species, attacker);
			}
		} else if (DEATH_ISWEAPON(deathtype, WEP_BROADAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_WARAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_SKIRMISHERSAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_BATTLEAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_TEMPLARAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_WOODAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_BEARDEDAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_DOUBLEBITAXE)
			|| DEATH_ISWEAPON(deathtype, WEP_ELVENAXE)) {
			if (self.armorvalue < 50)
			{
				//Infantry Axe etc omitted: too small, not heavy enough blade, wouldn't hit with enough force for mega cleavage blood visuals
				//Got to be heavy, and not too distant, really having the force reign down directly (thus pole axe omitted)
				//Regular WEP_AXE omitted as it may be too blunt than the others
				local vector hl;
				local vector hlc;
				hlc_x = self.origin_x;
				hlc_y = self.origin_y;
				hlc_z = hitloc_z;
				//print(vtos(self.origin), "s origin\n");
				//print(vtos(attacker.origin), "at origin\n");
				//print(vtos(hitloc), "hloc\n");
				//print(vtos(hlc), "hlc\n");
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				//print(vtos(hl), "hl\n");
				if (self.armorvalue < 1) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 2) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				if (self.armorvalue < 5) {
				if (svgorelvl > 1) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 1) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}

				if (self.armorvalue < 15) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 25) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 35) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (self.armorvalue < 45) {
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				}
			
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (svgorelvl > 2) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 2) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
				
				hl = hlc + ('1 1 1' * (random() - 0.5));
				if (svgorelvl > 1) Violence_GibSplash_At(hl, force, 2, bound(25, damage, 300), self, attacker);
				if (clgorelvl > 1) Damage_DamageInfo(hl, damage, damage, 0, force, WEP_BROADAXE, self.species, attacker);
			}
		} 
		else
		{
			Violence_GibSplash_At(hitloc, force, 2, bound(0, damage, 200) / 16, self, attacker);
		}
	}

	if (!g_minstagib)
	{
		v = healtharmor_applydamage(self.armorvalue, autocvar_g_balance_armor_blockpercent, damage);
		take = v_x;
		save = v_y;
	}
	else
	{
		save = 0;
		take = damage;
	}

	if(attacker == self)
	{
		// don't reset pushltime for self damage as it may be an attempt to
		// escape a lava pit or similar
		//self.pushltime = 0;
		self.istypefrag = 0;
	}
	else if(attacker.classname == "player")
	{
		self.pusher = attacker;
		self.pushltime = time + autocvar_g_maxpushtime;
		self.istypefrag = self.BUTTON_CHAT;
	}
	else if(time < self.pushltime)
	{
		attacker = self.pusher;
		self.pushltime = max(self.pushltime, time + 0.6);
	}
	else
	{
		self.pushltime = 0;
		self.istypefrag = 0;
	}

	frag_inflictor = inflictor;
	frag_attacker = attacker;
	frag_target = self;
	damage_take = take;
	damage_save = save;
	damage_force = force;
	MUTATOR_CALLHOOK(PlayerDamage_SplitHealthArmor);
	take = bound(0, damage_take, self.health);
	save = bound(0, damage_save, self.armorvalue);
	excess = max(0, damage - take - save);

	if(sound_allowed(MSG_BROADCAST, attacker))
	{
		if (save > 10)
			sound (self, CH_SHOTS, "misc/armorimpact.wav", VOL_BASE, ATTN_NORM);
		else if (take > 30)
			sound (self, CH_SHOTS, "misc/bodyimpact2.wav", VOL_BASE, ATTN_NORM);
		else if (take > 10)
			sound (self, CH_SHOTS, "misc/bodyimpact1.wav", VOL_BASE, ATTN_NORM); // FIXME possibly remove them?
	}

	if ((take > 50) && MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
		Violence_GibSplash_At(hitloc, force * -0.1, 3, 1, self, attacker);
	if ((take > 100) && MayWeDoBlood(deathtype) && DamageTargIsNotWithinGrace(self))
		Violence_GibSplash_At(hitloc, force * -0.2, 3, 1, self, attacker);

	if (time >= self.spawnshieldtime)
	{
		if (!(self.flags & FL_GODMODE))
		{
			self.armorvalue = self.armorvalue - save;
			self.health = self.health - take;
			// pause regeneration for 5 seconds
			if(take)
                self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_health_regen);

			if (time > self.pain_finished)		//Don't switch pain sequences like crazy
			{
				self.pain_finished = time + 0.5;	//Supajoe

				if(sv_gentle < 1) {
					if(self.classname != "body") // pain anim is BORKED on our ZYMs, FIXME remove this once we have good models
					{
						if (!self.animstate_override)
						{
							if (random() > 0.5)
								setanim(self, self.anim_pain1, FALSE, TRUE, TRUE);
							else
								setanim(self, self.anim_pain2, FALSE, TRUE, TRUE);
						}
					}

					if(sound_allowed(MSG_BROADCAST, attacker))
					if(!DEATH_ISWEAPON(deathtype, WEP_LASER) || attacker != self || self.health < 2 * autocvar_g_balance_laser_primary_damage * autocvar_g_balance_selfdamagepercent + 1)
					if(!self.stoned)
					if(self.health > 1)
					// exclude pain sounds for laserjumps as long as you aren't REALLY low on health and would die of the next two
					{
						if(deathtype == DEATH_FALL)
							PlayerSound(playersound_fall, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 75) // TODO make a "gentle" version?
							PlayerSound(playersound_pain100, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 50)
							PlayerSound(playersound_pain75, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else if(self.health > 25)
							PlayerSound(playersound_pain50, CH_PAIN, VOICETYPE_PLAYERSOUND);
						else
							PlayerSound(playersound_pain25, CH_PAIN, VOICETYPE_PLAYERSOUND);
					}
				}

				// throw off bot aim temporarily
				float shake;
				shake = damage * 5 / (bound(0,skill,100) + 1);
				self.v_angle_x = self.v_angle_x + (random() * 2 - 1) * shake;
				self.v_angle_y = self.v_angle_y + (random() * 2 - 1) * shake;
			}
		}
		else
			self.max_armorvalue += (save + take);
	}
	self.dmg_save = self.dmg_save + save;//max(save - 10, 0);
	self.dmg_take = self.dmg_take + take;//max(take - 10, 0);
	self.dmg_inflictor = inflictor;

	if(g_ca && self != attacker && attacker.classname == "player")
		PlayerScore_Add(attacker, SP_SCORE, (damage - excess) * autocvar_g_ca_damage2score_multiplier);

	float abot, vbot, awep;
	abot = (clienttype(attacker) == CLIENTTYPE_BOT);
	vbot = (clienttype(self) == CLIENTTYPE_BOT);

	valid_damage_for_weaponstats = 0;
	awep = 0;

	if(vbot || clienttype(self) == CLIENTTYPE_REAL)
	if(abot || clienttype(attacker) == CLIENTTYPE_REAL)
	if(attacker && self != attacker)
	if(IsDifferentTeam(self, attacker))
	{
		if(DEATH_ISSPECIAL(deathtype))
			awep = attacker.weapon;
		else
			awep = DEATH_WEAPONOF(deathtype);
		valid_damage_for_weaponstats = 1;
	}

	if(valid_damage_for_weaponstats)
	{
		dh = dh - max(self.health, 0);
		da = da - max(self.armorvalue, 0);
		WeaponStats_LogDamage(awep, abot, self.weapon, vbot, dh + da);
	}

	if (self.health < 1)
	{
		float defer_ClientKill_Now_TeamChange;
		defer_ClientKill_Now_TeamChange = FALSE;
		
		if(self.alivetime)
		{
			PlayerStats_Event(self, PLAYERSTATS_ALIVETIME, time - self.alivetime);
			self.alivetime = 0;
		}
		
		self.numhasdied = self.numhasdied + 1;
		
		//Wind out timesink spell if enabled
		WindDownTimesinksOfPlayer(self);
		
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
				if (dropent.rescaleondrop) {
					dropent.scale = dropent.droppedscale;
				}
			}
			dropent = find(dropent, classname, "drop_at_death");
		}
		//End removing crossbow bolts etc at death//
		////////////////////////////////////////////
		
		self.fire_oilfire_entreignite = 0; //Just to make sure
		self.fire_oilfire_entreignite_owner = world; //Just to make sure
		self.fire_oilfire_entwasinoil = 0; //Just to make sure
		
		placeraiseundeadmarker(self, 1); //Set a marker down so raiseundead spell can find death spot

		if(valid_damage_for_weaponstats)
			WeaponStats_LogKill(awep, abot, self.weapon, vbot);

		if(sv_gentle < 1) // TODO make a "gentle" version?
		if(sound_allowed(MSG_BROADCAST, attacker))
		if(!self.stoned)
		{
			if(deathtype == DEATH_DROWN)
				PlayerSound(playersound_drown, CH_PAIN, VOICETYPE_PLAYERSOUND);
			else
				PlayerSound(playersound_death, CH_PAIN, VOICETYPE_PLAYERSOUND);
		}

		// get rid of kill indicator
		if(self.killindicator)
		{
			remove(self.killindicator);
			self.killindicator = world;
			if(self.killindicator_teamchange)
				defer_ClientKill_Now_TeamChange = TRUE;

			if(self.classname == "body")
			if(deathtype == DEATH_KILL)
			{
				// for the lemmings fans, a small harmless explosion
				pointparticles(particleeffectnum("rocket_explode"), self.origin, '0 0 0', 1);
			}
		}

		if(!g_freezetag)
		{
			if (self != attacker && attacker.classname == "player")
			{
				if(teamplay && self.team == attacker.team
				&& vlen(self.origin-attacker.origin) > 128)
				{
					//Nothing if teammate and far away
					//Something if you're right next to them when you murder
				} else {
					//Half of ammo goes to attackers multitool
					local float an, ar, ac, sap;
					
					if(teamplay && self.team == attacker.team)
						sap = 1;   //Teammate must have pickuped some ammo
					else
						sap = 0.5; //Attacker gets half starting ammo too
				
					if (self.ammo_nails > start_ammo_nails)
					{
						an = floor((self.ammo_nails - (start_ammo_nails*sap)) * 0.5);
						self.ammo_nails = floor(an + (start_ammo_nails*sap));
						attacker.multitool_ammocurrent = attacker.multitool_ammocurrent + an;
					}
				
					if (self.ammo_rockets > start_ammo_rockets)
					{
						ar = floor((self.ammo_rockets - (start_ammo_rockets*sap)) * 0.5);
						self.ammo_rockets = floor(ar + (start_ammo_rockets*sap));
						attacker.multitool_ammocurrentr = attacker.multitool_ammocurrentr + ar;
					}
				
					if (self.ammo_cells > start_ammo_cells)
					{
						ac = floor((self.ammo_cells - (start_ammo_cells*sap)) * 0.5);
						self.ammo_cells = floor(ac + (start_ammo_cells*sap));
						attacker.multitool_ammocurrentc = attacker.multitool_ammocurrentc + ac;
					}
					
					//Team or world gets half of what's left, a tax!
					if (teamplay && self.team != attacker.team)
					{
						  if (attacker.team == COLOR_TEAM1)
						  {
						  	self.ammo_nails = floor(self.ammo_nails * 0.5);
						  	resource_nails_team1 = resource_nails_team1 + self.ammo_nails;
							self.ammo_rockets = floor(self.ammo_rockets * 0.5);
						  	resource_rockets_team1 = resource_rockets_team1 + self.ammo_rockets;
							self.ammo_cells = floor(self.ammo_cells * 0.5);
						  	resource_cells_team1 = resource_cells_team1 + self.ammo_cells;
							self.ammo_shells = floor(self.ammo_shells * 0.5);
						  	resource_shells_team1 = resource_shells_team1 + self.ammo_shells;
							self.ammo_fuel = floor(self.ammo_fuel * 0.5);
						  	resource_fuel_team1 = resource_fuel_team1 + self.ammo_fuel;
						  }
						  else if (attacker.team == COLOR_TEAM2)
						  {
						  	self.ammo_nails = floor(self.ammo_nails * 0.5);
						  	resource_nails_team2 = resource_nails_team2 + self.ammo_nails;
							self.ammo_rockets = floor(self.ammo_rockets * 0.5);
						  	resource_rockets_team2 = resource_rockets_team2 + self.ammo_rockets;
							self.ammo_cells = floor(self.ammo_cells * 0.5);
						  	resource_cells_team2 = resource_cells_team2 + self.ammo_cells;
							self.ammo_shells = floor(self.ammo_shells * 0.5);
						  	resource_shells_team2 = resource_shells_team2 + self.ammo_shells;
							self.ammo_fuel = floor(self.ammo_fuel * 0.5);
						  	resource_fuel_team2 = resource_fuel_team2 + self.ammo_fuel;
						  }
						  else if (attacker.team == COLOR_TEAM3)
						  {
						  	self.ammo_nails = floor(self.ammo_nails * 0.5);
						  	resource_nails_team3 = resource_nails_team3 + self.ammo_nails;
							self.ammo_rockets = floor(self.ammo_rockets * 0.5);
						  	resource_rockets_team3 = resource_rockets_team3 + self.ammo_rockets;
							self.ammo_cells = floor(self.ammo_cells * 0.5);
						  	resource_cells_team3 = resource_cells_team3 + self.ammo_cells;
							self.ammo_shells = floor(self.ammo_shells * 0.5);
						  	resource_shells_team3 = resource_shells_team3 + self.ammo_shells;
							self.ammo_fuel = floor(self.ammo_fuel * 0.5);
						  	resource_fuel_team3 = resource_fuel_team3 + self.ammo_fuel;
						  }
						  else if (attacker.team == COLOR_TEAM4)
						  {
						  	self.ammo_nails = floor(self.ammo_nails * 0.5);
						  	resource_nails_team4 = resource_nails_team4 + self.ammo_nails;
							self.ammo_rockets = floor(self.ammo_rockets * 0.5);
						  	resource_rockets_team4 = resource_rockets_team4 + self.ammo_rockets;
							self.ammo_cells = floor(self.ammo_cells * 0.5);
						  	resource_cells_team4 = resource_cells_team4 + self.ammo_cells;
							self.ammo_shells = floor(self.ammo_shells * 0.5);
						  	resource_shells_team4 = resource_shells_team4 + self.ammo_shells;
							self.ammo_fuel = floor(self.ammo_fuel * 0.5);
						  	resource_fuel_team4 = resource_fuel_team4 + self.ammo_fuel;
						  }
					}
					else
					{
							self.ammo_nails = floor(self.ammo_nails * 0.5);
						  	resource_nails_world = resource_nails_world + self.ammo_nails;
							self.ammo_rockets = floor(self.ammo_rockets * 0.5);
						  	resource_rockets_world = resource_rockets_world + self.ammo_rockets;
							self.ammo_cells = floor(self.ammo_cells * 0.5);
						  	resource_cells_world = resource_cells_world + self.ammo_cells;
							self.ammo_shells = floor(self.ammo_shells * 0.5);
						  	resource_shells_world = resource_shells_world + self.ammo_shells;
							self.ammo_fuel = floor(self.ammo_fuel * 0.5);
						  	resource_fuel_world = resource_fuel_world + self.ammo_fuel;
					}
					
					//print(ftos(resource_nails_world),"-N  ",ftos(resource_rockets_world),"-R  ",ftos(resource_cells_world),"-C  ",ftos(resource_shells_world),"-S  ",ftos(resource_fuel_world),"-F  \n");
				
					an = floor(self.multitool_ammocurrent * 0.5);
					attacker.multitool_ammocurrent = attacker.multitool_ammocurrent + an;
					self.multitool_ammocurrent = an;
				
					ar = floor(self.multitool_ammocurrentr * 0.5);
					attacker.multitool_ammocurrentr = attacker.multitool_ammocurrentr + ar;
					self.multitool_ammocurrentr = ar;
				
					ac = floor(self.multitool_ammocurrentc * 0.5);
					attacker.multitool_ammocurrentc = attacker.multitool_ammocurrentc + ac;
					self.multitool_ammocurrentc = ac;
				}
			}
			// become fully visible
			self.alpha = default_player_alpha;
			// throw a weapon
			SpawnThrownWeapon (self.origin + (self.mins + self.maxs) * 0.5, self.switchweapon);
			ZeroOutMagicInventory(self);
			RemoveStartSpells(self);
			WEPSET_CLEAR_E(self); //So we don't double drop the in-hand weapon in a MLRS/HK/turret rocket or spell explosion, thus avoid duping
		}

		// print an obituary message
		Obituary (attacker, inflictor, self, deathtype);
		RecordIfBurnedOtherToDeath (attacker, inflictor, self, deathtype);
		race_PreDie();
		DropAllRunes(self);

        // increment frag counter for used weapon type
        float w;
        w = DEATH_WEAPONOF(deathtype);
        if(WEP_VALID(w))
	if(accuracy_isgooddamage(attacker, self))
	if not(attacker.noaccuracyfrags)
        attacker.accuracy.(accuracy_frags[w-1]) += 1;
		
		if(deathtype == DEATH_HURTTRIGGER && g_freezetag)
		{
			PutClientInServer();
			count_alive_players(); // re-count players
			freezetag_CheckWinner();
			return;
		}

		frag_attacker = attacker;
		frag_inflictor = inflictor;
		frag_target = self;
		MUTATOR_CALLHOOK(PlayerDies);
		self.weaponaltaim_use = 0;
		self.weaponinitaimmotif_use = 0;
		weapon_action(self.weapon, WR_PLAYERDEATH);

		RemoveGrapplingHook(self);

		Portal_ClearAllLater(self);

		if(clienttype(self) == CLIENTTYPE_REAL)
		{
			stuffcmd(self, "-zoom\n");
			self.fixangle = TRUE;
			//msg_entity = self;
			//WriteByte (MSG_ONE, SVC_SETANGLE);
			//WriteAngle (MSG_ONE, self.v_angle_x);
			//WriteAngle (MSG_ONE, self.v_angle_y);
			//WriteAngle (MSG_ONE, 80);
		}

		if(defer_ClientKill_Now_TeamChange) // TODO does this work with FreezeTag?
			ClientKill_Now_TeamChange();
		
		if(g_colorwar)
		if(self.deadflag == DEAD_NO)
		if(attacker != world)
		if(clienttype(attacker) == CLIENTTYPE_REAL || clienttype(attacker) == CLIENTTYPE_BOT)
		{
			if(teamplay)
			{
				if(self.team != attacker.team)
				{
					SetPlayerTeam(self, attacker.team, attacker.team, TRUE);
					self.team = attacker.team;
					if(autocvar_g_colorwar_forceteam)
					{
						self.team_forced = attacker.team;
					}
					self.clientcolors = attacker.clientcolors;
				}
			}
			else {
				self.clientcolors = attacker.clientcolors;
				self.autoclientcolorshirt = floor(self.clientcolors / 16); //Shirt
				self.autoclientcolorpants = mod(self.clientcolors, 16);    //Pants
				self.autoclientcolorset = 1;

			}
			//self.colormap = attacker.colormap;
		}
		
		if(g_arena)
			Spawnqueue_Unmark(self);

		if(g_freezetag)
			return;

		// when we get here, player actually dies
		// clear waypoints (do this AFTER FreezeTag)
		WaypointSprite_PlayerDead();

		// make the corpse upright (not tilted)
		self.angles_x = 0;
		self.angles_z = 0;
		// don't spin
		self.avelocity = '0 0 0';
		// view from the floor
		self.view_ofs = '0 0 -8';
		// toss the corpse
		self.movetype = MOVETYPE_TOSS;
		// shootable corpse
		self.solid = SOLID_CORPSE;
		self.ballistics_density = autocvar_g_ballistics_density_corpse;
		// don't stick to the floor
		self.flags &~= FL_ONGROUND;
		// dying animation
		self.deadflag = DEAD_DYING;
		// when to allow respawn
		sdelay = 0;
		waves = 0;
		sdelay = cvar(strcat("g_", GetGametype(), "_respawn_delay"));
		if(!sdelay)
		{
			if(g_cts)
				sdelay = 0; // no respawn delay in CTS
			else
				sdelay = autocvar_g_respawn_delay;
		}
		waves = cvar(strcat("g_", GetGametype(), "_respawn_waves"));
		if(!waves)
			waves = autocvar_g_respawn_waves;
		if(waves)
			self.respawn_time = ceil((time + sdelay) / waves) * waves;
		else
			self.respawn_time = time + sdelay;
		if((sdelay + waves >= 5.0) && (self.respawn_time - time > 1.75))
			self.respawn_countdown = 10; // first number to count down from is 10
		else
			self.respawn_countdown = -1; // do not count down
		self.death_time = time;
		if (self.handcuffed)
		{
			self.jailor.jailee = world; //So can take other prisoners;
		}
		if (self.jailee != world)
		{
			self.jailee.jailor = world;  //So not chained to a corpse
			self.jailee = world;
		}
		if (self.stoned)
		{
			self.stonedorigin = self.origin;
		}
		else
		{
			if (random() < 0.5)
				setanim(self, self.anim_die1, FALSE, TRUE, TRUE);
			else
				setanim(self, self.anim_die2, FALSE, TRUE, TRUE);
		}
		if (self.maxs_z > 5)
		{
			self.maxs_z = 5;
			setsize(self, self.mins, self.maxs);
		}
		// set damage function to corpse damage
		self.event_damage = PlayerCorpseDamage;
		// call the corpse damage function just in case it wants to gib
		self.event_damage(inflictor, attacker, excess, deathtype, hitloc, force);
		// set up to fade out later
		SUB_SetFade (self, time + 6 + random (), 1);

		// remove laserdot
		if(self.weaponentity)
			if(self.weaponentity.lasertarget)
				remove(self.weaponentity.lasertarget);

		unmarshalmonsters(self);
		self.marshalattack = 0;
		
		if(sv_gentle > 0 || autocvar_ekg) {
			// remove corpse
			PlayerCorpseDamage (inflictor, attacker, autocvar_sv_gibhealth+1.0, deathtype, hitloc, force);
		}

		// reset fields the weapons may use just in case
		for (j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			self.weaponaltaim_use = 0;
			self.weaponinitaimmotif_use = 0;
			weapon_action(j, WR_RESETPLAYER);
			ATTACK_FINISHED_FOR(self, j) = 0;
		}
	}
}

.float muted; // to be used by prvm_edictset server playernumber muted 1
float Say(entity source, float teamsay, entity privatesay, string msgin, float floodcontrol)
// message "": do not say, just test flood control
// return value:
//   1 = accept
//   0 = reject
//  -1 = fake accept
{
	string msgstr, colorstr, cmsgstr, namestr, fullmsgstr, sourcemsgstr, fullcmsgstr, sourcecmsgstr;
	float flood;
	var .float flood_field;
	entity head;
	float ret;
	string privatemsgprefix = string_null; float privatemsgprefixlen = 0;

	if(Ban_MaybeEnforceBan(source))
		return 0;

	if(!teamsay && !privatesay)
		if(substring(msgin, 0, 1) == " ")
			msgin = substring(msgin, 1, strlen(msgin) - 1); // work around DP say bug (say_team does not have this!)

	msgin = formatmessage(msgin);

	if(source.classname != "player")
		colorstr = "^0"; // black for spectators
	else if(teamplay)
		colorstr = Team_ColorCode(source.team);
	else
	{
		colorstr = "";
		teamsay = FALSE;
	}

	if(intermission_running)
		teamsay = FALSE;

	if(msgin != "")
		msgin = trigger_magicear_processmessage_forallears(source, teamsay, privatesay, msgin);

	/*
	 * using bprint solves this... me stupid
	// how can we prevent the message from appearing in a listen server?
	// for now, just give "say" back and only handle say_team
	if(!teamsay)
	{
		clientcommand(self, strcat("say ", msgin));
		return;
	}
	*/

	if(autocvar_g_chat_teamcolors)
		namestr = playername(source);
	else
		namestr = source.netname;

	if(msgin != "")
	{
		if(privatesay)
		{
			msgstr = strcat("\{1}\{13}* ^3", namestr, "^3 tells you: ^7");
			privatemsgprefixlen = strlen(msgstr);
			msgstr = strcat(msgstr, msgin);
			cmsgstr = strcat(colorstr, "^3", namestr, "^3 tells you:\n^7", msgin);
			if(autocvar_g_chat_teamcolors)
				privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", playername(privatesay), ": ^7");
			else
				privatemsgprefix = strcat("\{1}\{13}* ^3You tell ", privatesay.netname, ": ^7");
		}
		else if(teamsay)
		{
			msgstr = strcat("\{1}\{13}", colorstr, "(^3", namestr, colorstr, ") ^7", msgin);
			cmsgstr = strcat(colorstr, "(^3", namestr, colorstr, ")\n^7", msgin);
		}
		else
		{
			msgstr = strcat("\{1}", namestr, "^7: ", msgin);
			cmsgstr = "";
		}
		msgstr = strcat(strreplace("\n", " ", msgstr), "\n"); // newlines only are good for centerprint
	}
	else
	{
		msgstr = cmsgstr = "";
	}

	fullmsgstr = msgstr;
	fullcmsgstr = cmsgstr;

	// FLOOD CONTROL
	flood = 0;
	flood_field = floodcontrol_chat;
	if(floodcontrol)
	{
		float flood_spl;
		float flood_burst;
		float flood_lmax;
		float lines;
		if(privatesay)
		{
			flood_spl = autocvar_g_chat_flood_spl_tell;
			flood_burst = autocvar_g_chat_flood_burst_tell;
			flood_lmax = autocvar_g_chat_flood_lmax_tell;
			flood_field = floodcontrol_chattell;
		}
		else if(teamsay)
		{
			flood_spl = autocvar_g_chat_flood_spl_team;
			flood_burst = autocvar_g_chat_flood_burst_team;
			flood_lmax = autocvar_g_chat_flood_lmax_team;
			flood_field = floodcontrol_chatteam;
		}
		else
		{
			flood_spl = autocvar_g_chat_flood_spl;
			flood_burst = autocvar_g_chat_flood_burst;
			flood_lmax = autocvar_g_chat_flood_lmax;
			flood_field = floodcontrol_chat;
		}
		flood_burst = max(0, flood_burst - 1);
		// to match explanation in default.cfg, a value of 3 must allow three-line bursts and not four!

		// do flood control for the default line size
		if(msgstr != "")
		{
			getWrappedLine_remaining = msgstr;
			msgstr = "";
			lines = 0;
			while(getWrappedLine_remaining && (!flood_lmax || lines <= flood_lmax))
			{
				msgstr = strcat(msgstr, " ", getWrappedLineLen(82.4289758859709, strlennocol)); // perl averagewidth.pl < gfx/vera-sans.width
				++lines;
			}
			msgstr = substring(msgstr, 1, strlen(msgstr) - 1);

			if(getWrappedLine_remaining != "")
			{
				msgstr = strcat(msgstr, "\n");
				flood = 2;
			}

			if(time >= source.flood_field)
			{
				source.flood_field = max(time - flood_burst * flood_spl, source.flood_field) + lines * flood_spl;
			}
			else
			{
				flood = 1;
				msgstr = fullmsgstr;
			}
		}
		else
		{
			if(time >= source.flood_field)
				source.flood_field = max(time - flood_burst * flood_spl, source.flood_field) + flood_spl;
			else
				flood = 1;
		}

		if (timeout_status == TIMEOUT_ACTIVE) // when game is paused, no flood protection
			source.flood_field = flood = 0;
	}

	if(flood == 2) // cannot happen for empty msgstr
	{
		if(autocvar_g_chat_flood_notify_flooder)
		{
			sourcemsgstr = strcat(msgstr, "\n^3FLOOD CONTROL: ^7message too long, trimmed\n");
			sourcecmsgstr = "";
		}
		else
		{
			sourcemsgstr = fullmsgstr;
			sourcecmsgstr = fullcmsgstr;
		}
		cmsgstr = "";
	}
	else
	{
		sourcemsgstr = msgstr;
		sourcecmsgstr = cmsgstr;
	}

	if(!privatesay)
	if(source.classname != "player")
	{
		if not(intermission_running)
			if(teamsay || (autocvar_g_chat_nospectators == 1) || (autocvar_g_chat_nospectators == 2 && !(inWarmupStage || gameover)))
				teamsay = -1; // spectators
	}

	if(flood)
		print("NOTE: ", playername(source), "^7 is flooding.\n");

	// build sourcemsgstr by cutting off a prefix and replacing it by the other one
	if(privatesay)
		sourcemsgstr = strcat(privatemsgprefix, substring(sourcemsgstr, privatemsgprefixlen, -1));

	if(source.muted)
	{
		// always fake the message
		ret = -1;
	}
	else if(flood == 1)
	{
		if(autocvar_g_chat_flood_notify_flooder)
		{
			sprint(source, strcat("^3FLOOD CONTROL: ^7wait ^1", ftos(source.flood_field - time), "^3 seconds\n"));
			ret = 0;
		}
		else
			ret = -1;
	}
	else
	{
		ret = 1;
	}

	if(sourcemsgstr != "" && ret != 0)
	{
		if(ret < 0) // faked message, because the player is muted
		{
			sprint(source, sourcemsgstr);
			if(sourcecmsgstr != "" && !privatesay)
				centerprint(source, sourcecmsgstr);
		}
		else if(privatesay) // private message, between 2 people only, not sent to server console
		{
			sprint(source, sourcemsgstr);
			sprint(privatesay, msgstr);
			if(cmsgstr != "")
				centerprint(privatesay, cmsgstr);
		}
		else if(teamsay > 0) // team message, only sent to team mates
		{
			sprint(source, sourcemsgstr);
			//print(msgstr); // send to server console too
			if(sourcecmsgstr != "")
				centerprint(source, sourcecmsgstr);
			FOR_EACH_REALPLAYER(head) if(head.team == source.team)
				if(head != source)
				{
					sprint(head, msgstr);
					if(cmsgstr != "")
						centerprint(head, cmsgstr);
				}
		}
		else if(teamsay < 0) // spectator message, only sent to spectators
		{
			sprint(source, sourcemsgstr);
			//print(msgstr); // send to server console too
			FOR_EACH_REALCLIENT(head) if(head.classname != "player")
				if(head != source)
					sprint(head, msgstr);
		}
		else if(sourcemsgstr != msgstr) // trimmed/server fixed message, sent to all players
		{
			sprint(source, sourcemsgstr);
			//print(msgstr); // send to server console too
			FOR_EACH_REALCLIENT(head)
				if(head != source)
					sprint(head, msgstr);
		}
		else
			bprint(msgstr); // entirely normal message, sent to all players -- bprint sends to server console too.
	}

	return ret;
}

float GetVoiceMessageVoiceType(string type)
{
	if(type == "taunt")
		return VOICETYPE_TAUNT;
	if(type == "teamshoot")
		return VOICETYPE_LASTATTACKER;
	return VOICETYPE_TEAMRADIO;
}

string allvoicesamples;
.string GetVoiceMessageSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLVOICEMSGS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

.string GetPlayerSoundSampleField(string type)
{
	GetPlayerSoundSampleField_notFound = 0;
	switch(type)
	{
#define _VOICEMSG(m) case #m: return playersound_##m;
		ALLPLAYERSOUNDS
#undef _VOICEMSG
	}
	GetPlayerSoundSampleField_notFound = 1;
	return playersound_taunt;
}

void PrecacheGlobalSound(string samplestring)
{
	float n, i;
	tokenize_console(samplestring);
	n = stof(argv(1));
	if(n > 0)
	{
		for(i = 1; i <= n; ++i)
			precache_sound(strcat(argv(0), ftos(i), ".wav"));
	}
	else
	{
		precache_sound(strcat(argv(0), ".wav"));
	}
}

void PrecachePlayerSounds(string f)
{
	float fh;
	string s;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
		return;
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
		{
			dprint("Invalid sound info line: ", s, "\n");
			continue;
		}
		PrecacheGlobalSound(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);

	if not(allvoicesamples)
	{
#define _VOICEMSG(m) allvoicesamples = strcat(allvoicesamples, " ", #m);
		ALLVOICEMSGS
#undef _VOICEMSG
		allvoicesamples = strzone(substring(allvoicesamples, 1, strlen(allvoicesamples) - 1));
	}
}

void ClearPlayerSounds()
{
#define _VOICEMSG(m) if(self.playersound_##m) { strunzone(self.playersound_##m); self.playersound_##m = string_null; }
	ALLPLAYERSOUNDS
	ALLVOICEMSGS
#undef _VOICEMSG
}

float LoadPlayerSounds(string f, float first)
{
	float fh;
	string s;
	var .string field;
	fh = fopen(f, FILE_READ);
	if(fh < 0)
	{
		dprint("Player sound file not found: ", f, "\n");
		return 0;
	}
	while((s = fgets(fh)))
	{
		if(tokenize_console(s) != 3)
			continue;
		field = GetPlayerSoundSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			field = GetVoiceMessageSampleField(argv(0));
		if(GetPlayerSoundSampleField_notFound)
			continue;
		if(self.field)
			strunzone(self.field);
		self.field = strzone(strcat(argv(1), " ", argv(2)));
	}
	fclose(fh);
	return 1;
}

.float modelindex_for_playersound;
.float skin_for_playersound;
void UpdatePlayerSounds()
{
	if(self.modelindex == self.modelindex_for_playersound)
	if(self.skin == self.skin_for_playersound)
		return;
	self.modelindex_for_playersound = self.modelindex;
	self.skin_for_playersound = self.skin;
	ClearPlayerSounds();
	LoadPlayerSounds("sound/player/default.sounds", 1);
	if(!autocvar_g_debug_defaultsounds)
		if(!LoadPlayerSounds(get_model_datafilename(self.model, self.skin, "sounds"), 0))
			LoadPlayerSounds(get_model_datafilename(self.model, 0, "sounds"), 0);
}

void FakeGlobalSound(string sample, float chan, float voicetype)
{
	float n;
	float tauntrand;

	if(sample == "")
		return;

	tokenize_console(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization

	switch(voicetype)
	{
		case VOICETYPE_LASTATTACKER_ONLY:
			break;
		case VOICETYPE_LASTATTACKER:
			if(self.pusher)
			{
				msg_entity = self;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TEAMRADIO:
			msg_entity = self;
			if(msg_entity.cvar_cl_voice_directional == 1)
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			break;
		case VOICETYPE_AUTOTAUNT:
			if(!sv_autotaunt)
				break;
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			tauntrand = random();
			msg_entity = self;
			if (tauntrand < msg_entity.cvar_cl_autotaunt)
			{
				if (msg_entity.cvar_cl_voice_directional >= 1)
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
				else
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TAUNT:
			if(self.classname == "player")
				if(self.deadflag == DEAD_NO)
					setanim(self, self.anim_taunt, FALSE, TRUE, TRUE);
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			msg_entity = self;
			if (msg_entity.cvar_cl_voice_directional >= 1)
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
			else
				soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			break;
		case VOICETYPE_PLAYERSOUND:
			msg_entity = self;
			soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NORM);
			break;
		default:
			backtrace("Invalid voice type!");
			break;
	}
}

void GlobalSound(string sample, float chan, float voicetype)
{
	float n;
	float tauntrand;

	if(sample == "")
		return;

	tokenize_console(sample);
	n = stof(argv(1));
	if(n > 0)
		sample = strcat(argv(0), ftos(floor(random() * n + 1)), ".wav"); // randomization
	else
		sample = strcat(argv(0), ".wav"); // randomization

	switch(voicetype)
	{
		case VOICETYPE_LASTATTACKER_ONLY:
			if(self.pusher)
			{
				msg_entity = self.pusher;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			}
			break;
		case VOICETYPE_LASTATTACKER:
			if(self.pusher)
			{
				msg_entity = self.pusher;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
				msg_entity = self;
				if(clienttype(msg_entity) == CLIENTTYPE_REAL)
					soundto(MSG_ONE, self, chan, sample, VOL_BASE, ATTN_NONE);
			}
			break;
		case VOICETYPE_TEAMRADIO:
			FOR_EACH_REALCLIENT(msg_entity)
				if(!teamplay || msg_entity.team == self.team)
				{
					if(msg_entity.cvar_cl_voice_directional == 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_MIN);
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_AUTOTAUNT:
			if(!sv_autotaunt)
				break;
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			tauntrand = random();
			FOR_EACH_REALCLIENT(msg_entity)
				if (tauntrand < msg_entity.cvar_cl_autotaunt)
				{
					if (msg_entity.cvar_cl_voice_directional >= 1)
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
					else
						soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
				}
			break;
		case VOICETYPE_TAUNT:
			if(self.classname == "player")
				if(self.deadflag == DEAD_NO)
					setanim(self, self.anim_taunt, FALSE, TRUE, TRUE);
			if(!sv_taunt)
				break;
			if(sv_gentle)
				break;
			FOR_EACH_REALCLIENT(msg_entity)
			{
				if (msg_entity.cvar_cl_voice_directional >= 1)
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, bound(ATTN_MIN, msg_entity.cvar_cl_voice_directional_taunt_attenuation, ATTN_MAX));
				else
					soundto(MSG_ONE, self, chan, sample, VOL_BASEVOICE, ATTN_NONE);
			}
			break;
		case VOICETYPE_PLAYERSOUND:
			sound(self, chan, sample, VOL_BASE, ATTN_NORM);
			break;
		default:
			backtrace("Invalid voice type!");
			break;
	}
}

void PlayerSound(.string samplefield, float chan, float voicetype)
{
	GlobalSound(self.samplefield, chan, voicetype);
}

void VoiceMessage(string type, string msg)
{
	var .string sample;
	float voicetype, ownteam;
	float flood;
	sample = GetVoiceMessageSampleField(type);

	if(GetPlayerSoundSampleField_notFound)
	{
		sprint(self, strcat("Invalid voice. Use one of: ", allvoicesamples, "\n"));
		return;
	}

	voicetype = GetVoiceMessageVoiceType(type);
	ownteam = (voicetype == VOICETYPE_TEAMRADIO);

	flood = Say(self, ownteam, world, msg, 1);

	if (flood > 0)
		GlobalSound(self.sample, CH_VOICE, voicetype);
	else if (flood < 0)
		FakeGlobalSound(self.sample, CH_VOICE, voicetype);
}

void MoveToTeam(entity client, float team_colour, float type, float show_message)
{
// 	show_message
// 	0 (00) automove centerprint, admin message
// 	1 (01) automove centerprint, no admin message
// 	2 (10) no centerprint, admin message
// 	3 (11) no centerprint, no admin message

	float lockteams_backup;

	lockteams_backup = lockteams;  // backup any team lock

	lockteams = 0;  // disable locked teams

	TeamchangeFrags(client);  // move the players frags
	SetPlayerColors(client, team_colour - 1);  // set the players colour
	Damage(client, client, client, 100000, ((show_message & 2) ? DEATH_QUIET : DEATH_AUTOTEAMCHANGE), client.origin, '0 0 0');  // kill the player

	lockteams = lockteams_backup;  // restore the team lock

	LogTeamchange(client.playerid, client.team, type);

	if not(show_message & 1) // admin message
		sprint(client, strcat("\{1}\{13}^3", admin_name(), "^7: You have been moved to the ", Team_ColorNameLowerCase(team_colour), " team\n"));  // send a chat message

	bprint(strcat(client.netname, " joined the ", ColoredTeamName(client.team), "\n"));
}
