
.float cvar_cl_brawling_timeout;


// these are used to store the last key press time for each of the keys.. //Changed to br_ so as not to conflict with brawling code
.float br_last_FORWARD_KEY_time;
.float br_last_BACKWARD_KEY_time;
.float br_last_LEFT_KEY_time;
.float br_last_RIGHT_KEY_time;

// these store the movement direction at the time of the brawl action happening.
.float brawling_direction_x;
.float brawling_direction_y;

// this indicates the last time a brawl was executed. used to check if another one is allowed
// and to ramp up the brawl acceleration in the physics hook.
.float br_last_brawling_time;

// set to 1 to indicate brawling has started.. reset by physics hook after brawl has been done..
.float brawling_action;

// the jump part of the brawl cannot be ramped
.float brawling_single_action;

void brawling_Initialize() {
	// print("brawling_Initialize\n");

	self.br_last_FORWARD_KEY_time = 0;
	self.br_last_BACKWARD_KEY_time = 0;
	self.br_last_RIGHT_KEY_time = 0;
	self.br_last_LEFT_KEY_time = 0;
	self.br_last_brawling_time = 0;
	self.brawling_action = 0;
	self.brawling_single_action = 0;
	self.brawling_direction_x = 0;
	self.brawling_direction_y = 0;
}

// returns entity if the player is close to an entity
entity check_close_to_player(float threshold) {
	vector trace_start;
	vector trace_end;
	float is_player;

	trace_start = self.origin;

	if (self.brawling_direction_y > 0) {
		trace_end = self.origin + (1000*v_right);
	} else if (self.brawling_direction_y < 0) {
		trace_end = self.origin - (1000*v_right);
	} else {
		trace_end = self.origin + (1000*v_forward);
	}
	
	tracebox(trace_start, self.mins, self.maxs, trace_end, MOVE_NORMAL, self);
	
	is_player = isPlayerOrMonsterByClassname(trace_ent);
		
	//print(etos(trace_ent),"e \n");
	if (trace_fraction < 1 && is_player && vlen (self.origin - trace_endpos) < threshold)
		return trace_ent;

	return world;
}

vector brawling_evaluatevector(vector myforcevec, entity myplayertarget)
{
	if (cvar("sv_brawling_zprotect_disable")) {
		//Do nothing
	} else if (autocvar_sv_brawling_zprotect) {
		//print(vtos(myforcevec), "\n");
		//print(ftos(myforcevec_z), " Z\n");
		local float myvlen;
		
		//////We don't want uppercuts etc to be used to jump over tall walls...
		
		if (autocvar_sv_brawling_zprotect_ignorebelow) {
			local vector mytargvec;
			mytargvec = myplayertarget.origin;
			mytargvec_z = 512 + autocvar_sv_brawling_zprotect_ignorebelow;
		
			traceline(myplayertarget.origin, mytargvec, MOVE_NOMONSTERS, myplayertarget);
			myvlen = vlen(trace_endpos - myplayertarget.origin);
			
			//Collides with func_client_illu.. well ... can't win them all
			//print(vtos(myplayertarget.origin)," MORIG\n");
			//print(vtos(trace_endpos)," TEPOS\n");
			//print(ftos(myplayertarget.origin_z)," Z1\n");
			//print(ftos(trace_endpos_z)," Z2\n");
			//print(ftos(myvlen)," myvlen\n");
		} else {
			myvlen = 0;
		}
		
		
		if (myvlen > autocvar_sv_brawling_zprotect_ignorebelow) {
			//Not inside (eg: spikerelmarena..), so we reduce
			//print("must reduce z perhaps\n");
			
			if (myforcevec_z > autocvar_sv_brawling_zprotect) {
				myforcevec_z = autocvar_sv_brawling_zprotect;
			}
		}
		
		//print(ftos(myforcevec_z), " NewZ\n");
	}
	return myforcevec;
} 

