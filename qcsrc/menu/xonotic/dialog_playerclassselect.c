#ifdef INTERFACE
CLASS(XonoticPlayerclassSelectDialog) EXTENDS(XonoticRootDialog)
	METHOD(XonoticPlayerclassSelectDialog, fill, void(entity)) // to be overridden by user to fill the dialog with controls
	METHOD(XonoticPlayerclassSelectDialog, showNotify, void(entity))
	ATTRIB(XonoticPlayerclassSelectDialog, title, string, _("Player Class Selection")) // ;)
	ATTRIB(XonoticPlayerclassSelectDialog, color, vector, SKINCOLOR_DIALOG_TEAMSELECT)
	ATTRIB(XonoticPlayerclassSelectDialog, intendedWidth, float, 0.4)
	ATTRIB(XonoticPlayerclassSelectDialog, rows, float, 9)
	ATTRIB(XonoticPlayerclassSelectDialog, columns, float, 4)
	ATTRIB(XonoticPlayerclassSelectDialog, name, string, "PlayerClassSelect")
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_longdistance, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_marksman, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_mediumdistance, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_assault, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_closerange, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_destructive, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_heavyweapons, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_promaniac, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_engineer, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_worker, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_healer, entity, NULL)
	ATTRIB(XonoticPlayerclassSelectDialog, playerclass_none, entity, NULL)
	
ENDCLASS(XonoticPlayerclassSelectDialog)
#endif

#ifdef IMPLEMENTATION
entity makePlayerclassButton(string theName, vector theColor, string commandtheName)
{
	entity b;
	b = makeXonoticBigCommandButton(theName, theColor, commandtheName, 1);
	return b;
}

