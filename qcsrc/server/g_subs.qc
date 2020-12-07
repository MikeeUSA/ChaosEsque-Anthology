void SUB_NullThink(void) { }

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove;
void()  SUB_CalcMoveDone;
void() SUB_CalcAngleMoveDone;
//void() SUB_UseTargets;
void() SUB_Remove;

.string platmovetype;
.float platmovetype_start;
.float platmovetype_end;
.float platmovetype_turn;
.string curvetarget;

void spawnfunc_info_null (void)
{
	remove(self);
	// if anything breaks, tell the mapper to fix his map! info_null is meant to remove itself immediately.
}

void setanim(entity e, vector anim, float looping, float override, float restart)
{
	if (!anim)
		return; // no animation was given to us! We can't use this. 
		
	if (anim_x == e.animstate_startframe)
	if (anim_y == e.animstate_numframes)
	if (anim_z == e.animstate_framerate)
	{
		if(restart)
		{
			if(restart > 0)
			if(anim_y == 1) // ZYM animation
				BITXOR_ASSIGN(e.effects, EF_RESTARTANIM_BIT);
		}
		else
			return;
	}
	e.animstate_startframe = anim_x;
	e.animstate_numframes = anim_y;
	e.animstate_framerate = anim_z;
	e.animstate_starttime = servertime - 0.1 * serverframetime; // shift it a little bit into the past to prevent float inaccuracy hiccups
	e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
	e.animstate_looping = looping;
	e.animstate_override = override;
	e.frame = e.animstate_startframe;
	e.frame1time = servertime;
}

void updateanim(entity e)
{
	if (time >= e.animstate_endtime)
	{
		if (e.animstate_looping)
		{
			e.animstate_starttime = e.animstate_endtime;
			e.animstate_endtime = e.animstate_starttime + e.animstate_numframes / e.animstate_framerate;
		}
		e.animstate_override = FALSE;
	}
	e.frame = e.animstate_startframe + bound(0, (time - e.animstate_starttime) * e.animstate_framerate, e.animstate_numframes - 1);
	//print(ftos(time), " -> ", ftos(e.frame), "\n");
}

////////////Only here in xonotic-concrete branch, elsewhere (utils) in xonotic-stable (bendy-models) branch
vector animfixfps(entity e, vector a)
{
	// multi-frame anim: keep as-is
	if(a_y == 1)
	{
		float dur;
		dur = frameduration(e.modelindex, a_x);
		if(dur > 0)
			a_z = 1.0 / dur;
	}
	return a;
}
////////////

/*
==================
SUB_Remove

Remove self
==================
*/
void SUB_Remove (void)
{
	remove (self);
}

/*
==================
SUB_Friction

Applies some friction to self
==================
*/
.float friction;
void SUB_Friction (void)
{
	self.nextthink = time;
	if(self.flags & FL_ONGROUND)
		self.velocity = self.velocity * (1 - frametime * self.friction);
}

/*
==================
SUB_VanishOrRemove

Makes client invisible or removes non-client
==================
*/
void SUB_VanishOrRemove (entity ent)
{
	if (ent.flags & FL_CLIENT)
	{
		// vanish
		ent.alpha = -1;
		ent.effects = 0;
		ent.glow_size = 0;
		ent.pflags = 0;
	}
	else
	{
		// remove
		remove (ent);
	}
}

void SUB_SetFade_Think (void)
{
	if(self.alpha == 0)
		self.alpha = 1;
	self.think = SUB_SetFade_Think;
	self.nextthink = time;
	self.alpha -= frametime * self.fade_rate;
	if (self.alpha < 0.01)
		SUB_VanishOrRemove(self);
	else
		self.nextthink = time;
}

/*
==================
SUB_SetFade

Fade 'ent' out when time >= 'when'
==================
*/
void SUB_SetFade (entity ent, float when, float fadetime)
{
	//if (ent.flags & FL_CLIENT) // && ent.deadflag != DEAD_NO)
	//	return;
	//ent.alpha = 1;
	ent.fade_rate = 1/fadetime;
	ent.think = SUB_SetFade_Think;
	ent.nextthink = when;
}

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void SUB_CalcMoveDone (void)
{
	// After moving, set origin to exact final destination

	setorigin (self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1 && self.think1 != SUB_CalcMoveDone) //Avoid endless loops
		self.think1 ();
}

