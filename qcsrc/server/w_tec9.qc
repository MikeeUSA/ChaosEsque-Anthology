#ifdef REGISTER_WEAPON
REGISTER_WEAPON(TEC9, w_tec9, IT_NAILS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "tec9", "tec9", _("Tec-9"))
#else
#ifdef SVQC

.float tec9_release;
.float tec9_jammed;
.float tec9_unjam;
.float tec9_unjam_time;
.float tec9_click;
.float tec9_animempty;
.float tec9_animset;
.float tec9_nextanim;
.float tec9_nextbot;
.float tec9_magazine; //0normal(32), 1 50rnd
.float tec9_magazine_changetime;
.float tec9_gsetmagazine; //For ground model setting propagation
.float tec9_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup
.float tec9_triggerlag;
.float tec9_triggerlag_time;
.float tec9_triggerlag_button;

void W_Tec9_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_tec9_primary_ammo;
	d = autocvar_g_balance_tec9_primary_damage;
	f = autocvar_g_balance_tec9_primary_force;
	//spread = autocvar_g_balance_tec9_primary_spread;
	spread = bound(autocvar_g_balance_tec9_spread_min, autocvar_g_balance_tec9_spread_min + (autocvar_g_balance_tec9_spread_add * self.misc_bulletcounter), autocvar_g_balance_tec9_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_tec9_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_9mm_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_tec9_reload_ammo);
	
	if (autocvar_g_balance_tec9_jamrate &&
 	(autocvar_g_balance_tec9_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your Tec-9 jammed\n");
		}
		self.tec9_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/uzi_fire.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_tec9_primary_headshotaddeddamage, f, WEP_TEC9, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_tec9_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_tec9_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_tec9_gunrise, random() * autocvar_g_balance_tec9_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '9.25 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -300 - 140) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	} //End Not Jammed
}


float W_Tec9_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_tec9_reload_ammo && self.clip_load < autocvar_g_balance_tec9_primary_ammo))
	{
		if (!self.tec9_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.tec9_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.tec9_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float W_Tec9_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.tec9_magazine == 2) {
				//	if (!autocvar_g_balance_tec9_exmag106notincluded
			  	//	|| player.inv_misc_exmag_tec9_106)
			  	//	{
				//		return 1;
				//	} else {
				//		player.tec9_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else 
				if (player.tec9_magazine == 1.5) {
					if (!autocvar_g_balance_tec9_drum72notincluded
			  		|| player.inv_misc_drum_tec9_72)
			  		{
						return 1;
					} else {
						player.tec9_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.tec9_magazine == 1) {
					if (!autocvar_g_balance_tec9_exmag50notincluded
			  		|| player.inv_misc_exmag_tec9_50)
			  		{
						return 1;
					} else {
						player.tec9_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.tec9_magazine == 0.5) {
					if (!autocvar_g_balance_tec9_exmag36notincluded
			  		|| player.inv_misc_exmag_tec9_36)
			  		{
						return 1;
					} else {
						player.tec9_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.tec9_magazine == -0.25) {
					if (!autocvar_g_balance_tec9_mag20notincluded
			  		|| player.inv_misc_mag_tec9_20)
			  		{
						return 1;
					} else {
						player.tec9_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.tec9_magazine == -0.50) {
					if (!autocvar_g_balance_tec9_mag10notincluded
			  		|| player.inv_misc_mag_tec9_10)
			  		{
						return 1;
					} else {
						player.tec9_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.tec9_magazine == -1) {
					return 1;
				}
				
				if (player.tec9_magazine == 0) {
					if (!autocvar_g_balance_tec9_mag32notincluded
			  		|| player.inv_misc_mag_tec9_32)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.tec9_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_Tec9_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_tec9_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_tec9_reload_ammo;
		player.clip_load = autocvar_g_balance_tec9_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_Tec9_refunddowntocustommag(entity player, float myreloadammo) {
	if(player.clip_load > myreloadammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - myreloadammo;
		player.clip_load = myreloadammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

void W_Tec9_setmodelforanim(entity player) {
	//Reversed, open bolt
	//if (player.tec9_magazine == 2) {
	//	if (player.tec9_animempty)
	//		player.weaponname = "tec9_exm106";
	//	else
	//		player.weaponname = "tec9_exm106_empty";
	//} else
	if (player.tec9_magazine == 1.5) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_drum72";
		else
			player.weaponname = "tec9_drum72_empty";
	} else if (player.tec9_magazine == 1) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_exm50";
		else
			player.weaponname = "tec9_exm50_empty";
	} else if (player.tec9_magazine == 0.5) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_exm36";
		else
			player.weaponname = "tec9_exm36_empty";
			
	} else if (player.tec9_magazine == -0.25) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_mag20";
		else
			player.weaponname = "tec9_mag20_empty";
			
	} else if (player.tec9_magazine == -0.50) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_mag10";
		else
			player.weaponname = "tec9_mag10_empty";
			
	} else if (player.tec9_magazine == -1) {
		if (player.tec9_animempty)
			player.weaponname = "tec9_none";
		else
			player.weaponname = "tec9_none_empty";
	} else {
		if (player.tec9_animempty)
			player.weaponname = "tec9";
		else
			player.weaponname = "tec9_empty";
	}
}

void W_Tec9_setclipsize(entity player) {
	//if (player.tec9_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_tec9_reload_ammoexm106;
	//} else
	if (player.tec9_magazine == 1.5) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammodrum72;
	} else if (player.tec9_magazine == 1) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammoexm50;
	} else if (player.tec9_magazine == 0.5) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammoexm36;
	} else if (player.tec9_magazine == -0.25) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammomag20;
	} else if (player.tec9_magazine == -0.5) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammomag10;
	} else if (player.tec9_magazine == -1) {
		player.clip_size = autocvar_g_balance_tec9_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_tec9_reload_ammo;
	}
}

