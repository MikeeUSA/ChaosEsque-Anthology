#ifdef INTERFACE
CLASS(XonoticStartweaponsDialog) EXTENDS(XonoticDialog)
	METHOD(XonoticStartweaponsDialog, fill, void(entity))
	METHOD(XonoticStartweaponsDialog, showNotify, void(entity))
	METHOD(XonoticStartweaponsDialog, close, void(entity))
	ATTRIB(XonoticStartweaponsDialog, title, string, _("Team weapons"))
	ATTRIB(XonoticStartweaponsDialog, color, vector, SKINCOLOR_DIALOG_ADVANCED)
	ATTRIB(XonoticStartweaponsDialog, intendedWidth, float, 1.0)
	ATTRIB(XonoticStartweaponsDialog, rows, float, 82)
	ATTRIB(XonoticStartweaponsDialog, columns, float, 4)
	ATTRIB(XonoticStartweaponsDialog, refilterEntity, entity, NULL)
ENDCLASS(XonoticStartweaponsDialog)
#endif

#ifdef IMPLEMENTATION
void XonoticStartweaponsDialog_showNotify(entity me)
{
	loadAllCvars(me);
}

void XonoticStartweaponsDialog_fill(entity me)
{
	entity e;
	me.TR(me);
		me.TD(me, 1, 0.25, makeXonoticTextLabel(0, _("Cells")));
			me.TD(me, 1, 0.75, makeXonoticSlider(0, 300, 5, "g_start_ammo_cells"));
		me.TD(me, 1, 0.25, makeXonoticTextLabel(0, _("Nails")));
			me.TD(me, 1, 0.75, makeXonoticSlider(0, 300, 5, "g_start_ammo_nails"));
		me.TD(me, 1, 0.25, makeXonoticTextLabel(0, _("Rockets")));
			me.TD(me, 1, 0.75, makeXonoticSlider(0, 300, 5, "g_start_ammo_rockets"));
		me.TD(me, 1, 0.25, makeXonoticTextLabel(0, _("Shells")));
			me.TD(me, 1, 0.75, makeXonoticSlider(0, 300, 5, "g_start_ammo_shells"));
	me.TR(me);
	me.TD(me, 1, 0.5, makeXonoticTextLabel(0, _("Total Override")));
		me.TD(me, 1, 1.8, makeXonoticSlider(0, 2, 1, "g_start_weapon_teamoverrides"));
		//was 1.9, added the 0.06, changed to 1.8, same for below with the 2.3
		
	me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_nocost", _("Zero Build Cost")));
	me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_nobuildtime", _("Zero Build Time")));
	me.TD(me, 1, 0.34, e = makeXonoticCheckBox(0, "g_balance_multitool_noknowledgeneeded", _("Zero Knowledge")));
	me.TD(me, 1, 0.33, e = makeXonoticCheckBox(0, "g_balance_multitool_ancientonly", _("MT: Ancient")));
	me.TD(me, 1, 0.06, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noweapons", _("")));
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nosuits", _("")));
	me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noaircraft", _("No Air")));

	me.TR(me);
	me.TDempty(me, 2.3);
	me.TD(me, 1, 0.325, e = makeXonoticTextLabel(0, _("FreeBuild Blocks")));
	me.TD(me, 1, 0.175, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild_blocks"));
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitool_toofarblockscountasbuildings", _("")));
	me.TD(me, 1, 0.325, e = makeXonoticTextLabel(0, _("FreeBuild All")));
	me.TD(me, 1, 0.175, e = makeXonoticSlider(0, 4, 1, "g_balance_multitool_freebuild"));
	me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_ignorebuild_blocks", _("")));
	me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_claimstones", _("")));
	me.TD(me, 1, 0.1, e = makeXonoticCheckBox(0, "g_balance_multitool_bedspawnpoints", _("")));
	me.TD(me, 1, 0.06, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_noammo", _("")));
	me.TD(me, 1, 0.05, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_nomiscgroundvehicle", _("")));
	me.TD(me, 1, 0.2, e = makeXonoticCheckBox(0, "g_balance_multitoolutilitool_notanks", _("No Tanks")));
//Team1
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Team 1:")));
	
	me.TD(me, 1, 0.4, e = makeXonoticCheckBox(0, "g_nades", _("Grenades")));
		e.colorL = '0.1 0.1 0.1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_grenades_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Fragnades")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_fragnades_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Flashbangs")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_flashbangs_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Smokenades")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_smokenades_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("Landmines")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_landmines_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.4, e = makeXonoticTextLabel(0, _("AT Mines")));
		e.colorL = '0.1 0.1 0.1';
		setDependent(e, "g_nades", 1, 1);
	me.TD(me, 1, 0.4, e = makeXonoticSlider(0, 20, 1, "g_start_atmines_team1"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); //me.TDempty(me, 0.2);
	
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_laser", _("Laser")));
		e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shotgun", _("Shotgun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crypistol", _("Crypistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_uzi", _("MachineGun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_grenadelauncher", _("Mortar")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sportshotgun", _("SportShotgun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_minelayer", _("Minelayer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_electro", _("Electro")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spikedflail", _("SpikedFlail")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crylink", _("Crylink")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_nex", _("Nex")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shootingstar", _("Shooting-Star")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hagar", _("Hagar")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_rocketlauncher", _("RocketLauncher")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_fightersword", _("FighterSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_porto", _("Port-O-Launch")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_minstanex", _("MinstaNex")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_styeraug", _("Styer Aug")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hook", _("Hook")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hlac", _("HLAC")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m9pistol", _("M9 Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tuba", _("Tuba")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_rifle", _("Rifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_styertmp", _("Styer TMP")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";		
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_fireball", _("Fireball")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_seeker", _("Seeker")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crylancer", _("Crylancer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pistol", _("Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hmg", _("HeavyMachineGun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m82rifle", _("M82 Rifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_mg", _("AssaultRifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_explosivevest", _("Explosives")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_amr18", _("AMR-18")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crossbowdtwr", _("Crossbow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_warhammerspiked", _("Warhammer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spas12", _("SPAS-12")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shotgunautomat", _("ShotgunAutomat")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pumpshotgun", _("PumpShotgun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_longpistol", _(".45 Longslide")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightninggun", _("Lightninggun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_g98", _("G98")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m1903", _("M1903")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_nukelayer", _("NukeLayer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_caltrop", _("Caltrops")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_mosin", _("Mosin-Nagant")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_torch", _("Torch")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_revolver", _("Revolver")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_mauserpistol", _("MauserPistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bigpistol", _(".45 Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m1921", _(".45 SMG 1921")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_machinepistol", _("MachinePistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_flashlight", _("Flashlight")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lrr", _("LongRangeRifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hellriegelsmg", _("HellriegelSMG")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_multitool", _("Multi-Tool")));
		e.colorL = '0.5 0.25 0.25'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shortsword", _("ShortSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_webley", _("Webley")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_broadaxe", _("BroadAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_longsword", _("LongSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_webleylong", _("WebleyDragoon")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_rapier", _("Rapier")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_carbine", _("Carbine")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_chauchat", _("Chauchat")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_utilitool", _("Utili-Tool")));
		e.colorL = '0.5 0.25 0.25'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shackles", _("Shackles")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shosho", _("Sho-Sho")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spear", _("Spear")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pdw", _("PDW")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bar1918", _("BAR-1918")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightpistol", _("9mm Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_morgenstern", _("Morgenstern")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_nagant1895", _("Nagant M1895")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_katana", _("Katana")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_odachi", _("Odachi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_mg0815", _("MG 08/15")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_nagamaki", _("Nagamaki")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightsabre", _("Lightsabre")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lewismg", _("LewisGun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tetsubo", _("Tetsubo")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_largepistol", _(".50 Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightsabreii", _("LightsabreII")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightauto", _("9mm AutoPistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_magnum", _("357 Magnum")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightsabreiv", _("LightsabreIV")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crowbar", _("Crowbar")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_yari", _("Yari")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightsabrexi", _("LightsabreXI")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ak47", _("AK-47")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_rpg7launcher", _("RPG7")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sunbeam", _("Sunbeam")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_aks74u", _("AKS-74u")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tt33pistol", _("TT33 Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_starblast", _("Starblast")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ffmagnum", _("44 Magnum")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m16mini", _("M16 mini")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sunburst", _("Sunburst")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m16vn", _("M16 vn")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_browninghp", _("9mm HiPower")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sunbolt", _("Sunbolt")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_longbow", _("Longbow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_cudgel", _("Cudgel")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_starlase", _("Starlase")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crudebow", _("Crude Bow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_compositebow", _("Composite Bow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_svd", _("SVD")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_lightcrossbow", _("Light Crossbow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_flangedmace", _("Flanged Mace")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bat", _("Bat")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_warmallet", _("War Mallet")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_kiduchi", _("Kiduchi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spikedmace", _("Spiked Mace")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_microuzi", _("MicroUzi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_miniuzi", _("Uzi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sai", _("Sai")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ra4launcher", _("RA4")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_stoneaxe", _("StoneAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spectre", _("Spectre")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shiningstar", _("Shiningstar")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_poleaxe", _("PoleAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_armingsword", _("ArmingSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_yumibow", _("Yumi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ironcrow", _("IronCrow")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_defendersword", _("DefenderSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_handcuffs", _("Handcuffs")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_greyironmallet", _("GreyIronMallet")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_beardedaxe", _("BeardedAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ironknife", _("Iron Knife")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_dagger", _("Dagger")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spikedcudgel", _("Spiked Cudgel")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_spikedclub", _("Spiked Club")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sks45", _("SKS-45")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bronzecudgel", _("Bronze Cudgel")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_chainsaw", _("Chainsaw")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_clawhammer", _("Claw Hammer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tec9", _("Tec-9")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_staffflame", _("Staff of Flame")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_staffmagi", _("Magicians Staff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_poundersmg", _("Pounder-SMG")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bastardsword", _("BastardSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_scimitar", _("Scimitar")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_flamethrower", _("FlameThrower")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_infantryaxe", _("InfantryAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_elvenaxe", _("ElvenAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_devastator", _("Devastator")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_quarterstaff", _("Quarterstaff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_elvensabre", _("ElvenSabre")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_hagar2", _("Hagar-2")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_waraxe", _("WarAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_elvenstaff", _("ElvenStaff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_mortar", _("MortarCannon")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_powersaw", _("PowerSaw")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_elvenglaive", _("ElvenGlaive")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_l85a2", _("L85A2")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_woodaxe", _("WoodsmansAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_doublebitaxe", _("DoubleBitAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_fnscar", _("FN SCAR-H")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_falchion", _("Falchion")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_axe", _("Axe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_g36c", _("G36C")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pickaxe", _("Pickaxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_elvenhammer", _("ElvenHammer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_navy1851revolver", _("Navy1851")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1"; 
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m16a2", _("M16A2")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	//me.TDempty(me, 0.3333);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pepperboxrevolver", _("Pepperbox")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_colt44revolver", _("Colt44")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_musket", _("Musket")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_flintlockpistol", _("Flintlock")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_henry1860rifle", _("HenryRifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_eightgaugeshotgun", _("8gaShotgun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_coltlightning", _("ColtLightning")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_sharpsrifle", _("SharpsRifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_eightgaugesawedoff", _("8gaSawedOff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tengaugedouble", _("10gaDouble")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tengaugesawedoff", _("10gaSawedOff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bowieknife", _("BowieKnife")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_arkansastoothpick", _("ArkansasToothpick")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_milflail", _("MilitaryFlail")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_infantrystaff", _("InfantryStaff")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_kriegshammer", _("KriegsHammer")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_battleaxe", _("BattleAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_bardiche", _("Bardiche")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_skirmishersaxe", _("SkirmishersAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_dadao", _("Dadao")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_tanegashima", _("Tanegashima")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_crusadersword", _("CrusaderSword")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_templaraxe", _("TemplarAxe")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_p90", _("P90")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_fivesevenpistol", _("5.7mm Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m93rpistol", _("93R Pistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_t17mmrifle", _("T17mm Rifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_famas", _("FAMAS")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_knife", _("Knife")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m1928", _(".45 SMG 1928")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m1929", _(".45 SMG 1929M")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_czskorpion", _("SV Skorpion")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_czskorpion", _("CZ Skorpion")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_henry1860maresleg", _("Mare'sLeg")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_schofieldrevolver", _("Schofield")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_r1856revolver", _("Remington1856")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1"; 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_winchester1873rifle", _("WinchesterRifle")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1"; 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_winchester1897", _("Winchester1897")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m1897trenchgun", _("M1897Trenchgun")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_ithacastakeout", _("IthacaStakeout")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_flamberge", _("Flamberge")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_streetsweeper", _("StreetSweeper")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_targetpistol", _("TargetPistol")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_rpd", _("RPD")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_m249para", _("M249Para")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pkm", _("PKM")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_shirasaya", _("Shirasaya")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_zatoichi", _("Zatoichi")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_claymore", _("Claymore")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team1_pudao", _("Pudao")));
		e.colorL = '1 0 0'; e.cvarOffValue = "-1";
		
	
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Knowledge:")));
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_carpentry", _("C")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_mortise", _("M")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_stonemasonry", _("S")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_arch", _("A")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_ironworking", _("I")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_welding", _("w")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team1_concrete", _("c")));
		e.colorL = '0.5 0.0 0.0'; e.cvarOffValue = "0";
	
me.gotoRC(me, 2, 1); me.setFirstColumn(me, me.currentColumn);
	//Team2
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Team 2:")));
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_grenades_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_fragnades_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_flashbangs_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_smokenades_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_landmines_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_atmines_team2"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); //me.TDempty(me, 0.2);
	
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_laser", _("Laser")));
		e.colorL = '0 0 1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shotgun", _("Shotgun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crypistol", _("Crypistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_uzi", _("MachineGun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_grenadelauncher", _("Mortar")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sportshotgun", _("SportShotgun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_minelayer", _("Minelayer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_electro", _("Electro")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spikedflail", _("SpikedFlail")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crylink", _("Crylink")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_nex", _("Nex")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shootingstar", _("Shooting-Star")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hagar", _("Hagar")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_rocketlauncher", _("RocketLauncher")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_fightersword", _("FighterSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_porto", _("Port-O-Launch")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_minstanex", _("MinstaNex")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_styeraug", _("Styer Aug")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hook", _("Hook")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hlac", _("HLAC")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m9pistol", _("M9 Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tuba", _("Tuba")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_rifle", _("Rifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_styertmp", _("Styer TMP")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_fireball", _("Fireball")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_seeker", _("Seeker")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crylancer", _("Crylancer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pistol", _("Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hmg", _("HeavyMachineGun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m82rifle", _("M82 Rifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_mg", _("AssaultRifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_explosivevest", _("Explosives")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_amr18", _("AMR-18")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crossbowdtwr", _("Crossbow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_warhammerspiked", _("Warhammer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spas12", _("SPAS-12")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shotgunautomat", _("ShotgunAutomat")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pumpshotgun", _("PumpShotgun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_longpistol", _(".45 Longslide")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightninggun", _("Lightninggun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_g98", _("G98")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m1903", _("M1903")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_nukelayer", _("NukeLayer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_caltrop", _("Caltrops")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_mosin", _("Mosin-Nagant")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_torch", _("Torch")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_revolver", _("Revolver")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_mauserpistol", _("MauserPistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bigpistol", _(".45 Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m1921", _(".45 SMG 1921")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_machinepistol", _("MachinePistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_flashlight", _("Flashlight")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lrr", _("LongRangeRifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hellriegelsmg", _("HellriegelSMG")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_multitool", _("Multi-Tool")));
		e.colorL = '0.25 0.25 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shortsword", _("ShortSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_webley", _("Webley")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_broadaxe", _("BroadAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_longsword", _("LongSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_webleylong", _("WebleyDragoon")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_rapier", _("Rapier")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_carbine", _("Carbine")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_chauchat", _("Chauchat")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_utilitool", _("Utili-Tool")));
		e.colorL = '0.25 0.25 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shackles", _("Shackles")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shosho", _("Sho-Sho")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spear", _("Spear")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pdw", _("PDW")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bar1918", _("BAR-1918")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightpistol", _("9mm Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_morgenstern", _("Morgenstern")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_nagant1895", _("Nagant M1895")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_katana", _("Katana")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_odachi", _("Odachi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_mg0815", _("MG 08/15")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_nagamaki", _("Nagamaki")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightsabre", _("Lightsabre")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lewismg", _("LewisGun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tetsubo", _("Tetsubo")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_largepistol", _(".50 Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightsabreii", _("LightsabreII")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightauto", _("9mm AutoPistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_magnum", _("357 Magnum")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightsabreiv", _("LightsabreIV")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crowbar", _("Crowbar")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_yari", _("Yari")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightsabrexi", _("LightsabreXI")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ak47", _("AK-47")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_rpg7launcher", _("RPG7")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sunbeam", _("Sunbeam")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_aks74u", _("AKS-74u")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tt33pistol", _("TT33 Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_starblast", _("Starblast")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ffmagnum", _("44 Magnum")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m16mini", _("M16 mini")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sunburst", _("Sunburst")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m16vn", _("M16 vn")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_browninghp", _("9mm HiPower")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sunbolt", _("Sunbolt")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_longbow", _("Longbow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_cudgel", _("Cudgel")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_starlase", _("Starlase")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crudebow", _("Crude Bow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_compositebow", _("Composite Bow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_svd", _("SVD")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_lightcrossbow", _("Light Crossbow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_flangedmace", _("Flanged Mace")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bat", _("Bat")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_warmallet", _("War Mallet")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_kiduchi", _("Kiduchi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spikedmace", _("Spiked Mace")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_microuzi", _("MicroUzi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_miniuzi", _("Uzi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sai", _("Sai")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ra4launcher", _("RA4")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_stoneaxe", _("StoneAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spectre", _("Spectre")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shiningstar", _("Shiningstar")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_poleaxe", _("PoleAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_armingsword", _("ArmingSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_yumibow", _("Yumi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ironcrow", _("IronCrow")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_defendersword", _("DefenderSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_handcuffs", _("Handcuffs")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_greyironmallet", _("GreyIronMallet")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_beardedaxe", _("BeardedAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ironknife", _("Iron Knife")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_dagger", _("Dagger")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spikedcudgel", _("Spiked Cudgel")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_spikedclub", _("Spiked Club")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sks45", _("SKS-45")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bronzecudgel", _("Bronze Cudgel")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_chainsaw", _("Chainsaw")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_clawhammer", _("Claw Hammer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tec9", _("Tec-9")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_staffflame", _("Staff of Flame")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_staffmagi", _("Magicians Staff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_poundersmg", _("Pounder-SMG")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bastardsword", _("BastardSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_scimitar", _("Scimitar")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_flamethrower", _("FlameThrower")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_infantryaxe", _("InfantryAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_elvenaxe", _("ElvenAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_devastator", _("Devastator")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_quarterstaff", _("Quarterstaff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_elvensabre", _("ElvenSabre")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_hagar2", _("Hagar-2")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_waraxe", _("WarAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_elvenstaff", _("ElvenStaff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_mortar", _("MortarCannon")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_powersaw", _("PowerSaw")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_elvenglaive", _("ElvenGlaive")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_l85a2", _("L85A2")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_woodaxe", _("WoodsmansAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_doublebitaxe", _("DoubleBitAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_fnscar", _("FN SCAR-H")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_falchion", _("Falchion")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_axe", _("Axe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_g36c", _("G36C")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pickaxe", _("Pickaxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_elvenhammer", _("ElvenHammer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_navy1851revolver", _("Navy1851")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1"; 
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m16a2", _("M16A2")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	//me.TDempty(me, 0.3333);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pepperboxrevolver", _("Pepperbox")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_colt44revolver", _("Colt44")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_musket", _("Musket")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_flintlockpistol", _("Flintlock")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_henry1860rifle", _("HenryRifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_eightgaugeshotgun", _("8gaShotgun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_coltlightning", _("ColtLightning")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_sharpsrifle", _("SharpsRifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_eightgaugesawedoff", _("8gaSawedOff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tengaugedouble", _("10gaDouble")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tengaugesawedoff", _("10gaSawedOff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bowieknife", _("BowieKnife")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_arkansastoothpick", _("ArkansasToothpick")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_milflail", _("MilitaryFlail")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_infantrystaff", _("InfantryStaff")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_kriegshammer", _("KriegsHammer")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_battleaxe", _("BattleAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_bardiche", _("Bardiche")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_skirmishersaxe", _("SkirmishersAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_dadao", _("Dadao")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_tanegashima", _("Tanegashima")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_crusadersword", _("CrusaderSword")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_templaraxe", _("TemplarAxe")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_p90", _("P90")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_fivesevenpistol", _("5.7mm Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m93rpistol", _("93R Pistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_t17mmrifle", _("T17mm Rifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_famas", _("FAMAS")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_knife", _("Knife")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m1928", _(".45 SMG 1928")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m1929", _(".45 SMG 1929M")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_czskorpion", _("SV Skorpion")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_czskorpion", _("CZ Skorpion")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_henry1860maresleg", _("Mare'sLeg")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_schofieldrevolver", _("Schofield")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_r1856revolver", _("Remington1856")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1"; 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_winchester1873rifle", _("WinchesterRifle")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_winchester1897", _("Winchester1897")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1"; 
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m1897trenchgun", _("M1897Trenchgun")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_ithacastakeout", _("IthacaStakeout")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_flamberge", _("Flamberge")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_streetsweeper", _("StreetSweeper")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_targetpistol", _("TargetPistol")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_rpd", _("RPD")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_m249para", _("M249Para")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pkm", _("PKM")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_shirasaya", _("Shirasaya")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_zatoichi", _("Zatoichi")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_claymore", _("Claymore")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team2_pudao", _("Pudao")));
		e.colorL = '0 0 1'; e.cvarOffValue = "-1";
	
	me.TR(me); me.TDempty(me, 0.2);
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_carpentry", _("C")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_mortise", _("M")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_stonemasonry", _("S")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_arch", _("A")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_ironworking", _("I")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_welding", _("w")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team2_concrete", _("c")));
		e.colorL = '0.0 0.0 0.5'; e.cvarOffValue = "0";
	
	
me.gotoRC(me, 2, 2); me.setFirstColumn(me, me.currentColumn);
	//Team3
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Team 3:")));
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_grenades_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_fragnades_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_flashbangs_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_smokenades_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_landmines_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_atmines_team3"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); //me.TDempty(me, 0.2);
	
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_laser", _("Laser")));
		e.colorL = '1 1 0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shotgun", _("Shotgun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crypistol", _("Crypistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_uzi", _("MachineGun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_grenadelauncher", _("Mortar")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sportshotgun", _("SportShotgun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_minelayer", _("Minelayer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_electro", _("Electro")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spikedflail", _("SpikedFlail")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crylink", _("Crylink")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_nex", _("Nex")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shootingstar", _("Shooting-Star")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hagar", _("Hagar")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_rocketlauncher", _("RocketLauncher")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_fightersword", _("FighterSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_porto", _("Port-O-Launch")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_minstanex", _("MinstaNex")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_styeraug", _("Styer Aug")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hook", _("Hook")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hlac", _("HLAC")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m9pistol", _("M9 Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tuba", _("Tuba")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_rifle", _("Rifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_styertmp", _("Styer TMP")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_fireball", _("Fireball")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_seeker", _("Seeker")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crylancer", _("Crylancer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pistol", _("Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hmg", _("HeavyMachineGun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m82rifle", _("M82 Rifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_mg", _("AssaultRifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_explosivevest", _("Explosives")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_amr18", _("AMR-18")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crossbowdtwr", _("Crossbow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_warhammerspiked", _("Warhammer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spas12", _("SPAS-12")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shotgunautomat", _("ShotgunAutomat")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pumpshotgun", _("PumpShotgun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_longpistol", _(".45 Longslide")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightninggun", _("Lightninggun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_g98", _("G98")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m1903", _("M1903")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_nukelayer", _("NukeLayer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_caltrop", _("Caltrops")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_mosin", _("Mosin-Nagant")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_torch", _("Torch")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_revolver", _("Revolver")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_mauserpistol", _("MauserPistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bigpistol", _(".45 Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m1921", _(".45 SMG 1921")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_machinepistol", _("MachinePistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_flashlight", _("Flashlight")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lrr", _("LongRangeRifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hellriegelsmg", _("HellriegelSMG")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_multitool", _("Multi-Tool")));
		e.colorL = '0.5 0.5 0.25'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shortsword", _("ShortSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_webley", _("Webley")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_broadaxe", _("BroadAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_longsword", _("LongSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_webleylong", _("WebleyDragoon")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_rapier", _("Rapier")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_carbine", _("Carbine")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_chauchat", _("Chauchat")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_utilitool", _("Utili-Tool")));
		e.colorL = '0.5 0.5 0.25'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shackles", _("Shackles")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shosho", _("Sho-Sho")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spear", _("Spear")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pdw", _("PDW")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bar1918", _("BAR-1918")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightpistol", _("9mm Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_morgenstern", _("Morgenstern")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_nagant1895", _("Nagant M1895")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_katana", _("Katana")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_odachi", _("Odachi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_mg0815", _("MG 08/15")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_nagamaki", _("Nagamaki")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightsabre", _("Lightsabre")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lewismg", _("LewisGun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tetsubo", _("Tetsubo")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_largepistol", _(".50 Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightsabreii", _("LightsabreII")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightauto", _("9mm AutoPistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_magnum", _("357 Magnum")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightsabreiv", _("LightsabreIV")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crowbar", _("Crowbar")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_yari", _("Yari")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightsabrexi", _("LightsabreXI")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ak47", _("AK-47")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_rpg7launcher", _("RPG7")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sunbeam", _("Sunbeam")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_aks74u", _("AKS-74u")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tt33pistol", _("TT33 Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_starblast", _("Starblast")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ffmagnum", _("44 Magnum")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m16mini", _("M16 mini")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sunburst", _("Sunburst")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m16vn", _("M16 vn")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_browninghp", _("9mm HiPower")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sunbolt", _("Sunbolt")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_longbow", _("Longbow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_cudgel", _("Cudgel")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_starlase", _("Starlase")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crudebow", _("Crude Bow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_compositebow", _("Composite Bow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_svd", _("SVD")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_lightcrossbow", _("Light Crossbow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_flangedmace", _("Flanged Mace")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bat", _("Bat")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_warmallet", _("War Mallet")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_kiduchi", _("Kiduchi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spikedmace", _("Spiked Mace")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_microuzi", _("MicroUzi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_miniuzi", _("Uzi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sai", _("Sai")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ra4launcher", _("RA4")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_stoneaxe", _("StoneAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spectre", _("Spectre")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shiningstar", _("Shiningstar")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_poleaxe", _("PoleAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_armingsword", _("ArmingSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_yumibow", _("Yumi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ironcrow", _("IronCrow")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_defendersword", _("DefenderSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_handcuffs", _("Handcuffs")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_greyironmallet", _("GreyIronMallet")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_beardedaxe", _("BeardedAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ironknife", _("Iron Knife")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_dagger", _("Dagger")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spikedcudgel", _("Spiked Cudgel")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_spikedclub", _("Spiked Club")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sks45", _("SKS-45")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bronzecudgel", _("Bronze Cudgel")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_chainsaw", _("Chainsaw")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_clawhammer", _("Claw Hammer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tec9", _("Tec-9")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_staffflame", _("Staff of Flame")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_staffmagi", _("Magicians Staff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_poundersmg", _("Pounder-SMG")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bastardsword", _("BastardSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_scimitar", _("Scimitar")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_flamethrower", _("FlameThrower")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_infantryaxe", _("InfantryAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_elvenaxe", _("ElvenAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_devastator", _("Devastator")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_quarterstaff", _("Quarterstaff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_elvensabre", _("ElvenSabre")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_hagar2", _("Hagar-2")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_waraxe", _("WarAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_elvenstaff", _("ElvenStaff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_mortar", _("MortarCannon")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_powersaw", _("PowerSaw")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_elvenglaive", _("ElvenGlaive")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_l85a2", _("L85A2")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_woodaxe", _("WoodsmansAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_doublebitaxe", _("DoubleBitAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_fnscar", _("FN SCAR-H")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_falchion", _("Falchion")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_axe", _("Axe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_g36c", _("G36C")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pickaxe", _("Pickaxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_elvenhammer", _("ElvenHammer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_navy1851revolver", _("Navy1851")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1"; 
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m16a2", _("M16A2")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	//me.TDempty(me, 0.3333);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pepperboxrevolver", _("Pepperbox")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_colt44revolver", _("Colt44")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_musket", _("Musket")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_flintlockpistol", _("Flintlock")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_henry1860rifle", _("HenryRifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_eightgaugeshotgun", _("8gaShotgun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_coltlightning", _("ColtLightning")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_sharpsrifle", _("SharpsRifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_eightgaugesawedoff", _("8gaSawedOff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tengaugedouble", _("10gaDouble")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tengaugesawedoff", _("10gaSawedOff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bowieknife", _("BowieKnife")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_arkansastoothpick", _("ArkansasToothpick")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_milflail", _("MilitaryFlail")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_infantrystaff", _("InfantryStaff")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_kriegshammer", _("KriegsHammer")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_battleaxe", _("BattleAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_bardiche", _("Bardiche")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_skirmishersaxe", _("SkirmishersAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_dadao", _("Dadao")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_tanegashima", _("Tanegashima")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_crusadersword", _("CrusaderSword")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_templaraxe", _("TemplarAxe")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_p90", _("P90")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_fivesevenpistol", _("5.7mm Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m93rpistol", _("93R Pistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_t17mmrifle", _("T17mm Rifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_famas", _("FAMAS")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_knife", _("Knife")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m1928", _(".45 SMG 1928")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m1929", _(".45 SMG 1929M")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_czskorpion", _("SV Skorpion")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_czskorpion", _("CZ Skorpion")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_henry1860maresleg", _("Mare'sLeg")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_schofieldrevolver", _("Schofield")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_r1856revolver", _("Remington1856")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";  
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_winchester1873rifle", _("WinchesterRifle")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_winchester1897", _("Winchester1897")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m1897trenchgun", _("M1897Trenchgun")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_ithacastakeout", _("IthacaStakeout")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_flamberge", _("Flamberge")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_streetsweeper", _("StreetSweeper")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_targetpistol", _("TargetPistol")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_rpd", _("RPD")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_m249para", _("M249Para")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pkm", _("PKM")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_shirasaya", _("Shirasaya")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_zatoichi", _("Zatoichi")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_claymore", _("Claymore")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team3_pudao", _("Pudao")));
		e.colorL = '1 1 0'; e.cvarOffValue = "-1";
		
	me.TR(me); me.TDempty(me, 0.2);
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_carpentry", _("C")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_mortise", _("M")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_stonemasonry", _("S")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_arch", _("A")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_ironworking", _("I")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_welding", _("w")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team3_concrete", _("c")));
		e.colorL = '0.5 0.5 0.0'; e.cvarOffValue = "0";
	
	
me.gotoRC(me, 2, 3); me.setFirstColumn(me, me.currentColumn);
	//Team4
	me.TR(me); me.TD(me, 1, 0.2, e = makeXonoticTextLabel(0, _("Team 4:")));
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_grenades_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_fragnades_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_flashbangs_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_smokenades_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_landmines_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.8, e = makeXonoticSlider(0, 20, 1, "g_start_atmines_team4"));
		setDependent(e, "g_nades", 1, 1);
	me.TR(me); //me.TDempty(me, 0.2);
	
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_laser", _("Laser")));
		e.colorL = '1 0 1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shotgun", _("Shotgun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crypistol", _("Crypistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_uzi", _("MachineGun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_grenadelauncher", _("Mortar")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sportshotgun", _("SportShotgun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_minelayer", _("Minelayer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_electro", _("Electro")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spikedflail", _("SpikedFlail")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crylink", _("Crylink")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_nex", _("Nex")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shootingstar", _("Shooting-Star")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hagar", _("Hagar")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_rocketlauncher", _("RocketLauncher")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_fightersword", _("FighterSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_porto", _("Port-O-Launch")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_minstanex", _("MinstaNex")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_styeraug", _("Styer Aug")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hook", _("Hook")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hlac", _("HLAC")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m9pistol", _("M9 Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tuba", _("Tuba")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_rifle", _("Rifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_styertmp", _("Styer TMP")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_fireball", _("Fireball")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_seeker", _("Seeker")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crylancer", _("Crylancer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pistol", _("Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hmg", _("HeavyMachineGun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m82rifle", _("M82 Rifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_mg", _("AssaultRifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_explosivevest", _("Explosives")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_amr18", _("AMR-18")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crossbowdtwr", _("Crossbow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_warhammerspiked", _("Warhammer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spas12", _("SPAS-12")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shotgunautomat", _("ShotgunAutomat")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pumpshotgun", _("PumpShotgun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_longpistol", _(".45 Longslide")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightninggun", _("Lightninggun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_g98", _("G98")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m1903", _("M1903")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_nukelayer", _("NukeLayer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_caltrop", _("Caltrops")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_mosin", _("Mosin-Nagant")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_torch", _("Torch")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_revolver", _("Revolver")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_mauserpistol", _("MauserPistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bigpistol", _(".45 Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m1921", _(".45 SMG 1921")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_machinepistol", _("MachinePistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_flashlight", _("Flashlight")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lrr", _("LongRangeRifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hellriegelsmg", _("HellriegelSMG")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_multitool", _("Multi-Tool")));
		e.colorL = '0.5 0.25 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shortsword", _("ShortSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_webley", _("Webley")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_broadaxe", _("BroadAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_longsword", _("LongSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_webleylong", _("WebleyDragoon")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_rapier", _("Rapier")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_carbine", _("Carbine")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_chauchat", _("Chauchat")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_utilitool", _("Utili-Tool")));
		e.colorL = '0.5 0.25 0.5'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shackles", _("Shackles")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shosho", _("Sho-Sho")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spear", _("Spear")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pdw", _("PDW")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bar1918", _("BAR-1918")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightpistol", _("9mm Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_morgenstern", _("Morgenstern")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_nagant1895", _("Nagant M1895")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_katana", _("Katana")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_odachi", _("Odachi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_mg0815", _("MG 08/15")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_nagamaki", _("Nagamaki")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightsabre", _("Lightsabre")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lewismg", _("LewisGun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tetsubo", _("Tetsubo")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_largepistol", _(".50 Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightsabreii", _("LightsabreII")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightauto", _("9mm AutoPistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_magnum", _("357 Magnum")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightsabreiv", _("LightsabreIV")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crowbar", _("Crowbar")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_yari", _("Yari")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightsabrexi", _("LightsabreXI")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ak47", _("AK-47")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_rpg7launcher", _("RPG7")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sunbeam", _("Sunbeam")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_aks74u", _("AKS-74u")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tt33pistol", _("TT33 Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_starblast", _("Starblast")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ffmagnum", _("44 Magnum")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m16mini", _("M16 mini")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sunburst", _("Sunburst")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m16vn", _("M16 vn")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_browninghp", _("9mm HiPower")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sunbolt", _("Sunbolt")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_longbow", _("Longbow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_cudgel", _("Cudgel")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_starlase", _("Starlase")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crudebow", _("Crude Bow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_compositebow", _("Composite Bow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_svd", _("SVD")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_lightcrossbow", _("Light Crossbow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_flangedmace", _("Flanged Mace")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bat", _("Bat")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_warmallet", _("War Mallet")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_kiduchi", _("Kiduchi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spikedmace", _("Spiked Mace")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_microuzi", _("MicroUzi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_miniuzi", _("Uzi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sai", _("Sai")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ra4launcher", _("RA4")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_stoneaxe", _("StoneAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spectre", _("Spectre")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shiningstar", _("Shiningstar")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_poleaxe", _("PoleAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_armingsword", _("ArmingSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_yumibow", _("Yumi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ironcrow", _("IronCrow")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_defendersword", _("DefenderSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_handcuffs", _("Handcuffs")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_greyironmallet", _("GreyIronMallet")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_beardedaxe", _("BeardedAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ironknife", _("Iron Knife")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_dagger", _("Dagger")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spikedcudgel", _("Spiked Cudgel")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_spikedclub", _("Spiked Club")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sks45", _("SKS-45")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bronzecudgel", _("Bronze Cudgel")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_chainsaw", _("Chainsaw")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_clawhammer", _("Claw Hammer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tec9", _("Tec-9")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_staffflame", _("Staff of Flame")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_staffmagi", _("Magicians Staff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_poundersmg", _("Pounder-SMG")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bastardsword", _("BastardSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_scimitar", _("Scimitar")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_flamethrower", _("FlameThrower")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_infantryaxe", _("InfantryAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_elvenaxe", _("ElvenAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_devastator", _("Devastator")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_quarterstaff", _("Quarterstaff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_elvensabre", _("ElvenSabre")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_hagar2", _("Hagar-2")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_waraxe", _("WarAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_elvenstaff", _("ElvenStaff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_mortar", _("MortarCannon")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_powersaw", _("PowerSaw")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_elvenglaive", _("ElvenGlaive")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_l85a2", _("L85A2")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_woodaxe", _("WoodsmansAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_doublebitaxe", _("DoubleBitAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_fnscar", _("FN SCAR-H")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_falchion", _("Falchion")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_axe", _("Axe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_g36c", _("G36C")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pickaxe", _("Pickaxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_elvenhammer", _("ElvenHammer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_navy1851revolver", _("Navy1851")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1"; 
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m16a2", _("M16A2")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	//me.TDempty(me, 0.3333);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pepperboxrevolver", _("Pepperbox")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_colt44revolver", _("Colt44")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_musket", _("Musket")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_flintlockpistol", _("Flintlock")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_henry1860rifle", _("HenryRifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_eightgaugeshotgun", _("8gaShotgun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_coltlightning", _("ColtLightning")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_sharpsrifle", _("SharpsRifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_eightgaugesawedoff", _("8gaSawedOff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tengaugedouble", _("10gaDouble")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tengaugesawedoff", _("10gaSawedOff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bowieknife", _("BowieKnife")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_arkansastoothpick", _("ArkansasToothpick")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_milflail", _("MilitaryFlail")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TR(me); //me.TDempty(me, 0.2);
		
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_infantrystaff", _("InfantryStaff")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_kriegshammer", _("KriegsHammer")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_battleaxe", _("BattleAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_bardiche", _("Bardiche")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_skirmishersaxe", _("SkirmishersAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_dadao", _("Dadao")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_tanegashima", _("Tanegashima")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_crusadersword", _("CrusaderSword")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_templaraxe", _("TemplarAxe")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_p90", _("P90")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_fivesevenpistol", _("5.7mm Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m93rpistol", _("93R Pistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_t17mmrifle", _("T17mm Rifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_famas", _("FAMAS")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_knife", _("Knife")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m1928", _(".45 SMG 1928")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m1929", _(".45 SMG 1929M")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_czskorpion", _("SV Skorpion")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_czskorpion", _("CZ Skorpion")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_henry1860maresleg", _("Mare'sLeg")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_schofieldrevolver", _("Schofield")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";	
	
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_r1856revolver", _("Remington1856")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";  
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_winchester1873rifle", _("WinchesterRifle")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_winchester1897", _("Winchester1897")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m1897trenchgun", _("M1897Trenchgun")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_ithacastakeout", _("IthacaStakeout")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_flamberge", _("Flamberge")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me); 
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_streetsweeper", _("StreetSweeper")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_targetpistol", _("TargetPistol")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_rpd", _("RPD")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
				
	me.TR(me);
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_m249para", _("M249Para")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pkm", _("PKM")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_shirasaya", _("Shirasaya")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	
	me.TR(me);	
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_zatoichi", _("Zatoichi")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_claymore", _("Claymore")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
	me.TD(me, 1, 0.3333, e = makeXonoticCheckBox(0, "g_start_weapon_team4_pudao", _("Pudao")));
		e.colorL = '1 0 1'; e.cvarOffValue = "-1";
		
	me.TR(me); me.TDempty(me, 0.2);
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_carpentry", _("C")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_mortise", _("M")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_stonemasonry", _("S")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_arch", _("A")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_ironworking", _("I")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_welding", _("w")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	me.TD(me, 1, 0.11, e = makeXonoticCheckBox(0, "g_start_knowledge_team4_concrete", _("c")));
		e.colorL = '0.5 0.0 0.5'; e.cvarOffValue = "0";
	

	me.gotoRC(me, me.rows - 1, 0);
		me.TD(me, 1, me.columns, e = makeXonoticButton(_("OK"), '0 0 0'));
			e.onClick = Dialog_Close;
			e.onClickEntity = me;
}

void XonoticStartweaponsDialog_close(entity me)
{
	if(me.refilterEntity)
		me.refilterEntity.refilter(me.refilterEntity);
	SUPER(XonoticStartweaponsDialog).close(me);
}
#endif
