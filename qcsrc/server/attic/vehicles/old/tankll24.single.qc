const vector TANKLL24_MIN = '-100 -100 2';
const vector TANKLL24_MAX  = '100 100 136';

const vector TANKLL24_MIN_HBF = '-80 -80 2';
const vector TANKLL24_MAX_HBF = '80 80 85';

const vector TANKLL24_MIN_HBB = '-65 -65 2';
const vector TANKLL24_MAX_HBB = '65 65 75';

#ifdef SVQC
float autocvar_g_vehicle_tankll24;

float autocvar_g_vehicle_tankll24_respawntime;

float autocvar_g_vehicle_tankll24_speed_stop;
float autocvar_g_vehicle_tankll24_speed_strafe;
float autocvar_g_vehicle_tankll24_speed_walk;
float autocvar_g_vehicle_tankll24_movement_inertia;

float autocvar_g_vehicle_tankll24_springlength;
float autocvar_g_vehicle_tankll24_springup;
float autocvar_g_vehicle_tankll24_springblend;
float autocvar_g_vehicle_tankll24_tiltlimit;

//float autocvar_g_vehicle_tankll24_gun_turnlimit;
//float autocvar_g_vehicle_tankll24_gun_turnspeed;

float autocvar_g_vehicle_tankll24_turret_turnlimit;
float autocvar_g_vehicle_tankll24_turret_turnspeed;

//float autocvar_g_vehicle_tankll24_energy;
//float autocvar_g_vehicle_tankll24_energy_regen;
//float autocvar_g_vehicle_tankll24_energy_regen_pause;

float autocvar_g_vehicle_tankll24_health;
float autocvar_g_vehicle_tankll24_health_regen;
float autocvar_g_vehicle_tankll24_health_regen_pause;

float autocvar_g_vehicle_tankll24_shield;
float autocvar_g_vehicle_tankll24_shield_regen;
float autocvar_g_vehicle_tankll24_shield_regen_pause;

float autocvar_g_vehicle_tankll24_raacannon_damage;
float autocvar_g_vehicle_tankll24_raacannon_bulletconstant;
float autocvar_g_vehicle_tankll24_raacannon_speed;
float autocvar_g_vehicle_tankll24_raacannon_headshotaddeddamage;
float autocvar_g_vehicle_tankll24_raacannon_force;
float autocvar_g_vehicle_tankll24_raacannon_coreshotaddeddamage;
float autocvar_g_vehicle_tankll24_raacannon_spread;
//float autocvar_g_vehicle_tankll24_raacannon_refire;
float autocvar_g_vehicle_tankll24_raacannon_refire_min;
float autocvar_g_vehicle_tankll24_raacannon_refire_max;
float autocvar_g_vehicle_tankll24_raacannon_refire_changerate;
float autocvar_g_vehicle_tankll24_raacannon_ammo_cost;
//float autocvar_g_vehicle_tankll24_raacannon_fragments;
float autocvar_g_vehicle_tankll24_raacannon_pitchspeed;
float autocvar_g_vehicle_tankll24_raacannon_pitchlimit_down;
float autocvar_g_vehicle_tankll24_raacannon_pitchlimit_up;
//float autocvar_g_vehicle_tankll24_raacannon_ammo_regen_pause;
float autocvar_g_vehicle_tankll24_raacannon_ammo_max;

float autocvar_g_vehicle_tankll24_aicannon_damage;
float autocvar_g_vehicle_tankll24_aicannon_bulletconstant;
float autocvar_g_vehicle_tankll24_aicannon_speed;
float autocvar_g_vehicle_tankll24_aicannon_headshotaddeddamage;
float autocvar_g_vehicle_tankll24_aicannon_force;
float autocvar_g_vehicle_tankll24_aicannon_coreshotaddeddamage;
float autocvar_g_vehicle_tankll24_aicannon_spread;
float autocvar_g_vehicle_tankll24_aicannon_refire;
float autocvar_g_vehicle_tankll24_aicannon_ammo_cost;
float autocvar_g_vehicle_tankll24_aicannon_fragments;
float autocvar_g_vehicle_tankll24_aicannon_pitchspeed;
float autocvar_g_vehicle_tankll24_aicannon_pitchlimit_down;
float autocvar_g_vehicle_tankll24_aicannon_pitchlimit_up;
float autocvar_g_vehicle_tankll24_aicannon_radius;
float autocvar_g_vehicle_tankll24_aicannon_expdamage;
float autocvar_g_vehicle_tankll24_aicannon_expedgedamage;
float autocvar_g_vehicle_tankll24_aicannon_expforce;
float autocvar_g_vehicle_tankll24_aicannon_ammo_regen_pause;

float autocvar_g_vehicle_tankll24_heatcannon_damage;
float autocvar_g_vehicle_tankll24_heatcannon_bulletconstant;
float autocvar_g_vehicle_tankll24_heatcannon_speed;
float autocvar_g_vehicle_tankll24_heatcannon_headshotaddeddamage;
float autocvar_g_vehicle_tankll24_heatcannon_force;
float autocvar_g_vehicle_tankll24_heatcannon_coreshotaddeddamage;
float autocvar_g_vehicle_tankll24_heatcannon_spread;
float autocvar_g_vehicle_tankll24_heatcannon_refire;
float autocvar_g_vehicle_tankll24_heatcannon_ammo_cost;
float autocvar_g_vehicle_tankll24_heatcannon_fragments;
float autocvar_g_vehicle_tankll24_heatcannon_pitchspeed;
float autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_down;
float autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_up;
float autocvar_g_vehicle_tankll24_heatcannon_radius;
float autocvar_g_vehicle_tankll24_heatcannon_expdamage;
float autocvar_g_vehicle_tankll24_heatcannon_expedgedamage;
float autocvar_g_vehicle_tankll24_heatcannon_expforce;
float autocvar_g_vehicle_tankll24_heatcannon_ammo_regen_pause;
float autocvar_g_vehicle_tankll24_aacannon_damage;
float autocvar_g_vehicle_tankll24_aacannon_bulletconstant;
float autocvar_g_vehicle_tankll24_aacannon_speed;
float autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage;
float autocvar_g_vehicle_tankll24_aacannon_force;
float autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage;
float autocvar_g_vehicle_tankll24_aacannon_spread;
float autocvar_g_vehicle_tankll24_aacannon_refire;
float autocvar_g_vehicle_tankll24_aacannon_ammo_cost;
float autocvar_g_vehicle_tankll24_aacannon_fragments;
float autocvar_g_vehicle_tankll24_aacannon_pitchspeed;
float autocvar_g_vehicle_tankll24_aacannon_pitchlimit_down;
float autocvar_g_vehicle_tankll24_aacannon_pitchlimit_up;
float autocvar_g_vehicle_tankll24_aacannon_ammo_regen_pause;
float autocvar_g_vehicle_tankll24_cannon_refire;
float autocvar_g_vehicle_tankll24_cannon_ammo_cost;
float autocvar_g_vehicle_tankll24_cannon_ammo_max;
float autocvar_g_vehicle_tankll24_cannon_ammo_regen;
float autocvar_g_vehicle_tankll24_cannon_ammo_regen_pause;
float autocvar_g_vehicle_tankll24_cannon_iter;
float autocvar_g_vehicle_tankll24_cannon_iterforward;
float autocvar_g_vehicle_tankll24_cannon_fragments;
float autocvar_g_vehicle_tankll24_cannon_pitchspeed;
float autocvar_g_vehicle_tankll24_cannon_pitchlimit_down;
float autocvar_g_vehicle_tankll24_cannon_pitchlimit_up;

vector autocvar_g_vehicle_tankll24_bouncepain;

void tankll24_exit(float eject);
void tankll24_enter();
void tankll24_spawn(float);

