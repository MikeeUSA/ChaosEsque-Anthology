#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TORCH, w_torch, IT_NAILS, 3, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "torch", "torch", _("Torch"))
#else
#ifdef SVQC
.float torch_lit;
.float torch_release;
.float torch_secondary;
.entity torchlight;
.entity torchlightforwarpzone;

.float swing_prev;
.entity swing_alreadyhit;

void torch_thinklight() {
	if (self.owner.torch_lit == 1 && self.torch_lit == 1 && self.owner.health > 0) {
		//Here we set where this light is going to emit from:
		//Above and forward of the player abit.
		//We make sure we don't put the light in a soid below
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *48)+(v_up *16));
		
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *16));
		  //print("1\n");
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	//print("2\n");
			vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *16));
		  	if (pointcontents (vlporigin) == CONTENT_SOLID) {
				//print("3\n");
				vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *16));
		  	}
		  }
		}
		
		setorigin(self, vlporigin);
		
		//Old way:
		//makevectors(self.owner.v_angle);
		//setorigin(self, ((self.owner.origin + self.owner.view_ofs)+(v_forward *56)+(v_up *16)));
		
		////Oldest way:
		////setorigin(self, self.owner.origin);
		
		self.nextthink = time;
		self.torch_lit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

.float flashlight_lit;
.entity subordinate10; //Here we are using it to store the REAL .torchlight
void torch_thinklightforwarpzone() {

	if (autocvar_g_balance_torch_maxlighttraces_enable && self.subordinate10 && self.owner) {
		if (
		 ( ((self.ammount5 == 0) && self.owner.torch_lit == 1)
		 || ((self.ammount5 == 1) && self.owner.flashlight_lit == 1) )
		 && self.owner.health > 0
		 && (self.owner.weapon == self.weapon || (self.ammount5 == 1))
		 ) {
		 	//Note: flashlight stays on even when not in hand.
			local vector targpos;
			
			local float mycount;
			local float mycountmax;
			local float myrealcount;
			local float mytracedistance;
			local float mymaxtraces;
			local float mytracemulip;
			float torchhasallreadyfoundwarpzone;
			
			if (self.ammount5 == 1) {
				//The utilize warpzone code attempt didn't quite work
				//The goal was to use the same exact light setting as the "real" light
				//It sorta worked at first, but problems arose...
				//The light would only shine in the other area
				//if you were quite near the warp zone
				//Sometimes it would flicker
				//Sometimes it would show up from a farther distance, but only after a second or two.
				//////For using:Warpzone code attempt 
				//////mymaxtraces = 5;
				
				//KISS:
				
				//mymaxtraces = 1; //Flashlight, one trace ...
				////too pinpoint, wouldn't be in both the foreground and background,
				////was one or the other, so doing the middle plus 4 points trace instead
				////(one thing that's similar with the other attempt...)
				
				mymaxtraces = autocvar_g_balance_flashlight_maxlighttraces;
				
				if (mymaxtraces > 9) {
					mymaxtraces = 9; //Was 5 before...
				}
				
				if (autocvar_g_balance_flashlight_maxlighttracesnomorethanfwd) {
					if (mymaxtraces > autocvar_g_balance_torch_maxlighttraces) {
						mymaxtraces = autocvar_g_balance_torch_maxlighttraces;
					}
				}
			} else {
				mymaxtraces = autocvar_g_balance_torch_maxlighttraces;
				
				if (mymaxtraces > 12) {
					mymaxtraces = 12;
				}
			}
			
			mytracedistance = self.subordinate10.ammount7;
			mytracemulip = 1;
			mycountmax = autocvar_g_balance_torch_maxlighttraces + autocvar_g_balance_torch_maxlighttracesback;
			if (mycountmax > 21) { mycountmax = 21; }
			myrealcount = 0;
				
			makevectors(self.owner.v_angle);
			
			torchhasallreadyfoundwarpzone = 0;
			mycount = 0;
			
			if (autocvar_g_balance_torch_maxlighttracestime) {
				if (time > self.ammount4) {
					//update;
					self.origin = self.subordinate10.origin;
					self.ammount4 = time + autocvar_g_balance_torch_maxlighttracestime;
				} else {
					//Don't update
					mycount = 10000;
				}
			} else {
				self.origin = self.subordinate10.origin;
			}
			
			//print("\n\n\n\n\nBeginTraces\n");
			
			while (mycount < 12 && mycount < mymaxtraces && myrealcount < mycountmax) {
				//one above themaxmycount
				//////////////////////////
				//////////////////////////
				
				//print("doing traces", vtos(self.origin), etos(self.owner), etos(self.subordinate10), " time:",  ftos(time),  "\n");
				
				local vector mytrceorigin;
				local vector mytrceorigin2;
				mytrceorigin = self.subordinate10.origin; //For finding targpos
				
				if (mytracemulip == -1) {
					//print(etos(self.owner)," myowner \n");
					mytrceorigin2 = self.owner.origin + self.owner.view_ofs; //For trace backwards
					////mytrceorigin = mytrceorigin2;
				} else {
					mytrceorigin2 = mytrceorigin; //For actual trace
				}
				
				if (torchhasallreadyfoundwarpzone) {
					//print("no need\n");
					mycount = 10000; //Could break here..
				} else {
					if (mycount == 1) {
						//print("1 up forward\n");
						//torchlightforwarpzoneupforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_up * self.subordinate10.ammount2));
					} else if (mycount == 2) {
						//print("2 down forward\n");
						//torchlightforwarpzonedownforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_up * self.subordinate10.ammount2 * -1));
					} else if (mycount == 3) {
						//print("3 right forward\n");
						//torchlightforwarpzonerightforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_right * self.subordinate10.ammount2));
					} else if (mycount == 4) {
						//print("4 left forward\n");
						//torchlightforwarpzoneleftforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_right * self.subordinate10.ammount2 * -1));
						
					//Nothing found?, try more extreme angles
					//First R and L
					} else if (mycount == 5) {
						//print("5 rf\n");
						//torchlightforwarpzonerightforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_right * self.subordinate10.ammount2 * 3));
					} else if (mycount == 6) {
						//print("6 lf\n");
						//torchlightforwarpzoneleftforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_right * self.subordinate10.ammount2 * -3));
					//Then up, down
					} else if (mycount == 7) {
						//print("7 uf\n");
						//torchlightforwarpzoneupforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_up * self.subordinate10.ammount2 * 3));
					} else if (mycount == 8) {
						//print("8 df\n");
						//torchlightforwarpzonedownforward
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance)
						+ (v_up * self.subordinate10.ammount2 * -3));
				
					////side to side direct
					////First R and L
					} else if (mycount == 9) {
						//print("9 right\n");
						//torchlightforwarpzoneright
						targpos = ((mytrceorigin) + (v_right * mytracemulip * mytracedistance));
					} else if (mycount == 10) {
						//print("10 left\n");
						//torchlightforwarpzoneleft
						targpos = ((mytrceorigin) + (v_right * mytracemulip * mytracedistance * -1));
				
					//Up/down direct
					} else if (mycount == 11) {
						//print("11 up\n");
						//torchlightforwarpzoneup
						targpos = ((mytrceorigin) + (v_up * mytracemulip * mytracedistance));
					//////} else if (mycount == 12) {
					//////	//print("12 down\n");
					//////	//torchlightforwarpzonedown
					//////	targpos = ((mytrceorigin) + (v_up * mytracemulip * mytracedistance * -1));
				
				
					//First is forward
					} else {
						//print("0 forward\n");
						targpos = ((mytrceorigin) + (v_forward * mytracemulip * mytracedistance));
					}
				
					//WarpZone_traceline_antilag(self, mytrceorigin, targpos, FALSE, self, ANTILAG_LATENCY(self.owner));
					WarpZone_traceline_antilag(self, mytrceorigin2, targpos, TRUE, self, ANTILAG_LATENCY(self.owner));
				
					if (trace_fraction) {
						if (WarpZone_trace_firstzone == world) {
							self.light_lev = 0;
							//print("  no zoned:", ftos(trace_fraction),"\n");
		
							self.origin = self.subordinate10.origin;
						} else if (WarpZone_trace_firstzone) {
							self.origin = trace_endpos;
					
							self.light_lev = self.ammount3;
					
							torchhasallreadyfoundwarpzone = 1;
							
							if (self.ammount5 == 1) {
								//This didn't quite work
								//The goal was to use the same exact light setting as the "real" light
								//It sorta worked at first, but problems arose...
								//The light would only shine in the other area
								//if you were quite near the warp zone
								//Sometimes it would flicker
								//Sometimes it would show up from a farther distance, but only after a second or two.
								////
								//////For using:Warpzone code attempt 
								////////////traceline(self.subordinate10.origin, targpos, MOVE_WORLDONLY, self);
								////////////self.origin = trace_endpos;
								//////////////Above: an attempt to place the origin in the entrance warpzone before doing the transforms
								//////
								//////self.color = self.subordinate10.color;
								//////
								//////self.angles = WarpZone_TransformAngles(WarpZone_trace_firstzone, self.subordinate10.angles);
								//////self.origin = WarpZone_TransformOrigin(WarpZone_trace_firstzone, self.subordinate10.origin);
								////// First zone sorta worked, but the above problems occured
								//////
								////////self.angles = WarpZone_TransformAngles(WarpZone_trace_lastzone, self.subordinate10.angles);
								////////self.origin = WarpZone_TransformOrigin(WarpZone_trace_lastzone, self.subordinate10.origin);
								////////last zone wasn't much better
								//////print(vtos(self.origin), vtos(self.angles), " wz o ", vtos(WarpZone_trace_firstzone.origin), " wz o2 ", vtos(WarpZone_trace_lastzone.origin), etos(WarpZone_trace_lastzone), "\n");
								////
								
								//Ohwell, KISS:
								
								self.color = self.subordinate10.color;

							}
						} else {
							self.light_lev = 0;
							//print("  no zoned2:", ftos(trace_fraction),"\n");
	
							self.origin = self.subordinate10.origin;
						}
					} else {
						self.light_lev = 0;
						//print("  tracefraction:", ftos(trace_fraction),"\n");
	
						self.origin = self.subordinate10.origin;
					}
				}
				
			
				mycount = mycount + 1;
				//////////////////////////
				//////////////////////////
				
				if (self.ammount5 == 1) {
					//Flashlight, does not trace back;
				} else if (mytracemulip == -1) {
					//Traceback set allready
					//print("Traceback\n");
				} else if (autocvar_g_balance_torch_maxlighttracesback) {
					if (torchhasallreadyfoundwarpzone) {
						//Do nothing
					} else if (mycount < 12 && mycount < autocvar_g_balance_torch_maxlighttraces) {
						//Do nothing
					} else {
						//print("\n\n\nFound nothing, Redoing back too\n");
						mycount = 0;
						mymaxtraces = autocvar_g_balance_torch_maxlighttracesback;
						
						if (autocvar_g_balance_torch_maxlighttracesbacknomorethanfwd) {
							if (mymaxtraces > autocvar_g_balance_torch_maxlighttraces) {
								//print("HERE\n!!!!!");
								mymaxtraces = autocvar_g_balance_torch_maxlighttraces;
							}
						}
						
						if (mymaxtraces > 9) {
							//Greater than 9 is pointless as it is perpendicular, 
							//(Up, down, right, left)
							//equal to traces you allready did.
							mymaxtraces = 9;
						}
						mytracemulip = -1;
						
						//print("Doing\n!!!!!");
					}
				}
				
				myrealcount = myrealcount + 1;
			}
			
			setorigin(self, self.origin);
			
			self.nextthink = time;
		} else {
			self.light_lev = 0;
			remove(self);
		}
	} else {
		self.light_lev = 0;
		remove(self);
	}
}


