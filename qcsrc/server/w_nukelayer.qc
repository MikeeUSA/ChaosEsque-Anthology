#ifdef REGISTER_WEAPON
REGISTER_WEAPON(NUKE_LAYER, w_nukelayer, IT_ROCKETS, 4, WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_HIGH, "nukemine", "nukelayer", _("Nuke Layer"))
#else
#ifdef SVQC
void W_Nuke_Think (void);
void W_Nuke_CopyNukeSettings (entity myfrom, entity myto);
.float nukelayer_detonate, nuke_explodeanyway;
.float nuke_time;

void spawnfunc_weapon_nukelayer (void)
{
	weapon_defaultspawnfunc(WEP_NUKE_LAYER);
}

void W_Nuke_Stick (entity to)
{
	spamsound (self, CH_SHOTS, "weapons/mine_stick.wav", VOL_BASE, ATTN_NORM);

	// in order for nukes to face properly when sticking to the ground, they must be a server side entity rather than a csqc projectile

	entity newnuke;
	newnuke = spawn();
	W_Nuke_CopyNukeSettings (self, newnuke);
	newnuke.classname = self.classname;

	newnuke.bot_dodge = self.bot_dodge;
	newnuke.bot_dodgerating = self.bot_dodgerating;

	newnuke.owner = self.owner;
	newnuke.realowner = self.realowner;
	setsize(newnuke, '-4 -4 -4', '4 4 4');
	setorigin(newnuke, self.origin);
	setmodel(newnuke, "models/nukemine.md3");
	newnuke.angles = vectoangles(-trace_plane_normal); // face against the surface

	newnuke.oldvelocity = self.velocity;

	newnuke.takedamage = self.takedamage;
	newnuke.damageforcescale = self.damageforcescale;
	newnuke.health = self.health;
	newnuke.event_damage = self.event_damage;
	newnuke.spawnshieldtime = self.spawnshieldtime;

	newnuke.movetype = MOVETYPE_NONE; // lock the nuke in place
	newnuke.projectiledeathtype = self.projectiledeathtype;

	newnuke.nuke_time = self.nuke_time;

	newnuke.touch = func_null;
	newnuke.think = W_Nuke_Think;
	newnuke.nextthink = time;
	newnuke.cnt = self.cnt;
	newnuke.flags = self.flags;

	remove(self);
	self = newnuke;

	if(to)
		SetMovetypeFollow(self, to);
}

void W_Nuke_Pound_Down (entity who, float howfar)
{
		if(who != world)
		if (
		(who.classname == "tree")
		|| ( strstrofs(who.model, "tree", 0) != -1 )
		|| ( strstrofs(who.model, "lightpost", 0) != -1 )
		|| ( strstrofs(who.model, "peach", 0) != -1 )
		|| ( strstrofs(who.model, "statue", 0) != -1 )
		 ) {
		 	makevectors(who.angles);
			if (who.scale > 1)
				setorigin(who, (who.origin + v_up * (howfar*who.scale*-1))); //Down howfar Qunits.
			else
				setorigin(who, (who.origin + v_up * (howfar*-1))); //Down howfar Qunits.
		 }
}

void nukelight_thinklight() {
	if (self.color_x > 0.25) {
		//self.light_lev = self.light_lev - (self.nukelayer_radius / 600);
		if (self.color_x > 100) {
			self.color_x = self.color_x * 0.99;
			self.color_y = self.color_y * 0.99;
			self.color_z = self.color_z * 0.99;
		} else if (self.color_x > 50) {
			self.color_x = self.color_x * 0.995;
			self.color_y = self.color_y * 0.995;
			self.color_z = self.color_z * 0.995;
		} else if (self.color_x > 1) {
			self.color_x = self.color_x * 0.998;
			self.color_y = self.color_y * 0.998;
			self.color_z = self.color_z * 0.998;
		} else {
			self.color_x = self.color_x * 0.999;
			self.color_y = self.color_y * 0.999;
			self.color_z = self.color_z * 0.999;
		}
		self.nextthink = time + 0.1;
	} else {
		//print("removelight\n");
		remove(self);
	}
}

void nukelight_spawnlight(vector eorg, entity mynuke) {
	local entity newnukelight;
	newnukelight = spawn();
	newnukelight.nukelayer_radius = mynuke.nukelayer_radius;
	newnukelight.pflags = PFLAGS_FULLDYNAMIC;
	newnukelight.light_lev = newnukelight.nukelayer_radius * 2;
	newnukelight.color = '255 204 153';
	//newnukelight.skin = 1; //Projective texture cubemap#.tga
	newnukelight.style = 255;
	//newnukelight.owner = self;
	newnukelight.think = nukelight_thinklight;
	newnukelight.nextthink = time + 1;
	newnukelight.origin = eorg;
	newnukelight.origin_z = newnukelight.origin_z + 0.1;
	setorigin (newnukelight, newnukelight.origin);
}

