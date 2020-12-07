////////////////////////////
//AT Mine stuff
void atmine_Think (void);

void atmine_destroy_gamemodel_tree(entity eburn)
{
	if (eburn.nopounddown)
	{
		//Do Nothing
	} else {
		if (
		( strstrofs(eburn.model, "tree", 0) != -1 )
		|| ( strstrofs(eburn.model, "lightpost", 0) != -1 )
		|| ( strstrofs(eburn.model, "peach", 0) != -1 )
		|| ( strstrofs(eburn.model, "statue", 0) != -1 )
		) {
			eburn.health = eburn.maxs_z + 16;
			eburn.think = Foliage_Fall;
			eburn.nextthink = time;
		}
	}	
}

void atmine_Damage_Tree (entity mymine)
{
	entity eburn;
	eburn = findradius(mymine.origin, autocvar_g_balance_minelayer_atmine_radius);
	while(eburn)
	{
		if (eburn.classname == "tree" || eburn.classname == "bush") {
			mine_damage_tree(eburn, mymine, autocvar_g_balance_minelayer_atmine_damage * autocvar_g_balance_minelayer_atmine_damagerate_tree);
		}
		
		eburn = eburn.chain;
	}
	
	eburn = findradius(mymine.origin, autocvar_g_balance_minelayer_atmine_radius*0.5);
	while(eburn)
	{
		if (eburn.classname == "misc_gamemodel") {
 			atmine_destroy_gamemodel_tree(eburn);	
		}
		
		eburn = eburn.chain;
	}
}

void atmine_Stick (entity to)
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
	setorigin(newmine, self.origin);
	
	if(teamplay) newmine.team = newmine.realowner.team; //For more checks
	
	float hitmaterial;
	if (other.classname == "tree")
		hitmaterial = 8;
	else
		hitmaterial = W_EvaluateMaterialHit();
	
	newmine.angles = vectoangles(-trace_plane_normal);
	newmine.angles_x = newmine.angles_x + 90;
	
	//print (vtos(newmine.angles), "angles\n");
	float mineangledtofloor;
	if (newmine.angles_x > 300) {
		mineangledtofloor = 1;
	} else {
		mineangledtofloor = 0;
	}
	
	setmodel(newmine, "models/atmine.iqm");
	if (hitmaterial == 7) {
		//print("Dirt Etc\n");
		newmine.canbeburied = 1; //You can bury this with 'cmd bury' (see cheats.qc, though its a cmd not a cheat)
		
		//Random depth into the dirt for visuals
		local vector mnvec;
		mnvec_x = -4;
		mnvec_y = -4;
		mnvec_z = 2 + (random()*1.5);
		
		setsize(newmine, mnvec, '4 4 6');
		
		entity previousself;
		previousself = self;
		self = newmine;
		droptofloor();
		self = previousself;
	} else if (mineangledtofloor) {
		if ((hitmaterial == 1) || (hitmaterial == 2)) {
			//print("Metal\n");
			setsize(newmine, '-4 -4 0', '4 4 4');
		} else if (hitmaterial == 5) {
			//print("Concrete\n");
			setsize(newmine, '-4 -4 0', '4 4 4');
		} else if ((hitmaterial == 3) || (hitmaterial == 4)) {
			//print("Stone and Brick\n");
			setsize(newmine, '-4 -4 2', '4 4 6');
		} else if (hitmaterial == 8) {
			//print("Wood and Bark\n");
			setsize(newmine, '-4 -4 1', '4 4 5');
		} else if (hitmaterial == 9) {
			//print("Sheetrock\n");
			setsize(newmine, '-4 -4 1', '4 4 5');
		} else {
			//print("NotMetal\n");
			setsize(newmine, '-4 -4 0', '4 4 4');
		}
		entity previousself;
		previousself = self;
		self = newmine;
		droptofloor();
		self = previousself;
	} else {
		setsize(newmine, '-4 -4 -4', '4 4 4');
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
	newmine.think = atmine_Think;
	newmine.nextthink = time;
	newmine.cnt = self.cnt;
	newmine.flags = self.flags;

	remove(self);
	self = newmine;

	if(to)
		SetMovetypeFollow(self, to);
}

void atmine_Explode2 ()
{
	if(autocvar_g_balance_minelayer_primary_failurerate &&
 	(autocvar_g_balance_minelayer_primary_failurerate > random() ))
 	{
		if ((clienttype(self.realowner) == CLIENTTYPE_REAL)) {
			sprint(self.realowner, "A mine of yours failed to detonate\n");
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

	atmine_Damage_Tree(self);
	
	local float myradius, mydamage, myedgedamage, myforce;
	mydamage = autocvar_g_balance_minelayer_atmine_damage;
	myedgedamage = autocvar_g_balance_minelayer_atmine_edgedamage;
	myradius = autocvar_g_balance_minelayer_atmine_radius;
	myforce = autocvar_g_balance_minelayer_atmine_force;
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, myradius, 0.95, 0.05, 0.25);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, myradius, 0.75, 0.07, 0.4);
	
	modeleffect_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, myradius, 0.4, 0.1, 0.5);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, myradius, 0.4, 1, 1.0);
	
	modeleffect_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, myradius, 0.3, 2, 2.0);
	
	pointparticles(particleeffectnum("explosion_big"), self.origin, '0 0 0', 1);
	RadiusDamage (self, self.realowner, mydamage, myedgedamage, myradius, world, myforce, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);
	
	} //End To Dud or not to dud.
	remove (self);
}

void mine_removeselfthink()
{
	//print("removing myself\n");
	remove (self);
}

void mine_removeself()
{
	self.think = mine_removeselfthink;
	self.nextthink = time + 0.01;	
}

void atmine_Explode()
{
	self.alpha = 1;
	setsize (self, '-4 -4 -4', '4 4 4');
	setmodel(self, "models/atmine.iqm");
	self.think = atmine_Explode2;
	self.nextthink = time + 0.01;
}

void atmine_ProximityExplode ()
{
	// make sure no friend is in the mine's radius. If there is any, explosion is delayed until he's at a safe distance
	if(autocvar_g_balance_minelayer_protection && self.mine_explodeanyway == 0)
	{
		entity head;
		head = findradius(self.origin, autocvar_g_balance_minelayer_radius);
		while(head)
		{
			if(head == self.realowner || !IsDifferentTeam(head, self))
				return;
			head = head.chain;
		}
	}

	self.mine_time = 0;
	atmine_Explode();
}

void atmine_Think (void)
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
	head = findradius(self.origin, autocvar_g_balance_minelayer_atmine_proximityradius);
	while(head)
	{
		if((head.classname == "player" || head.flags & FL_MONSTER) && head.deadflag == DEAD_NO)
		if(!head.stoned)     //Not for players afflicted with stonecurse
		if(head.frozen != 1) //Not for players frozen in ice. //1 == Ice, 2 == paralysis
		if(head != self.realowner && IsDifferentTeam(head, self)) // don't trigger for team mates
		if(!self.mine_time)
		{
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
			self.mine_time = time + autocvar_g_balance_minelayer_atmine_time;
		}
		head = head.chain;
	}

	// explode if it's time to
	if(self.mine_time && time >= self.mine_time)
	{
		atmine_ProximityExplode();
		return;
	}

	//// remote detonation
	//if (self.realowner.weapon == WEP_MINE_LAYER)
	//if (self.realowner.deadflag == DEAD_NO)
	//if (self.minelayer_detonate)
	//	W_Mine_RemoteExplode();
}