void W_Tec9_setrefunddown(entity player) {
	//if (player.tec9_magazine == 2) {
	//	W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammoexm106);
	//} else
	if (player.tec9_magazine == 1.5) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammodrum72);
	} else if (player.tec9_magazine == 1) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammoexm50);
	} else if (player.tec9_magazine == 0.5) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammoexm36);
	} else if (player.tec9_magazine == -0.25) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammomag20);
	} else if (player.tec9_magazine == -0.5) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammomag10);	
	} else if (player.tec9_magazine == -1) {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammonone);
	} else {
		W_Tec9_refunddowntocustommag(player, autocvar_g_balance_tec9_reload_ammo);
	}
}

float W_Tec9_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_tec9_mag32notincluded
	|| player.inv_misc_mag_tec9_32)
	{
		return 0;
	} else if (!autocvar_g_balance_tec9_exmag36notincluded
	|| player.inv_misc_exmag_tec9_36)
	{
		return 0.5;
	} else if (!autocvar_g_balance_tec9_exmag50notincluded
	|| player.inv_misc_exmag_tec9_50)
	{
		return 1;
	} else if (!autocvar_g_balance_tec9_drum72notincluded
	|| player.inv_misc_drum_tec9_72)
	{
		return 1.5;
	//} else if (!autocvar_g_balance_tec9_exmag106notincluded
	//|| player.inv_misc_exmag_tec9_106)
	//{
	//	return 2;					
	} else if (!autocvar_g_balance_tec9_mag20notincluded
	|| player.inv_misc_mag_tec9_20)
	{
		return (-0.25);					
	} else if (!autocvar_g_balance_tec9_mag10notincluded
	|| player.inv_misc_mag_tec9_10)
	{
		return (-0.50);					
	}
	
	return currentmagwant;
}

void spawnfunc_weapon_tec9 (void)
{
	weapon_defaultspawnfunc(WEP_TEC9);
}