void nukelight_spawnlight2(vector eorg, entity mynuke) {
	local entity newnukelight;
	local vector addvec;
	newnukelight = spawn();
	newnukelight.nukelayer_radius = mynuke.nukelayer_radius;
	newnukelight.pflags = PFLAGS_FULLDYNAMIC;
	newnukelight.light_lev = newnukelight.nukelayer_radius * 2;
	newnukelight.color = '255 204 153';
	//newnukelight.skin = 1; //Projective texture cubemap#.tga
	newnukelight.style = 255;
	//newnukelight.owner = self;
	newnukelight.think = nukelight_thinklight;
	newnukelight.nextthink = time + 1;
	newnukelight.origin = eorg;
	addvec = '0 0 1';
	addvec_z = newnukelight.nukelayer_radius * 0.25; //So it lights up alot;
	traceline(newnukelight.origin + '0 0 2', newnukelight.origin + '0 0 2048', MOVE_WORLDONLY, newnukelight);
	setorigin(newnukelight, trace_endpos);
}

void nukefire_think()
{
	vector oldorg;
	oldorg = self.origin;
	oldorg_z = oldorg_z + 16384;
	trailparticles(self, particleeffectnum("explosion_big"), oldorg, self.origin);
	
	self.nextthink = time + frametime;

	if(self.count > time)
	{
		remove_safely(self);
	}
}

void nukesmoke_think()
{
	vector oldorg;
	oldorg = self.origin;
	oldorg_z = oldorg_z + self.cnt;
	trailparticles(self, particleeffectnum("smoke_big"), oldorg, self.origin);
	
	self.nextthink = time + frametime;

	if(self.count > time)
	{
		remove_safely(self);
	}
}

void nukesmoke_spawn(vector eorg, float etime, float etype, float etop)
{
	local entity newnukesmoke;
	newnukesmoke = spawn();
	
	if (etype == 1)
		newnukesmoke.think = nukefire_think;
	else
		newnukesmoke.think = nukesmoke_think;
		
	newnukesmoke.nextthink = time + frametime;
	newnukesmoke.origin = eorg;
	newnukesmoke.origin_z = newnukesmoke.origin_z + 0.1;
	newnukesmoke.count = time + etime; //1200 == 20 min
	newnukesmoke.cnt = etop;
	setorigin (newnukesmoke, newnukesmoke.origin);	
}

void W_Do_Nuke_Explosion_NewEmit (entity gren);
void W_Do_Nuke_Explosion_OverTime (void)
{
	//print(ftos(self.cnt),"\n");
	if (self.cnt == 1) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.2, 0.05, 0.08);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 1, 0.05, 0.1);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 0.05, 0.12);
	} else if (self.cnt == 2) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.8, 0.05, 0.14);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.7, 0.05, 0.16);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.8, 0.05, 0.22);
	} else if (self.cnt == 3) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.6, 0.05, 0.32);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.4, 0.05, 0.42);
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.2, 0.05, 0.52);
		//Thermo Nuke Fireballs
	} else if (self.cnt == 4) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.8, 0.05, 0.6);
	} else if (self.cnt == 5) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.79, 0.05, 1.0);
	} else if (self.cnt == 6) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.78, 2, 5.0);
	} else if (self.cnt == 7) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.76, 3, 7.0);
	} else if (self.cnt == 8) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.75, 4, 9.0);
	} else if (self.cnt == 9) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.74, 5, 11.0);
	} else if (self.cnt == 10) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.73, 6, 13.0);
	} else if (self.cnt == 11) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.72, 7, 15.0);
	} else if (self.cnt == 12) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.71, 8, 17.0);
	} else if (self.cnt == 13) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.7, 9, 19.0);
	} else if (self.cnt == 14) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.69, 10, 21.0);
	} else if (self.cnt == 15) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.68, 11, 23.0);
	} else if (self.cnt == 16) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.67, 12, 25.0);
	} else if (self.cnt == 17) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.66, 13, 27.0);
	} else if (self.cnt == 18) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.65, 14, 29.0);
	} else if (self.cnt == 19) {
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.64, 15, 31.0);
	} else if (self.cnt == 20) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.64, 17, 35.0);
	} else if (self.cnt == 21) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.64, 19, 39.0);
	} else if (self.cnt == 22) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.64, 21, 43.0);
	} else if (self.cnt == 23) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.63, 23, 47.0);
	} else if (self.cnt == 24) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.63, 25, 51.0);
	} else if (self.cnt == 25) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.63, 27, 55.0);
	} else if (self.cnt == 26) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.62, 29, 59.0);
	} else if (self.cnt == 27) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.62, 31, 63.0);
	} else if (self.cnt == 28) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.62, 33, 67.0);
	} else if (self.cnt == 29) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 35, 71.0);
	} else if (self.cnt == 30) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 37, 75.0);
	} else if (self.cnt == 31) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 39, 79.0);
	} else if (self.cnt == 32) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 41, 83.0);
		
	} else if (self.cnt == 33) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 43, 93.0);
	} else if (self.cnt == 34) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 45, 103.0);
	} else if (self.cnt == 35) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 47, 203.0);
	} else if (self.cnt == 36) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.61, 49, 303.0);

	} else if (self.cnt == 37) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.83, 0.05, 60.0);
	} else if (self.cnt == 38) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 120.0);
	} else if (self.cnt == 39) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 180.0);
	} else if (self.cnt == 40) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 240.0);
	} else if (self.cnt == 41) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 300.0);
	} else if (self.cnt == 42) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 480.0);
	} else if (self.cnt == 43) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 540.0);
	} else if (self.cnt == 44) { modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.05, 600.0);
		
	} else if (self.cnt == 45) { modeleffect2_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 5, 360.0);
	} else if (self.cnt == 46) { modeleffect2_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 5, 720.0);
	} else if (self.cnt == 47) { modeleffect2_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 5, 1080.0);
	} else if (self.cnt == 48) { modeleffect2_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 5, 1440.0);
		
	} else if (self.cnt == 49) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 3, 120.0);
	} else if (self.cnt == 50) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 4, 240.0);
	} else if (self.cnt == 51) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 5, 360.0);
	} else if (self.cnt == 52) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 6, 480.0);
	} else if (self.cnt == 53) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 7, 600.0);
	} else if (self.cnt == 54) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 8, 960.0);
	} else if (self.cnt == 55) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 9, 1080.0);
	} else if (self.cnt == 56) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 10, 1200.0);
	} else if (self.cnt == 57) { modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 11, 2400.0);	
	}
	
	if (self.cnt > 57)
	{
		if(self.cnt < 72)
		{
			//5min (57 + (60*5/20))
			modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.04, 2400.0);
		}
		if(self.cnt < 102)
		{	
			//15min (57 + (60*15/20))
			modeleffect2_spawn("models/sphere/sphexp2.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.9, 0.05, 2400.0);
		}
		modeleffect2_spawn("models/sphere/sphexp3.iqm", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.82, 0.1, 2400.0);
		self.nextthink = time + 20;
	} else {
		self.nextthink = time + (sys_frametime*3.1);
	}
	self.cnt = self.cnt + 1;
	if (time > self.count + 21)
	{
		if (self.cnt < 597)
		{
			//3hrs(57 + (60*60*3/20))
			W_Do_Nuke_Explosion_NewEmit(self);
		}
		remove(self);
	}
}

