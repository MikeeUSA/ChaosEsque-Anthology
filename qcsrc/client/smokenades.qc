void Smokenade_Delete()
{
	remove(self);
}

void SUB_SmokenadeRemoveOnNoImpact()
{
	if(trace_dphitq3surfaceflags & Q3SURFACEFLAG_NOIMPACT)
		Smokenade_Delete();
}

void Smokenade_Draw()
{
	vector oldorg;
	oldorg = self.origin;

	Movetype_Physics_MatchTicrate(0.1, autocvar_cl_gibs_sloppy);
	if(wasfreed(self))
		return;

	trailparticles(self, particleeffectnum("smoke_big"), oldorg, self.origin);

	self.renderflags = 0;

	self.nextthink -= frametime;

	self.alpha = bound(0, self.nextthink - time, 1);

	if(self.alpha < ALPHA_MIN_VISIBLE)
	{
		self.drawmask = 0;
		Smokenade_Delete();
	}
}

void TossSmokenade (vector safeorg, vector org)
{
	entity smokeage;

	smokeage = RubbleNew("smokeage");
	smokeage.classname = "smokeage";
	smokeage.move_movetype = MOVETYPE_NONE;
	smokeage.gravity = 1;
	smokeage.solid = SOLID_NOT;
	setmodel(smokeage, "null");
	setsize (smokeage, '-8 -8 -8', '8 8 8');
	smokeage.alpha = 1;
	smokeage.draw = Smokenade_Draw;
	smokeage.move_touch = SUB_SmokenadeRemoveOnNoImpact;

	// don't spawn smokeages inside solid - just don't
	if(org != safeorg)
	{
		tracebox(safeorg, smokeage.mins, smokeage.maxs, org, MOVE_NOMONSTERS, smokeage);
		org = trace_endpos;
	}

	smokeage.move_origin = org;
	setorigin(smokeage, org);
	smokeage.move_time = time;

	smokeage.nextthink = time + 125; //Time that it lasts in seconds
	smokeage.drawmask = MASK_NORMAL;
}

void Ent_SmokenadeSplash(float isNew)
{
	//float type;
	float soffset;
	soffset = 128;
	vector org, norg;

	//type = ReadByte(); //Maybe add in the future
	org_x = ReadLong() * 4 + 2; //Switched to long to support huge maps
	org_y = ReadLong() * 4 + 2;
	org_z = ReadLong() * 4 + 2;
	TossSmokenade (org, org);
	norg_x = org_x + soffset;
	norg_y = org_y + soffset;
	norg_z = org_z;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset;
	norg_y = org_y - soffset;
	TossSmokenade (norg, norg);
	norg_x = org_x + soffset;
	norg_y = org_y - soffset;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset;
	norg_y = org_y + soffset;
	TossSmokenade (norg, norg);
	///
	norg_x = org_x + soffset*2;
	norg_y = org_y + soffset*2;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset*2;
	norg_y = org_y - soffset*2;
	TossSmokenade (norg, norg);
	norg_x = org_x + soffset*2;
	norg_y = org_y - soffset*2;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset*2;
	norg_y = org_y + soffset*2;
	TossSmokenade (norg, norg);
	
	norg_x = org_x + soffset*2;
	norg_y = org_y + soffset;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset;
	norg_y = org_y - soffset*2;
	TossSmokenade (norg, norg);
	norg_x = org_x + soffset*2;
	norg_y = org_y - soffset;
	TossSmokenade (norg, norg);
	norg_x = org_x - soffset;
	norg_y = org_y + soffset*2;
	TossSmokenade (norg, norg);
}
