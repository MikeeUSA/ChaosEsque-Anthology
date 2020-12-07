#ifdef REGISTER_WEAPON
REGISTER_WEAPON(HANDCUFFS, w_handcuffs, IT_NAILS, 4, WEP_FLAG_NORMAL , BOT_PICKUP_RATING_LOW, "handcuffs", "handcuffs", _("Handcuffs"))
#else
#ifdef SVQC

.float handcuffs_release;
.float handcuffs_secondary;

.float swing_prev;
.entity swing_alreadyhit;
void MagicInventoryPinataNadesOnly (entity player);
void SpawnThrownWeapon (vector org, float w);

void handcuffs_primarythink (void)
{
	shackles_meleethink(
		autocvar_g_balance_handcuffs_primary_melee_time,
		autocvar_g_balance_handcuffs_primary_melee_range,
		autocvar_g_balance_handcuffs_primary_damage,
		autocvar_g_balance_handcuffs_primary_melee_nonplayerdamage, 0, WEP_HANDCUFFS
		);
}

void handcuffs_secondarythink (void)
{
	shackles_meleethink(
		autocvar_g_balance_handcuffs_secondary_melee_time,
		autocvar_g_balance_handcuffs_secondary_melee_range,
		autocvar_g_balance_handcuffs_secondary_damage,
		autocvar_g_balance_handcuffs_secondary_melee_nonplayerdamage, 1, WEP_HANDCUFFS
		);
}

void W_Handcuffs_Attack (void)
{
	sound (self, CH_WEAPON_A, "weapons/handcuffs_melee.wav", VOL_BASE, ATTN_NORM);
	if(self.handcuffs_secondary == 1) {
		weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_handcuffs_secondary_animtime, w_ready);
	} else {
		weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_handcuffs_primary_animtime, w_ready);
	}

	entity meleetemp;
	meleetemp = spawn();
	meleetemp.realowner = self;
	
	self.melee_temp = meleetemp;
	self.melee_temp_class = 0; //Less than Shackless
	
	if(self.handcuffs_secondary == 1) {
	 	self.melee_temp_starttime = time + autocvar_g_balance_handcuffs_secondary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_handcuffs_secondary_melee_time;
	   meleetemp.think = handcuffs_secondarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_handcuffs_secondary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_handcuffs_secondary_damage, autocvar_g_balance_handcuffs_secondary_melee_range);
	} else {
		self.melee_temp_starttime = time + autocvar_g_balance_handcuffs_primary_melee_delay * W_WeaponRateFactor();
	   	self.melee_temp_endtime = self.melee_temp_starttime + autocvar_g_balance_handcuffs_primary_melee_time;
	   meleetemp.think = handcuffs_primarythink;
	   meleetemp.nextthink = time + autocvar_g_balance_handcuffs_primary_melee_delay * W_WeaponRateFactor();
	   W_SetupShot_Range(self, TRUE, 0, "", 0, autocvar_g_balance_handcuffs_primary_damage, autocvar_g_balance_handcuffs_primary_melee_range);
	}
}


void spawnfunc_weapon_handcuffs (void)
{
	weapon_defaultspawnfunc(WEP_HANDCUFFS);
}

.float handcuffs_primarytime;

float w_handcuffs(float req)
{
	if (req == WR_AIM) {
		if((vlen(self.origin-self.enemy.origin) <= autocvar_g_balance_handcuffs_primary_melee_range)
		&& (self.handcuffs_release)) {
			self.BUTTON_ATCK = bot_aim(1000000, 0, 0.001, FALSE);
		}
		else
		{
			self.BUTTON_ATCK=FALSE;
		}
	}
	else if (req == WR_THINK)
	{
		//if (!self.crouch) // we are not currently crouching; this fixes an exploit where your melee anim is not visible, and besides wouldn't make much sense
		if (self.BUTTON_ATCK)
		if (self.handcuffs_release)
		if (weapon_prepareattack(1, autocvar_g_balance_handcuffs_primary_refire))
		{
			self.handcuffs_secondary = 0;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Handcuffs_Attack);
			self.handcuffs_release = 0;
		}
		if (self.BUTTON_ATCK2)
		if (self.handcuffs_release)
		if (weapon_prepareattack(1, autocvar_g_balance_handcuffs_secondary_refire))
		{
			self.handcuffs_secondary = 1;
			// attempt forcing playback of the anim by switching to another anim (that we never play) here...
			weapon_thinkf(WFRAME_FIRE1, 0, W_Handcuffs_Attack);
			self.handcuffs_release = 0;
		}
		if not(self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.handcuffs_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_handcuffs.md3");
		precache_model ("models/weapons/v_handcuffs.md3");
		precache_model ("models/weapons/h_handcuffs.iqm");
		//precache_sound ("misc/itempickup.wav");
		//precache_sound ("weapons/handcuffs_fire.wav");
		precache_sound ("weapons/handcuffs_melee.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		melee_precachesound();
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_HANDCUFFS);
		self.current_ammo = ammo_none;
	}
	else if (req == WR_CHECKAMMO1)
	{
		// melee attack is always available
		return TRUE;
	}
	return TRUE;
}
#endif
#ifdef CSQC
.float prevric;
float w_handcuffs(float req)
{
	if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
	{
		if (w_deathtype & HITTYPE_SECONDARY)
		{
			w_deathtypestring = _("%s was died by way of %s's handcuffs");
		} else {
			w_deathtypestring = _("%s was killed with %s's handcuffs");
		}
	}
	return TRUE;
}
#endif
#endif
