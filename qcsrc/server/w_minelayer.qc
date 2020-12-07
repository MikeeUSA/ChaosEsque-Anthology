#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MINE_LAYER, w_minelayer, IT_ROCKETS, 4, WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_HIGH, "minelayer", "minelayer", _("Mine Layer"))
#else
#ifdef SVQC
void W_Mine_Think (void);
.float minelayer_detonate, mine_explodeanyway;
.float mine_time;

.float minelayer_usingaltammo;
.float minelayer_landminesmulti;

.float multitool_ammocurrent;
void Foliage_Fall();

void spawnfunc_weapon_minelayer (void)
{
	weapon_defaultspawnfunc(WEP_MINE_LAYER);
}

void W_Mine_Stick (entity to)
{
	spamsound (self, CH_SHOTS, "weapons/mine_stick.wav", VOL_BASE, ATTN_NORM);

	// in order for mines to face properly when sticking to the ground, they must be a server side entity rather than a csqc projectile

	entity newmine;
	newmine = spawn();
	newmine.classname = self.classname;

	newmine.bot_dodge = self.bot_dodge;
	newmine.bot_dodgerating = self.bot_dodgerating;

	newmine.owner = self.owner;
	newmine.realowner = self.realowner;
	setsize(newmine, '-4 -4 -4', '4 4 4');
	setorigin(newmine, self.origin);
	setmodel(newmine, "models/mine.md3");
	newmine.angles = vectoangles(-trace_plane_normal); // face against the surface


	float hitmaterial;
	if (other.classname == "tree")
		hitmaterial = 8;
	else
		hitmaterial = W_EvaluateMaterialHit();
		
	if (hitmaterial == 7) {
		//print("Dirt Etc\n");
		newmine.canbeburied = 1;
	}
	
	newmine.oldvelocity = self.velocity;

	newmine.takedamage = self.takedamage;
	newmine.damageforcescale = self.damageforcescale;
	newmine.health = self.health;
	newmine.event_damage = self.event_damage;
	newmine.spawnshieldtime = self.spawnshieldtime;
	newmine.damagedbycontents = TRUE;

	newmine.movetype = MOVETYPE_NONE; // lock the mine in place
	newmine.projectiledeathtype = self.projectiledeathtype;

	newmine.mine_time = self.mine_time;

	newmine.touch = func_null;
	newmine.think = W_Mine_Think;
	newmine.nextthink = time;
	newmine.cnt = self.cnt;
	newmine.flags = self.flags;

	remove(self);
	self = newmine;

	if(to)
		SetMovetypeFollow(self, to);
}

void mine_damage_tree(entity target_victim, entity mymine, float swing_damage)
{		
		target_victim.vehicle_health = target_victim.vehicle_health - swing_damage;
		if (target_victim.vehicle_health < 0) {
			if (mymine.realowner)
			if (mymine.realowner != world)
			if(!mymine.realowner.frozen)
			if(!mymine.realowner.freezetag_frozen)
			if(!mymine.realowner.stoned)
			if(mymine.realowner.prisonerlevel != 3)
			if(mymine.realowner.prisonerlevel != 2)
			if(mymine.realowner.deadflag == DEAD_NO)
			if(mymine.realowner.health > 0)
				mymine.realowner.multitool_ammocurrent = mymine.realowner.multitool_ammocurrent + (target_victim.multitool_ammocurrent * 0.25); //Less profit than from swinging
			
			target_victim.multitool_ammocurrent = 0;
					
			target_victim.health = target_victim.maxs_z + 16;
			
			target_victim.think = Foliage_Fall;
			target_victim.nextthink = time;
		} else {
			if (random() > 0.5) {
				spamsound (target_victim, CH_PAIN, "object/impact_wood_5.ogg", VOL_BASE * 0.4, ATTN_NORM);
			} else {
				spamsound (target_victim, CH_PAIN, "object/impact_wood_4.ogg", VOL_BASE * 0.4, ATTN_NORM);
			}
		}
				
		//print(strcat(self.realowner.netname, " classname ", target_victim.classname, " with ", ftos(target_victim.vehicle_health), " health ... ammo ", ftos(target_victim.multitool_ammocurrent), "\n"));
}

void W_Mine_Damage_Tree (entity mymine)
{
	entity eburn;
	eburn = findradius(mymine.origin, autocvar_g_balance_minelayer_radius);
	while(eburn)
	{
		if (eburn.classname == "tree" || eburn.classname == "bush") {
			mine_damage_tree(eburn, mymine, autocvar_g_balance_minelayer_damage * autocvar_g_balance_minelayer_damagerate_tree);
		}
		
		eburn = eburn.chain;
	}
}

