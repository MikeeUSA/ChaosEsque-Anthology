#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CRYPISTOL, w_crypistol, IT_CELLS, 1, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "crypistol", "crypistol", _("Crypistol"));
#else
#ifdef SVQC
//.float gravity;
.float crypistol_waitrelease;
.entity crylink_lastgroup;
.float crypistol_release;

//.entity queuenext;
//.entity queueprev;

void W_Crypistol_CheckLinks(entity e)
{
	float i;
	entity p;

	if(e == world)
		error("W_Crypistol_CheckLinks: entity is world");
	if(e.classname != "spike" || wasfreed(e))
		error(sprintf("W_Crypistol_CheckLinks: entity is not a spike but a %s (freed: %d)", e.classname, wasfreed(e)));

	p = e;
	for(i = 0; i < 1000; ++i)
	{
		if(p.queuenext.queueprev != p || p.queueprev.queuenext != p)
			error("W_Crypistol_CheckLinks: queue is inconsistent");
		p = p.queuenext;
		if(p == e)
			break;
	}
	if(i >= 1000)
		error("W_Crypistol_CheckLinks: infinite chain");
}

void W_Crypistol_Dequeue_Raw(entity own, entity prev, entity me, entity next)
{
	W_Crypistol_CheckLinks(next);
	if(me == own.crylink_lastgroup)
		own.crylink_lastgroup = ((me == next) ? world : next);
	prev.queuenext = next;
	next.queueprev = prev;
	me.classname = "spike_oktoremove";
	if(me != next)
		W_Crypistol_CheckLinks(next);
}

void W_Crypistol_Dequeue(entity e)
{
	W_Crypistol_Dequeue_Raw(e.realowner, e.queueprev, e, e.queuenext);
}

void W_Crypistol_Reset(void)
{
	W_Crypistol_Dequeue(self);
	remove(self);
}

// force projectile to explode
void W_Crypistol_LinkExplode (entity e, entity e2)
{
	float a;

	if(e == e2)
		return;

	a = bound(0, 1 - (time - e.fade_time) * e.fade_rate, 1);

	if(e == e.realowner.crylink_lastgroup)
		e.realowner.crylink_lastgroup = world;

	if(e.projectiledeathtype & HITTYPE_SECONDARY)
		RadiusDamage (e, e.realowner, autocvar_g_balance_crypistol_secondary_damage * a, autocvar_g_balance_crypistol_secondary_edgedamage * a, autocvar_g_balance_crypistol_secondary_radius, world, autocvar_g_balance_crypistol_secondary_force * a, e.projectiledeathtype, other);
	else
		RadiusDamage (e, e.realowner, autocvar_g_balance_crypistol_primary_damage * a, autocvar_g_balance_crypistol_primary_edgedamage * a, autocvar_g_balance_crypistol_primary_radius, world, autocvar_g_balance_crypistol_primary_force * a, e.projectiledeathtype, other);

	W_Crypistol_LinkExplode(e.queuenext, e2);

	e.classname = "spike_oktoremove";
	Chemical_flash_maybe(e);
	remove (e);
}

