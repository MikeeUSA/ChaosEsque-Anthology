#ifdef REGISTER_WEAPON
REGISTER_WEAPON(M16VN, w_m16vn, IT_NAILS, 3, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_LOW, "m16vn", "m16vn", _("M16-Vn"))
#else
#ifdef SVQC

.float m16vn_release;
.float m16vn_jammed;
.float m16vn_unjam;
.float m16vn_unjam_time;
.float m16vn_click;
.float m16vn_animempty;
.float m16vn_animset;
.float m16vn_nextanim;
.float m16vn_nextbot;
.float m16vn_setting; //0 full auto //1 semi
.float m16vn_overheat_cnt;
.float m16vn_overheated_until;
.float m16vn_magazine; //0normal(32), 1 50rnd, 2 106rnd
.float m16vn_magazine_changetime;
.float m16vn_gsetmagazine; //For ground model setting propagation
.float m16vn_pickedupgsetmagazine; //set if player pickedup a gsetmagazine pickup


void W_M16Vn_Attack (void)
{
	float	ammoamount;
	float	d;
	float	f;
	float	spread;
	float	bulletspeed;
	float	bulletconstant;
	entity flash;

	ammoamount = autocvar_g_balance_m16vn_primary_ammo;
	d = autocvar_g_balance_m16vn_primary_damage;
	f = autocvar_g_balance_m16vn_primary_force;
	//spread = autocvar_g_balance_m16vn_primary_spread;
	spread = bound(autocvar_g_balance_m16vn_spread_min, autocvar_g_balance_m16vn_spread_min + (autocvar_g_balance_m16vn_spread_add * self.misc_bulletcounter), autocvar_g_balance_m16vn_spread_max);

	//print(ftos(spread), " spread\n");

	bulletspeed = autocvar_g_balance_m16vn_primary_speed;
	bulletconstant = autocvar_g_balance_projectile_223rifle_bulletconstant;

	W_DecreaseAmmo(ammo_nails, ammoamount, autocvar_g_balance_m16vn_reload_ammo);
	
	if (autocvar_g_balance_m16vn_jamrate &&
 	(autocvar_g_balance_m16vn_jamrate > random() ))
 	{
		if ((clienttype(self) == CLIENTTYPE_REAL)) {
			sprint(self, "Your assault rifle jammed\n");
		}
		self.m16vn_jammed = 1;
	} else { //Start Not Jammed


		W_SetupShot (self, autocvar_g_antilag_bullets && bulletspeed >= autocvar_g_antilag_bullets, 5, "weapons/ffsl_ar15_fire.wav", CH_WEAPON_A, d);
	
	W_MaybeShootFromEyeForAltAim(self); //shoot from the eye maybe if in alt aim so that shooting through windows works correctly when aiming
	
	fireBallisticBullet(w_shotorg, w_shotdir, spread, bulletspeed, 5, d, autocvar_g_balance_m16vn_primary_headshotaddeddamage, f, WEP_M16VN, PROJECTILE_BULLETRIFLE22, 1, bulletconstant, autocvar_g_balance_m16vn_primary_coreshotaddeddamage);
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

		pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, autocvar_g_balance_m16vn_primary_ammo);
	
		PlayerGunRise(self, autocvar_g_balance_m16vn_gunrise, random() * autocvar_g_balance_m16vn_gunrun);

		// muzzle flash for 1st person view
		flash = spawn();
		setmodel(flash, "models/uziflash.md3"); // precision set below
		flash.think = SUB_Remove;
		flash.nextthink = time + 0.06;
		flash.effects = EF_ADDITIVE | EF_FULLBRIGHT | EF_LOWPRECISION;
		W_AttachToShotorg(flash, '12 0 0');
	
	
	if (autocvar_g_casings >= 2)
		SpawnCasing (((random () * 50 + 50) * v_right) - (v_forward * (random () * 30 + 30)) - ((random () * -120 - 140) * v_up), 2, vectoangles(v_forward),'0 250 0', 100, 103, self);

	
	if not (autocvar_g_nosmallarmsoverheating) {
	    	//Overheating//
			//print(ftos(self.m16vn_overheat_cnt),"_Firing\n");
		
	    	self.m16vn_overheat_cnt = self.m16vn_overheat_cnt + autocvar_g_balance_m16vn_heatconstant;
         
	    	if (self.m16vn_overheat_cnt > random() )
 	    	{
			if ((clienttype(self) == CLIENTTYPE_REAL)) {
				sprint(self, "Your m16vn overheated\n");
			}
				
			self.m16vn_overheated_until = time + (autocvar_g_balance_m16vn_cooldownwait * (self.m16vn_overheat_cnt + 1));
	    	}
	    	//Overheating//
	}
	
	
	} //End Not Jammed
}


