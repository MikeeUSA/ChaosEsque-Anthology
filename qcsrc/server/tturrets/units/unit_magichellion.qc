void spawnfunc_turret_magichellion();
void turret_magichellion_dinit();
void turret_magichellion_attack();

void turret_magichellion_missile_think()
{
    vector olddir,newdir;
    vector pre_pos;
    float itime;

    self.nextthink = time + 0.05;

    olddir = normalize(self.velocity);

    if(self.tur_health < time)
        W_Fireball_Explode(); //turret_projectile_explode();

    // Enemy dead? just keep on the current heading then.
    if ((self.enemy == world) || (self.enemy.deadflag != DEAD_NO))
    {

        // Make sure we dont return to tracking a respawned player
        self.enemy = world;

        // Turn model
        self.angles = vectoangles(self.velocity);

        if ( (vlen(self.origin - self.owner.origin)) > (self.owner.shot_radius * 5) )
            W_Fireball_Explode(); //turret_projectile_explode();

        // Accelerate
        self.velocity = olddir * min(vlen(self.velocity) * autocvar_g_turrets_unit_magichellion_std_shot_speed_gain, autocvar_g_turrets_unit_magichellion_std_shot_speed_max);

        UpdateCSQCProjectile(self);

        return;
    }

    // Enemy in range?
    if (vlen(self.origin - self.enemy.origin) < self.owner.shot_radius * 0.2)
        W_Fireball_Explode(); //turret_projectile_explode();

    // Predict enemy position
    itime = vlen(self.enemy.origin - self.origin) / vlen(self.velocity);
    pre_pos = self.enemy.origin + self.enemy.velocity * itime;

    pre_pos = (pre_pos + self.enemy.origin) * 0.5;

    // Find out the direction to that place
    newdir = normalize(pre_pos - self.origin);

    // Turn
    newdir = normalize(olddir + newdir * 0.35);

    // Turn model
    self.angles = vectoangles(self.velocity);

    // Accelerate
    self.velocity = newdir * min(vlen(self.velocity) * autocvar_g_turrets_unit_magichellion_std_shot_speed_gain, autocvar_g_turrets_unit_magichellion_std_shot_speed_max);

    if (itime < 0.05)
        self.think = W_Fireball_Explode; //turret_projectile_explode;

    UpdateCSQCProjectile(self);
}
void turret_magichellion_attack()
{
    entity missile;
		
	if(self.tur_head.frame != 0)
		self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire"));
	else
		self.tur_shotorg = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire2"));
    
    missile = turret_projectile("weapons/fireball_fire2.wav", 32, 10, WEP_FIREBALL, PROJECTILE_FIREBALL, FALSE, FALSE);
    te_explosion (missile.origin);
    missile.use = W_Fireball_Explode;
    missile.touch = W_Fireball_TouchExplode;
    missile.event_damage = W_Fireball_Damage;
    missile.projectiledeathtype = WEP_FIREBALL;
    missile.think        = turret_magichellion_missile_think;
    missile.nextthink    = time;
    missile.flags        = FL_PROJECTILE;
    missile.tur_health   = time + 9;
    missile.tur_aimpos   = randomvec() * 128;
    missile.missile_flags = MIF_SPLASH | MIF_PROXY | MIF_GUIDED_HEAT;
	self.tur_head.frame += 1;
}

void turret_magichellion_postthink()
{
    if (self.tur_head.frame != 0)
        self.tur_head.frame += 1;

    if (self.tur_head.frame >= 7)
        self.tur_head.frame = 0;
}

void turret_magichellion_dinit()
{
    if (self.netname == "")      self.netname  = "Hellion Missile Turret";

    self.turrcaps_flags = TFL_TURRCAPS_RADIUSDMG | TFL_TURRCAPS_FASTPROJ | TFL_TURRCAPS_PLAYERKILL | TFL_TURRCAPS_MISSILEKILL;
    self.aim_flags = TFL_AIM_SIMPLE;
    self.target_select_flags = TFL_TARGETSELECT_LOS | TFL_TARGETSELECT_PLAYERS | TFL_TARGETSELECT_RANGELIMTS | TFL_TARGETSELECT_TEAMCHECK ;
    self.firecheck_flags = TFL_FIRECHECK_DEAD | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_TEAMCECK | TFL_FIRECHECK_REFIRE | TFL_FIRECHECK_AFF | TFL_FIRECHECK_OWM_AMMO;
    self.ammo_flags = TFL_AMMO_ROCKETS | TFL_AMMO_RECHARGE;

    if (turret_stdproc_init("magichellion_std", "models/turrets/base.md3", "models/turrets/hellion.md3", TID_MAGICHELLION) == 0)
    {
        remove(self);
        return;
    }

    self.turret_firefunc  = turret_magichellion_attack;
    self.turret_postthink = turret_magichellion_postthink;
}

/*QUAKED turret_magichellion (0 .5 .8) ?
*/
void spawnfunc_turret_magichellion()
{
    precache_model ("models/turrets/hellion.md3");
    precache_model ("models/turrets/base.md3");
    precache_model ("models/sphere/sphere.md3");

    self.think = turret_magichellion_dinit;
    self.nextthink = time + 0.5;
}


