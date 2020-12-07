.float race_penalty;
.float restart_jump;

.float ladder_time;
.entity ladder_entity;
.float gravity;
.float swamp_slowdown;
.float lastflags;
.float lastground;
.float wasFlying;
.float spectatorspeed;

.float multijump_count;
.float multijump_ready;
.float prevjumpbutton;

/*
=============
PlayerJump

When you press the jump key
=============
*/
void PlayerJump (void)
{
	if(self.freezetag_frozen)
		return; // no jumping in freezetag when frozen
	
	if(self.frozen)
		return;
		
	
	if(self.stoned)
		return;
		
	if(self.prisonerlevel >= 3)
		return;
		
	float mjumpheight;
	float doublejump;

	doublejump = FALSE;
	if (autocvar_sv_doublejump)
	{
		tracebox(self.origin + '0 0 0.01', self.mins, self.maxs, self.origin - '0 0 0.01', MOVE_NORMAL, self);
		if (trace_fraction < 1 && trace_plane_normal_z > 0.7)
		{
			doublejump = TRUE;

			// we MUST clip velocity here!
			float f;
			f = self.velocity * trace_plane_normal;
			if(f < 0)
				self.velocity -= f * trace_plane_normal;
		}
	}

	mjumpheight = autocvar_sv_jumpvelocity;
	if (self.waterlevel >= WATERLEVEL_SWIMMING)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 200;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

		return;
	}

	if (autocvar_g_multijump)
	{
		if (self.prevjumpbutton == FALSE && !(self.flags & FL_ONGROUND)) // jump button pressed this frame and we are in midair
			self.multijump_ready = TRUE;  // this is necessary to check that we released the jump button and pressed it again
		else
			self.multijump_ready = FALSE;
	}

	if(!doublejump && self.multijump_ready && self.multijump_count < autocvar_g_multijump && self.velocity_z > autocvar_g_multijump_speed)
	{
		// doublejump = FALSE; // checked above in the if
		if (autocvar_g_multijump)
		{
			if (autocvar_g_multijump_add == 0) // in this case we make the z velocity == jumpvelocity
			{
				if (self.velocity_z < mjumpheight)
				{
					doublejump = TRUE;
					self.velocity_z = 0;
				}
			}
			else
				doublejump = TRUE;

			if(doublejump)
			{
				if(self.movement_x != 0 || self.movement_y != 0) // don't remove all speed if player isnt pressing any movement keys
				{
					float curspeed;
					vector wishvel, wishdir;

					curspeed = max(
						vlen(vec2(self.velocity)), // current xy speed
						vlen(vec2(antilag_takebackavgvelocity(self, max(self.lastteleporttime + sys_frametime, time - 0.25), time))) // average xy topspeed over the last 0.25 secs
					);
					makevectors(self.v_angle_y * '0 1 0');
					wishvel = v_forward * self.movement_x + v_right * self.movement_y;
					wishdir = normalize(wishvel);

					self.velocity_x = wishdir_x * curspeed; // allow "dodging" at a multijump
					self.velocity_y = wishdir_y * curspeed;
					// keep velocity_z unchanged!
				}
				if (autocvar_g_multijump > 0)
					self.multijump_count += 1;
			}
		}
		self.multijump_ready = FALSE; // require releasing and pressing the jump button again for the next jump
	}

	if (!doublejump)
		if (!(self.flags & FL_ONGROUND))
			return;

	if(self.cvar_cl_movement_track_canjump)
		if (!(self.flags & FL_JUMPRELEASED))
			return;

	if(self.health <= g_bloodloss)
		return;

	if (self.permhobbled_l || self.temphobbled_l || self.permhobbled_r || self.temphobbled_r) {
		if ((self.permhobbled_l || self.temphobbled_l) && (self.permhobbled_r || self.temphobbled_r)) {
			return;
		} else if (self.parthobbledtime > time) {
			return;
		}
	}

	// sv_jumpspeedcap_min/sv_jumpspeedcap_max act as baseline
	// velocity bounds.  Final velocity is bound between (jumpheight *
	// min + jumpheight) and (jumpheight * max + jumpheight);

	if(autocvar_sv_jumpspeedcap_min != "")
	{
		float minjumpspeed;

		minjumpspeed = mjumpheight * stof(autocvar_sv_jumpspeedcap_min);

		if (self.velocity_z < minjumpspeed)
			mjumpheight += minjumpspeed - self.velocity_z;
	}

	if(autocvar_sv_jumpspeedcap_max != "")
	{
		// don't do jump speedcaps on ramps to preserve old xonotic ramjump style
		tracebox(self.origin + '0 0 0.01', self.mins, self.maxs, self.origin - '0 0 0.01', MOVE_NORMAL, self);

		if(!(trace_fraction < 1 && trace_plane_normal_z < 0.98 && autocvar_sv_jumpspeedcap_max_disable_on_ramps))
		{
			float maxjumpspeed;

			maxjumpspeed = mjumpheight * stof(autocvar_sv_jumpspeedcap_max);

			if (self.velocity_z > maxjumpspeed)
				mjumpheight -= self.velocity_z - maxjumpspeed;
		}
	}

	if(!(self.lastflags & FL_ONGROUND))
	{
		if(autocvar_speedmeter)
			dprint(strcat("landing velocity: ", vtos(self.velocity), " (abs: ", ftos(vlen(self.velocity)), ")\n"));
		if(self.lastground < time - 0.3)
		{
			self.velocity_x *= (1 - autocvar_sv_friction_on_land);
			self.velocity_y *= (1 - autocvar_sv_friction_on_land);
		}
		if(self.jumppadcount > 1)
			dprint(strcat(ftos(self.jumppadcount), "x jumppad combo\n"));
		self.jumppadcount = 0;
	}

	self.velocity_z = self.velocity_z + mjumpheight;
	self.oldvelocity_z = self.velocity_z;

	self.flags &~= FL_ONGROUND;
	self.flags &~= FL_JUMPRELEASED;

	if (self.crouch)
		setanim(self, self.anim_duckjump, FALSE, TRUE, TRUE);
	else if (self.animstate_startframe != self.anim_melee_x || (self.animstate_startframe == self.anim_melee_x && time - self.animstate_starttime >= 21/20)) // jump animation shouldn't override melee until we have animation blending (or until the anim finished, 21/20 = numframes/fps)
		setanim(self, self.anim_jump, FALSE, TRUE, TRUE);

	if(g_jump_grunt)
		PlayerSound(playersound_jump, CH_PLAYER, VOICETYPE_PLAYERSOUND);

	self.restart_jump = -1; // restart jump anim next time
	// value -1 is used to not use the teleport bit (workaround for tiny hitch when re-jumping)
}
void CheckWaterJump()
{
	vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags |= FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags &~= FL_JUMPRELEASED;
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
}
void CheckPlayerJump()
{
	if(self.flags & FL_ONGROUND)
	{
		if (autocvar_g_multijump > 0)
			self.multijump_count = 0;
		else
			self.multijump_count = -2; // the cvar value for infinite jumps is -1, so this needs to be smaller
	}

	if (self.BUTTON_JUMP)
		PlayerJump ();
	else
		self.flags |= FL_JUMPRELEASED;

	if (self.waterlevel == WATERLEVEL_SWIMMING)
		CheckWaterJump ();
	self.prevjumpbutton = self.BUTTON_JUMP;
}

float racecar_angle(float forward, float down)
{
	float ret, angle_mult;

	if(forward < 0)
	{
		forward = -forward;
		down = -down;
	}

	ret = vectoyaw('0 1 0' * down + '1 0 0' * forward);

	angle_mult = forward / (800 + forward);

	if(ret > 180)
		return ret * angle_mult + 360 * (1 - angle_mult);
	else
		return ret * angle_mult;
}