float W_M16Vn_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_m16vn_reload_ammo && self.clip_load < autocvar_g_balance_m16vn_primary_ammo))
	{
		if (!self.m16vn_click && (self.BUTTON_ATCK)) {
			spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.25, ATTN_NORM);
			self.m16vn_click = 1;
		}
		else if not(self.BUTTON_ATCK)
		{
			self.m16vn_click = 0;
		}
		return 1;
	} else {
		return 0;
	}
	
}

//
float W_M16Vn_allowedextendedmags(entity player) {
	local float stdmagfallback;
	stdmagfallback = 0;
				//if (player.m16vn_magazine == 2) {
				//	if (!autocvar_g_balance_m16vn_exmag106notincluded
			  	//	|| player.inv_misc_exmag_m16_106)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16vn_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else
				if (player.m16vn_magazine == 1.5) {
					if (!autocvar_g_balance_m16vn_betacmagnotincluded
			  		|| player.inv_misc_betacmag_m16)
			  		{
						return 1;
					} else {
						player.m16vn_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				//} else if (player.m16vn_magazine == 1) {
				//	if (!autocvar_g_balance_m16vn_exmag50notincluded
			  	//	|| player.inv_misc_exmag_m16_50)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16vn_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				//} else if (player.m16vn_magazine == 0.5) {
				//	if (!autocvar_g_balance_m16vn_exmag40notincluded
			  	//	|| player.inv_misc_exmag_m16_40)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16vn_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				} else if (player.m16vn_magazine == 0.3) {
					if (!autocvar_g_balance_m16vn_mag30notincluded
			  		|| player.inv_misc_mag_m16_30)
			  		{
						return 1;
					} else {
						player.m16vn_magazine = 0; //fallback
						stdmagfallback = 1;
					}
				//} else if (player.m16vn_magazine == 0.25) {
				//	if (!autocvar_g_balance_m16vn_mag25notincluded
			  	//	|| player.inv_misc_mag_m16_25)
			  	//	{
				//		return 1;
				//	} else {
				//		player.m16vn_magazine = 0; //fallback
				//		stdmagfallback = 1;
				//	}
				} else if (player.m16vn_magazine == -1) {
					return 1;
				}
				
				if (player.m16vn_magazine == 0) {
					if (!autocvar_g_balance_m16vn_mag20notincluded
			  		|| player.inv_misc_mag_m16_20)
			  		{
						if (!stdmagfallback) {
							return 1;
						}
					} else {
						player.m16vn_magazine = -1; //fallback
					}
				}
				
				return 0;
}

float W_M16Vn_refunddowntostdmag(entity player) {
	if(player.clip_load > autocvar_g_balance_m16vn_reload_ammo) {
		//print("refunding\n");
		local float mygivebackammo;
		mygivebackammo = player.clip_load - autocvar_g_balance_m16vn_reload_ammo;
		player.clip_load = autocvar_g_balance_m16vn_reload_ammo;
		player.ammo_nails = player.ammo_nails + mygivebackammo;
					
		return 1;
	}
				
	return 0;
}

float W_M16Vn_refunddowntocustommag(entity player, float myreloadammo) {
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

void W_M16Vn_setmodelforanim(entity player) {
	//No anim
	//if (player.m16vn_magazine == 2) {
	//		player.weaponname = "m16vn_exm106";
	//} else
	if (player.m16vn_magazine == 1.5) {
			player.weaponname = "m16vn_betacmag";
	//} else if (player.m16vn_magazine == 1) {
	//		player.weaponname = "m16vn_exm50";
	//} else if (player.m16vn_magazine == 0.5) {
	//		player.weaponname = "m16vn_exm40";
	} else if (player.m16vn_magazine == 0.3) {
			player.weaponname = "m16vn_mag30";
	//} else if (player.m16vn_magazine == 0.25) {
	//		player.weaponname = "m16vn_mag25";
	} else if (player.m16vn_magazine == -1) {
			player.weaponname = "m16vn_none";
	} else {
			player.weaponname = "m16vn";
	}
}

void W_M16Vn_setclipsize(entity player) {
	//if (player.m16vn_magazine == 2) {
	//	player.clip_size = autocvar_g_balance_m16vn_reload_ammoexm106;
	//} else
	if (player.m16vn_magazine == 1.5) {
		player.clip_size = autocvar_g_balance_m16vn_reload_ammobetacmag;
	//} else if (player.m16vn_magazine == 1) {
	//	player.clip_size = autocvar_g_balance_m16vn_reload_ammoexm50;
	//} else if (player.m16vn_magazine == 0.5) {
	//	player.clip_size = autocvar_g_balance_m16vn_reload_ammoexm40;
	} else if (player.m16vn_magazine == 0.3) {
		player.clip_size = autocvar_g_balance_m16vn_reload_ammomag30;
	//} else if (player.m16vn_magazine == 0.25) {
	//	player.clip_size = autocvar_g_balance_m16vn_reload_ammomag25;
	} else if (player.m16vn_magazine == -1) {
		player.clip_size = autocvar_g_balance_m16vn_reload_ammonone;
	} else {
		player.clip_size = autocvar_g_balance_m16vn_reload_ammo;
	}
}

void W_M16Vn_setrefunddown(entity player) {
	//if (player.m16vn_magazine == 2) {
	//	W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammoexm106);
	//} else
	if (player.m16vn_magazine == 1.5) {
		W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammobetacmag);
	//} else if (player.m16vn_magazine == 1) {
	//	W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammoexm50);
	//} else if (player.m16vn_magazine == 0.5) {
	//	W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammoexm40);
	} else if (player.m16vn_magazine == 0.3) {
		W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammomag30);
	//} else if (player.m16vn_magazine == 0.25) {
	//	W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammomag25);	
	} else if (player.m16vn_magazine == -1) {
		W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammonone);
	} else {
		W_M16Vn_refunddowntocustommag(player, autocvar_g_balance_m16vn_reload_ammo);
	}
}

