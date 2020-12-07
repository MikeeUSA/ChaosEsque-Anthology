float autocvar_g_turrets_unit_fusreac_vhc_range;
void spawnfunc_turret_fusionreactor();
void turret_fusionreactor_dinit();
void turret_fusionreactor_fire();

void turret_fusionreactor_fire()
{
    vector fl_org;

    self.enemy.vehicle_ammo1_current = min(self.enemy.vehicle_ammo1_current + self.shot_dmg, self.enemy.vehicle_ammo1_max);
    self.enemy.vehicle_ammo2_current = min(self.enemy.vehicle_ammo2_current + self.shot_dmg, self.enemy.vehicle_ammo2_max);
    
    self.enemy.ammo = min(self.enemy.ammo + self.shot_dmg,self.enemy.ammo_max);
    fl_org = 0.5 * (self.enemy.absmin + self.enemy.absmax);
    te_smallflash(fl_org);
}

void turret_fusionreactor_postthink()
{
    self.tur_head.avelocity = '0 250 0' * (self.ammo / self.ammo_max);
}

/*
void turret_fusionreactor_respawnhook()
{
    self.tur_head.avelocity = '0 50 0';
}
*/

/**
** Preforms pre-fire checks for fusionreactor
**/
float turret_fusionreactor_firecheck()
{
	if (self.attack_finished_single > time) 
		return 0;

	if (self.enemy.deadflag != DEAD_NO)
		return 0;

	if (self.enemy == world)
		return 0;
		
	if ((self.enemy.netname == "T27")
	|| (self.enemy.netname == "TankIV")
	|| (self.enemy.netname == "TankA7V")
	|| (self.enemy.netname == "Spiderbot")
	|| (self.enemy.netname == "LL48")
	|| (self.enemy.netname == "LL40")
	|| (self.enemy.netname == "LL37")
	|| (self.enemy.netname == "LL24")
	|| (self.enemy.netname == "LL20")
	|| (self.enemy.netname == "Raptor")
	|| (self.enemy.netname == "BlackHawk")
	|| (self.enemy.netname == "Challenger")
	|| (self.enemy.netname == "Cruizer")
	|| (self.enemy.netname == "PickupTruck")
	|| (self.enemy.netname == "Wakizashi")
	|| (self.enemy.netname == "Sportster")
	|| (self.enemy.netname == "R22Heli")
	|| (self.enemy.netname == "H125Heli")
	|| (self.enemy.netname == "Submersible")
	|| (self.enemy.netname == "SpeedBoat")
	|| (self.enemy.netname == "AeroCommander")
	|| (self.enemy.netname == "Nieuport")
	|| (self.enemy.netname == "Fokker")
	|| (self.enemy.netname == "Sopwith")
	|| (self.enemy.netname == "Eindecker")
	|| (self.enemy.netname == "MechMAX")
	|| (self.enemy.netname == "LightAPC")
	|| (self.enemy.netname == "Browning50Gun")
	|| (self.enemy.netname == "GAU19Gun")
	|| (self.enemy.netname == "LewisGun")
	|| (self.enemy.netname == "M134Gun")
	|| (self.enemy.netname == "RpkGun")
	|| (self.enemy.netname == "RpdGun")
	|| (self.enemy.netname == "PkmGun")
	|| (self.enemy.netname == "M249ParaGun")
	|| (self.enemy.netname == "HotchkissM1914Gun")
	|| (self.enemy.netname == "Gatling1877Gun")
	|| (self.enemy.netname == "SpaduGun")
	|| (self.enemy.netname == "T17mmGun")
	|| (self.enemy.netname == "SiegeMortar")
	|| (self.enemy.netname == "CharMortar")
	|| (self.enemy.netname == "ScorpionBallista")
	)
	{
		if (vlen(self.enemy.origin - self.origin) > (self.target_range * autocvar_g_turrets_unit_fusreac_vhc_range))
			return 0;				
	
		if (self.enemy.vehicle_ammo1_current >= self.enemy.vehicle_ammo1_max)
		if (self.enemy.vehicle_ammo2_current >= self.enemy.vehicle_ammo2_max)
			return 0;
			
		//if(self.team != self.enemy.team)
		//	return 0;	
		
		return 1;	
	}
	
	if (self.ammo < self.shot_dmg)
		return 0;

	if (self.enemy.ammo >= self.enemy.ammo_max)
		return 0;
	
	if (vlen(self.enemy.origin - self.origin) > self.target_range)
		return 0;				
	
	if(self.team != self.enemy.team)
		return 0;
	
	if not (self.enemy.ammo_flags & TFL_AMMO_ENERGY)
		return 0;    
	
	return 1;
}

void turret_fusionreactor_dinit()
{
    if (self.netname == "")      self.netname     = "Fusionreactor";

    self.turrcaps_flags      = TFL_TURRCAPS_SUPPORT | TFL_TURRCAPS_AMMOSOURCE;
    self.ammo_flags          = TFL_AMMO_ENERGY | TFL_AMMO_RECHARGE;
    self.target_select_flags = TFL_TARGETSELECT_TEAMCHECK | TFL_TARGETSELECT_OWNTEAM | TFL_TARGETSELECT_RANGELIMTS;
    self.firecheck_flags     = TFL_FIRECHECK_OWM_AMMO | TFL_FIRECHECK_OTHER_AMMO | TFL_FIRECHECK_DISTANCES | TFL_FIRECHECK_DEAD;
    self.shoot_flags         = TFL_SHOOT_HITALLVALID;
    self.aim_flags           = TFL_AIM_NO;
    self.track_flags         = TFL_TRACK_NO;
    // self.turret_respawnhook  = turret_fusionreactor_respawnhook;

    if (turret_stdproc_init("fusreac_std", "models/turrets/base.md3", "models/turrets/reactor.md3", TID_FUSION) == 0)
    {
        remove(self);
        return;
    }
    self.tur_head.scale = 0.75;
    self.tur_head.avelocity = '0 50 0';
    setsize(self,'-34 -34 0','34 34 90');

    self.turret_firecheckfunc   = turret_fusionreactor_firecheck;
    self.turret_firefunc        = turret_fusionreactor_fire;
    self.turret_postthink       = turret_fusionreactor_postthink;
}

/*QUAKED turret_fusionreactor (0 .5 .8) ?
*/
void spawnfunc_turret_fusionreactor()
{
    precache_model ("models/turrets/reactor.md3");
    precache_model ("models/turrets/base.md3");

    self.think = turret_fusionreactor_dinit;
    self.nextthink = time + 0.5;
}