void RaceCarPhysics()
{
	// using this move type for "big rigs"
	// the engine does not push the entity!

	float accel, steer, f, myspeed, steerfactor;
	vector angles_save, rigvel;

	angles_save = self.angles;
	accel = bound(-1, self.movement_x / self.stat_sv_maxspeed, 1);
	steer = bound(-1, self.movement_y / self.stat_sv_maxspeed, 1);

	if(g_bugrigs_reverse_speeding)
	{
		if(accel < 0)
		{
			// back accel is DIGITAL
			// to prevent speedhack
			if(accel < -0.5)
				accel = -1;
			else
				accel = 0;
		}
	}

	self.angles_x = 0;
	self.angles_z = 0;
	makevectors(self.angles); // new forward direction!

	if(self.flags & FL_ONGROUND || g_bugrigs_air_steering)
	{
		float upspeed, accelfactor;

		myspeed = self.velocity * v_forward;
		upspeed = self.velocity * v_up;

		// responsiveness factor for steering and acceleration
		f = 1 / (1 + pow(max(-myspeed, myspeed) / g_bugrigs_speed_ref, g_bugrigs_speed_pow));
		//MAXIMA: f(v) := 1 / (1 + (v / g_bugrigs_speed_ref) ^ g_bugrigs_speed_pow);

		if(myspeed < 0 && g_bugrigs_reverse_spinning)
			steerfactor = -myspeed * g_bugrigs_steer;
		else
			steerfactor = -myspeed * f * g_bugrigs_steer;

		if(myspeed < 0 && g_bugrigs_reverse_speeding)
			accelfactor = g_bugrigs_accel;
		else
			accelfactor = f * g_bugrigs_accel;
		//MAXIMA: accel(v) := f(v) * g_bugrigs_accel;

		if(accel < 0)
		{
			if(myspeed > 0)
			{
				myspeed = max(0, myspeed - frametime * (g_bugrigs_friction_floor - g_bugrigs_friction_brake * accel));
			}
			else
			{
				if(!g_bugrigs_reverse_speeding)
					myspeed = min(0, myspeed + frametime * g_bugrigs_friction_floor);
			}
		}
		else
		{
			if(myspeed >= 0)
			{
				myspeed = max(0, myspeed - frametime * g_bugrigs_friction_floor);
			}
			else
			{
				if(g_bugrigs_reverse_stopping)
					myspeed = 0;
				else
					myspeed = min(0, myspeed + frametime * (g_bugrigs_friction_floor + g_bugrigs_friction_brake * accel));
			}
		}
		// terminal velocity = velocity at which 50 == accelfactor, that is, 1549 units/sec
		//MAXIMA: friction(v) := g_bugrigs_friction_floor;

		self.angles_y += steer * frametime * steerfactor; // apply steering
		makevectors(self.angles); // new forward direction!

		myspeed += accel * accelfactor * frametime;

		rigvel = myspeed * v_forward + '0 0 1' * upspeed;
	}
	else
	{
		myspeed = vlen(self.velocity);

		// responsiveness factor for steering and acceleration
		f = 1 / (1 + pow(max(0, myspeed / g_bugrigs_speed_ref), g_bugrigs_speed_pow));
		steerfactor = -myspeed * f;
		self.angles_y += steer * frametime * steerfactor; // apply steering

		rigvel = self.velocity;
		makevectors(self.angles); // new forward direction!
	}

	rigvel = rigvel * max(0, 1 - vlen(rigvel) * g_bugrigs_friction_air * frametime);
	//MAXIMA: airfriction(v) := v * v * g_bugrigs_friction_air;
	//MAXIMA: total_acceleration(v) := accel(v) - friction(v) - airfriction(v);
	//MAXIMA: solve(total_acceleration(v) = 0, v);

	if(g_bugrigs_planar_movement)
	{
		vector rigvel_xy, neworigin, up;
		float mt;

		rigvel_z -= frametime * autocvar_sv_gravity; // 4x gravity plays better
		rigvel_xy = vec2(rigvel);

		if(g_bugrigs_planar_movement_car_jumping && !g_touchexplode) // touchexplode is a better way to handle collisions
			mt = MOVE_NORMAL;
		else
			mt = MOVE_NOMONSTERS;

		tracebox(self.origin, self.mins, self.maxs, self.origin + '0 0 1024', mt, self);
		up = trace_endpos - self.origin;

		// BUG RIGS: align the move to the surface instead of doing collision testing
		// can we move?
		tracebox(trace_endpos, self.mins, self.maxs, trace_endpos + rigvel_xy * frametime, mt, self);

		// align to surface
		tracebox(trace_endpos, self.mins, self.maxs, trace_endpos - up + '0 0 1' * rigvel_z * frametime, mt, self);

		if(trace_fraction < 0.5)
		{
			trace_fraction = 1;
			neworigin = self.origin;
		}
		else
			neworigin = trace_endpos;

		if(trace_fraction < 1)
		{
			// now set angles_x so that the car points parallel to the surface
			self.angles = vectoangles(
					'1 0 0' * v_forward_x * trace_plane_normal_z
					+
					'0 1 0' * v_forward_y * trace_plane_normal_z
					+
					'0 0 1' * -(v_forward_x * trace_plane_normal_x + v_forward_y * trace_plane_normal_y)
					);
			self.flags |= FL_ONGROUND;
		}
		else
		{
			// now set angles_x so that the car points forward, but is tilted in velocity direction
			self.flags &~= FL_ONGROUND;
		}

		self.velocity = (neworigin - self.origin) * (1.0 / frametime);
		self.movetype = MOVETYPE_NOCLIP;
	}
	else
	{
		rigvel_z -= frametime * autocvar_sv_gravity; // 4x gravity plays better
		self.velocity = rigvel;
		self.movetype = MOVETYPE_FLY;
	}

	trace_fraction = 1;
	tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 4', MOVE_NORMAL, self);
	if(trace_fraction != 1)
	{
		self.angles = vectoangles2(
				'1 0 0' * v_forward_x * trace_plane_normal_z
				+
				'0 1 0' * v_forward_y * trace_plane_normal_z
				+
				'0 0 1' * -(v_forward_x * trace_plane_normal_x + v_forward_y * trace_plane_normal_y),
				trace_plane_normal
				);
	}
	else
	{
		vector vel_local;

		vel_local_x = v_forward * self.velocity;
		vel_local_y = v_right * self.velocity;
		vel_local_z = v_up * self.velocity;

		self.angles_x = racecar_angle(vel_local_x, vel_local_z);
		self.angles_z = racecar_angle(-vel_local_y, vel_local_z);
	}

	// smooth the angles
	vector vf1, vu1, smoothangles;
	makevectors(self.angles);
	f = bound(0, frametime * g_bugrigs_angle_smoothing, 1);
	if(f == 0)
		f = 1;
	vf1 = v_forward * f;
	vu1 = v_up * f;
	makevectors(angles_save);
	vf1 = vf1 + v_forward * (1 - f);
	vu1 = vu1 + v_up * (1 - f);
	smoothangles = vectoangles2(vf1, vu1);
	self.angles_x = -smoothangles_x;
	self.angles_z =  smoothangles_z;
}

float IsMoveInDirection(vector mv, float angle) // key mix factor
{
	if(mv_x == 0 && mv_y == 0)
		return 0; // avoid division by zero
	angle -= RAD2DEG * atan2(mv_y, mv_x);
	angle = remainder(angle, 360) / 45;
	if(angle >  1)
		return 0;
	if(angle < -1)
		return 0;
	return 1 - fabs(angle);
}

float GeomLerp(float a, float lerp, float b)
{
	if(a == 0)
	{
		if(lerp < 1)
			return 0;
		else
			return b;
	}
	if(b == 0)
	{
		if(lerp > 0)
			return 0;
		else
			return a;
	}
	return a * pow(fabs(b / a), lerp);
}

void CPM_PM_Aircontrol(vector wishdir, float wishspeed)
{
	float zspeed, xyspeed, dot, k;

#if 0
	// this doesn't play well with analog input
	if(self.movement_x == 0 || self.movement_y != 0)
		return; // can't control movement if not moving forward or backward
	k = 32;
#else
	k = 32 * (2 * IsMoveInDirection(self.movement, 0) - 1);
	if(k <= 0)
		return;
#endif

	k *= bound(0, wishspeed / autocvar_sv_maxairspeed, 1);

	zspeed = self.velocity_z;
	self.velocity_z = 0;
	xyspeed = vlen(self.velocity); self.velocity = normalize(self.velocity);

	dot = self.velocity * wishdir;

	if(dot > 0) // we can't change direction while slowing down
	{
		k *= pow(dot, autocvar_sv_aircontrol_power)*frametime;
		xyspeed = max(0, xyspeed - autocvar_sv_aircontrol_penalty * sqrt(max(0, 1 - dot*dot)) * k/32);
		k *= autocvar_sv_aircontrol;
		self.velocity = normalize(self.velocity * xyspeed + wishdir * k);
	}

	self.velocity = self.velocity * xyspeed;
	self.velocity_z = zspeed;
}

float AdjustAirAccelQW(float accelqw, float factor)
{
	return copysign(bound(0.000001, 1 - (1 - fabs(accelqw)) * factor, 1), accelqw);
}

// example config for alternate speed clamping:
//   sv_airaccel_qw 0.8
//   sv_airaccel_sideways_friction 0
//   prvm_globalset server speedclamp_mode 1
//     (or 2)
void PM_Accelerate(vector wishdir, float wishspeed, float wishspeed0, float accel, float accelqw, float stretchfactor, float sidefric, float speedlimit)
{
	float vel_straight;
	float vel_z;
	vector vel_perpend;
	float step;

	vector vel_xy;
	float vel_xy_current;
	float vel_xy_backward, vel_xy_forward;
	float speedclamp;

	if(stretchfactor > 0)
		speedclamp = stretchfactor;
	else if(accelqw < 0)
		speedclamp = 1; // full clamping, no stretch
	else
		speedclamp = -1; // no clamping

	if(accelqw < 0)
		accelqw = -accelqw;

	if(autocvar_sv_gameplayfix_q2airaccelerate)
		wishspeed0 = wishspeed;

	vel_straight = self.velocity * wishdir;
	vel_z = self.velocity_z;
	vel_xy = vec2(self.velocity);
	vel_perpend = vel_xy - vel_straight * wishdir;

	step = accel * frametime * wishspeed0;

	vel_xy_current  = vlen(vel_xy);
	if(speedlimit)
		accelqw = AdjustAirAccelQW(accelqw, (speedlimit - bound(wishspeed, vel_xy_current, speedlimit)) / max(1, speedlimit - wishspeed));
	vel_xy_forward  = vel_xy_current + bound(0, wishspeed - vel_xy_current, step) * accelqw + step * (1 - accelqw);
	vel_xy_backward = vel_xy_current - bound(0, wishspeed + vel_xy_current, step) * accelqw - step * (1 - accelqw);
	if(vel_xy_backward < 0)
		vel_xy_backward = 0; // not that it REALLY occurs that this would cause wrong behaviour afterwards

	vel_straight = vel_straight + bound(0, wishspeed - vel_straight, step) * accelqw + step * (1 - accelqw);

	if(sidefric < 0 && (vel_perpend*vel_perpend))
		// negative: only apply so much sideways friction to stay below the speed you could get by "braking"
	{
		float f, fminimum;
		f = max(0, 1 + frametime * wishspeed * sidefric);
		fminimum = (vel_xy_backward*vel_xy_backward - vel_straight*vel_straight) / (vel_perpend*vel_perpend);
		// this cannot be > 1
		if(fminimum <= 0)
			vel_perpend = vel_perpend * max(0, f);
		else
		{
			fminimum = sqrt(fminimum);
			vel_perpend = vel_perpend * max(fminimum, f);
		}
	}
	else
		vel_perpend = vel_perpend * max(0, 1 - frametime * wishspeed * sidefric);
	
	vel_xy = vel_straight * wishdir + vel_perpend;
	
	if(speedclamp >= 0)
	{
		float vel_xy_preclamp;
		vel_xy_preclamp = vlen(vel_xy);
		if(vel_xy_preclamp > 0) // prevent division by zero
		{
			vel_xy_current += (vel_xy_forward - vel_xy_current) * speedclamp;
			if(vel_xy_current < vel_xy_preclamp)
				vel_xy = vel_xy * (vel_xy_current / vel_xy_preclamp);
		}
	}

	self.velocity = vel_xy + vel_z * '0 0 1';
}

