#ifdef REGISTER_WEAPON
REGISTER_WEAPON(STARBLAST, w_starblast, IT_CELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "starblast", "starblast", _("Starblast"));
#else
#ifdef SVQC
.float gravity;
.float starblast_release;

.entity starblast_subordinate;


void W_Starblast_Reset(void)
{
	remove(self);
}

void W_Starblast_Fadethink (void)
{
	remove(self);
}

void W_Starblast_Think(void)
{
	if (self.starblast_subordinate) {
		if (!self.starblast_subordinate.ammount2) {
			self.velocity = self.starblast_subordinate.velocity;
		}
		UpdateCSQCProjectile(self);
		//projthinkwait omitted, as we've done that allready to get here
		self.nextthink = time + autocvar_g_balance_starblast_primary_other_lifetime + autocvar_g_balance_starblast_primary_other_fadetime;
	} else {
		self.nextthink = time + autocvar_g_balance_starblast_primary_middle_lifetime + autocvar_g_balance_starblast_primary_middle_fadetime;
	}
	
	self.think = W_Starblast_Fadethink;
}

float W_Starblast_MaybeFade(entity e)
{
	//print(etos(e), "\n");
	if (e == world
	|| e.classname == "building"
	|| e.classname == "tree"
	|| e.classname == "bush"
	|| e.accptlikebuilding) {
		return FALSE;
	}
	
	return TRUE;
}

void W_Starbast_InitFadeNow(entity e, float myfaderate)
{
	e.think = W_Starblast_Fadethink;
	if (e.nextthink > (time + myfaderate)) {
		e.nextthink = time + myfaderate;
		e.fade_time = time + myfaderate;
		e.fade_rate = 1 / (myfaderate);
	}
}

// NO bounce protection, as bounces are limited!
void W_Starblast_Touch (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;
	
	self.ammount2 = 1; //If this is set on center projectile, the other projectiles won't change velocity to it when they pass the spreadtime

	float a;
	a = bound(0, 1 - (time - self.fade_time) * self.fade_rate, 1);

	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = autocvar_g_balance_starblast_primary_bouncedamagefactor;
	if(a)
		f *= a;

	RadiusDamage(self, self.realowner, autocvar_g_balance_starblast_primary_damage * f, autocvar_g_balance_starblast_primary_edgedamage * f, autocvar_g_balance_starblast_primary_radius, world, autocvar_g_balance_starblast_primary_force * f, self.projectiledeathtype, other);
	
	
	if(finalhit)
	{
		Chemical_flash_maybe(self);
		if (autocvar_g_balance_starblast_primary_notouchremove) {
			//Do nothing
			self.solid = SOLID_NOT;
			self.velocity = '0 0 0';
			if (W_Starblast_MaybeFade(other)) {
				W_Starbast_InitFadeNow(self, (1.2*random()));
			}
			UpdateCSQCProjectile(self);
		} else {
			remove(self);
		}
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_STARBLAST, TRUE);
	
	UpdateCSQCProjectile(self);
}

void W_Starblast_Touch2 (void)
{
	float finalhit;
	float f;
	PROJECTILE_TOUCH;

	float a;
	a = bound(0, 1 - (time - self.fade_time) * self.fade_rate, 1);

	finalhit = ((self.cnt <= 0) || (other.takedamage != DAMAGE_NO));
	if(finalhit)
		f = 1;
	else
		f = autocvar_g_balance_starblast_secondary_bouncedamagefactor;
	if(a)
		f *= a;

	RadiusDamage(self, self.realowner, autocvar_g_balance_starblast_secondary_damage * f, autocvar_g_balance_starblast_secondary_edgedamage * f, autocvar_g_balance_starblast_secondary_radius, world, autocvar_g_balance_starblast_secondary_force * f, self.projectiledeathtype, other);
		
	
	if(finalhit)
	{
		Chemical_flash_maybe(self);
		if (autocvar_g_balance_starblast_secondary_notouchremove) {
			//Do nothing
			self.solid = SOLID_NOT;
			self.velocity = '0 0 0';
			if (W_Starblast_MaybeFade(other)) {
				W_Starbast_InitFadeNow(self, (1.2*random()));
			}
			UpdateCSQCProjectile(self);
		} else {
			remove(self);
		}
		return;
	}
	self.cnt = self.cnt - 1;
	self.angles = vectoangles(self.velocity);
	self.owner = world;
	self.projectiledeathtype |= HITTYPE_BOUNCE;
	// commented out as it causes a little hitch...
	//if(proj.cnt == 0)
	//	CSQCProjectile(proj, TRUE, PROJECTILE_STARBLAST, TRUE);
	
	UpdateCSQCProjectile(self);
}