void brawling_attack(entity player)
{
		local entity pktarget;
		local float dx, fx, vx, km; //Damage multiple, force multiple, vector multiple, kickmultiplier
		pktarget = check_close_to_player(autocvar_sv_brawling_distance_threshold);
		if (pktarget != world) {
			//print(etos(pktarget),"pktgt\n");
			//print(ftos(player.sex)," sex\n");
			//print(ftos(player.species)," species\n");
			
			km = 1;
			if (player.sex == SEX_MALE) {
				dx = 1;
				fx = 1;
				vx = 0.125;
			} else if (player.sex == SEX_FEMALE) {
				dx = 0.5;
				fx = 0.5;
				vx = 0.0625;
			} else if (player.sex == SEX_HERMAPHRODITE) {
				dx = 1;
				fx = 1;
				vx = 0.115;
			} else if (player.sex == SEX_EUNICH) {
				dx = 1;
				fx = 1;
				vx = 0.116;
			} else {
				dx = 1;
				fx = 1;
				vx = 0.125;
			}
			
			if (player.species == SPECIES_HUMAN || player.species == SPECIES_FAE) {
				if (player.sex == SEX_FEMALE)
					km = 1.25;
					//To bring up lower body strenght to 0.62
			} else if (player.species == SPECIES_ALIEN) {
				dx = dx * 0.90;
				fx = fx * 0.90;
				vx = vx * 0.90;
			} else if (player.species == SPECIES_ANIMAL) {
				dx = dx * 1.25;
				fx = fx * 1.25;
				vx = vx * 0.80;
			} else if (player.species == SPECIES_ROBOT_SOLID) {
				vx = vx * 1.25;
			} else if (player.species == SPECIES_ROBOT_SHINY) {
				dx = dx * 0.85;
				fx = fx * 0.85;
				vx = vx * 0.5;
			} else if (player.species == SPECIES_ROBOT_RUSTY) {
				dx = dx * 1.10;
				fx = fx * 0.85;
				vx = vx * 0.5;
			}
			
			if (player.drunken > 4)
			{
				dx = 1.2;
			}
			else if (player.drunken > 1.75)
			{
				dx = 1.1;
			} 
			
			fx = fx * autocvar_sv_brawling_forcemulti; //Allow to set pushback
			
			//print(ftos(dx), " Damage X   ", ftos(fx), " Force X   ", ftos(vx), " Vector X   ", ftos(km), " KickMultiplier\n");
			
			if (player.flags & FL_ONGROUND) {
				if (player.brawling_direction_y > 0)
					Damage (pktarget, player, player, 0.5 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector(v_right*150*fx, pktarget));
				else if (player.brawling_direction_y < 0)
					Damage (pktarget, player, player, 0.5 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector(v_right*-150*fx, pktarget));
				else {
					if (player.crouch)
						Damage (pktarget, player, player, 1.5 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector((v_forward*25*fx)+'0 0 50'+(player.velocity*vx), pktarget));
					else
						Damage (pktarget, player, player, 1 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector((v_forward*300*fx)+(player.velocity*vx), pktarget));
				}
				//print("ground\n");
			} else {
				dx = dx * km;
				fx = fx * km;
				vx = fx * km;
				
				if (player.brawling_direction_y > 0)
					Damage (pktarget, player, player, 1.5 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector(v_right*212*fx, pktarget));
				else if (player.brawling_direction_y < 0)
					Damage (pktarget, player, player, 1.5 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector(v_right*-212*fx, pktarget));
				else {
					if (player.crouch)
						Damage (pktarget, player, player, 3 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector((v_forward*50*fx)+'0 0 100'+(player.velocity*vx), pktarget));
					else
						Damage (pktarget, player, player, 2 * dx, DEATH_BEATDOWN, pktarget.origin, brawling_evaluatevector((v_forward*425*fx)+(player.velocity*vx), pktarget));
				}
				//print("air\n");
			}
		}	
}

float brawling_delay (entity player)
{
	local float brawl_delay_multiple; //More is worse
	// first check if the last brawl is far enough back in time so we can brawl again
	if (player.species == SPECIES_HUMAN || player.species == SPECIES_FAE)
	{
				if (player.sex == SEX_FEMALE)
					brawl_delay_multiple = 1.05; //Human female creature (slower)
				else if (player.sex == SEX_EUNICH)
					brawl_delay_multiple = 1.25;
				else
					brawl_delay_multiple = 1;
	}
	else if (player.species == SPECIES_ALIEN)
	{
		brawl_delay_multiple = 0.8; //Svelt
	}
	else if (player.species == SPECIES_ANIMAL)
	{
		brawl_delay_multiple = 0.75; //Viscious brutal animal
	}
	else if (player.species == SPECIES_ROBOT_SOLID)
	{
		brawl_delay_multiple = 1.25; //Big, heavy
	}
	else if (player.species == SPECIES_ROBOT_SHINY)
	{
		brawl_delay_multiple = 1.01;			
	}
	else if (player.species == SPECIES_ROBOT_RUSTY)
	{
		brawl_delay_multiple = 1.5; //Rusty, hard to move		
	}
	else
	{
		brawl_delay_multiple = 1;
	}
	
	return brawl_delay_multiple;
}

MUTATOR_HOOKFUNCTION(brawling_GetCvars) {
	GetCvars_handleFloat(get_cvars_s, get_cvars_f, cvar_cl_brawling_timeout, "cl_brawling_timeout");
	return 0;
}