void SUB_CalcMove_controller_think (void)
{
	entity oldself;
	float traveltime;
	float phasepos;
	float nexttick;
	vector delta;
	vector delta2;
	vector veloc;
	vector angloc;
	vector nextpos;
	delta = self.destvec;
	delta2 = self.destvec2;
	if(time < self.animstate_endtime) {
		nexttick = time + sys_frametime;

		if (self.oldstyleplatmovetype) {
			//Old Style:
			traveltime = self.animstate_endtime - self.animstate_starttime;
			phasepos = (nexttick - self.animstate_starttime) / traveltime; // range: [0, 1]
			if(self.oldstyleplatmovetype != 1)
			{
				phasepos = 3.14159265 + (phasepos * 3.14159265); // range: [pi, 2pi]
				phasepos = cos(phasepos); // cos [pi, 2pi] is in [-1, 1]
				phasepos = phasepos + 1; // correct range to [0, 2]
				phasepos = phasepos / 2; // correct range to [0, 1]
			}
			nextpos = self.origin + (delta * phasepos) + (delta2 * phasepos * phasepos);
			// derivative: delta + 2 * delta2 * phasepos (e.g. for angle positioning)
		
		} else {
			//Nu Style
			traveltime = self.animstate_endtime - self.animstate_starttime;
			phasepos = (nexttick - self.animstate_starttime) / traveltime; // range: [0, 1]
			phasepos = cubic_speedfunc(self.platmovetype_start, self.platmovetype_end, phasepos);
			nextpos = self.origin + (delta * phasepos) + (delta2 * phasepos * phasepos);
			// derivative: delta + 2 * delta2 * phasepos (e.g. for angle positioning)
		}
		
		if(self.owner.platmovetype_turn)
		{
			vector destangle;
			destangle = delta + 2 * delta2 * phasepos;
			destangle = vectoangles(destangle);
			destangle_x = -destangle_x; // flip up / down orientation

			// take the shortest distance for the angles
			vector v = self.owner.angles;
			v_x -= 360 * floor((v_x - destangle_x) / 360 + 0.5);
			v_y -= 360 * floor((v_y - destangle_y) / 360 + 0.5);
			v_z -= 360 * floor((v_z - destangle_z) / 360 + 0.5);
			self.owner.angles = v;
			angloc = destangle - self.owner.angles;
			angloc = angloc * (1 / frametime); // so it arrives for the next frame
			self.owner.avelocity = angloc;
		}
		
		if(nexttick < self.animstate_endtime) {
			veloc = nextpos - self.owner.origin;
			veloc = veloc * (1 / sys_frametime); // so it arrives for the next frame
		} else {
			veloc = self.finaldest - self.owner.origin;
			veloc = veloc * (1 / sys_frametime); // so it arrives for the next frame
		}
		self.owner.velocity = veloc;
		self.nextthink = nexttick;
	} else {
		// derivative: delta + 2 * delta2 (e.g. for angle positioning)
		oldself = self;
		self.owner.think = self.think1;
		self = self.owner;
		remove(oldself);
		self.think();
	}
}

void SUB_CalcMove_controller_setbezier (entity controller, vector org, vector control, vector dest)
{
	// 0 * (1-t) * (1-t) + 2 * control * t * (1-t) + dest * t * t
	// 2 * control * t - 2 * control * t * t + dest * t * t
	// 2 * control * t + (dest - 2 * control) * t * t

	controller.origin = org; // starting point
	control -= org;
	dest -= org;

	controller.destvec = 2 * control; // control point
	controller.destvec2 = dest - 2 * control; // quadratic part required to reach end point
}

void SUB_CalcMove_controller_setlinear (entity controller, vector org, vector dest)
{
	// 0 * (1-t) * (1-t) + 2 * control * t * (1-t) + dest * t * t
	// 2 * control * t - 2 * control * t * t + dest * t * t
	// 2 * control * t + (dest - 2 * control) * t * t

	controller.origin = org; // starting point
	dest -= org;

	controller.destvec = dest; // end point
	controller.destvec2 = '0 0 0';
}

#define TSPEED_DEFAULTCODE -2
#define TSPEED_TIME -1
#define TSPEED_LINEAR 0
#define TSPEED_START 1
#define TSPEED_END 2

