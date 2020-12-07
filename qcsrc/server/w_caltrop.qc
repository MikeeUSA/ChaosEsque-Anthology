#ifdef REGISTER_WEAPON
REGISTER_WEAPON(CALTROP, w_caltrop, IT_NAILS, 4, WEP_FLAG_NORMAL | WEP_FLAG_RELOADABLE | WEP_TYPE_SPLASH, BOT_PICKUP_RATING_MID, "caltrop", "caltrop", _("Caltrops"))
#else
#ifdef SVQC
.float caltrop_detonate_later;
.float caltrop_bouncecnt;
.float caltrop_release;

void W_Caltrop_Explode (void)
{
	local float mydamage;
	local float myedgedamage;
	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	mydamage = autocvar_g_balance_caltrop_primary_damage * (frametime / 0.0222222);
	myedgedamage = autocvar_g_balance_caltrop_primary_edgedamage * (frametime / 0.0222222);
	
	//print(ftos(mydamage),"\n");
	
	RadiusDamage (self, self.realowner, mydamage, myedgedamage, autocvar_g_balance_caltrop_primary_radius, world, autocvar_g_balance_caltrop_primary_force, self.projectiledeathtype, other);
}

void W_Caltrop_Explode2 (void)
{
	local float mydamage;
	local float myedgedamage;
	
	if(self.movetype == MOVETYPE_NONE)
		self.velocity = self.oldvelocity;

	mydamage = autocvar_g_balance_caltrop_secondary_damage * (frametime / 0.0222222);
	myedgedamage = autocvar_g_balance_caltrop_secondary_edgedamage * (frametime / 0.0222222);
	
	RadiusDamage (self, self.realowner, mydamage, myedgedamage, autocvar_g_balance_caltrop_secondary_radius, world, autocvar_g_balance_caltrop_secondary_force, self.projectiledeathtype, other);

}

void W_Caltrop_Damage (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if (self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	
	if (self.health <= 0) {
		W_PrepareExplosionByDamage(attacker, self.use);
		remove (self);
	}
}

void W_Caltrop_Think1 (void)
{

	if (time > self.cnt) {
		remove (self);
	}

	entity head;
	self.nextthink = time;
	// set the mine for detonation when a foe gets close enough
	head = findradius(self.origin, autocvar_g_balance_caltrop_proximityradius);
	while(head)
	{
		if((head.classname == "player" || head.flags & FL_MONSTER) && head.deadflag == DEAD_NO)
		if(time > self.delay)
		{
			W_Caltrop_Explode();
			//self.nextthink = time + 0.4;	
		}
		head = head.chain;
	}
}

void W_Caltrop_Think2 (void)
{
	
	if (time > self.cnt) {
		remove (self);
	}
	
	entity head;
	self.nextthink = time;
	// set the mine for detonation when a foe gets close enough
	head = findradius(self.origin, autocvar_g_balance_caltrop_proximityradius);
	while(head)
	{
		if((head.classname == "player" || head.flags & FL_MONSTER) && head.deadflag == DEAD_NO)
		if(time > self.delay)
		{
			W_Caltrop_Explode2();
			//self.nextthink = time + 0.4;	
		}
		head = head.chain;
	}
}

void W_Caltrop_Touch1 (void)
{
	PROJECTILE_TOUCH;

	if (other.takedamage == DAMAGE_AIM) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	}
	else
	{
		float r;
		r = random() * 6;
		if(r < 1)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce1.wav", VOL_BASE, ATTN_NORM);
		else if(r < 2)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce2.wav", VOL_BASE, ATTN_NORM);
		else if(r < 3)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce3.wav", VOL_BASE, ATTN_NORM);
		else if(r < 4)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce4.wav", VOL_BASE, ATTN_NORM);
		else if(r < 5)
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce5.wav", VOL_BASE, ATTN_NORM);
		else
			spamsound (self, CH_SHOTS, "weapons/grenade_bounce6.wav", VOL_BASE, ATTN_NORM);
		self.projectiledeathtype |= HITTYPE_BOUNCE;
		self.caltrop_bouncecnt += 1;
		UpdateCSQCProjectile(self);
	}
}

