.vector iorigin1, iorigin2;
.float spawntime;
.vector trail_oldorigin;
.float trail_oldtime;
.float fade_time, fade_rate;

.vector cl_proj_init_avelocity; //added as the others seem to get overwritten

void SUB_Stop()
{
	self.move_velocity = self.move_avelocity = '0 0 0';
	self.move_movetype = MOVETYPE_NONE;
}

.float alphamod;
.float count; // set if clientside projectile
.float cnt; // sound index
.float gravity;
.float snd_looping;
.float silent;

void Projectile_ResetTrail(vector to)
{
	self.trail_oldorigin = to;
	self.trail_oldtime = time;
}

void Projectile_DrawTrail(vector to)
{
	vector from;
	float t0;

	from = self.trail_oldorigin;
	t0 = self.trail_oldtime;
	self.trail_oldorigin = to;
	self.trail_oldtime = time;

	// force the effect even for stationary firemine
	if(self.cnt == PROJECTILE_FIREMINE || self.cnt == PROJECTILE_CHARBELCHER)
		if(from == to)
			from_z += 1;

	if (self.traileffect)
	{
		particles_alphamin = particles_alphamax = sqrt(self.alpha);
		boxparticles(self.traileffect, self, from, to, self.velocity, self.velocity, sqrt(self.alpha), PARTICLES_USEALPHA);
	}
}

void Projectile_Draw()
{
	vector rot;
	vector trailorigin;
	float f;
	float drawn;
	float t;
	float a;

	f = self.move_flags;

	if(self.count & 0x80)
	{
		//self.move_flags &~= FL_ONGROUND;
		if(self.move_movetype == MOVETYPE_NONE || self.move_movetype == MOVETYPE_FLY)
			Movetype_Physics_NoMatchServer();
			// the trivial movetypes do not have to match the
			// server's ticrate as they are ticrate independent
			// NOTE: this assumption is only true if MOVETYPE_FLY
			// projectiles detonate on impact. If they continue
			// moving, we might still be ticrate dependent.
		else
			Movetype_Physics_MatchServer(autocvar_cl_projectiles_sloppy);
		if(!(self.move_flags & FL_ONGROUND))
			if(self.velocity != '0 0 0')
				self.move_angles = self.angles = vectoangles(self.velocity);
	}
	else
	{
		InterpolateOrigin_Do();
	}

	if(self.count & 0x80)
	{
		drawn = (time >= self.spawntime - 0.02);
		t = max(time, self.spawntime);
	}
	else
	{
		drawn = (self.iflags & IFLAG_VALID);
		t = time;
	}

	if(!(f & FL_ONGROUND))
	{
		rot = '0 0 0';
		switch(self.cnt)
		{
			/*
			case PROJECTILE_GRENADE:
				rot = '-2000 0 0'; // forward
				break;
			*/
			case PROJECTILE_GRENADE_BOUNCING:
				rot = '0 -1000 0'; // sideways
				break;
			case PROJECTILE_MORTARGRENADE_BOUNCING:
				rot = '0 -1000 0'; // sideways
				break;
			case PROJECTILE_ROCK_BOUNCING:
				rot = '0 -1000 0'; // sideways
				break;
			case PROJECTILE_HOOKBOMB:
				rot = '1000 0 0'; // forward
				break;
			case PROJECTILE_NADE_BURN:
			case PROJECTILE_NADE:
				rot = self.avelocity;
				break;
			case PROJECTILE_ROSEPETALRED:
			case PROJECTILE_ROSEPETALPINK:
			case PROJECTILE_ROSEPETALWHITE:
			case PROJECTILE_ROSEPETALBLACK:
				rot = self.cl_proj_init_avelocity;
				break;
			case PROJECTILE_FEATHERBLACK:
			case PROJECTILE_FEATHERWHITE:
				rot = self.cl_proj_init_avelocity;
				break;
			default:
				break;
		}
		self.angles = AnglesTransform_ToAngles(AnglesTransform_Multiply(AnglesTransform_FromAngles(self.angles), rot * (t - self.spawntime)));
	}

	vector ang;
	ang = self.angles;
	ang_x = -ang_x;
	makevectors(ang);

	a = 1 - (time - self.fade_time) * self.fade_rate;
	self.alpha = bound(0, self.alphamod * a, 1);
	if(self.alpha <= 0)
		drawn = 0;
	self.renderflags = 0;

	trailorigin = self.origin;
	switch(self.cnt)
	{
		case PROJECTILE_MORTARGRENADE:
		case PROJECTILE_MORTARGRENADE_BOUNCING:
		case PROJECTILE_GRENADE:
		case PROJECTILE_GRENADE_BOUNCING:
			trailorigin += v_right * 1 + v_forward * -10;
			break;
		case PROJECTILE_NADE_BURN:
		case PROJECTILE_NADE:
			trailorigin += v_up * 4;
			break;
		default:
			break;
	}
	if(drawn)
		Projectile_DrawTrail(trailorigin);
	else
		Projectile_ResetTrail(trailorigin);

	self.drawmask = 0;

	if(!drawn)
		return;

	switch(self.cnt)
	{
		case PROJECTILE_BULLET_GLOWING:
		case PROJECTILE_BULLET_GLOWING_TRACER:
			adddynamiclight(self.origin, 50 * a, '1 1 0');
			break;
		default:
			break;
	}

	self.drawmask = MASK_NORMAL;
}