void atmine_Touch (void)
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
		atmine_Stick(other);
	}
}

void atmine_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
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
		W_PrepareExplosionByDamage(attacker, atmine_Explode);
}

void atmine_Attack (void)
{
	entity mine;
	//entity flash;

	//// scan how many mines we placed, and return if we reached our limit
	//if(autocvar_g_balance_minelayer_limit)
	//{
	//
	//	if(W_Mine_Count(self) >= autocvar_g_balance_minelayer_limit)
	//	{
	//		// the refire delay keeps this message from being spammed
	//		sprint(self, strcat("minelayer: You cannot place more than ^2", ftos(autocvar_g_balance_minelayer_limit), " ^7mines at a time\n") );
	//		play2(self, "weapons/unavailable.wav");
	//		return;
	//	}
	//}

	//Removed Decrease Ammo
	W_SetupShot_ProjectileSize (self, '-4 -4 -4', '4 4 4', FALSE, 1, "", CH_WEAPON_A, autocvar_g_balance_minelayer_damage);
	//Removed point particles
	
	mine = WarpZone_RefSys_SpawnSameRefSys(self);
	mine.owner = mine.realowner = self;
	
	if(teamplay) mine.team = mine.realowner.team; //For more checks
	
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
	mine.event_damage = atmine_Damage;
	mine.damagedbycontents = TRUE;

	mine.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(mine);
	mine.projectiledeathtype = WEP_MINE_LAYER;
	setsize (mine, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot

	setorigin (mine, w_shotorg - v_forward * 4); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(mine, 10 , 0);
	mine.angles = vectoangles (mine.velocity);

	mine.touch = atmine_Touch;
	mine.think = atmine_Think;
	mine.nextthink = time;
	mine.cnt = time + (autocvar_g_balance_minelayer_lifetime - autocvar_g_balance_minelayer_lifetime_countdown);
	mine.flags = FL_PROJECTILE;
	mine.missile_flags = MIF_SPLASH | MIF_ARC | MIF_PROXY;

	CSQCProjectile(mine, TRUE, PROJECTILE_ATMINE, TRUE);

	//Removed muzzle flash

	// common properties

	other = mine; MUTATOR_CALLHOOK(EditProjectile);
	
	//self.minelayer_mines = W_Mine_Count(self);
}

void atmine_place (entity player)
{
	if (player.origin_x == 0 && player.origin_y == 0 && player.origin_z == 0)
	{
		//No dropping mines when in the ether. (an unlikely event, perhaps impossible, but check)
		return;
	}
	player.atmines = player.atmines - 1;
	entity previousself;
	previousself = self;
	self = player;
	atmine_Attack();
	self = previousself;
}
////////////////////////////
//Landmine stuff
////////////////////////////
void Landmine_Mine_ProximityExplode ();
void landmine_NoRemote_Think (void);

void landmine_NoRemote_Stick (entity to)
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

	if(teamplay) newmine.team = newmine.realowner.team; //For more checks

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
	newmine.think = landmine_NoRemote_Think;
	newmine.nextthink = time;
	newmine.cnt = self.cnt;
	newmine.flags = self.flags;

	remove(self);
	self = newmine;

	if(to)
		SetMovetypeFollow(self, to);
}

void landmine_NoRemote_Touch (void)
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
		landmine_NoRemote_Stick(other);
	}
}

void landmine_NoRemote_Think (void)
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
		if(head != self.realowner && IsDifferentTeam(head, self)) // don't trigger for team mates
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
		Landmine_Mine_ProximityExplode();
		return;
	}

	// remote detonation removed
}

////// Similar to minelayer mine, but sets own team, not linked to owners current team (if he switches)
void Landmine_Mine_Think (void);

void Landmine_Mine_Stick (entity to)
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

	if(teamplay) newmine.team = newmine.realowner.team; //For more checks

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
	newmine.think = Landmine_Mine_Think;
	newmine.nextthink = time;
	newmine.cnt = self.cnt;
	newmine.flags = self.flags;

	remove(self);
	self = newmine;

	if(to)
		SetMovetypeFollow(self, to);
}

void Landmine_Mine_ProximityExplode ()
{
	// make sure no friend is in the mine's radius. If there is any, explosion is delayed until he's at a safe distance
	if(autocvar_g_balance_minelayer_protection && self.mine_explodeanyway == 0)
	{
		entity head;
		head = findradius(self.origin, autocvar_g_balance_minelayer_radius);
		while(head)
		{
			if(head == self.realowner || !IsDifferentTeam(head, self))
				return;
			head = head.chain;
		}
	}

	self.mine_time = 0;
	W_Mine_Explode();
}

void Landmine_Mine_Think (void)
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
		if(head != self.realowner && IsDifferentTeam(head, self)) // don't trigger for team mates
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
		Landmine_Mine_ProximityExplode();
		return;
	}

	// remote detonation
	if (self.realowner.weapon == WEP_MINE_LAYER)
	if (self.realowner.deadflag == DEAD_NO)
	if (self.minelayer_detonate)
		W_Mine_RemoteExplode();
}

void Landmine_Mine_Touch (void)
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
		Landmine_Mine_Stick(other);
	}
}

/////

void landmine_Attack (void)
{
	entity mine;
	// entity flash;

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

	//Removed decrease weapon ammo
	
	W_SetupShot_ProjectileSize (self, '-4 -4 -4', '4 4 4', FALSE, 0.25, "", CH_WEAPON_A, autocvar_g_balance_minelayer_damage);
	//Removed point particles
	
	mine = WarpZone_RefSys_SpawnSameRefSys(self);
	mine.owner = mine.realowner = self;
	
	if(teamplay) mine.team = mine.realowner.team; //For more checks

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
	W_SetupProjectileVelocity(mine, 10, 0);
	mine.angles = vectoangles (mine.velocity);

	//If we are holding the mine layer when we lay this down, it gets
	//set to use remote detonation, otherwise it's not setup for that
	if (mine.realowner.weapon == WEP_MINE_LAYER) {
		mine.touch = Landmine_Mine_Touch;
		mine.think = Landmine_Mine_Think;
	} else {
		mine.touch = landmine_NoRemote_Touch;
		mine.think = landmine_NoRemote_Think;
	}
	mine.nextthink = time;
	mine.cnt = time + (autocvar_g_balance_minelayer_lifetime - autocvar_g_balance_minelayer_lifetime_countdown);
	mine.flags = FL_PROJECTILE;
	mine.missile_flags = MIF_SPLASH | MIF_ARC | MIF_PROXY;

	CSQCProjectile(mine, TRUE, PROJECTILE_MINE, TRUE);

	//Removed Flash

	// common properties

	other = mine; MUTATOR_CALLHOOK(EditProjectile);
	
	self.minelayer_mines = W_Mine_Count(self);
}


