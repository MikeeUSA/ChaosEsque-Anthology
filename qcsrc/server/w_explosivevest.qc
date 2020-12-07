#ifdef REGISTER_WEAPON
REGISTER_WEAPON(EXPLOSIVE_VEST, w_explosivevest, IT_ROCKETS, 4, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "explosivevest", "explosivevest", _("Explosives"))
#else
#ifdef SVQC
.float exvest_release;

void W_Expvest_FragsOverTime (void)
{
	//print("Here\n");
	//Start Grenade Fragmentation
	float	sc;
	for (sc = 0;sc < self.count;sc = sc + 1) {
		fireBallisticBullet(self.origin, randomvec(), 1,
		 autocvar_g_balance_explosivevest_primary_fragment_speed, 5,
		 autocvar_g_balance_explosivevest_primary_fragment_damage,
		 autocvar_g_balance_explosivevest_primary_fragment_headshotbonus,
		 autocvar_g_balance_explosivevest_primary_fragment_force,
		 DEATH_FRAGMENT,
		 PROJECTILE_BALLBEARING,
		 autocvar_g_balance_explosivevest_primary_fragment_gravity,
		 autocvar_g_balance_explosivevest_primary_fragment_bulletconstant,
		 autocvar_g_balance_explosivevest_primary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();	
	}
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_balance_explosivevest_primary_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}


void W_Expvest_FragsOverTimeSpawn (entity gren)
{
	float frameadjust;
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	e.think = W_Expvest_FragsOverTime;
	
	frameadjust = sys_frametime/0.0222222;
	if (frameadjust > 0.95) {
		//So if we have lower frametime than default or default we keep it the same
		e.count = floor(autocvar_g_balance_explosivevest_primary_fragments / autocvar_g_balance_explosivevest_primary_fragments_frames)+1;
	} else {
		//If we have lower frametime than the standard, spreadout over time more
		e.count = floor(autocvar_g_balance_explosivevest_primary_fragments / (autocvar_g_balance_explosivevest_primary_fragments_frames/frameadjust))+1;
	}
	//print(ftos(sys_frametime),"  :  ",ftos(e.count),"\n");
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void W_Expvest_Explode (void)
{
	if(autocvar_g_balance_explosivevest_primary_failurerate &&
 	(autocvar_g_balance_explosivevest_primary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your explosive failed to detonate\n");
		}
	} else {
	
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
		
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_explosivevest_primary_radius, 0.95, 0.05, 0.25);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_explosivevest_primary_radius, 0.75, 0.07, 0.4);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_explosivevest_primary_radius, 0.4, 0.1, 0.5);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_explosivevest_primary_radius, 0.4, 1, 1.0);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, autocvar_g_balance_explosivevest_primary_radius, 0.3, 2, 2.0);
	
	pointparticles(particleeffectnum("explosion_medium"), self.origin, '0 0 0', 1);

	RadiusDamage (self, self.realowner, autocvar_g_balance_explosivevest_primary_damage, autocvar_g_balance_explosivevest_primary_edgedamage, autocvar_g_balance_explosivevest_primary_radius, world, autocvar_g_balance_explosivevest_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	//Would like to set self to self.realowner because fireBallisticBullet sets
	//the projectile owner and realowner to self,
	//right now self is a grenade.
	//However then the fragments won't damage the owner, so we won't do that
	//Engine will complain about the frags accuracy field for world being accessed in cl_player.qc
	//Cant detect there that it will be world however...
	//Since the entity is some random entity, not 0 (world)
	//The engine figures it out, however, in time
	//
	////entity beforeself;
	////beforeself = self;
	////self = self.realowner;
	//////and fireBallisticBullet(beforeself.origin
	//////and later
	////self = beforeself;
	//
	//So instead we have created a new variable
	//.ignoreaccuracy
	//If set to 1, once attacker.ignoreaccuracy is read in cl_player.qc
	//accuracy will be ignored, engine won't complain
	//Note: Don't unset it once set, if it's unset then
	//by the time it's value in cl_player.qc is looked up....
	//it's really just for nades etc that get removed at the 
	//end of their useful existance.
	
	//Start explosivevest Fragmentation
	if(autocvar_g_balance_explosivevest_primary_fragments_frames < 2)
	{
		float	sc;
		for (sc = 0;sc < autocvar_g_balance_explosivevest_primary_fragments;sc = sc + 1) {
			//print(sprintf("Spawning bullets: %f\n", sc));
	
			fireBallisticBullet(self.origin, randomvec(), 1,
			 autocvar_g_balance_explosivevest_primary_fragment_speed, 5,
			 autocvar_g_balance_explosivevest_primary_fragment_damage,
			 autocvar_g_balance_explosivevest_primary_fragment_headshotbonus,
			 autocvar_g_balance_explosivevest_primary_fragment_force,
			 DEATH_FRAGMENT,
			 PROJECTILE_BALLBEARING,
			 autocvar_g_balance_explosivevest_primary_fragment_gravity,
			 autocvar_g_balance_explosivevest_primary_fragment_bulletconstant,
			 autocvar_g_balance_explosivevest_primary_fragment_coreshotbonus);
			 
			endFireBallisticBullet();
		}
	} else {
		W_Expvest_FragsOverTimeSpawn(self); //Spread out fragment spawning
	}
	//Finish explosivevest Fragmentation
	
	}
	remove (self);
}

