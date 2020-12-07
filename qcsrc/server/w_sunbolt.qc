#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SUNBOLT, w_sunbolt, IT_CELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "sunbolt", "sunbolt", _("Sunbolt"));
#else
#ifdef SVQC
.float gravity;
.float sunbolt_release;

.float sunbolt_subordinate_time;


void W_Sunbolt_SteerThink(entity e, float spd)
{
	vector desireddir, olddir, newdir, eorg;
	float turnrate;
	float dist;
	
	if (e != world)
	{
		eorg            = 0.5 * (e.absmin + e.absmax);
		turnrate        = autocvar_g_balance_sunbolt_primary_turnrate; // how fast to turn
		desireddir      = normalize(eorg - self.origin);
		olddir          = normalize(self.velocity); // get my current direction
		dist            = vlen(eorg - self.origin);
		
		newdir = normalize(olddir + desireddir * turnrate); // take the average of the 2 directions; not the best method but simple & easy
		self.velocity = newdir * spd; // make me fly in the new direction at my flight speed
		
		UpdateCSQCProjectile(self);
	}
}



void W_Sunbolt_FollowThink(void)
{
	//Otherwise they swarm
	if (self.realowner.sunburst_subordinate && self.realowner.sunburst_subordinate != world) {
		if not(W_Sunburst_MaybeMakeEnemy(self.realowner.sunburst_subordinate)) {
			if (self.realowner) self.realowner.sunburst_subordinate = world;
		}
	}
		
	if (self.realowner.weapon != WEP_SUNBOLT
	|| self.realowner.deadflag != DEAD_NO
	|| (!(self.realowner.health > 0))
	) {
		if (self.realowner) self.realowner.sunburst_subordinate = world;
		self.think = W_Starblast_Fadethink;
		self.nextthink = self.ammount;
	} else if (time > self.ammount) {
		self.think = W_Starblast_Fadethink;
		self.nextthink = time;
	} else if (self.realowner.sunburst_subordinate) {
		W_Sunbolt_SteerThink(self.realowner.sunburst_subordinate, autocvar_g_balance_sunbolt_primary_speed);
		self.nextthink = time;
	} else {
		self.think = W_Starblast_Fadethink;
		self.nextthink = self.ammount;
	}
	UpdateCSQCProjectile(self);	
}

void W_Sunbolt_Think(void)
{
	if (self.realowner.sunburst_subordinate) {
		self.think = W_Sunbolt_FollowThink;
		self.nextthink = time;
	} else {
		self.think = W_Starblast_Fadethink;
		self.nextthink = self.ammount;
	}
}