void landmine_place (entity player)
{
	if (player.origin_x == 0 && player.origin_y == 0 && player.origin_z == 0)
	{
		//No dropping mines when in the ether. (an unlikely event, perhaps impossible, but check)
		return;
	}
	player.landmines = player.landmines - 1;
	entity previousself;
	previousself = self;
	self = player;
	landmine_Attack();
	self = previousself;
}

///////////////////////////
////Begin FragNade stuff
//////////////////////////
float FragnadeSplash_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_SMOKENADESPLASH);
	//WriteByte(MSG_ENTITY, self.state); // actually type if we add more types
	WriteLong(MSG_ENTITY, floor(self.origin_x / 4)); // Switched to long to support huge maps
	WriteLong(MSG_ENTITY, floor(self.origin_y / 4)); // still, gibs don't need super accuracy
	WriteLong(MSG_ENTITY, floor(self.origin_z / 4)); // but they need big coords sometimes	
	
	return TRUE;
}

void Fragnade_GibSplash_At(vector org, float type)
{
	entity e;

	e = spawn();
	e.classname = "fragnadesplash";
	//e.state = type; //If we add more types (incindiary etc)

	setorigin(e, org);

	Net_LinkEntity(e, FALSE, 0.2, FragnadeSplash_SendEntity);
}


void fragnade_burn_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE_BURN;

	CSQCProjectile(_nade, TRUE, p, TRUE);
}


void fragnade_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE;

	CSQCProjectile(_nade, TRUE, p, TRUE);

}

void fragnade_boom()
{
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	//pointparticles(particleeffectnum("hagar_explode"), self.origin + '0 0 1', '0 0 0', 1);

	self.takedamage = DAMAGE_NO;
	
	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_primary_damage, autocvar_g_balance_grenadelauncher_primary_edgedamage, autocvar_g_balance_grenadelauncher_primary_radius, world, autocvar_g_balance_grenadelauncher_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_primary_fragments_frames < 2)
	{
		float	sc;
		float   scpjt;
		for (sc = 0;sc < autocvar_g_balance_grenadelauncher_primary_fragments;sc = sc + 1) {
		
			if (random() > 0.5) {
				scpjt = PROJECTILE_BULLETSHRAPNELSHINE;
			} else {
				scpjt = PROJECTILE_BULLETSHRAPNEL;
			}
		
			fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
			 autocvar_g_balance_grenadelauncher_primary_fragment_speed, 5,
			 autocvar_g_balance_grenadelauncher_primary_fragment_damage,
			 autocvar_g_balance_grenadelauncher_primary_fragment_headshotbonus,
			 autocvar_g_balance_grenadelauncher_primary_fragment_force,
			 DEATH_FRAGMENT,
			 scpjt,
			 autocvar_g_balance_grenadelauncher_primary_fragment_gravity,
			 autocvar_g_balance_grenadelauncher_primary_fragment_bulletconstant,
			 autocvar_g_balance_grenadelauncher_primary_fragment_coreshotbonus);
			 
			endFireBallisticBullet();
		}
	} else {
		W_Grenade_FragsOverTimeSpawn(self, 20); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	remove(self);
}

void fragnade_touch()
{
	PROJECTILE_TOUCH;
	//setsize(self, '-2 -2 -2', '2 2 2');
	//UpdateCSQCProjectile(self);
	if(self.health == self.max_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTN_NORM);
		return;
	}

	self.enemy = other;
	fragnade_boom();
}

void fragnade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
	self.think = fragnade_boom;
	self.nextthink = max(self.wait, time);
}

void fragnade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX) || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = self.max_health * 0.55;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI))
		damage = self.max_health * 0.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && !(deathtype & HITTYPE_SECONDARY))
		damage = self.max_health * 1.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && (deathtype & HITTYPE_SECONDARY))
	{
		damage = self.max_health * 0.1;
		force *= 15;
	}

	self.velocity += force;

	if(!damage || (self.flags & FL_ONGROUND && isPlayerOrMonsterByClassname(attacker)))
		return;

	if(self.health == self.max_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
		self.nextthink = max(time + autocvar_g_nades_nade_lifetime, time);
		self.think = fragnade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, fragnade_boom);
	else
		fragnade_burn_spawn(self);
}

void fragtoss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.real_nade;
	e.real_nade = world;

	remove(e.fake_nade);
	e.fake_nade = world;

	makevectors(e.v_angle);

	W_SetupShot(e, FALSE, FALSE, "", CH_WEAPON_A, 0);

	//////Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_NADES);

	//setorigin(_nade, CENTER_OR_VIEWOFS(e) + (v_right * 10) * -1);
	setorigin(_nade, w_shotorg + (v_right * 25) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-3 -3 -3', '3 3 3');
	_nade.movetype = MOVETYPE_BOUNCE;

	tracebox(_nade.origin, _nade.mins, _nade.maxs, _nade.origin, FALSE, _nade);
	if (trace_startsolid)
		setorigin(_nade, e.origin);

	if(self.v_angle_x >= 70 && self.v_angle_x <= 110)
		_nade.velocity = '0 0 100';
	else if(autocvar_g_nades_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_nades_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, TRUE);
		
	_nade.touch = fragnade_touch;
	_nade.health = autocvar_g_nades_nade_health;
	_nade.max_health = _nade.health;
	_nade.takedamage = DAMAGE_AIM;
	_nade.event_damage = fragnade_damage;
	_nade.teleportable = TRUE;
	_nade.pushable = TRUE;
	_nade.gravity = 1;
	_nade.missile_flags = MIF_SPLASH | MIF_ARC;
	_nade.damagedbycontents = TRUE;
	_nade.angles = vectoangles(_nade.velocity);
	_nade.flags = FL_PROJECTILE;

	fragnade_spawn(_nade);

	if(_time)
	{
		_nade.think = fragnade_boom;
		_nade.nextthink = _time;
	}

	e.real_nade_refire = time + autocvar_g_nades_nade_refire;
}

void fragnade_prime()
{
	if(self.real_nade)
		remove(self.real_nade);

	if(self.fake_nade)
		remove(self.fake_nade);
		
	self.fragnades = self.fragnades - 1;

	self.real_nade = spawn();
	setmodel(self.real_nade, "null");
	setattachment(self.real_nade, self, "bip01 l hand");
	self.real_nade.classname = "nade";
	self.real_nade.nadeselected = 5; //So if player dies, correct nade will be dropped if primed allready (see player dies part of this file here)
	self.real_nade.realowner = self;
	self.real_nade.colormap = self.colormap;
	self.real_nade.glowmod = self.glowmod;
	self.real_nade.wait = time + autocvar_g_nades_nade_lifetime;
	self.real_nade.lifetime = time;
	self.real_nade.think = fragnade_beep;
	self.real_nade.nextthink = max(self.real_nade.wait - 3, time);
	//self.real_nade.projectiledeathtype = DEATH_NADE;
	self.real_nade.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	//self.real_nade.projectiledeathtype = DEATH_GRENADE;

	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	//self.fake_nade.viewmodelforclient = self;
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.real_nade.wait;
}
////////////////////////
////End FragNade stuff
/////////////////////////

