#ifdef REGISTER_WEAPON
REGISTER_WEAPON(FIREBALL, w_fireball, 0, 9, WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "fireball", "fireball", _("Fireball"));
#else
#ifdef SVQC
.float bot_primary_fireballmooth; // whatever a mooth is
.vector fireball_impactvec;
.float fireball_primarytime;

void W_Fireball_Explode (void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_fireball_primary_bfgradius, 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, autocvar_g_balance_fireball_primary_bfgradius); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / autocvar_g_balance_fireball_primary_bfgradius));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, autocvar_g_balance_fireball_primary_bfgdamage * points);

			Damage(e, self, self.realowner, autocvar_g_balance_fireball_primary_bfgdamage * points, self.projectiledeathtype | HITTYPE_BOUNCE | HITTYPE_SPLASH, e.origin + e.view_ofs, autocvar_g_balance_fireball_primary_bfgforce * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);
		}
	}

	remove (self);
}

void W_Fireball_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	
	if (self.altdeathtype_addspellexp_spell == 4) {
		if (other.altdeathtype_addspellexp_spell == 4) {
			if (self.classname == other.classname) {
				if (other.classname == "plasma_prim") {
					//print("ignore same spell\n");
					return;
				}
			}
		}
	}
	
	if (other.classname == "tree" || other.classname == "bush"
	|| ((other.classname == "bldhitbx" || other.classname == "building") && multitool_iswooden(other.count))
	) {
		Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
	}
	
	if (other.takedamage) {
		if (self.altdeathtype_addspellexp) {
				//Other firebolt type spells may be added later
				if (self.altdeathtype_addspellexp_spell == 1) {
						//fireball
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_fireball,
						exp_spell_fireball,
						self.altdeathtype_addspellexp, other);
				} else if (self.altdeathtype_addspellexp_spell == 3) {
						//flameburst
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_flameburst,
						exp_spell_flameburst,
						self.altdeathtype_addspellexp, other);
				} else if (self.altdeathtype_addspellexp_spell == 4) {
						//firecentury
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_firecentury,
						exp_spell_firecentury,
						self.altdeathtype_addspellexp, other);
				}
		}
	}
		
	W_Fireball_Explode ();
}

void W_Fireball_LaserPlay(float dt, float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;

	if(damage <= 0)
		return;

	RandomSelection_Init();
	for(e = WarpZone_FindRadius(self.origin, dist, TRUE); e; e = e.chain)
	if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
	{
		p = e.origin;
		p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
		p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
		p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
		d = vlen(WarpZone_UnTransformOrigin(e, self.origin) - p);
		if(d < dist)
		{
			e.fireball_impactvec = p;
			RandomSelection_Add(e, 0, string_null, 1 / (1 + d), !Fire_IsBurning(e));
		}
	}
	if(RandomSelection_chosen_ent)
	{
		d = vlen(WarpZone_UnTransformOrigin(RandomSelection_chosen_ent, self.origin) - RandomSelection_chosen_ent.fireball_impactvec);
		d = damage + (edgedamage - damage) * (d / dist);
		Fire_AddDamage(RandomSelection_chosen_ent, self.realowner, d * burntime, burntime, self.projectiledeathtype | HITTYPE_BOUNCE);
		//trailparticles(self, particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec);
		pointparticles(particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec - self.origin, 1);
	
		if (RandomSelection_chosen_ent.takedamage) {
			if (self.altdeathtype_addspellexp) {
				//Other firebolt type spells may be added later
				if (self.altdeathtype_addspellexp_spell == 1) {
						//fireball
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_fireball,
						exp_spell_fireball,
						self.altdeathtype_addspellexp * 0.01, RandomSelection_chosen_ent);
				} else if (self.altdeathtype_addspellexp_spell == 2) {
						//firebolt
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_firebolt,
						exp_spell_firebolt,
						self.altdeathtype_addspellexp * 0.01, RandomSelection_chosen_ent);
				} else if (self.altdeathtype_addspellexp_spell == 3) {
						//flameburst
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_flameburst,
						exp_spell_flameburst,
						self.altdeathtype_addspellexp * 0.01, RandomSelection_chosen_ent);
				} else if (self.altdeathtype_addspellexp_spell == 4) {
						//firecentury
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_firecentury,
						exp_spell_firecentury,
						self.altdeathtype_addspellexp * 0.01, RandomSelection_chosen_ent);
				}
			}
		}
	}
}

