#ifdef REGISTER_WEAPON
REGISTER_WEAPON(LIGHTNINGGUN, w_lightninggun, IT_CELLS, 5, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "lightninggun", "lightninggun", _("LightningGun"));
#else
#ifdef SVQC
void lgunbeam_arcsb(float d, float r, vector o, entity owner_player);
void LightningGunInit();
vector lightninggun_shotorigin[4];

.float lightninggun_count;
.float lightninggun_secondarytime;

.vector hook_start, hook_end;
float lgunbeam_send(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_LGBEAM);
	sf = sf & 0x7F;
	if(sound_allowed(MSG_BROADCAST, self.realowner))
		sf |= 0x80;
	WriteByte(MSG_ENTITY, sf);
	if(sf & 1)
	{
		WriteByte(MSG_ENTITY, num_for_edict(self.realowner));
		if (self.owner.shootfromaltaim || self.owner.classname == "piercedjetemitter") {
			WriteByte(MSG_ENTITY, 1); //Don't interpolate from "owner player"
		} else {
			WriteByte(MSG_ENTITY, 0);
		}
		WriteCoord(MSG_ENTITY, autocvar_g_balance_lightninggun_primary_range);
	}
	if(sf & 2)
	{
		WriteCoord(MSG_ENTITY, self.hook_start_x);
		WriteCoord(MSG_ENTITY, self.hook_start_y);
		WriteCoord(MSG_ENTITY, self.hook_start_z);
	}
	if(sf & 4)
	{
		WriteCoord(MSG_ENTITY, self.hook_end_x);
		WriteCoord(MSG_ENTITY, self.hook_end_y);
		WriteCoord(MSG_ENTITY, self.hook_end_z);
	}
	return TRUE;
}
.entity lgbeam;
.float prevlgfire;
float lgunbeam_checkammo()
{
	if(self.realowner.items & IT_UNLIMITED_WEAPON_AMMO)
		return TRUE;
	else if(autocvar_g_balance_lightninggun_reload_ammo)
		return self.realowner.clip_load > 0;
	else
		return self.realowner.ammo_cells > 0;
}

