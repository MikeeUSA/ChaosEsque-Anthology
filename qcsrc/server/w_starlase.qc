#ifdef REGISTER_WEAPON
REGISTER_WEAPON(STARLASE, w_starlase, IT_CELLS, 2, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "starlase", "starlase", _("Starlase"));
#else
#ifdef SVQC
.float gravity;
.float starlase_release;

.float starlase_attack_finished_single;
.float starlase_pulseduration;

.float starlase_nextfire_time;


void starlase_pulse_laser_think(void) {
	if (time > self.ammount
	|| self.sunbeam_subordinate.weapon != WEP_STARLASE
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

void starlase_lasercannon_fire(entity mg_lasercannon, entity player, entity _gun, float attackbutton, float mydamage, vector mycolor, float mypulseduration, float mycost, float myrefire) 
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
		if(time > _gun.starlase_attack_finished_single || time < _gun.starlase_pulseduration) {
			if(player.ammo_cells >= mycost)
			{
					myrequirementstofire = 1;
			}
		}
	}
	
	if (sunbeam_maybe_fire_laser(_gun, player,
				mg_lasercannon, mycolor, 0.9,
				2, 1, mydamage,
				mypulseduration, myrequirementstofire))
	{
		if (time > _gun.starlase_attack_finished_single) {
			//mg_lasercannon.vehicle_ammo1 -= mycost;
			local entity myolderself;
			myolderself = self;
			self = player;
			W_DecreaseAmmo(ammo_cells, mycost, autocvar_g_balance_starlase_reload_ammo);
			self = myolderself;
			
			_gun.starlase_attack_finished_single = time + myrefire;
			_gun.starlase_pulseduration = time + mypulseduration; //Pulse duration;
		}
	}
	
	//Restore previous
	v_forward = oldvforward;
	v_up = oldvup;
	v_right = oldvright;
}


float W_Starlase_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_starlase_reload_ammo && self.clip_load < min(autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}


void spawnfunc_weapon_starlase (void)
{
	weapon_defaultspawnfunc(WEP_STARLASE);
}

float w_starlase(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Starlase_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off
	
		self.BUTTON_ATCK2 = FALSE;
		self.BUTTON_ATCK = bot_aim(1000000, 0, 1, FALSE);
		
	}
	else if (req == WR_THINK && !W_Starlase_NeedManualReload())
	{
		if(autocvar_g_balance_starlase_reload_ammo && self.clip_load < min(autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);

		if (self.BUTTON_ATCK)
		{
			if (self.starlase_release > 0 && (time > self.starlase_nextfire_time)) {
				starlase_lasercannon_fire(self, self, self.weaponentity, self.BUTTON_ATCK, autocvar_g_balance_starlase_primary_damage, '1 1 0.5', autocvar_g_balance_starlase_primary_lifetime, autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_primary_refire);
				if (weapon_prepareattack(0, autocvar_g_balance_starlase_primary_refire))
				{
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_starlase_primary_animtime, w_ready);
					self.starlase_release = self.starlase_release - 1; //If we want this to be semi auto, set to 0
					if not(self.starlase_release > 0) {
						self.starlase_nextfire_time = time + autocvar_g_balance_starlase_primary_refire2;
					}
				}
			} else {
				starlase_lasercannon_fire(self, self, self.weaponentity, FALSE, autocvar_g_balance_starlase_primary_damage, '1 1 0.5', autocvar_g_balance_starlase_primary_lifetime, autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_primary_refire);	
			}
		} else {
			if (self.starlase_release != autocvar_g_balance_starlase_primary_shots) {
						self.starlase_nextfire_time = time + autocvar_g_balance_starlase_primary_refire2;
			}
			self.starlase_release = autocvar_g_balance_starlase_primary_shots;
			starlase_lasercannon_fire(self, self, self.weaponentity, FALSE, autocvar_g_balance_starlase_primary_damage, '1 1 0.5', autocvar_g_balance_starlase_primary_lifetime, autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_primary_refire);	
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_starlase.md3");
		precache_model ("models/weapons/v_starlase.md3");
		precache_model ("models/weapons/h_starlase.iqm");
		//We're silent like the sunbeam
		//precache_sound ("weapons/crylink_fire.wav");
		//precache_sound ("weapons/crylink_fire2.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_STARLASE);
		self.current_ammo = ammo_cells;
		
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '55 -0.75 -6';
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_starlase_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_STARLASE]) >= autocvar_g_balance_starlase_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		//ammo_amount = self.ammo_cells >= autocvar_g_balance_starlase_secondary_ammo;
		//ammo_amount += self.(weapon_load[WEP_STARLASE]) >= autocvar_g_balance_starlase_secondary_ammo;
		//return ammo_amount;
		return FALSE;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_starlase_primary_ammo, autocvar_g_balance_starlase_secondary_ammo), autocvar_g_balance_starlase_reload_ammo, autocvar_g_balance_starlase_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_starlase(float req)
{
	//These effects are not used as the starlase emits a HURTLASER
	//But here for completion just incase...
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 2;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("TE_SUPERSPIKE"), org2, '0 0 0', 1);
			//if(!w_issilent)
			//	sound(self, CH_SHOTS, "weapons/crylink_impact2.wav", VOL_BASE, ATTN_NORM);
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
		//precache_sound("weapons/crylink_impact2.wav");
		//precache_sound("weapons/crylink_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		w_deathtypestring = _("%s succeeded at self-destructing themself with the Starlase");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_BOUNCE)
			w_deathtypestring = _("%s could not hide from %s's Starlase"); // unchecked: SPLASH (SECONDARY can't be)
		else if(w_deathtype & HITTYPE_SPLASH)
			w_deathtypestring = _("%s was too close to %s's Starlase"); // unchecked: SECONDARY
		else
			w_deathtypestring = _("%s took a close look at %s's Starlase"); // unchecked: SECONDARY
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_starlase (void)
//{
//	weapon_defaultspawnfunc(WEP_STARLASE);
//}
