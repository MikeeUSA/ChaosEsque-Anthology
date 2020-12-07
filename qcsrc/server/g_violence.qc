float Violence_GibSplash_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_GIBSPLASH);
	WriteByte(MSG_ENTITY, self.state); // actually type
	WriteByte(MSG_ENTITY, bound(1, self.cnt * 16, 255)); // gibbage amount multiplier
	//WriteShort(MSG_ENTITY, floor(self.origin_x / 4)); // not using a coord here, as gibs don't need this accuracy
	//WriteShort(MSG_ENTITY, floor(self.origin_y / 4)); // not using a coord here, as gibs don't need this accuracy
	//WriteShort(MSG_ENTITY, floor(self.origin_z / 4)); // not using a coord here, as gibs don't need this accuracy
	WriteLong(MSG_ENTITY, floor(self.origin_x / 4)); // Switched to long to support huge maps
	WriteLong(MSG_ENTITY, floor(self.origin_y / 4)); // still, gibs don't need super accuracy
	WriteLong(MSG_ENTITY, floor(self.origin_z / 4)); // but they need big coords sometimes	
	WriteShort(MSG_ENTITY, self.oldorigin_x); // acrually compressed velocity
	
	if (self.gibscale) {
		if (!self.scale)
			self.scale = self.gibscale;
		else
			self.scale = self.scale * self.gibscale;
	}
	
	if (!self.scale)
		WriteShort(MSG_ENTITY, 32); //32 = scale 1;
	else if ((self.scale) && (self.scale < 0.04)) //Below this is 0, which is taken as "no scaling"
		WriteShort(MSG_ENTITY, 1);
	else
		WriteShort(MSG_ENTITY, floor(self.scale * 32));
	
	WriteByte(MSG_ENTITY, self.skin);
	return TRUE;
}

// TODO maybe convert this to a TE?
void Violence_GibSplash_At(vector org, vector dir, float type, float amount, entity gibowner, entity attacker)
{
	if(g_cts) // no gibs in CTS
		return;

	entity e;

	e = spawn();
	e.classname = "gibsplash";
	e.cnt = amount;
	e.state = type; // should stay smaller than 15
	if(!sound_allowed(MSG_BROADCAST, gibowner) || !sound_allowed(MSG_BROADCAST, attacker))
		e.state |= 0x40; // "silence" bit
	e.state |= 8 * self.species; // gib type, ranges from 0 to 15

	// if this is a copied dead body, send the num of its player instead
	// TODO: remove this field, read from model txt files
	if(self.classname == "body")
		e.team = num_for_edict(self.enemy);
	else
		e.team = num_for_edict(self);

	if (gibowner.classname == "monster_minotaur")
		org_z = org_z + 32;

	setorigin(e, org);
	e.velocity = dir;

	e.oldorigin_x = compressShortVector(e.velocity);
	
	e.scale = gibowner.scale;
	e.gibscale = gibowner.gibscale;
	
	if (gibowner.species == SPECIES_SKELETON)
	{
		if (gibowner.stoned)
			e.skin = 3;
		else if (gibowner.skin == 4 || gibowner.skin == 8 || gibowner.skin == 12) //Same color as 0 but no armor
			e.skin = 0;
		else if (gibowner.skin == 5 || gibowner.skin == 9 || gibowner.skin == 13) //Same color as 1 but no armor
			e.skin = 1;
		else if (gibowner.skin == 6 || gibowner.skin == 10 || gibowner.skin == 14) //Same color as 2 but no armor
			e.skin = 2;	
		else
			e.skin = gibowner.skin;
	}
	else if (gibowner.stoned)
		e.skin = 8;
	else
		e.skin = 0;

	Net_LinkEntity(e, FALSE, 0.2, Violence_GibSplash_SendEntity);
}

void Violence_GibSplash(entity source, float type, float amount, entity attacker)
{
	Violence_GibSplash_At(source.origin + source.view_ofs, source.velocity, type, amount, source, attacker);
}