void PM_AirAccelerate(vector wishdir, float wishspeed)
{
	vector curvel, wishvel, acceldir, curdir;
	float addspeed, accelspeed, curspeed, f;
	float dot;

	if(wishspeed == 0)
		return;

	curvel = self.velocity;
	curvel_z = 0;
	curspeed = vlen(curvel);

	if(wishspeed > curspeed * 1.01)
	{
		wishspeed = min(wishspeed, curspeed + autocvar_sv_warsowbunny_airforwardaccel * self.stat_sv_maxspeed * frametime);
	}
	else
	{
		f = max(0, (autocvar_sv_warsowbunny_topspeed - curspeed) / (autocvar_sv_warsowbunny_topspeed - self.stat_sv_maxspeed));
		wishspeed = max(curspeed, self.stat_sv_maxspeed) + autocvar_sv_warsowbunny_accel * f * self.stat_sv_maxspeed * frametime;
	}
	wishvel = wishdir * wishspeed;
	acceldir = wishvel - curvel;
	addspeed = vlen(acceldir);
	acceldir = normalize(acceldir);

	accelspeed = min(addspeed, autocvar_sv_warsowbunny_turnaccel * self.stat_sv_maxspeed * frametime);

	if(autocvar_sv_warsowbunny_backtosideratio < 1)
	{
		curdir = normalize(curvel);
		dot = acceldir * curdir;
		if(dot < 0)
			acceldir = acceldir - (1 - autocvar_sv_warsowbunny_backtosideratio) * dot * curdir;
	}

	self.velocity += accelspeed * acceldir;
}

.vector movement_old;
.float buttons_old;
.vector v_angle_old;
.string lastclassname;

.float() PlayerPhysplug;

string specialcommand = "xwxwxsxsxaxdxaxdx1x ";
.float specialcommand_pos;
void SpecialCommand()
{
#ifdef TETRIS
	TetrisImpulse();
#else
	if(!CheatImpulse(99))
		print("A hollow voice says \"Plugh\".\n");
#endif
}

float speedaward_speed;
string speedaward_holder;
string speedaward_uid;
void race_send_speedaward(float msg)
{
	// send the best speed of the round
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_RACE);
	WriteByte(msg, RACE_NET_SPEED_AWARD);
	WriteInt24_t(msg, floor(speedaward_speed+0.5));
	WriteString(msg, speedaward_holder);
}

float speedaward_alltimebest;
string speedaward_alltimebest_holder;
string speedaward_alltimebest_uid;
void race_send_speedaward_alltimebest(float msg)
{
	// send the best speed
	WriteByte(msg, SVC_TEMPENTITY);
	WriteByte(msg, TE_CSQC_RACE);
	WriteByte(msg, RACE_NET_SPEED_AWARD_BEST);
	WriteInt24_t(msg, floor(speedaward_alltimebest+0.5));
	WriteString(msg, speedaward_alltimebest_holder);
}



float PlayerIsInOil(entity player)
{
			if ((g_spawnfoliagearound_oillevel_started)
			&& (g_spawnfoliagearound_oillevel && g_spawnfoliagearound_oillevel != 0)
			&& ((player.origin_z + player.mins_z) < g_spawnfoliagearound_oillevel_unchanging)) {
				return TRUE;
			}
			
			return FALSE;
}

float PlayerIsInMethane(entity player)
{	
			if ((g_spawnfoliagearound_methanelevel_started)
			&& (g_spawnfoliagearound_methanelevel && g_spawnfoliagearound_methanelevel != 0)
			&& ((player.origin_z + player.mins_z) < g_spawnfoliagearound_methanelevel_unchanging)) {
				return TRUE;
			}
			
			return FALSE;
}

float PlayerIsInChem(entity player)
{	
			if ((g_spawnfoliagearound_chemlevel_started)
			&& (g_spawnfoliagearound_chemlevel && g_spawnfoliagearound_chemlevel != 0)
			&& ((player.origin_z + player.mins_z) < g_spawnfoliagearound_chemlevel_unchanging)) {
				return TRUE;
			}
			
			return FALSE;
}

float PlayerIsInOilReactArea(entity myself)
{
	//For map trigger_oilreactarea brush entities:
	local vector entsorigin;
	local entity entm;
	if (oilreactareasexist) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		oilreactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(isoilreactarea, 1);
    		while (entm)
    		{
    		    oilreactareasexist = oilreactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	return TRUE;
		    }
    		    entm = entm.chain;
    		}	
	}
	return FALSE;
}

float PlayerIsInMethaneReactArea(entity myself)
{
	//For map trigger_methanereactarea brush entities:
	local vector entsorigin;
	local entity entm;
	if (methanereactareasexist) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		methanereactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(ismethanereactarea, 1);
    		while (entm)
    		{
    		    methanereactareasexist = methanereactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	return TRUE;
		    }
    		    entm = entm.chain;
    		}	
	}
	return FALSE;
}

float PlayerIsInChemReactArea(entity myself)
{
	//For map trigger_chemreactarea brush entities:
	local vector entsorigin;
	local entity entm;
	if (chemreactareasexist) {
		local vector myentsabsmins;
		local vector myentsabsmaxs;
		myentsabsmins = myself.origin;
		myentsabsmins_x = myentsabsmins_x - 1;
		myentsabsmins_y = myentsabsmins_y - 1;
		myentsabsmins_z = myentsabsmins_z - 1;
		myentsabsmaxs = myself.origin;
		myentsabsmaxs_x = myentsabsmaxs_x + 1;
		myentsabsmaxs_y = myentsabsmaxs_y + 1;
		myentsabsmaxs_z = myentsabsmaxs_z + 1;
		
		chemreactareasexist = 0;
		
		entsorigin = myself.origin;
		entm = findchainfloat(ischemreactarea, 1);
    		while (entm)
    		{
    		    chemreactareasexist = chemreactareasexist + 1; //Keep amount updated
		    if(boxesoverlap(entm.absmin, entm.absmax, myentsabsmins, myentsabsmaxs))
		    {
		    	return TRUE;
		    }
    		    entm = entm.chain;
    		}	
	}
	return FALSE;
}