.entity flashlightlightforwarpzone;
void ExtinguishTorchlightForWarpzone(entity myplyr)
{
	if (myplyr.torchlightforwarpzone) {
	  if (myplyr.torchlightforwarpzone != world) { //Yes, redundant
	    if (myplyr.torchlightforwarpzone.owner == myplyr) {
	      //print("Removing torchlight for warpzone\n");
	      myplyr.torchlightforwarpzone.light_lev = 0;
	      remove(myplyr.torchlightforwarpzone);
	    }
	  }
	}
}



entity torch_spawnlightforwarpzone(entity myotherlight, float mystyle, float myskin, float mylightlev, float mytypeoflight) {
	local entity newtorchlightforwarpzone;
	newtorchlightforwarpzone = spawn();
	newtorchlightforwarpzone.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlightforwarpzone.light_lev = 0;
	newtorchlightforwarpzone.ammount3 = mylightlev; //128;
	newtorchlightforwarpzone.color = myotherlight.color;
	newtorchlightforwarpzone.skin = myskin;
	newtorchlightforwarpzone.style = mystyle;
	newtorchlightforwarpzone.owner = myotherlight.owner;
	newtorchlightforwarpzone.think = torch_thinklightforwarpzone;
	newtorchlightforwarpzone.nextthink = time;
	newtorchlightforwarpzone.ammount5 = mytypeoflight; //0 torch, 1 flashlight, etc;
	//newtorchlightforwarpzone.torch_lit = 1;
	return newtorchlightforwarpzone;
}

