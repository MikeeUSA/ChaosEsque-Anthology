#ifdef REGISTER_WEAPON
REGISTER_WEAPON(MINIUZI, w_miniuzi, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "miniuzi", "miniuzi", _("Uzi"))
#else
#ifdef SVQC

.float miniuzi_release;
.float miniuzi_jammed;
.float miniuzi_unjam;
.float miniuzi_unjam_time;
.float miniuzi_click;
.float miniuzi_animempty;
.float miniuzi_animset;
.float miniuzi_nextanim;
.float miniuzi_nextbot;
.float miniuzi_magazine; //0normal(32), 1 50rnd, 2 106rnd
.float miniuzi_magazine_changetime;
.float miniuzi_gsetmagazine; //For ground model setting propagation
.float miniuzi_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup

void W_MiniUzi_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_miniuzi_primary_ammo;
	d = autocvar_g_balance_miniuzi_primary_damage;
	f = autocvar_g_balance_miniuzi_primary_force;
	//spread = autocvar_g_balance_miniuzi_primary_spread;
	spread = bound(autocvar_g_balance_miniuzi_spread_min, autocvar_g_balance_miniuzi_spread_min + (autocvar_g_balance_miniuzi_spread_add * self.misc_bulletcounter), autocvar_g_balance_miniuzi_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_miniuzi_primary_speed;
	bulletconstant = autocvar_g_balance_miniuzi_primary_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_miniuzi_reload_ammo);
	
	if (autocvar_g_balance_miniuzi_jamrate &&
 	(autocvar_g_balance_miniuzi_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your miniuzi jammed\n");
		}
		self.miniuzi_jammed = 1;
	} else { //Start Not Jammed

		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/futuristic_smg_single_shot.wav", CH_WEAPON_A, d);

	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_miniuzi_primary_headshotaddeddamage, f, WEP_MINIUZI, PROJECTILE_BULLET9MM, 1, bulletconstant, autocvar_g_balance_miniuzi_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_miniuzi_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_miniuzi_gunrise, random() * autocvar_g_balance_miniuzi_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '4.25 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 25 + 25)) - ((random () * -200 - 120) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 5, self);

	
	} //End Not Jammed
}


float W_MiniUzi_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_miniuzi_reload_ammo && self.clip_load < autocvar_g_balance_miniuzi_primary_ammo))
	{
		if (!self.miniuzi_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.miniuzi_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.miniuzi_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}


float W_MiniUzi_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				if (player.miniuzi_magazine == 2) {
					if (!autocvar_g_balance_miniuzi_exmag106notincluded
			  		|| player.inv_misc_exmag_uzi_106)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == 1.5) {
					if (!autocvar_g_balance_miniuzi_drum82notincluded
			  		|| player.inv_misc_drum_uzi_82)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == 1) {
					if (!autocvar_g_balance_miniuzi_exmag50notincluded
			  		|| player.inv_misc_exmag_uzi_50)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == 0.5) {
					if (!autocvar_g_balance_miniuzi_exmag40notincluded
			  		|| player.inv_misc_exmag_uzi_40)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == -0.25) {
					if (!autocvar_g_balance_miniuzi_mag25notincluded
			  		|| player.inv_misc_mag_uzi_25)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == -0.50) {
					if (!autocvar_g_balance_miniuzi_mag20notincluded
			  		|| player.inv_misc_mag_uzi_20)
			  		{
						return 1;
					} else {
						player.miniuzi_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.miniuzi_magazine == -1) {
					return 1;
				}
				
				if (player.miniuzi_magazine == 0) {
					if (!autocvar_g_balance_miniuzi_mag32notincluded
			  		|| player.inv_misc_mag_uzi_32)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.miniuzi_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_MiniUzi_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_miniuzi_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_miniuzi_reload_ammo;
		player.clip_load = autocvar_g_balance_miniuzi_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_MiniUzi_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_MiniUzi_setmodelforanim(entity player) {
	//Reversed, open bolt
	if (player.miniuzi_magazine == 2) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_exm106";
		else
			player.weaponname = "miniuzi_exm106_empty";
	} else if (player.miniuzi_magazine == 1.5) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_drum82";
		else
			player.weaponname = "miniuzi_drum82_empty";
	} else if (player.miniuzi_magazine == 1) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_exm50";
		else
			player.weaponname = "miniuzi_exm50_empty";
	} else if (player.miniuzi_magazine == 0.5) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_exm40";
		else
			player.weaponname = "miniuzi_exm40_empty";
			
	} else if (player.miniuzi_magazine == -0.25) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_mag25";
		else
			player.weaponname = "miniuzi_mag25_empty";
			
	} else if (player.miniuzi_magazine == -0.50) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_mag20";
		else
			player.weaponname = "miniuzi_mag20_empty";
			
	} else if (player.miniuzi_magazine == -1) {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi_none";
		else
			player.weaponname = "miniuzi_none_empty";
	} else {
		if (player.miniuzi_animempty)
			player.weaponname = "miniuzi";
		else
			player.weaponname = "miniuzi_empty";
	}
}