entity lgbeam_owner_ent;
void lgunbeam_think()
{
	entity owner_player;
	owner_player = self.realowner;

	owner_player.prevlgfire = time;
	if (self != owner_player.lgbeam)
	{
		remove(self);
		return;
	}

	if (owner_player.weaponentity.state != WS_INUSE || !lgunbeam_checkammo() || owner_player.deadflag != DEAD_NO || !owner_player.BUTTON_ATCK || owner_player.freezetag_frozen || owner_player.frozen || owner_player.stoned)
	{
		if(self == owner_player.lgbeam)
			owner_player.lgbeam = world;
		remove(self);
		return;
	}

	self.nextthink = time;

	makevectors(owner_player.v_angle);

	float rmulti;
	float dt, f;
	dt = frametime;

	// if this weapon is reloadable, decrease its load. Else decrease the player's ammo
	if not(owner_player.items & IT_UNLIMITED_WEAPON_AMMO)
	{
		if(autocvar_g_balance_lightninggun_primary_ammo)
		{
			if(autocvar_g_balance_lightninggun_reload_ammo)
			{
				dt = min(dt, owner_player.clip_load / autocvar_g_balance_lightninggun_primary_ammo);
				owner_player.clip_load = max(0, owner_player.clip_load - autocvar_g_balance_lightninggun_primary_ammo * frametime);
				owner_player.(weapon_load[WEP_LIGHTNINGGUN]) = owner_player.clip_load;
			}
			else
			{
				dt = min(dt, owner_player.ammo_cells / autocvar_g_balance_lightninggun_primary_ammo);
				owner_player.ammo_cells = max(0, owner_player.ammo_cells - autocvar_g_balance_lightninggun_primary_ammo * frametime);
			}
		}
	}

	W_SetupShot_Range(owner_player, TRUE, 0, "", 0, autocvar_g_balance_lightninggun_primary_damage * dt, autocvar_g_balance_lightninggun_primary_range);
	if(!lgbeam_owner_ent)
	{
		lgbeam_owner_ent = spawn();
		lgbeam_owner_ent.classname = "lgbeam_owner_ent";
	}
	WarpZone_traceline_antilag(lgbeam_owner_ent, w_shotorg, w_shotend, MOVE_NORMAL, lgbeam_owner_ent, ANTILAG_LATENCY(owner_player));

	//f needs to be calculated anyway for arcing, even if no direct damage by beam
	f = ExponentialFalloff(autocvar_g_balance_lightninggun_primary_falloff_mindist, autocvar_g_balance_lightninggun_primary_falloff_maxdist, autocvar_g_balance_lightninggun_primary_falloff_halflifedist, vlen(WarpZone_UnTransformOrigin(WarpZone_trace_transform, trace_endpos) - w_shotorg));
	
	rmulti = 0;
	// apply the direct beam damage
	if(trace_ent)
	{
		rmulti = 1;
		vector force;
		force = w_shotdir * autocvar_g_balance_lightninggun_primary_force + '0 0 1' * autocvar_g_balance_lightninggun_primary_force_up;

		if(accuracy_isgooddamage(owner_player, trace_ent))
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, autocvar_g_balance_lightninggun_primary_damage * dt * f);
		Damage (trace_ent, owner_player, owner_player, autocvar_g_balance_lightninggun_primary_damage * dt * f, WEP_LIGHTNINGGUN, trace_endpos, force * dt);
	}
	W_Plasma_TriggerCombo(trace_endpos, autocvar_g_balance_electro_primary_comboradius, owner_player);
	Chemical_flash_maybe_at(trace_endpos, owner_player);


	// draw effect
	if(w_shotorg != self.hook_start)
	{
		self.SendFlags |= 2;
		self.hook_start = w_shotorg;
	}
	if(w_shotend != self.hook_end)
	{
		self.SendFlags |= 4;
		self.hook_end = w_shotend;
	}
	
	//Arcing stuff;
	//Rmulti is 0 if the beam didn't hit an entity, we evaluate materials, most are inert.
		float hitmaterial;
		hitmaterial = W_EvaluateMaterialHit();

		if ((hitmaterial == 1) || (hitmaterial == 2)) {
			//print("Metal\n");
			rmulti = 6.25;
			//Metal is a deathtrap
		} else if (hitmaterial == 5) {
			//print("Concrete\n");
			rmulti = 0;
		} else if ((hitmaterial == 3) || (hitmaterial == 4)) {
			//print("Stone and Brick\n");
			rmulti = 0;
		} else if (hitmaterial == 8) {
			//print("Wood and Bark\n");
			rmulti = 0;
		} else if (hitmaterial == 7) {
			//print("Dirt Etc\n");
			rmulti = 0;
		} else if (hitmaterial == 9) {
			//print("Sheetrock\n");
			rmulti = 0;
		} else {
			//print("NotMetal\n");
		}
		
	if(rmulti > 0) {
		lgunbeam_arcsb(autocvar_g_balance_lightninggun_primary_damage * dt * f, autocvar_g_balance_lightninggun_primary_arcrange * rmulti, w_shotend, owner_player);
	}
}

entity lgtoast(entity from, float range, float damage, entity owner_player)
{
    entity e;
    entity etarget = world;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if ((e.railgunhit != 1) && (e != from))
        {
            //Not going to validate, everythings good to attack!
                traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
                if (trace_fraction == 1.0)
                {
                    d = vlen(e.origin - from.origin);
                    if (d < dd)
                    {
                        dd = d;
                        etarget = e;
                    }
                }
        }
        e = e.chain;
    }

    if (etarget)
    {        
        te_csqc_lightningarc(from.origin,etarget.origin);
	
	if(accuracy_isgooddamage(owner_player, etarget)) {
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, damage);
	}
			
        Damage(etarget, owner_player, owner_player, damage, WEP_LIGHTNINGGUN | HITTYPE_SECONDARY, etarget.origin, '0 0 0');
        etarget.railgunhit = 1;
	if (random() < 0.2) {
		Chemical_flash_maybe_at(etarget.origin, owner_player);
	}
    }

    return etarget;
}