void torch_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 256;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = torch_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.torch_lit = 1;
	self.torchlight = newtorchlight;
	if(!warpzone_warpzones_exist) {
		//Do nothing
	} else {
		if (autocvar_g_balance_torch_maxlighttraces_enable) {
			self.torchlight.ammount7 = 160; //how far //192 is fairly good //128 not enough
			self.torchlight.ammount2 = 45; //Deviation from center;
			self.torchlightforwarpzone = torch_spawnlightforwarpzone(newtorchlight, newtorchlight.style, newtorchlight.skin, 128, 0);
			self.torchlightforwarpzone.subordinate10 = newtorchlight; //The "real" torchlight
			self.torchlightforwarpzone.weapon = WEP_TORCH;
		}
	}

}

////////////////////
//These are for when a lit torch is thrown, so a light follows it
//(if autocvar_g_balance_torch_allowthrownlight is enabled)
//see: cl_weapons.qc W_ThrowNewWeapon for where the light spawning is called

void torch_thrown_thinklight() {
	local float myreqmet;
	myreqmet = 0;
	
	if (autocvar_g_balance_torch_allowthrownlight_quickextinguish) {
		if (self.owner) { // && self.owner.classname == "droppedweapon") {
			if (self.owner.origin_x
			|| self.owner.origin_y
			|| self.owner.origin_z) { 
				if (random() > (0.01 * autocvar_g_balance_torch_allowthrownlight_quickextinguish)) {
					//light stays on
					myreqmet = 1;
				}
			}
		}
	} else {
		//Exists if torch exists
		if (self.owner) {
			if (self.owner.origin_x
			|| self.owner.origin_y
			|| self.owner.origin_z) {
				myreqmet = 1;
			}
		}
	}
	
	if (myreqmet) {
		//Here we set where this light is going to emit from:
		//Above and forward of the player abit.
		//We make sure we don't put the light in a soid below
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *16));
		
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *16));
		  //print("1\n");
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	//print("2\n");
			vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *8)+(v_up *16));
		  	if (pointcontents (vlporigin) == CONTENT_SOLID) {
				//print("3\n");
				vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *16));
		  	}
		  }
		}
		
		setorigin(self, vlporigin);
		
		//Old way:
		//makevectors(self.owner.v_angle);
		//setorigin(self, ((self.owner.origin + self.owner.view_ofs)+(v_forward *56)+(v_up *16)));
		
		////Oldest way:
		////setorigin(self, self.owner.origin);
		
		
		local float mytestconts;
		local float mytestconts2;
		mytestconts = pointcontents (vlporigin);
		mytestconts2 = pointcontents (self.owner.origin);
		
		//If we are in water or slime, extinguish
		if (mytestconts == CONTENT_WATER
		|| mytestconts2 == CONTENT_WATER
		|| mytestconts == CONTENT_SLIME
		|| mytestconts2 == CONTENT_SLIME) {
			pointparticles(particleeffectnum("smoke_big"), vlporigin, '0 0 30', 10);
			spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);		
			
			//print("extinguished\n");
			remove(self);
		} else {
			self.nextthink = time;
		
			if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
				if (OilFire_explosion_spawnoilburnermaybe(self)) {
					if (random() < autocvar_g_balance_torch_allowthrownlight_expextinguishrate) {
						//We go out
						//Note also tried changing the owner.model
						//back to the unlit torch
						//and doing an TNSF_FULLUPDATE, but that didn't work easily
						//since the owner is a client side entity
						
						remove(self);
					}
				}
			}
		}
	} else {
		//print("no more owner\n");
		remove(self);
	}
}