// adjust towards center
// returns the origin where they will meet... and the time till the meeting is
// stored in w_crypistol_linkjoin_time.
// could possibly network this origin and time, and display a special particle
// effect when projectiles meet there :P
// jspeed: MINIMUM jing speed
// jtime: MAXIMUM jing time (0: none)
float w_crypistol_linkjoin_time;
vector W_Crypistol_LinkJoin(entity e, float jspeed, float jtime)
{
	vector avg_origin, avg_velocity;
	vector targ_origin;
	float avg_dist, n;
	entity p;

	// FIXME remove this debug code
	W_Crypistol_CheckLinks(e);

	w_crypistol_linkjoin_time = 0;

	avg_origin = e.origin;
	avg_velocity = e.velocity;
	n = 1;
	for(p = e; (p = p.queuenext) != e; )
	{
		avg_origin += WarpZone_RefSys_TransformOrigin(p, e, p.origin);
		avg_velocity += WarpZone_RefSys_TransformVelocity(p, e, p.velocity);
		++n;
	}
	avg_origin *= (1.0 / n);
	avg_velocity *= (1.0 / n);

	if(n < 2)
		return avg_origin; // nothing to do

	// yes, mathematically we can do this in ONE step, but beware of 32bit floats...
	avg_dist = pow(vlen(e.origin - avg_origin), 2);
	for(p = e; (p = p.queuenext) != e; )
		avg_dist += pow(vlen(WarpZone_RefSys_TransformOrigin(p, e, p.origin) - avg_origin), 2);
	avg_dist *= (1.0 / n);
	avg_dist = sqrt(avg_dist);

	if(avg_dist == 0)
		return avg_origin; // no change needed

	if(jspeed == 0 && jtime == 0)
	{
		e.velocity = avg_velocity;
		UpdateCSQCProjectile(e);
		for(p = e; (p = p.queuenext) != e; )
		{
			p.velocity = WarpZone_RefSys_TransformVelocity(e, p, avg_velocity);
			UpdateCSQCProjectile(p);
		}
		targ_origin = avg_origin + 1000000000 * normalize(avg_velocity); // HUUUUUUGE
	}
	else
	{
		if(jtime)
		{
			if(jspeed)
				w_crypistol_linkjoin_time = min(jtime, avg_dist / jspeed);
			else
				w_crypistol_linkjoin_time = jtime;
		}
		else
			w_crypistol_linkjoin_time = avg_dist / jspeed;
		targ_origin = avg_origin + w_crypistol_linkjoin_time * avg_velocity;

		e.velocity = (targ_origin - e.origin) * (1.0 / w_crypistol_linkjoin_time);
		UpdateCSQCProjectile(e);
		for(p = e; (p = p.queuenext) != e; )
		{
			p.velocity = WarpZone_RefSys_TransformVelocity(e, p, (targ_origin - WarpZone_RefSys_TransformOrigin(p, e, p.origin)) * (1.0 / w_crypistol_linkjoin_time));
			UpdateCSQCProjectile(p);
		}

		// analysis:
		//   jspeed -> +infinity:
		//      w_crypistol_linkjoin_time -> +0
		//      targ_origin -> avg_origin
		//      p->velocity -> HUEG towards center
		//   jspeed -> 0:
		//      w_crypistol_linkjoin_time -> +/- infinity
		//      targ_origin -> avg_velocity * +/- infinity
		//      p->velocity -> avg_velocity
		//   jspeed -> -infinity:
		//      w_crypistol_linkjoin_time -> -0
		//      targ_origin -> avg_origin
		//      p->velocity -> HUEG away from center
	}

	W_Crypistol_CheckLinks(e);

	return targ_origin;
}

void W_Crypistol_LinkJoinEffect_Think()
{
	// is there at least 2 projectiles very close?
	entity e, p;
	float n;
	e = self.owner.crylink_lastgroup;
	n = 0;
	if(e)
	{
		if(vlen(e.origin - self.origin) < vlen(e.velocity) * frametime)
			++n;
		for(p = e; (p = p.queuenext) != e; )
		{
			if(vlen(p.origin - self.origin) < vlen(p.velocity) * frametime)
				++n;
		}
		if(n >= 2)
		{
			if(e.projectiledeathtype & HITTYPE_SECONDARY)
			{
				if(autocvar_g_balance_crypistol_secondary_joinexplode)
				{
					n = n / autocvar_g_balance_crypistol_secondary_shots;
					RadiusDamage (e, e.realowner, autocvar_g_balance_crypistol_secondary_joinexplode_damage * n,
									autocvar_g_balance_crypistol_secondary_joinexplode_edgedamage * n,
									autocvar_g_balance_crypistol_secondary_joinexplode_radius * n, e.realowner,
									autocvar_g_balance_crypistol_secondary_joinexplode_force * n, e.projectiledeathtype, other);

					pointparticles(particleeffectnum("crylink_joinexplode"), self.origin, '0 0 0', n);
				}
			}
			else
			{
				if(autocvar_g_balance_crypistol_primary_joinexplode)
				{
					n = n / autocvar_g_balance_crypistol_primary_shots;
					RadiusDamage (e, e.realowner, autocvar_g_balance_crypistol_primary_joinexplode_damage * n,
									autocvar_g_balance_crypistol_primary_joinexplode_edgedamage * n,
									autocvar_g_balance_crypistol_primary_joinexplode_radius * n, e.realowner,
									autocvar_g_balance_crypistol_primary_joinexplode_force * n, e.projectiledeathtype, other);

					pointparticles(particleeffectnum("crylink_joinexplode"), self.origin, '0 0 0', n);
				}
			}
		}
	}
	remove(self);
}

float W_Crypistol_Touch_WouldHitFriendly(entity projectile, float rad)
{
	entity head = WarpZone_FindRadius((projectile.origin + (projectile.mins + projectile.maxs) * 0.5), rad + MAX_DAMAGEEXTRARADIUS, FALSE);
	float hit_friendly = 0;
	float hit_enemy = 0;

	while(head)
	{
		if((head.takedamage != DAMAGE_NO) && (head.deadflag == DEAD_NO))
		{
			if(IsDifferentTeam(head, projectile.realowner))
				++hit_enemy;
			else
				++hit_friendly;
		}
			
		head = head.chain;
	}

	return (hit_enemy ? FALSE : hit_friendly);
}

