
void W_GiveWeapon (entity e, float wep, string name)
{
	entity oldself;

	if (!wep)
		return;

	WEPSET_OR_EW(e, wep);

	oldself = self;
	self = e;

	if not(g_minstagib)
	if (other.classname == "player")
	{
		sprint (other, "You got the ^2");
		sprint (other, name);
		sprint (other, "\n");
	}

	self = oldself;
}

void W_MaybeShootFromEyeForAltAim(entity ent)
{
	//This is mainly for fixing shooting through windows with bullet/shotgun type weapons
	//If this is enabled, the shots will line-up correctly if using alt aim
	if (ent.shootfromaltaim) {
	if (autocvar_g_shootfromfixedorigin_alt_allow) {
	if (autocvar_sv_gameplayfix_bulletholesinglass_alt_shootsfromeye) {
	w_shotdir = v_forward;
	w_shotorg = ent.origin + ent.view_ofs + ((w_shotorg - ent.origin - ent.view_ofs) * v_forward) * v_forward;
	}
	}
	}
}

void W_VehicleDriveByShootingAim(entity vehic, entity gun, entity gunner) {
	if (gun.vehicle_viewport) {
		makevectors(gunner.v_angle);
		w_shotdir = v_forward;
		gunner.vehicle_tempchange_setupshot_origin = gettaginfo(gun.vehicle_viewport, gettagindex(gun.vehicle_viewport, ""));
		gunner.vehicle_tempchange_setupshot = 1;
	} else {
		print(etos(gun), " ", gun.netname, " Error: no proper vehicle_viewport, W_VehicleDriveByShootingAim\n");
	}
}

.float railgundistance;
.vector railgunforce;
void FireRailgunBullet (vector start, vector end, float bdamage, float bforce, float mindist, float maxdist, float halflifedist, float forcehalflifedist, float deathtype)
{
	vector hitloc, force, endpoint, dir;
	entity ent, endent;
	float endq3surfaceflags;
	float totaldmg;
	entity o;

	float length;
	vector beampos;
	string snd;
	entity pseudoprojectile;
	float f, ffs;

	pseudoprojectile = world;

	railgun_start = start;
	railgun_end = end;

	dir = normalize(end - start);
	length = vlen(end - start);
	force = dir * bforce;

	// go a little bit into the wall because we need to hit this wall later
	end = end + dir;

	totaldmg = 0;

	// trace multiple times until we hit a wall, each obstacle will be made
	// non-solid so we can hit the next, while doing this we spawn effects and
	// note down which entities were hit so we can damage them later
	o = self;
	while (1)
	{
		if(self.antilag_debug)
			WarpZone_traceline_antilag (self, start, end, FALSE, o, self.antilag_debug);
		else
			WarpZone_traceline_antilag (self, start, end, FALSE, o, ANTILAG_LATENCY(self));
		if(o && WarpZone_trace_firstzone)
		{
			o = world;
			continue;
		}

		if(trace_ent.solid == SOLID_BSP || trace_ent.solid == SOLID_SLIDEBOX)
			Damage_DamageInfo(trace_endpos, bdamage, 0, 0, force, deathtype, trace_ent.species, self);

		// if it is world we can't hurt it so stop now
		if (trace_ent == world || trace_fraction == 1)
			break;

		// make the entity non-solid so we can hit the next one
		trace_ent.railgunhit = TRUE;
		trace_ent.railgunhitloc = end;
		trace_ent.railgunhitsolidbackup = trace_ent.solid;
		trace_ent.railgundistance = vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos) - start);
		trace_ent.railgunforce = WarpZone_TransformVelocity(WarpZone_trace_transform, force);

		// stop if this is a wall
		if (trace_ent.solid == SOLID_BSP)
			break;

		// make the entity non-solid
		trace_ent.solid = SOLID_NOT;
	}

	endpoint = trace_endpos;
	endent = trace_ent;
	endq3surfaceflags = trace_dphitq3surfaceflags;

	// find all the entities the railgun hit and restore their solid state
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// restore their solid type
		ent.solid = ent.railgunhitsolidbackup;
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// spawn a temporary explosion entity for RadiusDamage calls
	//explosion = spawn();

	// Find all non-hit players the beam passed close by
	if(deathtype == WEP_MINSTANEX || deathtype == WEP_NEX)
	{
		FOR_EACH_REALCLIENT(msg_entity) if(msg_entity != self) if(!msg_entity.railgunhit) if not(msg_entity.classname == "spectator" && msg_entity.enemy == self) // we use realclient, so spectators can hear the whoosh too
		{
			// nearest point on the beam
			beampos = start + dir * bound(0, (msg_entity.origin - start) * dir, length);

			f = bound(0, 1 - vlen(beampos - msg_entity.origin) / 512, 1);
			if(f <= 0)
				continue;

			snd = strcat("weapons/nexwhoosh", ftos(floor(random() * 3) + 1), ".wav");

			if(!pseudoprojectile)
				pseudoprojectile = spawn(); // we need this so the sound uses the "entchannel4" volume
			soundtoat(MSG_ONE, pseudoprojectile, beampos, CH_SHOTS, snd, VOL_BASE * f, ATTN_NONE);
		}

		if(pseudoprojectile)
			remove(pseudoprojectile);
	}

	// find all the entities the railgun hit and hurt them
	ent = findfloat(world, railgunhit, TRUE);
	while (ent)
	{
		// get the details we need to call the damage function
		hitloc = ent.railgunhitloc;

		f = ExponentialFalloff(mindist, maxdist, halflifedist, ent.railgundistance);
		ffs = ExponentialFalloff(mindist, maxdist, forcehalflifedist, ent.railgundistance);

		if(accuracy_isgooddamage(self.realowner, ent))
			totaldmg += bdamage * f;

		// apply the damage
		if (ent.takedamage)
			Damage (ent, self, self, bdamage * f, deathtype, hitloc, ent.railgunforce * ffs);

		// create a small explosion to throw gibs around (if applicable)
		//setorigin (explosion, hitloc);
		//RadiusDamage (explosion, self, 10, 0, 50, world, 300, deathtype);

		ent.railgunhitloc = '0 0 0';
		ent.railgunhitsolidbackup = SOLID_NOT;
		ent.railgunhit = FALSE;
		ent.railgundistance = 0;

		// advance to the next entity
		ent = findfloat(ent, railgunhit, TRUE);
	}

	// calculate hits and fired shots for hitscan
	accuracy_add(self, self.weapon, 0, min(bdamage, totaldmg));

	trace_endpos = endpoint;
	trace_ent = endent;
	trace_dphitq3surfaceflags = endq3surfaceflags;
}

.float dmg_edge;
.float dmg_edge2;
.float dmg_force;
.float dmg_radius;
.float dmg_total;
void W_BallisticBullet_Hit (void)
{
	float f, q, g;

	f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
	q = 1 + self.dmg_edge / self.dmg;

	if(other.solid == SOLID_BSP || other.solid == SOLID_SLIDEBOX || other.solid == SOLID_CORPSE || ((other.flags & FL_MONSTER) && (other.solid == SOLID_BBOX)))
	{
		//Changed this to also trigger for corpses
		//And set when you hit the world species_reserved
		//so that when you're shooting at a corpse, species 0 (default, human)
		//blood particles don't get attached on account of the world being shot
		//around the corpse
		local float myspecies;
		if (other == world || other.stoned || other.accptcrrdbldspltr) {
			myspecies = SPECIES_RESERVED;
						
			//This below is stuff for blood splatter on walls etc.
			if (self.bullethitliving >= 1) 
			{
			if (vlen(self.origin-self.bullethit_origin) < 320) //Abit more than 256
			{				
				entity selfbeforeviolence; //Our oldself
				//print(ftos(self.bullethit_dmg),"  went through living\n");
				
				if ((self.bullethit_victim) && self.bullethit_victim != world) {
					selfbeforeviolence = self;
					self = self.bullethit_victim;
										
					//Violence_GibSplash_At(selfbeforeviolence.origin, v_forward * 10, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
					Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
					
					if (DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SHOTGUN)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_PUMPSHOTGUN)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SPORTSHOTGUN)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_STREETSWEEPER)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_ITHACASTAKEOUT)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_WINCHESTER1897)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_M1897TRENCHGUN)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_EIGHTGAUGESHOTGUN)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_EIGHTGAUGESAWEDOFF)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_TENGAUGEDOUBLE)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_TENGAUGESAWEDOFF)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SPAS12)
					|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SHOTGUNAUTOMAT)
					) {
						//print("shotgun\n"); //Shotguns are messy
						Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
						Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
						Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
					}
						
				
					if (selfbeforeviolence.bullethit_dmg > 95) {
						//If we're a very powerful shot, maybe more material was pulled out
						Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
					}
					
					////////////////////////////////////////////////////////////////////////////////
					//Some extra if model has set this
					if (other.accptcrrdbldspltr > 1) {
					if (selfbeforeviolence.bullethitliving == 1) //No Corpse, living only
					{
						//print("HERE4\n");
						local float aitr;
						aitr = 0;
						
						while (aitr < other.accptcrrdbldspltr) {
							Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
							aitr ++;
							//print("HERE5\n");
							
							if (selfbeforeviolence.bullethit_dmg > 95) {
								//If we're a very powerful shot, maybe more material was pulled out
								Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
							}
						}
						
						if (DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SHOTGUN)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SPORTSHOTGUN)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_EIGHTGAUGESHOTGUN)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_EIGHTGAUGESAWEDOFF)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_TENGAUGEDOUBLE)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_TENGAUGESAWEDOFF)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SPAS12)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_PUMPSHOTGUN)
						|| DEATH_ISWEAPON(selfbeforeviolence.projectiledeathtype, WEP_SHOTGUNAUTOMAT)
						) {
							aitr = 0;
							while (aitr < other.accptcrrdbldspltr) {
								//print("shotgun\n"); //Shotguns are messy
								Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
								Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
								Violence_GibSplash_At(selfbeforeviolence.origin, selfbeforeviolence.velocity, 2, selfbeforeviolence.bullethit_dmg, self.bullethit_victim, selfbeforeviolence);
								aitr ++;
								//print("HERE6\n");
							}
						}
					}
					}
					//engine seems more reluctant to put decals on models often
					//thus this, more or less, hack
					////////////////////////////////////////////////////////////////////////////////
					
					self = selfbeforeviolence;
				}
			}
			}
		} else {
			myspecies = other.species;
			
			//The below is for blood splatter on walls, we just went through some
			//living thing, we will record info if said thing is not frozen, turned to stone, etc
			if(!other.frozen)
			if(!other.freezetag_frozen)
			if(!other.stoned)
			if(other.flags & FL_MONSTER || other.classname == "player" || other.classname == "body" )
			if (DamageTargIsNotWithinGrace(other))
			{
				//If we are not frozen or stone, maybe there will be blood splatter
				//if we hit a wall next. We thusly record info.
				if (other.solid == SOLID_CORPSE) {
					self.bullethitliving = 2; //Don't want to possibly overdo blood for the sake of a corpse
				} else {
					self.bullethitliving = 1;
				}
				self.bullethit_species = other.species;
				self.bullethit_origin = self.origin;
				self.bullethit_victim = other;
				self.bullethit_velocity = self.velocity;
				self.bullethit_dmg = self.dmg * f;
				self.bullethit_dmgforce = self.dmg_force;
			}
		}
		Damage_DamageInfo(self.origin, self.dmg * f, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * f, self.projectiledeathtype, myspecies, self);
	}
	
	if(other && other != self.enemy)
	{
		endzcurveparticles();

		headshot = 0;
		coreshot = 0;
		yoda = 0;
		damage_headshotbonus = self.dmg_edge * f;
		damage_coreshotbonus = self.dmg_edge2 * f; //can I do this? add a dmg_edge2?
		railgun_start = self.origin - 2 * frametime * self.velocity;
		railgun_end = self.origin + 2 * frametime * self.velocity;
		g = accuracy_isgooddamage(self.realowner, other);
		Damage(other, self, self.realowner, self.dmg * f, self.projectiledeathtype, self.origin, self.dmg_force * normalize(self.velocity) * f);
		damage_headshotbonus = 0;
		damage_coreshotbonus = 0;

		if(headshot)
			f *= q;
		if(self.dmg_edge > 0)
		{
			if(headshot)
				AnnounceTo(self.realowner, "headshot");
			if(yoda)
				AnnounceTo(self.realowner, "awesome");
		}

		// calculate hits for ballistic weapons
		if(g)
		{
			// do not exceed 100%
			q = min(self.dmg * q, self.dmg_total + f * self.dmg) - self.dmg_total;
			self.dmg_total += f * self.dmg;
			accuracy_add(self.realowner, self.realowner.weapon, 0, q);
		}
	}

	self.enemy = other; // don't hit the same player twice with the same bullet
}

