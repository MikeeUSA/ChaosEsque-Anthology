#ifdef INTERFACE
CLASS(XonoticServerCreateTab) EXTENDS(XonoticTab)
	METHOD(XonoticServerCreateTab, fill, void(entity))
	METHOD(XonoticServerCreateTab, gameTypeChangeNotify, void(entity))
	ATTRIB(XonoticServerCreateTab, title, string, _("Create"))
	ATTRIB(XonoticServerCreateTab, intendedWidth, float, 0.9)
	ATTRIB(XonoticServerCreateTab, rows, float, 22)
	ATTRIB(XonoticServerCreateTab, columns, float, 6.2) // added extra .2 for center space 

	ATTRIB(XonoticServerCreateTab, mapListBox, entity, NULL)
	ATTRIB(XonoticServerCreateTab, sliderFraglimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, sliderTimelimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, checkboxFraglimit, entity, NULL)
	ATTRIB(XonoticServerCreateTab, checkboxFraglimitMapinfo, entity, NULL)
	ATTRIB(XonoticServerCreateTab, buttonStartweapons, entity, NULL)
	ATTRIB(XonoticServerCreateTab, buttonStartmagic, entity, NULL)
	ATTRIB(XonoticServerCreateTab, buttonMountedguns, entity, NULL)
	ATTRIB(XonoticServerCreateTab, buttonVehicles, entity, NULL)
ENDCLASS(XonoticServerCreateTab)
entity makeXonoticServerCreateTab();
#endif

#ifdef IMPLEMENTATION

entity makeXonoticServerCreateTab()
{
	entity me;
	me = spawnXonoticServerCreateTab();
	me.configureDialog(me);
	return me;
}