void W_Mine_Explode ()
{
	if(autocvar_g_balance_minelayer_primary_failurerate &&
 	(autocvar_g_balance_minelayer_primary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "A mine of yours failed to detonate\n");
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

	W_Mine_Damage_Tree(self);
	RadiusDamage (self, self.realowner, autocvar_g_balance_minelayer_damage, autocvar_g_balance_minelayer_edgedamage, autocvar_g_balance_minelayer_radius, world, autocvar_g_balance_minelayer_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	} //End To Dud or not to dud.

	if (self.realowner.weapon == WEP_MINE_LAYER)
	{
		entity oldself;
		oldself = self;
		self = self.realowner;
		if (!weapon_action(WEP_MINE_LAYER, WR_CHECKAMMO1))
		{
			self.cnt = WEP_MINE_LAYER;
			ATTACK_FINISHED(self) = time;
			self.switchweapon = w_getbestweapon(self);
		}
		self = oldself;
	}
	self.realowner.minelayer_mines -= 1;
	remove (self);
}

void W_Mine_DoRemoteExplode ()
{
	if(autocvar_g_balance_minelayer_secondary_failurerate &&
 	(autocvar_g_balance_minelayer_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "A mine of yours failed to explode\n");
		}
	} else {
	
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE || self.movetype == MOVETYPE_FOLLOW)
		self.velocity = self.oldvelocity;

	W_Mine_Damage_Tree(self);
	RadiusDamage (self, self.realowner, autocvar_g_balance_minelayer_remote_damage, autocvar_g_balance_minelayer_remote_edgedamage, autocvar_g_balance_minelayer_remote_radius, world, autocvar_g_balance_minelayer_remote_force, self.projectiledeathtype | HITTYPE_BOUNCE, world);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	} //End To Dud or not to dud.

	if (self.realowner.weapon == WEP_MINE_LAYER)
	{
		entity oldself;
		oldself = self;
		self = self.realowner;
		if (!weapon_action(WEP_MINE_LAYER, WR_CHECKAMMO1))
		{
			self.cnt = WEP_MINE_LAYER;
			ATTACK_FINISHED(self) = time;
			self.switchweapon = w_getbestweapon(self);
		}
		self = oldself;
	}
	self.realowner.minelayer_mines -= 1;
	remove (self);
}

void W_Mine_RemoteExplode ()
{
	if(self.realowner.deadflag == DEAD_NO)
		if((self.spawnshieldtime >= 0)
			? (time >= self.spawnshieldtime) // timer
			: (vlen(NearestPointOnBox(self.realowner, self.origin) - self.origin) > autocvar_g_balance_minelayer_remote_radius) // safety device
		)
		{
			W_Mine_DoRemoteExplode();
		}
}

void W_Mine_ProximityExplode ()
{
	// make sure no friend is in the mine's radius. If there is any, explosion is delayed until he's at a safe distance
	if(autocvar_g_balance_minelayer_protection && self.mine_explodeanyway == 0)
	{
		entity head;
		head = findradius(self.origin, autocvar_g_balance_minelayer_radius);
		while(head)
		{
			if(head == self.realowner || !IsDifferentTeam(head, self.realowner) || (autocvar_g_allow_friends && autocvar_g_balance_minelayer_protection_forfriends && quickIsFriendOf(self.realowner, head)))
				return;
			head = head.chain;
		}
	}

	self.mine_time = 0;
	W_Mine_Explode();
}

float W_Mine_Count(entity e)
{
	float minecount = 0;
	entity mine;
	for(mine = world; (mine = find(mine, classname, "mine")); ) if(mine.realowner == e)
		minecount += 1;
		
	return minecount;
}