void W_Do_Nuke_Explosion_NewEmit (entity gren)
{
	//print("newemit\n");
	entity e;
	e = spawn();
	
	//W_Nuke_CopyNukeSettings (gren, e);
	e.nukelayer_radius = gren.nukelayer_radius;
	//print("New Emit\n");

	e.owner  = gren.owner;
	e.realowner  = gren.realowner;
	e.origin = gren.origin;
	e.classname = "nukeemit";
	e.event_damage = func_null;
	e.takedamage = DAMAGE_NO;
	setsize (e, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot
	setorigin(e, e.origin);
	e.think = W_Do_Nuke_Explosion_OverTime;
	e.count = time;
	e.nextthink = time; //Start Right Away
	e.cnt = gren.cnt;
	CSQCProjectile(e, TRUE, PROJECTILE_MINE, TRUE);
}

void W_Do_Nuke_Explosion_OverTimeSpawn (entity gren)
{
	entity e;
	e = spawn();
	
	//W_Nuke_CopyNukeSettings (gren, e);
	e.nukelayer_radius = gren.nukelayer_radius;
	//print("New Do Explosion OverTimeSpawn\n");
	
	e.owner  = gren.owner;
	e.realowner  = gren.realowner;
	e.origin = gren.origin;
	e.classname = "nukeemit";
	e.event_damage = func_null;
	e.takedamage = DAMAGE_NO;
	setsize (e, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot
	setorigin(e, e.origin);
	e.think = W_Do_Nuke_Explosion_OverTime;
	e.count = time;
	e.nextthink = time; //Start Right Away
	e.cnt = 0;
	CSQCProjectile(e, TRUE, PROJECTILE_MINE, TRUE);
}

void Foliage_Remove_Self();
void W_Do_Nuke_Explosion ()
{
	//print(ftos(self.nukelayer_damage),"\n");
	RadiusDamage (self, self.realowner, self.nukelayer_damage, self.nukelayer_edgedamage, self.nukelayer_radius, world, autocvar_g_balance_nukelayer_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	nukesmoke_spawn(self.origin, 2400, 0, 2048);
	nukesmoke_spawn(self.origin, 2400, 1, 2048);


	//Start Explosion Shockwave and fireball
	if (autocvar_g_balance_nukelayer_enableshockwave == 1) {
	if (self.nukelayer_radius > 7999) {
		//Use ambients now, don't need super costly dynamic lights
	 	//nukelight_spawnlight(self.origin, self); //Ground light
		////nukelight_spawnlight2(self.origin, self); //High light
		//Thermo Nuke Shockwaves
		W_Do_Nuke_Explosion_OverTimeSpawn(self);
	} else if (self.nukelayer_radius > 5999) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.6, 0.05, 0.22);
		//Secondary Fireball
		modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.60, 0.05, 0.4);
		
	} else if (self.nukelayer_radius > 3999) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.4, 0.05, 0.22);
		
	} else if (self.nukelayer_radius > 1999) {
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.2, 0.05, 0.22);
		
	} else if (self.nukelayer_radius > 499) {
		//Pushes vapor away
		modeleffect2_spawn("models/sphere/sphere.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.1, 0.05, 0.22);
		
	}
	
	modeleffect2_spawn("models/sphere/sphexp.md3", 0, 0, self.origin, '0 0 0', '0 0 0', '0 0 0', 0, self.nukelayer_radius, 0.95, 0.05, 0.25);
	
	}
	//End Explosion Shockwave and Fireball


	//Spontanious Ignition
	
	//Ring 0
	local entity eburn;
	eburn = findradius(self.origin, self.nukelayer_fire0_radius * self.nukelayer_radius);
	while(eburn)
	{
		if (eburn.classname == "tree"
		|| eburn.classname == "bush") {
			eburn.alpha = -1;
			eburn.skin = 0;
			
			eburn.solid = SOLID_NOT;
			
			eburn.mins = ('0 0 0');
			eburn.maxs = ('0 0 0');
				
			eburn.classname = "";
			
			setmodel(eburn, "null");
			eburn.model = string_null;
			eburn.lodmodel1 = string_null;
			eburn.lodmodel2 = string_null;
			
			eburn.fire_endtime = 0;
			
			eburn.think = Foliage_Remove_Self;
			eburn.nextthink = time;
		} else if(eburn != world) {
			//Burn EVERYTHING left
			Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire0_damage *
			self.nukelayer_fire0_burntime, self.nukelayer_fire0_burntime, 
			self.projectiledeathtype | HITTYPE_BOUNCE);
			
			//if (eburn.classname == "building")
			//	nukesmoke_spawn(eburn.origin, 1200, 0, 2048);
		}
		
		eburn = eburn.chain;
		
		
		//print(strcat(self.realowner.netname, " model ", self.realowner.model, " ro\n"));
		//print(strcat(self.netname, " model ", self.model, " self\n"));
		//print(strcat(other.netname, " model ", other.model, " other\n"));
		//print(strcat(eburn.netname, " model ", eburn.model, " eburn\n"));
		
		W_Nuke_Pound_Down(eburn, 512);
	}
	
	//Ring 1
	eburn = findradius(self.origin, self.nukelayer_fire1_radius * self.nukelayer_radius);
	while(eburn)
	{
		//Burn EVERYTHING
		if(eburn != world) {
			Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire1_damage *
			self.nukelayer_fire1_burntime, self.nukelayer_fire1_burntime, 
			self.projectiledeathtype | HITTYPE_BOUNCE);
			
			if (eburn.classname == "tree"
			|| eburn.classname == "bush"
			|| (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3))
			|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count))
			) {
				eburn.fire_intensity = 30;
			}
		}
		
		eburn = eburn.chain;
		
		W_Nuke_Pound_Down(eburn, 256);
	}
	
	//Ring 2
	eburn = findradius(self.origin, self.nukelayer_fire2_radius * self.nukelayer_radius);
	while(eburn)
	{
	if ((eburn.classname == "player" && eburn.health > 0) || eburn.classname == "tree" || eburn.classname == "bush" || (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) )
		Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire2_damage *
		self.nukelayer_fire2_burntime, self.nukelayer_fire2_burntime, 
		self.projectiledeathtype | HITTYPE_BOUNCE);
		
		if (eburn.classname == "tree"
		|| eburn.classname == "bush"
		|| (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3))
		|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) ) {
			eburn.fire_intensity = 25;
		}
		
		eburn = eburn.chain;
		
		W_Nuke_Pound_Down(eburn, 128);
	}
	
	//Ring 3
	eburn = findradius(self.origin, self.nukelayer_fire3_radius * self.nukelayer_radius);
	while(eburn)
	{
	if ((eburn.classname == "player" && eburn.health > 0) || eburn.classname == "tree" || eburn.classname == "bush" || (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) )
		Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire3_damage *
		self.nukelayer_fire3_burntime, self.nukelayer_fire3_burntime, 
		self.projectiledeathtype | HITTYPE_BOUNCE);
		
		if (eburn.classname == "tree"
		|| eburn.classname == "bush"
		|| (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3))
		|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) ) {
			eburn.fire_intensity = 15;
		}
		
		eburn = eburn.chain;
		
		W_Nuke_Pound_Down(eburn, 64);
	}
	
	//Ring 4
	eburn = findradius(self.origin, self.nukelayer_fire4_radius * self.nukelayer_radius);
	while(eburn)
	{
	if ((eburn.classname == "player" && eburn.health > 0) || eburn.classname == "tree" || eburn.classname == "bush" || (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) )
		Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire4_damage *
		self.nukelayer_fire4_burntime, self.nukelayer_fire4_burntime, 
		self.projectiledeathtype | HITTYPE_BOUNCE);
		
		if (eburn.classname == "tree"
		|| eburn.classname == "bush"
		|| (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3))
		|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) ) {
			eburn.fire_intensity = 10;
		}
		
		eburn = eburn.chain;
		
		W_Nuke_Pound_Down(eburn, 32);
	}
	
	//Ring 5
	eburn = findradius(self.origin, self.nukelayer_fire5_radius * self.nukelayer_radius);
	while(eburn)
	{
	if ((eburn.classname == "player" && eburn.health > 0) || eburn.classname == "tree" || eburn.classname == "bush" || (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3)) || (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) )
		Fire_AddDamage(eburn, self.realowner, self.nukelayer_fire5_damage *
		self.nukelayer_fire5_burntime, self.nukelayer_fire5_burntime, 
		self.projectiledeathtype | HITTYPE_BOUNCE);
		
		if (eburn.classname == "tree"
		|| eburn.classname == "bush"
		|| (eburn.abdbldcanburn && (autocvar_g_spawnmiscitemsaround_abdbld_extendeddamage >= 3))
		|| (eburn.classname == "bldhitbx" && multitool_iswooden(eburn.count)) ) {
			eburn.fire_intensity = 5;
		}
		
		eburn = eburn.chain;
	}
	
	//End Spontanious Ignition
	
	//Flash Full
	eburn = findradius(self.origin, self.nukelayer_radius * 10);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 105) {
			eburn.stat_nukeflash = 105;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Less
	eburn = findradius(self.origin, self.nukelayer_radius * 15);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 95) {
			eburn.stat_nukeflash = 95;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesser
	eburn = findradius(self.origin, self.nukelayer_radius * 20);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 85) {
			eburn.stat_nukeflash = 85;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesser
	eburn = findradius(self.origin, self.nukelayer_radius * 25);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 75) {
			eburn.stat_nukeflash = 75;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesserer
	eburn = findradius(self.origin, self.nukelayer_radius * 30);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 65) {
			eburn.stat_nukeflash = 65;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesserer3r
	eburn = findradius(self.origin, self.nukelayer_radius * 40);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 55) {
			eburn.stat_nukeflash = 55;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesserer3rer
	eburn = findradius(self.origin, self.nukelayer_radius * 50);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 45) {
			eburn.stat_nukeflash = 45;
		}
		
		eburn = eburn.chain;
	}
	
	//Flash Lesserer3rerer
	eburn = findradius(self.origin, self.nukelayer_radius * 60);
	while(eburn)
	{
		if (eburn.classname == "player")
		if (eburn.stat_nukeflash < 35) {
			eburn.stat_nukeflash = 35;
		}
		
		eburn = eburn.chain;
	}
	
}