.void(void) W_BallisticBullet_LeaveSolid_think_save;
.float W_BallisticBullet_LeaveSolid_nextthink_save;
.vector W_BallisticBullet_LeaveSolid_origin;
.vector W_BallisticBullet_LeaveSolid_velocity;

void W_BallisticBullet_LeaveSolid_think()
{
	setorigin(self, self.W_BallisticBullet_LeaveSolid_origin);
	self.velocity = self.W_BallisticBullet_LeaveSolid_velocity;

	self.think = self.W_BallisticBullet_LeaveSolid_think_save;
	self.nextthink = max(time, self.W_BallisticBullet_LeaveSolid_nextthink_save);
	self.W_BallisticBullet_LeaveSolid_think_save = func_null;

	self.flags &~= FL_ONGROUND;

	if(self.enemy.solid == SOLID_BSP)
	{
		float f;
		f = pow(bound(0, vlen(self.velocity) / vlen(self.oldvelocity), 1), 2); // energy multiplier
		Damage_DamageInfo(self.origin, 0, 0, 0, max(1, self.dmg_force) * normalize(self.velocity) * -f, self.projectiledeathtype, 0, self);
	}

	UpdateCSQCProjectile(self);
}

float W_EvaluateMaterialHit (void)
{
	//Thanks to Spoike for the idea for the implementation of the caching
	//print(strcat(self.realowner.netname, " texture ", trace_dphittexturename, " etc\n"));
	float texvalue;
	string tvs;
	
	texvalue = 0;
	tvs = strcat("texvalue_", trace_dphittexturename);
	
	//This check eliminates console spam: thanks Mario!
	if(cvar_type(tvs) & CVAR_TYPEFLAG_EXISTS) 
	{
		texvalue = cvar(tvs);
	}
	
	if (texvalue == 100) {
		//print("EvaluateMaterialHit: 100 (Normal material )\n");
		//100 is normal material (0), see below, can't use 0 in the variable as we use that to check if the var exists or not
		return 0;
	} else if(texvalue) {
		//print("EvaluateMaterialHit: ",ftos(texvalue),"-value\n");
		return texvalue;
	} else {
		//print("EvaluateMaterialHit: No value set, determining\n");
		if (trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS) {
			//print("Metal By Q3Flags\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "1");
			return 1;
		} else if (
		( strstrofs(trace_dphittexturename, "mtl", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "metal", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "Metal", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "clang", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "rust", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "e7beam", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "e8beam", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "e8trim", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "e8jump", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/e8_", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk1x/panel", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk1x/wall", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk1x/vent", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk1x/trim", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/celing", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/base", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/decal", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/computer", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/floor", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/panel", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/phillipk2x/wall", 0) != -1 )
		 ) {
			//print("Metal\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "2");
			return 2;
		} else if (
		( strstrofs(trace_dphittexturename, "stone", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "rock", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "cliff", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "marble", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "granite", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "mtiles", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "gtiles", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "Marble", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "marble", 0) != -1 )
		) {
			//print("Stone\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "3");
			return 3;
		} else if (
		( strstrofs(trace_dphittexturename, "brick", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "clay", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "mason", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "citytile", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "temp_road", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "0ad_road/road", 0) != -1 )
		) {
			//print("Brick\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "4");
			return 4;
		} else if (
		( strstrofs(trace_dphittexturename, "crete", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "cement", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "cemtile", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "CRETE", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "_coral_", 0) != -1 )
		) {
			//print("Concrete\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "5");
			return 5;
		} else if (
		( strstrofs(trace_dphittexturename, "glass", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "screen", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "window", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "map_red-planet/env", 0) != -1 )
		) {
			//print("Glass\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "6");
			return 6;
		} else if (
		( strstrofs(trace_dphittexturename, "grass", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "sand", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "dirt", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "snow", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "ground", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "terrain", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "lakebed", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "pebbles", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "farmland", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "_plants_", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "riparian", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "_mud_", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "beach", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "swamp", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "tundra", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "desert_rough", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "river_rocks", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "forrestfloor", 0) != -1 )
		) {
			//print("Dirt\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "7");
			return 7;
		} else if (
		( strstrofs(trace_dphittexturename, "wood", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "WOOD", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "Wood", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "bark", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "/wd_", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "caethaver2_ceiling/ceiling", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "evil3_roofs/sroof", 0) != -1 )
		) {
			//print("Wood\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "8");
			return 8;
		} else if (
		( strstrofs(trace_dphittexturename, "sheetrock", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "vinyl", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "vertsiding", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "officeceiling", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "cardboard", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "paper", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "dropceli", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "desertfactory_misc/light", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "desertfactory_misc/white", 0) != -1 )
		|| ( strstrofs(trace_dphittexturename, "evil3_roofs/ceil-", 0) != -1 )
		) {
			//print("Sheetrock\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "9");
			return 9;
		} else if (
		( strstrofs(trace_dphittexturename, "board", 0) != -1 )
		) {
			//Any other board other than cardboard we will assume is wood
			//print("Wood Board\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "8");
			return 8;
		} else {
			//print("Standard Material\n");
			registercvar((strcat("texvalue_", trace_dphittexturename)), "100"); //zero reservered for not evaluated
			return 0;
		}
	}
}

float W_BallisticBulletSetConstant(float selfcount, float currentvalue)
{
		float newconstant;
		float hitmaterial;
		hitmaterial = W_EvaluateMaterialHit();
		
		switch(hitmaterial)
		{
		case 1:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_metal / selfcount;
			break;
		case 2:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_metal / selfcount;
			break;
		case 3:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_stone / selfcount;
			break;
		case 4:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_brick / selfcount;
			break;
		case 5:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_concrete / selfcount;
			break;
		case 6:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_glass / selfcount;
			break;
		case 7:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_dirt / selfcount;
			break;
		case 8:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_wood / selfcount;
			break;
		case 9:
			newconstant = autocvar_g_ballistics_materialconstant * autocvar_g_ballistics_density_sheetrock / selfcount;
			break;
		default:
			//Otherwise change nothing
			newconstant = currentvalue;
			break;
		}
		return newconstant;
}

float W_BallisticBullet_HoleInGlassClose(entity mybullet, float myradius, float mymaxthickness)
{
	local entity f;
	f = findradius(mybullet.origin, myradius);
  	while(f)
  	{
		if (f.classname == "glsstmrk")
		{
			if (vlen(trace_endpos - self.origin) < mymaxthickness) {
				//print("Deflection Mitigation, hole in glass close, glass thusly weak\n");
				return TRUE;
			} else {
				//print("Hole in glass found close, but glass too thick\n");
			}
		}
		f = f.chain;
	}
	return FALSE;
}

void W_BallisticBullet_HoleInGlassRemove(void)
{
	local entity enext, eprev;
	enext = self.glsstmrknextchain;
	eprev = self.glsstmrkprevchain;
	
	if(enext != world) {
		enext.glsstmrkprevchain = eprev;
	}
	
	if(eprev != world) {
		eprev.glsstmrknextchain = enext;
	}
	
	
	self.classname = "";
	
	//print("Hole In Glass Remove Self\n");
	
	glsstmrkammnt = glsstmrkammnt - 1;
	if (glsstmrkammnt <= 0) glsstmrkammnt = 0;
	
	if (glsstmrkfirst == self) {
		//Reassign the "first"
		if(enext && enext != world) {
			glsstmrkfirst = enext;
		} else {
			glsstmrkfirst = world;
		}
	}
	
	if (glsstmrklast == self) {
		//Reassign the "last"
		if(eprev && eprev != world) {
			glsstmrklast = eprev;
		} else {
			glsstmrklast = world;
		}
	}
	
	SUB_SetFade (self, time, 2);
}

void W_BallisticBullet_HoleInGlassCheckOther(void)
{
	//print("Checking Other\n");
	
	if (time > self.ammount5) {
		W_BallisticBullet_HoleInGlassRemove();
	} else if (self.subordinate5 ==  world) {
		W_BallisticBullet_HoleInGlassRemove();
	} else if (!self.subordinate5) {
		W_BallisticBullet_HoleInGlassRemove();
	} else {
		if ((time + self.ammount6) > (self.ammount5)) {
			self.nextthink = self.ammount5;
		} else {
			self.nextthink = time + self.ammount6;
		}
	}
}
void W_BallisticBullet_GlassShardSetupRemove(void)
{
	local entity enext, eprev;
	enext = self.glssshrdnextchain;
	eprev = self.glssshrdprevchain;
	
	if(enext != world) {
		enext.glssshrdprevchain = eprev;
	}
	
	if(eprev != world) {
		eprev.glssshrdnextchain = enext;
	}
	
	
	self.classname = "";
	
	//print("Glass Shard Remove Self\n");
	
	glssshrdammnt = glssshrdammnt - 1;
	if (glssshrdammnt <= 0) glssshrdammnt = 0;
	
	if (glssshrdfirst == self) {
		//Reassign the "first"
		if(enext && enext != world) {
			glssshrdfirst = enext;
		} else {
			glssshrdfirst = world;
		}
	}
	
	if (glssshrdlast == self) {
		//Reassign the "last"
		if(eprev && eprev != world) {
			glssshrdlast = eprev;
		} else {
			glssshrdlast = world;
		}
	}
}


void W_BallisticBullet_GlassShardRemove(void)
{
	W_BallisticBullet_GlassShardSetupRemove();
	
	SUB_SetFade (self, time, 2);
}

void W_BallisticBullet_GlassShard_Explode(void)
{
	if (other != world) {
		Damage(other, self, self.realowner, self.dmg, self.projectiledeathtype, self.origin, '0 0 0');
			
			if(!other.frozen)
			if(!other.freezetag_frozen)
			if(!other.stoned)
			if(other.flags & FL_MONSTER || other.classname == "player" || other.classname == "body" )
			if (DamageTargIsNotWithinGrace(other))
			{
				Violence_GibSplash_At(self.origin, self.velocity, 2, self.dmg, other, self);
				Damage_DamageInfo(self.origin, self.dmg, 0, 0, '0 0 0', DEATH_FRAGMENT, other.species, self);
			}
			
		W_BallisticBullet_GlassShardSetupRemove();
		self.solid = SOLID_NOT;
		remove(self);
	}
}