void lgunbeam_arcs(float d, float r, vector o, entity owner_player)
{
    entity e, t;
    float i;

    //w_deathtypestring = "discoverd how a tesla coil works";

    e = spawn();
    setorigin(e,o);
	
	//print("doing\n");

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = lgtoast(e,r,d,owner_player);
    remove(e);

    if (t == world) return;

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished_single = time + self.shot_refire;
    for (i = 0; i < 10; ++i)
    {
        d *= 0.75;
        r *= 0.85;
        t = lgtoast(t, r, d, owner_player);
        if (t == world) break;

    }

    e = findchainfloat(railgunhit, 1);
    while (e)
    {
        e.railgunhit = 0;
        e = e.chain;
    }
}
////////////////////////////////////////////
//Some extra colors.
//Tried to do this another way...
//Didn't want to work the clever way,
//guess it was too clever by half,
//and I not so clever by a third
// so here we go
//Blue
entity lgtoastb(entity from, float range, float damage, entity owner_player)
{
    entity e;
    entity etarget = world;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if ((e.railgunhit != 1) && (e != from))
        {
            //Not going to validate, everythings good to attack!
                traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
                if (trace_fraction == 1.0)
                {
                    d = vlen(e.origin - from.origin);
                    if (d < dd)
                    {
                        dd = d;
                        etarget = e;
                    }
                }
        }
        e = e.chain;
    }

    if (etarget)
    {        
        te_csqc_lightningarcb(from.origin,etarget.origin);
	
	if(accuracy_isgooddamage(owner_player, etarget)) {
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, damage);
	}
			
        Damage(etarget, owner_player, owner_player, damage, WEP_LIGHTNINGGUN | HITTYPE_SECONDARY, etarget.origin, '0 0 0');
        etarget.railgunhit = 1;
	if (random() < 0.2) {
		Chemical_flash_maybe_at(etarget.origin, owner_player);
	}
    }

    return etarget;
}

void lgunbeam_arcsb(float d, float r, vector o, entity owner_player)
{
    entity e, t;
    float i;

    //w_deathtypestring = "discoverd how a tesla coil works";

    e = spawn();
    setorigin(e,o);
	
	//print("doing\n");

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = lgtoastb(e,r,d,owner_player);
    remove(e);

    if (t == world) return;

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished_single = time + self.shot_refire;
    for (i = 0; i < 10; ++i)
    {
        d *= 0.75;
        r *= 0.85;
        t = lgtoastb(t, r, d, owner_player);
        if (t == world) break;

    }

    e = findchainfloat(railgunhit, 1);
    while (e)
    {
        e.railgunhit = 0;
        e = e.chain;
    }
}
//End Blue

//Cyan
entity lgtoastc(entity from, float range, float damage, entity owner_player)
{
    entity e;
    entity etarget = world;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if ((e.railgunhit != 1) && (e != from))
        {
            //Not going to validate, everythings good to attack!
                traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
                if (trace_fraction == 1.0)
                {
                    d = vlen(e.origin - from.origin);
                    if (d < dd)
                    {
                        dd = d;
                        etarget = e;
                    }
                }
        }
        e = e.chain;
    }

    if (etarget)
    {        
        te_csqc_lightningarcc(from.origin,etarget.origin);
	
	if(accuracy_isgooddamage(owner_player, etarget)) {
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, damage);
	}
			
        Damage(etarget, owner_player, owner_player, damage, WEP_LIGHTNINGGUN | HITTYPE_SECONDARY, etarget.origin, '0 0 0');
        etarget.railgunhit = 1;
	if (random() < 0.2) {
		Chemical_flash_maybe_at(etarget.origin, owner_player);
	}
    }

    return etarget;
}

