void DamageEffect_Think()
{
	// if particle distribution is enabled, slow ticrate by total number of damages
	if(autocvar_cl_damageeffect_distribute)
		self.nextthink = time + autocvar_cl_damageeffect_ticrate * self.owner.total_damages;
	else
		self.nextthink = time + autocvar_cl_damageeffect_ticrate;

	if(time >= self.cnt || !self.owner || !self.owner.modelindex || !self.owner.drawmask)
	{
		// time is up or the player got gibbed / disconnected
		self.owner.total_damages = max(0, self.owner.total_damages - 1);
		remove(self);
		return;
	}
	if(self.state && !self.owner.csqcmodel_isdead)
	{
		// if the player was dead but is now alive, it means he respawned
		// if so, clear his damage effects, or damages from his dead body will be copied back
		self.owner.total_damages = max(0, self.owner.total_damages - 1);
		remove(self);
		return;
	}
	self.state = self.owner.csqcmodel_isdead;
#ifdef COMPAT_XON050_ENGINE
	if(self.owner.isplayermodel && (self.owner.entnum == player_localentnum || self.owner.entnum == spectatee_status) && !autocvar_chase_active)
#else
	if(self.owner.isplayermodel && (self.owner.entnum == player_localentnum) && !autocvar_chase_active)
#endif
		if not(autocvar_cl_damageeffect_self) { return; } // if we aren't using a third person camera, hide our own effects

	// now generate the particles
	vector org;
	org = gettaginfo(self, 0); // origin at attached location
	pointparticles(self.team, org, '0 0 0', 1);
}

