#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M16MINI, w_m16mini, IT_NAILS, 6, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m16mini", "m16mini", _("M16-Mini"))
#else
#ifdef SVQC

.float m16mini_release;
.float m16mini_jammed;
.float m16mini_unjam;
.float m16mini_unjam_time;
.float m16mini_click;
.float m16mini_animempty;
.float m16mini_animset;
.float m16mini_nextanim;
.float m16mini_nextbot;
.float m16mini_setting; //0 full auto //1 semi
.float m16mini_overheat_cnt;
.float m16mini_overheated_until;
.float m16mini_magazine; //0normal(32), 1 50rnd, 2 106rnd
.float m16mini_magazine_changetime;
.float m16mini_gsetmagazine; //For ground model setting propagation
.float m16mini_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup

void W_M16Mini_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m16mini_primary_ammo;
	d = autocvar_g_balance_m16mini_primary_damage;
	f = autocvar_g_balance_m16mini_primary_force;
	//spread = autocvar_g_balance_m16mini_primary_spread;
	spread = bound(autocvar_g_balance_m16mini_spread_min, autocvar_g_balance_m16mini_spread_min + (autocvar_g_balance_m16mini_spread_add * self.misc_bulletcounter), autocvar_g_balance_m16mini_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_m16mini_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m16mini_reload_ammo);
	
	if (autocvar_g_balance_m16mini_jamrate &&
 	(autocvar_g_balance_m16mini_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault rifle jammed\n");
		}
		self.m16mini_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m16mini_primary_headshotaddeddamage, f, WEP_M16MINI, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_m16mini_primary_coreshotaddeddamage);
	endFireBallisticBullet();

	if (!g_norecoil)
	{
		if (self.misc_bulletcounter) {
		//If we've been shooting full auto, shake things around
		self.punchangle_x = random () - 0.35;
		self.punchangle_y = random () - 0.35;
		}
	}
	self.misc_bulletcounter = self.misc_bulletcounter + 1;

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m16mini_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m16mini_gunrise, random() * autocvar_g_balance_m16mini_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '-9 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * -120 - 140) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self);


	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.m16mini_overheat_cnt),"_Firing\n");
		
	    	self.m16mini_overheat_cnt = self.m16mini_overheat_cnt + autocvar_g_balance_m16mini_heatconstant;
         
	    	if (self.m16mini_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your m16mini overheated\n");
			}
				
			self.m16mini_overheated_until = time + (autocvar_g_balance_m16mini_cooldownwait * (self.m16mini_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
}


float W_M16Mini_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m16mini_reload_ammo && self.clip_load < autocvar_g_balance_m16mini_primary_ammo))
	{
		if (!self.m16mini_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m16mini_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m16mini_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

//
float W_M16Mini_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.m16mini_magazine == 2) {
				//	if (!autocvar_g_balance_m16mini_exmag106notincluded
			  	//	|| player.inv_misc_exmag_m16_106)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16mini_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else
				if (player.m16mini_magazine == 1.5) {
					if (!autocvar_g_balance_m16mini_betacmagnotincluded
			  		|| player.inv_misc_betacmag_m16)
			  		{
						return 1;
					} else {
						player.m16mini_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				//} else if (player.m16mini_magazine == 1) {
				//	if (!autocvar_g_balance_m16mini_exmag50notincluded
			  	//	|| player.inv_misc_exmag_m16_50)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16mini_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.m16mini_magazine == 0.5) {
				//	if (!autocvar_g_balance_m16mini_exmag40notincluded
			  	//	|| player.inv_misc_exmag_m16_40)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16mini_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.m16mini_magazine == -0.25) {
				//	if (!autocvar_g_balance_m16mini_mag25notincluded
			  	//	|| player.inv_misc_mag_m16_25)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16mini_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				} else if (player.m16mini_magazine == -0.50) {
					if (!autocvar_g_balance_m16mini_mag20notincluded
			  		|| player.inv_misc_mag_m16_20)
			  		{
						return 1;
					} else {
						player.m16mini_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				} else if (player.m16mini_magazine == -1) {
					return 1;
				}
				
				if (player.m16mini_magazine == 0) {
					if (!autocvar_g_balance_m16mini_mag30notincluded
			  		|| player.inv_misc_mag_m16_30)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.m16mini_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_M16Mini_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_m16mini_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_m16mini_reload_ammo;
		player.clip_load = autocvar_g_balance_m16mini_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_M16Mini_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_M16Mini_setmodelforanim(entity player) {
	//No anim
	//if (player.m16mini_magazine == 2) {
	//		player.weaponname = "m16mini_exm106";
	//} else
	if (player.m16mini_magazine == 1.5) {
			player.weaponname = "m16mini_betacmag";
	//} else if (player.m16mini_magazine == 1) {
	//		player.weaponname = "m16mini_exm50";
	//} else if (player.m16mini_magazine == 0.5) {
	//		player.weaponname = "m16mini_exm40";
	//} else if (player.m16mini_magazine == -0.25) {
	//		player.weaponname = "m16mini_mag25";
	} else if (player.m16mini_magazine == -0.50) {
			player.weaponname = "m16mini_mag20";
	} else if (player.m16mini_magazine == -1) {
			player.weaponname = "m16mini_none";
	} else {
			player.weaponname = "m16mini";
	}
}

void W_M16Mini_setclipsize(entity player) {
	//if (player.m16mini_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_m16mini_reload_ammoexm106;
	//} else
	if (player.m16mini_magazine == 1.5) {
		player.clip_size = autocvar_g_balance_m16mini_reload_ammobetacmag;
	//} else if (player.m16mini_magazine == 1) {
	//	player.clip_size = autocvar_g_balance_m16mini_reload_ammoexm50;
	//} else if (player.m16mini_magazine == 0.5) {
	//	player.clip_size = autocvar_g_balance_m16mini_reload_ammoexm40;
	//} else if (player.m16mini_magazine == -0.25) {
	//	player.clip_size = autocvar_g_balance_m16mini_reload_ammomag25;
	} else if (player.m16mini_magazine == -0.5) {
		player.clip_size = autocvar_g_balance_m16mini_reload_ammomag20;
	} else if (player.m16mini_magazine == -1) {
		player.clip_size = autocvar_g_balance_m16mini_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_m16mini_reload_ammo;
	}
}

void W_M16Mini_setrefunddown(entity player) {
	//if (player.m16mini_magazine == 2) {
	//	W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammoexm106);
	//} else
	if (player.m16mini_magazine == 1.5) {
		W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammobetacmag);
	//} else if (player.m16mini_magazine == 1) {
	//	W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammoexm50);
	//} else if (player.m16mini_magazine == 0.5) {
	//	W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammoexm40);
	//} else if (player.m16mini_magazine == -0.25) {
	//	W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammomag25);
	} else if (player.m16mini_magazine == -0.5) {
		W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammomag20);	
	} else if (player.m16mini_magazine == -1) {
		W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammonone);
	} else {
		W_M16Mini_refunddowntocustommag(player, autocvar_g_balance_m16mini_reload_ammo);
	}
}

float W_M16Mini_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_m16mini_mag30notincluded
	|| player.inv_misc_mag_m16_30)
	{
		return 0;
	//} else if (!autocvar_g_balance_m16mini_exmag40notincluded
	//|| player.inv_misc_exmag_m16_40)
	//{
	//	return 0.5;
	//} else if (!autocvar_g_balance_m16mini_exmag50notincluded
	//|| player.inv_misc_exmag_m16_50)
	//{
	//	return 1;
	} else if (!autocvar_g_balance_m16mini_betacmagnotincluded
	|| player.inv_misc_betacmag_m16)
	{
		return 1.5;
	//} else if (!autocvar_g_balance_m16mini_exmag106notincluded
	//|| player.inv_misc_exmag_m16_106)
	//{
	//	return 2;					
	//} else if (!autocvar_g_balance_m16mini_mag25notincluded
	//|| player.inv_misc_mag_m16_25)
	//{
	//	return (-0.25);					
	} else if (!autocvar_g_balance_m16mini_mag20notincluded
	|| player.inv_misc_mag_m16_20)
	{
		return (-0.50);					
	}
	
	return currentmagwant;
}

