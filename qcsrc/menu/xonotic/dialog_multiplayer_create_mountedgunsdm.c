#ifdef INTERFACE
CLASS(XonoticMountedgunsdmDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticMountedgunsdmDialog, fill, void(entity))
	METHOD(XonoticMountedgunsdmDialog, showNotify, void(entity))
	METHOD(XonoticMountedgunsdmDialog, close, void(entity))
	ATTRIB(XonoticMountedgunsdmDialog, title, string, _("Mounted guns"))
	ATTRIB(XonoticMountedgunsdmDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticMountedgunsdmDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticMountedgunsdmDialog, rows, float, 9)
	ATTRIB(XonoticMountedgunsdmDialog, columns, float, 4)
	ATTRIB(XonoticMountedgunsdmDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticMountedgunsdmDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticMountedgunsdmDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticMountedgunsdmDialog_fill(entity me)
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

	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M134"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_m134_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GAU19"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_gau19_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("MHB50"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_browning50_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("T17MM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.3 0.3 0.3';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_t17mm_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.3 0.3 0.3';
		
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("GRail"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_grail_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("AutoNex"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_autonex_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SHLAC"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_shlac_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BPCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_bpcannon_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.7 1.0 1.0';
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPK"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.25 0.16';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_rpk_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.25 0.16';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Spadu"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.2 0.2 0.2';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_spadu_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.2 0.2 0.2';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Maxim"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.15 0.15 0.15';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_maxim_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.15 0.15 0.15';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Lewisgun"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_lewis_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Scorpion"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_scorpion_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Charbelcher"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_charbelcher_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("BatteringRam"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_batteringram_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.05 0.0';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Deluge"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_deluge_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	
	
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("SiegeMortar"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.1 0.1';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_siegemortar_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.1 0.1 0.1';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Hotchkiss"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_hotchkissm1914_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.253 0.25 0.165';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("LaserCannon"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1.0 0.7 0.7';
		
		me.TD(me, 1, 0.0625, e = makeXonoticCheckBox(0, "g_spawnmountedgunsaround_lasercannon_red_randomcolor", _("")));
		setDependentAND(e, "g_spawnmountedgunsaround", 1, 1, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1.0 0.7 0.7';
		
		me.TD(me, 1, 0.0625, e = makeXonoticCheckBox(0, "g_spawnmountedgunsaround_lasercannon_red_randomtype", _("")));
		setDependentAND(e, "g_spawnmountedgunsaround", 1, 1, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1.0 0.7 0.7';
		
		me.TD(me, 1, 0.625, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_lasercannon_red_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '1.0 0.7 0.7';
		
		me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("Gatling1877"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.25 0.25 0.2';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_gatling1877_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.25 0.25 0.2';
		
	me.TR(me);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("RPD"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.20 0.25';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_rpd_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.20 0.25';
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("M249Para"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		//e.colorL = '0 0 0';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_m249para_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TD(me, 1, 0.25, e = makeXonoticTextLabel(0, _("PKM"))); setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.45 0.20';
		me.TD(me, 1, 0.75, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmountedgunsaround_pkm_amnt"));
		setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		e.colorL = '0.5 0.45 0.20';
	
	
	
	
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticMountedgunsdmDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticMountedgunsdmDialog).close(me);
}
#endif