void mine_removeself();
void W_Mine_Think (void)
{
	entity head;

	self.nextthink = time;

	if(self.movetype == MOVETYPE_FOLLOW)
	{
		if(LostMovetypeFollow(self))
		{
			UnsetMovetypeFollow(self);
			self.movetype = MOVETYPE_NONE;
			mine_removeself();
			self.realowner.minelayer_mines -= 1;
			return;
		}
	}
	
	// our lifetime has expired, it's time to die - mine_time just allows us to play a sound for this
	// TODO: replace this mine_trigger.wav sound with a real countdown
	if ((time > self.cnt) && (!self.mine_time))
	{
		if(autocvar_g_balance_minelayer_lifetime_countdown > 0)
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
		self.mine_time = time + autocvar_g_balance_minelayer_lifetime_countdown;
		self.mine_explodeanyway = 1; // make the mine super aggressive -- Samual: Rather, make it not care if a team mate is near.
	}

	// a player's mines shall explode if he disconnects or dies
	// TODO: Do this on team change too -- Samual: But isn't a player killed when they switch teams?
	if((self.realowner.classname != "player" || self.realowner.deadflag != DEAD_NO)
		&& autocvar_g_balance_minelayer_persistent != 1)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Mine_Explode();
		return;
	}

	// set the mine for detonation when a foe gets close enough
	head = findradius(self.origin, autocvar_g_balance_minelayer_proximityradius);
	while(head)
	{
		if((head.classname == "player" || head.flags & FL_MONSTER) && head.deadflag == DEAD_NO)
		if(!head.stoned)     //Not for players afflicted with stonecurse
		if(head.frozen != 1) //Not for players frozen in ice. //1 == Ice, 2 == paralysis
		if(head != self.realowner && IsDifferentTeam(head, self.realowner)) // don't trigger for team mates
		if(!(autocvar_g_allow_friends && autocvar_g_balance_minelayer_ignorefriends && quickIsFriendOf(self.realowner, head)))
		if(!self.mine_time)
		{
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
			self.mine_time = time + autocvar_g_balance_minelayer_time;
		}
		head = head.chain;
	}

	// explode if it's time to
	if(self.mine_time && time >= self.mine_time)
	{
		W_Mine_ProximityExplode();
		return;
	}

	// remote detonation
	if (self.realowner.weapon == WEP_MINE_LAYER)
	if (self.realowner.deadflag == DEAD_NO)
	if (self.minelayer_detonate)
		W_Mine_RemoteExplode();
}

void W_Mine_Touch (void)
{
	if(self.movetype == MOVETYPE_NONE || self.movetype == MOVETYPE_FOLLOW)
		return; // we're already a stuck mine, why do we get called? TODO does this even happen?

	PROJECTILE_TOUCH;

	if(other && other.classname == "player" && other.deadflag == DEAD_NO && other.frozen != 1 && !other.stoned)
	{
		// hit a player
		// don't stick
	}
	else
	{
		W_Mine_Stick(other);
	}
}

void W_Mine_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	float is_from_enemy = (inflictor.realowner != self.realowner);
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, (is_from_enemy ? 1 : -1)))
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	self.angles = vectoangles(self.velocity);
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_Mine_Explode);
}