void SUB_CalcMove_Bezier2 (vector tcontrol, vector tdest, float tspeedtype, float tspeed, void() func)
{
	float	traveltime;
	entity controller;

	if (!tspeed)
		objerror ("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tspeedtype == TSPEED_LINEAR)
		traveltime = vlen(tdest - self.origin)        / tspeed;
	else if (tspeedtype == TSPEED_TIME)
		traveltime = tspeed;
	else if(tspeed > 0 || tspeedtype == TSPEED_START) // positive: start speed
		traveltime = 2 * vlen(tcontrol - self.origin) /  tspeed;
	else // negative: end speed
		traveltime = 2 * vlen(tcontrol - tdest)       / -tspeed;

	if (traveltime < 0.1) // useless anim
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	controller = spawn();
	controller.classname = "SUB_CalcMove_controller";
	controller.owner = self;
	controller.oldstyleplatmovetype = self.oldstyleplatmovetype; //For compat with maps using the old way of func_plat's platmovestyle
	controller.platmovetype = self.platmovetype;
	controller.platmovetype_start = self.platmovetype_start;
	controller.platmovetype_end = self.platmovetype_end;
	SUB_CalcMove_controller_setbezier(controller, self.origin, tcontrol, tdest);
	controller.finaldest = (tdest + '0 0 0.125'); // where do we want to end? Offset to overshoot a bit.
	controller.animstate_starttime = time;
	controller.animstate_endtime = time + traveltime;
	controller.think = SUB_CalcMove_controller_think;
	controller.think1 = self.think;

	// the thinking is now done by the controller
	self.think = SUB_NullThink; // for PushMove
	self.nextthink = self.ltime + traveltime;
	
	// invoke controller
	self = controller;
	self.think();
	self = self.owner;
}

void SUB_CalcMove_Bezier (vector tcontrol, vector tdest, float tspeed, void() func)
{
	SUB_CalcMove_Bezier2(tcontrol, tdest, TSPEED_DEFAULTCODE, tspeed, func);
}

void SUB_CalcMove (vector tdest, float tspeed, void() func)
{
	vector	delta;
	float	traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}

	delta = tdest - self.origin;
	traveltime = vlen (delta) / tspeed;

	// Very short animations don't really show off the effect
	// of controlled animation, so let's just use linear movement.
	// Alternatively entities can choose to specify non-controlled movement.
        // The only currently implemented alternative movement is linear (value 1)
	if (traveltime < 0.15 || (self.platmovetype_start == 1 && self.platmovetype_end == 1))
	{
		self.velocity = delta * (1/traveltime);	// QuakeC doesn't allow vector/float division
		self.nextthink = self.ltime + traveltime;
		return;
	}

	// now just run like a bezier curve...
	SUB_CalcMove_Bezier((self.origin + tdest) * 0.5, tdest, tspeed, func);
}

void SUB_CalcMoveEnt (entity ent, vector tdest, float tspeed, void() func)
{
	entity	oldself;

	oldself = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);

	self = oldself;
}

/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating

The calling function should make sure self.think is valid
===============
*/
void SUB_CalcAngleMoveDone (void)
{
	// After rotating, set angle to exact final angle
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1 && self.think1 != SUB_CalcAngleMoveDone)
		self.think1 ();
}

void SUB_CalcAvelocity_platmovetype_think();
void SUB_CalcAvelocity_platmovetype(float traveltime, float myperiodtype)
{
	if (self.platmovetype_start && self.platmovetype_end && !self.oldstyleplatmovetype) {
		entity controller;
		
		controller = spawn();
		controller.classname = "SUB_CalcMove_controller";
		controller.owner = self;
		controller.oldstyleplatmovetype = self.oldstyleplatmovetype; //For compat with maps using the old way of func_plat's platmovestyle
		controller.platmovetype = self.platmovetype;
		controller.platmovetype_start = self.platmovetype_start;
		controller.platmovetype_end = self.platmovetype_end;
		controller.origin = self.origin;
		controller.avelocity = self.avelocity;
		controller.periodtype = myperiodtype;

		controller.animstate_starttime = time;
		controller.animstate_endtime = time + traveltime;
		controller.think = SUB_CalcAvelocity_platmovetype_think;

		// invoke controller
		self = controller;
		self.think();
		self = self.owner;
	}
}