void XonoticServerCreateTab_fill(entity me)
{
	entity e, e0;

	me.TR(me);
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Game type:")));
	me.TR(me);
		me.TD(me, 8, 3, e = makeXonoticGametypeList());
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		//me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Match settings:"))); // pointless, overcrowds the dialog imo
	me.TR(me);
		me.sliderTimelimit = makeXonoticSlider(1.0, 60.0, 1, "timelimit_override");
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(0, 1, me.sliderTimelimit, _("Time limit:")));
		me.TD(me, 1, 2, me.sliderTimelimit);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticSliderCheckBox(-1, 0, me.sliderTimelimit, _("Use map specified default")));
		
		me.TD(me, 1, 0.65, e = makeXonoticCheckBox(0, "g_colorwar", _("Colorwar")));
			e.cvarOffValue = "0";
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "bot_colorwar_ignoresame", _("")));
			e.cvarOffValue = "0";
			setDependent(e, "g_colorwar", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_colorwar_nodamagetosame", _("")));
			e.cvarOffValue = "0";
			setDependent(e, "g_colorwar", 1, 1);
		me.TDempty(me, 0.15);
	me.TR(me);
		me.sliderFraglimit = makeXonoticSlider(1.0, 2000.0, 5, "fraglimit_override");
		me.TD(me, 1, 1, e = makeXonoticSliderCheckBox(0, 1, me.sliderFraglimit, _("Point limit:")));
			me.checkboxFraglimit = e;
		me.TD(me, 1, 2, me.sliderFraglimit);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticSliderCheckBox(-1, 0, me.sliderFraglimit, _("Use map specified default")));
			me.checkboxFraglimitMapinfo = e;
			
		me.TD(me, 1, 1.0, e = makeXonoticCheckBox(0, "sv_autoplayercolors", _("Autocolor")));
			e.cvarOffValue = "0";
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Player slots:")));
		me.TD(me, 1, 2, makeXonoticSlider(1, 32, 1, "menu_maxplayers"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Number of bots:")));
		me.TD(me, 1, 2, makeXonoticSlider(0, 9, 1, "bot_number"));
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Bot skill:")));
			setDependent(e, "bot_number", 0, -1);
		me.TD(me, 1, 2, e = makeXonoticTextSlider("skill"));
			e.addValue(e, _("Botlike"), "0");
			e.addValue(e, _("Beginner"), "1");
			e.addValue(e, _("You will win"), "2");
			e.addValue(e, _("You can win"), "3");
			e.addValue(e, _("You might win"), "4");
			e.addValue(e, _("Advanced"), "5");
			e.addValue(e, _("Expert"), "6");
			e.addValue(e, _("Pro"), "7");
			e.addValue(e, _("Assassin"), "8");
			e.addValue(e, _("Unhuman"), "9");
			e.addValue(e, _("Godlike"), "10");
			e.configureXonoticTextSliderValues(e);
			setDependent(e, "bot_number", 0, -1);
	me.TR(me);
	me.TR(me);
		me.TD(me, 1, 1, e = makeXonoticButton(_("Mutators..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.mutatorsDialog;
			main.mutatorsDialog.refilterEntity = me.mapListBox;
		//me.TD(me, 1, 2, e0 = makeXonoticTextLabel(0, string_null));
		me.TD(me, 1, 1.15, e0 = makeXonoticTextLabel(0, string_null));
			e0.textEntity = main.mutatorsDialog;
			e0.allowCut = 1;
		me.TD(me, 1, 1, e = makeXonoticButton(_("Presets..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.presetsDialog;
			main.mutatorsDialog.refilterEntity = me.mapListBox;
	me.TR(me);
		//me.TDempty(me, 0.25);
		me.TD(me, 1, 0.25, e = makeXonoticButton(_("MG"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.mountedgunsDialog;
			me.buttonMountedguns = e;
			main.advancedDialog.refilterEntity = me.mapListBox;
		me.TD(me, 1, 0.5, e = makeXonoticButton(_("Spells"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.startmagicDialog;
			me.buttonStartmagic = e;
			main.advancedDialog.refilterEntity = me.mapListBox;
		me.TD(me, 1, 0.75, e = makeXonoticButton(_("Start weapons"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.startweaponsDialog;
			me.buttonStartweapons = e;
			main.advancedDialog.refilterEntity = me.mapListBox;
		me.TD(me, 1, 1.25, e = makeXonoticButton(_("Advanced settings..."), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.advancedDialog;
			main.advancedDialog.refilterEntity = me.mapListBox;
		me.TD(me, 1, 0.4, e = makeXonoticButton(_("Vehicles"), '0 0 0'));
			e.onClick = DialogOpenButton_Click;
			e.onClickEntity = main.vehiclesDialog;
			me.buttonVehicles = e;
			main.advancedDialog.refilterEntity = me.mapListBox;

	me.gotoRC(me, 0, 3.2); me.setFirstColumn(me, me.currentColumn);
		me.mapListBox = makeXonoticMapList();
		me.TD(me, 1, 3, e = makeXonoticTextLabel(0, _("Map list:")));
			makeCallback(e, me.mapListBox, me.mapListBox.refilterCallback);
	me.TR(me);
		me.TD(me, me.rows - 4, 3, me.mapListBox);
	me.gotoRC(me, me.rows - 3, 3.5);
		me.TDempty(me, 0.25);
		me.TD(me, 1, 1.125, e = makeXonoticButton(_("Select all"), '0 0 0'));
			e.onClick = MapList_All;
			e.onClickEntity = me.mapListBox;
		me.TD(me, 1, 1.125, e = makeXonoticButton(_("Select none"), '0 0 0'));
			e.onClick = MapList_None;
			e.onClickEntity = me.mapListBox;
		me.TDempty(me, 0.25);

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("Start Multiplayer!"), '0 0 0'));
			e.onClick = MapList_LoadMap;
			e.onClickEntity = me.mapListBox;
			me.mapListBox.startButton = e;

	me.gameTypeChangeNotify(me);
}

void GameType_ConfigureSliders(entity e, entity l, entity l2, entity b1, entity b2, entity b3, entity b4, string pLabel, float pMin, float pMax, float pStep, string pCvar, float isTeamGame)
{
	if(isTeamGame)
	{
		//b1.disabled = FALSE;
		b1.onClickEntity = main.startweaponsDialog;
		b2.onClickEntity = main.mountedgunsDialog;
		b3.onClickEntity = main.vehiclesDialog;
		b4.onClickEntity = main.startmagicDialog;
	}
	else 
	{
		//b1.disabled = TRUE;
		b1.onClickEntity = main.startweaponsdmDialog;
		if (cvar("g_spawn_around_findbases_nonteamplay_vehiclesandmg")) {
			b2.onClickEntity = main.mountedgunsDialog;
			b3.onClickEntity = main.vehiclesDialog;
		} else {
			b2.onClickEntity = main.mountedgunsdmDialog;
			b3.onClickEntity = main.vehiclesdmDialog;
		}
		b4.onClickEntity = main.startmagicdmDialog;
	}
	
	if(pCvar == "")
	{
		e.configureXonoticSlider(e, pMin, pMax, pStep, string_null);
		l.setText(l, pLabel);
		e.disabled = l.disabled = l2.disabled = TRUE;
	}
	else
	{
		e.configureXonoticSlider(e, pMin, pMax, pStep, pCvar);
		l.setText(l, pLabel);
		e.disabled = l.disabled = l2.disabled = FALSE;
	}
}

void XonoticServerCreateTab_gameTypeChangeNotify(entity me)
{
	// tell the map list to update
	float gt;
	entity e, l, l2, b1, b2, b3, b4;
	gt = MapInfo_CurrentGametype();
	e = me.sliderFraglimit;
	l = me.checkboxFraglimit;
	l2 = me.checkboxFraglimitMapinfo;
	b1 = me.buttonStartweapons;
	b2 = me.buttonMountedguns;
	b3 = me.buttonVehicles;
	b4 = me.buttonStartmagic;
	switch(gt)
	{
		case MAPINFO_TYPE_TEAM_DEATHMATCH:        GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Frag limit:"),      5,  100,  5, "fraglimit_override", TRUE);       break;
		case MAPINFO_TYPE_CTF:        GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Capture limit:"),   1,   20, 1, "capturelimit_override", TRUE);     break;
		case MAPINFO_TYPE_DOMINATION: GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),    50,  500, 10, "g_domination_point_limit", TRUE); break;
		case MAPINFO_TYPE_CA:         GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Frag limit:"),      5,  100,  5, "fraglimit_override", TRUE);       break;
		case MAPINFO_TYPE_KEYHUNT:    GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),   200, 1500, 50, "g_keyhunt_point_limit", TRUE);    break;
		case MAPINFO_TYPE_RUNEMATCH:  GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),    50,  500, 10, "g_runematch_point_limit", FALSE);  break;
		case MAPINFO_TYPE_LMS:        GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Lives:"),           3,   50,  1, "g_lms_lives_override", FALSE);     break;
		case MAPINFO_TYPE_RACE:       GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Laps:"),            1,   25,  1, "g_race_laps_limit", FALSE);        break;
		case MAPINFO_TYPE_NEXBALL:    GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Goals:"),           1,   50,  1, "g_nexball_goallimit", TRUE);      break;
		case MAPINFO_TYPE_ASSAULT:    GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),    50,  500, 10, "", TRUE);                         break;
		case MAPINFO_TYPE_ONSLAUGHT:  GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),    50,  500, 10, "", TRUE);                         break;
		case MAPINFO_TYPE_CTS:        GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Point limit:"),    50,  500, 10, "", FALSE);                         break;
		case MAPINFO_TYPE_FREEZETAG:  GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Frag limit:"),      5,  100,  5, "fraglimit_override", TRUE);       break;
		default:                      GameType_ConfigureSliders(e, l, l2, b1, b2, b3, b4, _("Frag limit:"),      5,  100,  5, "fraglimit_override", FALSE);       break;
	}
	me.mapListBox.refilter(me.mapListBox);
}

#endif
