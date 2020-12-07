#ifdef REGISTER_WEAPON
REGISTER_WEAPON(GRENADE_LAUNCHER, w_glauncher, IT_ROCKETS, 4, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_FLAG_CANCLIMB | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "gl", "grenadelauncher", _("Mortar"))
#else
#ifdef SVQC
.float gl_detonate_later;
.float gl_bouncecnt;
.float gl_release;
.float ignoreaccuracy;

void W_Grenade_FragsOverTime (void)
{
	//print("Here\n");
	//Start Grenade Fragmentation
	float	sc;
	float   scpjt;
	for (sc = 0;sc < self.count;sc = sc + 1) {
	
		if (random() > 0.5) {
			scpjt = PROJECTILE_BULLETSHRAPNELHOT;
		} else {
			scpjt = PROJECTILE_BULLETSHRAPNELDARK;
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
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_balance_grenadelauncher_primary_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void W_Grenade_FragsOverTimeShine (void)
{
	//print("Here\n");
	//Start Grenade Fragmentation
	float	sc;
	float   scpjt;
	for (sc = 0;sc < self.count;sc = sc + 1) {
	
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
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_balance_grenadelauncher_primary_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void W_Grenade_FragsOverTime2 (void)
{
	//print("Here2\n");
	//Start Grenade Fragmentation
	float	sc;
	float   scpjt;
	for (sc = 0;sc < self.count;sc = sc + 1) {
	
		if (random() > 0.5) {
			scpjt = PROJECTILE_BULLETSHRAPNELHOT;
		} else {
			scpjt = PROJECTILE_BULLETSHRAPNELDARK;
		}
		
		fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
		 DEATH_FRAGMENT,
		 scpjt,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
		 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
		endFireBallisticBullet();
	}
	//Finish Grenade Fragmentation
	
	self.cnt = self.cnt + self.count;
	self.nextthink = time;
	if (self.cnt >= autocvar_g_balance_grenadelauncher_secondary_fragments)
		remove(self);
	//Finish Grenade Fragmentation
}

void W_Grenade_FragsOverTimeSpawn (entity gren, float type)
{
	float frameadjust;
	entity e;
	e = spawn();
	e.owner = e.realowner = gren.realowner;
	e.origin = gren.origin;
	setorigin(e, e.origin);
	
	frameadjust = sys_frametime/0.0222222;
	if (type == 0)
	{
		e.think = W_Grenade_FragsOverTime;
		if (frameadjust > 0.95) {
			//So if we have lower frametime than default or default we keep it the same
			e.count = floor(autocvar_g_balance_grenadelauncher_primary_fragments / autocvar_g_balance_grenadelauncher_primary_fragments_frames)+1;
		} else {
			//If we have lower frametime than the standard, spreadout over time more
			e.count = floor(autocvar_g_balance_grenadelauncher_primary_fragments / (autocvar_g_balance_grenadelauncher_primary_fragments_frames/frameadjust))+1;
		}
	} else if (type == 20)
	{
		e.think = W_Grenade_FragsOverTimeShine;
		if (frameadjust > 0.95) {
			//So if we have lower frametime than default or default we keep it the same
			e.count = floor(autocvar_g_balance_grenadelauncher_primary_fragments / autocvar_g_balance_grenadelauncher_primary_fragments_frames)+1;
		} else {
			//If we have lower frametime than the standard, spreadout over time more
			e.count = floor(autocvar_g_balance_grenadelauncher_primary_fragments / (autocvar_g_balance_grenadelauncher_primary_fragments_frames/frameadjust))+1;
		}
	} else {
		e.think = W_Grenade_FragsOverTime2;
		if (frameadjust > 0.95) {
			//So if we have lower frametime than default or default we keep it the same
			e.count = floor(autocvar_g_balance_grenadelauncher_secondary_fragments / autocvar_g_balance_grenadelauncher_secondary_fragments_frames)+1;
		} else {
			//If we have lower frametime than the standard, spreadout over time more
			e.count = floor(autocvar_g_balance_grenadelauncher_secondary_fragments / (autocvar_g_balance_grenadelauncher_secondary_fragments_frames/frameadjust))+1;
		}
	}
	//print(ftos(sys_frametime),"  :  ",ftos(e.count),"\n");
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
}

void W_Grenade_Explode (void)
{
	if(autocvar_g_balance_grenadelauncher_primary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_primary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade was a dud\n");
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_primary_damage, autocvar_g_balance_grenadelauncher_primary_edgedamage, autocvar_g_balance_grenadelauncher_primary_radius, world, autocvar_g_balance_grenadelauncher_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_primary_fragments_frames < 2)
	{
		float	sc;
		float   scpjt;
		for (sc = 0;sc < autocvar_g_balance_grenadelauncher_primary_fragments;sc = sc + 1) {
		
			if (random() > 0.5) {
				scpjt = PROJECTILE_BULLETSHRAPNELHOT;
			} else {
				scpjt = PROJECTILE_BULLETSHRAPNELDARK;
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
		W_Grenade_FragsOverTimeSpawn(self, 0); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

void W_Grenade_Explode2 (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade failed to detonate\n");
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	//Start Grenade Fragmentation
	if(autocvar_g_balance_grenadelauncher_secondary_fragments_frames < 2)
	{
		float	sc;
		float   scpjt;
		for (sc = 0;sc < autocvar_g_balance_grenadelauncher_secondary_fragments;sc = sc + 1) {
		
			if (random() > 0.5) {
				scpjt = PROJECTILE_BULLETSHRAPNELHOT;
			} else {
				scpjt = PROJECTILE_BULLETSHRAPNELDARK;
			}
		
			fireBallisticBullet(self.origin,randomvec() * 10 * random(), 1,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_speed, 5,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_damage,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_headshotbonus,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_force,
			 DEATH_FRAGMENT,
			 scpjt,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_gravity,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_bulletconstant,
			 autocvar_g_balance_grenadelauncher_secondary_fragment_coreshotbonus);
		 
			endFireBallisticBullet();
		}
	} else {
		W_Grenade_FragsOverTimeSpawn(self, 1); //Spread out fragment spawning
	}
	//Finish Grenade Fragmentation
	
	}
	remove (self);
}

//No Fragmentation Grenade
void W_Grenade_ExplodeB (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade failed to detonate\n");
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	//No Fragmentation
	}
	remove (self);
}

//Rock
void W_Grenade_ExplodeBR (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
			sprint(self.owner, "Your grenade failed to detonate\n");
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

	RadiusDamage (self, self.realowner, autocvar_g_balance_grenadelauncher_secondary_damage, autocvar_g_balance_grenadelauncher_secondary_edgedamage, autocvar_g_balance_grenadelauncher_secondary_radius, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);
	//OilFire_explosion_spawnoilburnermaybe(self);

	//No Fragmentation
	}
	remove (self);
}

void W_Grenade_ExplodeBRSR_HurtWooden(vector myorigin, entity caster, float mydamage, float myradius)
{
	local entity enextent;
	enextent = findradius(myorigin, myradius);
	while(enextent)
	{
		if (enextent != world)
		if (enextent != caster) {
			if (enextent.classname == "bldhitbx" && multitool_iswooden(enextent.count))
			{
				Damage(enextent, caster, caster, 
				mydamage, WEP_ROCKET_LAUNCHER, 
				enextent.origin + enextent.view_ofs, 
				'0 0 0');
			}
		}
		
		enextent = enextent.chain;
	}
}

void W_Grenade_ExplodeBRSR_HurtFarms(vector myorigin, entity caster, float mydamage, float myradius)
{
	local entity enextent;
	enextent = findradius(myorigin, myradius);
	while(enextent)
	{
		if (enextent != world)
		if (enextent != caster) {
			if (enextent.classname == "bldhitbx" && (enextent.count == 501 || enextent.count == 502))
			{
				Damage(enextent, caster, caster, 
				mydamage, WEP_ROCKET_LAUNCHER, 
				enextent.origin + enextent.view_ofs, 
				'0 0 0');
			}
		}
		
		enextent = enextent.chain;
	}
}

//Rock - Stone Rain
void W_Grenade_ExplodeBRSR (void)
{
	if(autocvar_g_balance_grenadelauncher_secondary_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_failurerate > random() ))
 	{
		//if ((clienttype(self.owner) == CLIENTTYPE_REAL)) {
		//	sprint(self.owner, "Your stone disintegrated\n");
		//}
	} else {
	
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	if (other.multitool_hitbox) {
		if (other.classname == "building" && multitool_iswooden(other.multitool_hitbox.count))
		{
			Damage(other.multitool_hitbox, self.realowner, self.realowner, 
			30, WEP_ROCKET_LAUNCHER, 
			other.origin + other.view_ofs, 
			'0 0 0');
		}
	}
			
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	RadiusDamage (self, self.realowner, 60, 5, 128, world, autocvar_g_balance_grenadelauncher_secondary_force, self.projectiledeathtype, other);
	//OilFire_explosion_spawnoilburnermaybe(self);
	
	W_Grenade_ExplodeBRSR_HurtWooden(self.origin, self.realowner, 30, 128);
	W_Grenade_ExplodeBRSR_HurtFarms(self.origin, self.realowner, 30, 768);
	
	//No Fragmentation
	}
	remove (self);
}


void W_Grenade_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
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

void W_Grenade_Think1 (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_Grenade_Explode ();
		return;
	}
	if(self.gl_detonate_later && self.gl_bouncecnt >= autocvar_g_balance_grenadelauncher_primary_remote_minbouncecnt)
		W_Grenade_Explode();
}

void W_Grenade_Touch1 (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM || autocvar_g_balance_grenadelauncher_primary_type == 0) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else if (autocvar_g_balance_grenadelauncher_primary_type == 1) // bounce
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.gl_bouncecnt += 1;
	}
	else if(autocvar_g_balance_grenadelauncher_primary_type == 2 && (!other || (other.takedamage != DAMAGE_AIM && other.movetype == MOVETYPE_NONE))) // stick
	{
		spamsound (self, CH_SHOTS, "weapons/grenade_stick.wav", VOL_BASE, ATTN_NORM);

		// let it stick whereever it is
		self.oldvelocity = self.velocity;
		self.velocity = '0 0 0';
		self.movetype = MOVETYPE_NONE; // also disables gravity
		self.gravity = 0; // nope, it does NOT! maybe a bug in CSQC code? TODO
		UpdateCSQCProjectile(self);

		// do not respond to any more touches
		self.solid = SOLID_NOT;

		self.nextthink = min(self.nextthink, time + autocvar_g_balance_grenadelauncher_primary_lifetime_stick);
	}
}

void W_Grenade_Touch2 (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM || autocvar_g_balance_grenadelauncher_secondary_type == 0) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else if (autocvar_g_balance_grenadelauncher_secondary_type == 1) // bounce
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.gl_bouncecnt += 1;
		
		if (autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce && self.gl_bouncecnt == 1)
			self.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce;
			
	}
	else if(autocvar_g_balance_grenadelauncher_secondary_type == 2 && (!other || (other.takedamage != DAMAGE_AIM && other.movetype == MOVETYPE_NONE))) // stick
	{
		spamsound (self, CH_SHOTS, "weapons/grenade_stick.wav", VOL_BASE, ATTN_NORM);

		// let it stick whereever it is
		self.oldvelocity = self.velocity;
		self.velocity = '0 0 0';
		self.movetype = MOVETYPE_NONE; // also disables gravity
		self.gravity = 0; // nope, it does NOT! maybe a bug in CSQC code? TODO
		UpdateCSQCProjectile(self);

		// do not respond to any more touches
		self.solid = SOLID_NOT;

		self.nextthink = min(self.nextthink, time + autocvar_g_balance_grenadelauncher_secondary_lifetime_stick);
	}
}