void SUB_CalcAvelocity_platmovetype_think()
{
	entity oldself;
	vector	delta;
	vector	delta2;
	float traveltime;
	float phasepos;
	float nexttick;
	vector veloc;
	vector nextpos;
	
	if ((self.owner == world) || (self.owner == self)) {
		//print("I have no owner, I shall remove self\n");
		remove(self);
		return;
	}
	
	
	if(time < self.animstate_endtime) {
		//Do Nothing, still within window;
	} else {
		//Must reset what traveltime is;
		traveltime = self.animstate_endtime - self.animstate_starttime;
		self.animstate_starttime = time;
		self.animstate_endtime = time + traveltime;
		traveltime = self.animstate_endtime - self.animstate_starttime;
		if (self.periodtype != 1) {
			if (self.ammount3) {
				//print("Tock\n");
				self.ammount3 = 0;
			} else {
				//print("Tick\n");
				self.ammount3 = 1;
			}
		}
	}
	
	nexttick = time + sys_frametime;
	
	if (self.owner.active == ACTIVE_NOT) {
		//print("AVnothink\n");
		
		//Just in case
		if (self.owner.avelocity) {
			self.owner.avelocity = '0 0 0';
		}
	} else {
		//print("AVTHINK\n");
		
		//Nu Style
		traveltime = self.animstate_endtime - self.animstate_starttime;
		
		phasepos = (nexttick - self.animstate_starttime) / traveltime; // range: [0, 1]
		if (self.ammount3) {
			phasepos = 1 + (phasepos * -1);
		}
		phasepos = cubic_speedfunc(self.platmovetype_start, self.platmovetype_end, phasepos);
		veloc = self.avelocity * phasepos;
		
		self.owner.avelocity = veloc;
		
		//print (vtos(self.avelocity),"-controllravel\n");
		//print (vtos(self.owner.avelocity),"-avel\n");
		//print (vtos(self.owner.angles),"-angles\n");
		//print (ftos(phasepos),"-phasepos\n");
	}
	self.nextthink = nexttick;
}


//////////////////////////////////////////////////
//////////////////////////////////////////////////

void SUB_CalcAngleMove2_platmovetype_think()
{
	entity oldself;
	vector	delta;
	vector	delta2;
	float traveltime;
	float phasepos;
	float nexttick;
	vector veloc;
	vector nextpos;
	delta = self.finalangle - self.angles;
	
	if(time < self.animstate_endtime) {
		nexttick = time + sys_frametime;
		
		//Nu Style
		traveltime = self.animstate_endtime - self.animstate_starttime;
		phasepos = (nexttick - self.animstate_starttime) / traveltime; // range: [0, 1]
		phasepos = cubic_speedfunc(self.platmovetype_start, self.platmovetype_end, phasepos);
		nextpos = self.angles + (delta * phasepos) + (delta2 * phasepos * phasepos);
		// derivative: delta + 2 * delta2 * phasepos (e.g. for angle positioning)
		
		
		if(nexttick < self.animstate_endtime) {
			veloc = nextpos - self.owner.angles;
			veloc = veloc * (1 / sys_frametime); // so it arrives for the next frame
		} else {
			veloc = self.finalangle - self.owner.angles;
			veloc = veloc * (1 / sys_frametime); // so it arrives for the next frame
		}
		self.owner.avelocity = veloc;
		self.nextthink = nexttick;
		
		//print("ANGTHINK\n");
		//print (vtos(self.owner.avelocity),"-avel\n");
		//print (vtos(self.owner.angles),"-angles\n");
	} else {
		//print("ANGnothink\n");
		//print (vtos(self.owner.avelocity),"-avel\n");
		//print (vtos(self.owner.angles),"-angles\n");

		oldself = self;
		self.owner.think = SUB_CalcAngleMoveDone;
		self = self.owner;
		remove(oldself);
		self.think();
	}
}