void torch_thrown_spawnlight(entity myowner) {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 256;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = myowner;
	newtorchlight.think = torch_thrown_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.torch_lit = 1;
}

////////////////////


void torch_meleethink (float wmelee_time, float wmelee_range, float wprimary_damage, float wmelee_nonplayerdamage)
{
	// declarations
	float i, f, swing, swing_factor, swing_damage, meleetime, is_player;
	entity target_victim;
	vector targpos;

	if(!self.cnt) // set start time of melee
	{
		self.cnt = time; 
		W_PlayStrengthSound(self.realowner);
	}

	makevectors(self.realowner.v_angle); // update values for v_* vectors
	
	// calculate swing percentage based on time
	meleetime = wmelee_time * W_WeaponRateFactor();
	swing = bound(0, (self.cnt + meleetime - time) / meleetime, 10);
	f = ((1 - swing) * autocvar_g_balance_torch_primary_melee_traces);
	
	// check to see if we can still continue, otherwise give up now
	if((self.realowner.deadflag != DEAD_NO) && autocvar_g_balance_torch_primary_melee_no_doubleslap)
	{
		remove(self);
		return;
	}
	
	// if okay, perform the traces needed for this frame 
	for(i=self.swing_prev; i < f; ++i)
	{
		swing_factor = ((1 - (i / autocvar_g_balance_torch_primary_melee_traces)) * 2 - 1);
		
		targpos = (self.realowner.origin + self.realowner.view_ofs 
			+ (v_forward * wmelee_range)
			+ (v_up * swing_factor * autocvar_g_balance_torch_primary_melee_swing_up)
			+ (v_right * swing_factor * autocvar_g_balance_torch_primary_melee_swing_side));

		WarpZone_traceline_antilag(self, self.realowner.origin + self.realowner.view_ofs, targpos, FALSE, self, ANTILAG_LATENCY(self.realowner));
		
		// draw lightning beams for debugging
		//te_lightning2(world, targpos, self.realowner.origin + self.realowner.view_ofs + v_forward * 5 - v_up * 5); 
		//te_customflash(targpos, 40,  2, '1 1 1');
		
		is_player = isPlayerOrMonsterByClassname(trace_ent);

		if (is_player)
		{
			if (melee_check_collision(self.realowner, trace_ent))
			{
				if(trace_ent.melee_temp && !self.meleeotherpassesthrough) remove(trace_ent.melee_temp);
				remove(self);
				return;	
			}
		}

		if (trace_fraction < 1) { // if trace is good, apply the damage and remove self
		  if((trace_ent.takedamage == DAMAGE_AIM) //Player or some entity that can be damaged
			&& (trace_ent != self.swing_alreadyhit)
			&& (is_player || wmelee_nonplayerdamage))
		  {
			target_victim = trace_ent; // so it persists through other calls
			
			if(is_player) // this allows us to be able to nerf the non-player damage done in e.g. assault or onslaught.
				swing_damage = (wprimary_damage * min(1, swing_factor + 1));
			else
				swing_damage = (wmelee_nonplayerdamage * min(1, swing_factor + 1));
			
			//print(strcat(self.realowner.netname, " hitting ", target_victim.netname, " with ", strcat(ftos(swing_damage), " damage (factor: ", ftos(swing_factor), ") at "), ftos(time), " seconds.\n"));
			
			if (is_player) {
				swing_damage = W_CritHitCalc_Blunt(swing_damage, self.realowner.origin + self.realowner.view_ofs, targpos, target_victim, self.realowner, WEP_TORCH);
			}
			
			Damage(target_victim, self.realowner, self.realowner, 
				swing_damage, WEP_TORCH, 
				self.realowner.origin + self.realowner.view_ofs, 
				v_forward * autocvar_g_balance_torch_primary_force);
				
			if (self.realowner.torch_lit) {
				Fire_AddDamage(target_victim, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, WEP_TORCH | HITTYPE_SECONDARY);
			}
				
			if(accuracy_isgooddamage(self.realowner, target_victim)) { accuracy_add(self.realowner, WEP_TORCH, 0, swing_damage); }
				
			// draw large red flash for debugging
			//te_customflash(targpos, 200, 2, '15 0 0');
			
			if(autocvar_g_balance_torch_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		  } else if ((self.realowner.torch_lit) //Burn non players.
			&& (trace_ent != self.swing_alreadyhit)
			&& (trace_ent != world))
		  {	
			target_victim = trace_ent; // so it persists through other calls
			
			float hitmaterial;
			float t;
			float d;
			hitmaterial = W_EvaluateMaterialHit();
			//// What materials should we burn
			if ((hitmaterial == 1) || (hitmaterial == 2)) {
				//print("Metal\n");
				
				//Do nothing
			} else {
				if (hitmaterial == 5) {
					//print("Concrete\n");
					d = autocvar_g_balance_torch_fire_damage * 0.05;
					t = autocvar_g_balance_torch_fire_burntime * 0.05;
				} else if ((hitmaterial == 3) || (hitmaterial == 4)) {
					//print("Stone and Brick\n");
					d = autocvar_g_balance_torch_fire_damage * 0.1;
					t = autocvar_g_balance_torch_fire_burntime * 0.1;
				} else if (hitmaterial == 8) {
					//print("Wood and Bark\n");
					d = autocvar_g_balance_torch_fire_damage * 2;
					t = autocvar_g_balance_torch_fire_burntime * 2;
				} else if (hitmaterial == 7) {
					//print("Dirt Etc\n");
					d = autocvar_g_balance_torch_fire_damage * 0.12;
					t = autocvar_g_balance_torch_fire_burntime * 0.12;
				} else if (hitmaterial == 9) {
					//print("Sheetrock\n");
					d = autocvar_g_balance_torch_fire_damage * 0.25;
					t = autocvar_g_balance_torch_fire_burntime * 0.25;
				} else {
					//print("NotMetal\n");
					d = autocvar_g_balance_torch_fire_damage;
					t = autocvar_g_balance_torch_fire_burntime;
				}
				
				Fire_AddDamage(target_victim, self.realowner, d * t, t, WEP_TORCH | HITTYPE_SECONDARY);
			}
			
			if(autocvar_g_balance_torch_primary_melee_multihit) // allow multiple hits with one swing, but not against the same player twice.
			{
				self.swing_alreadyhit = target_victim;
				continue; // move along to next trace
			}
			else
			{
				remove(self);
				return;
			}
		  }
		}
	}
	
	if(time >= self.cnt + meleetime)
	{
		// melee is finished
		remove(self);
		return;
	}
	else
	{
		// set up next frame 
		self.swing_prev = i;
		self.nextthink = time;
	}
}

void torch_primarythink (void)
{
	torch_meleethink(
		autocvar_g_balance_torch_primary_melee_time,
		autocvar_g_balance_torch_primary_melee_range,
		autocvar_g_balance_torch_primary_damage,
		autocvar_g_balance_torch_primary_melee_nonplayerdamage
		);
}

void torch_secondarythink (void)
{
	torch_meleethink(
		autocvar_g_balance_torch_secondary_melee_time,
		autocvar_g_balance_torch_secondary_melee_range,
		autocvar_g_balance_torch_secondary_damage,
		autocvar_g_balance_torch_secondary_melee_nonplayerdamage
		);
}

void W_Torch_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/torch_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.torch_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_torch_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_torch_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn(); meleetemp.meleeotherpassesthrough = 0;
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 3;
	
	if(self.torch_secondary == 1) {
		self.melee_temp_starttime = time + autocvar_g_balance_torch_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_torch_secondary_melee_time;
	   meleetemp.think = torch_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_torch_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_torch_secondary_damage, autocvar_g_balance_torch_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_torch_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_torch_primary_melee_time;
	   meleetemp.think = torch_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_torch_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_torch_primary_damage, autocvar_g_balance_torch_primary_melee_range);
	}
}


