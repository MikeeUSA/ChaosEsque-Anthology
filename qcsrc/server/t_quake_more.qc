//***********************
//QUAKE 1 ENTITIES - So people can play quake1 maps with the xonotic weapons
//***********************
// There are some compiler conflicts with map as a .string, so here 
//are entities where there is a problem, moved after the problematic code
//in progs.src (specifically placed after race.qc which was giving problems
//race.qc:141: error: invalid type for parameter 1 in function call: expected string, got .string
//race.qc:147: error: invalid type for parameter 1 in function call: expected string, got .string
//race.qc:234: error: invalid type for parameter 1 in function call: expected string, got .string
//race.qc:235: error: invalid type for parameter 1 in function call: expected string, got .string
//race.qc:238: error: invalid type for parameter 1 in function call: expected string, got .string
//race.qc:239: error: invalid type for parameter 1 in function call: expected string, got .string

.string map;
void trigger_changelevel_use()
{
	if(self.gametype != "")
		MapInfo_SwitchGameType(MapInfo_Type_FromString(self.gametype));

	if (self.map == "")
		localcmd("endmatch\n");
	else
		localcmd(strcat("changelevel ", self.map, "\n"));
}
void trigger_changelevel_touch()
{
	if(clienttype(other) != CLIENTTYPE_REAL)
		return; //We don't want bullets activating us.
	
	trigger_changelevel_use();
}
void trigger_changelevel(void)
{
	EXACTTRIGGER_INIT;
	self.touch = trigger_changelevel_touch;
	self.use = trigger_changelevel_use;
}