void W_Nuke_Explode ()
{
	if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	W_Do_Nuke_Explosion();

	if (self.realowner.weapon == WEP_NUKE_LAYER)
	{
		entity oldself;
		oldself = self;
		self = self.realowner;
		if (!weapon_action(WEP_NUKE_LAYER, WR_CHECKAMMO1))
		{
			self.cnt = WEP_NUKE_LAYER;
			ATTACK_FINISHED(self) = time;
			self.switchweapon = w_getbestweapon(self);
		}
		self = oldself;
	}
	self.realowner.nukelayer_nukes -= 1;
	remove (self);
}

void W_Nuke_DoRemoteExplode ()
{
	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	if(self.movetype == MOVETYPE_NONE || self.movetype == MOVETYPE_FOLLOW)
		self.velocity = self.oldvelocity;

	W_Do_Nuke_Explosion();

	if (self.realowner.weapon == WEP_NUKE_LAYER)
	{
		entity oldself;
		oldself = self;
		self = self.realowner;
		if (!weapon_action(WEP_NUKE_LAYER, WR_CHECKAMMO1))
		{
			self.cnt = WEP_NUKE_LAYER;
			ATTACK_FINISHED(self) = time;
			self.switchweapon = w_getbestweapon(self);
		}
		self = oldself;
	}
	self.realowner.nukelayer_nukes -= 1;
	remove (self);
}