void tankll24_heat_explode (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate*0.5 > random() ))
 	{
		if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
			sprint(self.realowner, "Your HEAT round failed to detonate\n");
		}
	} else {
	
	self.event_damage = func_null;
	
	if (other.classname == "tree") {
		mine_damage_tree(other, self, autocvar_g_vehicle_tankll24_heatcannon_expdamage * 5 * autocvar_g_balance_minelayer_damagerate_tree);
	}

	RadiusDamage (self, self.realowner, autocvar_g_vehicle_tankll24_heatcannon_expdamage,
		autocvar_g_vehicle_tankll24_heatcannon_expedgedamage,
		autocvar_g_vehicle_tankll24_heatcannon_radius, world,
		autocvar_g_vehicle_tankll24_heatcannon_expforce,
		self.projectiledeathtype, other);
		
	OilFire_explosion_spawnoilburnermaybe(self);
	
	modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_tankll24_heatcannon_radius, 0.95, 0.05, 0.25);
	pointparticles(particleeffectnum("explosion_big"), self.origin, '0 0 0', 1);
	
	
	

		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
		//Begin Fragmentation
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_tankll24_heatcannon_fragments;sc = sc + 1) {
	
		 fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		 endFireBallisticBullet();
			
		}
		//End Fragmentation
		}
		
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');

			setorigin(self, (self.origin + v_forward * -8)); //Backwards X qunits so we fire at what we hit
	
			fireBallisticBullet(self.origin, v_forward, autocvar_g_vehicle_tankll24_heatcannon_spread, autocvar_g_vehicle_tankll24_heatcannon_speed, 5, autocvar_g_vehicle_tankll24_heatcannon_damage, autocvar_g_vehicle_tankll24_heatcannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_heatcannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_heatcannon_bulletconstant, autocvar_g_vehicle_tankll24_heatcannon_coreshotaddeddamage);
    			endFireBallisticBullet();
	
	} //End To Dud or not to dud.
	
	remove (self);
}

void tankll24_ai_explode (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate*0.5 > random() ))
 	{
		if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
			sprint(self.realowner, "Your AI round failed to detonate\n");
		}
	} else {
	
	self.event_damage = func_null;
	
	if (other.classname == "tree") {
		mine_damage_tree(other, self, autocvar_g_vehicle_tankll24_aicannon_expdamage * autocvar_g_balance_minelayer_damagerate_tree);
	}

	RadiusDamage (self, self.realowner, autocvar_g_vehicle_tankll24_aicannon_expdamage,
		autocvar_g_vehicle_tankll24_aicannon_expedgedamage,
		autocvar_g_vehicle_tankll24_aicannon_radius, world,
		autocvar_g_vehicle_tankll24_aicannon_expforce,
		self.projectiledeathtype, other);
		
	OilFire_explosion_spawnoilburnermaybe(self);
	
	//modeleffect_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_vehicle_tankll24_aicannon_radius, 0.95, 0.05, 0.25);
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);
	
	
	

		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
		//Begin Fragmentation
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_tankll24_aicannon_fragments;sc = sc + 1) {
	
		 fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		 endFireBallisticBullet();
			
		}
		//End Fragmentation
		}
		
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');

			setorigin(self, (self.origin + v_forward * -8)); //Backwards X qunits so we fire at what we hit
	
			fireBallisticBullet(self.origin, v_forward, autocvar_g_vehicle_tankll24_aicannon_spread, autocvar_g_vehicle_tankll24_aicannon_speed, 5, autocvar_g_vehicle_tankll24_aicannon_damage, autocvar_g_vehicle_tankll24_aicannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aicannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aicannon_bulletconstant, autocvar_g_vehicle_tankll24_aicannon_coreshotaddeddamage);
    			endFireBallisticBullet();
	
	} //End To Dud or not to dud.
	
	remove (self);
}

void tankll24_hagar_explode (void)
{
	if(autocvar_g_balance_hagar_primary_failurerate &&
 	(autocvar_g_balance_hagar_primary_failurerate*0.5 > random() ))
 	{
		//if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
		//	sprint(self.realowner, "A grenade of yours was a dud\n");
		//}
		//Spams client too much (many duds with this gun by default)
	} else {
	
	self.event_damage = func_null;
	
	if (other.classname == "tree") {
		mine_damage_tree(other, self, autocvar_g_balance_hagar_primary_damage * autocvar_g_balance_minelayer_damagerate_tree);
	}
	
	RadiusDamage (self, self.realowner, autocvar_g_balance_hagar_primary_damage, autocvar_g_balance_hagar_primary_edgedamage, autocvar_g_balance_hagar_primary_radius, world, autocvar_g_balance_hagar_primary_force, self.projectiledeathtype, other);
	
	OilFire_explosion_spawnoilburnermaybe(self);
	
		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
		//Begin Fragmentation
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_tankll24_aacannon_fragments;sc = sc + 1) {
	
		 fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BULLETSHRAPNEL,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		 endFireBallisticBullet();
			
		}
		//End Fragmentation
		}
	
	} //End To Dud or not to dud.
	
	remove (self);
}

void tankll24_AAGrenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	spamsound (self, CH_SHOTS, "weapons/hagexp1.wav", VOL_BASE, ATTN_NORM);
	self.use ();
}

void tankll24_fire_aacannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun2, gettagindex(self.gun2, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/hagar_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_HAGAR;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll24_hagar_explode;
	gren.touch = tankll24_AAGrenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankll24_aacannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_HAGAR, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void tankll24_fire_heatcannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun2, gettagindex(self.gun2, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll24_heat_explode;
	gren.touch = tankll24_AAGrenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankll24_heatcannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void tankll24_fire_aicannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun2, gettagindex(self.gun2, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll24_ai_explode;
	gren.touch = tankll24_AAGrenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankll24_aicannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void tankll24_Grenade_Explode2 (void)
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	
	float	xc;
	for (xc = 0;xc < autocvar_g_vehicle_tankll24_cannon_iter;xc = xc + 1) {
	
		RadiusDamage (self, self.realowner, autocvar_g_balance_electro_combo_damage,
		autocvar_g_balance_electro_combo_edgedamage,
		autocvar_g_balance_electro_combo_radius, world,
		autocvar_g_balance_electro_combo_force,
		self.projectiledeathtype, other);
		
		//OilFire_explosion_spawnoilburnermaybe(self);
		////This is an energy weap, not explosive or fire, chem flash more appropriate:
		Chemical_flash_maybe(self);
		
		pointparticles(particleeffectnum("newelectro_combo"), self.origin + '0 0 32', '0 0 0', 1);
		//pointparticles(particleeffectnum("PROJECTILE_BUMBLE_GUN"), self.origin + '0 0 32', '0 0 0', 1);
		if not (pointcontents(self.origin) == CONTENT_SOLID)
		if not (pointcontents(self.origin) == CONTENT_SKY)
		{
		//Start Grenade Fragmentation
		float	sc;
		for (sc = 0;sc < autocvar_g_vehicle_tankll24_cannon_fragments;sc = sc + 1) {
	

		 float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife;
		 mydmg = autocvar_g_balance_nex_primary_damage;
		 myforce = autocvar_g_balance_nex_primary_force;
		 mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		 mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		 myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		 myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		
		 FireRailgunBullet (self.origin, self.origin + randomvec() * MAX_SHOT_DISTANCE,
		 mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);

		//vector u;
		//u = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
		//WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
		//WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
		//WriteCoord(MSG_BROADCAST, self.origin_x);
		//WriteCoord(MSG_BROADCAST, self.origin_y);
		//WriteCoord(MSG_BROADCAST, self.origin_z);
		//WriteCoord(MSG_BROADCAST, u_x);
		//WriteCoord(MSG_BROADCAST, u_y);
		//WriteCoord(MSG_BROADCAST, u_z);
		//WriteByte(MSG_BROADCAST, bound(0, 255, 255));
			
		}
		//Finish Grenade Fragmentation
		}
		
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:24 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');

			setorigin(self, (self.origin + v_forward * autocvar_g_vehicle_tankll24_cannon_iterforward)); //Forward X qunits
	}

	remove (self);
}

void tankll24_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	spamsound (self, CH_SHOTS, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);
	self.use ();
}

void tankll24_fire_cannon(string tagname)
{
    vector v;

    v = gettaginfo(self.gun2, gettagindex(self.gun2, tagname));

	entity gren;

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/electro_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);


	gren = spawn ();
	
	//Got to be for newtonian physics to work
	gren.owner = self;
	gren.realowner = self.owner;
	
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_ELECTRO;
	setorigin(gren, v);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = tankll24_Grenade_Explode2;
	gren.touch = tankll24_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_vehicle_tankll24_cannon);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	CSQCProjectile(gren, TRUE, PROJECTILE_ELECTRO_BEAM, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float tankll24_aiframe()
{
    return FALSE;
}


void tankll24_grail(entity gun, entity pilot, entity gunmount)
{
   
    if(pilot.BUTTON_ATCK2)
    {
    	mg_grail_fire(gun, pilot, gunmount);
    } else {
	vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_grail_railgun_ammo_max,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_grail_railgun_ammo_regen, frametime, FALSE, vehicle_zero, vehicle_zero);
    }
}