void W_BallisticBullet_GlassShard_Touch(void)
{
	//print(etos(other),"_theother\n");
	
	if (other.classname == "glssshrd")
	{
		//print("Ignore glass shard\n");
		return;
	}
	
	PROJECTILE_TOUCH;
	
	if (other.isabdbld) {
		//print("stopped\n");
		self.solid = SOLID_NOT;
		self.touch = func_null;
	} else if (other.isbldablbld) {
		//print("stopped\n");
		self.solid = SOLID_NOT;
		self.touch = func_null;
	} else if (other.isfurniture) {
		//print("stopped\n");
		self.solid = SOLID_NOT;
		self.touch = func_null;
	} else if (other.takedamage) {
		//print("touch\n");
		self.use();
	} else {
		//print("stopped\n");
		self.solid = SOLID_NOT;
		self.touch = func_null;
	}
}

void W_BallisticBullet_GlassShard_SpallInit(void)
{
	if (
	(pointcontents (self.origin) == CONTENT_SOLID) 
	|| (pointcontents (self.origin+'1 0 0') == CONTENT_SOLID)
	|| (pointcontents (self.origin+'-1 0 0') == CONTENT_SOLID)
	|| (pointcontents (self.origin+'0 1 0') == CONTENT_SOLID)
	|| (pointcontents (self.origin+'0 -1 0') == CONTENT_SOLID)
	|| (pointcontents (self.origin+'0 0 1') == CONTENT_SOLID)
	|| (pointcontents (self.origin+'0 0 -1') == CONTENT_SOLID)
	) {
		if (time > self.ammount7) {
			//print("Go on anyway\n");
		} else {
			//print("Wait\n");
			self.nextthink = time;
			return;
		}
	}
	//print("SpallInitThink\n");
	
	self.dmg = autocvar_sv_gameplayfix_bulletholesinglass_shards_spalldmg;
	self.projectiledeathtype = DEATH_IMPALE;
	PROJECTILE_MAKETRIGGER(self);
	self.touch = W_BallisticBullet_GlassShard_Touch;
	self.use = W_BallisticBullet_GlassShard_Explode;
		
		
	self.think = W_BallisticBullet_GlassShardRemove;
	self.nextthink = time + autocvar_sv_gameplayfix_bulletholesinglass_shards_time;	
	
	setsize(self, '-1 -1 -1', '1 1 1');
}

void W_BallisticBullet_GlassShard_Do (float shardamnt, entity myself, float myskin, float myscale, float myglsscolormap)
{
	entity myglassshard;
	entity oslf;
	float myglshrand;
	myglassshard = spawn();
	myglassshard.origin = myself.origin;
	myglassshard.classname = "glssshrd";
	myglassshard.think = W_BallisticBullet_GlassShardRemove;
	myglassshard.nextthink = time + autocvar_sv_gameplayfix_bulletholesinglass_shards_time;
	
	myglshrand = random();
	if (myglshrand > 0.55) {
		myglassshard.model = "models/glassshardtriangle.iqm";
	} else if (myglshrand > 0.20) {
		myglassshard.model = "models/glassshardtriangle2.iqm";
	} else {
		myglassshard.model = "models/glassshardtriangle3.iqm";
	}
			
	myglassshard.solid = SOLID_NOT;
	myglassshard.movetype = MOVETYPE_TOSS;
	myglassshard.alpha = 0.90;
	myglassshard.scale = myscale;
	myglassshard.angles = randomvec();
	myglassshard.angles_x = (myglassshard.angles_x - 0.5) * 180;
	myglassshard.angles_y = (myglassshard.angles_y - 0.5) * 180;
	myglassshard.angles_z = (myglassshard.angles_z - 0.5) * 180;
	myglassshard.fixangle = 1;
	myglassshard.velocity = myself.velocity;
	myglassshard.velocity_x = myglassshard.velocity_x * (0.025 + (0.025 * random()));
	myglassshard.velocity_y = myglassshard.velocity_y * (0.025 + (0.025 * random()));
	myglassshard.velocity_z = myglassshard.velocity_z * (0.025 + (0.025 * random()));
		//print(vtos(myglassshard.velocity), "___", vtos(myself.velocity), "\n");
	myglassshard.skin = myskin;
	if (myglsscolormap) myglassshard.colormap = myglsscolormap;
	
	if (autocvar_sv_gameplayfix_bulletholesinglass_shards_spalldmg > 0) 
	{
		myglassshard.realowner = self.realowner;
		myglassshard.think = W_BallisticBullet_GlassShard_SpallInit;
		myglassshard.nextthink = time;
		myglassshard.ammount7 = time + 0.5;
	}
	setorigin (myglassshard, myglassshard.origin);
	
			oslf = self;
			self = myglassshard;
			spawnfunc_misc_gamemodel();
			self = oslf;	
		
	//print(ftos(myglassshard.skin), "_myskin\n");
	
			glssshrdammnt = glssshrdammnt + 1;
			
			//The first
			if (glssshrdfirst && (glssshrdfirst != world)) {
				//Do nothing, we have a first in existance
			} else {
				glssshrdfirst = myglassshard;
			}
			
			//The Last
			if (glssshrdlast && (glssshrdlast != world)) {
				glssshrdlast.glssshrdnextchain = myglassshard;
				myglassshard.glssshrdprevchain = glssshrdlast;
				glssshrdlast = myglassshard;
			} else {
				glssshrdlast = myglassshard;
			}
			
			if (glssshrdammnt > autocvar_sv_gameplayfix_bulletholesinglass_shards_max) {
				//print(ftos(glssshrdammnt), "Reached Max Shards\n");
				local entity gmfe, gmrm;
				if (glssshrdfirst && (glssshrdfirst != world)) {
					//print("Reached Max Glass Shards Removing First\n");
					
					gmfe = glssshrdfirst.glssshrdnextchain;
					gmrm = glssshrdfirst;
					
					if (gmfe != world) {
						glssshrdfirst = gmfe;
					} else {
						//print("ERROR: Glass shard first is world\n");
					}
					
					gmrm.classname = "";
					
					if (gmrm.glssshrdnextchain.glssshrdprevchain) {
						gmrm.glssshrdnextchain.glssshrdprevchain = world;
					} else {
						//print("Strangish: Glass next, prev...\n");
					}
					
					remove(gmrm);
					glssshrdammnt = glssshrdammnt - 1;
					if (glssshrdammnt <= 0) glssshrdammnt = 0;
				}
			}
}

void W_BallisticBullet_GlassShard (float shardamnt, entity myself, float myskin, float myscale, float myglsscolormap)	
{
	float a = 0;
	while (a < shardamnt) {
		W_BallisticBullet_GlassShard_Do (shardamnt, myself, myskin, myscale, myglsscolormap);
		a++;
	}
}