void W_Nuke_RemoteExplode ()
{
	if(self.realowner.deadflag == DEAD_NO)
		if((self.spawnshieldtime >= 0)
			? (time >= self.spawnshieldtime) // timer
			: (vlen(NearestPointOnBox(self.realowner, self.origin) - self.origin) > autocvar_g_balance_nukelayer_remote_radius) // safety device
		)
		{
			W_Nuke_DoRemoteExplode();
		}
}

void W_Nuke_ProximityExplode ()
{
	// make sure no friend is in the nuke's radius. If there is any, explosion is delayed until he's at a safe distance
	if(autocvar_g_balance_nukelayer_protection && self.nuke_explodeanyway == 0)
	{
		entity head;
		head = findradius(self.origin, self.nukelayer_radius);
		while(head)
		{
			if(head == self.realowner || !IsDifferentTeam(head, self.realowner))
				return;
			head = head.chain;
		}
	}

	self.nuke_time = 0;
	W_Nuke_Explode();
}

float W_Nuke_Count(entity e)
{
	float nukecount;
	entity nuke;
	for(nuke = world; (nuke = find(nuke, classname, "nuke")); ) if(nuke.realowner == e)
		nukecount += 1;
		
	return nukecount;
}

void W_Nuke_Think (void)
{
	//print(ftos(self.nukelayer_damage),"- NThinkEntity: ", etos(self),"\n");
	entity head;

	self.nextthink = time;

	if(self.movetype == MOVETYPE_FOLLOW)
	{
		if(LostMovetypeFollow(self))
		{
			UnsetMovetypeFollow(self);
			self.movetype = MOVETYPE_NONE;
		}
	}
	
	// our lifetime has expired, it's time to die - nuke_time just allows us to play a sound for this
	// TODO: replace this mine_trigger.wav sound with a real countdown
	if ((time > self.cnt) && (!self.nuke_time))
	{
		if(autocvar_g_balance_nukelayer_lifetime_countdown > 0)
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
		self.nuke_time = time + autocvar_g_balance_nukelayer_lifetime_countdown;
		self.nuke_explodeanyway = 1; // make the nuke super aggressive -- Samual: Rather, make it not care if a team mate is near.
	}

	// shall explode if he disconnects or dies
	// Not for nukes

	// set the nuke for detonation when a foe gets close enough
	head = findradius(self.origin, autocvar_g_balance_nukelayer_proximityradius);
	while(head)
	{
		if(head.classname == "player" && head.deadflag == DEAD_NO)
		if(head != self.realowner && IsDifferentTeam(head, self.realowner)) // don't trigger for team mates
		if(!self.nuke_time)
		{
			spamsound (self, CH_SHOTS, "weapons/mine_trigger.wav", VOL_BASE, ATTN_NORM);
			self.nuke_time = time + autocvar_g_balance_nukelayer_time;
		}
		head = head.chain;
	}

	// explode if it's time to
	if(self.nuke_time && time >= self.nuke_time)
	{
		W_Nuke_ProximityExplode();
		return;
	}

	// remote detonation
	if (self.realowner.weapon == WEP_NUKE_LAYER)
	if (self.realowner.deadflag == DEAD_NO)
	if (self.nukelayer_detonate)
		W_Nuke_RemoteExplode();
}