float W_M16Vn_tryforvalidmag(entity player, float currentmagwant) {
	if (!autocvar_g_balance_m16vn_mag20notincluded
	|| player.inv_misc_mag_m16_20)
	{
		return 0;					
	//} else if (!autocvar_g_balance_m16vn_mag25notincluded
	//|| player.inv_misc_mag_m16_25)
	//{
	//	return 0.25;	
	} else if (!autocvar_g_balance_m16vn_mag30notincluded
	|| player.inv_misc_mag_m16_30)
	{
		return 0.3;
	//} else if (!autocvar_g_balance_m16vn_exmag40notincluded
	//|| player.inv_misc_exmag_m16_40)
	//{
	//	return 0.5;
	//} else if (!autocvar_g_balance_m16vn_exmag50notincluded
	//|| player.inv_misc_exmag_m16_50)
	//{
	//	return 1;
	} else if (!autocvar_g_balance_m16vn_betacmagnotincluded
	|| player.inv_misc_betacmag_m16)
	{
		return 1.5;
	//} else if (!autocvar_g_balance_m16vn_exmag106notincluded
	//|| player.inv_misc_exmag_m16_106)
	//{
	//	return 2;									
	}
	
	return currentmagwant;
}
//


void spawnfunc_weapon_m16vn (void)
{
	weapon_defaultspawnfunc(WEP_M16VN);
}

//