///////////////////////////
////Begin SmokeNade stuff
//////////////////////////
float SmokenadeSplash_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_SMOKENADESPLASH);
	//WriteByte(MSG_ENTITY, self.state); // actually type if we add more types
	WriteLong(MSG_ENTITY, floor(self.origin_x / 4)); // Switched to long to support huge maps
	WriteLong(MSG_ENTITY, floor(self.origin_y / 4)); // still, gibs don't need super accuracy
	WriteLong(MSG_ENTITY, floor(self.origin_z / 4)); // but they need big coords sometimes	
	
	return TRUE;
}

void Smokenade_GibSplash_At(vector org, float type)
{
	entity e;

	e = spawn();
	e.classname = "smokenadesplash";
	//e.state = type; //If we add more types (incindiary etc)

	setorigin(e, org);

	Net_LinkEntity(e, FALSE, 0.2, SmokenadeSplash_SendEntity);
}

void smokenade_spawnserversmoke_think(void)
{
	if (self.alpha >= self.ammount) {
		self.fade_rate = 0;
		self.alpha = autocvar_g_nades_smokenade_serversmoke_alpha;
		SUB_SetFade (self, self.ammount2, 2);
	} else {
		self.alpha += frametime * self.fade_rate;
		self.think = smokenade_spawnserversmoke_think;
		self.nextthink = time;
	}
}

void smokenade_spawnserversmoke_at(vector org, float mylifetime, float mywait)
{
	entity e;
	local entity oslf;

	e = spawn();
	e.classname = "smokenadeserversplash";
	e.model = "models/misc/billowingsmoke.iqm";
	e.solid = SOLID_NOT;
	e.scale = 3;
	
	e.alpha = 0.0001;
	
	e.ammount = autocvar_g_nades_smokenade_serversmoke_alpha;
	e.ammount2 = time + mylifetime;
	e.cnt = mywait;
	
	e.think = smokenade_spawnserversmoke_think;
	e.nextthink = time;
	
	e.fade_rate = autocvar_g_nades_smokenade_serversmoke_alpha/mywait;
	
	e.origin = org + '0 0 2';
	
	oslf = self;
	self = e;
	setorigin(self, self.origin);
	spawnfunc_misc_gamemodel();
	self = oslf;	
}

void smokenade_burn_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE_BURN;

	CSQCProjectile(_nade, TRUE, p, TRUE);
}


void smokenade_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE;

	CSQCProjectile(_nade, TRUE, p, TRUE);

}

void smokenade_boom()
{
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTN_NORM);
	sound(self, CH_SHOTS, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("smoke_big"), self.origin + '0 0 1', '0 0 0', 1);

	self.takedamage = DAMAGE_NO;
	
	Smokenade_GibSplash_At(self.origin, 0);
	if (autocvar_g_nades_smokenade_serversmoke) {
		local float pc;
		pc = pointcontents(self.origin);
		if(pc == CONTENT_WATER || pc == CONTENT_LAVA || pc == CONTENT_SLIME) {
			//No smoke cloud spawned
		} else {
			smokenade_spawnserversmoke_at(self.origin, autocvar_g_nades_smokenade_serversmoke_time, 7);
		}
	}

	remove(self);
}

void smokenade_touch()
{
	PROJECTILE_TOUCH;
	//setsize(self, '-2 -2 -2', '2 2 2');
	//UpdateCSQCProjectile(self);
	if(self.health == self.max_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTN_NORM);
		return;
	}

	self.enemy = other;
	smokenade_boom();
}

void smokenade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
	self.think = smokenade_boom;
	self.nextthink = max(self.wait, time);
}

void smokenade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX) || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = self.max_health * 0.55;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI))
		damage = self.max_health * 0.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && !(deathtype & HITTYPE_SECONDARY))
		damage = self.max_health * 1.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && (deathtype & HITTYPE_SECONDARY))
	{
		damage = self.max_health * 0.1;
		force *= 15;
	}

	self.velocity += force;

	if(!damage || (self.flags & FL_ONGROUND && isPlayerOrMonsterByClassname(attacker)))
		return;

	if(self.health == self.max_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
		self.nextthink = max(time + autocvar_g_nades_nade_lifetime, time);
		self.think = smokenade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, smokenade_boom);
	else
		smokenade_burn_spawn(self);
}

void smoketoss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.real_nade;
	e.real_nade = world;

	remove(e.fake_nade);
	e.fake_nade = world;

	makevectors(e.v_angle);

	W_SetupShot(e, FALSE, FALSE, "", CH_WEAPON_A, 0);

	//////Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_NADES);

	//setorigin(_nade, CENTER_OR_VIEWOFS(e) + (v_right * 10) * -1);
	setorigin(_nade, w_shotorg + (v_right * 25) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-3 -3 -3', '3 3 3');
	_nade.movetype = MOVETYPE_BOUNCE;

	tracebox(_nade.origin, _nade.mins, _nade.maxs, _nade.origin, FALSE, _nade);
	if (trace_startsolid)
		setorigin(_nade, e.origin);

	if(self.v_angle_x >= 70 && self.v_angle_x <= 110)
		_nade.velocity = '0 0 100';
	else if(autocvar_g_nades_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_nades_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, TRUE);
		
	_nade.touch = smokenade_touch;
	_nade.health = autocvar_g_nades_nade_health;
	_nade.max_health = _nade.health;
	_nade.takedamage = DAMAGE_AIM;
	_nade.event_damage = smokenade_damage;
	_nade.teleportable = TRUE;
	_nade.pushable = TRUE;
	_nade.gravity = 1;
	_nade.missile_flags = MIF_SPLASH | MIF_ARC;
	_nade.damagedbycontents = TRUE;
	_nade.angles = vectoangles(_nade.velocity);
	_nade.flags = FL_PROJECTILE;

	smokenade_spawn(_nade);

	if(_time)
	{
		_nade.think = smokenade_boom;
		_nade.nextthink = _time;
	}

	e.real_nade_refire = time + autocvar_g_nades_nade_refire;
}

void smokenade_prime()
{
	if(self.real_nade)
		remove(self.real_nade);

	if(self.fake_nade)
		remove(self.fake_nade);
		
	self.smokenades = self.smokenades - 1;

	self.real_nade = spawn();
	setmodel(self.real_nade, "null");
	setattachment(self.real_nade, self, "bip01 l hand");
	self.real_nade.classname = "nade";
	self.real_nade.nadeselected = 2; //So if player dies, correct nade will be dropped if primed allready (see player dies part of this file here)
	self.real_nade.realowner = self;
	self.real_nade.colormap = self.colormap;
	self.real_nade.glowmod = self.glowmod;
	self.real_nade.wait = time + autocvar_g_nades_nade_lifetime;
	self.real_nade.lifetime = time;
	self.real_nade.think = smokenade_beep;
	self.real_nade.nextthink = max(self.real_nade.wait - 3, time);
	//self.real_nade.projectiledeathtype = DEATH_NADE;
	//self.real_nade.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	self.real_nade.projectiledeathtype = DEATH_GRENADE;

	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	//self.fake_nade.viewmodelforclient = self;
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.real_nade.wait;
}
////////////////////////
////End SmokeNade stuff
/////////////////////////