void lgunbeam_arcsc(float d, float r, vector o, entity owner_player)
{
    entity e, t;
    float i;

    //w_deathtypestring = "discoverd how a tesla coil works";

    e = spawn();
    setorigin(e,o);
	
	//print("doing\n");

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = lgtoastc(e,r,d,owner_player);
    remove(e);

    if (t == world) return;

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished_single = time + self.shot_refire;
    for (i = 0; i < 10; ++i)
    {
        d *= 0.75;
        r *= 0.85;
        t = lgtoastc(t, r, d, owner_player);
        if (t == world) break;

    }

    e = findchainfloat(railgunhit, 1);
    while (e)
    {
        e.railgunhit = 0;
        e = e.chain;
    }
}
//EndCyan

//DarkBlue
entity lgtoastd(entity from, float range, float damage, entity owner_player)
{
    entity e;
    entity etarget = world;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if ((e.railgunhit != 1) && (e != from))
        {
            //Not going to validate, everythings good to attack!
                traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
                if (trace_fraction == 1.0)
                {
                    d = vlen(e.origin - from.origin);
                    if (d < dd)
                    {
                        dd = d;
                        etarget = e;
                    }
                }
        }
        e = e.chain;
    }

    if (etarget)
    {        
        te_csqc_lightningarcd(from.origin,etarget.origin);
	
	if(accuracy_isgooddamage(owner_player, etarget)) {
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, damage);
	}
			
        Damage(etarget, owner_player, owner_player, damage, WEP_LIGHTNINGGUN | HITTYPE_SECONDARY, etarget.origin, '0 0 0');
        etarget.railgunhit = 1;
	if (random() < 0.2) {
		Chemical_flash_maybe_at(etarget.origin, owner_player);
	}
    }

    return etarget;
}

void lgunbeam_arcsd(float d, float r, vector o, entity owner_player)
{
    entity e, t;
    float i;

    //w_deathtypestring = "discoverd how a tesla coil works";

    e = spawn();
    setorigin(e,o);
	
	//print("doing\n");

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = lgtoastd(e,r,d,owner_player);
    remove(e);

    if (t == world) return;

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished_single = time + self.shot_refire;
    for (i = 0; i < 10; ++i)
    {
        d *= 0.75;
        r *= 0.85;
        t = lgtoastd(t, r, d, owner_player);
        if (t == world) break;

    }

    e = findchainfloat(railgunhit, 1);
    while (e)
    {
        e.railgunhit = 0;
        e = e.chain;
    }
}
//End Dark Blue

//Purple(ish)
entity lgtoastp(entity from, float range, float damage, entity owner_player)
{
    entity e;
    entity etarget = world;
    float d,dd;

    dd = range + 1;

    e = findradius(from.origin,range);
    while (e)
    {
        if ((e.railgunhit != 1) && (e != from))
        {
            //Not going to validate, everythings good to attack!
                traceline(from.origin,0.5 * (e.absmin + e.absmax),MOVE_WORLDONLY,from);
                if (trace_fraction == 1.0)
                {
                    d = vlen(e.origin - from.origin);
                    if (d < dd)
                    {
                        dd = d;
                        etarget = e;
                    }
                }
        }
        e = e.chain;
    }

    if (etarget)
    {        
        te_csqc_lightningarcp(from.origin,etarget.origin);
	
	if(accuracy_isgooddamage(owner_player, etarget)) {
			accuracy_add(owner_player, WEP_LIGHTNINGGUN, 0, damage);
	}
			
        Damage(etarget, owner_player, owner_player, damage, WEP_LIGHTNINGGUN | HITTYPE_SECONDARY, etarget.origin, '0 0 0');
        etarget.railgunhit = 1;
	if (random() < 0.2) {
		Chemical_flash_maybe_at(etarget.origin, owner_player);
	}
    }

    return etarget;
}