void W_Firecentury_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Fireball_Explode();
		return;
	}

	W_Fireball_LaserPlay(0.1, autocvar_g_balance_fireball_primary_laserradius, autocvar_g_balance_fireball_primary_laserdamage, autocvar_g_balance_fireball_primary_laseredgedamage, autocvar_g_balance_fireball_primary_laserburntime);

	self.nextthink = time + 0.1 + (random()*1.5);
}

void W_Fireball_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Fireball_Explode();
		return;
	}

	W_Fireball_LaserPlay(0.1, autocvar_g_balance_fireball_primary_laserradius, autocvar_g_balance_fireball_primary_laserdamage, autocvar_g_balance_fireball_primary_laseredgedamage, autocvar_g_balance_fireball_primary_laserburntime);

	self.nextthink = time + 0.1;
}

void W_Fireball_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.cnt = 1;
		W_PrepareExplosionByDamage(attacker, W_Fireball_Explode);
	}
}

void W_Fireball_Attack1()
{
	entity proj;

	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Fireball_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Fireball_Attack1_spell(entity player, float isscroll, float myexp)
{
	entity proj;

	W_SetupShot_ProjectileSize (player, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = player;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Fireball_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = player.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
    	proj.altdeathtype_addspellexp = myexp;
	proj.altdeathtype_addspellexp_spell = 1; //Set to 1 for fireball, is relevant only to the dmg section of this projectile
	proj.altdeathtype_addspellexp_owner = proj.owner;
	proj.altdeathtype_addspellexp_isscroll = isscroll;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Firecentury_Attack1_spell(entity player, float isscroll, float myexp, float mylifetime, vector myorigin)
{
	entity proj;

	W_SetupShot_ProjectileSize (player, '-32 -32 -32', '32 32 32', FALSE, 2, "", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	//pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = player;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + mylifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Firecentury_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = player.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, myorigin);

	proj.movetype = MOVETYPE_FLY;
	
	//W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_primary);
	//local vector mydir;
	//mydir = '0.001 0.001 0.001';
	//mydir_x *= ((random()*-0.5)*2);
	//mydir_y *= ((random()*-0.5)*2);
	//mydir_z *= ((random()*-0.5)*2);
	
	
	//W_SetupProjectileVelocityEx(proj, w_shotdir, v_up, 5, 0, 0, 0.025, FALSE);
	
	//W_SetupProjectileVelocityEx(proj, v_forward, v_up, 5, 0, 0, 0.025, FALSE);
	
	W_SetupProjectileVelocityEx(proj, v_forward, v_up, 5, 0, 0, 0.025, TRUE);

	
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Fireball_TouchExplode;
	setsize(proj, '-20 -20 -20', '20 20 20');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
    	proj.altdeathtype_addspellexp = myexp;
	proj.altdeathtype_addspellexp_spell = 4; //Set to 4 for firecentury, is relevant only to the dmg section of this projectile
	proj.altdeathtype_addspellexp_owner = proj.owner;
	proj.altdeathtype_addspellexp_isscroll = isscroll;
	
	proj.nohitplotanalysis = 1;
	proj.noaccuracyfrags = 1;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIRECENTURY, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Firecentury_Attack1_spell_dofromsavedvars()
{
	//this is so we can call it from spawnarray etc
	W_Firecentury_Attack1_spell(self.owner, self.altdeathtype_addspellexp_isscroll, self.altdeathtype_addspellexp, self.ammount2, self.origin);
}

//Iceball stuff
void W_Iceball_Explode (void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_fireball_primary_bfgradius, 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, autocvar_g_balance_fireball_primary_bfgradius); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / autocvar_g_balance_fireball_primary_bfgradius));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, autocvar_g_balance_fireball_primary_bfgdamage * points);

			Damage(e, self, self.realowner, autocvar_g_balance_fireball_primary_bfgdamage * points, self.projectiledeathtype, e.origin + e.view_ofs, autocvar_g_balance_fireball_primary_bfgforce * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);
		}
	}

	remove (self);
}