void tankll24_t17mm_fire(entity gun, entity pilot, entity gunmount)
{
    if(pilot.BUTTON_ATCK2)
    {
	mg_t17mm_fire(gun, pilot, gunmount);
	gun.count = 0; //Will have to press R to resume reload
    } else {
    	if (gun.count == 1) {
        vehicles_regen(gun.cnt, vehicle_ammo1, autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max,
                                           autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen_pause,
                                           autocvar_g_vehicle_mg_t17mm_machinegun_ammo_regen, frametime, FALSE, vehicle_ammo1_max, vehicle_ammo1_current);
	} else if ((pilot.impulse == 20) && !(pilot.BUTTON_HOOK)) {
			gun.count = 1;
			sound (gun, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
	}
	
	if (pilot.impulse == 20)
	if (pilot.BUTTON_HOOK) {
		//Reload from own stores //75 ammo, 3 pilot ammo = 1 vehic ammo,
		vehicles_replenishAmmo(pilot, gun, ammo_nails, vehicle_ammo1_current, vehicle_ammo1_max, 75, 3);	
	}
	
	//Overheating and cooldown stuff://
	if (gun.gun1.cnt < autocvar_g_vehicle_mg_t17mm_machinegun_heatmin) {
		gun.gun1.cnt = autocvar_g_vehicle_mg_t17mm_machinegun_heatmin;
	} else {
		gun.gun1.cnt = gun.gun1.cnt - (autocvar_g_vehicle_mg_t17mm_machinegun_cooldownrate * sys_frametime);
	}
    }
}

void tankll24_mg_m134(entity mg_m134, entity player, entity gunmount, entity mggun1) 
{
        mg_m134.cnt = time;
        if(mg_m134.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_raacannon_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    mg_m134.count = 0; //Will have to press R to resume reload
	    
            vector v;
            mg_m134.misc_bulletcounter += 1;

            self = player;

            v = gettaginfo(gunmount, gettagindex(gunmount, "tag_mgun"));
            v_forward = normalize(v_forward);
         //   v += v_forward * 50;
  	 // Start Ballistic bullet
	 
   	  fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_raacannon_spread, autocvar_g_vehicle_tankll24_raacannon_speed, 5, autocvar_g_vehicle_tankll24_raacannon_damage, autocvar_g_vehicle_tankll24_raacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_raacannon_force, DEATH_SBMINIGUN, PROJECTILE_BULLETRIFLE30MM, 1, autocvar_g_vehicle_tankll24_raacannon_bulletconstant, autocvar_g_vehicle_tankll24_raacannon_coreshotaddeddamage);
    	 endFireBallisticBullet();
	 // End Ballistic bullet

	 
	 v = gettaginfo(gunmount, gettagindex(gunmount, "tag_flash"));
         v_forward = normalize(v_forward);
	 v += v_forward * 5;
	 
	 pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
	 
   	 UziFlash();
    	 mg_maxim_AttachToShotorg(self.muzzle_flash, '5 0 0', "tag_flash", gunmount);
	 
	 sound (gunmount, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);

	    
  		if (autocvar_g_casings >= 2) {
			mg_maxim_SpawnCasing (((random () * 50 + 50) * v_right) - 
			(v_forward * (random () * 25 + 25)) - 
			((random () * 5 - 70) * v_up), 2, 
			vectoangles(v_forward),'0 250 0', 100, 31, gunmount, "tag_casings");
			//30mm
		}

            self = mg_m134;

            mg_m134.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_raacannon_ammo_cost;
            
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire
	                
	    player.vehicle_ammo2 = (mg_m134.vehicle_ammo2 / autocvar_g_vehicle_tankll24_raacannon_ammo_max) * 100;
	    
	    
            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
	//Smooth animations. Also gun can spin via elec power even if no ammo
	} else if(mg_m134.vehicle_ammo2 < autocvar_g_vehicle_tankll24_raacannon_ammo_cost && gunmount.attack_finished_single <= time)
        {
	    gunmount.attack_finished_single = time + mggun1.count; //Next refire

            mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.attack_finished_single <= time)
	{
	    mggun1.attack_finished_single = time + (mggun1.count*0.3333333); // 1/3 time
	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        } else if(mggun1.cnt <= time)
	{
	    mggun1.cnt = time + (mggun1.count*0.6666666); // 2/3 time

	    mggun1.angles_y += 20;
            if(mggun1.angles_y >= 360)
            {
                mggun1.angles_y = 0;
            }
        }
}