void W_Grenade_Touch2R (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM || autocvar_g_balance_grenadelauncher_secondary_type == 0) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else if (autocvar_g_balance_grenadelauncher_secondary_type == 1) // bounce
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_21.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_22.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_23.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_24.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_25.ogg", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_26.ogg", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.gl_bouncecnt += 1;
		
		if (autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce && self.gl_bouncecnt == 1)
			self.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce;
			
	}
	else if(autocvar_g_balance_grenadelauncher_secondary_type == 2 && (!other || (other.takedamage != DAMAGE_AIM && other.movetype == MOVETYPE_NONE))) // stick
	{
		spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_21.ogg", VOL_BASE, ATTN_NORM);

		// let it stick whereever it is
		self.oldvelocity = self.velocity;
		self.velocity = '0 0 0';
		self.movetype = MOVETYPE_NONE; // also disables gravity
		self.gravity = 0; // nope, it does NOT! maybe a bug in CSQC code? TODO
		UpdateCSQCProjectile(self);

		// do not respond to any more touches
		self.solid = SOLID_NOT;

		self.nextthink = min(self.nextthink, time + autocvar_g_balance_grenadelauncher_secondary_lifetime_stick);
	}
}

void W_Grenade_Touch2RSR (void)
{
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM ||
	((other.multitool_hitbox) && (other.classname == "building" && multitool_iswooden(other.multitool_hitbox.count)))	
	) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else // bounce
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_21.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_22.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_23.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_24.ogg", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_25.ogg", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "resource/impact/slingimpstone_26.ogg", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.gl_bouncecnt += 1;
		
		if (autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce && self.gl_bouncecnt == 1)
			self.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime_bounce;
			
	}
}