void W_Nuke_Touch (void)
{
	if(self.movetype == MOVETYPE_NONE || self.movetype == MOVETYPE_FOLLOW)
		return; // we're already a stuck nuke, why do we get called? TODO does this even happen?

	PROJECTILE_TOUCH;

	if(other && other.classname == "player" && other.deadflag == DEAD_NO)
	{
		// hit a player
		// don't stick
	}
	else
	{
		W_Nuke_Stick(other);
	}
}

void W_Nuke_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
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
		W_PrepareExplosionByDamage(attacker, W_Nuke_Explode);
}

void W_Nuke_CopyNukeSettings (entity myfrom, entity myto)
{
myto.nukelayer_damage = myfrom.nukelayer_damage;
myto.nukelayer_damageforcescale = myfrom.nukelayer_damageforcescale;
myto.nukelayer_edgedamage = myfrom.nukelayer_edgedamage;
myto.nukelayer_radius = myfrom.nukelayer_radius;
myto.nukelayer_force = myfrom.nukelayer_force;
myto.nukelayer_fire0_damage =  myfrom.nukelayer_fire0_damage;
myto.nukelayer_fire0_burntime =  myfrom.nukelayer_fire0_burntime;
myto.nukelayer_fire0_radius =  myfrom.nukelayer_fire0_radius;
myto.nukelayer_fire1_damage =  myfrom.nukelayer_fire1_damage;
myto.nukelayer_fire1_burntime =  myfrom.nukelayer_fire1_burntime;
myto.nukelayer_fire1_radius =  myfrom.nukelayer_fire1_radius;
myto.nukelayer_fire2_damage =  myfrom.nukelayer_fire2_damage;
myto.nukelayer_fire2_burntime =  myfrom.nukelayer_fire2_burntime;
myto.nukelayer_fire2_radius =  myfrom.nukelayer_fire2_radius;
myto.nukelayer_fire3_damage =  myfrom.nukelayer_fire3_damage;
myto.nukelayer_fire3_burntime =  myfrom.nukelayer_fire3_burntime;
myto.nukelayer_fire3_radius =  myfrom.nukelayer_fire3_radius;
myto.nukelayer_fire4_damage =  myfrom.nukelayer_fire4_damage;
myto.nukelayer_fire4_burntime =  myfrom.nukelayer_fire4_burntime;
myto.nukelayer_fire4_radius =  myfrom.nukelayer_fire4_radius;
myto.nukelayer_fire5_damage =  myfrom.nukelayer_fire5_damage;
myto.nukelayer_fire5_burntime =  myfrom.nukelayer_fire5_burntime;
myto.nukelayer_fire5_radius = myfrom.nukelayer_fire5_radius;
}

void W_Nuke_Set_Standard (entity mynuke)
{
mynuke.nukelayer_damage = autocvar_g_balance_nukelayer_damage;
mynuke.nukelayer_damageforcescale = autocvar_g_balance_nukelayer_damageforcescale;
mynuke.nukelayer_edgedamage = autocvar_g_balance_nukelayer_edgedamage;
mynuke.nukelayer_radius = autocvar_g_balance_nukelayer_radius;
mynuke.nukelayer_force = autocvar_g_balance_nukelayer_force;
mynuke.nukelayer_fire0_damage =  autocvar_g_balance_nukelayer_fire0_damage;
mynuke.nukelayer_fire0_burntime =  autocvar_g_balance_nukelayer_fire0_burntime;
mynuke.nukelayer_fire0_radius =  autocvar_g_balance_nukelayer_fire0_radius;
mynuke.nukelayer_fire1_damage =  autocvar_g_balance_nukelayer_fire1_damage;
mynuke.nukelayer_fire1_burntime =  autocvar_g_balance_nukelayer_fire1_burntime;
mynuke.nukelayer_fire1_radius =  autocvar_g_balance_nukelayer_fire1_radius;
mynuke.nukelayer_fire2_damage =  autocvar_g_balance_nukelayer_fire2_damage;
mynuke.nukelayer_fire2_burntime =  autocvar_g_balance_nukelayer_fire2_burntime;
mynuke.nukelayer_fire2_radius =  autocvar_g_balance_nukelayer_fire2_radius;
mynuke.nukelayer_fire3_damage =  autocvar_g_balance_nukelayer_fire3_damage;
mynuke.nukelayer_fire3_burntime =  autocvar_g_balance_nukelayer_fire3_burntime;
mynuke.nukelayer_fire3_radius =  autocvar_g_balance_nukelayer_fire3_radius;
mynuke.nukelayer_fire4_damage =  autocvar_g_balance_nukelayer_fire4_damage;
mynuke.nukelayer_fire4_burntime =  autocvar_g_balance_nukelayer_fire4_burntime;
mynuke.nukelayer_fire4_radius =  autocvar_g_balance_nukelayer_fire4_radius;
mynuke.nukelayer_fire5_damage =  autocvar_g_balance_nukelayer_fire5_damage;
mynuke.nukelayer_fire5_burntime =  autocvar_g_balance_nukelayer_fire5_burntime;
mynuke.nukelayer_fire5_radius = autocvar_g_balance_nukelayer_fire5_radius;
}