float tankll24_frame()
{
    vector ad, vf;
    entity player, tankll24;
    float ftmp;

	if(intermission_running)
		return 1;
		
    player = self;
    tankll24 = self.vehicle;
    self   = tankll24;

    vehicles_painframe();
    
    player.BUTTON_ZOOM      = 0;
    //player.BUTTON_CROUCH    = 0;
    player.switchweapon     = 0;

    ad = gettaginfo(tankll24.gun3, gettagindex(tankll24.gun3, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    
    vf = ad;
    ad = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    if (tankll24.spawnflags & 512) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 1 0', 1);
    } else if (tankll24.spawnflags & 256) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.65 0', 1);
    } else if (tankll24.spawnflags & 128) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.35 0', 1);
    } else if (tankll24.spawnflags & 64) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0.5 0', 1);
    } else {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0 0.5 1', 1);
    }
    //ad = 0.5 * (ad + vf);
    ad = vf;
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll24.angles), AnglesTransform_FromAngles(ad))) - tankll24.gun3.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    
    //Make sure angles are fine
    //if(tankll24.tur_head.angles_y > 180)  tankll24.tur_head.angles_y -= 360; if(tankll24.tur_head.angles_y < -180) tankll24.tur_head.angles_y += 360;
    
 
    //Rotate Turret and stabilizing "gun3" (rotates faster than turret)
    ftmp = autocvar_g_vehicle_tankll24_turret_turnspeed * sys_frametime;    
    ad_y = bound(-ftmp, ad_y, ftmp);
    if (player.isvehiclepilotplaceholder) {
    	//Do Nothing, no turret rotation
    } else {
    	tankll24.gun3.angles_y = bound(autocvar_g_vehicle_tankll24_turret_turnlimit * -1, tankll24.gun3.angles_y + ad_y, autocvar_g_vehicle_tankll24_turret_turnlimit);
    	tankll24.tur_head.angles_y = tankll24.gun3.angles_y;
    }
    
    /////////////////////////
    //Stuff for actual mgun
    ad = gettaginfo(tankll24.gun1, gettagindex(tankll24.gun1, "tag_mgun"));
    traceline(ad, ad + v_forward * MAX_SHOT_DISTANCE, MOVE_WORLDONLY, tankll24);
    if (self.spawnflags & 16384) {
    	UpdateAuxiliaryXhair(player, trace_endpos, '0 0 0', 0);
    } else {
    	UpdateAuxiliaryXhair(player, trace_endpos, '1 0 1', 0);
    }
    
    crosshair_trace2(player);
    ad = vectoangles(normalize(trace_endpos - ad));
    ad = AnglesTransform_ToAngles(AnglesTransform_LeftDivide(AnglesTransform_FromAngles(tankll24.angles), AnglesTransform_FromAngles(ad))) - tankll24.gun1.angles;
    ad = AnglesTransform_Normalize(ad, TRUE);
    
    //ftmp = autocvar_g_vehicle_tankll24_gun_turnspeed * sys_frametime;    
    //ad_y = bound(-ftmp, ad_y, ftmp);
    //tankll24.gun1.angles_y = bound(autocvar_g_vehicle_tankll24_gun_turnlimit * -1, tankll24.gun1.angles_y + ad_y, autocvar_g_vehicle_tankll24_gun_turnlimit);

    vf = ad;
    // Pitch head
    if (tankll24.spawnflags & 512) {
    	ftmp = autocvar_g_vehicle_tankll24_raacannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 256) {
    	ftmp = autocvar_g_vehicle_tankll24_aicannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 128) {
    	ftmp = autocvar_g_vehicle_tankll24_heatcannon_pitchspeed * sys_frametime;
    } else if (tankll24.spawnflags & 64) {
    	ftmp = autocvar_g_vehicle_tankll24_aacannon_pitchspeed * sys_frametime;  
    } else {
    	ftmp = autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime; 
    }  
    ad_x = bound(ftmp * -1, ad_x, ftmp);
    if (tankll24.spawnflags & 512) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_raacannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_raacannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 256) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_aicannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_aicannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 128) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_heatcannon_pitchlimit_up);
    } else if (tankll24.spawnflags & 64) {
    	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_aacannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_aacannon_pitchlimit_up);
    } else {
        tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down, tankll24.gun2.angles_x + ad_x, autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    }
    ad = vf;
    
    //Mgun
    tankll24.gun1.angles_x = tankll24.gun2.angles_x;

    //fixedmakevectors(tankll24.angles);
    makevectors(tankll24.angles + '-2 0 0' * tankll24.angles_x);
    
    movelib_groundalign4point(autocvar_g_vehicle_tankll24_springlength, autocvar_g_vehicle_tankll24_springup, autocvar_g_vehicle_tankll24_springblend, autocvar_g_vehicle_tankll24_tiltlimit);

    if(tankll24.flags & FL_ONGROUND)
    {
          makevectors(player.v_angle);

	if(vlen(player.movement) == 0)
        {
                if(self.sound_nexttime < time || self.delay != 3)
                {                        
                    self.delay = 3;
                    self.sound_nexttime = time + 6; //soundlength("machines/generator_loop_pitchdown.ogg");
                    //dprint("tankll24_idle:", ftos(soundlength("machines/generator_loop_pitchdown.ogg")), "\n");
                    sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                }                
                movelib_beak_simple(autocvar_g_vehicle_tankll24_speed_stop);
                //tankll24.frame = 5;
		
		self.bomb1.gun1.avelocity_y = self.bomb1.gun2.avelocity_y = self.bomb2.gun1.avelocity_y = self.bomb2.gun2.avelocity_y = 0;
        }
	
    	if(player.movement_y != 0)
   	 {
	 	if(tankll24.angles_y > 180)  tankll24.angles_y -= 360;
    		if(tankll24.angles_y < -180) tankll24.angles_y += 360;
		tankll24.angles_y = bound(-184,tankll24.angles_y + ((player.movement_y * 1.2* sys_frametime) / -6.66666),184);	
		
		if(tankll24.angles_y >= -1 && tankll24.angles_y <= -1)
            		tankll24.angles_y = 0;	
		
		//Unlike the T27 tank, we do it alittle more complex way so the turret can 
		//be independent somewhat
		float degree_y;
		player.angles_y = player.angles_y + ((player.movement_y * 1.2* sys_frametime) / -6.66666);
		degree_y = ((player.movement_y * 1.2* sys_frametime) / -6.66666);
		player.v_angle_y += degree_y;
		
		////player.v_angle_y = tankll24.angles_y; //kiss //T27

		if ((clienttype(player) == CLIENTTYPE_REAL)) {
			msg_entity = player;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, player.v_angle_x);
			WriteAngle( MSG_ONE, player.v_angle_y);
  			WriteAngle( MSG_ONE, player.v_angle_z);
		}
		
		////////player.angles_y = player.angles_y + (player.movement_y / -200);
		////////player.fixangle = TRUE;
		
		//////msg_entity = player;
  		//////WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  		//////WriteAngle( MSG_ONE, tankll24.angles_x); 
  		//////WriteAngle( MSG_ONE, tankll24.angles_y);
  		//////WriteAngle( MSG_ONE, tankll24.angles_z);
		if (player.movement_y > 0) {
			self.bomb1.gun1.avelocity_y = 75; //gear
                	self.bomb1.gun2.avelocity_y = 90; //wheel
                	self.bomb2.gun1.avelocity_y = -75; //gear
                	self.bomb2.gun2.avelocity_y = -90; //wheel
		} else {
			self.bomb1.gun1.avelocity_y = -75; //gear
                	self.bomb1.gun2.avelocity_y = -90; //wheel
                	self.bomb2.gun1.avelocity_y = 75; //gear
                	self.bomb2.gun2.avelocity_y = 90; //wheel
		}
	 }
	 
	 if(player.movement_x != 0)
         {
                    if(player.movement_x > 0)
                    {
                        player.movement_x = 1;
                        tankll24.frame = 0;
                    }
                    else if(player.movement_x < 0)
                    {
                        player.movement_x = -1;
                        tankll24.frame = 1;
                    }
		    
		    self.bomb1.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb1.gun2.avelocity_y = 90 * player.movement_x; //wheel
                    self.bomb2.gun1.avelocity_y = 75 * player.movement_x; //gear
                    self.bomb2.gun2.avelocity_y = 90 * player.movement_x; //wheel
		    
                    player.movement_y = 0;
		    
		    //fixedmakevectors(tankll24.angles);
    			makevectors(tankll24.angles + '-2 0 0' * tankll24.angles_x);
    
                    movelib_move_simple(normalize(v_forward * player.movement_x),vehicles_tank_waterspeed_simple(player, autocvar_g_vehicle_tankll24_speed_walk),autocvar_g_vehicle_tankll24_movement_inertia);

                    if(self.sound_nexttime < time || self.delay != 1)
                    {                        
                        self.delay = 1;
                        self.sound_nexttime = time + 4; //soundlength("machines/generator_loop_speedup_pitchdown.ogg");
                        sound (self, CH_TRIGGER_SINGLE, "machines/generator_loop_speedup_pitchdown.ogg", VOL_VEHICLEENGINE, ATTN_NORM);
                        //dprint("tankll24_walk:", ftos(soundlength("machines/generator_loop_speedup_pitchdown.ogg")), "\n");
                    }
		  
	 } else {
	 	//If we are not moving forward or backwards we should stop
		//Otherwise we "drift" while turn buttons are pressed, like on ice
	 	movelib_beak_simple(autocvar_g_vehicle_tankll24_speed_stop);
	 }
    }
    
    self.angles_x = bound(-autocvar_g_vehicle_tankll24_tiltlimit, self.angles_x, autocvar_g_vehicle_tankll24_tiltlimit);
    self.angles_z = bound(-autocvar_g_vehicle_tankll24_tiltlimit, self.angles_z, autocvar_g_vehicle_tankll24_tiltlimit);

    //if(player.BUTTON_JUMP) {
    //	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down, tankll24.gun2.angles_x + (autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    //}
    
    //if(player.BUTTON_CROUCH ) {
    //	tankll24.gun2.angles_x = bound(autocvar_g_vehicle_tankll24_cannon_pitchlimit_down, tankll24.gun2.angles_x - (autocvar_g_vehicle_tankll24_cannon_pitchspeed * sys_frametime),autocvar_g_vehicle_tankll24_cannon_pitchlimit_up);
    //}
    
    if (tankll24.spawnflags & 512) {
    if(player.BUTTON_HOOK) {
    	if(player.BUTTON_JUMP) {
    		tankll24.gun2.gun1.count = bound(autocvar_g_vehicle_tankll24_raacannon_refire_max, tankll24.gun2.gun1.count - (autocvar_g_vehicle_tankll24_raacannon_refire_changerate * sys_frametime),autocvar_g_vehicle_tankll24_raacannon_refire_min);
		if(tankll24.gun2.gun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(player, sprintf("RoF Raised to %f RPM\n", (60/tankll24.gun2.gun1.count)));
			tankll24.gun2.gun1.pushltime = time + 0.25;
		}
	    }
    
    	if(player.BUTTON_CROUCH ) {
    		tankll24.gun2.gun1.count = bound(autocvar_g_vehicle_tankll24_raacannon_refire_max, tankll24.gun2.gun1.count + (autocvar_g_vehicle_tankll24_raacannon_refire_changerate * sys_frametime),autocvar_g_vehicle_tankll24_raacannon_refire_min);
		if(tankll24.gun2.gun1.pushltime < time)  // Don't flood the connection with the messages
		{
			sprint(player, sprintf("RoF Lowered to %f RPM\n", (60/tankll24.gun2.gun1.count)));
			tankll24.gun2.gun1.pushltime = time + 0.25;
		}

    	}
    }
    //print(ftos(tankll24.gun2.gun1.count),"\n");
    }
    
    player.BUTTON_CROUCH    = 0;

    if (self.spawnflags & 16384) {
    	tankll24_t17mm_fire(tankll24, player, tankll24.gun1);
    } else {
    	tankll24_grail(tankll24, player, tankll24.gun1);
    }    

    if(player.BUTTON_ATCK)
    {
    	if (tankll24.spawnflags & 512) {
		tankll24_mg_m134(tankll24, player, tankll24.gun2, tankll24.gun2.gun1);
        } else if (tankll24.spawnflags & 256) {
		//Anti Infantry Cannon
		tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_aicannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;

	            	self = tankll24;
	    
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aicannon("tag_cannon1");
	 	   
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 12, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_aicannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_aicannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         	tankll24.count = 0; //Will have to press R to resume reload
        	}
    	} else if (tankll24.spawnflags & 128) {
		//HEAT Cannon
		tankll24.cnt = time;
		if not(tankll24.bomb1.gun1.count)
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_heatcannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;

	            	self = tankll24;
	    
	 		sound (tankll24, CH_WEAPON_A, "weapons/campingrifle_fire_morebass.ogg", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_heatcannon("tag_cannon1");
	 	   
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 13, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_heatcannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_heatcannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         	tankll24.count = 0; //Will have to press R to resume reload
		tankll24.bomb1.gun1.count = 1; //Can't fire untill stop pressing key (semi auto)
        	}
    	} else if (tankll24.spawnflags & 64) {
		//AA Cannon
		tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_aacannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;
		    
		    if(tankll24.gun2.count == 1) {
		    	tankll24.gun2.count = 2;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon2");
	 	   } else if(tankll24.gun2.count == 2) {
	   		tankll24.gun2.count = 3;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon3"));
	           	 v_forward = normalize(v_forward);
	    		
			entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon4"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon4");
		   } else if(tankll24.gun2.count == 3) {
	   		tankll24.gun2.count = 0;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon1");
		   } else {
		   	tankll24.gun2.count = 1;

	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon4"));
	           	 v_forward = normalize(v_forward);
	    
	    		entity _oldself = self;
	    		self = self.owner;
	 	   	fireBallisticBullet(v, v_forward, autocvar_g_vehicle_tankll24_aacannon_spread, autocvar_g_vehicle_tankll24_aacannon_speed, 5, autocvar_g_vehicle_tankll24_aacannon_damage, autocvar_g_vehicle_tankll24_aacannon_headshotaddeddamage, autocvar_g_vehicle_tankll24_aacannon_force, DEATH_SBMINIGUN, 1, 1, autocvar_g_vehicle_tankll24_aacannon_bulletconstant, autocvar_g_vehicle_tankll24_aacannon_coreshotaddeddamage);
    	 		endFireBallisticBullet();
	 		sound (tankll24, CH_WEAPON_A, "weapons/uzi_fire_slow_bass.wav", VOL_BASE, ATTN_NORM);
			pointparticles(particleeffectnum("spiderbot_minigun_muzzleflash"), v, v_forward, 1);
			self = _oldself;
			
			makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon3"));
	           	 v_forward = normalize(v_forward);
			 
			tankll24_fire_aacannon("tag_cannon3");
		   }
		   
		   	self = player;
			makevectors(self.angles);
			
		   	if (autocvar_g_casings >= 2) {
				SpawnCasing (((random () * 50 + 50) * v_right) - 
				(v_forward * (random () * 25 + 25)) - 
				((random () * 5 - 70) * v_up), 2, 
				vectoangles(v_forward),'0 250 0', 100, 111, self);
			}
			
			self = tankll24;
			
            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_aacannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_aacannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
		tankll24.count = 0; //Will have to press R to resume reload 
        	}
	} else {
		//Regular
        	tankll24.cnt = time;
       		if(tankll24.vehicle_ammo2 >= autocvar_g_vehicle_tankll24_cannon_ammo_cost && tankll24.tur_head.attack_finished_single <= time)
        	{
        	    vector v;
        	    tankll24.misc_bulletcounter += 1;
	
	            self = player;
		    
		    if(tankll24.gun2.count == 1) {
	            	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
		    	tankll24.gun2.count = 0;
			v_forward = normalize(v_forward);
	            	v += v_forward * 12;

	            	pointparticles(particleeffectnum("bigplasma_muzzleflash"), v, v_forward, 1);


	            	self = tankll24;
	    
		    	makevectors(self.angles);
		    	v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon1"));
	           	 v_forward = normalize(v_forward);
	    
	 	   	tankll24_fire_cannon("tag_cannon1");
	 	   } else {
	   		v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
	    		tankll24.gun2.count = 1;
			v_forward = normalize(v_forward);
            		v += v_forward * 12;

            		pointparticles(particleeffectnum("bigplasma_muzzleflash"), v, v_forward, 1);


            		self = tankll24;
	    
	    		makevectors(self.angles);
	    		v = gettaginfo(tankll24.gun2, gettagindex(tankll24.gun2, "tag_cannon2"));
            		v_forward = normalize(v_forward);
	    
	    		tankll24_fire_cannon("tag_cannon2");
	   	  }

            	tankll24.vehicle_ammo2 -= autocvar_g_vehicle_tankll24_cannon_ammo_cost;
            	tankll24.tur_head.attack_finished_single = time + autocvar_g_vehicle_tankll24_cannon_refire;
            	player.vehicle_ammo2 = (tankll24.vehicle_ammo2 / autocvar_g_vehicle_tankll24_cannon_ammo_max) * 100;
         
        	}
	}
    }
    else
    {
    	tankll24.bomb1.gun1.count = 0; //For semi-auto cannons, you stopped pressing attack2 button, so reset this
	
    	float regenll24;
    	if (tankll24.spawnflags & 256) {
		regenll24 = autocvar_g_vehicle_tankll24_aicannon_ammo_regen_pause;
	} else if (tankll24.spawnflags & 128) {
		regenll24 = autocvar_g_vehicle_tankll24_heatcannon_ammo_regen_pause;
	} else if (tankll24.spawnflags & 64) {
		regenll24 = autocvar_g_vehicle_tankll24_aacannon_ammo_regen_pause;
	} else {
		regenll24 = autocvar_g_vehicle_tankll24_cannon_ammo_regen_pause;
	}
	
	if (tankll24.spawnflags & 512 || tankll24.spawnflags & 256 || tankll24.spawnflags & 128 || tankll24.spawnflags & 64) {
		if (tankll24.count == 1) {
        	vehicles_regen(tankll24.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll24_cannon_ammo_max,
                	                           regenll24,
                	                           autocvar_g_vehicle_tankll24_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);
    		} else if ((player.impulse == 20) && !(player.BUTTON_HOOK)) {
				tankll24.count = 1;
				sound (tankll24, CH_WEAPON_A, "weapons/reload.wav", VOL_BASE, ATTN_NORM);
		}
		
		if (player.impulse == 20)
		if (player.BUTTON_HOOK) {
    			//Reload from own stores //4 ammo, 4 player ammo = 50 vehic ammo, 4/0.08 = 50 (the normal one shot ammo cost for this weapon)
			//For the RAA gun (512) it's 125 ammo at 5 player ammo per one vehic ammo = 25 vehic ammo
			if (tankll24.spawnflags & 512)
				vehicles_replenishAmmo(player, tankll24, ammo_nails, vehicle_ammo2_current, vehicle_ammo2_max, 125, 5);
			else
				vehicles_replenishAmmo(player, tankll24, ammo_rockets, vehicle_ammo2_current, vehicle_ammo2_max, 4, 0.08);
    		} 
	} else {
	vehicles_regen(tankll24.cnt, vehicle_ammo2, autocvar_g_vehicle_tankll24_cannon_ammo_max,
                                           regenll24,
                                           autocvar_g_vehicle_tankll24_cannon_ammo_regen, frametime, FALSE, vehicle_ammo2_max, vehicle_ammo2_current);	
	}
    }  
    
    //tankll24_rocket_do();

    if(self.vehicle_flags  & VHF_SHIELDREGEN)
        vehicles_regen(tankll24.dmg_time, vehicle_shield, autocvar_g_vehicle_tankll24_shield, autocvar_g_vehicle_tankll24_shield_regen_pause, autocvar_g_vehicle_tankll24_shield_regen, frametime, TRUE, vehicle_zero, vehicle_zero);

    if(self.vehicle_flags  & VHF_HEALTHREGEN)
        vehicles_regen(tankll24.dmg_time, vehicle_health, autocvar_g_vehicle_tankll24_health, autocvar_g_vehicle_tankll24_health_regen_pause, autocvar_g_vehicle_tankll24_health_regen, frametime, FALSE, vehicle_zero, vehicle_zero);

    player.BUTTON_ATCK = player.BUTTON_ATCK2 = 0;
    //player.vehicle_ammo2 = tankll24.tur_head.frame;

    if(tankll24.gun2.cnt <= time)
        player.vehicle_reload2 = 100;
    else
        player.vehicle_reload2 = 100 - ((tankll24.gun2.cnt - time) / tankll24.attack_finished_single) * 100;

    setorigin(player, tankll24.origin + '0 0 1' * TANKLL24_MAX_z);
    tankll24.velocity = vehicles_tank_waterfriction(player, tankll24.velocity);
    player.velocity = tankll24.velocity;

    VEHICLE_UPDATE_PLAYER(player, health, tankll24);

    if(self.vehicle_flags & VHF_HASSHIELD)
        VEHICLE_UPDATE_PLAYER(player, shield, tankll24);


    //Gun3 is out invisible angle stabilizer/reducer
    //tur_head gets its value from it above, so we act on it here
    //print(sprintf("m1 = %f\n", tankll24.gun3.angles_y));
    if(tankll24.gun3.angles_y > 180) {
    	//print("here 1\n");
    	tankll24.gun3.angles_y = tankll24.gun3.angles_y - 360;
	//print(sprintf("m2 = %f\n", tankll24.gun3.angles_y));
    } else if(tankll24.gun3.angles_y < -180) {
    	//print("here 2\n");
    	tankll24.gun3.angles_y = tankll24.gun3.angles_y + 360;
	//print(sprintf("m2 = %f\n", tankll24.gun3.angles_y));
    }

    player.vehicle_ammo1_current = tankll24.vehicle_ammo1_current;
    player.vehicle_ammo1_max = tankll24.vehicle_ammo1_max;
    player.vehicle_ammo2_current = tankll24.vehicle_ammo2_current;
    player.vehicle_ammo2_max = tankll24.vehicle_ammo2_max;

    self = player;
    return 1;    
}
void tankll24_think()
{
    if(self.flags & FL_ONGROUND)
        movelib_beak_simple(autocvar_g_vehicle_tankll24_speed_stop);

    self.nextthink = time;
}