///////////////////////////
////Begin FlashNade stuff
//////////////////////////
void flashnade_burn_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE_BURN;

	CSQCProjectile(_nade, TRUE, p, TRUE);
}


void flashnade_spawn(entity _nade)
{
	float p;
	p = PROJECTILE_NADE;

	CSQCProjectile(_nade, TRUE, p, TRUE);

}

float flashnade_will_stun_monster(entity eburn)
{
	//Some magical monsters or undead are not stunned as they can "sence" you
	//Same for wizards
	//Normal monsters/animals/etc are stunned
	if (eburn.classname == "monster_ogre"
	|| eburn.classname == "monster_dog" || eburn.classname == "monster_wolf"
	|| eburn.classname == "monster_soldier" || eburn.classname == "monster_goblin"
	|| eburn.classname == "monster_knight" || eburn.classname == "monster_hellknight"
	|| eburn.classname == "monster_police" || eburn.classname == "monster_royalguard"
	|| eburn.classname == "monster_fighter" || eburn.classname == "monster_ninjaassassin"
	|| eburn.classname == "monster_minotaur" || eburn.classname == "monster_shinrae") {
		return TRUE;
	} else {
		return FALSE;
	}
}

void flashnade_doflash(entity mynade, float flashbangradi)
{
	local entity eburn;
	
	//Flash Full
	eburn = findradius(mynade.origin, flashbangradi);
	while(eburn)
	{
		if (isPlayerOrMonsterByClassname(eburn))
		if (eburn.stat_bangflash < 405) {
			eburn.stat_bangflash = 405;
			if (flashnade_will_stun_monster(eburn)) {
				//Clear enemy, stunned
				eburn.enemy = world;
			}
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Less
	eburn = findradius(mynade.origin, flashbangradi*1.25);
	while(eburn)
	{
		if (isPlayerOrMonsterByClassname(eburn))
		if (eburn.stat_bangflash < 210) {
			eburn.stat_bangflash = 210;
			if (flashnade_will_stun_monster(eburn)) {
				//Clear enemy, stunned
				eburn.enemy = world;
			}
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Less
	eburn = findradius(mynade.origin, flashbangradi*1.5);
	while(eburn)
	{
		if (isPlayerOrMonsterByClassname(eburn))
		if (eburn.stat_bangflash < 110) {
			eburn.stat_bangflash = 110;
			if (flashnade_will_stun_monster(eburn)) {
				//Clear enemy, stunned
				eburn.enemy = world;
			}
		}
		
		eburn = eburn.chain;
	}
	
	
	//Flash Less x2
	eburn = findradius(mynade.origin, flashbangradi*2);
	while(eburn)
	{
		if (isPlayerOrMonsterByClassname(eburn))
		if (eburn.stat_bangflash < 85) {
			eburn.stat_bangflash = 85;
			if (flashnade_will_stun_monster(eburn)) {
				//Clear enemy, stunned
				eburn.enemy = world;
			}
		}
		
		eburn = eburn.chain;
	}

}

void flashnade_boom()
{
	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum("hookbomb_explode"), self.origin + '0 0 1', '0 0 0', 1);

	//Damage_DamageInfo(self.origin, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage, autocvar_g_nades_nade_radius, '1 1 1' * autocvar_g_nades_nade_force, self.projectiledeathtype, 0, self);

	self.takedamage = DAMAGE_NO;
	//RadiusDamage(self, self.realowner, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage,
	//			 autocvar_g_nades_nade_radius, self, autocvar_g_nades_nade_force, self.projectiledeathtype, self.enemy);

	flashnade_doflash(self, 512);

	remove(self);
}

void flashnade_touch()
{
	PROJECTILE_TOUCH;
	//setsize(self, '-2 -2 -2', '2 2 2');
	//UpdateCSQCProjectile(self);
	if(self.health == self.max_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTN_NORM);
		return;
	}

	self.enemy = other;
	flashnade_boom();
}

void flashnade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
	self.think = flashnade_boom;
	self.nextthink = max(self.wait, time);
}

void flashnade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX) || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = self.max_health * 0.55;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI))
		damage = self.max_health * 0.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && !(deathtype & HITTYPE_SECONDARY))
		damage = self.max_health * 1.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && (deathtype & HITTYPE_SECONDARY))
	{
		damage = self.max_health * 0.1;
		force *= 15;
	}

	self.velocity += force;

	if(!damage || (self.flags & FL_ONGROUND && isPlayerOrMonsterByClassname(attacker)))
		return;

	if(self.health == self.max_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
		self.nextthink = max(time + autocvar_g_nades_nade_lifetime, time);
		self.think = flashnade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, flashnade_boom);
	else
		flashnade_burn_spawn(self);
}

void flashtoss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.real_nade;
	e.real_nade = world;

	remove(e.fake_nade);
	e.fake_nade = world;

	makevectors(e.v_angle);

	W_SetupShot(e, FALSE, FALSE, "", CH_WEAPON_A, 0);

	//////Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_NADES);

	//setorigin(_nade, CENTER_OR_VIEWOFS(e) + (v_right * 10) * -1);
	setorigin(_nade, w_shotorg + (v_right * 25) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-3 -3 -3', '3 3 3');
	_nade.movetype = MOVETYPE_BOUNCE;

	tracebox(_nade.origin, _nade.mins, _nade.maxs, _nade.origin, FALSE, _nade);
	if (trace_startsolid)
		setorigin(_nade, e.origin);

	if(self.v_angle_x >= 70 && self.v_angle_x <= 110)
		_nade.velocity = '0 0 100';
	else if(autocvar_g_nades_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_nades_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, TRUE);
		
	_nade.touch = flashnade_touch;
	_nade.health = autocvar_g_nades_nade_health;
	_nade.max_health = _nade.health;
	_nade.takedamage = DAMAGE_AIM;
	_nade.event_damage = flashnade_damage;
	_nade.teleportable = TRUE;
	_nade.pushable = TRUE;
	_nade.gravity = 1;
	_nade.missile_flags = MIF_SPLASH | MIF_ARC;
	_nade.damagedbycontents = TRUE;
	_nade.angles = vectoangles(_nade.velocity);
	_nade.flags = FL_PROJECTILE;

	flashnade_spawn(_nade);

	if(_time)
	{
		_nade.think = flashnade_boom;
		_nade.nextthink = _time;
	}

	e.real_nade_refire = time + autocvar_g_nades_nade_refire;
}