void w_tec9_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.tec9_magazine == 2) {
	//	myself.model = "models/weapons/g_tec9_exm106.md3";
	//	
	//	if (autocvar_g_balance_tec9_exmag106notincluded
	//	&& player.inv_misc_exmag_tec9_106 >= 1) {
	//		player.inv_misc_exmag_tec9_106 = player.inv_misc_exmag_tec9_106 - 1;
	//		myself.inv_misc_exmag_tec9_106 = myself.inv_misc_exmag_tec9_106 + 1;
	//	}
	//	
	//	myself.tec9_gsetmagazine = player.tec9_magazine;
	//} else
	if (player.tec9_magazine == 1.5) {
		myself.model = "models/weapons/g_tec9_drum72.md3";
		
		if (autocvar_g_balance_tec9_drum72notincluded
		&& player.inv_misc_drum_tec9_72 >= 1) {
			player.inv_misc_drum_tec9_72 = player.inv_misc_drum_tec9_72 - 1;
			myself.inv_misc_drum_tec9_72 = myself.inv_misc_drum_tec9_72 + 1;
		}
		
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else if (player.tec9_magazine == 1) {
		myself.model = "models/weapons/g_tec9_exm50.md3";
		
		if (autocvar_g_balance_tec9_exmag50notincluded
		&& player.inv_misc_exmag_tec9_50 >= 1) {
			player.inv_misc_exmag_tec9_50 = player.inv_misc_exmag_tec9_50 - 1;
			myself.inv_misc_exmag_tec9_50 = myself.inv_misc_exmag_tec9_50 + 1;
		}
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else if (player.tec9_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_tec9.md3";
		
		if (autocvar_g_balance_tec9_mag32notincluded
		&& player.inv_misc_mag_tec9_32 >= 1) {
			player.inv_misc_mag_tec9_32 = player.inv_misc_mag_tec9_32 - 1;
			myself.inv_misc_mag_tec9_32 = myself.inv_misc_mag_tec9_32 + 1;
		}
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else if (player.tec9_magazine == -0.25) {
		myself.model = "models/weapons/g_tec9_mag20.md3";
		
		if (autocvar_g_balance_tec9_mag20notincluded
		&& player.inv_misc_mag_tec9_20 >= 1) {
			player.inv_misc_mag_tec9_20 = player.inv_misc_mag_tec9_20 - 1;
			myself.inv_misc_mag_tec9_20 = myself.inv_misc_mag_tec9_20 + 1;
		}
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else if (player.tec9_magazine == -0.5) {
		myself.model = "models/weapons/g_tec9_mag10.md3";
		
		if (autocvar_g_balance_tec9_mag10notincluded
		&& player.inv_misc_mag_tec9_10 >= 1) {
			player.inv_misc_mag_tec9_10 = player.inv_misc_mag_tec9_10 - 1;
			myself.inv_misc_mag_tec9_10 = myself.inv_misc_mag_tec9_10 + 1;
		}
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else if (player.tec9_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_tec9_none.md3";
		
		myself.tec9_gsetmagazine = player.tec9_magazine;
	} else {
		//Do nothing
		myself.tec9_gsetmagazine = 0;
	}
}

void w_tec9_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_TEC9) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.tec9_magazine = myself.tec9_gsetmagazine;
			player.tec9_pickedupgsetmagazine = myself.tec9_gsetmagazine;
		}
	}
}


.float tec9_primarytime;

float w_tec9(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_Tec9_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.tec9_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.tec9_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_tec9_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_Tec9_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_Tec9_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_Tec9_refunddowntostdmag(self);
			//print(ftos(self.tec9_magazine), "Here222\n");
			//////self.tec9_magazine = W_Tec9_tryforvalidmag(self, self.tec9_magazine);
			W_Tec9_setclipsize(self);
			W_Tec9_setrefunddown(self);
			W_Tec9_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_tec9_reload_ammo && self.clip_load < autocvar_g_balance_tec9_primary_ammo) // forced reload
		{
			// don't force reload an empty tec9 if its melee attack is active
			if not(autocvar_g_balance_tec9_secondary && self.ammo_nails < autocvar_g_balance_tec9_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.tec9_release = 0;
		}
		else
		{
		  if (self.tec9_jammed && self.tec9_unjam)
		  {
		  	if (time >= self.tec9_unjam_time) {
				self.tec9_jammed = 0;
				self.tec9_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK || self.tec9_triggerlag_button == 1)
			if (self.tec9_release)
			if (self.tec9_jammed != 1)
			if (((time > self.tec9_triggerlag_time) && self.tec9_triggerlag) || autocvar_g_balance_noopenbolttriggerlag)
			if (weapon_prepareattack_check(0, 0))
			{
				self.tec9_triggerlag = 1; //For openbolt trigger lag
				
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.tec9_nextbot)," \n");
				} else {
					self.tec9_nextbot = 0;
				}
				
				if (time >= self.tec9_nextbot) {
					W_Tec9_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_tec9_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_tec9_primary_animtime, w_ready);
					self.tec9_release = 0;
					self.tec9_animempty = 1;
					self.tec9_animset = 1;
					self.tec9_nextanim = time + autocvar_g_balance_tec9_primary_rfanim;
					bp_skipme = 1;
					//self.tec9_nextbot = time + (autocvar_g_balance_tec9_primary_refire * 50 * random());
					self.tec9_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.tec9_release = 1;
					self.tec9_nextbot = time;
				}
			}
			
			
			//Openbolt trigger lag
			if (time > self.tec9_triggerlag_time) {
				self.tec9_triggerlag_button = 0;
			}
			
			if (!autocvar_g_balance_noopenbolttriggerlag
		  	&& !(self.tec9_triggerlag)
			&& self.BUTTON_ATCK) {
				self.tec9_triggerlag_button = 1;
				//For openbolt trigger lag
				//print("triggerlag\n"); 
				self.tec9_triggerlag = 1;
				self.tec9_triggerlag_time = time + (autocvar_g_balance_tec9_primary_refire * 0.5) * W_WeaponRateFactor(); //1/2 a cycle
		  	}
			//Openbolt trigger lag
			
			
			if not(bp_skipme) {
				if (self.tec9_jammed != 1)
				if (time >= self.tec9_nextanim)
				if (self.tec9_animempty)
				{
					self.tec9_animempty = 0;
					self.tec9_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.tec9_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
				
				if not(self.tec9_triggerlag_button) {
					self.tec9_triggerlag = 0; //For openbolt trigger lag
				}
			}
				
			//Reversed: open bolt
			if (self.tec9_animset)
			if (self.tec9_jammed != 1) {
					W_Tec9_setmodelforanim(self);
					//if (self.tec9_animempty)
					//	self.weaponname = "tec9";
					//else
					//	self.weaponname = "tec9_empty";
			}
			
			self.tec9_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_Tec9_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_Tec9_refunddowntostdmag(self);
			W_Tec9_setclipsize(self);
			W_Tec9_setrefunddown(self);
			W_Tec9_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_tec9.md3");
		precache_model ("models/weapons/v_tec9.md3");
		precache_model ("models/weapons/h_tec9.iqm");
		
		precache_model ("models/weapons/v_tec9_empty.md3");
		precache_model ("models/weapons/h_tec9_empty.iqm");
		
		precache_model ("models/weapons/g_tec9_mag10.md3");
		precache_model ("models/weapons/v_tec9_mag10.md3");
		precache_model ("models/weapons/h_tec9_mag10.iqm");
		precache_model ("models/weapons/v_tec9_mag10_empty.md3");
		precache_model ("models/weapons/h_tec9_mag10_empty.iqm");
		
		precache_model ("models/weapons/g_tec9_mag20.md3");
		precache_model ("models/weapons/v_tec9_mag20.md3");
		precache_model ("models/weapons/h_tec9_mag20.iqm");
		precache_model ("models/weapons/v_tec9_mag20_empty.md3");
		precache_model ("models/weapons/h_tec9_mag20_empty.iqm");
		
		
		precache_model ("models/weapons/g_tec9_exm36.md3");
		precache_model ("models/weapons/v_tec9_exm36.md3");
		precache_model ("models/weapons/h_tec9_exm36.iqm");
		precache_model ("models/weapons/v_tec9_exm36_empty.md3");
		precache_model ("models/weapons/h_tec9_exm36_empty.iqm");
		
		
		precache_model ("models/weapons/g_tec9_exm50.md3");
		precache_model ("models/weapons/v_tec9_exm50.md3");
		precache_model ("models/weapons/h_tec9_exm50.iqm");
		precache_model ("models/weapons/v_tec9_exm50_empty.md3");
		precache_model ("models/weapons/h_tec9_exm50_empty.iqm");
		
		precache_model ("models/weapons/g_tec9_drum72.md3");
		precache_model ("models/weapons/v_tec9_drum72.md3");
		precache_model ("models/weapons/h_tec9_drum72.iqm");
		precache_model ("models/weapons/v_tec9_drum72_empty.md3");
		precache_model ("models/weapons/h_tec9_drum72_empty.iqm");
		
		precache_model ("models/weapons/g_tec9_none.md3");
		precache_model ("models/weapons/v_tec9_none.md3");
		precache_model ("models/weapons/h_tec9_none.iqm");
		precache_model ("models/weapons/v_tec9_none_empty.md3");
		precache_model ("models/weapons/h_tec9_none_empty.iqm");
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/uzi_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.tec9_triggerlag_button = 0; //for openbolt trigger lag
		self.tec9_triggerlag = 0; //for openbolt trigger lag
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -2.1';
			
		weapon_setup(WEP_TEC9);
		self.current_ammo = ammo_nails;
			//////Reversed, open bolt
			//if (self.tec9_animempty)
			//	self.weaponname = "tec9";
			//else
			//	self.weaponname = "tec9_empty";
	
	
		
		
			//Make sure we're allowed to have.
			W_Tec9_allowedextendedmags(self);
			
			if (self.tec9_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.tec9_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 32 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.tec9_magazine = W_Tec9_tryforvalidmag(self, self.tec9_magazine);
					W_Tec9_allowedextendedmags(self);
				}
			}
			
			self.tec9_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_Tec9_setmodelforanim(self);
			
	
	
	
	
		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  if (self.tec9_jammed && self.tec9_unjam)
		  {
		  	if (time >= self.tec9_unjam_time) {
				self.tec9_jammed = 0;
				self.tec9_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_Tec9_setclipsize(self);
		W_Tec9_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_tec9_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_TEC9]) >= autocvar_g_balance_tec9_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		self.tec9_triggerlag_button = 0; //for openbolt triggerlag
		self.tec9_triggerlag = 0; //for openbolt triggerlag
		
		if (self.tec9_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_tec9_clearjam_time, w_ready);
			if (self.tec9_unjam != 1) {
				self.tec9_unjam = 1;
				self.tec9_unjam_time = time + autocvar_g_balance_tec9_clearjam_time;
				self.tec9_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float tec9donothing;
			tec9donothing = 0;
			if (self.BUTTON_USE) {
			  if (self.tec9_magazine_changetime >= time) {
			  	//Do nothing
				tec9donothing = 1;
			  } else {
				local float tec9magwant;
				if (self.tec9_magazine == -0.5) {
					tec9magwant = -0.25;
				} else if (self.tec9_magazine == -0.25) {
					tec9magwant = 0;
				//} else if (self.tec9_magazine == 0) {
				//	tec9magwant = 0.5;
				} else if (self.tec9_magazine == 0.5) {
					tec9magwant = 1;
				} else if (self.tec9_magazine == 1) {
					tec9magwant = 1.5;
				} else if (self.tec9_magazine == 1.5) {
					//tec9magwant = 2;
					tec9magwant = -0.5;	
				//} else if (self.tec9_magazine == 2) {
				//	tec9magwant = -0.5;	
				} else {
					//self.tec9_magazine == 0
					tec9magwant = 0.5;
				}
				
				if (tec9magwant == -0.5) {
					if (!autocvar_g_balance_tec9_mag10notincluded
			  		|| self.inv_misc_mag_tec9_10)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = -0.25; //fallback
					}
				}
				
				if (tec9magwant == -0.25) {
					if (!autocvar_g_balance_tec9_mag20notincluded
			  		|| self.inv_misc_mag_tec9_20)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = 0; //fallback
					}
				}
				
				//Where standard comes in
				//Keeping with the pattern
				if (tec9magwant == 0) {
					if (!autocvar_g_balance_tec9_mag32notincluded
			  		|| self.inv_misc_mag_tec9_32)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = 0.5; //fallback
					}
				}
				
				//40 round exmag
				if (tec9magwant == 0.5) {
					if (!autocvar_g_balance_tec9_exmag36notincluded
			  		|| self.inv_misc_exmag_tec9_36)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = 1; //fallback
					}
				}				
				
				if (tec9magwant == 1) {
					if (!autocvar_g_balance_tec9_exmag50notincluded
			  		|| self.inv_misc_exmag_tec9_50)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = 1.5; //fallback
					}
				}				
				
				if (tec9magwant == 1.5) {
					if (!autocvar_g_balance_tec9_drum72notincluded
			  		|| self.inv_misc_drum_tec9_72)
			  		{
						//Yes
					} else {
						//No
							//tec9magwant = 2; //fallback
							tec9magwant = -0.5; //fallback
					}
				}
				
				//if (tec9magwant == 2) {
				//	if (!autocvar_g_balance_tec9_exmag106notincluded
			  	//	|| self.inv_misc_exmag_tec9_106)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			tec9magwant = -0.5; //fallback
				//	}
				//}
				
				if (tec9magwant == -0.5) {
					if (!autocvar_g_balance_tec9_mag10notincluded
			  		|| self.inv_misc_mag_tec9_10)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = -0.25; //fallback
					}
				}
				
				if (tec9magwant == -0.25) {
					if (!autocvar_g_balance_tec9_mag20notincluded
			  		|| self.inv_misc_mag_tec9_20)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = 0; //fallback
					}
				}
				
				//If no magazines available...
				if (tec9magwant == 0) {
					if (!autocvar_g_balance_tec9_mag32notincluded
			  		|| self.inv_misc_mag_tec9_32)
			  		{
						//Yes
					} else {
						//No
							tec9magwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (tec9magwant == -1) {
					tec9magwant = W_Tec9_tryforvalidmag(self, tec9magwant);
				}
				//Final decisions
				
				if (tec9magwant == self.tec9_magazine) {
					tec9donothing = 1;
				//} else if (tec9magwant == 2) {
				//	self.tec9_magazine = 2;
				} else if (tec9magwant == 1.5) {
					self.tec9_magazine = 1.5;
				} else if (tec9magwant == 1) {
					self.tec9_magazine = 1;
				} else if (tec9magwant == 0.5) {
					self.tec9_magazine = 0.5;
				} else if (tec9magwant == 0) {
					self.tec9_magazine = 0;
				} else if (tec9magwant == -0.25) {
					self.tec9_magazine = -0.25;
				} else if (tec9magwant == -0.5) {
					self.tec9_magazine = -0.5;
				} else if (tec9magwant == -1) {
					self.tec9_magazine = -1;
				}
				
				W_Tec9_setmodelforanim(self);
			  }
			}
		
			if (tec9donothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.tec9_magazine == 2) {
			//	W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm106, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
			//	
			//	W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammoexm106);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm106, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
			//	W_Tec9_setclipsize(self);
			//	self.tec9_magazine_changetime = time + self.reload_time;
			} else if (self.tec9_magazine == 1.5) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammodrum72, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammodrum72);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammodrum72, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			} else if (self.tec9_magazine == 1) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm50, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammoexm50);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm50, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			} else if (self.tec9_magazine == 0.5) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm36, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammoexm36);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammoexm36, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			} else if (self.tec9_magazine == -0.25) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammomag20, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammomag20);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammomag20, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			} else if (self.tec9_magazine == -0.5) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammomag10, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammomag10);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammomag10, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			
			} else if (self.tec9_magazine == -1) {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammonone, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_Tec9_refunddowntocustommag(self, autocvar_g_balance_tec9_reload_ammonone);
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammonone, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammo, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_Tec9_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammo, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
				W_Tec9_setclipsize(self);
				self.tec9_magazine_changetime = time + self.reload_time;
			}
			
			//////Old:
			//////W_Reload(autocvar_g_balance_tec9_primary_ammo, autocvar_g_balance_tec9_reload_ammo, autocvar_g_balance_tec9_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_tec9(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		pointparticles(particleeffectnum("machinegun_impact"), org2, w_backoff * 1000, 1);
		if(!w_issilent && time - self.prevric > 0.25)
		{
			if(w_random < 0.0165)
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.033)
				sound(self, CH_SHOTS, "weapons/ric2.wav", VOL_BASE, ATTN_NORM);
			else if(w_random < 0.05)
				sound(self, CH_SHOTS, "weapons/ric3.wav", VOL_BASE, ATTN_NORM);
			self.prevric = time;
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/ric1.wav");
		precache_sound("weapons/ric2.wav");
		precache_sound("weapons/ric3.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_CORESHOT)
			w_deathtypestring = _("%1$s chest was ventelated by %2$s Tec-9");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s domed them with a Tec-9");
		else
			w_deathtypestring = _("%s was kiled by %s's Tec-9");
	}
	return TRUE;
}
#endif
#endif