void W_Iceball_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	if (isPlayerOrMonsterByClassname(other))
	{
		if (autocvar_g_balance_fireball_test == 2) {
			//Test out some stone curse!
			Stone(other, 0.00);
		} else if (autocvar_g_balance_fireball_test == 3) {
			//Test out some stone curse time limited!
			Stone(other, 0.01);
		} else {
			Freeze(other, 0.01, 0);

		}
	}
	W_Iceball_Explode ();
}

void W_Iceball_LaserPlay(float dt, float dist, float damage, float edgedamage, float burntime)
{
	entity e;
	float d;
	vector p;

	if(damage <= 0)
		return;

	RandomSelection_Init();
	for(e = WarpZone_FindRadius(self.origin, dist, TRUE); e; e = e.chain)
	if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
	{
		p = e.origin;
		p_x += e.mins_x + random() * (e.maxs_x - e.mins_x);
		p_y += e.mins_y + random() * (e.maxs_y - e.mins_y);
		p_z += e.mins_z + random() * (e.maxs_z - e.mins_z);
		d = vlen(WarpZone_UnTransformOrigin(e, self.origin) - p);
		if(d < dist)
		{
			e.fireball_impactvec = p;
			RandomSelection_Add(e, 0, string_null, 1 / (1 + d), !Fire_IsBurning(e));
		}
	}
	if(RandomSelection_chosen_ent)
	{
		d = vlen(WarpZone_UnTransformOrigin(RandomSelection_chosen_ent, self.origin) - RandomSelection_chosen_ent.fireball_impactvec);
		d = damage + (edgedamage - damage) * (d / dist);
		if (autocvar_g_balance_fireball_test == 2) {
			//Test out some stone curse!
			Stone(RandomSelection_chosen_ent, 0.0);
		} else if (autocvar_g_balance_fireball_test == 3) {
			//Test out some stone curse!
			Stone(RandomSelection_chosen_ent, 0.1);
		} else {
			Freeze(RandomSelection_chosen_ent, 0.1, 0);
		}
		//trailparticles(self, particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec);
		pointparticles(particleeffectnum("fireball_laser"), self.origin, RandomSelection_chosen_ent.fireball_impactvec - self.origin, 1);
	}
}

void W_Iceball_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		//self.projectiledeathtype;
		W_Iceball_Explode();
		return;
	}

	W_Iceball_LaserPlay(0.1, autocvar_g_balance_fireball_primary_laserradius, autocvar_g_balance_fireball_primary_laserdamage, autocvar_g_balance_fireball_primary_laseredgedamage, autocvar_g_balance_fireball_primary_laserburntime);

	self.nextthink = time + 0.1;
}

void W_Iceball_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.cnt = 1;
		W_PrepareExplosionByDamage(attacker, W_Iceball_Explode);
	}
}

void W_Iceball_Attack1()
{
	entity proj;

	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	pointparticles(particleeffectnum("electro_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = self;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Iceball_Explode;
	proj.think = W_Iceball_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Iceball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_ICE;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	W_SETUPPROJECTILEVELOCITY(proj, g_balance_fireball_primary);
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Iceball_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_ICEBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_IceStar1_Explode (void)
{
	entity e, eburn;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	
	eburn = findradius(self.origin, autocvar_g_balance_fireball_primary_radius*6);
	while(eburn)
	{
		if ((eburn.classname == "player" || eburn.flags & FL_MONSTER) && eburn.health > 0)
			Freeze(eburn, 0.1, 0);
			
		eburn = eburn.chain;
	}
	remove(eburn);
	
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_fireball_primary_bfgradius, 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, autocvar_g_balance_fireball_primary_bfgradius); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / autocvar_g_balance_fireball_primary_bfgradius));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, autocvar_g_balance_fireball_primary_bfgdamage * points);

			Damage(e, self, self.realowner, autocvar_g_balance_fireball_primary_bfgdamage * points, self.projectiledeathtype, e.origin + e.view_ofs, autocvar_g_balance_fireball_primary_bfgforce * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);
		}
	}

	remove (self);
}

