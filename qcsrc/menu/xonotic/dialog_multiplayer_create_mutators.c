#ifdef INTERFACE
CLASS(XonoticMutatorsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticMutatorsDialog, toString, string(entity))
	METHOD(XonoticMutatorsDialog, fill, void(entity))
	METHOD(XonoticMutatorsDialog, showNotify, void(entity))
	METHOD(XonoticMutatorsDialog, close, void(entity))
	ATTRIB(XonoticMutatorsDialog, title, string, _("Mutators"))
	ATTRIB(XonoticMutatorsDialog, color, vector, SKINCOLOR_DIALOG_MUTATORS)
	ATTRIB(XonoticMutatorsDialog, intendedWidth, float, 1.0)
	ATTRIB(XonoticMutatorsDialog, rows, float, 53)
	ATTRIB(XonoticMutatorsDialog, columns, float, 12)
	ATTRIB(XonoticMutatorsDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticMutatorsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticMutatorsDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

string weaponarenastring;
string weaponarenastring_cvar;
string WeaponArenaString()
{
	string s;
	float n, i, j;
	entity e;
	s = cvar_string("g_weaponarena");
	if(s == "0")
		return "";
	if(s == "all")
		return _("All Weapons Arena");
	if(s == "most")
		return _("Most Weapons Arena");
	if(s == weaponarenastring_cvar)
		return weaponarenastring;
	if(weaponarenastring)
		strunzone(weaponarenastring);
	if(weaponarenastring_cvar)
		strunzone(weaponarenastring_cvar);

	weaponarenastring_cvar = strzone(s);

	n = tokenize_console(s);
	s = "";
	for(i = 0; i < n; ++i)
	{
		for(j = WEP_FIRST; j <= WEP_LAST; ++j)
		{
			e = get_weaponinfo(j);
			if(argv(i) == e.netname)
				s = strcat(s, " & ", e.message);
		}
	}
	s = sprintf(_("%s Arena"), substring(s, 3, strlen(s) - 3));

	weaponarenastring = strzone(s);

	return weaponarenastring;
}

string XonoticMutatorsDialog_toString(entity me)
{
	string s;
	s = "";
	if(cvar("g_dodging"))
		s = strcat(s, ", ", _("Dodging"));
	if(cvar("g_brawling"))
		s = strcat(s, ", ", _("Brawling"));
	if(cvar("g_minstagib"))
		s = strcat(s, ", ", _("MinstaGib"));
	//Commented out as we include the newtoys by default
	//if(cvar("g_new_toys"))
	//	s = strcat(s, ", ", _("New Toys"));
	if(cvar("g_nix"))
		s = strcat(s, ", ", _("NIX"));
	if(cvar("g_rocket_flying"))
		s = strcat(s, ", ", _("Rocket Flying"));
	if(cvar("g_invincible_projectiles"))
		s = strcat(s, ", ", _("Invincible Projectiles"));
	if(cvar_string("g_weaponarena") != "0")
		s = strcat(s, ", ", WeaponArenaString());
	if(cvar("g_start_weapon_laser") == 0)
		s = strcat(s, ", ", _("No start weapons"));
	if(cvar("sv_gravity") < 800)
		s = strcat(s, ", ", _("Low gravity"));
	if(cvar("g_cloaked"))
		s = strcat(s, ", ", _("Cloaked"));
	if(cvar("g_grappling_hook"))
		s = strcat(s, ", ", _("Hook"));
	if(cvar("g_midair"))
		s = strcat(s, ", ", _("Midair"));
	if(cvar("g_vampire"))
		s = strcat(s, ", ", _("Vampire"));
	if(cvar("g_pinata"))
		s = strcat(s, ", ", _("Piñata"));
	if(cvar("g_weapon_stay"))
		s = strcat(s, ", ", _("Weapons stay"));
	if(cvar("g_spawnvehiclesaround"))
		s = strcat(s, ", ", _("Random Vehicles"));
	if(cvar("g_spawnmountedgunsaround"))
		s = strcat(s, ", ", _("Random Mounted Weapons"));
	if(cvar("g_spawnturretsaround"))
		s = strcat(s, ", ", _("Random Enemy Turrets"));
	if(cvar("g_za"))
		s = strcat(s, ", ", _("Zombie Apocalypse"));
	if(cvar("g_bloodloss") > 0)
		s = strcat(s, ", ", _("Blood loss"));
	if(cvar("g_jetpack"))
		s = strcat(s, ", ", _("Jet pack"));
	if(cvar("g_powerups") == 0)
		s = strcat(s, ", ", _("No powerups"));
	if(cvar("g_powerups") > 0)
		s = strcat(s, ", ", _("Powerups"));
	if(s == "")
		return ZCTX(_("MUT^None"));
	else
		return substring(s, 2, strlen(s) - 2);
}



// WARNING: dirty hack. TODO clean this up by putting this behaviour in extra classes.
void loadCvarsLaserWeaponArenaWeaponButton(entity me)
{
	tokenize_console(cvar_string("g_weaponarena"));
	me.checked = (argv(0) == me.cvarValue);
}

void saveCvarsLaserWeaponArenaWeaponButton(entity me)
{
	string suffix;

	suffix = "";
	if(me.cvarValue != "laser" && me.cvarValue != "most")
		if(cvar("menu_weaponarena_with_laser"))
			suffix = " laser";
	if(me.checked)
		cvar_set("g_weaponarena", strcat(me.cvarValue, suffix));
	else
		cvar_set("g_weaponarena", me.cvarOffValue);
}

.void(entity) draw_weaponarena;
.void(entity) saveCvars_weaponarena;
void saveCvarsLaserWeaponArenaLaserButton(entity me)
{
	// run the old function
	me.saveCvars_weaponarena(me);

	me.disabled = ((cvar_string("g_weaponarena") == "0") || (cvar_string("g_weaponarena") == "laser") || (cvar_string("g_weaponarena") == "most"));

	if not(me.disabled)
	{
		// check for the laser suffix
		string s;
		s = cvar_string("g_weaponarena");
		if(me.checked && substring(s, strlen(s) - 6, 6) != " laser")
			s = strcat(s, " laser");
		else if(!me.checked && substring(s, strlen(s) - 6, 6) == " laser")
			s = substring(s, 0, strlen(s) - 6);
		cvar_set("g_weaponarena", s);
	}
}

void preDrawLaserWeaponArenaLaserButton(entity me)
{
	me.disabled = ((cvar_string("g_weaponarena") == "0") || (cvar_string("g_weaponarena") == "laser") || (cvar_string("g_weaponarena") == "most"));
	// run the old function
	me.draw_weaponarena(me);
}
// WARNING: end of dirty hack. Do not try this at home.

float checkCompatibility_pinata(entity me)
{
	if(cvar("g_minstagib"))
		return 0;
	if(cvar("g_nix"))
		return 0;
	if(cvar_string("g_weaponarena") != "0")
		return 0;
	return 1;
}
float checkCompatibility_weaponstay(entity me)
{
	return checkCompatibility_pinata(me);
}
float checkCompatibility_newtoys(entity me)
{
	if(cvar("g_minstagib"))
		return 0;
	if(cvar_string("g_weaponarena") == "most")
		return 1;
	if(cvar_string("g_weaponarena") == "all")
		return 1;
	if(cvar_string("g_weaponarena") != "0")
		return 0;
	return 1;
}

void XonoticMutatorsDialog_fill(entity me)
{
	entity e, s, w;
	float i, j;
	string str, hstr;
	me.TR(me);
		me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Gameplay mutators:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_dodging", _("Dodging")));
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_brawling", _("Brawling")));
	me.TR(me);
		me.TD(me, 1, 0.9, e = makeXonoticTextLabel(0, _("Brawling Force:")));
			setDependent(e, "g_brawling", 1, 1);
		me.TD(me, 1, 0.9, e = makeXonoticSlider(0, 1.5, 0.1, "sv_brawling_forcemulti"));
			setDependent(e, "g_brawling", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "sv_brawling_zprotect_disable", _("")));
			setDependent(e, "g_brawling", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_cloaked", _("Cloaked")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_midair", _("Midair")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_vampire", _("Vampire")));
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticSlider(10, 50, 1, "g_bloodloss");
		me.TD(me, 1, 1.8, e = makeXonoticSliderCheckBox(0, 1, s, _("Blood loss")));
			setDependent(e, "g_minstagib", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 1.6, s);
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticSlider(80, 400, 8, "sv_gravity");
			s.valueDigits = 0;
			s.valueDisplayMultiplier = 0.125; // show gravity in percent
		me.TD(me, 1, 1.8, e = makeXonoticSliderCheckBox(800, 1, s, _("Low gravity")));
			e.savedValue = 200; // good on silvercity
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 1.6, s);
	me.TR(me);
		me.TDempty(me, 0.2);
		s = makeXonoticSlider(1, 10, 1, "g_maxlives");
		me.TD(me, 1, 1.4, e = makeXonoticSliderCheckBox(0, 1, s, _("Max lives")));
		me.TD(me, 1, 0.40, e = makeXonoticCheckBox(0, "g_maxlives_ignorebots", _("")));
			setDependent(e, "g_maxlives", 1, 10000000);
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 1.6, s);
	me.TR(me);
	//me.TR(me); //Unneccessary, but make looks better
	//me.TR(me); //Unneccessary, but make looks better
		me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Weapon & item mutators:")));
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Add")));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 200, 1, "g_randomadditionalweapons"));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 500, 2, "g_randomadditionalweapons_wait"));
			e.colorL = '1 0 0';
			
		//me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 9, 1, "g_randomadditionalweapons_type"));
		//	e.colorL = '1 0 0';
		//	setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
		//	"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TD(me, 1, 2.2, e = makeXonoticTextSlider("g_randomadditionalweapons_type"));
			e.addValue(e, _("standard"), "0");
			e.addValue(e, _("energy"), "1");
			e.addValue(e, _("explosives"), "2");
			e.addValue(e, _("civ guns"), "3");
			e.addValue(e, _("modern guns"), "4");
			e.addValue(e, _("modern tools"), "5");
			e.addValue(e, _("guns explosives & energy"), "6");
			e.addValue(e, _("WWI"), "7");
			e.addValue(e, _("old west"), "8");
			e.addValue(e, _("medieval"), "9");
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("+")));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 1, 0.1, "g_randomadditionalweapons1"));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 1.4, e = makeXonoticTextSlider("g_randomadditionalweapons1_type"));
			e.addValue(e, _("standard"), "0");
			e.addValue(e, _("energy"), "1");
			e.addValue(e, _("explosives"), "2");
			e.addValue(e, _("civ guns"), "3");
			e.addValue(e, _("modern guns"), "4");
			e.addValue(e, _("modern tools"), "5");
			e.addValue(e, _("guns explosives & energy"), "6");
			e.addValue(e, _("WWI"), "7");
			e.addValue(e, _("old west"), "8");
			e.addValue(e, _("medieval"), "9");
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("+")));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
			//setDependent(e, "g_randomadditionalweapons", 0.001, 999999999999);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 1, 0.1, "g_randomadditionalweapons2"));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 1.4, e = makeXonoticTextSlider("g_randomadditionalweapons2_type"));
			e.addValue(e, _("standard"), "0");
			e.addValue(e, _("energy"), "1");
			e.addValue(e, _("explosives"), "2");
			e.addValue(e, _("civ guns"), "3");
			e.addValue(e, _("modern guns"), "4");
			e.addValue(e, _("modern tools"), "5");
			e.addValue(e, _("guns explosives & energy"), "6");
			e.addValue(e, _("WWI"), "7");
			e.addValue(e, _("old west"), "8");
			e.addValue(e, _("medieval"), "9");
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("+")));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
			//setDependent(e, "g_randomadditionalweapons", 0.001, 999999999999);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 1, 0.1, "g_randomadditionalweapons3"));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 1.4, e = makeXonoticTextSlider("g_randomadditionalweapons3_type"));
			e.addValue(e, _("standard"), "0");
			e.addValue(e, _("energy"), "1");
			e.addValue(e, _("explosives"), "2");
			e.addValue(e, _("civ guns"), "3");
			e.addValue(e, _("modern guns"), "4");
			e.addValue(e, _("modern tools"), "5");
			e.addValue(e, _("guns explosives & energy"), "6");
			e.addValue(e, _("WWI"), "7");
			e.addValue(e, _("old west"), "8");
			e.addValue(e, _("medieval"), "9");
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("+")));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
			//setDependent(e, "g_randomadditionalweapons", 0.001, 999999999999);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 1, 0.1, "g_randomadditionalweapons4"));
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
		me.TD(me, 1, 1.4, e = makeXonoticTextSlider("g_randomadditionalweapons4_type"));
			e.addValue(e, _("standard"), "0");
			e.addValue(e, _("energy"), "1");
			e.addValue(e, _("explosives"), "2");
			e.addValue(e, _("civ guns"), "3");
			e.addValue(e, _("modern guns"), "4");
			e.addValue(e, _("modern tools"), "5");
			e.addValue(e, _("guns explosives & energy"), "6");
			e.addValue(e, _("WWI"), "7");
			e.addValue(e, _("old west"), "8");
			e.addValue(e, _("medieval"), "9");
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			setDependentOR(e, "g_delete_weapon_pickups", 0, 0,  
			"g_randomadditionalweapons_wait",  0.001, 999999999999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_grappling_hook", _("Grappling hook")));
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_rocket_flying", _("Rocket Flying")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_jetpack", _("Jet pack")));
		me.TD(me, 1, 0.9, e = makeXonoticCheckBoxEx(0, -1, "g_pickup_items", _("No-Pickups")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_delete_weapon_pickups", _("Delete Weapons")));
	me.TR(me);
		//me.TD(me, 1, 1.1, e = makeXonoticTextLabel(0, _("Replace Weapons:")));
		me.TD(me, 1, 2.2, e = makeXonoticTextLabel(0, _("Replace Weapons:")));
			e.colorL = '1 0 0';
			setDependent(e, "g_delete_weapon_pickups", 0, 0);
		//me.TD(me, 1, 0.9, e = makeXonoticSlider(0, 12, 1, "g_replace_weapon_pickups"));
		//	e.colorL = '1 0 0';
		//	setDependent(e, "g_delete_weapon_pickups", 0, 0);
	me.TR(me);
		me.TD(me, 1, 2.2, e = makeXonoticTextSlider("g_replace_weapon_pickups"));
			e.addValue(e, _("0"), "0");
			e.addValue(e, _("Spikes"), S_GREPLACEWEAPONPICKUPS_SPIKES);
			e.addValue(e, _("Fire"), S_GREPLACEWEAPONPICKUPS_FIRE);
			e.addValue(e, _("Pillar Of Fire"), S_GREPLACEWEAPONPICKUPS_PILLAR_OF_FIRE);
			e.addValue(e, _("Jumppads"), S_GREPLACEWEAPONPICKUPS_JUMPPADS);
			e.addValue(e, _("Bumpers"), S_GREPLACEWEAPONPICKUPS_BUMPERS);
			e.addValue(e, _("Balloons"), S_GREPLACEWEAPONPICKUPS_BALOONS);
			e.addValue(e, _("TankTraps"), S_GREPLACEWEAPONPICKUPS_TANKTRAPS);
			e.addValue(e, _("AbdBldgs"), S_GREPLACEWEAPONPICKUPS_ABDBLDGS);
			e.addValue(e, _("Foliage"), S_GREPLACEWEAPONPICKUPS_FOLIAGE);
			e.addValue(e, _("XonWpns"), S_GREPLACEWEAPONPICKUPS_STDXONWPNS);
			e.addValue(e, _("Energy Wpns"), S_GREPLACEWEAPONPICKUPS_ENRGYWPNS);
			e.addValue(e, _("Explosives"), S_GREPLACEWEAPONPICKUPS_EXPLSVWPNS);
			e.addValue(e, _("Civillian Wpns"), S_GREPLACEWEAPONPICKUPS_MODGUNCIVILWPNS);
			e.addValue(e, _("Modern Guns"), S_GREPLACEWEAPONPICKUPS_MODGUNWPNS);
			e.addValue(e, _("Modern Tools"), S_GREPLACEWEAPONPICKUPS_MODTOOLS);
			e.addValue(e, _("Guns/Xplsvs/Energy"), S_GREPLACEWEAPONPICKUPS_GUNXPLSVENRGYWPNS);
			e.addValue(e, _("WWI Wpns"), S_GREPLACEWEAPONPICKUPS_WWIWPNS);
			e.addValue(e, _("Old West Wpns"), S_GREPLACEWEAPONPICKUPS_OLDWESTWPNS);
			e.addValue(e, _("Scrolls"), S_GREPLACEWEAPONPICKUPS_SCROLLS);     //10
			e.addValue(e, _("Medieval Wpns"), S_GREPLACEWEAPONPICKUPS_MDVL_WPNS); //11
			e.addValue(e, _("Mdvl Wpns+Srlls"), S_GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS); //12
			e.configureXonoticTextSliderValues(e);
			e.colorL = '1 0 0';
			//e.colorC = '1 0 0';
			//e.colorF = '1 0 0';
			//e.colorD = '1 0 0';
			e.color2 = '1 0.5 0.5';
			setDependent(e, "g_delete_weapon_pickups", 0, 0);
			//ftos(GREPLACEWEAPONPICKUPS_SPIKES) didn't work, had to make precomputed strings
	me.TR(me);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("rate:")));
			setDependent(e, "g_delete_weapon_pickups", 0, 0);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.05, "g_replace_weapon_pickups_rate"));
			setDependent(e, "g_delete_weapon_pickups", 0, 0);
	me.TR(me);
		me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 1, 0.05, "g_replace_weapon_pickups_scroll_biased_rate"));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
		me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 1, 0.05, "g_replace_weapon_pickups_scrollvsmedieval_rate"));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Scrolls")), '0 0 0', "exec button_replace_weapon_scrollonly.cfg", 0));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^S+MedeB")), '0 0 0', "exec button_replace_weapon_scrollandbookknowmed.cfg", 0));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
	me.TR(me);
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^S+All B")), '0 0 0', "exec button_replace_weapon_scrollandbookknowall.cfg", 0));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
		me.TD(me, 1, 1.0, e = makeXonoticCommandButton(ZCTX(_("PRE^Books")), '0 0 0', "exec button_replace_weapon_bookknowonly.cfg", 0));
			setDependent(e, "g_replace_weapon_pickups", (GREPLACEWEAPONPICKUPS_SCROLLS), (GREPLACEWEAPONPICKUPS_MDVL_WPNS_SCROLLS));
	//me.TR(me); //Unneccessary, but make looks better
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_invincible_projectiles", _("Invincible Projectiles")));
	//Commented out as we include the newtoys by default
	//me.TR(me);
	//	me.TDempty(me, 0.2);
	//	me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_new_toys", _("New Toys")));
	//		setDependentWeird(e, checkCompatibility_newtoys);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_pinata", _("Piñata")));
			setDependentWeird(e, checkCompatibility_pinata);
		me.TD(me, 1, 0.9, e = makeXonoticCheckBox(0, "g_pickup_permitems", _("PermItems")));
	me.TR(me);
		me.TDempty(me, 0.4);
		me.TD(me, 1, 0.40, e = makeXonoticCheckBox(0, "g_pickup_permitems_sanspowerups", _("PW")));
			setDependent(e, "g_pickup_permitems", 1, 1);
		me.TD(me, 1, 0.40, e = makeXonoticCheckBox(0, "g_pickup_permitems_sansammo", _("AO")));
			setDependent(e, "g_pickup_permitems", 1, 1);
		me.TD(me, 1, 0.40, e = makeXonoticCheckBox(0, "g_pickup_permitems_sansarmor", _("AR")));
			setDependent(e, "g_pickup_permitems", 1, 1);
		me.TD(me, 1, 0.40, e = makeXonoticCheckBox(0, "g_pickup_permitems_sanshealth", _("HP")));
			setDependent(e, "g_pickup_permitems", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.6, e = makeXonoticCheckBox(0, "g_startobjectsonlyonce", _("StartItemsOnlyOnce")));
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_startobjectsonlyonce_excludeweapsonly", _("")));
			setDependent(e, "g_startobjectsonlyonce", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_startobjectsonlyonce_ignorebots", _("")));
			setDependent(e, "g_startobjectsonlyonce", 1, 1);
	me.TR(me);
		//me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("MonsterDrop")));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '1 0 0';
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 1, 0.1, "g_monsters_dropweapon_medieval"));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.1 0.05 0.0'; //'0.7 0 0';
			e.color2 = '0.5 0.5 0.5';
			e.colorC = '0.5 0.5 0.5';
			e.colorF = '0.5 0.5 0.5';
			e.colorD = '0.5 0.5 0.5';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MDVL")));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.1 0.05 0.0';
	me.TR(me);
		//me.TDempty(me, 0.3);
		me.TD(me, 1, 0.65, e = makeXonoticSlider(0, 1, 0.1, "g_monsters_dropweapon_moderngun"));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.5 1 1'; //0.5 0.5 0.6
			e.color2 = '0.5 1 1';
			e.colorC = '0.5 1 1';
			e.colorF = '0.5 1 1';
			e.colorD = '0.5 1 1';
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("MOD")));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.5 1 1';
		
		me.TD(me, 1, 0.65, e = makeXonoticSlider(0, 1, 0.1, "g_monsters_dropweapon_futurehvy"));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.9 0.7 1.0';
			e.color2 = '0.9 0.7 1.0';
			e.colorC = '0.9 0.7 1.0';
			e.colorF = '0.9 0.7 1.0';
			e.colorD = '0.9 0.7 1.0';
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("FUTR")));
			setDependent(e, "g_monsters", 1, 1);
			e.colorL = '0.9 0.7 1.0';
	//me.TR(me); //Unneccessary, but make looks better
	me.TR(me);
		//me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticCheckBox(0, "g_weapon_stay", _("Weapons stay")));
			setDependentWeird(e, checkCompatibility_weaponstay);
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_nodropweapons", _("No Drop")));
	me.TR(me);
		me.TDempty(me, 0.2);	
		me.TD(me, 1, 1.8, e = makeXonoticCheckBoxEx(0, 1, "g_monsters", _("No-Monsters")));
	me.TR(me);
		me.TDempty(me, 0.2);	
		me.TD(me, 1, 1.8, e = makeXonoticCheckBoxEx(0, 1, "g_turrets", _("No-Turrets")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Turrets Repairable")));
			setDependent(e, "g_turrets", 1, 1);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(-1, 1, 1, "g_turrets_allrepairable"));
			setDependent(e, "g_turrets", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Turrets No Respawn")));
			setDependent(e, "g_turrets", 1, 1);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 2, 1, "g_turrets_norespawn"));
			setDependent(e, "g_turrets", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("TrScan")));
			setDependent(e, "g_turrets", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0.1, 4.9, 0.1, "g_turrets_targetscan_mindelay"));
			setDependent(e, "g_turrets", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("TrThnkTime")));
			setDependent(e, "g_turrets", 1, 1);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 5, 0.1, "g_turrets_thinkadd"));
			setDependent(e, "g_turrets", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_turrets_thinkadd_toaimspeed", _("")));
			setDependentAND(e, "g_turrets", 1, 1, "g_turrets_thinkadd", 0.001, 999999999999);
	//me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_delete_vehicles", _("Delete Vehicles")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround", _("Random Vehicles")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Mil")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 50, 1, "g_spawnvehiclesaround_mil_max"));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmechs", _("M")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_mil_atleast", _("1ea")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		
		me.currentColumn = 0;
		me.TDempty(me, 1.3);
			me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilbiplanes", _("B")));
				setDependent(e, "g_spawnvehiclesaround", 1, 1);
			//me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilmonoplanes", _("P")));
			//	setDependent(e, "g_spawnvehiclesaround", 1, 1);
			me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilheli", _("H")));
				setDependent(e, "g_spawnvehiclesaround", 1, 1);
			//me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmiltechnicals", _("C")));
			//	setDependent(e, "g_spawnvehiclesaround", 1, 1);
			//me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowmilspiderbots", _("S")));
			//	setDependent(e, "g_spawnvehiclesaround", 1, 1);	
			me.TD(me, 2, 0.3, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_allowtanks", _("T")));
				setDependent(e, "g_spawnvehiclesaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Civ")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 50, 1, "g_spawnvehiclesaround_civ_max"));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_spawnvehiclesaround_civ_atleast", _("1ea")));
			setDependent(e, "g_spawnvehiclesaround", 1, 1);		
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_delete_mountedguns", _("Delete Mounted Guns")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_spawnmountedgunsaround", _("Random Mounted Guns")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(1, 30, 1, "g_spawnmountedgunsaround_max"));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnmountedgunsaround_shield", _("")));
			setDependent(e, "g_spawnmountedgunsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_spawnturretsaround", _("Random Enemy Turrets")));
			setDependent(e, "g_turrets", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Tur")));
			setDependent(e, "g_spawnturretsaround", 1, 1);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(0, 100, 1, "g_spawnturretsaround_max"));
			setDependent(e, "g_spawnturretsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Wlk")));
			setDependent(e, "g_spawnturretsaround", 1, 1);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(0, 100, 1, "g_spawnturretsaroundwalker_max"));
			setDependent(e, "g_spawnturretsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Rct")));
			setDependent(e, "g_spawnturretsaround", 1, 1);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(0, 100, 1, "g_spawnturretsaroundreactor_max"));
			setDependent(e, "g_spawnturretsaround", 1, 1);
	me.TR(me);

	me.gotoRC(me, 0, 2); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 4, makeXonoticTextLabel(0, _("Weapon arenas:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.45, e = makeXonoticRadioButton(1, string_null, string_null, _("Regular (no arena)")));
		//Third abode of "with laser" checkbox"
		me.TDempty(me, 0.1);
		me.TD(me, 1, 1.25, e = makeXonoticCheckBox(0, "menu_weaponarena_with_laser", _("  with laser")));
			// hook the draw function to gray it out
			e.draw_weaponarena = e.draw;
			e.draw = preDrawLaserWeaponArenaLaserButton;
			// hook the save function to notify about the cvar
			e.saveCvars_weaponarena = e.saveCvars;
			e.saveCvars = saveCvarsLaserWeaponArenaLaserButton;
	me.TR(me);	
	for(i = WEP_FIRST, j = 0; i <= WEP_LAST; ++i)
	{
		w = get_weaponinfo(i);
		if(w.spawnflags & WEP_FLAG_HIDDEN)
			continue;
		//if(j & 1 == 1)
		//	me.TR(me);
		//if(j == 4) {
		//	me.TR(me);
		if(j == 5) {
			me.TR(me);
			j = 0;
		}
		str = w.netname;
		hstr = w.message;
		////When it was 4:
		//me.TDempty(me, 0.2);
		//me.TD(me, 1, 0.85, e = makeXonoticRadioButton(1, "g_weaponarena", strzone(str), strzone(hstr)));
		
		//Now that it's 5:
		if (j == 0) {
			me.TDempty(me, 0.2);
		}
		me.TD(me, 1, 0.58, e = makeXonoticRadioButton(1, "g_weaponarena", strzone(str), strzone(hstr)));
			e.cvarOffValue = "0";
			// custom load/save logic that ignores a " laser" suffix, or adds it 
			e.loadCvars = loadCvarsLaserWeaponArenaWeaponButton;
			e.saveCvars = saveCvarsLaserWeaponArenaWeaponButton;
			e.loadCvars(e);
		++j;
	}
	//me.TR(me);
		//me.TDempty(me, 0.2);
		//Old abode of the "with laser" checkbox, had to move it down below.
	//me.TR(me);
	//me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	
	
	//////////////////////////////
	//
	//////////////////////////////
	me.gotoRC(me, me.rows - 8, 2); me.setFirstColumn(me, me.currentColumn);
	
	me.TDempty(me, 0.3);
		me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Bots Start Unarmed")));
		me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 2, 1, "bot_start_unarmed"));
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 2.5, e = makeXonoticInputBox(1, "bot_start_unarmed_inventory"));
			e.forbiddenCharacters = "\r\n\\\"$"; // don't care, isn't getting saved
			e.maxLength = -2048; // negative means encoded length in bytes
			e.saveImmediately = 1;
			setDependent(e, "bot_start_unarmed", 2, 2);
	//me.TR(me);
	me.TR(me);
		me.TD(me, 1, 2.33, makeXonoticTextLabel(0, _("Special arenas:")));
		//Second abode of "with laser"
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticRadioButton(1, "g_minstagib", string_null, _("MinstaGib")));
	//me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.5, e = makeXonoticRadioButton(1, "g_nix", string_null, _("NIX")));
	//me.TR(me);
		//me.TDempty(me, 0.4);
		me.TD(me, 1, 1.6, e = makeXonoticCheckBox(0, "g_nix_with_laser", _("with laser")));
			setDependent(e, "g_nix", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticRadioButton(1, "g_weaponarena", "most", _("Most weapons")));
			e.cvarOffValue = "0";
	//me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticRadioButton(1, "g_start_weapon_laser", "0", _("No start weapons (except for:)")));
			e.cvarOffValue = "-1";
			makeMulti(e, "g_start_weapon_shotgun g_start_weapon_uzi g_start_weapon_grenadelauncher g_start_weapon_minelayer g_start_weapon_electro g_start_weapon_crylink g_start_weapon_nex g_start_weapon_hagar g_start_weapon_rocketlauncher g_start_weapon_rifle g_start_weapon_hlac g_start_weapon_seeker g_start_weapon_minstanex g_start_weapon_hook g_start_weapon_porto g_start_weapon_tuba g_start_weapon_minelayer g_start_weapon_shotgunautomat g_start_weapon_nukelayer g_start_weapon_explosivevest g_start_weapon_hmg g_start_weapon_mg  g_start_weapon_lightninggun g_start_weapon_g98");
			
	me.TR(me);	
		//me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_pistol", _("Pistol")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_bigpistol", _(".45")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_start_weapon_utilitool", _("")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_nocost", _("")));
			setDependent(e, "g_start_weapon_utilitool", 1, 1);
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_nobuildtime", _("")));
			setDependent(e, "g_start_weapon_utilitool", 1, 1);
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_noknowledgeneeded", _("")));
			setDependent(e, "g_start_weapon_utilitool", 1, 1);	
		me.TD(me, 1, 0.625, e = makeXonoticTextLabel(0, _("UtiliTool")));	
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_start_weapon_flashlight", _("Flashlight")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.7, e = makeXonoticCheckBox(0, "g_start_weapon_pumpshotgun", _("Pump Shotgun")));
			e.cvarOffValue = "-1";
	me.TR(me);
		//me.TDempty(me, 0.2);
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_revolver", _("Revolver")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_caltrop", _("Caltrops")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_start_weapon_multitool", _("")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_nocost", _("")));
			setDependent(e, "g_start_weapon_multitool", 1, 1);
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_nobuildtime", _("")));
			setDependent(e, "g_start_weapon_multitool", 1, 1);
		me.TD(me, 1, 0.125, e = makeXonoticCheckBox(0, "g_balance_multitool_noknowledgeneeded", _("")));
			setDependent(e, "g_start_weapon_multitool", 1, 1);
		me.TD(me, 1, 0.45, e = makeXonoticTextLabel(0, _("MultiTool")));
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_crossbowdtwr", _("Crossbow")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_warhammerspiked", _("Warhammer")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_shortsword", _("Short Sword")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_longsword", _("Long Sword")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_broadaxe", _("Broad Axe")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_torch", _("Torch")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_rapier", _("Rapier")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_spear", _("Spear")));
			e.cvarOffValue = "-1";
		me.TD(me, 1, 0.825, e = makeXonoticCheckBox(0, "g_start_weapon_morgenstern", _("Morgenstern")));
			e.cvarOffValue = "-1";
	
	me.TR(me);
	
	
	//////////////////////////////
	//
	//////////////////////////////
	me.gotoRC(me, 0, 5); me.setFirstColumn(me, me.currentColumn);
		me.TD(me, 1, 2, makeXonoticTextLabel(0, _("Enviroment mutators:")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.3, makeXonoticCheckBoxEx(0, 1, "g_ambient_temperature_disable", _("Temperature")));
		//me.TD(me, 1, 0.3, e = makeXonoticCheckBoxEx(1, 0, "g_ambient_temperature", _("0")));
		me.TD(me, 1, 0.5, makeXonoticCommandButton(_("Zero"), '0.7 0.5 0.8', "g_ambient_temperature 0; menu_sync;", COMMANDBUTTON_APPLY));
			//setDependent(e, "g_ambient_temperature_disable", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(-274, 301, 1, "g_ambient_temperature"));
			setDependent(e, "g_ambient_temperature_disable", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Pipes")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
		me.TD(me, 1, 0.7, e = makeXonoticCheckBox(0, "g_allpiercingcausessteam_frompipes", _("Steam")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_allpiercingcausesfire_frompipes", _("Fire")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_allpiercingcauses_disabled", _("D")));
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 0.7, e = makeXonoticCheckBox(0, "g_allpiercingcauseswater_frompipes", _("Water")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
		me.TD(me, 1, 0.5, e = makeXonoticCheckBox(0, "g_allpiercingcausesice_frompipes", _("Ice")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 0.7, e = makeXonoticCheckBox(0, "g_allpiercingcausespoison_frompipes", _("Poison")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
		me.TD(me, 1, 0.7, e = makeXonoticCheckBox(0, "g_allpiercingcauseslaser_frompipes", _("Laser")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 1.4, e = makeXonoticCheckBox(0, "g_allpiercingcausesautomatic_frompipes", _("AUTOMATIC")));
			setDependent(e, "g_allpiercingcauses_disabled", 0, 0);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_skycycle", _("Sky Cycle")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Time")));
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(120, 86400, 60, "g_skycycle_time"));
			e.valueDigits = 0;
			e.valueDisplayMultiplier = 0.0166666666666666666666666666666666; // show as mins
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_skycycle_startatnight", _("N")));
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Start")));
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 1, 0.01, "g_skycycle_startattime"));
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_skycycle_timelock", _("F")));
			e.colorL = '0.8 1 1';
			setDependent(e, "g_skycycle", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_spawnfoliagearound", _("Random Foliage")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Season")));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 5, 1, "g_spawnfoliagearound_season"));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		
		me.TD(me, 1, 0.6, e = makeXonoticSlider(0, 7, 1, "g_spawnfoliagearound_overgrowth"));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Growth")));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("At Start")));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1000, 1, "g_spawnfoliagearound_min"));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Per Spawn")));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.7, e = makeXonoticSlider(0, 50, 1, "g_spawnfoliagearound_per"));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		//Group trees into forest?
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 10, 1, "g_spawnfoliagearound_forestsmin"));
			e.colorL = '0.8 1 0.8';
			setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_forestsonly", _("O")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Per Death")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 50, 1, "g_spawnfoliagearound_perdeath"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Maximum")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 9001, 1, "g_spawnfoliagearound_max"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Placement")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 2, 1, "g_spawnfoliagearound_spawnnearteam"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	//me.TR(me);
	//	me.TDempty(me, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_scale_tree", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.6, e = makeXonoticTextLabel(0, _("Scale Tree")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 10, 0.01, "g_spawnfoliagearound_scale_tree"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Beech")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_beechtree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Grove")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_beechtreegrove_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_groves_are_solid", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("EPine")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_epinetree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Eucalyptus")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_eucatree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Lombardy")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_iftree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Grove")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_iftreegrove_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		//me.TD(me, 1, 0.3, e = makeXonoticSlider(0, 1, 0.1, "g_spawnfoliagearound_groveangles2norm"));
		//	e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_groveangles2norm", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Palm")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_jubpalmtree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 0.3, e = makeXonoticTextLabel(0, _("Grove")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_jubpalmtreegrove_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("QRobur")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_quercustree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Oak")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_oldoaktree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Cedar")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_cedartree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("SwampTree")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_swamptree_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	//me.TR(me);
	//	me.TDempty(me, 0.2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_scale_bush", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.6, e = makeXonoticTextLabel(0, _("Scale Bush")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 10, 0.01, "g_spawnfoliagearound_scale_bush"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Rose")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_rosebush_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Bougainvillier")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_boubush_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Dypsis")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_dypbush_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Banana")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_bnabush_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Grass")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_grassyarea_amnt"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_bushareaangles2norm", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBoxEx(30, 0, "g_spawnfoliagearound_grassyarea_altseason", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	//me.TR(me);
	//	me.TDempty(me, 2);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_scale", _("")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Scale *")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 10, 0.01, "g_spawnfoliagearound_scale"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Meadows")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 10, 1, "g_spawnfoliagearound_meadowsmin"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Min Size")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 4096, 8, "g_spawnfoliagearound_meadow_min"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Max Size")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 4096, 8, "g_spawnfoliagearound_meadow_max"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Brush")));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_spawnfoliagearound_meadow_brush"));
			e.colorL = '0.8 1 0.8'; setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
	me.TR(me);
	me.TR(me);
	me.TDempty(me, 0.2);
		me.TD(me, 1, 0.6, e = makeXonoticTextLabel(0, _("Divisions")));
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 2, 1, "g_spawn_around_findbases_nonteamplay"));
	me.TR(me);
	me.TDempty(me, 0.2);
		me.TD(me, 1, 1.2, e = makeXonoticSlider(0, 5, 1, "g_spawn_around_findbases_nonteamplay_type"));
			setDependent(e, "g_spawn_around_findbases_nonteamplay", 1, 2);	
		me.TD(me, 1, 0.6, e = makeXonoticCheckBox(0, "g_spawn_around_findbases_nonteamplay_vehiclesandmg", _("V+MG")));
			setDependent(e, "g_spawn_around_findbases_nonteamplay", 1, 2);
	
	me.TR(me);
	me.TR(me);
	me.TR(me);
		/////
		/////
	me.TR(me);
	
	//////////////////////////////
	//
	//////////////////////////////		
		me.gotoRC(me, 0, 7); me.setFirstColumn(me, me.currentColumn);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround", _("Misc Items")));

	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("JumpPads")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 512, 1, "g_spawnmiscitemsaround_jumppad_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Bumpers")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 4096, 1, "g_spawnmiscitemsaround_bumper_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Baloons")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 4096, 1, "g_spawnmiscitemsaround_baloon_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_baloon_rainbow", _("R")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Spikes")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1024, 1, "g_spawnmiscitemsaround_spikes_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_spikes_angles2norm", _("")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.5);
		me.TD(me, 1, 0.55, e = makeXonoticTextLabel(0, _("XY")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		
		me.TD(me, 1, 0.85, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_spikes_xy"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_spikes_uz", _("Z")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
			
		me.TD(me, 1, 0.75, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_spikes_solid", _("Solid")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
			
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Spikeball Chains")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 256, 1, "g_spawnmiscitemsaround_spikeball_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Tank Traps")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1500, 1, "g_spawnmiscitemsaround_tnkpyr_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_tnkpyr_angles2norm", _("")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		//
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_tnkpyr_spawnnearteam"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("Rocks")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1500, 1, "g_spawnmiscitemsaround_rock_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		//me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_rock_angles2norm", _("")));
		//	setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		//
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_rock_avoidbuildings", _("")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_rock_spawnnearteam"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("AbdBldgs")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_max"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 0.9, e = makeXonoticTextLabel(0, _("Concrete")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_concrete_amnt"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_concrete_spawnnearteam"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 0.9, e = makeXonoticTextLabel(0, _("Glass")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.6, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_glass_amnt"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_glass_spawnnearteam"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		//me.TD(me, 1, 0.3, e = makeXonoticSlider(0, 1, 0.01, "g_balance_multitool_noautoturretsforworldtowers"));
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_noautoturretsforworldtowers", _("")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_misc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Built:Ancient")));
			e.colorL = '0.1 0.05 0.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_misc_amnt"));
			e.colorL = '0.1 0.05 0.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_misc_spawnnearteam"));
			e.colorL = '0.1 0.05 0.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_utilitool_noautoturretsforworldpedestals", _("")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_fisc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("Built:Aorist")));
			e.colorL = '0.9 0.7 1.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_fisc_amnt"));
			e.colorL = '0.9 0.7 1.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_fisc_spawnnearteam"));
			e.colorL = '0.9 0.7 1.0';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 1.2, e = makeXonoticTextLabel(0, _("SC Tiles")));
			e.colorL = '0.5 1 1';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_sc_amnt"));
			e.colorL = '0.5 1 1';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_sc_spawnnearteam"));
			e.colorL = '0.5 1 1';
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 1.133333, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbldmunitions", _("Munitions")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 0.733333, e = makeXonoticTextLabel(0, _("Nukes")));
			setDependentAND3(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1,
			 "g_spawnmiscitemsaround_abdbldmunitions", 1, 1);
		me.TD(me, 1, 1.033333, e = makeXonoticSlider(0, 5, 1, "g_spawnmiscitemsaround_abdbldmunitions_maxnukes"));
			setDependentAND3(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1,
			 "g_spawnmiscitemsaround_abdbldmunitions", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.3);
		me.TD(me, 1, 1.866667, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbldmunitions_rate"));
			setDependentAND3(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1,
			 "g_spawnmiscitemsaround_abdbldmunitions", 1, 1);
		me.TD(me, 1, 1.033333, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbldmunitions_nukes_rate"));
			setDependentAND3(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1,
			 "g_spawnmiscitemsaround_abdbldmunitions", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.633333, e = makeXonoticTextLabel(0, _("City")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.833333, e = makeXonoticSlider(0, 6, 1, "g_spawnmiscitemsaround_abdbld_citytype"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.333333, e = makeXonoticSlider(8192, 81920, 2048, "g_spawnmiscitemsaround_abdbld_citytype_size"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);			 	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("%")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
		me.TD(me, 1, 0.933333, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_citytype_rate"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
		me.TD(me, 1, 0.733333, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_citytype_shape"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 3); //Normal cities get shape, not linecity
		me.TD(me, 1, 0.933333, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_citytype_position_mapedge_noprotect", _("Edge")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("X")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_citytype_positionx"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Y")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
		me.TD(me, 1, 2.6, e = makeXonoticSlider(0, 1, 0.01, "g_spawnmiscitemsaround_abdbld_citytype_positiony"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.633333, e = makeXonoticTextLabel(0, _("CMdw")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 3); //Not line cities		 	
		me.TD(me, 1, 0.833333, e = makeXonoticSlider(0, 2, 1, "g_spawnmiscitemsaround_abdbld_citytype_meadows"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 3); //Not line cities		 	
		me.TD(me, 1, 1.333333, e = makeXonoticSlider(0, 16384, 1024, "g_spawnmiscitemsaround_abdbld_citytype_meadows_extrad"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_citytype", 1, 3); //Not line cities		 	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.7, e = makeXonoticTextLabel(0, _("Extended Damage")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.1, e = makeXonoticSlider(0, 3, 1, "g_spawnmiscitemsaround_abdbld_extendeddamage"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_extendeddamage_scale_enable", _("")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.5, e = makeXonoticTextLabel(0, _("Damage Scale")));
			setDependent(e, "g_spawnmiscitemsaround_abdbld_extendeddamage_scale_enable", 1, 1);
		me.TD(me, 1, 1.1, e = makeXonoticSlider(0.1, 200, 0.1, "g_spawnmiscitemsaround_abdbld_extendeddamage_scale"));
			setDependent(e, "g_spawnmiscitemsaround_abdbld_extendeddamage_scale_enable", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("BldSpread")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.5, e = makeXonoticSlider(0, 10240, 512, "g_spawnmiscitemsaround_abdbld_tooclose"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.3, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_tooclose_ignoretanktrapsetc", _("I")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_tooclose_spawnpoints", _("")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_max", 0.1, 999999999999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("BldRotate")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.1, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_randomangle"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		//me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Rnd")));
		//	setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.7, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_randombld"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_tooclose_flagbase", _("")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_max", 0.1, 999999999999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("BldNorm")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_angles2norm"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_tooclose_onslaught", _("")));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1, "g_spawnmiscitemsaround_abdbld_max", 0.1, 999999999999);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.9, e = makeXonoticTextLabel(0, _("Height")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 	"g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(32, 1024, 32, "g_spawnmiscitemsaround_abdbld_baseheight_sc"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 	"g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnmiscitemsaround_abdbld_baseheightrand_sc", _("")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
				"g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 0.7, e = makeXonoticSlider(0, 2048, 32, "g_spawnmiscitemsaround_abdbld_baseheightrandmax_sc"));
			e.colorL = '0.8 1 1';
			setDependentAND3(e, "g_spawnmiscitemsaround", 1, 1,
			 	"g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1,
			 	"g_spawnmiscitemsaround_abdbld_baseheightrand_sc", 1, 1);	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.95, e = makeXonoticTextLabel(0, _("Array")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.15, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmiscitemsaround_abdbld_arrayrate"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.95, e = makeXonoticTextLabel(0, _("Ring1")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.15, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmiscitemsaround_abdbld_arrayrate_ring"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("BX")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmiscitemsaround_abdbld_arrayrate_ring_isbox"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.95, e = makeXonoticTextLabel(0, _("Ring2")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 1.15, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmiscitemsaround_abdbld_arrayrate_ring2"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("B2")));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
		me.TD(me, 1, 0.5, e = makeXonoticSlider(0, 1, 0.1, "g_spawnmiscitemsaround_abdbld_arrayrate_ring2_isbox"));
			setDependent(e, "g_spawnmiscitemsaround", 1, 1);
	me.TR(me);
	
	
	/////////////////////////////////
	//
	/////////////////////////////////
	
	//First we do the text so it is "under" the sliders
	me.gotoRC(me, me.rows - 13, 7); me.setFirstColumn(me, me.currentColumn);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Airport")));
			e.colorL = '0.5 0.5 0.5';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Military")));
			e.colorL = '0.2 0.2 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("LightIndustrial")));
			e.colorL = '0.8 0.8 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Industrial")));
			e.colorL = '0.4 0.4 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Commercial")));
			e.colorL = '0.4 0.2 0.4';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("MediumCommercial")));
			e.colorL = '0.2 0.2 0.8';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("LightCommercial")));
			e.colorL = '0.2 0.7 0.8';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Apartments")));
			e.colorL = '0.2 0.2 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("LowerClass")));
			e.colorL = '0.3 0.5 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("MiddleClass")));
			e.colorL = '0.2 0.7 0.35';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("UpperClass")));
			e.colorL = '0.2 1.0 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticTextLabel(0, _("Rural")));
			e.colorL = '0.5 0.2 0.2';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);

	/////////////////////////////////
	
	
	me.gotoRC(me, me.rows - 17, 7); me.setFirstColumn(me, me.currentColumn);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 2.8, e = makeXonoticTextLabel(0, _("Neiborhood Zoning:")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("KT")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_keeptyperate"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("SR")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 10240, 512, "g_spawnmiscitemsaround_abdbld_keeptypesearchradius"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("BL")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_keeptypeblendrate"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	
		me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("IG")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.3, e = makeXonoticSlider(0, 1, 0.05, "g_spawnmiscitemsaround_abdbld_keeptypeignorerate"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.0, e = makeXonoticTextLabel(0, _("UC Radius")));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1.8, e = makeXonoticSlider(0, 10240, 512, "g_spawnmiscitemsaround_abdbld_border_uc_no_radius"));
			e.colorL = '0.8 1 1';
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeairport"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typemilitary"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typelightindustrial"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeindustrial"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typecommercial"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typemediumcommercial"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typelightcommercial"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeresidentialdense"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeresidentiallc"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeresidentialmc"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeresidentialuc"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
		me.TD(me, 1, 1, e = makeXonoticSlider(0, 100, 1, "g_spawnmiscitemsaround_abdbld_sc_typeruralfarm"));
			setDependentAND(e, "g_spawnmiscitemsaround", 1, 1,
			 "g_spawnmiscitemsaround_abdbld_sc_amnt", 0.0001, 1);
	me.TR(me);
	
	
	
	/////////////////////////////////
	me.TR(me);
	//
	
	//////////////////////////////
	//
	//////////////////////////////	
	
		me.gotoRC(me, 0, 10); me.setFirstColumn(me, me.currentColumn);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 1.8, e = makeXonoticCheckBox(0, "g_za", _("Zombie Apocalypse")));
			setDependent(e, "g_monsters", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("At Start")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 20, 1, "g_za_monster_count"));
			setDependent(e, "g_za", 1, 1);
		
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_za_noitemdrop", _("")));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("+Per Round")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 10, 1, "g_za_monster_count_add"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Maximum")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 9001, 1, "g_monsters_max"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ThinkTime")));
			setDependent(e, "g_monsters", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 5, 0.2, "g_monsters_thinkadd"));
			setDependent(e, "g_monsters", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Respawn")));
			setDependent(e, "g_monsters", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 500, 10, "g_monsters_respawn_delay"));
			setDependent(e, "g_monsters", 1, 1);
			
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_monsters_respawn", _("")));
			setDependent(e, "g_monsters", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Placement")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 2, 1, "g_za_spawnnearteam"));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_za_spawnnearteam_setteamto", _("")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_za_spawnnearteam_showteam", _("")));
			setDependent(e, "g_za_spawnnearteam_setteamto", 1, 1);	
	//me.TR(me);
	//	me.TDempty(me, 0.2);
	//	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Monster Lists")));
	//		setDependent(e, "g_za", 1, 1);
	//	me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 7, 1, "g_za_monster_types"));
	//		setDependent(e, "g_za", 1, 1);
	////me.TR(me);
	////	me.TDempty(me, 2);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Zombies")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_zombie_amnt"));
			setDependent(e, "g_za", 1, 1);
			
		me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_monster_zombie_quakelike", _("")));
			setDependent(e, "g_monsters", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("RottingCorpse")));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_rottingcorpse_amnt"));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("BlackDeath")));
			e.colorL = '0.6 0.6 0.2';
			e.color2 = '0.6 0.6 0.2';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_blackdeath_amnt"));
			e.colorL = '0.6 0.6 0.2';
			e.color2 = '0.6 0.6 0.2';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Goblin")));
			e.colorL = '0.3 0.6 0.2';
			e.color2 = '0.3 0.6 0.2';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_goblin_amnt"));
			e.colorL = '0.3 0.6 0.2';
			e.color2 = '0.3 0.6 0.2';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Skeletons")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_skeleton_amnt"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Minotaur")));
			e.colorL = '0.3 0.2 0.1';
			e.color2 = '0.3 0.2 0.1';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_minotaur_amnt"));
			e.colorL = '0.3 0.2 0.1';
			e.color2 = '0.3 0.2 0.1';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Golem")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_golem_amnt"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Dogs")));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_dog_amnt"));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Wolves")));
			e.colorL = '0.3 0.3 0.3';
			e.color2 = '0.3 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_wolf_amnt"));
			e.colorL = '0.3 0.3 0.3';
			e.color2 = '0.3 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Spiders")));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_spider_amnt"));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fish")));
			e.colorL = '0.5 0.5 0.5';
			e.color2 = '0.5 0.5 0.5';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_fish_amnt"));
			e.colorL = '0.5 0.5 0.5';
			e.color2 = '0.5 0.5 0.5';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Wyvern")));
			e.colorL = '0.3795 0.45 0.2475';
			e.color2 = '0.3795 0.45 0.2475';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_wyvern_amnt"));
			e.colorL = '0.3795 0.45 0.2475';
			e.color2 = '0.3795 0.45 0.2475';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Knight")));
			e.colorL = '0.5 0.5 0.5';
			e.colorL = '0.5 0.5 0.5';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_knight_amnt"));
			e.colorL = '0.5 0.5 0.5';
			e.colorL = '0.5 0.5 0.5';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("RoyalGuard")));
			e.colorL = '0.7 0.7 0.8';
			e.colorL = '0.7 0.7 0.8';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_royalguard_amnt"));
			e.colorL = '0.7 0.7 0.8';
			e.colorL = '0.7 0.7 0.8';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Fighter")));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_fighter_amnt"));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Assassin")));
			e.colorL = '0.3 0.3 0.3';
			e.color2 = '0.3 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_ninjaassassin_amnt"));
			e.colorL = '0.3 0.3 0.3';
			e.color2 = '0.3 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Ogre")));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_ogre_amnt"));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
	
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Shamblers")));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_shambler_amnt"));
			e.colorL = '0.3795 0.375 0.2475';
			e.color2 = '0.3795 0.375 0.2475';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Vore")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_vore_amnt"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Scrags")));
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_scrag_amnt"));
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("TarBabys")));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_spawn_amnt"));
			e.colorL = '0.2 0.2 0.2';
			e.color2 = '0.2 0.2 0.2';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fiends")));
			e.colorL = '0.0 0.3 0.3';
			e.color2 = '0.0 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_demon_amnt"));
			e.colorL = '0.0 0.3 0.3';
			e.color2 = '0.0 0.3 0.3';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("HellKnight")));
			e.colorL = '0.5 0.2 0';
			e.color2 = '0.5 0.2 0';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_hellknight_amnt"));
			e.colorL = '0.5 0.2 0';
			e.color2 = '0.5 0.2 0';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("Imps")));	
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_imp_amnt"));
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);	
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("BileDemon")));
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_biledemon_amnt"));
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("HornDemon")));
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_horndemon_amnt"));
			e.colorL = '0.4 0 0';
			e.color2 = '0.4 0 0';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);	
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Seraph")));
			e.colorL = '1 1 1';
			e.color2 = '1 1 1';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_seraph_amnt"));
			e.colorL = '1 1 1';
			e.color2 = '1 1 1';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Police")));
			e.colorL = '0.1 0.1 0.3';
			e.color2 = '0.1 0.1 0.3';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_police_amnt"));
			e.colorL = '0.1 0.1 0.3';
			e.color2 = '0.1 0.1 0.3';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Soldier")));
			e.colorL = '0.1 0.3 0.1';
			e.color2 = '0.1 0.3 0.1';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_soldier_amnt"));
			e.colorL = '0.1 0.3 0.1';
			e.color2 = '0.1 0.3 0.1';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("AO:Cyborg")));
			e.colorL = '0.5 0.8 1';
			e.color2 = '0.5 0.8 1';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_aocyborg_amnt"));
			e.colorL = '0.5 0.8 1';
			e.color2 = '0.5 0.8 1';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("ShinRae")));
			e.colorL = '0.3 0.0 0.5';
			e.color2 = '0.3 0.0 0.5';
			setDependent(e, "g_za", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 1, 0.01, "g_za_monster_shinrae_amnt"));
			e.colorL = '0.3 0.0 0.5';
			e.color2 = '0.3 0.0 0.5';
			setDependent(e, "g_za", 1, 1);
	me.TR(me);
	
	
	
	///////////////////////////////////////
	//Spawn in oceans
	///////////////////////////////////////
	me.gotoRC(me, me.rows - 5, 6); me.setFirstColumn(me, me.currentColumn);
	me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticTextLabel(0, _("WaterType")));
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.0, e = makeXonoticSlider(0, 3, 1, "g_spawnfoliagearound_watertype"));
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("WaterLVL")));
			e.colorL = '0.8 0.9 1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_waterlevel"));
			e.colorL = '0.8 0.9 1';
			e.color2 = '0.8 0.9 1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("LavaLVL")));
			e.colorL = '0.8 0.1 0.1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_lavalevel"));
			e.colorL = '0.8 0.1 0.1';
			e.color2 = '0.8 0.1 0.1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);	
		
		
			
	me.gotoRC(me, me.rows - 5, 8); me.setFirstColumn(me, me.currentColumn);		
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_liquidlvl_based", _("BASED")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("SlimeLVL")));
			e.colorL = '0.3 1 0';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_slimelevel"));
			e.colorL = '0.3 1 0';
			e.color2 = '0.3 1 0';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("OilLVL")));
			e.colorL = '0.34 0.34 0.34';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_oillevel"));
			e.colorL = '0.4 0.4 0.4';
			e.color2 = '0.4 0.4 0.4';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_oilspreadlimitless", _("L")));
			e.colorL = '0.4 0.4 0.4';
			setDependent(e, "g_spawnfoliagearound_oillevel", 0, 999999999999);
	me.TR(me);			
			
			
	me.gotoRC(me, me.rows - 5, 10); me.setFirstColumn(me, me.currentColumn);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.8, e = makeXonoticCheckBox(0, "g_spawnfoliagearound_liquidlvl_immediate", _("Immediate")));
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("MethaneLVL")));
			e.colorL = '1 0.5 0';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_methanelevel"));
			e.colorL = '1 0.5 0';
			e.color2 = '1 0.5 0';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);
		me.TDempty(me, 0.2);
		me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("ChemLVL")));
			e.colorL = '0.75 0 1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
		me.TD(me, 1, 1.4, e = makeXonoticSlider(0, 32512, 1, "g_spawnfoliagearound_chemlevel"));
			e.colorL = '0.75 0 1';
			e.color2 = '0.75 0 1';
			//setDependent(e, "g_spawnfoliagearound", 1, 1);
	me.TR(me);






	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticMutatorsDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticMutatorsDialog).close(me);
}
#endif
