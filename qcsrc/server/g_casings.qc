float Casing_SendEntity(entity to, float sf)
{
	WriteByte(MSG_ENTITY, ENT_CLIENT_CASING);
	WriteByte(MSG_ENTITY, self.state); // actually type
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	WriteShort(MSG_ENTITY, self.oldorigin_x); // acrually compressed velocity
	WriteByte(MSG_ENTITY, self.angles_x * 256 / 360);
	WriteByte(MSG_ENTITY, self.angles_y * 256 / 360);
	WriteByte(MSG_ENTITY, self.angles_z * 256 / 360);
	return TRUE;
}

void SpawnCasing(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner)
{
	entity e;
	vector org;

	org = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;

	if(!sound_allowed(MSG_BROADCAST, casingowner))
		casingtype |= 0x80;

	e = spawn();
	e.state = casingtype;
	setorigin(e, org);
	e.velocity = vel;
	e.angles = ang;
	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, TRUE, 0.2, Casing_SendEntity);
		// 0.2s should be enough time for all clients to receive this ent once, do the gibbage and be done with it
}

//Same as above, but we allow an offset to our starting origin to be specified at the end, used usually for bull-pup weaps
void SpawnCasing_Offset(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, vector mycasingoffset)
{
	entity e;
	vector org;

	org = self.origin + self.view_ofs + self.weaponentity.spawnorigin_x * v_forward - self.weaponentity.spawnorigin_y * v_right + self.weaponentity.spawnorigin_z * v_up;
	org = org + (mycasingoffset_x * v_forward) - (mycasingoffset_y * v_right) + (mycasingoffset_z * v_up); //Do it the Same way
	
	if(!sound_allowed(MSG_BROADCAST, casingowner))
		casingtype |= 0x80;

	e = spawn();
	e.state = casingtype;
	setorigin(e, org);
	e.velocity = vel;
	e.angles = ang;
	e.oldorigin_x = compressShortVector(e.velocity);

	Net_LinkEntity(e, TRUE, 0.2, Casing_SendEntity);
		// 0.2s should be enough time for all clients to receive this ent once, do the gibbage and be done with it
}

//In t_items.qc
void SpawnLiveCartridge_Offset(vector vel, float randomvel, vector ang, vector avel, float randomavel, float casingtype, entity casingowner, vector mycasingoffset, float ammocost);