void W_IceStar1_TouchExplode (void)
{
	if (other.classname == "plasma_prim") {
		//print("this\n");
	} else if (other.classname == "grenade") {
		//print("nade\n");	
	} else if (other == self.owner) {
		//print("owner\n");
	} else {
		PROJECTILE_TOUCH;
		
		if ((other.classname == "player" || other.flags & FL_MONSTER) && other.health > 0)
		{
			Freeze(other, 0.01, 0);
		}
			
		W_IceStar1_Explode ();
	}
}

void W_IceStar1_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_IceStar1_Explode();
		return;
	}

	//W_Iceball_LaserPlay(0.1, autocvar_g_balance_fireball_primary_laserradius, autocvar_g_balance_fireball_primary_laserdamage, autocvar_g_balance_fireball_primary_laseredgedamage, autocvar_g_balance_fireball_primary_laserburntime);

	self.nextthink = time + 0.1;
}


void W_IceStar1(entity player, entity mowner)
{
	entity proj;
	vector direction;
	direction = randomvec();
	
	w_shotorg = player.origin;
	W_SetupShot_ProjectileSize (player, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = mowner;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Iceball_Explode;
	proj.think = W_IceStar1_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Iceball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_ICE;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	
	W_SetupProjectileVelocityEx(proj, direction, v_up, autocvar_g_balance_fireball_primary_speed, 0, 0, 0.025, FALSE);
	
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_IceStar1_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_ICEBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

//End Iceball stuff

void W_Fireball_AttackEffect(float i, vector f_diff)
{
	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 0, "", 0, 0);
	w_shotorg += f_diff_x * v_up + f_diff_y * v_right;
	pointparticles(particleeffectnum("fireball_preattack_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
}

void W_Fireball_Attack1_Frame4()
{
	if (autocvar_g_balance_fireball_test) {
		//Test out ice attack or stone curse
		W_Iceball_Attack1();
	} else {
		W_Fireball_Attack1();
	}
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fireball_primary_animtime, w_ready);
}

void W_Fireball_Attack1_Frame3()
{
	W_Fireball_AttackEffect(0, '+1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fireball_primary_animtime, W_Fireball_Attack1_Frame4);
}

void W_Fireball_Attack1_Frame2()
{
	W_Fireball_AttackEffect(0, '-1.25 +3.75 0');
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fireball_primary_animtime, W_Fireball_Attack1_Frame3);
}

void W_Fireball_Attack1_Frame1()
{
	W_Fireball_AttackEffect(1, '+1.25 -3.75 0');
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fireball_primary_animtime, W_Fireball_Attack1_Frame2);
}

void W_Fireball_Attack1_Frame0()
{
	W_Fireball_AttackEffect(0, '-1.25 -3.75 0');
	sound (self, CH_WEAPON_SINGLE, "weapons/fireball_prefire2.wav", VOL_BASE, ATTN_NORM);
	weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_fireball_primary_animtime, W_Fireball_Attack1_Frame1);
}

void W_Firemine_Think()
{
	if(time > self.pushltime)
	{
		remove(self);
		return;
	}

	// make it "hot" once it leaves its owner
	if(self.owner)
	{
		if(vlen(self.origin - self.owner.origin - self.owner.view_ofs) > autocvar_g_balance_fireball_secondary_laserradius)
		{
			self.cnt += 1;
			if(self.cnt == 3)
				self.owner = world;
		}
		else
			self.cnt = 0;
	}

	W_Fireball_LaserPlay(0.1, autocvar_g_balance_fireball_secondary_laserradius, autocvar_g_balance_fireball_secondary_laserdamage, autocvar_g_balance_fireball_secondary_laseredgedamage, autocvar_g_balance_fireball_secondary_laserburntime);

	self.nextthink = time + 0.1;
}