void spawnfunc_weapon_torch (void)
{
	weapon_defaultspawnfunc(WEP_TORCH);
}

void w_torch_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.torch_lit) {	
		if (autocvar_g_balance_torch_allowthrownlight) {
			local float myclienttype;
			myclienttype = clienttype(player);
			
			if (myclienttype == CLIENTTYPE_REAL
			|| myclienttype == CLIENTTYPE_BOT)
			{
				myself.model = "models/weapons/g_torch_lit.md3";	
			}
		}
	}
}

.float torch_primarytime;

float w_torch(float req)
{
	if (req == WR_AIM) {
		if ((!self.torch_lit)
		&& (!((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2))
		&& self.bot_aggresskill > 0.75) {
			//We're a bot with an unlit torch and not underwater, better light it up if we're even abit aggressive
			weapon_action(self.weapon, WR_RELOAD);
		} else {
		 	if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_torch_primary_melee_range)
			&& (self.torch_release)) {
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			}
			else
			{
				self.BUTTON_ATCK=FALSE;
			}
		}
	}
	else if (req == WR_THINK)
	{
		//if (!self.crouch) // we are not currently crouching; this fixes an exploit where your melee anim is not visible, and besides wouldn't make much sense
		if (self.BUTTON_ATCK)
		if (self.torch_release)
		if (weapon_prepareattack(1, autocvar_g_balance_torch_primary_refire))
		{
			self.torch_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Torch_Attack);
			self.torch_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.torch_release)
		if (weapon_prepareattack(1, autocvar_g_balance_torch_secondary_refire))
		{
			self.torch_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Torch_Attack);
			self.torch_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.torch_release = 1;
		}
		
		if (self.torch_lit) {
		if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
			pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
			spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);		
			self.torch_lit = 0;
			self.weaponname = "torch";
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your torch was extinguished\n");
			}
		} else {
			self.torchlight.torch_lit = 1;
		}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_torch.md3");
		precache_model ("models/weapons/g_torch_lit.md3"); //used for when throw burning torch
		precache_model ("models/weapons/v_torch.md3");
		precache_model ("models/weapons/h_torch.iqm");
		precache_model ("models/weapons/v_torch_lit.md3");
		precache_model ("models/weapons/h_torch_lit.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/torch_fire.wav");
		precache_sound ("weapons/torch_melee.wav");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_TORCH);
		self.current_ammo = ammo_none;
		self.torch_lit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if not(self.torch_lit) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_torch_reload_time, w_ready);
			self.torch_lit = 1;
			self.weaponname = "torch_lit";
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You lit the torch\n");
			}
			torch_spawnlight();
			
		} else {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_torch_reload_time, w_ready);
			self.torch_lit = 0;
			self.weaponname = "torch";
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "You extinguish the torch\n");
			}
		}

	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_torch(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if not(w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was beaten to death with %s's torch");
		} else {
			w_deathtypestring = _("%s was burned to death with %s's torch");
		}
	}
	return TRUE;
}
#endif
#endif