//

void spawnfunc_weapon_m16mini (void)
{
	weapon_defaultspawnfunc(WEP_M16MINI);
}

//

void w_m16mini_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.m16mini_magazine == 2) {
	//	myself.model = "models/weapons/g_m16mini_exm106.md3";
	//	
	//	if (autocvar_g_balance_m16mini_exmag106notincluded
	//	&& player.inv_misc_exmag_m16_106 >= 1) {
	//		player.inv_misc_exmag_m16_106 = player.inv_misc_exmag_m16_106 - 1;
	//		myself.inv_misc_exmag_m16_106 = myself.inv_misc_exmag_m16_106 + 1;
	//	}
	//	
	//	myself.m16mini_gsetmagazine = player.m16mini_magazine;
	//} else
	if (player.m16mini_magazine == 1.5) {
		myself.model = "models/weapons/g_m16mini_betacmag.md3";
		
		if (autocvar_g_balance_m16mini_betacmagnotincluded
		&& player.inv_misc_betacmag_m16 >= 1) {
			player.inv_misc_betacmag_m16 = player.inv_misc_betacmag_m16 - 1;
			myself.inv_misc_betacmag_m16 = myself.inv_misc_betacmag_m16 + 1;
		}
		
		myself.m16mini_gsetmagazine = player.m16mini_magazine;
	//} else if (player.m16mini_magazine == 1) {
	//	myself.model = "models/weapons/g_m16mini_exm50.md3";
	//	
	//	if (autocvar_g_balance_m16mini_exmag50notincluded
	//	&& player.inv_misc_exmag_m16_50 >= 1) {
	//		player.inv_misc_exmag_m16_50 = player.inv_misc_exmag_m16_50 - 1;
	//		myself.inv_misc_exmag_m16_50 = myself.inv_misc_exmag_m16_50 + 1;
	//	}
	//	myself.m16mini_gsetmagazine = player.m16mini_magazine;
	} else if (player.m16mini_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_m16mini.md3";
		
		if (autocvar_g_balance_m16mini_mag30notincluded
		&& player.inv_misc_mag_m16_30 >= 1) {
			player.inv_misc_mag_m16_30 = player.inv_misc_mag_m16_30 - 1;
			myself.inv_misc_mag_m16_30 = myself.inv_misc_mag_m16_30 + 1;
		}
		myself.m16mini_gsetmagazine = player.m16mini_magazine;
	//} else if (player.m16mini_magazine == -0.25) {
	//	myself.model = "models/weapons/g_m16mini_mag25.md3";
	//	
	//	if (autocvar_g_balance_m16mini_mag25notincluded
	//	&& player.inv_misc_mag_m16_25 >= 1) {
	//		player.inv_misc_mag_m16_25 = player.inv_misc_mag_m16_25 - 1;
	//		myself.inv_misc_mag_m16_25 = myself.inv_misc_mag_m16_25 + 1;
	//	}
	//	myself.m16mini_gsetmagazine = player.m16mini_magazine;
	} else if (player.m16mini_magazine == -0.5) {
		myself.model = "models/weapons/g_m16mini_mag20.md3";
		
		if (autocvar_g_balance_m16mini_mag20notincluded
		&& player.inv_misc_mag_m16_20 >= 1) {
			player.inv_misc_mag_m16_20 = player.inv_misc_mag_m16_20 - 1;
			myself.inv_misc_mag_m16_20 = myself.inv_misc_mag_m16_20 + 1;
		}
		myself.m16mini_gsetmagazine = player.m16mini_magazine;
	} else if (player.m16mini_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_m16mini_none.md3";
		
		myself.m16mini_gsetmagazine = player.m16mini_magazine;
	} else {
		//Do nothing
		myself.m16mini_gsetmagazine = 0;
	}
}