void W_Firemine_Touch (void)
{
	PROJECTILE_TOUCH;
	
	if (other.classname == "tree" || other.classname == "bush"
	|| ((other.classname == "bldhitbx" || other.classname == "building") && multitool_iswooden(other.count))
	) {
		Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
	}
	
	if (other.takedamage == DAMAGE_AIM)
	if(Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype | HITTYPE_HEADSHOT) >= 0)
	{
		if (self.altdeathtype_addspellexp) {
				//Other firebolt type spells may be added later
				if (self.altdeathtype_addspellexp_spell == 2) {
						//firebolt
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_firebolt,
						exp_spell_firebolt,
						self.altdeathtype_addspellexp, other);
				} else if (self.altdeathtype_addspellexp_spell == 3) {
						//flameburst 'secondary'
						IncreaseSpellExpAndMaybeLVL(self.altdeathtype_addspellexp_isscroll,
						self.altdeathtype_addspellexp_owner,
				 		spell_flameburst,
						exp_spell_flameburst,
						self.altdeathtype_addspellexp, other);
				}
		}
		remove(self);
		return;
	}
	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void W_Fireball_Attack2()
{
	entity proj;
	vector f_diff;
	float c;

	c = mod(self.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, self);
	w_shotorg = trace_endpos;

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = self;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + autocvar_g_balance_fireball_secondary_lifetime;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

//For the spell
void W_Fireball_Attack2_spell(entity player, float isscroll, float myexp)
{
	entity proj;
	vector f_diff;
	float c;

	c = mod(player.bulletcounter, 4);
	switch(c)
	{
		case 0:
			f_diff = '-1.25 -3.75 0';
			break;
		case 1:
			f_diff = '+1.25 -3.75 0';
			break;
		case 2:
			f_diff = '-1.25 +3.75 0';
			break;
		case 3:
		default:
			f_diff = '+1.25 +3.75 0';
			break;
	}
	W_SetupShot_ProjectileSize(player, '-4 -4 -4', '4 4 4', FALSE, 2, "weapons/fireball_fire.wav", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);
	traceline(w_shotorg, w_shotorg + f_diff_x * v_up + f_diff_y * v_right, MOVE_NORMAL, player);
	w_shotorg = trace_endpos;

	pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = player;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + autocvar_g_balance_fireball_secondary_lifetime;
	W_SETUPPROJECTILEVELOCITY_UP(proj, g_balance_fireball_secondary);

	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
    	proj.altdeathtype_addspellexp = myexp;
	proj.altdeathtype_addspellexp_spell = 2; //Set to 2 for firebolt, is relevant only to the dmg section of this projectile
	proj.altdeathtype_addspellexp_owner = proj.owner;
	proj.altdeathtype_addspellexp_isscroll = isscroll;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}
//

void W_Flameburst1_TouchExplode (void)
{
	if (other.classname == "plasma_prim") {
		//print("this\n");
	} else if (other.classname == "grenade") {
		//print("nade\n");	
	} else if (other == self.owner) {
		//print("owner\n");
	} else {
		PROJECTILE_TOUCH;
		if (other.classname == "tree" || other.classname == "bush"
		|| ((other.classname == "bldhitbx" || other.classname == "building") && multitool_iswooden(other.count))
		) {
			Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
		}
		W_Fireball_Explode ();
	}
}

void W_Flameburst1_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Fireball_Explode();
		return;
	}

	self.nextthink = time + 0.1;
}

