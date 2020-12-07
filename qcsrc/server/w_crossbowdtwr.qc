#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CROSSBOWDTWR, w_crossbowdtwr, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE, BOT_PICKUP_RATING_MID, "crossbowdtwr", "crossbowdtwr", _("Crossbow"))
#else
#ifdef SVQC
.float cb_detonate_later;
.float cb_bouncecnt;
.float cb_release;
.float cb_reloaded_time;
.float cb_arrowlit;
.float cb_arrownextburn;

float autocvar_g_balance_crossbowdtwr_forceburningbolt; //If admin wishes to force (no choice for player) the bolts fired to be burning ones, say in night games

.entity crossbowlight;
.entity multitool_doorframeent; //Door frament, so we may find info when attacking built slab door

void crossbow_thinklight() {
	if (self.owner.cb_arrowlit == 1 && self.cb_arrowlit == 1 && self.owner.health > 0) {
		local vector vlporigin;
		makevectors(self.owner.v_angle);
		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *48)+(v_up *2));
		//Checks to make sure we don't put light inside a corner, so shadows won't be messed up
		if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *32)+(v_up *2));
		  if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  	vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_forward *16)+(v_up *2));
		  	if (pointcontents (vlporigin) == CONTENT_SOLID) {
		  		vlporigin = ((self.owner.origin + self.owner.view_ofs)+(v_up *2));
		    	}
		  }
		}
		setorigin(self, vlporigin);
		self.nextthink = time;
		self.cb_arrowlit = 0;
		if (random() < autocvar_g_spawnfoliagearound_oilfire_expl_torchrate) {
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		remove(self);
	}
}

void crossbow_spawnlight() {
	local entity newtorchlight;
	newtorchlight = spawn();
	newtorchlight.pflags = PFLAGS_FULLDYNAMIC;
	newtorchlight.light_lev = 64;
	newtorchlight.color = '0.75 0.25 0';
	//newtorchlight.skin = 2; //Projective texture cubemap#.tga
	newtorchlight.style = 0;
	newtorchlight.owner = self;
	newtorchlight.think = crossbow_thinklight;
	newtorchlight.nextthink = time;
	newtorchlight.cb_arrowlit = 1;
	self.crossbowlight = newtorchlight;
}


float W_CrossbowCanLightBolt (entity player, float srchradius)
{
	entity f;
	f = findradius(player.origin, srchradius);
  	while(f)
  	{
		if (f.fire_burner) {
			if (f.fire_burner.classname == "fireburner")
			{
				return 1;
			}
		} else if (f.classname == "func_pointparticles") {
			//In alot of maps, so you can set your arrows alight near these
			if (f.mdl == "torchflame"
			|| f.mdl == "torch_small"
			|| f.mdl == "flamethrower"
			|| f.mdl == "firefield"
			|| f.mdl == "TE_FLAMEJET"
			|| f.mdl == "EF_BIGFLAME"
			|| f.mdl == "EF_LARGEFLAME"
			|| f.mdl == "EF_HUGEFLAME"
			|| f.mdl == "EF_IMMENSEFLAME") {
				return 1;
			}
		} else if (f.canigniteflame) {
			//Forges can also be used to ignite flame
			return 1;
		}
		f = f.chain;
	}
	
	return 0;
}

float W_CrossbowCanLightBoltEx (entity player, float srchradius)
{
	//Here we do a radius search AND a traceline
	if (W_CrossbowCanLightBolt (player, srchradius)) {
		return 1;
	}
	
	local entity e;
	e = spawn();
	e.origin = player.origin;
	traceline(e.origin, e.origin + v_forward * srchradius, MOVE_NORMAL, e);
	remove(e);
	
	if (trace_ent) {
		if (trace_ent.canigniteflame) {
			return 1;
		}
	}
	
	return 0;
}

float W_CrossbowCanLightBoltExVec (entity player, float srchradius, vector myvector, vector myvangles)
{
	//Here we do a radius search AND a traceline
	if (W_CrossbowCanLightBolt (player, srchradius)) {
		return 1;
	}
	
		//print(vtos(myvangles),"\n");
	
	makevectors(myvangles);
	
	local entity e;
	e = spawn();
	e.origin = myvector;
	traceline(e.origin, e.origin + v_forward * srchradius, MOVE_NORMAL, e);
		
		//trailparticles(e, particleeffectnum("TR_NEXUIZPLASMA"), e.origin, trace_endpos);

	remove(e);
	
	if (trace_ent) {
		if (trace_ent.canigniteflame) {
			return 1;
		}
	}
	
	return 0;
}

