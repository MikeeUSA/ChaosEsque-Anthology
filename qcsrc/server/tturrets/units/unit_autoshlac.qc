void spawnfunc_turret_autoshlac();
void turret_autoshlac_std_init();
void turret_autoshlac_attack();

void turret_autoshlac_Touch (void)
{
	PROJECTILE_TOUCH;

	self.event_damage = func_null;
	
	if(self.projectiledeathtype & HITTYPE_SECONDARY)
		RadiusDamage (self, self.realowner, self.dmg, autocvar_g_balance_hlac_secondary_edgedamage, autocvar_g_balance_hlac_secondary_radius, world, autocvar_g_balance_hlac_secondary_force, self.projectiledeathtype, other);
	else
		RadiusDamage (self, self.realowner, self.dmg, autocvar_g_balance_hlac_primary_edgedamage, autocvar_g_balance_hlac_primary_radius, world, autocvar_g_balance_hlac_primary_force, self.projectiledeathtype, other);

	Chemical_flash_maybe(self);
	remove (self);
}

void turret_autoshlac_fire(vector start, vector dir, float spread, float pSpeed, float damage)
{
	entity missile;

	W_SetupShot (self, FALSE, 3, "weapons/lasergun_fire.wav", CH_WEAPON_A, autocvar_g_balance_hlac_primary_damage);
	pointparticles(particleeffectnum("laser_muzzleflash"), start, v_forward * 1000, 1);
	if (!g_norecoil)
	{
		self.punchangle_x = random () - 0.5;
		self.punchangle_y = random () - 0.5;
	}

	missile = spawn ();
	missile.owner = missile.realowner = self;
	missile.classname = "hlacbolt";
	missile.bot_dodge = TRUE;

    missile.bot_dodgerating = autocvar_g_balance_hlac_primary_damage;

	missile.movetype = MOVETYPE_FLY;
	PROJECTILE_MAKETRIGGER(missile);

	setorigin (missile, start);
	setsize(missile, '0 0 0', '0 0 0');

	W_SetupProjectileVelocityEx(missile, dir, v_up, pSpeed, 0, 0, spread, FALSE);

	missile.touch = turret_autoshlac_Touch;
	missile.think = SUB_Remove;
	missile.dmg = damage;

    missile.nextthink = time + autocvar_g_balance_hlac_primary_lifetime;

	missile.flags = FL_PROJECTILE;
	missile.projectiledeathtype = DEATH_TURRET_AUTOSHLAC;

	CSQCProjectile(missile, TRUE, PROJECTILE_HLAC, TRUE);

	other = missile; MUTATOR_CALLHOOK(EditProjectile);
}

//.float bulletcounter;
void turret_autoshlac_attack()
{

    turret_autoshlac_fire(self.tur_shotorg, self.tur_shotdir_updated,self.shot_spread, self.shot_speed, self.shot_dmg);
}


void turret_autoshlac_std_init()
{
    if (self.netname == "")      self.netname     = "AutoSHLAC Turret";

    self.ammo_flags = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MISSILEKILL;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
    
	if not (autocvar_g_antilag_bullets)
		self.turrcaps_flags |= TFL_TURRCAPS_HITSCAN;

    if (turret_stdproc_init("autoshlac_std", "models/turrets/base.md3", "models/turrets/machinegun.md3", TID_AUTOSHLAC) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;

    // Our fire routine
    self.turret_firefunc  = turret_autoshlac_attack;

}


/*QUAKED turret_autoshlac (0 .5 .8) ?
* autoshlac turret. does what you'd expect
*/
void spawnfunc_turret_autoshlac()
{
    precache_model ("models/turrets/machinegun.md3");
    precache_model ("models/turrets/base.md3");
    precache_sound ("weapons/lasergun_fire.wav");

    self.think = turret_autoshlac_std_init;
    self.nextthink = time + 0.5;
}

