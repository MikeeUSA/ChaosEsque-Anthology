#ifdef INTERFACE
CLASS(XonoticUserSettingsTab) EXTENDS(XonoticTab)
	METHOD(XonoticUserSettingsTab, fill, void(entity))
	ATTRIB(XonoticUserSettingsTab, title, string, _("User"))
	ATTRIB(XonoticUserSettingsTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticUserSettingsTab, rows, float, 17)
	ATTRIB(XonoticUserSettingsTab, columns, float, 5)
ENDCLASS(XonoticUserSettingsTab)
entity makeXonoticUserSettingsTab();
#endif

#ifdef IMPLEMENTATION
entity makeXonoticUserSettingsTab()
{
	entity me;
	me = spawnXonoticUserSettingsTab();
	me.configureDialog(me);
	return me;
}

void XonoticUserSettingsTab_fill(entity me)
{
	entity e;
	entity sk;

	me.TR(me);
		me.TD(me, 1, 2, e = makeXonoticTextLabel(0, _("Menu skins:")));
	me.TR(me);
		me.TD(me, me.rows - 2, 2, sk = makeXonoticSkinList());
	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, 2, e = makeXonoticButton(_("Set skin"), '0 0 0'));
			e.onClick = SetSkin_Click;
			e.onClickEntity = sk;

	/* AFTER 0.6 RELEASE TODO: Add a listbox which has fonts too, this way user can select the font they want.
	me.gotoRC(me, 0, 2.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Text language:")));
	me.TR(me);
		me.TD(me, 6, 1, sk = makeXonoticLanguageList());
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Set language"), '0 0 0'));
			e.onClick = SetLanguage_Click;
			e.onClickEntity = sk;

	me.gotoRC(me, 0, 3.3); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1.5, e = makeXonoticTextLabel(0, _("Font:")));
	me.TR(me);
		me.TD(me, 2, 1.5, sk = makeXonoticLanguageList());
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1.5, e = makeXonoticButton(_("Set font"), '0 0 0'));
			e.onClick = SetLanguage_Click;
			e.onClickEntity = sk;*/
			
	me.gotoRC(me, 0, 3.1); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Text language:")));
	me.TR(me);
		me.TD(me, 6, 1, sk = makeXonoticLanguageList());
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Set language"), '0 0 0'));
			e.onClick = SetLanguage_Click;
			e.onClickEntity = sk;
		
	me.gotoRC(me, 8, 2.2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 1.6, e = makeXonoticCheckBox(0, "cl_gentle", _("Disable gore effects and harsh language")));
		if(cvar("cl_risque") >= 3) {
			me.TD(me, 1, 0.3, e = makeXonoticSlider(0, 3, 0.5, "cl_risque"));
				e.colorL = '0.2 0 0.1';
			me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Risque Level")));
				e.colorL = '0.2 0 0.1';
			me.TD(me, 1, 0.3, makeXonoticCommandButton(_("Apply"), '0.2 0 0.1', "bot_config_file bots2.txt; menu_restart;", COMMANDBUTTON_APPLY));
		} else if(cvar("cl_risque") >= 1) {
			me.TD(me, 1, 0.3, e = makeXonoticSlider(0, 1, 0.5, "cl_risque"));
				e.colorL = '0.2 0 0.1';
			me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Risque Level")));
				e.colorL = '0.2 0 0.1';
			me.TD(me, 1, 0.3, makeXonoticCommandButton(_("Apply"), '0.2 0 0.1', "bot_config_file bots2.txt; menu_restart;", COMMANDBUTTON_APPLY));
		} else {
			me.TD(me, 1, 0.3, e = makeXonoticSlider(0, 0.5, 0.5, "cl_risque"));
				e.colorL = '0.2 0 0.1';
			me.TD(me, 1, 0.5, e = makeXonoticTextLabel(0, _("Risque Level")));
				e.colorL = '0.2 0 0.1';
			if(cvar("cl_risque") >= 0.5) {
				me.TD(me, 1, 0.3, makeXonoticCommandButton(_("Apply"), '0.2 0 0.1', "bot_config_file bots1.txt; menu_restart;", COMMANDBUTTON_APPLY));
			} else {
				me.TD(me, 1, 0.3, makeXonoticCommandButton(_("Apply"), '0.2 0 0.1', "bot_config_file bots.txt; menu_restart;", COMMANDBUTTON_APPLY));
			}
		}	
		
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Mele Gore FX:")));
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Server")));
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 3, 1, "g_balance_svgorelvl"));
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Client")));
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 3, 1, "g_balance_clgorelvl"));
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Weapon")));
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 3, 1, "g_balance_melee_gorelvl"));
	me.TR(me);
	
	/////////////////////////////////
	
	me.gotoRC(me, 9.25, 2.2);
	me.TR(me);
		me.TDempty(me, 0.8);
		me.TD(me, 1, 0.666667, e = makeXonoticTextLabel(0, _("time")));
			e.colorL = '0.6 0.7 0.8';
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 1, 0.666667, e = makeXonoticTextLabel(0, _("traces")));
			e.colorL = '0.8 0.8 0.8';
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 1, 0.666667, e = makeXonoticTextLabel(0, _("backtraces")));
			e.colorL = '0.2 0.2 0.2';
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
	
	me.gotoRC(me, 9.25, 2.2);	
	me.TR(me);
		me.TD(me, 0.5, 0.8, e = makeXonoticCheckBox(0, "g_balance_torch_maxlighttraces_enable", _("Warpzone Light Trace:")));
		me.TD(me, 0.5, 0.666667, e = makeXonoticSlider(0.05, 0.15, 0.05, "g_balance_torch_maxlighttracestime"));
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 0.5, 0.666667, e = makeXonoticSlider(1, 11, 1, "g_balance_torch_maxlighttraces")); //Min set to 1 for the menu, use the enable/disable button to enable/disable completely
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 0.5, 0.466667, e = makeXonoticSlider(0, 9, 1, "g_balance_torch_maxlighttracesback"));
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 0.5, 0.1, e = makeXonoticCheckBox(0, "g_balance_torch_maxlighttracesbacknomorethanfwd", _("")));
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);
		me.TD(me, 0.5, 0.1, e = makeXonoticCheckBox(0, "g_balance_flashlight_maxlighttracesnomorethanfwd", _("")));
			setDependent(e, "g_balance_torch_maxlighttraces_enable", 1, 1);

		
	/////////////////////////////////
	
	/////////////////////////////////
	//
	/////////////////////////////////
	
	//First we do the text so it is "under" the sliders
	me.gotoRC(me, me.rows - 7, 2.2); me.setFirstColumn(me, me.currentColumn);
	
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Fragmentation Adjustment:")));
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("grenade I")));
			e.colorL = '0.2 0.7 0.2';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("grenade II")));
			e.colorL = '0.2 0.7 0.2';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("explosives")));
			e.colorL = '0.2 0.2 0.2';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("nieuport")));
			e.colorL = '0.5 0.25 0.0';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll37")));
			e.colorL = '0.2 0.1 0.4';
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("raptor")));
			e.colorL = '0.2 0.7 1';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankt27")));
			e.colorL = '0.253 0.25 0.165';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("sopwith I")));
			e.colorL = '0.7 0.7 0.2';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("sopwith II")));
			e.colorL = '0.7 0.7 0.0';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankiv")));
			e.colorL = '0.1 0.3 0.1';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankav7")));
			e.colorL = '0.2 0.2 0.2';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll48")));
			e.colorL = '0.5 0.0 0.0';
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll24")));
			e.colorL = '0.1 0.7 0.8';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll24:ai")));
			e.colorL = '0.7 0.0 0.0';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("eindecker I")));
			e.colorL = '0.5 0.8 0.5';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("eindecker II")));
			e.colorL = '0.5 0.8 0.5';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll24:aa")));
			e.colorL = '0.3 0.3 0.3';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll24:heat")));
			e.colorL = '1.0 0.5 0.0';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("tankll40")));
			e.colorL = '0.1 0.0 0.2';
	me.TR(me);
	/////////////////////////////////
	
	
	me.gotoRC(me, me.rows - 7, 2.2); me.setFirstColumn(me, me.currentColumn);
	
	me.TR(me);
		me.TDempty(me, 0.8);
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(5, 100, 1, "g_balance_grenadelauncher_primary_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(25, 500, 1, "g_balance_grenadelauncher_secondary_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(75, 1500, 1, "g_balance_explosivevest_primary_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(85, 1700, 1, "g_vehicle_nieuport_bomb_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(7, 130, 1, "g_vehicle_tankll37_cannon_fragments"));
	me.TR(me);
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(0, 3, 1, "g_vehicle_raptor_bomblet_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(10, 200, 1, "g_vehicle_tankt27_cannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(3, 75, 1, "g_vehicle_sopwith_bomb1_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(5, 100, 1, "g_vehicle_sopwith_bomb2_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(6, 125, 1, "g_vehicle_tankiv_cannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 50, 1, "g_vehicle_tanka7v_cannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 50, 1, "g_vehicle_tankll48_cannon_fragments"));
	me.TR(me);
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 25, 1, "g_vehicle_tankll24_cannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 15, 1, "g_vehicle_tankll24_aicannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 10, 1, "g_vehicle_eindecker_bomb1_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 15, 1, "g_vehicle_eindecker_bomb2_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(0, 3, 1, "g_vehicle_tankll24_aacannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(2, 10, 1, "g_vehicle_tankll24_heatcannon_fragments"));
		me.TD(me, 0.5, 0.4, e = makeXonoticSlider(0, 3, 1, "g_vehicle_tankll40_cannon_fragments"));

	me.TR(me);
	/////////////////////////////////

	//me.TR(me);
	//me.TR(me);
	//me.TR(me);
	/////////////////////////////////
	
		
	me.gotoRC(me, me.rows - 4, 2.2);
	me.TR(me);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_allow_uidtracking", _("Allow player statistics to track your client")));
	me.TR(me);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "cl_allow_uid2name", _("Allow player statistics to use your nickname")));
		setDependent(e, "cl_allow_uidtracking", 1, 1);
		
	me.gotoRC(me, me.rows - 1, 2.6);
		me.TD(me, 1, 2, makeXonoticCommandButton(_("Apply immediately"), '0 0 0', "sendcvar cl_gentle; sendcvar cl_allow_uidtracking; sendcvar cl_allow_uid2name;", COMMANDBUTTON_APPLY));

}
#endif