void lgunbeam_arcsp(float d, float r, vector o, entity owner_player)
{
    entity e, t;
    float i;

    //w_deathtypestring = "discoverd how a tesla coil works";

    e = spawn();
    setorigin(e,o);
	
	//print("doing\n");

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK;

    t = lgtoastp(e,r,d,owner_player);
    remove(e);

    if (t == world) return;

    //self.target_validate_flags = TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_MISSILES | TFL_TARGETSELECT_TEAMCHECK;

    self.attack_finished_single = time + self.shot_refire;
    for (i = 0; i < 10; ++i)
    {
        d *= 0.75;
        r *= 0.85;
        t = lgtoastp(t, r, d, owner_player);
        if (t == world) break;

    }

    e = findchainfloat(railgunhit, 1);
    while (e)
    {
        e.railgunhit = 0;
        e = e.chain;
    }
}
//End Purple(ish)

//End Colors
////////////////////////////////////////////

// experimental lightning gun
void W_LightningGun_Attack3 (void)
{
	// only play fire sound if 0.5 sec has passed since player let go the fire button
	if(time - self.prevlgfire > 0.5)
		sound (self, CH_WEAPON_A, "weapons/lgbeam_fire.wav", VOL_BASE, ATTN_NORM);

	entity beam, oldself;

	self.lgbeam = beam = spawn();
	beam.classname = "lgbeam";
	beam.solid = SOLID_NOT;
	beam.think = lgunbeam_think;
	beam.owner = beam.realowner = self;
	beam.movetype = MOVETYPE_NONE;
	beam.shot_spread = 0;
	beam.bot_dodge = TRUE;
	beam.bot_dodgerating = autocvar_g_balance_lightninggun_primary_damage;
	Net_LinkEntity(beam, FALSE, 0, lgunbeam_send);

	oldself = self;
	self = beam;
	self.think();
	self = oldself;
}

void LightningGunInit()
{
	weapon_action(WEP_LIGHTNINGGUN, WR_PRECACHE);
	lightninggun_shotorigin[0] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LIGHTNINGGUN), FALSE, FALSE, 1);
	lightninggun_shotorigin[1] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LIGHTNINGGUN), FALSE, FALSE, 2);
	lightninggun_shotorigin[2] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LIGHTNINGGUN), FALSE, FALSE, 3);
	lightninggun_shotorigin[3] = shotorg_adjust_values(CL_Weapon_GetShotOrg(WEP_LIGHTNINGGUN), FALSE, FALSE, 4);
}

void spawnfunc_weapon_lightninggun (void)
{
	weapon_defaultspawnfunc(WEP_LIGHTNINGGUN);
}

float W_LightningGun_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_lightninggun_reload_ammo && self.clip_load < min(autocvar_g_balance_lightninggun_primary_ammo, autocvar_g_balance_lightninggun_secondary_ammo)) )
	{
		//Tried to figure out the logic of the custom lightninggun reload code, has to do with
		//not allowing you to waste all your ammo on secondary I think. I'll keep it
		//simple here though. Down on primary or secondary ammo, gotta reload
		return 1;
	} else {
		return 0;
	}
	
}