void W_Nuke_Attack (void)
{
	entity nuke;
	entity flash;

	// scan how many nukes we placed, and return if we reached our limit
	if(autocvar_g_balance_nukelayer_limit)
	{
	
		if(W_Nuke_Count(self) >= autocvar_g_balance_nukelayer_limit)
		{
			// the refire delay keeps this message from being spammed
			sprint(self, strcat("You cannot place more than ^2", ftos(autocvar_g_balance_nukelayer_limit), " ^7nukes at a time\n") );
			play2(self, "weapons/unavailable.wav");
			return;
		}
	}

	W_DecreaseAmmo(ammo_rockets, autocvar_g_balance_nukelayer_ammo, autocvar_g_balance_nukelayer_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-4 -4 -4', '4 4 4', FALSE, 5, "weapons/mine_fire.wav", CH_WEAPON_A, autocvar_g_balance_nukelayer_damage);
	pointparticles(particleeffectnum("rocketlauncher_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	nuke = WarpZone_RefSys_SpawnSameRefSys(self);
	nuke.owner = nuke.realowner = self;
	W_Nuke_Set_Standard(nuke);
	if(autocvar_g_balance_nukelayer_detonatedelay >= 0)
		nuke.spawnshieldtime = time + autocvar_g_balance_nukelayer_detonatedelay;
	else
		nuke.spawnshieldtime = -1;
	nuke.classname = "nuke";
	nuke.bot_dodge = TRUE;
	nuke.bot_dodgerating = nuke.nukelayer_damage * 2; // * 2 because it can detonate inflight which makes it even more dangerous

	nuke.takedamage = DAMAGE_YES;
	nuke.damageforcescale = nuke.nukelayer_damageforcescale;
	nuke.health = autocvar_g_balance_nukelayer_health;
	nuke.event_damage = W_Nuke_Damage;

	nuke.movetype = MOVETYPE_TOSS;
	PROJECTILE_MAKETRIGGER(nuke);
	nuke.projectiledeathtype = WEP_NUKE_LAYER;
	setsize (nuke, '-4 -4 -4', '4 4 4'); // give it some size so it can be shot

	setorigin (nuke, w_shotorg - v_forward * 4); // move it back so it hits the wall at the right point
	W_SetupProjectileVelocity(nuke, autocvar_g_balance_nukelayer_speed, 0);
	nuke.angles = vectoangles (nuke.velocity);

	nuke.touch = W_Nuke_Touch;
	nuke.think = W_Nuke_Think;
	nuke.nextthink = time;
	nuke.cnt = time + (autocvar_g_balance_nukelayer_lifetime - autocvar_g_balance_nukelayer_lifetime_countdown);
	nuke.flags = FL_PROJECTILE;

	CSQCProjectile(nuke, TRUE, PROJECTILE_MINE, TRUE);

	// muzzle flash for 1st person view
	flash = spawn ();
	setmodel (flash, "models/flash.md3"); // precision set below
	SUB_SetFade (flash, time, 0.1);
	flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
	W_AttachToShotorg(flash, '5 0 0');

	// common properties
	//print(ftos(nuke.nukelayer_damage),"- Entity: ", etos(nuke),"\n");
	other = nuke; MUTATOR_CALLHOOK(EditProjectile);
	
	self.nukelayer_nukes = W_Nuke_Count(self);
}

void spawnfunc_weapon_nukelayer (void); // defined in t_items.qc

float W_PlacedNukes(float detonate)
{
	entity nuke;
	float minfound;

	for(nuke = world; (nuke = find(nuke, classname, "nuke")); ) if(nuke.realowner == self)
	{
		if(detonate)
		{
			if(!nuke.nukelayer_detonate)
			{
				nuke.nukelayer_detonate = TRUE;
				minfound = 1;
			}
		}
		else
			minfound = 1;
	}
	return minfound;
}

float W_NukeLayer_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_nukelayer_reload_ammo && self.clip_load < autocvar_g_balance_nukelayer_ammo))
	{
		return 1;
	} else {
		return 0;
	}
	
}