void W_Caltrop_Touch2 (void)
{
	PROJECTILE_TOUCH;

	if (other.takedamage == DAMAGE_AIM) // always explode when hitting a player, or if normal mortar projectile
	{
		self.use ();
	} else {
		//spamsound (self, CH_SHOTS, "weapons/grenade_stick.wav", VOL_BASE, ATTN_NORM);

		// let it stick whereever it is
		self.oldvelocity = self.velocity;
		self.velocity = '0 0 0';
		self.movetype = MOVETYPE_NONE; // also disables gravity
		self.gravity = 0; // nope, it does NOT! maybe a bug in CSQC code? TODO
		UpdateCSQCProjectile(self);

		// do not respond to any more touches
		//self.solid = SOLID_NOT;
	}
}

void W_Caltrop_Attack (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_caltrop_primary_ammo, autocvar_g_balance_caltrop_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 0, "", CH_WEAPON_A, autocvar_g_balance_caltrop_primary_damage);
	w_shotdir = v_forward; // no TrueAim for caltrops please


	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "caltrop";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_caltrop_primary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_caltrop_bouncefactor;
	gren.bouncestop = autocvar_g_balance_caltrop_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_CALTROP;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_caltrop_primary_lifetime;
	gren.delay = time + autocvar_g_balance_caltrop_delay;
	gren.nextthink = time;
	gren.think = W_Caltrop_Think1;
	gren.use = W_Caltrop_Explode;
	gren.touch = W_Caltrop_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_caltrop_primary_health;
	gren.damageforcescale = autocvar_g_balance_caltrop_primary_damageforcescale;
	gren.event_damage = W_Caltrop_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;


	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_caltrop_primary);


	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	
	CSQCProjectile(gren, TRUE, PROJECTILE_CALTROP, TRUE);
	
	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Caltrop_Attack2 (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_caltrop_secondary_ammo, autocvar_g_balance_caltrop_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 0, "", CH_WEAPON_A, autocvar_g_balance_caltrop_secondary_damage);
	w_shotdir = v_forward; // no TrueAim for caltrops please

	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "caltrop";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_caltrop_secondary_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_caltrop_bouncefactor;
	gren.bouncestop = autocvar_g_balance_caltrop_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_CALTROP | HITTYPE_SECONDARY;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_caltrop_secondary_lifetime;
	gren.delay = time + autocvar_g_balance_caltrop_delay;
	gren.nextthink = time;
	gren.think = W_Caltrop_Think2;
	gren.use = W_Caltrop_Explode2;
	gren.touch = W_Caltrop_Touch2;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_caltrop_secondary_health;
	gren.damageforcescale = autocvar_g_balance_caltrop_secondary_damageforcescale;
	gren.event_damage = W_Caltrop_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;

	
	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_caltrop_secondary);

	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	
	CSQCProjectile(gren, TRUE, PROJECTILE_CALTROP, TRUE);
	
	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

void W_Caltrop_Attack2Many (void)
{
	entity gren;

	W_DecreaseAmmo(ammo_nails, autocvar_g_balance_caltrop_secondarymany_ammo, autocvar_g_balance_caltrop_reload_ammo);

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 0, "", CH_WEAPON_A, autocvar_g_balance_caltrop_secondarymany_damage);
	w_shotdir = v_forward; // no TrueAim for caltrops please


	gren = spawn ();
	gren.owner = gren.realowner = self;
	gren.classname = "caltrop";
	gren.bot_dodge = TRUE;
	gren.bot_dodgerating = autocvar_g_balance_caltrop_secondarymany_damage;
	gren.movetype = MOVETYPE_BOUNCE;
	gren.bouncefactor = autocvar_g_balance_caltrop_bouncefactor;
	gren.bouncestop = autocvar_g_balance_caltrop_bouncestop;
	PROJECTILE_MAKETRIGGER(gren);
	gren.projectiledeathtype = WEP_CALTROP;
	setorigin(gren, w_shotorg);
	setsize(gren, '-3 -3 -3', '3 3 3');

	gren.cnt = time + autocvar_g_balance_caltrop_secondarymany_lifetime;
	gren.delay = time + autocvar_g_balance_caltrop_delay;
	gren.nextthink = time;
	gren.think = W_Caltrop_Think1;
	gren.use = W_Caltrop_Explode;
	gren.touch = W_Caltrop_Touch1;

	gren.takedamage = DAMAGE_YES;
	gren.health = autocvar_g_balance_caltrop_secondarymany_health;
	gren.damageforcescale = autocvar_g_balance_caltrop_secondarymany_damageforcescale;
	gren.event_damage = W_Caltrop_Damage;
	gren.damagedbycontents = TRUE;
	gren.missile_flags = MIF_SPLASH | MIF_ARC;


	W_SETUPPROJECTILEVELOCITY_UP(gren, g_balance_caltrop_secondarymany);


	gren.angles = vectoangles (gren.velocity);
	gren.flags = FL_PROJECTILE;

	
	CSQCProjectile(gren, TRUE, PROJECTILE_CALTROP, TRUE);
	
	other = gren; MUTATOR_CALLHOOK(EditProjectile);
}

