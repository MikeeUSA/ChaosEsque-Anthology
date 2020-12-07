.float silent;

void Casing_Delete()
{
    remove(self);
}

void Casing_Draw()
{
	if(self.move_flags & FL_ONGROUND)
	{
		self.move_angles_x = 0;
		self.move_angles_z = 0;
		self.flags &~= FL_ONGROUND;
	}

	Movetype_Physics_MatchTicrate(autocvar_cl_casings_ticrate, autocvar_cl_casings_sloppy);
	if(wasfreed(self))
		return; // deleted by touch function

	self.renderflags = 0;
	self.alpha = bound(0, self.cnt - time, 1);

	if(self.alpha < ALPHA_MIN_VISIBLE)
	{
		Casing_Delete();
		self.drawmask = 0;
	}
}

void Casing_Touch()
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
	{
		Casing_Delete();
		return;
	}

	if(!self.silent)
	if(!trace_ent || trace_ent.solid == SOLID_BSP)
	{
		if(vlen(self.velocity) > 50)
		{
			if(time >= self.nextthink)
			{
				string s;
				float f;

				f = floor(prandom() * 3) + 1;
				switch(self.state)
				{
					case 1:
					case 59:
					case 60:
						s = strcat("weapons/casings", ftos(f), ".wav");
						break;
					case 64:
					case 65:
					case 66:
					case 67:
					case 68:
					case 69:
						s = "";
						break;
					default:
						s = strcat("weapons/brass", ftos(f), ".wav");
						break;
				}

				sound (self, CH_SHOTS, s, VOL_BASE, ATTN_LARGE);
			}
		}
	}

	self.nextthink = time + 0.2;
}

void Casing_Damage(float thisdmg, float hittype, vector org, vector thisforce)
{
	if(thisforce_z < 0)
		thisforce_z = 0;
	self.move_velocity = self.move_velocity + thisforce + '0 0 100';
	self.move_flags &~= FL_ONGROUND;
}