void flashnade_prime()
{
	if(self.real_nade)
		remove(self.real_nade);

	if(self.fake_nade)
		remove(self.fake_nade);
		
	self.flashbangs = self.flashbangs - 1;

	self.real_nade = spawn();
	setmodel(self.real_nade, "null");
	setattachment(self.real_nade, self, "bip01 l hand");
	self.real_nade.classname = "nade";
	self.real_nade.nadeselected = 1; //So if player dies, correct nade will be dropped if primed allready (see player dies part of this file here)
	self.real_nade.realowner = self;
	self.real_nade.colormap = self.colormap;
	self.real_nade.glowmod = self.glowmod;
	self.real_nade.wait = time + autocvar_g_nades_nade_lifetime;
	self.real_nade.lifetime = time;
	self.real_nade.think = flashnade_beep;
	self.real_nade.nextthink = max(self.real_nade.wait - 3, time);
	//self.real_nade.projectiledeathtype = DEATH_NADE;
	//self.real_nade.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	self.real_nade.projectiledeathtype = DEATH_GRENADE;

	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	//self.fake_nade.viewmodelforclient = self;
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.real_nade.wait;
}
////////////////////////
////End FlashNade stuff
/////////////////////////

void nade_timer_think()
{
	self.skin = 8 - (self.owner.wait - time) / (autocvar_g_nades_nade_lifetime / 10);
	self.nextthink = time;
	if(!self.owner || wasfreed(self.owner))
		remove(self);

}

void nade_burn_spawn(entity _nade)
{
	float p;

	//switch(_nade.realowner.team)
	//{
	//	case COLOR_TEAM1: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_RED_BURN; break;
	//	case COLOR_TEAM2: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_BLUE_BURN; break;
	//	case COLOR_TEAM3: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_YELLOW_BURN; break;
	//	case COLOR_TEAM4: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_PINK_BURN; break;
	//	default:		 p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_BURN; break;
	//}
	p = PROJECTILE_NADE_BURN;

	CSQCProjectile(_nade, TRUE, p, TRUE);
}

void nade_spawn(entity _nade)
{
	float p;
	//entity timer = spawn();
	//setmodel(timer, "models/ok_nade_counter/ok_nade_counter.md3");
	//setmodel(timer, "models/weapons/h_ok_grenade.iqm");
	//setattachment(timer, _nade, "");
	//timer.classname = "nade_timer";
	//timer.colormap = _nade.colormap;
	//timer.glowmod = _nade.glowmod;
	//timer.think = nade_timer_think;
	//timer.nextthink = time;
	//timer.wait = _nade.wait;
	//timer.owner = _nade;
	//timer.skin = 10;

	//switch(_nade.realowner.team)
	//{
	//	case COLOR_TEAM1: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_RED; break;
	//	case COLOR_TEAM2: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_BLUE; break;
	//	case COLOR_TEAM3: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_YELLOW; break;
	//	case COLOR_TEAM4: p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE_PINK; break;
	//	default:		 p = PROJECTILE_GRENADE_BOUNCING; break;//PROJECTILE_NADE; break;
	//}
	p = PROJECTILE_NADE;

	CSQCProjectile(_nade, TRUE, p, TRUE);

}

void nade_boom()
{
	string expef;

	switch(self.realowner.team)
	{
		case COLOR_TEAM1: expef = "nade_red_explode"; break;
		case COLOR_TEAM2: expef = "nade_blue_explode"; break;
		case COLOR_TEAM3: expef = "nade_yellow_explode"; break;
		case COLOR_TEAM4: expef = "nade_pink_explode"; break;
		default: 		 expef = "nade_explode"; break;
	}

	sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, ATTN_NORM);
	sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
	pointparticles(particleeffectnum(expef), self.origin + '0 0 1', '0 0 0', 1);

	Damage_DamageInfo(self.origin, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage, autocvar_g_nades_nade_radius, '1 1 1' * autocvar_g_nades_nade_force, self.projectiledeathtype, 0, self);

	self.takedamage = DAMAGE_NO;
	RadiusDamage(self, self.realowner, autocvar_g_nades_nade_damage, autocvar_g_nades_nade_edgedamage,
				 autocvar_g_nades_nade_radius, self, autocvar_g_nades_nade_force, self.projectiledeathtype, self.enemy);

	
	OilFire_explosion_spawnoilburnermaybe(self);
	
	remove(self);
}

void nade_touch()
{
	PROJECTILE_TOUCH;
	//setsize(self, '-2 -2 -2', '2 2 2');
	//UpdateCSQCProjectile(self);
	if(self.health == self.max_health)
	{
		spamsound(self, CH_SHOTS, strcat("weapons/grenade_bounce", ftos(1 + rint(random() * 5)), ".wav"), VOL_BASE, ATTN_NORM);
		return;
	}

	self.enemy = other;
	nade_boom();
}

void nade_beep()
{
	sound(self, CH_SHOTS_SINGLE, "overkill/grenadebip.ogg", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
	self.think = nade_boom;
	self.nextthink = max(self.wait, time);
}

void nade_damage(entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(DEATH_ISWEAPON(deathtype, WEP_LASER))
		return;

	if(DEATH_ISWEAPON(deathtype, WEP_NEX) || DEATH_ISWEAPON(deathtype, WEP_MINSTANEX))
	{
		force *= 6;
		damage = self.max_health * 0.55;
	}

	if(DEATH_ISWEAPON(deathtype, WEP_UZI))
		damage = self.max_health * 0.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && !(deathtype & HITTYPE_SECONDARY))
		damage = self.max_health * 1.1;

	if(DEATH_ISWEAPON(deathtype, WEP_SHOTGUN) && (deathtype & HITTYPE_SECONDARY))
	{
		damage = self.max_health * 0.1;
		force *= 15;
	}

	self.velocity += force;

	if(!damage || (self.flags & FL_ONGROUND && isPlayerOrMonsterByClassname(attacker)))
		return;

	if(self.health == self.max_health)
	{
		sound(self, CH_SHOTS_SINGLE, "misc/null.wav", VOL_BASE, 0.5 *(ATTN_LARGE + ATTN_MAX));
		self.nextthink = max(time + autocvar_g_nades_nade_lifetime, time);
		self.think = nade_beep;
	}

	self.health   -= damage;
	self.realowner = attacker;

	if(self.health <= 0)
		W_PrepareExplosionByDamage(attacker, nade_boom);
	else
		nade_burn_spawn(self);
}