void W_MiniUzi_setclipsize(entity player) {
	if (player.miniuzi_magazine == 2) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammoexm106;
	} else if (player.miniuzi_magazine == 1.5) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammodrum82;
	} else if (player.miniuzi_magazine == 1) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammoexm50;
	} else if (player.miniuzi_magazine == 0.5) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammoexm40;
	} else if (player.miniuzi_magazine == -0.25) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammomag25;
	} else if (player.miniuzi_magazine == -0.5) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammomag20;
	} else if (player.miniuzi_magazine == -1) {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_miniuzi_reload_ammo;
	}
}

void W_MiniUzi_setrefunddown(entity player) {
	if (player.miniuzi_magazine == 2) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammoexm106);
	} else if (player.miniuzi_magazine == 1.5) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammodrum82);
	} else if (player.miniuzi_magazine == 1) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammoexm50);
	} else if (player.miniuzi_magazine == 0.5) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammoexm40);
	} else if (player.miniuzi_magazine == -0.25) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammomag25);
	} else if (player.miniuzi_magazine == -0.5) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammomag20);	
	} else if (player.miniuzi_magazine == -1) {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammonone);
	} else {
		W_MiniUzi_refunddowntocustommag(player, autocvar_g_balance_miniuzi_reload_ammo);
	}
}

float W_MiniUzi_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_miniuzi_mag32notincluded
	|| player.inv_misc_mag_uzi_32)
	{
		return 0;
	} else if (!autocvar_g_balance_miniuzi_exmag40notincluded
	|| player.inv_misc_exmag_uzi_40)
	{
		return 0.5;
	} else if (!autocvar_g_balance_miniuzi_exmag50notincluded
	|| player.inv_misc_exmag_uzi_50)
	{
		return 1;
	} else if (!autocvar_g_balance_miniuzi_drum82notincluded
	|| player.inv_misc_drum_uzi_82)
	{
		return 1.5;
	} else if (!autocvar_g_balance_miniuzi_exmag106notincluded
	|| player.inv_misc_exmag_uzi_106)
	{
		return 2;					
	} else if (!autocvar_g_balance_miniuzi_mag25notincluded
	|| player.inv_misc_mag_uzi_25)
	{
		return (-0.25);					
	} else if (!autocvar_g_balance_miniuzi_mag20notincluded
	|| player.inv_misc_mag_uzi_20)
	{
		return (-0.50);					
	}
	
	return currentmagwant;
}

void spawnfunc_weapon_miniuzi (void)
{
	weapon_defaultspawnfunc(WEP_MINIUZI);
}

