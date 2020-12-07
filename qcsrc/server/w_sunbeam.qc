#ifdef REGISTER_WEAPON
REGISTER_WEAPON(SUNBEAM, w_sunbeam, IT_CELLS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "sunbeam", "sunbeam", _("Sunbeam"));
#else
#ifdef SVQC
//.float gravity;
.float sunbeam_release;
.float sunbeam_attack_finished_single;
.float sunbeam_pulseduration;

.entity sunbeam_subordinate;
.entity sunbeam_mylazerenemy;

void sunbeam_pulse_laser_think(void);
void starlase_pulse_laser_think(void);

void sunbeam_pulse_laser_think(void) {
	if (time > self.ammount
	|| self.sunbeam_subordinate.weapon != WEP_SUNBEAM
	|| self.sunbeam_subordinate.deadflag != DEAD_NO
	|| (!(self.sunbeam_subordinate.health > 0))
	) {
		self.sunbeam_subordinate.sunbeam_mylazerenemy = world;
		entity myselflaser;
		myselflaser = self;
		self = world; //So whoever is pointing at us is pointing at world now (hopefully)
		remove(myselflaser);
	} else {
		misc_laser_think();
	}
}

float sunbeam_maybe_fire_laser(entity _gun, entity pilot,
				entity _vehic, vector _mycolormod, float _myalpha,
				float _myscale, float _mydynlight, float _mydamage,
				float _myduration, float firerequirementsment)
{
	local vector s;
	
	if(firerequirementsment)
	{
		makevectors(pilot.v_angle);
		W_SetupShot (pilot, TRUE, 0, "", CH_WEAPON_A, _mydamage);
		s = normalize(w_shotdir);
		s = vectoangles(s);
		s_x = s_x * -1;

		if (pilot.sunbeam_mylazerenemy == world || !pilot.sunbeam_mylazerenemy) {
			//vector v;
			entity mylaser;
			entity myoldself;
			myoldself = self;
			mylaser = spawn();
			self = mylaser;
			self.realowner = pilot;
			self.colormod = _mycolormod;
			self.alpha = _myalpha;
			self.scale = _myscale;
			self.modelscale = _mydynlight; //Dynlight
			
			
			self.origin = w_shotorg;
						
			self.angles = s;
			
			self.dmg = _mydamage;
			spawnfunc_misc_laser();
			if (_myduration) {
				self.ammount = time + _myduration;
				if (pilot.weapon == WEP_STARLASE) {
					self.think = starlase_pulse_laser_think;
				} else {
					self.think = sunbeam_pulse_laser_think;
				}
				self.sunbeam_subordinate = pilot;
			}
			self = myoldself;
			
			pilot.sunbeam_mylazerenemy = mylaser;
		} else {
			pilot.sunbeam_mylazerenemy.origin = w_shotorg;
			
			pilot.sunbeam_mylazerenemy.angles = s;
		}
		return 1;
	}
	else {
		entity myremovelaser;
		if(pilot.sunbeam_mylazerenemy) {
			myremovelaser = pilot.sunbeam_mylazerenemy;
			pilot.sunbeam_mylazerenemy = world;
			remove(myremovelaser);
		}
		return 0;
	}
}

void sunbeam_lasercannon_fire(entity mg_lasercannon, entity player, entity _gun, float attackbutton, float mydamage, vector mycolor, float mypulseduration, float mycost, float myrefire) 
{
	local vector oldvforward;
	local vector oldvup;
	local vector oldvright;
	
	oldvforward = v_forward;
	oldvforward = v_up;
	oldvforward = v_right;
	
	float myrequirementstofire;
    	myrequirementstofire = 0;
	
	if(attackbutton) {
		if(time > _gun.sunbeam_attack_finished_single || time < _gun.sunbeam_pulseduration) {
			if(player.ammo_cells >= mycost)
			{
					myrequirementstofire = 1;
			}
		}
	}
	
	if (sunbeam_maybe_fire_laser(_gun, player,
				mg_lasercannon, mycolor, 0.9,
				8, 2, mydamage,
				mypulseduration, myrequirementstofire))
	{
		if (time > _gun.sunbeam_attack_finished_single) {
			//mg_lasercannon.vehicle_ammo1 -= mycost;
			local entity myolderself;
			myolderself = self;
			self = player;
			W_DecreaseAmmo(ammo_cells, mycost, autocvar_g_balance_sunbeam_reload_ammo);
			self = myolderself;
			
			_gun.sunbeam_attack_finished_single = time + myrefire;
			_gun.sunbeam_pulseduration = time + mypulseduration; //Pulse duration;
		}
	}
	
	//Restore previous
	v_forward = oldvforward;
	v_up = oldvup;
	v_right = oldvright;
}