void Ent_Casing(float isNew)
{
	entity casing;

	casing = RubbleNew("casing");
	casing.state = ReadByte();
	casing.silent = (casing.state & 0x80);
	casing.state = (casing.state & 0x7F);
	casing.origin_x = ReadCoord();
	casing.origin_y = ReadCoord();
	casing.origin_z = ReadCoord();
	setorigin(casing, casing.origin);
	casing.velocity = decompressShortVector(ReadShort());
	casing.angles_x = ReadByte() * 360 / 256;
	casing.angles_y = ReadByte() * 360 / 256;
	casing.angles_z = ReadByte() * 360 / 256;
	casing.drawmask = MASK_NORMAL;

	if(autocvar_cl_casings && isNew) {
		casing.draw = Casing_Draw;
		casing.move_origin = casing.origin;
		casing.move_velocity = casing.velocity + 2 * prandomvec();
		casing.move_angles = casing.angles;
		casing.move_avelocity = '0 250 0' + 100 * prandomvec();
		casing.move_movetype = MOVETYPE_BOUNCE;
		casing.move_touch = Casing_Touch;
		casing.move_time = time;
		casing.event_damage = Casing_Damage;
		casing.solid = SOLID_TRIGGER;
		
		//print(ftos(casing.state),"\n");
		switch(casing.state)
		{
			case 1:
				setmodel(casing, "models/casing_shell.mdl");
				casing.cnt = time + autocvar_cl_casings_shell_time;
				break;
			case 4:
				//30 cal
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 0.66666;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 5:
				//9 mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 6:
				//.45 cal
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 7:
				//.50 cal
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 8:
				//17mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 1.46;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 9:
				//20mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 1.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 10:
				//30mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 2.58;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 11:
				//40mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 3.44;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 12:
				//55mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 4.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 13:
				//100mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 8.60;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 14:
				//125mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 10.75;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 15:
				//Placeholder
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 13.50;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 16:
				//Placehilder
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 17;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 17:
				//250mm
				setmodel(casing, "models/casing_bronze.iqm");
				casing.scale = 21.5;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 25:
				//9 mm Long case
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 26:
				//.45 cal Long case
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 27:
				//.50 cal Long case
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 29:
				//17mm Long case
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 1.46;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 30:
				//20mm
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 1.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 31:
				//30mm
				setmodel(casing, "models/casing_long.iqm");
				casing.scale = 2.58;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 32:
				//Old lead ball straight case
				setmodel(casing, "models/casing_steel.mdl");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 33:
				//RPG7 backstop
				setmodel(casing, "models/rpg7casing.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 34:
				//Casinglink  .25 cal
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 0.555;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 35:
				//Casinglink  9mm
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 36:
				//Casinglink .45 cal
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 37:
				//Casinglink  .50 cal
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 38:
				//Casinglink  17mm
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 1.46;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 39:
				//Casinglink  20mm
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 1.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 40:
				//Casinglink  30mm
				setmodel(casing, "models/casinglink.iqm");
				casing.scale = 2.58;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 45:
				//9 mm AE style pistol round, in between long and normal
				setmodel(casing, "models/casing_ae.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 46:
				//.45 cal AE style pistol round, in between long and normal
				setmodel(casing, "models/casing_ae.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 47:
				//.50 cal AE style pistol round, in between long and normal
				setmodel(casing, "models/casing_ae.iqm");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 55:
				//Nagant casing
				setmodel(casing, "models/casing_nagant.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 56:
				//Old lead ball straight case scaled for .36
				setmodel(casing, "models/casing_steel.mdl");
				casing.scale = 0.8;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 57:
				//Old lead ball straight case scaled for .69
				setmodel(casing, "models/casing_steel.mdl");
				casing.scale = 1.533333;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 58:
				//Old lead ball straight case scaled for .50
				setmodel(casing, "models/casing_steel.mdl");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 59:
				//8 gauge shotgun
				setmodel(casing, "models/casing_shell.mdl");
				casing.scale = 1.145;
				casing.cnt = time + autocvar_cl_casings_shell_time;
				break;
			case 60:
				//10 gauge shotgun
				setmodel(casing, "models/casing_shell.mdl");
				casing.scale = 1.064;
				casing.cnt = time + autocvar_cl_casings_shell_time;
				break;
			case 61:
				//Necked-down pistol ammunition
				//Five-Seven ammunition (P-90)
				//(which is .22 cal)
				setmodel(casing, "models/casing_nkdnpstl.iqm");
				casing.scale = 0.488;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 62:
				//Tokarev (7.62×25mm necked-down pistol ammunition)
				setmodel(casing, "models/casing_tokarev.iqm");
				casing.scale = 0.67;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 63:
				//8 mm lebel
				setmodel(casing, "models/casing_lebel.iqm");
				casing.scale = 0.757; //neck diameter 8.85mm 
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 64:
				//Red rose petal
				setmodel(casing, "models/rosepetals/rosepetal.iqm");
				casing.scale = 0.25;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 0;
				break;
			case 65:
				//Pink rose petal
				setmodel(casing, "models/rosepetals/rosepetal.iqm");
				casing.scale = 0.25;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 1;
				break;
			case 66:
				//White rose petal
				setmodel(casing, "models/rosepetals/rosepetal.iqm");
				casing.scale = 0.25;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 2;
				break;
			case 67:
				//Black rose petal
				setmodel(casing, "models/rosepetals/rosepetal.iqm");
				casing.scale = 0.25;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 3;
				break;
			case 68:
				//Black feather
				setmodel(casing, "models/feathers/feathersmall.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 0;
				break;
			case 69:
				//White feather
				setmodel(casing, "models/feathers/feathersmall.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				casing.skin = 1;
				break;
			case 99:
				//9 mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 0.77;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 103:
				//.22 cal
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 0.488;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 104:
				//Placeholder .25 cal
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 0.555;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 105:
				//.30 cal
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 0.66;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 106:
				//.45 cal
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 1;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 107:
				//.50 cal
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 1.11;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 108:
				//17mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 1.46;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 109:
				//20mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 1.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 110:
				//30mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 2.58;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 111:
				//40mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 3.44;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 112:
				//55mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 4.72;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 113:
				//100mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 8.60;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 114:
				//125mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 10.75;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 115:
				//Placeholder
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 13.50;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 116:
				//Placehilder
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 17;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 117:
				//250mm
				setmodel(casing, "models/casing_rifle.iqm");
				casing.scale = 21.5;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			//RUSSIAN
			case 123:
				//.22 cal  AK74 
				setmodel(casing, "models/casing_riflerusshort.iqm");
				casing.scale = 0.488;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 124:
				//7.62mm (30 cal) short  AK47 
				setmodel(casing, "models/casing_riflerusshort.iqm");
				casing.scale = 0.66;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			case 125:
				//7.62mm (30 cal) SVD, PKM, Mosin 
				setmodel(casing, "models/casing_riflerus.iqm");
				casing.scale = 0.66;
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
			default:
				//.45 representation of
				setmodel(casing, "models/casing_bronze.iqm");
				casing.cnt = time + autocvar_cl_casings_bronze_time;
				break;
		}

		setsize(casing, '0 0 -1', '0 0 -1');

		RubbleLimit("casing", autocvar_cl_casings_maxcount, Casing_Delete);
	}
	else
	{
		entity oldself = self;
		self = casing;
		Casing_Delete(); // yes, this IS stupid, but I don't need to duplicate all the read* stuff then
		self = oldself;
	}
}

void Casings_Precache()
{
	precache_model("models/casing_shell.mdl");
	precache_model("models/casing_steel.mdl");
	precache_model("models/casing_bronze.iqm");
	precache_model("models/casing_rifle.iqm");
	precache_model("models/casing_riflerus.iqm");
	precache_model("models/casing_riflerusshort.iqm");
	precache_model("models/casing_lebel.iqm");
	precache_model("models/rosepetals/rosepetal.iqm");
	precache_model("models/feathers/feathersmall.iqm");
	precache_model("models/casing_nkdnpstl.iqm");
	precache_model("models/casing_tokarev.iqm");
	precache_model("models/casing_ae.iqm");
	precache_model("models/casing_long.iqm");
	precache_model("models/casing_nagant.iqm");
	precache_model("models/rpg7casing.iqm");
	precache_model("models/casinglink.iqm");
	precache_sound("weapons/brass1.wav");
	precache_sound("weapons/brass2.wav");
	precache_sound("weapons/brass3.wav");
	precache_sound("weapons/casings1.wav");
	precache_sound("weapons/casings2.wav");
	precache_sound("weapons/casings3.wav");
}
