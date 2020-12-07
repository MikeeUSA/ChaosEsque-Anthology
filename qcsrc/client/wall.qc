.float lip;
.float bgmscriptangular;
.float lodmodelindex0, lodmodelindex1, lodmodelindex2, lodmodelindex3, lodmodelindex4, lodmodelindex5, lodmodelindex6, lodmodelindex0substitute;
.float loddistance1, loddistance2, loddistance3, loddistance4, loddistance5, loddistance6, lodmodel0substitute_use;
.vector saved;

void Ent_Wall_Draw()
{
	float f;
	var .vector fld;

	if(self.bgmscriptangular)
		fld = angles;
	else
		fld = origin;
	self.fld = self.saved;

	if(self.lodmodelindex1)
	{
		if(autocvar_cl_modeldetailreduction <= 0)
		{
			if(self.lodmodelindex6 && autocvar_cl_modeldetailreduction <= -6)
				self.modelindex = self.lodmodelindex6;
			else if(self.lodmodelindex5 && autocvar_cl_modeldetailreduction <= -5)
				self.modelindex = self.lodmodelindex5;
			else if(self.lodmodelindex4 && autocvar_cl_modeldetailreduction <= -4)
				self.modelindex = self.lodmodelindex4;
			else if(self.lodmodelindex3 && autocvar_cl_modeldetailreduction <= -3)
				self.modelindex = self.lodmodelindex3;
			else if(self.lodmodelindex2 && autocvar_cl_modeldetailreduction <= -2)
				self.modelindex = self.lodmodelindex2;
			else if(autocvar_cl_modeldetailreduction <= -1)
				self.modelindex = self.lodmodelindex1;
			else
				self.modelindex = self.lodmodelindex0;
		}
		else
		{
			float distance = vlen(NearestPointOnBox(self, view_origin) - view_origin);
			f = (distance * current_viewzoom + 100.0) * autocvar_cl_modeldetailreduction;
			f *= 1.0 / bound(0.01, view_quality, 1);
			if(self.lodmodelindex6 && f > self.loddistance6)
				self.modelindex = self.lodmodelindex6;
			else if(self.lodmodelindex5 && f > self.loddistance5)
				self.modelindex = self.lodmodelindex5;
			else if(self.lodmodelindex4 && f > self.loddistance4)
				self.modelindex = self.lodmodelindex4;
			else if(self.lodmodelindex3 && f > self.loddistance3)
				self.modelindex = self.lodmodelindex3;
			else if(self.lodmodelindex2 && f > self.loddistance2)
				self.modelindex = self.lodmodelindex2;
			else if(f > self.loddistance1)
				self.modelindex = self.lodmodelindex1;
			else {
				if (self.lodmodel0substitute_use) {
					self.modelindex = self.lodmodelindex0substitute;
				} else {
					self.modelindex = self.lodmodelindex0;
				}
			}
		}
	}

	InterpolateOrigin_Do();

	self.saved = self.fld;

	f = BGMScript(self);
	if(f >= 0)
	{
		if(self.lip < 0) // < 0: alpha goes from 1 to 1-|lip| when toggled (toggling subtracts lip)
			self.alpha = 1 + self.lip * f;
		else // > 0: alpha goes from 1-|lip| to 1 when toggled (toggling adds lip)
			self.alpha = 1 - self.lip * (1 - f);
		self.fld = self.fld + self.movedir * f;
	}
	else
		self.alpha = 1;

	if(self.alpha >= ALPHA_MIN_VISIBLE)
		self.drawmask = MASK_NORMAL;
	else
		self.drawmask = 0;
}

void Ent_Wall_Remove()
{
	if(self.bgmscript)
		strunzone(self.bgmscript);
	self.bgmscript = string_null;
}

void Ent_Wall()
{
	float f;
	var .vector fld;

	InterpolateOrigin_Undo();
	//self.iflags = IFLAG_ANGLES | IFLAG_ORIGIN; //Bendy-models branch xonotic-stable
	self.iflags = IFLAG_ANGLES; // xonotic-concrete

	if(self.bgmscriptangular)
		fld = angles;
	else
		fld = origin;
	self.fld = self.saved;

	f = ReadByte();

	if(f & 1)
	{
		if(f & 0x40)
			self.colormap = ReadShort();
		else
			self.colormap = 0;
			
		self.skin = ReadByte();
		self.effects = ReadLong();
	}

	if(f & 2)
	{
		self.origin_x = ReadCoord();
		self.origin_y = ReadCoord();
		self.origin_z = ReadCoord();
		setorigin(self, self.origin);
	}

	if(f & 4)
	{
		if(f & 0x10)
		{
			self.angles_x = ReadAngle();
			self.angles_y = ReadAngle();
			self.angles_z = ReadAngle();
		}
		else
			self.angles = '0 0 0';
	}

	if(f & 8)
	{
		if(f & 0x80)
		{
			self.lodmodelindex0 = ReadShort();
			self.loddistance1 = ReadLong(); //Switched to long to support huge lod distances
			self.lodmodelindex1 = ReadShort();
			self.loddistance2 = ReadLong();
			self.lodmodelindex2 = ReadShort();
			self.loddistance3 = ReadLong();
			self.lodmodelindex3 = ReadShort();
			self.loddistance4 = ReadLong();
			self.lodmodelindex4 = ReadShort();
			self.loddistance5 = ReadLong();
			self.lodmodelindex5 = ReadShort();
			self.loddistance6 = ReadLong();
			self.lodmodelindex6 = ReadShort();
			
			self.lodmodel0substitute_use = ReadShort();
			self.lodmodelindex0substitute = ReadShort();
		}
		else
		{
			self.modelindex = ReadShort();
			self.loddistance1 = 0;
			self.loddistance2 = 0;
			self.loddistance3 = 0;
			self.loddistance4 = 0;
			self.loddistance5 = 0;
			self.loddistance6 = 0;
		}
		self.solid = ReadByte();
		self.scale = ReadShort() / 256.0;
		if(f & 0x20)
		{
			self.mins_x = ReadCoord();
			self.mins_y = ReadCoord();
			self.mins_z = ReadCoord();
			self.maxs_x = ReadCoord();
			self.maxs_y = ReadCoord();
			self.maxs_z = ReadCoord();
		}
		else
			self.mins = self.maxs = '0 0 0';
		setsize(self, self.mins, self.maxs);

		if(self.bgmscript)
			strunzone(self.bgmscript);
		self.bgmscript = ReadString();
		if(substring(self.bgmscript, 0, 1) == "<")
		{
			self.bgmscript = strzone(substring(self.bgmscript, 1, -1));
			self.bgmscriptangular = 1;
		}
		else
		{
			self.bgmscript = strzone(self.bgmscript);
			self.bgmscriptangular = 0;
		}
		if(self.bgmscript != "")
		{
			self.bgmscriptattack = ReadByte() / 64.0;
			self.bgmscriptdecay = ReadByte() / 64.0;
			self.bgmscriptsustain = ReadByte() / 255.0;
			self.bgmscriptrelease = ReadByte() / 64.0;
			self.movedir_x = ReadCoord();
			self.movedir_y = ReadCoord();
			self.movedir_z = ReadCoord();
			self.lip = ReadByte() / 255.0;
		}
		BGMScript_InitEntity(self);
	}

	InterpolateOrigin_Note();

	self.saved = self.fld;

	self.entremove = Ent_Wall_Remove;
	self.draw = Ent_Wall_Draw;
}