void W_Sunbolt_Attack (void)
{
	float projthinkwait;
	entity proj, player;
	vector forward, right, up;
	float maxdmg, spread;
	player = self;

	W_DecreaseAmmo(ammo_cells, autocvar_g_balance_sunbolt_primary_ammo, autocvar_g_balance_sunbolt_reload_ammo);

	maxdmg = autocvar_g_balance_sunburst_primary_damage;
	maxdmg *= 1 + autocvar_g_balance_sunbolt_primary_bouncedamagefactor * autocvar_g_balance_sunbolt_primary_bounces;
	
	//W_SetupShot (self, FALSE, 2, "weapons/crylink_fire.wav", CH_WEAPON_A, maxdmg);
	//Silent:
	W_SetupShot (self, FALSE, 2, "", CH_WEAPON_A, maxdmg);

	forward = v_forward;
	right = v_right;
	up = v_up;

	pointparticles(particleeffectnum("uzi_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);
	proj = world;
	
	
		proj = spawn ();
		proj.reset = W_Starblast_Reset;
		proj.realowner = proj.owner = self;
		proj.classname = "sunboltbolt";
		proj.bot_dodge = TRUE;
		proj.bot_dodgerating = autocvar_g_balance_sunburst_primary_damage;

		proj.movetype = MOVETYPE_BOUNCEMISSILE;
		PROJECTILE_MAKETRIGGER(proj);
		proj.projectiledeathtype = WEP_SUNBOLT;
		//proj.gravity = 0.001;

		setsize(proj, '0 0 0', '0 0 0');


		setorigin (proj, w_shotorg);
		spread = autocvar_g_balance_sunbolt_primary_spread * g_weaponspreadfactor;

		//W_SetupProjectileVelocityEx(proj, w_shotdir + right * s_y + up * s_z, v_up, autocvar_g_balance_sunbolt_primary_speed, 0, 0, 0, FALSE);
		W_SetupProjectileVelocity(proj, autocvar_g_balance_sunbolt_primary_speed, spread);
		proj.touch = W_Sunburst_Touch;

		proj.think = W_Sunbolt_Think;
		
		projthinkwait = autocvar_g_balance_sunbolt_primary_spreadtime;
		
			proj.fade_time = time + projthinkwait + autocvar_g_balance_sunbolt_primary_middle_lifetime;
			proj.fade_rate = 1 / (projthinkwait + autocvar_g_balance_sunbolt_primary_middle_fadetime);
			proj.nextthink = time + projthinkwait;
			proj.ammount = proj.fade_time;
		
		proj.teleport_time = time + autocvar_g_balance_sunbolt_primary_joindelay;
		proj.cnt = autocvar_g_balance_sunbolt_primary_bounces;
		//proj.scale = 1 + 1 * proj.cnt;

		proj.angles = vectoangles (proj.velocity);

		//proj.glow_size = 20;

		proj.flags = FL_PROJECTILE;
    proj.missile_flags = MIF_SPLASH;
    
		CSQCProjectile(proj, TRUE, (proj.cnt ? PROJECTILE_STARBLAST_BOUNCING : PROJECTILE_STARBLAST), TRUE);

		other = proj; MUTATOR_CALLHOOK(EditProjectile);
}

float W_Sunbolt_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_sunbolt_reload_ammo && self.clip_load < min(autocvar_g_balance_sunbolt_primary_ammo, autocvar_g_balance_sunbolt_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_sunbolt (void)
{
	weapon_defaultspawnfunc(WEP_SUNBOLT);
}

float w_sunbolt(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Sunbolt_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if (self.sunburst_subordinate) {
			self.BUTTON_ATCK = bot_aim(autocvar_g_balance_sunbolt_primary_speed, 0, autocvar_g_balance_sunbolt_primary_middle_lifetime, FALSE);
			
			if not (self.BUTTON_ATCK) {
				//print("keep shooting anyway\n");
				if (random() > 0.05) {
					self.BUTTON_ATCK = 1; //Keep shooting anyway, since they'll home in
				}
			}
		} else {
			self.BUTTON_ATCK=FALSE;
			self.BUTTON_ATCK2=FALSE;

			if (self.sunbolt_release) {
					self.BUTTON_ATCK = bot_aim(autocvar_g_balance_sunbolt_primary_speed, 0, autocvar_g_balance_sunbolt_primary_middle_lifetime, FALSE);
			}
		}
	}
	else if (req == WR_THINK && !W_Sunbolt_NeedManualReload())
	{
		if(autocvar_g_balance_sunbolt_reload_ammo && self.clip_load < min(autocvar_g_balance_sunbolt_primary_ammo, autocvar_g_balance_sunbolt_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		if (self.BUTTON_ATCK)
		{
			if (self.sunbolt_release) {
				if (weapon_prepareattack(0, autocvar_g_balance_sunbolt_primary_refire))
				{
					W_Sunbolt_Attack();
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_sunbolt_primary_animtime, w_ready);
					self.sunbolt_release = 0; //semi auto
					self.sunbolt_subordinate_time = time + autocvar_g_balance_sunbolt_primary_tracktime;
				}
			}
		} else {
			self.sunbolt_release = 1;
			if (time > self.sunbolt_subordinate_time) {
				self.sunburst_subordinate = world;
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_sunbolt.md3");
		precache_model ("models/weapons/v_sunbolt.md3");
		precache_model ("models/weapons/h_sunbolt.iqm");
		//We're silent like the sunbeam
		//precache_sound ("weapons/crylink_fire.wav");
		//precache_sound ("weapons/crylink_fire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_SUNBOLT);
		self.current_ammo = ammo_cells;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '40 -0.35 -2';
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_sunbolt_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SUNBOLT]) >= autocvar_g_balance_sunbolt_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		//ammo_amount = self.ammo_cells >= autocvar_g_balance_sunbolt_secondary_ammo;
		//ammo_amount += self.(weapon_load[WEP_SUNBOLT]) >= autocvar_g_balance_sunbolt_secondary_ammo;
		//return ammo_amount;
		return FALSE;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_sunbolt_primary_ammo, autocvar_g_balance_sunbolt_secondary_ammo), autocvar_g_balance_sunbolt_reload_ammo, autocvar_g_balance_sunbolt_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_sunbolt(float req)
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
		w_deathtypestring = _("%s succeeded at self-destructing themself with the Sunbolt");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = _("%s could not hide from %s's Sunbolt"); // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s was too close to %s's Sunbolt"); // unchecked: SECONDARY
		else
			w_deathtypestring = _("%s took a close look at %s's Sunbolt"); // unchecked: SECONDARY
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_sunbolt (void)
//{
//	weapon_defaultspawnfunc(WEP_SUNBOLT);
//}