// FIXME: I fixed this function only for rotation around the main axes
void SUB_CalcAngleMove2 (vector destangle, float tspeedtype, float tspeed, void() func)
{
	vector	delta;
	float	traveltime;

	if (!tspeed)
		objerror ("No speed is defined!");

	// take the shortest distance for the angles
	self.angles_x -= 360 * floor((self.angles_x - destangle_x) / 360 + 0.5);
	self.angles_y -= 360 * floor((self.angles_y - destangle_y) / 360 + 0.5);
	self.angles_z -= 360 * floor((self.angles_z - destangle_z) / 360 + 0.5);
	delta = destangle - self.angles;
	if (tspeedtype == TSPEED_TIME) {
		traveltime = tspeed;
	} else {
		traveltime = vlen (delta) / tspeed;
	}

	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;

	if (traveltime < 0.1)
	{
		self.avelocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
	if (self.platmovetype_start && self.platmovetype_end && !self.oldstyleplatmovetype) {
		entity controller;
		
		controller = spawn();
		controller.classname = "SUB_CalcMove_controller";
		controller.owner = self;
		controller.oldstyleplatmovetype = self.oldstyleplatmovetype; //For compat with maps using the old way of func_plat's platmovestyle
		controller.platmovetype = self.platmovetype;
		controller.platmovetype_start = self.platmovetype_start;
		controller.platmovetype_end = self.platmovetype_end;
		controller.origin = self.origin;
		controller.angles = self.angles;

		controller.finalangle = self.finalangle; // where do we want to end? Offset to overshoot a bit.
		controller.animstate_starttime = time;
		controller.animstate_endtime = time + traveltime;
		controller.think = SUB_CalcAngleMove2_platmovetype_think;
		controller.think1 = self.think1;

		// the thinking is now done by the controller
		self.think = SUB_NullThink; // for PushMove
		self.nextthink = self.ltime + traveltime;
	
		// invoke controller
		self = controller;
		self.think();
		self = self.owner;
		return;
	}

	self.avelocity = delta * (1 / traveltime);
	self.nextthink = self.ltime + traveltime;
}

void SUB_CalcAngleMove (vector destangle, float tspeed, void() func)
{
	SUB_CalcAngleMove2 (destangle, TSPEED_DEFAULTCODE, tspeed, func);
}

void SUB_CalcAngleMoveEnt (entity ent, vector destangle, float tspeed, void() func)
{
	entity	oldself;

	oldself = self;
	self = ent;

	SUB_CalcAngleMove (destangle, tspeed, func);

	self = oldself;
}

/*
==================
main

unused but required by the engine
==================
*/
void main (void)
{

}

// Misc

/*
==================
traceline_antilag

A version of traceline that must be used by SOLID_SLIDEBOX things that want to hit SOLID_CORPSE things with a trace attack
Additionally it moves players back into the past before the trace and restores them afterward.
==================
*/
void tracebox_antilag_force_wz (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag, float wz)
{
	entity player;
	float oldsolid;

	// check whether antilagged traces are enabled
	if (lag < 0.001)
		lag = 0;
	if (clienttype(forent) != CLIENTTYPE_REAL)
		lag = 0; // only antilag for clients

	// change shooter to SOLID_BBOX so the shot can hit corpses
	oldsolid = source.dphitcontentsmask;
	if(source)
		source.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY | DPCONTENTS_CORPSE;

	if (lag)
	{
		// take players back into the past
		FOR_EACH_PLAYER(player)
			if(player != forent)
				antilag_takeback(player, time - lag);
	}

	// do the trace
	if(wz)
		WarpZone_TraceBox (v1, mi, ma, v2, nomonst, forent);
	else
		tracebox (v1, mi, ma, v2, nomonst, forent);

	// restore players to current positions
	if (lag)
	{
		FOR_EACH_PLAYER(player)
			if(player != forent)
				antilag_restore(player);
	}

	// restore shooter solid type
	if(source)
		source.dphitcontentsmask = oldsolid;
}
void traceline_antilag_force (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	tracebox_antilag_force_wz(source, v1, '0 0 0', '0 0 0', v2, nomonst, forent, lag, FALSE);
}
void traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	if (autocvar_g_antilag != 2 || source.cvar_cl_noantilag)
		lag = 0;
	traceline_antilag_force(source, v1, v2, nomonst, forent, lag);
}
void tracebox_antilag (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag)
{
	if (autocvar_g_antilag != 2 || source.cvar_cl_noantilag)
		lag = 0;
	tracebox_antilag_force_wz(source, v1, mi, ma, v2, nomonst, forent, lag, FALSE);
}
void WarpZone_traceline_antilag_force (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	tracebox_antilag_force_wz(source, v1, '0 0 0', '0 0 0', v2, nomonst, forent, lag, TRUE);
}
void WarpZone_traceline_antilag (entity source, vector v1, vector v2, float nomonst, entity forent, float lag)
{
	if (autocvar_g_antilag != 2 || source.cvar_cl_noantilag)
		lag = 0;
	WarpZone_traceline_antilag_force(source, v1, v2, nomonst, forent, lag);
}
void WarpZone_tracebox_antilag (entity source, vector v1, vector mi, vector ma, vector v2, float nomonst, entity forent, float lag)
{
	if (autocvar_g_antilag != 2 || source.cvar_cl_noantilag)
		lag = 0;
	tracebox_antilag_force_wz(source, v1, mi, ma, v2, nomonst, forent, lag, TRUE);
}