void w_m16vn_changedroppedgroundmodel (entity myself, entity player)
{
	//Set the dropped weapon model to non-default if needed, and some attributes, used in: t_items.qc StartItem() 
	//if (player.m16vn_magazine == 2) {
	//	myself.model = "models/weapons/g_m16vn_exm106.md3";
	//	
	//	if (autocvar_g_balance_m16vn_exmag106notincluded
	//	&& player.inv_misc_exmag_m16_106 >= 1) {
	//		player.inv_misc_exmag_m16_106 = player.inv_misc_exmag_m16_106 - 1;
	//		myself.inv_misc_exmag_m16_106 = myself.inv_misc_exmag_m16_106 + 1;
	//	}
	//	
	//	myself.m16vn_gsetmagazine = player.m16vn_magazine;
	//} else
	if (player.m16vn_magazine == 1.5) {
		myself.model = "models/weapons/g_m16vn_betacmag.md3";
		
		if (autocvar_g_balance_m16vn_betacmagnotincluded
		&& player.inv_misc_betacmag_m16 >= 1) {
			player.inv_misc_betacmag_m16 = player.inv_misc_betacmag_m16 - 1;
			myself.inv_misc_betacmag_m16 = myself.inv_misc_betacmag_m16 + 1;
		}
		
		myself.m16vn_gsetmagazine = player.m16vn_magazine;
	//} else if (player.m16vn_magazine == 1) {
	//	myself.model = "models/weapons/g_m16vn_exm50.md3";
	//	
	//	if (autocvar_g_balance_m16vn_exmag50notincluded
	//	&& player.inv_misc_exmag_m16_50 >= 1) {
	//		player.inv_misc_exmag_m16_50 = player.inv_misc_exmag_m16_50 - 1;
	//		myself.inv_misc_exmag_m16_50 = myself.inv_misc_exmag_m16_50 + 1;
	//	}
	//	myself.m16vn_gsetmagazine = player.m16vn_magazine;
	} else if (player.m16vn_magazine == 0.3) {
		myself.model = "models/weapons/g_m16vn_mag30.md3";
		
		if (autocvar_g_balance_m16vn_mag30notincluded
		&& player.inv_misc_mag_m16_30 >= 1) {
			player.inv_misc_mag_m16_30 = player.inv_misc_mag_m16_30 - 1;
			myself.inv_misc_mag_m16_30 = myself.inv_misc_mag_m16_30 + 1;
		}
		myself.m16vn_gsetmagazine = player.m16vn_magazine;
	//} else if (player.m16vn_magazine == 0.25) {
	//	myself.model = "models/weapons/g_m16vn_mag25.md3";
	//	
	//	if (autocvar_g_balance_m16vn_mag25notincluded
	//	&& player.inv_misc_mag_m16_25 >= 1) {
	//		player.inv_misc_mag_m16_25 = player.inv_misc_mag_m16_25 - 1;
	//		myself.inv_misc_mag_m16_25 = myself.inv_misc_mag_m16_25 + 1;
	//	}
	//	myself.m16vn_gsetmagazine = player.m16vn_magazine;
	} else if (player.m16vn_magazine == 0) {
		//Standard
		//////Allready set //myself.model = "models/weapons/g_m16vn.md3";
		
		if (autocvar_g_balance_m16vn_mag20notincluded
		&& player.inv_misc_mag_m16_20 >= 1) {
			player.inv_misc_mag_m16_20 = player.inv_misc_mag_m16_20 - 1;
			myself.inv_misc_mag_m16_20 = myself.inv_misc_mag_m16_20 + 1;
		}
		myself.m16vn_gsetmagazine = player.m16vn_magazine;
	} else if (player.m16vn_magazine == -1) {
		//No magazine
		myself.model = "models/weapons/g_m16vn_none.md3";
		
		myself.m16vn_gsetmagazine = player.m16vn_magazine;
	} else {
		//Do nothing
		myself.m16vn_gsetmagazine = 0;
	}
}

void w_m16vn_setwhenpickedup (entity myself, entity player, float allreadyhaveweapon)
{
	//Propagate the magazine used setting
	//Called in Item_Touch (void)
	if (player.weapon != WEP_M16VN) {
		if (allreadyhaveweapon) {
			//No settings change if we have the weapon
		} else {
			player.m16vn_magazine = myself.m16vn_gsetmagazine;
			player.m16vn_pickedupgsetmagazine = myself.m16vn_gsetmagazine;
		}
	}
}
//

.float m16vn_primarytime;