MUTATOR_HOOKFUNCTION(brawling_PlayerPhysics) {
	// print("brawling_PlayerPhysics\n");

	float common_factor;
	float velocity_difference;
	float clean_up_and_do_nothing;

    if (self.deadflag != DEAD_NO)
        return 0;

	clean_up_and_do_nothing = 0;

	if (g_brawling == 0)
		clean_up_and_do_nothing = 1;

	// when swimming, no brawling allowed..
	if (self.waterlevel >= WATERLEVEL_SWIMMING)
		clean_up_and_do_nothing = 1;

	if (clean_up_and_do_nothing != 0) {
		self.brawling_action = 0;
		self.brawling_direction_x = 0;
		self.brawling_direction_y = 0;
		return 0;
	}

	// make sure v_up, v_right and v_forward are sane
	makevectors(self.angles);

	//punch/push/kick
	if (self.brawling_action == 1) {
		brawling_attack(self);
	}

	// the up part of the brawl is a single shot action
	if (self.brawling_single_action == 1) {
		//animdecide_setaction(self, ANIMACTION_JUMP, TRUE); //For other branch
		setanim(self, self.anim_jump, TRUE, FALSE, TRUE);

		self.brawling_single_action = 0;
	}

	// are we done with the brawling ramp yet?
	if((self.brawling_action == 1) && ((time - self.br_last_brawling_time) > autocvar_sv_brawling_ramp_time))
	{
		// reset state so next brawl can be done correctly
		self.brawling_action = 0;
		self.brawling_direction_x = 0;
		self.brawling_direction_y = 0;
	}

	return 0;
}

MUTATOR_HOOKFUNCTION(brawling_GetPressedKeys) {
	// print("brawling_PlayerPhysics\n");
	local float brawl_delay_multiple; //More is worse
	float length;
	float tap_direction_x;
	float tap_direction_y;

	tap_direction_x = 0;
	tap_direction_y = 0;

	float brawl_detected;
	if (g_brawling == 0)
		return 0;

	brawl_detected = 0;

	brawl_delay_multiple = brawling_delay(self);
	
	if ((time - self.br_last_brawling_time) < (autocvar_sv_brawling_delay * brawl_delay_multiple))
		return 0;

	if (self.movement_x > 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_FORWARD)) {
			if ((time - self.br_last_FORWARD_KEY_time) < self.cvar_cl_brawling_timeout)	{ 
				tap_direction_x = 1.0;
				brawl_detected = 1;
			}
 			self.br_last_FORWARD_KEY_time = time;
 		}
	}

	if (self.movement_x < 0) {
		// is this a state change?
 		if (!(self.pressedkeys & KEY_BACKWARD)) {
			tap_direction_x = -1.0;
			if ((time - self.br_last_BACKWARD_KEY_time) < self.cvar_cl_brawling_timeout)	{ 
				brawl_detected = 1;
			}
 			self.br_last_BACKWARD_KEY_time = time;
 		}
	}

	if (self.movement_y > 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_RIGHT)) {
			tap_direction_y = 1.0;
			if ((time - self.br_last_RIGHT_KEY_time) < self.cvar_cl_brawling_timeout)	{ 
				brawl_detected = 1;
			}
 			self.br_last_RIGHT_KEY_time = time;
 		}
	}

	if (self.movement_y < 0) {
		// is this a state change?
		if (!(self.pressedkeys & KEY_LEFT)) {
			tap_direction_y = -1.0;
			if ((time - self.br_last_LEFT_KEY_time) < self.cvar_cl_brawling_timeout)	{ 
				brawl_detected = 1;
			}
 			self.br_last_LEFT_KEY_time = time;
 		}
	}

	if (brawl_detected == 1) {
		self.br_last_brawling_time = time;

		self.brawling_action = 1;
		self.brawling_single_action = 1;

		self.brawling_direction_x = tap_direction_x;
		self.brawling_direction_y = tap_direction_y;

		// normalize the brawling_direction vector.. (unlike UT99) XD
		length =          self.brawling_direction_x * self.brawling_direction_x;
		length = length + self.brawling_direction_y * self.brawling_direction_y;
		length = sqrt(length);

		self.brawling_direction_x = self.brawling_direction_x * 1.0/length;
		self.brawling_direction_y = self.brawling_direction_y * 1.0/length;
	}

	return 0;
}

MUTATOR_DEFINITION(mutator_brawling)
{
	// we need to be called before GetPressedKey does its thing so we can
	// detect state changes and therefore brawling actions..
	MUTATOR_HOOK(GetPressedKeys, brawling_GetPressedKeys, CBC_ORDER_ANY);

	// in the physics hook we actually implement the brawl..
	MUTATOR_HOOK(PlayerPhysics, brawling_PlayerPhysics, CBC_ORDER_ANY);

	// get timeout information from the client, so the client can configure it..
	MUTATOR_HOOK(GetCvars, brawling_GetCvars, CBC_ORDER_ANY);

	// this just turns on the cvar.
	MUTATOR_ONADD
	{
		g_brawling = 1;
		brawling_Initialize();
	}

	// this just turns off the cvar.
	MUTATOR_ONREMOVE
	{	 
		g_brawling = 0;
	}

	return 0;
}