void XonoticPlayerclassSelectDialog_showNotify(entity me)
{
	float pclass_ld, pclass_md, pclass_as;
	float pclass_cr, pclass_de, pclass_hw;
	float pclass_py, pclass_en, pclass_wk;
	float pclass_hl;
	float pclass_mk;
	float pclass_none;
	float pclassset;
	pclass_ld = cvar("_playerclass_longdistance");
	pclass_mk = cvar("_playerclass_marksman");
	pclass_md = cvar("_playerclass_mediumdistance");
	pclass_as = cvar("_playerclass_assault");
	pclass_cr = cvar("_playerclass_closerange");
	pclass_de = cvar("_playerclass_destructive");
	pclass_hw = cvar("_playerclass_heavyweapons");
	pclass_py = cvar("_playerclass_pyromaniac");
	pclass_en = cvar("_playerclass_engineer");
	pclass_wk = cvar("_playerclass_worker");
	pclass_hl = cvar("_playerclass_healer");
	pclass_none = 1;
	
	pclassset = cvar("_playerclassset");
	
	me.playerclass_longdistance.disabled = !(pclass_ld);
	me.playerclass_marksman.disabled = !(pclass_mk);
	me.playerclass_mediumdistance.disabled = !(pclass_md);
	me.playerclass_assault.disabled = !(pclass_as);
	me.playerclass_closerange.disabled = !(pclass_cr);
	me.playerclass_destructive.disabled = !(pclass_de);
	me.playerclass_heavyweapons.disabled = !(pclass_hw);
	me.playerclass_promaniac.disabled = !(pclass_py);
	me.playerclass_engineer.disabled = !(pclass_en);
	me.playerclass_worker.disabled = !(pclass_wk);
	me.playerclass_healer.disabled = !(pclass_hl);
	me.playerclass_none.disabled = !(pclass_none);

	//Here we configure non-default playerclasses	
	//entity pc_ld, pc_mk, pc_md, pc_as, pc_cr;
	//entity pc_de, pc_hw, pc_py, pc_en, pc_wk;
	//entity pc_hl,
	
	entity pc_ld = me.playerclass_longdistance;
	entity pc_mk = me.playerclass_marksman;
	entity pc_md = me.playerclass_mediumdistance;
	entity pc_as = me.playerclass_assault;
	entity pc_cr = me.playerclass_closerange;
	entity pc_de = me.playerclass_destructive;
	entity pc_hw = me.playerclass_heavyweapons;
	entity pc_py = me.playerclass_promaniac;
	entity pc_en = me.playerclass_engineer;
	entity pc_wk = me.playerclass_worker;
	entity pc_hl = me.playerclass_healer;
	
	
	if (pclassset == 21) {
	//Medieval Fantasy
		pc_ld.configureXonoticBigCommandButton(pc_ld, _("Ite"), '1 0.5 0.5', "cmd playerclass longdistance", 1);
		pc_mk.configureXonoticBigCommandButton(pc_mk, _("Archer"), '0.8 0.7 0.6', "cmd playerclass marksman", 1);
		pc_md.configureXonoticBigCommandButton(pc_md, _("Rogue"), '0.65 0.4 0.2', "cmd playerclass mediumdistance", 1);
		pc_as.configureXonoticBigCommandButton(pc_as, _("Samurai"), '0.7 0.0 0.0', "cmd playerclass assault", 1);
		pc_cr.configureXonoticBigCommandButton(pc_cr, _("Warrior"), '0.3 0.3 0.3', "cmd playerclass closerange", 1);
		pc_de.configureXonoticBigCommandButton(pc_de, _("Barbarian"), '0.1 0.1 0.1', "cmd playerclass destructive", 1);
		pc_hw.configureXonoticBigCommandButton(pc_hw, _("Paladin"), '1 1 1', "cmd playerclass heavyweapons", 1);
		//pc_py.configureXonoticBigCommandButton(pc_py, _("Pyromancer"), '1 0.75 0.5', "cmd playerclass pyromaniac", 1);
		pc_py.configureXonoticBigCommandButton(pc_py, _("Necromancer"), '1 0.75 0.5', "cmd playerclass pyromaniac", 1);
		pc_en.configureXonoticBigCommandButton(pc_en, _("Sorcerer"), '0.75 0.75 0.1', "cmd playerclass engineer", 1);
		pc_wk.configureXonoticBigCommandButton(pc_wk, _("Peasant"), '0.7 0.6 0.5', "cmd playerclass worker", 1);
		pc_hl.configureXonoticBigCommandButton(pc_hl, _("Healer"), '0.5 1 0.5', "cmd playerclass healer", 1);
	} else if (pclassset == 11) {
	//Default 1
		pc_ld.configureXonoticBigCommandButton(pc_ld, _("LongDistance"), '1 0.5 1', "cmd playerclass longdistance", 1);
		pc_mk.configureXonoticBigCommandButton(pc_mk, _("Marksman"), '0.5 1 1', "cmd playerclass marksman", 1);
		pc_md.configureXonoticBigCommandButton(pc_md, _("MediumDistance"), '0.5 0.5 1', "cmd playerclass mediumdistance", 1);
		pc_as.configureXonoticBigCommandButton(pc_as, _("Assault"), '1 0.5 0.5', "cmd playerclass assault", 1);
		pc_cr.configureXonoticBigCommandButton(pc_cr, _("CloseRange"), '0.3 0.3 0.3', "cmd playerclass closerange", 1);
		pc_de.configureXonoticBigCommandButton(pc_de, _("Destructive"), '1 0.85 0.5', "cmd playerclass destructive", 1);
		pc_hw.configureXonoticBigCommandButton(pc_hw, _("HeavyWeapons"), '1 0 0', "cmd playerclass heavyweapons", 1);
		pc_py.configureXonoticBigCommandButton(pc_py, _("Pyromaniac"), '1 0.75 0.5', "cmd playerclass pyromaniac", 1);
		pc_en.configureXonoticBigCommandButton(pc_en, _("Engineer"), '0.1 0.1 0.1', "cmd playerclass engineer", 1);
		pc_wk.configureXonoticBigCommandButton(pc_wk, _("Worker"), '0.7 0.6 0.5', "cmd playerclass worker", 1);
		pc_hl.configureXonoticBigCommandButton(pc_hl, _("Healer"), '0.5 1 0.5', "cmd playerclass healer", 1);
	} else if (pclassset == 31) {
	//Old West
		pc_ld.configureXonoticBigCommandButton(pc_ld, _("Sharpshooter"), '1 1 0.75', "cmd playerclass longdistance", 1);
		pc_mk.configureXonoticBigCommandButton(pc_mk, _("Deadeye"), '0.1 0.1 0.1', "cmd playerclass marksman", 1);
		pc_md.configureXonoticBigCommandButton(pc_md, _("Solider"), '0.5 0.5 0.75', "cmd playerclass mediumdistance", 1);
		pc_as.configureXonoticBigCommandButton(pc_as, _("Cavalryman"), '0.7 0.6 0.5', "cmd playerclass assault", 1);
		pc_cr.configureXonoticBigCommandButton(pc_cr, _("ShotgunMessenger"), '1 0.75 0.5', "cmd playerclass closerange", 1);
		pc_de.configureXonoticBigCommandButton(pc_de, _("Outlaw"), '0.8 0.4 0.2', "cmd playerclass destructive", 1);
		pc_hw.configureXonoticBigCommandButton(pc_hw, _("Homesteader"), '0.2 0.5 0.2', "cmd playerclass heavyweapons", 1);
		pc_py.configureXonoticBigCommandButton(pc_py, _("Gunslinger"), '0.2 0.2 0.2', "cmd playerclass pyromaniac", 1);
		pc_en.configureXonoticBigCommandButton(pc_en, _("Lawman"), '0.5 0.5 0.5', "cmd playerclass engineer", 1);
		pc_wk.configureXonoticBigCommandButton(pc_wk, _("Farmhand"), '0.7 0.8 0.5', "cmd playerclass worker", 1);
		pc_hl.configureXonoticBigCommandButton(pc_hl, _("Doctor"), '1 1 1', "cmd playerclass healer", 1);
	} else if (pclassset == 41) {
	//Xon 
		pc_ld.configureXonoticBigCommandButton(pc_ld, _("Xon"), '1 0.6 1', "cmd playerclass longdistance", 1);
		pc_mk.configureXonoticBigCommandButton(pc_mk, _("Sniper"), '0.5 0.5 0.5', "cmd playerclass marksman", 1);
		pc_md.configureXonoticBigCommandButton(pc_md, _("MediumDistance"), '0.6 0.6 0.5', "cmd playerclass mediumdistance", 1);
		pc_as.configureXonoticBigCommandButton(pc_as, _("HeavyAssault"), '0.8 0.0 0.0', "cmd playerclass assault", 1);
		pc_cr.configureXonoticBigCommandButton(pc_cr, _("CloseRange"), '0.1 0.1 0.1', "cmd playerclass closerange", 1);
		pc_de.configureXonoticBigCommandButton(pc_de, _("Destructive"), '1 0.89 0.5', "cmd playerclass destructive", 1);
		pc_hw.configureXonoticBigCommandButton(pc_hw, _("HeavyWeapons"), '1 0.5 0.2', "cmd playerclass heavyweapons", 1);
		pc_py.configureXonoticBigCommandButton(pc_py, _("Electromaniac"), '0.5 0.6 1.0', "cmd playerclass pyromaniac", 1);
		pc_en.configureXonoticBigCommandButton(pc_en, _("ElectricalEngineer"), '0.3 0.75 0.95', "cmd playerclass engineer", 1);
		pc_wk.configureXonoticBigCommandButton(pc_wk, _("LaserAscendant"), '0.8 0.5 0.5', "cmd playerclass worker", 1);
		pc_hl.configureXonoticBigCommandButton(pc_hl, _("Cryromancer"), '0.7 0.3 1.0', "cmd playerclass healer", 1);
	} else if (pclassset == 51) {
	//WWI
		pc_ld.configureXonoticBigCommandButton(pc_ld, _("Sniper"), '0.9 0.9 0.9', "cmd playerclass longdistance", 1);
		pc_mk.configureXonoticBigCommandButton(pc_mk, _("Marksman"), '0.7 0.7 0.5', "cmd playerclass marksman", 1);
		pc_md.configureXonoticBigCommandButton(pc_md, _("Solider"), '0.7 0.6 0.5', "cmd playerclass mediumdistance", 1);
		pc_as.configureXonoticBigCommandButton(pc_as, _("Assault"), '0.7 0.5 0.5', "cmd playerclass assault", 1);
		pc_cr.configureXonoticBigCommandButton(pc_cr, _("Shotgunner"), '0.7 0.5 0.3', "cmd playerclass closerange", 1);
		pc_de.configureXonoticBigCommandButton(pc_de, _("Trenchbroom"), '0.5 0.3 0.2', "cmd playerclass destructive", 1);
		pc_hw.configureXonoticBigCommandButton(pc_hw, _("Machinegunner"), '0.3 0.3 0.3', "cmd playerclass heavyweapons", 1);
		pc_py.configureXonoticBigCommandButton(pc_py, _("Assaultgunner"), '0.1 0.1 0.1', "cmd playerclass pyromaniac", 1);
		pc_en.configureXonoticBigCommandButton(pc_en, _("Engineer"), '0.2 0.2 0.2', "cmd playerclass engineer", 1);
		pc_wk.configureXonoticBigCommandButton(pc_wk, _("En-trencher"), '0.7 0.6 0.5', "cmd playerclass worker", 1);
		pc_hl.configureXonoticBigCommandButton(pc_hl, _("Doctor"), '0.6 0.7 0.6', "cmd playerclass healer", 1);
	} 
}

void XonoticPlayerclassSelectDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 4, me.playerclass_none = makePlayerclassButton(_("No Change"), '0.8 0.8 0.8', "cmd join"));
	me.TR(me);
		me.TD(me, 2, 1, me.playerclass_longdistance = makePlayerclassButton(_("PC 1"), '0.7 0.2 0.7', "cmd playerclass longdistance"));		
		me.TD(me, 2, 1, me.playerclass_marksman = makePlayerclassButton(_("PC 2"), '0.2 0.7 0.7', "cmd playerclass marksman"));
		me.TD(me, 2, 1, me.playerclass_mediumdistance = makePlayerclassButton(_("PC 3"), '0.2 0.2 0.7', "cmd playerclass mediumdistance"));
		me.TD(me, 2, 1, me.playerclass_assault = makePlayerclassButton(_("PC 4"), '0.7 0.2 0.2', "cmd playerclass assault"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.playerclass_closerange = makePlayerclassButton(_("PC 5"), '0.1 0.1 0.1', "cmd playerclass closerange"));
		me.TD(me, 2, 1, me.playerclass_destructive = makePlayerclassButton(_("PC 6"), '0.7 0.55 0.2', "cmd playerclass destructive"));
		me.TD(me, 2, 1, me.playerclass_heavyweapons = makePlayerclassButton(_("PC 7"), '0.7 0 0', "cmd playerclass heavyweapons"));
		me.TD(me, 2, 1, me.playerclass_promaniac = makePlayerclassButton(_("PC 8"), '0.7 0.45 0.2', "cmd playerclass pyromaniac"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 1, me.playerclass_engineer = makePlayerclassButton(_("PC 9"), '0.01 0.01 0.01', "cmd playerclass engineer"));
		me.TD(me, 2, 1, me.playerclass_worker = makePlayerclassButton(_("PC 10"), '0.4 0.3 0.2', "cmd playerclass worker"));
		me.TD(me, 2, 1, me.playerclass_healer = makePlayerclassButton(_("PC 11"), '0.2 0.7 0.2', "cmd playerclass healer"));
	me.TR(me);
	me.TR(me);
		me.TD(me, 2, 4, me.playerclass_none = makePlayerclassButton(_("None"), '0.5 0.5 0.5', "cmd playerclass none"));
	me.TR(me);


}
#endif

/* Click. The c-word is here so you can grep for it :-) */