void W_Starblast_Attack (void)
{
	float counter, shots, projthinkwait;
	entity proj, player;
	vector s;
	vector forward, right, up;
	float maxdmg;
	player = self;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_starblast_primary_ammo, autocvar_g_balance_starblast_reload_ammo);

	maxdmg = autocvar_g_balance_starblast_primary_damage*autocvar_g_balance_starblast_primary_shots;
	maxdmg *= 1 + autocvar_g_balance_starblast_primary_bouncedamagefactor * autocvar_g_balance_starblast_primary_bounces;
	
	//W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	//Silent:
	W_SetupShot (self, FALSE, 2, "", CH_WEAPON_A, maxdmg);

	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_balance_starblast_primary_shots;
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.ammount2 = 0; //Once we touch() something we set this to 1.
		proj.reset = W_Starblast_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "starblastbolt";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_starblast_primary_damage;
		
		if (autocvar_g_balance_starblast_primary_bounces) {
			proj.movetype = MOVETYPE_BOUNCEMISSILE;
		} else {
			proj.movetype = MOVETYPE_FLYMISSILE;
		}
		
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_STARBLAST;
		//proj.gravity = 0.001;

		setsize(proj, '0 0 0', '0 0 0');


		s = '0 0 0';
		if (counter == 0) {
			setorigin (proj, w_shotorg);
			s = '0 0 0';
			s = s * autocvar_g_balance_starblast_primary_spread * g_weaponspreadfactor;
			player.starblast_subordinate = proj;
		}
		else
		{
			//makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));

			local float modc, minmmc;
			local vector f_diff;
			f_diff = '0 0 0';
			modc = mod(counter, 8); //modc = counter % 8;
			
			if (modc == 1) {
					//print("1\n");
				makevectors('0 90 0');
			} else if (modc == 2) {
					//print("2\n");
				makevectors('0 180 0');
			} else if (modc == 3) {
					//print("3\n");
				makevectors('0 270 0');
			} else if (modc == 4) {
					//print("4\n");
				makevectors('0 360 0');
			} else if (modc == 5) {
					//print("5\n");
				makevectors('0 45 0');
				f_diff = '4 4 0';
			} else if (modc == 6) {
					//print("6\n");
				makevectors('0 135 0');
				f_diff = '4 -4 0';
			} else if (modc == 7) {
					//print("7\n");
				makevectors('0 225 0');
				f_diff = '-4 -4 0';
			} else {
					//print("8\n");
				makevectors('0 315 0');
				f_diff = '-4 4 0';
			}
			w_shotorg += f_diff;
			setorigin (proj, w_shotorg);
			
			minmmc = floor((counter-1)/8);
			minmmc = minmmc + 1;
			
			s_y = v_forward_x;
			s_z = v_forward_y;
			
			s = s * autocvar_g_balance_starblast_primary_spread * g_weaponspreadfactor;
			if (minmmc > 1) {
				s = s * (1 + (minmmc*0.25));
			}
			if (modc != 1 &&
			modc != 2 &&
			modc != 3 &&
			modc != 4) {
				s = s * (1 + (minmmc*0.25));
			}
			
			proj.starblast_subordinate = player.starblast_subordinate;
			
		}
		W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, autocvar_g_balance_starblast_primary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Starblast_Touch;

		proj.think = W_Starblast_Think;
		
		projthinkwait = autocvar_g_balance_starblast_primary_spreadtime;
		if(counter == 0)
		{
			proj.fade_time = time + projthinkwait + autocvar_g_balance_starblast_primary_middle_lifetime;
			proj.fade_rate = 1 / (projthinkwait + autocvar_g_balance_starblast_primary_middle_fadetime);
			proj.nextthink = time + projthinkwait;
		}
		else
		{
			proj.fade_time = time + projthinkwait + autocvar_g_balance_starblast_primary_other_lifetime;
			proj.fade_rate = 1 / (projthinkwait + autocvar_g_balance_starblast_primary_other_fadetime);
			proj.nextthink = time + projthinkwait;
		}
		proj.teleport_time = time + autocvar_g_balance_starblast_primary_joindelay;
		proj.cnt = autocvar_g_balance_starblast_primary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_STARBLAST_BOUNCING : PROJECTILE_STARBLAST), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
}