float W_Sunbeam_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_sunbeam_reload_ammo && self.clip_load < min(autocvar_g_balance_sunbeam_primary_ammo, autocvar_g_balance_sunbeam_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_sunbeam (void)
{
	weapon_defaultspawnfunc(WEP_SUNBEAM);
}

float w_sunbeam(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Sunbeam_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		
		if (self.sunbeam_release) {
			if (random() < 0.50)
				self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
			else
				self.BUTTON_ATCK2 = bot_aim(1000000, 0, 1, FALSE);
		} else {
			self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
		}
	}
	else if (req == WR_THINK && !W_Sunbeam_NeedManualReload())
	{
		if(autocvar_g_balance_sunbeam_reload_ammo && self.clip_load < min(autocvar_g_balance_sunbeam_primary_ammo, autocvar_g_balance_sunbeam_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		if (self.BUTTON_ATCK)
		{
			if (self.sunbeam_release)
			{
				sunbeam_lasercannon_fire(self, self, self.weaponentity, self.BUTTON_ATCK, autocvar_g_balance_sunbeam_primary_damage, '1 1 0.5', autocvar_g_balance_sunbeam_primary_lifetime, autocvar_g_balance_sunbeam_primary_ammo, autocvar_g_balance_sunbeam_primary_refire);
				if (weapon_prepareattack(0, autocvar_g_balance_sunbeam_primary_refire))
				{
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_sunbeam_primary_animtime, w_ready);
					self.sunbeam_release = 1; //If we want this to be semi auto, set to 0
				}
			}
		}
		else if(self.BUTTON_ATCK2 && autocvar_g_balance_sunbeam_secondary)
		{
			if (self.sunbeam_release)
			{
				sunbeam_lasercannon_fire(self, self, self.weaponentity, self.BUTTON_ATCK2, autocvar_g_balance_sunbeam_secondary_damage, '1 1 0.5', autocvar_g_balance_sunbeam_secondary_lifetime, autocvar_g_balance_sunbeam_secondary_ammo, autocvar_g_balance_sunbeam_secondary_refire);
				if (weapon_prepareattack(1, autocvar_g_balance_sunbeam_secondary_refire))
				{
					weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_sunbeam_secondary_animtime, w_ready);
					self.sunbeam_release = 1; //If we want this to be semi auto, set to 0
				}
			}
		} else {
			self.sunbeam_release = 1;
			sunbeam_lasercannon_fire(self, self, self.weaponentity, FALSE, autocvar_g_balance_sunbeam_primary_damage, '1 1 0.5', autocvar_g_balance_sunbeam_primary_lifetime, autocvar_g_balance_sunbeam_primary_ammo, autocvar_g_balance_sunbeam_primary_refire);

		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_sunbeam.md3");
		precache_model ("models/weapons/v_sunbeam.md3");
		precache_model ("models/weapons/h_sunbeam.iqm");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_SUNBEAM);
		self.current_ammo = ammo_cells;
		
		self.weaponaltaim_use = 1;
		//self.weaponaltaim = '40 0 -1.75';
		//self.weaponaltaim = '40 0 -3.75';
		//self.weaponaltaim = '40 1 -5.2';
		//self.weaponaltaim = '50 -0.5 -8.2';
		self.weaponaltaim = '50 -0.5 -10.2';
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_sunbeam_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_SUNBEAM]) >= autocvar_g_balance_sunbeam_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_sunbeam_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_SUNBEAM]) >= autocvar_g_balance_sunbeam_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_sunbeam_primary_ammo, autocvar_g_balance_sunbeam_secondary_ammo), autocvar_g_balance_sunbeam_reload_ammo, autocvar_g_balance_sunbeam_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_sunbeam(float req)
{
	//These effects are not used as the sunbeam emits a HURTLASER
	//But here for completion just incase...
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("newcrylink_impact"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
		}
		else
		{
			pointparticles(particleeffectnum("newcrylink_impactbig"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/crylink_impact.wav", VOL_BASE, ATTN_NORM);
		}
	}
	else if(req == WR_PRECACHE)
	{
		//
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = _("%s succeeded at self-destructing themself with the Sunbeam");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = _("%s could not hide from %s's Sunbeam"); // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s was too close to %s's Sunbeam"); // unchecked: SECONDARY
		else
			w_deathtypestring = _("%s took a close look at %s's Sunbeam"); // unchecked: SECONDARY
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_sunbeam (void)
//{
//	weapon_defaultspawnfunc(WEP_SUNBEAM);
//}