void W_Meteor_Explode (void)
{
	entity e, eburn;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	// 1. dist damage
	d = (self.realowner.health + self.realowner.armorvalue);
	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
		
	eburn = findradius(self.origin, autocvar_g_balance_fireball_primary_radius*3);
	while(eburn)
	{
		if ((eburn.classname == "tree" || eburn.classname == "bush")
		|| ((eburn.classname == "bldhitbx" || eburn.classname == "building") && multitool_iswooden(eburn.count))
		|| ((eburn.classname == "player" || eburn.flags & FL_MONSTER) && eburn.health > 0)
		)
			Fire_AddDamage(eburn, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime*5, autocvar_g_balance_fireball_secondary_damagetime*5, self.projectiledeathtype);

		eburn = eburn.chain;
	}
	remove(eburn);
	
	if(self.realowner.health + self.realowner.armorvalue >= d)
	if(!self.cnt)
	{
		modeleffect_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_fireball_primary_bfgradius, 0.2, 0.05, 0.25);

		// 2. bfg effect
		// NOTE: this cannot be made warpzone aware by design. So, better intentionally ignore warpzones here.
		for(e = findradius(self.origin, autocvar_g_balance_fireball_primary_bfgradius); e; e = e.chain)
		if(e != self.realowner) if(e.takedamage == DAMAGE_AIM) if(e.classname != "player" || !self.realowner || IsDifferentTeam(e, self))
		{
			// can we see fireball?
			traceline(e.origin + e.view_ofs, self.origin, MOVE_NORMAL, e);
			if(/* trace_startsolid || */ trace_fraction != 1) // startsolid should be never happening anyway
				continue;
			// can we see player who shot fireball?
			traceline(e.origin + e.view_ofs, self.realowner.origin + self.realowner.view_ofs, MOVE_NORMAL, e);
			if(trace_ent != self.realowner)
			if(/* trace_startsolid || */ trace_fraction != 1)
				continue;
			dist = vlen(self.origin - e.origin - e.view_ofs);
			points = (1 - sqrt(dist / autocvar_g_balance_fireball_primary_bfgradius));
			if(points <= 0)
				continue;
			dir = normalize(e.origin + e.view_ofs - self.origin);

			if(accuracy_isgooddamage(self.realowner, e))
				accuracy_add(self.realowner, WEP_FIREBALL, 0, autocvar_g_balance_fireball_primary_bfgdamage * points);

			Damage(e, self, self.realowner, autocvar_g_balance_fireball_primary_bfgdamage * points, self.projectiledeathtype | HITTYPE_BOUNCE | HITTYPE_SPLASH, e.origin + e.view_ofs, autocvar_g_balance_fireball_primary_bfgforce * dir);
			pointparticles(particleeffectnum("fireball_bfgdamage"), e.origin, -1 * dir, 1);
		}
	}

	remove (self);
}

void W_Meteor_Think()
{
	if(time > self.pushltime)
	{
		self.cnt = 1;
		self.projectiledeathtype |= HITTYPE_SPLASH;
		W_Meteor_Explode();
		return;
	}

	self.nextthink = time + 0.1;
}

void W_Meteor_TouchExplode (void)
{
	PROJECTILE_TOUCH;
	if (other.classname == "plasma_prim") {
		//print("this\n");
	} else if (other.classname == "grenade") {
		//print("nade\n");	
	} else if (other == self.owner) {
		//print("owner\n");
	} else {
		PROJECTILE_TOUCH;
		if (other.classname == "tree" || other.classname == "bush"
		|| ((other.classname == "bldhitbx" || other.classname == "building") && multitool_iswooden(other.count))
		) {
			Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
		}
		W_Meteor_Explode ();
	}
}