void W_Starblast_Attack2 (void)
{
	float counter, shots;
	entity proj;
	vector s;
	vector forward, right, up;
	float maxdmg;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_starblast_secondary_ammo, autocvar_g_balance_starblast_reload_ammo);

	maxdmg = autocvar_g_balance_starblast_secondary_damage*autocvar_g_balance_starblast_secondary_shots;
	maxdmg *= 1 + autocvar_g_balance_starblast_secondary_bouncedamagefactor * autocvar_g_balance_starblast_secondary_bounces;
	
	//W_SetupShot (self, FALSE, 2, "weapons/crylink_fire2.wav", CH_WEAPON_A, maxdmg);
	//Silent:
	W_SetupShot (self, FALSE, 2, "", CH_WEAPON_A, maxdmg);

	forward = v_forward;
	right = v_right;
	up = v_up;

	shots = autocvar_g_balance_starblast_secondary_shots;
	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, shots);
	proj = world;
	for(counter = 0; counter < shots; ++counter)
	{
		proj = spawn ();
		proj.reset = W_Starblast_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "starblastbolt";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_starblast_secondary_damage;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_STARBLAST | HITTYPE_SECONDARY;
		//proj.gravity = 0.001;

		setorigin (proj, w_shotorg);
		setsize(proj, '0 0 0', '0 0 0');

		if(autocvar_g_balance_starblast_secondary_spreadtype == 1)
		{
			s = '0 0 0';
			if (counter == 0)
				s = '0 0 0';
			else
			{
				makevectors('0 360 0' * (0.75 + (counter - 0.5) / (shots - 1)));
				s_y = v_forward_x;
				s_z = v_forward_y;
			}
			s = s * autocvar_g_balance_starblast_secondary_spread * g_weaponspreadfactor;
			s = w_shotdir + right * s_y + up * s_z;
		}
		else
		{
			if (self.shootfromside == 1) {
				s = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_up * autocvar_g_balance_starblast_secondary_spread * g_weaponspreadfactor);
			} else {
				//Normal
				s = (w_shotdir + (((counter + 0.5) / shots) * 2 - 1) * v_right * autocvar_g_balance_starblast_secondary_spread * g_weaponspreadfactor);
			}
		}

		W_SetupProjectileVelocityEx(proj, s, v_up, autocvar_g_balance_starblast_secondary_speed, 0, 0, 0, FALSE);
		proj.touch = W_Starblast_Touch2;
		proj.think = W_Starblast_Fadethink;
		if(counter == (shots - 1) / 2)
		{
			proj.fade_time = time + autocvar_g_balance_starblast_secondary_middle_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_starblast_secondary_middle_fadetime;
			proj.nextthink = time + autocvar_g_balance_starblast_secondary_middle_lifetime + autocvar_g_balance_starblast_secondary_middle_fadetime;
		}
		else
		{
			proj.fade_time = time + autocvar_g_balance_starblast_secondary_line_lifetime;
			proj.fade_rate = 1 / autocvar_g_balance_starblast_secondary_line_fadetime;
			proj.nextthink = time + autocvar_g_balance_starblast_secondary_line_lifetime + autocvar_g_balance_starblast_secondary_line_fadetime;
		}
		proj.teleport_time = time + autocvar_g_balance_starblast_secondary_joindelay;
		proj.cnt = autocvar_g_balance_starblast_secondary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
        proj.missile_flags = MIF_SPLASH;
        
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_STARBLAST_BOUNCING : PROJECTILE_STARBLAST), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
	}
}