void DamageEffect(vector hitorg, float dmg, float type, float specnum)
{
	// particle effects for players and objects damaged by weapons (eg: flames coming out of victims shot with rockets)

	float life, nearestbone = 0;
	string specstr, effectname;
	entity e;

	if(!autocvar_cl_damageeffect || autocvar_cl_gentle || autocvar_cl_gentle_damage)
		return;
	if(!self || !self.modelindex || !self.drawmask)
		return;

	// if this is a rigged mesh, the effect will show on the bone where damage was dealt
	// we do this by choosing the skeletal bone closest to the impact, and attaching our entity to it
	// if there's no skeleton, object origin will automatically be selected
	FOR_EACH_TAG(self)
	{
		if(!tagnum)
			continue; // skip empty bones
		// blacklist bones positioned outside the mesh, or the effect will be floating
		// TODO: Do we have to do it this way? Why do these bones exist at all?
		if(gettaginfo_name == "master" || gettaginfo_name == "knee_L" || gettaginfo_name == "knee_R" || gettaginfo_name == "leg_L" || gettaginfo_name == "leg_R")
			continue; // player model bone blacklist

		// now choose the bone closest to impact origin
		if(nearestbone == 0 || vlen(hitorg - gettaginfo(self, tagnum)) <= vlen(hitorg - gettaginfo(self, nearestbone)))
			nearestbone = tagnum;
	}
	gettaginfo(self, nearestbone); // set gettaginfo_name

	// return if we reached our damage effect limit or damages are disabled
	// TODO: When the limit is reached, it would be better if the oldest damage was removed instead of not adding a new one
	if(nearestbone)
	{
		if(self.total_damages >= autocvar_cl_damageeffect_bones)
			return; // allow multiple damages on skeletal models
	}
	else
	{
		if(autocvar_cl_damageeffect < 2 || self.total_damages)
			return; // allow a single damage on non-skeletal models
	}

	life = bound(autocvar_cl_damageeffect_lifetime_min, dmg * autocvar_cl_damageeffect_lifetime, autocvar_cl_damageeffect_lifetime_max);
	specstr = species_prefix(specnum);
	type = DEATH_WEAPONOF(type);
	e = get_weaponinfo(type);
	
	//Some things that do blood are omitted here so that they only do server-side blood
	//(IE: less blood) Examples include crowbar, which does some blood but we don't want it to do a ton like a cut
	if(type == WEP_PISTOL || type == WEP_HMG || type == WEP_RPD || type == WEP_PKM || type == WEP_M249PARA || type == WEP_LEWISMG || type == WEP_MG0815 || type == WEP_MG || type == WEP_BIGPISTOL || type == WEP_LONGPISTOL || type == WEP_MAGNUM || type == WEP_PEPPERBOXREVOLVER || type == WEP_NAGANT1895 || type == WEP_WEBLEY || type == WEP_WEBLEYLONG || type == WEP_FFMAGNUM || type == WEP_LIGHTPISTOL || type == WEP_FIVESEVENPISTOL || type == WEP_MAUSERPISTOL || type == WEP_M9PISTOL || type == WEP_M93RPISTOL || type == WEP_BROWNINGHP || type == WEP_TT33PISTOL || type == WEP_LIGHTAUTO || type == WEP_MACHINEPISTOL || type == WEP_CZSKORPION || type == WEP_SVSKORPION || type == WEP_MICROUZI || type == WEP_TEC9 || type == WEP_POUNDERSMG || type == WEP_MINIUZI || type == WEP_SVD || type == WEP_AK47 || type == WEP_BAR1918 || type == WEP_CHAUCHAT || type == WEP_SHOSHO || type == WEP_AMR18 || type == WEP_HELLRIEGELSMG || type == WEP_SKS45 || type == WEP_AKS74U || type == WEP_M16MINI || type == WEP_SPECTRE || type == WEP_L85A2 || type == WEP_FAMAS || type == WEP_FNSCAR || type == WEP_G36C || type == WEP_M16VN || type == WEP_M16A2 || type == WEP_STYERAUG || type == WEP_STYERTMP || type == WEP_P90 || type == WEP_M1921 || type == WEP_M1928 || type == WEP_M1929 || type == WEP_PDW
	|| type == WEP_CROSSBOWDTWR || type == WEP_LIGHTCROSSBOW || type == WEP_LONGBOW || type == WEP_YUMIBOW || type == WEP_COMPOSITEBOW || type == WEP_CRUDEBOW || type == WEP_CALTROP || type == DEATH_SBMINIGUN || type == DEATH_SPORTSTERGUN || type == DEATH_SPORTSTERGUNHV || type == DEATH_SPORTSTERGUNLT
	|| type == WEP_COLT44REVOLVER || type == WEP_SCHOFIELDREVOLVER || type == WEP_COLTLIGHTNING || type == WEP_SHARPSRIFLE || type == WEP_HENRY1860RIFLE || type == WEP_WINCHESTER1873RIFLE || type == WEP_HENRY1860MARESLEG || type == WEP_NAVY1851REVOLVER || type == WEP_R1856REVOLVER || type == WEP_CARBINE || type == WEP_RAPIER || type == WEP_PICKAXE || type == WEP_ARKANSASTOOTHPICK || type == WEP_DAGGER || type == WEP_SAI || type == WEP_LARGEPISTOL) {
		effectname = "damage_uzi";
	} else if(type == WEP_REVOLVER || type == WEP_FLINTLOCKPISTOL
	 || type == WEP_MUSKET || type == WEP_TANEGASHIMA) {
		//Revolver fires a large lead ball as comparitivly slow speeds (black powder revolver), large hole
		effectname = "damage_uzi";
		life = bound(autocvar_cl_damageeffect_lifetime_min, life * 4 , autocvar_cl_damageeffect_lifetime_max);
	} else if(type == WEP_SHORTSWORD || type == WEP_LONGSWORD || type == WEP_CRUSADERSWORD || type == WEP_ARMINGSWORD || type == WEP_BASTARDSWORD || type == WEP_CLAYMORE || type == WEP_FLAMBERGE || type == WEP_SCIMITAR || type == WEP_FALCHION || type == WEP_DADAO || type == WEP_PUDAO || type == WEP_IRONKNIFE || type == WEP_BOWIEKNIFE || type == WEP_KNIFE || type == WEP_KATANA || type == WEP_SHIRASAYA || type == WEP_ZATOICHI || type == WEP_ODACHI || type == WEP_FIGHTERSWORD) {
		//Sword wound, large gash
		if (random() > 0.5) {
			effectname = "damage_shortsword";
		} else {
			effectname = "damage_uzi";
		}
		life = bound(autocvar_cl_damageeffect_lifetime_min, life * 5 , autocvar_cl_damageeffect_lifetime_max);
	} else if(type == WEP_MORGENSTERN || type == WEP_MILFLAIL || type == WEP_SPIKEDFLAIL || type == WEP_SHOOTINGSTAR || type == WEP_SHININGSTAR || type == WEP_SPIKEDMACE) {
		//Spike puncture
		effectname = "damage_uzi";
		life = bound(autocvar_cl_damageeffect_lifetime_min, life * 5 , autocvar_cl_damageeffect_lifetime_max);
	} else if(type == WEP_BROADAXE || type == WEP_NAGAMAKI) {
		//axe wound, large gash
		effectname = "damage_broadaxe";
		life = bound(autocvar_cl_damageeffect_lifetime_min, life * 6 , autocvar_cl_damageeffect_lifetime_max);
	} else if(type == WEP_STONEAXE) {
		//Not as great as a broadaxe, often more crushing perhaps, sometimes a somewhat heavy wound though
		if (random() > 0.8) {
			effectname = "damage_shortsword";
		} else {
			effectname = "damage_uzi";
		}
		life = bound(autocvar_cl_damageeffect_lifetime_min, life * 6 , autocvar_cl_damageeffect_lifetime_max);
	} else if(type == WEP_PUMPSHOTGUN || type == WEP_WINCHESTER1897 || type == WEP_M1897TRENCHGUN || type == WEP_ITHACASTAKEOUT || type == WEP_STREETSWEEPER || type == WEP_TENGAUGEDOUBLE || type == WEP_TENGAUGESAWEDOFF || type == WEP_EIGHTGAUGESAWEDOFF || type == WEP_EIGHTGAUGESHOTGUN || type == WEP_SPORTSHOTGUN || type == WEP_SPAS12 || type == WEP_SHOTGUNAUTOMAT) {
		effectname = "damage_shotgun";
	} else if(type == WEP_G98 || type == WEP_MOSIN || type == WEP_T17MMRIFLE || type == WEP_M1903 || type == WEP_TARGETPISTOL || type == WEP_LRR || type == WEP_M82RIFLE) {
		effectname = "damage_rifle";
	} else if(type == WEP_NUKE_LAYER) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_EXPLOSIVE_VEST) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_RPG7_LAUNCHER) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_RA4_LAUNCHER) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_DEVASTATOR) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_LIGHTSABRE) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_LIGHTSABREII) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_LIGHTSABREIV) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_LIGHTSABREXI) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_FLAMETHROWER) {
		effectname = "damage_rocketlauncher";
	} else if(type == WEP_HAGAR2) {
		effectname = "damage_hagar";
	} else if(type == WEP_MORTAR) {
		effectname = "damage_grenadelauncher";
	} else if(type == WEP_STARBLAST || type == WEP_SUNBURST || type == WEP_SUNBOLT) {
		if (autocvar_cl_particles_starblast) {
			effectname = "EF_STARDUST";
		}
	} else if(type == DEATH_RAPTOR_CANNON || type == WEP_CRYPISTOL || type == WEP_CRYLANCER) {
		effectname = "damage_crylink";
	} else if(type == DEATH_BUMB_GUN || type == WEP_LIGHTNINGGUN) {
		effectname = "damage_electro";
	} else if(type == DEATH_WAKIGUN || type == DEATH_TURRET_AUTOSHLAC) {
		effectname = "damage_hlac";
	} else {
		effectname = strcat("damage_", e.netname);
	}
	
	// if damage was dealt with a bullet weapon, our effect is blood
	// since blood is species dependent, include the species tag
	if(type == WEP_SHOTGUN || type == WEP_UZI || type == WEP_RIFLE || type == WEP_M1921 || type == WEP_M1928 || type == WEP_M1929 || type == WEP_PDW
	|| type == WEP_PISTOL || type == WEP_BIGPISTOL || type == WEP_LONGPISTOL || type == WEP_MAGNUM || type == WEP_PEPPERBOXREVOLVER || type == WEP_NAGANT1895 || type == WEP_WEBLEY || type == WEP_WEBLEYLONG || type == WEP_FFMAGNUM || type == WEP_LIGHTPISTOL || type == WEP_FIVESEVENPISTOL || type == WEP_MAUSERPISTOL || type == WEP_M9PISTOL || type == WEP_M93RPISTOL || type == WEP_BROWNINGHP || type == WEP_TT33PISTOL || type == WEP_LIGHTAUTO || type == WEP_MACHINEPISTOL || type == WEP_CZSKORPION || type == WEP_SVSKORPION || type == WEP_MICROUZI || type == WEP_TEC9 || type == WEP_POUNDERSMG || type == WEP_MINIUZI || type == WEP_SVD || type == WEP_AK47 || type == WEP_BAR1918 || type == WEP_CHAUCHAT || type == WEP_SHOSHO || type == WEP_AMR18 || type == WEP_HELLRIEGELSMG || type == WEP_SKS45 || type == WEP_AKS74U || type == WEP_M16MINI || type == WEP_SPECTRE || type == WEP_M16VN || type == WEP_M16A2 || type == WEP_FNSCAR || type == WEP_G36C || type == WEP_L85A2 || type == WEP_FAMAS || type == WEP_STYERAUG || type == WEP_STYERTMP || type == WEP_P90 || type == WEP_HMG || type == WEP_RPD || type == WEP_PKM || type == WEP_M249PARA || type == WEP_LEWISMG || type == WEP_MG0815 || type == WEP_MG || type == WEP_REVOLVER || type == WEP_FLINTLOCKPISTOL || type == WEP_MUSKET || type == WEP_TANEGASHIMA || type == WEP_NAVY1851REVOLVER || type == WEP_R1856REVOLVER || type == WEP_COLT44REVOLVER || type == WEP_SCHOFIELDREVOLVER || type == WEP_COLTLIGHTNING || type == WEP_SHARPSRIFLE || type == WEP_HENRY1860RIFLE || type == WEP_WINCHESTER1873RIFLE || type == WEP_HENRY1860MARESLEG 
	|| type == WEP_SHOTGUNAUTOMAT || type == WEP_PUMPSHOTGUN || type == WEP_WINCHESTER1897 || type == WEP_M1897TRENCHGUN || type == WEP_ITHACASTAKEOUT || type == WEP_STREETSWEEPER || type == WEP_TENGAUGEDOUBLE || type == WEP_TENGAUGESAWEDOFF || type == WEP_EIGHTGAUGESAWEDOFF || type == WEP_EIGHTGAUGESHOTGUN || type == WEP_SPORTSHOTGUN || type == WEP_SPAS12 || type == WEP_CARBINE || type == WEP_RAPIER || type == WEP_PICKAXE || type == WEP_ARKANSASTOOTHPICK || type == WEP_DAGGER || type == WEP_SAI
	|| type == WEP_G98 || type == WEP_MOSIN || type == WEP_T17MMRIFLE || type == WEP_M1903 || type == WEP_TARGETPISTOL || type == WEP_LRR || type == WEP_M82RIFLE || type == WEP_LARGEPISTOL || type == WEP_CROSSBOWDTWR || type == WEP_LIGHTCROSSBOW || type == WEP_LONGBOW || type == WEP_YUMIBOW || type == WEP_COMPOSITEBOW || type == WEP_CRUDEBOW || type == WEP_CALTROP || type == WEP_SHORTSWORD || type == WEP_MORGENSTERN || type == WEP_MILFLAIL || type == WEP_SPIKEDFLAIL || type == WEP_SHOOTINGSTAR || type == WEP_SHININGSTAR || type == WEP_SPIKEDMACE || type == WEP_LONGSWORD || type == WEP_BASTARDSWORD || type == WEP_CLAYMORE || type == WEP_FLAMBERGE || type == WEP_SCIMITAR || type == WEP_FALCHION || type == WEP_DADAO || type == WEP_PUDAO || type == WEP_CRUSADERSWORD || type == WEP_ARMINGSWORD || type == WEP_IRONKNIFE || type == WEP_BOWIEKNIFE || type == WEP_KNIFE || type == WEP_KATANA || type == WEP_SHIRASAYA || type == WEP_ZATOICHI || type == WEP_ODACHI || type == WEP_FIGHTERSWORD || type == WEP_BROADAXE || type == WEP_NAGAMAKI || type == WEP_STONEAXE)
	{
		if(self.isplayermodel)
		{
			effectname = strcat(effectname, "_", specstr);
			effectname = substring(effectname, 0, strlen(effectname) - 1); // remove the _ symbol at the end of the species tag
		}
		else
			return; // objects don't bleed
	}

	e = spawn();
	setmodel(e, "null"); // necessary to attach and read origin // samual: FIXME: this is weird, is there some better way to do this?
	setattachment(e, self, gettaginfo_name); // attach to the given bone
	e.classname = "damage";
	e.owner = self;
	e.cnt = time + life;
	e.team = particleeffectnum(effectname);
	e.think = DamageEffect_Think;
	e.nextthink = time;
	self.total_damages += 1;
}