void w_miniuzi_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	if (player.miniuzi_magazine == 2) {
		myself.model = "models/weapons/g_miniuzi_exm106.md3";
		
		if (autocvar_g_balance_miniuzi_exmag106notincluded
		&& player.inv_misc_exmag_uzi_106 >= 1) {
			player.inv_misc_exmag_uzi_106 = player.inv_misc_exmag_uzi_106 - 1;
			myself.inv_misc_exmag_uzi_106 = myself.inv_misc_exmag_uzi_106 + 1;
		}
		
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == 1.5) {
		myself.model = "models/weapons/g_miniuzi_drum82.md3";
		
		if (autocvar_g_balance_miniuzi_drum82notincluded
		&& player.inv_misc_drum_uzi_82 >= 1) {
			player.inv_misc_drum_uzi_82 = player.inv_misc_drum_uzi_82 - 1;
			myself.inv_misc_drum_uzi_82 = myself.inv_misc_drum_uzi_82 + 1;
		}
		
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == 1) {
		myself.model = "models/weapons/g_miniuzi_exm50.md3";
		
		if (autocvar_g_balance_miniuzi_exmag50notincluded
		&& player.inv_misc_exmag_uzi_50 >= 1) {
			player.inv_misc_exmag_uzi_50 = player.inv_misc_exmag_uzi_50 - 1;
			myself.inv_misc_exmag_uzi_50 = myself.inv_misc_exmag_uzi_50 + 1;
		}
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_miniuzi.md3";
		
		if (autocvar_g_balance_miniuzi_mag32notincluded
		&& player.inv_misc_mag_uzi_32 >= 1) {
			player.inv_misc_mag_uzi_32 = player.inv_misc_mag_uzi_32 - 1;
			myself.inv_misc_mag_uzi_32 = myself.inv_misc_mag_uzi_32 + 1;
		}
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == -0.25) {
		myself.model = "models/weapons/g_miniuzi_mag25.md3";
		
		if (autocvar_g_balance_miniuzi_mag25notincluded
		&& player.inv_misc_mag_uzi_25 >= 1) {
			player.inv_misc_mag_uzi_25 = player.inv_misc_mag_uzi_25 - 1;
			myself.inv_misc_mag_uzi_25 = myself.inv_misc_mag_uzi_25 + 1;
		}
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == -0.5) {
		myself.model = "models/weapons/g_miniuzi_mag20.md3";
		
		if (autocvar_g_balance_miniuzi_mag20notincluded
		&& player.inv_misc_mag_uzi_20 >= 1) {
			player.inv_misc_mag_uzi_20 = player.inv_misc_mag_uzi_20 - 1;
			myself.inv_misc_mag_uzi_20 = myself.inv_misc_mag_uzi_20 + 1;
		}
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else if (player.miniuzi_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_miniuzi_none.md3";
		
		myself.miniuzi_gsetmagazine = player.miniuzi_magazine;
	} else {
		//Do nothing
		myself.miniuzi_gsetmagazine = 0;
	}
}

void w_miniuzi_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_MINIUZI) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.miniuzi_magazine = myself.miniuzi_gsetmagazine;
			player.miniuzi_pickedupgsetmagazine = myself.miniuzi_gsetmagazine;
		}
	}
}

.float miniuzi_primarytime;