float W_Starblast_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_starblast_reload_ammo && self.clip_load < min(autocvar_g_balance_starblast_primary_ammo, autocvar_g_balance_starblast_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_starblast (void)
{
	weapon_defaultspawnfunc(WEP_STARBLAST);
}

float w_starblast(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Starblast_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;

		if (self.starblast_release) {
			if (random() < 0.40)
				self.BUTTON_ATCK = bot_aim(autocvar_g_balance_starblast_primary_speed, 0, autocvar_g_balance_starblast_primary_middle_lifetime, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(autocvar_g_balance_starblast_secondary_speed, 0, autocvar_g_balance_starblast_secondary_middle_lifetime, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Starblast_NeedManualReload())
	{
		if(autocvar_g_balance_starblast_reload_ammo && self.clip_load < min(autocvar_g_balance_starblast_primary_ammo, autocvar_g_balance_starblast_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		if (self.BUTTON_ATCK)
		{
			if (self.starblast_release) {
				if (weapon_prepareattack(0, autocvar_g_balance_starblast_primary_refire))
				{
					W_Starblast_Attack();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_starblast_primary_animtime, w_ready);
					self.starblast_release = 0; //Semi auto
				}
			}
		}
		else if(self.BUTTON_ATCK2 && autocvar_g_balance_starblast_secondary)
		{
			if (self.starblast_release) {
				if (weapon_prepareattack(1, autocvar_g_balance_starblast_secondary_refire))
				{
					W_Starblast_Attack2();
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_starblast_secondary_animtime, w_ready);
					self.starblast_release = 0; //Semi auto
				}
			}
		} else if (!self.BUTTON_ATCK && !self.BUTTON_ATCK2) {
			self.starblast_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_starblast.md3");
		precache_model ("models/weapons/v_starblast.md3");
		precache_model ("models/weapons/h_starblast.iqm");
		//We're silent like the sunbeam
		//precache_sound ("weapons/crylink_fire.wav");
		//precache_sound ("weapons/crylink_fire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_STARBLAST);
		self.current_ammo = ammo_cells;
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 1 -5.2';
		//self.weaponaltaim = '45 -0.2 -8.25';
		//self.weaponaltaim = '45 1 -7.25';
		//self.weaponaltaim = '45 -0.5 -7';
		self.weaponaltaim = '50 -0.7 -7';
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_starblast_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_STARBLAST]) >= autocvar_g_balance_starblast_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_starblast_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_STARBLAST]) >= autocvar_g_balance_starblast_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_starblast_primary_ammo, autocvar_g_balance_starblast_secondary_ammo), autocvar_g_balance_starblast_reload_ammo, autocvar_g_balance_starblast_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_starblast(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("TE_SUPERSPIKE"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
		}
		else
		{
			pointparticles(particleeffectnum("TE_SUPERSPIKE"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/crylink_impact2.wav");
		precache_sound("weapons/crylink_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = _("%s succeeded at self-destructing themself with the Starblast");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = _("%s could not hide from %s's Starblast"); // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s was too close to %s's Starblast"); // unchecked: SECONDARY
		else
			w_deathtypestring = _("%s took a close look at %s's Starblast"); // unchecked: SECONDARY
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_starblast (void)
//{
//	weapon_defaultspawnfunc(WEP_STARBLAST);
//}