.float csqcprojectile_type;
float W_BallisticBullet_LeaveSolid(float eff)
{
	// move the entity along its velocity until it's out of solid, then let it resume
	vector vel = self.velocity;
	float dt, dst, velfactor, v0, vs;
	float maxdist;
	float E0_m, Es_m;
	float constant = self.dmg_radius * (other.ballistics_density ? other.ballistics_density : 1);

	// outside the world? forget it
	if(self.origin_x > world.maxs_x || self.origin_y > world.maxs_y || self.origin_z > world.maxs_z || self.origin_x < world.mins_x || self.origin_y < world.mins_y || self.origin_z < world.mins_z)
		return 0;

	// special case for zero density and zero bullet constant: 

	if(self.dmg_radius == 0)
	{
		if(other.ballistics_density < 0)
			constant = 0; // infinite travel distance
		else
			return 0; // no penetration
	}
	else
	{
		if(other.ballistics_density < 0)
			constant = 0; // infinite travel distance
		else if(other.ballistics_density == 0)
			constant = self.dmg_radius;
		else
			constant = self.dmg_radius * other.ballistics_density;
	}

	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	v0 = vlen(vel);

	E0_m = 0.5 * v0 * v0;

	if(constant)
	{
		maxdist = E0_m / constant;
		// maxdist = 0.5 * v0 * v0 / constant
		// dprint("max dist = ", ftos(maxdist), "\n");

		if(maxdist <= autocvar_g_ballistics_mindistance)
			return 0;
	}
	else
	{
		maxdist = vlen(other.maxs - other.mins) + 1; // any distance, as long as we leave the entity
	}

	traceline_inverted (self.origin, self.origin + normalize(vel) * maxdist, MOVE_NORMAL, self, TRUE);
	if(trace_fraction == 1) // 1: we never got out of solid
		return 0;

	self.W_BallisticBullet_LeaveSolid_origin = trace_endpos;
	
	////Start ChaosEsque Stuff
	//We don't want the player to beable to shoot out of a brush with
	//a weak material on his side and a strong material on the otherside
	//to a greater degree than the stronger side would allow
	entity myglassshotmarker;
	entity oslf;
	if((self.dmg_radius > 0) && (other.ballistics_density == 0)) {
		//We are just, say, a textured wall, not an entity with density set
		float hitmaterial;
		hitmaterial = W_EvaluateMaterialHit();
	
		float nuconstant;
		nuconstant = W_BallisticBulletSetConstant(self.count, self.dmg_radius);
		if (constant < nuconstant) {
			constant = nuconstant;
			//Strongest Material Wins
		} else if (hitmaterial == 6 && constant == nuconstant && autocvar_sv_gameplayfix_bulletholesinglass) {
			//Add cvar gameplayfix_ etc to turn on/off etc
			//Glass, both sides
			//Below: (thebullet, radiustosearch, toothickglass)
			if (autocvar_sv_gameplayfix_bulletholesinglass_deflectionmitigation) {
				if (W_BallisticBullet_HoleInGlassClose(self, autocvar_sv_gameplayfix_bulletholesinglass_searchradius, autocvar_sv_gameplayfix_bulletholesinglass_maxthickness))
				{
					//print(ftos(constant), "_Before Broken Glass\n");
					
					constant = constant * autocvar_sv_gameplayfix_bulletholesinglass_deflectionmitigation_rate; //Toughness of the glass reduced if near broken area
					
					//print(ftos(constant), "_After Broken Glass\n");
				}
			}
			
			//print(etos(other),"_The other\n");
			
			myglassshotmarker = spawn();

			////myglassshotmarker.origin = self.origin; //Next: put between the 2 origins.
			myglassshotmarker.origin_x = (trace_endpos_x * 0.5) + (self.origin_x * 0.5);
			myglassshotmarker.origin_y = (trace_endpos_y * 0.5) + (self.origin_y * 0.5);
			myglassshotmarker.origin_z = (trace_endpos_z * 0.5) + (self.origin_z * 0.5);
			myglassshotmarker.classname = "glsstmrk";
			myglassshotmarker.think = W_BallisticBullet_HoleInGlassRemove;
			myglassshotmarker.nextthink = time + autocvar_sv_gameplayfix_bulletholesinglass_time;
			myglassshotmarker.model = "models/decalbulletholeglass.iqm";
			////myglassshotmarker.effects |= EF_DOUBLESIDED; //Not needed, did on model
			////myglassshotmarker.effects |= EF_FULLBRIGHT; //Doesn't help
			////myglassshotmarker.effects |= EF_ADDITIVE; //Allready set in shader
			myglassshotmarker.solid = SOLID_NOT;
			myglassshotmarker.alpha = 0.90;
			
			//These scales are the same as in client/projectiles.qc
			if (self.csqcprojectile_type == PROJECTILE_BULLET) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET_GLOWING) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET_GLOWING_TRACER) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETWEBLEY) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET45ACP) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET50AE) {
				myglassshotmarker.scale = 1.11;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETSHOTGUN) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET9MM) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET357MAG) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLET44MAG) {
				myglassshotmarker.scale = 1;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE22) {
				myglassshotmarker.scale = 0.488;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE25) {
				myglassshotmarker.scale = 0.555;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE9MM) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE9MM_G) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE9MM_G_T) {
				myglassshotmarker.scale = 0.77;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE50) {
				myglassshotmarker.scale = 1.11;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE50S) {
				myglassshotmarker.scale = 1.11;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE50_G) {
				myglassshotmarker.scale = 1.11;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE50_G_T) {
				myglassshotmarker.scale = 1.11;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE17MM) {
				myglassshotmarker.scale = 1.46;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE20MM) {
				myglassshotmarker.scale = 1.72;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETRIFLE30MM) {
				myglassshotmarker.scale = 2.58;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETSHRAPNEL) {
				myglassshotmarker.scale = 2;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETSHRAPNELSHINE) {
				myglassshotmarker.scale = 2;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETSHRAPNELDARK) {
				myglassshotmarker.scale = 2;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETSHRAPNELHOT) {
				myglassshotmarker.scale = 2;
			} else if (self.csqcprojectile_type == PROJECTILE_BULLETNAGANT) {
				myglassshotmarker.scale = 0.77;
			} else {
				myglassshotmarker.scale = 1; //Fallback default
			}
			
			//print(ftos(self.csqcprojectile_type), "_Projtype\n");
			
			myglassshotmarker.angles = vectoangles(trace_plane_normal);
			myglassshotmarker.angles_x = myglassshotmarker.angles_x * -1;

			if (other != world) {
				if (other.isabdbld) {
					//Do nothing
					myglassshotmarker.ammount6 = 10;
				} else if (other.isbldablbld) {
					//Do nothing
					myglassshotmarker.ammount6 = 5; //Easier to destroy so check more often
				} else {
					//Might be a mover...
					myglassshotmarker.origin_x = myglassshotmarker.origin_x - other.origin_x;
					myglassshotmarker.origin_y = myglassshotmarker.origin_y - other.origin_y;
					myglassshotmarker.origin_z = myglassshotmarker.origin_z - other.origin_z;
					setorigin (myglassshotmarker, myglassshotmarker.origin);
					setattachment(myglassshotmarker, other, "");
					myglassshotmarker.ammount6 = 1;
				}
				
				if (myglassshotmarker.ammount6 > autocvar_sv_gameplayfix_bulletholesinglass_time) {
					myglassshotmarker.ammount6 = autocvar_sv_gameplayfix_bulletholesinglass_time;
				}
				
				myglassshotmarker.think = W_BallisticBullet_HoleInGlassCheckOther;
				myglassshotmarker.nextthink = time + myglassshotmarker.ammount6;
				myglassshotmarker.ammount5 = time + autocvar_sv_gameplayfix_bulletholesinglass_time;
				myglassshotmarker.subordinate5 = other;
			} else {
				setorigin (myglassshotmarker, self.origin);
			}
			
			local float mygrandm;
			mygrandm = random();
			if (mygrandm > 0.55) {
				spamsound (myglassshotmarker, CH_SHOTS, "glassbreaking/mirrorbreaking.ogg", VOL_BASE, ATTN_NORM);
			} else if (mygrandm > 0.20) {
				spamsound (myglassshotmarker, CH_SHOTS, "glassbreaking/glassbreaking.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (myglassshotmarker, CH_SHOTS, "glassbreaking/lightbulbbreaking.ogg", VOL_BASE, ATTN_NORM);
			}
			
			oslf = self;
			self = myglassshotmarker;
			spawnfunc_misc_gamemodel();
			self = oslf;	
			
			glsstmrkammnt = glsstmrkammnt + 1;
			
			//The first
			if (glsstmrkfirst && (glsstmrkfirst != world)) {
				//Do nothing, we have a first in existance
			} else {
				glsstmrkfirst = myglassshotmarker;
			}
			
			//The Last
			if (glsstmrklast && (glsstmrklast != world)) {
				glsstmrklast.glsstmrknextchain = myglassshotmarker;
				myglassshotmarker.glsstmrkprevchain = glsstmrklast;
				glsstmrklast = myglassshotmarker;
			} else {
				glsstmrklast = myglassshotmarker;
			}
			
			if (glsstmrkammnt > autocvar_sv_gameplayfix_bulletholesinglass_max) {
				//print(ftos(glsstmrkammnt), "Reached Max Holes\n");
				local entity gmfe, gmrm;
				if (glsstmrkfirst && (glsstmrkfirst != world)) {
					//print("Reached Max Holes In Glass Removing First\n");

					gmfe = glsstmrkfirst.glsstmrknextchain;
					gmrm = glsstmrkfirst;
					glsstmrkfirst = gmfe;
					gmrm.classname = "";
					gmrm.glsstmrknextchain.glsstmrkprevchain = world;
					remove(gmrm);
					glsstmrkammnt = glsstmrkammnt - 1;
					if (glsstmrkammnt <= 0) glsstmrkammnt = 0;
				}
			}
			
			if (autocvar_sv_gameplayfix_bulletholesinglass_shards >= 1) {
				local float myglssskin;
				local float myglsscolormap = 0;
				if ( strstrofs(trace_dphittexturename, "glasspane2", 0) != -1 ) {
					myglssskin = 2;
				} else if ( strstrofs(trace_dphittexturename, "glasspane3", 0) != -1 ) {
					myglssskin = 3;
				} else if ( strstrofs(trace_dphittexturename, "glasspane4", 0) != -1 ) {
					myglssskin = 4;
				} else if ( strstrofs(trace_dphittexturename, "glasspane5", 0) != -1 ) {
					myglssskin = 5;
				} else if ( strstrofs(trace_dphittexturename, "glasspane6", 0) != -1 ) {
					myglssskin = 6;
				} else if ( strstrofs(trace_dphittexturename, "glasspane7", 0) != -1 ) {
					myglssskin = 7;
				} else if ( strstrofs(trace_dphittexturename, "glasspane8", 0) != -1 ) {
					myglssskin = 8;
				} else if ( strstrofs(trace_dphittexturename, "glasspane9", 0) != -1 ) {
					myglssskin = 9;
				} else if ( strstrofs(trace_dphittexturename, "glasspane10CM", 0) != -1 ) {
					myglssskin = 25;
					if (other != world) {
						if (other.colormap) {
							myglsscolormap = other.colormap;
						}
					}
				} else if ( strstrofs(trace_dphittexturename, "glasspane10", 0) != -1 ) {
					myglssskin = 10;
				} else if ( strstrofs(trace_dphittexturename, "glasspaneCM", 0) != -1 ) {
					myglssskin = 11;
					if (other != world) {
						if (other.colormap) {
							myglsscolormap = other.colormap;
						}
					}
				} else if ( strstrofs(trace_dphittexturename, "glasspane1", 0) != -1 ) {
					myglssskin = 1;
				} else if ( strstrofs(trace_dphittexturename, "ame7glass", 0) != -1 ) {
					myglssskin = 12;
				} else if ( strstrofs(trace_dphittexturename, "stained_glass_nexlogo_blue", 0) != -1 ) {
					myglssskin = 13;
				} else if ( strstrofs(trace_dphittexturename, "map_solarium", 0) != -1 ) {
					myglssskin = 26;
				} else if ( strstrofs(trace_dphittexturename, "map_red-planet", 0) != -1 ) {
					myglssskin = 27;
				} else if ( strstrofs(trace_dphittexturename, "glasspaneorange", 0) != -1 ) {
					myglssskin = 15;
				} else if ( strstrofs(trace_dphittexturename, "glasspanecyan", 0) != -1 ) {
					myglssskin = 16;
				} else if ( strstrofs(trace_dphittexturename, "glasspanerose", 0) != -1 ) {
					myglssskin = 17;
				} else if ( strstrofs(trace_dphittexturename, "glasspanered", 0) != -1 ) {
					myglssskin = 18;
				} else if ( strstrofs(trace_dphittexturename, "glasspanemagenta", 0) != -1 ) {
					myglssskin = 19;
				} else if ( strstrofs(trace_dphittexturename, "glasspanepurple", 0) != -1 ) {
					myglssskin = 20;
				} else if ( strstrofs(trace_dphittexturename, "glasspanelightgreen", 0) != -1 ) {
					myglssskin = 21;
				} else if ( strstrofs(trace_dphittexturename, "glasspaneburntyellow", 0) != -1 ) {
					myglssskin = 22;
				} else if ( strstrofs(trace_dphittexturename, "glasspaneroyalblue", 0) != -1 ) {
					myglssskin = 23;
				} else if ( strstrofs(trace_dphittexturename, "glasspaneyellow", 0) != -1 ) {
					myglssskin = 24;
				} else if ( strstrofs(trace_dphittexturename, "stained_glass", 0) != -1 ) {
					myglssskin = 14;
				} else if ( strstrofs(trace_dphittexturename, "window3", 0) != -1 ) {
					myglssskin = 10;
				} else if ( strstrofs(trace_dphittexturename, "magenta", 0) != -1 ) {
					myglssskin = 19;
				} else if ( strstrofs(trace_dphittexturename, "yellow", 0) != -1 ) {
					if ( strstrofs(trace_dphittexturename, "dark", 0) != -1 ) {
						myglssskin = 7;
					} else if ( strstrofs(trace_dphittexturename, "dull", 0) != -1 ) {
						myglssskin = 7;
					} else if ( strstrofs(trace_dphittexturename, "bright", 0) != -1 ) {
						myglssskin = 24;
					} else if ( strstrofs(trace_dphittexturename, "light", 0) != -1 ) {
						myglssskin = 24;
					} else if ( strstrofs(trace_dphittexturename, "burn", 0) != -1 ) {
						myglssskin = 22;
					} else if ( strstrofs(trace_dphittexturename, "orange", 0) != -1 ) {
						myglssskin = 22;
					} else {
						if (random() > 0.5) {
							myglssskin = 24; //light, saturated
						} else {
							myglssskin = 7;
						}
					}
				} else if ( strstrofs(trace_dphittexturename, "orange", 0) != -1 ) {
					myglssskin = 15;
				} else if ( strstrofs(trace_dphittexturename, "purple", 0) != -1 ) {
					myglssskin = 21;
				} else if ( strstrofs(trace_dphittexturename, "black", 0) != -1 ) {
					myglssskin = 1;
				} else if ( strstrofs(trace_dphittexturename, "green", 0) != -1 ) {
					if ( strstrofs(trace_dphittexturename, "light", 0) != -1 ) {
						myglssskin = 21;
					} else if ( strstrofs(trace_dphittexturename, "dark", 0) != -1 ) {
						myglssskin = 6;
					} else if ( strstrofs(trace_dphittexturename, "dull", 0) != -1 ) {
						myglssskin = 6;
					} else {
						if (random() > 0.5) {
							myglssskin = 21;
						} else {
							myglssskin = 6;
						}
					}
				} else if ( strstrofs(trace_dphittexturename, "white", 0) != -1 ) {
					myglssskin = 8;
				} else if ( strstrofs(trace_dphittexturename, "blue", 0) != -1 ) {
					if ( strstrofs(trace_dphittexturename, "royal", 0) != -1 ) {
						myglssskin = 23;
					} else if ( strstrofs(trace_dphittexturename, "light", 0) != -1 ) {
						myglssskin = 9;
					} else if ( strstrofs(trace_dphittexturename, "sky", 0) != -1 ) {
						myglssskin = 9;
					} else if ( strstrofs(trace_dphittexturename, "dark", 0) != -1 ) {
						myglssskin = 4;
					} else if ( strstrofs(trace_dphittexturename, "dull", 0) != -1 ) {
						myglssskin = 4;
					} else {
						if (random() > 0.5) {
							myglssskin = 23;
						} else {
							myglssskin = 4;
						}
					}
				} else if ( strstrofs(trace_dphittexturename, "grey", 0) != -1 ) {
					myglssskin = 2;
				} else if ( strstrofs(trace_dphittexturename, "gray", 0) != -1 ) {
					myglssskin = 2;
				} else if ( strstrofs(trace_dphittexturename, "cyan", 0) != -1 ) {
					myglssskin = 16;
				} else if ( strstrofs(trace_dphittexturename, "rose", 0) != -1 ) {
					myglssskin = 17;
				} else if ( strstrofs(trace_dphittexturename, "red", 0) != -1 ) {
					if ( strstrofs(trace_dphittexturename, "bright", 0) != -1 ) {
						myglssskin = 18;
					} else if ( strstrofs(trace_dphittexturename, "blood", 0) != -1 ) {
						myglssskin = 18;
					} else if ( strstrofs(trace_dphittexturename, "dark", 0) != -1 ) {
						myglssskin = 5;
					} else if ( strstrofs(trace_dphittexturename, "dull", 0) != -1 ) {
						myglssskin = 5;
					} else {
						if (random() > 0.5) {
							myglssskin = 18;
						} else {
							myglssskin = 5;
						}
					}
				} else {
					myglssskin = 8;
				}
				
				//print(trace_dphittexturename, "_txname ", ftos(myglssskin), "_mygskin\n");
				
				W_BallisticBullet_GlassShard (autocvar_sv_gameplayfix_bulletholesinglass_shards, self, myglssskin, myglassshotmarker.scale, myglsscolormap);	
			}
		}
	}
	////End ChaosEsque Stuff

	dst = max(autocvar_g_ballistics_mindistance, vlen(trace_endpos - self.origin));
	// E(s) = E0 - constant * s, constant = area of bullet circle * material constant / mass
	Es_m = E0_m - constant * dst;
	if(Es_m <= 0)
	{
		// roundoff errors got us
		return 0;
	}
	vs = sqrt(2 * Es_m);
	velfactor = vs / v0;

	dt = dst / (0.5 * (v0 + vs));
	// this is not correct, but the differential equations have no analytic
	// solution - and these times are very small anyway
	//print("dt = ", ftos(dt), "\n");

	self.W_BallisticBullet_LeaveSolid_think_save = self.think;
	self.W_BallisticBullet_LeaveSolid_nextthink_save = self.nextthink;
	self.think = W_BallisticBullet_LeaveSolid_think;
	self.nextthink = time + dt;

	vel = vel * velfactor;

	self.velocity = '0 0 0';
	self.flags |= FL_ONGROUND; // prevent moving
	self.W_BallisticBullet_LeaveSolid_velocity = vel;

	if(eff >= 0)
		if(vlen(trace_endpos - self.origin) > 4)
		{
			endzcurveparticles();
			trailparticles(self, eff, self.origin, trace_endpos);
		}

	return 1;
}