float tracebox_inverted (vector v1, vector mi, vector ma, vector v2, float nomonsters, entity forent, float stopatentity) // returns the number of traces done, for benchmarking
{
	vector pos, dir, t;
	float nudge;
	entity stopentity;

	//nudge = 2 * cvar("collision_impactnudge"); // why not?
	nudge = 0.5;

	dir = normalize(v2 - v1);

	pos = v1 + dir * nudge;

	float c;
	c = 0;

	for(;;)
	{
		if((pos - v1) * dir >= (v2 - v1) * dir)
		{
			// went too far
			trace_fraction = 1;
			trace_endpos = v2;
			return c;
		}

		tracebox(pos, mi, ma, v2, nomonsters, forent);
		++c;

		if(c == 50)
		{
			dprint("HOLY SHIT! When tracing from ", vtos(v1), " to ", vtos(v2), "\n");
			dprint("  Nudging gets us nowhere at ", vtos(pos), "\n");
			dprint("  trace_endpos is ", vtos(trace_endpos), "\n");
			dprint("  trace distance is ", ftos(vlen(pos - trace_endpos)), "\n");
		}

		stopentity = trace_ent;

		if(trace_startsolid)
		{
			// we started inside solid.
			// then trace from endpos to pos
			t = trace_endpos;
			tracebox(t, mi, ma, pos, nomonsters, forent);
			++c;
			if(trace_startsolid)
			{
				// t is still inside solid? bad
				// force advance, then, and retry
				pos = t + dir * nudge;

				// but if we hit an entity, stop RIGHT before it
				if(stopatentity && stopentity)
				{
					trace_ent = stopentity;
					trace_endpos = t;
					trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
					return c;
				}
			}
			else
			{
				// we actually LEFT solid!
				trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
				return c;
			}
		}
		else
		{
			// pos is outside solid?!? but why?!? never mind, just return it.
			trace_endpos = pos;
			trace_fraction = ((trace_endpos - v1) * dir) / ((v2 - v1) * dir);
			return c;
		}
	}
}

void traceline_inverted (vector v1, vector v2, float nomonsters, entity forent, float stopatentity)
{
	tracebox_inverted(v1, '0 0 0', '0 0 0', v2, nomonsters, forent, stopatentity);
}

/*
==================
findbetterlocation

Returns a point at least 12 units away from walls
(useful for explosion animations, although the blast is performed where it really happened)
Ripped from DPMod
==================
*/
vector findbetterlocation (vector org, float mindist)
{
	vector	loc;
	vector vec;
	float c, h;

	vec = mindist * '1 0 0';
	c = 0;
	while (c < 6)
	{
		traceline (org, org + vec, TRUE, world);
		vec = vec * -1;
		if (trace_fraction < 1)
		{
			loc = trace_endpos;
			traceline (loc, loc + vec, TRUE, world);
			if (trace_fraction >= 1)
				org = loc + vec;
		}
		if (c & 1)
		{
			h = vec_y;
			vec_y = vec_x;
			vec_x = vec_z;
			vec_z = h;
		}
		c = c + 1;
	}

	return org;
}

/*
==================
crandom

Returns a random number between -1.0 and 1.0
==================
*/
float crandom (void)
{
	return 2 * (random () - 0.5);
}

/*
==================
Angc used for animations
==================
*/


float angc (float a1, float a2)
{
	float	a;

	while (a1 > 180)
		a1 = a1 - 360;
	while (a1 < -179)
		a1 = a1 + 360;

	while (a2 > 180)
		a2 = a2 - 360;
	while (a2 < -179)
		a2 = a2 + 360;

	a = a1 - a2;
	while (a > 180)
		a = a - 360;
	while (a < -179)
		a = a + 360;

	return a;
}

.string lodtarget1;
.string lodtarget2;
.string lodtarget3;
.string lodtarget4;
.string lodtarget5;
.string lodtarget6;
.string lodmodel1;
.string lodmodel2;
.string lodmodel3;
.string lodmodel4;
.string lodmodel5;
.string lodmodel6;
.float lodmodelindex0;
.float lodmodelindex1;
.float lodmodelindex2;
.float lodmodelindex3;
.float lodmodelindex4;
.float lodmodelindex5;
.float lodmodelindex6;
.float loddistance1;
.float loddistance2;
.float loddistance3;
.float loddistance4;
.float loddistance5;
.float loddistance6;
.float lodowner; //If set, lod origin will be owners origin

.string lodtarget0substitute;
.float lodmodel0substitute_use;
.string lodmodel0substitute;
.float lodmodelindex0substitute;
.float loddistance0substitute;