void toss_nade(entity e, vector _velocity, float _time)
{
	entity _nade = e.real_nade;
	e.real_nade = world;

	remove(e.fake_nade);
	e.fake_nade = world;

	makevectors(e.v_angle);

	W_SetupShot(e, FALSE, FALSE, "", CH_WEAPON_A, 0);

	//////Kill_Notification(NOTIF_ONE_ONLY, e, MSG_CENTER_CPID, CPID_NADES);

	//setorigin(_nade, CENTER_OR_VIEWOFS(e) + (v_right * 10) * -1);
	setorigin(_nade, w_shotorg + (v_right * 25) * -1);
	setmodel(_nade, "models/weapons/v_ok_grenade.md3");
	setattachment(_nade, world, "");
	PROJECTILE_MAKETRIGGER(_nade);
	setsize(_nade, '-3 -3 -3', '3 3 3');
	_nade.movetype = MOVETYPE_BOUNCE;

	tracebox(_nade.origin, _nade.mins, _nade.maxs, _nade.origin, FALSE, _nade);
	if (trace_startsolid)
		setorigin(_nade, e.origin);

	if(self.v_angle_x >= 70 && self.v_angle_x <= 110)
		_nade.velocity = '0 0 100';
	else if(autocvar_g_nades_nade_newton_style == 1)
		_nade.velocity = e.velocity + _velocity;
	else if(autocvar_g_nades_nade_newton_style == 2)
		_nade.velocity = _velocity;
	else
		_nade.velocity = W_CalculateProjectileVelocity(e.velocity, _velocity, TRUE);
		
	_nade.touch = nade_touch;
	_nade.health = autocvar_g_nades_nade_health;
	_nade.max_health = _nade.health;
	_nade.takedamage = DAMAGE_AIM;
	_nade.event_damage = nade_damage;
	_nade.teleportable = TRUE;
	_nade.pushable = TRUE;
	_nade.gravity = 1;
	_nade.missile_flags = MIF_SPLASH | MIF_ARC;
	_nade.damagedbycontents = TRUE;
	_nade.angles = vectoangles(_nade.velocity);
	_nade.flags = FL_PROJECTILE;

	nade_spawn(_nade);

	if(_time)
	{
		_nade.think = nade_boom;
		_nade.nextthink = _time;
	}

	e.real_nade_refire = time + autocvar_g_nades_nade_refire;
}

void nade_prime()
{
	if(self.real_nade)
		remove(self.real_nade);

	if(self.fake_nade)
		remove(self.fake_nade);
		
	self.grenades = self.grenades - 1;

	self.real_nade = spawn();
	setmodel(self.real_nade, "null");
	setattachment(self.real_nade, self, "bip01 l hand");
	self.real_nade.classname = "nade";
	self.real_nade.realowner = self;
	self.real_nade.colormap = self.colormap;
	self.real_nade.glowmod = self.glowmod;
	self.real_nade.wait = time + autocvar_g_nades_nade_lifetime;
	self.real_nade.lifetime = time;
	self.real_nade.think = nade_beep;
	self.real_nade.nextthink = max(self.real_nade.wait - 3, time);
	//self.real_nade.projectiledeathtype = DEATH_NADE;
	//self.real_nade.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	self.real_nade.projectiledeathtype = DEATH_GRENADE;

	self.fake_nade = spawn();
	setmodel(self.fake_nade, "models/weapons/h_ok_grenade.iqm");
	setattachment(self.fake_nade, self.weaponentity, "");
	self.fake_nade.classname = "fake_nade";
	//self.fake_nade.viewmodelforclient = self;
	self.fake_nade.realowner = self.fake_nade.owner = self;
	self.fake_nade.colormap = self.colormap;
	self.fake_nade.glowmod = self.glowmod;
	self.fake_nade.think = SUB_Remove;
	self.fake_nade.nextthink = self.real_nade.wait;
}

float CanThrowNade()
{
	if(self.vehicle)
		return FALSE;

	if(gameover)
		return FALSE;

	if(self.deadflag != DEAD_NO)
		return FALSE;

	if (!autocvar_g_nades)
		return FALSE; // allow turning them off mid match

	if(self.stoned)
		return FALSE;
		
	if(self.frozen)
		return FALSE;
		
	if(self.freezetag_frozen)
		return FALSE;
		
	if(self.prisonerlevel == 3)
		return FALSE;
		
	//if(forbidWeaponUse())
	//	return FALSE;

	if (!(isPlayerOrMonsterByClassname(self)))
		return FALSE;

	return TRUE;
}

void nades_CheckThrow()
{
	if(!CanThrowNade())
		return;

	if(!self.real_nade)
	{
		if(self.real_nade_refire < time)
		{
			//////Send_Notification(NOTIF_ONE, self, MSG_CENTER, CENTER_NADE_THROW);
			nade_prime();
			self.real_nade_refire = time + autocvar_g_nades_nade_refire;
		}
	}
	else
	{
		if(time - self.real_nade.lifetime >= 1)
		{
			makevectors(self.v_angle);
			float _force = time - self.real_nade.lifetime;
			_force /= autocvar_g_nades_nade_lifetime;
			_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
			if (self.real_nade.nadeselected == 1) 
			{
				flashtoss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
			} else if (self.real_nade.nadeselected == 2) 
			{
				smoketoss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
			} else if (self.real_nade.nadeselected == 5) 
			{
				fragtoss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
			}
			else
			{
				toss_nade(self, (v_forward * 0.75 + v_up * 0.2 + v_right * 0.05) * _force, 0);
			}
		}
	}
}