void W_CrossbowAttachFlameToShotorg(float particleeffectnbr, vector offset)
{
	entity flash;
	flash = spawn();
	vector v;
					
	if(gettagindex(self.weaponentity, "shot"))
		v = gettaginfo(self.weaponentity, gettagindex(self.weaponentity, "shot"));
	else
		v = gettaginfo(self.weaponentity, gettagindex(self.weaponentity, "tag_shot"));
		
	if (self.shootfromside == 1) {
		makevectors(self.v_angle);
		offset = offset-(v_up*16); //For somereason offset badly, so fix
		
		v_x = v_x + offset_x;
		v_y = v_y + offset_y;
		v_z = v_z + offset_z;
		setorigin(flash, v);
	} else {
		//Normal
		v_x = v_x + offset_x;
		v_y = v_y + offset_y;
		v_z = v_z + offset_z;
		setorigin(flash, v);
	}

	pointparticles(particleeffectnbr, flash.origin, '0 0 0', 1);
	remove(flash);
}

void W_CrossbowBolt_Remove (void)
{
	remove (self);
}

void W_CrossbowBolt_Destroy (void)
{
	pointparticles(particleeffectnum("machinegun_impact"), self.origin, '0 0 0', 1);
	remove (self);
}

void W_CrossbowBolt_Explode (void)
{
	
	if (self.amnt == 7 || self.amnt == 8) {
		//Do nothing, feathers (spell)
	} else {
	  ////////
	  if(other.takedamage == DAMAGE_AIM)
		if(other.classname == "player")
			if(IsDifferentTeam(self.realowner, other))
				if(other.deadflag == DEAD_NO)
					if(IsFlying(other))
						AnnounceTo(self.realowner, "airshot");
	
	  ////////
	}

	//--//Moving below to hopefully not have stuck when player is dead
	//--//self.takedamage = DAMAGE_NO;
	//--//RadiusDamage (self, self.realowner, self.ammount, autocvar_g_balance_crossbowdtwr_primary_edgedamage, autocvar_g_balance_crossbowdtwr_primary_radius, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
	//--//self.takedamage = DAMAGE_YES;
		
	if(other.armorvalue > 50) {
		////Speed depends on how much armor the person has
		//self.velocity = self.velocity - trace_plane_normal * (self.velocity * trace_plane_normal) * 1.5;
		////Throw in a direction
		self.speed = (self.speed / (((self.cnt - time) * -2) + 0.1)) + 0.1; //As time goes on and bolt flies, force is lessened
		UpdateCSQCProjectile(self);
		if (self.amnt == 3 || self.amnt == 5 || self.amnt == 6) {
			//Burning type
			OilFire_explosion_spawnoilburnermaybe(self);
		}
	} else {
		entity crossbolthit;
		crossbolthit = spawn ();
		crossbolthit.owner = other; //Player it's stuck into owns.
		crossbolthit.cnt = self.cnt;
		crossbolthit.amnt = self.amnt;
		crossbolthit.nextthink = min(self.nextthink, time + autocvar_g_balance_crossbowdtwr_primary_lifetime_stick);
		crossbolthit.think = self.think;
		
		crossbolthit.takedamage = self.takedamage;
		crossbolthit.health = self.health;
		crossbolthit.damageforcescale = self.damageforcescale;
		crossbolthit.event_damage = self.event_damage;
		crossbolthit.damagedbycontents = self.damagedbycontents;
		
		if (other != world) {
			if (crossbolthit.amnt == 7) {
				IncreaseSpellExpAndMaybeLVL(self.owner.ammount4,
				self.realowner,
				spell_corvuspenna,
				exp_spell_corvuspenna,
				1, other); 
			} else if (crossbolthit.amnt == 8) {
				IncreaseSpellExpAndMaybeLVL(self.owner.ammount4,
				self.realowner,
				spell_plumosus,
				exp_spell_plumosus,
				1, other); 
			}
		}
		
		if (other.health < 1)
		{
			crossbolthit.origin = self.origin;
			crossbolthit.angles = self.angles;
			crossbolthit.speed = self.speed;
		
			//--//remove (self); //Old code, now we remove and do damage at the end
			
			if (crossbolthit.amnt == 4 || crossbolthit.amnt == 5) {
				setmodel (crossbolthit, "models/arrowbodkin.iqm");
			} else if (crossbolthit.amnt == 2 || crossbolthit.amnt == 6) {
				setmodel (crossbolthit, "models/ballistabolt.md3");
			} else if (crossbolthit.amnt == 7) {
				setmodel (crossbolthit, "models/feathers/feathersmall.iqm");
			} else if (crossbolthit.amnt == 8) {
					crossbolthit.skin = 1;
				setmodel (crossbolthit, "models/feathers/feathersmall.iqm");
			} else {
				setmodel (crossbolthit, "models/crossbowbolt.md3");
			}
			setsize (crossbolthit, '0 0 0', '0 0 0');
			crossbolthit.tag_entity = world;
			crossbolthit.movetype = MOVETYPE_TOSS;
			
			//Do the damage after the sticking. This way the bolt can be dropped if player dies
			self.takedamage = DAMAGE_NO;
			RadiusDamage (self, self.realowner, self.ammount, autocvar_g_balance_crossbowdtwr_primary_edgedamage, autocvar_g_balance_crossbowdtwr_primary_radius, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
			
			if (self.amnt == 3 || self.amnt == 5 || self.amnt == 6) {
				if (other != world) {
					//This is the crossbowbolt type we are
					//print("burn!\n");
					Fire_AddDamage(other, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, self.projectiledeathtype);
				}
				OilFire_explosion_spawnoilburnermaybe(self);
			}
			
			self.takedamage = DAMAGE_YES;
			remove (self);
		} else {
			// LordHavoc Supplied this code
			// 21:03 < quantumstate> LordHavoc: what license do you give this code as?
			// 21:03 < quantumstate> (it's going into a gpl mod)
			// 21:03 <@LordHavoc> wtfpl or zlib
			// 21:03 <@LordHavoc> aka I don't care
			crossbolthit.classname = "drop_at_death";
			
			local vector origarroworigin;
			origarroworigin = self.origin;
			local vector old_origin;
			local vector old_angles;
			makevectors(self.angles);
			old_origin = self.origin + v_forward * (24 - (0.14*(other.armorvalue * 2)));
			//24 == approx breath of playerhitbox. Origin of crossbow bolt is near it's tip (not quite but near)
			//14 is the max amount of qunits to subtract if there is armor
			//Armor values of 50 or less is what we deal with, thus the * 2
			old_angles = self.angles;
		
			local vector suborigin;
			local vector relup;
			local vector relorigin;
			local vector relforward;
			local vector boltforward;
			local vector boltup;
		
			//Information on why it's not simply makevectors(self.angles);
			//18:33 <@LordHavoc> quantumstate: it's some legacy quake weirdness that models 
			//	have inverted pitch
			//18:36 <@LordHavoc> makevectors calls on an entity's .angles value are correct 
			//	if the entity is bsp or sprite, but not if it is a model
			//18:36 <@LordHavoc> inverting the pitch is necessary on models
			//18:37 <@LordHavoc> vectoangles and vectoangles2 have the opposite behavior 
			//	where they are correct pitch for models but not for bsp or 
			//	sprite :P

			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			//--//remove (self);  //Old code, now we remove and do damage at the end
			boltforward = v_forward;
			boltup = v_up;
		
			makevectors(other.angles_x * '-1 0 0' + other.angles_y * '0 1 0' + other.angles_z * '0 0 1');
			suborigin = old_origin - other.origin;
			relorigin_x = suborigin * v_forward;
			relorigin_y = suborigin * v_right * -1;
			relorigin_z = suborigin * v_up;
			setorigin(crossbolthit, relorigin);

			relforward_x = boltforward * v_forward;
			relforward_y = boltforward * v_right * -1;
			relforward_z = boltforward * v_up;
			relup_x = boltup * v_forward;
			relup_y = boltup * v_right * -1;
			relup_z = boltup * v_up;
			crossbolthit.angles = vectoangles2(relforward, relup);
		
			if (crossbolthit.amnt == 4 || crossbolthit.amnt == 5) {
				setmodel (crossbolthit, "models/arrowbodkin.iqm");
			} else if (crossbolthit.amnt == 2 || crossbolthit.amnt == 6) {
				setmodel (crossbolthit, "models/ballistabolt.md3");
			} else if (crossbolthit.amnt == 7) {
				setmodel (crossbolthit, "models/feathers/feathersmall.iqm");
			} else if (crossbolthit.amnt == 8) {
					crossbolthit.skin = 1;
				setmodel (crossbolthit, "models/feathers/feathersmall.iqm");
			} else {
				setmodel (crossbolthit, "models/crossbowbolt.md3");
			}
			setsize (crossbolthit, '0 0 0', '0 0 0');
			
			if (other.scale && (other.scale != 1)) {
				crossbolthit.rescaleondrop = 1;
				crossbolthit.droppedscale = crossbolthit.scale;
				crossbolthit.scale = 1/other.scale; //Attached things are scaled to parent, so scale back down.
				//This way we are visually equal to 1/1 scale.
			}
			
			setattachment(crossbolthit, other, "");
			
			//Do the damage after the sticking. This way the bolt can be dropped if player dies
			self.takedamage = DAMAGE_NO;
			
			if (crossbolthit.amnt == 2 || crossbolthit.amnt == 6) {
				//ballistabolt
				RadiusDamage (self, self.realowner,
				W_CritHitCalc_Ballista(self.ammount, origarroworigin, old_origin, other, self.realowner, self.projectiledeathtype),
				autocvar_g_balance_crossbowdtwr_primary_edgedamage, autocvar_g_balance_crossbowdtwr_primary_radius, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
			} else if (crossbolthit.amnt == 7 || crossbolthit.amnt == 8) {
				RadiusDamage (self, self.realowner,
				W_CritHitCalc_ArrowCore(self.ammount, origarroworigin, old_origin, other, self.realowner, self.projectiledeathtype),
				self.ammount * 0.5, 1, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
			} else {
				RadiusDamage (self, self.realowner,
				W_CritHitCalc_ArrowCore(self.ammount, origarroworigin, old_origin, other, self.realowner, self.projectiledeathtype),
				autocvar_g_balance_crossbowdtwr_primary_edgedamage, autocvar_g_balance_crossbowdtwr_primary_radius, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
			}
			
			if (self.amnt == 3 || self.amnt == 5 || self.amnt == 6) {
				if (other != world) {
					//This is the crossbowbolt type we are
					//print("burn!\n");
					Fire_AddDamage(other, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
				}
				OilFire_explosion_spawnoilburnermaybe(self);
			}
			
			self.takedamage = DAMAGE_YES;
			remove (self);
		}
		
	}
}

void W_CrossbowBolt_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	self.health = self.health - damage;
	
	if (self.health <= 0)
		W_PrepareExplosionByDamage(attacker, W_CrossbowBolt_Destroy);
}

void W_CrossbowBolt_Think1 (void)
{
	self.nextthink = time;
	if (time > self.cnt)
	{
		other = world;
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		W_CrossbowBolt_Remove ();
		return;
	}
		//if(self.cb_detonate_later && self.cb_bouncecnt >= autocvar_g_balance_crossbowdtwr_primary_remote_minbouncecnt)
			//W_CrossbowBolt_Explode();
			//W_CrossbowBolt_Remove();
}

void W_CrossbowBolt_Touch1 (void)
{
	local vector myoriginalorigin;
	local float myarrowisburning;
	myarrowisburning = 0;
	if (self.amnt == 3 || self.amnt == 5 || self.amnt == 6) {
		myarrowisburning = 1;
	}
	myoriginalorigin = self.origin; //Used to see if we do an oilfire or methane explosion
	
	self.angles = vectoangles(self.velocity); //So it will stick into the ground with the correct angle. CSQC Projectiles always follow this and thus don't send angle information
	PROJECTILE_TOUCH;
	if (other.takedamage == DAMAGE_AIM
	&& other.classname != "building"
	&& other.classname != "tree"
	&& !other.accptcrssbwstklkbld) // always dmg when hitting a player, but stick if hit a building (not hitting the hitbox, also an arrow, not a ballista!)
	{
		self.use ();
	}
	else //Stick
	{
		entity attachother;
		//spamsound (self, CH_SHOTS, "weapons/crossbowbolt_stick.wav", VOL_BASE, ATTN_NORM);

		// let it stick whereever it is
		self.takedamage = DAMAGE_NO;
		
		
		if (self.amnt == 7 || self.amnt == 8) {
			//Do nothing - feathers
		} else {
			RadiusDamage (self, self.realowner, autocvar_g_balance_crossbowdtwr_primary_nonplayerdamage, autocvar_g_balance_crossbowdtwr_primary_nonplayeredgedamage, autocvar_g_balance_crossbowdtwr_primary_radius, world, autocvar_g_balance_crossbowdtwr_primary_force, self.projectiledeathtype, other);
		}
		
		
		if ((self.amnt == 3 || self.amnt == 5 || self.amnt == 6) && other != world) {
			if (other.classname == "tree" || other.classname == "bush"
			|| isPlayerOrMonsterByClassname(other)) {
				//This is the crossbowbolt type we are
				//print("burn!2222\n");
				Fire_AddDamage(other, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, self.projectiledeathtype);
			} else if (self.amnt == 6) {
				//Ballista bolt, burns things often
				if (other.classname == "building" && other.multitool_hitbox != world) {
					if ((random() > 0.5) && multitool_iswooden(other.multitool_hitbox.count)) {
						Fire_AddDamage(other.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				else if (other.accptcrssbwstklkbld) {
				if (other.multitool_doorframeent && other.multitool_doorframeent.multitool_hitbox != world) {
					if ((random() > 0.5) && multitool_iswooden(other.multitool_doorframeent.multitool_hitbox.count)) {
						Fire_AddDamage(other.multitool_doorframeent.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				}
			} else if (self.amnt == 3 || self.amnt == 5) {
				//Burning arrows and bolts, rarely catch the buildings on fire
				if (other.classname == "building" && other.multitool_hitbox != world) {
					if ((random() > 0.8) && multitool_iswooden(other.multitool_hitbox.count)) {
						Fire_AddDamage(other.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				else if (other.accptcrssbwstklkbld) {
				if (other.multitool_doorframeent && other.multitool_doorframeent.multitool_hitbox != world) {
					if ((random() > 0.8) && multitool_iswooden(other.multitool_doorframeent.multitool_hitbox.count)) {
						Fire_AddDamage(other.multitool_doorframeent.multitool_hitbox, self.realowner, autocvar_g_balance_torch_fire_damage * autocvar_g_balance_torch_fire_burntime, autocvar_g_balance_torch_fire_burntime, DEATH_FIRE);
					}
				}
				}
			}
		}
		
		self.takedamage = DAMAGE_YES;

		self.oldvelocity = self.velocity;
		self.velocity = '0 0 0';
		self.movetype = MOVETYPE_NONE; // also disables gravity
		self.gravity = 0; // nope, it does NOT! maybe a bug in CSQC code? TODO
		UpdateCSQCProjectile(self);

		// do not respond to any more touches
		self.solid = SOLID_NOT;		
		
		entity crossboltstick;
		crossboltstick = spawn ();
		
		if (other.classname != "building" && other.classname != "tree" && !other.accptcrssbwstklkbld)
			crossboltstick.owner = attachother = other; //Thing it's stuck into owns.
		else
			crossboltstick.owner = attachother = world;
		
		crossboltstick.cnt = self.cnt;
		crossboltstick.nextthink = min(self.nextthink, time + autocvar_g_balance_crossbowdtwr_primary_lifetime_stick);
		crossboltstick.think = self.think;
		crossboltstick.amnt = self.amnt;
		
		crossboltstick.takedamage = self.takedamage;
		crossboltstick.health = self.health;
		crossboltstick.damageforcescale = self.damageforcescale;
		crossboltstick.event_damage = self.event_damage;
		crossboltstick.damagedbycontents = self.damagedbycontents;
		crossboltstick.classname = "cbwbolt_stuck";
		
		//print(strcat(self.realowner.netname, " texture ", trace_dphittexturename, " etc\n"));
		
		float hitmaterial;
		if (other.classname == "tree")
			hitmaterial = 8;
		else if (other != world && other.objcthitmaterial)
			hitmaterial = other.objcthitmaterial;
		else
			hitmaterial = W_EvaluateMaterialHit();
			
		float r; //random float for sound selection;
		//// What materials should we stick into, with what probability. Metal we shall never stick into (note: no attach statement)
		if ((hitmaterial == 1) || (hitmaterial == 2)) {
			//print("Metal\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			setorigin(crossboltstick, (self.origin + v_forward * -10)); //Backup 10 qunits
			crossboltstick.angles  = self.angles;

			crossboltstick.tag_entity = world;
			crossboltstick.movetype = MOVETYPE_TOSS;
			
			r = random() * 13;
			if (crossboltstick.amnt == 7 || crossboltstick.amnt == 8) {
				//No sound
			} else if (r > 12) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_213.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 11) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_212.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 10) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_211.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 9) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_210.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 8) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_29.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 7) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_28.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 6) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_27.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 5) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_26.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 4) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_25.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 3) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_24.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 2) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_23.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 1) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_22.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpmetal_21.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if (hitmaterial == 5) {
			//print("Concrete\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			
			
			if (random() < 0.33) {
				setorigin(crossboltstick, (self.origin + v_forward * -9)); //Backup 9 qunits
				crossboltstick.tag_entity = world;
				crossboltstick.movetype = MOVETYPE_TOSS;
			} else {
				setorigin(crossboltstick, (self.origin + v_forward * -5)); //Backup 7 qunits
				setattachment(crossboltstick, attachother, "");
			}
			
			crossboltstick.angles  = self.angles;
			
			r = random() * 2;
			if (crossboltstick.amnt == 7 || crossboltstick.amnt == 8) {
				//No sound
			} else if (r > 1) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/slingimpstone_211.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/slingimpstone_210.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if ((hitmaterial == 3) || (hitmaterial == 4)) {
			//print("Stone and Brick\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			
			local float cb_random;
			cb_random = random();
			if (cb_random < 0.25) {
				setorigin(crossboltstick, (self.origin + v_forward * -9)); //Backup 9 qunits
				crossboltstick.tag_entity = world;
				crossboltstick.movetype = MOVETYPE_TOSS;
			} else if (cb_random < 0.5) {
				setorigin(crossboltstick, (self.origin + v_forward * -4));
				setattachment(crossboltstick, attachother, "");
			} else if (cb_random < 0.75) {
				setorigin(crossboltstick, (self.origin + v_forward * -3));
				setattachment(crossboltstick, attachother, "");	
			} else {
				setorigin(crossboltstick, (self.origin + v_forward * -2));
				setattachment(crossboltstick, attachother, "");
			}
			
			crossboltstick.angles  = self.angles;
			
			r = random() * 12;
			if (crossboltstick.amnt == 7 || crossboltstick.amnt == 8) {
				//No sound
			} else if (r > 11) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_212.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 10) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_211.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 9) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_210.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 8) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_29.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 7) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_28.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 6) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_27.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 5) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_26.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 4) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_25.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 3) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_24.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 2) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_23.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 1) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_22.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/arrowimpstone_21.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if (hitmaterial == 8) {
			//print("Wood and Bark\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			setattachment(crossboltstick, attachother, "");
			
			local float cb_random;
			cb_random = random();
			if (cb_random < 0.2) {
				setorigin(crossboltstick, self.origin);
			} else if (cb_random < 0.4) {
				setorigin(crossboltstick, (self.origin + v_forward * 1.25)); //Forward 1.25 qunits
			} else if (cb_random < 0.6) {
				setorigin(crossboltstick, (self.origin + v_forward * 1.5));
			} else if (cb_random < 0.8) {
				setorigin(crossboltstick, (self.origin + v_forward * 1.75));	
			} else {
				setorigin(crossboltstick, (self.origin + v_forward * 2));
			}
			
			crossboltstick.angles  = self.angles;
			
			if (crossboltstick.amnt == 7 || crossboltstick.amnt == 8) {
				//No sound
			} else if (r > 8) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_19.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 7) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_18.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 6) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_17.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 5) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_16.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 4) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_15.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 3) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_14.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 2) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_13.ogg", VOL_BASE, ATTN_NORM);
			} else if (r > 1) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_12.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/Arrowimpwood_11.ogg", VOL_BASE, ATTN_NORM);
			}
		} else if (hitmaterial == 7) {
			//print("Dirt Etc\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			setattachment(crossboltstick, attachother, "");
			
			local float cb_random;
			cb_random = random();
			if (cb_random < 0.2) {
				setorigin(crossboltstick, self.origin);
			} else if (cb_random < 0.4) {
				setorigin(crossboltstick, (self.origin + v_forward * 2.5)); //Forward 2.5 qunits
			} else if (cb_random < 0.6) {
				setorigin(crossboltstick, (self.origin + v_forward * 2.75));
			} else if (cb_random < 0.8) {
				setorigin(crossboltstick, (self.origin + v_forward * 3));	
			} else {
				setorigin(crossboltstick, (self.origin + v_forward * 3.25));
			}
			
			crossboltstick.angles  = self.angles;
		} else if (hitmaterial == 9) {
			//print("Sheetrock\n");
			
			makevectors(self.angles_x * '-1 0 0' + self.angles_y * '0 1 0' + self.angles_z * '0 0 1');
			
			setattachment(crossboltstick, attachother, "");
			
			local float cb_random;
			cb_random = random();
			if (cb_random < 0.2) {
				setorigin(crossboltstick, self.origin);
			} else if (cb_random < 0.4) {
				setorigin(crossboltstick, (self.origin + v_forward * 9.25)); //Forward 9.25 qunits
			} else if (cb_random < 0.6) {
				setorigin(crossboltstick, (self.origin + v_forward * 9.50));
			} else if (cb_random < 0.8) {
				setorigin(crossboltstick, (self.origin + v_forward * 9.75));	
			} else {
				setorigin(crossboltstick, (self.origin + v_forward * 10));
			}
			
			crossboltstick.angles  = self.angles;
			
			r = random() * 2;
			if (crossboltstick.amnt == 7 || crossboltstick.amnt == 8) {
				//No sound
			} else if (r > 1) {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/slingimpwood_22.ogg", VOL_BASE, ATTN_NORM);
			} else {
				spamsound (crossboltstick, CH_PAIN, "resource/impact/slingimpwood_21.ogg", VOL_BASE, ATTN_NORM);
			}
		} else {
			//print("NotMetal\n");
			setattachment(crossboltstick, attachother, "");
			
			setorigin(crossboltstick, self.origin);
			crossboltstick.angles = self.angles;
		}
		
		
		crossboltstick.speed = self.speed;

		
		
		remove (self);
		
		if (crossboltstick.amnt == 4 || crossboltstick.amnt == 5) {
			setmodel (crossboltstick, "models/arrowbodkin.iqm");
		} else if (crossboltstick.amnt == 2 || crossboltstick.amnt == 6) {
			setmodel (crossboltstick, "models/ballistabolt.md3");
		} else if (crossboltstick.amnt == 7) {
			setmodel (crossboltstick, "models/feathers/feathersmall.iqm");
		} else if (crossboltstick.amnt == 8) {
			crossboltstick.skin = 1;
			setmodel (crossboltstick, "models/feathers/feathersmall.iqm");
		} else {
			setmodel (crossboltstick, "models/crossbowbolt.md3");
		}
		setsize (crossboltstick, '0 0 0', '0 0 0');
	}
	
	if (myarrowisburning) {
		OilFire_explosion_spawnoilburnermaybe_viacoords(myoriginalorigin);
	}
}

