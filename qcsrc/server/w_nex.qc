#ifdef REGISTER_WEAPON
REGISTER_WEAPON(NEX, w_nex, IT_CELLS, 7, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_HITSCAN, BOT_PICKUP_RATING_HIGH, "nex", "nex", _("Nex"))
#else
#ifdef SVQC

void SendCSQCNexBeamParticle(float charge) {
	vector v;
	v = WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos);
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_CSQC_NEXGUNBEAMPARTICLE);
	WriteCoord(MSG_BROADCAST, w_shotorg_x);
	WriteCoord(MSG_BROADCAST, w_shotorg_y);
	WriteCoord(MSG_BROADCAST, w_shotorg_z);
	WriteCoord(MSG_BROADCAST, v_x);
	WriteCoord(MSG_BROADCAST, v_y);
	WriteCoord(MSG_BROADCAST, v_z);
	WriteByte(MSG_BROADCAST, bound(0, 255 * charge, 255));
}

void W_Nex_Attack (float issecondary)
{
	float mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, myammo, charge;
	if(issecondary)
	{
		mydmg = autocvar_g_balance_nex_secondary_damage;
		myforce = autocvar_g_balance_nex_secondary_force;
		mymindist = autocvar_g_balance_nex_secondary_damagefalloff_mindist;
		mymaxdist = autocvar_g_balance_nex_secondary_damagefalloff_maxdist;
		myhalflife = autocvar_g_balance_nex_secondary_damagefalloff_halflife;
		myforcehalflife = autocvar_g_balance_nex_secondary_damagefalloff_forcehalflife;
		myammo = autocvar_g_balance_nex_secondary_ammo;
	}
	else
	{
		mydmg = autocvar_g_balance_nex_primary_damage;
		myforce = autocvar_g_balance_nex_primary_force;
		mymindist = autocvar_g_balance_nex_primary_damagefalloff_mindist;
		mymaxdist = autocvar_g_balance_nex_primary_damagefalloff_maxdist;
		myhalflife = autocvar_g_balance_nex_primary_damagefalloff_halflife;
		myforcehalflife = autocvar_g_balance_nex_primary_damagefalloff_forcehalflife;
		myammo = autocvar_g_balance_nex_primary_ammo;
	}

	float flying;
	flying = IsFlying(self); // do this BEFORE to make the trace values from FireRailgunBullet last

	if(autocvar_g_balance_nex_charge)
	{
		charge = autocvar_g_balance_nex_charge_mindmg / mydmg + (1 - autocvar_g_balance_nex_charge_mindmg / mydmg) * self.nex_charge;
		self.nex_charge *= autocvar_g_balance_nex_charge_shot_multiplier; // do this AFTER setting mydmg/myforce
		// O RLY? -- divVerent
		// YA RLY -- FruitieX
	}
	else
		charge = 1;
	mydmg *= charge;
	myforce *= charge;

	W_SetupShot (self, TRUE, 5, "weapons/nexfire.wav", CH_WEAPON_A, mydmg);
	if(charge > autocvar_g_balance_nex_charge_animlimit && autocvar_g_balance_nex_charge_animlimit) // if the Nex is overcharged, we play an extra sound
	{
		sound (self, CH_WEAPON_B, "weapons/nexcharge.wav", VOL_BASE * (charge - 0.5 * autocvar_g_balance_nex_charge_animlimit) / (1 - 0.5 * autocvar_g_balance_nex_charge_animlimit), ATTN_NORM);
	}

	yoda = 0;
	FireRailgunBullet (w_shotorg, w_shotorg + w_shotdir * MAX_SHOT_DISTANCE, mydmg, myforce, mymindist, mymaxdist, myhalflife, myforcehalflife, WEP_NEX);

	if(yoda && flying)
		AnnounceTo(self, "yoda");

	//beam and muzzle flash done on client
	SendCSQCNexBeamParticle(charge);

	W_DecreaseAmmo(ammo_cells, myammo, autocvar_g_balance_nex_reload_ammo);
}