float W_caltrop_NeedManualReload() {
	if  (autocvar_g_manualreload && (autocvar_g_balance_caltrop_reload_ammo && self.clip_load < min(autocvar_g_balance_caltrop_primary_ammo, autocvar_g_balance_caltrop_secondary_ammo)))
	{
		return 1;
	} else {
		return 0;
	}
	
}

void spawnfunc_weapon_caltrop (void)
{
	weapon_defaultspawnfunc(WEP_CALTROP);
}

.float bot_secondary_caltropmooth;
float w_caltrop(float req)
{
	float ammo_amount;

	if (req == WR_AIM)
	{
		if (W_caltrop_NeedManualReload()) { weapon_action(self.weapon, WR_RELOAD); } // bot reload if automatic reload off

		self.BUTTON_ATCK = FALSE;
		self.BUTTON_ATCK2 = FALSE;
		self.caltrop_release = 1;
		if (self.bot_secondary_caltropmooth == 0)
		{
			if(bot_aim(autocvar_g_balance_caltrop_primary_speed, autocvar_g_balance_caltrop_primary_speed_up, autocvar_g_balance_caltrop_primary_lifetime, TRUE))
			{
				self.BUTTON_ATCK = TRUE;
				if(random() < 0.01) self.bot_secondary_caltropmooth = 1;
			}
		}
		else
		{
			if(bot_aim(autocvar_g_balance_caltrop_secondary_speed, autocvar_g_balance_caltrop_secondary_speed_up, autocvar_g_balance_caltrop_secondary_lifetime, TRUE))
			{
				self.BUTTON_ATCK2 = TRUE;
				if(random() < 0.02) self.bot_secondary_caltropmooth = 0;
			}
		}
	}
	else if (req == WR_THINK && !W_caltrop_NeedManualReload())
	{		
		if(autocvar_g_balance_caltrop_reload_ammo && self.clip_load < min(autocvar_g_balance_caltrop_primary_ammo, autocvar_g_balance_caltrop_secondary_ammo)) // forced reload
			weapon_action(self.weapon, WR_RELOAD);
		else if (self.BUTTON_ATCK)
		{
			if (weapon_prepareattack(0, autocvar_g_balance_caltrop_primary_refire))
			{
				W_Caltrop_Attack();
				weapon_thinkf(WFRAME_FIRE1, autocvar_g_balance_caltrop_primary_animtime, w_ready);
			}
		}
		else if (self.BUTTON_ATCK2 && autocvar_g_balance_caltrop_secondary_type != 2)
		{
			if (weapon_prepareattack(1, autocvar_g_balance_caltrop_secondary_refire))
			{
				W_Caltrop_Attack2();
				weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_caltrop_secondary_animtime, w_ready);
			}
		} else {
		  
		  if (self.BUTTON_ATCK2 && autocvar_g_balance_caltrop_secondary_type == 2)
		  if (self.caltrop_release) {
		  
		    local float myrandvar, willdoattack, myloadammount;
		    willdoattack = 0;
		    myrandvar = 9 + floor((random()*5));
		    
		    if (autocvar_g_balance_caltrop_reload_ammo)
		    {
		    	myloadammount = self.clip_load;
		    } else {
		    	myloadammount = self.ammo_nails;
		    }
		    
		    //print(ftos(myloadammount), "my load ammount\n");
		    
		    if (myloadammount >= autocvar_g_balance_caltrop_secondary_ammo * myrandvar) {
		  	willdoattack = 1;
		    } else if (myloadammount >= autocvar_g_balance_caltrop_secondary_ammo * 9) {
		    	myrandvar = 9;
			willdoattack = 1;
		    }
		    
		    if (willdoattack)
		    if (weapon_prepareattack(1, autocvar_g_balance_caltrop_secondarymany_refire))
		    {
			while (myrandvar >= 1) {
				W_Caltrop_Attack2Many();
				myrandvar = myrandvar - 1;
			}
					
			weapon_thinkf(WFRAME_FIRE2, autocvar_g_balance_caltrop_secondarymany_animtime, w_ready);
		    }
		  }
		}
		
		if (self.BUTTON_ATCK || self.BUTTON_ATCK2) {
			self.caltrop_release = 0;
		} else {
			self.caltrop_release = 1;
		}
	}
	else if (req == WR_PRECACHE)
	{
		precache_model ("models/weapons/g_caltrop.md3");
		precache_model ("models/weapons/v_caltrop.md3");
		precache_model ("models/weapons/h_caltrop.iqm");
		precache_sound ("weapons/grenade_bounce1.wav");
		precache_sound ("weapons/grenade_bounce2.wav");
		precache_sound ("weapons/grenade_bounce3.wav");
		precache_sound ("weapons/grenade_bounce4.wav");
		precache_sound ("weapons/grenade_bounce5.wav");
		precache_sound ("weapons/grenade_bounce6.wav");
		precache_sound ("weapons/grenade_stick.wav");
		//precache_sound ("weapons/reload.wav"); // until weapons have individual reload sounds, precache the reload sound somewhere else
	}
	else if (req == WR_SETUP)
	{
		weapon_setup(WEP_CALTROP);
		self.current_ammo = ammo_nails;
	}
	else if (req == WR_CHECKAMMO1)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_caltrop_primary_ammo;
		ammo_amount += self.(weapon_load[WEP_CALTROP]) >= autocvar_g_balance_caltrop_primary_ammo;
		return ammo_amount;
	}
	else if (req == WR_CHECKAMMO2)
	{
		ammo_amount = self.ammo_nails >= autocvar_g_balance_caltrop_secondary_ammo;
		ammo_amount += self.(weapon_load[WEP_CALTROP]) >= autocvar_g_balance_caltrop_secondary_ammo;
		return ammo_amount;
	}
	else if (req == WR_RELOAD)
	{
		W_Reload(min(autocvar_g_balance_caltrop_primary_ammo, autocvar_g_balance_caltrop_secondary_ammo), autocvar_g_balance_caltrop_reload_ammo, autocvar_g_balance_caltrop_reload_time, "weapons/reload.wav");
	}
	return TRUE;
}
#endif
#ifdef CSQC
float w_caltrop(float req)
{
	if(req == WR_IMPACTEFFECT)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		//pointparticles(particleeffectnum("caltrop_explode"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/caltrop_impact.wav", VOL_BASE, ATTN_NORM);
	}
	else if(req == WR_PRECACHE)
	{
		precache_sound("weapons/caltrop_impact.wav");
	}
	else if (req == WR_SUICIDEMESSAGE)
	{
		if(w_deathtype & HITTYPE_SECONDARY)
			w_deathtypestring = _("%s didn't see their own caltrops");
		else
			w_deathtypestring = _("%s died by their own caltrops");
	}
	else if (req == WR_KILLMESSAGE)
	{
		if(w_deathtype & HITTYPE_SPLASH)
			if(w_deathtype & HITTYPE_BOUNCE) // (must be secondary then)
				w_deathtypestring = _("%s walked over %s's caltrops");
			else // unchecked: SECONDARY
				w_deathtypestring = _("%s treaded upon %s's caltrops");
		else // unchecked: SECONDARY, BOUNCE
			w_deathtypestring = _("%s ate %s's caltrop");
	}
	return TRUE;
}
#endif
#endif


//void spawnfunc_weapon_caltrop (void)
//{
//	weapon_defaultspawnfunc(WEP_CALTROP);
//}