void Ent_DamageInfo(float isNew)
{
	float dmg, rad, edge, thisdmg, forcemul, species, hitplayer = FALSE;
	vector force, thisforce;
	entity oldself;

	oldself = self;

	w_deathtype = ReadShort();
	w_issilent = (w_deathtype & 0x8000);
	w_deathtype = (w_deathtype & 0x7FFF);

	w_org_x = ReadCoord();
	w_org_y = ReadCoord();
	w_org_z = ReadCoord();

	dmg = ReadByte();
	rad = ReadByte();
	edge = ReadByte();
	force = decompressShortVector(ReadShort());
	species = ReadByte();

	if not(isNew)
		return;

	if(rad < 0)
	{
		rad = -rad;
		forcemul = -1;
	}
	else
		forcemul = 1;
	
	for(self = findradius(w_org, rad + MAX_DAMAGEEXTRARADIUS); self; self = self.chain)
	{
		// attached ents suck
		if(self.tag_entity)
			continue;

		vector nearest = NearestPointOnBox(self, w_org);
		if(rad)
		{
			thisdmg = ((vlen (nearest - w_org) - bound(MIN_DAMAGEEXTRARADIUS, self.damageextraradius, MAX_DAMAGEEXTRARADIUS)) / rad);
			if(thisdmg >= 1)
				continue;
			if(thisdmg < 0)
				thisdmg = 0;
			if(dmg)
			{
				thisdmg = dmg + (edge - dmg) * thisdmg;
				thisforce = forcemul * vlen(force) * (thisdmg / dmg) * normalize(self.origin - w_org);
			}
			else
			{
				thisdmg = 0;
				thisforce = forcemul * vlen(force) * normalize(self.origin - w_org);
			}
		}
		else
		{
			if(vlen(nearest - w_org) > bound(MIN_DAMAGEEXTRARADIUS, self.damageextraradius, MAX_DAMAGEEXTRARADIUS))
				continue;

			thisdmg = dmg;
			thisforce = forcemul * force;
		}

		if(self.damageforcescale)
			if(vlen(thisforce))
			{
				self.move_velocity = self.move_velocity + damage_explosion_calcpush(self.damageforcescale * thisforce, self.move_velocity, autocvar_g_balance_damagepush_speedfactor);
				self.move_flags &~= FL_ONGROUND;
			}

		if(w_issilent)
			self.silent = 1;

		if(self.event_damage)
			self.event_damage(thisdmg, w_deathtype, w_org, thisforce);

		DamageEffect(w_org, thisdmg, w_deathtype, species);

		if(self.isplayermodel)
			hitplayer = TRUE; // this impact damaged a player
	}

	self = oldself;
	
	if(w_deathtype == DEATH_FRAGMENT)
	{
		traceline(w_org - normalize(force) * 16, w_org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_plane_normal != '0 0 0')
			w_backoff = trace_plane_normal;
		else
			w_backoff = -1 * normalize(w_org - (w_org + normalize(force) * 16));
		
		setorigin(self, w_org + w_backoff * 2); // for sound() calls
		
		
		string _snd;
		_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".wav");
		sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
		pointparticles(particleeffectnum("fragment_impact"), self.origin, w_backoff * 1000, 1);
	}
	
	if(w_deathtype == DEATH_GRENADE)
	{
		vector org2;
		org2 = w_org + w_backoff * 12;
		pointparticles(particleeffectnum("grenade_explode"), org2, '0 0 0', 1);
		pointparticles(particleeffectnum("explosion_medium"), org2, '0 0 0', 1);
		if(!w_issilent)
			sound(self, CH_SHOTS, "weapons/grenade_impact.wav", VOL_BASE, ATTN_NORM);
	}
	
	if(DEATH_ISVEHICLE(w_deathtype))
	{
		traceline(w_org - normalize(force) * 16, w_org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_plane_normal != '0 0 0')
			w_backoff = trace_plane_normal;
		else
			w_backoff = -1 * normalize(w_org - (w_org + normalize(force) * 16));
		
		setorigin(self, w_org + w_backoff * 2); // for sound() calls
		
		switch(w_deathtype)
		{
			case DEATH_VHCRUSH:
				break;
				
			// spiderbot
			case DEATH_SBMINIGUN:
				string _snd;
				_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".wav");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("spiderbot_minigun_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_SBROCKET:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("spiderbot_rocket_explode"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_SBBLOWUP:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("explosion_big"), self.origin, w_backoff * 1000, 1);
				break;
            
			case DEATH_WAKIGUN:
				sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("wakizashi_gun_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_WAKIROCKET:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("wakizashi_rocket_explode"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_WAKIBLOWUP:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("explosion_big"), self.origin, w_backoff * 1000, 1);
				break;
				
			case DEATH_SPORTSTERGUN:
				_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".waw");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("machinegun_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_SPORTSTERGUNHV:
				_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".waw");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("machinegun_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_SPORTSTERGUNLT:
				_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".waw");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("machinegun_impact"), self.origin, w_backoff * 1000, 1);
				break;
			
			case DEATH_RAPTOR_CANNON:
				sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("raptor_cannon_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_RAPTOR_BOMB_SPLIT:
				float i;
				vector ang, vel;
				for(i = 1; i < 4; ++i)
				{
					vel = normalize(w_org - (w_org + normalize(force) * 16)) + randomvec() * 128;
					ang = vectoangles(vel);
					RaptorCBShellfragToss(w_org, vel, ang + '0 0 1' * (120 * i));
				}
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("raptor_bomb_spread"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_RAPTOR_BOMB:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("raptor_bomb_impact"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_RAPTOR_DEATH:
				sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("explosion_big"), self.origin, w_backoff * 1000, 1);
				break;
			case DEATH_BUMB_GUN:
				sound(self, CH_SHOTS, "weapons/fireball_impact2.wav", VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("bigplasma_impact"), self.origin, w_backoff * 1000, 1);
				break;
		}
	}
	
	
	if(DEATH_ISTURRET(w_deathtype))
	{
		string _snd;
		traceline(w_org - normalize(force) * 16, w_org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_plane_normal != '0 0 0')
			w_backoff = trace_plane_normal;
		else
			w_backoff = -1 * normalize(w_org - (w_org + normalize(force) * 16));
		
		setorigin(self, w_org + w_backoff * 2); // for sound() calls
		
		switch(w_deathtype)
		{   
			 case DEATH_TURRET_AUTOSHLAC:
			 case DEATH_TURRET_EWHEEL:
				sound(self, CH_SHOTS, "weapons/laserimpact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("laser_impact"), self.origin, w_backoff * 1000, 1);
				break;
			 
			 case DEATH_TURRET_FLAC:
				pointparticles(particleeffectnum("hagar_explode"), w_org, '0 0 0', 1);
				_snd = strcat("weapons/hagexp", ftos(1 + rint(random() * 2)), ".waw");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				break;
				
			 case DEATH_TURRET_MLRS:
			 case DEATH_TURRET_HK:
			 case DEATH_TURRET_WALKER_ROCKET:
			 case DEATH_TURRET_HELLION:
				sound(self, CH_SHOTS, "weapons/rocket_impact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("rocket_explode"), self.origin, w_backoff * 1000, 1);
				break;
			 
			 case DEATH_TURRET_MACHINEGUN:
			 case DEATH_TURRET_WALKER_GUN:
				_snd = strcat("weapons/ric", ftos(1 + rint(random() * 2)), ".waw");
				sound(self, CH_SHOTS, _snd, VOL_BASE, ATTN_NORM);
				pointparticles(particleeffectnum("machinegun_impact"), self.origin, w_backoff * 1000, 1);
				break;
						  
			 case DEATH_TURRET_PLASMA:
				sound(self, CH_SHOTS, "weapons/electro_impact.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("newelectro_impact"), self.origin, w_backoff * 1000, 1);
				break;
						  
			 case DEATH_TURRET_WALKER_MEELE:
				sound(self, CH_SHOTS, "weapons/ric1.wav", VOL_BASE, ATTN_MIN);
				pointparticles(particleeffectnum("TE_SPARK"), self.origin, w_backoff * 1000, 1);
				break;

			 case DEATH_TURRET_PHASER:
				break;
				
			 case DEATH_TURRET_TESLA:
				te_smallflash(self.origin);
				break;

		}
	}
	
	// TODO spawn particle effects and sounds based on w_deathtype
	if(!DEATH_ISSPECIAL(w_deathtype))
	if not(hitplayer && !rad) // don't show ground impacts for hitscan weapons if a player was hit
	{
		float hitwep;

		hitwep = DEATH_WEAPONOFWEAPONDEATH(w_deathtype);
		w_random = prandom();

		traceline(w_org - normalize(force) * 16, w_org + normalize(force) * 16, MOVE_NOMONSTERS, world);
		if(trace_fraction < 1 && hitwep != WEP_NEX && hitwep != WEP_MINSTANEX)
			w_backoff = trace_plane_normal;
		else
			w_backoff = -1 * normalize(force);
		setorigin(self, w_org + w_backoff * 2); // for sound() calls

		(get_weaponinfo(hitwep)).weapon_func(WR_IMPACTEFFECT);
	}
}

void DamageInfo_Precache()
{
	float i;
	for(i = WEP_FIRST; i <= WEP_LAST; ++i)
		(get_weaponinfo(i)).weapon_func(WR_PRECACHE);
}