float W_Nex_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_nex_reload_ammo && self.clip_load < min(autocvar_g_balance_nex_primary_ammo, autocvar_g_balance_nex_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_nex (void); // defined in t_items.qc

.float nex_chargepool_pauseregen_finished;
float w_nex(float req)
{
	float dt;
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_Nex_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		if(bot_aim(1000000, 0, 1, FALSE))
			self.BUTTON_ATCK = TRUE;
		else
		{
			if(autocvar_g_balance_nex_charge)
				self.BUTTON_ATCK2 = TRUE;
		}
	}
	else if (req == WR_THINK && !W_Nex_NeedManualReload())
	{
		if(autocvar_g_balance_nex_charge && self.nex_charge < autocvar_g_balance_nex_charge_limit)
			self.nex_charge = min(1, self.nex_charge + autocvar_g_balance_nex_charge_rate * frametime / W_TICSPERFRAME);

		if(autocvar_g_balance_nex_secondary_chargepool)
			if(self.nex_chargepool_ammo < 1)
			{
				if(self.nex_chargepool_pauseregen_finished < time)
					self.nex_chargepool_ammo = min(1, self.nex_chargepool_ammo + autocvar_g_balance_nex_secondary_chargepool_regen * frametime / W_TICSPERFRAME);
				self.pauseregen_finished = max(self.pauseregen_finished, time + autocvar_g_balance_nex_secondary_chargepool_pause_health_regen);
			}

		if(autocvar_g_balance_nex_reload_ammo && self.clip_load < min(autocvar_g_balance_nex_primary_ammo, autocvar_g_balance_nex_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else
		{
			if (self.BUTTON_ATCK)
			{
				if (weapon_prepareattack(0, autocvar_g_balance_nex_primary_refire))
				{
					W_Nex_Attack(0);
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nex_primary_animtime, w_ready);
				}
			}
			if ((autocvar_g_balance_nex_secondary_charge && !autocvar_g_balance_nex_secondary) ? (self.BUTTON_ZOOM | self.BUTTON_ZOOMSCRIPT) : self.BUTTON_ATCK2)
			{
				if(autocvar_g_balance_nex_secondary_charge)
				{
					self.nex_charge_rottime = time + autocvar_g_balance_nex_charge_rot_pause;
					dt = frametime / W_TICSPERFRAME;

					if(self.nex_charge < 1)
					{
						if(autocvar_g_balance_nex_secondary_chargepool)
						{
							if(autocvar_g_balance_nex_secondary_ammo)
							{
								// always deplete if secondary is held
								self.nex_chargepool_ammo = max(0, self.nex_chargepool_ammo - autocvar_g_balance_nex_secondary_ammo * dt);

								dt = min(dt, (1 - self.nex_charge) / autocvar_g_balance_nex_secondary_charge_rate);
								self.nex_chargepool_pauseregen_finished = time + autocvar_g_balance_nex_secondary_chargepool_pause_regen;
								dt = min(dt, self.nex_chargepool_ammo);
								dt = max(0, dt);

								self.nex_charge += dt * autocvar_g_balance_nex_secondary_charge_rate;
							}
						}

						else if(autocvar_g_balance_nex_secondary_ammo)
						{
							if(self.BUTTON_ATCK2) // only eat ammo when the button is pressed
							{
								dt = min(dt, (1 - self.nex_charge) / autocvar_g_balance_nex_secondary_charge_rate);
								if not(self.items & IT_UNLIMITED_WEAPON_AMMO)
								{
									// if this weapon is reloadable, decrease its load. Else decrease the player's ammo
									if(autocvar_g_balance_nex_reload_ammo)
									{
										dt = min(dt, (self.clip_load - autocvar_g_balance_nex_primary_ammo) / autocvar_g_balance_nex_secondary_ammo);
										dt = max(0, dt);
										if(dt > 0)
										{
											self.clip_load = max(autocvar_g_balance_nex_secondary_ammo, self.clip_load - autocvar_g_balance_nex_secondary_ammo * dt);
										}
										self.(weapon_load[WEP_NEX]) = self.clip_load;
									}
									else
									{
										dt = min(dt, (self.ammo_cells - autocvar_g_balance_nex_primary_ammo) / autocvar_g_balance_nex_secondary_ammo);
										dt = max(0, dt);
										if(dt > 0)
										{
											self.ammo_cells = max(autocvar_g_balance_nex_secondary_ammo, self.ammo_cells - autocvar_g_balance_nex_secondary_ammo * dt);
										}
									}
								}
								self.nex_charge += dt * autocvar_g_balance_nex_secondary_charge_rate;
							}
						}

						else
						{
							dt = min(dt, (1 - self.nex_charge) / autocvar_g_balance_nex_secondary_charge_rate);
							self.nex_charge += dt * autocvar_g_balance_nex_secondary_charge_rate;
						}
					}
				}
				else if(autocvar_g_balance_nex_secondary)
				{
					if (weapon_prepareattack(0, autocvar_g_balance_nex_secondary_refire))
					{
						W_Nex_Attack(1);
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_nex_secondary_animtime, w_ready);
					}
				}
			}
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/nexflash.md3");
		precache_model ("models/weapons/g_nex.md3");
		precache_model ("models/weapons/v_nex.md3");
		precache_model ("models/weapons/h_nex.iqm");
		precache_sound ("weapons/nexfire.wav");
		precache_sound ("weapons/nexcharge.wav");
		precache_sound ("weapons/nexwhoosh1.wav");
		precache_sound ("weapons/nexwhoosh2.wav");
		precache_sound ("weapons/nexwhoosh3.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		self.weaponaltaim_use = 1;
		self.weaponaltaim = '45 -0.2 -8.25';
		weapon_setup(WEP_NEX);
		self.current_ammo = ammo_cells;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_nex_primary_ammo;
		ammo_amount += (autocvar_g_balance_nex_reload_ammo && self.(weapon_load[WEP_NEX]) >= autocvar_g_balance_nex_primary_ammo);
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		if(autocvar_g_balance_nex_secondary)
		{
			// don't allow charging if we don't have enough ammo
			ammo_amount = self.ammo_cells >= autocvar_g_balance_nex_secondary_ammo;
			ammo_amount += self.(weapon_load[WEP_NEX]) >= autocvar_g_balance_nex_secondary_ammo;	
			return ammo_amount;
		}
		else
		{
			return FALSE; // zoom is not a fire mode
		}
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_nex_primary_ammo, autocvar_g_balance_nex_secondary_ammo), autocvar_g_balance_nex_reload_ammo, autocvar_g_balance_nex_reload_time, "weapons/reload.wav");
	}

	return TRUE;
}
#endif
#ifdef CSQC
float w_nex(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		pointparticles(particleeffectnum("newnex_impact"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/neximpact.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/neximpact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
		w_deathtypestring = _("%s is now thinking with portals");
	else if (req == WR_KILLMESSAGE)
		w_deathtypestring = _("%s has been vaporized by %s's nex");
	return TRUE;
}
#endif
#endif