float w_miniuzi(float req)
{
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_MiniUzi_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.miniuzi_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.miniuzi_release) {
			if(autocvar_g_antilag_bullets)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
			else
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_miniuzi_primary_speed, 0, 0.001, FALSE);
		}
		
	}
	else if (req == WR_THINK && !W_MiniUzi_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_MiniUzi_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_MiniUzi_refunddowntostdmag(self);
			//print(ftos(self.miniuzi_magazine), "Here222\n");
			//////self.miniuzi_magazine = W_MiniUzi_tryforvalidmag(self, self.miniuzi_magazine);
			W_MiniUzi_setclipsize(self);
			W_MiniUzi_setrefunddown(self);
			W_MiniUzi_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_miniuzi_reload_ammo && self.clip_load < autocvar_g_balance_miniuzi_primary_ammo) // forced reload
		{
			// don't force reload an empty miniuzi if its melee attack is active
			if not(autocvar_g_balance_miniuzi_secondary && self.ammo_nails < autocvar_g_balance_miniuzi_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.miniuzi_release = 0;
		}
		else
		{
		  if (self.miniuzi_jammed && self.miniuzi_unjam)
		  {
		  	if (time >= self.miniuzi_unjam_time) {
				self.miniuzi_jammed = 0;
				self.miniuzi_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.miniuzi_release)
			if (self.miniuzi_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.miniuzi_nextbot)," \n");
				} else {
					self.miniuzi_nextbot = 0;
				}
				
				if (time >= self.miniuzi_nextbot) {
					W_MiniUzi_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_miniuzi_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_miniuzi_primary_animtime, w_ready);
					self.miniuzi_release = 0;
					self.miniuzi_animempty = 1;
					self.miniuzi_animset = 1;
					self.miniuzi_nextanim = time + autocvar_g_balance_miniuzi_primary_rfanim;
					bp_skipme = 1;
					//self.miniuzi_nextbot = time + (autocvar_g_balance_miniuzi_primary_refire * 50 * random());
					self.miniuzi_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.miniuzi_release = 1;
					self.miniuzi_nextbot = time;
				}
			}
			
			if (self.BUTTON_ATCK2)
			if (self.miniuzi_release)
			if (self.miniuzi_jammed != 1)
			if (weapon_prepareattack_check(0, 0))
			{
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.miniuzi_nextbot)," \n");
				} else {
					self.miniuzi_nextbot = 0;
				}
				
				if (time >= self.miniuzi_nextbot) {
					W_MiniUzi_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_miniuzi_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_miniuzi_secondary_animtime, w_ready);
					self.miniuzi_release = 0;
					self.miniuzi_animempty = 1;
					self.miniuzi_animset = 1;
					self.miniuzi_nextanim = time + autocvar_g_balance_miniuzi_secondary_rfanim;
					bp_skipme = 1;
					//self.miniuzi_nextbot = time + (autocvar_g_balance_miniuzi_secondary_refire * 50 * random());
					self.miniuzi_nextbot = time + 0.1 + (0.4 * random());
					
					if (autocvar_g_balance_miniuzi_fullauto == 1) {
						self.miniuzi_release = 1;
						self.miniuzi_nextbot = time;
					}
				}
			}
			
			if not(bp_skipme) {
				if (self.miniuzi_jammed != 1)
				if (time >= self.miniuzi_nextanim)
				if (self.miniuzi_animempty)
				{
					self.miniuzi_animempty = 0;
					self.miniuzi_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.miniuzi_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//Reversed, open bolt
			if (self.miniuzi_animset)
			if (self.miniuzi_jammed != 1) {
					W_MiniUzi_setmodelforanim(self);
					//if (self.miniuzi_animempty)
					//	self.weaponname = "miniuzi";
					//else
					//	self.weaponname = "miniuzi_empty";
			}
			
			self.miniuzi_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_MiniUzi_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_MiniUzi_refunddowntostdmag(self);
			W_MiniUzi_setclipsize(self);
			W_MiniUzi_setrefunddown(self);
			W_MiniUzi_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_miniuzi.md3");
		precache_model ("models/weapons/v_miniuzi.md3");
		precache_model ("models/weapons/h_miniuzi.iqm");
		
		precache_model ("models/weapons/v_miniuzi_empty.md3");
		precache_model ("models/weapons/h_miniuzi_empty.iqm");
		
		
		precache_model ("models/weapons/g_miniuzi_mag20.md3");
		precache_model ("models/weapons/v_miniuzi_mag20.md3");
		precache_model ("models/weapons/h_miniuzi_mag20.iqm");
		precache_model ("models/weapons/v_miniuzi_mag20_empty.md3");
		precache_model ("models/weapons/h_miniuzi_mag20_empty.iqm");
		
		precache_model ("models/weapons/g_miniuzi_mag25.md3");
		precache_model ("models/weapons/v_miniuzi_mag25.md3");
		precache_model ("models/weapons/h_miniuzi_mag25.iqm");
		precache_model ("models/weapons/v_miniuzi_mag25_empty.md3");
		precache_model ("models/weapons/h_miniuzi_mag25_empty.iqm");
		
		
		precache_model ("models/weapons/g_miniuzi_exm40.md3");
		precache_model ("models/weapons/v_miniuzi_exm40.md3");
		precache_model ("models/weapons/h_miniuzi_exm40.iqm");
		precache_model ("models/weapons/v_miniuzi_exm40_empty.md3");
		precache_model ("models/weapons/h_miniuzi_exm40_empty.iqm");
		
		
		precache_model ("models/weapons/g_miniuzi_exm50.md3");
		precache_model ("models/weapons/v_miniuzi_exm50.md3");
		precache_model ("models/weapons/h_miniuzi_exm50.iqm");
		precache_model ("models/weapons/v_miniuzi_exm50_empty.md3");
		precache_model ("models/weapons/h_miniuzi_exm50_empty.iqm");
		
		precache_model ("models/weapons/g_miniuzi_drum82.md3");
		precache_model ("models/weapons/v_miniuzi_drum82.md3");
		precache_model ("models/weapons/h_miniuzi_drum82.iqm");
		precache_model ("models/weapons/v_miniuzi_drum82_empty.md3");
		precache_model ("models/weapons/h_miniuzi_drum82_empty.iqm");
		
		precache_model ("models/weapons/g_miniuzi_exm106.md3");
		precache_model ("models/weapons/v_miniuzi_exm106.md3");
		precache_model ("models/weapons/h_miniuzi_exm106.iqm");
		precache_model ("models/weapons/v_miniuzi_exm106_empty.md3");
		precache_model ("models/weapons/h_miniuzi_exm106_empty.iqm");
		
		precache_model ("models/weapons/g_miniuzi_none.md3");
		precache_model ("models/weapons/v_miniuzi_none.md3");
		precache_model ("models/weapons/h_miniuzi_none.iqm");
		precache_model ("models/weapons/v_miniuzi_none_empty.md3");
		precache_model ("models/weapons/h_miniuzi_none_empty.iqm");
		
		
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/futuristic_smg_single_shot.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 -0.35 -2.1';
		self.weaponaltaim = '40 -0.35 -2.6';
			
		weapon_setup(WEP_MINIUZI);
		self.current_ammo = ammo_nails;
		
			////Reversed, open bolt
			//if (self.miniuzi_animempty)
			//	self.weaponname = "miniuzi";
			//else
			//	self.weaponname = "miniuzi_empty";
	
		
		
			//Make sure we're allowed to have.
			W_MiniUzi_allowedextendedmags(self);
			
			if (self.miniuzi_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.miniuzi_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 32 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.miniuzi_magazine = W_MiniUzi_tryforvalidmag(self, self.miniuzi_magazine);
					W_MiniUzi_allowedextendedmags(self);
				}
			}
			
			self.miniuzi_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_MiniUzi_setmodelforanim(self);
			
	
	
		  if (self.miniuzi_jammed && self.miniuzi_unjam)
		  {
		  	if (time >= self.miniuzi_unjam_time) {
				self.miniuzi_jammed = 0;
				self.miniuzi_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_MiniUzi_setclipsize(self);
		W_MiniUzi_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_miniuzi_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_MINIUZI]) >= autocvar_g_balance_miniuzi_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.miniuzi_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_miniuzi_clearjam_time, w_ready);
			if (self.miniuzi_unjam != 1) {
				self.miniuzi_unjam = 1;
				self.miniuzi_unjam_time = time + autocvar_g_balance_miniuzi_clearjam_time;
				self.miniuzi_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float miniuzidonothing;
			miniuzidonothing = 0;
			if (self.BUTTON_USE) {
			  if (self.miniuzi_magazine_changetime >= time) {
			  	//Do nothing
				miniuzidonothing = 1;
			  } else {
				local float miniuzimagwant;
				if (self.miniuzi_magazine == -0.5) {
					miniuzimagwant = -0.25;
				} else if (self.miniuzi_magazine == -0.25) {
					miniuzimagwant = 0;
				//} else if (self.miniuzi_magazine == 0) {
				//	miniuzimagwant = 0.5;
				} else if (self.miniuzi_magazine == 0.5) {
					miniuzimagwant = 1;
				} else if (self.miniuzi_magazine == 1) {
					miniuzimagwant = 1.5;
				} else if (self.miniuzi_magazine == 1.5) {
					miniuzimagwant = 2;	
				} else if (self.miniuzi_magazine == 2) {
					miniuzimagwant = -0.5;	
				} else {
					//self.miniuzi_magazine == 0
					miniuzimagwant = 0.5;
				}
				
				if (miniuzimagwant == -0.5) {
					if (!autocvar_g_balance_miniuzi_mag20notincluded
			  		|| self.inv_misc_mag_uzi_20)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = -0.25; //fallback
					}
				}
				
				if (miniuzimagwant == -0.25) {
					if (!autocvar_g_balance_miniuzi_mag25notincluded
			  		|| self.inv_misc_mag_uzi_25)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 0; //fallback
					}
				}
				
				//Where standard comes in
				//Keeping with the pattern
				if (miniuzimagwant == 0) {
					if (!autocvar_g_balance_miniuzi_mag32notincluded
			  		|| self.inv_misc_mag_uzi_32)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 0.5; //fallback
					}
				}
				
				//40 round exmag
				if (miniuzimagwant == 0.5) {
					if (!autocvar_g_balance_miniuzi_exmag40notincluded
			  		|| self.inv_misc_exmag_uzi_40)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 1; //fallback
					}
				}				
				
				if (miniuzimagwant == 1) {
					if (!autocvar_g_balance_miniuzi_exmag50notincluded
			  		|| self.inv_misc_exmag_uzi_50)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 1.5; //fallback
					}
				}				
				
				if (miniuzimagwant == 1.5) {
					if (!autocvar_g_balance_miniuzi_drum82notincluded
			  		|| self.inv_misc_drum_uzi_82)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 2; //fallback
					}
				}
				
				if (miniuzimagwant == 2) {
					if (!autocvar_g_balance_miniuzi_exmag106notincluded
			  		|| self.inv_misc_exmag_uzi_106)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = -0.5; //fallback
					}
				}
				
				if (miniuzimagwant == -0.5) {
					if (!autocvar_g_balance_miniuzi_mag20notincluded
			  		|| self.inv_misc_mag_uzi_20)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = -0.25; //fallback
					}
				}
				
				if (miniuzimagwant == -0.25) {
					if (!autocvar_g_balance_miniuzi_mag25notincluded
			  		|| self.inv_misc_mag_uzi_25)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = 0; //fallback
					}
				}
				
				//If no magazines available...
				if (miniuzimagwant == 0) {
					if (!autocvar_g_balance_miniuzi_mag32notincluded
			  		|| self.inv_misc_mag_uzi_32)
			  		{
						//Yes
					} else {
						//No
							miniuzimagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (miniuzimagwant == -1) {
					miniuzimagwant = W_MiniUzi_tryforvalidmag(self, miniuzimagwant);
				}
				//Final decisions
				
				if (miniuzimagwant == self.miniuzi_magazine) {
					miniuzidonothing = 1;
				} else if (miniuzimagwant == 2) {
					self.miniuzi_magazine = 2;
				} else if (miniuzimagwant == 1.5) {
					self.miniuzi_magazine = 1.5;
				} else if (miniuzimagwant == 1) {
					self.miniuzi_magazine = 1;
				} else if (miniuzimagwant == 0.5) {
					self.miniuzi_magazine = 0.5;
				} else if (miniuzimagwant == 0) {
					self.miniuzi_magazine = 0;
				} else if (miniuzimagwant == -0.25) {
					self.miniuzi_magazine = -0.25;
				} else if (miniuzimagwant == -0.5) {
					self.miniuzi_magazine = -0.5;
				} else if (miniuzimagwant == -1) {
					self.miniuzi_magazine = -1;
				}
				
				W_MiniUzi_setmodelforanim(self);
			  }
			}
		
			if (miniuzidonothing) {
				//print(ftos(time),"Doing nothing\n");
			} else if (self.miniuzi_magazine == 2) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm106, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammoexm106);
				//Normally no refund here since selection goes up
	
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm106, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else if (self.miniuzi_magazine == 1.5) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammodrum82, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammodrum82);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammodrum82, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else if (self.miniuzi_magazine == 1) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm50, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammoexm50);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm50, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else if (self.miniuzi_magazine == 0.5) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm40, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammoexm40);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammoexm40, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else if (self.miniuzi_magazine == -0.25) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammomag25, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammomag25);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammomag25, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else if (self.miniuzi_magazine == -0.5) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammomag20, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammomag20);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammomag20, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			
			} else if (self.miniuzi_magazine == -1) {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammonone, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_MiniUzi_refunddowntocustommag(self, autocvar_g_balance_miniuzi_reload_ammonone);
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammonone, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammo, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_MiniUzi_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_miniuzi_primary_ammo, autocvar_g_balance_miniuzi_reload_ammo, autocvar_g_balance_miniuzi_reload_time, "weapons/reload.wav");
				W_MiniUzi_setclipsize(self);
				self.miniuzi_magazine_changetime = time + self.reload_time;
			}
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_miniuzi(float req)
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
			w_deathtypestring = _("%1$s chest was ventelated by %2$s uzi");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%1$s died when %2$s shot them in the head with an uzi");
		else
			w_deathtypestring = _("%s was kiled by %s's uzi");
	}
	return TRUE;
}
#endif
#endif
