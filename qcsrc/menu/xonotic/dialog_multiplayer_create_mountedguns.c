#ifdef INTERFACE
CLASS(XonoticMountedgunsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticMountedgunsDialog, fill, void(entity))
	METHOD(XonoticMountedgunsDialog, showNotify, void(entity))
	METHOD(XonoticMountedgunsDialog, close, void(entity))
	ATTRIB(XonoticMountedgunsDialog, title, string, _("Team mounted guns"))
	ATTRIB(XonoticMountedgunsDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticMountedgunsDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticMountedgunsDialog, rows, float, 17)
	ATTRIB(XonoticMountedgunsDialog, columns, float, 4)
	ATTRIB(XonoticMountedgunsDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticMountedgunsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticMountedgunsDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticMountedgunsDialog_fill(entity me)
{
	entity e;
	
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticCheckBox(0, "g_spawnmountedgunsaround", _("Random Mounted Guns")));
		
		me.TD(me, 1, 1.5, e = makeXonoticSlider(1, 30, 1, "g_spawnmountedgunsaround_max"));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmountedgunsaround_shield"));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Shields")));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TR(me);
	me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Default")), '0 0 0', "exec mountedgunsamnt_default.cfg", 0));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Ancient")), '0 0 0', "exec mountedgunsamnt_ancient.cfg", 0));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Equal")), '0 0 0', "exec mountedgunsamnt_equal.cfg", 0));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^None")), '0 0 0', "exec mountedgunsamnt_none.cfg", 0));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
//Team1
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Team 1:"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M134"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_m134_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GAU19"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_gau19_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MHB50"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_browning50_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("T17MM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_t17mm_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GRail"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_grail_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AutoNex"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_autonex_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SHLAC"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_shlac_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BPCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_bpcannon_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPK"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_rpk_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Spadu"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_spadu_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Maxim"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_maxim_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lewisgun"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_lewis_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Scorpion"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_scorpion_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Charbelcher"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_charbelcher_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BatteringRam"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_batteringram_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Deluge"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_deluge_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SiegeMortar"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_siegemortar_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Hotchkiss"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_hotchkissm1914_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LaserCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_lasercannon_red_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Gatling1877"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_gatling1877_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPD"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_rpd_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M249Para"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_m249para_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PKM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team1_pkm_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	
//Team2
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Team 2:"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M134"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_m134_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GAU19"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_gau19_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MHB50"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_browning50_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("T17MM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_t17mm_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GRail"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_grail_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AutoNex"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_autonex_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SHLAC"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_shlac_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BPCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_bpcannon_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPK"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_rpk_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Spadu"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_spadu_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Maxim"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_maxim_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lewisgun"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_lewis_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Scorpion"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_scorpion_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Charbelcher"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_charbelcher_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BatteringRam"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_batteringram_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Deluge"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_deluge_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SiegeMortar"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_siegemortar_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Hotchkiss"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_hotchkissm1914_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LaserCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_lasercannon_red_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Gatling1877"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_gatling1877_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPD"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_rpd_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M249Para"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_m249para_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PKM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0 0 1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_team2_pkm_amnt")); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	
	
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticMountedgunsDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticMountedgunsDialog).close(me);
}
#endif
