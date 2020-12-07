void spawnfunc_turret_magicmachinegun();
void turret_magicmachinegun_std_init();
void turret_magicmachinegun_attack();

void turret_magicmachinegun_W_CrossbowBolt_Attack (vector start, vector dir, float myspread)
{
	entity crossbolt;
	
	float antilagging;

	antilagging = (autocvar_g_antilag_bullets && (autocvar_g_balance_crossbowdtwr_primary_speed >= autocvar_g_antilag_bullets));

	W_SetupShot_ProjectileSize (self, '-3 -3 -3', '3 3 3', FALSE, 4, "", CH_WEAPON_A, autocvar_g_balance_crossbowdtwr_primary_damage);
	//w_shotdir = v_forward; // no TrueAim for crossbowbolts please

	//pointparticles(particleeffectnum("crossbowdtwr_muzzleflash"), w_shotorg, w_shotdir * 1000, 1);

	crossbolt = spawn ();
	crossbolt.owner = crossbolt.realowner = self;
	crossbolt.classname = "crossbowbolt";
	crossbolt.bot_dodge = TRUE;
	crossbolt.bot_dodgerating = autocvar_g_balance_crossbowdtwr_primary_damage;
	crossbolt.movetype = MOVETYPE_BOUNCE;
	crossbolt.bouncefactor = autocvar_g_balance_crossbowdtwr_bouncefactor;
	crossbolt.bouncestop = autocvar_g_balance_crossbowdtwr_bouncestop;
	PROJECTILE_MAKETRIGGER(crossbolt);
	crossbolt.projectiledeathtype = WEP_CROSSBOWDTWR;
	setorigin(crossbolt, start);
	setsize(crossbolt, '-0.5 -0.5 -0.5', '0.5 0.5 0.5');

	crossbolt.cnt = time + autocvar_g_balance_crossbowdtwr_primary_lifetime;
	crossbolt.nextthink = time;
	crossbolt.think = W_CrossbowBolt_Think1;
	crossbolt.use = W_CrossbowBolt_Explode;
	crossbolt.touch = W_CrossbowBolt_Touch1;

	crossbolt.takedamage = DAMAGE_YES;
	crossbolt.health = autocvar_g_balance_crossbowdtwr_primary_health;
	crossbolt.damageforcescale = autocvar_g_balance_crossbowdtwr_primary_damageforcescale;
	crossbolt.event_damage = W_CrossbowBolt_Damage;
	crossbolt.damagedbycontents = TRUE;
	//if(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate &&
 	//(autocvar_g_balance_crossbowdtwr_primary_launch_failurerate > random() ))
 	//{
	//	W_SetupProjectileVelocityEx(crossbolt, dir, v_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_up, autocvar_g_balance_crossbowdtwr_primary_launchfailure_speed_z, autocvar_g_balance_crossbowdtwr_primary_launchfailure_spread, antilagging);
	//	//if ((clienttype(self) == CLIENTTYPE_REAL)) {
	//	//	sprint(self, "Your crossbow suffered a partial dryfire\n");
	//	//}
	//} else {
		W_SetupProjectileVelocityEx(crossbolt, dir, v_up, autocvar_g_balance_crossbowdtwr_primary_speed, autocvar_g_balance_crossbowdtwr_primary_speed_up, autocvar_g_balance_crossbowdtwr_primary_speed_z, myspread, antilagging);
	//}

	crossbolt.angles = vectoangles (crossbolt.velocity);
	crossbolt.flags = FL_PROJECTILE;
	crossbolt.ammount = autocvar_g_balance_crossbowdtwr_primary_damage;

	CSQCProjectile(crossbolt, TRUE, PROJECTILE_CROSSBOWBOLT, TRUE);

	other = crossbolt; MUTATOR_CALLHOOK(EditProjectile);
}