float automatic_pipe_type;
float automatic_pipe_type_mapinfoevaluated;

#define AUTOMATICPIPETYPE_STEAM 1
#define AUTOMATICPIPETYPE_FIRE 2
#define AUTOMATICPIPETYPE_FIREANDSTEAM 3
#define AUTOMATICPIPETYPE_ICE 4
#define AUTOMATICPIPETYPE_WATER 5
#define AUTOMATICPIPETYPE_POISON 6
#define AUTOMATICPIPETYPE_LASER 7
#define AUTOMATICPIPETYPE_FIREANDICE 8

void W_AutoEvaluatePipeTypeByMapInfo(void)
{
	if (automatic_pipe_type) {
		return;
	}
	
	if (automatic_pipe_type_mapinfoevaluated) {
		return;
	}
	
	if not(autocvar_g_allpiercingcausesautomatic_frompipes) {
		return;
	}
	
	
		
	automatic_pipe_type_mapinfoevaluated = 1;
	
	//print(mapname, "_mapname\n");
	
	if (strstrofs(mapname, "blue", 0) != -1 ) {
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	} else if ((strstrofs(mapname, "slime", 0) != -1 )
	&& (!(strstrofs(mapname, "after", 0) != -1 )))
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
	} else if (strstrofs(mapname, "diesel", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_FIREANDSTEAM;
	} else if (strstrofs(mapname, "poison", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
	} else if (
	(strstrofs(mapname, "oil", 0) != -1 )
	|| (strstrofs(mapname, "burning", 0) != -1 )
	|| (strstrofs(mapname, "petrol", 0) != -1 )
	|| (strstrofs(mapname, "gasoline", 0) != -1 )
	|| (strstrofs(mapname, "kerosene", 0) != -1 )
	|| (strstrofs(mapname, "benzene", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_FIREANDSTEAM;
	} else if (
	(strstrofs(mapname, "fire", 0) != -1 )
	|| (strstrofs(mapname, "flame", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_FIRE;
	} else if (strstrofs(mapname, "acid", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
	} else if (
	(strstrofs(mapname, "water", 0) != -1 )
	|| (strstrofs(mapname, "ocean", 0) != -1 )
	|| (strstrofs(mapname, "hydro", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_WATER;
	} else if (strstrofs(mapname, "snow", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	} else if (
	(strstrofs(mapname, "artic", 0) != -1 )
	|| (strstrofs(mapname, "frozen", 0) != -1 )
	|| (strstrofs(mapname, "tundra", 0) != -1 )
	|| (strstrofs(mapname, "christmas", 0) != -1 )
	|| (strstrofs(mapname, "santa", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	} else if (strstrofs(mapname, "steam", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_STEAM;
	} else if (
	(strstrofs(mapname, "atom", 0) != -1 )
	|| (strstrofs(mapname, "fusion", 0) != -1 )
	|| (strstrofs(mapname, "laser", 0) != -1 )
	|| (strstrofs(mapname, "lazer", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_LASER;
	} else if (strstrofs(mapname, "ice", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	} else if (
	(strstrofs(mapname, "lava", 0) != -1 )
	|| (strstrofs(mapname, "magma", 0) != -1 )
	) {
		automatic_pipe_type = AUTOMATICPIPETYPE_FIRE;
	} else if (strstrofs(mapname, "cryo", 0) != -1 ){
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	}
	
	
	if (automatic_pipe_type) {
		return;
	}
	
	
	local float myfogcolor_red;
	local float myfogcolor_green;
	local float myfogcolor_blue;
	
	int mynum;
	
	mynum = tokenize_console(world.fog);
	
	if(mynum > 1) {
		myfogcolor_red = 0;
		myfogcolor_green = 0;
		myfogcolor_blue = 0;
		
		myfogcolor_red = stof(argv(1)); //Red
		if(mynum > 2)
			myfogcolor_green = stof(argv(2)); //Green
		
		if(mynum > 3)
			myfogcolor_blue = stof(argv(3)); //Blue
		
		
	} else {
		return;
	}
	
	
	
	//print(ftos(myfogcolor_red), "_R\n");
	//print(ftos(myfogcolor_green), "_G\n");
	//print(ftos(myfogcolor_blue), "_B\n");
	
	
	if (myfogcolor_blue > myfogcolor_red
	&& myfogcolor_blue > myfogcolor_green) {
		automatic_pipe_type = AUTOMATICPIPETYPE_ICE;
	} else if (myfogcolor_green > myfogcolor_red
	&& myfogcolor_green > myfogcolor_blue) {
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
	} else if (myfogcolor_red > myfogcolor_blue
	&& (myfogcolor_red > myfogcolor_green
	|| myfogcolor_red == myfogcolor_green)) {
		automatic_pipe_type = AUTOMATICPIPETYPE_FIREANDSTEAM;
	} else if (myfogcolor_red > myfogcolor_green
	&& myfogcolor_red == myfogcolor_blue) {
		//Purple
		automatic_pipe_type = AUTOMATICPIPETYPE_FIREANDICE;
	}
}

void W_AutoEvaluatePipeTypeByDamage(float deathtype)
{
	if (automatic_pipe_type) {
		return;
	}
	
	if not(autocvar_g_allpiercingcausesautomatic_frompipes) {
		return;
	}
	
	
		
	if (deathtype == DEATH_SLIME)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
	} else if (deathtype == DEATH_LAVA)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_FIRE;
	}
}

void W_AutoEvaluatePipeTypeBySpot(vector mytestspot)
{
	if (automatic_pipe_type) {
		return;
	}
	
	if not(autocvar_g_allpiercingcausesautomatic_frompipes) {
		return;
	}
	
	//print (vtos(mytestspot),"_testspot\n");
	//print (vtos(v_forward),"_v_forward\n");
	local float mytestpointcontents;
	
	mytestpointcontents = pointcontents(mytestspot);
		
	if (mytestpointcontents == CONTENT_SLIME)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
		return;
	} else if (mytestpointcontents == CONTENT_LAVA)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_FIRE;
		return;
	}
	
	mytestpointcontents = pointcontents(mytestspot + (v_forward * -2));
		
	if (mytestpointcontents == CONTENT_SLIME)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_POISON;
		return;
	} else if (mytestpointcontents == CONTENT_LAVA)
	{
		automatic_pipe_type = AUTOMATICPIPETYPE_FIRE;
		return;
	}
}

float W_EvaluateIfIsPipeFlats(vector mypipevector) {
	
	if (mypipevector_x == 0
	&& mypipevector_y == 0
	&& mypipevector_z == 1) {
		return TRUE;
	} else if (mypipevector_x == 0
	&& mypipevector_y == 0
	&& mypipevector_z == -1) {
		return TRUE;
	} else if (mypipevector_x == 0
	&& mypipevector_y == 1
	&& mypipevector_z == 0) {
		return TRUE;
	} else if (mypipevector_x == 0
	&& mypipevector_y == -1
	&& mypipevector_z == 0) {
		return TRUE;
	} else if (mypipevector_x == 1
	&& mypipevector_y == 0
	&& mypipevector_z == 0) {
		return TRUE;
	} else if (mypipevector_x == -1
	&& mypipevector_y == 0
	&& mypipevector_z == 0) {
		return TRUE;
	}
	
	return FALSE;
}

float W_EvaluateIfIsPipe (void)
{
	if not (autocvar_g_allpiercingcauses_pipetexture_ignoredefault) {
		if (strstrofs(trace_dphittexturename, "pipe", 0) != -1 ) {
			if (autocvar_g_allpiercingcauses_noflatpipes == 2
			&& W_EvaluateIfIsPipeFlats(trace_plane_normal))
			{
				return FALSE;
			} else {
				//Always pipe
				return TRUE;
			}
		} else if(strstrofs(trace_dphittexturename, "exx/floor-simplines", 0) != -1 ) {
			if (autocvar_g_allpiercingcauses_noflatpipes && W_EvaluateIfIsPipeFlats(trace_plane_normal))
			{
				return FALSE;
			} else {
				return TRUE;
			}
		}
	}
	
	if not (autocvar_g_allpiercingcauses_pipetexture_ignorespecial) {
		if (autocvar_g_allpiercingcauses_noflatpipes && W_EvaluateIfIsPipeFlats(trace_plane_normal))
		{
			return FALSE;
		}
		
		//So you can set your own texture strings to match as a pipe!
		if (autocvar_g_allpiercingcauses_pipetexture0 != "") {
			//print("Here1\n");
			if (strstrofs(trace_dphittexturename, autocvar_g_allpiercingcauses_pipetexture0, 0) != -1 )
			{
				//print("HERE!\n");
				//print(vtos(trace_plane_normal),"_TPN\n");
				return TRUE;
			}
		}
	
		if (autocvar_g_allpiercingcauses_pipetexture1 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_allpiercingcauses_pipetexture1, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_allpiercingcauses_pipetexture2 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_allpiercingcauses_pipetexture2, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_allpiercingcauses_pipetexture3 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_allpiercingcauses_pipetexture3, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_allpiercingcauses_pipetexture4 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_allpiercingcauses_pipetexture4, 0) != -1 )
			{
				return TRUE;
			}
		}
	}
	
	//For use in mapinfo files, must enable in mapinfo before we look to use
	if (autocvar_g_suggested_allpiercingcauses_pipetexture_enablespecial) {
		if (autocvar_g_suggested_allpiercingcauses_noflatpipes && W_EvaluateIfIsPipeFlats(trace_plane_normal))
		{
			return FALSE;
		}
		
		//So you can set your own texture strings to match as a pipe in a mapinfor!
		if (autocvar_g_suggested_allpiercingcauses_pipetexture0 != "") {
			//print("Here1\n");
			if (strstrofs(trace_dphittexturename, autocvar_g_suggested_allpiercingcauses_pipetexture0, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_suggested_allpiercingcauses_pipetexture1 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_suggested_allpiercingcauses_pipetexture1, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_suggested_allpiercingcauses_pipetexture2 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_suggested_allpiercingcauses_pipetexture2, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_suggested_allpiercingcauses_pipetexture3 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_suggested_allpiercingcauses_pipetexture3, 0) != -1 )
			{
				return TRUE;
			}
		}
	
		if (autocvar_g_suggested_allpiercingcauses_pipetexture4 != "") {
			if (strstrofs(trace_dphittexturename, autocvar_g_suggested_allpiercingcauses_pipetexture4, 0) != -1 )
			{
				return TRUE;
			}
		}
	}
		
	return FALSE;
}


void W_BallisticBullet_Touch (void)
{
	//float density;

	if(self.think == W_BallisticBullet_LeaveSolid_think) // skip this!
		return;

	PROJECTILE_TOUCH;
	
	if(self.dmg_radius > 0) {
		self.dmg_radius = W_BallisticBulletSetConstant(self.count, self.dmg_radius);
	}
	
	W_BallisticBullet_Hit ();

	if(self.dmg_radius < 0) // these NEVER penetrate solid
	{
		remove(self);
		return;
	}

	// if we hit "weapclip", bail out
	//
	// rationale of this check:
	//
	// any shader that is solid, nodraw AND trans is meant to clip weapon
	// shots and players, but has no other effect!
	//
	// if it is not trans, it is caulk and should not have this side effect
	//
	// matching shaders:
	//   common/weapclip (intended)
	//   common/noimpact (is supposed to eat projectiles, but is erased farther above)
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NODRAW)
	if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NONSOLID)
	if not(trace_dphitcontents & DPCONTENTS_OPAQUE)
	{
		remove(self);
		return;
	}
	
	
	local float pipeburnsforce, pipesteamsforce, pipeicesforce, pipewatersforce, pipepoisonsforce, pipelasersforce;
	pipeburnsforce = 0;
	pipesteamsforce = 0;
	pipeicesforce = 0;
	pipewatersforce = 0;
	pipepoisonsforce = 0;
	pipelasersforce = 0;
	if (!autocvar_g_allpiercingcauses_disabled) {
		if (autocvar_g_allpiercingcausesfire_frompipes
		|| autocvar_g_allpiercingcausessteam_frompipes
		|| autocvar_g_allpiercingcausesice_frompipes
		|| autocvar_g_allpiercingcauseswater_frompipes
		|| autocvar_g_allpiercingcausespoison_frompipes
		|| autocvar_g_allpiercingcauseslaser_frompipes
		|| autocvar_g_allpiercingcausesautomatic_frompipes)
		{
			if (autocvar_g_allpiercingcausesautomatic_frompipes) {
				if (automatic_pipe_type) {
					//No need
				} else {
					W_AutoEvaluatePipeTypeBySpot(self.origin);
				}
			}


			local float evaluateifpipe;
			local float evaluationcomplete;
			evaluateifpipe = W_EvaluateIfIsPipe();
			
			evaluationcomplete = 0;
			
			if (evaluateifpipe) {
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcausesfire_frompipes) {
					pipeburnsforce = 1;
					
					if (autocvar_g_allpiercingcausesfire_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcausessteam_frompipes) {
					pipesteamsforce = 1;
					
					if (autocvar_g_allpiercingcausessteam_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcauseswater_frompipes) {
					pipewatersforce = 1;
					
					if (autocvar_g_allpiercingcauseswater_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcausesice_frompipes) {
					pipeicesforce = 1;
					
					if (autocvar_g_allpiercingcausesice_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcausespoison_frompipes) {
					pipepoisonsforce = 1;
					
					if (autocvar_g_allpiercingcausespoison_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (!evaluationcomplete) {
				if (random() < autocvar_g_allpiercingcauseslaser_frompipes) {
					pipelasersforce = 1;
					
					if (autocvar_g_allpiercingcauseslaser_frompipes >= 1) {
						//If we're at 100 pct, and other things are set too, give them a chance to shine aswell
					} else {
						evaluationcomplete = 1;
					}
				}
				}
				
				
				if (autocvar_g_allpiercingcausesautomatic_frompipes) {
					if (automatic_pipe_type) {
						if (automatic_pipe_type == AUTOMATICPIPETYPE_STEAM) {
							pipesteamsforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_FIRE) {
							pipeburnsforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_FIREANDSTEAM) {
							pipeburnsforce = 1;
							pipesteamsforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_ICE) {
							pipeicesforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_WATER) {
							pipewatersforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_POISON) {
							pipepoisonsforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_LASER) {
							pipelasersforce = 1;
						} else if (automatic_pipe_type == AUTOMATICPIPETYPE_FIREANDICE) {
							pipeburnsforce = 1;
							pipeicesforce = 1;
						} else {
							pipesteamsforce = 1;	
						}
					} else {
						pipesteamsforce = 1;	
					}
				}
			}	
		}
	}
	
	
	Methane_ExplodeBullet_maybe_at (self.origin, self.realowner); //If we are in methane, maybe cause an explosion
	
	if (!autocvar_g_allpiercingcauses_disabled) {
		PiercingCausesFire_maybe(self, other, trace_plane_normal, pipeburnsforce);
		PiercingCausesSteam_maybe(self, other, trace_plane_normal, pipesteamsforce);
		PiercingCausesIce_maybe(self, other, trace_plane_normal, pipeicesforce);
		PiercingCausesWater_maybe(self, other, trace_plane_normal, pipewatersforce);
		PiercingCausesPoison_maybe(self, other, trace_plane_normal, pipepoisonsforce);
		PiercingCausesLaser_maybe(self, other, trace_plane_normal, pipelasersforce);
	}
	
	// go through solid!
	if(!W_BallisticBullet_LeaveSolid(-1))
	{
		remove(self);
		return;
	}

	self.projectiledeathtype |= HITTYPE_BOUNCE;
}

void endFireBallisticBullet()
{
	endzcurveparticles();
}

entity fireBallisticBullet_trace_callback_ent;
float fireBallisticBullet_trace_callback_eff;
void fireBallisticBullet_trace_callback(vector start, vector hit, vector end)
{
	if(vlen(trace_endpos - fireBallisticBullet_trace_callback_ent.origin) > 16)
		zcurveparticles_from_tracetoss(fireBallisticBullet_trace_callback_eff, fireBallisticBullet_trace_callback_ent.origin, trace_endpos, fireBallisticBullet_trace_callback_ent.velocity);
	WarpZone_trace_forent = world;
	self.owner = world;
}

float fireBallisticBullet_frmadjst(float multi)
{
	float myrem;
	//So that friction will be independent of framerate:
	
	myrem = (1 - (multi * (frametime/0.0222222)));
	
	//print(ftos(myrem),"------\n");
	
	return (myrem);
}

//float vehicles_frmadjst(float multi); //A useful routine that deals with frictions irrespective of frametime

void fireBallisticBullet_FrictionThink(void)
{
	self.nextthink = time;
	if (time > self.ammount4) {
		self.think = SUB_Remove;
	}
	
	
	if (self.amnt == 1) {
		if (self.touch == W_BallisticBullet_Touch) {
			self.touch = func_null;
			if (self.think != SUB_Remove) {
				if (time > self.ammount4)
				{
					self.nextthink = self.ammount4;
					self.think = SUB_Remove;
					return;
				}
			}
		}
	}
	
		local float dvlctyrdctn;
		dvlctyrdctn = 0;
		local float tstvlen;
		tstvlen = vlen(self.velocity);
		local float tstpntcntnts;
		tstpntcntnts = pointcontents(self.origin);
		
		//print(ftos(vlen(self.velocity)),"_a\n");
		//print(ftos(tstvlen),"_b\n");
		
		if ((tstvlen < 24 || self.amnt == 1)
		   && (self.ammount2 != CONTENT_SLIME
		   && self.ammount2 != CONTENT_LAVA))
		{
			//Less than 24 qu/second Do nothing
			//If we have "stopped" (sans gravity) due to waterfriction
			//Now we will let gravity take us
			//Lava and Slime will continue to act on us if we're in that, however
			self.amnt = 1; //Let gravity take over
				//print("Letting gravity take over\n");
		} else if (tstpntcntnts == CONTENT_WATER) {
			if (autocvar_g_ballistics_waterfriction) {
				self.velocity = self.velocity * fireBallisticBullet_frmadjst(autocvar_g_ballistics_waterfriction);
				UpdateCSQCProjectile(self);
				dvlctyrdctn = 1;
				self.ammount2 = CONTENT_WATER;
				
				if (self.ammount3) {
					if (self.ammount3 > time) {
						if (self.prevorigin_x || self.prevorigin_y || self.prevorigin_z)
						{
							if (pointcontents(self.prevorigin) == CONTENT_WATER) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
							
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
							
								if (tstvlen > 400) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								}
								
								if (tstvlen > 800) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								}
								
								if (tstvlen > 2500) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								}
								
								if (tstvlen > 5000) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								}
								
								if (tstvlen > 10000) {
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								trailparticles(self, particleeffectnum("tr_rifle"), self.origin, self.prevorigin);
								}
							}
						}
						
						self.prevorigin = self.origin;
					}
				} else {
					//For bullet trails underwater, originating underwater
					self.ammount3 = time + 1;
					self.prevorigin = self.origin;
				}

				//print(vtos(self.velocity)," Bullet in water\n");
			}
		} else if (tstpntcntnts == CONTENT_SLIME) {
			if (autocvar_g_ballistics_slimefriction) {
				self.velocity = self.velocity * fireBallisticBullet_frmadjst(autocvar_g_ballistics_slimefriction);
				UpdateCSQCProjectile(self);
				dvlctyrdctn = 1;
				self.ammount2 = CONTENT_SLIME;
				
				//print(vtos(self.velocity)," Bullet in slime\n");
			}
		} else if (tstpntcntnts == CONTENT_LAVA) {
			if (autocvar_g_ballistics_lavafriction) {
				self.velocity = self.velocity * fireBallisticBullet_frmadjst(autocvar_g_ballistics_lavafriction);
				UpdateCSQCProjectile(self);
				dvlctyrdctn = 1;
				self.ammount2 = CONTENT_LAVA;
				
				//print(vtos(self.velocity)," Bullet in lava\n");
			}
		} else {
			if (tstpntcntnts != CONTENT_SOLID) {
				//For bullet trails underwater, originating outside of lava/slime/water/solid
				//Note: lava doesn't get trails, nor does slime (too thick)
				self.ammount3 = time + 1;
				self.prevorigin = self.origin;
			}
		}
		


		if (dvlctyrdctn)
		if (self.amnt != 1)
		{
			if (tstvlen < 24) {
				if (self.ammount2 != CONTENT_SLIME
				&& self.ammount2 != CONTENT_LAVA) 
				{
					//If we have "stopped" (sans gravity) due to waterfriction
					//Now we will let gravity take us
					//Lava and Slime will continue to act on us if we're in that, however
					self.amnt = 1;
				}
			} else if (tstvlen < 30) {
				if (!self.amnt || self.amnt > 30) {
					self.amnt = 30;
					self.dmg = self.dmg * 0.1;
					self.dmg_edge = self.dmg_edge * 0.1;
					self.dmg_edge2 = self.dmg_edge2 * 0.1;
				}
			} else if (tstvlen < 50) {
				if (!self.amnt || self.amnt > 50) {
					self.amnt = 50;
					self.dmg = self.dmg * 0.25;
					self.dmg_edge = self.dmg_edge * 0.25;
					self.dmg_edge2 = self.dmg_edge2 * 0.25;
				}
			} else if (tstvlen < 100) {
				if (!self.amnt || self.amnt > 100) {
					self.amnt = 100;
					self.dmg = self.dmg * 0.75;
					self.dmg_edge = self.dmg_edge * 0.75;
					self.dmg_edge2 = self.dmg_edge2 * 0.75;
				}
			} else if (tstvlen < 200) {
				if (!self.amnt || self.amnt > 200) {
					self.amnt = 200;
					self.dmg = self.dmg * 0.75;
					self.dmg_edge = self.dmg_edge * 0.75;
					self.dmg_edge2 = self.dmg_edge2 * 0.75;
				}
			} else if (tstvlen < 300) {
				if (!self.amnt || self.amnt > 300) {
					self.amnt = 300;
					self.dmg = self.dmg * 0.75;
					self.dmg_edge = self.dmg_edge * 0.75;
					self.dmg_edge2 = self.dmg_edge2 * 0.75;
				}
			} else if (tstvlen < 400) {
				if (!self.amnt || self.amnt > 400) {
					self.amnt = 400;
					self.dmg = self.dmg * 0.75;
					self.dmg_edge = self.dmg_edge * 0.75;
					self.dmg_edge2 = self.dmg_edge2 * 0.75;
				}
			} else if (tstvlen < 500) {
				if (!self.amnt || self.amnt > 500) {
					self.amnt = 500;
					self.dmg = self.dmg * 0.75;
					self.dmg_edge = self.dmg_edge * 0.75;
					self.dmg_edge2 = self.dmg_edge2 * 0.75;
				}
			}
			
			
			//print(ftos(vlen(self.velocity)),"__", ftos(self.dmg),"\n");
		}
		
		//print(ftos(vlen(self.velocity)),"\n");

}

void fireBallisticBullet(vector start, vector dir, float spread, float pSpeed, float lifetime, float damage, float headshotbonus, float force, float dtype, float tracereffects, float gravityfactor, float bulletconstant, float coreshotbonus)
{
	float lag, dt, savetime; //, density;
	entity pl, oldself;
	float antilagging;
	
	if (tracereffects == 1) tracereffects = PROJECTILE_BULLET_GLOWING_TRACER; //Fix a common error

	antilagging = (autocvar_g_antilag_bullets && (pSpeed >= autocvar_g_antilag_bullets));

	entity proj;
	proj = spawn();
	proj.classname = "bullet";
	proj.owner = proj.realowner = self;
	
	Methane_ExplodeBullet_maybe_at (start, proj.realowner);
	
	PROJECTILE_MAKETRIGGER(proj);
	if(gravityfactor > 0)
	{
		proj.movetype = MOVETYPE_TOSS;
		proj.gravity = gravityfactor;
	}
	else
		proj.movetype = MOVETYPE_FLY;
	
	if (autocvar_g_ballistics_allowfriction) {
		proj.think = fireBallisticBullet_FrictionThink;
		proj.ammount4 = time + lifetime;
		proj.nextthink = time;
	} else {
	proj.think = SUB_Remove;
	proj.nextthink = time + lifetime; // min(pLifetime, vlen(world.maxs - world.mins) / pSpeed);
	}
	
	W_SetupProjectileVelocityEx(proj, dir, v_up, pSpeed, 0, 0, spread, antilagging);
	proj.angles = vectoangles(proj.velocity);
	if(bulletconstant > 0)
		proj.dmg_radius = autocvar_g_ballistics_materialconstant / bulletconstant;
	else if(bulletconstant == 0)
		proj.dmg_radius = 0;
	else
		proj.dmg_radius = -1;
	// so: bulletconstant = bullet mass / area of bullet circle
	proj.count = bulletconstant; //so we can compute later
	setorigin(proj, start);
	proj.flags = FL_PROJECTILE;

	proj.touch = W_BallisticBullet_Touch;
	proj.dmg = damage;
	proj.dmg_edge = headshotbonus;
	proj.dmg_edge2 = coreshotbonus; //Coreshot, hope I can do this
	proj.dmg_force = force;
	proj.projectiledeathtype = dtype;

	proj.oldvelocity = proj.velocity;

	other = proj; MUTATOR_CALLHOOK(EditProjectile);

	if(antilagging)
	{
		float eff;

		if(tracereffects == PROJECTILE_BULLET_GLOWING_TRACER
		|| tracereffects == PROJECTILE_BULLETRIFLE9MM_G_T
		|| tracereffects == PROJECTILE_BULLETRIFLE50_G_T) //replaced & EF_RED
			eff = particleeffectnum("tr_rifle");
		else if(tracereffects == PROJECTILE_BULLET_GLOWING
		|| tracereffects == PROJECTILE_BULLETRIFLE9MM_G
		|| tracereffects == PROJECTILE_BULLETRIFLE50_G) //replaced & EF_BLUE
			eff = particleeffectnum("tr_rifle_weak");
		else
			eff = particleeffectnum("tr_bullet");

		// NOTE: this may severely throw off weapon balance
		lag = ANTILAG_LATENCY(self);
		if(lag < 0.001)
			lag = 0;
		if(clienttype(self) != CLIENTTYPE_REAL)
			lag = 0;
		if(autocvar_g_antilag == 0 || self.cvar_cl_noantilag)
			lag = 0; // only do hitscan, but no antilag

		if(lag)
			FOR_EACH_PLAYER(pl)
				if(pl != self)
					antilag_takeback(pl, time - lag);

		oldself = self;
		self = proj;

		savetime = frametime;
		frametime = 0.05;

		for(;;)
		{
			// DP tracetoss is stupid and always traces in 0.05s
			// ticks. This makes it trace in 0.05*0.125s ticks
			// instead.
			vector v0;
			float g0;
			v0 = self.velocity;
			g0 = self.gravity;
			self.velocity = self.velocity * 0.125;
			self.gravity *= 0.125 * 0.125;
			trace_fraction = 0;
			fireBallisticBullet_trace_callback_ent = self;
			fireBallisticBullet_trace_callback_eff = eff;
			WarpZone_TraceToss_ThroughZone(self, self.owner, world, fireBallisticBullet_trace_callback);
			self.velocity = v0;
			self.gravity = g0;

			if(trace_fraction == 1)
				break;
				// won't hit anything anytime soon (DP's
				// tracetoss does 200 tics of, here,
				// 0.05*0.125s, that is, 1.25 seconds

			other = trace_ent;
			dt = WarpZone_tracetoss_time * 0.125; // this is only approximate!
			setorigin(self, trace_endpos);
			self.velocity = WarpZone_tracetoss_velocity * (1 / 0.125);

			if(!SUB_OwnerCheck())
			{
				if(SUB_NoImpactCheck())
					break;

				// hit the player
				W_BallisticBullet_Hit();
			}

			if(proj.dmg_radius < 0) // these NEVER penetrate solid
				break;

			// if we hit "weapclip", bail out
			//
			// rationale of this check:
			//
			// any shader that is solid, nodraw AND trans is meant to clip weapon
			// shots and players, but has no other effect!
			//
			// if it is not trans, it is caulk and should not have this side effect
			//
			// matching shaders:
			//   common/weapclip (intended)
			//   common/noimpact (is supposed to eat projectiles, but is erased farther above)
			if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NODRAW)
			if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NONSOLID)
			if not(trace_dphitcontents & DPCONTENTS_OPAQUE)
				break;

			// go through solid!
			if(!W_BallisticBullet_LeaveSolid((other && (other.solid != SOLID_BSP)) ? eff : -1))
				break;

			W_BallisticBullet_LeaveSolid_think();

			self.projectiledeathtype |= HITTYPE_BOUNCE;
		}
		frametime = savetime;
		self = oldself;

		if(lag)
			FOR_EACH_PLAYER(pl)
				if(pl != self)
					antilag_restore(pl);

		remove(proj);

		return;
	}

	if(tracereffects == PROJECTILE_BULLET_GLOWING_TRACER) //replaced & EF_RED
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING_TRACER, TRUE);
	else if(tracereffects == PROJECTILE_BULLET_GLOWING) //replaced & EF_BLUE
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET_GLOWING, TRUE);
	else if (tracereffects && !autocvar_sv_simple_bullets) //Can set PROJECTILE_ now
		CSQCProjectile(proj, TRUE, tracereffects, TRUE);
	else
		CSQCProjectile(proj, TRUE, PROJECTILE_BULLET, TRUE);
}

void fireBullet (vector start, vector dir, float spread, float damage, float force, float dtype, float tracer)
{
	vector  end;

	dir = normalize(dir + randomvec() * spread);
	end = start + dir * MAX_SHOT_DISTANCE;
	if(self.antilag_debug)
		traceline_antilag (self, start, end, FALSE, self, self.antilag_debug);
	else
		traceline_antilag (self, start, end, FALSE, self, ANTILAG_LATENCY(self));

	end = trace_endpos;

	if (pointcontents (trace_endpos) != CONTENT_SKY)
	{
		if not (trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
			Damage_DamageInfo(trace_endpos, damage, 0, 0, dir * max(1, force), dtype, trace_ent.species, self);                    

		Damage (trace_ent, self, self, damage, dtype, trace_endpos, dir * force);
	}
	trace_endpos = end;
}

float W_CheckProjectileDamage(entity inflictor, entity projowner, float deathtype, float exception)
{
	float is_from_contents = (deathtype == DEATH_SLIME || deathtype == DEATH_LAVA);
	float is_from_owner = (inflictor == projowner);
	float is_from_exception = (exception != -1);
	
	//dprint(strcat("W_CheckProjectileDamage: from_contents ", ftos(is_from_contents), " : from_owner ", ftos(is_from_owner), " : exception ", strcat(ftos(is_from_exception), " (", ftos(exception), "). \n")));

	if(autocvar_g_projectiles_damage <= -2)
	{
		return FALSE; // no damage to projectiles at all, not even with the exceptions
	}
	else if(autocvar_g_projectiles_damage == -1)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else
			return FALSE; // otherwise, no other damage is allowed
	}
	else if(autocvar_g_projectiles_damage == 0)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else if not(is_from_contents)
			return FALSE; // otherwise, only allow damage from contents
	}	
	else if(autocvar_g_projectiles_damage == 1)
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
		else if not(is_from_contents || is_from_owner)
			return FALSE; // otherwise, only allow self damage and damage from contents
	}
	else if(autocvar_g_projectiles_damage == 2) // allow any damage, but override for exceptions
	{
		if(is_from_exception)
			return (exception); // if exception is detected, allow it to override
	}

	return TRUE; // if none of these return, then allow damage anyway.
}

