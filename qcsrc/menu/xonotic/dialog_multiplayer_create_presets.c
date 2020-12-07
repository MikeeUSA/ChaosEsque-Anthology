#ifdef INTERFACE
CLASS(XonoticPresetsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticPresetsDialog, fill, void(entity))
	METHOD(XonoticPresetsDialog, showNotify, void(entity))
	METHOD(XonoticPresetsDialog, close, void(entity))
	ATTRIB(XonoticPresetsDialog, title, string, _("Presets"))
	ATTRIB(XonoticPresetsDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticPresetsDialog, intendedWidth, float, 0.9)
	ATTRIB(XonoticPresetsDialog, rows, float, 21)
	ATTRIB(XonoticPresetsDialog, columns, float, 4)
	ATTRIB(XonoticPresetsDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticPresetsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticPresetsDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticPresetsDialog_fill(entity me)
{
	entity e;

	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Medieval Fantasy Quest")), '0 0 0', "exec presets_medievalfantasyquest.cfg", 0));
			e.colorL = '0.75 0.2 1';
		me.TD(me, 3, 3, e = makeXonoticTextLabel(0, _("A quest where medieval weapons and magic is present, in addition to monsters. Spell books and scrolls are distributed throughout the map, potions of mana and health appear, medieval weapons take the place of what would otherwise be offered for conferance")));
			e.colorL = '0.75 0 1';
			e.allowCut = 0;
			e.allowWrap = 1;
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(ZCTX(_("PRE^MFQ: Small")), '0 0 0', "exec presets_medievalfantasyquest_small.cfg", 0));
			e.colorL = '0.75 0.2 1';
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(ZCTX(_("PRE^MFQ: DM")), '0 0 0', "exec presets_medievalfantasyquest_dm.cfg", 0));
			e.colorL = '0.75 0.2 1';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^MFQ: Dark")), '0 0 0', "exec presets_medievalfantasyquest_dark.cfg", 0));
			e.colorL = '0.75 0.2 1';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^MFQ: One")), '0 0 0', "exec presets_medievalfantasyquest_one.cfg", 0));
			e.colorL = '0.375 0 0.5';
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("An iron knife and one life")));
			e.colorL = '0.375 0 0.5';
			e.allowCut = 0;
			e.allowWrap = 1;
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Misc Mix")), '0 0 0', "exec presets_miscmix.cfg", 0));
			e.colorL = '0.3 0.7 1';
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("A mix of weapons across the map")));
			e.colorL = '0.3 0.7 1';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Action Quest")), '0 0 0', "exec presets_modernactionquest.cfg", 0));
			e.colorL = '0.1 0.1 0.1';
		me.TD(me, 2, 3, e = makeXonoticTextLabel(0, _("A quest where modern action weapons are present, in addition to modern and futuristic monsters, presented for fully automatic slaughter")));
			e.colorL = '0.1 0.1 0.1';
			e.allowCut = 0;
			e.allowWrap = 1;
	me.TR(me);
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(ZCTX(_("PRE^AQ: Small")), '0 0 0', "exec presets_modernactionquest_small.cfg", 0));
			e.colorL = '0.1 0.1 0.1';
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(ZCTX(_("PRE^AQ: DM")), '0 0 0', "exec presets_modernactionquest_dm.cfg", 0));
			e.colorL = '0.1 0.1 0.1';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Zombie Apocalypse Quest")), '0 0 0', "exec presets_zombieapocalypsequest.cfg", 0));
			e.colorL = '0.75 0 0';
		me.TD(me, 3, 3, e = makeXonoticTextLabel(0, _("You, a crowbar, and perhaps a light...")));
			e.colorL = '0.5 0 0';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^ZAQ: DM")), '0 0 0', "exec presets_zombieapocalypsequest_dm.cfg", 0));
			e.colorL = '0.75 0 0';	
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^ZAQ: Dark")), '0 0 0', "exec presets_zombieapocalypsequest_dark.cfg", 0));
			e.colorL = '0.75 0 0';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Bare Knuckle Brawling")), '0 0 0', "exec presets_bareknucklebrawling.cfg", 0));
			e.colorL = '0.0 1 0.7';
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("No weapons, no limits")));
			e.colorL = '0.0 1 0.7';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Brutal Realism Brawling")), '0 0 0', "exec presets_brutalrealismbrawling.cfg", 0));
			e.colorL = '0.3 0.5 0.3';
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("There are limits, and no quick wins")));
			e.colorL = '0.3 0.5 0.3';
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Default")), '0 0 0', "exec presets_default.cfg", 0));
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("The default setting, a pistol")));
	me.TR(me);
	
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^BUILD: Utili-tool")), '0 0 0', "exec presetbuildable_utilitool.cfg", 0));
			e.colorL = '1.0 1.0 0.7';
		me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^BUILD: Multi-tool")), '0 0 0', "exec presetbuildable_multitool.cfg", 0));
			e.colorL = '0.1 0.05 0.0';
		me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^BUILD: Utili-tool And Multi-tool")), '0 0 0', "exec presetbuildable_multitoolandutilitool.cfg", 0));
			//e.colorL = '0.1 0.1 0.1';
		
		me.TD(me, 2, 1.6, e = makeXonoticTextLabel(0, _("Build futuristic buildings using the utili-tool or medieval buildings using the multi-tool.")));
			e.allowCut = 0;
			e.allowWrap = 1;
	me.TR(me);
		me.TD(me, 1, 2.4, e = makeXonoticCommandButton(ZCTX(_("PRE^BUILD: Nothing (Default)")), '0 0 0', "exec presetbuildable_resetall.cfg", 0));
	
	me.TR(me);
		me.TD(me, 1, 1.1, e = makeXonoticCommandButton(ZCTX(_("PRE^COST: Tm, Knwlg, Rsrcs (Default)")), '0 0 0', "exec presetbuildable_cost_resetall.cfg", 0));
			e.colorL = '0.5 0.5 0.5';
		me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^COST: Nothing")), '0 0 0', "exec presetbuildable_cost_nothing.cfg", 0));
			e.colorL = '0.7 0.7 0.7';
		me.TD(me, 1, 0.5, e = makeXonoticCommandButton(ZCTX(_("PRE^COST: Completely Free")), '0 0 0', "exec presetbuildable_cost_completelyfree.cfg", 0));
			e.colorL = '1.0 1.0 1.0';
		
		
		me.TD(me, 2, 1.6, e = makeXonoticTextLabel(0, _("How much building costs: Time, Knowlege, and Resources - Nothing upfront - Everything completely free.")));
			e.allowCut = 0;
			e.allowWrap = 1;
	me.TR(me);
	
	me.gotoRC(me, me.rows - 3, 0);
			me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^SC Tiles City")), '0 0 0', "exec presetcity_sctiles.cfg", 0));
				e.colorL = '0.5 1 1';
			me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^Aorist City")), '0 0 0', "exec presetcity_future.cfg", 0));
				e.colorL = '0.9 0.7 1.0';
			me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^Medieval City")), '0 0 0', "exec presetcity_medieval.cfg", 0));
				e.colorL = '0.1 0.05 0.0';
			me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^SC/Aor/Med City")), '0 0 0', "exec presetcity_all.cfg", 0));
				e.colorL = '0.1 0.1 0.1';
			me.TD(me, 1, 0.8, e = makeXonoticCommandButton(ZCTX(_("PRE^No City")), '0 0 0', "exec presetcity_resetall.cfg", 0));
	me.TR(me);
		me.TD(me, 1, 4, e = makeXonoticTextLabel(0, _("Will a city into existence. Best for use on large maps. Additional city configuration options in the   Multiplayer > Create > Mutator   menu, under    Misc Items")));
			e.allowCut = 0;
			e.allowWrap = 1;
			
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticPresetsDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticPresetsDialog).close(me);
}
#endif