float skeleton_style_aiming (entity mymonster, float myprojectilespeed, float myconstant);
//.float bulletcounter;
void turret_magicmachinegun_attack()
{
    local float myenmdist;
    local float myaimconst;
    local float mynumarrows; //How many?
    local vector v;
    local vector myoldangles;
    

    
    myenmdist = vlen(self.origin - self.enemy.origin);

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //myaimconst = 6; //2410 good... 3630 eh
    //myaimconst = 7;  //2014, more often 2124 2554 over head often,, 5672 too far, 6723 falling short
    //myaimconst = 6.5; //5281 falling short //3866 good //3319 good //2820 good //2360 good //2116 almost too high
    //7.25 1400 , 11000 falling short by alot, 7534, alittle, 6731 - 0k sorta, 6342 -good
    //7.5  7543 ok 7551 ok 7881 out of range seem almost
    //7.75 9827 falling short, 9240 did hit, 7600 good 8068 hitting low, 9080 falling short, 7968 hitting
    //8 8204 abit high, can crouch to avd 8960 - falls short
    //9 10645 - hits head, 11144 -falls short 9783 over, 10222 over
    //10 - 11768 good, 11640 -ok
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    mynumarrows = 1; //Far off players don't waste too many on
    
    //Here We start low for close, then add more to a point, then just go back to 1 if the player is too far
    
    if (myenmdist < 2400) {
    	myaimconst = 6;
		mynumarrows = 1;
    } else if (myenmdist < 4000) {
    	myaimconst = 6.5;
		mynumarrows = 3;
    } else if (myenmdist < 5000) {
    	myaimconst = 7;
		mynumarrows = 4;
    } else if (myenmdist < 6500) {
    	myaimconst = 7.25;
		mynumarrows = 5;
    } else if (myenmdist < 7500) {
    	myaimconst = 7.5;
		mynumarrows = 5;
    } else if (myenmdist < 8000) {
    	myaimconst = 7.75;
		mynumarrows = 6;
    } else if (myenmdist < 8200) {
    	myaimconst = 8;
		mynumarrows = 6;
    } else if (myenmdist < 9000) {
    	myaimconst = 8.25; //Guess
		mynumarrows = 7;
    } else if (myenmdist < 9500) {
    	myaimconst = 8.5;  //Guess
		mynumarrows = 7;
    } else if (myenmdist < 10250) {
    	myaimconst = 8.75;
		mynumarrows = 8;
    } else if (myenmdist < 10900) {
    	myaimconst = 9;
    } else if (myenmdist < 11100) {
    	myaimconst = 9.25; //Guess
    } else if (myenmdist < 11400) {
    	myaimconst = 9.5; //Guess
    } else if (myenmdist < 11600) {
    	myaimconst = 9.75;
    } else {
    	myaimconst = 10;
    }
    
    
    //print(ftos(self.enemy.health), " My enemy health\n");
    //print(etos(self.enemy), " My enemy\n");
    //print(ftos(self.enemy.solid), " My enemy solid\n");
    //print(ftos(self.enemy.movetype), " My enemy movetype\n");
    
    
    if (mynumarrows > 1) {
    	//Don't waste arrows on dead or frozen or stoned
   	 local float gvlessarrows;
    	gvlessarrows = 1;
    
    	if(!self.enemy.frozen)
    	if(!self.enemy.freezetag_frozen)
    	if(!self.enemy.stoned)
	if(self.enemy.prisonerlevel != 3)
   	if(self.enemy.deadflag == DEAD_NO)
    	if(self.enemy.health > 0)
	if(self.enemy.solid != SOLID_CORPSE && self.enemy.movetype != MOVETYPE_TOSS)
    	{
    		//Alive and well, here are some arrows! The full contingent
		gvlessarrows = 0;
    	}
    
   	if (gvlessarrows) {
    		//print("He's dead jim!\n");
    		mynumarrows = 1; //Dont waste tons on dead
    	}
    }
    
    //print(ftos(myenmdist)," enemy distance ", ftos(myaimconst)," Aim Constant\n");
    
    myoldangles = self.tur_head.angles;
    

    	if (self.enemy != world) {
    		self.tur_head.angles_x = skeleton_style_aiming (self, autocvar_g_balance_crossbowdtwr_primary_speed, myaimconst); //10 normal
    		self.tur_head.angles_x = self.tur_head.angles_x * -1; //Have to reverse it back
		makevectors(self.tur_head.angles);
    	} else {
		mynumarrows = 1; //Unlikely event :P, but if it ever happens, Don't waste
	}
    
    	v = gettaginfo(self.tur_head, gettagindex(self.tur_head, "tag_fire"));
    	v_forward = normalize(v_forward);
    	v += v_forward * 5;
	 
    while (mynumarrows > 0) {
    	//print("Loos an arra!\n");
    	turret_magicmachinegun_W_CrossbowBolt_Attack(v, v_forward, autocvar_g_balance_crossbowdtwr_primary_spread);	
    	mynumarrows = mynumarrows - 1;
	v += v_up * -5; //So we doewnt destru ersauls!
    }
    
    
    
    self.tur_head.angles = myoldangles;
    
}


void turret_magicmachinegun_std_init()
{
    if (self.netname == "")      self.netname     = "Machinegun Turret";

    self.ammo_flags = TFL_AMMO_BULLETS | TFL_AMMO_RECHARGE | TFL_AMMO_RECIVE;
    self.turrcaps_flags = TFL_TURRCAPS_PLAYERKILL;
    self.aim_flags = TFL_AIM_LEAD | TFL_AIM_SHOTTIMECOMPENSATE;
    
	if not (autocvar_g_antilag_bullets)
		self.turrcaps_flags |= TFL_TURRCAPS_HITSCAN;

    if (turret_stdproc_init("magicmachinegun_std", "models/turrets/base.md3", "models/turrets/machinegun.md3", TID_MAGICMACHINEGUN) == 0)
    {
        remove(self);
        return;
    }

    self.damage_flags |= TFL_DMG_HEADSHAKE;

    // Our fire routine
    self.turret_firefunc  = turret_magicmachinegun_attack;

}


/*QUAKED turret_magicmachinegun (0 .5 .8) ?
* magicmachinegun turret. does what you'd expect
*/
void spawnfunc_turret_magicmachinegun()
{
    precache_model ("models/turrets/machinegun.md3");
    precache_model ("models/turrets/base.md3");
    precache_model ("models/crossbowbolt.md3");
    //precache_sound ("weapons/uzi_fire.wav");
    W_crossbowdtwr_precache_arrowsounds();

    self.think = turret_magicmachinegun_std_init;
    self.nextthink = time + 0.5;
}