void loopsound(entity e, float ch, string samp, float vol, float attn)
{
	if(self.silent)
		return;

	sound(e, ch, samp, vol, attn);
	e.snd_looping = ch;
}

void Ent_RemoveProjectile()
{
	if(self.count & 0x80)
	{
		tracebox(self.origin, self.mins, self.maxs, self.origin + self.velocity * 0.05, MOVE_NORMAL, self);
		Projectile_DrawTrail(trace_endpos);
	}
}

void Ent_Projectile()
{
	float bn = autocvar_cl_projectiles_bullets_null; //bullets_null
							 //(note, does not include
							 //the old PROJECTILE_BULLET, PROJECTILE_BULLET_GLOWING etc
							 //which are very low poly (4 triangles IIRC)
							 //and mostly used in spells now,
							 //so are not included in the turn off)
							 //This switch turns off the modeled bullets used
							 //for the guns etc.
	float f;

	// projectile properties:
	//   kind (interpolated, or clientside)
	//
	//   modelindex
	//   origin
	//   scale
	//   if clientside:
	//     velocity
	//     gravity
	//   soundindex (hardcoded list)
	//   effects
	//
	// projectiles don't send angles, because they always follow the velocity

	f = ReadByte();
	self.count = (f & 0x80);
	self.iflags = (self.iflags & IFLAG_INTERNALMASK) | IFLAG_AUTOANGLES | IFLAG_ANGLES;
	self.solid = SOLID_TRIGGER;
	//self.effects = EF_NOMODELFLAGS;

	// this should make collisions with bmodels more exact, but it leads to
	// projectiles no longer being able to lie on a bmodel
	self.move_nomonsters = MOVE_WORLDONLY;
	if(f & 0x40)
		self.move_flags |= FL_ONGROUND;
	else
		self.move_flags &~= FL_ONGROUND;

	if(!self.move_time)
	{
		// for some unknown reason, we don't need to care for
		// sv_gameplayfix_delayprojectiles here.
		self.move_time = time;
		self.spawntime = time;
	}
	else
		self.move_time = max(self.move_time, time);

	if(!(self.count & 0x80))
		InterpolateOrigin_Undo();

	if(f & 1)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
		if(self.count & 0x80)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
			if(f & 0x10)
				self.gravity = ReadCoord();
			else
				self.gravity = 0; // none
			self.move_origin = self.origin;
			self.move_velocity = self.velocity;
		}

		if(time == self.spawntime || (self.count & 0x80) || (f & 0x08))
		{
			self.trail_oldorigin = self.origin;
			if(!(self.count & 0x80))
				InterpolateOrigin_Reset();
		}

		if(f & 0x20)
		{
			self.fade_time = time + ReadByte() * ticrate;
			self.fade_rate = 1 / (ReadByte() * ticrate);
		}
		else
		{
			self.fade_time = 0;
			self.fade_rate = 0;
		}
	}

	if(f & 2)
	{
		self.cnt = ReadByte();

		self.silent = (self.cnt & 0x80);
		self.cnt = (self.cnt & 0x7F);

		self.scale = 1;
		self.traileffect = 0;
		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO: setmodel(self, "models/ebomb.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_DELUGE: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("TR_DELUGEPLASMA"); break;
			case PROJECTILE_DELUGEOIL: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("tar_TR_BLOOD"); break;
			case PROJECTILE_DELUGEMETHANE: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("insect_TR_BLOOD"); break;
			case PROJECTILE_DELUGESLIME: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("alien_TR_BLOOD"); break;
			case PROJECTILE_DELUGEFILTH: setmodel(self, "models/projdeluge2.iqm");self.traileffect = particleeffectnum("insect_TR_SLIGHTBLOOD"); break;
			case PROJECTILE_DELUGECHEM: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("robot_TR_SLIGHTBLOOD"); break;
			case PROJECTILE_DELUGELAVA: setmodel(self, "models/waterblob.iqm");self.traileffect = particleeffectnum("fireball"); break;
			case PROJECTILE_ROCKET: setmodel(self, "models/rocket.md3");self.traileffect = particleeffectnum("TR_ROCKET"); self.scale = 2; break;
			case PROJECTILE_BULLET: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET_GLOWING: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_rifle_weak"); break;
			case PROJECTILE_BULLET_GLOWING_TRACER: setmodel(self, "models/tracer.mdl");self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_CRYLINK: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_CRYLINK_BOUNCING: setmodel(self, "models/plasmatrail.mdl");self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;
			case PROJECTILE_ELECTRO_BEAM: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_GRENADE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_GRENADE_BOUNCING: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_MORTARGRENADE: setmodel(self, "models/grenademodelmortar.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_MORTARGRENADE_BOUNCING: setmodel(self, "models/grenademodelmortar.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_NADE: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_NADE_BURN: setmodel(self, "models/weapons/v_ok_grenade.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_CALTROP: setmodel(self, "models/caltrop.iqm");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_MINE: setmodel(self, "models/mine.md3");self.traileffect = particleeffectnum("TR_GRENADE"); break;
			case PROJECTILE_ATMINE: setmodel(self, "models/atmine.iqm");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_LASER: setmodel(self, "models/laser.mdl");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_HLAC: setmodel(self, "models/hlac_bullet.md3");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_PORTO_RED: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_PORTO_BLUE: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_WIZSPIKE"); self.scale = 4; break;
			case PROJECTILE_HOOKBOMB: setmodel(self, "models/grenademodel.md3");self.traileffect = particleeffectnum("TR_KNIGHTSPIKE"); break;
			case PROJECTILE_HAGAR: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("tr_hagar"); self.scale = 0.75; break;
			case PROJECTILE_HAGAR_BOUNCING: setmodel(self, "models/hagarmissile.mdl");self.traileffect = particleeffectnum("tr_hagar"); self.scale = 0.75; break;
			case PROJECTILE_FIREBALL: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("fireball"); break; // particle effect is good enough
			case PROJECTILE_FIREMINE: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("firemine"); break; // particle effect is good enough
			case PROJECTILE_FIRECENTURY: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("torchflame"); break; // particle effect is good enough
			case PROJECTILE_CHARBELCHER: self.scale = 3; setmodel(self, "models/map_xoylent/asteroid.obj"); self.traileffect = particleeffectnum("firemine"); break; // Add asteroid
			case PROJECTILE_ROCK: setmodel(self, "models/map_xoylent/asteroid.obj");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_ROCK_BOUNCING: setmodel(self, "models/map_xoylent/asteroid.obj");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_SIEGECANNON: setmodel(self, "models/sphere/cannonball.iqm");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_STARBLAST: setmodel(self, "models/plasmatrail2.mdl"); if (autocvar_cl_particles_starblast) { self.traileffect = particleeffectnum("EF_STARDUST"); } else { self.traileffect = particleeffectnum(""); } break;
			case PROJECTILE_STARBLAST_BOUNCING: setmodel(self, "models/plasmatrail2.mdl"); if (autocvar_cl_particles_starblast) { self.traileffect = particleeffectnum("EF_STARDUST"); } else { self.traileffect = particleeffectnum(""); } break;
			
			case PROJECTILE_ICEBALL: self.model = ""; self.modelindex = 0; self.traileffect = particleeffectnum("iceball"); break; // particle effect is good enough
			case PROJECTILE_TAG: setmodel(self, "models/laser.mdl"); self.traileffect = particleeffectnum("TR_ROCKET"); break;
			case PROJECTILE_FLAC: setmodel(self, "models/hagarmissile.mdl"); self.scale = 0.4; self.traileffect = particleeffectnum("TR_SEEKER"); break;
			case PROJECTILE_SEEKER: setmodel(self, "models/tagrocket.md3"); self.traileffect = particleeffectnum("TR_SEEKER"); break;

			case PROJECTILE_RAPTORBOMB:    setmodel(self, "models/vehicles/clusterbomb.md3"); self.gravity = 1; self.avelocity = '0 0 180'; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_RAPTORBOMBLET: setmodel(self, "models/vehicles/bomblet.md3");     self.gravity = 1; self.avelocity = '0 0 180'; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_RAPTORCANNON:  setmodel(self, "models/plasmatrail.mdl"); self.traileffect = particleeffectnum("TR_CRYLINKPLASMA"); break;

			case PROJECTILE_NUKEBOMB:     setmodel(self, "models/vehicles/nukebomb.md3"); self.gravity = 0.65; self.avelocity = '0 0 180'; self.traileffect = particleeffectnum("smoke_big"); break;

			case PROJECTILE_RAPTORCMISSILE:    setmodel(self, "models/vehicles/clusterbomb.md3"); self.avelocity = '0 0 180'; self.traileffect = particleeffectnum("TR_ROCKET"); break;
			case PROJECTILE_NUKECMISSILE:     setmodel(self, "models/vehicles/nukebomb.md3"); self.avelocity = '0 0 180'; self.traileffect = particleeffectnum("TR_ROCKET"); break;
			
			case PROJECTILE_ROSEPETALRED:     setmodel(self, "models/rosepetals/rosepetal.iqm"); self.skin = 0; self.scale = 0.25; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_ROSEPETALPINK:     setmodel(self, "models/rosepetals/rosepetal.iqm"); self.skin = 1; self.scale = 0.25;  self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_ROSEPETALWHITE:     setmodel(self, "models/rosepetals/rosepetal.iqm"); self.skin = 2; self.scale = 0.25;  self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_ROSEPETALBLACK:     setmodel(self, "models/rosepetals/rosepetal.iqm"); self.skin = 3; self.scale = 0.25;  self.traileffect = particleeffectnum(""); break;

			case PROJECTILE_FEATHERBLACK:     setmodel(self, "models/feathers/feathersmall.iqm"); self.skin = 0; self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_FEATHERWHITE:     setmodel(self, "models/feathers/feathersmall.iqm"); self.skin = 1; self.traileffect = particleeffectnum(""); break;

			case PROJECTILE_RPG: setmodel(self, "models/rpg7rocket.iqm");self.traileffect = particleeffectnum("TR_ROCKET"); self.scale = 1; break;

			case PROJECTILE_SPIDERROCKET: setmodel(self, "models/vehicles/rocket02.md3"); self.traileffect = particleeffectnum("spiderbot_rocket_thrust"); break;
			case PROJECTILE_WAKIROCKET:   setmodel(self, "models/vehicles/rocket01.md3");  self.traileffect = particleeffectnum("wakizashi_rocket_thrust"); break;
			case PROJECTILE_WAKICANNON:   setmodel(self, "models/laser.mdl");  self.traileffect = particleeffectnum(""); break;			
			case PROJECTILE_CROSSBOWBOLT: setmodel(self, "models/crossbowbolt.md3");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_BALLISTABOLT: setmodel(self, "models/ballistabolt.md3");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_BRBALLISTABOLT: setmodel(self, "models/ballistabolt.md3");self.traileffect = particleeffectnum("firemine"); break;
			case PROJECTILE_BURNINGBOLT: setmodel(self, "models/crossbowbolt.md3");self.traileffect = particleeffectnum("firemine"); break;
			case PROJECTILE_ARROW: setmodel(self, "models/arrowbodkin.iqm");self.traileffect = particleeffectnum(""); break;
			case PROJECTILE_BURNINGARROW: setmodel(self, "models/arrowbodkin.iqm");self.traileffect = particleeffectnum("firemine"); break;
			case PROJECTILE_BUMBLE_GUN: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;
			case PROJECTILE_BUMBLE_BEAM: setmodel(self, "models/elaser.mdl");self.traileffect = particleeffectnum("TR_NEXUIZPLASMA"); break;

			case PROJECTILE_BALLBEARING: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.scale = 1.11; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MUSKETBALL: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.skin = 2; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MUSKETBALL36: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.scale = 0.8; self.skin = 2; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MUSKETBALL69: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.scale = 1.533333; self.skin = 2; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MUSKETBALL50: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.scale = 1.11; self.skin = 2; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MINIEBALL: if(bn){self.model = "";}else{setmodel(self, "models/bulletpistol.iqm");} self.skin = 3; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MINIEBALL36: if(bn){self.model = "";}else{setmodel(self, "models/bulletpistol.iqm");} self.scale = 0.8; self.skin = 3; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_MINIEBALL50: if(bn){self.model = "";}else{setmodel(self, "models/bulletpistol.iqm");} self.scale = 1.11; self.skin = 3; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETWEBLEY: if(bn){self.model = "";}else{setmodel(self, "models/bulletwebley.iqm");} self.skin = 3; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET45ACP: if(bn){self.model = "";}else{setmodel(self, "models/bulletpistol.iqm");} self.skin = 5; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET50AE: if(bn){self.model = "";}else{setmodel(self, "models/bulletmagnum.iqm");} self.scale = 1.11; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETSHOTGUN: if(bn){self.model = "";}else{setmodel(self, "models/bulletsphere.iqm");} self.scale = 0.77; self.skin = 1; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET9MM: if(bn){self.model = "";}else{setmodel(self, "models/bulletpistol.iqm");} self.scale = 0.77; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET357MAG: if(bn){self.model = "";}else{setmodel(self, "models/bulletwebley.iqm");} self.scale = 0.77; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLET44MAG: if(bn){self.model = "";}else{setmodel(self, "models/bulletmagnum.iqm");} self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE22: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.488; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE25: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.555; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE30: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.66; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE30_G: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.66; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle_weak"); break;
			case PROJECTILE_BULLETRIFLE30_G_T: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.66; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_BULLETRIFLE9MM: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.77; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE9MM_G: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.77; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle_weak"); break;
			case PROJECTILE_BULLETRIFLE9MM_G_T: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 0.77; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_BULLETRIFLE45: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE45_G: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle_weak"); break;
			case PROJECTILE_BULLETRIFLE45_G_T: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_BULLETRIFLE50: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.11; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE50S: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.11; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE50_G: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.11; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle_weak"); break;
			case PROJECTILE_BULLETRIFLE50_G_T: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.11; self.skin = 0; self.traileffect = particleeffectnum("tr_rifle"); break;
			case PROJECTILE_BULLETRIFLE17MM: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.46; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE20MM: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 1.72; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETRIFLE30MM: if(bn){self.model = "";}else{setmodel(self, "models/bulletrifle.iqm");} self.scale = 2.58; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETSHRAPNEL: if(bn){self.model = "";}else{setmodel(self, "models/bulletshrapnel.iqm");} self.scale = 2; self.skin = 0; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETSHRAPNELSHINE: if(bn){self.model = "";}else{setmodel(self, "models/bulletshrapnel.iqm");} self.scale = 2; self.skin = 4; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETSHRAPNELDARK: if(bn){self.model = "";}else{setmodel(self, "models/bulletshrapnel.iqm");} self.scale = 2; self.skin = 2; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETSHRAPNELHOT: if(bn){self.model = "";}else{setmodel(self, "models/bulletshrapnel.iqm");} self.scale = 2; self.skin = 1; self.traileffect = particleeffectnum("tr_bullet"); break;
			case PROJECTILE_BULLETNAGANT: if(bn){self.model = "";}else{setmodel(self, "models/bulletwebley.iqm");} self.scale = 0.77; self.skin = 5; self.traileffect = particleeffectnum("tr_bullet"); break;

			default:
				error("Received invalid CSQC projectile, can't work with this!");
				break;
		}

		self.mins = '0 0 0';
		self.maxs = '0 0 0';
		self.colormod = '0 0 0';
		self.move_touch = SUB_Stop;
		self.move_movetype = MOVETYPE_TOSS;
		self.alphamod = 1;

		switch(self.cnt)
		{
			case PROJECTILE_ELECTRO:
				// only new engines support sound moving with object
				loopsound(self, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -4';
				self.maxs = '0 0 -4';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
				self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
				break;
			case PROJECTILE_DELUGEOIL:
			case PROJECTILE_DELUGEMETHANE:
			case PROJECTILE_DELUGESLIME:
			case PROJECTILE_DELUGEFILTH:
			case PROJECTILE_DELUGECHEM:
			case PROJECTILE_DELUGELAVA:
			case PROJECTILE_DELUGE:
				// only new engines support sound moving with object
				loopsound(self, CH_SHOTS_SINGLE, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -4';
				self.maxs = '0 0 -4';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
				self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
				break;
			case PROJECTILE_ROCKET:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_RPG:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-3.25 -3.25 -3.25';
				self.maxs = '3.25 3.25 3.25';
				break;
			case PROJECTILE_ROSEPETALRED:
			case PROJECTILE_ROSEPETALPINK:
			case PROJECTILE_ROSEPETALWHITE:
			case PROJECTILE_ROSEPETALBLACK:
				self.cl_proj_init_avelocity = randomvec() * 720;
				self.mins = '-1 -1 -1';
				self.maxs = '1 1 1';
				break;
			case PROJECTILE_FEATHERBLACK:
			case PROJECTILE_FEATHERWHITE:
				self.cl_proj_init_avelocity = randomvec() * 360;
				self.mins = '-1 -1 -1';
				self.maxs = '1 1 1';
				break;
			case PROJECTILE_GRENADE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_GRENADE_BOUNCING:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_grenadelauncher_bouncefactor;
				self.move_bounce_stopspeed = g_balance_grenadelauncher_bouncestop;
				break;
			case PROJECTILE_MORTARGRENADE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_MORTARGRENADE_BOUNCING:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_grenadelauncher_bouncefactor;
				self.move_bounce_stopspeed = g_balance_grenadelauncher_bouncestop;
				break;
			case PROJECTILE_NADE_BURN:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.avelocity = randomvec() * 720;
				break;
			case PROJECTILE_NADE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.avelocity = randomvec() * 720;
				break;
			case PROJECTILE_MINE:
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_ATMINE:
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_PORTO_RED:
				self.colormod = '2 1 1';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_PORTO_BLUE:
				self.colormod = '1 1 2';
				self.alphamod = 0.5;
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_HAGAR_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_CRYLINK_BOUNCING:
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				break;
			case PROJECTILE_FIREBALL:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly2.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-16 -16 -16';
				self.maxs = '16 16 16';
				break;
			case PROJECTILE_FIRECENTURY:
				//No loopsound for this
				self.mins = '-20 -20 -20';
				self.maxs = '20 20 20';
				break;
			case PROJECTILE_FIREMINE:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly.wav", VOL_BASE, ATTN_NORM);
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_CHARBELCHER:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly.wav", VOL_BASE, ATTN_NORM);
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_SIEGECANNON:
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
			case PROJECTILE_ROCK:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
			case PROJECTILE_ROCK_BOUNCING:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_grenadelauncher_bouncefactor;
				self.move_bounce_stopspeed = g_balance_grenadelauncher_bouncestop;
				break;
			case PROJECTILE_ICEBALL:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/fireball_fly2.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-16 -16 -16';
				self.maxs = '16 16 16';
				break;
			case PROJECTILE_TAG:
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_FLAC:
				self.mins = '-2 -2 -2';
				self.maxs = '2 2 2';
				break;
			case PROJECTILE_SEEKER:
				loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '-4 -4 -4';
				self.maxs = '4 4 4';
				break;
            case PROJECTILE_RAPTORBOMB:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
	    case PROJECTILE_RAPTORCMISSILE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
            case PROJECTILE_RAPTORBOMBLET:
				break;
            case PROJECTILE_RAPTORCANNON:
				break;
            case PROJECTILE_NUKEBOMB:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
	    case PROJECTILE_NUKECMISSILE:
				self.mins = '-3 -3 -3';
				self.maxs = '3 3 3';
				break;
            case PROJECTILE_SPIDERROCKET:
                loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				break;
            case PROJECTILE_WAKIROCKET:
                loopsound(self, CH_SHOTS_SINGLE, "weapons/tag_rocket_fly.wav", VOL_BASE, ATTN_NORM);
				break;            
            /*
            case PROJECTILE_WAKICANNON:
				break;
			case PROJECTILE_BUMBLE_GUN:
				// only new engines support sound moving with object
				loopsound(self, CH_SHOTS_SINGLE, "weapons/electro_fly.wav", VOL_BASE, ATTN_NORM);
				self.mins = '0 0 -4';
				self.maxs = '0 0 -4';
				self.move_movetype = MOVETYPE_BOUNCE;
				self.move_touch = func_null;
				self.move_bounce_factor = g_balance_electro_secondary_bouncefactor;
				self.move_bounce_stopspeed = g_balance_electro_secondary_bouncestop;
				break;
			*/
			default:
				break;
		}
		setsize(self, self.mins, self.maxs);
	}

	if(self.gravity)
	{
		if(self.move_movetype == MOVETYPE_FLY)
			self.move_movetype = MOVETYPE_TOSS;
		if(self.move_movetype == MOVETYPE_BOUNCEMISSILE)
			self.move_movetype = MOVETYPE_BOUNCE;
	}
	else
	{
		if(self.move_movetype == MOVETYPE_TOSS)
			self.move_movetype = MOVETYPE_FLY;
		if(self.move_movetype == MOVETYPE_BOUNCE)
			self.move_movetype = MOVETYPE_BOUNCEMISSILE;
	}

	if(!(self.count & 0x80))
		InterpolateOrigin_Note();

	self.draw = Projectile_Draw;
	self.entremove = Ent_RemoveProjectile;
}

void Projectile_Precache()
{
	precache_model("models/ebomb.mdl");
	precache_model("models/waterblob.iqm");
	precache_model("models/elaser.mdl");
	precache_model("models/grenademodel.md3");
	precache_model("models/grenademodelmortar.md3");
	precache_model("models/mine.md3");
	precache_model("models/atmine.iqm");
	precache_model("models/caltrop.iqm");
	precache_model("models/hagarmissile.mdl");
	precache_model("models/hlac_bullet.md3");
	precache_model("models/laser.mdl");
	precache_model("models/plasmatrail.mdl");
	precache_model("models/plasmatrail2.mdl");
	precache_model("models/rocket.md3");
	precache_model("models/tagrocket.md3");
	precache_model("models/tracer.mdl");
	precache_model("models/crossbowbolt.md3");
	precache_model("models/arrowbodkin.iqm");
	precache_model("models/ballistabolt.md3");
	precache_model("models/map_xoylent/asteroid.obj");
	precache_model("models/sphere/cannonball.iqm");
	precache_model("models/weapons/v_ok_grenade.md3");
	precache_model("models/rpg7rocket.iqm");
	precache_model("models/bulletsphere.iqm");
	precache_model("models/bulletwebley.iqm");
	precache_model("models/bulletmagnum.iqm");
	precache_model("models/bulletpistol.iqm");
	precache_model("models/bulletrifle.iqm");
	precache_model("models/bulletshrapnel.iqm");
	precache_model("models/rosepetals/rosepetal.iqm");
	precache_model("models/feathers/feathersmall.iqm");
	precache_model("models/projdeluge2.iqm");

	precache_sound("weapons/electro_fly.wav");
	precache_sound("machines/steam_fade.ogg");
	precache_sound("weapons/rocket_fly.wav");
	precache_sound("weapons/fireball_fly.wav");
	precache_sound("weapons/fireball_fly2.wav");
	precache_sound("weapons/tag_rocket_fly.wav");

}