void w_m16mini_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_M16MINI) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.m16mini_magazine = myself.m16mini_gsetmagazine;
			player.m16mini_pickedupgsetmagazine = myself.m16mini_gsetmagazine;
		}
	}
}
//

.float m16mini_primarytime;

float w_m16mini(float req)
{
	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//Normally, secondary would be irrelevant here
				//(Being a selector switch)
				//However m16s are tempermental
				//when not handled exactly correctly
				//print(ftos(self.m16mini_overheat_cnt),"_Cooldown\n");
			
			if (self.m16mini_overheat_cnt < autocvar_g_balance_m16mini_heatmin) {
				self.m16mini_overheat_cnt = autocvar_g_balance_m16mini_heatmin;
			} else {
				self.m16mini_overheat_cnt = self.m16mini_overheat_cnt - (autocvar_g_balance_m16mini_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}

	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M16Mini_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m16mini_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.m16mini_setting != 1) {
			self.BUTTON_ATCK2 = 1;
			//Flip to full auto if bot
		} else {
		
			if (self.m16mini_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m16mini_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_M16Mini_NeedManualReload())
	{
		//
		//Make sure we're allowed to have.
		if (W_M16Mini_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_M16Mini_refunddowntostdmag(self);
			//print(ftos(self.m16mini_magazine), "Here222\n");
			//////self.m16mini_magazine = W_M16Mini_tryforvalidmag(self, self.m16mini_magazine);
			W_M16Mini_setclipsize(self);
			W_M16Mini_setrefunddown(self);
			W_M16Mini_setmodelforanim(self);
		}
		//
		
		if(autocvar_g_balance_m16mini_reload_ammo && self.clip_load < autocvar_g_balance_m16mini_primary_ammo) // forced reload
		{
			// don't force reload an empty m16mini if its melee attack is active
			if not(autocvar_g_balance_m16mini_secondary && self.ammo_nails < autocvar_g_balance_m16mini_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m16mini_release = 0;
		}
		else
		{
		  if (self.m16mini_jammed && self.m16mini_unjam)
		  {
		  	if (time >= self.m16mini_unjam_time) {
				self.m16mini_jammed = 0;
				self.m16mini_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.m16mini_release)
			if (self.m16mini_jammed != 1)
			if ((time > self.m16mini_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.m16mini_setting == 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m16mini_nextbot)," \n");
				} else {
					self.m16mini_nextbot = 0;
				}
				
				if (time >= self.m16mini_nextbot) {
					W_M16Mini_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m16mini_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m16mini_primary_animtime, w_ready);
					self.m16mini_release = 0;
					self.m16mini_animempty = 1;
					self.m16mini_animset = 1;
					self.m16mini_nextanim = time + autocvar_g_balance_m16mini_primary_rfanim;
					bp_skipme = 1;
					//self.m16mini_nextbot = time + (autocvar_g_balance_m16mini_primary_refire * 50 * random());
					self.m16mini_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.m16mini_release = 1;
					self.m16mini_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m16mini_nextbot)," \n");
				} else {
					self.m16mini_nextbot = 0;
				}
				
				if (time >= self.m16mini_nextbot) {
					W_M16Mini_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m16mini_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m16mini_secondary_animtime, w_ready);
					self.m16mini_release = 0;
					self.m16mini_animempty = 1;
					self.m16mini_animset = 1;
					self.m16mini_nextanim = time + autocvar_g_balance_m16mini_secondary_rfanim;
					bp_skipme = 1;
					//self.m16mini_nextbot = time + (autocvar_g_balance_m16mini_secondary_refire * 50 * random());
					self.m16mini_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.m16mini_release)
			if (self.m16mini_jammed != 1)
			if ((time > self.m16mini_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.m16mini_setting) {
					self.m16mini_setting = 0;
				} else {
					self.m16mini_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.m16mini_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.m16mini_jammed != 1)
				if (time >= self.m16mini_nextanim)
				if (self.m16mini_animempty)
				{
					self.m16mini_animempty = 0;
					self.m16mini_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m16mini_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.m16mini_animset)
			//if (self.m16mini_jammed != 1) {
			//	
			//		if (self.m16mini_animempty)
			//			self.weaponname = "m16mini_empty";
			//		else
			//			self.weaponname = "m16mini";
			//}
			
			self.m16mini_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_M16Mini_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_M16Mini_refunddowntostdmag(self);
			W_M16Mini_setclipsize(self);
			W_M16Mini_setrefunddown(self);
			W_M16Mini_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m16mini.md3");
		precache_model ("models/weapons/v_m16mini.md3");
		precache_model ("models/weapons/h_m16mini.iqm");
		
		precache_model ("models/weapons/g_m16mini_mag20.md3");
		precache_model ("models/weapons/v_m16mini_mag20.md3");
		precache_model ("models/weapons/h_m16mini_mag20.iqm");
		
		precache_model ("models/weapons/g_m16mini_betacmag.md3");
		precache_model ("models/weapons/v_m16mini_betacmag.md3");
		precache_model ("models/weapons/h_m16mini_betacmag.iqm");
		
		precache_model ("models/weapons/g_m16mini_none.md3");
		precache_model ("models/weapons/v_m16mini_none.md3");
		precache_model ("models/weapons/h_m16mini_none.iqm");
		
		
		//precache_model ("models/weapons/v_m16mini_empty.md3");
		//precache_model ("models/weapons/h_m16mini_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.m16mini_overheat_cnt = autocvar_g_balance_m16mini_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 0.02 -2.8';
		weapon_setup(WEP_M16MINI);
		self.current_ammo = ammo_nails;
		
		
			//if (self.m16mini_animempty)
			//	self.weaponname = "m16mini_empty";
			//else
			//	self.weaponname = "m16mini";
				
	          	//
		  	//Make sure we're allowed to have.
			W_M16Mini_allowedextendedmags(self);
			
			if (self.m16mini_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.m16mini_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 32 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.m16mini_magazine = W_M16Mini_tryforvalidmag(self, self.m16mini_magazine);
					W_M16Mini_allowedextendedmags(self);
				}
			}
			
			self.m16mini_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_M16Mini_setmodelforanim(self);
			//
	
		  

		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  //With the M16 we have set it so that if a malfunction (rather than a jam) occurs it is hard to clear
		  //Much fiddling
		  if (self.m16mini_jammed && self.m16mini_unjam)
		  {
		  	if (time >= self.m16mini_unjam_time) {
			if (random() > 0.9) {
				self.m16mini_jammed = 0;
				self.m16mini_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_M16Mini_setclipsize(self);
		W_M16Mini_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m16mini_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M16MINI]) >= autocvar_g_balance_m16mini_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m16mini_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m16mini_clearjam_time, w_ready);
			if (self.m16mini_unjam != 1) {
				self.m16mini_unjam = 1;
				self.m16mini_unjam_time = time + autocvar_g_balance_m16mini_clearjam_time;
				self.m16mini_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float m16minidonothing;
			m16minidonothing = 0;
			if (self.BUTTON_USE) {
			  if (self.m16mini_magazine_changetime >= time) {
			  	//Do nothing
				m16minidonothing = 1;
			  } else {
				local float m16minimagwant;
				if (self.m16mini_magazine == -0.5) {
					//m16minimagwant = -0.25;
					m16minimagwant = 0;
				//} else if (self.m16mini_magazine == -0.25) {
				//	m16minimagwant = 0;
				////} else if (self.m16mini_magazine == 0) {
				////	m16minimagwant = 0.5;
				//} else if (self.m16mini_magazine == 0.5) {
				//	m16minimagwant = 1;
				//} else if (self.m16mini_magazine == 1) {
				//	m16minimagwant = 1.5;
				} else if (self.m16mini_magazine == 1.5) {
					//m16minimagwant = 2;
					m16minimagwant = -0.5;	
				//} else if (self.m16mini_magazine == 2) {
				//	m16minimagwant = -0.5;	
				} else {
					////self.m16mini_magazine == 0
					//m16minimagwant = 0.5;
					m16minimagwant = 1.5;
				}
				
				if (m16minimagwant == -0.5) {
					if (!autocvar_g_balance_m16mini_mag20notincluded
			  		|| self.inv_misc_mag_m16_20)
			  		{
						//Yes
					} else {
						//No
							//m16minimagwant = -0.25; //fallback
							m16minimagwant = 0; //fallback
					}
				}
				
				//if (m16minimagwant == -0.25) {
				//	if (!autocvar_g_balance_m16mini_mag25notincluded
			  	//	|| self.inv_misc_mag_m16_25)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16minimagwant = 0; //fallback
				//	}
				//}
				
				//Where standard comes in
				//Keeping with the pattern
				if (m16minimagwant == 0) {
					if (!autocvar_g_balance_m16mini_mag30notincluded
			  		|| self.inv_misc_mag_m16_30)
			  		{
						//Yes
					} else {
						//No
							//m16minimagwant = 0.5; //fallback
							m16minimagwant = 1.5; //fallback
					}
				}
				
				////40 round exmag
				//if (m16minimagwant == 0.5) {
				//	if (!autocvar_g_balance_m16mini_exmag40notincluded
			  	//	|| self.inv_misc_exmag_m16_40)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16minimagwant = 1; //fallback
				//	}
				//}				
				
				//if (m16minimagwant == 1) {
				//	if (!autocvar_g_balance_m16mini_exmag50notincluded
			  	//	|| self.inv_misc_exmag_m16_50)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16minimagwant = 1.5; //fallback
				//	}
				//}				
				
				if (m16minimagwant == 1.5) {
					if (!autocvar_g_balance_m16mini_betacmagnotincluded
			  		|| self.inv_misc_betacmag_m16)
			  		{
						//Yes
					} else {
						//No
							//m16minimagwant = 2; //fallback
							m16minimagwant = -0.5; //fallback
					}
				}
				
				//if (m16minimagwant == 2) {
				//	if (!autocvar_g_balance_m16mini_exmag106notincluded
			  	//	|| self.inv_misc_exmag_m16_106)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16minimagwant = -0.5; //fallback
				//	}
				//}
				
				if (m16minimagwant == -0.5) {
					if (!autocvar_g_balance_m16mini_mag20notincluded
			  		|| self.inv_misc_mag_m16_20)
			  		{
						//Yes
					} else {
						//No
							//m16minimagwant = -0.25; //fallback
							m16minimagwant = 0; //fallback
					}
				}
				
				//if (m16minimagwant == -0.25) {
				//	if (!autocvar_g_balance_m16mini_mag25notincluded
			  	//	|| self.inv_misc_mag_m16_25)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16minimagwant = 0; //fallback
				//	}
				//}
				
				//If no magazines available...
				if (m16minimagwant == 0) {
					if (!autocvar_g_balance_m16mini_mag30notincluded
			  		|| self.inv_misc_mag_m16_30)
			  		{
						//Yes
					} else {
						//No
							m16minimagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (m16minimagwant == -1) {
					m16minimagwant = W_M16Mini_tryforvalidmag(self, m16minimagwant);
				}
				//Final decisions
				
				if (m16minimagwant == self.m16mini_magazine) {
					m16minidonothing = 1;
				//} else if (m16minimagwant == 2) {
				//	self.m16mini_magazine = 2;
				} else if (m16minimagwant == 1.5) {
					self.m16mini_magazine = 1.5;
				//} else if (m16minimagwant == 1) {
				//	self.m16mini_magazine = 1;
				//} else if (m16minimagwant == 0.5) {
				//	self.m16mini_magazine = 0.5;
				} else if (m16minimagwant == 0) {
					self.m16mini_magazine = 0;
				//} else if (m16minimagwant == -0.25) {
				//	self.m16mini_magazine = -0.25;
				} else if (m16minimagwant == -0.5) {
					self.m16mini_magazine = -0.5;
				} else if (m16minimagwant == -1) {
					self.m16mini_magazine = -1;
				}
				
				W_M16Mini_setmodelforanim(self);
			  }
			}
		
			if (m16minidonothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.m16mini_magazine == 2) {
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm106, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammoexm106);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm106, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	W_M16Mini_setclipsize(self);
			//	self.m16mini_magazine_changetime = time + self.reload_time;
			} else if (self.m16mini_magazine == 1.5) {
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammobetacmag, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				
				W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammobetacmag);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammobetacmag, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				W_M16Mini_setclipsize(self);
				self.m16mini_magazine_changetime = time + self.reload_time;
			//} else if (self.m16mini_magazine == 1) {
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm50, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammoexm50);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm50, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	W_M16Mini_setclipsize(self);
			//	self.m16mini_magazine_changetime = time + self.reload_time;
			//} else if (self.m16mini_magazine == 0.5) {
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm40, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammoexm40);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammoexm40, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	W_M16Mini_setclipsize(self);
			//	self.m16mini_magazine_changetime = time + self.reload_time;
			//} else if (self.m16mini_magazine == -0.25) {
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammomag25, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammomag25);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammomag25, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
			//	W_M16Mini_setclipsize(self);
			//	self.m16mini_magazine_changetime = time + self.reload_time;
			} else if (self.m16mini_magazine == -0.5) {
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammomag20, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				
				W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammomag20);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammomag20, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				W_M16Mini_setclipsize(self);
				self.m16mini_magazine_changetime = time + self.reload_time;
			
			} else if (self.m16mini_magazine == -1) {
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammonone, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_M16Mini_refunddowntocustommag(self, autocvar_g_balance_m16mini_reload_ammonone);
				
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammonone, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				W_M16Mini_setclipsize(self);
				self.m16mini_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammo, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_M16Mini_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammo, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
				W_M16Mini_setclipsize(self);
				self.m16mini_magazine_changetime = time + self.reload_time;
			}
		
			//////W_Reload(autocvar_g_balance_m16mini_primary_ammo, autocvar_g_balance_m16mini_reload_ammo, autocvar_g_balance_m16mini_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m16mini(float req)
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
			w_deathtypestring = _("%s recieved chest wounds from %s's M16 mini");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s sustained a head wound by %s's short M16");
		else
			w_deathtypestring = _("%s shot to death by %s with an shortened M16");
	}
	return TRUE;
}
#endif
#endif
