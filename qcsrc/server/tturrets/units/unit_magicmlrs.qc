void spawnfunc_turret_magicmlrs();
void turret_magicmlrs_dinit();
void turret_magicmlrs_attack();


///////////////Lesser version

void turret_magic_W_Fireball_Explode2 (void)
{
	entity e;
	float dist;
	float points;
	vector dir;
	float d;

	self.event_damage = func_null;
	self.takedamage = DAMAGE_NO;

	RadiusDamage (self, self.realowner, autocvar_g_balance_fireball_primary_damage, autocvar_g_balance_fireball_primary_edgedamage, autocvar_g_balance_fireball_primary_radius, world, autocvar_g_balance_fireball_primary_force, self.projectiledeathtype, other);
	OilFire_explosion_spawnoilburnermaybe(self);

	remove (self);
}

void turret_magic_W_Fireball_TouchExplode2 (void)
{
	PROJECTILE_TOUCH;
	if (other.classname == "tree" || other.classname == "bush"
	|| ((other.classname == "bldhitbx" || other.classname == "building") && multitool_iswooden(other.count))
	) {
		Fire_AddDamage(other, self.realowner, autocvar_g_balance_fireball_secondary_damage * autocvar_g_balance_fireball_secondary_damagetime, autocvar_g_balance_fireball_secondary_damagetime, self.projectiledeathtype);
	}
	turret_magic_W_Fireball_Explode2 ();
}

void turret_magic_W_Fireball_Damage2 (entity inflictor, entity attacker, float damage, float deathtype, vector hitloc, vector force)
{
	if(self.health <= 0)
		return;
		
	if (!W_CheckProjectileDamage(inflictor.realowner, self.realowner, deathtype, -1)) // no exceptions
		return; // g_projectiles_damage says to halt
		
	if (deathtype == DEATH_SLIME)
		return;
		
	self.health = self.health - damage;
	if (self.health <= 0)
	{
		self.cnt = 1;
		W_PrepareExplosionByDamage(attacker, turret_magic_W_Fireball_Explode2);
	}
}
///////////////////////

void turret_magicmlrs_postthink()
{
    // 0 = full, 6 = empty
    self.tur_head.frame = bound(0, 6 - floor(0.1 + self.ammo / self.shot_dmg), 6);
    if(self.tur_head.frame < 0)
    {
    	dprint("ammo:",ftos(self.ammo),"\n");
    	dprint("shot_dmg:",ftos(self.shot_dmg),"\n");
    }
}

void turret_magicmlrs_attack()
{
    entity missile;
    
    turret_tag_fire_update();    
    missile = turret_projectile("weapons/fireball_fire.wav", 6, 10, WEP_FIREBALL, PROJECTILE_FIREMINE, TRUE, TRUE);
    missile.nextthink = time + max(self.tur_impacttime,(self.shot_radius * 2) / self.shot_speed);
    missile.missile_flags = MIF_SPLASH;
    //
    missile.nextthink = time + 12; //more time 
    missile.use = turret_magic_W_Fireball_Explode2;
    missile.touch = turret_magic_W_Fireball_TouchExplode2;
    missile.event_damage = turret_magic_W_Fireball_Damage2;
    missile.think = W_Firemine_Think; //Peter out
    missile.projectiledeathtype = WEP_FIREBALL | HITTYPE_SECONDARY;
    //
    te_explosion (missile.origin);    
}

void turret_magicmlrs_dinit()
{
    if (self.netname == "")      self.netname  = "MLRS turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_MEDPROJ | TFL_TURRCAPS_PLAYERKILL;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;

    if (turret_stdproc_init("magicmlrs_std", "models/turrets/base.md3", "models/turrets/mlrs.md3", TID_MAGICMLRS) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;
    self.shoot_flags  |= TFL_SHOOT_VOLLYALWAYS;
    self.volly_counter = self.shot_volly;

    // Our fire routine
    self.turret_firefunc  = turret_magicmlrs_attack;
    self.turret_postthink = turret_magicmlrs_postthink;

}

/*QUAKED turret_magicmlrs (0 .5 .8) ?
*/

void spawnfunc_turret_magicmlrs()
{
    precache_model ("models/turrets/mlrs.md3");
    precache_model ("models/turrets/base.md3");
    //precache_model ("models/sphere/sphere.md3");

    self.think = turret_magicmlrs_dinit;
    self.nextthink = time + 0.5;
}