MUTATOR_HOOKFUNCTION(nades_CheckThrow)
{
	if(MUTATOR_RETURNVALUE) { nades_CheckThrow(); }
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_VehicleEnter)
{
	if(other.real_nade) {
		if (other.real_nade.nadeselected == 1) {
			flashtoss_nade(other, '0 0 100', max(other.real_nade.wait, time + 0.05));
		} else if (other.real_nade.nadeselected == 2) {
			smoketoss_nade(other, '0 0 100', max(other.real_nade.wait, time + 0.05));
		} else if (other.real_nade.nadeselected == 5) {
			fragtoss_nade(other, '0 0 100', max(other.real_nade.wait, time + 0.05));
		} else {
			toss_nade(other, '0 0 100', max(other.real_nade.wait, time + 0.05));
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerPreThink)
{
	//float key_pressed = ((g_grappling_hook || client_hasweapon(self, WEP_HOOK, FALSE, FALSE) || (weaponsInMap & WEPSET_HOOK)) ? self.button16 : self.BUTTON_HOOK);
	//float key_pressed = ((g_grappling_hook || client_hasweapon(self, WEP_HOOK, FALSE, FALSE) ) ? self.button16 : self.BUTTON_HOOK);
	float key_pressed = self.button16;

	if(self.real_nade) {
		if(self.real_nade.wait - 0.1 <= time) {
			if (self.real_nade.nadeselected == 1) {
				flashtoss_nade(self, '0 0 0', time + 0.05);
			} else if (self.real_nade.nadeselected == 2) {
				smoketoss_nade(self, '0 0 0', time + 0.05);
			} else if (self.real_nade.nadeselected == 5) {
				fragtoss_nade(self, '0 0 0', time + 0.05);
			} else {
				toss_nade(self, '0 0 0', time + 0.05);
			}
		}
	}

	//print(ftos(self.grenades)," n nades\n");
	float selectedgrenade;
	if(self.nadeselected == 1) {
		if(self.flashbangs >= 1) {
			selectedgrenade = 1;
		} else {
			if(self.smokenades >= 1) {
				selectedgrenade = 2;
			} else {
				selectedgrenade = 1;
			}
		}
	} else if(self.nadeselected == 2) {
		if(self.smokenades >= 1) {
			selectedgrenade = 2;
		} else {
			if(self.flashbangs >= 1) {
				selectedgrenade = 1;
			} else {
				selectedgrenade = 2;
			}
		}
	} else if(self.nadeselected == 3) {
		//landmines. They won't be automatically selected
		//Too different, your guy wouldn't accidentally pick them
		if(self.landmines >= 1) {
			selectedgrenade = 3;
		} else {
			if(self.atmines >= 1) {
				selectedgrenade = 4; //Fallback to large mine
			} else {
				selectedgrenade = 3;
			}
		}
	} else if(self.nadeselected == 4) {
		//AT mines. They won't be automatically selected
		//Too big, your guy wouldn't accidentally pick them
		if(self.atmines >= 1) {
			selectedgrenade = 4;
		} else {
			if(self.landmines >= 1) {
				selectedgrenade = 3; //Fallback to small mine
			} else {
				selectedgrenade = 4;
			}
		}
	} else if(self.nadeselected == 5) {
		if(self.fragnades >= 1) {
			selectedgrenade = 5;
		} else {
			if(self.grenades >= 1) {
				selectedgrenade = 0; //Fallback to grenade
			} else {
				selectedgrenade = 5;
			}
		}	
	} else {
		if(self.grenades >= 1) {
			selectedgrenade = 0;
		} else {
			if (self.fragnades >= 1) {
				selectedgrenade = 5;
			} else {
				selectedgrenade = 0;
			}
		}
	}
	
	if(selectedgrenade == 1) {
	  ////////////////////////////////
          //Flashnade
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.flashbangs >= 1) //Must have atleast 1 ammo
				flashnade_prime();
		}
		else if(time - self.real_nade.lifetime >= 1)
		{
			if(self.real_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.real_nade.lifetime;
				_force /= autocvar_g_nades_nade_lifetime;
				_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
				flashtoss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	  }
	  ////////////////////////////////
	} else if(selectedgrenade == 2) {
	  ////////////////////////////////
          //Smokenade
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.smokenades >= 1) //Must have atleast 1 ammo
				smokenade_prime();
		}
		else if(time - self.real_nade.lifetime >= 1)
		{
			if(self.real_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.real_nade.lifetime;
				_force /= autocvar_g_nades_nade_lifetime;
				_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
				smoketoss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	  }
	  ////////////////////////////////
	} else if(selectedgrenade == 3) {
	  ////////////////////////////////
          //landines
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.landmines >= 1) { //Must have atleast 1 ammo
				landmine_place(self);
				self.real_nade_refire = time + autocvar_g_nades_nade_refire;
			}
		}
	  }
	  ////////////////////////////////
	} else if(selectedgrenade == 4) {
	  ////////////////////////////////
          //ATMines
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.atmines >= 1) { //Must have atleast 1 ammo
				atmine_place(self);
				self.real_nade_refire = time + autocvar_g_nades_nade_refire;
			}
		}
	  }
	  ////////////////////////////////
	} else if(selectedgrenade == 5) {
	  ////////////////////////////////
          //Fragnade
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.fragnades >= 1) //Must have atleast 1 ammo
				fragnade_prime();
		}
		else if(time - self.real_nade.lifetime >= 1)
		{
			if(self.real_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.real_nade.lifetime;
				_force /= autocvar_g_nades_nade_lifetime;
				_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
				fragtoss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	  }
	  ////////////////////////////////
	} else {
	  ////////////////////////////////
	  //Regular Grenade
	  if(CanThrowNade())
	  if(self.real_nade_refire < time)
	  {
		if(key_pressed)
		{
			if(!self.real_nade)
			if(self.grenades >= 1) //Must have atleast 1 ammo
				nade_prime();
		}
		else if(time - self.real_nade.lifetime >= 1)
		{
			if(self.real_nade)
			{
				makevectors(self.v_angle);
				float _force = time - self.real_nade.lifetime;
				_force /= autocvar_g_nades_nade_lifetime;
				_force = autocvar_g_nades_nade_minforce + (_force * (autocvar_g_nades_nade_maxforce - autocvar_g_nades_nade_minforce));
				toss_nade(self, (v_forward * 0.7 + v_up * 0.2 + v_right * 0.1) * _force, 0);
			}
		}
	  }
	  ////////////////////////////////
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerSpawn)
{
	if(autocvar_g_nades_spawn)
		self.real_nade_refire = time + autocvar_g_spawnshieldtime;
	else
		self.real_nade_refire  = time + autocvar_g_nades_nade_refire;

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_PlayerDies)
{
	if(self.real_nade) {
		if (self.real_nade.nadeselected == 1) {
			flashtoss_nade(self, '0 0 100', max(self.real_nade.wait, time + 0.05));
		} else if (self.real_nade.nadeselected == 2) {
			smoketoss_nade(self, '0 0 100', max(self.real_nade.wait, time + 0.05));
		} else if (self.real_nade.nadeselected == 5) {
			fragtoss_nade(self, '0 0 100', max(self.real_nade.wait, time + 0.05));
		} else {
			toss_nade(self, '0 0 100', max(self.real_nade.wait, time + 0.05));
		}
	}

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_RemovePlayer)
{
	if(self.real_nade)
		remove(self.real_nade);

	if(self.fake_nade)
		remove(self.fake_nade);

	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_BuildMutatorsString)
{
	ret_string = strcat(ret_string, ":Nades");
	return FALSE;
}

MUTATOR_HOOKFUNCTION(nades_BuildMutatorsPrettyString)
{
	ret_string = strcat(ret_string, ", Nades");
	return FALSE;
}

MUTATOR_DEFINITION(mutator_nades)
{
	MUTATOR_HOOK(ForbidThrowCurrentWeapon, nades_CheckThrow, CBC_ORDER_LAST);
	MUTATOR_HOOK(VehicleEnter, nades_VehicleEnter, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerPreThink, nades_PlayerPreThink, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerSpawn, nades_PlayerSpawn, CBC_ORDER_ANY);
	MUTATOR_HOOK(PlayerDies, nades_PlayerDies, CBC_ORDER_ANY);
	MUTATOR_HOOK(MakePlayerObserver, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(ClientDisconnect, nades_RemovePlayer, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsString, nades_BuildMutatorsString, CBC_ORDER_ANY);
	MUTATOR_HOOK(BuildMutatorsPrettyString, nades_BuildMutatorsPrettyString, CBC_ORDER_ANY);

	MUTATOR_ONADD
	{
		//precache_model("models/ok_nade_counter/ok_nade_counter.md3");

		precache_model("models/weapons/h_ok_grenade.iqm");
		precache_model("models/weapons/v_ok_grenade.md3");
		precache_model("models/atmine.iqm");
		precache_sound("machines/steam_fade.ogg");
		precache_sound("weapons/rocket_impact.wav");
		precache_sound("weapons/grenade_bounce1.wav");
		precache_sound("weapons/grenade_bounce2.wav");
		precache_sound("weapons/grenade_bounce3.wav");
		precache_sound("weapons/grenade_bounce4.wav");
		precache_sound("weapons/grenade_bounce5.wav");
		precache_sound("weapons/grenade_bounce6.wav");
		precache_sound("overkill/grenadebip.ogg");
		
		g_nades = 1;
	}

	// this just turns off the cvar.
	MUTATOR_ONREMOVE
	{	 
		g_nades = 0;
	}

	return FALSE;
}