.float bot_secondary_lightninggunmooth;
.float BUTTON_ATCK_prev;
float w_lightninggun(float req)
{
	float ammo_amount;
	if (req == WR_AIM)
	{
		if (W_LightningGun_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK=FALSE;
		self.BUTTON_ATCK2=FALSE;
		if(vlen(self.origin-self.enemy.origin) > 1000)
			self.bot_secondary_lightninggunmooth = 0;
		if(self.bot_secondary_lightninggunmooth == 0)
		{
			float shoot;
			shoot = bot_aim(1000000, 0, 0.001, FALSE);

			if(shoot)
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_lightninggunmooth = 1;
			}
		}
	}
	else if (req == WR_THINK && !W_LightningGun_NeedManualReload())
	{
		if(autocvar_g_balance_lightninggun_reload_ammo) // forced reload
		{
			if(self.clip_load > 0)
				ammo_amount = 1;
			if(self.clip_load >= autocvar_g_balance_lightninggun_secondary_ammo)
				ammo_amount += 1;

			if(!ammo_amount)
			{
				weapon_action(self.weapon, WR_RELOAD);
				return FALSE;
			}
		}
		if (self.BUTTON_ATCK)
		{
			if(self.BUTTON_ATCK_prev)
			{
					// prolong the animtime while the gun is being fired
					if(self.animstate_startframe == self.anim_shoot_x && self.animstate_numframes == self.anim_shoot_y)
						weapon_thinkf(WFRAME_DONTCHANGE, autocvar_g_balance_lightninggun_primary_animtime, w_ready);
					else
						weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightninggun_primary_animtime, w_ready);
			}
			if (weapon_prepareattack(0, 0))
			{
				if ((!self.lgbeam) || wasfreed(self.lgbeam))
				{
					W_LightningGun_Attack3();
				}
				if(!self.BUTTON_ATCK_prev)
				{
					weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightninggun_primary_animtime, w_ready);
						self.BUTTON_ATCK_prev = 1;
				}
			}
		} else {
			if (self.BUTTON_ATCK_prev != 0)
			{
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_lightninggun_primary_animtime, w_ready);
				ATTACK_FINISHED(self) = time + autocvar_g_balance_lightninggun_primary_refire * W_WeaponRateFactor();
			}
			self.BUTTON_ATCK_prev = 0;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_lightninggun.md3");
		precache_model ("models/weapons/v_lightninggun.md3");
		precache_model ("models/weapons/h_lightninggun.iqm");
		precache_sound ("weapons/electro_impact.wav");
		precache_sound ("weapons/electro_impact_combo.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
		
			precache_sound ("weapons/lgbeam_fire.wav");
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_LIGHTNINGGUN);
		self.current_ammo = ammo_cells;
	}
	else if (req == WR_CHECKAMMO1)
	{
		if(!autocvar_g_balance_lightninggun_primary_ammo)
			ammo_amount = 1;
		else
			ammo_amount = self.ammo_cells > 0;
		ammo_amount += self.(weapon_load[WEP_LIGHTNINGGUN]) > 0;
		
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_cells >= autocvar_g_balance_lightninggun_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_LIGHTNINGGUN]) >= autocvar_g_balance_lightninggun_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RESETPLAYER)
	{
		self.lightninggun_secondarytime = time;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_lightninggun_primary_ammo, autocvar_g_balance_lightninggun_secondary_ammo), autocvar_g_balance_lightninggun_reload_ammo, autocvar_g_balance_lightninggun_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_lightninggun(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 6;
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			pointparticles(particleeffectnum("electro_ballexplode"), org2, '0 0 0', 1);
			if(!w_issilent)
				sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE)
			{
				// this is sent as "primary (w_deathtype & HITTYPE_BOUNCE)" to distinguish it from (w_deathtype & HITTYPE_SECONDARY) bounced balls
				pointparticles(particleeffectnum("electro_combo"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/electro_impact_combo.wav", VOL_BASE, ATTN_NORM);
			}
			else
			{
				pointparticles(particleeffectnum("electro_impact"), org2, '0 0 0', 1);
				if(!w_issilent)
					sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTN_NORM);
			}
		}
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/electro_impact.wav");
		precache_sound("weapons/electro_impact_combo.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s's lightninggun arced back");
		else
			w_deathtypestring = _("%s electrified the air with lightning");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
		{
			if(w_deathtype & HITTYPE_SPLASH) // unchecked: BOUNCE
				w_deathtypestring = _("%s just noticed %s's lightninggun plasma");
			else // unchecked: BOUNCE
				w_deathtypestring = _("%s was linked by %s's lightning arc");
		}
		else
		{
			if(w_deathtype & HITTYPE_BOUNCE) // combo
				w_deathtypestring = _("%s felt the electrifying air of %s's lightninggun combo");
			else if(w_deathtype & HITTYPE_SPLASH)
				w_deathtypestring = _("%s got too close to %s's lightning");
			else
				w_deathtypestring = _("%s was cooked by %s's lightning");
		}
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_lightninggun (void)
//{
//	weapon_defaultspawnfunc(WEP_LIGHTNINGGUN);
//}