// NO bounce protection, as bounces are limited!
void W_Crypistol_Touch (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;

	float a;
	a = bound(0, 1 - (time - self.fade_time) * self.fade_rate, 1);

	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = autocvar_g_balance_crypistol_primary_bouncedamagefactor;
	if(a)
		f *= a;

	float totaldamage = RadiusDamage(self, self.realowner, autocvar_g_balance_crypistol_primary_damage * f, autocvar_g_balance_crypistol_primary_edgedamage * f, autocvar_g_balance_crypistol_primary_radius, world, autocvar_g_balance_crypistol_primary_force * f, self.projectiledeathtype, other);
	
	if(totaldamage && ((autocvar_g_balance_crypistol_primary_linkexplode == 2) || ((autocvar_g_balance_crypistol_primary_linkexplode == 1) && !W_Crypistol_Touch_WouldHitFriendly(self, autocvar_g_balance_crypistol_primary_radius))))
	{
		if(self == self.realowner.crylink_lastgroup)
			self.realowner.crylink_lastgroup = world;
		W_Crypistol_LinkExplode(self.queuenext, self);
		self.classname = "spike_oktoremove";
		remove (self);
		return;
	}
	else if(finalhit)
	{
		// just unlink
		W_Crypistol_Dequeue(self);
		remove(self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void W_Crypistol_Touch2 (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;

	float a;
	a = bound(0, 1 - (time - self.fade_time) * self.fade_rate, 1);

	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = autocvar_g_balance_crypistol_secondary_bouncedamagefactor;
	if(a)
		f *= a;

	float totaldamage = RadiusDamage(self, self.realowner, autocvar_g_balance_crypistol_secondary_damage * f, autocvar_g_balance_crypistol_secondary_edgedamage * f, autocvar_g_balance_crypistol_secondary_radius, world, autocvar_g_balance_crypistol_secondary_force * f, self.projectiledeathtype, other);
		
	if(totaldamage && ((autocvar_g_balance_crypistol_secondary_linkexplode == 2) || ((autocvar_g_balance_crypistol_secondary_linkexplode == 1) && !W_Crypistol_Touch_WouldHitFriendly(self, autocvar_g_balance_crypistol_secondary_radius))))
	{
		if(self == self.realowner.crylink_lastgroup)
			self.realowner.crylink_lastgroup = world;
		W_Crypistol_LinkExplode(self.queuenext, self);
		self.classname = "spike_oktoremove";
		remove (self);
		return;
	}
	else if(finalhit)
	{
		// just unlink
		W_Crypistol_Dequeue(self);
		Chemical_flash_maybe(self);
		remove(self);
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_CRYLINK, TRUE);
}

void W_Crypistol_Fadethink (void)
{
	W_Crypistol_Dequeue(self);
	remove(self);
}

void W_Crypistol_Attack (void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_crypistol_primary_ammo, autocvar_g_balance_crypistol_reload_ammo);

	maxdmg = autocvar_g_balance_crypistol_primary_damage*autocvar_g_balance_crypistol_primary_shots;
	maxdmg *= 1 + autocvar_g_balance_crypistol_primary_bouncedamagefactor * autocvar_g_balance_crypistol_primary_bounces;
	if(autocvar_g_balance_crypistol_primary_joinexplode)
		maxdmg += autocvar_g_balance_crypistol_primary_joinexplode_damage;

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_balance_crypistol_primary_shots;
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crypistol_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_crypistol_primary_damage;
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYPISTOL;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if (counter == 0)
			s = '0 0 0';
		else
		{
			makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
			s_y = v_forward_x;
			s_z = v_forward_y;
		}
		s = s * autocvar_g_balance_crypistol_primary_spread * g_weaponspreadfactor;
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, autocvar_g_balance_crypistol_primary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Crypistol_Touch;

		proj.think = W_Crypistol_Fadethink;
		if(counter == 0)
		{
			proj.fade_time = time + autocvar_g_balance_crypistol_primary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crypistol_primary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_crypistol_primary_middle_lifetime + autocvar_g_balance_crypistol_primary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_crypistol_primary_other_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crypistol_primary_other_fadetime;
			proj.nextthink = time + autocvar_g_balance_crypistol_primary_other_lifetime + autocvar_g_balance_crypistol_primary_other_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_crypistol_primary_joindelay;
		proj.cnt = autocvar_g_balance_crypistol_primary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(autocvar_g_balance_crypistol_primary_joinspread != 0 || autocvar_g_balance_crypistol_primary_jointime != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crypistol_CheckLinks(proj);
		self.crypistol_waitrelease = 1;
	}
}

void W_Crypistol_Attack2 (void)
{
	float counter, shots;
	entity proj, prevproj, firstproj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_crypistol_secondary_ammo, autocvar_g_balance_crypistol_reload_ammo);

	maxdmg = autocvar_g_balance_crypistol_secondary_damage*autocvar_g_balance_crypistol_secondary_shots;
	maxdmg *= 1 + autocvar_g_balance_crypistol_secondary_bouncedamagefactor * autocvar_g_balance_crypistol_secondary_bounces;
	if(autocvar_g_balance_crypistol_secondary_joinexplode)
		maxdmg += autocvar_g_balance_crypistol_secondary_joinexplode_damage;

	W_SetupShot (self, FALSE, 2, "weapons/crylink_fire2.wav", CH_WEAPON_A, maxdmg);
	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_balance_crypistol_secondary_shots;
	pointparticles(particleeffectnum("crylink_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = prevproj = firstproj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Crypistol_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "spike";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_crypistol_secondary_damage;
		if(shots == 1) {
			proj.queuenext = proj;
			proj.queueprev = proj;
		}
		else if(counter == 0) { // first projectile, store in firstproj for now
			firstproj = proj;
		}
		else if(counter == shots - 1) { // last projectile, link up with first projectile
			prevproj.queuenext = proj;
			firstproj.queueprev = proj;
			proj.queuenext = firstproj;
			proj.queueprev = prevproj;
		}
		else { // else link up with previous projectile
			prevproj.queuenext = proj;
			proj.queueprev = prevproj;
		}

		prevproj = proj;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_CRYPISTOL | HITTYPE_SECONDARY;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');

		if(autocvar_g_balance_crypistol_secondary_spreadtype == 1)
		{
			s = '0 0 0';
			if (counter == 0)
				s = '0 0 0';
			else
			{
				makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
				s_y = v_forward_x;
				s_z = v_forward_y;
			}
			s = s * autocvar_g_balance_crypistol_secondary_spread * g_weaponspreadfactor;
			s = w_shotdir + right * s_y + up * s_z;
		}
		else
		{
			//Reversed from Crylink
			if (self.shootfromside == 1) {
				s = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * autocvar_g_balance_crypistol_secondary_spread * g_weaponspreadfactor);
			} else {
				//Verticle
				s = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_up * autocvar_g_balance_crypistol_secondary_spread * g_weaponspreadfactor);
			}
		}

		W_SetupProjectileVelocityEx(proj, s, v_up, autocvar_g_balance_crypistol_secondary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Crypistol_Touch2;
		proj.think = W_Crypistol_Fadethink;
		if(counter == (shots - 1) / 2)
		{
			proj.fade_time = time + autocvar_g_balance_crypistol_secondary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crypistol_secondary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_crypistol_secondary_middle_lifetime + autocvar_g_balance_crypistol_secondary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_crypistol_secondary_line_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_crypistol_secondary_line_fadetime;
			proj.nextthink = time + autocvar_g_balance_crypistol_secondary_line_lifetime + autocvar_g_balance_crypistol_secondary_line_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_crypistol_secondary_joindelay;
		proj.cnt = autocvar_g_balance_crypistol_secondary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;
        
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_CRYLINK_BOUNCING : PROJECTILE_CRYLINK), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
	if(autocvar_g_balance_crypistol_secondary_joinspread != 0 || autocvar_g_balance_crypistol_secondary_jointime != 0)
	{
		self.crylink_lastgroup = proj;
		W_Crypistol_CheckLinks(proj);
		self.crypistol_waitrelease = 2;
	}
}

float W_Crypistol_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_crypistol_reload_ammo && self.clip_load < min(autocvar_g_balance_crypistol_primary_ammo, autocvar_g_balance_crypistol_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_crypistol (void)
{
	weapon_defaultspawnfunc(WEP_CRYPISTOL);
}

float w_crypistol(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Crypistol_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.crypistol_release) {
			if (random() < 0.10)
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_crypistol_primary_speed, 0, autocvar_g_balance_crypistol_primary_middle_lifetime, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_crypistol_secondary_speed, 0, autocvar_g_balance_crypistol_secondary_middle_lifetime, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Crypistol_NeedManualReload())
	{
		if(autocvar_g_balance_crypistol_reload_ammo && self.clip_load < min(autocvar_g_balance_crypistol_primary_ammo, autocvar_g_balance_crypistol_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		if (self.BUTTON_ATCK)
		if (self.crypistol_release)
		{
			if (self.crypistol_waitrelease != 1)
			if (weapon_prepareattack(0, autocvar_g_balance_crypistol_primary_refire))
			{
				W_Crypistol_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_crypistol_primary_animtime, w_ready);
				self.crypistol_release = 0;
			}
		}

		if(self.BUTTON_ATCK2 && autocvar_g_balance_crypistol_secondary)
		if (self.crypistol_release)
		{
			if (self.crypistol_waitrelease != 2)
			if (weapon_prepareattack(1, autocvar_g_balance_crypistol_secondary_refire))
			{
				W_Crypistol_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_crypistol_secondary_animtime, w_ready);
				self.crypistol_release = 0;
			}
		}

		if ((self.crypistol_waitrelease == 1 && !self.BUTTON_ATCK) || (self.crypistol_waitrelease == 2 && !self.BUTTON_ATCK2))
		{
			if (!self.crylink_lastgroup || time > self.crylink_lastgroup.teleport_time)
			{
				// fired and released now!
				if(self.crylink_lastgroup)
				{
					vector pos;
					entity linkjoineffect;

					if(self.crypistol_waitrelease == 1)
					{
						pos = W_Crypistol_LinkJoin(self.crylink_lastgroup, autocvar_g_balance_crypistol_primary_joinspread * autocvar_g_balance_crypistol_primary_speed, autocvar_g_balance_crypistol_primary_jointime);

					}
					else
					{
						pos = W_Crypistol_LinkJoin(self.crylink_lastgroup, autocvar_g_balance_crypistol_secondary_joinspread * autocvar_g_balance_crypistol_secondary_speed, autocvar_g_balance_crypistol_secondary_jointime);
					}

					linkjoineffect = spawn();
					linkjoineffect.think = W_Crypistol_LinkJoinEffect_Think;
					linkjoineffect.classname = "linkjoineffect";
					linkjoineffect.nextthink = time + w_crypistol_linkjoin_time;
					linkjoineffect.owner = self;
					setorigin(linkjoineffect, pos);
				}
				self.crypistol_waitrelease = 0;
				if(!w_crypistol(WR_CHECKAMMO1) && !w_crypistol(WR_CHECKAMMO2))
				if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				{
					// ran out of ammo!
					self.cnt = WEP_CRYPISTOL;
					self.switchweapon = w_getbestweapon(self);
				}
			}
		}
		
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
			self.crypistol_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_crypistol.md3");
		precache_model ("models/weapons/v_crypistol.md3");
		precache_model ("models/weapons/h_crypistol.iqm");
		precache_sound ("weapons/crylink_fire.wav");
		precache_sound ("weapons/crylink_fire2.wav");
		precache_sound ("weapons/crylink_linkjoin.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CRYPISTOL);
		self.current_ammo = ammo_cells;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 0 -1.75';
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't "run out of ammo" and switch weapons while waiting for release
		if(self.crylink_lastgroup && self.crypistol_waitrelease)
			return TRUE;

		ammo_amount = self.ammo_cells >= autocvar_g_balance_crypistol_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_CRYPISTOL]) >= autocvar_g_balance_crypistol_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// don't "run out of ammo" and switch weapons while waiting for release
		if(self.crylink_lastgroup && self.crypistol_waitrelease)
			return TRUE;

		ammo_amount = self.ammo_cells >= autocvar_g_balance_crypistol_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_CRYPISTOL]) >= autocvar_g_balance_crypistol_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_crypistol_primary_ammo, autocvar_g_balance_crypistol_secondary_ammo), autocvar_g_balance_crypistol_reload_ammo, autocvar_g_balance_crypistol_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_crypistol(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("newcrylink_impact"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
		}
		else
		{
			pointparticles(particleeffectnum("newcrylink_impactbig"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/crylink_impact2.wav");
		precache_sound("weapons/crylink_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = _("%s succeeded at self-destructing themself with the Crypistol");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = _("%s could not hide from %s's Crypistol"); // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s was too close to %s's Crypistol"); // unchecked: SECONDARY
		else
			w_deathtypestring = _("%s took a close look at %s's Crypistol"); // unchecked: SECONDARY
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_crypistol (void)
//{
//	weapon_defaultspawnfunc(WEP_CRYPISTOL);
//}