void W_PrepareExplosionByDamage(entity attacker, void() explode)
{
	self.takedamage = DAMAGE_NO;
	self.event_damage = func_null;
	
	if((attacker.flags & FL_CLIENT) && !autocvar_g_projectiles_keep_owner)
	{
		self.owner = attacker;
		self.realowner = attacker;
	}
	
	// do not explode NOW but in the NEXT FRAME!
	// because recursive calls to RadiusDamage are not allowed
	self.nextthink = time;
	self.think = explode;
}

//For melee and arrows:
//We calculate damage based on where the hit occured
//Different weapons may do less damage based on where they hit
float W_CritHitCalc(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, float myheadpcnt, float mycorepcnt, float mytoppcnt, float myupperpcnt, float mylowerpcnt, float mylegpcnt, float myfootpcnt, float myresidualpcnt, float mymovementimparable, float myextremityreduce, entity myattacker, float mydamagetype, float mycentertargetpct, float mydisorientate, float mydisorientatetopmid, float mydisorientatetopouter)
{
	// draw lightning beams for debugging
	//te_lightning2(world, myswingstart, myhitspot); 
		
	float myhitnearertomiddle;
	myhitnearertomiddle = 0;
	vector myhitmins, myhitmaxs, org;
	org = mytargent.origin;
	myhitmins = org + GetHeadshotMins(mytargent);
	myhitmaxs = org + GetHeadshotMaxs(mytargent);
	
	if (DamageDoesHeadshotByClassname(mytargent)) {
		if(trace_hits_box(myswingstart, myhitspot, myhitmins, myhitmaxs))
		{
		////Head
		//print("head hit\n");
			if (mydisorientate) {
				if (mytargent.vuln_movement_imparable) {
				//print("here\n");
				mytargent.dmgdisorientate = mydisorientate;
				mytargent.dmgdisorientatetime = time;
				mytargent.dmgdisorientateatkr = myattacker;
				mytargent.dmgdisorientatedthtyp = mydamagetype;
				}
			}
		mydamage = mydamage * myheadpcnt;
		return mydamage;
		}
	}
	
	myhitmins = org + GetCoreshotMins(mytargent);
	myhitmaxs = org + GetCoreshotMaxs(mytargent);
	if (DamageDoesCoreshotByClassname(mytargent)) {
		if(trace_hits_box(myswingstart, myhitspot, myhitmins, myhitmaxs))
		{
		////Core
		//print("core hit\n");
		mydamage = mydamage * mycorepcnt;
		return mydamage;
		}
	}
	
	
	//If that didn't work, the regions
	float targspread;
	targspread = mytargent.maxs_z - mytargent.mins_z;
	
	//print(ftos(targspread), "_Targspread\n");
	
	
	vector mymins;
	vector mymaxs;
	
	//Are we not at extemities of hitbox?
	mymins = mytargent.mins;
	mymaxs = mytargent.maxs;
	
	mymins_x = mymins_x * mycentertargetpct;
	mymins_y = mymins_y * mycentertargetpct;
	mymins_z = mymins_z - 16; //We just want to take into account the XY, not Z
	
	mymaxs_x = mymaxs_x * mycentertargetpct;
	mymaxs_y = mymaxs_y * mycentertargetpct;
	mymaxs_z = mymaxs_z + 16; //We just want to take into account the XY, not Z
	
	mymins = org + mymins;
	mymaxs = org + mymaxs;
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		//print("hit within", ftos(mycentertargetpct)," middle xy\n");
		myhitnearertomiddle = 1;
	}
	
	
	//Head area
	mymins = org +mytargent.mins;
	mymaxs = org +mytargent.maxs;
	
	mymins_z = mymins_z + (targspread*0.90);
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		////Top
		//print("top hit\n");
		if (myhitnearertomiddle) {
			if (mydisorientatetopmid) {
				if (mytargent.vuln_movement_imparable) {
				//print("here2\n");
				mytargent.dmgdisorientate = mydisorientatetopmid;
				mytargent.dmgdisorientatetime = time;
				mytargent.dmgdisorientateatkr = myattacker;
				mytargent.dmgdisorientatedthtyp = mydamagetype;
				}
			}
		} else {
			if (mydisorientatetopouter) {
				if (mytargent.vuln_movement_imparable) {
				//print("here3\n");
				mytargent.dmgdisorientate = mydisorientatetopouter;
				mytargent.dmgdisorientatetime = time;
				mytargent.dmgdisorientateatkr = myattacker;
				mytargent.dmgdisorientatedthtyp = mydamagetype;
				}
			}
		}
		mydamage = mydamage * mytoppcnt;
		return mydamage;
	}
	
	
	//Upperbody
	mymins = org + mytargent.mins;
	mymaxs = org + mytargent.maxs;
	
	mymins_z = mymins_z + (targspread*0.70);
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		////upperbody
		//print("upper hit\n");
		mydamage = mydamage * myupperpcnt;
		if (myhitnearertomiddle) {
			//Do Nothing
		} else {
			//Hit near extremities, reduce damage
			mydamage = mydamage * myextremityreduce;
		}
		return mydamage;
	}
	
	//Lowerbody
	mymins = org + mytargent.mins;
	mymaxs = org + mytargent.maxs;
	
	mymins_z = mymins_z + (targspread*0.50);
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		////lowerbody
		//print("lower hit\n");
		if (myhitnearertomiddle) {
			if (mymovementimparable) {
				if (mytargent.vuln_movement_imparable) {
				mytargent.dmgmvmntimpare = 0.4;
				mytargent.dmgmvmntimparetime = time;
				mytargent.dmgmvmntimpareatkr = myattacker;
				mytargent.dmgmvmntimparedthtyp = mydamagetype;
				}
			}
		} else {
			//Hit near extremities, reduce damage
			mydamage = mydamage * myextremityreduce;
		}
		mydamage = mydamage * mylowerpcnt;
		return mydamage;
	}
	
	//Leg
	mymins = org + mytargent.mins;
	mymaxs = org + mytargent.maxs;
	
	mymins_z = mymins_z + (targspread*0.25);
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		////leg
		//print("leg hit\n");
		if (myhitnearertomiddle) {
			if (mymovementimparable) {
				if (mytargent.vuln_movement_imparable) {
				mytargent.dmgmvmntimpare = 0.5;
				mytargent.dmgmvmntimparetime = time;
				mytargent.dmgmvmntimpareatkr = myattacker;
				mytargent.dmgmvmntimparedthtyp = mydamagetype;
				}
			}
		} else {
			//Hit near extremities, reduce damage
			mydamage = mydamage * myextremityreduce;
		}
		mydamage = mydamage * mylegpcnt;
		return mydamage;
	}
	
	//Foot
	mymins = org + mytargent.mins;
	mymaxs = org + mytargent.maxs;
	
	if(trace_hits_box(myswingstart, myhitspot, mymins, mymaxs))
	{
		////foot
		//print("foot hit\n");
		if (myhitnearertomiddle) {
			if (mymovementimparable) {
				if (mytargent.vuln_movement_imparable) {
				mytargent.dmgmvmntimpare = 0.25;
				mytargent.dmgmvmntimparetime = time;
				mytargent.dmgmvmntimpareatkr = myattacker;
				mytargent.dmgmvmntimparedthtyp = mydamagetype;
				}
			}
		} else {
			//Hit near extremities, reduce damage
			mydamage = mydamage * myextremityreduce;
		}
		mydamage = mydamage * myfootpcnt;
		return mydamage;
	}
	
	//print("residual hit\n"); //Shouldn't get here
	if (myhitnearertomiddle) { //Do Nothing
	} else { //Hit near extremities, reduce damage
		mydamage = mydamage * myextremityreduce;
	}
	return mydamage * myresidualpcnt;
}