void tankll24_enter()
{
    self.vehicle_weapon2mode = SBRM_GUIDE;
    self.movetype   = MOVETYPE_WALK;
    CSQCVehicleSetup(self.owner, 0);
    self.owner.vehicle_health = (self.vehicle_health / autocvar_g_vehicle_tankll24_health) * 100;
    self.owner.vehicle_shield = (self.vehicle_shield / autocvar_g_vehicle_tankll24_shield) * 100;

    if(self.owner.flagcarried)
    {
        setattachment(self.owner.flagcarried, self.tur_head, ""); 
        setorigin(self.owner.flagcarried, '-20 0 120'); 
    }
}

void tankll24_exit(float eject)
{
    vector spot;
    

    //self.velocity   = '0 0 0';
    self.think      = tankll24_think;
    self.nextthink  = time;
    self.frame      = 5;
    self.movetype   = MOVETYPE_WALK;
    
    if not (self.owner)
        return;

	makevectors(self.angles);
	if(eject)
	{
	    spot = self.origin + v_forward * 100 + '0 0 64';
	    spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
	    setorigin(self.owner , spot);
	    self.owner.velocity = (v_up + v_forward * 0.25) * 750;
	    self.owner.oldvelocity = self.owner.velocity;
	}
	else
	{
		if(vlen(self.velocity) > autocvar_g_vehicle_tankll24_speed_strafe)
		{
			self.owner.velocity = normalize(self.velocity) * vlen(self.velocity);
			self.owner.velocity_z += 200;
			spot = self.origin + v_forward * 128 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
		else
		{
			self.owner.velocity = self.velocity * 0.5;
			self.owner.velocity_z += 10;
			spot = self.origin + v_forward * 256 + '0 0 64';
			spot = vehicles_findgoodexit(spot, MOVE_WORLDONLY);
		}
	    self.owner.oldvelocity = self.owner.velocity;
	    setorigin(self.owner , spot);
	}
	
	antilag_clear(self.owner);
    self.owner = world;
}

void tankll24_impact()
{
    if(autocvar_g_vehicle_tankll24_bouncepain_x)
        vehilces_impact(autocvar_g_vehicle_tankll24_bouncepain_x, autocvar_g_vehicle_tankll24_bouncepain_y, autocvar_g_vehicle_tankll24_bouncepain_z);    
}

void tankll24_headfade()
{
	self.think = tankll24_headfade;
	self.nextthink = self.fade_time;
	self.alpha = 1 - (time - self.fade_time) * self.fade_rate;

    if(self.cnt < time || self.alpha < 0.1)
    {
        if(self.alpha > 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_big"), self.origin + '0 0 100', '0 0 0', 1);
        }
        remove(self);
    }
}

void tankll24_blowup()
{
    if(self.cnt > time)
    {
        if(random() < 0.1)
        {
            sound (self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
            pointparticles(particleeffectnum("explosion_small"), randomvec() * 80 + (self.origin + '0 0 100'), '0 0 0', 1);
        }
        self.nextthink = time + 0.1;
        return;
    }
    
    entity h, g1, g2, b;
    b = spawn();
    h = spawn();
    g1 = spawn();
    g2 = spawn();

    b.lodmodel1 = "models/vehicles/tankll24_lod1.iqm";
    b.lodmodel2 = "models/vehicles/tankll24_lod2.iqm";
    setmodel(b,  "models/vehicles/tankll24.iqm");
    InitializeEntity(b, LODmodel_attach, INITPRIO_FINDTARGET);
    if (self.spawnflags & 512) {
    	g1.scale = 4;
    	setmodel(g1, "models/mountedguns/m134gun_barrels.iqm");
	setmodel(h,  "models/vehicles/tankll24_aaturret.iqm");
	self.gun2.gun1.alpha = -1;
    } else if (self.spawnflags & 256) {
    	setmodel(g1, "models/vehicles/tankll24_aicannon.iqm");
	setmodel(h,  "models/vehicles/tankll24_aaturret.iqm");
    } else if (self.spawnflags & 128) {
    	setmodel(g1, "models/vehicles/tankll24_heatcannon.iqm");
	setmodel(h,  "models/vehicles/tankll24_aaturret.iqm");
    } else if (self.spawnflags & 64) {
    	setmodel(g1, "models/vehicles/tankll24_aacannon.iqm");
	setmodel(h,  "models/vehicles/tankll24_aaturret.iqm");
    } else {
    	setmodel(g1, "models/vehicles/tankll24_cannon.iqm");
	setmodel(h,  "models/vehicles/tankll24_turret.iqm");

    }
    setmodel(g2, "models/vehicles/tankt27_gear.iqm");

    setorigin(b, self.origin);
    b.frame         = 11;
    b.angles        = self.angles;
    setsize(b, self.mins, self.maxs);

    setorigin(h, gettaginfo(self, gettagindex(self, "tag_head")));
    h.movetype      = MOVETYPE_BOUNCE;
    h.solid         = SOLID_BBOX;
    h.velocity      = v_up * (500 + random() * 500) + randomvec() * 128;
    h.modelflags    = MF_ROCKET;
    h.effects       = EF_FLAME | EF_LOWPRECISION;
    h.avelocity     = randomvec() * 360;

    h.alpha         = 1;
    h.cnt           = time + (3.5 * random());
    h.fade_rate     = 1 / min(autocvar_g_vehicle_tankll24_respawntime, 10);
    h.fade_time     = time;
    h.think         = tankll24_headfade;
    h.nextthink     = time;

    setorigin(g1, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint01")));
    g1.movetype     = MOVETYPE_TOSS;
    g1.solid        = SOLID_CORPSE;
    g1.velocity     = v_forward * 700 + (randomvec() * 32);
    g1.avelocity    = randomvec() * 180;

    setorigin(g2, gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_hardpoint02")));
    g2.movetype     = MOVETYPE_TOSS;
    g2.solid        = SOLID_CORPSE;
    g2.velocity     = v_forward * 700 + (randomvec() * 32);
    g2.avelocity    = randomvec() * 180;

    h.colormod = b.colormod = g1.colormod = g2.colormod = '-2 -2 -2';

    SUB_SetFade(b,  time + 5, min(autocvar_g_vehicle_tankll24_respawntime, 1));
    //SUB_SetFade(h,  time, min(autocvar_g_vehicle_tankll24_respawntime, 10));
    SUB_SetFade(g1, time, min(autocvar_g_vehicle_tankll24_respawntime, 10));
    SUB_SetFade(g2, time, min(autocvar_g_vehicle_tankll24_respawntime, 10));

    RadiusDamage (self, self.enemy, 250, 15, 250, world, 250, DEATH_SBBLOWUP, world);

    self.alpha = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = -1;
    self.movetype   = MOVETYPE_NONE;
    self.deadflag   = DEAD_DEAD;
    self.solid      = SOLID_NOT;
    self.tur_head.effects  &~=  EF_FLAME;
	self.vehicle_hudmodel.viewmodelforclient = self;
}

void tankll24_die()
{
    self.health             = 0;
    self.event_damage       = func_null;
    self.takedamage         = DAMAGE_NO;
    self.touch              = func_null;
    self.cnt                = 3.4 + time + random() * 2;
    self.think              = tankll24_blowup;
    self.nextthink          = time;
    self.deadflag           = DEAD_DYING;
	self.frame              = 5;
	self.tur_head.effects  |= EF_FLAME;
	self.colormod           = self.tur_head.colormod = '-1 -1 -1';
	self.frame              = 10;
	self.movetype           = MOVETYPE_TOSS;
    tankt27_hitbox_die(self.hitboxft);
    tankt27_hitbox_die(self.hitboxbk);
}

void tankll24_spawn(float _f)
{
    self.buff_wont_ignite = 1;
    self.vehicle_tankresists = 1;
    
    if(!self.gun1)
    {
    	self.lodmodel1 = "models/vehicles/tankll24_lod1.iqm";
	self.lodmodel2 = "models/vehicles/tankll24_lod2.iqm";
	InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);

    	entity spinner;
	self.bomb1 = spawn();
        self.bomb2 = spawn();
	
	//Turret Rotation stabilizer
	self.gun3 = spawn(); //Will be an angle stabilizer for the rotating turret
	self.gun3.alpha = -1;
	setmodel(self.gun3, "models/vehicles/anglestabilizer.iqm");
	setattachment(self.gun3, self.tur_head, "tag_cannon_pivot");
	
	
        self.gun1               = spawn();
        self.gun2               = spawn();
	if (self.spawnflags & 16384) {
	 	setmodel(self.gun1, "models/mountedguns/t17mmgun.iqm");
		//LOD stuff.
		self.gun1.owner = self;
		self.gun1.lodowner = 1; //Use owner origin for computing LOD
		self.gun1.lodmodel1 = "models/mountedguns/t17mmgun_lod1.iqm";
		self.gun1.lodmodel2 = "models/mountedguns/t17mmgun_lod2.iqm";
		self.gun1.lodmodel3 = "models/mountedguns/t17mmgun_lod3.iqm";
		InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
		if (self.spawnflags & 64) {
			//AA tank, mount set high
			setorigin(self.gun1, '8 -8 4');
		} else {
			//Low mount
			setorigin(self.gun1, '16 -18 -18');
		}
	} else {
        	setmodel(self.gun1, "models/mountedguns/grailgun.iqm");
		//LOD stuff.
		self.gun1.owner = self;
		self.gun1.lodowner = 1; //Use owner origin for computing LOD
		self.gun1.lodmodel1 = "models/mountedguns/grailgun_lod1.iqm";
		InitializeEntity(self.gun1, LODmodel_attach, INITPRIO_FINDTARGET);
		//LOD stuff end
		setattachment(self.gun1, self.tur_head, "tag_gunpivot2");
	}
		
	if (self.spawnflags & 512) {
		self.gun2.scale = 4;
		self.gun2.owner = self;
		self.gun2.lodmodel1 = "models/vehicles/m134simple_lod1.iqm";
        	setmodel(self.gun2, "models/vehicles/m134simple.iqm");
		InitializeEntity(self.gun2, LODmodel_attach, INITPRIO_FINDTARGET);
		
		self.gun2.gun1 = spawn();
		////Do not need to scale, takes on scale of parent //self.gun2.gun1.scale = 4;//
		setmodel(self.gun2.gun1,"models/mountedguns/m134gun_barrels.iqm");
		setattachment(self.gun2.gun1, self.gun2, "tag_axis");
		
		self.gun2.gun1.count = autocvar_g_vehicle_tankll24_raacannon_refire_max;
	} else if (self.spawnflags & 256) {
        	setmodel(self.gun2, "models/vehicles/tankll24_aicannon.iqm");
	} else if (self.spawnflags & 128) {
        	setmodel(self.gun2, "models/vehicles/tankll24_heatcannon.iqm");
	} else if (self.spawnflags & 64) {
        	setmodel(self.gun2, "models/vehicles/tankll24_aacannon.iqm");
	} else {
		setmodel(self.gun2, "models/vehicles/tankll24_cannon.iqm");
	}
	setattachment(self.gun2, self.tur_head, "tag_cannon_pivot");
        self.gravity            = 2;
        self.mass               = 5000;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_left");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb1.gun2 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_gear.iqm");
        setattachment(spinner, self, "tag_gear_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun1 = spinner;
	
	spinner = spawn();
        spinner.owner = self;
        setmodel(spinner,"models/vehicles/tankt27_wheel.iqm");
        setattachment(spinner, self, "tag_wheel_right");
        spinner.movetype = MOVETYPE_NOCLIP;
        spinner.avelocity = '0 90 0';
        self.bomb2.gun2 = spinner;
	
	// Sigh.
        self.bomb1.think = raptor_rotor_anglefix;
        self.bomb1.nextthink = time;
	
	setattachment(self.vehicle_hudmodel, self, "");
        //setattachment(self.vehicle_viewport, self.gun1, "tag_gcamera");
	if (self.spawnflags & 128 || self.spawnflags & 256 || self.spawnflags & 512) {
		setattachment(self.vehicle_viewport, self.tur_head, "tag_camera");
	} else {
		setattachment(self.vehicle_viewport, self.gun2, "tag_camera");
	}
	
	self.gun1.colormap = self.colormap;
	self.hitboxft = spawn();
    	self.hitboxbk = spawn();
    }
    
    self.vehicle_ammo1_current = self.vehicle_ammo1_max;
    self.vehicle_ammo2_current = self.vehicle_ammo2_max;    
    self.frame              = 5;
    self.tur_head.frame     = 1;
    self.think              = tankll24_think;
    self.touch              = tankt27_vehicles_touch2;
    self.subordinate        = self.hitboxft; //For testing max_z in determining if should crush a player or monster
    self.subordinatespeed   = autocvar_g_vehicle_tankll24_speed_walk;
    self.subordinateinertia = autocvar_g_vehicle_tankll24_movement_inertia;
    self.nextthink          = time;
    self.vehicle_health     = autocvar_g_vehicle_tankll24_health;
    self.vehicle_shield     = autocvar_g_vehicle_tankll24_shield;
    self.movetype           = MOVETYPE_WALK;
    self.solid              = SOLID_SLIDEBOX;
    if (self.spawnflags & 512) {
	self.gun2.gun1.alpha = 1;
    }
    self.alpha              = self.tur_head.alpha = self.gun1.alpha = self.gun2.alpha = self.bomb1.gun1.alpha = self.bomb1.gun2.alpha = self.bomb2.gun1.alpha = self.bomb2.gun2.alpha = 1;
    self.gun2.colormap = self.bomb1.gun1.colormap = self.bomb1.gun2.colormap = self.bomb2.gun1.colormap = self.bomb2.gun2.colormap = self.colormap;
    self.tur_head.angles    = '0 0 0';
    
    self.bomb1.gun1.avelocity_y = 0;
    self.bomb1.gun2.avelocity_y = 0;
    self.bomb2.gun1.avelocity_y = 0;
    self.bomb2.gun2.avelocity_y = 0;

    setorigin(self, self.pos1 + '0 0 128');
    self.angles = self.pos2;
    self.vehicle_impact = tankll24_impact;
    self.damageforcescale = 0.03;
    self.ballistics_density = autocvar_g_ballistics_density_metal;
    
    tankt27_spawn_hitbox(0, self, self.hitboxft, TANKLL24_MIN_HBF, TANKLL24_MAX_HBF, 124, autocvar_g_vehicle_tankll24_health);
    tankt27_spawn_hitbox(1, self, self.hitboxbk, TANKLL24_MIN_HBB, TANKLL24_MAX_HBB, -120, autocvar_g_vehicle_tankll24_health * 0.5);
}

void spawnfunc_vehicle_tankll24()
{
    if(!autocvar_g_vehicle_tankll24)
    {
        remove(self);
        return;
    }    
    
    if (autocvar_g_delete_vehicles >= 1) {
		if (time < game_starttime + autocvar_g_delete_vehicles_time)
		{
			remove(self);
			return;
		}
    }    

    self.vehicle_flags |= VHF_DMGSHAKE;
    //self.vehicle_flags |= VHF_DMGROLL;
    //self.vehicle_flags |= VHF_DMGHEADROLL;
    
    precache_model ( "models/vhshield.md3");
    precache_model ( "models/vehicles/tankll24.iqm");
    precache_model ( "models/vehicles/tankll24_lod1.iqm");
    precache_model ( "models/vehicles/tankll24_lod2.iqm");
    
    precache_model ( "models/vehicles/tankt27_wheel.iqm");
    precache_model ( "models/vehicles/tankt27_gear.iqm");
    
    precache_model ( "models/vehicles/anglestabilizer.iqm");
    precache_model ( "models/uziflash.md3");
    
    //Anti-infantry gun (seconday weapon)
    float gnammomax;
    if (self.spawnflags & 16384) { 
    	precache_model ( "models/mountedguns/t17mmgun.iqm");
    	precache_model ( "models/mountedguns/t17mmgun_lod1.iqm");
	precache_model ( "models/mountedguns/t17mmgun_lod2.iqm");
	precache_model ( "models/mountedguns/t17mmgun_lod3.iqm");
	gnammomax = autocvar_g_vehicle_mg_t17mm_machinegun_ammo_max * 7;
    } else {
    	precache_model ( "models/mountedguns/grailgun.iqm");
    	precache_model ( "models/mountedguns/grailgun_lod1.iqm");
	gnammomax = 0;
    }
    
    //Main Turret
    float caammomax;
    string turretmodel;
    if (self.spawnflags & 512) {
	precache_model ( "models/mountedguns/m134gun_barrels.iqm");
	precache_model ( "models/vehicles/m134simple.iqm");
	precache_model ( "models/vehicles/m134simple_lod1.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	turretmodel = "models/vehicles/tankll24_aaturret.iqm";
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_raacannon_ammo_max * 3;
    } else if (self.spawnflags & 256) {
	precache_model ( "models/vehicles/tankll24_aicannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	//precache_model ( "models/sphere/sphexp.md3");
	turretmodel = "models/vehicles/tankll24_aaturret.iqm";
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 12;
    } else if (self.spawnflags & 128) {
	precache_model ( "models/vehicles/tankll24_heatcannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	precache_model ( "models/sphere/sphexp.md3");
	turretmodel = "models/vehicles/tankll24_aaturret.iqm";
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/campingrifle_fire_morebass.ogg" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 3;
    } else if (self.spawnflags & 64) {
	precache_model ( "models/vehicles/tankll24_aacannon.iqm");
	precache_model ( "models/vehicles/tankll24_aaturret.iqm");
	turretmodel = "models/vehicles/tankll24_aaturret.iqm";
	precache_sound ( "weapons/hagexp1.wav" );
	precache_sound ( "weapons/uzi_fire_slow_bass.wav" );
	caammomax = autocvar_g_vehicle_tankll24_cannon_ammo_max * 3;
    } else {
	precache_model ( "models/vehicles/tankll24_cannon.iqm");
	precache_model ( "models/vehicles/tankll24_turret.iqm");
	turretmodel = "models/vehicles/tankll24_turret.iqm";
	caammomax = 0;
    }
    
    precache_sound ( "weapons/electro_impact_combo.wav" );
    precache_sound ( "weapons/electro_fire.wav" );
    precache_sound ( "weapons/crylink_fire.wav" );
    precache_sound ( "weapons/nexfire.wav" );
    precache_sound ( "weapons/rocket_impact.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    
    precache_sound ( "vehicles/tankll24_die.wav");
    precache_sound ( "machines/generator_loop_pitchdown.ogg");
    precache_sound ( "vehicles/tankll24_jump.wav");
    precache_sound ( "vehicles/tankll24_strafe.wav");
    precache_sound ( "machines/generator_loop_speedup_pitchdown.ogg");
    precache_sound ( "vehicles/tankll24_land.wav");
    precache_sound ( "object/impact_metal_3.ogg");
    precache_sound ( "object/impact_metal_4.ogg");

    if(autocvar_g_vehicle_tankll24_shield)
        self.vehicle_flags |= VHF_HASSHIELD;

    if(autocvar_g_vehicle_tankll24_shield_regen)
        self.vehicle_flags |= VHF_SHIELDREGEN;

    if(autocvar_g_vehicle_tankll24_health_regen)
        self.vehicle_flags |= VHF_HEALTHREGEN;
        
	float autocolor;
	autocolor = -1;
	if (self.colormap >= 1023)
		autocolor = self.colormap;
	
    if not (vehicle_initialize(
             "LL24",
             "models/vehicles/tankll24.iqm",
             turretmodel,
             "null",
             "tag_turret", "tag_camera", "",
             HUD_TANK,
             TANKLL24_MIN, TANKLL24_MAX,
             FALSE,
             tankll24_spawn, autocvar_g_vehicle_tankll24_respawntime,
             tankll24_frame,
             tankll24_enter, tankll24_exit,
             tankll24_die,   tankll24_think,
             FALSE, 
             autocvar_g_vehicle_tankll24_health,
             autocvar_g_vehicle_tankll24_shield, autocolor, gnammomax, caammomax))
	     	//1023 == Hack for no colormap
		//Not likely to be any 1023rd colormap
		//So it's the regular color of the base texture.
    {
        remove(self);
        return;
    }
}

void spawnfunc_vehicle_tankll24_aa()
{
	if not(self.spawnflags & 64) {
		self.spawnflags |= 64; //So we spawn AA
	}
		
	spawnfunc_vehicle_tankll24();
}

void spawnfunc_vehicle_tankll24_heat()
{
	if not(self.spawnflags & 128) {
		self.spawnflags |= 128; //So we spawn HEAT
	}
		
	spawnfunc_vehicle_tankll24();
}

void spawnfunc_vehicle_tankll24_ai()
{
	if not(self.spawnflags & 256) {
		self.spawnflags |= 256; //So we spawn AntiInfantry
	}
		
	spawnfunc_vehicle_tankll24();
}

void spawnfunc_vehicle_tankll24_raa()
{
	if not(self.spawnflags & 512) {
		self.spawnflags |= 512; //So we spawn RAA
	}
		
	spawnfunc_vehicle_tankll24();
}
#endif // SVQC