void W_CrossbowBolt_Attack (void)
{
	entity crossbolt;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_CROSSBOWDTWR;
	setorigin(crossbolt, w_shotorg);
	setsize(crossbolt, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');

	crossbolt.cnt = time + autocvar_g_balance_crossbowdtwr_primary_lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);	
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your crossbow suffered a partial dryfire\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_CROSSBOWBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

void W_CrossbowBolt_Burning_Attack (void)
{
	entity crossbolt;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_CROSSBOWDTWR;
	setorigin(crossbolt, w_shotorg);
	setsize(crossbolt, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');

	crossbolt.cnt = time + autocvar_g_balance_crossbowdtwr_primary_lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	{
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary_launchfailure);	
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your crossbow suffered a partial dryfire\n");
		}
	} else {
		W_SETUPPROJECTILEVELOCITY_UP(crossbolt, g_balance_crossbowdtwr_primary);
	}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.amnt = 3; //Burning bolt, same model as regular crossbow, will check to see if shall burn in vicinity tho

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_BURNINGBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}

float W_crossbowdtwr_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_crossbowdtwr_reload_ammo && self.clip_load < min(autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_crossbowdtwr (void)
{
	weapon_defaultspawnfunc(WEP_CROSSBOWDTWR);
}

void W_crossbowdtwr_precache_arrowsounds (void)
{
		precache_sound("resource/impact/arrowimpmetal_213.ogg");
		precache_sound("resource/impact/arrowimpmetal_212.ogg");
		precache_sound("resource/impact/arrowimpmetal_211.ogg");
		precache_sound("resource/impact/arrowimpmetal_210.ogg");
		precache_sound("resource/impact/arrowimpmetal_29.ogg");
		precache_sound("resource/impact/arrowimpmetal_28.ogg");
		precache_sound("resource/impact/arrowimpmetal_27.ogg");
		precache_sound("resource/impact/arrowimpmetal_26.ogg");
		precache_sound("resource/impact/arrowimpmetal_25.ogg");
		precache_sound("resource/impact/arrowimpmetal_24.ogg");
		precache_sound("resource/impact/arrowimpmetal_23.ogg");
		precache_sound("resource/impact/arrowimpmetal_22.ogg");
		precache_sound("resource/impact/arrowimpmetal_21.ogg");
		precache_sound("resource/impact/arrowimpstone_212.ogg");
		precache_sound("resource/impact/arrowimpstone_211.ogg");
		precache_sound("resource/impact/arrowimpstone_210.ogg");
		precache_sound("resource/impact/arrowimpstone_29.ogg");
		precache_sound("resource/impact/arrowimpstone_28.ogg");
		precache_sound("resource/impact/arrowimpstone_27.ogg");
		precache_sound("resource/impact/arrowimpstone_26.ogg");
		precache_sound("resource/impact/arrowimpstone_25.ogg");
		precache_sound("resource/impact/arrowimpstone_24.ogg");
		precache_sound("resource/impact/arrowimpstone_23.ogg");
		precache_sound("resource/impact/arrowimpstone_22.ogg");
		precache_sound("resource/impact/arrowimpstone_21.ogg");
		precache_sound("resource/impact/Arrowimpwood_19.ogg");
		precache_sound("resource/impact/Arrowimpwood_18.ogg");
		precache_sound("resource/impact/Arrowimpwood_17.ogg");
		precache_sound("resource/impact/Arrowimpwood_16.ogg");
		precache_sound("resource/impact/Arrowimpwood_15.ogg");
		precache_sound("resource/impact/Arrowimpwood_14.ogg");
		precache_sound("resource/impact/Arrowimpwood_13.ogg");
		precache_sound("resource/impact/Arrowimpwood_12.ogg");
		precache_sound("resource/impact/Arrowimpwood_11.ogg");
		precache_sound("resource/impact/slingimpwood_22.ogg");
		precache_sound("resource/impact/slingimpwood_21.ogg");
		precache_sound("resource/impact/slingimpstone_210.ogg");
		precache_sound("resource/impact/slingimpstone_211.ogg");
}

float w_crossbowdtwr(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_crossbowdtwr_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
			if((bot_aim(autocvar_g_balance_crossbowdtwr_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_lifetime, TRUE)) && (self.cb_release))
			{
				self.BUTTON_ATCK = TRUE;
			}
	}
	else if (req == WR_THINK)
	{
		if (!W_crossbowdtwr_NeedManualReload()) {
			if(autocvar_g_balance_crossbowdtwr_reload_ammo && self.clip_load < min(autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_secondary_ammo)) // forced reload
				weapon_action(self.weapon, WR_RELOAD);
			else if (self.BUTTON_ATCK && self.cb_release)
			{
				if (weapon_prepareattack(0, autocvar_g_balance_crossbowdtwr_primary_refire))
				{
					if (self.cb_arrowlit == 1 || autocvar_g_balance_crossbowdtwr_forceburningbolt == 1)
					{
						//If admin wants to force on all (no choice for player)
						//Or if lit by player F+R near fire
						W_CrossbowBolt_Burning_Attack();
					} else {
						//Normal
						W_CrossbowBolt_Attack();
					}
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_crossbowdtwr_primary_animtime, w_ready);
					self.cb_release = 0;
					
					self.cb_arrowlit = 0;
					
					self.weaponname = "crossbowdtwr-uncocked";
				}
			}
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.cb_release = 1;
			}
		} else {
			self.weaponname = "crossbowdtwr-uncocked";	
		}
		
		//"Animation"
		if ((self.cb_reloaded_time) && 
		(self.cb_reloaded_time < time))
		{
			self.weaponname = "crossbowdtwr";

			self.cb_reloaded_time = 0;
		}
		
		if (self.cb_arrowlit == 1) {
			if ((self.watertype == CONTENT_WATER || self.watertype == CONTENT_SLIME) && self.waterlevel > 2) {
				pointparticles(particleeffectnum("smoke_big"), ((self.origin + self.view_ofs)+(v_forward *32)+(v_up *2)), '0 0 30', 10);
				spamsound (self, CH_WEAPON_A, "machines/steam_fade.ogg", VOL_BASE, ATTN_NORM);
				self.cb_arrowlit = 0;
				
			} else if (time > self.cb_arrownextburn) {
				W_CrossbowAttachFlameToShotorg(particleeffectnum("torchflame"),'0 0 0');
				self.cb_arrownextburn = time + 0.2;
				self.crossbowlight.cb_arrowlit = 1;
			} else {
				self.crossbowlight.cb_arrowlit = 1;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_crossbowdtwr.md3");
		precache_model ("models/weapons/v_crossbowdtwr.md3");
		precache_model ("models/weapons/h_crossbowdtwr.iqm");
		//precache_model ("models/weapons/g_crossbowdtwr-empty.md3");
		//precache_model ("models/weapons/v_crossbowdtwr-empty.md3");
		//precache_model ("models/weapons/h_crossbowdtwr-empty.iqm");
		precache_model ("models/weapons/g_crossbowdtwr-uncocked.md3");
		precache_model ("models/weapons/v_crossbowdtwr-uncocked.md3");
		precache_model ("models/weapons/h_crossbowdtwr-uncocked.iqm");
		precache_model ("models/crossbowbolt.md3");
		precache_sound("weapons/campingrifle_boltclick.wav");
		precache_sound ("machines/steam_fade.ogg");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		W_crossbowdtwr_precache_arrowsounds();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CROSSBOWDTWR);
		self.current_ammo = ammo_nails;
		if not(autocvar_g_balance_bowsstaylit) {
			self.cb_arrowlit = 0;
		}
		
		if (self.cb_arrowlit) {
			crossbow_spawnlight();
		}
	}
	else if (req == WR_RESETPLAYER)
	{
		self.cb_arrowlit = 0;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_crossbowdtwr_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_CROSSBOWDTWR]) >= autocvar_g_balance_crossbowdtwr_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_crossbowdtwr_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_CROSSBOWDTWR]) >= autocvar_g_balance_crossbowdtwr_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_GONETHINK)
	{
		//We lost the weapon
		self.cb_arrowlit = 0;
	}
	else if (req == WR_DROP)
	{
		//We lost dropped the weapon
		self.cb_arrowlit = 0;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_crossbowdtwr_primary_ammo, autocvar_g_balance_crossbowdtwr_secondary_ammo), autocvar_g_balance_crossbowdtwr_reload_ammo, autocvar_g_balance_crossbowdtwr_reload_time, "weapons/campingrifle_boltclick.wav");
		self.cb_reloaded_time = time + autocvar_g_balance_crossbowdtwr_reload_time;
		
		if (self.BUTTON_USE && !self.cb_arrowlit) {
			if (W_CrossbowCanLightBoltEx(self, 78)) {
				self.cb_arrowlit = 1;
				crossbow_spawnlight();
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_crossbowdtwr(float req)
{
	//if(req == WR_IMPACTEFFECT)
	//{
	//	////vector org2;
	//	////org2 = w_org + w_backoff * 12;
	//	////pointparticles(particleeffectnum("crossbowbolt_explode"), org2, '0 0 0', 1);
	//	if(!w_issilent)
	//		sound(self, CH_SHOTS, "weapons/crossbowbolt_impact.wav", VOL_BASE, ATTN_NORM);
	//}
	//else if(req == WR_PRECACHE)
	//{
	//	precache_sound("weapons/crossbowbolt_impact.wav");
	//}
	//else 
	if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see their own crossbow bolt");
		else
			w_deathtypestring = _("%s killed themself good with their crossbow");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s didn't see %s's crossbow bolt");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s almost dodged %s's crossbow bolt");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s ate %s's crossbow bolt");
	}
	return TRUE;
}
#endif
#endif