void W_Expvest_Touch (void)
{
	PROJECTILE_TOUCH;
	self.use ();
}

void W_Expvest_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, self.use);
}

void W_Expvest_Think (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Expvest_Explode ();
		return;
	}
}

void W_Expvest_Attack (void)
{
	entity exvest;
	
	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_explosivevest_primary_ammo, autocvar_g_balance_explosivevest_reload_ammo);
	
	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/rocket_det.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_primary_damage);
	w_shotdir = v_forward; // no TrueAim for exvestades please

	exvest = spawn ();
	exvest.owner = exvest.realowner = self;
	exvest.classname = "grenade";
	exvest.bot_dodge = TRUE;
	exvest.bot_dodgerating = autocvar_g_balance_explosivevest_primary_damage;
	exvest.movetype = MOVETYPE_BOUNCE;
	exvest.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	exvest.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(exvest);
	exvest.projectiledeathtype = WEP_EXPLOSIVE_VEST;
	setorigin(exvest, w_shotorg);
	setsize(exvest, '-3 -3 -3', '3 3 3');

	exvest.cnt = time + autocvar_g_balance_explosivevest_primary_delay;
	exvest.nextthink = time;
	exvest.think = W_Expvest_Think;
	exvest.use = W_Expvest_Explode;
	exvest.touch = W_Expvest_Touch;

	exvest.takedamage = DAMAGE_YES;
	exvest.health = autocvar_g_balance_grenadelauncher_primary_health;
	exvest.damageforcescale = autocvar_g_balance_explosivevest_primary_damageforcescale;
	exvest.event_damage = W_Expvest_Damage;
	exvest.damagedbycontents = TRUE;
 	
	W_SETUPPROJECTILEVELOCITY_UP(exvest, g_balance_explosivevest_primary);

	exvest.angles = vectoangles (exvest.velocity);
	exvest.flags = FL_PROJECTILE;
	
	exvest.alpha = 0;
	
	CSQCProjectile(exvest, TRUE, PROJECTILE_GRENADE, TRUE);
	
	other = exvest; MUTATOR_CALLHOOK(EditProjectile);
}

float W_explosivevest_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_explosivevest_reload_ammo && self.clip_load < autocvar_g_balance_explosivevest_primary_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_explosivevest (void)
{
	weapon_defaultspawnfunc(WEP_EXPLOSIVE_VEST);
}

.float bot_secondary_explosivevestmooth;
float w_explosivevest(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_explosivevest_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK = FALSE;
		//self.BUTTON_ATCK2 = FALSE;
		
		if(vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_explosivevest_primary_melee_range) {
			self.BUTTON_ATCK2 = bot_aim(1000000, 0, 0.001, FALSE);
		}
	}
	else if (req == WR_THINK && !W_explosivevest_NeedManualReload())
	{
		if(autocvar_g_balance_explosivevest_reload_ammo && self.clip_load < autocvar_g_balance_explosivevest_primary_ammo) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if ((self.BUTTON_ATCK && !self.BUTTON_ATCK2) || (self.exvest_release == 1 && !self.BUTTON_ATCK2))
		{
			if (weapon_prepareattack(0, autocvar_g_balance_explosivevest_primary_refire))
			{
				W_Expvest_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_explosivevest_primary_animtime, w_ready);
				self.exvest_release = 0;
			}
		}
		else if (self.BUTTON_ATCK2 && !self.BUTTON_ATCK && !self.exvest_release)
		{
			self.exvest_release = 1;
			spamsound (self, CH_SHOTS, "weapons/hagar_beep.wav", VOL_BASE * 0.75, ATTN_NORM);
		}		
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_explosivevest.md3");
		precache_model ("models/weapons/v_explosivevest.md3");
		precache_model ("models/weapons/h_explosivevest.iqm");
		precache_model ("models/sphere/sphexp2.iqm");
		precache_model ("models/sphere/sphexp3.iqm");
		precache_sound ("weapons/rocket_det.wav");
		precache_sound ("weapons/hagar_beep.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_EXPLOSIVE_VEST);
		self.current_ammo = ammo_rockets;
		self.exvest_release = 0;
	}
	else if ((req == WR_CHECKAMMO1) || (req == WR_CHECKAMMO2))
	{
		ammo_amount = self.ammo_rockets >= autocvar_g_balance_explosivevest_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_EXPLOSIVE_VEST]) >= autocvar_g_balance_explosivevest_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_PLAYERDEATH)
	{
		if (self.exvest_release == 1)
		{
				W_Expvest_Attack();
		}
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_explosivevest_primary_ammo, autocvar_g_balance_explosivevest_reload_ammo, autocvar_g_balance_explosivevest_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_explosivevest(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("shotgun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent && time - self.prevric > 0.25)
		{
			if(w_random < 0.0165)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.033)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
			self.prevric = time;
		}
		//if(!w_issilent)
		//	sound(self, CH_SHOTS, "weapons/rocket_det.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/rocket_det.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see their own explosive");
		else
			w_deathtypestring = _("%s blew themself up with their explosive");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see %s's explosive's dead-man switch");
		else
			w_deathtypestring = _("%s died in %s's explosion");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_explosivevest (void)
//{
//	weapon_defaultspawnfunc(WEP_EXPLOSIVE_VEST);
//}