float LOD_customize()
{
	float d;

	if(autocvar_loddebug)
	{
		d = autocvar_loddebug;
		if(d == 1)
			self.modelindex = self.lodmodelindex0;
		else if(d == 2 || !self.lodmodelindex2)
			self.modelindex = self.lodmodelindex1;
		else if(d == 3)
			self.modelindex = self.lodmodelindex2;
		else if(d == 4)
			self.modelindex = self.lodmodelindex3;
		else if(d == 5)
			self.modelindex = self.lodmodelindex4;
		else if(d == 6)
			self.modelindex = self.lodmodelindex5;
		else // if(d == 7)
			self.modelindex = self.lodmodelindex6;
		return TRUE;
	}

	// TODO csqc network this so it only gets sent once
	if (self.lodowner == 1)
		d = vlen(NearestPointOnBox(self.owner, other.origin) - other.origin);	
	else
		d = vlen(NearestPointOnBox(self, other.origin) - other.origin);
	
	if(d < self.loddistance1) {
		float d2;
		if (self.lodmodel0substitute_use) {
			if (self.loddistance0substitute) {
				if (self.lodowner == 1)
					d2 = vlen(self.owner.origin - other.origin);	
				else
					d2 = vlen(self.origin - other.origin);
			} else {
				d2 = 0;
			}
		}
		
		if (self.lodmodel0substitute_use && d2 >= self.loddistance0substitute)
			self.modelindex = self.lodmodelindex0substitute;
		else
			self.modelindex = self.lodmodelindex0;
	} else if(!self.lodmodelindex2 || d < self.loddistance2)
		self.modelindex = self.lodmodelindex1;
	else if(!self.lodmodelindex3 || d < self.loddistance3)
		self.modelindex = self.lodmodelindex2;
	else if(!self.lodmodelindex4 || d < self.loddistance4)
		self.modelindex = self.lodmodelindex3;
	else if(!self.lodmodelindex5 || d < self.loddistance5)
		self.modelindex = self.lodmodelindex4;
	else if(!self.lodmodelindex6 || d < self.loddistance6)
		self.modelindex = self.lodmodelindex5;
	else
		self.modelindex = self.lodmodelindex6;

	return TRUE;
}

void LOD_uncustomize()
{
	self.modelindex = self.lodmodelindex0;
}