//W_CritHitCalc: Damage, StartOfSwing, EndOfSwing, TargetVictim,
// Head"shot"DMGPercentage,
// Core"shot"DMGPercentage,
// TopDMGPercentage,		(If you didn't hit the headshot, but still at top)
// UpperBodyDmgPercentage,
// LowerBodyDmgPercentage,
// LegDmgPercentage,
// FootDmgPercentage,
// ResidualFallbackDmgPercentage (Usually Shouldn't get here (Exception: RadiusDmg like arrows))
// Can Impare Movement If Hit Lowers? (Arrows, Axes, Cleavers, Spears)
// ExtremityDamageMultip (if hit x-y extremities do less damage)
// MyAttacker
// MyDeathType (DMG type of weapon)
// MyCenterTarget (0.75, 0.85) where is the extemity boundry for this weapon (put 1 for no: full damage)
// MyDisorientate (Headshot) (dmg to disorientate time)
// MyDisorientateTopMid (top, middle)
// MyDisorientateTopOut (top, outer)


float W_CritHitCalc_Axe(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Axe\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 1, 1, 1, 0.55, 0.35, 0.18,
	0.05, 
	1, 0.85, myattacker, mydamagetype, 0.80,
	0.15, 0.08, 0);
	return mydamage;
}

float W_CritHitCalc_Sword(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Sword\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.95, 1, 0.80, 1, 0.5, 0.15, 0.10,
	0.05, 
	0, 0.65, myattacker, mydamagetype, 0.80,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_Cleaver(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//Cleaver type sword
	//print("Cleaver\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.95, 1, 0.80, 1, 0.55, 0.20, 0.16, 
	0.05, 
	1, 0.75, myattacker, mydamagetype, 0.80,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_CleaverKnife(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//Cleaver type knife
	//print("CleaverKnife\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.90, 1, 0.65, 1, 0.55, 0.20, 0.15,
	0.05, 
	0, 0.70, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_Knife(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Knife\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.90, 1, 0.50, 1, 0.5, 0.15, 0.10,
	0.05, 
	0, 0.60, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_Spear(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Spear\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.75, 1, 0.60, 0.9, 0.65, 0.20, 0.10,
	0.05, 
	1, 0.65, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_ArrowCore(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{	
	////NOTE: ArrowCore is the only one that goes over 1 for a hit
	////This is to bring insta-death for shots to the heart
	//print("ArrowCore\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.80, 1.25, 0.60, 1, 0.65, 0.20, 0.10,
	0.05, 
	1, 0.65, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_Arrow(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{	
	////Arrows that doesn't go above 1, as standard for all
	//print("Arrow\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.80, 1, 0.60, 1, 0.65, 0.20, 0.10,
	0.05, 
	1, 0.65, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_Ballista(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{	
	////Arrows that doesn't go above 1, as standard for all
	//print("Ballista\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	0.95, 1, 0.90, 1, 0.85, 0.75, 0.65,
	0.6, 
	1, 0.70, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_WarHammer(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("WarHammer\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 0.70, 0.85, 0.65, 0.5, 0.25, 0.15,
	0.05, 
	0, 0.65, myattacker, mydamagetype, 0.75,
	0.75, 0.2, 0);
	return mydamage;
}

float W_CritHitCalc_Mace(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Mace\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 0.80, 0.90, 0.65, 0.5, 0.25, 0.10,
	0.05, 
	0, 0.65, myattacker, mydamagetype, 0.75,
	0.5, 0.25, 0.125);
	return mydamage;
}

float W_CritHitCalc_Blunt(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Blunt\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 0.75, 0.85, 0.70, 0.60, 0.25, 0.15,
	0.05, 
	0, 0.65, myattacker, mydamagetype, 0.75,
	0.3, 0.2, 0.1);
	return mydamage;
}

float W_CritHitCalc_Generic(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("Generic\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 0.95, 0.85, 0.75, 0.5, 0.25, 0.10,
	0.05, 
	0, 0.65, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}

float W_CritHitCalc_LightSabre(float mydamage, vector myswingstart, vector myhitspot, entity mytargent, entity myattacker, float mydamagetype)
{
	//print("LightSabre\n");
	mydamage = W_CritHitCalc(mydamage, myswingstart, myhitspot, mytargent,
	1, 1, 1, 1, 1, 0.80, 0.60,
	0.01, 
	1, 0.65, myattacker, mydamagetype, 0.75,
	0, 0, 0);
	return mydamage;
}