void W_Meteor2(entity player, entity mowner, float mypushltime)
{
	entity proj;
	vector direction;
	direction = '0 0 -1';
	
	w_shotorg = player.origin;
	w_shotorg_z = w_shotorg_z - 16;
	W_SetupShot_ProjectileSize (player, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = mowner;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = mypushltime;
	proj.use = W_Meteor_Explode;
	proj.think = W_Meteor_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	
	W_SetupProjectileVelocityEx(proj, direction, v_up, autocvar_g_balance_fireball_primary_speed, 0, 0, 0.025, FALSE);
	
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Meteor_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Meteor1(entity player, entity mowner)
{
	//proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	W_Meteor2(player, mowner, time + autocvar_g_balance_fireball_primary_lifetime);
}

void W_StoneRain2(entity player, entity mowner, float mypushltime, float mynextthink)
{
	entity proj;
	vector direction;
	direction = '0 0 -1';
	
	w_shotorg = player.origin;
	w_shotorg_z = w_shotorg_z - 16;
	W_SetupShot_ProjectileSize (player, '-3 -3 -3', '3 3 3', FALSE, 2, "", CH_WEAPON_A, 30);

	proj = spawn ();
	proj.classname = "grenade";
	proj.owner = proj.realowner = mowner;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	
	proj.pushltime = mypushltime;
	proj.use = W_Grenade_ExplodeBRSR;
	proj.touch = W_Grenade_Touch2RSR;
	proj.think = adaptor_think2use_hittype_splash;
	proj.nextthink = mynextthink;
	proj.health = autocvar_g_balance_grenadelauncher_secondary_health;
	proj.team = self.team;
	proj.event_damage = W_Grenade_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = DEATH_VHCRUSH; //So doesn't gib
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_BOUNCE;
	
	W_SetupProjectileVelocityEx(proj, direction, v_up, autocvar_g_balance_fireball_primary_speed, 0, 0, 0.025, FALSE);
	
	proj.angles = vectoangles(proj.velocity);
	setsize(proj, '-3 -3 -3', '3 3 3');
	proj.flags = FL_PROJECTILE;
    	proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_ROCK, TRUE);
	//CSQCProjectile(proj, TRUE, PROJECTILE_ROCK_BOUNCING, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_StoneRain1(entity player, entity mowner)
{
	//Normal simple command, wrapper for more advanced one
	//proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	//proj.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	W_StoneRain2(player, mowner, time + autocvar_g_balance_fireball_primary_lifetime, time + autocvar_g_balance_grenadelauncher_secondary_lifetime);
}

void W_Flameburst1(entity player, float isscroll, float myexp)
{
	entity proj;
	vector direction;
	direction = randomvec();
	direction_z = 0;
	
	w_shotorg = player.origin;
	W_SetupShot_ProjectileSize (self, '-16 -16 -16', '16 16 16', FALSE, 2, "weapons/fireball_fire2.wav", CH_WEAPON_A, autocvar_g_balance_fireball_primary_damage + autocvar_g_balance_fireball_primary_bfgdamage);

	proj = spawn ();
	proj.classname = "plasma_prim";
	proj.owner = proj.realowner = player;
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_primary_damage;
	proj.pushltime = time + autocvar_g_balance_fireball_primary_lifetime;
	proj.use = W_Fireball_Explode;
	proj.think = W_Flameburst1_Think;
	proj.nextthink = time;
	proj.health = autocvar_g_balance_fireball_primary_health;
	proj.team = self.team;
	proj.event_damage = W_Fireball_Damage;
	proj.takedamage = DAMAGE_YES;
	proj.damageforcescale = autocvar_g_balance_fireball_primary_damageforcescale;
	PROJECTILE_MAKETRIGGER(proj);
	proj.projectiledeathtype = WEP_FIREBALL;
	setorigin(proj, w_shotorg);

	proj.movetype = MOVETYPE_FLY;
	
	W_SetupProjectileVelocityEx(proj, direction, v_up, autocvar_g_balance_fireball_primary_speed, 0, 0, 0.025, FALSE);
	
	proj.angles = vectoangles(proj.velocity);
	proj.touch = W_Flameburst1_TouchExplode;
	setsize(proj, '-16 -16 -16', '16 16 16');
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY;
    
    	proj.altdeathtype_addspellexp = myexp;
	proj.altdeathtype_addspellexp_spell = 3; //Set to 3 for flameburst, is relevant only to the dmg section of this projectile
	proj.altdeathtype_addspellexp_owner = proj.owner;
	proj.altdeathtype_addspellexp_isscroll = isscroll;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREBALL, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Flameburst2(float mylevel, entity player, float isscroll, float myexp)
{
	entity proj;
	
	W_SetupShot_ProjectileSize(self, '-4 -4 -4', '4 4 4', FALSE, 2, "", CH_WEAPON_A, autocvar_g_balance_fireball_secondary_damage);
	//w_shotorg = player.origin;

	//pointparticles(particleeffectnum("fireball_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	proj = spawn ();
	proj.owner = proj.realowner = self;
	proj.classname = "grenade";
	proj.bot_dodge = TRUE;
	proj.bot_dodgerating = autocvar_g_balance_fireball_secondary_damage;
	proj.movetype = MOVETYPE_BOUNCE;
	proj.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
	proj.touch = W_Firemine_Touch;
	PROJECTILE_MAKETRIGGER(proj);
	setsize(proj, '-4 -4 -4', '4 4 4');
	setorigin(proj, w_shotorg);
	proj.think = W_Firemine_Think;
	proj.nextthink = time;
	proj.damageforcescale = autocvar_g_balance_fireball_secondary_damageforcescale;
	proj.pushltime = time + autocvar_g_balance_fireball_secondary_lifetime;

	proj.velocity = randomvec()*(256+(mylevel*4));
	//proj.velocity = '1 1 0' * random() * 10000;
	proj.velocity_z = 0;
	
	proj.angles = vectoangles(proj.velocity);
	proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_ARC;
    
    	proj.altdeathtype_addspellexp = myexp;
	proj.altdeathtype_addspellexp_spell = 3; //Set to 3 for flameburst, is relevant only to the dmg section of this projectile
	proj.altdeathtype_addspellexp_owner = proj.owner;
	proj.altdeathtype_addspellexp_isscroll = isscroll;
    
	CSQCProjectile(proj, TRUE, PROJECTILE_FIREMINE, TRUE);

	other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

void spawnfunc_weapon_fireball (void)
{
	weapon_defaultspawnfunc(WEP_FIREBALL);
}

float w_fireball(float req)
{
	//float ammo_amount;
	if (req == WR_AIM)
	{
		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if (self.bot_primary_fireballmooth == 0)
		{
			if(bot_aim(autocvar_g_balance_fireball_primary_speed, 0, autocvar_g_balance_fireball_primary_lifetime, FALSE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.02) self.bot_primary_fireballmooth = 0;
			}
		}
		else
		{
			if(bot_aim(autocvar_g_balance_fireball_secondary_speed, autocvar_g_balance_fireball_secondary_speed_up, autocvar_g_balance_fireball_secondary_lifetime, TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.01) self.bot_primary_fireballmooth = 1;
			}
		}
	}
	else if (req == WR_THINK)
	{
		if (self.BUTTON_ATCK)
		{
			if (time >= self.fireball_primarytime)
			if (weapon_prepareattack(0, autocvar_g_balance_fireball_primary_refire))
			{
				W_Fireball_Attack1_Frame0();
				self.fireball_primarytime = time + autocvar_g_balance_fireball_primary_refire2 * W_WeaponRateFactor();
			}
		}
		else if (self.BUTTON_ATCK2)
		{
			if (weapon_prepareattack(1, autocvar_g_balance_fireball_secondary_refire))
			{
				W_Fireball_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_fireball_secondary_animtime, w_ready);
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_fireball.md3");
		precache_model ("models/weapons/v_fireball.md3");
		precache_model ("models/weapons/h_fireball.iqm");
		precache_model ("models/sphere/sphere.md3");
		precache_sound ("weapons/fireball_fire.wav");
		precache_sound ("weapons/fireball_fire2.wav");
		precache_sound ("weapons/fireball_prefire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{	
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '32 -0.01 -6.5';
		weapon_setup(WEP_FIREBALL);
		self.current_ammo = ammo_none;
	}
	else if (req == WR_CHECKAMMO1)
	{
		return 1;
	}
	else if (req == WR_CHECKAMMO2)
	{
		return 1;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.fireball_primarytime = time;
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_fireball(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			// firemine goes out silently
		}
		else
		{
			org2 = w_org + w_backoff * 16;
			pointparticles(particleeffectnum("fireball_explode"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/fireball_impact2.wav", VOL_BASE, ATTN_NORM * 0.25); // long range boom
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/fireball_impact2.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s forgot about some firemine");
		else
			w_deathtypestring = _("%s should have used a smaller gun");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_HEADSHOT)
				w_deathtypestring = _("%s tried to catch %s's firemine");
			else
				w_deathtypestring = _("%s fatefully ignored %s's firemine");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				if(w_deathtype & HITTYPE_SPLASH) // BFG effect
					w_deathtypestring = _("%s could not hide from %s's fireball");
				else // laser
					w_deathtypestring = _("%s saw the pretty lights of %s's fireball");
			}
			else if(w_deathtype & HITTYPE_SPLASH)
				w_deathtypestring = _("%s got too close to %s's fireball");
			else
				w_deathtypestring = _("%s tasted %s's fireball");
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_fireball (void)
//{
//	weapon_defaultspawnfunc(WEP_FIREBALL);
//}