void W_Mine_Attack (void)
{
	entity mine;
	entity flash;

	// scan how many mines we placed, and return if we reached our limit
	if(autocvar_g_balance_minelayer_limit)
	{
	
		if(W_Mine_Count(self) >= autocvar_g_balance_minelayer_limit)
		{
			// the refire delay keeps this message from being spammed
			sprint(self, strcat("minelayer: You cannot place more than ^2", ftos(autocvar_g_balance_minelayer_limit), " ^7mines at a time\n") );
			play2(self, "weapons/unavailable.wav");
			return;
		}
	}

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_minelayer_ammo, autocvar_g_balance_minelayer_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-4 -4 -4', '4 4 4', FALSE, 5, "weapons/mine_fire.wav", CH_WEAPON_A, autocvar_g_balance_minelayer_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	mine = WarpZone_RefSys_SpawnSameRefSys(self);
	mine.owner = mine.realowner = self;
	if(autocvar_g_balance_minelayer_detonatedelay >= 0)
		mine.spawnshieldtime = time + autocvar_g_balance_minelayer_detonatedelay;
	else
		mine.spawnshieldtime = -1;
	mine.classname = "mine";
	mine.bot_dodge = TRUE;
	mine.bot_dodgerating = autocvar_g_balance_minelayer_damage * 2; // * 2 because it can detonate inflight which makes it even more dangerous

	mine.takedamage = DAMAGE_YES;
	mine.damageforcescale = autocvar_g_balance_minelayer_damageforcescale;
	mine.health = autocvar_g_balance_minelayer_health;
	mine.event_damage = W_Mine_Damage;
	mine.damagedbycontents = TRUE;

	mine.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(mine);
	mine.projectiledeathtype = WEP_MINE_LAYER;
	setsize (mine, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot

	setorigin (mine, w_shotorg - v_forward * 4); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(mine, autocvar_g_balance_minelayer_speed, 0);
	mine.angles = vectoangles (mine.velocity);

	mine.touch = W_Mine_Touch;
	mine.think = W_Mine_Think;
	mine.nextthink = time;
	mine.cnt = time + (autocvar_g_balance_minelayer_lifetime - autocvar_g_balance_minelayer_lifetime_countdown);
	mine.flags = FL_PROJECTILE;
	mine.missile_flags = MIF_SPLASH | MIF_ARC | MIF_PROXY;

	CSQCProjectile(mine, TRUE, PROJECTILE_MINE, TRUE);

	// muzzle flash for 1st person view
	flash = spawn ();
	setmodel (flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// common properties

	other = mine; MUTATOR_CALLHOOK(EditProjectile);
	
	self.minelayer_mines = W_Mine_Count(self);
}

float W_PlacedMines(float detonate)
{
	entity mine;
	float minfound = 0;

	for(mine = world; (mine = find(mine, classname, "mine")); ) if(mine.realowner == self)
	{
		if(detonate)
		{
			if(!mine.minelayer_detonate)
			{
				mine.minelayer_detonate = TRUE;
				minfound = 1;
			}
		}
		else
			minfound = 1;
	}
	return minfound;
}

float W_MineLayer_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_minelayer_reload_ammo && self.clip_load < autocvar_g_balance_minelayer_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

float w_minelayer(float req)
{
	entity mine;
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_MineLayer_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		// aim and decide to fire if appropriate
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_minelayer_speed, 0, autocvar_g_balance_minelayer_lifetime, FALSE);
		if(skill >= 2) // skill 0 and 1 bots won't detonate mines!
		{
			// decide whether to detonate mines
			entity targetlist, targ;
			float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
			float selfdamage, teamdamage, enemydamage;
			edgedamage = autocvar_g_balance_minelayer_edgedamage;
			coredamage = autocvar_g_balance_minelayer_damage;
			edgeradius = autocvar_g_balance_minelayer_radius;
			recipricoledgeradius = 1 / edgeradius;
			selfdamage = 0;
			teamdamage = 0;
			enemydamage = 0;
			targetlist = findchainfloat(bot_attack, TRUE);
			mine = find(world, classname, "mine");
			while (mine)
			{
				if (mine.realowner != self)
				{
					mine = find(mine, classname, "mine");
					continue;
				}
				targ = targetlist;
				while (targ)
				{
					d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - mine.origin);
					d = bound(0, edgedamage + (coredamage - edgedamage) * sqrt(1 - d * recipricoledgeradius), 10000);
					// count potential damage according to type of target
					if (targ == self)
						selfdamage = selfdamage + d;
					else if (targ.team == self.team && teamplay)
						teamdamage = teamdamage + d;
					else if (bot_shouldattack(targ))
						enemydamage = enemydamage + d;
					targ = targ.chain;
				}
				mine = find(mine, classname, "mine");
			}
			float desirabledamage;
			desirabledamage = enemydamage;
			if (time > self.invincible_finished && time > self.spawnshieldtime)
				desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
			if (teamplay && self.team)
				desirabledamage = desirabledamage - teamdamage;

			mine = find(world, classname, "mine");
			while (mine)
			{
				if (mine.realowner != self)
				{
					mine = find(mine, classname, "mine");
					continue;
				}
				makevectors(mine.v_angle);
				targ = targetlist;
				if (skill > 9) // normal players only do this for the target they are tracking
				{
					targ = targetlist;
					while (targ)
					{
						if (
							(v_forward * normalize(mine.origin - targ.origin)< 0.1)
							&& desirabledamage > 0.1*coredamage
						)self.BUTTON_ATCK2 = TRUE;
						targ = targ.chain;
					}
				}else{
					float distance; distance= bound(300,vlen(self.origin-self.enemy.origin),30000);
					//As the distance gets larger, a correct detonation gets near imposible
					//Bots are assumed to use the mine spawnfunc_light to see if the mine gets near a player
					if(v_forward * normalize(mine.origin - self.enemy.origin)< 0.1)
						if(self.enemy.classname == "player")
							if(desirabledamage >= 0.1*coredamage)
								if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
									self.BUTTON_ATCK2 = TRUE;
				//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
				}

				mine = find(mine, classname, "mine");
			}
			// if we would be doing at X percent of the core damage, detonate it
			// but don't fire a new shot at the same time!
			if (desirabledamage >= 0.75 * coredamage) //this should do group damage in rare fortunate events
				self.BUTTON_ATCK2 = TRUE;
			if ((skill > 6.5) && (selfdamage > self.health))
				self.BUTTON_ATCK2 = FALSE;
			//if(self.BUTTON_ATCK2 == TRUE)
			//	dprint(ftos(desirabledamage),"\n");
			if (self.BUTTON_ATCK2 == TRUE) self.BUTTON_ATCK = FALSE;
		}
	}
	else if (req == WR_THINK && !W_MineLayer_NeedManualReload())
	{
		if(autocvar_g_balance_minelayer_reload_ammo && self.clip_load < autocvar_g_balance_minelayer_ammo) // forced reload
		{
			// not if we're holding the minelayer without enough ammo, but can detonate existing mines
			if not (W_PlacedMines(FALSE) && self.ammo_rockets < autocvar_g_balance_minelayer_ammo)
				weapon_action(self.weapon, WR_RELOAD);
		}
		else if (self.BUTTON_ATCK)
		{
			if(weapon_prepareattack(0, autocvar_g_balance_minelayer_refire))
			{
				W_Mine_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_minelayer_animtime, w_ready);
			}
		}

		if (self.BUTTON_ATCK2)
		{
			if(W_PlacedMines(TRUE))
				sound (self, CH_WEAPON_B, "weapons/mine_det.wav", VOL_BASE, ATTN_NORM);
		}
		
		if (self.minelayer_usingaltammo) {
			if(self.weaponentity.state == WS_READY) {
				//print("Reload completed, switching back to rockets\n");
				self.current_ammo = ammo_rockets;
				self.minelayer_usingaltammo = 0;
				self.landmines = self.minelayer_landminesmulti/autocvar_g_balance_minelayer_ammo;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/flash.md3");
		precache_model ("models/mine.md3");
		precache_model ("models/weapons/g_minelayer.md3");
		precache_model ("models/weapons/v_minelayer.md3");
		precache_model ("models/weapons/h_minelayer.iqm");
		precache_sound ("weapons/mine_det.wav");
		precache_sound ("weapons/mine_fire.wav");
		precache_sound ("weapons/mine_stick.wav");
		precache_sound ("weapons/mine_trigger.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '25 -0.01 -7';
		weapon_setup(WEP_MINE_LAYER);
		self.current_ammo = ammo_rockets;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.minelayer_landminesmulti = 0;
		self.minelayer_usingaltammo = 0;
	}
	else if (req == WR_PLAYERDEATH)
	{
		self.minelayer_landminesmulti = 0;
		self.minelayer_usingaltammo = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while placing a mine
		if (ATTACK_FINISHED(self) <= time || self.weapon != WEP_MINE_LAYER)
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_minelayer_ammo;
			ammo_amount += self.(weapon_load[WEP_MINE_LAYER]) >= autocvar_g_balance_minelayer_ammo;
			return ammo_amount;
		}
	}
	else if (req == WR_CHECKAMMO2)
	{
		if (W_PlacedMines(FALSE))
			return TRUE;
		else
			return FALSE;
	}
	else if (req == WR_RELOAD)
	{
		if ((self.ammo_rockets < autocvar_g_balance_minelayer_ammo)
		&& (self.landmines >= 1))
		{
			//print("reloading from landmines\n");
			self.minelayer_usingaltammo = 1;
			self.minelayer_landminesmulti = self.landmines * autocvar_g_balance_minelayer_ammo;
			self.landmines = 0; //Will restore when reload completed
			self.current_ammo = minelayer_landminesmulti;
			W_Reload(autocvar_g_balance_minelayer_ammo, autocvar_g_balance_minelayer_reload_ammo, autocvar_g_balance_minelayer_reload_time, "weapons/reload.wav");
		} else {
			W_Reload(autocvar_g_balance_minelayer_ammo, autocvar_g_balance_minelayer_reload_ammo, autocvar_g_balance_minelayer_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_minelayer(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/mine_exp.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/mine_exp.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		if(w_deathtype & HITTYPE_BOUNCE) // (remote detonation)
			w_deathtypestring = _("%s blew themself up with their minelayer");
		else
			w_deathtypestring = _("%s forgot about their mine");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE) // (remote detonation)
			w_deathtypestring = _("%s got too close to %s's mine");
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s almost dodged %s's mine");
		else
			w_deathtypestring = _("%s stepped on %s's mine");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_minelayer (void)
//{
//	weapon_defaultspawnfunc(WEP_MINE_LAYER);
//}