float w_nukelayer(float req)
{
	entity nuke;
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_NukeLayer_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		// aim and decide to fire if appropriate
		self.BUTTON_ATCK = bot_aim(autocvar_g_balance_nukelayer_speed, 0, autocvar_g_balance_nukelayer_lifetime, FALSE);
		if(skill >= 2) // skill 0 and 1 bots won't detonate nukes!
		{
			// decide whether to detonate nukes
			entity targetlist, targ;
			float edgedamage, coredamage, edgeradius, recipricoledgeradius, d;
			float selfdamage, teamdamage, enemydamage;
			edgedamage = autocvar_g_balance_nukelayer_edgedamage;
			coredamage = autocvar_g_balance_nukelayer_damage;
			edgeradius = autocvar_g_balance_nukelayer_radius;
			recipricoledgeradius = 1 / edgeradius;
			selfdamage = 0;
			teamdamage = 0;
			enemydamage = 0;
			targetlist = findchainfloat(bot_attack, TRUE);
			nuke = find(world, classname, "nuke");
			while (nuke)
			{
				if (nuke.realowner != self)
				{
					nuke = find(nuke, classname, "nuke");
					continue;
				}
				targ = targetlist;
				while (targ)
				{
					d = vlen(targ.origin + (targ.mins + targ.maxs) * 0.5 - nuke.origin);
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
				nuke = find(nuke, classname, "nuke");
			}
			float desirabledamage;
			desirabledamage = enemydamage;
			if (time > self.invincible_finished && time > self.spawnshieldtime)
				desirabledamage = desirabledamage - selfdamage * autocvar_g_balance_selfdamagepercent;
			if (teamplay && self.team)
				desirabledamage = desirabledamage - teamdamage;

			nuke = find(world, classname, "nuke");
			while (nuke)
			{
				if (nuke.realowner != self)
				{
					nuke = find(nuke, classname, "nuke");
					continue;
				}
				makevectors(nuke.v_angle);
				targ = targetlist;
				if (skill > 9) // normal players only do this for the target they are tracking
				{
					targ = targetlist;
					while (targ)
					{
						if (
							(v_forward * normalize(nuke.origin - targ.origin)< 0.1)
							&& desirabledamage > 0.1*coredamage
						)self.BUTTON_ATCK2 = TRUE;
						targ = targ.chain;
					}
				}else{
					float distance; distance= bound(300,vlen(self.origin-self.enemy.origin),30000);
					//As the distance gets larger, a correct detonation gets near imposible
					//Bots are assumed to use the nuke spawnfunc_light to see if the nuke gets near a player
					if(v_forward * normalize(nuke.origin - self.enemy.origin)< 0.1)
						if(self.enemy.classname == "player")
							if(desirabledamage >= 0.1*coredamage)
								if(random()/distance*300 > frametime*bound(0,(10-skill)*0.2,1))
									self.BUTTON_ATCK2 = TRUE;
				//	dprint(ftos(random()/distance*300),">");dprint(ftos(frametime*bound(0,(10-skill)*0.2,1)),"\n");
				}

				nuke = find(nuke, classname, "nuke");
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
	else if (req == WR_THINK && !W_NukeLayer_NeedManualReload())
	{
		if(autocvar_g_balance_nukelayer_reload_ammo && self.clip_load < autocvar_g_balance_nukelayer_ammo) // forced reload
		{			
				weapon_action(self.weapon, WR_RELOAD);
		}
		else if (self.BUTTON_ATCK)
		{
			if(weapon_prepareattack(0, autocvar_g_balance_nukelayer_refire))
			{
				W_Nuke_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nukelayer_animtime, w_ready);

				//We lose the weapon
				if (self.weapon == 0)
				{
					// just in case
				}
				else if(!WEPSET_CONTAINS_EW(self, self.weapon)) 
				{
					//Do nothing
				}
				else
				{
					WEPSET_ANDNOT_EW(self, self.weapon);
					W_SwitchWeapon_Force(self, w_getbestweapon(self));
				}
	
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/flash.md3");
		precache_model ("models/nukemine.md3");
		precache_model ("models/weapons/g_nukemine.md3");
		precache_model ("models/weapons/v_nukemine.md3");
		precache_model ("models/weapons/h_nukemine.iqm");
		precache_model ("models/sphere/sphere.md3");
		precache_model ("models/sphere/sphexp.md3");
		precache_model ("models/sphere/sphexp2.iqm");
		precache_model ("models/sphere/sphexp3.iqm");
		if(cvar("g_spawnmiscitemsaround")) {
			precache_model ("models/misc/abandoned_tower1_ruin1.bsp");
			precache_model ("models/misc/abandoned_tower1_ruin2.bsp");
			precache_model ("models/misc/abandoned_gtower1_ruin0.bsp");
			precache_model ("models/misc/abandoned_gtower1_ruin1.bsp");
			precache_model ("models/misc/abandoned_gtower1_ruin2.bsp");
			precache_model ("models/misc/abandoned_sc_ruin1.bsp");
			precache_model ("models/misc/abandoned_sc_ruin2.bsp");
		}
		precache_sound ("weapons/mine_det.wav");
		precache_sound ("weapons/mine_fire.wav");
		precache_sound ("weapons/mine_stick.wav");
		precache_sound ("weapons/mine_trigger.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_NUKE_LAYER);
		self.current_ammo = ammo_rockets;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// don't switch while placing a nuke
		if (ATTACK_FINISHED(self) <= time || self.weapon != WEP_NUKE_LAYER)
		{
			ammo_amount = self.ammo_rockets >= autocvar_g_balance_nukelayer_ammo;
			ammo_amount += self.weapon_load[WEP_NUKE_LAYER] >= autocvar_g_balance_nukelayer_ammo;
			return ammo_amount;
		}
	}
	else if (req == WR_CHECKAMMO2)
	{
		if (W_PlacedNukes(FALSE))
			return TRUE;
		else
			return FALSE;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(autocvar_g_balance_nukelayer_ammo, autocvar_g_balance_nukelayer_reload_ammo, autocvar_g_balance_nukelayer_reload_time, "weapons/reload.wav");
	}
	return TRUE;
};
#endif
#ifdef CSQC
float w_nukelayer(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("rocket_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/nuke_exp.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/nuke_exp.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s exploded");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE) // (remote detonation)
			w_deathtypestring = _("%s got too close to %s's nuke");
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s almost dodged %s's nuke");
		else
			w_deathtypestring = _("%s stepped on %s's nuke");
	}
	return TRUE;
}
#endif
#endif