void W_ThrowWeaponNoSwitch(vector velo, vector delta, float doreduce);
vector W_CalculateProjectileVelocity(vector pvelocity, vector mvelocity, float forceAbsolute);
void SkyCycle_NukeFlashSet(entity player);
void SkyCycle_NukeFlashDo(entity player, float srfakelight, float srambient);
string GetMapname(void);
float speedaward_lastupdate;
float speedaward_lastsent;
void SV_PlayerPhysics()
{
	vector wishvel, wishdir, v;
	float wishspeed, f, maxspd_mod, spd, maxairspd, airaccel, swampspd_mod, buttons, friction_mod;
	string temps;
	float buttons_prev;
	float not_allowed_to_move;
	string c;

	WarpZone_PlayerPhysics_FixVAngle();
	
	maxspd_mod = 1;
	friction_mod = 1;
	self.timesinkfalldamageaccelprotection = 0;
	
	if(g_minstagib && (self.items & IT_INVINCIBLE))
		maxspd_mod *= autocvar_g_minstagib_speed_highspeed;
	if(self.ballcarried)
		if(g_nexball)
			maxspd_mod *= autocvar_g_nexball_basketball_carrier_highspeed;
		else if(g_keepaway)
			maxspd_mod *= autocvar_g_keepaway_ballcarrier_highspeed;

	if(g_runematch)
	{
		if(self.runes & RUNE_SPEED)
		{
			if(self.runes & CURSE_SLOW)
				maxspd_mod *= autocvar_g_balance_rune_speed_combo_highspeed;
			else
				maxspd_mod *= autocvar_g_balance_rune_speed_highspeed;
		}
		else if(self.runes & CURSE_SLOW)
		{
			maxspd_mod *= autocvar_g_balance_curse_slow_highspeed;
		}
	}
	maxspd_mod *= autocvar_g_movement_highspeed;

	// fix physics stats for g_movement_highspeed
	// TODO maybe rather use maxairspeed? needs testing
	self.stat_sv_airaccel_qw = AdjustAirAccelQW(autocvar_sv_airaccel_qw, maxspd_mod);
	if(autocvar_sv_airstrafeaccel_qw)
		self.stat_sv_airstrafeaccel_qw = AdjustAirAccelQW(autocvar_sv_airstrafeaccel_qw, maxspd_mod);
	else
		self.stat_sv_airstrafeaccel_qw = 0;
	self.stat_sv_airspeedlimit_nonqw = autocvar_sv_airspeedlimit_nonqw * maxspd_mod;
	self.stat_sv_maxspeed = autocvar_sv_maxspeed * maxspd_mod; // also slow walking
	
	self.stat_sv_hudshownameenemies = sv_hudshownameenemies;
	
	if (self.stat_nukeflash) {
		if (time > self.nukeflash_nexttime) {	
			self.stat_nukeflash = self.stat_nukeflash - 1;
			self.nukeflash_nexttime = time + 0.3; //30 second flash fade for nuke 
			if(cvar("g_skycycle")) {
				SkyCycle_NukeFlashSet(self);
				self.nukeflash_sendagain = 2;
				self.nukeflash_sendagainnexttime = time + 0.3;
			} else {
				SkyCycle_NukeFlashDo(self, 0.75, 30);
			}
		}
	} else {
		if (self.nukeflash_sendagain) {
			//This is for sending the info again if the skycycle mutator is in effect
			//This is because at the end of a nuclear blast situation, in 
			//client/View.qc r_ambient and r_fakelight_intensity are reset to
			//their values before the nuke went off, which may be different
			//than what the current situation calls for due to changing 
			//light levels under the skycycle mutator.
			if(cvar("g_skycycle")) {
				SkyCycle_NukeFlashSet(self);
				self.nukeflash_sendagain = self.nukeflash_sendagain - 1;
			} else {
				self.nukeflash_sendagain = 0;
			}
			//print("here222\n");
	  	}
	
		if (self.nukeflash_sendagainnexttime) {
			//Same as above but this sends a final update at a specified time
			if(cvar("g_skycycle")) {
				if (time > self.nukeflash_sendagainnexttime) {
					SkyCycle_NukeFlashSet(self);
					self.nukeflash_sendagainnexttime = 0;
				}
			} else {
				self.nukeflash_sendagainnexttime = 0;
			}
			//print("here\n");
		}	
	}
	
	if (self.stat_bangflash) {
		if (time > self.bangflash_nexttime) {	
			self.stat_bangflash = self.stat_bangflash - 1;
			self.bangflash_nexttime = time + 0.1; //10 second flash fade for bang 
		}
	}
	
	if (self.permmangled_l || self.tempmangled_l || self.permmangled_r || self.tempmangled_r) {
	  if (self.weapon) {
	  	//print(ftos(self.weapon), "self weapon\n");
		if ((self.permmangled_l || self.tempmangled_l) && (self.permmangled_r || self.tempmangled_r)) {
			if (random() > 0.5) {
				self.weaponentity.state = WS_READY; //Have to do this to ensure it will be dropped
				W_ThrowWeaponNoSwitch(W_CalculateProjectileVelocity(self.velocity, v_forward * 1, FALSE), '0 0 0', TRUE);
				
				if (autocvar_g_nodropweapons) {
					//If this is set, the above will fail to
					//drop a weapon
					//So instead we just switch weapon to none
					//print ("failed to throw weapon due to nodropweapons, switching to none instead\n");
					W_SwitchWeapon_Force(self, 0);
				}
				
			}
		} else if (random() > 0.998) {
			self.weaponentity.state = WS_READY; //Have to do this to ensure it will be dropped
			W_ThrowWeaponNoSwitch(W_CalculateProjectileVelocity(self.velocity, v_forward * 1, FALSE), '0 0 0', TRUE);
			
			if (autocvar_g_nodropweapons) {
				//If this is set, the above will fail to
				//drop a weapon
				//So instead we just switch weapon to none
				//print ("failed to throw weapon due to nodropweapons, switching to none instead\n");
				W_SwitchWeapon_Force(self, 0);
			}
		}
	  }
	}
	
	if (self.permhobbled_l || self.temphobbled_l || self.permhobbled_r || self.temphobbled_r) {
		if ((self.permhobbled_l || self.temphobbled_l) && (self.permhobbled_r || self.temphobbled_r)) {
			//Done elsewhere
		} else if (self.parthobbledtime > time) {
			//Done elsewhere
		} else if (random() > 0.95) {
			self.parthobbledtime = time + 1;
		} else {
			self.parthobbledtime = 0;
		}
	}
	
	if (self.tempmangled_l || self.tempmangled_r || self.temphobbled_l || self.temphobbled_r) {
	 	if (!self.tempmanhoblocked) {
			if (self.tempmanhobheal_nexttime < time) {
			self.tempmangled_l = 0;
			self.tempmangled_r = 0;
			self.temphobbled_l = 0;
			self.temphobbled_r = 0;
			self.tempmanhoblocked = 0;
			self.tempmanhobheal_nexttime = 0;	
			}
		}
	}
	
	if (self.tempmovementimpared) {
	 	if (!self.tempmvmntimprdlocked) {
			if (self.tempmvmntimprdheal_nexttime < time) {
			self.tempmovementimpared = 0;
			self.tempmvmntimprdlocked = 0;
			self.tempmvmntimprdheal_nexttime = 0;	
			}
		}
	}
	
	ambient_temperature_playerphysics(self, 0);
	
	PossiblyReigniteFireFromOilFire(self);
	
	////////////////////////
	//START DRUNKEN STUFF
	if(!self.frozen)
	if(!self.freezetag_frozen)
	if(!self.stoned)
	if(self.deadflag == DEAD_NO)
	if(self.health > 0)
	{
	  if (Fire_IsBurning(self)) {
		OilFire_explosion_spawnoilburnermaybe(self);
	  }
	  
	  if(self.tempdisorientated)
	  {
	  	//If you got headshot and survived, this happens
		
	  	if(time < self.tempdisorientated_time) {
			if (!self.permblinded) {
				if (self.stat_blinded)
				if (time > self.tempblinded_nexttime) {
					
					self.stat_blinded = self.stat_blinded - 1;
					self.tempblinded_nexttime = time + 3;
				}
			}
			if (time > self.tempdisorientated_nexttime) {
				self.angles_x = self.angles_x + ((random()-0.5)*self.tempdisorientated*0.2);
				self.angles_y = self.angles_y + ((random()-0.5)*self.tempdisorientated*0.2);
				self.v_angle_x = self.v_angle_x + ((random()-0.5)*self.tempdisorientated*0.4);
				self.v_angle_y = self.v_angle_y + ((random()-0.5)*self.tempdisorientated*0.4);
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					msg_entity = self;
  					WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  					WriteAngle( MSG_ONE, self.v_angle_x);
					WriteAngle( MSG_ONE, self.v_angle_y);
  					WriteAngle( MSG_ONE, self.v_angle_z);
				}
				self.movement = self.movement * (1 + ((random()-0.5)*self.tempdisorientated*0.6));
				self.tempdisorientated_nexttime = time + 0.05;
			}
		} else {
			self.tempdisorientated = 0;
			if (!self.permblinded) {
				self.stat_blinded = 0;
			}
		}
	  }
	  
	  if(self.nextmetabolize < time) //Every 1 second
	  {
	  	//Do we forget...
	  	if(self.prisoner2_sufferingmemory > 0) {
	  		if (time > (self.prisoner2_sufferingmemory_lasttime+60)) {
				self.prisoner2_sufferingmemory = self.prisoner2_sufferingmemory * 0.95;
				if (self.prisoner2_sufferingmemory < 1) {
					//Note: added at a multiple of 0.1
					self.prisoner2_sufferingmemory = 0;
				}
			}
	 	}
		
		if(self.prisoner3_sufferingmemory > 0) {
	  		if (time > (self.prisoner3_sufferingmemory_lasttime+60)) {
				self.prisoner3_sufferingmemory = self.prisoner3_sufferingmemory * 0.95;
				if (self.prisoner3_sufferingmemory < 1) {
					//Note: added at a multiple of 0.2
					self.prisoner3_sufferingmemory = 0;
				}
			}
	 	}
		
	  	////////////////////////
		//Bath
		local float plyrisinoil, plyrisinmethane, plyrisinfilth, plyrwasinfithliquid;
		entity plyrfilthentity;
		plyrisinoil = 0;
		plyrisinmethane = 0;
		plyrisinfilth = 0;
		plyrwasinfithliquid = 0;
		plyrfilthentity = world;
		
		plyrfilthentity = PlayerIsInFilth(self);
		
		self.wasinfilthliquidlastmetabolize = 0;
		if (plyrfilthentity) {
		  if (plyrfilthentity != world) {
		    if (plyrfilthentity.isfilth) {
			plyrisinfilth = 1;
			plyrwasinfithliquid = TransferSmells (self, plyrfilthentity);
		    	if (self.waterlevel != WATERLEVEL_NONE) {
				self.wasinfilthliquidlastmetabolize = plyrwasinfithliquid;
			}
		    }	
		  }
		} 
		
		if (autocvar_sv_playerwaft) {
			if (time > self.nextwaft) {
				PlayerWaft(self);
				self.nextwaft = time + 3 + random();
			}
		}
		
		if (self.waterlevel != WATERLEVEL_NONE) {
			if (PlayerIsInOil(self)) {
				plyrisinoil = 1;
			}
			
			if (PlayerIsInMethane(self)) {
				plyrisinmethane = 1;
			}
		}
		
		if (self.waterlevel == WATERLEVEL_SUBMERGED)
		{
			local float cleanmultip;
			
			if (self.watertype == CONTENT_LAVA) { cleanmultip = 10; }
			else if (self.watertype == CONTENT_SLIME) { cleanmultip = 100; } //Really cleans you up well
			else { cleanmultip = 1; }
			
			if (plyrisinoil) {
				//Bathing In Oil
				self.fire_oilfire_entwasinoil = 1;
				//print("Set In Oil 1\n");
			} else if (plyrisinmethane) {
				//Do nothing
			} else if (plyrisinfilth) {
				//Do nothing
			} else {
				//Clean
				
				self.smell_acrid = bound(0, self.smell_acrid - (0.01 * cleanmultip), 10000);
				self.smell_alcohol =  bound(0, self.smell_alcohol - (0.05 * cleanmultip), 10000);
				self.smell_bodyodor = bound(0, self.smell_bodyodor - (0.02 * cleanmultip), 10000);
				self.smell_cheeze = bound(0, self.smell_cheeze - (0.03 * cleanmultip), 10000);
				self.smell_earthy = bound(0, self.smell_earthy - (0.03 * cleanmultip), 10000);
				self.smell_faeces = bound(0, self.smell_faeces - (0.01 * cleanmultip), 10000);
				self.smell_garlic = bound(0, self.smell_garlic- (0.02 * cleanmultip), 10000);
				self.smell_urine = bound(0, self.smell_urine - (0.02 * cleanmultip), 10000);
				self.smell_roses = bound(0, self.smell_roses - (0.1 * cleanmultip), 10000);
				self.smell_rottingflesh = bound(0, self.smell_rottingflesh - (0.01 * cleanmultip), 10000);
			
				if (self.watertype != CONTENT_LAVA) {
				self.fire_oilfire_entwasinoil = bound(0, self.fire_oilfire_entwasinoil - (0.2 * cleanmultip), 10000);
				self.fire_oilfire_entreignite = bound(0, self.fire_oilfire_entreignite - (0.2 * cleanmultip), 10000);
				}
				
				//print("Cleaning\n");
			}
		} else if (self.waterlevel == WATERLEVEL_SWIMMING) {
			if (plyrisinoil) {
				if (random() < 0.5) {
					//Swimming In Oil
					self.fire_oilfire_entwasinoil = 1;
					//print("Set In Oil 0.5 the time\n");
				}
			}
		} else if (self.waterlevel == WATERLEVEL_WETFEET) {
			if (plyrisinoil) {
				if (random() < 0.2) {
					//Walking In Oil
					self.fire_oilfire_entwasinoil = 1;
					//print("Set In Oil 0.2 the time\n");
				}
			}
		}
		//End Bath
		////////////////////////
	  
	  	if (self.species != SPECIES_ROBOT_SHINY
		&& self.species != SPECIES_ROBOT_RUSTY
		&& self.species != SPECIES_ROBOT_SOLID
		&& self.species != SPECIES_STONE
		&& self.species != SPECIES_SKELETON)
		{
			//Should drink 64oz per day.
			//24*60*60 = 86400
			//64/86400 = ~0.00074074074074074074
			self.con_water = self.con_water - 0.00074;
			
			if (self.con_water > 0)
			{
				self.con_waste_liquid = self.con_waste_liquid + 0.00074;
			}
			
			local float kcpersec;
			local float kcperday;
			local float kcweight; //kilos
			local float kcheight; //cm
			local float kcage;    //years
			
			kcweight = 77; //Around 170 lbs
			kcheight = 182; //Around 6 foot
			kcage = 35;
			
			if (self.plweight > 0.001)
			{
				kcweight = self.plweight;
			}
			
			if (self.age > 0.001)
			{
				kcage = self.age;
				if (self.age < 13)
				{
					kcheight = 134; //About 4'5"
				}
				else if (self.age < 15)
				{
					kcheight = 134; //About 5'3"
				}
			}
			
			kcperday = (10 * kcweight) + (6.25 * kcheight) - (4.93 * kcage);
			
			if (self.sex == SEX_FEMALE)
			{
				kcperday = kcperday - 162;
			}
			else if (self.sex == SEX_MALE)
			{
				kcperday = kcperday + 5;
			}
			else if (self.sex == SEX_HERMAPHRODITE)
			{
				kcperday = kcperday - 82;
			}
			else if (self.sex == SEX_EUNICH)
			{
				kcperday = kcperday - 16;
			}
			
			//Differing metabolic rates
			if (self.species == SPECIES_ALIEN)
			{
				kcperday = kcperday * 0.9;
			}
			else if (self.species == SPECIES_ANIMAL)
			{
				kcperday = kcperday * 1.2;
			}
			else if (self.species == SPECIES_INSECT)
			{
				kcperday = kcperday * 0.5;
			}
			
				//Activity level
				//kcperday = kcperday * 1.2; //Inactive
				//kcperday = kcperday * 1.375; //Light Activity
				//kcperday = kcperday * 1.55; //Middiling Activity
			kcperday = kcperday * 1.726; //Very Activity
				//kcperday = kcperday * 1.9; //Extremely Activity
						
			kcpersec = kcperday/86400; //24*60*60 = 86400 (Seconds in a day)
			
			if (self.con_kilocalories > 0)
			{
				//3,500 kcal = 1 lb. of fat
				//1 pound = 0.625 oz
				//3,500kc = 0.625 oz
				//5600kc = 1 ounce
				
				self.con_waste_solid = self.con_waste_solid + kcpersec/5600;
			}
			
			if (self.con_filler > 0)
			{
				local float rmfiller;
				
				rmfiller = kcpersec/5.6; //1000x faster
				
				if (rmfiller > self.con_filler) rmfiller = self.con_filler;
				
				self.con_filler = self.con_filler - rmfiller;
				self.con_waste_solid = self.con_waste_solid + rmfiller;
			}
			
			self.con_kilocalories = self.con_kilocalories - kcpersec;
			
			//Smells
			if (self.species == SPECIES_ANIMAL)
			{
				self.smell_bodyodor = self.smell_bodyodor + 0.0003;
			} else {
				self.smell_bodyodor = self.smell_bodyodor + 0.0001;
			}
			
			////Testing stuff, Comment below out
			//self.con_waste_solid = 100;
			//print(etos(self)," SmellFaeces: ", ftos(self.smell_faeces)," --- SmellAlcohol ", ftos(self.smell_alcohol), " SmellBO: ", ftos(self.smell_bodyodor), "\n");
			//print(etos(self)," KC: ", ftos(self.con_kilocalories)," --- KCPD ", ftos(kcperday), " WasteSolid: ", ftos(self.con_waste_solid), "\n");
			//print(etos(self)," Water: ", ftos(self.con_water), " WasteLiquid: ", ftos(self.con_waste_liquid ),"\n");
		}
		
		if (self.con_alcohol)
		{
			//Should be .5oz per hour;
			//60*60 = 3600
			//0.5/3600 =  ~0.00013888888888888889
			self.con_alcohol = self.con_alcohol - 0.00014;
			
			if (self.species == SPECIES_ROBOT_SHINY
			|| self.species == SPECIES_ROBOT_RUSTY
			|| self.species == SPECIES_ROBOT_SOLID
			|| self.species == SPECIES_STONE
			|| self.species == SPECIES_SKELETON)
			{
				self.drunken = 0;
			} else {
				float drunkmultip;
				drunkmultip = 1;
				if (self.sex == SEX_FEMALE)
				{
					drunkmultip = drunkmultip * 2;
				}
				else if (self.sex == SEX_MALE)
				{
					drunkmultip = drunkmultip * 0.5;
				}
				else if (self.sex == SEX_HERMAPHRODITE)
				{
					drunkmultip = drunkmultip * 0.95;
				}
				else if (self.sex == SEX_EUNICH)
				{
					drunkmultip = drunkmultip * 1.25;
				}
				
				if (self.plweight > 0.001)
				{
					drunkmultip = drunkmultip * (100/self.plweight);	
				}
				
				if (self.species == SPECIES_ALIEN)
				{
					drunkmultip = drunkmultip * 1.5;
				}
				else if (self.species == SPECIES_ANIMAL)
				{
					drunkmultip = drunkmultip * 2;
				}
				else if (self.species == SPECIES_INSECT)
				{
					drunkmultip = drunkmultip * 2.5;
				}
				
				if (self.species == SPECIES_HUMAN || self.species == SPECIES_FAE)
				if (self.age > 0.001)
				{
					if (self.age < 13)
					{
						drunkmultip = drunkmultip * 2;	
					}
					else if (self.age < 15)
					{
						drunkmultip = drunkmultip * 1.5;
					}
					else if (self.age < 18)
					{
						drunkmultip = drunkmultip * 1.2;
					}
					else if (self.age < 25)
					{
						drunkmultip = drunkmultip * 1.01;
					}
					else if (self.age < 30)
					{
						drunkmultip = drunkmultip * 0.95;
					}
					else if (self.age < 40)
					{
						drunkmultip = drunkmultip * 0.9;
					}
					else if (self.age < 50)
					{
						drunkmultip = drunkmultip * 0.85;
					}
					else if (self.age < 60)
					{
						drunkmultip = drunkmultip * 0.80;
					}
					else if (self.age < 70)
					{
						drunkmultip = drunkmultip * 0.70;
					}
					else if (self.age < 85)
					{
						drunkmultip = drunkmultip * 0.65;
					} else {
						drunkmultip = drunkmultip * 1.11;
					}
				
				}
				
				self.drunken = self.con_alcohol * drunkmultip;
			}
		}
		
		if (self.con_alcohol < 0) self.con_alcohol = 0;
		if (self.con_water < -2) self.con_water = -2;
		self.nextmetabolize = time + 1;
		
		//print(etos(self)," ALC: ", ftos(self.con_alcohol)," --- ", ftos(self.drunken), " Water: ", ftos(self.con_water),"\n");
	  }
	
	
	  if ((self.drunken > 2) && (self.nextdrunkadjust < time))
	  {
		self.angles_x = self.angles_x + ((random()-0.5)*self.drunken*0.2);
		self.angles_y = self.angles_y + ((random()-0.5)*self.drunken*0.2);
		self.v_angle_x = self.v_angle_x + ((random()-0.5)*self.drunken*0.4);
		self.v_angle_y = self.v_angle_y + ((random()-0.5)*self.drunken*0.4);
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			msg_entity = self;
  			WriteByte (MSG_ONE, SVC_SETVIEWANGLES);
  			WriteAngle( MSG_ONE, self.v_angle_x);
			WriteAngle( MSG_ONE, self.v_angle_y);
  			WriteAngle( MSG_ONE, self.v_angle_z);
		}
		
		if (self.drunken < 4) {
			self.nextdrunkadjust = time + 0.44;
		} else if (self.drunken < 8) {
			self.nextdrunkadjust = time + 0.33;
		} else if (self.drunken < 12) {
			self.nextdrunkadjust = time + 0.22;
		} else if (self.drunken < 16) {
			self.nextdrunkadjust = time + 0.11;
		} else {
			self.nextdrunkadjust = time + 0.1;
		}
		
		//print("here\n");
	  }
	  
	  if (self.drunken > 12) {
		self.movement = self.movement * (1 + ((random()-0.5)*self.drunken*0.4));
	  } else if (self.drunken > 16) {
		self.movement = self.movement * (1 + ((random()-0.5)*self.drunken*0.6));
	  }
	}
	//END DRUNKEN STUFF
	////////////////////////


	/////////////////////////////////////////////////////
	/////////////////////////////////////////////////////
	//This below is so when we have a placeholder pilot
	//(In a multi-slot vehicle)
	//The movement and angles are correct to the
	//original player pilot who vacated the seat for
	//a gunner position.
	//we save the information here, and then use it
	//in CmdVehiclesChangeSeatAsPilot and vehiclepilotplaceholder_think
	//in cheats.qc
	self.prephysplug_movement = self.movement;
	self.prephysplug_v_angle = self.v_angle;
	
	self.prephysplug_button_hook = self.BUTTON_USE;
	self.prephysplug_button_hook = self.BUTTON_HOOK;
	self.prephysplug_button_jump = self.BUTTON_JUMP;
	self.prephysplug_button_crouch = self.BUTTON_CROUCH;
	/////////////////////////////////////////////////////
	/////////////////////////////////////////////////////
	

    if(self.PlayerPhysplug)
        if(self.PlayerPhysplug())
            return;

	MaybeDoClairvoyance(self);

	self.race_movetime_frac += frametime;
	f = floor(self.race_movetime_frac);
	self.race_movetime_frac -= f;
	self.race_movetime_count += f;
	self.race_movetime = self.race_movetime_frac + self.race_movetime_count;

	anticheat_physics();

	buttons = self.BUTTON_ATCK + 2 * self.BUTTON_JUMP + 4 * self.BUTTON_ATCK2 + 8 * self.BUTTON_ZOOM + 16 * self.BUTTON_CROUCH + 32 * self.BUTTON_HOOK + 64 * self.BUTTON_USE + 128 * (self.movement_x < 0) + 256 * (self.movement_x > 0) + 512 * (self.movement_y < 0) + 1024 * (self.movement_y > 0);

	if(!buttons)
		c = "x";
	else if(buttons == 1)
		c = "1";
	else if(buttons == 2)
		c = " ";
	else if(buttons == 128)
		c = "s";
	else if(buttons == 256)
		c = "w";
	else if(buttons == 512)
		c = "a";
	else if(buttons == 1024)
		c = "d";
	else
		c = "?";

	if(c == substring(specialcommand, self.specialcommand_pos, 1))
	{
		self.specialcommand_pos += 1;
		if(self.specialcommand_pos >= strlen(specialcommand))
		{
			self.specialcommand_pos = 0;
			SpecialCommand();
			return;
		}
	}
	else if(self.specialcommand_pos && (c != substring(specialcommand, self.specialcommand_pos - 1, 1)))
		self.specialcommand_pos = 0;

	if(!sv_maxidle_spectatorsareidle || self.movetype == MOVETYPE_WALK)
	{
		if(buttons != self.buttons_old || self.movement != self.movement_old || self.v_angle != self.v_angle_old)
			self.parm_idlesince = time;
	}
	buttons_prev = self.buttons_old;
	self.buttons_old = buttons;
	self.movement_old = self.movement;
	self.v_angle_old = self.v_angle;

	if(time < self.nickspamtime)
	if(self.nickspamcount >= autocvar_g_nick_flood_penalty_yellow)
	{
		// slight annoyance for nick change scripts
		self.movement = -1 * self.movement;
		self.BUTTON_ATCK = self.BUTTON_JUMP = self.BUTTON_ATCK2 = self.BUTTON_ZOOM = self.BUTTON_CROUCH = self.BUTTON_HOOK = self.BUTTON_USE = 0;

		if(self.nickspamcount >= autocvar_g_nick_flood_penalty_red) // if you are persistent and the slight annoyance above does not stop you, I'll show you!
		{
			self.angles_x = random() * 360;
			self.angles_y = random() * 360;
			// at least I'm not forcing retardedview by also assigning to angles_z
			self.fixangle = TRUE;
		}
	}

	if (self.punchangle != '0 0 0')
	{
		f = vlen(self.punchangle) - 10 * frametime;
		if (f > 0)
			self.punchangle = normalize(self.punchangle) * f;
		else
			self.punchangle = '0 0 0';
	}

	if (self.punchvector != '0 0 0')
	{
		f = vlen(self.punchvector) - 30 * frametime;
		if (f > 0)
			self.punchvector = normalize(self.punchvector) * f;
		else
			self.punchvector = '0 0 0';
	}

	if (clienttype(self) == CLIENTTYPE_BOT)
	{
		if(playerdemo_read())
			return;
		bot_think();
	}
	
	self.items &~= IT_USING_JETPACK;

	if(self.classname == "player")
	{
		if(self.race_penalty)
			if(time > self.race_penalty)
				self.race_penalty = 0;

		not_allowed_to_move = 0;
		if(self.race_penalty)
			not_allowed_to_move = 1;
		if(!autocvar_sv_ready_restart_after_countdown)
		if(time < game_starttime)
			not_allowed_to_move = 1;

		if(not_allowed_to_move)
		{
			self.velocity = '0 0 0';
			self.movetype = MOVETYPE_NONE;
			self.disableclientprediction = 2;
		}
		else if(self.disableclientprediction == 2)
		{
			if(self.movetype == MOVETYPE_NONE)
				self.movetype = MOVETYPE_WALK;
			self.disableclientprediction = 0;
		}
	}

	if (self.movetype == MOVETYPE_NONE)
		return;

	// when we get here, disableclientprediction cannot be 2
	self.disableclientprediction = 0;
	if(time < self.ladder_time)
		self.disableclientprediction = 1;

	MUTATOR_CALLHOOK(PlayerPhysics);
	
	if(self.vuln_movement_imparable) {
	if(self.tempmovementimpared)
	{
		if(self.tempmovementimpared > 0) {
			local float mytempmovementmultip;
			mytempmovementmultip = 1;
			if (self.tempmovementimpared >= 1.5) {
				mytempmovementmultip = 0.2;
			} else if (self.tempmovementimpared >= 1.25) {
				mytempmovementmultip = 0.25;
			} else if (self.tempmovementimpared >= 1) {
				mytempmovementmultip = 0.3;
			} else if (self.tempmovementimpared >= 0.75) {
				mytempmovementmultip = 0.4;
			} else if (self.tempmovementimpared >= 0.5) {
				mytempmovementmultip = 0.5;
			} else if (self.tempmovementimpared >= 0.4) {
				mytempmovementmultip = 0.6;
			} else if (self.tempmovementimpared >= 0.3) {
				mytempmovementmultip = 0.7;
			} else if (self.tempmovementimpared >= 0.2) {
				mytempmovementmultip = 0.8;
			} else {
				mytempmovementmultip = 0.9;
			}
		
			self.movement_x = self.movement_x * mytempmovementmultip;
			self.movement_y = self.movement_y * mytempmovementmultip;
			self.movement_z = self.movement_z * mytempmovementmultip;
		}
	}
	}
	
	if(self.jailee != world)
	if(self.jailee.stoned)
	if(self.jailee.health >= 1)
	{
		//Hard to drag stone statues around, they are heavy and have friction
		self.movement_x = self.movement_x * 0.05;
		self.movement_y = self.movement_y * 0.05;
		self.BUTTON_JUMP = 0;
	}
	
	if(self.player_blocked || self.frozen || self.stoned || self.prisonerlevel >= 3)
	{
		self.movement = '0 0 0';
		self.disableclientprediction = 1;
	}
	
	if(self.handcuffed)
	{
		if (self.jailor != world)
		{
			self.disableclientprediction = 1;
			self.origin = self.jailor.origin + self.prison1spot;
			setorigin(self, self.origin);
		}
	}
	else if (self.prisonerlevel == 3)
	{
		if (self.prison3ent != world)
		{
			self.prison3angles = self.prison3ent.angles;
			self.prison3spot = self.prison3ent.origin;
		}
		
		self.angles = self.prison3angles;

		if (self.origin != self.prison3spot)
		{	
			self.origin = self.prison3spot;
			setorigin(self, self.origin);
		}	
		if (self.movetype != MOVETYPE_NONE)
			self.movetype = MOVETYPE_NONE;
	}
	
	if (self.frozen)
	{
		self.revive_progress = bound(0, self.revive_progress + frametime * self.revive_speed, 1);
		if(self.revive_progress >= 1) Unfreeze(self);
	}
	
	if (self.stoned)
	{
		self.v_angle_x = self.angles_x;
		self.v_angle_y = self.angles_y;
		self.v_angle_z = self.angles_z;
		self.strevive_progress = bound(0, self.strevive_progress + frametime * self.strevive_speed, 1);
		if(self.strevive_progress >= 1) Unstone(self);
	}

	maxspd_mod = 1;

	swampspd_mod = 1;
	if(self.in_swamp) {
		swampspd_mod = self.swamp_slowdown; //cvar("g_balance_swamp_moverate");
	}

	// conveyors: first fix velocity
	if(self.conveyor.state)
		self.velocity -= self.conveyor.movedir;

	if(self.classname != "player")
	{
		maxspd_mod = autocvar_sv_spectator_speed_multiplier;
		if(!self.spectatorspeed)
			self.spectatorspeed = maxspd_mod;
		if(self.impulse && self.impulse <= 19)
		{
			if(self.lastclassname != "player")
			{
				if(self.impulse == 10 || self.impulse == 15 || self.impulse == 18)
					self.spectatorspeed = bound(1, self.spectatorspeed + 0.5, 5);
				else if(self.impulse == 11)
					self.spectatorspeed = maxspd_mod;
				else if(self.impulse == 12 || self.impulse == 16  || self.impulse == 19)
					self.spectatorspeed = bound(1, self.spectatorspeed - 0.5, 5);
				else if(self.impulse >= 1 && self.impulse <= 9)
					self.spectatorspeed = 1 + 0.5 * (self.impulse - 1);
			} // otherwise just clear
			self.impulse = 0;
		}
		maxspd_mod = self.spectatorspeed;
	}

	spd = max(self.stat_sv_maxspeed, autocvar_sv_maxairspeed) * maxspd_mod * swampspd_mod;
	if(self.speed != spd)
	{
		self.speed = spd;
		temps = ftos(spd);
		stuffcmd(self, strcat("cl_forwardspeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_backspeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_sidespeed ", temps, "\n"));
		stuffcmd(self, strcat("cl_upspeed ", temps, "\n"));
	}

	maxspd_mod *= swampspd_mod; // only one common speed modder please!
	swampspd_mod = 1;
	
	if (timesinksactive) {
		if (self.timesinkent && self.timesinkent != world) {
		if (self.timesinkent.ammount3 != 0) {
		if (self.timesinkent.ammount4 >= 5) {
			//At level 5 and above we have still to control self in time
			local float tmsnkamnt;
			
			if (self.timesinkent.amnt < autocvar_slowmo) {
				tmsnkamnt = autocvar_slowmo;
			} else {
				tmsnkamnt = self.timesinkent.amnt;
			}
			
			if (tmsnkamnt > 0) {		
				maxspd_mod = maxspd_mod / tmsnkamnt;
				self.movement_x = self.movement_x / tmsnkamnt;
				self.movement_y = self.movement_y / tmsnkamnt;
				self.movement_z = self.movement_z / tmsnkamnt;
				friction_mod = 1 / tmsnkamnt;
				self.timesinkfalldamageaccelprotection = 1;
			}
		}
		}
		}

	}
	
	// if dead, behave differently
	if (self.deadflag)
		goto end;

	if (!self.fixangle && !g_bugrigs)
	{
		if (self.prisonerlevel != 3)
		{
			self.angles_x = 0;
			self.angles_y = self.v_angle_y;
			self.angles_z = 0;
		}
	}

	if(self.flags & FL_ONGROUND)
	if(self.classname == "player") // no fall sounds for observers thank you very much
	if(self.wasFlying)
	{
		self.wasFlying = 0;

		if(self.waterlevel < WATERLEVEL_SWIMMING)
		if(time >= self.ladder_time)
		if not(self.hook)
		{
			self.nextstep = time + 0.3 + random() * 0.1;
			trace_dphitq3surfaceflags = 0;
			tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
			if not(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOSTEPS)
			{
				if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_METALSTEPS)
					GlobalSound(globalsound_metalfall, CH_PLAYER, VOICETYPE_PLAYERSOUND);
				else
					GlobalSound(globalsound_fall, CH_PLAYER, VOICETYPE_PLAYERSOUND);
			}
		}
	}

	if(IsFlying(self))
		self.wasFlying = 1;

	if(self.classname == "player")
		CheckPlayerJump();

	if (self.flags & FL_WATERJUMP )
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;
		if (time > self.teleport_time || self.waterlevel == WATERLEVEL_NONE)
		{
			self.flags &~= FL_WATERJUMP;
			self.teleport_time = 0;
		}
	}
	else if (g_bugrigs && self.classname == "player")
	{
		RaceCarPhysics();
	}
	else if (self.movetype == MOVETYPE_NOCLIP || self.movetype == MOVETYPE_FLY || self.movetype == MOVETYPE_FLY_WORLDONLY)
	{
		// noclipping or flying
		self.flags &~= FL_ONGROUND;

		self.velocity = self.velocity * (1 - frametime * autocvar_sv_friction * friction_mod);
		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > self.stat_sv_maxspeed*maxspd_mod)
			wishspeed = self.stat_sv_maxspeed*maxspd_mod;
		if (time >= self.teleport_time)
			PM_Accelerate(wishdir, wishspeed, wishspeed, autocvar_sv_accelerate*maxspd_mod, 1, 0, 0, 0);
	}
	else if (self.waterlevel >= WATERLEVEL_SWIMMING)
	{
		// swimming
		self.flags &~= FL_ONGROUND;

		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		if (wishvel == '0 0 0')
			wishvel = '0 0 -60'; // drift towards bottom

		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > self.stat_sv_maxspeed*maxspd_mod)
			wishspeed = self.stat_sv_maxspeed*maxspd_mod;
		wishspeed = wishspeed * 0.7;

		// water friction
		self.velocity = self.velocity * (1 - frametime * autocvar_sv_friction * friction_mod);

		// water acceleration
		PM_Accelerate(wishdir, wishspeed, wishspeed, autocvar_sv_accelerate*maxspd_mod, 1, 0, 0, 0);
	}
	else if (time < self.ladder_time)
	{
		// on a spawnfunc_func_ladder or swimming in spawnfunc_func_water
		self.flags &~= FL_ONGROUND;

		float g;
		g = autocvar_sv_gravity * frametime;
		if(self.gravity)
			g *= self.gravity;
		if(autocvar_sv_gameplayfix_gravityunaffectedbyticrate)
		{
			g *= 0.5;
			self.velocity_z += g;
		}

		self.velocity = self.velocity * (1 - frametime * autocvar_sv_friction * friction_mod);
		makevectors(self.v_angle);
		//wishvel = v_forward * self.movement_x + v_right * self.movement_y + v_up * self.movement_z;
		wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;
		self.velocity_z += g;
		if (self.ladder_entity.classname == "func_water")
		{
			f = vlen(wishvel);
			if (f > self.ladder_entity.speed)
				wishvel = wishvel * (self.ladder_entity.speed / f);

			self.watertype = self.ladder_entity.skin;
			f = self.ladder_entity.origin_z + self.ladder_entity.maxs_z;
			if ((self.origin_z + self.view_ofs_z) < f)
				self.waterlevel = WATERLEVEL_SUBMERGED;
			else if ((self.origin_z + (self.mins_z + self.maxs_z) * 0.5) < f)
				self.waterlevel = WATERLEVEL_SWIMMING;
			else if ((self.origin_z + self.mins_z + 1) < f)
				self.waterlevel = WATERLEVEL_WETFEET;
			else
			{
				self.waterlevel = WATERLEVEL_NONE;
				self.watertype = CONTENT_EMPTY;
			}
		}
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > self.stat_sv_maxspeed*maxspd_mod)
			wishspeed = self.stat_sv_maxspeed*maxspd_mod;
		if (time >= self.teleport_time)
		{
			// water acceleration
			PM_Accelerate(wishdir, wishspeed, wishspeed, autocvar_sv_accelerate*maxspd_mod, 1, 0, 0, 0);
		}
	}
	else if ((self.items & IT_JETPACK) && self.BUTTON_HOOK && (!autocvar_g_jetpack_fuel || self.ammo_fuel >= 0.01 || self.items & IT_UNLIMITED_WEAPON_AMMO) && !self.freezetag_frozen && !self.frozen && !self.stoned && (self.prisonerlevel < 3))
	{
		//makevectors(self.v_angle_y * '0 1 0');
		makevectors(self.v_angle);
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
		// add remaining speed as Z component
		maxairspd = autocvar_sv_maxairspeed*max(1, maxspd_mod);
		// fix speedhacks :P
		wishvel = normalize(wishvel) * min(vlen(wishvel) / maxairspd, 1);
		// add the unused velocity as up component
		wishvel_z = 0;

		// if(self.BUTTON_JUMP)
			wishvel_z = sqrt(max(0, 1 - wishvel * wishvel));

		// it is now normalized, so...
		float a_side, a_up, a_add, a_diff;
		a_side = autocvar_g_jetpack_acceleration_side;
		a_up = autocvar_g_jetpack_acceleration_up;
		a_add = autocvar_g_jetpack_antigravity * autocvar_sv_gravity;

		wishvel_x *= a_side;
		wishvel_y *= a_side;
		wishvel_z *= a_up;
		wishvel_z += a_add;

		float best;
		best = 0;
		//////////////////////////////////////////////////////////////////////////////////////
		// finding the maximum over all vectors of above form
		// with wishvel having an absolute value of 1
		//////////////////////////////////////////////////////////////////////////////////////
		// we're finding the maximum over
		//   f(a_side, a_up, a_add, z) := a_side * (1 - z^2) + (a_add + a_up * z)^2;
		// for z in the range from -1 to 1
		//////////////////////////////////////////////////////////////////////////////////////
		// maximum is EITHER attained at the single extreme point:
		a_diff = a_side * a_side - a_up * a_up;
		if(a_diff != 0)
		{
			f = a_add * a_up / a_diff; // this is the zero of diff(f(a_side, a_up, a_add, z), z)
			if(f > -1 && f < 1) // can it be attained?
			{
				best = (a_diff + a_add * a_add) * (a_diff + a_up * a_up) / a_diff;
				//print("middle\n");
			}
		}
		// OR attained at z = 1:
		f = (a_up + a_add) * (a_up + a_add);
		if(f > best)
		{
			best = f;
			//print("top\n");
		}
		// OR attained at z = -1:
		f = (a_up - a_add) * (a_up - a_add);
		if(f > best)
		{
			best = f;
			//print("bottom\n");
		}
		best = sqrt(best);
		//////////////////////////////////////////////////////////////////////////////////////

		//print("best possible acceleration: ", ftos(best), "\n");

		float fxy, fz;
		fxy = bound(0, 1 - (self.velocity * normalize(wishvel_x * '1 0 0' + wishvel_y * '0 1 0')) / autocvar_g_jetpack_maxspeed_side, 1);
		if(wishvel_z - autocvar_sv_gravity > 0)
			fz = bound(0, 1 - self.velocity_z / autocvar_g_jetpack_maxspeed_up, 1);
		else
			fz = bound(0, 1 + self.velocity_z / autocvar_g_jetpack_maxspeed_up, 1);

		float fvel;
		fvel = vlen(wishvel);
		wishvel_x *= fxy;
		wishvel_y *= fxy;
		wishvel_z = (wishvel_z - autocvar_sv_gravity) * fz + autocvar_sv_gravity;

		fvel = min(1, vlen(wishvel) / best);
		if(autocvar_g_jetpack_fuel && !(self.items & IT_UNLIMITED_WEAPON_AMMO))
			f = min(1, self.ammo_fuel / (autocvar_g_jetpack_fuel * frametime * fvel));
		else
			f = 1;

		//print("this acceleration: ", ftos(vlen(wishvel) * f), "\n");

		if (f > 0 && wishvel != '0 0 0')
		{
			self.velocity = self.velocity + wishvel * f * frametime;
			if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
				self.ammo_fuel -= autocvar_g_jetpack_fuel * frametime * fvel * f;
			self.flags &~= FL_ONGROUND;
			self.items |= IT_USING_JETPACK;

			// jetpack also inhibits health regeneration, but only for 1 second
			self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_pause_fuel_regen);
		}
	}
	else if (self.flags & FL_ONGROUND)
	{
		// we get here if we ran out of ammo
		if((self.items & IT_JETPACK) && self.BUTTON_HOOK && !(buttons_prev & 32) && self.ammo_fuel < 0.01)
			sprint(self, "You don't have any fuel for the ^2Jetpack\n");

		// walking
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;

		if(!(self.lastflags & FL_ONGROUND))
		{
			if(autocvar_speedmeter)
				dprint(strcat("landing velocity: ", vtos(self.velocity), " (abs: ", ftos(vlen(self.velocity)), ")\n"));
			if(self.lastground < time - 0.3)
				self.velocity = self.velocity * (1 - autocvar_sv_friction_on_land * friction_mod);
			if(self.jumppadcount > 1)
				dprint(strcat(ftos(self.jumppadcount), "x jumppad combo\n"));
			self.jumppadcount = 0;
		}

#ifdef LETS_TEST_FTEQCC
		if(self.velocity_x || self.velocity_y)
		{
			// good
		}
		else
		{
			if(self.velocity_x)
				checkclient();
			if(self.velocity_y)
				checkclient();
		}
#endif

		v = self.velocity;
		v_z = 0;
		f = vlen(v);
		if(f > 0)
		{
			trace_dphitq3surfaceflags = 0;
			tracebox(self.origin, self.mins, self.maxs, self.origin - '0 0 1', MOVE_NOMONSTERS, self);
			
			if (f < autocvar_sv_stopspeed)
				if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK)
					f = 1 - frametime * (autocvar_sv_stopspeed / f) * autocvar_sv_friction_slick * friction_mod;
				else
					f = 1 - frametime * (autocvar_sv_stopspeed / f) * autocvar_sv_friction * friction_mod;
			else
				if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_SLICK)
					f = 1 - frametime * autocvar_sv_friction_slick * friction_mod;
				else
					f = 1 - frametime * autocvar_sv_friction * friction_mod;
			if (f > 0)
				self.velocity = self.velocity * f;
			else
				self.velocity = '0 0 0';
			/*
			   Mathematical analysis time!

			   Our goal is to invert this mess.

			   For the two cases we get:
			   	v = v0 * (1 - frametime * (autocvar_sv_stopspeed / v0) * autocvar_sv_friction)
			   	  = v0 - frametime * autocvar_sv_stopspeed * autocvar_sv_friction
				v0 = v + frametime * autocvar_sv_stopspeed * autocvar_sv_friction
			   and
			   	v = v0 * (1 - frametime * autocvar_sv_friction)
			   	v0 = v / (1 - frametime * autocvar_sv_friction)

			   These cases would be chosen ONLY if:
			   	v0 < autocvar_sv_stopspeed
				v + frametime * autocvar_sv_stopspeed * autocvar_sv_friction < autocvar_sv_stopspeed
				v < autocvar_sv_stopspeed * (1 - frametime * autocvar_sv_friction)
			   and, respectively:
			   	v0 >= autocvar_sv_stopspeed
			   	v / (1 - frametime * autocvar_sv_friction) >= autocvar_sv_stopspeed
			   	v >= autocvar_sv_stopspeed * (1 - frametime * autocvar_sv_friction)
			 */
		}

		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = vlen(wishvel);
		if (wishspeed > self.stat_sv_maxspeed*maxspd_mod)
			wishspeed = self.stat_sv_maxspeed*maxspd_mod;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		if (time >= self.teleport_time)
			PM_Accelerate(wishdir, wishspeed, wishspeed, autocvar_sv_accelerate*maxspd_mod, 1, 0, 0, 0);
	}
	else
	{
		float wishspeed0;
		// we get here if we ran out of ammo
		if((self.items & IT_JETPACK) && self.BUTTON_HOOK && !(buttons_prev & 32) && self.ammo_fuel < 0.01)
			sprint(self, "You don't have any fuel for the ^2Jetpack\n");

		if(maxspd_mod < 1)
		{
			maxairspd = autocvar_sv_maxairspeed*maxspd_mod;
			airaccel = autocvar_sv_airaccelerate*maxspd_mod;
		}
		else
		{
			maxairspd = autocvar_sv_maxairspeed;
			airaccel = autocvar_sv_airaccelerate;
		}
		// airborn
		makevectors(self.v_angle_y * '0 1 0');
		wishvel = v_forward * self.movement_x + v_right * self.movement_y;
		// acceleration
		wishdir = normalize(wishvel);
		wishspeed = wishspeed0 = vlen(wishvel);
		if (wishspeed0 > self.stat_sv_maxspeed*maxspd_mod)
			wishspeed0 = self.stat_sv_maxspeed*maxspd_mod;
		if (wishspeed > maxairspd)
			wishspeed = maxairspd;
		if (self.crouch)
			wishspeed = wishspeed * 0.5;
		if (time >= self.teleport_time)
		{
			float accelerating;
			float wishspeed2;
			float airaccelqw;
			float strafity;

			airaccelqw = self.stat_sv_airaccel_qw;
			accelerating = (self.velocity * wishdir > 0);
			wishspeed2 = wishspeed;

			// CPM
			if(autocvar_sv_airstopaccelerate)
			{
				vector curdir;
				curdir = self.velocity;
				curdir_z = 0;
				curdir = normalize(curdir);
				airaccel = airaccel + (autocvar_sv_airstopaccelerate*maxspd_mod - airaccel) * max(0, -(curdir * wishdir));
			}
			// note that for straight forward jumping:
			// step = accel * frametime * wishspeed0;
			// accel  = bound(0, wishspeed - vel_xy_current, step) * accelqw + step * (1 - accelqw);
			// -->
			// dv/dt = accel * maxspeed (when slow)
			// dv/dt = accel * maxspeed * (1 - accelqw) (when fast)
			// log dv/dt = logaccel + logmaxspeed (when slow)
			// log dv/dt = logaccel + logmaxspeed + log(1 - accelqw) (when fast)
			strafity = IsMoveInDirection(self.movement, -90) + IsMoveInDirection(self.movement, +90); // if one is nonzero, other is always zero
			if(autocvar_sv_maxairstrafespeed)
				wishspeed = min(wishspeed, GeomLerp(autocvar_sv_maxairspeed*maxspd_mod, strafity, autocvar_sv_maxairstrafespeed*maxspd_mod));
			if(autocvar_sv_airstrafeaccelerate)
				airaccel = GeomLerp(airaccel, strafity, autocvar_sv_airstrafeaccelerate*maxspd_mod);
			if(self.stat_sv_airstrafeaccel_qw)
				airaccelqw = copysign(1-GeomLerp(1-fabs(self.stat_sv_airaccel_qw), strafity, 1-fabs(self.stat_sv_airstrafeaccel_qw)), ((strafity > 0.5) ? self.stat_sv_airstrafeaccel_qw : self.stat_sv_airaccel_qw));
			// !CPM

			if(autocvar_sv_warsowbunny_turnaccel && accelerating && self.movement_y == 0 && self.movement_x != 0)
				PM_AirAccelerate(wishdir, wishspeed);
			else
				PM_Accelerate(wishdir, wishspeed, wishspeed0, airaccel, airaccelqw, autocvar_sv_airaccel_qw_stretchfactor, autocvar_sv_airaccel_sideways_friction / maxairspd, self.stat_sv_airspeedlimit_nonqw);

			if(autocvar_sv_aircontrol)
				CPM_PM_Aircontrol(wishdir, wishspeed2);
		}
	}

	if((g_cts || g_race) && self.classname != "observer") {
		if(vlen(self.velocity - self.velocity_z * '0 0 1') > speedaward_speed) {
			speedaward_speed = vlen(self.velocity - self.velocity_z * '0 0 1');
			speedaward_holder = self.netname;
			speedaward_uid = self.crypto_idfp;
			speedaward_lastupdate = time;
		}
		if(speedaward_speed > speedaward_lastsent && time - speedaward_lastupdate > 1) {
			string rr;
			if(g_cts)
				rr = CTS_RECORD;
			else
				rr = RACE_RECORD;
			race_send_speedaward(MSG_ALL);
			speedaward_lastsent = speedaward_speed;
			if (speedaward_speed > speedaward_alltimebest && speedaward_uid != "") {
				speedaward_alltimebest = speedaward_speed;
				speedaward_alltimebest_holder = speedaward_holder;
				speedaward_alltimebest_uid = speedaward_uid;
				db_put(ServerProgsDB, strcat(GetMapname(), rr, "speed/speed"), ftos(speedaward_alltimebest));
				db_put(ServerProgsDB, strcat(GetMapname(), rr, "speed/crypto_idfp"), speedaward_alltimebest_uid);
				race_send_speedaward_alltimebest(MSG_ALL);
			}
		}
	}

	float xyspeed;
	xyspeed = vlen('1 0 0' * self.velocity_x + '0 1 0' * self.velocity_y);
	if(self.weapon == WEP_NEX && autocvar_g_balance_nex_charge && autocvar_g_balance_nex_charge_velocity_rate && xyspeed > autocvar_g_balance_nex_charge_minspeed)
	{
		// add a maximum of charge_velocity_rate when going fast (f = 1), gradually increasing from minspeed (f = 0) to maxspeed
	        xyspeed = min(xyspeed, autocvar_g_balance_nex_charge_maxspeed);
		f = (xyspeed - autocvar_g_balance_nex_charge_minspeed) / (autocvar_g_balance_nex_charge_maxspeed - autocvar_g_balance_nex_charge_minspeed);
		// add the extra charge
		self.nex_charge = min(1, self.nex_charge + autocvar_g_balance_nex_charge_velocity_rate * f * frametime);
	}
:end
	if(self.flags & FL_ONGROUND)
		self.lastground = time;

	// conveyors: then break velocity again
	if(self.conveyor.state)
		self.velocity += self.conveyor.movedir;

	self.lastflags = self.flags;
	self.lastclassname = self.classname;
}