void LODmodel_attach()
{
	entity e;

	if(!self.loddistance1)
		self.loddistance1 = 1000;
	if(!self.loddistance2)
		self.loddistance2 = 2000;
	if(!self.loddistance3)
		self.loddistance3 = 3000;
	if(!self.loddistance4)
		self.loddistance4 = 4000;
	if(!self.loddistance5)
		self.loddistance5 = 5000;
	if(!self.loddistance6)
		self.loddistance6 = 6000;
	self.lodmodelindex0 = self.modelindex;

	//////////////
	//For if you want to set the model to a simple collision hull model but want to show
	//the "real" model to the player (Collision hull set to the .model for the server)
	if (self.lodmodel0substitute_use) {
	   if(self.lodtarget0substitute != "")
	   {
		e = find(world, targetname, self.lodtarget0substitute);
		if(e)
		{
			self.lodmodel0substitute = e.model;
			remove(e);
		}
	   }
	}
	//////////////
	if(self.lodtarget1 != "")
	{
		e = find(world, targetname, self.lodtarget1);
		if(e)
		{
			self.lodmodel1 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget2 != "")
	{
		e = find(world, targetname, self.lodtarget2);
		if(e)
		{
			self.lodmodel2 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget3 != "")
	{
		e = find(world, targetname, self.lodtarget3);
		if(e)
		{
			self.lodmodel3 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget4 != "")
	{
		e = find(world, targetname, self.lodtarget4);
		if(e)
		{
			self.lodmodel4 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget5 != "")
	{
		e = find(world, targetname, self.lodtarget5);
		if(e)
		{
			self.lodmodel5 = e.model;
			remove(e);
		}
	}
	if(self.lodtarget6 != "")
	{
		e = find(world, targetname, self.lodtarget6);
		if(e)
		{
			self.lodmodel6 = e.model;
			remove(e);
		}
	}
	

	if(autocvar_loddebug < 0)
	{
		self.lodmodel1 = self.lodmodel2 = self.lodmodel3 = self.lodmodel4 = ""; // don't even initialize
		self.lodmodel5 = self.lodmodel6 = "";
		self.lodmodel0substitute = "";
	}

	if(self.lodmodel1 != "")
	{
		vector mi, ma;
		mi = self.mins;
		ma = self.maxs;
		
		//////////////
		//For if you want to set the model to a simple collision hull model but want to show
		//the "real" model to the player (Collision hull set to the .model for the server)
		if (self.lodmodel0substitute_use) {
			if (self.lodmodel0substitute != "")
			{
				precache_model(self.lodmodel0substitute);
				setmodel(self, self.lodmodel0substitute);
				self.lodmodelindex0substitute = self.modelindex;
			}
		}
		//////////////

		precache_model(self.lodmodel1);
		setmodel(self, self.lodmodel1);
		self.lodmodelindex1 = self.modelindex;

		if(self.lodmodel2 != "")
		{
			precache_model(self.lodmodel2);
			setmodel(self, self.lodmodel2);
			self.lodmodelindex2 = self.modelindex;
			
			if(self.lodmodel3 != "")
			{
				precache_model(self.lodmodel3);
				setmodel(self, self.lodmodel3);
				self.lodmodelindex3 = self.modelindex;
				
				if(self.lodmodel4 != "")
				{
					precache_model(self.lodmodel4);
					setmodel(self, self.lodmodel4);
					self.lodmodelindex4 = self.modelindex;
					
					if(self.lodmodel5 != "")
					{
						precache_model(self.lodmodel5);
						setmodel(self, self.lodmodel5);
						self.lodmodelindex5 = self.modelindex;
						
						if(self.lodmodel6 != "")
						{
							precache_model(self.lodmodel6);
							setmodel(self, self.lodmodel6);
							self.lodmodelindex6 = self.modelindex;
						}
					}
				}
			}
		}

		self.modelindex = self.lodmodelindex0;
		setsize(self, mi, ma);
	}

	if(self.lodmodelindex1)
		if not(self.SendEntity)
			SetCustomizer(self, LOD_customize, LOD_uncustomize);
}

void ApplyMinMaxScaleAngles(entity e)
{
	if(e.angles_x != 0 || e.angles_z != 0 || self.avelocity_x != 0 || self.avelocity_z != 0) // "weird" rotation
	{
		e.maxs = '1 1 1' * vlen(
			'1 0 0' * max(-e.mins_x, e.maxs_x) +
			'0 1 0' * max(-e.mins_y, e.maxs_y) +
			'0 0 1' * max(-e.mins_z, e.maxs_z)
		);
		e.mins = -e.maxs;
	}
	else if(e.angles_y != 0 || self.avelocity_y != 0) // yaw only is a bit better
	{
		e.maxs_x = vlen(
			'1 0 0' * max(-e.mins_x, e.maxs_x) +
			'0 1 0' * max(-e.mins_y, e.maxs_y)
		);
		e.maxs_y = e.maxs_x;
		e.mins_x = -e.maxs_x;
		e.mins_y = -e.maxs_x;
	}
	if(e.scale)
		setsize(e, e.mins * e.scale, e.maxs * e.scale);
	else
		setsize(e, e.mins, e.maxs);
}

void SetBrushEntityModel()
{
 	if(self.model != "")
 	{
 		precache_model(self.model);
		if(self.mins != '0 0 0' || self.maxs != '0 0 0')
		{
			vector mi = self.mins;
			vector ma = self.maxs;
			setmodel(self, self.model); // no precision needed
			setsize(self, mi, ma);
		}
		else
			setmodel(self, self.model); // no precision needed
		InitializeEntity(self, LODmodel_attach, INITPRIO_FINDTARGET);
 	}
	setorigin(self, self.origin);
	ApplyMinMaxScaleAngles(self);
}

void SetBrushEntityModelNoLOD()
{
 	if(self.model != "")
 	{
 		precache_model(self.model);
		if(self.mins != '0 0 0' || self.maxs != '0 0 0')
		{
			vector mi = self.mins;
			vector ma = self.maxs;
			setmodel(self, self.model); // no precision needed
			setsize(self, mi, ma);
		}
		else
			setmodel(self, self.model); // no precision needed
 	}
	setorigin(self, self.origin);
	ApplyMinMaxScaleAngles(self);
}

/*
================
InitTrigger
================
*/

void SetMovedir()
{
	if (self.movedir != '0 0 0')
		self.movedir = normalize(self.movedir);
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}

	self.angles = '0 0 0';
}

void InitTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	SetMovedir ();
	self.solid = SOLID_TRIGGER;
	SetBrushEntityModel();
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
}

void InitSolidBSPTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	SetMovedir ();
	self.solid = SOLID_BSP;
	SetBrushEntityModel();
	self.movetype = MOVETYPE_NONE; // why was this PUSH? -div0
//	self.modelindex = 0;
	self.model = "";
}

float InitMovingBrushTrigger()
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	self.solid = SOLID_BSP;
	SetBrushEntityModel();
	self.movetype = MOVETYPE_PUSH;
	if(self.modelindex == 0)
	{
		objerror("InitMovingBrushTrigger: no brushes found!");
		return 0;
	}
	return 1;
}