float w_m16vn(float req)
{

	if (!autocvar_g_nosmallarmsoverheating) {
	//Overheating and cooldown stuff://
		if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
				//Normally, secondary would be irrelevant here
				//(Being a selector switch)
				//However m16s are tempermental
				//when not handled exactly correctly
				//print(ftos(self.m16vn_overheat_cnt),"_Cooldown\n");
			
			if (self.m16vn_overheat_cnt < autocvar_g_balance_m16vn_heatmin) {
				self.m16vn_overheat_cnt = autocvar_g_balance_m16vn_heatmin;
			} else {
				self.m16vn_overheat_cnt = self.m16vn_overheat_cnt - (autocvar_g_balance_m16vn_cooldownrate * sys_frametime);
			}
		}
	//Overheating and cooldown stuff Done//
	}
	
	
	float ammo_amount;
	if (req == WR_AIM) {
		if (W_M16Vn_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.m16vn_jammed) {
			 weapon_action(self.weapon, WR_RELOAD);
		}
		
		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.m16vn_setting != 1) {
			self.BUTTON_ATCK2 = 1;
			//Flip to full auto if bot
		} else {
		
			if (self.m16vn_release) {
				if(autocvar_g_antilag_bullets)
					self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
				else
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_m16vn_primary_speed, 0, 0.001, FALSE);
			}
		}
		
	}
	else if (req == WR_THINK && !W_M16Vn_NeedManualReload())
	{
		//Make sure we're allowed to have.
		if (W_M16Vn_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_M16Vn_refunddowntostdmag(self);
			//print(ftos(self.m16vn_magazine), "Here222\n");
			//////self.m16vn_magazine = W_M16Vn_tryforvalidmag(self, self.m16vn_magazine);
			W_M16Vn_setclipsize(self);
			W_M16Vn_setrefunddown(self);
			W_M16Vn_setmodelforanim(self);
		}
		
		if(autocvar_g_balance_m16vn_reload_ammo && self.clip_load < autocvar_g_balance_m16vn_primary_ammo) // forced reload
		{
			// don't force reload an empty m16vn if its melee attack is active
			if not(autocvar_g_balance_m16vn_secondary && self.ammo_nails < autocvar_g_balance_m16vn_primary_ammo)
				weapon_action(self.weapon, WR_RELOAD);
				//self.m16vn_release = 0;
		}
		else
		{
		  if (self.m16vn_jammed && self.m16vn_unjam)
		  {
		  	if (time >= self.m16vn_unjam_time) {
				self.m16vn_jammed = 0;
				self.m16vn_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the jam\n");
				}
			}
		  } else {
			float bp_skipme;
			if (self.BUTTON_ATCK)
			if (self.m16vn_release)
			if (self.m16vn_jammed != 1)
			if ((time > self.m16vn_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
			  if (self.m16vn_setting == 1) {
			  	//Fullauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m16vn_nextbot)," \n");
				} else {
					self.m16vn_nextbot = 0;
				}
				
				if (time >= self.m16vn_nextbot) {
					W_M16Vn_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m16vn_primary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m16vn_primary_animtime, w_ready);
					self.m16vn_release = 0;
					self.m16vn_animempty = 1;
					self.m16vn_animset = 1;
					self.m16vn_nextanim = time + autocvar_g_balance_m16vn_primary_rfanim;
					bp_skipme = 1;
					//self.m16vn_nextbot = time + (autocvar_g_balance_m16vn_primary_refire * 50 * random());
					self.m16vn_nextbot = time + 0.1 + (0.4 * random());
					
					//Fullauto:
					self.m16vn_release = 1;
					self.m16vn_nextbot = time;
				}
			   } else {
				//Semiauto
				if(clienttype(self) == CLIENTTYPE_BOT) {
					//Nope
					//print("I bot", ftos(self.m16vn_nextbot)," \n");
				} else {
					self.m16vn_nextbot = 0;
				}
				
				if (time >= self.m16vn_nextbot) {
					W_M16Vn_Attack();
					ATTACK_FINISHED(self) = time + autocvar_g_balance_m16vn_secondary_refire * W_WeaponRateFactor();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_m16vn_secondary_animtime, w_ready);
					self.m16vn_release = 0;
					self.m16vn_animempty = 1;
					self.m16vn_animset = 1;
					self.m16vn_nextanim = time + autocvar_g_balance_m16vn_secondary_rfanim;
					bp_skipme = 1;
					//self.m16vn_nextbot = time + (autocvar_g_balance_m16vn_secondary_refire * 50 * random());
					self.m16vn_nextbot = time + 0.1 + (0.4 * random());
				}
			   }
			}
			
			if (self.BUTTON_ATCK2)
			if (self.m16vn_release)
			if (self.m16vn_jammed != 1)
			if ((time > self.m16vn_overheated_until) || autocvar_g_nosmallarmsoverheating)
			if (weapon_prepareattack_check(0, 0))
			{
				if(self.m16vn_setting) {
					self.m16vn_setting = 0;
				} else {
					self.m16vn_setting = 1;
				}
				spamsound (self, CH_SHOTS, "weapons/dryfire.wav", VOL_BASE * 0.20, ATTN_NORM);
				self.m16vn_release = 0;
			}
			
			if not(bp_skipme) {
				if (self.m16vn_jammed != 1)
				if (time >= self.m16vn_nextanim)
				if (self.m16vn_animempty)
				{
					self.m16vn_animempty = 0;
					self.m16vn_animset = 1;
				}
			}
			
			if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
				self.m16vn_release = 1;
			}
			
			if not(self.BUTTON_ATCK) {
				//Not full auto, reset bullet counter
				self.misc_bulletcounter = 0;
			}
				
			//if (self.m16vn_animset)
			//if (self.m16vn_jammed != 1) {
			//	
			//		if (self.m16vn_animempty)
			//			self.weaponname = "m16vn_empty";
			//		else
			//			self.weaponname = "m16vn";
			//}
			
			self.m16vn_animset = 0;
			bp_skipme = 0;
			////END NORMAL////
		  }
		}
		
	}
	else if (req == WR_THINK)
	{
		//Make sure we're allowed to have.
		if (W_M16Vn_allowedextendedmags(self)) {
			//Do nothing
		} else {	
			//////W_M16Vn_refunddowntostdmag(self);
			W_M16Vn_setclipsize(self);
			W_M16Vn_setrefunddown(self);
			W_M16Vn_setmodelforanim(self);
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/uziflash.md3");
		precache_model ("models/weapons/g_m16vn.md3");
		precache_model ("models/weapons/v_m16vn.md3");
		precache_model ("models/weapons/h_m16vn.iqm");
		
		precache_model ("models/weapons/g_m16vn_mag30.md3");
		precache_model ("models/weapons/v_m16vn_mag30.md3");
		precache_model ("models/weapons/h_m16vn_mag30.iqm");
		
		precache_model ("models/weapons/g_m16vn_betacmag.md3");
		precache_model ("models/weapons/v_m16vn_betacmag.md3");
		precache_model ("models/weapons/h_m16vn_betacmag.iqm");
		
		precache_model ("models/weapons/g_m16vn_none.md3");
		precache_model ("models/weapons/v_m16vn_none.md3");
		precache_model ("models/weapons/h_m16vn_none.iqm");
		
		//precache_model ("models/weapons/v_m16vn_empty.md3");
		//precache_model ("models/weapons/h_m16vn_empty.iqm");
		precache_sound ("misc/itempickup.wav");
		precache_sound ("weapons/ffsl_ar15_fire.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.m16vn_overheat_cnt = autocvar_g_balance_m16vn_heatmin;
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '43 0.02 -2.8';
		weapon_setup(WEP_M16VN);
		self.current_ammo = ammo_nails;
		
		
			//if (self.m16vn_animempty)
			//	self.weaponname = "m16vn_empty";
			//else
			//	self.weaponname = "m16vn";
			
			
			//
			//Make sure we're allowed to have.
			W_M16Vn_allowedextendedmags(self);
			
			if (self.m16vn_magazine == -1) {
				//-1 is "no magazine". If we have a magazine... maybe use it
				if (self.m16vn_pickedupgsetmagazine == -1) {
					//If we picked up a weapon that had -1 set as it's magazine, accept
				} else {
					//Otherwise if we are starting with this weapon, see if we can have a valid magazine
					//Example: standard 32 round mags not included, but you can use a different one that you have
					//access to at spawn
					self.m16vn_magazine = W_M16Vn_tryforvalidmag(self, self.m16vn_magazine);
					W_M16Vn_allowedextendedmags(self);
				}
			}
			
			self.m16vn_pickedupgsetmagazine = 0; //Now that the pickup has propagated Reset
			
			//Set correct model		
			W_M16Vn_setmodelforanim(self);
			//	
		  
		  //When a jam occurs when there is no ammo left, then one cannot reach the routine to unjam
		  //Thus is a "malfunction" and takes more to fix (switching weapon)
		  //With the M16 we have set it so that if a malfunction (rather than a jam) occurs it is hard to clear
		  if (self.m16vn_jammed && self.m16vn_unjam)
		  {
		  	if (time >= self.m16vn_unjam_time) {
			if (random() > 0.95) {
				self.m16vn_jammed = 0;
				self.m16vn_unjam = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You cleared the malfunction\n");
				}
			}
			}
		  }
	}
	else if (req == WR_CLIPSETUP)
	{
		W_M16Vn_setclipsize(self);
		W_M16Vn_setrefunddown(self);
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_m16vn_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_M16VN]) >= autocvar_g_balance_m16vn_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		// melee attack is always available
		return TRUE;
	}
	else if (req == WR_RELOAD)
	{
		if (self.m16vn_jammed) {
			weapon_thinkf(WFRAME_RELOAD, autocvar_g_balance_m16vn_clearjam_time, w_ready);
			if (self.m16vn_unjam != 1) {
				self.m16vn_unjam = 1;
				self.m16vn_unjam_time = time + autocvar_g_balance_m16vn_clearjam_time;
				self.m16vn_click = 0;
				if ((clienttype(self) == CLIENTTYPE_REAL)) {
					sprint(self, "You work on the weapon\n");
				}
			}
		} else {
			local float m16vndonothing;
			m16vndonothing = 0;
			if (self.BUTTON_USE) {
			  if (self.m16vn_magazine_changetime >= time) {
			  	//Do nothing
				m16vndonothing = 1;
			  } else {
				local float m16vnmagwant;
				//if (self.m16vn_magazine == 0.25) {
				//	m16vnmagwant = 0.3;
				//} else
				if (self.m16vn_magazine == 0.3) {
					//m16vnmagwant = 0.5;
					m16vnmagwant = 1.5;
				//} else if (self.m16vn_magazine == 0.5) {
				//	m16vnmagwant = 1;
				//} else if (self.m16vn_magazine == 1) {
				//	m16vnmagwant = 1.5;
				} else if (self.m16vn_magazine == 1.5) {
					//m16vnmagwant = 2;	
					m16vnmagwant = 0;
				//} else if (self.m16vn_magazine == 2) {
				//	m16vnmagwant = 0;	
				} else {
					//self.m16vn_magazine == 0
					//m16vnmagwant = 0.25;
					m16vnmagwant = 0.3;
				}
				
				//if (m16vnmagwant == 0.25) {
				//	if (!autocvar_g_balance_m16vn_mag25notincluded
			  	//	|| self.inv_misc_mag_m16_25)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16vnmagwant = 0.3; //fallback
				//	}
				//}
				
				if (m16vnmagwant == 0.3) {
					if (!autocvar_g_balance_m16vn_mag30notincluded
			  		|| self.inv_misc_mag_m16_30)
			  		{
						//Yes
					} else {
						//No
							//m16vnmagwant = 0.5; //fallback
							m16vnmagwant = 1.5; //fallback
					}
				}
				
				////40 round exmag
				//if (m16vnmagwant == 0.5) {
				//	if (!autocvar_g_balance_m16vn_exmag40notincluded
			  	//	|| self.inv_misc_exmag_m16_40)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16vnmagwant = 1; //fallback
				//	}
				//}				
				
				//if (m16vnmagwant == 1) {
				//	if (!autocvar_g_balance_m16vn_exmag50notincluded
			  	//	|| self.inv_misc_exmag_m16_50)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16vnmagwant = 1.5; //fallback
				//	}
				//}				
				
				if (m16vnmagwant == 1.5) {
					if (!autocvar_g_balance_m16vn_betacmagnotincluded
			  		|| self.inv_misc_betacmag_m16)
			  		{
						//Yes
					} else {
						//No
							//m16vnmagwant = 2; //fallback
							m16vnmagwant = 0; //fallback
					}
				}
				
				//if (m16vnmagwant == 2) {
				//	if (!autocvar_g_balance_m16vn_exmag106notincluded
			  	//	|| self.inv_misc_exmag_m16_106)
			  	//	{
				//		//Yes
				//	} else {
				//		//No
				//			m16vnmagwant = 0; //fallback
				//	}
				//}
				
				//If no magazines available...
				if (m16vnmagwant == 0) {
					if (!autocvar_g_balance_m16vn_mag20notincluded
			  		|| self.inv_misc_mag_m16_20)
			  		{
						//Yes
					} else {
						//No
							m16vnmagwant = -1; //fallback
					}
				}
				
				//If no mag, Try for valid magazine instead if have
				if (m16vnmagwant == -1) {
					m16vnmagwant = W_M16Vn_tryforvalidmag(self, m16vnmagwant);
				}
				//Final decisions
				
				if (m16vnmagwant == self.m16vn_magazine) {
					m16vndonothing = 1;
				//} else if (m16vnmagwant == 2) {
				//	self.m16vn_magazine = 2;
				} else if (m16vnmagwant == 1.5) {
					self.m16vn_magazine = 1.5;
				//} else if (m16vnmagwant == 1) {
				//	self.m16vn_magazine = 1;
				//} else if (m16vnmagwant == 0.5) {
				//	self.m16vn_magazine = 0.5;
				} else if (m16vnmagwant == 0.3) {
					self.m16vn_magazine = 0.3;
				//} else if (m16vnmagwant == 0.25) {
				//	self.m16vn_magazine = 0.25;
				} else if (m16vnmagwant == 0) {
					self.m16vn_magazine = 0;
				} else if (m16vnmagwant == -1) {
					self.m16vn_magazine = -1;
				}
				
				W_M16Vn_setmodelforanim(self);
			  }
			}
		
			if (m16vndonothing) {
				//print(ftos(time),"Doing nothing\n");
			//} else if (self.m16vn_magazine == 2) {
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm106, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammoexm106);
			//	//Normally no refund here since selection goes up
			//
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm106, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	W_M16Vn_setclipsize(self);
			//	self.m16vn_magazine_changetime = time + self.reload_time;
			} else if (self.m16vn_magazine == 1.5) {
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammobetacmag, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				
				W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammobetacmag);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammobetacmag, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				W_M16Vn_setclipsize(self);
				self.m16vn_magazine_changetime = time + self.reload_time;
			//} else if (self.m16vn_magazine == 1) {
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm50, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammoexm50);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm50, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	W_M16Vn_setclipsize(self);
			//	self.m16vn_magazine_changetime = time + self.reload_time;
			//} else if (self.m16vn_magazine == 0.5) {
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm40, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammoexm40);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammoexm40, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	W_M16Vn_setclipsize(self);
			//	self.m16vn_magazine_changetime = time + self.reload_time;
			//	
			} else if (self.m16vn_magazine == 0.3) {
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammomag30, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				
				W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammomag30);
				//Normally no refund here since selection goes up
				
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammomag30, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				W_M16Vn_setclipsize(self);
				self.m16vn_magazine_changetime = time + self.reload_time;
			
			//} else if (self.m16vn_magazine == 0.25) {
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammomag25, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	
			//	W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammomag25);
			//	//Normally no refund here since selection goes up
			//	
			//	W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammomag25, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
			//	W_M16Vn_setclipsize(self);
			//	self.m16vn_magazine_changetime = time + self.reload_time;
			//
			} else if (self.m16vn_magazine == -1) {
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammonone, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				
				W_M16Vn_refunddowntocustommag(self, autocvar_g_balance_m16vn_reload_ammonone);
				
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammonone, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				W_M16Vn_setclipsize(self);
				self.m16vn_magazine_changetime = time + self.reload_time;
			} else {
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammo, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				
				//print(ftos(self.clip_load),"clipload\n");
				//print(ftos(self.reload_ammo_amount),"reload_ammo_amount\n");
				W_M16Vn_refunddowntostdmag(self);
				
				W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammo, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
				W_M16Vn_setclipsize(self);
				self.m16vn_magazine_changetime = time + self.reload_time;
			}
			
			//////W_Reload(autocvar_g_balance_m16vn_primary_ammo, autocvar_g_balance_m16vn_reload_ammo, autocvar_g_balance_m16vn_reload_time, "weapons/reload.wav");
		}
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_m16vn(float req)
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
			w_deathtypestring = _("%s had .223 sized holes in the chest thanks to %s");
		else if(w_deathtype & HITTYPE_HEADSHOT)
			w_deathtypestring = _("%s was designated shot by %s's M16");
		else
			w_deathtypestring = _("%s shot dead by %s with an M16");
	}
	return TRUE;
}
#endif
#endif