void W_Grenade_Attack (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_grenadelauncher_primary_ammo, autocvar_g_balance_grenadelauncher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_primary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_primary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_grenadelauncher_primary_lifetime;
	gren.nextthink = time;
	gren.think = W_Grenade_Think1;
	gren.use = W_Grenade_Explode;
	gren.touch = W_Grenade_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_primary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_primary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	if(autocvar_g_balance_grenadelauncher_primary_launch_failurerate &&
 	(autocvar_g_balance_grenadelauncher_primary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_primary_launchfailure);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {	
			sprint(self, "Your grenade held an insufficent firing charge\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_primary);
	}


	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_primary_type == 0 || autocvar_g_balance_grenadelauncher_primary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Grenade_Attack2 (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_grenadelauncher_secondary_ammo, autocvar_g_balance_grenadelauncher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Grenade_Explode2;
	gren.touch = W_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	if(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary_launchfailure);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your grenade held an insufficent firing charge\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);
	}

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

//No Fragmentation Grenade Attack (Used for monster projectiles)
void W_Grenade_AttackB (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_grenadelauncher_secondary_ammo, autocvar_g_balance_grenadelauncher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "weapons/grenade_fire.wav", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_GRENADE_LAUNCHER | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Grenade_ExplodeB;
	gren.touch = W_Grenade_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	if(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary_launchfailure);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your grenade held an insufficent firing charge\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);
	}

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_GRENADE_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

//Rock Attack (Used for monster projectiles)
void W_Grenade_AttackBR (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_grenadelauncher_secondary_ammo, autocvar_g_balance_grenadelauncher_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "resource/gathering/gather_field_11.ogg", CH_WEAPON_A, autocvar_g_balance_grenadelauncher_secondary_damage);
	w_shotdir = v_forward; // no TrueAim for grenades please

	//pointparticles(particleeffectnum("grenadelauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "grenade";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_grenadelauncher_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_grenadelauncher_bouncefactor;
	gren.bouncestop = autocvar_g_balance_grenadelauncher_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = DEATH_VHCRUSH; //So doesn't gib
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.nextthink = time + autocvar_g_balance_grenadelauncher_secondary_lifetime;
	gren.think = adaptor_think2use_hittype_splash;
	gren.use = W_Grenade_ExplodeBR;
	gren.touch = W_Grenade_Touch2R;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_grenadelauncher_secondary_health;
	gren.damageforcescale = autocvar_g_balance_grenadelauncher_secondary_damageforcescale;
	gren.event_damage = W_Grenade_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	if(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate &&
 	(autocvar_g_balance_grenadelauncher_secondary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary_launchfailure);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your grenade held an insufficent firing charge\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_grenadelauncher_secondary);
	}

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	if(autocvar_g_balance_grenadelauncher_secondary_type == 0 || autocvar_g_balance_grenadelauncher_secondary_type == 2)
		CSQCProjectile(gren, TRUE, PROJECTILE_ROCK, TRUE);
	else
		CSQCProjectile(gren, TRUE, PROJECTILE_ROCK_BOUNCING, TRUE);

	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float W_glauncher_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_grenadelauncher_reload_ammo && self.clip_load < min(autocvar_g_balance_grenadelauncher_primary_ammo, autocvar_g_balance_grenadelauncher_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_grenadelauncher (void)
{
	weapon_defaultspawnfunc(WEP_GRENADE_LAUNCHER);
}

.float bot_secondary_grenademooth;
float w_glauncher(float req)
{
	entity nade;
	float nadefound;
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_glauncher_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		if (self.bot_secondary_grenademooth == 0)
		{
			if(bot_aim(autocvar_g_balance_grenadelauncher_primary_speed, autocvar_g_balance_grenadelauncher_primary_speed_up, autocvar_g_balance_grenadelauncher_primary_lifetime, TRUE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_grenademooth = 1;
			}
		}
		else
		{
			if(bot_aim(autocvar_g_balance_grenadelauncher_secondary_speed, autocvar_g_balance_grenadelauncher_secondary_speed_up, autocvar_g_balance_grenadelauncher_secondary_lifetime, TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.02) self.bot_secondary_grenademooth = 0;
			}
		}
	}
	else if (req == WR_THINK && !W_glauncher_NeedManualReload())
	{
		if(autocvar_g_balance_grenadelauncher_reload_ammo && self.clip_load < min(autocvar_g_balance_grenadelauncher_primary_ammo, autocvar_g_balance_grenadelauncher_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if (self.BUTTON_ATCK)
		{
			if (self.gl_release)
			if (weapon_prepareattack(0, autocvar_g_balance_grenadelauncher_primary_refire))
			{
				W_Grenade_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_grenadelauncher_primary_animtime, w_ready);
				PlayerGunRise(self, autocvar_g_balance_grenadelauncher_gunrise, random() * autocvar_g_balance_grenadelauncher_gunrun);
				self.gl_release = 0;
			}
		}
		else if (self.BUTTON_ATCK2)
		{
			if (cvar("g_balance_grenadelauncher_secondary_remote_detonateprimary"))
			{
				nadefound = 0;
				for(nade = world; (nade = find(nade, classname, "grenade")); ) if(nade.realowner == self)
				{
					if(!nade.gl_detonate_later)
					{
						nade.gl_detonate_later = TRUE;
						nadefound = 1;
					}
				}
				if(nadefound)
					sound (self, CH_WEAPON_B, "weapons/rocket_det.wav", VOL_BASE, ATTN_NORM);
			}
			else if (self.gl_release) {
			  if (weapon_prepareattack(1, autocvar_g_balance_grenadelauncher_secondary_refire))
			  {
					W_Grenade_Attack2();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_grenadelauncher_secondary_animtime, w_ready);
					PlayerGunRise(self, autocvar_g_balance_grenadelauncher_gunrise, random() * autocvar_g_balance_grenadelauncher_gunrun);
					self.gl_release = 0;
			  }
			}
		}
		if (!autocvar_g_balance_grenadelauncher_semiauto) {
			self.gl_release = 1;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.gl_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_gl.md3");
		precache_model ("models/weapons/v_gl.md3");
		precache_model ("models/weapons/h_gl.iqm");
		precache_sound ("weapons/grenade_bounce1.wav");
		precache_sound ("weapons/grenade_bounce2.wav");
		precache_sound ("weapons/grenade_bounce3.wav");
		precache_sound ("weapons/grenade_bounce4.wav");
		precache_sound ("weapons/grenade_bounce5.wav");
		precache_sound ("weapons/grenade_bounce6.wav");
		precache_sound ("weapons/grenade_stick.wav");
		precache_sound ("weapons/grenade_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '32 -0.01 -5';
		weapon_setup(WEP_GRENADE_LAUNCHER);
		self.current_ammo = ammo_rockets;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_rockets >= autocvar_g_balance_grenadelauncher_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_GRENADE_LAUNCHER]) >= autocvar_g_balance_grenadelauncher_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_rockets >= autocvar_g_balance_grenadelauncher_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_GRENADE_LAUNCHER]) >= autocvar_g_balance_grenadelauncher_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_grenadelauncher_primary_ammo, autocvar_g_balance_grenadelauncher_secondary_ammo), autocvar_g_balance_grenadelauncher_reload_ammo, autocvar_g_balance_grenadelauncher_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_glauncher(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("grenade_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/grenade_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see their own grenade");
		else
			w_deathtypestring = _("%s blew themself up with their grenadelauncher");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s didn't see %s's grenade");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s almost dodged %s's grenade");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s ate %s's grenade");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_grenadelauncher (void)
//{
//	weapon_defaultspawnfunc(WEP_GRENADE_LAUNCHER);
//}
